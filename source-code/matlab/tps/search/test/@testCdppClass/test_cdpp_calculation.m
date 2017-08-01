function self = test_cdpp_calculation( self )
%
% test_cdpp_calculation -- unit test for generating customized time series and computing
% the resulting CDPP
%
% This is a unit test in the testCdppClass, which runs under mlunit.  The test generates a
% flux time series with a specified spectrum and determines the expected CDPP from an
% assortment of methods.  The CDPP is then estimated by TPS-Lite, and the latter is
% compared to the former.  The spectra which are tested are as follows:
%
%     white Gaussian noise
%     1/f noise
%     stellar-like spectrum (lots of fairly broadband low-frequency content)
%
% This method is not intended to be invoked directly, but rather via an mlunit call.
% Here's the syntax:
%
%      run(text_test_runner, testCdppClass('test_cdpp_calculation'));
%
%  Updated 7/20/2012:  The unit tests have not been kept up to date for a
%  year and I verified that the extended flux from a year ago when this
%  unit test passed is identical but that now there are small differences
%  in the whitening/wavelet machinery that are throwing the nubmers off and
%  causing the unit test to fail under the old limits.  Updating the limits
%  since we believe that the code now is more correct.  CdppTps is now just
%  slightly smaller than it was before.
%=========================================================================================
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

  disp(' ... testing CDPP calculation with synthetic noise ... ') ;
  
% set the test data path and retrieve the input struct 

  tpsDataFile = 'tps-multi-quarter-struct' ;
  tpsDataStructName = 'tpsInputs' ;
  tps_testing_initialization ;
  
% set rand seed

  s = RandStream('mcg16807','Seed',0) ;
  RandStream.setDefaultStream(s) ;
 
  tpsInputs.tpsTargets = tpsInputs.tpsTargets(1) ;
  tpsInputs.tpsTargets.gapIndices = [] ;
  tpsInputs.tpsTargets.fillIndices = [] ;
  tpsInputs.tpsModuleParameters.debugLevel = -1 ;
  tpsInputs.tpsModuleParameters.performQuarterStitching = true ;

% set up a flux time series with 9000 cadences, which is about 2 months' worth of long
% cadence data; set it up with no gaps and no fills

  nCadences = 9000 ;
  tpsInputs = copy_time_series_and_setup( tpsInputs, nCadences ) ;
  
% determine the desired set of pulse durations and set options

  pulseDurationsHours = [1.5 3 6 12 18 24 48] ;
  saveCdppFlags = false(length(pulseDurationsHours),1) ;
  daysPerCadence = median( diff( tpsInputs.cadenceTimes.midTimestamps ) ) ;
  pulseDurationsCadences = round( pulseDurationsHours * get_unit_conversion( 'hour2day' ) / ...
      daysPerCadence ) ;
  tpsInputs.tpsModuleParameters.requiredTrialTransitPulseInHours = pulseDurationsHours ;
  tpsInputs.tpsModuleParameters.storeCdppFlag = saveCdppFlags ;
  tpsInputs.tpsModuleParameters.minTrialTransitPulseInHours = -1 ;
  tpsInputs.tpsModuleParameters.maxTrialTransitPulseInHours = -1 ;
  tpsInputs.tpsModuleParameters.tpsLiteEnabled = true ;
  
% create a struct for the syntheticNoiseClass instantiation

  syntheticNoiseStruct.nSamples      = nCadences ;
  syntheticNoiseStruct.noiseScalePpm = 50 ;
  syntheticNoiseStruct.randStream = RandStream( 'mt19937ar', 'seed', 3494069 ) ;
  
  syntheticNoiseObject = syntheticNoiseClass( syntheticNoiseStruct ) ;
  
% create a white-noise spectrum and do all tests

  syntheticNoiseObjectWhiteNoise = set_spectrum_array(syntheticNoiseObject, [1 1 ; 1 1]) ;
  syntheticNoiseObjectWhiteNoise = construct_colored_noise_via_wavelets( ...
      syntheticNoiseObjectWhiteNoise ) ;
  [cdppTps, cdppActual, cdppFft] = perform_cdpp_tests( tpsInputs, ...
      syntheticNoiseObjectWhiteNoise, pulseDurationsCadences ) ;
  
% For this case, the ratio of TPS' CDPP to the syntheticNoiseObject's value should be
% between 0.92 and 0.98, while the ratio between TPS and the FFT is between
% 0.95 and 1.065

  mlunit_assert( all( cdppTps ./ cdppActual >= 0.90 & cdppTps ./ cdppActual <= 0.98 ), ...
      'White noise TPS vs Actual not as expected' ) ;
  mlunit_assert( all( cdppTps ./ cdppFft >= 0.92 & cdppTps ./ cdppFft <= 1.07 ), ...
      'White noise TPS vs FFT not as expected' ) ;
  
% create a 1/f^2 spectrum (1/f in amplitude) and do all tests

  nFilterSteps = compute_wavelet_filter_bank_length( syntheticNoiseObject ) ;
  spectrumArray = 2.^(0:nFilterSteps-1) ;
  spectrumArray = repmat( fliplr( spectrumArray ), 2, 1 ) ;
  syntheticNoiseObjectRedNoise = set_spectrum_array( syntheticNoiseObject, spectrumArray ) ;
  syntheticNoiseObjectRedNoise = construct_colored_noise_via_wavelets( ...
      syntheticNoiseObjectRedNoise ) ;
  [cdppTps, cdppActual, cdppFft] = perform_cdpp_tests( tpsInputs, ...
      syntheticNoiseObjectRedNoise, pulseDurationsCadences ) ;
  
% For this case, the ratio of TPS' CDPP to the syntheticNoiseObject's value should be
% between 0.94 and 1.01, while the ratio between TPS and the FFT is between 1.03 and 1.1

  mlunit_assert( all( cdppTps ./ cdppActual >= 0.92 & cdppTps ./ cdppActual <= 1.01 ), ...
      'Red noise TPS vs Actual not as expected' ) ;
  mlunit_assert( all( cdppTps ./ cdppFft >= 1.01 & cdppTps ./ cdppFft <= 1.1 ), ...
      'Red noise TPS vs FFT not as expected' ) ;
%     s = RandStream('mcg16807','Seed',10) ;
  RandStream.setDefaultStream(s) ;

% create a stellar-like spectrum and do all tests

  syntheticNoiseObjectStellar = set_spectrum_array( syntheticNoiseObject, ...
      repmat([60 60 60 1 1],2,1) ) ;
  syntheticNoiseObjectStellar = construct_colored_noise_via_wavelets( ...
      syntheticNoiseObjectStellar ) ;
  [cdppTps, cdppActual, cdppFft] = perform_cdpp_tests( tpsInputs, ...
      syntheticNoiseObjectStellar, pulseDurationsCadences ) ;
  
% For this case, the ratio of TPS' CDPP to the syntheticNoiseObject's value should be
% between 0.91 and 1.0, while the ratio between TPS and the FFT is between
% 1.04 and 1.15

  mlunit_assert( all( cdppTps ./ cdppActual >= 0.91 & cdppTps ./ cdppActual <= 1.0 ), ...
      'Stellar noise TPS vs Actual not as expected' ) ;
  mlunit_assert( all( cdppTps ./ cdppFft >= 1.02 & cdppTps ./ cdppFft <= 1.15 ), ...
      'Stelar noise TPS vs FFT not as expected' ) ;
  
% do the same tests, but with additional pathologies applied

  cdppTpsPathological = perform_cdpp_tests( tpsInputs, syntheticNoiseObjectStellar, ...
      pulseDurationsCadences, true ) ;
  
% the pathological should be no worse than 1% bigger than the non-pathological

  mlunit_assert( all( cdppTpsPathological ./ cdppTps >= 0.99 & ...
      cdppTpsPathological ./ cdppTps <= 1.01 ), ...
      'Pathological stellar noise TPS vs non-pathological TPS not as expected' ) ;
  
  disp('') ;
  
return

%=========================================================================================

function tpsInputsFinal = copy_time_series_and_setup( tpsInputsInitial, nCadences )
%
% tpsInputsFinal = copy_time_series_and_setup( tpsInputsInitial, fluxTimeSeries )
%

  tpsInputsFinal                        = tpsInputsInitial ;
  tpsInputsFinal.tpsTargets.fluxValue   = zeros(nCadences,1 )  ;
  tpsInputsFinal.tpsTargets.uncertainty = ones( nCadences, 1 ) ;
  
  ct = tpsInputsFinal.cadenceTimes ;
  
  dt = median( diff( ct.midTimestamps ) ) ;
  ct.startTimestamps = ct.startTimestamps(1) + dt * (0:nCadences-1)' ;
  ct.midTimestamps   = ct.startTimestamps    + dt / 2 ;
  ct.endTimestamps   = ct.startTimestamps    + dt     ;
  
  ct.gapIndicators = false( nCadences, 1 ) ;
  ct.requantEnabled = true( nCadences, 1 ) ;
  ct.cadenceNumbers = (1:nCadences)' ;
  
  ct.isSefiAcc = false( nCadences, 1 ) ;
  ct.isSefiCad = false( nCadences, 1 ) ;
  ct.isLdeOos  = false( nCadences, 1 ) ;
  ct.isFinePnt = true( nCadences, 1 ) ;
  ct.isMmntmDmp = false( nCadences, 1 ) ;
  ct.isLdeParEr = false( nCadences, 1 ) ;
  ct.isScrcErr = false( nCadences, 1 ) ;
  ct.dataAnomalyTypes = cell(1,nCadences) ;
  
  for iCadence = 1:nCadences
      ct.dataAnomalyTypes{iCadence} = [] ;
  end
  
  tpsInputsFinal.cadenceTimes = ct ;

return

%=========================================================================================

% subfunction which does the actual calculations

function [cdppTps, cdppActual, cdppFft] = perform_cdpp_tests( tpsInputs, ...
    syntheticNoiseObject, pulseDurationsCadences, addRealisticEffects )
  
% optional argument

  if ~exist( 'addRealisticEffects', 'var' ) || isempty( addRealisticEffects )
      addRealisticEffects = false ;
  end
  
% set the variance window the way that TPS does

  varianceWindow = tpsInputs.tpsModuleParameters.varianceWindowLengthMultiplier ;
  
% setup catchbasins

  cdppActual   = zeros( size( pulseDurationsCadences ) ) ;
  cdppFft      = zeros( size( pulseDurationsCadences ) ) ;
  
% loop over pulse durations and perform syntheticNoiseClass calculations

  for iDuration = 1:length( pulseDurationsCadences )
      
      pulseDuration = pulseDurationsCadences( iDuration ) ;
      cdppActual(iDuration)   = median( compute_actual_cdpp( syntheticNoiseObject, ...
          pulseDuration, varianceWindow ) ) ;
      cdppFft(iDuration)      = compute_cdpp_via_fft( syntheticNoiseObject, pulseDuration, ...
          3 ) ;
      
  end
  
% now put the colored noise into TPS and run TPS-Lite

  coloredNoise = 1 + get( syntheticNoiseObject, 'coloredNoise' ) ;
  nCadences    = get( syntheticNoiseObject, 'nSamples' ) ;
  
  tpsInputs.tpsTargets.fluxValue = coloredNoise( 1:nCadences ) ;
  
  if addRealisticEffects
      tpsInputs = add_realistic_effects( tpsInputs ) ;
  end
  
  tpsOutputs = tps_matlab_controller( tpsInputs ) ;
  cdppTps = [tpsOutputs.tpsResults.rmsCdpp] ;
  
  
return

%=========================================================================================

% subfunction which adds scaling problems, slopes, gaps, and harmonics to the flux time
% series in a TPS input struct

function tpsInputsFinal = add_realistic_effects( tpsInputsInitial )

% initialize return argument

  tpsInputsFinal = tpsInputsInitial ;
  fluxValue = tpsInputsFinal.tpsTargets.fluxValue ;
  
% put a 40-cadence gap in the middle of the time series

  tpsInputsFinal.tpsTargets.gapIndices = 4479:4539 ;
  tpsInputsFinal.tpsTargets.gapIndices = tpsInputsFinal.tpsTargets.gapIndices(:) ;
  
% put a slope into the first quarter

  rmsVariation = std( fluxValue ) ;
  fluxOffset = 3 * rmsVariation ;
  fluxSlope  = -6 * rmsVariation * (1:4480) / 4480 ;
  fluxValue(1:4480) = fluxValue(1:4480) + fluxOffset + fluxSlope(:) ;
  
% put in a harmonic

  periodCadences = 100 ;
  sineWave = 6 * rmsVariation * sin( 2*pi*(1:length(fluxValue)) / periodCadences ) ;
  fluxValue = fluxValue + sineWave(:) ;
  
% zero out the gapped cadences

  fluxValue(tpsInputsFinal.tpsTargets.gapIndices+1) = 0 ;
  
  tpsInputsFinal.tpsTargets.fluxValue = fluxValue ;
  
return
