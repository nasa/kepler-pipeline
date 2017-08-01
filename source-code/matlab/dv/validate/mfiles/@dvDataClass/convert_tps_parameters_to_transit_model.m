function [transitModel] = convert_tps_parameters_to_transit_model( dvDataObject, iTarget, thresholdCrossingEvent, targetFluxTimeSeries, impactParameterSeed )
%
% convert_tps_parameters_to_transit_model -- estimate the physical parameters which
%    correspond to a given threshold crossing event, and return them in the format of a
%    struct which instantiates a transitGeneratorClass object
%
% Version date:  2014-May-20.
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
%    2014-May-20, JL:
%        update the algorithm to calculate ratioSemiMajorAxisToStarRadius
%        set lower bound of ratioSemiMajorAxisToStarRadius to '1+ratioPlanetRadiusToStarRadius'
%    2013-December-11, JL:
%        add parameter 'defaultEffectiveTemp' in transitModel
%    2013-April-30, JL:
%        adjust transitEpochBkjd so that it is always larger than the start of unit of work
%    2013-April-15, JL:
%        add max limit of transitDepth
%    2012-December-06, JL:
%        set lower bound of ratioSemiMajorAxisToStarRadius to 1
%    2012-August-23, JL:
%        add structs of stellar parameters in transitModel
%    2012-July-03, JL:
%        add input 'impactParameterSeed'
%    2011-October-03, JL:
%        take the median of ungapped flux values or uncertainties so that the median 
%        won't be zero
%    2011-August-08, JL:
%        add parameter 'smallBodyCutoff' in transitModel
%    2011-June-06, JL:
%        determine initial value of ratioSemiMajorAxisToStarRadius from orbitalPeriod 
%        and transitDuration of thresholdCrossingEvent struct to cope with the bias in
%        fitted parameters of some targets, as suggested by Jason.
%        add 'cadenceDurationDays' in the outputs.
%    2011-March-04, JL:
%        set initial value of minImpactParameter to 0.1
%    2011-February-28, JL:
%        set initial value of minImpactParameter to 0
%    2011-January-31, JL:
%        set initial value of ratioSemiMajorAxisToStarRadius from 'starRadiusSolarRadii'
%        and 'log10SurfaceGravity'
%    2010-November-24, JL:
%        add number of samples per cadence to transitModel
%    2010-October-25, JL:
%        when geometric transit model is used, include fields 'ratioPlanetRadiusToStarRadius'
%        and 'ratioSemiMajorAxisToStarRadius' in transitModel.planetModel
%    2010-May-05, PT:
%        convert from transitEpochMjd to transitEpochBkjd.
%    2009-November-09, PT:
%        change debug levels -- now debugLevel >= 4 causes the transitGeneratorClass to be
%        invoked with debugging on.
%    2009-September-09, PT:
%        do not allow the estimated transit depth to exceed the total range of values in
%        the flux time series.  Use the config maps to extract the cadence duration.
%    2009-August-05, PT:
%        set the generator's debugFlag only if debugLevel > 2 (the debug mode in the
%        generator draws pictures every time the light curve method is called, which is
%        a large number of times in the fit!).
%    2009-July-29, PT:
%        update parameters in model:  add effective temp, change from limb darkening
%        coeffs to the limb darkening model name, add buffer cadences, eccentricity,
%        config maps, and longitude of periastron.
%    2009-July-27, PT:
%        change to new parameters:  depth, period, star radius, force impact parameter to
%        zero.
%    2009-June-23, PT:
%        try out new parameters:  depth, period, star radius, force inclination to 90
%        degrees.
%    2009-May-26, PT:
%        update to match current design of transitGeneratorClass constructor.
%
%=========================================================================================


  % get default value of impact parameter seed
  
  if ~exist( 'impactParameterSeed', 'var' ) || isempty(impactParameterSeed)

      impactParameterSeed = dvDataObject.planetFitConfigurationStruct.impactParameterSeed;
     
  end

% get the cadence duration.  There is a remote possibility that the cadence duration will
% vary during the time of the data.  We will use the duration which is appropriate during
% the first cadence time, which is certainly good enough for the estimation purposes in
% this method.

  configMapObject = configMapClass( dvDataObject.configMaps ) ;

  mjd = dvDataObject.dvCadenceTimes.midTimestamps(1) ;
  exposureTimeSec = get_exposure_time( configMapObject, mjd ) ;
  readoutTimeSec = get_readout_time( configMapObject, mjd ) ;
  numExposuresPerCadence = ...
    get_number_of_exposures_per_long_cadence_period( configMapObject, mjd ) ;
  cadenceDurationDays = numExposuresPerCadence * ( exposureTimeSec + readoutTimeSec ) * ...
      get_unit_conversion('sec2day') ;

% get the range of flux time series values in valid cadences

  if exist( 'targetFluxTimeSeries', 'var' ) && ~isempty(targetFluxTimeSeries)

      gapIndicators = targetFluxTimeSeries.gapIndicators ;
      gapIndicators(targetFluxTimeSeries.filledIndices) = true ;
      fluxTimeSeriesRange = range( targetFluxTimeSeries.values( ~gapIndicators ) ) ;
      
  else
      
      fluxTimeSeriesRange = 1 ;
      
  end

% there are several parameters we can simply copy from the inputs

  keplerId     = dvDataObject.targetStruct(iTarget).keplerId;
  bufKeplerIds = [dvDataObject.barycentricCadenceTimes.keplerId];
  barycentricCadenceTimes   = dvDataObject.barycentricCadenceTimes(keplerId==bufKeplerIds);
  transitModel.cadenceTimes = barycentricCadenceTimes.midTimestamps ;
  	
  transitModel.log10SurfaceGravity  = dvDataObject.targetStruct(iTarget).log10SurfaceGravity;
  transitModel.effectiveTemp        = dvDataObject.targetStruct(iTarget).effectiveTemp;
  transitModel.log10Metallicity     = dvDataObject.targetStruct(iTarget).log10Metallicity;
  transitModel.radius               = dvDataObject.targetStruct(iTarget).radius;
  
  if ( dvDataObject.dvConfigurationStruct.debugLevel > 3 )
      transitModel.debugFlag = true ;
  else
      transitModel.debugFlag = false ;
  end
  
% fill in the names of the models which will be used

  transitModel.modelNamesStruct.transitModelName = ...
      dvDataObject.dvConfigurationStruct.transitModelName ;
  transitModel.modelNamesStruct.limbDarkeningModelName = ...
      dvDataObject.dvConfigurationStruct.limbDarkeningModelName ;
  
% fill in the transit buffer cadences, number of samples per cadence, config map information and smallBodyCutOff parameter

  transitModel.transitBufferCadences    = dvDataObject.planetFitConfigurationStruct.transitBufferCadences;
  transitModel.transitSamplesPerCadence = dvDataObject.planetFitConfigurationStruct.transitSamplesPerCadence;

  transitModel.configMaps               = dvDataObject.configMaps;
  
  transitModel.smallBodyCutoff          = dvDataObject.planetFitConfigurationStruct.smallBodyCutoff;
  transitModel.defaultAlbedo            = dvDataObject.planetFitConfigurationStruct.defaultAlbedo;
  transitModel.defaultEffectiveTemp     = dvDataObject.planetFitConfigurationStruct.defaultEffectiveTemp;
   
% Retrieve epochMjd time and orbitalPeriod from TCE. Adjust transit epoch time if necessary

  transitEpochBkjd  = thresholdCrossingEvent.epochMjd - kjd_offset_from_mjd;
  orbitalPeriodDays = thresholdCrossingEvent.orbitalPeriod;
  
  epochOffsetPeriods = 0;
  while ( transitEpochBkjd + epochOffsetPeriods*orbitalPeriodDays ) < barycentricCadenceTimes.startTimestamps(1)
      epochOffsetPeriods = epochOffsetPeriods + 1;
  end
  
% Now fill the planet model -- for test purposes, we will hand-construct a physical
% parameter set from the combination of orbital period, transit depth, star radius, and
% the minimum impact parameter, which is forced to zero (central transit).  At this time,
% set eccentricity and longitude of periastron to zero (we don't use these in DV 1, but
% they may come up later).

  planetModel.transitEpochBkjd       = transitEpochBkjd + epochOffsetPeriods*orbitalPeriodDays;
  planetModel.orbitalPeriodDays      = orbitalPeriodDays;
  planetModel.eccentricity           = 0;
  planetModel.longitudeOfPeriDegrees = 0;
  planetModel.minImpactParameter     = impactParameterSeed;
  planetModel.starRadiusSolarRadii   = dvDataObject.targetStruct(iTarget).radius.value;
    
% TPS doesn't determine anything which is quite comparable to the transit depth, but it
% does estimate the max single event statistic in sigmas; this is, very roughly, the ratio
% of the transit depth to the noise amplitude for a single transit.  The code block below
% peforms a simple estimate of transit depth from the single event statistic for the purpose
% of seeding the fit.

  transitDurationDays = thresholdCrossingEvent.trialTransitPulseDuration * ...
      get_unit_conversion('hour2day') ;
  fluxTimeSeries = dvDataObject.targetStruct(iTarget).correctedFluxTimeSeries ;
  gapIndicators = fluxTimeSeries.gapIndicators | fluxTimeSeries.uncertainties == -1;
  transitDepth = median( fluxTimeSeries.uncertainties(~gapIndicators) ) / ...
      median( fluxTimeSeries.values(~gapIndicators) ) * ...
      sqrt( cadenceDurationDays / transitDurationDays ) * ...
      thresholdCrossingEvent.maxSingleEventSigma ;
  
% don't allow the transit depth to exceed the total range of values in the flux time
% series

  transitDepth = min( transitDepth, fluxTimeSeriesRange ) ;

% When geometric transit model is used, include the fields 'ratioPlanetRadiusToStarRadius' and 'ratioSemiMajorAxisToStarRadius'
% in the planet model. Otherwise, include the field 'transitDepthPpm' in the planet model
  if strcmp(dvDataObject.dvConfigurationStruct.transitModelName, 'mandel-agol_geometric_transit_model')

    transitDepth_buf = transitDepth;
    if ( transitDepth_buf < 0 )
        transitDepth_buf = 0;
    end
    maxDepth = dvDataObject.planetFitConfigurationStruct.eclipsingBinaryDepthLimitPpm * 1e-6;
    if ( transitDepth_buf > maxDepth )
        transitDepth_buf = maxDepth;
    end
    planetModel.ratioPlanetRadiusToStarRadius  = sqrt(transitDepth_buf);
    
    starRadiusSolarRadii = planetModel.starRadiusSolarRadii;
    if isnan(starRadiusSolarRadii) 
        starRadiusSolarRadii = dvDataObject.planetFitConfigurationStruct.defaultRadius;
        planetModel.starRadiusSolarRadii = starRadiusSolarRadii;
    end
    log10SurfaceGravityValue  = transitModel.log10SurfaceGravity.value;
    if isnan(log10SurfaceGravityValue )
        log10SurfaceGravityValue  = dvDataObject.planetFitConfigurationStruct.defaultLog10SurfaceGravity;
        transitModel.log10SurfaceGravity.value = log10SurfaceGravityValue;
    end

    orbitalPeriodMks     = orbitalPeriodDays             * get_unit_conversion('day2sec');
    starRadiusMks        = starRadiusSolarRadii          * get_unit_conversion('solarRadius2meter');
    gMks                 = 10^(log10SurfaceGravityValue) * get_unit_conversion('cm2meter');
    semiMajorAxisMks     = (orbitalPeriodMks * starRadiusMks * sqrt(gMks) / 2 / pi)^(2/3);
%   planetModel.ratioSemiMajorAxisToStarRadius = semiMajorAxisMks/starRadiusMks; 

%     planetModel.ratioSemiMajorAxisToStarRadius = thresholdCrossingEvent.orbitalPeriod/transitDurationDays/pi * ...
%         sqrt( (1 + planetModel.ratioPlanetRadiusToStarRadius)^2 - (planetModel.minImpactParameter)^2 ); 

    planetModel.ratioSemiMajorAxisToStarRadius = sqrt( ( (1 + planetModel.ratioPlanetRadiusToStarRadius)^2 - (planetModel.minImpactParameter)^2 ) /  ...
                                                       ( sin( pi * transitDurationDays / thresholdCrossingEvent.orbitalPeriod ) )^2 + (planetModel.minImpactParameter)^2 ); 
                                                   
    if ( planetModel.ratioSemiMajorAxisToStarRadius < (1 +  planetModel.ratioPlanetRadiusToStarRadius) )
        disp(['TCE.orbitalPeriod:                  ' num2str(thresholdCrossingEvent.orbitalPeriod)]);
        disp(['transitDurationDays:                ' num2str(transitDurationDays)]);
        disp(['planetModel.ratioPlanetRadiusToRs:  ' num2str(planetModel.ratioPlanetRadiusToStarRadius)]);
        disp(['planetModel.minImpactParameter:     ' num2str(planetModel.minImpactParameter)]);
        disp(['planetModel.ratioSemiMajorAxisToRs: ' num2str(planetModel.ratioSemiMajorAxisToStarRadius)]);
        planetModel.ratioSemiMajorAxisToStarRadius = 1.001 + planetModel.ratioPlanetRadiusToStarRadius;
    end
        
  else                                           

    planetModel.transitDepthPpm = transitDepth * 1e6 ;
    
  end
  

%
% When geometric transit model is used, transitModel.planetModel includes the following 8 fields:
%
%       transitEpochBkjd
%       ratioPlanetRadiusToStarRadius
%       ratioSemiMajorAxisToStarRadius
%       minImpactParameter
%       orbitalPeriodDays
%       eccentricity
%       longitudeOfPeriDegrees
%       starRadiusSolarRadii
%
% Otherwise, transitModel.planetModel includes the following 7 fileds:
%       
%       transitEpochBkjd
%       minImpactParameter
%       transitDepthPpm
%       orbitalPeriodDays
%       eccentricity
%       longitudeOfPeriDegrees
%       starRadiusSolarRadii
%
  
  transitModel.planetModel = planetModel ;
    
return

% and that's it!

