function self = test_vel_aber( self )
%
% test_vel_aber -- unit test for velocity aberration calculation
%
% This is an mlunit unit test of the velocity aberration code.  To execute, use the
% following syntax:
%
%      run(text_test_runner, testVelocityAberrationClass('test_vel_aber')) ;
%
% Version date:  2009-June-04.
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

  disp( 'Velocity aberration tests:' ) ;

% set a calculational tolerance -- why is the numerical accuracy of this calculation so
% poor when there's a VA variation in Dec?

  tolerance = 1e-4 ;

% our test case is going to be an object with a velocity equal to exactly clight / 10000

  vObsMks = get_physical_constants_mks('speedOfLight') / 10000 ;
  maxVaDegrees = vObsMks /  get_physical_constants_mks('speedOfLight') * 180/pi ;
  
% we are going to look at 2 targets:  one with RA 50 degrees and Dec 0, one with RA 50
% degrees and dec nonzero.  Here we arbitrarily use a value which is not a "special" value
% (ie, not 30, 45, or 60 degrees)

  raTarget = 50 ; decTarget1 = 0 ; decTarget2 = 22.33 ;
  
% The test will be performed with velocity vector angles from 0 to 350 degrees in steps of
% 10.  

  theta = 0:10:350 ;
  
% find the indices of the theta values which correspond to the velocity pointing towards
% and away from the target star, and which correspond to velocity vectors perpendicular to
% the target star plane

  vTowardsTarget = find(theta==raTarget) ;
  vPosPastTarget = find(theta==raTarget+90) ;
  vAwayFromTarget = find(theta==raTarget+180) ;
  vNegPastTarget = find(theta==raTarget+270) ;
  
% compute the velocity vectors

  vx = vObsMks * cos(theta*pi/180) ;
  vy = vObsMks * sin(theta*pi/180) ;
  v = [vx ; vy ; zeros(size(vx))] ;
  
%=========================================================================================
%
% T E S T   1
%
%=========================================================================================

  disp( 'Test 1:  target star in equatorial plane (dec == 0)' ) ;

% test with a target star which lies in the equatorial plane 

  [raAber, decAber] = apply_aberration_to_ra_dec( raTarget, decTarget1, v ) ;
  dRa = raAber - raTarget ; dDec = decAber - decTarget1 ;

% Verify that all of the velocity aberration is in the equatorial plane, that there is no
% variation in the apparent declination of the target

  mlunit_assert( all( abs(dDec) < tolerance * maxVaDegrees ), ...
      'Test 1:  declination in Dec DOF is not within tol of zero' ) ;
  
% verify that the max, min, and zero VA occur at the angles predicted

  [a,b] = max(dRa) ; 
  mlunit_assert( b == vPosPastTarget, ...
      'Test 1:  max positive VA does not occur at predicted location' ) ;
  [a,b] = min(dRa) ;
  mlunit_assert( b == vNegPastTarget, ...
      'Test 1:  max negative VA does not occur at predicted location' ) ;
  z = find( abs(dRa) < tolerance * maxVaDegrees ) ;
  assert_equals( sort(z(:)), sort( [vTowardsTarget ; vAwayFromTarget] ) , ...
      'Test 1:  zero VA in RA does not occur at predicted locations' ) ;
  
% Verify the magnitude of the max and min VA

  mlunit_assert( abs(dRa(vPosPastTarget)-maxVaDegrees) < tolerance * maxVaDegrees, ...
      'Test 1:  max positive VA does not have correct magnitude' ) ;
  mlunit_assert( abs(dRa(vNegPastTarget)+maxVaDegrees) < tolerance * maxVaDegrees, ...
      'Test 1:  max negative VA does not have correct magnitude' ) ;

%=========================================================================================
%
% T E S T   2
%
%=========================================================================================

  disp( ['Test 2:  target star out of equatorial plane (dec == ',...
      num2str(decTarget2),')'] ) ;

% test with a target star which lies out of the equatorial plane

  [raAber, decAber] = apply_aberration_to_ra_dec( raTarget, decTarget2, v ) ;
  dRa = raAber - raTarget ; dDec = decAber - decTarget2 ;
  
% verify that neither RA nor Dec aberration is uniformly zero

  mlunit_assert( any( abs(dRa) > tolerance*maxVaDegrees ) || ...
                 any( abs(dDec) > tolerance*maxVaDegrees ), ...
      'Test 2:  RA or Dec has all-zero VA' ) ;
  
% verify the location of the min, max, and zeros of each component

  [a,b] = max(dRa) ; 
  mlunit_assert( b == vPosPastTarget, ...
      'Test 2:  max positive RA VA does not occur at predicted location' ) ;
  [a,b] = min(dRa) ;
  mlunit_assert( b == vNegPastTarget, ...
      'Test 2:  max negative RA VA does not occur at predicted location' ) ;
  z = find( abs(dRa) < tolerance * maxVaDegrees ) ;
  assert_equals( sort(z(:)), sort( [vTowardsTarget ; vAwayFromTarget] ) , ...
      'Test 2:  zero VA in RA does not occur at predicted locations' ) ;

  [a,b] = max(dDec) ; 
  mlunit_assert( b == vAwayFromTarget, ...
      'Test 2:  max positive Dec VA does not occur at predicted location' ) ;
  [a,b] = min(dDec) ;
  mlunit_assert( b == vTowardsTarget, ...
      'Test 2:  max negative Dec VA does not occur at predicted location' ) ;
  z = find( abs(dDec) < tolerance * maxVaDegrees ) ;
  assert_equals( sort(z(:)), sort( [vPosPastTarget ; vNegPastTarget] ) , ...
      'Test 2:  zero VA in Dec RA does not occur at predicted locations' ) ;

% verify that the magnitude is correct

  vaMag = sqrt( (dRa*cos(decTarget2*get_unit_conversion('deg2rad'))).^2 + ...
      (dDec / sin(decTarget2*get_unit_conversion('deg2rad'))).^2 ) ;
  mlunit_assert( all( abs(vaMag-maxVaDegrees) < tolerance*maxVaDegrees ) , ...
      'Test 2:  Magnitude of VA not correct for all locations' ) ;

%=========================================================================================
%
% T E S T   3
%
%=========================================================================================
  
  disp('Test 3:  vectors of RAs and Decs') ;

% This is basically a test of whether vectorized star positions and vectorized velocities
% work the way they are supposed to

% start by doing the calculations for 1 star at a time:

  [raOut1,decOut1] = apply_aberration_to_ra_dec( raTarget, decTarget1, v ) ;
  
  [raOut2,decOut2] = apply_aberration_to_ra_dec( raTarget, decTarget2, v ) ;
  
% Now construct vectorized RA and Dec and see whether the calculation still works
% correctly (velocity is already a matrix, representing many different velocity vectors)

  raAll = [raTarget raTarget] ;
  decAll = [decTarget1 decTarget2] ;
  
  [raOutAll,decOutAll] = apply_aberration_to_ra_dec( raAll, decAll, v ) ;
  
  assert_equals( raOutAll, [raOut1 raOut2], ...
      'Test 3:  Vectorized RA outputs not correct' ) ;
  assert_equals( decOutAll, [decOut1 decOut2], ...
      'Test 3:  Vectorized Dec outputs not correct' ) ;
  
% make sure that any vector / matrix orientation is acceptable

  [raOutAll,decOutAll] = apply_aberration_to_ra_dec( raAll', decAll, v ) ;
  assert_equals( raOutAll, [raOut1 raOut2], ...
      'Test 3:  Vectorized RA outputs not correct -- orientation 2' ) ;
  assert_equals( decOutAll, [decOut1 decOut2], ...
      'Test 3:  Vectorized Dec outputs not correct -- orientation 2' ) ;
  [raOutAll,decOutAll] = apply_aberration_to_ra_dec( raAll, decAll', v ) ;
  assert_equals( raOutAll, [raOut1 raOut2], ...
      'Test 3:  Vectorized RA outputs not correct -- orientation 3' ) ;
  assert_equals( decOutAll, [decOut1 decOut2], ...
      'Test 3:  Vectorized Dec outputs not correct -- orientation 3' ) ;
  [raOutAll,decOutAll] = apply_aberration_to_ra_dec( raAll', decAll', v ) ;
  assert_equals( raOutAll, [raOut1 raOut2], ...
      'Test 3:  Vectorized RA outputs not correct -- orientation 4' ) ;
  assert_equals( decOutAll, [decOut1 decOut2], ...
      'Test 3:  Vectorized Dec outputs not correct -- orientation 4' ) ;
  [raOutAll,decOutAll] = apply_aberration_to_ra_dec( raAll, decAll, v' ) ;
  assert_equals( raOutAll, [raOut1 raOut2], ...
      'Test 3:  Vectorized RA outputs not correct -- orientation 5' ) ;
  assert_equals( decOutAll, [decOut1 decOut2], ...
      'Test 3:  Vectorized Dec outputs not correct -- orientation 5' ) ;
  [raOutAll,decOutAll] = apply_aberration_to_ra_dec( raAll', decAll, v' ) ;
  assert_equals( raOutAll, [raOut1 raOut2], ...
      'Test 3:  Vectorized RA outputs not correct -- orientation 6' ) ;
  assert_equals( decOutAll, [decOut1 decOut2], ...
      'Test 3:  Vectorized Dec outputs not correct -- orientation 6' ) ;
  [raOutAll,decOutAll] = apply_aberration_to_ra_dec( raAll, decAll', v' ) ;
  assert_equals( raOutAll, [raOut1 raOut2], ...
      'Test 3:  Vectorized RA outputs not correct -- orientation 7' ) ;
  assert_equals( decOutAll, [decOut1 decOut2], ...
      'Test 3:  Vectorized Dec outputs not correct -- orientation 7' ) ;
  [raOutAll,decOutAll] = apply_aberration_to_ra_dec( raAll', decAll', v' ) ;
  assert_equals( raOutAll, [raOut1 raOut2], ...
      'Test 3:  Vectorized RA outputs not correct -- orientation 8' ) ;
  assert_equals( decOutAll, [decOut1 decOut2], ...
      'Test 3:  Vectorized Dec outputs not correct -- orientation 8' ) ;

% exercise the error statements in apply_aberration_to_ra_dec -- these call out situations
% in which the RA and Dec vectors are not equal in length, or the velocity vectors are not
% 3-vectors

  try_to_catch_error_condition( ...
      '[ra,dec] = apply_aberration_to_ra_dec( raTarget, [decTarget1 decTarget2], v ) ;', ...
      'raDecLengthsUnequal','caller' ) ;
  try_to_catch_error_condition( ...
      '[ra,dec] = apply_aberration_to_ra_dec( raTarget, decTarget1, [v ; v] ) ;', ...
      'velocityShapeInvalid', 'caller' ) ;
  disp('\n') ;
  
  
%=========================================================================================
%
% T E S T   4
%
%=========================================================================================
  
  disp( 'Test 4:  vel_aber_inv as an inverse of vel_aber' ) ;
  
% take the output of the last call and run it through the inverse process -- note that the
% inverse process is somewhat fussier about its argument shapes, in particular it requires
% that the # of velocities be either 1 or equal to the # of RA / Dec pairs

  [raRoundTrip, decRoundTrip] = remove_aberration_from_ra_dec( raOut2, decOut2, ...
      v' ) ;
  
  nTimes = length(theta) ;
  raDiff = raRoundTrip - repmat(raTarget, nTimes, 1) ;
  mlunit_assert( all(abs(raDiff(:))<tolerance*maxVaDegrees), ...
      'Test 4:  vel_aber and vel_aber_inv not inverses for all RAs' ) ;
  decDiff = decRoundTrip - repmat(decTarget2, nTimes, 1) ;
  mlunit_assert( all(abs(decDiff(:))<tolerance*maxVaDegrees), ...
      'Test 4:  vel_aber and vel_aber_inv not inverses for all Decs' ) ;
  
% test that the correct action is taken for a single velocity and multiple RA / dec pairs

  raOut3  = repmat(raOut2(1),nTimes,1) ;
  decOut3 = repmat(decOut2(1),nTimes,1) ;
  [raRoundTrip, decRoundTrip] = remove_aberration_from_ra_dec( raOut3, decOut3, ...
      [v(:,1)]' ) ;
  
  raDiff = raRoundTrip - repmat(raTarget, nTimes, 1) ;
  mlunit_assert( all(abs(raDiff(:))<tolerance*maxVaDegrees), ...
      'Test 4:  vel_aber and vel_aber_inv not inverses for single velocity' ) ;
  decDiff = decRoundTrip - repmat(decTarget2, nTimes, 1) ;
  mlunit_assert( all(abs(decDiff(:))<tolerance*maxVaDegrees), ...
      'Test 4:  vel_aber and vel_aber_inv not inverses for single velocity' ) ;
  mlunit_assert( std(raDiff) == 0, ...
      'Test 4:  not all raDiff values equal' ) ;
  mlunit_assert( std(decDiff) == 0, ...
      'Test 4:  not all decDiff values equal' ) ;
  
% Test error conditions in remove_aberration_from_ra_dec

  try_to_catch_error_condition( ...
      '[ra,dec]=remove_aberration_from_ra_dec(raOut3,[decOut3(:);decOut3(:)],[v(:,1)]'');', ...
      'raDecLengthsUnequal','caller' ) ;
  try_to_catch_error_condition( ...
      '[ra,dec]=remove_aberration_from_ra_dec(raOut3,decOut3,v);', ...
      'velocityNot3Vector','caller' ) ;
  try_to_catch_error_condition( ...
      '[ra,dec]=remove_aberration_from_ra_dec(raOut3,decOut3,[v(:,1:end-1)]'');', ...
      'velocityMatrixInvalid','caller' ) ;
  disp('\n') ;
  
% test all possible orientations of RA and Dec (note that velocity vector orientation is
% not free)

[raRoundTrip, decRoundTrip] = remove_aberration_from_ra_dec( raOut2, decOut2, ...
      v' ) ;

[raRoundTrip2, decRoundTrip2] = remove_aberration_from_ra_dec( raOut2', decOut2, ...
      v' ) ;
  assert_equals( raRoundTrip2, raRoundTrip, ...
      'Test 4:  RA results not invariant for RA transpose' ) ;
  assert_equals( decRoundTrip2, decRoundTrip, ...
      'Test 4:  Dec results not invariant for RA transpose' ) ;
  [raRoundTrip2, decRoundTrip2] = remove_aberration_from_ra_dec( raOut2, decOut2', ...
      v' ) ;
  assert_equals( raRoundTrip2, raRoundTrip, ...
      'Test 4:  RA results not invariant for Dec transpose' ) ;
  assert_equals( decRoundTrip2, decRoundTrip, ...
      'Test 4:  Dec results not invariant for Dec transpose' ) ;
  [raRoundTrip2, decRoundTrip2] = remove_aberration_from_ra_dec( raOut2', decOut2', ...
      v' ) ;
  assert_equals( raRoundTrip2, raRoundTrip, ...
      'Test 4:  RA results not invariant for RA and Dec transpose' ) ;
  assert_equals( decRoundTrip2, decRoundTrip, ...
      'Test 4:  Dec results not invariant for RA and Dec transpose' ) ;
  

return
