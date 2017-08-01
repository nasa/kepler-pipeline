function plot_filtered_zoomed_odd_even_flux_time_series(dvDataObject, ...
dvResultsStruct, iTarget, iPlanet, nTransitTimesZoom)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function plot_filtered_zoomed_odd_even_flux_time_series(dvDataObject, ...
% dvResultsStruct, iTarget, iPlanet, nTransitTimesZoom)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Create figure displaying the detrended (by median filtering) initial
% flux time series separately folded by odd and even transits for the given
% planet candidate. Mark the transit depths with associated uncertainties
% for the odd and even transits.
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
BINNED_DATA_MARKER_SIZE = 5.0;
TRANSIT_MARKER_SIZE = 6.0;
TEXT_MARKER_POSITION = 0.05;
TRANSIT_MARKER_POSITION = 0.025;
PPM_CONVERSION = 1e6;
SIGMAS_PER_MAD = 1.4826;

% Get required fields.
clippingLevel = ...
    dvDataObject.planetFitConfigurationStruct.reportSummaryClippingLevel;
binsPerTransit = ...
    dvDataObject.planetFitConfigurationStruct.reportSummaryBinsPerTransit;

% Get the barycentric timestamps for the given target. They should be
% defined for all cadences.
cadenceTimestamps = ...
    dvDataObject.barycentricCadenceTimes(iTarget).midTimestamps;

% Get the relevant fit results for the given planet candidate. Fall back to
% the trapezoidal model fit results if the all transits fit did not
% succeed.
planetResultsStruct = ...
    dvResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(iPlanet);
[fitResultsStruct] = ...
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

% Perform the folding for the odd transit and then even transits.
[oddPhase, oddPhaseSorted, oddSortKey, oddFoldedFluxValues] = ...
    fold_time_series(cadenceTimestamps, transitEpochBkjd, 2*orbitalPeriodDays, ...
    filteredTimeSeriesValues);                                                              %#ok<ASGLU>
oddPhaseHours = oddPhaseSorted * 2 * orbitalPeriodDays * get_unit_conversion('day2hour');

[evenPhase, evenPhaseSorted, evenSortKey, evenFoldedFluxValues] = ...
    fold_time_series(cadenceTimestamps, transitEpochBkjd+orbitalPeriodDays, ...
    2*orbitalPeriodDays, filteredTimeSeriesValues);                                         %#ok<ASGLU>
evenPhaseHours = evenPhaseSorted * 2 * orbitalPeriodDays * get_unit_conversion('day2hour');

% Perform the binning and averaging separately for the odd and even
% transits.
[oddBinnedPhaseHours, oddBinnedFluxValues] = ...
    bin_and_average_time_series_by_cadence_time( ...
    oddPhaseHours, oddFoldedFluxValues, 0, ...
    transitDurationHours / binsPerTransit, ...
    isnan(oddFoldedFluxValues));

[evenBinnedPhaseHours, evenBinnedFluxValues] = ...
    bin_and_average_time_series_by_cadence_time( ...
    evenPhaseHours, evenFoldedFluxValues, 0, ...
    transitDurationHours / binsPerTransit, ...
    isnan(evenFoldedFluxValues));

% The nTransitTimesZoom may exceed the total range of times which are
% present in the data (unlikely but possible). Handle that case now.
nTransitTimesZoom = min(nTransitTimesZoom, ...
    range(oddPhaseHours)/transitDurationHours ) ;
maxPhaseHours = nTransitTimesZoom / 2 * transitDurationHours;

% Draw the plot with appropriate scaling if transit depth is known.
figure;

isInOddZoom = abs(oddPhaseHours) < maxPhaseHours;
plot(oddPhaseHours(isInOddZoom) - maxPhaseHours, ...
    oddFoldedFluxValues(isInOddZoom), '.k', 'MarkerSize', DATA_MARKER_SIZE);

hold on
isInEvenZoom = abs(evenPhaseHours) < maxPhaseHours;
plot(evenPhaseHours(isInEvenZoom) + maxPhaseHours, ...
    evenFoldedFluxValues(isInEvenZoom), '.k', 'MarkerSize', DATA_MARKER_SIZE);
x = axis();
x(1) = -2 * maxPhaseHours;
x(2) = 2 * maxPhaseHours;
axis(x);

if modelChiSquare ~= -1
    x = axis();
    sigmaEstimate = SIGMAS_PER_MAD * ...
        mad([oddFoldedFluxValues(isInOddZoom); evenFoldedFluxValues(isInEvenZoom)], 1);
    x(3) = max(x(3), -transitDepth - clippingLevel * sigmaEstimate);
    x(4) = min(x(4), clippingLevel * sigmaEstimate);
    if x(4) > x(3)
        axis(x);
    end % if
end % if

isInOddZoom = abs(oddBinnedPhaseHours) < maxPhaseHours;
plot(oddBinnedPhaseHours(isInOddZoom) - maxPhaseHours, ...
    oddBinnedFluxValues(isInOddZoom), ...
    'o', 'MarkerEdgeColor', 'blue', 'MarkerFaceColor', 'cyan', ...
    'MarkerSize', BINNED_DATA_MARKER_SIZE, 'LineWidth', 1);

isInEvenZoom = abs(evenBinnedPhaseHours) < maxPhaseHours;
plot(evenBinnedPhaseHours(isInEvenZoom) + maxPhaseHours, ...
    evenBinnedFluxValues(isInEvenZoom), ...
    'o', 'MarkerEdgeColor', 'blue', 'MarkerFaceColor', 'cyan', ...
    'MarkerSize', BINNED_DATA_MARKER_SIZE, 'LineWidth', 1);

x = axis();
mark_transit_depth(planetResultsStruct.oddTransitsFit, [x(1); 0]);
mark_transit_depth(planetResultsStruct.evenTransitsFit, [0; x(2)]);

% Add text and transit markers.
text(-maxPhaseHours, x(4) - TEXT_MARKER_POSITION * (x(4) - x(3)), 'Odd', ...
    'HorizontalAlignment', 'center');
text(maxPhaseHours, x(4) - TEXT_MARKER_POSITION * (x(4) - x(3)), 'Even', ...
    'HorizontalAlignment', 'center');
plot(-maxPhaseHours, x(3) + TRANSIT_MARKER_POSITION * (x(4) - x(3)), ...
    '^', 'MarkerEdgeColor', 'red', 'MarkerFaceColor', 'red', ...
    'MarkerSize', TRANSIT_MARKER_SIZE);
plot(maxPhaseHours, x(3) + TRANSIT_MARKER_POSITION * (x(4) - x(3)), ...
    '^', 'MarkerEdgeColor', 'red', 'MarkerFaceColor', 'red', ...
    'MarkerSize', TRANSIT_MARKER_SIZE);

% Mark the boundary between the odd and even plots.
plot([0; 0], [x(3); x(4)], '--r');

% Add title and labels.
string = sprintf('Planet %d : Filtered Folded Zoomed PDC Flux Time Series [Odd / Even]', iPlanet);
title(string);
xlabel('Phase [Hours]');
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
    sprintf('%09d-%02d-odd-even-unwhitened-filtered-zoomed.fig', ...
    keplerId, iPlanet));
saveas(gcf, figureName);

% Close the figure.
close(gcf);

% Return.
return


function mark_transit_depth(transitsFit, xLimits)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function mark_transit_depth(transitsFit, xLimits)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

% Set constants.
PPM_CONVERSION = 1e6;

% Get model chi-square and transit depth.
modelChiSquare = transitsFit.modelChiSquare;
modelParameters = transitsFit.modelParameters;
if isempty(modelParameters)
    return
end % if
[depthStruct] = ...
    retrieve_model_parameter(modelParameters, 'transitDepthPpm');
transitDepth = depthStruct.value / PPM_CONVERSION;
transitDepthUncertainty = depthStruct.uncertainty / PPM_CONVERSION;

% Mark transit depth with uncertainties.
if modelChiSquare ~= -1
    plot(xLimits, [-transitDepth; -transitDepth], '-r');
    plot(xLimits, ...
        [-transitDepth+transitDepthUncertainty; -transitDepth+transitDepthUncertainty], '--r');
    plot(xLimits, ...
        [-transitDepth-transitDepthUncertainty; -transitDepth-transitDepthUncertainty], '--r');
end % if

% Return.
return
