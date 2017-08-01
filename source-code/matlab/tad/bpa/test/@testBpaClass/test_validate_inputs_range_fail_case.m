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

bpaParameterStruct = setup_valid_bpa_test_struct();
% convert the input completeOutputImage field from a java <array <array>>
% to a 2D matlab array
bpaParameterStruct.moduleOutputImage = ...
    struct_to_array2D(bpaParameterStruct.moduleOutputImage);

% set up input structure for the bpaConfigurationStruct
testBpaConfigFields = cell(9,5);
% each cell row contains the following:
% {fieldName;   Nan;    Inf;    out of left bound;  out of right bound}
testBpaConfigFields(1,:) = {'nLinesRow'; aNaN; anInf; -1; 1130};
testBpaConfigFields(2,:) = {'nLinesCol'; aNaN; anInf; -1; 1130};
testBpaConfigFields(3,:) = {'nEdge'; aNaN; anInf; -1; 1030};
testBpaConfigFields(4,:) = {'edgeFraction'; aNaN; anInf; -1; 0.8};
testBpaConfigFields(5,:) = {'lineStartRow'; aNaN; anInf; -1; 1210};
testBpaConfigFields(6,:) = {'lineEndRow'; aNaN; anInf; -1; 1210};
testBpaConfigFields(7,:) = {'lineStartCol'; aNaN; anInf; -1; 1210};
testBpaConfigFields(8,:) = {'lineEndCol'; aNaN; anInf; -1; 1210};
testBpaConfigFields(9,:) = {'histBinSize'; aNaN; anInf; -1; 2e6};
testImageFields(1,:) = {'moduleOutputImage'; aNaN; anInf; -1; 2e10};

test_range(testBpaConfigFields, bpaParameterStruct, 'bpaConfigurationStruct', []);
test_range(testImageFields, bpaParameterStruct, 'moduleOutputImage', [400, 200]);

function test_range(testFields, bpaParameterStruct, subStructName, index)
% if subStructName = [] then we are testing the fields of
% bpaParameterStruct.
% if subStructName is not empty then we are testing the fields of
% bpaParameterStruct.subStructName.
% if index is not empty we are testing the fields in 
% bpaParameterStruct.subStructName[index].
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
        bpaData = bpaParameterStruct;
        if(~isempty(testFields{j,k+1})) % for some parameters, need to check only one bound (either <= or >= some value)
            % now set the jth field value to out of bounds value and test whether the constructor catches the error

            if isempty(subStructName) % testing the top level structure
                bpaData.(testFields{j,1}) = testFields{j,k+1};
            else
                if isempty(index) % if there is no index
                    bpaData.(subStructName).(testFields{j,1}) = testFields{j,k+1};
                else % there is an index on the sub-structure
                    bpaData.(subStructName)(index(1), index(2)) = testFields{j,k+1};
                end
            end;

            caughtErrorFlag = 0;
            try
                bpaObject = bpaClass(bpaData);
            catch
                % test passed, input validation failed
                err = lasterror;
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

