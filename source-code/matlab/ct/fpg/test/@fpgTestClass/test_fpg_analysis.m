function [self] = test_fpg_analysis(self)
%
% test_fpg_analysis -- unit test which demonstrates that the FPG algorithm is working
% properly
%
% This unit test generates fake FPG data and runs it through the fitting algorithm under a
% number of different conditions, in the process demonstrating the following:
%
% 1.  That turning plate scale fitting on/off changes the fit result
% 2.  That turning robust fitting on/off changes the fit result and the robust weights
% 3.  That performing a robust fit with plate scale fitting enabled gets the expected
%     answer to within the requirements specified for FPG
% 4.  That user-excluded mod/outs and data which has been flagged as bad data in the 
%     motion polynomials used for the analysis procedure are properly handled.
%
% This is a test which is intended to be used in the mlunit context.  The appropriate
% syntax for execution is as follows:
%
%     run(text_test_runner, fpgTestClass('test_fpg_analysis')) ;
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
%         changes in support of one- vs zero-based coordinate systems.
%     2008-September-07, PT:
%         update fpgTestDataStruct file name.
%     2008-July-27, PT:
%         cleanup any copied ephemeris files at end of execution.
%     2008-July-18, PT:
%         use setup_fpg_paths_and_files instead of local code block for same purpose.
%     2008-July-11, PT:
%         check that chisq/ndof is at least 1000x as large in the case without plate scale
%         fitting as it is in the case with fitting.  Check that correct cadence is
%         dropped from the final fit.
%
%=========================================================================================

% load the appropriate model for raDec2Pix

  setup_fpg_paths_and_files ;

% Generate a 5-cadence test dataset with 3 pixel / 0.16 degree errors, and with pointing
% offsets from 0 (reference) to roughly 2 pixels

  raDec2PixObject0 = make_raDec2PixClass_fakedata_object( 3, 3, 0.16, 1e-3, ...
    rd2pm ) ;

  dPoint1Pix = 3.98 / 3600 ; % 1 pixel offset in degrees
  pointing = [ 0    0.5*dPoint1Pix    dPoint1Pix    1.5*dPoint1Pix    2*dPoint1Pix ; ...
               0 0 0 0 0 ;
               0 0 0 0 0 ] ;
  rowGrid = linspace(25,1040,15) ;
  colGrid = linspace(15,1100,15) ;
           
  motionPolynomials = generate_fakedata_motion_polynomials( raDec2PixObject0, ...
      54936.5, 0.02, pointing, rowGrid, colGrid, 100e-6 ) ;
  
  mjdLongCadence = [motionPolynomials(1,:).mjdMidTime] ;
  mjdRefCadence = mjdLongCadence(1) ;
  
% apply the following defects to the data:
%
%    cadence 1,   module 2, output 2 row polynomial has bad status
%    cadence 1-5, module 2, output 3 row or col polynomials have bad status
%    cadence 2,   9 channels have bad row or col polynomial status
%    cadence 3,   module 2, output 4 has a motion polynomial with bad status
%    cadence 4,   8 channels have bad row or col polynomial status
%
% Note that since mod 2, out 3 is bad on all, it complicates slightly the process of
% assigning bad mod/outs randomly to cadences 2 and 4

  motionPolynomials(2,1).rowPolyStatus = false ;
  
  for iCadence = 1:size(motionPolynomials,2)
      motionPolynomials(3,iCadence) = set_bad_polynomial_status(motionPolynomials(3,iCadence)) ;
  end
  
  badChannels = [] ; 
  while (length(badChannels) < 8)
      badChannels = [badChannels get_random_bad_channel_list(8-length(badChannels))] ;
      mod2out3 = find(badChannels == 3) ;
      badChannels(mod2out3) = [] ;
  end
  for iChannel = 1:length(badChannels)
      motionPolynomials(badChannels(iChannel),2) = set_bad_polynomial_status( ...
          motionPolynomials(badChannels(iChannel),2) ) ;
  end

  motionPolynomials(4,3) = set_bad_polynomial_status(motionPolynomials(4,3)) ;
  
  badChannels = [] ; 
  while (length(badChannels) < 7)
      badChannels = [badChannels get_random_bad_channel_list(7-length(badChannels))] ;
      mod2out3 = find(badChannels == 3) ;
      badChannels(mod2out3) = [] ;
  end
  for iChannel = 1:length(badChannels)
      motionPolynomials(badChannels(iChannel),4) = set_bad_polynomial_status( ...
          motionPolynomials(badChannels(iChannel),4) ) ;
  end
  
% load an existing data structure and replace its data where appropriate

  load(fullfile(testFileDir,'fpgTestDataStruct')) ;
  fpgDataStruct.mjdLongCadence = mjdLongCadence ;
  fpgDataStruct.mjdRefCadence = mjdRefCadence ;
  
  fpgDataStruct.rowGridValues = [50 1000] ;  
  fpgDataStruct.columnGridValues = [50 750] ; 
  fpgDataStruct.raDec2PixModel = rd2pm ;
  fpgDataStruct.motionPolynomials = motionPolynomials ;

% exclude mod 2 out 1 from the fit completely

  fpgDataStruct.excludedModules = 2 ;
  fpgDataStruct.excludedOutputs = 1 ;
  
% first fit -- no plate scale, no robust fitting

  fpgDataStruct.fitPlateScaleFlag = false ;
  fpgDataStruct.doRobustFit = false ;
  fpgDataObject1 = fpgDataClass(fpgDataStruct) ;
  fpgDataObject1 = fpg_data_reformat(fpgDataObject1) ;
  fpgResultsObject1 = update_fpg(fpgDataObject1) ;
  
% second fit -- plate scale fitting on, no robust fitting

  fpgDataStruct.fitPlateScaleFlag = true ;
  fpgDataObject2 = fpgDataClass(fpgDataStruct) ;
  fpgDataObject2 = fpg_data_reformat(fpgDataObject2) ;
  fpgResultsObject2 = update_fpg(fpgDataObject2) ;

% third fit -- plate scale fitting on, robust fitting on 

  fpgDataStruct.doRobustFit = true ;
  fpgDataStruct.tolSigma = 0.1 ;
  fpgDataObject3 = fpgDataClass(fpgDataStruct) ;
  fpgDataObject3 = fpg_data_reformat(fpgDataObject3) ;
  fpgResultsObject3 = update_fpg(fpgDataObject3) ;
  
% First test -- with/without plate scale results are not identical, and chisq/ndof for
% without is > 1000x as large as with.

  fitVector1 = get(fpgResultsObject1,'finalParValues') ;
  fitVector2 = get(fpgResultsObject2,'finalParValues') ;
  chisq1 = get(fpgResultsObject1,'chisq') ;
  chisq2 = get(fpgResultsObject2,'chisq') ;
  
  assert_not_equals(fitVector1, fitVector2,...
      'fits with and without plate scale fitting are equal!') ;
  mlunit_assert( chisq1 >= 1000*chisq2, ...
      'fit without plate scale not as bad as anticipated!') ;
  
% second test -- with/without robust fitting results are not identical and robust weights
% are not identical

  fitVector3 = get(fpgResultsObject3,'finalParValues') ;
  robustVector2 = get(fpgResultsObject2,'robustWeights') ;
  robustVector3 = get(fpgResultsObject3,'robustWeights') ;

  assert_not_equals(fitVector2, fitVector3, ...
      'robust and non-robust fits are equal!') ;
  assert_not_equals(robustVector2, robustVector3, ...
      'robust and non-robust fits have identical robust weights!') ;
  
% third test -- the robust, plate-scale on version got the right answer to within
% tolerances

  fpgResultsObject3 = set_raDec2Pix_geometry( fpgResultsObject3, 1 ) ;
  raDec2PixObject3 = get(fpgResultsObject3,'raDec2PixObject') ;
  [dRow,dCol] = compute_geometry_diff_in_pixels( raDec2PixObject0, raDec2PixObject3, ...
      [21 1044],[13 13], mjdRefCadence, 'one-based' ) ;
  dRowCol = [dRow ; dCol] ;
  
  tolerance = 0.05 ;
  
  mlunit_assert( max(abs(dRowCol)) <= tolerance, ...
      'robust, plate-scale included fit does not meet accuracy tolerance!' ) ;
  
% fourth test -- that the uncertainties on the first 2 CCDs are much larger than on any
% other CCD, indicating that the bad / excluded data has in fact been left out of the fit

  fitCovariance3 = get(fpgResultsObject3,'parValueCovariance') ;
  fitUncertainty3 = sqrt(diag(fitCovariance3)) ;
  
  angle3Uncertainty3 = fitUncertainty3(1:3:126) ;
  angle2Uncertainty3 = fitUncertainty3(2:3:126) ;
  angle1Uncertainty3 = fitUncertainty3(3:3:126) ;
  
  uncertaintyVariationFactor = 1.35 ; % should be sqrt(2), but leave some wiggle room
                                      % since it won't be exact
                                      
  angle3Mean = mean(angle3Uncertainty3(3:42)) ;
  angle2Mean = mean(angle2Uncertainty3(3:42)) ;
  angle1Mean = mean(angle1Uncertainty3(3:42)) ;

  angle3Good = ( angle3Uncertainty3(1) > uncertaintyVariationFactor * angle3Mean && ...
                 angle3Uncertainty3(2) > uncertaintyVariationFactor * angle3Mean ) ;
  angle2Good = ( angle2Uncertainty3(1) > uncertaintyVariationFactor * angle2Mean && ...
                 angle2Uncertainty3(2) > uncertaintyVariationFactor * angle2Mean ) ;
  angle1Good = ( angle1Uncertainty3(1) > uncertaintyVariationFactor * angle1Mean && ...
                 angle1Uncertainty3(2) > uncertaintyVariationFactor * angle1Mean ) ;
  
  mlunit_assert( angle3Good && angle2Good && angle1Good, ...
      'CCDs 1 and 2 fit uncertainties not large enough!' ) ;
  
% fifth test -- only 4 cadences were used on the final fit, and that the original cadence
% 2 was omitted

  raDecModOut = get(fpgResultsObject3, 'raDecModOut') ;
  
  nCadenceFinal = length(raDecModOut) ;
  
  mlunit_assert( nCadenceFinal == length(mjdLongCadence)-1, ...
      'wrong number of cadences used in fit!' ) ;
  
  mjdUsed = get(fpgResultsObject3, 'mjd') ;
  mjdOrig = get(fpgDataObject3,'mjdLongCadence') ;
  mjdUsed = mjdUsed(:) ;
  mjdOrig = mjdOrig(:) ;
  
  assert_equals(mjdUsed, [mjdOrig(1) ; mjdOrig(3:5)], ...
      'wrong cadences used in fit!') ;
  
% and that's it!

%
%
%

%=========================================================================================

% randomly set bad row or column polynomial status

function motionPolyStrucOut = set_bad_polynomial_status( motionPolyStrucIn )

  motionPolyStrucOut = motionPolyStrucIn ;
  
  z = rand(1) ;
  if (z<0.5)
      motionPolyStrucOut.rowPolyStatus = false ;
  else
      motionPolyStrucOut.colPolyStatus = false ;
  end
  
% and that's it!

%
%
%

%=========================================================================================

% select a given number of channels at random to be set as bad

function badChannels = get_random_bad_channel_list(nChannels) 

  badChannels = [] ;
  while (length(badChannels) ~= nChannels)
      badChannels = [badChannels ceil(84*rand(1,nChannels-length(badChannels)))] ;
      badChannels = unique(badChannels) ;
  end
  
  
