function self = test_transitGeneratorCollectionClass_constructor_g_model( self )
%
% test_transitGeneratorCollectionClass_constructor_g_model -- unit test for the constructor of the transitGeneratorCollectionClass with geometric transit model
%
% test_transitGeneratorCollectionClass_constructor_g_model tests the following features of the constructor for the transitGeneratorCollectionClass:
%
% ==> instantiation without errors for oddEvenFlag == 0, 1, or 2
% ==> correct # of embedded transitGeneratorClass objects for each oddEvenFlag value
% ==> embedded transitGeneratorClass objects are identical at instantiation
% ==> gapIndicators and filledIndices flags are correctly handled when oddEvenFlag == 2
% ==> errors and warnings are correctly thrown when needed
%
% This is a unit test in the mlunit context.  To execute just this unit test, use the following syntax:
%
%   run(text_test_runner, testTransitGeneratorCollectionClass('test_transitGeneratorCollectionClass_constructor_g_model'));
%
% Version date:  2011-April-20.
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
%    2011-April-20, JL:
%        update to support DV 7.0
%
%=========================================================================================
  
  disp(' ');
  disp(' ... testing transitGeneratorCollectionClass constructor with geometric transit model ... ');
  disp(' ');
  
% initialize with the correct transit model

  testTransitGeneratorCollectionGeometricClass_initialization;
  transitObject0 = transitGeneratorClass( transitModel );
  
% Test 1:  oddEvenFlag == 0

  transitObject = transitGeneratorCollectionClass( transitModel, 0 );
  transitStruct = struct( transitObject );
  transitStructFields = fieldnames( transitStruct );
  assert_equals( transitStructFields, { 'transitGeneratorObjectVector' ; 'oddEvenFlag' }, 'transitGeneratorCollectionClass has wrong field names for oddEvenFlag == 0' );
  assert_equals( transitStruct.oddEvenFlag, 0, 'transitGeneratorCollectionClass has wrong oddEvenFlag value for oddEvenFlag == 0' );
  assert_equals( struct(transitObject0), struct(transitStruct.transitGeneratorObjectVector), ...
      'transitGeneratorCollectionClass has wrong transitGeneratorClass object for oddEvenFlag == 0' );
  
% test 2:  oddEvenFlag == 1

  transitObject = transitGeneratorCollectionClass( transitModel, 1 );
  transitStruct = struct( transitObject );
  transitStructFields = fieldnames( transitStruct );
  assert_equals( transitStructFields, { 'transitGeneratorObjectVector' ; 'oddEvenFlag' }, 'transitGeneratorCollectionClass has wrong field names for oddEvenFlag == 1' );
  assert_equals( transitStruct.oddEvenFlag, 1, 'transitGeneratorCollectionClass has wrong oddEvenFlag value for oddEvenFlag == 1' ); 
  assert_equals( size( transitStruct.transitGeneratorObjectVector ), [2 1], 'transitGeneratorCollectionClass has wrong size transitGeneratorObjectVector for oddEvenFlag == 1' );
  for iObject = 1:2
    assert_equals( struct(transitObject0), struct(transitStruct.transitGeneratorObjectVector(iObject)), ...
      'transitGeneratorCollectionClass has wrong transitGeneratorClass object for oddEvenFlag == 1' );
  end
  
% test 3:  oddEvenFlag == 2

  gapIndicators = false( size(transitModel.cadenceTimes) );
  filledIndices = [];  
  transitObject = transitGeneratorCollectionClass( transitModel, 2, gapIndicators, filledIndices );
  transitStruct = struct( transitObject );
  transitStructFields = fieldnames( transitStruct );
  assert_equals( transitStructFields, { 'transitGeneratorObjectVector' ; 'oddEvenFlag' }, 'transitGeneratorCollectionClass has wrong field names for oddEvenFlag == 2' );
  assert_equals( transitStruct.oddEvenFlag, 2, 'transitGeneratorCollectionClass has wrong oddEvenFlag value for oddEvenFlag == 2' );
  cadenceTimes = get( transitObject0, 'cadenceTimes' );
  [nTransits, nValidTransits] = get_number_of_transits_in_time_series( transitObject0, cadenceTimes, false(size(cadenceTimes)), [] );
  assert_equals( nTransits, nValidTransits, 'nTransits and nValidTransits not equal when they should be' );
  assert_equals( size( transitStruct.transitGeneratorObjectVector ), [nValidTransits 1], ...
      'transitGeneratorCollectionClass has wrong size transitGeneratorObjectVector for oddEvenFlag == 2' );
  for iObject = 1:nValidTransits
    assert_equals( struct(transitObject0), struct(transitStruct.transitGeneratorObjectVector(iObject)), ...
      'transitGeneratorCollectionClass has wrong transitGeneratorClass object for oddEvenFlag == 2' );
  end

% test 3:  oddEvenFlag == 2, but 1 transit is fully gapped

  transitCadences           = identify_transit_cadences( transitObject0, cadenceTimes, 1.0 );
  transit5                  = find( transitCadences == 5 );
  gapIndicators             = false( size( cadenceTimes ) );
  gapIndicators( transit5 ) = true;
  
  transitObject = transitGeneratorCollectionClass( transitModel, 2, gapIndicators, [] );
  transitStruct = struct( transitObject );
  transitStructFields = fieldnames( transitStruct );
  assert_equals( transitStructFields, { 'transitGeneratorObjectVector' ; 'oddEvenFlag' }, 'transitGeneratorCollectionClass has wrong field names for oddEvenFlag == 2' );
  assert_equals( transitStruct.oddEvenFlag, 2, 'transitGeneratorCollectionClass has wrong oddEvenFlag value for oddEvenFlag == 2' ) ;
  
  [nTransits, nValidTransits] = get_number_of_transits_in_time_series( transitObject0, cadenceTimes, gapIndicators, [] );
  assert_not_equals( nTransits, nValidTransits, 'nTransits and nValidTransits equal when they should not be' );
  
  assert_equals( size( transitStruct.transitGeneratorObjectVector ), [nTransits 1], ...
      'transitGeneratorCollectionClass has wrong size transitGeneratorObjectVector for oddEvenFlag == 2' );
  for iObject = 1:nTransits
    assert_equals( struct(transitObject0), struct(transitStruct.transitGeneratorObjectVector(iObject)), ...
      'transitGeneratorCollectionClass has wrong transitGeneratorClass object for oddEvenFlag == 2' );
  end
  
  
% test 4:  oddEvenFlag == 2, but transit is fully filled

  gapIndicators = false( size( cadenceTimes ) );
  
  transitObject = transitGeneratorCollectionClass( transitModel, 2, gapIndicators, transit5 );
  transitStruct = struct( transitObject );
  transitStructFields = fieldnames( transitStruct );
  assert_equals( transitStructFields, { 'transitGeneratorObjectVector' ; 'oddEvenFlag' }, 'transitGeneratorCollectionClass has wrong field names for oddEvenFlag == 2' );
  assert_equals( transitStruct.oddEvenFlag, 2, 'transitGeneratorCollectionClass has wrong oddEvenFlag value for oddEvenFlag == 2' );
  
  [nTransits, nValidTransits] = get_number_of_transits_in_time_series( transitObject0, cadenceTimes, gapIndicators, transit5 );
  assert_not_equals( nTransits, nValidTransits, 'nTransits and nValidTransits equal when they should not be' );
  
  assert_equals( size( transitStruct.transitGeneratorObjectVector ), [nTransits 1], ...
      'transitGeneratorCollectionClass has wrong size transitGeneratorObjectVector for oddEvenFlag == 2' );
  for iObject = 1:nTransits
    assert_equals( struct(transitObject0), struct(transitStruct.transitGeneratorObjectVector(iObject)), ...
      'transitGeneratorCollectionClass has wrong transitGeneratorClass object for oddEvenFlag == 2' );
  end

% test 5:  error cases

  try_to_catch_error_condition( 'transitObject = transitGeneratorCollectionClass( transitModel, 3 ) ;',     'oddEvenFlagInvalid', 'caller' );
  try_to_catch_error_condition( 'transitObject = transitGeneratorCollectionClass( transitModel, [0 1] ) ;', 'oddEvenFlagInvalid', 'caller' );
  gapIndicators = zeros( size( cadenceTimes ) );
  filledIndices = [];
  try_to_catch_error_condition( 'transitObject = transitGeneratorCollectionClass( transitModel, 2, gapIndicators, filledIndices ) ;', 'gapIndicatorsInvalid', 'caller' );
  gapIndicators = false( 2*length(cadenceTimes), 1 );
  try_to_catch_error_condition( 'transitObject = transitGeneratorCollectionClass( transitModel, 2, gapIndicators, filledIndices ) ;', 'gapIndicatorsInvalid', 'caller' );
  gapIndicators = false( size(cadenceTimes) );
  filledIndices = [0];
  try_to_catch_error_condition( 'transitObject = transitGeneratorCollectionClass( transitModel, 2, gapIndicators, filledIndices ) ;', 'filledIndicesInvalid', 'caller' );
  filledIndices = [1 2 ; 3 4];
  try_to_catch_error_condition( 'transitObject = transitGeneratorCollectionClass( transitModel, 2, gapIndicators, filledIndices ) ;', 'filledIndicesInvalid', 'caller' );

% test 6:  warning cases

  disp(' ');
  
  transitObject = transitGeneratorCollectionClass( transitModel, 2, gapIndicators );
  [w1,w2] = lastwarn;
  mlunit_assert( ~isempty( strfind( w2, 'filledIndicesNotPresent' ) ), 'filledIndicesNotPresent warning not issued' );
  
  transitObject = transitGeneratorCollectionClass( transitModel, 2, [], [] );
  [w1,w2] = lastwarn;
  mlunit_assert( ~isempty( strfind( w2, 'gapIndicatorsNotPresent' ) ), 'gapIndicatorsNotPresent warning not issued' );
  
  disp(' ');
  
return

% and that's it!

  