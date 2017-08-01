%% pdq_generate_channel_report
%
% function reportFilename = pdq_generate_channel_report(pdqInputStruct, channel, sourceDirectory)
%
% Generates the PDQ reports.
%
%% INPUTS
% * *pdqInputStruct*: the input struct
% * *channel*: the channel for which a report should be generated
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

function reportFilename = pdq_generate_channel_report(pdqInputStruct, channel, sourceDirectory)

if (nargin ~= 2 && nargin ~= 3)
    disp('Usage: pdq_generate_report(pdqInputStruct, channel [, sourceDirectory])');
    return;
end
if (~exist('sourceDirectory', 'var'))
    sourceDirectory = '';
end

CSCI = 'pdq';

REPORT_ALIASES = 'report-values.sty';
TIMESTAMPS_PROCESSED = 'timestamps-processed.tex';

DEFAULT_WIDTH = 1.0;
DEFAULT_HEIGHT = 0.85;
HALF_HEIGHT = DEFAULT_HEIGHT/2;
HALF_HEIGHT_WITH_CAPTIONS = HALF_HEIGHT - 0.04;

[ccdModule, ccdOutput]  = convert_to_module_output(channel);
channelSuffix = sprintf('module_%d_output_%d_modout_%d', ccdModule, ccdOutput, channel);

reportDate = now;
% TODO Replace 30 with 'yyyymmdd'.
reportDateString = local_time_to_utc(reportDate, 30);
reportDir = sprintf('%s-%02d-%d-%sZ', CSCI, ccdModule, ccdOutput, reportDateString(1:8));

% Copy static files and rename pdq-channel-report.tex as required.
report_copy_static_files(CSCI, reportDir);
movefile(fullfile(reportDir, 'pdq-channel-report.tex'), ...
    fullfile(reportDir, [reportDir '.tex']));

% Generate dynamic files and data.
fid = report_open_latex_file(reportDir, REPORT_ALIASES);

report_add_string(fid, 'ccdModule', num2str(ccdModule));
report_add_string(fid, 'ccdOutput', num2str(ccdOutput));
report_add_string(fid, 'channelSuffix', channelSuffix);

% Main portion of report.
generate_summary();
generate_track_and_trend();
generate_stellar_pixels();

xclose(fid, REPORT_ALIASES);

% Tell module interface to scoop up entire directory.
reportFilename = reportDir;

%% Generate tables used by channel-summary.tex.
%
    function generate_summary()
        
        data = {'generated' local_time_to_utc(reportDate, 0); ...
            'pipelineInstanceId' pdqInputStruct.pipelineInstanceId};
        report_add_static_table(fid, data);
        
        table = pdq_report_timestamps_processed(pdqInputStruct.pdqTimestampSeries);
        report_add_table(reportDir, TIMESTAMPS_PROCESSED, table);
        
    end

%% Generate figures used by channel-track-and-trend.tex.
    function generate_track_and_trend()
        WIDTH = 1.0;
        
        add_figure('trackingTrendingSummary', channelSuffix, 'tracking_trending_summary_*.fig', WIDTH, DEFAULT_HEIGHT);
        add_figure('trackingTrendingBlackLevel', channelSuffix, 'tracking_trending_black_level_*.fig', WIDTH, HALF_HEIGHT);
        add_figure('trackingTrendingSmearLevel', channelSuffix, 'tracking_trending_smear_level_*.fig', WIDTH, HALF_HEIGHT);
        add_figure('trackingTrendingDarkCurrent', channelSuffix, 'tracking_trending_dark_current_*.fig', WIDTH, HALF_HEIGHT);
        add_figure('trackingTrendingBackgroundLevel', channelSuffix, 'tracking_trending_background_level_*.fig', WIDTH, HALF_HEIGHT);
        add_figure('trackingTrendingDynamicRange', channelSuffix, 'tracking_trending_dynamic_range_*.fig', WIDTH, HALF_HEIGHT);
        add_figure('trackingTrendingMeanFlux', channelSuffix, 'tracking_trending_mean_flux_*.fig', WIDTH, HALF_HEIGHT);
        add_figure('trackingTrendingCentroidsMeanRow', channelSuffix, 'tracking_trending_centroids_mean_row_*.fig', WIDTH, HALF_HEIGHT);
        add_figure('trackingTrendingCentroidsMeanColumn', channelSuffix, 'tracking_trending_centroids_mean_column_*.fig', WIDTH, HALF_HEIGHT);
        add_figure('trackingTrendingEncircledEnergy', channelSuffix, 'tracking_trending_encircled_energy_*.fig', WIDTH, HALF_HEIGHT);
        add_figure('trackingTrendingPlateScale', channelSuffix, 'tracking_trending_plate_scale_*.fig', WIDTH, HALF_HEIGHT);
    end

%% Generate figures used by channel-stellar-pixels.tex.
    function generate_stellar_pixels()
        add_figure('imagePixels', channelSuffix, 'image_pixels_on_*.fig', DEFAULT_WIDTH, 0.8);
        add_figure('calibratedVsRawTargetPixels', channelSuffix, 'mosaic_of_calibrated_vs_raw_target_pixels_*.fig', DEFAULT_WIDTH, HALF_HEIGHT);
        add_figure('falseColorImageStellarPixelsCentroids', channelSuffix, 'false_color_image_stellar_pixels_centroids_*.fig', DEFAULT_WIDTH, DEFAULT_HEIGHT);
        add_figure('meshPlotStellarPixels', channelSuffix, 'mesh_plot_stellar_pixels_*.fig', DEFAULT_WIDTH, HALF_HEIGHT_WITH_CAPTIONS);
        add_figure('pixels', channelSuffix, 'pixels_on_*.fig', DEFAULT_WIDTH, HALF_HEIGHT_WITH_CAPTIONS);
        add_figure('rowViewOfTargetBkgdPixels', channelSuffix, 'row_view_of_target_pixels_bkgd_pixels_for_*.fig', DEFAULT_WIDTH, HALF_HEIGHT_WITH_CAPTIONS);
        add_figure('columnViewOfTargetBkgdPixels', channelSuffix, 'column_view_of_target_pixels_bkgd_pixels_for_*.fig', DEFAULT_WIDTH, HALF_HEIGHT_WITH_CAPTIONS);
        add_figure('undershootCorrection', channelSuffix, 'undershoot_correction_*.fig', DEFAULT_WIDTH, HALF_HEIGHT_WITH_CAPTIONS);
        add_figure('targetPixelsAfterDifferentStagesOfCalibration', channelSuffix, 'target_pixels_after_different_stages_of_calibration_for_*.fig', DEFAULT_WIDTH, HALF_HEIGHT_WITH_CAPTIONS);
        add_figure('encircledEnergyPixelFlux', channelSuffix, 'encircled_energy_pixel_flux_*.fig', DEFAULT_WIDTH, DEFAULT_HEIGHT);
        add_figure('encircledEnergyCumulativeFlux', channelSuffix, 'encircled_energy_cumulative_flux_*.fig', DEFAULT_WIDTH, DEFAULT_HEIGHT);
    end

%% Define common functions.

    function basename = add_figure(name, directory, pattern, widthPercent, heightPercent)
        if (~exist('widthPercent', 'var'))
            widthPercent = DEFAULT_WIDTH;
        end
        if (~exist('heightPercent', 'var'))
            heightPercent = DEFAULT_WIDTH; % allow for captions and chapter titles
        end
        
        if (~exist('pattern', 'var'))
            pattern = '';
        end
        basename = pdq_report_add_figure(reportDir, fid, name, ...
            sourceDirectory, directory, pattern, widthPercent, heightPercent);
    end

end
