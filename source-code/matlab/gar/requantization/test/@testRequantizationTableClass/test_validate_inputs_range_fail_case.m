function self = test_validate_inputs_range_fail_case(self)
%test_validate_missing_inputs checks whether the class
% constructor catches the missing field and throws an error
%
%
%  Example
%  =======
%  Use a test runner to run the test method:
%         Example: run(text_test_runner, testRequantizationTableClass('test_validate_inputs_range_fail_case'));
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

% set up input structure

% Set path to unit test inputs.
initialize_soc_variables;
path = fullfile(socTestDataRoot, 'gar', 'unit-tests', 'requantization');

load(fullfile(path, 'requantizationInputStruct.mat'));

quickAndDirtyCheckFlag = true;

%------------------------------------------------------------
fieldsAndBounds = cell(7,4);
fieldsAndBounds(1,:)  = { 'guardBandHigh'; '>= 0'; '< 0.5'; []};
fieldsAndBounds(2,:)  = { 'quantizationFraction'; '> 0'; '< .5'; []};
fieldsAndBounds(3,:)  = { 'expectedSmearMaxBlackCorrectedPerReadInAdu'; '>=0'; '<= 1e3'; []};
fieldsAndBounds(4,:)  = { 'expectedSmearMinBlackCorrectedPerReadInAdu'; '>= 0'; '<=1e2'; []};
fieldsAndBounds(5,:)  = { 'rssOutOriginalQuantizationNoiseFlag'; []; []; [true, false]};
fieldsAndBounds(6,:)  = { 'inflationFactorForBufferZone'; '>= 0'; '<= 1.5'; []};
fieldsAndBounds(7,:)  = { 'debugFlag'; '>= 0'; '<= 3'; []};

assign_illegal_value_and_test_for_failure(requantizationInputStruct.requantModuleParameters, 'requantizationInputStruct.requantModuleParameters', ...
    requantizationInputStruct, ...
    'requantizationInputStruct', 'requantizationTableClass', fieldsAndBounds, quickAndDirtyCheckFlag);

clear fieldsAndBounds;
%------------------------------------------------------------
fieldsAndBounds = cell(17,4);

fieldsAndBounds(1,:)  = { 'mjd'; '> 54000'; '< 64000'; []};% use mjd
fieldsAndBounds(2,:)  = { 'millisecondsPerReadout'; '> 0'; '< 1e6'; []};
fieldsAndBounds(3,:)  = { 'integrationsPerShortCadence'; '> 0'; '< 1000' ; []};
fieldsAndBounds(4,:)  = { 'shortCadencesPerLongCadence'; '> 0'; '< 1000'; []};
fieldsAndBounds(5,:)  = { 'smearStartRow'; '>=1044' ; '<= 1069'; []}; % row,columns are 0 based
fieldsAndBounds(6,:)  = { 'smearEndRow'; '>=1044' ; '<= 1069'; []};% virtual smear region rows
fieldsAndBounds(7,:)  = { 'smearStartCol'; '>=12'; '<= 1111'; []};
fieldsAndBounds(8,:)  = { 'smearEndCol'; '>=12'; '<= 1111'; []};
fieldsAndBounds(9,:)  = { 'maskedStartRow'; '>= 0'; '<= 19'; []};% masked smear region rows
fieldsAndBounds(10,:)  = { 'maskedEndRow'; '>= 0'; '<= 19'; []}; % masked smear region rows
fieldsAndBounds(11,:)  = { 'maskedStartCol'; '>=12'; '<= 1111'; []};
fieldsAndBounds(12,:)  = { 'maskedEndCol'; '>=12'; '<= 1111'; []}; % smear columns
fieldsAndBounds(13,:)  = { 'darkStartRow'; '>= 0'; '<=1069'; []}; % dark => black
fieldsAndBounds(14,:)  = { 'darkEndRow'; '>= 0'; '<=1069'; []}; % dark => black
fieldsAndBounds(15,:)  = { 'darkStartCol'; []; [];  '[0:11, 1112:1131]''';}; % includes both leading and trailing black
fieldsAndBounds(16,:)  = { 'darkEndCol'; []; [];  '[0:11, 1112:1131]''';}; % includes both leading and trailing black
fieldsAndBounds(17,:)  = { 'requantFixedOffset'; '>=400000'; '<=420000'; []}; % max value is .05*(2^14)*512


assign_illegal_value_and_test_for_failure(requantizationInputStruct.scConfigParameters, 'requantizationInputStruct.scConfigParameters', ...
    requantizationInputStruct, ...
    'requantizationInputStruct', 'requantizationTableClass', fieldsAndBounds, quickAndDirtyCheckFlag);

clear fieldsAndBounds;

%------------------------------------------------------------
fieldsAndBounds = cell(14,4);
fieldsAndBounds(1,:)  = { 'BITS_IN_ADC'; '==14'; []; []};
fieldsAndBounds(2,:)  = { 'nRowsImaging'; '== 1024'; []; []};
fieldsAndBounds(3,:)  = { 'nColsImaging'; '== 1100'; []; []};
fieldsAndBounds(4,:)  = { 'nLeadingBlack'; '==12'; []; []};
fieldsAndBounds(5,:)  = { 'nTrailingBlack'; '==20'; []; []};
fieldsAndBounds(6,:)  = { 'nVirtualSmear'; '==26'; []; []};
fieldsAndBounds(7,:)  = { 'nMaskedSmear'; '== 20'; []; []};
fieldsAndBounds(8,:)  = { 'REQUANT_TABLE_LENGTH'; '==2^16'; []; []};
fieldsAndBounds(9,:)  = { 'REQUANT_TABLE_MIN_VALUE'; '==0'; []; []};
fieldsAndBounds(10,:)  = { 'REQUANT_TABLE_MAX_VALUE'; '==2^23-1'; []; []};
fieldsAndBounds(11,:)  = { 'MEAN_BLACK_TABLE_LENGTH'; '== 84'; []; []};
fieldsAndBounds(12,:)  = { 'MEAN_BLACK_TABLE_MIN_VALUE'; '==0'; []; []};
fieldsAndBounds(13,:)  = { 'MEAN_BLACK_TABLE_MAX_VALUE'; '==2^14-1'; []; []};
fieldsAndBounds(14,:)  = { 'MODULE_OUTPUTS'; '== 84'; []; []};


assign_illegal_value_and_test_for_failure(requantizationInputStruct.fcConstants, 'requantizationInputStruct.fcConstants', ...
    requantizationInputStruct, ...
    'requantizationInputStruct', 'requantizationTableClass', fieldsAndBounds, quickAndDirtyCheckFlag);

clear fieldsAndBounds;
%------------------------------------------------------------




return;


