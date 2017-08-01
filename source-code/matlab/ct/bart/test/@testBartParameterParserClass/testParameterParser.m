function self = testParameterParser( self )
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

disp('Executing testParameterParser()');
MsgID = 'CT:BART:testBartParameterParserClass:testParameterParser';

MsgIDExpected = 'CT:BART:bart_parameters_parser';

%% nominal case
inputParameterFilename = 'unit_test_data/bart_ffi_tvac_input_pc.txt';
try
    bartDataInStruct = bart_parameters_parser(inputParameterFilename);
catch
    lastError = lasterror();
    disp(['Error ID: ' lastError.identifier]);
    disp(['Error Msg: ' lastError.message]);
    error(MsgID, 'error with bart_parameter_parser()');
end

% load groundtrudth: bartDataInStruct_0
load 'unit_test_data/parameter_parser_unit_test.mat';
status = isequal(bartDataInStruct_0, bartDataInStruct);
mlunit_assert( status, 'Nominal case failed');

%% Invalid input struct

% non exist input file name
inputParameterFilename  = 'abc';
try
    bartDataInStruct = bart_parameters_parser( inputParameterFilename );
catch
    lastError = lasterror();
    status = strcmp(lastError.identifier, MsgIDExpected) && ...
        ~isempty( strfind(lastError.message, 'Input parameter file is empty, not string or does not exist!') );
    mlunit_assert( status, 'Invalid input filename test case failed');
end

% input file with empty fields
inputParameterFilename  = 'unit_test_data/bart_input_bad_2_pc.txt';
try
    bartDataInStruct = bart_parameters_parser( inputParameterFilename );
catch
    lastError = lasterror();
    status = strcmp(lastError.identifier, MsgIDExpected) && ...
        ~isempty( strfind(lastError.message, 'Error in reading keyword values from file') );
    mlunit_assert( status, 'Input file with invalid fields test case failed');
end

% input file with bad fields
inputParameterFilename  = 'unit_test_data/bart_input_bad_1_pc.txt';
try
    bartDataInStruct = bart_parameters_parser( inputParameterFilename );
catch
    lastError = lasterror();
    status = strcmp(lastError.identifier, MsgIDExpected) && ...
        ~isempty( strfind(lastError.message, 'Unexpected empty or none character keyword') );
    mlunit_assert( status, 'Input file with invalid fields test case failed');
end

% input file with mnemonic file that does not exist
inputParameterFilename  = 'unit_test_data/bart_input_bad_4_pc.txt';
try
    bartDataInStruct = bart_parameters_parser( inputParameterFilename );
catch
    lastError = lasterror();
    status = strcmp(lastError.identifier, MsgIDExpected) && ...
        ~isempty( strfind(lastError.message, 'Mnemonic file does not exist') );
    mlunit_assert( status, 'Input file with non existence mnemonic file test case failed');
end

% input file with missing keyword
inputParameterFilename  = 'unit_test_data/bart_input_bad_5_pc.txt';
try
    bartDataInStruct = bart_parameters_parser( inputParameterFilename );
catch
    lastError = lasterror();
    status = strcmp(lastError.identifier, MsgIDExpected) && ...
        ~isempty( strfind(lastError.message, 'Missing fields in bartDataInStruct') );
    mlunit_assert( status, 'Input file with missing fields test case failed');
end
return;