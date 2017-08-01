function self = test_fpg_prf_features( self )
%
% test_fpg_prf_features -- test the FPG features which have been developed in support of
% operation within the PRF context.  The features in question are:
%
% 1.  Optional use of a user-supplied pointing rather than the pointing from the built-in
%     pointing model.
% 2.  Optional capability to fit the pointing on the reference cadence.
% 3.  Use of an alternate input data structure due to differences between the pipeline
%     environment and the interactive environment.
%
% This test is intended to run in the context of mlunit; to execute it on its own, use a
% command of the form:
%
%     run(text_test_runner,fpgTestClass('test_fpg_prf_features')) ;
%
% Version date:  2008-December-12.
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
%     2008-December-12, PT:
%         delete obsolete ephemeris file cleanup.
%     2008-October-30, PT:
%         update fakedata generation to match expected performance of PA.
%     2008-September-19, PT:
%         changes in support of one- and zero-based coordinate systems.
%     2008-September-14, PT:
%         test that permuted motionBlobsStruct and motionBlobsStruct with < 84 structs are
%         properly handled.
%     2008-September-07, PT:
%         add cleanup of blob files generated when the interactive-mode data structure is
%         converted to the pipeline-mode structure.  Update file name of
%         fpgTestDataStruct.
%
%=========================================================================================

% first things first:  figure out where we are running from (the FPG development laptop or
% a SOC workstation), and set the location of the test files accordingly:

  setup_fpg_paths_and_files ;

% load the fpgDataStruct and replace its raDec2PixModel with the correct one from above

  load(fullfile(testFileDir,'fpgTestDataStruct')) ;
  fpgDataStruct.raDec2PixModel = rd2pm ;
  
% generate an raDec2PixClass object with appropriate misalignments

  raDec2PixObject0 = make_raDec2PixClass_fakedata_object( 3, 3, 0.16, -1e-4, ...
    rd2pm ) ;

% prepare row/column information for the motion polynomial fit

  rowGrid = linspace(25,1040,15) ;
  colGrid = linspace(15,1100,15) ;
  
  mjd = 54936.5 ; dMjd = 0.02 ;
  
% prepare 5 pointings -- on point and then a box of 0.5 pixel offsets around it

  pointing = zeros(3,5) ;
  angle0p5Pix = 0.5 * 3.98 / 3600 ; % 0.5 pixels converted to degrees
  pointing(1,2:5) = angle0p5Pix * [-1 -1  1 1] ;
  pointing(2,2:5) = angle0p5Pix * [-1  1 -1 1] ;
  
% add a 0.1 pixel offset in RA and Dec to all coordinates

  pointing(1,1:5) = pointing(1,1:5) + angle0p5Pix / 5 ;
  pointing(2,1:5) = pointing(2,1:5) - angle0p5Pix / 5 ;
  
% generate fakedata for that date

  motionPolynomials = generate_fakedata_motion_polynomials( raDec2PixObject0, ...
      mjd, dMjd, pointing, rowGrid, colGrid, 100e-6 ) ;

  mjdLongCadence = [motionPolynomials(1,:).mjdMidTime] ;
  mjdRefCadence = mjdLongCadence(1) ;

  fpgDataStruct.motionPolynomials = motionPolynomials ;
  fpgDataStruct.mjdLongCadence = mjdLongCadence ;
  fpgDataStruct.mjdRefCadence = mjdRefCadence ;
  fpgDataStruct.doRobustFit = false ;
  fpgDataStruct.fitPlateScaleFlag = true ;
  fpgDataStruct.excludedModules = [] ;
  fpgDataStruct.excludedOutputs = [] ;
  
% on the first fit, don't fit the reference cadence pointing and don't use a
% user-specified value, either

  fpgDataStruct.fitPointingRefCadence = false ;

% perform the first fit

  fpgDataObject = fpgDataClass(fpgDataStruct) ;
  fpgDataObject = fpg_data_reformat(fpgDataObject) ;
  fpgResultsObject = update_fpg(fpgDataObject) ;
  
% get the fitted geometry and demonstrate that it does not agree with the geometry used to
% generate the fake data, since the fit does not include the pointing error
  
  fpgResultsObject = set_raDec2Pix_geometry( fpgResultsObject, 1 ) ;
  raDec2PixObject1 = get(fpgResultsObject,'raDec2PixObject') ;
  [dRow,dCol] = compute_geometry_diff_in_pixels( raDec2PixObject0, raDec2PixObject1, ...
      [21 1044],[13 13], mjdRefCadence, 'one-based' ) ;
  dRowCol = [dRow ; dCol] ;

  tolerance = 0.05 ;

  errmsg = 'Fit quality too good in presence of pointing offset' ;
  mlunit_assert( max(abs(dRowCol)) > tolerance, errmsg ) ;
  
% get the actual pointing used for the reference cadence and supply it to the fitting
% process

  pointingObject = pointingClass(get(raDec2PixObject0,'pointingModel')) ;
  pointingDesign = get_pointing(pointingObject,mjdRefCadence) ;
  fpgDataStruct.pointingRefCadence = pointingDesign ;
  fpgDataStruct.pointingRefCadence(1) = fpgDataStruct.pointingRefCadence(1) + ...
      angle0p5Pix / 5 ;
   fpgDataStruct.pointingRefCadence(2) = fpgDataStruct.pointingRefCadence(2) - ...
       angle0p5Pix / 5 ;

% perform the fit including the actual pointing on the reference cadence

  fpgDataObject = fpgDataClass(fpgDataStruct) ;
  fpgDataObject = fpg_data_reformat(fpgDataObject) ;
  fpgResultsObject = update_fpg(fpgDataObject) ;

% get the fitted geometry and demonstrate that it agrees with the geometry used to
% generate the fake data, since the fit now includes the pointing error
  
  fpgResultsObject = set_raDec2Pix_geometry( fpgResultsObject, 1 ) ;
  raDec2PixObject1 = get(fpgResultsObject,'raDec2PixObject') ;
  [dRow,dCol] = compute_geometry_diff_in_pixels( raDec2PixObject0, raDec2PixObject1, ...
      [21 1044],[13 13], mjdRefCadence, 'one-based' ) ;
  dRowCol = [dRow ; dCol] ;

  errmsg = 'Fit quality inadequate with pointing error included' ;
  mlunit_assert( max(abs(dRowCol)) <= tolerance, errmsg ) ;
  
% change the pointing information provided to the fit to be incorrect again, but allow the
% fit to include the pointing on the reference cadence as a parameter

  fpgDataStruct.pointingRefCadence = pointingDesign ;
  fpgDataStruct.fitPointingRefCadence = true ;

  fpgDataObject = fpgDataClass(fpgDataStruct) ;
  fpgDataObject = fpg_data_reformat(fpgDataObject) ;
  fpgResultsObject = update_fpg(fpgDataObject) ;

% get the fitted geometry and demonstrate that it agrees with the geometry used to
% generate the fake data, since the reference cadence pointing is now fitted
  
  fpgResultsObject = set_raDec2Pix_geometry( fpgResultsObject, 1 ) ;
  raDec2PixObject1 = get(fpgResultsObject,'raDec2PixObject') ;
  [dRow,dCol] = compute_geometry_diff_in_pixels( raDec2PixObject0, raDec2PixObject1, ...
      [21 1044],[13 13], mjdRefCadence, 'one-based' ) ;
  dRowCol = [dRow ; dCol] ;

  errmsg = 'Fit quality inadequate with pointing fitted' ;
  mlunit_assert( max(abs(dRowCol)) <= tolerance, errmsg ) ;
  
% finally, convert the fpgDataStruct to the pipeline format and repeat the fit

  fpgDataStructPipeline = convert_fpg_inputs_to_pipeline( fpgDataStruct ) ;
  fpgDataObject = fpgDataClass(fpgDataStructPipeline) ;
  fpgDataObject = fpg_data_reformat(fpgDataObject) ;
  fpgResultsObjectPipeline = update_fpg(fpgDataObject) ;
  fpgResultsObjectPipeline = set_raDec2Pix_geometry( fpgResultsObjectPipeline, 1 ) ;
  
% the two fpgResultsClass objects should be identical

  errmsg = 'Pipeline and interactive results objects not identical' ;
  assert_equals( get(fpgResultsObject,'*'), get(fpgResultsObjectPipeline,'*'), errmsg ) ;
  
% randomly rearrange the motion polynomial blobSeries structures in the pipeline input and
% re-run, make sure that the result is identical to the one with the nominal order

  fpgDataStructPipelineOld = fpgDataStructPipeline ;

  nMotionBlobs = length(fpgDataStructPipeline.motionBlobsStruct) ;
  newOrder = randperm(nMotionBlobs) ;
  fpgDataStructPipeline.motionBlobsStruct = ...
      fpgDataStructPipeline.motionBlobsStruct(newOrder) ;

  fpgDataObject = fpgDataClass(fpgDataStructPipeline) ;
  fpgDataObject = fpg_data_reformat(fpgDataObject) ;
  fpgResultsObjectPipeline = update_fpg(fpgDataObject) ;
  fpgResultsObjectPipeline = set_raDec2Pix_geometry( fpgResultsObjectPipeline, 1 ) ;
  errmsg = 'Pipeline and interactive results objects not identical' ;
  assert_equals( get(fpgResultsObject,'*'), get(fpgResultsObjectPipeline,'*'), errmsg ) ;
  
% lop off the first 4 mod/outs (the first 2 CCDs), permute what's left, and make sure that
% the fit proceeds as expected (ie, the first 2 CCDs are left out of the fit)

  fpgDataStructPipeline = fpgDataStructPipelineOld ;
  fpgDataStructPipeline.motionBlobsStruct = fpgDataStructPipeline.motionBlobsStruct(5:84) ;
  nMotionBlobs = length(fpgDataStructPipeline.motionBlobsStruct) ;
  newOrder = randperm(nMotionBlobs) ;
  fpgDataStructPipeline.motionBlobsStruct = ...
      fpgDataStructPipeline.motionBlobsStruct(newOrder) ;

  fpgDataObject = fpgDataClass(fpgDataStructPipeline) ;
  fpgDataObject = fpg_data_reformat(fpgDataObject) ;
  fpgResultsObjectPipeline = update_fpg(fpgDataObject) ;
  geometryParMap = get(fpgResultsObjectPipeline,'geometryParMap') ;
  geometryParMap = geometryParMap(:) ;
  geometryParMapExpected = [zeros(6,1) ; [1:120]'] ;
  assert_equals(geometryParMap, geometryParMapExpected, ...
      'geometryParMap not structured as expected when mods 2 and 3 thrown out of motionBlobsStruct') ;
  
% clean up blob files

  cleanup_fpgDataStruct_blob_files( fpgDataStructPipelineOld ) ;
  
% and that's it!

%
%
%
  