function transitGeneratorObject = set( transitGeneratorObject, fieldName, fieldValue )
%
% set -- set the value of a member of the transitGeneratorClass
%
% transitGeneratorObject = set( transitGeneratorObject, fieldName, fieldValue ) sets the
%    selected field (determined by string fieldName) to the user-specified value
%    (fieldValue), and returns the resulting transitGeneratorClass object.  At this time,
%    the only field which is supported is planetModel.  
%
% After setting the planetModel, the planetModel fields will be updated:  if the user has
%    specified new values of the physical parameters (planet radius, semi-major axis,
%    inclination, eccentricity, longitude of periastron, star radius) then the observable 
%    parameters (transit duration, transit ingress time, transit depth, orbital period) 
%    will be updated to be consistent with the new values of the physical parameters;
%    if the user has specified new values of the observable parameters, then the physical 
%    parameters will be updated to be consistent with the new values of the observables.  
%    If the user has changed values in both categories, an error will result.
%
% Version date:  2010-Nov-05.
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
%    2012-September-21, BC:
%        Add 'radius' to fields which may be set. This should have been updated as part
%        of KSOC-2448.
%    2012-August-17, BC:
%        Add ability to set any field in the transitGeneratorObject. With the exception of
%        planetModel field, no check for consistancy performed here. It is up to the user to
%        set parameter values and dimension consistant with their use case.
%    2010-Nov-05, JL:
%        When geometric transit model is used, planetModelRequiredFields includes 'all' 
%        -- 'physical-observable-geometric'; otherwise, planetModelRequiredFields includes
%        'physical-observable'
%        Call transitGeneratorClass method compute_transit_geometric_observable_parameters
%        when geometric transit model is used
%    2009-August-17, PT:
%        move handling of negative signs into set_par_values_in_transit_generator method
%        of transitFitClass.
%    2009-July-22, PT:
%        handle a planetModel with signed minImpactParameter.  Handle bounds checking on
%        minImpactParameter.
%    
%=========================================================================================

% at this time we only support the setting of the planetModel

  switch fieldName
      
      case 'planetModel'
          
          % list of required fields
          % When geometric transit model is used, planetModelRequiredFields includes 'all' -- 'physical-observable-geometric';
          % otherwise, planetModelRequiredFields includes 'physical-observable'
          
          if strcmp(transitGeneratorObject.modelNamesStruct.transitModelName, 'mandel-agol_geometric_transit_model')
              planetModelRequiredFields = get_planet_model_legal_fields('all') ;
          else
              planetModelRequiredFields = get_planet_model_legal_fields('physical-observable') ;
          end
             
          if (~check_planet_model( fieldValue, planetModelRequiredFields ))
              error('dv:transitGeneratorClass:set:planetModelInvalid', ...
                  'set: planetModel struct is not valid') ;
          end

          if strcmp(transitGeneratorObject.modelNamesStruct.transitModelName, 'mandel-agol_geometric_transit_model')

              check_planet_model_value_bounds( fieldValue ) ;
              transitGeneratorObject.planetModel = fieldValue ;
              
              %  When geometric transit model is used, call the transitGeneratorClass method
              %  compute_transit_geometric_observable_parameters
              transitGeneratorObject = compute_transit_geometric_observable_parameters(transitGeneratorObject );

          else

              oldPlanetModel = get(transitGeneratorObject, 'planetModel') ;
              parFlag = find_updated_parameters( oldPlanetModel, fieldValue ) ;
              if parFlag == 3 % changed both sets of parameters, so error out
                  error('dv:transitGeneratorClass:set:planetModelChangesInvalid', ...
                      'set: user can change physical or observable parameters, but not both') ;
              end
              
              check_planet_model_value_bounds( fieldValue ) ;
              transitGeneratorObject.planetModel = fieldValue ;

              if parFlag == 1 % physical parameters have changed, update observables

                  transitGeneratorObject = compute_transit_observable_parameters( ...
                      transitGeneratorObject ) ;

              elseif parFlag == 2 % observable parameters have changed, update physical

                  transitGeneratorObject = compute_transit_physical_parameters( ...
                      transitGeneratorObject ) ;

              end
          end
          
      case 'cadenceTimes'
          transitGeneratorObject.cadenceTimes = fieldValue;
      case 'log10SurfaceGravity'
          transitGeneratorObject.log10SurfaceGravity = fieldValue;
      case 'effectiveTemp'
          transitGeneratorObject.effectiveTemp = fieldValue;
      case 'log10Metallicity'
          transitGeneratorObject.log10Metallicity = fieldValue;
      case 'transitBufferCadences'
          transitGeneratorObject.transitBufferCadences = fieldValue;
      case 'transitSamplesPerCadence'
          transitGeneratorObject.transitSamplesPerCadence = fieldValue;
      case 'configMaps'
          transitGeneratorObject.configMaps = fieldValue;
      case 'modelNamesStruct'
          transitGeneratorObject.modelNamesStruct = fieldValue;
      case 'debugFlag'          
          transitGeneratorObject.debugFlag = fieldValue;
      case 'transitModelLightCurve'
          transitGeneratorObject.transitModelLightCurve = fieldValue;

      otherwise
          
          error('dv:transitGeneratorClass:set:fieldNameInvalid', ...
              'set:  invalid field selected') ;
          
  end % switch statement
  
return

% and that's it!

%
%
%

%=========================================================================================

% subfunction which checks that the planetModel has the correct fields

function isOkay = check_planet_model( planetModel, planetModelRequiredFields )

% The planet model must have the specified fields, and only the specified fields, and each
% one must be a numeric scalar value

  planetModelFields = fieldnames( planetModel ) ;
  
  fieldNamesOk = isequal( sort(planetModelFields(:)), sort(planetModelRequiredFields(:)) ) ;
  
  fieldValuesOk = false(length(planetModelFields),1) ;
  
  for iField = 1:length(planetModelFields)
      thisFieldValue = planetModel.(planetModelFields{iField}) ;
      fieldValuesOk(iField) = isscalar(thisFieldValue) && isnumeric(thisFieldValue) ;
  end
  
  isOkay = fieldNamesOk && all(fieldValuesOk) ;
  
return

%=========================================================================================
  
% subfunction which determines which portion of the planetModel is being touched; returns
% 0 if neither the physical nor observable parameters are touched (ie, only the transit
% epoch is different or else all pars are the same), 1 if physical parameters are touched,
% 2 if observable parameters are touched, 3 if both physical and observable parameters are
% touched.  

function [parFlag, planetModel] = find_updated_parameters( oldPlanetModel, ...
    planetModel, log10SurfaceGravity )
  
% get the physical and observable parameter field lists, and remove any fields which are
% in both lists
  
  physicalParameters   = get_planet_model_legal_fields( 'physical' ) ;
  observableParameters = get_planet_model_legal_fields( 'observable' ) ;
  
  [commonFields,physPointerCommon,obsPointerCommon] = intersect( physicalParameters, ...
      observableParameters ) ;
  physicalParameters(physPointerCommon) = [] ;
  observableParameters(obsPointerCommon) = [] ;
  
% there's no real pretty way to do this, so here goes a couple of for-loops:

  physParsUpdated = 0 ; obsParsUpdated = 0 ;
  for iField = 1:length(physicalParameters)
      if oldPlanetModel.(physicalParameters{iField}) ~= ...
              planetModel.(physicalParameters{iField})
          physParsUpdated = 1 ;
          if strcmp( physicalParameters{iField}, 'starRadiusSolarRadii' )
              starRadiusChanged = true ;
          end
          if strcmp( physicalParameters{iField}, 'semiMajorAxisAu' )
              semiMajorAxisChanged = true ;
          end
          
      end
  end
  for iField = 1:length(observableParameters)
      if oldPlanetModel.(observableParameters{iField}) ~= ...
              planetModel.(observableParameters{iField})
          obsParsUpdated = 2 ;
          if strcmp( observableParameters{iField}, 'orbitalPeriodDays' )
              orbitalPeriodChanged = true ;
          end
      end
  end
     
% set return value 
  
  parFlag = physParsUpdated + obsParsUpdated ;
    
return

