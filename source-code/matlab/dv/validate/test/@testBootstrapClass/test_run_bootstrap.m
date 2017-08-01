%% test_run_bootstrap
%
% function [self] = test_run_bootstrap(self)
%
% Run with:
%   run(text_test_runner, testBootstrapClass('test_run_bootstrap'));
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
function [self] = test_run_bootstrap(self)

fprintf('\nTesting run_bootstrap...\n')

% Add test-meta-data path
initialize_soc_variables;
testMetaDataRoot = fullfile(socTestMetaDataRoot, 'dv', 'unit-tests', 'bootstrap');
addpath(testMetaDataRoot);

% Generate bootstrapInpuStruct and instantiate the bootstrapObject, set
% parameters for statistics and counts
s = generate_bootstrapinputstruct_with_soho_data;

% Replicate 3 single event statistics struct
s.singleEventStatistics(2:3) = s.singleEventStatistics(1);
bsObject = bootstrapClass(s);

bsObject = set(bsObject, 'searchTransitThreshold', 7.1);
bsObject = set(bsObject, 'observedTransitCount', 4);
bsObject = set(bsObject, 'bootstrapAutoSkipCountEnabled', true);
bsObject = set(bsObject, 'bootstrapSkipCount', 0);
bsObject = set(bsObject, 'bootstrapMaxIterations', 1e9);
bsObject = set(bsObject, 'targetNumber', 1);

% Generate bootstrapResultsStruct
bootstrapResultsStruct = create_bootstrapResultsStruct(bsObject);

% Create dummy dvResultsStruct
dvResultsStruct.targetResultsStruct(1).planetResultsStruct(1).planetCandidate.maxMultipleEventSigma = 100;
dvResultsStruct.alerts = [];

% Test that that histogram is called "smooth" when skipCount=0
[bootstrapResultsStruct, dvResultsStruct] = ...
    run_bootstrap(bsObject, bootstrapResultsStruct, dvResultsStruct);
messageOut = 'Expected finalSkipCount = 0';
assert_equals(bootstrapResultsStruct.finalSkipCount, 0, messageOut);

% Generate a non-smooth histogram first, and stops on the second trial of
% skipcount because decrementing it would exceed bootstrapMaxIterations
bsObject = set(bsObject, 'searchTransitThreshold', 6.9);
bsObject = set(bsObject, 'bootstrapSkipCount', 25);
bsObject = set(bsObject, 'bootstrapMaxIterations', 5e7);
[bootstrapResultsStruct, dvResultsStruct] = ...
    run_bootstrap(bsObject, bootstrapResultsStruct, dvResultsStruct);
messageOut = 'Expected finalSkipCount = 13';
mlunit_assert(bootstrapResultsStruct.finalSkipCount == 13, messageOut);

% Test "too many iterations required" and exit of run_bootstrap executes
bsObject = set(bsObject, 'observedTransitCount', 10);
[bootstrapResultsStruct, dvResultsStruct] = ...
    run_bootstrap(bsObject, bootstrapResultsStruct, dvResultsStruct); %#ok<ASGLU>
alertMessage= 'Smallest estimated number of iterations required to bootstrap';
messageOut = 'Wrong type of warning thrown';
mlunit_assert(~isempty(strfind(dvResultsStruct.alerts(end).message, alertMessage)), messageOut);

rmpath(testMetaDataRoot);