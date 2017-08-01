function [prfCreationObject, prfResultStruct] = ...
clean_target_cosmic_rays(prfCreationObject, prfResultStruct)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [prfCreationObject, prfResultStruct] = ...
% clean_target_cosmic_rays(prfCreationObject, prfResultStruct)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Clean cosmic rays from the target pixel time series. Use SVD based
% cosmic ray removal function.
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
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

% Get fields from input object.
cadenceTimes = prfCreationObject.cadenceTimes;
timestamps = cadenceTimes.midTimestamps;

prfConfigurationStruct = prfCreationObject.prfConfigurationStruct;
falseCrRejectionRate = prfConfigurationStruct.falseCrRejectionRate;

targetStarsStruct = prfCreationObject.targetStarsStruct;

% Get row and column coordinates of target pixels, and create arrays of
% target pixels and gap indicators.
pixelDataStructArray = [targetStarsStruct.pixelTimeSeriesStruct];
ccdRows = [pixelDataStructArray.row]';
ccdColumns = [pixelDataStructArray.column]';
targetValues = [pixelDataStructArray.values];

gapIndicesCellArray = {pixelDataStructArray.gapIndices};
targetGapIndicators = false(size(targetValues));
for iPixel = 1 : length(gapIndicesCellArray)
    targetGapIndicators(gapIndicesCellArray{iPixel}, iPixel) = true;
end

% Identify the cosmic ray events.
[cosmicRayCorrectedValues, cosmicRayEventsIndicators] = ...
    clean_cosmic_rays_svd(targetValues, targetGapIndicators, ...
    falseCrRejectionRate);

% Create the cosmic ray events list.
[cosmicRayEvents] = create_cosmic_ray_events_list(targetValues, ...
    cosmicRayEventsIndicators, cosmicRayCorrectedValues, ...
    ccdRows, ccdColumns, timestamps);

% Clean and update the target pixels on a target by target basis.
nEvents = length(cosmicRayEvents);

if nEvents > 0

    targetValues(cosmicRayEventsIndicators) = ...
        cosmicRayCorrectedValues(cosmicRayEventsIndicators);
    clear cosmicRayCorrectedValues cosmicRayEventsIndicators
    
    nTargets = length(targetStarsStruct);
    pixelIndex = 1;
    
    for iTarget = 1 : nTargets
    
        targetDataStruct = targetStarsStruct(iTarget);
        nPixels = length(targetDataStruct.pixelTimeSeriesStruct);

        values = targetValues( : , pixelIndex : pixelIndex + nPixels - 1);
        valuesCellArray = num2cell(values, 1);
        [targetDataStruct.pixelTimeSeriesStruct(1 : nPixels).values] = ...
            valuesCellArray{:};
        
        targetStarsStruct(iTarget) = targetDataStruct;
        pixelIndex = pixelIndex + nPixels;
        
    end % for iTarget

    prfCreationObject.targetStarsStruct = targetStarsStruct;
    
end % if

% Remove any duplicate cosmic ray events. Update the results structure with
% the cosmic ray events. MAY NOT WANT TO DO THIS.
cosmicRayEvents = remove_duplicate_cosmic_ray_events(cosmicRayEvents);
prfResultStruct.cosmicRayEvents = cosmicRayEvents;

%Return
return
