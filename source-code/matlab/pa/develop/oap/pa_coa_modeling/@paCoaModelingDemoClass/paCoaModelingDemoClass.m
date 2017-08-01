classdef paCoaModelingDemoClass < handle
%************************************************************************** 
% classdef paCoaModelingDemoClass
%************************************************************************** 
% Demonstrate aperture modeling as we intend to use it in PA-COA. 
%
% INPUTS
%     paCoaModelingDemoClass()
%
%         Constructor. May be called in any of the following ways:
%
%             paCoaModelingDemoClass()
%             paCoaModelingDemoClass( paramStruct )
%             paCoaModelingDemoClass( paramStruct, prfModelObject )
%
%         NOTE that if a prfModelObject is provided it will supercede any
%         related parameters provided in paramStruct.
%
% USAGE EXAMPLES
%     To fit an aperture model to the observed data, making sure to clean
%     cosmic rays beforehand: 
%
%         >> params = paCoaModelingDemoClass.get_default_param_struct
%         >> params.flags.cleanCosmicRays = true
%         >> demoObj = paCoaModelingDemoClass(params)
%
%     To show side-by-side images of the observed flux values, modeled
%     target flux, and modeled background flux on the first cadence:
%
%         >> demoObj.display_pixel_data_struct( demoObj.aperturePixelArray, ...
%            'cadence', 1, ...
%            'fields', {'values', 'targetFluxEstimates', 'bgStellarFluxEstimates'}, ...
%            'plotType', 'log') 
%
%     To obtain and display the model residual on cadence 1254:
%
%         >> residual = demoObj.get_model_residual(1254, true);
%
%     To plot the normalized PRFs of all stars included in the model on 
%     cadence 1254: 
%
%         >> demoObj.apertureModelObject.visualize_contributing_stars(1254, 8, false)
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
        
        params         = paCoaModelingDemoClass.get_default_param_struct();
        
        targetKeplerId         = [];
        
        prfModelObject         = [];
        
        motionModelObject      = [];
        
        apertureModelObject    = [];
        
        aperturePixelArray     = [];
        
        contributingStarStruct = [];
    end

    %% ------------------------- Public Methods ---------------------------
    methods 
        
        %**
        % Constructor
        function obj = paCoaModelingDemoClass( paramStruct, prfModelObject )
            
            if exist('paramStruct', 'var') && ~isempty( paramStruct )
                
                if ~isfield(paramStruct, 'raDecCadences')
                    paramStruct.raDecCadences = [];
                end
                
                obj.params = paramStruct;
            end
            
            if exist('prfModelObject', 'var')
                obj.prfModelObject = prfModelObject;
            end
           
            obj.initialize();
        end    
    
        %**
        % show_model_residual()
        residualImage = get_model_residual(obj, cadence, displayImage);    
        
    end
    
    
    %% ------------------------- Private Methods --------------------------
    methods (Access = 'public') % (Access = 'private')
        
        %**
        % initialize()
        initialize(obj);
        
    end
    
    %% ------------------------- Static Methods ---------------------------
    methods (Static)
        
        %**
        % remove_background()
        targetDataStruct = remove_background(targetDataStruct, backgroundStruct);

        %**
        % extract_data_cube()
        [dataCube, apertureMask, optimalApertureMask] = ...
            extract_data_cube( pixelDataStruct, dataField, cadences );
        
        %**
        % display_pixel_data_struct()
        display_pixel_data_struct(pixelDataStruct, varargin);
        
        
        %**
        % convert_catalog_to_pa_format()
        catalog = convert_catalog_to_pa_format(catalog);
        
        %**
        % get_default_param_struct()
        function paramStruct = get_default_param_struct()
             paramStruct                        = struct;

             paramStruct.paTaskDir              = '/path/to/pa/k2/c0b/pa-304-q00m2-10.04'; %'/path/to/pa/defocused_quarter/pa-matlab-7268-439288';
             paramStruct.subtaskDir             = 'st-1'; % Use empty string '' if processing an old-style directory.
             paramStruct.cadences               = [10 100 200 300 400 500 600 700 800 900];%[1; 500; 1100; 1500; 2000; 2500; 3000; 3500; 4000];
             paramStruct.raDecCadences          = [400 500 600 700];
             paramStruct.targetIndex            = 1;
             
             paramStruct.files.kicFile          = ''; %'/path/to/catalog/epics_c0_mod10_out4.mat'; %'/path/to/catalog/latestCleanKic.mat';
             paramStruct.files.paInputFile      = 'pa-inputs-0.mat'; % Should always be 'pa-inputs-0.mat' if oldStyleTaskDir == false.
             paramStruct.files.paMotionFile     = 'pa_motion.mat';
             paramStruct.files.paBkgndFile      = 'pa_background.mat';
             paramStruct.files.paStateFile      = 'pa_state.mat';
         
             paramStruct.flags.cleanCosmicRays  = false;
             paramStruct.flags.gapArgaCadences  = true;
             paramStruct.flags.removeBackground = true;
             paramStruct.flags.fittingEnabled    = true;
             
             amConfigStruct.excludeSnrThreshold = 3;
             amConfigStruct.lockSnrThreshold    = 7;
             amConfigStruct.amplitudeFitMethod  = 'bbnnls';
             amConfigStruct.raDecFittingEnabled =  true;
             amConfigStruct.raDecFitMethod      = 'nlinfit';
             amConfigStruct.raDecMaxDeltaPixels =  5;
             amConfigStruct.raDecRestoringCoef  =  0;
             amConfigStruct.raDecRepulsiveCoef  =  0;
             amConfigStruct.raDecMaxIter        =  100;
             amConfigStruct.raDecTolFun         =  1.0e-08;
             amConfigStruct.raDecTolX           =  1.0e-08;
             amConfigStruct.maxDeltaMagnitude   =  1;
             amConfigStruct.maxNumStars         =  10;
             amConfigStruct.usePrecomputedStaticPrfs =  false;             
             paramStruct.apertureModelConfigurationStruct = [];
             
%             paramStruct.apertureModelConfigurationStruct = apertureModelClass.get_default_params(); 
             
             
%              paramStruct.staticKernelParams     = [];             
        end
                
    end    
end

%********************************** EOF ***********************************

