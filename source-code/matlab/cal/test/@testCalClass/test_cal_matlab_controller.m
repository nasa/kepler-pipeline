function self = test_cal_matlab_controller(self)
% self = test_cal_matlab_controller(self)
%
% This test loads stored verified results and also loads the same input
% and compares the generated results with the verified results.
%
% If the regression test fails, an error condition occurs.
%
%  Use a test runner to run the test method:
%  Example: run(text_test_runner, testCalClass('test_cal_matlab_controller'));
%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%  SOC_REQ_MAP:
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
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

% (1) generate input test data, or load pre-generated data
% [calInputStruct] = generate_cal_collateral_input_data_etem2

% (2) load inputs .mat file 
%load calInput_shortCad_30Cad_Apr30.mat calInputStruct % short cad collateral data 30 cadences from SM

%load /path/to/matlab/cal/calInputStruct_fromSean_collateralData_30Cadences_May30.mat
%load /path/to/matlab/cal/calInputStruct_smoketest24_collateralData_June9.mat calInputStruct


%load calInputStruct_30cadApr28.mat calInputStruct % collateral data 30 cadences from SM
%load calInputStruct_currentJavaBinfile.mat calInputStruct % collateral data all cadences fromSM
%load calInputStruct_phot30cadNEW.mat calInputStruct % photometric data from SM
%load caltest.mat calInputStruct  % collateral data from MC
%load caltest1.mat calInputStruct % photometric data from MC
% load sample_data/cal-inputs-0.bin calInputStruct  % collateral data all cadences fromSM
% load sample_data/cal-inputs-1.bin calInputStruct  % photometric data all cadences fromSM

load calInputStruct

inputFileName = 'inputs-0.bin';
outputFileName = 'outputs-0.bin';

% write to, and read from, auto-generated scripts for input
write_CalInputs(inputFileName, calInputStruct);
calInputStructNEW = read_CalInputs(inputFileName);
delete(inputFileName);

% convert to floats for assert equals test
calInputStruct  = convert_struct_fields_to_float(calInputStruct);
calInputStructNEW  = convert_struct_fields_to_float(calInputStructNEW);

% compare structures that are written to and read back from a bin file
messageOut = 'cal_matlab_controller - input data written to bin file and read back by read_CalInputs are not identical!';
assert_equals(calInputStructNEW, calInputStruct, messageOut);

%--------------------------------------------------------------------------
% run the controller and generate output data with newly generated input struct
%--------------------------------------------------------------------------
calOutputStruct = cal_matlab_controller(calInputStructNEW);

% write to, and read from, auto-generated scripts for output
write_CalOutputs(outputFileName, calOutputStruct);

calOutputStructNew = read_CalOutputs(outputFileName);
%delete(outputFileName);

% convert to floats for assert equals test
calOutputStruct = convert_struct_fields_to_float(calOutputStruct);
calOutputStructNew = convert_struct_fields_to_float(calOutputStructNew);

messageOut = 'cal_matlab_controller - data written to bin file and read back by read_CalOutputs are not identical!';
assert_equals(calOutputStruct, calOutputStructNew, messageOut);

return