classdef dynamicKernelClass < handle
%************************************************************************** 
% classdef dynamicKernelClass < handle
%************************************************************************** 
% Given a row, column position, and possibly a cadence, return an
% appropriate kernel to modify the static PRF.
%
%
% METHODS:
%
%     dynamicKernelClass()
%
%         Constructor. May be called in any of the following ways:
%
%             dynamicKernelClass()
%             dynamicKernelClass( dynamicKernelObject )
%             dynamicKernelClass( paramStruct )
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
        modelType    = '';
        resolution   = []; % Samples per pixel.
        kernel       = [];
        cadenceTimes = [];
    end
    
    %% ------------------------- Public Methods ---------------------------
    methods 
        
        %**
        % Constructor
        %   If no argument is passed a default object is created. If an
        %   argument is passed it may contain any of the following:
        %   1) An empty cell array (constructs a defalt object).
        %   2) A dynamicKernelClass object (copy constructor).
        %   3) A paramStruct.
        function obj = dynamicKernelClass( arg )
            %--------------------------------------------------------------
            % Default constructor
            %--------------------------------------------------------------
            if nargin == 0 || isempty(arg)
            
            %--------------------------------------------------------------
            % Copy constructor
            %--------------------------------------------------------------
            elseif nargin == 1 && isa(arg, 'dynamicKernelClass')
                motionModelObject = arg;
                p = properties('dynamicKernelClass'); % Public properties
                for i = 1:numel(p)
                    propertyAttr = findprop(motionModelObject, p{i});
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
                                properties(motionModelObject), p{i})) 
                                obj.(p{i}) = motionModelObject.(p{i});
                            end
                        end
                    end
                end
                  
            %--------------------------------------------------------------
            % Construct from parameter struct.
            %--------------------------------------------------------------
            else
                obj.modelType    = arg.modelType;
                obj.resolution   = arg.resolution;
                obj.cadenceTimes = arg.cadenceTimes;
                
                switch obj.modelType
                    case 'SPATIALLY_INVARIANT'
                        if isempty(cadenceTimes)                  % Static
                            obj.kernel = zeros(obj.kernelWidth);
                        else                                      % Dynamic
                            obj.kernel = zeros(obj.kernelWidth, ...
                                               obj.kernelWidth, ...
                                               length(obj.cadenceTimes));
                        end
                    otherwise
                        error('Invalid model type.');
                end
            end
        end
        
        %**
        % get_kernel()
        kernel = get_kernel(obj, rows, columns);

    end
    
    
    %% ------------------------- Static Methods ---------------------------
    methods (Static)
   
        %**
        % create_default_input_struct()
        function paramStruct = create_default_input_struct()
             paramStruct                     = struct;
             paramStruct.modelType           = 'SPATIALLY_INVARIANT';  
             paramStruct.kernelWidth         = 11;
             paramStruct.resolution          = 4; % Points per pixel.
             paramStruct.cadenceTimes        = [];
             paramStruct.debugLevel          = 0;
        end
    end
    
end

%********************************** EOF ***********************************
