% This is a collection os static methods used for dispatching processes in PDC
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

classdef pdcDispatchWrapperClass

methods(Static=true)

%----------------------------------------------------------------------------------------------------
% This function is called in pdc_matlab_controller in the daughter processes. The actual dispatched functions are called from here. %
% 
% THIS FUNCTION SHOULD ONLY BE CALLED IN A DIAPTCHED PROCESS!

function dispatch_in_daughter_wrapper(daughterDispatcher)

    if (~daughterDispatcher.isInDaughter)
        error('dispatch_in_daughter_wrapper: Thsi function should only be called in adispatched process');
    end

    % Check if there is a dispatch file
    dispatchingEnabled = pdcDaughterDispatcherClass.check_for_dispatch_out_file;
    if (~dispatchingEnabled)
        error(['DaughterDispatcher task: ', daughterDispatcher.daughterTaskString, '; we are in a daughter but there is no dispatch file.']);
    end

    % Load the required arguments from dispatch file
    [dispatchedArguments] = daughterDispatcher.load_dispatched_arguments;

    % Call the actual command
    switch daughterDispatcher.daughterTaskString 

    case 'stellarVariability'

        [variability, medianVariability] = pdc_calculate_stellar_variability ...
            (dispatchedArguments.targetDataStruct, dispatchedArguments.cadenceTimes, dispatchedArguments.coarseDetrendPolyOrder, ...
                dispatchedArguments.doNormalizeFlux, dispatchedArguments.doMaskEpRecovery, ...
                dispatchedArguments.maskWindow, dispatchedArguments.doRemoveEclipsingBinaries);

        % Save the returned arguments
        daughterDispatcher.save_returning_arguments ('variability', 'medianVariability');

    case 'MAP'

        [mapResultsObject] = map_controller (dispatchedArguments.mapConfigurationStruct, dispatchedArguments.pdcModuleParameters, ...
                dispatchedArguments.targetDataStruct, dispatchedArguments.cadenceTimes, dispatchedArguments.targetsForBasisVectorsAndPriors, ...
                dispatchedArguments.mapDiagnosticStruct, dispatchedArguments.variabilityStruct, dispatchedArguments.mapBlobStruct, ...
                dispatchedArguments.cbvBlobStruct, dispatchedArguments.goodnessMetricConfigurationStruct, dispatchedArguments.motionPolyStruct);

        mapCorrectedTargetDataStruct = mapResultsObject.mapCorrectedTargetDataStruct;
        alerts = mapResultsObject.alerts;
        daughterDispatcher.save_returning_arguments ('mapCorrectedTargetDataStruct', 'alerts');
        clear mapCorrectedTargetDataStruct alerts;

    case 'goodnessMetric'

        % All optional arguments have been made explicit in pdc_goodness_metric_dispatcher 

        goodnessStruct = pdc_goodness_metric (dispatchedArguments.rawDataStruct, dispatchedArguments.correctedDataStruct, dispatchedArguments.cadenceTimes, ...
                dispatchedArguments.pdcModuleParameters, dispatchedArguments.goodnessMetricConfigurationStruct, dispatchedArguments.doNormalizeFlux, ...
                dispatchedArguments.doSavePlots, dispatchedArguments.plotTitleIntro, dispatchedArguments.targetList, dispatchedArguments.plotSubDirSuffix, ...
                dispatchedArguments.calcEpGoodness);

        daughterDispatcher.save_returning_arguments ('goodnessStruct');

    case 'blueBox'

        [localTargetDataStruct, alerts, fluxCorrectionStruct, pdcDebugObject, ...
            targetsToUseForBasisVectorsAndPriors] = pdc_blue_box_spsd_outlier_harmonics (...
            dispatchedArguments.daughterDispatcher, ...
            dispatchedArguments.localTargetDataStruct, ...
            dispatchedArguments.pdcInputObject, ...
            dispatchedArguments.uberDiagnosticStruct, ...
            dispatchedArguments.cbvBlobStruct, ...
            dispatchedArguments.mapBlobStruct, ...
            dispatchedArguments.localMotionPolyStruct, ...
            dispatchedArguments.fluxCorrectionStruct, ...
            dispatchedArguments.pdcDebugObject, ...
            dispatchedArguments.pdcInternalConfig, ...
            dispatchedArguments.localConfigurationStruct, ...
            dispatchedArguments.spsdBlobStruct, ...
            dispatchedArguments.dataAnomalyIndicators, ...
            dispatchedArguments.nonbsMapConfigurationStruct, ...
            dispatchedArguments.alerts);

        % Do not return mapResultsObjectCoarse, it's a huge object, memory fragmentation and all...
        daughterDispatcher.save_returning_arguments ('localTargetDataStruct', 'alerts', 'fluxCorrectionStruct', ...
            'pdcDebugObject', 'targetsToUseForBasisVectorsAndPriors');

    case 'greenBox'

        [localTargetDataStruct, alerts, fluxCorrectionStruct, variabilityStruct, pdcDebugObject] = ...
            pdc_green_box_map_proper (...
            dispatchedArguments.daughterDispatcher, ...
            dispatchedArguments.localTargetDataStruct, ...
            dispatchedArguments.pdcInputObject, ...
            dispatchedArguments.cbvBlobStruct, ...
            dispatchedArguments.uberDiagnosticStruct, ...
            dispatchedArguments.mapBlobStruct, ...
            dispatchedArguments.localMotionPolyStruct, ...
            dispatchedArguments.fluxCorrectionStruct, ...
            dispatchedArguments.pdcDebugObject, ...
            dispatchedArguments.pdcInternalConfig, ...
            dispatchedArguments.nonbsMapConfigurationStruct, ...
            dispatchedArguments.targetsToUseForBasisVectorsAndPriors, ...
            dispatchedArguments.bsMapConfigurationStructArray, ...
            dispatchedArguments.alerts);

            % Save msMapResultsObject to file but do not return to mother process
           %intelligent_save('msMapResultsObject', 'msMapResultsObject');

        % Do not return mapResultsObjects, they are huge objects, memory fragmentation and all...
        daughterDispatcher.save_returning_arguments ('localTargetDataStruct', 'alerts', 'fluxCorrectionStruct', 'variabilityStruct', 'pdcDebugObject');

    case 'createOutputs'

        pdcOutputsStruct = ...
            pdc_create_output_struct(dispatchedArguments.pdcInputObject, dispatchedArguments.localTargetDataStruct, ...
                dispatchedArguments.harmonicTimeSeries, dispatchedArguments.outlieredFluxSeries,...
                                        dispatchedArguments.fluxCorrectionStruct, dispatchedArguments.alerts, ...
                                        dispatchedArguments.goodnessStruct, dispatchedArguments.variabilityStruct, ...
                                        dispatchedArguments.gapFilledCadenceMidTimestamps);

        daughterDispatcher.save_returning_arguments ('pdcOutputsStruct');

    case 'presearch_data_conditioning_map'

        [pdcOutputsStruct] = presearch_data_conditioning_map(dispatchedArguments.pdcInputObject, dispatchedArguments.uberDiagnosticStruct, ...
                                dispatchedArguments.daughterDispatcher);

        daughterDispatcher.save_returning_arguments ('pdcOutputsStruct');

    case 'bs_controller_split'

        [targetDataStructBands] = bs_controller_split(dispatchedArguments.localTargetDataStruct, ...
            dispatchedArguments.bandSplittingConfigurationStruct, dispatchedArguments.bsDiagnosticStruct);

        daughterDispatcher.save_returning_arguments ('targetDataStructBands');

    otherwise

        error(['DaughterDispatcher task: ', daughterDispatcher.daughterTaskString, '; Unknown sub-task.']);

    end

    % Quit this session (if in a session and not executable) so we can proceed with the mother
    if (daughterDispatcher.doSpawnMatlabSession)
        quit;
    end

end % dispatcher


%*************************************************************************************************************
% Stellar variability calculator dispatcher

function [variability, medianVariability] = pdc_calculate_stellar_variability_dispatcher ...
            (targetDataStruct, cadenceTimes, coarseDetrendPolyOrder, doNormalizeFlux, doMaskEpRecovery, ...
             maskWindow, doRemoveEclipsingBinaries, daughterDispatcher)

    daughterTaskString = 'stellarVariability';

    % Determine if this is a matlab session or matlab executable. this determines the command string
    if (~daughterDispatcher.dispatchingEnabled)
        % Just call stellar variability calulator, bypassing the dispatch function
        [variability, medianVariability] = pdc_calculate_stellar_variability ...
            (targetDataStruct, cadenceTimes, coarseDetrendPolyOrder, doNormalizeFlux, doMaskEpRecovery, ...
             maskWindow, doRemoveEclipsingBinaries);

        return;

    elseif (daughterDispatcher.doSpawnMatlabSession)
        % A matlab session, so call pdc_matlab_controller with the task string
        commandString = ['[~] = pdc_matlab_controller ([], [],''', daughterTaskString, ''')'];

    elseif (daughterDispatcher.doSpawnMatlabExecutable)
        % A matlab executable, so just need to pass the task string
        commandString = daughterTaskString;

    else
        errror('error');
    end

    disp(['*~*~*~*~*~* Dispatching ', daughterTaskString, '...*~*~*~*~*~*']);

    [variability, medianVariability] =  daughterDispatcher.dispatch (commandString, daughterTaskString, ...
             'targetDataStruct', 'cadenceTimes', 'coarseDetrendPolyOrder', 'doNormalizeFlux', 'doMaskEpRecovery', ...
             'maskWindow', 'doRemoveEclipsingBinaries');

    disp(['*~*~*~*~*~* Finished dispatching ', daughterTaskString, '*~*~*~*~*~*']);

end % function pdc_calculate_stellar_variability_dispatcher 

%*************************************************************************************************************
% MAP calculator dispatcher

function [mapCorrectedTargetDataStruct, alerts, basisVectors] = map_controller_dispatcher (mapConfigurationStruct, pdcModuleParameters, ...
                targetDataStruct, cadenceTimes, targetsForBasisVectorsAndPriors, mapDiagnosticStruct, ...
                variabilityStruct, mapBlobStruct, cbvBlobStruct, goodnessMetricConfigurationStruct, ...
                motionPolyStruct, daughterDispatcher)

    daughterTaskString = 'MAP';

    % Determine if this is a matlab session or matlab executable. this determines the command string
    if (~daughterDispatcher.dispatchingEnabled)
        % Just call map_controller , bypassing the dispatch function
        [mapCorrectedTargetDataStruct, alerts, basisVectors] = map_controller (mapConfigurationStruct, pdcModuleParameters, ...
                targetDataStruct, cadenceTimes, targetsForBasisVectorsAndPriors, mapDiagnosticStruct, ...
                variabilityStruct, mapBlobStruct, cbvBlobStruct, goodnessMetricConfigurationStruct, ...
                motionPolyStruct);

        return;

    elseif (daughterDispatcher.doSpawnMatlabSession)
        % A matlab session, so call pdc_matlab_controller with the task string
        commandString = ['[~] = pdc_matlab_controller ([], [],''', daughterTaskString, ''')'];

    elseif (daughterDispatcher.doSpawnMatlabExecutable)
        % A matlab executable, so just need to pass the task string
        commandString = daughterTaskString;

    else
        errror('error');
    end

    disp(['*~*~*~*~*~* Dispatching ', daughterTaskString, '...*~*~*~*~*~*']);

    [mapCorrectedTargetDataStruct, alerts, basisVectors] =  daughterDispatcher.dispatch ...
        (commandString, daughterTaskString, 'mapConfigurationStruct', 'pdcModuleParameters', ...
             'targetDataStruct', 'cadenceTimes', 'targetsForBasisVectorsAndPriors', 'mapDiagnosticStruct', ...
                'variabilityStruct', 'mapBlobStruct', 'cbvBlobStruct', 'goodnessMetricConfigurationStruct', ...
                'motionPolyStruct');

    disp(['*~*~*~*~*~* Finished dispatching ', daughterTaskString, '*~*~*~*~*~*']);

end % function map_controller_dispatcher 

%*************************************************************************************************************
% Goodness Metric Calculator dispatcher

function goodnessStruct = pdc_goodness_metric_dispatcher (daughterDispatcher, rawDataStruct, correctedDataStruct, cadenceTimes, ...
        pdcModuleParameters, goodnessMetricConfigurationStruct, doNormalizeFlux, doSavePlots, plotTitleIntro, varargin)
    
    daughterTaskString = 'goodnessMetric';

    % Determine if this is a matlab session or matlab executable. this determines the command string
    if (~daughterDispatcher.dispatchingEnabled)
        % Just call , bypassing the dispatch function
        goodnessStruct = pdc_goodness_metric (rawDataStruct, correctedDataStruct, cadenceTimes, ...
            pdcModuleParameters, goodnessMetricConfigurationStruct, doNormalizeFlux, doSavePlots, plotTitleIntro, varargin{:});

        return;

    elseif (daughterDispatcher.doSpawnMatlabSession)
        % A matlab session, so call pdc_matlab_controller with the task string
        commandString = ['[~] = pdc_matlab_controller ([], [],''', daughterTaskString, ''')'];

    elseif (daughterDispatcher.doSpawnMatlabExecutable)
        % A matlab executable, so just need to pass the task string
        commandString = daughterTaskString;

    else
        errror('error');
    end

    % Create local copies of all the passed optional arguments

    calcEpGoodness = true;
    plotSubDirSuffix = '';
    doAllTargets = true;
    nTargets = length(rawDataStruct);
    targetList = [1:nTargets];
    if (~isempty(varargin))
        % Find which optional arguments are given
        for iArg = 1 : length(varargin)
            if(isa(varargin{iArg}, 'char'))
                plotSubDirSuffix = varargin{iArg};
            elseif(isa(varargin{iArg}, 'numeric'))
                doAllTargets = false;
                if(varargin{iArg} ~= 0)
                    targetList = varargin{iArg};
                    nTargets = length(targetList);
                end
            elseif(isa(varargin{iArg}, 'logical'))
                calcEpGoodness = varargin{iArg};
            end
        end
    end

    disp(['*~*~*~*~*~* Dispatching ', daughterTaskString, '...*~*~*~*~*~*']);

    [goodnessStruct] =  daughterDispatcher.dispatch (commandString, daughterTaskString, 'rawDataStruct', 'correctedDataStruct', 'cadenceTimes', ...
        'pdcModuleParameters', 'goodnessMetricConfigurationStruct', 'doNormalizeFlux', 'doSavePlots', 'plotTitleIntro', 'targetList', 'plotSubDirSuffix', ...
        'calcEpGoodness');

    disp(['*~*~*~*~*~* Finished dispatching ', daughterTaskString, '*~*~*~*~*~*']);

end % function pdc_goodness_metric_dispatcher 

%*************************************************************************************************************
% Blue Box SPSD Outlier Harmonics dispatcher

function [localTargetDataStruct, alerts, fluxCorrectionStruct, pdcDebugObject, ...
    targetsToUseForBasisVectorsAndPriors] = pdc_blue_box_spsd_outlier_harmonics_dispatcher (daughterDispatcher, ...
    localTargetDataStruct, ...
    pdcInputObject, ...
    uberDiagnosticStruct, ...
    cbvBlobStruct, ...
    mapBlobStruct, ...
    localMotionPolyStruct, ...
    fluxCorrectionStruct, ...
    pdcDebugObject, ...
    pdcInternalConfig, ...
    localConfigurationStruct, ...
    spsdBlobStruct, ...
    dataAnomalyIndicators, ...
    nonbsMapConfigurationStruct, ...
    alerts)


    daughterTaskString = 'blueBox';

    % Determine if this is a matlab session or matlab executable. this determines the command string
    if (~daughterDispatcher.dispatchingEnabled)
        % Just call map_controller , bypassing the dispatch function
        [localTargetDataStruct, alerts, fluxCorrectionStruct, pdcDebugObject, ...
            targetsToUseForBasisVectorsAndPriors] = pdc_blue_box_spsd_outlier_harmonics (daughterDispatcher, ...
            localTargetDataStruct, ...
            pdcInputObject, ...
            uberDiagnosticStruct, ...
            cbvBlobStruct, ...
            mapBlobStruct, ...
            localMotionPolyStruct, ...
            fluxCorrectionStruct, ...
            pdcDebugObject, ...
            pdcInternalConfig, ...
            localConfigurationStruct, ...
            spsdBlobStruct, ...
            dataAnomalyIndicators, ...
            nonbsMapConfigurationStruct, ...
            alerts);

        return;

    elseif (daughterDispatcher.doSpawnMatlabSession)
        % A matlab session, so call pdc_matlab_controller with the task string
        commandString = ['[~] = pdc_matlab_controller ([], [],''', daughterTaskString, ''')'];

    elseif (daughterDispatcher.doSpawnMatlabExecutable)
        % A matlab executable, so just need to pass the task string
        commandString = daughterTaskString;

    else
        errror('error');
    end

    disp(['*~*~*~*~*~* Dispatching ', daughterTaskString, '...*~*~*~*~*~*']);

    [localTargetDataStruct, alerts, fluxCorrectionStruct, pdcDebugObject, targetsToUseForBasisVectorsAndPriors] = ...
        daughterDispatcher.dispatch (commandString, daughterTaskString, ...
            'daughterDispatcher', ... 
            'localTargetDataStruct', ...
            'pdcInputObject', ...
            'uberDiagnosticStruct', ...
            'cbvBlobStruct', ...
            'mapBlobStruct', ...
            'localMotionPolyStruct', ...
            'fluxCorrectionStruct', ...
            'pdcDebugObject', ...
            'pdcInternalConfig', ...
            'localConfigurationStruct', ...
            'spsdBlobStruct', ...
            'dataAnomalyIndicators', ...
            'nonbsMapConfigurationStruct', ...
            'alerts');

    disp(['*~*~*~*~*~* Finished dispatching ', daughterTaskString, '*~*~*~*~*~*']);

end % function pdc_blue_box_spsd_outlier_harmonics_dispatcher

%*************************************************************************************************************
% Green box Map Proper

function [localTargetDataStruct, alerts, fluxCorrectionStruct, variabilityStruct, pdcDebugObject] = ...
    pdc_green_box_map_proper_dispatcher (daughterDispatcher, ...
        localTargetDataStruct, ...
        pdcInputObject, ...
        cbvBlobStruct, ...
        uberDiagnosticStruct, ...
        mapBlobStruct, ...
        localMotionPolyStruct, ...
        fluxCorrectionStruct, ...
        pdcDebugObject, ...
        pdcInternalConfig, ...
        nonbsMapConfigurationStruct, ...
        targetsToUseForBasisVectorsAndPriors, ...
        bsMapConfigurationStructArray, ...
        alerts)


    daughterTaskString = 'greenBox';

    % Determine if this is a matlab session or matlab executable. this determines the command string
    if (~daughterDispatcher.dispatchingEnabled)
        % Just call map_controller , bypassing the dispatch function
        [localTargetDataStruct, alerts, fluxCorrectionStruct, variabilityStruct, pdcDebugObject] = ...
            pdc_green_box_map_proper (daughterDispatcher, ...
                localTargetDataStruct, ...
                pdcInputObject, ...
                cbvBlobStruct, ...
                uberDiagnosticStruct, ...
                mapBlobStruct, ...
                localMotionPolyStruct, ...
                fluxCorrectionStruct, ...
                pdcDebugObject, ...
                pdcInternalConfig, ...
                nonbsMapConfigurationStruct, ...
                targetsToUseForBasisVectorsAndPriors, ...
                bsMapConfigurationStructArray, ...
                alerts);

        return;

    elseif (daughterDispatcher.doSpawnMatlabSession)
        % A matlab session, so call pdc_matlab_controller with the task string
        commandString = ['[~] = pdc_matlab_controller ([], [],''', daughterTaskString, ''')'];

    elseif (daughterDispatcher.doSpawnMatlabExecutable)
        % A matlab executable, so just need to pass the task string
        commandString = daughterTaskString;

    else
        errror('error');
    end

    disp(['*~*~*~*~*~* Dispatching ', daughterTaskString, '...*~*~*~*~*~*']);

    [ localTargetDataStruct, alerts, fluxCorrectionStruct, variabilityStruct] =  ...
        daughterDispatcher.dispatch (commandString, daughterTaskString, ...
            'daughterDispatcher', ... 
            'localTargetDataStruct', ...
            'pdcInputObject', ...
            'cbvBlobStruct', ...
            'uberDiagnosticStruct', ...
            'mapBlobStruct', ...
            'localMotionPolyStruct', ...
            'fluxCorrectionStruct', ...
            'pdcDebugObject', ...
            'pdcInternalConfig', ...
            'nonbsMapConfigurationStruct', ...
            'targetsToUseForBasisVectorsAndPriors', ...
            'bsMapConfigurationStructArray', ...
            'alerts');

    disp(['*~*~*~*~*~* Finished dispatching ', daughterTaskString, '*~*~*~*~*~*']);

end % function pdc_blue_box_spsd_outlier_harmonics_dispatcher

%*************************************************************************************************************
% pdc_create_output_struct

function pdcOutputsStruct = ...
    pdc_create_output_struct_dispatcher(daughterDispatcher, pdcInputObject,localTargetDataStruct,harmonicTimeSeries,outlieredFluxSeries,...
                                fluxCorrectionStruct, alerts, goodnessStruct, variabilityStruct, gapFilledCadenceMidTimestamps);

    daughterTaskString = 'createOutputs';

    % Determine if this is a matlab session or matlab executable. this determines the command string
    if (~daughterDispatcher.dispatchingEnabled)
        % Just call map_controller , bypassing the dispatch function
        pdcOutputsStruct = ...
            pdc_create_output_struct(pdcInputObject,localTargetDataStruct,harmonicTimeSeries,outlieredFluxSeries,...
                                        fluxCorrectionStruct, alerts, goodnessStruct, variabilityStruct, gapFilledCadenceMidTimestamps);

        return;

    elseif (daughterDispatcher.doSpawnMatlabSession)
        % A matlab session, so call pdc_matlab_controller with the task string
        commandString = ['[~] = pdc_matlab_controller ([], [],''', daughterTaskString, ''')'];

    elseif (daughterDispatcher.doSpawnMatlabExecutable)
        % A matlab executable, so just need to pass the task string
        commandString = daughterTaskString;

    else
        errror('error');
    end

    disp(['*~*~*~*~*~* Dispatching ', daughterTaskString, '...*~*~*~*~*~*']);

    [pdcOutputsStruct] =  daughterDispatcher.dispatch (commandString, daughterTaskString, 'pdcInputObject', 'localTargetDataStruct', ...
                            'harmonicTimeSeries', 'outlieredFluxSeries', 'fluxCorrectionStruct', ...
                            'alerts', 'goodnessStruct', 'variabilityStruct', 'gapFilledCadenceMidTimestamps');

    disp(['*~*~*~*~*~* Finished dispatching ', daughterTaskString, '*~*~*~*~*~*']);

end % function pdc_create_output_struct_dispatcher

%*************************************************************************************************************
% presearch_data_conditioning_map

function [pdcOutputsStruct] = presearch_data_conditioning_map_dispatcher (pdcInputObject, uberDiagnosticStruct, daughterDispatcher)

    daughterTaskString = 'presearch_data_conditioning_map';

    % Determine if this is a matlab session or matlab executable. this determines the command string
    if (~daughterDispatcher.dispatchingEnabled)
        % Just call map_controller , bypassing the dispatch function
        [ pdcOutputsStruct ] = presearch_data_conditioning_map(pdcInputObject, uberDiagnosticStruct, daughterDispatcher);

        return;

    elseif (daughterDispatcher.doSpawnMatlabSession)
        % A matlab session, so call pdc_matlab_controller with the task string
        commandString = ['[~] = pdc_matlab_controller ([], [],''', daughterTaskString, ''')'];

    elseif (daughterDispatcher.doSpawnMatlabExecutable)
        % A matlab executable, so just need to pass the task string
        commandString = daughterTaskString;

    else
        errror('error');
    end

    disp(['*~*~*~*~*~* Dispatching ', daughterTaskString, '...*~*~*~*~*~*']);

    [pdcOutputsStruct] =  daughterDispatcher.dispatch (commandString, daughterTaskString, 'pdcInputObject', 'uberDiagnosticStruct', 'daughterDispatcher');

    disp(['*~*~*~*~*~* Finished dispatching ', daughterTaskString, '*~*~*~*~*~*']);

end % function presearch_data_conditioning_map_dispatcher 

%*************************************************************************************************************
% bs_controller_split

function [targetDataStructBands] = bs_controller_split_dispatcher (daughterDispatcher, localTargetDataStruct , ...
                                                                    bandSplittingConfigurationStruct, bsDiagnosticStruct)

    daughterTaskString = 'bs_controller_split';

    % Determine if this is a matlab session or matlab executable. this determines the command string
    if (~daughterDispatcher.dispatchingEnabled)
        [targetDataStructBands] = bs_controller_split( localTargetDataStruct, bandSplittingConfigurationStruct, bsDiagnosticStruct );

        return;

    elseif (daughterDispatcher.doSpawnMatlabSession)
        % A matlab session, so call pdc_matlab_controller with the task string
        commandString = ['[~] = pdc_matlab_controller ([], [],''', daughterTaskString, ''')'];

    elseif (daughterDispatcher.doSpawnMatlabExecutable)
        % A matlab executable, so just need to pass the task string
        commandString = daughterTaskString;

    else
        errror('error');
    end

    disp(['*~*~*~*~*~* Dispatching ', daughterTaskString, '...*~*~*~*~*~*']);

    [targetDataStructBands] =  daughterDispatcher.dispatch (commandString, daughterTaskString, 'localTargetDataStruct', 'bandSplittingConfigurationStruct', ...
                                                        'bsDiagnosticStruct');

    disp(['*~*~*~*~*~* Finished dispatching ', daughterTaskString, '*~*~*~*~*~*']);

end % function bs_controller_split_dispatcher 

end % static methods

end % classdef  pdcDispatchWrapperClass
