function [trapezoidalModelFitData] = perform_flux_time_series_smoothing(dvDataObject, dvResultsStruct, thresholdCrossingEvent, iTarget, iPlanet)

% Set detrend parameters
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

detrendParameters.gapThreshold                = dvDataObject.trapezoidalFitConfigurationStruct.gapThreshold;
detrendParameters.defaultSmoothingParameter   = dvDataObject.trapezoidalFitConfigurationStruct.defaultSmoothingParameter;
detrendParameters.medianFilterLength          = dvDataObject.trapezoidalFitConfigurationStruct.medianFilterLength;
detrendParameters.filterCircularShift         = dvDataObject.trapezoidalFitConfigurationStruct.filterCircularShift;
detrendParameters.snrThreshold                = dvDataObject.trapezoidalFitConfigurationStruct.snrThreshold;


% Get flux data, gap indicators, etc.

fluxValues                      = dvDataObject.targetStruct(iTarget).correctedFluxTimeSeries.values;
fluxUncertainties               = dvDataObject.targetStruct(iTarget).correctedFluxTimeSeries.uncertainties;
midTimestampsBkjd               = dvDataObject.barycentricCadenceTimes(iTarget).midTimestamps;
    
gapIndicators1                  = dvDataObject.targetStruct(iTarget).correctedFluxTimeSeries.gapIndicators;
filledIndices1                  = dvDataObject.targetStruct(iTarget).correctedFluxTimeSeries.filledIndices;
outliers1                       = dvDataObject.targetStruct(iTarget).outliers.indices;
gapIndicators1(filledIndices1)  = true;
gapIndicators1(outliers1)       = true;

gapIndicators2                  = dvResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(iPlanet).planetCandidate.initialFluxTimeSeries.gapIndicators;
filledInices2                   = dvResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(iPlanet).planetCandidate.initialFluxTimeSeries.filledIndices;
gapIndicators2(filledInices2)   = true;
gapIndicators                   = gapIndicators1 | gapIndicators2 | ~isfinite(fluxValues) | ~isfinite(fluxUncertainties) | ~isfinite(midTimestampsBkjd) | ...
                                    fluxUncertainties <= 0.0 | midTimestampsBkjd < 1;

% Convert transit epoch from MJD to BKJD 

[minDiffTimestampsToEpochDays, minIndex] = min( abs( dvDataObject.dvCadenceTimes.midTimestamps - thresholdCrossingEvent.epochMjd ) );
display( ' ' );
display( sprintf( 'Minimum difference of MJD timestamps to TCE epochMjd:  %f  minutes', minDiffTimestampsToEpochDays*60*24 ) );
display( ' ' );

medianDiffBkjdToKjd  = median( midTimestampsBkjd - ( dvDataObject.dvCadenceTimes.midTimestamps - kjd_offset_from_mjd) );
if ( minDiffTimestampsToEpochDays > 1.5*30/60/24 )                          % threshold: 45 minutes or ~ 1.5 cadences
    display( sprintf( 'Minimum difference Too Big getting crude estimate' ) );
    display( ' ' );
    epochBkjd = thresholdCrossingEvent.epochMjd - kjd_offset_from_mjd + medianDiffBkjdToKjd;
else
    epochBkjd = midTimestampsBkjd(minIndex);
end


% Set trapezoidalModelFitData structure

trapezoidalModelFitData.keplerId                                     = dvDataObject.targetStruct(iTarget).keplerId;
trapezoidalModelFitData.iTarget                                      = iTarget;
trapezoidalModelFitData.iPlanet                                      = iPlanet;
trapezoidalModelFitData.detrendParameters                            = detrendParameters;
trapezoidalModelFitData.safeToMinimizeFlag                           = false;

trapezoidalModelFitData.detrendInputs.midTimestampsBkjd              = midTimestampsBkjd;
trapezoidalModelFitData.detrendInputs.fluxValues                     = fluxValues;
trapezoidalModelFitData.detrendInputs.gapIndicators                  = gapIndicators;

trapezoidalModelFitData.thresholdCrossingEvent.medianDiffBkjdToKjd   = medianDiffBkjdToKjd;
trapezoidalModelFitData.thresholdCrossingEvent.epochBkjd             = epochBkjd;
trapezoidalModelFitData.thresholdCrossingEvent.orbitalPeriodDays     = thresholdCrossingEvent.orbitalPeriod;
trapezoidalModelFitData.thresholdCrossingEvent.transitDurationHours  = thresholdCrossingEvent.trialTransitPulseDuration;
trapezoidalModelFitData.thresholdCrossingEvent.maxMultipleEventSigma = thresholdCrossingEvent.maxMultipleEventSigma;             

availableQuarters                                                    = sort( unique( dvDataObject.dvCadenceTimes.quarters(~gapIndicators) ) );
nQuarters                                                            = length(availableQuarters);
trapezoidalModelFitData.quarters.quarterNumber                       = availableQuarters(:);
trapezoidalModelFitData.quarters.transitsFlag                        = false(nQuarters, 1);
trapezoidalModelFitData.quarters.smoothingParameter                  = zeros(nQuarters, 1);
trapezoidalModelFitData.quarters.phaseOffset                         = zeros(nQuarters, 1);
trapezoidalModelFitData.quarters.snrEstimate                         = zeros(nQuarters, 1);
trapezoidalModelFitData.quarters.minDepthPpm                         = zeros(nQuarters, 1);
trapezoidalModelFitData.quarters.epochBkjd                           = zeros(nQuarters, 1);
trapezoidalModelFitData.quarters.transitDurationHours                = zeros(nQuarters, 1);
trapezoidalModelFitData.quarters.stdSigma                            = zeros(nQuarters, 1);
trapezoidalModelFitData.quarters.madSigma                            = zeros(nQuarters, 1);
trapezoidalModelFitData.quarters.gaps                                = repmat(struct('startCadence', [], 'endCadence', []), nQuarters, 1);

[trapezoidalModelFitData] = detrend_with_in_transit_data_ungapped(dvDataObject, trapezoidalModelFitData);

if iPlanet > 1
    
    jPlanet = 1;
    while ( jPlanet < (iPlanet-1) ) && ~dvResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(jPlanet).trapezoidalFit.fullConvergence
        jPlanet = jPlanet + 1;
    end
    
    if dvResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(jPlanet).trapezoidalFit.fullConvergence
        
        fileName = ['trapezoidalFit_target_' num2str(iTarget) '_planet_' num2str(jPlanet) '.mat'];
        if exist(fileName, 'file')
            
            load(fileName);
            trapezoidalModelFitData.quarters.gaps = trapezoidalModelFitDataSaved.quarters.gaps;
            
        else
            
            errorMessage = ['Cannot find trapezoidal model fit data file ' fileName];
            error('dv:performFluxTimeSeriesSmoothing:noTrapezoidalModelFitDataFile', errorMessage);
            
        end
        
    end
    
end
    
[trapezoidalModelFitData] = detrend_with_in_transit_data_gapped(dvDataObject, trapezoidalModelFitData);

if trapezoidalModelFitData.safeToMinimizeFlag
    
    [trapezoidalModelFitData] = detrend_with_in_transit_data_gapped_updated(dvDataObject, trapezoidalModelFitData);

    [trapezoidalModelFitData] = clip_outliers_for_trapezoidal_fit(dvDataObject, trapezoidalModelFitData);
    
end

return
