function self = test_pmd_track_trend_and_alarm_generation(self)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function self = test_pmd_track_trend_and_alarm_generation(self)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% This function tests 
% (1) PMD time series track and trend.
% (2) PMD time series bounds check and alarm generation
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Run with:
%   run(text_test_runner, testPMDClass('test_pmd_track_trend_and_alarm_generation'))
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

clear pmdInputStruct;
clear pmdScienceClass;

messageOut = 'Test failed - The retrieved data and the expected data are not identical!';

initialize_soc_variables;
pmdTestDataRoot = fullfile(socTestDataRoot, 'ppa', 'MATLAB', 'unit-tests', 'pmd');
addpath(pmdTestDataRoot);

load pmdInputStruct_unitTest.mat;
load unitTestDataStruct.mat;

% Part 1. PMD time series track and trend

fprintf('\nTest PMD: track and trend\n');

parameters           = pmdInputStruct.pmdModuleParameters;
cadenceTimes         = pmdInputStruct.cadenceTimes.midTimestamps;
cadenceGapIndicators = pmdInputStruct.cadenceTimes.gapIndicators;
ccdModule            = pmdInputStruct.ccdModule;
ccdOutput            = pmdInputStruct.ccdOutput;

% Black Level metrics

metricTs = pmdInputStruct.inputTsData.blackLevel;
smoothingFactor = pmdInputStruct.pmdModuleParameters.blackLevelSmoothingFactor;
fixedLowerBound = pmdInputStruct.pmdModuleParameters.blackLevelFixedLowerBound;
fixedUpperBound = pmdInputStruct.pmdModuleParameters.blackLevelFixedUpperBound;
adaptiveXFactor = pmdInputStruct.pmdModuleParameters.blackLevelAdaptiveXFactor;

figure;
[blackLevelReport] = ppa_create_report(parameters, metricTs, smoothingFactor, fixedLowerBound, ...
    fixedUpperBound, adaptiveXFactor, 'black level', cadenceTimes, cadenceGapIndicators, ccdModule, ccdOutput);

testDataStruct = unitTestDataStruct.reports.blackLevelOutlier;
isEmptyFlags   = check_out_of_bound_times(blackLevelReport, testDataStruct);
if any(isEmptyFlags)
    assert_equals(1, 0, messageOut);
end

% Smear Level metrics

metricTs = pmdInputStruct.inputTsData.smearLevel;
smoothingFactor = pmdInputStruct.pmdModuleParameters.smearLevelSmoothingFactor;
fixedLowerBound = pmdInputStruct.pmdModuleParameters.smearLevelFixedLowerBound;
fixedUpperBound = pmdInputStruct.pmdModuleParameters.smearLevelFixedUpperBound;
adaptiveXFactor = pmdInputStruct.pmdModuleParameters.smearLevelAdaptiveXFactor;

figure;
[smearLevelReport] = ppa_create_report(parameters, metricTs, smoothingFactor, fixedLowerBound, ...
    fixedUpperBound, adaptiveXFactor, 'smear level', cadenceTimes, cadenceGapIndicators, ccdModule, ccdOutput);

testDataStruct = unitTestDataStruct.reports.smearLevelOutlier;
isEmptyFlags   = check_out_of_bound_times(smearLevelReport, testDataStruct);
if any(isEmptyFlags)
    assert_equals(1, 0, messageOut);
end


% Part 2. PMD time series bounds check and alarm generation

display('Test PMD: Bounds Check and Alarm Generation');

% Black Level metrics

nFixedUpperBound    = 0;
nFixedLowerBound    = 0;
nAdaptiveUpperBound = 0;
nAdaptiveLowerBound = 0;
for i=1:length(blackLevelReport.alerts)
    if ~isempty(strfind(blackLevelReport.alerts(i).message, 'out of fixed upper bound'))
        nFixedUpperBound = nFixedUpperBound + 1;
    end
    if ~isempty(strfind(blackLevelReport.alerts(i).message, 'out of fixed lower bound'))
        nFixedLowerBound = nFixedLowerBound + 1;
    end
    if ~isempty(strfind(blackLevelReport.alerts(i).message, 'out of adaptive upper bound'))
        nAdaptiveUpperBound = nAdaptiveUpperBound + 1;
    end
    if ~isempty(strfind(blackLevelReport.alerts(i).message, 'out of adaptive lower bound'))
        nAdaptiveLowerBound = nAdaptiveLowerBound + 1;
    end
end
if ( nFixedUpperBound < 2 )
    assert_equals(1, 0, messageOut);
end
if ( nFixedLowerBound < 1 )
    assert_equals(1, 0, messageOut);
end
if ( nAdaptiveUpperBound < 2 )
    assert_equals(1, 0, messageOut);
end
if ( nAdaptiveLowerBound < 1 )
    assert_equals(1, 0, messageOut);
end

% Smear Level metrics

nFixedUpperBound    = 0;
nFixedLowerBound    = 0;
nAdaptiveUpperBound = 0;
nAdaptiveLowerBound = 0;
for i=1:length(smearLevelReport.alerts)
    if strfind(smearLevelReport.alerts(i).message, 'out of fixed upper bound')
        nFixedUpperBound = nFixedUpperBound + 1;
    end
    if strfind(smearLevelReport.alerts(i).message, 'out of fixed lower bound')
        nFixedLowerBound = nFixedLowerBound + 1;
    end
    if strfind(smearLevelReport.alerts(i).message, 'out of adaptive upper bound')
        nAdaptiveUpperBound = nAdaptiveUpperBound + 1;
    end
    if strfind(smearLevelReport.alerts(i).message, 'out of adaptive lower bound')
        nAdaptiveLowerBound = nAdaptiveLowerBound + 1;
    end
end
if ( nFixedUpperBound < 2 )
    assert_equals(1, 0, messageOut);
end
if ( nFixedLowerBound < 1 )
    assert_equals(1, 0, messageOut);
end
if ( nAdaptiveUpperBound < 2 )
    assert_equals(1, 0, messageOut);
end
if ( nAdaptiveLowerBound < 1 )
    assert_equals(1, 0, messageOut);
end

rmpath(pmdTestDataRoot);

return