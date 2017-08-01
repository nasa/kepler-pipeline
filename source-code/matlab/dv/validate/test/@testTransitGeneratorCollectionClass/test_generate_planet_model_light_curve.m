function self = test_generate_planet_model_light_curve( self ) 
%
% test_generate_planet_model_light_curve -- unit test of transitGeneratorCollectionClass
% method generate_planet_model_light_curve
%
% This unit test exercises the following functionality of the
% transitGeneratorCollectionClass method generate_planet_model_light_curve:
%
% ==> Correct execution for oddEvenFlag values of 0, 1, and 2
%
% This test is intended to be executed in the mlunit context.  For standalone execution
% use the following syntax:
%
%      run(text_test_runner, testTransitGeneratorCollectionClass('test_generate_planet_model_light_curve'));
%
% Version date:  2010-May-10.
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
%    2010-May-10, PT:
%        updates in support of change to BKJD.
%
%=========================================================================================

  disp('... testing generate_planet_model_light_curve method ... ')
  
% initialize with the correct transit model

  testTransitGeneratorCollectionClass_initialization ;
  transitObject0 = transitGeneratorClass( transitModel ) ;
  [lightCurve0, cadenceTimes0] = generate_planet_model_light_curve( transitObject0 ) ;
  
% start with case 0, which has 1 model and should be identical to the single
% transitGeneratorClass object output
  
  transitObject = transitGeneratorCollectionClass( transitModel, 0 ) ;
  
  [lightCurve, cadenceTimes] = generate_planet_model_light_curve( transitObject ) ;
  assert_equals( lightCurve, lightCurve0, ...
      'light curves do not match in oddEvenFlag == 0 case' ) ;
  assert_equals( cadenceTimes, cadenceTimes0, ...
      'cadence times do not match in oddEvenFlag == 0 case' ) ;
  
% now do oddEvenFlag == 1, with a 1 cadence offset in the 2 models

  transitObject = transitGeneratorCollectionClass( transitModel, 1 ) ;
  planetModel = get( transitObject, 'planetModel' ) ;
  planetModel(2).transitEpochBkjd = planetModel(2).transitEpochBkjd + 0.0204 ;
  transitObject = set( transitObject, 'planetModel', planetModel ) ;
  transitCadences = identify_transit_cadences( transitObject, cadenceTimes, 0 ) ;
  [lightCurve, cadenceTimes] = generate_planet_model_light_curve( transitObject ) ;
  assert_not_equals( lightCurve, lightCurve0, ...
      'light curves match in oddEvenFlag == 1 case' ) ;
  assert_equals( cadenceTimes, cadenceTimes0, ...
      'cadence times do not match in oddEvenFlag == 1 case' ) ;
  assert_equals( transitCadences ~= 0, lightCurve ~= 0, ...
      'light curve and transit cadence non-zero values do not match in oddEvenFlag == 1 case' ) ;
  
% Finally oddEvenFlag == 2 with a 1 cadence offset in 1 model

  transitObject = transitGeneratorCollectionClass( transitModel, 2 ) ;
  planetModel = get( transitObject, 'planetModel' ) ;
  planetModel(3).transitEpochBkjd = planetModel(3).transitEpochBkjd + 0.0204 ;
  transitObject = set( transitObject, 'planetModel', planetModel ) ;
  transitCadences = identify_transit_cadences( transitObject, cadenceTimes, 0 ) ;
  [lightCurve, cadenceTimes] = generate_planet_model_light_curve( transitObject ) ;
  assert_not_equals( lightCurve, lightCurve0, ...
      'light curves match in oddEvenFlag == 2 case' ) ;
  assert_equals( cadenceTimes, cadenceTimes0, ...
      'cadence times do not match in oddEvenFlag == 2 case' ) ;
  assert_equals( transitCadences ~= 0, lightCurve ~= 0, ...
      'light curve and transit cadence non-zero values do not match in oddEvenFlag == 2 case' ) ;
  
  disp(' ') ;
  
return

% and that's it!

%
%
%
