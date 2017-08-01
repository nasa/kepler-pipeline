function self = test_validate_inputs_range_fail_case(self)
%test_validate_missing_inputs checks whether the class
% constructor catches the missing field and throws an error
%
%
%  Example
%  =======
%  Use a test runner to run the test method:
%         Example: run(text_test_runner, test_sin('test_null'));
% 
% Copyright 2017 United States Government as represented by the
% Administrator of the National Aeronautics and Space Administration.
% All Rights Reserved.
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

aNaN = NaN; % generate a NaN
anInf = Inf; % generate an Inf

amaParameterStruct = setup_valid_ama_test_struct();

testMaskTableRowFields = cell(2,5);
% each cell row contains the following:
% {fieldName;   Nan;    Inf;    out of left bound;  out of right bound}
testTableRowFields(1,:) = {'row'; aNaN; anInf; -1300; 1300};
testTableRowFields(2,:) = {'column'; aNaN; anInf; -1300; 1300};

testApertureTableRowFields = cell(3,5);
% each cell row contains the following:
% {fieldName;   Nan;    Inf;    out of left bound;  out of right bound}
testApertureTableRowFields(1,:) = {'keplerId'; aNaN; anInf; -1; 2e9};
testApertureTableRowFields(2,:) = {'referenceRow'; aNaN; anInf; -1; 1300};
testApertureTableRowFields(3,:) = {'referenceColumn'; aNaN; anInf; -1; 1300};

test_range(testTableRowFields, amaParameterStruct, 'maskDefinitions', 'offsets', 2);
test_range(testApertureTableRowFields, amaParameterStruct, [], 'apertureStructs', 2);
test_range(testTableRowFields, amaParameterStruct, 'apertureStructs', 'offsets', 2);

function test_range(testFields, ParameterStruct, midStructs, subStructName, index)
% if subStructName = [] then we are testing the fields of
% amaParameterStruct.
% if subStructName is not empty then we are testing the fields of
% amaParameterStruct.subStructName.
% if index is not empty we are testing the fields in 
% amaParameterStruct.subStructName[index].
% there are four different range checks
% (1) checking for NaN
% (2) checking for Inf
% (3) checking for value outside the left bound
% (4) checking for value outside the right bound
nFields = size(testFields, 1);
nChecks = size(testFields, 2) - 1;
for k=1:nChecks
    for j=1:nFields
        % copy the original structure with valid inputs
        amaData = ParameterStruct;
        if(~isempty(testFields{j,k+1})) % for some parameters, need to check only one bound (either <= or >= some value)
            % now set the jth field value to out of bounds value and test whether the constructor catches the error

            if isempty(subStructName) && isempty(midStructs) % testing the top level structure
                amaData.(testFields{j,1}) = testFields{j,k+1};
            elseif isempty(midStructs) % testing the top level structure
                if isempty(index) % if there is no index
                    amaData.(testFields{j,1}).(subStructName).(testFields{j,1}) = testFields{j,k+1};
                else % there is an index on the sub-structure
                    amaData.(subStructName)(index).(testFields{j,1}) = testFields{j,k+1};
                end
            else
                if isempty(index) % if there is no index
                    amaData.(midStructs).(testFields{j,1}) = testFields{j,k+1};
                else % there is an index on the sub-structure
                    amaData.(midStructs)(index).(subStructName)(index).(testFields{j,1}) = testFields{j,k+1};
                end
            end;

            caughtErrorFlag = 0;
            try
                amaObject = amaClass(amaData);
            catch
                % test passed, input validation failed
                err = lasterror;
%                 err.message
%                 err
%                 err.stack(1)
                % check to see whether the correct exception/error was
                % thrown
                % parse the string and look for 'rangeCheck' and the name
                % of the field
                if(isempty(findstr(err.identifier, 'rangeCheck')))
                    assert_equals('rangeCheck',err.identifier,'Wrong type of error thrown!');
                else
                    if(isempty(findstr(err.identifier,testFields{j,1})))
                        assert_equals(testFields{j,1},err.identifier,'Wrong field identified as a missing field' );
                    end;
                end;
                caughtErrorFlag = 1;
%                 print_error(err, 'range check test');    
            end;
            if(~caughtErrorFlag)
                % test failed, input validation did not catch the error
                % optional message is printed only when assert fails
                assert_equals(1,0, 'Validation failed to catch the error..');
            end
        end;
    end;
end;

