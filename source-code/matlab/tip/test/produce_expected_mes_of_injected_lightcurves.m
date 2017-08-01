% function produce_expected_mes_of_injected_lightcurves( inputStruct )
%
% This tool crawls through the TIP .txt file, PA, PDC and TPS task files for each skygroup identified in the TPS task files root directory
% and assembles the dataStruct defined in the output below.
%
% INPUT:    inputStruct is a structure containing the following fields:
% 
%           paTaskFilesRoot: [1xnQuarter cell array]     each cell entry contains the full path name to a quarter of PA task files
%                                                        w/transitInjectionEnaled = true
%          pdcTaskFilesRoot: [1xnQuarter cell array]     each cell entry contains the full path name to a quarter of PDC task files
%                                                        w/transitInjectionEnaled = true 
%          tpsTaskFilesRoot: [string]                    full path to TPS task files covering the PA and PDC quarters
%                 configMap: [1x1 struct]                spacecraftConfigMap from any CAL or PA inputsStruct
%                 nQuarters: int                         number of quarters
%       nasStyleDirectories: [logical]                   true = group style structure used on NAS, false = cluster style (non-group or single group)
%            outputFileRoot: [string]                    root of output files generated for each skygroup (outputFileRoot-skygroup#.mat)
%   minimumNumberOfTransits: [float]                     minimum number of transits needed to compute expectedMes
%        enableTpsWindowing: [logical]                   true == use deemphasis weights from TPS in computing expectedMes
%    updateDurationAndDepth: [logical]                   true == update the TIP transit duration using the injected transitModelStruct
%         produceMapStructs: [logical]                   true == force production or reproduction of map structs for PA, PDC and TPS
%         excludedSkygroups: [int array]                 list of skygroups to exclude from processing
%
% OUTPUT:   .mat files are generated for each skygroup (outputFileRoot-skygroup#.mat) and stored in the current run directory.
%
%           These .mat file contain a single data structure (data) with the following fields:
%
%             cadenceNumbers: [nCadences x 1 double]
%                   keplerId: [1 x nTipTargets double]
%             uniqueKeplerId: [1 x nUniqueTipTargets double]
%                 skyGroupId: 18
%                tipDepthPpm: [1 x nTipTargets double]
%                     tipSes: [1 x nTipTargets double]
%                tipEpochBjd: [1 x nTipTargets double]
%              tipPeriodDays: [1 x nTipTargets double]
%           tipDurationHours: [1 x nTipTargets double]
%          paTransitDepthPpm: [nQuarters x nTipTargets double]
%               paMedianFlux: [nQuarters x nTipTargets double]
%     fluxFractionInAperture: [nQuarters x nUniqueTipTargets double]
%             crowdingMetric: [nQuarters x nUniqueTipTargets double]
%        inTransitNormalized: [nCadences x nTipTargets logical]
%           
%         pdcTransitDepthPpm: [nQuarters x nTipTargets double]
%              tpsPulseMatch: [1 x nTipTargets double]
%       tpsMeanInTransitCdpp: [1 x nTipTargets double]
%                     tpsMes: [1 x nTipTargets double]
%                     tpsSes: [1 x nTipTargets double]
%                 tpsRmsCdpp: [1 x nTipTargets double]
%               nTransitsInt: [1 x nTipTargets double]
%              nTransitsFrac: [1 x nTipTargets double]
%          nTransitsWindowed: [1 x nTipTargets double]
%                apertureMes: [1 x nTipTargets double]
%              tpsPeriodDays: [1 x nTipTargets double]
%                tpsEpochMjd: [1 x nTipTargets double]
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

function produce_expected_mes_of_injected_lightcurves( inputStruct )

% unpack flags
enableTpsWindowing = inputStruct.enableTpsWindowing;
updateDurationAndDepth = inputStruct.updateDurationAndDepth;
produceMapStructs = inputStruct.produceMapStructs;
excludedSkygroups = inputStruct.excludedSkygroups;
minTpsTransitCount = inputStruct.minTpsTransitCount;
if isfield(inputStruct,'forceAggregateCreate')
    forceAggregateCreate = inputStruct.forceAggregateCreate;
else
    forceAggregateCreate = true;                                % default
end
if isfield(inputStruct,'vetoAggregateWrite')
    vetoAggregateWrite = inputStruct.vetoAggregateWrite;
else
    vetoAggregateWrite = false;                                % default
end
if isfield(inputStruct,'writeAggregateLocally')
    writeAggregateLocally = inputStruct.writeAggregateLocally;
else
    writeAggregateLocally = false;                                % default
end

% minimum number of transits needed to produce apertureMes
minimumNumberOfTransits = inputStruct.minimumNumberOfTransits;

% hard coded masks and filenames
TEMP_PA_DATA_MASK = 'temp-pa-data-q';
TEMP_PDC_DATA_MASK = 'temp-pdc-data-q';
TPS_DAWG_FILE_MASK = 'tps-dawg-struct-';
TASKFILE_MAP = 'task-file-map.mat';

PA_TRANSIT_INJECTION_STATE_FILE = 'pa_simulated_transits.mat';
PA_STAR_RESULTS_FILE = 'pa_target_aggregate_results.mat';
% PA_STATE_FILE = 'pa_state.mat';
TPS_OUTPUT_FILE = 'tps-outputs-0.mat';
TPS_INPUT_FILE = 'tps-inputs-0.mat';


% extract filenames and paths from inputStruct
paTaskFilesRoot  = inputStruct.paTaskFilesRoot;                 % cell array - one entry for each quarter (cluster style) or single entry (NAS style)
pdcTaskFilesRoot = inputStruct.pdcTaskFilesRoot;                % cell array - one entry for each quarter (cluster style) or single entry (NAS style)
tpsTaskFilesRoot = inputStruct.tpsTaskFilesRoot;                % char array (string) since tps operates on multiple quarters
if isfield(inputStruct,'targetChunkSize')
    targetChunkSize  = inputStruct.targetChunkSize;             % [double];number of TIP targets to process in one pass
else
    targetChunkSize = 2500;                                     % default
end

% count quarters
if inputStruct.nasStyleDirectories
    nQuarters = inputStruct.nQuarters;
    % replicate paTaskFileRoot
    X = cell(nQuarters,1);
    Y = cell(nQuarters,1);
    for iQuarter = 1:nQuarters
        X{iQuarter} = paTaskFilesRoot{1};
        Y{iQuarter} = pdcTaskFilesRoot{1};
    end
    paTaskFilesRoot = X;
    pdcTaskFilesRoot = Y;
else
    nQuarters = length(paTaskFilesRoot);
end
paMapStructCellArray = cell(nQuarters,1);
pdcMapStructCellArray = cell(nQuarters,1);


% extract paMap and pdcMap for each quarter
for iQuarter = 1:nQuarters    
        
    % generate PA map struct for quarter or load it
    % PA map will include TIP file location
    if ~exist([paTaskFilesRoot{iQuarter},TASKFILE_MAP],'file') || produceMapStructs
        disp(['Producing PA task file map for quarter ...',num2str(iQuarter),'...']);
        paMapStruct = produce_matlab_taskfile_map( paTaskFilesRoot{iQuarter}, 'pa' );
        save([paTaskFilesRoot{iQuarter},TASKFILE_MAP],'paMapStruct');
    else
        disp(['Loading PA task file map for quarter ...',num2str(iQuarter),'...']);
        disp([paTaskFilesRoot{iQuarter},TASKFILE_MAP]);
        if ~exist('s','var') || ~inputStruct.nasStyleDirectories
            s = load([paTaskFilesRoot{iQuarter},TASKFILE_MAP]);
        end
        paMapStruct = s.mapOut;
        idx = [paMapStruct.quarter]==iQuarter;
        paMapStruct = paMapStruct(idx);
    end
    paMapStructCellArray{iQuarter} = paMapStruct;
    
    % generate PDC map struct for quarter or load it
    if ~exist([pdcTaskFilesRoot{iQuarter},TASKFILE_MAP],'file') || produceMapStructs
        disp(['Producing PDC task file map for quarter ',num2str(iQuarter),'...']);
        pdcMapStruct = produce_matlab_taskfile_map( pdcTaskFilesRoot{iQuarter}, 'pdc' );
        save([pdcTaskFilesRoot{iQuarter},TASKFILE_MAP],'pdcMapStruct');
    else
        disp(['Loading PDC task file map for quarter ...',num2str(iQuarter),'...']);
        disp([pdcTaskFilesRoot{iQuarter},TASKFILE_MAP]);
        if ~exist('p','var') || ~inputStruct.nasStyleDirectories
            p = load([pdcTaskFilesRoot{iQuarter},TASKFILE_MAP]);
        end
        pdcMapStruct = p.mapOut;
        idx = [pdcMapStruct.quarter]==iQuarter;
        pdcMapStruct = pdcMapStruct(idx);        
    end
    pdcMapStructCellArray{iQuarter} = pdcMapStruct;    

end

% clear PA and PDC task file map input
clear s p;

% extract tpsMap
if ~exist([tpsTaskFilesRoot,TASKFILE_MAP],'file') || produceMapStructs
    disp('Producing TPS task file map for quarter ...');
    tpsMapStruct = produce_matlab_taskfile_map( tpsTaskFilesRoot, 'tps' );
    save([tpsTaskFilesRoot,TASKFILE_MAP],'tpsMapStruct');
else
    disp('Loading TPS task file map for quarter ...');
    disp([tpsTaskFilesRoot,TASKFILE_MAP]);
    s = load([tpsTaskFilesRoot,TASKFILE_MAP]);
    tpsMapStruct = s.mapOut;
end

% clear TPS task file map input
clear s;

% extract skygroupIds from tpsMapStruct which will include all quarters - exclude selected skygroups
skygroup = setdiff([tpsMapStruct.skyGroupId],excludedSkygroups);
nSkygroups = length(skygroup);

% loop over skygroups
for iSkygroup = 1:nSkygroups    
    disp('  ');
    disp(['Doing skygroup ',num2str(skygroup(iSkygroup)),' ...']);
    
    % set up output filename root
    outputFileroot = [inputStruct.outputFileRoot,num2str(skygroup(iSkygroup),'%02i')];
        
    % get TPS pulse durations
    disp('Getting avaliable TPS pulse durations from TPS DAWG struct ...');
    skyGroupIndex = find([tpsMapStruct.skyGroupId] == skygroup(iSkygroup));
    D = dir([tpsMapStruct(skyGroupIndex).taskFileFullPath,TPS_DAWG_FILE_MASK,'*.mat']);
    if length(D) > 1
        error('Multpile TPS dawg structs at taskfile root level');
    elseif length(D) < 1
        error('No TPS dawg structs at taskfile root level');
    end
    S = load([tpsMapStruct(skyGroupIndex).taskFileFullPath,D(1).name]);
    tpsPulseDurations = S.tpsDawgStruct.pulseDurations;
    clear S;    
    
    
    % initialize chunk variables
    chunksDone = false;
    iChunk = 0;
    chunkStart = 1;
    
    while ~chunksDone        

        % update chunk variables
        iChunk = iChunk +1;
        chunkIndices = chunkStart:(chunkStart + targetChunkSize - 1);
        disp(['*** Doing chunk ',num2str(iChunk),' ...']);
        
        % save inputStruct in the outputs
        data.inputStruct = inputStruct;
        
        % set up data structs to be reused for each quarter (chunk)
        paDataStruct = struct('keplerId',[],...
            'maskIntoTipIds',[],...
            'quarter',[],...
            'season',[],...
            'skyGroupId',[],...
            'tpsPulseDurations',[],...
            'cadenceNumbers',[],...
            'paTransitDepthPpm',[],...
            'paMeanTransitDepthPpm',[],...
            'paMeanTransitDepthPpmTps',[],...
            'paMedianFlux',[],...
            'inTransitNormalized',[],...
            'inTransitNormalizedTps',[],...
            'centralTransitLogical',[],...
            'nTransitsInt',[],...
            'nTransitsFract',[],...
            'nTransitsFractTps',[],...
            'tipDepthPpm',[],...
            'tipSes',[],...
            'tipEpochBjd',[],...
            'tipPeriodDays',[],...
            'tipDurationHours',[],...
            'tpsDurationHours',[],...
            'transitModelDurationHours',[],...
            'transitModelDepthPpm',[],...
            'barycentricTimestamps',[],...
            'taskFileFullPath',[]);
        
        pdcDataStruct = struct('keplerId',[],...
            'indexIntoTipIds',[],...
            'quarter',[],...
            'season',[],...
            'skyGroupId',[],...
            'fluxFractionInAperture',[],...
            'crowdingMetric',[],...
            'cadenceNumbers',[],...
            'taskFileFullPath',[]);
        

        
        % initialize TIP filename, simulationStructure and cadenceNumbers
        tipFilename = '';
        masterSimStruct = [];
        paCadenceNumbers = [];
        
        % one root per PA quarter
        for iQuarter = 1:nQuarters
            
            % READ THE PA TRANSIT INJECTION FILE plus any other PA outputs needed---------------
            
            paMapStruct = paMapStructCellArray{iQuarter};
            skyGroupIndex = find([paMapStruct.skyGroupId] == skygroup(iSkygroup));
            
            if ~isempty(skyGroupIndex)
                               
                % Read the TIP file for skygroup - the content of this file should be the same for all quarters even though the TIP files per
                % quarter exist as separate blob files in the task file directories. Should only need to read this once, tipInput will be good
                % for all quarters. Set target chunk variables and flags
                if isempty(tipFilename)
                    tipFilename = [paMapStruct(skyGroupIndex).taskFileFullPath,paMapStruct(skyGroupIndex).tipFilename];
                    tipInput = read_simulated_transit_parameters(tipFilename);
                    
                    % operate on sorted tipInput lists - sort by keplerId
                    tipInput = sort_tip_input(tipInput,'keplerId');
                    
                    % identify chunk targets
                    chunkIdx = intersect(1:length(tipInput.keplerId),chunkIndices);
                    chunkKeplerIds = unique(tipInput.keplerId(chunkIdx));
                    
                    % update chunk start indices
                    tf = ismember(tipInput.keplerId,chunkKeplerIds);
                    chunkStart = find(tf,1,'last') + 1;
                    
                    % check if done with chunks
                    if chunkStart > length(tipInput.keplerId)
                        chunksDone = true;
                    end 
                    
                    % set singleChunk flag
                    singleChunk = chunksDone && iChunk == 1;
                    
                    % select chunk of input
                    tipInput = select_tip_input(tipInput,chunkKeplerIds);
                end
                
                
                % there should only be one task file set per skygroup - rather than error out we will pick one
                if length(skyGroupIndex) > 1
                    disp(['MULTIPLE PA TASK FILE SETS AVAILABLE FOR SKYGROUP ',num2str(skygroup(iSkygroup))]);
                    skyGroupIndex = skyGroupIndex(1);
                    disp(['Selecting set ',paMapStruct(skyGroupIndex).taskFileFullPath]);
                end
                
                disp(['Doing PA for quarter ',num2str(paMapStruct(skyGroupIndex).quarter),' ...']);                
                                
                % Aggregate transit injection state files or load already aggregated file
                % This loads the following variables into P:
                % cadenceModified                  nCadences x nTargets
                % fractionSignalSubtracted         nCadences x nTargets
                % keplerIds                        1 x nTargets
                % prfFailed                        nCadences x nTargets
                % transitParameterStructArray      1 x nInjectedTargets
                
                % choose local or remote (i.e. taskfile) filename
                if writeAggregateLocally
                    filename = ['q',num2str(iQuarter),'-',PA_TRANSIT_INJECTION_STATE_FILE];
                else
                    filename = [paMapStruct(skyGroupIndex).taskFileFullPath,PA_TRANSIT_INJECTION_STATE_FILE];
                end
                
                % load or create
                if (forceAggregateCreate && iChunk == 1) || ~exist(filename,'file')
                    % 'false' option does not write aggregated file to task file path
                    writeFileLogical = ~vetoAggregateWrite && ~writeAggregateLocally;
                    P = aggregate_transit_injection_state_files(paMapStruct(skyGroupIndex).taskFileFullPath, PA_TRANSIT_INJECTION_STATE_FILE, writeFileLogical );
                    if ~vetoAggregateWrite && writeAggregateLocally
                        if singleChunk
                            disp(['Single chunk. Do *not* write ',filename,' to local directory.']);
                        else
                            disp(['Saving aggregated state file ',filename,' ...']);
                            % check the size first and save with appropriate switch (sort of)
                            p = whos('P');
                            if p.bytes > 2e9
                                save(filename,'-struct','P','-v7.3');
                            else
                                save(filename,'-struct','P');
                            end
                            
                        end
                    end
                else
                    disp(['Loading ',PA_TRANSIT_INJECTION_STATE_FILE,' ...']);
                    P = load(filename);
                end
                
                % if no aggregate transit injection data is available - punt
                if isempty(P)
                    disp(['No transits injected for any target for quarter ',num2str(paMapStruct(skyGroupIndex).quarter),'.']);
                    continue;
                end
                
                
                % While processing the first quarter build a simulatedTransitsStruct from the TIP input file. This populates masterSimStruct
                % with meta-data + a transitModelStructArray for each entry in the TIP in put file in the same order as the entries in the TIP
                % input file. This masterSimStrcut would be the same using the TIP file from any quarter.
                if isempty( masterSimStruct )
                    masterSimStruct = build_simulated_transits_struct_from_tip_text_file( tipFilename, chunkKeplerIds );
                    masterSimStruct.configMaps = inputStruct.configMap;
                    % update planet models and add transitDurationHours and transitDepthPpm using observable parameters from transit model
                    if updateDurationAndDepth
                        masterSimStruct = update_planet_model_with_derived_parameters(masterSimStruct);
                    end
                end
                
                % find the TIP targets in common with PA targets - note TIP targets could contain duplicate keplerIds if more than one planet was
                % injected
                tipIds = tipInput.keplerId;
                tf = ismember(tipIds, P.keplerIds);
                uniquePaTargets = unique(tipInput.keplerId(tf));
                
                % extract TIP data per target and set paDataStruct for quarter
                paDataStruct.keplerId = tipInput.keplerId(tf)';                       % transpose to get right shape for concatenation later
                paDataStruct.maskIntoTipIds = tf;                                     % save logical mask so we can combine quarters later
                paDataStruct.quarter = paMapStruct(skyGroupIndex).quarter;
                paDataStruct.season = paMapStruct(skyGroupIndex).season;
                paDataStruct.skyGroupId = paMapStruct(skyGroupIndex).skyGroupId;
                paDataStruct.tpsPulseDurations = tpsPulseDurations;
                paDataStruct.cadenceNumbers = paMapStruct(skyGroupIndex).cadenceTimes.cadenceNumbers';    % transpose to get right shape for concatenation later
                paDataStruct.tipDepthPpm = tipInput.transitDepthPpm(tf);
                paDataStruct.tipSes = tipInput.singleEventStatistic(tf);
                paDataStruct.tipEpochBjd = tipInput.epochBjd(tf);
                paDataStruct.tipPeriodDays = tipInput.orbitalPeriodDays(tf);
                paDataStruct.tipDurationHours = tipInput.transitDurationHours(tf);
                paDataStruct.taskFileFullPath = paMapStruct(skyGroupIndex).taskFileFullPath;
                
                % include any updates
                if updateDurationAndDepth
                    planetModels = [masterSimStruct.transitModelStructArray.planetModel];
                    paDataStruct.transitModelDurationHours = rowvec([planetModels(tf).transitDurationHours]);
                    paDataStruct.transitModelDepthPpm = rowvec([planetModels(tf).transitDepthPpm]);
                else
                    paDataStruct.transitModelDurationHours = paDataStruct.tipDurationHours;
                    paDataStruct.transitModelDepthPpm = paDataStruct.tipDepthPpm;
                end
                
                
                % ----------------- I think we will need the barycentric time stamps in order to get the transit timing right for estimating PA
                % ----------------- transit depth.  YES, WE DO! This is available in the aggregated pa_state.mat file in paTargetStarResultsStruct
                % ----------------- barycentricOffset is added to the mid timestamp to produce the correct timing for the transit model
                
                % choose local of remote aggregate filename (remote == taskfile directory from mapOut)
                if writeAggregateLocally
                    filename = ['q',num2str(iQuarter),'-',PA_STAR_RESULTS_FILE];
                else
                    filename = [paMapStruct(skyGroupIndex).taskFileFullPath,PA_STAR_RESULTS_FILE];
                end
                
                % load single variable paTargetStarResultsStruct from the PA_STAR_RESULTS_FILE if it exists, otherwise create this aggregate and save
                if (forceAggregateCreate && iChunk == 1) || ~exist(filename,'file')
                    disp(['Creating ',PA_STAR_RESULTS_FILE,' ...']);                   
                    S = aggregate_paTargetStarResults_fields_from_pa_state_files( paMapStruct(skyGroupIndex).taskFileFullPath, {'keplerId', 'barycentricTimeOffset'} );
                    
                    % save file as PA_STAR_RESULTS_FILE
                    if isempty(S)
                        error('PA state files not found. Cannot compile baraycentric timestamps for targets.');
                    else
                        if ~vetoAggregateWrite
                            if singleChunk && writeAggregateLocally
                                disp(['Single chunk. Do *not* write ',filename,' to local directory.']);
                            else
                                disp(['Saving aggregated target results file ',filename,' ...']);
                                % check the size first and save with appropriate switch
                                p = whos('S');
                                if p.bytes > 2e9
                                    save(filename,'-struct','S','-v7.3');
                                else
                                    save(filename,'-struct','S');
                                end
                            end
                        end
                    end
                else
                    disp(['Loading ',PA_STAR_RESULTS_FILE,' ...']);
                    S = load(filename,'paTargetStarResultsStruct');
                end
                
                % trim the resultsStruct to only include ones in uniquePaTargets
                tf = ismember( [S.paTargetStarResultsStruct.keplerId], uniquePaTargets );
                S.paTargetStarResultsStruct = S.paTargetStarResultsStruct(tf);
                paResultsKeplerIds = [S.paTargetStarResultsStruct.keplerId];
                
                % to generate a model light curve we need the transitModelStruct from simulatedTransitsStruct
                % these targets will be the same as the TIP targets and in the same order
                simulatedTransitsStruct = masterSimStruct;
                simulatedTransitsKeplerIds = simulatedTransitsStruct.keplerId;
                
                % add timestamps and configMap to all transit model structs - needed to instantiate transit generator object
                cadenceTimes = paMapStruct(skyGroupIndex).cadenceTimes;
                for iStruct = 1:length(simulatedTransitsStruct.transitModelStructArray)
                    simulatedTransitsStruct.transitModelStructArray(iStruct).cadenceTimes = cadenceTimes.midTimestamps;
                end
                
                % extract barycentric offsets for target and add to timestamps
                barycentricLogical = true(size(uniquePaTargets));
                for iTarget = 1:length(uniquePaTargets)
                    idx = find( paResultsKeplerIds == uniquePaTargets(iTarget) );
                    if ~isempty(idx)
                        offsets = S.paTargetStarResultsStruct(idx).barycentricTimeOffset.values;
                        tf = ismember( simulatedTransitsKeplerIds, uniquePaTargets(iTarget));
                        if any(tf)
                            idx = find(tf);
                            for tempIndex = rowvec(idx)
                                simulatedTransitsStruct.transitModelStructArray(tempIndex).cadenceTimes = cadenceTimes.midTimestamps + offsets;
                            end
                        end
                    else
                        barycentricLogical(iTarget) = false;
                    end
                end
                clear S;
                
                % display a message for any targets w/o bary timestamps
                if any(~barycentricLogical)
                    disp(['No barycentric offsets available for ',num2str(numel(find(~barycentricLogical))),' injected targets']);
                end
                
                % find the fractional transit depth injected in PA and update paDataStruct for quarter
                depthOutputStruct = estimate_pa_transit_depth( P, paDataStruct, simulatedTransitsStruct );
                
                % clear memory
                clear P;
                
                paDataStruct.paTransitDepthPpm = depthOutputStruct.paTransitDepthPpm;
                paDataStruct.paTransitDepthPpmTps = depthOutputStruct.paTransitDepthPpmTps;                 % *************  possibly not needed
                paDataStruct.paMeanTransitDepthPpm = depthOutputStruct.paMeanTransitDepthPpm;
                paDataStruct.paMeanTransitDepthPpmTps = depthOutputStruct.paMeanTransitDepthPpmTps;
                
                paDataStruct.inTransitNormalized = depthOutputStruct.inTransitNormalized;
                paDataStruct.inTransitNormalizedTps = depthOutputStruct.inTransitNormalizedTps;
                paDataStruct.centralTransitLogical = depthOutputStruct.centralTransitLogical;
                
                paDataStruct.nTransitsInt = depthOutputStruct.nTransitsInt;
                paDataStruct.nTransitsFrac = depthOutputStruct.nTransitsFrac;
                paDataStruct.nTransitsFracTps = depthOutputStruct.nTransitsFracTps;
                
                paDataStruct.paMedianFlux = depthOutputStruct.paMedianFlux;
                paDataStruct.barycentricTimestamps = depthOutputStruct.barycentricTimestamps;
                paDataStruct.tpsDurationHours = depthOutputStruct.tpsDurationHours;
                
                % concatenate things that need to be
                paCadenceNumbers = [paCadenceNumbers, paDataStruct.cadenceNumbers];                         %#ok<AGROW>
                
                % save out paDataStruct for quarter to temporary file
                intelligent_save([TEMP_PA_DATA_MASK,num2str(iQuarter),'.mat'],'paDataStruct');
                                
            else
                disp(['No task file data for skygroup ',num2str(skygroup(iSkygroup)),' in ',paTaskFilesRoot{iQuarter}]);
            end
            
            
            % READ THE PDC FILES --------------------------------------------
            pdcMapStruct = pdcMapStructCellArray{iQuarter};
            skyGroupIndex = find([pdcMapStruct.skyGroupId] == skygroup(iSkygroup));
            
            if ~isempty(skyGroupIndex)
                
                % there should only be one task file set per skygroup - rather
                % than error out we will pick one
                if length(skyGroupIndex) > 1
                    disp(['MULTIPLE PDC TASK FILE SETS AVAILABLE FOR SKYGROUP ',num2str(skygroup(iSkygroup))]);
                    skyGroupIndex = skyGroupIndex(1);
                    disp(['Selecting set ',pdcMapStruct(skyGroupIndex).taskFileFullPath]);
                end
                
                disp(['Doing PDC for quarter ',num2str(pdcMapStruct(skyGroupIndex).quarter),' ...']);
                
                % load pdc inputs to get crowding metric and flux fraction in aperture for each target
                if exist([pdcMapStruct(skyGroupIndex).taskFileFullPath,'pdc-inputs-0.mat'],'file')
                    disp('Loading pdc inputs ...');
                    S = load([pdcMapStruct(skyGroupIndex).taskFileFullPath,'pdc-inputs-0.mat']);
                else
                    error([pdcMapStruct(skyGroupIndex).taskFileFullPath,'pdc-inputs-0.mat',' not available. No CM or FFIA for skygroup ',num2str(skygroup(iSkygroup))]);
                end
                
                cadenceNumbers = S.inputsStruct.cadenceTimes.cadenceNumbers;
                targetDataStruct = S.inputsStruct.channelDataStruct.targetDataStruct;
                pdcKeplerId = [targetDataStruct.keplerId];
                crowdingMetric = [targetDataStruct.crowdingMetric];
                fluxFractionInAperture = [targetDataStruct.fluxFractionInAperture];
                clear S;
                
                % select only keplerIds with injected transits for output
                [tf, idx] = ismember(pdcKeplerId, tipIds);
                
                % set output
                pdcDataStruct.keplerId = pdcKeplerId(tf);
                pdcDataStruct.indexIntoTipIds = idx(tf);
                pdcDataStruct.quarter = pdcMapStruct(skyGroupIndex).quarter;
                pdcDataStruct.season = pdcMapStruct(skyGroupIndex).season;
                pdcDataStruct.skyGroupId = pdcMapStruct(skyGroupIndex).skyGroupId;
                pdcDataStruct.fluxFractionInAperture = fluxFractionInAperture(tf);
                pdcDataStruct.crowdingMetric = crowdingMetric(tf);
                pdcDataStruct.cadenceNumbers = cadenceNumbers';                                    % transpose for concatenation later
                pdcDataStruct.taskFileFullPath = pdcMapStruct(skyGroupIndex).taskFileFullPath;
                
                % save out paDataStruct for quarter to temporary file
                intelligent_save([TEMP_PDC_DATA_MASK,num2str(iQuarter),'.mat'],'pdcDataStruct');
                
            end
        end
        
        
        % combine multi quarter PA/PDC data into one struct
        % this will be the data struct written to the output file
        
        % get total pa cadences
        data.cadenceNumbers = paCadenceNumbers;
        nCadences = length(data.cadenceNumbers);
        
        % add lists corresponding to keplerId and uniqueKeplerId
        targetIds           = tipInput.keplerId;
        nTargets            = length(targetIds);
        uniqueTargetIds     = unique(targetIds);
        nUniqueTargets      = length(uniqueTargetIds);
        data.keplerId       = targetIds(:)';
        data.uniqueKeplerId = uniqueTargetIds(:)';
        data.skyGroupId     = unique([paDataStruct.skyGroupId]);
        data.configMaps     = inputStruct.configMap;
        
        data.transitModelStructArray = masterSimStruct.transitModelStructArray;
        data.tipFilename = tipFilename;
        
        % use data struct as temporary storage
        data.tipDepthPpm                = nan(nQuarters, nTargets);
        data.tipSes                     = nan(nQuarters, nTargets);
        data.tipEpochBjd                = nan(nQuarters, nTargets);
        data.tipPeriodDays              = nan(nQuarters, nTargets);
        data.tipDurationHours           = nan(nQuarters, nTargets);
        data.tpsDurationHours           = nan(nQuarters, nTargets);
        data.transitModelDurationHours  = nan(nQuarters, nTargets);
        data.transitModelDepthPpm       = nan(nQuarters, nTargets);
        data.paTransitDepthPpm          = nan(nQuarters, nTargets);
        data.paTransitDepthPpmTps       = nan(nQuarters, nTargets);
        data.paMeanTransitDepthPpm      = nan(nQuarters, nTargets);
        data.paMeanTransitDepthPpmTps   = nan(nQuarters, nTargets);
        data.paMedianFlux               = nan(nQuarters, nTargets);
        data.nTransitsInt               = nan(nQuarters, nTargets);
        data.nTransitsFrac              = nan(nQuarters, nTargets);
        data.nTransitsFracTps           = nan(nQuarters, nTargets);
        data.inTransitNormalized        = zeros(nCadences, nTargets);
        data.inTransitNormalizedTps     = zeros(nCadences, nTargets);
        data.centralTransitLogical      = false(nCadences, nTargets);
        data.barycentricTimestamps      = nan(nCadences, nTargets);
        data.fluxFractionInAperture     = nan(nQuarters, nUniqueTargets);
        data.crowdingMetric             = nan(nQuarters, nUniqueTargets);
        
        % step through each quarter and update the data fields
        cadenceIdx = 1;
        for iQuarter = 1:nQuarters
            
            % unset booleans
            paExist = false;
            pdcExist = false;
            
            % load paDataStruct and pdcDataStruct for quarter from files
            if exist([TEMP_PA_DATA_MASK,num2str(iQuarter),'.mat'],'file')
                Q = load([TEMP_PA_DATA_MASK,num2str(iQuarter),'.mat']);
                paExist = true;
                % remove temporary files for quarter
                delete([TEMP_PA_DATA_MASK,num2str(iQuarter),'.mat']);
            end
            if exist ([TEMP_PDC_DATA_MASK,num2str(iQuarter),'.mat'],'file')
                R = load([TEMP_PDC_DATA_MASK,num2str(iQuarter),'.mat']);
                pdcExist = true;
                % remove temporary files for quarter
                delete([TEMP_PDC_DATA_MASK,num2str(iQuarter),'.mat']);
            end
            
            if paExist
                % copy data for targets of interest
                tipMask = Q.paDataStruct.maskIntoTipIds;
                if any(tipMask)
                    % do PA
                    nQuarterCadences = length(Q.paDataStruct.cadenceNumbers);
                    data.tipDepthPpm(iQuarter,tipMask)          = Q.paDataStruct.tipDepthPpm;
                    data.tipSes(iQuarter,tipMask)               = Q.paDataStruct.tipSes;
                    data.tipEpochBjd(iQuarter,tipMask)          = Q.paDataStruct.tipEpochBjd;
                    data.tipPeriodDays(iQuarter,tipMask)        = Q.paDataStruct.tipPeriodDays;
                    data.tipDurationHours(iQuarter,tipMask)     = Q.paDataStruct.tipDurationHours;
                    data.tpsDurationHours(iQuarter,tipMask)     = Q.paDataStruct.tpsDurationHours;
                    data.paTransitDepthPpm(iQuarter,tipMask)    = Q.paDataStruct.paTransitDepthPpm;
                    data.paTransitDepthPpmTps(iQuarter,tipMask) = Q.paDataStruct.paTransitDepthPpmTps;
                    data.paMeanTransitDepthPpm(iQuarter,tipMask)= Q.paDataStruct.paMeanTransitDepthPpm;
                    data.paMeanTransitDepthPpmTps(iQuarter,tipMask)= Q.paDataStruct.paMeanTransitDepthPpmTps;
                    data.paMedianFlux(iQuarter,tipMask)         = Q.paDataStruct.paMedianFlux;
                    data.nTransitsInt(iQuarter,tipMask)         = Q.paDataStruct.nTransitsInt;
                    data.nTransitsFrac(iQuarter,tipMask)        = Q.paDataStruct.nTransitsFrac;
                    data.nTransitsFracTps(iQuarter,tipMask)     = Q.paDataStruct.nTransitsFracTps;
                    data.transitModelDurationHours(iQuarter,tipMask) = Q.paDataStruct.transitModelDurationHours;
                    data.transitModelDepthPpm(iQuarter,tipMask) = Q.paDataStruct.transitModelDepthPpm;
                    
                    % update cadence dependent arrays and update cadence index
                    data.inTransitNormalized(cadenceIdx:nQuarterCadences+cadenceIdx-1, tipMask) = Q.paDataStruct.inTransitNormalized;
                    data.inTransitNormalizedTps(cadenceIdx:nQuarterCadences+cadenceIdx-1, tipMask) = Q.paDataStruct.inTransitNormalizedTps;
                    data.centralTransitLogical(cadenceIdx:nQuarterCadences+cadenceIdx-1, tipMask) = Q.paDataStruct.centralTransitLogical;
                    data.barycentricTimestamps(cadenceIdx:nQuarterCadences+cadenceIdx-1, tipMask) = Q.paDataStruct.barycentricTimestamps;
                    cadenceIdx = cadenceIdx + nQuarterCadences;
                end
                if pdcExist
                    % do PDC
                    [tf, idx] = ismember( R.pdcDataStruct.keplerId, uniqueTargetIds );
                    data.fluxFractionInAperture(iQuarter,idx(tf)) = R.pdcDataStruct.fluxFractionInAperture(tf);
                    data.crowdingMetric(iQuarter,idx(tf)) = R.pdcDataStruct.crowdingMetric(tf);
                end
            end
        end
        
        
        % clear some memory
        clear Q R;
        
        % there should be only one value for the TIP parameters for each target - we could add some checks here
        data.tipDepthPpm = nanmedian(data.tipDepthPpm);
        data.tipSes = nanmedian(data.tipSes);
        data.tipEpochBjd = nanmedian(data.tipEpochBjd);
        data.tipPeriodDays = nanmedian(data.tipPeriodDays);
        data.tipDurationHours = nanmedian(data.tipDurationHours);
        data.tpsDurationHours = nanmedian(data.tpsDurationHours);
        data.transitModelDurationHours = nanmedian(data.transitModelDurationHours);
        data.transitModelDepthPpm = nanmedian(data.transitModelDepthPpm);
        
        % sum transits over quarters
        data.nTransitsInt = nansum(data.nTransitsInt);
        data.nTransitsFrac = nansum(data.nTransitsFrac);
        data.nTransitsFracTps = nansum(data.nTransitsFracTps);
        
        % apply PDC correction to transit depth (see KSOC-3417)
        % crowding metric and flux fraction in aperture are referenced to uniqueTargetIds while PA transit depth and PDC transit depth are
        % referenced to targetIds
        [tf, idx] = ismember( targetIds, uniqueTargetIds );
        data.pdcTransitDepthPpm(:,tf) = data.paTransitDepthPpm(:,tf) ./ data.crowdingMetric(:,idx(tf));
        data.pdcTransitDepthPpmTps(:,tf) = data.paTransitDepthPpmTps(:,tf) ./ data.crowdingMetric(:,idx(tf));
        data.pdcMeanTransitDepthPpm(:,tf) = data.paMeanTransitDepthPpm(:,tf) ./ data.crowdingMetric(:,idx(tf));
        data.pdcMeanTransitDepthPpmTps(:,tf) = data.paMeanTransitDepthPpmTps(:,tf) ./ data.crowdingMetric(:,idx(tf));
        
        % add TPS generated fields to data struct
        data.tpsPulseMatch = nan(1,nTargets);
        data.tpsMeanInTransitCdpp = nan(1,nTargets);
        data.tpsMes = nan(1,nTargets);
        data.tpsSes = nan(1,nTargets);
        data.tpsRmsCdpp = nan(1,nTargets);
        data.nTransitsWindowed = nan(1,nTargets);
        data.universeMes = nan(1,nTargets);
        data.apertureMes = nan(1,nTargets);
        data.windowedMes = nan(1,nTargets);
        data.universeMesMean = nan(1,nTargets);
        data.apertureMesMean = nan(1,nTargets);
        data.windowedMesMean = nan(1,nTargets);
        data.tpsPeriodDays = nan(1,nTargets);
        data.tpsEpochMjd = nan(1,nTargets);
        data.isPlanetCandidateTps = nan(1,nTargets);
        data.fitSinglePulseTip = nan(1,nTargets);
        data.fitSinglePulseTps = nan(1,nTargets);
        data.fitSinglePulse9p2 = nan(1,nTargets);
        
        
        % READ THE TPS FILES --------------------------------------------
        skyGroupIndex = find([tpsMapStruct.skyGroupId] == skygroup(iSkygroup));
        
        if ~isempty(skyGroupIndex)
            
            % there should only be one task file set per skygroup - rather
            % than error out we will pick one
            if length(skyGroupIndex) > 1
                disp(['MULTIPLE TPS TASK FILE SETS AVAILABLE FOR SKYGROUP ',num2str(skygroup(iSkygroup))]);
                skyGroupIndex = skyGroupIndex(1);
                disp(['Selecting set ',tpsMapStruct(skyGroupIndex).taskFileFullPath]);
            end
            
            disp('Doing TPS ...');
            
            D = dir([tpsMapStruct(skyGroupIndex).taskFileFullPath,TPS_DAWG_FILE_MASK,'*.mat']);
            
            if length(D) > 1
                error('Multpile TPS dawg structs at taskfile root level');
            elseif length(D) < 1
                error('No TPS dawg structs at taskfile root level');
            end
            
            % load tps dawg struct to get kepler ids and pulse durations for each target
            disp('Loading tps dawg struct ...');
            S = load([tpsMapStruct(skyGroupIndex).taskFileFullPath,D(1).name]);
            
            % save full path to tps task files for skygroup
            data.tpsRootPathForSkygroup = tpsMapStruct(skyGroupIndex).taskFileFullPath;
            
            % pick out the TIP kepler ids which match the TPS ids
            tpsKeplerId = S.tpsDawgStruct.keplerId;
            [tfTip, tpsIdx] = ismember( data.keplerId, tpsKeplerId );
            tipKeplerId = data.keplerId(tfTip);
            tipIdx = find(tfTip);
            
            % get planet cadidate flag across all pulse durations for all tps keplerIds
            isPlanetCandidateTps = any(S.tpsDawgStruct.isPlanetACandidate,2);
            
            % get tps cadence numbers and gaps
            tpsCadenceNumbers = tpsMapStruct(skyGroupIndex).cadenceTimes.cadenceNumbers;
            tpsGapIndicators = tpsMapStruct(skyGroupIndex).cadenceTimes.gapIndicators;
            
            % find valid tps cadence numbers in common with PA/PDC cadence numbers
            [tfTps, paCadenceIdx] = ismember(tpsCadenceNumbers, data.cadenceNumbers);
            
            
            % loop through the TIP keplerIds which have matches in TPS
            disp(['Looping through TPS inputs/outputs for ',num2str(length(tipKeplerId)),' TIP target entries ...']);
            for iTarget = 1:length(tipKeplerId)
                
                % A message!
                if floor(iTarget/500)*500 == iTarget
                    disp([num2str(iTarget),' entries done.'])
                end
                
                % keplerId we are working to
                tipId = data.keplerId(tipIdx(iTarget));
                
                % load the tps inputs and outputs for the pulse duration that most closely matches the tip duration
                % need to first get the subtask directory
                % tpsKeplerId is not necessarily unique but since all we need is the cdpp we will use the first keplerId match in the tps list
                subStrings = get_substrings(S.tpsDawgStruct.taskfile{tpsIdx(tipIdx(iTarget))},'/');
                tpsSubtask = subStrings{2};
                
                % load the tps inputs - assumes single target in subtask directory
                if exist([tpsMapStruct(skyGroupIndex).taskFileFullPath,tpsSubtask,filesep,TPS_INPUT_FILE],'file')
                    T = load([tpsMapStruct(skyGroupIndex).taskFileFullPath,tpsSubtask,filesep,TPS_INPUT_FILE]);
                else
                    disp([tpsMapStruct(skyGroupIndex).taskFileFullPath,tpsSubtask,filesep,TPS_INPUT_FILE,' not found.']);
                    disp(['Skipping TPS for target ',num2str(tipId)]);
                    continue;
                end
                
                % throw error if tps keplerId does not match tip keplerId
                tpsId = T.inputsStruct.tpsTargets.keplerId;
                if ~isequal( tpsId, tipId )
                    error(['Wrong keplerId in TPS input file. tipKeplerId = ',num2str(tipId),...
                        '  tpsKeplerId = ',num2str(tpsId),' TPS output path ',tpsMapStruct(skyGroupIndex).taskFileFullPath,tpsSubtask]);
                end
                
                % weighted intransit vector for this target on the PA/PDC timestamps
                inTransit = data.inTransitNormalized(paCadenceIdx(tfTps),tipIdx(iTarget));
                inTransitTps = data.inTransitNormalizedTps(paCadenceIdx(tfTps),tipIdx(iTarget));
                
                
                % find the pulse duration for the id match
                [~, closestPulseIdx] = min( abs( S.tpsDawgStruct.pulseDurations - data.transitModelDurationHours(tipIdx(iTarget)) ));
                data.tpsPulseMatch(tipIdx(iTarget)) = S.tpsDawgStruct.pulseDurations(closestPulseIdx);
                
                % get deweighting vector from tps inputs for windowing
                % assume this vector is on the same timestamps as the tps inputs
                if enableTpsWindowing
                    tpsWeights = build_deemphasis_weights_vector(T.inputsStruct);
                else
                    tpsWeights = ones(size(tpsCadenceNumbers));
                end
                % select subset to match PA timestamps
                tpsWeights = tpsWeights(tfTps);
                
                % set fitSinglePulse flags for output based on TIP modeled duration and on TPS pulse duration
                data.fitSinglePulseTip(tipIdx(iTarget)) = assess_pulse_train_validity( inTransit, tpsWeights, minTpsTransitCount );
                data.fitSinglePulseTps(tipIdx(iTarget)) = assess_pulse_train_validity( inTransitTps, tpsWeights, minTpsTransitCount );
                
                % set central cadence pulse validity flag
                centralCadenceLogical = data.centralTransitLogical(paCadenceIdx(tfTps),tipIdx(iTarget));
                data.fitSinglePulse9p2(tipIdx(iTarget)) = numel(find(tpsWeights(centralCadenceLogical) ~= 0)) < minTpsTransitCount;
                
                % scale weighted intransit vector by tpsWeights vector to form new weighted intransit vector and store
                data.inTransitNormalized(paCadenceIdx(tfTps),tipIdx(iTarget)) = inTransit .* tpsWeights;
                data.inTransitNormalizedTps(paCadenceIdx(tfTps),tipIdx(iTarget)) = inTransitTps .* tpsWeights;
                
                % load the tps outputs - assumes single target in subtask directory
                if exist([tpsMapStruct(skyGroupIndex).taskFileFullPath,tpsSubtask,filesep,TPS_OUTPUT_FILE],'file')
                    T = load([tpsMapStruct(skyGroupIndex).taskFileFullPath,tpsSubtask,filesep,TPS_OUTPUT_FILE]);
                else
                    disp([tpsMapStruct(skyGroupIndex).taskFileFullPath,tpsSubtask,filesep,TPS_OUTPUT_FILE,' not found.']);
                    disp(['Skipping TPS for target ',num2str(tipId)]);
                    continue;
                end
                
                cdpp = T.outputsStruct.tpsResults(closestPulseIdx).cdppTimeSeries;
                
                % throw error if tps keplerId does not match tip keplerId
                tpsId = T.outputsStruct.tpsResults(closestPulseIdx).keplerId;
                if ~isequal( tpsId, tipId )
                    error(['Wrong keplerId in TPS output file. tipKeplerId = ',num2str(tipId),...
                        '  tpsKeplerId = ',num2str(tpsId),' TPS output path ',tpsMapStruct(skyGroupIndex).taskFileFullPath,tpsSubtask]);
                end
                
                % store isPlanetCandidateTps for this target
                % consider target a planet candidate if flag is set for any instance of tpsKeplerId
                data.isPlanetCandidateTps(tipIdx(iTarget)) = any(isPlanetCandidateTps(tpsKeplerId == tipId));
                
                
                % set pdc gapped cdpp to NaN - there should be no gaps coming into TPS anyway
                cdpp(tpsGapIndicators) = nan;
                
                % truncate cdpp time series to only PA/PDC cadence numbers so we can apply inTransitNormalized as a logical mask
                cdpp = cdpp(tfTps);
                
                % set OOT points to NaN
                cdpp(~logical(inTransit)) = nan;
                
                % get cdpp in transit average and store
                data.tpsMeanInTransitCdpp(tipIdx(iTarget)) = nanmean(cdpp);
                
                % store some other tps results in output struct if they are available
                if ~isempty(T.outputsStruct.tpsResults(closestPulseIdx).maxMultipleEventStatistic)
                    data.tpsMes(tipIdx(iTarget)) = T.outputsStruct.tpsResults(closestPulseIdx).maxMultipleEventStatistic;
                end
                if ~isempty(T.outputsStruct.tpsResults(closestPulseIdx).maxSingleEventStatistic)
                    data.tpsSes(tipIdx(iTarget)) = T.outputsStruct.tpsResults(closestPulseIdx).maxSingleEventStatistic;
                end
                if ~isempty(T.outputsStruct.tpsResults(closestPulseIdx).rmsCdpp)
                    data.tpsRmsCdpp(tipIdx(iTarget)) = T.outputsStruct.tpsResults(closestPulseIdx).rmsCdpp;
                end
                if ~isempty(T.outputsStruct.tpsResults(closestPulseIdx).detectedOrbitalPeriodInDays)
                    data.tpsPeriodDays(tipIdx(iTarget)) = T.outputsStruct.tpsResults(closestPulseIdx).detectedOrbitalPeriodInDays;
                end
                if ~isempty(T.outputsStruct.tpsResults(closestPulseIdx).timeOfFirstTransitInMjd)
                    data.tpsEpochMjd(tipIdx(iTarget)) = T.outputsStruct.tpsResults(closestPulseIdx).timeOfFirstTransitInMjd;
                end
                
            end
            
            clear T;
            
            % calculate the effective number of transits after windowing for all targets found
            data.nTransitsWindowed(tfTip) = nansum(data.inTransitNormalized(:,tfTip));
            data.nTransitsWindowedTps(tfTip) = nansum(data.inTransitNormalizedTps(:,tfTip));
            
            % calculate different flavors of MES expected for all TIP targets
            
            % universeMes
            % Must have at least one transit and cdpp from tps available. (integer nTransits)
            % Use transit depth derived parmater from planet model
            enoughTransits = data.nTransitsInt > 0;
            idx = enoughTransits & tfTip;
            data.universeMes(idx) = sqrt(data.nTransitsInt(idx)) .* data.transitModelDepthPpm(idx) ./ data.tpsMeanInTransitCdpp(idx);
            
            % apertureMes
            % This MES uses the measured transit depth injected in PA which is corrected for FFIA and CM (from PDC) but does not include effects
            % for any PDC gapping or for TPS deweighting (windowing). Considers only the cadences actually injected in PA and must meet minimum
            % transit count. (fractional nTransits)
            enoughTransits = data.nTransitsFrac >= minimumNumberOfTransits;
            idx = enoughTransits & tfTip;
            data.apertureMes(idx) = sqrt(data.nTransitsFrac(idx)) .* nanmean(data.pdcTransitDepthPpm(:,idx)) ./ data.tpsMeanInTransitCdpp(idx);
            data.apertureMesMean(idx) = sqrt(data.nTransitsFrac(idx)) .* nanmean(data.pdcMeanTransitDepthPpm(:,idx)) ./ data.tpsMeanInTransitCdpp(idx);
            
            % windowedMes
            % Calculate MES expected at TPS measurement. This MES includes effects for PA and PDC gapping plus TPS deweighting. Must meet
            % minimum transit count and have cdpp available from TPS. (fractional nTransits)
            enoughTransits = data.nTransitsWindowedTps >= minimumNumberOfTransits;
            idx = enoughTransits & tfTip;
            data.windowedMes(idx) = sqrt(data.nTransitsWindowedTps(idx)) .* nanmean(data.pdcTransitDepthPpmTps(:,idx)) ./ data.tpsMeanInTransitCdpp(idx);
            data.windowedMesMean(idx) = sqrt(data.nTransitsWindowedTps(idx)) .* nanmean(data.pdcMeanTransitDepthPpmTps(:,idx)) ./ data.tpsMeanInTransitCdpp(idx);
        
        end
        
        clear S;
        
        % write output for this skygroup in file with skygroup tag and chunk tag
        % if there is only one chunk do not tag with chunk-#
        outputFileroot = [inputStruct.outputFileRoot,num2str(skygroup(iSkygroup),'%02i')];
        if ~chunksDone
            filename = [outputFileroot,'-chunk-',num2str(iChunk),'.mat'];
            disp(['Saving ',filename]);
            intelligent_save(filename, 'data');
            clear data;
        end       
    end
    
        
    % aggregate data - last chunk (chunk == iChunk) still remains in variable data
    data = concatenate_expected_mes_data(aggregate_expected_mes_data(outputFileroot, iChunk - 1), data);

    % write aggregate output for this skygroup in file with skygroup tag
    filename = [outputFileroot,'.mat'];
    disp(['Saving ',filename,' ...']);
    intelligent_save(filename, 'data');   

    % clean up temp files and memory
    remove_expected_mes_chunk_files(outputFileroot, iChunk - 1);
    clear data;   
    
    % clean up local aggregate files if they exist - each skygroup must start with a clean directory as far as state files are concerned
    D = dir(['q*-',PA_TRANSIT_INJECTION_STATE_FILE]);
    if ~isempty(D)
        delete(['q*-',PA_TRANSIT_INJECTION_STATE_FILE]);
    end
    D = dir(['q*-',PA_STAR_RESULTS_FILE]);
    if ~isempty(D)
        delete(['q*-',PA_STAR_RESULTS_FILE]);
    end    

end






