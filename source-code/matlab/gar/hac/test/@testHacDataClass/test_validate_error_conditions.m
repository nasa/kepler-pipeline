function [self] = test_validate_error_conditions(self)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [self] = test_validate_error_conditions(self)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% This test validates that hac error conditions are properly caught. The
% following error conditions are tested:
%
%  1. missingStateFile - hac state file missing from prior invocation
%  2. emptyHistograms - empty histograms struct array
%  3. invalidBaselineIntervalValue - value in one invocation different than
%     prior invocation
%  4. invalidHistogramLength - length of histogram vector (empty or otherwise)
%     is different than Huffman table size
%
%  Example
%  =======
%  Use a test runner to run the test method:
%      run(text_test_runner, testHacDataClass('test_validate_error_conditions'));
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

matFileName = 'HacInputs.mat';
binFileName = 'HacInputs-0.bin';
hacStateFileName = 'hac_state.mat';
fullMatFileName = fullfile(path, matFileName);
fullBinFileName = fullfile(path, binFileName);

% Generate an input structure by one of the following methods:

% (1) Create an input structure hacDataStruct
% [hacDataStruct] = generate_hac_test_data;

% (2) Load a previously generated test data structure hacDataStruct
load(fullMatFileName, 'hacDataStruct');

% (3) Read a test data structure hacDataStruct from a previously
%     generated bin file
% [hacDataStruct] = read_HacInputs(fullBinFileName);

% Save the original hac data structure.
originalHacDataStruct = hacDataStruct;

% Test for missing state file.
hacDataStruct = originalHacDataStruct;
hac_matlab_controller(hacDataStruct);
delete(hacStateFileName);

hacDataStruct.firstMatlabInvocation = false;

try_to_catch_error_condition('hac_matlab_controller(hacDataStruct)', ...
    'missingStateFile', hacDataStruct, 'hacDataStruct');

% Test for empty histograms struct array.
hacDataStruct = originalHacDataStruct;
hacDataStruct.histograms = [];

try_to_catch_error_condition('hac_matlab_controller(hacDataStruct)', ...
    'emptyHistograms', hacDataStruct, 'hacDataStruct');

% Test for invalid baseline interval value.
hacDataStruct = originalHacDataStruct;
hac_matlab_controller(hacDataStruct);

hacDataStruct.firstMatlabInvocation = false;
hacDataStruct.histograms(1).baselineInterval = ...
    hacDataStruct.histograms(1).baselineInterval + 1;

try_to_catch_error_condition('hac_matlab_controller(hacDataStruct)', ...
    'invalidBaselineIntervalValue', hacDataStruct, 'hacDataStruct');

% Test for empty histogram and invalid histogram vector length.
hacDataStruct = originalHacDataStruct;
hacDataStruct.histograms(1).histogram = [];

try_to_catch_error_condition('hac_matlab_controller(hacDataStruct)', ...
    'FieldEmpty', hacDataStruct, 'hacDataStruct');

hacDataStruct = originalHacDataStruct;
hacDataStruct.histograms(3).histogram = ...
    hacDataStruct.histograms(3).histogram(1 : end - 1);

try_to_catch_error_condition('hac_matlab_controller(hacDataStruct)', ...
    'invalidHistogramLength', hacDataStruct, 'hacDataStruct');

fprintf('\n');

% Delete the hac state file.
delete(hacStateFileName);

% Return.
return
