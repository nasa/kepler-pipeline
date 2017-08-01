function [stellarParameterStruct] = get_stellar_parameters_for_injection_targets(groupLabel)
% Get stellar parameters by brute force, from tpsInputStruct
% Path to this code
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


% Inputs: 
%         groupLabel for output file, such as'Group1' or  'Group2'
%         tps-injection-struct.mat
% Outputs: stellarParameterStruct

% Added field stellarParameterStruct.taskfileIndex that associates a taskfileIndex with the first instance of each unique keplerId 

% Usage:
% Run immediately after injection run
% keplerId in tpsInjectionStruct is used to identify the corresponding
% index in stellarParameterStruct.keplerId,
% which can then be used to extract the corresponding
% stellar parameters from the fields
% tpsInjectionStruct.log10SurfaceGravity
% tpsInjectionStruct.log10Metallicity
% tpsInjectionStruct.effectiveTemp
% tpsInjectionStruct.stellarRadiusInSolarRadii
% tpsInjectionStruct.dataSpanInCadences
% tpsInjectionStruct.dutyCycle

%==========================================================================
% Get group label
if(nargin == 0)
    groupLabel = input('Group number: Group1, Group2, Group3, Group4, Group6, KSOC4886, KIC3114789, GroupA, GroupB, KSOC-4930, KSOC-4964, KSOC-4964-2, KSOC-4964-4, TPS9p3V4,  KSOC-5004-1 -- ','s');
end

% Get topDir
topDir = get_top_dir(groupLabel);

% Get the taskfile list
switch groupLabel
    
    case 'TPS9p3V4'
        
        % Load the TPS output file
        load(strcat(topDir,'tps-tce-struct.mat'))
        
        % taskfile field is used to identify the subtask directory
        tpsInjectionStruct = tpsTceStruct;
        taskfileList = tpsInjectionStruct.taskfile;
        
    otherwise
        
        % Load the injection output file
        load(strcat(topDir,'tps-injection-struct.mat'))
        
        % taskfile field is used to identify the subtask directory
        taskfileList = tpsInjectionStruct.taskfile;


end

% Directory in which to save the results
saveDir = '/codesaver/work/transit_injection/data/';

% If the directory does not yet exist, create it.
if( ~( exist(saveDir,'dir') == 7 ) )
    mkdir(saveDir)
end


% Initialize for loop over taskfiles
nTargets = length(taskfileList);
keplerId = zeros(nTargets,1);
log10SurfaceGravity = zeros(nTargets,1);
log10Metallicity = zeros(nTargets,1);
effectiveTemp = zeros(nTargets,1);
stellarRadiusInSolarRadii = zeros(nTargets,1);
dataSpanInCadences = zeros(nTargets,1);
dutyCycle = zeros(nTargets,1);
rmsCdpp = zeros(nTargets,14);
keplerMag = zeros(nTargets,1);
keplerIdCheck = zeros(nTargets,1);
isPlanetACandidate = zeros(nTargets,1);

% Get keplerMag from 9.3 taskfiles for TPS run (it is not in the
% tpsInjectionStruct)
switch groupLabel
    case 'TPS9p3V4'
    otherwise
        
        taskFilesDir9p3 = '/path/to/soc-9.3-reprocessing/mq-q1-q17/pipeline_results/tps/';
        load(strcat(taskFilesDir9p3,'tps-tce-struct.mat'));
end
keplerIdTps = tpsTceStruct.keplerId;
keplerMagTps = tpsTceStruct.keplerMag;
% clear tpsTceStruct


tic

% Brute force loop over taskfileList to find keplerId associated with each one
% Get stellar parameters for each unique keplerId
fprintf('Getting stellar parameters for %s ...\n',groupLabel');

for iTarget = 1:nTargets
    
    % For each target, construct the path to and load the tps-inputs-0.mat file
    switch groupLabel
        case 'Group1'
            % Identify the subdirectory that is the top directory for the
            % taskfiles
            if(iTarget <= nPart1)
                subDir = 'tps-matlab-2015231/';
            elseif(iTarget <= nPart1 + nPart2)
                subDir = 'tps-matlab-2015239/';
            elseif(iTarget <= nPart1 + nPart2 + nPart3)
                subDir = 'tps-matlab-2015240/';
            end
            % topDir for this target
            topDir = strcat(topTopDir,subDir);
    end
    
    % Identify the path to and load the tps input struct for this target:
    % This is the source of all the stellar parameters
    taskfileSuffix = taskfileList{iTarget};
    taskfileDir = strcat('tps-matlab',taskfileSuffix,'/');
    load(strcat(topDir,taskfileDir,'tps-inputs-0.mat'))
    
    % Get all the stellar parameters from the inputStruct -- these are scalars, except for rmsCdpp
    % Note that rmsCdpp originates from the tps_tce_struct that is
    % specified as an input for transit injection
    keplerId(iTarget) = inputsStruct.tpsTargets.keplerId;
    if( isfield(inputsStruct.tpsTargets,'log10SurfaceGravity') )
        log10SurfaceGravity(iTarget) = inputsStruct.tpsTargets.log10SurfaceGravity;
    end
    
    if( isfield(inputsStruct.tpsTargets,'log10Metallicity') )
        log10Metallicity(iTarget) = inputsStruct.tpsTargets.log10Metallicity;
    end
    
    if( isfield(inputsStruct.tpsTargets,'effectiveTemp') ) 
        effectiveTemp(iTarget) = inputsStruct.tpsTargets.effectiveTemp;
    end
    
    if( isfield(inputsStruct.tpsTargets,'radius') )
        stellarRadiusInSolarRadii(iTarget) = inputsStruct.tpsTargets.radius;
    end
    
    if( isfield(inputsStruct.tpsTargets,'rmsCdpp') )
        rmsCdpp(iTarget,:) = inputsStruct.tpsTargets.rmsCdpp;
    end
    
    
    % These parameters are from the injection run
    % log10SurfaceGravity2(iTarget) = tpsInjectionStruct.log10SurfaceGravity(iTarget); % offset by 1e-7
    % log10Metallicity2(iTarget) = tpsInjectionStruct.log10Metallicity(iTarget); % offset by 6 e-10
    % effectiveTemp2(iTarget) = tpsInjectionStruct.effectiveTemp(iTarget); % exactly equal
    % stellarRadiusInSolarRadii2(iTarget) = tpsInjectionStruct.stellarRadiusInSolarRadii(iTarget); % offset by 2.4e-9
    dataSpanInCadences(iTarget) = tpsInjectionStruct.dataSpanInCadences(iTarget);
    % dutyCycle(iTarget) = tpsInjectionStruct.numValidCadences(iTarget)./dataSpanInCadences(iTarget);
    dutyCycle(iTarget) = tpsInjectionStruct.dutyCycle(iTarget); % for KSOC-5004, dutyCycle is available
    isPlanetACandidate(iTarget) = tpsInjectionStruct.isPlanetACandidate(iTarget);
    
    % Retrieve the keplerMag from the tce struct
    isTarget = ismember(keplerIdTps,keplerId(iTarget));
    tmp = keplerMagTps(isTarget,1);
    keplerMag(iTarget) = tmp(1);
    tmp2 = keplerIdTps(isTarget,1);
    keplerIdCheck(iTarget) = tmp2;
    
    % Progress indicator
    if(mod(iTarget,100)==0)
        fprintf('iTarget %d of %d\n',iTarget,nTargets)
    end
    
    % Prepare for next target
    clear inputsStruct
    
end
toc



%==========================================================================
% Could actually get the stellar parameters
% effectiveTemp, keplerMag, log10Metallicity, log10SurfaceGravity, and
% stellarRadiusInSolarRadii
% from tpsV4StellarParametersCatalog.mat, which is archived in catalogDir


% Identify unique targets
[~, iUnique, ~] = unique(keplerId);

% Pack up the stellar parameters into a struct
stellarParameterStruct.taskfileIndex = iUnique;
stellarParameterStruct.keplerId = keplerId(iUnique);
stellarParameterStruct.log10SurfaceGravity = log10SurfaceGravity(iUnique);
stellarParameterStruct.log10Metallicity = log10Metallicity(iUnique);
stellarParameterStruct.effectiveTemp = effectiveTemp(iUnique);
stellarParameterStruct.stellarRadiusInSolarRadii = stellarRadiusInSolarRadii(iUnique);
stellarParameterStruct.rmsCdpp = rmsCdpp(iUnique,:);
stellarParameterStruct.dataSpanInCadences = dataSpanInCadences(iUnique);
stellarParameterStruct.dutyCycle = dutyCycle(iUnique);
stellarParameterStruct.keplerMag = keplerMag(iUnique);

% Save the output file
save(strcat(saveDir,groupLabel,'_stellar_parameters.mat'),'stellarParameterStruct')




