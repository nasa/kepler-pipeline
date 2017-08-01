function monteCarloResults = run_signal_template_mismatch_monte_carlo( stellarParameters, ...
    tpsInputStruct, nIterations )

% trim the stellar parameters
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
spIndicator = stellarParameters.radius < prctile(stellarParameters.radius,95) & ...
    stellarParameters.radius > prctile(stellarParameters.radius,5) & ...
    stellarParameters.log10SurfaceGravity < prctile(stellarParameters.log10SurfaceGravity,95) & ...
    stellarParameters.log10SurfaceGravity > prctile(stellarParameters.log10SurfaceGravity,5) & ...
    stellarParameters.log10Metallicity < prctile(stellarParameters.log10Metallicity,95) & ...
    stellarParameters.log10Metallicity > prctile(stellarParameters.log10Metallicity,5) & ...
    stellarParameters.effectiveTemp < prctile(stellarParameters.effectiveTemp,95) & ...
    stellarParameters.effectiveTemp > prctile(stellarParameters.effectiveTemp,5);

stellarParameters.keplerId = stellarParameters.keplerId(spIndicator);
stellarParameters.radius = stellarParameters.radius(spIndicator);
stellarParameters.log10SurfaceGravity = stellarParameters.log10SurfaceGravity(spIndicator);
stellarParameters.log10Metallicity = stellarParameters.log10Metallicity(spIndicator);
stellarParameters.effectiveTemp = stellarParameters.effectiveTemp(spIndicator);
stellarParameters.kepMag = stellarParameters.kepMag(spIndicator);
    
% explicitly set the superResolutionFactor to 1
tpsInputStruct.tpsModuleParameters.superResolutionFactor = 1;

% validate a temp input to get added fields for use below
tpsInputStruct = validate_tps_input_structure( tpsInputStruct );

% configuration parameters
tpsModuleParameters = tpsInputStruct.tpsModuleParameters;
superResolutionFactor = tpsModuleParameters.superResolutionFactor;
rho = tpsModuleParameters.searchPeriodStepControlFactor;
cadencesPerHour = tpsModuleParameters.cadencesPerHour;
cadencesPerDay = tpsModuleParameters.cadencesPerDay;
cadenceTimes = tpsInputStruct.cadenceTimes;
minSesInMes = tpsModuleParameters.minSesInMesCount;
nStellarParams = length(stellarParameters.keplerId) ;
nCadences = length(tpsInputStruct.tpsTargets.fluxValue);

minPlanetRadiusEarthRadii = 0.5;
maxPlanetRadiusEarthRadii = 10;
radiusSamplingMethod = 'uniformLog';
minImpactParameter = 0;
maxImpactParameter = 0.95;
randSeedOffset = 11;
periodSamplingMethod = 'uniformLog';

% validate a temp input to get added fields for use below
tpsInputStruct = validate_tps_input_structure( tpsInputStruct );

% compute the set of pulse durations searched
pulseDurationsInHours = compute_trial_transit_durations(tpsModuleParameters);

% get filter coeffs
h0 = daubechies_low_pass_scaling_filter(tpsModuleParameters.waveletFilterLength);

% get the min/max period
minPeriodDays = tpsInputStruct.tpsModuleParameters.minimumSearchPeriodInDays;
maxPeriodDays = tpsInputStruct.tpsModuleParameters.maximumSearchPeriodInDays;

% get the earliest epoch
gapIndicators = cadenceTimes.gapIndicators;
cadenceTimes = cadenceTimes.midTimestamps;
cadenceTimes(gapIndicators) = interp1( find(~gapIndicators), ...
    cadenceTimes(~gapIndicators), find(gapIndicators), 'linear', 'extrap' ) ;
cadenceTimes = cadenceTimes - kjd_offset_from_mjd ;
earliestAllowedEpoch = cadenceTimes(1) ;
endTimestamp = cadenceTimes(end) ;

progressReports = 1:10:nIterations ;
misMatchVect = zeros(nIterations,1);
injectedDurationVect = zeros(nIterations,1);
injectedPeriodVect = zeros(nIterations,1);

for i=1:nIterations
    
    % spit out progress info
    if ( ismember( i, progressReports ) )
        disp( [ 'starting loop iteration number ', num2str(i), ...
            ' out of ', num2str(nIterations),' total loop iterations' ] ) ;
        pause(1) ;
        monteCarloResults.misMatchVect = misMatchVect;
        monteCarloResults.injectedDurationVect = injectedDurationVect;
        monteCarloResults.injectedPeriodVect = injectedPeriodVect;
        save monteCarloResults.mat monteCarloResults;
    end
    injectedDurationHours = 0;
    iAttempt = 0;
    
    while (injectedDurationHours < 0.5 || injectedDurationHours > 15 && iAttempt < 3)
        iAttempt = iAttempt + 1;
        % set the random seed for this iteration
        s = RandStream('mcg16807','Seed',i+randSeedOffset);
        RandStream.setDefaultStream(s);

        % sample orbital parameters
        injectedPeriodDays = generate_random_sample( minPeriodDays, maxPeriodDays, periodSamplingMethod);
        injectedPlanetRadiusEarthRadii = generate_random_sample( minPlanetRadiusEarthRadii, ...
            maxPlanetRadiusEarthRadii, radiusSamplingMethod );
        injectedImpactParameter = generate_random_sample( minImpactParameter, maxImpactParameter, 'uniform' );

        % get the epoch
        maxEpoch = min( injectedPeriodDays + earliestAllowedEpoch - 1/cadencesPerDay, ...
            endTimestamp - injectedPeriodDays * (minSesInMes - 1) );
        injectedEpoch = earliestAllowedEpoch + (maxEpoch - earliestAllowedEpoch) * rand(1,1);

        % grab a random set of stellar parameters for limb darkening
        iStellarParams = randi([1 nStellarParams],1,1);
        log10SurfaceGravity = stellarParameters.log10SurfaceGravity(iStellarParams) ;
        effectiveTemp = stellarParameters.effectiveTemp(iStellarParams) ;
        log10Metallicity = stellarParameters.log10Metallicity(iStellarParams) ;
        radius = stellarParameters.radius(iStellarParams);

        % construct the timing information struct
        timeParametersStruct.exposureTimeSec        = 6.0198029032704 ;
        timeParametersStruct.readoutTimeSec         = 0.518948526144 ;
        timeParametersStruct.numExposuresPerCadence = 270 ;

        % construct the model name struct
        modelNamesStruct.transitModelName       = 'mandel-agol_geometric_transit_model' ;
        modelNamesStruct.limbDarkeningModelName = 'kepler_nonlinear_limb_darkening_model' ;

        % convert radii to common  units
        stellarRadiusMks = radius * get_unit_conversion('solarRadius2meter') ;
        planetRadiusMks = injectedPlanetRadiusEarthRadii * get_unit_conversion('earthRadius2meter') ;

        % compute the semiMajor axis from keplers laws
        gMks = 10^(log10SurfaceGravity) * get_unit_conversion('cm2meter') ;
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
        planetModel.starRadiusSolarRadii   = radius ;

        % build the struct for instantiating the transit object
        transitStruct.cadenceTimes              = cadenceTimes ;
        transitStruct.log10SurfaceGravity.value = log10SurfaceGravity ;
        transitStruct.effectiveTemp.value       = effectiveTemp ;
        transitStruct.log10Metallicity.value    = log10Metallicity ;
        transitStruct.radius.value              = radius ;
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
        [planetInformation, astroModel] = generate_planet_information(transitStruct);
        injectedDurationHours = planetInformation.planetModel.transitDurationHours;
    end
    
    %%%%%%%%%%%%%%%%%%% generate the TPS model %%%%%%%%%%%%%%%%%%%%%%%%%%%%  
    
    maxMatch = -1;

    [~,durationIndex] = sort( abs(pulseDurationsInHours - injectedDurationHours) );
    tempDurations = pulseDurationsInHours(durationIndex(1:12));
    for iDuration = 1:length(tempDurations)
        possiblePeriodsInCadences = compute_search_periods( tpsModuleParameters, ...
            tempDurations(iDuration), nCadences );
        [~,periodIndex] = sort( abs(possiblePeriodsInCadences - injectedPeriodDays*cadencesPerDay) );
        tempPeriods = possiblePeriodsInCadences(periodIndex(1:5));
        for iPeriod = 1:length(tempPeriods)
            deltaLagInCadences = compute_phase_lag_in_cadences( tempDurations(iDuration), ...
                cadencesPerHour, superResolutionFactor, rho ) ;
            possiblePhases = deltaLagInCadences:deltaLagInCadences:tempPeriods(iPeriod);
            injectedEpochCadences = (injectedEpoch - earliestAllowedEpoch) * cadencesPerDay + 1;
            [~,epochIndex] = sort( abs(possiblePhases - injectedEpochCadences) );
            tempPhases = possiblePhases(epochIndex(1:5));
            for iPhase = 1:length(tempPhases)
                % get the ses indices
                [indexOfSesAdded, sesCombinedToYieldMes] = ...
                    find_index_of_ses_added_to_yield_mes( tempPeriods(iPeriod), ...
                    tempPhases(iPhase), superResolutionFactor, ones(nCadences,1), ...
                    ones(nCadences,1), ones(nCadences,1));
                
                % build the superResolutionObject
                superResolutionStruct = struct('superResolutionFactor', superResolutionFactor, ...
                    'pulseDurationInCadences', tempDurations(iDuration), 'usePolyFitTransitModel', ...
                    true ) ;
                superResolutionObject = superResolutionClass( superResolutionStruct, h0 ) ;
                superResolutionObject = set_statistics_time_series_shift_length( superResolutionObject) ; 
                
                % build the transit model
                tpsModel = generate_trial_transit_pulse_train( superResolutionObject, ...
                    indexOfSesAdded, nCadences ) ; 
                
                % compute the match and update if necessary
                tempMatch = sum((tpsModel./norm(tpsModel)) .* (astroModel./norm(astroModel)));
                
                if tempMatch > maxMatch
                    maxMatch = tempMatch;
                end
            end
        end     
    end
    
    misMatchVect(i) = 1 - maxMatch;
    injectedDurationVect(i) = injectedDurationHours;
    injectedPeriodVect(i) = injectedPeriodDays;

end

monteCarloResults.misMatchVect = misMatchVect;
monteCarloResults.injectedDurationVect = injectedDurationVect;
monteCarloResults.injectedPeriodVect = injectedPeriodVect;
save monteCarloResults.mat monteCarloResults;

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