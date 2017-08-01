function self = test_cdpp_calculation_with_transit_depths( self )
%
% test_cdpp_calculation_with_transit_depths -- unit test of the TPS CDPP calculation given
% transits of several depths
%
% This unit test compares the CDPP computed for the case of white noise, white noise + a
% shallow transit, white noise + a giant transit.  The CDPP for a shallow transit should
% be somewhat larger than for white noise, and a giant transit should be moderately larger
% still (note that this is with MAD-based calculation of the CDPP without removal of giant
% transits).
%
% This unit test is intended for execution in the mlunit context.  For standalone
% execution, use the following syntax:
%
%      run(text_test_runner, testTpsClass('test_cdpp_calculation_with_transit_depths'));
%
% Version date:  2010-December-02.
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
%    2010-December-02, PT:
%        update expected CDPP agreement -- now that we no longer remove giant transits
%        from the light curve used to produce the whitening filter, and use the MAD
%        calculation of in-band noise, we get a somewhat increased CDPP for giant transits
%        compared to white noise or shallow transits.
%    2010-October-25, PT:
%        update expected CDPP agreement (loosen tolerances moderately).
%    2010-October-01, PT:
%        update method signature (include harmonics array as input field).
%    2010-July-15, PT:
%        update expected parameter ranges based on more detailed studies.
%
%=========================================================================================

  disp(' ... testing CDPP computation for several transit depths ... ') ;

% set the test data path and retrieve the tps-full struct for instantiation

  tpsDataFile = 'tps-full-struct-for-instantiation' ;
  tpsDataStructName = 'tpsInputStruct' ;
  tps_testing_initialization ;
  
% set the random number generator to the correct value - subsequent limits
% are based on using this seed so the unit test essentially requires that
% the results dont change much.  This alleviates the need to use a long UOW
% to satisfy the central limit theorem

  s = RandStream('mcg16807','Seed',10) ;
  RandStream.setDefaultStream(s) ;
  
% construct the necessary flux time series

  timeSeriesLength = length( tpsInputStruct.cadenceTimes.startTimestamps ) ;
  
  [whiteNoise,randomWalk,harmonicSine,harmonicCosine,transit] = ...
      generate_tps_test_time_series( timeSeriesLength, harmonicPeriodCadences, ...
      finalPhaseShiftRadians, transitEpochCadence, transitPeriodCadences, ...
      transitDurationCadences ) ;
  
  tpsTargets = tpsInputStruct.tpsTargets ;
  
  tpsInputStruct.tpsModuleParameters.performQuarterStitching = true ;
  
% Use 50 PPM as the white noise RMS amplitude, and the CDPP in this case should be about
% 18.9 PPM for a 7-cadence transit pulse and giant transit threshold should be about 337.25 PPM
% (10 * MAD of 50 PPM white noise)

  whiteNoiseAmplitude = 50e-6 ;
  expectedCdpp = whiteNoiseAmplitude / sqrt(transitDurationCadences) ;
  expectedMad = whiteNoiseAmplitude * 0.6745 ;
  
% for a shallow transit, use about 10 * the expected CDPP; for a giant transit, use about
% 50 * the expected MAD

  noTransitFlux = whiteNoiseAmplitude * whiteNoise ;
  shallowTransitFlux = noTransitFlux + 10 * expectedCdpp * transit ;
  giantTransitFlux = noTransitFlux + 50  * expectedMad * transit ;
  
  tpsTargets.fluxValue = noTransitFlux - median(noTransitFlux) ;
  tpsInputStruct.tpsTargets(1) = tpsTargets ;
  tpsTargets.fluxValue = shallowTransitFlux - median(shallowTransitFlux) ;
  tpsInputStruct.tpsTargets(2) = tpsTargets ;
  tpsInputStruct.tpsTargets(2).keplerId = tpsInputStruct.tpsTargets(1).keplerId + 1 ;
  tpsTargets.fluxValue = giantTransitFlux - median(giantTransitFlux) ;
  tpsInputStruct.tpsTargets(3) = tpsTargets ;
  tpsInputStruct.tpsTargets(3).keplerId = tpsInputStruct.tpsTargets(2).keplerId + 1 ;
  
% validate the struct to get necessary fields added in

  tpsInputStruct = validate_tps_input_structure( tpsInputStruct ) ;
  
% instantiate the object and put it through the CDPP computer

  tpsObject = tpsClass( tpsInputStruct ) ;
  [tpsObject, harmonicTimeSeries, fittedTrend] = perform_quarter_stitching( tpsObject) ;
  cdppResults = compute_cdpp_time_series( tpsObject, harmonicTimeSeries, fittedTrend ) ;
  rmsCdpp = [cdppResults.rmsCdpp] ;
  pulseLength = tpsInputStruct.tpsModuleParameters.requiredTrialTransitPulseInHours ;
  
% check the RMS CDPP values -- we expect that the shallow transits will be within 25% of
% the no-transits case, and the giant transits within about 40% of the no-transits case.
% NB that the 3-hour, 6-hour, and 12-hour results are grouped together!

  for iPulseLength = 1:3
      
      whiteIndex = 3*(iPulseLength-1) + 1 ;
      shallowIndex = whiteIndex + 1 ;
      giantIndex = whiteIndex + 2 ;
      
      shallowRatio = rmsCdpp( shallowIndex ) / rmsCdpp( whiteIndex ) ; % 1.07,1.071, 1.121
      giantRatio   = rmsCdpp( giantIndex)    / rmsCdpp( whiteIndex ) ; % 1.189, 1.2, 1.26
      
      mlunit_assert( shallowRatio > 0.99 && shallowRatio <= 1.15, ...
          [ 'Shallow transit CDPP for ', num2str(pulseLength(iPulseLength)),...
          ' hour pulse not as expected!' ] ) ;
      mlunit_assert( giantRatio > 0.99 && giantRatio <= 1.4, ...
          [ 'Giant transit CDPP for ', num2str(pulseLength(iPulseLength)),...
          ' hour pulse not as expected!' ] ) ;
      
  end
  
% check that the 6 hr white-noise CDPP is ~ 1/sqrt(2) x the 3 hr, and that the 12 hr is ~
% 1/2 x the 3-hr

  mlunit_assert( abs( rmsCdpp(4) - 1/sqrt(2) * rmsCdpp(1) ) / rmsCdpp(1) < 0.02, ...
      '3-hour vs 6-hour CDPP estimates not as expected!' ) ; % 0.0067
  mlunit_assert( abs( rmsCdpp(7) - 1/2 * rmsCdpp(1) ) / rmsCdpp(1) < 0.02, ...
      '3-hour vs 12-hour CDPP estimates not as expected!' ) ; % 0.0135
  
  disp('') ;
  
return  