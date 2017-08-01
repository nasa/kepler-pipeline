function self = testPrefetchTemperarures( self )
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

disp('Executing testPrefetchTemperatures()');
MsgID = 'CT:BART:testBartPrefetchTemperaturesClass:testPrefetchTemperatures';

MsgIDExpected = 'CT:BART:bart_prefetch_temperatures';

%% nominal case
if isunix
    fitsFoldername_0  = '/path/to/matlab/bart/inputs/TVAC/';
elseif ispc
    fitsFoldername_0  = 'Z:\path\to\matlab\bart\inputs\TVAC\';
end
fitsFilenames_0       = {'ffi_200809030929_set_001.fits'; 'ffi_200809030930_set_001.fits'; 'ffi_200809030931_set_001.fits'};
temperatureMnemonics_0= {'PEDACQ1T', 'PEDACQ1ST'; 'PEDACQ2T', 'PEDACQ2ST';'PEDACQ3T', 'PEDACQ3ST'};

if ( isunix )
    try
        [selectedTemperatureStruct, averagedTemperatures] = bart_prefetch_temperatures( ...
            fitsFoldername_0, fitsFilenames_0, temperatureMnemonics_0);
    catch
        lastError = lasterror();
        disp(['Error ID: ' lastError.identifier]);
        disp(['Error Msg: ' lastError.message]);
        error(MsgID, 'error with bart_prefetch_temperatures()');
    end

    % load groundtruth: selectedTemperatureStruct_0, averagedTemperatures_0;
    load 'unit_test_data/prefetch_unit_test.mat'

    status = isequal(selectedTemperatureStruct_0, selectedTemperatureStruct) ...
        && isequal( averagedTemperatures_0, averagedTemperatures );

    mlunit_assert( status, 'Nominal case failed');
end

%% Invalid folder name, filenames or mnemonics

% empty folder name
fitsFoldername       = '';
try
    [selectedTemperatureStruct, averagedTemperatures] = bart_prefetch_temperatures( ...
        fitsFoldername, fitsFilenames_0, temperatureMnemonics_0);
catch
    lastError = lasterror();
    status = strcmp(lastError.identifier, MsgIDExpected) && ...
        ~isempty( strfind(lastError.message, 'FITS folder is empty or invalid') );
    mlunit_assert( status, 'Invalid FITS folderame test case failed');
end

% non-existence folder name
fitsFoldername       = '/path/to/_wrong';
try
    [selectedTemperatureStruct, averagedTemperatures] = bart_prefetch_temperatures( ...
        fitsFoldername, fitsFilenames_0, temperatureMnemonics_0);
catch
    lastError = lasterror();
    status = strcmp(lastError.identifier, MsgIDExpected) && ...
        ~isempty( strfind(lastError.message, 'FITS folder not found') );
    mlunit_assert( status, 'Invalid FITS folderame test case failed');
end

%% Invalid FITS filenames
% empty FITS filename
fitsFilenames       = {};
try
    [selectedTemperatureStruct, averagedTemperatures] = bart_prefetch_temperatures( ...
        fitsFoldername_0, fitsFilenames, temperatureMnemonics_0);
catch
    lastError = lasterror();
    status = strcmp(lastError.identifier, MsgIDExpected) && ...
        ~isempty( strfind(lastError.message, 'FITS files array is empty') );
    mlunit_assert( status, 'Empty FITS filename test case failed');
end

% incorrect FITS filename number
fitsFilenames       = {'rclc_fits', 'pmrf_fits', 'junk_fits'};
try
    [selectedTemperatureStruct, averagedTemperatures] = bart_prefetch_temperatures( ...
        fitsFoldername_0, fitsFilenames, temperatureMnemonics_0);
catch
    lastError = lasterror();
    status = strcmp(lastError.identifier, MsgIDExpected) && ...
        ~isempty( strfind(lastError.message, 'Incorrect number of FFI or RCLC files') );
    mlunit_assert( status, 'Incorrect number of FITS files test case failed');
end

% single FITS file input
fitsFilenames       = {'ffi_fits'};
try
    [selectedTemperatureStruct, averagedTemperatures] = bart_prefetch_temperatures( ...
        fitsFoldername_0, fitsFilenames, temperatureMnemonics_0);
catch
    lastError = lasterror();
    status = strcmp(lastError.identifier, MsgIDExpected) && ...
        ~isempty( strfind(lastError.message, 'Insufficient number of FFI or RCLC files for fitting, only one!') );
    mlunit_assert( status, 'Single FITS file test case failed');
end

% empty FITS file input
fitsFilenames       = {''; 'ffi_fits'};
try
    [selectedTemperatureStruct, averagedTemperatures] = bart_prefetch_temperatures( ...
        fitsFoldername_0, fitsFilenames, temperatureMnemonics_0);
catch
    lastError = lasterror();
    status = strcmp(lastError.identifier, MsgIDExpected) && ...
        ~isempty( strfind(lastError.message, 'FITS filename is empty or invalid') );
    mlunit_assert( status, 'Single FITS file test case failed');
end

% non existent FITS files
fitsFilenames       = {'ffi_200809030929_set_XXX.fits'; 'ffi_200809030930_set_YYY.fits'; 'ffi_200809030931_set_ZZZ.fits'};
try
    [selectedTemperatureStruct, averagedTemperatures] = bart_prefetch_temperatures( ...
        fitsFoldername_0, fitsFilenames, temperatureMnemonics_0);
catch
    lastError = lasterror();
    status = strcmp(lastError.identifier, MsgIDExpected) && ...
        ~isempty( strfind(lastError.message, 'FITS file not found') );
    mlunit_assert( status, 'Single FITS file test case failed');
end

%% Invalid mnemonics
% invalid mnemonics cell size
temperatureMnemonics = {};
try
    [selectedTemperatureStruct, averagedTemperatures] = bart_prefetch_temperatures( ...
        fitsFoldername_0, fitsFilenames_0, temperatureMnemonics);
catch
    lastError = lasterror();
    status = strcmp(lastError.identifier, MsgIDExpected) && ...
        ~isempty( strfind(lastError.message, 'Input argument temperatureMnemonics is not a valid cell') );
    mlunit_assert( status, 'Empty FITS filename test case failed');
end

% invalid mnemonic cell size
temperatureMnemonics = {'PEDDRV1T', 'PEDDRV1ST', 'PEDDRV3T'};
try
    [selectedTemperatureStruct, averagedTemperatures] = bart_prefetch_temperatures( ...
        fitsFoldername_0, fitsFilenames_0, temperatureMnemonics);
catch
    lastError = lasterror();
    status = strcmp(lastError.identifier, MsgIDExpected) && ...
        ~isempty( strfind(lastError.message, 'Temperature menmonics error in size') );
    mlunit_assert( status, 'Temperature menmonics error in size test failed');
end

return;
