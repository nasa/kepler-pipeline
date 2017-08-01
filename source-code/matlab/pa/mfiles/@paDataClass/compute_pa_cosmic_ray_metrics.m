function [paResultsStruct] = ...
compute_pa_cosmic_ray_metrics(paDataObject, paResultsStruct)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [paResultsStruct] = ...
% compute_pa_cosmic_ray_metrics(paDataObject, paResultsStruct)
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


% Set empty value.
emptyValue = -1;

% Get fields from input object.
paFileStruct    = paDataObject.paFileStruct;
paStateFileName = paFileStruct.paStateFileName;
paRootTaskDir   = paFileStruct.paRootTaskDir;

cadenceType = paDataObject.cadenceType;

cadenceTimes = paDataObject.cadenceTimes;
timestamps = cadenceTimes.midTimestamps;
cadenceGapIndicators = cadenceTimes.gapIndicators;

spacecraftConfigMap = paDataObject.spacecraftConfigMap;
fcConstants = paDataObject.fcConstants;

backgroundDataStruct = paDataObject.backgroundDataStruct;
targetStarDataStruct = paDataObject.targetStarDataStruct;

processingState = paDataObject.processingState;

% Set long and short cadence flags.
if strcmpi(cadenceType, 'long')
    processLongCadence = true;
    processShortCadence = false;
elseif strcmpi(cadenceType, 'short')
    processLongCadence = false;
    processShortCadence = true;
end

% Set the data type flags.
switch processingState
    case 'BACKGROUND'
        processBackground = true;
        processTarget = false;
    case 'AGGREGATE_RESULTS'
        processBackground = false;
        processTarget = true;        
    otherwise % Assume we're analyzing target results.
        processBackground = false;
        processTarget = true;                
end

% Load the cosmic ray events struct array and the vector of valid pixel
% counts per cadence from the PA state file. Get the event times.
load(paStateFileName, 'cosmicRayEvents', 'nValidPixels');

if ~isempty(cosmicRayEvents)
    eventMjds = [cosmicRayEvents.mjd]';
else
    eventMjds = [];
end

% Instantiate config map object and get the exposure time and the number of
% exposures for each cadence. Compute the total time per cadence.
configMapObject = configMapClass(spacecraftConfigMap);

validTimestamps = timestamps(~cadenceGapIndicators);

[ccdExposureTime] = get_exposure_time(configMapObject, validTimestamps);
[ccdReadoutTime] = get_readout_time(configMapObject, validTimestamps);

if processLongCadence
    [numberOfExposuresPerCadence] = ...
        get_number_of_exposures_per_long_cadence_period(configMapObject, ...
        validTimestamps);
elseif processShortCadence
    [numberOfExposuresPerCadence] = ...
        get_number_of_exposures_per_short_cadence_period(configMapObject, ...
        validTimestamps);
end

totalTimePerCadence = repmat(emptyValue, size(timestamps));
totalTimePerCadence(~cadenceGapIndicators) = ...
    (ccdExposureTime + ccdReadoutTime) .* numberOfExposuresPerCadence;

% Get the pixel size and area.
pixelSizeInMicrons = fcConstants.PIXEL_SIZE_IN_MICRONS;
pixelAreaInCmSquared = (pixelSizeInMicrons * 1e-4) ^ 2;

% Initialize the cosmic ray metric time series structure.
nCadences = length(timestamps);
[cosmicRayMetrics] = initialize_cosmic_ray_metrics_structure(nCadences);

% Return a fully gapped metrics structure if there are no valid pixels for
% any cadence. Otherwise at least the hit rates will be valid.
if 0 == sum(nValidPixels)
    if processBackground
        paResultsStruct.backgroundCosmicRayMetrics = cosmicRayMetrics;
    elseif processTarget
        paResultsStruct.targetStarCosmicRayMetrics = cosmicRayMetrics;
    end
    return
end

% Loop over the cadences and compute the cosmic ray metrics where possible.
for iCadence = 1 : nCadences
    
    % Check that cadence is valid.
    nValidPixelsForThisCadence = nValidPixels(iCadence);
    if cadenceGapIndicators(iCadence) || 0 == nValidPixelsForThisCadence
        continue;
    end
    
    % Find events for this cadence.
    %isEvent = ismember(eventMjds, timestamps(iCadence));
    isEvent = (timestamps(iCadence) == eventMjds);
    nEvents = sum(isEvent);
    
    % Compute the mean hit rate in units of #events/cm^2/sec.
    areaOfCcdWithValidPixels = ...
        pixelAreaInCmSquared * nValidPixelsForThisCadence;
    hitRate = ...
        nEvents / areaOfCcdWithValidPixels / totalTimePerCadence(iCadence);
    cosmicRayMetrics.hitRate.values(iCadence) = hitRate;
    cosmicRayMetrics.hitRate.gapIndicators(iCadence) = false;
    
    % Compute the mean energy in units of photoelectrons.
    if nEvents > 0
        events = cosmicRayEvents(isEvent);
        eventDeltas = [events.delta];
        meanEnergy = mean(eventDeltas);
        cosmicRayMetrics.meanEnergy.values(iCadence) = meanEnergy;
        cosmicRayMetrics.meanEnergy.gapIndicators(iCadence) = false;
    end
    
    % Compute the energy variance in units of photoelectrons^2.
    if nEvents > 1
        energyVariance = var(eventDeltas);
        if ~isnan(energyVariance)
            cosmicRayMetrics.energyVariance.values(iCadence) = energyVariance;
            cosmicRayMetrics.energyVariance.gapIndicators(iCadence) = false;
        end
    end
    
    % Compute the energy skewness (dimensionless).
    if nEvents > 2
        energySkewness = skewness(eventDeltas);
        if ~isnan(energySkewness)
            cosmicRayMetrics.energySkewness.values(iCadence) = energySkewness;
            cosmicRayMetrics.energySkewness.gapIndicators(iCadence) = false;
        end
    end
    
    % Compute the energy kurtosis (dimensionless).
    if nEvents > 3
        energyKurtosis = kurtosis(eventDeltas);
        if ~isnan(energyKurtosis)
            cosmicRayMetrics.energyKurtosis.values(iCadence) = energyKurtosis;
            cosmicRayMetrics.energyKurtosis.gapIndicators(iCadence) = false;
        end
    end
        
end % for iCadence

% Copy the metrics to the PA results structure.
if processBackground
    paResultsStruct.backgroundCosmicRayMetrics = cosmicRayMetrics;
elseif processTarget
    paResultsStruct.targetStarCosmicRayMetrics = cosmicRayMetrics;
end

%Return
return
