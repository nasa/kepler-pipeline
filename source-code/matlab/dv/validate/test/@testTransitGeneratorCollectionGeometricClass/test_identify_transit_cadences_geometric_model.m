function self = test_identify_transit_cadences_geometric_model( self )
%
% test_identify_transit_cadences_geometric_model -- unit test for identify_transit_cadences method of transitGeneratorCollectionClass with geometric transit model
%
% This unit test exercises the following functionality of the method:
%
% ==> Basic functionality, oddEvenFlag == 0 case
% ==> Functionality, oddEvenFlag == 1 case (odd and even transits can be offset in time)
% ==> Advanced functionality, oddEvenFlag == 2 case (all transits can be offset in time)
%
% This is a unit test in the mlunit context.  To execute just this unit test, use the following syntax:
%
%   run(text_test_runner, testTransitGeneratorCollectionClass('test_identify_transit_cadences_geometric_model'));
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
%    2010-May-10, PT:
%        changes in support of BKJD time standard.
%
%=========================================================================================

  disp(' ');
  disp(' ... testing transitGeneratorCollectionClass identify transit cadences method with geometric transit model ... ');
  disp(' ');
   
% initialize with the correct transit model

  testTransitGeneratorCollectionGeometricClass_initialization;
  
% oddEvenFlag == 0 case

  transitObject = transitGeneratorCollectionClass( transitModel, 0 );
  cadenceTimes = get( transitObject, 'cadenceTimes' );
  transitCadences = identify_transit_cadences( transitObject, cadenceTimes, 1.0 ) ;
  transitCadences2 = identify_transit_cadences( get( transitObject, 'transitGeneratorObjectVector' ), cadenceTimes, 1.0 );
  assert_equals( transitCadences, transitCadences2, 'Cadences for oddEvenFlag == 0 case not correct' );
  
% oddEvenFlag == 1 case -- put an offset of ~1 cadence between the two objects

  transitObject = transitGeneratorCollectionClass( transitModel, 1 );
  planetModel = get( transitObject, 'planetModel' );
  planetModel(1).transitEpochBkjd = planetModel(1).transitEpochBkjd + 0.0205;
  transitObject = set( transitObject, 'planetModel', planetModel );
  
  transitCadences = identify_transit_cadences( transitObject, cadenceTimes, 1.0 );
  transitCadences = find( transitCadences > 0 );

  transitGeneratorObjectVector = get( transitObject, 'transitGeneratorObjectVector' );
  transitCadences2 = identify_transit_cadences( transitGeneratorObjectVector(1), cadenceTimes, 1.0 );
  transitCadences2 = find( mod(transitCadences2,2) == 1 );
  transitCadences3 = identify_transit_cadences( transitGeneratorObjectVector(2), cadenceTimes, 1.0 );
  transitCadences3 = find( mod(transitCadences3,2) == 0 & transitCadences3 > 0 );
  transitCadences2 = sort( [transitCadences2 ; transitCadences3] );
  
  assert_equals( transitCadences, transitCadences2, 'Cadences for oddEvenFlag == 1 case not correct' );
  
% oddEvenFlag == 2 case -- put an offset of ~1 cadence in the 3rd object

  gapIndicators = false( size(transitModel.cadenceTimes) );
  filledIndices = [];  
  transitObject = transitGeneratorCollectionClass( transitModel, 2, gapIndicators, filledIndices );
  planetModel = get( transitObject, 'planetModel' );
  planetModel(3).transitEpochBkjd = planetModel(1).transitEpochBkjd + 0.0205;
  transitObject = set( transitObject, 'planetModel', planetModel );
  
  transitCadences = identify_transit_cadences( transitObject, cadenceTimes, 1.0 );
  transitCadences = find( transitCadences > 0 );

  transitCadences2 = [];
  transitGeneratorObjectVector = get( transitObject, 'transitGeneratorObjectVector' );
  for iObject = 1:length(transitGeneratorObjectVector)
      
      transitCadences3 = identify_transit_cadences( transitGeneratorObjectVector(iObject), cadenceTimes, 1.0 );
      transitCadences2 = [transitCadences2 ; find(transitCadences3 == iObject)];
      
  end
  
  assert_equals( transitCadences, transitCadences2, 'Cadences for oddEvenFlag == 2 case not correct' );

  disp(' ');
  
return

% and that's it!

