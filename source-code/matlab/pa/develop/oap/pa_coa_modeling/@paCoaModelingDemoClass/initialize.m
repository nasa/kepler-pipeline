function initialize(obj)
%************************************************************************** 
% initialize(obj)
%************************************************************************** 
% Set-up
%
% - Find PPA subdirectories.
% - Load the PA input struct, convert to 1-based, and prune targets.
% - Load the motion and background polynomials.
% - Gap Argabrightening cadences
% - Clean cosmic rays on all cadences.
% - Prune cadences from the PA input struct, motion struct, and
%   background struct. 
% - Group any overlapping target masks.
% - Remove background flux.
% - Construct PRF and motion model objects.  
%
% NOTES
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
    paTaskDir           = obj.params.paTaskDir;
    subtaskDir          = obj.params.subtaskDir;
    paInputFile         = obj.params.files.paInputFile;
    paMotionFile        = obj.params.files.paMotionFile;
    paBkgndFile         = obj.params.files.paBkgndFile;
    paStateFile         = obj.params.files.paStateFile;
    cleanCosmicRays     = obj.params.flags.cleanCosmicRays;
    gapArgaCadences     = obj.params.flags.gapArgaCadences;
    removeBackground    = obj.params.flags.removeBackground;
    targetIndex         = obj.params.targetIndex;
    cadences            = obj.params.cadences;
    raDecCadences       = obj.params.raDecCadences;
    amConfigStruct      = obj.params.apertureModelConfigurationStruct;
    
    if isfield(obj.params.flags, 'fittingEnabled')  
        fittingEnabled = obj.params.flags.fittingEnabled;
    else
        fittingEnabled = true;
    end
       
    %----------------------------------------------------------------------
    % Read PA input struct, prune all but the selected target, and convert
    % to 1-based. 
    %----------------------------------------------------------------------
    fprintf('Finding selected targets and creating a paInputStruct ...\n');
    s = load(fullfile(paTaskDir, subtaskDir, paInputFile));
    paInputStruct = update_pa_data_struct(s.inputsStruct);
    paInputStruct.targetStarDataStruct = ...
        paInputStruct.targetStarDataStruct(targetIndex);
    paInputStruct = convert_pa_inputs_to_1_base(paInputStruct);
    obj.targetKeplerId = ...
        paInputStruct.targetStarDataStruct.keplerId;
    
    %----------------------------------------------------------------------
    % Load motion and background polynomial structures. 
    %----------------------------------------------------------------------
    fprintf('Loading motion and background structs ...\n');
    s = load(fullfile(paTaskDir, paMotionFile));
    motionStruct = s.inputStruct;
    s = load(fullfile(paTaskDir, paBkgndFile));
    backgroundStruct = s.inputStruct;

    clear s
      
    %----------------------------------------------------------------------
    % Gap Argabrightening cadences.
    %----------------------------------------------------------------------
    if gapArgaCadences
        s = load(fullfile(paTaskDir, paStateFile), 'isArgaCadence');
        isArgaCadence = s.isArgaCadence;
        targetStarDataStruct = paInputStruct.targetStarDataStruct;
        for iTarget = 1 : length(targetStarDataStruct)
            for iPixel = 1 : length(targetStarDataStruct(iTarget).pixelDataStruct)
                targetStarDataStruct(iTarget).pixelDataStruct(iPixel).values(isArgaCadence) = 0;
                targetStarDataStruct(iTarget).pixelDataStruct(iPixel).uncertainties(isArgaCadence) = 0;
                targetStarDataStruct(iTarget).pixelDataStruct(iPixel).gapIndicators(isArgaCadence) = true;
            end % for iPixel
        end % for iTarget
        paInputStruct.targetStarDataStruct = targetStarDataStruct;
        clear targetStarDataStruct;
    end
    
    %----------------------------------------------------------------------
    % Do initial cosmic ray removal, if desired. We need to clean cosmic
    % rays BEFORE pruning cadences, since we relay on the time context to
    % recognize outliers.
    %----------------------------------------------------------------------
    if cleanCosmicRays
        fprintf('Cleaning cosmic rays ...\n');
        cosmicRayCleanerObject = paCosmicRayCleanerClass( paInputStruct, motionStruct);
        cosmicRayCleanerObject.clean;
        
        cosmicRayTargetStructFieldnames = ...
            fieldnames(cosmicRayCleanerObject.targetArray);
        targetStarDataStructFieldnames = ...
            fieldnames(paInputStruct.targetStarDataStruct);
        fieldsToRemove = setdiff( cosmicRayTargetStructFieldnames, ...
                                  targetStarDataStructFieldnames );
      
        for iTarget = 1:numel(cosmicRayCleanerObject.targetArray)
            paInputStruct.targetStarDataStruct(iTarget) = ...
                rmfield(paInputStruct.targetStarDataStruct(iTarget), fieldsToRemove);
        end
    end
    
    
    %----------------------------------------------------------------------
    % Remove background flux.
    %----------------------------------------------------------------------    
    if removeBackground
        fprintf('Removing background flux ...\n');
        paInputStruct.targetStarDataStruct = ...
            paCoaModelingDemoClass.remove_background( ...
                paInputStruct.targetStarDataStruct, backgroundStruct);
    end
    
    %----------------------------------------------------------------------
    % Load catalog.
    %----------------------------------------------------------------------    
    kicFile = obj.params.files.kicFile;
    if exist(kicFile,'file')
        fprintf('\tLoading the KIC ...\n');
        
        s = load(kicFile); % Load the KIC.
        fn = fieldnames(s);
        if numel(fn) > 1 || ~isstruct(s.(fn{1}))
            error('A catalog file may only contain a single struct array.')
        end
        catalog = s.(fn{1});
        clear s
    else
        fprintf('\tKIC file does not exist. Proceeding without it ...\n');
        catalog = struct([]);
    end

    catalog = paCoaModelingDemoClass.convert_catalog_to_pa_format(catalog);
    
    %----------------------------------------------------------------------
    % Call pa_coa_fit_aperture_model()
    %----------------------------------------------------------------------
    fprintf('Modeling the target aperture ...\n');
    
    nCadences = length(paInputStruct.cadenceTimes.midTimestamps);
    cadenceIndicators = false(nCadences, 1);
    cadenceIndicators(cadences) = true;
    
    paInputStruct.motionPolyStruct = motionStruct;
    if ~isempty(amConfigStruct)
        paInputStruct.apertureModelConfigurationStruct = amConfigStruct;
    end
    
    tic;
    [obj.aperturePixelArray, obj.contributingStarStruct, ...
     obj.apertureModelObject] = ...
        pa_coa_fit_aperture_model(paInputStruct, 1, cadenceIndicators, ...
            raDecCadences, fittingEnabled, catalog);
    toc
end

function paDataStruct = update_pa_data_struct(paDataStruct)
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

%********************************** EOF ***********************************

