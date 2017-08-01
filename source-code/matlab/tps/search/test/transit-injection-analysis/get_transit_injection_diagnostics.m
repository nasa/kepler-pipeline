function get_transit_injection_diagnostics(groupLabel)
% Note: this script takes ~5 minutes per target...
% under subversion in
% /path/to/matlab/tps/search/test/transit-injection-analysis/
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

% Group1
% /path/to/transitInjectionRuns/Group_1_1st_20_G_stars_09032015/***
% Group2 /path/to/transitInjectionRuns/Group_2_1st_20_K_stars_09012015/tps-matlab-2015233/


% script to run transit_injection_controller.m to generate
% the one-sigma depth function, the
% window function, and
% the period grid

% !!!!! Directions:
% in transit_injection_controller.m
% set collectPeriodSpaceDiagnostics to true, and
% set nInjections = 0
% Check that other switches are set correctly

% !!!!! First run get_stellar_parameters_for_injection_targets.m

% !!!!! Needs to be run under the ksoc-4861 codebase

%=========================================================================
% Base path
baseDir = '/path/to/matlab/tps/search/test/transit-injection-analysis';
addpath '/path/to/matlab/tps/search/test/transit-injection-analysis';

% Path to transit_injection_controller
addpath '/path/to/matlab/tps/search/test/transit-injection';

% Get group label
if(nargin == 0)
    groupLabel = input('Group number: Group1, Group2, Group3, Group4, Group6, KSOC4886, KIC3114789, GroupA, GroupB, KSOC-4930, KSOC-4964, KSOC-4964-2, KSOC-4964-4 -- ','s');
end

% Threshold label
% disp('NOTE -- !!!!! You must change thresholdForValidity manually in compute_duty_cycle.m in the KSOC-4841 codebase !!!!!')
thresholdForValidity = input('Validity threshold to be used in transit_injection_controller_for_window_function.m -- e.g. enter 0.5 for default, or enter another value: ');
validityThresholdLabel = strcat('-threshold-',num2str(thresholdForValidity));

% Option to save gzip archive of output
saveGzipArchive = false; %logical(input('Save gzip archive? 0 or 1 -- '));

% Remind user to update transit_injection-controller
svnUpdateQuery = input('Did you set collectPeriodSpaceDiagnostics to true and nInjections to 0 in transit_injection_controller_for_window_function? Y or N -- ','s');
if(svnUpdateQuery == 'N')
    error('Need to update transit_injection_controller_for_window_function!!!!!');
end

% Remind user to change the code base
disp('Current code base:')
!echo $SOC_CODE_ROOT
codebaseQuery = input('Is the current code base KSOC-4841? Y or N -- ','s');
if(codebaseQuery == 'N')
    error('Change code base to KSOC-4841!!!!!');
end


% Get topDir
topDir = get_top_dir(groupLabel);
load(strcat(topDir,'tps-injection-struct.mat'))


% Directory in which to save the results
saveDir = strcat('/codesaver/work/transit_injection/diagnostics/',groupLabel,'/');
% If the directory does not yet exist, create it.
if( ~( exist(saveDir,'dir') == 7 ) )
    mkdir(saveDir)
end
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

% For each uniqueKeplerId, get a valid corresponding index into the taskfile list
% [tf, taskfileIndex] = ismember(uniqueKeplerId,keplerIdList);
% if(sum(tf)~=nExpectedTargets)
%    error(['Fewer than ',num2str(nExpectedTargets),' unique kepler IDs!'])
% end

% Loop over unique keplerIds, running transit_injection_controller_for_window_function to make
% and save the diagnostic struct for each.
tic
for iTarget = 1:nTargets
    
    % For each target, identify the top directory for the taskfiles
    switch groupLabel
        case 'Group1'
            % Identify the subdirectory that is the top directory for the
            % taskfiles
            error('Code for Group1 case is broken ...')
            % if(uniqueKeplerIdIndex(iTarget) <= nPart1)
            %    subDir = 'tps-matlab-2015231/';
            %elseif(uniqueKeplerIdIndex(iTarget) <= nPart1 + nPart2)
            %    subDir = 'tps-matlab-2015239/';
            %elseif(uniqueKeplerIdIndex(iTarget) <= nPart1 + nPart2 + nPart3)
            %    subDir = 'tps-matlab-2015240/';
            %end
            % topDir for this target
            %topDir = strcat(topTopDir,subDir);
    end
    
    
    % For each unique target, construct the path to and load the tps-inputs-0.mat file
    taskfileSuffix = taskfileList{taskfileIndex(iTarget)};
    taskfileDir = strcat('tps-matlab',taskfileSuffix,'/');
    load(strcat(topDir,taskfileDir,'tps-inputs-0.mat'))
    
    % Progress indicator
    fprintf('iTarget %d of %d\n',iTarget,nTargets)
    fprintf('Running transit_injection_controller_for_window_function for KIC %d ...\n\n',inputsStruct.tpsTargets.keplerId)
    
    % Run transit_injection_controller
    cd(topDir)
    
    % 6/12/2016 -- Can run transit_injection_controller locally with proper switches set, instead of
    % using transit_injection_controller_for_window_function???
    
    transit_injection_controller_for_window_function( inputsStruct, thresholdForValidity );
    
    % Create filename for injection diagnostic file to be saved
    injectionDiagnosticFile = strcat(saveDir,'tps-diagnostic-struct-',groupLabel,'-KIC-',num2str(inputsStruct.tpsTargets.keplerId),validityThresholdLabel,'.mat');
    
    % Move the diagnostics file to a local directory
    fprintf('Moving the diagnostic struct for KIC %d to file %s ...\n\n',inputsStruct.tpsTargets.keplerId,injectionDiagnosticFile)
    movefile('tps-diagnostic-struct.mat',strcat(injectionDiagnosticFile))
    
    % Prepare for next target
    clear inputsStruct
    
    toc
    
end

% Create a gzipped tar archive
if(saveGzipArchive)
    tarFile = strcat(saveDir,groupLabel,'-diagnostic-structs-',validityThresholdLabel,'.tar');
    gzFile = strcat(tarFile,'.gz');
    cd(saveDir)
    evalString = sprintf('!tar cvf %s *.mat',tarFile);
    eval(evalString);
    evalString = sprintf('!gzip %s',tarFile);
    eval(evalString);
    
    % Copy the gzipped tarfile to the NFS
    nfsDir = '/path/to/diagnostic-structs/';
    evalString = sprintf('copyfile %s %s;',gzFile,nfsDir);
    eval(evalString);
end

% Return to the base directory
cd(baseDir);

