classdef paCosmicRayCleanerClass < cosmicRayCleanerClass
%************************************************************************** 
% classdef paCosmicRayCleanerClass < cosmicRayCleanerClass
%************************************************************************** 
% A subclass of cosmicRayCleanerClass used for PA cosmic ray cleaning. This
% class transforms inputs into the format required by the parent class'
% constructor.
%
%
% METHODS:
%
%     paCosmicRayCleanerClass()
%
%         Constructor. May be called in any of the following ways:
%
%             paCosmicRayCleanerClass()
%             paCosmicRayCleanerClass( cosmicRayCleanerObject )
%             paCosmicRayCleanerClass( paInputStruct, motionPolyStruct )
%             paCosmicRayCleanerClass( paDataObject )
%             paCosmicRayCleanerClass( cosmicRayInputStruct )
%
%         See cosmicRayCleanerClass for details of cosmicRayInputStruct.
%
%
%     get_corrected_flux_and_event_indicator_matrices()
%
%         Returns matrices used in clean_target_cosmic_rays.m and
%         clean_background_cosmic_rays.m. Process all targets if they
%         haven't already been processed.  
%
%     Inherited from cosmicRayCleanerClass:
%         clean()
%         set_exclude_cadences()
%
%
% PROPERTIES:
%
%     targetType      : Either 'background' or 'stellar'
%         
%     cadenceType     : 'LONG' or 'SHORT'.
%         
%     ancillaryLabels : Labels for ancillary time series.  
%
%
% USAGE:
%     An example of usage from paDataClass.clean_target_cosmic_rays():
%         
%     cosmicRayCleanerObject = paCosmicRayCleanerClass(paDataObject);
%     if ~paDataObject.cosmicRayConfigurationStruct.cleanZeroCrossingCadencesEnabled
%         cosmicRayCleanerObject.set_exclude_cadences( ...
%             reactionWheelZeroCrossingIndicators);
%     end
%     [cosmicRayCorrectedValues, cosmicRayEventsIndicators] = ...
%         cosmicRayCleanerObject.get_corrected_flux_and_event_indicator_matrices;
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
    properties (GetAccess = 'public', SetAccess = 'public')
        
        targetType       = '';           % Either 'background' or 'stellar'
        
        cadenceType      = '';           % 'LONG' or 'SHORT'.
        
        ancillaryLabels  = {};           % Labels for ancillary time series.          
    end
    
    %% ------------------------- Public Methods ---------------------------
    methods 
        
        %**
        % Constructor
        %   varargin may contain any of the following:
        %   1) An empty cell array.
        %   2) A cosmicRayCleanerClass object.
        %   3) A paCosmicRayCleanerClass object.
        %   4) A paInputStruct and a motion polynomial struct array.
        %   5) A paDataObject.
        %   6) A cosmic ray cleaner input struct.
        function obj = paCosmicRayCleanerClass( varargin )

            % Get the input for the base class' constructor.
            if nargin == 0
                inputStruct = struct([]);
            else
                if isa(varargin{1}, 'cosmicRayCleanerClass') || isempty(varargin{1})
                    inputStruct = varargin{1};
                else 
                    inputStruct = paCosmicRayCleanerClass.inputs_from_pa_data_object(varargin{:});
                end
            end

            obj = obj@cosmicRayCleanerClass( inputStruct );
            
            % Populate subclass-specific properties.
            obj.targetType      = inputStruct.targetType;
            obj.cadenceType     = inputStruct.cadenceType;            
            obj.ancillaryLabels = inputStruct.ancillaryLabels;            
            
        end % paCosmicRayCleanerClass
        
              
        %**
        % get_corrected_flux_and_event_indicator_matrices()
        [correctedFluxMat, eventIndicatorMat] ...
            = get_corrected_flux_and_event_indicator_matrices(obj);
        
        %**
        % set_thruster_activity_exclude_cadences()
        set_thruster_activity_exclude_cadences( obj, thrusterFiringEvents, ...
            halfWindowSize);
        
    end % public methods
    
    %% ------------------------- Private Methods --------------------------
    methods (Access = 'public') % (Access = 'private')
        
    end % private methods
    
    
    %% ------------------------- Static Methods ---------------------------
    methods (Static)
        
        %**
        % inputs_from_pa_data_object()
        inputStruct = inputs_from_pa_data_object(paDataObject, motionPolyStruct);
        
        %**
        % read_motion_poly_data_from_files()
        [motionPolyStruct, motionPolyGapIndicators] ...
            = read_motion_poly_data_from_files( taskDir, gaps );

        %**
        % Return a struct compatible with the existing pipeline input
        % validation method.
        fieldsAndBounds = get_config_struct_fields_and_bounds();
        
        %**
        % assemble_background_targets()
        targetArray = assemble_background_targets(pixelArray);
        
        %**
        % disassemble_background_targets()
        function pixelArray = disassemble_background_targets(targetArray)
            unorderedPixelArray = [targetArray.pixelDataStruct];
            pixelArray          = unorderedPixelArray;
            for i = 1:numel(unorderedPixelArray)
                pixelArray(unorderedPixelArray(i).index) ...
                    = unorderedPixelArray(i);
            end
            pixelArray = rmfield(pixelArray, 'index');
        end
                                       
        %**
        % derive_motion_time_series_matrices()
        [rowPositionMat, colPositionMat] = derive_motion_time_series_matrices(targetArray, motionPolyStruct);
        
        %**
        % derive_focus_time_series_matrix()
        focusMat = derive_focus_time_series_matrix(targetArray, motionPolyStruct);
        
    end % static methods
     
end

%********************************** EOF ***********************************
