%% retrieve_function_list
%
%  [functionList options] = retrieve_function_list(filename)
% 
% Returns a list of structures with a 'name' string field and a 'done'
% logical field. The 'name' field is initialized to the function names in the
% given filename and the 'done' field is initialized to false.
% The functions listed in this file should be fully-qualified but relative
% to the directory in which this function is run. Lines that begin with a #
% are ignored.
%
% This function can also return an options structure if the input file
% contains lines of the form "options.field = value".
% 
%% INPUTS
%
% * filename: the filename of a file that contains function names
%
%% OUTPUTS
%
% * functionList: a list of structures with a 'name' string field and a 'done'
%                 logical field
% * options: an optional options structure found in the input file
%%
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

function [functionList fileOptions] = retrieve_function_list(filename)

matlabRoot = [fullfile(get_socCodeRoot(), 'matlab') filesep];
packageRoot = [pwd() filesep];
package = regexprep(packageRoot, ['^' matlabRoot], '');

functions = importdata(filename, '');
fileOptions = struct();

% Strip comments.
for i = length(functions):-1:1
    if (isequal(functions{i}(1), '#'))
        functions(i,:) = [];
    end
end

% Strip leading and trailing whitespace.
functions = strtrim(functions);

% Parse options.
for i = length(functions):-1:1
    if (regexp(functions{i}, '^options\.', 'once'))
        if (nargout > 1)
            [s, e, tokenExtents, match, tokens] ...
                = regexp(functions{i}, '^options\.(\w+)\s*=\s*(\w+)'); %#ok<ASGLU>
            fileOptions.(tokens{1}{1}) = tokens{1}{2};
        end
        functions(i,:) = [];
    end
end

% Initialize list.
functionList = repmat(struct('name', '', 'done', false, 'options', struct()), ...
    [1 length(functions)]);

for i = 1 : length(functions)
    % Extract function name, minus trailing optional .m.
    functionName = regexprep(functions{i}, '^\s*([^\s]+).*$', ...
        fullfile(package, '$1'), 'once');
    functionName = regexprep(functionName, '\.m$', '');

    % Extract optional options.
    remain = regexprep(functions{i}, '^[^\[]+\[([^\]]+)\].*$', '$1', 'once');
    if (regexp(remain, '='))
        while (true)
            [optionStr remain] = strtok(remain, ',');  %#ok<STTOK>
            if (isempty(optionStr))
                break;
            end
            option = regexprep(optionStr, '^\s*(options\.)?(\w+)\s*=\s*\w+\s*$', '$2', 'once');
            value = regexprep(optionStr, '^\s*[\w.]+\s*=\s*(\w+)\s*$', '$1', 'once');
            functionList(i).options.(option) = value;
        end
    end

    functionList(i).name = functionName;
end

return
