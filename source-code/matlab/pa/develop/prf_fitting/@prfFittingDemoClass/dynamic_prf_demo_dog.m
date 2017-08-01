function outputStruct = dynamic_prf_demo(kicFile)
%**************************************************************************
% function dynamic_prf_demo(paTaskDir, kicFile)
%**************************************************************************
% Demonstrate dynamic PRF fitting.
%
% Process a limited number of PPA targets from a single PA input struct.
%
% This prototype does not recompute motion polynomials, which would allow
% for limited positional adjustments in the full implementation. The idea
% would be to use the dynamic PRF in the centroid fitting.
%
%
% Set-up
%     1. Find PPA subdirectories.
%     2. Load the PA input struct, convert to 1-based, and prune cadences.
%     3. Load motion and background polys and prune cadences.
% Determine overlap between target masks and group them accordingly.
% Condition the flux time series by 
%     1. Gapping Argabrightening cadences.
%     2. Removing cosmic rays.
%     3. Subtracting background.
% Construct PRF and motion model objects.
% Construct aperture model objects and fit the static PRF models to the
% observations.
%
%
% NOTES
%     To visualize the recovered kernel:
%
%         show_filter({outputStruct.appliedKernel, ...
%                      outputStruct.recoveredKernel}, ...
%                     {'applied', 'recovered'});
%
%     To visualize the fit of the model to the ith aperture group:
%
%         i = 1;
%         groupArray = outputStruct.targetArray( ...
%             ismember([outputStruct.targetArray.keplerId]', ...
%             outputStruct.groups{i}));
%         plot_two_aperture_models(...
%             outputStruct.staticPrfApertureModel(i), ...
%             outputStruct.dynamicPrfApertureModel(i), ...
%             groupArray, {'static model', 'dynamic model'}); 
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

    %----------------------------------------------------------------------
    % Define constants and set default parameters, if necessary.
    %----------------------------------------------------------------------    
    PA_INPUT_FILE_NAME  = 'pa-inputs-0.mat';
    PA_MOTION_FILE_NAME = 'pa_motion.mat';
    PA_BKGND_FILE_NAME  = 'pa_background.mat';
    PA_STATE_FILE_NAME  = 'pa_state.mat';
    CLEAN_COSMIC_RAYS   = true;
    MAX_ITERATIONS      = 500; 
    MAX_N_MASKS         = 20; % Maximum number of masks to include in the demonstration.
    USE_SIMULATED_DATA  = false;
    OLD_STYLE_TASK_DIR  = true;
    FIT_ALL_STARS       = false; % If true, use all KIC (and possibly UKIRT) 
                                % stars. If false, use only the target
                                % stars in the PA input struct.
    MODEL_TYPE          = 'INVARIANT_DOG';
    KERNEL_WIDTH        = 21;
    SAMPLES_PER_PIXEL   = 4;
    
          
    % Select a group of tightly clustered stars on a defocused channel.
    paTaskDir = '/path/to/pa/defocused_quarter/pa-matlab-7268-439288';
    selectedKids = [ ...
        7009268, ...
        7009474, ...
        7009632, ...
        7009548, ...
        7009684, ...
        7009654, ...
        7009852, ...
        7009817 ...
    ];
%    cadences = [1; 500; 1100; 1500; 2000; 2500; 3000; 3500; 4000];
    cadences = 1;
    
    
    if ~exist('kicFile', 'var')
        kicFile = '/path/to/PRF/PRF_photometry/joint_fit_prototype/kic11913013_kicOnly_allStars_back.mat';
    end
    
    
    %----------------------------------------------------------------------
    % Set-up
    %
    % - Find PPA subdirectories.
    % - Load the PA input struct, convert to 1-based, and prune targets.
    % - Load the motion and background polynomials.
    % - Gap Argabrightening cadences
    % - Clean cosmic rays on all cadences.
    % - Prune cadences from the PA input struct, motion struct, and
    %   background struct. 
    %---------------------------------------------------------------------- 
    if ~OLD_STYLE_TASK_DIR
        % Find PPA subdirectories.
        originalDir = pwd;
        cd(paTaskDir);
        ppaSubDirs = ...
            find_subtask_dirs_by_processing_state( paTaskDir, 'PPA_TARGETS' );
        cd(originalDir);
        
        % Load PA input struct from the first PPA subtaska and convert to
        % 1-based.
        s = load(fullfile(paTaskDir, ppaSubDirs{1}, PA_INPUT_FILE_NAME));
    else
        s = load(fullfile(paTaskDir, 'pa-inputs-1.mat'));
    end
    
    paInputStruct = convert_pa_inputs_to_1_base(s.inputsStruct);
    
    % prune all but the specified targets.
    fprintf('Pruning targets from paInputStruct ...\n');
    targetIndices = find(ismember([paInputStruct.targetStarDataStruct.keplerId], selectedKids));
    paInputStruct = prune_pa_targets_and_cadences(paInputStruct, targetIndices);
    
    % Load motion and background polynomial structures.
    fprintf('Loading motion and background structs ...\n');
    s = load(fullfile(paTaskDir, PA_MOTION_FILE_NAME));
    motionStruct = s.inputStruct;
    s = load(fullfile(paTaskDir, PA_BKGND_FILE_NAME));
    backgroundStruct = s.inputStruct;

    clear s
    
    
    % Gap Argabrightening cadences.
    s = load(fullfile(paTaskDir, PA_STATE_FILE_NAME), 'isArgaCadence');
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
    
    % Do initial cosmic ray removal, if desired. We need to clean cosmic
    % rays BEFORE pruning cadences, since we relay on the time context to
    % recognize outliers.
    if CLEAN_COSMIC_RAYS
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

    % Prune all but the specified cadences from the remaining targets, the
    % motion polynomial struct, and the background struct. 
    fprintf('Pruning cadences from paInputStruct, motionStruct, and backgroundStruct ...\n');
    targetIndices = 1:numel(paInputStruct.targetStarDataStruct);
    paInputStruct    = prune_pa_targets_and_cadences(paInputStruct, targetIndices, cadences);
    targetArray      = paInputStruct.targetStarDataStruct;
    motionStruct     = motionStruct(cadences);
    backgroundStruct = backgroundStruct(cadences);

       
            
    %----------------------------------------------------------------------
    % Group the target masks.
    %----------------------------------------------------------------------
    fprintf('Grouping target masks ...\n');
    [groups, groupsByIndex] = apertureModelClass.group_apertures_by_overlap(targetArray);
    
    
    % Prune the set of mask groups to the desired size, preferring larger
    % groups for demonstration purposes. 
    groupSizes = cellfun(@numel, groups, 'UniformOutput', true);
    groupIndicesAndSizes = [ [1:numel(groups)]', groupSizes(:)]; % N x 2
    groupIndicesAndSizes = ...
        sortrows(groupIndicesAndSizes, -2); % -2 means sort rows in 
                                            % descending order, by values
                                            % in the second column.  
    nGroups = min([MAX_N_MASKS; numel(groups)]);                        
    retainIndices = groupIndicesAndSizes(1:nGroups, 1);
    groups = groups(retainIndices);

    % Prune unused targets from the target array.
    targetArray = targetArray([groupsByIndex{retainIndices}]);
    clear groupsByIndex % No longer valid.
    
    
    %----------------------------------------------------------------------
    % Remove background flux.
    %----------------------------------------------------------------------    
    fprintf('Removing background flux ...\n');
    targetArray = ...
        remove_background(targetArray, backgroundStruct);
        
    
    %----------------------------------------------------------------------
    % Construct PRF and motion model objects.
    %----------------------------------------------------------------------
    fprintf('Constructing PRF and motion model objects ...\n');

    % Static correction kernel params.
    staticKernelParamStruct = staticKernelClass.create_empty_param_struct();                          
    staticKernelParamStruct.modelType   = MODEL_TYPE;
    staticKernelParamStruct.kernelWidth = KERNEL_WIDTH;
    staticKernelParamStruct.resolution  = SAMPLES_PER_PIXEL;
%    staticKernelParamStruct.paramVector = staticKernelClass.get_default_invariant_dog_params();
    staticKernelParamStruct.paramVector = ...
        [1, 2, 2, 0.2, 3, 3, 0,...
         ceil(KERNEL_WIDTH/2), ceil(KERNEL_WIDTH/2)]; % Allow translation
    prfModelParams = prfModelClass.default_param_struct_from_pa_inputs(paInputStruct);
    prfModelParams.staticKernelParams = staticKernelParamStruct;

    prfModelObject = prfModelClass( prfModelParams );
    motionModelObject = motionModelClass( motionStruct );
    
    
    %----------------------------------------------------------------------
    % Construct aperture model objects and fit the static PRF models to the
    % observations.
    %----------------------------------------------------------------------
    fprintf('Constructing aperture model array ...\n');
    if FIT_ALL_STARS
        fprintf('\tLoading the KIC ...\n');
        
        s = load(kicFile, 'kic'); % Load the KIC.
        catalog = s.kic;
        clear s
    else
        catalog = [];
    end
    
    for iGroup = 1:numel(groups)
        fprintf('\tConstructing aperture model %d ...\n', iGroup);
        
        % Get the subset of targets belonging to this group.
        groupArray = ...
            targetArray(ismember([targetArray.keplerId]', groups{iGroup}));
        
        apertureModelArray(iGroup) = apertureModelClass( ...
            apertureModelClass.create_input_struct(groupArray, catalog, ...
            prfModelObject, motionModelObject) );
                        
        apertureModelArray(iGroup).fit_observations();
    end % for iGroup ...

    % Clear the catalog, if it was loaded. This is a *large* variable, so
    % we dont want to leave it hanging around. 
    clear catalog 
    
        
    %----------------------------------------------------------------------
    % Replace observed pixels with simulated data, if desired, and
    % initialize the static correction kernel.
    %----------------------------------------------------------------------
    if USE_SIMULATED_DATA
        fprintf('Replacing observed apertures with simulated data ...\n');
        
        kernelWidth = prfModelObject.get_kernel_width();
        
        %appliedKernel = gausswin(kernelWidth)*gausswin(kernelWidth)';                                 % Gaussian blur.
        appliedKernel = zeros(kernelWidth); appliedKernel(fix(kernelWidth/4),fix(kernelWidth/4)) = 1; % translation
        %appliedKernel = zeros(kernelWidth); appliedKernel(fix(kernelWidth/4),:) = 1;                  % rooftop

        appliedKernel = appliedKernel / sum(appliedKernel(:)); % Normalize
        
        for iAperture = 1:numel(apertureModelArray)
            fprintf('\tSimulating observations for aperture %d ...\n', iAperture);
            
            apertureModelArray(iAperture).set_observed_pixels( ...
                apertureModelArray(iAperture).simulate_pixels(appliedKernel) ...
            );
        end
    end
                
    
    %----------------------------------------------------------------------
    % Find the minimizing parameters for the static PRF correction kernel
    % model.
    %----------------------------------------------------------------------   
    fprintf('Fitting the static PRF correction kernel ...\n');
    
    % Perform the minimization
    objectiveFunction = @(x) apertureModelClass.fit_multi_aperture_model(x, apertureModelArray);
    options = optimset( ...
        'MaxIter', MAX_ITERATIONS, ...
        'Display', 'iter', ...
        'FunValCheck', 'on',...
        'TolFun', 1.0e-2, ...    % Stop if the function value changes by less than this amount.
        'TolX', 1.0e-2 ...       % Stop if the param vector moves by less than this amount.
    );
                   
    [recoveredParams, figureOfMerit ] = ...
        fminsearch(objectiveFunction, staticKernelParamStruct.paramVector, options);
    
    % Because a normalization is performed when evaluating the dynamic PRF,
    % fminsearch may find a kernel that fits some multiple of the applied 
    % kernel. We therefore normalize the recovered kernel before doing the
    % final fit.
    apertureModelClass.fit_multi_aperture_model( recoveredParams, apertureModelArray);

    %----------------------------------------------------------------------
    % Find the minimizing parameters for the dynamic PRF correction kernel
    % model.
    %----------------------------------------------------------------------   

    %----------------------------------------------------------------------
    % Put results in the  output struct. 
    %----------------------------------------------------------------------    
    outputStruct.apertureModelArray = apertureModelArray;
    outputStruct.groups = groups;
    outputStruct.recoveredParams = recoveredParams;
    outputStruct.residuals = ...
        apertureModelClass.get_multi_aperture_residuals(apertureModelArray);
    
    if USE_SIMULATED_DATA
        outputStruct.appliedParams = appliedParams;
    end
end


%********************************** EOF ***********************************

