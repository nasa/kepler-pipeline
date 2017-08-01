function transitingStarObject = transitingStarClass( ...
    transitingStarData, targetData, initialData, runParamsObject)

% instantiate the stellar properties object
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
nonlinearLimbDarkeningData = struct(...
    'limbDarkeningDataLocation', 'configuration_files', ...
    'limbDarkeningDataFilename', 'atlasNonlinearLimbDarkeningData.mat');
nonlinearLimbDarkeningObject = nonlinearLimbDarkeningClass( ...
    nonlinearLimbDarkeningData);

simpleStellarPropertiesData = struct('className', 'simpleStellarPropertiesClass');
simpleStellarPropertiesData.limbDarkeningObject = nonlinearLimbDarkeningObject;
simpleStellarPropertiesObject = simpleStellarPropertiesClass(...
    simpleStellarPropertiesData);

if isempty(initialData) % if there is no initial data
    primaryPropertiesStruct = struct( ...
        'ra', targetData.ra, ...
        'dec', targetData.dec, ...
        'effectiveTemperature', targetData.effectiveTemperature, ...
        'logSurfaceGravity', targetData.logSurfaceGravity, ...
        'effectiveTemperatureUncertainty', 250);
    if isempty(primaryPropertiesStruct.effectiveTemperature)
        primaryPropertiesStruct.effectiveTemperature = 5870; % sun
    end
    if isempty(primaryPropertiesStruct.logSurfaceGravity)
        primaryPropertiesStruct.logSurfaceGravity = 4.4; % sun
    end

    primaryPropertiesStruct = get_stellar_properties(...
        simpleStellarPropertiesObject, primaryPropertiesStruct);

    transitingOrbitData = struct( ...
        'primaryPropertiesStruct', primaryPropertiesStruct,...
        'transitTimeBuffer', get(runParamsObject, 'transitTimeBuffer')*get(runParamsObject, 'cadenceDuration'));

    % choose the secondary star parameters from the specified range

    effTemp = ...
        uniformRandomPickFromRange(transitingStarData.effectiveTemperatureRange);
    logG = uniformRandomPickFromRange(transitingStarData.logGRange);

    secondaryPropertiesStruct = struct(...
        'effectiveTemperature', effTemp, ...
        'logSurfaceGravity', logG, ...
        'effectiveTemperatureUncertainty', 250);

    transitingOrbitData.secondaryPropertiesStruct = get_stellar_properties(...
        simpleStellarPropertiesObject, secondaryPropertiesStruct);

    %----------------------------------------------------------------------
    % choose the orbital parameters from the specified ranges
    %----------------------------------------------------------------------

    if isempty(transitingStarData.eccentricityRange)

        % pick an eccentricity from observed distribution for close binaries
        % hist2ppcdfe returns a piece-wise polynomial representation for the histogram in
        %   Duquennoy and Mayor for the eccentricity of tight binaries:
        %
        eccentricityDistributionPoly = hist2ppcdfe;
        % pick a random eccentricity
        transitingOrbitData.eccentricity = ppcdfinv(eccentricityDistributionPoly, rand(1, 1));
    else
        % choose from input range
        transitingOrbitData.eccentricity = ...
            uniformRandomPickFromRange(transitingStarData.eccentricityRange);
    end

    transitingOrbitData.orbitalPeriod = ...
        uniformRandomPickFromRange(transitingStarData.orbitalPeriodRange);
    transitingOrbitData.orbitalPeriodUnits = transitingStarData.orbitalPeriodUnits;

    % pericenter time is specified in mjd
    transitingOrbitData.periCenterTimeMks = ...
        convert_to_mks(uniformRandomPickFromRange( ...
        transitingStarData.periCenterDateRange), 'days');

    % pick a random line-of-sight angle
    transitingOrbitData.lineOfSightAngle = rand(1,1)*2*pi;

    transitingOrbitData.minimumImpactParameter = ...
        uniformRandomPickFromRange(transitingStarData.minimumImpactParameterRange);
else % there is initial data
    primaryPropertiesStruct = initialData.primaryPropertiesStruct;

    transitingOrbitData = struct( ...
        'primaryPropertiesStruct', primaryPropertiesStruct,...
        'transitTimeBuffer', get(runParamsObject, 'transitTimeBuffer')*get(runParamsObject, 'cadenceDuration'));

    transitingOrbitData.secondaryPropertiesStruct = initialData.secondaryPropertiesStruct;
    transitingOrbitData.eccentricity = initialData.eccentricity;
    transitingOrbitData.orbitalPeriod = initialData.orbitalPeriod;
    transitingOrbitData.orbitalPeriodUnits = initialData.orbitalPeriodUnits;
    transitingOrbitData.periCenterTimeMks = initialData.periCenterTimeMks;
    transitingOrbitData.lineOfSightAngle = initialData.lineOfSightAngle;
    transitingOrbitData.minimumImpactParameter = initialData.minimumImpactParameter;
end
% instantiate the transitingOrbitClass
transitingStarData.transitingOrbitObject = ...
    transitingOrbitClass(transitingOrbitData, runParamsObject);

% instantiate the transitingStarClass
disp(transitingStarData);
transitingStarObject = class(transitingStarData, ...
    'transitingStarClass', runParamsObject);

