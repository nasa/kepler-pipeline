%% pmd_generate_report
%
% function reportFilename = pmd_generate_report(...
%    pmdInputStruct, pmdOutputStruct, pmdTempStruct)
%
% Generates the PMD report.
%
%% INPUTS
% * *pmdInputStruct*: the input struct
% * *pmdOutputStruct*: the output struct
% * *pmdTempStruct*: a structure containing other PMD variables
% * *sourceDirectory*: the name of the directory that contains the inputs
%
%% OUTPUTS
% * *reportFilename*: the name of the directory that contains the report's
%                     artifacts
%
%% ALGORITHM
%%
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

function reportFilename = pmd_generate_report(...
    pmdInputStruct, pmdOutputStruct, pmdTempStruct, sourceDirectory)

if (nargin ~= 3 && nargin ~= 4)
    disp('Usage: pmd_generate_report(pmdInputStruct, pmdOutputStruct, pmdTempStruct [, sourceDirectory])');
    return;
end
if (~exist('sourceDirectory', 'var'))
    sourceDirectory = '';
end

CSCI = 'pmd';

REPORT_ALIASES = 'report-values.sty';
ANOMALY_TABLE = 'anomaly.tex';
ANOMALY_SUMMARY_TABLE = 'anomaly-summary.tex';

TRACK = 'Tracking';
TREND = 'Trending';
CDPP9TO11 = 'cdpp9to11';
CDPP12TO15 = 'cdpp12to15';

reportDate = now;
ccdModule = pmdInputStruct.ccdModule;
ccdOutput = pmdInputStruct.ccdOutput;
[startMjd, endMjd] = uowMjds(pmdInputStruct.cadenceTimes);
startUtc = mjd_to_utc(startMjd, 31);
endUtc = mjd_to_utc(endMjd, 31);
reportDir = [CSCI '-' int2str(ccdModule) '-' int2str(ccdOutput)];

% Copy static files and rename pmd-report.tex as required.
report_copy_static_files(CSCI, reportDir);
movefile(fullfile(reportDir, 'pmd-report.tex'), ...
    fullfile(reportDir, [reportDir '.tex']));

% Generate dynamic files and data.
fid = report_open_latex_file(reportDir, REPORT_ALIASES);

generate_summary();
generate_inputs();
generate_metrics_summary();
generate_metric_tracking();
generate_bounds_breakers();
generate_metric_trending();

xclose(fid, REPORT_ALIASES);

% Tell module interface to scoop up entire directory.
reportFilename = reportDir;

% Return the timestamp of the first and last cadence regardless of whether
% it is gapped.
    function [startMjd, endMjd] = uowMjds(cadenceTimes)
        midTimestamps = cadenceTimes.midTimestamps;
        gapIndicators = cadenceTimes.gapIndicators;
        midTimestamps(gapIndicators) = interp1(find(~gapIndicators), ...
            midTimestamps(~gapIndicators), find(gapIndicators), ...
            'linear', 'extrap');
       startMjd = midTimestamps(1);
       endMjd = midTimestamps(end);
    end

%% * Generate table of general information.
    function generate_summary()

        data = {'generated' local_time_to_utc(reportDate, 31); ...
            'pipelineModule' 'ppa'; ...
            'ccdModule' ccdModule; ...
            'ccdOutput' ccdOutput};
        report_add_static_table(fid, data);
    end

%% * Generate table of inputs.
    function generate_inputs()

        data = {'nCadences' length(pmdInputStruct.cadenceTimes.midTimestamps); ...
            'nGappedCadences' length(find(pmdInputStruct.cadenceTimes.gapIndicators==1)); ...
            'startMjd' startMjd; ...
            'endMjd' endMjd; ...
            'startUtc' startUtc; ...
            'endUtc' endUtc; ...
            'startCadence' pmdInputStruct.cadenceTimes.cadenceNumbers(1); ...
            'endCadence' pmdInputStruct.cadenceTimes.cadenceNumbers(end)};
        report_add_static_table(fid, data);
    end

%% * Generate metrics summary.
    function generate_metrics_summary()

        create_dashboard_figure('trackAlertLevel', 'trackDashboard');
        create_dashboard_figure('trendAlertLevel', 'trendDashboard');
        create_bounds_breaking_figure('gnrlProjBndsBreak', 1);
        create_bounds_breaking_figure('LDE2DBlkProjBndsBreak', 2);
        create_bounds_breaking_figure('CRProjBndsBreak', 3);
        create_bounds_breaking_figure('CDPP03ProjBndsBreak', 4);
        create_bounds_breaking_figure('CDPP06ProjBndsBreak', 5);
        create_bounds_breaking_figure('CDPP12ProjBndsBreak', 6);
    end

    function create_dashboard_figure(alert, name)
        
        figure('Position', [0 0 800 600]);

        pmd_plot_track_trend_summary(pmdOutputStruct.report, ...
            alert, ' ');
        
        basename = pmd_get_plot_filename(name, ccdModule, ccdOutput, reportDate);
        saveas(gcf, fullfile(sourceDirectory, basename));
        close(gcf);
        
        report_add_figure(reportDir, fid, name, sourceDirectory, basename);
    end

    function create_bounds_breaking_figure(name, plotRegion)
        
        [axisLabels, adaptValues] = pmd_get_mjd_for_bounds_breaking( ...
            pmdOutputStruct.report, 0, plotRegion); %#ok<ASGLU>
        [axisLabels, fixedValues] = pmd_get_mjd_for_bounds_breaking( ...
            pmdOutputStruct.report, 1, plotRegion);
        adaptTime = adaptValues - endMjd;
        fixedTime = fixedValues - endMjd;

        figure('Position', [0 0 600 300]);

        goodvals = find(adaptTime >= 0);
        nGoodAdapt = length(goodvals);
        plot(goodvals, adaptTime(goodvals), 'bs');
        
        hold on;
        goodvals = find(fixedTime >= 0);
        nGoodValues = length(goodvals);
        plot(goodvals, fixedTime(goodvals), 'md');
        
        if (nGoodAdapt > 0 && nGoodValues > 0)
            legend('Adaptive Bounds', 'Fixed Bounds');
        elseif (nGoodValues > 0)
            legend('Fixed Bounds');
        elseif (nGoodAdapt > 0)
            legend('Adaptive Bounds');
        end
        axis([0 length(fixedTime)+1 0 pmdInputStruct.pmdModuleParameters.horizonTime+1]);
        
        ylabel('Time to Projected Bounds Break [days]');
        set(gca, 'XTick', 1:length(fixedTime));
        set(gca, 'XTickLabel', axisLabels);
        report_adjust_plot_x_axis_location(0.15);
        rotate_x_tick_label(gca);

        basename = pmd_get_plot_filename(name, ccdModule, ccdOutput, reportDate);
        saveas(gcf, fullfile(sourceDirectory, basename));
        close(gcf);
        
        report_add_figure(reportDir, fid, name, sourceDirectory, basename);
    end

%% * Generate metric tracking
    function generate_metric_tracking()

        create_general_metrics_figure(TRACK);
        create_lde_undershoot_and_2d_black_figure(TRACK);
        create_cosmic_ray_metrics_figure(TRACK);
        create_cdpp_metrics_figure(TRACK, CDPP9TO11, 'threeHour');
        create_cdpp_metrics_figure(TRACK, CDPP12TO15, 'threeHour');
        create_cdpp_metrics_figure(TRACK, CDPP9TO11, 'sixHour');
        create_cdpp_metrics_figure(TRACK, CDPP12TO15, 'sixHour');
        create_cdpp_metrics_figure(TRACK, CDPP9TO11, 'twelveHour');
        create_cdpp_metrics_figure(TRACK, CDPP12TO15, 'twelveHour');
    end

    function create_general_metrics_figure(mode)

        inputTsData = pmdInputStruct.inputTsData;
        outputTsData = pmdOutputStruct.outputTsData;

        figure('Position', [0 0 700 700]);

        create_general_metrics_subplot(mode, 1, 'blackLevel', inputTsData);
        create_general_metrics_subplot(mode, 2, 'smearLevel', inputTsData);
        create_general_metrics_subplot(mode, 3, 'darkCurrent', inputTsData);
        create_general_metrics_subplot(mode, 4, 'brightness', inputTsData);
        create_general_metrics_subplot(mode, 5, 'encircledEnergy', inputTsData);
        create_general_metrics_subplot(mode, 6, 'backgroundLevel', outputTsData, 'bkgdLevel');
        create_general_metrics_subplot(mode, 7, 'centroidsMeanRow', outputTsData, 'meanRow');
        create_general_metrics_subplot(mode, 8, 'centroidsMeanColumn', outputTsData, 'meanColumn');
        create_general_metrics_subplot(mode, 9, 'plateScale', outputTsData);
        create_general_metrics_subplot(mode, 10, 'theoreticalCompressionEfficiency', inputTsData, 'theoCompEff', 'compression');
        create_general_metrics_subplot(mode, 11, 'achievedCompressionEfficiency', inputTsData, 'achvCompEff', 'compression');
        
        name = ['generalMetric' mode];
        basename = pmd_get_plot_filename(name, ccdModule, ccdOutput, reportDate);
        saveas(gcf, fullfile(sourceDirectory, basename));
        close(gcf);
        
        report_add_figure(reportDir, fid, name, sourceDirectory, basename);
    end

    function create_general_metrics_subplot(mode, plotNumber, metricName, tsData, ...
            newTitle, metricName2)
        
        if (~exist('newTitle', 'var'))
            newTitle = '';
        end
        if (~exist('metricName2', 'var'))
            metricName2 = '';
        end
        
        subplot(4, 3, plotNumber);
        if (strcmp(mode, TRACK))
            pmd_plot_time_series_metrics(tsData, pmdTempStruct, ...
                pmdInputStruct.pmdModuleParameters, ...
                pmdInputStruct.cadenceTimes.midTimestamps, ...
                pmdInputStruct.cadenceTimes.gapIndicators, ...
                metricName, metricName2, true, newTitle);
        else
            pmd_track_trend_time_series_metrics( ...
                tsData, pmdOutputStruct, pmdTempStruct, ...
                pmdInputStruct.pmdModuleParameters, ...
                pmdInputStruct.cadenceTimes.midTimestamps, ...
                pmdInputStruct.cadenceTimes.gapIndicators, ...
                ccdModule, ccdOutput, ...
                metricName, metricName2, true, newTitle);
        end
        xlabel('');
        ylabel('');
        legend('off');
    end

    function create_lde_undershoot_and_2d_black_figure(mode)
        
        nLdePlots = min([length(pmdInputStruct.inputTsData.ldeUndershoot) ...
            length(pmdTempStruct.ldeUndershoot)]);
        n2dBlackPlots = min([length(pmdInputStruct.inputTsData.twoDBlack) ...
            length(pmdTempStruct.twoDBlack)]);
        nColumns = 3;
        nRows = ceil((nLdePlots + n2dBlackPlots)/nColumns);
        
        if nRows == 0
            nRows         = 1;
            nLdePlots     = 1;
            n2dBlackPlots = 1;
        end
        
        figure('Position', [0 0 700 175*nRows]);
        currentPlot = 1;
        
        for i = 1 : nLdePlots
            create_lde_undershoot_and_2d_black_subplot(mode, currentPlot, ...
                'ldeUndershoot', i, nRows, nColumns);
            currentPlot = currentPlot + 1;
        end
        
        for i = 1 : n2dBlackPlots
            create_lde_undershoot_and_2d_black_subplot(mode, currentPlot, ...
                'twoDBlack', i, nRows, nColumns);
            currentPlot = currentPlot + 1;
        end
        
        name = ['lde+2DBlackMetric' mode];
        basename = pmd_get_plot_filename(name, ccdModule, ccdOutput, reportDate);
        saveas(gcf, fullfile(sourceDirectory, basename));
        close(gcf);
        
        report_add_figure(reportDir, fid, name, sourceDirectory, basename);
        
    end

    function create_lde_undershoot_and_2d_black_subplot(mode, plotNumber, metricName, iType, nRows, nColumns)
        subplot(nRows, nColumns, plotNumber);
        if (strcmp(mode, TRACK))
            pmd_plot_metrics_array(pmdInputStruct.inputTsData, pmdTempStruct, ...
                pmdInputStruct.pmdModuleParameters, ...
                pmdInputStruct.cadenceTimes.midTimestamps, ...
                pmdInputStruct.cadenceTimes.gapIndicators, ...
                iType, metricName);
        elseif (strcmp(mode, TREND))
            pmd_track_trend_metrics_array(pmdInputStruct.inputTsData, ...
                pmdOutputStruct, pmdTempStruct, ...
                pmdInputStruct.pmdModuleParameters, ...
                pmdInputStruct.cadenceTimes.midTimestamps, ...
                pmdInputStruct.cadenceTimes.gapIndicators, ...
                ccdModule, ccdOutput, ...
                iType, metricName, '', [metricName ' Target #' iType]);
        end
        legend('off');
        report_adjust_plot_x_axis_location(0.05);
    end

    function create_cosmic_ray_metrics_figure(mode)

        figure('Position', [0 0 700 875]);
        
        plotTitles = {'Hit Rate' 'Mean Energy' 'Energy Variance'};
        metricTypes = {'hitRate' 'meanEnergy' 'energyVariance'}; 
        metricAreas = {'black' 'maskedSmear' 'virtualSmear' 'targetStar' 'background'};
        plotYLabels = {'black' 'masked' 'virtual' 'target' 'bkgd'};
        
        for i = 1 : length(metricAreas)
            for j = 1 : length(metricTypes)
                plotNumber = j + (i-1)*length(metricTypes);
                plotTitle = '';
                if (i == 1)
                    plotTitle = plotTitles{j};
                end
                plotYLabel = '';
                if (j == 1)
                    plotYLabel = plotYLabels{i};
                end
                create_cosmic_ray_metrics_subplot(mode, ...
                    length(metricAreas), length(metricTypes), plotNumber, ...
                    metricAreas{i}, metricTypes{j}, plotTitle, plotYLabel);
            end
        end
        
        name = ['CRMetric' mode];
        basename = pmd_get_plot_filename(name, ccdModule, ccdOutput, reportDate);
        saveas(gcf, fullfile(sourceDirectory, basename));
        close(gcf);
        
        report_add_figure(reportDir, fid, name, sourceDirectory, basename);
    end

    function create_cosmic_ray_metrics_subplot(mode, nRows, nCols, plotNumber, ...
            metricArea, metricType, plotTitle, plotYLabel)
        
        subplot(nRows, nCols, plotNumber);
        if (strcmp(mode, TRACK))
            pmd_plot_cosmic_ray_metrics(pmdInputStruct.inputTsData, pmdTempStruct, ...
                pmdInputStruct.pmdModuleParameters, ...
                pmdInputStruct.cadenceTimes.midTimestamps, ...
                pmdInputStruct.cadenceTimes.gapIndicators, ...
                metricArea, metricType);
        else
            pmd_track_trend_cosmic_ray_metrics(pmdInputStruct.inputTsData, ...
                pmdOutputStruct, pmdTempStruct, ...
                pmdInputStruct.pmdModuleParameters, ...
                pmdInputStruct.cadenceTimes.midTimestamps, ...
                pmdInputStruct.cadenceTimes.gapIndicators, ...
                ccdModule, ccdOutput, metricArea, metricType, 'dmy') ;
        end
        title(plotTitle);
        xlabel('');
        ylabel(plotYLabel);
        legend('off');
        % report_adjust_plot_height(0.025);
    end

    function create_cdpp_metrics_figure(mode, name, timeString)

        figure('Position', [0 0 600 600]);
        
        titles = {'Measured' 'Expected' 'Ratio'};
        plotTypes = {'cdppMeasured' 'cdppExpected' 'cdppRatio'};

        if (strfind(name, '9to11'))
            magnitudes = {'mag9' 'mag10' 'mag11'};
        else
            magnitudes = {'mag12' 'mag13' 'mag14' 'mag15'};
        end

        for i = 1 : length(magnitudes)
            for j = 1 : length(plotTypes)
                create_cdpp_metrics_subplot(mode, timeString, titles, ...
                    i, magnitudes, j, plotTypes);
            end
        end

        if (strcmp(mode, TRACK))
            name = [name mode];
        else
            % TODO Ask around and see if cdpp12to15Trending would be OK so
            % that we can simply append the mode to the name below
            name = [name mode(1:5)];
        end

        name = [name '-' timeString];
        basename = pmd_get_plot_filename(name, ccdModule, ccdOutput, reportDate);
        saveas(gcf, fullfile(sourceDirectory, basename));
        close(gcf);
        
        report_add_figure(reportDir, fid, name, sourceDirectory, basename);
    end

    function create_cdpp_metrics_subplot(mode, timeString, titles, row, magnitudes, column, plotTypes)
        
        plotNumber = column + (row-1)*length(plotTypes);
        
        subplot(length(magnitudes), length(plotTypes), plotNumber);
        
        if (strcmp(mode, TRACK))
            pmd_plot_cdpp_metrics(pmdOutputStruct.outputTsData, pmdTempStruct, ...
                pmdInputStruct.pmdModuleParameters, ...
                pmdInputStruct.cadenceTimes.midTimestamps, ...
                pmdInputStruct.cadenceTimes.gapIndicators, ...
                plotTypes{column}, magnitudes{row}, timeString);
        else
            pmd_track_trend_cdpp_metrics(pmdOutputStruct.outputTsData, ...
                pmdOutputStruct, pmdTempStruct, ...
                pmdInputStruct.pmdModuleParameters, ...
                pmdInputStruct.cadenceTimes.midTimestamps, ...
                pmdInputStruct.cadenceTimes.gapIndicators, ...
                ccdModule, ccdOutput, plotTypes{column}, ...
                magnitudes{row}, timeString, 'dummy');
        end

        if (row == 1)
            title(titles{column});
        else
            title('');
        end
        xlabel('');
        if (column == 1) 
            ylabel(magnitudes{row});
        else
            ylabel('');
        end
        legend('off');
        % report_adjust_plot_height(0.025);
    end

%% * Generate tables of bounds breaking information.
    function generate_bounds_breakers()
        [table, summaryTable] = pmd_get_table_of_anomalies(pmdOutputStruct.report, 10);
        
        % Set startRow to 2 to skip heading.
        report_add_table(reportDir, ANOMALY_TABLE, table, 2);
        report_add_table(reportDir, ANOMALY_SUMMARY_TABLE, summaryTable, 2);
    end

%% * Generate metric trending.
    function generate_metric_trending()

        create_general_metrics_figure(TREND);
        create_lde_undershoot_and_2d_black_figure(TREND);
        create_cosmic_ray_metrics_figure(TREND);
        create_cdpp_metrics_figure(TREND, CDPP9TO11, 'threeHour');
        create_cdpp_metrics_figure(TREND, CDPP12TO15, 'threeHour');
        create_cdpp_metrics_figure(TREND, CDPP9TO11, 'sixHour');
        create_cdpp_metrics_figure(TREND, CDPP12TO15, 'sixHour');
        create_cdpp_metrics_figure(TREND, CDPP9TO11, 'twelveHour');
        create_cdpp_metrics_figure(TREND, CDPP12TO15, 'twelveHour');
    end
end
