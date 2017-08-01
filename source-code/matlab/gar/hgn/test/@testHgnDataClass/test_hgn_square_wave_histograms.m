function [self] = test_hgn_square_wave_histograms(self)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% [self] = test_hgn_square_wave_histograms(self)
%
% This test generates a square wave with a period of 16 cadences, and
% checks the resulting Huffman histograms with baseline intervals equal to
% 8, 16 and 24 cadences. The results for each baseline should be different.
%
%  Example
%  =======
%  Use a test runner to run the test method:
%      run(text_test_runner, testHgnDataClass('test_hgn_square_wave_histograms'));
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
% to 8, 16 and 24 cadences respectively.
period = 16;
nPeriods = 30;
nCadences = 1 + period * nPeriods;
baselineIntervals = [8 16 24]';
squareWaveMagnitude = 2^9;

% Define constants and file names.
requantTableLength = fcConstants.REQUANT_TABLE_LENGTH;
nRequantBits = ceil(log2(requantTableLength));
zeroOffsetData = 2^(nRequantBits - 1);
zeroOffsetResults = 2^nRequantBits;
huffmanTableLength = 2^(nRequantBits + 1) - 1;

hgnStateFileName = 'hgn_state.mat';

% Initialize variables, vectors, and arrays. Set the
% requantization table such that the output is equal to the input.
nIntervals = length(baselineIntervals);
% huffmanHistograms = zeros([huffmanTableLength, nIntervals], 'uint32');
huffmanHistograms = zeros([huffmanTableLength, nIntervals]);
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

% Set up a square wave with the desired pixel values. An additional sample
% is needed at the start to set the initial baseline for each of the
% baseline intervals.
s = ones([1, period / 2]);
s = [s -s];
s = repmat(s, [1, nPeriods]);
squareWave = squareWaveMagnitude*[-1 s] + zeroOffsetData;

% Fill the array of cadence pixels structures.
hgnDataStruct.cadencePixels = repmat(struct( ...
    'cadence', [], ...
    'pixelValues', [], ...
    'gapIndicators', [] ), [1, nCadences]);

for i = 1 : nCadences
    hgnDataStruct.cadencePixels(i).cadence = i;
    hgnDataStruct.cadencePixels(i).pixelValues = squareWave(i);
    hgnDataStruct.cadencePixels(i).gapIndicators = false;
end

% Set the invocation start and end cadences.
hgnDataStruct.invocationCadenceStart = hgnDataStruct.cadencePixels(1).cadence;
hgnDataStruct.invocationCadenceEnd = hgnDataStruct.cadencePixels(nCadences).cadence;

% Generate results structure and delete hgn state file.
[hgnResultsStruct] = hgn_matlab_controller(hgnDataStruct);
delete(hgnStateFileName);

% Set the expected histograms for each baseline. The baseline intervals
% are equal to 8, 16 and 24 cadences.
huffmanHistograms(zeroOffsetResults - 2*squareWaveMagnitude, 1) = (nCadences - 1) / 2;
huffmanHistograms(zeroOffsetResults + 2*squareWaveMagnitude, 1) = (nCadences - 1) / 2;

huffmanHistograms(zeroOffsetResults                        , 2) = (nCadences - 1) / 2;
huffmanHistograms(zeroOffsetResults + 2*squareWaveMagnitude, 2) = (nCadences - 1) / 2;

huffmanHistograms(zeroOffsetResults - 2*squareWaveMagnitude, 3) = (nCadences - 1) / 3;
huffmanHistograms(zeroOffsetResults                        , 3) = (nCadences - 1) / 3;
huffmanHistograms(zeroOffsetResults + 2*squareWaveMagnitude, 3) = (nCadences - 1) / 3;

% Compare results for each baseline interval with expected histograms.
for i = 1 : nIntervals
    messageOut = sprintf( ...
        'Square wave test failed (interval = %d) - generated and expected histograms are not identical!', ...
        hgnResultsStruct.histograms(i).baselineInterval);
    assert_equals(hgnResultsStruct.histograms(i).histogram, ...
        huffmanHistograms( : , i), messageOut);
end

% Return.
return
    