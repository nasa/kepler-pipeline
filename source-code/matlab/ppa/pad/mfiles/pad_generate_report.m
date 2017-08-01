%% pad_generate_report
%
% function reportFilename = pad_generate_report(...
%    padInputStruct, padOutputStruct)
%
% Generates the PMD report.
%
%% INPUTS
% * *padInputStruct*: the input struct
% * *padOutputStruct*: the output struct
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

function reportFilename = pad_generate_report(...
    padInputStruct, padOutputStruct, sourceDirectory)

if (nargin ~= 2 && nargin ~= 3)
    disp('Usage: pad_generate_report(padInputStruct, padOutputStruct [, sourceDirectory])');
    reportFilename = '';
    return;
end
if (~exist('sourceDirectory', 'var'))
    sourceDirectory = '';
end

CSCI = 'pad';

REPORT_ALIASES = 'report-values.sty';
MOTION_AVAILABILITY = 'motion-availability';
DELTA_REPORT = '%s-delta-report';
DELTA_ALERTS = '%s-delta-alerts';

reportDate = now;
[startMjd, endMjd] = uowMjds(padInputStruct.cadenceTimes);
startUtc = mjd_to_utc(startMjd, 31);
endUtc = mjd_to_utc(endMjd, 31);
reportDateString = local_time_to_utc(reportDate, 'yyyymmdd');
reportDir = [CSCI '-' reportDateString(1:8) 'Z'];

gapIndicators = padOutputStruct.attitudeSolution.gapIndicators;
cadenceVector = padInputStruct.cadenceTimes.midTimestamps;

% Copy static files and rename pad-report.tex as required.
report_copy_static_files(CSCI, reportDir);
movefile(fullfile(reportDir, 'pad-report.tex'), ...
    fullfile(reportDir, [reportDir '.tex']));

% Generate dynamic files and data.
fid = report_open_latex_file(reportDir, REPORT_ALIASES);

generate_summary();
generate_inputs();
generate_configuration();
generate_motion_availability();
generate_delta_attitude();
generate_centroid_positions();
generate_attitude_solution();

xclose(fid, REPORT_ALIASES);

% Tell module interface to scoop up entire directory.
reportFilename = reportDir;

%% * Generate table of general information.
    function generate_summary()

        data = {'generated' local_time_to_utc(reportDate, 31); ...
            'pipelineModule' 'ppa'};
        report_add_static_table(fid, data);
    end

%% * Generate table of inputs.
    function generate_inputs()

        data = {'nCadences' length(padInputStruct.cadenceTimes.midTimestamps); ...
            'nGappedCadences' length(find(padInputStruct.cadenceTimes.gapIndicators==1)); ...
            'startMjd' startMjd; ...
            'endMjd' endMjd; ...
            'startUtc' startUtc; ...
            'endUtc' endUtc; ...
            'startCadence' padInputStruct.cadenceTimes.cadenceNumbers(1); ...
            'endCadence' padInputStruct.cadenceTimes.cadenceNumbers(end)};
        report_add_static_table(fid, data);
    end

%% Generate table module parameters.
    function generate_configuration()
        padConfiguration = padInputStruct.padModuleParameters;

        data = { ...
            'gridRowStart' padConfiguration.gridRowStart; ...
            'gridRowEnd' padConfiguration.gridRowEnd; ...
            'gridColStart' padConfiguration.gridColStart; ...
            'gridColEnd' padConfiguration.gridColEnd; ...
            'horizonTime' padConfiguration.horizonTime; ...
            'trendFitTime' padConfiguration.trendFitTime; ...
            'alertTime' padConfiguration.alertTime; ...
            'initialAverageSampleCount' padConfiguration.initialAverageSampleCount; ...
            'minTrendFitSampleCount' padConfiguration.minTrendFitSampleCount; ...
            'adaptiveBoundsXFactorForOutlier' padConfiguration.adaptiveBoundsXFactorForOutlier; ...
            'deltaRaAdaptiveXFactor' padConfiguration.deltaRaAdaptiveXFactor; ...
            'deltaDecAdaptiveXFactor' padConfiguration.deltaDecAdaptiveXFactor; ...
            'deltaRollAdaptiveXFactor' padConfiguration.deltaRollAdaptiveXFactor; ...
            'deltaRaSmoothingFactor' padConfiguration.deltaRaSmoothingFactor; ...
            'deltaRaFixedLowerBound' padConfiguration.deltaRaFixedLowerBound; ...
            'deltaRaFixedUpperBound' padConfiguration.deltaRaFixedUpperBound; ...
            'deltaDecSmoothingFactor' padConfiguration.deltaDecSmoothingFactor; ...
            'deltaDecFixedLowerBound' padConfiguration.deltaDecFixedLowerBound; ...
            'deltaDecFixedUpperBound' padConfiguration.deltaDecFixedUpperBound; ...
            'deltaRollSmoothingFactor' padConfiguration.deltaRollSmoothingFactor; ...
            'deltaRollFixedLowerBound' padConfiguration.deltaRollFixedLowerBound; ...
            'deltaRollFixedUpperBound' padConfiguration.deltaRollFixedUpperBound; ...
            'debugLevel' padConfiguration.debugLevel; ...
            'plottingEnabled' padConfiguration.plottingEnabled};
        report_add_static_table(fid, data);
    end

%% * Generate table of motion availability information.

    function generate_motion_availability()
                
        motionAvailability = cell(length(padInputStruct.motionBlobs), 5);
        for i = 1:length(padInputStruct.motionBlobs)
    
            [module output] = convert_to_module_output(i);
            motionAvailability{i,1} = module;
            motionAvailability{i,2} = output;
            motionAvailability{i,3} = i;

            if any(padInputStruct.motionBlobs(i).gapIndicators)
                motionAvailability{i,4} = 'X';
            end
    
            if ~isempty(padInputStruct.motionBlobs(i).blobFilenames)
                motionAvailability{i,5} = 'X';
            end
    
        end
        
        report_add_table(reportDir, MOTION_AVAILABILITY, ...
            motionAvailability);
    end

%% * Generate delta attitude.
    function generate_delta_attitude()
        
        report_add_figure(reportDir, fid, 'boundCrossingsAlert', ...
            sourceDirectory, 'pad_track_and_trend_bound_crossings_alert');
        report_add_figure(reportDir, fid, 'boundCrossingsTimeSeries', ...
            sourceDirectory, 'pad_track_and_trend_bound_crossings_time_series');

        create_delta_report(reportDir, padOutputStruct.report.deltaRa, 'ra');
        report_add_figure(reportDir, fid, 'attitudeDeltaRa', ...
            sourceDirectory, 'pad_track_and_trend_reconstructed_attitude_delta_ra');
        create_delta_alerts(reportDir, padOutputStruct.report.deltaRa.alerts, 'ra');

        create_delta_report(reportDir, padOutputStruct.report.deltaDec, 'dec');
        report_add_figure(reportDir, fid, 'attitudeDeltaDec', ...
            sourceDirectory, 'pad_track_and_trend_reconstructed_attitude_delta_dec');
        create_delta_alerts(reportDir, padOutputStruct.report.deltaDec.alerts, 'dec');

        create_delta_report(reportDir, padOutputStruct.report.deltaRoll, 'roll');
        report_add_figure(reportDir, fid, 'attitudeDeltaRoll', ...
            sourceDirectory, 'pad_track_and_trend_reconstructed_attitude_delta_roll');
        create_delta_alerts(reportDir, padOutputStruct.report.deltaRoll.alerts, 'roll');
    end

    function create_delta_report(reportDir, report, name)

        data = { ...
            'Time' report.time; ...
            'Value' sprintf('%1.4e', report.value); ...
            'Mean Value' sprintf('%1.4e', report.meanValue); ...
            'Uncertainty' sprintf('%1.4e', report.uncertainty); ...
            'Adaptive Bounds X Factor' report.adaptiveBoundsXFactor; ...
            'Track Alert Level' report.trackAlertLevel; ...
            'Trend Alert Level' report.trendAlertLevel };
        report_add_table(reportDir, sprintf(DELTA_REPORT, name), data);
    end

    function create_delta_alerts(reportDir, alerts, name)

        nAlerts = length(alerts);
        data = cell(nAlerts, 3);
        for iAlert = 1:nAlerts
            data(iAlert,:) = { num2str(alerts(iAlert).time), ...
                alerts(iAlert).severity, alerts(iAlert).message };
        end;
        report_add_table(reportDir, sprintf(DELTA_ALERTS, name), data);
    end

%% * Generate centroid positions.
    function generate_centroid_positions()
        
        figureNames = [];
        for i = 1:5
            basename = ['pad_centroids_from_nominal_attitude_and_attitude_solution_' num2str(i)];
            if (exist(fullfile(sourceDirectory, [basename '.fig']), 'file'))
                if (~isempty(figureNames))
                    figureNames = [figureNames ', ']; %#ok<AGROW>
                end
                figureNames = [figureNames basename]; %#ok<AGROW>
                report_add_figure(reportDir, fid, basename, sourceDirectory, basename);
            end
            basename = ['pad_centroids_from_attitude_solution_and_motion_poly_' num2str(i)];
            if (exist(fullfile(sourceDirectory, [basename '.fig']), 'file'))
                if (~isempty(figureNames))
                    figureNames = [figureNames ', ']; %#ok<AGROW>
                end
                figureNames = [figureNames basename]; %#ok<AGROW>
                report_add_figure(reportDir, fid, basename, sourceDirectory, basename);
            end
        end
        report_add_string(fid, 'centroidFigures', figureNames, false);
    end


%% * Generate attitude solution.
    function generate_attitude_solution()
        generate_attitude_solution_ra_dec_roll();
        generate_attitude_solution_covariance('11', '22', '33', ...
            '11_22_33', 'covarianceDiagonal');
        generate_attitude_solution_covariance('12', '13', '23', ...
            '12_13_23', 'covarianceOffDiagonal');
        generate_attitude_solution_focal_plane_residual();
    end

    function generate_attitude_solution_ra_dec_roll()

        figure(1);

        subplot(3,1,1);
        plot(cadenceVector(~gapIndicators), ...
            padOutputStruct.attitudeSolution.ra(~gapIndicators), 'o');
        ylabel('Ra (degrees)');
        set(gca, 'xticklabel', '');
        grid on;

        subplot(3,1,2);
        plot(cadenceVector(~gapIndicators), ...
            padOutputStruct.attitudeSolution.dec(~gapIndicators), 'o');
        ylabel('Dec (degrees)');
        set(gca, 'xticklabel', '');
        grid on;

        subplot(3,1,3);
        plot(cadenceVector(~gapIndicators), ...
            padOutputStruct.attitudeSolution.roll(~gapIndicators),'o');
        ylabel('Roll (degrees)');
        xlabel('Mid MJD Time');
        ticks = get(gca, 'xtick');
        labels = num2str(ticks(:));
        set(gca, 'xticklabel', labels);
        grid on;

        format_graphics_for_report(1, 1.0, 0.85);
        saveas(1, 'pad_attitude_solution_ra_dec_roll.fig');
        close(1);
        
        report_add_figure(reportDir, fid, 'attitudeRaDecRoll', ...
            sourceDirectory, 'pad_attitude_solution_ra_dec_roll');
        
    end

    function generate_attitude_solution_covariance(...
            covariance1, covariance2, covariance3, fig, name)
        
        figure(1);
        
        covarianceMatrix1 = eval(...
            ['padOutputStruct.attitudeSolution.covarianceMatrix' covariance1]);
        covarianceMatrix2 = eval(...
            ['padOutputStruct.attitudeSolution.covarianceMatrix' covariance2]);
        covarianceMatrix3 = eval(...
            ['padOutputStruct.attitudeSolution.covarianceMatrix' covariance3]);

        subplot(3,1,1);
        plot(cadenceVector(~gapIndicators), covarianceMatrix1(~gapIndicators), 'o');
        ylabel({['Covariance Matrix ' covariance1], '(degrees^2)'});
        set(gca, 'xticklabel', '');
        grid on;

        subplot(3,1,2);
        plot(cadenceVector(~gapIndicators), covarianceMatrix2(~gapIndicators), 'o');
        ylabel({['Covariance Matrix ' covariance2], '(degrees^2)'});
        set(gca, 'xticklabel', '');
        grid on;

        subplot(3,1,3);
        plot(cadenceVector(~gapIndicators), covarianceMatrix3(~gapIndicators), 'o');
        ylabel({['Covariance Matrix ' covariance3], '(degrees^2)'});
        xlabel('Mid MJD Time');
        ticks = get(gca, 'xtick');
        labels = num2str(ticks(:));
        set(gca, 'xticklabel', labels);
        grid on;

        format_graphics_for_report(1, 1.0, 0.85);
        covarianceFig = ['pad_attitude_solution_covariance_' fig];
        saveas(1, [covarianceFig '.fig']);
        close(1);

        report_add_figure(reportDir, fid, name, sourceDirectory, covarianceFig);
    end

    function generate_attitude_solution_focal_plane_residual()
        
        figure(1);
        
        plot(cadenceVector(~gapIndicators), ...
            padOutputStruct.attitudeSolution.maxAttitudeFocalPlaneResidual(~gapIndicators), ...
            'o');
        ylabel({'Max Attitude', 'FocalPlaneResidual', '(pixels)'});
        xlabel('Mid MJD Time');
        ticks = get(gca, 'xtick');
        labels = num2str(ticks(:));
        set(gca, 'xticklabel', labels);
        grid on;
        
        format_graphics_for_report(1,  1.0, 0.85);
        saveas(1, 'pad_attitude_solution_focal_plane_residual.fig');
        close(1);
        
        report_add_figure(reportDir, fid, 'focalPlaneResidual', ...
            sourceDirectory, 'pad_attitude_solution_focal_plane_residual');
    end

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

end
