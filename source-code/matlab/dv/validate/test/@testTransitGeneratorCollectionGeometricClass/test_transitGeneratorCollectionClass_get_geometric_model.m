function self = test_transitGeneratorCollectionClass_get_geometric_model( self )
%
% test_transitGeneratorCollectionClass_get_geometric_model -- unit test for the get method of the transitGeneratorCollectionClass with geometric transit model
%
% test_transitGeneratorCollectionClass_get tests the following features of the get method for the transitGeneratorCollectionClass:
%
% ==> 'help' and '?' produce correct lists of members
% ==> planet model and its subsidiary fields produce vectors of output
% ==> All other requested members produce scalars (except for cadenceTimes)
% ==> '*' produces an error
%
% This is a unit test in the mlunit context.  To execute just this unit test, use the following syntax:
%
%   run(text_test_runner, testTransitGeneratorCollectionClass('test_transitGeneratorCollectionClass_get_geometric_model'));
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
  disp(' ... testing transitGeneratorCollectionClass get method with geometric transit model ... ');
  disp(' ');
  
% initialize with the correct transit model

  testTransitGeneratorCollectionGeometricClass_initialization;
  transitObject0 = transitGeneratorClass( transitModel );
  
  gapIndicators = false( size(transitModel.cadenceTimes) );
  filledIndices = [];  
  transitObject = transitGeneratorCollectionClass( transitModel, 2, gapIndicators, filledIndices );
  
% identify the member names which should produce something other than the value which is in the embedded transitGeneratorClass single object

  planetModel = get( transitObject0, 'planetModel' );
  planetModelFields = fieldnames( planetModel );
  fieldsWithVectorOutput = [planetModelFields; 'planetModel'; 'planetRadiusMeters'; 'semiMajorAxisMeters'; 'starRadiusMeters'];
  transitGeneratorClassMembers = get( transitObject0, '?' );
  nonVectorOutput = ~ismember( transitGeneratorClassMembers, fieldsWithVectorOutput );
  fieldsWithoutVectorOutput = transitGeneratorClassMembers( nonVectorOutput );
  
% test 1:  'help' and '?'

  helpReturn = get( transitObject, '?' );
  assert_equals( helpReturn, [transitGeneratorClassMembers; 'transitGeneratorObjectVector'; 'oddEvenFlag'], '''?'' argument produces incorrect output' );
  helpReturn = get( transitObject, 'help' ) ;
  assert_equals( helpReturn, [transitGeneratorClassMembers; 'transitGeneratorObjectVector'; 'oddEvenFlag'], '''help'' argument produces incorrect output' );
  helpReturn = get( transitObject, 'HELP' ) ;
  assert_equals( helpReturn, [transitGeneratorClassMembers; 'transitGeneratorObjectVector'; 'oddEvenFlag'], '''HELP'' argument produces incorrect output' );
  
% test 2:  oddEvenFlag

  oddEvenReturn = get( transitObject, 'oddEvenFlag' );
  assert_equals( oddEvenReturn, 2, 'oddEvenFlag value wrong in get' );
  
% test 3:  transitGeneratorObjectVector

  tgovReturn = get( transitObject, 'transitGeneratorObjectVector' );
  assert_equals( size( tgovReturn ), [13 1], 'Size of transitGeneratorObjectVector wrong in get' );
  for iObject = 1:length( tgovReturn )
      assert_equals( struct( tgovReturn(iObject) ), struct( transitObject0 ), 'transitGeneratorObjectVector values wrong in get' );
  end
  
% test 4: "non-vector" returns

  for iMember = 1:length( fieldsWithoutVectorOutput )
      retval = get( transitObject, fieldsWithoutVectorOutput{iMember} );
      assert_equals( retval, get( transitObject0, fieldsWithoutVectorOutput{iMember} ), ['Member ''', fieldsWithoutVectorOutput{iMember}, ''' value wrong in get'] );
  end
  
% test 5:  vector returns

  for iMember = 1:length( fieldsWithVectorOutput )
      retval = get( transitObject, fieldsWithVectorOutput{iMember} );
      retval0 = get( transitObject0, fieldsWithVectorOutput{iMember} );
      assert_equals( retval, repmat(retval0, 13, 1), ['Member ''', fieldsWithVectorOutput{iMember}, ''' value wrong in get'] );
  end

% test 6:  error on '*'

  try_to_catch_error_condition( 'retval=get(transitObject,''*'');', 'wildCardNotValid', 'caller' );
  
  disp(' ');
  
return

% and that's it!
