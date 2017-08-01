classdef prfFittingDemoClass < handle
%************************************************************************** 
% classdef prfFittingDemoClass
%************************************************************************** 
% Demonstrate dynamic PRF fitting.
%
% INPUTS
%     prfFittingDemoClass()
%
%         Constructor. May be called in any of the following ways:
%
%             prfFittingDemoClass()
%             prfFittingDemoClass( paramStruct )
%             prfFittingDemoClass( paramStruct, prfModelObject )
%
%         NOTE that if a prfModelObject is provided it will supercede any
%         related parameters provided in paramStruct.
%
% USAGE
%     This class is intended to be used int he following ways:
%
%     (1) To fit a PRF model to a channel
%
%         EXAMPLE:
%         >> params = prfFittingDemoClass.get_default_param_struct
%         >> params.flags.cleanCosmicRays = false
%         >> prfDemoObj = prfFittingDemoClass(params)
%         >> prfModelObj = prfDemoObj.fit_prf_model()
%
%     (2) To extract photometry, given a PRF model.
% 
%         EXAMPLE:
%         >> params = prfFittingDemoClass.get_default_param_struct
%         >> params.flags.useNonTargetStars = true
%         >> params.cadences = 1:288
%         >> prfDemoObj = prfFittingDemoClass(params, prfModelObj)
%         >> starStruct = prfDemoObj.extract_phomotmetry()
%
%
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
    %% ----------------------------- Data ---------------------------------
    properties (Constant)

    end
    
    % Set access is private because the event processing won't work
    % correctly if the motion and PRF models are set haphazardly.
    properties (GetAccess = 'public', SetAccess = 'private')
        
        params             = prfFittingDemoClass.get_default_param_struct();
        
        targetArray        = [];
        
        groups             = {};
        
        prfModelObject     = [];
        
        motionModelObject  = [];
        
        apertureModelArray = [];
    end

    %% ------------------------- Public Methods ---------------------------
    methods 
        
        %**
        % Constructor
        function obj = prfFittingDemoClass( paramStruct, prfModelObject )
            
            if exist('paramStruct', 'var') && ~isempty( paramStruct )
                obj.params = paramStruct;
            end
            
            if exist('prfModelObject', 'var')
                obj.prfModelObject = prfModelObject;
            end
           
            obj.initialize();
        end
        
        %**
        % fit_prf_model()
        prfModelObject = fit_prf_model(obj);    
  
        %**
        % extract_photometry()
        photometryCellArray = extract_photometry(obj);    
    end
    
    
    %% ------------------------- Private Methods --------------------------
    methods (Access = 'public') % (Access = 'private')
        
        %**
        % initialize()
        initialize(obj);
        
        %**
        % initialize_aperture_array()
        initialize_aperture_array(obj);
    end
    
    %% ------------------------- Static Methods ---------------------------
    methods (Static)

        %**
        % get_targets_by_kepler_ids()
        [targetArray, filenames] = ...
            get_targets_by_kepler_ids( keplerIds, taskDir );
        
        %**
        % get_default_param_struct()
        function paramStruct = get_default_param_struct()
             paramStruct                        = struct;

             paramStruct.paTaskDir              = '/path/to/pa/defocused_quarter/pa-matlab-7268-439288';
             paramStruct.maxNumMasks            = 20;
             paramStruct.cadences               = [1; 500; 1100; 1500; 2000; 2500; 3000; 3500; 4000];
             paramStruct.selectedKids = [ ...
                    7009268, ...
                    7009474, ...  %     7009632, ...
                    7009548, ...
                    7009684, ...
                    7009654, ...  %     7009852, ...
                    7009817 ...
                ];

             paramStruct.files.kicFile           = '/path/to/PRF/PRF_photometry/joint_fit_prototype/kic11913013_kicOnly_allStars_back.mat';
%             paramStruct.files.paInputFile       = 'pa-inputs-1.mat'; % Should always be 'pa-inputs-0.mat' if oldStyleTaskDir == false.
             paramStruct.files.paMotionFile      = 'pa_motion.mat';
             paramStruct.files.paBkgndFile       = 'pa_background.mat';
             paramStruct.files.paStateFile       = 'pa_state.mat';
         
             paramStruct.flags.cleanCosmicRays   = false;
             paramStruct.flags.useNonTargetStars = false;
             paramStruct.flags.useSimulatedData  = false;
             paramStruct.flags.oldStyleTaskDir   = true;

             paramStruct.optimization.maxIter    = 500;
             paramStruct.optimization.tolFun     = 1.0e-2;
             paramStruct.optimization.tolX       = 1.0e-4;
             
             paramStruct.prfParams.subsamplingMethod        = 'explicit';
             
             % Initial static kernel parameters.
             kernelWidth                                    = 21;
             samplesPerPixel                                = 4;
             paramStruct.staticKernelParams.modelType       = 'INVARIANT_DOG';
             paramStruct.staticKernelParams.kernelWidth     = kernelWidth;
             paramStruct.staticKernelParams.resolution      = samplesPerPixel;
             paramStruct.staticKernelParams.paramVector ...
                 = [1,   2, 2, ...           % amplitude, std_x, std_y (1st Gaussian)
                    0.2, 3, 3, ...           % amplitude, std_x, std_y (2nd Gaussian)
                    0, ...                   % rotation (radians)
                    ceil(kernelWidth/2), ... % Centroid row position
                    ceil(kernelWidth/2)];    % Centroid col position

             % Simulation static kernel parameters.
             paramStruct.simulation.applyStaticKernel              = true;
             paramStruct.simulation.staticKernelParams.modelType   = 'INVARIANT_DOG';
             paramStruct.simulation.staticKernelParams.kernelWidth = kernelWidth;
             paramStruct.simulation.staticKernelParams.resolution  = samplesPerPixel;
             paramStruct.simulation.staticKernelParams.paramVector = [1, 0, 0, 0, 0, 0, 0];
             
%            paramStruct.simulation.staticKernelParams.paramVector ...
%          = [1,   5, 2, ...         % blur
%             0, 0, 0, ...           %
%             pi/4, ...              % rotate 45 degrees
%             ceil(staticKernelParams.kernelWidth/2) + staticKernelParams.resolution, ... % Shift by one pixel
%             ceil(staticKernelParams.kernelWidth/2) + staticKernelParams.resolution];    % Shift by one pixel
        end

        
        %**
        % prune_pa_targets_and_cadences()
        [paDataStruct] = ...
            prune_pa_targets_and_cadences(paDataStruct, targets, cadences); 
        
        %**
        % remove_background()
        targetDataStruct = remove_background(targetDataStruct, backgroundStruct);
    end    
end

%********************************** EOF ***********************************

