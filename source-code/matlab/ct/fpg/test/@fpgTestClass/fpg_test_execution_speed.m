function [self] = fpg_test_execution_speed(self)
%
% fpg_test_execution_speed -- verify that the 121-cadence FPG fit can be accomplished in
% the required time.
%
% This unit test generates fake FPG data for 121 cadences and runs it through the fitting
%    algorithm.  The FPG class for interactive generation of displays and other results
%    management is then instantiated.  This test demonstrates the following:
%
% 1.  The 121-cadence FPG fit can meet the execution time requirement (currently 120
%     minutes or less), while simultaneously meeting the FPG accuracy requirement of 0.1
%     pixels.
% 2.  The FPG results management class produces all of the displays which are required.
%
% Since different computers have different performance levels compared to the computers
%    for which the requirement is held (ie, the pipeline computers), the unit test first
%    estimates the performance of the testing computer in order to scale the required time
%    (ie, slower computers will be allotted more time to execute the test before failure
%    is declared).
%
% Note that this test can take a very long time to execute!  It is not executed as part of
%    the standard FPG all-unit-tests operation, but only on its own, and users are
%    cautioned to allow sufficient time for the test to execute.
%
% This is a test which is intended to be used in the mlunit context.  The appropriate
% syntax for execution is as follows:
%
%     run(text_test_runner, fpgTestClass('fpg_test_execution_speed')) ;
%
% Version date:  2008-December-20.
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
%     2008-December-20, PT:
%         update tolFun default value.
%     2008-December-12, PT:
%         delete obsolete ephemeris file cleanup.
%     2008-October-30, PT:
%         update fakedata generation values to match current expected performance of PA.
%     2008-October-05, PT:
%         restructure to more closely resemble PRF/FPG use case:  include N cadences which
%         are bad (motion contaminated) interleaved with N that are to be used; cadence 1
%         is the reference cadence; other cadences are randomly rearranged.
%     2008-October-03, PT:
%         bugfix:  send the ID of the ref cadence to the fakedata generator.  Add data
%         status map plot to displays.
%     2008-September-19, PT:
%         changes in support of zero- or one-based raDec2PixClass objects.  Move assert
%         related to execution time to the end of the test so that if it fails everything
%         else will at least have been exercised.
%     2008-August-07, PT:
%         name change so that automatic execution in master test suite is suppressed.
%     2008-July-29, PT:
%         update execution time on reference computer based on production version of
%         raDec2Pix, not improved version.
%     2008-July-27, PT:
%         add FOV plot using fpgResultsUserClass methods.
%     2008-July-25, PT:
%         remove FOV display information from fpgDataStruct.
%
%=========================================================================================

% define the normal execution time limit

  executionNominalTimeLimitSeconds = 2 * 3600 ;
  
% load the appropriate model for raDec2Pix, and generally set up to get data for the test

  setup_fpg_paths_and_files ;

% determine the MJD range over which data will be generated

  dRAPixels = [0 -0.5 -0.4 -0.3 -0.2 -0.1  0.1  0.2  0.3  0.4  0.5] ;
  dDecPixels = dRAPixels ;
  [dRA,dDec] = ndgrid(dRAPixels,dDecPixels) ;
  
  dRA = dRA(:) ; dDec = dDec(:) ;
  
% randomly permute pointings for cadences other than the reference cadence

  nCadences = length(dRA) ;
  cadenceOrder = 1 + randperm(nCadences-1) ;
  dRA(2:nCadences) = dRA(cadenceOrder) ;
  dDec(2:nCadences) = dDec(cadenceOrder) ;
  
  dPoint1Pix = 3.98 / 3600 ; % 1 pixel offset in degrees
  dRA = dRA * dPoint1Pix ; dDec = dDec * dPoint1Pix ; 
  
  mjdStart = 54936.5 ; mjdTimeStep = 0.02 ;
  mjdFinish = mjdStart + mjdTimeStep * length(dRA(:)) ;
  
% generate and raDec2PixClass object with 3 pixel misalignments and a -0.0001 fractional
% error in the plate scale

  raDec2PixObject0 = make_raDec2PixClass_fakedata_object( 3, 3, 0.16, -1e-4, ...
    rd2pm ) ;
  
% determine the testing speed of the testing computer and scale the allowed time for the
% main test to execute based on a comparison of the test computer speed to a reference
% computer speed (in this case, my laptop, which is a reasonable facsimile of a pipeline
% computer)

  executionTimeReferenceComputer = 19.0 ;
  executionTime = fpg_execution_speed_test(raDec2PixObject0, mjdStart+mjdTimeStep, 1000) ;
  
  speedScaleFactor = executionTime / executionTimeReferenceComputer ;
  executionTimeLimitSeconds = executionNominalTimeLimitSeconds * speedScaleFactor ;
  
% display a warning for the user

  disp(['Execution time may exceed ',num2str(round(executionTimeLimitSeconds/60)),...
      ' minutes, be warned!']) ;
  
% generate motion polynomials for all of the pointings and find the reference pointing

  rowGrid = linspace(25,1040,15) ;
  colGrid = linspace(15,1100,15) ;

 pointing = [dRA(:)' ; dDec(:)' ; zeros(1,length(dDec(:)))] ;
 refPointing = find(dRA == 0 & dDec == 0,1) ;
 if (isempty(refPointing))
     refPointing = 1 ;
 end
  
  motionPolynomials = generate_fakedata_motion_polynomials( raDec2PixObject0, ...
      mjdStart, mjdTimeStep * 2, pointing, rowGrid, colGrid, 100e-6, refPointing ) ;
  
% generate a second set of motion polynomials by duplicating the first, but make these the
% motion contaminated set by setting the rowPolyStatus and colPolyStatus to 0 (bad);
% change the times by 1 mjdTimeStep

  mpMotionContaminated = motionPolynomials ;
  for jCount = 1:size(mpMotionContaminated,2)
      for iCount = 1:size(mpMotionContaminated,1)
          mpMotionContaminated(iCount,jCount).mjdStartTime = ...
              mpMotionContaminated(iCount,jCount).mjdStartTime + mjdTimeStep ;
          mpMotionContaminated(iCount,jCount).mjdMidTime = ...
              mpMotionContaminated(iCount,jCount).mjdMidTime + mjdTimeStep ;
          mpMotionContaminated(iCount,jCount).mjdEndTime = ...
              mpMotionContaminated(iCount,jCount).mjdEndTime + mjdTimeStep ;
          mpMotionContaminated(iCount,jCount).rowPolyStatus = 0 ;
          mpMotionContaminated(iCount,jCount).colPolyStatus = 0 ;
      end
  end
  
% assemble a complete set of motion polynomials, interleaving the bad ones with the good
% by reshaping the resulting struct array

  motionPolynomials = [motionPolynomials ; mpMotionContaminated] ;
  motionPolynomials = reshape(motionPolynomials,84,2*nCadences) ;
  
% find the correct values for the mjdLongCadence vector and the mjdRefCadence scalar
  
  mjdLongCadence = [motionPolynomials(1,:).mjdMidTime] ;
  mjdRefCadence = mjdLongCadence(refPointing) ;
  
% get the focal plane characterization constants

  load(fullfile(testFileDir,'fcConstants')) ;
  
% select the rows and columns on which the constraintPoints will be evaluated

  rowGridValues = [300 700] ; colGridValues = [100 700] ;
  
% construct the data structure

  fpgDataStruct.mjdLongCadence = mjdLongCadence ;
  fpgDataStruct.excludedModules = [] ;
  fpgDataStruct.excludedOutputs = [] ;
  fpgDataStruct.rowGridValues = rowGridValues ;
  fpgDataStruct.columnGridValues = colGridValues ;
  fpgDataStruct.mjdRefCadence = mjdRefCadence ;
  fpgDataStruct.fitPlateScaleFlag = true ;
  fpgDataStruct.tolX = 1e-8 ;
  fpgDataStruct.tolFun = 2e-2 ;
  fpgDataStruct.tolSigma = 5e-1 ;
  fpgDataStruct.doRobustFit = true ;
  fpgDataStruct.fcConstants = fcConstants ;
  fpgDataStruct.raDec2PixModel = rd2pm ;
  fpgDataStruct.motionPolynomials = motionPolynomials ;
  
% start the clock

  t0 = clock ;
  disp(t0) ;
  
% instantiate the data structure

  fpgDataObject = fpgDataClass(fpgDataStruct) ;
  
% perform data reorganization

  fpgDataObject = fpg_data_reformat(fpgDataObject) ;
  
% perform the fit

  fpgResultsObject = update_fpg(fpgDataObject) ;
  
% how long did it take?

  elapsedTime = etime(clock,t0) ; 

% accuracy of the fit

  fpgResultsObject = set_raDec2Pix_geometry( fpgResultsObject, 1 ) ;
  raDec2PixObject = get(fpgResultsObject,'raDec2PixObject') ;
  [dRow,dCol] = compute_geometry_diff_in_pixels( raDec2PixObject0, raDec2PixObject, ...
      [21 1044],[13 13], mjdRefCadence, 'one-based' ) ;
  disp([dRow dCol]) ;
  dRowCol = [dRow ; dCol] ;
  
  tolerance = 0.05 ;
  
  mlunit_assert( max(abs(dRowCol)) <= tolerance, ...
      'robust, plate-scale included fit does not meet accuracy tolerance!' ) ;
  
% all figure-generation routines execute without error

  fpgResultsPlotStruct.Angle321 = plot_321_angle_changes( fpgResultsObject ) ;
  fpgResultsPlotStruct.ccdMisalignments = plot_ccd_misalignments( fpgResultsObject ) ;
  [fpgResultsPlotStruct.pointingScatter, fpgResultsPlotStruct.pointingValue] = ...
      plot_fpg_pointing( fpgResultsObject ) ;
  fpgResultsPlotStruct.quiverBefore = plot_fpg_residuals_quiver( fpgResultsObject, 1 ) ;
  fpgResultsPlotStruct.quiverAfter = plot_fpg_residuals_quiver( fpgResultsObject, 0 ) ;
  [fpgResultsPlotStruct.residualsBefore, fpgResultsPlotStruct.residualsAfter] = ...
      plot_fpg_fit_residuals( fpgResultsObject ) ;
  fpgResultsPlotStruct.robustWeights = plot_robust_weights( fpgResultsObject ) ;
  fpgResultsPlotStruct.dataStatusMap = plot_data_status_map( fpgResultsObject ) ;
  [fpgResultsPlotStruct.correlationImage, fpgResultsPlotStruct.correlationSurface, ...
      fpgResultsPlotStruct.globalCorrelation] = plot_fpg_correlations( fpgResultsObject ) ;

% instantiate fpgResultsUserClass object, get FOV plot data, and produce the plot.  We'll
% use the non-datastore-access version of the retrieval methods, since (a) the data we
% need to retrieve isn't in the datastore yet, (b) the SBTs to get to it are not all
% complete, (c) we want the test to be able to run on computers which aren't inside the
% SOC firewall.  Also, we'll pass the raDec2PixObject which was used to generate the
% motion polynomials so that the pixel positions are "real".

  fpgResultsUserObject = fpgResultsUserClass( fpgResultsObject ) ;
  fpgResultsUserObject = retrieve_star_information_from_catalog( fpgResultsUserObject, ...
      6, 15, 0 ) ;
  fpgResultsUserObject = retrieve_pixels_from_cadence( fpgResultsUserObject, 0, ...
      raDec2PixObject0 ) ;
  [fpgResultsUserObject,fovPlotHandle] = display_reference_cadence( fpgResultsUserObject, ...
      6, 9 ) ;
  
% was the elapsed time sufficiently small?  Do this at the end, so that all of the other
% stuff will execute before this error is thrown, if it is

  display(['Elapsed time in fit:  ',num2str(elapsedTime),' seconds']) ;
  mlunit_assert( elapsedTime <= executionTimeLimitSeconds, ...
      'Robust 121-cadence fit does not meet execution time requirement!' ) ;  
  
% and that's it

%
%
%
