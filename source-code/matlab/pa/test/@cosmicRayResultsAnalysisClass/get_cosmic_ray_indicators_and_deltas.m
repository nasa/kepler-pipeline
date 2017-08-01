function [eventIndicatorArray, deltaArray, crcObj] = ...
    get_cosmic_ray_indicators_and_deltas(keplerId, module, output, rootPath)
%************************************************************************** 
% [eventIndicatorArray, deltaArray, crcObj] = ...
%    get_cosmic_ray_indicators_and_deltas(keplerId, module, output, rootPath)
%************************************************************************** 
% Return event indicators and additive corrections for the entire
% photometric aperture of the specified target.  
%
% INPUTS
%     keplerId    : A valid kepler ID.
%     module      : A module number in the range [2,24].
%     output      : An output number in the range [1,4].
%     rootPath    : The full path to the directory containing task 
%                   directories for the pipeline instance (i.e., the
%                   directory that contains the uow/ directory). If
%                   unspecified, the current working directory is used.
%
% OUTPUTS
%     eventIndicatorArray : An nCadences-by-1 logical array, the ith element
%                           of which indicates whether a cosmic ray event
%                           was detected on any pixel in the photometric
%                           aperture on the ith cadence. 
%     deltaArray          : An nCadences-by-1 double array, the ith element
%                           of which represents the total amplitude (summed
%                           over all pixels) of cosmic ray events detected
%                           on the ith cadence. 
%
%                           correctedFlux = uncorrectedFlux - deltaArray
%
%     crcObj              : The reconstructed paCosmicRayCleanerClass
%                           object.
%
% USAGE EXAMPLE
%     >> [eventIndicatorArray, deltaArray, crcObj] = ...
%         cosmicRayResultsAnalysisClass.get_cosmic_ray_indicators_and_deltas( ...
%         201843477, 24, 4, ...
%        '/path/to/ksop-2128-release-9.3-VnV-K2-pacoa-run2');
%
%     To visually inspect the cleaning results:
%     >> crraObj = cosmicRayResultsAnalysisClass(crcObj)
%     >> cosmicRayResultsAnalysisClass.compare_target_flux_results(crraObj, crraObj)
%
% NOTES
%     As of SOC 9.3 all targets (PPA and non-PPA) are processed in the
%     TARGETS processing state. We therefore search only the TARGETS
%     subtask directories.
%
%     Cosmic ray events in the PA state file are stored in 1-based pixel
%     coordinates. Zero-based results can be found in the output file of
%     the final subtask, but the array in the state file is simpler and
%     faster to access. We must therefore convert to zero-based
%     coordinates.
%
%     As described on KSOC-4549, the reference rows and columns for optimal
%     apertures were output in 1-based coordinates during PA 9.3 V&V. Once
%     this issue has been resolved, the constant
%     CONVERT_APERTURES_TO_ZERO_BASED should be set to 'false'.
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
    PA_STATE_FILE_NAME  = 'pa_state.mat';
    PA_INPUT_FILE_NAME  = 'pa-inputs-0.mat';
    PA_OUTPUT_FILE_NAME = 'pa-outputs-0.mat';
    
    % Cosmic ray events in the PA state file are stored in 1-based pixel
    % coordinates. Zero-based results can be found in the output file of
    % the final subtask, but the array in the state file is simpler and
    % faster to access. We must therefore convert to zero-based
    % coordinates.
    CONVERT_CR_EVENTS_TO_ZERO_BASED = true;
    
    % This is currently set to 'true' because of the bug described on
    % KSOC-4549.
    CONVERT_APERTURES_TO_ZERO_BASED = false;

    % Set defaults.
    if ~exist('rootPath','var') || ~isdir(rootPath)
        rootPath = pwd;
    end

    subtaskDir = '';
    
    %----------------------------------------------------------------------
    % Determine the associated task file directory and search TARGET
    % subtask directories for the target. 
    %----------------------------------------------------------------------
    groupDir = cell2mat(get_group_dir( 'PA', [module, output], ...
        'rootPath', rootPath ));
    if isempty(groupDir)   
        error('Could not find PA group directory for mod.out %d.%d\n', ...
            module, output);
    end
    
    targetsSubtaskDirs = ...
        find_subtask_dirs_by_processing_state( groupDir, 'TARGETS' );
    
    for iDir=1:numel(targetsSubtaskDirs)
        fprintf('Searching subtask directory %s ...\n',targetsSubtaskDirs{iDir});
        load(fullfile(groupDir, targetsSubtaskDirs{iDir}, PA_INPUT_FILE_NAME));
        if( ~isempty(inputsStruct.targetStarDataStruct) )
            if ismember(keplerId, [inputsStruct.targetStarDataStruct.keplerId])
                subtaskDir = fullfile(groupDir, targetsSubtaskDirs{iDir});  
                break;
            end
        end
    end

    if isempty(subtaskDir)
        error(['Could not find kepler ID %d in PA input', ...
            'files in directory %s\n'], keplerId, groupDir);
    end    
      
    %----------------------------------------------------------------------
    % Discard all but the target of interest and prune pixels outside the
    % optimal aperture.
    %----------------------------------------------------------------------
    inputsStruct.targetStarDataStruct = ...
        inputsStruct.targetStarDataStruct( ...
        [inputsStruct.targetStarDataStruct.keplerId] == keplerId);
    pds = inputsStruct.targetStarDataStruct.pixelDataStruct;
    
    % Get the photometric aperture (either TAD-COA or PA-COA).
    load(fullfile(groupDir, targetsSubtaskDirs{iDir}, PA_OUTPUT_FILE_NAME));
    targOptApp = outputsStruct.targetStarResultsStruct( ...
        [outputsStruct.targetStarResultsStruct.keplerId] == keplerId).optimalAperture;
    
    if CONVERT_APERTURES_TO_ZERO_BASED
        targOptApp.referenceRow    = targOptApp.referenceRow;
        targOptApp.referenceColumn = targOptApp.referenceColumn;
    end
    oaZeroBasedCcdCoords = ...
        [ colvec([targOptApp.offsets.row]    + targOptApp.referenceRow), ...
          colvec([targOptApp.offsets.column] + targOptApp.referenceColumn) ];
    
    maskZeroBasedCcdCoords = [colvec([pds.ccdRow]), colvec([pds.ccdColumn])];  
    inOptimalAperture = ismember(maskZeroBasedCcdCoords, oaZeroBasedCcdCoords, 'rows');
    pds = pds([inOptimalAperture]);
    inputsStruct.targetStarDataStruct.pixelDataStruct = pds;
    
    %----------------------------------------------------------------------
    % Reconstruct paCosmicRayCleanerClass object.
    %----------------------------------------------------------------------
    load( fullfile(subtaskDir, PA_STATE_FILE_NAME), 'cosmicRayEvents');
    crcObj = paCosmicRayCleanerClass(inputsStruct, '');
    crcObj.reconstruct_result_from_event_array(cosmicRayEvents, ...
            inputsStruct.cadenceTimes.midTimestamps, ...
            CONVERT_CR_EVENTS_TO_ZERO_BASED);
        
    %----------------------------------------------------------------------
    % Generate output arrays.
    %----------------------------------------------------------------------
    [correctedFluxMat, eventIndicatorMat] ...
            = crcObj.get_corrected_flux_and_event_indicator_matrices();
    eventIndicatorArray = any(eventIndicatorMat, 2);
    uncorrectedFluxMat = [crcObj.inputArray.pixelDataStruct.values];    
    deltaArray = sum(uncorrectedFluxMat - correctedFluxMat, 2);
end
    