%*********************************************************************************************************
% function [targetModOutStruct] = pdc_find_target_mod_out (keplerId, quarter)
%
% Finds the requested target task directory. Call from path with all the pdc-* subdirectories
%
% Inputs:
%   keplerId    -- [int] The Kepler ID to look up
%   quarter     -- [int] Thw quarter to find the tasks for
%
% Outputs:
%   targetModOutStruct  -- [struct]
%       .ccdModule
%       .ccdOutput
%       .taskDir        -- [char] Path to task files
%
%*********************************************************************************************************
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

function [targetModOutStruct] = pdc_find_target_mod_out (keplerId, quarter)


    % Find the directories for this quarter
    taskDirNames = dir('./uow/pdc-*');
    % Find sub-tasks for this quarter
    useThisDirectory = false(length(taskDirNames),1);
    for iTask = 1 : length(taskDirNames)
        if (quarter < 10)
            stringPattern = ['-q0', num2str(quarter)];
        else
            stringPattern = ['-q', num2str(quarter)];
        end
        useThisDirectory(iTask) = ~isempty(strfind(taskDirNames(iTask).name, stringPattern));
    end
    taskDirNames = taskDirNames(useThisDirectory);

    % Search these directories for the target
    dirHeaderPath = [pwd, '/uow/'];

    nTaskDirs = length(taskDirNames);

    for iTaskDir = 1 : nTaskDirs
        
        cd ([dirHeaderPath, taskDirNames(iTaskDir).name]);

        display(['Working on Task ', num2str(iTaskDir), ' of ', num2str(nTaskDirs)]);
            
        if (~exist('pdc-inputs-0.mat', 'file'))
            % No data, skip this task
            cd ..
            continue;
        end
        inputsStruct = load('pdc-inputs-0.mat');
        inputsStruct = inputsStruct.inputsStruct;

        for iChannel = 1 : length(inputsStruct.channelDataStruct)
            keplerIdsOnThisChannel = [inputsStruct.channelDataStruct(iChannel).targetDataStruct.keplerId];

            targetLocation = find(keplerId == keplerIdsOnThisChannel, 1);
            if (~isempty(targetLocation))
                % Found it!
                targetModOutStruct.ccdModule = inputsStruct.channelDataStruct(iChannel).ccdModule;
                targetModOutStruct.ccdOutput = inputsStruct.channelDataStruct(iChannel).ccdOutput;
                targetModOutStruct.taskDir   = taskDirNames(iTaskDir).name;

                cd ..
                return;
            end
        end

        cd ..
    end

end

