classdef apertureModelClass < handle
%************************************************************************** 
% classdef apertureModelClass < handle
%************************************************************************** 
% Given background-corrected observations from a set of pixels (typically a
% target aperture) and cadences, model the observations as a linear
% combination of sampled PRFs and a constant background term.
%
% More generally, we are fitting a set of N+1 basis vectors at each cadence
% to the observed pixel values. The first N vectors are sampled PRFs which
% are determined by the centroids of all known stars expected to contribute
% significant flux to any of the observations and a PRF model, which
% describes how the flux of a point source whose centroid falls at a given
% location will be distributed among the surrounding pixels. The centroids
% at each cadence are determined from the stellar parameters (RA and Dec)
% along with the motion model. The final basis vector is a constant vector
% intended to capture any remaining bias in the observations.
%
%
% In the descriptions below,
%
%     nCadences denotes the number of cadences BEING MODELED and not the
%               total number of cadences in the quarter. 
%
%     nStars    denotes the number of stars in the model.
%
%     nTargets  denotes the number of individual target apertures
%               comprising the total aperture being modeled. In most cases
%               this number is '1', but some apertures overlap and these
%               may be submitted as a group. 
%
%     nPixels   denotes the total number of pixels comprising the total
%               aperture being modeled.
%
%
% METHODS:
%
%     apertureModelClass()
%
%         Constructor. May be called in any of the following ways:
%
%             apertureModelClass()
%             apertureModelClass( apertureModelObject )
%             apertureModelClass( apertureModelInputStruct )
%
%         where
%             apertureModelInputStruct : 
%             |-.configStruct      : The apertureModelConfigurationStruct
%             |                      found in a PA input struct.
%             |-.targetArray       : [1 x nTargets struct] Pruned to
%             |                      include only the cadences being
%             |                      modeled. These target structs MUST
%             |                      contain finite and valid RAs and Decs.
%             |-.midTimestamps     : [nCadences x 1 double] Mid-cadence
%             |                      timestamps (MJD) for each modeled
%             |                      cadence. 
%             |-.catalog           : [1 x nStars struct] If empty, only the 
%             |                      stars provided in the targetArray 
%             |                      field are used to model the aperture. 
%             |-.keplerIds         : An array of Kepler IDs. If not empty,
%             |                      the specified stars are used to
%             |                      construct the model, provided that 
%             |                      their parameters are available in the
%             |                      'catalog' or 'targetArray' fields.  
%             |-.prfModelObject    : [prfModelClass]
%             |-.motionModelObject : [motionModelClass]     
%              -.debugLevel        : [1 x 1] An integer (set to zero
%                                    during pipeline operation).  
%
%     evaluate( cadences )
%         Evaluate the model for the specified cadences.
%
%     update_basis()
%         Computes basis images from the PRF model and motion models for 
%         each star at each cadence.  
%
%     initialize(catalog, prfModelObject, motionModelObject)
%         - Identify contributing stars.
%         - Create the contributing star struct array.
%         - Evaluate the relevant portion of the static PRF for each
%           contributing star. 
% 
%     update_basis(prfModelObject, motionModelObject)
%         Update the basis images at each cadence given new PRF and/or
%         motion models.
%
%     fit_observations( targetArray ) 
%         Fits the current basis images to the pixel values in targetArray.
%         targetArray must be the set of targets whose pixels comprise the
%         aperture.  
%
%     
% PROPERTIES:
%
%     configStruct
%     |-.excludeSnrThreshold  : Include catalog stars in the model only if
%     |                         their expected peak pixel SNR is above this
%     |                         threshold.
%     |-.lockSnrThreshold     : Do not allow RA/Dec fitting of stars whose
%     |                         expected peak pixel SNR falls below this
%     |                         threshold.
%     |-.amplitudeFitMethod   : One of the following strings: 'bbnnls',
%     |                         'lsqnonneg', or 'unconstrained'. The
%     |                         'lsqnonneg' method requires the
%     |                         Optimization toolbox and should yield
%     |                         similar results to 'bbnnls'. The 
%     |                         unconstrained fit allows negative coefs
%     |                         in the solution and should probably be
%     |                         avoided. 
%     |-.raDecFittingEnabled  : If FALSE, catalog positions are fixed. If
%     |                         TRUE, update the positions for eligible
%     |                         stars.  
%     |-.raDecFitMethod       : Either 'nlinfit' or 'lsqnonlin' 
%     |                         ('lsqnonlin' is valid only if the Matlab
%     |                         Optimization Toolbox is available).
%     |-.raDecMaxDeltaPixels  : Maximum allowed deviation from catalog
%     |                         positions in units of pixels. 
%     |-.raDecRestoringCoef   : Coefficient determining how strongly each
%     |                         star's position is pulled back toward the
%     |                         catalog position during the fitting
%     |                         process. If zero, then no restoring force
%     |                         is applied.   
%     |-.raDecRepulsiveCoef   : Coefficient determining how strongly stars
%     |                         are pushed away from one another during the
%     |                         fitting process. If zero, then no repulsive
%     |                         force is applied.  
%     |-.raDecMaxIter         : Maximum number of iterations when fitting
%     |                         star positions (RA & Dec) for an aperture. 
%     |-.raDecTolFun          : Stop the optimization procedure if the
%     |                         function value changes less than this
%     |                         amount.  
%     |-.raDecTolX            : Stop the optimization procedure if the
%     |                         parameter vector moves less than this
%     |                         amount.
%     |-.maxNumStars          : If specified and not empty, include no more
%     |                         than maxNumStars in the model. Stars are
%     |                         selected in order of their expected flux
%     |                         contribution to the aperture. If empty, no
%     |                         limit on the number of contributing stars 
%     |                         is imposed. (default=[])
%     |-.maxDeltaMagnitude    : This parameter is not directly used in
%     |                         apertureModelClass, but defines the limit
%     |                         of a "reasonable" deviation in fitted
%     |                         magnitude from a star's catalog magnitude.
%     |-.ukirtMagnitudeThreshold : A scalar magnitude. UKIRT stars brighter
%     |                         than this magnitude will be excluded from
%     |                         aperture models.
%      -.usePrecomputedStaticPrfs
%
%     pixelRows          : 1-by-nPixels
%
%     pixelColumns       : 1-by-nPixels
%         
%     basisVectors       : nPixels-by-(nStars+1)-by-nCadences
%         
%     coefficients       : nCadences-by-(nStars+1) matrix of model coefficients.
%                          coefs(:,end) represents background flux 
%                          coefs(:,1:end-1) represent stellar flux estimates.
%                          
%                          The model of pixel p at cadence c is given by
%
%                           V
%                          SUM( coefficients(c,v) * basisVectors(p, v, c))
%                          v=1
%                           
%                          where v = 1, 2, ..., V indexes each basis
%                          vector.
%
%     midTimestamps      : A nCadences-by-1 array of mid-cadence timestamps
%                          (MJD). 
%                                                                                        
%     prfModelHandle     : A handle to the common prfModelClass object.
%         
%     motionModelHandle  : A handle to the common motionfModelClass object.
%         
%     contributingStars  : An nStars-length struct array having the
%                          following fields:
%
%                          keplerId
%                          keplerMag
%                          raDegrees
%                          decDegrees
%                          lockRaDec    : If set to 'true', do not allow
%                                         updating of RA & Dec. 
%                          centroidRow  : An nCadences-by-1 time series of
%                                         sub-pixel row coordinates for 
%                                         this star's centroid. 
%                          centroidCol  : An nCadences-by-1 time series of
%                                         sub-pixel column coordinates for
%                                         this star's centroid.
%                          prf          : A nPoints-by-nCadences array  of 
%                                         static PRF values, where nPoints
%                                         is the number of samples per 
%                                         pixel (see prfModolClass). Note 
%                                         that sum(prf(:,n)) == 1. THIS
%                                         FIELD IS USED ONLY WHEN
%                                         usePrecomputedStaticPrfs = true.
%                          catalogMag
%                          catalogRaDegrees
%                          catalogDecDegrees
%
%     observedPixels     : A struct array of observed pixels. Pixel values
%                          are assumed to be background-corrected.
%
%     basisOutOfDate     : A flag indicating the PRF and/or motion models
%                          have changed since basis vectors were last
%                          computed.
%         
%     centroidsOutOfDate : A flag indicating the motion model has changed
%                          since contributing star centroids were last
%                          computed. 
%                          
%     twelfthMagFlux     : Total flux from a twelfth magnitude star
%                          (e-/sec). This constant is obtained from the
%                          fcConstants field of a PA input struct when
%                          inputs_from_pa_data_struct() is called.
%                          Otherwise a default value of 214100 is used.
%
%     debugStruct        : Container for debugging flags 
%
%
% CONSTANT PROPERTIES:
% (only properties warranting some explanation are listed here)
%
%     MIN_CONFIGURATION_WEIGHT
%                        : The minimum "energy" of a hypothetical star
%                          configuration returned by the method
%                          compute_source_configuration_energy().
%
%     MAX_CONFIGURATION_WEIGHT
%                        : The maximum "energy" of a hypothetical star
%                          configuration returned by the method
%                          compute_source_configuration_energy().
%
%     NO_PENALTY_RADIUS_PIXELS 
%                        : Define a radius in pixels over which star
%                          positions may move without penalty. 
%
%     SIGMOID_TRANSITION_WIDTH_PIXELS
%                        : The distance in pixels over which the sigmoid
%                          function rises from 1 - SIGMOID_TRANSITION_VALUE
%                          to SIGMOID_TRANSITION_VALUE. The sigmoid value 
%                          is incorporated into the star configuration
%                          "energy" when performing RA/Dec fitting with
%                          nlinfit(), which does not allow for hard
%                          constraints. It is used to enforce the constraint
%                          raDecMaxDeltaPixels defined in the configStruct
%                          property.
%
%     SIGMOID_TRANSITION_VALUE 
%                        : See SIGMOID_TRANSITION_WIDTH_PIXELS.
%
% USAGE EXAMPLE:
%
%     apertureModelInputStruct = ...
%         apertureModelClass.inputs_from_pa_data_struct( paDataObject, ...
%             targetIndex, cadenceIndicators);% 
%     apertureModelObject = apertureModelClass(apertureModelInputStruct);
%     apertureModelObject.fit_observations();
%
%
% NOTES:
%     - Observed pixel values in the input struct are assumed to be
%       background-corrected. 
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
        DEGREES_PER_PIXEL                           = 0.001106;
        DEFAULT_EXCLUDE_SNR_THRESHOLD               = 100;
        DEFAULT_USE_PRECOMPUTED_STATIC_PRFS         = false;
    end
    
    % Constants for RA/Dec fitting.
    properties (Constant)
        DEFAULT_FIT_SKY_COORDINATES                 = false;
        DEFAULT_LOCK_SNR_THRESHOLD                  = 500;
        MIN_CONFIGURATION_WEIGHT                    = 0;
        MAX_CONFIGURATION_WEIGHT                    = 1e32;
        SIGMOID_TRANSITION_WIDTH_PIXELS             = 0.01;
        SIGMOID_TRANSITION_VALUE                    = 0.999999;
        NO_PENALTY_RADIUS_PIXELS                    = 1.0;
    end
    
    properties (GetAccess = 'public', SetAccess = 'public')
                
        configStruct            = [];
                
        pixelRows               = [];
        
        pixelColumns            = [];

        basisVectors            = []; 
        
        coefficients            = []; 
                                          
        midTimestamps           = [];          
                                                                                 
        contributingStars       = struct([]); 
                                                 
        prfModelHandle          = [];
        
        motionModelHandle       = [];
                
        observedPixels          = [];       
        
        basisOutOfDate          = true;  
        
        centroidsOutOfDate      = true;
        
        twelfthMagFlux          = 214100; 

        debugStruct             = struct;
     end
    
    %% ------------------------- Public Methods ---------------------------
    methods 
        
        %**
        % Constructor
        %   If no argument is passed a default object is created. If an
        %   argument is passed it may contain any of the following:
        %   1) An empty cell array (constructs a defalt object).
        %   2) A apertureModelClass object (copy constructor).
        %   3) An aperture model input struct.
        function obj = apertureModelClass( arg )
            %--------------------------------------------------------------
            % Default constructor
            %--------------------------------------------------------------
            if nargin == 0 || isempty(arg)
            
            %--------------------------------------------------------------
            % Copy constructor
            %--------------------------------------------------------------
            elseif nargin == 1 && isa(arg, 'apertureModelClass')
                apertureModelObject = arg;
                p = properties('apertureModelClass'); % Public properties
                for i = 1:numel(p)
                    propertyAttr = findprop(apertureModelObject, p{i});
                    if ~propertyAttr.Constant && ~propertyAttr.Abstract
                        
                        % Use copy constructors for handle-class objects.
                        if isa(arg.(p{i}), 'handle')
                            constructor = str2func(class(arg.(p{i})));
                            obj.(p{i}) = constructor(arg.(p{i}));
                        else
                            % An older object's properties may be a subset
                            % of the properties listed in the current class
                            % definition.
                            if any(ismember( ...
                                properties(apertureModelObject), p{i})) 
                                obj.(p{i}) = apertureModelObject.(p{i});
                            end
                        end
                    end
                end
                  
            %--------------------------------------------------------------
            % Construct from an aperture model input struct.
            %--------------------------------------------------------------
            else               
                if ~apertureModelClass.is_valid_input_struct(arg)
                   error('Invalid input struct'); 
                end
                obj.initialize(arg);  
                addlistener(obj.prfModelHandle,   'stateChange',@obj.handle_prf_model_change);
                addlistener(obj.motionModelHandle,'stateChange',@obj.handle_motion_model_change);
            end
        end
        
        %**
        % evaluate()
        pixelArray = evaluate(obj, cadences);

        %**
        % set_coefficients_from_catalog_magnitudes()
        function set_coefficients_from_catalog_magnitudes(obj, cadenceDurationInMinutes)
            if obj.get_num_contributing_stars() > 0
                m0 = 12;
                f0 = obj.twelfthMagFlux;
                m = [obj.contributingStars.keplerMag];
                f = f0 * 60 * cadenceDurationInMinutes * mag2b(m - m0);
                obj.coefficients(:,1:length(f)) = repmat(f, [obj.get_num_cadences(), 1]);
                obj.coefficients(:,end) = 0; % No constant offset.
            end
        end
        
        %**
        % get_photometry_by_kepler_id()
        photometryStruct = get_photometry_by_kepler_id(obj, keplerId);

        %**
        % extract_photometry()
        photometryStructArray = extract_photometry(obj);

        %**
        % update_basis()
        update_basis(obj);

        %**
        % fit_observations()
        function fit_observations(obj)
            if obj.get_num_contributing_stars() == 0 || ...
               ~obj.configStruct.raDecFittingEnabled || ...
               all([obj.contributingStars(:).lockRaDec])
           
                obj.fit_amplitudes_to_observations();              
            else
                obj.fit_amplitudes_and_positions_to_observations();
            end
        end
        
        %**
        % compute_chi_square_residuals()
        residuals = compute_chi_square_residuals(obj, cadences);

        %**
        % simulate_pixels()
        pixelArray = simulate_pixels(obj, kernel);
        
        %**
        % is_inside_aperture()
        tf = is_inside_aperture(obj, row, column);
        
       
        %% Get Methods

        %**
        % get_num_cadences()
        function nCadences = get_num_cadences(obj)
            nCadences = length(obj.midTimestamps);
        end
        
        %**
        % get_num_pixels()
        function nPixels = get_num_pixels(obj) 
            nPixels = length(obj.pixelRows);
        end
        
        %**
        % get_num_contributing_stars()
        function nStars = get_num_contributing_stars(obj) 
            nStars = numel(obj.contributingStars);
        end
        
        %**
        % get_pixel_and_motion_gap_indicators()
        function gapIndicators = get_pixel_and_motion_gap_indicators(obj)
            pixelGaps     = any([obj.observedPixels.gapIndicators], 2);
            centroidGaps  = obj.motionModelHandle.get_gap_indicators(); 
            gapIndicators = pixelGaps | centroidGaps;
        end

        %**
        % get_motion_gap_indicators
        function gapIndicators = get_motion_gap_indicators(obj)
            gapIndicators = obj.motionModelHandle.get_gap_indicators();
        end
        
        %**
        % get_all_pixels_gapped_indicators()
        %
        % gapIndicators(c)==true  : all pixels are gapped on cadence 'c'
        % gapIndicators(c)==false : one or more pixels are not gapped on
        %                           cadence 'c' 
        function gapIndicators = get_all_pixels_gapped_indicators(obj)
            gapIndicators = all([obj.observedPixels.gapIndicators], 2);
        end
        
        %**
        % get_observed_values_and_sigmas()
        [pixelValueMat, pixelSigmaMat, pixelGapMat] = ...
            get_observed_values_and_sigmas(obj, cadences);

        
        %% Set Methods

        %**
        % set_observed_pixels()
        function set_observed_pixels(obj, pixelArray)
            obj.observedPixels = pixelArray;
        end
 
        %**
        % set_prf_model()
        function set_prf_model(obj, prfModelObject)
            obj.prfModelHandle = prfModelObject;
            obj.basisOutOfDate = true;
        end
        
        %**
        % set_motion_model()
        function set_motion_model(obj, motionModelObject)
            obj.motionModelHandle  = motionModelObject;
            obj.centroidsOutOfDate = true;
        end
        
        %% Event Handling Methods
        
        %**
        % handle_prf_model_change()
        function handle_prf_model_change(obj, src, evnt)
            obj.basisOutOfDate = true;
        end
        
        %**
        % handle_motion_model_change()
        %
        % If the motion model has changed, then both the centroids and
        % basis vectors are out of date. 
        function handle_motion_model_change(obj, src, evnt)
            obj.centroidsOutOfDate = true;
            obj.basisOutOfDate     = true; 
        end
        
        %**
        % clear_basis_out_of_date()
        function clear_basis_out_of_date(obj)
            obj.basisOutOfDate = false;
        end
        
        %**
        % clear_centroids_out_of_date()
        function clear_centroids_out_of_date(obj)
            obj.centroidsOutOfDate = false;
        end

         %% Visualization Methods
       
        %**
        % visualize_contributing_stars()
        visualize_contributing_stars(obj, cadence, spp, scalePrfsByCoefs);
        
        %**
        % plot_star_locations_on_image()
        plot_star_locations_on_image( obj, cadenceIndex, keplerIds );
        
    end
    
    %% ------------------------- Private Methods --------------------------
    methods (Access = 'public') % (Access = 'private')        
        
        %**
        % Set debugging flags given the PA debug level.
        initialize_debug_struct(obj, debugLevel);
  
        %**
        % initialize()
        initialize(obj, inputStruct);

        %**
        % initialize_contributing_stars()
        initialize_contributing_stars(obj, targetArray, kics);
        
        %**
        % initialize_contributing_stars_from_list()
        initialize_contributing_stars_from_list(obj, targetArray, kics, keplerIds);
        
        %**
        % compute_contributing_star_centroids()
        compute_contributing_star_centroids(obj, returnZeroBased);
        
        %**
        % estimate_peak_snr_per_star()
        [estimatedPeakSnr, minDistToValidPixel] = ...
            estimate_peak_snr_per_star(obj);
        
        %**
        % determine_contributing_stars()
        [isContributingStar, fractionalFlux] = ...
            determine_contributing_stars(obj);
                
        %**
        % precompute_subsampled_static_prfs()
        precompute_subsampled_static_prfs(obj);
        
        %**
        % fit_amplitudes_to_observations()
        fit_amplitudes_to_observations(obj)

        %**
        % fit_amplitudes_and_positions_to_observations()
        fit_amplitudes_and_positions_to_observations(obj)
    
    end
    
    
    %% ------------------------- Static Methods ---------------------------
    methods (Static)
                 
        %**
        % fit_multi_aperture_model()
        figureOfMerit = fit_multi_aperture_model( ...
            configStruct, apertureModelArray);
        
        %**
        % get_multi_aperture_residuals()
        function residuals = get_multi_aperture_residuals( apertureModelArray )
            nApertures = numel(apertureModelArray);           
            residuals = cell(1, nApertures);
            for iAperture = 1:nApertures
                residuals{iAperture} = ...
                    apertureModelArray(iAperture).compute_chi_square_residuals();      
            end 
            residuals = vertcat(residuals{:});
        end     
        
        %**
        % compute_source_configuration_energy()
        w = compute_source_configuration_energy(ra, dec, ...
            catalogRa, catalogDec, restoringCoef, repulsiveCoef, ...
            noPenaltyRadius);
        
        %**
        % group_apertures_by_overlap()
        [groupsByKepId, groupsByIndex] = ...
            group_apertures_by_overlap(targetArray);
        
        %**
        % is_soc_catalog()
        tf = is_soc_catalog(catalog);
        
        %**
        % get_attribute_arrays_from_catalog_struct()
        [kepIdArray, kepMagArray, raHoursArray, decDegreesArray] = ...
            get_attribute_arrays_from_catalog_struct(catalog);
        
        %**
        % angular_separation_degrees()
        degrees = angular_separation_degrees( raDec1, raDec2 );
        
        
        %% Parameter-Related Methods

        %**
        % Return a struct compatible with the existing pipeline input
        % validation method.
        fieldsAndBounds = get_config_struct_fields_and_bounds();
        
        %**
        % get_default_params()
        function paramStruct = get_default_params()
            paramStruct = struct;
            paramStruct.excludeSnrThreshold      = ...
                apertureModelClass.DEFAULT_EXCLUDE_SNR_THRESHOLD;
            paramStruct.lockSnrThreshold         = ...
                apertureModelClass.DEFAULT_LOCK_SNR_THRESHOLD;
            paramStruct.amplitudeFitMethod       = 'bbnnls';
            paramStruct.raDecFittingEnabled      = ...
                apertureModelClass.DEFAULT_FIT_SKY_COORDINATES;
            paramStruct.raDecFitMethod           = 'nlinfit';
            paramStruct.raDecMaxDeltaPixels      = 5;
            paramStruct.raDecRestoringCoef       = 1e8;
            paramStruct.raDecRepulsiveCoef       = 1.0;
            paramStruct.raDecMaxIter             = 100;
            paramStruct.raDecTolFun              = 1e-8;
            paramStruct.raDecTolX                = 1e-8;
            paramStruct.maxDeltaMagnitude        = 1.0;
            paramStruct.maxNumStars              = []; % No limit enforced if empty.
            paramStruct.ukirtMagnitudeThreshold  = 18.0;
            paramStruct.usePrecomputedStaticPrfs = ...
                apertureModelClass.DEFAULT_USE_PRECOMPUTED_STATIC_PRFS;
        end

        %**
        % inputs_from_pa_data_struct()
        inputStruct = inputs_from_pa_data_struct( paDataStruct, ...
            targetIndices, cadenceIndicators);

        %**
        % is_valid_input_struct()
        isValid = is_valid_input_struct( apertureModelInputStruct );
        
        %**
        % create_empty_input_struct()
        function inputStruct = create_empty_input_struct()
            inputStruct                         = struct;
            inputStruct.configStruct            = struct([]);
            inputStruct.targetArray             = struct([]);    
            inputStruct.midTimestamps           = [];
            inputStruct.catalog                 = [];
            inputStruct.prfModelObject          = [];
            inputStruct.motionModelObject       = [];   
            inputStruct.debugLevel              = 0;
        end
        
        
        %% Visualization Methods
        
        %**
        % plot_aperture_model()
        plot_aperture_model(apertureModelObject, cadence);
 
        %**
        % plot_two_aperture_models()
        plot_two_aperture_models(apertureModelObject1, ...
                                 apertureModelObject2, ...
                                 labels, cadence);
                             
        %**
        % visualize_position_weighting_function()
        visualize_star_configuration_energy(nSamples, deviateNPixels, ...
            catalogRa, catalogDec, varargin)  

    end  
    
end

%********************************** EOF ***********************************
