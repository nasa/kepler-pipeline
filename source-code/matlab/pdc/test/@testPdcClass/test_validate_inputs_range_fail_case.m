function [self] = test_validate_inputs_range_fail_case(self)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [self] = test_validate_inputs_range_fail_case(self)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% This test checks whether the class constructor catches the out of bounds value
% and throws an error. This test calls assign_illegal_value_and_test_for_failure,
% which checks for NaNs, Infs, violation of lower bound, violation of upper bound,
% or violation of list membership.
%
%
%  Example
%  =======
%  Use a test runner to run the test method:
%      run(text_test_runner, testPdcClass('test_validate_inputs_range_fail_case'));
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

% Define variables, (conditional) path and file names.
initialize_soc_variables;
pdcTestDataDir = fullfile(socTestDataRoot, 'pdc', 'unit-tests', 'pdc-matlab-46-6550');
quickAndDirtyCheckFlag = false;

% Generate the input structure by one of the following methods:

% ------>> NOT Provided <<-------------------
% (1) Create the input structure pdcInputDataStruct
% [pdcInputDataStruct] = generate_pdc_test_data;

% (2) Load a previously generated test data structure pdcInputDataStruct
load(fullfile(pdcTestDataDir, 'pdc-inputs-0.mat'));

% (3) Read a test data structure pdcInputDataStruct from a previously
%     generated bin file
%[pdcInputDataStruct] = read_PdcInputs(fullfile(pdcTestDataDir, 'pdc-inputs-0.bin'));

pdcInputDataStruct = inputsStruct;
clear inputsStruct;
% trim the number of targets 
pdcInputDataStruct.targetDataStruct = pdcInputDataStruct.targetDataStruct(1:10);

%--------------------------------------------------------------------------
% Top level validation.
% Assign invalid fields and check for failures in pdcInputDataStruct.
%
% If fields are structures, they are not included here (they are validated
% within the pdcDataClass, and also tested for missing fields in
% test_validate_missing_inputs).
%--------------------------------------------------------------------------
fieldsAndBounds = cell(4,4);
fieldsAndBounds(1,:)  = { 'ccdModule'; '>= 2'; '<= 24'; []};
fieldsAndBounds(2,:)  = { 'ccdOutput'; '>= 1'; '<= 4'; []};
fieldsAndBounds(3,:)  = { 'startCadence'; '>= 0'; '< 2e7'; []};
fieldsAndBounds(4,:)  = { 'endCadence'; '>= 0'; '< 2e7'; []};

assign_illegal_value_and_test_for_failure(pdcInputDataStruct, 'pdcInputDataStruct', ...
    pdcInputDataStruct, 'pdcInputDataStruct', 'pdcDataClass', fieldsAndBounds, ...
    quickAndDirtyCheckFlag);

clear fieldsAndBounds

%--------------------------------------------------------------------------
% Second level validation.
% Assign invalid fields and check for failures in pdcInputDataStruct.cadenceTimes.
%--------------------------------------------------------------------------
fieldsAndBounds = cell(4,4);
fieldsAndBounds(1,:)  = { 'startTimestamps'; '> 54500'; '< 70000'; []}; % 2/4/2008 to 7/13/2050
fieldsAndBounds(2,:)  = { 'midTimestamps'; '> 54500'; '< 70000'; []};   % 2/4/2008 to 7/13/2050
fieldsAndBounds(3,:)  = { 'endTimestamps'; '> 54500'; '< 70000'; []};   % 2/4/2008 to 7/13/2050
fieldsAndBounds(4,:)  = { 'cadenceNumbers'; '>= 0'; '< 2e7'; []};

assign_illegal_value_and_test_for_failure(pdcInputDataStruct.cadenceTimes, ...
    'pdcInputDataStruct.cadenceTimes', pdcInputDataStruct, 'pdcInputDataStruct', ...
    'pdcDataClass', fieldsAndBounds, quickAndDirtyCheckFlag);

clear fieldsAndBounds

%--------------------------------------------------------------------------
% Second level validation.
% Assign invalid fields and check for failures in pdcInputDataStruct.longCadenceTimes.
%--------------------------------------------------------------------------
fieldsAndBounds = cell(4,4);
fieldsAndBounds(1,:)  = { 'startTimestamps'; '> 54500'; '< 70000'; []}; % 2/4/2008 to 7/13/2050
fieldsAndBounds(2,:)  = { 'midTimestamps'; '> 54500'; '< 70000'; []};   % 2/4/2008 to 7/13/2050
fieldsAndBounds(3,:)  = { 'endTimestamps'; '> 54500'; '< 70000'; []};   % 2/4/2008 to 7/13/2050
fieldsAndBounds(4,:)  = { 'cadenceNumbers'; '>= 0'; '< 2e7'; []};

assign_illegal_value_and_test_for_failure(pdcInputDataStruct.longCadenceTimes, ...
    'pdcInputDataStruct.longCadenceTimes', pdcInputDataStruct, 'pdcInputDataStruct', ...
    'pdcDataClass', fieldsAndBounds, quickAndDirtyCheckFlag);

clear fieldsAndBounds

%--------------------------------------------------------------------------
% Second level validation.
% Assign invalid fields and check for failures in pdcInputDataStruct.pdcModuleParameters.
%--------------------------------------------------------------------------
fieldsAndBounds = cell(9,4);
fieldsAndBounds(1,:)  = { 'sgPolyOrder'; '>= 2'; '<= 24'; []};
fieldsAndBounds(2,:)  = { 'sgFrameSize'; '>= 25'; '< 1000'; []};
fieldsAndBounds(3,:)  = { 'satSegThreshold'; '> 0'; '<= 1e6'; []};
fieldsAndBounds(4,:)  = { 'satSegExclusionZone'; '>= 1'; '<= 1000'; []};
fieldsAndBounds(5,:)  = { 'medianFilterLength'; '>= 1'; '< 1000'; []};
fieldsAndBounds(6,:)  = { 'histogramLength'; '>= 1'; '< 1000'; []};
fieldsAndBounds(7,:)  = { 'histogramCountFraction'; '>= 0.5'; '<= 1.0'; []};
fieldsAndBounds(8,:) = { 'outlierScanWindowSize'; '>= 1'; '<= 30*48'; []};
fieldsAndBounds(9,:) = { 'outlierThresholdXFactor'; '> 0'; '< 10'; []};

assign_illegal_value_and_test_for_failure(pdcInputDataStruct.pdcModuleParameters, ...
    'pdcInputDataStruct.pdcModuleParameters', pdcInputDataStruct, 'pdcInputDataStruct', ...
    'pdcDataClass', fieldsAndBounds, quickAndDirtyCheckFlag);

clear fieldsAndBounds

%--------------------------------------------------------------------------
% Second level validation.
% Assign invalid fields and check for failures in pdcInputDataStruct.ancillaryEngineeringConfigurationStruct.
%--------------------------------------------------------------------------
fieldsAndBounds = cell(3,4);

fieldsAndBounds(1,:)  = { 'modelOrders'; '>= 0'; '<= 5'; []};
fieldsAndBounds(2,:)  = { 'quantizationLevels'; '>= 0'; []; []};
fieldsAndBounds(3,:)  = { 'intrinsicUncertainties'; '>= 0'; []; []};

engConfigStruct = pdcInputDataStruct.ancillaryEngineeringConfigurationStruct;

if ~isempty(engConfigStruct.modelOrders) && ~isempty(engConfigStruct.quantizationLevels) && ~isempty(engConfigStruct.intrinsicUncertainties)

    % to make this field non-empty
    pdcInputDataStruct.ancillaryEngineeringDataStruct.mnemonic = 'DUMMY';
    pdcInputDataStruct.ancillaryEngineeringDataStruct.timestamps = 54501;
    pdcInputDataStruct.ancillaryEngineeringDataStruct.values = 123456.0;

    assign_illegal_value_and_test_for_failure(pdcInputDataStruct.ancillaryEngineeringConfigurationStruct, ...
        'pdcInputDataStruct.ancillaryEngineeringConfigurationStruct', pdcInputDataStruct, 'pdcInputDataStruct', ...
        'pdcDataClass', fieldsAndBounds, quickAndDirtyCheckFlag);
end

clear fieldsAndBounds

%--------------------------------------------------------------------------
% Second level validation.
% Assign invalid fields and check for failures in pdcInputDataStruct.ancillaryPipelineConfigurationStruct.
%--------------------------------------------------------------------------
fieldsAndBounds = cell(1,4);
fieldsAndBounds(1,:)  = { 'modelOrders'; '>= 0'; '<= 5'; []};

pdcInputDataStruct.ancillaryEngineeringConfigurationStruct.mnemonics = 'DUMMY';
pdcInputDataStruct.ancillaryEngineeringConfigurationStruct.modelOrders = 1;
pdcInputDataStruct.ancillaryEngineeringConfigurationStruct.quantizationLevels = 0.0;
pdcInputDataStruct.ancillaryEngineeringConfigurationStruct.intrinsicUncertainties = 0.0;

assign_illegal_value_and_test_for_failure(pdcInputDataStruct.ancillaryPipelineConfigurationStruct, ...
    'pdcInputDataStruct.ancillaryPipelineConfigurationStruct', pdcInputDataStruct, 'pdcInputDataStruct', ...
    'pdcDataClass', fieldsAndBounds, quickAndDirtyCheckFlag);

clear fieldsAndBounds;

%--------------------------------------------------------------------------
% Second level validation.
% Assign invalid fields and check for failures in pdcInputDataStruct.ancillaryAttitudeConfigurationStruct.
%--------------------------------------------------------------------------
fieldsAndBounds = cell(1,4);

fieldsAndBounds(1,:)  = { 'modelOrders'; '>= 0'; '<= 5'; []};

pdcInputDataStruct.attitudeSolutionStruct.gapIndicators = false;

assign_illegal_value_and_test_for_failure(pdcInputDataStruct.ancillaryAttitudeConfigurationStruct, ...
    'pdcInputDataStruct.ancillaryAttitudeConfigurationStruct', pdcInputDataStruct, 'pdcInputDataStruct', ...
    'pdcDataClass', fieldsAndBounds, quickAndDirtyCheckFlag);

clear fieldsAndBounds

%--------------------------------------------------------------------------
% Second level validation.
% Assign invalid fields and check for failures in pdcInputDataStruct.gapFillConfigurationStruct.
%--------------------------------------------------------------------------
fieldsAndBounds = cell(6,4);
fieldsAndBounds(1,:)  = { 'madXFactor'; '> 0'; '<= 100'; []};
fieldsAndBounds(2,:)  = { 'maxGiantTransitDurationInHours'; '> 0'; '<= 100'; []};
fieldsAndBounds(3,:)  = { 'maxDetrendPolyOrder'; '>= 1'; '<= 100'; []};
fieldsAndBounds(4,:)  = { 'maxArOrderLimit'; '>= 1'; '<= 100'; []};
fieldsAndBounds(5,:)  = { 'maxCorrelationWindowXFactor'; '>= 1'; '<= 100'; []};
fieldsAndBounds(6,:)  = { 'gapFillModeIsAddBackPredictionError'; []; []; [true; false]};

assign_illegal_value_and_test_for_failure(pdcInputDataStruct.gapFillConfigurationStruct, ...
    'pdcInputDataStruct.gapFillConfigurationStruct', pdcInputDataStruct, 'pdcInputDataStruct', ...
    'pdcDataClass', fieldsAndBounds, quickAndDirtyCheckFlag);

clear fieldsAndBounds

%--------------------------------------------------------------------------
% Second level validation.
% Assign invalid fields and check for failures in pdcInputDataStruct.ancillaryEngineeringDataStruct.
%--------------------------------------------------------------------------
fieldsAndBounds = cell(1,4);

fieldsAndBounds(1,:)  = { 'timestamps'; '> 54500'; '< 70000'; []};   % 2/4/2008 to 7/13/2050

nStructures = length(pdcInputDataStruct.ancillaryEngineeringDataStruct);
suppressDisplayFlag = true;
nStructures = min(nStructures, 1);
for j = 1 : nStructures
    lowLevelStructName =  ['pdcInputDataStruct.ancillaryEngineeringDataStruct(' num2str(j) ')'];

    assign_illegal_value_and_test_for_failure(pdcInputDataStruct.ancillaryEngineeringDataStruct(j), ...
        lowLevelStructName, pdcInputDataStruct, 'pdcInputDataStruct', 'pdcDataClass', ...
        fieldsAndBounds, quickAndDirtyCheckFlag, suppressDisplayFlag);
end

clear fieldsAndBounds

%--------------------------------------------------------------------------
% Second level validation.
% Assign invalid fields and check for failures in pdcInputDataStruct.ancillaryPipelineDataStruct.
%--------------------------------------------------------------------------
fieldsAndBounds = cell(2,4);

fieldsAndBounds(1,:)  = { 'timestamps'; '> 54500'; '< 70000'; []};   % 2/4/2008 to 7/13/2050
fieldsAndBounds(2,:)  = { 'uncertainties'; '>= 0'; []; []};          % TBD

nStructures = length(pdcInputDataStruct.ancillaryPipelineDataStruct);
nStructures = min(nStructures, 1);
suppressDisplayFlag = true;

for j = 1 : nStructures
    lowLevelStructName =  ['pdcInputDataStruct.ancillaryPipelineDataStruct(' num2str(j) ')'];

    assign_illegal_value_and_test_for_failure(pdcInputDataStruct.ancillaryPipelineDataStruct(j), ...
        lowLevelStructName, pdcInputDataStruct, 'pdcInputDataStruct', 'pdcDataClass', ...
        fieldsAndBounds, quickAndDirtyCheckFlag, suppressDisplayFlag);
end

clear fieldsAndBounds

%--------------------------------------------------------------------------
% Second level validation.
% Assign invalid fields and check for failures in pdcInputDataStruct.targetDataStruct.
%--------------------------------------------------------------------------
fieldsAndBounds = cell(6,4);

fieldsAndBounds(1,:)  = { 'keplerId'; '> 0'; '< 1e9'; []};
fieldsAndBounds(2,:)  = { 'keplerMag'; '> 0'; '< 20'; []};
fieldsAndBounds(3,:)  = { 'fluxFractionInAperture'; '>= 0'; '<= 1'; []};
fieldsAndBounds(4,:)  = { 'crowdingMetric'; '>= 0'; '<= 1'; []};
fieldsAndBounds(5,:)  = { 'values'; '>= 0'; '< 1e12'; []};
fieldsAndBounds(6,:)  = { 'uncertainties'; '>= 0'; '< 1e7'; []};

pdcInputDataStruct.attitudeSolutionStruct.covarianceMatrix11 = 0;
pdcInputDataStruct.attitudeSolutionStruct.covarianceMatrix22 = 0;
pdcInputDataStruct.attitudeSolutionStruct.covarianceMatrix33 = 0;
pdcInputDataStruct.attitudeSolutionStruct.covarianceMatrix12 = 0;
pdcInputDataStruct.attitudeSolutionStruct.covarianceMatrix13 = 0;
pdcInputDataStruct.attitudeSolutionStruct.covarianceMatrix23 = 0;

nStructures = length(pdcInputDataStruct.targetDataStruct);
suppressDisplayFlag = true;
nStructures = min(nStructures, 1);
for j = 1 : nStructures
    lowLevelStructName =  ['pdcInputDataStruct.targetDataStruct(' num2str(j) ')'];

    assign_illegal_value_and_test_for_failure(pdcInputDataStruct.targetDataStruct(j), ...
        lowLevelStructName, pdcInputDataStruct, 'pdcInputDataStruct', 'pdcDataClass', ...
        fieldsAndBounds, quickAndDirtyCheckFlag, suppressDisplayFlag);
end

clear fieldsAndBounds

% Return.
return
