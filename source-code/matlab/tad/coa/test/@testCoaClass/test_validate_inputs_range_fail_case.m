function self = test_validate_inputs_range_fail_case(self)
%test_validate_missing_inputs checks whether the class
% constructor catches the missing field and throws an error
%
% the various fields and their values are described in coaClass.m
% here we test values outside the ranges specified in coaClass.m
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

aNaN = NaN; % generate a NaN
anInf = Inf; % generate an Inf

coaParameterStruct = setup_valid_coa_test_struct();

% earlyDate = datestr2mjd('01-Jan-1998');
% lateDate = datestr2mjd('01-Jan-2130');
earlyDate = '01-Jan-1998';
lateDate = '01-Jan-2130';
% set up input structure for the coa level
testCoaFields = cell(3,5);
% each cell row contains the following:
% {fieldName;   Nan;    Inf;    out of left bound;  out of right bound}
testCoaFields(1,:) = {'module'; aNaN; anInf; -1; 140};
testCoaFields(2,:) = {'output'; aNaN; anInf; -1; 7};
testCoaFields(3,:) = {'debugFlag'; aNaN; anInf; []; []};

testKICFields = cell(4,5);
% each cell row contains the following:
% {fieldName;   Nan;    Inf;    out of left bound;  out of right bound}
testKICFields(1,:) = {'KICID'; aNaN; anInf; -1; 1e15};
testKICFields(2,:) = {'RA'; aNaN; anInf; -1; 40};
testKICFields(3,:) = {'dec'; aNaN; anInf; -100; 100};
testKICFields(4,:) = {'magnitude'; aNaN; anInf; -20; 150};

% set up input structure for the pixelModelStruct
testPixFields = cell(11,5);
% each cell row contains the following:
% {fieldName;   Nan;    Inf;    out of left bound;  out of right bound}
testPixFields(1,:) = {'wellCapacity'; aNaN; anInf; -1; []};
testPixFields(2,:) = {'saturationSpillUpFraction'; aNaN; anInf; -1; 1.5};
testPixFields(3,:) = {'flux12'; aNaN; anInf; -1; []};
testPixFields(4,:) = {'cadenceTime'; aNaN; anInf; 1e-4; 1e6};
testPixFields(5,:) = {'integrationTime'; aNaN; anInf; -1; 1e6};
testPixFields(6,:) = {'transferTime'; aNaN; anInf; -1; 1e6};
testPixFields(7,:) = {'exposuresPerCadence'; aNaN; anInf; -1; 2500};
testPixFields(8,:) = {'parallelCTE'; aNaN; anInf; -1; 3};
testPixFields(9,:) = {'serialCTE'; aNaN; anInf; -1; 3};
testPixFields(10,:) = {'readNoiseSquared'; aNaN; anInf; -1; 3e8};
testPixFields(11,:) = {'quantizationNoiseSquared'; aNaN; anInf; -1; 3e6};

% set up input structure for the moduleDescriptionStruct
testModFields = cell(6,5);
% each cell row contains the following:
% {fieldName;   Nan;    Inf;    out of left bound;  out of right bound}
testModFields(1,:) = {'nRowPix'; aNaN; anInf; 800; 2500};
testModFields(2,:) = {'nColPix'; aNaN; anInf; 800; 2500};
testModFields(3,:) = {'leadingBlack'; aNaN; anInf; -3; 120};
testModFields(4,:) = {'trailingBlack'; aNaN; anInf; -3; 120};
testModFields(5,:) = {'virtualSmear'; aNaN; anInf; -3; 120};
testModFields(6,:) = {'maskedSmear'; aNaN; anInf; -3; 120};

% set up input structure for the coaConfigurationStruct
testCoaConfigFields = cell(13,5);
% each cell row contains the following:
% {fieldName;   Nan;    Inf;    out of left bound;  out of right bound}
testCoaConfigFields(1,:) = {'dvaMeshEdgeBuffer'; aNaN; anInf; -222; 231};
testCoaConfigFields(2,:) = {'dvaMeshOrder'; aNaN; anInf; -1; 23};
testCoaConfigFields(3,:) = {'nDvaMeshRows'; aNaN; anInf; 0; 231};
testCoaConfigFields(4,:) = {'nDvaMeshCols'; aNaN; anInf; 0; 231};
testCoaConfigFields(5,:) = {'nOutputBufferPix'; aNaN; anInf; -222; 231};
testCoaConfigFields(6,:) = {'nStarImageRows'; aNaN; anInf; -3; 1230};
testCoaConfigFields(7,:) = {'nStarImageCols'; aNaN; anInf; -3; 1230};
testCoaConfigFields(8,:) = {'starChunkLength'; aNaN; anInf; 0; 2e12};
testCoaConfigFields(9,:) = {'startTime'; []; []; earlyDate; lateDate};
testCoaConfigFields(10,:) = {'duration'; aNaN; anInf; -19; 1e6};
testCoaConfigFields(11,:) = {'raOffset'; aNaN; anInf; -19; 370};
testCoaConfigFields(12,:) = {'decOffset'; aNaN; anInf; -19; 370};
testCoaConfigFields(13,:) = {'phiOffset'; aNaN; anInf; -19; 370};

test_range(testCoaFields, coaParameterStruct, [], []);
test_range(testKICFields, coaParameterStruct, 'kicEntryDataStruct', 2);
test_range(testPixFields, coaParameterStruct, 'pixelModelStruct', []);
test_range(testModFields, coaParameterStruct, 'moduleDescriptionStruct', []);
test_range(testCoaConfigFields, coaParameterStruct, 'coaConfigurationStruct', []);

test_date_string(coaParameterStruct, 'ss - rjsk', 'datevec');
test_date_string(coaParameterStruct, 0, 'rangeCheck');

function test_range(testFields, coaParameterStruct, subStructName, index)
% if subStructName = [] then we are testing the fields of
% coaParameterStruct.
% if subStructName is not empty then we are testing the fields of
% coaParameterStruct.subStructName.
% if index is not empty we are testing the fields in 
% coaParameterStruct.subStructName[index].
% there are four different range checking
% (1) checking for NaN
% (2) checking for Inf
% (3) checking for value outside the left bound
% (4) checking for value outside the right bound
% (5) for guard bands alone: a sum check
nFields = size(testFields, 1);
nChecks = size(testFields, 2) - 1;
for k=1:nChecks

    for j=1:nFields

        % copy the original structure with valid inputs
        coaData = coaParameterStruct;
        if(~isempty(testFields{j,k+1})) % for some parameters, need to check only one bound (either <= or >= some value)
            % now set the jth field value to out of bounds value and test whether the constructor catches the error

            if isempty(subStructName) % testing the top level structure
                coaData.(testFields{j,1}) = testFields{j,k+1};
            else
                if isempty(index) % if there is no index
                    coaData.(subStructName).(testFields{j,1}) = testFields{j,k+1};
                else % there is an index on the sub-structure
                    coaData.(subStructName)(index).(testFields{j,1}) = testFields{j,k+1};
                end
            end;

            caughtErrorFlag = 0;
            try
                coaObject = coaClass(coaData);
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

function test_date_string(coaParameterStruct, string, errorID)
% special test for the date string to make sure the right error is thrown
% when the date string is garbage
coaData = coaParameterStruct;
coaData.startTime = string; 
caughtErrorFlag = 0;
try
    coaObject = coaClass(coaData);
catch
    % test passed, input validation failed
    err = lasterror;
    % check to see whether the correct exception/error was
    % thrown
    % parse the string and look for 'rangeCheck' and the name
    % of the field
    if(isempty(findstr(err.identifier, errorID)))
        assert_equals(errorID,err.identifier,'date string: Wrong type of error thrown!');
    end;
    caughtErrorFlag = 1;
%                 print_error(err, 'range check test');    
end;
if(~caughtErrorFlag)
    % test failed, input validation did not catch the error
    % optional message is printed only when assert fails
    assert_equals(1,0, 'date string: Validation failed to catch the error..');
end

function test_odd(testFields, coaParameterStruct, subStructName)
% check that constructor fails when parameters that must be odd are even
% if subStructName = [] then we are testing the fields of
% coaParameterStruct.
% if subStructName is not empty then we are testing the fields of
% coaParameterStruct.subStructName.
nFields = size(testFields, 1);
for j=1:nFields
    % copy the original structure with valid inputs
    coaData = coaParameterStruct;
    if isempty(subStructName) % testing the top level structure
        coaData.(testFields{j,1}) = testFields{j,2};
    else
        if isempty(index) % if there is no index
            coaData.(subStructName).(testFields{j,1}) = testFields{j,2};
        else % there is an index on the sub-structure
            coaData.(subStructName)(index).(testFields{j,1}) = testFields{j,2};
        end
    end;

    caughtErrorFlag = 0;
    try
        coaObject = coaClass(coaData);
    catch
        % test passed, input validation failed
        err = lasterror;
        % check to see whether the correct exception/error was
        % thrown
        % parse the string and look for 'rangeCheck' and the name
        % of the field
        if(isempty(findstr(err.identifier, 'notOdd')))
            assert_equals('notOdd',err.identifier,'Wrong type of error thrown!');
        else
            if(isempty(findstr(err.identifier,testFields{j,1})))
                assert_equals(testFields{j,1},err.identifier,'Wrong field identified as a missing field' );
            end;
        end;
        caughtErrorFlag = 1;
    end;
    if(~caughtErrorFlag)
        % test failed, input validation did not catch the error
        % optional message is printed only when assert fails
        assert_equals(1,0, 'Validation failed to catch the error..');
    end
end;
