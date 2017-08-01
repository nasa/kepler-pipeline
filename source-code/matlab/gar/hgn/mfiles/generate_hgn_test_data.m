function [hgnDataStruct] = generate_hgn_test_data()
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% [hgnDataStruct] = generate_hgn_test_data()
%
% Function to generate test data for Huffman histogram generation with HGN.
% Output is hgn data structure. This is also saved to HgnInputs.mat file.
% Pixel values and requantization table are obtained from ETEM results for
% the given 'run'. The number of cadences per pixel for test data generation
% is specified by 'nCadences'. If this exceeds the maximum number of cadences
% for which data are available, then the number of desired cadences will be
% reset to the maximum available.
%
% Results of histogram generation are computed with hgn_matlab_controller
% and saved to HgnResults.mat file for comparison test of stored and
% generated results.
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


% Define basic parameters.
run = '100300';
nCadences = 7 * 48;  % One week
baselineIntervals = [4 12 24 48]';

% Define constants, (conditional) path and file names.
BYTES_PER_FLOAT32 = 4;

if ispc
    path = '\path\to\matlab\gar\hgn';
else
    path = '/path/to/matlab/gar/hgn';
end

matFileName = 'HgnInputs.mat';
binFileName = 'HgnInputs-0.bin';
resultsFileName = 'HgnResults.mat';

% Define requantization table as global to eliminate warning messages for
% quanttbl(1 : end-1) and quanttbl(2 : end)
global quanttbl;

% Save the current directory.
origDir = pwd;

% Define basic fields in input structure.
hgnModuleParameters.baselineIntervals = baselineIntervals;
hgnDataStruct.hgnModuleParameters = hgnModuleParameters;

hgnDataStruct.firstMatlabInvocation = true;
hgnDataStruct.debugFlag = 0;

% Switch to the hgn test directory.
testDir = path;
cd(testDir);

% Get module and output numbers from ETEM run parameters file. Also get
% start and end times.
runString = ['run' run];
etemRunParametersFilename = ['run_params_' runString '.mat'];
load(etemRunParametersFilename);
hgnDataStruct.ccdModule = run_params.module_number;
hgnDataStruct.ccdOutput = run_params.output_number;
startMjd = datestr2mjd([run_params.run_start_date ' 00:00:00']);

% Get number of pixels per cadence from ETEM bad pixel file.
badPixelFilename = ['bad_pixel_' runString '.mat'];
load(badPixelFilename, 'kstarpix', 'kbackpix2', 'k_masked_smear', ...
    'k_virtual_smear', 'k_leading_black');
nStarPixels = length(kstarpix);
nBackgroundPixels = length(kbackpix2);
nMaskedSmearPixels = length(k_masked_smear);
nVirtualSmearPixels = length(k_virtual_smear);
nLeadingBlackPixels = length(k_leading_black);
nPixelsPerCadence = nStarPixels + nBackgroundPixels + nMaskedSmearPixels + ...
    nVirtualSmearPixels + nLeadingBlackPixels;
    
% It is necessary to cast the quanttbl values to single precision for ETEM data
% because the pixel values are stored in single precision, and then round
% to the nearest integer because both requantization table and pixel values
% should be integers.
quantizationTableFilename = ['quantize_' runString '.mat'];
load(quantizationTableFilename);
requantEntries = single((quanttbl(1 : end-1) + quanttbl(2 : end)) / 2);
requantTable.requantEntries = double(round(requantEntries));
requantTable.externalId = 1;
requantTable.startMjd = startMjd;
requantTable.meanBlackEntries = 1;
hgnDataStruct.requantTable = requantTable;

% Get the total number of cadences for which data are available. If the
% desire number of cadences is less than the total number, then adjust it.
longCadenceQuantFilename = ['long_cadence_quant_' runString '.dat'];
fidLongCadenceQuant = fopen(longCadenceQuantFilename, 'r', 'ieee-le');
fseek(fidLongCadenceQuant, 0, 'eof');
nTotalBytes = ftell(fidLongCadenceQuant);
frewind(fidLongCadenceQuant);
nTotalCadences = floor((nTotalBytes / BYTES_PER_FLOAT32) / nPixelsPerCadence);

if nCadences > nTotalCadences
    nCadences = nTotalCadences;
end

% Load the fcConstants file and add it to the hgn data structure.
load('fcConstants.mat');
hgnDataStruct.fcConstants = fcConstants;

% Fill the array of cadence pixels structures. The pixel values must be rounded to
% the nearest integers.
hgnDataStruct.cadencePixels = repmat(struct( ...
    'cadence', [], ...
    'pixelValues', [], ...
    'gapIndicators', [] ), [1, nCadences]);

for i = 1 : nCadences
    pixelValues = fread(fidLongCadenceQuant, [nPixelsPerCadence, 1], 'float32');
    hgnDataStruct.cadencePixels(i).cadence = i;
    hgnDataStruct.cadencePixels(i).pixelValues = double(round(pixelValues));
    hgnDataStruct.cadencePixels(i).gapIndicators = repmat(false, [nPixelsPerCadence, 1]);
end

% Set the invocation start and end cadences.
hgnDataStruct.invocationCadenceStart = hgnDataStruct.cadencePixels(1).cadence;
hgnDataStruct.invocationCadenceEnd = hgnDataStruct.cadencePixels(nCadences).cadence;

% Save the data structure to the hgn inputs .mat file.
save(matFileName, 'hgnDataStruct');

% Write the data structure to a bin file.
write_HgnInputs(binFileName, hgnDataStruct);

% Generate results structure and save to hgn results .mat file.
[hgnResultsStruct] = hgn_matlab_controller(hgnDataStruct);
save(resultsFileName, 'hgnResultsStruct');

% Switch back to the original working directory.
cd(origDir);

% Return.
return
    