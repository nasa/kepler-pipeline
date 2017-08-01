function bootstrapInputStruct = generate_tps_bootstrap_input( ...
    waveletObject, tpsResult, tpsModuleParameters, bootstrapParameters, ...
    foldingParameterStruct, inTransitIndicator)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function bootstrapInputStruct = generate_tps_bootstrap_input(tpsResult, ...
%    tpsModuleParameters, foldingParametersStruct, inTransitIndicator)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Decription: This function constructs the MES distribution and estimates
% the threshold that gives an equivalent false alarm rate as that
% corresponding to a standard normal with threshold given by
% searchTransitThreshold
% 
%
% Inputs:
%
% Outputs:
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
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

% Create bootstrapInputStruct 
bootstrapInputStruct = struct( ...
    'targetNumber', -1, ...
    'keplerId', -1, ...
    'planetNumber', -1, ...
    'histogramBinWidth', -1, ...  
    'searchTransitThreshold', -1, ...
    'nullTailMinSigma', -1, ...
    'nullTailMaxSigma', -1, ...
    'searchPeriodStepControlFactor', -1, ...
    'minimumSearchPeriodInDays', -1, ...
    'maximumSearchPeriodInDays', -1, ...
    'maxDutyCycle', -1, ...
    'maxPeriodParameter', -1, ...
    'maxFoldingsInPeriodSearch', -1, ...
    'maxNumberBins', -1, ...
    'minSesInMesCount', -1, ...
    'orbitalPeriodInDays', -1, ...
    'epochInMjd', -1, ...
    'observedTransitCount', -1, ...
    'trialTransitDuration', -1, ...
    'singleEventStatistics', [], ...
    'deemphasizedNormalizationTimeSeries', [], ...
    'convolutionMethodEnabled', [], ...  
    'firstMidTimestamp', -1, ...
    'superResolutionFactor', -1, ...
    'cadenceDurationInMinutes', -1, ...
    'deemphasizeQuartersWithoutTransits', [], ...
    'quarters', [], ...
    'sesZeroCrossingWidthDays', -1, ...
    'sesZeroCrossingDensityFactor', -1, ...
    'nSesPeaksToRemove', -1, ...
    'sesPeakRemovalThreshold', -1, ...
    'sesPeakRemovalFloor', -1, ...
    'bootstrapResolutionFactor', -1, ...
    'dvFiguresRootDirectory', -1, ...
    'debugLevel', -1 );

% extract parameters from inputs
deemphasisWeightsOrig = tpsResult.deemphasisWeight;
usePolyFitTransitModel = tpsModuleParameters.usePolyFitTransitModel;
trialTransitPulseInHours = tpsResult.trialTransitPulseInHours;
trialTransitDurationInCadences = foldingParameterStruct.trialTransitDurationInCadences;
nCadences = length( inTransitIndicator );

% set weights to zero explicitly for in-transit cadences
deemphasisWeights = deemphasisWeightsOrig;
deemphasisWeights(inTransitIndicator) = 0;

% remove the transits and recompute the whitener and single event
% statistics to prevent the bootstrap from vetoing deep transits that leave
% residual in the SES
removeTrend = false;
removeTransits = true;
waveletObject = adjust_wavelet_object_for_transits( waveletObject, ...
    inTransitIndicator, removeTrend, removeTransits );

% get the cadenceDurationInMinutes from the waveletObject - This is
% computed by the same method as it is in DV for consistency
gapFillParametersStruct = get( waveletObject, 'gapFillParametersStruct' ) ;

% generate a superResolutionObject with superResolution = 1
scalingFilterCoeffts = get( waveletObject, 'h0' ) ;
superResolutionStruct = struct('superResolutionFactor', 1, ...
    'pulseDurationInCadences', trialTransitDurationInCadences, 'usePolyFitTransitModel', ...
    usePolyFitTransitModel ) ;
superResolutionObject = superResolutionClass( superResolutionStruct, scalingFilterCoeffts ) ;
superResolutionObject = set_statistics_time_series_shift_length( superResolutionObject) ;   

% add the updated waveletObject to the superResolutionObject
superResolutionObject = set_wavelet_object( superResolutionObject, waveletObject );

% compute the new single event statistics free from any residual associated
% with transits
[~, correlationTimeSeries, normalizationTimeSeries] =  ...
    set_hires_statistics_time_series( superResolutionObject, nCadences );

% build the singleEventStatistics
statisticSeries = struct( ...
    'values', zeros(nCadences,1), ...
    'gapIndicators', inTransitIndicator);

deemphasisSeries = struct( ...
    'values', deemphasisWeights );

singleEventStatistics = struct( ...
    'trialTransitPulseDuration', trialTransitPulseInHours, ...
    'correlationTimeSeries', statisticSeries, ...
    'normalizationTimeSeries', statisticSeries, ...
    'deemphasisWeights', deemphasisSeries);

singleEventStatistics.correlationTimeSeries.values = correlationTimeSeries;
singleEventStatistics.normalizationTimeSeries.values = normalizationTimeSeries;

% record everything in the input struct
bootstrapInputStruct.searchTransitThreshold              = tpsModuleParameters.bootstrapGaussianEquivalentThreshold;
bootstrapInputStruct.searchPeriodStepControlFactor       = tpsModuleParameters.searchPeriodStepControlFactor;
bootstrapInputStruct.minSesInMesCount                    = tpsModuleParameters.minSesInMesCount;
bootstrapInputStruct.superResolutionFactor               = tpsModuleParameters.superResolutionFactor;
bootstrapInputStruct.minimumSearchPeriodInDays           = tpsModuleParameters.minimumSearchPeriodInDays;
bootstrapInputStruct.maximumSearchPeriodInDays           = tpsModuleParameters.maximumSearchPeriodInDays;
bootstrapInputStruct.maxDutyCycle                        = tpsModuleParameters.maxDutyCycle;
bootstrapInputStruct.maxPeriodParameter                  = tpsModuleParameters.maxPeriodParameter;
bootstrapInputStruct.maxFoldingsInPeriodSearch           = tpsModuleParameters.maxFoldingsInPeriodSearch;
bootstrapInputStruct.cadenceDurationInMinutes            = gapFillParametersStruct.cadenceDurationInMinutes;
bootstrapInputStruct.orbitalPeriodInDays                 = tpsResult.detectedOrbitalPeriodInDays;
bootstrapInputStruct.epochInMjd                          = tpsResult.timeOfFirstTransitInMjd;
bootstrapInputStruct.trialTransitDuration                = trialTransitPulseInHours;
bootstrapInputStruct.firstMidTimestamp                   = foldingParameterStruct.cadence1Timestamp;
bootstrapInputStruct.quarters                            = foldingParameterStruct.quarters;
bootstrapInputStruct.deemphasizedNormalizationTimeSeries = normalizationTimeSeries .* deemphasisWeightsOrig;
bootstrapInputStruct.singleEventStatistics               = singleEventStatistics;
bootstrapInputStruct.convolutionMethodEnabled            = bootstrapParameters.convolutionMethodEnabled;
bootstrapInputStruct.histogramBinWidth                   = bootstrapParameters.histogramBinWidth;
bootstrapInputStruct.deemphasizeQuartersWithoutTransits  = bootstrapParameters.deemphasizeQuartersWithoutTransits;
bootstrapInputStruct.bootstrapMaxNumberBins              = bootstrapParameters.maxNumberBins;
bootstrapInputStruct.sesZeroCrossingWidthDays            = bootstrapParameters.sesZeroCrossingWidthDays;
bootstrapInputStruct.sesZeroCrossingDensityFactor        = bootstrapParameters.sesZeroCrossingDensityFactor;
bootstrapInputStruct.nSesPeaksToRemove                   = bootstrapParameters.nSesPeaksToRemove;
bootstrapInputStruct.sesPeakRemovalThreshold             = bootstrapParameters.sesPeakRemovalThreshold;
bootstrapInputStruct.sesPeakRemovalFloor                 = bootstrapParameters.sesPeakRemovalFloor;
bootstrapInputStruct.bootstrapResolutionFactor           = bootstrapParameters.bootstrapResolutionFactor;

return