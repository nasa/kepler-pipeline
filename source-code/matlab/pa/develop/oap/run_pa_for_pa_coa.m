%**************************************************************************
% function run_pa(taskFileDirectory, spiceFileDirectory, startingSubTaskNumber)
%**************************************************************************
% Simulate long-cadence PA for an existing directory structure. All input
% files and subtask directories are assumed to exist in taskFileDirectory.
% All input structures are assumed to be in the SOC 9.1 format.
%
% INPUTS
%     taskFileDirectory     :
%     spiceFileDirectory    :
%     startingSubTaskNumber :
%
% OUTPUTS
%     The variables inputsStruct (with spice files updated) and
%     outputsStruct are saved to the files 'pa-inputs-0.mat' and
%     'pa-outputs-0.mat', respectively, in each subtask directory.
%
% NOTES
%     BE AWARE that the spice file names in the input files will be
%     altered!
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
function run_pa_for_pa_coa(taskFileDirectory, spiceFileDirectory, paCoaRun)
 
    paInputFileName  = 'pa-inputs-0.mat';        
    paOutputFileName = 'pa-outputs-0.mat';
    
    if ~exist(taskFileDirectory, 'dir')
        error('taskFileDirectory not found');
    end

    if ~exist('paCoaRun', 'var')
        paCoaRun = false;
    end
    
    if ~exist('startingSubTaskNumber', 'var')
        startingSubTaskNumber = 0;
    end
    
    startDirectory = pwd; % Save current directory to be restored later.
    
    % Create a list of subtask directories in ascending order.
    contents = dir(fullfile(taskFileDirectory, 'st-*'));
    names = {contents.name};
    isdir = [contents.isdir];
    subtaskDirs = names(isdir);
    [~, remain] = strtok(subtaskDirs, '-');
    subtaskNumberStrings = strtok(remain, '-');
    subtaskNumbers = int16(str2double(subtaskNumberStrings));
    [~, sortedIndices] = sort(subtaskNumbers);
    sortedSubtaskDirs = subtaskDirs(sortedIndices);

    %----------------------------------------------------------------------
    % Execute each subtask
    %----------------------------------------------------------------------
    startIndex = startingSubTaskNumber + 1;
    for i = startIndex:numel(sortedSubtaskDirs)

        % Descend into subtask directory.
        cd(fullfile(taskFileDirectory, sortedSubtaskDirs{i}));
    
        % Try block is used to ensure the original working directory is
        % restored.
        %try
            % load PA inputs.
            load(paInputFileName);

            % Set SPICE directories and files.
            if ~isempty(spiceFileDirectory)
                inputsStruct.raDec2PixModel.spiceFileDir = spiceFileDirectory;
            end
        
            % Set the minimum fit points for motion polynomial fitting (for K2)
            inputsStruct.motionConfigurationStruct.fitMinPoints = 5;
            
            % Turn on PA-COA if requested
            if (paCoaRun)
                inputsStruct.paConfigurationStruct.paCoaEnabled = true;
                inputsStruct.paCoaConfigurationStruct.cadenceStep  = 100;
                inputsStruct.apertureModelConfigurationStruct.raDecFittingEnabled = true;
                inputsStruct.apertureModelConfigurationStruct.raDecRepulsiveCoef = 0.0;
                inputsStruct.apertureModelConfigurationStruct.raDecRestoringCoef = 0.0;
            end

            % Run the matlab controller.
            [outputsStruct] = pa_matlab_controller(inputsStruct);
            
        %catch exception
        %    cd(startDirectory);
        %    rethrow(exception);
        %end
        
        % Save inputs and outputs
        save(paInputFileName,  'inputsStruct');
        save(paOutputFileName, 'outputsStruct');
        
        cd ..
    end
    cd(startDirectory);
    
end

