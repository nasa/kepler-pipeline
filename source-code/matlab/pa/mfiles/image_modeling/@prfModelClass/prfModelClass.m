classdef prfModelClass < handle
%************************************************************************** 
% classdef prfModelClass < handle
%************************************************************************** 
% Manage the static PRF model and the two kernel models and apply methods
% in order to produce sampled PRFs at any given position and cadence.
%
%     PRF_dynamic(x,y,t) =  h(x,y,t) * g(x,y) * PRF_static(x,y)
%
%
% METHODS:
%
%     prfModelClass()
%
%         Constructor. May be called in any of the following ways:
%
%             prfModelClass()
%             prfModelClass( prfModelObject )
%             prfModelClass( prfModelInputStruct )
%
%         where
%             prfModelInputStruct : 
%             |-.prfModel               :
%             |-.fcConstants            :
%             |-.samplesPerPixel        :
%             |-.staticKernelParams     : If empty, no correction kernel is
%             |                           applied. 
%             |-.dynamicKernelParams    :
%             |-.timestamps             :
%              -.debugLevel [1 x 1 int] : An integer (set to zero during 
%                                         pipeline operation).
%
% 
%     evaluate(starCentroidRow, starCentroidColumn, cadences, ...
%              sampleRows, sampleCols )
%
%         Evaluate the PRF model for the point source at the specified
%         cadences and sub-pixel row/column positions.
%
%             sampleRows  : A vector of sub-pixel row positions at which to
%                           evaluate the PRF. 
%             sampleCols  : A vector of sub-pixel column positions at which
%                           to evaluate the PRF. 
%
%     set_static_model( prfCollectionObject )
%
%     set_static_modification_model( prfStaticCorrectionKernelObject)
%
%     set_dynamic_model(prfDynamicCorrectionKernelObject )
%
%
%     
% PROPERTIES:
%
%     staticPrfObject     : PRF_static(x,y)
%         
%     staticKernelObject  : g(x,y)
% 
%     dynamicKernelObject : h(x,y,t)
%                                     
%     samplesPerPixel     : Integer number of samples per pixel.
%
%     subsamplingMethod   : 'interp' or 'explicit'.
%
%     timestamps          : A nCadences-by-1 array of mid-cadence timestamps.
%     
%     debugStruct         : Container for debugging flags 
%
%
% USAGE:
%     Within the pipeline:
%         
% 
%
% NOTES:
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
        REPLACE_INF = 0;       % Replace non finite (NaN and Inf) values in 
                               % evaluated PRF arrays with this value. If
                               % set to the empty array [], then non-finite
                               % values are not replaced.
                               
        DEFAULT_SAMP_PER_PIX = 4;
        DEFAULT_KERNEL_MODEL = 'INVARIANT_DOG';
        DEFAULT_KERNEL_WIDTH = 21;
        
        DEFAULT_SUBSAMPLING_METHOD = 'explicit';
    end
    
%     properties (GetAccess = 'public', SetAccess = 'private')
    properties (GetAccess = 'public', SetAccess = 'public')
        
        staticPrfObject     = [];         % PRF_static(x,y)
        
        staticKernelObject  = [];         % g(x,y)

        dynamicKernelObject = [];         % h(x,y,t)

        samplesPerPixel     = prfModelClass.DEFAULT_SAMP_PER_PIX;
        
        subsamplingMethod   = prfModelClass.DEFAULT_SUBSAMPLING_METHOD;
        
        renormalize         = false;      % Renormalize PRFs after applying
                                          % corrections.
        
        timestamps          = [];         % An array of mid-cadence 
                                          % timestamps 
        
        debugStruct         = struct;     % Container for debugging flags 
                                          % and related data.
     end
    
    %% ------------------------- Public Methods ---------------------------
    methods 
        
        %**
        % Constructor
        %   If no argument is passed a default object is created. If an
        %   argument is passed it may contain any of the following:
        %   1) An empty cell array (constructs a defalt object).
        %   2) A prfModelClass object (copy constructor).
        %   3) A PRF model input struct.
        function obj = prfModelClass( arg )
            %--------------------------------------------------------------
            % Default constructor
            %--------------------------------------------------------------
            if nargin == 0 || isempty(arg)
            
            %--------------------------------------------------------------
            % Copy constructor
            %--------------------------------------------------------------
            elseif nargin == 1 && isa(arg, 'prfModelClass')
                prfModelObject = arg;
                p = properties('prfModelClass'); % Public properties
                for i = 1:numel(p)
                    propertyAttr = findprop(prfModelObject, p{i});
                    if ~propertyAttr.Constant && ~propertyAttr.Abstract
                        
                        % Use copy constructors for handle-class objects.
                        if isa(arg.(p{i}), 'handle')
                            constructor = str2func(class(arg.(p{i})));
                            obj.(p{i}) = constructor(arg.(p{i}));
                        else
                            % An older object's properties may be a
                            % subset of the properties listed in the
                            % current class definition.
                            if any(ismember( ...
                                properties(prfModelObject), p{i})) 
                                obj.(p{i}) = prfModelObject.(p{i});
                            end
                        end
                    end
                end
                  
            %--------------------------------------------------------------
            % Construct from a PRF model input struct.
            %--------------------------------------------------------------
            else
                obj.initialize_debug_struct( arg.debugLevel );  
                
                % Initialize the static model
                obj.staticPrfObject = prfCollectionClass( ...
                    blob_to_struct(arg.prfModel.blob), arg.fcConstants);
                
                % Initialize the static correction kernel model.
                if ~isempty(arg.staticKernelParams)
                    obj.staticKernelObject = ...
                        staticKernelClass(arg.staticKernelParams);
                end
                
                % Initialize the dynamic correction kernel model.
                if ~isempty(arg.dynamicKernelParams)
                    obj.dynamicKernelObject = ...
                        dynamicKernelClass(arg.dynamicKernelParams);
                end
        
            end
        end
        
        
        %**
        % evaluate()
        prfValues = evaluate(obj, starRow, starCol, sampleRows, sampleColumns, cadence);
        
        %**
        % evaluate_static()
        sampledPrfStruct = evaluate_static(obj, ...
            starRow, starColumn, pixelRows, pixelColumns);

        %**
        % evaluate_static_corrected()
        sampledPrfStruct = evaluate_static_corrected(obj, ...
            starRow, starColumn, pixelRows, pixelColumns);
 
        %**
        % apply_static_correction()
        corrected = apply_static_correction(obj, sampledStaticPrfStruct);

        %**
        % apply_dynamic_correction()
        corrected = apply_dynamic_correction(obj, sampledStaticPrfStruct, cadence);

        %% Get Methods

        %**
        % get_num_samples_per_pixel()
        function samplesPerPixel = get_num_samples_per_pixel(obj)
            samplesPerPixel = obj.samplesPerPixel;
        end
                
        %**
        % get_static_width_in_pixels()
        %     Return the width (in pixels) of the non-zero portion of the
        %     static PRF.
        function width = get_static_width_in_pixels(obj)
            pco   = get(obj.staticPrfObject, 'prfCenterObject');
            width = get(pco, 'nPrfArrayRows');
        end
         
        %**
        % get_static_kernel_object()
        function staticKernelObject = get_static_kernel_object(obj)
            staticKernelObject = obj.staticKernelObject;
        end
        
        %**
        % get_static_kernel_param_vector()
        function params = get_static_kernel_param_vector(obj)
            params = obj.staticKernelObject.get_parameters();
        end

        %**
        % get_kernel_width()
        %
        % Return the width of the corrective kernels in number of points.
        function width = get_kernel_width(obj)
            width = obj.staticKernelObject.get_width();
        end
        
        %% Set Methods

        %**
        % set_num_samples_per_pixel()
        function set_num_samples_per_pixel(obj, samplesPerPixel)
            obj.samplesPerPixel = fix(samplesPerPixel);
            obj.notify('stateChange');
        end
        
        %**
        % set_static_kernel_param_vector()
        function set_static_kernel_param_vector(obj, params)
            obj.staticKernelObject.set_parameters(params);
            obj.notify('stateChange');
        end       
        
        %**
        % set_static_kernel_object()
        function set_static_kernel_object(obj, staticKernelObject)
            obj.staticKernelObject = staticKernelObject;
            obj.notify('stateChange');
        end

        %% Visualization Methods
        %**
        % plot_model_components()
        plot_model_components(obj, row, column, cadence);

        %**
        % plot_static_correction()
        plot_static_correction(obj, row, column);

%         %**
%         % plot_static_correction_cross_section()
%         [rowMat, colMat] = plot_static_correction_cross_section(obj, ... 
%             row, column, cadence, crossSectionRows, crossSectionColumns);

    end
    
    %% ------------------------- Private Methods --------------------------
    methods (Access = 'public') % (Access = 'private')        
        
        %**
        % Set debugging flags given the PA debug level.
        initialize_debug_struct(obj, debugLevel);
        
        %**
        % get_subsampled_static_prf_grid()
        subsampledGridStruct = get_subsampled_static_prf_grid(obj, ...
            starRow, starColumn, pixelRows, pixelColumns);
    
        %**
        % get_subsampled_static_prf_grid_interp()
        subsampledGridStruct = get_subsampled_static_prf_grid_interp(obj, ...
            starRow, starColumn, pixelRows, pixelColumns);
 
        %**
        % get_subsampled_static_prf_grid_explicit()
        subsampledGridStruct = ...
            get_subsampled_static_prf_grid_explicit(obj, ...
                starRow, starColumn, pixelRows, pixelColumns);
    
        %**
        % subsampled_grid_to_sampled_prf()
        sampledPrfStruct = subsampled_grid_to_sampled_prf(obj, ...
            subsampledGridStruct, pixelRows, pixelColumns);
    end
    
    
    %% ------------------------- Static Methods ---------------------------
    methods (Static)
             
        %**
        % evaluate_normalized_static_prf()
        [valueArray, rowArray, columnArray] = ...
            evaluate_normalized_static_prf(prfObject, ...
                starRow, starColumn, pixelRows, pixelColumns);
        
        %**
        % prf_collection_from_pa_inputs()
        function prfCollectionObject = prf_collection_from_pa_inputs(paInputStruct)
            prfStruct = blob_to_struct(paInputStruct.prfModel.blob);
            prfCollectionObject = prfCollectionClass(prfStruct, paInputStruct.fcConstants);  
        end
    
        %**
        % create_sampled_prf_struct()
        function sampledPrfStruct = create_empty_prf_struct()
             sampledPrfStruct                = struct;
             sampledPrfStruct.starRow        = [];
             sampledPrfStruct.starColumn     = [];
             sampledPrfStruct.cadenceTimes   = [];
             sampledPrfStruct.sampleRows     = [];
             sampledPrfStruct.sampleColumns  = [];
             sampledPrfStruct.values         = [];
        end
        
        %**
        % create_empty_input_struct()
        function paramStruct = create_empty_input_struct()
             paramStruct                     = struct;
             paramStruct.prfModel            = [];
             paramStruct.fcConstants         = [];
             paramStruct.samplesPerPixel     = [];
             paramStruct.subsamplingMethod   = [];
             paramStruct.staticKernelParams  = [];
             paramStruct.dynamicKernelParams = [];
             paramStruct.timestamps          = [];
             paramStruct.debugLevel          = 0;
        end
        
        %**
        % default_param_struct_from_pa_inputs()
        function paramStruct = default_param_struct_from_pa_inputs(paInputStruct)
             paramStruct                     = struct;
             paramStruct.prfModel            = paInputStruct.prfModel;
             paramStruct.fcConstants         = paInputStruct.fcConstants;
             paramStruct.samplesPerPixel     = prfModelClass.DEFAULT_SAMP_PER_PIX;
             paramStruct.subsamplingMethod   = prfModelClass.DEFAULT_SUBSAMPLING_METHOD;
             paramStruct.staticKernelParams  = prfModelClass.get_default_static_kernel_params();
             paramStruct.dynamicKernelParams = prfModelClass.get_default_dynamic_kernel_params();
             paramStruct.timestamps          = paInputStruct.cadenceTimes.midTimestamps;
             paramStruct.debugLevel          = 0;           
        end
        
        %**
        % get_default_static_kernel_params()
        function paramStruct = get_default_static_kernel_params()
            paramStruct = [];
       end
        
        %**
        % get_default_dynamic_kernel_params()
        function paramStruct = get_default_dynamic_kernel_params()
            paramStruct = [];
        end

        %**
        % loadobj
%         function obj = loadobj(obj)
%             
%             s = struct(obj);
%             s = s.staticPrfObject;    
%             prfCenterObejct = prfClass(s.prfCenterObejct);
%             prfCornerObejct = prfClass(s.prfCornerObejct);
%             pco = prfCollectionClass(s);
%             
%             obj.staticPrfObject = pco;
%                             
%         end


    end  
    
    %% ----------------------------- Events -------------------------------
    events
        stateChange
    end
    
end

%********************************** EOF ***********************************
