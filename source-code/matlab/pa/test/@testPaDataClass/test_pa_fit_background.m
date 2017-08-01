function [self] = test_pa_fit_background(self)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% [self] = test_pa_fit_background(self)
%
% This test generates background pixel time series based on a specified
% background polynomial and additive noise. A low order 2D polynomial is
% then fit to the background on a cadence by cadence basis. Chi-square and
% z-tests on the retrieved fit parameters are performed to validate the
% fitting process within a specified confidence level. Large outliers
% (e.g. bright targets) are inserted at a specified fraction and the tests
% are repeated. Gaps are then inserted at the specified fraction at the
% background pixel level, and the tests are repeated.
%
%  Example
%  =======
%  Use a test runner to run the test method:
%      run(text_test_runner, ...
%          testPaDataClass('test_pa_fit_background'));
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


% Reset random number generators.
randn('state', 0);
rand('twister', 5489);

% Define basic parameters. Background and outlier flux is in units of
% photoelectrons.
nGridPoints = 65;
nBackPixels = nGridPoints * nGridPoints;

nCadences = 200;
polyOrder = 2;

nominalPoly = [250e3; 9.5; 1.3; 6.1; 5.3; 13.3];
backgroundSigma = 2e3;

confidenceLevel = 0.95;

outlierFraction = 0.01;
outlierFlux = 10e6;

gapFraction = 0.25;

% Define basic fields in PA input structure.
paBackgroundFileName = 'pa_background.mat';
paStateFileName = 'pa_state.mat';
paInputUncertaintiesFileName = 'pa_input_uncertainties.mat';
paFileStruct.paBackgroundFileName = paBackgroundFileName;
paFileStruct.paStateFileName = paStateFileName;
paFileStruct.paInputUncertaintiesFileName = paInputUncertaintiesFileName;

cadenceTimes.startTimestamps = 55555 + (0 : nCadences - 1)' * 0.5 / 24;
cadenceTimes.midTimestamps = cadenceTimes.startTimestamps + 0.25 / 24;
cadenceTimes.endTimestamps = cadenceTimes.midTimestamps + 0.25 / 24;
cadenceTimes.gapIndicators = false([nCadences, 1]);
cadenceTimes.requantEnabled = false([nCadences, 1]);
cadenceTimes.cadenceNumbers = (0 : nCadences - 1)';

paConfigurationStruct.debugLevel = 0;
paConfigurationStruct.cosmicRayCleaningEnabled = false;
paConfigurationStruct.targetPrfCentroidingEnabled = false;
paConfigurationStruct.ppaTargetPrfCentroidingEnabled = true;
paConfigurationStruct.falseCrRejectionRate = 0.0001;
paConfigurationStruct.oapEnabled = false;
paConfigurationStruct.brightRobustThreshold = 0.05;
paConfigurationStruct.minimumBrightTargets = 10;

backgroundConfigurationStruct.aicOrderSelectionEnabled = false;
backgroundConfigurationStruct.fitMaxOrder = 8;
backgroundConfigurationStruct.fitOrder = polyOrder;
backgroundConfigurationStruct.fitMinPoints = 200;

pouConfigurationStruct.pouEnabled = false;
pouConfigurationStruct.compressionEnabled = true;
pouConfigurationStruct.pixelChunkSize = 2500;
pouConfigurationStruct.cadenceChunkSize = 240;
pouConfigurationStruct.interpDecimation = 24;
pouConfigurationStruct.interpMethod = 'linear';

oapAncillaryEngineeringConfigurationStruct.mnemonics = [];
ancillaryPipelineConfigurationStruct.mnemonics = [];
ancillaryAttitudeConfigurationStruct.mnemonics = [];
motionConfigurationStruct.aicOrderSelectionEnabled = false;
encircledEnergyConfigurationStruct.fluxFraction = 0.95;
gapFillConfigurationStruct.madXFactor = 10;

fcConstants.BITS_IN_ADC = 14;
spacecraftConfigMap.entries.mnemonic = [];
prfModel.ccdModule = 4;

paDataStruct.ccdModule = 4;
paDataStruct.ccdOutput = 3;
paDataStruct.cadenceType = 'LONG';
paDataStruct.startCadence = 0;
paDataStruct.endCadence = nCadences - 1;
paDataStruct.firstCall = true;
paDataStruct.lastCall = false;
paDataStruct.fcConstants = fcConstants;
paDataStruct.spacecraftConfigMap = spacecraftConfigMap;
paDataStruct.cadenceTimes = cadenceTimes;
paDataStruct.longCadenceTimes = cadenceTimes;
paDataStruct.paConfigurationStruct = paConfigurationStruct;
paDataStruct.oapAncillaryEngineeringConfigurationStruct = ...
    oapAncillaryEngineeringConfigurationStruct;
paDataStruct.ancillaryPipelineConfigurationStruct = ...
    ancillaryPipelineConfigurationStruct;
paDataStruct.ancillaryAttitudeConfigurationStruct = ...
    ancillaryAttitudeConfigurationStruct;
paDataStruct.backgroundConfigurationStruct = backgroundConfigurationStruct;
paDataStruct.motionConfigurationStruct = motionConfigurationStruct;
paDataStruct.pouConfigurationStruct = pouConfigurationStruct;
paDataStruct.encircledEnergyConfigurationStruct = ...
    encircledEnergyConfigurationStruct;
paDataStruct.gapFillConfigurationStruct = gapFillConfigurationStruct;
paDataStruct.ancillaryEngineeringDataStruct = [];
paDataStruct.ancillaryPipelineDataStruct = [];
paDataStruct.targetStarDataStruct = [];
paDataStruct.attitudeSolutionStruct = [];
paDataStruct.prfModel = prfModel;
paDataStruct.backgroundPolyStruct = [];
paDataStruct.motionPolyStruct = [];
paDataStruct.paFileStruct = paFileStruct;

% Generate the (1-based) background grid.
rowSpacing = 1024 / nGridPoints;
columnSpacing = 1100 / nGridPoints;

gridRows = 21 + round(rowSpacing / 2 + (0 : nGridPoints - 1)' * rowSpacing);
gridColumns = 13 + round(columnSpacing / 2 + (0 : nGridPoints - 1)' * columnSpacing);
[meshRows, meshColumns] = meshgrid(gridRows, gridColumns);

% Set up a dummy background polynomial fit to get a background coefficient
% struct with the correct x,y origins and scale factors. Assign the nominal
% background polynomial.
backgroundCoeffStruct = robust_polyfit2d(meshRows( : ), meshColumns( : ), ...
    nominalPoly(1) * ones([nBackPixels, 1]), ones([nBackPixels, 1]), ...
    polyOrder);

backgroundCoeffStruct.coeffs = nominalPoly;

% Fill the background data struct array.
uncertainties = backgroundSigma * ones([nCadences, 1]);
gapIndicators = false([nCadences, 1]);

backgroundDataStruct = repmat(struct( ...
    'ccdRow', [], ...
    'ccdColumn', [], ...
    'isInOptimalAperture', true, ...
    'values', [], ...
    'uncertainties', uncertainties, ...
    'gapIndicators', gapIndicators ), [1, nBackPixels]);

ccdRowCellArray = num2cell(meshRows( : ));
[backgroundDataStruct(1 : nBackPixels).ccdRow] = ccdRowCellArray{:};
ccdColumnCellArray = num2cell(meshColumns( : ));
[backgroundDataStruct(1 : nBackPixels).ccdColumn] = ccdColumnCellArray{:};

[backgroundValues, zu, Aback] = weighted_polyval2d(meshRows( : ), meshColumns( : ), ...
    backgroundCoeffStruct);
values = repmat(backgroundValues', [nCadences, 1]) + ...
    backgroundSigma * randn([nCadences, nBackPixels]);

for i = 1 : nBackPixels
    backgroundDataStruct(i).values = values( : , i);
end

clear values

paDataStruct.backgroundDataStruct = backgroundDataStruct;

% Instantiate a PA data object and initialize an output structure.
[paDataObject] = paDataClass(paDataStruct);
[paResultsStruct] = initialize_pa_output_structure(paDataObject);

% Fit the background.
backgroundPolyStruct = [];                                                                 %#ok<NASGU>
save(paStateFileName, 'backgroundPolyStruct');

[paResultsStruct, backgroundPolyStruct] = ...
    fit_background(paDataObject, paResultsStruct);

% Extract the background polynomials.
backgroundCoeffStruct = [backgroundPolyStruct.backgroundPoly];
polyValues = [backgroundCoeffStruct.coeffs]';

% Compute the theoretical covariance matrix for the fit parameters.
Cback = repmat(backgroundSigma ^ 2, [nBackPixels, 1]);
pinvAback = pinv(Aback);
Cparams = scalerow(Cback, pinvAback) * pinvAback';

% Determine confidence level per test. FOR NOW ASSUME THAT TESTS ON ALL FIT
% PARAMETERS ARE INDEPENDENT. THIS ASSUME IS NOT REALLY VALID.
nParams = size(Cparams, 1);
confidenceLevelPerTest = confidenceLevel ^ (1 / nParams);

% Compare results for the mean and standard deviations of all polynomial
% coefficients.
disp(' ');
disp(['Number of background polynomial parameters = ', num2str(nParams)]);
disp(['Confidence level = ', num2str(confidenceLevel), ...
    '; Confidence level per test = ', num2str(confidenceLevelPerTest)]);
disp(' ');

disp('Performing chi-square tests to validate variance in fit polynomials.');
messageOut = sprintf( ...
    'Background fit failed; variance in fit parameters is not sufficiently close to theoretical variance');
normalizedValues = (polyValues - repmat(nominalPoly', [nCadences, 1])) ...
    ./ repmat(sqrt(diag(Cparams)'), [nCadences, 1]);
[hv, pv] = vartest(normalizedValues, 1, 1 - confidenceLevelPerTest);                       %#ok<NASGU>
assert_equals(hv, zeros(size(hv)), messageOut);

disp('Performing z-tests to validate mean in fit polynomials.');
messageOut = sprintf( ...
    'Background fit failed; mean in fit parameters is not sufficiently close to nominal values');
[hz, pz] = ztest(normalizedValues, 0, 1, 1 - confidenceLevelPerTest);                      %#ok<NASGU>
assert_equals(hz, zeros(size(hz)), messageOut);

% Add outliers at specified level and repeat the test to determine that the
% robust results with outliers are consistent with theoretical least
% squares results without the outliers.
isOutlier = rand([1, nBackPixels]) < outlierFraction;

for i = find(isOutlier)
    backgroundDataStruct(i).values = ...
        backgroundDataStruct(i).values + outlierFlux;
end

paDataStruct.backgroundDataStruct = backgroundDataStruct;

[paDataObject] = paDataClass(paDataStruct);
[paResultsStruct] = initialize_pa_output_structure(paDataObject);

[paResultsStruct, backgroundPolyStruct] = ...
    fit_background(paDataObject, paResultsStruct);

backgroundCoeffStruct = [backgroundPolyStruct.backgroundPoly];
polyValues = [backgroundCoeffStruct.coeffs]';

pinvAback = pinv(Aback(~isOutlier, : ));
Cparams = scalerow(Cback(~isOutlier), pinvAback) * pinvAback';

disp(['Performing chi-square tests to validate variance in fit polynomials (outlier fraction = ', num2str(outlierFraction), ').']);
messageOut = sprintf( ...
    'Background fit failed; variance in fit parameters is not sufficiently close to theoretical variance');
normalizedValues = (polyValues - repmat(nominalPoly', [nCadences, 1])) ...
    ./ repmat(sqrt(diag(Cparams)'), [nCadences, 1]);
[hv, pv] = vartest(normalizedValues, 1, 1 - confidenceLevelPerTest);                       %#ok<NASGU>
assert_equals(hv, zeros(size(hv)), messageOut);

disp(['Performing z-tests to validate mean in fit polynomials (outlier fraction = ', num2str(outlierFraction), ').']);
messageOut = sprintf( ...
    'Background fit failed; mean in fit parameters is not sufficiently close to nominal values');
[hz, pz] = ztest(normalizedValues, 0, 1, 1 - confidenceLevelPerTest);                      %#ok<NASGU>
assert_equals(hz, zeros(size(hz)), messageOut);

% Set gaps (pixel level) at desired fraction and repeat the test.
isGap = rand([1, nBackPixels]) < gapFraction;

values = zeros([nCadences, 1]);
uncertainties = ones([nCadences, 1]);
gapIndicators = true([nCadences, 1]);

for i = find(isGap)
    backgroundDataStruct(i).values = values;
    backgroundDataStruct(i).uncertainties = uncertainties;
    backgroundDataStruct(i).gapIndicators = gapIndicators;
end

paDataStruct.backgroundDataStruct = backgroundDataStruct;

[paDataObject] = paDataClass(paDataStruct);
[paResultsStruct] = initialize_pa_output_structure(paDataObject);

[paResultsStruct, backgroundPolyStruct] = ...
    fit_background(paDataObject, paResultsStruct);
delete(paStateFileName);
delete(paBackgroundFileName);   

backgroundCoeffStruct = [backgroundPolyStruct.backgroundPoly];
polyValues = [backgroundCoeffStruct.coeffs]';

isGap = isGap | isOutlier;
pinvAback = pinv(Aback(~isGap, : ));
Cparams = scalerow(Cback(~isGap), pinvAback) * pinvAback';

disp(['Performing chi-square tests to validate variance in fit polynomials (gap fraction = ', num2str(gapFraction), ').']);
messageOut = sprintf( ...
    'Background fit failed; variance in fit parameters is not sufficiently close to theoretical variance');
normalizedValues = (polyValues - repmat(nominalPoly', [nCadences, 1])) ...
    ./ repmat(sqrt(diag(Cparams)'), [nCadences, 1]);
[hv, pv] = vartest(normalizedValues, 1, 1 - confidenceLevelPerTest);                       %#ok<NASGU>
assert_equals(hv, zeros(size(hv)), messageOut);

disp(['Performing z-tests to validate mean in fit polynomials (gap fraction = ', num2str(gapFraction), ').']);
messageOut = sprintf( ...
    'Background fit failed; mean in fit parameters is not sufficiently close to nominal values');
[hz, pz] = ztest(normalizedValues, 0, 1, 1 - confidenceLevelPerTest);                      %#ok<NASGU>
assert_equals(hz, zeros(size(hz)), messageOut);

% Return.
return
    