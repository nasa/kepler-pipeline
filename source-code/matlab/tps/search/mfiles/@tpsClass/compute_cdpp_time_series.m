function [tpsResults, alerts, whitenedFluxAllTargets] = ...
    compute_cdpp_time_series(tpsObject, harmonicTimeSeriesAllTargets, ...
    fittedTrendAllTargets, customTransitModel, suppressTransitsInWhitener, ...
    indexOfSesAdded)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [tpsResults, alerts, extendedFlux] = compute_cdpp_time_series(tpsObject)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Background:
% Combined Differential Photometric Precision (CDPP) is the effective noise
% in a given time interval relevant to the duration of a transit and is a
% measure of how easy it would be to detect transits of assumed duration
% and depth. It is measured as the ratio of an assumed or reference transit
% signal strength 'sref' in parts per million (ppm) to the Signal-to-Noise
% Ratio (SNR) of this transit under consideration. The reference transit
% signal strength 'sref' is defined as the fractional reduction in light
% flux (measured in ppm) observed from the star as a result of a transit.
% For the transit of an Earth like planet around a Sun like star, the
% change in brightness 'sref' resulting from the transit is given by the
% ratio of the area of the transiting planet to the area of the star and is
% given by (area of Earth)/(area of Sun) = (6378 Km^2)/(696265 Km^2) =
% 84 ppm. To compute the SNR of such a transit contained in a noisy flux
% time series, we need to estimate the variance of the non-white and
% non-stationary noise as a function of time. This necessitates an explicit
% time-frequency decomposition of the data which is easily accomplished by
% a wavelet based approach. Thus the SNR time series is obtained in the
% wavelet domain as the scaled ratio of si^2[n]/sigmai^2[n], where si[n] is
% the overcomplete wavelet expansion series at the ith scale for the
% transit signal 's' constructed as a periodic transit pulse train and
% 'sigmai' is the moving standard deviation series estimated from the
% wavelet expansion of the flux time series 'x'. Obtaining the SNR series
% in the wavelet domain is equivalent to obtaining the SNR series in the
% time domain.
%
% Now the CDPP time series for a reference rectangular transit signal 's'
% with a fractional depth of 'd' parts per million with respect to the flux
% time series can be written as 'd' ppm/SNR[n].
% In the above equations, the transit signal 's' and the flux time series
% 'x' are in the same units and so are the wavelet series 'si[n]' and
% 'sigmai[n]'. The calculation of the CDPP series is not dependent upon the
% assumed transit signal depth.
%
% References:
%  [1]. J. Jenkins, Algorithm Theoretical Basis Document for the Science
%       Operations Center, KSOC-21008-001, July 2004.
%  [2]. KADN-26063 Combined Differential Photometric Precision (CDPP)
%       Calculation
%  [3]. KADN-26062 Matched Filter
%  [4]. KADN-26061 Wavelet Transform
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

%__________________________________________________________________________
% Input:  An object of tpsClass 'tpsObject' with the following fields:
%__________________________________________________________________________
%
% tpsObject contains the following fields:
%
%     tpsModuleParameters: [1x1 struct]
%       gapFillParameters: [1x1 struct]
%              tpsTargets: [1x1775 struct]
%           rollTimeModel: [1x1 struct]
%            cadenceTimes: [1x1 struct]
%..........................................................................
%
%  tpsObject.tpsModuleParameters contains the following fields:
%
%                             debugLevel: 0
%       requiredTrialTransitPulseInHours: [3x1 double]
%          searchPeriodStepControlFactor: 0.9000
%         varianceWindowLengthMultiplier: 5
%              minimumSearchPeriodInDays: 1
%                 searchTransitThreshold: 7.1000
%                constrainedPolyMaxOrder: 10
%              maximumSearchPeriodInDays: 365
%                          waveletFamily: 'daub'
%                    waveletFilterLength: 12
%                         tpsLiteEnabled: 0
%                  superResolutionFactor: 3
%        adXFactorForSimpleMatchedFilter: 20
%   deemphasizePeriodAfterSafeModeInDays: 2
%  deemphasizePeriodAfterTweakInCadences: 8
%        edgeDetrendingSignificanceValue: 0.0100
%       requiredTrialTransitPulseInHours: [3x1 double]
%            minTrialTransitPulseInHours: 1.5 (-1 to disable algorithmic D)
%            maxTrialTransitPulseInHours: 15  (-1 to disable algorithmic D)
%      searchTrialTransitDurationStepControlFactor: 0.8000
%               maxFoldingsInPeriodSearch: 10
%                 performQuarterStitching: 1
%                robustStatisticThreshold: 7.1
%   robustStatisticWindowLengthMultiplier: 3
%            robustWeightGappingThreshold: 0.5
%     robustStatisticConvergenceTolerance: 0.01
%
%..........................................................................
%
%  tpsObject.gapFillParameters contains the following fields:
%
%                              madXFactor: 10
%          maxGiantTransitDurationInHours: 72
%                     maxDetrendPolyOrder: 25
%                         maxArOrderLimit: 25
%             maxCorrelationWindowXFactor: 5
%     gapFillModeIsAddBackPredictionError: 1
%                           waveletFamily: 'daub'
%                     waveletFilterLength: 12
%   giantTransitPolyFitChunkLengthInHours: 72
%
%..........................................................................
% tpsObject.harmonicsIdentificationParameters
%
%                medianWindowLength: 21
%         movingAverageWindowLength: 47
%     chiSquareProbabilityThreshold: 0.99998998641967
%
%..........................................................................
%
%  tpsObject.tpsTargets is an array of structures with the following fields:
%
% tpsObject.tpsTargets(1)
%           keplerId: 757076
%             kepMag: 11.6780
%     crowdingMetric: 0.9592
%        validKepMag: 0
%          fluxValue: [1639x1 double]
%        uncertainty: [1639x1 double]
%         gapIndices: []
%        fillIndices: [13x1 double]
%     outlierIndices: []
%
%..........................................................................
%
%  tpsObject.rollTimeModel contains the following fields:
%
%                  mjds: [16x1 double]
%               seasons: [16x1 double]
%           rollOffsets: [16x1 double]
%          fovCenterRas: [16x1 double]
% fovCenterDeclinations: [16x1 double]
%        fovCenterRolls: [16x1 double]
%
%..........................................................................
%
%  tpsObject.cadenceTimes contains the following fields:
%
%     startTimestamps: [1639x1 double]
%       midTimestamps: [1639x1 double]
%       endTimestamps: [1639x1 double]
%       gapIndicators: [1639x1 logical]
%      requantEnabled: [1639x1 logical]
%      cadenceNumbers: [1639x1 double]
%           isSefiAcc: [1639x1 logical]
%           isSefiCad: [1639x1 logical]
%            isLdeOos: [1639x1 logical]
%           isFinePnt: [1639x1 logical]
%          isMmntmDmp: [1639x1 logical]
%          isLdeParEr: [1639x1 logical]
%           isScrcErr: [1639x1 logical]
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

% extract needed information from inputs
tpsModuleParameters     = tpsObject.tpsModuleParameters;
gapFillParametersStruct = tpsObject.gapFillParameters;
tpsTargets              = tpsObject.tpsTargets ;
cadenceTimes            = tpsObject.cadenceTimes;
randStreams             = tpsObject.randStreams ;
debugLevel                      = tpsModuleParameters.debugLevel ;
superResolutionFactor           = tpsModuleParameters.superResolutionFactor;
cadencesPerHour                 = tpsModuleParameters.cadencesPerHour;
varianceWindowLengthMultiplier  = tpsModuleParameters.varianceWindowLengthMultiplier;
tpsLiteEnabled                  = tpsModuleParameters.tpsLiteEnabled ;
usePolyFitTransitModel          = tpsModuleParameters.usePolyFitTransitModel ;
positiveOutlierHaircutEnabled   = tpsModuleParameters.positiveOutlierHaircutEnabled ;
positiveOutlierHaircutThreshold = tpsModuleParameters.positiveOutlierHaircutThreshold;
noiseEstimationByQuarterEnabled = tpsModuleParameters.noiseEstimationByQuarterEnabled;
deemphasisParameter = cadenceTimes.deemphasisParameter;
quarters            = cadenceTimes.quarters;
removeEclipsingBinariesOnList = gapFillParametersStruct.removeEclipsingBinariesOnList ;

% always use outlier-free flux when computing whitening coefficients
useOutlierFreeFlux = true ;

% display progress every 10% or so
displayProgressInterval = 0.1 ; 

% if there is a custom model in the inputs, then override the other models
if exist( 'customTransitModel', 'var' ) && ~isempty( customTransitModel )
    useCustomTransitModel = true;
    usePolyFitTransitModel = false;
else
    useCustomTransitModel = false;
    customTransitModel = [];
end

% set defaults for optional input suppressTransitsInWhitener
if ~exist('suppressTransitsInWhitener','var') || isempty(suppressTransitsInWhitener)
    suppressTransitsInWhitener = false;
    indexOfSesAdded = [];
end

% if we are suppressing the effect of the transits on the whitener then we
% just have an inTransitIndicator
if ( exist('suppressTransitsInWhitener','var') && suppressTransitsInWhitener==true ) ...
        && ( ~exist('indexOfSesAdded','var') || isempty(indexOfSesAdded) )
    error('compute_cdpp_time_sereis:noIndexOfSesAdded', ...
        'compute_cdpp_time_series: need indexOfSesAdded when suppressTransitsInWhitener == true!' ) ;
end
    
% determine the number of targets and flux length
[nCadences, nStars] = size(cat(2, tpsObject.tpsTargets.fluxValue));

% initialize results
alerts = []; 
whitenedFluxAllTargets = zeros( nCadences, nStars ) ;

% get the scaling filter coefficients
if (strcmp(tpsModuleParameters.waveletFamily, 'daub'))
    scalingFilterCoeffts = daubechies_low_pass_scaling_filter(tpsModuleParameters.waveletFilterLength);
end

% compute the space of transit pulses to search over
trialTransitPulseDurationsInHours = compute_trial_transit_durations(tpsModuleParameters);
    
%initialize Output Struct
tpsResults = initialize_tps_results_struct( tpsObject,length(trialTransitPulseDurationsInHours) ) ;

% set of progress reporting
nCallsTotal = nStars * length(trialTransitPulseDurationsInHours) ;
nCallsProgress = nCallsTotal * displayProgressInterval ;
progressReports = nCallsProgress:nCallsProgress:nCallsTotal ;
progressReports = unique(floor(progressReports)) ;

% initialize loop variables
iProgress = 0 ;
iOutputResultCounter = 0;
tic

% set up the superResolutionObject
superResolutionStruct = struct('superResolutionFactor', superResolutionFactor, ...
    'pulseDurationInCadences', [], 'usePolyFitTransitModel', usePolyFitTransitModel, ...
    'useCustomTransitModel', useCustomTransitModel) ;
superResolutionObject = superResolutionClass( superResolutionStruct, scalingFilterCoeffts ) ;

for jStar = 1:nStars    
    
    % initialize rand seed and outlier indices for each target
    randStreams.set_default( tpsTargets(jStar).keplerId ) ;
    cumulativePositiveOutlierIndices = [] ;
    
    % get the target specific data
    fluxTimeSeries = tpsTargets(jStar).fluxValue ;
    outlierIndicators = tpsTargets(jStar).outlierIndicators ;
    outlierFillValues = tpsTargets(jStar).outlierFillValues ;
    fillIndices = tpsTargets(jStar).fillIndices ;
    cadenceQuarterLabels = get_intra_quarter_cadence_labels( quarters, fillIndices );
    
    if debugLevel >= 0
       disp(['    Computing CDPP time series for Kepler ID ', num2str(tpsTargets(jStar).keplerId), ' ...'] );
    end
    
    % compute CDPP for each star for each trial transit duration
    for kPulse = 1: length(trialTransitPulseDurationsInHours)
      
      needToIterateWhitenedFlux = true ;
      nOutlierLoops = 0 ;
        
      iProgress = iProgress + 1 ;
      if ( ismember( iProgress, progressReports ) && debugLevel >= 0 )
          disp( [ '        CDPP calculation:  starting loop iteration number ', num2str(iProgress), ...
              ' out of ', num2str(nCallsTotal),' total loop iterations' ] ) ;
          pause(1) ;
      end
        
      while needToIterateWhitenedFlux
        % get the pulse width
        if useCustomTransitModel
            trialTransitPulseWidth = cadencesPerHour*trialTransitPulseDurationsInHours(kPulse);
        else
            trialTransitPulseWidth = round(cadencesPerHour*trialTransitPulseDurationsInHours(kPulse));  % cadencesPerHour is not an integer
        end
        
        % compute the base window size for noise estimation
        varianceEstimationWindowLength = floor(trialTransitPulseWidth * varianceWindowLengthMultiplier);
        
        % construct the waveletObject for this flux time series and pulse duration
        waveletObject = waveletClass( scalingFilterCoeffts ) ;
        
        % set the outlier vectors
        waveletObject = set_outlier_vectors( waveletObject, outlierIndicators, ...
            outlierFillValues, gapFillParametersStruct, fittedTrendAllTargets(:,jStar) ) ;
        
        % set the flux in the object
        waveletObject = set_extended_flux( waveletObject, fluxTimeSeries, ...
            noiseEstimationByQuarterEnabled, cadenceQuarterLabels ) ;
        
        % add pulse duration, trial pulse, and shifts in the superResolutionObject
        superResolutionObject = set_pulse_duration( superResolutionObject, trialTransitPulseWidth ) ;
        superResolutionObject = set_trial_transit_pulse( superResolutionObject, customTransitModel ) ;
        superResolutionObject = set_statistics_time_series_shift_length( superResolutionObject ) ;
        
        % set the outliers, compute the whitening coefficients, and set the
        % waveletObject into the superResolutionObject
        if ~suppressTransitsInWhitener
            % not suppressing transits so compute the whitening coefficients
            waveletObject = set_whitening_coefficients( waveletObject, ...
                varianceEstimationWindowLength, useOutlierFreeFlux ) ;  
            
            % add the waveletObject to the superResolutionObject
            superResolutionObject = set_wavelet_object( superResolutionObject, waveletObject ) ;
        else
            % suppressing transits in the whitener
            transitModel = generate_trial_transit_pulse_train( superResolutionObject,  ...
                indexOfSesAdded, nCadences ) ;

            % generate the padded in-transit cadence indicator
            nPadCadences = min( ceil(trialTransitPulseWidth * 0.5), 4 ) ;
            inTransitIndicator = generate_padded_transit_indicator( transitModel, nPadCadences );
            
            % get the fill values for the in-transit cadences
            waveletObject = augment_outlier_vectors( waveletObject, ...
                inTransitIndicator, [] );
            
            % compute the whitening coefficients
            waveletObject = set_whitening_coefficients( waveletObject, ...
                varianceEstimationWindowLength, useOutlierFreeFlux ) ;
            
            % update the fitted trend
            fittedTrendAllTargets(:,jStar) = get( waveletObject, 'fittedTrend' ) ;
            
            % add the waveletObject to the superResolutionObject
            superResolutionObject = set_wavelet_object( superResolutionObject, waveletObject ) ;
        end
        
        % compute whitened flux just once and identify positive outliers
        if isequal(kPulse,1)
            whitenedFlux = apply_whitening_to_time_series( waveletObject ) ;    
            positiveOutlierIndices = identify_positive_outliers( whitenedFlux, ...
                positiveOutlierHaircutThreshold, fluxTimeSeries ) ;
            positiveOutlierIndices( ismember( positiveOutlierIndices, ...
                cumulativePositiveOutlierIndices ) ) = [] ;
        end
        
        % get fill values for positive outliers if there are any
        if ~isempty( positiveOutlierIndices ) && positiveOutlierHaircutEnabled
            nOutlierLoops = nOutlierLoops + 1 ;
            cumulativePositiveOutlierIndices = unique([cumulativePositiveOutlierIndices ; ...
                positiveOutlierIndices]) ;
            fillIndicators = false(nCadences,1) ;
            fillIndicators(positiveOutlierIndices) = true ;
            fluxTimeSeries = fill_short_gaps( fluxTimeSeries, ...
              fillIndicators, find(outlierIndicators), 0, ...
              gapFillParametersStruct, [], fittedTrendAllTargets(:,jStar) ) ;
        else
            needToIterateWhitenedFlux = false ;
            if nOutlierLoops > 0
                disp(['           Haircut:  removed ',...
                    num2str(length(cumulativePositiveOutlierIndices)), ...
                    ' outlier cadences in ', num2str(nOutlierLoops),' iterations']) ;
            end
        end
        
      end 
        
        % compute hi-res time series
        [superResolutionObject, correlationTimeSeries, normalizationTimeSeries] =  ...
            set_hires_statistics_time_series( superResolutionObject, nCadences ) ;
        
        % extract the hiRes time series for storage in the results
        correlationTimeSeriesHiRes = get( superResolutionObject, 'correlationTimeSeriesHiRes' ) ;
        normalizationTimeSeriesHiRes = get( superResolutionObject, 'normalizationTimeSeriesHiRes' ) ;
        
        % compute the CDPP and SES
        cdppTimeSeries = 1e6./normalizationTimeSeries; % in parts per million
        singleEventStatistics = correlationTimeSeriesHiRes./normalizationTimeSeriesHiRes;
        
        % if we did the noise estimation by quarter then the inter-quarter
        % cadence values are not valid
        if noiseEstimationByQuarterEnabled
            cdppTimeSeries(cadenceQuarterLabels == -1) = 0;
            if superResolutionFactor > 1
                cadenceQuarterLabelsSuperResolution = repmat( cadenceQuarterLabels,1, superResolutionFactor ) ;
                cadenceQuarterLabelsSuperResolution = cadenceQuarterLabelsSuperResolution' ;
                cadenceQuarterLabelsSuperResolution = cadenceQuarterLabelsSuperResolution(:);
            else
                cadenceQuarterLabelsSuperResolution = cadenceQuarterLabels;
            end
            singleEventStatistics = singleEventStatistics(cadenceQuarterLabelsSuperResolution ~= -1);
        end
            
        % index of result
        iOutputResultCounter = (kPulse-1)*nStars + jStar;
        
        % de-emphasize (zero out) the cadences/super resolution cadences
        % correponding to gapIndices, filled indices, outlier indices as
        % these represent non-existent data
        % de-emphasize (for now zero out) specified period around safe
        % modes and attitude tweaks before folding detection statistic time
        % series in order to reduce the number of false positives        
        [deemphasisWeightSuperResolution, deemphasisWeight] = initialize_deemphasis_weights( ...
            tpsTargets(jStar), deemphasisParameter, tpsModuleParameters, gapFillParametersStruct, ...
            cumulativePositiveOutlierIndices, [], []) ;
  
        % copy results to the tps struct
        tpsResults(iOutputResultCounter).keplerId = tpsObject.tpsTargets(jStar).keplerId;
        tpsResults(iOutputResultCounter).trialTransitPulseInHours = trialTransitPulseDurationsInHours(kPulse);
        tpsResults(iOutputResultCounter).maxSingleEventStatistic = max(singleEventStatistics);
        tpsResults(iOutputResultCounter).minSingleEventStatistic = min(singleEventStatistics);
        tpsResults(iOutputResultCounter).meanSingleEventStatistic = mean(singleEventStatistics);
        tpsResults(iOutputResultCounter).cdppTimeSeries = cdppTimeSeries;
        tpsResults(iOutputResultCounter).correlationTimeSeries =  correlationTimeSeries;
        tpsResults(iOutputResultCounter).normalizationTimeSeries =  normalizationTimeSeries;
        tpsResults(iOutputResultCounter).correlationTimeSeriesHiRes =  correlationTimeSeriesHiRes;
        tpsResults(iOutputResultCounter).normalizationTimeSeriesHiRes =  normalizationTimeSeriesHiRes;
        
        % compute the RMS CDPP for cadences with > 50% weight
        rmsGapIndicator = deemphasisWeight < 0.5;
        doRobustRms = true;
        tpsResults(iOutputResultCounter).rmsCdpp =  compute_rms_value( cdppTimeSeries, rmsGapIndicator, doRobustRms );
        
        if ~tpsLiteEnabled
            tpsResults(iOutputResultCounter).waveletObject = waveletObject ;
            tpsResults(iOutputResultCounter).positiveOutlierIndices = cumulativePositiveOutlierIndices ;
            tpsResults(iOutputResultCounter).deemphasisWeightSuperResolution = deemphasisWeightSuperResolution ;
            tpsResults(iOutputResultCounter).deemphasisWeight = deemphasisWeight ;
        end
        clear waveletObject ;
        
        % check to see if target is an eclipsing binary
        if removeEclipsingBinariesOnList
            ebCatalog = load_eclipsing_binary_catalog() ;
            ebIndex = find(ebCatalog(:,1)==tpsObject.tpsTargets(jStar).keplerId,1) ;
            if ~isempty( ebIndex )
                tpsResults(iOutputResultCounter).isOnEclipsingBinaryList = true;
            end
        end
        
        % need to save the extracted harmonic time series but at the same
        % time don't need multiple copies under each trial transit; so
        % save under the first trial transit pulse results
        if( kPulse == 1)
            tpsResults(iOutputResultCounter).detrendedFluxTimeSeries =  ...
                fluxTimeSeries;
            whitenedFluxAllTargets(:,jStar) = whitenedFlux;
            
            if(~all(harmonicTimeSeriesAllTargets(:, jStar) == -1))
                tpsResults(iOutputResultCounter).harmonicTimeSeries =  ...
                    harmonicTimeSeriesAllTargets(:, jStar);
            end
        else
            tpsResults(iOutputResultCounter).harmonicTimeSeries = [];
            tpsResults(iOutputResultCounter).detrendedFluxTimeSeries = [] ;
        end
               
        tpsResults(iOutputResultCounter).matchedFilterUsed = false;
        
        % check for NaN or Inf and issue a warning
        nanPresent = any(isnan(correlationTimeSeries)) || any(isnan(normalizationTimeSeries)) || ...
            any(~isreal(cdppTimeSeries)) || any(isnan(cdppTimeSeries)) ;
        if( nanPresent )
            if debugLevel >= 0
              warning('TPS:computeCdppTimeSeries', ...
                ['compute_cdpp_time_series: Nan or Inf or Complex numbers detected in CDPP time series for target ' num2str(jStar) ' Kepler Id ' ...
                num2str(tpsObject.tpsTargets(jStar).keplerId) ' for trial transit pulse of ' num2str(trialTransitPulseDurationsInHours(kPulse))]);
            end
            
            % add alert
            alerts = add_alert(alerts, 'warning', ...
                ['Nan or Inf or Complex numbers detected in CDPP time series for target ' num2str(jStar) ' Kepler Id ' ...
                num2str(tpsObject.tpsTargets(jStar).keplerId) ' for trial transit pulse of ' num2str(trialTransitPulseDurationsInHours(kPulse))]);
            disp(alerts(end).message);
            
            % update the results if they are invalid
            tpsResults(iOutputResultCounter).isResultValid = false;
            tpsResults(iOutputResultCounter).maxSingleEventStatistic = -1;
            tpsResults(iOutputResultCounter).minSingleEventStatistic = -1;
            tpsResults(iOutputResultCounter).meanSingleEventStatistic = -1;
            tpsResults(iOutputResultCounter).cdppTimeSeries = -ones(nCadences,1);
            tpsResults(iOutputResultCounter).rmsCdpp = -1;
            tpsResults(iOutputResultCounter).correlationTimeSeries = -ones(nCadences,1);
            tpsResults(iOutputResultCounter).normalizationTimeSeries =  -ones(nCadences,1);
            tpsResults(iOutputResultCounter).correlationTimeSeriesHiRes = ...
                -ones(superResolutionFactor*nCadences,1);
            tpsResults(iOutputResultCounter).normalizationTimeSeriesHiRes = ...
                -ones(superResolutionFactor*nCadences,1);
            
            % check to see if target is an eclipsing binary  
            if removeEclipsingBinariesOnList
                ebCatalog = load_eclipsing_binary_catalog() ;
                ebIndex = find(ebCatalog(:,1)==tpsObject.tpsTargets(jStar).keplerId,1) ;
                if ~isempty( ebIndex )
                    tpsResults(iOutputResultCounter).isOnEclipsingBinaryList = true;
                end
            end
        end 
    end
end

tpsResults(iOutputResultCounter+1:end) = [];

timeTakenToComputeCdpp = toc;
if debugLevel >= 0
   fprintf('    ... computing CDPP for %d stars took %f seconds\n',  nStars, ...
       timeTakenToComputeCdpp);
end

randStreams.restore_default() ;

return

%=========================================================================================

% subfunction which identifies indices of cadences which are positive outliers

function positiveOutlierIndices = identify_positive_outliers( whitenedFlux, ...
    threshold, fluxTimeSeries )

  NUM_PAD_CADENCES = 10 ;  % just hard code for now
  MAX_N_CADENCES = 30 ;
  positiveOutlierIndices = [] ;
  
% for a start, the positive outliers absolutely must be above threshold

  aboveThreshold        = whitenedFlux >= threshold ;
  aboveThresholdIndices = find(aboveThreshold) ;
  aboveThresholdValues  = whitenedFlux(aboveThreshold) ;
  nCadences = length(aboveThresholdIndices) ;
  
  if ~isempty(aboveThresholdValues)
  
% a more complicated requirement is that the positive "outlier" not be in the wings of a
% whitened transit.  How do we determine that?  Start by finding the local minima, which
% are the local maxima of the inverse

      localMinima = local_max( -whitenedFlux ) ;
      localMinima = localMinima(:) ;
      localMinima = localMinima' ;
  
% eliminate local minima which are greater than zero

      localMinima(whitenedFlux(localMinima)>0) = [] ;
  
% Now we need to find the nearest local minimum upstream of each cadence, and downstream
% of each cadence.  To do this, start by making a matrix of each, which is nCadences x
% nMinima

      trueOutlier = false( nCadences, 1 ) ;
      
      for i=1:nCadences
          
% now find the distance from each cadence to each local minimum  

          distanceVector = localMinima - aboveThresholdIndices(i) ;
          
% use the sign to determine the upstream or downstream status of each minimum      

          upstreamMin = double( distanceVector <= 0 ) ;
          downstreamMin = double( distanceVector >= 0 ) ;
          absDistanceVector = abs(distanceVector) ;
          
% the nearest DOWNSTREAM minimum is the one for which the abs distance is minimum, AND
% which is downstream.  We can determine this by taking the abs distance and DIVIDING by
% the downstream matrix -- upstream minima will have a downstream value of zero, resulting
% in an abs distance / minimum indicator equal to inf          
          
          [~,nearestDownstreamMin] = min( absDistanceVector./downstreamMin ) ;
          [~,nearestUpstreamMin]   = min( absDistanceVector./upstreamMin ) ;
          
          upstreamMinValue   = whitenedFlux(localMinima(nearestUpstreamMin)) ;
          downstreamMinValue = whitenedFlux(localMinima(nearestDownstreamMin)) ;
          
% to be an outlier, the value of the outlier must be greater than the depth of the
% nearest upstream and nearest downstream local minima          
          
          if ~isempty( upstreamMinValue ) && ~isempty( downstreamMinValue )
              trueOutlier(i) = aboveThresholdValues(i) > -upstreamMinValue & ...
                  aboveThresholdValues(i) > -downstreamMinValue ;
          end
          
      end
      
      positiveOutlierIndices = aboveThresholdIndices( trueOutlier ) ;
      
  end
  
  
if ~isempty(positiveOutlierIndices)  
    % follow the outliers down to the floor in the flux to make
    % sure the whole spike is removed
    fluxDiff = [0;diff(fluxTimeSeries)];
    positiveOutlierChunks = identify_contiguous_integer_values(positiveOutlierIndices);
    positiveOutlierIndicator = false(nCadences,1);
    positiveOutlierIndicator(positiveOutlierIndices) = true;
    for iChunk = 1:length(positiveOutlierChunks)
        chunkStart = positiveOutlierChunks{iChunk}(1);
        chunkEnd = positiveOutlierChunks{iChunk}(end);
        if isequal(chunkStart,1)
            spikeStart = 1;
        else 
            spikeStart = find(fluxDiff(1:chunkStart-1)<0,2,'last') ;
            if isempty(spikeStart)
                spikeStart = max(chunkStart - NUM_PAD_CADENCES,1);
            end
            spikeStart = spikeStart(1);
            if (chunkStart - spikeStart) > MAX_N_CADENCES
                spikeStart = chunkStart - MAX_N_CADENCES + 1;
            end
        end
        if isequal(chunkEnd,nCadences)
            spikeEnd = nCadences;
        else
            spikeEnd = find(fluxDiff(chunkEnd+1:end)>0,3,'first') - 1 + chunkEnd;
            if isempty(spikeEnd)
                spikeEnd = min(chunkEnd + NUM_PAD_CADENCES,nCadences);
            end
            spikeEnd = spikeEnd(end);
            if (spikeEnd - chunkEnd) > MAX_N_CADENCES
                spikeEnd = chunkEnd + MAX_N_CADENCES - 1;
            end       
        end
        positiveOutlierIndicator(spikeStart:spikeEnd) = true;
    end

    % pad the outliers
    %positiveOutlierIndicator = false( length(whitenedFlux),1 );
    %positiveOutlierIndicator(positiveOutlierIndices) = true;

    %positiveOutlierIndicator = generate_padded_transit_indicator( ...
    %    positiveOutlierIndicator, NUM_PAD_CADENCES);

    positiveOutlierIndices = find(positiveOutlierIndicator);
    positiveOutlierIndices = positiveOutlierIndices(:);
end
  
return
