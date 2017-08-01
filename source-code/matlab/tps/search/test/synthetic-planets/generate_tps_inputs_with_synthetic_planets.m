function tpsInputStruct = generate_tps_inputs_with_synthetic_planets( ...
    tpsDawgStruct, keplerIdList, multipleEventStatistic, periodRange, ...
    epochFlexibilityDays )
%
% generate_tps_inputs_with_synthetic_planets -- produce a tpsInputStruct in which
% synthetic planets have been added to the TPS input flux.  Arguments:
%
% tpsDawgStruct:           a tpsDawgStruct or tceStruct which is used to get the original
%                          (planet-free) TPS inputs
% keplerIdList:            list of Kepler IDs to which planets are to be added
% multipleEventStatistic:  approximate value of the MES desired for all targets
% periodRange:             a vector with the min and max desired periods in days
% epochFlexibilityDays:    step size in days which can be used to adjust the planet epochs
%                          in order to maximize the number of in-transit cadences
%
% Returns a tpsInputStruct with a tpsTargets vector.  The targets in the vector have
% synthetic transit signatures added and contain information about their transits in the
% tpsTargets.diagnostics.planetInformation struct.
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

%==========================================================================


  nStars = length(keplerIdList) ;

% put all of the TPS inputs into a single struct, the simpler to later tweak the module
% parameters
  
  tpsInputStruct = make_tps_input_struct_from_kepler_ids( tpsDawgStruct, keplerIdList ) ;
  
%   if ~isPlanetInjectionEnabled  
%       
%       for iStar = 1:nStars
%         
%           keplerId = keplerIdList(iStar) ;
%           thisTpsInput = get_tps_struct_by_kepid_from_task_dir_tree( tpsDawgStruct, keplerId, 'input', false ) ;
%           
%           disp([datestr(now),':  Constructing synthetic planet signature for KIC ', ...
%               num2str(keplerId)]) ;
% 
%           if isempty( tpsInputStruct )
%               tpsInputStruct = thisTpsInput ;
%           else
%               tpsInputStruct.tpsTargets = [tpsInputStruct.tpsTargets ; ...
%                   thisTpsInput.tpsTargets] ;
%           end      
%       end % loop over stars
%       
%       return;
%       
%   end
  
% get information for all of the stars  
  
  starInformationStruct = retrieve_kics_by_kepler_id_matlabstyle( double(keplerIdList) ) ;
  starInformationStruct = starInformationStruct(:) ;

% generate a set of periods and epochs

  earliestAllowedEpoch = tpsDawgStruct.unitOfWorkKjd(1) ;
  periodVector = randi( [periodRange(1) periodRange(2)], nStars, 1 ) ;
  epochVector = rand(nStars,1) .* periodVector + earliestAllowedEpoch ;

% estimate the number of transits

  nTransits = floor( (tpsDawgStruct.unitOfWorkKjd(2) - epochVector) ./ periodVector ) + 1 ;

% compute transit durations

  periodMks = periodVector * get_unit_conversion('day2sec') ;
  radiusMks = [starInformationStruct.radius] * get_unit_conversion('solarRadius2meter') ;
  gMks = 10.^([starInformationStruct.log10SurfaceGravity]) / 100 ;
  durationMks = 2 * (periodMks .* radiusMks(:) ./ (2*pi*gMks(:) )).^(1/3) ;
  durationHours = durationMks * get_unit_conversion('sec2hour') ;

  pulseDurationHours = tpsDawgStruct.pulseDurations ;

  warning('off','dv:computeTransitParametersFromTpsInstantiation:iterLimitExceeded') ;

% loop over stars

  unclassifiedIndex = [] ;
  for iStar = 1:nStars

      thisStarInformation = starInformationStruct(iStar) ;
      keplerId            = keplerIdList(iStar) ;
      disp([datestr(now),':  Constructing synthetic planet signature for KIC ', ...
          num2str(keplerId), ', target ',num2str(iStar),' out of ', ...
          num2str(nStars)]) ;

%     get the TPS results and find the CDPP for the transit duration closest to the
%     requested duration of this transit sequence

      tpsOutputs = get_tps_struct_by_kepid_from_task_dir_tree( tpsDawgStruct, ...
          keplerId, 'output', false ) ;
      rmsCdpp = [tpsOutputs.tpsResults.rmsCdpp] ;

      [~,closestDuration] = min(abs(pulseDurationHours - durationHours(iStar))) ;
      rmsCdpp = rmsCdpp(closestDuration) ;

%     from the CDPP and the # of transits, estimate the transit depth needed to produce
%     the desired multiple event statistic

      transitDepthPpm = rmsCdpp * multipleEventStatistic / sqrt( nTransits(iStar) ) ;

%     construct the planet and star models

      planetModel.transitEpochBkjd = epochVector(iStar) ;
      planetModel.minImpactParameter = 0 ;
      planetModel.orbitalPeriodDays = periodVector(iStar) ;
      planetModel.transitDepthPpm = transitDepthPpm ;

      starModel.starRadiusSolarRadii = thisStarInformation.radius ;
      starModel.log10SurfaceGravity = thisStarInformation.log10SurfaceGravity ;
      starModel.log10Metallicity = thisStarInformation.log10Metallicity ;
      starModel.effectiveTemp = thisStarInformation.effectiveTemp ;

%     if the star is unclassified, skip it 

      if isnan( starModel.starRadiusSolarRadii * ...
                starModel.log10SurfaceGravity * ...
                starModel.log10Metallicity * ...
                starModel.effectiveTemp )

            disp([ ' ... KIC ', num2str(keplerId), ' unclassified, skipping ... ']) ;
            unclassifiedIndex = [unclassifiedIndex ; iStar] ;
            continue ;
      end
      
%     generate the model transits in the data

      tpsInputStructNew = add_planet_signature_to_flight_data( tpsInputStruct, ...
          keplerId, planetModel, starModel, epochFlexibilityDays ) ;
      thisTpsTarget = tpsInputStructNew.tpsTargets(iStar) ;
      
%     if the # of actual transits does not match expected, scale the size of the desired
%     transit and adjust the epoch to match what the planet signature code used

      planetStruct = thisTpsTarget.diagnostics.addedPlanetStruct ;

      if planetStruct.nTransits ~= nTransits(iStar)
          
          planetModel.transitEpochBkjd = planetStruct.planetInformation.planetModel.transitEpochBkjd ;
          planetModel.transitDepthPpm = planetModel.transitDepthPpm * ...
              sqrt( nTransits(iStar) / planetStruct.nTransits ) ;
          
          tpsInputStructNew = add_planet_signature_to_flight_data( tpsInputStruct, ...
              keplerId, planetModel, starModel, 0 ) ;
          thisTpsTarget = tpsInputStructNew.tpsTargets(iStar) ;
          
      end
      minSesInMesCount = tpsInputStruct.tpsModuleParameters.minSesInMesCount ;
      if planetStruct.nTransits < minSesInMesCount
          disp([' ... warning:  # of transits in KIC ', num2str(keplerId), ...
              ' == ', num2str(planetStruct.nTransits), ...
              ', less than minSesInMes value of ', num2str(minSesInMesCount)]) ;
      end
      
%     accumulate TPS target data structs

      tpsInputStruct.tpsTargets(iStar) = thisTpsTarget ;

%       if isempty( tpsInputStruct )
%           tpsInputStruct = thisTpsInput ;
%       else
%           tpsInputStruct.tpsTargets = [tpsInputStruct.tpsTargets ; ...
%               thisTpsInput.tpsTargets] ;
%       end
      
  end % loop over stars

  warning('on','dv:computeTransitParametersFromTpsInstantiation:iterLimitExceeded') ;
  
% remove unclassified stars

  tpsInputStruct.tpsTargets(unclassifiedIndex) = [] ;
  
return 



