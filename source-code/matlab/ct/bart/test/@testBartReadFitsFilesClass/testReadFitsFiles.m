function self = testReadFitsFiles( self )
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

disp('Executing testReadFitsFiles()');
MsgID = 'CT:BART:testBartReadFitsFilesClass:testReadFitsFiles';

MsgIDExpected = 'CT:BART:bart_read_fits_files';

%% nominal case
if isunix
    fitsFoldername_0  = '/path/to/matlab/bart/inputs/TVAC/';
elseif ispc
    fitsFoldername_0  = 'Z:\path\to\matlab\bart\inputs\TVAC\';
end

fitsFilenames_0       = {'ffi_200809030929_set_001.fits'};
moduleIndex_0         = 2;
outputIndex_0         = 1;

% these are constants and not changed
nRows                 = 1070;
nCols                 = 1132;

try
    [ffiData, ffiInfoStruct] = bart_read_fits_files( fitsFoldername_0, fitsFilenames_0, moduleIndex_0, outputIndex_0, nRows, nCols);
catch
    lastError = lasterror();
    disp(['Error ID: ' lastError.identifier]);
    disp(['Error Msg: ' lastError.message]);
    error(MsgID, 'error with bart_read_fits_files()');
end

% load groundtrudth: selectedTemperatureStruct_0
load 'unit_test_data/read_fits_files_unit_test.mat';

status = isequal(ffiData_0, ffiData) && isequal(ffiInfoStruct_0, ffiInfoStruct);

mlunit_assert( status, 'Nominal case failed');

%% Invalid input folder and file names

% empty input folder name
fitsFoldername = [];
try
    [ffiData,ffiInfoStruct] = bart_read_fits_files( fitsFoldername, fitsFilenames_0, moduleIndex_0, outputIndex_0, nRows, nCols);
catch
    lastError = lasterror();
    status = strcmp(lastError.identifier, MsgIDExpected) && ...
        ~isempty( strfind(lastError.message, 'FITS folder is empty') );
    mlunit_assert( status, 'Empty input folder test case failed');
end

% none-exist folder name
fitsFoldername = strrep(fitsFoldername_0, 'TVAC', 'TVAC_YYY');
try
    [ffiData,ffiInfoStruct] = bart_read_fits_files( fitsFoldername, fitsFilenames_0, moduleIndex_0, outputIndex_0, nRows, nCols);
catch
    lastError = lasterror();
    status = strcmp(lastError.identifier, MsgIDExpected) && ...
        ~isempty( strfind(lastError.message, 'FITS folder not found') );
    mlunit_assert( status, 'None exist folder test case failed');
end

% empty file names
fitsFilenames =[];
try
    [ffiData,ffiInfoStruct] = bart_read_fits_files( fitsFoldername_0, fitsFilenames, moduleIndex_0, outputIndex_0, nRows, nCols);
catch
    lastError = lasterror();
    status = strcmp(lastError.identifier, MsgIDExpected) && ...
        ~isempty( strfind(lastError.message, 'FITS files array is empty') );
    mlunit_assert( status, 'Empty fits filename test case failed');
end

% empty file names
fitsFilenames ={'ffi_200809030929_set_001.fits','ffi_200809030929_set_001.fits','ffi_200809030929_set_001.fits'};
try
    [ffiData,ffiInfoStruct] = bart_read_fits_files( fitsFoldername_0, fitsFilenames, moduleIndex_0, outputIndex_0, nRows, nCols);
catch
    lastError = lasterror();
    status = strcmp(lastError.identifier, MsgIDExpected) && ...
        ~isempty( strfind(lastError.message, 'Incorrect number of FFI or RCLC files') );
    mlunit_assert( status, 'Incorrect dimension of fits file names array test case failed');
end

%% Invalid module and out indexes

% invalid input struct
moduleIndex = 0;
outputIndex = 1;
try
    [ffiData,ffiInfoStruct] = bart_read_fits_files( fitsFoldername_0, fitsFilenames_0, moduleIndex, outputIndex, nRows, nCols);
catch
    lastError = lasterror();
    status = strcmp(lastError.identifier, MsgIDExpected) && ...
        ~isempty( strfind(lastError.message, 'Incorrect module or output indexes') );
    mlunit_assert( status, 'Incorrect module or output indexes test case failed');
end

return;