function self = test_locate_strongest_statistics( self )
%
% test_locate_strongest_statistics -- test TPS function which manages the folding of
% the detection statistics and return of a desired subset of said statistics.  The
% following functionality is tested:
%
% ==> Correct operation in the case in which the requested max # of statistics exceeds the
%     number present in the data -- in this case the # returned should be the number which
%     are present in the data, all should be above threshold, and the result should be in
%     order
% ==> Correct operation in the case in which the requested max # of statistics is less
%     than the number present in the data -- in this case only the requested # should be
%     returned
% ==> Correct operation in the case in which there are no statistics above threshold -- in
%     this case there should be 1 statistic returned.
%
% This unit test is intended to be used in the mlunit context.  To run this unit test all
% by itself, use the following syntax:
%
%     run(text_test_runner, testTpsClass('test_locate_strongest_statistics'));
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

  disp(' ... testing TPS search for strong statistics ... ') ;

% initialize paths, etc

  tps_testing_initialization ;
  
% load the struct which has the necessary arguments

  load( fullfile( testDataPath, 'tps-folder-test-struct' ) ) ;
  
% set the random number generator to the correct value

  s = RandStream('mcg16807','Seed',0) ;
  RandStream.setDefaultStream(s) ;
  
% test 1 -- fewer statistics are present than are requested

  if isa( tpsFolderTestStruct(1).tpsResult.waveletObject, 'struct' )
      tpsFolderTestStruct(1).tpsResult.waveletObject = waveletClass( ...
          tpsFolderTestStruct(1).tpsResult.waveletObject ) ;
  end
  maxLoopCount = 1000 ;
  threshold    = 7.1 ;
  [multipleEventStatistic, periodInCadences, phaseInCadences, returnedPeriodVector, ...
      foldedStatisticAtTrialPeriods, foldedStatisticMinAtTrialPeriods, ...
      phaseLagOfMinStatistic] = locate_strongest_statistics( ...
      tpsFolderTestStruct(1).tpsResult, tpsFolderTestStruct(1).tpsModuleParameters, ...
      possiblePeriodsInCadences, maxLoopCount, threshold ) ;
  
  mlunit_assert( length(multipleEventStatistic) < maxLoopCount, ...
      'Too many MES returned in Test 1!' ) ;
  assert_equals( length(multipleEventStatistic), length(periodInCadences), ...
      'MES and period vectors in Test 1 not equal length!' ) ;
  assert_equals( length(multipleEventStatistic), length(phaseInCadences), ...
      'MES and phase vectors in Test 1 not equal length!' ) ;
  assert_equals( returnedPeriodVector, possiblePeriodsInCadences, ...
      'Possible period vectors not identical in Test 1!' ) ;
  assert_equals( length(foldedStatisticAtTrialPeriods), ...
      length(possiblePeriodsInCadences), ...
      'Folded statistic max and possible period vectors in Test 1 not equal length!' ) ;
  assert_equals( length(foldedStatisticMinAtTrialPeriods), ...
      length(possiblePeriodsInCadences), ...
      'Folded statistic min and possible period vectors in Test 1 not equal length!' ) ;
  assert_equals( length(phaseLagOfMinStatistic), ...
      length(possiblePeriodsInCadences), ...
      'Phase of folded statistic min and possible period vectors in Test 1 not equal length!' ) ;
  mlunit_assert( all( multipleEventStatistic >= threshold ), ...
      'Returned statistics in Test 1 not all above threshold!' ) ;
  mlunit_assert( issorted( flipud(multipleEventStatistic) ), ...
      'MES in Test 1 not sorted in descending order!' ) ;
  
% test 2 -- more statistics are present than are required

  maxLoopCount = length(multipleEventStatistic) - 1 ;
  [multipleEventStatistic] = locate_strongest_statistics( ...
      tpsFolderTestStruct(1).tpsResult, tpsFolderTestStruct(1).tpsModuleParameters, ...
      possiblePeriodsInCadences, maxLoopCount, threshold ) ;
  mlunit_assert( length(multipleEventStatistic) == maxLoopCount, ...
      'MES vector in Test 2 length not as expected!' ) ;
  mlunit_assert( all( multipleEventStatistic >= threshold ), ...
      'MES in Test 2 not all above threshold!' ) ;
  
% test 3 -- all statistics are below threshold

  threshold = 1000 ;
  [multipleEventStatistic] = locate_strongest_statistics( ...
      tpsFolderTestStruct(1).tpsResult, tpsFolderTestStruct(1).tpsModuleParameters, ...
      possiblePeriodsInCadences, maxLoopCount, threshold ) ;
  mlunit_assert( isscalar( multipleEventStatistic ) , ...
      'MES in Test 3 not scalar!' ) ;
  mlunit_assert( multipleEventStatistic < threshold, ...
      'MES in Test 3 not below threshold!' ) ;
  
  disp('') ;
  
return

