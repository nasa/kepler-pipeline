function [dvResultsStruct] = ...
generate_dv_rolling_band_diagnostics(dvDataObject, dvResultsStruct)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [dvResultsStruct] = ...
% generate_dv_rolling_band_diagnostics(dvDataObject, dvResultsStruct)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Generate rolling band contamination diagnostics for all targets and
% planet candidates. Diagnostics consist of a histogram of the number of
% transits for each candidate that are affected by optimal aperture rolling
% bands at each severity level (0-4). A transit is considered to be
% affected at a given severity level if at least one valid in-transit
% cadence is flagged with a rolling band at that level and no other
% in-transit cadences are flagged at a higher level (i.e. maximum rolling
% band severity level over all in-transit cadences for given transit). If a
% transit was not observed or rolling band contamination flags are gapped
% for all in-transit cadences then the transit is not counted in the
% contamination histogram. Severity levels are determined by target and
% cadence for one or more pulse durations in the Photometric Analysis CSCI.
% The diagnostic histogram is determined from the rolling band flags for
% the pulse duration that most closely matches the transit duration as
% determined in DV (from limb-darkened all transits fit if successful,
% otherwise from trapezoidal model fit).
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

% Get cadence duration.
dvCadenceTimes = dvDataObject.dvCadenceTimes;
cadenceGapIndicators = dvCadenceTimes.gapIndicators;

startTimestamps = dvCadenceTimes.startTimestamps(~cadenceGapIndicators);
endTimestamps = dvCadenceTimes.endTimestamps(~cadenceGapIndicators);
cadenceDurations = endTimestamps - startTimestamps;
cadenceDurationDays = median(cadenceDurations);
clear startTimestamps endTimestamps cadenceDurations cadenceGapIndicators

% Loop over the targets and generate the rolling band contamination
% diagnostics.
nTargets = length(dvDataObject.targetStruct);

for iTarget = 1 : nTargets
    
    % Get the keplerId for the given target.
    keplerId = dvDataObject.targetStruct(iTarget).keplerId;
    
    % There is no reporting to do for the given target if all of the
    % rolling band contamination flags are gapped. Trim the rolling band
    % contamination flags for pulse durations where the flags are all
    % gapped. Move on to the next target if no valid flags remain.
    rollingBandContaminationStruct = ...
        dvDataObject.targetStruct(iTarget).rollingBandContaminationStruct;
    
    for iPulse = length(rollingBandContaminationStruct): -1 : 1
        rollingBandGapIndicators = ...
            rollingBandContaminationStruct(iPulse).severityFlags.gapIndicators;
        if all(rollingBandGapIndicators)
            rollingBandContaminationStruct(iPulse) = [];
        end % if
    end % for iPulse
         
    if isempty(rollingBandContaminationStruct)
        string = ...
            'Rolling band contamination diagnostics are enabled but target level flags are unavailable';
        [dvResultsStruct] = add_dv_alert(dvResultsStruct, 'generateDvRollingBandDiagnostics', ...
            'warning', string, iTarget, keplerId);
        disp(dvResultsStruct.alerts(end).message);
        continue
    end % if
    
    % Get target specific fields.
    barycentricCadenceTimes = ...
        dvDataObject.barycentricCadenceTimes(iTarget);
    bkjdTimestamps = barycentricCadenceTimes.midTimestamps;
    
    % Initialize the transit model for the given target.
    thresholdCrossingEvent = ...
        dvDataObject.targetStruct(iTarget).thresholdCrossingEvent(1);
    [transitModel] = ...
        convert_tps_parameters_to_transit_model(dvDataObject, ...
        iTarget, thresholdCrossingEvent);
    
    % Loop through the planet candidates associated with each target.
    % Identify the in-transit cadences and generate the rolling band
    % contamination diagnostics.
    targetResultsStruct = dvResultsStruct.targetResultsStruct(iTarget);
    nPlanets = length(targetResultsStruct.planetResultsStruct);
    
    for iPlanet = 1 : nPlanets
        
        % Get the model fit results for the given candidate. Move on to the
        % next candidate if the model fit was not successful.
        planetResultsStruct = ...
            targetResultsStruct.planetResultsStruct(iPlanet);
        [fitResultsStruct, ~, ~, trapezoidalFitReturned] = ...
            get_fit_results_for_diagnostic_test(planetResultsStruct);
        
        if isempty(fitResultsStruct)
            string = sprintf('Model fit results are not available to support rolling band contamination diagnostic');
            [dvResultsStruct] = add_dv_alert(dvResultsStruct, 'generateDvRollingBandDiagnostics', ...
                'warning', string, iTarget, keplerId, iPlanet);
            disp(dvResultsStruct.alerts(end).message);
            continue
        elseif trapezoidalFitReturned
            string = sprintf('Falling back to trapezoidal model fit results to support rolling band contamination diagnostic');
            [dvResultsStruct] = add_dv_alert(dvResultsStruct, 'generateDvRollingBandDiagnostics', ...
                'warning', string, iTarget, keplerId, iPlanet);
            disp(dvResultsStruct.alerts(end).message);
        end % if / elseif   
        
        modelParameters = fitResultsStruct.modelParameters;
        [periodStruct] = ...
            retrieve_model_parameter(modelParameters, 'orbitalPeriodDays');
        orbitalPeriodDays = periodStruct.value;
        [epochStruct] = ...
            retrieve_model_parameter(modelParameters, 'transitEpochBkjd');
        transitEpochBkjd = epochStruct.value;
        [durationStruct] = ...
            retrieve_model_parameter(modelParameters, 'transitDurationHours');
        transitDurationHours = durationStruct.value;
        
        % Update the planet model for the given candidate and instantiate a
        % transit object.
        transitModel.planetModel = fitResultsStruct.modelParameters;
        [transitObject] = transitGeneratorClass(transitModel);
        
        % Identify the in-transit cadences for the given candidate.
        [transitNumber] = ...
            identify_transit_cadences(transitObject, bkjdTimestamps, 0);
        
        % Get the flux time series in which the given planet candidate was
        % detected and set gaps for the filled cadences.
        initialFluxTimeSeries = ...
            planetResultsStruct.planetCandidate.initialFluxTimeSeries;
        fluxGapIndicators = initialFluxTimeSeries.gapIndicators;
        fluxFilledIndices = initialFluxTimeSeries.filledIndices;
        fluxGapIndicators(fluxFilledIndices) = true;
        
        % Get the rolling band flags and gap indicators for the pulse
        % duration that most closely matches the transit duration. Ensure 
        % that flux gap indicators are set when the rolling band
        % contamination flags are gapped.
        pulseDurations = [rollingBandContaminationStruct.testPulseDurationLc]';
        transitDurationCadences = transitDurationHours * ...
            get_unit_conversion('hour2day') / cadenceDurationDays;
        [~, index] = min(abs(pulseDurations - transitDurationCadences));
        
        testPulseDurationLc = ...
            rollingBandContaminationStruct(index).testPulseDurationLc;
        rollingBandValues = ...
            rollingBandContaminationStruct(index).severityFlags.values;
        rollingBandGapIndicators = ...
            rollingBandContaminationStruct(index).severityFlags.gapIndicators;
        rollingBandValues(rollingBandGapIndicators) = 0;
    
        fluxGapIndicators(rollingBandGapIndicators) = true;
        
        % Get the rolling band results structure for the given candidate. 
        rollingBandContaminationHistogram = ...
            planetResultsStruct.imageArtifactResults.rollingBandContaminationHistogram;
        transitMetadata = ...
            rollingBandContaminationHistogram.transitMetadata;
        
        % Set the pulse duration for the rolling band contamination flags
        % that most closely matched the transit duration of the given
        % planet.
        rollingBandContaminationHistogram.testPulseDurationLc = ...
            testPulseDurationLc;
        
        % Loop over the transits and identify the maximum rolling band
        % severity level for each transit with at least one valid cadence
        % for which the rolling band contamination flag is also ungapped.
        % Also determine the epoch associated with transits for which the
        % severity level > 0; this is somewhat complicated because of
        % partial transits for which the epoch occurs before the beginning
        % of the UOW.
        nTransits = max(transitNumber);
        
        for iTransit = 1 : nTransits
            
            isInTransit = transitNumber == iTransit;
            
            if ~all(fluxGapIndicators(isInTransit))
                
                severityLevel = ...
                    max(rollingBandValues(isInTransit & ~fluxGapIndicators));
                index = severityLevel + 1;
                rollingBandContaminationHistogram.transitCounts(index) = ...
                    rollingBandContaminationHistogram.transitCounts(index) + 1;
                
                if severityLevel > 0
                    number = round( ...
                        (mean(bkjdTimestamps(isInTransit)) - transitEpochBkjd) / ...
                        orbitalPeriodDays);
                    epoch = transitEpochBkjd + number * orbitalPeriodDays;
                    transitMetadata(severityLevel).numbers = ...
                        [transitMetadata(severityLevel).numbers; number];
                    transitMetadata(severityLevel).epochs = ...
                        [transitMetadata(severityLevel).epochs; epoch];
                end % if
                    
            end % if
            
        end % for iTransit
        
        % Compute the fraction of transits at each severity level.
        totalCount = sum(rollingBandContaminationHistogram.transitCounts);
        
        if totalCount > 0
            rollingBandContaminationHistogram.transitFractions = ...
                rollingBandContaminationHistogram.transitCounts / totalCount;
        end % if
        
        % Update the results structure for the given candidate.
        rollingBandContaminationHistogram.transitMetadata = transitMetadata;
        planetResultsStruct.imageArtifactResults.rollingBandContaminationHistogram = ...
            rollingBandContaminationHistogram;
        targetResultsStruct.planetResultsStruct(iPlanet) = planetResultsStruct;
        
    end % for iPlanet
    
    % Update the results structure for the given target.
    dvResultsStruct.targetResultsStruct(iTarget) = targetResultsStruct;
      
end % for iTarget

% Return.
return
