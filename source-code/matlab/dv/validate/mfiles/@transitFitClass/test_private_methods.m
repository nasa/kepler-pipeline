function testResultsStruct = test_private_methods( transitFitObject, methodName )
%
% test_private_methods -- transitFitClass method used exclusively in unit tests of the
% class' private methods
%
% testResultsStruct = test_private_methods( transitFitObject, methodName ) performs the 
%    calls to the transitFitClass private methods which are needed for the unit tests of
%    those methods.  This multi-layer unit test strategy is necessary because Matlab does
%    not allow private methods or functions to be called except by methods or functions
%    sitting in the directory above the private directory where the private methods and
%    functions are held.  Argument methodName can take the following values:
%
%    'convert_impact_parameter'
%    'dv_fitter_plotter_kernel'
%    'set_par_values_in_transit_generator'
%
%    In each case the appropriate test steps are executed for the named method, and the
%    resulting signals of correct or incorrect execution are passed back to the caller in
%    the testResultsStruct.  
%
% Version date:  2010-May-07.
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
          testResultsStruct = test_convert_impact_parameter ;
      case 'set_par_values_in_transit_generator'
          testResultsStruct = test_set_par_values_in_transit_generator( ...
              transitFitObject ) ;
          
  end
  
return

% and that's it!

%
%
%

%=========================================================================================

% subfunction which performs tests on the convert_impact_parameter private method

function testResultsStruct = test_convert_impact_parameter

% test conversion from bounded to unbounded

  [par0, deriv0] = convert_impact_parameter( 0, 1 ) ;
  [par1, deriv1] = convert_impact_parameter( 1, 1 ) ;
  
  testResultsStruct.direction1Ok = par0 == 0 && deriv0 == 1 && par1 == pi/2 && ...
      isinf( deriv1 ) ;
  
% test conversion from unbounded to bounded

  [par2, deriv2] = convert_impact_parameter( 0, -1 ) ;
  [par3, deriv3] = convert_impact_parameter( pi/2, -1 ) ;
  
  testResultsStruct.direction2Ok = par2 == 0 && deriv2 == 1 && par3 == 1 && ...
      abs(deriv3) < 1e-12 ;
  
% test error case

  try
      [a,b] = convert_impact_parameter( 0, 2 ) ;
      testResultsStruct.errorMessage = char([]) ;
  catch
      lastError = lasterror ;
      testResultsStruct.errorMessage = lastError.identifier ;
  end
  
return

%=========================================================================================

% subfunction which performs the set-par-values tests

function testResultsStruct = test_set_par_values_in_transit_generator( transitFitObject )

% get the initial transit object and its planet model

  transitObject = get( transitFitObject, 'transitGeneratorObject' ) ;
  planetModel = get( transitObject, 'planetModel' ) ;
  
% get the parameter map out of the fit object

  parameterMapStruct = get( transitFitObject, 'parameterMapStruct' ) ;
  
% fitType 1 case -- extract the parameters, vary them by up to 1%, and put them into a
% transitGeneratorClass object

  parameterValueArray = [planetModel.transitEpochBkjd ; ...
      planetModel.planetRadiusEarthRadii ; ...
      planetModel.semiMajorAxisAu ; ...
      planetModel.orbitalPeriodDays] ;
  parameterValueArray = parameterValueArray .* (1 + rand(size(parameterValueArray))) ;
  
  transitObject1 = set_par_values_in_transit_generator( transitObject, 1, ...
      parameterMapStruct, parameterValueArray ) ;
  planetModel1 = get( transitObject1, 'planetModel' ) ;
  
% are the 3 changed physical values changed to the desired ones?  Is the minimum impact 
% parameter unchanged?  Is the star radius changed (due to the change in orbital period
% and semi-major axis)?  Is the orbital period approximately correct?

  fitType1Ok = planetModel1.transitEpochBkjd == parameterValueArray(1) ;
  fitType1Ok = fitType1Ok && planetModel1.planetRadiusEarthRadii == parameterValueArray(2) ;
  fitType1Ok = fitType1Ok && planetModel1.semiMajorAxisAu == parameterValueArray(3) ;
  fitType1Ok = fitType1Ok && abs( planetModel1.orbitalPeriodDays - parameterValueArray(4) ) ...
      < 1e-12 * parameterValueArray(4) ;
  fitType1Ok = fitType1Ok && planetModel.starRadiusSolarRadii ~= ...
                             planetModel1.starRadiusSolarRadii ;
  fitType1Ok = fitType1Ok && planetModel.minImpactParameter == ...
                             planetModel1.minImpactParameter ;
                         
% check that negative values are OK

  transitObject1 = set_par_values_in_transit_generator( transitObject, 1, ...
      parameterMapStruct, -parameterValueArray ) ;
  planetModel1a = get( transitObject1, 'planetModel' ) ;
  fitType1Ok = fitType1Ok && isequal( planetModel1a, planetModel1 ) ;
  
% fitType 0 case -- similar logic to fitType 1

  parameterMapStruct.orbitalPeriodDays = 0 ;
  parameterMapStruct.minImpactParameter = 4 ;
  parameterValueArray = [planetModel.transitEpochBkjd ; ...
      planetModel.planetRadiusEarthRadii ; ...
      planetModel.semiMajorAxisAu] ;
  parameterValueArray = parameterValueArray .* (1 + rand(size(parameterValueArray))) ;
  parameterValueArray(4) = 0.005 ;
  
  transitObject0 = set_par_values_in_transit_generator( transitObject, 0, ...
      parameterMapStruct, parameterValueArray ) ;
  planetModel0 = get( transitObject0, 'planetModel' ) ;
  fitTypeZeroOk = planetModel0.transitEpochBkjd == parameterValueArray(1) ;
  fitTypeZeroOk = fitTypeZeroOk && planetModel0.planetRadiusEarthRadii == parameterValueArray(2) ;
  fitTypeZeroOk = fitTypeZeroOk && planetModel0.semiMajorAxisAu == parameterValueArray(3) ;
  fitTypeZeroOk = fitTypeZeroOk && planetModel0.minImpactParameter == ...
                                      parameterValueArray(4) ;
  fitTypeZeroOk = fitTypeZeroOk && planetModel0.starRadiusSolarRadii == ...
                                   planetModel.starRadiusSolarRadii ;

  transitObject0 = set_par_values_in_transit_generator( transitObject, 0, ...
      parameterMapStruct, -parameterValueArray ) ;
  planetModel0a = get( transitObject0, 'planetModel' ) ;
  fitTypeZeroOk = fitTypeZeroOk && isequal( planetModel0a, planetModel0 ) ;

% fit type 2 case is like fit type 1 except that neither orbital period nor impact
% parameter is fitted

  parameterMapStruct.minImpactParameter = 0 ;
  parameterValueArray = [planetModel.transitEpochBkjd ; ...
      planetModel.planetRadiusEarthRadii ; ...
      planetModel.semiMajorAxisAu] ;
  parameterValueArray = parameterValueArray .* (1 + rand(size(parameterValueArray))) ;
  
  transitObject2 = set_par_values_in_transit_generator( transitObject, 2, ...
      parameterMapStruct, parameterValueArray ) ;
  planetModel2 = get( transitObject2, 'planetModel' ) ;
  
  fitType2Ok = planetModel2.transitEpochBkjd == parameterValueArray(1) ;
  fitType2Ok = fitType2Ok && planetModel2.planetRadiusEarthRadii == parameterValueArray(2) ;
  fitType2Ok = fitType2Ok && planetModel2.semiMajorAxisAu == parameterValueArray(3) ;
  fitType2Ok = fitType2Ok && abs( planetModel2.orbitalPeriodDays - ...
      planetModel.orbitalPeriodDays ) ...
      < 1e-12 * planetModel.orbitalPeriodDays ;
  fitType2Ok = fitType2Ok && planetModel.starRadiusSolarRadii ~= ...
                             planetModel2.starRadiusSolarRadii ;
  fitType2Ok = fitType2Ok && planetModel.minImpactParameter == ...
                             planetModel2.minImpactParameter ;

  transitObject2 = set_par_values_in_transit_generator( transitObject, 2, ...
      parameterMapStruct, -parameterValueArray ) ;
  planetModel2a = get( transitObject2, 'planetModel' ) ;
  fitType2Ok = fitType2Ok && isequal( planetModel2a, planetModel2 ) ;
  
% Test odd-even case, in which there are 2 models which need to get filled.  We'll
% instantiate the models with parameters which give 2 odd transits and 2 even ones

  initialize_soc_variables ;
  testDataDir = [socTestDataRoot, filesep, 'dv', filesep, 'unit-tests', filesep, ...
      'transitFitClass'] ;

  load(fullfile(testDataDir,'transit-generator-model')) ;
  load(fullfile(testDataDir,'transitFitClass-struct-format1')) ;

  t0 = transitModel.cadenceTimes(1) ;
  tRange = range( transitModel.cadenceTimes ) ;
  transitModel.planetModel.transitEpochBkjd = t0 + 0.2 * tRange ;
  transitModel.planetModel.orbitalPeriodDays = 0.25 * tRange ;
  transitObject3 = transitGeneratorCollectionClass( transitModel, 1 ) ;
  transitFitStruct.transitGeneratorObject = transitObject3 ;
  transitFitObject2 = transitFitClass( transitFitStruct, 1 ) ;
  parameterMapStruct = get( transitFitObject2, 'parameterMapStruct' ) ;
  planetModel = get( transitObject3, 'planetModel' ) ;
  initialValues = [planetModel(1).transitEpochBkjd ; ...
      planetModel(1).planetRadiusEarthRadii ; ...
      planetModel(1).semiMajorAxisAu ; ...
      planetModel(1).orbitalPeriodDays ; ...
      planetModel(2).transitEpochBkjd ; ...
      planetModel(2).planetRadiusEarthRadii ; ...
      planetModel(2).semiMajorAxisAu ; ...
      planetModel(2).orbitalPeriodDays] ;
  injectedValues = initialValues .* (1 + 0.01 * rand( size( initialValues ) ) ) ;
  transitObject4 = set_par_values_in_transit_generator( transitObject3, [1 1], ...
      parameterMapStruct, injectedValues ) ;
  planetModelNew = get( transitObject4, 'planetModel' ) ;
  modelValues = [planetModelNew(1).transitEpochBkjd ; ...
      planetModelNew(1).planetRadiusEarthRadii ; ...
      planetModelNew(1).semiMajorAxisAu ; ...
      planetModelNew(1).orbitalPeriodDays ; ...
      planetModelNew(2).transitEpochBkjd ; ...
      planetModelNew(2).planetRadiusEarthRadii ; ...
      planetModelNew(2).semiMajorAxisAu ; ...
      planetModelNew(2).orbitalPeriodDays] ;
  oddEvenFitOk = max( abs( modelValues - injectedValues ) ) < 1e-12  ;
  
% now gap the last transit so that odds want to be fitType 1 and evens want to be fitType
% 2

  nCadences = length(transitModel.cadenceTimes) ;
  gapRange = round(0.75*nCadences):nCadences ;
  transitFitStruct.whitenedFluxTimeSeries.gapIndicators(gapRange) = true ;
  transitFitObject3 = transitFitClass( transitFitStruct, 1 ) ;
  parameterMapStruct = get( transitFitObject3, 'parameterMapStruct' ) ;
  planetModel = get( transitObject3, 'planetModel' ) ;
  initialValues = [ planetModel(1).transitEpochBkjd ; ...
      planetModel(1).planetRadiusEarthRadii ; ...
      planetModel(1).semiMajorAxisAu ; ...
      planetModel(1).orbitalPeriodDays ; ...
      planetModel(2).transitEpochBkjd ; ...
      planetModel(2).planetRadiusEarthRadii; ...
      planetModel(2).semiMajorAxisAu ] ;
  injectedValues = initialValues .* (1 + 0.01 * rand( size( initialValues ) ) ) ;
  transitObject5 = set_par_values_in_transit_generator( transitObject3, [1 2], ...
      parameterMapStruct, injectedValues ) ;
  planetModelNew = get( transitObject5, 'planetModel' ) ;
  modelValues = [planetModelNew(1).transitEpochBkjd ; ...
      planetModelNew(1).planetRadiusEarthRadii ; ...
      planetModelNew(1).semiMajorAxisAu ; ...
      planetModelNew(1).orbitalPeriodDays ; ...
      planetModelNew(2).transitEpochBkjd ; ...
      planetModelNew(2).planetRadiusEarthRadii ; ...
      planetModelNew(2).semiMajorAxisAu] ;
  oddEvenFitOk = oddEvenFitOk && max( abs( modelValues - injectedValues ) ) < 1e-12  ;
  
% construct return structure and return it

  testResultsStruct.fitType1Ok = fitType1Ok ;
  testResultsStruct.fitTypeZeroOk = fitTypeZeroOk ;
  testResultsStruct.fitType2Ok = fitType2Ok ;
  testResultsStruct.oddEvenFitOk = oddEvenFitOk ;
  
return

%
