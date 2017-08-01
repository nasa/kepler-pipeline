%% test_validate_bootstrap_object
%
% function [self] = test_validate_bootstrap_object(self)
%
% Tests that validate_bootstrapObject will make the right call in
% determining whether the input data produces a valid bootstrap object.
% Also tests the precedence of the warning messages.
%
% Run with:
%   run(text_test_runner, testBootstrapClass('test_validate_bootstrap_object'));
%%
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
function [self] = test_validate_bootstrap_object(self)

% Add paths for test-data and test-meta data
initialize_soc_variables;
bootstrapTestDir = fullfile('dv', 'unit-tests', 'bootstrap');
testMetaDataRoot = fullfile(socTestMetaDataRoot, bootstrapTestDir);
addpath(testMetaDataRoot);

% Load a dvResultsStruct, clear fields in alerts
load(fullfile(socTestDataRoot, 'dv', 'unit-tests', 'dv-matlab-controller', 'dvResultsStruct.mat'));

dvResultsStruct.alerts(end).severity = [];
dvResultsStruct.alerts(end).message = [];
dvResultsStruct.alerts(end).time = [];

% Generate the bootstrapInputStruct
bootstrapInputStruct = generate_bootstrapinputstruct_with_soho_data;

% Instantiate the bootstrap object
bsObject = bootstrapClass(bootstrapInputStruct);
bsObject = set(bsObject, 'targetNumber', 1);

%--------------------------------------------------------------------------
% Flag suspected EB and test for invalid object warning
%--------------------------------------------------------------------------
dvResultsStruct.targetResultsStruct.planetResultsStruct.planetCandidate.suspectedEclipsingBinary = true;

[validBsObject dvResultsStruct] = validate_bootstrapObject(bsObject, dvResultsStruct);

assert_equals(validBsObject, false);

expectedMessage= 'Planet is suspected to be an eclipsing binary';
actualMessage = dvResultsStruct.alerts(end).message;
mlunit_assert(~isempty(strfind(actualMessage, expectedMessage)), ...
    message(actualMessage, expectedMessage));

%--------------------------------------------------------------------------
% Assign observedTransitCount = 0 and test for invalid object and warning
%--------------------------------------------------------------------------

% Set EB flag back to false
dvResultsStruct.targetResultsStruct.planetResultsStruct.planetCandidate.suspectedEclipsingBinary = false;

bsObject = set(bsObject, 'observedTransitCount', 0);
bsObject = set(bsObject, 'numberPulseWidths', 1);
bsObject = set(bsObject, 'searchTransitThreshold', 7.1);
bsObject = set(bsObject, 'nullTailMaxSigma', 9.0);

[validBsObject dvResultsStruct] = validate_bootstrapObject(bsObject, dvResultsStruct);

assert_equals(validBsObject, false);

expectedMessage= 'Observed transit count information not available, will not proceed with bootstrap';
actualMessage = dvResultsStruct.alerts(end).message;
mlunit_assert(~isempty(strfind(actualMessage, expectedMessage)), ...
    message(actualMessage, expectedMessage));

%--------------------------------------------------------------------------
% Assign numberPulseWidths = 0
%--------------------------------------------------------------------------
bsObject = set(bsObject, 'observedTransitCount', 3);
bsObject = set(bsObject, 'numberPulseWidths', 0);
bsObject = set(bsObject, 'searchTransitThreshold', 7.1);
bsObject = set(bsObject, 'nullTailMaxSigma', 7.0);

[validBsObject dvResultsStruct] = validate_bootstrapObject(bsObject, dvResultsStruct);

assert_equals(validBsObject, false);

expectedMessage= 'Invalid single event statistics time series';
actualMessage = dvResultsStruct.alerts(end).message;
mlunit_assert(~isempty(strfind(actualMessage, expectedMessage)), ...
    message(actualMessage, expectedMessage));

%--------------------------------------------------------------------------
% Assign a nullTailMaxSigma that is less than searchTransitThreshold
%--------------------------------------------------------------------------
bsObject = set(bsObject, 'observedTransitCount', 3);
bsObject = set(bsObject, 'numberPulseWidths', 1);
bsObject = set(bsObject, 'searchTransitThreshold', 7.1);
bsObject = set(bsObject, 'nullTailMaxSigma', 7.0);

[validBsObject dvResultsStruct] = validate_bootstrapObject(bsObject, dvResultsStruct);

assert_equals(validBsObject, false);
assert_equals(dvResultsStruct.targetResultsStruct.planetResultsStruct(1).planetCandidate(1).significance, ...
    0);

%--------------------------------------------------------------------------
% Assign a nullTailMaxSigma = searchTransitThreshold
%--------------------------------------------------------------------------
bsObject = set(bsObject, 'observedTransitCount', 3);
bsObject = set(bsObject, 'numberPulseWidths', 1);
bsObject = set(bsObject, 'searchTransitThreshold', 7.1);
bsObject = set(bsObject, 'nullTailMaxSigma', 7.1);

% Call the bootstrapObject validator, check for the correct warning in alerts
[validBsObject dvResultsStruct] = validate_bootstrapObject(bsObject, dvResultsStruct);

assert_equals(validBsObject, false);

% Check significance = 0, and not -1
assert_equals(dvResultsStruct.targetResultsStruct.planetResultsStruct(1).planetCandidate(1).significance, ...
    0);

%--------------------------------------------------------------------------
% Assign a nullTailMaxSigma that is greater than searchTransitThreshold 
%--------------------------------------------------------------------------
bsObject = set(bsObject, 'observedTransitCount', 3);
bsObject = set(bsObject, 'numberPulseWidths', 1);
bsObject = set(bsObject, 'searchTransitThreshold', 7.1);
bsObject = set(bsObject, 'nullTailMaxSigma', 9.0);

[validBsObject dvResultsStruct] = validate_bootstrapObject(bsObject, dvResultsStruct);

assert_equals(validBsObject, true);

%--------------------------------------------------------------------------
% Check for precedence of warning messages.  observedTransitCount=0 should
% be flagged first
%--------------------------------------------------------------------------
bsObject = set(bsObject, 'observedTransitCount', 0);
bsObject = set(bsObject, 'numberPulseWidths', 0);
bsObject = set(bsObject, 'searchTransitThreshold', 7.1); 
bsObject = set(bsObject, 'nullTailMaxSigma', 7.1);

[validBsObject dvResultsStruct] = validate_bootstrapObject(bsObject, dvResultsStruct);

assert_equals(validBsObject, false);

expectedMessage= 'Observed transit count information not available, will not proceed with bootstrap';
actualMessage = dvResultsStruct.alerts(end).message;
mlunit_assert(~isempty(strfind(actualMessage, expectedMessage)), ...
    message(expectedMessage, actualMessage));

%--------------------------------------------------------------------------
% Check for precedence of warning messages.  Invalid single event statistics time series should
% be flagged first
%--------------------------------------------------------------------------
bsObject = set(bsObject, 'observedTransitCount', 3);
bsObject = set(bsObject, 'numberPulseWidths', 0);
bsObject = set(bsObject, 'searchTransitThreshold', 7.1); 
bsObject = set(bsObject, 'nullTailMaxSigma', 7.1);

[validBsObject dvResultsStruct] = validate_bootstrapObject(bsObject, dvResultsStruct);

assert_equals(validBsObject, false);

expectedMessage= 'Invalid single event statistics time series';
actualMessage = dvResultsStruct.alerts(end).message;
mlunit_assert(~isempty(strfind(actualMessage, expectedMessage)), ...
    message(expectedMessage, actualMessage));

%--------------------------------------------------------------------------
% Check for greater than 20 observed transit counts. 
% Bootstrap is limited to factorial 20
%--------------------------------------------------------------------------
bsObject = set(bsObject, 'observedTransitCount', 21);
bsObject = set(bsObject, 'numberPulseWidths', 3);
bsObject = set(bsObject, 'searchTransitThreshold', 7.1); 
bsObject = set(bsObject, 'nullTailMaxSigma', 12.0);

% Call the bootstrapObject validator, check for the correct warning in alerts
[validBsObject dvResultsStruct] = validate_bootstrapObject(bsObject, dvResultsStruct);

assert_equals(validBsObject, false);

expectedMessage= 'More than 20 observed transits.  Max factorial allowed in bootstrap is 20';
actualMessage = dvResultsStruct.alerts(end).message;
mlunit_assert(~isempty(strfind(actualMessage, expectedMessage)), ...
    message(actualMessage, expectedMessage));

rmpath(testMetaDataRoot);

end

function message = message(expected, actual)
message = sprintf('Expected alert "%s" but was "%s"', expected, actual);
end
