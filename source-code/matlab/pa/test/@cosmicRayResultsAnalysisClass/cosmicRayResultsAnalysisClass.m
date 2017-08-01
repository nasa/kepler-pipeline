classdef cosmicRayResultsAnalysisClass < paCosmicRayCleanerClass
%************************************************************************** 
% classdef cosmicRayResultsAnalysisClass < cosmicRayCleanerClass
%************************************************************************** 
% Summarize and visualize cosmic ray cleaning results. 
%
% METHODS:
%
%     cosmicRayResultsAnalysisClass( )
%         The constructor may be called in any of the following ways:
%             (1) cosmicRayResultsAnalysisClass()
%             (2) cosmicRayResultsAnalysisClass( cosmicRayCleanerClass ) <<< implement in base class
%             (3) cosmicRayResultsAnalysisClass( paDataStruct )
%             (4) cosmicRayResultsAnalysisClass( paDataStruct, motionPolyStruct )
%             (5) cosmicRayResultsAnalysisClass( paDataStruct, motionPolyStruct, 
%                                                cosmicRayEvents, convertEventsToZeroBased)
%
%         Note that in the 4th and 5th calling conventions, motionPolyStruct 
%         may be empty.
%
%     plot_pixels()
%         Plot cleaning results for each pixel in the specified target.
%
%     compare_target_flux_results()
%         A static function used to compare results from different versions
%         or configurations of cosmic ray cleaner objects. This is intended
%         primarily as a V&V tool.
%
%     plot_pixel_results()
%         This function is obsolete. It is similar to plot_pixels(), but
%         was designed to facilitate work with simulated data. 
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
        cadenceTimes              = [];
        zeroCrossingIndicators    = [];
        argabrighteningIndicators = [];
        thrusterFiringIndicators  = []; % K2 only.
    end
    
    %% ------------------------- Public Methods ---------------------------
    methods 
        
        %**
        % Constructor
        function obj = cosmicRayResultsAnalysisClass( varargin )
            cadenceTimesAvailable = true; % Assume they'll be available 
                                          % unless we find otherwise.
            switch nargin
                case 0
                    crcArgs = {};
                case 1
                    if isa(varargin{1}, 'cosmicRayCleanerClass')
                        crcArgs = varargin;
                        cadenceTimesAvailable = false;
                    else % Must be a paDataStruct
                        crcArgs = {varargin{1}, ''};      
                    end
                case 2
                    crcArgs = varargin;
                case 4
                    crcArgs = varargin(1:2);
                    cosmicRayEvents = varargin{3};
                    convertEventsToZeroBased = varargin{4};
                otherwise
                    error('Invalid constructor arguments');
            end
                
            obj = obj@paCosmicRayCleanerClass( crcArgs{:} );
                       
            % If a cosmicRayCleanerClass object was passed directly,
            % cadence timestamps are not available.
            if cadenceTimesAvailable
                obj.cadenceTimes = varargin{1}.cadenceTimes;
            end
            
            % If a cosmic ray event array was passed, we use it to
            % reconstruct the cosmicRayCleanerClass object.
            if exist('cosmicRayEvents', 'var')
                obj.reconstruct_result_from_event_array( cosmicRayEvents, ...
                    obj.cadenceTimes.midTimestamps, convertEventsToZeroBased );
            end           
        end        
                
        
        %**
        % plot_pixel_results
        plot_pixel_results(obj, targetIndex);

        %**
        % plot_pixels
        plot_pixels(obj, targetIndex);

        
        %**
        % plot_image_motion
        plot_image_motion(obj, targetIndex, markGaps, markZeroCrossings, setLineWidth);
        
        %**
        % plot_target_results
        plot_target_results(obj, h, targetIndex);

        
        %**
        % set_zero_crossing_indicators
        function set_zero_crossing_indicators(obj, zeroCrossingIndicators)
           obj.zeroCrossingIndicators = zeroCrossingIndicators;
        end

        %**
        % set_argabrightening_indicators
        function set_argabrightening_indicators(obj, argabrighteningIndicators)
           obj.argabrighteningIndicators = argabrighteningIndicators;
        end
        
        %**
        % set_thruster_firing_indicators
        function set_thruster_firing_indicators(obj, thrusterFiringIndicators)
           obj.thrusterFiringIndicators = thrusterFiringIndicators;
        end
        
    end
    
    %% ------------------------- Private Methods --------------------------
    methods (Access = 'private')
        
    end
    
    
    %% ------------------------- Static Methods ---------------------------
    methods (Static)
        p = mark_cadences(h, cadences, color, alpha);
        p = mark_cadences_with_lines(h, cadences, color, style, width);
        h = format_current_figure(baseLineWidth, lineWidthDelta, dataLabels);
        
        %**
        % compare_target_flux_results()
        %
        % Can be called in any of the following ways:
        %   compare_results( inputsStruct, cosmicRayEvents1, cosmicRayEvents2 )
        %   compare_results( cosmicRayResultsAnalysisObject1, cosmicRayResultsAnalysisObject2 )
        %   compare_results( cosmicRayResultsAnalysisObject, inputsStruct, cosmicRayEvents1 )
        compare_target_flux_results( varargin );

        % This function was developed to facilitate PDC results analysis.
        [eventIndicatorArray, deltaArray, crcObj] = ...
            get_cosmic_ray_indicators_and_deltas(keplerId, module, output, rootPath);
    end  
    
    
end

%********************************** EOF ***********************************
