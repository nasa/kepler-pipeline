function self = test_fpg_geometry_model( self )
%
% test_fpg_geometry_model -- unit test for Focal Plane Geometry which tests the following
% properties:
%
% ==> A geometry model can be passed to FPG, in the form of a blob, via the pipeline
%     interface input structure
% ==> The geometry model which is so passed is in fact the one which is used as a starting
%     point in the fit
% ==> The filename which is returned as the geometry blob file name is in fact the name of
%     a file which contains a geometry model in blob form
% ==> The returned geometry model does in fact match the model which was fitted by FPG
% ==> The returned filename for the geometry model flat file (for FC import) matches a
%     file which exists and which has the correct format for the importer.
%
% This is a unit test which is intended to operate in the mlunit context.  To execute, use
% the following syntax:
%
%      run(text_test_runner, fpgTestClass('test_fpg_geometry_model'));
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
%    2008-December-12, PT:
%        add test for importer format.  Remove cleanup of ephemeris files.
%
%=========================================================================================

% first things first:  figure out where we are running from (the FPG development laptop or
% a SOC workstation), and set the location of the test files accordingly:

  setup_fpg_paths_and_files ;

% load the fpgDataStruct and replace its raDec2PixModel with the correct one from above

  load(fullfile(testFileDir,'fpgTestDataStruct')) ;
  fpgDataStruct.raDec2PixModel = rd2pm ;
  
% generate an raDec2PixClass object with appropriate misalignments

  raDec2PixObject0 = make_raDec2PixClass_fakedata_object( 3, 3, 0.12, 1e-4, ...
    rd2pm ) ;

% prepare a second raDec2PixClass object with a different geometry model

  raDec2PixObject1 = make_raDec2PixClass_fakedata_object( 3, 3, 0.12, -7e-5, ...
    rd2pm ) ;

% prepare row/column information for the motion polynomial fit

  rowGrid = linspace(300,700,5) ;
  colGrid = linspace(300,650,5) ;
  
% Prepare motion polynomials for the fit, and set some parameters  
  
  mjd = 54936.5 ;

  motionPolynomials = generate_fakedata_motion_polynomials( raDec2PixObject0, ...
      mjd, 0.02,[0 ; 0 ; 0], rowGrid, colGrid, 20e-6 ) ;

  mjdLongCadence = [motionPolynomials(1,:).mjdMidTime] ;
  mjdRefCadence = mjdLongCadence(1) ;

  fpgDataStruct.motionPolynomials = motionPolynomials ;
  fpgDataStruct.mjdLongCadence = mjdLongCadence ;
  fpgDataStruct.mjdRefCadence = mjdRefCadence ;
  fpgDataStruct.fitPlateScaleFlag = true ;
  fpgDataStruct.doRobustFit = false ;
  
% convert the fpgDataStruct to the format which is correct for the pipeline

  fpgDataStruct = convert_fpg_inputs_to_pipeline( fpgDataStruct ) ;
  
% delete the geometry blob file which is currently pointed to by the data structure, blob
% up the geometry model in raDec2PixObject1, and put its name into the relevant field

  delete( fpgDataStruct.geometryBlobFileName ) ;
  
  geometryModel = get(raDec2PixObject1,'geometryModel') ;
  fileTimestamp = datestr(now,30) ;
  gmFilename = ['geometryModelBlob_fpgInput_',fileTimestamp,'.mat'] ;
  struct_to_blob( geometryModel, gmFilename ) ;
  fpgDataStruct.geometryBlobFileName = gmFilename ;
  
% first test -- put the fpgDataStruct through fpg_matlab_controller and see that it does
% not error out (ie, the geometryBlobFileName was accepted, at least)

  fpgOutputStruct = fpg_matlab_controller( fpgDataStruct ) ;
%  save geometryModel geometryModel fpgOutputStruct ;
%  load geometryModel
  close all ;
  
% second test -- the geometry model which was blobbed up should match the starting
% geometry model of the fpgDataClass object which was used in the fit

  load fpgResultsStruct ;
  fpgResultsObject = fpgResultsClass(fpgResultsStruct) ;
  fpgResultsObject = set_raDec2Pix_geometry(fpgResultsObject,0) ;
  raDec2PixObject = get(fpgResultsObject,'raDec2PixObject') ;
  geometryModelFitStart = get(raDec2PixObject,'geometryModel') ;
  
  assert_equals( geometryModel, geometryModelFitStart, ...
      'Starting geometry models do not match') ;
  
% third test -- the geometry model in the blob referred to in output is really a geometry
% model

  geometryModelOutput = single_blob_to_struct( fpgOutputStruct.geometryBlobFileName ) ;
  geometryObject = geometryClass( geometryModelOutput ) ;
  
% fourth test -- the geometry model matches the one which is the fit result in the
% fpgResultsObject

  fpgResultsObject = set_raDec2Pix_geometry(fpgResultsObject,1) ;
  raDec2PixObject = get(fpgResultsObject,'raDec2PixObject') ;
  geometryModelFitFinal = get(raDec2PixObject,'geometryModel') ;
  
  assert_equals( geometryModelFitFinal, geometryModelOutput, ...
      'Final geometry models do not match') ;
  
% fifth test -- test the existence and format of the flat-file form of the geometry model.
% This test will only work if the production version of the ImporterGeometry class, or the
% fc jar file, is present on Matlab's java path

  import gov.nasa.kepler.fc.importer.ImporterGeometry ;
  importGeometry = ImporterGeometry() ;
  try
      parsedGeometry = importGeometry.parseFile(fpgOutputStruct.fpgImportFileName) ;
  catch
      mlunit_assert( false, 'Geometry import test failed!' ) ;
  end
  
% do cleanup

  cleanup_fpgDataStruct_blob_files( fpgDataStruct ) ;
  delete( fpgOutputStruct.geometryBlobFileName ) ;
  cleanup_fpg_figure_files ;

% and that's it!

%
%
%

