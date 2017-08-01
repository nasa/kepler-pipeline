function [dvResultsStruct, removedEclipsingBinary, gappedTransitStruct] = ...
    identify_and_gap_eclipsing_binaries( dvDataObject, dvResultsStruct, iTarget, ...
    thresholdCrossingEvent )
%
% identify_and_gap_eclipsing_binaries -- identify signatures of an eclipsing binary and
% gap same
%
% [dvResultsStruct, removedEclipsingBinary, gappedTransitStruct] = 
%    identify_and_gap_eclipsing_binaries( dvDataObject, dvResultsStruct, iTarget,
%    thresholdCrossingEvent ) examines the transits associated with a threshold crossing
%    event and attempts to determine whether the transits are caused by an eclipsing
%    binary rather than a planet.  If such a determination is made, then the transits
%    which are associated with the TCE are gapped in the dvResultsStruct, and the
%    removedEclipsingBinary flag is set to true; otherwise, removedEclipsingBinary is set
%    to false, and dvResultsStruct is returned unchanged.  The returned
%    GappedTransitStruct contains information on each of the transits which has been
%    gapped out (its depth, duration, etc).
% 
% The method uses two tests for eclipsing binaries:  a pure depth test, and an aspect
%    ratio test, which identifies wide but relatively shallow transits.  For a given TCE,
%    all of the transits must be detected and all of the odd transits OR all of the even
%    ones must match either the depth criterion or the aspect ratio criterion in order to
%    be removed.
%
% Note that identify_and_gap_eclipsing_binaries is not meant to be a definitive test for
%    eclipsing binaries, but rather a conservative test which eliminates only the EB
%    signatures which are most difficult for the DV planet fitter to handle.  Many EBs
%    will not be removed by this method and will be passed to the planet fitter.
%
% Version date:  2009-December-18.
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

% Modification Date:
%
%    2009-December-18, PT:
%        bugfix:  when computing the depth of a transit with gapped cadences, do not
%        consider the values of the gapped cadences!
%
%=========================================================================================

% get the parameters for the tests out of the configuration struct

  transitDepthLimit = ...
      dvDataObject.planetFitConfigurationStruct.eclipsingBinaryDepthLimitPpm / 1e6 ;
  transitAspectRatioLimitCadences = ...
      dvDataObject.planetFitConfigurationStruct.eclipsingBinaryAspectRatioLimitCadences ;
  aspectRatioTestDepthLimit = ...
      dvDataObject.planetFitConfigurationStruct.eclipsingBinaryAspectRatioDepthLimitPpm ...
      / 1e6 ;

% default to NOT gapping out any signatures

  removedEclipsingBinary = false ;
  gappedTransitStruct = [] ;

% step 1:  find the MJD mid-times of all transits associated with the TCE, bearing in mind
% that there is always a slight possibility that the epoch in the TCE is not the first
% transit in the time series but maybe the second, third, etc (or that the time for the
% "first" transit could be gapped)

  cadenceTimes = dvDataObject.barycentricCadenceTimes(iTarget).midTimestamps + ...
      kjd_offset_from_mjd ;
    
  lowestTransit = ceil( ...
      ( cadenceTimes(1)-thresholdCrossingEvent.epochMjd ) / ...
      thresholdCrossingEvent.orbitalPeriod ) ;
  highestTransit = floor( ...
      (cadenceTimes(end) - thresholdCrossingEvent.epochMjd ) / ...
      thresholdCrossingEvent.orbitalPeriod ) ;

  transitIndex = lowestTransit:highestTransit ;
  transitMidTimes = transitIndex * thresholdCrossingEvent.orbitalPeriod + ...
      thresholdCrossingEvent.epochMjd ;
  
% find the times of the last transit before the time series, and the next transit after
% the time series

  timeOfEarlyTransit = min( transitMidTimes ) - thresholdCrossingEvent.orbitalPeriod ;
  timeOfLateTransit  = max( transitMidTimes ) + thresholdCrossingEvent.orbitalPeriod ;
  
% step 2:  locate all the giant transits and repackage their information transit by
% transit

  fluxTimeSeries = dvResultsStruct.targetResultsStruct(iTarget).residualFluxTimeSeries ;
  gapIndicators = fluxTimeSeries.gapIndicators ;
  gapIndicators( fluxTimeSeries.filledIndices ) = true ;

  giantTransitCadences = identify_giant_transits( ...
      fluxTimeSeries.values, ...
      gapIndicators, ...
      dvDataObject.gapFillConfigurationStruct ) ;
  
  giantTransitStruct = repackage_giant_transit_info( giantTransitCadences, ...
      fluxTimeSeries.values, ...
      gapIndicators, ...
      cadenceTimes ) ;
  
% step 3:  find the giant transit which contains each transit mid-time, if any.  There may
% be a nice vectorized way to do this, but it's not a performance issue to do it in a loop
% which is easier to code and debug

  if ~isempty( giantTransitStruct )

      giantTransitStartTimes    = [giantTransitStruct.startMjd] ;
      giantTransitEndTimes      = [giantTransitStruct.endMjd] ;
      giantTransitDepth         = [giantTransitStruct.transitDepth] ;
      giantTransitAspectRatio   = [giantTransitStruct.aspectRatioCadences] ;
      giantTransitGapIndicators = [giantTransitStruct.gapIndicator] ;
      giantTransitAllGapped     = [giantTransitStruct.allGapped] ;

      giantTransitOfTransit = zeros( size( transitMidTimes ) ) ;
      for iTransit = 1:length(transitMidTimes)
          transitTimesMatch = transitMidTimes(iTransit) >= giantTransitStartTimes & ...
              transitMidTimes(iTransit) <= giantTransitEndTimes ;
          if any( transitTimesMatch )
              giantTransitOfTransit(iTransit) = find( transitTimesMatch, 1 ) ;
          end
      end
  
%     step 4:  if all of the transits in the TCE are in a giant transit, then look to see
%     which gap-out conditions, if any, are met by each transit

      if ( all( giantTransitOfTransit > 0 ) )

          isGapped = giantTransitGapIndicators( giantTransitOfTransit ) ;
          isAllGapped = giantTransitAllGapped( giantTransitOfTransit ) ;
          isReallyTooDeep = giantTransitDepth( giantTransitOfTransit ) >= transitDepthLimit ;
          isReallyTooWide = giantTransitAspectRatio( giantTransitOfTransit ) >= ...
              transitAspectRatioLimitCadences & ...
              giantTransitDepth( giantTransitOfTransit ) >= aspectRatioTestDepthLimit ;
      
%         for a gapped transit, just assume that it would have matched either condition

          isTooDeep = isReallyTooDeep | isGapped ;
          isTooWide = isReallyTooWide | isGapped ;
          
%         break into even and odd transits.  The reason we consider evens and odds
%         separately is that, for an EB which has a circular orbit, it will typically have
%         2 transits which are evenly spaced and have different depths.  We want to remove
%         this EB's signature, even though only alternate transits actually match the
%         criterion.

          isTooDeepOdd    = isTooDeep(1:2:end) ;
          isTooDeepEven   = isTooDeep(2:2:end) ;
          isTooWideOdd    = isTooWide(1:2:end) ;
          isTooWideEven   = isTooWide(2:2:end) ;
          isAllGappedEven = isAllGapped(2:2:end) ;
          isAllGappedOdd  = isAllGapped(1:2:end) ;
          
          if isempty(isTooDeepEven)
              isTooDeepEven = false ;
          end
          if isempty(isTooWideEven)
              isTooWideEven = false ;
          end
      
%         if all the transits match one condition, or the other, then we can declare that
%         this is too likely to be an EB and gap it; otherwise, leave it alone and the
%         fitter will have to take its chances.  Note that, in order to signal an EB,
%         there must be at least 1 real giant transit in the transit set we look at (ie,
%         they can't all be there on account of having all their transits gapped).  Also,
%         at least 1 of the transits needs to actually meet the criteria for removal

%           ebOddCadences  = all( isTooDeepOdd )  || all( isTooWideOdd ) ;
%           ebEvenCadences = all( isTooDeepEven ) || all( isTooWideEven ) ;
          ebOddCadences  = ( all( isTooDeepOdd ) && any( isReallyTooDeep ) ) || ...
              ( all( isTooWideOdd ) && any( isReallyTooWide ) ) ;
          ebEvenCadences = ( all( isTooDeepEven ) && any( isReallyTooDeep ) ) || ...
              ( all( isTooWideEven ) && any( isReallyTooWide ) ) ;
          ebOddCadences  = ebOddCadences  && any( ~isAllGappedOdd ) ;
          ebEvenCadences = ebEvenCadences && any( ~isAllGappedEven ) ;

          if ebOddCadences || ebEvenCadences
              removedEclipsingBinary = true ;
              dvResultsStruct = gap_giant_transits( dvResultsStruct, iTarget, ...
                  giantTransitStruct, giantTransitOfTransit ) ;
              gappedTransitStruct = giantTransitStruct( giantTransitOfTransit ) ;
              
%             if there's a giant transit at the beginning or end of the time series, and
%             the nearest transit prior to or subsequent to the time series is close
%             enough, gap the one at the end

              dvResultsStruct = gap_giant_transit_at_time_series_edge( dvResultsStruct, ...
                  iTarget, giantTransitStruct, giantTransitOfTransit, cadenceTimes, ...
                  timeOfEarlyTransit, timeOfLateTransit ) ;
              
          end

      end
  
  end % giant-transit struct empty conditional
  
return

%=========================================================================================

% subfunction which repackages the cadence information on giant transits into a transit-by
% transit structure

function giantTransitStruct = repackage_giant_transit_info( giantTransitCadences, ...
    fluxValues, gapIndicators, cadenceTimes )

% define the return struct

  giantTransitStructTemplate = struct( 'startCadence', [], 'endCadence', [], ...
      'startMjd', [], 'endMjd', [], 'gapIndicator', [], 'transitDepth', [], ...
      'transitDurationCadences', [], 'aspectRatioCadences', [] ) ;
  
% combine the gap indicators and the transit cadences, and sort them

  gapIndices = find( gapIndicators ) ;
  interestingCadences = sort( unique( ...
      [ giantTransitCadences(:) ; gapIndices(:) ] ) ) ;
  nCadences = length( cadenceTimes ) ;
  
% we can identify individual transits by use of the diff operator -- the diff is 1 for
% cadences in the same giant transit

  cadenceDiff = diff( interestingCadences ) ;
  
  transitTermini = find(cadenceDiff > 1) ;
  
  if ~isempty( transitTermini )
      
      transitTermini = [0 ; transitTermini(:) ; length(interestingCadences)] ;
  
%     go through the transits and put in their start and end information, adding 1 cadence
%     at each end if possible as a buffer

      giantTransitStruct = repmat( giantTransitStructTemplate, length(transitTermini)-1, 1 ) ;
      for iTransit = 1:length(transitTermini)-1
          giantTransitStruct(iTransit).startCadence = ...
              interestingCadences( transitTermini(iTransit)+1 ) ;
          giantTransitStruct(iTransit).endCadence = ...
              interestingCadences( transitTermini(iTransit+1) ) ;  
          trueCadenceRange = [giantTransitStruct(iTransit).startCadence: ...
              giantTransitStruct(iTransit).endCadence] ;
          giantTransitStruct(iTransit).startCadence = ...
              max( giantTransitStruct(iTransit).startCadence-1, 1 ) ;
          giantTransitStruct(iTransit).endCadence = ...
              min( giantTransitStruct(iTransit).endCadence+1, nCadences ) ;
          giantTransitStruct(iTransit).startMjd = ...
              cadenceTimes( giantTransitStruct(iTransit).startCadence ) ;
          giantTransitStruct(iTransit).endMjd = ...
              cadenceTimes( giantTransitStruct(iTransit).endCadence ) ;
          cadenceRange = ...
              giantTransitStruct(iTransit).startCadence:giantTransitStruct(iTransit).endCadence ;
          gappedExtendedCadenceRange = ismember( cadenceRange, gapIndices ) ;
          if any( gappedExtendedCadenceRange )
              giantTransitStruct(iTransit).gapIndicator = true ;
          else
              giantTransitStruct(iTransit).gapIndicator = false ;
          end
          gappedCadences = ismember( trueCadenceRange(:), gapIndices ) ;
          if ( all( gappedCadences ) )
              giantTransitStruct(iTransit).allGapped = true ;
          else
              giantTransitStruct(iTransit).allGapped = false ;
          end
          giantTransitStruct(iTransit).transitDepth = range( ...
              fluxValues( cadenceRange( ~gappedExtendedCadenceRange ) ) ) ;
          giantTransitStruct(iTransit).transitDurationCadences = ...
              giantTransitStruct(iTransit).endCadence - ...
                giantTransitStruct(iTransit).startCadence + 1 ;
          giantTransitStruct(iTransit).aspectRatioCadences = ...
              ( giantTransitStruct(iTransit).transitDurationCadences ) / ...
                giantTransitStruct(iTransit).transitDepth ;
      end
      
  else
      
      giantTransitStruct = [] ;
      
  end
  
return

%=========================================================================================

% subfunction which gaps the flux time series in the locations of the transits which
% correspond to the transits we want to remove

function dvResultsStruct = gap_giant_transits( dvResultsStruct, iTarget, ...
              giantTransitStruct, giantTransitOfTransit )
          
% unpack

  gapIndicators = dvResultsStruct.targetResultsStruct(iTarget).residualFluxTimeSeries.gapIndicators ;

  startCadence = [giantTransitStruct.startCadence] ;
  endCadence   = [giantTransitStruct.endCadence] ;
  
  
% loop over transits to remove and set the gap indicators to true

  for iTransit = giantTransitOfTransit(:)'
      gapIndicators( startCadence(iTransit):endCadence(iTransit) ) = true ;
  end
  
  dvResultsStruct.targetResultsStruct(iTarget).residualFluxTimeSeries.gapIndicators = ...
      gapIndicators ;
  
return

%=========================================================================================

% subfunction which gaps the giant transit which overlaps the beginning or end of the time
% series if there is an unseen transit which is close enough in time to warrant the action

function dvResultsStruct = gap_giant_transit_at_time_series_edge( dvResultsStruct, ...
                  iTarget, giantTransitStruct, giantTransitOfTransit, cadenceTimes, ...
                  timeOfEarlyTransit, timeOfLateTransit )

% unpack

  gapIndicators = dvResultsStruct.targetResultsStruct(iTarget).residualFluxTimeSeries.gapIndicators ;

  startCadence = [giantTransitStruct.startCadence] ;
  endCadence   = [giantTransitStruct.endCadence] ;
  
  nCadences = length(cadenceTimes) ;
  
% find the max duration of any giant transit which is already gapped

  gappedTransitDuration = cadenceTimes( endCadence( giantTransitOfTransit ) ) - ...
      cadenceTimes( startCadence( giantTransitOfTransit ) ) ;
  longestGappedTransitDuration = max( gappedTransitDuration ) ;
  
% find the transits which overlap the start and end cadences, if any

  leadingGiantTransitIndex  = find( startCadence == 1 ) ;
  trailingGiantTransitIndex = find( endCadence == nCadences ) ;
  
% If there is a leading giant transit, AND there is a predicted transit which lies within
% 1 transit-time prior to the first cadence, THEN gap the leading-edge giant transit

  if ~isempty( leadingGiantTransitIndex ) && ...
          cadenceTimes(1) - timeOfEarlyTransit <= longestGappedTransitDuration
      gapIndicators( startCadence(leadingGiantTransitIndex):endCadence(leadingGiantTransitIndex) ) = true ;
  end
  
% use similar logic for the trailing giant transit

  if ~isempty( trailingGiantTransitIndex ) && ...
          timeOfLateTransit - cadenceTimes(end) <= longestGappedTransitDuration
      gapIndicators( startCadence(trailingGiantTransitIndex):endCadence(trailingGiantTransitIndex) ) = true ;
  end

% assign the gap indicators back onto the dvResultsStruct

  dvResultsStruct.targetResultsStruct(iTarget).residualFluxTimeSeries.gapIndicators = ...
      gapIndicators ;
  
return