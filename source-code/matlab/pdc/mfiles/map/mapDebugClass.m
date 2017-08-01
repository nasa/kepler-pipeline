%% classdef mapDebugClass
%
% Used for debugging and V&V of MAP as implemented in PDC. 
%
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

classdef mapDebugClass < handle & classIoTools

    properties (Constant)
        NODEBUGLEVEL         = 0;
        VERBOSEDEBUGLEVEL    = 1;
        PLOTTINGDEBUGLEVEL   = 2;
        SAVETOFILEDEBUGLEVEL = 3;

        MINDEBUGLEVEL = 0;
        MAXDEBUGLEVEL = 3;
        
        validComponents = { 'mapController', ...
                            'basisVectors', ...
                            'stellarVariability', ... 
                            'compileKicData', ...
                            'compileCentroidData', ...
                            'robustFit', ...
                            'generatePrior', ...
                            'generateConditional',...
                            'generatePosterior',...
                            'maximizePosterior', ...
                            'pou', ...
                            'compileResults', ...
                            'resultantPlots'};
    end

    properties (GetAccess = 'public', SetAccess = 'public')
        % Here are the bebug levels for each component
        % If value is 3 then any plots will be saved in task file subdirectory
        mapController       = 1;
        compileKicData      = 1; % No static properties so have to use numbers!
        compileCentroidData = 1;
        stellarVariability  = 3;
        basisVectors        = 3;
        robustFit           = 1;
        generatePrior       = 1;
        generateConditional = 1;
        generatePosterior   = 1;
        maximizePosterior   = 1;
        pou                 = 1;
        compileResults      = 3;
        resultantPlots      = 3;

        applyMapToAllTargets = true; % If this is FALSE, we limit the number of targets run
        %   through map to only those in targetsToAnalyze (to speed up runs). If TRUE then apply MAP
        %   on all targets (i.e. a pipeline run)

        doFindKicDatabase = false; % For pre-8.0 data we need the kic information, should I look for it?
        doStopOnError     = false; % Stop execution and enter debug mode on error

        runLabel    = '' % What to say at beginning of warning message and filenames
    end

    %*******************************************************************************
    % These sections are for selecting targets to plot and analyze
    % The default values are for a pipeline run.
    properties (GetAccess = 'public', SetAccess = 'public')
        quickDiagnosticRun           = false; % If true then no figures and use specified targets
        debugRun                     = false; % If true then use custom debug setting in map_controller.m
        interactive = false; % if true then MAP will pause at certaint plots before
                %   they are refreshed or MAP moves on to next step
        displayWaitbar = false;               % If true then display the waitbar (bad to do so on headless cluster)
        doAnalyzeReducedSetOfTargets = true;  % Select a small subset of targets to analyze and plot
        doSpecificTargets            = true;  % Analyze the set of targets in specificKeplerIdsToAnalyze
        doRandomTargets              = true;  % Analyze a random set of target
        nRandomTargetsToAnalyze      = 0;     % Number of random targets to analyze per module output
        specificKeplerIdsToAnalyze   = [];    % Logical array of specific targets to analyze
        justDoVariable               = false; % When selecting random targets, only select variable
        justDoQuiet                  = false; % When selecting random targets, only select quiet
        justDoNo3Vec                 = false; % When selecting random targets, only select targets where ra,dec or kepMag not present
        justDoEclipsingBinaries      = false; % When selecting random targets, only select Eclipsing Binaries
        doFigures                    = true;  % Generate figures, save if doSaveFigures and display if doVisibleFigures
        doVisibleFigures             = true;  % Suppress plotting to display (just save to file)
        doSaveFigures                = true;  % Save plots to subdirectory
        doCloseAfterSaveFigures      = false; % Close plots after saving to subdirectory
        saveFigureDirectory          = './';  % Save data in subdirectories to the task file directory
        saveFigureFormat             = 'fig';
    end

    properties (GetAccess = 'public', SetAccess = 'public')
        targetsToAnalyze    = []; % Logical array of targets to analyze (both specific and random)
        nTargetsToAnalyze;
    end

    properties (GetAccess = 'public', SetAccess = 'private')
        randomSeed;    % Set by mapParams.randomStreamSeed
        randomStream;  % Used for selecting targets
        waitbarHandle = nan;
    end
    %*******************************************************************************

%*******************************************************************************
%*******************************************************************************
    methods
        %***
        % Constructor
        function obj = mapDebugClass(randomStreamSeed)

            if (randomStreamSeed == 0)
                % Initiate the random seed with system clock
                obj.randomSeed = int32(rem(now,1)*1e9);
                obj.randomStream = RandStream('mt19937ar', 'Seed', obj.randomSeed);
            else
                % Use the specified integer
                obj.randomSeed = randomStreamSeed;
                obj.randomStream = RandStream('mt19937ar', 'Seed', obj.randomSeed);
            end
        end

        %***
        % Setter functions
        % Restricts what values properties can be set to
        function obj = set (obj, property, setValue)
    
            % See if we are setting a component debug level
            componentIndex = strcmp(property, obj.validComponents);

            if (any(componentIndex))
                % Then check if setValue is within debug level range
                if (~obj.within_debug_range(setValue))
                    display('ERROR: debug level out of range, value NOT set');
                    return;
                end
            end

            % Set the value
            % Is there a better way to do this?
            eval(char(strcat('obj.', property, '= ', num2str(setValue))));
        end

        % Stop on all errors?
        function obj = set.doStopOnError(obj, value)
            if (~islogical(value))
                display ('DEBUG ERROR: doStopOnError is a logical')
                return;
            end
            
            if (value)   
                obj.doStopOnError = true;
                % Stop execution and enter debug mode on error
                dbstop if error;
            else
                obj.doStopOnError = false;
            end

        end

        %***
        % Setup to select a subset of targets to analyze and plot
        function setup_reduced_set_of_targets (obj, mapData, mapInput)

            if (obj.doAnalyzeReducedSetOfTargets)
                display('Selecting targets to analyze');
            else
                display('No specific targets will be analyzed.');
                return;
            end

            obj.select_targets (mapData, mapInput);
        end

        %***
        % Query if debug level is at specified level for the specified component
        function doIt = query(obj, component, level)
        
            debugValue = obj.component_value(component);

            if (debugValue >= level)
                doIt = true;
            else
                doIt = false;
            end
        end

        %***
        % Query if plotting is being performed (either visible or invisible)
        function doPlot = query_do_plot(obj, component)
        
            debugValue = obj.component_value(component);

            if (debugValue >= obj.PLOTTINGDEBUGLEVEL && obj.doFigures)
                doPlot = true;
            else
                doPlot = false;
            end
        end

        %***
        % Display the text string if the debug level is high enough for the specified component
        function [] = display(obj, varargin)
            
            if (isempty(varargin))
                return;
            elseif (length(varargin) == 2)
                component = char(varargin(1));
                string = char(varargin(2));
            else
                display('Can only display debug object with zero or 2 arguments')
            end

            debugValue = obj.component_value(component);

            if (debugValue >= obj.VERBOSEDEBUGLEVEL)
                disp(string);
            end
        end
        %***
        % Pause function will query the state of <interactive>, if true then will pause execution
        % HOWEVER, if <doVisibleFigures> = false, then DO NOT pause (nothing to look at!)
        % Also displays <string> (Ignoring debug level for components)
        function [] = pause (obj, string)
            if (nargin >= 2 && obj.doVisibleFigures && obj.interactive)
                disp(string);
            end
            if (obj.interactive && obj.doVisibleFigures)
                pause;
            end
        end
        %***
        % Display a waitbar only if displayWaitbar = true
        % If waitbar does not exist yet it is created
        % When waitbar reaches > %99.999 it is displayed for 100 milliseconds then closed, 
        % unless optional <hold> is true
        function [] = waitbar (obj, percentage, string, varargin)
            if (~obj.displayWaitbar)
                return
            end

            if(isnan(obj.waitbarHandle))
                obj.waitbarHandle = waitbar(percentage, string);
            else
                waitbar(percentage, obj.waitbarHandle, string);
            end

            % Close waitbar if realy near the end and not requested to be held
            if ((~isempty(varargin) && ~varargin{1}) && percentage > 0.99999)
                pause(0.1);
                close(obj.waitbarHandle)
                obj.waitbarHandle = nan;
            end
        end

        function close_waitbar (obj)
            if(~isnan(obj.waitbarHandle))
                pause(0.1);
                close(obj.waitbarHandle)
                obj.waitbarHandle = nan;
            end
        end
    end
%*******************************************************************************
% These methods specific to figures
    methods
        %***
        % Create plot window and return figure handle
        % If obj.doVisibleFigure == TRUE then display
        function [figureHandle] = create_figure (obj)
        
            % Do nothing if figures are turned off
            if (~obj.doFigures)
                figureHandle = NaN;
                return;
            end

            % If visiblePlots == false then suppress displaying figure
            if (obj.doVisibleFigures)
                figureHandle = figure;
            else
                figureHandle = figure('Visible', 'off');
            end
        end

        %***
        % Select a figure using the figure handle, if visibility suppressed then figure not
        % displayed
        function [figureHandle] = select_figure (obj, figureHandle)

            % Do nothing if figures are turned off
            if (~obj.doFigures)
                return;
            end

            % If visiblePlots == false then suppress displaying figure
            if (obj.doVisibleFigures)
                % Select the figure, make it visible and on top of other
                % figures
                figure(figureHandle);
            else
                % Make the figure current but do not make it visible or
                % change stacking
                set(0,'CurrentFigure', figureHandle)
            end
        end

        %***
        % Save the figure to file named <filename> in the <component> to saveFigureDirectory 
        % IF obj.doSaveFigure == TRUE;
        % NOTE: if the figure is invisible then the figure will be saved invisible. When the figure
        % is opened later it must be made visible manually with either
        % 'openfig('file.fig','new','visible')' or 'set(fig,'visible','on')'
        function [] = save_figure (obj, figureHandle, component, filename)

            % Do nothing if figures are turned off
            if (~obj.doFigures)
                return;
            end

            if (obj.doSaveFigures && obj.query(component, obj.SAVETOFILEDEBUGLEVEL))
                % check if path exist, if not create it
                directory = fullfile(obj.saveFigureDirectory, ['map_plots/', obj.runLabel, '/']);
                if (~exist(directory, 'dir'))
                    mkdir(directory);
                end
                fullFilename = fullfile(directory, filename);
                saveas (figureHandle, fullFilename, obj.saveFigureFormat);
                if (obj.doCloseAfterSaveFigures)
                    close(figureHandle);
                end
            end
        end
                
    end % Figure methods

%*******************************************************************************
% Methods associated with selecting targets
    methods(Access = 'private')
        % This will select which targets to use for analysis and plotting.
        % This cannot be called by the public. It is only set when doAnalyzeReducedSetOfTargets is
        % set to true.
        function select_targets(obj, mapData, mapInput)

            obj.targetsToAnalyze = false(mapData.nTargets,1);

            % Must select at least one: doSpecificTargets or doRandomTargets
            if (~obj.doSpecificTargets & ~obj.doRandomTargets)
                display('DEBUG: must select at least one: doSpecificTargets or doRandomTargets');
                display('No targets will be analyzed!');
                obj.doAnalyzeReducedSetOfTargets = false;
            end


            % Two parts:  1) specific targets, 2) random targets

            %***
            % 1) Specific Targets
            if (obj.doSpecificTargets)
                % Search KIC data for kepler IDs desired
                [~, specificTargets, ~] = ...
                        intersect(mapData.kic.keplerId, obj.specificKeplerIdsToAnalyze);
                obj.targetsToAnalyze(specificTargets) = true;
            end

            %***
            % 1) Random Targets
            if (obj.doRandomTargets)
                % Random selection of targets

                % Check if variability has already been calculated
                if (isempty(mapData.variability) && ...
                                (obj.justDoVariable || obj.justDoQuiet))
                    error('SELECT_TARGETS: Must have already calculated stellar variability');
                end

                % Setup which targets to pick randomly from
                validTargets = true(mapData.nTargets,1);

                % Remove specific targets selected in 1) above
                validTargets(obj.targetsToAnalyze) = false;

                % Select just quiet or variable targets & etc...
                if (obj.justDoVariable + obj.justDoQuiet + obj.justDoNo3Vec + obj.justDoEclipsingBinaries > 1)
                    error ('SELECT_TARGETS: can do only one of justDoVariable, justDoQuiet, justDoNo3Vec ...')
                elseif (obj.justDoVariable)
                    variableTargets = mapData.variability >= mapInput.mapParams.variabilityCutoff;
                    validTargets(~variableTargets) = false;
                elseif (obj.justDoQuiet)
                    quietTargets = mapData.variability < mapInput.mapParams.variabilityCutoff;
                    validTargets(~quietTargets) = false;
                elseif (obj.justDoNo3Vec)
                    validTargets(~mapData.targetsWhereKicDataNotFound) = false;
                elseif (obj.justDoEclipsingBinaries)
                    useHardCatalogAsBackup = true;
                    ebHere = pdcTransitClass.identify_eclipsing_binaries (mapInput.targetDataStruct, useHardCatalogAsBackup);
                    validTargets(~ebHere) = false;
                end
            
                nValidTargets = length(find(validTargets));
                if (nValidTargets < obj.nRandomTargetsToAnalyze)
                    display('SELECT_TARGETS: not enough targets available to pick from, selecting all available')
                    obj.targetsToAnalyze(validTargets) = true;
                    obj.nTargetsToAnalyze = length(find(obj.targetsToAnalyze));
                    return
                end

                targetSet = randperm (obj.randomStream, nValidTargets);
                targetSet = targetSet(1:obj.nRandomTargetsToAnalyze);
                validTargetIndices = find(validTargets);
                targetIndicesToAnalyze = validTargetIndices(targetSet);

                obj.targetsToAnalyze(targetIndicesToAnalyze) = true;
            end

            obj.nTargetsToAnalyze = length(find(obj.targetsToAnalyze));

            if(~any(obj.targetsToAnalyze))
                obj.doAnalyzeReducedSetOfTargets = false;
            end

        end % function select_targets

    end % selecting targets methods

%*******************************************************************************
% Methods associated with converting the properties to and from a struct

    methods (Static = true)

        %********************************************************************************
        % function  obj = construct_from_struct (debugStruct)
        %
        % This will construct the debug object using the data stored in debugStruct which was saved
        % in mapResultsStruct.
        %
        % Note: be sure to update this if new properties are added to the debug class.
        %

        function obj = construct_from_struct (debugStruct)

            % First create a "naked" debug object with default properties (except for randomStream)
            obj = mapDebugClass(debugStruct.randomSeed);


            % Now populate the object properites with those in debugStruct
            obj = obj.set_properties_with_struct_values (debugStruct);

        end

    end % static methods

%*******************************************************************************
% Other private methods
    methods (Access = 'private')
        % Check if value is within debug range
        function [isWithin] = within_debug_range (obj, value)
            if (value >= obj.MINDEBUGLEVEL && value <= obj.MAXDEBUGLEVEL)
                isWithin = true;
            else
                isWithin = false;
            end
        end

        % Returns the value of the component
        function [value] = component_value (obj, component)
            
            % Find the component object property name
            componentIndex = strcmp(component, obj.validComponents);

            % Check if one and only one component was found
            nComponentsFound = length(find(componentIndex));
            if (nComponentsFound < 1)
                error('Debug Error: No debug component of this name');
            elseif (nComponentsFound > 1)
                error('Debug Error: Looks like there are two components of the same name?!?')
            end

            % Evaluate the character string and find the value for this component
            value = eval(char(strcat('obj.', obj.validComponents(componentIndex))));

        end
                
    end % other private methods

end % classdef
