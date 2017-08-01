function  status  = compare_structs_to_within_specified_precision(s1,s2, precisionString, nameOfStruct1, nameOfStruct2)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function status  = compare_structs_to_within_specified_precision(s1,s2, precisionString, nameOfStruct1, nameOfStruct2)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Decription:
% This function compares two given structures for equality to within the
% specified precision indicated by the 'precisionString'
%
%  Can eventually replace the existing function 'compare_structs_to_within_single_precision.m' 
%
% Note: this function correctly supports testing for equality between
% floating point NaN values for corresponding fields in s1 and s2.
%
% Inputs:
%       s1, s2 - structures which are to be tested for equality under
%       single or double precision
%       precisionString - can be only 'double' or 'single' (if left
%       unspecified, defaults to 'single')
%       nameOfStruct1, nameOfStruct2 are strings containing the names of
%       the structures by which they will be known inside the function and
%       are optional.
%
% Outputs:
%       status - a boolean, true indictaing that the structures are the
%       same to within specified precision, false otherwise.
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
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

if(~exist('nameOfStruct1', 'var'))
    nameOfStruct1 = 'firstStruct';
end
if(~exist('nameOfStruct2', 'var'))
    nameOfStruct2 = 'secondStruct';
end
if(~exist('precisionString', 'var'))
    precisionString = 'single';
else
    validate_field(precisionString, { 'precisionString'; []; []; {'single' ; 'double'}}', '');  %

end

status = test_structs(s1,s2,precisionString, nameOfStruct1, nameOfStruct2);

return



function status = test_structs(s1,s2, precisionString, nameOfStruct1, nameOfStruct2)

nFields = length(fieldnames(s1));
namesOfFields = fieldnames(s1);

status = true;

% check if all fields are present in both structures
namesOfFields2 = fieldnames(s2);
diff12 = setdiff(namesOfFields,namesOfFields2); % contains fields that are missing in s2
diff21 = setdiff(namesOfFields2,namesOfFields); % contains fields that are missing in s1
if ~isempty(diff12)
    fprintf('structures are not identical: fieldnames not matching. field ''%s'' is missing in second structure.',diff12{1});
    status = false;
end
if ~isempty(diff21)
    fprintf('structures are not identical: fieldnames not matching. field ''%s'' is missing in first structure.',diff21{1});
    status = false;
end


if (status) % only execute this if fieldnames are identical for both structures
    nStructs = length(s1);
    for j =1:nStructs

        for k = 1:nFields

            if(~isstruct(s1(j).(namesOfFields{k})))
                if(isfloat(s1(j).(namesOfFields{k})))

                    v1 = s1(j).(namesOfFields{k});
                    v2 = s2(j).(namesOfFields{k});
                    v1(isnan(v1)) = -sqrt(pi);
                    v2(isnan(v2)) = -sqrt(pi);

                    if(strmatch(precisionString, 'single', 'exact'))
                        toleranceEps = eps(single(v1));
                    else
                        toleranceEps = eps(double(v1));
                    end

                    compare = abs(v1 - v2) <= toleranceEps;
                    if any(~compare),
                        % print error message
                        newNameOfStruct1 = [nameOfStruct1 '(' num2str(j) ').' (namesOfFields{k})];
                        newNameOfStruct2 = [nameOfStruct2 '(' num2str(j) ').' (namesOfFields{k})];
                        fprintf('%s is not equal to %s at the %s precision level \n', newNameOfStruct1, newNameOfStruct2, precisionString);
                        status = false;
                        %break
                    end
                end
            else
                newNameOfStruct1 = [nameOfStruct1 '(' num2str(j) ').' (namesOfFields{k})];
                newNameOfStruct2 = [nameOfStruct2 '(' num2str(j) ').' (namesOfFields{k})];
                compare = test_structs(s1(j).(namesOfFields{k}),s2(j).(namesOfFields{k}), precisionString, newNameOfStruct1, newNameOfStruct2);
                if any(~compare)
                    fprintf('%s is not equal to %s at the %s precision level \n', newNameOfStruct1, newNameOfStruct2, precisionString);
                    status = false;
                    %break
                end
            end

        end

        if ~status
            break
        end

    end % for
end % if

return
