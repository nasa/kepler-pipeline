function self = test_rpts_matlab_controller(self)
% self = test_rpts_matlab_controller(self)
%
% This test loads stored verified results and also loads the same input
% and compares the generated results with the verified results.
%
% rptsInputStruct =
%     rptsModuleParametersStruct: [struct]
%           moduleOutputImage: [struct array]
%            stellarApertures: [struct array]
%       dynamicRangeApertures: [struct array]
%               existingMasks: [struct array]
%                   debugFlag: [logical flag]
%
% If the regression test fails, an error condition occurs.
%
%  Use a test runner to run the test method:
%  Example: run(text_test_runner, testRptsClass('test_rpts_matlab_controller'));
%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%  SOC_REQ_MAP: 967.TAD.1, M.test_rpts_matlab_controller, CERTIFIED <>
%  SOC_REQ_MAP: 685.TAD.1, M.test_rpts_matlab_controller, CERTIFIED <>
%  SOC_REQ_MAP: 1068.TAD.1, M.test_rpts_matlab_controller, CERTIFIED <>
%  SOC_REQ_MAP: 926.TAD.13, M.test_rpts_matlab_controller, CERTIFIED <>
%  SOC_REQ_MAP: 926.TAD.14, M.test_rpts_matlab_controller, CERTIFIED <>
%  SOC_REQ_MAP: 926.TAD.25, M.test_rpts_matlab_controller, CERTIFIED <>
%  SOC_REQ_MAP: 926.TAD.30, M.test_rpts_matlab_controller, CERTIFIED <>
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

% generate input test data, or load pre-generated data

% [rptsInputStruct] = generate_rpts_input_data;
% load inputs.mat  rptsInputStruct % or load rptsInputStruct directly from matfile
% load /path/to/matlab/tad/rpts/inputs_May2.mat rptsInputStruct;
%load ../rpts_bug_fix/rptsInputs.mat rptsInputStruct

load rptsInputsJune17.mat rptsInputStruct

inputFileName = 'inputs-0.bin';
outputFileName = 'outputs-0.bin';

% write to, and read from, auto-generated scripts for input
write_RptsInputs(inputFileName, rptsInputStruct);
rptsInputStructNew = read_RptsInputs(inputFileName);
delete(inputFileName);

% convert to floats for assert equals test
rptsInputStruct  = convert_struct_fields_to_float(rptsInputStruct);
rptsInputStructNew  = convert_struct_fields_to_float(rptsInputStructNew);

% compare structures that are written to and read back from a bin file
messageOut = 'rpts_matlab_controller - data generated and read back by read_RptsInputs are not identical!';
assert_equals(rptsInputStructNew, rptsInputStruct, messageOut);

%--------------------------------------------------------------------------
% generate output test data
%--------------------------------------------------------------------------
[rptsResultsStruct] = rpts_matlab_controller(rptsInputStructNew);

% write to, and read from, auto-generated scripts for output
write_RptsOutputs(outputFileName, rptsResultsStruct);
rptsResultsStructNew = read_RptsOutputs(outputFileName);
delete(outputFileName);

% convert to floats for assert equals test
rptsResultsStruct = convert_struct_fields_to_float(rptsResultsStruct);
rptsResultsStructNew = convert_struct_fields_to_float(rptsResultsStructNew);

messageOut = 'rpts_matlab_controller - results received and read back by read_RptsOutputs are not identical!';
assert_equals(rptsResultsStruct, rptsResultsStructNew, messageOut);

% Optional: save test results 
% testResults = struct('rptsInputStruct', rptsInputStruct, 'rptsInputStructNew', ...
%       rptsInputStructNew, 'rptsResultsStruct', rptsResultsStruct, 'rptsResultsStructNew', rptsResultsStructNew);
% save test_matlab_controller_results.mat testResults  

return