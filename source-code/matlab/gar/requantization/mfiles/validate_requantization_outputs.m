function validate_requantization_outputs(requantizationOutputStruct, requantizationInputStruct)


% make use of the unit tests code to validate the output structure
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

%--------------------------------------------------------------------------
% test 1
% test_main_requantization_table_step_size checks to see whether all the
% entries in the table 'requantizationMainTableVerifyFraction'  are <=
% quantizationFraction.
%--------------------------------------------------------------------------

quantizationFraction = requantizationOutputStruct.requantizationMainStruct.quantizationFraction;

verifyTable = requantizationOutputStruct.requantizationMainTableVerifyFraction;

% All values in the verifyTable should be between 0 and
% quantizationFraction. Find any value that is not within this range (=>
% indicates invalid requantization table)
testResult = (verifyTable < 0 | verifyTable > quantizationFraction);


% we expect all the entries in the main requantization table have a stepsize
% <= quantizationFraction which guarantees that the table maintains at each
% step the ratio of quantization noise to total noise at <= quantizationFraction

if(~any(testResult)) % all zeros
    testResult = 0; % just a scalar to indicate that all entries are okay
end;

if(testResult)
    error('GAR:validateRequantizationOutputs:verifyMainTable', ...
        'validate_requantization_outputs: main requantization table failed to maintain desired ratio of requantization noise to total noise at all intervals.');
end


%--------------------------------------------------------------------------
% test 2
% test_requantization_table_length_and_first_and_last_values checks to see
% whether the first entry is 0, last entry is 2^23-1, and the table length
% is exactly 2^16
% this test also checks to see whether the meanBlackTable is an array of length
% 84 and whether the entries are within 0 and 2^14-1

%--------------------------------------------------------------------------

% check whether the first entry is 0
expectedResult = [requantizationInputStruct.fcConstants.REQUANT_TABLE_MIN_VALUE; requantizationInputStruct.fcConstants.REQUANT_TABLE_MAX_VALUE; ...
    requantizationInputStruct.fcConstants.REQUANT_TABLE_LENGTH];
testResult = [requantizationOutputStruct.requantizationTable(1);requantizationOutputStruct.requantizationTable(end); length(requantizationOutputStruct.requantizationTable)];

if(~isequal(expectedResult,testResult))
    error('GAR:validateRequantizationOutputs:verifyRequantizationTable', ...
        'validate_requantization_outputs: failure of test that checks to see whether the first entry in the table is 0, last entry is 2^23-1, and the table length is 2^16.');
end

% check to validate meanblack table

if(length(requantizationOutputStruct.meanBlackTable) ~= requantizationInputStruct.fcConstants.MEAN_BLACK_TABLE_LENGTH)
    error('GAR:validateRequantizationOutputs:verifyMeanBlackTable', ...
        ['validate_requantization_outputs: meanBlackTable length ~= ' num2str(requantizationInputStruct.fcConstants.MEAN_BLACK_TABLE_LENGTH)]);
end


testResult = (requantizationOutputStruct.meanBlackTable < requantizationInputStruct.fcConstants.MEAN_BLACK_TABLE_MIN_VALUE...
    | requantizationOutputStruct.meanBlackTable > requantizationInputStruct.fcConstants.MEAN_BLACK_TABLE_MAX_VALUE);


if(~any(testResult)) % all zeros
    testResult = 0; % just a scalar to indicate that all entries are okay
end;

if(testResult)
    error('GAR:validateRequantizationOutputs:verifyMeanBlackTable', ...
        ['validate_requantization_outputs: meanBlackTable entries are not within ' num2str([requantizationInputStruct.fcConstants.MEAN_BLACK_TABLE_MIN_VALUE ...
        requantizationInputStruct.fcConstants.MEAN_BLACK_TABLE_MAX_VALUE]) ] );
end



%--------------------------------------------------------------------------
% test 3
% this test checks to see whether the requantization table entries are
% monotonically increasing.
%--------------------------------------------------------------------------
differenceTable = diff(requantizationOutputStruct.requantizationTable);
% if all entries are positive, then monotonicity is assured!

if(any(differenceTable <= 0)) % no entry should be negative
    error('GAR:validateRequantizationOutputs:verifyRequantizationTable', ...
        'validate_requantization_outputs: Entries in the requantization table are not in strict monotonic increasing order');

end


return

