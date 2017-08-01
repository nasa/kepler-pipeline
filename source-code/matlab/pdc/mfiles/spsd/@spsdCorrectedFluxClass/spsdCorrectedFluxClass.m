%% classdef spsdCorrectedFluxClass   
% =========================================================================
% Detects Sudden Pixel Sensitivity Dropout (SPSD) events in flux time
% series and returns a summary of events detected along with additive
% corrections for each target.
%
% Let N = number of stellar targets in targetDataStruct.
%     C = the number of cadences in each light curve.
%     B = the number of basis vectors used in cotrending.
%
%
% METHODS:
%
%     spsdCorrectedFluxClass( paramStruct, targetDataStruct, mapVectors, preLoadedEvents)
%
%         Constructor. Builds the results structure by iteratively
%         detecting and correcting SPSDs in t
%
%         paramStruct        : A struct containing the following fields
%                              (see PROPERTIES below for details): 
%                              .pdcModuleParameters
%                              .spsdDetectorConfigurationStruct
%                              .spsdDetectionConfigurationStruct
%                              .spsdRemovalConfigurationStruct
%
%         targetDataStruct   : An N-length array of structs representing
%                              stellar targets. (see pdcDataStruct)
%
%         mapVectors         : A B x C matrix of MAP basis vectors
%                              (or optionally empty matrix).
%
%         preLoadedEvents:   : An optional struct array containing events.
%                              See compile_spsd_blob().
%                              Intended mainly for SC processing (added in 8.2).
%
%
%     spsdCorrectedFluxClass(  spsdCorrectedFluxObject )
%
%         Constructor. The constructor can also be called with a
%         spsdCorrectedFluxClass object as the sole argument. Since this
%         object contains all the relevant input data from its
%         construction, that data is simply extracted and used as input for
%         constructing the current object.
%
%
%     get_results() 
%
%         Returns a structure indicating clean targets and targets in which
%         SPSD events were identified. For each "dirty" target, a combined
%         additive correction is returned. Additive corrections are also
%         returned for each individual event within a target. See the
%         example structure below for details.
%
%         Assuming at least one SPSD was identified, a corrected light 
%         curve for the first SPSD can be created as follows:
%
%             >> idx1 = resultsStruct.spsd.index(1);
%             >> correctedFlux = targetDataStruct(idx1).values ...
%                    + resultsStruct.spsd.targets(1).cumulativeCorrection;
%
%         The cumulative correction is simply the sum of the individual
%         SPSD corrections:
%
%             cumulativeCorrection = sum([spsdEvents.correction],2)).
%
%         Example
%         -------
%         exampleResultsStruct          
%         |
%         |-.clean [1x1 struct]         : Structure summarizing targets in
%         |  |                            which SPSD events were NOT
%         |  |                            identified.
%         |  |-.count: 4                : Number of "clean" targets.
%         |  |-.index: [2 3 4 5]        : targetDataStruct array indices of
%         |  |                            clean targets.
%         |   -.keplerId: [8077474 8077489 8077525 8733697]
%         |                             : Kepler IDs corresponding to 
%         |                               elements in 'index').
%          -.spsds [1x1 struct]         : Structure summarizing targets in
%            |                            which SPSD events WERE identified.
%            |-.count: 1                : Number of "dirty" targets.
%            |-.index: 1                : targetDataStruct array indices of
%            |                            targets containing SPSD events. 
%            |-.keplerId: 8077476
%             -.targets: [1x1 struct]   : SPSD event and correction summary 
%               |                         for each target.
%               |-.index: 1             : targetDataStruct array index of 
%               |                         this target.
%               |-.keplerId: 8077476    : Kepler ID of this target.
%               |-.spsdCount: 1         : Number of SPSD events identified 
%               |                         in this target.
%               |-.cumulativeCorrection: [4634x1 double]
%               |                       : Combined additive correction to  
%               |                         target's light curve: correctedFlux =
%               |                         this rawFlux + cumulativeCorrection, 
%               |                         where cumulativeCorrection =
%               |                         sum([spsdEvents.correction],2)).  
%                -.spsdEvents: [1x1 struct]
%                  |                    : Summary of individual SPSD events.
%                  |-.spsdCadence: 2516
%                  |                    : The index of the last non-gapped
%                  |                      cadence before the maximum positive
%                  |                      change in the corresponding
%                  |                      correction. (NOTE that this is
%                  |                      different than the meaning of 
%                  |                      spsdCadence in the internal
%                  |                      resultsStruct)
%                  |
%                   -.correction: [4634x1 double]
%                                       : Additive correction for this SPSD.
%
%
% PROPERTIES:
%
%     detectorObject                : An spsdDetectorClass object 
%
%
%     detectionConfigurationStruct         : Configuration parameters for the SPSD
%                                            detection algorithm are contained in
%                                            the following fields:
%         .discontinuityRatioTolerance     : Ratio of long to short step
%                                            height estimates. 
%         .endpointFitWindowWidth          :
%         .excludeWindowHalfWidth          :
%         .falsePositiveRateLimit          : The desired expected false
%                                            positive rate.
%         .harmonicsRemovalEnabled         :
%         .transitSpsdMinmaxDiscriminator  :
%         .useCentroids                    : Use centroid positions in the
%                                            detection process.
%         .quickSpsdEnabled                :
%         .validationSignificanceThreshold : SPSD candidates are considered
%                                            valid if step-size exceeds 
%                                            this many standard deviations.  
%         .maxDetectionIterations       : maximum number of times to
%                                            iterate spsd detection on one time
%                                            series
%
%
%     correctionConfigStruct         : Configuration parameters for the
%                                      SPSD correction algorithm are
%                                      contained in the following fields:
%         .bigPicturePolyOrder       :
%         .harmonicFalsePositiveRate :
%         .logTimeConstantIncrement  : Positive increment
%         .logTimeConstantMaxValue   : Maximum value of log10(time
%                                      constant) for exponential terms in
%                                      the recovery model.
%         .logTimeConstantStartValue : Minimum value of log10(time
%                                      constant) for exponential terms in
%                                      the recovery model.
%         .polyWindowHalfWidth       :
%         .recoveryWindowWidth       :
%
%
%     inputTargetDataStruct          : A copy of the constructor argument
%                                      'targetDataStruct'.
%         
%     mapBasisVectors                : MAP basis vectors, if any.
%         
%     timeSeriesStruct               : A structure used internally in the
%                                      detection/correction process. This
%                                      struct is set to [] upon completion
%                                      of the constructor.
%
%     resultsStruct                  : Let Nc denote the numebr of clean
%     |                                targets and Ns denote the number of
%     |                                targets in which SPSDs were detected.
%     |                                Note that this structure is slightly
%     |                                different from that returned by
%     |                                get_results(). 
%     |-.clean [1x1 struct]          : Structure summarizing targets in
%     |  |                             which SPSD events were NOT
%     |  |                             identified.
%     |  |-.count: [1x1 double]      : Number of "clean" targets.
%     |  |-.index: [1xNc struct]     : targetDataStruct array indices of
%     |  |                             clean targets.
%     |   -.keplerId: [1xNc struct]
%     |                              : Kepler IDs corresponding to 
%     |                                elements in 'index').
%      -.spsds [1x1 struct]          : Structure summarizing targets in
%        |                             which SPSD events WERE identified.
%        |-.count: [1x1 double]      : Number of "dirty" targets.
%        |-.index: [1xNs struct]     : targetDataStruct array indices of
%        |                             targets containing SPSD events. 
%        |-.keplerId: [1xNs struct]
%         -.targets: [1xNs cell]     : SPSD event and correction summary 
%           |                          for each target.
%           | 
%           |-.index:[1x1 double]    : targetDataStruct array index of 
%           |                          this target.
%           | 
%           |-.keplerId: [1x1 double] 
%           |                        : Kepler ID of this target.
%           | 
%           |-.spsdCount: [1x1 double]       
%           |                        : Number of SPSD events identified 
%           |                          in this target.
%           | 
%           |-.gapIndicators: [Cx1 logical]
%           |                        : Gap indicators for this target.
%           | 
%           |-.uncorrectedSuspectedDiscontinuity: [1x1 logical]
%           |                        : If true, at least one SPSD was
%           |                          detected in this target, but
%           |                          corrections were not applied.
%           | 
%           |-.correctedTimeSeries: [1xC double]
%           |                        : The corrected flux time series
%           |                          for this target.
%           | 
%            -.spsd: [1xN_spsd cell] : Summary of individual SPSD events.
%              |                        
%              |-.spsdCadence: [1x1 double]  
%              |                     : The cadence index of the detector
%              |                       response maximum. 
%              | 
%              |-.longCoefs: [1x10 double]
%              |-.longStepHeight: [1x1 double]
%              |-.longMADs: [1x2 double]
%              |-.shortCoefs: [1x7 double]
%              |-.shortStepHeight: [1x1 double]
%              |-.shortMADs: [1x2 double]
%              |-.persistentStep: [1xC double]
%               -.recoveryTerm: [1xC double]
%
%
%     debugObject : Container for (1) flags to modify debugging behavior,
%                   and (2) diagnostic data.
%
%
%
% KEY ASSUMPTIONS:
%
%     - Time series values must be in units of photoelectrons per cadence,
%       as output by PA. 
%     - Input values must constitute Piecewise Contiguous Photometric Data, 
%       as defined in the Kepler Project Glossary (KP-121).
% 
%% ========================================================================
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

classdef spsdCorrectedFluxClass < handle

    %% ---------------------------- Data ----------------------------------
    
    properties (GetAccess = 'public', SetAccess = 'public')
        
        
        saveAsStruct           = true;
        
        detectorObject             = []; % 
        detectionParamsStruct      = []; % Detection parameters
        correctionParamsStruct     = []; % Correction parameters
                                             
        inputTargetDataStruct      = []; % A copy of the input structure
        inputPreloadedStruct       = []; % A copy of the input struct array
                                         % of previous detections, if
                                         % processing short cadence. (This
                                         % was added to facilitate 
                                         % construction of a new object
                                         % from an existing one in short
                                         % cadence)    
        
        mapBasisVectors            = []; % MAP basis vectors, if any.
        
        timeSeriesStruct           = []; % The uncorrected data. With each 
                                         % iteration the contents of this
                                         % structure contain only light curves
                                         % that were corrected in the previous
                                         % iteration.
         
        resultsStruct              = []; % Results from detection and correction 
                                         % methods, used to derive the corrected 
                                         % flux timeseries from the input flux.  
                                     
        debugObject                = []; % Container for (1) flags to 
                                         % modify debugging behavior, and 
                                         % (2) diagnostic data.
                                     
        preLoadedEvents            = []; % Struct array of previous detections.
                                         % Compiled by compile_spsd_blob() in PDC,
                                         % and can be used as input to SPSD to skip
                                         % detection and just use these events.
                                         % Primary purpose as of 8.2 is SC SPSD.
        cadenceStartTimes          = []; % only required if quickSpsdEnabled = true
        cadenceEndTimes            = []; % only required if quickSpsdEnabled = true
        longCadenceTimes           = []; % only required if quickSpsdEnabled = true
        shortCadenceTimes          = []; % only required if quickSpsdEnabled = true
        lcCorrectionRecovery       = []; % only required if quickSpsdEnabled = true
                                         % this intermediate variable stores the LC-corrections for the next correction,
                                         % as extracted from the spsdBlob by detect_from_preloaded()
        lcCorrectionPersistentStep = []; % only required if quickSpsdEnabled = true
                                         % this intermediate variable stores the LC-corrections for the next correction,
                                         % as extracted from the spsdBlob by detect_from_preloaded()
        % NOTE: these last two variables are pretty dirty style.
        %       however, we do not have any time to do this thoroughly now, as we did not expect any need to rewrite the
        %       correction in the first place!
        
    end
    
    %% ------------------------ Public Methods ----------------------------
    methods (Access = 'public')
        %**
        % Constructor
        function obj = spsdCorrectedFluxClass( varargin )
            obj.detectorObject = spsdDetectorClass();     
            obj.debugObject    = spsdDebugClass();
            
            % Parse arguments
            if nargin > 0
                if isa(varargin{1}, 'spsdCorrectedFluxClass')
                    [paramStruct, targetDataStruct, mapVectors, preloaded] = ...
                        obj.object_to_constructor_args( varargin{1} );
                    
                    if ~isempty(preloaded)
                        inputPreLoadedEventsStruct = preloaded;
                    end
                    
                elseif nargin >= 2
                    paramStruct      = varargin{1};
                    targetDataStruct = varargin{2};

                    if nargin >= 3
                        mapVectors = varargin{3}; 
                    end
                    
                    if nargin >= 4
                        inputPreLoadedEventsStruct = varargin{4};
                    end
                end
            end
            
            if exist('paramStruct','var')
                if (exist('inputPreLoadedEventsStruct') ...
                    && paramStruct.spsdDetectionConfigurationStruct.quickSpsdEnabled ...
                    && (~isempty(inputPreLoadedEventsStruct)) )
                
                    obj.cadenceStartTimes = inputPreLoadedEventsStruct.cadenceStartTimes;
                    obj.cadenceEndTimes = inputPreLoadedEventsStruct.cadenceEndTimes;
                    obj.shortCadenceTimes = inputPreLoadedEventsStruct.shortCadenceTimes;
                    obj.longCadenceTimes = inputPreLoadedEventsStruct.longCadenceTimes;
                end
            
                obj.debugObject.set_debug_level(paramStruct.pdcModuleParameters.debugLevel);

                if obj.debugObject.flags.useSocRandStreamManager == false           
                    % Initialize the random number generator. These lines are here 
                    % to facilitate comparison with older results.
                    s = RandStream('mt19937ar', 'Seed', 0, 'RandnAlg', 'Ziggurat');
                    RandStream.setDefaultStream(s);
                end 
            end
            
            if exist('mapVectors', 'var') && ~isempty(mapVectors)
                obj.mapBasisVectors = mapVectors;
            end
            
            
            if exist('targetDataStruct', 'var') && ~isempty(targetDataStruct) 
                
                obj.inputTargetDataStruct = targetDataStruct;
                             
                % Set parameter values
                obj.detectorObject = ...
                          spsdDetectorClass( paramStruct.spsdDetectorConfigurationStruct);
                obj.detectionParamsStruct  = paramStruct.spsdDetectionConfigurationStruct;
                obj.correctionParamsStruct = paramStruct.spsdRemovalConfigurationStruct;
                
                % Initialize timeSeriesStruct
                obj.init_time_series_struct(targetDataStruct);

                % Set up exclude flags for cadences within transits
                % Don't use SPSD's intrinic padding (useExcludeWindowHalfWidth) since the padding is already accounted for
                useExcludeWindowHalfWidth = false;
                for iTarget = 1 : obj.timeSeriesStruct.parameters.nTargets
                    cummulativeTransitGapIndicators = pdcTransitClass.find_cumulative_transit_gaps (targetDataStruct, iTarget);
                    obj.set_exclude_flags(iTarget, find(cummulativeTransitGapIndicators), useExcludeWindowHalfWidth);
                end

                % Set up exclude flags for attitude tweaks
                % Don't use SPSD's intrinic padding (useExcludeWindowHalfWidth) since the padding is already accounted for
                useExcludeWindowHalfWidth = false;
                for iTarget = 1 : obj.timeSeriesStruct.parameters.nTargets
                    if (isfield(targetDataStruct(iTarget), 'attitudeTweakIndicators'))
                        obj.set_exclude_flags(iTarget, find(targetDataStruct(iTarget).attitudeTweakIndicators), useExcludeWindowHalfWidth);
                    end
                end
                
                % Initialize preLoaded short-cadence data if required
                % the input spsdBlob contains all SPSDs from the LC run. we have to:
                % 1) extract the targets which are relevant for this run
                % 2) locate the SC cadence for these targets
                % 3) extract those SPSDs which have the SPSD in the valid cadence range (i.e. in this SC month)
                if (paramStruct.spsdDetectionConfigurationStruct.quickSpsdEnabled ...
                    && exist('inputPreLoadedEventsStruct', 'var') ....
                    && (~isempty(inputPreLoadedEventsStruct)) )
                
                    obj.inputPreloadedStruct = inputPreLoadedEventsStruct;
                    obj.preLoadedEvents = inputPreLoadedEventsStruct.events;
                    % 1) remove targets which are not processed in this run
                    obj.preLoadedEvents = obj.sc_trim_events_to_targetlist( obj.preLoadedEvents );
                    % 2) locate SC cadence for each target
                    obj.preLoadedEvents = obj.sc_locate_spsds( obj.preLoadedEvents , obj.detectorObject.filter );
                    % 3) remove events that are outside the current cadence range
                    obj.preLoadedEvents = obj.sc_trim_events_to_cadencerange( obj.preLoadedEvents );
                end                
                
                

                %***********************************
                % Begin the detection loop

                % Detect and correct SPSDs
                % Iteration is at this level. First call obj.detect to do initial detections. Then correct all the detected SPSDs.
                detectionResultsStruct = obj.detect();
                if obj.numSpsdTargetsIdentified(detectionResultsStruct) == 0
                    obj.append_results(detectionResultsStruct, []);
                end
                
                iter = 1;
                while obj.numSpsdTargetsIdentified(detectionResultsStruct) > 0 ...
                        && iter <= obj.detectionParamsStruct.maxDetectionIterations
                    correctionResultsStruct = obj.correct(detectionResultsStruct.spsds);                    
                    obj.append_results(detectionResultsStruct, correctionResultsStruct);    
                    obj.update_time_series_struct(detectionResultsStruct, correctionResultsStruct);
                    detectionResultsStruct = obj.detect();
                    iter = iter + 1;
                end      
                
                % END the detection loop
                %***********************************

                % Check for any remaining detected, but uncorrected spsds.
                % Flag the corresponding targets, zero the corrections, and
                % revert to the original time series.
                if obj.numSpsdTargetsIdentified(detectionResultsStruct) > 0
                    uncorrectedKeplerIds = detectionResultsStruct.spsds.keplerId;
                    
                    % Make sure these targets have entries in the results
                    % struct.
                    
                    % Set flags and restore original time series.
                    for i = 1:length(obj.resultsStruct.spsds.targets)
                        dirtyTarget = obj.resultsStruct.spsds.targets{i};
                        if ismember(dirtyTarget.keplerId, uncorrectedKeplerIds)
                            dirtyTarget.uncorrectedSuspectedDiscontinuity = true;           
                            dirtyTarget.correctedTimeSeries(:) = ...
                                targetDataStruct(dirtyTarget.index).values(:); 
                            for j = 1:dirtyTarget.spsdCount
                                dirtyTarget.spsd{j}.persistentStep(:) = 0;
                                dirtyTarget.spsd{j}.recoveryTerm(:) = 0;
                            end
                        end
                        obj.resultsStruct.spsds.targets{i} = dirtyTarget;
                    end
                end
                
            end % if exist('targetDataStruct' ...
            
            % Clean-up
            obj.timeSeriesStruct = []; 
            if ~obj.debugObject.flags.retainInputTimeSeries
                obj.inputTargetDataStruct = [];
            end
            
        end % spsdCorrectedFluxClass
            
        
        %**
        % Generate output
        outputStruct = get_results(obj);
        
        
        %**
        % saveobj
        % Assumes that obj has at least one property. 
        function obj = saveobj(obj)
            if obj.saveAsStruct             
                p = properties(obj);
                for i = 1:numel(p)
                    objMethods = methods(obj.(p{i}));
                    if ismember('saveobj', objMethods)
                        s.(p{i}) = obj.(p{i}).saveobj;
                    else
                        s.(p{i}) = obj.(p{i});
                    end
                end
                obj = s;
            end
        end
         
    end % public methods
    
    %% ------------------------ Private Methods ---------------------------
    methods (Access = 'private')
        detectionResultsStruct  = detect(obj);
        correctionResultsStruct = correct(obj, detectionResultsStruct);
        append_results(obj, detectionResultsStruct, correctionResultsStruct);
        init_time_series_struct(obj, targetDataStruct);
        update_time_series_struct(obj, detectionResultsStruct, correctionResultsStruct);
        [ timeSeriesOut removedHarmonics stepVector ] = remove_harmonics(obj, timeSeriesIn, roi, stepIndex );
        outStruct       = precondition(obj, fluxIn,gapsIn,L, W);
        thresholdStruct = compute_thresholds(obj, nCadencesFull, nCadencesNear, faslePositiveRate);

        %**
        % Convert a single index to a time series in the internal
        % timeSeriesStruct to the index of the same time series in the
        % input targetDataStruct.
        function tdsIndex = tss_index_to_tds_index(obj, tssIndex)
            keplerIds = [obj.inputTargetDataStruct.keplerId];
            tdsIndex  = find(keplerIds == obj.timeSeriesStruct.parameters.keplerId(tssIndex) );
        end
        
        %**
        % Get number of "dirty" targets identified in the detection result
        function n = numSpsdTargetsIdentified(obj, detectionResultsStruct)
            n = detectionResultsStruct.spsds.count;
        end
        
        %**
        % Set flags to exclude certain regions from consideration as SPSDs.
        % 'targets' and 'cadences' are equal-length vectors and 'value' is
        % a logical scalar. 'targets' is a vector of indices to targets in
        % the property timeSeriesStruct.
        %
        % Input:
        %   target                    -- [integer] target index in targetDataStruct (Ths function NOT vectorized!)
        %   cadences                  -- [integer array] indices of cadences to mask (NOT logical array)
        %   useExcludeWindowHalfWidth -- [logical] Flag to use the exclude window around each cadence to exclude
        %
        function set_exclude_flags(obj, target, cadences, useExcludeWindowHalfWidth)
            if target < 1 | target > obj.timeSeriesStruct.parameters.nTargets 
                warning('Invalid target index. Flags not set.');
            elseif any( cadences < 1 | cadences > obj.timeSeriesStruct.parameters.nCadences)
                warning('Invalid cadence indices. Flags not set.');
            else
                if (useExcludeWindowHalfWidth)
                    halfwidth = obj.detectionParamsStruct.excludeWindowHalfWidth;
                else
                    halfwidth = 0;
                end
                excludeRow = obj.timeSeriesStruct.exclude(target,:);
                for i = 1:length(cadences)
                    indices = obj.clamp(cadences(i)-halfwidth : cadences(i)+halfwidth, ...
                                        1, obj.timeSeriesStruct.parameters.nCadences);
                    excludeRow(indices) = true;
                end
                obj.timeSeriesStruct.exclude(target, :) = excludeRow;
            end
        end

                    
    end % private methods
    
    %% ------------------------ Static Methods ----------------------------
    % Unfortunately, static properties are not supported in Matlab 2010b,
    % so any constants used by static methods need to be defined within the
    % methods. 
    methods (Static)
        
        %**
        % Extract constructor arguments from an existing
        % spsdCorrectedFluxClass object.
        function [paramStruct, targetDataStruct, mapVectors, preloaded] = object_to_constructor_args(spsdCorrectedFluxObject )
            paramStruct.pdcModuleParameters.debugLevel   = spsdCorrectedFluxObject.debugObject.debugLevel;
            paramStruct.spsdDetectorConfigurationStruct  = spsdCorrectedFluxObject.detectorObject.parameterStruct;
            paramStruct.spsdDetectionConfigurationStruct = spsdCorrectedFluxObject.detectionParamsStruct; 
            paramStruct.spsdRemovalConfigurationStruct   = spsdCorrectedFluxObject.correctionParamsStruct;
            targetDataStruct = spsdCorrectedFluxObject.inputTargetDataStruct;
            mapVectors = spsdCorrectedFluxObject.mapBasisVectors;
                   
            if ismember('inputPreloadedStruct', properties(spsdCorrectedFluxObject))
               preloaded = spsdCorrectedFluxObject.inputPreloadedStruct;
            else
               preloaded = [];
            end
        end

        %**
        % Validate the configuration structures. The other inputs to the 
        % constructor (target data and map basis vectors) are validated
        % elsewhere. 
        isValid = validate_input( spsdDetectorConfigurationStruct, ...
                                  spsdDetectionConfigurationStruct, ...
                                  spsdCorrectionConfigurationStruct ...
                                );
        fieldsAndBounds = get_detection_fields_and_bounds();
        fieldsAndBounds = get_correction_fields_and_bounds(paramStruct);
        
        %**
        % Utility function that returns a set of valid detection parameters
        function ps = get_default_detection_param_struct()
            ps = struct( ...
                'discontinuityRatioTolerance',     0.7, ...   % Ratio of long to short step height estimates.
                'endpointFitWindowWidth',         48, ...     %
                'excludeWindowHalfWidth',          4, ...     % When a cadence is excluded from consideration as an SPSD, exclude this many cadences on either side as well.
                'falsePositiveRateLimit',          0.005, ... % The desired expected false positive rate.
                'transitSpsdMinmaxDiscriminator',  0.7, ...   %
                'useCentroids',                    false, ... % Use centroid positions in the detection process.
                'validationSignificanceThreshold', 3, ...     % spsd candidates are considered valid if they exceed this many standard deviations.
                'excludeWindowHalfWidth', 4, ...              %
                'harmonicsRemovalEnabled', false, ...         %
                'maxDetectionIterations', 5, ...           %
                'quickSpsdEnabled', false ...               
            );
        end

       %**
        % Utility function that returns a set of valid correction parameters
        function ps = get_default_correction_param_struct()
            ps = struct( ...
                'bigPicturePolyOrder',         6, ...
                'harmonicFalsePositiveRate',   0.01, ...
                'logTimeConstantIncrement',    1, ...     % Positive increment
                'logTimeConstantMaxValue',     0, ...     % Maximum value of log10(time constant) for exponential terms in the recovery model
                'logTimeConstantStartValue',  -2, ...     % Minimum value of log10(time constant) for exponential terms in the recovery model
                'polyWindowHalfWidth',       480, ...
                'recoveryWindowWidth',       240, ...
                'useMapBasisVectors',       true, ...
                'shortCadencePostCorrectionEnabled',     false, ...
                'shortCadencePostCorrectionMethod',      'gapfill', ...
                'shortCadencePostCorrectionLeftWindow',  5, ...
                'shortCadencePostCorrectionRightWindow', 30 ...
            );
        end

        %**
        % Determine the optimal degree for polynomial fitting, using
        % Akaike's information criterion.
        [n,ys1] = polydeg(x,y);
        
        %**
        % Limit the values in vector x to the range [minval, maxval].
        function y = clamp(x, minval, maxval)
            y = max(min(x, maxval), minval);
        end

        %**
        % loadobj
        function obj = loadobj(obj)
            
            % If the input is a struct, convert it to an object.
            if isstruct(obj)
                newObj = spsdCorrectedFluxClass();
                objFields = fieldnames(obj);
                
                % For each of the input struct's fields, determine whether
                % the class has a corresponding property. If it does,
                % populate the property.
                for i = 1:numel(objFields)
                    
                    property = objFields{i};
                    if ismember( property, properties(newObj) ) 
                        propertyAttr = findprop(newObj, property);
                        
                        % Ignore constant and abstract properties.
                        if ~propertyAttr.Constant && ~propertyAttr.Abstract
                            
                            % If the property belongs to a class with its
                            % own loadobj() method, use it. Otherwise,
                            % assign the structure's field value directly
                            % to the corresponding property.
                            newObjMethods = methods(newObj.(property));
                            if ismember('loadobj', newObjMethods)
                                newObj.(property) = ...
                                    newObj.(property).loadobj(obj.(property));
                            else
                                newObj.(property) = obj.(property);
                            end
                            
                        end
                    end
                end
                
                obj = newObj;
            end
        end

    end % static methods
    
end

