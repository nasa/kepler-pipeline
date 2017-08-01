%% test_histogram_smoothness
%
% self = test_histogram_smoothness(self)
%
% This function tests for smoothness of histogram.
% 
% Run with:
%   run(text_test_runner, testBootstrapClass('test_histogram_smoothness'));
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
function self = test_histogram_smoothness(self)

fprintf('\nTesting determine_histogram_smoothness.m...\n')

% Add test-meta-data path
initialize_soc_variables;
testMetaDataRoot = fullfile(socTestMetaDataRoot, 'dv', 'unit-tests', 'bootstrap');
addpath(testMetaDataRoot);

% Generate bootstrapInpuStruct and instantiate the bootstrapObject, set
% parameters for statistics and counts
s = generate_bootstrapinputstruct_with_soho_data;
bsObject = bootstrapClass(s);
bsObject = set(bsObject, 'nullTailMinSigma', 6.0);
bsObject = set(bsObject, 'nullTailMaxSigma', 8.0);
bsObject = set(bsObject, 'searchTransitThreshold', 7.1);

% Generate bootstrapResultsStruct
bootstrapResultsStruct = create_bootstrapResultsStruct(bsObject);
searchTransitThreshold = get(bsObject, 'searchTransitThreshold'); %#ok<NASGU>
bootstrapResultsStruct.statistics = (6:0.1:8)'; % 21 bins, threshold  at index 12

%--------------------------------------------------------------------------
% CASE 1 - histogram is not gaussian shaped because it is: 
% (1) not descending at the tail max 
% (2) histogram max does not occur at the threshold  bin

messageOut = 'case 1: expected histogram to not be ''smooth''';
expectedSmoothness = false;

% Define counts in the histogram
counts = zeros(length(bootstrapResultsStruct.statistics), 1);
counts(1:11) = 0;
counts(12) = 3;
counts(13:end) =[ 9 3 7 9 4 2 7 1 0];
bootstrapResultsStruct.histogramStruct(1).counts = counts;

isHistSmooth = determine_histogram_smoothness(bsObject, bootstrapResultsStruct, 1);
assert_equals(expectedSmoothness, isHistSmooth, messageOut)

%--------------------------------------------------------------------------
% CASE 2 -histogram is not smooth because it is
% (1) descending, but
% (2) counts at the threshold  bin is not max

messageOut = 'case 2: expected histogram to not be ''smooth''';
expectedSmoothness = false;

% Define counts in the histogram
counts = zeros(length(bootstrapResultsStruct.statistics), 1);
counts(1:11) = 0;
counts(12) = 3;
counts(13:end) =[ 9 8 7 6 3 2 1 0 0];
bootstrapResultsStruct.histogramStruct(1).counts = counts;

isHistSmooth = determine_histogram_smoothness(bsObject, bootstrapResultsStruct, 1);
assert_equals(expectedSmoothness, isHistSmooth, messageOut)


%--------------------------------------------------------------------------
% CASE 3 -histogram is not smooth because it is
% (1) not decending
% (2) at threshold , count is at the max

messageOut = 'case 3: expected histogram to not be ''smooth''';
expectedSmoothness = false;

% Define counts in the histogram
counts = zeros(length(bootstrapResultsStruct.statistics), 1);
counts(1:11) = 0;
counts(12) = 10;
counts(13:end) =[ 9 3 7 9 4 2 7 1 0];
bootstrapResultsStruct.histogramStruct(1).counts = counts;

isHistSmooth = determine_histogram_smoothness(bsObject, bootstrapResultsStruct, 1);
assert_equals(expectedSmoothness, isHistSmooth, messageOut)

%--------------------------------------------------------------------------
% CASE 4 -histogram is smooth because
% (1) descending, with some zeros at the tail max
% (2) at threshold , histogram is max

messageOut = 'case 4: expected histogram to be ''smooth''';
expectedSmoothness = true;

% Define counts in the histogram
counts = zeros(length(bootstrapResultsStruct.statistics), 1);
counts(1:9) = 0;
counts(10:11) = [15 12];
counts(12:end)= [ 10 9 8 7 0 5 0 1 0 0];
bootstrapResultsStruct.histogramStruct(1).counts = counts;

isHistSmooth = determine_histogram_smoothness(bsObject, bootstrapResultsStruct, 1);
assert_equals(expectedSmoothness, isHistSmooth, messageOut)
%--------------------------------------------------------------------------
% CASE 5 -histogram is smooth because
% (1) descending, no zeros at the tail max
% (2) at threshold , histogram is max

messageOut = 'case 5: expected histogram to be ''smooth''';
expectedSmoothness = true;

% Define counts in the histogram
counts = zeros(length(bootstrapResultsStruct.statistics), 1);
counts(1:9) = 0;
counts(10:11) = [15 12];
counts(12:end) = [ 10 9 8 7 6 5 4 3 2 1 ];
bootstrapResultsStruct.histogramStruct(1).counts = counts;

isHistSmooth = determine_histogram_smoothness(bsObject, bootstrapResultsStruct, 1);
assert_equals(expectedSmoothness, isHistSmooth, messageOut)

%--------------------------------------------------------------------------
% CASE 6 -histogram is not smooth because histogram counts are all zeros

messageOut = 'case 6: expected histogram to not be ''smooth''';
expectedSmoothness = false;

% Define counts in the histogram
bootstrapResultsStruct.histogramStruct(1).counts = ...
    zeros(length(bootstrapResultsStruct.statistics), 1);

isHistSmooth = determine_histogram_smoothness(bsObject, bootstrapResultsStruct, 1);
assert_equals(expectedSmoothness, isHistSmooth, messageOut)

%--------------------------------------------------------------------------
% CASE 7 -histogram is not smooth because histogram counts did not get
% populated, i.e., empty

messageOut = 'case 7: expected histogram to not be ''smooth''';
expectedSmoothness = false;

% Define counts in the histogram
bootstrapResultsStruct.histogramStruct(1).counts = [];

isHistSmooth = determine_histogram_smoothness(bsObject, bootstrapResultsStruct, 1);
assert_equals(expectedSmoothness, isHistSmooth, messageOut)

rmpath(testMetaDataRoot);

return















