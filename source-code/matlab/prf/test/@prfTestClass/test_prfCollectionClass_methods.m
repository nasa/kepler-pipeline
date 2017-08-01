function self = test_prfCollectionClass_methods( self )
%
% test_prfCollectionClass_methods -- exercise the prfCollectionClass methods
% cross_section, make_array, draw, and display_quality.  The test simply demonstrates that
% the methods execute without error without attempting to demonstrate that they produce
% numerically correct output; the key numerical feature of the prfCollectionClass,
% triangular interpolation, is tested by test_prfCollectionClass_evaluation.
%
% This test is intended to execute in the context of the mlunit unit test.  Syntax:
%
%     run(text_test_runner, prfTestClass('test_prfCollectionClass_methods')) ;
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
%     2008-October-06, PT:
%         use a multi-PRF prfCollectionClass (single-PRF objects fall through to the
%         prfClass methods, which is not what we want to do here).
%     2008-September-29, PT:
%         switch to use of fcConstants as 2nd argument in constructor.  Add cleanup.
%
%=========================================================================================

% set the path for the PRF data files

  setup_prf_paths ;
  
  load(fullfile(testDataDir,'prfCoefficientMatrices')) ;
  load(fullfile(testDataDir,'fcConstants')) ;
  
% Construct the prfClass object from the data and use it to instantiate the
% prfCollectionClass

  prfCollectionObject = prfCollectionClass( [...
      prfClass(coefficientMatrix1) prfClass(coefficientMatrix2) ...
      prfClass(coefficientMatrix3) prfClass(coefficientMatrix4) ...
      prfClass(coefficientMatrix5)], ...
      fcConstants ) ;
  
% test draw in contour and mesh modes, and make sure that it throws an error when the mode
% is some other word

  [prf,row,col] = draw( prfCollectionObject, 300, 600, 'contour' ) ;
  [prf,row,col] = draw( prfCollectionObject, 300, 600, 'mesh' ) ;
  try_to_catch_error_condition(...
      '[p,r,c]=draw(prfCollectionObject,300,600,''dummy'')', 'drawTypeInvalid', ...
      prfCollectionObject,'prfCollectionObject') ;
  
% The make_array and cross_section methods are used by the display_quality method

  [prf,row,col] = display_quality( prfCollectionObject, 300, 600 ) ;
  
% and that's it!

%
%
%
