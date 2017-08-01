classdef cosmicRayCleanerClass < handle
%************************************************************************** 
% classdef cosmicRayCleanerClass < handle
%************************************************************************** 
% A class to perform cosmic ray cleaning and contain the results. This
% class provides a common framework for all cleaning of cosmic rays from
% pixel time series. Derived classes are responsible for transforming input
% data into the form required by cosmicRayCleanerClass (see
% paCosmicRayCleanerClass and calCosmicRayCleanerClass).
%
% METHODS:
%
%     cosmicRayCleanerClass()
%
%         Constructor. May be called in any of the following ways:
%
%             cosmicRayCleanerClass()
%             cosmicRayCleanerClass( cosmicRayCleanerObject )
%             cosmicRayCleanerClass( cosmicRayInputStruct )
%
%         where
%             cosmicRayInputStruct : 
%             |-.params                 
%             |  |-.gapLengthThreshold
%             |  |-.longMedianFilterLength
%             |  |-.shortMedianFilterLength
%             |  |-.arOrder
%             |  |-.detectionThreshold
%             |  |-.cleanZeroCrossingCadencesEnabled
%             |  |-.harmonicsIdentificationConfigurationStruct 
%             |   -.gapFillConfigurationStruct 
%             |  
%             |-.targetArray [1 x N struct] 
%             |  |                       : A cosmicRayTargetStruct array.
%             |  |
%             |  |-.activeIndices        : Optional field specifying the
%             |  |                         pixels in pixelArray that should
%             |  |                         be corrected. Others will be
%             |  |                         unaffected  
%             |  |
%             |   -.pixelArray [1 x P struct] 
%             |                          : A cosmicRayPixelStruct array.
%             |  
%             |-.ancillary  [1 x A cell] : A cell array of matrices
%             |                            containing ancillary time series
%             |                            for each target. 
%             |
%             |-.cadenceTimes [1 x 1 struct] 
%             |                          : A cadenceTimes struct.
%             |
%              -.debugLevel [1 x 1 int]  : An integer (set to zero during 
%                                          pipeline operation).
%
%         and 
%             cosmicRayTargetStruct
%             |-.activeIndices           : Optional field specifying the
%             |                            pixels in pixelArray that should
%             |                            be corrected. Others will be
%             |                            unaffected  
%              -.pixelArray              : An array of cosmicRayPixelStruct
%
%             cosmicRayPixelStruct
%             |-.ccdRow                  : (a constant if collateral smear)
%             |-.ccdColumn               : (a constant if collateral black)
%             |-.values        [C x 1 double] 
%             |                          : 
%             |-.gapIndicators [C x 1 logical] 
%             |                          : 
%              -.uncertainties [C x 1 double]
%                                        : (unavailable for CAL collateral
%                                           data) 
%         C = number of cadences
%         N = number of targets
%         P = number of pixels 
%         A = number of ancillary time series
%
%         Unless otherwise stated, both cosmicRayTargetStruct and
%         cosmicRayPixelStruct *must* contain the fields listed above but
%         may also contain arbitrary additional fields.
%
%
%     set_exclude_cadences( excludeIndicators )
%
%         Identify cadences which should NOT be cleaned. Typically these
%         will be zero-corossing cadences in short-cadence time series.
%
%     clean()
%
%         Process all targets.
%
%
% PROPERTIES:
%     params
%     timestamps
%     inputArray            
%     targetArray              
%     ancillaryTimeSeries           
%     excludeIndicators              
%     isCleaned 
%     debugStruct 
%
% USAGE:
%     Within the pipeline:
%         
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
    properties (Constant)
        ACTIVE_PIXEL_FIELDNAME   = 'pixelsToClean';
        CR_SIGNAL_FIELDNAME      = 'cosmicRaySignal';
        LARGE_TREND_FIELDNAME    = 'largeScaleTrend';
        LS_MODEL_FIELDNAME       = 'hmfModel';
        AR_MODEL_FIELDNAME       = 'arModel';
        NONIMP_OUTLIER_FIELDNAME = 'nonImpulsiveOutliers';
        PREDICTION_FIELDNAME     = 'prediction';
    end
    
    properties (GetAccess = 'public', SetAccess = 'public')
        params              = [];         % A copy of the cosmic ray config 
                                          % struct with gap fill and
                                          % harmonics ID config structs
                                          % added as fields.
                                          
        timestamps          = [];         % An array of mid-cadence 
                                          % timestamps 
                                          
        inputArray          = struct([]); % A copy of the original input 
                                          % target array.
                                         
        targetArray         = struct([]); % The "working" target array   
                                          % which ultimately contains the
                                          % results. 
                                         
        ancillaryTimeSeries = {};         % A cell array of matrices, each 
                                          % column of which corresponds to
                                          % the
                                          % Include these column vectors in
                                          % the first-stage model.  
                                         
        excludeIndicators   = [];         % A logical array indicating 
                                          % cadences NOT to clean (true =
                                          % "do not clean"). 
                                         
        isCleaned           = [];         % Targetwise flags indicating 
                                          % whether the target has been
                                          % cleaned (true) or not (false). 
        
        debugStruct         = struct;     % Container for debugging flags 
                                          % and related data.
     end
    
    %% ------------------------- Public Methods ---------------------------
    methods 
        
        %**
        % Constructor
        %   If no argument is passed a default object is created. If an
        %   argument is passed it may contain any of the following:
        %   1) An empty cell array (constructs a defalt object).
        %   2) A cosmicRayCleanerClass object (copy constructor).
        %   3) A cosmic ray cleaner input struct.
        function obj = cosmicRayCleanerClass( arg )
            %--------------------------------------------------------------
            % Default constructor
            %--------------------------------------------------------------
            if nargin == 0 || isempty(arg)
                obj.params = obj.get_default_param_struct();
                obj.initialize_debug_struct(0);               
            
            %--------------------------------------------------------------
            % Copy constructor
            %--------------------------------------------------------------
            elseif nargin == 1 && isa(arg, 'cosmicRayCleanerClass')
                cosmicRayCleanerObject = arg;
                p = properties('cosmicRayCleanerClass'); % Public properties
                for i = 1:numel(p)
                    propertyAttr = findprop(cosmicRayCleanerObject, p{i});
                    if ~propertyAttr.Constant && ~propertyAttr.Abstract
                        
                        % An older object's properties may be a subset of
                        % the properties listed in the current class
                        % definition.  
                        if any(ismember( ...
                            properties(cosmicRayCleanerObject), p{i})) 
                            obj.(p{i}) = cosmicRayCleanerObject.(p{i});
                        end
                    end
                end
                  
            %--------------------------------------------------------------
            % Construct from a cosmicRayInputStruct.
            %--------------------------------------------------------------
            else      
                obj.initialize_debug_struct( arg.debugLevel );

                obj.params              = arg.params;
                obj.timestamps          = arg.cadenceTimes.midTimestamps;
                obj.inputArray          = arg.targetArray;
                
                if isfield(arg, 'ancillary') && ~isempty(arg.ancillary)
                    obj.ancillaryTimeSeries = arg.ancillary;
                end

                % Make sure the gap filler is using the correct cadence
                % duration.
                obj.params.gapFillConfigurationStruct.cadenceDurationInMinutes ...
                    = compute_cadence_duration_in_minutes(arg.cadenceTimes);

                obj.initialize_target_array();
                obj.set_exclude_cadences();
                obj.isCleaned = false(size(obj.targetArray));   
            end
        end
        
        %**
        % clean()
        clean(obj);
        
        %**
        % clean_target()
        cleanTargetStruct = clean_target(obj, targetIdx, activeIndices);

        %**
        % set_exclude_cadences()
        function set_exclude_cadences(obj, excludeIndicators)
            nCadences = length(obj.timestamps);
            if exist('excludeIndicators', 'var') ...
                    && length(excludeIndicators) == nCadences ...
                    && islogical(excludeIndicators)
                obj.excludeIndicators = excludeIndicators(:);
            else % The default behavior is to clean all cadences.
                obj.excludeIndicators = false(nCadences,1);
            end
        end
                        
        %**
        % reconstruct_result_from_event_array()
        %
        % Reconstruct the estimated cosmic ray pixel time series from an
        % event array and add the time series to the targetArray.
        reconstruct_result_from_event_array(obj, cosmicRayEvents, ...
            midCadenceTimes, convertEventsToZeroBased);
    end
    
    %% ------------------------- Private Methods --------------------------
    methods (Access = 'public') % (Access = 'private')
        
        %**
        % initialize_target_array()
        initialize_target_array( obj );
        
        %**
        % predict_arburg()
        [y_predicted, x, x_sigma, deltaSigma, outliers] ...
            = predict_arburg( obj, y, p, t, gaps);
                                
        %**
        % get_conditioned_time_series()
        [pixelTsArr,trendMat] = get_conditioned_time_series(obj,targetIdx);

        %**
        % identify_harmonics()
        harmonicModelStruct = identify_harmonics(obj,values,gapIndicators);
        
        %**
        % build_design_matrix()
        designMat = build_design_matrix(obj, targetIndex, cadences, ...
                                             frequencies, samplingTimes);
                        
        %**
        % Set debugging flags given the PA debug level.
        initialize_debug_struct(obj, debugLevel);
  
    end
    
    
    %% ------------------------- Static Methods ---------------------------
    methods (Static)
        %**
        % find_gaps()
        [startIndices, gapLengths] = find_gaps( gapIndicators, roi );
        
        %**
        % find_neighbors()
        nbrIndices = find_neighbors(pixelArray, pixelRowCol, neighborhood);

        %**
        % padded_median_filter()
        filteredMat = padded_median_filter( columnVectorMat, ...
                                            filterWindowLength );

        %**
        % fit_by_svd()
        X = fit_by_svd(A, Y);
        
        %**
        % linear_gap_fill()
        filled = linear_gap_fill(ts, gapIndicators);
        
        %**
        % create_empty_pixel_struct()
        function pixelStruct = create_empty_pixel_struct()
            pixelStruct = struct(...
                'ccdRow',        [], ...
                'ccdColumn',     [], ...
                'values',        [], ...
                'gapIndicators', [], ...
                'uncertainties', []);
        end
                       
        %**
        % create_empty_input_struct()
        function inputStruct = create_empty_input_struct()
             inputStruct = struct;
             inputStruct.params       = struct([]);
             inputStruct.targetArray  = struct([]);    
             inputStruct.cadenceTimes = struct([]);
             inputStruct.ancillary    = {};
             inputStruct.debugLevel   = 0;
        end
        
        %**
        % get_default_cosmic_ray_config_struct()
        %
        % Useful for obtaining a valid struct that can be modified and
        % passed to the constructor.
        function cosmicRayConfigurationStruct ...
                = get_default_cosmic_ray_config_struct()
            cosmicRayConfigurationStruct = struct( ...
                'gapLengthThreshold',                10, ...  % Gaps longer than this are used to define segments.
                'longMedianFilterLength',            49, ...  % Jon suggested a value of 49 (1 day)
                'shortMedianFilterLength',           3, ...   % Post-processing median filter order.
                'arOrder',                           50, ...  % Autoregressive model order.
                'detectionThreshold',                4, ...   % Detection threshold in number of innovation standard deviations.
                'cleanZeroCrossingCadencesEnabled',  true ... % Identify and clean cosmic rays on zero crossing cadences (applies to non-background targets only).
            );
        end
        
        %**
        % get_default_gap_fill_config_struct()
        %
        % Useful for obtaining a valid struct that can be modified and
        % passed to the constructor.
        function gapFillConfigurationStruct ...
                = get_default_gap_fill_config_struct()
            gapFillConfigurationStruct = struct( ...
                'madXFactor' , 10 , ...
                'maxGiantTransitDurationInHours' ,        72 , ...
                'maxDetrendPolyOrder' ,                   25 , ...
                'maxArOrderLimit' ,                       25 , ...
                'maxCorrelationWindowXFactor' ,           5 , ...
                'gapFillModeIsAddBackPredictionError' ,   true , ...
                'waveletFamily' ,                         'daub' , ...
                'waveletFilterLength' ,                   12 , ...
                'giantTransitPolyFitChunkLengthInHours' , 72 , ...
                'removeEclipsingBinariesOnList' ,         true , ...
                'arAutoCorrelationThreshold' ,            0.0500 , ...
                'cadenceDurationInMinutes'  ,             29.4244 );
        end
        
        %**
        % get_default_harmonic_id_config_struct()
        %
        % Useful for obtaining a valid struct that can be modified and
        % passed to the constructor.
        function harmonicsIdentificationConfigurationStruct ...
                = get_default_harmonic_id_config_struct()
            
            % Add a configuration struct for harmonic identification. We
            % may want to add this struct as a module parameter.
            harmonicsIdentificationConfigurationStruct = struct( ...
                'falseDetectionProbabilityForTimeSeries' ,    0.0010 , ... % JT: possibly 0.0001 to speed up
                'maxHarmonicComponents' ,                     25 , ...     % JT: also possible to reduce this for speed up
                'medianWindowLengthForPeriodogramSmoothing' , 47 , ...     %
                'medianWindowLengthForTimeSeriesSmoothing' ,  21 , ...     % Not currently used -RLM
                'minHarmonicSeparationInBins' ,               25 , ...     %
                'movingAverageWindowLength' ,                 47 , ...     %
                'timeOutInMinutes' ,                          2.5000 );    % JT: may want to reduce time limit.
        end
        
        %**
        % get_default_param_struct()
        %
        % Create a default parameter struct by combining the default 
        % structures defined above.
        function paramStruct = get_default_param_struct()
            paramStruct ...
                = cosmicRayCleanerClass.get_default_cosmic_ray_config_struct();
            paramStruct.harmonicsIdentificationConfigurationStruct ...
                = cosmicRayCleanerClass.get_default_harmonic_id_config_struct();
            paramStruct.gapFillConfigurationStruct ...
                = cosmicRayCleanerClass.get_default_gap_fill_config_struct();
        end
    end  
    
    
end

%********************************** EOF ***********************************
