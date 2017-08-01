function self = test_eclipsing_binary_removal( self )
%
% test_eclipsing_binary_removal -- overarching unit test of the eclipsing binary detection
% and removal features in dvDataClass
%
% This unit test exercises perform_dv_planet_search_and_model_fitting in the case in which
% a target has both an eclipsing binary and a planet.  It verifies that the EB is detected
% and gapped, and that the planet is detected and fitted.
%
% This test is intended to be executed in the mlunit context.  For standalone execution
% use the following syntax:
%
%      run(text_test_runner, testDvDataClass('test_eclipsing_binary_removal'));
%
% Version date:  2009-November-05.
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

  disp('... testing eclipsing binary removal method ... ')
  
  dvDataFilename = 'eclipsing-binary-removal-test-data.mat' ;
  testDvDataClass_fitter_initialization ;

% create the directories for the figures to be shoved into

  dvResultsStruct = create_directories_for_dv_figures( dvDataObject, ...
      dvResultsStructBeforeFitting ) ;  
  
% run the planet search / model fitting method

  dvResultsStruct = perform_dv_planet_search_and_model_fitting( dvDataObject, ...
      dvResultsStruct ) ;
  
% extract the planet results structure for inspection

  planetResultsStruct = dvResultsStruct.targetResultsStruct.planetResultsStruct ;
  
% The planet results struct has to be properly formed:  a vector of 3 structs, of which
% the first 2 are correct for removed EBs and the third is correct for a planet

  mlunit_assert( length(planetResultsStruct) == 3, ...
      'Length of planetResultsStruct is incorrect' ) ;
  planetCandidate1 = planetResultsStruct(1).planetCandidate ;
  planetCandidate2 = planetResultsStruct(2).planetCandidate ;
  planetCandidate3 = planetResultsStruct(3).planetCandidate ;
  
  planet1Ok = planetCandidate1.suspectedEclipsingBinary ;
  planet1Ok = planet1Ok && planetCandidate1.expectedTransitCount == 0 ;
  planet1Ok = planet1Ok && planetCandidate1.observedTransitCount == 0 ;
  
  mlunit_assert( planet1Ok, ...
      'PlanetCandidate(1) incorrect' ) ;
  
  planet2Ok = planetCandidate2.suspectedEclipsingBinary ;
  planet2Ok = planet2Ok && planetCandidate2.expectedTransitCount == 0 ;
  planet2Ok = planet2Ok && planetCandidate2.observedTransitCount == 0 ;
  
  mlunit_assert( planet2Ok, ...
      'PlanetCandidate(2) incorrect' ) ;
  
  planet3Ok = ~planetCandidate3.suspectedEclipsingBinary ;
  planet3Ok = planet3Ok && planetCandidate3.expectedTransitCount > 0 ;
  planet3Ok = planet3Ok && planetCandidate3.observedTransitCount > 0 ;
  
  mlunit_assert( planet3Ok, ...
      'PlanetCandidate(3) incorrect' ) ;
  
  noTransitFittedStruct = struct( 'modelChiSquare', -1, 'modelDegreesOfFreedom', -1, ...
      'robustWeights', zeros(3000,1), 'modelParameterCovariance', [] ) ;
  fieldsToRemove = {'keplerId', 'planetNumber', 'transitModelName', ...
      'limbDarkeningModelName', 'modelParameters'} ;
  
  assert_equals( orderfields( noTransitFittedStruct ), ...
      orderfields( rmfield( planetResultsStruct(1).allTransitsFit, fieldsToRemove ) ), ...
      'Planet 1 all-transits fit struct not correct' ) ;
  assert_equals( orderfields( noTransitFittedStruct ), ...
      orderfields( rmfield( planetResultsStruct(1).oddTransitsFit, fieldsToRemove ) ), ...
      'Planet 1 odd-transits fit struct not correct' ) ;
  assert_equals( orderfields( noTransitFittedStruct ), ...
      orderfields( rmfield( planetResultsStruct(1).evenTransitsFit, fieldsToRemove ) ), ...
      'Planet 1 even-transits fit struct not correct' ) ;
  assert_equals( size( planetResultsStruct(1).allTransitsFit.modelParameters ), ...
      [1 4], 'Planet 1 all-transits fit model parameters not correct' ) ;
  assert_equals( size( planetResultsStruct(1).oddTransitsFit.modelParameters ), ...
      [1 4], 'Planet 1 odd-transits fit model parameters not correct' ) ;
  assert_equals( size( planetResultsStruct(1).evenTransitsFit.modelParameters ), ...
      [1 4], 'Planet 1 even-transits fit model parameters not correct' ) ;

  assert_equals( orderfields( noTransitFittedStruct ), ...
      orderfields( rmfield( planetResultsStruct(2).allTransitsFit, fieldsToRemove ) ), ...
      'Planet 2 all-transits fit struct not correct' ) ;
  assert_equals( orderfields( noTransitFittedStruct ), ...
      orderfields( rmfield( planetResultsStruct(2).oddTransitsFit, fieldsToRemove ) ), ...
      'Planet 2 odd-transits fit struct not correct' ) ;
  assert_equals( orderfields( noTransitFittedStruct ), ...
      orderfields( rmfield( planetResultsStruct(2).evenTransitsFit, fieldsToRemove ) ), ...
      'Planet 2 even-transits fit struct not correct' ) ;
  assert_equals( size( planetResultsStruct(2).allTransitsFit.modelParameters ), ...
      [1 4], 'Planet 2 all-transits fit model parameters not correct' ) ;
  assert_equals( size( planetResultsStruct(2).oddTransitsFit.modelParameters ), ...
      [1 4], 'Planet 2 odd-transits fit model parameters not correct' ) ;
  assert_equals( size( planetResultsStruct(2).evenTransitsFit.modelParameters ), ...
      [1 4], 'Planet 2 even-transits fit model parameters not correct' ) ;

  planet3AllTransitsOk = planetResultsStruct(3).allTransitsFit.modelChiSquare > 0 ;
  planet3AllTransitsOk = planet3AllTransitsOk && ...
      planetResultsStruct(3).allTransitsFit.modelDegreesOfFreedom > 0 ;
  planet3AllTransitsOk = planet3AllTransitsOk && ...
      any( planetResultsStruct(3).allTransitsFit.robustWeights > 0 ) ;
  planet3AllTransitsOk = planet3AllTransitsOk && ...
      isequal( size( planetResultsStruct(3).allTransitsFit.modelParameterCovariance ), ...
      [144 1] ) ;
  planet3AllTransitsOk = planet3AllTransitsOk && ...
      isequal( size( planetResultsStruct(3).allTransitsFit.modelParameters ), ...
      [1 12] ) ;
  mlunit_assert( planet3AllTransitsOk, ...
      'Planet 3 all-transits fit struct not correct' ) ;
  
  planet3OddTransitsOk = planetResultsStruct(3).oddTransitsFit.modelChiSquare > 0 ;
  planet3OddTransitsOk = planet3OddTransitsOk && ...
      planetResultsStruct(3).oddTransitsFit.modelDegreesOfFreedom > 0 ;
  planet3OddTransitsOk = planet3OddTransitsOk && ...
      any( planetResultsStruct(3).oddTransitsFit.robustWeights > 0 ) ;
  planet3OddTransitsOk = planet3OddTransitsOk && ...
      isequal( size( planetResultsStruct(3).oddTransitsFit.modelParameterCovariance ), ...
      [144 1] ) ;
  planet3OddTransitsOk = planet3OddTransitsOk && ...
      isequal( size( planetResultsStruct(3).oddTransitsFit.modelParameters ), ...
      [1 12] ) ;
  mlunit_assert( planet3OddTransitsOk, ...
      'Planet 3 odd-transits fit struct not correct' ) ;
  
  planet3EvenTransitsOk = planetResultsStruct(3).evenTransitsFit.modelChiSquare > 0 ;
  planet3EvenTransitsOk = planet3EvenTransitsOk && ...
      planetResultsStruct(3).evenTransitsFit.modelDegreesOfFreedom > 0 ;
  planet3EvenTransitsOk = planet3EvenTransitsOk && ...
      any( planetResultsStruct(3).evenTransitsFit.robustWeights > 0 ) ;
  planet3EvenTransitsOk = planet3EvenTransitsOk && ...
      isequal( size( planetResultsStruct(3).evenTransitsFit.modelParameterCovariance ), ...
      [144 1] ) ;
  planet3EvenTransitsOk = planet3EvenTransitsOk && ...
      isequal( size( planetResultsStruct(3).evenTransitsFit.modelParameters ), ...
      [1 12] ) ;
  mlunit_assert( planet3EvenTransitsOk, ...
      'Planet 3 even-transits fit struct not correct' ) ;
  
% make sure that the correct cadences are gapped via regression.  This is obviously a bit
% risky, since small changes in how the gapping is performed can cause this to be almost
% the same, but not exactly the same.  Oh, well...

  assert_equals( dvResultsStruct.targetResultsStruct.residualFluxTimeSeries.gapIndicators, ...
      dvResultsStructAfterFitting.targetResultsStruct.residualFluxTimeSeries.gapIndicators, ...
      'Gaps from fitter do not match expected' ) ;
  
  disp(' ') ;
  
return

% and that's it!

%
%
%

  