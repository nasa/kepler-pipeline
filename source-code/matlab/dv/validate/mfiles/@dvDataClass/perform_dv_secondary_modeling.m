function [dvResultsStruct] = perform_dv_secondary_modeling( ...
dvDataObject, dvResultsStruct, iTarget, iPlanet)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [dvResultsStruct] = perform_dv_secondary_modeling( ...
% dvDataObject, dvResultsStruct, iTarget, iPlanet )
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Compute the geometric albedo and planet effective temperature (with
% associated uncertainties) based on the depth of the secondary event
% (fitted in TPS and passed in to DV). Compare the geometric albedo
% statistically against 1 and compare the planet effective temperature
% statisticaly against the equilibrium temperature. If the albedo > 1 or
% the effective temperature > equilibrium temperature the target is likely
% to be a (foreground) eclipsing binary. Update the secondaryEventResults
% structure in the dvResultsStruct with the new parameter
% values/uncertainties and comparison test statistics/significances.
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

% Set constant.
PPM_TO_FRACTION = 1e-6;

% Get physical constants: astronomical unit and Earth radius in meters.
astronomicalUnitMeters = get_physical_constants_mks('astronomicalUnit');
earthRadiusMeters = get_physical_constants_mks('earthRadius');
solarRadiusMeters = get_physical_constants_mks('solarRadius');

% Get required fields for the given target and planet candidate. Return if
% weak secondary test is not enabled. Return if transiting planet model fit
% was not successful or weak secondary info from TPS is invalid.
dvConfigurationStruct = dvDataObject.dvConfigurationStruct;
weakSecondaryTestEnabled = dvConfigurationStruct.weakSecondaryTestEnabled;
if ~weakSecondaryTestEnabled
    return
end % if

targetStruct = dvDataObject.targetStruct(iTarget);
stellarEffectiveTempStruct = targetStruct.effectiveTemp;
radiusStruct = targetStruct.radius;
targetResultsStruct = dvResultsStruct.targetResultsStruct(iTarget);
planetResultsStruct = targetResultsStruct.planetResultsStruct(iPlanet);
allTransitsFit = planetResultsStruct.allTransitsFit;
modelChiSquare = allTransitsFit.modelChiSquare;
modelParameters = allTransitsFit.modelParameters;
modelParameterCovariance = allTransitsFit.modelParameterCovariance;

if modelChiSquare == -1
    return
end % if

[semiMajorAxisStruct] = ...
    retrieve_model_parameter(modelParameters, 'semiMajorAxisAu');
[planetRadiusStruct] = ...
    retrieve_model_parameter(modelParameters, 'planetRadiusEarthRadii');
[reducedRadiusStruct] = ...
    retrieve_model_parameter(modelParameters, 'ratioPlanetRadiusToStarRadius');
[equilibriumTempStruct] = ...
    retrieve_model_parameter(modelParameters, 'equilibriumTempKelvin');

planetCandidate = planetResultsStruct.planetCandidate;
weakSecondaryStruct = planetCandidate.weakSecondaryStruct;
mesMad = weakSecondaryStruct.mesMad;
depthStruct = weakSecondaryStruct.depthPpm;

if mesMad == -1 || depthStruct.uncertainty <= 0 || depthStruct.value <= 0
    return
end % if

secondaryEventResults = planetResultsStruct.secondaryEventResults;

% Compute the geometric albedo and associated uncertainty. For the purpose
% of nomenclature, T = transformation matrix, C = covariance matrix, J =
% Jacobian, d = depth, a = semi-major axis, r = planet radius. Also perform
% a statistical comparison test. Do not compute the geometric albedo if the
% orbit parameters are non-physical.
depth = depthStruct.value * PPM_TO_FRACTION;
semiMajorAxis = semiMajorAxisStruct.value * astronomicalUnitMeters;
planetRadius = planetRadiusStruct.value * earthRadiusMeters;
stellarRadius = radiusStruct.value * solarRadiusMeters;

if semiMajorAxisStruct.uncertainty ~= -1 && ...
        semiMajorAxis > stellarRadius + planetRadius && ...
        planetRadiusStruct.uncertainty ~= -1
    
    % Compute the geometric albedo and uncertainty.
    geometricAlbedoValue = depth * semiMajorAxis^2 / planetRadius^2;

    Tar = [astronomicalUnitMeters, 0; 0, earthRadiusMeters];
    Car = Tar * ...
        retrieve_model_parameter_covariance(modelParameters, ...
        modelParameterCovariance, ...
        {'semiMajorAxisAu', 'planetRadiusEarthRadii'}) * Tar';

    Cdar = zeros(3, 3);
    Cdar(1, 1) = PPM_TO_FRACTION * depthStruct.uncertainty^2 * PPM_TO_FRACTION;
    Cdar(2:3, 2:3) = Car;

    Jdar = ...
        [geometricAlbedoValue / depth, ...
         2 * geometricAlbedoValue / semiMajorAxis, ...
        -2 * geometricAlbedoValue / planetRadius];

    geometricAlbedoUncertainty = sqrt(Jdar * Cdar * Jdar');

    % Perform the comparison test. Geometric albedo is compared
    % statistically against 1.
    albedoComparisonStatisticValue = ...
        (geometricAlbedoValue - 1) / geometricAlbedoUncertainty;
    albedoComparisonStatisticSignificance = ...
        1 - normcdf(albedoComparisonStatisticValue, 0, 1);
    
    % Populate the secondary event results structure.
    secondaryEventResults.planetParameters.geometricAlbedo.value = ...
        geometricAlbedoValue;
    secondaryEventResults.planetParameters.geometricAlbedo.uncertainty = ...
        geometricAlbedoUncertainty;
    
    secondaryEventResults.comparisonTests.albedoComparisonStatistic.value = ...
        albedoComparisonStatisticValue;
    secondaryEventResults.comparisonTests.albedoComparisonStatistic.significance = ...
        albedoComparisonStatisticSignificance;
    
end % if

% Compute the planet effective temperature and associated uncertainty. For
% the purpose of nomenclature, C = covariance matrix, J = Jacobian,
% d = depth, u = reduced radius (Rp/R*), t = stellar effective temperature.
% Also perform a statistical comparison test. Do this only as long as the
% equilibrium temperature is valid and the orbit parameters are sensible.
% Note that equilibrium temperature is bogus if the orbit is bogus; the
% point of this test is to compare the planet effective temperature against
% the equilibrium temperature.
reducedRadius = reducedRadiusStruct.value;
stellarEffectiveTemp = stellarEffectiveTempStruct.value;

if equilibriumTempStruct.uncertainty ~= -1 && ...
        equilibriumTempStruct.value < stellarEffectiveTemp && ...
        semiMajorAxisStruct.uncertainty ~= -1 && ...
        semiMajorAxis > stellarRadius + planetRadius
        
    planetEffectiveTempValue = ...
        depth^(1/4) * stellarEffectiveTemp / sqrt(reducedRadius);

    Cdut = zeros(3, 3);
    Cdut(1, 1) = Cdar(1, 1);
    Cdut(2, 2) = reducedRadiusStruct.uncertainty^2;
    Cdut(3, 3) = stellarEffectiveTempStruct.uncertainty^2;

    Jdut = ...
        [0.25 * planetEffectiveTempValue / depth, ...
        -0.5 * planetEffectiveTempValue / reducedRadius, ...
         planetEffectiveTempValue / stellarEffectiveTemp];

    planetEffectiveTempUncertainty = sqrt(Jdut * Cdut * Jdut');

    % Perform the comparison test. Planet effective temperature is compared
    % statistically against equilibrium temperature.
    tempComparisonStatisticValue = ...
        (planetEffectiveTempValue - equilibriumTempStruct.value) / ...
        sqrt(planetEffectiveTempUncertainty^2 + ...
        equilibriumTempStruct.uncertainty^2);
    tempComparisonStatisticSignificance = ...
        1 - normcdf(tempComparisonStatisticValue, 0, 1);

    % Populate the secondary event results structure.
    secondaryEventResults.planetParameters.planetEffectiveTemp.value = ...
        planetEffectiveTempValue;
    secondaryEventResults.planetParameters.planetEffectiveTemp.uncertainty = ...
        planetEffectiveTempUncertainty;

    secondaryEventResults.comparisonTests.tempComparisonStatistic.value = ...
        tempComparisonStatisticValue;
    secondaryEventResults.comparisonTests.tempComparisonStatistic.significance = ...
        tempComparisonStatisticSignificance;

end % if

% Update the DV results structure.
dvResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(iPlanet).secondaryEventResults = ...
    secondaryEventResults;

% Return.
return
