classdef motionModelClass < handle
%************************************************************************** 
% classdef motionModelClass < handle
%************************************************************************** 
% This class is simply a container for a motionPolyStruct. Being a handle
% class, a single motionModelClass object can be referenced by many
% apertureModelClass objects. This is advantageous, as we plan to update
% the motion model in an iterative process. 
%
% Additionally, we may wish to use the listening/signaling mechanisms to
% trigger automatic updating of aperture models when the motion model is
% updated.  
%
%
% METHODS:
%
%     motionModelClass()
%
%         Constructor. May be called in any of the following ways:
%
%             motionModelClass()
%             motionModelClass( motionModelObject )
%             motionModelClass( motionPolyStruct )
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
    
    properties (GetAccess = 'public', SetAccess = 'private')
        motionPolyStruct    = []; 
    end
    
    %% ------------------------- Public Methods ---------------------------
    methods 
        
        %**
        % Constructor
        %   If no argument is passed a default object is created. If an
        %   argument is passed it may contain any of the following:
        %   1) An empty cell array (constructs a defalt object).
        %   2) A motionModelClass object (copy constructor).
        %   3) A motionPolyStruct.
        function obj = motionModelClass( arg )
            %--------------------------------------------------------------
            % Default constructor
            %--------------------------------------------------------------
            if nargin == 0 || isempty(arg)
            
            %--------------------------------------------------------------
            % Copy constructor
            %--------------------------------------------------------------
            elseif nargin == 1 && isa(arg, 'motionModelClass')
                motionModelObject = arg;
                p = properties('motionModelClass'); % Public properties
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
            % Construct from a PRF model input struct.
            %--------------------------------------------------------------
            else
                obj.motionPolyStruct = arg;
            end
        end
        
        %**
        % set_motion_poly_struct()
        function set_motion_poly_struct(obj, motionPolyStruct)
            obj.motionPolyStruct = motionPolyStruct;
            obj.notify('stateChange');
        end

        %**
        % get_gap_indicators()
        function gapIndicators = get_gap_indicators(obj)
            gapIndicators = ...
                colvec(~[obj.motionPolyStruct.rowPolyStatus] | ...
                       ~[obj.motionPolyStruct.colPolyStatus]);
        end
        
        %**
        % get_motion_polynomials()
        function motionPolyStruct = get_motion_polynomials(obj)
            motionPolyStruct = obj.motionPolyStruct;
        end        
        
    end
    

    %% ----------------------------- Events -------------------------------
    events
        stateChange
    end
    
end

%********************************** EOF ***********************************
