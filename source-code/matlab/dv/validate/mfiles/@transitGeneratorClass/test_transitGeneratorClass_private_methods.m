function testResultsStruct = test_transitGeneratorClass_private_methods( transitObject, ...
    testTypeString )
%
% test_private_methods -- execution kernel for performing unit tests of private methods of
% the transitGeneratorClass
%
% testResultsStruct = test_private_methods( transitObject, testTypeString ) performs the
%    main work of the unit tests for the private methods of the transitGeneratorClass.
%    This approach is necessary because the private methods can only be invoked by a
%    function or method in the directory over the "/private" directory containing the
%    private methods (ie, not by an object which inherits the transitGeneratorClass but
%    has all its native methods in some other directory).  
%
% Argument testTypeString determines which of the private methods is tested, and can have
%    one of four values:
%
%    ==> 'check_planet_model_value_bounds'
%    ==> 'compute_min_impact_parameter_from_observables'
%    ==> 'compute_semimajor_axis_from_observables'
%    ==> 'compute_transit_ingress_time'
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

%=========================================================================================

  planetModel = get( transitObject, 'planetModel' ) ;

% switch between the 4 actual tests:

  switch testTypeString
      
      case 'check_planet_model_value_bounds'
          testResultsStruct = test_check_planet_model_value_bounds( planetModel ) ;
      case 'compute_min_impact_parameter_from_observables'
          testResultsStruct = test_compute_min_impact_parameter( transitObject ) ;
      case 'compute_semimajor_axis_from_observables'
          testResultsStruct = test_compute_semimajor_axis( transitObject ) ;
      case 'compute_transit_ingress_time'
          testResultsStruct = test_compute_transit_ingress_time( transitObject ) ;
          
  end
  
return

%=========================================================================================

% subfunction which does the work of testing the check_planet_model_value_bounds private
% method

function testResultsStruct = test_check_planet_model_value_bounds( planetModel )

% test the impact parameter bounds

  planetModel.minImpactParameter = 0.5 ;
  check_planet_model_value_bounds( planetModel ) ;
  
  planetModel.minImpactParameter = 1.1 ;
  try
      lasterror('reset') ;
      check_planet_model_value_bounds(planetModel) ;
  catch
      lastError = lasterror ;
  end
  testResultsStruct.errorsExecuteOk = strcmp( lastError.identifier, ...
      'dv:transitGeneratorClass:minImpactParameterValueOutOfBounds')  ;
  
  planetModel.minImpactParameter = -0.1 ;
  try
      lasterror('reset') ;
      check_planet_model_value_bounds(planetModel) ;
  catch
      lastError = lasterror ;
  end
  testResultsStruct.errorsExecuteOk = testResultsStruct.errorsExecuteOk && ...
      strcmp( lastError.identifier, ...
      'dv:transitGeneratorClass:minImpactParameterValueOutOfBounds')  ;
  
return

%=========================================================================================

% subfunction which performs tests of the minimum impact parameter calculator

function testResultsStruct = test_compute_min_impact_parameter( transitObject ) 

% start by testing the computation of a zero minimum impact parameter
  
  planetModel = get( transitObject, 'planetModel' ) ;
  planetModel.minImpactParameter = 0 ;
  transitObject = set( transitObject, 'planetModel', planetModel ) ;
  planetModel = get( transitObject, 'planetModel' ) ;
  
  radiusRatio = planetModel.planetRadiusEarthRadii * ...
      get_unit_conversion('earthRadius2meter') / ...
      planetModel.starRadiusSolarRadii / ...
      get_unit_conversion('solarRadius2meter') ;
  
  minImpactParameterExact = compute_min_impact_parameter_from_observables( ...
      radiusRatio^2, ...
      planetModel.transitDurationHours * get_unit_conversion('hour2sec'), ...
      planetModel.transitIngressTimeHours * get_unit_conversion('hour2sec'), ...
      planetModel.orbitalPeriodDays * get_unit_conversion('day2sec'), ...
      true ) ;
  
  minImpactParameterApprox = compute_min_impact_parameter_from_observables( ...
      radiusRatio^2, ...
      planetModel.transitDurationHours * get_unit_conversion('hour2sec'), ...
      planetModel.transitIngressTimeHours * get_unit_conversion('hour2sec'), ...
      planetModel.orbitalPeriodDays * get_unit_conversion('day2sec'), ...
      false ) ;
  
  minImpactParameterDefault = compute_min_impact_parameter_from_observables( ...
      radiusRatio^2, ...
      planetModel.transitDurationHours * get_unit_conversion('hour2sec'), ...
      planetModel.transitIngressTimeHours * get_unit_conversion('hour2sec'), ...
      planetModel.orbitalPeriodDays * get_unit_conversion('day2sec') ) ;
  
  valuesOk = minImpactParameterApprox < 1e-7 ;
  valuesOk = valuesOk && minImpactParameterApprox == minImpactParameterDefault ;
  valuesOk = valuesOk && minImpactParameterApprox ~= minImpactParameterExact ;
  valuesOk = valuesOk && minImpactParameterExact < 3e-3 ;
  
  testResultsStruct.zeroImpactParameterOk = valuesOk ;
  
% now do a test with a non-zero impact parameter

  planetModel.minImpactParameter = 0.1 ;
  transitObject = set( transitObject, 'planetModel', planetModel ) ;
  planetModel = get( transitObject, 'planetModel' ) ;
  
  radiusRatio = planetModel.planetRadiusEarthRadii * ...
      get_unit_conversion('earthRadius2meter') / ...
      planetModel.starRadiusSolarRadii / ...
      get_unit_conversion('solarRadius2meter') ;
  
  minImpactParameterExact = compute_min_impact_parameter_from_observables( ...
      radiusRatio^2, ...
      planetModel.transitDurationHours * get_unit_conversion('hour2sec'), ...
      planetModel.transitIngressTimeHours * get_unit_conversion('hour2sec'), ...
      planetModel.orbitalPeriodDays * get_unit_conversion('day2sec'), ...
      true ) ;
  
  minImpactParameterApprox = compute_min_impact_parameter_from_observables( ...
      radiusRatio^2, ...
      planetModel.transitDurationHours * get_unit_conversion('hour2sec'), ...
      planetModel.transitIngressTimeHours * get_unit_conversion('hour2sec'), ...
      planetModel.orbitalPeriodDays * get_unit_conversion('day2sec'), ...
      false ) ;
  
  minImpactParameterDefault = compute_min_impact_parameter_from_observables( ...
      radiusRatio^2, ...
      planetModel.transitDurationHours * get_unit_conversion('hour2sec'), ...
      planetModel.transitIngressTimeHours * get_unit_conversion('hour2sec'), ...
      planetModel.orbitalPeriodDays * get_unit_conversion('day2sec') ) ;
  
  valuesOk = abs( planetModel.minImpactParameter - minImpactParameterApprox ) < ...
      3e-6 ;
  valuesOk = valuesOk && abs( planetModel.minImpactParameter - minImpactParameterExact ) < ...
      4e-5 ;
  valuesOk = valuesOk && minImpactParameterExact ~= minImpactParameterApprox ;
  valuesOk = valuesOk && minImpactParameterDefault == minImpactParameterApprox ;
  
  testResultsStruct.nonzeroImpactParameterOk = valuesOk ;

  
return

%=========================================================================================

% subfunction which performs tests of semi-major axis calculator

function testResultsStruct = test_compute_semimajor_axis( transitObject )

  planetModel = get( transitObject, 'planetModel' ) ;
  planetModel.planetRadiusEarthRadii = 1 ;
  planetModel.semiMajorAxisAu = 1 ;
  transitObject = set( transitObject, 'planetModel', planetModel ) ;
  planetModel = get( transitObject, 'planetModel' ) ;
  
% get the ratio in planet-radius to star radius

  radiusRatio = planetModel.planetRadiusEarthRadii * ...
      get_unit_conversion('earthRadius2meter') / ...
      planetModel.starRadiusSolarRadii / ...
      get_unit_conversion('solarRadius2meter') ;

% perform the calculation

  aOverR = compute_semimajor_axis_from_observables( radiusRatio^2, ...
      planetModel.minImpactParameter, ...
      planetModel.transitDurationHours * get_unit_conversion('hour2sec'), ...
      planetModel.orbitalPeriodDays * get_unit_conversion('day2sec') ) ;
  semiMajorAxisAu = aOverR * planetModel.starRadiusSolarRadii * ...
      get_unit_conversion('solarRadius2meter') * ...
      get_unit_conversion('meter2au') ;
  
  testResultsStruct.valuesOk = abs(1-semiMajorAxisAu) < 4e-6 ;
  
return

%=========================================================================================

% subfunction which performs test on transit ingress time calculator

function testResultsStruct = test_compute_transit_ingress_time( transitObject )

% get the parameters out of the transit object 

  planetModel = get( transitObject, 'planetModel' ) ;
  planetRadiusMeters = planetModel.planetRadiusEarthRadii * ...
      get_unit_conversion( 'earthRadius2meter' ) ;
  starRadiusMeters = planetModel.starRadiusSolarRadii * ...
      get_unit_conversion( 'solarRadius2meter' ) ;
  semiMajorAxisMeters = planetModel.semiMajorAxisAu * ...
      get_unit_conversion( 'au2meter' ) ;
  minImpactParameter = planetModel.minImpactParameter ;
  transitDurationSeconds = planetModel.transitDurationHours * ...
      get_unit_conversion( 'hour2sec' ) ;
  log10SurfaceGravity = transitObject.log10SurfaceGravity ;
  surfaceGravityKicUnits = 10^(log10SurfaceGravity) * get_unit_conversion('cm2meter') ;
  
% compute the ingress time for zero impact parameter and large impact parameter
  
  ingressTime0 = compute_transit_ingress_time( planetRadiusMeters, starRadiusMeters, ...
      semiMajorAxisMeters, minImpactParameter, transitDurationSeconds, ...
      surfaceGravityKicUnits ) ;
  
  minImpactParameter = 0.9999 ;
  ingressTime1 = compute_transit_ingress_time( planetRadiusMeters, starRadiusMeters, ...
      semiMajorAxisMeters, minImpactParameter, transitDurationSeconds, ...
      surfaceGravityKicUnits ) ;
  
  testResultsStruct.valuesOk = ingressTime1 > ingressTime0 && ...
      ingressTime1 <= 0.5 * transitDurationSeconds ;
  
return

