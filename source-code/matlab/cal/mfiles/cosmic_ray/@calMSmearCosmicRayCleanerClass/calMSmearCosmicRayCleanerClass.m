classdef calMSmearCosmicRayCleanerClass < calCosmicRayCleanerClass
%************************************************************************** 
% classdef calMSmearCosmicRayCleanerClass < cosmicRayCleanerClass
%************************************************************************** 
% A class to clean cosmic ray signal from masked smear pixels in CAL.
%
% METHODS
%
%     calMSmearCosmicRayCleanerClass()
%
%         Constructor. May be called in any of the following ways:
%
%             calMSmearCosmicRayCleanerClass()
%             calMSmearCosmicRayCleanerClass( calObject )
%             calMSmearCosmicRayCleanerClass( calInputStruct )
%
%     get_corrected_flux_and_event_indicator_matrices()
%
%         Returns matrices used in clean_target_cosmic_rays.m and
%         correct_smear_pix_for_cosmic_rays.m.
%
%
% USAGE
%     Within the pipeline:
%
%     smearCosmicRayObj = ...
%         calMSmearCosmicRayCleanerClass( calObject, calIntermediateStruct);
%     [mSmearPixelsCosmicRayCorrected, cosmicRayEventsIndicators] = ...
%         smearCosmicRayObj.get_corrected_flux_and_event_indicator_matrices();
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
        MASKED_ROW   = 1;
        NEIGHBORHOOD = [0 1; 0 -1]; % (row, col) offsets of neighbors.
    end
        
    %% ------------------------- Public Methods ---------------------------
    methods 
        
        %**
        % Constructor
        %   varargin may contain ...
        %   1) An empty cell array.
        %   2) A calClass object or calDataStruct
        function obj = calMSmearCosmicRayCleanerClass( varargin )
            obj = obj@calCosmicRayCleanerClass( varargin{:}, ...
                @calMSmearCosmicRayCleanerClass.assemble_cosmic_ray_input_struct);
        end
        
        
        %**
        % get_corrected_flux_and_event_indicator_matrices()
        [correctedFluxMat, eventIndicatorMat] ...
            = get_corrected_flux_and_event_indicator_matrices(obj, returnSparse);

    end
        
    
    %% ------------------------- Static Methods ---------------------------
    methods (Static)
                
        %**
        % assemble_cosmic_ray_input_struct()
        inputStruct = ...
            assemble_cosmic_ray_input_struct(calObject, ...
                                             calIntermediateStruct);
                                
    end  
     
end

%********************************** EOF ***********************************
