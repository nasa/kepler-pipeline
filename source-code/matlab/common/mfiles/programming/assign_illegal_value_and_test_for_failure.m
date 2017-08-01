function assign_illegal_value_and_test_for_failure(lowLevelStructure, lowLevelStructName, topLevelStructure, topLevelStructName, className, ...
    inputFields, quickCheckFlag, suppressDisplayFlag)
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

[nInputs, nColumns]  = size(inputFields);
eval([topLevelStructName ' =  topLevelStructure;']);
if(~exist('quickCheckFlag', 'var'))
    quickCheckFlag = true;
end

if(~exist('suppressDisplayFlag', 'var'))
    suppressDisplayFlag = false;
end


nChecks = min(nColumns,5); % check for NaN, Inf, violation of lower bound, violation of upper bound, or violation of list membership

for i= 1:nChecks

    if(~suppressDisplayFlag)
        fprintf('\n\n');
    end

    for j=1:nInputs

        % copy the original structure with valid inputs
        inputData = lowLevelStructure;

        % now set the jth field value to out of bounds value and test whether the constructor catches the error

        switch i
            case 1
                inputData.(inputFields{j,1}) = NaN;
            case 2
                inputData.(inputFields{j,1}) = Inf;
            case 3

                if(~isempty(inputFields{j,2})) % extract lower bound or == value and make it illegal

                    lowerBoundStr = inputFields{j,2};
                    lowerBoundStr = strrep(lowerBoundStr, '>','');
                    lowerBoundStr = strrep(lowerBoundStr, '=','');
                    lowerBoundStr = strrep(lowerBoundStr, '=','');
                    inputData.(inputFields{j,1}) = str2num(lowerBoundStr) - 1;
                else
                    continue;
                end
            case 4
                if(~isempty(inputFields{j,3})) % extract lower bound or == value and make it illegal

                    upperBoundStr = inputFields{j,3};
                    upperBoundStr = strrep(upperBoundStr, '<','');
                    upperBoundStr = strrep(upperBoundStr, '=','');
                    upperBoundStr = strrep(upperBoundStr, '=','');
                    inputData.(inputFields{j,1}) = str2num(upperBoundStr) + 1;
                else
                    continue;
                end

            case 5
                if(~isempty(inputFields{j,4})) % extract lower bound or == value and make it illegal

                    listStr = inputFields{j,4};
                    if(ischar(listStr))
                        inputData.(inputFields{j,1}) = str2num(listStr) + 1;
                    elseif(iscell(listStr))
                        inputData.(inputFields{j,1}) = 'xgaggdhghd'; % garbage string
                    elseif(islogical(listStr))
                        inputData.(inputFields{j,1}) = 100.5; % garbage string
                    end

                else
                    continue;
                end
        end;

        eval([lowLevelStructName ' =  inputData;']);

        caughtErrorFlag = 0;
        try
            %ignore returned value

            if(~exist('quickCheckFlag', 'var'))
                eval([className '(' topLevelStructName ')']);
            else
                if(quickCheckFlag)
                    validate_structure(inputData, inputFields, lowLevelStructName);
                else
                    eval([className '(' topLevelStructName ')']);
                end;
            end;
        catch
            % test passed, input validation failed
            err = lasterror;
            startIndex = regexp(err.message,'\n');

            if(~suppressDisplayFlag)
                fprintf(['\n\t\t' err.message(startIndex+1:end) ]);
            end

            % check to see whether the correct exception/error was
            % thrown
            % parse the string and look for 'missingField' and the name
            % of the field

            if(isempty(findstr(err.identifier, 'rangeCheck')))
                assert_equals('rangeCheck',err.identifier,'Wrong type of error thrown!');
            else
                if(isempty(findstr(err.identifier,inputFields{j,1})))
                    assert_equals(inputFields{j,1},err.identifier,'Wrong field identified as having illegal inputs' );
                end;
            end;
            caughtErrorFlag = 1;
        end;
        if(~caughtErrorFlag)
            % optional message is printed only when assert fails
            % test failed, input validation did not catch the error
            assert_equals(1,0, 'Validation failed to catch the error..');
        end;
    end;
end;

if(~suppressDisplayFlag)
    fprintf('\n');
end

return;