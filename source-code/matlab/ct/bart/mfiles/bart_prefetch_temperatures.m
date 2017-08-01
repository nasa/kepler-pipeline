function [selectedTemperatureStruct,averagedTemperatures] = bart_prefetch_temperatures( ...
    fitsFoldername, fitsFilenames, temperatureMnemonicPair)
% function [selectedTemperatureStruct,averagedTemperatures] = bart_prefetch_temperatures( ...
%    inputFoldername, fitsFilenames, temperatureMnemonics)
% Do a prefetch of the timestamps of each FITS file and then retrieve the
% temperature measurements
%
% which module output is unimportant as the timestamps and then
% temperatures are all the same
%
%   Top Level Input
%
%          fitsFoldername: [string] folder name of input FITS files
%           fitsFilenames: [cell array] array of FITS file names for FFI (cell(nFFI,1))
% temperatureMnemonicPair: [cell array] list of temperature mnemonic pairs: value and status.
%
%--------------------------------------------------------------------------
%
%   Top Level Output
%
% selectedTemperatureStruct: [struct] temperature information for each
%                                      mnemonic and for each FITS file;
%       averageTemperatures: [struct] average temperature for each FITS
%       file.
%
%   Second Level Output
%
% selectedTemperatureStruct is a struct with the following fields:
%
%    temperatureMean: [double array] mean temperature measurements for each
%                      pair of mnemonics and FFI
%     temperatureStd: [double array] std of temperature measurements for
%                      each pair of mnemonics and FFI
%    temperatureSamples: [int array] number of temperature measurements for
%                      each pair of mnemonics and FFI
% temperatureMnemonics: [cell array] list of temperature mnemonics, e.g.
%                        {'PEDDRV1T', 'PEDACQ4T'}
%
%
%   Second Level Output
%
%    averageTemperatures: [double array] mean temperature measurements of
%                     selected mnemnoics for each FFI
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
MsgID = 'CT:BART:bart_prefetch_temperatures';

if ( nargin ~= 3 )
    error(MsgID, 'Invalid number of input arguments');
end

% constants for existence test
FILE_EXIST      = 2;
FOLDER_EXIST    = 7;

% validate the input data structure
if ( isempty(fitsFoldername) || ~ischar(fitsFoldername) )
    error(MsgID, 'FITS folder is empty or invalid: ' );
elseif ( exist(fitsFoldername, 'dir') ~= FOLDER_EXIST )
    error(MsgID, 'FITS folder not found: ' );
elseif ( isempty(fitsFilenames)  || ~ischar(fitsFoldername) )
    error(MsgID, 'FITS files array is empty: ' );
else
    % get the number of FITS entries and the number of files per entry
    [nFitsFiles, nRCLCFiles] = size( fitsFilenames );
    if ( nFitsFiles < 1 || nRCLCFiles > 2 || nRCLCFiles < 1)
        error(MsgID, 'Incorrect number of FFI or RCLC files');
    elseif ( nFitsFiles == 1 )
        error(MsgID, 'Insufficient number of FFI or RCLC files for fitting, only one!');
    elseif ( nFitsFiles == 2 )
        warning(MsgID, 'Minimum number of FFI or RCLC files for fitting, only two is provided!');
    end
end

% check the temperature mnemonics
if ( isempty(temperatureMnemonicPair) || ~iscell(temperatureMnemonicPair) )
    error(MsgID, 'Input argument temperatureMnemonics is not a valid cell');
else
    % expecting a column vector of mnemonics
    [nMnemonics, nCols] = size( temperatureMnemonicPair);
    if ~( nCols == 2 && nMnemonics > 0 )
        error(MsgID, 'Temperature menmonics error in size');
    end
end

% Pre-allocate memory for ffi information extracted from header
oneInfoStruct = struct('STARTIME', 0, 'END_TIME', 0, 'NUM_FFI', 0, 'DATATYPE', []);

ffiInfoStruct = repmat( oneInfoStruct, nFitsFiles, 1);

% This is for either FFI or RCLC files
for k = 1:nFitsFiles
    disp(['Reading FITS file header : ' num2str(k) ]);

    if ( isempty(fitsFilenames{ k, 1 }) || ~ischar( fitsFilenames{ k, 1 } ) )
        error(MsgID, ['FITS filename is empty or invalid: ', fitsFilenames{ k, 1 }] );
    end

    % extract FITS header keywords
    fitsFullFilename = fullfile(fitsFoldername, fitsFilenames{ k, 1 });
    if ~( exist(fitsFullFilename, 'file') == FILE_EXIST )
        error(MsgID, ['FITS file not found: ', fitsFullFilename] );
    end

    try
        % extract the keyword values
        ffiKeywordStruct = retrieve_fits_primary_keywords( fitsFullFilename, ...
            'STARTIME', 'END_TIME', 'NUM_FFI', 'DATATYPE');
    catch
        error(MsgID, ['Error with retrieve_fits_primary_keywords() for FITS file ' fitsFullFilename] );
    end

    if ~all( isfield(ffiKeywordStruct, {'STARTIME', 'END_TIME', 'NUM_FFI', 'DATATYPE'}) )
        error(MsgID, 'ffiKeywordStruct has invalid fields');
    end

    ffiInfoStruct(k) =  ffiKeywordStruct;
end

try
    % extract the temperature measurements for the selected mnemonics
    selectedTemperatureStruct = bart_get_temperatures( ffiInfoStruct, temperatureMnemonicPair );
catch
    lastError = lasterror();
    disp(['Error ID: ' lastError.identifier]);
    disp(['Error Msg: ' lastError.message]);
    error(MsgID, 'error with bart_get_temperatures()');
end

try
    % average temperature measurement for each and across all selected mnemonics
    averagedTemperatures = bart_temperature_conditioning( selectedTemperatureStruct );
catch
    lastError = lasterror();
    disp(['Error ID: ' lastError.identifier]);
    disp(['Error Msg: ' lastError.message]);
    error(MsgID, 'error with bart_temperature_conditioning()');
end
return;


