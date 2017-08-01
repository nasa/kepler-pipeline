function self = test_validate_missing_inputs(self)
% self = test_validate_missing_inputs(self)                 %Ran 1 test in 26.394s
%
% This test checks whether the class constructor catches the missing field and
% throws an error.  This test calls remove_field_and_test_for_failure.
%
%
%  Example
%  =======
%  Use a test runner to run the test method:
%         Example: run(text_test_runner, testRptsClass('test_validate_missing_inputs'));
%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%  SOC_REQ_MAP: Req#, M.<TEST_CASE_NAME>, CERTIFIED <SVN_REV_#>
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

% generate the inputs structure by one of the following methods:

% (1) create the input structure rptsInputStruct (which is saved as inputs.mat)
% [rptsInputStruct, rptsObject] = generate_rpts_test_data;

% (2) load the previously generated test data structure rptsInputStruct
% load /path/to/matlab/tad/rpts/sample_data/inputs.mat rptsInputStruct;
load /path/to/matlab/tad/rpts/inputs.mat rptsInputStruct;

% (3) or load the previously generated bin file
% inputFileName = '/path/to/java/tad/rpts/inputs-9.bin';
% rptsInputStruct = read_RptsInputs(inputFileName);

%--------------------------------------------------------------------------
% top level validation
% remove fields and check for failures in rptsInputStruct
%--------------------------------------------------------------------------

fieldsAndBounds = cell(6, 4);
fieldsAndBounds(1,:)  = { 'moduleOutputImage'; []; []; []};
fieldsAndBounds(2,:)  = { 'stellarApertures'; []; []; []};
fieldsAndBounds(3,:)  = { 'dynamicRangeApertures'; []; []; []};
fieldsAndBounds(4,:)  = { 'existingMasks'; []; []; []};
fieldsAndBounds(5,:)  = { 'rptsModuleParametersStruct'; []; []; []};
fieldsAndBounds(6,:)  = { 'debugFlag'; '>= 0'; '<= 1'; []};

% template:
% remove_field_and_test_for_failure(lowLevelStructure, lowLevelStructName, topLevelStructure,
% topLevelStructName, className, inputFields, quickAndDirtyCheckFlag, suppressDisplayFlag)

remove_field_and_test_for_failure(rptsInputStruct, 'rptsInputStruct', rptsInputStruct, ...
    'rptsInputStruct', 'rptsClass', fieldsAndBounds);

clear fieldsAndBounds
%--------------------------------------------------------------------------
% second level validation
% remove fields and check for failures in rptsInputStruct.rptsModuleParametersStruct
%--------------------------------------------------------------------------

fieldsAndBounds = cell(9, 4);
fieldsAndBounds(1,:)  = { 'nHaloRings'; '>= 0'; '<= 100'; []};
fieldsAndBounds(2,:)  = { 'radiusForBackgroundPixelSelection'; '>= 0'; '<= 2000'; []};
fieldsAndBounds(3,:)  = { 'nBackgroundPixelsPerStellarTarget'; '>= 0'; '<= 2000'; []};
fieldsAndBounds(4,:)  = { 'smearRows'; []; []; [1:20, 1045:1070]};
fieldsAndBounds(5,:)  = { 'blackColumns'; []; []; [1:12, 1113:1132]};
fieldsAndBounds(6,:)  = { 'backgroundModeThresh'; '>= 0'; '<= 100'; []};
fieldsAndBounds(7,:)  = { 'smearNoiseRatioThresh'; '>= 0'; '<= 100'; []};
fieldsAndBounds(8,:)  = { 'readNoiseSquared'; '>= 0'; '<= 1e6'; []};
fieldsAndBounds(9,:)  = { 'exposuresPerCadence'; '>= 0'; '<= 2000'; []};

remove_field_and_test_for_failure(rptsInputStruct.rptsModuleParametersStruct, 'rptsInputStruct.rptsModuleParametersStruct',...
    rptsInputStruct, 'rptsInputStruct', 'rptsClass', fieldsAndBounds);

clear fieldsAndBounds
%--------------------------------------------------------------------------
% second level validation
% remove fields and check for failures in rptsInputStruct.moduleOutputImage

fieldsAndBounds = cell(1, 4);
fieldsAndBounds(1,:)  = { 'array'; '>= 0'; '< 1e10'; []};

remove_field_and_test_for_failure(rptsInputStruct.moduleOutputImage, 'rptsInputStruct.moduleOutputImage', ...
    rptsInputStruct,'rptsInputStruct', 'rptsClass', fieldsAndBounds);

clear fieldsAndBounds
%--------------------------------------------------------------------------
% second level validation
% remove fields and check for failures in rptsInputStruct.stellarApertures


% run test only if input stellar apertures is non-empty struct array
if (~isempty(rptsInputStruct.stellarApertures))

    fieldsAndBounds = cell(5, 4);
    fieldsAndBounds(1,:)  = { 'keplerId'; '> 0'; '< 1e9'; []};
    fieldsAndBounds(2,:)  = { 'badPixelCount';  '>= 0'; '< 1e9'; []};
    fieldsAndBounds(3,:)  = { 'referenceRow';  '>= 0'; '<= 1070'; []};
    fieldsAndBounds(4,:)  = { 'referenceColumn';  '>= 0'; '<= 1132'; []};
    fieldsAndBounds(5,:)  = { 'offsets'; []; []; []};

    remove_field_and_test_for_failure(rptsInputStruct.stellarApertures, ...
        'rptsInputStruct.stellarApertures', rptsInputStruct,'rptsInputStruct', 'rptsClass', fieldsAndBounds);

    clear fieldsAndBounds
    %--------------------------------------------------------------------------
    % third level validation
    % remove fields and check for failures in rptsInputStruct.stellarApertures.offsets

    fieldsAndBounds = cell(2, 4);
    fieldsAndBounds(1,:)  = { 'row'; '> -2^15'; '< 2^15'; []};
    fieldsAndBounds(2,:)  = { 'column'; '> -2^15'; '< 2^15'; []};

    kStructs = length(rptsInputStruct.stellarApertures);

    quickAndDirtyCheckFlag = true;
    suppressDisplayFlag = true;
    fprintf('\nChecking for missing fields in offsets structure in %d rptsInputStruct.stellarApertures....(display suppressed)\n', kStructs);

    for i = 1:kStructs

        lowLevelStructName =  ['rptsInputStruct.stellarApertures(' num2str(i) ').offsets'];

        remove_field_and_test_for_failure(rptsInputStruct.stellarApertures(i).offsets, ...
            lowLevelStructName, rptsInputStruct, 'rptsInputStruct', 'rptsClass', ...
            fieldsAndBounds, quickAndDirtyCheckFlag, suppressDisplayFlag);
    end

    clear fieldsAndBounds
end
%--------------------------------------------------------------------------
% second level validation
% remove fields and check for failures in rptsInputStruct.dynamicRangeApertures

% run test only if input dynamic range apertures is non-empty struct array
if (~isempty(rptsInputStruct.dynamicRangeApertures))

    fieldsAndBounds = cell(5, 4);
    fieldsAndBounds(1,:)  = { 'keplerId'; '> 0'; '< 1e9'; []};
    fieldsAndBounds(2,:)  = { 'badPixelCount';  '>= 0'; '< 1e9'; []};
    fieldsAndBounds(3,:)  = { 'referenceRow';  '>= 0'; '<= 1070'; []};
    fieldsAndBounds(4,:)  = { 'referenceColumn';  '>= 0'; '<= 1132'; []};
    fieldsAndBounds(5,:)  = { 'offsets'; []; []; []};

    remove_field_and_test_for_failure(rptsInputStruct.dynamicRangeApertures, ...
        'rptsInputStruct.dynamicRangeApertures', rptsInputStruct,'rptsInputStruct', 'rptsClass', fieldsAndBounds);

    clear fieldsAndBounds
    %--------------------------------------------------------------------------
    % third level validation
    % remove fields and check for failures in rptsInputStruct.dynamicRangeApertures.offsets

    fieldsAndBounds = cell(2, 4);
    fieldsAndBounds(1,:)  = { 'row'; '> -2^15'; '< 2^15'; []};
    fieldsAndBounds(2,:)  = { 'column'; '> -2^15'; '< 2^15'; []};

    kStructs = length(rptsInputStruct.dynamicRangeApertures);

    quickAndDirtyCheckFlag = true;
    suppressDisplayFlag = true;
    fprintf('\nChecking for missing fields in offsets structure in %d rptsInputStruct.dynamicRangeApertures....(display suppressed)\n', kStructs);

    for i = 1:kStructs

        lowLevelStructName =  ['rptsInputStruct.dynamicRangeApertures(' num2str(i) ').offsets'];

        remove_field_and_test_for_failure(rptsInputStruct.dynamicRangeApertures(i).offsets, ...
            lowLevelStructName, rptsInputStruct, 'rptsInputStruct', 'rptsClass', ...
            fieldsAndBounds, quickAndDirtyCheckFlag, suppressDisplayFlag);
    end

    clear fieldsAndBounds;
end
%--------------------------------------------------------------------------
% second level validation
% remove fields and check for failures in rptsInputStruct.existingMasks

fieldsAndBounds = cell(1, 4);
fieldsAndBounds(1,:)  = { 'offsets'; []; []; []};

remove_field_and_test_for_failure(rptsInputStruct.existingMasks, ...
    'rptsInputStruct.existingMasks', rptsInputStruct,'rptsInputStruct', 'rptsClass', fieldsAndBounds);

clear fieldsAndBounds
%--------------------------------------------------------------------------
% third level validation
% remove fields and check for failures in rptsInputStruct.existingMasks.offsets

fieldsAndBounds = cell(2, 4);
fieldsAndBounds(1,:)  = { 'row'; '> -2^15'; '< 2^15'; []};
fieldsAndBounds(2,:)  = { 'column'; '> -2^15'; '< 2^15'; []};

kStructs = length(rptsInputStruct.existingMasks);

quickAndDirtyCheckFlag = true;
suppressDisplayFlag = true;
fprintf('\nChecking for missing fields in offsets structure in %d rptsInputStruct.existingMasks....(display suppressed)\n', kStructs);

for i = 1:kStructs
    lowLevelStructName =  ['rptsInputStruct.existingMasks(' num2str(i) ').offsets'];

    remove_field_and_test_for_failure(rptsInputStruct.existingMasks(i).offsets, ...
        lowLevelStructName, rptsInputStruct, 'rptsInputStruct', 'rptsClass', ...
        fieldsAndBounds, quickAndDirtyCheckFlag, suppressDisplayFlag);
end

clear fieldsAndBounds;
return