classdef staticKernelClass < handle
%************************************************************************** 
% classdef staticKernelClass < handle
%************************************************************************** 
% Given a row, column position, and possibly a cadence, return an
% appropriate kernel to modify the static PRF.
%
%
% METHODS:
%
%     staticKernelClass()
%
%         Constructor. May be called in any of the following ways:
%
%             staticKernelClass()
%             staticKernelClass( staticKernelObject )
%             staticKernelClass( paramStruct )
%
%     
% PROPERTIES:
%     paramVector  : A numeric parameter vector that determines the model.
%     modelType    : One of the following strings: 
%                    'INVARIANT'          : An unconstrained kernel
%                    'INVARIANT_DOG'
%                    'INVARIANT_GAUSSIAN'
%     kernelWidth  : Integer dimension of the kernelWidth x kernelWidth
%                    convolution kernel.
%     resolution   : The spatial resolution of the kernel in points per
%                    pixel. 
%
% NOTES:
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
    
    properties (GetAccess = 'public', SetAccess = 'public')
        paramVector  = []; % A parameter vector that determines the model.
        modelType    = 'INVARIANT';
        kernelWidth  = 11;
        resolution   = 4;  % Points per pixel.
    end
    
    %% ------------------------- Public Methods ---------------------------
    methods 
        
        %**
        % Constructor
        %   If no argument is passed a default object is created. If an
        %   argument is passed it may contain any of the following:
        %   1) An empty cell array (constructs a defalt object).
        %   2) A staticKernelClass object (copy constructor).
        %   3) A paramStruct.
        function obj = staticKernelClass( arg )
            %--------------------------------------------------------------
            % Copy constructor
            %--------------------------------------------------------------
            if nargin == 1 && isa(arg, 'staticKernelClass')
                staticKernelObject = arg;
                p = properties('staticKernelClass'); % Public properties
                for i = 1:numel(p)
                    propertyAttr = findprop(staticKernelObject, p{i});
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
                                properties(staticKernelObject), p{i})) 
                                obj.(p{i}) = staticKernelObject.(p{i});
                            end
                        end
                    end
                end
                  
            %--------------------------------------------------------------
            % Construct from a parameter structure, if provided. Otherwise
            % construct a default object.
            %--------------------------------------------------------------
            else     
                if nargin == 1 && ~isempty(arg)
                    obj.modelType    = arg.modelType;
                    obj.kernelWidth  = arg.kernelWidth;
                    obj.resolution   = arg.resolution;
                    obj.paramVector  = arg.paramVector;
                end
                            
                switch obj.modelType
                    case 'INVARIANT'
                        if isempty(obj.paramVector)
                            obj.paramVector = ...
                                get_default_invariant_params(obj.kernelWidth);
                        end
                    case 'INVARIANT_GAUSSIAN'
                        if isempty(obj.paramVector)
                            obj.paramVector = ...
                                obj.get_default_invariant_gaussian_params();
                        end
                    case 'INVARIANT_DOG'
                        if isempty(obj.paramVector)
                            obj.paramVector = ...
                                obj.get_default_invariant_dog_params();
                        end
                    otherwise
                        error('Invalid model type.');
                end
            end
        end
        
        %**
        % get_kernel()
        kernel = get_kernel(obj, row, column);
        
        %**
        % get_width()
        function width = get_width(obj)
            width = obj.kernelWidth;
        end

        %**
        % set_parameters()
        function set_parameters(obj, params)
            obj.paramVector = params;
        end
        
        %**
        % get_parameters()
        function params = get_parameters(obj)
            params = obj.paramVector;
        end
        
        %**
        % plot_kernel()
        plot_kernel(obj, row, column, labels);
        
    end
    
    %% ------------------------- Private Methods --------------------------
    methods (Access = 'public') % (Access = 'private')  
        
    end
    
    %% ------------------------- Static Methods ---------------------------
    methods (Static)
   
        %**
        % compute_dog_filter()
        kernel = compute_dog_filter(kernelWidth, params);
        
        %**
        % compute_gaussian_filter()
        kernel = compute_gaussian_filter(kernelWidth, params);

        %**
        % create_default_input_struct()
        function paramStruct = create_empty_param_struct()
             paramStruct                     = struct;
             paramStruct.paramVector         = [];
             paramStruct.modelType           = []; % Any of 'INVARIANT', 'INVARIANT_DOG'
             paramStruct.kernelWidth         = []; % Integer width of discrete kernel.
             paramStruct.resolution          = []; % Points per pixel.
        end
               
        
        %**
        % get_default_invariant_params()
        function paramVector = get_default_invariant_params(kernelWidth)
            paramVector = zeros(kernelWidth);
            paramVector(ceil(kernelWidth/2), ceil(kernelWidth/2)) = 1.0;
        end
        
        %**
        % get_default_invariant_gaussian_params()
        function paramVector = get_default_invariant_gaussian_params()
            % std_x, std_y, and rotation angle (radians).
            paramVector = [1, 1, 0]; 
        end
        
        %**
        % get_default_invariant_dog_params
        function paramVector = get_default_invariant_dog_params()
            paramVector = [ ...
                1, ... % Mixing coefficient for the two Gaussians.
                2, ... % Standard deviation of g1 in the row direction.
                2, ... % Standard deviation of g1 in the column dir
                1, ... % Proportionality constant.
                1, ... % Proportionality constant.
                0.1, ... % Correlation coefficient in the range [-1.0, 1.0].
];
        end
    end
    
end

%********************************** EOF ***********************************
