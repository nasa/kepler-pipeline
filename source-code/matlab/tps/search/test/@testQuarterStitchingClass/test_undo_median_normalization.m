function self = test_undo_median_normalization( self )
%
% test_undo_median_normalization -- unit test for the quarterStitchingClass method
% undo_median_normalization
%
% This unit test exercises the following functionality of the method:
%
% ==> When medianNormalizationFlag == true, the method produces an object which is
%     identical to the original object
% ==> When medianNormalizationFlag == false, the method rescales the values in each
%     segment by the original median value of that segment.
%
% This test is performed in the mlunit context.  For standalone operation, use the
% following syntax:
%
%      run(text_test_runner, testQuarterStitchingClass('test_undo_median_normalization'));
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

  disp(' ... testing undo-median-normalization method ... ') ;

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
  
% perform median correction on both, which populates the median values fields

  quarterStitchingObject  = median_correct_time_series( quarterStitchingObject ) ;
  quarterStitchingObject2 = median_correct_time_series( quarterStitchingObject2 ) ;
  
% apply the undo-normalization method to each object

  quarterStitchingObjectAfter  = undo_median_normalization( quarterStitchingObject ) ;
  quarterStitchingObject2After = undo_median_normalization( quarterStitchingObject2 ) ;
  
% the object with median-normalization enabled should be identical to what it was before
% the call
  
  assert_equals( quarterStitchingObject, quarterStitchingObjectAfter, ...
      'median-normalized object altered by undo-normalization method!' ) ;
  
% for the other object, test values

  timeSeriesStructBefore = get_time_series_struct( quarterStitchingObject2 ) ;
  timeSeriesStructAfter  = get_time_series_struct( quarterStitchingObject2After ) ;
  
% except for the values and uncertainties, the two structs should be identical

  assert_equals( rmfield( timeSeriesStructBefore, {'values', 'uncertainties'} ), ...
      rmfield( timeSeriesStructAfter, {'values', 'uncertainties'} ), ...
      'median-rescaled object time series struct not as expected!' ) ;
  
% loop over targets and segments

  for iTarget = 1:length( timeSeriesStructBefore )
      
      thisTimeSeriesBefore = timeSeriesStructBefore(iTarget) ;
      thisTimeSeriesAfter  = timeSeriesStructAfter(iTarget) ;
      
      for iSegment = 1:length( thisTimeSeriesBefore.medianValues )
          
          segStart = thisTimeSeriesBefore.dataSegments{iSegment}(1) ;
          segEnd   = thisTimeSeriesBefore.dataSegments{iSegment}(2) ;
          medValue = thisTimeSeriesBefore.medianValues(iSegment) ;
          
%         check that the values and uncertainties are correctly scaled

          assert_equals( thisTimeSeriesBefore.values(segStart:segEnd) * medValue, ...
              thisTimeSeriesAfter.values(segStart:segEnd), ...
              ['median-rescaled object values not as expected on target ', ...
              num2str(iTarget), ' segment ', num2str(iSegment) ] ) ;
          assert_equals( thisTimeSeriesBefore.uncertainties(segStart:segEnd) * medValue, ...
              thisTimeSeriesAfter.uncertainties(segStart:segEnd), ...
              ['median-rescaled object uncertainties not as expected on target ', ...
              num2str(iTarget), ' segment ', num2str(iSegment) ] ) ;
          
      end
      
  end
  
% exercise the negative-median-value use-case

  timeSeriesStruct2 = get_time_series_struct( quarterStitchingObject2After ) ;
  quarterStart = timeSeriesStruct2(1).dataSegments{1}(1) ;
  quarterEnd   = timeSeriesStruct2(1).dataSegments{1}(2) ;
  
  quarterStitchingStruct.timeSeriesStruct(1).values(quarterStart:quarterEnd) = ...
      -1 * quarterStitchingStruct.timeSeriesStruct(1).values(quarterStart:quarterEnd) ;
  quarterStitchingStruct.timeSeriesStruct = quarterStitchingStruct.timeSeriesStruct(1) ;
  quarterStitchingStruct.quarterStitchingParametersStruct.medianNormalizationFlag = false ;
  
  quarterStitchingObject3 = quarterStitchingClass( quarterStitchingStruct ) ;
  quarterStitchingObject3 = median_correct_time_series( quarterStitchingObject3 ) ;
  quarterStitchingObject3 = undo_median_normalization( quarterStitchingObject3 ) ;
  timeSeriesStruct3 = get_time_series_struct( quarterStitchingObject3 ) ;
  timeSeriesStruct2 = get_time_series_struct( quarterStitchingObject2After ) ;
  timeSeriesStruct2 = timeSeriesStruct2(1) ;
  
  assert_equals( timeSeriesStruct2.values(quarterStart:quarterEnd), ...
      -timeSeriesStruct3.values(quarterStart:quarterEnd), ...
      'Median normalization does not undo correctly on negative flux case!' );
  
  assert_equals( timeSeriesStruct2.values(quarterEnd+1:end), ...
      timeSeriesStruct3.values(quarterEnd+1:end), ...
      'Median normalization does not undo correctly on positive flux case!' ) ;

  
  disp('') ;        
  
% 
end

