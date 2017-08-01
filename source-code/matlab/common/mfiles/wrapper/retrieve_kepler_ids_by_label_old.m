function matchingTargets = retrieve_kepler_ids_by_label(targetListSetName, varargin)
% matchingTargets = retrieve_kepler_ids_by_label(targetListSetName)
% matchingTargets = retrieve_kepler_ids_by_label(targetListSetName, 'labels',     labels)
% matchingTargets = retrieve_kepler_ids_by_label(targetListSetName, 'categories', categories)
% matchingTargets = retrieve_kepler_ids_by_label(targetListSetName, 'labels',     labels,     labelsAndCategoriesAreSubstrings)
% matchingTargets = retrieve_kepler_ids_by_label(targetListSetName, 'categories', categories, labelsAndCategoriesAreSubstrings)
% matchingTargets = retrieve_kepler_ids_by_label(targetListSetName, 'labels',     labels, 'categories', categories)
% matchingTargets = retrieve_kepler_ids_by_label(targetListSetName, 'labels',     labels, 'categories', categories, labelsAndCategoriesAreSubstrings)
%
% INPUTS:
%     taretListSetName                     -- A string specifiying the name of a TargetListSet.
%     labels                               -- [optional] A cell array of Label substrings (strings).
%     categories                           -- [optional] A cell array of Category substrings (strings).
%     labelsAndCategoriesAreSubstrings     -- [optional] a boolean flag.  If true, the contents of the
%                                             labels and categories inputs will be matched only
%                                             to exact matches.  By default, these input 
%                                             arguments are matched as substrings.
%
% OUTPUTS:
%     matchingTargets(nTargets)  -- A struct array with the following fields:
%          keplerId              -- The target's keplerId .
%          labels{nLabels, 2}    -- A cell array of label/targetListName pairs.
%                                   If the same label is in multiple target lists,
%                                   each target list will have a row in this field.
%          labelToTargetListName -- a struct of label --> {list of target list names}
%          targetListNameToLabel -- a struct of target list name --> {labels}
%          catagories            -- a cell array of matching categories
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


    inputLists.labels = {};
    inputLists.categories = {};
    inputListsFields = fieldnames(inputLists);
    
    switch nargin
        case 1
             % do nothing
             labelsAndCategoriesAreSubstrings = false;
        case 3
            inputLists.(varargin{1}) = varargin{2};
            labelsAndCategoriesAreSubstrings = false;
        case 4
            inputLists.(varargin{1}) = varargin{2};
            labelsAndCategoriesAreSubstrings = logical(varargin{3});
        case 5
            inputLists.(varargin{1}) = varargin{2};
            inputLists.(varargin{3}) = varargin{4};
            labelsAndCategoriesAreSubstrings = false;
        case 6
            inputLists.(varargin{1}) = varargin{2};
            inputLists.(varargin{3}) = varargin{4};
            labelsAndCategoriesAreSubstrings = logical(varargin{5});
        otherwise
            help retrieve_kepler_ids_by_label
            error('Matlab:common:wrapper:retrieve_kepler_ids_by_label', ...
                  'Incorrect number of args.  5, 3, or 1 args are allowed.  Please see the above helptext.')
    end

    % Verify there weren't any misspellings that added fields to the inputLists struct 
    % in the list name specification strings:
    %   
    if ~isequal(inputListsFields, fieldnames(inputLists))
            error('Matlab:common:wrapper:retrieve_kepler_ids_by_label', ...
                  'Error in list names: only "labels" and "categories" are allowed as list name specifiers')
    end

    % Copy the contents of labels and categories into Java Lists (necessary for
    % the retrievePlannedTargets call)
    %
    labelsList = cell_array_to_java_list(inputLists.labels);
    categoriesList = cell_array_to_java_list(inputLists.categories);

    % Run CRUD method:
    %
    import gov.nasa.kepler.hibernate.cm.TargetSelectionCrud;
    targetSelectionCrud = TargetSelectionCrud();
    targets = targetSelectionCrud.retrievePlannedTargets(targetListSetName, labelsList, categoriesList, labelsAndCategoriesAreSubstrings);

    % Construct output struct array from the Java objects that TargetSelectionCrud returns:
    %
    matchingTargets = repmat(struct('keplerId', [], 'category', [], 'labels', []), 1, targets.size());
    for ii_matlab = 1:targets.size()
        ii_java = ii_matlab - 1; % Java indexing
        target =  targets.get(ii_java);
        
        % Unpack Kepler ID:
        %
        matchingTargets(ii_matlab).keplerId = target.getKeplerId;
        matchingTargets(ii_matlab).category = char(target.getTargetList.getCategory);
        
        % Unpack labels.  Package them into a Nx2 cell array.  Column 1 is the
        % label, column 2 is the name of the target list that label was found in.  
        %
        labels = target.getLabels.toArray;
        for ilabel = 1:length(labels)
            matchingTargets(ii_matlab).labels{ilabel, 1} = labels(ilabel);
            matchingTargets(ii_matlab).labels{ilabel, 2} = char(target.getTargetList.getName);
        end
    end
    
    % If a target is in more than one target list, there will be multiple
    % entries in matchingTargets with the same Kepler ID, but different labels.
    % This function produces a list of targets with unique Kepler IDs and a
    % complete list of label/targetListName pairs.
    % 
    matchingTargets = make_unique_kepler_ids(matchingTargets);
    matchingTargets = create_label_to_target_list_mapping(matchingTargets);
    matchingTargets = create_target_list_to_label_mapping(matchingTargets);
return

function uniqueTargets = make_unique_kepler_ids(targets)
    % Return nothing if the input is empty:
    %
    if isempty(targets)
        uniqueTargets = [];
        return;
    end


    % Get a list of the unique Kepler IDs:
    %
    keplerIds = [targets.keplerId];
    uniqueKeplerIds = unique(keplerIds);
    uniqueTargets = repmat(struct('keplerId', [], 'category', [], 'labels', []), 1, length(uniqueKeplerIds));
    
    for ii = 1:length(uniqueKeplerIds)

        indexUnique = find(keplerIds == uniqueKeplerIds(ii));

        % If this entry in "targets" has a unique Kepler ID, just copy it into the outputs:
        %
        % If there are multiple entres in "targets" with this Kepler ID,
        % create a SINGLE output entry.  Concatenate the labels into one
        % list.
        %
        if length(indexUnique) == 1
            uniqueTargets(ii) = targets(indexUnique);
        elseif length(indexUnique) > 1
            % Assign the keplerId and initialize the labels field:
            %
            uniqueTargets(ii).keplerId = targets(indexUnique(1)).keplerId;
            uniqueTargets(ii).labels = {};
            uniqueTargets(ii).category = {};
            
            
            % Concatenate the label cell arrays onto the end of the
            % uniqueTargets entry's labels field:
            %
            for jj = 1:length(indexUnique)
                newLabels = targets(indexUnique(jj)).labels;
                
                for ilabel = 1:size(newLabels, 1)
                    uniqueTargets(ii).labels{end+1, 1} = newLabels{ilabel, 1};
                    uniqueTargets(ii).labels{end,   2} = newLabels{ilabel, 2};
                    
                    uniqueTargets(ii).category{end+1} = targets(indexUnique(1)).category;
                end
            end
        else
            error('Matlab:common:wrapper:retrieve_kepler_ids_by_label', ...
                  'Error in running "unique" in retrieve_kepler_ids_by_label:make_unique_kepler_ids');
        end
    end
return

function matchingTargets = create_label_to_target_list_mapping(matchingTargets)
% Create a parallel labelToTargetListName struct out of the list of (name,targetListName) labels:
%
    for itarget = 1:length(matchingTargets)
        matchingTargets(itarget).labelToTargetListName = struct();

        for ilabel = 1:size(matchingTargets(itarget).labels, 1)
            [name label] = get_name_and_label(matchingTargets(itarget), ilabel);

            nEntries = get_number_of_map_entries(matchingTargets(itarget).labelToTargetListName, name);
            matchingTargets(itarget).labelToTargetListName.(name){nEntries+1} = label;
        end
    end
return

function matchingTargets = create_target_list_to_label_mapping(matchingTargets)
% Create a parallel targetListNameToLabel struct out of the list of (name,targetListName) labels:
%
    for itarget = 1:length(matchingTargets)
        matchingTargets(itarget).targetListNameToLabel = struct();

        for ilabel = 1:size(matchingTargets(itarget).labels, 1)
            [name label] = get_name_and_label(matchingTargets(itarget), ilabel);
            % replace all "." characters with "_" characters ("." is a forbidden fieldname character in structs):
            label = regexprep(label, '\.', '_');

            nEntries = get_number_of_map_entries(matchingTargets(itarget).targetListNameToLabel, label);
            matchingTargets(itarget).targetListNameToLabel.(label){nEntries+1} = name;
        end
    end
return

function [name label] = get_name_and_label(target, ii)
    name  = target.labels{ii, 1};
    label = target.labels{ii, 2};
return

function nEntries = get_number_of_map_entries(map, field)
    nEntries = 0;
    if isfield(map, field)
        nEntries = length(map.(field));
    end
return

function javaList = cell_array_to_java_list(cellArray) 
    import java.util.ArrayList

    javaList = ArrayList();
    for ii = 1:length(cellArray)
        javaList.add(cellArray{ii});
    end
return
