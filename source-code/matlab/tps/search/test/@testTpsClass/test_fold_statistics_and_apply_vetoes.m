function self = test_fold_statistics_and_apply_vetoes( self )
%
% test_fold_statistics_and_apply_vetoes -- test TPS function which manages the folding of
% the detection statistics and application of vetoes.  The following functionality is
% tested:
%
% ==> correct operation of the looper -- detections are possible on looper passes other
%     than the first one, varying the max loop count or max time changes the looper
%     behavior as expected
% ==> no detection is produced for a flux time series which has nothing in it
% ==> robust statistic and chi-square vetoes are applied when appropriate
% ==> a true detection, which passes all vetoes, behaves as expected
% ==> feature removal behaves as expected.
%
% This unit test is intended to be used in the mlunit context.  To run this unit test all
% by itself, use the following syntax:
%
%     run(text_test_runner, testTpsClass('test_fold_statistics_and_apply_vetoes'));
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

  disp(' ... testing TPS folder / veto application ... ') ;

% initialize paths, etc

  tps_testing_initialization ;
  
% load the struct which has the necessary arguments

  load( fullfile( testDataPath, 'tps-folder-test-struct' ) ) ;
  
% set the random number generator to the correct value

  s = RandStream('mcg16807','Seed',0) ;
  RandStream.setDefaultStream(s) ;
  
% test 1 -- the first of the 2 structs in the tpsFolderTestStruct array produces a TCE
% with the correct properties

  if isa( tpsFolderTestStruct(1).tpsResult.waveletObject, 'struct' )
      tpsFolderTestStruct(1).tpsResult.waveletObject = waveletClass( ...
          tpsFolderTestStruct(1).tpsResult.waveletObject ) ;
  end
  [tpsResult,possiblePeriods] = fold_statistics_and_apply_vetoes( ...
      tpsFolderTestStruct(1).tpsResult, tpsFolderTestStruct(1).tpsModuleParameters, ...
      [], tpsFolderTestStruct(1).foldingParameterStruct, ...
      tpsFolderTestStruct(1).deemphasisParameter ) ;
  
% This should be a detection which takes place on iteration 4, with no feature removals,
% no timeouts, no running out of iterations
  
  mlunit_assert( tpsResult.isPlanetACandidate, ...
      'Test 1 detection did not occur!' ) ;
  mlunit_assert( tpsResult.strongestOverallMultipleEventStatistic > ...
      tpsResult.maxMultipleEventStatistic, ...
      'Test 1 strongest MES not greater than max MES!' ) ;
  mlunit_assert( tpsResult.searchLoopCount > 1, ...
      'Test 1 search loop count not as expected!' ) ;
  assert_equals( tpsResult.removedFeatureCount, 0, ...
      'Test 1 removed features!' ) ;
  mlunit_assert( ~tpsResult.exitedOnLoopCountLimit, ...
      'Test 1 exited on loop count limit!' ) ;
  mlunit_assert( ~tpsResult.exitedOnLoopTimeLimit, ...
      'Test 1 exited on loop time limit!' ) ;
  mlunit_assert( ~isempty( possiblePeriods ), ...
      'Test 1 period vector not populated!' ) ;
  nLoopsTest1 = tpsResult.searchLoopCount ;
  
% test 2 -- same as above, but with the timeout set to zero

  tpsModuleParameters = tpsFolderTestStruct(1).tpsModuleParameters ;
  tpsModuleParameters.maxHrsLoopingPerPulse = 0 ;
  [tpsResult] = fold_statistics_and_apply_vetoes( ...
      tpsFolderTestStruct(1).tpsResult, tpsModuleParameters, ...
      [], tpsFolderTestStruct(1).foldingParameterStruct, ...
      tpsFolderTestStruct(1).deemphasisParameter ) ;
  
  mlunit_assert( ~tpsResult.isPlanetACandidate, ...
      'Test 2 detected a planet!' ) ;
  mlunit_assert( tpsResult.exitedOnLoopTimeLimit, ...
      'Test 2 did not exit on loop time limit!' ) ; 
  mlunit_assert( ~tpsResult.exitedOnLoopCountLimit, ...
      'Test 2 exited on loop count limit!' ) ;
  
% test 3 -- same as test 1, but with loop count set to 2

  tpsModuleParameters = tpsFolderTestStruct(1).tpsModuleParameters ;
  tpsModuleParameters.maxFoldingLoopCount = 2 ;
  [tpsResult] = fold_statistics_and_apply_vetoes( ...
      tpsFolderTestStruct(1).tpsResult, tpsModuleParameters, ...
      [], tpsFolderTestStruct(1).foldingParameterStruct, ...
      tpsFolderTestStruct(1).deemphasisParameter ) ;
  
  mlunit_assert( ~tpsResult.isPlanetACandidate, ...
      'Test 3 detected a planet!' ) ;
  mlunit_assert( ~tpsResult.exitedOnLoopTimeLimit, ...
      'Test 3 exited on loop time limit!' ) ;
  mlunit_assert( tpsResult.exitedOnLoopCountLimit, ...
      'Test 3 did not exit on loop count limit!' ) ;
  
% test 4 -- same as test 1, but with MES threshold set very high

  tpsModuleParameters = tpsFolderTestStruct(1).tpsModuleParameters ;
  tpsModuleParameters.searchTransitThreshold = 15 ;
  [tpsResult] = fold_statistics_and_apply_vetoes( ...
      tpsFolderTestStruct(1).tpsResult, tpsModuleParameters, ...
      [], tpsFolderTestStruct(1).foldingParameterStruct, ...
      tpsFolderTestStruct(1).deemphasisParameter ) ;
  
  mlunit_assert( ~tpsResult.isPlanetACandidate, ...
      'Test 4 detected a planet!' ) ;
  assert_equals( tpsResult.searchLoopCount, 0, ...
      'Test 4 search loop count not as expected!' ) ;
  mlunit_assert( ~tpsResult.exitedOnLoopTimeLimit, ...
      'Test 4 exited on loop time limit!' ) ;
  mlunit_assert( ~tpsResult.exitedOnLoopCountLimit, ...
      'Test 4 exited on loop count limit!' ) ;
  
% test 5 -- same as test 1, but with RS threshold set very high

  tpsModuleParameters = tpsFolderTestStruct(1).tpsModuleParameters ;
  tpsModuleParameters.maxFoldingLoopCount = nLoopsTest1 ;
  tpsModuleParameters.robustStatisticThreshold = 10 ;
  [tpsResult] = fold_statistics_and_apply_vetoes( ...
      tpsFolderTestStruct(1).tpsResult, tpsModuleParameters, ...
      [], tpsFolderTestStruct(1).foldingParameterStruct, ...
      tpsFolderTestStruct(1).deemphasisParameter ) ;

  mlunit_assert( ~tpsResult.isPlanetACandidate, ...
      'Test 5 detected a planet!' ) ;
  assert_equals( tpsResult.searchLoopCount, nLoopsTest1, ...
      'Test 5 search loop count not as expected!' ) ;
  mlunit_assert( ~tpsResult.exitedOnLoopTimeLimit, ...
      'Test 5 exited on loop time limit!' ) ;
  mlunit_assert( tpsResult.exitedOnLoopCountLimit, ...
      'Test 5 failed to exit on loop count limit!' ) ;
  mlunit_assert( tpsResult.robustStatisticVetoApplied, ...
      'Test 5 robust statistic veto not applied!' ) ;
  
% test 6 -- same as test 1, but with chi-square 2 threshold set very high  

  tpsModuleParameters = tpsFolderTestStruct(1).tpsModuleParameters ;
  tpsModuleParameters.maxFoldingLoopCount = 1 ;
  tpsModuleParameters.robustStatisticThreshold = 0 ;
  tpsModuleParameters.chiSquare2Threshold = 15 ;
  [tpsResult] = fold_statistics_and_apply_vetoes( ...
      tpsFolderTestStruct(1).tpsResult, tpsModuleParameters, ...
      [], tpsFolderTestStruct(1).foldingParameterStruct, ...
      tpsFolderTestStruct(1).deemphasisParameter ) ;
  
  mlunit_assert( ~tpsResult.isPlanetACandidate, ...
      'Test 6 detected a planet!' ) ;
  assert_equals( tpsResult.searchLoopCount, 1, ...
      'Test 6 search loop count not as expected!' ) ;
  mlunit_assert( ~tpsResult.exitedOnLoopTimeLimit, ...
      'Test 6 exited on loop time limit!' ) ;
  mlunit_assert( ~tpsResult.robustStatisticVetoApplied, ...
      'Test 6 robust statistic veto applied!' ) ;
  
% test 7 -- test with feature removal

  if isa( tpsFolderTestStruct(2).tpsResult.waveletObject, 'struct' )
      tpsFolderTestStruct(2).tpsResult.waveletObject = waveletClass( ...
          tpsFolderTestStruct(2).tpsResult.waveletObject ) ;
  end
  [tpsResult] = fold_statistics_and_apply_vetoes( ...
      tpsFolderTestStruct(2).tpsResult, tpsFolderTestStruct(2).tpsModuleParameters, ...
      [], tpsFolderTestStruct(2).foldingParameterStruct, ...
      tpsFolderTestStruct(2).deemphasisParameter ) ;
  
  mlunit_assert( tpsResult.isPlanetACandidate, ...
      'Test 7 failed to detect a planet!' ) ;
  assert_equals( tpsResult.removedFeatureCount, 2, ...
      'Test 7 removed feature count not as expected!' ) ;
  nLoopsTest7 = tpsResult.searchLoopCount ;
  
% test 8 -- same as above, but with no feature removal

  tpsModuleParameters = tpsFolderTestStruct(2).tpsModuleParameters ;
  tpsModuleParameters.maxFoldingLoopCount = nLoopsTest7 ;
  tpsModuleParameters.maxRemovedFeatureCount = 1 ;
  [tpsResult] = fold_statistics_and_apply_vetoes( ...
      tpsFolderTestStruct(2).tpsResult, tpsModuleParameters, ...
      [], tpsFolderTestStruct(2).foldingParameterStruct, ...
      tpsFolderTestStruct(2).deemphasisParameter ) ;
  mlunit_assert( ~tpsResult.isPlanetACandidate, ...
      'Test 8 detected a planet!' ) ;
  assert_equals( tpsResult.removedFeatureCount, 1, ...
      'Test 8 removed feature count not as expected!' ) ;
  mlunit_assert( ~tpsResult.exitedOnLoopTimeLimit, ...
      'Test 8 exited on loop time limit!' ) ;



  disp('') ;
  
return

