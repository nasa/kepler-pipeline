function self = test_get_fitted_to_unfitted_jacobian( self )
%
% test_get_fitted_to_unfitted_jacobian -- test the transitFitClass method which computes
% the jacobian of the transformation from fitted planet model parameters to unfitted
% parameters
%
% This unit test exercises the get_fitted_to_unfitted_jacobian method of the
% transitFitClass.  It tests the following functionality:
%
% ==> The jacobian is properly formed when operated on fitType == 0, 1, or 2
% ==> The jacobian is properly formed whether it includes or excludes the inclination
%     angle in its calculations.
%
% This test is intended to be executed in the mlunit context.  For standalone execution
% use the following syntax:
%
%      run(text_test_runner, testTransitFitClass('test_get_fitted_to_unfitted_jacobian'));
%
% Version date:  2009-September-23.
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
%=========================================================================================

  disp('... testing fitted-to-unfitted jacobian method ... ')
  
  testTransitFitClass_initialization ;
  
% Invoke the jacobian calculator for the fitted method

  fieldOrder = [1 4 5 11 2 3 6 7 8 9 10] ;
  jacobian = get_fitted_to_unfitted_jacobian( transitFitObject1, fieldOrder, ...
      false ) ;
  
% check that the resulting jacobian has the expected dimensions

  assert_equals( size(jacobian), [7 4], ...
      'fitType 1 jacobian without inclination angle has wrong dimensions' ) ;
  
% do the same with the inclination angle included

  jacobian = get_fitted_to_unfitted_jacobian( transitFitObject1, fieldOrder, ...
      true ) ;
  assert_equals( size(jacobian), [8 4], ...
      'fitType 1 jacobian with inclination angle has wrong dimensions' ) ;

% Now do the same with fitType 0, with and without inclination angle

  transitFitObject2 = transitFitClass( transitFitStruct, 0 ) ;
  transitFitObject2 = fit_transit( transitFitObject2 ) ;
  fieldOrder = [1 4 5 6 2 3 7 8 9 10 11] ;
  jacobian = get_fitted_to_unfitted_jacobian( transitFitObject2, fieldOrder, ...
      false ) ;
   assert_equals( size(jacobian), [7 4], ...
      'fitType 0 jacobian without inclination angle has wrong dimensions' ) ;
  jacobian = get_fitted_to_unfitted_jacobian( transitFitObject2, fieldOrder, ...
      true ) ;
  assert_equals( size(jacobian), [8 4], ...
      'fitType 0 jacobian with inclination angle has wrong dimensions' ) ;
  
% finally, do the same with fitType 2, with and without inclination angle

  transitFitObject3 = transitFitClass( transitFitStruct, 2 ) ;
  transitFitObject3 = fit_transit( transitFitObject3 ) ;
  fieldOrder = [1 4 5 2 3 6 7 8 9 10 11] ;
  jacobian = get_fitted_to_unfitted_jacobian( transitFitObject3, fieldOrder, ...
      false ) ;
   assert_equals( size(jacobian), [8 3], ...
      'fitType 2 jacobian without inclination angle has wrong dimensions' ) ;
  jacobian = get_fitted_to_unfitted_jacobian( transitFitObject3, fieldOrder, ...
      true ) ;
  assert_equals( size(jacobian), [9 3], ...
      'fitType 2 jacobian with inclination angle has wrong dimensions' ) ;
  
  disp(' ') ;
  
return

% and that's it!

%
%
%
