function [self] = test_pa_fit_motion_polynomials(self)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% [self] = test_pa_fit_motion_polynomials(self)
%
% This test generates row and column centroid pixel time series based on
% specified row and column motion polynomials and additive noise. Low order
% 2D polynomials are then fit to the row and column centroids on a cadence
% by cadence basis. Chi-square and z-tests on the retrieved fit parameters
% are performed to validate the fitting process within a specified
% confidence level. Large errors are introduced into the centroids fraction
% and the tests are repeated. Gaps are then inserted at the specified
% fraction at the target level, and the tests are repeated.
%
%  Example
%  =======
%  Use a test runner to run the test method:
%      run(text_test_runner, ...
%          testPaDataClass('test_pa_fit_motion_polynomials'));
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

% Define basic parameters.
nTargets = 1000;

nCadences = 200;
polyOrder = 3;

nominalRowPoly = [574; -226; -145; -0.28; 1.7; 0.064; 0.020; 0.050; -0.24; 0.74];
nominalColPoly = [528; 126; -260; -0.71; -0.93; -0.024; 0.011; -0.088; 0.14; -0.073];

centroidSigma = 0.25;

confidenceLevel = 0.95;

outlierFraction = 0.01;
outlierSigma = 2.0;

gapFraction = 0.25;

% Define basic fields in PA input structure.
paStateFileName = 'pa_state.mat';
paFileStruct.paStateFileName = paStateFileName;

cadenceTimes.startTimestamps = 55555 + (0 : nCadences - 1)' * 0.5 / 24;
cadenceTimes.midTimestamps = cadenceTimes.startTimestamps + 0.25 / 24;
cadenceTimes.endTimestamps = cadenceTimes.midTimestamps + 0.25 / 24;
cadenceTimes.gapIndicators = false([nCadences, 1]);
cadenceTimes.requantEnabled = false([nCadences, 1]);
cadenceTimes.cadenceNumbers = (0 : nCadences - 1)';

paConfigurationStruct.debugLevel = 0;
paConfigurationStruct.cosmicRayCleaningEnabled = true;
paConfigurationStruct.targetPrfCentroidingEnabled = false;
paConfigurationStruct.ppaTargetPrfCentroidingEnabled = true;
paConfigurationStruct.falseCrRejectionRate = 0.0001;
paConfigurationStruct.oapEnabled = false;
paConfigurationStruct.brightRobustThreshold = 0.05;
paConfigurationStruct.minimumBrightTargets = 10;

pouConfigurationStruct.pouEnabled = false;
pouConfigurationStruct.compressionEnabled = true;
pouConfigurationStruct.pixelChunkSize = 2500;
pouConfigurationStruct.cadenceChunkSize = 240;
pouConfigurationStruct.interpDecimation = 24;
pouConfigurationStruct.interpMethod = 'linear';

motionConfigurationStruct.aicOrderSelectionEnabled = false;
motionConfigurationStruct.fitMaxOrder = 8;
motionConfigurationStruct.rowFitOrder = polyOrder;
motionConfigurationStruct.columnFitOrder = polyOrder;
motionConfigurationStruct.fitMinPoints = 200;

oapAncillaryEngineeringConfigurationStruct.mnemonics = [];
ancillaryPipelineConfigurationStruct.mnemonics = [];
ancillaryAttitudeConfigurationStruct.mnemonics = [];
backgroundConfigurationStruct.aicOrderSelectionEnabled = false;
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
paDataStruct.backgroundDataStruct = [];
paDataStruct.targetStarDataStruct = [];
paDataStruct.attitudeSolutionStruct = [];
paDataStruct.prfModel = prfModel;
paDataStruct.backgroundPolyStruct = [];
paDataStruct.motionPolyStruct = [];
paDataStruct.paFileStruct = paFileStruct;

% Generate the random targets.
targetRa = 295.25 + 1.5 * rand([nTargets, 1]);
targetDec = 50.1 + 1.1 * rand([nTargets, 1]);

% Set up dummy motion polynomial fits to get motion coefficient structs
% with the correct x,y origins and scale factors. Assign the nominal
% row and column polynomials.
rowCoeffStruct = robust_polyfit2d(targetRa, targetDec, ...
    nominalRowPoly(1) * ones([nTargets, 1]), ones([nTargets, 1]), ...
    polyOrder);
rowCoeffStruct.coeffs = nominalRowPoly;

colCoeffStruct = robust_polyfit2d(targetRa, targetDec, ...
    nominalColPoly(1) * ones([nTargets, 1]), ones([nTargets, 1]), ...
    polyOrder);
colCoeffStruct.coeffs = nominalColPoly;

% Fill the PA target star results struct array.
uncertainties = centroidSigma * ones([nCadences, 1]);
gapIndicators = false([nCadences, 1]);

paTargetStarResultsStruct = repmat(struct( ...
    'keplerId', 0, ...
    'raHours', 0, ...
    'decDegrees', 0, ...
    'referenceRow', 0, ...
    'referenceColumn', 0, ...
    'fluxTimeSeries', [], ...
    'centroidRowTimeSeries', [], ...
    'centroidColumnTimeSeries', [] ), [1, nTargets]);

raHoursCellArray = num2cell(targetRa / 15);
[paTargetStarResultsStruct(1 : nTargets).raHours] = raHoursCellArray{:};
decDegreesCellArray = num2cell(targetDec);
[paTargetStarResultsStruct(1 : nTargets).decDegrees] = decDegreesCellArray{:};

[rowCentroidValues, zu, Arow] = weighted_polyval2d(targetRa, targetDec, ...
    rowCoeffStruct);
values = repmat(rowCentroidValues', [nCadences, 1]) + ...
    centroidSigma * randn([nCadences, nTargets]);

for i = 1 : nTargets
    paTargetStarResultsStruct(i).centroidRowTimeSeries.values = ...
        values( : , i);
    paTargetStarResultsStruct(i).centroidRowTimeSeries.uncertainties = ...
        uncertainties;
    paTargetStarResultsStruct(i).centroidRowTimeSeries.gapIndicators = ...
        gapIndicators;
end

clear values

[colCentroidValues, zu, Acol] = weighted_polyval2d(targetRa, targetDec, ...
    colCoeffStruct);
values = repmat(colCentroidValues', [nCadences, 1]) + ...
    centroidSigma * randn([nCadences, nTargets]);

for i = 1 : nTargets
    paTargetStarResultsStruct(i).centroidColumnTimeSeries.values = ...
        values( : , i);
    paTargetStarResultsStruct(i).centroidColumnTimeSeries.uncertainties = ...
        uncertainties;
    paTargetStarResultsStruct(i).centroidColumnTimeSeries.gapIndicators = ...
        gapIndicators;
end

clear values

% Save the PA target star results structure to the state file.
save(paStateFileName, 'paTargetStarResultsStruct');

% Instantiate a PA data object and initialize an output structure.
[paDataObject] = paDataClass(paDataStruct);
[paResultsStruct] = initialize_pa_output_structure(paDataObject);

% Fit the motion polynomials.
[paResultsStruct, motionPolyStruct] = ...
    fit_motion_polynomials(paDataObject, paResultsStruct);

% Extract the motion polynomials.
rowCoeffStruct = [motionPolyStruct.rowPoly];
rowPolyValues = [rowCoeffStruct.coeffs]';

colCoeffStruct = [motionPolyStruct.colPoly];
colPolyValues = [colCoeffStruct.coeffs]';

% Compute the theoretical covariance matrices for the fit parameters.
Ccentroids = repmat(centroidSigma ^ 2, [nTargets, 1]);

pinvArow = pinv(Arow);
CrowParams = scalerow(Ccentroids, pinvArow) * pinvArow';

pinvAcol = pinv(Acol);
CcolParams = scalerow(Ccentroids, pinvAcol) * pinvAcol';

% Determine confidence level per test. FOR NOW ASSUME THAT TESTS ON ALL FIT
% PARAMETERS ARE INDEPENDENT. THIS ASSUME IS NOT REALLY VALID.
nParams = size(CrowParams, 1) + size(CcolParams, 1);
confidenceLevelPerTest = confidenceLevel ^ (1 / nParams);

% Compare results for the mean and standard deviations of all polynomial
% coefficients.
disp(' ');
disp(['Number of motion polynomial parameters (row + column) = ', num2str(nParams)]);
disp(['Confidence level = ', num2str(confidenceLevel), ...
    '; Confidence level per test = ', num2str(confidenceLevelPerTest)]);
disp(' ');

disp('Performing chi-square tests to validate variance in motion polynomials.');
messageOut = sprintf( ...
    'Row motion fit failed; variance in fit parameters is not sufficiently close to theoretical variance');
normalizedRowValues = (rowPolyValues - repmat(nominalRowPoly', [nCadences, 1])) ...
    ./ repmat(sqrt(diag(CrowParams)'), [nCadences, 1]);
[hv, pv] = vartest(normalizedRowValues, 1, 1 - confidenceLevelPerTest);                    %#ok<NASGU>
assert_equals(hv, zeros(size(hv)), messageOut);

messageOut = sprintf( ...
    'Column motion fit failed; variance in fit parameters is not sufficiently close to theoretical variance');
normalizedColValues = (colPolyValues - repmat(nominalColPoly', [nCadences, 1])) ...
    ./ repmat(sqrt(diag(CcolParams)'), [nCadences, 1]);
[hv, pv] = vartest(normalizedColValues, 1, 1 - confidenceLevelPerTest);                    %#ok<NASGU>
assert_equals(hv, zeros(size(hv)), messageOut);

disp('Performing z-tests to validate mean in motion polynomials.');
messageOut = sprintf( ...
    'Row motion fit failed; mean in fit parameters is not sufficiently close to nominal values');
[hz, pz] = ztest(normalizedRowValues, 0, 1, 1 - confidenceLevelPerTest);                   %#ok<NASGU>
assert_equals(hz, zeros(size(hz)), messageOut);

messageOut = sprintf( ...
    'Col motion fit failed; mean in fit parameters is not sufficiently close to nominal values');
[hz, pz] = ztest(normalizedColValues, 0, 1, 1 - confidenceLevelPerTest);                   %#ok<NASGU>
assert_equals(hz, zeros(size(hz)), messageOut);

% Add centroid outliers at specified level and repeat the test to determine
% that the robust results with outliers are consistent with theoretical least
% squares results without the outliers.
isOutlier = rand([1, nTargets]) < outlierFraction;

uncertainties = repmat(outlierSigma, [nCadences, 1]);

for i = find(isOutlier)
    
    paTargetStarResultsStruct(i).centroidRowTimeSeries.values = ...
        rowCentroidValues(i) + outlierSigma * randn([nCadences, 1]);
    paTargetStarResultsStruct(i).centroidRowTimeSeries.uncertainties = ...
        uncertainties;
    
    paTargetStarResultsStruct(i).centroidColumnTimeSeries.values = ...
        colCentroidValues(i) + outlierSigma * randn([nCadences, 1]);
    paTargetStarResultsStruct(i).centroidColumnTimeSeries.uncertainties = ...
        uncertainties;
    
    Ccentroids(i) = outlierSigma ^ 2;
    
end

save(paStateFileName, 'paTargetStarResultsStruct');

[paDataObject] = paDataClass(paDataStruct);
[paResultsStruct] = initialize_pa_output_structure(paDataObject);

[paResultsStruct, motionPolyStruct] = ...
    fit_motion_polynomials(paDataObject, paResultsStruct);

rowCoeffStruct = [motionPolyStruct.rowPoly];
rowPolyValues = [rowCoeffStruct.coeffs]';
colCoeffStruct = [motionPolyStruct.colPoly];
colPolyValues = [colCoeffStruct.coeffs]';

pinvArow = pinv(Arow(~isOutlier, : ));
CrowParams = scalerow(Ccentroids(~isOutlier), pinvArow) * pinvArow';
pinvAcol = pinv(Acol(~isOutlier, : ));
CcolParams = scalerow(Ccentroids(~isOutlier), pinvAcol) * pinvAcol';

disp(['Performing chi-square tests to validate variance in motion polynomials(outlier fraction = ', num2str(outlierFraction), ').']);
messageOut = sprintf( ...
    'Row motion fit failed; variance in fit parameters is not sufficiently close to theoretical variance');
normalizedRowValues = (rowPolyValues - repmat(nominalRowPoly', [nCadences, 1])) ...
    ./ repmat(sqrt(diag(CrowParams)'), [nCadences, 1]);
[hv, pv] = vartest(normalizedRowValues, 1, 1 - confidenceLevelPerTest);                    %#ok<NASGU>
assert_equals(hv, zeros(size(hv)), messageOut);

messageOut = sprintf( ...
    'Column motion fit failed; variance in fit parameters is not sufficiently close to theoretical variance');
normalizedColValues = (colPolyValues - repmat(nominalColPoly', [nCadences, 1])) ...
    ./ repmat(sqrt(diag(CcolParams)'), [nCadences, 1]);
[hv, pv] = vartest(normalizedColValues, 1, 1 - confidenceLevelPerTest);                    %#ok<NASGU>
assert_equals(hv, zeros(size(hv)), messageOut);

disp(['Performing z-tests to validate mean in motion polynomials (outlier fraction = ', num2str(outlierFraction), ').']);
messageOut = sprintf( ...
    'Row motion fit failed; mean in fit parameters is not sufficiently close to nominal values');
[hz, pz] = ztest(normalizedRowValues, 0, 1, 1 - confidenceLevelPerTest);                   %#ok<NASGU>
assert_equals(hz, zeros(size(hz)), messageOut);

messageOut = sprintf( ...
    'Col motion fit failed; mean in fit parameters is not sufficiently close to nominal values');
[hz, pz] = ztest(normalizedColValues, 0, 1, 1 - confidenceLevelPerTest);                   %#ok<NASGU>
assert_equals(hz, zeros(size(hz)), messageOut);

% Set gaps (target level) at desired fraction and repeat the test.
isGap = rand([1, nTargets]) < gapFraction;

values = zeros([nCadences, 1]);
uncertainties = ones([nCadences, 1]);
gapIndicators = true([nCadences, 1]);

for i = find(isGap)
    
    paTargetStarResultsStruct(i).centroidRowTimeSeries.values = ...
        values;
    paTargetStarResultsStruct(i).centroidRowTimeSeries.uncertainties = ...
        uncertainties;
    paTargetStarResultsStruct(i).centroidRowTimeSeries.gapIndicators = ...
        gapIndicators;
    
    paTargetStarResultsStruct(i).centroidColumnTimeSeries.values = ...
        values;
    paTargetStarResultsStruct(i).centroidColumnTimeSeries.uncertainties = ...
        uncertainties;
    paTargetStarResultsStruct(i).centroidColumnTimeSeries.gapIndicators = ...
        gapIndicators;
    
end

save(paStateFileName, 'paTargetStarResultsStruct');

[paDataObject] = paDataClass(paDataStruct);
[paResultsStruct] = initialize_pa_output_structure(paDataObject);

[paResultsStruct, motionPolyStruct] = ...
    fit_motion_polynomials(paDataObject, paResultsStruct);
delete(paStateFileName);   

rowCoeffStruct = [motionPolyStruct.rowPoly];
rowPolyValues = [rowCoeffStruct.coeffs]';
colCoeffStruct = [motionPolyStruct.colPoly];
colPolyValues = [colCoeffStruct.coeffs]';

isGap = isGap | isOutlier;
pinvArow = pinv(Arow(~isGap, : ));
CrowParams = scalerow(Ccentroids(~isGap), pinvArow) * pinvArow';
pinvAcol = pinv(Acol(~isGap, : ));
CcolParams = scalerow(Ccentroids(~isGap), pinvAcol) * pinvAcol';

disp(['Performing chi-square tests to validate variance in motion polynomials(gap fraction = ', num2str(gapFraction), ').']);
messageOut = sprintf( ...
    'Row motion fit failed; variance in fit parameters is not sufficiently close to theoretical variance');
normalizedRowValues = (rowPolyValues - repmat(nominalRowPoly', [nCadences, 1])) ...
    ./ repmat(sqrt(diag(CrowParams)'), [nCadences, 1]);
[hv, pv] = vartest(normalizedRowValues, 1, 1 - confidenceLevelPerTest);                    %#ok<NASGU>
assert_equals(hv, zeros(size(hv)), messageOut);

messageOut = sprintf( ...
    'Column motion fit failed; variance in fit parameters is not sufficiently close to theoretical variance');
normalizedColValues = (colPolyValues - repmat(nominalColPoly', [nCadences, 1])) ...
    ./ repmat(sqrt(diag(CcolParams)'), [nCadences, 1]);
[hv, pv] = vartest(normalizedColValues, 1, 1 - confidenceLevelPerTest);                    %#ok<NASGU>
assert_equals(hv, zeros(size(hv)), messageOut);

disp(['Performing z-tests to validate mean in motion polynomials (gap fraction = ', num2str(gapFraction), ').']);
messageOut = sprintf( ...
    'Row motion fit failed; mean in fit parameters is not sufficiently close to nominal values');
[hz, pz] = ztest(normalizedRowValues, 0, 1, 1 - confidenceLevelPerTest);                   %#ok<NASGU>
assert_equals(hz, zeros(size(hz)), messageOut);

messageOut = sprintf( ...
    'Col motion fit failed; mean in fit parameters is not sufficiently close to nominal values');
[hz, pz] = ztest(normalizedColValues, 0, 1, 1 - confidenceLevelPerTest);                   %#ok<NASGU>
assert_equals(hz, zeros(size(hz)), messageOut);

% Return.
return
    