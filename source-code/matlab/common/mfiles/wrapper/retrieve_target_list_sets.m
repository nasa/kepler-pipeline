function targetListSets = retrieve_target_list_sets()
%function targetListSets = retrieve_target_list_sets()
%
% Returns a struct similar to the following:
%
% 1x3 struct array with fields:
%    name
%    type
%    state
%    startDate
%    endDate
%    targetLists
%    excludedTargetLists
%
% >> tls(1)
%
% ans = 
%
%                   name: 'a-lc'
%                   type: 'Long cadence'
%                  state: 'TAD completed and validated'
%              startDate: '2010-06-24 05:00:00.0'
%                endDate: '2010-09-12 05:00:00.0'
%            targetLists: [1x20 struct]
%    excludedTargetLists: [1x0 struct]
%
% >> tls(1).targetLists(1)
%
% ans = 
%
%          name: 'a-lc-asteroseismology.txt'
%      category: 'Asteroseismology'
%        source: '/path/to/rec/so/target-lists/latest/a-lc-asteroseismology.txt'
%    sourceType: 'FILE'
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

import gov.nasa.kepler.hibernate.cm.TargetSelectionCrud;
import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;

dbService = DatabaseServiceFactory.getInstance;
targetSelectionCrud = TargetSelectionCrud(dbService);

javaTargetListSets = targetSelectionCrud.retrieveAllTargetListSets.toArray;

if(isempty(javaTargetListSets))
    targetListSets = [];
    SandboxTools.close;
    return;
end;

targetListSets = repmat(struct('name', [], 'type', [], 'state', [], 'startDate', [], ...
    'endDate', [], 'targetLists', [], 'excludedTargetLists', []), 1, length(javaTargetListSets));

for i = 1:length(javaTargetListSets)
    javaTargetListSet = javaTargetListSets(i);
    
    javaTargetLists = javaTargetListSet.getTargetLists.toArray;
    javaExcludedTargetLists = javaTargetListSet.getExcludedTargetLists.toArray;

    targetListSets(i).name = java_string_to_chars(javaTargetListSet.getName);
    targetListSets(i).type = java_string_to_chars(javaTargetListSet.getType.toString);
    targetListSets(i).state = java_string_to_chars(javaTargetListSet.getState.toString);
    targetListSets(i).startDate = java_string_to_chars(javaTargetListSet.getStart.toString);
    targetListSets(i).endDate = java_string_to_chars(javaTargetListSet.getEnd.toString);
    
    targetListSets(i).targetLists = copyTargetListInfo(javaTargetLists);
    targetListSets(i).excludedTargetLists = copyTargetListInfo(javaExcludedTargetLists);    
end;

% Clear Hibernate cache
import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
dbService = DatabaseServiceFactory.getInstance;
dbService.clear;

SandboxTools.close;
return;

% copy the relevant fields from the Java List<TargetList> to the
% MATLAB struct array
function matlabTargetLists = copyTargetListInfo(javaTargetLists)

matlabTargetLists = repmat(struct('name', [], 'category', [], 'source', [], 'sourceType', []), 1, length(javaTargetLists));

for i = 1:length(javaTargetLists)
    matlabTargetLists(i).name = java_string_to_chars(javaTargetLists(i).getName);
    matlabTargetLists(i).category = java_string_to_chars(javaTargetLists(i).getCategory);
    matlabTargetLists(i).source = java_string_to_chars(javaTargetLists(i).getSource);
    matlabTargetLists(i).sourceType = java_string_to_chars(javaTargetLists(i).getSourceType.toString);
end;

return;
