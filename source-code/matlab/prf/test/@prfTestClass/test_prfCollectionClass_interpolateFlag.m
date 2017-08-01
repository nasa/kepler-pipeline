function self = test_prfCollectionClass_interpolateFlag( self ) 
%
% test_prfCollectionClass_interpolateFlag -- tests whether the interpolateFlag is properly
% used by prfCollectionClass methods evaluate, make_array, cross_section, and
% get_interpolated_prf.  This test is a unit test in the mlunit context; the correct
% syntax for executing it is:
%
%
%     run(text_test_runner, prfTestClass('test_prfCollectionClass_interpolateFlag')) ;
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
%     2008-September-29, PT:
%         add cleanup.
%     2008-September-24, PT:
%         update file used for test.
%
%=========================================================================================

% set the path for the PRF data files

  setup_prf_paths ;
  
% load the data file for a prfCollectionClass, and instantiate it

  load(fullfile(testDataDir,'prfCollectionStruct')) ;
  prfCollectionObject1 = prfCollectionClass(prfCollectionStruct) ;
  
% Instantiate a second prfCollectionClass object which is identical to the first one but
% which has its interpolateFlag set to 0 -- this way the internal data representation is
% the same as for the first one, but it acts like it only has one PRF in it, which is the
% one in the center

  prfCollectionStruct.interpolateFlag = false ;
  prfCollectionObject2 = prfCollectionClass(prfCollectionStruct) ;
  
% get the center prfClass object from prfCollectionObject1 -- this object should have the
% same behavior as prfCollectionObject2

  prfObject = get(prfCollectionObject1,'prfCenterObject') ;

%=========================================================================================  
  
% Test 1:  evaluate method -- evaluate the 3 objects at a selected point; to ensure that
% the same evaluation is performed, use the row and column information from the first
% evaluate call in the second and third calls

  [pixel1, row1, col1] = evaluate( prfCollectionObject1, 500, 250 ) ;
  [pixel2, row2, col2] = evaluate( prfCollectionObject2, 500, 250, row1, col1 ) ;
  [pixel3, row3, col3] = evaluate( prfObject, 500, 250, row1, col1 ) ;
  
% What is success?  Success is that pixel2 == pixel3 ; pixel 1 ~= pixel 2 ; and that all
% the row and all the column returns are the same.  The idea is that, since the second
% prfCollectionClass object has interpolateFlag set to false, it always uses the central
% prfClass object and ignores the others; so it should be identical to the prfObject.

  pixelSuccess = ( ~isequal(pixel1,pixel2) && isequal(pixel2,pixel3) ) ;
  rowColSuccess = ( isequal(row1,row2) && isequal(row1,row3) && ...
                    isequal(col1,col2) && isequal(col2,col3)        ) ;
                
  mlunit_assert( pixelSuccess, ...
      'pixel values from evaluate do not match expected pattern' ) ;
  mlunit_assert( rowColSuccess, ...
      'evaluate functions not evaluating on same row/column locations' ) ;
  
%=========================================================================================

% Test 2: make_array method -- similar concept to above, except that the make_array method
% is used instead of evaluate.

  resolution = 100 ;

  [array1, row1, col1] = make_array( prfCollectionObject1, 500, 250, resolution ) ;
  [array2, row2, col2] = make_array( prfCollectionObject2, 500, 250, resolution ) ;
  [array3, row3, col3] = make_array( prfObject, resolution ) ;

  arraySuccess = ( ~isequal(array1,array2) && isequal(array2,array3) ) ;
  rowColSuccess = ( isequal(row1,row2) && isequal(row1,row3) && ...
                    isequal(col1,col2) && isequal(col2,col3)        ) ;
                
  mlunit_assert( arraySuccess, ...
      'array values from make_array do not match expected pattern' ) ;
  mlunit_assert( rowColSuccess, ...
      'row/col positions from make_array do not match' ) ;
  
%=========================================================================================

% Test 3: cross_section method

  [value1, coord1] = cross_section( prfCollectionObject1, 1, 500, 250 ) ;
  [value2, coord2] = cross_section( prfCollectionObject2, 1, 500, 250 ) ;
  [value3, coord3] = cross_section( prfObject, 1 ) ;
  
  valueSuccess = ( ~isequal(value1,value2) && isequal(value2,value3) ) ;
  coordSuccess = ( isequal(coord1,coord2) && isequal(coord2,coord3) ) ;
  
  mlunit_assert( valueSuccess, ...
      'values from cross_section do not match expected pattern' ) ;
  mlunit_assert( rowColSuccess, ...
      'positions from cross_section do not match' ) ;
  
%=========================================================================================

% Test 4: get_interpolated_prf test

  prfObject1 = get_interpolated_prf( prfCollectionObject1, 500, 250 ) ;
  prfObject2 = get_interpolated_prf( prfCollectionObject2, 500, 250 ) ;
  
  prfObjectSuccess = ( ~isequal(prfObject1,prfObject) && isequal(prfObject2,prfObject) ) ;
  
  mlunit_assert( prfObjectSuccess, ...
      'prfObject equivalences do not match expected pattern' ) ;
  
% and that's it

%
%
%