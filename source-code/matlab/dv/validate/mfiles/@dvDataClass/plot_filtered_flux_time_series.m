function plot_filtered_flux_time_series(dvDataObject, dvResultsStruct, ...
iTarget, iPlanet)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function plot_filtered_flux_time_series(dvDataObject, dvResultsStruct, ...
% iTarget, iPlanet)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Create figure displaying the detrended (by median filtering) initial
% flux time series for the given planet candidate. Make sure that filled
% cadences are not displayed. Mark the expected timestamps for all
% transits, observed or otherwise. Also mark the quarterly boundaries.
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
TEXT_MARKER_POSITION = 0.025;
PERCENTILE_FOR_PLOTTING = 99.5;
DAYS_TO_PAD = 5.0;

% Get the cadence duration in days.
dvCadenceTimes = dvDataObject.dvCadenceTimes;
lcTargetTableIds = dvCadenceTimes.lcTargetTableIds;
quarters = dvCadenceTimes.quarters;

% Get the barycentric timestamps for the given target. They should be
% defined for all cadences.
midCadenceTimestamps = ...
    dvDataObject.barycentricCadenceTimes(iTarget).midTimestamps;
endCadenceTimestamps = ...
    dvDataObject.barycentricCadenceTimes(iTarget).endTimestamps;

% Get the fit parameters. Fall back to the trapezoidal model fit results if
% the all transits fit did not succeed.
planetResultsStruct = ...
    dvResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(iPlanet);
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

% Get the detrended flux time series for the given planet candidate. Set
% the gap filled cadences to NaN.
detrendedFluxTimeSeries = planetResultsStruct.detrendedFluxTimeSeries;
filteredTimeSeriesValues = detrendedFluxTimeSeries.values;
filteredTimeSeriesValues(detrendedFluxTimeSeries.filledIndices) = NaN;
yLim = prctile(filteredTimeSeriesValues, PERCENTILE_FOR_PLOTTING);

% Plot the detrended time series.
figure;
plot(midCadenceTimestamps, filteredTimeSeriesValues, '.k', ...
    'MarkerSize', DATA_MARKER_SIZE);

% Mark the expected times of transit based on the epoch and period in red.
% Mark the epochs of the rolling band corrupted transits in blue.
lastTransit = floor((endCadenceTimestamps(end) - transitEpochBkjd) / orbitalPeriodDays);
transitTimestamps = transitEpochBkjd + (0 : lastTransit)' * orbitalPeriodDays;

x = axis();
x(1) = floor(midCadenceTimestamps(1)) - DAYS_TO_PAD;
x(2) = ceil(midCadenceTimestamps(end)) + DAYS_TO_PAD;
x(4) = yLim + 4 * TEXT_MARKER_POSITION * (yLim - x(3));
axis(x);

hold on;
markerValue = x(3) + TRANSIT_MARKER_POSITION * (x(4) - x(3));
plot(transitTimestamps, repmat(markerValue, size(transitTimestamps)), ...
    '^', 'MarkerEdgeColor', 'blue', 'MarkerFaceColor', 'blue', ...
    'MarkerSize', TRANSIT_MARKER_SIZE);

rollingBandContaminationHistogram = ...
    planetResultsStruct.imageArtifactResults.rollingBandContaminationHistogram;
transitMetadata = rollingBandContaminationHistogram.transitMetadata;
corruptedTransitEpochs = sort(vertcat(transitMetadata.epochs));
plot(corruptedTransitEpochs, repmat(markerValue, size(corruptedTransitEpochs)), ...
    '^', 'MarkerEdgeColor', 'red', 'MarkerFaceColor', 'red', ...
    'MarkerSize', TRANSIT_MARKER_SIZE);

% Mark the quarterly boundaries and module output.
tableIds = unique(lcTargetTableIds);
markerValue = x(4) - TEXT_MARKER_POSITION * (x(4) - x(3));

for iTable = 1 : length(tableIds)
    startIndex = ...
        find(lcTargetTableIds == tableIds(iTable), 1, 'first');
    startTimestamp = midCadenceTimestamps(startIndex);
    plot([startTimestamp; startTimestamp], [x(3); x(4)], '--r');
    [ccdModule, ccdOutput] = ...
        get_mod_out_for_target_table(dvDataObject.targetTableDataStruct, ...
        tableIds(iTable));
    text(startTimestamp, markerValue, ...
       ['Q', num2str(quarters(startIndex)), ' [', ...
       num2str(ccdModule), '.', num2str(ccdOutput), ']']);
end % for iTable

% Add title and labels.
string = sprintf('Planet %d : Filtered PDC Flux Time Series', iPlanet);
title(string);
xlabel('Time [BKJD]');
ylabel('Relative Flux');
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
    sprintf('%09d-%02d-all-unwhitened-filtered.fig', ...
    keplerId, iPlanet));
saveas(gcf, figureName);

% Close the figure.
close(gcf);

% Return.
return


function [ccdModule, ccdOutput] = ...
get_mod_out_for_target_table(targetTableDataStruct, tableId)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [ccdModule, ccdOutput] = ...
% get_mod_out_for_target_table(targetTableDataStruct, tableId)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Return the module and output for the specified target table.
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

ccdModule = 0;
ccdOutput = 0;

targetTableIds = [targetTableDataStruct.targetTableId];

[tf, loc] = ismember(tableId, targetTableIds);

if tf
    ccdModule = targetTableDataStruct(loc).ccdModule;
    ccdOutput = targetTableDataStruct(loc).ccdOutput;
end % if

return
