function self = test_transitGeneratorCollectionClass_set( self )
%
% test_transitGeneratorCollectionClass_set -- unit test for the set method of the
% transitGeneratorCollectionClass
%
% test_transitGeneratorCollectionClass_set tests the following features of the set method
% for the transitGeneratorCollectionClass:
%
% ==> incorrect dimension for the planetModel argument generates an error
% ==> setting the planetModel produces the correct return value for getting the planet
%     model
%
% This is a unit test in the mlunit context.  To execute just this unit test, use the
% following syntax:
%
%   run(text_test_runner, testTransitGeneratorCollectionClass('test_transitGeneratorCollectionClass_set'));
%
% Version date:  2010-April-26.
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

  disp(' ... testing transitGeneratorCollectionClass get method ... ') ;
  
% initialize with the correct transit model

  testTransitGeneratorCollectionClass_initialization ;
  transitObject = transitGeneratorCollectionClass( transitModel, 2 ) ;
  
% get the initial planet model

  planetModel = get( transitObject, 'planetModel' ) ;
  
% touch one value

  planetModel(2).transitDepthPpm = 1050 ;
  
% put the model back, get it, and make sure that the values are correct

  transitObject = set( transitObject, 'planetModel', planetModel ) ;
  planetModelNew = get( transitObject, 'planetModel' ) ;
  planetModelNewUntouched = planetModelNew([1 3:6]) ;
  planetModelUntouched = planetModel([1 3:6]) ;
  assert_equals( planetModelUntouched, planetModelNewUntouched, ...
      'Untouched planet models do not agree' ) ;
  
  assert_not_equals( planetModelUntouched(1), planetModelNew(2), ...
      'Touched planet model not correct' ) ;
  mlunit_assert( abs( planetModelNew(2).transitDepthPpm - 1050 ) < 0.1, ...
      'Touched planet model depth not correct' ) ;
  
% check that error occurs if the dimension of the planet model is wrong

  try_to_catch_error_condition( 'to=set(transitObject,''planetModel'',planetModel(1)) ;', ...
      'memberValueDimensionsInvalid', 'caller' ) ;
  
  disp(' ') ;
  
return

% and that's it!

%
%
%
