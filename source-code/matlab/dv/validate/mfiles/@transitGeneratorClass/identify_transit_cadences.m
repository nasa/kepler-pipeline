function [transitNumber, refEpochTransit] = identify_transit_cadences( ...
    transitGeneratorObject, bkjdTimestamps, transitBufferFactor )
%
% identify_transit_cadences -- identify the cadences which correspond to transits in a 
% transit model object
%
% transitNumber = identify_transit_cadences( transitGeneratorObject, bkjdTimestamps,
%    transitBufferFactor ) determines, for a given transit model and set of timestamps,
%    which of the timestamps overlap with a transit, and which transit it is that they
%    overlap.  The returned transitNumber is a vector, with length equal to the length of
%    mjdTimestamps; transitNumber(iCadence) == the number of the transit which the cadence
%    overlaps, if it overlaps a transit, or zero if the cadence overlaps no transits.
%    Note that transitNumber == 1 for the first transit in the timestamp vector, which may
%    not correspond to the transit epoch in the transit model (ie, the transit epoch may
%    point to the second, third, etc. transit in the series).  Argument
%    transitBufferFactor is used to identify cadences which buffer the transits.  When
%    transitBufferFactor == 0, only cadences on a transit are identified with that
%    transit; for nonzero values, cadences which are within transitBufferFactor transit
%    durations of the transit are also returned (ie, transitBufferFactor == 1 will return
%    transitNumber values which identify groups of cadences which are 3 transit durations
%    long in total).
%
% [transitNumber, refEpochTransit] = identify_transit_cadences( ... ) also returns the
%    number of the transit which contains the reference epoch (usually == 1, but not
%    necessarily).
%
% Version date:  2013-March-06.
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

% Modification History:
%
%    2013-March-06, JL:
%        set minimum transit duration to be 1.5 hours
%    2010-May-05, PT:
%        convert from transitEpochMjd to transitEpochBkjd.
%    2010-January-07, PT:
%        bugfix:  if there are no transits at all in the time series, set refEpochTransit
%        to zero.
%
%=========================================================================================

% setting default value for transitBufferFactor

  if ~exist('transitBufferFactor','var') || isempty(transitBufferFactor)
      transitBufferFactor = 0 ;
  end

% argument checking:  mjdTimestamps must be a numeric vector without NaN or Inf values,
% transitBufferFactor must be a scalar > -1 (+Inf allowed)

  if ~isvector( bkjdTimestamps ) || ~isnumeric( bkjdTimestamps ) || ...
          any( isnan( bkjdTimestamps ) | isinf( bkjdTimestamps ) )
      error('dv:identifyTransitCadences:bkjdTimestampsInvalid', ...
          'identify_transit_cadences:  bkjdTimestamps must be a numeric vector free of NaN or Inf values') ;
  end
  
  if ~isscalar( transitBufferFactor ) || ~isnumeric( transitBufferFactor ) || ...
          transitBufferFactor < 0
      error('dv:identifyTransitCadences:transitBufferFactorInvalid', ...
          'identify_transit_cadences:  transitBufferFactor must be a numeric scalar >= 0') ;
  end
    
% Determine the cadence duration using information packaged in the transit generator
% object

  timePars = transitGeneratorObject.timeParametersStruct ;
  cadenceDurationSec = (timePars.exposureTimeSec + timePars.readoutTimeSec) * ...
      timePars.numExposuresPerCadence ;
  cadenceDurationDays = cadenceDurationSec * get_unit_conversion('sec2day') ;
    
% get the cadence timing information from the transit model

  transitEpochBkjd = transitGeneratorObject.planetModel.transitEpochBkjd ;
  transitDurationHours = transitGeneratorObject.planetModel.transitDurationHours ;
  if transitDurationHours < 1.5
      transitDurationHours = 1.5;             % set minimum transit duration to be 1.5 hours
  end
  transitDurationDays = transitDurationHours * get_unit_conversion('hour2day') ;
  orbitalPeriodDays = transitGeneratorObject.planetModel.orbitalPeriodDays ;
  transitHalfDurationDays = transitDurationDays / 2 ;
  
  cadenceDurationPeriods = cadenceDurationDays / orbitalPeriodDays ;

% the actual half-duration we are interested in includes the buffer factor, so compute
% that now

  intervalHalfDurationDays = transitHalfDurationDays * (1 + 2*transitBufferFactor) ;
  
% compute the start and end of the interval centered on the transit epoch (henceforth this
% is the "reference interval").  

  refIntervalStart = transitEpochBkjd - intervalHalfDurationDays ;
  refIntervalEnd   = transitEpochBkjd + intervalHalfDurationDays ;
  
% For each cadence, compute the number of periods since the start and end of the transit
% denoted by the reference epoch

  periodsFromStartRefInterval = (bkjdTimestamps - refIntervalStart) / ...
      orbitalPeriodDays ;
  periodsFromEndRefInterval   = (bkjdTimestamps - refIntervalEnd) / ...
      orbitalPeriodDays ;
  
% to make sure that we get each cadence which overlaps a transit, no matter how slightly,
% offset the values above by half a cadence interval

  periodsFromStartRefInterval = periodsFromStartRefInterval + cadenceDurationPeriods / 2 ;
  periodsFromEndRefInterval   = periodsFromEndRefInterval    - cadenceDurationPeriods / 2 ;
  
% A cadence is "in transit" when its periods from the start and periods from the end round
% down to different numbers (ie, if it's 9.1 periods from the start but 8.9 periods from
% the end, it's in a transit)

  inTransit = ( floor( periodsFromStartRefInterval ) > floor( periodsFromEndRefInterval ) ) ;
  
% the cadence number is given by the floor value of the start ref interval vector, offset
% appropriately so that all values are >= 1.  While we are here, figure out which transit
% contains the reference epoch

  transitNumber = floor( periodsFromStartRefInterval ) ;
  transitNumber = transitNumber - min(transitNumber)  ;
  
% one interesting corner case is a situation in which the earliest cadence falls during a
% transit.  In this case, its transit number will be zero, but the minimum transit number
% will also be zero (in the normal case, with non-transit cadences prior to the first
% transit cadence, the minimum transit number would be -1).  Handle that corner case now.

  [earliestBkjd,indexEarliest] = min(bkjdTimestamps) ;
  if inTransit(indexEarliest)
      transitNumber = transitNumber + 1 ;
  end
  
% any cadence which is not in a transit should have transitNumber -> 0

  transitNumber( ~inTransit ) = 0 ;
  
% identify the transit with the reference epoch in it by finding the transit cadence which
% is closest in time to the reference epoch

  [minTimeOffset,epochIndex] = min( abs( bkjdTimestamps(inTransit) - transitEpochBkjd ) ) ;
  
% It is possible that the transit epoch does not correspond to a transit which is
% represented in our timestamps (due to gaps in the timestamp vector, or the epoch falling
% on a transit which is before the first or after the last timestamp).  In this case, the
% time offset will be larger than 1/2 of an orbital period, and we should return a
% refEpochTransit value of zero.  Otherwise, return the transitNumber of the cadence at
% epochIndex.  Also, if the time range does not include any transits at all, then the
% refEpochTransit will also be zero.

  if ( minTimeOffset > orbitalPeriodDays / 2 )
      refEpochTransit = 0 ;
  elseif isempty( minTimeOffset )
      refEpochTransit = 0 ;
  else
      transitNumberInTransit = transitNumber(inTransit) ;
      refEpochTransit = transitNumberInTransit(epochIndex) ;
  end
  
return

% and that's it!

%
%
%
