function [self] = test_errors(self)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [self] = test_errors(self)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% This test validates that FPG error conditions are properly caught. The
% following error conditions are tested:
%
%    fpgDataClass constructor:
%        .wrong number of arguments
%        .wrong size for motionPolynomials data structure
%        .mismatch between excludedModules and excludedOutputs lengths
%        .mjdRefCadence is not scalar
%        .mjdLongCadence contains reused values
%        .motionPolynomials contain reused MJDs
%        .motionPolynomials from same LC have different MJDs
%        .empty row or column grid values
%        .motionPolynomials mod/outs not unique within a cadence
%        .motionPolynomials mod/outs not common across cadences
%        .starSkyCoordinates is present but mag limit missing
%
%    fpg_data_reformat method of fpgDataClass:
%        .reference cadence has too little good data for fit
%            (includes test of maxBadDataCutoff)
%        .unable to fit pointing on reference cadence
%        .no good mod/outs in a fit
%    update_fpg method of fpgDataClass:
%        .class object's fpgFitClass object vector is empty
%    get method of fpgDataClass:
%        .invalid name supplied for member which is to be returned
%
%    fpg_chisq method of fpgFitClass:
%        .empty finalParValues vector when final chisq requested
%        .empty robustWeights vector when use of robust weights requested
%    get method of fpgFitClass:
%        .invalid name supplied for member which is to be returned
%    set_raDec2Pix_geometry method of fpgFitClass:
%        .set requests use of final values which are not present
%        .invalid parameter # supplied to set_raDec2Pix_geometry
%
%    get method of fpgResultsClass:
%        .invalid name supplied for member which is to be returned
% 
%    get method of fpgResultsUserClass:
%        .invalid name supplied for member which is to be returned
%
%    retrieve_star_information_from_catalog method of fpgResultsUserClass:
%        .min magnitude specified is greater than max magnitude
%
%  Example
%  =======
%  Use a test runner to run the test method:
%      run(text_test_runner, fpgTestClass('test_errors'));
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
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

% first things first:  figure out where we are running from (the FPG development laptop or
% a SOC workstation), and set the location of the test files accordingly:

  setup_fpg_paths_and_files ;

%=========================================================================================
%
% no errors
%
%=========================================================================================

% First things first, demonstrate that a good fpgDataClass object can make its way through
% the entire process without error (commented out since some components don't exist yet)

  load(fullfile(testFileDir,'fpgTestDataStruct')) ;
  fpgDataStruct.raDec2PixModel = rd2pm ;
  fpgOutputs = fpg_matlab_controller( fpgDataStruct ) ;
  pause(5) ;

%=========================================================================================
%
% fpgDataClass errors
%
%=========================================================================================

  load(fullfile(testFileDir,'fpgTestDataStruct')) ;
  fpgDataStruct.raDec2PixModel = rd2pm ;

% too many or too few arguments

  try_to_catch_error_condition('a=fpgDataClass()','numInputs') ;
  try_to_catch_error_condition('a=fpgDataClass(1,2)','TooManyInputs') ;
  
% dimensioning errors

  fpgGoodDataStruct = fpgDataStruct ;
  fpgDataStruct.excludedOutputs = [fpgDataStruct.excludedOutputs(:) ; 4] ;
  try_to_catch_error_condition('a=fpgDataClass(fpgDataStruct)','excludedModOuts', ...
      fpgDataStruct, 'fpgDataStruct' ) ;
  
  fpgDataStruct = fpgGoodDataStruct ;
  mpSize = size(fpgDataStruct.motionPolynomials) ;
  fpgDataStruct.motionPolynomials = fpgDataStruct.motionPolynomials(:,1:mpSize(2)-1) ;
  try_to_catch_error_condition('a=fpgDataClass(fpgDataStruct)','motionPolynomialsNCadences', ...
      fpgDataStruct, 'fpgDataStruct' ) ;
   
  fpgDataStruct = fpgGoodDataStruct ;
  mpSize = size(fpgDataStruct.motionPolynomials) ;
  fpgDataStruct.motionPolynomials = fpgDataStruct.motionPolynomials(1:mpSize(1)-1,:) ;
  try_to_catch_error_condition('a=fpgDataClass(fpgDataStruct)','motionPolynomialsNModOuts', ...
      fpgDataStruct, 'fpgDataStruct' ) ;
   
% mjdRefCadence not scalar

  fpgDataStruct = fpgGoodDataStruct ;
  fpgDataStruct.mjdRefCadence = fpgDataStruct.mjdLongCadence(1:2) ;
  try_to_catch_error_condition('a=fpgDataClass(fpgDataStruct)','mjdRefCadenceNotScalar', ...
      fpgDataStruct, 'fpgDataStruct' ) ;
      
% mjdLongCadence values not unique 

  fpgDataStruct = fpgGoodDataStruct ;
  fpgDataStruct.mjdLongCadence(2) = fpgDataStruct.mjdLongCadence(1) ;
  try_to_catch_error_condition('a=fpgDataClass(fpgDataStruct)','mjdNotUnique', ...
      fpgDataStruct, 'fpgDataStruct' ) ;
  
% motionPolynomials MJDs not unique between LCs

  fpgDataStruct = fpgGoodDataStruct ;
  for iModOut = 1:84
    fpgDataStruct.motionPolynomials(iModOut,1).mjdMidTime = ...
      fpgDataStruct.motionPolynomials(iModOut,2).mjdMidTime ;
  end
  try_to_catch_error_condition('a=fpgDataClass(fpgDataStruct)',...
      'mjdMotionPolynomialsNotUnique', fpgDataStruct, 'fpgDataStruct' ) ;
  
% motionPolynomials MJDs not common within an LC -- since all motion polynomials within an
% MJD have to be the same as one another, and they all have to be members of the overall
% set of MJDs in use in the fit, this actually throws the same error as above

  fpgDataStruct = fpgGoodDataStruct ;
  fpgDataStruct.motionPolynomials(1,1).mjdMidTime = ...
      fpgDataStruct.motionPolynomials(1,2).mjdMidTime ;
  try_to_catch_error_condition('a=fpgDataClass(fpgDataStruct)',...
      'mjdMotionPolynomialsNotUnique', fpgDataStruct, 'fpgDataStruct' ) ;
  
% not enough good data on reference cadence -- first check that 8 bad mod/outs is okay,
% then check that 9 is too many

  fpgDataStruct = fpgGoodDataStruct ;
  for iModOut = 1:4
    fpgDataStruct.motionPolynomials(iModOut,3).rowPolyStatus = false ;  
    fpgDataStruct.motionPolynomials(iModOut+4,3).colPolyStatus = false ; 
  end
  a = fpgDataClass(fpgDataStruct) ; b = fpg_data_reformat(a) ;
  fpgDataStruct.motionPolynomials(9,3).colPolyStatus = false ; 
  try_to_catch_error_condition('a=fpgDataClass(fpgDataStruct); b = fpg_data_reformat(a) ;',...
      'badRefCadence', fpgDataStruct, 'fpgDataStruct' ) ;
  
% now set the allowed bad data to 20% from 10% and see whether it will pass the reformat

  fpgDataStruct.maxBadDataCutoff = 0.2 ;
  a = fpgDataClass(fpgDataStruct) ; b = fpg_data_reformat(a) ;

% set the allowed bad data to 99% (ie, only 1 good mod/out needed), set the mod/outs to
% all bad except for (24,4), set the ref cadence fitting to ON and make sure that the
% reformat fails due to inadequate data for fitting the ref cadence pointing

  fpgDataStruct.maxBadDataCutoff = 0.99 ;
  for iModOut = 1:83
      fpgDataStruct.motionPolynomials(iModOut,3).rowPolyStatus = false ;
  end
  fpgDataStruct.fitPointingRefCadence = true ;
  try_to_catch_error_condition('a=fpgDataClass(fpgDataStruct); b = fpg_data_reformat(a) ;',...
      'ccdsForPointingConstraintEmpty', fpgDataStruct, 'fpgDataStruct' ) ;
  
% turn off ref cadence pointing, set all of cadence 1 bad except for mod 2 out 1, and make
% sure that fpg_data_reformat errors out due to no data to fit that cadence's pointing
% (ie, no overlap between good mod/outs on the ref cadence and on the specific cadence)
  
  fpgDataStruct.fitPointingRefCadence = false ;
  for iModOut = 2:84
      fpgDataStruct.motionPolynomials(iModOut,1).rowPolyStatus = false ;
  end
  try_to_catch_error_condition('a=fpgDataClass(fpgDataStruct); b = fpg_data_reformat(a) ;',...
      'noModOutsInFit', fpgDataStruct, 'fpgDataStruct' ) ;

% empty row or column grid values

  fpgDataStruct = fpgGoodDataStruct ;
  fpgDataStruct.rowGridValues = [] ;
  try_to_catch_error_condition('a=fpgDataClass(fpgDataStruct);',...
      'emptyGridValues', fpgDataStruct, 'fpgDataStruct' ) ;
  fpgDataStruct = fpgGoodDataStruct ;
  fpgDataStruct.columnGridValues = [] ;
  try_to_catch_error_condition('a=fpgDataClass(fpgDataStruct);',...
      'emptyGridValues', fpgDataStruct, 'fpgDataStruct' ) ;
  
% no fpgFitClass objects when trying to perform the fit

  fpgDataObject = fpgDataClass(fpgGoodDataStruct) ;
  try_to_catch_error_condition('a=update_fpg(fpgDataObject);',...
      'fpgFitObjectEmpty', fpgDataObject, 'fpgDataObject' ) ;
  
% errors with get member:  invalid member name

  try_to_catch_error_condition('a=get(fpgDataObject,''dummy'');' , ...
      'badFieldName', fpgDataObject, 'fpgDataObject') ;
      
% motionPolynomial mod/out lists not common across cadences

  fpgDataStruct = fpgGoodDataStruct ;
  fpgDataStruct.motionPolynomials(2,1) = fpgDataStruct.motionPolynomials(1,1) ;
  try_to_catch_error_condition('a=fpgDataClass(fpgDataStruct);',...
      'MotionPolynomialModOutsNotCommon', fpgDataStruct, 'fpgDataStruct' ) ;
  
% motion polynomials mod/out lists not unique across cadences
  
  for iCadence = 1:size(fpgDataStruct.motionPolynomials,2)
      fpgDataStruct.motionPolynomials(2,iCadence) = ...
          fpgDataStruct.motionPolynomials(1,iCadence) ;
  end
  try_to_catch_error_condition('a=fpgDataClass(fpgDataStruct);',...
      'MotionPolynomialModOutsNotUnique', fpgDataStruct, 'fpgDataStruct' ) ;  

%=========================================================================================
%
% fpgFitClass errors
%
%=========================================================================================

% load an fpgDataStruct which will instantiate correctly but hasn't been put through a fit
% yet; then instantiate it

  load(fullfile(testFileDir,'fpgFitTestStruct')) ;
  fpgFitTestStruct.raDec2PixObject = raDec2PixClass(rd2pm,'one-based') ;
  fpgFitTestObject = fpgFitClass(fpgFitTestStruct) ;

% fpg_chisq errors:  empty finalParValues or empty robustWeights

  try_to_catch_error_condition('[a,b]=fpg_chisq(fpgFitTestObject,0,0,0);', ...
      'finalParValues', fpgFitTestObject, 'fpgFitTestObject');
  try_to_catch_error_condition('[a,b]=fpg_chisq(fpgFitTestObject,1,0,1);', ...
      'robustWeights', fpgFitTestObject, 'fpgFitTestObject');
  
% errors with get member:  invalid member name

  try_to_catch_error_condition('a=get(fpgFitTestObject,''dummy'');' , ...
      'badFieldName', fpgFitTestObject, 'fpgFitTestObject') ;
  
% request use of final values which are not present

  try_to_catch_error_condition('a=set_raDec2Pix_geometry(fpgFitTestObject, 1);' , ...
      'noFinalValues', fpgFitTestObject, 'fpgFitTestObject') ;
  
% request to tweak parameter past end of initialParValues

  try_to_catch_error_condition('a=set_raDec2Pix_geometry(fpgFitTestObject,0,10000,1e-6);' , ...
      'argOutOfBounds', fpgFitTestObject, 'fpgFitTestObject') ;
  
%=========================================================================================
%
% fpgResultsClass errors
%
%=========================================================================================

% load a data structure and instantiate the fpgResultsClass object with it

  load(fullfile(testFileDir,'fpgTestResultsStruct')) ;
  fpgResultsObject = fpgResultsClass(fpgResultsStruct) ;
  
% errors with get member:  invalid member name

  try_to_catch_error_condition('a=get(fpgResultsObject,''dummy'');' , ...
      'badFieldName', fpgResultsObject, 'fpgResultsObject') ;
  
%=========================================================================================
%
% fpgResultsUserClass errors
%
%=========================================================================================

% instantiate an object from the fpgResultsStruct structure

  fpgResultsUserObject = fpgResultsUserClass(fpgResultsStruct) ;
  
% errors with get member:  invalid member name

  try_to_catch_error_condition('a=get(fpgResultsUserObject,''dummy'');' , ...
      'badFieldName', fpgResultsUserObject, 'fpgResultsUserObject') ;

% try to retrieve star information with bad magnitude ranges

  try_to_catch_error_condition( ...
      'a=retrieve_star_information_from_catalog(fpgResultsUserObject,6,5);', ...
      'magnitudeRange', fpgResultsUserObject, 'fpgResultsUserObject' ) ;
  
