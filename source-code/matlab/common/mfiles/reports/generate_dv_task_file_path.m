function generate_dv_task_file_path(dvFilePath, instanceNumber, startTaskId, endTaskId, outputFileName)
%
%  This function generates a text file of a table showing the correspondence between the Kepler IDs and the DV task file paths.
%
%  The table consists of 4 columns as following:
%
%       column #1: keplerIds of the targets, sorted in ascending order
%       column #2: DV task file path of the target
%       column #3: Flag indicating whether the DV output file dv-outputs-0.mat is available
%       column #4: Flag indicating whether the DV post-fit workspace file dv_post_fit_workspace.mat is available
%
%  
%  Inputs:
%
%       dvFilePath:      [string]  root folder of DV task file path, which is one level above the folders '~/dv-matlab-iiii-######/'
%       instanceNumber:  [integer] Instance number, i.e. value of 'iiii' in the folders '~/dv-matlab-iiii-######/'
%       startTaskId:     [integer] Start task ID number, i.e. minimum value of '######'   in the folders '~/dv-matlab-iiii-######/'
%       endTaskId:       [integer] End   task ID number, i.e. maximum value of '######'   in the folders '~/dv-matlab-iiii-######/'
%       outputFileName:  [string]  Output file name. By calling this function, a text file 'outputFileName.txt'
%                                  and a Matlab data file 'outputFileName.mat' will be generated.
%
%  Example:
%
%       dvFilePath      = '/path/to/MQ-q1-q16/pipeline_results/dv_supp_ksop1970/';
%       instanceNumber  = 9306;
%       startTaskId     = 568440;
%       endTaskId       = 568523;
%       outputFileName  = 'keplerId_dvTaskFilePath_table_external_tce_supplement_Q1_Q16_i9306_04082014';
%       generate_dv_task_file_path(dvFilePath, instanceNumber, startTaskId, endTaskId, outputFileName)
%
%
%  Version date:  2014-April-10.
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


%  Modification History:
%
%    2014-April-10, JL:
%        Initial release.
%
%=========================================================================================

outputTxtFileName   = [ outputFileName '.txt' ];
outputMatFileName   = [ outputFileName '.mat' ];

nDvTasks    = endTaskId - startTaskId + 1;         % total # of DV task files

counter = 0;
for i=1:nDvTasks

    iTask = startTaskId + i - 1;
    pathName   = [dvFilePath 'dv-matlab-' num2str(instanceNumber) '-' num2str(iTask)];
    dirStructs = dir(pathName);
    
    if ~isempty(dirStructs)
        
        nDirs = length(dirStructs);
        for iDir=1:nDirs
           
            disp(['taskId = ' num2str(iTask) '    nDirs = ' num2str(nDirs) '    iDir = ' num2str(iDir)]);
            
            dirName = dirStructs(iDir).name;
            if dirStructs(iDir).isdir && ~isempty(strfind(dirName, 'st'))
                
                stInd = strfind(dirName, 'st');
                stNum = str2double(dirName(stInd+3:end));
                
                if exist(fullfile(pathName, dirName, 'dv-inputs-0.mat'), 'file')
                    
                    outputAvailable           = 0;
                    postFitWorkspaceAvailable = 0;
                    if exist(fullfile(pathName, dirName, 'dv-outputs-0.mat'), 'file')
                        outputAvailable           = 1;
                    end
                    if exist(fullfile(pathName, dirName, 'dv_post_fit_workspace.mat'), 'file')
                        postFitWorkspaceAvailable = 1;
                    end
                    
                    targetDirStructs = dir([pathName '/' dirName]);
    
                    for j1=1:length(targetDirStructs)
                        
                        if targetDirStructs(j1).isdir && ~isempty(strfind(targetDirStructs(j1).name, 'target-'))
                            counter = counter + 1;
                            targetStruct(counter).keplerId                  = str2double(targetDirStructs(j1).name(8:end));
                            targetStruct(counter).pathName                  = pathName;
                            targetStruct(counter).dirName                   = dirName;
                            targetStruct(counter).taskNum                   = iTask;
                            targetStruct(counter).stNum                     = stNum;
%                            targetStruct(counter).targetIndex              = j1;
                            targetStruct(counter).outputAvailable           = outputAvailable;
                            targetStruct(counter).postFitWorkspaceAvailable = postFitWorkspaceAvailable;
                        end
                        
                    end
    
                end
                
            end
            
        end
        
    end
    
end

[ignored, sortedIndex] = sort([targetStruct.keplerId]);

fid = fopen(outputTxtFileName, 'w');
title = '  KeplerId                                                DV Task File Path                                                DV output file available?                DV post-fit workspace file available?';
fprintf(fid, '%s\n\n', title);
for i=1:length(sortedIndex)
    fprintf(fid, '%10d          %s                      %4d                       %4d\n', ...
        targetStruct(sortedIndex(i)).keplerId, [targetStruct(sortedIndex(i)).pathName '/' targetStruct(sortedIndex(i)).dirName], targetStruct(sortedIndex(i)).outputAvailable, targetStruct(sortedIndex(i)).postFitWorkspaceAvailable);
end
fclose(fid);

sumOutputAvailable           = sum([targetStruct.outputAvailable]);
sumPostFitWorkspaceAvailable = sum([targetStruct.postFitWorkspaceAvailable]);

eval(['save ' outputMatFileName ' targetStruct sumOutputAvailable sumPostFitWorkspaceAvailable']);
