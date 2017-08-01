function run_pa(taskFileDirectory, spiceFileDirectory, ...
    startingSubTaskNumber, endingSubTaskNumber)
%**************************************************************************
% function run_pa(taskFileDirectory, spiceFileDirectory, ...
%     startingSubTaskNumber, overwriteInputSpiceDirs)
%**************************************************************************
% Simulate long-cadence PA for an existing directory structure. All input
% files and subtask directories are assumed to exist in taskFileDirectory.
% All input structures are assumed to be in the SOC 9.1 format.
%
% INPUTS
%     taskFileDirectory       : A string specifying the root task directory,
%                               under which subtask directories are found.
%     spiceFileDirectory      : A string specifying the path where spice
%                               files are to be found.
%     startingSubTaskNumber   : Begin the processing with this subtask
%                               (default = 0).
%     endingSubTaskNumber     : Stop after this subtask (default is last
%                               subtask in taskFileDirectory)  
% OUTPUTS
%     The variables inputsStruct (with spice files updated) and
%     outputsStruct are saved to the files 'pa-inputs-0.mat' and
%     'pa-outputs-0.mat', respectively, in each subtask directory.
%
% NOTES
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
    paInputBinFileName  = 'pa-inputs-0.bin';        
    paInputMatFileName  = 'pa-inputs-0.mat';
    paOutputMatFileName = 'pa-outputs-0.mat';
    
    % Specify the directory containing functions to read binary input
    % files.
    readBinaryInputsPath = ...
        fullfile(get_socCodeRoot(), 'matlab/pa/build/generated/mfiles');

    if ~exist(taskFileDirectory, 'dir')
        error('taskFileDirectory not found');
    end
    
    if ~exist('startingSubTaskNumber', 'var')
        startingSubTaskNumber = 0;
    end
    
    if ~exist('endingSubTaskNumber', 'var')
        endingSubTaskNumber = [];
    end
    
    startDirectory = pwd; % Save current directory to be restored later.
        
    %----------------------------------------------------------------------
    % Create a list of subtask directories in ascending order.
    %----------------------------------------------------------------------
    dirContents = dir(fullfile(taskFileDirectory, 'st-*'));
    names = {dirContents.name};
    isdir = [dirContents.isdir];
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
    for iDir = startIndex:stopIndex   
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

        % Run the matlab controller.
        [outputsStruct] = pa_matlab_controller(inputsStruct);
                    
        % Save outputs
        save(paOutputMatFileName, 'outputsStruct');
    end
    cd(startDirectory);
end

