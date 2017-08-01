function self = test_jacobian( self )
%
% test_jacobian -- test the compute_jacobian function in the common library
%
% This is a unit test, for use in the mlunit testing context.  It tests the
%    compute_jacobian function to verify the following:
%
% ==> Mismatches in the modelSize and stepSize argument generate an error
% ==> Model functions which are independent of one or more of the requested parameters
%     generate an error
% ==> Outputs have the correct dimension and value
% ==> Functions which take 1 argument (modelPars) or 2 arguments (modelPars, X) are both
%     handled correctly
% ==> Changing the step size results in a change in the jacobian
% ==> Scalar step size or vector, length==length(modelPars) step sizes are accepted
% ==> Omitting the step size is acceptable
% ==> Any combination of row and column arguments is equally acceptable.
% ==> Optional arguments to control the iteration process and handle models which are
%     independent of some parameters work correctly.
%
% This method is not intended to be executed directly; instead, the mlunit test harness is
% to be used.  The correct syntax for executing this test is:
%
%      run(text_test_runner, jacobianTestClass('test_jacobian')) ;
%
% Version date:  2009-October-09.
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
%    2009-October-09, PT:
%        add tests of maxIter, maxDelta, deltaScale, failType arguments.
%
%=========================================================================================

% Hard-coded convergence parameter -- jacobian terms should be within this value of what
% we calculate by hand

  agreementTolerance = 2e-6 ;

% generate a couple of anonymous functions which can be used for testing.  First function:
% Coordinate transformation between Cartesian and cylindrical coordinates in 2 dimensions

  f1 = @(b) [sqrt(b(1)^2 + b(2)^2) ; atan2(b(2),b(1))] ;
  
% second function:  a polynomial with variable coefficients, which allows us to test
% Jacobians for functions which take a parameter argument and a vector of variables.  To
% make the error-exercise work right, limit the polynomial to 3rd order

  f2 = @(b,x) polyval(b(1:min([4 length(b)])),x) ;
  
% finally, a function which returns zero for arguments below a threshold, and returns the
% argument when it is above threshold.  This allows us to test the iterative increments to
% the differential

  threshold = 0.001 ;
  f3 = @(b) threshold_return( b, threshold ) ;
  
%=========================================================================================
%
% E X E R C I S E   E R R O R   C O N D I T I O N S
%
%=========================================================================================

% Error condition 1:  jacobian calculator called with parameter vector and step size
% vector which are not equal in length

  try_to_catch_error_condition( 'J=compute_jacobian(f2,[1 1 1 1],[1 2 3 4 5],[1 1 1]) ;', ...
      'argumentSizeMismatch', 'caller' ) ;
  
% Error condition 2:  jacobian calculator called with a parameter which does not change
% the value of the function

  try_to_catch_error_condition( 'J=compute_jacobian(f2,[1 1 1 1 1],[1 2 3 4]) ;', ...
      'badModelParameter', 'caller' ) ;
  
% it should also be an error when we explicitly ask for an error

  try_to_catch_error_condition( ...
      'J=compute_jacobian(f2,[1 1 1 1 1],[1 2 3 4],[],[],[],[],''error'') ;', ...
      'badModelParameter', 'caller' ) ;

% when we ask for warning, the correct warning should show up

  lastwarn('') ;
  J=compute_jacobian( f2, [1 1 1 1 1], [1 2 3 4], [], [], [], [], 'warning') ;
  [lastMessage,lastWarningId] = lastwarn ;
  assert_equals( lastWarningId, ...
      'common:computeJacobian:badModelParameter', ...
      'warning of model independent of parameter not issued' ) ;
  
% when we ask for no response at all to a model independent of one of its parameters, that
% should be correctly handled as well

  lastwarn('') ;
  J=compute_jacobian( f2, [1 1 1 1 1], [1 2 3 4], [], [], [], [], 'nothing') ;
  [lastMessage,lastWarningId] = lastwarn ;
  assert_equals( lastWarningId, ...
      '', ...
      'model independent of parameter not tolerated' ) ;
  
% error condition 3:  bad values for optional arguments

  try_to_catch_error_condition( ...
      'J=compute_jacobian(f2,[1 1 1 1],[1 2 3 4],[],-1,[],[]) ;', ...
      'iterationParametersInvalid', 'caller' ) ;
  
  try_to_catch_error_condition( ...
      'J=compute_jacobian(f2,[1 1 1 1],[1 2 3 4],[],[],-1,[]) ;', ...
      'iterationParametersInvalid', 'caller' ) ;
  
  try_to_catch_error_condition( ...
      'J=compute_jacobian(f2,[1 1 1 1],[1 2 3 4],[],[],[],0) ;', ...
      'iterationParametersInvalid', 'caller' ) ;
 
%=========================================================================================
%
% D I M E N S I O N S   A N D   V A L U E S
%
%=========================================================================================

% Compute the Jacobian for f2 with 3 coefficients and 10 values of x; the dimension should
% be 10 x 3.  This also tests that omitting the step size is acceptable

  J = compute_jacobian(f2,[3 2 1],[1:10]) ;
  assert_equals( size(J), [10 3], ...
      'Jacobian matrix has incorrect dimensions!' ) ;
  
% For the parameters above, the Jacobian should be [x.^2 x 1] to within the acceptance
% tolerance

  xTest = [1:10]' ;
  analyticJ = [xTest.^2 xTest repmat(1,size(xTest))] ;
  mlunit_assert( all(abs(analyticJ(:)-J(:))<agreementTolerance), ...
      'Numeric and analytic Jacobians do not agree!' ) ;

% Check the value for the polynomial with fixed coefficients

  J = compute_jacobian(f1,[1 1]) ;
  analyticJ = [sqrt(2)/2 sqrt(2)/2 ; -0.5 0.5] ;
  mlunit_assert( all(abs(analyticJ(:)-J(:))<agreementTolerance), ...
      'Numeric and analytic Jacobians do not agree!' ) ;
  
%=========================================================================================
%
% A R G U M E N T   V A R I A T I O N S
%
%=========================================================================================

% check that both the 1-argument and 2-argument versions can work with a step size
% argument

  J = compute_jacobian(f2,[3 2 1],[1:10],1e-6) ;
  J = compute_jacobian(f1,[1 1],[],1e-6) ;
  
% Check that changing the value of the step size changes the value of the Jacobian

  J2 = compute_jacobian(f1,[1 1],[],2e-6) ;
  assert_not_equals(J,J2,...
      'Jacobians are equal when they should not be!') ;
  
% check that a vector of stepSize is acceptable

  J3 = compute_jacobian(f1,[1 1],[],[1e-6 2e-6]) ;
  
% check that all combinations of row and column arguments work

  J = compute_jacobian(f2,[3 2 1],[1:10],[1e-6 1e-6 1e-6]) ;
  J = compute_jacobian(f2,[3 2 1]',[1:10],[1e-6 1e-6 1e-6]) ;
  J = compute_jacobian(f2,[3 2 1],[1:10]',[1e-6 1e-6 1e-6]) ;
  J = compute_jacobian(f2,[3 2 1]',[1:10]',[1e-6 1e-6 1e-6]) ;
  J = compute_jacobian(f2,[3 2 1],[1:10],[1e-6 1e-6 1e-6]') ;
  J = compute_jacobian(f2,[3 2 1]',[1:10],[1e-6 1e-6 1e-6]') ;
  J = compute_jacobian(f2,[3 2 1],[1:10]',[1e-6 1e-6 1e-6]') ;
  J = compute_jacobian(f2,[3 2 1]',[1:10]',[1e-6 1e-6 1e-6]') ;

%=========================================================================================
%
% I T E R A T I O N   P A R A M E T E R S
%
%=========================================================================================

% by defining the step size and iteration parameters correctly we can cause or prevent
% error in the Jacobian calculator due to model-independence

  stepSize = 1e-6 ;
  try_to_catch_error_condition( ...
      'J=compute_jacobian(f3,0,[],stepSize,2,[],[]) ;', ...
      'badModelParameter', 'caller' ) ;
  try_to_catch_error_condition( ...
      'J=compute_jacobian(f3,0,[],stepSize,[],1e-4,[]) ;', ...
      'badModelParameter', 'caller' ) ;
  try_to_catch_error_condition( ...
      'J=compute_jacobian(f3,0,[],stepSize,4,[],2) ;', ...
      'badModelParameter', 'caller' ) ;
  
% now set the parameters such that the scale-up is limited but sufficient to produce
% success

  J = compute_jacobian( f3, 0, [], stepSize, 2, [], 40 ) ;

  disp(' ') ;
  
return

% and that's it!

%
%
%

%=========================================================================================

% subfunction which returns its argument if and only if it is above a set threshold

function b1 = threshold_return( b0, threshold )

  if b0 > threshold
      b1 = b0 ;
  else
      b1 = 0 ;
  end
  
return