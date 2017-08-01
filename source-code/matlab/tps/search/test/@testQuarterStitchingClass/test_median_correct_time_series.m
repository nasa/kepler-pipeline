function self = test_median_correct_time_series( self )
%
% test_median_correct_time_series -- unit test for quarterStitchingClass method
% median_correct_time_series
%
% This unit test exercises the following functionality of the method:
%
% ==> The flux time series are median-corrected, ie, median of the resulting time series
%     is zero
% ==> The correction is applied quarter by quarter.
%
% This test is performed in the mlunit context.  For standalone operation, use the
% following syntax:
%
%      run(text_test_runner, testQuarterStitchingClass('test_median_correct_time_series'));
%
% Version date:  2010-October-21.
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
%    2010-October-21, PT:
%        do not test median normalization, since median normalization is no longer applied
%        in median_correct_time_series.
%    2010-October-12, PT:
%        add test of medianValues.
%
%=========================================================================================

  disp(' ... testing median-correction method ... ') ;

% set the test data path and retrieve the standard input struct 

  tpsDataFile = 'tps-multi-quarter-struct' ;
  tpsDataStructName = 'tpsInputs' ;
  tps_testing_initialization ;
  load( fullfile( testDataPath, 'quarterStitchingClass-struct' ) ) ;
  
% validate the input and update the quarterStitchingStruct with anything
% new that it might need
  
  nTargets = length(quarterStitchingStruct.timeSeriesStruct) ;
  tpsInputs.tpsTargets = tpsInputs.tpsTargets(1) ;
  tpsInputs.tpsTargets(1:nTargets) = tpsInputs.tpsTargets;
  tpsInputs = validate_tps_input_structure( tpsInputs ) ;
  quarterStitchingStruct.gapFillParametersStruct = tpsInputs.gapFillParameters ;
  quarterStitchingStruct.harmonicsIdentificationParametersStruct = tpsInputs.harmonicsIdentificationParameters ;
  quarterStitchingStruct.randStreams = tpsInputs.randStreams ;  
  
% instantiate two quarterStitchingClass object -- with and without median normalization
% enabled

  quarterStitchingObject  = quarterStitchingClass( quarterStitchingStruct ) ;
  quarterStitchingStruct.quarterStitchingParametersStruct.medianNormalizationFlag = false ;
  quarterStitchingObject2 = quarterStitchingClass( quarterStitchingStruct ) ;
  
% execute the median-correction method with the nominal options (median-normalization) and
% with median-normalization disabled

  quarterStitchingObject  = median_correct_time_series( quarterStitchingObject ) ;
  quarterStitchingObject2 = median_correct_time_series( quarterStitchingObject2 ) ;

% cast the objects back to structs

  quarterStitchingStructAfter  = struct( quarterStitchingObject ) ;
  quarterStitchingStructAfter2 = struct( quarterStitchingObject2 ) ;
  
% since median normalization is no longer applied in this method, the two structs should
% be identical

  assert_equals( quarterStitchingStructAfter.timeSeriesStruct, ...
      quarterStitchingStructAfter2.timeSeriesStruct, ...
      'Time series structs with and without median normalization do not match!' ) ;
  
% loop over time series

  for iTarget = 1:length( quarterStitchingStructAfter.timeSeriesStruct )
      
      target        = quarterStitchingStruct.timeSeriesStruct(iTarget) ;
      targetAfter   = quarterStitchingStructAfter.timeSeriesStruct(iTarget) ;
      gapIndicators = target.gapIndicators ;
      
%     first test:  median of the non-gapped cadences should be zero

      mlunit_assert( abs( median( target.values(~gapIndicators) ) ) > 1e-6 && ...
          abs( median( targetAfter.values(~gapIndicators) ) ) < 1e-6,        ...
          ['Overall median for target ', num2str(iTarget),' not as expected!'] ) ;
      
%     for the remaining tests, we need to loop over quarters

      for iQuarter = 1:length( targetAfter.dataSegments )
          
          dataStart = targetAfter.dataSegments{iQuarter}(1) ;
          dataEnd   = targetAfter.dataSegments{iQuarter}(2) ;
          dataRegion = dataStart:dataEnd ;
          oldMedian  = median( target.values(dataRegion) ) ;
          newMedian  = median( targetAfter.values(dataRegion) ) ;
          oldRMS     = std(    target.values(dataRegion) ) ;
          newRMS     = std(    targetAfter.values(dataRegion) ) ;
          
%         the segment median should be within a small error of zero
          
          mlunit_assert( abs( oldMedian ) > 1e-6 && ...
              abs( newMedian ) < 1e-6 ,             ...
              ['Median for target ', num2str(iTarget), ...
              ' segment ', num2str(iQuarter), ' not as expected!'] ) ;
          
%         the segment RMS should be equal to the old segment RMS but scaled by the old
%         median

          mlunit_assert( abs( oldRMS - oldMedian * newRMS ) < 1e-6 * oldRMS, ...
              ['Normalized RMS for target ', num2str(iTarget), ...
              ' segment ', num2str(iQuarter), ' not as expected!'] ) ;
          
%         the segment medianValues entry should be equal to the median of the original
%         segment values to within a small error

          mlunit_assert( abs( oldMedian - targetAfter.medianValues( iQuarter ) ) < 1e-6, ...
              ['medianValues for target ', num2str(iTarget), ...
              ' segment ', num2str(iQuarter), ' not as expected!'] ) ;
          
      end % loop over quarters
      
  end % loop over targets
  
% test of correct handling of negative flux:  take one quarter out of one target, invert
% its values, and make sure that the correct action is taken

  quarterStart = quarterStitchingStructAfter.timeSeriesStruct(1).dataSegments{1}(1) ;
  quarterEnd   = quarterStitchingStructAfter.timeSeriesStruct(1).dataSegments{1}(2) ;
  
  quarterStitchingStruct.timeSeriesStruct(1).values(quarterStart:quarterEnd) = ...
      -1 * quarterStitchingStruct.timeSeriesStruct(1).values(quarterStart:quarterEnd) ;
  quarterStitchingStruct.timeSeriesStruct = quarterStitchingStruct.timeSeriesStruct(1) ;
  
  quarterStitchingObject3 = quarterStitchingClass( quarterStitchingStruct ) ;
  quarterStitchingObject3 = median_correct_time_series( quarterStitchingObject3 ) ;
  
  timeSeriesStruct3 = get_time_series_struct( quarterStitchingObject3 ) ;
  timeSeriesStruct  = get_time_series_struct( quarterStitchingObject ) ;
  median3           = timeSeriesStruct3.medianValues(1) ;
  
  mlunit_assert( all( abs(timeSeriesStruct3.values - timeSeriesStruct(1).values) / median3 ...
      < 1e-9 ), ...
      ' Time series with negative median values fails median correction test!' ) ;
  assert_equals( timeSeriesStruct3.medianValues(1), ...
      -1 * timeSeriesStruct(1).medianValues(1), ...
      'Stored median value of negative time series incorrect!' ) ;

  disp('') ;
  
return

% and that's it!

%
%
%

      