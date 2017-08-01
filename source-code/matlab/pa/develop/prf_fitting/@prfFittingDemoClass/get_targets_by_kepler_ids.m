function [targetArray, filenames] = get_targets_by_kepler_ids( keplerIds, taskDir )
%************************************************************************** 
% [targetArray, filenames]  = get_targets_by_kepler_ids( keplerIds, taskDir )
%************************************************************************** 
% Given an array of Kepler IDs and a task file directory (default is the
% current directory), find the files containing the targets and return an
% array of target data structures.
%
% INPUTS:
%     keplerId    : A list of valid kepler ID
%     taskDir     : The task directory to search (default is current 
%                   working directory). A task directory contains all data 
%                   for a single channel.
%
% OUTPUTS:
%     targetArray : An array of target data structs containing the
%                   specified targets that were found in files under
%                   taskDir.
%     filenames   : A cell array of file names under taskDir in which
%                   corresponding elements of targetArray were found. 
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
    targetArray = [];
    filenames = {};
    nFound = 0;
    
    if ~exist('taskDir','var')
        taskDir = '.';
    end
        
    % Is this an ol-style directory?
    if exist( fullfile(taskDir, 'st-0'), 'dir')

        % Search NAS-style task directory.

    else
        % Search an old-style task directory.
        inputFiles = dir( fullfile(taskDir,'pa-inputs-*.mat') );
        
        for i = 1:numel(inputFiles)
            fprintf('Searching input file %d of %d ...\n', i, numel(inputFiles));
            
            s = load( fullfile(taskDir, inputFiles(i).name) );
            if ~isempty(s.inputsStruct.targetStarDataStruct)
                [isFound, targetIndex] = ismember(keplerIds, [s.inputsStruct.targetStarDataStruct.keplerId]);
                if any(isFound)
                    targetArray = [targetArray, s.inputsStruct.targetStarDataStruct(targetIndex(isFound))];
                    [filenames{nFound+1:nFound+nnz(isFound)}] = deal(inputFiles(i).name); 

                    nFound = nFound + nnz(isFound);
                    if nFound >= numel(keplerIds)
                        break;
                    end
                end      
            end
            
        end
        
    end
    
end