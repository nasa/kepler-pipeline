function [self] = test_validate_missing_input(self)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% [self] = test_validate_missing_input(self)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% This test checks whether the class constructor catches the missing field and
% throws an error.  This test calls remove_field_and_test_for_failure.
%
%
%  Example
%  =======
%  Use a test runner to run the test method:
%      run(text_test_runner, fpgTestClass('test_validate_missing_input'));
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

% Define variables, (conditional) path and file names.

  quickAndDirtyCheckFlag = false ;

% figure out where we are running from (the FPG development laptop or a SOC workstation),
% and set the location of the test files accordingly:

  setup_fpg_paths_and_files ;

% get a good fpgDataStruct and use it to instantiate an fpgDataClass
  
  load(fullfile(testFileDir,'fpgTestDataStruct')) ;
  fpgDataObject = fpgDataClass(fpgDataStruct) ;

  
%=========================================================================================
%
% Top-level validation
%
%=========================================================================================

  validMjdString = ['[',num2str(fpgDataStruct.mjdLongCadence(:)'),']'] ;

  fieldsAndBounds = cell(14,4) ; % don't validate the optional inputs!

  fieldsAndBounds(1,: ) = { 'mjdLongCadence' ; '>54500' ; '<58200' ; [] } ; % early 2008 to early 2018
  fieldsAndBounds(2,:)  = { 'excludedModules' ; [] ; [] ; [] } ;
  fieldsAndBounds(3,:)  = { 'excludedOutputs' ; [] ; [] ; [] } ;
  fieldsAndBounds(4,:)  = { 'rowGridValues' ; '>19.5' ; '<1043.5' ; [] } ;
  fieldsAndBounds(5,:)  = { 'columnGridValues' ; '>11.5' ; '<1111.5' ; [] } ;
  fieldsAndBounds(6,:)  = { 'mjdRefCadence' ; [] ; [] ; validMjdString } ;
  fieldsAndBounds(7,:)  = { 'fitPlateScaleFlag' ; [] ; [] ; '[true false]' } ;
  fieldsAndBounds(8,:)  = { 'tolX' ; '<1e-3' ; '>1e-20' ; [] } ;
  fieldsAndBounds(9,:)  = { 'tolFun' ; '<1e-3' ; '>1e-20' ; [] } ;
  fieldsAndBounds(10,:) = { 'tolSigma' ; '<1' ; '>1e-8' ; [] } ;
  fieldsAndBounds(11,:) = { 'doRobustFit' ; [] ; [] ; '[true false]' } ;
  fieldsAndBounds(12,:) = { 'fcConstants' ; [] ; [] ; [] } ;
  fieldsAndBounds(13,:) = { 'raDec2PixModel' ; [] ; [] ; [] } ;
  fieldsAndBounds(14,:) = { 'motionPolynomials' ; [] ; [] ; [] } ;


  remove_field_and_test_for_failure(fpgDataStruct, 'fpgDataStruct', fpgDataStruct, ...
    'fpgDataStruct', 'fpgDataClass', fieldsAndBounds, quickAndDirtyCheckFlag);

  clear fieldsAndBounds

%=========================================================================================
%
% motionPolynomials validation
%
%=========================================================================================

  fieldsAndBounds = cell(7,4) ;
  fieldsAndBounds(1,:) = {'mjdMidTime' ; [] ; [] ; [] } ;
  fieldsAndBounds(2,:) = {'module' ; [] ; [] ; [] } ;
  fieldsAndBounds(3,:) = {'output' ; [] ; [] ; [] } ;
  fieldsAndBounds(4,:) = {'rowPoly' ; [] ; [] ; [] } ;
  fieldsAndBounds(5,:) = {'rowPolyStatus' ; [] ; [] ; [] } ;
  fieldsAndBounds(6,:) = {'colPoly' ; [] ; [] ; [] } ;
  fieldsAndBounds(7,:) = {'colPolyStatus' ; [] ; [] ; [] } ;
  
  remove_field_and_test_for_failure(fpgDataStruct.motionPolynomials, ...
      'fpgDataStruct.motionPolynomials', fpgDataStruct, 'fpgDataStruct', ...
      'fpgDataClass', fieldsAndBounds, quickAndDirtyCheckFlag);
  
  clear fieldsAndBounds ;
  
% now for testing the row and column polynomials themselves.  This is complicated by the
% fact that the row/column polynomial is itself a structure, so we have the nested
% structure problem in Matlab:  when you have a(i,j).b, and b is a structure, the fields
% of b are not required to be the same across all i,j (ie, a(1,1).b.c and a(1,2).b.d is
% legal).  So here is how we are going to do this validation:
%
%     step 1:  remove each field in turn from one polynomial, and trap the resulting error
%        (attempt to concatenate dissimilar structures).
%     step 2:  remove each field in turn from all polynomials, and verify that
%        check_poly2d_struct does the right thing.

  motionPolynomialFields = {'coeffs' ; 'covariance' ; 'order' ; 'type' ; 'offsetx' ; ...
      'scalex' ; 'originx' ; 'offsety' ; 'scaley' ; 'originy' ; 'xindex' ; 'yindex' ; ...
      'message'} ;

  for iField = 1:length(motionPolynomialFields)
      fpgDataStructFail = fpgDataStruct ;
      fpgDataStructFail.motionPolynomials(1,1).rowPoly = rmfield( ...
          fpgDataStructFail.motionPolynomials(1,1).rowPoly,motionPolynomialFields{iField}) ;
      try_to_catch_error_condition('a=fpgDataClass(fpgDataStruct)','structFieldBad', ...
          fpgDataStructFail,'fpgDataStruct') ;
  end
  
  nChannels = size(fpgDataStruct.motionPolynomials,1) ;
  nCadences = size(fpgDataStruct.motionPolynomials,2) ;
  rowPoly = [fpgDataStruct.motionPolynomials.rowPoly] ;
  rowPoly = reshape(rowPoly,nChannels,nCadences) ;
  colPoly = [fpgDataStruct.motionPolynomials.colPoly] ;
  colPoly = reshape(colPoly,nChannels,nCadences) ;
  
  for iField = 1:length(motionPolynomialFields)
      
      rowPolyFail = rmfield(rowPoly,motionPolynomialFields{iField}) ;
      colPolyFail = rmfield(colPoly,motionPolynomialFields{iField}) ;
      fpgDataStructFail = fpgDataStruct ;
      for iChannel = 1:nChannels
          for iCadence = 1:nCadences
              fpgDataStructFail.motionPolynomials(iChannel,iCadence).rowPoly = ...
                  rowPolyFail(iChannel,iCadence) ;
              fpgDataStructFail.motionPolynomials(iChannel,iCadence).colPoly = ...
                  colPolyFail(iChannel,iCadence) ;
          end
      end
      try_to_catch_error_condition('a=fpgDataClass(fpgDataStruct)',...
          motionPolynomialFields{iField}, fpgDataStructFail,'fpgDataStruct') ;
      
  end
  
% and that's it for testing that the input fields are correctly validated!

%
%
%

     
