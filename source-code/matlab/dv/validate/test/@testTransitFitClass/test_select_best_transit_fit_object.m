function self = test_select_best_transit_fit_object( self )
%
% test_select_best_transit_fit_object -- unit test of transitFitClass method
% select_best_transit_fit_object
%
% This is a unit test of the select_best_transit_fit_object method of the transitFitClass.
% It tests the following functionality:
%
% ==> The method does the right thing when invoked with only 1 transitFitClass object
%     in the argument list
% ==> When presented with 2 transitFitClass objects, it returns as "best" the one with the
%     lower normalized chi-squared, correctly returns the chi-squares, and returns the
%     fitType of the best object.
%
% This test is intended to be executed in the mlunit context.  For standalone execution
% use the following syntax:
%
%      run(text_test_runner, testTransitFitClass('test_select_best_transit_fit_object'));
%
% Version date:  2009-September-24.
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

  disp('... testing select_best_transit_fit_object method ... ')

% perform initialization

  testTransitFitClass_initialization ;

% use-case with one transitFitClass object in the invocation

  [bestObject, fitType, chiSquare] = select_best_transit_fit_object( ...
      transitFitObject1, [] ) ;
  outputsOk = isequal( bestObject, transitFitObject1 ) ;
  outputsOk = outputsOk && fitType == get( transitFitObject1, 'fitType' ) ;
  outputsOk = outputsOk && chiSquare(1) == ...
      get( transitFitObject1, 'chisq') / get( transitFitObject1, 'ndof' ) ;
  outputsOk = outputsOk && isnan(chiSquare(2)) ;
  
  mlunit_assert( outputsOk, ...
      'Incorrect outputs on single-object use case' ) ;
  
% now cobble together a second object with a different chi-square and fit type

  transitFitStruct1 = get( transitFitObject1, '*' ) ;
  transitFitStruct1.fitType = 0 ;
  transitFitStruct1.chisq = transitFitStruct1.chisq / 2 ;
  transitFitObject2 = transitFitClass( transitFitStruct1, 0 ) ;
  
% do the test and check the outputs

  [bestObject, fitType, chiSquare] = select_best_transit_fit_object( ...
      transitFitObject1, transitFitObject2 ) ;
  outputsOk = isequal( bestObject, transitFitObject2 ) ;
  outputsOk = outputsOk && fitType == get( bestObject, 'fitType' ) ;
  outputsOk = outputsOk && chiSquare(1) == ...
      get( transitFitObject1, 'chisq') / get( transitFitObject1, 'ndof' ) ;
  outputsOk = outputsOk && chiSquare(2) == ...
      get( transitFitObject2, 'chisq') / get( transitFitObject2, 'ndof' ) ;
 
  mlunit_assert( outputsOk, ...
      'Incorrect outputs on two-object use case' ) ;
  
% reverse the order of the objects and make sure that the correct results are still
% produced

  [bestObject, fitType, chiSquare] = select_best_transit_fit_object( ...
      transitFitObject2, transitFitObject1 ) ;
  outputsOk = isequal( bestObject, transitFitObject2 ) ;
  outputsOk = outputsOk && fitType == get( bestObject, 'fitType' ) ;
  outputsOk = outputsOk && chiSquare(2) == ...
      get( transitFitObject1, 'chisq') / get( transitFitObject1, 'ndof' ) ;
  outputsOk = outputsOk && chiSquare(1) == ...
      get( transitFitObject2, 'chisq') / get( transitFitObject2, 'ndof' ) ;

  mlunit_assert( outputsOk, ...
      'Incorrect outputs on two-object reversed-order use case' ) ;
  
  disp(' ') ;
  
return

% and that's it!

%
%
%
