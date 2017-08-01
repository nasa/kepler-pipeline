function plot_filtered_zoomed_flux_time_series_for_secondary( ...
dvDataObject, dvResultsStruct, iTarget, iPlanet, nTransitTimesZoom)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function plot_filtered_zoomed_flux_time_series_for_secondary( ...
% dvDataObject, dvResultsStruct, iTarget, iPlanet, nTransitTimesZoom)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Create figure displaying the detrended (by median filtering) initial
% flux time series folded and zoomed on weak secondary for the given planet
% candidate.
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
BINNED_DATA_MARKER_SIZE = 6.0;
TRANSIT_MARKER_SIZE = 6.0;
TRANSIT_MARKER_POSITION = 0.025;
SIGMAS_PER_MAD = 1.4826;
SECONDARY_DEPTH_MULTIPLIER = 1.4;
CONTROL_BUFFER_IN_CADENCES = 1;

% Get required fields.
clippingLevel = ...
    dvDataObject.planetFitConfigurationStruct.reportSummaryClippingLevel;
binsPerTransit = ...
    dvDataObject.planetFitConfigurationStruct.reportSummaryBinsPerTransit;

% Get the barycentric timestamps for the given target. They should be
% defined for all cadences.
cadenceTimestamps = ...
    dvDataObject.barycentricCadenceTimes(iTarget).midTimestamps;

% Get the model light curve and relevant fit results for the given planet
% candidate. Fall back to the trapezoidal model fit results if the all
% transits fit did not succeed.
planetResultsStruct = ...
    dvResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(iPlanet);
[fitResultsStruct, modelLightCurve] = ...
    get_fit_results_for_diagnostic_test(planetResultsStruct);
if isempty(fitResultsStruct)
    fitResultsStruct = planetResultsStruct.allTransitsFit;
    modelLightCurve = planetResultsStruct.modelLightCurve.values;
    modelLightCurve(planetResultsStruct.modelLightCurve.gapIndicators) = 0;
end % if
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

% Get the weak secondary results.
weakSecondaryStruct = ...
    planetResultsStruct.planetCandidate.weakSecondaryStruct;
maxMesPhaseInDays = weakSecondaryStruct.maxMesPhaseInDays;

% Get the detrended flux time series for the given planet candidate. Set
% the gap filled cadences to NaN.
detrendedFluxTimeSeries = planetResultsStruct.detrendedFluxTimeSeries;
filteredTimeSeriesValues = detrendedFluxTimeSeries.values;
filteredTimeSeriesValues(detrendedFluxTimeSeries.filledIndices) = NaN;

% Set the in-transit flux values to NaN as well.
isInTransit = modelLightCurve < 0;
inTransitCadences = find(isInTransit);
for iCadence = 1 : length(isInTransit)
    if min(abs(iCadence - inTransitCadences)) <= CONTROL_BUFFER_IN_CADENCES
        isInTransit(iCadence) = true;
    end % if
end % for iCadence
filteredTimeSeriesValues(isInTransit) = NaN;

% Perform the folding about the best phase.
[phase, phaseSorted, sortKey, foldedFluxValues] = ...
    fold_time_series(cadenceTimestamps, transitEpochBkjd + maxMesPhaseInDays, ...
    orbitalPeriodDays, filteredTimeSeriesValues);                                                              %#ok<ASGLU>
phaseHours = phaseSorted * orbitalPeriodDays * get_unit_conversion('day2hour');

% Perform the binning and averaging.
[binnedPhaseHours, binnedFluxValues] = ...
    bin_and_average_time_series_by_cadence_time( ...
    phaseHours, foldedFluxValues, 0, ...
    transitDurationHours / binsPerTransit, ...
    isnan(foldedFluxValues));

% The nTransitTimesZoom may exceed the total range of times which are
% present in the data (unlikely but possible). Handle that case now.
nTransitTimesZoom = min(nTransitTimesZoom, ...
    range(phaseHours)/transitDurationHours ) ;
maxPhaseHours = nTransitTimesZoom / 2 * transitDurationHours;

% Draw the plot with appropriate scaling if transit depth is known.
figure;

isInZoom = abs(phaseHours) < maxPhaseHours;
plot(phaseHours(isInZoom), foldedFluxValues(isInZoom), ...
    '.k', 'MarkerSize', DATA_MARKER_SIZE);

x = axis();
x(1) = -maxPhaseHours;
x(2) = maxPhaseHours;
axis(x);

sigmaEstimate = SIGMAS_PER_MAD * mad(foldedFluxValues(isInZoom), 1);
secondaryDepth = mean(binnedFluxValues(abs(binnedPhaseHours) <= ...
    1.5 * transitDurationHours / binsPerTransit));
x(3) = max(x(3), min(-clippingLevel * sigmaEstimate, ...
    SECONDARY_DEPTH_MULTIPLIER * secondaryDepth));
x(4) = min(x(4), clippingLevel * sigmaEstimate);
if x(4) > x(3)
    axis(x);
end % if
hold on

isInZoom = abs(binnedPhaseHours) < maxPhaseHours;
plot(binnedPhaseHours(isInZoom), binnedFluxValues(isInZoom), ...
    'o', 'MarkerEdgeColor', 'blue', 'MarkerFaceColor', 'cyan', ...
    'MarkerSize', BINNED_DATA_MARKER_SIZE, 'LineWidth', 1);

% Add text and transit markers.
x = axis();
plot(0, x(3) + TRANSIT_MARKER_POSITION * (x(4) - x(3)), ...
    '^', 'MarkerEdgeColor', 'red', 'MarkerFaceColor', 'red', ...
    'MarkerSize', TRANSIT_MARKER_SIZE);

% Add title and labels.
string = sprintf('Planet %d : Filtered Folded Averaged Zoomed On Weak Secondary PDC Flux Time Series', iPlanet);
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
    sprintf('%09d-%02d-all-unwhitened-filtered-zoomed-secondary.fig', ...
    keplerId, iPlanet));
saveas(gcf, figureName);

% Close the figure.
close(gcf);

% Return.
return
