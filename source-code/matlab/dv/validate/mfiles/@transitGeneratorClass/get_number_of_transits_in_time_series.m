function [numExpectedTransits, numActualTransits, transitStruct] = ...
    get_number_of_transits_in_time_series( transitGeneratorObject, bkjdTimestamps, ...
       gapIndicators, fillIndices )
% 
% get_number_of_transits_in_time_series -- determine the number of transits which are in a
% given time series, and which are expected
%
% [numExpectedTransits, numActualTransits] = get_number_of_transits_in_time_series(
%    transitGeneratorObject, bkjdTimestamps, gapIndicators, fillIndices ) determines the
%    number of expected transits in a time range indicated by bkjdTimestamps, and the
%    number of actual transits (actual = expected - transits which are entirely gapped or
%    filled). If bkjdTimestamps is missing or empty, the timestamps in the
%    transitGeneratorClass object are used.  If gapIndicators is missing, then all gap
%    indicators are assumed to be false (ie, no gaps).  If fillIndices is empty or
%    missing, then all values are assumed to be unfilled (ie, all good).
%
% [..., transitStruct] = get_number_of_transits_in_time_series( ... ) returns a structure
%    vector with length == numExpectedTransits, with the following fields:
%
%        bkjdTransitStart == start time of the transit
%        bkjdTransitEnd   == end time of the transit
%        gapIndicator    == true if the transit is a missing transit.
%
% All MJDs are assumed to be barycentric-corrected MJDs.
%
% Version date:  2010-May-05.
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
%    2010-May-05, PT:
%        convert from transitEpochMjd to transitEpochBkjd.
%    2010-January-05, PT:
%        bugfix:  handle case in which the epoch does not fall within the range of the
%        timestamps.
%    2009-October-08, PT:
%        bugfix:  off-by-1 error in transitStruct construction.
%    2009-August-28, PT:
%        bugfix:  handle case where numExpectedTransits == 0 correctly.
%    2009-August-07, PT:
%        fix logic bug in transitStruct.gapIndicators assignment.  Refactor code to get
%        transit number as a function of cadences available separately (see
%        identify_transit_cadences.m).
%    2009-May-28, PT:
%        a cadence is in a transit if any portion of the cadence overlaps in time with any
%        portion of the transit (correction from original code, which only looked to see
%        whether the cadence mid-time overlaps any portion of the transit).
%    2009-May-27, PT:
%        support for fill indices as well as gap indicators.
%
%=========================================================================================

% if the mjdTimestamps is missing or empty, fill it from the transitGeneratorClass member

  if (~exist('bkjdTimestamps', 'var') || isempty(bkjdTimestamps))
      bkjdTimestamps = transitGeneratorObject.cadenceTimes ;
  end
  
% if the gapIndicators is missing or empty, set it to all false (ie, no gaps)

  if (~exist('gapIndicators', 'var') || isempty(gapIndicators))
      gapIndicators = false(size(bkjdTimestamps)) ;
  end
  
% if the fillIndices is missing, set it to empty

  if (~exist('fillIndices', 'var') || isempty(fillIndices))
      fillIndices = [] ;
  end
  
% combine the fill indices and gap indicators into one vector which indicates any entry in
% the time series which should not be used for any reason

  gapIndicators(fillIndices) = true ;
  
% get the relevant parameters from the object -- in this case, the epoch, the half-length
% of the transit, and the orbital period

  transitEpochBkjd = transitGeneratorObject.planetModel.transitEpochBkjd ;
  transitDurationHours = transitGeneratorObject.planetModel.transitDurationHours ;
  transitDurationDays = transitDurationHours * get_unit_conversion('hour2day') ;
  orbitalPeriodDays = transitGeneratorObject.planetModel.orbitalPeriodDays ;
  transitHalfDurationDays = transitDurationDays / 2 ;
  
% get the transit number for each cadence, and while we are at it find out which transit
% number contains the epoch
  
  [transitNumber, refEpochTransit] = identify_transit_cadences( transitGeneratorObject, ...
      bkjdTimestamps, 0 ) ;
  
% the number of transits expected can be determined by looking at the unique non-zero
% values in the transitNumber vector

  expectedTransits = unique( transitNumber(transitNumber~=0) ) ;
  numExpectedTransits = length(expectedTransits) ;
  
% now, refEpochTransit can be zero if the reference epoch doesn't fall within the
% timestamps at all.  Handle that case now, but only if the # of expected transits is not
% zero (if # expected transits == 0, then the epoch and period are such that no transits
% fall on the timestamps in any event).

  if refEpochTransit == 0 && numExpectedTransits > 0
      
      refEpochTransit = ( transitEpochBkjd - min(bkjdTimestamps) ) / orbitalPeriodDays ;
      refEpochTransit = ceil( refEpochTransit ) ;
      
  end
  
% set all transitNumber values which correspond to gapped cadences to zero

  transitNumber(gapIndicators) = 0 ;
  
% The # of actual transits is the # of transits for which at least 1 timestamp is not
% gapped

  actualTransits = unique( transitNumber(transitNumber~=0) ) ;
  numActualTransits = length(actualTransits) ;
  
% construct the transit information structure based on the expectedTransits vector, and if
% there's a value in expectedTransits which isn't in actualTransits then that is a gapped
% transit.  

  if ( numExpectedTransits > 0 )

      bkjdTransitStart = transitEpochBkjd - transitHalfDurationDays + orbitalPeriodDays * ...
          ( expectedTransits - refEpochTransit ) ;
      bkjdTransitEnd   = bkjdTransitStart + transitDurationDays ;
      gapIndicator = ~ismember(expectedTransits,actualTransits) ;

      transitCell = num2cell([bkjdTransitStart(:) bkjdTransitEnd(:) gapIndicator(:)]) ;
      transitStruct = cell2struct(transitCell,{'bkjdTransitStart' ; 'bkjdTransitEnd' ; ...
          'gapIndicator'},2) ;
      
  else
      
      transitStruct = struct( 'bkjdTransitStart',[], 'bkjdTransitEnd',[], ...
          'gapIndicator',[] ) ;
      
  end
  
return






