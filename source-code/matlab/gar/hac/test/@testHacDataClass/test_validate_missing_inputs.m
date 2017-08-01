function [self] = test_validate_missing_inputs(self)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% [self] = test_validate_missing_inputs(self)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% This test checks whether the class constructor catches the missing field and
% throws an error.  This test calls remove_field_and_test_for_failure.
%
%
%  Example
%  =======
%  Use a test runner to run the test method:
%      run(text_test_runner, testHacDataClass('test_validate_missing_inputs'));
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
path = fullfile(socTestDataRoot, 'gar', 'unit-tests', 'hac');

matFileName = 'HacInputs.mat';
binFileName = 'HacInputs-0.bin';
fullMatFileName = fullfile(path, matFileName);
fullBinFileName = fullfile(path, binFileName);

% Define variables.
quickAndDirtyCheckFlag = false;

% Generate the input structure by one of the following methods:

% (1) Create the input structure hacDataStruct
% [hacDataStruct] = generate_hac_test_data;

% (2) Load a previously generated test data structure hacDataStruct
load(fullMatFileName, 'hacDataStruct');

% (3) Read a test data structure hacDataStruct from a previously
%     generated bin file
% [hacDataStruct] = read_HacInputs(fullBinFileName);


%--------------------------------------------------------------------------
% Top level validation.
% Remove fields and check for failures in hacDataStruct. Do not check if
% debugFlag is missing because it is optional (default = 0 if not specified).
%--------------------------------------------------------------------------
fieldsAndBounds = cell(7,4);
fieldsAndBounds(1,:)  = { 'fcConstants'; []; []; []};
fieldsAndBounds(2,:)  = { 'invocationCcdModule'; '>= 2'; '<= 24'; []};
fieldsAndBounds(3,:)  = { 'invocationCcdOutput'; '>= 1'; '<= 4'; []};
fieldsAndBounds(4,:)  = { 'cadenceStart'; '> - 2^20'; '< 2^20'; []};  % for now
fieldsAndBounds(5,:)  = { 'cadenceEnd'; '> -2^20'; '< 2^20'; []};     % for now
fieldsAndBounds(6,:)  = { 'firstMatlabInvocation'; '>= 0'; '<= 1'; []};
fieldsAndBounds(7,:)  = { 'histograms'; []; []; []};
%fieldsAndBounds(8,:)  = { 'debugFlag'; '>= 0'; '<= 3'; []};  % 3 levels max

% Template:
% remove_field_and_test_for_failure(lowLevelStructure, lowLevelStructName, topLevelStructure, ...
% topLevelStructName, className, inputFields, quickAndDirtyCheckFlag, suppressDisplayFlag)

remove_field_and_test_for_failure(hacDataStruct, 'hacDataStruct', hacDataStruct, ...
    'hacDataStruct', 'hacDataClass', fieldsAndBounds, quickAndDirtyCheckFlag);

clear fieldsAndBounds

%--------------------------------------------------------------------------
% Second level validation.
% Remove fields and check for failures in hacDataStruct.histograms.
%--------------------------------------------------------------------------
fieldsAndBounds = cell(5,4);
fieldsAndBounds(1,:)  = { 'baselineInterval'; '>= 2'; '<= 336'; []}; % 1 week max
fieldsAndBounds(2,:)  = { 'uncompressedBaselineOverheadRate'; '>= 0'; []; []};
fieldsAndBounds(3,:)  = { 'theoreticalCompressionRate'; '>= 0'; []; []};
fieldsAndBounds(4,:)  = { 'totalStorageRate'; '>= 0'; []; []};
fieldsAndBounds(5,:)  = { 'histogram'; '>= 0'; '< 2^32'; []};

remove_field_and_test_for_failure(hacDataStruct.histograms, ...
    'hacDataStruct.histograms', hacDataStruct, 'hacDataStruct', ...
    'hacDataClass', fieldsAndBounds, quickAndDirtyCheckFlag);

clear fieldsAndBounds

% Return.
return
