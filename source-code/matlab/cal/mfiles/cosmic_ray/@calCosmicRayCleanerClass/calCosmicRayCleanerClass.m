classdef calCosmicRayCleanerClass < cosmicRayCleanerClass
%************************************************************************** 
% classdef calCosmicRayCleanerClass < cosmicRayCleanerClass
%************************************************************************** 
% An abstract base class for the classes in CAL that perform cosmic ray 
% cleaning of collateral pixels.
%
%
% METHODS:
%
%     calCosmicRayCleanerClass()
%
%         Constructor. May be called in any of the following ways:
%
%             calCosmicRayCleanerClass()
%             calCosmicRayCleanerClass( calObject,      function_handle)
%             calCosmicRayCleanerClass( calInputStruct, function_handle)
%             calCosmicRayCleanerClass( calObject,      calIntermediateStruct, function_handle)
%             calCosmicRayCleanerClass( calInputStruct, calIntermediateStruct, function_handle)
%
%        where 'function_handle' points to a function that converts the
%        other arguments to a valid cosmicRayCleanerClass input struct.
%
% USAGE:
%     Since this is an abstract class, it can't be instantiated. Instead it
%     is used as a base for the following concrete classes:
%
%         calBlackCosmicRayCleanerClass 
%         calMSmearCosmicRayCleanerClass 
%         calVSmearCosmicRayCleanerClass 
%         
% NOTES:
%     Long cadence collateral data consist of
%     1) Each column for a binned subset of rows in the Masked Smear region. 
%     2) Each column for a binned subset of rows in the Virtual Smear region 
%     3) Each row for a binned subset of columns in the Trailing Black
%        regions, for each module/output regardless of target distribution. 
% 
%     Short cadence collateral data consist of
%     1)	Short Cadence Target Black 
%     2)	Short Cadence Target Masked Pixels 
%     3)	Short Cadence Target Smear Pixels
%     4)	Short Cadence masked/black overlap Pixels 
%     5)	Short Cadence smear/black overlap Pixels
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
    properties (GetAccess = 'public', SetAccess = 'public')
        nCcdRows    = [];
        nCcdColumns = [];        
        cadenceType = ''; % 'LONG' or 'SHORT'.
    end
    
    %% ------------------------- Public Methods ---------------------------    
    methods 
        
        %**
        % Constructor
        %   varargin may contain ...
        %   1) An empty cell array.
        %   2) A calClass object or calDataStruct and a function handle
        %   3) A calClass object or calDataStruct, a calIntermediateStruct,
        %      and a function handle
        function obj = calCosmicRayCleanerClass( varargin )

            switch nargin
                case 0
                    inputStruct = struct([]);
                case 2
                    if (   isa(varargin{1}, 'calClass')   ...
                        || isa(varargin{1}, 'struct'  ) ) ...
                        && isa(varargin{2}, 'function_handle')
                   
                        calObject             = struct(varargin{1});
                        fHandle               = varargin{2};
                    else
                        error('Invalid constructor arguments');
                    end
                    inputStruct = fHandle(calObject);
                case 3
                    if (   isa(varargin{1}, 'calClass')   ...
                        || isa(varargin{1}, 'struct'  ) ) ...
                        && isa(varargin{2}, 'struct')     ...
                        && isa(varargin{3}, 'function_handle')
                   
                        calObject             = struct(varargin{1});
                        calIntermediateStruct = varargin{2};
                        fHandle               = varargin{3};
                    else
                        error('Invalid constructor arguments');
                    end
                    inputStruct = fHandle(calObject,calIntermediateStruct);
                otherwise
                    error('Invalid constructor arguments');
            end

            obj = obj@cosmicRayCleanerClass( inputStruct );
            
            % Populate subclass-specific properties.
            if ~isempty(inputStruct)
                obj.nCcdRows        = inputStruct.nCcdRows;            
                obj.nCcdColumns     = inputStruct.nCcdColumns;            
                obj.cadenceType     = inputStruct.cadenceType;            
            end
        end % calCosmicRayCleanerClass
        
     end
    
     methods (Abstract)  
        
        %**
        % get_corrected_flux_and_event_indicator_matrices()
        [correctedFluxMat, eventIndicatorMat] ...
            = get_corrected_flux_and_event_indicator_matrices(obj);
        
    end    
    
    %% ------------------------- Static Methods ---------------------------
    methods (Static)
        
        %**
        % get_config_struct_fields_and_bounds()
        %
        % Return a struct compatible with the existing pipeline input
        % validation method.
        fieldsAndBounds = get_config_struct_fields_and_bounds();
        
        %**
        % assemble_background_targets()
        targetArray = assemble_collateral_targets(pixelArray, neighborhood);
        
        %**
        % disassemble_collateral_targets()
        pixelArray = disassemble_collateral_targets(targetArray);
        
        %**
        % initialize_cosmic_ray_input_struct()
        inputStruct = initialize_cosmic_ray_input_struct( calObject )
    end
%     
%     methods (Abstract, Static)
%                 
%         %**
%         % assemble_cosmic_ray_input_struct()
%         inputStruct = assemble_cosmic_ray_input_struct( ...
%             calObject, calIntermediateStruct);
%         
%     end  
     
end

%********************************** EOF ***********************************
