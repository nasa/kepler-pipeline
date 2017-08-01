function bartDataOutStruct = bart_matlab_run(paramFile, selectedChannels)
% function bartDataOutStruct = bart_matlab_run(paramFile, selectedChannels)
% Prepare input data  structure for bart_matlab_controller from a user
% supplied parameter file and then execute the bart_matlab_controller();
%
%--------------------------------------------------------------------------
%   Top Level Input
%
%            paramFile: [string] contains the filenames, location and
% information for constructing the output data struct. 
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

% paramFile should contain the following keywords and values:
%       inputFoldername: input FITS files location 
%      outputFoldername: output location
%             outputTag: tag name for grouping multiple runs
%         fitsFilenames: FITS file names 
%      selectedChannels: default channels for processing 
%      mnemonicFilename: a file containing two columns of mnemonics 
%  referenceTemperature: the reference temperature for the temperature
%                        based model

%     selectedChannels: [int array] are, optional, the list of channels for processing
%                        and it also overwrites the channel in the parameter file.
%
% -------------------------------------------------------------------------
%   Top Level Output
%
%   bartDataOutStruct is a structure for each module output with the following fields:
%
%                     channels: [int] the CCD channel indexes
% selectedTemperatureStruct: [struct] temperature measurements for all
%                             selected mnemonics and FFI
%--------------------------------------------------------------------------

MsgID = 'CT:BART:bart_matlab_run';
if nargin > 0
    if ( isempty(paramFile) || ~ischar(paramFile) || exist(paramFile, 'file') ~= 2)
        error(MsgID, 'Error with parameter file input');
    else
        bartDataInStruct = bart_parameters_parser( paramFile );
    end

    if nargin == 2
        
        if ( isempty(selectedChannels) || ~isnumeric(selectedChannels) || ...
                max(selectedChannels) > 84 )
            error(MsgID, 'Error with selectedChannels');
        elseif isfield(bartDataInStruct, 'selectedChannels')
            % overwrite the selected channels
            if (size(selectedChannels, 2) > 0 && size(selectedChannels, 1) == 1)
                % row format
                bartDataInStruct.selectedChannels = selectedChannels;
            elseif (size(selectedChannels, 2) == 1 && size(selectedChannels, 1) > 0)
                % column format
                bartDataInStruct.selectedChannels = selectedChannels';
            end

            % check if prep channel is selected
            if min( bartDataInStruct.selectedChannels ) < 1
                if ( size(bartDataInStruct.selectedChannels, 2) == 1 && ...
                        bartDataInStruct.selectedChannels(1) == 0 )
                    disp('Prep channel detected ...');
                else
                    error(MsgID, 'channel value is invlid ... minimum is 1.');
                end
            end
        end
        
    else
        error(MsgID, 'Incorrect number of input arguments');
    end
else
    error(MsgID, 'Not enough input ... abort');
end

% prepare a local cache input data struct
bartDataInLocalStruct = bart_set_local_caching( bartDataInStruct );

try
    % execute the bart matlab controller
    bartDataOutStruct = bart_matlab_controller( bartDataInLocalStruct );
catch
    lastError = lasterror();
    disp(['Error ID: ' lastError.identifier]);
    disp(['Error Msg: ' lastError.message]);
    error(MsgID, 'Error in executing bart_matlab_controller() ');
end

% copy the locally cached results to destination
bart_copy_to_destination( bartDataInStruct, bartDataInLocalStruct, bartDataOutStruct.dateString);

clear bartDataInLocalStruct;

disp('BART processing is completed! ');

return;

% -------------------------------------------------------------------------
%%
% set local folders for caching
function bartDataInLocalStruct = bart_set_local_caching( bartDataInStruct )
% function bartDataInLocalStruct = bart_set_local_caching(bartDataInStruct)
% Taking in a data structure for bart_matlab_controller and replacing the
% input & output folders with local folders

MsgID = 'CT:BART:bart_set_local_caching';

% remove the unused 'outputTag' field for bart_matlab_controller()
bartDataInLocalStruct = rmfield(bartDataInStruct, 'outputTag');

% prepare the temporary local folders for efficiency
tempInputFoldername = 'temp_bart_input';
tempOutputFoldername = 'temp_bart_output';

if ~isunix
    error(MsgID, 'No local caching under Windows');
else

    disp('Checking folders ...');

    if ( exist(bartDataInStruct.inputFoldername, 'dir') == 7 )
        disp(['   Input folder ' bartDataInStruct.inputFoldername ' exists ... good']);
    else
        error(MsgID, ['   Input folder ' bartDataInStruct.inputFoldername ' does not exists ... abort']);
    end

    if ( exist(bartDataInStruct.outputFoldername, 'dir') == 7 )
        disp(['   Output folder ' bartDataInStruct.outputFoldername ' exists ... good']);
    else
        error(MsgID, ['   Output folder ' bartDataInStruct.outputFoldername ' does not exists ... abort']);
    end

    outputTagFoldername = fullfile(bartDataInStruct.outputFoldername, bartDataInStruct.outputTag);

    if ( exist(outputTagFoldername , 'dir') == 7 )
        disp(['   Output tagged folder ' outputTagFoldername  ' exists ... assuming shared.']);
    else
        disp(['   Output folder ' outputTagFoldername ' does not exists ... will create in needed.']);
    end

    if ( exist(tempInputFoldername, 'dir') == 7 )
        disp(['   Input cache folder ' tempInputFoldername ' already exists, assuming its valid.'])
    else
        disp(['   Input cache folder ' tempInputFoldername ' does not exists ... will create.']);
    end

    if ( exist(tempOutputFoldername, 'dir') == 7 )
        disp(['   Output cache folder ' tempOutputFoldername ' already exists ... looking for alternate name'])
        % check if there is any conflict with existing name

        k = -1;
        while ( exist( tempOutputFoldername, 'dir' ) == 7 )
            k = k + 1;
            tempOutputFoldername = ['temp_bart_output_' num2str(k, '%1d')];
        end
    end
    disp(['   Output folder ' tempOutputFoldername ' does not exists ... will create if needed.']);
end

% create local input folder
try
    shell_command = ['/bin/mkdir -m 755 ' tempInputFoldername];
    status = system( shell_command );
catch
    lastError = lasterror();
    disp(['Error ID: ' lastError.identifier]);
    disp(['Error Msg: ' lastError.message]);
    error(MsgID, 'Error in executing system() to create temporary input folder ');
end
if ~( status == 0 )
    warning(MsgID, ['Temporary folder already exists: ' tempInputFoldername '; use it as valid.']);
else
    % block copy data to local disk
    disp('Copying FITS files into local cache ...');
    shell_command =['/bin/cp ' bartDataInStruct.inputFoldername '/*.fits ' tempInputFoldername ];
    status = system( shell_command ) ;
    if ~( status == 0 )
        error(MsgID, 'Copying to local folder failed');
    end
end

% check if there is any conflict with existing name
k = -1;
while ( exist( tempOutputFoldername, 'dir' ) == 7 )
    k = k + 1;
    tempOutputFoldername = ['temp_bart_output_' num2str(k, '%1d')];
end

% create the local output folder
try
    shell_command = ['/bin/mkdir -m 755 ' tempOutputFoldername];
    status = system(shell_command);
catch
    lastError = lasterror();
    disp(['Error ID: ' lastError.identifier]);
    disp(['Error Msg: ' lastError.message]);
    error(MsgID, 'Error in executing system() to create temporary output folder');
end
if ~( status == 0 )
    error(MsgID, ['Temporary folder already exists: ' tempOutputFoldername '; This should never happen!']);
end

bartDataInLocalStruct.inputFoldername  = tempInputFoldername;
bartDataInLocalStruct.outputFoldername = tempOutputFoldername;
return;

%%
function bart_copy_to_destination( bartDataInStruct,  bartDataInLocalStruct, dateString)
% function bart_copy_to_destination( bartDataInStruct,  bartDataInLocalStruct)
% Copy the results folder pointed by the bartDataInLocalStruct to the
% destination location pointed by bartDataInStruct

MsgID = 'CT:BART:bart_copy_to_destination';

if ~isunix
    error(MsgID, 'No local caching on Windows');
end

% prepare the temporary local folders for efficiency
outputTagFoldername = fullfile(bartDataInStruct.outputFoldername, ...
    bartDataInStruct.outputTag);

% test if there is any name conflict
k = -1;
while ( exist( outputTagFoldername, 'dir' ) == 7 )
    k = k + 1;
    outputTagFoldername = fullfile(bartDataInStruct.outputFoldername, ...
        [bartDataInStruct.outputTag '_' num2str(k, '%1d')]);
end

shell_command = ['/bin/mkdir -m 755 ' outputTagFoldername];
status = system( shell_command );
if ~( status == 0 )
    error(MsgID, ['Error with creating tag folder: ' outputTagFoldername]);
end

destOutputFoldername = ['run_' dateString];
destOutputFullFoldername = fullfile(outputTagFoldername, destOutputFoldername);
shell_command = ['/bin/mv ' bartDataInLocalStruct.outputFoldername ' ' destOutputFullFoldername];

try
    status = system( shell_command );
catch
    lastError = lasterror();
    disp(['Error ID: ' lastError.identifier]);
    disp(['Error Msg: ' lastError.message]);
    error(MsgID, 'Error in executing system() to copy results to destination folder');
end
if ~( status == 0 )
    error(MsgID, ['Error with executing copy command: ' destOutputFullFoldername]);
else
    % change permission into 755
    shell_command = ['/bin/chmod -R 755 ' destOutputFullFoldername];
    status = system( shell_command );
    if ~( status == 0 )
        error(MsgID, 'Error with change destination folder permission');
    end
end

return;
