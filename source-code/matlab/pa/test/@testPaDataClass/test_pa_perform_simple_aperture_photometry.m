function [self] = test_pa_perform_simple_aperture_photometry(self)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% [self] = test_pa_perform_simple_aperture_photometry(self)
%
% This test generates target pixel time series for randomly located targets
% based on a 2D-gaussian PRF. The amplitudes are also randomly determined.
% Additive noise is included in the target pixels, and simple aperture
% photometry is invoked. Chi-square and z-tests on the flux values are
% performed to validate the SAP process. Also perform simple gap test to
% verify that gaps are inserted in flux time series for a given cadence if
% at least one pixel is missing in the optimal aperture.
%
%  Example
%  =======
%  Use a test runner to run the test method:
%      run(text_test_runner, ...
%          testPaDataClass('test_pa_perform_simple_aperture_photometry'));
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
nTargets = 100;

nCadences = 200;

confidenceLevel = 0.95;

unitFlux = 10e6;
nominalBackground = 250e3;

fwhmPixels = 2.0; 

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

oapAncillaryEngineeringConfigurationStruct.mnemonics = [];
ancillaryPipelineConfigurationStruct.mnemonics = [];
ancillaryAttitudeConfigurationStruct.mnemonics = [];
backgroundConfigurationStruct.aicOrderSelectionEnabled = false;
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
paDataStruct.backgroundDataStruct = [];
paDataStruct.attitudeSolutionStruct = [];
paDataStruct.prfModel = prfModel;
paDataStruct.backgroundPolyStruct = [];
paDataStruct.motionPolyStruct = [];
paDataStruct.paFileStruct = paFileStruct;

% Generate random target locations. All targets must lie within the visible
% region of the CCD.
referenceRows = 23 + fix(1020 * rand([nTargets, 1]));
referenceColumns = 15 + fix(1096 * rand([nTargets, 1]));

[targetRows, targetColumns, targetValues, targetFlux] = ...
    define_targets(referenceRows, referenceColumns, fwhmPixels);

targetValues = targetValues * unitFlux;
targetFlux = targetFlux * unitFlux;

% Populate the target star data structure. There are twenty-five pixels per
% target for this test.
targetStarDataStruct = repmat(struct( ...
    'keplerId', 0, ...
    'labels', '', ...
    'raHours', 12.3, ...
    'decDegrees', 45, ...
    'keplerMag', 12, ...
    'fluxFractionInAperture', 1.0, ...
    'referenceRow', [], ...
    'referenceColumn', [], ...
    'pixelDataStruct', []), [1, nTargets]);

referenceRowCellArray = num2cell(referenceRows);
[targetStarDataStruct(1 : nTargets).referenceRow] = ...
    referenceRowCellArray{:};
referenceColumnCellArray = num2cell(referenceColumns);
[targetStarDataStruct(1 : nTargets).referenceColumn] = ...
    referenceColumnCellArray{:};

targetUncertainties = sqrt(targetValues + nominalBackground);
values = repmat(targetValues', [nCadences, 1]) + ...
    repmat(targetUncertainties', [nCadences, 1]) .* randn([nCadences, 25 * nTargets]);

index = 1;

for i = 1 : nTargets
    
    gapIndicators = false([nCadences, 1]);
    
    pixelDataStruct = repmat(struct( ...
        'ccdRow', [], ...
        'ccdColumn', [], ...
        'isInOptimalAperture', true, ...
        'values', [], ...
        'uncertainties', [], ...
        'gapIndicators', gapIndicators), [1, 25]);
    
    targetRowCellArray = num2cell(targetRows(index : index+24));
    [pixelDataStruct(1 : 25).ccdRow] = targetRowCellArray{:};
    targetColumnCellArray = num2cell(targetColumns(index : index+24));
    [pixelDataStruct(1 : 25).ccdColumn] = targetColumnCellArray{:};

    valuesCellArray = num2cell(values( : , index:index+24), 1);
    [pixelDataStruct(1 : 25).values] = valuesCellArray{:};
    uncertaintiesCellArray = num2cell(repmat(targetUncertainties(index:index+24)', [nCadences, 1]), 1);
    [pixelDataStruct(1 : 25).uncertainties] = uncertaintiesCellArray{:};
    
    targetStarDataStruct(i).pixelDataStruct = pixelDataStruct;
    
    index = index + 25;
    
end

clear values

paDataStruct.targetStarDataStruct = targetStarDataStruct;

% Instantiate a PA data object.
[paDataObject] = paDataClass(paDataStruct);

% Initialize the PA results structure.
[paResultsStruct] = initialize_pa_output_structure(paDataObject);

% Perform SAP.
[paResultsStruct] = ...
    perform_simple_aperture_photometry(paDataObject, paResultsStruct);

% Get the flux time series.
targetStarResultsStruct = paResultsStruct.targetStarResultsStruct;
fluxTimeSeriesStruct = [targetStarResultsStruct.fluxTimeSeries];
fluxValues = [fluxTimeSeriesStruct.values];
fluxUncertainties = [fluxTimeSeriesStruct.uncertainties];

% Compute the theoretical variances for the flux time series.
Cflux = sum(reshape(targetUncertainties, 25, nTargets) .^ 2)';

% Determine confidence level per test.
confidenceLevelPerTest = confidenceLevel ^ (1 / nTargets);

% Compare results for the mean and standard deviations of flux for each
% target.
disp(' ');
disp(['Number of targets = ', num2str(nTargets)]);
disp(['Confidence level = ', num2str(confidenceLevel), ...
    '; Confidence level per test = ', num2str(confidenceLevelPerTest)]);
disp(' ');

disp('Performing chi-square tests to validate variance in target flux.');
messageOut = sprintf( ...
    'SAP; variance in target flux is not sufficiently close to theoretical variance');
normalizedValues = (fluxValues - repmat(targetFlux', [nCadences, 1])) ...
    ./ repmat(sqrt(Cflux'), [nCadences, 1]);
[hv, pv] = vartest(normalizedValues, 1, 1 - confidenceLevelPerTest);                       %#ok<NASGU>
assert_equals(hv, zeros(size(hv)), messageOut);

disp('Performing z-tests to validate mean in target flux.');
messageOut = sprintf( ...
    'SAP failed; mean flux is not sufficiently close to target flux');
[hz, pz] = ztest(normalizedValues, 0, 1, 1 - confidenceLevelPerTest);                      %#ok<NASGU>
assert_equals(hz, zeros(size(hz)), messageOut);

% Do simple gap test to validate that flux values are not computed for
% a given cadence when at least one pixel is missing in the optimal
% aperture.
expectedGapIndicators = false([nCadences, nTargets]);

for i = 1 : nTargets
    
    nGaps = fix(gapFraction * nCadences);
    gapPixels = 1 + fix(25 * rand([nGaps, 1]));
    gapCadences = 1 + fix(nCadences * rand([nGaps, 1]));
    
    pixelDataStruct = targetStarDataStruct(i).pixelDataStruct;
    values = [pixelDataStruct.values];
    uncertainties = [pixelDataStruct.uncertainties];
    gapIndicators = false(size(values));
    
    values(gapCadences, gapPixels) = 0;
    uncertainties(gapCadences, gapPixels) = 0;
    gapIndicators(gapCadences, gapPixels) = true;
    
    valuesCellArray = num2cell(values, 1);
    [pixelDataStruct(1 : 25).values] = valuesCellArray{:};
    uncertaintiesCellArray = num2cell(uncertainties, 1);
    [pixelDataStruct(1 : 25).uncertainties] = uncertaintiesCellArray{:};
    gapIndicatorsCellArray = num2cell(gapIndicators, 1);
    [pixelDataStruct(1 : 25).gapIndicators] = gapIndicatorsCellArray{:};
    
    targetStarDataStruct(i).pixelDataStruct = pixelDataStruct;
    
    expectedGapIndicators(gapCadences, i) = true;
    
end % for

paDataStruct.targetStarDataStruct = targetStarDataStruct;

% Instantiate a PA data object.
[paDataObject] = paDataClass(paDataStruct);

% Initialize the PA results structure.
[paResultsStruct] = initialize_pa_output_structure(paDataObject);

% Perform SAP.
[paResultsStruct] = ...
    perform_simple_aperture_photometry(paDataObject, paResultsStruct);

% Get the gap indicators and compare with the expected result.
targetStarResultsStruct = paResultsStruct.targetStarResultsStruct;
fluxTimeSeries = [targetStarResultsStruct.fluxTimeSeries];
sapGapIndicators = [fluxTimeSeries.gapIndicators];

disp('Performing gap test.');
messageOut = sprintf( ...
    'SAP failed; gaps in flux time series are not correct');
assert_equals(expectedGapIndicators, sapGapIndicators, messageOut);

% Return.
return


function [targetRows, targetColumns, targetValues, targetFlux] = ...
define_targets(referenceRows, referenceColumns, fwhm)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [targetRows, targetColumns, targetValues] = ...
% define_targets(referenceRows, referenceColumns, fwhm)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Place five x five pixel array for each target based on 2D gaussian prf.
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

nTargets = length(referenceRows);
levels = 1 + 49 * rand([nTargets, 1]);

sigma = fwhm / (2 * sqrt(2 * log(2)));

x2 = repmat((-2 : 2), [5, 1]) .^ 2;
y2 = repmat((-2 : 2)', [1, 5]) .^ 2;
p = exp(-0.5 * x2 / sigma^2) .* exp(-0.5 * y2 / sigma^2);

[X, Y] = meshgrid((-2: 2), (-2 : 2));

targetRows = [];
targetColumns = [];
targetValues = [];
targetFlux = zeros([nTargets, 1]);

for i = 1 : nTargets
    r = referenceRows(i);
    c = referenceColumns(i);
    l = levels(i);
    targetRows = [targetRows; r + Y( : )];                                                 %#ok<AGROW>
    targetColumns = [targetColumns; c + X( : )];                                           %#ok<AGROW>
    newValues = l * p( : );
    targetValues = [targetValues; newValues];                                              %#ok<AGROW>
    targetFlux(i) = sum(newValues);
end

% Return.
return
    