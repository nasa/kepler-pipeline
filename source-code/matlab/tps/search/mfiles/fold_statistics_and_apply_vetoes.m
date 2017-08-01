function [tpsResult, possiblePeriodsInCadences] = ...
    fold_statistics_and_apply_vetoes( tpsResult, tpsModuleParameters, ...
    bootstrapParameters, possiblePeriodsInCadences, ...
    foldingParameterStruct, deemphasisParameter )
%
% fold_statistics_and_apply_vetoes -- search for a valid TCE by folding the detection
% statistics and applying vetoes to above-threshold cases
%
% [tpsResult, possiblePeriodsInCadences] = fold_statistics_and_apply_vetoes( tpsResult,
%    tpsModuleParameters, possiblePeriodsInCadences, midTimestamp, foldingParameterStruct,
%    deemphasisParameter ) performs the folding and combination of the single event
%    statistics to find multiple event statistics as a function of period and phase; if
%    any of the resulting multiple event statistics are above threshold, the vetoes are
%    applied to remove false alarm detections; if the detection passes the multiple event
%    statistic threshold and the vetoes, the detection is latched into the tpsResult
%    struct.  The search is performed iteratively over the strongest set of
%    above-threshold detections, depending on search parameters, so that a strong signal
%    which is vetoed does not preclude detection of a weaker signal which can pass the
%    vetoes.  Argument possiblePeriodsInCadences is passed as an input and output argument
%    so that, in the multi-target use case, the search periods do not need to be
%    recomputed for every target but are stored in the calling routine and re-used after
%    the first calculation.
%
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

%=========================================================================================

  cadencesPerDay                 = tpsModuleParameters.cadencesPerDay;
  superResolutionFactor          = tpsModuleParameters.superResolutionFactor;
  searchTransitThreshold         = tpsModuleParameters.searchTransitThreshold ;
  maxLoopCount                   = tpsModuleParameters.maxFoldingLoopCount ;
  maxRemovedFeatureCount         = tpsModuleParameters.maxRemovedFeatureCount ;
  minSesInMesCount               = tpsModuleParameters.minSesInMesCount ;

  tpsResult.searchLoopCount     = 0 ;
  tpsResult.removedFeatureCount = 0 ;
  tpsResult.deemphasisParameter = deemphasisParameter ;
  
  tpsResult = populate_deemphasis_weight( tpsResult, superResolutionFactor ) ;
    
% generate whitening coefficients for this flux time series at this pulse duration

  waveletObject = tpsResult.waveletObject ;

% glue some more stuff into the foldingParameterStruct

  foldingParameterStruct.mScale        = get( waveletObject, 'filterScale' ) + 1 ;
  foldingParameterStruct.whitenedFlux  = apply_whitening_to_time_series( waveletObject ) ;
  foldingParameterStruct.superResolutionFactor = ...
      tpsModuleParameters.superResolutionFactor ;

% count the features

  tpsResult.detectedFeatureCount = count_features_in_ses( ...
      tpsResult.correlationTimeSeries ./ tpsResult.normalizationTimeSeries, ...
      searchTransitThreshold, minSesInMesCount ) ;
  
% duplicate tpsResult -- we'll use one copy for the main search and one for the additional
% periods search

  tpsResultAdditionalPeriods = tpsResult ;

% search loop:  remove the largest feature(s) if permitted to do so by the TPS parameters,
% then examine the strongest multiple event statistics in this time series; in the
% process, we will capture in the robustFitExtraParameters struct the deemphasis parameter
% updates which were used to remove features, but NOT any which are related to robust
% statistic removal of cadences

  [tpsResult, possiblePeriodsInCadences, foldedStatisticAtTrialPeriods, ...
      foldedStatisticMinAtTrialPeriods, phaseLagOfMinStatistic, meanMesEstimate, ...
      validPhaseSpaceFraction, mesHistogram, tpsModuleParameters] = ...
      search_for_valid_detections( tpsResult, possiblePeriodsInCadences, ...
      tpsModuleParameters, bootstrapParameters, foldingParameterStruct, ...
      tpsModuleParameters.searchTransitThreshold, maxLoopCount, ...
      maxRemovedFeatureCount ) ;

% in the case of a near-circular EB, multi-planet search may identify a signal
% which is 2x the actual period (because of the gaps in the light curve from
% removing the primary eclipse).  To help identify this occurrence, we need to be
% able to look at the MES at multiples of the period which produced the best detection.
% The easiest way to do this is to redo the search with only the list of new periods

  bestOrbitalPeriodInCadences = tpsResult.bestOrbitalPeriodInCadences * ...
      superResolutionFactor ;
  additionalPeriods = ...
      2*bestOrbitalPeriodInCadences:bestOrbitalPeriodInCadences:max(possiblePeriodsInCadences) ;
  additionalPeriods = additionalPeriods(:) ;

  if ~isempty(additionalPeriods) && ...
        tpsResult.isPlanetACandidate
    
    disp(['     ... starting search of additional periods ... ']) ;

%   If any of the new periods being searched has the exact same MES as the one which is
%   latched, we want it to latch the new one and discard the old one.  
    
    [tpsResultAdditionalPeriods,~,additionalFoldedStatistics, additionalMinStatistics, ...
        additionalMinStatisticLags] = search_for_valid_detections( tpsResultAdditionalPeriods, ...
        additionalPeriods, tpsModuleParameters, bootstrapParameters, foldingParameterStruct, ...
        tpsResult.maxMultipleEventStatistic, maxLoopCount, 0, true ) ;
    
%   if an equally-good MES was found at longer period, then the longer-period value is the
%   one we want to hold onto because the only way this can happen is if every other
%   transit in the shorter-period detection is actually a gap; however, even if this is
%   the case, do not trade a tpsResult with a good candidate for a
%   tpsResultsAdditionalPeriods without a good candidate
    
    goodOriginalBadAdditional = tpsResult.isPlanetACandidate && ...
        ~tpsResultAdditionalPeriods.isPlanetACandidate ;
    if (tpsResultAdditionalPeriods.maxMultipleEventStatistic == ...
            tpsResult.maxMultipleEventStatistic) && ~goodOriginalBadAdditional
        tpsResultAdditionalPeriods.searchLoopCount = ...
            tpsResultAdditionalPeriods.searchLoopCount + tpsResult.searchLoopCount ;
        % We want to keep the loop iterations planet candidateStruct from the original run, not the additional periods run.
        tpsResultAdditionalPeriods.planetCandidateStruct = tpsResult.planetCandidateStruct; 
        tpsResult = tpsResultAdditionalPeriods ;
    end
    
%   construct the complete set of period, phase, and MES vectors with both the initial and
%   the harmonic period sets
    
    possiblePeriodsInCadences = [possiblePeriodsInCadences(:) ; ...
        additionalPeriods(:)] ;
    [possiblePeriodsInCadences, periodSortKey] = sort( possiblePeriodsInCadences ) ;
    foldedStatisticAtTrialPeriods = [foldedStatisticAtTrialPeriods(:) ; ...
        additionalFoldedStatistics(:)] ;
    foldedStatisticAtTrialPeriods = foldedStatisticAtTrialPeriods( periodSortKey ) ;
    foldedStatisticMinAtTrialPeriods = [foldedStatisticMinAtTrialPeriods(:) ; ...
        additionalMinStatistics(:)] ;
    foldedStatisticMinAtTrialPeriods = foldedStatisticMinAtTrialPeriods( periodSortKey ) ;
    phaseLagOfMinStatistic = [phaseLagOfMinStatistic(:) ; ...
        additionalMinStatisticLags(:)] ;
    phaseLagOfMinStatistic = phaseLagOfMinStatistic( periodSortKey ) ;
        
  end
        
% capture the final vector of periods and MES values

  tpsResult.foldedStatisticAtTrialPeriods = foldedStatisticAtTrialPeriods ;
  tpsResult.possiblePeriodsInCadences     = possiblePeriodsInCadences / superResolutionFactor ; 
  tpsResult.mesHistogram = mesHistogram ;
  tpsResult.meanMesEstimateForSearchPeriods = meanMesEstimate ;
  tpsResult.validPhaseSpaceFractionForSearchPeriods = validPhaseSpaceFraction ;

% capture the statistic vs phase for this period

  [tpsResult.foldedStatisticAtTrialPhases, ...
      phaseLagInCadences] = fold_statistics_at_trial_phases( tpsResult, ...
      tpsResult.bestOrbitalPeriodInCadences * superResolutionFactor, ...
      tpsModuleParameters ) ;
  tpsResult.phaseLagInCadences = phaseLagInCadences / superResolutionFactor ;

% capture the microlensing parameters -- here we make a much simpler test, and use only
% the vectors of MES and period

  indexOfBestMicrolensPeriod = ...
      locate_center_of_asymmetric_peak(-foldedStatisticMinAtTrialPeriods);   
  bestMinMultipleEventStatistic = ...
      foldedStatisticMinAtTrialPeriods(indexOfBestMicrolensPeriod);

  bestMicrolensOrbitalPeriodInCadences = ...
      possiblePeriodsInCadences(indexOfBestMicrolensPeriod) ;
  bestMicrolensOrbitalPeriodInDays = ...
      bestMicrolensOrbitalPeriodInCadences/(cadencesPerDay*superResolutionFactor);

  bestMicrolensPhaseInCadences = phaseLagOfMinStatistic(indexOfBestMicrolensPeriod);
  bestMicrolensPhaseInDays = (bestMicrolensPhaseInCadences)/ ...
      (cadencesPerDay*superResolutionFactor);

  tpsResult.bestMicrolensOrbitalPeriodInCadences = ...
      bestMicrolensOrbitalPeriodInCadences/superResolutionFactor;
  tpsResult.detectedMicrolensOrbitalPeriodInDays = bestMicrolensOrbitalPeriodInDays;
  tpsResult.bestMicrolensPhaseInCadences = bestMicrolensPhaseInCadences/superResolutionFactor;
  tpsResult.timeToFirstMicrolensInDays = bestMicrolensPhaseInDays;
  tpsResult.timeOfFirstMicrolensInMjd = foldingParameterStruct.cadence1Timestamp + ...
      bestMicrolensPhaseInDays;
  tpsResult.minMultipleEventStatistic = bestMinMultipleEventStatistic;
  
% TPS must set the orbital period to -1 when there is only one strong event giving rise to 
% a TCE 

  if(length(tpsResult.indexOfSesAdded(tpsResult.sesCombinedToYieldMes ~= 0)) < 2)
      correlationTimeSeriesHiRes = tpsResult.correlationTimeSeriesHiRes ;
      normalizationTimeSeriesHiRes = tpsResult.normalizationTimeSeriesHiRes ;
      deemphasisWeights = tpsResult.deemphasisWeightSuperResolution ;
      isForSes = true ;
    
%   apply weights

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
          foldingParameterStruct.cadence1Timestamp ;   
  end

return

%=========================================================================================
%=========================================================================================
%=========================================================================================
%=========================================================================================
%=========================================================================================
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

%=========================================================================================

% subfunction to remove a feature in the single event statistics time series

function [tpsResult,featureRemoved] = remove_feature( tpsResult, ...
    tpsModuleParameters, periodInCadences, phaseInCadences, threshold )
  
  ses = tpsResult.correlationTimeSeries ./ tpsResult.normalizationTimeSeries ;
  superResolutionFactor  = tpsModuleParameters.superResolutionFactor ;
  minSesInMesCount       = tpsModuleParameters.minSesInMesCount ;
  featureRemoved         = false ;
  
% find all of the SES in MES for this signal  
  
  [indexHiRes,sesValues] = find_index_of_ses_added_to_yield_mes( ...
        periodInCadences / superResolutionFactor, ...
        phaseInCadences / superResolutionFactor, ...
        superResolutionFactor, ...
        tpsResult.correlationTimeSeriesHiRes, ...
        tpsResult.normalizationTimeSeriesHiRes, ...
        tpsResult.deemphasisWeightSuperResolution ) ;

% find the strongest of the values, and convert its location to normal resolution
    
  [maxSes,pointerToMaxSes] = max(sesValues) ;
  indexOfMaxSes = round( indexHiRes(pointerToMaxSes) / superResolutionFactor ) ;

% find the extent of the SES peak by seeing where it goes down to a SES which is below the
% detection threshold

  if maxSes >= threshold * sqrt( minSesInMesCount )
      
      [deemphasisStart,deemphasisEnd] = find_range_of_ses_peak( ses, indexOfMaxSes, ...
            threshold ) ;
      cadencesToRemove = deemphasisStart:deemphasisEnd ;
  
% deemphasize these cadences completely 

      tpsResult = update_deemphasis_parameter( tpsResult, cadencesToRemove(:) ) ;
      tpsResult = populate_deemphasis_weight( tpsResult, superResolutionFactor ) ;
  
      tpsResult.removedFeatureCount = tpsResult.removedFeatureCount + 1 ;
      featureRemoved                = true ;
      disp('       ... feature removed from SES time series ... ') ;
      
  else
      
      disp('       ... no features removed from SES time series ... ') ;
      
  end


return

%=========================================================================================

% subfunction which performs the iterative searching of MES values above threshold, any
% necessary feature removal, and application of vetoes

function [tpsResultLatched, possiblePeriodsInCadences, foldedStatisticAtTrialPeriods, ...
    foldedStatisticMinAtTrialPeriods, phaseLagOfMinStatistic, meanMesEstimate, ...
    validPhaseSpaceFraction, mesHistogram, tpsModuleParameters] = search_for_valid_detections( tpsResult, ...
    possiblePeriodsInCadences, tpsModuleParameters, bootstrapParameters, foldingParameterStruct, ...
    searchThreshold, maxLoopCount, maxRemovedFeatureCount, additionalPeriodSearch )

  searchComplete = false ;
  if ~exist('additionalPeriodSearch','var') || isempty(additionalPeriodSearch)
      additionalPeriodSearch = false ;
  end  
  
% get the starting threshold for feature removal in case the threshold is updated 
% subsequently by the bootstrap

featureRemovalThreshold = tpsModuleParameters.searchTransitThreshold ;
  
% We will be using two copies of the tpsResult struct:  a working copy which we can
% manipulate in any way we desire, and a "best so far copy" which is ultimately returned
% to the caller; form that second copy now
  
  tpsResultLatched = tpsResult ;
  t0 = clock ;
  
% if we are not in the additional period search, set the looping time limit

  loopStopTime = inf ;
  searchTimedOut = false ;
  if ~additionalPeriodSearch
      loopTimeLimitHours  = tpsModuleParameters.maxHrsLoopingPerPulse ;
      if loopTimeLimitHours ~= -1
          loopTimeLimitDays = loopTimeLimitHours * get_unit_conversion('hour2day') ;
          loopStopTime = datenum(t0) + loopTimeLimitDays ;
      end
  end
  
  while ~searchComplete
    
%   If we are in the part of the search where we are allowed to remove features, then we
%   only want to get one MES value from the locator; if it gets rejected on vetoes, then
%   we'll remove a feature from it, if a feature is present.  Otherwise, once we are past
%   feature removal, then we can get the full maxLoopCount list of strongest MES values
%   from the locator

    if tpsResult.removedFeatureCount < maxRemovedFeatureCount
        nMesToSearch = 1 ;
    else
        nMesToSearch = maxLoopCount ;
    end
    
    [multipleEventStatistic, periodInCadences, phaseInCadences, ...
        possiblePeriodsInCadences, foldedStatisticAtTrialPeriods, ...
        foldedStatisticMinAtTrialPeriods, phaseLagOfMinStatistic, ...
        meanMesEstimate, validPhaseSpaceFraction, mesHistogram] = ...
        locate_strongest_statistics( tpsResult, tpsModuleParameters, ...
        possiblePeriodsInCadences, nMesToSearch, searchThreshold ) ;
        
    tpsResult.strongestOverallMultipleEventStatistic = multipleEventStatistic(1) ;
    iMesToSearch = 0 ;
    
%   if there are no events above threshold, then there's nothing more to do so we can end
%   the loop

    if max(multipleEventStatistic) < searchThreshold
        searchComplete = true ;
    else
        
%       otherwise, we need to look at each possible signal in turn and subject it to 
%       vetoes and/or deemphasis of cadences

        while ~searchComplete && iMesToSearch < length(multipleEventStatistic)
            
            iMesToSearch = iMesToSearch + 1 ;
            
            tpsResult.searchLoopCount = iMesToSearch ;

            [tpsResult, tpsModuleParameters] = set_transit_candidate_status( ...
                tpsResult, multipleEventStatistic(iMesToSearch), foldingParameterStruct, ...
                tpsModuleParameters, bootstrapParameters, periodInCadences(iMesToSearch), ...
                phaseInCadences(iMesToSearch), false ) ;
        
%           if this transit candidate has good status and MES above the existing
%           candidate, then we want this one to become the existing candidate

            if tpsResult.isPlanetACandidate && tpsResult.maxMultipleEventStatistic > ...
                    tpsResultLatched.maxMultipleEventStatistic
                
                tpsResultLatched = tpsResult ;
                
%               If the latched MES value was obtained after applying some robust
%               deweighting of cadences, then it's possible that the resulting MES is
%               actually lower than some of the MES values on the list which have yet to
%               be explored.  Handle that condition now

                if iMesToSearch == length(multipleEventStatistic) || ...
                        tpsResultLatched.maxMultipleEventStatistic >= ...
                        multipleEventStatistic(iMesToSearch+1)
                    searchComplete = true ;
                end
                    
                
            end % latching condition
            
%           check to see whether we have run out of time

            datenumNow = now ;
            if datenumNow > loopStopTime
                searchComplete = true ;
                searchTimedOut = true ;
            end
            
        end % while still searching and still something to search loop
        
%       if we are still allowed to remove features, then remove one now; otherwise, if we
%       have done all feature removal and looked at all maxLoopCount strongest signals,
%       then we are done searching

        if ~searchComplete && tpsResult.removedFeatureCount < maxRemovedFeatureCount
            [tpsResult, featureRemoved] = remove_feature( tpsResult, ...
                tpsModuleParameters, periodInCadences, phaseInCadences, featureRemovalThreshold ) ;
           
%           if a feature was removed and we are computing the bootstrap
%           veto after the other vetoes, then we need to reset the search
%           threshold and the tps results that may have been modified by it
            
            if featureRemoved && ~isequal(tpsModuleParameters.bootstrapThresholdReductionFactor, -1) && ...
                    ~isequal(tpsResult.thresholdForDesiredPfa, -1)
                tpsModuleParameters.searchTransitThreshold = featureRemovalThreshold ;
                tpsResult.thresholdForDesiredPfa = -1;
                tpsResult.mesMeanEstimate = -1;
                tpsResult.mesStdEstimate = -1;
                tpsResult.falseAlarmProbability = -1;
                tpsResult.falseAlarmProbabilities = -1;
                tpsResult.mesBins = -1;
                tpsResult.isThreshForDesiredPfaInterpolated = false;
                tpsResult.isFalseAlarmProbInterpolated = false;
            end
                    
            
%           In some cases there is an event which is rejected but which contains no
%           "features" as defined by the feature removal algorithm.  In this case, if we
%           go back and re-fold then an infinite loop will occur, since the exact same
%           event will come up as the strongest one and be rejected again, etc.  Protect
%           against that case now
            
            if ~featureRemoved
                maxRemovedFeatureCount = tpsResult.removedFeatureCount ;
            end
            
        else
            searchComplete = true ;
        end
        
    end % what to do if there are multiple event statistics in the list
    
  end % while loop over search complete

% if no latching of values ever occurred at all, latch the values which correspond to the
% last period-phase combination in the list, plus force calculation of everything in this
% case -- note that we only want to do this if the last period-phase combination is not
% pathological!  For the injection studies where we are not performing the
% weak secondary test, there is no need to force the latching either.

  if ( ~tpsModuleParameters.performWeakSecondaryTest  && ...
          tpsResultLatched.maxMultipleEventStatistic == -1 && ...
          ~additionalPeriodSearch && ...
          (tpsResult.maxMultipleEventStatistic > 0 || ...
          tpsResult.maxMultipleEventStatistic == -1) )
      tpsResultLatched = set_transit_candidate_status( ...
          tpsResult, multipleEventStatistic(end), foldingParameterStruct, ...
          tpsModuleParameters, bootstrapParameters, periodInCadences(end), ...
          phaseInCadences(end), false ) ;
      tpsResultLatched.searchLoopCount = max(iMesToSearch,1) ;
  elseif ( tpsResultLatched.maxMultipleEventStatistic == -1 && ...
          ~additionalPeriodSearch && ...
          (tpsResult.maxMultipleEventStatistic > 0 || ...
          tpsResult.maxMultipleEventStatistic == -1) )
      tpsResultLatched = set_transit_candidate_status( ...
          tpsResult, multipleEventStatistic(end), foldingParameterStruct, ...
          tpsModuleParameters, bootstrapParameters, periodInCadences(end), ...
          phaseInCadences(end), true ) ;
      tpsResultLatched.searchLoopCount = max(iMesToSearch,1) ;
  end

  if iMesToSearch >= maxLoopCount
      tpsResultLatched.exitedOnLoopCountLimit = true ;
  else
      tpsResultLatched.exitedOnLoopCountLimit = false ;
  end
  tpsResultLatched.exitedOnLoopTimeLimit = searchTimedOut ;
  
  t1 = clock ; 
  if ~searchTimedOut
      disp(['     ... analysis of prospective detections complete after ', ...
          num2str(etime(t1,t0)), ' seconds ... ']) ;
  else
      disp(['     ... analysis of prospective detections timed out after ', ...
          num2str(etime(t1,t0)), ' seconds ... ']) ;
  end

  % If there is only a single entry in planetCandidateStruct then this is the same information as in the rest of tpsResultLatched and so clear the struct, it's
  % redundant information. Also, remove all iterations that never occured in the pre-allocated tpsResultLatched.planetCandidateStruct.
  maxIteration = max(tpsResultLatched.planetCandidateStruct.searchLoopCount);
  if (maxIteration < 2)
      tpsResultLatched.planetCandidateStruct = [];
  else
      structFieldNames = fieldnames(tpsResultLatched.planetCandidateStruct);
      for iField = 1 : length(structFieldNames)
          tpsResultLatched.planetCandidateStruct.(structFieldNames{iField}) = tpsResultLatched.planetCandidateStruct.(structFieldNames{iField})(1:maxIteration);
      end
  end

return

%=========================================================================================

% subfunction which determines whether the current period and phase constitute a valid
% detection, based on whatever the current criteria are.  
 function [tpsResult, tpsModuleParameters] = set_transit_candidate_status( tpsResult, ...
     maxMultipleEventStatistic, foldingParameterStruct, tpsModuleParameters, ...
     bootstrapParameters, bestOrbitalPeriodInCadences, bestPhaseInCadences, ...
     forceChiSquareCalculation )
          
% extract useful module parameters
 
  minSesInMes                    = tpsModuleParameters.minSesInMesCount ;
  superResolutionFactor          = tpsModuleParameters.superResolutionFactor ;
  usePolyFitTransitModel         = tpsModuleParameters.usePolyFitTransitModel ;
  bestOrbitalPeriod              = bestOrbitalPeriodInCadences / superResolutionFactor ;
  bestPhase                      = bestPhaseInCadences / superResolutionFactor ;
  waveletObject                  = tpsResult.waveletObject ;
  deemphasisWeights              = tpsResult.deemphasisWeight ;
  trialTransitDurationInCadences = foldingParameterStruct.trialTransitDurationInCadences ;
  nCadences                      = foldingParameterStruct.nCadences ;
  
% set default return

  tpsResult.isPlanetACandidate = false ;
  
% latch the current event timing and MES value

  tpsResult = latch_this_period_and_phase( tpsResult, ...
      tpsModuleParameters, maxMultipleEventStatistic, ...
      bestOrbitalPeriodInCadences, ...
      bestPhaseInCadences, foldingParameterStruct.cadence1Timestamp ) ;

% get the transit information

  [indexOfSesAdded, sesCombinedToYieldMes] = ...
      find_index_of_ses_added_to_yield_mes( bestOrbitalPeriod, bestPhase, ...
      superResolutionFactor, tpsResult.correlationTimeSeriesHiRes, ...
      tpsResult.normalizationTimeSeriesHiRes, ...
      tpsResult.deemphasisWeightSuperResolution ) ;
  
  tpsResult.maxSesInMes = max(sesCombinedToYieldMes) ;
  tpsResult.indexOfSesAdded = indexOfSesAdded ;
  tpsResult.sesCombinedToYieldMes = sesCombinedToYieldMes ;
  
  nTransits = length( indexOfSesAdded(sesCombinedToYieldMes ~= 0) ) ;
  
  planetCandidateStruct = determine_planet_candidate_status( tpsResult, tpsModuleParameters ) ;
  
% generate the trial transit pulse train through the superResolutionClass   
  scalingFilterCoeffts = get( waveletObject, 'h0' ) ;
  superResolutionStruct = struct('superResolutionFactor', superResolutionFactor, ...
      'pulseDurationInCadences', trialTransitDurationInCadences, 'usePolyFitTransitModel', ...
      usePolyFitTransitModel ) ;
  superResolutionObject = superResolutionClass( superResolutionStruct, scalingFilterCoeffts ) ;
  superResolutionObject = set_statistics_time_series_shift_length( superResolutionObject) ; 

% generate a new pulse train that excludes transits falling in gaps
  validSesIndex = indexOfSesAdded(sesCombinedToYieldMes ~= 0) ;
  transitModel = generate_trial_transit_pulse_train( superResolutionObject, ...
      validSesIndex, nCadences ) ;

% check the validity of the pulse train - if we are at nSesInMes =
% minSesInMes then this requires that the events have decent weights
fitSinglePulse = assess_pulse_train_validity( transitModel, deemphasisWeights, minSesInMes ) ;
tpsResult.fitSinglePulse = fitSinglePulse;
  
  if (planetCandidateStruct.mesOkay || forceChiSquareCalculation) && (nTransits >= minSesInMes)

    % compute and apply the vetoes

      [tpsResult, fittedTrend, deemphasizedNormalizationTimeSeries, tpsModuleParameters] = ...
          compute_and_apply_vetoes( tpsResult, tpsModuleParameters, ...
          bootstrapParameters, foldingParameterStruct, forceChiSquareCalculation ) ;

    % determine if this is a planet candidate

    
      % KSOC-4884: Record the Veto statistics for post-analysis up to the maximum number of iterations
      % but only for this final call to determine_planet_candidate_status 
      % and only in the search loop (I.e searchLoopCount > 0)
      % Only do this if we want to record any iterations (vetoDiagnosticsMaxNumIterationsToRecord set to 0 means disabled)
      doRecordExtraDiagnostics = (tpsResult.searchLoopCount > 0 && tpsResult.searchLoopCount <= tpsModuleParameters.vetoDiagnosticsMaxNumIterationsToRecord);
      planetCandidateStruct = determine_planet_candidate_status( tpsResult, tpsModuleParameters, doRecordExtraDiagnostics) ;
      tpsResult.isPlanetACandidate = planetCandidateStruct.isPlanetACandidate ;
      if (doRecordExtraDiagnostics)
          index = int32(tpsResult.searchLoopCount);
          structFieldNames = fieldnames(planetCandidateStruct);
          for iField = 1 : length(structFieldNames)
              tpsResult.planetCandidateStruct.(structFieldNames{iField})(index) = planetCandidateStruct.(structFieldNames{iField});
          end
      end

      if tpsResult.isPlanetACandidate 
          
          if tpsModuleParameters.performWeakSecondaryTest
              % get the weak secondary info
              tpsResult.weakSecondaryStruct = compute_weak_secondary_diagnostics( tpsResult, ...
                  foldingParameterStruct, tpsModuleParameters, fittedTrend) ;
          end

          % get the deemphasized normalization time series
          tpsResult.deemphasizedNormalizationTimeSeries = deemphasizedNormalizationTimeSeries;
      end 
      
  end
  
return
  
%=========================================================================================

% subfunction which populates the tpsResult struct with a multiple event statistic and the
% timing information associated therewith

function tpsResult = latch_this_period_and_phase( tpsResult, ...
                tpsModuleParameters, multipleEventStatistic, ...
                bestOrbitalPeriodInCadences, bestPhaseInCadences, ...
                cadence1Timestamp )

cadencesPerDay        = tpsModuleParameters.cadencesPerHour / get_unit_conversion( ...
    'hour2day' ) ;
superResolutionFactor = tpsModuleParameters.superResolutionFactor ;

bestOrbitalPeriodInDays = bestOrbitalPeriodInCadences/(cadencesPerDay*superResolutionFactor);
bestPhaseInDays = (bestPhaseInCadences)/...
    (cadencesPerDay*superResolutionFactor);

tpsResult.bestPhaseInCadences = bestPhaseInCadences/superResolutionFactor;
tpsResult.bestOrbitalPeriodInCadences = bestOrbitalPeriodInCadences/superResolutionFactor;

tpsResult.detectedOrbitalPeriodInDays = bestOrbitalPeriodInDays;

tpsResult.timeToFirstTransitInDays = bestPhaseInDays;
tpsResult.timeOfFirstTransitInMjd = cadence1Timestamp + bestPhaseInDays ;

tpsResult.maxMultipleEventStatistic = multipleEventStatistic ;

return

%=========================================================================================

% subfunction which determines whether a detection is a planet candidate, and also
% determines which of the detection criteria / vetoes are okay and which are not
%
% Inputs:
%   tpsResults
%   tpsModuleParameters
%   doRecordExtraDiagnostics    -- [logical] If true then record many more fields in planetCandidateStruct [Default = false]
%
% Outputs:
%   planetCandidateStruct   -- [struct] Gives the results of each of the veto tests 
%       .isPlanetACandidate
%       .mesOkay
%       .bootstrapOkay
%       .rsOkay
%       .chiSquare2Okay
%       .chiSquareGofOkay
%       .maxSesInMesOkay
%           {Extra Fields below}
%       .searchLoopCount
%       .maxMes
%       .periodDays
%       .epochKjd
%       .numSesInMes
%       .fitSinglePulse
%       .robustStatistic
%       .chiSquare2Statistic    % the value that actually gets compared to the threshold
%       .chiSquareGofStatistic % the value that actually gets compared to the threshold
%       .maxSesInMesStatistic
%       .thresholdForDesiredPfa 
%       .falseAlarmProbability
%

function planetCandidateStruct = determine_planet_candidate_status( tpsResult, tpsModuleParameters, doRecordExtraDiagnostics )

% initialize the candidate field to false

  planetCandidateStruct.isPlanetACandidate = false ;
  
% check if we need to reduce the bootstrap threshold

  if ~isequal(tpsModuleParameters.bootstrapThresholdReductionFactor, -1)
      thresholdReductionFactor = tpsModuleParameters.bootstrapThresholdReductionFactor;
  else
      thresholdReductionFactor = 0;
  end
  
% build the rest of the fields  
  
  planetCandidateStruct.mesOkay = tpsResult.maxMultipleEventStatistic >= ...
      tpsModuleParameters.searchTransitThreshold ;
  
  if isequal(tpsResult.thresholdForDesiredPfa, -1) || ...
          tpsResult.maxMultipleEventStatistic < tpsModuleParameters.bootstrapLowMesCutoff || ...
          ~tpsResult.isThreshForDesiredPfaInterpolated
      planetCandidateStruct.bootstrapOkay = true;
  else
      planetCandidateStruct.bootstrapOkay = tpsResult.maxMultipleEventStatistic >= ...
          (tpsResult.thresholdForDesiredPfa - thresholdReductionFactor);
  end
  
  % TODO: make sure these checks are "turned off" (set to true) until the metric is available. 
  planetCandidateStruct.rsOkay  = tpsResult.robustStatistic >= ...
      tpsModuleParameters.robustStatisticThreshold ;
  
  chiSquare2Statistic = tpsResult.maxMultipleEventStatistic / ...
      sqrt( tpsResult.chiSquare2 / ...
      tpsResult.chiSquareDof2 ) ;
  chiSquareGofStatistic = tpsResult.maxMultipleEventStatistic / ...
      sqrt( tpsResult.chiSquareGof / ...
      tpsResult.chiSquareGofDof ) ;
  
  planetCandidateStruct.chiSquare2Okay = ( chiSquare2Statistic >= ...
      tpsModuleParameters.chiSquare2Threshold ) ;
  planetCandidateStruct.chiSquareGofOkay = ( chiSquareGofStatistic >= ...
      tpsModuleParameters.chiSquareGofThreshold ) ;

  % See compute_maxSesInMesStatistic_veto for details on this veto
  if (isequal(tpsResult.maxSesInMesStatistic, -1) || isequal(tpsResult.detectedOrbitalPeriodInDays, -1))
      % This statistic not yet computed or turned off, so default to true to ignore
      planetCandidateStruct.maxSesInMesOkay = true;
  elseif (tpsResult.maxSesInMesStatistic         > tpsModuleParameters.maxSesInMesStatisticThreshold   && ...
          tpsResult.detectedOrbitalPeriodInDays  > tpsModuleParameters.maxSesInMesStatisticPeriodCutoff  )
      planetCandidateStruct.maxSesInMesOkay = false;
  else
      planetCandidateStruct.maxSesInMesOkay = true;
  end

  
% Convert the struct to a cell array, and the cell array to a vector

  planetCandidateVector = cell2mat( struct2cell( planetCandidateStruct ) ) ;
  
% the value of the isPlanetACandidate field is true if ALL of the other fields are true

  planetCandidateStruct.isPlanetACandidate = all( planetCandidateVector(2:end) ) ;

%***
% Extra Diagnostics
    if (exist('doRecordExtraDiagnostics', 'var') && doRecordExtraDiagnostics)

        planetCandidateStruct.searchLoopCount   = int32(tpsResult.searchLoopCount);

        planetCandidateStruct.maxMes                = tpsResult.maxMultipleEventStatistic;
        planetCandidateStruct.periodDays            = tpsResult.detectedOrbitalPeriodInDays;

        % timeOfFirstTransitInMjd is really in MJD (unlike bestPhaseInCadences, which is in super-resoluton cadences)
        planetCandidateStruct.epochKjd              = tpsResult.timeOfFirstTransitInMjd - kjd_offset_from_mjd;
                                                    
        planetCandidateStruct.numSesInMes           = int32(length(tpsResult.sesCombinedToYieldMes));
        planetCandidateStruct.fitSinglePulse        = tpsResult.fitSinglePulse;
        planetCandidateStruct.robustStatistic       = tpsResult.robustStatistic;
        planetCandidateStruct.chiSquare2Statistic   = chiSquare2Statistic; % the value that actually gets compared to the threshold
        planetCandidateStruct.chiSquareGofStatistic = chiSquareGofStatistic; % the value that actually gets compared to the threshold
        planetCandidateStruct.maxSesInMesStatistic  = tpsResult.maxSesInMesStatistic;
        planetCandidateStruct.thresholdForDesiredPfa= tpsResult.thresholdForDesiredPfa;   
        planetCandidateStruct.falseAlarmProbability = tpsResult.falseAlarmProbability;

    end
  
return

%=========================================================================================

% subfunction to compute the vetoes

function [tpsResult, fittedTrend, deemphasizedNormalizationTimeSeries, tpsModuleParameters] = ...
        compute_and_apply_vetoes( tpsResult, tpsModuleParameters, bootstrapParameters, ...
        foldingParameterStruct, forceChiSquareCalculation )

superResolutionFactor            = tpsModuleParameters.superResolutionFactor ;
usePolyFitTransitModel           = tpsModuleParameters.usePolyFitTransitModel ;
bootThreshReductionFactor        = tpsModuleParameters.bootstrapThresholdReductionFactor ;
maxMes                           = tpsResult.maxMultipleEventStatistic ;
waveletObject                    = tpsResult.waveletObject ;
deemphasisWeights                = tpsResult.deemphasisWeight ;
deemphasisWeightsSuperResolution = tpsResult.deemphasisWeightSuperResolution ;
normalizationTimeSeries          = tpsResult.normalizationTimeSeries ;
indexOfSesAdded                  = tpsResult.indexOfSesAdded ;
sesCombinedToYieldMes            = tpsResult.sesCombinedToYieldMes ;
fitSinglePulse                   = tpsResult.fitSinglePulse ;
nCadences                        = foldingParameterStruct.nCadences ;
trialTransitDurationInCadences   = foldingParameterStruct.trialTransitDurationInCadences ;

% initialize output
fittedTrend = [];
deemphasizedNormalizationTimeSeries = normalizationTimeSeries .* deemphasisWeights;

% generate the trial transit pulse train through the superResolutionClass   
scalingFilterCoeffts = get( waveletObject, 'h0' ) ;
superResolutionStruct = struct('superResolutionFactor', superResolutionFactor, ...
    'pulseDurationInCadences', trialTransitDurationInCadences, 'usePolyFitTransitModel', ...
    usePolyFitTransitModel ) ;
superResolutionObject = superResolutionClass( superResolutionStruct, scalingFilterCoeffts ) ;
superResolutionObject = set_statistics_time_series_shift_length( superResolutionObject) ; 

% generate a new pulse train that excludes transits falling in gaps
validSesIndex = indexOfSesAdded(sesCombinedToYieldMes ~= 0) ;

% Compute the maxSesInMes statistic
% Note: this only computes the maxSesInMes/Mes ratio, the period restriction is determined in determine_planet_candidate_status
tpsResult = compute_maxSesInMesStatistic_veto (tpsResult, tpsModuleParameters);
planetCandidateStruct = determine_planet_candidate_status( tpsResult, tpsModuleParameters) ;

% We continue to calcualte each veto until one does not pass then exit this function. A final call to determine_planet_candidate_status then returns if this
% trigger is a planet candidate.
if (~fitSinglePulse && planetCandidateStruct.maxSesInMesOkay)  || forceChiSquareCalculation
    
    transitModel = generate_trial_transit_pulse_train( superResolutionObject, ...
        indexOfSesAdded, nCadences ) ;

    % generate the padded in-transit cadence indicator
    nPadCadences = min( ceil(trialTransitDurationInCadences * 0.5), 4 ) ;
    inTransitIndicator = generate_padded_transit_indicator( transitModel, nPadCadences );
         
    % if we are doing the bootstrap prior to the other vetoes
    if ~isequal(tpsModuleParameters.bootstrapGaussianEquivalentThreshold, -1)  && ...
            isequal(bootThreshReductionFactor, -1)

        % generate the bootstrap input from various TPS ingredients
        bootstrapInputStruct = generate_tps_bootstrap_input( waveletObject, ...
            tpsResult, tpsModuleParameters, bootstrapParameters, foldingParameterStruct, ...
            inTransitIndicator );

        % get the deemphasizedNormalizationTimeSeries for output
        deemphasizedNormalizationTimeSeries = bootstrapInputStruct.deemphasizedNormalizationTimeSeries;

        % compute the bootstrap threshold to check for significance of the MES
        % against the background
        tpsResult = compute_threshold_by_bootstrap( bootstrapInputStruct, tpsResult, maxMes ) ;

    end

    % check for significance of the thresholdForDesiredPfa
    planetCandidateStruct = determine_planet_candidate_status( tpsResult, tpsModuleParameters) ;

    if (planetCandidateStruct.mesOkay && planetCandidateStruct.bootstrapOkay) || ...
            forceChiSquareCalculation

        % re-compute the whitener and detrend the flux now that we know where the transits are  
        removeTrend = true ;
        removeTransits = false ;
        [waveletObject, fittedTrend] = adjust_wavelet_object_for_transits( waveletObject, ...
            inTransitIndicator, removeTrend, removeTransits ) ;

        % generate a new pulse train that excludes transits falling in gaps
        transitModelRs = generate_trial_transit_pulse_train( superResolutionObject, ...
            validSesIndex, nCadences ) ;

        % compute the robust statistic
        warning('off','stats:statrobustfit:IterationLimit') ;
        tpsResult = compute_robust_statistic( waveletObject, transitModelRs, ...
            deemphasisWeights, tpsResult )  ;
        warning('on','stats:statrobustfit:IterationLimit') ;

        % now see whether the MES and RS are above threshold, if so we can go on to compute the
        % chi-square discriminators
        planetCandidateStruct = determine_planet_candidate_status( tpsResult, tpsModuleParameters ) ;

        if (planetCandidateStruct.rsOkay || forceChiSquareCalculation)

            % Add the new waveletObject to the superResolutionObject
            superResolutionObject = set_wavelet_object( superResolutionObject, waveletObject ) ;

            % compute the chi-square values
            tpsResult = compute_chisquare_veto( superResolutionObject, nCadences, validSesIndex, ...
                deemphasisWeights, deemphasisWeightsSuperResolution, tpsResult) ; 
            
            % check if the chi-square requirements were met
            planetCandidateStruct = determine_planet_candidate_status( tpsResult, tpsModuleParameters) ;
            
            % if we are doing the bootstrap after the vetoes and it hasnt been
            % calculated yet, then calculate it
            if isequal(tpsResult.thresholdForDesiredPfa, -1) && ...
                    ~isequal(bootThreshReductionFactor, -1) && ...
                    planetCandidateStruct.isPlanetACandidate == true
                
                % generate the bootstrap input from various TPS ingredients
                bootstrapInputStruct = generate_tps_bootstrap_input( waveletObject, ...
                    tpsResult, tpsModuleParameters, bootstrapParameters, foldingParameterStruct, ...
                    inTransitIndicator );
                
                % explicitly set the observedTransitCount to minSesInMesCount
                bootstrapInputStruct.observedTransitCount = tpsModuleParameters.minSesInMesCount;
                
                % explicitly set the deemphasizeQuartersWithoutTransits
                bootstrapInputStruct.deemphasizeQuartersWithoutTransits = false;

                % get the deemphasizedNormalizationTimeSeries for output
                deemphasizedNormalizationTimeSeries = bootstrapInputStruct.deemphasizedNormalizationTimeSeries;

                % compute the bootstrap threshold to check for significance of the MES
                % against the background
                tpsResult = compute_threshold_by_bootstrap( bootstrapInputStruct, tpsResult, maxMes ) ;
                
                % check to see if the bootstrap veto is met
                planetCandidateStruct = determine_planet_candidate_status( tpsResult, tpsModuleParameters) ;
                
                if planetCandidateStruct.isPlanetACandidate == true
                    % update the search threshold for other candidates on this
                    % pulse duration
                    tpsModuleParameters.searchTransitThreshold = ...
                        max( tpsModuleParameters.searchTransitThreshold, ...
                        tpsResult.thresholdForDesiredPfa - bootThreshReductionFactor );
                end
                
            end

        end

    end
    
end

return

%=========================================================================================

% subfunction to compute the weak secondary information

function weakSecondaryStruct = compute_weak_secondary_diagnostics( tpsResult, ...
    foldingParameterStruct, tpsModuleParameters, fittedTrend)

% initialize output
weakSecondaryStruct = initialize_weak_secondary_struct ;

% extract info from inputs
nCadences                      = foldingParameterStruct.nCadences ;
trialTransitPulseWidth         = foldingParameterStruct.trialTransitDurationInCadences ;
cadencesPerDay = tpsModuleParameters.cadencesPerHour / get_unit_conversion( 'hour2day' ) ;
usePolyFitTransitModel = tpsModuleParameters.usePolyFitTransitModel ;
weakSecondaryPeakRangeMultiplier = tpsModuleParameters.weakSecondaryPeakRangeMultiplier;
superResolutionFactor           = tpsModuleParameters.superResolutionFactor;
deemphasisWeightSuperResolution = tpsResult.deemphasisWeightSuperResolution ;
deemphasisWeight = tpsResult.deemphasisWeight ;
bestPhaseInCadences = tpsResult.bestPhaseInCadences * superResolutionFactor ;
bestOrbitalPeriodInCadences = tpsResult.bestOrbitalPeriodInCadences * superResolutionFactor ;
indexOfSesAdded = tpsResult.indexOfSesAdded ;
waveletObject = tpsResult.waveletObject ;

if exist('fittedTrend', 'var') && ~isempty(fittedTrend)
    % add the fittedTrend to the waveletObject and recompute fills
    outlierIndicators = get( waveletObject, 'outlierIndicators' );
    waveletObject = augment_outlier_vectors( waveletObject, ...
        outlierIndicators, [], fittedTrend ) ;
end

% set up the superResolutionObject
scalingFilterCoeffts = get( waveletObject, 'h0' ) ;
superResolutionStruct = struct('superResolutionFactor', superResolutionFactor, ...
    'pulseDurationInCadences', trialTransitPulseWidth, 'usePolyFitTransitModel', ...
    usePolyFitTransitModel ) ;
superResolutionObject = superResolutionClass( superResolutionStruct, scalingFilterCoeffts ) ;
superResolutionObject = set_statistics_time_series_shift_length( superResolutionObject) ;

% generate the trial pulse train
trialTransitPulseTrain = generate_trial_transit_pulse_train( superResolutionObject, ...
    indexOfSesAdded, nCadences ) ;

% pad the in-transit cadences to ensure primary is notched out but dont pad
% to get rid of more than half the cadences
nPadCadences = min( ceil( trialTransitPulseWidth * weakSecondaryPeakRangeMultiplier ), ...
    ceil(0.5 * (0.5 * bestOrbitalPeriodInCadences - trialTransitPulseWidth)) );

% get the in-transit cadence indicator including the padding
inTransitIndicator = generate_padded_transit_indicator( trialTransitPulseTrain, nPadCadences );

% adjust the waveletObject for the transits
removeTrend = false;
removeTransits = true;
[waveletObject, ~, inTransitIndicator] = adjust_wavelet_object_for_transits( waveletObject, ...
    inTransitIndicator, removeTrend, removeTransits ) ;

% add the new waveletObject to the superResolutionObject
superResolutionObject = set_wavelet_object( superResolutionObject, waveletObject ) ;

% compute hi-res time series
superResolutionObject =  set_hires_statistics_time_series( superResolutionObject, nCadences ) ;

% extract the hiRes time series for storage in the results
tpsResult.correlationTimeSeriesHiRes = get( superResolutionObject, 'correlationTimeSeriesHiRes' ) ;
tpsResult.normalizationTimeSeriesHiRes = get( superResolutionObject, 'normalizationTimeSeriesHiRes' ) ;

% update the deemphasisWeights to gap in-transit cadences
deemphasisWeight(inTransitIndicator) = 0 ;
if(superResolutionFactor > 1)
    inTransitIndicator = repmat( inTransitIndicator,1, superResolutionFactor ) ;
    inTransitIndicator = inTransitIndicator' ;
    inTransitIndicator = inTransitIndicator(:) ;
end   
deemphasisWeightSuperResolution(inTransitIndicator) = 0 ;
tpsResult.deemphasisWeightSuperResolution = deemphasisWeightSuperResolution ;

% redo the folding at the period of the TCE
[foldedStatisticAtPhasesComplete, phaseLagInCadences] = ...
    fold_statistics_at_trial_phases(tpsResult, bestOrbitalPeriodInCadences, tpsModuleParameters);
indexOfBestPhase = locate_center_of_asymmetric_peak( foldedStatisticAtPhasesComplete) ;
weakSecondaryPhaseInCadences = phaseLagInCadences(indexOfBestPhase) / superResolutionFactor;

% convert and sort phase
bestOrbitalPeriodInDays = bestOrbitalPeriodInCadences/(cadencesPerDay*superResolutionFactor);
phase = mod( phaseLagInCadences - bestPhaseInCadences, bestOrbitalPeriodInCadences ) / bestOrbitalPeriodInCadences ;
overOneHalf = phase > 0.5 ;
phase(overOneHalf) = phase(overOneHalf) - 1 ;
[phaseSorted, sortKey] = sort( phase ) ;
phaseInDays = phaseSorted * bestOrbitalPeriodInDays ;
foldedStatisticAtPhasesComplete = foldedStatisticAtPhasesComplete(sortKey) ;

% get the max phase info
indexOfBestPhase = locate_center_of_asymmetric_peak( foldedStatisticAtPhasesComplete) ;
bestPhaseInDays = phaseInDays(indexOfBestPhase) ;
weakSecondaryStruct.mes = foldedStatisticAtPhasesComplete ;
weakSecondaryStruct.phaseInDays = phaseInDays ;
weakSecondaryStruct.maxMesPhaseInDays = bestPhaseInDays ;
weakSecondaryStruct.maxMes = foldedStatisticAtPhasesComplete(indexOfBestPhase) ;
weakSecondaryStruct.mesMad = mad(foldedStatisticAtPhasesComplete(foldedStatisticAtPhasesComplete ~= 0),1) ;
weakSecondaryStruct.medianMes = median( foldedStatisticAtPhasesComplete(foldedStatisticAtPhasesComplete ~= 0) ) ;
weakSecondaryStruct.nValidPhases = sum( foldedStatisticAtPhasesComplete ~= 0 ) ;
if isnan(weakSecondaryStruct.mesMad)
    weakSecondaryStruct.mesMad = -1 ;
    weakSecondaryStruct.medianMes = -1;
end

% get the min phase info
indexOfBestPhase = locate_center_of_asymmetric_peak( -foldedStatisticAtPhasesComplete) ;
weakSecondaryStruct.minMesPhaseInDays = phaseInDays(indexOfBestPhase) ;
weakSecondaryStruct.minMes = foldedStatisticAtPhasesComplete(indexOfBestPhase) ;

% build a transit model for the weak secondary
[indexOfSesInMes, sesCombinedToYieldMes] = find_index_of_ses_added_to_yield_mes( ...
    bestOrbitalPeriodInCadences/superResolutionFactor, ...
    weakSecondaryPhaseInCadences, superResolutionFactor, ...
    tpsResult.correlationTimeSeriesHiRes, tpsResult.normalizationTimeSeriesHiRes, ...
    tpsResult.deemphasisWeightSuperResolution ) ;
transitModel = generate_trial_transit_pulse_train( superResolutionObject, ...
    indexOfSesInMes(sesCombinedToYieldMes ~= 0), nCadences ) ;

% compute the robust statistic
warning('off','stats:statrobustfit:IterationLimit') ;
robustStatisticResults = compute_robust_statistic( waveletObject, transitModel, deemphasisWeight )  ;
warning('on','stats:statrobustfit:IterationLimit') ;

% add results to weakSecondaryStruct
weakSecondaryStruct.depthPpm.value = 1e6 * robustStatisticResults.fittedDepth;
if ~isequal(robustStatisticResults.depthUncertainty, -1)
    weakSecondaryStruct.depthPpm.uncertainty = 1e6 * robustStatisticResults.depthUncertainty;
else
    weakSecondaryStruct.depthPpm.uncertainty = robustStatisticResults.depthUncertainty;
end
weakSecondaryStruct.robustStatistic = robustStatisticResults.robustStatistic;

return

%=========================================================================================
% function tpsResult = compute_maxSesInMesStatistic_veto (tpsResult, tpsModuleParameters)
%
% Subfunction to compute maxSesInMesVeto.
%
%   Passes statistic if
%       maxSesInMes / Mes < 0.9 OR  P < 90 Days;
%   Fails statistic if
%       maxSesInMes / Mes > 0.9 AND P > 90 Days;
%
% The final determination if the trigger passes the statistic is performed in determine_planet_candidate_status.
% This function is very simple but adding in so that the relevent comments are in one logical place.
%   
%
% Inputs:
%   tpsModuleParameters.maxSesInMesStatisticThreshold       --  [double] maxSesInMes / mes veto threshold {-1 => turn off this veto}
%   tpsModuleParameters.maxSesInMesStatisticPeriodCutoff    --  [double] Only check for periods longer than this in days
%
% Outputs:
%   tpsResult.maxSesInMesStatistic  -- [double] maxSesInMes / maxMes {-1 => not yet computed)
%=========================================================================================

function tpsResult = compute_maxSesInMesStatistic_veto (tpsResult, tpsModuleParameters)

    if (tpsResult.maxSesInMes == -1 || tpsResult.maxMultipleEventStatistic == -1 ||  tpsResult.maxMultipleEventStatistic == 0 || ...
                tpsModuleParameters.maxSesInMesStatisticThreshold == -1)
        tpsResult.maxSesInMesStatistic = -1;
    else
        tpsResult.maxSesInMesStatistic = tpsResult.maxSesInMes / tpsResult.maxMultipleEventStatistic;
    end

return

    
