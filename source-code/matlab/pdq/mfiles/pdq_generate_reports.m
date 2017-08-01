%% pdq_generate_reports
%
% function reportFilename = pdq_generate_reports(pdqInputStruct, channelsProcessed)
%
% Generates the PDQ reports.
%
%% INPUTS
%        pdqInputStruct [struct]: the input struct
%  channelsProcessed [int array]: an array listing the channels that were
%                                 processed
%       sourceDirectory [string]: the name of the directory that contains the
%                                 inputs (optional, default '.')
%
%% OUTPUTS
%        reportFilename [string]: the name of the directory that contains
%                                 the report's artifacts
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

function reportFilename = pdq_generate_reports(...
    pdqInputStruct, channelsProcessed, sourceDirectory)

if (nargin ~= 2 && nargin ~= 3)
    disp('Usage: pdq_generate_reports(pdqInputStruct, channelsProcessed [, sourceDirectory])');
    return;
end
if (~exist('sourceDirectory', 'var'))
    sourceDirectory = '';
end

CSCI = 'pdq';
FOCAL_PLANE_DIR = 'focal_plane';

REPORT_ALIASES = 'report-values.sty';
TIMESTAMPS_PROCESSED = 'timestamps-processed.tex';
CCD_CHANNELS_PROCESSED = 'ccd-channels-processed.tex';
CCD_CHANNELS_NOT_PROCESSED = 'ccd-channels-not-processed.tex';

DEFAULT_WIDTH = 1.0;
DEFAULT_HEIGHT = 0.85;
HALF_HEIGHT = DEFAULT_HEIGHT/2;
METRIC_HEIGHT = DEFAULT_HEIGHT * 0.7;

reportDate = now;
% TODO Replace 30 with 'yyyymmdd'.
reportDateString = local_time_to_utc(reportDate, 30);
reportDir = [CSCI '-summary-' reportDateString(1:8) 'Z'];

% Separate the channels processed from channels failed to process.
channelsSucceeded = find(channelsProcessed);  % index of channels [1, 84]
channelsFailed = find(~channelsProcessed);  % index of channels [1, 84]

% Copy static files and rename pdq-report.tex as required.
report_copy_static_files(CSCI, reportDir);
movefile(fullfile(reportDir, 'pdq-report.tex'), ...
    fullfile(reportDir, [reportDir '.tex']));

% Generate dynamic files and data.
fid = report_open_latex_file(reportDir, REPORT_ALIASES);

% Main portion of report.
generate_summary();
generate_track_and_trend();
generate_centroid_bias_map();
generate_summary_metrics();
generate_delta_quaternion_table();

% Appendix
generate_configuration();
generate_reference_pixels_timestamps();
generate_reference_pixels_gap_summary();
generate_reference_pixels_summary()
generate_reference_pixels_mosaics();

xclose(fid, REPORT_ALIASES);

% Tell module interface to scoop up entire directory.
reportFilename = reportDir;


%% Generate tables used by summary.tex.
%
    function generate_summary()
        
        data = {'generated' local_time_to_utc(reportDate, 0); ...
            'pipelineInstanceId' pdqInputStruct.pipelineInstanceId};
        report_add_static_table(fid, data);
        
        table = pdq_report_timestamps_processed(pdqInputStruct.pdqTimestampSeries);
        report_add_table(reportDir, TIMESTAMPS_PROCESSED, table);
        
        data = {'spacecraftEphemerisFilename' pdqInputStruct.raDec2PixModel.spiceSpacecraftEphemerisFilename; ...
            'planetaryEphemerisFilename' pdqInputStruct.raDec2PixModel.planetaryEphemerisFilename; ...
            'leapSecondFilename' pdqInputStruct.raDec2PixModel.leapSecondFilename};
        report_add_static_table(fid, data);
        
        table = channels_processed(channelsFailed, 3);
        report_add_table(reportDir, CCD_CHANNELS_NOT_PROCESSED, table);
        
        table = channels_processed(channelsSucceeded, 3);
        report_add_table(reportDir, CCD_CHANNELS_PROCESSED, table);
    end

    function table = channels_processed(channels, nColumns)
        if (nargin < 2)
            nColumns = 1;
        end
        
        nChannels = length(channels);
        
        if (nChannels == 0)
            table = {'None'};
            return;
        end
        
        % One "column" contains N_DATA_ELEMENTS columns.
        N_DATA_ELEMENTS = 3; % CCD module, output, and channel
        nRows = ceil(nChannels/nColumns);
        table = cell(nRows, nColumns*N_DATA_ELEMENTS);
        for row = 1 : nRows
            rowData = cell(1, nColumns*N_DATA_ELEMENTS);
            for column = 1 : nColumns
                index = (column-1)*nRows + row;
                if (index > nChannels)
                    break;
                end
                channel = channels(index);
                [ccdModule, ccdOutput]  = convert_to_module_output(channel);
                rowData((column-1)*N_DATA_ELEMENTS+1) = {num2str(ccdModule, '%d')};
                rowData((column-1)*N_DATA_ELEMENTS+2) = {num2str(ccdOutput, '%d')};
                rowData((column-1)*N_DATA_ELEMENTS+3) = {num2str(channel, '%d')};
            end
            table(row, :) = rowData;
        end
    end

%% Generate figures used by track-and-trend.tex.
    function generate_track_and_trend()
        add_figure('pdq_bound_crossings_across_the_focal_plane', FOCAL_PLANE_DIR, '', DEFAULT_WIDTH, METRIC_HEIGHT);
        add_file('PDQ_Fixed_Bound_Crossings_Report.txt');
        add_file('PDQ_Adaptive_Bound_Crossings_Report.txt');
        add_figure('pdq_bound_crossing_predictions_across_the_focal_plane', FOCAL_PLANE_DIR, '', DEFAULT_WIDTH, METRIC_HEIGHT);
        add_file('PDQ_Fixed_Bound_Crossing_Prediction_Report.txt');
        add_figure('tracking_trending_delta_attitude_ra_across_the_focal_plane', FOCAL_PLANE_DIR, '', DEFAULT_WIDTH, HALF_HEIGHT);
        add_figure('tracking_trending_delta_attitude_dec_across_the_focal_plane', FOCAL_PLANE_DIR, '', DEFAULT_WIDTH, HALF_HEIGHT);
        add_figure('tracking_trending_delta_attitude_roll_across_the_focal_plane', FOCAL_PLANE_DIR, '', DEFAULT_WIDTH, HALF_HEIGHT);
        add_figure('tracking_trending_max_attitude_residual_across_the_focal_plane', FOCAL_PLANE_DIR, '', DEFAULT_WIDTH, HALF_HEIGHT);
    end

%% Generate figure used by centroid-bias-map.tex.
    function generate_centroid_bias_map()
        add_figure('centroidBiasMapByCadence', FOCAL_PLANE_DIR, 'centroid_bias_map_across_the_focal_plane_for_cadence_*.fig', DEFAULT_WIDTH, METRIC_HEIGHT);
    end

%% Generate figures used by summary-metrics.tex.
    function generate_summary_metrics()
        add_figure('meanBlackLevelVariation', FOCAL_PLANE_DIR, 'Mean_black_level_variation_over_the_focal_plane_in_ADU.fig', DEFAULT_WIDTH, METRIC_HEIGHT);
        add_figure('blackLevelMetricVariationByModout', FOCAL_PLANE_DIR, 'Black_level_metric_variation_across_the_focal_plane_over_*_modouts.fig', DEFAULT_WIDTH, METRIC_HEIGHT);
        add_figure('blackLevelMetricVariationByCadence', FOCAL_PLANE_DIR, 'Black_level_metric_variation_across_the_focal_plane_over_*_cadences.fig', DEFAULT_WIDTH, METRIC_HEIGHT);

        add_figure('meanSmearLevelVariation', FOCAL_PLANE_DIR, 'Mean_smear_level_variation_over_the_focal_plane_in_photoelectrons.fig', DEFAULT_WIDTH, METRIC_HEIGHT);
        add_figure('smearLevelMetricVariationByModout', FOCAL_PLANE_DIR, 'Smear_level_metric_variation_across_the_focal_plane_over_*_modouts.fig', DEFAULT_WIDTH, METRIC_HEIGHT);
        add_figure('smearLevelMetricVariationByCadence', FOCAL_PLANE_DIR, 'Smear_level_metric_variation_across_the_focal_plane_over_*_cadences.fig', DEFAULT_WIDTH, METRIC_HEIGHT);

        add_figure('meanDarkCurrentLevelVariation', FOCAL_PLANE_DIR, 'Mean_dark_current_level_variation_over_the_focal_plane_in_photoelectrons_per_sec_per_exposure.fig', DEFAULT_WIDTH, METRIC_HEIGHT);
        add_figure('darkCurrentMetricVariationByModout', FOCAL_PLANE_DIR, 'Dark_current_metric_variation_across_the_focal_plane_over_*_modouts.fig', DEFAULT_WIDTH, METRIC_HEIGHT);
        add_figure('darkCurrentMetricVariationByCadence', FOCAL_PLANE_DIR, 'Dark_current_metric_variation_across_the_focal_plane_over_*_cadences.fig', DEFAULT_WIDTH, METRIC_HEIGHT);

        add_figure('meanBackgroundLevelVariation', FOCAL_PLANE_DIR, 'Mean_background_level_variation_over_the_focal_plane_in_photoelectrons.fig', DEFAULT_WIDTH, METRIC_HEIGHT);
        add_figure('backgroundLevelMetricVariationByModout', FOCAL_PLANE_DIR, 'Background_level_metric_variation_across_the_focal_plane_over_*_modouts.fig', DEFAULT_WIDTH, METRIC_HEIGHT);
        add_figure('backgroundLevelMetricVariationByCadence', FOCAL_PLANE_DIR, 'Background_level_metric_variation_across_the_focal_plane_over_*_cadences.fig', DEFAULT_WIDTH, METRIC_HEIGHT);

        add_figure('meanDynamicRangeVariation', FOCAL_PLANE_DIR, 'Mean_dynamic_range_variation_over_the_focal_plane_in_ADU.fig', DEFAULT_WIDTH, METRIC_HEIGHT);
        add_figure('dynamicRangeMetricVariationByModout', FOCAL_PLANE_DIR, 'Dynamic_range_metric_variation_across_the_focal_plane_over_*_modouts.fig', DEFAULT_WIDTH, METRIC_HEIGHT);
        add_figure('dynamicRangeMetricVariationByCadence', FOCAL_PLANE_DIR, 'Dynamic_range_metric_variation_across_the_focal_plane_over_*_cadences.fig', DEFAULT_WIDTH, METRIC_HEIGHT);

        add_figure('meanBrightnessMetricVariation', FOCAL_PLANE_DIR, 'Mean_brightness_metric_variation_over_the_focal_plane_in_unitless_ratio.fig', DEFAULT_WIDTH, METRIC_HEIGHT);
        add_figure('brightnessMetricVariationByModout', FOCAL_PLANE_DIR, 'Brightness_metric_variation_across_the_focal_plane_over_*_modouts.fig', DEFAULT_WIDTH, METRIC_HEIGHT);
        add_figure('brightnessMetricVariationByCadence', FOCAL_PLANE_DIR, 'Brightness_metric_variation_across_the_focal_plane_over_*_cadences.fig', DEFAULT_WIDTH, METRIC_HEIGHT);

        add_figure('meanCentroidRowMetricVariation', FOCAL_PLANE_DIR, 'Mean_centroid_row_metric_variation_over_the_focal_plane_in_pixels.fig', DEFAULT_WIDTH, METRIC_HEIGHT);
        add_figure('centroidRowMetricVariationByModout', FOCAL_PLANE_DIR, 'Centroid_row_metric_variation_across_the_focal_plane_over_*_modouts.fig', DEFAULT_WIDTH, METRIC_HEIGHT);
        add_figure('centroidRowMetricVariationByCadence', FOCAL_PLANE_DIR, 'Centroid_row_metric_variation_across_the_focal_plane_over_*_cadences.fig', DEFAULT_WIDTH, METRIC_HEIGHT);

        add_figure('meanCentroidColumnMetricVariation', FOCAL_PLANE_DIR, 'Mean_centroid_column_metric_variation_over_the_focal_plane_in_pixels.fig', DEFAULT_WIDTH, METRIC_HEIGHT);
        add_figure('centroidColumnMetricVariationByModout', FOCAL_PLANE_DIR, 'Centroid_column_metric_variation_across_the_focal_plane_over_*_modouts.fig', DEFAULT_WIDTH, METRIC_HEIGHT);
        add_figure('centroidColumnMetricVariationByCadence', FOCAL_PLANE_DIR, 'Centroid_column_metric_variation_across_the_focal_plane_over_*_cadences.fig', DEFAULT_WIDTH, METRIC_HEIGHT);

        add_figure('meanEncircledEnergyVariation', FOCAL_PLANE_DIR, 'Mean_encircled_energy_variation_over_the_focal_plane_in_pixels.fig', DEFAULT_WIDTH, METRIC_HEIGHT);
        add_figure('encircledEnergyMetricVariationByModout', FOCAL_PLANE_DIR, 'Encircled_energy_metric_variation_across_the_focal_plane_over_*_modouts.fig', DEFAULT_WIDTH, METRIC_HEIGHT);
        add_figure('encircledEnergyMetricVariationByCadence', FOCAL_PLANE_DIR, 'Encircled_energy_metric_variation_across_the_focal_plane_over_*_cadences.fig', DEFAULT_WIDTH, METRIC_HEIGHT);
        
        add_figure('meanPlateScaleMetricVariation', FOCAL_PLANE_DIR, 'Mean_plate_scale_metric_variation_over_the_focal_plane.fig', DEFAULT_WIDTH, METRIC_HEIGHT);
        add_figure('plateScaleMetricVariationByModout', FOCAL_PLANE_DIR, 'Plate_scale_metric_variation_across_the_focal_plane_over_*_modouts.fig', DEFAULT_WIDTH, METRIC_HEIGHT);
        add_figure('plateScaleMetricVariationByCadence', FOCAL_PLANE_DIR, 'Plate_scale_metric_variation_across_the_focal_plane_over_*_cadences.fig', DEFAULT_WIDTH, METRIC_HEIGHT);
    end

%% Generate figures used by delta_quaternion_table.tex.
    function generate_delta_quaternion_table()
        add_file('PDQ_Quaternion_Report.txt');
    end

%% Generate table used by configuration.tex.
    function generate_configuration()
        pdqConfiguration = pdqInputStruct.pdqConfiguration;

        excludeCadences = '-';
        if (~isempty(pdqConfiguration.excludeCadences))
            excludeCadences = '';
            for i = 1:length(pdqConfiguration.excludeCadences)
                excludeCadences = appendCsvValue(...
                    excludeCadences, num2str(pdqConfiguration.excludeCadences(i)));
            end
        end
        
        table = { ...
            'maxBlackPolyOrder' pdqConfiguration.maxBlackPolyOrder; ...
            'eeFluxFraction' pdqConfiguration.eeFluxFraction; ...
            'maxFzeroIterations' pdqConfiguration.maxFzeroIterations; ...
            'encircledEnergyPolyOrderMax' pdqConfiguration.encircledEnergyPolyOrderMax; ...
            'sigmaGaussianRollOff' pdqConfiguration.sigmaGaussianRollOff; ...
            'immediateNeighborhoodRadiusInPixel' pdqConfiguration.immediateNeighborhoodRadiusInPixel; ...
            'madSigmaThresholdForBleedingColumns' pdqConfiguration.madSigmaThresholdForBleedingColumns; ...
            'haloAroundOptimalApertureInPixels' pdqConfiguration.haloAroundOptimalApertureInPixels; ...
            'sigmaForRejectingBadTargets' pdqConfiguration.sigmaForRejectingBadTargets; ...
            'madThresholdForCentroidOutliers' pdqConfiguration.madThresholdForCentroidOutliers; ...
            'horizonTime' pdqConfiguration.horizonTime; ...
            'minTrendFitSampleCount' pdqConfiguration.minTrendFitSampleCount; ...
            'exponentialSmoothingFactor' pdqConfiguration.exponentialSmoothingFactor; ...
            'adaptiveBoundsXFactor' pdqConfiguration.adaptiveBoundsXFactor; ...
            'trendFitTime' pdqConfiguration.trendFitTime; ...
            'backgroundLevelFixedLowerBound' pdqConfiguration.backgroundLevelFixedLowerBound; ...
            'backgroundLevelFixedUpperBound' pdqConfiguration.backgroundLevelFixedUpperBound; ...
            'blackLevelFixedLowerBound' pdqConfiguration.blackLevelFixedLowerBound; ...
            'blackLevelFixedUpperBound' pdqConfiguration.blackLevelFixedUpperBound; ...
            'centroidsMeanColFixedLowerBound' pdqConfiguration.centroidsMeanColFixedLowerBound; ...
            'centroidsMeanColFixedUpperBound' pdqConfiguration.centroidsMeanColFixedUpperBound; ...
            'centroidsMeanRowFixedLowerBound' pdqConfiguration.centroidsMeanColFixedLowerBound; ...
            'centroidsMeanRowFixedUpperBound' pdqConfiguration.centroidsMeanRowFixedUpperBound; ...
            'darkCurrentFixedLowerBound' pdqConfiguration.darkCurrentFixedLowerBound; ...
            'darkCurrentFixedUpperBound' pdqConfiguration.darkCurrentFixedUpperBound; ...
            'deltaAttitudeDecFixedLowerBound' pdqConfiguration.deltaAttitudeDecFixedLowerBound; ...
            'deltaAttitudeDecFixedUpperBound' pdqConfiguration.deltaAttitudeDecFixedUpperBound; ...
            'deltaAttitudeRaFixedLowerBound' pdqConfiguration.deltaAttitudeRaFixedLowerBound; ...
            'deltaAttitudeRaFixedUpperBound' pdqConfiguration.deltaAttitudeRaFixedUpperBound; ...
            'deltaAttitudeRollFixedLowerBound' pdqConfiguration.deltaAttitudeRollFixedLowerBound; ...
            'deltaAttitudeRollFixedUpperBound' pdqConfiguration.deltaAttitudeRollFixedUpperBound; ...
            'dynamicRangeFixedLowerBound' pdqConfiguration.dynamicRangeFixedLowerBound; ...
            'dynamicRangeFixedUpperBound' pdqConfiguration.dynamicRangeFixedUpperBound; ...
            'encircledEnergyFixedLowerBound' pdqConfiguration.encircledEnergyFixedLowerBound; ...
            'encircledEnergyFixedUpperBound' pdqConfiguration.encircledEnergyFixedUpperBound; ...
            'meanFluxFixedLowerBound' pdqConfiguration.meanFluxFixedLowerBound; ...
            'meanFluxFixedUpperBound' pdqConfiguration.meanFluxFixedUpperBound; ...
            'plateScaleFixedLowerBound' pdqConfiguration.plateScaleFixedLowerBound; ...
            'plateScaleFixedUpperBound' pdqConfiguration.plateScaleFixedUpperBound; ...
            'smearLevelFixedLowerBound'  pdqConfiguration.smearLevelFixedLowerBound; ...
            'smearLevelFixedUpperBound' pdqConfiguration.smearLevelFixedUpperBound; ...
            'maxAttitudeResidualInPixelsFixedLowerBound' pdqConfiguration.maxAttitudeResidualInPixelsFixedLowerBound; ...
            'maxAttitudeResidualInPixelsFixedUpperBound' pdqConfiguration.maxAttitudeResidualInPixelsFixedUpperBound; ...
            'reportEnabled' pdqConfiguration.reportEnabled; ...
            'debugLevel' pdqConfiguration.debugLevel; ...
            'forceReprocessing' pdqConfiguration.forceReprocessing; ...
            'excludeCadences' excludeCadences};

        report_add_static_table(fid, table);
    end

%% Generate figures used by reference-pixels-timestamps.tex.
    function generate_reference_pixels_timestamps()
        add_file('PDQ_Timestamps_Report.txt');
    end

%% Generate figures used by reference-pixels-gap-summary.tex.
    function generate_reference_pixels_gap_summary()
        add_file('PDQ_Pixels_Gap_Summary_by_Module_Output.txt');
    end

%% Generate figures used by reference-pixels-summary.tex.
    function generate_reference_pixels_summary()
        add_file('PDQ_Pixels_Summary_by_Module_Output.txt');
    end

%% Generate figures used by reference-pixels-mosaics.tex.
    function generate_reference_pixels_mosaics()
        s = '';
        i = 1;
        filenames = dir(fullfile(sourceDirectory, 'focal_plane/mosaic_of_raw_target_pixels_focal_plane_set_*.fig'));

        for filename = {filenames.name}
            basename = add_figure(['referencePixelsMosaic' num2str(i)], ...
                FOCAL_PLANE_DIR, filename{1}, DEFAULT_WIDTH, HALF_HEIGHT);
            if (~isempty(s))
                s = strcat(s, ',');
            end
            s = strcat(s, basename);
            i = i + 1;
        end
        
        if (~isempty(s))
            report_add_string(fid, 'referencePixelsMosaics', s, false);
        end
    end

%% Define common functions.

    function basename = add_figure(name, directory, pattern, widthPercent, heightPercent)
        if (~exist('widthPercent', 'var'))
            widthPercent = DEFAULT_WIDTH;
        end
        if (~exist('heightPercent', 'var'))
            heightPercent = DEFAULT_HEIGHT;
        end
        if (~exist('pattern', 'var'))
            pattern = '';
        end
        basename = pdq_report_add_figure(reportDir, fid, name, ...
            sourceDirectory, directory, pattern, widthPercent, heightPercent);
    end

    function add_file(name)
        pdq_report_add_file(reportDir, fullfile(sourceDirectory, name));
    end

    function csv = appendCsvValue(csv, s, separatorChar)
        if (~exist('separatorChar', 'var'))
            separatorChar = ',';
        end
        if (~isempty(csv))
            csv = [csv separatorChar];
        end
        csv = [csv s];
    end

end
