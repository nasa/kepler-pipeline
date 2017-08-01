%% dv_generate_reports
%
% function dvResultsStruct = dv_generate_reports(...
%    dvDataObject, dvResultsStruct, usedDefaultValuesStruct)
%
% Generates a report for each target in dvResultsStruct.
%
% reportFilename will be returned to dvResultsStruct.
%
%% INPUTS
%
%             dvDataObject [struct]: the input struct
%          dvResultsStruct [struct]: the output struct
%  usedDefaultValuesStruct [struct]: a record of the values that contain
%                                    default values
%
%% OUTPUTS
%
%          dvResultsStruct [struct]: the output struct whose reportFilename
%                                    fields have been modified appropriately.
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

function dvResultsStruct = dv_generate_reports(dvDataObject, ...
    dvResultsStruct, usedDefaultValuesStruct, sourceDirectory)

if (nargin < 3 && nargin > 5)
    disp('Usage: dv_generate_reports(dvDataObject, dvResultsStruct, usedDefaultValuesStruct[, sourceDirectory])');
    return;
end

if (~exist('sourceDirectory', 'var'))
    sourceDirectory = '';
end

CSCI = 'dv';
REPORT_ALIASES = 'report-values.sty';
TARGET_TABLE_SUMMARY= 'target-table-summary.tex';
PLANET_SUMMARY = 'planet-summary.tex';
ROLLING_BAND_CONTAMINATION = 'rolling-band-contamination-%d.tex';
ALL_TRANSITS_TCE = 'all-transits-tce-%d.tex';
ALL_TRANSITS_FIT_RESULTS = 'all-transits-fit-results-%d.tex';
ODDEVEN_TRANSITS_FIT_RESULTS = 'oddeven-transits-fit-results-%d.tex';
REDUCED_PARAMETER_FIT_RESULTS = 'reduced-parameter-fit-results-%d-%s.tex';
TRAPEZOIDAL_MODEL_FIT_RESULTS = 'trapezoidal-model-fit-results-%d.tex';
FLUX_WEIGHTED_CENTROID_TEST = 'flux-weighted-centroid-test-%d.tex';
ECLIPSING_BINARY_DISCRIMINATION_TEST = 'eclipsing-binary-discrimination-test-%d.tex';
WEAK_SECONDARY_RESULTS = 'weak-secondary-results-%d.tex';
BOOTSTRAP_TEST = 'bootstrap-test-%d.tex';
GHOST_DIAGNOSTIC_TEST = 'ghost-diagnostic-test-%d.tex';
ALERTS = 'alerts.tex';
TEAM = 'team.tex';

% Image dimensions.
WIDTH = 1.0; % width of images as percent of page
FULL_HEIGHT = 1.0;
HEIGHT = FULL_HEIGHT * 0.7; % height of images as percent of page w/caption
FOUR_PLOT_ONE_CAPTION_PER_PAGE_WIDTH = 0.40 * WIDTH;
FOUR_PLOT_ONE_CAPTION_PER_PAGE_HEIGHT = 0.475 * HEIGHT;
QUARTER_HEIGHT = 0.25 * HEIGHT;
THIRD_HEIGHT = 0.33 * HEIGHT; % 1/3 the height w/caption
HALF_HEIGHT = 0.4 * HEIGHT; % 1/2 the height w/caption
TWO_THIRDS_HEIGHT = 0.66 * HEIGHT; % 2/3 the height w/caption

reportDate = now;

for iTarget = 1 : length(dvResultsStruct.targetResultsStruct)
    targetResultsStruct = dvResultsStruct.targetResultsStruct(iTarget);
    planetResultsStruct = targetResultsStruct.planetResultsStruct;
    targetStruct = dvDataObject.targetStruct(iTarget);
    keplerId = targetResultsStruct.keplerId;
    zeroPaddedKeplerId = sprintf('%09d', keplerId);

    fprintf('DV:Report:Processing target #%d of %d, keplerId %d\n', ...
        iTarget, length(dvResultsStruct.targetResultsStruct), keplerId);
    
    [alertsTable, maxCandidatesPerTargetExceeded] = ...
        extract_alerts(keplerId, dvResultsStruct.alerts);
    
    % Code depends on figureRootDirectory not ending in a slash.
    figureRootDirectory = fullfile(sourceDirectory, targetResultsStruct.dvFiguresRootDirectory);
    figureRootDirectory = regexprep(figureRootDirectory, [filesep '+$'], '');
    
    %reportDateString = local_time_to_utc(reportDate, 'yyyymmdd');
    
    % Set report name.
    reportBasename = sprintf('%s-%09d', CSCI, keplerId);
    reportDir = fullfile(targetResultsStruct.dvFiguresRootDirectory, reportBasename);
    
    % Copy static files and rename dv-report.tex as required.
    report_copy_static_files(CSCI, reportDir);
    try 
        movefile(fullfile(reportDir, 'dv-report.tex'), ...
            fullfile(reportDir, [reportBasename '.tex']));
    catch ME 
        if ~exist(fullfile(reportDir, [reportBasename '.tex']), 'file')
            rethrow(ME);
        end;
    end;
    
    % Generate dynamic files and data.
    fid = report_open_latex_file(reportDir, REPORT_ALIASES);
    
    % Main portion of report.
    fprintf('DV:Report:Processing summary pages\n');
    generate_title_page();
    generate_team_page();
    generate_summary(dvDataObject.skyGroupId);
    
    generate_flux_time_series();
    generate_dashboards(usedDefaultValuesStruct(iTarget));
    generate_centroid_cloud_plot();
    generate_ukirt_image();
    generate_image_artifacts();
    generate_pixel_level_diagnostics();
    generate_phased_light_curves();

    fprintf('DV:Report:Processing per-planet pages\n');
    generate_per_planet_data();
    
    % Appendices.
    fprintf('DV:Report:Processing appendices\n');
    generate_per_planet_data_app();
    generate_single_event_statistics_app();
    generate_alerts_app(alertsTable);

    xclose(fid, REPORT_ALIASES);
    dvResultsStruct.targetResultsStruct(iTarget).reportFilename = reportDir;
end


return;

%% Generate data used by dv-report.tex.
%
    function generate_title_page()
        fprintf('  Title page\n');
        
        report_add_string(fid, 'generated', local_time_to_utc(reportDate, 0));
        report_add_string(fid, 'keplerId', num2str(keplerId));
        report_add_string(fid, 'zeroPaddedKeplerId', zeroPaddedKeplerId);
        
        % Use 'first' and 'last' prefixes instead of 'start' and 'end'
        % because LaTeX variables can't start with 'end'.
        report_add_string(fid, 'firstQuarter', num2str(dvDataObject.dvCadenceTimes.quarters(1)));
        report_add_string(fid, 'lastQuarter', num2str(dvDataObject.dvCadenceTimes.quarters(end)));
        
        % Add additional strings needed by many sections.
        
        % Give per-planet reports a variable to loop over (planets), as
        % well as additional variables to access the actual planet number
        % from the cryptic LaTeX-safe name.
        planets = '';
        for iPlanet = 1:length(planetResultsStruct)
            [planetNumber, safePlanetNumber] = getPlanetNumber(planetResultsStruct(iPlanet));
            report_add_string(fid, ['planet' safePlanetNumber], ...
                num2str(planetNumber));
            report_add_string(fid, ['zeroPaddedPlanet' safePlanetNumber], ...
                sprintf('%02d', planetNumber));
            planets = appendCsvValue(planets, safePlanetNumber);
        end
        report_add_string(fid, 'planets', planets);
        
        % Ditto for target tables.
        targetTables = '';
        for iTargetTable = 1:length(dvDataObject.targetTableDataStruct)
            [quarter, targetTable, safeTargetTable] = ...
                getTargetTableId(dvDataObject.targetTableDataStruct(iTargetTable));
            report_add_string(fid, ['targetTable' safeTargetTable], ...
                num2str(targetTable));
            report_add_string(fid, ['quarter' safeTargetTable], ...
                num2str(quarter));
            report_add_string(fid, ['zeroPaddedTargetTable' safeTargetTable], ...
                sprintf('%03d', targetTable));
            targetTables = appendCsvValue(targetTables, safeTargetTable);
        end
        report_add_string(fid, 'targetTables', targetTables);

        report_add_string(fid, 'ebDepthLimit', ...
            num2str(dvDataObject.planetFitConfigurationStruct.eclipsingBinaryDepthLimitPpm));
    end

%% Generate table used by team-app.tex.
%
    function generate_team_page()
        fprintf('  Team page\n');
        
        if (length(dvDataObject.dvConfigurationStruct.team) == 0)
            return
        end
        
        teamTable = generate_team_table( ...
            dvDataObject.dvConfigurationStruct.team);
        
        report_add_table(reportDir, TEAM, teamTable);
    end

%% Generate tables used by summary.tex.
%
    function generate_summary(skyGroupId)
        fprintf('  Summary\n');
        
        table = generate_target_summary_table(...
            targetStruct, targetResultsStruct, skyGroupId, ...
	    length(planetResultsStruct), ...
	    dvDataObject.softwareRevision, ...
            dvDataObject.transitParameterModelDescription, ...
	    dvDataObject.transitNameModelDescription, ...
	    dvDataObject.externalTceModelDescription);
        report_add_static_table(fid, table);
        if (maxCandidatesPerTargetExceeded)
            report_add_string(fid, 'maxCandidatesPerTarget', ...
                num2str(dvDataObject.dvConfigurationStruct.maxCandidatesPerTarget));
        end
        
        table = generate_target_table_summary_table(targetStruct, targetResultsStruct);
        report_add_table(reportDir, TARGET_TABLE_SUMMARY, table);
        
        report_add_string(fid, 'kjdOffsetFromJd', num2str(kjd_offset_from_jd, '%1.0f'));

        table = generate_planet_summary_table(planetResultsStruct);
        report_add_table(reportDir, PLANET_SUMMARY, table);

        generate_unmatched_koi_ids();
    end

%% Generate images used by flux-time-series.tex.
%
    function generate_flux_time_series()
        fprintf('  Flux time series\n');
        
        generate_figures('fluxDvFit', 0, 'summary-plots', ...
            sprintf('%09d-00-flux-dv-fit-*.fig', keplerId), ...
            WIDTH, HEIGHT);
        
        generate_figures('rawFlux', 0, 'summary-plots', ...
            sprintf('%09d-00-raw-flux-*.fig', keplerId), ...
            WIDTH, HEIGHT);
    end

%% Generate data used by dashboards.tex.
%
    function generate_dashboards(usedDefaultValuesStruct)
        fprintf('  Dashboards\n');
        
        warning('off', 'DV:retrieveModelParameter:illegalInput');
        warning('off', 'DV:retrieveModelParameter:missingParams');
        
        for iPlanet = 1:length(planetResultsStruct)
            [~, safePlanetNumber] = getPlanetNumber(planetResultsStruct(iPlanet));
            
            generateModelStellarRadius(planetResultsStruct(iPlanet));
            generateKicStellarRadius(planetResultsStruct(iPlanet), ...
                usedDefaultValuesStruct.radiusReplaced);
            generateModelFitterDashboard(planetResultsStruct(iPlanet));
            generateCentroidTestDashboard(planetResultsStruct(iPlanet));
            generateDifferenceImageCentroidOffsetsDashboard( ...
                planetResultsStruct(iPlanet));
            generateEclipsingBinaryDiscriminationTestDashboard('oddEvenDepth', safePlanetNumber, ...
                planetResultsStruct(iPlanet).binaryDiscriminationResults.oddEvenTransitDepthComparisonStatistic);
            generateEclipsingBinaryDiscriminationTestDashboard('oddEvenEpoch', safePlanetNumber, ...
                planetResultsStruct(iPlanet).binaryDiscriminationResults.oddEvenTransitEpochComparisonStatistic);
            generateEclipsingBinaryDiscriminationTestDashboard('shorterPeriod', safePlanetNumber, ...
                planetResultsStruct(iPlanet).binaryDiscriminationResults.shorterPeriodComparisonStatistic);
            generateEclipsingBinaryDiscriminationTestDashboard('longerPeriod', safePlanetNumber, ...
                planetResultsStruct(iPlanet).binaryDiscriminationResults.longerPeriodComparisonStatistic);
            generateBootstrapTestDashboard(planetResultsStruct(iPlanet));
        end
        report_add_string(fid, 'searchTransitThreshold', ...
            sprintf('%1.1f', dvDataObject.tpsConfigurationStruct.searchTransitThreshold));
        
        warning('on', 'DV:retrieveModelParameter:missingParams');
        warning('on', 'DV:retrieveModelParameter:illegalInput');
    end

% Create model stellar radius dashboard.
    function generateModelStellarRadius(planetResultsStruct)
        [~, safePlanetNumber] = getPlanetNumber(planetResultsStruct);
        starRadiusStruct = retrieve_model_parameter(...
            planetResultsStruct.allTransitsFit.modelParameters, 'starRadiusSolarRadii');
        
        if (planetResultsStruct.allTransitsFit.modelChiSquare ~= -1)
            report_add_string(fid, ['starRadiusSolarRadii' safePlanetNumber], ...
                sprintf('%1.1f', starRadiusStruct.value));
            report_add_string(fid, ['starRadiusSolarRadiiUncertainty' safePlanetNumber], ...
                sprintf('%1.1f', starRadiusStruct.uncertainty));
        end
        report_add_string(fid, ['starRadiusColor' safePlanetNumber], ...
            getStellarRadiusColor(planetResultsStruct));
    end

% Create KIC stellar radius dashboard.
    function generateKicStellarRadius(planetResultsStruct, radiusReplacedFlag)
        [~, safePlanetNumber] = getPlanetNumber(planetResultsStruct);
        report_add_string(fid, ['kicRadiusSolarRadii' safePlanetNumber], ...
            sprintf('%1.1f', targetStruct.radius.value));
        
        if (~isempty(targetStruct.radius.uncertainty) ...
                && ~isnan(targetStruct.radius.uncertainty))
            report_add_string(fid, ['kicRadiusSolarRadiiUncertainty' safePlanetNumber], ...
                sprintf('%1.1f', targetStruct.radius.uncertainty));
        end
        
        if (radiusReplacedFlag)
            report_add_string(fid, ['kicRadiusColor' safePlanetNumber], 'cyan');
        else
            report_add_string(fid, ['kicRadiusColor' safePlanetNumber], getStellarRadiusColor(planetResultsStruct));
        end
    end

% Determine the color for the stellar radius dashboard.
    function color = getStellarRadiusColor(planetResultsStruct)
        if (planetResultsStruct.allTransitsFit.modelChiSquare ~= -1)
            starRadiusStruct = retrieve_model_parameter(...
                planetResultsStruct.allTransitsFit.modelParameters, 'starRadiusSolarRadii');
            
            if (abs(targetStruct.radius.value - starRadiusStruct.value)/targetStruct.radius.value < 0.2)
                color = 'green';
            elseif ((abs(targetStruct.radius.value - starRadiusStruct.value)/targetStruct.radius.value >= 0.2) ...
                    && (abs(targetStruct.radius.value - starRadiusStruct.value)/targetStruct.radius.value <= 1))
                color = 'yellow';
            else
                % abs(targetStruct.radius.value - starRadiusStruct.value)/targetStruct.radius.value > 1
                color = 'red';
            end
        else
            % Fitter failed, or MES/SES < threshold, or EB
            color = 'cyan';
        end
    end

% Create model fitter dashboard. All-transit values are used.
    function generateModelFitterDashboard(planetResultsStruct)
        [~, safePlanetNumber] = getPlanetNumber(planetResultsStruct);
        allTransitsFit = planetResultsStruct.allTransitsFit;
        periodStruct = retrieve_model_parameter(...
            allTransitsFit.modelParameters, 'orbitalPeriodDays');
        transitDepthStruct = retrieve_model_parameter(...
            allTransitsFit.modelParameters, 'transitDepthPpm');
        result = '';
        color = 'cyan';
        resultColor = 'red';
        
        if (allTransitsFit.modelChiSquare ~= -1)
            % Fit succeeded.
            planetRadiusStruct = retrieve_model_parameter(...
                allTransitsFit.modelParameters, 'planetRadiusEarthRadii');
            semiMajorAxisStruct = retrieve_model_parameter(...
                allTransitsFit.modelParameters, 'semiMajorAxisAu');
            effectiveStellarFluxStruct = retrieve_model_parameter(...
                allTransitsFit.modelParameters, 'effectiveStellarFlux');
            equilibriumTempStruct = retrieve_model_parameter(...
                allTransitsFit.modelParameters, 'equilibriumTempKelvin');
            
            report_add_string(fid, ['orbitalPeriodDays' safePlanetNumber], ...
                sprintf('%1.1f', periodStruct.value));
            report_add_string(fid, ['orbitalPeriodDaysUncertainty' safePlanetNumber], ...
                sprintf('%1.1f', periodStruct.uncertainty));
            report_add_string(fid, ['transitDepthPpm' safePlanetNumber], ...
                sprintf('%1.0f', transitDepthStruct.value));
            report_add_string(fid, ['transitDepthPpmUncertainty' safePlanetNumber], ...
                sprintf('%1.0f', transitDepthStruct.uncertainty));
            report_add_string(fid, ['planetRadiusEarthRadii' safePlanetNumber], ...
                sprintf('%1.1f', planetRadiusStruct.value));
            report_add_string(fid, ['planetRadiusEarthRadiiUncertainty' safePlanetNumber], ...
                sprintf('%1.1f', planetRadiusStruct.uncertainty));
            report_add_string(fid, ['semiMajorAxisAu' safePlanetNumber], ...
                sprintf('%1.1f', semiMajorAxisStruct.value));
            report_add_string(fid, ['semiMajorAxisAuUncertainty' safePlanetNumber], ...
                sprintf('%1.1f', semiMajorAxisStruct.uncertainty));
            report_add_string(fid, ['effectiveStellarFlux' safePlanetNumber], ...
                sprintf('%1.1f', effectiveStellarFluxStruct.value));
            report_add_string(fid, ['effectiveStellarFluxUncertainty' safePlanetNumber], ...
                sprintf('%1.1f', effectiveStellarFluxStruct.uncertainty'));
            report_add_string(fid, ['equilibriumTempKelvin' safePlanetNumber], ...
                sprintf('%1.0f', equilibriumTempStruct.value));
            report_add_string(fid, ['equilibriumTempKelvinUncertainty' safePlanetNumber], ...
                sprintf('%1.0f', equilibriumTempStruct.uncertainty'));
            report_add_string(fid, ['chiSquaredOverDof' safePlanetNumber], ...
                sprintf('%1.1f', allTransitsFit.modelChiSquare/allTransitsFit.modelDegreesOfFreedom));
            snr = planetResultsStruct.allTransitsFit.modelFitSnr;
            report_add_string(fid, ['snr' safePlanetNumber], ...
                sprintf('%1.1f', snr));
            
            if (snr >= 10)
                color = 'green';
            elseif (snr >= dvDataObject.tpsConfigurationStruct.searchTransitThreshold)
                color = 'yellow';
            else
                color = 'red';
            end
            if (~allTransitsFit.fullConvergence)
                result = 'Model fit did not fully converge';
            end
        elseif (planetResultsStruct.planetCandidate.suspectedEclipsingBinary)
            % EB.
            report_add_string(fid, ['orbitalPeriodDays' safePlanetNumber], ...
                sprintf('%1.1f', periodStruct.value));
            report_add_string(fid, ['transitDepthPpm' safePlanetNumber], ...
                sprintf('%1.0f', transitDepthStruct.value));
            result = 'Planet candidate suspected to be an EB';
        else
            % MES/SES or fitter failure.
            if (planetResultsStruct.planetCandidate.statisticRatioBelowThreshold)
                result = 'MES/SES < threshold';
            else
                color = 'red';
                result = 'Model fit failed';
            end
        end
        report_add_string(fid, ['modelFitResult' safePlanetNumber], result);
        report_add_string(fid, ['modelFitResultColor' safePlanetNumber], resultColor);
        report_add_string(fid, ['modelFitColor' safePlanetNumber], color);
    end

% Create centroid test dashboard. Flux-weighted centroid values are used.
    function generateCentroidTestDashboard(planetResultsStruct)
        [~, safePlanetNumber] = getPlanetNumber(planetResultsStruct);
        motionResults = planetResultsStruct.centroidResults.fluxWeightedMotionResults;
        significance = motionResults.motionDetectionStatistic.significance;
        
        if (significance ~= -1)
            report_add_string(fid, ['centroidTestValue' safePlanetNumber], ...
                sprintf('%1.2e', motionResults.motionDetectionStatistic.value));
            report_add_string(fid, ['centroidTestSignificance' safePlanetNumber], ...
                sprintf('%1.2f', significance*100));
            report_add_string(fid, ['peakRaOffset' safePlanetNumber], ...
                sprintf('%1.2e', motionResults.peakRaOffset.value));
            report_add_string(fid, ['peakRaOffsetUncertainty' safePlanetNumber], ...
                sprintf('%1.2e', motionResults.peakRaOffset.uncertainty));
            report_add_string(fid, ['peakRaOffsetError' safePlanetNumber], ...
                sprintf('%1.2g', motionResults.peakRaOffset.value/motionResults.peakRaOffset.uncertainty));
            report_add_string(fid, ['peakDecOffset' safePlanetNumber], ...
                sprintf('%1.2e', motionResults.peakDecOffset.value));
            report_add_string(fid, ['peakDecOffsetUncertainty' safePlanetNumber], ...
                sprintf('%1.2e', motionResults.peakDecOffset.uncertainty));
            report_add_string(fid, ['peakDecOffsetError' safePlanetNumber], ...
                sprintf('%1.2g', motionResults.peakDecOffset.value/motionResults.peakDecOffset.uncertainty));
            report_add_string(fid, ['peakOffset' safePlanetNumber], ...
                sprintf('%1.2e', motionResults.peakOffsetArcSec.value));
            report_add_string(fid, ['peakOffsetUncertainty' safePlanetNumber], ...
                sprintf('%1.2e', motionResults.peakOffsetArcSec.uncertainty));
            report_add_string(fid, ['peakOffsetError' safePlanetNumber], ...
                sprintf('%1.2g', motionResults.peakOffsetArcSec.value/motionResults.peakOffsetArcSec.uncertainty));
            report_add_string(fid, ['sourceRaOffset' safePlanetNumber], ...
                sprintf('%1.2e', motionResults.sourceRaOffset.value));
            report_add_string(fid, ['sourceRaOffsetUncertainty' safePlanetNumber], ...
                sprintf('%1.2e', motionResults.sourceRaOffset.uncertainty));
            report_add_string(fid, ['sourceRaOffsetError' safePlanetNumber], ...
                sprintf('%1.2g', motionResults.sourceRaOffset.value/motionResults.sourceRaOffset.uncertainty));
            report_add_string(fid, ['sourceDecOffset' safePlanetNumber], ...
                sprintf('%1.2e', motionResults.sourceDecOffset.value));
            report_add_string(fid, ['sourceDecOffsetUncertainty' safePlanetNumber], ...
                sprintf('%1.2e', motionResults.sourceDecOffset.uncertainty));
            report_add_string(fid, ['sourceDecOffsetError' safePlanetNumber], ...
                sprintf('%1.2g', motionResults.sourceDecOffset.value/motionResults.sourceDecOffset.uncertainty));
            if (motionResults.sourceOffsetArcSec.uncertainty > 0)
                report_add_string(fid, ['sourceOffset' safePlanetNumber], ...
                    sprintf('%1.2e', motionResults.sourceOffsetArcSec.value));
                report_add_string(fid, ['sourceOffsetUncertainty' safePlanetNumber], ...
                    sprintf('%1.2e', motionResults.sourceOffsetArcSec.uncertainty));
                report_add_string(fid, ['sourceOffsetError' safePlanetNumber], ...
                    sprintf('%1.2g', motionResults.sourceOffsetArcSec.value/motionResults.sourceOffsetArcSec.uncertainty));
            end
        end
        
        report_add_string(fid, ['centroidTestColor' safePlanetNumber], ...
            getSignificanceColor(significance));
    end

% Create difference image centroid offsets dashboard.
    function generateDifferenceImageCentroidOffsetsDashboard(planetResultsStruct)
        [~, safePlanetNumber] = getPlanetNumber(planetResultsStruct);
        controlSkyOffset = planetResultsStruct.centroidResults.differenceImageMotionResults.mqControlCentroidOffsets.meanSkyOffset;
        kicSkyOffset = planetResultsStruct.centroidResults.differenceImageMotionResults.mqKicCentroidOffsets.meanSkyOffset;
        if (controlSkyOffset.uncertainty == -1)
            controlSkySigma = -1;
        else
            controlSkySigma = controlSkyOffset.value/controlSkyOffset.uncertainty;
        end
        if (kicSkyOffset.uncertainty == -1)
            kicSkySigma = -1;
        else
            kicSkySigma = kicSkyOffset.value/kicSkyOffset.uncertainty;
        end
        maxSkySigma = max(controlSkySigma, kicSkySigma);
        report_add_string(fid, ['differenceImageCentroidOffsets' 'Color' safePlanetNumber], ...
            getSigmaColor(maxSkySigma));
    end

% Determine the color for the given sigma.
%
% A significance of less than or equal to 2-sigma yields green, less than
% or equal to 3-sigma yields yellow, and a significance above 3-sigma
% yields red.
%
% A significance of -1 (no data) yields cyan.
    function color = getSigmaColor(sigma)
        if (sigma == -1)
            color = 'cyan';
        elseif (sigma <= 2.0)
            color = 'green';
        elseif (sigma <= 3.0)
            color = 'yellow';
        else
            color = 'red';
        end
    end

% Create eclipsing binary discrimination test dashboard.
    function generateEclipsingBinaryDiscriminationTestDashboard(basename, safePlanetNumber, statistic)
        if (statistic.significance ~= -1)
            report_add_string(fid, [basename safePlanetNumber], ...
                sprintf('%1.2e', statistic.value));
            report_add_string(fid, [basename 'Significance' safePlanetNumber], ...
                sprintf('%1.2f', statistic.significance*100));
        end
        report_add_string(fid, [basename 'Color' safePlanetNumber], ...
            getSignificanceColor(statistic.significance));
    end


% Determine the color for the given significance.
%
% A significance of less than or equal to 2-sigma yields green, less than
% or equal to 3-sigma yields yellow, and a significance above 3-sigma
% yields red.
%
% A significance of -1 (no data) yields cyan.
    function color = getSignificanceColor(significance)
        if (significance == -1)
            color = 'cyan';
        elseif (significance >= erfc(2/sqrt(2)))
            color = 'green';
        elseif (significance >= erfc(3/sqrt(2)))
            color = 'yellow';
        else
            color = 'red';
        end
    end

% Create bootstrap test dashboard.
    function generateBootstrapTestDashboard(planetResultsStruct)
        [~, safePlanetNumber] = getPlanetNumber(planetResultsStruct);
        bootstrapFalseAlarm = planetResultsStruct.planetCandidate.significance;
        maxMultipleEventStatistic = planetResultsStruct.planetCandidate.maxMultipleEventSigma;
        color = 'cyan';
        
        if (bootstrapFalseAlarm ~= -1)
            report_add_string(fid, ['bootstrapFalseAlarm' safePlanetNumber], ...
                sprintf('%1.2e', bootstrapFalseAlarm));
            
            % If false alarm was set to 0 because no null total detection
            % statistic > search transit theshold.
            if (~isempty(planetResultsStruct.planetCandidate.bootstrapHistogram.statistics))
                report_add_string(fid, ['finalSkipCount', safePlanetNumber], ...
                    sprintf('%d', planetResultsStruct.planetCandidate.bootstrapHistogram.finalSkipCount));
            end
            
            % Since the error function can return impossibly small values,
            % even though the result is good, impose some sort of a limit
            % so that the bootstrap panel can be colored green if the
            % result is good.
            %
            % The value 1e12 is the approximate number of independent
            % statistical tests performed in TPS for 100,000 stars in the
            % nominal mission, so 1e-12 represents one false alarm for the
            % mission.
            falseAlarmLimit = 1e-12;
            
            if (bootstrapFalseAlarm <= max(0.5*erfc(maxMultipleEventStatistic/sqrt(2)), falseAlarmLimit))
                color = 'green';
            elseif (bootstrapFalseAlarm <=  2*0.5*erfc(maxMultipleEventStatistic/sqrt(2)))
                color = 'yellow';
            else
                color = 'red';
            end
        end
        
        if (planetResultsStruct.allTransitsFit.modelChiSquare ~= -1)
            report_add_string(fid, ['observedTransitCount' safePlanetNumber], ...
                sprintf('%d', planetResultsStruct.planetCandidate.observedTransitCount));
        end
        
        report_add_string(fid, ['maxMultipleEventStatistic' safePlanetNumber], ...
            sprintf('%1.1f', maxMultipleEventStatistic));
        report_add_string(fid, ['bootstrapColor' safePlanetNumber], color);
    end

%% Generate planet summary table footnote about unmatched KOI IDs used by summary.tex.
%
    function generate_unmatched_koi_ids()
        fprintf('  Unmatched KOI IDs\n');

        unmatchedKoiIds = '';
        if (~isempty(targetResultsStruct.unmatchedKoiIds))
            for iKoiId = 1:length(targetResultsStruct.unmatchedKoiIds)
                unmatchedKoiId = char(targetResultsStruct.unmatchedKoiIds(iKoiId));
                if (~isempty(unmatchedKoiIds))
                    unmatchedKoiIds = [ unmatchedKoiIds ', ' ];
                end
                unmatchedKoiIds = [ unmatchedKoiIds unmatchedKoiId ];
            end
        end
        report_add_string(fid, 'unmatchedKoiIds', unmatchedKoiIds);
    end

%% Generate UKIRT image used by ukirt-image.tex.
%
    function generate_ukirt_image()
        fprintf('  UKIRT image\n');
        
        ukirtBase = sprintf('target-%09d-ukirt', keplerId);
        ukirtPng = [ ukirtBase '.png' ];
        if (exist(ukirtPng))
            copyfile(ukirtPng, reportDir);
            
            report_add_string(fid, 'ukirtImageFile', ukirtBase);
        end
    end

%% Generate image used by centroid-cloud-plot.tex.
%
    function generate_centroid_cloud_plot()
        fprintf('  Centroid cloud plot\n');

        generate_figures('centroidCloudPlot', 0, 'summary-plots', ...
            sprintf('%09d-00-fluxWeighted-centroids-cloud.fig', keplerId), ...
            WIDTH, HEIGHT);
    end

%% Generate images used by phased-light-curves.tex
%
    function generate_phased_light_curves()
        fprintf('  Phased Light Curves\n');

        generate_figures('phasedUnwhitenedLightCurves', 0, 'summary-plots', ...
            sprintf('%09d-*-phased-unwhitened-flux-time-series.fig', keplerId), ...
            WIDTH, HEIGHT);

        generate_figures('phasedWhitenedLightCurves', 0, 'summary-plots', ...
            sprintf('%09d-*-phased-whitened-flux-time-series.fig', keplerId), ...
            WIDTH, HEIGHT);

        generate_figures('phasedUnwhitenedLightCurvesByQuarter', 0, 'summary-plots', ...
            sprintf('%09d-*-phased-unwhitened-flux-time-series-by-quarter.fig', keplerId), ...
            WIDTH, HEIGHT);
    end

%% Generate images used by image-artifacts.tex.
%
    function generate_image_artifacts()
        fprintf('  Image artifacts\n');
        
        if (~dvDataObject.dvConfigurationStruct.rollingBandDiagnosticsEnabled)
            return
        end
        
        for iPlanet = 1:length(planetResultsStruct)
            [planetNumber, safePlanetNumber] = getPlanetNumber(planetResultsStruct(iPlanet));
            rollingBandContaminationHistogram = ...
                planetResultsStruct(iPlanet).imageArtifactResults.rollingBandContaminationHistogram;
            
            [table, transitCountsString, transitFractionTotalString] = ...
                generate_rolling_band_contamination_table(rollingBandContaminationHistogram);
            
            report_add_table(reportDir, sprintf(ROLLING_BAND_CONTAMINATION, planetNumber), table);
            report_add_string(fid, ['rollingBandContaminationTransitCounts' safePlanetNumber], ...
                transitCountsString);
            report_add_string(fid, ['rollingBandContaminationTransitFractionTotal' safePlanetNumber], ...
                transitFractionTotalString);
        end
    end

%% Generate images used by pixel-level-diagnostics.tex.
%
    function generate_pixel_level_diagnostics()
        fprintf('  Pixel level diagnostics\n');

        for iPlanet = 1:length(planetResultsStruct)
            [planetNumber, safePlanetNumber] = getPlanetNumber(planetResultsStruct(iPlanet));
            
            generate_difference_image_summary_quality_metric_table(planetNumber, safePlanetNumber);
            
            generate_difference_image_mq_centroid_offset(planetNumber, safePlanetNumber);
            generate_difference_image_mq_centroid_offset_table(planetNumber, safePlanetNumber);
            generate_pixel_correlation_mq_centroid_offset(planetNumber, safePlanetNumber);
            generate_pixel_correlation_mq_centroid_offset_table(planetNumber, safePlanetNumber);
            
            generate_kic_reference_centroid_table_entry(planetNumber, safePlanetNumber);
            generate_difference_image_mq_image_centroid_table(planetNumber, safePlanetNumber);
            generate_pixel_correlation_mq_image_centroid_table(planetNumber, safePlanetNumber);
            
            for iTargetTable = 1:length(dvDataObject.targetTableDataStruct)
                [~, targetTableId, safeTargetTableId] = getTargetTableId(dvDataObject.targetTableDataStruct(iTargetTable));
                
                generate_difference_image(planetNumber, safePlanetNumber, targetTableId, safeTargetTableId);
                generate_difference_image_centroid_table(planetNumber, safePlanetNumber, targetTableId, safeTargetTableId);
                generate_pixel_correlation_statistic(planetNumber, safePlanetNumber, targetTableId, safeTargetTableId);
                generate_pixel_correlation_centroid_table(planetNumber, safePlanetNumber, targetTableId, safeTargetTableId);
            end
            
        end
        
        fprintf('  Centroid cloud plot\n');
        report_add_string(fid, 'pixelCorrelationFigureWidthPercent', ...
            sprintf('%.2f', FOUR_PLOT_ONE_CAPTION_PER_PAGE_WIDTH/WIDTH), false);
    end

    function generate_difference_image_summary_quality_metric_table(planetNumber, safePlanetNumber)
        differenceImageMotionResults = planetResultsStruct(planetNumber).centroidResults.differenceImageMotionResults;
        if (~mq_centroid_offsets_data_available(differenceImageMotionResults))
            return;
        end
        
        add_mq_summary_metric_strings(differenceImageMotionResults.summaryQualityMetric, ...
            'diffImageMqSummaryQualityMetric', safePlanetNumber);
    end

    function generate_kic_reference_centroid_table_entry(planetNumber, safePlanetNumber)
        differenceImageResults = planetResultsStruct(planetNumber).differenceImageResults;
        if (~isfield(differenceImageResults, 'kicReferenceCentroid'))
            return;
        end
        differenceImageResult = differenceImageResults(1);
        report_add_string(fid, ['kicReferenceCentroidRa' safePlanetNumber], ...
            sprintf('%.8f', differenceImageResult.kicReferenceCentroid.raHours.value));
        report_add_string(fid, ['kicReferenceCentroidRa' 'Uncertainty' safePlanetNumber], ...
            sprintf('%.2e', differenceImageResult.kicReferenceCentroid.raHours.uncertainty));
        report_add_string(fid, ['kicReferenceCentroidDec' safePlanetNumber], ...
            sprintf('%.8f', differenceImageResult.kicReferenceCentroid.decDegrees.value));
        report_add_string(fid, ['kicReferenceCentroidDec' 'Uncertainty' safePlanetNumber], ...
            sprintf('%.2e', differenceImageResult.kicReferenceCentroid.decDegrees.uncertainty));

    end

    function generate_difference_image_mq_centroid_offset(planetNumber, safePlanetNumber)
        figureMacro = generate_figures( '', planetNumber, 'difference-image', ...
            sprintf('%09d-%02d-difference-image-centroid-offsets.fig', ...
            keplerId, planetNumber), WIDTH, HALF_HEIGHT);
        report_add_string(fid, ...
            ['differenceImageMqCentroidOffsets' safePlanetNumber], ...
            figureMacro, false);

        figureMacro = generate_figures( '', planetNumber, 'difference-image', ...
            sprintf('%09d-%02d-difference-image-centroid-offsets-ukirt.fig', ...
            keplerId, planetNumber), WIDTH, HALF_HEIGHT);
        report_add_string(fid, ...
            ['differenceImageMqCentroidOffsetsUkirt' safePlanetNumber], ...
            figureMacro, false);
    end

    function generate_pixel_correlation_mq_centroid_offset(planetNumber, safePlanetNumber)
        figureMacro = generate_figures( '', planetNumber, 'pixel-correlation-test-results', ...
            sprintf('%09d-%02d-pixel-correlation-centroid-offsets.fig', ...
            keplerId, planetNumber), WIDTH, HALF_HEIGHT);
        report_add_string(fid, ...
            ['pixelCorrelationMqCentroidOffsets' safePlanetNumber], ...
            figureMacro, false);

        figureMacro = generate_figures( '', planetNumber, 'pixel-correlation-test-results', ...
            sprintf('%09d-%02d-pixel-correlation-centroid-offsets-ukirt.fig', ...
            keplerId, planetNumber), WIDTH, HALF_HEIGHT);
        report_add_string(fid, ...
            ['pixelCorrelationMqCentroidOffsetsUkirt' safePlanetNumber], ...
            figureMacro, false);
    end

    function generate_difference_image(planetNumber, safePlanetNumber, targetTableId, safeTargetTableId)
        figureMacro = generate_figures( '', planetNumber, 'difference-image', ...
            sprintf('%09d-%02d-difference-image-*-%03d.fig', ...
            keplerId, planetNumber, targetTableId), ...
            WIDTH, HEIGHT);
        report_add_string(fid, ...
            ['differenceImage' safePlanetNumber safeTargetTableId], ...
            figureMacro, false);
    end

    function generate_difference_image_mq_centroid_offset_table(planetNumber, safePlanetNumber)
        differenceImageMotionResults = planetResultsStruct(planetNumber).centroidResults.differenceImageMotionResults;
        if (~mq_centroid_offsets_data_available(differenceImageMotionResults))
            return;
        end
        
        add_mq_offset_strings(differenceImageMotionResults.mqControlCentroidOffsets, 'diffImageMqCntlCentroidOffsets', safePlanetNumber);
        add_mq_offset_strings(differenceImageMotionResults.mqKicCentroidOffsets, 'diffImageMqKicCentroidOffsets', safePlanetNumber);
    end

    function generate_difference_image_mq_image_centroid_table(planetNumber, safePlanetNumber)
        differenceImageMotionResults = planetResultsStruct(planetNumber).centroidResults.differenceImageMotionResults;
        if (~mq_image_centroid_data_available(differenceImageMotionResults))
            return;
        end
        
        add_mq_centroid_strings(differenceImageMotionResults.mqControlImageCentroid, 'diffImageMqCntlImageCentroid', safePlanetNumber);
        add_mq_centroid_strings(differenceImageMotionResults.mqDifferenceImageCentroid, 'diffImageMqDiffImageCentroid', safePlanetNumber);
    end

    function generate_pixel_correlation_mq_centroid_offset_table(planetNumber, safePlanetNumber)
        pixelCorrelationMotionResults = planetResultsStruct(planetNumber).centroidResults.pixelCorrelationMotionResults;
        if (~mq_centroid_offsets_data_available(pixelCorrelationMotionResults))
            return;
        end
        
        add_mq_offset_strings(pixelCorrelationMotionResults.mqControlCentroidOffsets, 'pixelCorrMqCntlCentroidOffsets', safePlanetNumber);
        add_mq_offset_strings(pixelCorrelationMotionResults.mqKicCentroidOffsets, 'pixelCorrMqKicCentroidOffsets', safePlanetNumber);
    end

    function generate_pixel_correlation_mq_image_centroid_table(planetNumber, safePlanetNumber)
        pixelCorrelationMotionResults = planetResultsStruct(planetNumber).centroidResults.pixelCorrelationMotionResults;
        if (~mq_image_centroid_data_available(pixelCorrelationMotionResults))
            return;
        end
        
        add_mq_centroid_strings(pixelCorrelationMotionResults.mqControlImageCentroid, 'pixelCorrMqCntlImageCentroid', safePlanetNumber);
        add_mq_centroid_strings(pixelCorrelationMotionResults.mqCorrelationImageCentroid, 'pixelCorrMqCorrImageCentroid', safePlanetNumber);
    end

    function dataAvailable = mq_centroid_offsets_data_available(motionResults)
        mqControlCentroidOffsets = motionResults.mqControlCentroidOffsets;
        if (mqControlCentroidOffsets.meanDecOffset.uncertainty ~= -1 ...
                || mqControlCentroidOffsets.meanRaOffset.uncertainty ~= -1 ...
                || mqControlCentroidOffsets.meanSkyOffset.uncertainty ~= -1)
            dataAvailable = true;
            return;
        end
        mqKicCentroidOffsets = motionResults.mqKicCentroidOffsets;
        if (mqKicCentroidOffsets.meanDecOffset.uncertainty ~= -1 ...
                || mqKicCentroidOffsets.meanRaOffset.uncertainty ~= -1 ...
                || mqKicCentroidOffsets.meanSkyOffset.uncertainty ~= -1)
            dataAvailable = true;
            return;
        end
        dataAvailable = false;
    end

    function dataAvailable = mq_image_centroid_data_available(motionResults)
        mqControlImageCentroid = motionResults.mqControlImageCentroid;
        if (mqControlImageCentroid.decDegrees.uncertainty ~= -1 ...
                || mqControlImageCentroid.raHours.uncertainty ~= -1)
            dataAvailable = true;
            return;
        end
        if (isfield(motionResults, 'mqDifferenceImageCentroid'))
            mqImageCentroid = motionResults.mqDifferenceImageCentroid;
        elseif (isfield(motionResults, 'mqCorrelationImageCentroid'))
            mqImageCentroid = motionResults.mqCorrelationImageCentroid;
        else
            warning('DV:dvGenerateReports:mqImageCentroidDataAvailable:missingField', ...
                'motion results missing mqDifferenceImageCentroid and/or mqCorrelationImageCentroid fields');
            mqImageCentroid = [];
        end
        if (~isempty(mqImageCentroid) ...
                && (mqImageCentroid.decDegrees.uncertainty ~= -1 ...
                || mqImageCentroid.raHours.uncertainty ~= -1))
            dataAvailable = true;
            return;
        end
        dataAvailable = false;
    end

    function generate_difference_image_centroid_table(planetNumber, safePlanetNumber, targetTableId, safeTargetTableId)
        differenceImageResults = get_difference_image_results(planetNumber, targetTableId);
        if (isempty(differenceImageResults) ...
                || ~centroid_data_available(differenceImageResults))
            % If differenceImageResults is empty, there isn't any quarter data.
            % Also avoid displaying the table if centroids and offsets have
            % not been calculated.
            return;
        end
        
        add_centroid_strings(differenceImageResults.controlImageCentroid, 'diffImageCntlImageCentroid', safePlanetNumber, safeTargetTableId);
        add_centroid_strings(differenceImageResults.differenceImageCentroid, 'diffImageCentroid', safePlanetNumber, safeTargetTableId);
        add_offset_strings(differenceImageResults.controlCentroidOffsets, 'diffImageCntlCentroidOffsets', safePlanetNumber, safeTargetTableId);

        add_centroid_strings(differenceImageResults.kicReferenceCentroid, 'diffImageKicReferenceCentroid', safePlanetNumber, safeTargetTableId);
        add_offset_strings(differenceImageResults.kicCentroidOffsets, 'diffImageKicCentroidOffsets', safePlanetNumber, safeTargetTableId);
    end

    function differenceImageResults = get_difference_image_results(planet, targetTableId)
        planetResults = planetResultsStruct(planet);
        
        for iDifferenceImageResults = 1 : length(planetResults.differenceImageResults)
            differenceImageResults = planetResults.differenceImageResults(iDifferenceImageResults);
            if (differenceImageResults.targetTableId == targetTableId)
                return;
            end
        end
        fprintf('No differenceImageResults for planet %d, target table ID %d\n', ...
            planet, targetTableId);
        differenceImageResults = [];
    end

    function generate_pixel_correlation_centroid_table(planetNumber, safePlanetNumber, targetTableId, safeTargetTableId)
        pixelCorrelationResults = get_pixel_correlation_results(planetNumber, targetTableId);
        if (isempty(pixelCorrelationResults) ...
                || ~centroid_data_available(pixelCorrelationResults))
            % This occurs when the differenceImageResults are empty too, so
            % the report uses differenceImageCentroidAvailable to print
            % both the difference image and pixel correlation statistic
            % centroid tables.
            return;
        end
        
        add_centroid_strings(pixelCorrelationResults.controlImageCentroid, 'pixelCorrCntlImageCentroid', safePlanetNumber, safeTargetTableId);
        add_centroid_strings(pixelCorrelationResults.correlationImageCentroid, 'corrImageCentroid', safePlanetNumber, safeTargetTableId);
        add_offset_strings(pixelCorrelationResults.controlCentroidOffsets, 'pixelCorrCntlCentroidOffsets', safePlanetNumber, safeTargetTableId);

        add_centroid_strings(pixelCorrelationResults.kicReferenceCentroid, 'pixelCorrKicReferenceCentroid', safePlanetNumber, safeTargetTableId);
        add_offset_strings(pixelCorrelationResults.kicCentroidOffsets, 'pixelCorrKicCentroidOffsets', safePlanetNumber, safeTargetTableId);
    end

    function pixelCorrelationResults = get_pixel_correlation_results(planet, targetTableId)
        planetResults = planetResultsStruct(planet);
        
        for iPixelCorrelationResults = 1 : length(planetResults.pixelCorrelationResults)
            pixelCorrelationResults = planetResults.pixelCorrelationResults(iPixelCorrelationResults);
            if (pixelCorrelationResults.targetTableId == targetTableId)
                return;
            end
        end
        fprintf('No pixelCorrelationResults for planet %d, target table ID %d\n', ...
            planet, targetTableId);
        pixelCorrelationResults = [];
    end

    function dataAvailable = centroid_data_available(centroidResults)
        centroid = centroidResults.controlImageCentroid;
        if (centroid.row.uncertainty ~= -1 || centroid.column.uncertainty ~= -1 ...
                || centroid.raHours.uncertainty ~= -1 || centroid.decDegrees.uncertainty ~= -1)
            dataAvailable = true;
            return;
        end
        if (isfield(centroidResults, 'differenceImageCentroid'))
            centroid = centroidResults.differenceImageCentroid;
        elseif (isfield(centroidResults, 'correlationImageCentroid'))
            centroid = centroidResults.correlationImageCentroid;
        else
            warning('DV:dvGenerateReports:centroidDataAvailable:missingField', ...
                'centroid results missing differenceImageCentroid and/or correlationImageCentroid fields');
            centroid = [];
        end
        if (~isempty(centroid) ...
                && (centroid.row.uncertainty ~= -1 || centroid.column.uncertainty ~= -1 ...
                || centroid.raHours.uncertainty ~= -1 || centroid.decDegrees.uncertainty ~= -1))
            dataAvailable = true;
            return;
        end
        offsets = centroidResults.controlCentroidOffsets;
        if (offsets.rowOffset.uncertainty ~= -1 || offsets.columnOffset.uncertainty ~= -1 ...
                || offsets.raOffset.uncertainty ~= -1 || offsets.decOffset.uncertainty ~= -1 ...
                || offsets.focalPlaneOffset.uncertainty ~= -1 || offsets.skyOffset.uncertainty ~= -1)
            dataAvailable = true;
            return;
        end
        dataAvailable = false;
    end

    function add_mq_summary_metric_strings(metric, prefix, safePlanetNumber)
        report_add_string(fid, [prefix 'FractionGoodMetrics' safePlanetNumber], ...
            sprintf('%.4f', metric.fractionOfGoodMetrics));
        report_add_string(fid, [prefix 'NumberAttempts' safePlanetNumber], ...
            sprintf('%d', metric.numberOfAttempts));
        report_add_string(fid, [prefix 'NumberGoodMetrics' safePlanetNumber], ...
            sprintf('%d', metric.numberOfGoodMetrics));
        report_add_string(fid, [prefix 'NumberMetrics' safePlanetNumber], ...
            sprintf('%d', metric.numberOfMetrics));
        report_add_string(fid, [prefix 'QualityThreshold' safePlanetNumber], ...
            sprintf('%.2f', metric.qualityThreshold));
    end

    function add_centroid_strings(centroid, prefix, safePlanetNumber, safeTargetTableId)
        add_quantity_strings_one_based([prefix 'Row'], [safePlanetNumber safeTargetTableId], centroid.row, '%.2f');
        add_quantity_strings_one_based([prefix 'Column'], [safePlanetNumber safeTargetTableId], centroid.column, '%.2f');
        add_quantity_strings([prefix 'Ra'], [safePlanetNumber safeTargetTableId], centroid.raHours, '%.8f');
        add_quantity_strings([prefix 'Dec'], [safePlanetNumber safeTargetTableId], centroid.decDegrees, '%.8f');
    end

    function add_offset_strings(offset, prefix, safePlanetNumber, safeTargetTableId)
        add_quantity_strings([prefix 'Row'], [safePlanetNumber safeTargetTableId], offset.rowOffset, '%.4f');
        add_quantity_strings([prefix 'Column'], [safePlanetNumber safeTargetTableId], offset.columnOffset, '%.4f');
        add_quantity_strings([prefix 'Ra'], [safePlanetNumber safeTargetTableId], offset.raOffset, '%.4f');
        add_quantity_strings([prefix 'Dec'], [safePlanetNumber safeTargetTableId], offset.decOffset, '%.4f');

        add_quantity_strings([prefix 'DistanceCcd'], [safePlanetNumber safeTargetTableId], offset.focalPlaneOffset, '%.4f');
        add_quantity_strings([prefix 'DistanceSky'], [safePlanetNumber safeTargetTableId], offset.skyOffset, '%.4f');
    end

    function add_mq_centroid_strings(centroid, prefix, safePlanetNumber)
        add_quantity_strings([prefix 'Ra'], safePlanetNumber, centroid.raHours, '%.8f');
        add_quantity_strings([prefix 'Dec'], safePlanetNumber, centroid.decDegrees, '%.8f');
    end

    function add_mq_offset_strings(offset, prefix, safePlanetNumber)
        add_quantity_strings([prefix 'MeanRa'], safePlanetNumber, offset.meanRaOffset, '%.4f');
        add_quantity_strings([prefix 'MeanDec'], safePlanetNumber, offset.meanDecOffset, '%.4f');
        add_quantity_strings([prefix 'MeanDistanceSky'], safePlanetNumber, offset.meanSkyOffset, '%.4f');
        add_quantity_strings([prefix 'SingleFitRa'], safePlanetNumber, offset.singleFitRaOffset, '%.4f');
        add_quantity_strings([prefix 'SingleFitDec'], safePlanetNumber, offset.singleFitDecOffset, '%.4f');
        add_quantity_strings([prefix 'SingleFitDistanceSky'], safePlanetNumber, offset.singleFitSkyOffset, '%.4f');
    end

    function add_quantity_strings(prefix, suffix, quantity, format)
        if (quantity.uncertainty ~= -1)
            report_add_string(fid, [prefix suffix], sprintf(format, quantity.value));
            report_add_string(fid, [prefix 'Dbo' suffix], sprintf('%.2e', quantity.value));
            report_add_string(fid, [prefix 'Uncertainty' suffix], sprintf('%.2e', quantity.uncertainty));
            report_add_string(fid, [prefix 'Sigma' suffix], sprintf('%.2f', quantity.value/quantity.uncertainty));
            report_add_string(fid, [prefix 'ThreeSigma' suffix], sprintf('%.4f', 3*quantity.uncertainty));
        end
    end

    function add_quantity_strings_one_based(prefix, suffix, quantity, format)
        if (quantity.uncertainty ~= -1)
            report_add_string(fid, [prefix suffix], sprintf(format, quantity.value - 1));
            report_add_string(fid, [prefix 'Uncertainty' suffix], sprintf('%.2e', quantity.uncertainty));
        end
    end

    function generate_pixel_correlation_statistic(planetNumber, safePlanetNumber, targetTableId, safeTargetTableId)
        figureMacro = generate_figures('', planetNumber, 'pixel-correlation-test-results', ...
            sprintf('%09d-%02d-pixel-correlation-statistic-*-%03d.fig', ...
            keplerId, planetNumber, targetTableId), ...
            FOUR_PLOT_ONE_CAPTION_PER_PAGE_WIDTH, FOUR_PLOT_ONE_CAPTION_PER_PAGE_HEIGHT);
        report_add_string(fid, ...
            ['pixelCorrelationStatistic' safePlanetNumber safeTargetTableId], ...
            figureMacro, false);
    end
%% Generate data and images in per-planet sections.
%
    function generate_per_planet_data()
        reducedParameterFitsEnabled = 'false';
        if (dvDataObject.planetFitConfigurationStruct.reducedParameterFitsEnabled)
            reducedParameterFitsEnabled = 'true';
        end
        report_add_string(fid, 'reducedParameterFitsEnabled', ...
            reducedParameterFitsEnabled);
        
        trapezoidalModelFitEnabled = 'false';
        if (dvDataObject.planetFitConfigurationStruct.trapezoidalModelFitEnabled)
            trapezoidalModelFitEnabled = 'true';
        end
        report_add_string(fid, 'trapezoidalModelFitEnabled', ...
            trapezoidalModelFitEnabled);
        
        for iPlanet = 1:length(planetResultsStruct)
            fprintf('  Planet #%d of %d\n', iPlanet, length(planetResultsStruct));
            generate_model_fitter_all(planetResultsStruct(iPlanet));
            if (strcmp(reducedParameterFitsEnabled, 'true'))
                generate_model_fitter_reduced_parameter(planetResultsStruct(iPlanet));
            end
            if (strcmp(trapezoidalModelFitEnabled, 'true'))
                generate_trapezoidal_model_fitter(planetResultsStruct(iPlanet));
            end
            generate_validation_tests(planetResultsStruct(iPlanet));
        end
    end

%% Generate data and images used by model-fitter-all.tex.
%
    function generate_model_fitter_all(planetResultsStruct)
        fprintf('    Model fitter (all transits)\n');

        [planetNumber, safePlanetNumber] = getPlanetNumber(planetResultsStruct);
        
        report_add_string(fid, ['transitModel' safePlanetNumber], ...
            planetResultsStruct.allTransitsFit.transitModelName);
        report_add_string(fid, ['limbDarkeningModel' safePlanetNumber], ...
            planetResultsStruct.allTransitsFit.limbDarkeningModelName);
        
        tceTable = generate_tce_table(planetResultsStruct.planetCandidate);
        report_add_table(reportDir, ...
            sprintf(ALL_TRANSITS_TCE, planetNumber), tceTable);
        
        fullConvergence = 'true';
        suspectedEclipsingBinary = 'false';
        belowMesSesThreshold = 'false';
        modelFitFailed = 'false';
        fitTable = generate_fitter_results_table(planetResultsStruct, 'all');
        if (planetResultsStruct.allTransitsFit.modelChiSquare > 0)
            report_add_table(reportDir, ...
                sprintf(ALL_TRANSITS_FIT_RESULTS, planetNumber), fitTable);
            if (~planetResultsStruct.allTransitsFit.fullConvergence)
                fullConvergence = 'false';
            end
        elseif (planetResultsStruct.planetCandidate.suspectedEclipsingBinary)
            report_add_table(reportDir, ...
                sprintf(ALL_TRANSITS_FIT_RESULTS, planetNumber), fitTable);
            suspectedEclipsingBinary = 'true';
        elseif (planetResultsStruct.planetCandidate.statisticRatioBelowThreshold)
            belowMesSesThreshold = 'true';
        else
            modelFitFailed = 'true';
        end
        report_add_string(fid, ['fullConvergence' safePlanetNumber], fullConvergence);
        report_add_string(fid, ['suspectedEclipsingBinary' safePlanetNumber], suspectedEclipsingBinary);
        report_add_string(fid, ['belowMesSesThreshold' safePlanetNumber], belowMesSesThreshold);
        report_add_string(fid, ['modelFitFailed' safePlanetNumber], modelFitFailed);
        
        % Remove -filtered-zoomed and -zoomed figure names as they will be
        % displayed separately.
        generate_figures(['allUnwhitened' safePlanetNumber], planetNumber, ...
            fullfile('planet-search-and-model-fitting-results', 'all-transits-fit'), ...
            sprintf('%09d-%02d-all-unwhitened-*.fig', keplerId, planetNumber), ...
            WIDTH, HEIGHT, '-zoomed.fig');
        
        generate_figures(['allUnwhitenedFilteredZoomed' safePlanetNumber], planetNumber, ...
            fullfile('planet-search-and-model-fitting-results', 'all-transits-fit'), ...
            sprintf('%09d-%02d-all-unwhitened-filtered-zoomed.fig', keplerId, planetNumber), ...
            WIDTH, HALF_HEIGHT);
        
        generate_figures(['allUnwhitenedZoomed' safePlanetNumber], planetNumber, ...
            fullfile('planet-search-and-model-fitting-results', 'all-transits-fit'), ...
            sprintf('%09d-%02d-all-unwhitened-zoomed.fig', keplerId, planetNumber), ...
            WIDTH, HALF_HEIGHT);
        
        generate_figures(['allWhitened' safePlanetNumber], planetNumber, ...
            fullfile('planet-search-and-model-fitting-results', 'all-transits-fit'), ...
            sprintf('%09d-%02d-all-whitened.fig', keplerId, planetNumber), ...
            WIDTH, HALF_HEIGHT);
        
        generate_figures(['allWhitenedZoomed' safePlanetNumber], planetNumber, ...
            fullfile('planet-search-and-model-fitting-results', 'all-transits-fit'), ...
            sprintf('%09d-%02d-all-whitened-zoomed.fig', keplerId, planetNumber), ...
            WIDTH, HALF_HEIGHT);
    end

%% Generate data and images used by reduced-parameter-fit-results.tex
%
    function generate_model_fitter_reduced_parameter(planetResultsStruct)
        fprintf('    Reduced parameter fit\n');
        [planetNumber, safePlanetNumber] = getPlanetNumber(planetResultsStruct);
        
        reducedParameterFitsAvailable = 'true';
        if (length(planetResultsStruct.reducedParameterFits) == 0)
            reducedParameterFitsAvailable = 'false';
        end
        report_add_string(fid, ['reducedParameterFitsAvailable' safePlanetNumber], ...
            reducedParameterFitsAvailable);
        
        if (~reducedParameterFitsAvailable)
            return;
        end
        
        [startTable, endTable, allReducedParameterFitsFailed] = ...
            generate_reduced_parameter_fit_results_tables( ...
            planetResultsStruct.reducedParameterFits);
        
        report_add_string(fid, ['allReducedParameterFitsFailed' safePlanetNumber], ...
            allReducedParameterFitsFailed);
        
        report_add_table(reportDir, ...
            sprintf(REDUCED_PARAMETER_FIT_RESULTS, planetNumber, 'start'), ...
            startTable);
        report_add_table(reportDir, ...
            sprintf(REDUCED_PARAMETER_FIT_RESULTS, planetNumber, 'end'), ...
            endTable);
        
        % Generate figures.
        
        generate_figures(['reducedParameterFitsModelChiSquare' safePlanetNumber], planetNumber, ...
            fullfile('planet-search-and-model-fitting-results', 'reduced-parameter-fits'), ...
            sprintf('%09d-%02d-reduced-fits-chi-square.fig', keplerId, planetNumber), ...
            WIDTH, QUARTER_HEIGHT);
        
        generate_figures(['reducedParameterFitsRatioPlanetRadiusToStarRadius' safePlanetNumber], planetNumber, ...
            fullfile('planet-search-and-model-fitting-results', 'reduced-parameter-fits'), ...
            sprintf('%09d-%02d-reduced-fits-rp-over-rstar.fig', keplerId, planetNumber), ...
            WIDTH, QUARTER_HEIGHT);
        
        generate_figures(['reducedParameterFitsRatioSemiMajorAxisToStarRadius' safePlanetNumber], planetNumber, ...
            fullfile('planet-search-and-model-fitting-results', 'reduced-parameter-fits'), ...
            sprintf('%09d-%02d-reduced-fits-a-over-rstar.fig', keplerId, planetNumber), ...
            WIDTH, QUARTER_HEIGHT);
    end

%% Generate data and images used by trapezoidal-model-fit.tex
%
    function generate_trapezoidal_model_fitter(planetResultsStruct)
        fprintf('    Trapezoidal model fitter\n');
        [planetNumber, safePlanetNumber] = getPlanetNumber(planetResultsStruct);

        report_add_string(fid, ['trapezoidalModelFitTransitModel' safePlanetNumber], ...
            planetResultsStruct.trapezoidalFit.transitModelName);
        report_add_string(fid, ['trapezoidalModelFitLimbDarkeningModel' safePlanetNumber], ...
            planetResultsStruct.trapezoidalFit.limbDarkeningModelName);

        trapezoidalModelFitAvailable = 'true';
        if (planetResultsStruct.trapezoidalFit.modelChiSquare == -1)
            trapezoidalModelFitAvailable = 'false';
        end
        report_add_string(fid, ['trapezoidalModelFitAvailable' safePlanetNumber], ...
            trapezoidalModelFitAvailable);
        if (~trapezoidalModelFitAvailable)
            return;
        end
        
        table = generate_trapezoidal_model_fit_results_table( ...
            planetResultsStruct.trapezoidalFit);
        
        report_add_table(reportDir, ...
            sprintf(TRAPEZOIDAL_MODEL_FIT_RESULTS, planetNumber), ...
            table);
        
        % Generate figures.
        generate_figures(['allTrapezoidal' safePlanetNumber], planetNumber, ...
            fullfile('planet-search-and-model-fitting-results', 'trapezoidal-model-fit'), ...
            sprintf('%09d-%02d-all-trapezoidal.fig', keplerId, planetNumber), ...
            WIDTH, HALF_HEIGHT);
        
        generate_figures(['allTrapezoidalZoomed' safePlanetNumber], planetNumber, ...
            fullfile('planet-search-and-model-fitting-results', 'trapezoidal-model-fit'), ...
            sprintf('%09d-%02d-all-trapezoidal-zoomed.fig', keplerId, planetNumber), ...
            WIDTH, HALF_HEIGHT);
    end

%% Generate data and images used by validation.tex.
%
    function generate_validation_tests(planetResultsStruct)
        fprintf('    Validation tests\n');

        [planetNumber, safePlanetNumber] = getPlanetNumber(planetResultsStruct);
        
        table = generate_centroid_table(...
            planetResultsStruct.centroidResults.fluxWeightedMotionResults, ...
            targetStruct.keplerMag);
        report_add_table(reportDir, ...
            sprintf(FLUX_WEIGHTED_CENTROID_TEST, planetNumber), table);
        
        table = generate_ebd_table(...
            planetResultsStruct.binaryDiscriminationResults);
        report_add_table(reportDir, ...
            sprintf(ECLIPSING_BINARY_DISCRIMINATION_TEST, planetNumber), table);

        weakSecondaryTestEnabled = dvDataObject.dvConfigurationStruct.weakSecondaryTestEnabled;

        if weakSecondaryTestEnabled && ...
                planetResultsStruct.planetCandidate.weakSecondaryStruct.mesMad ~= -1
            table = generate_weak_secondary_results_table(planetResultsStruct);
            report_add_table(reportDir, ...
                sprintf(WEAK_SECONDARY_RESULTS, planetNumber), table);
        end
        
        table = generate_bootstrap_table(planetResultsStruct);
        report_add_table(reportDir, ...
            sprintf(BOOTSTRAP_TEST, planetNumber), table);
        
        table = generate_ghost_diagnostic_table(planetResultsStruct);
        report_add_table(reportDir, ...
            sprintf(GHOST_DIAGNOSTIC_TEST, planetNumber), table);
        
        generate_figures(...
            ['weakSecondaryDiagnostic' safePlanetNumber], ...
            planetNumber, 'report-summary', ...
            sprintf('%09d-%02d-weak-secondary-diagnostic.fig', ...
            keplerId, planetNumber), WIDTH, HEIGHT);
        
        generate_figures(...
            ['centroidTestSourceOffsets' safePlanetNumber], ...
            planetNumber, 'centroid-test-results', ...
            sprintf('%09d-%02d-centroid-test-source-offsets.fig', ...
            keplerId, planetNumber), WIDTH, HEIGHT);
        
        generate_figures(...
            ['foldedTransitFitFluxWeightedCentroids' safePlanetNumber], ...
            planetNumber, 'centroid-test-results', ...
            sprintf('%09d-%02d-folded-transit-fit-fluxWeighted-centroids.fig', ...
            keplerId, planetNumber), WIDTH, HEIGHT);
        
        generate_figures(...
            ['transitFitFluxWeightedCentroids' safePlanetNumber], ...
            planetNumber, 'centroid-test-results', ...
            sprintf('%09d-%02d-transit-fit-fluxWeighted-centroids-*.fig', ...
            keplerId, planetNumber), WIDTH, HEIGHT);
        
        generate_figures(...
            ['bootstrapFalseAlarmPlot' safePlanetNumber], ...
            planetNumber, 'bootstrap-results', ...
            sprintf('%09d-%02d-bootstrap-false-alarm.fig', ...
            keplerId, planetNumber), WIDTH, HEIGHT);
    end

%% Generate data and images in per-planet appendix sections.
%
    function generate_per_planet_data_app()
        for iPlanet = 1:length(planetResultsStruct)
            fprintf('  Planet #%d of %d\n', iPlanet, length(planetResultsStruct));
            generate_model_fitter_all_app(planetResultsStruct(iPlanet));
            generate_model_fitter_oddeven_app(planetResultsStruct(iPlanet));
            generate_eclipsing_binary_discrimination_test_app(planetResultsStruct(iPlanet));
        end
    end

%% Generate images used by model-fitter-all-app.tex.
%
    function generate_model_fitter_all_app(planetResultsStruct)
        fprintf('    Model fitter (all)\n');

        [planetNumber, safePlanetNumber] = getPlanetNumber(planetResultsStruct);

        generate_figures(['allRobustWeights' safePlanetNumber], planetNumber, ...
            fullfile('planet-search-and-model-fitting-results', 'all-transits-fit'), ...
            sprintf('%09d-%02d-all-robust-weights.fig', keplerId, planetNumber), ...
            WIDTH, HEIGHT);

        generate_figures(['allHistoUsed' safePlanetNumber], planetNumber, ...
            fullfile('planet-search-and-model-fitting-results', 'all-transits-fit'), ...
            sprintf('%09d-%02d-all-histo-used.fig', keplerId, planetNumber), ...
            WIDTH, THIRD_HEIGHT+0.05);
        
        generate_figures(['allHistoAllAndUnused' safePlanetNumber], planetNumber, ...
            fullfile('planet-search-and-model-fitting-results', 'all-transits-fit'), ...
            sprintf('%09d-%02d-all-histo-all-and-unused.fig', keplerId, planetNumber), ...
            WIDTH, TWO_THIRDS_HEIGHT);
    end

%% Generate data and images used by model-fitter-oddeven-app.tex.
%
    function generate_model_fitter_oddeven_app(planetResultsStruct)
        fprintf('    Model fitter (odd/even)\n');

        [planetNumber, safePlanetNumber] = getPlanetNumber(planetResultsStruct);

        oddFullConvergence = 'true';
        evenFullConvergence = 'true';
        modelFitFailed = 'false';
        table = generate_fitter_results_table(planetResultsStruct, 'oddEven');
        if (planetResultsStruct.oddTransitsFit.modelChiSquare > 0 ...
            && planetResultsStruct.evenTransitsFit.modelChiSquare > 0)
            report_add_table(reportDir, ...
                sprintf(ODDEVEN_TRANSITS_FIT_RESULTS, planetNumber), table);
            if (~planetResultsStruct.oddTransitsFit.fullConvergence)
                oddFullConvergence = 'false';
            end
            if (~planetResultsStruct.evenTransitsFit.fullConvergence)
                evenFullConvergence = 'false';
            end
        elseif (planetResultsStruct.planetCandidate.suspectedEclipsingBinary)
            report_add_table(reportDir, ...
                sprintf(ODDEVEN_TRANSITS_FIT_RESULTS, planetNumber), table);
        elseif (~planetResultsStruct.planetCandidate.statisticRatioBelowThreshold)
            modelFitFailed = 'true';
        end
        
        % Strings for suspectedEclipsingBinary and belowMesSesThreshold
        % have already been written by model_fitter_all().
        report_add_string(fid, ['oddFullConvergence' safePlanetNumber], oddFullConvergence);
        report_add_string(fid, ['evenFullConvergence' safePlanetNumber], evenFullConvergence);
        report_add_string(fid, ['oddEvenModelFitFailed' safePlanetNumber], modelFitFailed);

        % Remove -filtered-zoomed and -zoomed figure names as they will be
        % displayed separately.
        generate_figures(['oddEvenUnwhitened' safePlanetNumber], planetNumber, ...
            fullfile('planet-search-and-model-fitting-results', 'odd-even-transits-fit'), ...
            sprintf('%09d-%02d-odd-even-unwhitened-*.fig', keplerId, planetNumber), ...
            WIDTH, HEIGHT, '-zoomed.fig');
        
        generate_figures(['oddEvenUnwhitenedFilteredZoomed' safePlanetNumber], planetNumber, ...
            fullfile('planet-search-and-model-fitting-results', 'odd-even-transits-fit'), ...
            sprintf('%09d-%02d-odd-even-unwhitened-filtered-zoomed.fig', keplerId, planetNumber), ...
            WIDTH, HALF_HEIGHT);
        
        generate_figures(['oddEvenUnwhitenedZoomed' safePlanetNumber], planetNumber, ...
            fullfile('planet-search-and-model-fitting-results', 'odd-even-transits-fit'), ...
            sprintf('%09d-%02d-odd-even-unwhitened-zoomed.fig', keplerId, planetNumber), ...
            WIDTH, HALF_HEIGHT);
        
        generate_figures(['oddEvenWhitened' safePlanetNumber], planetNumber, ...
            fullfile('planet-search-and-model-fitting-results', 'odd-even-transits-fit'), ...
            sprintf('%09d-%02d-odd-even-whitened.fig', keplerId, planetNumber), ...
            WIDTH, HEIGHT);
        
        generate_figures(['oddEvenWhitenedZoomed' safePlanetNumber], planetNumber, ...
            fullfile('planet-search-and-model-fitting-results', 'odd-even-transits-fit'), ...
            sprintf('%09d-%02d-odd-even-whitened-zoomed.fig', keplerId, planetNumber), ...
            WIDTH, HEIGHT);

        generate_figures(['oddEvenRobustWeights' safePlanetNumber], planetNumber, ...
            fullfile('planet-search-and-model-fitting-results', 'odd-even-transits-fit'), ...
            sprintf('%09d-%02d-odd-even-robust-weights.fig', keplerId, planetNumber), ...
            WIDTH, HEIGHT);

        generate_figures(['oddEvenHistoUsed' safePlanetNumber], planetNumber, ...
            fullfile('planet-search-and-model-fitting-results', 'odd-even-transits-fit'), ...
            sprintf('%09d-%02d-odd-even-histo-used.fig', keplerId, planetNumber), ...
            WIDTH, THIRD_HEIGHT+0.05);
        
        generate_figures(['oddEvenHistoAllAndUnused' safePlanetNumber], planetNumber, ...
            fullfile('planet-search-and-model-fitting-results', 'odd-even-transits-fit'), ...
            sprintf('%09d-%02d-odd-even-histo-all-and-unused.fig', keplerId, planetNumber), ...
            WIDTH, TWO_THIRDS_HEIGHT);
    end

%% Generate image used by binary-discrimination-test-results-app.tex.
%
    function generate_eclipsing_binary_discrimination_test_app(planetResultsStruct)
        fprintf('    Binary discrimination test\n');

        [planetNumber, safePlanetNumber] = getPlanetNumber(planetResultsStruct);

        generate_figures(['binaryDiscriminationTestResults' safePlanetNumber], ...
            planetNumber, 'binary-discrimination-test-results', ...
            sprintf('%09d-%02d-eclipsing-binary-discrimination-tests.fig', ...
            keplerId, planetNumber), WIDTH, HEIGHT);
    end

%% Generate images used by single-event-statistics-app.tex.
%
    function generate_single_event_statistics_app()
        fprintf('  Single event statistics\n');

        generate_figures('singleEventStatistics', 0, 'summary-plots', ...
            sprintf('%09d-00-residual-ses-*.fig', keplerId), WIDTH, HEIGHT);
    end

%% Generate tables used by alerts-app.tex.
%
    function generate_alerts_app(alertsTable)
        fprintf('  Alerts\n');

        report_add_table(reportDir, ALERTS, alertsTable);
    end

%% Define common functions.
%
    function figureMacros = generate_figures(...
            name, planet, directory, pattern, widthPercent, heightPercent, excludePattern)

        figureNames = generate_figure_names(figureRootDirectory, ...
            planet, directory, pattern);
        if (exist('excludePattern', 'var'))
            figureNames(~cellfun(@isempty, strfind(figureNames, excludePattern))) = [];
        end
        
        figureMacros = '';
        for i = 1:length(figureNames)
            [dir, basename, ~] = fileparts(figureNames{i});
            figureMacro = report_add_figure(...
                reportDir, fid, basename, figureRootDirectory, ...
                fullfile(strrep(dir, [figureRootDirectory filesep], ''), basename), ...
                widthPercent, heightPercent, true);
            figureMacros = appendCsvValue(figureMacros, figureMacro);
        end
        if (~isempty(name))
            report_add_string(fid, name, figureMacros, false);
        end
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

    function [planetNumber, safePlanetNumber] = getPlanetNumber(planetResultsStruct)
        planetNumber = planetResultsStruct.planetNumber;
        safePlanetNumber = report_latex_safe(num2str(planetNumber));
    end

    function [quarter, targetTableId, safeTargetTableId] = getTargetTableId(targetTableDataStruct)
        quarter = targetTableDataStruct.quarter;
        targetTableId = targetTableDataStruct.targetTableId;
        safeTargetTableId = report_latex_safe(num2str(targetTableId));
    end
end
