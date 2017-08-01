function self = test_get_included_excluded_cadences_geometric_model( self ) 
%
% test_get_included_excluded_cadences_geometric_model -- unit test for get_included_excluded_cadences method of transitFitClass with geometric transit model
%
% This test exercises the get_included_excluded_cadences method of the transitFitClass. It verifies that, for a given object with known gapped and filled cadences, 
% the correct cadences are reported as included and excluded.
%
% This test is intended to be executed in the mlunit context.  For standalone execution use the following syntax:
%
%      run(text_test_runner, testTransitFitClass('test_get_included_excluded_cadences_geometric_model'));
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
%    2010-May-02, PT:
%        handle different use-cases -- include or exclude good cadences which are far from
%        a transit.
%
%=========================================================================================

  disp(' ');
  disp('... testing included-excluded cadences method with geometric_transit_model ... ');
  disp(' ');

% we don't do the complete initialization, just set the paths and load the object struct

  initialize_soc_variables;
  testDataDir = [socTestDataRoot, filesep, 'dv', filesep, 'unit-tests', filesep, 'transitFitGeometricClass'];
  
% find the near-transit cadences

  load(fullfile(testDataDir,'transit-generator-model'));
  transitObject = transitGeneratorCollectionClass( transitModel, 0 );
  cadenceTimes  = get(transitObject, 'cadenceTimes');
  transitNumber = identify_transit_cadences( transitObject, cadenceTimes, 1.0 );
  
% set some cadences to be gapped and filled

  load(fullfile(testDataDir,'transit-fit-struct'));
  nCadences = length( transitFitStruct.whitenedFluxTimeSeries.values );
  transitFitStruct.whitenedFluxTimeSeries.gapIndicators = false(nCadences,1);
  transitFitStruct.whitenedFluxTimeSeries.gapIndicators(1:250) = true;
  transitFitStruct.whitenedFluxTimeSeries.filledIndices = [251:500];
  
% the expected cadences to be used are near-transit and not members of the range  

  cadencesUsedExpected = false(nCadences,1);
  cadencesUsedExpected( transitNumber>0 ) = true;
  cadencesUsedExpected( 1:500 ) = false;
  cadencesNotUsedExpected = ~cadencesUsedExpected;
  
  transitFitObject1 = transitFitClass( transitFitStruct, 12 );
  [cadencesUsed, cadencesNotUsed] = get_included_excluded_cadences( transitFitObject1, true );
  assert_equals( length(cadencesUsed),    nCadences, 'cadencesUsed has wrong size!'    );
  assert_equals( length(cadencesNotUsed), nCadences, 'cadencesNotUsed has wrong size!' );
  mlunit_assert( islogical( cadencesUsed ),    'cadencesUsed is not logical array!'    );
  mlunit_assert( islogical( cadencesNotUsed ), 'cadencesNotUsed is not logical array!' );
  assert_equals( find(cadencesNotUsed(:)), find(cadencesNotUsedExpected(:)), 'cadencesNotUsed has incorrect values!' );
  mlunit_assert( isempty(find( cadencesUsed & cadencesNotUsed , 1) ),   'cadencesUsed and cadencesNotUsed not exclusive!' );
  mlunit_assert( isempty(find( ~cadencesUsed & ~cadencesNotUsed , 1) ), 'cadencesUsed and cadencesNotUsed do not span the range of cadences!' );
  
% now do the test with the distant cadences included and not excluded

  cadencesUsedExpected = true(3000,1);
  cadencesUsedExpected( 1:500 ) = false;
  cadencesNotUsedExpected = ~cadencesUsedExpected;
  
  [cadencesUsed, cadencesNotUsed] = get_included_excluded_cadences( transitFitObject1, false );

  assert_equals( length(cadencesUsed),    nCadences, 'cadencesUsed has wrong size!'    );
  assert_equals( length(cadencesNotUsed), nCadences, 'cadencesNotUsed has wrong size!' );
  mlunit_assert( islogical( cadencesUsed ),    'cadencesUsed is not logical array!'    );
  mlunit_assert( islogical( cadencesNotUsed ), 'cadencesNotUsed is not logical array!' );
  assert_equals( find(cadencesNotUsed(:)), find(cadencesNotUsedExpected(:)), 'cadencesNotUsed has incorrect values!' );
  mlunit_assert( isempty(find( cadencesUsed & cadencesNotUsed , 1) ),   'cadencesUsed and cadencesNotUsed not exclusive!' );
  mlunit_assert( isempty(find( ~cadencesUsed & ~cadencesNotUsed , 1) ), 'cadencesUsed and cadencesNotUsed do not span the range of cadences!' );

  [cadencesUsed2, cadencesNotUsed2] = get_included_excluded_cadences( transitFitObject1 );
  
  mlunit_assert( isequal(cadencesUsed, cadencesUsed2) && isequal(cadencesNotUsed, cadencesNotUsed2), 'default case not identical to flag==false case' );
  
  disp(' ');
  
return

% and that's it!
