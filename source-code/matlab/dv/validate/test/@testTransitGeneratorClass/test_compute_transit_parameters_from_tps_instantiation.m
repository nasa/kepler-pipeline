function self = test_compute_transit_parameters_from_tps_instantiation( self ) 
%
% test_compute_transit_parameters_from_tps_instantiation -- unit test for
% transitGeneratorClass method compute_transit_parameters_from_tps_instantiation
%
% This unit test exercises the transitGeneratorClass method which fills in the planet
% model from the fields which are available when instantiated from a TPS TCE.  The
% available fields are:
%
%    transitEpochMjd
%    starRadiusSolarRadii
%    transitDepthPpm
%    orbitalPeriodDays
%    minImpactParameter
%
% From these, the method calculates the parameters:
%
%    planetRadiusEarthRadii
%    semiMajorAxisAu
%    transitDurationHours
%    transitIngressTimeHours
%
% This unit test is essentially a regression test of the method which performs that
% calculation.
%
% This test is intended to be executed in the mlunit context.  For standalone execution
% use the following syntax:
%
%      run(text_test_runner, testTransitGeneratorClass('test_compute_transit_parameters_from_tps_instantiation'));
%
% Version date:  2009-October-16.
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
%    2009-October-16, PT:
%        test case in which iteration limit is reached in trying to get planet radius to
%        match transit depth.
%
%=========================================================================================

  disp('... testing compute-parameters-from-tps method ... ')
  
  cleanup = false ;
  testTransitGeneratorClass_initialization ;
  clear transitObject ;
  
% tweak the planet model parameters to be more like Venus and less like Earth; while we're
% at it, tweak the impact parameter and the solar radius

  planetModel = transitModel.planetModel ;
  planetModel.minImpactParameter = 0.01 ;
  planetModel.starRadiusSolarRadii = 1.01 ;
  planetModel.transitDepthPpm = 89.64 ;
  planetModel.orbitalPeriodDays = 222.45 ;
  transitModel.planetModel = planetModel ;
  
% instantiate the object -- this automatically invokes the parameter computer, but we will
% also explicitly invoke it just in case the constructor is later changed
  
  transitObject1 = transitGeneratorClass( transitModel ) ;
  transitObject1 = compute_transit_parameters_from_tps_instantiation( transitObject1 ) ;
  planetModel = get( transitObject1, 'planetModel' ) ;
  
% load a cached planet model and regression test against it

  load( fullfile( testDataDir, 'planet-model-tps-regression-test' ) ) ;
  assert_equals( planetModel, planetModelVenusRegression, ...
      'TPS-to-full parameter regression test failed' ) ;
  
% load a model which will hit its iteration limit trying to instantiate, and verify that
% the appropriate warning message is thrown

  load( fullfile( testDataDir, 'transit-generator-model-iter-limit-test' ) ) ;
  lastwarn('') ;
  transitObject2 = transitGeneratorClass( transitModelStruct ) ;
  [lastWarnMsg, lastWarnId] = lastwarn ;
  assert_equals( lastWarnId, ...
      'dv:computeTransitParametersFromTpsInstantiation:iterLimitExceeded', ...
      'Iteration-limit warning not generated' ) ;
  
  disp(' ') ;
  
  
return

%   
