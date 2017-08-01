function [multipleEventStatistic, periodInCadences, phaseInCadences, ...
        possiblePeriodsInCadences, foldedStatisticAtTrialPeriods, ...
        foldedStatisticMinAtTrialPeriods, phaseLagOfMinStatistic, ...
        meanMesEstimate, validPhaseSpaceFraction, mesHistogram] = ...
        locate_strongest_statistics( tpsResult, tpsModuleParameters, ...
        possiblePeriodsInCadences, maxLoopCount, searchThreshold )
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
%
% locate_strongest_statistics -- locate the period and phase of the strongest multiple
% event statistics for a given target
%
% [multipleEventStatistic, periodInCadences, phaseInCadences, possiblePeriodsInCadences,
%    foldedStatisticAtTrialPeriods, foldedStatisticMinAtTrialPeriods,
%    phaseLagOfMinStatistic] = locate_strongest_statistics( tpsResult,
%    tpsModuleParameters, possiblePeriodsInCadences, maxLoopCount, searchThreshold )
%    performs the search of the multiple event statistic across all periods and phases,
%    returning the strongest MES values along with their period and phase (in
%    super-resolution cadences), plus the minimum MES value as a function of period and
%    the vector of periods (in super-resolution cadences) which have been searched.  The
%    number of values returned depends upon the values of maxLoopCount and
%    searchThreshold:
%
%    If the number of MES values above searchThreshold is greater than maxLoopCount, then
%       the maxLoopCount largest values are returned ;
%    If the number of MES values above searchThreshold is less than maxLoopCount but
%       greater than zero, all of the MES values above searchThreshold are returned ;
%    If there are no MES values above searchThreshold, the largest single MES value will
%       be returned even though it is below threshold.
%

%=========================================================================================

% begin with the folding across all periods and phases

  cadencesPerDay                 = tpsModuleParameters.cadencesPerDay;
  superResolutionFactor          = tpsModuleParameters.superResolutionFactor;
  transitLengthSuperResolutionCadences = round( tpsResult.trialTransitPulseInHours * ...
      get_unit_conversion('hour2day') * cadencesPerDay ) * superResolutionFactor ;

  t0 = clock ;
  [foldedStatisticAtTrialPeriods,  phaseOfMaxMes, possiblePeriodsInCadences, ...
      foldedStatisticMinAtTrialPeriods, phaseLagOfMinStatistic, ...
      meanMesEstimate, validPhaseSpaceFraction, mesHistogram ]  = ...
      fold_statistics_at_trial_periods(tpsResult, tpsModuleParameters, ...
      possiblePeriodsInCadences );
    
  foldedStatisticsForThisStar = foldedStatisticAtTrialPeriods ; 
  t1 = clock ;
  disp(['     ... folding completed in ', ...
      num2str(etime(t1,t0)),' seconds ... ']) ;


% allocate 3 square arrays of maxLoopCount size

  mesValues = -1 * ones( maxLoopCount ) ;
  periodCadences = -1 * ones( maxLoopCount ) ;
  phaseCadences = -1 * ones( maxLoopCount ) ;

% search over periods

  stillSearchingPeriods = true ;
  nPeriods = 0 ; 
  nLatchedValues = 0 ;
  t0 = clock ;
  valuesAboveThreshold = true ;
  minMesToLatch = searchThreshold ;
  while stillSearchingPeriods && nPeriods < maxLoopCount

      indexOfBestPeriod = locate_center_of_asymmetric_peak( ...
            foldedStatisticsForThisStar, possiblePeriodsInCadences ) ;
      bestMultipleEventStatistic = foldedStatisticsForThisStar( indexOfBestPeriod ) ;

%     if we're still on nPeriods == 0, and the best MES is already below threshold,
%     then that means that ALL of the MES are below threshold.  In this case we want
%     to capture the single strongest event, even though it's weak

      if nPeriods == 0 && bestMultipleEventStatistic < minMesToLatch
          valuesAboveThreshold = false ;          
      end

%     lternately, if we're past nPeriods == 0 and the best MES is below threshold, we
%     can stop looking at new periods

      if bestMultipleEventStatistic < minMesToLatch && valuesAboveThreshold
          stillSearchingPeriods = false ;
      else

%         otherwise, we have to fold this period across phases

          bestPeriod = possiblePeriodsInCadences( indexOfBestPeriod ) ;
          nPeriods = nPeriods + 1 ;
          periodCadences(:,nPeriods) = bestPeriod ;

          [foldedStatisticAtTrialPhases, phaseLagInCadences, containsNaNs] = ...
            fold_statistics_at_trial_phases(tpsResult, ...
            possiblePeriodsInCadences(indexOfBestPeriod), tpsModuleParameters);
          nPhases = 0 ;
          stillSearchingPhases = true ;

          while stillSearchingPhases && nPhases < maxLoopCount

              indexOfBestPhase = locate_center_of_asymmetric_peak( ...
                  foldedStatisticAtTrialPhases, phaseLagInCadences ) ;
              bestMultipleEventStatistic = ...
                  foldedStatisticAtTrialPhases( indexOfBestPhase ) ;

%             we need to capture at least the strongest MES, and its corresponding phase,
%             for each period; we also need to capture all phases for a given period which
%             are above the detection threshold
              
              if bestMultipleEventStatistic < minMesToLatch && nPhases > 0
                  stillSearchingPhases = false ;

              else

                  nPhases = nPhases + 1 ;
                  nLatchedValues = nLatchedValues + 1 ;

%                 in the case of a target on which there are an extremely large number
%                 of period-phase combinations above threshold, we can speed things up
%                 by periodically raising the latch threshold:  the idea is that once
%                 we already have maxLoopCount latched values, any additional
%                 latchings have to have MES at least as large as the weakest latched
%                 value.  The code below periodically updates the min latching value.
%                 This will make the code slightly slower in cases where there aren't
%                 many values to consider latching, but much faster when there are
%                 many.

                  mesValues(nPhases,nPeriods) = bestMultipleEventStatistic ;
                  bestPhase = phaseLagInCadences(indexOfBestPhase) ;
                  phaseCadences(nPhases,nPeriods) = bestPhase ;
                  if mod(nLatchedValues,maxLoopCount)==0
                      mesValuesVector = mesValues(:) ;
                      [~,sortKey] = sort(mesValuesVector,'descend') ;
                      minMesToLatch = mesValuesVector(sortKey(maxLoopCount)) ;
                  end

%                 now mask out that phase

                  [~,edgeIndex] = min( abs(phaseLagInCadences - ...
                      (bestPhase+transitLengthSuperResolutionCadences)) ) ;
                  peakRange = edgeIndex - indexOfBestPhase ;
                  [peakStart,peakEnd] = determine_range_of_asymmetric_peak( ...
                       foldedStatisticAtTrialPhases, peakRange ) ;

                  foldedStatisticAtTrialPhases( peakStart:peakEnd ) = 0 ;

              end % latching logic

%             At this point, if there aren't any values above threshold we have
%             nonetheless latched the strongest one which is present.  There's no longer
%             any point to the search, so set exit conditions

              if ~valuesAboveThreshold
                  stillSearchingPhases = false ;
                  stillSearchingPeriods = false ;
              end

          end % while-loop over searching phases at this period

%         mask out the period which has just been completed and iterate the loop

          [~,edgeIndex] = min( abs(possiblePeriodsInCadences - ...
             (bestPeriod+transitLengthSuperResolutionCadences)) ) ;
          peakRange = edgeIndex - indexOfBestPeriod ;
          [peakStart,peakEnd] = determine_range_of_asymmetric_peak( ...
              foldedStatisticsForThisStar, peakRange ) ;

          foldedStatisticsForThisStar( peakStart:peakEnd ) = 0 ;

      end % search-this-period condition

  end % search over periods while-loop

% OK:  now we have a set of candidates which includes the strongest signals in this
% time series, but at least potentially there are too many and they are in an arbitrary
% order.  Also, if none of the values are above threshold, we still need to return at
% least one value.

  mesValues = mesValues(:) ;
  periodCadences = periodCadences(:) ;
  phaseCadences = phaseCadences(:) ;
  
% we want to get the strongest value from the list of MES values. HOWEVER: if all of the
% values are <= -1, then doing this will result in a mess. In that case, the light curve
% is so pathological that there's no point trying to return anything useful, so just
% return the first thing which was found.
  
  if any( mesValues > -1 )
      [~,sortKey] = sort(mesValues,'descend') ;
      nValuesOfInterest = max( length(find(mesValues>=searchThreshold)), 1 ) ;
  else
      sortKey = 1 ;
      nValuesOfInterest = 1 ;
  end
  maxSortKeyLength = min(nValuesOfInterest,maxLoopCount) ;
  sortKey = sortKey(1:maxSortKeyLength) ;

  multipleEventStatistic = mesValues(sortKey) ;
  periodInCadences = periodCadences(sortKey) ;
  phaseInCadences = phaseCadences(sortKey) ;
  t1 = clock ;
  disp(['     ... returned ', num2str(maxSortKeyLength),' detection candidates for analysis in ', ...
      num2str(etime(t1,t0)),' seconds ... ']) ;
      
return

