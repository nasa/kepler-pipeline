function rho = ephemeris_match( epoch1, period1, epoch2, period2, durationHours, ...
    unitOfWork )
%
% ephemeris_match -- calculate the matching parameter between two transit ephemerii
%
% rho = ephemeris_match( epoch1, period1, epoch2, period2, durationHours, unitOfWork )
%    computes the fraction of transits of the shorter period ephemeris which fall within
%    durationHours/2 of the longer period ephemeris, given the unitOfWork (vector,
%    containing the start day and end day of the unit of work).  Argument durationHours
%    has units of hours, while all other arguments are in days. The two epochs and the
%    unit of work must all agree in terms of any absolute offset (ie, must all be MJD, or
%    all JD, or all KJD, or whatever).
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

  durationDays = durationHours * get_unit_conversion('hour2day') ;

% find the shorter of the two periods

  if period1 < period2
      shortPeriod = period1 ;
      shortEpoch  = epoch1  ;
      longPeriod  = period2 ;
      longEpoch   = epoch2  ;
  else
      shortPeriod = period2 ;
      shortEpoch  = epoch2  ;
      longPeriod  = period1 ;
      longEpoch   = epoch1  ;
  end
  
% move the epochs to be within 1 period of the start of the unit of work

  shortEpoch = adjust_epoch( shortEpoch, shortPeriod, unitOfWork(1) ) ;
  longEpoch  = adjust_epoch( longEpoch,  longPeriod,  unitOfWork(1) ) ;
  
% generate the vectors of transit times

  shortTransitTime = shortEpoch:shortPeriod:unitOfWork(2) ;
  longTransitTime  = longEpoch:longPeriod:unitOfWork(2) ;
  
% adjust the shapes of the vectors to be opposite

  shortTransitTime = shortTransitTime(:) ;
  longTransitTime  = (longTransitTime(:))' ;
  nShortTransits   = length(shortTransitTime) ;
  nLongTransits    = length(longTransitTime) ;
  
% for each of the long-period transits, find the time to the nearest short-period transit;
% this can be done by converting both vectors into matrices, performing a subtraction, and
% then doing a column-wise min(abs()) operation

  deltaTime = repmat( shortTransitTime, 1, nLongTransits ) - ...
      repmat( longTransitTime, nShortTransits, 1 ) ;
  
  minTimeToLongTransit = min(abs( deltaTime ) ) ;
  
% how many meet the criterion?

  rho = length( find( minTimeToLongTransit <= durationDays/2 ) ) / nShortTransits ;

return

%=========================================================================================

% subfunction which moves the epoch to be within 1 period of the start of unit of work

function epochFinal = adjust_epoch( epochInitial, period, unitOfWorkStart )

% convert the epoch into the # of days since start of unit of work

  epochRelative = epochInitial - unitOfWorkStart ;
  
% figure out how many whole periods away we are

  nPeriodsNeededToCorrect = floor( epochRelative / period ) ;
  
% apply a correction

  epochFinal = epochRelative - period * nPeriodsNeededToCorrect + unitOfWorkStart ;
  
return

