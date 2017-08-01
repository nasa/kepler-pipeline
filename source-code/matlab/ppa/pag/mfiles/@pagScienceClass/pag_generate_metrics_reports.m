function pag_generate_metrics_reports(pagScienceObject, pagOutputStruct, alertType, reportType)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function pag_generate_metrics_reports(pagScienceObject, pagOutputStruct, alertType, reportType)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% This fuction generates track and trend report of PPA metric time series.
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

if nargin ~= 4
    error('PAG:generateMetricsReports:wrongNumberOfInputs', ...
        'This function must be called with 4 input arguments');
end

if ( isempty (reportType) )
    error('PAG:generateMetricsReports:invalidInput', 'reportType cannot be empty.');
elseif ( ~ismember(reportType, {'metricStates'            'metricArrayStates' ...
                                'cosmicRayStatesPage1'    'cosmicRayStatesPage2' ...
                                'cdpp3HourStatesPage1'    'cdpp3HourStatesPage2' ...
                                'cdpp6HourStatesPage1'    'cdpp6HourStatesPage2' ...
                                'cdpp12HourStatesPage1'   'cdpp12HourStatesPage2' }) )
    error('PAG:generateMetricsReports:invalidInput', 'Value of reportType is invalid.');
end

metricString  = { 'blackLevel',                          'smearLevel',                       'darkCurrent',     ...
                  'brightness',                          'encircledEnergy',                  'backgroundLevel', ...
                  'centroidsMeanRow',                    'centroidsMeanColumn',              'plateScale',      ...
                  'theoreticalCompressionEfficiency',    'achievedCompressionEfficiency'                        };
crString1     = { 'blackCosmicRayMetrics',       ...
                  'maskedSmearCosmicRayMetrics', ...
                  'virtualSmearCosmicRayMetrics' };
crString2     = { 'targetStarCosmicRayMetrics', ...
                  'backgroundCosmicRayMetrics'   };
crFieldString = { 'hitRate', 'meanEnergy', 'energyVariance' };
magString1    = { 'mag9',  ...
                  'mag10', ...
                  'mag11' };
magString2    = { 'mag12', ...
                  'mag13', ...
                  'mag14', ...
                  'mag15' };
cdppTypeString    = { 'cdppMeasured', 'cdppExpected', 'cdppRatio' };           
                 
% Set orientation to landscape.
% isLandscapeOrientation = true;

% Get the track and trend reports of all avialable module/outputs.  
reports = pagScienceObject.reports;

% Get the edges of the mod out in MORC coordinates.  
rowlist = [-0.5 1043.5 1043.5 -0.5];
collist = [11.5 11.5 1091.5 1091.5];

% Plot focal plane for reports
pag_plot_focal_plane(pagScienceObject.fcConstants.MODULE_OUTPUTS, rowlist, collist);

titleString = '';
% Loop throught all module outputs.
for iModOut = 1 : length(reports)

    % Get the track and trend report of one module/output
    moduleOutputReport = reports(iModOut);

    % Get the CCD module and output.
    module  = moduleOutputReport.ccdModule;
    output  = moduleOutputReport.ccdOutput;
    modlist = repmat(module, [1, 4]);
    outlist = repmat(output, [1, 4]);

    % Convert the MORC coordinates of the mod out to the global focal plane coordinates.
    [z, y] = morc_to_focal_plane_coords(modlist, outlist, rowlist, collist, 'one-based');

    % Use convhull to order the box edges.
    pointIndex = convhull(z,y);

    % Set the grid for displaying the state of the metrics within each mod out.
    zg = min(z) + (max(z)-min(z)) * (0:3)/3;
    yg = min(y) + (max(y)-min(y)) * (0:4)/4;

    nLdeUndershoot = length(moduleOutputReport.ldeUndershoot);
    nTwoDBlack     = length(moduleOutputReport.twoDBlack);
    
    switch (reportType)
        case 'metricStates'
            for iMetric = 1:length(metricString)
                plot_mod_out_metric_state(moduleOutputReport.(metricString{iMetric}), zg, yg, iMetric, alertType);
            end
            titleString = ['PPA ' alertType ' states of general metrics'];
        case 'metricArrayStates'
            for iLdeUndershoot = 1:min(3,nLdeUndershoot)
                plot_mod_out_metric_state(moduleOutputReport.ldeUndershoot(iLdeUndershoot),  zg, yg, iLdeUndershoot, alertType);
            end
            for iTwoDBlack = 1:min(6,nTwoDBlack)
                plot_mod_out_metric_state(moduleOutputReport.twoDBlack(iTwoDBlack),          zg, yg, 3+iTwoDBlack,   alertType);
            end
            titleString = ['PPA ' alertType ' states of two-D black targets and LDE undershoot targets'];
        case 'cosmicRayStatesPage1'
            for iCr = 1:length(crString1)
                for iCrField = 1:length(crFieldString)
                    plot_mod_out_metric_state(moduleOutputReport.(crString1{iCr}).(crFieldString{iCrField}), zg, yg, (iCr-1)*3+iCrField, alertType);
                end
            end
            titleString = ['PPA ' alertType ' states of cosmic ray metrics: black, maskedSmear and virtualSmear pixels'];
        case 'cosmicRayStatesPage2'
            for iCr = 1:length(crString2)
                for iCrField = 1:length(crFieldString)
                    plot_mod_out_metric_state(moduleOutputReport.(crString2{iCr}).(crFieldString{iCrField}), zg, yg, (iCr-1)*3+iCrField, alertType);
                end
            end
            titleString = ['PPA ' alertType ' states of cosmic ray metrics: target star and background pixels'];
        case 'cdpp3HourStatesPage1'
            for iMag = 1:length(magString1)
                for iType = 1:length(cdppTypeString)
                    plot_mod_out_metric_state(moduleOutputReport.(cdppTypeString{iType}).(magString1{iMag}).threeHour, zg, yg, (iMag-1)*3+iType, alertType);
                end
            end
            titleString = ['PPA ' alertType ' states of CDPP 3-Hour metrics: magnitudes 9-11'];
        case 'cdpp3HourStatesPage2'
            for iMag = 1:length(magString2)
                for iType = 1:length(cdppTypeString)
                    plot_mod_out_metric_state(moduleOutputReport.(cdppTypeString{iType}).(magString2{iMag}).threeHour, zg, yg, (iMag-1)*3+iType, alertType);
                end
            end
            titleString = ['PPA ' alertType ' states of CDPP 3-Hour metrics: magnitudes 12-15'];
        case 'cdpp6HourStatesPage1'
            for iMag = 1:length(magString1)
                for iType = 1:length(cdppTypeString)
                    plot_mod_out_metric_state(moduleOutputReport.(cdppTypeString{iType}).(magString1{iMag}).sixHour, zg, yg, (iMag-1)*3+iType, alertType);
                end
            end
            titleString = ['PPA ' alertType ' states of CDPP 6-Hour metrics: magnitudes 9-11'];
        case 'cdpp6HourStatesPage2'
            for iMag = 1:length(magString2)
                for iType = 1:length(cdppTypeString)
                    plot_mod_out_metric_state(moduleOutputReport.(cdppTypeString{iType}).(magString2{iMag}).sixHour, zg, yg, (iMag-1)*3+iType, alertType);
                end
            end
            titleString = ['PPA ' alertType ' states of CDPP 6-Hour metrics: magnitudes 12-15'];
        case 'cdpp12HourStatesPage1'
            for iMag = 1:length(magString1)
                for iType = 1:length(cdppTypeString)
                    plot_mod_out_metric_state(moduleOutputReport.(cdppTypeString{iType}).(magString1{iMag}).twelveHour, zg, yg, (iMag-1)*3+iType, alertType);
                end
            end
            titleString = ['PPA ' alertType ' states of CDPP 12-Hour metrics: magnitudes 9-11'];
        case 'cdpp12HourStatesPage2'
            for iMag = 1:length(magString2)
                for iType = 1:length(cdppTypeString)
                    plot_mod_out_metric_state(moduleOutputReport.(cdppTypeString{iType}).(magString2{iMag}).twelveHour, zg, yg, (iMag-1)*3+iType, alertType);
                end
            end
            titleString = ['PPA ' alertType ' states of CDPP 12-Hour metrics: magnitudes 12-15'];
    end

    % Plot the bounding box for the mod out, with dashed lines to demarcate the metric grid.
    plot(z(pointIndex), y(pointIndex), 'k', 'LineWidth', 1);
    hold on

    plot([zg(2), zg(2)], [yg(1), yg(5)], '--k');
    plot([zg(3), zg(3)], [yg(1), yg(5)], '--k');
    plot([zg(1), zg(4)], [yg(2), yg(2)], '--k');
    plot([zg(1), zg(4)], [yg(3), yg(3)], '--k');
    plot([zg(1), zg(4)], [yg(4), yg(4)], '--k');

    text((2*zg(2)+1*zg(3))/3, (1*yg(2)+1*yg(3))/2, [num2str(module), ', ', num2str(output)], 'FontSize', 5);

end % for iModOut

if ( strcmp(reportType, 'metricStates') )
    % Set the plane coordinates of rectangles of the compressionEfficiency metrics
    zCe    = [4000 4500 5000];
    yCe    = [4000 4500];
    rowNum = 1;
    plot_mod_out_metric_state(pagOutputStruct.report.theoreticalCompressionEfficiency, zCe, yCe, 1, alertType, rowNum, '-');
    plot_mod_out_metric_state(pagOutputStruct.report.achievedCompressionEfficiency,    zCe, yCe, 2, alertType, rowNum, '-');
end

% Save plot to fig file.
hold off
set(gca,'xtick',[],'ytick',[]);
title(titleString);
xlabel('FPA Z''');
ylabel('FPA Y''');
axis('equal');
axis('square');
% plot_to_file('pag_track_trend_summary', isLandscapeOrientation);

return


function plot_mod_out_metric_state(report, zg, yg, iMetric, alertType, rowNum, lineStyle)

if ~exist('rowNum', 'var')
    rowNum = 4;
end
if ~exist('lineStyle', 'var')
    lineStyle = 'none';
end

eval(['alertLevel = report.' alertType 'AlertLevel;']);
colorCode = {'c' 'g' 'y' 'r'};
color     = colorCode{alertLevel+2};

width  = zg(2) - zg(1);
height = yg(2) - yg(1);
zIndex = 1 + mod(iMetric - 1, 3);
yIndex = rowNum - floor((iMetric - 1) / 3); 
rectangle('Position', [zg(zIndex), yg(yIndex), width, height], 'FaceColor', color, 'LineStyle', lineStyle);
hold on

return
    

