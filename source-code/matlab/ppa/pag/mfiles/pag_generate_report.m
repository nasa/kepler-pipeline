%% pag_generate_report
%
% function reportFilename = pag_generate_report(...
%    pagScienceObject, pagInputStruct, pagOutputStruct)
%
% Generates the PAG report.
%
%% INPUTS
% * *pagScienceObject*: the class instance for pagScienceClass
% * *pagInputStruct*: the input struct
% * *pagOutputStruct*: the output struct
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

function reportFilename = pag_generate_report(...
    pagScienceObject, pagInputStruct, pagOutputStruct, sourceDirectory)

if (nargin ~= 2 && nargin ~= 3)
    disp('Usage: pag_generate_report(pagScienceObject, pagInputStruct, pagOutputStruct [, sourceDirectory])');
    reportFilename = '';
    return;
end
if (~exist('sourceDirectory', 'var'))
    sourceDirectory = '';
end

CSCI = 'pag';

REPORT_ALIASES = 'report-values.sty';

reportDate = now;
startMjd = min(pagInputStruct.cadenceTimes.midTimestamps);
endMjd = max(pagInputStruct.cadenceTimes.midTimestamps);
startUtc = mjd_to_utc(startMjd, 31);
endUtc = mjd_to_utc(endMjd, 31);
reportDateString = local_time_to_utc(reportDate, 30);
reportDir = [CSCI '-' reportDateString(1:8) 'Z'];

% Copy static files and rename pag-report.tex as required.
report_copy_static_files(CSCI, reportDir);
movefile(fullfile(reportDir, 'pag-report.tex'), ...
    fullfile(reportDir, [reportDir '.tex']));

% Generate dynamic files and data.
fid = report_open_latex_file(reportDir, REPORT_ALIASES);

generate_summary();
generate_inputs();
generate_metric_tracking();
generate_metric_trending();
generate_compression_efficiency();
generate_bounds_breaking_events();

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

        data = {'nCadences' length(pagInputStruct.cadenceTimes.midTimestamps); ...
            'nGappedCadences' length(find(pagInputStruct.cadenceTimes.gapIndicators==1)); ...
            'startMjd' startMjd; ...
            'endMjd' endMjd; ...
            'startUtc' startUtc; ...
            'endUtc' endUtc; ...
            'startCadence' min(pagInputStruct.cadenceTimes.cadenceNumbers); ...
            'endCadence' max(pagInputStruct.cadenceTimes.cadenceNumbers)};
        report_add_static_table(fid, data);
    end

%% * Generate tracking and trending metrics.
    function generate_metric_tracking()
        alertType = 'track';
        
        fprintf('\nPAG: generate metric tracking figures...\n');
        
        figure(10)
        
        
        generate_metrics_figure(alertType, 'metricStates', ...
            'generalMetricTrack', 'generalMetricTrack');
        
        generate_metrics_figure(alertType, 'metricArrayStates', ...
            'lde+2DBlackTrack', 'ldeTwoDBlackTrack');
        
        generate_metrics_figure(alertType, 'cosmicRayStatesPage1', ...
            'CRMasked+BlackTrack', 'crMaskedAndBlackTrack');
        
        generate_metrics_figure(alertType, 'cosmicRayStatesPage2', ...
            'CRTarget+BkgdTrack', 'crTargetAndBkgdTrack');
        
        generate_metrics_figure(alertType, 'cdpp3HourStatesPage1', ...
            'CDPP3HrMag09to11Track', 'threeHrMagNineToElevenTrack');
        
        generate_metrics_figure(alertType, 'cdpp3HourStatesPage2', ...
            'CDPP3HrMag12to15Track', 'threeHrMagTwelveToFifteenTrack');
        
        generate_metrics_figure(alertType, 'cdpp6HourStatesPage1', ...
            'CDPP6HrMag09to11Track', 'sixHrMagNineToElevenTrack');
        
        generate_metrics_figure(alertType, 'cdpp6HourStatesPage2', ...
            'CDPP6HrMag12to15Track', 'sixHrMagTwelveToFifteenTrack');
        
        generate_metrics_figure(alertType, 'cdpp12HourStatesPage1', ...
            'CDPP12HrMag09to11Track', 'twelveHrMagNineToElevenTrack');
        
        generate_metrics_figure(alertType, 'cdpp12HourStatesPage2', ...
            'CDPP12HrMag12to15Track', 'twelveHrMagTwelveToFifteenTrack');
        
        close(10);
    end

    function generate_metric_trending()
        alertType = 'trend';
        
        fprintf('\nPAG: generate metric trending figures...\n');

        figure(10);
        
        generate_metrics_figure(alertType, 'metricStates', ...
            'generalMetricTrend', 'generalMetricTrend');
        
        generate_metrics_figure(alertType, 'metricArrayStates', ...
            'lde+2DBlackTrend', 'ldeTwoDBlackTrend');
        
        generate_metrics_figure(alertType, 'cosmicRayStatesPage1', ...
            'CRMasked+BlackTrend', 'crMaskedAndBlackTrend');
        
        generate_metrics_figure(alertType, 'cosmicRayStatesPage2', ...
            'CRTarget+BkgdTrend', 'crTargetAndBkgdTrend');
        
        generate_metrics_figure(alertType, 'cdpp3HourStatesPage1', ...
            'CDPP3HrMag09to11Trend', 'threeHrMagNineToElevenTrend');
        
        generate_metrics_figure(alertType, 'cdpp3HourStatesPage2', ...
            'CDPP3HrMag12to15Trend', 'threeHrMagTwelveToFifteenTrend');
        
        generate_metrics_figure(alertType, 'cdpp6HourStatesPage1', ...
            'CDPP6HrMag09to11Trend', 'sixHrMagNineToElevenTrend');
        
        generate_metrics_figure(alertType, 'cdpp6HourStatesPage2', ...
            'CDPP6HrMag12to15Trend', 'sixHrMagTwelveToFifteenTrend');
        
        generate_metrics_figure(alertType, 'cdpp12HourStatesPage1', ...
            'CDPP12HrMag09to11Trend', 'twelveHrMagNineToElevenTrend');
        
        generate_metrics_figure(alertType, 'cdpp12HourStatesPage2', ...
            'CDPP12HrMag12to15Trend', 'twelveHrMagTwelveToFifteenTrend');
        
        close(10);

    end

    function generate_metrics_figure(alertType, reportType, name, varname)
        
        clf(gcf);
        pag_generate_metrics_reports(pagScienceObject, pagOutputStruct, ...
            alertType, reportType);
        pag_report_add_figure(gcf, name, varname);

    end

    function generate_compression_efficiency()
        fprintf('\nPAG: add theoreticalCompressionEfficiency figure...\n');
        pag_report_add_figure(1, 'theoreticalCompressionEfficiency', ...
            'theoreticalCompressionEfficiency');
        close(1);
        fprintf('\nPAG: add achievedCompressionEfficiency figure...\n');
        pag_report_add_figure(2, 'achievedCompressionEfficiency', ...
            'achievedCompressionEfficiency');
        close(2);
    end

    function generate_bounds_breaking_events()
        fprintf('\nPAG: generate bounds breaking events table...\n');
        anomalyTable = pmd_get_table_of_anomalies( pagOutputStruct.report );
        data = anomalyTable(2:end,:);
        report_add_table(reportDir, 'bounds-breaking-events', data);
    end

    function pag_report_add_figure(handle, name, varname)
        figure(handle);
        basename = ['pag-' name '-' reportDateString];
        fprintf('\nPAG: format_graphics_for_report: %s...\n', basename);
        format_graphics_for_report(handle, 1.0, 0.75);
        saveas(handle, [basename '.fig']);
        fprintf('\nPAG: report_add_figure: %s...\n', basename);
        report_add_figure(reportDir, fid, varname, sourceDirectory, basename);
    end

end
