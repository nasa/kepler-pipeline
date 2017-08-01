%**************************************************************************
% function struct_to_comment_block(s, sName, filename, depth)
%**************************************************************************
% Print a comment block summarizing the structure 's' by level. The output
% format is derived from the headers of the top-level matlab functions of
% the Kepler SOC pipeline (e.g., pa_matlab_controller.m).
%
% INPUTS
%
%     s        : The struct to document.
%     sName    : A string containing name of the structure s (e.g.,
%                'paDataStruct').
%     filename : A string containing the path and name of the file to which
%                comments will be appended. If a file name is not provided,
%                results are written to the standard output.
%     depth    : The maximum number of levels to document (default = 20).
%
% OUTPUTS
%
%     Comments are written to the file specified by the argument 'filename'
%     or to the standard output if a file name is not provided. The file is
%     created if it does not already exist, otherwise existing file
%     contents are overwritten.
%
% USAGE EXAMPLE
%
% >> s = struct('a', 1, 'b', struct('d', struct('f', [], 'g', ones(5)), ...
%    'e', true), 'c', 'text');
% >> struct_to_comment_block(s, 's')
% %------------------------------------------------------------------------
% %    Level 1
% %
% %    s is is a struct with the following fields:
% %
% %        a [double]
% %        b [struct]
% %        c [char]
% %
% %------------------------------------------------------------------------
% %    Level 2
% %
% %    b is is a struct with the following fields:
% %
% %        d [struct]
% %        e [logical]
% %
% %------------------------------------------------------------------------
% %    Level 3
% %
% %    d is is a struct with the following fields:
% %
% %        f [double]
% %        g [double]
% %
%**************************************************************************
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
function struct_to_comment_block(s, sName, filename, depth)
    if ~exist('depth', 'var')
        depth = 20;
    end
    
    if exist('filename', 'var') && ~isempty(filename) && ischar(filename)
        fid = fopen(filename, 'a');
    else % write to the standard output.
        fid = 1;
    end
    
    for printLevel = 1:depth
        struct_level_to_comment_block(fid, s, sName, printLevel);
    end
end

%**************************************************************************
% Identify and recursively descend into sub-structures. Print comments for
% sub-structures at the specified level.
%**************************************************************************
function struct_level_to_comment_block(fid, s, name, printLevel, level)

    if ~isstruct(s)
        error('Input object is not a valid struct.');
    end

    if ~exist('level', 'var')
        level = 1;
    end

    if level == printLevel
        print_comments(fid, s, name, level);
    end

    if level < printLevel
        fn = fieldnames(s);
        for i = 1:numel(fn)
            if numel(s) > 1
                s = s(1);
            end
            if isstruct(s.(fn{i}))
                struct_level_to_comment_block(fid, s.(fn{i}), fn{i}, ...
                    printLevel, level + 1);
            end
        end
    end
end

%**************************************************************************
% Print comments for each field of the structure s to the specified file
% ID. 
%**************************************************************************
function print_comments(fid, s, name, level)

    fn = fieldnames(s);
    classPosition = max(cellfun(@length, fn)) + 1;
    
    fprintf(fid, '%%%s\n', repmat('-', 1, 74));
    fprintf(fid, '%%    Level %d\n', level);
    fprintf(fid, '%%\n');
    fprintf(fid, '%%    %s is a struct with the following fields:\n', name);
    fprintf(fid, '%%\n');
    for i = 1:numel(fn)
        if numel(s) > 1
            s = s(1);
        end
        
        if isempty(s.(fn{i}))
            classStr = '';
        else
            classStr = class(s.(fn{i}));
        end
        
        nSpaces = classPosition - length(fn{i}) - 1;
        fprintf(fid, '%%        %s %s[%s]\n', ...
            fn{i},  repmat('.', 1, nSpaces), classStr );
    end
    fprintf(fid, '%%\n');
end