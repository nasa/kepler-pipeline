function injectionOutputStruct = transit_injection_controller( tpsInputStruct )
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function transit_injection_controller(tpsInputStruct,injectionStruct)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Description:
% Inputs:
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Parameters controlling the injections
collectPeriodSpaceDiagnostics = false;
nInjections = 2000;
minInjectedImpactParameter = 0;
maxInjectedImpactParameter = 1;
minInjectedPlanetRadiusInEarthRadii = 0.5;
maxInjectedPlanetRadiusInEarthRadii = 10;
nDurationsToSearch = 1;
nPeriodsToSearch = 2;
saveInterval = 10;
minPeriodOverride = 10;
randomSeedOffset = 1;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% print the parameters to the log once
fprintf('collectPeriodSpaceDiagnostics = %d\n', collectPeriodSpaceDiagnostics) ;
fprintf('nInjections = %d\n', nInjections);
fprintf('minInjectedImpactParameter = %f\n', minInjectedImpactParameter);
fprintf('maxInjectedImpactParameter = %f\n', maxInjectedImpactParameter);
fprintf('minInjectedPlanetRadiusInEarthRadii = %f\n', minInjectedPlanetRadiusInEarthRadii);
fprintf('maxInjectedPlanetRadiusInEarthRadii = %f\n', maxInjectedPlanetRadiusInEarthRadii);
fprintf('nDurationsToSearch = %d\n', nDurationsToSearch);
fprintf('nPeriodsToSearch = %d\n', nPeriodsToSearch);
fprintf('saveInterval = %d\n', saveInterval);
fprintf('minPeriodOverride = %f\n', minPeriodOverride);
fprintf('randomSeedOffset = %d\n', randomSeedOffset);

% check for the case where dv failed to produce the residual flux
if isequal(tpsInputStruct.tpsTargets.fluxValue, -1)
    error('tps:transitInjection:noDVResidualFlux', ...
        'DV failed to produce residual flux so skipping this target!');
end

% time the run
tStartInjRun = tic;

keplerId = tpsInputStruct.tpsTargets.keplerId;
nCadences = length( tpsInputStruct.tpsTargets.fluxValue );

tpsInputStruct = tps_convert_91_data_to_92( tpsInputStruct ) ;
tpsInputStruct = tps_convert_92_data_to_93( tpsInputStruct ) ;

% make sure the flux is a double
tpsInputStruct.tpsTargets.fluxValue = double( tpsInputStruct.tpsTargets.fluxValue );

% disable all normal reporting
tpsInputStruct.tpsModuleParameters.debugLevel = -1;

% add in missing fields
tpsInputStruct.tpsTargets.frontExponentialSize = 0;
tpsInputStruct.tpsTargets.backExponentialSize = 0;

% set up randStream
paramStruct = socRandStreamManagerClass.get_default_param_struct() ;
paramStruct.seedOffset = randomSeedOffset;
randStream = socRandStreamManagerClass('TPS', keplerId, paramStruct) ;
randStream.set_default( keplerId ) ;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% generate random flux fraction that matches the std
fluxStd = 1.4826*mad(tpsInputStruct.tpsTargets.fluxValue,1);
%fluxStd = 0.0005;
tpsInputStruct.tpsTargets.fluxValue = fluxStd * randn(length(tpsInputStruct.tpsTargets.fluxValue),1);
gapIndicators = tpsInputStruct.cadenceTimes.gapIndicators;
startTimes = tpsInputStruct.cadenceTimes.startTimestamps;
midTimes = tpsInputStruct.cadenceTimes.midTimestamps;
endTimes = tpsInputStruct.cadenceTimes.endTimestamps;
startTimes(gapIndicators) = interp1(find(~gapIndicators), ...
   startTimes(~gapIndicators),find(gapIndicators),'linear','extrap');
midTimes(gapIndicators) = interp1(find(~gapIndicators), ...
   midTimes(~gapIndicators),find(gapIndicators),'linear','extrap');
endTimes(gapIndicators) = interp1(find(~gapIndicators), ...
   endTimes(~gapIndicators),find(gapIndicators),'linear','extrap');
tpsInputStruct.cadenceTimes.startTimestamps = startTimes;
tpsInputStruct.cadenceTimes.midTimestamps = midTimes;
tpsInputStruct.cadenceTimes.endTimestamps = endTimes;
tpsInputStruct.cadenceTimes.gapIndicators = false(size(gapIndicators));
anomalyFlags = tpsInputStruct.cadenceTimes.dataAnomalyFlags;
anomalyFlags.attitudeTweakIndicators = false(size(gapIndicators));
anomalyFlags.safeModeIndicators = false(size(gapIndicators));
anomalyFlags.coarsePointIndicators = false(size(gapIndicators));
anomalyFlags.argabrighteningIndicators = false(size(gapIndicators));
anomalyFlags.excludeIndicators = false(size(gapIndicators));
anomalyFlags.earthPointIndicators = false(size(gapIndicators));
anomalyFlags.planetSearchExcludeIndicators = false(size(gapIndicators));
tpsInputStruct.cadenceTimes.dataAnomalyFlags = anomalyFlags;
tpsInputStruct.tpsTargets.gapIndices = [];
tpsInputStruct.tpsTargets.fillIndices = [];
tpsInputStruct.tpsTargets.outlierIndices = [];
tpsInputStruct.tpsTargets.discontinuityIndices = [];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% validate a temp input to get added fields for use below
tpsInputStruct = validate_tps_input_structure( tpsInputStruct );

superResolutionFactor = tpsInputStruct.tpsModuleParameters.superResolutionFactor;
cadencesPerDay = tpsInputStruct.tpsModuleParameters.cadencesPerDay;
cadencesPerHour = tpsInputStruct.tpsModuleParameters.cadencesPerHour;

% initialize dummy results struct
tempObject = tpsClass(tpsInputStruct);
tpsResultsTemplate = initialize_tps_results_struct( tempObject, 1 );
tpsResultsTemplate = add_new_fields( tpsResultsTemplate, [] );
tpsResultsTemplate = remove_large_fields(tpsResultsTemplate);

% get new diagnostics for completeness
if collectPeriodSpaceDiagnostics
    % time the collection of diagnostics
    tStartDiagnostics = tic;
    
    % add the mesHistogram parameters since they are not module parameters
    % yet
    tpsInputStruct.tpsModuleParameters.mesHistogramMinMes =  -1;
    tpsInputStruct.tpsModuleParameters.mesHistogramMaxMes =  1;
    tpsInputStruct.tpsModuleParameters.mesHistogramBinSize =  0.2;
    
    % run TPS up through compute_cdpp_time_series
    [tempObject, harmonicTimeSeriesAll, fittedTrendAll] = perform_quarter_stitching( tempObject );
    tempResults = compute_cdpp_time_series(tempObject, harmonicTimeSeriesAll, fittedTrendAll);
    
    % allocate the output struct
    nPulses = length(tempResults);
    tpsDiagnosticStruct = struct('decimationFactor', [], 'meanMesEstimateForSearchPeriods', ...
        [], 'validPhaseSpaceFractionForSearchPeriods', []);
    tpsDiagnosticStruct = repmat( tpsDiagnosticStruct, nPulses, 1 ) ;
    
    for iPulse = 1:nPulses
        
        % construct search periods vector 
        possiblePeriodsInCadences = compute_search_periods( tpsInputStruct.tpsModuleParameters, ...
            tempResults(iPulse).trialTransitPulseInHours, nCadences );
        
        % decimate the vector prior to search to save time
        diagnosticsDecimationFactor = 30;
        [~, ~, dutyCycle] = compute_duty_cycle( tempResults(iPulse).deemphasisWeight );
        diagnosticsDecimationFactor = diagnosticsDecimationFactor * dutyCycle ;

        [~, ~, possiblePeriodsInCadences] = decimate_period_space_diagnostics( ...
            possiblePeriodsInCadences, possiblePeriodsInCadences, ...
            possiblePeriodsInCadences, nCadences, diagnosticsDecimationFactor ) ;

        % call the folder to generate the diagnostics setting the
        % decimation to zero since the periods were already decimated
        [~,~,~,~,~, meanMesEstimate, validPhaseSpaceFraction] = ...
            fold_statistics_at_trial_periods(tempResults(iPulse), ...
            tpsInputStruct.tpsModuleParameters, possiblePeriodsInCadences, 0 );
        
        % record the results
        tpsDiagnosticStruct(iPulse).decimationFactor = diagnosticsDecimationFactor;
        tpsDiagnosticStruct(iPulse).meanMesEstimateForSearchPeriods = meanMesEstimate;
        tpsDiagnosticStruct(iPulse).validPhaseSpaceFractionForSearchPeriods = validPhaseSpaceFraction;
    
    end
    
    % save the decimated results and the decimation factor for each pulse
    save tps-diagnostic-struct tpsDiagnosticStruct;
    
    % clean up the vectors that wont be used again
    clear tempResults  meanMesEstimate validPhaseSpaceFraction possiblePeriodsInCadences tpsDiagnosticStruct;
    
    timeTakenForDiagnostics = toc(tStartDiagnostics);
    fprintf('Collecting diagnostics took %f seconds\n', timeTakenForDiagnostics);
end

clear tempObject;

minPeriod = tpsInputStruct.tpsModuleParameters.minimumSearchPeriodInDays;
maxPeriod = tpsInputStruct.tpsModuleParameters.maximumSearchPeriodInDays;

% check the length of valid data to see if the period space should be
% trimmed
[~, deemphasisWeights] = initialize_deemphasis_weights( tpsInputStruct.tpsTargets, ...
    tpsInputStruct.cadenceTimes.deemphasisParameter, tpsInputStruct.tpsModuleParameters, ...
    tpsInputStruct.gapFillParameters, [], [], [] ) ;
[~, dataSpanInCadences] = compute_duty_cycle( deemphasisWeights );
maxPeriod = min(maxPeriod, dataSpanInCadences/cadencesPerDay/2);

if minPeriodOverride > minPeriod
    minPeriod = minPeriodOverride;
end

fprintf('Injecting %d signals and performing a local search in KIC %d\n', ...
    nInjections,tpsInputStruct.tpsTargets.keplerId) ;

% loop over injections and run TPS
for iInjection = 1:nInjections
    
    resultsIndex = 1;
    
    % iterate until an injection meets duty cycle requirements and has at
    % least 3 transits
    isInvalidInjection = true;
    
    while isInvalidInjection
        % select parameters randomly from the continuous distribution
        injectedPeriodDays = 10^(log10(minPeriod) + (log10(maxPeriod) - log10(minPeriod)) * rand(1,1)); % period logarithmically
        injectedPlanetRadiusInEarthRadii = 10^( log10(minInjectedPlanetRadiusInEarthRadii) + ...
            (log10(maxInjectedPlanetRadiusInEarthRadii) - log10(minInjectedPlanetRadiusInEarthRadii)) * ...
            rand(1,1) ); % radius logarithmically
        injectedImpactParameter = minInjectedImpactParameter + (maxInjectedImpactParameter - ...
            minInjectedImpactParameter) * rand(1,1); % impactParameter uniformly
        
        % inject the signal
        [tpsInputStructInj, isInvalidInjection] = inject_transit_signal( ...
            tpsInputStruct, injectedPeriodDays, injectedPlanetRadiusInEarthRadii, ...
            injectedImpactParameter );
        
        % make a cut on the injected duration to ensure that it is at least
        % 1.5 hours
        if ~isInvalidInjection
            planetInformationStruct = tpsInputStructInj.tpsTargets.diagnostics.addedPlanetStruct.planetInformation;
            injectedDurationHours = planetInformationStruct.planetModel.transitDurationHours;
            if (injectedDurationHours < tpsInputStruct.tpsModuleParameters.minTrialTransitPulseInHours)
                isInvalidInjection = true;
            end
        end
        
        if ~isInvalidInjection
            % chop the parameter space
            modelLightCurve = tpsInputStructInj.tpsTargets.diagnostics.addedPlanetStruct.lightCurve;
            actualInjectedDepthPpm = 1e6 * abs( min(modelLightCurve) );
            planetInformationStruct.actualInjectedDepthPpm = actualInjectedDepthPpm;

            [searchSpaceStruct, totalSearchPoints, isInvalidInjection] = ...
                get_local_parameter_space( injectedPeriodDays, injectedDurationHours, ...
                tpsInputStruct.tpsModuleParameters, nCadences, nPeriodsToSearch, nDurationsToSearch);
            
            % compute period in cadences for later use
            injectedPeriodCadences = injectedPeriodDays * cadencesPerDay;
        end
        
    end

    %modify the module parameters to focus on the correct duration
    tpsInputStructInj.tpsModuleParameters.minTrialTransitPulseInHours = -1;
    tpsInputStructInj.tpsModuleParameters.maxTrialTransitPulseInHours = -1;
    tpsInputStructInj.tpsModuleParameters.storeCdppFlag = true(1,1);
    tpsInputStructInj.tpsModuleParameters.requiredTrialTransitPulseInHours = 6; % dummy value
    tpsInputStructInj.tpsModuleParameters.performWeakSecondaryTest = false; % no need to waste time on this
    
    % initialize the results structs
    tpsResultsSingleInjection = tpsResultsTemplate;
    tpsResultsSingleInjection(1:totalSearchPoints) = tpsResultsSingleInjection;
    if isequal(iInjection,1)
        tpsResultsAllInjections = tpsResultsTemplate;
        tpsResultsAllInjections(1:nInjections) = tpsResultsAllInjections;
    end
    
    fprintf('Doing injection %d and searching %d parameter space points\n', iInjection, totalSearchPoints) ;
    
    % get the fittedTrend and harmonicTimeSeries so I dont have to call the
    % quarter stitcher repeatedly
    
    % construct the object
    tpsScienceObjectInj = tpsClass(tpsInputStructInj);
    
    % do quarter stitching
    [tpsScienceObjectInj, harmonicTimeSeriesAll, fittedTrendAll] = ...
        perform_quarter_stitching( tpsScienceObjectInj ) ;
    
    % since the period space has a finer mesh than the duration space, if I
    % am only searching a few points then I can be fairly certain that the
    % closest nPeriods points are associated with the same pulse duration.
    % Therefore, just start with that pulse duration and only search until
    % either all parameter space points are exhausted or until a detection
    % is made.  This doesnt guarantee that it will be the "best" detection,
    % but it doesnt matter in this case since our end goal is to assess
    % detectability as a function of injected signal strength.  Note that
    % the searchSpaceStruct is ordered correctly when it is produced.
    
    % initialize loop variables
    isDetectionMade = false;
    iDuration = 1;
    iPeriod = 1;
    [correlationSums, normalizationSums] = initialize_correlation_and_normalization_sums();
    transitModelMatch = -1;
    
    while ~isDetectionMade && iDuration <= nDurationsToSearch

        searchPeriods = searchSpaceStruct(iDuration).searchPeriodsInDays;
        searchDuration = searchSpaceStruct(iDuration).searchDurationInHours;

        tempModuleParams = get( tpsScienceObjectInj, 'tpsModuleParameters' );
        tempModuleParams.requiredTrialTransitPulseInHours = searchDuration;
        tpsScienceObjectInj = set( tpsScienceObjectInj, 'tpsModuleParameters', tempModuleParams );

        % compute cdpp
        [tpsResultsForPeriodSearch, alerts, extendedFlux] = compute_cdpp_time_series(...
            tpsScienceObjectInj, harmonicTimeSeriesAll, fittedTrendAll);

        correlationTimeSeriesHiRes = tpsResultsForPeriodSearch.correlationTimeSeriesHiRes;
        normalizationTimeSeriesHiRes = tpsResultsForPeriodSearch.normalizationTimeSeriesHiRes;
        deemphasisWeightsSuperResolution = tpsResultsForPeriodSearch.deemphasisWeightSuperResolution;

        % compute epoch in cadences for future use - Note that the
        % midTimeStamps are used in injecte_transit_signal
        injectedEpochCadences = (planetInformationStruct.planetModel.transitEpochBkjd - ...
            tpsInputStruct.cadenceTimes.midTimestamps(1) + kjd_offset_from_mjd) * cadencesPerDay;  

        % loop over periods
        while ~isDetectionMade && iPeriod <= nPeriodsToSearch

            tStart = tic;

            % modify the module parameters to focus on the right period
            tempModuleParams = get( tpsScienceObjectInj, 'tpsModuleParameters' );
            tempModuleParams.minimumSearchPeriodInDays = searchPeriods(iPeriod);
            tempModuleParams.maximumSearchPeriodInDays = searchPeriods(iPeriod);
            tpsScienceObjectInj = set( tpsScienceObjectInj, 'tpsModuleParameters', tempModuleParams );
            
            % do the search
            [tpsResultsTemp, alerts] = compute_multiple_event_statistic(tpsScienceObjectInj, ...
                tpsResultsForPeriodSearch, alerts, extendedFlux);
            
            nTransits = sum( tpsResultsTemp.sesCombinedToYieldMes ~= 0 );

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % There are 3 things studied here that affect the MES:
            % (1) signal/template shape mismatch (includes transit duration)
            % (2) signal reduction of whitening process
            % (3) search parameter space mismatch (t0,T)
            % Here I will use a set of 3 booleans to identify what goes
            % on under each of thes effects.  For the 3 effects:
            % (1) 1: signal and template shapes match
            %     0: signal and template shapes do not match
            % (2) 1: whitener effect is suppressed
            %     0: whitener degrades signal
            % (3) 1: search parameters match injected parameters
            %     0: search parameters dont necessarily match injected
            %
            % Note that for cases 011, 001, 111, and 101, I only need
            % to compute the quantities once for each duration since
            % they dont change when the search period changes
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            if (nTransits >= tempModuleParams.minSesInMesCount && tpsResultsTemp.fitSinglePulse == false)
                % Case 000
                [correlationSums.corrSum000, normalizationSums.normSum000] = ...
                    compute_correlation_and_normalization_sums( tpsResultsTemp.bestOrbitalPeriodInCadences, ...
                    tpsResultsTemp.bestPhaseInCadences, superResolutionFactor, correlationTimeSeriesHiRes, ...
                    normalizationTimeSeriesHiRes, deemphasisWeightsSuperResolution);
            end

            if isequal(iPeriod,1)  
                % Case 001
                [correlationSums.corrSum001, normalizationSums.normSum001, indexOfSesAdded] = ...
                    compute_correlation_and_normalization_sums( injectedPeriodCadences, ...
                    injectedEpochCadences, superResolutionFactor, correlationTimeSeriesHiRes, ...
                    normalizationTimeSeriesHiRes, deemphasisWeightsSuperResolution);

                % remove the effect of the whitener
                corrNormResults1  = compute_cdpp_time_series(tpsScienceObjectInj, ...
                    harmonicTimeSeriesAll, fittedTrendAll, [], true, indexOfSesAdded);

                % trim
                corrNormResults1 = trim_cdpp_results( corrNormResults1 );

                % Case 011
                [correlationSums.corrSum011, normalizationSums.normSum011] = ...
                    compute_correlation_and_normalization_sums( injectedPeriodCadences, ...
                    injectedEpochCadences, superResolutionFactor, corrNormResults1.correlationTimeSeriesHiRes, ...
                    corrNormResults1.normalizationTimeSeriesHiRes, corrNormResults1.deemphasisWeightSuperResolution);
            end

            if (nTransits >= tempModuleParams.minSesInMesCount && tpsResultsTemp.fitSinglePulse == false)
                % Case 010
                [correlationSums.corrSum010, normalizationSums.normSum010] = ...
                    compute_correlation_and_normalization_sums( tpsResultsTemp.bestOrbitalPeriodInCadences, ...
                    tpsResultsTemp.bestPhaseInCadences, superResolutionFactor, corrNormResults1.correlationTimeSeriesHiRes, ...
                    corrNormResults1.normalizationTimeSeriesHiRes, corrNormResults1.deemphasisWeightSuperResolution);
            end

            if isequal(iDuration,1) && isequal(iPeriod,1)

                % use the injected signal as the model
                injectedModel = build_trial_pulse_from_model_light_curve( modelLightCurve );

                tempModuleParams = get( tpsScienceObjectInj, 'tpsModuleParameters' );
                tempModuleParams.requiredTrialTransitPulseInHours = injectedDurationHours;
                tpsScienceObjectInj2 = tpsScienceObjectInj;
                tpsScienceObjectInj2 = set( tpsScienceObjectInj2, 'tpsModuleParameters', tempModuleParams );

                % calculate the mismatch between the model and the actual
                % injection so that the mes estimates can be fixed
                transitModelMatch = compute_transit_model_match( ...
                    tempModuleParams, modelLightCurve, injectedModel, ...
                    injectedPeriodCadences, injectedEpochCadences, injectedDurationHours );

                % use the new model to generate correlation/normalization
                corrNormResults2  = compute_cdpp_time_series(tpsScienceObjectInj2, ...
                    harmonicTimeSeriesAll, fittedTrendAll, injectedModel);

                % trim
                corrNormResults2 = trim_cdpp_results( corrNormResults2 );
            end

            if (nTransits >= tempModuleParams.minSesInMesCount && tpsResultsTemp.fitSinglePulse == false)
                % Case 100
                [correlationSums.corrSum100, normalizationSums.normSum100] = ...
                    compute_correlation_and_normalization_sums( tpsResultsTemp.bestOrbitalPeriodInCadences, ...
                    tpsResultsTemp.bestPhaseInCadences, superResolutionFactor, corrNormResults2.correlationTimeSeriesHiRes, ...
                    corrNormResults2.normalizationTimeSeriesHiRes, corrNormResults2.deemphasisWeightSuperResolution);
            end

            if isequal(iPeriod,1)
                % Case 101
                [correlationSums.corrSum101, normalizationSums.normSum101] = ...
                    compute_correlation_and_normalization_sums( injectedPeriodCadences, ...
                    injectedEpochCadences, superResolutionFactor, corrNormResults2.correlationTimeSeriesHiRes, ...
                    corrNormResults2.normalizationTimeSeriesHiRes, corrNormResults2.deemphasisWeightSuperResolution);

                % remove the effect of the whitener with the new model
                corrNormResults3  = compute_cdpp_time_series(tpsScienceObjectInj2, ...
                    harmonicTimeSeriesAll, fittedTrendAll, injectedModel, true, indexOfSesAdded);

                % trim
                corrNormResults3 = trim_cdpp_results( corrNormResults3 );

                % Case 111
                [correlationSums.corrSum111, normalizationSums.normSum111] = ...
                    compute_correlation_and_normalization_sums( injectedPeriodCadences, ...
                    injectedEpochCadences, superResolutionFactor, corrNormResults3.correlationTimeSeriesHiRes, ...
                    corrNormResults3.normalizationTimeSeriesHiRes, corrNormResults3.deemphasisWeightSuperResolution);
            end

            if (nTransits >= tempModuleParams.minSesInMesCount && tpsResultsTemp.fitSinglePulse == false)
                % Case 110
                [correlationSums.corrSum110, normalizationSums.normSum110] = ...
                    compute_correlation_and_normalization_sums( tpsResultsTemp.bestOrbitalPeriodInCadences, ...
                    tpsResultsTemp.bestPhaseInCadences, superResolutionFactor, corrNormResults3.correlationTimeSeriesHiRes, ...
                    corrNormResults3.normalizationTimeSeriesHiRes, corrNormResults3.deemphasisWeightSuperResolution);
            end

            % add new fields and trim
            elapsedTime = toc(tStart);
            tpsResultsTemp = add_new_fields( tpsResultsTemp, planetInformationStruct, elapsedTime, ...
                correlationSums, normalizationSums, transitModelMatch );
            tpsResultsTemp = remove_large_fields(tpsResultsTemp);

            % record results
            tpsResultsSingleInjection(resultsIndex) = tpsResultsTemp;
            resultsIndex = resultsIndex + 1;

            % determine if the detection was made
            isDetectionMade = tpsResultsTemp.isPlanetACandidate;
            
            iPeriod = iPeriod + 1;

        end % loop over periods
        
        iDuration = iDuration + 1;

    end % loop over durations
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % need to exclude cases where (numSesInMes==minSesInMes &&
    % fitSinglePulse ==true).  TPS would not be able to detect these
    % since they are automatically flunked by the RS test
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % determine which result to keep for this injection   
    tpsResultsAllInjections(iInjection) = get_best_result( tpsResultsSingleInjection );
    
    % save intermediate results
    if isequal( mod(iInjection,saveInterval), 0)
        injectionOutputStruct = collect_transit_injection_results( tpsInputStructInj.tpsTargets, ...
            tpsResultsAllInjections ) ;
        save tps-injection-results-struct injectionOutputStruct ;
    end
    
end % loop over injections

injectionOutputStruct = collect_transit_injection_results( tpsInputStructInj.tpsTargets, ...
    tpsResultsAllInjections ) ;
      
% write the results file using the dawg convetions so that the aggregators
% will work

disp('TPS: Writing information struct ... ') ;
save tps-injection-results-struct injectionOutputStruct ;

totalTime = toc( tStartInjRun );
fprintf('Injection run took %f seconds\n',totalTime);

return

%=========================================================================================
% initialize correlation and normalization sums

function [correlationSums, normalizationSums] = initialize_correlation_and_normalization_sums()
    
    correlationSums.corrSum000 = -1;
    correlationSums.corrSum001 = -1;
    correlationSums.corrSum010 = -1;
    correlationSums.corrSum011 = -1;
    correlationSums.corrSum100 = -1;
    correlationSums.corrSum101 = -1;
    correlationSums.corrSum110 = -1;
    correlationSums.corrSum111 = -1;
    
    normalizationSums.normSum000 = -1;
    normalizationSums.normSum001 = -1;
    normalizationSums.normSum010 = -1;
    normalizationSums.normSum011 = -1;
    normalizationSums.normSum100 = -1;
    normalizationSums.normSum101 = -1;
    normalizationSums.normSum110 = -1;
    normalizationSums.normSum111 = -1;

return

%=========================================================================================
% compute correlation and normalization sums

function [correlationSum, normalizationSum, indexAddedOrig] = compute_correlation_and_normalization_sums( ...
    periodInCadences, phaseInCadences, superResolutionFactor, correlationTimeSeries, ...
    normalizationTimeSeries, deemphasisWeights)

[indexAddedOrig, sesCombined] = find_index_of_ses_added_to_yield_mes( periodInCadences, ...
    phaseInCadences, superResolutionFactor, correlationTimeSeries, ...
    normalizationTimeSeries, deemphasisWeights );

indexAdded = indexAddedOrig( sesCombined ~= 0 );
[correlationSum, normalizationSum] = apply_deemphasis_weights( correlationTimeSeries(indexAdded), ...
    normalizationTimeSeries(indexAdded), deemphasisWeights(indexAdded), false );

correlationSum = sum( correlationSum );
normalizationSum = sqrt( sum( normalizationSum.^2 ) );

return

%=================================================================================
% generate the trialPulse from the model light curve

function  trialPulse = build_trial_pulse_from_model_light_curve( modelLightCurve )

% interweave all the transits and interpolate out to end up with something
% symmetric - TPS will do the rest of the work internally

trialPulse = sort(modelLightCurve(modelLightCurve~=0),'descend');

% do a poly fit 
x = ( 1:length(trialPulse) )' ;
trialPulse = robust_poly_fit( trialPulse, x );

% now mirror and average to get a symmetric pulse
trialPulse = [trialPulse;sort(trialPulse,'ascend')];

return

%=========================================================================================
% compute correlation coefficent for the model built from the actual
% injection -  this can be used to adjust the mes estimates in the end

function transitModelMatch = compute_transit_model_match( ...
    tpsModuleParameters, modelLightCurve, injectedModel, ...
    injectedPeriodInCadences, injectedPhaseInCadences, injectedDurationInHours )

% extract needed quantities
waveletFilterLength = tpsModuleParameters.waveletFilterLength;
cadencesPerHour = tpsModuleParameters.cadencesPerHour;
superResolutionFactor = tpsModuleParameters.superResolutionFactor;
nCadences = length(modelLightCurve);

% compute needed quantities
injectedDurationInCadences = injectedDurationInHours * cadencesPerHour;
scalingFilterCoeffts = daubechies_low_pass_scaling_filter( waveletFilterLength );

% get the indices of SES added
indexOfSesAdded = find_index_of_ses_added_to_yield_mes( injectedPeriodInCadences, ...
    injectedPhaseInCadences, superResolutionFactor, ones(nCadences*superResolutionFactor,1), ...
    ones(nCadences*superResolutionFactor,1), ones(nCadences*superResolutionFactor,1) );

% build the superResolutionObject
superResolutionStruct = struct('superResolutionFactor', superResolutionFactor, ...
    'pulseDurationInCadences', [], 'usePolyFitTransitModel', false, ...
    'useCustomTransitModel', true) ;
superResolutionObject = superResolutionClass( superResolutionStruct, scalingFilterCoeffts ) ;
superResolutionObject = set_pulse_duration( superResolutionObject, injectedDurationInCadences ) ;
superResolutionObject = set_trial_transit_pulse( superResolutionObject, injectedModel ) ;
superResolutionObject = set_statistics_time_series_shift_length( superResolutionObject ) ;

transitModel = generate_trial_transit_pulse_train( superResolutionObject, ...
    indexOfSesAdded, nCadences ) ;

transitModel = transitModel/norm(transitModel);
modelLightCurve = modelLightCurve/norm(modelLightCurve);

% compute the Pearson correlation coefficient
transitModelMatch = sum(transitModel.*modelLightCurve);

return
            
%=========================================================================================
% Remove fields that take up too much memory

function tpsResults = remove_large_fields(tpsResults)

fieldsToRemoveCell = {'correlationTimeSeriesHiRes'; 'normalizationTimeSeriesHiRes'; ...
    'foldedStatisticAtTrialPeriods'; 'possiblePeriodsInCadences'; 'cdppTimeSeries';...
    'deemphasizeSuperResolutionCadenceIndicators';'foldedStatisticAtTrialPhases' ;...
    'phaseLagInCadences'; 'deemphasizeAroundSafeModeTweakIndicators'; ...
    'harmonicTimeSeries'; 'correlationTimeSeries'; 'normalizationTimeSeries'; ...
    'deemphasizedNormalizationTimeSeries'; 'detrendedFluxTimeSeries'; ...
    'deemphasisWeight';'deemphasisWeightSuperResolution'; 'deemphasisParameter'; ...
    'waveletObject'; 'weakSecondaryStruct'; 'mesHistogram'; 'matchedFilterUsed'; ...
    'meanMesEstimateForSearchPeriods'; 'validPhaseSpaceFractionForSearchPeriods'}; % can add addional fields

for iField = 1:length(fieldsToRemoveCell)
    if isfield(tpsResults, fieldsToRemoveCell{iField})
        tpsResults = rmfield(tpsResults, fieldsToRemoveCell{iField});
    end
end

return    

%=========================================================================================
% Remove fields that are not needed in the cdpp results

function tpsResults = trim_cdpp_results(tpsResults)

fieldsToKeep = {'correlationTimeSeriesHiRes', 'normalizationTimeSeriesHiRes','deemphasisWeightSuperResolution'};
fieldsInStruct = fieldnames(tpsResults); 

for iField = 1:length(fieldsInStruct)
    if ~ismember(fieldsInStruct{iField},fieldsToKeep)
        tpsResults = rmfield(tpsResults, fieldsInStruct{iField});
    end
end

return   

%=========================================================================================
% Add fields that are unique to transit injection results

function tpsResults = add_new_fields( tpsResults, planetInformationStruct, elapsedTime, ...
    correlationSums, normalizationSums, transitModelMatch)

if isempty(planetInformationStruct)
    tpsResults.injectedPeriodDays = [];
    tpsResults.planetRadiusInEarthRadii = [];
    tpsResults.impactParameter = [];
    tpsResults.injectedEpochKjd = [];
    tpsResults.semiMajorAxisAu = [];
    tpsResults.injectedDurationHours = [];
    tpsResults.injectedDepthPpm = [];
    tpsResults.inclinationDegrees = [];
    tpsResults.equilibriumTempKelvin = [];
    tpsResults.elapsedTime = [];
    tpsResults.corrSum000 = [];
    tpsResults.corrSum001 = [];
    tpsResults.corrSum010 = [];
    tpsResults.corrSum011 = [];
    tpsResults.corrSum100 = [];
    tpsResults.corrSum101 = [];
    tpsResults.corrSum110 = [];
    tpsResults.corrSum111 = [];
    tpsResults.normSum000 = [];
    tpsResults.normSum001 = [];
    tpsResults.normSum010 = [];
    tpsResults.normSum011 = [];
    tpsResults.normSum100 = [];
    tpsResults.normSum101 = [];
    tpsResults.normSum110 = [];
    tpsResults.normSum111 = [];
    tpsResults.transitModelMatch = [];
    
else
    tpsResults.injectedPeriodDays = planetInformationStruct.planetModel.orbitalPeriodDays;
    tpsResults.planetRadiusInEarthRadii = planetInformationStruct.planetModel.planetRadiusEarthRadii;
    tpsResults.impactParameter = planetInformationStruct.planetModel.minImpactParameter;
    tpsResults.injectedEpochKjd = planetInformationStruct.planetModel.transitEpochBkjd;
    tpsResults.semiMajorAxisAu = planetInformationStruct.planetModel.semiMajorAxisAu;
    tpsResults.injectedDurationHours = planetInformationStruct.planetModel.transitDurationHours;
    tpsResults.injectedDepthPpm = planetInformationStruct.actualInjectedDepthPpm;
    tpsResults.inclinationDegrees = planetInformationStruct.planetModel.inclinationDegrees;
    tpsResults.equilibriumTempKelvin = planetInformationStruct.planetModel.equilibriumTempKelvin;
    tpsResults.elapsedTime = elapsedTime;
    tpsResults.corrSum000 = correlationSums.corrSum000;
    tpsResults.corrSum001 = correlationSums.corrSum001;
    tpsResults.corrSum010 = correlationSums.corrSum010;
    tpsResults.corrSum011 = correlationSums.corrSum011;
    tpsResults.corrSum100 = correlationSums.corrSum100;
    tpsResults.corrSum101 = correlationSums.corrSum101;
    tpsResults.corrSum110 = correlationSums.corrSum110;
    tpsResults.corrSum111 = correlationSums.corrSum111;
    tpsResults.normSum000 = normalizationSums.normSum000;
    tpsResults.normSum001 = normalizationSums.normSum001;
    tpsResults.normSum010 = normalizationSums.normSum010;
    tpsResults.normSum011 = normalizationSums.normSum011;
    tpsResults.normSum100 = normalizationSums.normSum100;
    tpsResults.normSum101 = normalizationSums.normSum101;
    tpsResults.normSum110 = normalizationSums.normSum110;
    tpsResults.normSum111 = normalizationSums.normSum111;
    tpsResults.transitModelMatch = transitModelMatch;
end

return


%=========================================================================================
% Get the best result for each injection

function tpsResult = get_best_result( tpsResults )

% determine the index of the best result by taking the one with the highest
% MES out of all those producing TCE's.  In the case of no TCE's, just
% return the result with the highest MES.

maxMes = [tpsResults.maxMultipleEventStatistic];
isPlanetACandidate = [tpsResults.isPlanetACandidate];
[maxMesTrueTce,maxMesIndexTrueTce] = max( maxMes .* double( isPlanetACandidate ), [], 2 ) ;
[~,maxMesIndexNoTce] = max( maxMes .* double( ~isPlanetACandidate ), [], 2 ) ;
trueTceFlag = maxMesTrueTce > 0 ;

maxMesIndex(trueTceFlag) = maxMesIndexTrueTce(trueTceFlag) ;
maxMesIndex(~trueTceFlag) = maxMesIndexNoTce(~trueTceFlag) ;

tpsResult = tpsResults(maxMesIndex);

return







