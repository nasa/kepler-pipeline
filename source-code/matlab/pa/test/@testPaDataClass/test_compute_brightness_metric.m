function self = test_compute_brightness_metric(self)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function self = test_encircledEnergy(self)
% This function loads targetStarDataStruct, targetStarResultsStruct 
% generated from 3 months (1 quarter) of simulated data from ETEM and 
% perfroms the tests on the operation of the compute_brightness_metric
% function:
%
% Run compute_brightness_metric on:
%   Full data set (4500 cadences, 2000 targets)
%   1)    - No data gaps
%   2)    - Randomly gapped flux time series
%   3)    - Randomly gapped targets (entire time series gapped)
%   4)    - Randomly gapped cadences (time series gapped at cadences for all targets)
%   Partial data set (100 cadences, 200 targets, no data gaps)
%   5)    - Zero 'brightTarget' labels
%   6)    - 50% of targets contain 'brightTarget' label
%   7)    - Use variable input brightParamStruct
%   8)    - Pass brightParamStruct with standardMag12 as time series
%   9-12) - Remove 1, 2, 3, 4 of the brightParamStruct fields
%   13)   - Pass a non-structure brightParamStruct
%   14)   - Pass empty targetStarDataStruct
%   15)   - Pass unequal length targetStarDataStruct and targetStarResulsStruct
%   16)   - Pass non-structure targetStarDataStruct and targetStarResulsStruct
%   17)   - Pass targetStarDataStruct and targetStarResulsStruct with missing
%           fields
%   18)   - Pass input structure where all flux time series values are
%           identical--> expected result values known.
% 
%   The size of the returned data is checked against the expected value for each case above.
%   If any of the checks fail, an error condition occurs.
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%  Use a test runner to run the test method:
%  Example: run(text_test_runner, testTppClass('test_compute_brightness_metric'));
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


%% Add paths for test-data and test-meta data
initialize_soc_variables;
testDataRepo = [socTestDataRoot filesep 'pa' filesep 'unit-tests' filesep 'brightness_metric'];
testMetaDataRepo = [socTestMetaDataRoot filesep 'pa' filesep 'unit-tests' filesep 'brightness_metric'];

addpath(testMetaDataRepo);

% data filename
dataFile = [testDataRepo filesep 'paBrightnessTestData'];


%% Load 1 quarter of ETEM Test Data from .mat file

% to avoid mlint warnings in code
targetStarDataStruct = [];
targetStarResultsStruct = [];
brightParamStruct = [];

disp(['Loading ',dataFile,' ...']);
load(dataFile);        

%% hard coded constants
GAPPED_DATA_INSTANCES = 1;          % number of instances of gapped data to check
GAP_FRACTION = 0.10;                % fraction of flux time series to gap
CADENCE_GAP_FRACTION = 0.10;        % fraction of cadences to gap
TARGET_GAP_FRACTION = 0.10;         % fraction of targets to gap
PARTIAL_TARGET_LIST = 1:200;        % target list for partial data set
PARTIAL_CADENCE_LIST = 1:100;       % cadence list for partial data set
NO_BRIGHT_LABELS = {'L1','L2'};     % label list for 'no brightLabels' test

% for constant flux time series test
MAG12_FLUX_VALUE = brightParamStruct.standardMag12Flux ;                   
CFLUX_VALUE = sqrt(MAG12_FLUX_VALUE);
TEST_FLUX_FRACTION = 1.0;
TEST_MAG = 12;
TEST_LABEL = brightParamStruct.brightnessLabel;
TEST_TOLERANCE = eps;

% lists of necessary fields in input structures
dataFields = {'keplerMag','labels','fluxFractionInAperture'};
resultsFields = {'fluxTimeSeries'};
fluxFields = {'values','uncertainties','gapIndicators'};

warningState = warning('query','all');
warning off all;        % disable warning echo

% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%   Full data set (4500 cadences, 2000 targets)
%   1)    - No data gaps
%   2)    - Randomly gapped flux time series
%   3)    - Randomly gapped targets (entire time series gapped)
%   4)    - Randomly gapped cadences (time series gapped at cadences for
%           all targets)

nCadences = length(targetStarResultsStruct(1).fluxTimeSeries(1).values);
nTargets = length(targetStarResultsStruct);

%% 1) No data gaps
disp(['Full data set - ',num2str(nTargets),' targets, ',...
    num2str(nCadences),' cadences - No data gaps ...']);
bright = compute_brightness_metric( targetStarDataStruct, targetStarResultsStruct);
assert_equals(true,length(bright.values)== nCadences,...
    'Length of brightness metric not equal to number of cadences');
assert_equals(true,length(bright.uncertainties) == nCadences,...
    'Length of brightness uncertainty not equal to number of cadences');
assert_equals(true,length(bright.gapIndicators) == nCadences,...
    'Length of brightness gap indicators not equal to number of cadences');

%% 2) Randomly gapped flux time series
disp(['Full data set - ',num2str(nTargets),' targets, ',...
    num2str(nCadences),' cadences - ',num2str(GAPPED_DATA_INSTANCES),' instances of randomly gapped flux time series ...']);
for i=1:GAPPED_DATA_INSTANCES
    % build gapped data
    gappedResultsStruct = targetStarResultsStruct;
    for j=1:nTargets        
        randCadences = [];
        while(length(randCadences) < GAP_FRACTION * nCadences)
            randCadences = unique(sort([randCadences,ceil(nCadences.*rand)]));
        end
        gappedResultsStruct(j).fluxTimeSeries.gapIndicators(randCadences) = true;
    end 
    bright = compute_brightness_metric( targetStarDataStruct, gappedResultsStruct);
    assert_equals(true,length(bright.values)== nCadences,...
        'Length of brightness metric not equal to number of cadences');
    assert_equals(true,length(bright.uncertainties) == nCadences,...
        'Length of brightness uncertainty not equal to number of cadences');
    assert_equals(true,length(bright.gapIndicators) == nCadences,...
        'Length of brightness gap indicators not equal to number of cadences');
end
    
%% 3) Randomly gapped targets (entire time series gapped)
for i=1:GAPPED_DATA_INSTANCES
    disp(['Full data set - ',num2str(nTargets),' targets, ',...
    num2str(nCadences),' cadences - ',num2str(GAPPED_DATA_INSTANCES),' instances of randomly gapped targets ...']);
    % build gapped data
    gappedResultsStruct = targetStarResultsStruct;
    randTargets = [];
    while(length(randTargets) < TARGET_GAP_FRACTION * nTargets)
        randTargets = unique(sort([randTargets,ceil(nTargets.*rand)]));
    end    
    for j=1:length(randTargets)
        gappedResultsStruct(randTargets(j)).fluxTimeSeries.gapIndicators(1:end) = true;
    end    
    bright = compute_brightness_metric( targetStarDataStruct, gappedResultsStruct);
    assert_equals(true,length(bright.values)== nCadences,...
        'Length of brightness metric not equal to number of cadences');
    assert_equals(true,length(bright.uncertainties) == nCadences,...
        'Length of brightness uncertainty not equal to number of cadences');
    assert_equals(true,length(bright.gapIndicators) == nCadences,...
        'Length of brightness gap indicators not equal to number of cadences');
end

%% 4) Randomly gapped cadences
disp(['Full data set - ',num2str(nTargets),' targets, ',...
    num2str(nCadences),' cadences - ',num2str(GAPPED_DATA_INSTANCES),' instances of randomly gapped cadences ...']);
for i=1:GAPPED_DATA_INSTANCES
    % build gapped data
    randCadences = [];
    while(length(randCadences) < CADENCE_GAP_FRACTION * nCadences)
        randCadences = unique(sort([randCadences,ceil(nCadences.*rand)]));
    end    
    gappedResultsStruct = targetStarResultsStruct;
    for j=1:nTargets        
        gappedResultsStruct(j).fluxTimeSeries.gapIndicators(randCadences) = true;
    end    
    bright = compute_brightness_metric( targetStarDataStruct, gappedResultsStruct);
    assert_equals(true,length(bright.values)== nCadences,...
        'Length of brightness metric not equal to number of cadences');
    assert_equals(true,length(bright.uncertainties) == nCadences,...
        'Length of brightness uncertainty not equal to number of cadences');
    assert_equals(true,length(bright.gapIndicators) == nCadences,...
        'Length of brightness gap indicators not equal to number of cadences');
    assert_equals(true,isempty(setdiff(randCadences,find(bright.gapIndicators))),...
        'At least one gapped cadence not marked with gap indicator in output');
end

clear gappedResultsStruct

% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%   Partial data set (100 cadences, 200 targets, no data gaps)
%   5)    - Zero 'brightTarget' labels
%   6)    - 50% of targets contain 'brightTarget' label
%   7)    - Use variable input brightParamStruct with all four fields
%   8-11) - Remove 1, 2, 3, 4 of the brightParamStruct fields
%   12)   - Pass a non-structure brightParamStruct
%   13)   - Pass empty targetStarDataStruct and targetStarResultsStruct
%   14)   - Pass unequal length targetStarDataStruct and targetStarResulsStruct
%   15)   - Pass non-structure targetStarDataStruct and targetStarResulsStruct
%   16)   - Pass targetStarDataStruct and targetStarResulsStruct with missing fields
%   17)   - Pass input structure where all flux time series values are
%           identical--> expected result values known.

% generate partial data set
nTargets = length(PARTIAL_TARGET_LIST);
nCadences = length(PARTIAL_CADENCE_LIST);

targetStarDataStruct = targetStarDataStruct(PARTIAL_TARGET_LIST);
targetStarResultsStruct = targetStarResultsStruct(PARTIAL_TARGET_LIST);

for i=1:nTargets
    targetStarResultsStruct(i).fluxTimeSeries.values = ...
        targetStarResultsStruct(i).fluxTimeSeries.values(PARTIAL_CADENCE_LIST);
    targetStarResultsStruct(i).fluxTimeSeries.uncertainties = ...
        targetStarResultsStruct(i).fluxTimeSeries.uncertainties(PARTIAL_CADENCE_LIST);
    targetStarResultsStruct(i).fluxTimeSeries.gapIndicators = ...
        targetStarResultsStruct(i).fluxTimeSeries.gapIndicators(PARTIAL_CADENCE_LIST);
end


%% 5) Zero 'brightTarget' labels
disp(['Partial data set - ',num2str(nTargets),' targets, ',...
    num2str(nCadences),' cadences - Zero brightTarget labels ...']);
testDataStruct = targetStarDataStruct;
for i=1:nTargets
    testDataStruct(i).labels = NO_BRIGHT_LABELS;
end
bright = compute_brightness_metric( testDataStruct, targetStarResultsStruct);
assert_equals(true,length(bright.values)== nCadences,...
    'Length of brightness metric not equal to number of cadences');
assert_equals(true,length(bright.uncertainties) == nCadences,...
    'Length of brightness uncertainty not equal to number of cadences');
assert_equals(true,length(bright.gapIndicators) == nCadences,...
    'Length of brightness gap indicators not equal to number of cadences');

%%  6) 50% of targets contain 'brightTarget' label
disp(['Partial data set - ',num2str(nTargets),' targets, ',...
    num2str(nCadences),' cadences - 50% of targets contain brightTarget label ...']);
testDataStruct = targetStarDataStruct;
for i=1:2:nTargets
    testDataStruct(i).labels = NO_BRIGHT_LABELS;
end
bright = compute_brightness_metric( testDataStruct, targetStarResultsStruct);
assert_equals(true,length(bright.values)== nCadences,...
    'Length of brightness metric not equal to number of cadences');
assert_equals(true,length(bright.uncertainties) == nCadences,...
    'Length of brightness uncertainty not equal to number of cadences');
assert_equals(true,length(bright.gapIndicators) == nCadences,...
    'Length of brightness gap indicators not equal to number of cadences');

%%  7) Use variable input brightParamStruct with all four fields
paramFields = fieldnames(brightParamStruct);
disp(['Partial data set - ',num2str(nTargets),' targets, ',num2str(nCadences),...
    ' cadences - Use variable input brightParamStruct with all four fields ...']);
testDataStruct = targetStarDataStruct;
bright = compute_brightness_metric( testDataStruct, targetStarResultsStruct, brightParamStruct);
assert_equals(true,length(bright.values)== nCadences,...
    'Length of brightness metric not equal to number of cadences');
assert_equals(true,length(bright.uncertainties) == nCadences,...
    'Length of brightness uncertainty not equal to number of cadences');
assert_equals(true,length(bright.gapIndicators) == nCadences,...
    'Length of brightness gap indicators not equal to number of cadences');

%%  8) Pass brightParamStruct with standardMag12 as time series
brightParamStruct.standardMag12Flux = ones(nCadences,1) .* brightParamStruct.standardMag12Flux;
disp(['Partial data set - ',num2str(nTargets),' targets, ',num2str(nCadences),...
    ' cadences - Use variable input brightParamStruct with standardMag12 field as a vector ...']);
testDataStruct = targetStarDataStruct;
bright = compute_brightness_metric( testDataStruct, targetStarResultsStruct, brightParamStruct);
assert_equals(true,length(bright.values)== nCadences,...
    'Length of brightness metric not equal to number of cadences');
assert_equals(true,length(bright.uncertainties) == nCadences,...
    'Length of brightness uncertainty not equal to number of cadences');
assert_equals(true,length(bright.gapIndicators) == nCadences,...
    'Length of brightness gap indicators not equal to number of cadences');

%%  9) Use variable input brightParamStruct with 3 fields
brightParamStruct = rmfield(brightParamStruct,paramFields{1});
disp(['Partial data set - ',num2str(nTargets),' targets, ',num2str(nCadences),...
    ' cadences - Use variable input brightParamStruct with three fields ...']);
testDataStruct = targetStarDataStruct;
bright = compute_brightness_metric( testDataStruct, targetStarResultsStruct, brightParamStruct);
assert_equals(true,length(bright.values)== nCadences,...
    'Length of brightness metric not equal to number of cadences');
assert_equals(true,length(bright.uncertainties) == nCadences,...
    'Length of brightness uncertainty not equal to number of cadences');
assert_equals(true,length(bright.gapIndicators) == nCadences,...
    'Length of brightness gap indicators not equal to number of cadences');

%%  10) Use variable input brightParamStruct with 2 fields
brightParamStruct = rmfield(brightParamStruct,paramFields{2});
disp(['Partial data set - ',num2str(nTargets),' targets, ',num2str(nCadences),...
    ' cadences - Use variable input brightParamStruct with two fields ...']);
testDataStruct = targetStarDataStruct;
bright = compute_brightness_metric( testDataStruct, targetStarResultsStruct, brightParamStruct);
assert_equals(true,length(bright.values)== nCadences,...
    'Length of brightness metric not equal to number of cadences');
assert_equals(true,length(bright.uncertainties) == nCadences,...
    'Length of brightness uncertainty not equal to number of cadences');
assert_equals(true,length(bright.gapIndicators) == nCadences,...
    'Length of brightness gap indicators not equal to number of cadences');

%%  11) Use variable input brightParamStruct with 1 fields
brightParamStruct = rmfield(brightParamStruct,paramFields{3});
disp(['Partial data set - ',num2str(nTargets),' targets, ',num2str(nCadences),...
    ' cadences - Use variable input brightParamStruct with one field ...']);
testDataStruct = targetStarDataStruct;
bright = compute_brightness_metric( testDataStruct, targetStarResultsStruct, brightParamStruct);
assert_equals(true,length(bright.values)== nCadences,...
    'Length of brightness metric not equal to number of cadences');
assert_equals(true,length(bright.uncertainties) == nCadences,...
    'Length of brightness uncertainty not equal to number of cadences');
assert_equals(true,length(bright.gapIndicators) == nCadences,...
    'Length of brightness gap indicators not equal to number of cadences');

%%  12) Use variable input brightParamStruct with 0 fields
brightParamStruct = rmfield(brightParamStruct,paramFields{4});
disp(['Partial data set - ',num2str(nTargets),' targets, ',num2str(nCadences),...
    ' cadences - Use variable input brightParamStruct with zero fields ...']);
testDataStruct = targetStarDataStruct;
bright = compute_brightness_metric( testDataStruct, targetStarResultsStruct, brightParamStruct);
assert_equals(true,length(bright.values)== nCadences,...
    'Length of brightness metric not equal to number of cadences');
assert_equals(true,length(bright.uncertainties) == nCadences,...
    'Length of brightness uncertainty not equal to number of cadences');
assert_equals(true,length(bright.gapIndicators) == nCadences,...
    'Length of brightness gap indicators not equal to number of cadences');

%%  13) Pass a non-structure brightParamStruct
brightParamStruct = 'notastructure';
disp(['Partial data set - ',num2str(nTargets),' targets, ',num2str(nCadences),...
    ' cadences - Use variable input brightParamStruct which is not a structure ...']);
testDataStruct = targetStarDataStruct;
bright = compute_brightness_metric( testDataStruct, targetStarResultsStruct, brightParamStruct);
assert_equals(true,length(bright.values)== nCadences,...
    'Length of brightness metric not equal to number of cadences');
assert_equals(true,length(bright.uncertainties) == nCadences,...
    'Length of brightness uncertainty not equal to number of cadences');
assert_equals(true,length(bright.gapIndicators) == nCadences,...
    'Length of brightness gap indicators not equal to number of cadences');

%%  14) Pass empty targetStarDataStruct
disp(['Partial data set - ',num2str(nTargets),' targets, ',num2str(nCadences),...
    ' cadences - Empty targetStarDataStruct ...']);
testDataStruct = struct();
bright = compute_brightness_metric( testDataStruct, targetStarResultsStruct);
assert_equals(true,isempty(bright.values),...
    'Brightness metric not empty');
assert_equals(true,isempty(bright.uncertainties),...
    'Brightness uncertainty not empty');
assert_equals(true,isempty(bright.gapIndicators),...
    'Brightness gap indicators not empty');

%   Pass empty targetStarResultsStruct
disp(['Partial data set - ',num2str(nTargets),' targets, ',num2str(nCadences),...
    ' cadences - Empty targetStarResultsStruct ...']);
testResultsStruct = struct();
bright = compute_brightness_metric( targetStarDataStruct, testResultsStruct);
assert_equals(true,isempty(bright.values),...
    'Brightness metric not empty');
assert_equals(true,isempty(bright.uncertainties),...
    'Brightness uncertainty not empty');
assert_equals(true,isempty(bright.gapIndicators),...
    'Brightness gap indicators not empty');

%%  15)   - Pass unequal length targetStarDataStruct and targetStarResulsStruct
disp(['Partial data set - ',num2str(nTargets),' targets, ',num2str(nCadences),...
    ' cadences - Different length targetStarDataStruct and targetStarResultsStruct ...']);
testResultsStruct = targetStarResultsStruct(1:nTargets-1);
bright = compute_brightness_metric( targetStarDataStruct, testResultsStruct);
assert_equals(true,length(targetStarDataStruct) ~= length(testResultsStruct),...
    'targetStarDataStruct and targetStarResultsStruct of equal length');
assert_equals(true,isempty(bright.values),...
    'Brightness metric not empty');
assert_equals(true,isempty(bright.uncertainties),...
    'Brightness uncertainty not empty');
assert_equals(true,isempty(bright.gapIndicators),...
    'Brightness gap indicators not empty');

%%  16) Pass non-structure targetStarDataStruct
disp(['Partial data set - ',num2str(nTargets),' targets, ',num2str(nCadences),...
    ' cadences - Empty targetStarDataStruct ...']);
testDataStruct = 'notastructure';
bright = compute_brightness_metric( testDataStruct, targetStarResultsStruct);
assert_equals(true,isempty(bright.values),...
    'Brightness metric not empty');
assert_equals(true,isempty(bright.uncertainties),...
    'Brightness uncertainty not empty');
assert_equals(true,isempty(bright.gapIndicators),...
    'Brightness gap indicators not empty');

%   Pass non-structure targetStarResultsStruct
disp(['Partial data set - ',num2str(nTargets),' targets, ',num2str(nCadences),...
    ' cadences - Empty targetStarResultsStruct ...']);
testResultsStruct = 'notastructure';
bright = compute_brightness_metric( targetStarDataStruct, testResultsStruct);
assert_equals(true,isempty(bright.values),...
    'Brightness metric not empty');
assert_equals(true,isempty(bright.uncertainties),...
    'Brightness uncertainty not empty');
assert_equals(true,isempty(bright.gapIndicators),...
    'Brightness gap indicators not empty');

%%  17)   - Pass targetStarDataStruct and targetStarResulsStruct with missing fields
disp(['Partial data set - ',num2str(nTargets),' targets, ',num2str(nCadences),...
    ' cadences - Check using missing fields in targetStarDataStruct and targetStarResultsStruct ...']);
for i=1:length(dataFields)
    testDataStruct = rmfield(targetStarDataStruct,dataFields{i});
    bright = compute_brightness_metric( testDataStruct, targetStarResultsStruct);
    disp(['targetStarDataStruct.',dataFields{i},' removed ...']);
    assert_equals(true,isempty(bright.values),...
        'Brightness metric not empty');
    assert_equals(true,isempty(bright.uncertainties),...
        'Brightness uncertainty not empty');
    assert_equals(true,isempty(bright.gapIndicators),...
        'Brightness gap indicators not empty');
end
for i=1:length(resultsFields)
    testResultsStruct = rmfield(targetStarResultsStruct,resultsFields{i});
    bright = compute_brightness_metric( targetStarDataStruct, testResultsStruct);
    disp(['targetStarResultsStruct.',resultsFields{i},' removed ...']);    
    assert_equals(true,isempty(bright.values),...
        'Brightness metric not empty');
    assert_equals(true,isempty(bright.uncertainties),...
        'Brightness uncertainty not empty');
    assert_equals(true,isempty(bright.gapIndicators),...
        'Brightness gap indicators not empty');
end
for i=1:length(fluxFields)
    clear testResultsStruct;    
    for j=1:nTargets
        testResultsStruct(j).fluxTimeSeries = rmfield(targetStarResultsStruct(j).fluxTimeSeries,fluxFields{i});
    end
    bright = compute_brightness_metric( targetStarDataStruct, testResultsStruct);
    disp(['targetStarResultsStruct(:).fluxTimeSeries.',fluxFields{i},' removed ...']);    
    assert_equals(true,isempty(bright.values),...
        'Brightness metric not empty');
    assert_equals(true,isempty(bright.uncertainties),...
        'Brightness uncertainty not empty');
    assert_equals(true,isempty(bright.gapIndicators),...
        'Brightness gap indicators not empty');
end

%%  18)   - Pass input structure where all flux time series values are identical--> expected result values known.
disp(['Partial data set - ',num2str(nTargets),' targets, ',num2str(nCadences),...
    ' cadences - Check output against constant input flux time series ...']);
% set up testResultsStruct
testResultsStruct = targetStarResultsStruct;
testDataStruct = targetStarDataStruct;
for i=1:nTargets
    testDataStruct(i).keplerMag = TEST_MAG;
    testDataStruct(i).fluxFractionInAperture = TEST_FLUX_FRACTION;
    testDataStruct(i).labels = {TEST_LABEL};
    testResultsStruct(i).fluxTimeSeries.values = ones(nCadences,1).*MAG12_FLUX_VALUE;
    testResultsStruct(i).fluxTimeSeries.uncertainties = ones(nCadences,1).*CFLUX_VALUE;
    testResultsStruct(i).fluxTimeSeries.gapIndicators = false(nCadences,1);
end
bright = compute_brightness_metric( testDataStruct, testResultsStruct);
assert_equals(true,all(abs(bright.values - 1) < TEST_TOLERANCE ),...
    'Brightness metric not equal to 1');
assert_equals(true,all(abs(bright.uncertainties - CFLUX_VALUE/MAG12_FLUX_VALUE/sqrt(nTargets)) < TEST_TOLERANCE),...
    'Brightness uncertainty not equal expected');
assert_equals(true,all(~bright.gapIndicators),...
    'Brightness gap indicators indicate gaps');


% restore warning state
warning(warningState);
