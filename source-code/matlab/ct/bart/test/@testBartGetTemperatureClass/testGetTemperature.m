function self = testGetTemperarures( self )
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

disp('Executing testGetTemperatures()');
MsgID = 'CT:BART:testBartGetTemperatureClass:testGetTemperatures';

MsgIDExpected = 'CT:BART:bart_get_temperatures';

%% nominal case
ffiInfoStruct_0 = struct('STARTIME', 54711.622662037, ...
    'END_TIME', 54712.401111111, ...
    'NUM_FFI', 270, 'DATATYPE', 'ffi');
temperatureMnemonics_0= {'PEDACQ1T', 'PEDACQ1ST'; 'PEDACQ2T', 'PEDACQ2ST';'PEDACQ3T', 'PEDACQ3ST'};

if isunix
    try
        selectedTemperatureStruct = bart_get_temperatures( ...
            ffiInfoStruct_0, temperatureMnemonics_0);
    catch
        lastError = lasterror();
        disp(['Error ID: ' lastError.identifier]);
        disp(['Error Msg: ' lastError.message]);
        error(MsgID, 'error with bart_get_temperatures()');
    end

    % load groundtrudth: selectedTemperatureStruct_0
    load 'unit_test_data/get_temperatures_unit_test.mat';

    status = isequal(selectedTemperatureStruct_0, selectedTemperatureStruct);

    mlunit_assert( status, 'Nominal case failed');
end

%% Invalid input struct

% invalid input struct
ffiInfoStruct  = 'abc';
try
    selectedTemperatureStruct = bart_get_temperatures(ffiInfoStruct, temperatureMnemonics_0);
catch
    lastError = lasterror();
    status = strcmp(lastError.identifier, MsgIDExpected) && ...
        ~isempty( strfind(lastError.message, 'Input argument ffiInfoStruct is not a valid struct') );
    mlunit_assert( status, 'Invalid ffiInfoStruct test case failed');
end

% empty input struct
ffiInfoStruct  = [];
try
    selectedTemperatureStruct = bart_get_temperatures(ffiInfoStruct, temperatureMnemonics_0);
catch
    lastError = lasterror();
    status = strcmp(lastError.identifier, MsgIDExpected) && ...
        ~isempty( strfind(lastError.message, 'Input argument ffiInfoStruct is not a valid struct') );
    mlunit_assert( status, 'Invalid ffiInfoStruct test case failed');
end

%invalid fields
ffiInfoStruct  = rmfield(ffiInfoStruct_0, 'STARTIME');
try
    selectedTemperatureStruct = bart_get_temperatures(ffiInfoStruct, temperatureMnemonics_0);
catch
    lastError = lasterror();
    status = strcmp(lastError.identifier, MsgIDExpected) && ...
        ~isempty( strfind(lastError.message, 'Input argument ffiInfoStruct has invalid fields') );
    mlunit_assert( status, 'Invalid ffiInfoStruct field test case failed');
end

%% Invalid mnemonics

% empty mnemonics
temperatureMnemonics = {};
try
    selectedTemperatureStruct = bart_get_temperatures(ffiInfoStruct_0, temperatureMnemonics);
catch
    lastError = lasterror();
    status = strcmp(lastError.identifier, MsgIDExpected) && ...
        ~isempty( strfind(lastError.message, 'Input argument temperatureMnemonics is not a valid cell') );
    mlunit_assert( status, 'Invalid ffiInfoStruct field test case failed');
end

% mnemonic of wrong type
temperatureMnemonics = ['PEDDRV1T', 'PEDDRV1ST'];
try
    selectedTemperatureStruct = bart_get_temperatures(ffiInfoStruct_0, temperatureMnemonics);
catch
    lastError = lasterror();
    status = strcmp(lastError.identifier, MsgIDExpected) && ...
        ~isempty( strfind(lastError.message, 'Input argument temperatureMnemonics is not a valid cell') );
    mlunit_assert( status, 'Invalid ffiInfoStruct field test case failed');
end

% mnemonics of wrong dimension
temperatureMnemonics = {'PEDDRV1T', 'PEDDRV1ST', 'PEDDRV3T'};
try
    selectedTemperatureStruct = bart_get_temperatures(ffiInfoStruct_0, temperatureMnemonics);
catch
    lastError = lasterror();
    status = strcmp(lastError.identifier, MsgIDExpected) && ...
        ~isempty( strfind(lastError.message, 'Temperature menmonics error in size') );
    mlunit_assert( status, 'Invalid ffiInfoStruct field test case failed');
end

return;