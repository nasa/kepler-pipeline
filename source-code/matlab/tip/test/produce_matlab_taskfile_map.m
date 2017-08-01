function mapOut = produce_matlab_taskfile_map( rootPath, csciTag )
%
% function mapOut = produce_matlab_taskfile_map( rootPath, csciTag )
%
% This function produces an array of structures mapping the taskfile directories under rootPath to module, output, channel, season, quarter
% and skygroup. It assumes a subtask directory structure under the taskfile directory and that the MATLAB input filename follows the convention
% (csciTag)-inputs-0.mat. See mapStruct below for details of the output mapOut. Currently this function will handle CSCIs 'cal', 'pa',
% 'pdc', 'tps','dv', 'tip' and 'dynablack'.
%
% Note: with CAL-NAS processing, a given task file directory
% (cal-matlab-####) can have multiple channels grouped into separate group
% directories: g-0, g-1,...
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



% hard coded
SUBTASK_MASK = 'st-';
GROUP_SUBTASK_MASK = 'g-*';
% G0_SUBTASK_MASK = ['g-0',filesep,'st-'];
TASKFILE_MASK = '-matlab-*';
INPUT_FILE_MASK = '-inputs-0.mat';
OUTPUT_FILE_MASK = '-outputs-0.mat';

% get fc models
fc = convert_fc_constants_java_2_struct;

% convert tag to lower case
csciTag = lower(csciTag);

% initialize generic task file map structure
mapStruct = struct('taskFileFullPath',[],...
    'module',[],...
    'output',[],...
    'channel',[],...
    'skyGroupId',[],...
    'season',[],...
    'quarter',[],...
    'k2Campaign',[],...
    'isK2Uow',false,...
    'cadenceTimes',[],...
    'startCadence',[],...
    'endCadence',[]);

% find task file directories under root
D = dir([ rootPath, csciTag, TASKFILE_MASK]);
D = D([D.isdir]);

% count the groups in each task file dir
counter = 0;
for iDir = 1:length(D)
    DD = dir([rootPath, D(iDir).name,filesep,GROUP_SUBTASK_MASK]);
    if ~isempty(DD)
        % add groups
        counter = counter + length(DD);
    else
        % pdc runs with multiple subtasks yet no group
        if strcmpi('pdc',csciTag)
            CC = dir([rootPath, D(iDir).name,filesep,SUBTASK_MASK,'*']);
            counter = counter + length(CC);
        else
            % no groups but count one for the task file directory
            counter = counter + 1;
        end
    end
end

% build map array and uow found indicator array
mapOut = repmat(mapStruct, counter, 1);
uowFound = true(counter, 1);

% populate array for each taskfile directory, putting  channels into
% separate task file struct arrays

taskCount = 0; % running count of the task files
for iDir =1:length(D)
    
    % get all the group directories
    groupDir = dir([rootPath, D(iDir).name,filesep,GROUP_SUBTASK_MASK]);
    if ~isempty(groupDir)
        ngroups = length(groupDir);
        NAS_GROUPS = true;
    else
        NAS_GROUPS = false;
        ngroups=1; % still go through group loop once
    end
    
    for igrp = 1:ngroups
               
        % count subtasks needed
        if strcmpi('pdc',csciTag)
            CC = dir([rootPath, D(iDir).name,filesep,SUBTASK_MASK,'*']);
            nSubtasks = length(CC);
        else
            nSubtasks = 1;
        end
        
        
        for iSubtask = 1:nSubtasks
            
            taskCount = taskCount+1; % increment task counter
            
            % save full path to task files
            if NAS_GROUPS
                mapOut(taskCount).taskFileFullPath = [rootPath, D(iDir).name, filesep, groupDir(igrp).name, filesep];
            else
                mapOut(taskCount).taskFileFullPath = [rootPath, D(iDir).name, filesep];
            end
            
            % pdc is special case
            if strcmpi('pdc',csciTag)
                mapOut(taskCount).taskFileFullPath = [mapOut(taskCount).taskFileFullPath,CC(iSubtask).name,filesep];
                subtaskString = [];
            else
                % use first available st to get unit of work
                dummy = dir([mapOut(taskCount).taskFileFullPath,SUBTASK_MASK,'*']);
                if ~isempty(dummy)
                    subtaskString = [dummy(1).name,filesep];
                else
                    subtaskString = [];
                end
            end
            
            % build inputs filename
            inputsFile = [csciTag,INPUT_FILE_MASK];
            
            % load the st-0 input file in order to get unit of work info
            % if 'pdc' load inputs from each st
            disp(['Loading ',mapOut(taskCount).taskFileFullPath,'...']);
            
            if exist([mapOut(taskCount).taskFileFullPath,subtaskString],'dir')
                if exist([mapOut(taskCount).taskFileFullPath,subtaskString,inputsFile],'file')
                    s = load([mapOut(taskCount).taskFileFullPath,subtaskString,inputsFile]);
                else
                    disp(['File not found: ',mapOut(taskCount).taskFileFullPath,subtaskString,inputsFile,' Skipping task directory.']);
                    uowFound(taskCount) = false;
                    continue;
                end
            elseif exist([mapOut(taskCount).taskFileFullPath,inputsFile],'file')
                s = load([mapOut(taskCount).taskFileFullPath,inputsFile]);
            else
                disp(['File not found: ',mapOut(taskCount).taskFileFullPath,inputsFile,' Skipping task directory.']);
                uowFound(taskCount) = false;
                continue;
            end
            
            % extract stuff from inputsStruct
            switch(csciTag)
                case {'pa', 'pdc', 'cal','dynablack'}
                    % CAL, PA and PDC are organized by mod.out per quarter
                    if isfield(s.inputsStruct,'channelDataStruct')
                        mod = s.inputsStruct.channelDataStruct.ccdModule;
                        out = s.inputsStruct.channelDataStruct.ccdOutput;
                    else
                        mod = s.inputsStruct.ccdModule;
                        out = s.inputsStruct.ccdOutput;
                    end
                    startCadence = s.inputsStruct.cadenceTimes.cadenceNumbers(1);
                    endCadence = s.inputsStruct.cadenceTimes.cadenceNumbers(end);
                    if strcmpi(csciTag, 'dynablack')
                        cadenceType = 'LONG';
                    else
                        cadenceType = s.inputsStruct.cadenceType;
                    end
                    % handle FFI data type as single long cadence
                    if strcmpi(cadenceType,'FFI')
                        cadenceType = 'LONG';
                    end
                    quarter = floor(convert_from_cadence_to_quarter(startCadence, cadenceType));
                    if quarter ~= -1
                        season = convert_kepler_quarter_to_season( quarter );
                    else
                        season = [];
                    end
                    if ~isempty(season)
                        skygroup = return_skygroup_for_season( mod, out, season, fc );
                    else
                        skygroup = [];
                    end
                    if strcmpi(csciTag, 'cal')
                        if isfield(s.inputsStruct,'k2Campaign')
                            k2Campaign = s.inputsStruct.k2Campaign;
                        else
                            k2Campaign = [];
                        end
                        isK2Uow = s.inputsStruct.cadenceTimes.startTimestamps(1) > s.inputsStruct.fcConstants.KEPLER_END_OF_MISSION_MJD;
                        % load output to get black algorithm
                        outputsFile = ['cal',OUTPUT_FILE_MASK];
                        p = load([mapOut(taskCount).taskFileFullPath,subtaskString,outputsFile]);
                        mapOut(taskCount).blackAlgorithmApplied = p.outputsStruct.blackAlgorithmApplied;
                        clear p;
                    else
                        k2Campaign = [];
                        isK2Uow = false;
                    end
                    
                    % save some stuff
                    mapOut(taskCount).module     = mod;
                    mapOut(taskCount).output     = out;
                    mapOut(taskCount).channel    = convert_from_module_output(mod, out);
                    mapOut(taskCount).skyGroupId = skygroup;
                    mapOut(taskCount).season     = season;
                    mapOut(taskCount).quarter    = quarter;
                    mapOut(taskCount).k2Campaign = k2Campaign;
                    mapOut(taskCount).isK2Uow    = isK2Uow;
                    mapOut(taskCount).startCadence = startCadence;
                    mapOut(taskCount).endCadence = endCadence;
                    
                    % fill the gaps in cadence timestamps by linear interpolation
                    mapOut(taskCount).cadenceTimes = estimate_timestamps(s.inputsStruct.cadenceTimes);
                    
                    if strcmpi(csciTag, 'pa')
                        tipD = dir([mapOut(taskCount).taskFileFullPath,filesep,'blob*.txt']);
                        if ~isempty(tipD)
                            mapOut(taskCount).tipFilename = tipD.name;
                        end
                    end
                    
                case {'tps'}
                    % TPS is organized by skyGroup over multiple quarters
                    mapOut(taskCount).skyGroupId = s.inputsStruct.skyGroup;
                    mapOut(taskCount).cadenceTimes = estimate_timestamps(s.inputsStruct.cadenceTimes);
                    startCadence = s.inputsStruct.cadenceTimes.cadenceNumbers(1);
                    endCadence = s.inputsStruct.cadenceTimes.cadenceNumbers(end);
                    mapOut(taskCount).startCadence = startCadence;
                    mapOut(taskCount).endCadence = endCadence;
                case {'dv'}
                    % DV is organized by skyGroup over multpile quarters (slightly different field names)
                    mapOut(taskCount).skyGroupId = s.inputsStruct.skyGroupId;
                    mapOut(taskCount).cadenceTimes = estimate_timestamps(s.inputsStruct.dvCadenceTimes);
                    startCadence = s.inputsStruct.dvCadenceTimes.cadenceNumbers(1);
                    endCadence = s.inputsStruct.dvCadenceTimes.cadenceNumbers(end);
                    mapOut(taskCount).startCadence = startCadence;
                    mapOut(taskCount).endCadence = endCadence;
                case {'tip'}
                    % TIP is organized by skygroup
                    mapOut(taskCount).skyGroupId = s.inputsStruct.skyGroupId;
                    mapOut(taskCount).startCadence = s.inputsStruct.startCadence;
                    mapOut(taskCount).endCadence = s.inputsStruct.endCadence;
            end
        end
    end
end

% list missing uows
missingUow = {mapOut(~uowFound).taskFileFullPath};
if ~isempty(missingUow)
    disp('Task file directories contain no /st-0/inputs-0.mat');
    for iUow = 1:length(missingUow)
        disp(missingUow{iUow});
    end
end

% only produce map for the task directories where a uow was found
mapOut = mapOut(uowFound);