function [self] = test_validate_bad_inputs(self)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [self] = test_validate_bad_inputs(self)
%
% This function tests the fpgDataClass constructor with all possible out-of-range inputs,
%    and ensures that the class constructor's range verification logic is functioning
%    properly.
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
%     2008-October-06, PT:
%         change excludedModules and excludedOutputs test to match current validation
%         scheme in fpgDataClass constructor.
%     2008-September-19, PT:
%         change row and column coordinates to be one-based.
%     2008-September-18, PT:
%         allow maxBadDataCutoff to be == 1.
%     2008-September-14, PT:
%         support for maxBadDataCutoff parameter.
%     2008-September-07, PT:
%         update file name of fpgTestDataStruct.
%     2008-July-30, PT:
%         test whether invalid fitPointingRefCadence value is trapped.
%     2008-July-27, PT:
%         cleanup any copied ephemeris files at end of execution.
%     2008-July-18, PT:
%         use setup_fpg_paths_and_files instead of local code block for same purpose.
%     2008-July-18, PT:
%         test against unacceptable pointing values.
%     2008-July-11, PT:
%         test motion polynomial validation on 1 cadence, 1 mod/out only, and pick one
%         near the center of the loop range.  Ditto for pixelTimeSeries validation.
%     2008-july-09, PT:
%         validate min/max magnitude plot values (min <= max required).  Changes to
%         validation of starSkyCoordinates based on new definitions.
%
%=========================================================================================

% Define variables, (conditional) path and file names.

  quickAndDirtyCheckFlag = false ;

% figure out where we are running from (the FPG development laptop or a SOC workstation),
% and set the location of the test files accordingly:

  setup_fpg_paths_and_files ;

% get a good fpgDataStruct and use it to instantiate an fpgDataClass
  
  load(fullfile(testFileDir,'fpgTestDataStruct')) ;
  fpgDataObject = fpgDataClass(fpgDataStruct) ;
  if (~isfield(fpgDataStruct,'fitPointingRefCadence'))
      fpgDataStruct.fitPointingRefCadence = false ;
  end
  if (~isfield(fpgDataStruct,'maxBadDataCutoff'))
      fpgDataStruct.maxBadDataCutoff = 0.1 ;
  end
    
% define the limits which are dependent on data which comes in with the fpgDataStruct  

  validMjdString = ['[',num2str(fpgDataStruct.mjdLongCadence(:)'),']'] ;
  validModuleString = ['[',num2str(fpgDataStruct.fcConstants.modulesList'),']'] ;
  validOutputString = ['[',num2str(1:fpgDataStruct.fcConstants.nOutputsPerModule),']'] ;
  
  minRow = fpgDataStruct.fcConstants.MASKED_SMEAR_END + 0.5 + 1;
  maxRow = fpgDataStruct.fcConstants.VIRTUAL_SMEAR_START - 0.5 + 1;
  minRowString = ['>=',num2str(minRow)] ;
  maxRowString = ['<=',num2str(maxRow)] ;
  minCol = fpgDataStruct.fcConstants.LEADING_BLACK_END + 0.5 + 1;
  maxCol = fpgDataStruct.fcConstants.TRAILING_BLACK_START - 0.5 + 1;
  minColString = ['>=',num2str(minCol)] ;
  maxColString = ['<=',num2str(maxCol)] ;
  
%=========================================================================================
%
% Top-level range validation
%
%=========================================================================================

  fieldsAndBounds = cell(12,4) ;
  fieldsAndBounds(1,: ) = { 'mjdLongCadence' ; '>54500' ; '<58200' ; [] } ; % early 2008 to early 2018
  fieldsAndBounds(2,:)  = { 'rowGridValues' ; minRowString ; maxRowString ; [] } ;
  fieldsAndBounds(3,:)  = { 'columnGridValues' ; minColString ; maxColString ; [] } ;
  fieldsAndBounds(4,:)  = { 'fitPlateScaleFlag' ; [] ; [] ; '[true false]' } ;
  fieldsAndBounds(5,:)  = { 'tolX' ; '>1e-20' ; '<1e-3' ; [] } ;
  fieldsAndBounds(6,:)  = { 'tolFun' ; '>1e-20' ; '<1e-3' ; [] } ;
  fieldsAndBounds(7,:)  = { 'tolSigma' ; '>1e-8' ; '<1' ; [] } ;
  fieldsAndBounds(8,:)  = { 'doRobustFit' ; [] ; [] ; '[true false]' } ;
%  fieldsAndBounds(9,:)  = { 'excludedModules' ; [] ; [] ; validModuleString } ;
%  fieldsAndBounds(10,:) = { 'excludedOutputs' ; [] ; [] ; validOutputString } ;
  fieldsAndBounds(9,:) = { 'mjdRefCadence' ; [] ; [] ; validMjdString } ;
  fieldsAndBounds(10,:) = { 'fitPointingRefCadence' ; [] ; [] ; '[true false]' } ;
  fieldsAndBounds(11,:) = { 'maxBadDataCutoff' ; '>=0' ; '<=1' ; [] } ;
  fieldsAndBounds(12,:)  = { 'reportGenerationEnabled' ; [] ; [] ; '[true false]' } ;

  assign_illegal_value_and_test_for_failure(fpgDataStruct, 'fpgDataStruct', ...
    fpgDataStruct, 'fpgDataStruct', 'fpgDataClass', fieldsAndBounds, ...
    quickAndDirtyCheckFlag);

  clear fieldsAndBounds
  
% We'll get the error for bad pointing on the reference cadence to throw here,
% since it's throwing an error on bad input values rather than a general-purpose error

  try_to_catch_error_condition(...
      'fpgDataStruct.pointingRefCadence=[0;0;0];a=fpgDataClass(fpgDataStruct)',...
      'invalidPointing', fpgDataStruct, 'fpgDataStruct' ) ;

% similarly, exercise the error-throw for bad modules / outputs here

  try_to_catch_error_condition(...
      'fpgDataStruct.excludedModules=0;a=fpgDataClass(fpgDataStruct)',...
      'invalidModuleNumbers', fpgDataStruct, 'fpgDataStruct' ) ;
   try_to_catch_error_condition(...
      'fpgDataStruct.excludedModules=NaN;a=fpgDataClass(fpgDataStruct)',...
      'invalidModuleNumbers', fpgDataStruct, 'fpgDataStruct' ) ;
  try_to_catch_error_condition(...
      'fpgDataStruct.excludedModules=Inf;a=fpgDataClass(fpgDataStruct)',...
      'invalidModuleNumbers', fpgDataStruct, 'fpgDataStruct' ) ;
 
  try_to_catch_error_condition(...
      'fpgDataStruct.excludedOutputs=0;a=fpgDataClass(fpgDataStruct)',...
      'invalidOutputNumbers', fpgDataStruct, 'fpgDataStruct' ) ;
   try_to_catch_error_condition(...
      'fpgDataStruct.excludedOutputs=NaN;a=fpgDataClass(fpgDataStruct)',...
      'invalidOutputNumbers', fpgDataStruct, 'fpgDataStruct' ) ;
  try_to_catch_error_condition(...
      'fpgDataStruct.excludedOutputs=Inf;a=fpgDataClass(fpgDataStruct)',...
      'invalidOutputNumbers', fpgDataStruct, 'fpgDataStruct' ) ;
 

%=========================================================================================
%
% motionPolynomials range validation
%
%=========================================================================================
  
% here we need two sets of fields and bounds cell arrays:  one for the fields of
% motionPolynomials, and one for the fields of the rowPoly / colPoly structures

  fieldsAndBoundsUpper = cell(5,4) ;
  fieldsAndBoundsUpper(1,:) = { 'mjdMidTime' ; [] ; [] ; validMjdString } ;
  fieldsAndBoundsUpper(2,:) = {'module' ; [] ; [] ; validModuleString } ;
  fieldsAndBoundsUpper(3,:) = {'output' ; [] ; [] ; validOutputString } ;
  fieldsAndBoundsUpper(4,:) = {'rowPolyStatus' ; [] ; [] ; '[true false]' } ;
  fieldsAndBoundsUpper(5,:) = {'colPolyStatus' ; [] ; [] ; '[true false]' } ;
  
  fieldsAndBoundsLower = cell(12,4) ;
  fieldsAndBoundsLower(1,:)  = {'offsetx' ; '>=-1e12' ; '<=1e12' ; [] } ;
  fieldsAndBoundsLower(2,:)  = {'scalex' ; '>=-1e12' ; '<=1e12' ; [] } ;
  fieldsAndBoundsLower(3,:)  = {'originx' ; '>=-1e12' ; '<=1e12' ; [] } ;
  fieldsAndBoundsLower(4,:)  = {'offsety' ; '>=-1e12' ; '<=1e12' ; [] } ;
  fieldsAndBoundsLower(5,:)  = {'scaley' ; '>=-1e12' ; '<=1e12' ; [] } ;
  fieldsAndBoundsLower(6,:)  = {'originy' ; '>=-1e12' ; '<=1e12' ; [] } ;
  fieldsAndBoundsLower(7,:)  = {'xindex' ; '>=-1' ; '<=4' ; [] } ;
  fieldsAndBoundsLower(8,:)  = {'yindex' ; '>=-1' ; '<=4' ; [] } ;
  fieldsAndBoundsLower(9,:)  = {'order' ; '>=0' ; '<=1e4' ; [] } ;
  fieldsAndBoundsLower(10,:) = {'coeffs' ; '>=-1e12' ; '<=1e12' ; [] } ;
  fieldsAndBoundsLower(11,:) = {'covariance' ; '>=-1e12' ; '<=1e12' ; [] } ;
  fieldsAndBoundsLower(12,:) = {'type' ; [] ; [] ; {'standard'} } ;

% loop over motion polynomials

% testing that the validation works for all 840 polynomials would be excessively time
% consuming, but we want to be sure that the validation doesn't just work on some subset
% of polynomials (for example, the first cadence, or the first mod / out, or just the row
% polynomials).  We will ensure that the validation code works right by testing it on a
% single entry in motionPolynomials, selected to be near the center of the matrix in both
% cadence and mod/out dimensions.

  nCadences = size(fpgDataStruct.motionPolynomials,2) ;
  nModOuts  = size(fpgDataStruct.motionPolynomials,1) ;
  
  centerCadence = ceil(nCadences/2) ;
  centerModOut = ceil(nModOuts/2) ;
  testIndices = [(centerCadence-1)*nModOuts + centerModOut] ;  
  
% convert the testIndices to a list of cadences and channels

  channelList = mod(testIndices,nModOuts) + 1 
  cadenceList = ceil(testIndices/nModOuts) 
  
%  for iCadence = 1:size(fpgDataStruct.motionPolynomials,2)
%      for iChannel = 1:size(fpgDataStruct.motionPolynomials,1)

  for iPoly = 1:length(testIndices)
      
      iChannel = channelList(iPoly) ;
      iCadence = cadenceList(iPoly) ;
          
%    display what's going on only for the first MP that gets tested, and suppress
%    messages on all subsequent motion polynomials 
          
      if ( iPoly==1 )
          suppressDisplayFlag = false;
      else
          suppressDisplayFlag = true;
      end
          
%     perform the range check on the fields of motionPolynomial
          
      lowLevelStructName =  ['fpgDataStruct.motionPolynomials('...
          num2str(iChannel),',' num2str(iCadence), ')'];

      assign_illegal_value_and_test_for_failure(fpgDataStruct.motionPolynomials(iChannel,iCadence), ...
          lowLevelStructName, fpgDataStruct, 'fpgDataStruct', 'fpgDataClass', ...
          fieldsAndBoundsUpper, quickAndDirtyCheckFlag, suppressDisplayFlag);
          
%     perform the check on rowPoly and colPoly

      lowLevelStructName =  ['fpgDataStruct.motionPolynomials('...
          num2str(iChannel),',' num2str(iCadence), ').rowPoly'];

      assign_illegal_value_and_test_for_failure(...
          fpgDataStruct.motionPolynomials(iChannel,iCadence).rowPoly, ...
          lowLevelStructName, fpgDataStruct, 'fpgDataStruct', 'fpgDataClass', ...
          fieldsAndBoundsLower, quickAndDirtyCheckFlag, suppressDisplayFlag);

      lowLevelStructName =  ['fpgDataStruct.motionPolynomials('...
          num2str(iChannel),',' num2str(iCadence), ').colPoly'];

      assign_illegal_value_and_test_for_failure(...
          fpgDataStruct.motionPolynomials(iChannel,iCadence).colPoly, ...
          lowLevelStructName, fpgDataStruct, 'fpgDataStruct', 'fpgDataClass', ...
          fieldsAndBoundsLower, quickAndDirtyCheckFlag, suppressDisplayFlag);
          
%     finally, we test to make sure that the two alternate types of 2d weighted
%     polynomials -- legendre and not_scaled -- are not accepted.  Since the standard
%     text-field value test is to put nonsense into the test string, that test is
%     necessary but not sufficient to demonstrate that you can't inadvertantly pass a
%     not_scaled or legendre polynomial to fpgDataClass.  We'll do this test by hand:

      test_motion_polynomial_type_failure( fpgDataStruct, iChannel, iCadence, ...
          'rowPoly', suppressDisplayFlag ) ;
      test_motion_polynomial_type_failure( fpgDataStruct, iChannel, iCadence, ...
          'colPoly', suppressDisplayFlag ) ;

      if ( iPoly==1 )
          fprintf('\n ... testing additional motion polynomials... \n') ;
      end

  end % loop over randomly-tested motion polynomials 
  
%      end % loop over channels
%  end     % loop over cadences

  clear fieldsAndBoundsUpper ;
  clear fieldsAndBoundsLower ;
  
% and that's it!

%
%
%
  
  
%=========================================================================================
%=========================================================================================
%=========================================================================================
  
% function which assigns the not-acceptable but valid 2-d polynomial types to a given
% polynomial and detects that an appropriate failure has occurred

function test_motion_polynomial_type_failure( fpgDataStruct, iChannel, iCadence, polyType, ...
    suppressDisplayFlag)

% define the not-acceptable but valid field values

  typeFieldValue = {'legendre' ; 'not_scaled'} ;
  
% loop over type values

  for iType = 1:length(typeFieldValue)
      
%     assign the specified type value in the specified location and see if the desired
%     error occurs when the fpgDataClass tries to validate
      
      fpgDataStruct.motionPolynomials(iChannel,iCadence).(polyType) = ...
          setfield(fpgDataStruct.motionPolynomials(iChannel,iCadence).(polyType), 'type', ...
          typeFieldValue{iType}) ;
      
      errorDetected = 0 ;
      try
          a = fpgDataClass(fpgDataStruct) ;
      catch
          errorDetected = 1 ;
          err = lasterror ;
          startIndex = regexp(err.message,'\n');
          if(~suppressDisplayFlag)
              fprintf(['\n\t\t' err.message(startIndex+1:end) ]);
          end
          if (isempty(findstr(err.identifier,'type')))
              assert_equals('type',err.identifier,'Wrong type of error thrown!') ;
          end
      end
      if (errorDetected == 0)
          assert_equals(1,0,'Validation failed to catch the error.') ;
      end
      
  end
  
% and that's it!

%
%
%
