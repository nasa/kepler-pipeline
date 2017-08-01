function self = test_fpg_pipeline_validation(self)
%
% test_fpg_pipeline_validation -- test that the additional FPG data validation required
% for pipeline operation is in good working order.  This unit test exercises the
% validation tools for the pipeline form of fpgDataStruct and its substructures.  The
% valdition performed in this process is not a complete validation; all that is validated
% is the level of structural correctness required to convert the pipeline-format inputs
% into interactive-format inputs, after which the interactive-format validator performs a
% more intense validation of the data.
%
% This test is intended to run in the context of mlunit; to execute it on its own, use a
% command of the form:
%
%     run(text_test_runner,fpgTestClass('test_fpg_pipeline_validation')) ;
%
% Version date:  2008-December-14.
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
%     2008-December-14, PT:
%         test for problems with the cadenceNumbers, or for a cadence mid-time which does
%         not match the mid-time in any motion polynomial
%     2008-September-14, PT:
%         test for presence of maxBadDataCutoff field in fpgConfigurationStruct.
%     2008-September-07, PT:
%         update name of fpgTestDataStruct.  Manually test for validation of reference
%         cadence #.
%     2008-September-05, PT:
%         updated to match changes in revised input structure.  Eliminate motion blobs
%         validation since it is now done by the blobSeriesClass constructor and not FPG.
%     2008-August-13, PT:
%         changes in support of revised input structure.
%
%=========================================================================================

% set the value of the quickAndDirtyCheckFlag and the paths etc needed for testing

  quickAndDirtyCheckFlag = false ;
  setup_fpg_paths_and_files ;

% get a good fpgDataStruct, convert to pipeline format, and use it to instantiate an
% fpgDataClass
  
  load(fullfile(testFileDir,'fpgTestDataStruct')) ;
  fpgDataStructPipeline = convert_fpg_inputs_to_pipeline( fpgDataStruct ) ;
  fpgDataObject = fpgDataClass(fpgDataStructPipeline) ;
  
%=========================================================================================
%
% Top-level validation
%
%=========================================================================================

  fieldsAndBounds = cell(6,4) ;
  fieldsAndBounds(1,:) = { 'timestampSeries' ; [] ; [] ; [] } ;
  fieldsAndBounds(2,:) = { 'fcConstants' ; [] ; [] ; [] } ;
  fieldsAndBounds(3,:) = { 'fpgModuleParameters' ; [] ; [] ; [] } ;
  fieldsAndBounds(4,:) = { 'raDec2PixModel' ; [] ; [] ; [] } ;
  fieldsAndBounds(5,:) = { 'motionBlobsStruct' ; [] ; [] ; [] } ;
  fieldsAndBounds(6,:) = { 'geometryBlobFileName' ; [] ; [] ; [] } ;

  remove_field_and_test_for_failure(fpgDataStructPipeline, 'fpgDataStructPipeline', ...
      fpgDataStructPipeline, 'fpgDataStructPipeline', 'fpgDataClass', fieldsAndBounds, ...
      quickAndDirtyCheckFlag);

  clear fieldsAndBounds
  
% test the string-validation on geometry blob names

  gBN = fpgDataStructPipeline.geometryBlobFileName ;
  fpgDataStructPipeline.geometryBlobFileName = 7 ;
  try_to_catch_error_condition('a=fpgDataClass(fpgDataStructPipeline)',...
      'geometryBlobFileNameInvalid', fpgDataStructPipeline, 'fpgDataStructPipeline') ;
  
  fpgDataStructPipeline.geometryBlobFileName = ['Duran' ; 'Duran'] ;
  try_to_catch_error_condition('a=fpgDataClass(fpgDataStructPipeline)',...
      'geometryBlobFileNameInvalid', fpgDataStructPipeline, 'fpgDataStructPipeline') ;
  
  fpgDataStructPipeline.geometryBlobFileName = gBN ;

%=========================================================================================
%
% timestampSeries validation
%
%=========================================================================================

  fieldsAndBounds = cell(5,4) ;
  fieldsAndBounds(1,:) = { 'startTimestamps' ; [] ; [] ; [] } ;
  fieldsAndBounds(2,:) = { 'midTimestamps' ; [] ; [] ; [] } ;
  fieldsAndBounds(3,:) = { 'endTimestamps' ; [] ; [] ; [] } ;
  fieldsAndBounds(4,:) = { 'gapIndicators' ; [] ; [] ; [] } ;
  fieldsAndBounds(5,:) = { 'cadenceNumbers' ; [] ; [] ; [] } ;

  remove_field_and_test_for_failure(fpgDataStructPipeline.timestampSeries, ...
      'fpgDataStructPipeline.timestampSeries', fpgDataStructPipeline, ...
      'fpgDataStructPipeline', 'fpgDataClass', fieldsAndBounds, ...
      quickAndDirtyCheckFlag);
  clear fieldsAndBounds 

% additional tests -- midTimestamps and gapIndicators are vectors, they are the same
% length as one another, gapIndicators is logicals

  fpgDataStructPipelineGood = fpgDataStructPipeline ;
  
  midTimestamps = fpgDataStructPipelineGood.timestampSeries.midTimestamps ;
  fpgDataStructPipeline.timestampSeries.midTimestamps = [midTimestamps midTimestamps ; ...
                                                         midTimestamps midTimestamps ] ;
  try_to_catch_error_condition('a=fpgDataClass(fpgDataStructPipeline)',...
      'timestampSeriesDimensions', fpgDataStructPipeline, 'fpgDataStructPipeline') ;

  fpgDataStructPipeline = fpgDataStructPipelineGood ;
  gapIndicators = fpgDataStructPipelineGood.timestampSeries.gapIndicators ;
  fpgDataStructPipeline.timestampSeries.gapIndicators = [gapIndicators gapIndicators ; ...
                                                         gapIndicators gapIndicators ] ;
  try_to_catch_error_condition('a=fpgDataClass(fpgDataStructPipeline)',...
      'timestampSeriesDimensions', fpgDataStructPipeline, 'fpgDataStructPipeline') ;

  fpgDataStructPipeline = fpgDataStructPipelineGood ;
  gapIndicators = fpgDataStructPipelineGood.timestampSeries.gapIndicators ;
  gapIndicatorLength = length(gapIndicators) ;
  gapIndicators(gapIndicatorLength+1) = gapIndicators(gapIndicatorLength) ;
  fpgDataStructPipeline.timestampSeries.gapIndicators = gapIndicators ; 
  try_to_catch_error_condition('a=fpgDataClass(fpgDataStructPipeline)',...
      'timestampSeriesDimensions', fpgDataStructPipeline, 'fpgDataStructPipeline') ;
  
  fpgDataStructPipeline = fpgDataStructPipelineGood ;
  gapIndicators = double(fpgDataStructPipelineGood.timestampSeries.gapIndicators) ;
  fpgDataStructPipeline.timestampSeries.gapIndicators = gapIndicators ; 
  try_to_catch_error_condition('a=fpgDataClass(fpgDataStructPipeline)',...
      'gapIndicatorsIllogical', fpgDataStructPipeline, 'fpgDataStructPipeline') ;
  
% cadenceNumbers is not a vector, not monotonic-increasing, or not unique

  cadenceNumbers = fpgDataStructPipeline.timestampSeries.cadenceNumbers ;
  fpgDataStructPipeline = fpgDataStructPipelineGood ;
  fpgDataStructPipeline.timestampSeries.cadenceNumbers = ...
      [cadenceNumbers cadenceNumbers ; cadenceNumbers cadenceNumbers] ;
  try_to_catch_error_condition('a=fpgDataClass(fpgDataStructPipeline)',...
      'cadenceNumbersIllFormed', fpgDataStructPipeline, 'fpgDataStructPipeline') ;
  
  fpgDataStructPipeline.timestampSeries.cadenceNumbers = ...
      sort(cadenceNumbers, 'descend') ;
  try_to_catch_error_condition('a=fpgDataClass(fpgDataStructPipeline)',...
      'cadenceNumbersIllFormed', fpgDataStructPipeline, 'fpgDataStructPipeline') ;

  fpgDataStructPipeline.timestampSeries.cadenceNumbers = ...
      ones(size(cadenceNumbers)) ;
  try_to_catch_error_condition('a=fpgDataClass(fpgDataStructPipeline)',...
      'cadenceNumbersIllFormed', fpgDataStructPipeline, 'fpgDataStructPipeline') ;
  
%=========================================================================================
%
% fpgModuleParameters validation
%
%=========================================================================================

  nCadences = length(fpgDataStructPipeline.timestampSeries.midTimestamps) ;
  validReferenceCadences = [-1:nCadences-1] ;
  validRefCadenceString = ['[',num2str(validReferenceCadences),']'] ;
  fieldsAndBounds = cell(13,4) ;
  fieldsAndBounds(1,:) = { 'rowGridValues' ; [] ; [] ; [] } ;
  fieldsAndBounds(2,:) = { 'columnGridValues' ; [] ; [] ; [] } ;
  fieldsAndBounds(3,:) = { 'fitPlateScaleFlag' ; [] ; [] ; [] } ;
  fieldsAndBounds(4,:) = { 'tolX' ; [] ; [] ; [] } ;
  fieldsAndBounds(5,:) = { 'tolFun' ; [] ; [] ; [] } ;
  fieldsAndBounds(6,:) = { 'tolSigma' ; [] ; [] ; [] } ;
  fieldsAndBounds(7,:) = { 'doRobustFit' ; [] ; [] ; [] } ;
  fieldsAndBounds(8,:) = { 'reportGenerationEnabled' ; [] ; [] ; [] } ;
  fieldsAndBounds(9,:) = { 'pointingRefCadence' ; [] ; [] ; [] } ;
  fieldsAndBounds(10,:) = { 'usePointingModel' ; [] ; [] ; [] } ;
  fieldsAndBounds(11,:) = { 'fitPointingRefCadence' ; [] ; [] ; [] } ;
  fieldsAndBounds(12,:) = { 'referenceCadence' ; [] ; [] ; validRefCadenceString } ;
  fieldsAndBounds(13,:) = { 'maxBadDataCutoff' ; [] ; [] ; [] } ;

  fpgDataStructPipeline = fpgDataStructPipelineGood ;
  remove_field_and_test_for_failure(fpgDataStructPipeline.fpgModuleParameters, ...
      'fpgDataStructPipeline.fpgModuleParameters', fpgDataStructPipeline, ...
      'fpgDataStructPipeline', 'fpgDataClass', fieldsAndBounds, ...
      quickAndDirtyCheckFlag);
    
% make sure that usePointingModel is a logical scalar -- everything else will be handled
% by the main validator which is exercised by other unit tests

  fpgDataStructPipeline.fpgModuleParameters.usePointingModel = ...
      double(fpgDataStructPipeline.fpgModuleParameters.usePointingModel) ;
  try_to_catch_error_condition('a=fpgDataClass(fpgDataStructPipeline)',...
      'usePointingModelImproper', fpgDataStructPipeline, 'fpgDataStructPipeline') ;
  fpgDataStructPipeline = fpgDataStructPipelineGood ;
  fpgDataStructPipeline.fpgModuleParameters.usePointingModel = [true true] ;
  try_to_catch_error_condition('a=fpgDataClass(fpgDataStructPipeline)',...
      'usePointingModelImproper', fpgDataStructPipeline, 'fpgDataStructPipeline') ;
  fpgDataStructPipeline = fpgDataStructPipelineGood ;

% values validation for referenceCadence

  lowLevelStructName = 'fpgDataStructPipeline.fpgModuleParameters' ;
  assign_illegal_value_and_test_for_failure(...
      fpgDataStructPipeline.fpgModuleParameters, ...
      lowLevelStructName, fpgDataStructPipeline, 'fpgDataStructPipeline', ...
      'fpgDataClass', fieldsAndBounds(11,:), quickAndDirtyCheckFlag );
  
  fpgDataStructPipeline = fpgDataStructPipelineGood ;
  fpgDataStructPipeline.fpgModuleParameters.referenceCadence = -2 ;
  try_to_catch_error_condition('a=fpgDataClass(fpgDataStructPipeline)',...
      'rangeCheck', fpgDataStructPipeline, 'fpgDataStructPipeline') ;

  fpgDataStructPipeline = fpgDataStructPipelineGood ;
  fpgDataStructPipeline.fpgModuleParameters.referenceCadence = nCadences ;
  try_to_catch_error_condition('a=fpgDataClass(fpgDataStructPipeline)',...
      'rangeCheck', fpgDataStructPipeline, 'fpgDataStructPipeline') ;

  fpgDataStructPipeline = fpgDataStructPipelineGood ;
  
  clear fieldsAndBounds
      
%=========================================================================================
%
% gapped reference cadence
%
%=========================================================================================

  referenceCadence = fpgDataStructPipeline.fpgModuleParameters.referenceCadence+1 ;
  if (referenceCadence==0)
      referenceCadence = 1 ;
  end
  
  fpgDataStructPipeline.timestampSeries.gapIndicators(referenceCadence) = true ;
  try_to_catch_error_condition('a=fpgDataClass(fpgDataStructPipeline)',...
      'referenceCadenceIsGapped', fpgDataStructPipeline, 'fpgDataStructPipeline') ;

%=========================================================================================
%
% MJD mismatch
%
%=========================================================================================

% if there is a mismatch between MJDs in the motion polynomial blobs and MJDs in the
% timestampSeries midTimestamps, test that it is properly trapped

  fpgDataStructPipeline = fpgDataStructPipelineGood ;
  fpgDataStructPipeline.timestampSeries.midTimestamps(1) = ...
      fpgDataStructPipeline.timestampSeries.midTimestamps(1) + 0.005 ;
  try_to_catch_error_condition('a=fpgDataClass(fpgDataStructPipeline)',...
      'illFormedMotionPolynomial', fpgDataStructPipeline, 'fpgDataStructPipeline') ;
      
%=========================================================================================
%
% MJD == 0 values
%
%=========================================================================================

% generate a new pipeline structure in which the second cadence is gapped and has MJDs
% equal to zero

  for count = 1:84
      fpgDataStruct.motionPolynomials(count,2).mjdStartTime = 0 ;
      fpgDataStruct.motionPolynomials(count,2).mjdMidTime = 0 ;
      fpgDataStruct.motionPolynomials(count,2).mjdEndTime = 0 ;
      fpgDataStruct.motionPolynomials(count,2).rowPolyStatus = 0 ;
      fpgDataStruct.motionPolynomials(count,2).colPolyStatus = 0 ;
  end
  fpgDataStructPipelineGood2 = convert_fpg_inputs_to_pipeline( fpgDataStruct ) ;
  fpgDataStructPipelineGood2.timestampSeries.startTimestamps(2) = 0 ;
  fpgDataStructPipelineGood2.timestampSeries.midTimestamps(2) = 0 ;
  fpgDataStructPipelineGood2.timestampSeries.endTimestamps(2) = 0 ;
  fpgDataStructPipelineGood2.timestampSeries.gapIndicators(2) = true ;
  
% demonstrate that this can be successfully instantiated

  fpgDataObject = fpgDataClass(fpgDataStructPipelineGood2) ;
  
% detect the error if the 3 timestamps aren't all zero

  fpgDataStructPipeline = fpgDataStructPipelineGood2 ;
  fpgDataStructPipeline.timestampSeries.startTimestamps(2) = ...
      fpgDataStructPipelineGood.timestampSeries.startTimestamps(2) ;
  try_to_catch_error_condition('a=fpgDataClass(fpgDataStructPipeline)',...
      'zeroTimestampsInconsistent', fpgDataStructPipeline, 'fpgDataStructPipeline') ;

  fpgDataStructPipeline = fpgDataStructPipelineGood2 ;
  fpgDataStructPipeline.timestampSeries.midTimestamps(2) = ...
      fpgDataStructPipelineGood.timestampSeries.midTimestamps(2) ;
  try_to_catch_error_condition('a=fpgDataClass(fpgDataStructPipeline)',...
      'zeroTimestampsInconsistent', fpgDataStructPipeline, 'fpgDataStructPipeline') ;

  fpgDataStructPipeline = fpgDataStructPipelineGood2 ;
  fpgDataStructPipeline.timestampSeries.endTimestamps(2) = ...
      fpgDataStructPipelineGood.timestampSeries.endTimestamps(2) ;
  try_to_catch_error_condition('a=fpgDataClass(fpgDataStructPipeline)',...
      'zeroTimestampsInconsistent', fpgDataStructPipeline, 'fpgDataStructPipeline') ;
  
% detect the error if the zeroed timestamp isn't a gapped cadence

  fpgDataStructPipeline = fpgDataStructPipelineGood2 ;
  fpgDataStructPipeline.timestampSeries.gapIndicators(2) = false ;
  try_to_catch_error_condition('a=fpgDataClass(fpgDataStructPipeline)',...
      'gapIndicatorsInconsistent', fpgDataStructPipeline, 'fpgDataStructPipeline') ;


%=========================================================================================
%
% cleanup
%
%=========================================================================================

% clean up blob files

  cleanup_fpgDataStruct_blob_files( fpgDataStructPipelineGood ) ;
  cleanup_fpgDataStruct_blob_files( fpgDataStructPipelineGood2 ) ;
  
% and that's it!

%
%
%
                 