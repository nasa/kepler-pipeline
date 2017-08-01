function self = test_blobSeries_validation(self)
%
% test_blobSeries_validation -- unit test of the validation algorithms within the
% blobSeriesClass
%
% test_blobSeries_validation exercises the validation algorithms inside of the
% blobSeriesClass constructor and verifies that they are working correctly.  This means
% that:
%
% ==> all fields (blobIndices, gapIndicators, blobFilenames) are present in the 
%        instantiating structure
% ==> blobIndices and gapIndicators are the same length, and are vectors
% ==> gapIndicators is logical
% ==> blobIndices is integer-valued, numeric, and real
% ==> the values in blobIndices are correct (they point to members of blobData)
% ==> blobFilenames is a vector cell array
%
% All of the validations listed above will be exercised in the course of this test.
%
% This is a unit test designed to run in the context of mlunit, and is called with a test
% runner:
%
%      run(text_test_runner, blobSeriesTestClass('test_blobSeries_validation'));
%
% or else as a master all-test run via blobSeries_run_all_tests_txt or
% blobSeries_run_all_tests_gui.
%
% Version date:  2008-September-19.
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
%     2008-September-19, PT:
%         support for startCadence and endCadence members.
%     2008-September-07, PT:
%         blobIndices can be any numeric class but must be integer valued and real, int32
%         no longer required.
%
%=========================================================================================

% no quick and dirty action here

  quickAndDirtyCheckFlag = false ;

% start by generating a valid blobSeries structure for test, and demonstrate that it
% instantiates without error

  blobSeriesStruct = make_test_blobSeries_structure() ;
  blobSeriesObject = blobSeriesClass(blobSeriesStruct) ;
  
% presence of required fields:  note that the fields used here are the fields of the
% Java-side blobSeries, which are subtly different from the fields which are validated in
% the class constructor

  validGapIndicatorsString = '[true false]' ;
  fieldsAndBounds = cell(5,4) ;
  fieldsAndBounds(1,:) = { 'blobIndices' ; [] ; [] ; [] } ;
  fieldsAndBounds(2,:) = { 'gapIndicators' ; [] ; [] ; validGapIndicatorsString } ;
  fieldsAndBounds(3,:) = { 'blobFilenames' ; [] ; [] ; [] } ;
  fieldsAndBounds(4,:) = { 'startCadence' ; [] ; [] ; [] } ;
  fieldsAndBounds(5,:) = { 'endCadence' ; [] ; [] ; [] } ;
  remove_field_and_test_for_failure( blobSeriesStruct, 'blobSeriesStruct', ...
      blobSeriesStruct, 'blobSeriesStruct', 'blobSeriesClass', fieldsAndBounds, ...
      quickAndDirtyCheckFlag ) ;
  
  blobSeriesStructGood = blobSeriesStruct ; 
  
% test vector nature of all fields, length of blobIndices and gapIndicators, and cell
% array form of blobFilenames

  blobSeriesStruct = blobSeriesStructGood ;
  blobSeriesStruct.blobIndices = [blobSeriesStruct.blobIndices  ...
                                 blobSeriesStruct.blobIndices ; ...
                                 blobSeriesStruct.blobIndices   ...
                                 blobSeriesStruct.blobIndices] ;
  try_to_catch_error_condition( 'a=blobSeriesClass(blobSeriesStruct);', ...
      'cadenceVectorsInvalid', blobSeriesStruct, 'blobSeriesStruct' ) ;
  
  blobSeriesStruct = blobSeriesStructGood ;
  blobSeriesStruct.gapIndicators = [blobSeriesStruct.gapIndicators   ...
                                    blobSeriesStruct.gapIndicators ; ...
                                    blobSeriesStruct.gapIndicators   ...
                                    blobSeriesStruct.gapIndicators] ;
  try_to_catch_error_condition( 'a=blobSeriesClass(blobSeriesStruct);', ...
      'cadenceVectorsInvalid', blobSeriesStruct, 'blobSeriesStruct' ) ;

  blobSeriesStruct = blobSeriesStructGood ;
  blobSeriesStruct.gapIndicators(end) = [] ;
  try_to_catch_error_condition( 'a=blobSeriesClass(blobSeriesStruct);', ...
      'cadenceVectorsInvalid', blobSeriesStruct, 'blobSeriesStruct' ) ;

  blobSeriesStruct = blobSeriesStructGood ;
  blobSeriesStruct.blobFilenames = [blobSeriesStruct.blobFilenames   ...
                                    blobSeriesStruct.blobFilenames ; ...
                                    blobSeriesStruct.blobFilenames   ...
                                    blobSeriesStruct.blobFilenames] ;
  try_to_catch_error_condition( 'a=blobSeriesClass(blobSeriesStruct);', ...
      'blobFilenamesNotVectorCellArray', blobSeriesStruct, 'blobSeriesStruct' ) ;  
  
  blobSeriesStruct = blobSeriesStructGood ;
  blobSeriesStruct.blobFilenames = 'clancy' ;
  try_to_catch_error_condition( 'a=blobSeriesClass(blobSeriesStruct);', ...
      'blobFilenamesNotVectorCellArray', blobSeriesStruct, 'blobSeriesStruct' ) ;
 
  blobSeriesStruct = blobSeriesStructGood ;
  blobSeriesStruct.blobFilenames{1} = ['clancy' ; 'clancy'] ;
  try_to_catch_error_condition( 'a=blobSeriesClass(blobSeriesStruct);', ...
      'blobFilenamesNotCharVectors', blobSeriesStruct, 'blobSeriesStruct' ) ;
 
  blobSeriesStruct = blobSeriesStructGood ;
  blobSeriesStruct.blobFilenames{1} = 10 ;
  try_to_catch_error_condition( 'a=blobSeriesClass(blobSeriesStruct);', ...
      'blobFilenamesNotCharVectors', blobSeriesStruct, 'blobSeriesStruct' ) ;
 
% test validation of startCadence and endCadence fields  

  blobSeriesStruct = blobSeriesStructGood ;
  blobSeriesStruct.startCadence = [blobSeriesStruct.startCadence   ...
                                   blobSeriesStruct.startCadence ; ...
                                   blobSeriesStruct.startCadence   ...
                                   blobSeriesStruct.startCadence] ;
  try_to_catch_error_condition( 'a=blobSeriesClass(blobSeriesStruct);', ...
      'startCadenceNotScalar', blobSeriesStruct, 'blobSeriesStruct' ) ;
                               
  blobSeriesStruct = blobSeriesStructGood ;
  blobSeriesStruct.endCadence = [blobSeriesStruct.endCadence   ...
                                   blobSeriesStruct.endCadence ; ...
                                   blobSeriesStruct.endCadence   ...
                                   blobSeriesStruct.endCadence] ;
  try_to_catch_error_condition( 'a=blobSeriesClass(blobSeriesStruct);', ...
      'endCadenceNotScalar', blobSeriesStruct, 'blobSeriesStruct' ) ;
                               
  blobSeriesStruct = blobSeriesStructGood ;
  blobSeriesStruct.startCadence = blobSeriesStruct.startCadence + 0.1 ;
  try_to_catch_error_condition( 'a=blobSeriesClass(blobSeriesStruct);', ...
      'startCadenceNotIntegerValued', blobSeriesStruct, 'blobSeriesStruct' ) ;
                               
  blobSeriesStruct = blobSeriesStructGood ;
  blobSeriesStruct.endCadence = blobSeriesStruct.endCadence + 0.1 ;
  try_to_catch_error_condition( 'a=blobSeriesClass(blobSeriesStruct);', ...
      'endCadenceNotIntegerValued', blobSeriesStruct, 'blobSeriesStruct' ) ;
                               
  blobSeriesStruct = blobSeriesStructGood ;
  blobSeriesStruct.startCadence = blobSeriesStruct.endCadence + 1 ;
  try_to_catch_error_condition( 'a=blobSeriesClass(blobSeriesStruct);', ...
      'endCadenceLessThanStartCadence', blobSeriesStruct, 'blobSeriesStruct' ) ;
                               
% test that gapIndicators is logical and blobIndices is integer-valued, numeric, and real

  blobSeriesStruct = blobSeriesStructGood ;
  blobSeriesStruct.gapIndicators = int32(blobSeriesStruct.gapIndicators) ;
  try_to_catch_error_condition( 'a=blobSeriesClass(blobSeriesStruct);', ...
      'gapIndicatorsIllogical', blobSeriesStruct, 'blobSeriesStruct' ) ;

  blobSeriesStruct = blobSeriesStructGood ;
  blobSeriesStruct.blobIndices = double(blobSeriesStruct.blobIndices)+0.1 ;
  try_to_catch_error_condition( 'a=blobSeriesClass(blobSeriesStruct);', ...
      'blobIndicesNotIntegerValued', blobSeriesStruct, 'blobSeriesStruct' ) ;

  blobSeriesStruct = blobSeriesStructGood ;
  blobSeriesStruct.blobIndices = char(blobSeriesStruct.blobIndices) ;
  try_to_catch_error_condition( 'a=blobSeriesClass(blobSeriesStruct);', ...
      'blobIndicesNotNumeric', blobSeriesStruct, 'blobSeriesStruct' ) ;
  
  blobSeriesStruct = blobSeriesStructGood ;
  blobSeriesStruct.blobIndices = double(blobSeriesStruct.blobIndices)+0.1i ;
  try_to_catch_error_condition( 'a=blobSeriesClass(blobSeriesStruct);', ...
      'blobIndicesNotReal', blobSeriesStruct, 'blobSeriesStruct' ) ;

% test the values in blobIndices -- for all ungapped cadences they should be between 0 and
% length(blobSeriesStruct.blobFilenames)-1

  goodCadences = find(~blobSeriesStruct.gapIndicators) ;
  blobSeriesStruct = blobSeriesStructGood ;
  blobSeriesStruct.blobIndices(goodCadences(1)) = int32(-1) ;
  try_to_catch_error_condition( 'a=blobSeriesClass(blobSeriesStruct);', ...
      'cadenceNumbersInvalid', blobSeriesStruct, 'blobSeriesStruct' ) ;
  blobSeriesStruct.blobIndices(goodCadences(1)) = int32(length(blobSeriesStruct.blobFilenames)) ;
  try_to_catch_error_condition( 'a=blobSeriesClass(blobSeriesStruct);', ...
      'cadenceNumbersInvalid', blobSeriesStruct, 'blobSeriesStruct' ) ;
 
% perform cleanup of the files

  cleanup_test_blobSeries_structure( blobSeriesStruct ) ;
  
% and that's it!

%
%
%

