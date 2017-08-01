function self = testTemperatureConditioning(self)
%function self = testTemperatureConditioning(self)
% test temperature conditioning logics
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

MsgID = 'CT:BART:testBartTemperatureConditioningClass:testTemperatureConditioning';

disp( 'testTemperatureConditioning' );

nFFI = 2;

oneTemperatureStruct = struct( ...
    'temperatureMean',      [], ...
    'temperatureStd',       [], ...
    'temperatureSamples',   [], ...
    'temperatureMnemonics', [] ...
    );

%% test nominal case
oneTemperatureStruct.temperatureMnemonics = {'PEDACQ1T'; 'PEDACQ1T'; 'PEDDRV3T'; 'PEDDRV4T'};
oneTemperatureStruct.temperatureMean    = [ 1,  2,   3,  4];
oneTemperatureStruct.temperatureStd     = [ 11, 12, 13, 14];
oneTemperatureStruct.temperatureSamples = [ 21, 22, 23, 24];

selectedTemperatureStruct = repmat(oneTemperatureStruct, nFFI, 1);

% calculatethe true values
meanGroundTruth = zeros(nFFI, 1);
for k=1:nFFI
    meanGroundTruth(k) = mean( [selectedTemperatureStruct(k).temperatureMean], 2 );
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

assert( all(meanGroundTruth == averagedTemperatures), 'Norminal case failed!' );

%% test no input
try
    averagedTemperatures = bart_temperature_conditioning();
catch
    lastError = lasterror();
    status = strcmp(lastError.identifier, 'CT:BART:bart_temperature_conditioning') && ...
        ~isempty( strfind(lastError.message, 'No valid input') );
    mlunit_assert( status, 'No input test failed!');
end

%% test empty input
try
    averagedTemperatures = bart_temperature_conditioning([]);
catch
    lastError = lasterror();
    status = strcmp(lastError.identifier, 'CT:BART:bart_temperature_conditioning') && ...
        ~isempty( strfind(lastError.message, 'Input is not a struct or empty'));
    mlunit_assert( status, 'Empty input test failed!');
end

%% test input of wrong type
junk = 1.0;
try
    averagedTemperatures = bart_temperature_conditioning( junk );
catch
    lastError = lasterror();
    status = strcmp(lastError.identifier, 'CT:BART:bart_temperature_conditioning') && ...
        ~isempty( strfind(lastError.message, 'Input is not a struct or empty'));
    mlunit_assert( status, 'Input of wrong type test failed!');
end

%% test input with wrong or missing field
missingFieldStruct = rmfield(oneTemperatureStruct, 'temperatureMean');
try
    averagedTemperatures = bart_temperature_conditioning( missingFieldStruct );
catch
    lastError = lasterror();
    status = strcmp(lastError.identifier, 'CT:BART:bart_temperature_conditioning') && ...
        ~isempty( strfind(lastError.message, 'Input struct has non existence fields'));
    mlunit_assert( status, 'Input with missing field test failed!');
end

% incorrect field
wrongFieldStruct = struct( ...
    'temperatureMean_1',      [], ...
    'temperatureMnemonics_1', [] ...
    );
try
    averagedTemperatures = bart_temperature_conditioning( wrongFieldStruct );
catch
    lastError = lasterror();
    status = strcmp(lastError.identifier, 'CT:BART:bart_temperature_conditioning') && ...
        ~isempty( strfind(lastError.message, 'Input struct has non existence fields'));
    mlunit_assert( status, 'Input with incorrect field test failed!');
end

% empty field
emptyFieldStruct = oneTemperatureStruct;
emptyFieldStruct.temperatureMean = [];
try
    averagedTemperatures = bart_temperature_conditioning( emptyFieldStruct );
catch
    lastError = lasterror();
    status = strcmp(lastError.identifier, 'CT:BART:bart_temperature_conditioning') && ...
        ~isempty( strfind(lastError.message, 'Input struct has empty fields'));
    mlunit_assert( status, 'Input with empty field test failed!');
end

%%  test input with wrong temperature measurements or types
% inconsistent mnemonics and temperature measurements
wrongDataStruct = oneTemperatureStruct;
wrongDataStruct.temperatureMean(1) = [];
try
    averagedTemperatures = bart_temperature_conditioning( wrongDataStruct );
catch
    lastError = lasterror();
    status = strcmp(lastError.identifier, 'CT:BART:bart_temperature_conditioning') && ...
        ~isempty( strfind(lastError.message, 'Incorrect temperature measurements or types!'));
    mlunit_assert( status, 'Input with wrong data length test failed!');
end

% wrong data dimension
wrongDataStruct = oneTemperatureStruct;
wrongDataStruct.temperatureMean = ones(2, 8);
try
    averagedTemperatures = bart_temperature_conditioning( wrongDataStruct );
catch
    lastError = lasterror();
    status = strcmp(lastError.identifier, 'CT:BART:bart_temperature_conditioning') && ...
        ~isempty( strfind(lastError.message, 'Incorrect temperature measurements or types!'));
    mlunit_assert( status, 'Input with wrong data length test failed!');
end

% wrong mnemonic dimension
wrongDataStruct = oneTemperatureStruct;
wrongDataStruct.temperatureMnemonics(end+1) = {'junk'};
try
    averagedTemperatures = bart_temperature_conditioning( wrongDataStruct );
catch
    lastError = lasterror();
    status = strcmp(lastError.identifier, 'CT:BART:bart_temperature_conditioning') && ...
        ~isempty( strfind(lastError.message, 'Incorrect temperature measurements or types!'));
    mlunit_assert( status, 'Input with wrong data length test failed!');
end

return;