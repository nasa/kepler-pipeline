function build_tps_inputs_from_pdc_outputs(pdcTopDir,tpsInputStruct)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% build_tps_inputs_from_pdc_outputs
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Inputs
%     pdcTopDir: the top directory of the PDC for which the TPS inputs will
%         be built from
%     tpsInputStruct: A tpsInputStruct that contains the
%         tpsModuleParameters, gapFillParameters, bootstrapParameters,
%         harmonicsIdentificationParameters, tpsTargets, rollTimeModel,
%         cadenceTimes, taskTimeoutSecs, and tasksPerCore.  Note that some
%         of this is not used at all but is checked for in the input
%         validator and the tpsClass object constructor.  The important
%         thing here is to make sure that the tpsModuleParameters,
%         gapFillParameters, bootstrapParameters, and
%         harmonicsIdentificationParameters are set how they should be for
%         the subsequent TPS runs that will use the inputs built here.
%
% Outputs
%      The output is a set of TPS inputs saved to the working directory.
%
%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
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

% skyGroup is required by the tpsClass object constructor and the input
% validator but it is meaningless in K2 and never gets used anyway
tpsInputStruct.skyGroup = -1;

% explicitly disable collection of bootstrap diagnostics to save time
tpsInputStruct.tpsModuleParameters.collectBootstrapDiagnostics = false;

% explicitly disable the weak secondary test
tpsInputStruct.tpsModuleParameters.performWeakSecondaryTest = false;

% input file name
saveFilenameBase = 'tps-inputs-0.mat';

% acquire the full list of subdirectories to topDir, removing the '.' and '..' instances
subdirList = get_list_of_subdirs( pdcTopDir ) ;
nDirs = length(subdirList) ;

% keep only subdirs that have pdc-matlab in their name
keepIndicator = false(nDirs,1);
for iDir = 1:nDirs
    if ~isempty(strfind(subdirList(iDir).name,'pdc-matlab'))
        keepIndicator(iDir) = true;
    end
end
subdirList = subdirList(keepIndicator);
nDirs = length(subdirList) ;

% initialize
runIdentifier = [];
taskIdentifier = 0;

for iDir = 1:nDirs
    pdcFilename = fullfile(pdcTopDir,subdirList(iDir).name,'st-0','pdc-inputs-0.mat');
    pdcInput = load(pdcFilename);
    pdcInput = pdcInput.inputsStruct;
    pdcFilename = fullfile(pdcTopDir,subdirList(iDir).name,'st-0','pdc-outputs-0.mat');
    pdcOutput = load(pdcFilename);
    pdcOutput = pdcOutput.outputsStruct;
    
    if isempty(runIdentifier)
        % get the run identifier
        dashIndices = strfind(subdirList(iDir).name,'-');
        runIdentifier = str2num( subdirList(iDir).name(dashIndices(end-1)+1:dashIndices(end)-1));
        
        % build the top directory to hold the tps inputs
        dirName = strcat('tps-matlab-',num2str(runIdentifier));
        if ~exist( dirName, 'dir' )
            mkdir(dirName) ;
        end
    end
    
    % get the cadenceTimes
    cadenceTimes = pdcInput.cadenceTimes;
    cadenceTimes = rmfield(cadenceTimes,{'serialVersionUID','months'});
    
    nChannels = length(pdcInput.channelDataStruct);
    for iChannel = 1:nChannels
        % get the task directory name and build directory
        taskDirName = strcat(dirName,'-',num2str(taskIdentifier));
        if ~exist(fullfile(dirName,taskDirName),'dir')
            mkdir(fullfile(dirName,taskDirName)) ;
        end
        
        % do the subtask level work
        subtaskIdentifier = 0;
        nTargets = length(pdcInput.channelDataStruct(iChannel).targetDataStruct);
        for iTarget = 1:nTargets
            
            % make the subtask dir
            subtaskDirName = strcat('st-',num2str(subtaskIdentifier));
            if ~exist(fullfile(dirName,taskDirName,subtaskDirName),'dir')
                mkdir(fullfile(dirName,taskDirName,subtaskDirName)) ;
            end
            
            % build the empty target struct
            tpsTarget = struct('keplerId',[],'diagnostics',[],'fluxValue',[], ...
                'uncertainty',[],'gapIndices',[],'fillIndices',[],'outlierIndices',[], ...
                'discontinuityIndices',[],'quarterGapIndicators',[]);
            
            % get the keplerId and map to the output struct
            kepId = pdcInput.channelDataStruct(iChannel).targetDataStruct(iTarget).keplerId;
            kepIdIndicator = ismember([pdcOutput.targetResultsStruct.keplerId],kepId);
            
            % build the target struct
            pdcTarget = pdcOutput.targetResultsStruct(kepIdIndicator);
            tpsTarget.keplerId = pdcTarget.keplerId;
            tpsTarget.fluxValue = pdcTarget.correctedFluxTimeSeries.values;
            tpsTarget.uncertainty = pdcTarget.correctedFluxTimeSeries.uncertainties;
            tpsTarget.fillIndices = pdcTarget.correctedFluxTimeSeries.filledIndices;
            tpsTarget.outlierIndices = pdcTarget.outliers.indices;
            tpsTarget.discontinuityIndices = pdcTarget.discontinuityIndices;
            tpsTarget.quarterGapIndicators = false(1,1); % targets are observed in one campaign
            tpsTarget.diagnostics.keplerMag = pdcInput.channelDataStruct(iChannel).targetDataStruct(iTarget).keplerMag; 

            % build the input struct
            inputsStruct = tpsInputStruct;
            inputsStruct.cadenceTimes = cadenceTimes;
            inputsStruct.tpsTargets = tpsTarget;
            
            % save the input
            saveFilename = fullfile(dirName,taskDirName,subtaskDirName,saveFilenameBase);
            save(saveFilename,'inputsStruct');
            
            % increment for next subtask dir
            subtaskIdentifier = subtaskIdentifier + 1;
        end
        
        % increment for next task dir
        taskIdentifier = taskIdentifier + 1;
    end
end

return