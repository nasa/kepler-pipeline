function [self] = test_hgn_multiple_invocations(self)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% [self] = test_hgn_multiple_invocations(self)
%
% This test validates that the hgn state is properly maintained from one
% invocation to the next. Huffman histograms are first computed from
% Gaussian pixel values for 100 cadences, and the compared against those
% computed for the same number of cadences across three hgn invocations.
%
%  Example
%  =======
%  Use a test runner to run the test method:
%      run(text_test_runner, testHgnDataClass('test_hgn_multiple_invocations'));
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

% Load fcConstants file.
fcFileName = fullfile(path, 'fcConstants.mat');
load(fcFileName);

% Define basic parameters. The baseline intervals of interest are equal
% to 5, 16, 28 and 46 cadences respectively.
nCadences = 100;
nCadences1 = 40;
nCadences2 = 35;
nCadences3 = 25;
nPixelsPerCadence = 10000;
baselineIntervals = [5 16 28 46]';
sigmaData = 2^13.5;  % Wide range with little clipping

% Define constants and file names.
requantTableLength = fcConstants.REQUANT_TABLE_LENGTH;
nRequantBits = ceil(log2(requantTableLength));
zeroOffsetData = 2^(nRequantBits - 1);

hgnStateFileName = 'hgn_state.mat';

% Initialize variables, vectors, and arrays. Set the
% requantization table such that the output is equal to the input.
indxRequantTable = (0 : requantTableLength - 1)';
requantEntries = indxRequantTable;

% Define basic fields in input structure.
hgnModuleParameters.baselineIntervals = baselineIntervals;

requantTable.externalId = 1;
requantTable.startMjd = 60000;
requantTable.requantEntries = requantEntries;
requantTable.meanBlackEntries = 1;

hgnDataStruct.hgnModuleParameters = hgnModuleParameters;
hgnDataStruct.fcConstants = fcConstants;
hgnDataStruct.requantTable = requantTable;
hgnDataStruct.ccdModule = 2;
hgnDataStruct.ccdOutput = 1;
hgnDataStruct.firstMatlabInvocation = true;
hgnDataStruct.debugFlag = 0;

% Seed the random number generator so that the values are consistent from
% test to test.
randn('state', 0);

% Fill the array of cadence pixels structures.
hgnDataStruct.cadencePixels = repmat(struct( ...
    'cadence', [], ...
    'pixelValues', [], ...
    'gapIndicators', [] ), [1, nCadences]);

for i = 1 : nCadences
    hgnDataStruct.cadencePixels(i).cadence = i;
    r = max(round(sigmaData * randn([nPixelsPerCadence, 1]) + zeroOffsetData), 0); 
    hgnDataStruct.cadencePixels(i).pixelValues = min(r, requantTableLength - 1);
    hgnDataStruct.cadencePixels(i).gapIndicators = false([nPixelsPerCadence, 1]);
end

% Set the invocation start and end cadences.
hgnDataStruct.invocationCadenceStart = hgnDataStruct.cadencePixels(1).cadence;
hgnDataStruct.invocationCadenceEnd = hgnDataStruct.cadencePixels(nCadences).cadence;

% Generate results structure.
[hgnResultsStruct] = hgn_matlab_controller(hgnDataStruct);


%--------------------------------------------------------------------------
% Now recompute the results from three consecutive invocations.
% Invocation #1. The random number generator seed must first be reset.
%--------------------------------------------------------------------------
randn('state', 0);

hgnDataStruct.cadencePixels = repmat(struct( ...
    'cadence', [], ...
    'pixelValues', [], ...
    'gapIndicators', [] ), [1, nCadences1]);

cadence = 0;
for i = 1 : nCadences1
    cadence = cadence + 1;
    hgnDataStruct.cadencePixels(i).cadence = cadence;
    r = max(round(sigmaData * randn([nPixelsPerCadence, 1]) + zeroOffsetData), 0); 
    hgnDataStruct.cadencePixels(i).pixelValues = min(r, requantTableLength - 1);
    hgnDataStruct.cadencePixels(i).gapIndicators = false([nPixelsPerCadence, 1]);
end

hgnDataStruct.invocationCadenceStart = hgnDataStruct.cadencePixels(1).cadence;
hgnDataStruct.invocationCadenceEnd = hgnDataStruct.cadencePixels(nCadences1).cadence;

[testHgnResultsStruct] = hgn_matlab_controller(hgnDataStruct);
clear testHgnResultsStruct;

% Invocation #2. The first matlab invocation flag is now false.
hgnDataStruct.firstMatlabInvocation = false;

hgnDataStruct.cadencePixels = repmat(struct( ...
    'cadence', [], ...
    'pixelValues', [], ...
    'gapIndicators', [] ), [1, nCadences2]);

for i = 1 : nCadences2
    cadence = cadence + 1;
    hgnDataStruct.cadencePixels(i).cadence = cadence;
    r = max(round(sigmaData * randn([nPixelsPerCadence, 1]) + zeroOffsetData), 0); 
    hgnDataStruct.cadencePixels(i).pixelValues = min(r, requantTableLength - 1);
    hgnDataStruct.cadencePixels(i).gapIndicators = false([nPixelsPerCadence, 1]);
end

hgnDataStruct.invocationCadenceStart = hgnDataStruct.cadencePixels(1).cadence;
hgnDataStruct.invocationCadenceEnd = hgnDataStruct.cadencePixels(nCadences2).cadence;

[testHgnResultsStruct] = hgn_matlab_controller(hgnDataStruct);
clear testHgnResultsStruct;

% Invocation #3. Delete hgn state file after this invocation.
hgnDataStruct.cadencePixels = repmat(struct( ...
    'cadence', [], ...
    'pixelValues', [], ...
    'gapIndicators', [] ), [1, nCadences3]);

for i = 1 : nCadences3
    cadence = cadence + 1;
    hgnDataStruct.cadencePixels(i).cadence = cadence;
    r = max(round(sigmaData * randn([nPixelsPerCadence, 1]) + zeroOffsetData), 0); 
    hgnDataStruct.cadencePixels(i).pixelValues = min(r, requantTableLength - 1);
    hgnDataStruct.cadencePixels(i).gapIndicators = false([nPixelsPerCadence, 1]);
end

hgnDataStruct.invocationCadenceStart = hgnDataStruct.cadencePixels(1).cadence;
hgnDataStruct.invocationCadenceEnd = hgnDataStruct.cadencePixels(nCadences3).cadence;

[testHgnResultsStruct] = hgn_matlab_controller(hgnDataStruct);
delete(hgnStateFileName);

% Compare the results. First remove the invocation cadence start field from
% the results structures because they will not otherwise match.
[hgnResultsStruct] = rmfield(hgnResultsStruct, 'invocationCadenceStart');
[testHgnResultsStruct] = rmfield(testHgnResultsStruct, 'invocationCadenceStart');
messageOut = 'Multiple invocations test failed - results from one and multiple invocations are not identical!';
assert_equals(testHgnResultsStruct, hgnResultsStruct, messageOut);

% Return.
return
    