classdef socRandStreamManagerClass < handle
%************************************************************************** 
% classdef socRandStreamManagerClass < handle
%************************************************************************** 
% Initializes and maintains a set of random streams for use in the SOC
% pipeline. This class is a response to KSOC-1623, which states: 
%
%     "This ticket will resolve this issue by having each CSCI set a unique
%     randstream for each target using Matlab 2010 features. The randstream
%     will be set to the keplerID + CSCI index." 
%
% Future versions may maintain separate RandStream objects for each
% (target, function) pair, as suggested on KSOC-1623. However, any code
% using this version of socRandStreamManagerClass should remain valid.
%
% METHODS:
%
%     socRandStreamManagerClass( csciName, keplerIds, paramStruct)
%
%         Initialize the various RandStreams according to either default
%         parameters or the parameters specified in paramStruct.
%
%         csciName      : A string containing the acronym of the current 
%                         CSCI (case is ignored). (e.g., 'PDC')
%         keplerIds     : An array of Kepelr IDs for which to create and
%                         maintain RandStream objects.
%         paramStruct   : An optional structure containing the following
%                         fields: 
%
%                             generatorType
%                             randnAlg
%                             antithetic 
%                             fullPrecision
%                             seedOffset    : Added to seed values during
%                                             construction and in reset().
%
%                         See get_default_param_struct(). 
%
%
%     get_stream(keplerId)
%
%         Return the RandStream specified by the arguments. 
%
%         keplerId : Specifies the target-specific RandStream to return.
%
%
%     reset(kepIdArr, seeds)
%
%         Reset the RandStreams for the specified targets. 
%
%         kepIdArr : An array of Kepler IDs specifying the targets whose
%                    RandStreams should be reset.
%         seeds    : An optional array of seed values, one for each
%                    keplerID. 
%
%     set_default(keplerId)
%
%         Set the default RandStream to the stream specified by keplerId.
%
%     restore_default()
%
%         Restores the original state of the default stream. That is, its
%         state before the first call to set_default() since the last call
%         to restore_default().         
%
%     get_default_param_struct()  (Static Method)
%
%         Returns a default structure that can be modified and passed to 
%         the constructor. Note that this is a static method and can be
%         called before instantiating a socRandStreamManagerClass object. 
%         For example:
%
%         >> paramStruct = socRandStreamManagerClass.get_default_param_struct()
%         >> paramStruct.seedOffset = 17
%         >> srs = socRandStreamManagerClass('PDC', ...
%             [inputsStruct.targetDataStruct.keplerId], paramStruct)
%
%
% USAGE:
%     Typical usage is shown in the example below, where a set of targets
%     is processed using independent random streams.
%     
%     Example:
%
%         paramStruct = ...
%             socRandStreamManagerClass.get_default_param_struct();
%         srsm = socRandStreamManagerClass('PDC', kepIdArray, paramStruct);
%         for i = 1:length(kepIdArray)
%             srsm.set_default( kepIdArray(i) );
%                    :
%             PROCESS TARGET
%                    :
%         end
%         srsm.restore_default();
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
        CSCI_LIST = { 'PDQ'; ...
                      'CAL'; ...
                      'PA' ; ...
                      'PDC'; ...
                      'TPS'; ...
                      'DV' ; ...
                      'PPA'; ...
                      'FC' ; ...
                      'GAR'; ...
                      'TAD'  ...
                    };
    end

    properties (GetAccess = 'public', SetAccess = 'protected')
        generatorType = 'mt19937ar';  % Pseudorandom number generator.
        randnAlg      = 'Polar';      % Algorithm for use with randn().    
        fullPrecision = true;         % Return full-precision values?
        antithetic    = false;        % Return 1 - value?
        seedOffset    = 0;            % Add to seed value when initializing 
                                      %   RandStream objects.
                                      
        % Temporary storage for the default RandStream handle
        defaultStreamTemp = [];
        
        % Target-specific RandStreams
        seeds             = [];       % The current seed values. 
        csciIndex         = 0;        % The CSCI index.
        keplerIdArray     = [];       % A list of Kepler IDs for which to
                                      % maintain RandStream objects.
        targetStreamArray = cell({}); % A cell array of RandStream objects.
        
        matlabRelease = version('-release'); % RandStream optional argument have changed for 2014b!
    end
    
    %% ------------------------- Public Methods ---------------------------
    methods 
        
        %**
        % Constructor
        function obj = socRandStreamManagerClass(csciName, keplerIds, ...
                                                 paramStruct)
            if nargin > 2
                obj.read_param_struct(paramStruct);
            end
            
            if nargin > 0 && isstr(csciName)
                ind = find(strcmpi(csciName, obj.CSCI_LIST)); % Ignore case.
                if ~isempty(ind)
                    obj.csciIndex = ind(1);
                end
            end
            
            if nargin > 1 && isnumeric(keplerIds)
                
                obj.keplerIdArray = unique(keplerIds( obj.is_valid_kepler_id(keplerIds) ));
                if ~all(ismember(keplerIds, obj.keplerIdArray))
                    warning(['Input array contains invalid Kepler IDs. ' ...
                        'These will be excluded.\n']);
                end
                
                N = length(obj.keplerIdArray);
                obj.seeds = mod(obj.csciIndex + 10*obj.keplerIdArray + obj.seedOffset, 2^32); % 0 <= valid_seed < 2^32
                for n = 1:N
                    obj.targetStreamArray{n} = obj.new_rand_stream(obj.seeds(n));
                end
            end
            
        end        
        
        
        %**
        % get_stream()
        function s = get_stream(obj, keplerId)
                        
            if nargin < 2
                error(['Kepler ID required when specifying a target stream.\n']); 
            end

            if ~ismember(keplerId, obj.keplerIdArray)
                error(sprintf(['%d does not index a valid RandStream.\n'], ...
                    keplerId) );
            end

            s = obj.targetStreamArray{obj.kepler_id_to_ind(keplerId)}; 
            
        end
        
        
        %**
        % set_default()
        function set_default(obj, keplerId)
                            
            if nargin < 2
                error(['Kepler ID required when specifying a target stream.\n']); 
            end

            if ~ismember(keplerId, obj.keplerIdArray)
                error(sprintf(['%d does not index a valid RandStream.\n'], ...
                    keplerId) );
            end

            % An optional argument for RandStream has changed for 2014b!
            switch obj.matlabRelease
                case '2010b'
                    oldDefaultRandStream = RandStream.setDefaultStream( ...
                        obj.targetStreamArray{obj.kepler_id_to_ind(keplerId)});
                case '2014b'
                    oldDefaultRandStream = RandStream.setGlobalStream( ...
                        obj.targetStreamArray{obj.kepler_id_to_ind(keplerId)});
                otherwise
                    error('Unknown Matlab release');
            end

            if isempty(obj.defaultStreamTemp)
                obj.defaultStreamTemp = oldDefaultRandStream;
            end
   
        end

        
        %**
        % restore_default()
        function restore_default(obj)
            if ~isempty(obj.defaultStreamTemp)
                % An optional argument for RandStream has changed for 2014b!
                switch obj.matlabRelease
                    case '2010b'
                        RandStream.setDefaultStream(obj.defaultStreamTemp);
                    case '2014b'
                        RandStream.setGlobalStream(obj.defaultStreamTemp);
                    otherwise
                        erorr('Unknown Matlab  release');
            end
                    
                        obj.defaultStreamTemp = [];
            end
        end
        
        
        %**
        % reset()
        function reset(obj, kepIdArr, seedArr)
            
            if nargin < 2 
                kepIdArr = obj.keplerIdArray;
            end
                       
            resetIndices = obj.kepler_id_to_ind(kepIdArr);
            
            if nargin > 2
                if numel(seedArr) == numel(kepIdArr)
                    seedIndices = find(ismember(kepIdArr, obj.keplerIdArray));
                    for n = 1:length(resetIndices)
                        obj.targetStreamArray{ ...
                            resetIndices(n)}.reset(seedArr(seedIndices(n)));
                        obj.seeds(n) = seedArr(seedIndices(n));
                    end
                else
                    warning(['Number of seeds does not equal the number' ...
                            ' of Kepler IDs submitted. Not resetting.\n']);
                end
            else
                for idx = resetIndices
                    obj.targetStreamArray{idx}.reset();
                end
            end
        end
        
    end
    
    %% ------------------------- Private Methods --------------------------
    methods (Access = 'private')
        %**
        % Return the target stream array indices corresponding to the given
        % Kepler IDs. Returns indices = [] if no elements of keplerIdList
        % are in obj.keplerIdArray. 
        function indices = kepler_id_to_ind(obj, keplerIdList)
           indices = find(ismember(obj.keplerIdArray, keplerIdList));
        end
        
        %**
        % Create a new random stream object.
        function s = new_rand_stream(obj, seed)
            % An optional argument for RandStream has changed for 2014b!
            switch obj.matlabRelease
                case '2010b'
                    s = RandStream(obj.generatorType, 'Seed', seed, ...
                        'RandnAlg', obj.randnAlg);
                case '2014b'
                    s = RandStream(obj.generatorType, 'Seed', seed, ...
                        'NormalTransform', obj.randnAlg);
                otherwise
                    error('Unknown Matlab release');
            end
            s.FullPrecision = obj.fullPrecision;
            s.Antithetic = obj.antithetic;
        end
        
        %**
        % Read valid fields from a parameter struct and set corresponding
        % properties.
        function read_param_struct(obj, s)
            if isstruct(s)
                if  isfield(s, 'generatorType')
                    obj.generatorType = s.generatorType;
                end
                if  isfield(s, 'randnAlg')
                    obj.randnAlg = s.randnAlg;
                end
                if  isfield(s, 'antithetic')
                    obj.antithetic = s.antithetic;
                end
                if  isfield(s, 'fullPrecision')
                    obj.fullPrecision = s.fullPrecision;
                end
                if  isfield(s, 'seedOffset')
                    obj.seedOffset = s.seedOffset;
                end
            end
        end
                
    end
    
    
    %% ------------------------- Static Methods ---------------------------
    methods (Static)
        %**
        % Return a logical array indicating validity. Valid Kepler IDs are
        % taken to be integers in the range [1,1e9).
        function valid = is_valid_kepler_id(x)
           valid = [];
           if ~isempty(x) 
               valid = is_valid_id(x);
           end
        end
         
        %**
        % Useful for obtaining a valid struct that can be modified and
        % passed to the constructor.
        function paramStruct = get_default_param_struct()
            paramStruct = ...
                struct( ...
                    'generatorType', 'mt19937ar', ...
                    'randnAlg', 'Polar', ...
                    'antithetic', false, ...
                    'fullPrecision', true, ... 
                    'seedOffset', 0 ...
                );
        end
    end  
    
    
end


