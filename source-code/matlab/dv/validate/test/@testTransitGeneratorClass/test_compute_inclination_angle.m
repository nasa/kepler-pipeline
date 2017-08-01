function self = test_compute_inclination_angle( self )
%
% test_compute_inclination_angle -- unit test of the compute_inclination_angle method of
% the transitGeneratorClass
%
% This unit test exercises the compute_inclination_angle method of the
% transitGeneratorClass.  In particular, it tests the following:
%
% ==> Numerical calculation of the inclination angle of a transit object
% ==> Capacity to return the angle in radians or degrees
% ==> correct execution of error statements in the method.
%
% At this time, the jacobian-calculating capabilities of the method are not tested as
% these capabilities are deprecated and are not currently used by any SOC application.
%
% This test is intended to be executed in the mlunit context.  For standalone execution
% use the following syntax:
%
%      run(text_test_runner, testTransitGeneratorClass('test_compute_inclination_angle'));
%
% Version date:  2009-October-07.
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

  disp('... testing compute_inclination_angle method ... ')
  
  testTransitGeneratorClass_initialization ;
  
% set the inclination angle to put the planet about halfway down the star's disc (impact
% parameter == 0.5)

  planetModel = get( transitObject, 'planetModel' ) ;
  planetModel.minImpactParameter = 0.5 ;
  transitObject1 = set( transitObject, 'planetModel', planetModel ) ;
  
% compute the inclination angle in radians and compare to expected value

  inclinationAngleRadians = compute_inclination_angle( transitObject1, 'radians' ) ;
  
  expectedAngle = acos( planetModel.minImpactParameter * ...
      planetModel.starRadiusSolarRadii * get_unit_conversion('solarRadius2meter') / ...
      ( planetModel.semiMajorAxisAu * get_unit_conversion('au2meter') ) ) ;
  mlunit_assert( abs(inclinationAngleRadians-expectedAngle) < 1e-12, ...
      'Computed inclination angle in radians does not match expected angle' ) ; 
  
% compute the angle in degrees and compare to expected

  inclinationAngleDegrees = compute_inclination_angle( transitObject1, 'degrees' ) ;
  mlunit_assert( abs( inclinationAngleDegrees - ...
      expectedAngle * get_unit_conversion('rad2deg') ) < 1e-12, ...
      'Computed inclination angle in degrees does not match expected angle' ) ; 

% get the default angle and compare to angle in degrees

  inclinationAngle = compute_inclination_angle( transitObject1 ) ;
  assert_equals( inclinationAngleDegrees, inclinationAngle, ...
      'Default inclination angle and inclination angle in degrees do not match' ) ;
  
% try an invalid unit string and make sure the error is thrown

  try_to_catch_error_condition( 'compute_inclination_angle(transitObject1,''grads'');', ...
      'unitStringNotRecognized', 'caller' ) ;
  disp(' ') ;
  
return

% and that's it!

%
%
%
