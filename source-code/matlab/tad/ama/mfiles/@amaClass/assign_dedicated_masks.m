function [status, assignedMaskStruct, maskDefinitions, amaObject] ...
    = assign_dedicated_masks( amaObject, ...
    targetStruct, ap, apCenter, maskDefinitions )
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [status, assignedMaskStruct] = assign_dedicated_masks( amaObject, ...
%     targetStruct, maskDefinitions )
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
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

assignedMaskStruct.numMasks = 0; % allows for the possibility of multiple masks to be assigned to this target
assignedMaskStruct.componentMasks(1).maskIndex = 0;
assignedMaskStruct.componentMasks(1).centerOffset = [0, 0];
assignedMaskStruct.componentMasks(1).numPixInAp = 0;
assignedMaskStruct.componentMasks(1).numPixInMask = 0;
status = -1;

% search the mask definitions to see if a mask matching the input 
apTargetDefinition = image_to_target_definition(ap, apCenter);
sortedApRows = sort([apTargetDefinition.offsets.row]);
sortedApCols = sort([apTargetDefinition.offsets.column]);

for m=1:length(maskDefinitions)
    if length(maskDefinitions(m).offsets) == length(apTargetDefinition.offsets)
        if all(sortedApRows == sort([maskDefinitions(m).offsets.row])) ...
                && all(sortedApCols == sort([maskDefinitions(m).offsets.column]))
            assignedMaskStruct.numMasks = 1; 
            assignedMaskStruct.componentMasks(1).maskIndex = m;
            assignedMaskStruct.componentMasks(1).centerOffset = [0, 0];
            assignedMaskStruct.componentMasks(1).numPixInAp = length(apTargetDefinition.offsets);
            assignedMaskStruct.componentMasks(1).numPixInMask = length(maskDefinitions(m).offsets);
            status = 1;
            return;
        end
    end
end

% there is no mask in the mask table matching the input, so create one
if amaObject.numDedicatedMasks >= amaObject.maskTableParametersStruct.nAssignedCustomMasks
    warning('ama:assigned_dedicated_masks: no more dedicated masks available');
    return;
end

% compute this mask index
maskIndex = amaObject.maskTableParametersStruct.nStellarMasks ...
    + amaObject.numDedicatedMasks + 1;
% create the mask exactly matching the input aperture
maskDefinitions(maskIndex).maskIndex = maskIndex;
maskDefinitions(maskIndex).offsets = apTargetDefinition.offsets;
maskDefinitions(maskIndex).nOffsets = length(apTargetDefinition.offsets);
[maskDefinitions(maskIndex).mask maskDefinitions(maskIndex).center] ...
    = target_definition_to_image(maskDefinitions(maskIndex));
maskDefinitions(maskIndex).size = size(maskDefinitions(maskIndex).mask);
% get the bounding box etc. of the mask
[area, numRowsInAp, numColsInAp, maskDefinitions(maskIndex).apertureBoundingBox] = ...
    square_ap(maskDefinitions(maskIndex).mask); % find the bounding box of the ap    

assignedMaskStruct.numMasks = 1; 
assignedMaskStruct.componentMasks(1).maskIndex = maskIndex;
assignedMaskStruct.componentMasks(1).centerOffset = [0, 0];
assignedMaskStruct.componentMasks(1).numPixInAp = length(apTargetDefinition.offsets);
assignedMaskStruct.componentMasks(1).numPixInMask = length(maskDefinitions(maskIndex).offsets);

amaObject.numDedicatedMasks = amaObject.numDedicatedMasks + 1;
status = 1;
