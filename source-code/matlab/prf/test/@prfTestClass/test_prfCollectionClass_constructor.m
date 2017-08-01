function self = test_prfCollectionClass_constructor( self )
%
% test_prfCollectionClass_constructor -- test of the class constructor for
% prfCollectionClass. This test exercises all of the constructor options and ensures that
% the constructor works properly in all cases.
%
% This test is intended to operate in the mlunit context.  To execute, use the following
% syntax:
%
%
%     run(text_test_runner, prfTestClass('test_prfCollectionClass_constructor')) ;
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
%         switch to use of fcConstants for 2nd argument of constructor.  Add cleanup.
%     2008-September-24, PT:
%         verify that use of datastruct(:).polyStruct and datastruct(:).coefficientMatrix
%         can also be used.  Use different data structures to match new prfClass and
%         prfCollectionClass organization.
%     2008-September-10, PT:
%         verify that PRFs with different sizes are rejected.
%
%=========================================================================================

% set the path for the PRF data files

  setup_prf_paths ;
  
% load 5 PRF data files and instantiate them

  load(fullfile(testDataDir,'prfCoefficientMatrices')) ;
  prfObject1 = prfClass(coefficientMatrix1) ;
  prfObject2 = prfClass(coefficientMatrix2) ;
  prfObject3 = prfClass(coefficientMatrix3) ;
  prfObject4 = prfClass(coefficientMatrix4) ;
  prfObject5 = prfClass(coefficientMatrix5) ;
  
% load the fcConstants

  load(fullfile(testDataDir,'fcConstants')) ;
  
% construct a prfCollectionClass object using 5 duplicates of one PRF (IE, only one PRF for
% that mod/out)

  prfCollectionObject1 = prfCollectionClass( prfObject1, fcConstants ) ;
 
% construct a prfCollectionClass object using 5 different PRFs, one in each corner

  prfObjectVector = [prfObject1 ; prfObject2 ; prfObject3 ; prfObject4 ; prfObject5] ;
  prfCollectionObject2 = prfCollectionClass( prfObjectVector, fcConstants ) ;
  
% construct a prfCollectionClass object using another prfCollectionClass object

  prfCollectionObject3 = prfCollectionClass( prfCollectionObject2 ) ;
  
% construct a prfCollectionClass object by extracting a data structure via get, then
% reconstructing

  prfCollectionStruct = get(prfCollectionObject3,'*') ;
  prfCollectionObject4 = prfCollectionClass( prfCollectionStruct ) ;
  
% construct a prfCollectionClass object by using a single coefficient matrix

  prfStruct.coefficientMatrix = coefficientMatrix1 ;
  prfCollectionObject5 = prfCollectionClass( prfStruct, fcConstants ) ;
  
% construct a prfCollectionClass object by using 5 coefficient matrices

  prfStruct(2).coefficientMatrix = coefficientMatrix2 ;
  prfStruct(3).coefficientMatrix = coefficientMatrix3 ;
  prfStruct(4).coefficientMatrix = coefficientMatrix4 ;
  prfStruct(5).coefficientMatrix = coefficientMatrix5 ;
  prfCollectionObject6 = prfCollectionClass( prfStruct, fcConstants ) ;
  
% equivalency and non-equivalency tests
  
  assert_not_equals( prfCollectionObject1, prfCollectionObject2, ...
      'prfCollectionClass objects identical in test_prfCollectionClass_constructor' ) ;
  assert_equals( prfCollectionObject2, prfCollectionObject3, ...
      'prfCollectionClass objects not identical in test_prfCollectionClass_constructor' ) ;
  assert_equals( prfCollectionObject2, prfCollectionObject4, ...
      'prfCollectionClass objects not identical in test_prfCollectionClass_constructor' ) ;
  assert_equals( prfCollectionObject1, prfCollectionObject5, ...
      'prfCollectionClass objects not identical in test_prfCollectionClass_constructor' ) ;
  assert_equals( prfCollectionObject2, prfCollectionObject6, ...
      'prfCollectionClass objects not identical in test_prfCollectionClass_constructor' ) ;
  
% size equivalences -- check that a mis-sized PRF will cause an error exit

  nPixels = size(coefficientMatrix1,2) ;
  nPixelsPerSide = sqrt(nPixels) ;
  nPixelsReduced = (nPixelsPerSide-1)^2 ;
  coefficientMatrixReduced = coefficientMatrix1(:,1:nPixelsReduced,:,:) ;
  
  prfObjectReduced = prfClass(coefficientMatrixReduced) ;
  prfObjectVector(5) = prfObjectReduced ;
  try_to_catch_error_condition( ...
      'p=prfCollectionClass(prfObjectVector,fcConstants)', ...
      'prfSizeMismatch','caller') ;
  
% and that's it!

%
%
%
