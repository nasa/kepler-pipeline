function [self] = test_hac_matlab_controller(self)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [self] = test_hac_matlab_controller(self)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% This test generates or loads a previously generated hac input data
% structure, and then compares that structure with another obtained by
% writing and reading a binary file.
%
% After generating a hac results structure with the hac_matlab_controller,
% this test also compares that structure with another obtained by writing
% and reading a binary file.
%
% hacDataStruct =
%            invocationCcdModule: [int]  CCD module for this invocation
%            invocationCcdOutput: [int]  CCD output for this invocation
%                   cadenceStart: [int]  first cadence for histograms
%                     cadenceEnd: [int]  last cadence for histograms
%      firstMatlabInvocation: [logical]  flag to indicate initial run
%            histograms: [struct array]  histograms for each baseline interval
%                      debugFlag: [int]  indicates debug level
%
% hacResultsStruct =
%            invocationCcdModule: [int]  CCD module for this invocation
%            invocationCcdOutput: [int]  CCD output for this invocation
%                   cadenceStart: [int]  first cadence for histograms
%                     cadenceEnd: [int]  last cadence for histograms
%            histograms: [struct array]  histograms for each baseline interval
%  overallBestBaselineInterval: [float]  best interval for all mod outputs (cadences)
%       overallBestStorageRate: [float]  minimum storage rate for all intervals (bpp)
%
%
% If the regression test fails, an error condition occurs.
%
%  Example
%  =======
%  Use a test runner to run the test method:
%      run(text_test_runner, testHacDataClass('test_hac_matlab_controller'));
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
path = fullfile(socTestDataRoot, 'gar', 'unit-tests', 'hac');

inputFileName = 'inputs-0.bin';
outputFileName = 'outputs-0.bin';
hacStateFileName = 'hac_state.mat';
matFileName = 'HacInputs.mat';
fullMatFileName = fullfile(path, matFileName);

% Generate input test data, or load pre-generated data.
% [hacDataStruct] = generate_hac_test_data;
load(fullMatFileName, 'hacDataStruct');

% Write to, and read from, auto-generated scripts for input.
write_HacInputs(inputFileName, hacDataStruct); %#ok<NODEF>
[hacDataStructNew] = read_HacInputs(inputFileName);
delete(inputFileName);

% Convert to floats for assert equals test.
[hacDataStruct] = convert_struct_fields_to_float(hacDataStruct);
[hacDataStructNew] = convert_struct_fields_to_float(hacDataStructNew);

% Compare structures that are written to and read back from a bin file.
messageOut = 'hac_matlab_controller - data generated and read back by read_HacInputs are not identical!';
assert_equals(hacDataStructNew, hacDataStruct, messageOut);


%--------------------------------------------------------------------------
% Generate output test data.
%--------------------------------------------------------------------------
[hacResultsStruct] = hac_matlab_controller(hacDataStructNew);
delete(hacStateFileName);

% Write to, and read from, auto-generated scripts for output.
write_HacOutputs(outputFileName, hacResultsStruct);
[hacResultsStructNew] = read_HacOutputs(outputFileName);
delete(outputFileName);

% Convert to floats for assert equals test.
[hacResultsStruct] = convert_struct_fields_to_float(hacResultsStruct);
[hacResultsStructNew] = convert_struct_fields_to_float(hacResultsStructNew);

% Compare structures that are written to and read back from a bin file.
messageOut = 'hac_matlab_controller - results received and read back by read_HacOutputs are not identical!';
assert_equals(hacResultsStruct, hacResultsStructNew, messageOut);

%{
% Optional: save test results. 
testResults = struct( ...
    'hacDataStruct', hacDataStruct, ... 
    'hacDataStructNew', hacDataStructNew, ...
    'hacResultsStruct', hacResultsStruct, ...
    'hacResultsStructNew', hacResultsStructNew);
save('test_matlab_controller_results.mat', 'testResults'); 
%}

% Return.
return
