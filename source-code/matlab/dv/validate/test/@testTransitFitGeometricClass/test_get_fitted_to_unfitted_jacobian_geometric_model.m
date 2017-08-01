function self = test_get_fitted_to_unfitted_jacobian_geometric_model( self )
%
% test_get_fitted_to_unfitted_jacobian_geometric_model -- unit test for get_fitted_to_unfitted_jacobian method of transitFitClass with geometric transit model
%
% This unit test exercises the get_fitted_to_unfitted_jacobian method of the transitFitClass.  It tests the following functionality:
%
% ==> The jacobian is properly formed when operated on fitType == 12
% ==> The jacobian is properly formed whether it includes or excludes the inclination angle in its calculations.
%
% This test is intended to be executed in the mlunit context.  For standalone execution use the following syntax:
%
%      run(text_test_runner, testTransitFitClass('test_get_fitted_to_unfitted_jacobian_geometric_model'));
%
% Version date:  2011-April-20.
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
%    2011-April-20, JL:
%        update to support DV 7.0
%
%=========================================================================================

  disp(' ');
  disp('... testing fitted-to-unfitted jacobian method with geometric transit model ... ');
  disp(' ');
  
  testTransitFitGeometricClass_initialization;
  
% Invoke the jacobian calculator for the fitted method

  fieldOrder = [1 12 13 6 11 2 3 4 5 7 8 9 10] ;
  jacobian = get_fitted_to_unfitted_jacobian( transitFitObject1, fieldOrder, false );
  
% check that the resulting jacobian has the expected dimensions

  assert_equals( size(jacobian), [8 5], 'jacobian without inclination angle has wrong dimensions' );
  
% do the same with the inclination angle included

  jacobian = get_fitted_to_unfitted_jacobian( transitFitObject1, fieldOrder, true );
  assert_equals( size(jacobian), [9 5], 'jacobian with inclination angle has wrong dimensions' );

  disp(' ');
  
return

% and that's it!