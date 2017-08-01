%% test_determine_skip_counts
%
% function [self] = test_determine_skip_counts(self)
%
% Tests that determine_skipcounts executes the designed logic.
% determine_skipcounts is called after validation of bootstrapObject,
% therefore the bootstrapObject used in this test is valid.
%
% Run with:
%   run(text_test_runner, testBootstrapClass('test_determine_skip_counts'));
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
function [self] = test_determine_skip_counts(self)

fprintf('\nTesting determine_skip_counts...\n')

% Add test-meta-data path
initialize_soc_variables;
testMetaDataRoot = fullfile(socTestMetaDataRoot, 'dv', 'unit-tests', 'bootstrap');
addpath(testMetaDataRoot);

% Generate bootstrapInpuStruct and instantiate the bootstrapObject, set
% parameters for statistics and counts
s = generate_bootstrapinputstruct_with_soho_data;
bsObject = bootstrapClass(s);
bsObject = set(bsObject, 'searchTransitThreshold', 7.1);
bsObject = set(bsObject, 'observedTransitCount', 4);
bsObject = set(bsObject, 'bootstrapAutoSkipCountEnabled', true);
bsObject = set(bsObject, 'bootstrapSkipCount', 100);

% Generate bootstrapResultsStruct
bootstrapResultsStruct = create_bootstrapResultsStruct(bsObject); %#ok<NASGU>

[skipCountArray numIterationsArray pulseOrder] = ...
    determine_skipcounts(bsObject); %#ok<NASGU,ASGLU>

messageOut = 'Expected skipCountArray(1) to be 0';
assert_equals(skipCountArray(1), 0, messageOut)

messageOut = 'Expected skipCountArray(2) to be 50';
assert_equals(skipCountArray(2), 50, messageOut)

messageOut = 'Expected skipCountArray(3) to be 100';
assert_equals(skipCountArray(3), 100, messageOut)

% Now test for pulse order.  Replicate single event statistics structure 5
% times using same single event statistics structure.  The order should
% therefore be 1 2 3 4 5
s.singleEventStatistics(2:5) = s.singleEventStatistics(1);
bsObject = bootstrapClass(s);

[skipCountArray numIterationsArray pulseOrder] = ...
    determine_skipcounts(bsObject); %#ok<ASGLU>
messageOut = 'Expected pulse order to be [ 1 2 3 4 5]';
mlunit_assert(all(pulseOrder == [1 2 3 4 5]'), messageOut)

% Now test make s.singleEventSatistics(1) invalid, via gaps, shorten SES for
% singelEventStatistics(2). Order should be [2 3 4 1]
s.singleEventStatistics(1).trialTransitPulseDuration = 1;
s.singleEventStatistics(2).trialTransitPulseDuration = 2;
s.singleEventStatistics(3).trialTransitPulseDuration = 3;
s.singleEventStatistics(4).trialTransitPulseDuration = 4;
s.singleEventStatistics(5).trialTransitPulseDuration = 5;

s.singleEventStatistics(2).correlationTimeSeries.gapIndicators = ~s.singleEventStatistics(2).correlationTimeSeries.gapIndicators;
s.singleEventStatistics(1).correlationTimeSeries.values = s.singleEventStatistics(1).correlationTimeSeries.values(1000:2000);
s.singleEventStatistics(1).correlationTimeSeries.gapIndicators = s.singleEventStatistics(1).correlationTimeSeries.gapIndicators(1000:2000);
s.singleEventStatistics(1).normalizationTimeSeries.values = s.singleEventStatistics(1).normalizationTimeSeries.values(1000:2000);
s.singleEventStatistics(1).normalizationTimeSeries.gapIndicators = s.singleEventStatistics(1).normalizationTimeSeries.gapIndicators(1000:2000);

bsObject = bootstrapClass(s);

[skipCountArray numIterationsArray pulseOrder] = ...
    determine_skipcounts(bsObject); %#ok<ASGLU>

messageOut = 'Expected pulse order to be [2 3 4 1]';
mlunit_assert(all(pulseOrder == [2 3 4 1]'), messageOut)

rmpath(testMetaDataRoot);