function dataOutStruct = cbd_controller(dataInStruct)
% function dataStruct = cbd_controller(dataInStruct)
% the main controller for CCD-Black-Dark Tool
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

% Top level controller for CCD Bias and Dark Tool
% Author: Gary Zhang
% Date: April 3rd, 2008

%%%% validate input data structure
%   Top level
%
%     dataInStruct contains the following fields:
%
%                     startMjd: [int]  start of duration in MJD
%                       endMjd: [int]  end of duration in MJD
%           channelIndex: [int array]  the CCD modout channels
%               fileFFIsDir: [string]  the folder holding the input FFIs
%   fileFFIsNameArray: [string array]  FFI file names
%       leadingBlackCols: [int array]  leading black column indexes
%      trailingBlackCols: [int array]  trailing black column indexes
%       virtualSmearRows: [int array]  trailing black column indexes
%        maskedSmearRows: [int array]  trailing black column indexes
%             cbdParameters: [struct]  processing parameters
%                 liveMode: [logical]  data from SBT stream or pre-archived
%                   dateStr: [string]  unique date string for saving data
%            dataArchivalDir:[string]  folder name for saving back up data
%          dataArchivalFile: [string]  file name for generated report &
%          results
%--------------------------------------------------------------------------
%   Second level
%
%     cbdParameters is struct with the following fields:
%
%            debugOption: [logical]  indicator for debug information
%
%--------------------------------------------------------------------------

[nRows, nFiles] = size( dataInStruct );

if ~( nRows == 1 && nFiles >= 1 )
    error('cbd_controller: dataInStruct error');
end

% validate input data structure
fieldsAndBounds = cell(14,4);
fieldsAndBounds(1,:)  = { 'startMjd';  '>=54466'; '<58819'; []}; % 58819 = datestr2mjd('January 1 2018');
fieldsAndBounds(2,:)  = { 'endMjd';  '>=54466'; '<58819'; []}; % 54466 = datestr2mjd('January 1 2008');
fieldsAndBounds(3,:)  = { 'channelIndex'; '>=1'; '<=84'; []};
fieldsAndBounds(4,:)  = { 'fileFFIsDir'; []; []; []};
fieldsAndBounds(5,:)  = { 'fileFFIsNameArray'; []; []; []};
fieldsAndBounds(6,:)  = { 'leadingBlackCols'; '>=1'; '<=12';  []};  % Validate only needed fields
fieldsAndBounds(7,:)  = { 'trailingBlackCols'; '>=1113'; '<=1132'; []};     % Do not validate
fieldsAndBounds(8,:)  = { 'virtualSmearRows'; '>=1045'; '<=1070'; []};
fieldsAndBounds(9,:)  = { 'maskedSmearRows'; '>=1'; '<=20'; []};
fieldsAndBounds(10,:) = { 'cbdParameters'; []; []; []};
%fieldsAndBounds(11,:) = { 'liveMode'; []; []; {'TRUE' ; 'FALSE'}};
fieldsAndBounds(11,:) = { 'liveMode'; []; []; []};
fieldsAndBounds(12,:) = { 'dateStr'; []; []; []};
fieldsAndBounds(13,:) = { 'dataArchivalDir'; []; []; []};
fieldsAndBounds(14,:) = { 'dataArchivalFile'; []; []; []};

validate_structure(dataInStruct(1), fieldsAndBounds, 'dataInStruct');

clear fieldsAndBounds;

% data has veen verified at this point

startMjd         = dataInStruct.startMjd;
endMjd           = dataInStruct.endMjd;
channelIndexes      = dataInStruct.channelIndex;   % range of channels

liveMode            = dataInStruct.liveMode;       % Is this live or load-from-disk mode?

if ( ispc && liveMode )
    liveMode = false; % automatically disable liveMode as there is no SBT support under PC
end

dataArchivalDir     = dataInStruct.dataArchivalDir;% archival dir and file names
dataArchivalFile    = dataInStruct.dataArchivalFile;

leadingBlackCols    = dataInStruct.leadingBlackCols;
trailingBlackCols   = dataInStruct.trailingBlackCols;
virtualSmearRows    = dataInStruct.virtualSmearRows;
maskedSmearRows     = dataInStruct.maskedSmearRows;

procParams          = dataInStruct.cbdParameters;

dateStr             = dataInStruct.dateStr;

fileFFIsDir         = dataInStruct.fileFFIsDir; % input files


% check inpout data validity
if ~( isscalar(startMjd) && isscalar(endMjd) )
    error('Error: Start/EndMjd must be scalar!');
end

if ~( isnumeric(channelIndexes) && isvector(channelIndexes) )
    error('Error: channelIndex must be numeric!');
end

if ~( isscalar(liveMode) && islogical(liveMode) )
    error('Error: liveMode must be true or false!');
end

if ~( ischar(dataArchivalDir) && ischar(dataArchivalFile) )
    error('Error: data archival folder and file names must be characters');
end

if ~( ischar(fileFFIsDir) )
    error('Error: FFI data input folder name must be characters');
end

if isempty( dataArchivalDir )
    error('data archival directory is empty!');
end

% which output uses this file?
if isempty( dataArchivalFile )
    error('data archival file is empty!');
end

if ~( ischar(dateStr) )
    error('Error: date string must be characters');
end

if ~( isnumeric(leadingBlackCols) && isvector(leadingBlackCols) && ...
        isnumeric(trailingBlackCols) && isvector(trailingBlackCols) && ...
        isnumeric(virtualSmearRows) && isvector(virtualSmearRows) && ...
        isnumeric(maskedSmearRows) && isvector(maskedSmearRows) )
    error('Error: collateral rows and columns must be numeric array!');
end

if ~( isstruct(procParams) )
    error('Warning: Cbd procParams is not a struct!');
end

% load the constants
constants;

% check input value range if
if ~( max(channelIndexes) <= MOD_OUT_NO && min(channelIndexes) >= 1 )
    error('Error: channelIndex out of range!');
end

% At this point, the input are checked and are valid.
%%
% Get the number of input FFI images
inputFFIsNumber     = length(dataInStruct);

% populate all the FFI file names (FITS format)
if ( inputFFIsNumber > 0 )
    try
        % retrieve each of the FITS filename
        fileFFIsNameArray   = cell(inputFFIsNumber, 1);
        ffiKeywordStruct    = cell(inputFFIsNumber, 1);
        ffiKeywordTable     = cell(inputFFIsNumber, 1);

        for fileFFIsIndex=1:inputFFIsNumber
            fileFFIsName = getfield(dataInStruct, {fileFFIsIndex}, 'fileFFIsNameArray');
            if ~( ischar(fileFFIsName) )
                error('Error: FFI file name must be  characters!');
            else
                % extract FITS file names
                fileFFIsNameArray{fileFFIsIndex}   = fileFFIsName;

                % extract FITS header keywords
                fitsFileName = fullfile(fileFFIsDir, fileFFIsName);

                % debug
                disp(fitsFileName);

                [ffiKeywordStruct{fileFFIsIndex}, ffiKeywordTable{fileFFIsIndex}] = ...
                    retrieve_fits_primary_keywords( fitsFileName, ...
                    'DATATYPE', 'INT_TIME', 'NUM_FFI', 'DCT_PURP', 'SCCONFID', 'STARTIME', 'END_TIME');
            end
        end
    catch
        error('Error in getting FFI FITS files!');
    end

    if ( liveMode )
        % This requires SBT support
        try
            % retrieve the ancillary data from both SBT
            ancillaryTemperature = retrieve_temperature_data(startMjd, endMjd);
        catch
            error('Error in retrieving temperature from ancillary data ...');
        end
    end
else
    error('cbd_controller: not enough input FFIs!');
end
%
%% Prepare the output
try
    % data information per channel
    channelDataStruct = struct( ...
        'blackData',        struct(cbdBlackClass), ...
        'collateralData',   struct(cbdCollateralClass), ...
        'dataCompleteness', zeros(inputFFIsNumber, 5));

    % information about FITS file names and header keyword values
    fitsFileStruct = struct( ...
        'fileNamesArray',       fileFFIsNameArray, ...
        'keywordsTable',        ffiKeywordTable, ...
        'ancillaryTemperature', ancillaryTemperature);

    dataOutStruct = struct( ...
        'channelDataStruct',    repmat(channelDataStruct, MOD_OUT_NO, 1), ...
        'fitsFilesStruct',      fitsFileStruct);

catch
    error('Error in constructing output data struct!');
end

% create the main CBD Object
try
    cbdMainObj = cbdObjectClass(startMjd, endMjd);

    % enable debug and verbose output
    if ( procParams.debugOption )
        cbdMainObj= turn_on_debug(cbdMainObj);
    end

    % set path to FFIs
    cbdMainObj= set_image_sources(cbdMainObj, fileFFIsDir, fileFFIsNameArray);

    pause_on_debug(cbdMainObj, 'set up collateral rows and columns ...');

    % set the collateral locations
    cbdMainObj = set_leading_black_cols(cbdMainObj, leadingBlackCols);
    cbdMainObj = set_trailing_black_cols(cbdMainObj, trailingBlackCols);
    cbdMainObj = set_masked_smear_rows(cbdMainObj, maskedSmearRows);
    cbdMainObj = set_virtual_smear_rows(cbdMainObj, virtualSmearRows);

catch
    error('Error in constructing cbdObjectClass object!');
end

% channels are provided by user as input
for channel = channelIndexes

    % close all the windows
    close all;

    [modIndex, outIndex] = convert_to_module_output(channel);

    fprintf('\nChannel: %2d: Module %2d, Output: %2d\n', channel, modIndex, outIndex );

    % set the channel index
    cbdMainObj= set_channel_index(cbdMainObj, channel);

    % use pre-saved file if SBT is not live.
    if ( liveMode )
        pause_on_debug(cbdMainObj, 'Load model data from SBT ...');

        try
            % get the bad, gap and xtalk pixel information from sandbox tool
            pause_on_debug(cbdMainObj, 'Retrieve bad pixels list and crosstalk pixels map');
            cbdMainObj= retrieve_badpixels(cbdMainObj);
            cbdMainObj= retrieve_xtalkpixels(cbdMainObj);

            % get models from sandbox tools
            pause_on_debug(cbdMainObj, 'Retrieve pre-flight models ...');
            cbdMainObj= retrieve_models(cbdMainObj);

            % get the original FFIs from designated files
            pause_on_debug(cbdMainObj, 'Retrieving original FFIs ...');
            cbdMainObj= retrieve_FFIs(cbdMainObj);

        catch
            lastError = lasterror();
            error(['Error in CBD processing: ' lastError.message ' file loc: ' lastError.stack(1).file ]);
        end

        % save a copy of the state
        try
            dataArchivalFileChannel = ['CBD_Backup_Channel_' num2str(channel, '%02d') '.mat'];
            save( fullfile(dataArchivalDir, dataArchivalFileChannel), 'cbdMainObj');
        catch

            lastError = lasterror();
            error(['Error in saving backup data files: ' lastError.message ' file loc: ' lastError.stack(1).file ]);
        end
    else
        pause_on_debug(cbdMainObj, 'Load model data from backup files ...');

        try
            dataArchivalFileChannel = [dataArchivalFile '_Channel_' num2str(channel, '%02d') '.mat'];
            fullArchivalFileChannel = fullfile(dataArchivalDir, dataArchivalFileChannel);
            if ( exist( fullArchivalFileChannel, 'file') )
                load( fullArchivalFileChannel );
            else
                error(['Error: file not found: ' fullArchivalFileChannel]);
            end
        catch
            lastError = lasterror();
            error(['Error in loading pre-saved backup data files: ' lastError.message ' file loc: ' lastError.stack(1).file ]);
        end
    end


    % visualization section
    pause_on_debug(cbdMainObj, 'Display 2D black model and three original FFIs ...');
    display_FFIs(cbdMainObj);

    pause_on_debug(cbdMainObj, 'Measure 2D black and compare with models ...');

    try
        % processing the 2D black and the collateral regions
        cbdMainObj= process_black_collateral(cbdMainObj);
    catch
        lastError = lasterror();
        error(['Error in processing black and collateral data: ' lastError.message ' file loc: ' lastError.stack(1).file ]);
    end

    % construct output data structure
    try
        dataOutStruct.channelDataStruct(channel).blackData = struct( get_black(cbdMainObj));
        dataOutStruct.channelDataStruct(channel).collateralData = struct( get_collateral(cbdMainObj));

        % get the input FFIs region statistis only
        cbdFFIsObj = get_FFIs(cbdMainObj);
        dataOutStruct.channelDataStruct(channel).dataCompleteness = get_data_completeness(cbdFFIsObj);
    catch
        lastError = lasterror();
        error(['Error in assigning results to output data struct: ' lastError.message]);
    end

    pause_on_debug(cbdMainObj, 'Process next channel');

end

return
