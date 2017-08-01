function tpsInputStruct = add_planet_signature_to_flight_data( tpsStruct, ...
    keplerId, planetModel, starModel, epochFlexibilityDays )
%
% add_planet_signature_to_flight_data -- superimpose a model transit sequence onto TPS
% flight data
%
% tpsInputStruct = add_planet_signature_to_flight_data( tpsStruct, keplerId,
%    planetModel, starModel, flexibleEpoch ) returns the TPS input struct for the selected
%    Kepler ID, with the fluxValue array modified to incorporate a model transit sequence.
%    The planet sequence is defined by the parameters in structs planetModel and
%    starModel, which have the following fields:
%
%    planetModel:
%       transitEpochBkjd
%       minImpactParameter
%       orbitalPeriodDays
%       transitDepthPpm
%
%    starModel:
%       starRadiusSolarRadii
%       log10SurfaceGravity
%       log10Metallicity
%       effectiveTemp
%
%    The tpsStruct can be either a tpsInputStruct which has the desired target as one of
%    the targets in the tpsTargets struct array, or a tpsDawgStruct / tceStruct.s
%
%    Note that starModel is optional, if omitted then the parameters for the Sun will be
%    substituted.  Argument epochFlexibilityDays is optional; if missing or set to zero,
%    this will force the planet signature to be added with the exact epoch specified by
%    the planetModel; if set to a positive number, it will allow the planet signature to
%    be added with an epoch offset in order to maximize the number of in-transit cadences;
%    the step size of the offset is given by the value of epochFlexibilityDays.
%
% The ground truth of the parameters described above and of the added light curve will be
%    stored in the tpsTargets.diagnostics struct.
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

% handle optional arguments

  if ~exist('epochFlexibilityDays','var') || isempty(epochFlexibilityDays)
      epochFlexibilityDays = 0 ;
  end
  
  if ~exist('starModel','var') || isempty(starModel)
      starModel.starRadiusSolarRadii = 1 ;
      starModel.log10SurfaceGravity = 4.44 ;
      starModel.log10Metallicity = 0 ;
      starModel.effectiveTemp = 5760 ;
  end
  
% retrieve the input struct if the user passed a DAWG struct...

  if isfield(tpsStruct,'topDir')

      tpsInputStruct = get_tps_struct_by_kepid_from_task_dir_tree( tpsStruct, keplerId, ...
          'input', false ) ;
      iTarget = 1 ;
      
  else % tpsInputStruct, so make necessary assignments
      
      tpsInputStruct = tpsStruct ;
      iTarget = find([tpsInputStruct.tpsTargets.keplerId] == keplerId) ;
      
  end
  
% generate the cadence times -- this requires interpolation of the existing cadence times,
% plus offsetting to make it Bkjd

  cadenceTimes = tpsInputStruct.cadenceTimes.midTimestamps ;
  gapIndicators = tpsInputStruct.cadenceTimes.gapIndicators ;
  
  cadenceTimes(gapIndicators) = interp1( find(~gapIndicators), ...
      cadenceTimes(~gapIndicators), find(gapIndicators), 'linear', 'extrap' ) ;
  cadenceTimes = cadenceTimes - kjd_offset_from_mjd ;
      
% construct an array which indicates which cadences are valid

  validCadences = ones( size( cadenceTimes ) ) ;
  validCadences( gapIndicators )                                             = 0 ;
  validCadences( tpsInputStruct.tpsTargets(iTarget).gapIndices+1 )           = 0 ;
  validCadences( tpsInputStruct.tpsTargets(iTarget).fillIndices+1 )          = 0 ;
  validCadences( tpsInputStruct.tpsTargets(iTarget).outlierIndices+1 )       = 0 ;
  validCadences( tpsInputStruct.tpsTargets(iTarget).discontinuityIndices+1 ) = 0 ;
      
% construct the timing information struct

  timeParametersStruct.exposureTimeSec        = 6.0198029032704 ;
  timeParametersStruct.readoutTimeSec         = 0.518948526144 ;
  timeParametersStruct.numExposuresPerCadence = 270 ;
  
% construct the model name struct

  modelNamesStruct.transitModelName       = 'mandel-agol_geometric_transit_model' ;
  modelNamesStruct.limbDarkeningModelName = 'kepler_nonlinear_limb_darkening_model' ;
  
% add some parameters to the planet model

  planetModel.eccentricity           = 0 ;
  planetModel.longitudeOfPeriDegrees = 0 ;
  planetModel.starRadiusSolarRadii   = starModel.starRadiusSolarRadii ;
  
% build the struct for instantiating the transit object

  transitStruct.cadenceTimes              = cadenceTimes ;
  transitStruct.log10SurfaceGravity.value = starModel.log10SurfaceGravity ;
  transitStruct.effectiveTemp.value       = starModel.effectiveTemp ;
  transitStruct.log10Metallicity.value    = starModel.log10Metallicity ;
  transitStruct.radius.value              = starModel.starRadiusSolarRadii ;
  transitStruct.debugFlag                 = false ;
  transitStruct.modelNamesStruct          = modelNamesStruct ;
  transitStruct.transitBufferCadences     = 1 ;
  transitStruct.transitSamplesPerCadence  = 21 ;
  transitStruct.timeParametersStruct      = timeParametersStruct ;
  transitStruct.planetModel               = planetModel ;
  
  transitStruct.log10SurfaceGravity.uncertainty = 0 ;
  transitStruct.effectiveTemp.uncertainty       = 0 ;
  transitStruct.log10Metallicity.uncertainty    = 0 ;
  transitStruct.radius.uncertainty              = 0 ;
  
% build the object

  transitObject = transitGeneratorClass( transitStruct ) ;
  
% now:  if the user wants to allow the epoch to be changed to maximize the number of
% transits which fall on good data cadences, we need to handle that now

  if epochFlexibilityDays > 0

%     first figure out how many cadences we expect to see with nonzero value

      planetModel          = get(transitObject,'planetModel') ;
      timeParametersStruct = get(transitObject,'timeParametersStruct') ;
      cadenceDurationHours = (timeParametersStruct.exposureTimeSec + ...
          timeParametersStruct.readoutTimeSec) * timeParametersStruct.numExposuresPerCadence ...
          * get_unit_conversion('sec2hour') ;
      cadenceDurationDays  = cadenceDurationHours * get_unit_conversion( 'hour2day' ) ;
      cadencesPerTransit   = planetModel.transitDurationHours / cadenceDurationHours ;
      numExpectedTransits  = get_number_of_transits_in_time_series( transitObject ) ;
      numExpectedCadences  = cadencesPerTransit * numExpectedTransits ;

%     figure out which cadences can be the epoch

      cadenceTimeDistanceFromEpoch = cadenceTimes - planetModel.transitEpochBkjd ;
      cadenceTimeDistanceInSteps = cadenceTimeDistanceFromEpoch / epochFlexibilityDays ;
      closestToStepBoundary = abs(cadenceTimeDistanceInSteps - ...
          floor(cadenceTimeDistanceInSteps)) < cadenceDurationDays / epochFlexibilityDays ;

      permittedEpochs = cadenceTimes( ...
          cadenceTimes - cadenceTimes(1) < planetModel.orbitalPeriodDays & ...
          closestToStepBoundary ) ;

%     sort the permitted epochs according to their distance from the user-requested epoch

      [~,sortKey] = sort( abs(permittedEpochs - planetModel.transitEpochBkjd) ) ;
      permittedEpochs = permittedEpochs(sortKey) ;
      permittedEpochs = [planetModel.transitEpochBkjd ; permittedEpochs(:)] ;

%     set up an array to track the # of cadences in transit for each epoch

      cadencesInTransit = zeros( size( permittedEpochs ) ) ;
      
%     loop over epochs and find the # of cadences in transit at that epoch

      for iEpoch = 1:length(permittedEpochs)
          
          planetModel.transitEpochBkjd = permittedEpochs( iEpoch ) ;
          transitObject = set(transitObject, 'planetModel', planetModel ) ;
          phaseShiftedLightCurve = generate_planet_model_light_curve( transitObject ) ;
          
          cadencesInTransit(iEpoch) = length( find( ...
              validCadences .* phaseShiftedLightCurve < 0 ) ) ;

%         in the unlikely event that we've found a case which has all the cadences we
%         could ever expect, we can stop searching now
          
          if cadencesInTransit(iEpoch) == numExpectedCadences
              break ;
          end
          
      end % loop over epochs
      
%     find the epoch which has the largest number of in-transit cadences and is also
%     closest in timing to the requested one

      [~,bestEpochPointer] = max(cadencesInTransit) ;
      planetModel.transitEpochBkjd = permittedEpochs( bestEpochPointer ) ;
      transitObject = set( transitObject, 'planetModel', planetModel ) ;
      
  end % flexible epoch condition
  
% at this point we are ready to stick the transit model information and the transit model
% itself into the TPS inputs

  addedPlanetStruct.planetInformation = get(transitObject,'*') ;
  addedPlanetStruct.lightCurve = generate_planet_model_light_curve( transitObject ) ;
  [~,addedPlanetStruct.nTransits] = get_number_of_transits_in_time_series( transitObject, ...
      cadenceTimes, ~validCadences, [] ) ;
  tpsInputStruct.tpsTargets(iTarget).diagnostics.addedPlanetStruct = addedPlanetStruct ;
  tpsInputStruct.tpsTargets(iTarget).fluxValue = tpsInputStruct.tpsTargets(iTarget).fluxValue .* ...
      (1 + addedPlanetStruct.lightCurve) ;

return

