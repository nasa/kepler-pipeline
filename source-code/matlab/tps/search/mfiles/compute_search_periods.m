function possiblePeriodsInCadences = compute_search_periods( ...
    tpsModuleParameters, trialTransitPulseInHours, nCadences )
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% possiblePeriodsInCadences = compute_search_periods( tpsModuleParameters)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Compute the search periods given the tpsModuleParameters and the pulse
% duration
%
% Inputs: tpsModuleParameters: validated set of module parameters
%         trialTransitPulseInHours: pulse duration
%         nCadences: number of cadences in the original flux time series
%
% Outputs: possiblePeriodsInCadences: vector of the periods to search
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
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

% Unpack
cadencesPerDay = tpsModuleParameters.cadencesPerDay;
cadencesPerHour = tpsModuleParameters.cadencesPerHour;
superResolutionFactor = tpsModuleParameters.superResolutionFactor;
maxFoldingsInPeriodSearch = tpsModuleParameters.maxFoldingsInPeriodSearch;
rho = tpsModuleParameters.searchPeriodStepControlFactor;

% get the min and max periods
minimumSearchPeriodInDays = get_min_search_period_days( tpsModuleParameters, ...
    trialTransitPulseInHours ) ;
maximumSearchPeriodInDays = get_max_search_period_days( tpsModuleParameters, ...
    trialTransitPulseInHours ) ;

% convert to superResolution cadences
minSearchPeriodInCadences = minimumSearchPeriodInDays * cadencesPerDay * ...
    superResolutionFactor;
maxSearchPeriodInCadences = maximumSearchPeriodInDays * cadencesPerDay * ...
    superResolutionFactor;
transitDurationInCadences = trialTransitPulseInHours * cadencesPerHour * ...
    superResolutionFactor;
nCadences = nCadences * superResolutionFactor;

% At this time we dynamically set min and max search durations, which means that until
% this moment we do not know whether we will have min period > max period.  If this
% happens it is an unrecoverable situation and we need to start signalling up the call
% chain that no search is possible and that the search must be exited ASAP.  

if maxSearchPeriodInCadences < minSearchPeriodInCadences
    error('TPS:computeSearchPeriods:noFoldingPossible', ...
        'compute_search_periods:  min folding period exceeds max period') ;
end

% If the trial periods are small, then fractional sampling intervals are
% required --> single event statistics need to be interpolated which is
% time consuming; instead segment the full length time series and combine
% the results

maxSeparationInCadences = 4 * (1-rho) * transitDurationInCadences; % rho correlation

% count the number of periods

nPeriodsInSearch = compute_periods( minSearchPeriodInCadences, ...
    maxSearchPeriodInCadences, maxFoldingsInPeriodSearch, maxSeparationInCadences, ...
    nCadences ) ;

% now go back and construct the actual period vector

[~,possiblePeriodsInCadences] = compute_periods( minSearchPeriodInCadences, ...
    maxSearchPeriodInCadences, maxFoldingsInPeriodSearch, maxSeparationInCadences, ...
    nCadences, nPeriodsInSearch ) ;

return

%=========================================================================================

% subfunction which either counts or else fills in values of the desired periods to search
% in cadences

function [nPeriods,possiblePeriodsInCadences] = compute_periods( ...
    minSearchPeriodInCadences, maxSearchPeriodInCadences, maxFoldingsInPeriodSearch, ...
    maxSeparationInCadences, nCadences, nPeriods ) 

% two use cases -- either we know the number of periods or else we don't

  if ~exist( 'nPeriods', 'var' ) || isempty( nPeriods )
      possiblePeriodsInCadences = [] ;
  else
      possiblePeriodsInCadences = zeros(nPeriods,1) ;
  end
  
  periodStepCount =1;
  periodInCadences = minSearchPeriodInCadences;

  while (periodInCadences <= maxSearchPeriodInCadences)	% step over period range with variable step size (deltaT)
      if ~isempty( possiblePeriodsInCadences )
         possiblePeriodsInCadences(periodStepCount) = periodInCadences;   
      end

%     period step small enough s.t. shift is <= TransitDuration_in_Days/4
%     there is rho% correlation between successive signals at T, T+dT

      if maxFoldingsInPeriodSearch ~= -1
          nTransits = min(ceil(nCadences/periodInCadences),maxFoldingsInPeriodSearch);
      else
          nTransits = ceil(nCadences/periodInCadences);
      end

      deltaPeriodInCadences = min(maxSeparationInCadences/nTransits,1) ; % rho% correlation

%     when we get to the point of stepping the period in one-cadence intervals, round the
%     period to the nearest cadence in the interest of prissiness
      
      if deltaPeriodInCadences == 1 && periodInCadences < ceil(periodInCadences)
          periodInCadences = ceil(periodInCadences) ;
      else  
          periodInCadences = periodInCadences + deltaPeriodInCadences;
     end

      periodStepCount = periodStepCount+1;

  end
  
  nPeriods = periodStepCount - 1 ;
  
return