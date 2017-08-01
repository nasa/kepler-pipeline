function [fluxWithoutEventsArray] = ...
replace_astrophysical_events(fluxWithEventsArray, gapIndicatorsArray, ...
pdcModuleParameters, gapFillParametersStruct, dataAnomalyIndicators)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [fluxWithoutEventsArray] = ...
% replace_astrophysical_events(fluxWithEventsArray, gapIndicatorsArray, ...
% pdcModuleParameters, gapFillParametersStruct, dataAnomalyIndicators)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Identify the giant transits (planetary and eclipsing binaries) and 
% gravitational microlensing events for each target and replace them prior
% to performing the cotrend fit. The events will still be present in the
% residuals between the original flux and the cotrend fit for each target.
%
% Do not allow giant transits to be identified immediately before or after
% a safe mode, earth point or attitude tweak. These may not to be actual
% giant transits and will prevent the systematic error correction from
% working properly in the vicinity of the known anomalies.
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


% Define constants.
SINGLETON_REMOVAL_ENABLED = false;
GAUSSIAN_SIGMA_PER_MAD = 1.4826;

% Get the median filter length and maximum detrend polynomial order.
medianFilterLength = pdcModuleParameters.medianFilterLength;
maxDetrendPolyOrder = gapFillParametersStruct.maxDetrendPolyOrder;

% Allocate space for flux without events array.
fluxWithoutEventsArray = zeros(size(fluxWithEventsArray));

% Get unit Gaussian random number sequence, one value per cadence. Load
% from DV mat file if it exists because fitter is currently over-sensitive.
if exist('dv_rand.mat', 'file')
    load('dv_rand.mat', 'unitRandomSequence');
else
    unitRandomSequence = randn([size(fluxWithEventsArray, 1), 1]);
    unitRandomSequence = max(min(unitRandomSequence, 3), -3);
end % if / else

% Process targets one at a time.
nTargets = size(fluxWithEventsArray, 2);

for iTarget = 1 : nTargets
    
    targetFlux = fluxWithEventsArray( : , iTarget);
    targetFluxDataGapIndicators = gapIndicatorsArray( : , iTarget);
    
    % Identify the astrophysical events and remove any "events" in the
    % vicinity of known anomalies.
    [indexOfAstroEvents] = identify_astrophysical_events(targetFlux, ...
        targetFluxDataGapIndicators, gapFillParametersStruct, ...
        SINGLETON_REMOVAL_ENABLED);
        
    if ~isempty(dataAnomalyIndicators) && ~isempty(indexOfAstroEvents)
        % TEMPORARY.
%         ix = indexOfAstroEvents;
%         hold off
%         plot(find(~targetFluxDataGapIndicators), targetFlux(~targetFluxDataGapIndicators), '.-b')
%         hold on
%         plot(ix, targetFlux(ix), 'og')
        [indexOfAstroEvents] = ...
            remove_events_near_known_anomalies(indexOfAstroEvents, ...
            targetFluxDataGapIndicators, dataAnomalyIndicators, ...
            pdcModuleParameters, gapFillParametersStruct);
        % TEMPORARY.
%         plot(indexOfAstroEvents, targetFlux(indexOfAstroEvents), 'or')
%         pause
    end
        
    if ~isempty(indexOfAstroEvents)
        
        % Temporarily replace the events with data gaps.
        targetFlux(indexOfAstroEvents) = 0;
        targetFluxDataGapIndicators(indexOfAstroEvents) = true;

        % Fit a polynomial trend to the flux curve. Replace the
        % astrophysical events by linear interpolation. Evaluate the
        % polynomial trend to replace astrophysical events at the leading
        % and trailing edges of the time series. Add random noise to
        % interpolated or trend values based on the MAD of time series
        % fluctuations.
        indexAvailable = find(~targetFluxDataGapIndicators);
        nTimeSteps = (1 : length(targetFluxDataGapIndicators))';
        [fittedTrend] = fit_trend(nTimeSteps, indexAvailable, ...
            targetFlux, maxDetrendPolyOrder);
        
        medianAbsoluteDeviation  = mad(targetFlux(indexAvailable) - ...
            medfilt1(targetFlux(indexAvailable), medianFilterLength), 1);

        targetFlux(indexOfAstroEvents) = interp1(indexAvailable, ...
            targetFlux(indexAvailable), indexOfAstroEvents, 'linear') + ...
            medianAbsoluteDeviation * GAUSSIAN_SIGMA_PER_MAD * ...
            unitRandomSequence(indexOfAstroEvents);
        
        isInvalid = isnan(targetFlux);
        targetFlux(isInvalid) = fittedTrend(isInvalid) + ...
            medianAbsoluteDeviation * GAUSSIAN_SIGMA_PER_MAD * ...
            unitRandomSequence(isInvalid);
        
    end % if
    
    % Save the target flux without events in an array for further
    % processing.
    fluxWithoutEventsArray( : , iTarget) = targetFlux;
    
end % for iTarget

% Return.
return


function [indexOfAstroEvents] = ...
remove_events_near_known_anomalies(indexOfAstroEvents, dataGapIndicators, ...
dataAnomalyIndicators, pdcModuleParameters, gapFillParametersStruct)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [indexOfAstroEvents] = ...
% remove_events_near_known_anomalies(indexOfAstroEvents, dataGapIndicators, ...
% dataAnomalyIndicators, pdcModuleParameters, gapFillParametersStruct)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Remove any astrophysical events immediately preceding or following a safe
% mode, earth point or attitude tweak. Data gaps are included in the events
% so that the events are bounded by valid data samples.
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


% Get parameter values.
cadenceDurationInMinutes = gapFillParametersStruct.cadenceDurationInMinutes;

if isfield(pdcModuleParameters, 'attitudeTweakBufferInDays')
    attitudeTweakBufferInDays = ...
        pdcModuleParameters.attitudeTweakBufferInDays;
else
    attitudeTweakBufferInDays = 0.0625;
end

if isfield(pdcModuleParameters, 'safeModeBufferInDays')
    safeModeBufferInDays = ...
        pdcModuleParameters.safeModeBufferInDays;
else
    safeModeBufferInDays = 0.0625;
end

if isfield(pdcModuleParameters, 'earthPointBufferInDays')
    earthPointBufferInDays = ...
        pdcModuleParameters.earthPointBufferInDays;
else
    earthPointBufferInDays = 0.0625;
end

if isfield(pdcModuleParameters, 'astrophysicalEventBridgeInDays')
    astrophysicalEventBridgeInDays = ...
        pdcModuleParameters.astrophysicalEventBridgeInDays;
else
    astrophysicalEventBridgeInDays = 0.0625;
end

% Convert parameters to units of cadences.
attitudeTweakBufferCadences = ...
    round(attitudeTweakBufferInDays * get_unit_conversion('day2min') / ...
    cadenceDurationInMinutes);

safeModeBufferCadences = ...
    round(safeModeBufferInDays * get_unit_conversion('day2min') / ...
    cadenceDurationInMinutes);

earthPointBufferCadences = ...
    round(earthPointBufferInDays * get_unit_conversion('day2min') / ...
    cadenceDurationInMinutes);

astrophysicalEventBridgeCadences = ...
    round(astrophysicalEventBridgeInDays * get_unit_conversion('day2min') / ...
    cadenceDurationInMinutes);

% Bridge any astrophysical events with short gaps between.
astroEventIndicators = false(size(dataGapIndicators));
astroEventIndicators(indexOfAstroEvents) = true;
astroEventLocations = find_datagap_locations(astroEventIndicators);
indexOfBridgedAstroEvents = indexOfAstroEvents;

for iEvent = 1 : size(astroEventLocations, 1) - 1
    endEvent = astroEventLocations(iEvent, 2);
    startNextEvent = astroEventLocations(iEvent + 1, 1);
    if startNextEvent - endEvent <= astrophysicalEventBridgeCadences
        indexOfBridgedAstroEvents = union(indexOfBridgedAstroEvents, ...
            (endEvent : startNextEvent)');
    end
end % for iEvent

% Remove any astrophysical events preceding or following a safe mode.
if any(dataAnomalyIndicators.safeModeIndicators)
    
    safeModeIndices = ...
        find(dataAnomalyIndicators.safeModeIndicators);
    
    astroEventIndicators = dataGapIndicators;
    astroEventIndicators(indexOfBridgedAstroEvents) = true;
    astroEventLocations = find_datagap_locations(astroEventIndicators);
    
    for iEvent = 1 : size(astroEventLocations, 1)
        eventStart = astroEventLocations(iEvent, 1);
        eventEnd = astroEventLocations(iEvent, 2);
        if any(ismember(safeModeIndices, ...
                (eventStart - safeModeBufferCadences : ...
                eventEnd + safeModeBufferCadences)'))
            indexOfAstroEvents = setdiff(indexOfAstroEvents, ...
                (eventStart : eventEnd)');
        end % if
    end % for iEvent

end % if

% Remove any astrophysical events preceding or following an earth point.
if any(dataAnomalyIndicators.earthPointIndicators)
    
    earthPointIndices = ...
        find(dataAnomalyIndicators.earthPointIndicators);
        
    astroEventIndicators = dataGapIndicators;
    astroEventIndicators(indexOfBridgedAstroEvents) = true;
    astroEventLocations = find_datagap_locations(astroEventIndicators);
    
    for iEvent = 1 : size(astroEventLocations, 1)
        eventStart = astroEventLocations(iEvent, 1);
        eventEnd = astroEventLocations(iEvent, 2);
        if any(ismember(earthPointIndices, ...
                (eventStart - earthPointBufferCadences : ...
                eventEnd + earthPointBufferCadences)'))
            indexOfAstroEvents = setdiff(indexOfAstroEvents, ...
                (eventStart : eventEnd)');
        end % if
    end % for iEvent

end % if

% Remove any remaining astrophysical events preceding or following an
% attitude tweak.
if any(dataAnomalyIndicators.attitudeTweakIndicators)
    
    attitudeTweakIndices = ...
        find(dataAnomalyIndicators.attitudeTweakIndicators);
    
    astroEventIndicators = dataGapIndicators;
    astroEventIndicators(indexOfBridgedAstroEvents) = true;
    astroEventLocations = find_datagap_locations(astroEventIndicators);
    
    for iEvent = 1 : size(astroEventLocations, 1)
        eventStart = astroEventLocations(iEvent, 1);
        eventEnd = astroEventLocations(iEvent, 2);
        if any(ismember(attitudeTweakIndices, ...
                (eventStart - attitudeTweakBufferCadences : ...
                eventEnd + attitudeTweakBufferCadences)'))
            indexOfAstroEvents = setdiff(indexOfAstroEvents, ...
                (eventStart : eventEnd)');
        end % if
    end % for iEvent

end % if

% Return.
return
