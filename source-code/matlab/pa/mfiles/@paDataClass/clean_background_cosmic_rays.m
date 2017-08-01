function [paDataObject, paResultsStruct] = ...
clean_background_cosmic_rays(paDataObject, paResultsStruct)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [paDataObject, paResultsStruct] = ...
% clean_background_cosmic_rays(paDataObject, paResultsStruct)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Clean cosmic rays from the background pixel time series. Save them to the
% PA state file for later computation of the background cosmic ray metrics.
% Use median filtering and MAD threshold based cosmic ray removal function.
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

backgroundDataStruct = paDataObject.backgroundDataStruct;

% Get row and column coordinates of background pixels, and create arrays of
% background pixels and gap indicators.
ccdRows = [backgroundDataStruct.ccdRow]';
ccdColumns = [backgroundDataStruct.ccdColumn]';
backgroundValues = [backgroundDataStruct.values];
backgroundGapIndicators = [backgroundDataStruct.gapIndicators];

% Identify the cosmic ray events.
%
% Note that we do not exclude reaction wheel zero crossing cadences for
% background targets. This is because low-amplitude pointing changes are
% unlikely to produce signals that look like cosmic rays in background
% targets.
cosmicRayCleanerObject = paCosmicRayCleanerClass(paDataObject);

% ---------------------------------- K2 -----------------------------------
% If processing K2 data, exclude cadences near thrusterfirings as specified
% in cosmicRayConfigurationStruct. In the BACKGROUND processing state, the
% thruster firing flags are in the subtask state file, while for all other
% processing states they are found in the root-level (group directory)
% state file.
processingK2Data = paDataObject.cadenceTimes.startTimestamps(1) > ...
    paDataObject.fcConstants.KEPLER_END_OF_MISSION_MJD;
if processingK2Data
    paStateFilePath = paDataObject.paFileStruct.paStateFileName;
    load(paStateFilePath, 'thrusterFiringEvents');

    cosmicRayCleanerObject.set_k2_thruster_activity_exclude_cadences( ...
        thrusterFiringEvents, paDataObject.cosmicRayConfigurationStruct.k2BackgroundThrusterFiringExcludeHalfWindow);
        
    clear thrusterFiringEvents
end
% ---------------------------------- K2 -----------------------------------

[cosmicRayCorrectedValues, cosmicRayEventsIndicators] = ...
    cosmicRayCleanerObject.get_corrected_flux_and_event_indicator_matrices();

if ~any(cosmicRayEventsIndicators( : ))
    [paResultsStruct.alerts] = ...
        add_alert(paResultsStruct.alerts, 'warning', ...
        'no background cosmic rays were detected');
    disp(paResultsStruct.alerts(end).message);
end

% Create the cosmic ray events list.
[cosmicRayEvents] = create_cosmic_ray_events_list(backgroundValues, ...
    cosmicRayEventsIndicators, cosmicRayCorrectedValues, ...
    ccdRows, ccdColumns, timestamps);

% Clean and update the background pixels.
nEvents = length(cosmicRayEvents);

if nEvents > 0

    backgroundValues(cosmicRayEventsIndicators) = ...
        cosmicRayCorrectedValues(cosmicRayEventsIndicators);
    clear cosmicRayCorrectedValues cosmicRayEventsIndicators
    
    nPixels = length(backgroundDataStruct);
    
    valuesCellArray = num2cell(backgroundValues, 1);
    [backgroundDataStruct(1 : nPixels).values] = valuesCellArray{:};
    
    paDataObject.backgroundDataStruct = backgroundDataStruct;
    
end % if

% Remove any duplicate events and save to the PA state file. Update the
% results structure. Also update and save counts of valid pixels for each
% cadence for computation of the cosmic ray hit rate metric. 
%
% NOTE that the cosmicRayEvents state variable is cleared in
% photometric_analaysis.m following background cosmic ray metric
% computation. Backgrouund cosmic ray events are therefore found only in
% the paResultsStruct and not in the state file. The lists of all
% background pixel coordinates and gaps, on the other hand, are aggregated
% in the state file along with target pixels.
load(paStateFileName, 'pixelCoordinates', 'pixelGaps');
cosmicRayEvents = remove_duplicate_cosmic_ray_events(cosmicRayEvents);
[pixelCoordinates, pixelGaps, nValidPixels] = ...
    update_pixel_coordinates_and_gaps(pixelCoordinates, pixelGaps, ...
    ccdRows, ccdColumns, backgroundGapIndicators);                                          %#ok<NASGU,NODEF>
save(paStateFileName, 'cosmicRayEvents', 'pixelCoordinates', ...
    'pixelGaps', 'nValidPixels', '-append');

paResultsStruct.backgroundCosmicRayEvents = cosmicRayEvents;

%Return
return
