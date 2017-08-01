function self = test_private_methods( self ) 
%
% test_private_methods -- unit test for private methods in the transitGeneratorClass
%
% This unit test exercises the private methods of the transitGeneratorClass.  Since such
% methods can only be executed by a public method sitting in the directory above the
% private one, the testing is assisted by a public method of the transitGeneratorClass
% which is named test_transitGeneratorClass_private_methods.  The methods which are
% exercised are:
%
%    check_planet_model_value_bounds
%    compute_min_impact_parameter_from_observables
%    compute_semimajor_axis_from_observables
%    compute_transit_ingress_time
%
% This test is intended to be executed in the mlunit context.  For standalone execution
% use the following syntax:
%
%      run(text_test_runner, testTransitGeneratorClass('test_private_methods'));
%
% Version date:  2009-October-09.
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

  disp('... testing private methods ... ')
  
  testTransitGeneratorClass_initialization ;

% test the methods one at a time

  testResultsStruct = test_transitGeneratorClass_private_methods( transitObject, ...
      'check_planet_model_value_bounds' ) ;
  mlunit_assert( testResultsStruct.errorsExecuteOk, ...
      'check_planet_model_value_bounds errors do not execute properly' ) ;
  
  testResultsStruct = test_transitGeneratorClass_private_methods( transitObject, ...
      'compute_min_impact_parameter_from_observables' ) ;
  mlunit_assert( testResultsStruct.zeroImpactParameterOk, ...
      'minImpactParameter == 0 calculation incorrect' ) ;
  mlunit_assert( testResultsStruct.nonzeroImpactParameterOk, ...
      'minImpactParameter ~= 0 calculation incorrect' ) ;
  
  testResultsStruct = test_transitGeneratorClass_private_methods( transitObject, ...
      'compute_semimajor_axis_from_observables' ) ;
  mlunit_assert( testResultsStruct.valuesOk, ...
      'semi-major axis calculation incorrect' ) ;
  
  testResultsStruct = test_transitGeneratorClass_private_methods( transitObject, ...
      'compute_transit_ingress_time' ) ;
  mlunit_assert( testResultsStruct.valuesOk, ...
      'transit ingress time calculation incorrect' ) ;
  disp(' ') ;
return

% and that's it!

%
%
%
