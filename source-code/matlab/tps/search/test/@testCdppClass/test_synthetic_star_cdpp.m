function self = test_synthetic_star_cdpp( self )
%
% test_synthetic_star_cdpp -- unit test for generating customized time series and
% computing the resulting CDPP
%
% This is a unit test in the testCdppClass, which runs under mlunit.  The test generates a
% flux time series with a specified spectrum and determines the expected CDPP from an
% assortment of methods.  The CDPP is then estimated by TPS-Lite, and the latter is
% compared to the former.  A number of spectra are tested, each based upon the flux of an
% actual star as follows:
%
%     noisy, non-variable star based on KIC 8547085
%     harmonically variable star based on KIC 8611921
%     non-harmonically variable star based on KIC 8740378
%
% This method is not intended to be invoked directly, but rather via an mlunit call.
% Here's the syntax:
%
%      run(text_test_runner, testCdppClass('test_synthetic_star_cdpp'));
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

  disp(' ... testing CDPP calculation with synthetic star flux time series ... ') ;
  
% set the test data path and retrieve the input struct 

  tpsDataFile = 'tps-multi-quarter-struct' ;
  tpsDataStructName = 'tpsInputs' ;
  tps_testing_initialization ;
  
  tpsInputs.tpsTargets = tpsInputs.tpsTargets(1) ;
  tpsInputs.tpsTargets.gapIndices = [] ;
  tpsInputs.tpsTargets.fillIndices = [] ;
  tpsInputs.tpsModuleParameters.debugLevel = -1 ;
  tpsInputs.tpsModuleParameters.performQuarterStitching = true ;
  
% set rand seed

  s = RandStream('mcg16807','Seed',0) ;
  RandStream.setDefaultStream(s) ;  

% set up a flux time series with 9000 cadences, which is about 2 months' worth of long
% cadence data; set it up with no gaps and no fills

  nCadences = 9000 ;
  tpsInputs = copy_time_series_and_setup( tpsInputs, nCadences ) ;
  
% determine the desired set of pulse durations and set options

  pulseDurationsHours = 15 ;
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
  syntheticNoiseStruct.noiseScalePpm = 150 ;
  syntheticNoiseStruct.randStream = RandStream( 'mt19937ar', 'seed', 3494069 ) ;
  
  syntheticNoiseObject = syntheticNoiseClass( syntheticNoiseStruct ) ;
  
% create a noisy but not harmonic star and test its cdpp

  spectrumArray = [1 2 4 6 8 10 20 20 15 7 3 1 1] ;
  syntheticNoiseObject = set_spectrum_array(syntheticNoiseObject, ...
      repmat( spectrumArray, 2, 1 ) ) ;
  syntheticNoiseObject = construct_colored_noise_via_wavelets( ...
      syntheticNoiseObject ) ;
  cdppActual = compute_actual_cdpp( syntheticNoiseObject, 31, 30 ) ;
  cdppActual = median( cdppActual ) ;
  mlunit_assert( abs( cdppActual - 135 ) < 1, ...
      'Noisy non-harmonic star actual CDPP not as expected!' ) ;
  
% now run it through TPS

  coloredNoise = get( syntheticNoiseObject, 'coloredNoise' ) ;
  tpsInputs.tpsTargets.fluxValue = 1 + coloredNoise(1:9000) ;
  tpsOutputs = tps_matlab_controller( tpsInputs ) ;
  cdppTps = tpsOutputs.tpsResults.rmsCdpp ;
  mlunit_assert( abs( cdppTps - 150 ) < 1, ...
      'Noisy non-harmonic star TPS CDPP not as expected!' ) ;
  
% now create a harmonic variable star spectrum

  syntheticNoiseStruct.noiseScalePpm = 98 ;
  syntheticNoiseObject = syntheticNoiseClass( syntheticNoiseStruct ) ;
  spectrumArray = [2048 1024 512 256 128 64 32 16 8 4 2 0.75 0.5] ;
  syntheticNoiseObject = set_spectrum_array( syntheticNoiseObject, ...
      repmat( spectrumArray, 2, 1 ) ) ;
  syntheticNoiseObject = construct_colored_noise_via_wavelets( ...
      syntheticNoiseObject ) ;
  cdppActual = compute_actual_cdpp( syntheticNoiseObject, 31, 30 ) ;
  cdppActual = median( cdppActual ) ;
  mlunit_assert( abs( cdppActual - 133 ) < 1, ...
      'Harmonic variable star actual CDPP not as expected!' ) ;
  
% now run it through TPS

  coloredNoise = get( syntheticNoiseObject, 'coloredNoise' ) ;
  tpsInputs.tpsTargets.fluxValue = 1 + coloredNoise(1:9000) ;
  tpsOutputs = tps_matlab_controller( tpsInputs ) ;
  cdppTps = tpsOutputs.tpsResults.rmsCdpp ;
  mlunit_assert( abs( cdppTps - 131 ) < 1, ...
      'Harmonic variable star TPS CDPP not as expected!' ) ;
  

% now create a non harmonic variable star spectrum

  syntheticNoiseStruct.noiseScalePpm = 17 ;
  syntheticNoiseObject = syntheticNoiseClass( syntheticNoiseStruct ) ;
  spectrumArray = [1000 758 3403 1258 1208 824 188 30 7 1 0.6 0.75 0.5] ;
  syntheticNoiseObject = set_spectrum_array( syntheticNoiseObject, ...
      repmat( spectrumArray, 2, 1 ) ) ;
  syntheticNoiseObject = construct_colored_noise_via_wavelets( ...
      syntheticNoiseObject ) ;
  cdppActual = compute_actual_cdpp( syntheticNoiseObject, 31, 30 ) ;
  cdppActual = median( cdppActual ) ;
  mlunit_assert( abs( cdppActual - 16 ) < 1, ...
      'Non-harmonic variable star actual CDPP not as expected!' ) ;
  
% now run it through TPS

  coloredNoise = get( syntheticNoiseObject, 'coloredNoise' ) ;
  tpsInputs.tpsTargets.fluxValue = 1 + coloredNoise(1:9000) ;
  tpsOutputs = tps_matlab_controller( tpsInputs ) ;
  cdppTps = tpsOutputs.tpsResults.rmsCdpp ;
  mlunit_assert( abs( cdppTps - 16 ) < 1, ...
      'Non-harmonic variable star TPS CDPP not as expected!' ) ;
  
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

