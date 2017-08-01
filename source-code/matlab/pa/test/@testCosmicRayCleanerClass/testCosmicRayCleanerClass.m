classdef testCosmicRayCleanerClass < cosmicRayCleanerClass
%************************************************************************** 
% classdef cosmicRaySimulationTesterClass < cosmicRayCleanerClass
%************************************************************************** 
% Perform unit tests and integrated tests of cosmicRayCleanerClass. 
%
% METHODS:
%
%     cosmicRayTesterClass(  )
%
% PROPERTIES:
%
%
% USAGE:
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
        testSourceDir  = '.';
        testResultsDir = '.';
        cadenceTimes   = struct([]);
    end
    
    %% ------------------------- Public Methods ---------------------------
    methods 
        
%         %**
%         % Constructor
%         function obj = testCosmicRayCleanerClass( varargin )
%              obj = obj@cosmicRayCleanerClass( varargin );   
%         end        
        %**
        % Constructor
        %
        % paInputStruct must contain at least one valid target.
        function obj = testCosmicRayCleanerClass( paInputStruct, testSourceDir, testResultsDir )
             obj = obj@cosmicRayCleanerClass( paInputStruct, testSourceDir );   
             
             obj.cadenceTimes = paInputStruct.cadenceTimes;
             
             if nargin > 1
                 obj.testSourceDir = testSourceDir;
             end
             
             if nargin > 2
                 obj.testResultsDir = testResultsDir;
             end
        end        

        %**
        % clean_target_83()
        cleanTargetStruct = clean_target_83(obj, targetIdx);
        
        %**
        % do_all_unit_tests
        function resultStruct = do_all_unit_tests(obj)
            
        end % test
        

        %------------------------------------------------------------------
        % Individual method tests.
        %------------------------------------------------------------------
        resultsStruct = test_set_exclude_cadences( obj );
        resultsStruct = test_clean_target( obj );
        resultsStruct = test_get_corrected_flux_and_event_indicator_matrices( obj );
        resultsStruct = test_clean( obj );
        resultsStruct = test_reconstruct_result_from_event_array( obj );
        resultsStruct = test_initialize_target_array( obj );
        resultsStruct = test_fill_missing_target_ra_dec( obj );
        resultsStruct = test_predict_arburg( obj )
        resultsStruct = test_derive_motion_time_series_matrices( obj );
        resultsStruct = test_derive_focus_time_series_matrix( obj );
        resultsStruct = test_get_conditioned_time_series( obj );
        resultsStruct = test_identify_harmonics( obj );
        resultsStruct = test_build_design_matrix( obj );
        resultsStruct = test_initialize_debug_struct( obj );
        resultsStruct = test_fit_by_svd( obj );
        resultsStruct = test_linear_gap_fill( obj );
        resultsStruct = test_inputs_from_pa_data_object( obj );
        resultsStruct = test_read_motion_poly_data_from_files( obj );
        resultsStruct = test_inputs_from_pa_input_struct( obj );
        resultsStruct = test_get_config_struct_fields_and_bounds( obj );
        resultsStruct = test_assemble_background_targets( obj );
        resultsStruct = test_disassemble_background_targets( obj );
        resultsStruct = test_create_empty_input_struct( obj );
        resultsStruct = test_get_default_cosmic_ray_config_struct( obj );
        resultsStruct = test_get_default_gap_fill_config_struct( obj );
        resultsStruct = test_get_default_harmonic_id_config_struct( obj );
        resultsStruct = test_get_default_param_struct( obj );

    end
    
    %% ------------------------- Private Methods --------------------------
    methods (Access = 'private')
        
    end
    
    
    %% ------------------------- Static Methods ---------------------------
    methods (Static)
        
        %**
        % Test construction from a cosmicRayInputStruct.
        function resultStruct = test_constructor()

            % Test construction when motionPolyStruct is empty
        end
        %**
        % test method reconstruct_result_from_event_array()
        %resultStruct = test_reconstruct_result_from_event_array(paInputStruct, plotResults);
 
        %**
        % test
        resultStruct = test_segment_sizes();
        
        %**
        % 
        function resultStruct = test_performance(inputStruct)
        end
        
    end  
    
    
end


