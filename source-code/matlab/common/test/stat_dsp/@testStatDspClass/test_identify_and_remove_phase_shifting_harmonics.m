function [self] = test_identify_and_remove_phase_shifting_harmonics(self)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% [self] = test_identify_and_remove_phase_shifting_harmonics(self)
%
% This test generates time series with and without harmonic content, and
% verifies the ability of the identify_and_remove_phase_shifting_harmonics
% function to return the correct harmonic models.
%
%  Example
%  =======
%  Use a test runner to run the test method:
%      run(text_test_runner, ...
%          testStatDspClass('test_identify_and_remove_phase_shifting_harmonics'));
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
path = [socTestDataRoot, filesep, 'common', filesep, 'unit-tests', filesep, 'stat-dsp'];

% Define constants.
FREQ_TOL_IN_BINS = 0.1;
CADENCES_PER_QUARTER = 93 * 48;
CONSTANT_LEVEL = 100;

% Load gap fill and harmonic identification parameters.
gapFillParametersFileName = [path, filesep, 'gapFillParameters.mat'];
load(gapFillParametersFileName);

harmonicsIdentificationParametersFileName = ...
    [path, filesep, 'harmonicsIdentificationParameters.mat'];
load(harmonicsIdentificationParametersFileName);

% Construct a random time series without any harmonic content and verify
% that no harmonics are identified.
randn('state', 0);
randomTimeSeries = randn([CADENCES_PER_QUARTER, 1]);
gapIndicators = false([CADENCES_PER_QUARTER, 1]);

originalTimeSeries = CONSTANT_LEVEL + randomTimeSeries;

[harmonicsRemovedTimeSeries, harmonicTimeSeries, indexOfGiantTransits, ...
    harmonicModelStruct] = identify_and_remove_phase_shifting_harmonics( ...
    originalTimeSeries, gapIndicators, gapFillParameters, ...
    harmonicsIdentificationParameters, []);

% Assert that no harmonics were identified and that harmonics removed time
% series is in fact the original time series.
disp('Harmonics identification with purely random time series.');
messageOut = sprintf( ...
    'Harmonic content misidentified in purely random time series!');
assert_equals(isempty(harmonicTimeSeries), true, messageOut);
assert_equals(isempty(harmonicModelStruct.cosCoeffts), true, messageOut);
assert_equals(isempty(harmonicModelStruct.sinCoeffts), true, messageOut);
assert_equals(isempty(harmonicModelStruct.harmonicFrequenciesInHz), ...
    true, messageOut);
assert_equals(isempty(harmonicModelStruct.samplingTimesInSeconds), ...
    true, messageOut);

messageOut = sprintf( ...
    'Harmonics removed time series when no harmonics are present is not identical to the original time series!');
assert_equals(harmonicsRemovedTimeSeries, originalTimeSeries, messageOut);

% Add a sinusoid with a known frequency and verify that the correct
% harmonic component is identified.
secondsInMinute = get_unit_conversion('min2sec');
cadenceDurationInMinutes = gapFillParameters.cadenceDurationInMinutes;

samplingFrequencyInHz = 1 / (cadenceDurationInMinutes * secondsInMinute);
nBins = 2^nextpow2(CADENCES_PER_QUARTER);

amp1 = 10.0;
dfreq1 = (1 / nBins) * (20 + pi);
freq1 = samplingFrequencyInHz * dfreq1;
harmonicTimeSeries1 = ...
    amp1 * cos(2 * pi * dfreq1 * (1 : CADENCES_PER_QUARTER)');

originalTimeSeries = ...
    CONSTANT_LEVEL + randomTimeSeries + harmonicTimeSeries1;

[harmonicsRemovedTimeSeries, harmonicTimeSeries, indexOfGiantTransits, ...
    harmonicModelStruct] = identify_and_remove_phase_shifting_harmonics( ...
    originalTimeSeries, gapIndicators, gapFillParameters, ...
    harmonicsIdentificationParameters, []);

% Assert that the correct harmonic component was identified at the
% specified tolerance (in units of periodogram bins).
disp('Harmonics identification with strong harmonic signal in noise.');
binResolutionInHz = samplingFrequencyInHz / nBins;
[maxPower, index] = max(...
    harmonicModelStruct.cosCoeffts.^2 + harmonicModelStruct.sinCoeffts.^2);
delta = abs(harmonicModelStruct.harmonicFrequenciesInHz(index) - freq1) / ...
    binResolutionInHz;
messageOut = sprintf( ...
    'Unidentified harmonic component at specified tolerance!');
assert_equals(delta > FREQ_TOL_IN_BINS, false, messageOut);

% Reduce the amplitude of the sinusoid by a factor of 10 and repeat.
amp1 = 1.0;
dfreq1 = (1 / nBins) * (20 + pi);
freq1 = samplingFrequencyInHz * dfreq1;
harmonicTimeSeries1 = ...
    amp1 * cos(2 * pi * dfreq1 * (1 : CADENCES_PER_QUARTER)');

originalTimeSeries = ...
    CONSTANT_LEVEL + randomTimeSeries + harmonicTimeSeries1;

[harmonicsRemovedTimeSeries, harmonicTimeSeries, indexOfGiantTransits, ...
    harmonicModelStruct] = identify_and_remove_phase_shifting_harmonics( ...
    originalTimeSeries, gapIndicators, gapFillParameters, ...
    harmonicsIdentificationParameters, []);

% Assert that the correct harmonic component was identified at the
% specified tolerance (in units of periodogram bins).
disp('Harmonics identification with weaker harmonic signal in noise.');
[maxPower, index] = max(...
    harmonicModelStruct.cosCoeffts.^2 + harmonicModelStruct.sinCoeffts.^2);
delta = abs(harmonicModelStruct.harmonicFrequenciesInHz(index) - freq1) / ...
    binResolutionInHz;
messageOut = sprintf( ...
    'Unidentified harmonic component at specified tolerance!');
assert_equals(delta > FREQ_TOL_IN_BINS, false, messageOut);

% Add a second component at a lower amplitude.
amp2 = amp1 / 4;
dfreq2 = (1 / nBins) * (256 + exp(1));
freq2 = samplingFrequencyInHz * dfreq2;
harmonicTimeSeries2 = ...
    amp2 * cos(2 * pi * dfreq2 * (1 : CADENCES_PER_QUARTER)');

originalTimeSeries = ...
    CONSTANT_LEVEL + randomTimeSeries + ...
    harmonicTimeSeries1 + harmonicTimeSeries2;

[harmonicsRemovedTimeSeries, harmonicTimeSeries, indexOfGiantTransits, ...
    harmonicModelStruct] = identify_and_remove_phase_shifting_harmonics( ...
    originalTimeSeries, gapIndicators, gapFillParameters, ...
    harmonicsIdentificationParameters, []);

% Assert that the correct harmonic components were identified at the
% specified tolerance (in units of periodogram bins).
disp('Harmonics identification with two harmonic signals in noise.');
[maxPower, index] = max(...
    harmonicModelStruct.cosCoeffts.^2 + harmonicModelStruct.sinCoeffts.^2);
delta = abs(harmonicModelStruct.harmonicFrequenciesInHz(index) - freq1) / ...
    binResolutionInHz;
messageOut = sprintf( ...
    'Unidentified primary harmonic component at specified tolerance!');
assert_equals(delta > FREQ_TOL_IN_BINS, false, messageOut);

harmonicModelStruct.harmonicFrequenciesInHz(index) = [];
[maxPower, index] = max(...
    harmonicModelStruct.cosCoeffts.^2 + harmonicModelStruct.sinCoeffts.^2);
delta = abs(harmonicModelStruct.harmonicFrequenciesInHz(index) - freq2) / ...
    binResolutionInHz;
messageOut = sprintf( ...
    'Unidentified secondary harmonic component at specified tolerance!');
assert_equals(delta > FREQ_TOL_IN_BINS, false, messageOut);

% Test with data gaps for monthly downlinks.
disp('Harmonics identification with data gaps.');
gapIndicators(1501:1596) = true;
gapIndicators(3001:3096) = true;
originalTimeSeries(gapIndicators) = 0;
[harmonicsRemovedTimeSeries, harmonicTimeSeries, indexOfGiantTransits, ...
    harmonicModelStruct] = identify_and_remove_phase_shifting_harmonics( ...
    originalTimeSeries, gapIndicators, gapFillParameters, ...
    harmonicsIdentificationParameters, []);

[maxPower, index] = max(...
    harmonicModelStruct.cosCoeffts.^2 + harmonicModelStruct.sinCoeffts.^2);
delta = abs(harmonicModelStruct.harmonicFrequenciesInHz(index) - freq1) / ...
    binResolutionInHz;
messageOut = sprintf( ...
    'Unidentified primary harmonic component at specified tolerance with data gaps!');
assert_equals(delta > FREQ_TOL_IN_BINS, false, messageOut);

harmonicModelStruct.harmonicFrequenciesInHz(index) = [];
[maxPower, index] = max(...
    harmonicModelStruct.cosCoeffts.^2 + harmonicModelStruct.sinCoeffts.^2);
delta = abs(harmonicModelStruct.harmonicFrequenciesInHz(index) - freq2) / ...
    binResolutionInHz;
messageOut = sprintf( ...
    'Unidentified secondary harmonic component at specified tolerance with data gaps!');
assert_equals(delta > FREQ_TOL_IN_BINS, false, messageOut);

% Finally, perform a regression test.
disp('Harmonics identification regression test.');
regressionFileName = [path, filesep, 'identifyAndRemovePhaseShiftingHarmonics.mat'];
load(regressionFileName);
[harmonicsRemovedTimeSeries, harmonicTimeSeries, indexOfGiantTransits, ...
    harmonicModelStruct, medianFlux, convertedToRelativeFluxFlag] = ...
    identify_and_remove_phase_shifting_harmonics( ...
    originalTimeSeries, gapIndicators, gapFillParameters, ...
    harmonicsIdentificationParameters, []);

messageOut = sprintf( ...
    'Failed regression test for harmonicsRemovedTimeSeries!');
assert_equals(single(harmonicsRemovedTimeSeries), ...
    single(regress.harmonicsRemovedTimeSeries), messageOut);
messageOut = sprintf( ...
    'Failed regression test for harmonicTimeSeries!');
assert_equals(single(harmonicTimeSeries), single(regress.harmonicTimeSeries), messageOut);
messageOut = sprintf( ...
    'Failed regression test for indexOfGiantTransits!');
assert_equals(indexOfGiantTransits, regress.indexOfGiantTransits, messageOut);
messageOut = sprintf( ...
    'Failed regression test for harmonicModelStruct!');
assert_equals(convert_struct_fields_to_float(harmonicModelStruct), ...
    convert_struct_fields_to_float(regress.harmonicModelStruct), messageOut);
messageOut = sprintf( ...
    'Failed regression test for medianFlux!');
assert_equals(single(medianFlux), single(regress.medianFlux), messageOut);
messageOut = sprintf( ...
    'Failed regression test for convertedToRelativeFluxFlag!');
assert_equals(convertedToRelativeFluxFlag, regress.convertedToRelativeFluxFlag, messageOut);

% Return.
return
    