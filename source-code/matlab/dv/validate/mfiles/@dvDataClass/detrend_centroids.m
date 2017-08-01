function [detrendedCentroidTimeSeries, originalCentroidTimeSeries] = detrend_centroids(dvDataObject,...
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
fcConstants = dvDataObject.fcConstants;
targetStruct = dvDataObject.targetStruct(iTarget);
    
% add some needed fields to the targetStruct
targetStruct.debugLevel = dvDataObject.dvConfigurationStruct.debugLevel;
targetStruct.targetIndex = iTarget;


% ~~~~~~~~~~~~~~~~~~ build motion polynomials array
% Apparently motion polynomials only exist for the cadences run in PA (e.g. NOT in the quarterly roll gaps)
% Need to fill out the struct array for all cadences in UOW
tempMotion = [dvDataObject.targetTableDataStruct.motionPolyStruct];
motionCadencenumbers = [tempMotion.cadence];
cadenceNumbers = dvDataObject.dvCadenceTimes.cadenceNumbers;

% pick off single struct element and set invalid
singleMotionStruct = tempMotion(1);
singleMotionStruct.cadence = 0;
singleMotionStruct.rowPolyStatus = 0;
singleMotionStruct.colPolyStatus = 0;

% allocate space for a full array of motion polynomials
motionPolynomials = repmat(singleMotionStruct,length(cadenceNumbers),1);

% find which cadences we have motion polys for
[motionLogical, foundIdx] = ismember(cadenceNumbers, motionCadencenumbers);

% copy motion polys into full structure
motionPolynomials(motionLogical) = tempMotion(foundIdx(motionLogical));
clear tempMotion singleMotionStruct motionCadencenumbers

% convert row and column centroids to ra and dec cetroids
disp('DV:CentroidTest:Convert centroids from row/column coordinates to ra/dec coordinates');
raDecCentroids = convert_row_col_centroids_to_ra_dec(targetStruct,...
                                                        motionPolynomials,...
                                                        fcConstants);


                                                    
% Setup 1x4 array of fauxTargetDataStruct to pass to correct_systematic_error
% as "target" flux data. Each target index gets populated with the row/column
% prf/fluxWeighted centroid time series in place of the flux time series. This
% way all four centroid time series for each target can be detrended in a
% single pass. Also save the original centroid time series as optional output.
% Note: fake targets are dim --> keplerMag == 20.                                                    
                                                    
                   
% set up inputs for call to correct systematic error                                                    
originalCentroidTimeSeries = raDecCentroids;
debugLevel = targetStruct.debugLevel;
keplerId = targetStruct.keplerId;

fauxTargetDataStruct = repmat(struct( ...
    'values', [], ...
    'uncertainties', [], ...
    'gapIndicators', [], ...
    'keplerMag', 20), 1, 4);

for iCentroidType = 1:4
    switch iCentroidType
        case 1
            tempTimeSeries = originalCentroidTimeSeries.prf.ra;            
        case 2
            tempTimeSeries = originalCentroidTimeSeries.prf.dec;
        case 3
            tempTimeSeries = originalCentroidTimeSeries.fluxWeighted.ra;
        case 4
            tempTimeSeries = originalCentroidTimeSeries.fluxWeighted.dec;
    end

    % populate the fauxTargetDataStruct "flux" position with the
    % centroid time series for this quarter
    fauxTargetDataStruct(iCentroidType).values = tempTimeSeries.values;
    fauxTargetDataStruct(iCentroidType).uncertainties = tempTimeSeries.uncertainties;
    fauxTargetDataStruct(iCentroidType).gapIndicators = tempTimeSeries.gapIndicators;
end

% remove harmonics from all centroid time series target table by target
% table prior to detrending. COMMENT OUT FOR NOW UNTIL HARMONIC
% IDENTIFICATION IS PERFORMED JOINTLY WITH SYSTEMATIC ERROR CORRECTION
% (POST-7.0). FOR NOW, HARMONICS WILL BE REMOVED BY QUARTER-STITCHER
% FOLLOWING SYSTEMATIC ERROR CORRECTION.
% coarsePdcConfigurationStruct = ...
%     detrendParamStruct.coarsePdcConfigurationStruct;
% cadenceTimes = coarsePdcConfigurationStruct.cadenceTimes;
% cadenceType = 'LONG';
% identifyAllTargetsAsVariable = true;
%
% for iCentroidType = 1:4
%
%     for iTable = 1:length(conditionedAncillaryDataArray)
%
%         ccdModule = conditionedAncillaryDataArray(iTable).ccdModule;
%         ccdOutput = conditionedAncillaryDataArray(iTable).ccdOutput;
%
%         startCadenceRelative = ...
%             conditionedAncillaryDataArray(iTable).startCadenceRelative;
%         endCadenceRelative = ...
%             conditionedAncillaryDataArray(iTable).endCadenceRelative;
%         cadenceRangeForTimeSeries = startCadenceRelative : endCadenceRelative;
%
%         coarsePdcConfigurationStruct.ccdModule = ccdModule;
%         coarsePdcConfigurationStruct.ccdOutput = ccdOutput;
%         coarsePdcConfigurationStruct.cadenceTimes = ...
%             trim_dv_cadence_times(cadenceTimes, cadenceRangeForTimeSeries);
%
%         [fauxTargetDataStructForTargetTable] = ...
%             extract_segment_for_target_table(fauxTargetDataStruct(iCentroidType), ...
%             cadenceRangeForTimeSeries);
%
%         [harmonicTimeSeries, fauxTargetDataStructForTargetTable] = ...
%             pdc_identify_and_remove_phase_shifting_harmonics_from_all_targets( ...
%             fauxTargetDataStructForTargetTable, coarsePdcConfigurationStruct, ...
%             cadenceType, identifyAllTargetsAsVariable);
%
%         cadenceRangeForTable = 1:length(cadenceRangeForTimeSeries);
%
%         [fauxTargetDataStruct(iCentroidType)] = ...
%             merge_segment_for_target_table(fauxTargetDataStructForTargetTable, ...
%             fauxTargetDataStruct(iCentroidType), cadenceRangeForTable, ...
%             cadenceRangeForTimeSeries);
%
%     end % for iTable
%
% end % for iCentroidType

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
    for iCentroidType = 1:4
        if( ~all(gaps(quarters==iQuarter,iCentroidType)) )
            
            % find first and last ungapped cadences
            firstUngappedIndex = find(quarters==iQuarter, 1 );
            lastUngappedIndex = find(quarters==iQuarter, 1, 'last' );

            if ~isequal(iQuarter,quarterIdx(1))
                while( gaps(firstUngappedIndex,iCentroidType) )
                    firstUngappedIndex = firstUngappedIndex + 1;
                end
            end

            if ~isequal(iQuarter,quarterIdx(end))    
                while( gaps(lastUngappedIndex,iCentroidType) )
                    lastUngappedIndex = lastUngappedIndex - 1;
                end
            end

            % fill gaps between ungapped data endpoints
            tempTimeSeries.values        = detrendedTimeSeries(iCentroidType).values(firstUngappedIndex:lastUngappedIndex);
            tempTimeSeries.uncertainties = detrendedTimeSeries(iCentroidType).uncertainties(firstUngappedIndex:lastUngappedIndex);
            tempTimeSeries.gapIndicators = detrendedTimeSeries(iCentroidType).gapIndicators(firstUngappedIndex:lastUngappedIndex);
            fillIndicators(firstUngappedIndex:lastUngappedIndex,iCentroidType) = tempTimeSeries.gapIndicators;
            
            % Just need to do simple interpolation since TPS fills all gaps
            % and re-fills all filled cadences.  So just do what PDC does.
            cadenceTimes.midTimestamps = dvDataObject.dvCadenceTimes.midTimestamps(firstUngappedIndex:lastUngappedIndex);
            cadenceTimes.gapIndicators = tempTimeSeries.gapIndicators;
            tempTimeSeries = pdc_fill_gaps(tempTimeSeries, cadenceTimes);
            
            % copy filled values and set intra-quarter gaps to zeros
            detrendedTimeSeries(iCentroidType).values(firstUngappedIndex:lastUngappedIndex) = tempTimeSeries.values;
            detrendedTimeSeries(iCentroidType).gapIndicators(firstUngappedIndex:lastUngappedIndex) = false(size(tempTimeSeries.gapIndicators));           
        end
    end
end

for iCentroidType = 1:4
    % copy the fillIndices in for TPS gap filling and astro event
    % identification - TPS now re-fills all filled cadences
    detrendedTimeSeries(iCentroidType).fillIndices = find(fillIndicators(:,iCentroidType));
end

% call quarter stitching w/o median normalization (but with median subtraction)
[detrendedTimeSeries, segmentInfo] = perform_quarter_stitching( dvDataObject, detrendedTimeSeries, false ) ;

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

% save into the detrended centroid timeseries struct
% restore median value to each timeseries
for iCentroidType = 1:4
    
    % use average of medians over segments as new median if a list of medians exists
    medians = [segmentInfo(iCentroidType).segment.medianValue];
    if( ~isempty(medians) )
        newMedian = mean([segmentInfo(iCentroidType).segment.medianValue]);
        detrendedTimeSeries(iCentroidType) = add_bias_to_timeseries( detrendedTimeSeries(iCentroidType), newMedian );
    end
    
    switch iCentroidType
        case 1
            typeString = 'prf';
            dimString  = 'ra';
        case 2
            typeString = 'prf';
            dimString  = 'dec';
        case 3
            typeString = 'fluxWeighted';
            dimString  = 'ra';
        case 4
            typeString = 'fluxWeighted';
            dimString  = 'dec';
    end    
    detrendedCentroidTimeSeries.(typeString).(dimString) = detrendedTimeSeries(iCentroidType);
end




