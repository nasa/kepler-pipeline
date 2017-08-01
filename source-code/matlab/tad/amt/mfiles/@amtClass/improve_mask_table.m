function amtObject = improve_mask_table(amtObject)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function amtObject = improve_mask_table(amtObject)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function which improves the existing mask table by matching it to most
% poorly fit apertures
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

% maxPixelsInMask = amtObject.amtConfigurationStruct.maxPixelsInMask; % 85
maxPixelsInSmallMask = amtObject.amtConfigurationStruct.maxPixelsInSmallMask; % include buffer to allow large masks
nStellarMasks = amtObject.maskTableParametersStruct.nStellarMasks;

% perform a mask assignment in order to find poorly fit apertures
amaParameterStruct.maskDefinitions = amtObject.maskDefinitions;
amaParameterStruct.apertureStructs = amtObject.apertureStructs;
amaParameterStruct.fcConstants = amtObject.fcConstants;
amaParameterStruct.amaConfigurationStruct = amtObject.amaConfigurationStruct;
amaParameterStruct.maskTableParametersStruct = amtObject.maskTableParametersStruct;
amaParameterStruct.debugFlag = amtObject.debugFlag;

% fit the masks, remembering that we're in 1-base indexing
amaResultStruct = ama_matlab_controller_1_base(amaParameterStruct);

% find the unique apertures in the input set
% uniqueAps will have halos if so ordered
[uniqueAps apsMap] = find_unique_apertures(amaParameterStruct.apertureStructs, ...
    amaParameterStruct.amaConfigurationStruct);

% sort the unique apertures in order of total number of excess pixels
% caused by that aperture
% first sum the excess pixels for each unique aperture
apExcess = zeros(length(uniqueAps));
for a=1:length(uniqueAps)
    % find the target definitions using this unique aperture
    % first find the set of Kepler IDs of the apertures that use this
    % unique aperture
    idSet = [amaParameterStruct.apertureStructs(apsMap == a).keplerId];
    % find the target definitions applied to each of these Kepler IDs.  We
    % have to be careful because there may be more than one target
    % definition for each Kepler ID.  
    targetIndices = find(ismember([amaResultStruct.targetDefinitions.keplerId], idSet));
    targetSet = amaResultStruct.targetDefinitions(targetIndices);
    % sum the excess pixels for those target definitions - gives the total
    % number of missed pixels due to each unique aperture
    apExcess(a) = sum([targetSet.excessPixels]);
end
% find the perfectly fit apertures
noExcess = find([amaResultStruct.targetDefinitions.excessPixels] == 0);
% find the perfect masks
perfectMasks = unique([amaResultStruct.targetDefinitions(noExcess).maskIndex]);
% sort the apertures by the number of missed pixels for each unique
% aperture
[sortedApExcess apExcessSortIndex] = sort(apExcess, 'descend');
% replace poorly fit or unused masks in the mask table with unique
% apertures, in descending order of number of pixels missed
currentReplacementAp = 1;
replacedMasks = zeros(length(amtObject.maskDefinitions), 1);
for m = 1:nStellarMasks
    % find a non-perfect mask
    if ~ismember(m, perfectMasks) || length(amtObject.maskDefinitions(m).offsets) > maxPixelsInSmallMask;
        if apExcess(apExcessSortIndex(currentReplacementAp)) > 0 % if this aperture caused some excess
            while length(uniqueAps(apExcessSortIndex(currentReplacementAp)).offsets) ...
                > maxPixelsInSmallMask; % make sure the aperture is not too big
                currentReplacementAp = currentReplacementAp + 1; % if it's too big try the next one
                if currentReplacementAp > length(uniqueAps)
                    break;
                end
            end
            % replace it with the next aperture in the sorted list
            % zero apertures are at end of sorted list
            if currentReplacementAp <= length(uniqueAps)
                replacedMasks(m) = 1;
                amtObject.maskDefinitions(m).offsets = ...
                	uniqueAps(apExcessSortIndex(currentReplacementAp)).offsets;
            end
        end
        currentReplacementAp = currentReplacementAp + 1;
        if currentReplacementAp > length(uniqueAps)
            break;
        end
    end
end
% for some reason the replaced masks will be single precision, and mixed
% types makes later code upset.  Therefore we do the following.
for m = 1:length(amtObject.maskDefinitions)
    for i=1:length(amtObject.maskDefinitions(m).offsets)
        amtObject.maskDefinitions(m).offsets(i).row = ...
            double(amtObject.maskDefinitions(m).offsets(i).row);
        amtObject.maskDefinitions(m).offsets(i).column = ...
            double(amtObject.maskDefinitions(m).offsets(i).column);
    end
end

