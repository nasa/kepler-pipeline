% function [figureHandles, inputsStruct, outputsStruct, mapResultsStruct] = ...
%           plot_corrected_flux_from_this_task_directory (targetIndicesToPlot, keplerIdsToPlot, nRandomTargets,
%           figureHandles, varargin)
%
% Plots PDC results for <targetIndicesToPlot> selection of targets. Will load in all the task file structs if
% uberPdcStruct is not given. This function should be called in the task directory to analyze.
%
% If you want to keep the PDC structures then save with uberPdcStruct. Then subsequent calls do not need to load the data structures is uberPdcStruct is passed
% back in.
%
% This function calls plot_corrected_flux
%
%
%************************************************************************************************************
% Inputs:
%   targetIndicesToPlot     -- [integer array] Target indices for targets to plot ([] if do not use, 
%                                               'all' means plot all targets)
%   keplerIdsToPlot         -- [integer array] Kepler Ids to plot ([] means do not use)
%   nRandomTargets          -- [integer] if given (not []) then randomly select this many targets ( 0 if do not use)
%   figureHandles           -- [int array OPTIONAL] fingure handles to use for plots. If called with [] then new figures generated.
%   uberPdcStruct           -- [struct OPTIONAL] The struct containing all inputs and outputs to use:
%                               .inputsStruct    
%                               .outputsStruct   
%                               .mapResultsStruct -- cell containing mapResultsStruct for each band and regular run
%
%************************************************************************************************************
% Outputs:
%   figureHandles       -- [int array] fingure handles used for plots.
%   uberPdcStruct       -- [struct OPTIONAL] The struct containing all inputs and outputs thjat were loaded:
%
%************************************************************************************************************
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

function [figureHandles, varargout] = ...
                plot_corrected_flux_from_this_task_directory (targetIndicesToPlot, keplerIdsToPlot, nRandomTargets, varargin)

%persistent KOI inputsStruct outputsStruct mapResultsStruct;

KOI = [];

% If the structs are passed in then do not load from file
if ((nargin - 3) > 0)
    figureHandles = varargin{1};
    if ((nargin - 4) > 0)
        inputsStruct            = varargin{2}.inputsStruct;
        outputsStruct           = varargin{2}.outputsStruct;
        mapResultsStruct        = varargin{2}.mapResultsStruct;
        spsdCorrectedFluxStruct = varargin{2}.spsdCorrectedFluxStruct;
    else
        [KOI, inputsStruct, outputsStruct, mapResultsStruct, spsdCorrectedFluxStruct] = load_the_Data;
    end
else
    figureHandles = [];
    [KOI, inputsStruct, outputsStruct, mapResultsStruct, spsdCorrectedFluxStruct] = load_the_Data;
end

% If we are using the new PDC inputs with channelDataStruct then we need to combine the channel-wise targetDataStructs into one big targetDataStruct
if (isfield(inputsStruct, 'channelDataStruct') && isfield(inputsStruct.channelDataStruct(1), 'targetDataStruct'))
    inputsStruct = combine_targetDataStructs (inputsStruct);
end

% Use the shorter set of inputsStruct and outputsStruct to find the total number of targets
% This is for when we do test runs with a truncated number of targets
nTotInputTargets = length(inputsStruct.targetDataStruct);
nTotOutputTargets = length(outputsStruct.targetResultsStruct);
nTotTargets = min(nTotInputTargets, nTotOutputTargets); 

% Two options, automatically randomly pick targets or use given targets
targetList = [];
if (nRandomTargets > 0)
    targetList = randperm(nTotTargets);
    targetList = targetList(1:min(nRandomTargets, length(targetList)));
end
if (~isempty(targetIndicesToPlot))
    if (strcmp(targetIndicesToPlot, 'all'));
        % If want to plot all targets then do so
        targetList = [1:nTotTargets];
    else
        % Get rid of targets that do not exist
        targetList = [targetIndicesToPlot(targetIndicesToPlot < nTotTargets)' targetList];
        if (isempty([targetIndicesToPlot < nTotTargets]))
            display(['Your target indices are all too high, number of targets = ', num2str(nTotTargets)])
            return;
        end 
    end
end
if (~isempty(keplerIdsToPlot))
    keplerIds = [inputsStruct.targetDataStruct.keplerId];
    [~,loc] = ismember(keplerIdsToPlot, keplerIds);
    % get rid of targets not found in task
    if (any(loc==0))
        display('WARNING: one or more keplerIds not found in task!');
        display(['Offending keplerIds: ', num2str(keplerIdsToPlot(loc==0))])
        loc = loc(loc~=0);
    end
    targetList = [loc targetList];
end

% only plot targets if any actually made it to the targetList
if (~isempty(targetList))
    titleString = [];
    harmonicTimeSeries = [];
    [figureHandles] = plot_corrected_flux(inputsStruct, outputsStruct, mapResultsStruct, spsdCorrectedFluxStruct, targetList, harmonicTimeSeries, ...
                                        titleString, KOI, figureHandles);
end

% Show alerts
display(' ')
display('************** ALERTS FOR THIS MOD.OUT *******************');
if (~isempty(outputsStruct.alerts))
    outputsStruct.alerts.message
else
    display('No alerts for this module output!');
end
display('************** END ALERTS *******************');

% Return the loaded structs if requested
if (nargout > 1)
    uberPdcStruct.inputsStruct            = inputsStruct;
    uberPdcStruct.outputsStruct           = outputsStruct;
    uberPdcStruct.mapResultsStruct        = mapResultsStruct;
    uberPdcStruct.spsdCorrectedFluxStruct = spsdCorrectedFluxStruct;
    varargout{1} = uberPdcStruct;
end

end

%************************************************************************************************************
function [KOI, inputsStruct, outputsStruct, mapResultsStruct, spsdCorrectedFluxStruct] = load_the_Data ()
    % load all the data (this takes some time, 100s of MB to load)
    disp(['Loading data from task directory ', pwd, ' ...']);

    if (~exist('pdc-inputs-0.mat', 'file'))
        error('This does not appear to be a task directory! Do you even know what you are doing?')
    end

    % KOI is just an exmpty set
   %load('/path/to/PDC_Experiments/VVtools/VV8.0/directories/KOI_VV8p0.mat')
   %disp('KOI loaded');
    KOI = [];

    load('pdc-inputs-0.mat');
    disp('inputsStruct loaded');

    load('pdc-outputs-0.mat');
    disp('outputsStruct loaded');

    % Load in all mapResultsStructs for each band and non-msMAP
    mapResultsFiles = dir('./mapResultsStruct_*');
    nStructs = length(mapResultsFiles);
    mapResultsCell = cell(nStructs,1);
    for iStruct = 1 : nStructs
        mapResultsStruct = load(mapResultsFiles(iStruct).name);
        name = fieldnames(mapResultsStruct);
        mapResultsCell{iStruct} = getfield(mapResultsStruct, name{1});
    end
    mapResultsStruct = mapResultsCell;
    disp('mapResultsStruct loaded');

    % Load the spsdCorrectedFluxStruct
    % The structure used to be saved with the end *Object since it came form an object. But the actual thing being saved is a struct so it's now called *struct
    if (exist('spsdCorrectedFluxStruct_1.mat', 'file'));
        spsdCorrectedFluxStruct = load('spsdCorrectedFluxStruct_1.mat');
        spsdCorrectedFluxStruct = spsdCorrectedFluxStruct.spsdCorrectedFluxStruct;
        disp('spsdCorrrectedFluxStruct loaded');
    elseif (exist('spsdCorrectedFluxObject_1.mat', 'file'));
        spsdCorrectedFluxStruct = load('spsdCorrectedFluxObject_1.mat');
        spsdCorrectedFluxStruct = spsdCorrectedFluxStruct.spsdCorrectedFluxObject;
        disp('spsdCorrrectedFluxStruct loaded');
    else
        spsdCorrectedFluxStruct = [];
    end
end

%************************************************************************************************************
% If using new multi-channel data this will combine the individual channel targetDataStructs into one upper-level targetDataStruct
function [inputsStruct] = combine_targetDataStructs (inputsStruct)

    inputsStruct.ccdModule = -1;
    inputsStruct.ccdOutput = -1;

    inputsStruct.targetDataStruct = [];
    for iChannel = 1 : length(inputsStruct.channelDataStruct)
        % Add in the module and output to each target
        for iTarget = 1 : length(inputsStruct.channelDataStruct(iChannel).targetDataStruct)
            inputsStruct.channelDataStruct(iChannel).targetDataStruct(iTarget).ccdModule = inputsStruct.channelDataStruct(iChannel).ccdModule;
            inputsStruct.channelDataStruct(iChannel).targetDataStruct(iTarget).ccdOutput = inputsStruct.channelDataStruct(iChannel).ccdOutput;
        end

        inputsStruct.targetDataStruct = [inputsStruct.targetDataStruct inputsStruct.channelDataStruct(iChannel).targetDataStruct];

    end

end

