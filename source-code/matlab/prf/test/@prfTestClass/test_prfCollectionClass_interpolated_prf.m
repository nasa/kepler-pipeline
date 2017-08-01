function self = test_prfCollectionClass_interpolated_prf( self )
%
% test_prfCollectionClass_interpolated_prf -- test the prfCollectionClass method
% get_interpolated_prf, which returns a PRF from a prfCollectionClass object which has
% been interpolated to a selected location.
%
% Specifically, this test verifies the following:
%
% ==> The get_interpolated_prf method returns a prfClass object.
% ==> at the point at which the prfClass object is produced, the prfClass object and the
%     original prfCollectionClass object agree to within a tight tolerance (the tolerance
%     is currently set to 2e-7 -- that is, the make_array of the prfClass object and the
%     make_array of the prfCollectionClass object produce arrays for which the maximum
%     difference between the arrays is 2e-7).
% ==> For a point which is 1 row or 1 column off of the point at which the prfClass object
%     was generated, the prfClass object and prfCollectionClass object agree to within a
%     somewhat looser tolerance (currently set to 2e-3).
% ==> The get_interpolated_prf method returns an interpolated PRF when it is called with
%     the alternate interpolation method (interpolation of the 2-D polynomials themselves,
%     rather than just the prfClass coefficientMatrix).
% ==> The second interpolation method produces a prfClass object which is extremely close
%     to identical to the first method (tolerance here is set to 3e-12 on the coefficient
%     matrices).
% ==> The second method produces non-blank polynomials in its prfClass object.
% ==> The first method produces blank polynomials in its prfClass object.
%
% This is a unit test which is intended to run in the context of mlunit; to execute it,
% use the following syntax:
%
%     run(text_test_runner, prfTestClass('test_prfCollectionClass_interpolated_prf')) ;
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
%         remove reference to obsolete ephemeris cleanup procedure.
%     2008-October-10, PT:
%         test that a point which is just outside the viewable results in an
%         interpolation using the coordinates on the boundray of the viewable.
%     2008-October-02, PT:
%         add tests of the interpolate-polynomial method.
%     2008-September-29, PT:
%         add cleanup.
%     2008-September-24, PT:
%         update file used for test.
%
%=========================================================================================

% set the path for the PRF data files

  setup_prf_paths ;
  load(fullfile(testDataDir,'fcConstants')) ;
  
% load the data file for a prfCollectionClass, and instantiate it

  load(fullfile(testDataDir,'prfCollectionStruct_polyStruct')) ;
  prfCollectionObject = prfCollectionClass(prfCollectionStruct,fcConstants) ;
  
% generate the center positions for generation of an interpolated PRF -- the first four
% should be near the centers of the 4 triangles of the mod/out

  row = [500 750 500 250] ; col = [250 500 750 500] ;
  
% the next group should be randomly generated around the mod/out

  nRandomCenters = 4 ;
  rowRandom = 21 + 1023*rand(1,nRandomCenters) ;
  colRandom = 13 + 1099*rand(1,nRandomCenters) ;
  row = [row rowRandom] ; col = [col colRandom] ;
  arrayResolution = 200 ;
  
% set error tolerances: 2e-7 for where we compare 2 arrays at the same location, 2e-3 for
% where they are 1 pixel off
  
  arrayTolerance = [2e-7 2e-3 2e-3] ;
  
% set the tolerance for the coefficient matrix agreement

  coeffMatrixTolerance = 3e-12 ;
  
  norm2Error = zeros(length(row),3) ;
  maxError   = zeros(length(row),3) ;
  
% loop over selected points

  for iPoint = 1:length(row)
      
%     make an interpolated PRF at the point of interest and get its array out

      interpolatedPrf = get_interpolated_prf( prfCollectionObject, row(iPoint), ...
          col(iPoint) ) ;
      interpolatedArray = make_array(interpolatedPrf,arrayResolution) ;
      
%     make an array from the prfCollectionClass object at the point of interest

      collectionArray1 = make_array( prfCollectionObject, row(iPoint), col(iPoint), ...
          arrayResolution ) ;
      
%     get the errors and put into the arrays

      [norm2Error(iPoint,1),maxError(iPoint,1)] = compute_prf_array_error( ...
          collectionArray1, interpolatedArray, 1 ) ;
      
%     repeat for points which are 1 row and 1 col off

      collectionArray2 = make_array( prfCollectionObject, row(iPoint)+1, col(iPoint), ...
          arrayResolution ) ;
      [norm2Error(iPoint,2),maxError(iPoint,2)] = compute_prf_array_error( ...
          collectionArray2, interpolatedArray, 1 ) ;
      collectionArray3 = make_array( prfCollectionObject, row(iPoint), col(iPoint)+1, ...
          arrayResolution ) ;
      [norm2Error(iPoint,3),maxError(iPoint,3)] = compute_prf_array_error( ...
          collectionArray3, interpolatedArray, 1 ) ;
      
%     make a second prfClass object using interpolation of the polynomials themselves

      interpolatedPrf2 = get_interpolated_prf( prfCollectionObject, row(iPoint), ...
          col(iPoint), 1 ) ;
      
%     compare the coefficient matrices

      coeffMatrix  = get(interpolatedPrf,  'coefficientMatrix') ;
      coeffMatrix2 = get(interpolatedPrf2, 'coefficientMatrix') ;
      
%     make sure they agree with one another      
      
      mlunit_assert( all( abs(coeffMatrix(:)-coeffMatrix2(:)) <= coeffMatrixTolerance ), ...
          'coefficient matrices do not agree to within tolerance' ) ;
      
%     the first interpolated PRF should have an empty polyStruct method, the second should
%     not

      polyStruct  = get(interpolatedPrf,  'polyStruct') ;
      polyStruct2 = get(interpolatedPrf2, 'polyStruct') ;
      mlunit_assert( isempty(polyStruct), ...
          'polyStruct not empty' ) ;
      mlunit_assert( ~isempty(polyStruct2), ...
          'polyStruct2 is empty' ) ;

  end
  
% display the errors

  norm2Error
  maxError
  
% display the coordinates

  row
  col
  
% check against the tolerances

  mlunit_assert( all(max(norm2Error) <= arrayTolerance), ...
      'norm2Error out of tolerance in test_prfCollectionClass_interpolated_prf' ) ;
  mlunit_assert( all(max(maxError) <= arrayTolerance), ...
      'maxError out of tolerance in test_prfCollectionClass_interpolated_prf' ) ;

% verify that an interpolated PRF which is slightly outside of the range of the viewable
% silicon works, and that it is identical to one which is just barely in the acceptable
% area

  prfObjectOutside = get_interpolated_prf( prfCollectionObject, 20, 500 ) ;
  prfObjectInside  = get_interpolated_prf( prfCollectionObject, 20.5, 500 ) ;
  assert_equals( prfObjectOutside, prfObjectInside, ...
      'First inside/outside object interpolation test fails' ) ;
  
  prfObjectOutside = get_interpolated_prf( prfCollectionObject, 500, 12 ) ;
  prfObjectInside  = get_interpolated_prf( prfCollectionObject, 500, 12.5 ) ;
  assert_equals( prfObjectOutside, prfObjectInside, ...
      'Second inside/outside object interpolation test fails' ) ;
  
  prfObjectOutside = get_interpolated_prf( prfCollectionObject, 1045, 500 ) ;
  prfObjectInside  = get_interpolated_prf( prfCollectionObject, 1044.5, 500 ) ;
  assert_equals( prfObjectOutside, prfObjectInside, ...
      'Third inside/outside object interpolation test fails' ) ;
  
  prfObjectOutside = get_interpolated_prf( prfCollectionObject, 500, 1113 ) ;
  prfObjectInside  = get_interpolated_prf( prfCollectionObject, 500, 1112.5 ) ;
  assert_equals( prfObjectOutside, prfObjectInside, ...
      'Fourth inside/outside object interpolation test fails' ) ;
  
% instantiate a prfCollectionClass object which does not have polyStruct's (ie, it uses
% pure coefficientMatrix construction of its prfClass objects)

  load(fullfile(testDataDir,'prfCollectionStruct')) ;
  prfCollectionObject = prfCollectionClass(prfCollectionStruct) ;

% An attempt to use the polyStruct interpolation method on this object should result in an
% error

  try_to_catch_error_condition('a=get_interpolated_prf(prfCollectionObject,500,100,1)', ...
      'polyStructEmpty',prfCollectionObject,'prfCollectionObject') ;
  
% and that's it!

%
%
%
