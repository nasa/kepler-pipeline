function [tpsInputStruct, isValidInjection] = inject_transit_signal( ...
    tpsInputStruct, injectionParametersStruct )
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function inject_transit_signal(tpsInputStruct, ...
%    injectedPeriodDays, injectedPlanetRadiusInEarthRadii, injectedImpactParameter )
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Description:
% Inputs:
% Outputs:
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
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

% initialize output
isValidInjection = false;

% extract inputs
tpsModuleParameters       = tpsInputStruct.tpsModuleParameters;
tpsTargets                = tpsInputStruct.tpsTargets;
rmsCdppValues                   = tpsTargets.rmsCdpp;
cadenceTimes              = tpsInputStruct.cadenceTimes.midTimestamps ;
gapIndicators             = tpsInputStruct.cadenceTimes.gapIndicators;
minSesInMes               = tpsModuleParameters.minSesInMesCount;
cadencesPerDay            = tpsModuleParameters.cadencesPerDay;
minPeriodDays             = injectionParametersStruct.minPeriodDays;
maxPeriodDays             = injectionParametersStruct.maxPeriodDays;
periodSamplingMethod      = injectionParametersStruct.periodSamplingMethod;
minPlanetRadiusEarthRadii = injectionParametersStruct.minPlanetRadiusEarthRadii;
maxPlanetRadiusEarthRadii = injectionParametersStruct.maxPlanetRadiusEarthRadii;
radiusSamplingMethod      = injectionParametersStruct.radiusSamplingMethod;
minImpactParameter        = injectionParametersStruct.minImpactParameter;
maxImpactParameter        = injectionParametersStruct.maxImpactParameter;
fractionToSampleByMes     = injectionParametersStruct.fractionToSampleByMes;
mesSamplingMinMes         = injectionParametersStruct.mesSamplingMinMes;
mesSamplingMaxMes         = injectionParametersStruct.mesSamplingMaxMes;
mesSamplingMethod         = injectionParametersStruct.mesSamplingMethod;
minPeriodOverride         = injectionParametersStruct.minPeriodOverride;
alwaysInject              = injectionParametersStruct.alwaysInject;
maxNumberOfAttempts       = injectionParametersStruct.maxNumberOfAttempts;
deemphasisWeights         = injectionParametersStruct.deemphasisWeights;
nCadences                 = length(gapIndicators);

% compute the set of pulse durations searched
pulseDurationsInHours = compute_trial_transit_durations(tpsModuleParameters);

% override the maxPeriod if necessary
if ~alwaysInject
    maxPeriodDays = min(maxPeriodDays, dataSpanInCadences/cadencesPerDay/2);
end

% override the minimum period if necessary
if minPeriodOverride > minPeriodDays
    minPeriodDays = minPeriodOverride;
end

% sample continuous parameter distributions for injected period, radius,
% and impact parameter
injectedPeriodDays = generate_random_sample( minPeriodDays, maxPeriodDays, periodSamplingMethod);
injectedPlanetRadiusEarthRadii = generate_random_sample( minPlanetRadiusEarthRadii, ...
    maxPlanetRadiusEarthRadii, radiusSamplingMethod );
injectedImpactParameter = generate_random_sample( minImpactParameter, maxImpactParameter, 'uniform' );

% get start timestamps to determine earliest epoch allowed
cadenceTimes(gapIndicators) = interp1( find(~gapIndicators), ...
    cadenceTimes(~gapIndicators), find(gapIndicators), 'linear', 'extrap' ) ;
cadenceTimes = cadenceTimes - kjd_offset_from_mjd ;
earliestAllowedEpoch = cadenceTimes(1) ;
endTimestamp = cadenceTimes(end) ;

% set the max epoch to avoid having less than minSesInMes transits and make
% sure it is less than the period
if ~alwaysInject
    maxEpoch = min( injectedPeriodDays + earliestAllowedEpoch - 1/cadencesPerDay, ...
        endTimestamp - injectedPeriodDays * (minSesInMes - 1) );
else
    maxEpoch = injectedPeriodDays + earliestAllowedEpoch - 1/cadencesPerDay;
end

% initialize loop variable
numberOfAttempts = 1;

while (~isValidInjection && numberOfAttempts <= maxNumberOfAttempts)
    % increment the number of attempts
    numberOfAttempts = numberOfAttempts + 1;
    
    % randomly sample the epoch
    injectedEpoch = earliestAllowedEpoch + (maxEpoch - earliestAllowedEpoch) * rand(1,1);

    % check if there are 3 transits
    [~, sesCombined] = find_index_of_ses_added_to_yield_mes( injectedPeriodDays*cadencesPerDay, ...
        (injectedEpoch-earliestAllowedEpoch)*cadencesPerDay, 1, ones(nCadences,1), ...
        ones(nCadences,1), deemphasisWeights );

    % get the number of transits in valid data
    nTransits = sum(sesCombined ~= 0);

    % check if the nTransits is sufficient
    if nTransits < minSesInMes
        isValidInjection = false;
    else
        isValidInjection = true;
    end
end

if isValidInjection || (~isValidInjection && alwaysInject)
    % construct the timing information struct
    timeParametersStruct.exposureTimeSec        = 6.0198029032704 ;
    timeParametersStruct.readoutTimeSec         = 0.518948526144 ;
    timeParametersStruct.numExposuresPerCadence = 270 ;

    % construct the model name struct
    modelNamesStruct.transitModelName       = 'mandel-agol_geometric_transit_model' ;
    modelNamesStruct.limbDarkeningModelName = 'kepler_nonlinear_limb_darkening_model' ;

    % convert radii to common  units
    stellarRadiusMks = tpsTargets.radius * get_unit_conversion('solarRadius2meter') ;
    planetRadiusMks = injectedPlanetRadiusEarthRadii * get_unit_conversion('earthRadius2meter') ;

    % compute the semiMajor axis from keplers laws
    gMks = 10^(tpsTargets.log10SurfaceGravity) * get_unit_conversion('cm2meter') ;
    orbitalPeriodMks    = injectedPeriodDays * get_unit_conversion('day2sec') ;
    semiMajorAxisMks = (orbitalPeriodMks * stellarRadiusMks * sqrt(gMks) / 2 / pi)^(2/3) ;

    % add parameters to the planet model
    planetModel.transitEpochBkjd = injectedEpoch ;
    planetModel.minImpactParameter = injectedImpactParameter ;
    planetModel.orbitalPeriodDays = injectedPeriodDays ;
    %planetModel.transitDepthPpm = (planetRadiusMks / stellarRadiusMks)^2 * 1e6 ;
    planetModel.ratioPlanetRadiusToStarRadius = planetRadiusMks / stellarRadiusMks;
    planetModel.ratioSemiMajorAxisToStarRadius = semiMajorAxisMks / stellarRadiusMks;
    planetModel.eccentricity           = 0 ;
    planetModel.longitudeOfPeriDegrees = 0 ;
    planetModel.starRadiusSolarRadii   = tpsTargets.radius ;

    % build the struct for instantiating the transit object
    transitStruct.cadenceTimes              = cadenceTimes ;
    transitStruct.log10SurfaceGravity.value = tpsTargets.log10SurfaceGravity ;
    transitStruct.effectiveTemp.value       = tpsTargets.effectiveTemp ;
    transitStruct.log10Metallicity.value    = tpsTargets.log10Metallicity ;
    transitStruct.radius.value              = tpsTargets.radius ;
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

    % generate the planet information using the transit generate class
    [planetInformation, lightCurve] = generate_planet_information(transitStruct);
    
    % if we are sampling by MES then check to see if we need to adjust the
    % planet radius and regenerate the model
    if rand(1,1) < fractionToSampleByMes
        nTransits = length(sesCombined);  % include all transits, even gapped ones
        injectedDepth = abs( min(lightCurve) );
        injectedDurationHours = planetInformation.planetModel.transitDurationHours;
        rmsCdpp = interp1(pulseDurationsInHours,rmsCdppValues,injectedDurationHours,'linear', NaN);
        
        % if the duration is out of range then choose the closest value
        if isnan(rmsCdpp)
            absDiff = abs( injectedDurationHours - pulseDurationsInHours );
            rmsCdpp = rmsCdppValues( absDiff == min(absDiff) );
        end
        
        % compute the MES Estimate
        mesEstimate = injectedDepth * 1e6 * sqrt(nTransits) / rmsCdpp;
        
        % sample to get a new MES
        mesEstimate = generate_random_sample( mesSamplingMinMes, mesSamplingMaxMes, mesSamplingMethod );

        % compute a new planet radius to approximately achieve the MES
        injectedPlanetRadiusEarthRadii = injectedPlanetRadiusEarthRadii * ...
            sqrt( mesEstimate * rmsCdpp / ( 1e6 * injectedDepth * sqrt(nTransits) ) );

        if ~(injectedPlanetRadiusEarthRadii < minPlanetRadiusEarthRadii || ...
                injectedPlanetRadiusEarthRadii > maxPlanetRadiusEarthRadii)
            % recompute the model
            planetRadiusMks = injectedPlanetRadiusEarthRadii * get_unit_conversion('earthRadius2meter') ;
            planetModel.ratioPlanetRadiusToStarRadius = planetRadiusMks / stellarRadiusMks;
            transitStruct.planetModel = planetModel ;

            % generate the planet information using the transit generate class
            [planetInformation, lightCurve] = generate_planet_information(transitStruct);
        end
        
    end
        
    % remove gaps
    fillIndices = tpsTargets.fillIndices ;
    lightCurve(fillIndices) = 0 ;
    
    % add the light curve to the flux
    addedPlanetStruct.lightCurve = lightCurve ;
    addedPlanetStruct.planetInformation = planetInformation ;
    tpsTargets.diagnostics.addedPlanetStruct = addedPlanetStruct ;
    tpsTargets.fluxValue = tpsTargets.fluxValue  + lightCurve ;  % just flux + model since its all relative
    tpsInputStruct.tpsTargets = tpsTargets;
    isValidInjection = true;
end

return


%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% generate_random_sample:  generate a random sample by sampling according the
% the samplingMethod between the minParameterValue and maxParameterValue
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
function randomSample = generate_random_sample( minParameterValue, maxParameterValue, samplingMethod)

if ~( strcmp(samplingMethod, 'uniformLog') || strcmp(samplingMethod, 'uniform') )
    error('inject_transit_signal:samplingMethod', ...
            'The samplingMethod must be uniformLog or uniform. Cant proceed! \n');
end

if strcmp(samplingMethod, 'uniformLog')
    randomSample = 10^(log10(minParameterValue) + (log10(maxParameterValue) - log10(minParameterValue)) * rand(1,1)); 
else
    randomSample = minParameterValue + (maxParameterValue - minParameterValue) * rand(1,1);
end

return

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% generate_planet_information: generate the planetInformationStruct and 
% the light curve from the transitObject
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
function [planetInformation, lightCurve] = generate_planet_information(transitStruct)

% build the object
transitObject = transitGeneratorClass( transitStruct ) ;

% get the planetInformationStruct
planetInformation = get(transitObject,'*') ;

% generate the light curve
lightCurve = generate_planet_model_light_curve( transitObject ) ;

return