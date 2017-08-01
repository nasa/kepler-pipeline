function check_struct(inStruct, fieldsAndBoundsStruct, mnemonic)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function check_struct(inStruct, fieldsAndBoundsStruct, mnemonic)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% This function compares the input struct inStruct with fields and tests
% in the array of structs fieldsAndBoundsStruct.  
% For each entry in fieldsAndBoundsStruct performs the following tests on 
% inStruct:
%   - the field name exists
%   - none of the field data entries contain Inf or NaN
%   - the data bounds are satisfied
%
% Inputs: 
%   inStruct: the structure whose fields are to be tested.  inStruct can be
%       an array of structs.
%   fieldsAndBoundsStruct: an array of structs with one entry for each 
%       field of inStruct that is to be tested. Not all fields of inStruct
%       need to be tested.
%       Each entry of fieldsAndBoundsStruct must contain the following fields:
%           - fieldName: a string with the name of a field that is required to
%           	appear in inStruct
%           - binaryCompare: a cell array of strings that contains comparisons that are to be
%               performed against each element of that field of inStruct, e.g. '<= 12'.
%               Note that the element of inStruct to be tested is on the left of the compare.
%
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

if nargin ~= 3
    % if not the correct number of inputs throw an error
    error('check_struct:WrongNumberOfInputs',...
        'check_struct must be called with 3 inputs.');
else
    nFields = length(fieldsAndBoundsStruct);
    
    % check the fields of the structure that have values in
    % fieldsAndBoundsStruct
    for f=1:nFields
%        display(['checking ' fieldsAndBoundsStruct(f).fieldName]);
        % first make sure the field exists
        if ~isfield(inStruct, fieldsAndBoundsStruct(f).fieldName)
            error([mnemonic ':missingField:' fieldsAndBoundsStruct(f).fieldName],...
                [fieldsAndBoundsStruct(f).fieldName ': field not present in the input structure.'])
        end
        
        % check for any NaNs or Infs, accounting for the possibility that
        % inStruct is an array of structs.
        if any(~isfinite([inStruct.(fieldsAndBoundsStruct(f).fieldName)]))
            error([mnemonic ':rangeCheck:' fieldsAndBoundsStruct(f).fieldName],...
                [fieldsAndBoundsStruct(f).fieldName ': contains a Nan or Inf.'])
        end
        
        % now check ranges for the compares, if any.  Fail unless all of
        % the elements resolve the compare as true.
        nCompares = length(fieldsAndBoundsStruct(f).binaryCompare);
        if nCompares > 0
            for test = 1:nCompares
                % make sure the column we're comparing is a row vector,
                % necessary for this text string manipulation
                if size([inStruct.(fieldsAndBoundsStruct(f).fieldName)], 1) == 1
                    if eval(['~all([' num2str([inStruct.(fieldsAndBoundsStruct(f).fieldName)]) ']' ...
                            char(fieldsAndBoundsStruct(f).binaryCompare(test)) ')'])
                        error([mnemonic ':rangeCheck:' fieldsAndBoundsStruct(f).fieldName],...
                            [fieldsAndBoundsStruct(f).fieldName ': not all '...
                            char(fieldsAndBoundsStruct(f).binaryCompare(test)) '.'])
                    end
                else
                    if eval(['~all([' num2str([inStruct.(fieldsAndBoundsStruct(f).fieldName)]') ']' ...
                            char(fieldsAndBoundsStruct(f).binaryCompare(test)) ')'])
                        error([mnemonic ':rangeCheck:' fieldsAndBoundsStruct(f).fieldName],...
                            [fieldsAndBoundsStruct(f).fieldName ': not all '...
                            char(fieldsAndBoundsStruct(f).binaryCompare(test)) '.'])
                    end
                end
            end
        end
    end   
end
