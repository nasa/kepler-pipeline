function [dvResultsStruct] =  perform_dv_bootstrap(dvDataObject, dvResultsStruct)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [dvResultsStruct] = perform_dv_bootstrap(dvDataObject, dvResultsStruct)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% If enabled, performs bootstrap to asses the false alarm rate for a given
% planet in a given target in which the transits have been removed.
%
% Upon completion, perform_dv_bootstrap populates the appropriate fields in
% dvResultsStruct.
%
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
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

% Turn on all warnings
warning('on', 'all')

% get inputs
bootstrapConfigurationStruct = dvDataObject.bootstrapConfigurationStruct;
tpsConfigurationStruct       = dvDataObject.tpsConfigurationStruct;
gapFillConfigurationStruct   = dvDataObject.gapFillConfigurationStruct;
dvConfigurationStruct        = dvDataObject.dvConfigurationStruct;
cadenceTimes                 = dvDataObject.dvCadenceTimes;

% update the tpsConfigurationStruct
cadenceDurationInMinutes = gapFillConfigurationStruct.cadenceDurationInMinutes;
nCadences = length(cadenceTimes.cadenceNumbers);
tpsConfigurationStruct = update_tps_module_parameters( tpsConfigurationStruct, ...
    nCadences, cadenceDurationInMinutes );

% check inputs
if (bootstrapConfigurationStruct.convolutionMethodEnabled && ~bootstrapConfigurationStruct.useTceTrialPulseOnly)
    bootstrapConfigurationStruct.useTceTrialPulseOnly = true;
    messageString = strcat('The convolution method of performing the bootstrap only supports the use of the TCE trial transit pulse\n', ...
        'Explicitly setting bootstrapConfigurationStruct.useTceTrialPulseOnly = true\n');
    warning(messageString) 
end

if (~bootstrapConfigurationStruct.convolutionMethodEnabled && bootstrapConfigurationStruct.deemphasizeQuartersWithNoTransits)
    bootstrapConfigurationStruct.deemphasizeQuartersWithNoTransits = false;
    messageString = strcat('The deemphasize of quarters with no transits is currently only available for the convolution method.\n', ...
        'Explicitly setting bootstrapConfigurationStruct.deemphasizeQuartersWithNoTransits = false\n');
    warning(messageString) 
end

% Create bootstrapInputStruct
bootstrapInputStruct = struct( ...
    'targetNumber', 0, ...
    'keplerId', 0, ...
    'planetNumber', 0, ...
    'searchTransitThreshold', 0, ...
    'bootstrapSkipCount', 0, ...
    'histogramBinWidth', 0, ...
    'binsBelowSearchTransitThreshold', 0, ...
    'observedTransitCount', -1, ...
    'trialTransitDuration', 0, ...
    'orbitalPeriodInDays', -1, ...
    'deemphasizedNormalizationTimeSeries', -1, ...
    'epochInMjd', -1, ...
    'singleEventStatistics', struct(), ...
    'dvFiguresRootDirectory', '', ...
    'bootstrapAutoSkipCountEnabled', false, ...
    'bootstrapMaxIterations', -1, ...
    'bootstrapMaxNumberBins', -1, ...
    'bootstrapUpperLimitFactor',1, ...
    'bootstrapTceTrialPulseOnly', false, ...
    'bootstrapMaxAllowedMes', -1, ...
    'bootstrapMaxAllowedTransitCount', -1, ...
    'convolutionMethodEnabled', true, ...
    'firstMidTimestamp', -1, ...
    'superResolutionFactor', -1, ...
    'searchPeriodStepControlFactor', -1, ...
    'minSesInMesCount', -1, ...
    'minimumSearchPeriodInDays', -1, ...
    'maximumSearchPeriodInDays', -1, ...
    'maxDutyCycle', -1, ...
    'maxPeriodParameter', -1, ...
    'maxFoldingsInPeriodSearch', -1, ...
    'cadenceDurationInMinutes', -1, ...
    'deemphasizeQuartersWithoutTransits', false, ...
    'quarters', -1, ...
    'sesZeroCrossingWidthDays', -1, ...
    'sesZeroCrossingDensityFactor', -1, ...
    'nSesPeaksToRemove', -1, ...
    'sesPeakRemovalThreshold', -1, ...
    'sesPeakRemovalFloor', -1, ...
    'bootstrapResolutionFactor', -1, ...
    'debugLevel', -1);

% Fill values in bootstrapInputStruct
bootstrapInputStruct.bootstrapSkipCount              = bootstrapConfigurationStruct.skipCount;
bootstrapInputStruct.bootstrapAutoSkipCountEnabled   = bootstrapConfigurationStruct.autoSkipCountEnabled;
bootstrapInputStruct.bootstrapMaxIterations          = bootstrapConfigurationStruct.maxIterations;
bootstrapInputStruct.bootstrapMaxNumberBins          = bootstrapConfigurationStruct.maxNumberBins;
bootstrapInputStruct.histogramBinWidth               = bootstrapConfigurationStruct.histogramBinWidth;
bootstrapInputStruct.searchTransitThreshold          = tpsConfigurationStruct.searchTransitThreshold;
bootstrapInputStruct.debugLevel                      = dvConfigurationStruct.debugLevel;
bootstrapInputStruct.binsBelowSearchTransitThreshold = bootstrapConfigurationStruct.binsBelowSearchTransitThreshold;
bootstrapInputStruct.bootstrapUpperLimitFactor       = bootstrapConfigurationStruct.upperLimitFactor;
bootstrapInputStruct.superResolutionFactor           = tpsConfigurationStruct.superResolutionFactor;
bootstrapInputStruct.searchPeriodStepControlFactor   = tpsConfigurationStruct.searchPeriodStepControlFactor;
bootstrapInputStruct.minSesInMesCount                = tpsConfigurationStruct.minSesInMesCount;
bootstrapInputStruct.minimumSearchPeriodInDays       = tpsConfigurationStruct.minimumSearchPeriodInDays;
bootstrapInputStruct.maximumSearchPeriodInDays       = tpsConfigurationStruct.maximumSearchPeriodInDays;
bootstrapInputStruct.maxDutyCycle                    = tpsConfigurationStruct.maxDutyCycle;
bootstrapInputStruct.maxPeriodParameter              = tpsConfigurationStruct.maxPeriodParameter;
bootstrapInputStruct.maxFoldingsInPeriodSearch       = tpsConfigurationStruct.maxFoldingsInPeriodSearch;
bootstrapInputStruct.cadenceDurationInMinutes        = cadenceDurationInMinutes;
bootstrapInputStruct.bootstrapTceTrialPulseOnly      = bootstrapConfigurationStruct.useTceTrialPulseOnly;
bootstrapInputStruct.bootstrapMaxAllowedMes          = bootstrapConfigurationStruct.maxAllowedMes;
bootstrapInputStruct.bootstrapMaxAllowedTransitCount = bootstrapConfigurationStruct.maxAllowedTransitCount;
bootstrapInputStruct.convolutionMethodEnabled        = bootstrapConfigurationStruct.convolutionMethodEnabled;
bootstrapInputStruct.quarters                        = cadenceTimes.quarters;
bootstrapInputStruct.deemphasizeQuartersWithoutTransits = bootstrapConfigurationStruct.deemphasizeQuartersWithoutTransits;
bootstrapInputStruct.sesZeroCrossingWidthDays        = bootstrapConfigurationStruct.sesZeroCrossingWidthDays;
bootstrapInputStruct.sesZeroCrossingDensityFactor    = bootstrapConfigurationStruct.sesZeroCrossingDensityFactor;
bootstrapInputStruct.nSesPeaksToRemove               = bootstrapConfigurationStruct.nSesPeaksToRemove;
bootstrapInputStruct.sesPeakRemovalThreshold         = bootstrapConfigurationStruct.sesPeakRemovalThreshold;
bootstrapInputStruct.sesPeakRemovalFloor             = bootstrapConfigurationStruct.sesPeakRemovalFloor;
bootstrapInputStruct.bootstrapResolutionFactor       = bootstrapConfigurationStruct.bootstrapResolutionFactor;

% Get the randstreams if they exist
streams = false;
fields = fieldnames(dvDataObject);
if any(strcmp('randStreamStruct', fields))
    randStreams = dvDataObject.randStreamStruct.bootstrapRandStreams;
    streams = true;
end % if

nTargets = length(dvResultsStruct.targetResultsStruct);

for iTarget = 1:nTargets
    
    keplerId = dvResultsStruct.targetResultsStruct(iTarget).keplerId;
    
    % Set target-specific randstreams
    if streams
        randStreams.set_default(keplerId);
    end % if
    
    % Populate bootstrap input structure
    bootstrapInputStruct.targetNumber = iTarget;
    
    bootstrapInputStruct.keplerId = keplerId;
    
    bootstrapInputStruct.singleEventStatistics = ...
        dvResultsStruct.targetResultsStruct(iTarget).singleEventStatistics;
    
    bootstrapInputStruct.dvFiguresRootDirectory = ...
        dvResultsStruct.targetResultsStruct(iTarget).dvFiguresRootDirectory;
    
    nPlanets = ...
        length(dvResultsStruct.targetResultsStruct(iTarget).planetResultsStruct);
    
    % Add SES plot if modelChiSquare > -1 for any planet
    for iPlanet = 1 : nPlanets
        if (dvResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(iPlanet).allTransitsFit.modelChiSquare > -1)
            %plot_residual_SES(bootstrapClass(bootstrapInputStruct));
            break;
        end
    end
    
    for iPlanet = 1: nPlanets
        
        fprintf('\nBootstrap in progress...target=%d, keplerId=%d, planet %d...\n', iTarget, bootstrapInputStruct.keplerId, iPlanet)

        bootstrapInputStruct.planetNumber = ...
            dvResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(iPlanet).planetCandidate.planetNumber;

        % if we are doing the convolution method then the observed transit
        % count is computed internally
        if ~bootstrapInputStruct.convolutionMethodEnabled
            bootstrapInputStruct.observedTransitCount  = ...
                dvResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(iPlanet).planetCandidate.observedTransitCount;
        end
        
        bootstrapInputStruct.trialTransitDuration = ...
            dvResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(iPlanet).planetCandidate.trialTransitPulseDuration;
        
        bootstrapInputStruct.orbitalPeriodInDays = ...
            dvResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(iPlanet).planetCandidate.orbitalPeriod;
        
        bootstrapInputStruct.epochInMjd = ...
            dvResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(iPlanet).planetCandidate.epochMjd;
        
        bootstrapInputStruct.deemphasizedNormalizationTimeSeries = ...
            dvResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(iPlanet).planetCandidate.deemphasizedNormalizationTimeSeries;
        
        % set the first midTimeStamp
        cadencesPerHour =  1 / (get_unit_conversion('min2hour') * bootstrapInputStruct.cadenceDurationInMinutes);
        bootstrapInputStruct.firstMidTimestamp = initialize_search_start_cadence_timestamp( ...
            bootstrapInputStruct.trialTransitDuration, cadencesPerHour, ...
            cadenceTimes) ;
        
        % All inputStruct values should be filled by now
        % Instantiate the bootstrap object, 1 BS object per target per planet
        bootstrapObject = bootstrapClass(bootstrapInputStruct);

        [validBootstrapObject dvResultsStruct] = ...
            validate_bootstrapObject(bootstrapObject, dvResultsStruct);
                
        % Do bootstrap, once per target per planet, if valid bootstrapObject
        if validBootstrapObject
            
            fprintf('\t valid bootstrapObject, proceeding with histogram generation\n')

            % Create bootstrapResultsStruct to place bootstrap results
            bootstrapResultsStruct = create_bootstrapResultsStruct(bootstrapObject);

            [bootstrapResultsStruct, dvResultsStruct] = ...
                run_bootstrap(bootstrapObject, bootstrapResultsStruct, dvResultsStruct);
            
            if any(bootstrapResultsStruct.probabilities)

                [bootstrapResultsStruct dvResultsStruct] = ...
                    compute_false_alarm(bootstrapObject, bootstrapResultsStruct, dvResultsStruct, 1);

                % Populate dvResultsStruct
                dvResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(iPlanet).planetCandidate.bootstrapHistogram.statistics = ...
                    bootstrapResultsStruct.statistics;

                dvResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(iPlanet).planetCandidate.bootstrapHistogram.finalSkipCount = ...
                    mean([bootstrapResultsStruct.histogramStruct.finalSkipCount]);

                dvResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(iPlanet).planetCandidate.significance = ...
                    bootstrapResultsStruct.significance;

                dvResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(iPlanet).planetCandidate.bootstrapHistogram.probabilities = ...
                    bootstrapResultsStruct.probabilities;
                
                dvResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(iPlanet).planetCandidate.bootstrapThresholdForDesiredPfa = ...
                    bootstrapResultsStruct.bootstrapThresholdForDesiredPfa;
                
                dvResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(iPlanet).planetCandidate.bootstrapMesMean = ...
                    bootstrapResultsStruct.bootstrapMesMean;
                
                dvResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(iPlanet).planetCandidate.bootstrapMesStd = ...
                    bootstrapResultsStruct.bootstrapMesStd;
                
            else
                
                % Issue a warning when the bootstrap fails to construct the
                % MES distribution estimate
                messageString = sprintf('The bootstrap failed to construct the MES distribution estimate for planet %d of target %d. No results are available.',iPlanet,iTarget);
                dvResultsStruct = add_dv_alert(dvResultsStruct, 'bootstrap', ...
                    'warning', messageString, iTarget, keplerId, iPlanet);
                disp(dvResultsStruct.alerts(end).message);
                
            end % if histogram(s) built

        end % if valid bootstrapObject

    end % iPlanet

    % restore the default randstreams
    if streams
        randStreams.restore_default();
    end % if
    
end % iTarget

return



