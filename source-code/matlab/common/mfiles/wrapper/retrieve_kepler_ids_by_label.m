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

    import gov.nasa.kepler.systest.sbt.SandboxTools;
    SandboxTools.displayDatabaseConfig;

    import gov.nasa.kepler.systest.sbt.SbtRetrieveKeplerIds;
    sbt = SbtRetrieveKeplerIds();

    switch nargin
        case 1
             pathJava = sbt.retrieveKeplerIds(targetListSetName);
        case 3
            isLabels = get_is_labels(varargin{1});
            labelsOrCategories = make_java_list(varargin{2});
            pathJava = sbt.retrieveKeplerIds(targetListSetName, labelsOrCategories, isLabels);
        case 4
            isLabels = get_is_labels(varargin{1});
            labelsOrCategories = make_java_list(varargin{2});
            isSubstring = varargin{3};
            pathJava = sbt.retrieveKeplerIds(targetListSetName, labelsOrCategories, isLabels, isSubstring);
        case 5
            [labels categories] = get_labels_and_categories(varargin{1}, varargin{2}, varargin{3}, varargin{4});
            pathJava = sbt.retrieveKeplerIds(targetListSetName, labels, categories);
        case 6
            [labels categories] = get_labels_and_categories(varargin{1}, varargin{2}, varargin{3}, varargin{4});
            isSubstring = logical(varargin{5});
            pathJava = sbt.retrieveKeplerIds(targetListSetName, labels, categories, isSubstring);
        otherwise
            error('Matlab:common:wrapper:retrieve_kepler_ids_by_label', ...
                  'Incorrect number of args.  5, 3, or 1 args are allowed.  Please see helptext.')
    end

    path = pathJava.toCharArray()';
    targetsStruct = sbt_sdf_to_struct(path);
    matchingTargets = targetsStruct.targets;
    
    SandboxTools.close;
return
    
function isLabels = get_is_labels(listType)
    switch listType
        case 'labels'
            isLabels = true;
        case 'categories'
            isLabels = false;
        otherwise
            error('Matlab:common:wrapper:retrieve_kepler_ids_by_label', ...
                'List type specifier must be either "labels" or "categories".')
    end
return

function [labels categories] = get_labels_and_categories(listType1, list1, listType2, list2)
    isLabels1 = get_is_labels(listType1);
    isLabels2 = get_is_labels(listType2);

    isFirstLabelsThenCategories = isLabels1 && (~isLabels2);
    isFirstCategoriesThenLabels = (~isLabels1) && isLabels2;

    if isFirstLabelsThenCategories
        labels = make_java_list(list1);
        categories = make_java_list(list2);
    elseif isFirstCategoriesThenLabels
        labels = make_java_list(list2);
        categories = make_java_list(list);
    else
        error('Matlab:common:wrapper:retrieve_kepler_ids_by_label', ...
            'Error in label/category specification: %s or %s are not legal specs', listType1, listType2)
    end
return

function javaList = make_java_list(cellArray) 
    if ~iscell(cellArray)
        cellArray = { cellArray };
    end
    import java.util.ArrayList;
    javaList = ArrayList();
    for ii = 1:length(cellArray)
        javaList.add(cellArray{ii});
    end
return
