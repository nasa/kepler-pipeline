function self = test_tps_anomaly_deweighting( self )
%
% test_tps_anomaly_deweighting -- test TPS functionality which performs deweighting of
% cadences in or near anomalies
%
%
% This unit test exercises the following functionality:
%
% ==> Cadences which are in an anomaly (as indicated by cadenceTimes anomaly flags or
%     tpsTargets anomaly flags) are set to zero weight
% ==> Cadences which are near a safe mode or earth point are partially deweighted as
%     expected
% ==> Cadences which are near a pointing tweak are partially deweighted as expected
% ==> Cadences which are entirely or partially deweighted are treated properly by the
%     folding algorithm:  fully deweighted cadences contribute zero to the MES, partially
%     deweighted ones contribute but not fully.
%
% This unit test is intended to be used in the mlunit context.  To run this unit test all
% by itself, use the following syntax:
%
%     run(text_test_runner, testTpsClass('test_tps_anomaly_deweighting'));
%
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

  disp(' ... testing anomaly-deweighting method ... ') ;

% initialize paths, etc, and get a single-quarter data file

  tpsDataFile = 'tps-full-data-struct' ;
  tpsDataStructName = 'tpsDataStruct' ;
  tps_testing_initialization ;
  
 % set the random number generator to the correct value

  s = RandStream('mcg16807','Seed',0) ;
  RandStream.setDefaultStream(s) ;
  
% load the regression-test deemphasis weight vectors

  load( fullfile( testDataPath, 'tps-deemphasis-weight-results' ) ) ;

  nCadences = length( tpsDataStruct.tpsTargets.fluxValue ) ;
  
% generate a flux time series which contains Gaussian white noise and five transits

  harmonicPeriodCadences  = 1000 ;
  finalPhaseShiftRadians  = 1 ;
  transitEpochCadence     = 25 ;
  transitPeriodCadences   = 1075 ;
  transitDurationCadences = 12 ;

  [whiteNoise,randomWalk,harmonicSine,harmonicCosine,transit] = ...
      generate_tps_test_time_series( nCadences, harmonicPeriodCadences, ...
      finalPhaseShiftRadians, transitEpochCadence, transitPeriodCadences, ...
      transitDurationCadences ) ;

  transitCadences = find(transit < 0) ;
  
% construct a time series with 50 PPM white noise and 1000 PPM transits, all cadences good

  tpsDataStruct.tpsTargets.fluxValue = 50e-6 * whiteNoise + 1000e-6 * transit ;
  for iCadence = 1:nCadences
      tpsDataStruct.cadenceTimes.dataAnomalyTypes{iCadence} = [] ;
  end
  
% in the interest of execution speed, limit the number of trial transit pulses

  tpsDataStruct.tpsModuleParameters.requiredTrialTransitPulseInHours = 6 ;
  tpsDataStruct.tpsModuleParameters.storeCdppFlag                    = true ;

% disable refolding based on robust statistic and chi-square vetoes

  tpsDataStruct.tpsModuleParameters.robustStatisticThreshold = 0 ;
  tpsDataStruct.tpsModuleParameters.chiSquare1Threshold = 0 ;
  tpsDataStruct.tpsModuleParameters.chiSquare2Threshold = 0 ;
  
% set appropriate debugLevel to avoid clipping the info we need from the results

  tpsDataStruct.tpsModuleParameters.debugLevel = -1 ;

% turn off dewieghting of zero crossing cadences

  tpsDataStruct.tpsModuleParameters.deweightReactionWheelZeroCrossingCadences = false ;
  
% Now we'll have 3 data structs:  one in which all cadences are good; one in which there
% are anomalies which overlap some transits; one in which anomalies are adjacent to some
% cadences

  tpsDataStruct2 = tpsDataStruct ;
  transit1 = transitCadences(1:13) ;
  for iCadence = transit1'
      tpsDataStruct2.cadenceTimes.dataAnomalyTypes{iCadence} = {'SAFE_MODE'} ;
  end
  transit2 = transitCadences(14:26) ;
  for iCadence = transit2'
      tpsDataStruct2.cadenceTimes.dataAnomalyTypes{iCadence} = {'EARTH_POINT'} ;
  end
  transit3 = transitCadences(27:39) ;
  for iCadence = transit3'
      tpsDataStruct2.cadenceTimes.dataAnomalyTypes{iCadence} = {'ATTITUDE_TWEAK'} ;
  end
  tpsDataStruct2.tpsTargets.fillIndices = 499 ;
  tpsDataStruct2.tpsTargets.discontinuityIndices = 549 ;
  tpsDataStruct2.tpsModuleParameters.minSesInMesCount = 2 ;

  tpsDataStruct3 = tpsDataStruct ;
  
  for iCadence = transitCadences(13)+1:transitCadences(13)+10
      tpsDataStruct3.cadenceTimes.dataAnomalyTypes{iCadence} = {'SAFE_MODE'} ;
  end
  for iCadence = transitCadences(14)-10:transitCadences(14)-1
      tpsDataStruct3.cadenceTimes.dataAnomalyTypes{iCadence} = {'EARTH_POINT'} ;
  end
  tpsDataStruct3.cadenceTimes.dataAnomalyTypes{transitCadences(27)-1} = {'ATTITUDE_TWEAK'} ;
  
% run the 3 structs through TPS

  tpsOutputStruct  = tps_matlab_controller( tpsDataStruct ) ;
  tpsOutputStruct2 = tps_matlab_controller( tpsDataStruct2 ) ;
  tpsOutputStruct3 = tps_matlab_controller( tpsDataStruct3 ) ;
  
  tpsResults  = tpsOutputStruct.tpsResults ;
  tpsResults2 = tpsOutputStruct2.tpsResults ;
  tpsResults3 = tpsOutputStruct3.tpsResults ;

% regression test the normal and super-resolution weights -- this tests all of the
% machinery involved in assigning the deemphasis parameters, and then converting same to
% deemphasis weights

  mlunit_assert( all( tpsResults.deemphasisWeight == 1 ), ...
      'No-anomaly case deemphasis weights incorrectly set!' ) ;
  mlunit_assert( all( tpsResults.deemphasisWeightSuperResolution == 1 ), ...
      'No-anomaly case super-resolution deemphasis weights incorrectly set!' ) ;
  
  assert_equals( tpsResults2.deemphasisWeight, deemphasisWeight2, ...
      'Anomaly-on-transit case deemphasis weights incorrectly set!' ) ;
  assert_equals( tpsResults2.deemphasisWeightSuperResolution, ...
      deemphasisWeightSuperResolution2, ...
      'Anomaly-on-transit case deemphasis weights incorrectly set!' ) ;
  
  assert_equals( tpsResults3.deemphasisWeight, deemphasisWeight3, ...
      'Anomaly-near-transit case deemphasis weights incorrectly set!' ) ;
  assert_equals( tpsResults3.deemphasisWeightSuperResolution, ...
      deemphasisWeightSuperResolution3, ...
      'Anomaly-near-transit case deemphasis weights incorrectly set!' ) ;
  
% check that the numbers of single event statistics are correct in each case

  assert_equals( sum( tpsResults.sesCombinedToYieldMes ~= 0 ), 5, ...
      'Incorrect # of SES combined to MES in no-anomaly case!' ) ;
  assert_equals( sum( tpsResults2.sesCombinedToYieldMes ~= 0 ), 2, ...
      'Incorrect # of SES combined to MES in anomaly-on-transit case!' ) ;
  assert_equals( sum( tpsResults3.sesCombinedToYieldMes ~= 0 ), 5, ...
      'Incorrect # of SES combined to MES in anomaly-near-transit case!' ) ;
  
% check that the single event statistics values are approximately correct

  sesDiff = tpsResults.sesCombinedToYieldMes - 77 ;
  mlunit_assert( all( abs(sesDiff) < 11 ), ...
      'SES values incorrect in no-anomaly case!' ) ;
  sesDiff2 = tpsResults2.sesCombinedToYieldMes(tpsResults2.sesCombinedToYieldMes ~= 0) - 77 ;
  mlunit_assert( all( abs(sesDiff2) < 11 ), ...
      'SES values incorrect in anomaly-on-transit case!' ) ;
  sesDiff3 = tpsResults3.sesCombinedToYieldMes - [12 ; 12 ; 77 ; 77 ; 77] ;
  mlunit_assert( all( abs(sesDiff3) < 11 ), ...
      'SES values incorrect in anomaly-near-transit case!' ) ;
  
  disp('') ;
  
return

