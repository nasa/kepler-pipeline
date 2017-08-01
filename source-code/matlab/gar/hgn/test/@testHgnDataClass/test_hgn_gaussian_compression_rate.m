function [self] = test_hgn_gaussian_compression_rate(self)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% [self] = test_hgn_gaussian_compression_rate(self)
%
% This test generates Gaussian random pixel values, and checks whether the
% compression rate for the resulting Huffman histograms is close to that
% expected from theory. The baseline intervals are set to 5, 16, 28
% and 46 cadences. The results should be independent of baseline interval.
% The tolerance for compression rate vs. theoretical Gaussian entropy is
% currently set to 0.5 bits per pixel.
%
%  Example
%  =======
%  Use a test runner to run the test method:
%      run(text_test_runner, testHgnDataClass('test_hgn_gaussian_compression_rate'));
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
nPixelsPerCadence = 10000;
baselineIntervals = [5 16 28 46]';
sigmaData = 2^13.5;  % wide range with little clipping
tolerance = 0.5;  % bits per pixel

% Define constants and file names.
requantTableLength = fcConstants.REQUANT_TABLE_LENGTH;
nRequantBits = ceil(log2(requantTableLength));
zeroOffsetData = 2^(nRequantBits - 1);

hgnStateFileName = 'hgn_state.mat';

% Initialize variables, vectors, and arrays. Set the
% requantization table such that the output is equal to the input.
nIntervals = length(baselineIntervals);
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

% Generate results structure and delete hgn state file.
[hgnResultsStruct] = hgn_matlab_controller(hgnDataStruct);
delete(hgnStateFileName);

% Compute the entropy for Gaussian pixel values. Note that sigmaResults =
% sigmaData * sqrt(2) because the histograms are constructed from the
% differences between Gaussian pixel values and (independent) Gaussian
% baseline values.
sigmaResults = sigmaData * sqrt(2);
gaussianEntropy = 0.5 * (1 + log2(2 * pi * sigmaResults^2));

% Check that theoretical compression rate for each baseline interval is within
% acceptable tolerance of entropy for Gaussian pixel values.
for i = 1 : nIntervals
    messageOut = sprintf( ...
        'Gaussian test failed (interval = %d) - compression rate is not within tolerance of gaussian entropy!', ...
        hgnResultsStruct.histograms(i).baselineInterval);
    theoreticalCompressionRate = ...
        hgnResultsStruct.histograms(i).theoreticalCompressionRate;
    deviation = abs(theoreticalCompressionRate - gaussianEntropy);
    assert_equals(deviation > tolerance, false, messageOut);
end

% Return.
return
    