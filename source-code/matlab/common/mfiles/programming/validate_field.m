function validate_field(inField, fieldsAndBounds, mnemonic, warningInsteadOfErrorFlag)


%----------------------------------------------------------------------
% if not the correct number of inputs throw an error
%----------------------------------------------------------------------
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
if nargin < 3
    error('validate_field:WrongNumberOfInputs',...
        'validate_field must be called with at least 3 inputs.');
end

if(~exist('warningInsteadOfErrorFlag', 'var'))
    warningInsteadOfErrorFlag = false;
end

%----------------------------------------------------------------------
% if not the correct number of inputs throw an error
%----------------------------------------------------------------------
[nFields, nChecks]  = size(fieldsAndBounds);
if((nFields > 1) && (nChecks > 1) )
    error('validate_field:TooManyInputs',...
        'validate_field can validate only one field at a time...');
end


if(isempty(mnemonic))
    mnemonic = 'validateField';
end
if(isempty(fieldsAndBounds{1}))
    fieldsAndBounds{1} = 'inputField';
end
% create dynamic field names
lowerBoundString = fieldsAndBounds{2};
upperBoundString = fieldsAndBounds{3};
listOfValuesString = fieldsAndBounds{4};

%----------------------------------------------------------------------
% if any of the lower, upper, or specific  values bounds exist, then
% the fiels can't be empty
%----------------------------------------------------------------------
if((~isempty(lowerBoundString) || ~isempty(upperBoundString) || ~isempty(listOfValuesString)) && isempty(inField))
    error('validate_field:FieldEmpty',...
        ['validate_field: ' fieldsAndBounds{1} ' can''t be empty when the bounds are not empty']);
end

%----------------------------------------------------------------------
% if any of the lower, upper, or specific  values bounds exist, if the
% field is not empty, then check to see if values are within bounds
%----------------------------------------------------------------------

if(~isempty(upperBoundString) || ~isempty(lowerBoundString))% this avoids bounds checking on struct

    if(~isfinite(inField))
        % not a NaN; not an Inf - go ahead and cast it into double (just in
        % case it came in as float or int)

        messageIdentifier = [mnemonic ':rangeCheck:' ];
        messageIdentifier = strrep(messageIdentifier, '.', '_');
        messageIdentifier = strrep(messageIdentifier, '(', '');
        messageIdentifier = strrep(messageIdentifier, ')', '');
        messageText = [mnemonic ':' fieldsAndBounds{1} ': contains a NaN or an Inf.'];
        error(messageIdentifier, messageText);


    end;

    % check for bounds
    % some times there may be only one value to check - for example ' < 0'
    % see whether left value and right value for the bounds exist
    if(isempty(upperBoundString))
        lowerBoundCheckResult = ~eval(['inField(:)' lowerBoundString]); % result could be an array
        if(~isempty(find(lowerBoundCheckResult,1))) % look for the first occurrence of failure

            if(length(inField(:)) == 1)
                actualValueString = [' but ' num2str(inField(:)) ];
            else
                % can't print  mile long vectors, so set the
                % string to ''
                actualValueString = [' but ' num2str(inField(find(lowerBoundCheckResult,1))) ];
            end

            messageIdentifier = [mnemonic ':rangeCheck:' fieldsAndBounds{1}];

            messageIdentifier = strrep(messageIdentifier, '.', '_');
            messageIdentifier = strrep(messageIdentifier, '(', '');
            messageIdentifier = strrep(messageIdentifier, ')', '');
            messageText = [mnemonic ':' fieldsAndBounds{1}  ': not ' lowerBoundString  actualValueString];
            if(warningInsteadOfErrorFlag) % issue a warning instead of error
                warning(messageIdentifier, messageText);
            else
                error(messageIdentifier, messageText);
            end

        end
    else
        % '&' operates on logical arrays instead of scalars
        boundsCheckResult = ~(eval(['inField(:)' lowerBoundString]) & ...
            eval(['inField(:)' upperBoundString]) );
        if(~isempty(find(boundsCheckResult,1)))% look for the first occurrence of failure

            if(length(inField(:)) == 1)
                actualValueString = [' but ' num2str(inField(:)) ];
            else
                % can't print  mile long vectors, so set the
                % string to ''
                actualValueString = [' but ' num2str(inField(find(boundsCheckResult,1))) ];
            end

            messageIdentifier = [mnemonic ':rangeCheck:' fieldsAndBounds{1}];
            messageIdentifier = strrep(messageIdentifier, '.', '_');
            messageIdentifier = strrep(messageIdentifier, '(', '');
            messageIdentifier = strrep(messageIdentifier, ')', '');
            messageText = [mnemonic ':' fieldsAndBounds{1} ': not ' lowerBoundString ' and not ' upperBoundString actualValueString];

            if(warningInsteadOfErrorFlag) % issue a warning instead of error
                warning(messageIdentifier, messageText);
            else
                error(messageIdentifier, messageText);
            end

        end
    end;
end
%----------------------------------------------------------------------
% both upper, lower bound strings are empty
% check the list of values to be matched
%----------------------------------------------------------------------

if(~isempty(listOfValuesString))
    % not a NaN; not an Inf - go ahead and cast it into double (just in
    % case it came in as float or int)
    if( ~ischar (inField) && ~islogical (inField)) &&...
            ~iscellstr (inField)
        if(isfinite(inField))
            inField = double(inField);

        else

            messageIdentifier = [mnemonic ':rangeCheck:' fieldsAndBounds{1}];
            messageIdentifier = strrep(messageIdentifier, '.', '_');
            messageIdentifier = strrep(messageIdentifier, '(', '');
            messageIdentifier = strrep(messageIdentifier, ')', '');
            messageText = [mnemonic ':' fieldsAndBounds{1} ': contains a NaN or an Inf.' ];
            if(warningInsteadOfErrorFlag) % issue a warning instead of error
                warning(messageIdentifier, messageText);
            else
                error(messageIdentifier, messageText);
            end

        end
    end;

    % check for bounds
    % some times there may be only one value to check - for example ' < 0'
    % see whether left value and right value for the bounds exist

    if(ischar (inField) || iscellstr (inField)) % a str, see whether it is one of the strings in the list

        nStringsToCheck  = length(cellstr(inField));
        if(nStringsToCheck == 1) % default
            listOfValuesCheckResult = ~eval(['strmatch( inField, listOfValuesString, ',    ' ''exact'')']); % result could be an array
        else % PDQ dynamic range targets seem to have two labels {'PDQ_STELLAR' ; 'PDQ_DYNAMIC_RANGE'}}
            for jString = 1:nStringsToCheck
                listOfValuesCheckResult = ~eval(['strmatch( inField(jString), listOfValuesString, ',    ' ''exact'')']); % result could be an array
                if(isempty(listOfValuesCheckResult))
                    break; % trigger error condition on finding no match
                end
            end

        end



        if(isempty(listOfValuesCheckResult))
            messageIdentifier = [mnemonic ':rangeCheck:' fieldsAndBounds{1}];
            messageIdentifier = strrep(messageIdentifier, '.', '_');
            messageIdentifier = strrep(messageIdentifier, '(', '');
            messageIdentifier = strrep(messageIdentifier, ')', '');

            nStrings = length(listOfValuesString);
            allStrings = '';
            for j=1:nStrings
                allStrings = [allStrings listOfValuesString{j} ' '];
            end

            if(nStringsToCheck == 1)
                actualValueString = [' but ' inField ];
            else
                % can't print  mile long vectors, so set the
                % string to ''
                actualValueString = [' but ' inField{jString} ];

            end

            messageText = [mnemonic ':' fieldsAndBounds{1} ': not ' allStrings actualValueString];
            if(warningInsteadOfErrorFlag) % issue a warning instead of error
                warning(messageIdentifier, messageText);
            else
                error(messageIdentifier, messageText);
            end

        end

    else

        if(~islogical(listOfValuesString))

            listOfValuesCheckResult = ~eval(['ismember(inField(:),',  listOfValuesString, ')']); % result could be an array
            if(~isempty(find(listOfValuesCheckResult,1)))
                messageIdentifier = [mnemonic ':rangeCheck:' fieldsAndBounds{1}];
                messageIdentifier = strrep(messageIdentifier, '.', '_');
                messageIdentifier = strrep(messageIdentifier, '(', '');
                messageIdentifier = strrep(messageIdentifier, ')', '');
                messageText = [mnemonic ':' fieldsAndBounds{1} ': not ' listOfValuesString ];
                if(warningInsteadOfErrorFlag) % issue a warning instead of error
                    warning(messageIdentifier, messageText);
                else
                    error(messageIdentifier, messageText);
                end
            end

        else
            if(~islogical(inField(:)))

                messageIdentifier = [mnemonic ':rangeCheck:' fieldsAndBounds{1}];
                messageIdentifier = strrep(messageIdentifier, '.', '_');
                messageIdentifier = strrep(messageIdentifier, '(', '');
                messageIdentifier = strrep(messageIdentifier, ')', '');
                messageText = [mnemonic ':' fieldsAndBounds{1} ': not a Boolean (logical) ' ];
                if(warningInsteadOfErrorFlag) % issue a warning instead of error
                    warning(messageIdentifier, messageText);
                else
                    error(messageIdentifier, messageText);
                end

            end
        end
    end;

end

