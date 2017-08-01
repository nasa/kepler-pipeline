function self = test_blobSeries_features( self )
%
% test_blobSeries_features -- unit test of blobSeriesClass features
%
% This is a unit test intended to be run in the context of mlunit.  It tests the following
% features of the blobSeriesClass:
%
% ==> class method get_cadence_count returns the correct value
% ==> class method get_gap_indicators returns the correct value
% ==> class method get_blob_indices returns the correct value
% ==> class method get_cadence_range returns the correct values
% ==> class method get_struct_for_cadence returns logical false for a gapped cadence
% ==> class method get_struct_for_cadence returns the correct structures when given a list
%     of cadence numbers
% ==> class method get_struct_for_cadence throws the correct errors when the following
%     happens:
%     ==> one of its arguments is < 1
%     ==> one of its arguments is > nCadences
%     ==> one of its arguments is not integer-valued.
%
% This test is intended to be run with an mlunit runner:
%
%      run(text_test_runner, blobSeriesTestClass('test_blobSeries_features'));
%
% or else as a master all-test run via blobSeries_run_all_tests_txt or
% blobSeries_run_all_tests_gui.
%
% Version date:  2008-October-22.
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
%     2008-October-22, PT:
%         add test of get_blob_indices.
%     2008-September-19, PT:
%         add test of get_cadence_range.
%
%=========================================================================================

% get a mockup blobSeries data structure and instantiate the blobSeriesClass object with
% it

  blobSeriesStruct = make_test_blobSeries_structure() ;
  blobSeriesObject = blobSeriesClass(blobSeriesStruct) ;
  
% determine that the # of cadences is returned properly

  nCadences1 = length(blobSeriesStruct.blobIndices) ;
  nGoodCadences1 = length(find(~blobSeriesStruct.gapIndicators)) ;
  [nCadences2, nGoodCadences2] = get_cadence_count(blobSeriesObject) ;
  
  assert_equals( nCadences1, nCadences2, 'get_cadence_count method failed!' ) ;
  assert_equals( nGoodCadences1, nGoodCadences2, 'get_cadence_count method failed!' ) ;
  
% determine that the gap indicators are returned properly

  gapIndicators = get_gap_indicators( blobSeriesObject ) ;
  assert_equals( gapIndicators, blobSeriesStruct.gapIndicators, ...
      'get_gap_indicators method failed!') ;
  
% determine that the blob indices are returned properly

  blobIndices = get_blob_indices( blobSeriesObject ) ;
  assert_equals( blobIndices, blobSeriesStruct.blobIndices+1, ...
      'get_blob_indices method failed!' ) ;
  
% determine that the start and end cadences are properly returned

  [startCadence,endCadence] = get_cadence_range( blobSeriesObject ) ;
  assert_equals( startCadence, blobSeriesStruct.startCadence, ...
      'get_cadence_range returned incorrect startCadence value!' ) ;
  
  assert_equals( endCadence, blobSeriesStruct.endCadence, ...
      'get_cadence_range returned incorrect endCadence value!' ) ;
    
% verify that the correct structures are returned for a list of cadences, and that logical
% false is returned for the case of a gapped cadence

  blobPointerValues = unique(blobSeriesStruct.blobIndices) + 1 ;
  cadenceVector = zeros(1,length(blobPointerValues)+1) ;
  for iCadence = 1:length(blobPointerValues)
      cadenceVector(iCadence) = find(blobSeriesStruct.blobIndices == ...
          blobPointerValues(iCadence)-1,1) ;
  end
  cadenceVector(end) = find(blobSeriesStruct.gapIndicators,1) ;
  
  returnStructs = get_struct_for_cadence(blobSeriesObject,cadenceVector) ;
  
% check that in each case we get back the structure we expect to get back  
  
  for iCadence = 1:length(blobPointerValues)
      
      expectedStruct = single_blob_to_struct( blobSeriesStruct.blobFilenames{ ...
          1+blobSeriesStruct.blobIndices(cadenceVector(iCadence))        ...
          } ) ;
      assert_equals(expectedStruct,returnStructs(iCadence).struct, ...
          'get_struct_for_cadence method failed!') ;
      
  end
  
% check that the last entry in returnStructs is logical false

  assert_equals( returnStructs(end).struct, false, 'get_struct_for_cadence method failed!' ) ;
  
% check that get_struct_for_cadence method exception handling is working correctly

% first case: cadence # less than 1

  testString = 'v = get_struct_for_cadence(blobSeriesObject,[1 0]);' ;
  try_to_catch_error_condition( testString, 'cadencesArgumentRange', ...
      blobSeriesObject, 'blobSeriesObject' ) ;
  
% second case:  cadence # is greater than nCadences

  testString = ['v = get_struct_for_cadence(blobSeriesObject,[1 ',...
      num2str(nCadences1+1), ']);'] ;
  try_to_catch_error_condition( testString, 'cadencesArgumentRange', ...
      blobSeriesObject, 'blobSeriesObject' ) ;
      
% third case:  non-integer cadence #

  testString = 'v = get_struct_for_cadence(blobSeriesObject,[1 1.5]);' ;
  try_to_catch_error_condition( testString, 'cadencesArgumentNotIntValued', ...
      blobSeriesObject, 'blobSeriesObject' ) ;

% fourth case:  not a vector

  testString = 'v = get_struct_for_cadence(blobSeriesObject,[1 2 ; 3 4]);' ;
  try_to_catch_error_condition( testString, 'cadencesArgumentNotVector', ...
      blobSeriesObject, 'blobSeriesObject' ) ;

% clean up the blobSeriesStruct's temporary blobs

  cleanup_test_blobSeries_structure( blobSeriesStruct ) ;

% and that's it!

%
%
%
