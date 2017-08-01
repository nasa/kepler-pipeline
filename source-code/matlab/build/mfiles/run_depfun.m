%% run_depfun
%
%  function = run_depfun(indexFilename, outputDirectory, options)
% 
% Produces one or more call trees for all of the functions in
% indexFilename.  The functions listed in this file should be relative to
% the directory in which this function is run. 
%
% Lines that begin with a # are ignored. 
%
% Lines that begin with "options." can be used to set the options
% described below (for example, "options.depth = 1") for the entire file.
% These options apply to all functions within the file. In addition,
% options can be specified on a per-function basis by placing
% comma-separated options (with or without a leading options. prefix) in
% square brackets on the same line following the function. For example:
%
%   mfiles/dv_matlab_controller [depth = 2, localOnly = true]
%
% The options passed into run_depfun take precedence over the other
% options. The per-function options take precedence over the file-wide
% options. 
%
%% INPUTS
%
% * *indexFilename*: the filename of a file that contains the functions that
%                    should be considered
% * *outputDirectory*: the name of the directory that should contain the
%                      output of depfun
% * *options*: an optional structure with the following
%              fields:
%   *depth*: limits the depth of the output (default: 0 - no limit)
%   *localOnly*: if true, do not show dependencies outside of the current
%                package (default: true)
%
%% OUTPUTS
%
% None
%
%% ALGORITHM
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

function run_depfun(indexFilename, outputDirectory, options)

if (nargin < 2 || nargin > 3)
    disp('Usage: run_depfun(indexFilename, outputDirectory [, options])');
    return;
elseif (nargin ~= 3)
    options = struct();
end

matlabRoot = [fullfile(get_socCodeRoot(), 'matlab') filesep];
packageRoot = [pwd() filesep];
package = regexprep(packageRoot, ['^' matlabRoot], '');

% fprintf('matlabRoot=%s; packageRoot=%s\n', matlabRoot,
% packageRoot);

[functionList fileOptions] = read_index_file(indexFilename);
functionList = set_options(options, fileOptions, functionList);
generate_dependencies(functionList, outputDirectory);
dependencyList = create_dependency_list(outputDirectory);
[dependencyList dependencyTrees] = create_dependency_trees(dependencyList);
render_dependency_trees(dependencyList, dependencyTrees, outputDirectory, 'dot');
render_dependency_trees(dependencyList, dependencyTrees, outputDirectory, 0);

%% Pass 1
%
% Run depfun recursively on each function in indexFilename, which can
% also include options. Except for functions outside of this package,
% an output file is created that lists its dependencies. This is a text
% file with a .dependencies extension and is written to the directory
% specified by outputDirectory. Recursion is suppressed for functions
% outside of this package. Functions that are in the MATLAB toolboxes
% are not listed.
%%
    function [functionList options] = read_index_file(indexFilename)
        fprintf('Pass 1a: Reading functions from %s\n', indexFilename);

        try
            [functionList options] = retrieve_function_list(indexFilename);
        catch
            error('Can not open %s', indexFilename);
        end
    end

    function functionList = set_options(options, fileOptions, functionList)

        for i = 1 : length(functionList)
            checkFields(functionList(i));

            functionList(i).options.depth = extract_option('depth', ...
                options, functionList(i).options, fileOptions, 0);
            functionList(i).options.localOnly = extract_option('localOnly', ...
                options, functionList(i).options, fileOptions, false);
            functionList(i).options.root = extract_option('root', ...
                options, functionList(i).options, fileOptions, false);
        end
    end

    function value = extract_option(name, options, functionOptions, fileOptions, default)
        % Default has lowest precedence.
        value = default;

        % Set value of option using the precedence rule: option parameter >
        % option given with function's entry > global file option.
        if (isfield(options, name))
            value = eval(options.(name));
        elseif (isfield(functionOptions, name))
            value = eval(functionOptions.(name));
        elseif (isfield(fileOptions, name))
            value = eval(fileOptions.(name));
        end
    end

    function checkFields(functionListElement)
        names = fieldnames(functionListElement.options);
        for i = 1 : length(names)
            switch (names{i})
                case 'depth'
                case 'localOnly'
                case 'root'
                otherwise
                    error('Unrecognized option %s given for function %s', ...
                        names{i}, functionListElement.name);
            end
        end
    end

    function generate_dependencies(functionList, outputDirectory)

        fprintf('Pass 1b: Writing dependencies to %s\n', outputDirectory);

        index = retrieve_next_index(functionList);
        while index > 0

            functionName = functionList(index).name;

            % If path ends in @fooClass, add a /fooClass implicit constructor.
            [directory basename] = fileparts(functionName); %#ok<ASGLU>
            if (strncmp(basename, '@', 1))
                functionName = fullfile(functionName, ...
                    regexprep(basename, '^@', '', 'once'));
            end

            % fprintf('Calculating call tree for %s\n', functionList(index).name);
            dependencies = depfun(functionName, '-toponly', '-quiet');

            % Create file for function, preserving directory structure.
            outputFilename = regexprep(functionName, ['^' matlabRoot], '');
            fid = open_dependency_file(outputDirectory, outputFilename);

            for i = 1:length(dependencies)
                % Strip trailing .m from function's name and make relative to matlabRoot.
                matlabFunction = regexprep(regexprep(dependencies{i}, '\.m$', ''), ...
                    ['^' matlabRoot], '');

                % fprintf('matlabFunction=%s\n', matlabFunction);

                % Don't add ourselves to our file.
                if (isequal(matlabFunction, functionName))
                    continue;
                end

                % fprintf('Processing %s\n', matlabFunction);

                % Skip non-Keplerian functions. The paths to these will be
                % outside of matlabRoot and therefore will be absolute instead
                % of relative.
                if (matlabFunction(1) == filesep())
                    continue;
                end

                % If matlabFunction isn't in functionList, add it.
                % If function is not in this package, mark it as done so that we do
                % not later recurse into it.
                if (~ismember(matlabFunction, {functionList.name}))
                    entry = struct('name', matlabFunction, ...
                        'options', functionList(index).options, ...
                        'done', false);
                    if (functionList(index).options.localOnly ...
                            && ~strncmp(matlabFunction, package, length(package)))
                        entry.done = true;
                    end
                    functionList = [functionList entry]; %#ok<AGROW>
                end

                fprintf(fid, '%s\n', matlabFunction);
            end

            xclose(fid, outputFilename);
            functionList(index).done = true;
            index = retrieve_next_index(functionList);
        end

    end

    function fid = open_dependency_file(outputDirectory, filename)

        [dirname basename ext] = fileparts(filename);

        depfunDir = fullfile(outputDirectory, dirname);
        if (exist(depfunDir, 'dir') ~= 7)
            mkdir(depfunDir);
        end

        file = fullfile(depfunDir, [basename ext '.dependencies']);
        fid = xopen(file, 'w');

    end

    function fid = xopen(filename, mode)

        fid = fopen(filename, mode);
        if (fid == -1)
            error('Unable to open file: %s', filename);
        end;

    end

    function xclose(fid, filename)

        if (fclose(fid) < 0)
            error('Error while closing %s', filename);
        end

    end

%% Pass 2
%
% Create a list of structures based upon the contents of the files
% previously created. This structure contains the name of the function (a
% string) and a list of its children (with name and children fields only).
% It also contains a logical field called hasParent whose initial value is false.
%%
    function dependencyList = create_dependency_list(outputDirectory, directory, list)

        if (nargin > 2)
            dependencyList = list;
        else
            disp('Pass 2: Building dependency list');
            dependencyList = [];
            directory = '';
        end

        files = dir(fullfile(outputDirectory, directory));
        for i = 1 : length(files)
            % Ignore ., .., and .svn.
            if (files(i).name(1) == '.')
                continue;
            end

            % Make filename relative to original directory.
            filename = fullfile(directory, files(i).name);

            % Recurse into directories.
            if (files(i).isdir)
                if (strncmp(files(i).name, '@', 1))
                    % List all class functions as children of the class.
                    classDependencyList = create_dependency_list(outputDirectory, ...
                        filename, []);
                    dependencyList = [dependencyList ...
                        struct('name', filename, ...
                        'children', unique_grandchildren(classDependencyList), ...
                        'hasParent', false)]; %#ok<AGROW>
                else
                    dependencyList = create_dependency_list(outputDirectory, ...
                        filename, dependencyList);
                end
                continue;
            end

            % Skip files unless they have a .dependency extension.
            if (isempty(regexp(files(i).name, '\.dependencies$', 'once')))
                continue;
            end

            % Create an element for the current file.
            element = struct('name', regexprep(filename, '\.dependencies$', ''), ...
                'children', [], 'hasParent', false);

            % Read dependencies from file and append to list of children.
            children = [];
            fid = xopen(fullfile(outputDirectory, filename), 'r');
            while 1
                line = fgetl(fid);
                if (~ischar(line))
                    break;
                end
                % Strip class functions from classes in non-class dependency files
                % to be consistent with code above which only adds class to
                % dependency list.
                [direct basename] = fileparts(directory); %#ok<ASGLU>
                [lineDirectory lineBasename] = fileparts(line); %#ok<NASGU>
                [lineDirectory lineBasename] = fileparts(lineDirectory); %#ok<ASGLU>
                if (~strncmp(basename, '@', 1) || ~strcmp(lineBasename, basename))
                    line = regexprep(line, '(@[^/]+)/.*', '$1', 'once');
                end
                children = [children struct('name', line, 'children', [])]; %#ok<AGROW>
            end
            xclose(fid, filename);
            element.children = children;

            % Add element to dependency list.
            dependencyList = [dependencyList element]; %#ok<AGROW>
        end
    end

    function grandchildren = unique_grandchildren(classDependencyList)

        grandchildren = [];
        for i = 1 : length(classDependencyList)
            node = classDependencyList(i);
            for j = 1 : length(node.children)
                if (isempty(grandchildren) ...
                        || ~ismember(node.children(j).name, {grandchildren.name}))
                    grandchildren = [grandchildren node.children(j)]; %#ok<AGROW>
                end
            end
        end

    end

%% Pass 3
%
% For each item in the list, fill out its children's children recursively
% by using the original list. For each descendent, mark its hasParent field
% as true in the original list.
%%

    function [dependencyList dependencyTrees] = create_dependency_trees(dependencyList)

        disp('Pass 3: Building dependency tree');

        dependencyTrees = [];
        for i = 1 : length(dependencyList)
            node = dependencyList(i);
            [dependencyList, tree] = create_dependency_tree_intern(dependencyList, node, []);
            dependencyTrees = [dependencyTrees, tree]; %#ok<AGROW>
        end
    end

    function [dependencyList dependencyTree] = create_dependency_tree_intern(dependencyList, parent, seenList)

        % Expand leaf nodes from original nodes.
        if (isempty(parent.children))
            parent.children = retrieveChildren(dependencyList, parent.name);
        end
        if (~ismember(parent.name, seenList))
            seenList{end+1} = parent.name;
        end

        % Expand leaf nodes recursively.
        for i = 1 : length(parent.children)
            node = parent.children(i);
            % Skip this child if we've already seen it on this recursion to avoid
            % infinite loop.
            if (ismember(node.name, seenList))
                continue;
            end
            seenList{end+1} = node.name; %#ok<AGROW>
            [dependencyList parent.children(i)] ...
                = create_dependency_tree_intern(dependencyList, node, seenList);

            % Mark those children in original list as having parents.
            index = findNodeIndex(dependencyList, node.name);
            if (index > 0)
                dependencyList(index).hasParent = true;
            end
        end

        dependencyTree = parent;

    end

    function children = retrieveChildren(list, name)

        index = findNodeIndex(list, name);
        if (index > 0)
            children = list(index).children;
        else
            children = [];
        end

    end

    function index = findNodeIndex(list, name)

        [tf loc] = ismember(name, {list.name}); %#ok<ASGLU>
        if (~isempty(loc))
            index = loc(1);
        else
            index = 0;
        end

    end

%% Pass 4
%
% For each item in the original list whose hasParent field is false, use
% the dependency tree to create a file for that function with a line for
% each descendent indented according to generation.
%%
    function render_dependency_trees(dependencyList, dependencyTrees, outputDirectory, type)

        % Use .txt for text version, .dot extension for Graphviz version.
        if (strcmp(type, 'dot'))
            disp('Pass 4: Rendering graphical dependency tree');
            extension = '.dot';
            % Avoid printing arrows multiple times.
            seenList = {};
        else
            disp('Pass 4: Rendering textual dependency tree');
            extension = '.txt';
        end

        % For each element in dependencyList whose hasParent field is false,
        % recursively descend into element and render descendents into separate
        % files.
        for i = 1 : length(dependencyList)

            name = dependencyList(i).name;
            depth = 0;
            root = false;
            [tf index] = ismember(name, {functionList.name}); %#ok<ASGLU>
            if (index)
                options = functionList(index).options;
                depth = options.depth;
                root = options.root;
            end

            if (dependencyList(i).hasParent && ~root)
                continue;
            end

            % Open appropriate file for element.
            filename = fullfile(outputDirectory, [name extension]);
            fid = xopen(filename, 'w');

            if (strcmp(type, 'dot'))
                [directory basename] = fileparts(name); %#ok<ASGLU>
                % The @ is illegal in Graphviz digraph names.
                fprintf(fid, 'digraph %s {\n', regexprep(basename, '@', ''));
                fprintf(fid, '  splines = true\n');
            end

            % Locate tree for current element.
            [tf loc] = ismember(name, {dependencyTrees.name}); %#ok<ASGLU>

            % Render tree.
            seenList = [];
            if (isequal(type, 'dot'))
                render_graph(dependencyTrees(loc(1)), depth, 0);
            else
                render_outline(dependencyTrees(loc(1)), depth, 0);
            end

            if (strcmp(type, 'dot'))
                fprintf(fid, '}\n');
            end
            xclose(fid, filename);
        end

        function render_outline(dependencyTree, depth, level)

            % Prune output.
            if (depth > 0 && level > depth)
                return;
            end

            % Display current element in textual tree.
            % Each level in a textual trees is indented two spaces.
            fprintf(fid, ['%' int2str(2*level) 's%s\n'], '', dependencyTree.name);

            % Render children.
            for j = 1 : length(dependencyTree.children)
                render_outline(dependencyTree.children(j), depth, level + 1);
            end
        end

        function render_graph(dependencyTree, depth, level)

            % Prune output.
            if (depth > 0 && level >= depth)
                return;
            end

            % Render children.
            for j = 1 : length(dependencyTree.children)
                % Only render association if we haven't already rendered
                % it. Otherwise, multiple lines will ensue.
                entry = sprintf('"%s" -> "%s"', ...
                    dependencyTree.name, dependencyTree.children(j).name);
                if (~ismember(entry, seenList))
                    seenList{end+1} = entry; %#ok<AGROW>
                    fprintf(fid, '  %s\n', entry);
                end
                render_graph(dependencyTree.children(j), depth, level + 1);
            end
        end

    end
end

