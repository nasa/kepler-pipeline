function self = test_roll_transparency( self )
%
% test_roll_transparency -- unit test which verifies that FPG functions correctly in any
% of the 4 seasonal roll orientations, and also checks that an fpgDataStruct with empty
% fields for plotting of the FOV will execute properly.
%
% Syntax for calling: run(text_test_runner, fpgTestClass('test_roll_transparency')) ;
%
% Version date:  2009-April-23.
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
%     2009-April-23, PT:
%         set fitPlateScaleFlag to true.  Why did this test ever work with that flag set
%         to false?
%     2008-December-12, PT:
%         delete obsolete ephemeris file cleanup.
%     2008-October-30, PT:
%         update fakedata generation to match expected PA performance.
%     2008-September-19, PT:
%         changes in support of one- vs zero-based coordinates.
%     2008-September-07, PT:
%         update file name of fpgTestDataStruct.  Add test of velocity aberration
%         correction.
%     2008-July-27, PT:
%         cleanup any copied ephemeris files at end of execution.
%     2008-July-18, PT:
%         use setup_fpg_paths_and_files instead of local code block for same purpose.
%
%=========================================================================================

% first things first:  figure out where we are running from (the FPG development laptop or
% a SOC workstation), and set the location of the test files accordingly:

  setup_fpg_paths_and_files ;

% load the fpgDataStruct and replace its raDec2PixModel with the correct one from above

  load(fullfile(testFileDir,'fpgTestDataStruct')) ;
  fpgDataStruct.raDec2PixModel = rd2pm ;
  
% generate an raDec2PixClass object with appropriate misalignments

  raDec2PixObject0 = make_raDec2PixClass_fakedata_object( 3, 3, 0.16, 1e-3, ...
    rd2pm ) ;

% prepare row/column information for the motion polynomial fit

  rowGrid = linspace(25,1040,15) ;
  colGrid = linspace(50,1100,15) ;

% loop over seasons

  for iSeason = 1:4
      
%     get an MJD which is in the correct season, based on the roll time model

      mjd = rd2pm.rollTimeModel.mjds(iSeason) + 1 ;
      disp(['...executing FPG fit on MJD ',num2str(mjd),'...']) ;
      
%     generate fakedata for that date

      motionPolynomials = generate_fakedata_motion_polynomials( raDec2PixObject0, ...
          mjd, 0.02,[0 ; 0 ; 0], rowGrid, colGrid, 100e-6 ) ;

      mjdLongCadence = [motionPolynomials(1,:).mjdMidTime] ;
      mjdRefCadence = mjdLongCadence(1) ;
      
      fpgDataStruct.motionPolynomials = motionPolynomials ;
      fpgDataStruct.mjdLongCadence = mjdLongCadence ;
      fpgDataStruct.mjdRefCadence = mjdRefCadence ;
      fpgDataStruct.fitPlateScaleFlag = true ;
      fpgDataStruct.doRobustFit = true ;
      
%     perform the fit and compare the results to the initial model

      fpgDataObject = fpgDataClass(fpgDataStruct) ;
      fpgDataObject = fpg_data_reformat(fpgDataObject) ;
      fpgResultsObject = update_fpg(fpgDataObject) ;

      fpgResultsObject = set_raDec2Pix_geometry( fpgResultsObject, 1 ) ;
      raDec2PixObject1 = get(fpgResultsObject,'raDec2PixObject') ;
      [dRow,dCol] = compute_geometry_diff_in_pixels( raDec2PixObject0, raDec2PixObject1, ...
          [21 1044],[13 13], mjdRefCadence, 'one-based' ) ;
      dRowCol = [dRow ; dCol] ;

      tolerance = 0.05 ;

      errmsg = ['roll transparency test fails on iteration ',num2str(iSeason)] ;
      mlunit_assert( max(abs(dRowCol)) <= tolerance, errmsg ) ;
  
  end % loop over seasons
  
% Test to see that FPG fit is performed with velocity aberration correction included:  get
% the RA and Dec of all constraint points out of the results object

  raDecModOut = get(fpgResultsObject,'raDecModOut') ;
  ra = raDecModOut(1).matrix(:,1) ;
  dec = raDecModOut(1).matrix(:,2) ;
  mod1 = raDecModOut(1).matrix(:,3) ;
  out1 = raDecModOut(1).matrix(:,4) ;
  
% use raDec2PixObject1 to determine the row and column of every constraint point in the
% fit, and compare to the model_function values; the two should be equal, and so should
% the vectors of mod and out

  [mod2,out2,row,column] = ra_dec_2_pix(raDec2PixObject1, ra, dec, mjdRefCadence, 1) ; 
  rowColumn = [row(:) ; column(:)] ;
  modelVector = model_function( fpgResultsObject, get(fpgResultsObject,'finalParValues') ) ;
  
  velocityAberrationOn = isequal(rowColumn,modelVector) & isequal(mod1,mod2) & ...
      isequal(out1,out2) ;
  
  mlunit_assert(velocityAberrationOn, ...
      'Error in velocity aberration validation step 1, test_roll_transparency!') ;
  
% now extract the row and column with velocity aberration correction off, it should be
% different from the modelVector

  [mod2,out2,row,column] = ra_dec_2_pix(raDec2PixObject1, ra, dec, mjdRefCadence, 0) ; 
  rowColumn = [row(:) ; column(:)] ;

  velocityAberrationOff = ~isequal(rowColumn,modelVector) ;
  mlunit_assert(velocityAberrationOn, ...
      'Error in velocity aberration validation step 2, test_roll_transparency!') ;

% and that's it!

%
%
%

