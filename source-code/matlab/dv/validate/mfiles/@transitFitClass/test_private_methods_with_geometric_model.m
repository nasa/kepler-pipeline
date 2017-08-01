function testResultsStruct = test_private_methods_with_geometric_model( transitFitObject, methodName )
%
% test_private_methods_with_geometric_model -- transitFitClass method used exclusively in unit tests of the class' private methods
%
% testResultsStruct = test_private_methods_with_geometric_model( transitFitObject, methodName )  performs the calls to the transitFitClass private methods
%    which are needed for the unit tests of those methods.  This multi-layer unit test strategy is necessary because Matlab does not allow private methods
%    or functions to be called except by methods or functions sitting in the directory above the private directory where the private methods and functions
%    are held.  Argument methodName can take the following values:
%
%    'convert_impact_parameter'
%    'set_par_values_in_transit_generator'
%
%    In each case the appropriate test steps are executed for the named method, and the resulting signals of correct or incorrect execution are passed back
%    to the caller in the testResultsStruct.  
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
%    2010-May-07, PT:
%        remove test of dv fitter plotter kernel (now obsolete).
%    2010-May-05, PT:
%        convert from transitEpochMjd to transitEpochBkjd.
%    2010-May-03, PT:
%        added tests for odd-even simultaneous fitting.
%
%=========================================================================================

% all the main function does is call the appropriate subfunction, so:

  switch methodName
      
      case 'convert_impact_parameter'
          testResultsStruct = test_convert_impact_parameter_geometric_model;
      case 'set_par_values_in_transit_generator'
          testResultsStruct = test_set_par_values_in_transit_generator_geometric_model( transitFitObject ) ;
          
  end
  
return

% and that's it!

%
%
%

%=========================================================================================

% subfunction which performs tests on the convert_impact_parameter private method

function testResultsStruct = test_convert_impact_parameter_geometric_model

% test conversion from bounded to unbounded

  [par0, deriv0] = convert_impact_parameter( 0,     1 );
  [par1, deriv1] = convert_impact_parameter( 1,     1 );
  
  testResultsStruct.direction1Ok = (par0 == 0) && (deriv0 == 1) && (par1 == pi/2) && isinf( deriv1 );
  
% test conversion from unbounded to bounded

  [par2, deriv2] = convert_impact_parameter( 0,    -1 );
  [par3, deriv3] = convert_impact_parameter( pi/2, -1 );
  
  testResultsStruct.direction2Ok = (par2 == 0) && (deriv2 == 1) && (par3 == 1   ) && (abs(deriv3) < 1e-12);
  
% test error case

  try
      [a,b] = convert_impact_parameter( 0, 2 );
      testResultsStruct.errorMessage = char([]);
  catch
      lastError = lasterror;
      testResultsStruct.errorMessage = lastError.identifier;
  end
  
return

%=========================================================================================

% subfunction which performs the set-par-values tests

function testResultsStruct = test_set_par_values_in_transit_generator_geometric_model( transitFitObject )

% get the initial transit object and its planet model

  transitObject      = get( transitFitObject, 'transitGeneratorObject' );
  planetModel        = get( transitObject,    'planetModel' );
  
% get the parameter map out of the fit object

  parameterMapStruct = get( transitFitObject, 'parameterMapStruct' );
  
% fitType 12 case -- extract the parameters, vary them by up to 1%, and put them into a transitGeneratorClass object

  parameterValueArray = [ planetModel.transitEpochBkjd; ...
                          planetModel.ratioPlanetRadiusToStarRadius; ...
                          planetModel.ratioSemiMajorAxisToStarRadius; ...
                          planetModel.minImpactParameter; ...
                          planetModel.orbitalPeriodDays ];
  parameterValueArray = parameterValueArray .* (1 + rand(size(parameterValueArray)));
  
  transitObject12 = set_par_values_in_transit_generator( transitObject, 12, parameterMapStruct, parameterValueArray );
  planetModel12   = get( transitObject12, 'planetModel' );
  
% are the 3 changed physical values changed to the desired ones?  Is the minimum impact 
% parameter unchanged?  Is the star radius changed (due to the change in orbital period
% and semi-major axis)?  Is the orbital period approximately correct?

  fitType12Ok =                  planetModel12.transitEpochBkjd               == parameterValueArray(1);
  fitType12Ok = fitType12Ok && ( planetModel12.ratioPlanetRadiusToStarRadius  == parameterValueArray(2) );
  fitType12Ok = fitType12Ok && ( planetModel12.ratioSemiMajorAxisToStarRadius == parameterValueArray(3) );
  fitType12Ok = fitType12Ok && ( planetModel12.minImpactParameter             == parameterValueArray(4) );
  fitType12Ok = fitType12Ok && ( abs( planetModel12.orbitalPeriodDays - parameterValueArray(5) ) < 1e-12 * parameterValueArray(5) );
                         
% check that negative values are OK

  transitObject12 = set_par_values_in_transit_generator( transitObject, 12, parameterMapStruct, -parameterValueArray );
  planetModel12a  = get( transitObject12, 'planetModel' );
  fitType12Ok     = fitType12Ok && isequal( planetModel12a, planetModel12 );
  
% Test odd-even case, in which there are 2 models which need to get filled.  We'll instantiate the models with parameters which give 2 odd transits and 2 even ones

  initialize_soc_variables;
  testDataDir = [socTestDataRoot, filesep, 'dv', filesep, 'unit-tests', filesep, 'transitFitGeometricClass'];

  load(fullfile(testDataDir,'transit-generator-model'));
  load(fullfile(testDataDir,'transit-fit-struct'));

  t0                                         = transitModel.cadenceTimes(1);
  tRange                                     = range( transitModel.cadenceTimes );
  transitModel.planetModel.transitEpochBkjd  = t0 + 0.2  * tRange;
  transitModel.planetModel.orbitalPeriodDays =      0.25 * tRange;
  
  transitObject3                             = transitGeneratorCollectionClass( transitModel, 1 );
  transitFitStruct.transitGeneratorObject    = transitObject3;
  transitFitObject2  = transitFitClass( transitFitStruct, 12 );
  parameterMapStruct = get( transitFitObject2, 'parameterMapStruct' );
  planetModel        = get( transitObject3, 'planetModel' );
  initialValues = [ planetModel(1).transitEpochBkjd; ...
                    planetModel(1).ratioPlanetRadiusToStarRadius; ...
                    planetModel(1).ratioSemiMajorAxisToStarRadius; ...
                    planetModel(1).minImpactParameter; ...
                    planetModel(1).orbitalPeriodDays; ...
                    planetModel(2).transitEpochBkjd ; ...
                    planetModel(2).ratioPlanetRadiusToStarRadius; ...
                    planetModel(2).ratioSemiMajorAxisToStarRadius; ...
                    planetModel(2).minImpactParameter; ...
                    planetModel(2).orbitalPeriodDays ];
  injectedValues = initialValues .* (1 + 0.01 * rand( size( initialValues ) ) );
  transitObject4 = set_par_values_in_transit_generator( transitObject3, [12 12], parameterMapStruct, injectedValues );
  planetModelNew = get( transitObject4, 'planetModel' );
  modelValues = [   planetModelNew(1).transitEpochBkjd; ...
                    planetModelNew(1).ratioPlanetRadiusToStarRadius; ...
                    planetModelNew(1).ratioSemiMajorAxisToStarRadius; ...
                    planetModelNew(1).minImpactParameter; ...
                    planetModelNew(1).orbitalPeriodDays; ...
                    planetModelNew(2).transitEpochBkjd; ...
                    planetModelNew(2).ratioPlanetRadiusToStarRadius; ...
                    planetModelNew(2).ratioSemiMajorAxisToStarRadius; ...
                    planetModelNew(2).minImpactParameter; ...
                    planetModelNew(2).orbitalPeriodDays ];
  oddEvenFitOk = max( abs( modelValues - injectedValues ) ) < 1e-12;
  
% now gap the last transit so that odds want to be fitType 12 and evens want to be fitType 14

  nCadences = length(transitModel.cadenceTimes);
  gapRange  = round(0.75*nCadences):nCadences;
  transitFitStruct.whitenedFluxTimeSeries.gapIndicators(gapRange) = true;
  transitFitObject3  = transitFitClass( transitFitStruct, 12 );
  parameterMapStruct = get( transitFitObject3, 'parameterMapStruct' );
  planetModel        = get( transitObject3, 'planetModel' );
  initialValues = [ planetModel(1).transitEpochBkjd; ...
                    planetModel(1).ratioPlanetRadiusToStarRadius; ...
                    planetModel(1).ratioSemiMajorAxisToStarRadius; ...
                    planetModel(1).minImpactParameter; ...
                    planetModel(1).orbitalPeriodDays; ...
                    planetModel(2).transitEpochBkjd ; ...
                    planetModel(2).ratioPlanetRadiusToStarRadius; ...
                    planetModel(2).ratioSemiMajorAxisToStarRadius; ...
                    planetModel(2).minImpactParameter ]; 
  injectedValues = initialValues .* (1 + 0.01 * rand( size( initialValues ) ) );
  transitObject5 = set_par_values_in_transit_generator( transitObject3, [12 12], parameterMapStruct, injectedValues );
  planetModelNew = get( transitObject5, 'planetModel' );
  modelValues = [   planetModelNew(1).transitEpochBkjd; ...
                    planetModelNew(1).ratioPlanetRadiusToStarRadius; ...
                    planetModelNew(1).ratioSemiMajorAxisToStarRadius; ...
                    planetModelNew(1).minImpactParameter; ...
                    planetModelNew(1).orbitalPeriodDays; ...
                    planetModelNew(2).transitEpochBkjd ; ...
                    planetModelNew(2).ratioPlanetRadiusToStarRadius; ...
                    planetModelNew(2).ratioSemiMajorAxisToStarRadius; ...
                    planetModelNew(2).minImpactParameter ]; 
  oddEvenFitOk = oddEvenFitOk && max( abs( modelValues - injectedValues ) ) < 1e-12;
  
% construct return structure and return it

  testResultsStruct.fitType12Ok  = fitType12Ok;
  testResultsStruct.oddEvenFitOk = oddEvenFitOk;
  
return

%
