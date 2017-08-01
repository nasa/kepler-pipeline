function self = test_iterator_loop_end_logic( self ) 
%
% test_iterator_loop_end_logic -- test the iterator_loop_end_logic method of
% transitFitClass
%
% test_iterator_loop_end_logic tests the transitFitClass method which handles all of the
% decision-making at the end of the whitener-fitter loop.  Specifially:
%
% ==> when determine_convergence decides that convergence hasn't happened yet, make sure
%     that the loop-end logic does the right thing (false convergence flag, other outputs
%     as expected)
% ==> when determine_convergence decides that convergence has happened but robust fitting
%     still needs to happen, set outputs such that robust fitting will follow
% ==> when determine_convergence decides that convergence has happened but that we need to
%     change fit types, set outputs such that fitting of the new fit type will follow.
%
% This test is intended to be executed in the mlunit context.  For standalone execution
% use the following syntax:
%
%      run(text_test_runner, testTransitFitClass('test_iterator_loop_end_logic'));
%
% Version date:  2010-April-30.
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
%    2010-April-30, PT:
%        loosen convergence criterion for robust fitting to speed up execution.
%
%=========================================================================================

  disp('... testing iterator loop end logic method ... ')

  testTransitFitClass_initialization ;
  
% Try the case in which we are not yet converged:  we can signal this by sending an empty
% for the transit fit object from the previous iteration.  In principle we should test
% that using 2 transitFitClass objects, which do not agree within their tolerance,
% produces the same effect; but in practice this is covered by the unit test of
% determine_convergence, and does not need to be repeated here

  outputsOk = check_outputs_convergence_failure( transitFitObject1, false ) ;
  mlunit_assert( outputsOk, ...
      'Incorrect outputs in non-robust, non-converged case with fitType == 1' ) ;
  
% Not converged case with robust fitting 

  transitFitStruct1 = transitFitStruct ;
  transitFitStruct1.configurationStruct.robustFitEnabled = true ;
  transitFitStruct1.configurationStruct.tolSigma = 1 ;
  transitFitObject2 = transitFitClass( transitFitStruct1, 1 ) ;
  transitFitObject2 = fit_transit( transitFitObject2 ) ;
  outputsOk = check_outputs_convergence_failure( transitFitObject2, true ) ;
  mlunit_assert( outputsOk, ...
      'Incorrect outputs in robust, non-converged case with fitType == 1' ) ;

% not converged case with non-robust fitting but fitType == 0

  transitFitObject3 = transitFitClass( transitFitStruct, 0 ) ;
  transitFitObject3 = fit_transit( transitFitObject3 ) ;
  outputsOk = check_outputs_convergence_failure( transitFitObject3, false ) ;
  mlunit_assert( outputsOk, ...
      'Incorrect outputs in non-robust, non-converged case with fitType == 0' ) ;

% Now a large number of cases in which "simple convergence" is achieved -- it has simply
% converged and is ready to stop iterating, period.

  outputsOk = check_outputs_simple_convergence( transitFitObject1, false, false ) ;
  mlunit_assert( outputsOk, ...
      'Incorrect outputs simple-converged case' ) ;
  
  outputsOk = check_outputs_simple_convergence( transitFitObject2, true, false ) ;
  mlunit_assert( outputsOk, ...
      'Incorrect outputs robust simple-converged case' ) ;
  
  outputsOk = check_outputs_simple_convergence( transitFitObject3, false, false ) ;
  mlunit_assert( outputsOk, ...
      'Incorrect outputs simple-converged fitType == 0 case' ) ;
  
  transitFitStruct2 = get( transitFitObject1, '*' ) ;
  transitFitStruct2.oddEvenFlag = 1 ;
  transitFitObject4 = transitFitClass( transitFitStruct2, 1 ) ;
  outputsOk = check_outputs_simple_convergence( transitFitObject4, false, false ) ;
  mlunit_assert( outputsOk, ...
      'Incorrect outputs simple-converged oddEvenFlag == 1 case' ) ;
  
  transitFitStruct3 = get( transitFitObject3, '*' ) ;
  transitFitStruct3.oddEvenFlag = 1 ;
  transitFitObject5 = transitFitClass( transitFitStruct3, 0 ) ;
  outputsOk = check_outputs_simple_convergence( transitFitObject5, false, false ) ;
  mlunit_assert( outputsOk, ...
      'Incorrect outputs simple-converged fitType == 0 oddEvenFlag == 1 case' ) ;
  
  outputsOk = check_outputs_simple_convergence( transitFitObject4, false, true ) ;
  mlunit_assert( outputsOk, ...
      'Incorrect outputs simple-converged oddEvenFlag == 1 starRadius case' ) ;
  
  transitFitStruct4 = get( transitFitObject2, '*' ) ;
  transitFitStruct4.oddEvenFlag = 1 ;
  transitFitObject6 = transitFitClass( transitFitStruct4, 1 ) ;
  outputsOk = check_outputs_simple_convergence( transitFitObject6, true, false ) ;
  mlunit_assert( outputsOk, ...
      'Incorrect outputs simple-converged robust oddEvenFlag == 1 case' ) ;
  
  transitFitObject7 = transitFitClass( transitFitStruct1, 0 ) ;
  transitFitObject7 = fit_transit( transitFitObject7 ) ;
  outputsOk = check_outputs_simple_convergence( transitFitObject7, true, false ) ;
  mlunit_assert( outputsOk, ...
      'Incorrect outputs simple-converged robust fitType==0 case' ) ;
  
  transitFitStruct5 = get( transitFitObject7, '*' ) ;
  transitFitStruct5.oddEvenFlag = 1 ;
  transitFitObject8 = transitFitClass( transitFitStruct5, 0 ) ;
  outputsOk = check_outputs_simple_convergence( transitFitObject8, true, false ) ;
  mlunit_assert( outputsOk, ...
      'Incorrect outputs simple-converged robust fitType==0 oddEvenFlag==1 case' ) ;
  
  outputsOk = check_outputs_simple_convergence( transitFitObject6, true, true ) ;
  mlunit_assert( outputsOk, ...
      'Incorrect outputs simple-converged robust oddEvenFlag==1 starRadius case' ) ;
  
% finally, we get to a couple of more interesting cases:  

% A case in which we converge but still need to do robust fitting ...

  oldBestFitObjectPreviousType = 'dummy' ;
  iterLimitOld = 100 ;
  nIter = 50 ;
  robustFitRequested = true ;
  [convergenceFlag, fitType, bestFitObjectPreviousType, iterLimitNew, ...
      transitFitObjectLastIter, transitObject, doRobustFit] = ...
      iterator_loop_end_logic( transitFitObject1, transitFitObject1, ...
      oldBestFitObjectPreviousType, iterLimitOld, robustFitRequested, 1, 0.01, nIter ) ;

  outputsOk = ~convergenceFlag ;
  outputsOk = outputsOk && fitType == get( transitFitObject1, 'fitType' ) ;
  outputsOk = outputsOk && isequal( bestFitObjectPreviousType, ...
                               oldBestFitObjectPreviousType ) ;
  outputsOk = outputsOk && iterLimitNew == nIter + iterLimitOld ;
  outputsOk = outputsOk && isequal( transitFitObjectLastIter, transitFitObject1 ) ;
  outputsOk = outputsOk && isequal( transitObject, get_fitted_transit_object( ...
      transitFitObject1 ) ) ;
  outputsOk = outputsOk && doRobustFit ;
  mlunit_assert( outputsOk, ...
      'Incorrect outputs enable robust fitting case' ) ;
  
% Two cases in which we switch from fitting mode 1 to fitting mode 0: one in which we were
% never doing robust fitting...

  robustFitRequested = false ;
  kicStarRadius = 2 * get( transitObject, 'starRadiusSolarRadii' ) ;
  [convergenceFlag, fitType, bestFitObjectPreviousType, iterLimitNew, ...
      transitFitObjectLastIter, transitObject, doRobustFit] = ...
      iterator_loop_end_logic( transitFitObject1, transitFitObject1, ...
      oldBestFitObjectPreviousType, iterLimitOld, robustFitRequested, kicStarRadius, ...
      0.01, nIter ) ;

  outputsOk = ~convergenceFlag ;
  outputsOk = outputsOk && fitType == 0 ;
  outputsOk = outputsOk && isequal( bestFitObjectPreviousType, ...
                               transitFitObject1 ) ;
  outputsOk = outputsOk && iterLimitNew == nIter + iterLimitOld ;
  outputsOk = outputsOk && isempty( transitFitObjectLastIter ) ;
  outputsOk = outputsOk && isequal( transitObject, ...
      get_transit_object_with_new_star_radius( ...
      get_fitted_transit_object(transitFitObject1), kicStarRadius ) ) ;
  outputsOk = outputsOk && ~doRobustFit ;
  mlunit_assert( outputsOk, ...
      'Incorrect outputs non-robust switch fitType case' ) ;
  
% and a case in which we switch from robust fitType 1 to non-robust fitType 0 fitting

  transitObject = get_fitted_transit_object( transitFitObject2 ) ;
  kicStarRadius = 2 * get( transitObject, 'starRadiusSolarRadii' ) ;
  robustFitRequested = true ;
  [convergenceFlag, fitType, bestFitObjectPreviousType, iterLimitNew, ...
      transitFitObjectLastIter, transitObject, doRobustFit] = ...
      iterator_loop_end_logic( transitFitObject2, transitFitObject2, ...
      oldBestFitObjectPreviousType, iterLimitOld, robustFitRequested, kicStarRadius, ...
      0.01, nIter ) ;

  outputsOk = ~convergenceFlag ;
  outputsOk = outputsOk && fitType == 0 ;
  outputsOk = outputsOk && isequal( bestFitObjectPreviousType, ...
                               transitFitObject2 ) ;
  outputsOk = outputsOk && iterLimitNew == nIter + iterLimitOld ;
  outputsOk = outputsOk && isempty( transitFitObjectLastIter ) ;
  outputsOk = outputsOk && isequal( transitObject, ...
      get_transit_object_with_new_star_radius( ...
      get_fitted_transit_object( transitFitObject2 ), kicStarRadius ) ) ;
  outputsOk = outputsOk && ~doRobustFit ;
  mlunit_assert( outputsOk, ...
      'Incorrect outputs robust switch fitType case' ) ;  
  
return

% and that's it!

%
%
%
  
%=========================================================================================
  
% subfunction which checks to see that the outputs are correct in the case in which
% the convergence test fails

function outputsOk = check_outputs_convergence_failure( transitFitObject, ...
    robustFitRequested )

  oldBestFitObjectPreviousType = 'dummy' ;
  iterLimitOld = 100 ;
  [convergenceFlag, fitType, bestFitObjectPreviousType, iterLimitNew, ...
      transitFitObjectLastIter, transitObject, doRobustFit] = ...
      iterator_loop_end_logic( transitFitObject, [], oldBestFitObjectPreviousType, ...
      iterLimitOld, robustFitRequested, 1, 0.01, 50 ) ;
  
% check outputs against expected
  
  outputsOk = ~convergenceFlag ;
  outputsOk = outputsOk && fitType == get( transitFitObject, 'fitType' ) ;
  outputsOk = outputsOk && isequal( bestFitObjectPreviousType, ...
                                   oldBestFitObjectPreviousType ) ;
  outputsOk = outputsOk && iterLimitNew == iterLimitOld ;
  outputsOk = outputsOk && isequal( transitFitObject, transitFitObjectLastIter ) ;
  outputsOk = outputsOk && isequal( transitObject, get_fitted_transit_object( ...
      transitFitObject ) ) ;
  outputsOk = outputsOk && doRobustFit == get_robust_fit_status( transitFitObject ) ;

return

% and that's it!

%
%
%

%=========================================================================================
  
% subfunction to perform output checking in simple convergence case

function outputsOk = check_outputs_simple_convergence( transitFitObject, ...
    robustFitRequested, starRadiusCondition )

  oldBestFitObjectPreviousType = 'dummy' ;
  iterLimitOld = 100 ;
  kicStarRadius = get( get_fitted_transit_object( transitFitObject ), ...
      'starRadiusSolarRadii' ) ;
  if ( starRadiusCondition )
      kicStarRadius = 2 * kicStarRadius ; 
  else
      kicStarRadius = 0.5 * kicStarRadius ; 
  end
  
  [convergenceFlag, fitType, bestFitObjectPreviousType, iterLimitNew, ...
      transitFitObjectLastIter, transitObject, doRobustFit] = ...
      iterator_loop_end_logic( transitFitObject, transitFitObject, ...
      oldBestFitObjectPreviousType, iterLimitOld, robustFitRequested, kicStarRadius, ...
      0.01, 50 ) ;
  
% check outputs against expected 

  outputsOk = convergenceFlag ;
  outputsOk = outputsOk && fitType == get( transitFitObject, 'fitType' ) ;
  outputsOk = outputsOk && isequal( bestFitObjectPreviousType, ...
                                   oldBestFitObjectPreviousType ) ;
  outputsOk = outputsOk && iterLimitNew == iterLimitOld ;
  outputsOk = outputsOk && isequal( transitFitObject, transitFitObjectLastIter ) ;
  outputsOk = outputsOk && isequal( transitObject, get_fitted_transit_object( ...
      transitFitObject ) ) ;
  outputsOk = outputsOk && doRobustFit == get_robust_fit_status( transitFitObject ) ;
  
  disp(' ') ;

return

% and that's it!

%
%
%


