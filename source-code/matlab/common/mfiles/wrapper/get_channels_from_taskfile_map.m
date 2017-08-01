function [availableChannelsFromMap, summaryStruct] = ...
    get_channels_from_taskfile_map(taskMappingFilename, csciString, dataDirPath)
%
% function [availableChannelsFromMap, summaryStruct] = ...
%     get_channels_from_taskfile_map(taskMappingFilename, csciString, dataDirPath)
%
% function to parse the task-to-mod-out file to retrieve a list of the CCD 
% channels that should be available in the task file dir
%
%
% INPUTS:
%  taskMappingFilename      [string] filename of task-to-mod-out map
%  csciString               [string] name of CSCI to map ('cal', 'pa', 'pdc')
%  dataDirPath (optional)   [string] path to data directory which contains
%                                    the taskfile map
%
%  example:
%       taskMappingFilename = 'Q3_KSOP400_LC-cal-task-to-mod-out-map.csv'
%       csciString = 'cal'
%       dataDirPath = '/path/to/pipeline_results/science_q3/q3_archive_ksop400/lc/';
%
%
% OUTPUTS:
%
% availableChannelsFromMap  [array] list of available channels according to
%                                   task-to-mod-out map
%
% summaryStruct  [struct array] that contains the taskfile directory name,
%                               ccd module, ccd output, and ccd channel
%   ex. summaryStruct =
%       1092x1 struct array with fields:
%           taskfileDirName
%           ccdModule
%           ccdOutput
%           ccdChannel
%--------------------------------------------------------------------------
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


if ~ischar(taskMappingFilename) || ~ischar(csciString)
    error('wrapper:get_task_filename:FileNameMustBeString', ...
        'taskMappingFilename and csciString must be strings.');
end

% switch to data directory
if nargin == 3
    currentDir = pwd;
    cd(dataDirPath)
end

% open task file map
fid = fopen(taskMappingFilename, 'r');
format = '%q %q %q %f %s %*[^\n]';
nameArray = textscan(fid, format, 'headerlines', 1, 'delimiter', ',');
fclose(fid);

firstNumArray = str2double(nameArray{1});
secondNumArray = str2double(nameArray{3});
moduleOrOutputValue  = nameArray{4};
moduleOrOutputString = nameArray{5};

isCcdModule = strcmp(moduleOrOutputString, 'ccdModule');
isCcdOutput = strcmp(moduleOrOutputString, 'ccdOutput');

moduleValue = moduleOrOutputValue(isCcdModule);
outputValue = moduleOrOutputValue(isCcdOutput);


firstNumArrayForModule  = firstNumArray(isCcdModule);
secondNumArrayForModule = secondNumArray(isCcdModule);
numEntries = length(firstNumArrayForModule);

firstNumArrayForOutput = firstNumArray(isCcdOutput);
secondNumArrayForOutput = secondNumArray(isCcdOutput);


summaryStruct = repmat(struct('taskfileDirName', [], 'ccdModule', [], ...
    'ccdOutput', [], 'ccdChannel', []), numEntries, 1);

for i = 1:numEntries

    % module and output lines should have same firstNum and secondNum
    idx = find(secondNumArrayForOutput==secondNumArrayForModule(i));

    firstNum  = firstNumArrayForOutput(idx);
    secondNum = secondNumArrayForOutput(idx);
    ccdModule = moduleValue(idx);
    ccdOutput = outputValue(idx);

    summaryStruct(i).taskfileDirName = [csciString '-matlab-' num2str(firstNum) '-' num2str(secondNum)];
    summaryStruct(i).ccdModule       = ccdModule;
    summaryStruct(i).ccdOutput       = ccdOutput;
    summaryStruct(i).ccdChannel      = convert_from_module_output(ccdModule, ccdOutput);
end

availableChannelsFromMap = unique([summaryStruct.ccdChannel])';

% switch back to original directory
if nargin == 3
    cd(currentDir)
end

return;
