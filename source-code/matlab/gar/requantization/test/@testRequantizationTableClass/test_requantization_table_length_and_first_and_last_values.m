function self = test_requantization_table_length_and_first_and_last_values(self)
% test_requantization_table_length_and_first_and_last_values checks to see
% whether the first entry is 0, last entry is 2^23-1, and the table length is exactly 2^16
%
%  Example
%  =======
%  Use a test runner to run the test method:
%         Example: run(text_test_runner, testRequantizationTableClass('test_requantization_table_length_and_first_and_last_values'));
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
path = fullfile(socTestDataRoot, 'gar', 'unit-tests', 'requantization');

load(fullfile(path, 'requantizationInputStruct.mat'));

requantizationTableObjet = requantizationTableClass(requantizationInputStruct);

requantizationOutputStruct = generate_requantization_table(requantizationTableObjet);


% requantizationInputStruct.fcConstants
%                                 BITS_IN_ADC: 14
%                                nRowsImaging: 1024
%                                nColsImaging: 1100
%                               nLeadingBlack: 12
%                              nTrailingBlack: 20
%                               nVirtualSmear: 26
%                                nMaskedSmear: 20
%                                    CCD_ROWS: 1070
%                                 CCD_COLUMNS: 1132
%                         LEADING_BLACK_START: 0
%                           LEADING_BLACK_END: 11
%                        TRAILING_BLACK_START: 1112
%                          TRAILING_BLACK_END: 1131
%                          MASKED_SMEAR_START: 0
%                            MASKED_SMEAR_END: 19
%                         VIRTUAL_SMEAR_START: 1044
%                           VIRTUAL_SMEAR_END: 1069
%                        REQUANT_TABLE_LENGTH: 65536
%                     REQUANT_TABLE_MIN_VALUE: 0
%                     REQUANT_TABLE_MAX_VALUE: 8388607
%



% check whether the first entry is 0
expectedResult = [requantizationInputStruct.fcConstants.REQUANT_TABLE_MIN_VALUE; requantizationInputStruct.fcConstants.REQUANT_TABLE_MAX_VALUE; ...
    requantizationInputStruct.fcConstants.REQUANT_TABLE_LENGTH];
testResult = [requantizationOutputStruct.requantizationTable(1);requantizationOutputStruct.requantizationTable(end); length(requantizationOutputStruct.requantizationTable)];


% you can only check whether the indices are equal
messageOut = 'This test checks to see whether the first entry in the requantization table is 0, last entry is 2^23-1, and the table length is 2^16.';
assert_equals(expectedResult, testResult, messageOut);



% check to validate meanblack table
messageOut = ['This test checks to see whether the meanBlackTable length is equal to ' num2str(requantizationInputStruct.fcConstants.MEAN_BLACK_TABLE_LENGTH)];
expectedResult = requantizationInputStruct.fcConstants.MEAN_BLACK_TABLE_LENGTH;
testResult = length(requantizationOutputStruct.meanBlackTable);
assert_equals(expectedResult, testResult, messageOut);


testResult = (requantizationOutputStruct.meanBlackTable < requantizationInputStruct.fcConstants.MEAN_BLACK_TABLE_MIN_VALUE...
    | requantizationOutputStruct.meanBlackTable > requantizationInputStruct.fcConstants.MEAN_BLACK_TABLE_MAX_VALUE);


if(~any(testResult)) % all zeros
    testResult = 0; % just a scalar to indicate that all entries are okay
end;


expectedResult = 0;

% you can only check whether the indices are equal
messageOut = ['This test checks to see whether the meanBlackTable entries are not within ' num2str([requantizationInputStruct.fcConstants.MEAN_BLACK_TABLE_MIN_VALUE ...
    requantizationInputStruct.fcConstants.MEAN_BLACK_TABLE_MAX_VALUE])] ;
assert_equals(expectedResult, testResult, messageOut);


return