function bootstrapResults = bootstrap_monte_carlo( tpsInputStruct, nTransits )

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Run Parameters
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
duration = 6;
nCadences = 71427;
useWhitener = false;
nTrials = 500;
resultsLowMes = -1;
resultsHighMes = 20;
resultsBinWidth = 0.1;
additionalRandSeedOffset = 0;
doFigure = false;
saveResults = true;
saveInterval = 10;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% print the parameters to the log
fprintf('duration = %f\n',duration);
fprintf('nCadences = %d\n',nCadences)
fprintf('useWhitener = %d\n',useWhitener);
fprintf('nTrials = %d\n',nTrials);
fprintf('resultsLowMes = %f\n',resultsLowMes);
fprintf('resultsHighMes = %f\n',resultsHighMes);
fprintf('resultsBinWidth = %f\n',resultsBinWidth);
fprintf('additionalRandSeedOffset = %d\n',additionalRandSeedOffset);
fprintf('doFigure = %d\n',doFigure);
fprintf('saveResults = %d\n',saveResults);
fprintf('saveInterval = %d\n',saveInterval);

% get nTransits
if ~exist('nTransits','var') || isempty(nTransits)
    nTransits = tpsInputStruct.tpsTargets.nTransits;
end

if useWhitener && ~isequal(nCadences,length(tpsInputStruct.tpsTargets.fluxValue))
    error('tps:bootstrap:invalidNCadences', ...
        'if you are using the whitener then nCadences must be length(flux)!');
end

% binning parameters
mesBins = (resultsLowMes:resultsBinWidth:resultsHighMes)';
counts = zeros(length(mesBins),1);
probSum = zeros(length(mesBins),1);

threshold = resultsLowMes;
keplerId = tpsInputStruct.tpsTargets.keplerId;

bootstrapResults = struct('nTrials',-1,'duration',duration,'nTransits',nTransits, ...
    'nCadences', nCadences, 'mesBins',mesBins,'counts',counts,'probSum',probSum);

% validate the input struct
tpsInputStruct = validate_tps_input_structure( tpsInputStruct );

% get inputs
bootstrapParams = tpsInputStruct.bootstrapParameters;
tpsModuleParameters = tpsInputStruct.tpsModuleParameters;
cadenceTimes = tpsInputStruct.cadenceTimes;
gapFillParameters = tpsInputStruct.gapFillParameters;

% set up randStream
if ~isfield( tpsInputStruct.tpsTargets, 'randSeedOffset' ) || isempty( tpsInputStruct.tpsTargets.randSeedOffset )
    randSeedOffset = 0;
else
    randSeedOffset = tpsInputStruct.tpsTargets.randSeedOffset + additionalRandSeedOffset;
end
paramStruct = socRandStreamManagerClass.get_default_param_struct() ;
paramStruct.seedOffset = randSeedOffset;
randStream = socRandStreamManagerClass('TPS', keplerId, paramStruct) ;
randStream.set_default( keplerId ) ;

% set input parameters
bootstrapInputStruct.keplerId                           = keplerId;
bootstrapInputStruct.targetNumber                       = 1;
bootstrapInputStruct.planetNumber                       = 1;
bootstrapInputStruct.debugLevel                         = 0;
bootstrapInputStruct.superResolutionFactor              = 1;
bootstrapInputStruct.dvFiguresRootDirectory             = '';
bootstrapInputStruct.observedTransitCount               = nTransits;
bootstrapInputStruct.deemphasizeQuartersWithoutTransits = false;
bootstrapInputStruct.searchTransitThreshold             = threshold;  % update this to get wider plots
bootstrapInputStruct.trialTransitDuration               = duration;
bootstrapInputStruct.bootstrapMaxIterations             = bootstrapParams.maxIterations;
bootstrapInputStruct.bootstrapMaxNumberBins             = bootstrapParams.maxNumberBins;
bootstrapInputStruct.histogramBinWidth                  = bootstrapParams.histogramBinWidth;
bootstrapInputStruct.bootstrapTceTrialPulseOnly         = bootstrapParams.useTceTrialPulseOnly;
bootstrapInputStruct.convolutionMethodEnabled           = bootstrapParams.convolutionMethodEnabled;
bootstrapInputStruct.sesZeroCrossingWidthDays           = bootstrapParams.sesZeroCrossingWidthDays;
bootstrapInputStruct.sesZeroCrossingDensityFactor       = bootstrapParams.sesZeroCrossingDensityFactor;
bootstrapInputStruct.nSesPeaksToRemove                  = bootstrapParams.nSesPeaksToRemove;
bootstrapInputStruct.sesPeakRemovalThreshold            = bootstrapParams.sesPeakRemovalThreshold;
bootstrapInputStruct.sesPeakRemovalFloor                = bootstrapParams.sesPeakRemovalFloor;
bootstrapInputStruct.bootstrapResolutionFactor          = bootstrapParams.bootstrapResolutionFactor;
bootstrapInputStruct.searchPeriodStepControlFactor      = tpsModuleParameters.searchPeriodStepControlFactor;
bootstrapInputStruct.minSesInMesCount                   = tpsModuleParameters.minSesInMesCount;
bootstrapInputStruct.maxDutyCycle                       = tpsModuleParameters.maxDutyCycle;
bootstrapInputStruct.maxPeriodParameter                 = tpsModuleParameters.maxPeriodParameter;
bootstrapInputStruct.maxFoldingsInPeriodSearch          = tpsModuleParameters.maxFoldingsInPeriodSearch;
bootstrapInputStruct.minimumSearchPeriodInDays          = tpsModuleParameters.minimumSearchPeriodInDays;
bootstrapInputStruct.maximumSearchPeriodInDays          = tpsModuleParameters.maximumSearchPeriodInDays;
bootstrapInputStruct.cadenceDurationInMinutes           = gapFillParameters.cadenceDurationInMinutes;
bootstrapInputStruct.quarters                           = cadenceTimes.quarters;

% get the cadenceQuarterLabels
deemphasisWeights = ones(nCadences,1);
if tpsModuleParameters.noiseEstimationByQuarterEnabled
    quarters = tpsInputStruct.cadenceTimes.quarters;
    fillIndices = sort(unique([tpsInputStruct.tpsTargets.gapIndices;tpsInputStruct.tpsTargets.fillIndices]));
    cadenceQuarterLabels = get_intra_quarter_cadence_labels( quarters, fillIndices );
    deemphasisWeights(fillIndices) = 0;
else
    cadenceQuarterLabels = ones(nCadences,1);
end

% initialize the singleEventStatistics
statisticSeries = struct( ...
    'values', zeros(nCadences,1), ...
    'gapIndicators', false(nCadences,1));
deemphasisSeries = struct( ...
    'values', deemphasisWeights );
singleEventStatistics = struct( ...
    'trialTransitPulseDuration', bootstrapInputStruct.trialTransitDuration, ...
    'correlationTimeSeries', statisticSeries, ...
    'normalizationTimeSeries', statisticSeries, ...
    'deemphasisWeights', deemphasisSeries);

% pulse width in cadences
trialTransitPulseWidth = round(tpsModuleParameters.cadencesPerHour*duration);

% initialize the results


% loop over the nTrials and generate results
for iTrial = 1:nTrials

    if useWhitener
        % generate random flux
        flux = (1+rand(1,1)) .* randn(nCadences,1); % std deviation random between 1 and 2

        % Method 1: use the wavelet/whitening machinery to get singleEventStatsitcs
        scalingFilterCoeffts = daubechies_low_pass_scaling_filter(tpsModuleParameters.waveletFilterLength);
        superResolutionStruct = struct('superResolutionFactor', 1, ...
            'pulseDurationInCadences', [], 'usePolyFitTransitModel', true, ...
            'useCustomTransitModel', false) ;
        superResolutionObject = superResolutionClass( superResolutionStruct, scalingFilterCoeffts ) ;
        varianceEstimationWindowLength = floor(trialTransitPulseWidth * tpsModuleParameters.varianceWindowLengthMultiplier);
        waveletObject = waveletClass( scalingFilterCoeffts ) ;
        waveletObject = set_outlier_vectors( waveletObject, false(nCadences,1), [], gapFillParameters ) ;
        waveletObject = set_extended_flux( waveletObject, flux, tpsModuleParameters.noiseEstimationByQuarterEnabled, ...
            cadenceQuarterLabels ) ;
        superResolutionObject = set_pulse_duration( superResolutionObject, trialTransitPulseWidth ) ;
        superResolutionObject = set_trial_transit_pulse( superResolutionObject) ;
        superResolutionObject = set_statistics_time_series_shift_length( superResolutionObject ) ;
        waveletObject = set_whitening_coefficients( waveletObject, varianceEstimationWindowLength, false ) ; 
        superResolutionObject = set_wavelet_object( superResolutionObject, waveletObject ) ;
        [superResolutionObject, correlationTimeSeries, normalizationTimeSeries] =  ...
            set_hires_statistics_time_series( superResolutionObject, nCadences ) ;   

    else
        % Method2 use random noise to get singleEventStatistics
        correlationTimeSeries = randn(nCadences,trialTransitPulseWidth);
        %temp=std(correlationTimeSeries,0,1)';
        %for i=1:trialTransitPulseWidth
        %    correlationTimeSeries(:,i) = correlationTimeSeries(:,i)/(temp(i));
        %    correlationTimeSeries(:,i) = correlationTimeSeries(:,i) - mean(correlationTimeSeries(:,i));
        %end
        correlationTimeSeries = sum(correlationTimeSeries,2);
        normalizationTimeSeries = sqrt(trialTransitPulseWidth) * ones(nCadences,1);
    end

    % get the singleEventStatistics for the object
    singleEventStatistics.correlationTimeSeries.values = correlationTimeSeries;
    singleEventStatistics.normalizationTimeSeries.values = normalizationTimeSeries;
    bootstrapInputStruct.singleEventStatistics = singleEventStatistics;
    bootstrapInputStruct.deemphasizedNormalizationTimeSeries = deemphasisWeights.*normalizationTimeSeries;

    % get the midTimeStamp
    cadencesPerHour =  1 / (get_unit_conversion('min2hour') * bootstrapInputStruct.cadenceDurationInMinutes);
    bootstrapInputStruct.firstMidTimestamp = initialize_search_start_cadence_timestamp( ...
        bootstrapInputStruct.trialTransitDuration, cadencesPerHour, cadenceTimes) ;
    
    % instantiate
    bootstrapObject = bootstrapClass(bootstrapInputStruct);

    % validate
    validBootstrapObject = validate_bootstrapObject(bootstrapObject);
    
    % Generate the histogram and threshold
    if validBootstrapObject

        % Create bootstrapResultsStruct to place bootstrap results
        tempResults = create_bootstrapResultsStruct(bootstrapObject);

        % generate the mes distribution by convolution
        tempResults = generate_histogram_by_convolution(bootstrapObject, tempResults);

        % compute the cumulative sum
        [statistics, probabilities] = compute_cumulative_probability( bootstrapObject, tempResults ); 
    end
    
    % bin the results
    bin = floor((statistics - (resultsLowMes-resultsBinWidth/2)) / resultsBinWidth) + 1;
    binIndicator = bin > 0 & bin <= length(mesBins);
    bin = bin(binIndicator);
    counts(bin) = counts(bin) + 1;
    probSum(bin) = probSum(bin) + probabilities(binIndicator);
    
    if isequal( mod(iTrial,saveInterval), 0) && saveResults
        bootstrapResults.nTrials = iTrial;
        bootstrapResults.mesBins = mesBins;
        bootstrapResults.probSum = probSum;
        bootstrapResults.counts = counts;
        fprintf('Saving results at trial number %d\n',iTrial);
        save bootstrap-results-struct bootstrapResults;
    end

end

bootstrapResults.nTrials = nTrials;
bootstrapResults.mesBins = mesBins;
bootstrapResults.probSum = probSum;
bootstrapResults.counts = counts;

if doFigure
    mesBins = mesBins(counts~=0);
    probSum = probSum(counts~=0);
    counts = counts(counts~=0);
    figure
    plot(mesBins,log10(probSum./counts),'-o')
    %y1=log10(0.5*erfc((mesBins-mesBinWidth/2)./sqrt(2)));
    y=log10(0.5*erfc((mesBins)./sqrt(2)));
    %y2=log10(0.5*erfc((mesBins+mesBinWidth/2)./sqrt(2)));
    hold on
    plot(mesBins,y,'-r*')
    %plot(mesBins,y1,'-ro')
    %plot(mesBins,y2,'-ro')
end

if saveResults
    fprintf('Saving final results\n');
    save bootstrap-results-struct bootstrapResults;
end

return