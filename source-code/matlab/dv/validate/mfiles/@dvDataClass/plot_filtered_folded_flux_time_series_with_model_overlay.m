function [dvResultsStruct] = plot_filtered_folded_flux_time_series_with_model_overlay( ...
dvDataObject, dvResultsStruct, iTarget, iPlanet)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [dvResultsStruct] = plot_filtered_folded_flux_time_series_with_model_overlay( ...
% dvDataObject, dvResultsStruct, iTarget, iPlanet)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Create figure displaying the detrended (by median filtering) initial
% flux time series folded with model overlay for the given planet
% candidate. Update the phase time series associated with the folded data
% and model in the DV results structure.
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

% Set constants.
DATA_MARKER_SIZE = 4.0;
TRANSIT_MARKER_SIZE = 6.0;
TRANSIT_MARKER_POSITION = 0.025;
TRANSIT_MARKER_SPACING = 1.5 * TRANSIT_MARKER_POSITION;
PPM_CONVERSION = 1e6;
SIGMAS_PER_MAD = 1.4826;

% Set colors.
COLOR_VALUE_ARRAY = [ ...
    1   0   0    % red    
    0   0   1    % blue
    0   1   0    % green
    0   0   0    % black
    1   0   1    % magenta
    1   0.7 0 ]; % orange

% Get required fields.
clippingLevel = ...
    dvDataObject.planetFitConfigurationStruct.reportSummaryClippingLevel;
binsPerTransit = ...
    dvDataObject.planetFitConfigurationStruct.reportSummaryBinsPerTransit;

% Get the barycentric timestamps for the given target. They should be
% defined for all cadences.
midCadenceTimestamps = ...
    dvDataObject.barycentricCadenceTimes(iTarget).midTimestamps;
endCadenceTimestamps = ...
    dvDataObject.barycentricCadenceTimes(iTarget).endTimestamps;

% Get the relevant fit results for the given planet candidate. Fall back to
% the trapezoidal model fit results if the all transits fit did not
% succeed.
planetResultsStruct = ...
    dvResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(iPlanet);
[fitResultsStruct, modelLightCurve, allTransitsFitReturned] = ...
    get_fit_results_for_diagnostic_test(planetResultsStruct);
if isempty(fitResultsStruct)
    fitResultsStruct = planetResultsStruct.allTransitsFit;
end % if
modelChiSquare = fitResultsStruct.modelChiSquare;
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
[depthStruct] = ...
    retrieve_model_parameter(modelParameters, 'transitDepthPpm');
transitDepth = depthStruct.value / PPM_CONVERSION;

% Get the detrended flux time series for the given planet candidate. Set
% the gap filled cadences to NaN.
detrendedFluxTimeSeries = planetResultsStruct.detrendedFluxTimeSeries;
filteredTimeSeriesValues = detrendedFluxTimeSeries.values;
filteredTimeSeriesValues(detrendedFluxTimeSeries.filledIndices) = NaN;

% Perform the folding.
[phase, phaseSorted, sortKey, foldedFluxValues] = ...
    fold_time_series(midCadenceTimestamps, transitEpochBkjd, orbitalPeriodDays, ...
    filteredTimeSeriesValues);                                                              %#ok<ASGLU>
phaseDays = phaseSorted * orbitalPeriodDays;

% Perform the binning and averaging.
[binnedPhaseDays, binnedFluxValues] = ...
    bin_and_average_time_series_by_cadence_time( ...
    phaseDays, foldedFluxValues, 0, ...
    transitDurationHours / get_unit_conversion('day2hour') / binsPerTransit, ...
    isnan(foldedFluxValues));

% Draw the plot with appropriate scaling if transit depth is known.
isWrap = phaseDays < -orbitalPeriodDays / 4;
phaseDays(isWrap) = phaseDays(isWrap) + orbitalPeriodDays;

[~, ix] = sort(sortKey);
planetResultsStruct.foldedPhase = phaseDays(ix);

figure

plot(phaseDays, foldedFluxValues, '.k', 'MarkerSize', DATA_MARKER_SIZE);
x = axis();
x(1) = -orbitalPeriodDays / 4;
x(2) = 3 * orbitalPeriodDays / 4;
axis(x);

if modelChiSquare ~= -1
    x = axis();
    sigmaEstimate = SIGMAS_PER_MAD * mad(foldedFluxValues, 1);
    x(3) = max(x(3), -transitDepth - clippingLevel * sigmaEstimate);
    x(4) = min(x(4), clippingLevel * sigmaEstimate);
    if x(4) > x(3)
        axis(x);
    end % if
end % if

hold on

isWrap = binnedPhaseDays < -orbitalPeriodDays / 4;
binnedPhaseDays(isWrap) = binnedPhaseDays(isWrap) + orbitalPeriodDays;

plot(binnedPhaseDays, binnedFluxValues, ...
    'o', 'MarkerEdgeColor', 'cyan', 'MarkerFaceColor', 'cyan', ...
    'MarkerSize', DATA_MARKER_SIZE);

if modelChiSquare ~= -1 && allTransitsFitReturned
    [phase, phaseSorted, sortKey, foldedModelLightCurve] = ...
        fold_time_series(midCadenceTimestamps, transitEpochBkjd, ...
        orbitalPeriodDays, modelLightCurve);                                                %#ok<ASGLU>
    phaseDays = phaseSorted * orbitalPeriodDays;
    isWrap = phaseDays < -orbitalPeriodDays / 4;
    phaseDays(isWrap) = phaseDays(isWrap) + orbitalPeriodDays;
    [phaseDays, ix] = sort(phaseDays);
    plot(phaseDays, foldedModelLightCurve(ix), '-r');
end % if

% Update the phase time series in the DV results structure.
dvResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(iPlanet) = ...
    planetResultsStruct;

% Add event triangles for all candidates associated with the given target.
nPlanets = ...
    length(dvResultsStruct.targetResultsStruct(iTarget).planetResultsStruct);
nColors = size(COLOR_VALUE_ARRAY, 1);

x = axis();
baseValue = x(3);
baseRange = x(4) - x(3);
x(3) = baseValue - TRANSIT_MARKER_SPACING * (nPlanets - 1) * baseRange;
axis(x);

baseOrbitalPeriodDays = orbitalPeriodDays;
baseTransitEpochBkjd = transitEpochBkjd;

for jPlanet = 1 : nPlanets
    
    planetResultsStruct = ...
        dvResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(jPlanet);
    [fitResultsStruct] = ...
        get_fit_results_for_diagnostic_test(planetResultsStruct);
    if isempty(fitResultsStruct)
        fitResultsStruct = planetResultsStruct.allTransitsFit;
    end % if
    modelParameters = fitResultsStruct.modelParameters;
    [periodStruct] = ...
        retrieve_model_parameter(modelParameters, 'orbitalPeriodDays');
    orbitalPeriodDays = periodStruct.value;
    [epochStruct] = ...
        retrieve_model_parameter(modelParameters, 'transitEpochBkjd');
    transitEpochBkjd = epochStruct.value;
    weakSecondaryStruct = ...
        planetResultsStruct.planetCandidate.weakSecondaryStruct;
        
    lastTransit = floor((endCadenceTimestamps(end) - transitEpochBkjd) / orbitalPeriodDays);
    transitTimestamps = transitEpochBkjd + (0 : lastTransit) * orbitalPeriodDays;
    [phase, phaseSorted] = fold_time_series(transitTimestamps, ...
        baseTransitEpochBkjd, baseOrbitalPeriodDays);                                               %#ok<ASGLU>
    phaseDays = phaseSorted * baseOrbitalPeriodDays;
    isWrap = phaseDays < -baseOrbitalPeriodDays / 4;
    phaseDays(isWrap) = phaseDays(isWrap) + baseOrbitalPeriodDays;

    colorValue = COLOR_VALUE_ARRAY(mod(jPlanet - 1, nColors) + 1, : );
    markerValue = baseValue + TRANSIT_MARKER_POSITION * baseRange;
    plot(phaseDays, repmat(markerValue, size(phaseDays)), ...
        '^', 'MarkerEdgeColor', colorValue, 'MarkerFaceColor', colorValue, ...
        'MarkerSize', TRANSIT_MARKER_SIZE);
    if iPlanet == jPlanet
        plot(weakSecondaryStruct.maxMesPhaseInDays, baseValue + TRANSIT_MARKER_POSITION * baseRange, ...
        'v', 'MarkerEdgeColor', colorValue, 'MarkerFaceColor', colorValue, ...
        'MarkerSize', TRANSIT_MARKER_SIZE);
    end % if
    
    baseValue = baseValue - TRANSIT_MARKER_SPACING * baseRange;
    
end % for jPlanet

% Add title and labels.
string = sprintf('Planet %d : Filtered Folded Averaged PDC Flux Time Series', iPlanet);
title(string);
xlabel('Phase [Days]');
ylabel('Relative Flux');

% Add title and labels.
format_graphics_for_dv_report(gcf);

% Save the figure.
keplerId = dvResultsStruct.targetResultsStruct(iTarget).keplerId;
planetDir = sprintf('planet-%02d', iPlanet);

if isfield(dvResultsStruct.targetResultsStruct(iTarget), 'dvFiguresRootDirectory')
    dvFiguresRootDirectory = dvResultsStruct.targetResultsStruct(iTarget).dvFiguresRootDirectory;
else
    dvFiguresRootDirectory = sprintf('target-%09d', targetStruct(iTarget).keplerId);
end % if / else

if ~exist(fullfile(dvFiguresRootDirectory, planetDir, 'report-summary'), 'dir')
            mkdir(fullfile(dvFiguresRootDirectory, planetDir, 'report-summary'));
end

figureName = fullfile(dvFiguresRootDirectory, planetDir, ...
    'report-summary', ...
    sprintf('%09d-%02d-all-unwhitened-filtered-model.fig', ...
    keplerId, iPlanet));
saveas(gcf, figureName);

% Close the figure.
close(gcf);

% Return.
return
