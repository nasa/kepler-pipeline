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

bppParameterStruct = setup_valid_bpp_test_struct();

% earlyDate = datestr2julian('01-Jan-1998');
% lateDate = datestr2julian('01-Jan-2130');
% set up input structure for the bpp level
testBppFields = cell(2,5);
% each cell row contains the following:
% {fieldName;   Nan;    Inf;    out of left bound;  out of right bound}
testBppFields(1,:) = {'debugFlag'; aNaN; anInf; []; []};
testBppFields(1,:) = {'cleanCosmicRays'; aNaN; anInf; -1; 2};

testBgConfigFields = cell(4,5);
% each cell row contains the following:
% {fieldName;   Nan;    Inf;    out of left bound;  out of right bound}
testBgConfigFields(1,:) = {'fitLowOrder'; aNaN; anInf; -1; 25};
testBgConfigFields(2,:) = {'fitCadenceChunkSize'; aNaN; anInf; -1; 2e9};
testBgConfigFields(3,:) = {'targetBgRemovalChunkSize'; aNaN; anInf; -1; 2e9};
testBgConfigFields(4,:) = {'fitMinPoints'; aNaN; anInf; -1; 2e4};

% set up input structure for the pixelModelStruct
testCrConfigFields = cell(18,5);
% each cell row contains the following:
% {fieldName;   Nan;    Inf;    out of left bound;  out of right bound}
testCrConfigFields(1,:) = {'threshold'; aNaN; anInf; -1; 110};
testCrConfigFields(2,:) = {'localSdWindow'; aNaN; anInf; -1; 2e3};
testCrConfigFields(3,:) = {'localSdIterations'; aNaN; anInf; -1; 21};
testCrConfigFields(4,:) = {'curvaturePartitionOrder'; aNaN; anInf; -1; 21};
testCrConfigFields(5,:) = {'curvaturePartitionWindow'; aNaN; anInf; -1; 2e3};
testCrConfigFields(6,:) = {'curvaturePartitionThreshold'; aNaN; anInf; -1; 110};
testCrConfigFields(7,:) = {'curvaturePartitionSmallestRegion'; aNaN; anInf; -1; 25};
testCrConfigFields(8,:) = {'detrendWindow'; aNaN; anInf; -1; 103};
testCrConfigFields(9,:) = {'smallWindowDetrendOrder'; aNaN; anInf; -1; 23};
testCrConfigFields(10,:) = {'largeWindowDetrendOrder'; aNaN; anInf; -1; 23};
testCrConfigFields(11,:) = {'reconstructionThreshold'; aNaN; anInf; -1; 3};
testCrConfigFields(12,:) = {'saturationValueThreshold'; aNaN; anInf; -1; 3e10};
testCrConfigFields(13,:) = {'saturationThresholdMultiplier'; aNaN; anInf; -1; 23};
testCrConfigFields(14,:) = {'motionDetrendOrder'; aNaN; anInf; -1; 23};
testCrConfigFields(17,:) = {'dataGapFillOrder'; aNaN; anInf; -1; 21};

% set up input structure for the pixelModelStruct
testbgStructFields = cell(2,5);
% each cell row contains the following:
% {fieldName;   Nan;    Inf;    out of left bound;  out of right bound}
testbgStructFields(1,:) = {'row'; aNaN; anInf; -1; 1202};
testbgStructFields(2,:) = {'column'; aNaN; anInf; -1; 1202};

% set up input structure for the pixelModelStruct
testTimeSeriesFields = cell(1,5);
% each cell row contains the following:
% {fieldName;   Nan;    Inf;    out of left bound;  out of right bound}
testTimeSeriesFields(1,:) = {'timeSeries'; aNaN; anInf; -2e3; 2e9};

% set up input structure for the pixelModelStruct
testUncertaintiesFields = cell(1,5);
% each cell row contains the following:
% {fieldName;   Nan;    Inf;    out of left bound;  out of right bound}
testUncertaintiesFields(1,:) = {'uncertainties'; aNaN; anInf; -1; 2e6};

% set up input structure for the pixelModelStruct
testGapListFields = cell(1,5);
% each cell row contains the following:
% {fieldName;   Nan;    Inf;    out of left bound;  out of right bound}
testGapListFields(1,:) = {'gapList'; aNaN; anInf; -1; 2e6};


test_range(testBppFields, bppParameterStruct, [], []);
test_range(testBgConfigFields, bppParameterStruct, 'backgroundConfigurationStruct', [], []);
test_range(testCrConfigFields, bppParameterStruct, 'cosmicRayConfigurationStruct', [], []);
test_range(testbgStructFields, bppParameterStruct, 'backgroundStruct', 2, []);
test_range(testTimeSeriesFields, bppParameterStruct, 'backgroundStruct', 2, 4);
test_range(testUncertaintiesFields, bppParameterStruct, 'backgroundStruct', 2, 4);
test_range(testGapListFields, bppParameterStruct, 'backgroundStruct', 2, 2);

function test_range(testFields, bppParameterStruct, subStructName, index, index2)
% if subStructName = [] then we are testing the fields of
% bppParameterStruct.
% if subStructName is not empty then we are testing the fields of
% bppParameterStruct.subStructName.
% if index is not empty we are testing the fields in 
% bppParameterStruct.subStructName[index].
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
        bppData = bppParameterStruct;
        if(~isempty(testFields{j,k+1})) % for some parameters, need to check only one bound (either <= or >= some value)
            % now set the jth field value to out of bounds value and test whether the constructor catches the error

            if isempty(subStructName) % testing the top level structure
                bppData.(testFields{j,1}) = testFields{j,k+1};
            elseif isempty(index2) % there is no substructure index
                if isempty(index) % if there is no index
                    bppData.(subStructName).(testFields{j,1}) = testFields{j,k+1};
                else % there is an index on the sub-structure
                    bppData.(subStructName)(index).(testFields{j,1}) = testFields{j,k+1};
                end
            else
                if isempty(index) % if there is no top index
                    bppData.(subStructName).(testFields{j,1})(index2) = testFields{j,k+1};
                else % there is an index on the sub-structure
                    bppData.(subStructName)(index).(testFields{j,1})(index2) = testFields{j,k+1};
                end
            end;
%             display(['changing ' testFields{j,1} ' to ' num2str(testFields{j,k+1})]);

            caughtErrorFlag = 0;
            try
                bppObject = bppClass(bppData);
            catch
                % test passed, input validation failed
                err = lasterror;
                % check to see whether the correct exception/error was
                % thrown
                % parse the string and look for 'rangeCheck' and the name
                % of the field
                if(isempty(findstr(err.identifier, 'rangeCheck')))
%                     display(['wrong error: ' err.identifier]);
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

