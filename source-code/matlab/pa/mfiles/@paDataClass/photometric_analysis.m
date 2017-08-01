function [paResultsStruct] = photometric_analysis(paDataObject)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [paResultsStruct] = photometric_analysis(paDataObject)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Photometric Analysis (PA) is performed for both long and short cadence
% targets.
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
processingState = paDataObject.processingState;

% Get file names
paFileStruct                    = paDataObject.paFileStruct;
paRootTaskDir                   = paFileStruct.paRootTaskDir;
paStateFileName                 = paFileStruct.paStateFileName;
paMotionFileName                = paFileStruct.paMotionFileName;
paOutputUncertaintiesFileName   = paFileStruct.paOutputUncertaintiesFileName;                %#ok<NASGU>

% Get fields from input structure
cadenceType = paDataObject.cadenceType;
firstCall   = paDataObject.firstCall;

cadenceTimes = paDataObject.cadenceTimes;
nCadences    = length(cadenceTimes.midTimestamps);

paConfigurationStruct       = paDataObject.paConfigurationStruct;
cosmicRayCleaningEnabled    = paConfigurationStruct.cosmicRayCleaningEnabled;
oapEnabled                  = paConfigurationStruct.oapEnabled;
simulatedTransitsEnabled    = paConfigurationStruct.simulatedTransitsEnabled;
debugLevel                  = paConfigurationStruct.debugLevel;                                             %#ok<NASGU>

pouConfigurationStruct  = paDataObject.pouConfigurationStruct;
pouEnabled              = pouConfigurationStruct.pouEnabled;
compressionEnabled      = pouConfigurationStruct.compressionEnabled;

% Set long and short cadence flags
if strcmpi(cadenceType, 'long')
    processLongCadence = true;
    processShortCadence = false;
elseif strcmpi(cadenceType, 'short')
    processLongCadence = false;
    processShortCadence = true;
end

% Initialize the PA output structure
[paResultsStruct] = initialize_pa_output_structure(paDataObject);


% Find reaction wheel zero crossing indices on first call
if firstCall
    disp('photometric_analysis: identifying reaction wheel zero crossing cadences...');
    paResultsStruct = identify_rw_zero_crossing_cadences(paDataObject,paResultsStruct);
else
    load(fullfile(paRootTaskDir, paStateFileName), 'reactionWheelZeroCrossingIndicators');
    paResultsStruct.reactionWheelZeroCrossingIndices = find(reactionWheelZeroCrossingIndicators);
end


% Compute the barycentric corrected timestamps for each target
[paResultsStruct] = compute_barycentric_offset_by_target(paDataObject, paResultsStruct);

% Ensure that cosmic ray cleaning is not enabled if there is only one
% cadence. Turn it off, and issue a warning if that is the case
if cosmicRayCleaningEnabled && nCadences < 2
    cosmicRayCleaningEnabled = false;
    paDataObject.paConfigurationStruct.cosmicRayCleaningEnabled = cosmicRayCleaningEnabled;
    [paResultsStruct.alerts] = add_alert(paResultsStruct.alerts, 'warning', ...
        'insufficient number of cadences available for cosmic ray cleaning');
    disp(paResultsStruct.alerts(end).message);
end

% In K2 we have the ability to independently disable cosmic ray cleaning
% for stellar and background targets. Here we check which processing state
% we're in and disable cosmic ray cleaning if necessary.
processingK2Data = paDataObject.cadenceTimes.startTimestamps(1) > ...
    paDataObject.fcConstants.KEPLER_END_OF_MISSION_MJD;
if processingK2Data
    if cosmicRayCleaningEnabled
        if (firstCall && paDataObject.cosmicRayConfigurationStruct.k2BackgroundCleaningEnabled == false) ...
           || (~firstCall && paDataObject.cosmicRayConfigurationStruct.k2TargetCleaningEnabled == false)
            cosmicRayCleaningEnabled = false;
            paDataObject.paConfigurationStruct.cosmicRayCleaningEnabled = cosmicRayCleaningEnabled;
        end
    end
end

% If OAP is enabled then conditioned ancillary data are required. Condition
% the ancillary data and save them for subsequent invocations is the first
% call. Otherwise, load the conditioned ancillary data that was stored in
% the first invocation.
conditionedAncillaryDataStruct = [];

if oapEnabled
    
    % THIS IS OBVIOUSLY TEMPORARY. THE ANCILLARY DATA SYNCHRONIZATION MAY
    % HAVE TO BE RE-THOUGHT FOR PA BEFORE IT WILL WORK FOR OAP. CURRENTLY
    % IT IS ASSUMED THAT THE MOTION POLYNOMIALS ARE AVAILABLE IN THE PA
    % INPUTS FOR ALL TARGET INVOCATIONS; THIS CAN ONLY HAPPEN NOW IF THE
    % FULL PA UNIT OF WORK IS RUN TWICE.
    
    % 5/4/2011
    % ALL CODE WITHIN THIS OAP ENABLED CLAUSE WILL HAVE TO BE REVISITED IF
    % OAP IS IMPLEMENTED IN PA. THE ANCILLARY CONFIGURATION AND DATA
    % STRUCTS HAVE CHANGED TO ACCOMODATE THE REACTION WHEEL CROSSING
    % DETECTOR.
    error('PA:photometricAnalysis:optionNotSupported', ...
        'OAP is not currently supported')
    
    if firstCall                                                                           %#ok<UNRCH>
        
        ancillaryEngineeringDataStruct = ...
            paDataObject.ancillaryEngineeringDataStruct;
        ancillaryPipelineDataStruct = ...
            paDataObject.ancillaryPipelineDataStruct;
        motionPolyStruct = ...
            paDataObject.motionPolyStruct;
        if isempty(ancillaryEngineeringDataStruct) && ...
                isempty(ancillaryPipelineDataStruct) && ...
                isempty(motionPolyStruct)
            error('PA:photometricAnalysis:missingAncillaryData', ...
                'OAP is enabled and ancillary data are not available')
        end
        
        tic
        display('photometric_analysis: conditioning ancillary data...');
        [conditionedAncillaryDataStruct, paResultsStruct.alerts] = ...
            synchronize_pa_ancillary_data(paDataObject, ...
            paResultsStruct.alerts);
        save(paStateFileName, 'conditionedAncillaryDataStruct', '-append');
        duration = toc;
        display(['Ancillary data conditioned: ' num2str(duration) ...
            ' seconds = '  num2str(duration/60) ' minutes']);

    else % not the first call
        
        if ~exist(paStateFileName, 'file')
            error('PA:photometricAnalysis:missingStateFile', ...
                'PA primary state file is missing')
        end
        load(paStateFileName, 'conditionedAncillaryDataStruct');
        
    end % if firstCall / else
    
end % if oapEnabled

% Treat long and short cadence data separately.
if processLongCadence 
                
    % Process background pixels if this is the first call. Process target
    % pixels otherwise.
    if firstCall
             
        % Process background pixels if this is the first call. Identify
        % and remove cosmic rays if CR enabled. Fit 2D background polynomial
        % to background pixels for each cadence. Save the background
        % coefficient structure to a matlab file for use in later
        % invocations.
        backgroundDataStruct = paDataObject.backgroundDataStruct;
        if isempty(backgroundDataStruct)
            error('PA:photometricAnalysis:missingBackgroundData', ...
                'Background data are not available')
        end

        display('photometric_analysis: processing background pixels...');
        [paDataObject, paResultsStruct] = ...
            process_background_pixels(paDataObject, paResultsStruct);
            
        
        if cosmicRayCleaningEnabled && ~simulatedTransitsEnabled
            
            % don't compute metrics for simulated transit runs
            tic
            display('photometric_analysis: computing (background) cosmic ray metrics...');
            [paResultsStruct] = ...
                compute_pa_cosmic_ray_metrics(paDataObject, paResultsStruct);
            
            cosmicRayEvents = [];                                                          %#ok<NASGU>
            nValidPixels = zeros([nCadences, 1]);                                          %#ok<NASGU>
            pixelCoordinates = [];                                                         %#ok<NASGU>
            pixelGaps = sparse(logical([]));                                                                %#ok<NASGU>
            save(paStateFileName, 'cosmicRayEvents', 'nValidPixels', ...
                'pixelCoordinates', 'pixelGaps', '-append');
            duration = toc;
            display(['Cosmic ray metrics computed: ' num2str(duration) ...
                ' seconds = '  num2str(duration/60) ' minutes']);

        else % cosmic ray cleaning is not enabled, must return gapped metrics struct
            
            [gappedCosmicRayMetrics] = ...
                initialize_cosmic_ray_metrics_structure(nCadences);
            paResultsStruct.backgroundCosmicRayMetrics = gappedCosmicRayMetrics;
            
        end % if cosmicRayCleaningEnabled / else
        
    else % not the first call
    
        % Process target pixels if this is not the first call. Identify and
        % remove cosmic rays if CR enabled. Subtract 2D background from
        % pixels for each cadence. Perform SAP, or OAP if enabled. Estimate
        % centroids for all targets at each cadence. Save centroids for
        % motion polynomial fitting.
        targetStarDataStruct = paDataObject.targetStarDataStruct;
        if isempty(targetStarDataStruct)
            error('PA:photometricAnalysis:missingTargetStarData', ...
                'Target star data are not available')
        end
        
        display('photometric_analysis: processing lc target pixels...');
        [paDataObject, paResultsStruct] = process_target_pixels(paDataObject, ...
            conditionedAncillaryDataStruct, paResultsStruct);
        
    end % if firstCall / else
    
elseif processShortCadence
    
    if strcmpi(processingState, 'TARGETS')
        % Short cadence processing involves target stars only. The
        % background polynomials are specified in the PA input structure on
        % the first call, and saved to a matlab file. They are then
        % reloaded from that file for all subsequent invocations. The
        % background polynomials are not defined at the short cadence rate
        % and hence must be temporally interpolated. The background is
        % subtracted as in the long cadence case. SAP or OAP is performed,
        % and centroids are estimated.
        display('photometric_analysis: processing sc target pixels...');
        targetStarDataStruct = paDataObject.targetStarDataStruct;
        if isempty(targetStarDataStruct)
            error('PA:photometricAnalysis:missingTargetStarData', ...
                'Target star data are not available')
        end

        [paDataObject, paResultsStruct] = process_target_pixels(paDataObject, ...
            conditionedAncillaryDataStruct, paResultsStruct);
    end
end % if processLongCadence /elseif processShortCadence

% Return.
return
