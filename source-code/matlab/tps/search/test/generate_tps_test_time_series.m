function [whiteNoise, randomWalk, harmonicSine, harmonicCosine, transit] = ...
    generate_tps_test_time_series( timeSeriesLength, harmonicPeriodCadences, ...
    finalPhaseShiftRadians, transitEpochCadence, transitPeriodCadences, ...
    transitDurationCadences ) 
%
% generate_tps_test_time_series -- construct a set of time series vectors for use in TPS
% tests
%
% [whiteNoise, randomWalk, harmonicSine, harmonicCosine, transit] =
%    generate_tps_test_time_series( timeSeriesLength, harmonicPeriodCadences,
%    finalPhaseShiftRadians, transitEpochCadence, transitPeriodCadences,
%    transitDurationCadences ) generates a time series of white noise, a random-walk time
%    series which goes to zero at first and last cadence, the sine and cosine terms of a
%    phase-shifting harmonic, and a unit transit vector.  These time series can be
%    combined to produce final flux time series for use in TPS testing.
%
% Version date:  2010-June-16.
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
%=========================================================================================

% time in cadences:

  t = 1:timeSeriesLength ; t = t(:) ;

% generate the white noise

  whiteNoise = randn(timeSeriesLength,1) ;
  
% generate the random walk, then subtract off the necessary slope to get to zero value at
% start and end

  randomWalk = cumsum(randn(timeSeriesLength,1)) ;
  randomWalk = randomWalk - randomWalk(1) ;
  randomWalk = randomWalk - (t-1) * randomWalk(end) / (timeSeriesLength-1) ;
  
% construct the phase variation parameter

  phasePar = harmonicPeriodCadences * finalPhaseShiftRadians / ...
      (2 * pi * (timeSeriesLength-1)^2) ;
  
% construct the sine-like and cosine-like phase-shifting harmonics

  harmonicArgument = 2*pi/harmonicPeriodCadences * (t-1) + ...
      2*pi/harmonicPeriodCadences * phasePar * (t-1).^2 ;
  harmonicSine = sin(harmonicArgument) ;
  harmonicCosine = cos(harmonicArgument) ;
  
% now construct the transit vector -- for simplicity, the transit uses a square pulse.
% Also for simplicity, the start cadence is rounded to an integer, the duration is rounded
% to an odd integer, the period is rounded to an integer.  

  transitEpochCadence = round(transitEpochCadence) ;
  transitPeriodCadences = round(transitPeriodCadences) ;
  transitDurationCadences = 1 + 2*floor(transitDurationCadences/2) ;
  halfDurationCadences = (transitDurationCadences-1)/2 ;
  
% determine the # of transits

  nTransits = floor( ( timeSeriesLength - transitEpochCadence + halfDurationCadences ) / ...
      transitPeriodCadences ) + 1 ;
  
% construct the list of cadences which are in transit

  transitCadences = (1:transitDurationCadences) - 1 ;
  transits = (0:nTransits - 1) * transitPeriodCadences ;
  transitCadences = repmat( transitCadences, nTransits, 1 ) ;
  transits = repmat( transits(:), 1, transitDurationCadences ) ;
  transitCadences = transitEpochCadence - halfDurationCadences + transitCadences + transits ;
  transitCadences = sort(transitCadences(:)) ;
  transitCadences( transitCadences > timeSeriesLength ) = [] ;
  
  transit = zeros( timeSeriesLength, 1 ) ;
  transit( transitCadences ) = -1 ;
 
return