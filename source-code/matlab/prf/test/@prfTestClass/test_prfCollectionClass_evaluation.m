function self = test_prfCollectionClass_evaluation( self )
%
% test_prfCollectionClass_evaluation -- test prfCollectionClass features related to the
% evaluate method.
%
% This is a unit test of the prfCollectionClass which tests the following features:
%
% ==> The find_triangle method finds the correct triangle for an assortment of points.
% ==> The find_triangle method raises an error if the selected point is not on the mod/out
%     viewable area.
% ==> The evaluate method correctly performs triangular interpolation between assorted
%     PRFs.
%
% This unit test is intended to operate in the mlunit context.  To execute it, use the
% following command-line syntax:
%
%     run(text_test_runner, prfTestClass('test_prfCollectionClass_evaluation')) ;
%
% Version date:  2010-August-17.
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
%     2010-August-17, PT:
%         remove unneeded cleanup block at end.
%     2008-October-22, PT:
%         change to catching the warning when out-of-bounds point is put into
%         find_triangle (no longer an error).
%     2008-September-29, PT:
%         switch to use of fcConstants as argument in constructor.  Add cleanup.
%     2008-September-10, PT:
%         use the default range of the PRFs for the evaluation rather than specifying one
%         ourselves.
%
%=========================================================================================

% set the path for the PRF data files

  setup_prf_paths ;
  
% load a single PRF (selected at random)

  load(fullfile(testDataDir,'prfCoefficientMatrices')) ;
  clear coefficientMatrix2 coefficientMatrix3 coefficientMatrix4 coefficientMatrix5 ;
  
  load(fullfile(testDataDir,'fcConstants')) ;

% produce the following scaled PRFs:  a PRF which is -1 * the one loaded, a PRF which is
% 0.5 * the one loaded, a PRF which is zero.

  coefficientMatrix2 = coefficientMatrix1 * -1 ;
  coefficientMatrix3 = coefficientMatrix1 * 0.5 ;
  coefficientMatrix4 = coefficientMatrix1 * 0 ;
  
% instantiate and assign the PRFs as follows:
%    corner 1 gets the original
%    corner 2 gets the negative
%    corner 3 gets the 1/2-scale
%    corner 4 gets the original
%    center gets the zero.

  prfObject1 = prfClass(coefficientMatrix1) ;
  prfObject2 = prfClass(coefficientMatrix2) ;
  prfObject3 = prfClass(coefficientMatrix3) ;
  prfObject4 = prfClass(coefficientMatrix4) ;
  
  prfCollectionObject = prfCollectionClass(...
      [prfObject1 ; prfObject2 ; prfObject3 ; prfObject1 ; prfObject4] , ...
      fcConstants ) ;
  
%=========================================================================================
%
% Triangle finding test
%
%=========================================================================================

% Test 1 -- make sure that points which are supposed to be in each triangle actually are!

  [triangle,r,c] = find_triangle( prfCollectionObject, 500, 100 ) ;
  assert_equals(triangle, 1, ...
      'Triangle 1 finding test failed!') ;
  [triangle,r,c] = find_triangle( prfCollectionObject, 1000, 500 ) ;
  assert_equals(triangle, 2, ...
      'Triangle 2 finding test failed!') ;
  [triangle,r,c] = find_triangle( prfCollectionObject, 500, 1000 ) ;
  assert_equals(triangle, 3, ...
      'Triangle 3 finding test failed!') ;
  [triangle,r,c] = find_triangle( prfCollectionObject, 100, 500 ) ;
  assert_equals(triangle, 4, ...
      'Triangle 4 finding test failed!') ;
  
% generate 1000 points at random which are within the range of the prfCollectionClass object
% and make sure they are all successfully found to be in one triangle or another (ie, the
% error exit in find_triangle is never exercised == success).

  nTriangleTry = 1000 ;
  rowRandom = 20.5 + 1024 * rand(nTriangleTry,1) ;
  colRandom = 12.5 + 1100 * rand(nTriangleTry,1) ;
  
  for iTriangle = 1:nTriangleTry
      [t,r,c] = find_triangle( prfCollectionObject, rowRandom(iTriangle), ...
          colRandom(iTriangle) ) ;
  end
  
% throw some points which are supposed to be outside of the viewable area and make sure
% that an appropriate warning is raised

  [t,r,c] = find_triangle( prfCollectionObject, 500, 12 ) ;
  lastWarnMsg = lastwarn ;
  assert_equals(lastwarn, ...
  'find_triangle: specified point (row==500.000000, column==12.000000) is not within any triangle', ...
  'Wrong / no warning at row == 500, column == 12') ;
  [t,r,c] = find_triangle( prfCollectionObject, 1045, 500 ) ;
  assert_equals(lastwarn, ...
  'find_triangle: specified point (row==1045.000000, column==500.000000) is not within any triangle', ...
  'Wrong / no warning at row == 1045, column == 500') ;
  [t,r,c] = find_triangle( prfCollectionObject, 500, 1113 ) ;
  assert_equals(lastwarn, ...
  'find_triangle: specified point (row==500.000000, column==1113.000000) is not within any triangle', ...
  'Wrong / no warning at row == 500, column == 1113') ;
  [t,r,c] = find_triangle( prfCollectionObject, 20, 500 ) ;
  assert_equals(lastwarn, ...
  'find_triangle: specified point (row==20.000000, column==500.000000) is not within any triangle', ...
  'Wrong / no warning at row == 20, column == 500') ;

%=========================================================================================
%
% PRF interpolation test
%
%=========================================================================================

% select the rows and columns for prfObject 1 as a comparison case, and set the tolerance

  tolerance = 1e-3 ;
  
% evaluate the PRF right at corner 1 -- it should be within a fairly tight tolerance of
% being identical to the results for PRF 1
  
  [prfReference,r,c] = evaluate( prfObject1, 505.51, 505.51 ) ;
  [prfCorner1,r,c] = evaluate( prfCollectionObject, 20.51, 12.51 ) ;
  
  prfDiff = prfReference - prfCorner1 ;
  assert( isempty( find(abs(prfDiff)>tolerance, 1) ), ...
      'PRF in corner 1 outside of tolerance!' ) ;
  
% right at corner 2 it should be very close to the opposite of what it is in corner 1

  [prfReference,r,c] = evaluate( prfObject1, 506.49, 505.51 ) ;
  [prfCorner2,r,c] = evaluate( prfCollectionObject, 1044.49, 12.51 ) ;
  
  prfSum = prfReference + prfCorner2 ;
  assert( isempty( find(abs(prfSum)>tolerance, 1) ), ...
      'PRF in corner 2 outside of tolerance!' ) ;
  
% right at corner 3 it should be very close to half of what it is in corner 1

  [prfReference,r,c] = evaluate( prfObject1, 506.49, 506.49 ) ;
  [prfCorner3,r,c] = evaluate( prfCollectionObject, 1044.49, 1112.49 ) ;
  
  prfDiff = 0.5 * prfReference - prfCorner3 ;
  assert( isempty( find(abs(prfDiff)>tolerance, 1) ), ...
      'PRF in corner 2 outside of tolerance!' ) ;
  
% and at corner 4 it should be again close to the corner 1 value

  [prfReference,r,c] = evaluate( prfObject1, 505.51, 506.49 ) ;
  [prfCorner4,r,c] = evaluate( prfCollectionObject, 20.51, 1112.49 ) ;
  
  prfDiff = prfReference - prfCorner4 ;
  assert( isempty( find(abs(prfDiff)>tolerance, 1) ), ...
      'PRF in corner 4 outside of tolerance!' ) ;
  
% In the center it should be close to zero

  [prfCenter,r,c] = evaluate( prfCollectionObject, 532.51, 562.49 ) ;
  prfNZIndex = find(prfReference ~= 0) ;
  prfRatio = prfCenter(prfNZIndex)./prfReference(prfNZIndex) ;
  assert( isempty( find(abs(prfRatio)>tolerance, 1) ), ...
      'PRF in center outside of tolerance!' ) ;

% at the boundary between corners 1 and 2 it should be close to zero

  [prfReference,r,c] = evaluate( prfObject1, 505.51, 505.51 ) ;
  [prfBoundary12,r,c] = evaluate( prfCollectionObject, 532.51, 12.51 ) ;
  prfNZIndex = find(prfReference ~= 0) ;
  prfRatio = prfBoundary12(prfNZIndex)./prfReference(prfNZIndex) ;
  assert( isempty( find(abs(prfRatio)>tolerance, 1) ), ...
      'PRF on line between points 1 and 2 outside of tolerance!' ) ;

% at the midpoint of the line betwen point 1 and the center it should be half of normal

  [prfBoundary1c,r,c] = evaluate( prfCollectionObject, 276.51, 287.51 ) ;
  prfRatio = prfBoundary1c(prfNZIndex)./prfReference(prfNZIndex) ;
  ratioDiff = prfRatio - 0.5 ;
  assert( isempty( find(abs(ratioDiff)>tolerance, 1) ), ...
      'PRF on line between points 1 and 2 outside of tolerance!' ) ;

% If we now drop down so that the row coordinate is halfway between the 1-c and 1-4 lines,
% and the col coordinate is still the same as above, the interpolation should increase to
% 3/4 of the original PRF

  [prf14c,r,c] = evaluate( prfCollectionObject, 148.51, 287.51 ) ;
  prfNZIndex = find(prfReference ~= 0) ;
  prfRatio = prf14c(prfNZIndex)./prfReference(prfNZIndex) ;
  ratioDiff = prfRatio - 0.75 ;
  assert( isempty( find(abs(ratioDiff)>tolerance, 1) ), ...
      'PRF within triangle 14c outside of tolerance!' ) ;

% final test -- make sure that the feature to take a different range works correctly

  nPixelsToCheck = 30 ;
  rowRangeUser = r(1:nPixelsToCheck) ; columnRangeUser = c(1:nPixelsToCheck) ;
  [prf14c2,r2,c2] = evaluate( prfCollectionObject, 148.51, 287.51, rowRangeUser, ...
      columnRangeUser ) ;
  assert_equals(prf14c2,prf14c(1:nPixelsToCheck), ...
      'User-range in prfCollectionClass evaluate produces incorrect values!') ;
  
% and that's it!

%
%
%

