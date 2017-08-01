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
%      run(text_test_runner, testHgnDataClass('test_validate_inputs_range_fail_case'));
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

% Set path to unit test inputs.
initialize_soc_variables;
path = fullfile(socTestDataRoot, 'gar', 'unit-tests', 'hgn');

matFileName = 'HgnInputs.mat';
binFileName = 'HgnInputs-0.bin';
fullMatFileName = fullfile(path, matFileName);
fullBinFileName = fullfile(path, binFileName);

% Define variables.
quickAndDirtyCheckFlag = false;

% Generate the input structure by one of the following methods:

% (1) Create the input structure hgnDataStruct
% [hgnDataStruct] = generate_hgn_test_data;

% (2) Load a previously generated test data structure hgnDataStruct
load(fullMatFileName, 'hgnDataStruct');

% (3) Read a test data structure hgnDataStruct from a previously
%     generated bin file
% [hgnDataStruct] = read_HgnInputs(fullBinFileName);


%--------------------------------------------------------------------------
% Top level validation.
% Assign invalid fields and check for failures in hgnDataStruct.
%
% If fields are structures, they are not included here (they are validated
% within the hgnDataClass, and also tested for missing fields in
% test_validate_missing_inputs).
%--------------------------------------------------------------------------
fieldsAndBounds = cell(6,4);
%fieldsAndBounds(1,:)  = { 'hgnModuleParameters'; []; []; []};
%fieldsAndBounds(2,:)  = { 'fcConstants'; []; []; []};
fieldsAndBounds(1,:)  = { 'ccdModule'; '>= 2'; '<= 24'; []};
fieldsAndBounds(2,:)  = { 'ccdOutput'; '>= 1'; '<= 4'; []};
fieldsAndBounds(3,:)  = { 'invocationCadenceStart'; '> -2^20'; '< 2^20'; []};  % for now
fieldsAndBounds(4,:)  = { 'invocationCadenceEnd'; '> -2^20'; '< 2^20'; []};    % for now
fieldsAndBounds(5,:)  = { 'firstMatlabInvocation'; '>= 0'; '<= 1'; []};
%fieldsAndBounds(6,:)  = { 'requantTable'; []; []; []};
%fieldsAndBounds(7,:)  = { 'cadencePixels'; []; []; []};
fieldsAndBounds(6,:)  = { 'debugFlag'; '>= 0'; '<= 3'; []};  % 3 levels max

assign_illegal_value_and_test_for_failure(hgnDataStruct, 'hgnDataStruct', ...
    hgnDataStruct, 'hgnDataStruct', 'hgnDataClass', fieldsAndBounds, ...
    quickAndDirtyCheckFlag);

clear fieldsAndBounds

%--------------------------------------------------------------------------
% Second level validation.
% Assign invalid fields and check for failures in hgnDataStruct.hgnModuleParameters.
%--------------------------------------------------------------------------
fieldsAndBounds = cell(1,4);
fieldsAndBounds(1,:)  = { 'baselineIntervals'; '>= 2'; '<= 336'; []};  % 1 week max

assign_illegal_value_and_test_for_failure(hgnDataStruct.hgnModuleParameters, ...
    'hgnDataStruct.hgnModuleParameters', hgnDataStruct, 'hgnDataStruct', ...
    'hgnDataClass', fieldsAndBounds, quickAndDirtyCheckFlag);

clear fieldsAndBounds

%--------------------------------------------------------------------------
% Second level validation.
% Assign invalid fields and check for failures in hgnDataStruct.requantTable.
%--------------------------------------------------------------------------
fieldsAndBounds = cell(4,4);
fieldsAndBounds(1,:)  = { 'externalId'; '>= 0'; '<= 255'; []};  % 1 byte
fieldsAndBounds(2,:)  = { 'startMjd'; '> 54500'; '< 70000'; []}; %  2/4/2008 to 7/13/2050
fieldsAndBounds(3,:)  = { 'requantEntries'; '>= 0'; '< 2^23'; []}; %  23 bits max
fieldsAndBounds(4,:)  = { 'meanBlackEntries'; '>= 0'; '< 2^23'; []}; %  23 bits max

assign_illegal_value_and_test_for_failure(hgnDataStruct.requantTable, ...
    'hgnDataStruct.requantTable', hgnDataStruct, 'hgnDataStruct', ...
    'hgnDataClass', fieldsAndBounds, quickAndDirtyCheckFlag);

clear fieldsAndBounds

%--------------------------------------------------------------------------
% Second level validation.
% Assign invalid fields and check for failures in hgnDataStruct.cadencePixels.
%--------------------------------------------------------------------------
fieldsAndBounds = cell(3,4);
fieldsAndBounds(1,:)  = { 'cadence'; '> -2^20'; '< 2^20'; []};  % for now
fieldsAndBounds(2,:)  = { 'pixelValues'; '>= 0'; '< 2^23'; []};
fieldsAndBounds(3,:)  = { 'gapIndicators'; '>= 0'; '<= 1'; []};

nStructures = length(hgnDataStruct.cadencePixels);
fprintf('\n');
fprintf('Checking for illegal data range in structure in %d of hgnDataStruct.cadencePixels....(display suppressed)\n', ...
    nStructures);

quickAndDirtyCheckFlag = true;
suppressDisplayFlag = true;

for j = 1 : nStructures

    lowLevelStructName =  ['hgnDataStruct.cadencePixels(' num2str(j) ')'];

    assign_illegal_value_and_test_for_failure(hgnDataStruct.cadencePixels(j), ...
        lowLevelStructName, hgnDataStruct, 'hgnDataStruct', 'hgnDataClass', ...
        fieldsAndBounds, quickAndDirtyCheckFlag, suppressDisplayFlag);
    
end

clear fieldsAndBounds

% Return.
return
