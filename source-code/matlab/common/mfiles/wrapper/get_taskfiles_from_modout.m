%% function taskDirname = get_taskfiles_from_modout(taskMappingFilename, ...
%     csciString, ccdChannelOrModOutArray, quarter, cadenceType,  dataDirPath)
%
% Function to parse the task-to-mod-out mapping file to retrieve the task file
% directory name for a given channel (or [module output] array). The output is a cell array.
%
% There are two versions of the task-to-modout/channel mapping. This function will auto-detect the styling.
%
% The old style which has a format like the following. It references by mod.out and is only for a single
% quarter.
%
% Note: You can use an absolute or relative path for <taskMappingFilename>. 
%       <taskDirname> is also returned relative to the same path as <taskMappingFilename>
%
%   PI_PIPELINE_INSTANCE_ID,PI_PIPELINE_INST_NODE_ID,PI_PIPELINE_TASK_ID,ELEMENT,MAPKEY
%   5542,6288,254942,2,ccdModule
%   5542,6288,254942,1,ccdOutput
%   5542,6288,254943,2,ccdModule
%   5542,6288,254943,2,ccdOutput
%
% And the new style with the following format. It references by channel and is for multi-quarter. Each channel
% is in a seperate subdirectory named st-#. 
%
%   PI_PIPELINE_INSTANCE_ID,PI_PIPELINE_INST_NODE_ID,PI_PIPELINE_TASK_ID,ELEMENT,MAPKEY
%   7456,8558,408792,"1,2,3,4,5,6,7,8",channels
%   7456,8558,408792,1105,startCadence
%   7456,8558,408792,2743,endCadence
%   7456,8558,408793,"9,10,11,12,13,14,15,16",channels
%   7456,8558,408793,1105,startCadence
%   7456,8558,408793,2743,endCadence
%
%   channel 1 is st-0, channel 2 is st-1,... channel 8 is st-7, etc... 
%
%**********************
% INPUTS:
%  taskMappingFilename      [string] filename of task-to-mod-out map
%  csciString               [string] name of CSCI to map ('cal', 'pa', 'pdc')
%  ccdChannelOrModOutArray  [int or array] CCD Channel index, or array of [mod out]
%  quarter     (optonal)    [int] The quarter to retrieve
%  cadenceType (optional)   [string] {'LONG', 'SHORT'}
%  dataDirPath (optional)   [string] path to data directory which contains the taskfile map; not needed if 
%                                   <taskMappingFilename> is realtive to the local path.      
%
%  example:
%       taskMappingFilename = 'Q3_KSOP400_LC-cal-task-to-mod-out-map.csv'
%       csciString = 'cal'
%       ccdChannelOrModOutArray = 19 or [7 3]
%       dataDirPath = '/path/to/pipeline_results/science_q3/q3_archive_ksop400/lc/';
%
% taskDirname = ...
%       get_taskfiles_from_modout(taskMappingFilename, 'cal', 10)  
%
% 
% OUTPUTS:
%  pipeline task file directory name(s) [cell array]
%
%  ex. taskDirname =
%     'cal-matlab-1131-49974'
%     'cal-matlab-1131-50058'
%     'cal-matlab-1131-50142'
%     'cal-matlab-1131-50226'
%     'cal-matlab-1131-50310'
%     'cal-matlab-1131-50394'
%
%
% TODO: Vectorize this function so that a list of mod.outs and quarters can be converted into a list of
% directories.
%%--------------------------------------------------------------------------
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

function taskDirname = get_taskfiles_from_modout(taskMappingFilename, csciString, ccdChannelOrModOutArray, varargin)

if ~ischar(taskMappingFilename) || ~ischar(csciString)
    error('wrapper:get_task_filename:FileNameMustBeString', ...
        'taskMappingFilename and csciString must be strings.');
end

if length(ccdChannelOrModOutArray) > 1
    ccdModule = ccdChannelOrModOutArray(:,1);
    ccdOutput = ccdChannelOrModOutArray(:,2);
    channel = convert_mod_out_to_from_channel (ccdModule, ccdOutput);
else
    [ccdModule ccdOutput] = convert_to_module_output(ccdChannelOrModOutArray);
    channel = ccdChannelOrModOutArray;
end

% Parse optional arguments
quarter = [];
cadenceType = [];
dataDirPath = [];
for iArg = 1 : length(varargin)
    if (isnumeric(varargin{iArg}))
        quarter = varargin{iArg}';
    elseif (any(strcmp(varargin{iArg}, {'LONG', 'SHORT'})))
        cadenceType = varargin{iArg};
    elseif (ischar(varargin{iArg}))
        dataDirPath = varargin{iArg};
        % Add on trailing '/' if needed
        if(~strcmp(dataDirPath(end), '/'))
            dataDirPath = [dataDirPath, '/'];
        end
    end
end
if (~isempty(dataDirPath))
    fullTaskMappingFilename = [dataDirPath, taskMappingFilename];
else
    fullTaskMappingFilename = taskMappingFilename;
end

% Check that the the taskMappingFile is located where the user claims it's located
if (length(dir(fullTaskMappingFilename)) ~= 1)
    error('<taskMappingFilename> does not appear to exist at specified path');
end

% Read in task file map
fid = fopen(fullTaskMappingFilename , 'r');
if (fid <3)
    error('Error opening task file map');
end

% Check if there is a header. The dumb way to do this is read in the data first assuming there is no header. If the read fails then there must be a header that
% doesn't conform to the data format.
format = '%u %u %u %q %s %*[^\n]';
nameArray = textscan(fid, format, 'delimiter', ',');
if (isempty(nameArray{1}))
    % Then there may be a header
    nameArray = textscan(fid, format, 'headerlines', 1, 'delimiter', ',');
    if (isempty(nameArray{1}))
        error('Incompatable data format in mapping file');
    end
end
fclose(fid);


% Check which format is used in the file
if (strncmpi(nameArray{end}(1), 'ccd', 3))
    % This is the old style
    taskDirname = old_style_format(nameArray, csciString, ccdModule, ccdOutput, fullTaskMappingFilename );
elseif (any(strncmpi(nameArray{end}(1), {'channels', 'startCadence', 'endCadence'}, 8)))
    % This is the new style
    if (~exist('quarter', 'var') || ~isnumeric(quarter) || ~exist('cadenceType', 'var') || isnumeric(cadenceType))
        error('get_taskfiles_from_modout: quarter and cadenceType must be specified for this type of mapping style');
    end
    taskDirname = new_style_format(nameArray, csciString, channel, quarter, cadenceType);
else
    error ('get_taskfiles_from_modout: unknown file format');
end 

% Add back in the full path if it was given in <taskMappingFilename>
[dirPath, ~, ~] = fileparts(taskMappingFilename);
if(~isempty(dirPath))
    for i = 1:length(taskDirname)
        taskDirname{i} = [dirPath, '/', taskDirname{i}];
    end
end

return

%*************************************************************************************************************
%*************************************************************************************************************
%*************************************************************************************************************
% internal functions
 
%*************************************************************************************************************
function [taskDirname] = old_style_format (nameArray, csciString, ccdModule, ccdOutput, fullTaskMappingFilename )

firstNumArray = nameArray{1};
secondNumArray = nameArray{3};
moduleOrOutputValue = zeros(length(nameArray{4}),1);
temp  = nameArray{4};
for iLine = 1 : length(nameArray{4})
    moduleOrOutputValue(iLine)  = str2num(temp{iLine});
end
clear temp;
moduleOrOutputString = nameArray{5};

lineFromModInfo = intersect(find(strcmp(moduleOrOutputString, 'ccdModule')) , find(moduleOrOutputValue==ccdModule));
lineFromOutInfo = intersect(find(strcmp(moduleOrOutputString, 'ccdOutput')) , find(moduleOrOutputValue==ccdOutput));

secondNum = intersect(secondNumArray(lineFromModInfo), secondNumArray(lineFromOutInfo));

firstNum = unique(firstNumArray(ismember(secondNumArray, secondNum)));

if (length(secondNum) == 0)
    error('No tasks found in mapping file match the requested mod.out or channel');
end
taskDirname = cell(length(secondNum), 1);
for i = 1:length(taskDirname)
    taskDirname{i} = [csciString '-matlab-' num2str(firstNum) '-' num2str(secondNum(i))];
end

% Search for the st-0 directory
% Assume the same format for all directories so only need to search the first directory in the list
if strcmpi(csciString, 'pdc')
    % Get the directory path 
    [dirPath, ~, ~] = fileparts(fullTaskMappingFilename);
    if (~isempty(dirPath))
        dirNames = dir([dirPath, '/', taskDirname{1}, '/st-*']);
    else
        dirNames = dir([taskDirname{1}, '/st-*']);
    end

    if (length(dirNames) > 1)
        error('More than 1 ''st-*'' directory names, yet using old csv file format. Indeterminate task directory path!')
    elseif (~isempty(dirNames))
        for i = 1:length(taskDirname)
            taskDirname{i} = [taskDirname{i}, '/st-0'];
        end
    end
    % no 'st-0' directory so assume we are done, no sub-directory
end

return;

%*************************************************************************************************************
function [taskDirname] = new_style_format(nameArray, csciString, channel, quarter, cadenceType)

if (length(channel) ~= length(quarter))
    error('get_taskfiles_from_modout: channel and quarter must be the same length');
end

firstNumArray  = nameArray{1};
secondNumArray = nameArray{3};
channelValuesOrCadence   = nameArray{4};
lineType       = nameArray{5};

%***
% Convert cadence range to quarter

% Collect lines that contain cadence ranges
startCadenceLines = find(strcmp('startCadence', lineType));
endCadenceLines   = find(strcmp('endCadence', lineType));

if (length(startCadenceLines) ~= length(endCadenceLines))
    error ('get_taskfiles_from_modout: Syntax error in task mapping file');
end

% Convert cadence ranges to MJDs and then to channels (with use of mod.out
% Function not vectorized :(
% NOTE: This method works but is REALLY SLOW! Leaving in for reference.
%for iLine = 1 : length(startCadenceLines)
%    % Find the MJDs from the cadence ranges
%    validMJD = get_mjd_cadences (str2double(cell2mat(channelValuesOrCadence(startCadenceLines(iLine)))), ...
%                                    str2double(cell2mat(channelValuesOrCadence(startCadenceLines(iLine)))));
%    % Convert module, output and MJD to quarter
%    skyGroupStruct = retrieve_sky_group(ccdModule, ccdOutput, validMJD(1).mjdMidTime);
%    quarterList(iLine) = skyGroupStruct.observingSeason;
%end
 
startCadences = str2double(channelValuesOrCadence(startCadenceLines));
quarterList = convert_from_cadence_to_quarter (startCadences, cadenceType);

%***
% Get lines that contain this quarter and mod.out 
% and the st-# directory containing the channel
% TODO: CLEAN THIS UP, not easy to decipher
channelLines = find(strcmp('channels', lineType));
stDirForThisChannel = zeros(length(channelLines), 1);
lineHasThisChannel  = false(length(channelLines), 1);

theFoundLines = nan(length(channel),1);
for iChannel = 1 : length(channel)

    for iLine = 1: length(channelLines)
        channelsForThisLine = str2num(channelValuesOrCadence{channelLines(iLine)});
        lineHasThisChannel(iLine) = ismember(channel(iChannel), channelsForThisLine);
        if (lineHasThisChannel(iLine))
            foundChannels = find(channelsForThisLine == channel(iChannel));
            if (length(foundChannels) > 1)
                error('get_taskfiles_from_modout: syntax error in task mapping file');
            end
            % Damn Java 0-based indexing! Must subtract 1 off found index.
            stDirForThisChannel(iLine) = foundChannels-1;
        end
    end

    linesFoundForThisChannel = intersect(find(quarterList == quarter(iChannel)), find(lineHasThisChannel));
    if (length(linesFoundForThisChannel) > 1)
        %error('get_taskfiles_from_modout: Too many task directories found for this mod.out/channel and quarter; There should only be one.');
        % If more than one foudn then there is some problem. Skip this quarter/channel
        continue;
    elseif (isempty(linesFoundForThisChannel ))
        % No tasksfile found for this quarter and/or mod.out
        continue;
    else
        theFoundLines(iChannel) = linesFoundForThisChannel;
    end
end

%***
% Generate the file names
taskDirname = cell(length(theFoundLines), 1);
for iLine = 1:length(taskDirname)
    if (isnan(theFoundLines(iLine)))
        taskDirname{iLine} = [];
        continue;
    end
    % Get the first and second number array for the found channels
    foundFirstNumArray  = firstNumArray(channelLines(theFoundLines(iLine)));
    foundSecondNumArray = secondNumArray(channelLines(theFoundLines(iLine)));

    taskDirname{iLine} = [csciString '-matlab-' num2str(foundFirstNumArray) '-' ...
                        num2str(foundSecondNumArray)];
    % Add the first subtask directory, if PDC.
    if strcmpi(csciString, 'pdc') 
        taskDirname{iLine} = ...
            [taskDirname{iLine} '/st-' ...
             num2str(stDirForThisChannel(theFoundLines(iLine)))];
    end
end

return

