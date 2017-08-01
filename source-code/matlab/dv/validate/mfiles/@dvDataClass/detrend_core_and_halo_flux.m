function detrendedApertureFluxTimeSeries = detrend_core_and_halo_flux(dvDataObject,...
                                                                                        quarterlyApertureFluxes,...
                                                                                        conditionedAncillaryDataArray,...
                                                                                        detrendParamStruct,...
                                                                                        dataAnomalyIndicators,...
                                                                                        quarters,...
                                                                                        iTarget)
%
% Copyright 2017 United States Government as represented by the
% Administrator of the National Aeronautics and Space Administration.
% All Rights Reserved.
% 
% NASA acknowledges the SETI Institute's primary role in authoring and
% producing the Kepler Data Processing Pipeline under Cooperative
% Agreement Nos. NNA04CC63A, NNX07AD96A, NNX07AD98A, NNX11AI13A,
% NNX11AI14A, NNX13AD01A & NNX13AD16A.
% 
% This file is available under the terms of the NASA Open Source Agreement
% (NOSA). You should have received a copy of this agreement with the
% Kepler source code; see the file NASA-OPEN-SOURCE-AGREEMENT.doc.
% 
% No Warranty: THE SUBJECT SOFTWARE IS PROVIDED "AS IS" WITHOUT ANY
% WARRANTY OF ANY KIND, EITHER EXPRESSED, IMPLIED, OR STATUTORY,
% INCLUDING, BUT NOT LIMITED TO, ANY WARRANTY THAT THE SUBJECT SOFTWARE
% WILL CONFORM TO SPECIFICATIONS, ANY IMPLIED WARRANTIES OF
% MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, OR FREEDOM FROM
% INFRINGEMENT, ANY WARRANTY THAT THE SUBJECT SOFTWARE WILL BE ERROR
% FREE, OR ANY WARRANTY THAT DOCUMENTATION, IF PROVIDED, WILL CONFORM
% TO THE SUBJECT SOFTWARE. THIS AGREEMENT DOES NOT, IN ANY MANNER,
% CONSTITUTE AN ENDORSEMENT BY GOVERNMENT AGENCY OR ANY PRIOR RECIPIENT
% OF ANY RESULTS, RESULTING DESIGNS, HARDWARE, SOFTWARE PRODUCTS OR ANY
% OTHER APPLICATIONS RESULTING FROM USE OF THE SUBJECT SOFTWARE.
% FURTHER, GOVERNMENT AGENCY DISCLAIMS ALL WARRANTIES AND LIABILITIES
% REGARDING THIRD-PARTY SOFTWARE, IF PRESENT IN THE ORIGINAL SOFTWARE,
% AND DISTRIBUTES IT "AS IS."
% 
% Waiver and Indemnity: RECIPIENT AGREES TO WAIVE ANY AND ALL CLAIMS
% AGAINST THE UNITED STATES GOVERNMENT, ITS CONTRACTORS AND
% SUBCONTRACTORS, AS WELL AS ANY PRIOR RECIPIENT. IF RECIPIENT'S USE OF
% THE SUBJECT SOFTWARE RESULTS IN ANY LIABILITIES, DEMANDS, DAMAGES,
% EXPENSES OR LOSSES ARISING FROM SUCH USE, INCLUDING ANY DAMAGES FROM
% PRODUCTS BASED ON, OR RESULTING FROM, RECIPIENT'S USE OF THE SUBJECT
% SOFTWARE, RECIPIENT SHALL INDEMNIFY AND HOLD HARMLESS THE UNITED
% STATES GOVERNMENT, ITS CONTRACTORS AND SUBCONTRACTORS, AS WELL AS ANY
% PRIOR RECIPIENT, TO THE EXTENT PERMITTED BY LAW. RECIPIENT'S SOLE
% REMEDY FOR ANY SUCH MATTER SHALL BE THE IMMEDIATE, UNILATERAL
% TERMINATION OF THIS AGREEMENT.
%
% adapted from detrend_centroids
% function [detrendedCentroidTimeSeries, originalCentroidTimeSeries] = detrend_centroids(dvDataObject,...
%                                                                                         conditionedAncillaryDataArray,...
%                                                                                         detrendParamStruct,...
%                                                                                         dataAnomalyIndicators,...
%                                                                                         quarters,...
%                                                                                         iTarget)
% 
% This DV method detrends the row and column centroid time series for both prf and flux weighted centroids for the target
% index input against conditioned ancillary data 
%
% INPUT:    dvDataObject                    = dvDataClass object
%           conditionedAncillaryDataArray   = structure containing ancillary data which has
%                                             been short gap filled and synchronized with
%                                             the target data for each target table
%           detrendParamStruct              = control parameter structure used in correcting systematic error
%           dataAnomalyIndicators           = structure with logical indicators for EXCLUDE, ATTITUDE_TWEAK, 
%                                             SAFE_MODE, EARTH_POINT, COARSE_POINT, ARGABRIGHTENING cadences
%           quarters                    
%           iTargettargetStruct 
%
% OUTPUT:   detrendedCentroidTimeSeries     = structure containing timeseries for detrended centroids
%           originalCentroidTimeSeries      = structure containing timeseries for original (undetrended) centroids
%
%           Both output timeseries structs have the form:
%             timeseriesStruct.prf.ra.values
%                                    .uncertainties
%                                    .gapIndicators
%             timeseriesStruct.prf.dec.values
%                                     .uncertainties
%                                     .gapIndicators
%             timeseriesStruct.fluxWeighted.ra.values
%                                             .uncertainties
%                                             .gapIndicators
%             timeseriesStruct.fluxWeighted.dec.values
%                                              .uncertainties
%                                              .gapIndicators



% parse stuff from dvDataObject
% fcConstants = dvDataObject.fcConstants;
targetStruct = dvDataObject.targetStruct(iTarget);
    
% add some needed fields to the targetStruct
targetStruct.debugLevel = dvDataObject.dvConfigurationStruct.debugLevel;
targetStruct.targetIndex = iTarget;


% ~~~~~~~~~~~~~~~~~~ build motion polynomials array
% Apparently motion polynomials only exist for the cadences run in PA (e.g. NOT in the quarterly roll gaps)
% Need to fill out the struct array for all cadences in UOW
% !!!!! don't need tempMotion or motionCadenceNumbers
% tempMotion = [dvDataObject.targetTableDataStruct.motionPolyStruct];
% motionCadenceNumbers = [tempMotion.cadence];
cadenceNumbers = dvDataObject.dvCadenceTimes.cadenceNumbers;
                                           
% Setup 1x4 array of fauxTargetDataStruct to pass to correct_systematic_error
% as "target" flux data. Each target index gets populated with the row/column
% prf/fluxWeighted centroid time series in place of the flux time series. This
% way all four centroid time series for each target can be detrended in a
% single pass. Also save the original centroid time series as optional output.
% Note: fake targets are dim --> keplerMag == 20. 
% Note for ghost diagnostic tests, fauxTargetDataStruct will be a 1x2 struct array
% which contains the core and halo aperture flux time series.             
keplerId = targetStruct.keplerId;

% Build fauxTargetDataStruct by concatenating all the quarterly pixel flux
% timeseries. Do this for both core and halo apertures.
fauxTargetDataStruct = repmat(struct( ...
    'values',zeros(length(cadenceNumbers),1), ...
    'uncertainties', zeros(length(cadenceNumbers),1), ...
    'gapIndicators', true(length(cadenceNumbers),1), ...
    'keplerMag', 20), 1, 2);

for iApertureType = 1:2
    switch iApertureType
        case 1
            apertureStruct = quarterlyApertureFluxes.coreAperture;
            
        case 2
            apertureStruct = quarterlyApertureFluxes.haloAperture;
            
    end % switch
        
    % initialize
    apertureValues = [];
    apertureUncertainties = [];
    apertureGapIndicators = [];
    apertureCadenceNumbers = [];
    
    % accumulate field values for all quarters
    for iQuarter = 1:length(apertureStruct)
        apertureValues = [apertureValues;apertureStruct(iQuarter).totalFlux];
        apertureUncertainties = [apertureUncertainties;apertureStruct(iQuarter).uncertainties];
        apertureGapIndicators = [apertureGapIndicators;apertureStruct(iQuarter).gapIndicators];
        apertureCadenceNumbers = [apertureCadenceNumbers;apertureStruct(iQuarter).cadenceNumbers];
    end % loop over quarters
    
    % Indicator and indexes for cadences associated with aperture fluxes
    % fluxLogical is an indicator of length(cadenceNumbers). It is true
    %    for apertureCadenceNumbers that are in cadenceNumbers
    % foundIdx are the indexes (relative to cadenceNumbers) of the corresponding apertureCadenceNumbers that are found in
    %    cadenceNumbers; the value of the index is zero if there is no corresponding element in 
    %    apertureCadenceNumbers
    [fluxLogical, foundIdx] = ismember(cadenceNumbers, apertureCadenceNumbers);

    
    % populate the fauxTargetDataStruct, filling in the full struct the
    % same way the motionPolynomials are populated
    fauxTargetDataStruct(iApertureType).values(fluxLogical) = apertureValues(foundIdx(fluxLogical));
    fauxTargetDataStruct(iApertureType).uncertainties(fluxLogical) = apertureUncertainties(foundIdx(fluxLogical));
    fauxTargetDataStruct(iApertureType).gapIndicators(fluxLogical) = apertureGapIndicators(foundIdx(fluxLogical));
    
end % loop over iApertureType


% detrend all time series in fauxTargetDataStruct quarter by quarter
restoreMeanFlag = true;
detrendedTimeSeries = ...
    correct_systematic_error_for_all_target_tables(conditionedAncillaryDataArray,...
                                                    fauxTargetDataStruct, ...
                                                    detrendParamStruct.ancillaryDesignMatrixConfigurationStruct, ...
                                                    detrendParamStruct.pdcConfigurationStruct,...
                                                    detrendParamStruct.saturationSegmentConfigurationStruct,...
                                                    detrendParamStruct.gapFillConfigurationStruct, ...
                                                    restoreMeanFlag, ...
                                                    dataAnomalyIndicators);

% attach keplerId field needed for quarter stitching
% use same target keplerId for all centroid time series
for iTimeseries = 1:length(detrendedTimeSeries)
    detrendedTimeSeries(iTimeseries).keplerId = keplerId;
end
                                                
% fill gaps within the quarter but leave the long gaps at the end of the quarters (quarterly rolls)
% this gapping scheme of long gaps between quarters and no gaps within quarters is needed for the quarter stitching routine
quarterIdx = unique(quarters);
gaps = [detrendedTimeSeries.gapIndicators];
fillIndicators = false(size(gaps));

for iQuarter = rowvec(quarterIdx)     
    for iApertureType = 1:2
        if( ~all(gaps(quarters==iQuarter,iApertureType)) )
            
            % find first and last ungapped cadences
            firstUngappedIndex = find(quarters==iQuarter, 1 );
            lastUngappedIndex = find(quarters==iQuarter, 1, 'last' );

            if ~isequal(iQuarter,quarterIdx(1))
                while( gaps(firstUngappedIndex,iApertureType) )
                    firstUngappedIndex = firstUngappedIndex + 1;
                end
            end

            if ~isequal(iQuarter,quarterIdx(end))    
                while( gaps(lastUngappedIndex,iApertureType) )
                    lastUngappedIndex = lastUngappedIndex - 1;
                end
            end

            % fill gaps between ungapped data endpoints
            apertureTimeSeries.values        = detrendedTimeSeries(iApertureType).values(firstUngappedIndex:lastUngappedIndex);
            apertureTimeSeries.uncertainties = detrendedTimeSeries(iApertureType).uncertainties(firstUngappedIndex:lastUngappedIndex);
            apertureTimeSeries.gapIndicators = detrendedTimeSeries(iApertureType).gapIndicators(firstUngappedIndex:lastUngappedIndex);
            fillIndicators(firstUngappedIndex:lastUngappedIndex,iApertureType) = apertureTimeSeries.gapIndicators;
            
            % Just need to do simple interpolation since TPS fills all gaps
            % and re-fills all filled cadences.  So just do what PDC does.
            cadenceTimes.midTimestamps = dvDataObject.dvCadenceTimes.midTimestamps(firstUngappedIndex:lastUngappedIndex);
            cadenceTimes.gapIndicators = apertureTimeSeries.gapIndicators;
            apertureTimeSeries = pdc_fill_gaps(apertureTimeSeries, cadenceTimes);
            
            % copy filled values and set intra-quarter gaps to zeros
            detrendedTimeSeries(iApertureType).values(firstUngappedIndex:lastUngappedIndex) = apertureTimeSeries.values;
            detrendedTimeSeries(iApertureType).gapIndicators(firstUngappedIndex:lastUngappedIndex) = false(size(apertureTimeSeries.gapIndicators));           
        end
    end
end

for iApertureType = 1:2
    % copy the fillIndices in for TPS gap filling and astro event
    % identification - TPS now re-fills all filled cadences
    detrendedTimeSeries(iApertureType).fillIndices = find(fillIndicators(:,iApertureType));
end

% call quarter stitching w/o median normalization (but with median subtraction)
% !!!!! Set medianNormalizationFlag to true -- then quarter-stitcher returns a time series that is 
% normalized by median and then the overall median is subtracted.
medianNormalizationFlag = true;
[detrendedTimeSeries, ~] = perform_quarter_stitching( dvDataObject, detrendedTimeSeries, medianNormalizationFlag ) ;

% restore original gap indicators
% make value and uncertainty zero in gaps
% make filled indices empty
values = [detrendedTimeSeries.values];
values(gaps) = 0;
valuesCellArray = num2cell(values,1);
[detrendedTimeSeries.values] = deal(valuesCellArray{:});

uncertainties = [detrendedTimeSeries.uncertainties];
uncertainties(gaps) = 0;
uncertaintiesCellArray = num2cell(uncertainties,1);
[detrendedTimeSeries.uncertainties] = deal(uncertaintiesCellArray{:});

gapCellArray = num2cell(gaps,1);
[detrendedTimeSeries.gapIndicators] = deal(gapCellArray{:});
[detrendedTimeSeries.fillIndices] = deal([]);

% save each detrended aperture flux timeseries into the detrendedApertureFluxTimeSeries struct
for iApertureType = 1:2
        
    % Re-use this code for core and halo aperture fluxes:
    % core == prf.ra, halo == prf.dec
    switch iApertureType
        case 1
            typeString = 'prf';
            dimString  = 'ra';
        case 2
            typeString = 'prf';
            dimString  = 'dec';
    end    
    detrendedApertureFluxTimeSeries.(typeString).(dimString) = detrendedTimeSeries(iApertureType);
end
