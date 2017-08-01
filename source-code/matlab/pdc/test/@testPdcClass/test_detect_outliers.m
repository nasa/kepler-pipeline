function [self] = test_detect_outliers(self)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% [self] = test_detect_outliers(self)
%
% This test generates time series with and without outliers, and verifies
% the ability of the pdc_detect_outliers function to return the correct outlier
% results. In particular, single cadence outliers must be detected while
% multiple cadence events are not flagged as outliers. These of course may
% be astrophysical in nature, e.g. transit, eclipses, flares.
%
%  Example
%  =======
%  Use a test runner to run the test method:
%      run(text_test_runner, ...
%          testPdcClass('test_detect_outliers'));
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


% Set path.
initialize_soc_variables;
path = [socTestDataRoot, filesep, 'pdc', filesep, 'unit-tests'];

% Define constants.
CADENCES_PER_QUARTER = 93 * 48;
MADS_PER_GAUSSIAN_SIGMA = 1.4826;
DETECTION_TOLERANCE = 0.5;

% Load PDC and gap fill parameters.
pdcModuleParametersFileName = ...
    [path, filesep, 'pdcModuleParameters.mat'];
load(pdcModuleParametersFileName);

gapFillParametersFileName = [path, filesep, 'gapFillParameters.mat'];
load(gapFillParametersFileName);

% Construct a random time series without any outliers and verify that no
% outliers are identified.
randn('state', 0);
randomTimeSeriesValues = randn([CADENCES_PER_QUARTER, 1]);
randomTimeSeriesUncertainties = abs(randn([CADENCES_PER_QUARTER, 1]));
gapIndicators = false([CADENCES_PER_QUARTER, 1]);

targetFluxTimeSeriesIn.values = randomTimeSeriesValues;
targetFluxTimeSeriesIn.uncertainties = randomTimeSeriesUncertainties;
targetFluxTimeSeriesIn.gapIndicators = gapIndicators;

[outlierStruct, targetFluxTimeSeriesOut] = ...
    pdc_detect_outliers(targetFluxTimeSeriesIn, pdcModuleParameters, ...
    gapFillParameters);

% Assert that no harmonics were identified and that harmonics removed time
% series is in fact the original time series.
disp('Outlier detection with purely random time series.');

messageOut = sprintf( ...
    'Length of outliers structure array does not equal number of targets!');
assert_equals(length(outlierStruct), length(targetFluxTimeSeriesIn), messageOut);

messageOut = sprintf( ...
    'Outlier(s) misidentified in purely random time series!');
assert_equals(isempty(outlierStruct.values), true, messageOut);
assert_equals(isempty(outlierStruct.uncertainties), true, messageOut);
assert_equals(isempty(outlierStruct.indices), true, messageOut);

messageOut = sprintf( ...
    'Returned target flux time series when no outliers are present is not identical to the original time series!');
assert_equals(targetFluxTimeSeriesOut, targetFluxTimeSeriesIn, messageOut);

% Add two "outliers", one just above and one just below the detection
% threshold, and verify that only the larger event is detected.
timeSeries = randomTimeSeriesValues(~gapIndicators);
med = median(timeSeries);
leftTimeSeries = timeSeries(timeSeries < med);
leftMedian = median(leftTimeSeries);
leftMad = mad(leftTimeSeries, 1);

outlierThresholdXFactor = pdcModuleParameters.outlierThresholdXFactor;
overThresholdValue = ...
    leftMedian - leftMad * (outlierThresholdXFactor + DETECTION_TOLERANCE) * ...
    MADS_PER_GAUSSIAN_SIGMA;
overThresholdUncertainty = abs(randn(1));
overThresholdIndex = 2000;

underThresholdValue = ...
    leftMedian - leftMad * (outlierThresholdXFactor - DETECTION_TOLERANCE) * ...
    MADS_PER_GAUSSIAN_SIGMA;
underThresholdUncertainty = abs(randn(1));
underThresholdIndex = 1000;

timeSeriesWithOutliersValues = randomTimeSeriesValues;
timeSeriesWithOutliersValues(underThresholdIndex) = underThresholdValue;
timeSeriesWithOutliersValues(overThresholdIndex) = overThresholdValue;

timeSeriesWithOutliersUncertainties = randomTimeSeriesUncertainties;
timeSeriesWithOutliersUncertainties(underThresholdIndex) = underThresholdUncertainty;
timeSeriesWithOutliersUncertainties(overThresholdIndex) = overThresholdUncertainty;

targetFluxTimeSeriesIn.values = timeSeriesWithOutliersValues;
targetFluxTimeSeriesIn.uncertainties = timeSeriesWithOutliersUncertainties;
targetFluxTimeSeriesIn.gapIndicators = gapIndicators;

[outlierStruct, targetFluxTimeSeriesOut] = ...
    pdc_detect_outliers(targetFluxTimeSeriesIn, pdcModuleParameters, ...
    gapFillParameters);

% Assert that the correct outlier was identified.
disp('Outlier detection with values just above and below the detection threshold.');

messageOut = sprintf( ...
    'Length of outliers structure array does not equal number of targets!');
assert_equals(length(outlierStruct), length(targetFluxTimeSeriesIn), messageOut);

messageOut = sprintf( ...
    'Outlier(s) misidentified in time series with values just above and below the detection threshold!');
assert_equals(outlierStruct.values, overThresholdValue, messageOut);
assert_equals(outlierStruct.uncertainties, overThresholdUncertainty, messageOut);
assert_equals(outlierStruct.indices, overThresholdIndex, messageOut);

messageOut = sprintf( ...
    'Returned target flux time series with values just above and below the detection threshold is not correct!');
assert_equals(targetFluxTimeSeriesOut.values(overThresholdIndex), 0, messageOut);
assert_equals(targetFluxTimeSeriesOut.uncertainties(overThresholdIndex), 0, messageOut);
assert_equals(targetFluxTimeSeriesOut.gapIndicators(overThresholdIndex), true, messageOut);
targetFluxTimeSeriesOut.values(overThresholdIndex) = overThresholdValue;
targetFluxTimeSeriesOut.uncertainties(overThresholdIndex) = overThresholdUncertainty;
targetFluxTimeSeriesOut.gapIndicators(overThresholdIndex) = false;
assert_equals(targetFluxTimeSeriesOut, targetFluxTimeSeriesIn, messageOut);

% Negate the time series and repeat the test with outliers just above and
% below the outlier detection threshold.
overThresholdValue = -overThresholdValue;

timeSeriesWithOutliersValues = -timeSeriesWithOutliersValues;

targetFluxTimeSeriesIn.values = timeSeriesWithOutliersValues;

[outlierStruct, targetFluxTimeSeriesOut] = ...
    pdc_detect_outliers(targetFluxTimeSeriesIn, pdcModuleParameters, ...
    gapFillParameters);

% Assert that the correct outlier was identified.
disp('Outlier detection for negated time series with values just above and below the detection threshold.');

messageOut = sprintf( ...
    'Length of outliers structure array does not equal number of targets!');
assert_equals(length(outlierStruct), length(targetFluxTimeSeriesIn), messageOut);

messageOut = sprintf( ...
    'Outlier(s) misidentified in negated time series with values just above and below the detection threshold!');
assert_equals(outlierStruct.values, overThresholdValue, messageOut);
assert_equals(outlierStruct.uncertainties, overThresholdUncertainty, messageOut);
assert_equals(outlierStruct.indices, overThresholdIndex, messageOut);

messageOut = sprintf( ...
    'Returned target flux time series with values just above and below the detection threshold is not correct!');
assert_equals(targetFluxTimeSeriesOut.values(overThresholdIndex), 0, messageOut);
assert_equals(targetFluxTimeSeriesOut.uncertainties(overThresholdIndex), 0, messageOut);
assert_equals(targetFluxTimeSeriesOut.gapIndicators(overThresholdIndex), true, messageOut);
targetFluxTimeSeriesOut.values(overThresholdIndex) = overThresholdValue;
targetFluxTimeSeriesOut.uncertainties(overThresholdIndex) = overThresholdUncertainty;
targetFluxTimeSeriesOut.gapIndicators(overThresholdIndex) = false;
assert_equals(targetFluxTimeSeriesOut, targetFluxTimeSeriesIn, messageOut);

% Add a quadratic trend and repeat the outliers identification test.
quadraticTrend = 20 / CADENCES_PER_QUARTER^2 * ...
    (0 : CADENCES_PER_QUARTER-1)'.^2;
timeSeriesWithOutliersValues = timeSeriesWithOutliersValues + quadraticTrend;

overThresholdValue = timeSeriesWithOutliersValues(overThresholdIndex);

targetFluxTimeSeriesIn.values = timeSeriesWithOutliersValues;

[outlierStruct, targetFluxTimeSeriesOut] = ...
    pdc_detect_outliers(targetFluxTimeSeriesIn, pdcModuleParameters, ...
    gapFillParameters);

% Assert that the correct outlier was identified.
disp('Outlier detection for time series with quadratric trend and values just above and below the detection threshold.');

messageOut = sprintf( ...
    'Length of outliers structure array does not equal number of targets!');
assert_equals(length(outlierStruct), length(targetFluxTimeSeriesIn), messageOut);

messageOut = sprintf( ...
    'Outlier(s) misidentified in time series with quadratic trend and values just above and below the detection threshold!');
assert_equals(outlierStruct.values, overThresholdValue, messageOut);
assert_equals(outlierStruct.uncertainties, overThresholdUncertainty, messageOut);
assert_equals(outlierStruct.indices, overThresholdIndex, messageOut);

messageOut = sprintf( ...
    'Returned target flux time series with quadratic trend and values just above and below the detection threshold is not correct!');
assert_equals(targetFluxTimeSeriesOut.values(overThresholdIndex), 0, messageOut);
assert_equals(targetFluxTimeSeriesOut.uncertainties(overThresholdIndex), 0, messageOut);
assert_equals(targetFluxTimeSeriesOut.gapIndicators(overThresholdIndex), true, messageOut);
targetFluxTimeSeriesOut.values(overThresholdIndex) = overThresholdValue;
targetFluxTimeSeriesOut.uncertainties(overThresholdIndex) = overThresholdUncertainty;
targetFluxTimeSeriesOut.gapIndicators(overThresholdIndex) = false;
assert_equals(targetFluxTimeSeriesOut, targetFluxTimeSeriesIn, messageOut);

% Add a second outlier above the detection threshold near the end of the
% time series.
overThresholdValue2 = 5;
overThresholdUncertainty2 = abs(randn(1));
overThresholdIndex2 = CADENCES_PER_QUARTER - 3;

timeSeriesWithOutliersValues(overThresholdIndex2) = overThresholdValue2;
timeSeriesWithOutliersUncertainties(overThresholdIndex2) = ...
    overThresholdUncertainty2;

targetFluxTimeSeriesIn.values = timeSeriesWithOutliersValues;
targetFluxTimeSeriesIn.uncertainties = timeSeriesWithOutliersUncertainties;

[outlierStruct, targetFluxTimeSeriesOut] = ...
    pdc_detect_outliers(targetFluxTimeSeriesIn, pdcModuleParameters, ...
    gapFillParameters);

% Assert that the correct outliers were identified.
disp('Outlier detection for time series with quadratric trend and multiple values above the detection threshold.');

messageOut = sprintf( ...
    'Length of outliers structure array does not equal number of targets!');
assert_equals(length(outlierStruct), length(targetFluxTimeSeriesIn), messageOut);

messageOut = sprintf( ...
    'Outlier(s) misidentified in time series with quadratic trend and multiple values above the detection threshold!');
overThresholdValues = [overThresholdValue; overThresholdValue2];
assert_equals(outlierStruct.values, overThresholdValues, messageOut);
overThresholdUncertainties = ...
    [overThresholdUncertainty; overThresholdUncertainty2];
assert_equals(outlierStruct.uncertainties, overThresholdUncertainties, ...
    messageOut);
overThresholdIndices = [overThresholdIndex; overThresholdIndex2];
assert_equals(outlierStruct.indices, overThresholdIndices, messageOut);

messageOut = sprintf( ...
    'Returned target flux time series with quadratic trend and multiple values above the detection threshold is not correct!');
assert_equals(targetFluxTimeSeriesOut.values(overThresholdIndices), [0; 0], messageOut);
assert_equals(targetFluxTimeSeriesOut.uncertainties(overThresholdIndices), [0; 0], messageOut);
assert_equals(targetFluxTimeSeriesOut.gapIndicators(overThresholdIndices), [true; true], messageOut);
targetFluxTimeSeriesOut.values(overThresholdIndices) = overThresholdValues;
targetFluxTimeSeriesOut.uncertainties(overThresholdIndices) = overThresholdUncertainties;
targetFluxTimeSeriesOut.gapIndicators(overThresholdIndices) = [false; false];
assert_equals(targetFluxTimeSeriesOut, targetFluxTimeSeriesIn, messageOut);

% Add a third outlier one cadence after the second. These consecutive
% "outliers" should be disregarded by the outlier identifier.
overThresholdValue3 = 5.1;
overThresholdUncertainty3 = abs(randn(1));
overThresholdIndex3 = overThresholdIndex2 + 1;

timeSeriesWithOutliersValues(overThresholdIndex3) = overThresholdValue3;
timeSeriesWithOutliersUncertainties(overThresholdIndex3) = ...
    overThresholdUncertainty3;

targetFluxTimeSeriesIn.values = timeSeriesWithOutliersValues;
targetFluxTimeSeriesIn.uncertainties = timeSeriesWithOutliersUncertainties;

[outlierStruct, targetFluxTimeSeriesOut] = ...
    pdc_detect_outliers(targetFluxTimeSeriesIn, pdcModuleParameters, ...
    gapFillParameters);

% Assert that the correct outlier was identified.
disp('Outlier detection for time series with quadratric trend and consecutive values above the detection threshold.');

messageOut = sprintf( ...
    'Length of outliers structure array does not equal number of targets!');
assert_equals(length(outlierStruct), length(targetFluxTimeSeriesIn), messageOut);

messageOut = sprintf( ...
    'Outlier(s) misidentified in time series with quadratic trend and consecutive values above the detection threshold!');
assert_equals(outlierStruct.values, overThresholdValue, messageOut);
assert_equals(outlierStruct.uncertainties, overThresholdUncertainty, messageOut);
assert_equals(outlierStruct.indices, overThresholdIndex, messageOut);

messageOut = sprintf( ...
    'Returned target flux time series with quadratic trend and consecutive values above the detection threshold is not correct!');
assert_equals(targetFluxTimeSeriesOut.values(overThresholdIndex), 0, messageOut);
assert_equals(targetFluxTimeSeriesOut.uncertainties(overThresholdIndex), 0, messageOut);
assert_equals(targetFluxTimeSeriesOut.gapIndicators(overThresholdIndex), true, messageOut);
targetFluxTimeSeriesOut.values(overThresholdIndex) = overThresholdValue;
targetFluxTimeSeriesOut.uncertainties(overThresholdIndex) = overThresholdUncertainty;
targetFluxTimeSeriesOut.gapIndicators(overThresholdIndex) = false;
assert_equals(targetFluxTimeSeriesOut, targetFluxTimeSeriesIn, messageOut);

% Test with data gaps for monthly downlinks.
gapIndicators(1501:1596) = true;
gapIndicators(3001:3096) = true;
timeSeriesWithOutliersValues(gapIndicators) = 0;
timeSeriesWithOutliersUncertainties(gapIndicators) = 0;

targetFluxTimeSeriesIn.values = timeSeriesWithOutliersValues;
targetFluxTimeSeriesIn.uncertainties = timeSeriesWithOutliersUncertainties;
targetFluxTimeSeriesIn.gapIndicators = gapIndicators;

[outlierStruct, targetFluxTimeSeriesOut] = ...
    pdc_detect_outliers(targetFluxTimeSeriesIn, pdcModuleParameters, ...
    gapFillParameters);

% Assert that the correct outlier was identified.
disp('Outlier detection for time series with monthly gaps.');

messageOut = sprintf( ...
    'Length of outliers structure array does not equal number of targets!');
assert_equals(length(outlierStruct), length(targetFluxTimeSeriesIn), messageOut);

messageOut = sprintf( ...
    'Outlier(s) misidentified in time series with monthly gaps!');
assert_equals(outlierStruct.values, overThresholdValue, messageOut);
assert_equals(outlierStruct.uncertainties, overThresholdUncertainty, messageOut);
assert_equals(outlierStruct.indices, overThresholdIndex, messageOut);

messageOut = sprintf( ...
    'Returned target flux time series with monthly gaps is not correct!');
assert_equals(targetFluxTimeSeriesOut.values(overThresholdIndex), 0, messageOut);
assert_equals(targetFluxTimeSeriesOut.uncertainties(overThresholdIndex), 0, messageOut);
assert_equals(targetFluxTimeSeriesOut.gapIndicators(overThresholdIndex), true, messageOut);
targetFluxTimeSeriesOut.values(overThresholdIndex) = overThresholdValue;
targetFluxTimeSeriesOut.uncertainties(overThresholdIndex) = overThresholdUncertainty;
targetFluxTimeSeriesOut.gapIndicators(overThresholdIndex) = false;
assert_equals(targetFluxTimeSeriesOut, targetFluxTimeSeriesIn, messageOut);

% Test with outlier events bridged by single cadence gap. These should
% *not* be identified as single cadence outliers.
timeSeriesWithOutliersValues(overThresholdIndex3) = 0;
timeSeriesWithOutliersUncertainties(overThresholdIndex3) = 0;
gapIndicators(overThresholdIndex3) = true;

overThresholdIndex3 = overThresholdIndex3 + 1;
timeSeriesWithOutliersValues(overThresholdIndex3) = 5.1;
timeSeriesWithOutliersUncertainties(overThresholdIndex3) = abs(randn(1));

targetFluxTimeSeriesIn.values = timeSeriesWithOutliersValues;
targetFluxTimeSeriesIn.uncertainties = timeSeriesWithOutliersUncertainties;
targetFluxTimeSeriesIn.gapIndicators = gapIndicators;

[outlierStruct, targetFluxTimeSeriesOut] = ...
    pdc_detect_outliers(targetFluxTimeSeriesIn, pdcModuleParameters, ...
    gapFillParameters);

% Assert that the correct outlier was identified.
disp('Outlier detection for time series with single cadence gap between values above detection threshold.');

messageOut = sprintf( ...
    'Length of outliers structure array does not equal number of targets!');
assert_equals(length(outlierStruct), length(targetFluxTimeSeriesIn), messageOut);

messageOut = sprintf( ...
    'Outlier(s) misidentified in time series with single cadence gap between values above detection threshold!');
assert_equals(outlierStruct.values, overThresholdValue, messageOut);
assert_equals(outlierStruct.uncertainties, overThresholdUncertainty, messageOut);
assert_equals(outlierStruct.indices, overThresholdIndex, messageOut);

messageOut = sprintf( ...
    'Returned target flux time series with single cadence gap between values above detection threshold is not correct!');
assert_equals(targetFluxTimeSeriesOut.values(overThresholdIndex), 0, messageOut);
assert_equals(targetFluxTimeSeriesOut.uncertainties(overThresholdIndex), 0, messageOut);
assert_equals(targetFluxTimeSeriesOut.gapIndicators(overThresholdIndex), true, messageOut);
targetFluxTimeSeriesOut.values(overThresholdIndex) = overThresholdValue;
targetFluxTimeSeriesOut.uncertainties(overThresholdIndex) = overThresholdUncertainty;
targetFluxTimeSeriesOut.gapIndicators(overThresholdIndex) = false;
assert_equals(targetFluxTimeSeriesOut, targetFluxTimeSeriesIn, messageOut);

% Finally, perform a regression test.
disp('Outlier detection regression test.');
regressionFileName = [path, filesep, 'detectOutliers.mat'];
load(regressionFileName);
[outlierStruct, targetFluxTimeSeries] = ...
    pdc_detect_outliers(targetFluxTimeSeries, pdcModuleParameters, ...
    gapFillParameters);                                                                     %#ok<NODEF>

messageOut = sprintf( ...
    'Failed regression test for outlierStruct!');
assert_equals(outlierStruct, regress.outlierStruct, messageOut);
messageOut = sprintf( ...
    'Failed regression test for targetFluxTimeSeries!');
assert_equals(targetFluxTimeSeries, regress.targetFluxTimeSeries, messageOut);

% Return.
return
    
