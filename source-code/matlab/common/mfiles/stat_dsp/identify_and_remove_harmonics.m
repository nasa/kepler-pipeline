function [harmonicsRemovedTimeSeries, harmonicTimeSeries, harmonicCombDetected, ...
    finalHarmonicCorrectionObject] = ...
    identify_and_remove_harmonics( fluxValues, gapFillParametersStruct, ...
                  harmonicsIdentificationParametersStruct, fillIndices, ...
                  protectedPeriod, initialHarmonicCorrectionObject )
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
% identify_and_remove_harmonics -- identify and remove from the flux time series any
% narrow-band features
%
% [harmonicsRemovedTimeSeries, harmonicTimeSeries, harmonicCombDetected] = 
%    identify_and_remove_harmonics( fluxValues, gapFillParametersStruct, 
%    harmonicsIdentificationParametersStruct, fillIndices, protectedPeriod ) performs a
%    periodogram analysis on a flux time series to identify narrow band harmonic features
%    and remove same.  Depending on the options set in the relevant parameters struct, it
%    may attempt to identify and retain harmonic combs which usually represent a transit
%    signature and not a set of narrow-band features.
%
% [... , harmonicCorrectionObject] = identify_and_remove_harmonics( ... ) returns the
%    final harmonicCorrectionClass object to the caller.
%
% [...] = identify_and_remove_harmonics( ... , initialHarmonicCorrectionObject ) allows
%    the caller to pass in a harmonicCorrectionClass object for use in initializing the
%    frequencies which are to be removed in this process.
%

%=========================================================================================

% STEP 1:  condition the flux by removing any giant transits and taking out any median
% offset which has snuck into the time series

  tooManySamplesInGiantTransit = false;
  gapIndicators = false( size( fluxValues ) ) ;
  meanOffset = mean(fluxValues) ;
  fluxValues = fluxValues - meanOffset ;
  nCadences = length(fluxValues) ;

  [indexOfGiantTransits1] = identify_giant_transits(fluxValues, ...
      gapIndicators, gapFillParametersStruct);
  [indexOfGiantTransits2] = identify_giant_transits(-fluxValues, ...
      gapIndicators, gapFillParametersStruct);
  indexOfGiantTransits = ...
      unique([indexOfGiantTransits1; indexOfGiantTransits2]);

% note if too many cadences have been identified, otherwise gap the
% cadences

  nSamplesInGiantTransit = length(indexOfGiantTransits);

  if nSamplesInGiantTransit / nCadences > 0.5
    tooManySamplesInGiantTransit = true;
  elseif nSamplesInGiantTransit > 0
    gapIndicators(indexOfGiantTransits) = true;
  end 

% skip harmonics identification if too many samples are in giant transits

  if tooManySamplesInGiantTransit
    harmonicsRemovedTimeSeries = fluxValues ;
    harmonicCombDetected = false ;
    harmonicTimeSeries = zeros( size( fluxValues ) ) ;
    warning('common:identifyAndRemoveHarmonics:tooManySamplesInGiantTransits', ...
        ['identify_and_remove_harmonics:  too many samples in giant transits, ', ...
         'skipping harmonic removal']) ;
    return
  end 

% linearly interpolate the gapped data values and add fill indices

  originalFluxValuesGiantTransits = fluxValues(indexOfGiantTransits) ;
  fluxValues = interp1(find(~gapIndicators), fluxValues(~gapIndicators), ...
    (1:nCadences)', 'linear', 'extrap');
  gapIndicators( fillIndices ) = true ;
  
% STEP 2:  iteratively remove the frequencies which stick up sufficiently above the
% background noise (iteratively because the frequencies which stick up are included in the
% calculation of the background noise).  This is done with a harmonicCorrectionClass
% object.

  sampleIntervalSeconds = gapFillParametersStruct.cadenceDurationInMinutes * ...
      get_unit_conversion('min2sec') ;
  harmonicCorrectionObject = harmonicCorrectionClass( ...
      harmonicsIdentificationParametersStruct ) ;
  harmonicCorrectionObject.set_time_series( fluxValues, sampleIntervalSeconds, ...
      gapIndicators ) ;
  if exist( 'protectedPeriod', 'var' ) && ~isempty( protectedPeriod )
      harmonicCorrectionObject.set_protected_frequency( protectedPeriod ) ;
  end
      
% if the caller passed in an initial harmonic correction object, use it to initialize the
% frequencies for removal

  centralFrequenciesHz = [] ; 
  if exist( 'initialHarmonicCorrectionObject', 'var' ) && ...
          isa( initialHarmonicCorrectionObject, 'harmonicCorrectionClass' )
%      harmonicCorrectionObject.copy_frequencies( initialHarmonicCorrectionObject ) ;
        centralFrequenciesHz = initialHarmonicCorrectionObject.get_central_frequencies ;
  end
  
% set the timeout and start timing

  timeoutInMinutes = harmonicsIdentificationParametersStruct.timeOutInMinutes ;
  timeoutInSeconds = timeoutInMinutes * get_unit_conversion('min2sec') ;
  
  timeout = false ;
  t0 = clock ;
  
% keep looping until either we've found everything we're going to, or we run out of time;
% note that after removing transit signatures, we go around for another pass of
% identifying, removing, and then if need be restoring frequencies, and we do this until
% the system converges to a self-consistent state (no more frequencies or harmonic combs
% can be detected) or we run out of time.

  needToIterateFullProcess = true ;
  harmonicCombDetected = false ;
%  while needToIterateFullProcess && ~timeout
  
      needToSearchForHarmonics = true ;
      while needToSearchForHarmonics && ~timeout
          needToSearchForHarmonics = ...
              harmonicCorrectionObject.add_harmonics(centralFrequenciesHz) ;
          centralFrequenciesHz = [] ;
          timeSoFar = etime( clock, t0 ) ;
          timeout = timeSoFar > timeoutInSeconds ;
      end
      if timeout
          warning('common:identifyAndRemoveHarmonics:harmonicIdentificationTimeLimitReached', ...
              'identify_and_remove_harmonics:  time limit for harmonic identification exceeded') ;
      end

    % if the caller wants to preserve harmonic combs, do that now

      if harmonicsIdentificationParametersStruct.retainFrequencyCombsEnabled
          harmonicCombDetectedThisTime = harmonicCorrectionObject.restore_combs ;
          needToIterateFullProcess = harmonicCombDetectedThisTime ;
      else
          harmonicCombDetectedThisTime = false ;
          needToIterateFullProcess = false ;
      end
      
%     accumulate a master harmonic removal flag

      harmonicCombDetected = harmonicCombDetected | harmonicCombDetectedThisTime ;
  
%  end
  
% return flux time series and get outta here

  harmonicsRemovedTimeSeries = harmonicCorrectionObject.get_harmonic_free_time_series + ...
      meanOffset ;
  harmonicTimeSeries         = harmonicCorrectionObject.get_harmonic_time_series ;
  harmonicsRemovedTimeSeries(indexOfGiantTransits) = ...
      originalFluxValuesGiantTransits - harmonicTimeSeries(indexOfGiantTransits) ;
  
  finalHarmonicCorrectionObject = harmonicCorrectionObject ;
  
% restore the too many harmonics warning message

  warning('on','Common:addHarmonics:harmonicsLimitReached') ;


return

