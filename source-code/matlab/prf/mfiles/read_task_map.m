function taskMapArray = read_task_map(filename)
% function taskMapArray = read_task_map(filename)
%
% taskMapArray(iteration, channel).instanceId
% taskMapArray(iteration, channel).nodeId
% taskMapArray(iteration, channel).taskId
% taskMapArray(iteration, channel).module
% taskMapArray(iteration, channel).output
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

%%
[instanceId, nodeId, taskId, modOrOut, type] = textread(filename, '%d,%d,%d,%d,%s');
%%
nChannels = 84;

% there are two entries per channel
nEntriesPerIteration = nChannels*2;

uniqueNodeIds = unique(nodeId);
% account for partial iterations
numUniqueNodeIds = length(uniqueNodeIds);
for i=1:numUniqueNodeIds
    nodeIdsInThisIteration = find(nodeId == uniqueNodeIds(i));
    if  length(nodeIdsInThisIteration) ~= nEntriesPerIteration
        % this is a partial iteration, remove it from the list
        % iteratively removing entries is OK because partial iterations
        % should be the last in the list
        if i ~= numUniqueNodeIds
            error('partial iteration that is not the last node ID in the list');
        end
        instanceId(nodeIdsInThisIteration) = [];
        nodeId(nodeIdsInThisIteration) = [];
        taskId(nodeIdsInThisIteration) = [];
        modOrOut(nodeIdsInThisIteration) = [];
        type(nodeIdsInThisIteration) = [];
        uniqueNodeIds(i) = [];
    end
end
% count the number of iterations
nIterations = length(uniqueNodeIds);

for entry=1:2:length(instanceId)
    % check that we're in sync
    if taskId(entry) ~= taskId(entry+1)
        error('out of sync');
    end
    switch type{entry}
        case 'ccdModule'
            module = modOrOut(entry);
            output = modOrOut(entry+1);
            
        case 'ccdOutput'
            module = modOrOut(entry+1);
            output = modOrOut(entry);
    end
    iteration = floor(entry/nEntriesPerIteration) + 1;
    channel = convert_from_module_output(module, output);
    
    taskMapArray(iteration, channel).instanceId = instanceId(entry);
    taskMapArray(iteration, channel).nodeId = nodeId(entry);
    taskMapArray(iteration, channel).taskId = taskId(entry);
    taskMapArray(iteration, channel).module = module;
    taskMapArray(iteration, channel).output = output;
end