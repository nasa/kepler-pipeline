function [timeSeconds, columnLabel] = analyze_pa_subtask_runtimes(groupDir)
%**************************************************************************
% [timeSeconds, columnLabel] = analyze_pa_subtask_runtimes(groupDir)
%**************************************************************************
% Get subtask runtime stats from the PA log files.
%
% INPUTS
%     groupDir    : A string containing the canonical path to the parent of
%                   the subtask directories. 
% OUTPUTS
%     timeSeconds : A nSubtasks-by-3 matrix containing the following in
%                   seconds: 
%
%                   Column 1 : Time to run pa_matlab_controller().
%                   Column 2 : Time to write outputs.
%                   Column 3 : Total time spent in Matlab.
%
%     columnLabel : Descriptive headings for each column in the timeSeconds
%                   matrix. 
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
   
    subtaskDirs = get_sorted_subtask_dirs(groupDir);
    nSubtasks = numel(subtaskDirs);
    
    columnLabel = {'Controller Runtime (s)', 'Time to Write Outputs (s)', 'Total (s)'};
    timeSeconds = zeros(nSubtasks, 3);
    
    for iSubtask  = 1:nSubtasks
        cd(fullfile(groupDir, subtaskDirs{iSubtask}));
        logFilePath = 'pa-stdout-0.log'; %fullfile(groupDir, subtaskDirs{iSubtask}, 'pa-stdout-0.log');
        
        command = sprintf('tail %s | grep ''Done executing controller''', logFilePath);
        [failure, result] = system(command);
        if ~failure
            timeSeconds(iSubtask, 1) = sscanf(result, 'Done executing controller, elapsed time = %g seconds');
        end
        
        command = sprintf('tail %s | grep ''Done writing outputs file''', logFilePath);
        [failure, result] = system(command);
        if ~failure
            timeSeconds(iSubtask, 2) = sscanf(result, 'Done writing outputs file, elapsed time = %g seconds');
        end
        
        command = sprintf('tail %s | grep ''Done, total elapsed time''', logFilePath);
        [failure, result] = system(command);
        if ~failure
            timeSeconds(iSubtask, 3) = sscanf(result, 'Done, total elapsed time = %g seconds');
        end
    end
end

function sortedSubtaskDirs = get_sorted_subtask_dirs(groupDir)
    dirContents = dir(fullfile(groupDir, 'st-*'));
    names = {dirContents.name};
    isdir = [dirContents.isdir];
    subtaskDirs = names(isdir);
    [~, remain] = strtok(subtaskDirs, '-');
    subtaskNumberStrings = strtok(remain, '-');
    subtaskNumbers = int16(str2double(subtaskNumberStrings));
    [~, sortedIndices] = sort(subtaskNumbers);
    sortedSubtaskDirs = subtaskDirs(sortedIndices);
end