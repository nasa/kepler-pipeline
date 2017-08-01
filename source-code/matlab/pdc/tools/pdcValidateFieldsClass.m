%*************************************************************************************************************
% classdef pdcValidateFields
%
% Tests if the fields in <testStruct> are equal or within the ranges specified by the structure named canonicalStructName in the calling function.
%
% NOTE: This class will not validate cells! TODO: set up for cells
%
% Inputs: 
%   testStructName      -- [char] The NAME for the the struct to examine. Must be a struct in the caller (see below)
%   canonicalStruct     -- [char] The struct to compare to.
%   problemFields       -- [struct OPTIONAL] apend new problem parameter to this struct (e.g. if calling pdc_validate_fields for substrcutures)
%   doSetToCanonical    -- [logical OPTIONAL] If true then set the problem fields to the canonical values (or within the canonical range)
%   tolerance           -- [double OPTIONAL] Tolerance to testing is floats are equal to canonical value (default = 1e-6)
%
% Outputs:
%   pdcValidateFieldsObject -- [pdcValidateClass] 
%       .problemFields          -- [struct] contains information on the problem fields
%       .testStruct             -- [struct] the struct under test (if doSetToCanonical=TRUE then it will be set to the canonicalStruct)
%       .testStructName         -- [char] Name of the test struct in the caller
%       .canonicalStruct        -- [struct] the canonicalStruct passed as input
%
% <canonicalStruct> (whatever it's called) contains the values to compare to. If you want to compare to a single value then just include that field in the
% struct. If you want to compare the field to a range of values then use the pdcValidRangeClass. If you do not want to check the field then set to [].
% Example below:
%
% isLogical = true; isChar = true; canBeEmpty = true; mustBeScalar = true;
%
% canonicalStruct.pdcVersion        = pdcValidRangeClass(0.0, 10.0, 'mustBeScalar');
% canonicalStruct.ccd.ccdNumber     = pdcValidRangeClass(  int32(1),    int32(4), 'mustBeScalar');
% canonicalStruct.ccd.cameraNumber  = pdcValidRangeClass(  int32(1),    int32(4), 'mustBeScalar');
% canonicalStruct.cadenceType       = pdcValidRangeClass(0.0,  0.0, 'isChar', 'charOptions', {'TARGET', 'FFI'}, 'mustBeScalar');
% canonicalStruct.startCadence      = pdcValidRangeClass(1,    1e7, 'mustBeScalar');
% canonicalStruct.endCadence        = pdcValidRangeClass(1,    1e7, 'mustBeScalar');
% canonicalStruct.startTimestamps   = pdcValidRangeClass(  53000,    70000, 'mustBeOfLegnth', 20000);
% canonicalStruct.pdcBlobFileName   = pdcValidRangeClass(0.0,  0.0, 'isChar', 'canBeEmpty');
% canonicalStruct.cbvBlobFileName   = pdcValidRangeClass(0.0,  0.0, 'isChar', 'canBeEmpty');
% canonicalStruct.alwaysPi          = 3.1416 % Check that this value is always pi.
% canonicalStruct.doNotCheckThis    = [] % Ignores this field
%
% % A substruct in canonicalStruct. targetDataStruct is an array of structs
% canonicalStruct.targetDataStruct.values         = pdcValidRangeClass(0.0, 1e12);
% canonicalStruct.targetDataStruct.uncertainties  = pdcValidRangeClass(0.0, 1e7);
% canonicalStruct.targetDataStruct.gapIndicators  = pdcValidRangeClass(0, 0, 'isLogical');
% canonicalStruct.targetDataStruct.catId          = pdcValidRangeClass(int32(1), int32(1e7), 'canBeEmpty');
%
%
% Then validate the struct with:
% pdcValidateFieldsObject = pdcValidateFieldsClass ('inputsStruct', canonicalStruct);
%
% The object created contains two public properties: 
% 
% pdcValidateFieldsObject.problemFields will contain an entry for every problem in the struct with the following fields:
%
% problemFields(iProblem).structName
% problemFields(iProblem).fieldName
% problemFields(iProblem).value
% problemFields(iProblem).description 
% problemFields(iProblem).validRangeStruct  -- [struct] a struct version of validRangeClass 
% problemFields(iProblem).validValue 
% problemFields(iProblem).indexInArray      -- [int] if the field being validated in an array this is the index in that array
%
% pdcValidateFieldsObject.testStruct will contain the struct under test and will update it if doSetToCanonical = true;
%
%*************************************************************************************************************
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

classdef pdcValidateFieldsClass

properties(Constant, GetAccess = 'private')
    problemFieldsTemplate = struct('structName', [], 'fieldName', [], 'value', [], 'description', [], 'validRangeStruct', [], 'validValue', [], ...
                                    'indexInArray', []);
end

properties(GetAccess = 'public', SetAccess = 'private')
    TOLERANCE = 1e-5;
    DOCHECKNUMERICTYPE = false; % If true check if the test value is the saem type as the high and low values. (I.e. if the value is supposed to be an integer)
end

properties(GetAccess = 'public', SetAccess = 'private')
    problemFields = pdcValidateFieldsClass.problemFieldsTemplate;
    testStruct = [];
    testStructName = [];
    canonicalStruct = [];
end

methods

%*************************************************************************************************************
% The constructor, See classdef header above
% Inputs: 
%   testStructName      -- [char] The NAME of the struct to examine. Must be a struct in the caller (see below)
%   canonicalStruct     -- [struct] The NAME for the struct to compare to.
%   problemFields       -- [struct OPTIONAL] apend new problem parameters to this struct (e.g. if calling pdc_validate_fields for substructures)
%   doSetToCanonical    -- [logical OPTIONAL] If true then set the problem fields to the canonical values (or within the canonical range)
%   tolerance           -- [double OPTIONAL] Tolerance to testing is floats are equal to canonical value (default = 1e-6)
%
%*************************************************************************************************************
function [obj] = pdcValidateFieldsClass (testStructName, canonicalStruct, problemFields, doSetToCanonical, tolerance)

    % We want the struct to be named as is the calling function
    testStruct = evalin('caller', testStructName);
    eval([testStructName,  ' = testStruct;']);

    obj.testStructName = testStructName;
    obj.canonicalStruct = canonicalStruct;

    if (~exist('problemFields', 'var'))
        problemFields = [];
    end

    if (~exist('doSetToCanonical', 'var') || isempty(doSetToCanonical))
        doSetToCanonical = false;
    end

    if (~exist('tolerance', 'var'))
        obj.TOLERANCE = 1e-5;
    else
        obj.TOLERANCE = tolerance;
    end

    % This method can be recursively called.
    [obj.problemFields, obj.testStruct] = obj.pdc_validate_fields (testStructName, testStruct, canonicalStruct, problemFields, doSetToCanonical);

    % Remove the dummy problemFields struct if no problems were found.
    if(~isempty(obj.problemFields) && isempty(obj.problemFields(end).structName))
        obj.problemFields(end) = [];
    end
end

%*************************************************************************************************************
%
% Inputs:
%   truncateToNProblems -- [int] only display the first N problems; DEFAULT = 100
%
function [] = display_problem_fields (obj, truncateToNProblems)

    if (~exist('truncateToNProblems', 'var'))
        truncateToNProblems = 100;
    end

    if (length(obj.problemFields) == 0)
        display(['No problems found in validating ', obj.testStructName]);
        return;
    end

    display('*****************************************');
    display('*****************************************');
    display('*****************************************');
    display(['Displaying Problems found in validating ', obj.testStructName, '...']);
    for iProblem = 1 : min(length(obj.problemFields), truncateToNProblems)
        display(['In ', obj.testStructName, '.', obj.problemFields(iProblem).structName, '.', obj.problemFields(iProblem).fieldName, ': ', ...
                    obj.problemFields(iProblem).description]);
    end
    if (length(obj.problemFields) > truncateToNProblems)
        display(['Truncated problem fields to only ', num2str(truncateToNProblems), ' entries!']);
        display(['There are ', num2str(length(obj.problemFields)), ' total problems!']);
    end

    display(' ');
    display(['Finished displaying problems found in validating ', obj.testStructName]);
    display('*****************************************')
    display('*****************************************')
    display('*****************************************')

end

%*************************************************************************************************************
% function [problemFields, testStruct] = pdc_validate_fields (testStructName, canonicalStruct, problemFields, doSetToCanonical)
%
% This is the actual work-horse function for the validation. It is a seperate function (and not a constructor) because it is recursively called for substructs.
%
% See classdef header above for usage
%
%*************************************************************************************************************

function [problemFields, testStruct] = pdc_validate_fields (obj, testStructName,  testStruct, canonicalStruct, problemFields, doSetToCanonical)

    if (isempty(problemFields))
        % Create a new problemFields struct
        problemFields = pdcValidateFieldsClass.problemFieldsTemplate;
        iProblem = 0; 
    elseif(isempty(problemFields(end).structName))
        % Empty probleFields struct passed
        iProblem = 0;
    else
        % non-empty problemFields passed
        iProblem = length(problemFields);
    end

    names = fieldnames(canonicalStruct);
    testStructNames = fieldnames(testStruct);

    % Check if any fields in the testStruct is not in the canonicalStruct
    [~, isInCanonicalStruct] = ismember(names, testStructNames);
    missingFields = true(length(testStructNames),1);
    isInCanonicalStruct = isInCanonicalStruct(isInCanonicalStruct ~=0);
    missingFields(isInCanonicalStruct) = false;
    problemNames = testStructNames(missingFields);
    for iNotExist = 1 : length(problemNames)
        iProblem = iProblem + 1;
        problemFields(iProblem).structName = testStructName;
        problemFields(iProblem).fieldName = problemNames{iNotExist};
        problemFields(iProblem).description = ['Field in ', testStructName, ' but not in canonicalStruct'];
    end
    clear testStructNames problemNames missingFields;

    % if testStruct is an array then loop over all single structs in the array
    for iStructArray = 1 : length(testStruct)
        testStructSingle = testStruct(iStructArray);
        for iName = 1 : length(names)
            if(~isfield(testStructSingle, names{iName}))
                iProblem = iProblem + 1;
                problemFields(iProblem).structName = testStructName;
                problemFields(iProblem).fieldName = names{iName};
                problemFields(iProblem).description = 'Field does not exist';
                problemFields(iProblem).indexInArray = iStructArray;
            elseif (~isempty(canonicalStruct.(names{iName})) && ~iscell(testStructSingle.(names{iName})))
        
                if (~isa(canonicalStruct.(names{iName}), 'pdcValidRangeClass') && ...
                            ~isequal(class(testStructSingle.(names{iName})), class(canonicalStruct.(names{iName}))))
                    % Not the correct type
                    iProblem = iProblem + 1;
                    problemFields(iProblem).structName = testStructName;
                    problemFields(iProblem).fieldName = names{iName};
                    problemFields(iProblem).value = testStructSingle.(names{iName});
                    problemFields(iProblem).description = 'Incorrect Class Type';
                    problemFields(iProblem).indexInArray = iStructArray;
                elseif (isstruct(canonicalStruct.(names{iName})))
                    % Recursively work on the sub-structure array
                    testSubStruct = testStructSingle.(names{iName});
                    for iSubStruct = 1 : length(testSubStruct)
                        [problemFields, newStruct] = ...
                            obj.pdc_validate_fields (names{iName}, testStruct(iStructArray).(names{iName})(iSubStruct), ...
                                                                canonicalStruct.(names{iName}), problemFields, doSetToCanonical);
                        if (doSetToCanonical)
                            testStructSingle.(names{iName})(iSubStruct) = newStruct;
                        end
                    end
                elseif (~isa(canonicalStruct.(names{iName}), 'pdcValidRangeClass') && ...
                        ~pdcValidateFieldsClass.is_equal_field_values(testStructSingle, canonicalStruct, names{iName}, obj.TOLERANCE))
                    % Not the correct value
                    iProblem = iProblem + 1;
                    problemFields(iProblem).structName = testStructName;
                    problemFields(iProblem).fieldName = names{iName};
                    problemFields(iProblem).value = testStructSingle.(names{iName});
                    problemFields(iProblem).description = 'Incorrect Value';
                    problemFields(iProblem).validValue = canonicalStruct.(names{iName});
                    problemFields(iProblem).indexInArray = iStructArray;
                elseif (obj.DOCHECKNUMERICTYPE && (isa(canonicalStruct.(names{iName}), 'pdcValidRangeClass') && ...
                            (~isequal(class(testStructSingle.(names{iName})), class(canonicalStruct.(names{iName}).high)) || ...
                            ~isequal(class(testStructSingle.(names{iName})), class(canonicalStruct.(names{iName}).low)))))
                    % Not the correct type
                    iProblem = iProblem + 1;
                    problemFields(iProblem).structName = testStructName;
                    problemFields(iProblem).fieldName = names{iName};
                    problemFields(iProblem).value = testStructSingle.(names{iName});
                    problemFields(iProblem).description = 'Incorrect Class Type';
                    problemFields(iProblem).validRangeStruct = canonicalStruct.(names{iName}).convert_to_struct;
                    problemFields(iProblem).indexInArray = iStructArray;
                elseif (isa(canonicalStruct.(names{iName}), 'pdcValidRangeClass'))
                    rangeProblem = pdcValidateFieldsClass.problem_with_range(testStructSingle, canonicalStruct, names{iName});
                    if (rangeProblem)
                        % Outside of valid range
                        % Not the correct value
                        iProblem = iProblem + 1;
                        problemFields(iProblem).structName = testStructName;
                        problemFields(iProblem).fieldName = names{iName};
                        problemFields(iProblem).value = testStructSingle.(names{iName});
                        problemFields(iProblem).validRangeStruct = canonicalStruct.(names{iName}).convert_to_struct;
                        problemFields(iProblem).indexInArray = iStructArray;
                        % Record the problem description
                        switch rangeProblem
                            case 1
                                problemFields(iProblem).description = 'Must Be Scalar';
                            case 2
                                problemFields(iProblem).description = 'Cannot Be NaN';
                            case 3
                                problemFields(iProblem).description = 'Cannot Be Empty';
                            case 4
                                problemFields(iProblem).description = 'Logical type error';
                            case 5
                                problemFields(iProblem).description = 'Char type error';
                            case 6
                                problemFields(iProblem).description = 'Outside Valid Numerical Range';
                        end
                    end
                end
                if (doSetToCanonical)
                    if (~isa(canonicalStruct.(names{iName}), 'pdcValidRangeClass'))
                        error ('Can only set to canonical value if the canonical value is a specific value and not a range');
                    end
                    testStruct(iStructArray) = setfield(testStruct(iStructArray), names{iName}, canonicalStruct.(names{iName}));
                end
            end
        
            % Check if each field is the proper length
            if (isa(canonicalStruct.(names{iName}), 'pdcValidRangeClass') && ...
                    ~pdcValidateFieldsClass.is_proper_length(testStructSingle, canonicalStruct, names{iName}))
                iProblem = iProblem + 1;
                problemFields(iProblem).structName = testStructName;
                problemFields(iProblem).fieldName = names{iName};
                problemFields(iProblem).value = testStructSingle.(names{iName});
                problemFields(iProblem).description = 'Incorrect Array Length';
                problemFields(iProblem).validRangeStruct = canonicalStruct.(names{iName}).convert_to_struct;
            end

        end
    end


end

end % methods

%*************************************************************************************************************
%*************************************************************************************************************
%*************************************************************************************************************
% private static Methods
% These are static because they do not really need the class objects

methods (Access = 'private', Static = true)

%*************************************************************************************************************
% This function tests equality of numerics, chars and logicals. 
% NOTE: Does not test equality of cells!Just passes isEqual = true in such cases!
% Also both values MUST be the same class type, otherwise, throws an error.
function isEqual =  is_equal_field_values (testStruct, canonicalStruct, fieldName, tolerance)

    testValue      = testStruct.(fieldName);
    canonicalValue = canonicalStruct.(fieldName);

    if (~isequal(class(testValue), class(canonicalValue)))
        error('is_equal_field_values: the field value and test value are not the same type! This should have already been checked in pdc_validate_fields!');
    end

    if (length(testValue) ~= length(canonicalValue))
        isEqual = false;
        return;
    end

    % If this is an array then check each element
    for iElement = 1 : length(canonicalValue)
        if (isnumeric(testValue(iElement)) && ((abs(testValue(iElement)) > abs(canonicalValue(iElement))*(1+tolerance) || ...
                                             abs(testValue(iElement)) < abs(canonicalValue(iElement))*(1-tolerance)) || ...
                                sign(testValue(iElement)) ~= sign(canonicalValue(iElement)))                           ) 
                isEqual = false;
                return;
        elseif (ischar(testValue(iElement)) && (~strcmp(testValue(iElement), canonicalValue(iElement))))
                isEqual = false;
                return;
        elseif (islogical(testValue(iElement)) && (testValue(iElement) ~= canonicalValue(iElement)))
                isEqual = false;
                return;
        end
    end

    isEqual = true;
    return;

end

%*************************************************************************************************************
%
% Checks if any values are NaN or must be scalar or class type or within numerical range
%
% Will only record one problem per testStruct
%
% TODO: record all problems not just the first encountered
%
% Outputs: 
%   rangeProblem   -- [int] with the following conditions:
%       0           -- is within proper range
%       1           -- Should be scalar
%       2           -- Should not be Nan
%       3           -- Should not be empty
%       4           -- Logical class problem
%       5           -- Char class problem
%       6           -- Outside numerical range
%

function rangeProblem = problem_with_range (testStruct, canonicalStruct, fieldName)

    rangeProblem = 0;

    testValue            = testStruct.(fieldName);
    canonicalRangeObject = canonicalStruct.(fieldName);

    % If empty and can be empty then return with no problem flags.
    if (canonicalRangeObject.canBeEmpty && isempty(testValue))
        return;
    end

    % If this is an array then check each element
    % If any is not within range then just record one instance of the error and break.
    if (~ischar(testValue) && length(testValue) > 1 && canonicalRangeObject.mustBeScalar)
        rangeProblem = 1;   
    elseif (~ischar(testValue) && any(isnan(testValue(:))) && ~canonicalRangeObject.canBeNan)
        rangeProblem = 2;   
    elseif (~canonicalRangeObject.canBeEmpty && isempty(testValue))
        rangeProblem = 3;   
    elseif (canonicalRangeObject.isLogical && ~isa(testValue, 'logical'))
        % Is NOT logical but supposed to be!
        rangeProblem = 4;
    elseif (~canonicalRangeObject.isLogical && isa(testValue, 'logical'))
        % Is a logical but not supposed to be!
        rangeProblem = 4;
    elseif (canonicalRangeObject.isChar && ~isa(testValue, 'char'))
        rangeProblem = 5;
    elseif (canonicalRangeObject.isChar && isa(testValue, 'char') && ~isempty(canonicalRangeObject.charOptions) && ...
                    ~ismember(testValue, canonicalRangeObject.charOptions))
        rangeProblem = 5;
    elseif (~canonicalRangeObject.isChar && isa(testValue, 'char'))
        % Is a character string but not supposed to be!
        rangeProblem = 5;
    elseif (canonicalRangeObject.isChar && isa(testValue, 'char'))
        % This character string is supposed to be a char and passed the previous char tests, so don't evaluate the next condition and return now
    elseif (isnumeric(testValue) && any(testValue(:) < canonicalRangeObject.low | testValue(:) > canonicalRangeObject.high))
        % This is a numerical but outside of specified range.
        rangeProblem = 6;
    end

end

%*************************************************************************************************************
function isProperLength = is_proper_length (testStruct, canonicalStruct, fieldName)

    isProperLength = true;

    % FieldNames comes form the canonical struct so we knwo that field exists in canonicalStruct but it could not exist in the test struct so we need to prtect
    % for that situation.
    if (~isfield(testStruct, fieldName))
        return;
    end
    testValue            = testStruct.(fieldName);
    canonicalRangeObject = canonicalStruct.(fieldName);

    if (~canonicalRangeObject.mustBeOfLength)
        return;
    end

    % If an arrayLength element is NaN then ignore that dimension
    % Also, ignore if testValue is empty and canBeEmpty
    if (isempty(testValue) && canonicalRangeObject.canBeEmpty)
        return;
    elseif (any((size(testValue) ~= canonicalRangeObject.arrayLength) & ~isnan(canonicalRangeObject.arrayLength)))
        isProperLength = false;
    end

end % is_proper_length

end % private static methods

end % classdef
