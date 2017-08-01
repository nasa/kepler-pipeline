function [self] = test_hgn_matlab_controller(self)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [self] = test_hgn_matlab_controller(self)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% This test generates or loads a previously generated hgn input data
% structure, and then compares that structure with another obtained by
% writing and reading a binary file.
%
% After generating a hgn results structure with the hgn_matlab_controller,
% this test also compares that structure with another obtained by writing
% and reading a binary file.
%
% hgnDataStruct =
%         hgnModuleParameters: [struct]  module parameters
%                      ccdModule: [int]  CCD module number
%                      ccdOutput: [int]  CCD output number
%         invocationCadenceStart: [int]  first cadence for this invocation
%           invocationCadenceEnd: [int]  last cadence for this invocation
%      firstMatlabInvocation: [logical]  flag to indicate initial run
%            requant table: [int array]  requantization table values
%         cadencePixels: [struct array]  requantized pixels for each cadence
%                      debugFlag: [int]  indicates debug level
%
% hgnResultsStruct = 
%                      ccdModule: [int]  CCD module number
%                      ccdOutput: [int]  CCD output number
%         invocationCadenceStart: [int]  first cadence for this invocation
%           invocationCadenceEnd: [int]  last cadence for this invocation
%            histograms: [struct array]  histograms for each baseline interval
%     modOutBestBaselineInterval: [int]  best interval for this module output (cadences)
%        modOutBestStorageRate: [float]  minimum storage rate of all intervals (bpp)
%
%
% If the regression test fails, an error condition occurs.
%
%  Example
%  =======
%  Use a test runner to run the test method:
%      run(text_test_runner, testHgnDataClass('test_hgn_matlab_controller'));
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

% Set path to unit test inputs.
initialize_soc_variables;
path = fullfile(socTestDataRoot, 'gar', 'unit-tests', 'hgn');

inputFileName = 'inputs-0.bin';
outputFileName = 'outputs-0.bin';
hgnStateFileName = 'hgn_state.mat';
matFileName = 'HgnInputs.mat';
fullMatFileName = fullfile(path, matFileName);

% Generate input test data, or load pre-generated data.
% [hgnDataStruct] = generate_hgn_test_data;
load(fullMatFileName, 'hgnDataStruct');

% Write to, and read from, auto-generated scripts for input.
write_HgnInputs(inputFileName, hgnDataStruct);
[hgnDataStructNew] = read_HgnInputs(inputFileName);
delete(inputFileName);

% Convert to floats for assert equals test.
[hgnDataStruct] = convert_struct_fields_to_float(hgnDataStruct);
[hgnDataStructNew] = convert_struct_fields_to_float(hgnDataStructNew);

% Compare structures that are written to and read back from a bin file.
messageOut = 'hgn_matlab_controller - data generated and read back by read_HgnInputs are not identical!';
assert_equals(hgnDataStructNew, hgnDataStruct, messageOut);


%--------------------------------------------------------------------------
% Generate output test data.
%--------------------------------------------------------------------------
[hgnResultsStruct] = hgn_matlab_controller(hgnDataStructNew);
delete(hgnStateFileName);

% Write to, and read from, auto-generated scripts for output.
write_HgnOutputs(outputFileName, hgnResultsStruct);
[hgnResultsStructNew] = read_HgnOutputs(outputFileName);
delete(outputFileName);

% Convert to floats for assert equals test.
[hgnResultsStruct] = convert_struct_fields_to_float(hgnResultsStruct);
[hgnResultsStructNew] = convert_struct_fields_to_float(hgnResultsStructNew);

% Compare structures that are written to and read back from a bin file.
messageOut = 'hgn_matlab_controller - results received and read back by read_HgnOutputs are not identical!';
assert_equals(hgnResultsStruct, hgnResultsStructNew, messageOut);

%{
% Optional: save test results. 
testResults = struct( ...
    'hgnDataStruct', hgnDataStruct, ... 
    'hgnDataStructNew', hgnDataStructNew, ...
    'hgnResultsStruct', hgnResultsStruct, ...
    'hgnResultsStructNew', hgnResultsStructNew);
save('test_matlab_controller_results.mat', 'testResults'); 
%}

% Return.
return
