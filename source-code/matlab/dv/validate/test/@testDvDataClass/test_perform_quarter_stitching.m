function self = test_perform_quarter_stitching( self )
%
% test_perform_quarter_stitching -- unit test of dvDataClass method
% perform_quarter_stitching
%
% This unit test exercises the following functionality of the method:
%
% ==> Basic functionality:  the method produces an output time series struct which is
%     correct, gaps are filled, etc.
% ==> The segmentInformationStruct is correctly filled
% ==> The scale of the time series varies depending on whether the median normalization
%     flag is true or false
% ==> The method works correctly whether the information on fills is carried in a
%     "fillIndices" field or a "filledIndices" field
% ==> If keplerId and timeSeriesType are included in the original time series, they are
%     correctly copied to the segmentInformationStruct.
%
% This unit test is intended to execute in the mlunit context.  For standalone execution,
% use the following syntax:
%
% This test is intended to be executed in the mlunit context.  For standalone execution
% use the following syntax:
%
%      run(text_test_runner, testDvDataClass('test_perform_quarter_stitching'));
%
% Version date:  2010-October-22.
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

  disp('... testing quarter-stitching method ... ')
  
% get the test data and construct a dvDataClass object

  dvDataFilename = 'test-dv-quarter-stitching-data' ;
  testDvDataClass_fitter_initialization ;

% expand the timeSeriesStructIn to a struct array, in order to test that multiple time
% series can be processed by a single call

  timeSeriesStructIn = repmat( timeSeriesStructIn, 3, 1 ) ;

% execute the method on the time series struct

  [timeSeriesStructOut, segmentInformationStruct] = perform_quarter_stitching( ...
      dvDataObject, timeSeriesStructIn, true ) ;
  
% verify that timeSeriesStructOut(2:3) are identical to timeSeriesStruct(1); do a similar
% verification on segmentInformationStruct; this will make it simpler to go through and
% check the values of each struct

  mlunit_assert( isequal( timeSeriesStructOut(2), timeSeriesStructOut(1) ) && ...
      isequal( timeSeriesStructOut(3), timeSeriesStructOut(1) ) && ...
      isequal( segmentInformationStruct(2), segmentInformationStruct(1) ) && ...
      isequal( segmentInformationStruct(3), segmentInformationStruct(1) ), ...
      'timeSeriesStruct and/or segmentInformationStruct 2nd and 3rd entries not identical to 1st!' ) ;

  timeSeriesStructOut      = timeSeriesStructOut(1) ;
  segmentInformationStruct = segmentInformationStruct(1) ;
  
% fields check

  assert_equals( sort( fieldnames( timeSeriesStructOut ) ), { 'filledIndices' ; ...
      'gapIndicators'; 'uncertainties'; 'values' }, ...
      'timeSeriesStructOut fields not as expected!' ) ;
  assert_equals( sort( fieldnames( segmentInformationStruct ) ), { 'keplerId'; ...
      'segment'; 'timeSeriesType' }, ...
      'segmentInformationStruct fields not as expected!' ) ;

% check that the gaps have been converted to fills

  mlunit_assert( all( ~timeSeriesStructOut.gapIndicators ), ...
      'timeSeriesStructOut gap indicators not all false!' ) ;
  oldGapsAndFills = sort( [timeSeriesStructOut.filledIndices ; ...
      find( timeSeriesStructOut.gapIndicators ) ] ) ;
  assert_equals( timeSeriesStructOut.filledIndices, oldGapsAndFills, ...
      'timeSeriesStrutOut fill indices not as expected!' ) ;
  
% check values and uncertainties -- in order to not have the test fail whenever we make a
% change to the algorithm this will be a somewhat loose test

  values = timeSeriesStructOut.values ;
  mlunit_assert( abs( median( values ) ) < 1e-6 && ...
      abs( mean( values ) ) < 1e-3 && ...
      mad( values, 1 ) < 3e-3 && ...
      std( values ) < 3e-3, ...
      'timeSeriesStructOut values not as expected!' ) ;
  
  uncertainties = timeSeriesStructOut.uncertainties( ~timeSeriesStructIn(1).gapIndicators ) ;
  mlunit_assert( median( uncertainties ) < 6e-4 && median(uncertainties) > 4e-4 && ...
      mean( uncertainties ) < 6e-4 && mean(uncertainties) > 4e-4 && ...
      mad( uncertainties, 1 ) < 1e-4 && std( uncertainties ) < 1e-4, ...
      'timeSeriesStructOut uncertainties not as expected!' ) ;
  mlunit_assert( all( -1 == ...
      timeSeriesStructOut.uncertainties( timeSeriesStructIn(1).gapIndicators ) ) && ...
      all( uncertainties > 0 ), ...
      'timeSeriesStructOut uncertainties not == -1 where expected!' ) ;
  
% check out the values in the segment information struct

  assert_equals( segmentInformationStruct.keplerId, -1, ...
      'keplerId field in segmentInformationStruct not as expected!' ) ;
  assert_equals( segmentInformationStruct.timeSeriesType, 'unknown', ...
      'timeSeriesType field in segmentInformationStruct not as expected!' ) ;
  assert_equals( [segmentInformationStruct.segment.startIndex], ...
      [1 1861 6300 10810], ...
      'segment startIndex values not as expected!' ) ;
  assert_equals( [segmentInformationStruct.segment.endIndex], ...
      [1639 6214 10669 11830], ...
      'segment endIndex values not as expected!' ) ;
  mlunit_assert( all( abs( [segmentInformationStruct.segment.medianValue] - ...
      [11340526 12614162.5 11458562 12286702] ) < 0.1 ) , ...
      'segment medianValue values not as expected!' ) ;
  
% now test with the median normalization turned off

  [timeSeriesStructOut2, segmentInformationStruct2] = perform_quarter_stitching( ...
      dvDataObject, timeSeriesStructIn, false ) ;
  
  mlunit_assert( isequal( timeSeriesStructOut2(2), timeSeriesStructOut2(1) ) && ...
      isequal( timeSeriesStructOut2(3), timeSeriesStructOut2(1) ) && ...
      isequal( segmentInformationStruct2(2), segmentInformationStruct2(1) ) && ...
      isequal( segmentInformationStruct2(3), segmentInformationStruct2(1) ), ...
      'timeSeriesStruct and/or segmentInformationStruct 2nd and 3rd entries not identical to 1st!' ) ;

  timeSeriesStructOut2      = timeSeriesStructOut2(1) ;
  segmentInformationStruct2 = segmentInformationStruct2(1) ;
  
% the segmentInformationStruct should be identical to the old one

  assert_equals( segmentInformationStruct, segmentInformationStruct2, ...
      'segmentInformationStruct not identical with and without median normalization!' ) ;
  
% the gap indicators and fill indices should match the normalization-on case

  assert_equals( timeSeriesStructOut2.filledIndices, timeSeriesStructOut.filledIndices, ...
      'filled indices not identical with and without median normalization!' ) ;
  assert_equals( timeSeriesStructOut2.gapIndicators, timeSeriesStructOut.gapIndicators, ...
      'filled indices not identical with and without median normalization!' ) ;
  
% check the values and the uncertainties

  values = timeSeriesStructOut2.values ;
  mlunit_assert( abs( median( values ) ) < 1e-6 && ...
      abs( mean( values ) ) < 5000 && ...
      mad( values, 1 ) < 30000 && ...
      std( values ) < 30000, ...
      'timeSeriesStructOut values not as expected!' ) ;
  
  uncertainties = timeSeriesStructOut2.uncertainties( ~timeSeriesStructIn(1).gapIndicators ) ;
  mlunit_assert( median( uncertainties ) < 6000 && median(uncertainties) > 4000 && ...
      mean( uncertainties ) < 6000 && mean(uncertainties) > 4000 && ...
      mad( uncertainties, 1 ) < 500 && std( uncertainties ) < 500, ...
      'timeSeriesStructOut uncertainties not as expected!' ) ;
  mlunit_assert( all( -1 == ...
      timeSeriesStructOut.uncertainties( timeSeriesStructIn(1).gapIndicators ) ) && ...
      all( uncertainties > 0 ), ...
      'timeSeriesStructOut uncertainties not == -1 where expected!' ) ;
  
% replace the filledIndices with fillIndices in the incoming time series, and add a
% keplerId and timeSeriesType field to the ingoing time series struct, and see that the
% right things are done

  timeSeriesStructIn = timeSeriesStructIn(1) ;
  timeSeriesStructIn.fillIndices = timeSeriesStructIn.filledIndices ;
  timeSeriesStructIn = rmfield( timeSeriesStructIn, 'filledIndices' ) ;
  timeSeriesStructIn.keplerId = 100 ;
  timeSeriesStructIn.timeSeriesType = 'test' ;
  
  [timeSeriesStructOut3, segmentInformationStruct3] = perform_quarter_stitching( ...
      dvDataObject, timeSeriesStructIn, false ) ;
  
  assert_equals( rmfield( timeSeriesStructOut3, 'fillIndices' ), ...
      rmfield( timeSeriesStructOut2, 'filledIndices' ) , ...
      'fillIndices - filledIndices substitution has other side-effects!' ) ;
  assert_equals( timeSeriesStructOut3.fillIndices, timeSeriesStructOut2.filledIndices, ...
      'translation between fillIndices and filledIndices not as expected!' ) ;
  
  assert_equals( segmentInformationStruct3.keplerId, ...
      timeSeriesStructIn.keplerId, ...
      'kepler ID not correctly handled!' ) ;
  assert_equals( segmentInformationStruct3.timeSeriesType, ...
      timeSeriesStructIn.timeSeriesType, ...
      'timeSeriesType not correctly handled!' ) ;
  mlunit_assert( isequal( [segmentInformationStruct3.segment.startIndex], ...
      [segmentInformationStruct2.segment.startIndex] ) && ...
      isequal( [segmentInformationStruct3.segment.endIndex], ...
      [segmentInformationStruct2.segment.endIndex] ) && ...
      isequal( [segmentInformationStruct3.segment.medianValue], ...
      [segmentInformationStruct2.segment.medianValue] ) , ...
      'segmentInformationStruct not as expected for fillIndices and keplerId case!' ) ;
  
  disp('') ;
      
return

