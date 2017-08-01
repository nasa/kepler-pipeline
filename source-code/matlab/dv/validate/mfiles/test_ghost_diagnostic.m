% test_ghost_diagnostic.m
% script to test ghost diagnostic on local copy of taskfiles
%==========================================================================
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


% Script dir
scriptDir = '/codesaver/work/test_ghost_diagnostic/scripts/';

% Input runId
runId = input('KSOP number, e.g. 2102, 2222, 2486, 2488, 2537 -- ','s');

% Option to save outputs
saveOutputs = false;

% Identify the location of the original taskfiles directory corresponding to the KSOP number, of the run to analyze.
% The taskfiles directory is where the dvOuputMatrix.mat is found
% Specify the name of the corresponding local working directory 
switch runId
    case '2102'
        topDir = '/path/to/ksop-2102/dv/';
        localDirRoot = '/codesaver/work/test_ghost_diagnostic/ksop-2102-dv-Q1-Q17-code-stabilization/';
    case '2222'
        topDir = '/path/to/ksop-2222-post-9.3-DV-full-Q1-Q17/';
        localDirRoot = '/codesaver/work/test_ghost_diagnostic/ksop-2222-post9.3-full-run-Q1-Q17/';
    case '2486'
        topDir = '/path/to/ksop-2486-DV-mini-Overpopulation-Q1-Q17/';
        localDirRoot = '/codesaver/work/test_ghost_diagnostic/ksop-2486-9.3-DV-mini-run-Overpopulation-Q1-Q17/';
    case '2488' % Results posted to KSOC-4959
        topDir = '/path/to/soc-9.3-reprocessing/mq-q1-q17/pipeline_results/dv-v2/';
        localDirRoot = '/codesaver/work/test_ghost_diagnostic/ksop-2488-9.3-DV-reprocessing-V2/';
    case '2537' % Results posted to KDAWG-217
        topDir = '/path/to/mq-q1-q17/pipeline_results/dv-v4/';
        localDirRoot = '/codesaver/work/test_ghost_diagnostic/ksop-2537-9.3-DV-reprocessing-V4new/';
        
end

% Data directory
dataDir = '/codesaver/work/test_ghost_diagnostic/data/';

% Local copy of taskfiles for a skygroup we want to test
% localDir = '/codesaver/work/test_ghost_diagnostic/ksoc-4753/dv-matlab-10476-595649/st-6/';

% Choose a random task/subtask directory
taskDir = 'dv-matlab-12625-1164948/';
subtaskDir = 'st-0/';
localDir = strcat(localDirRoot,taskDir,subtaskDir);
taskFilesDir = strcat(topDir,taskDir,subtaskDir);

% Make a local directory if it doesn't already exist
if(~exist(localDir,'dir'))
    mkdir(localDir);
end


% Copy relevant task files into localDir
copyfile(taskFilesDir,localDir)

% Get into localDir
cd(localDir);

% Option to save outputs
saveOutputs = false;


% Make a back-up copy of dv_cads.mat
% try
%     copyfile('dv_cads.mat','dv_cads_backup.mat');
% catch exception
%     fprintf('Error! Returns message -- %s\n with messageId = %s\n',exception.message,exception.identifier)
% end

% Copy all blob files & .sdf files from the task directory above to the
% copy of the subtask directory (localDir)
% cd(strcat(topDir,taskDir));
fprintf('Copying blob and sdf files ...\n\n')
taskDirPath = strcat(topDir,taskDir);
evalString = sprintf('!cp %sblob*.mat, %s',taskDirPath,localDir);
eval(evalString)
evalString = sprintf('!cp %s*.sdf %s',taskDirPath,localDir);
eval(evalString)

% Update dv input struct with some necessary data (dvDataObject is still a struct)
% erases the dv_cads.mat file
% dvDataObject = update_dv_inputs(dvDataObject);
% Above step is unnecessary and screws up results.
% See KSOC-4615

% Clear classes
clear classes

% Load the dv_post_fit_workspace, which has structs dvDataObject and dvResultsStruct
if(~exist('dv_post_fit_workspace.mat','file'))
    error('dv_post_fit_workspace.mat file not found!!')
else
    load dv_post_fit_workspace.mat
end

% Reset the refTime (which records when DV processing actually started) to now
dvDataObject.refTime = clock;

% Instantiate dvDataObject into an object
disp('Instantiating a dvDataObject...')
dvDataObject = dvDataClass(dvDataObject);

% Restore dv_cads.mat from the back-up copy
% try
%    movefile('dv_cads_backup.mat','dv_cads.mat');
% catch exception
%    fprintf('Error! Returns message -- %s\n with messageId = %s\n',exception.message,exception.identifier)
% end

% Restore the pixelData .mat files and put the pixel data into the dvDataObject
% really only need to do this if there are no existing .mat files in the pixelData directory
% This takes a few minutes ...
disp('Restoring the pixelData .mat files...')
dvDataObject = restore_dv_object_and_pixel_data_files(dvDataObject);

% Initialize the new dvResultsStruct fields that are used by the ghost diagnostic tests
% This will eventually be done in DV
% It is now done in DV, so skip this step
skip = true;
if(~skip)
    statistic = struct( ...
        'value',                        0, ...
        'significance',                 -1);
    ghostDiagnosticResults = struct( ...
        'coreApertureCorrelationStatistic',  statistic, ...
        'haloApertureCorrelationStatistic',  statistic);
    nTargets = length(dvResultsStruct.targetResultsStruct);
    nPlanets = length(dvResultsStruct.targetResultsStruct(1).planetResultsStruct);
    for iTarget = 1:nTargets
        for iPlanet = 1:nPlanets
            dvResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(iPlanet).ghostDiagnosticResults = ghostDiagnosticResults;
        end
    end
end

% Run the ghost diagnostic test
fprintf('Performing ghost diagnostic tests ...\n')
[dvResultsStruct] = perform_dv_ghost_diagnostic_tests(dvDataObject, dvResultsStruct);

if saveOutputs
    save dvResultsStruct.mat dvResultsStruct ;
end
clear dvResultsStruct dvDataObject ;
disp('Done with ghost diagnostic test')
pause(1) ;
  