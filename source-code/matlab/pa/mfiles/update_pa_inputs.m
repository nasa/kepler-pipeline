function [paDataStruct, stateFileNames] = ...
update_pa_inputs(paDataStruct)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [paDataStruct, stateFileNames] = ...
% update_pa_inputs(paDataStruct)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Add debug level == 0 to paConfigurationStruct if field is not already
% present. Add structure with PA matlab file names to input data struct.
% Convert input blobs to structs if this is the first call, otherwise load
% the structs from matlab files. Attach these structures (except for CAL
% uncertainties) to input data struct. Initialize the PA state file if this
% is the first call. Remove blobs from input data struct.
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

% Set debug level to zero if it was not specified.
if ~isfield(paDataStruct.paConfigurationStruct, 'debugLevel')
    paDataStruct.paConfigurationStruct.debugLevel = 0;
end

% Get fields from input structure.
processingState = paDataStruct.processingState;
cadenceType     = paDataStruct.cadenceType;
firstCall       = paDataStruct.firstCall;
simulatedTransitsEnabled = paDataStruct.paConfigurationStruct.simulatedTransitsEnabled;

% Set PA file names and attach to input struct.
paRootTaskDir                       = char(get_cwd_parent);
paStateFileName                     = 'pa_state.mat';
paBackgroundFileName                = '../pa_background.mat';
paInputUncertaintiesFileName        = '../pa_input_uncertainties.mat';
paOutputUncertaintiesFileName       = '../pa_output_uncertainties.mat';
paMotionFileName                    = '../pa_motion.mat';
paSimulatedTransitsFileName         = 'pa_simulated_transits.mat';
paSimulatedTransitsBlob             = 'simulatedTransitsBlob.mat';
calPouFileRoot                      = ['..',filesep,'decimatedCalPou'];
transitInjectionParametersFilename  = ['../',paDataStruct.transitInjectionParametersFileName];


stateFileNames = {paStateFileName, paBackgroundFileName, ...
    paInputUncertaintiesFileName, paMotionFileName,...
    paSimulatedTransitsFileName};

paFileStruct.paRootTaskDir                      = paRootTaskDir;
paFileStruct.paBackgroundFileName               = paBackgroundFileName;
paFileStruct.paInputUncertaintiesFileName       = paInputUncertaintiesFileName;
paFileStruct.paOutputUncertaintiesFileName      = paOutputUncertaintiesFileName;
paFileStruct.paMotionFileName                   = paMotionFileName;
paFileStruct.paStateFileName                    = paStateFileName;
paFileStruct.paSimulatedTransitsFileName        = paSimulatedTransitsFileName;
paFileStruct.paSimulatedTransitsBlob            = paSimulatedTransitsBlob;
paFileStruct.calPouFileRoot                     = calPouFileRoot;
paFileStruct.transitInjectionParametersFilename = transitInjectionParametersFilename;

paDataStruct.paFileStruct = paFileStruct;

% UPDATE OLD PA INPUT STRUCTURES. 
% This call only occurs if this is not a release branch.
import gov.nasa.kepler.common.KeplerSocBranch;
if(~KeplerSocBranch.isRelease())
    [paDataStruct] = pa_convert_62_data_to_70(paDataStruct);
    [paDataStruct] = pa_convert_70_data_to_80(paDataStruct);
    [paDataStruct] = pa_convert_80_data_to_81(paDataStruct);
    [paDataStruct] = pa_convert_81_data_to_82(paDataStruct);
    [paDataStruct] = pa_convert_82_data_to_83(paDataStruct);
    [paDataStruct] = pa_convert_83_data_to_90(paDataStruct);
    [paDataStruct] = pa_convert_90_data_to_91(paDataStruct);
    [paDataStruct] = pa_convert_91_data_to_92(paDataStruct);
    [paDataStruct] = pa_convert_92_data_to_93(paDataStruct);
end

% PA-COA needs the number of exposures per cadence. In stead of computing this once per target just do it once here and store the value.
cmObject = configMapClass( orderfields(paDataStruct.spacecraftConfigMap));
if( strcmpi(cadenceType, 'LONG' ) )
    paDataStruct.spacecraftConfigurationStruct.numExposuresPerCadence = get_number_of_exposures_per_long_cadence_period(cmObject(1));
elseif( strcmpi(cadenceType, 'SHORT' ) )
    paDataStruct.spacecraftConfigurationStruct.numExposuresPerCadence = get_number_of_exposures_per_short_cadence_period(cmObject(1));
end




% Create processing state marker file and save the state string to it.
processingStateFileName = ['processingState_', processingState];
save(processingStateFileName, 'processingState');

% K2: Gap non-fine-point and pre-tweak cadences in K2 data.
processingK2Data = paDataStruct.cadenceTimes.startTimestamps(1) > ...
    paDataStruct.fcConstants.KEPLER_END_OF_MISSION_MJD;
if processingK2Data
    
    
    if paDataStruct.paConfigurationStruct.k2GapIfNotFinePntData
        isFinePnt = paDataStruct.cadenceTimes.isFinePnt;
        paDataStruct = modify_gap_indicators(paDataStruct, ~isFinePnt, 'or');
    end
    
    % The following is a temporary fix that should be removed once the
    % proper mechanism is in place to handle pre-tweak data.
    if paDataStruct.paConfigurationStruct.k2GapPreTweakData
        attitudeTweakIndicators = ...
            paDataStruct.cadenceTimes.dataAnomalyFlags.attitudeTweakIndicators;
        if any(attitudeTweakIndicators)
            isPostTweak = false(size(attitudeTweakIndicators));
            finalTweakCadence = find(attitudeTweakIndicators, 1, 'last');
            if finalTweakCadence < length(attitudeTweakIndicators)
                isPostTweak(finalTweakCadence + 1 : end) = true;
            end
            paDataStruct = modify_gap_indicators(paDataStruct, ~isPostTweak, 'or');
        end
    end
    
end % processingK2Data


% If this is the first call, convert input blobs to structs. Save the
% structures to local PA matlab files. If this is not the first call, load
% the structures from the local PA matlab files.
%
%   backgroundBlobs      -> backgroundPolyStruct()
%   motionBlobs          -> motionPolyStruct()
%   calUncertaintyBlobs  -> calUncertaintiesStruct(), compressedData
%
%   Also move the TIP blob to the parent directory if this is the first call, simulatedTransits is enabled and the file is found in the
%   sub-task directory (current run directory)
%
if firstCall
    
    % Clean working directory; remove existing state files.
    for iFile = 1 : length(stateFileNames)
        fileName = stateFileNames{iFile};
        if exist(fileName, 'file') == 2
            delete(fileName);
            display(['update_pa_inputs: stale state file ', fileName, ' removed.']);
        end
    end % for iFile
    
    % Convert the background blob series if one exists.
    backgroundBlobs = paDataStruct.backgroundBlobs;
    backgroundPolyStruct = poly_blob_series_to_struct(backgroundBlobs);
    
    % Convert the motion blob series if one exists. If there are not a
    % sufficient number of valid polynomials then set the struct to empty
    % (in this case the centroids will not be seeded). Otherwise write the
    % output motion blob file and interpolate across gapped cadences.
    motionBlobs = paDataStruct.motionBlobs;
    motionPolyStruct = poly_blob_series_to_struct(motionBlobs);
    motionPolyStruct = ...
        get_interp_motion_polys_and_write_uninterp_motion_blob( ...
            motionPolyStruct, paMotionFileName, paDataStruct.cadenceTimes, ...
            cadenceType);
    
    % Convert the CAL blob if it exists.
    calUncertaintyBlobs = paDataStruct.calUncertaintyBlobs;
    
    if ~isempty(calUncertaintyBlobs.blobIndices)
        
        calUncertaintyObject = blobSeriesClass(calUncertaintyBlobs);
        calUncertaintyGapIndicators = get_gap_indicators(calUncertaintyObject);
        if all(calUncertaintyGapIndicators)
            error('PA:updatePaInputs:invalidCalUncertaintyBlob', ...
                'Uncertainty blob contains gaps only');
        end
        
        % find unique blob indices out of the ungapped cadences
        calUncertaintyIndices = get_blob_indices(calUncertaintyObject);
        [uniqueBlobIndices, uniqueIndex] = unique(calUncertaintyIndices(~calUncertaintyGapIndicators),'first');
        
        % retrieve array of all structs in calBlobSeries
        relativeCadences = find(~calUncertaintyGapIndicators);
        calStruct = get_struct_for_cadence(calUncertaintyObject, relativeCadences(uniqueIndex));
        
        % parse out needed arrays of structures
        calUncertaintiesStruct = [calStruct.struct];                                            
        
    else % CAL blob is empty
        
        calUncertaintiesStruct = [];
        calUncertaintyIndices = [];                                                             %#ok<NASGU>
        calUncertaintyGapIndicators = [];                                                       %#ok<NASGU>
        uniqueBlobIndices = [];
        
    end % if / else
    
    % Initialize state files. Use separate file for CAL uncertainties.
    create_new_state_file(paDataStruct, paStateFileName);
    save(paStateFileName, 'backgroundPolyStruct', 'motionPolyStruct', '-append');
        
    % save the cal POU blob indices and indicators
    intelligent_save(paInputUncertaintiesFileName, 'calUncertaintiesStruct',...
        'calUncertaintyIndices', 'calUncertaintyGapIndicators', 'uniqueBlobIndices');
        
    if paDataStruct.pouConfigurationStruct.pouEnabled
        
        tic
        display('update_pa_inputs: decimating CAL POU blobs...');
        
       % save the decimated CAL POU blobs as separate variables
        for iBlob = uniqueBlobIndices(:)'
            
            disp(['Doing blob ',num2str(iBlob),' ...']);

            decimatedCalPou = calUncertaintiesStruct(iBlob);
            varFileName = [calPouFileRoot,num2str(iBlob),'.mat'];

            % decimated cadence list starts from PA unit of work first cadence
            currentCalBlobCadences = (decimatedCalPou.absoluteFirstCadence:decimatedCalPou.absoluteLastCadence)';
            decimatedRelativeIndices = ...
                currentCalBlobCadences(mod(currentCalBlobCadences - paDataStruct.cadenceTimes.cadenceNumbers(1),...
                                           paDataStruct.pouConfigurationStruct.interpDecimation) == 0) -...
                                           decimatedCalPou.absoluteFirstCadence + 1;

            decimatedCalPou.calTransformStruct = put_collateral_covariance(decimatedCalPou.calTransformStruct,...
                                                                decimatedCalPou.compressedData,...
                                                                decimatedRelativeIndices);

            decimatedCalPou.compressedData = [];
            decimatedCalPou.decimatedRelativeIndices = decimatedRelativeIndices;

            % append the decimated struct to the local paInputUncertainties file
            intelligent_save(varFileName, 'decimatedCalPou');
            clear decimatedCalPou;
            
        end
        
        duration = toc;
        display(['POU blobs decimated: ' num2str(duration) ' seconds = '  num2str(duration/60) ' minutes']);

    end

    % clean up POU
    clear calUncertaintiesStruct calUncertaintyIndices calUncertaintyGapIndicators uniqueBlobIndices;
    
    % move the simulated transits text file blob to the parent task file directory on first call
    if simulatedTransitsEnabled && firstCall
        if exist(paDataStruct.transitInjectionParametersFileName, 'file') == 2
            movefile(paDataStruct.transitInjectionParametersFileName, transitInjectionParametersFilename);
        else
            warning('PA:updatePaInputs:transitInjectionBlobMissingInSubtask',...
                'Transit injection text file not present in st-0.');
        end        
    end
    
else % not the first call
    
    % Check for existence of state and uncertainties files in parent
    % directory and load background and transform structures. 
    if ~exist(fullfile(paRootTaskDir, paStateFileName), 'file')
        error('PA:updatePaInputs:missingStateFile', ...
            'PA state file is missing');
    end
    load(fullfile(paRootTaskDir, paStateFileName), 'backgroundPolyStruct', 'motionPolyStruct');
    
    if ~exist(paInputUncertaintiesFileName, 'file')
        error('PA:updatePaInputs:missingStateFile', ...
            'PA input uncertainty structures file is missing');
    end
    
    % If aggregating results, copy the state file from the root task
    % directory. Otherwise create a new state file for this subtask in the
    % current working directory.  
    switch processingState
        case {'GENERATE_MOTION_POLYNOMIALS', 'AGGREGATE_RESULTS'}
            copy_files_from_root_task_dir({paStateFileName});
        otherwise
            create_new_state_file(paDataStruct, paStateFileName);
    end
    
end % if firstCall / else

% check simulated transits parameters file
if simulatedTransitsEnabled && ( (strcmpi(cadenceType,'long') && ~firstCall) || strcmpi(cadenceType,'short') )
    if ~isvalid_transit_injection_parameters_file( paDataStruct.paFileStruct.transitInjectionParametersFilename );
        error('Transit injection parameters file invalid.');
    end
end

% Add the background, motion and transform structures to the PA data
% structure, and remove the blob fields from the data structure.
paDataStruct.backgroundPolyStruct = backgroundPolyStruct;
paDataStruct.motionPolyStruct     = motionPolyStruct;

% Remove the blob fields from the PA input structure.
paDataStruct = rmfield( paDataStruct, {'backgroundBlobs', 'motionBlobs', 'calUncertaintyBlobs'} );

% Disable PA-COA if motion polynomials (MPs) are unavailable. This should
% only affect processing in the rare case when we're in the TARGETS
% processing state and MPs are unavailable. Still, since PA-COA relies on
% MPs, it does no harm to disable it whenever they're unavailable.
if isempty(paDataStruct.motionPolyStruct)
    paDataStruct.paConfigurationStruct.paCoaEnabled = false;
end

% Disable PA-COA when in the PPA_TARGETS processing state since photometry
% for PPA targets is now generated in the TARGETS processing state along
% with all other targets.
if strcmpi(paDataStruct.processingState, 'PPA_TARGETS')
    paDataStruct.paConfigurationStruct.paCoaEnabled = false;
end

% Disable PA-COA for Short Cadence runs. The pipeline cannot handle 
% different apertures for LC and SC so as is there is little point running
% PA-COA for SC. We can revisit this in the future if it is so desired.
if (strcmp(paDataStruct.cadenceType, 'SHORT'))
    paDataStruct.paConfigurationStruct.paCoaEnabled = false;
end


% Return
end

