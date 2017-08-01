function inputStructArray = bs_clone_configuration_struct(inputStruct,nStructs)
% function inputStructArray = bs_clone_configuration_struct(inputStruct,nStructs)
%
%     clones a ConfigurationStruct into multiple copies, using the (array) values of each field for the different clones
%
%     If for a field fewer values are provided than output structures are requested, the last value is used for all
%     structures beyond the last one
%     e.g. a field with the input values [ 1 2 3 ], with 5 output structs requested, will have: 1 2 3 3 3 in structs 1-5
%
%     NOTE:
%     - does NOT work with substructs
%       this functionality could be added, but is not required because those data types are not supported in inputsStructs
%       anyway
%
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

    VERBOSE = 0;
    
    fn = fieldnames(inputStruct);

    for n=1:nStructs
        % initialize array, field values will be overwritten afterwards
        inputStructArray{n} = inputStruct;
    end
    
	% update individual values
    for i=1:length(fn)
        for n=1:nStructs            
            values = inputStructArray{n}.(fn{i});
            fIsChar = ischar(values); % will be char is single string is provided
            fIsCell = iscell(values); % will be cell if array of strings is provided (should be default also for 1 element)
            fIsStruct = isstruct(values); % NOT SUPPORTED
            k = length(values);
            % ======================================================================================
            % deal with single string inputs which are not contained in a cell array
            if (fIsChar)
                inputStructArray{n}.(fn{i}) = str_remove_spaces(values); % take this string
            end
            % ======================================================================================
            % deal with cell arrays of strings
            if (fIsCell)
                if (k==1)
                    % one argument only, take that for each clone
                    inputStructArray{n}.(fn{i}) = str_remove_spaces(values{1}); % no action, just taking input
                elseif (k>=nStructs)
                    % one argument per clone
                    inputStructArray{n}.(fn{i}) = str_remove_spaces(values{n});
                elseif (k==0)
                    % empty inputs should not occur, have there were encountered in a smoke test once
                    disp(['WARNING: empty field "' fn{i} '". Please do not provide empty input arguments.']);
                else
                    % too few arguments - need to pad
                    if (n<=k)
                        % specific value exists, take it
                        inputStructArray{n}.(fn{i}) = str_remove_spaces(values{n});
                    else
                        % more than 1, but less than nStructs. unclean. through warning and fill up with default
                        if (VERBOSE)
                            disp(['WARNING: Not enough values for all clones. Padding with last value.  (fieldname "' fn{i} '")']);
                        end
                        inputStructArray{n}.(fn{i}) = str_remove_spaces(values{k}); % NOTE: could change this to {1} to make first argument default
                    end
                end                
            end
            % ======================================================================================
            % catch substructures (not supported, because not a legal field in configstruct anyway)
            if (fIsStruct)
                if (VERBOSE)
                    disp('WARNING: substructures not supported.');
                end
            end
            % ======================================================================================
            % deal with any other format (except substructs)
            if ( ~ (fIsChar || fIsCell || fIsStruct) )
                if (k==1)
                    % one argument only, take that for each clone
                    inputStructArray{n}.(fn{i}) = values; % no action, just taking input
                elseif (k>=nStructs)
                    % one argument per clone
                    inputStructArray{n}.(fn{i}) = values(n);
                elseif (k==0)
                    % empty inputs should not occur, have there were encountered in a smoke test once
                    disp(['WARNING: empty field "' fn{i} '". Please do not provide empty input arguments.']);
                else
                    % too few arguments - need to pad
                    if (n<=k)
                        % specific value exists, take it
                        inputStructArray{n}.(fn{i}) = values(n);
                    else
                        % more than 1, but less than nStructs. unclean. through warning and fill up with default
                        if (VERBOSE)
                            disp(['WARNING: Not enough values for all clones. Padding with last value.  (fieldname "' fn{i} '")']);
                        end
                        inputStructArray{n}.(fn{i}) = values(k); % NOTE: could change this to {1} to make first argument default
                    end
                end                
            end % not fIsChar
        end % for n=1:nStructs
    end % for i=1:length(fn)
end

% ----------------------
% the function below removes all spaces (leading, trailing, also interior) from a string.
% reason to do this (at least leading and trailing) is to ensure compatibility with strings arrays like "mean, std, ..."
% this should be done on the Java side, but doing it here right now for quick fix (3/19/2012, MCS)
function outstr = str_remove_spaces(instr)
    outstr = instr(~isspace(instr));
end
