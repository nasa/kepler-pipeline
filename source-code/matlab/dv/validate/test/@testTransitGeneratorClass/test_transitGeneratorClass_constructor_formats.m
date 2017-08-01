function self = test_transitGeneratorClass_constructor_formats( self )
%
% test_transitGeneratorClass_formats -- unit test of transitGeneratorClass constructor
% when using non-Gaussian formats
%
% This unit test exercises the following functionality of the transitGeneratorClass
% constructor:
%
% ==> The class is properly instantiated when the constructor is called with a planet
%     model of physical parameters
% ==> The class is properly instantiated when the constructor is called with a planet
%     model of TPS parameters
% ==> The class is properly instantiated when the constructor is called with a planet
%     model which uses the fit-results format
% ==> The error statements in the constructor are executed under appropriate conditions.
%
% This test is intended to be executed in the mlunit context.  For standalone execution
% use the following syntax:
%
%      run(text_test_runner, testTransitGeneratorClass('test_transitGeneratorClass_constructor_formats'));
%
% Version date:  2009-October-14.
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

  disp('... testing transit generator class constructor with various formats ... ')
  
% run the initialization first -- this will load and instantiate an object from a
% TPS-format data struct

  cleanup = false ;
  testTransitGeneratorClass_initialization ;
  
% regression-test the resulting object's internals against a saved struct

  tpsInstantiationResultStruct = struct( transitObject ) ;
  
  assert_equals( tpsInstantiationResultStruct, instantiationRegressionStruct, ...
      'TPS-instantiated object fails regression test' ) ;
  
% construct an equivalent planet model which has just the physical parameters from the
% results struct above

  planetModel = tpsInstantiationResultStruct.planetModel ;
  physicalFields = get_planet_model_legal_fields( 'physical' ) ;
  for iField = 1:length(physicalFields)
      newPlanetModel.(physicalFields{iField}) = planetModel.(physicalFields{iField}) ;
  end
  
% demonstrate that the new planet model can also be used for instantiation purposes

  transitModel2 = transitModel ;
  transitModel2.planetModel = newPlanetModel ;
  transitObject2 = transitGeneratorClass( transitModel2 ) ;
  
% check to make sure that the parameters are the same

  physicalInstantiationResultStruct = struct( transitObject2 ) ;
  
% For the new result struct:  all the fields except for planetModel should agree to the
% bit ...

  assert_equals( rmfield( physicalInstantiationResultStruct, 'planetModel' ), ...
      rmfield( instantiationRegressionStruct, 'planetModel' ), ...
      'Physical-instantiated object fields are incorrect' ) ;
  
% ... the planet models should have the same fields ...

  assert_equals( fieldnames( physicalInstantiationResultStruct.planetModel ) , ...
      fieldnames( instantiationRegressionStruct.planetModel ) , ...
      'Physical-instantiated object planet model field names are incorrect' ) ;
  
% ... the planet model values should agree to within a numerical tolerance, but need not
% be identical

  agreementTolerance = 1e-12 ;
  
  regressionPlanetModelArray = struct2array( instantiationRegressionStruct.planetModel ) ;
  physicalPlanetModelArray = struct2array( physicalInstantiationResultStruct.planetModel ) ;
  equalValues = regressionPlanetModelArray == physicalPlanetModelArray ;
  absTolerance = (regressionPlanetModelArray == 0 | physicalPlanetModelArray == 0) & ...
      abs( regressionPlanetModelArray - physicalPlanetModelArray ) < agreementTolerance ;
  relTolerance = (regressionPlanetModelArray ~= 0 & physicalPlanetModelArray ~= 0) & ...
      abs( regressionPlanetModelArray - physicalPlanetModelArray ) < ...
      agreementTolerance * ...
      mean([regressionPlanetModelArray ; physicalPlanetModelArray]) ;
  withinTolerance = equalValues | absTolerance | relTolerance ;
  mlunit_assert( sum( double(withinTolerance) ) == length( withinTolerance ), ...
      'Phyisical-instantiated object planet model values are incorrect' ) ;
      
% construct a planet model in the fit-results format -- it should match the physical model
% version to the bit

  planetModelValueCell = num2cell( physicalPlanetModelArray ) ;
  planetModelNameCell = fieldnames( physicalInstantiationResultStruct.planetModel ) ;
  planetModelCell =  [planetModelNameCell(:) planetModelValueCell(:) ] ;
  planetModelFitResults = cell2struct( planetModelCell,{'name','value'},2 ) ;
  transitModel3 = transitModel ;
  transitModel3.planetModel = planetModelFitResults ;
  transitObject3 = transitGeneratorClass( transitModel3 ) ;
  fitResultsInstantiationStruct = struct( transitObject3 ) ;
  assert_equals( fitResultsInstantiationStruct, ...
      physicalInstantiationResultStruct, ...
      'Fit-results-instantiated object incorrect' ) ;
  
% change the observable parameters in the fit-results format and instantiate -- the
% resulting object should be identical (ie, physical parameters should be ignored)

  observableFields = get_planet_model_legal_fields( 'observable' ) ;
  observableOnlyFields = observableFields( ...
      ~ismember( observableFields, physicalFields ) ) ;
  planetModelPhysical = physicalInstantiationResultStruct.planetModel ;
  for iField = 1:length(observableOnlyFields)
      planetModelPhysical.(observableOnlyFields{iField}) = ...
          planetModelPhysical.(observableOnlyFields{iField}) + 1 ;
  end
  physicalPlanetModelArray = struct2array( physicalInstantiationResultStruct.planetModel ) ;
  planetModelValueCell = num2cell( physicalPlanetModelArray ) ;
  planetModelCell =  [planetModelNameCell(:) planetModelValueCell(:) ] ;
  planetModelFitResults = cell2struct( planetModelCell,{'name','value'},2 ) ;
  transitModel3 = transitModel ;
  transitModel3.planetModel = planetModelFitResults ;
  transitObject3 = transitGeneratorClass( transitModel3 ) ;
  fitResultsInstantiationStruct2 = struct( transitObject3 ) ;
  assert_equals( fitResultsInstantiationStruct, ...
      fitResultsInstantiationStruct2, ...
      'Fit-results-instantiated object does not ignore observable parameters' ) ;
  
% test error-throwing capabilities of the constructor:

% 1.  No input struct argument

  try_to_catch_error_condition( 'z=transitGeneratorClass();', ...
      'EmptyInputStruct', 'caller' ) ;
  
% 2.  log10 surface gravity is NaN

  transitModel2 = transitModel ;
  transitModel2.log10SurfaceGravity = nan ;
  try_to_catch_error_condition( 'z=transitGeneratorClass(transitModel2);' , ...
      'log10SurfaceGravityNan', 'caller' ) ;
  
% 3.  effective temp is NaN

  transitModel2 = transitModel ;
  transitModel2.effectiveTemp = nan ;
  try_to_catch_error_condition( 'z=transitGeneratorClass(transitModel2);' , ...
      'effectiveTempNan', 'caller' ) ;

% 4.  Invalid transit model name

  transitModel2 = transitModel ;
  transitModel2.modelNamesStruct.transitModelName = 'dummy' ;
  try_to_catch_error_condition( 'z=transitGeneratorClass(transitModel2);' , ...
      'invalidModel', 'caller' ) ;
  
% 5.  Planet model format isn't TPS, Physical, or Fit-Results

  transitModel2 = transitModel ;
  transitModel2.planetModel.extraField = 1 ;
  try_to_catch_error_condition( 'z=transitGeneratorClass(transitModel2);' , ...
      'invalidStructFormat', 'caller' ) ;
  
% 6.  solar radius is NaN 

  transitModel2 = transitModel ;
  transitModel2.planetModel.starRadiusSolarRadii = nan ;
  try_to_catch_error_condition( 'z=transitGeneratorClass(transitModel2);' , ...
      'starRadiusSolarRadiiNaN', 'caller' ) ;

  disp(' ') ;
return

% and that's it!

%
%
%
