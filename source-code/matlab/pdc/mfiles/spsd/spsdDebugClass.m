%==========================================================================
% A class to 
% 1. Maintain flags to control debugging-related behavior.
% 2. Contain diagnostic data.
%
%
% DATA
%     debugLevel : The current debug level
%     flags      : 
%     data       : A structure in which arbitrary data products can be
%                  accumulated.
% METHODS
%
%
% NOTES:
%
%     By using the structure FLAGS_BY_LEVEL, the class defines a mapping 
%     from individual integers to sets of flags that allows considerable 
%     flexibility in interpreting "debugLevel".
%
%==========================================================================
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
classdef spsdDebugClass < handle

    %% ---------------------------- Data ----------------------------------    
    properties (Constant)
        MIN_DEBUG_LEVEL = 0;
        MAX_DEBUG_LEVEL = 5;
        FLAGS_BY_LEVEL  = struct(...   % Debug level: [0 1 2 3 4 5]
            'retainInputTimeSeries',         logical( [1 1 1 1 1 1] ), ...
            'retainNonCandidates',           logical( [1 1 1 1 1 1] ), ...
            'retainRejectedCandidates',      logical( [1 1 1 1 1 1] ), ...
            'retainNormalizationParams',     logical( [1 1 1 1 1 1] ), ...
            'useSocRandStreamManager',       logical( [1 1 1 1 1 1] ) ...
            );
    end 
        
    properties (GetAccess = 'public', SetAccess = 'public')
        saveAsStruct = true;
        debugLevel   = 0;
        flags        = struct; % Initialize a 1x1 struct with no fields
    end 
    
    properties (GetAccess = 'public', SetAccess = 'private')
        data         = struct; % Initialize a 1x1 struct with no fields
    end 
    
    
    %% ------------------------- Public Methods ---------------------------
    methods (Access = 'public')
        %**
        % Constructor
        function obj = spsdDebugClass(debugLevel)
            if nargin > 0
                obj.debugLevel = debugLevel;
            end
            obj.set_debug_level(obj.debugLevel);
        end % spsdDebugClass
        
        
        %**
        % Set the value of an existing obj.data field or create a new field.
        function set_data(obj, name, value)
            obj.data.(name) = value;
        end % set_data
        
        
        %**
        % Remove a field from obj.data
        function rm_data(obj, name)
            if isfield(obj.data, name)
                obj.data = rmfield(obj.data, name);
            else
                warning([name, ' is not a valid field']);
            end
        end % rm_data

        
        %**
        % Retrieve a field from obj.data
        function value = get_data(obj, name)
            value = [];
            if isfield(obj.data, name)
                value = obj.data.(name);
            else
                warning([name, ' is not a valid field']);
            end
        end % get_data
        
        
        %**
        % Set flags according to debug level.
        function set_debug_level(obj, level)
            obj.debugLevel = fix(level);
            if obj.debugLevel < obj.MIN_DEBUG_LEVEL
                obj.debugLevel = obj.MIN_DEBUG_LEVEL;
            elseif level > obj.MAX_DEBUG_LEVEL
                obj.debugLevel = obj.MAX_DEBUG_LEVEL;
            end
            
            names = fieldnames(obj.FLAGS_BY_LEVEL);            
            if ~isempty(names)
                for i = 1:length(names)
                    obj.flags.(names{i}) = ...
                        obj.FLAGS_BY_LEVEL.(names{i})(obj.debugLevel + 1);
                end
            end
        end % set_debug_level
        
        %**
        % saveobj
        function obj = saveobj(obj)
            if obj.saveAsStruct             
                s.MIN_DEBUG_LEVEL  = obj.MIN_DEBUG_LEVEL;            
                s.MAX_DEBUG_LEVEL  = obj.MAX_DEBUG_LEVEL;            
                s.FLAGS_BY_LEVEL   = obj.FLAGS_BY_LEVEL;            
                s.saveAsStruct     = obj.saveAsStruct;
                s.debugLevel       = obj.debugLevel;   
                s.flags            = obj.flags;   
                s.data             = obj.data;   
                
                obj = s;
            end
        end

    end % public methods
    
    %% ------------------------ Static Methods ----------------------------
    methods (Static)
        
        %**
        % loadobj
        function obj = loadobj(obj)
            if isstruct(obj)
                newObj = spsdDebugClass();
                
                newObj.debugLevel   = obj.debugLevel;
                newObj.flags        = obj.flags;
                newObj.data         = obj.data;
 
                obj = newObj;
            end
        end

    end % static methods
    
end

