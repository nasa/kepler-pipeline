function paResultsStruct = finalize( paDataObject)
%**************************************************************************
% function paResultsStruct = finalize( paDataObject)
%**************************************************************************
% 1. Initialize and populate output structure. 
% 2. Compute brightness, encircled energy, and cosmic ray metrics.
% 3. If motion polynomial generation failed, then fit motion polynomials
%    using flux-weighted centroids from all targets. 
%**************************************************************************
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

    % Get file names
    paFileStruct                    = paDataObject.paFileStruct;
    paStateFileName                 = paFileStruct.paStateFileName;
    paMotionFileName                = paFileStruct.paMotionFileName;
    paOutputUncertaintiesFileName   = paFileStruct.paOutputUncertaintiesFileName;                %#ok<NASGU>

    % Get fields from input structure
    cadenceTimes = paDataObject.cadenceTimes;
    nCadences    = length(cadenceTimes.midTimestamps);

    paConfigurationStruct       = paDataObject.paConfigurationStruct;
    cosmicRayCleaningEnabled    = paConfigurationStruct.cosmicRayCleaningEnabled;
    simulatedTransitsEnabled    = paConfigurationStruct.simulatedTransitsEnabled;

    pouConfigurationStruct  = paDataObject.pouConfigurationStruct;
    pouEnabled              = pouConfigurationStruct.pouEnabled;
    compressionEnabled      = pouConfigurationStruct.compressionEnabled;

    mitigationEnabled = ...
        paDataObject.argabrighteningConfigurationStruct.mitigationEnabled;
    
    % Set long and short cadence flags
    cadenceType = paDataObject.cadenceType;
    if strcmpi(cadenceType, 'long')
        processLongCadence = true;
        processShortCadence = false;
    elseif strcmpi(cadenceType, 'short')
        processLongCadence = false;
        processShortCadence = true;
    end

    % Initialize the PA output structure.
    [paResultsStruct] = initialize_pa_output_structure(paDataObject);

    % Polulate results struct with state file contents.
    s = load(paStateFileName);
    paResultsStruct.targetStarCosmicRayEvents = s.cosmicRayEvents;
    paResultsStruct.reactionWheelZeroCrossingIndices = find(s.reactionWheelZeroCrossingIndicators);
    if mitigationEnabled && isfield(s, 'isArgaCadence')
        paResultsStruct.argabrighteningIndices = find(s.isArgaCadence);
    end
   
    if processLongCadence 
        % Fit motion polynomials (if necessary) and compute metrics if this
        % is the last call.
        motionPolyStruct = paDataObject.motionPolyStruct;
        if isempty(motionPolyStruct)
            tic
            display([mfilename ': fitting motion polynomials to all target centroids...']);
            [paResultsStruct, motionPolyStruct] = ...
                fit_motion_polynomials(paDataObject, paResultsStruct);
            paDataObject.motionPolyStruct = motionPolyStruct;
            save(paStateFileName, 'motionPolyStruct', '-append');
            struct_to_blob(motionPolyStruct, paMotionFileName);
            duration = toc;
            [paResultsStruct.alerts] = ...
                add_alert(paResultsStruct.alerts, 'warning', ...
                'motion polynomials have been fit to centroids of all targets, not only PPA_STELLAR targets');
            disp(paResultsStruct.alerts(end).message);
            display(['Motion polynomials computed for all targets: ' num2str(duration) ...
                ' seconds = '  num2str(duration/60) ' minutes']);
        end
        paResultsStruct.motionBlobFileName = paMotionFileName;  


        if ~simulatedTransitsEnabled

            % metrics for non-simulated transit runs only
            tic
            display([mfilename ': computing encircled energy metrics...']);
            [paResultsStruct] = ...
                compute_pa_encircled_energy_metrics(paDataObject, paResultsStruct);
            duration = toc;
            display(['Encircled energy metrics computed: ' num2str(duration) ...
                ' seconds = '  num2str(duration/60) ' minutes']);

            tic
            display([mfilename ': computing brightness metrics...']);
            [paResultsStruct] = ...
                compute_pa_brightness_metrics(paDataObject, paResultsStruct);
            duration = toc;
            display(['Brightness metrics computed: ' num2str(duration) ...
                ' seconds = '  num2str(duration/60) ' minutes']);

        else
            % no motion blob output for simulated transit runs
            paResultsStruct.motionBlobFileName = [];
        end


        if cosmicRayCleaningEnabled

            tic
            display([mfilename ': computing (target) cosmic ray metrics...']);
            [paResultsStruct] = ...
                compute_pa_cosmic_ray_metrics(paDataObject,paResultsStruct);
            duration = toc;
            display(['Cosmic ray metrics computed: ' num2str(duration) ...
                ' seconds = '  num2str(duration/60) ' minutes']);

        else % must return gapped metrics struct

            [gappedCosmicRayMetrics] = ...
                initialize_cosmic_ray_metrics_structure(nCadences);
            paResultsStruct.targetStarCosmicRayMetrics = gappedCosmicRayMetrics;

        end % if cosmicRayCleaningEnabled / else

    elseif processShortCadence
    
        % Compute cosmic ray metrics if cleaning enabled.
        if cosmicRayCleaningEnabled

            tic
            display([mfilename ': computing (target) cosmic ray metrics...']);
            [paResultsStruct] = ...
                compute_pa_cosmic_ray_metrics(paDataObject, paResultsStruct);
            duration = toc;
            display(['Cosmic ray metrics computed: ' num2str(duration) ...
                ' seconds = '  num2str(duration/60) ' minutes']);

        else % must return gapped metrics struct

            [gappedCosmicRayMetrics] = ...
                initialize_cosmic_ray_metrics_structure(nCadences);
            paResultsStruct.targetStarCosmicRayMetrics = gappedCosmicRayMetrics;

        end % if cosmicRayCleaningEnabled / else

    end % if processLongCadence /elseif processShortCadence
    
    

    % Generate final PA output uncertainty structure. Compress it if POU
    % compression is enabled.     
    if pouEnabled
        % FINALIZE PA POU OUTPUT STRUCTURE HERE.
        if compressionEnabled
            % COMPRESS PA POU OUTPUT STRUCTURE HERE.
        end % if compressionEnabled
        
        % SAVE OUTPUT UNCERTAINTIES STRUCTURE AS BLOB HERE.
        
        % Copy output uncertainties file name to PA results structure.
        % ONLY IF THERE IS ACTUALLY AN OUTPUT UNCERTAINTIES FILE.
        % paResultsStruct.paOutputUncertaintiesFileName = ...
        %     paOutputUncertaintiesFileName;
    end % if pouEnabled

end

