function [paDataObject, paResultsStruct] = ...
process_target_pixels(paDataObject, conditionedAncillaryDataStruct, ...
paResultsStruct)                                                                           %#ok<INUSL>
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [paDataObject, paResultsStruct] = ...
% process_target_pixels(paDataObject, conditionedAncillaryDataStruct, ...
% paResultsStruct)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Process target pixels. Removed cosmic rays if cosmic ray cleaning is
% enabled. Estimate and remove the background from the the target pixels.
% If optimal aperture photometry (OAP) is enabled, then create flux time
% series for each target by OAP. Otherwise, create flux time series for
% each target by simple aperture photometry (SAP).
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

% Get file names.
paFileStruct        = paDataObject.paFileStruct;
paRootTaskDir       = paFileStruct.paRootTaskDir;
paStateFileName     = paFileStruct.paStateFileName;

% Get fields from input structure.
cadenceType             = paDataObject.cadenceType;
backgroundPolyStruct    = paDataObject.backgroundPolyStruct;
configMapObject         = configMapClass(paDataObject.spacecraftConfigMap);

% Get some flags.
paConfigurationStruct           = paDataObject.paConfigurationStruct;
cosmicRayCleaningEnabled        = paConfigurationStruct.cosmicRayCleaningEnabled;
simulatedTransitsEnabled        = paConfigurationStruct.simulatedTransitsEnabled;
oapEnabled                      = paConfigurationStruct.oapEnabled;
targetPrfCentroidingEnabled     = paConfigurationStruct.targetPrfCentroidingEnabled;
ppaTargetPrfCentroidingEnabled  = paConfigurationStruct.ppaTargetPrfCentroidingEnabled;
debugLevel                      = paConfigurationStruct.debugLevel;                                             %#ok<NASGU>


% Get some configurations.
encircledEnergyConfigurationStruct  = paDataObject.encircledEnergyConfigurationStruct;
ppaTargetLabel                      = encircledEnergyConfigurationStruct.targetLabel;

argabrighteningConfigurationStruct  = paDataObject.argabrighteningConfigurationStruct;
mitigationEnabled                   = argabrighteningConfigurationStruct.mitigationEnabled;

targetStarDataStruct = paDataObject.targetStarDataStruct;

cadenceTimes = paDataObject.cadenceTimes;
cadenceNumbers = cadenceTimes.cadenceNumbers;

% Set long and short cadence flags.
if strcmpi(cadenceType, 'long')
    processLongCadence = true;
elseif strcmpi(cadenceType, 'short')
    processLongCadence = false;
end

% Set flag to indicate first call of short cadence processing.
scFirstCall = strcmpi(paDataObject.processingState, 'MOTION_BACKGROUND_BLOBS');

% Identify the Argabrightening cadences if the data are short cadence and
% this is the first call. Gap the long and short cadence target data for
% all Argabrightening cadences (in all invocations) if enabled.
if scFirstCall && mitigationEnabled
    
    tic
    display('process_target_pixels: identifying argabrightening cadences...');
    pixelDataStructArray = [targetStarDataStruct.pixelDataStruct];
    pixelValues = [pixelDataStructArray.values];
    pixelGapIndicators = [pixelDataStructArray.gapIndicators];
    inOptimalAperture = [pixelDataStructArray.inOptimalAperture]';
    clear pixelDataStructArray
    
    [isArgaCadence, argaCadences, argaStatistics] = ...
        identify_argabrightening_cadences(pixelValues( : , ~inOptimalAperture), ...
        pixelGapIndicators( : , ~inOptimalAperture), cadenceNumbers, ...
        argabrighteningConfigurationStruct);                                               %#ok<NASGU>
    nArgaCadences = length(argaCadences);
    save(paStateFileName, 'isArgaCadence', 'argaCadences', ...
            'argaStatistics', '-append');
        
    if nArgaCadences > 0
        [paResultsStruct.alerts] = add_alert(paResultsStruct.alerts, 'warning', ...
            ['Flux, centroids and metrics will be gapped for ', num2str(nArgaCadences), ...
            ' Argabrightening cadence(s)']);
        disp(paResultsStruct.alerts(end).message);
    end % if
    
    duration = toc;
    display(['Argabrightening cadences identified: ' num2str(duration) ...
        ' seconds = '  num2str(duration/60) ' minutes']);
    
end % if

if mitigationEnabled
    load(fullfile(paRootTaskDir, paStateFileName), 'isArgaCadence');
    
    for iTarget = 1 : length(targetStarDataStruct)
        for iPixel = 1 : length(targetStarDataStruct(iTarget).pixelDataStruct)
            targetStarDataStruct(iTarget).pixelDataStruct(iPixel).values(isArgaCadence) = 0;
            targetStarDataStruct(iTarget).pixelDataStruct(iPixel).uncertainties(isArgaCadence) = 0;
            targetStarDataStruct(iTarget).pixelDataStruct(iPixel).gapIndicators(isArgaCadence) = true;
        end % for iPixel
    end % for iTarget
    paDataObject.targetStarDataStruct = targetStarDataStruct;
    paResultsStruct.argabrighteningIndices = find(isArgaCadence);
end % if

% Clean cosmic rays from the target pixels if CR cleaning is enabled.
if cosmicRayCleaningEnabled
    
    % Clean cosmic rays from the target data. Save cleaned data to PA data
    % object. Write events to PA state file so that metrics can be computed
    % later. If this is the last call, copy events to PA results structure.
    tic
    display('process_target_pixels: cleaning target cosmic rays...');
    [paDataObject, paResultsStruct] = ...
        clean_target_cosmic_rays(paDataObject, paResultsStruct);
    duration = toc;
    display(['Target cosmic rays cleaned: ' num2str(duration) ...
        ' seconds = '  num2str(duration/60) ' minutes']);

end


% For short cadence processing, on the first invocation gap fill and update
% the background polynomial struct in paDataObject and in pa_state.mat. The
% long cadence background polynomials are attached to the paDataObject as
% read from the background blob on the first invocation only. 
% For long cadence processing, the background polynomials are already gap
% filled and saved to the pa_state file after background polynomial
% fitting. The file pa_background.mat contains the original (un-gap filled)
% polynomials which are what get saved to the background polynomial blob.
if scFirstCall
    [backgroundPolyStruct] = ...
        fill_background_polynomial_struct_array(backgroundPolyStruct, ...
        configMapObject, cadenceTimes, 'SHORT');
    paDataObject.backgroundPolyStruct = backgroundPolyStruct;
    save(paStateFileName, 'backgroundPolyStruct', '-append');
end % if


% Inject simulated transits just prior to aperture photometry.
if simulatedTransitsEnabled
    [paDataObject, paResultsStruct] = input_simulated_transits(paDataObject, paResultsStruct);
end % if


% 9/3/10
% BACKGROUND REMOVAL NOW DONE PER TARGET IN THE APERTURE PHOTOMETRY METHODS.

% % Estimate and remove the background from the target pixels. Update the
% % target pixel time series within the paDataObject.
% tic
% display('process_target_pixels: removing background...');
% [paDataObject] = ...
%     remove_background_from_targets(paDataObject);
% duration = toc;
% display(['Background removed: ' num2str(duration) ...
%     ' seconds = '  num2str(duration/60) ' minutes']);


% Perform aperture photometry. Perform optimal aperture photometry if OAP is
% enabled, otherwise perform simple aperture photometry.
if oapEnabled
    
    tic
    display('process_target_pixels: performing OAP...');
    % THIS IS OBVIOUSLY TEMPORARY.
    error('PA:processTargetPixels:optionNotSupported', ...
        'OAP is not currently supported')  
    [paDataObject, paResultsStruct] = ...
        perform_optimal_aperture_photometry(paDataObject, conditionedAncillaryDataStruct, ...
        paResultsStruct);                                                                  %#ok<UNRCH>
    duration = toc;
    display(['OAP performed: ' num2str(duration) ...
        ' seconds = '  num2str(duration/60) ' minutes']);
    
else % oap is not enabled
    
    tic
    display('process_target_pixels: performing SAP...');
    [paDataObject, paResultsStruct] = ...
        perform_simple_aperture_photometry(paDataObject, paResultsStruct);
    duration = toc;
    display(['SAP performed: ' num2str(duration) ...
        ' seconds = '  num2str(duration/60) ' minutes']);
        
end % if oapEnabled / else

% Compute the rolling band contamination flags per target and cadence. The
% flags should be gapped when the raw flux value for the given target is
% gapped.
[paResultsStruct] = ...
    set_rolling_band_contamination_flags(paDataObject, paResultsStruct);

% Compute the target row and column centroids on a cadence by cadence
% basis. If the motion polynomial structure is empty, attempt to fit motion
% polynomials for the PPA targets. Then evaluate the motion polynomials for
% the rest of the targets in this and subsequent invocations to establish
% seeds for centroiding. Convert the motion polynomials to a blob for
% output on the last invocation.
nTargets = length(targetStarDataStruct);
targetList = 1 : nTargets;

[isPpaTarget] = ...
    identify_targets(ppaTargetLabel, {targetStarDataStruct.labels});
ppaTargetList = find(isPpaTarget);

if any(isPpaTarget)
    tic
    display('process_target_pixels: computing ppa target centroids...');
    if ppaTargetPrfCentroidingEnabled && ~simulatedTransitsEnabled
        centroidType = 'best';
    else
        centroidType = 'flux-weighted';
    end
    [paDataObject, paResultsStruct] = ...
        compute_target_centroids(paDataObject, paResultsStruct, ...
        centroidType, ppaTargetList);
    duration = toc;
    display(['Centroids computed for PPA targets: ' num2str(duration) ...
        ' seconds = '  num2str(duration/60) ' minutes']);
end % if
        
        
% Compute the centroids for the general targets.
targetList = setdiff(targetList, ppaTargetList);

if ~isempty(targetList)
    tic
    display('process_target_pixels: computing general target centroids...');
    if targetPrfCentroidingEnabled
        centroidType = 'best';
    else
        centroidType = 'flux-weighted';
    end
    [paDataObject, paResultsStruct] = ...
        compute_target_centroids(paDataObject, paResultsStruct, ...
        centroidType, targetList);
    duration = toc;
    display(['Centroids computed for general targets: ' num2str(duration) ...
        ' seconds = '  num2str(duration/60) ' minutes']);
end % if

% Save the target results structures to the state file so that the motion
% polynomials can be computed from all of the centroids in the final call.
% Save the target data (with background removed) and results structures for
% the PPA targets to the PA state file. The motion polynomials and the PPA
% metrics are only computed in the long cadence case.
if processLongCadence
    display('process_target_pixels: saving target data and results...');
    save_target_structures(paDataObject, paResultsStruct);
end % if

% Return.
return
