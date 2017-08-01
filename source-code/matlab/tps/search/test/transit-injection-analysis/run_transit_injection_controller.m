function [outputStruct, localControlParameterStruct] =  run_transit_injection_controller(groupLabel)
% run transit injection on a single target with one injection
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

% !!!!! Directions: if we want diagnostics:
% in transit_injection_controller.m code,
% set collectPeriodSpaceDiagnostics to false, and
% set nInjections = 1
% Check that other switches are set correctly

% !!!!! Must be run under the ksoc-4841 codebase
% !!!!! Must be run under the ksoc-5041 codebase

%=========================================================================
% Base path
baseDir = '/path/to/matlab/tps/search/test/transit-injection-analysis';
addpath '/path/to/matlab/tps/search/test/transit-injection-analysis';

% Path to transit_injection_controller
addpath '/path/to/matlab/tps/search/test/transit-injection';

% Remind user to change the code base
disp('Current code base:')
!echo $SOC_CODE_ROOT
codebaseQuery = input('Is the current code base KSOC-5041? Y or N -- ','s');
if(codebaseQuery == 'N')
    error('Change code base to KSOC-5041!!!!!');
end

% Get group label
if(nargin == 0)
    groupLabel = input('Group number: Group1, Group2, Group3, Group4, Group6, KSOC4886, KIC3114789, GroupA, GroupB, KSOC-4930, KSOC-4964, KSOC-4964-2, KSOC-4964-4: ','s');
end


% Error if groupLabel is 'Group1'
switch groupLabel
    
    case 'Group1'
        
        error('Code for Group1 case is broken ...')     
end

% taskfiles top directory, used to get the tps-inputs-0.mat input structs
topDir = get_top_dir(groupLabel);

% Load injection struct
load(strcat(topDir,'tps-injection-struct.mat'))

% data directory
dataDir = '/codesaver/work/transit_injection/data/';

% Get the stellar parameters file created by
% get_stellar_parameters_for_injection_targets.m
load(strcat(dataDir,groupLabel,'_stellar_parameters.mat'))
% keplerIdList = stellarParameterStruct.keplerId;
keplerId = stellarParameterStruct.keplerId;

% taskFileIndex is the mapping between taskfileList and keplerId
% it allows you to locate the tps-inputs-0.mat taskfile associated with
% keplerId, which is the input file for transit injection
taskfileIndex = stellarParameterStruct.taskfileIndex;

% taskfile field is used to identify the subtask directory
taskfileList = tpsInjectionStruct.taskfile;

% List of unique targets for injections
% [uniqueKeplerId, uniqueKeplerIdIndex] = unique(keplerIdList);
% nUniqueKeplerIds = length(uniqueKeplerId);
nTargets = length(keplerId);

% Control parameters for local run
nInjections = 0;
minImpactParameter = 0.3;
minPlanetRadiusEarthRadii = 12;
maxPlanetRadiusEarthRadii = 15;
saveInterval = 1;
minPeriodOverride = 425;
alwaysInject = true;
collectPeriodSpaceDiagnostics = true;
saveTpsDataForEachInjection = true;


% Package local control parameters into a struct
localControlParameterStruct.nInjections = nInjections;
localControlParameterStruct.minImpactParameter = minImpactParameter;
localControlParameterStruct.minPlanetRadiusEarthRadii = minPlanetRadiusEarthRadii;
localControlParameterStruct.maxPlanetRadiusEarthRadii = maxPlanetRadiusEarthRadii;
localControlParameterStruct.saveInterval = saveInterval;
localControlParameterStruct.minPeriodOverride = minPeriodOverride;
localControlParameterStruct.alwaysInject = alwaysInject;
localControlParameterStruct.collectPeriodSpaceDiagnostics = collectPeriodSpaceDiagnostics;
localControlParameterStruct.saveTpsDataForEachInjection = saveTpsDataForEachInjection;


% For each uniqueKeplerId, get a valid corresponding index into the taskfile list
% [tf, taskfileIndex] = ismember(uniqueKeplerId,keplerIdList);
% if(sum(tf)~=nExpectedTargets)
%    error(['Fewer than ',num2str(nExpectedTargets),' unique kepler IDs!'])
% end

% Loop over unique keplerIds, running transit_injection_controller_for_window_function to make
% and save the diagnostic struct for each.
tic
% for iTarget = 1; % !!!!! For groupLabel KSOC-4930, this injects in KIC9898170 only !!!!! 1:nTargets 
for iTarget = 1:nTargets;
    
    % Get runId from clock
    % formatOut =  'ddmmmyyyyTHHMMSS';
    % runId = datestr(now,formatOut);
   
    % For each unique target, construct the path to and load the tps-inputs-0.mat file
    taskfileSuffix = taskfileList{taskfileIndex(iTarget)};
    taskfileDir = strcat('tps-matlab',taskfileSuffix,'/');
    load(strcat(topDir,taskfileDir,'tps-inputs-0.mat'))
    
    % Select a desired target
    % targetKeplerId = inputsStruct.tpsTargets.keplerId;
    
    %if(targetKeplerId == 9574801)
    
        
    % Progress indicator
    fprintf('iTarget %d of %d\n',iTarget,nTargets)
    fprintf('Running transit_injection_controller_local for KIC %d ...\n\n',inputsStruct.tpsTargets.keplerId)
    
    % Unique directory in which to save the results for this target
    % saveDir = strcat('/codesaver/work/transit_injection/test/',groupLabel,'_',runId,'_',num2str(),'/');
    % saveDir = strcat('/codesaver/work/transit_injection/test/',groupLabel,'-',runId,'-KIC-',num2str(inputsStruct.tpsTargets.keplerId),'/');
    % saveDir = strcat('/codesaver/work/transit_injection/test/',groupLabel,'-KIC-',num2str(inputsStruct.tpsTargets.keplerId),'/');
    % Just save the results in the original subtask directory
    saveDir = strcat(topDir,taskfileDir);
    
    
    % add saveDir to localParameterStruct
    localControlParameterStruct.saveDir = saveDir;
    
    % If the directory does not yet exist, create it.
    %if( ~( exist(saveDir,'dir') == 7 ) )
    %    mkdir(saveDir)
    %end
    
    % If there is already a diagnostic struct file present, remove it
    if(exist(strcat(saveDir,'tps-diagnostic-struct.mat'),'file'))
       delete(strcat(saveDir,'tps-diagnostic-struct.mat'));
    end
    fprintf('Results will be saved in directory %s ...\n',saveDir);
    
    
    % Run transit_injection_controller and save output in subtask directory
    % associated with this target
    cd(saveDir)
    % outputStruct = transit_injection_controller_working( inputsStruct, localControlParameterStruct );
    outputStruct = transit_injection_controller( inputsStruct, localControlParameterStruct );
    
    % If number of injections > 0, save the output struct
    %if(nInjections > 0)
        
        % Create filename for injection output file to be saved
    %    injectionOutputFile = strcat(saveDir,'tps-output-struct-',groupLabel,'-KIC-',num2str(inputsStruct.tpsTargets.keplerId),'.mat');
    %    save(injectionOutputFile,'outputStruct')
        
    %end
    
    % Prepare for next target
    clear inputsStruct
    
    toc
    
end

toc

% Return to the base directory
cd(baseDir);

