function [tpsResult, possiblePeriodsInCadences, containsNaNs] = ...
    fold_detection_statistics_time_series(tpsResult, ...
    tpsModuleParameters, possiblePeriodsInCadences, midTimestamp, ...
    foldingParameterStruct, deemphasisParameter, ...
    periodOfMaxMesCadences, ...
    iterationWithPeriodMultiples )
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
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [tpsResults, alerts] =
% fold_detection_statistics_time_series(tpsResult, tpsModuleParameters, 
%     possiblePeriodsInCadences, midTimestamp, iterateWithPeriodMultiples) ;
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Decription:
% The single event detection statistics time series
% (correlationTimeSeries N[n]./normalizationTimeSeries D[n]) contains positive spikes
% corresponding to the time instants of transit occurrences. The individual
% events (spikes in the detection statistics) may not be detectable (might
% not cross the threshold of 7sigma), but we know that these transits occur in
% a precisely periodic fashion and we can utilize this a priori knowledge
% to form multiple event detection statistics. The total detection
% statistic or multiple event detection statistics is determined from the
% components of the single event transit statistic by folding and summing
% the single event statistics at each trial period and trial phase and
% choosing the maximum.
%
% Single event statistics time series T[n] = N[n]/sqrt(D[n]
%
% The multiple event statistics can then be written for a trial orbital
% period, t, giving rise to periodic transits at time instants {t1, t2,
% � , tN } as:
%   multiple event statistics = ?N[i]/?sqrt(D[i] where i = {t1, t2,.., tN }
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        
cadencesPerDay                 = tpsModuleParameters.cadencesPerDay;
superResolutionFactor          = tpsModuleParameters.superResolutionFactor;
searchTransitThreshold         = tpsModuleParameters.searchTransitThreshold ;
usePolyFitTransitModel         = tpsModuleParameters.usePolyFitTransitModel ;
searchPeriodStepControlFactor  = tpsModuleParameters.searchPeriodStepControlFactor ;
periodOfMaxMesCadences         = periodOfMaxMesCadences * superResolutionFactor ;
maxLoopCount                   = tpsModuleParameters.maxFoldingLoopCount ;


transitLengthSuperResolutionCadences = round( tpsResult.trialTransitPulseInHours * ...
    get_unit_conversion('hour2day') * cadencesPerDay ) * superResolutionFactor ;

totalLoopCount = 0 ;
periodCount    = 0 ;
RSLoopCount    = 0 ;
tpsResult.periodCount = 0 ;
tpsResult.removedFeatureCount = 0 ;


valueLatched = false ;

previousBestPeriod = -1 ;

ses = tpsResult.correlationTimeSeries ./ tpsResult.normalizationTimeSeries ;

if ~iterationWithPeriodMultiples
    tpsResult.detectedFeatureCount = count_features_in_ses( ses, searchTransitThreshold, ...
        tpsModuleParameters.minSesInMesCount ) ;
end

% initialize the robustFitExtraParameters struct

  robustFitExtraParameters.minSesCount         = tpsModuleParameters.minSesInMesCount ;
  robustFitExtraParameters.gappingThreshold    = ...
      tpsModuleParameters.robustWeightGappingThreshold ;
  robustFitExtraParameters.previousFittedDepth = -1 ;
  robustFitExtraParameters.usePolyFitTransitModel = usePolyFitTransitModel ;
  
% capture the initial cadence weights, which contain only weights based on events in the
% cadenceTimes indicators

  originalWeightHighResolution = tpsResult.deemphasisWeightSuperResolution ;
  originalWeight               = tpsResult.deemphasisWeight ;
  originalDeemphasisParameter  = deemphasisParameter ;
  
% define the "latched" weights as initially equal to the input ones  

  latchedDeemphasisWeightSuperResolution = tpsResult.deemphasisWeightSuperResolution ;
  latchedDeemphasisWeight = tpsResult.deemphasisWeight ;
  
% we obviously want to do the folding across all periods on iteration 1...

  foldAcrossAllPeriods = true ;
 
% optional argument -- specifies which of the nested calls to this function we are using

  if ~exist('iterationWithPeriodMultiples','var') || ...
          isempty( iterationWithPeriodMultiples )
      iterationWithPeriodMultiples = false ;
  end

% first step: perform the folding across all periods and phases, saving the max MES at
% each period

% generate whitening coefficients for this flux time series at this pulse duration

waveletObject = tpsResult.waveletObject ;

% glue some more stuff into the foldingParameterStruct

if ~iterationWithPeriodMultiples
    foldingParameterStruct.mScale        = get( waveletObject, 'filterScale' ) + 1 ;
    foldingParameterStruct.whitenedFlux  = apply_whitening_to_time_series( waveletObject ) ;
    foldingParameterStruct.superResolutionFactor = ...
        tpsModuleParameters.superResolutionFactor ;
    foldingParameterStruct.robustStatisticConvergenceTolerance = ...
        tpsModuleParameters.robustStatisticConvergenceTolerance ;
    
    foldingParameterStruct.chiSquare1Threshold = tpsModuleParameters.chiSquare1Threshold ;
    foldingParameterStruct.chiSquare2Threshold = tpsModuleParameters.chiSquare2Threshold ;
end
maxRemovedFeatureCount = tpsModuleParameters.maxRemovedFeatureCount ;

% now we loop until we find a combination of period and phase which meets all requirements
% for being considered a transit, or we exhaust all possible combinations on the basis of
% the multiple event statistic falling below threshold

searchComplete = false ;
searchPerformed = false ;

while ~searchComplete

%   Note that in the current implementation we only fold across all periods at the start
%   of the process here.  In the future we may decide to change this, so the fold across
%   periods will be put inside the while loop with a conditional.

    if foldAcrossAllPeriods
        [foldedStatisticAtTrialPeriods,  phaseOfMaxMes, possiblePeriodsInCadences, ...
            foldedStatisticMinAtTrialPeriods, phaseLagOfMinStatistic ]  = ...
            fold_statistics_at_trial_periods(tpsResult, tpsModuleParameters, ...
            possiblePeriodsInCadences );
        possiblePeriodsForThisStar = possiblePeriodsInCadences ;
        foldedStatisticsForThisStar = foldedStatisticAtTrialPeriods ;
        foldAcrossAllPeriods = false ;
        clear validPhaseIndicator ;
    end
    
%   If all of the MES values are zero or less (which so far has only ever happened in
%   smoke tests), then many of the search assumptions are violated and we need to handle
%   that case somewhat differently

    if all( foldedStatisticAtTrialPeriods <= 0 )
        searchComplete = true ;
        valueLatched = true ;
        bestMultipleEventStatistic = -1 ;
        totalLoopCount = 1 ;
        validPhaseIndicator = [] ;
        containsNaNs = false ;
        bestOrbitalPeriodInCadences = possiblePeriodsInCadences(1) ;
        warning('tps:foldDetectionStatisticsTimeSeries:noSearchPossible', ...
            'fold_detection_statistics_time_series:  no search possible at this pulse duration') ;
    else
        
        searchPerformed = true ;
    
        if iterationWithPeriodMultiples
            indexOfBestPeriod = find_last_max_value( foldedStatisticsForThisStar ) ;
        else
            indexOfBestPeriod = locate_center_of_asymmetric_peak( ...
                foldedStatisticsForThisStar, possiblePeriodsForThisStar );
        end

        bestOrbitalPeriodInCadences  = possiblePeriodsForThisStar(indexOfBestPeriod) ;
        if bestOrbitalPeriodInCadences ~= previousBestPeriod
            periodCount = periodCount + 1 ;
            previousBestPeriod = bestOrbitalPeriodInCadences ;
            clear validPhaseIndicator ;
        end
        bestMultipleEventStatistic   = foldedStatisticsForThisStar( indexOfBestPeriod ) ;

%       capture the strongest overall multiple event statistic (ie, the one returned in
%       the first iteration of this search, regardless of whether it's a TCE)

        if tpsResult.strongestOverallMultipleEventStatistic == -1
            tpsResult.strongestOverallMultipleEventStatistic = bestMultipleEventStatistic ;
        end
        
    end % folded statistics all <= 0 condition

%   set logicals relevant to controlling the looping process
    
%   When can we terminate the search?  We can do this under two circumstances: first, if 
%   the max MES remaining in the MES vs Period plot is below threshold (in this case, no
%   amount of searching in periods where max MES is even lower than the current one is
%   going to give a candidate); second, if the max MES remaining in the MES vs
%   period plot is below the current latched value (because this means that we're not
%   going to get a stronger candidate by searching MES values which are lower than the one 
%   we've got).  

    if bestMultipleEventStatistic < tpsResult.maxMultipleEventStatistic || ...
            bestMultipleEventStatistic < searchTransitThreshold
        searchComplete = true ;
    end
    
%   if the inner while loop has never executed, we need to generate the folded statistic
%   at the current best period, all phases; we also need to do this if the search is not
%   yet complete, regardless of how many times the inner while loop has run
    
    if totalLoopCount == 0 || ~searchComplete || ~exist('validPhaseIndicator','var')
        [foldedStatisticAtTrialPhases, phaseLagInCadences, containsNaNs] = ...
            fold_statistics_at_trial_phases(tpsResult, ...
            bestOrbitalPeriodInCadences, tpsModuleParameters);
        foldedStatisticAtPhasesComplete = foldedStatisticAtTrialPhases ;
        if ~exist('validPhaseIndicator','var')
            validPhaseIndicator = ones(size( foldedStatisticAtTrialPhases )) ;
        end
    end
    
%   Inner loop:  here we are looping and examining period / phase combinations without
%   bothering to refold at any period.  We want to exit / bypass this loop under three
%   conditions:
%   1.  The search is complete -- we know that we have already found the strongest
%       detection candidate for this target on this pulse duration
%   2.  The robust statistic has deweighted some cadences, in which case we need to refold
%       at this period with the new weights
%   3.  The search at this period has completed, which means that either
%       a.  we found a new best detection candidate and latched it, or
%       b.  we eliminated all detection candidates with MES < the current latched value.
%   Condition (1) is indicated by the searchComplete logical variable; condition 2 by the
%   cadencesDeweighted logical variable; condition 3 by the doneWithThisPeriod
%   logical variable.

    doneWithThisPeriod = false ;
    cadencesDeweighted = false ;  
    

%   if this period has any phases which yield MES > the strongest one latched so far, then
%   we need to search this period until MES falls below the latched value, or else a new
%   value is latched (which is indicated by best statistic being equal to latched
%   statistic)

    while ~searchComplete && ~doneWithThisPeriod && ~cadencesDeweighted && ...
            ~foldAcrossAllPeriods
        
        if totalLoopCount >= maxLoopCount
            disp([datestr(now), ': Trial transit pulse duration ', ...
                num2str(tpsResult.trialTransitPulseInHours), ...
                ' hours, exceeded max loop count of ', num2str(maxLoopCount), ...
                ', exiting folding loop']) ;
            searchComplete = true ;
            tpsResult.exitedOnLoopCountLimit = true ;
            break ;
        end
        foldedStatisticAtTrialPhases = foldedStatisticAtPhasesComplete .* ...
            validPhaseIndicator ;
        totalLoopCount = totalLoopCount + 1 ;
        if mod(totalLoopCount,50) == 0
            disp([datestr(now),': Trial transit pulse duration ', ...
                num2str(tpsResult.trialTransitPulseInHours),...
                ' hours, on folding iteration ',num2str(totalLoopCount),...
                ', latched MES == ', num2str(tpsResult.maxMultipleEventStatistic)]) ;
        end
        RSLoopCount = RSLoopCount + 1 ;
        indexOfBestPhase = locate_center_of_asymmetric_peak( ...
            foldedStatisticAtTrialPhases);

        bestPhaseInCadences = phaseLagInCadences(indexOfBestPhase);
        bestMultipleEventStatistic = foldedStatisticAtTrialPhases(indexOfBestPhase);
        
%       if the MES at this period and phase is below the threshold, we already know that
%       there is no point continuing to search this period for a detection, since on each
%       period we search the phases from largest to smallest MES
        
        if bestMultipleEventStatistic < searchTransitThreshold
            doneWithThisPeriod = true ;
        end
        
        [isTransitCandidate,robustInformationStruct] = get_transit_candidate_status( ...
            tpsResult, ...
            bestMultipleEventStatistic, foldingParameterStruct, ...
            tpsModuleParameters, bestOrbitalPeriodInCadences, bestPhaseInCadences, ...
            robustFitExtraParameters ) ;
        
%       handle the various pieces of information which came back through the robust
%       information struct

        robustFitExtraParameters.previousFittedDepth = ...
            robustInformationStruct.previousFittedDepth ;
        
%       if we ever, at any point in all this looping, apply the robust statistic veto, we
%       want to latch that value and hold onto it
        
        tpsResult.robustStatisticVetoApplied = ...
            robustInformationStruct.robustStatisticVetoApplied | ...
            tpsResult.robustStatisticVetoApplied ;
        
%       if there was a MES here which got rejected, and it's harmonically related to the
%       period of the strongest detection thus far, it means that there's a problem here
%       in which the mismatch between the trial transit pulse duration and the actual
%       duration of the strongest transits will cause the looper to spin its wheels
%       hopelessly; prevent that now

        periodRatio = periodOfMaxMesCadences / bestOrbitalPeriodInCadences ;
        if periodRatio > 1
            scaledPeriodOfMaxMesCadences = periodOfMaxMesCadences / round( periodRatio ) ;
        else
            scaledPeriodOfMaxMesCadences = periodOfMaxMesCadences * round( 1/periodRatio ) ;
        end
        dPeriod = abs( scaledPeriodOfMaxMesCadences - bestOrbitalPeriodInCadences ) ;
        periodCorrelation = 1 - dPeriod / (4*transitLengthSuperResolutionCadences) ;
        
        
        
        if bestMultipleEventStatistic >= searchTransitThreshold && ...
                ~isTransitCandidate                             && ...
                ~iterationWithPeriodMultiples                   && ...
                periodCorrelation >= searchPeriodStepControlFactor
            searchComplete = true ;
        
%       Are there features which need to be removed from the search entirely?  We remove
%       features when all of the following are true:
%       -> MES is above threshold
%       -> isTransitCandidate is false
%       -> the max # of features for removal is not yet exhausted
%       In this case, it is also necessary to re-do folding across all periods, so we have
%       to set the appropriate flag for that.

        elseif bestMultipleEventStatistic >= searchTransitThreshold && ...
                ~isTransitCandidate                              && ...
                tpsResult.removedFeatureCount < maxRemovedFeatureCount
            tpsResult.removedFeatureCount = tpsResult.removedFeatureCount + 1 ;
            foldAcrossAllPeriods = true ;
            [indexHiRes,sesValues] = find_index_of_ses_added_to_yield_mes( ...
                bestOrbitalPeriodInCadences / superResolutionFactor, ...
                bestPhaseInCadences / superResolutionFactor, ...
                superResolutionFactor, ...
                tpsResult.correlationTimeSeriesHiRes, ...
                tpsResult.normalizationTimeSeriesHiRes, ...
                tpsResult.deemphasisWeightSuperResolution ) ;
            [~,pointerToMaxSes] = max(sesValues) ;
            indexOfMaxSes = round( indexHiRes(pointerToMaxSes) / superResolutionFactor ) ;

%           Here we need to find the extent of the feature, defined as where the SES falls
%           below the search threshold, searching forwards and backwards from the current
%           index.

            [deemphasisStart,deemphasisEnd] = find_range_of_ses_peak( ses, indexOfMaxSes, ...
                searchTransitThreshold ) ;
            cadencesToRemove = deemphasisStart:deemphasisEnd ;
            [originalDeemphasisParameterSuperResolution, originalDeemphasisParameter] = ...
                collect_cadences_to_deemphasize( originalDeemphasisParameter, ...
                superResolutionFactor, cadencesToRemove(:) ) ;
            originalWeightHighResolution = convert_deemphasis_parameter_to_weight( ...
                originalDeemphasisParameterSuperResolution ) ;
            originalWeight = convert_deemphasis_parameter_to_weight( ...
                originalDeemphasisParameter ) ;
            tpsResult.deemphasisWeight = originalWeight ;
            tpsResult.deemphasisWeightSuperResolution = originalWeightHighResolution ;
            deemphasisParameter = originalDeemphasisParameter ;
        
%       if there are cadences which need to be deweighted based on the robust statistic,
%       we can handle that here.  Also, inform master execution flow that we need another
%       iteration of phase folding because of the deweighted cadences

        elseif ~isempty( robustInformationStruct.cadencesToRemove ) && ...
                ~isTransitCandidate
            [deemphasisParameterSuperResolution, deemphasisParameter] = ...
                collect_cadences_to_deemphasize( deemphasisParameter, ...
                superResolutionFactor, robustInformationStruct.cadencesToRemove ) ;
            tpsResult.deemphasisWeightSuperResolution = ...
                convert_deemphasis_parameter_to_weight( deemphasisParameterSuperResolution ) ;
            tpsResult.deemphasisWeight = ...
                convert_deemphasis_parameter_to_weight( deemphasisParameter ) ;
            cadencesDeweighted = true ;
            
        else
            
%           In this case, we are done deweighting cadences for this period / phase 
%           combination.  Whatever MES and RS values we have now are here to stay.  We can
%           therefore decide whether to latch this value, and perform preparations for
%           going on to either the next period (if this phase has a value which is worth
%           latching) or the next phase at this period (if this phase isn't worth
%           latching)
            
            robustFitExtraParameters.previousFittedDepth = -1 ;
            cadencesDeweighted = false ;
        
%           if this is a good transit candidate, and the MES is greater than the current
%           latched value, then we need to replace the current latched value with the
%           values at this combination of period and phase; we also need to do this if the
%           largest remaining max MES has fallen below the MES threshold.  Note that we
%           cannot yet "latch" the deemphasis weights because the values in the tpsResult
%           struct are used to compute MES, RS, etc; so we have to capture them now, reset
%           to their pristine values, and later glue them into place if we want them.

            if bestMultipleEventStatistic > tpsResult.maxMultipleEventStatistic && ...
                    (isTransitCandidate || ...
                    bestMultipleEventStatistic < searchTransitThreshold )

                tpsResult = latch_this_period_and_phase( tpsResult, foldingParameterStruct, ...
                    tpsModuleParameters, ...
                    bestMultipleEventStatistic, bestOrbitalPeriodInCadences, ...
                    RSLoopCount, periodCount, ...
                    bestPhaseInCadences, phaseLagInCadences, midTimestamp, ...
                    foldedStatisticAtPhasesComplete, validPhaseIndicator ) ;
                latchedDeemphasisWeightSuperResolution = ...
                    tpsResult.deemphasisWeightSuperResolution ;
                latchedDeemphasisWeight = tpsResult.deemphasisWeight ;
                valueLatched = true ;
                
%               since we search each period from the phase with max MES to the phase with
%               min MES, if we are here then we can stop searching this period:  all of
%               the other phases at this period have smaller MES, and either the current
%               phase is the strongest detection so far (in which case all of the
%               weaker-MES candiates at this period are uninteresting), or we've already
%               fallen below the MES threshold (in which case all of the weaker-MES
%               candidates at this period are uninteresting).
                
                doneWithThisPeriod = true ;
            
%           in the event that the MES at this period / phase combination is above
%           threshold, BUT it was vetoed by RS or other vetoes, then it's possible that
%           there's a lower-MES event at this period which will still be strong enough to
%           be the detection we want to record and which won't be vetoed.  We search for
%           it by deleting the peak in the MES vs phase which we are currently examining,
%           and going back to look at the next-largest peak

            else

               peakCenter = locate_center_of_asymmetric_peak( ...
                    foldedStatisticAtTrialPhases ) ;
               centerLag = phaseLagInCadences(peakCenter) ;
               [~,edgeIndex] = min( abs(phaseLagInCadences - ...
                   (centerLag+transitLengthSuperResolutionCadences)) ) ;
               peakRange = edgeIndex - peakCenter ;
               [peakStart,peakEnd] = determine_range_of_asymmetric_peak( ...
                    foldedStatisticAtTrialPhases, peakRange ) ;
                
                validPhaseIndicator( peakStart:peakEnd ) = 0 ;

            end
            
%           reset the RSLoopCount to zero 
            
            RSLoopCount = 0 ;
            
        end % conditional on whether there are additional cadences to deemphasize
        
    end % while loop on best statistic > latched statistic

%   if the search is not complete, then we need to knock out the current peak in the 
%   MES vs period vector and look at the period which produces the next-smallest value

    if ~searchComplete && doneWithThisPeriod
        tpsResult.deemphasisWeightSuperResolution = ...
            originalWeightHighResolution ;
        tpsResult.deemphasisWeight = originalWeight ;
        clear validPhaseIndicator ;
        deemphasisParameter = originalDeemphasisParameter ;
        if iterationWithPeriodMultiples
            peakStart = indexOfBestPeriod ;
            peakEnd   = indexOfBestPeriod ;
        else
            peakCenter = locate_center_of_asymmetric_peak( ...
                foldedStatisticsForThisStar ) ;
            centerPeriod = possiblePeriodsInCadences(peakCenter) ;
            [~,edgeIndex] = min( abs(possiblePeriodsInCadences - ...
               (centerPeriod+transitLengthSuperResolutionCadences)) ) ;
            peakRange = edgeIndex - peakCenter ;
            [peakStart,peakEnd] = determine_range_of_asymmetric_peak( ...
                foldedStatisticsForThisStar, peakRange ) ;
        end
        foldedStatisticsForThisStar(peakStart:peakEnd) = 0 ;
    end
    
end % while search not complete

% if no latching of values ever occurred at all, latch the current value -- this can only
% happen when there is no MES above threshold in the target.  We need only do this on the
% first pass through this function, not the second.

if ~valueLatched && ~iterationWithPeriodMultiples
        foldedStatisticAtTrialPhases = foldedStatisticAtPhasesComplete .* ...
            validPhaseIndicator ;
        indexOfBestPhase = locate_center_of_asymmetric_peak( ...
            foldedStatisticAtTrialPhases);

        bestPhaseInCadences = phaseLagInCadences(indexOfBestPhase);
        bestMultipleEventStatistic = foldedStatisticAtTrialPhases(indexOfBestPhase);

    tpsResult = latch_this_period_and_phase( tpsResult, foldingParameterStruct, ...
        tpsModuleParameters, ...
        bestMultipleEventStatistic, bestOrbitalPeriodInCadences, ...
        RSLoopCount, periodCount, ...
        bestPhaseInCadences, phaseLagInCadences, midTimestamp, ...
        foldedStatisticAtPhasesComplete, validPhaseIndicator ) ;
end

% alternately, if a value was latched at some point, put the latched deemphasis
% information back into the results struct now

if valueLatched
    tpsResult.deemphasisWeightSuperResolution = ...
        latchedDeemphasisWeightSuperResolution ;
    tpsResult.deemphasisWeight = latchedDeemphasisWeight ;
end

% add the total number of periods to tpsResult as a second entry in the vector

  tpsResult.totalPeriodCount = periodCount ;
  tpsResult.totalLoopCount = totalLoopCount ;

% in the case of a near-circular EB, multi-planet search may identify a signal
% which is 2x the actual period (because of the gaps in the light curve from
% removing the primary eclipse).  To help identify this occurrence, we need to be
% able to look at the MES at multiples of the period which produced the best detection.
% The easiest way to do this is to re-run this function with only the list of new periods,
% and with the flag for the second iteration set to true

additionalPeriods = ...
    2*bestOrbitalPeriodInCadences:bestOrbitalPeriodInCadences:max(possiblePeriodsInCadences) ;
additionalPeriods = additionalPeriods(:) ;

if ~isempty(additionalPeriods) && ~iterationWithPeriodMultiples && ...
        tpsResult.isPlanetACandidate

%   If any of the new periods being searched has the exact same MES as the one which is
%   latched, we want it to latch the new one and discard the old one.  Because of the
%   conditions used for the search looper above, the easiest way to do this is to minutely
%   reduce the value of the MES in the result

    originalTpsResult = tpsResult ; % cache the original version here

    tpsResult.maxMultipleEventStatistic = originalTpsResult.maxMultipleEventStatistic * ...
        (1 - sqrt(eps('double'))) ;
    newMaxMes = tpsResult.maxMultipleEventStatistic ;
    
    tpsResult.deemphasisWeightSuperResolution = originalWeightHighResolution;
    tpsResult.deemphasisWeight = originalWeight ;
    
    oldLoopCount   = tpsResult.totalLoopCount ;
    
    tpsResult = fold_detection_statistics_time_series( tpsResult, tpsModuleParameters, ...
        additionalPeriods, midTimestamp, foldingParameterStruct, ...
        deemphasisParameter, periodOfMaxMesCadences, true ) ;
    additionalStatistics = tpsResult.foldedStatisticAtTrialPeriods ;
    
%   if no better MES found, undo the kludge which allowed the search to go in the first 
%   place; otherwise, the new loop count needs to be updated with the # of iterations
%   which occurred before the run of additional periods.  In this case we can also capture
%   the cadence weights
    
    if (tpsResult.maxMultipleEventStatistic == newMaxMes)
        originalTpsResult.totalPeriodCount = originalTpsResult.totalPeriodCount + ...
            tpsResult.totalPeriodCount ;
        tpsResult = originalTpsResult ;
    else
        tpsResult.periodCount = tpsResult.periodCount + ...
            originalTpsResult.totalPeriodCount ;
        tpsResult.totalPeriodCount = tpsResult.totalPeriodCount + ...
            originalTpsResult.totalPeriodCount ;
    end
    tpsResult.totalLoopCount = tpsResult.totalLoopCount + oldLoopCount ;
    
%   incorporate the new statistics into the MES vs period vector, and the periods also 
%   need to be incorporated    
    
    possiblePeriodsForThisStar = [possiblePeriodsInCadences ; ...
        additionalPeriods] ;
    foldedStatisticsForThisStar = [foldedStatisticAtTrialPeriods ; ...
        additionalStatistics] ;
    [possiblePeriodsForThisStar, sortKey] = sort(possiblePeriodsForThisStar) ;
    foldedStatisticsForThisStar = foldedStatisticsForThisStar( sortKey ) ;
    
else
    possiblePeriodsForThisStar = possiblePeriodsInCadences ;
    foldedStatisticsForThisStar = foldedStatisticAtTrialPeriods ;
end
    
% capture the final vector of periods and MES values

tpsResult.foldedStatisticAtTrialPeriods = foldedStatisticsForThisStar ;
tpsResult.possiblePeriodsInCadences     = possiblePeriodsForThisStar/ superResolutionFactor ; 

% there's a lot of value latching below which only makes sense if any search was even
% performed.  So we will use the searchPerformed logical to determine what to do next

if searchPerformed

    % capture the microlensing parameters -- here we make a much simpler test, and use only
    % the original vectors of MES and period


    indexOfBestMicrolensPeriod = ...
        locate_center_of_asymmetric_peak(-foldedStatisticMinAtTrialPeriods);   
    bestMinMultipleEventStatistic = ...
        foldedStatisticMinAtTrialPeriods(indexOfBestMicrolensPeriod);

    bestMicrolensOrbitalPeriodInCadences = ...
        possiblePeriodsInCadences(indexOfBestMicrolensPeriod) ;
    bestMicrolensOrbitalPeriodInDays = ...
        bestMicrolensOrbitalPeriodInCadences/(cadencesPerDay*superResolutionFactor);

    bestMicrolensPhaseInCadences = phaseLagOfMinStatistic(indexOfBestMicrolensPeriod);
    bestMicrolensPhaseInDays = (bestMicrolensPhaseInCadences-superResolutionFactor)/ ...
        (cadencesPerDay*superResolutionFactor);

    tpsResult.bestMicrolensOrbitalPeriodInCadences = ...
        bestMicrolensOrbitalPeriodInCadences/superResolutionFactor;
    tpsResult.detectedMicrolensOrbitalPeriodInDays = bestMicrolensOrbitalPeriodInDays;
    tpsResult.bestMicrolensPhaseInCadences = bestMicrolensPhaseInCadences/superResolutionFactor;
    tpsResult.timeToFirstMicrolensInDays = bestMicrolensPhaseInDays;
    tpsResult.timeOfFirstMicrolensInMjd = midTimestamp + bestMicrolensPhaseInDays;
    tpsResult.minMultipleEventStatistic = bestMinMultipleEventStatistic;

    % find and capture the SES which were folded into the current MES

    [indexOfSesAdded, sesCombinedToYieldMes] = find_index_of_ses_added_to_yield_mes( ...
        tpsResult, superResolutionFactor);

    tpsResult.indexOfSesAdded = indexOfSesAdded;
    tpsResult.sesCombinedToYieldMes = sesCombinedToYieldMes;

    % compute and capture the chi-square values

    tpsResult = compute_chisquare_veto( tpsResult, tpsModuleParameters, ...
        foldingParameterStruct, tpsResult.maxMultipleEventStatistic ) ;

    % TPS must set the orbital period to -1 when there is only one strong event giving rise to 
    % a TCE 

    if(length(indexOfSesAdded(sesCombinedToYieldMes ~= 0)) < 2)
        correlationTimeSeriesHiRes = tpsResult.correlationTimeSeriesHiRes ;
        normalizationTimeSeriesHiRes = tpsResult.normalizationTimeSeriesHiRes ;
        deemphasisWeights = tpsResult.deemphasisWeightSuperResolution ;
        isForSes = true ;

        % apply weights
        [correlationTimeSeriesHiRes, normalizationTimeSeriesHiRes] = ...
            apply_deemphasis_weights( correlationTimeSeriesHiRes, ...
            normalizationTimeSeriesHiRes, deemphasisWeights, isForSes );

        ses = correlationTimeSeriesHiRes./normalizationTimeSeriesHiRes;
        sesSuperResolutionCadence = find(ses==max(ses),1,'first');
        tpsResult.bestOrbitalPeriodInCadences = -1;
        tpsResult.detectedOrbitalPeriodInDays = -1;
        tpsResult.bestPhaseInCadences = ...
            sesSuperResolutionCadence / superResolutionFactor ;
        tpsResult.timeToFirstTransitInDays = ...
            tpsResult.bestPhaseInCadences / cadencesPerDay ;
        tpsResult.timeOfFirstTransitInMjd = ...
            tpsResult.timeToFirstTransitInDays + ...
            midTimestamp ;   
    end
    
end % searchPerformed conditional

return

%=========================================================================================
%=========================================================================================
%=========================================================================================
%=========================================================================================
%=========================================================================================
%=========================================================================================

%--------------------------------------------------------------------------
% get the indices/cadences of single event statistics components combined to yield
% maximum multiple event statistic; remember to set the cadences that were
% deemphasized to -1
%--------------------------------------------------------------------------

function [indexAdded, sesCombinedToYieldMes] = ...
    find_index_of_ses_added_to_yield_mes(varargin)

% this can take either tpsResults and superResolutionFactor, or else all 6 real variables
% as their arguments
if nargin == 2
    tpsResults = varargin{1} ;
    superResolutionFactor = varargin{2} ;
    bestPhaseInCadences = tpsResults.bestPhaseInCadences*superResolutionFactor;
    bestOrbitalPeriodInCadences = (tpsResults.bestOrbitalPeriodInCadences)*...
        superResolutionFactor;
    deemphasisWeights = tpsResults.deemphasisWeightSuperResolution ;
    correlationTimeSeriesHiRes = tpsResults.correlationTimeSeriesHiRes ;
    normalizationTimeSeriesHiRes = tpsResults.normalizationTimeSeriesHiRes ;
elseif nargin == 6
    superResolutionFactor = varargin{3} ;
    bestOrbitalPeriodInCadences = varargin{1} * superResolutionFactor ;
    bestPhaseInCadences = varargin{2} * superResolutionFactor ;
    correlationTimeSeriesHiRes = varargin{4} ;
    normalizationTimeSeriesHiRes = varargin{5} ;
    deemphasisWeights = varargin{6} ;
else
    error('tps:find_index_of_ses_added_to_yield_mes:invalidArguments', ...
        'find_index_of_ses_added_to_yield_mes:2 or 6 arguments required') ;
end
isForSes = true ;

 % apply weights
[correlationTimeSeriesHiRes, normalizationTimeSeriesHiRes] = ...
    apply_deemphasis_weights( correlationTimeSeriesHiRes, ...
    normalizationTimeSeriesHiRes, deemphasisWeights, isForSes );

[indexAdded, sesCombinedToYieldMes] = find_ses_in_mes( ...
    correlationTimeSeriesHiRes, normalizationTimeSeriesHiRes, ...
    bestOrbitalPeriodInCadences, bestPhaseInCadences ) ;

% convert from zero-based indexing to one-based
indexAdded = indexAdded + 1 ;

return

%=========================================================================================

% subfunction which determines whether the current period and phase constitute a valid
% detection, based on whatever the current criteria are

function [isTransitCandidate,robustFitInformationStruct] = get_transit_candidate_status( ...
    tpsResult, ...
    multipleEventStatistic, foldingParameterStruct, ...
    tpsModuleParameters, bestOrbitalPeriodInCadences, bestPhaseInCadences, ...
    robustFitExtraParameters )

% set default return

  isTransitCandidate = false ;
        
% extract useful module parameters

robustStatisticThreshold       = tpsModuleParameters.robustStatisticThreshold ;
superResolutionFactor          = tpsModuleParameters.superResolutionFactor ;
bestOrbitalPeriod              = bestOrbitalPeriodInCadences / superResolutionFactor ;

bestPhase                      = bestPhaseInCadences / superResolutionFactor ;

% compute the robust statistic -- note that this expects the period and phase to be in
% normal resolution cadences, while they are passed into this function in super-resolution
% cadences

  [robustStatistic,robustFitInformationStruct] = compute_robust_statistic( tpsResult, ...
      foldingParameterStruct, bestOrbitalPeriod, bestPhase, ...
      tpsResult.deemphasisWeight, robustFitExtraParameters ) ;
  
% in order to speed execution, we will only compute the chi-squares when the robust
% statistic threshold is passed

  if robustStatistic >= robustStatisticThreshold
      
      fittedDepth = robustFitInformationStruct.previousFittedDepth ;

%     compute the chi-square values and threshold on them as well

      [tpsResult.indexOfSesAdded, tpsResult.sesCombinedToYieldMes] = ...
          find_index_of_ses_added_to_yield_mes( bestOrbitalPeriod, bestPhase, ...
          superResolutionFactor, tpsResult.correlationTimeSeriesHiRes, ...
          tpsResult.normalizationTimeSeriesHiRes, ...
          tpsResult.deemphasisWeightSuperResolution ) ;

      [tpsResult,chiSquare1Ok,chiSquare2Ok] = compute_chisquare_veto( tpsResult, ...
          tpsModuleParameters, foldingParameterStruct, ...
          multipleEventStatistic, fittedDepth ) ;
      if chiSquare1Ok && chiSquare2Ok
          isTransitCandidate = true ;
      end
      
  end
  
return
  
%=========================================================================================

% subfunction for calculation of the robust statistic

function [robustStatistic,robustInformationStruct] = compute_robust_statistic( tpsResult, ...
    foldingParameterStruct, ...
    bestOrbitalPeriodInCadences, bestPhaseInCadences, deemphasisWeight, ...
    robustFitExtraParameters )

% unpack parameters

waveletObject                  = tpsResult.waveletObject ;
trialTransitDurationInCadences = foldingParameterStruct.trialTransitDurationInCadences ;
nCadences                      = foldingParameterStruct.nCadences ;
whitenedFluxTimeSeries         = foldingParameterStruct.whitenedFlux(1:nCadences) ;
superResolutionFactor          = foldingParameterStruct.superResolutionFactor ;

minSesCount                    = robustFitExtraParameters.minSesCount ;
gappingThreshold               = robustFitExtraParameters.gappingThreshold ;
previousFittedDepth            = robustFitExtraParameters.previousFittedDepth ;
usePolyFitTransitModel         = robustFitExtraParameters.usePolyFitTransitModel ;
 
numModelCadences = foldingParameterStruct.nCadencesExtended ;

robustInformationStruct.cadencesToRemove = [] ;
robustInformationStruct.robustFitFail = false ;
robustInformationStruct.fitSinglePulse = false ;
robustInformationStruct.robustStatisticVetoApplied = false ;
robustInformationStruct.previousFittedDepth = 0 ;
robustInformationStruct.previousPeriod = 0 ;

% determine which cadences, if any, need to be removed based on the robust weights and
% other criteria.  Start by getting the cadences which contribute to the MES, and the SES
% values

[indexOfSesInMes, sesCombinedToYieldMes] = find_index_of_ses_added_to_yield_mes( bestOrbitalPeriodInCadences, ...
   bestPhaseInCadences, superResolutionFactor, ...
   tpsResult.correlationTimeSeriesHiRes, tpsResult.normalizationTimeSeriesHiRes, ...
   tpsResult.deemphasisWeightSuperResolution ) ;

% set up the superResolutionObject
scalingFilterCoeffts = get( waveletObject, 'h0' ) ;
superResolutionStruct = struct('superResolutionFactor', superResolutionFactor, ...
    'pulseDurationInCadences', trialTransitDurationInCadences, 'usePolyFitTransitModel', ...
    usePolyFitTransitModel ) ;
superResolutionObject = superResolutionClass( superResolutionStruct, scalingFilterCoeffts ) ;
superResolutionObject = set_statistics_time_series_shift_length( superResolutionObject) ;

% generate the trial pulse train
transitModel = generate_trial_transit_pulse_train( superResolutionObject, ...
    indexOfSesInMes(sesCombinedToYieldMes ~= 0), nCadences ) ;
windowIndicesOrig = find(transitModel ~= 0) ;
transitModel((nCadences+1):numModelCadences) = 0 ;

% generate whitened flux and whitened transit model 

whitenedTransitModel = apply_whitening_to_time_series( waveletObject, transitModel ) ;

% Apply the deemphasis weights with cadence by cadence
% multiplication with the whitened flux and whitened model

whitenedFluxTimeSeries = whitenedFluxTimeSeries.*deemphasisWeight ;
whitenedTransitModel = whitenedTransitModel.*deemphasisWeight ;

% Now get the rectangular window indices and remove cadences with 
% deemphasis weights*data near zero

windowIndices = windowIndicesOrig(abs(whitenedFluxTimeSeries(windowIndicesOrig))>sqrt(eps)) ;

% robustfit the whitened, windowed model transit to the
% whitened, windowed flux and compute the robust statistic 

% Note that robustfit can fail if there's not enough points to do the fit,
% or potentially under other circumstances.  We want to treat a failure
% there as equivalent to robust statistic == 0 and continue, not error
% out.  Thus the try-catch block,

try

    [fittedTransitDepth, stats] = robustfit(whitenedTransitModel(windowIndices), ...
        whitenedFluxTimeSeries(windowIndices), [], [], 'off') ;
    if isempty(stats.covb)
        % poor fit
        fittedTransitDepthSigma = 1 ;
    else
        fittedTransitDepthSigma = sqrt(stats.covb) ;
    end
    robustStatistic = sum(...
        whitenedTransitModel(windowIndices) .* ...
        whitenedFluxTimeSeries(windowIndices).* ...
        stats.w ) / sqrt(sum(whitenedTransitModel(windowIndices).^2.*stats.w)) ;
    if isnan( robustStatistic )
        robustStatistic = 0 ;
    end

catch 

%   in the event of a failure, we will want to set up to gap out
%   all of the cadences in windowIndicesOriginal, so that the next
%   iteration of folding, if any, doesn't find the exact same event
%   and repeats the entire process (infinite loop will occur)

    robustStatistic = 0 ;
    stats.w = zeros(length(windowIndices),1) ;
    robustInformationStruct.robustFitFail = true ;
    fittedTransitDepth = 0 ;
    fittedTransitDepthSigma = 1 ;
    previousFittedDepth = 0 ;

end


% case 1:  there's actually only a single pulse here due to gaps -- set the stats for all
% pulses in the fit to zero so that they are marked to be gapped later

if range(windowIndices(deemphasisWeight(windowIndices)~=0)) <= trialTransitDurationInCadences - 1

        robustStatistic = 0 ;
        stats.w = zeros(length(windowIndices), 1) ;
        robustInformationStruct.robustStatisticVetoApplied = true ;
        robustInformationStruct.fitSinglePulse = true ;
        fittedTransitDepth = 0 ;
        previousFittedDepth = 0 ;
        fittedTransitDepthSigma = 1 ;

end

% case 2:  we're at minSesCount transits, and one or more of the transits has 50% of its
% cadences thrown out -- in this case, throw out the remaining cadences in the affected
% transits

nTransits = length(sesCombinedToYieldMes(sesCombinedToYieldMes ~= 0)) ;
if isequal(nTransits,minSesCount) % && robustStatistic >= robustStatisticThreshold
    windowStartIndex = [1;find(diff(windowIndicesOrig)>trialTransitDurationInCadences+1)+1] ;
    windowStart = windowIndicesOrig(windowStartIndex) ;
    windowEnd = [windowIndicesOrig(windowStartIndex(2:end)-1);windowIndicesOrig(end)] ;
    
    %windowStart(sesCombinedToYieldMes==0) = [] ; % removing these from the
    %model now so commenting out
    %windowEnd(sesCombinedToYieldMes==0) = [] ;
    
    % for each transit compute percent of cadences deemphasized
    for i=1:length(windowStart)
        avgWeight = mean( deemphasisWeight(windowStart(i):windowEnd(i)) ) ;
        if avgWeight < 0.5
            indexOrig = windowIndicesOrig(ismember(windowIndicesOrig,windowStart(i):windowEnd(i))) ;
            windowIndicators = ismember(windowIndices,indexOrig);
            stats.w(windowIndicators) = 0 ;
            robustStatistic = 0 ;
            robustInformationStruct.robustStatisticVetoApplied = true ;
            robustInformationStruct.fitSinglePulse = true ;
            fittedTransitDepth = 0 ;
            previousFittedDepth = 0 ;
            fittedTransitDepthSigma = 1 ;
        end
    end
end

% here is where we throw out any cadences from the 2 processes above, plus any identified
% by the robust fitter itself

subThresholdIndices =  stats.w <= gappingThreshold ;
if ismember(1,subThresholdIndices)
    robustInformationStruct.cadencesToRemove = windowIndices(subThresholdIndices) ;
    robustInformationStruct.cadencesToRemove = ...
        robustInformationStruct.cadencesToRemove(:) ;
end

% if the value of the period and the depth have hardly changed since the last iteration of
% robust statistic calculation, we can signal to the caller that we are done looking at
% this particular combination of period and phase.  This is done by nulling the list of
% cadences to be removed.  Note that if no cadences were thrown out on this iteration, we
% can already stop iterating because the next iteration will produce exactly the same
% period and depth as this one

if ~isnan(previousFittedDepth) && previousFittedDepth ~= 0      
   depthChangeSigmaFraction = abs(fittedTransitDepth - previousFittedDepth)/fittedTransitDepthSigma ;
   if depthChangeSigmaFraction < foldingParameterStruct.robustStatisticConvergenceTolerance 
       robustInformationStruct.cadencesToRemove = [] ;
   end
end

% latch the current period and depth

  robustInformationStruct.previousFittedDepth = fittedTransitDepth ;

return

%=========================================================================================

% tool for computation of the event statistic ratio

function eventStatisticRatio = compute_event_statistic_ratio( multipleEventStatistic, ...
      robustStatistic, bestOrbitalPeriodInCadences, bestPhaseInCadences, ...
      tpsResult )
  
% glue necessary parameters into the result struct

  tpsResult.bestOrbitalPeriodInCadences = bestOrbitalPeriodInCadences ;
  tpsResult.bestPhaseInCadences = bestPhaseInCadences ;
  
% get the SES in MES

[~, sesCombinedToYieldMes] = ...
    find_index_of_ses_added_to_yield_mes(tpsResult,1) ;
validSes = sesCombinedToYieldMes(sesCombinedToYieldMes ~= 0) ;

% if there are lots of transits that contribute to the MES then we 
% need to use the median SES when computing the ratio so we dont run 
% the risk of killing it with some outlier by taking the max

if length(validSes) > 4
    eventStatisticRatio = robustStatistic * multipleEventStatistic / ...
        quantile( validSes, 0.75 ) ;
else
    eventStatisticRatio = robustStatistic * multipleEventStatistic / ...
        max( validSes ) ;
end

if isempty( eventStatisticRatio ) || isnan( eventStatisticRatio ) || ...
        multipleEventStatistic == 0
    eventStatisticRatio = 0 ;
end

return


%=========================================================================================

% subfunction which "latches" current folding, or in plain English stores the current
% folding values into the tpsResult struct

function tpsResult = latch_this_period_and_phase( tpsResult, ...
                foldingParameterStruct, tpsModuleParameters, ...
                bestMultipleEventStatistic, bestOrbitalPeriodInCadences, ...
                RSLoopCount, periodCount, ...
                bestPhaseInCadences, phaseLagInCadences, midTimestamp, ...
                foldedStatisticAtPhasesComplete, validPhaseIndicator )

cadencesPerDay        = tpsModuleParameters.cadencesPerHour / get_unit_conversion( ...
    'hour2day' ) ;
superResolutionFactor = tpsModuleParameters.superResolutionFactor ;
transitLengthSuperResolutionCadences = foldingParameterStruct.trialTransitDurationInCadences * ...
    superResolutionFactor ;

bestOrbitalPeriodInDays = bestOrbitalPeriodInCadences/(cadencesPerDay*superResolutionFactor);
bestPhaseInDays = (bestPhaseInCadences-superResolutionFactor)/...
    (cadencesPerDay*superResolutionFactor);

tpsResult.bestPhaseInCadences = bestPhaseInCadences/superResolutionFactor;
tpsResult.bestOrbitalPeriodInCadences = bestOrbitalPeriodInCadences/superResolutionFactor;

tpsResult.maxMultipleEventStatistic = bestMultipleEventStatistic;
tpsResult.detectedOrbitalPeriodInDays = bestOrbitalPeriodInDays;

tpsResult.timeToFirstTransitInDays = bestPhaseInDays;
tpsResult.timeOfFirstTransitInMjd = midTimestamp + bestPhaseInDays ;

tpsResult.foldedStatisticAtTrialPhases = foldedStatisticAtPhasesComplete ;
tpsResult.phaseLagInCadences = phaseLagInCadences / superResolutionFactor ;

% get the robust statistic, again operating in normal-resolution cadences

robustFitExtraParameters.minSesCount         = tpsModuleParameters.minSesInMesCount ;
robustFitExtraParameters.gappingThreshold    = ...
    tpsModuleParameters.robustWeightGappingThreshold ;
robustFitExtraParameters.previousFittedDepth = -1 ;
robustFitExtraParameters.previousPeriod      = -1 ;

[tpsResult.robustStatistic,robustInformationStruct] = compute_robust_statistic( ...
    tpsResult, foldingParameterStruct, ...
    tpsResult.bestOrbitalPeriodInCadences, tpsResult.bestPhaseInCadences, ...
    tpsResult.deemphasisWeight, robustFitExtraParameters ) ;

tpsResult.robustfitFail  = robustInformationStruct.robustFitFail ;
tpsResult.fitSinglePulse = robustInformationStruct.fitSinglePulse ;
tpsResult.fittedDepth = robustInformationStruct.previousFittedDepth ;
  
% get the information on SES combined to yield MES

[tpsResult.indexOfSesAdded, tpsResult.sesCombinedToYieldMes] = ...
    find_index_of_ses_added_to_yield_mes(tpsResult,superResolutionFactor) ;

% compute the chi-squares

[tpsResult,chiSquare1Ok,chiSquare2Ok] = compute_chisquare_veto( tpsResult, ...
    tpsModuleParameters, foldingParameterStruct, ...
    tpsResult.maxMultipleEventStatistic, tpsResult.fittedDepth ) ;

% set the flags which indicate whether it's a good candidate phaseInDays(indexOfBestPhase);

tpsResult.isPlanetACandidate = tpsResult.maxMultipleEventStatistic >= ...
    tpsModuleParameters.searchTransitThreshold && ...
    tpsResult.robustStatistic >= tpsModuleParameters.robustStatisticThreshold && ...
    chiSquare1Ok && chiSquare2Ok ; 

% empty the mes vs. phase array each time we latch since we want it to be
% populated only when we end up with a TCE
tpsResult.weakSecondaryStruct = initialize_weak_secondary_struct ;

% if it is a TCE then record MES vs. Phase

if tpsResult.isPlanetACandidate
% notch out the peak corresponding to the TCE 
    foldedStatisticAtPhasesComplete = foldedStatisticAtPhasesComplete .* validPhaseIndicator ;
    peakCenter = find( bestPhaseInCadences == phaseLagInCadences ) ;
    weakSecondaryPeakRangeMultiplier = tpsModuleParameters.weakSecondaryPeakRangeMultiplier ; % hard coded for now
    peakHalfRange = round( transitLengthSuperResolutionCadences * weakSecondaryPeakRangeMultiplier );
    peakStart = max( 1, peakCenter - peakHalfRange ) ;
    peakEnd = min( length(foldedStatisticAtPhasesComplete),peakCenter + peakHalfRange ) ;
    foldedStatisticAtPhasesComplete(peakStart:peakEnd) = 0 ;
    
    phase = mod( phaseLagInCadences - bestPhaseInCadences, bestOrbitalPeriodInCadences ) / bestOrbitalPeriodInCadences ;
    overOneHalf = phase > 0.5 ;
    phase(overOneHalf) = phase(overOneHalf) - 1 ;
    [phaseSorted, sortKey] = sort( phase ) ;
    phaseInDays = phaseSorted * bestOrbitalPeriodInDays ;
    foldedStatisticAtPhasesComplete = foldedStatisticAtPhasesComplete(sortKey);
    
    indexOfBestPhase = locate_center_of_asymmetric_peak( foldedStatisticAtPhasesComplete);

    tpsResult.weakSecondaryStruct.mes = foldedStatisticAtPhasesComplete ;
    tpsResult.weakSecondaryStruct.phaseInDays = phaseInDays ;
    tpsResult.weakSecondaryStruct.bestPhaseInDays = phaseInDays(indexOfBestPhase);
    tpsResult.weakSecondaryStruct.bestMes = foldedStatisticAtPhasesComplete(indexOfBestPhase);
end

tpsResult.RSLoopCnt = RSLoopCount ;
tpsResult.periodCount = periodCount ;

return

%=========================================================================================

% subfunction which estimates the number of "features" in the single event statistics time
% series

function detectedFeatureCount = count_features_in_ses( ses, searchTransitThreshold, ...
    minSesInMesCount )

  detectedFeatureCount = 0 ;
  eventThreshold = searchTransitThreshold * sqrt(minSesInMesCount) ;
  
  while any( ses > eventThreshold )
      
      detectedFeatureCount = detectedFeatureCount + 1 ;
      [~,maxSesLocation] = max( ses ) ;
      [eventStart,eventEnd] = find_range_of_ses_peak( ses, maxSesLocation, ...
          searchTransitThreshold ) ;
      ses( eventStart:eventEnd ) = 0 ;
      
  end
  
return

%=========================================================================================

% subfunction to find the range of a peak in the SES time series

function [eventStart,eventEnd] = find_range_of_ses_peak( ses, maxSesLocation, ...
    searchTransitThreshold ) 

    eventStart = find( ses(1:maxSesLocation) < searchTransitThreshold, 1, ...
        'last' ) ;
    if isempty(eventStart)
        eventStart = 1 ;
    end
    eventEnd = find( ses(maxSesLocation+1:end) < searchTransitThreshold, 1, ...
        'first' ) + maxSesLocation ;
    if isempty(eventEnd)
        eventEnd = length(ses) ;
    end
    
return




