function remove_field_and_test_for_failure(lowLevelStructure, lowLevelStructName, topLevelStructure, topLevelStructName, className, ...
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

nInputs  = size(inputFields, 1);
eval([topLevelStructName ' =  topLevelStructure;']);

if(~exist('quickCheckFlag', 'var'))
    quickCheckFlag = true;
end

if(~exist('suppressDisplayFlag', 'var'))
    suppressDisplayFlag = false;
end

for j=1:nInputs

    % create structure with one missing input each time or create the structure
    % whole;
    inputData = lowLevelStructure;

    % now delete jth field and test whether the constructor catches the error
    inputData = rmfield(inputData, inputFields{j,1});

    eval([lowLevelStructName ' =  inputData;']);

    caughtErrorFlag = 0;
    try
        %ignore returned value

        if(quickCheckFlag)
            validate_structure(inputData, inputFields, lowLevelStructName);
        else
            eval([className '(' topLevelStructName ')']);
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
        if(isempty(findstr(err.identifier, 'missingField')))
            assert_equals('missingField',err.identifier,'Wrong type of error thrown!');
        else
            if(isempty(findstr(err.identifier,inputFields{j,1})))
                assert_equals(inputFields{j,1},err.identifier,'Wrong field identified as a missing field' );
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

if(~suppressDisplayFlag)
    fprintf('\n');
end

return;