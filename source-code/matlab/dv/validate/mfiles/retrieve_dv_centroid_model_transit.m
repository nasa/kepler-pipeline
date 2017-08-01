function transitModel = retrieve_dv_centroid_model_transit(inputModelStruct, ...
    targetStruct,barycentricTimestamps,planetFitConfigurationStruct, ...
    trapezoidalFitConfigurationStruct,configMaps)
%
% function transitModel = retrieve_dv_centroid_model_transit(inputModelStruct, ...
%     targetStruct,barycentricTimestamps,planetFitConfigurationStruct, ...
%     trapezoidalFitConfigurationStrut, configMaps)
%
% This DV function uses the information in the inputModelStruct along
% with the timestamps to retrieve the model flux time series at these
% timestamps.
%
% These are the legal model paramter names as of 12/16/2010. 
% They can be accessed by calling get_planet_model_legal_fields with
% argument one of {'all','physical','observable','tps-constructor','geometric','physical-observable'}
%
%     field name                     physical  observable tps-constructor  geometric  physical-observable
%     'transitEpochBkjd',              true,     true,        true,       true        true;  ...
%     'eccentricity',                  true,     true,        true,       true        true; ...
%     'longitudeOfPeriDegrees',        true,     true,        true,       true        true; ...
%     'planetRadiusEarthRadii',        true,     false,       false,      false       true; ...
%     'semiMajorAxisAu',               true,     false,       false,      false       true; ...
%     'minImpactParameter',            true,     false,       true,       true        true; ...
%     'starRadiusSolarRadii',          true,     false,       true,       true        true; ...
%     'transitDurationHours',          false,    true,        false,      false       true;  ...
%     'transitIngressTimeHours',       false,    true,        false,      false       true;  ...
%     'transitDepthPpm',               false,    true,        true,       false       true;  ...
%     'orbitalPeriodDays',             false,    true,        true,       true        true;  ...
%     'ratioPlanetRadiusToStarRadius'  false,    false,       false,      true        false;  ...
%     'ratioSemiMajorAxisToStarRadius' false,    false,       false,      true        false } ;
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


% ground truth model is used for testing against ETEM data
if( strcmpi( inputModelStruct.transitModelName, 'groundTruth' ) )
    transitModel = retrieve_model_light_curve_from_ground_truth( inputModelStruct, barycentricTimestamps(:) );
    return;
end

% trapezoidal model is used as fallback if limb darkened model fit to all
% transits is not performed or does not converge
if( strcmpi( inputModelStruct.transitModelName, 'trapezoidal_model' ) )
    generatingModelStruct = trapezoidal_fit_parameters_to_transit_model( ...
        inputModelStruct, targetStruct, barycentricTimestamps(:), ...
        planetFitConfigurationStruct, trapezoidalFitConfigurationStruct, ...
        configMaps);
    generatingModelObject = transitGeneratorClass( generatingModelStruct );
    transitModel = compute_trapezoidal_model_light_curve( generatingModelObject );
    return;
end

% set up transit model input struct
% add field 'radius' and change fields 'log10SurfaceGravity', 'effectiveTemp' and 'log10Metallicity' to structs -- JL, 08/23/2012
generatingModelStruct = struct('cadenceTimes', barycentricTimestamps(:), ...
                                'log10SurfaceGravity', targetStruct.log10SurfaceGravity, ...
                                'effectiveTemp', targetStruct.effectiveTemp, ...
                                'log10Metallicity', targetStruct.log10Metallicity, ...
                                'radius', targetStruct.radius, ...
                                'debugFlag', targetStruct.debugLevel, ...
                                'modelNamesStruct', [], ...
                                'transitBufferCadences', planetFitConfigurationStruct.transitBufferCadences, ...
                                'transitSamplesPerCadence', planetFitConfigurationStruct.transitSamplesPerCadence, ...
                                'smallBodyCutoff', planetFitConfigurationStruct.smallBodyCutoff, ...
                                'configMaps', configMaps, ...
                                'planetModel', []);


% set up model names struct
modelNamesStruct = struct('transitModelName', inputModelStruct.transitModelName, ...
                            'limbDarkeningModelName', inputModelStruct.limbDarkeningModelName);
generatingModelStruct.modelNamesStruct = modelNamesStruct;


% set up planet model struct which varies for different models
if( strcmpi( inputModelStruct.transitModelName, 'gaussian' ) )
    
    parameterFound = false(8,1);
    if( ~isempty(inputModelStruct.modelParameters) )
        [transitEpochStruct,       parameterFound(1)] = retrieve_model_parameter(inputModelStruct.modelParameters, 'transitEpochBkjd');
        [eccentricityStruct,       parameterFound(2)] = retrieve_model_parameter(inputModelStruct.modelParameters, 'eccentricity');
        [longitudeOfPeriStruct,    parameterFound(3)] = retrieve_model_parameter(inputModelStruct.modelParameters, 'longitudeOfPeriDegrees');
        [minImpactParameterStruct, parameterFound(4)] = retrieve_model_parameter(inputModelStruct.modelParameters, 'minImpactParameter');
        [starRadiusStruct,         parameterFound(5)] = retrieve_model_parameter(inputModelStruct.modelParameters, 'starRadiusSolarRadii');
        [transitDepthStruct,       parameterFound(6)] = retrieve_model_parameter(inputModelStruct.modelParameters, 'transitDepthPpm');
        [orbitalPeriodStruct,      parameterFound(7)] = retrieve_model_parameter(inputModelStruct.modelParameters, 'orbitalPeriodDays');
        [durationStruct,           parameterFound(8)] = retrieve_model_parameter(inputModelStruct.modelParameters, 'transitDurationHours');
    end
    
    % return constant model of correct size if insufficient fit info is available
    if( any(~parameterFound) )
        warning('DV:retrieve_dv_centroid_model:InvalidTransitModelParams', ...
            'Transit model parameters unavailable or ambiguous. Returning constant transit model.');
        transitModel = zeros( length(barycentricTimestamps),1);
        return;
    end
    
    planetModel = struct('transitEpochBkjd', transitEpochStruct.value, ...
                            'eccentricity', eccentricityStruct.value, ...
                            'longitudeOfPeriDegrees', longitudeOfPeriStruct.value, ...
                            'minImpactParameter', minImpactParameterStruct.value, ...
                            'starRadiusSolarRadii', starRadiusStruct.value, ...
                            'transitDepthPpm', transitDepthStruct.value, ...
                            'orbitalPeriodDays', orbitalPeriodStruct.value,...
                            'transitDurationHours',durationStruct.value);
    
    generatingModelStruct.planetModel = planetModel;


elseif( strcmpi( inputModelStruct.transitModelName, 'mandel-agol_transit_model' ) )
    
    parameterFound = false(7,1);
    if( ~isempty(inputModelStruct.modelParameters) )
        [transitEpochStruct,       parameterFound(1)] = retrieve_model_parameter(inputModelStruct.modelParameters, 'transitEpochBkjd');
        [eccentricityStruct,       parameterFound(2)] = retrieve_model_parameter(inputModelStruct.modelParameters, 'eccentricity');
        [longitudeOfPeriStruct,    parameterFound(3)] = retrieve_model_parameter(inputModelStruct.modelParameters, 'longitudeOfPeriDegrees');
        [minImpactParameterStruct, parameterFound(4)] = retrieve_model_parameter(inputModelStruct.modelParameters, 'minImpactParameter');
        [starRadiusStruct,         parameterFound(5)] = retrieve_model_parameter(inputModelStruct.modelParameters, 'starRadiusSolarRadii');
        [transitDepthStruct,       parameterFound(6)] = retrieve_model_parameter(inputModelStruct.modelParameters, 'transitDepthPpm');
        [orbitalPeriodStruct,      parameterFound(7)] = retrieve_model_parameter(inputModelStruct.modelParameters, 'orbitalPeriodDays');
    end
    
    % return constant model of correct size if insufficient fit info is available
    if( any(~parameterFound) )
        warning('DV:retrieve_dv_centroid_model:InvalidTransitModelParams', ...
            'Transit model parameters unavailable or ambiguous. Returning constant transit model.');
        transitModel = zeros( length(barycentricTimestamps),1);
        return;
    end
    
    planetModel = struct('transitEpochBkjd', transitEpochStruct.value, ...
                            'eccentricity', eccentricityStruct.value, ...
                            'longitudeOfPeriDegrees', longitudeOfPeriStruct.value, ...
                            'minImpactParameter', minImpactParameterStruct.value, ...
                            'starRadiusSolarRadii', starRadiusStruct.value, ...
                            'transitDepthPpm', transitDepthStruct.value, ...
                            'orbitalPeriodDays', orbitalPeriodStruct.value);
    
    generatingModelStruct.planetModel = planetModel;
    
elseif( strcmpi( inputModelStruct.transitModelName, 'mandel-agol_geometric_transit_model' ))
    
    parameterFound = false(8,1);
    if( ~isempty(inputModelStruct.modelParameters) )
        [transitEpochStruct,       parameterFound(1)] = retrieve_model_parameter(inputModelStruct.modelParameters, 'transitEpochBkjd');
        [eccentricityStruct,       parameterFound(2)] = retrieve_model_parameter(inputModelStruct.modelParameters, 'eccentricity');
        [longitudeOfPeriStruct,    parameterFound(3)] = retrieve_model_parameter(inputModelStruct.modelParameters, 'longitudeOfPeriDegrees');
        [minImpactParameterStruct, parameterFound(4)] = retrieve_model_parameter(inputModelStruct.modelParameters, 'minImpactParameter');        
        [orbitalPeriodStruct,      parameterFound(5)] = retrieve_model_parameter(inputModelStruct.modelParameters, 'orbitalPeriodDays');
        [ratioPlanetRadiusToStarRadiusStruct,  parameterFound(6)] = retrieve_model_parameter(inputModelStruct.modelParameters, 'ratioPlanetRadiusToStarRadius');
        [ratioSemiMajorAxisToStarRadiusStruct, parameterFound(7)] = retrieve_model_parameter(inputModelStruct.modelParameters, 'ratioSemiMajorAxisToStarRadius');
        [starRadiusSolarRadiiStruct, parameterFound(8)] = retrieve_model_parameter(inputModelStruct.modelParameters, 'starRadiusSolarRadii');
    end

    % return constant model of correct size if insufficient fit info is available
    if( any(~parameterFound) )
        warning('DV:retrieve_dv_centroid_model:InvalidTransitModelParams', ...
            'Transit model parameters unavailable or ambiguous. Returning constant transit model.');
        transitModel = zeros( length(barycentricTimestamps),1);
        return;
    end
    
    planetModel = struct('transitEpochBkjd', transitEpochStruct.value, ...
                            'eccentricity', eccentricityStruct.value, ...
                            'longitudeOfPeriDegrees', longitudeOfPeriStruct.value, ...
                            'minImpactParameter', minImpactParameterStruct.value, ...
                            'starRadiusSolarRadii',starRadiusSolarRadiiStruct.value,...
                            'orbitalPeriodDays', orbitalPeriodStruct.value, ...
                            'ratioPlanetRadiusToStarRadius', ratioPlanetRadiusToStarRadiusStruct.value, ...
                            'ratioSemiMajorAxisToStarRadius', ratioSemiMajorAxisToStarRadiusStruct.value);
    
    generatingModelStruct.planetModel = planetModel;
    
end


% make model generating object
generatingModelObject = transitGeneratorClass(generatingModelStruct);

% generate model
transitModel = generate_planet_model_light_curve(generatingModelObject);


return;

