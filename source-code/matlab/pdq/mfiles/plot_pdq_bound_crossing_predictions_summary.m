function [warningSummary, errorSummary] = ...
plot_pdq_bound_crossing_predictions_summary(pdqModuleOutputReports, ...
pdqFocalPlaneReport, excludeModules, excludeOutputs, ...
printModOutLabels, validReferencePixelsAvailable)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [warningSummary, errorSummary] = ...
% plot_pdq_bound_crossing_predictions_summary(pdqModuleOutputReports, ...
% pdqFocalPlaneReport,  excludeModules, excludeOutputs, ...
% printModOutLabels)
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

% Set the number of CCD module outputs.
N_MOD_OUTS = 84;

% Set module outputs for exclusion.
if ~exist('excludeModules', 'var')
    excludeModules = [];
end

if ~exist('excludeOutputs', 'var')
    excludeOutputs = [];
end

excludeModuleOutputs = [excludeModules(:), excludeOutputs(:)];

% Turn off mod out labels if not specified.
if ~exist('printModOutLabels', 'var')
    printModOutLabels = false;
end

% Close all figures. Set orientation to landscape.
close all;
isLandscapeOrientation = true;
includeTimeFlag = false;
printJpgFlag = false;

% Initialize the warning and error summaries. The cell array of metric name
% strings makes the initialization somewhat complicated. See matlab help
% for details.
summary = struct( ...
    'metricName', {'empty'}, ...
    'crossTime', [], ...
    'boundType', [], ...
    'module', [], ...
    'output', [], ...
    'index', [] );
summary.metricName = {};

warningSummary = summary;
errorSummary = summary;

% Get all CCD module outputs in sequence.
[modules, outputs] = convert_to_module_output(1: N_MOD_OUTS);
ccdModuleOutputs = [modules, outputs];

% Get the mod outs from the PDQ reports for which metrics were computed.
pdqReportModuleOutputs = [vertcat(pdqModuleOutputReports.ccdModule), ...
    vertcat(pdqModuleOutputReports.ccdOutput)];

% Identify the PDQ report module outputs.
[isPdqReportModuleOutput, locPdqReportsModuleOutput] = ...
    ismember(ccdModuleOutputs, pdqReportModuleOutputs, 'rows');

% Loop throught all module outputs.
for iModOut = 1 : N_MOD_OUTS
    
    % Get the CCD module and output.
    module = modules(iModOut);
    output = outputs(iModOut);

    % Get the edges of the mod out in MORC coordinates.  The rows go from 0
    % to 1043, so the edges of the mod out are rows -0.5 to 1043.5.
    % Similarly, the edges of the true mod out in column space are at column
    % 11.5 (outermost edge of column 12, since columns 0 to 11 don't actually
    % exist) and 1111.5.  
    modlist = repmat(module, [1, 4]);
    outlist = repmat(output, [1, 4]);
    rowlist = [-0.5 1043.5 1043.5 -0.5];
    collist = [11.5 11.5 1111.5 1111.5];

    % Convert the MORC coordinates of the mod out to the global focal plane
    % coordinates.
    [z, y] = morc_to_focal_plane_coords(modlist, outlist, ...
        rowlist, collist, 'zero-based');

    % Use convhull to order the box edges.      
    pointIndex = convhull(z,y);

    % Set the grid for displaying the state of the metrics within each mod
    % out.
    zg = min(z) + (max(z)-min(z)) * (0:3)/3;
    yg = min(y) + (max(y)-min(y)) * (0:4)/4;

    % Plot state of each metric for given mod out if the mod out is included
    % in the PDQ reports.
    if isPdqReportModuleOutput(iModOut) && ...
            ~ismember([module, output], excludeModuleOutputs, 'rows')
        pdqModuleOutputReport = ...
            pdqModuleOutputReports(locPdqReportsModuleOutput(iModOut));
        [warningSummary, errorSummary] = ...
            plot_mod_out_bound_crossing_predictions(pdqModuleOutputReport.backgroundLevel, ...
             'backgroundLevel', module, output, iModOut, zg, yg, 10, ...
            warningSummary, errorSummary, validReferencePixelsAvailable(iModOut));
        [warningSummary, errorSummary] = ...
            plot_mod_out_bound_crossing_predictions(pdqModuleOutputReport.blackLevel, ...
             'blackLevel', module, output, iModOut, zg, yg, 11, ...
            warningSummary, errorSummary, validReferencePixelsAvailable(iModOut));
        [warningSummary, errorSummary] = ...
            plot_mod_out_bound_crossing_predictions(pdqModuleOutputReport.centroidsMeanCol, ...
             'centroidsMeanCol', module, output, iModOut, zg, yg, 12, ...
            warningSummary, errorSummary, validReferencePixelsAvailable(iModOut));
        [warningSummary, errorSummary] = ...
            plot_mod_out_bound_crossing_predictions(pdqModuleOutputReport.centroidsMeanRow, ...
             'centroidsMeanRow', module, output, iModOut, zg, yg, 7, ...
            warningSummary, errorSummary, validReferencePixelsAvailable(iModOut));
        [warningSummary, errorSummary] = ...
            plot_mod_out_bound_crossing_predictions(pdqModuleOutputReport.darkCurrent, ...
             'darkCurrent', module, output, iModOut, zg, yg, 8, ...
            warningSummary, errorSummary, validReferencePixelsAvailable(iModOut));
        [warningSummary, errorSummary] = ...
            plot_mod_out_bound_crossing_predictions(pdqModuleOutputReport.dynamicRange, ...
             'dynamicRange', module, output, iModOut, zg, yg, 9, ...
            warningSummary, errorSummary, validReferencePixelsAvailable(iModOut));
        [warningSummary, errorSummary] = ...
            plot_mod_out_bound_crossing_predictions(pdqModuleOutputReport.encircledEnergy, ...
             'encircledEnergy', module, output, iModOut, zg, yg, 4, ...
            warningSummary, errorSummary, validReferencePixelsAvailable(iModOut));
        [warningSummary, errorSummary] = ...
            plot_mod_out_bound_crossing_predictions(pdqModuleOutputReport.meanFlux, ...
             'meanFlux', module, output, iModOut, zg, yg, 5, ...
            warningSummary, errorSummary, validReferencePixelsAvailable(iModOut));
        [warningSummary, errorSummary] = ...
            plot_mod_out_bound_crossing_predictions(pdqModuleOutputReport.plateScale, ...
             'plateScale', module, output, iModOut, zg, yg, 6, ...
            warningSummary, errorSummary, validReferencePixelsAvailable(iModOut));
        [warningSummary, errorSummary] = ...
            plot_mod_out_bound_crossing_predictions(pdqModuleOutputReport.smearLevel, ...
             'smearLevel', module, output, iModOut, zg, yg, 1, ...
            warningSummary, errorSummary, validReferencePixelsAvailable(iModOut));
    end % if 
    
    % Plot the bounding box for the mod out, with dashed lines to demarcate
    % the metric grid.
    plot(z(pointIndex), y(pointIndex), 'k', 'LineWidth', 1);
    hold on
    
    plot([zg(2), zg(2)], [yg(1), yg(5)], '--k');
    plot([zg(3), zg(3)], [yg(1), yg(5)], '--k');
    plot([zg(1), zg(4)], [yg(2), yg(2)], '--k');
    plot([zg(1), zg(4)], [yg(3), yg(3)], '--k');
    plot([zg(1), zg(4)], [yg(4), yg(4)], '--k');

    if printModOutLabels
        text((2*zg(2)+1*zg(3))/3, (1*yg(3)+1*yg(4))/2, ...
            [num2str(module), ', ', num2str(output)], 'FontSize', 8);
    end
    
end % for iModOut

% Plot the focal plane report metrics in the upper left corner.
z = [-5550; -5550; -3950; -3950];
y = [ 4750;  5250;  5250;  4750];
pointIndex = convhull(z,y);

zg = min(z) + (max(z)-min(z)) * (0:4)/4;
yg = min(y) + (max(y)-min(y)) * (0:1)/1;

if ~isempty(pdqFocalPlaneReport)
    
    [warningSummary, errorSummary] = ...
        plot_mod_out_bound_crossing_predictions(pdqFocalPlaneReport.deltaAttitudeRa, ...
         'deltaAttitudeRa', 0, 0, 0, zg, yg, 1, ...
        warningSummary, errorSummary, validReferencePixelsAvailable(iModOut));
    [warningSummary, errorSummary] = ...
        plot_mod_out_bound_crossing_predictions(pdqFocalPlaneReport.deltaAttitudeDec, ...
         'deltaAttitudeDec', 0, 0, 0, zg, yg, 2, ...
        warningSummary, errorSummary, validReferencePixelsAvailable(iModOut));
    [warningSummary, errorSummary] = ...
        plot_mod_out_bound_crossing_predictions(pdqFocalPlaneReport.deltaAttitudeRoll, ...
         'deltaAttitudeRoll', 0, 0, 0, zg, yg, 3, ...
        warningSummary, errorSummary, validReferencePixelsAvailable(iModOut));
    [warningSummary, errorSummary] = ...
        plot_mod_out_bound_crossing_predictions(pdqFocalPlaneReport.maxAttitudeResidualInPixels, ...
         'maxAttitudeResidualInPixels', 0, 0, 0, zg(2 : end), yg, 3, ...
        warningSummary, errorSummary, validReferencePixelsAvailable(iModOut));

    plot(z(pointIndex), y(pointIndex), 'k', 'LineWidth', 1) ;
    plot([zg(2), zg(2)], [yg(1), yg(2)], '--k');
    plot([zg(3), zg(3)], [yg(1), yg(2)], '--k');
    plot([zg(4), zg(4)], [yg(1), yg(2)], '-k');
    
end % if

% Save plot to fig file.
hold off
set(gca,'xtick',[],'ytick',[]);
title('[PDQ] Tracking and Trending Summary for Latest Contact -- Bound Crossing Predictions');
xlabel('FPA Z''');
ylabel('FPA Y''');
plot_to_file('pdq_bound_crossing_predictions_across_the_focal_plane', ...
    isLandscapeOrientation, includeTimeFlag, printJpgFlag);

% Return.
return


function [warningSummary, errorSummary] = ...
plot_mod_out_bound_crossing_predictions(report, metricName, ...
module, output, index, zg, yg, iMetric, warningSummary, errorSummary, ...
dataAvailable)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [warningSummary, errorSummary] = ...
% plot_mod_out_bound_crossing_predictions(report, metricName, ...
% module, output, index, zg, yg, iMetric, warningSummary, errorSummary)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Plot grid square green if metric is not predicted to be out of bounds
% within horizon time, yellow if it is predicted to be out of adaptive
% bounds, or red if it is predicted to be out of fixed bounds (highest
% precedence). Also update warning and error summary structures with metric
% name, module, output, linear mod out index and predicted crossing time.
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

adaptiveBoundsReport = report.adaptiveBoundsReport;
fixedBoundsReport = report.fixedBoundsReport;

if report.time == -1 | ~dataAvailable
    colorMetricRectangle(zg, yg, iMetric, 'c');
elseif fixedBoundsReport.upperBoundCrossingPredicted  || ...
        fixedBoundsReport.lowerBoundCrossingPredicted
    colorMetricRectangle(zg, yg, iMetric, 'r');
elseif isfield(report.alerts, 'message') && ...
        ~isempty(strfind([report.alerts.message], 'gaps in latest reference pixels'))
    colorMetricRectangle(zg, yg, iMetric, 'm'); 
elseif adaptiveBoundsReport.upperBoundCrossingPredicted  || ...
        adaptiveBoundsReport.lowerBoundCrossingPredicted
    colorMetricRectangle(zg, yg, iMetric, 'y');
else
    colorMetricRectangle(zg, yg, iMetric, 'g');
end

if report.time ~= -1 && ...
        fixedBoundsReport.upperBoundCrossingPredicted  || ...
        fixedBoundsReport.lowerBoundCrossingPredicted
    errorSummary.metricName = [errorSummary.metricName; metricName];
    errorSummary.module = [errorSummary.module; module];
    errorSummary.output = [errorSummary.output; output];
    errorSummary.index = [errorSummary.index; index];
    errorSummary.crossTime = [errorSummary.crossTime; ...
        fixedBoundsReport.crossingTime];
    errorSummary.boundType = [errorSummary.boundType; ...
        double(fixedBoundsReport.upperBoundCrossingPredicted)];
end

if report.time ~= -1 && ...
        adaptiveBoundsReport.upperBoundCrossingPredicted  || ...
        adaptiveBoundsReport.lowerBoundCrossingPredicted
    warningSummary.metricName = [warningSummary.metricName; metricName];
    warningSummary.module = [warningSummary.module; module];
    warningSummary.output = [warningSummary.output; output];
    warningSummary.index = [warningSummary.index; index];
    warningSummary.crossTime = [warningSummary.crossTime; ...
        adaptiveBoundsReport.crossingTime];
    warningSummary.boundType = [warningSummary.boundType; ...
        double(adaptiveBoundsReport.upperBoundCrossingPredicted)];
end

return
    
    
function colorMetricRectangle(zg, yg, iMetric, color)

width = zg(2) - zg(1);
height = yg(2) - yg(1);

zIndex = 1 + mod(iMetric - 1, 3);
yIndex = 1 + floor((iMetric - 1) / 3);


rectangle('Position', [zg(zIndex), yg(yIndex), width, height], ...
    'FaceColor', color, 'LineStyle' , 'none');
hold on

return
    