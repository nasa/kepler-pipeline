function [paDataObject, paResultsStruct] = ...
clean_target_cosmic_rays(paDataObject, paResultsStruct)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [paDataObject, paResultsStruct] = ...
% clean_target_cosmic_rays(paDataObject, paResultsStruct)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Clean cosmic rays from the target pixel time series. Save them to the
% PA state file with the cosmic ray events from prior invocations for later
% computation of the target cosmic ray metrics. Use median filtering and
% MAD based cosmic ray removal function. Do not identify or clean cosmic
% rays on reaction wheel zero-crossing cadences.
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
paFileStruct = paDataObject.paFileStruct;
paStateFileName = paFileStruct.paStateFileName;

cadenceTimes = paDataObject.cadenceTimes;
timestamps = cadenceTimes.midTimestamps;

targetStarDataStruct = paDataObject.targetStarDataStruct;

% Get reaction wheel zero crossing indices (one-based) from the PA results
% structure and convert to a logical array of indicators.
reactionWheelZeroCrossingIndicators = false(length(timestamps), 1);
reactionWheelZeroCrossingIndicators(paResultsStruct.reactionWheelZeroCrossingIndices) = true;

% Get row and column coordinates of target pixels, and create arrays of
% target pixels and gap indicators.
pixelDataStructArray = [targetStarDataStruct.pixelDataStruct];
ccdRows = [pixelDataStructArray.ccdRow]';
ccdColumns = [pixelDataStructArray.ccdColumn]';
targetValues = [pixelDataStructArray.values];
originalTargetGapIndicators = [pixelDataStructArray.gapIndicators];
clear pixelDataStructArray

% Identify the cosmic ray events.
nTargets = length(targetStarDataStruct);

cosmicRayCleanerObject = paCosmicRayCleanerClass(paDataObject);
if ~paDataObject.cosmicRayConfigurationStruct.cleanZeroCrossingCadencesEnabled
    cosmicRayCleanerObject.set_exclude_cadences( ...
        reactionWheelZeroCrossingIndicators);
end

% ---------------------------------- K2 -----------------------------------
% If processing K2 data, exclude cadences near thrusterfirings as specified
% in cosmicRayConfigurationStruct. In the BACKGROUND processing state, the
% thruster firing flags are in the subtask state file, while for all other
% processing states they are found in the root-level (group directory)
% state file.
processingK2Data = paDataObject.cadenceTimes.startTimestamps(1) > ...
    paDataObject.fcConstants.KEPLER_END_OF_MISSION_MJD;
if processingK2Data
    paStateFilePath = fullfile(char(get_cwd_parent), ...
        paDataObject.paFileStruct.paStateFileName);   
    load(paStateFilePath, 'thrusterFiringEvents');

    cosmicRayCleanerObject.set_k2_thruster_activity_exclude_cadences( ...
        thrusterFiringEvents, paDataObject.cosmicRayConfigurationStruct.k2TargetThrusterFiringExcludeHalfWindow);
        
    clear thrusterFiringEvents
end
% ---------------------------------- K2 -----------------------------------

[cosmicRayCorrectedValues, cosmicRayEventsIndicators] = ...
    cosmicRayCleanerObject.get_corrected_flux_and_event_indicator_matrices;

if ~any(cosmicRayEventsIndicators( : ))
    [paResultsStruct.alerts] = ...
        add_alert(paResultsStruct.alerts, 'warning', ...
        'no target cosmic rays were detected');
    disp(paResultsStruct.alerts(end).message);
end

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
    
    pixelIndex = 1;
    
    for iTarget = 1 : nTargets
    
        targetDataStruct = targetStarDataStruct(iTarget);
        nPixels = length(targetDataStruct.pixelDataStruct);

        values = targetValues( : , pixelIndex : pixelIndex + nPixels - 1);
        valuesCellArray = num2cell(values, 1);
        [targetDataStruct.pixelDataStruct(1 : nPixels).values] = ...
            valuesCellArray{:};
        
        targetStarDataStruct(iTarget) = targetDataStruct;
        pixelIndex = pixelIndex + nPixels;
        
    end % for iTarget

    paDataObject.targetStarDataStruct = targetStarDataStruct;
    
end % if

% Save cosmic ray events, pixel coordiantes and corresponding gap time
% series to state file. 
pixelCoordinates = [ccdRows(:), ccdColumns(:)];
pixelGaps = sparse(logical(originalTargetGapIndicators));
save(paStateFileName, 'cosmicRayEvents', 'pixelCoordinates', ...
    'pixelGaps', '-append');

%Return
return
