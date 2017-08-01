function [self] = test_validate_error_conditions(self)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [self] = test_validate_error_conditions(self)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% This test validates that hgn error conditions are properly caught. The
% following error conditions are tested:
%
%  1. missingStateFile - hgn state file missing from prior invocation
%  2. emptyBaselineIntervals - baseline intervals are not specified
%  3. invalidBaselineIntervalValue - value in one invocation different than
%     prior invocation
%  4. cadenceGap - gap between cadence start in one invocation and end from
%     prior invocation
%  5. tableLookupError - requantization table lookup error
%  6. emptyCadencePixels - empty cadence pixels struct array
%  7. emptyPixelValues - pixel values are not specified
%  8. invalidPixelValuesLength - length of pixel values vector is different
%     from cadence to cadence
%  9. invalidGapIndicatorsLength - length of gap indicators vector is different
%     than pixel values vector
%
%  Example
%  =======
%  Use a test runner to run the test method:
%      run(text_test_runner, testHgnDataClass('test_validate_error_conditions'));
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

matFileName = 'HgnInputs.mat';
binFileName = 'HgnInputs-0.bin';
hgnStateFileName = 'hgn_state.mat';
fullMatFileName = fullfile(path, matFileName);
fullBinFileName = fullfile(path, binFileName);

% Generate an input structure by one of the following methods:

% (1) Create an input structure hgnDataStruct
% [hgnDataStruct] = generate_hgn_test_data;

% (2) Load a previously generated test data structure hgnDataStruct
load(fullMatFileName, 'hgnDataStruct');

% (3) Read a test data structure hgnDataStruct from a previously
%     generated bin file
% [hgnDataStruct] = read_HgnInputs(fullBinFileName);

% Save the original hgn data structure.
originalHgnDataStruct = hgnDataStruct;

% Test for missing state file.
hgnDataStruct = originalHgnDataStruct;
[hgnResultsStruct] = hgn_matlab_controller(hgnDataStruct);
delete(hgnStateFileName);

hgnDataStruct.firstMatlabInvocation = false;
hgnDataStruct.invocationCadenceStart = ...
    hgnResultsStruct.invocationCadenceEnd + 1;
hgnDataStruct.invocationCadenceEnd = hgnDataStruct.invocationCadenceStart + ...
    (hgnResultsStruct.invocationCadenceEnd - hgnResultsStruct.invocationCadenceStart);

try_to_catch_error_condition('hgn_matlab_controller(hgnDataStruct)', ...
    'missingStateFile', hgnDataStruct, 'hgnDataStruct');

% Test for empty baseline intervals.
hgnDataStruct = originalHgnDataStruct;
hgnDataStruct.hgnModuleParameters.baselineIntervals = [];

try_to_catch_error_condition('hgn_matlab_controller(hgnDataStruct)', ...
    'FieldEmpty', hgnDataStruct, 'hgnDataStruct');

% Test for invalid baseline interval value.
hgnDataStruct = originalHgnDataStruct;
[hgnResultsStruct] = hgn_matlab_controller(hgnDataStruct);

hgnDataStruct.firstMatlabInvocation = false;
hgnDataStruct.hgnModuleParameters.baselineIntervals(1) = ...
    hgnDataStruct.hgnModuleParameters.baselineIntervals(1) + 1;
hgnDataStruct.invocationCadenceStart = ...
    hgnResultsStruct.invocationCadenceEnd + 1;
hgnDataStruct.invocationCadenceEnd = hgnDataStruct.invocationCadenceStart + ...
    (hgnResultsStruct.invocationCadenceEnd - hgnResultsStruct.invocationCadenceStart);

try_to_catch_error_condition('hgn_matlab_controller(hgnDataStruct)', ...
    'invalidBaselineIntervalValue', hgnDataStruct, 'hgnDataStruct');

% Test for cadence gap.
hgnDataStruct = originalHgnDataStruct;
[hgnResultsStruct] = hgn_matlab_controller(hgnDataStruct);

hgnDataStruct.firstMatlabInvocation = false;
hgnDataStruct.invocationCadenceStart = ...
    hgnResultsStruct.invocationCadenceEnd + 2;
hgnDataStruct.invocationCadenceEnd = hgnDataStruct.invocationCadenceStart + ...
    (hgnResultsStruct.invocationCadenceEnd - hgnResultsStruct.invocationCadenceStart);

try_to_catch_error_condition('hgn_matlab_controller(hgnDataStruct)', ...
    'cadenceGap', hgnDataStruct, 'hgnDataStruct');

% Test for requantization table lookup errors.
hgnDataStruct = originalHgnDataStruct;
hgnDataStruct.cadencePixels(1).pixelValues(1) = ...
    hgnDataStruct.cadencePixels(1).pixelValues(1) + 1;

try_to_catch_error_condition('hgn_matlab_controller(hgnDataStruct)', ...
    'tableLookupError', hgnDataStruct, 'hgnDataStruct');

hgnDataStruct = originalHgnDataStruct;
hgnDataStruct.cadencePixels(1).pixelValues(1) = ...
    hgnDataStruct.requantTable.requantEntries(end) + 1000;

try_to_catch_error_condition('hgn_matlab_controller(hgnDataStruct)', ...
    'tableLookupError', hgnDataStruct, 'hgnDataStruct');

% Test for empty cadence pixels struct array.
hgnDataStruct = originalHgnDataStruct;
hgnDataStruct.cadencePixels = [];

try_to_catch_error_condition('hgn_matlab_controller(hgnDataStruct)', ...
    'emptyCadencePixels', hgnDataStruct, 'hgnDataStruct');

% Test for empty pixel values vector.
hgnDataStruct = originalHgnDataStruct;
hgnDataStruct.cadencePixels(1).pixelValues = [];

try_to_catch_error_condition('hgn_matlab_controller(hgnDataStruct)', ...
    'FieldEmpty', hgnDataStruct, 'hgnDataStruct');

% Test for invalid pixel values vector length.
hgnDataStruct = originalHgnDataStruct;
hgnDataStruct.cadencePixels(2).pixelValues = ...
    hgnDataStruct.cadencePixels(2).pixelValues(1 : end - 1);

try_to_catch_error_condition('hgn_matlab_controller(hgnDataStruct)', ...
    'invalidPixelValuesLength', hgnDataStruct, 'hgnDataStruct');

hgnDataStruct = originalHgnDataStruct;
[hgnResultsStruct] = hgn_matlab_controller(hgnDataStruct);

hgnDataStruct.firstMatlabInvocation = false;
hgnDataStruct.invocationCadenceStart = ...
    hgnResultsStruct.invocationCadenceEnd + 1;
hgnDataStruct.invocationCadenceEnd = hgnDataStruct.invocationCadenceStart + ...
    (hgnResultsStruct.invocationCadenceEnd - hgnResultsStruct.invocationCadenceStart);
hgnDataStruct.cadencePixels(1).pixelValues = ...
    hgnDataStruct.cadencePixels(1).pixelValues(1 : end - 1);

try_to_catch_error_condition('hgn_matlab_controller(hgnDataStruct)', ...
    'invalidPixelValuesLength', hgnDataStruct, 'hgnDataStruct');

% Test for invalid gap indicators vector length.
hgnDataStruct = originalHgnDataStruct;
hgnDataStruct.cadencePixels(2).gapIndicators = ...
    hgnDataStruct.cadencePixels(2).gapIndicators(1 : end - 1);

try_to_catch_error_condition('hgn_matlab_controller(hgnDataStruct)', ...
    'invalidGapIndicatorsLength', hgnDataStruct, 'hgnDataStruct');

fprintf('\n');

% Delete the hgn state file.
delete(hgnStateFileName);

% Return.
return
