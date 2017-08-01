function run_pa_trunc(taskFileDirectory, spiceFileDirectory, ...
    startingSubTaskNumber, endingSubTaskNumber, truncConfigStruct)
%**************************************************************************
% run_pa_trunc(taskFileDirectory, spiceFileDirectory, startingSubTaskNumber)
%**************************************************************************
% Run the Matlab portion of long-cadence PA for an existing directory
% structure. Truncate inputs for fast testing. All input files and subtask
% directories are assumed to exist in taskFileDirectory. All input
% structures are assumed to be in the SOC 9.1 (or later) format.
%
%
% INPUTS
%     taskFileDirectory     : A string specifying the root task directory,
%                             under which subtask directories are found.
%     spiceFileDirectory    : A string specifying the path where spice
%                             files are to be found. If empty or not
%                             provided, do nothing. 
%     startingSubTaskNumber : Begin the processing with this subtask
%                             (default = 0).
%     endingSubTaskNumber   : Stop after this subtask (default is last
%                             subtask in taskFileDirectory)  
%     truncConfigStruct     : Configuration parameters for truncating PA
%     |                       inputs. If not provided, a default truncation
%     |                       configuration is used. If empty, do nothing.
%     |
%     |-.truncateInputsEnabled
%     |-.nBackgroundPixels
%     |-.maxNumPpaTargetsPerSubtask
%     |-.ppaTargetCount
%     |-.maxTargetsPerSubtask
%      -.nCadences
%
% OUTPUTS
%     The variables inputsStruct (with spice files updated) and
%     outputsStruct are saved to the files 'pa-inputs-0.mat' and
%     'pa-outputs-0.mat', respectively, in each subtask directory.
%
% USAGE EXAMPLES
%
%     Run all subtasks using the default truncation of inputs. Do not
%     modify the SPICE file directory:
%
%         >> run_pa_trunc(taskDir)
% 
%     Run all subtasks without truncating inputs or changing the SPICE file
%     directory:
%
%         >> run_pa_trunc(taskDir, [], 0, [])
%
%     Starting with subtask 3, apply the default truncation and look for
%     spice files in 'spiceDir':
%
%         >> run_pa_trunc(taskDir, spiceDir, 3)
%
%     Starting with subtask 3, apply the user-defined truncation
%     configuration and look for spice files in 'spiceDir':
%
%         >> run_pa_trunc(taskDir, spiceDir, 3, truncConfig)
%
% NOTES
%     The user should edit the function modify_pa_data_struct() to add any
%     additional modifications to  PA input structures.
%**************************************************************************
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

    paInputMatFileName  = 'pa-inputs-0.mat';
    paInputBinFileName  = 'pa-inputs-0.bin';        
    paOutputMatFileName = 'pa-outputs-0.mat';

    % Specify the directory containing functions to read binary input
    % files.
    readBinaryInputsPath = ...
        fullfile(get_socCodeRoot(), 'matlab/pa/build/generated/mfiles');

    if ~exist(taskFileDirectory, 'dir')
        error('taskFileDirectory not found');
    end
    
    if ~exist('spiceFileDirectory', 'var')
        spiceFileDirectory = [];
    end
    
    if ~exist('startingSubTaskNumber', 'var')
        startingSubTaskNumber = 0;
    end
    
    if ~exist('endingSubTaskNumber', 'var')
        endingSubTaskNumber = [];
    end
    
    if ~exist('truncConfigStruct', 'var')
        truncConfigStruct = get_default_config_struct();
    end
    
    startDirectory = pwd; % Save current directory to be restored later.
    
    %----------------------------------------------------------------------
    % Create a list of subtask directories in ascending order.
    %----------------------------------------------------------------------
    contents = dir(fullfile(taskFileDirectory, 'st-*'));
    names = {contents.name};
    isdir = [contents.isdir];
    subtaskDirs = names(isdir);
    [~, remain] = strtok(subtaskDirs, '-');
    subtaskNumberStrings = strtok(remain, '-');
    subtaskNumbers = int16(str2double(subtaskNumberStrings));
    [~, sortedIndices] = sort(subtaskNumbers);
    sortedSubtaskDirs = subtaskDirs(sortedIndices);

    % Determine the last subtask number, if necessary.
    if isempty(endingSubTaskNumber)
        endingSubTaskNumber = numel(sortedSubtaskDirs) - 1;
    end
    
    % Convert 0-based subtask numbers to 1-based array indices. 
    startIndex = startingSubTaskNumber + 1;
    stopIndex  = endingSubTaskNumber   + 1; 
    
    %----------------------------------------------------------------------
    % If any Matlab input files are missing, generate them from the binary
    % files if possible. The function read_PaInputs.m is automatically
    % generated when the codebase is built. It may or may not exist and may
    % or may not be compatible with the binary input file.
    %----------------------------------------------------------------------
    for iDir = 1:numel(sortedSubtaskDirs)   
         fullInputMatFilePath = fullfile( ...
             taskFileDirectory, sortedSubtaskDirs{iDir}, paInputMatFileName);
         fullInputBinFilePath = fullfile( ...
             taskFileDirectory, sortedSubtaskDirs{iDir}, paInputBinFileName);
         
        if ~exist(fullInputMatFilePath, 'file')
            fprintf('Input file %s not found. Attempting to read %s.\n', ...
                paInputMatFileName, paInputBinFileName)
            if exist(readBinaryInputsPath, 'dir')
                addpath(readBinaryInputsPath)
                inputsStruct = read_PaInputs(fullInputBinFilePath);
                save(fullInputMatFilePath, 'inputsStruct');
                rmpath(readBinaryInputsPath);
            else
                error(['Cannot generate %s from binary file %s', ...
                    ' because read_PaInputs() is not available.'], ... 
                    paInputMatFileName, paInputBinFileName);
            end
        end
    end
    
    %----------------------------------------------------------------------
    % If input truncation is enabled determine the truncated PPA target
    % count and add it to 'truncConfigStruct'. 
    %----------------------------------------------------------------------
    if truncConfigStruct.truncateInputsEnabled == true
        ppaDirs = find_subtask_dirs_by_processing_state( ...
            taskFileDirectory, 'PPA_TARGETS' );
        ppaTargetCount = 0;
        for iDir = 1:numel(ppaDirs)
            s = load(fullfile(taskFileDirectory, ppaDirs{iDir}, ...
                paInputMatFileName));
            nPpaTargetsThisSubtask = ...
                min( [numel(s.inputsStruct.targetStarDataStruct), ...
                      truncConfigStruct.maxNumPpaTargetsPerSubtask]);
            ppaTargetCount = ppaTargetCount + nPpaTargetsThisSubtask;
        end
        truncConfigStruct.ppaTargetCount = ppaTargetCount;
    end
    
    %----------------------------------------------------------------------
    % Execute each subtask
    %----------------------------------------------------------------------
    
    for i = startIndex : stopIndex
        % Descend into subtask directory.
        cd(fullfile(taskFileDirectory, sortedSubtaskDirs{i}));
    
        % load PA inputs.
        load(paInputMatFileName);

        % Set SPICE directories and files.
        if ~isempty(spiceFileDirectory)
            inputsStruct.raDec2PixModel.spiceFileDir = spiceFileDirectory;
        end

        % Modify the input structure:
        % (1) Set SPICE directories and files.
        % (2) Truncate inputs if desired.
        % (3) Perform any additional user-defined modifications.
        inputsStruct = modify_pa_data_struct(inputsStruct, ...
            spiceFileDirectory, truncConfigStruct);

        % Run the matlab controller.
        [outputsStruct] = pa_matlab_controller(inputsStruct);
            
        % Save outputs
        save(paOutputMatFileName, 'outputsStruct');
    end
    cd(startDirectory);
    
end

%**************************************************************************
% paDataStruct = modify_pa_data_struct(paDataStruct, ...
%     spiceFileDirectory, truncConfigStruct)
%**************************************************************************
% Modify PA inputs. 
% 
% INPUTS:
%     paDataStruct       :
%     spiceFileDirectory : A string specifying the directory in whcih to
%                          look for SPICE files. Do nothing if empty.  
%     truncConfigStruct  : Configuration parameters for truncating PA
%     |                    inputs. Do nothing if empty.  
%     |
%     |-.truncateInputsEnabled
%     |-.nBackgroundPixels
%     |-.maxNumPpaTargetsPerSubtask
%     |-.ppaTargetCount
%     |-.maxTargetsPerSubtask
%      -.nCadences
%**************************************************************************
function paDataStruct = ...
    modify_pa_data_struct(paDataStruct, spiceFileDirectory, truncConfigStruct)

    % INSERT ANY ADDITIONAL MODIFICATIONS HERE ----->
    
    % Argabrightening flags are stored for all cadences. Unfortunately
    % their use within process_target_pixels() can affect the lengths of
    % truncated pixel time series. For that reason, Argabrightening
    % mitigation is disabled here:
    paDataStruct.argabrighteningConfigurationStruct.mitigationEnabled = false;
    
    % <----- INSERT ADDITIONAL MODIFICATIONS HERE 

    % Set the SPICE file directory.
    if ~isempty(spiceFileDirectory)...
        && truncConfigStruct.truncateInputsEnabled == true
    
        paDataStruct.raDec2PixModel.spiceFileDir = spiceFileDirectory;
    end

    % Trunctate the input data.
    if ~isempty(truncConfigStruct)...
        && truncConfigStruct.truncateInputsEnabled == true
    
        paDataStruct = truncate_pa_data_struct(paDataStruct, truncConfigStruct);
    end
end

%**************************************************************************
% Truncate PA inputs.
function paDataStruct = truncate_pa_data_struct(paDataStruct, config)    
    
    switch paDataStruct.processingState

        case 'BACKGROUND'
            paDataStruct = trunc_pa(paDataStruct, config.nCadences, ...
                                    config.nBackgroundPixels, 0);
        case 'PPA_TARGETS'  
            paDataStruct = trunc_pa(paDataStruct, config.nCadences, ...
                                    0, config.maxNumPpaTargetsPerSubtask);
        case 'TARGETS'
            paDataStruct = trunc_pa(paDataStruct, config.nCadences, ...
                                    0, config.maxTargetsPerSubtask);
        otherwise
            % In the aggregation processing states, we still need to set 
            % the number of cadences.
            paDataStruct = trunc_pa(paDataStruct, config.nCadences, 0, 0);
    end

    % Make sure the PPA target count is consistent with the truncated
    % target arrays.
    if strcmpi(paDataStruct.processingState, 'BACKGROUND')
        paDataStruct.ppaTargetCount = 0;
    else
        paDataStruct.ppaTargetCount = config.ppaTargetCount;
    end
end


%**************************************************************************
% Return a default truncation configuration structure for use with
% run_pa_trunc()
function truncConfigStruct = get_default_config_struct()

    % Specify whether the input structure should be truncated.
    truncConfigStruct.truncateInputsEnabled = true;

    % Specify number of background targets to process in first subtask.
    % The remainder will be pruned from the input struct.
    truncConfigStruct.nBackgroundPixels = 2000;

    % Specify the maximum number of PPA targets to process in a subtask.
    truncConfigStruct.maxNumPpaTargetsPerSubtask = 50;
    truncConfigStruct.ppaTargetCount = []; % This value must be determined from the data.

    % Specify the maximum number of regular (non-PPA) targets to
    % process in a subtask. 
    truncConfigStruct.maxTargetsPerSubtask = 100;

    % Specify the number of cadences to process.
    truncConfigStruct.nCadences = 1000;
        
end