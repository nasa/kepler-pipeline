function detectionResultsStruct = detect_from_scratch( obj )
%%  detect_from_scratch 
% Identifys SPSDs in timeseries
% spsd = Sudden Pixel Sensitivity Dropouts
% 
%   Revision History:
%
%       Version 0 -   3/14/11     released for Science Office use
%       Version 0.1 - 4/30/11     improved/corrected documentation
%                                 replaced some enumerated values with
%                                 variable names
% 
% <html>
% <style type="text/css"> pre.codeinput {background: #FFFF66; padding: 30px;} </style>
% </html>
% 
%
%function detectionResultsStruct = detect(detectorStruct, timeseriesStruct);
%% 1.0 ARGUMENTS
% 
% Function returns:
%
% * |detectionResultsStruct     -| structure containing output parameters. 
% * |.clean                     -| Information about CLEAN targets:
% * |-.count                    -| how many
% * |-.index                    -| which ones, relative to input timeseries order
% * |-.keplerId                 -| which ones, Kepler IDs
% * |.spsds                     -| Information about spsd-containing targets:
% * |-.count                    -| how many?
% * |-.index                    -| which ones, relative to input timeseries order
% * |-.keplerId                 -| which ones, Kepler IDs
% * |-.keplerMag                -| kepler magnitude
% * |-.spsdCadence          	-| LC number relative to start of timeseries (See |detect.m| )
% * |-.longCoefs                -| local fit coefficients for long window (See |detect.m| )
% * |-.longStepHeight          	-| estimated step height for long window (See |detect.m| )
% * |-.longMADs              	-| MAD of residuals & MAD of residual differences for long window (See |detect.m| )
% * |-.shortCoefs        	    -| local fit coefficients for short window (See |detect.m| )
% * |-.shortStepHeight       	-| estimated step height for short window (See |detect.m| )
% * |-.shortMADs           	    -| MAD of residuals & MAD of residual differences for short window (See |detect.m| )
%
% Function Arguments:
%
% * |detectorStruct      -| structure detector information. 
% * See | init_filter.m | for structure details
%
% * |timeseriesStruct   -| structure containing timeseries information. 
% * See | Get_input_timeseries.m | for structure details
%%
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

MAD_FACTOR = 0.6745; % Estimated median absolute deviation of X 
                     % = mad(X,1)/MAD_FACTOR 
                     
detector = obj.detectorObject;

if isempty(detector.filter)
    detectionResultsStruct = struct([]);
    return
end

detectorStruct.kernelLength             = size(detector.filter, 1);
detectorStruct.kernelCount              = size(detector.filter, 2);
detectorStruct.kernels                  = detector.filter;
detectorStruct.longModel.nComponents    = detector.longModel.nComponents;
detectorStruct.longModel.designMatrix   = detector.longModel.designMatrix;
detectorStruct.longModel.pseudoinverse  = detector.longModel.pseudoinverse;
detectorStruct.shortModel.nComponents   = detector.shortModel.nComponents;
detectorStruct.shortModel.designMatrix  = detector.shortModel.designMatrix;
detectorStruct.shortModel.pseudoinverse = detector.shortModel.pseudoinverse;


%% 2.0 CONSTANT INITIALIZATION

%% 3.0 INITIALIZATION
%

% Don't analyze time series if they contain...
% 1) all gaps
% 2) a constant value, including 0, NaN, or Inf
rowStd = zeros( size(obj.timeSeriesStruct.fluxResiduals,1),  1);
for k = 1:length( rowStd )
    standardDev = std(obj.timeSeriesStruct.fluxResiduals(k,~obj.timeSeriesStruct.gaps(k,:)), 1, 2); % Exclude gapped cadences
    if ~isempty(standardDev) % If time series is all gaps, leave rowStd(k) set to zero.
        rowStd(k) = standardDev;
    end
end
validInd              = find( rowStd ~= 0 & ~isnan(rowStd) );                         
nValid      	      = length(validInd);
normalizedResponse1   = zeros(nValid, obj.timeSeriesStruct.parameters.nCadences);
conditionedTimeSeries = zeros(nValid, ...
                              obj.timeSeriesStruct.parameters.nCadences ...
                              + detectorStruct.kernelLength - 1);
maxResponseCadence    = zeros(nValid, 1);
minLocalResponse      = zeros(nValid, 1);
thresholdStruct       = obj.compute_thresholds( ...
                            obj.timeSeriesStruct.parameters.nCadences, ...
                            detectorStruct.kernelLength, ...
                            obj.detectionParamsStruct.falsePositiveRateLimit);
longModel             = detectorStruct.longModel;
shortModel            = detectorStruct.shortModel;
longWindowHalfWidth   = (detectorStruct.kernelLength - 1) / 2;
shortWindowHalfWidth  = (size(shortModel.designMatrix, 2) -1) / 2;

%% 4.0 IDENTIFY SPSDs
% 

if obj.detectionParamsStruct.useCentroids

%% 4.1 DETECTION WITH CENTROIDS
% 
    
    %TBD
    
else

%% 4.2 DETECTION WITHOUT CENTROIDS
% 

%% 4.2.1 PREPARE TIMESERIES FOR DETECTION PROCESS

     if obj.debugObject.flags.useSocRandStreamManager == true           
        srsm = socRandStreamManagerClass('pdc', ...
                   obj.timeSeriesStruct.parameters.keplerId(validInd), ...
                   struct( ...
                          'generatorType', 'mt19937ar', ...
                          'randnAlg', 'Ziggurat', ...
                          'antithetic', false, ...
                          'fullPrecision', true, ... 
                          'seedOffset', 0 ...
                         )...
                   );
    end 
    
    for k=1:nValid 
        
        if obj.debugObject.flags.useSocRandStreamManager == true           
            % Set the default random stream for this target
            srsm.set_default( obj.timeSeriesStruct.parameters.keplerId( ...
                                                          validInd(k)) );
        end
        
        % precondition each time series. (see precondition.m) 
        % ID gaps and near-gap regions
        preconditionedStruct = obj.precondition( ...
            obj.timeSeriesStruct.fluxResiduals(validInd(k),:), ... 
            obj.timeSeriesStruct.gaps(validInd(k),:), ...
            detectorStruct.kernelLength, ...
            obj.detectionParamsStruct.endpointFitWindowWidth);
        
        conditioned=preconditionedStruct.fluxOut;
        
        % Convolve detector with conditioned time series.
        % A step height is measured at each LC
        response=conv(conditioned,detectorStruct.kernels(:,1), 'valid');
        
        % Calculate a robust sigma for step height time series
        SPSD_sigma = mad(response,1) / MAD_FACTOR;

        % Standardize step height time series          
        normalizedResponse1(k,:) = (response - nanmedian(response)) / SPSD_sigma;

        % zero regions in and near gaps in standardized step height time
        % series.
        normalizedResponse1(k, ~preconditionedStruct.mask) = ...
            zeros(1, sum(~preconditionedStruct.mask));
        
        % maintain conditioned time series for future use
        conditionedTimeSeries(k,:) = conditioned;         
    end

    if obj.debugObject.flags.useSocRandStreamManager == true           
        srsm.restore_default(); % Restore the default rand stream to its 
                                % original state.
    end    
    
%% 4.2.2 STANDARDIZE ACROSS TARGETS LONG CADENCE -BY- LONG CADENCE
% 

    if nValid > 3
        
        % calculate MAD of all targets for each long cadence
        targetMadPerCadence = mad(normalizedResponse1,1);

        % if LCs have no variation (MAD=0) set to MAD_FACTOR
        targetMadPerCadence(targetMadPerCadence==0) = ...
            MAD_FACTOR*ones(sum(targetMadPerCadence==0), 1);

        % standardize each long cadence across all targets
        normalizedResponse2 = (normalizedResponse1 - (ones(nValid,1) ...
            * median(normalizedResponse1,1))) ./ ...
            (ones(nValid,1) * targetMadPerCadence / MAD_FACTOR);                                  
    else
        % 3 or less target case 
         normalizedResponse2 = normalizedResponse1;     
    end
    

%% 4.2.3 RESTANDARDIZE TARGET -BY- TARGET 
% to produce final detection statistics: normalizedResponse3
    
    if nValid > 3
        
        % standardize each targets across all long cadences 
        normalizedResponse3 = (normalizedResponse2 ...
            - (median(normalizedResponse2,2) ...
            * ones(1,obj.timeSeriesStruct.parameters.nCadences))) ...
            ./ (mad(normalizedResponse2',1)' / MAD_FACTOR ...
            * ones(1,obj.timeSeriesStruct.parameters.nCadences));           
    else
        % 3 or less target case 
        normalizedResponse3 = normalizedResponse2;    
    end
    
    
%% 4.2.4 COMPILE EXTREME VALUES FOR EACH TARGET
% 
    useExcludeWindowHalfWidth = true;
    % Preallocate storage for the maximum of each 2D-standardized step
    % height time series. 
    maxResponse = zeros(size(normalizedResponse3, 1), 1);
    maxMinSum   = zeros(size(normalizedResponse3, 1), 1);

    for k=1:nValid
        proceedToNextTarget = false;

        while ~proceedToNextTarget
            % Find max response, excluding masked cadences.
            nonExcludedCadences = find(~obj.timeSeriesStruct.exclude(validInd(k),:));

            if ~isempty(nonExcludedCadences)
                [maxResponse(k), nonExcludedCadenceIdx] = max(normalizedResponse3(k, nonExcludedCadences));

                % find LC time of each maximum 
                maxResponseCadence(k) = nonExcludedCadences(nonExcludedCadenceIdx);

                % find the minimum in a time window around each maximum. Masked
                % cadences ARE included here, since we are searching for trailing
                % edges of potential transits and don't want to ignore anything.
                lowInd = max(1, maxResponseCadence(k) - longWindowHalfWidth);
                hiInd  = min(obj.timeSeriesStruct.parameters.nCadences, ...
                             maxResponseCadence(k) + longWindowHalfWidth);
                minLocalResponse(k) = min(normalizedResponse3(k, [lowInd:hiInd]), [], 2);

                maxMinSum(k) = maxResponse(k) + minLocalResponse(k);

                if true % obj.detectionParamsStruct.skipTargetsWithSuspectedGiantTransits
                    proceedToNextTarget = true;
                else
                    % If the max response looks like a possible giant transit,
                    % set exclude flags and reprocess the current target.
                    if maxResponse(k) > thresholdStruct.full && ...
                       (maxMinSum(k)  < thresholdStruct.diff || ...
                        maxMinSum(k)  < obj.detectionParamsStruct.transitSpsdMinmaxDiscriminator ...
                                  * maxResponse(k) - thresholdStruct.nearMid)     
                        obj.set_exclude_flags(validInd(k), maxResponseCadence(k), useExcludeWindowHalfWidth);
                    else
                        proceedToNextTarget = true;
                    end
                end
            else
                proceedToNextTarget = true;
            end
        end % while ~proceedToNextTarget

    end % for k=1:nValid
        
    
%% 4.2.5 IDENTIFY spsd CANDIDATES
% 

    % flag candidates based on 3 criteria. The second two critera are
    % redundant since they were applied in the last step. Still, we leave
    % them in place here for clarity and because redundancy can't hurt the
    % result.
    isCandidate = ...
        maxResponse > thresholdStruct.full & ...
        maxMinSum   > thresholdStruct.diff & ...
        maxMinSum   > obj.detectionParamsStruct.transitSpsdMinmaxDiscriminator ...
                      * maxResponse - thresholdStruct.nearMid;
                
    % how many?
    nCandidates = sum(isCandidate);
    
    % which ones?
    candidateIndices = find(isCandidate);
    
    % Retain locations of maximal responses that are not candidates.
    if obj.debugObject.flags.retainNonCandidates
        nonCandidateTargets  = validInd(~isCandidate);
        nonCandidateCadences = maxResponseCadence(~isCandidate);
        
        eventArr = struct;
        for i = 1:length(nonCandidateTargets)
            eventArr(i).index    = nonCandidateTargets(i);
            eventArr(i).cadence = nonCandidateCadences(i);
        end
        
        if isfield( obj.debugObject.data, 'nonCandidateEvents')
            nonCandidateEvents = obj.debugObject.get_data('nonCandidateEvents');
            iter = numel(fieldnames(nonCandidateEvents)) + 1;
        else
            nonCandidateEvents = struct;
            iter = 1;
        end
        
        newField = strcat('iter',num2str(iter));
        nonCandidateEvents.(newField) = eventArr;
        obj.debugObject.set_data('nonCandidateEvents', nonCandidateEvents);
    end

%% 4.2.6 PREPARE CANDIDATES FOR VALIDATION 
%     
    
    if nCandidates>0
        
        % Initilize matrices of relevent local data
        conditionedFluxWindow = zeros(nCandidates,detectorStruct.kernelLength);

        % Populate matrices for all candidates
        for k=1:nCandidates
            
                % Center position
                r1 = maxResponseCadence(candidateIndices(k));
                
                % full window range (for conditionedFluxWindow)
                rg0 = r1 - longWindowHalfWidth : r1 + longWindowHalfWidth;
                
                % start/End-truncated window range 
                rg = max(1, r1 - longWindowHalfWidth) : ...
                     min(obj.timeSeriesStruct.parameters.nCadences, ...
                         r1 + longWindowHalfWidth);
                 
                % conditioned flux time series in window around candidate
                % spsd 
                conditionedFluxWindow(k,rg0-r1+longWindowHalfWidth+1) ...
                    = conditionedTimeSeries(candidateIndices(k), ...
                                            rg0 + longWindowHalfWidth);
                
        end
    
%% 4.2.7 SHORT AND LONG TERM FITS OF CANDIDATE TIME SERIES
%     
    
        % fit coefficents for short-term and long-term models
        longLocalFitCoefs=conditionedFluxWindow*longModel.pseudoinverse;
        shortLocalFitCoefs=conditionedFluxWindow*shortModel.pseudoinverse;

        % model estimates for short term and long term models
        longLocalEstimate=longLocalFitCoefs*longModel.designMatrix;
        shortLocalEstimate=shortLocalFitCoefs*shortModel.designMatrix;
        
        % step height estimates for short term and long term models
        longStepHeight  = longLocalEstimate(:,longWindowHalfWidth+1+2) ...
            - longLocalEstimate(:,longWindowHalfWidth+1-2);
        shortStepHeight = shortLocalEstimate(:,shortWindowHalfWidth+1+2) ...
            - shortLocalEstimate(:,shortWindowHalfWidth+1-2);

        % standardized step height for short term and long term model
        % accounts for only shot noise
        longNormalizedStepHeight  = sqrt((detectorStruct.kernelLength-3) ...
            * (longStepHeight.^2)  ./ longLocalFitCoefs(:,1)  / 4); 
        shortNormalizedStepHeight = sqrt((size(shortModel.designMatrix,2)-3) ...
            * (shortStepHeight.^2) ./ shortLocalFitCoefs(:,1) / 4);

        % residuals for short term and long term models
        longLocalResidual  = conditionedFluxWindow - longLocalEstimate;
        shortLocalResidual = conditionedFluxWindow(:, ...
            longWindowHalfWidth + 1 - shortWindowHalfWidth ...
            : longWindowHalfWidth+1+shortWindowHalfWidth) ...
            - shortLocalEstimate;

        % MAD of residuals for short term and long term models
        longLocalResidualMAD  = mad(longLocalResidual',1) / MAD_FACTOR;
        shortLocalResidualMAD = mad(shortLocalResidual',1) / MAD_FACTOR;

        % mad of residual differences (local noise level) for short term
        % and long term models 
        longLocalDifResidualMAD  = mad(diff(longLocalResidual'),1) ...
            / MAD_FACTOR;
        shortLocalDifResidualMAD = mad(diff(shortLocalResidual'),1) ...
            / MAD_FACTOR;


%% 4.2.8 VALIDATE CANDIDATES 
%     

        % confirm if:
        %     fit steps are negative
        %     significance is > 3 sigma
        %     ratio of step heights for long term vs short term
        confirmed = ...
            find( longStepHeight<0 & ...
                  shortStepHeight<0 & ...
                  longNormalizedStepHeight > 3 & ...
                  shortNormalizedStepHeight > 3 & ...
                  abs( log( abs(longStepHeight ./ shortStepHeight))) ...
                      - sqrt(1./longNormalizedStepHeight.^2 ...
                             + 1./shortNormalizedStepHeight.^2) ...
                  < obj.detectionParamsStruct.discontinuityRatioTolerance);

        % If an SPSD was previously detected in any of the newly confirmed
        % locations, then the correction was unsuccessful. In such cases we
        % reject the new SPSD, mark the previously detected one as an
        % "uncorrected suspected discontinuity", and leave the entire time
        % series uncorrected. JT's argument for leaving such targets
        % uncorrected is that multiple detections tend to indicate (1) the
        % feature is likely not an SPSD, and (2) there is something unusual
        % about the target. In such cases it's better to leave the target
        % uncorrected than to risk corrupting it.
        useExcludeWindowHalfWidth = true;
        if ~isempty(obj.resultsStruct) % Skip this step on the first iteration.
            confirmedSpsdTargetIndices = validInd(candidateIndices(confirmed));
            unconfirm = false(size(confirmed)); % flag confirmed candidates to remove from the list.
            for i = 1:length(confirmedSpsdTargetIndices)
                
                % Determine whether any SPSDs were previously detected in 
                % this target.
                keplerId = obj.timeSeriesStruct.parameters.keplerId(confirmedSpsdTargetIndices(i));
                containsPreviousSpsds = ismember(keplerId, obj.resultsStruct.spsds.keplerId);

                if containsPreviousSpsds
                    resultsTargetIndex = find(keplerId == obj.resultsStruct.spsds.keplerId);

                    % Determine proximity (cadences) of the nearest previously
                    % detected SPSD in this target.
                    spsdCadence = maxResponseCadence(confirmedSpsdTargetIndices(i));
                    previousSpsdCadences = cellfun(@(x) (x.spsdCadence), ...
                        obj.resultsStruct.spsds.targets{resultsTargetIndex}.spsd);
                    [minDist, nearestPreviousIndex] = min(abs(previousSpsdCadences - spsdCadence));

                    % If too close, then reject the newly confirmed SPSD and
                    % mark the previously detected one as a
                    % uncorrectedSuspectedDiscontinuity. Set exclude flags.
                    %
                    % NOTE: consider removing the correction here.
                    % Currently the correction is removed when
                    % get_results() is called, but is not removed
                    % internally. In general keeping or removing the
                    % correction at this point will affect successive 
                    % detections and corrections, though whether the
                    % effects are desirable or not is another question.
                    if minDist <= obj.detectionParamsStruct.excludeWindowHalfWidth
                        unconfirm(i) = true;
                        obj.resultsStruct.spsds.targets{resultsTargetIndex}.uncorrectedSuspectedDiscontinuity = true; % Flag the target
                        %obj.resultsStruct.spsds.targets{resultsTargetIndex}.spsd{nearestPreviousIndex}.uncorrectedSuspectedDiscontinuity = true; % Flag the event
                        obj.set_exclude_flags(confirmedSpsdTargetIndices(i), spsdCadence, useExcludeWindowHalfWidth); % Exclude from consideration in the next iteration.
                    end
                end

            end
            confirmed(unconfirm) = []; % Remove these candidates from the confirmed list.
        end
        
        rejected = setdiff(1:nCandidates,confirmed);
        
        % sort parameters (for plotting)
        [~,ord2] = sort(abs(log(abs(longLocalFitCoefs(confirmed,8) ...
            ./ shortLocalFitCoefs(confirmed,6)))),'ascend');
        [~,ord1] = sort(abs(log(abs(longLocalFitCoefs(rejected,8)  ...
            ./ shortLocalFitCoefs(rejected,6)))),'ascend');
        [~,ord0] = sort(shortLocalFitCoefs(:,6),'ascend');


        % Retain locations of rejected candidates.
        if obj.debugObject.flags.retainRejectedCandidates        
            rejectedTargets  = validInd(candidateIndices(rejected));
            rejectedCadences = maxResponseCadence(candidateIndices(rejected));

            eventArr = struct;
            for i = 1:length(rejectedTargets)
                eventArr(i).index    = rejectedTargets(i);
                eventArr(i).cadence = rejectedCadences(i);
            end

            if isfield( obj.debugObject.data, 'rejectedCandidates')
                rejectedCandidates = obj.debugObject.get_data('rejectedCandidates');
                iter = numel(fieldnames(rejectedCandidates)) + 1;
            else
                rejectedCandidates = struct;
                iter = 1;
            end

            newField = strcat('iter',num2str(iter));
            rejectedCandidates.(newField) = eventArr;
            obj.debugObject.set_data('rejectedCandidates', rejectedCandidates);    
        end

%% 5.0 BUILD OUTPUT STRUCTURE
% 
        detectionResultsStruct.spsds.count ...
            = length(confirmed);
        detectionResultsStruct.spsds.index ...
            = validInd(candidateIndices(confirmed));
        detectionResultsStruct.spsds.keplerId ...
            = obj.timeSeriesStruct.parameters.keplerId( ...
                detectionResultsStruct.spsds.index);
        detectionResultsStruct.spsds.keplerMag ...
            = obj.timeSeriesStruct.parameters.keplerMag( ....
                detectionResultsStruct.spsds.index);
        detectionResultsStruct.spsds.spsdCadence ...
            = maxResponseCadence(candidateIndices(confirmed));
        detectionResultsStruct.spsds.longCoefs ...
            = longLocalFitCoefs(confirmed,:);
        detectionResultsStruct.spsds.longStepHeight ...
            = longStepHeight(confirmed);
        detectionResultsStruct.spsds.longMADs ...
            = [longLocalResidualMAD(confirmed); ...
               longLocalDifResidualMAD(confirmed)]';
        detectionResultsStruct.spsds.shortCoefs ...
            = shortLocalFitCoefs(confirmed,:);
        detectionResultsStruct.spsds.shortStepHeight ...
            = shortStepHeight(confirmed);
        detectionResultsStruct.spsds.shortMADs ...
            = [shortLocalResidualMAD(confirmed); ...
               shortLocalDifResidualMAD(confirmed)]';
        detectionResultsStruct.clean.count ...
            = obj.timeSeriesStruct.parameters.nTargets ...
              - detectionResultsStruct.spsds.count;
        detectionResultsStruct.clean.index ...
            = setdiff(1:obj.timeSeriesStruct.parameters.nTargets, ...
                      detectionResultsStruct.spsds.index);
        detectionResultsStruct.clean.keplerId ...
            = obj.timeSeriesStruct.parameters.keplerId( ....
                detectionResultsStruct.clean.index);

    else
        
        detectionResultsStruct.spsds.count           = 0;
        detectionResultsStruct.spsds.index           = [];
        detectionResultsStruct.spsds.keplerId        = [];
        detectionResultsStruct.spsds.keplerMag       = [];
        detectionResultsStruct.spsds.spsdCadence     = 0;
        detectionResultsStruct.spsds.longCoefs       = [];
        detectionResultsStruct.spsds.longStepHeight  = [];
        detectionResultsStruct.spsds.longMADs        = [];
        detectionResultsStruct.spsds.shortCoefs      = [];
        detectionResultsStruct.spsds.shortStepHeight = [];
        detectionResultsStruct.spsds.shortMADs       = [];
        detectionResultsStruct.clean.count ...
            = obj.timeSeriesStruct.parameters.nTargets;
        detectionResultsStruct.clean.index ...
            = 1:obj.timeSeriesStruct.parameters.nTargets;
        detectionResultsStruct.clean.keplerId ...
            = obj.timeSeriesStruct.parameters.keplerId;
              
    end

%% 
% 
end

%% 6.0 RETURN
% 

end



