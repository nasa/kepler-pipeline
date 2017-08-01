function transitModel = convert_tps_parameters_to_geometric_transit_model(...
    dvInputsStruct, iTarget, targetFluxTimeSeries)
%
% function to estimate the physical parameters which correspond to a given
% threshold crossing event, and return them in the format of a struct which
% instantiates a transitGeneratorClass object
%
% examples:
%
% transitModel = convert_tps_parameters_to_geometric_transit_model(inputsStruct, 1, 1)
%
%
% When geometric transit model is used, transitModel.planetModel includes the following 8 fields:
%
%       transitEpochBkjd
%       orbitalPeriodDays
%       minImpactParameter
%       ratioPlanetRadiusToStarRadius
%       ratioSemiMajorAxisToStarRadius
%       eccentricity
%       longitudeOfPeriDegrees
%       starRadiusSolarRadii
%
% Otherwise, transitModel.planetModel includes the following 7 fields:
%
%       transitEpochBkjd
%       orbitalPeriodDays
%       minImpactParameter
%       transitDepthPpm
%       eccentricity
%       longitudeOfPeriDegrees
%       starRadiusSolarRadii
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



%--------------------------------------------------------------------------
% get the cadence duration based on first cadence (which we don't expect to
% change at this time)
%--------------------------------------------------------------------------
configMapObject = configMapClass(dvInputsStruct.configMaps);

mjd = dvInputsStruct.dvCadenceTimes.midTimestamps(1);
exposureTimeSec = get_exposure_time( configMapObject, mjd);
readoutTimeSec = get_readout_time( configMapObject, mjd);
numExposuresPerCadence = ...
    get_number_of_exposures_per_long_cadence_period( configMapObject, mjd) ;

cadenceDurationDays = numExposuresPerCadence * (exposureTimeSec + readoutTimeSec) * ...
    get_unit_conversion('sec2day') ;


%--------------------------------------------------------------------------
% get the range of flux time series values in valid cadences
%--------------------------------------------------------------------------
if exist( 'targetFluxTimeSeries', 'var' ) && ~isempty(targetFluxTimeSeries)
    
    gapIndicators = targetFluxTimeSeries.gapIndicators;
    gapIndicators(targetFluxTimeSeries.filledIndices) = true;
    fluxTimeSeriesRange = range(targetFluxTimeSeries.values(~gapIndicators));
else
    
    fluxTimeSeriesRange = 1;
end


%--------------------------------------------------------------------------
% compute barycentric times
%--------------------------------------------------------------------------
% dvInputsStruct = compute_barycentric_corrected_timestamps(dvInputsStruct);
%
% barycentricCadenceTimes = dvInputsStruct.barycentricCadenceTimes(iTarget) ;
% transitModel.cadenceTimes = barycentricCadenceTimes.midTimestamps ;

load barycentricCadenceTimes
transitModel.cadenceTimes = barycentricCadenceTimes(iTarget).midTimestamps;

%--------------------------------------------------------------------------
% extract stellar parameters
%--------------------------------------------------------------------------
transitModel.log10SurfaceGravity = ...
    dvInputsStruct.targetStruct(iTarget).log10SurfaceGravity.value;

transitModel.effectiveTemp = ...
    dvInputsStruct.targetStruct(iTarget).effectiveTemp.value;


% extract the log metallicity from the input kics struct if available
if isfield(dvInputsStruct, 'kics')
    
    targetKeplerID = dvInputsStruct.targetStruct(iTarget).keplerId;
    allTargetKeplerIDs = [dvInputsStruct.kics.keplerId]';
    
    transitModel.log10Metallicity = dvInputsStruct.kics(ismember(allTargetKeplerIDs, targetKeplerID)).log10Metallicity.value ;
end


if ( dvInputsStruct.dvConfigurationStruct.debugLevel > 3)
    transitModel.debugFlag = true;
else
    transitModel.debugFlag = false;
end


%--------------------------------------------------------------------------
% fill in the names of the models which will be used
%--------------------------------------------------------------------------
transitModelName = dvInputsStruct.dvConfigurationStruct.transitModelName;
limbDarkeningModelName = dvInputsStruct.dvConfigurationStruct.limbDarkeningModelName;

transitModel.modelNamesStruct.transitModelName = transitModelName;

transitModel.modelNamesStruct.limbDarkeningModelName = limbDarkeningModelName;


%--------------------------------------------------------------------------
% fill in the transit buffer cadences and config map information
%--------------------------------------------------------------------------
transitModel.transitBufferCadences = ...
    dvInputsStruct.planetFitConfigurationStruct.transitBufferCadences;


% add num samples per cadence if applicable
if strcmpi(transitModelName, 'mandel-agol_geometric_transit_model')
    
    if isfield(dvInputsStruct.planetFitConfigurationStruct, 'transitSamplesPerCadence')
        transitModel.transitSamplesPerCadence = dvInputsStruct.planetFitConfigurationStruct.transitSamplesPerCadence;
    else
        transitModel.transitSamplesPerCadence = 11;
    end
end

transitModel.configMaps = dvInputsStruct.configMaps ;


%--------------------------------------------------------------------------
% Now fill the planet model -- for test purposes, we will hand-construct a physical
% parameter set from the combination of orbital period, transit depth, star radius, and
% the minimum impact parameter, which is forced to zero (central transit).  At this time,
% set eccentricity and longitude of periastron to zero (we don't use these in DV 1, but
% they may come up later).
%--------------------------------------------------------------------------
% extract TCE
thresholdCrossingEvent = dvInputsStruct.targetStruct(iTarget).thresholdCrossingEvent;

planetModel.transitEpochBkjd = thresholdCrossingEvent.epochMjd - kjd_offset_from_mjd ;
planetModel.eccentricity = 0;
planetModel.longitudeOfPeriDegrees = 0;
planetModel.minImpactParameter = 0;
planetModel.starRadiusSolarRadii = dvInputsStruct.targetStruct(iTarget).radius.value;


%--------------------------------------------------------------------------
% TPS doesn't determine anything which is quite comparable to the transit depth, but it
% does estimate the max single event statistic in sigmas; this is, very roughly, the ratio
% of the transit depth to the noise amplitude for a single transit.  The code block below
% does a somewhat hokey job of estimating the transit depth from the single event
% statistic.  It's probably not a very good estimator, but good enough (I hope!) for
% seeding the fit with.
%--------------------------------------------------------------------------
transitDurationDays = thresholdCrossingEvent.trialTransitPulseDuration * ...
    get_unit_conversion('hour2day');

fluxTimeSeries = dvInputsStruct.targetStruct(iTarget).correctedFluxTimeSeries;

transitDepth = median(fluxTimeSeries.uncertainties) / ...
    median(fluxTimeSeries.values) * ...
    sqrt( cadenceDurationDays / transitDurationDays) * ...
    thresholdCrossingEvent.maxSingleEventSigma ;


% don't allow the transit depth to exceed the total range of values in the flux time
% series
transitDepth = min(transitDepth, fluxTimeSeriesRange);


%--------------------------------------------------------------------------
% When geometric transit model is used, include the fields 'ratioPlanetRadiusToStarRadius'
% and 'ratioSemiMajorAxisToStarRadius' in the planet model. Otherwise, include
% the field 'transitDepthPpm' in the planet model
%--------------------------------------------------------------------------
if strcmp(transitModelName, 'mandel-agol_geometric_transit_model')
    
    transitDepth_buf = transitDepth;
    if ( transitDepth_buf<0 )
        transitDepth_buf = 0;
    end
    planetModel.ratioPlanetRadiusToStarRadius  = sqrt(transitDepth_buf);
    planetModel.ratioSemiMajorAxisToStarRadius = thresholdCrossingEvent.orbitalPeriod/transitDurationDays/pi * ...
        sqrt( (1 + planetModel.ratioPlanetRadiusToStarRadius)^2 - (planetModel.minImpactParameter)^2 );
else
    
    planetModel.transitDepthPpm = transitDepth * 1e6;
end

planetModel.orbitalPeriodDays = thresholdCrossingEvent.orbitalPeriod;



transitModel.planetModel = planetModel ;


return;

