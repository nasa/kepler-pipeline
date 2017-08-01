function [dvResultsStruct] = dv_generate_report_summaries(dvDataObject, ...
dvResultsStruct, usedDefaultValuesStruct)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [dvResultsStruct] = dv_generate_report_summaries(dvDataObject, ...
% dvResultsStruct, usedDefaultValuesStruct)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Create brief report summaries per target and planet candidate as single
% Matlab figure with sub-plots. Save as Matlab FIG in 'report-summary'
% subdirectory for given planet candidate. Update and return DV results
% structure with detrended flux time series for each planet candidate.
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

% Define constants.
KEPLER_MAG_CUTOFF = 12.0;
PLANET_RADIUS_CUTOFF = 20.0;
FONT_SIZE = 10;
N_TRANSIT_TIMES_ZOOM = 6;
N_TRANSIT_TIMES_ZOOM_FOR_SECONDARY = 12;

% Get fields from DV data object.
softwareRevision = dvDataObject.softwareRevision;
externalTceModelDescription = dvDataObject.externalTceModelDescription;
searchTransitThreshold = ...
    dvDataObject.tpsConfigurationStruct.searchTransitThreshold;
weakSecondaryTestEnabled = ...
    dvDataObject.dvConfigurationStruct.weakSecondaryTestEnabled;
externalTcesEnabled = ...
    dvDataObject.dvConfigurationStruct.externalTcesEnabled;

% Loop over the targets and planet candidates.
nTargets = length(dvResultsStruct.targetResultsStruct);

for iTarget = 1 : nTargets
    
    % Get the keplerId, stellar parameters and figures root directory.
    keplerId = dvDataObject.targetStruct(iTarget).keplerId;
    keplerMag = dvDataObject.targetStruct(iTarget).keplerMag.value;
    
    fprintf('DV:Report Summaries:Processing target #%d of %d, keplerId %d\n', ...
        iTarget, nTargets, keplerId);
    
    if keplerMag < KEPLER_MAG_CUTOFF
        keplerMagColor = 'red';
    else
        keplerMagColor = 'black';
    end % if / else
    
    stellarRadiusValue = ...
        dvDataObject.targetStruct(iTarget).radius.value;
    effectiveTempValue = ...
        dvDataObject.targetStruct(iTarget).effectiveTemp.value;
    log10SurfaceGravityValue = ...
        dvDataObject.targetStruct(iTarget).log10SurfaceGravity.value;
    log10MetallicityValue = ...
        dvDataObject.targetStruct(iTarget).log10Metallicity.value;
    
    if usedDefaultValuesStruct(iTarget).radiusReplaced
        stellarRadiusColor = 'red';
    else
        stellarRadiusColor = 'black';
    end % if / else
    if usedDefaultValuesStruct(iTarget).effectiveTempReplaced
        effectiveTempColor = 'red';
    else
        effectiveTempColor = 'black';
    end % if / else
    if usedDefaultValuesStruct(iTarget).log10SurfaceGravityReplaced
        log10SurfaceGravityColor = 'red';
    else
        log10SurfaceGravityColor = 'black';
    end % if / else
    if usedDefaultValuesStruct(iTarget).log10MetallicityReplaced
        log10MetallicityColor = 'red';
    else
        log10MetallicityColor = 'black';
    end % if / else
    
    if isfield(dvResultsStruct.targetResultsStruct(iTarget), ...
            'dvFiguresRootDirectory')
        dvFiguresRootDirectory = ...
            dvResultsStruct.targetResultsStruct(iTarget).dvFiguresRootDirectory;
    else
        dvFiguresRootDirectory = ...
            sprintf('target-%09d', targetStruct(iTarget).keplerId);
    end % if / else
    
    nPlanets = ...
        length(dvResultsStruct.targetResultsStruct(iTarget).planetResultsStruct);
    
    for iPlanet = 1 : nPlanets
        
        % Print message.
        fprintf('  Planet #%d of %d\n', iPlanet, nPlanets);
    
        % Get the MES and weak secondary results.
        targetResultsStruct = ...
            dvResultsStruct.targetResultsStruct(iTarget);
        planetResultsStruct = ...
            targetResultsStruct.planetResultsStruct(iPlanet);
        multipleEventStatistic = ...
            planetResultsStruct.planetCandidate.maxMultipleEventSigma;
        weakSecondaryStruct = ...
            planetResultsStruct.planetCandidate.weakSecondaryStruct;
        
        % Get the fit results.
        allTransitsFit = planetResultsStruct.allTransitsFit;
        modelChiSquare = allTransitsFit.modelChiSquare;
        modelDegreesOfFreedom = allTransitsFit.modelDegreesOfFreedom;
        modelFitSnr = allTransitsFit.modelFitSnr;
        modelParameters = allTransitsFit.modelParameters;
        
        [periodStruct] = retrieve_model_parameter(...
            modelParameters, 'orbitalPeriodDays');
        [epochStruct] = retrieve_model_parameter(...
            modelParameters, 'transitEpochBkjd');
        
        if modelChiSquare ~= -1
            
            [reducedRadiusStruct] = retrieve_model_parameter(...
                modelParameters, 'ratioPlanetRadiusToStarRadius');
            [reducedSemiMajorAxisStruct] = retrieve_model_parameter(...
                modelParameters, 'ratioSemiMajorAxisToStarRadius');
            [impactParameterStruct] = retrieve_model_parameter(...
                modelParameters, 'minImpactParameter');
            [depthStruct] = retrieve_model_parameter(...
                modelParameters, 'transitDepthPpm');
            [semiMajorAxisStruct] = retrieve_model_parameter(...
                modelParameters, 'semiMajorAxisAu');
            [planetRadiusStruct] = retrieve_model_parameter(...
                modelParameters, 'planetRadiusEarthRadii');
            [equilibriumTempStruct] = retrieve_model_parameter(...
                modelParameters, 'equilibriumTempKelvin');
            [stellarFluxStruct, stellarFluxMatch] = ...
                retrieve_model_parameter(...
                modelParameters, 'effectiveStellarFlux');
            
            observedTransitCount = ...
                planetResultsStruct.planetCandidate.observedTransitCount;
            
        end % if
        
        % Get remaining diagnostic test results for the given planet
        % candidate.
        binaryDiscriminationResults = ...
            planetResultsStruct.binaryDiscriminationResults;
        fluxWeightedMotionResults = ...
            planetResultsStruct.centroidResults.fluxWeightedMotionResults;
        differenceImageMotionResults = ...
            planetResultsStruct.centroidResults.differenceImageMotionResults;
        differenceImageResults = ...
            planetResultsStruct.differenceImageResults;
        secondaryEventResults = ...
            planetResultsStruct.secondaryEventResults;
        
        % Detrend the initial flux time series for the given planet
        % candidate and update the results structure.
        [dvResultsStruct] = ...
            detrend_initial_flux_time_series(dvDataObject, ...
            dvResultsStruct, iTarget, iPlanet);
        
        % Generate a figure displaying the detrended initial flux time
        % series for the given planet candidate with markers indicating the
        % times of transit and quarterly boundaries.
        plot_filtered_flux_time_series(dvDataObject, dvResultsStruct, ...
            iTarget, iPlanet);
        
        % Generate a figure displaying the detrended initial flux time
        % series folded with model overly. Update the results structure
        % with the folded phase time series for the given planet.
        [dvResultsStruct] = ...
            plot_filtered_folded_flux_time_series_with_model_overlay( ...
            dvDataObject, dvResultsStruct, iTarget, iPlanet);
        
        % Generate a figure displaying the detrended initial flux time
        % series folded and zoomed with model overlay.
        plot_filtered_zoomed_flux_time_series_with_model_overlay( ...
            dvDataObject, dvResultsStruct, iTarget, iPlanet, ...
            N_TRANSIT_TIMES_ZOOM);
        
        % Generate a figure displaying the detrended initial flux time
        % series folded and zoomed on the weak secondary.
        plot_filtered_zoomed_flux_time_series_for_secondary( ...
            dvDataObject, dvResultsStruct, iTarget, iPlanet, ...
            N_TRANSIT_TIMES_ZOOM_FOR_SECONDARY);
        
        % Generate a figure displaying the detrended initial flux time
        % series separately folded for the odd and even transits.
        plot_filtered_zoomed_odd_even_flux_time_series(dvDataObject, ...
            dvResultsStruct, iTarget, iPlanet, N_TRANSIT_TIMES_ZOOM);
        
        % Create new figure with subplots.
        figure;
        set(gcf, 'Units', 'inches');
        set(gcf, 'Position', [1, 1, 17.0, 11.0]);
        set(gcf, 'PaperPositionMode', 'auto');
        set(gcf, 'PaperType', 'tabloid');
        
        a1 = subplot(4, 3, [1, 3], 'Box', 'on', 'XTick', [], 'YTick', []);
        a2 = subplot(4, 3, [4, 5], 'Box', 'on', 'XTick', [], 'YTick', []);
        a3 = subplot(4, 3, 6, 'Box', 'on', 'XTick', [], 'YTick', []);
        a4 = subplot(4, 3, [7, 8], 'Box', 'on', 'XTick', [], 'YTick', []);
        a5 = subplot(4, 3, 9, 'Box', 'on', 'XTick', [], 'YTick', []);
        a6 = subplot(4, 3, 10, 'Box', 'on', 'XTick', [], 'YTick', []);
        a7 = subplot(4, 3, 11, 'Box', 'on', 'XTick', [], 'YTick', []);
        a8 = subplot(4, 3, 12, 'Box', 'off');
        
        % Retrieve the desired summary figures and copy to subplots.
        planetDir = sprintf('planet-%02d', iPlanet);
        
        % Subplot 1.
        titleString = sprintf('{\\color{%s}Kp: %.2f}    {\\color{%s}R*: %.2f Rs}    {\\color{%s}Teff: %.1f K}    {\\color{%s}Logg: %.2f}    {\\color{%s}Fe/H: %.3f}', ...
            keplerMagColor, keplerMag, ...
            stellarRadiusColor, stellarRadiusValue, ...
            effectiveTempColor, effectiveTempValue, ...
            log10SurfaceGravityColor, log10SurfaceGravityValue, ...
            log10MetallicityColor, log10MetallicityValue);
        figureName = fullfile(dvFiguresRootDirectory, planetDir, ...
            'report-summary', ...
            sprintf('%09d-%02d-all-unwhitened-filtered.fig', ...
            keplerId, iPlanet));
        copy_figure_to_subplot(a1, figureName, 1, FONT_SIZE, titleString);
        
        % Subplot 2.
        figureName = fullfile(dvFiguresRootDirectory, planetDir, ...
            'report-summary', ...
            sprintf('%09d-%02d-all-unwhitened-filtered-model.fig', ...
            keplerId, iPlanet));
        copy_figure_to_subplot(a2, figureName, 1, FONT_SIZE, ' ');
        
        % Subplot 3.
        figureName = fullfile(dvFiguresRootDirectory, planetDir, ...
            'report-summary', ...
            sprintf('%09d-%02d-all-unwhitened-filtered-zoomed-secondary.fig', ...
            keplerId, iPlanet));
        if weakSecondaryStruct.maxMes > searchTransitThreshold
            secondaryColor = 'red';
        else
            secondaryColor = 'black';
        end % if / else
        if weakSecondaryTestEnabled && weakSecondaryStruct.mesMad ~= -1
            if weakSecondaryStruct.depthPpm.uncertainty ~= -1
                titleString1 = sprintf('Sec Depth: %.1f [%.1f] ppm', ...
                    weakSecondaryStruct.depthPpm.value, ...
                    weakSecondaryStruct.depthPpm.uncertainty);
            else
                titleString1 = '';
            end % if / else
            titleString2 = sprintf('Sec Phase: %.3f Days   {\\color{%s}Sec MES: %.1f}', ...
                weakSecondaryStruct.maxMesPhaseInDays, ...
                secondaryColor, weakSecondaryStruct.maxMes);
        else
            titleString1 = '';
            titleString2 = sprintf('Sec Phase: %.3f Days   Sec MES: N/A', ...
                weakSecondaryStruct.maxMesPhaseInDays);
        end % if / else
        if ~isempty(titleString1)
            titleString = {titleString1; titleString2};
        else
            titleString = titleString2;
        end % if / else
        copy_figure_to_subplot(a3, figureName, 1, FONT_SIZE, titleString);
         
        % Subplot 4.
        figureName = fullfile(dvFiguresRootDirectory, planetDir, ...
            'report-summary', ...
            sprintf('%09d-%02d-all-unwhitened-filtered-zoomed-model.fig', ...
            keplerId, iPlanet));
        copy_figure_to_subplot(a4, figureName, 1, FONT_SIZE, ' ');
        
        % Subplot 5.
        titleString1 = sprintf('MES: %.1f', multipleEventStatistic);
        if modelChiSquare ~= -1
            if modelFitSnr < searchTransitThreshold
                snrColor = 'red';
            else
                snrColor = 'black';
            end % if / else
            titleString1 = [titleString1, sprintf('    Transits: %d', ...
                observedTransitCount)];                                                     %#ok<AGROW>
            titleString2 = sprintf('{\\color{%s}SNR: %.1f}    \\chi^2/DoF: %.1f    Depth: %.1f [%.1f] ppm', ...
                snrColor, modelFitSnr, ...
                modelChiSquare / modelDegreesOfFreedom, ...
                depthStruct.value, depthStruct.uncertainty);
        else
            titleString2 = '';
        end % if / else
        if ~isempty(titleString2)
            titleString = {titleString1; titleString2};
        else
            titleString = titleString1;
        end % if / else
        figureName = fullfile(dvFiguresRootDirectory, planetDir, ...
            'planet-search-and-model-fitting-results', 'all-transits-fit', ...
            sprintf('%09d-%02d-all-whitened-zoomed-summary.fig', ...
            keplerId, iPlanet)); 
        copy_figure_to_subplot(a5, figureName, 1, FONT_SIZE, titleString, ...
            [], [], [], true);
        set(get(a5, 'Children'), 'MarkerSize', 6.0);
        
        % Subplot 6.
        oddEvenTransitDepthComparisonStatistic = ...
            binaryDiscriminationResults.oddEvenTransitDepthComparisonStatistic;
        significance = oddEvenTransitDepthComparisonStatistic.significance;
        value = oddEvenTransitDepthComparisonStatistic.value;
        titleString = generate_significance_string(significance, value, ...
            'Depth-sig', 'Depth-sig: N/A');
        figureName = fullfile(dvFiguresRootDirectory, planetDir, ...
            'report-summary', ...
            sprintf('%09d-%02d-odd-even-unwhitened-filtered-zoomed.fig', ...
            keplerId, iPlanet)); 
        copy_figure_to_subplot(a6, figureName, 1, FONT_SIZE, titleString);
        
        % Subplot 7.
        titleString = {'Difference Image';'Out of Transit Centroid Offsets'};
        figureName = fullfile(dvFiguresRootDirectory, planetDir, ...
            'difference-image', ...
            sprintf('%09d-%02d-difference-image-centroid-offsets.fig', ...
            keplerId, iPlanet));
        copy_figure_to_subplot(a7, figureName, 3, FONT_SIZE, titleString);
        
        % Subplot 8.
        set(a8, 'XTick', [], 'YTick', []);
        
        if modelChiSquare ~= -1
            
            text(-0.10, 1.10, 'DV Fit Results:');
            string = sprintf('Period = %.5f [%.5f] d', ...
                periodStruct.value, periodStruct.uncertainty);
            text(-0.10, 0.95, string);
            string = sprintf('Epoch = %.4f [%.4f] BKJD', ...
                epochStruct.value, epochStruct.uncertainty);
            text(-0.10, 0.85, string);
            string = sprintf('Rp/R* = %.4f [%.4f]', ...
                reducedRadiusStruct.value, reducedRadiusStruct.uncertainty);
            text(-0.10, 0.75, string);
            string = sprintf('a/R* = %.2f [%.2f]', ...
                reducedSemiMajorAxisStruct.value, ...
                reducedSemiMajorAxisStruct.uncertainty);
            text(-0.10, 0.65, string);
            string = sprintf('b = %.2f [%.2f]', ...
                impactParameterStruct.value, ...
                impactParameterStruct.uncertainty);
            text(-0.10, 0.55, string);
            
            if stellarFluxMatch && stellarFluxStruct.uncertainty ~= -1
                string = sprintf('Seff = %.2f [%.2f]', ...
                    stellarFluxStruct.value, ...
                    stellarFluxStruct.uncertainty);
            else
                string = sprintf('Seff = N/A');
            end % if / else
            text(-0.10, 0.40, string);
            if equilibriumTempStruct.uncertainty ~= -1
                string = sprintf('Teq = %.0f [%.0f] K', ...
                    equilibriumTempStruct.value, ...
                    equilibriumTempStruct.uncertainty);
            else
                string = sprintf('Teq = N/A');
            end
            text(-0.10, 0.30, string);
            if planetRadiusStruct.uncertainty ~= -1
                if planetRadiusStruct.value >= PLANET_RADIUS_CUTOFF
                    planetRadiusColor = 'red';
                else
                    planetRadiusColor = 'black';
                end % if / else
                string = sprintf('{\\color{%s}Rp = %.2f [%.2f] Re}', ...
                    planetRadiusColor, ...
                    planetRadiusStruct.value, ...
                    planetRadiusStruct.uncertainty);
            else
                string = sprintf('Rp = N/A');
            end
            text(-0.10, 0.20, string);
            if semiMajorAxisStruct.uncertainty ~= -1
                string = sprintf('a = %.4f [%.4f] AU', ...
                    semiMajorAxisStruct.value, ...
                    semiMajorAxisStruct.uncertainty);
            else
                string = sprintf('a = N/A');
            end
            text(-0.10, 0.10, string);
            
            if weakSecondaryTestEnabled && weakSecondaryStruct.mesMad ~= -1
                
                planetParameters = secondaryEventResults.planetParameters;
                comparisonTests = secondaryEventResults.comparisonTests;
                
                geometricAlbedo = planetParameters.geometricAlbedo;
                albedoComparisonStatistic = comparisonTests.albedoComparisonStatistic;
                if albedoComparisonStatistic.significance ~= -1
                    if albedoComparisonStatistic.value > 3 && ...
                            weakSecondaryStruct.maxMes > searchTransitThreshold
                        geometricAlbedoColor = 'red';
                    else
                        geometricAlbedoColor = 'black';
                    end % if / else
                    string = sprintf('{\\color{%s}Ag = %.2f [%.2f]  [%.2f\\sigma]}', ...
                        geometricAlbedoColor, ...
                        geometricAlbedo.value, ...
                        geometricAlbedo.uncertainty, ...
                        albedoComparisonStatistic.value);
                else
                    string = sprintf('Ag = N/A');
                end % if / else
                text(-0.10, -0.05, string);
                
                planetEffectiveTemp = planetParameters.planetEffectiveTemp;
                tempComparisonStatistic = comparisonTests.tempComparisonStatistic;
                if tempComparisonStatistic.significance ~= -1
                    if tempComparisonStatistic.value > 3 && ...
                            weakSecondaryStruct.maxMes > searchTransitThreshold
                        planetEffectiveTempColor = 'red';
                    else
                        planetEffectiveTempColor = 'black';
                    end % if / else
                    string = sprintf('{\\color{%s}Teffp = %.0f [%.0f] K  [%.2f\\sigma]}', ...
                        planetEffectiveTempColor, ...
                        planetEffectiveTemp.value, ...
                        planetEffectiveTemp.uncertainty, ...
                        tempComparisonStatistic.value);
                else
                    string = sprintf('Teffp = N/A');
                end % if / else
                text(-0.10, -0.15, string);
                
            end % if
            
        else
            
            text(-0.10, 1.10, 'TPS TCE Results:');
            string = sprintf('Period = %.5f d', periodStruct.value);
            text(-0.10, 0.95, string);
            string = sprintf('Epoch = %.4f BKJD', epochStruct.value);
            text(-0.10, 0.85, string);
            text(-0.10, 0.65, 'DV fit results are unavailable', ...
                'Color', 'red');
            
        end % if / else
        
        text(0.55, 1.10, 'DV Diagnostic Results:');
        shorterPeriodComparisonStatistic = ...
            binaryDiscriminationResults.shorterPeriodComparisonStatistic;
        significance = shorterPeriodComparisonStatistic.significance;
        value = shorterPeriodComparisonStatistic.value;
        text(0.55, 0.95, generate_significance_string( ...
            significance, value, 'ShortPeriod-sig', 'ShortPeriod-sig: N/A'));
        longerPeriodComparisonStatistic = ...
            binaryDiscriminationResults.longerPeriodComparisonStatistic;
        significance = longerPeriodComparisonStatistic.significance;
        value = longerPeriodComparisonStatistic.value;
        text(0.55, 0.85, generate_significance_string( ...
            significance, value, 'LongPeriod-sig', 'LongPeriod-sig: N/A'));
        modelChiSquare2 = ...
            planetResultsStruct.planetCandidate.modelChiSquare2;
        modelChiSquareDof2 = ...
            planetResultsStruct.planetCandidate.modelChiSquareDof2;
        if modelChiSquare2 ~= -1 && modelChiSquareDof2 ~= -1
            significance = 1 - chi2cdf(modelChiSquare2, modelChiSquareDof2);
        else
            significance = -1;
        end % if / else
        text(0.55, 0.75, generate_significance_string( ...
            significance, 0, 'ModelChiSquare2-sig', 'ModelChiSquare2-sig: N/A', true));
        modelChiSquareGof = ...
            planetResultsStruct.planetCandidate.modelChiSquareGof;
        modelChiSquareGofDof = ...
            planetResultsStruct.planetCandidate.modelChiSquareGofDof;
        if modelChiSquareGof ~= -1 && modelChiSquareGofDof ~= -1
            significance = 1 - chi2cdf(modelChiSquareGof, modelChiSquareGofDof);
        else
            significance = -1;
        end % if / else
        text(0.55, 0.65, generate_significance_string( ...
            significance, 0, 'ModelChiSquareGof-sig', 'ModelChiSquareGof-sig: N/A', true));
        bootstrapFalseAlarm = ...
            planetResultsStruct.planetCandidate.significance;
        if bootstrapFalseAlarm ~= -1
            if bootstrapFalseAlarm < 1e-12
                bootstrapColor = 'black';
            else
                bootstrapColor = 'red';
            end % if / else
            text(0.55, 0.55, sprintf('{\\color{%s}Bootstrap-pfa: %.2e}', ...
                bootstrapColor, bootstrapFalseAlarm));  
        else
            text(0.55, 0.55, 'Bootstrap-pfa: N/A');
        end % if / else
        rollingBandContaminationHistogram = ...
            planetResultsStruct.imageArtifactResults.rollingBandContaminationHistogram;
        fractionOfGoodTransits = rollingBandContaminationHistogram.transitFractions(1);
        if fractionOfGoodTransits ~= -1
            if fractionOfGoodTransits >= 0.8
                bootstrapColor = 'black';
            else
                bootstrapColor = 'red';
            end % if / else
            text(0.55, 0.45, sprintf('{\\color{%s}RollingBand-fgt: %.2f [%d/%d]}', ...
                bootstrapColor, fractionOfGoodTransits, ...
                rollingBandContaminationHistogram.transitCounts(1), ...
                sum(rollingBandContaminationHistogram.transitCounts)));  
        else
            text(0.55, 0.45, 'RollingBand-fgt: N/A');
        end % if / else
        ghostDiagnosticResults = planetResultsStruct.ghostDiagnosticResults;
        coreApertureCorrelationStatistic = ...
            ghostDiagnosticResults.coreApertureCorrelationStatistic;
        coreValue = coreApertureCorrelationStatistic.value;
        coreSignificance = coreApertureCorrelationStatistic.significance;
        haloApertureCorrelationStatistic = ...
            ghostDiagnosticResults.haloApertureCorrelationStatistic;
        haloValue = haloApertureCorrelationStatistic.value;
        haloSignificance = haloApertureCorrelationStatistic.significance;
        if coreSignificance ~= -1 && haloSignificance ~= -1 && ...
                haloValue ~= 0.0
            coreHaloRatio = coreValue / haloValue;
            if coreValue < haloValue
                color = 'red';
            else
                color = 'black';
            end
            string = sprintf('{\\color{%s}GhostDiagnostic-chr: %.4g}', ...
                color, coreHaloRatio);
        else
            string = sprintf('GhostDiagnostic-chr: N/A');
        end
        text(0.55, 0.35, string);
            
        significance =  ...
            fluxWeightedMotionResults.motionDetectionStatistic.significance;
        text(0.55, 0.20, generate_significance_string( ...
            significance, 0, 'Centroid-sig', 'Centroid-sig: N/A', true));
        sourceOffsetArcSec = ...
            fluxWeightedMotionResults.sourceOffsetArcSec;
        text(0.55, 0.10, generate_offset_string( ...
            sourceOffsetArcSec, 'Centroid-so', 'Centroid-so: N/A'));
        mqControlCentroidOffsets = ...
            differenceImageMotionResults.mqControlCentroidOffsets;
        mqKicCentroidOffsets = ...
            differenceImageMotionResults.mqKicCentroidOffsets;
        meanSkyOffset = mqControlCentroidOffsets.meanSkyOffset;
        text(0.55, 0.00, generate_offset_string( ...
             meanSkyOffset, 'OotOffset-rm', 'OotOffset-rm: N/A'));
        meanSkyOffset = mqKicCentroidOffsets.meanSkyOffset;
        text(0.55, -0.10, generate_offset_string( ...
            meanSkyOffset, 'KicOffset-rm', 'KicOffset-rm: N/A'));
        
        nValidControlOffsets = zeros(4, 1);
        nValidKicOffsets = zeros(4, 1);
        for iTable = 1 : length(differenceImageResults)
            quarter = differenceImageResults(iTable).quarter;
            if quarter ~= 0
                seasonIndex = 1 + mod(quarter-2, 4);
            else
                seasonIndex = 4;
            end % if / else [Q0 == S3]
            controlCentroidOffsets = ...
                differenceImageResults(iTable).controlCentroidOffsets;
            if controlCentroidOffsets.skyOffset.uncertainty ~= -1
                nValidControlOffsets(seasonIndex) = ...
                    nValidControlOffsets(seasonIndex) + 1;
            end % if
            kicCentroidOffsets = ...
                differenceImageResults(iTable).kicCentroidOffsets;
            if kicCentroidOffsets.skyOffset.uncertainty ~= -1
                nValidKicOffsets(seasonIndex) = ...
                    nValidKicOffsets(seasonIndex) + 1;
            end % if
        end % for iTable
        string = sprintf('OotOffset-st: %d/%d/%d/%d [%d]', ...
            nValidControlOffsets(1), nValidControlOffsets(2), ...
            nValidControlOffsets(3), nValidControlOffsets(4), ...
            sum(nValidControlOffsets));
        text(0.55, -0.20, string);
        string = sprintf('KicOffset-st: %d/%d/%d/%d [%d]', ...
            nValidKicOffsets(1), nValidKicOffsets(2), ...
            nValidKicOffsets(3), nValidKicOffsets(4), ...
            sum(nValidKicOffsets));
        text(0.55, -0.30, string);
        summaryQualityMetric = ...
            differenceImageMotionResults.summaryQualityMetric;
        if summaryQualityMetric.fractionOfGoodMetrics ~= -1
            string = sprintf('DiffImageQuality-fgm: %.2f [%d/%d]', ...
                summaryQualityMetric.fractionOfGoodMetrics, ...
                summaryQualityMetric.numberOfGoodMetrics, ...
                summaryQualityMetric.numberOfMetrics);
        else
            string = 'DiffImageQuality-fgm: N/A';
        end % if / else
        text(0.55, -0.40, string);
        summaryOverlapMetric = ...
            differenceImageMotionResults.summaryOverlapMetric;
        if summaryOverlapMetric.imageCountFractionNoOverlap ~= -1
            string = sprintf('DiffImageOverlap-fno: %.2f [%d/%d]', ...
                summaryOverlapMetric.imageCountFractionNoOverlap, ...
                summaryOverlapMetric.imageCountNoOverlap, ...
                summaryOverlapMetric.imageCount);
        else
            string = 'DiffImageOverlap-fno: N/A';
        end % if / else
        text(0.55, -0.50, string);
        axis(a8, 'off');
        
        % Add title.
        titleString1 = sprintf('KIC: %d     Candidate: %d of %d     Period: %.3f d', ...
            keplerId, iPlanet, nPlanets, periodStruct.value);
        if ~isempty(planetResultsStruct.koiId)
            if ~isempty(planetResultsStruct.keplerName)
                titleString2 = sprintf('KOI: %s     Name: %s     Corr: %.3f', ...
                    planetResultsStruct.koiId, planetResultsStruct.keplerName, ...
                    planetResultsStruct.koiCorrelation);
            else
                titleString2 = sprintf('KOI: %s     Corr: %.3f', ...
                    planetResultsStruct.koiId, ...
                    planetResultsStruct.koiCorrelation);
            end % if / else
        elseif ~isempty(targetResultsStruct.koiId)
            if ~isempty(targetResultsStruct.keplerName)
                titleString2 = sprintf('KOI: %s     Name: %s     Corr: No Ephemeris Match', ...
                    targetResultsStruct.koiId, targetResultsStruct.keplerName);
            else
                titleString2 = sprintf('KOI: %s     Corr: No Ephemeris Match', ...
                    targetResultsStruct.koiId);
            end % if / else
        else
            titleString2 = '';
        end % if / elseif / end

        axes('position', [0.1, 0.915, 0.8, .05], 'Box', 'off', 'Visible', 'off');
        title(titleString1);
        set(get(gca, 'Title'), 'Visible', 'on');
        set(get(gca, 'Title'), 'FontWeight', 'bold');
        
        if ~isempty(titleString2)
            axes('position', [0.1, 0.90, 0.8, .05], 'Box', 'off', 'Visible', 'off');
            title(titleString2);
            set(get(gca, 'Title'), 'Visible', 'on');
            set(get(gca, 'Title'), 'FontWeight', 'bold');
        end % if
        
        axes('position', [0.1, -0.02, 0.8, .05], 'Box', 'off', 'Visible', 'off');
        titleString = sprintf('Software Revision: %s    --    Date Generated: %s', ...
            softwareRevision, local_time_to_utc(now, 0));
        title(titleString);
        set(get(gca, 'Title'), 'Visible', 'on');
        set(get(gca, 'Title'), 'FontWeight', 'bold');
        
        axes('position', [0.1, -0.04, 0.8, .05], 'Box', 'off', 'Visible', 'off');
        if externalTcesEnabled
            titleString = sprintf('External TCE Model Description: %s', ...
                regexprep(externalTceModelDescription, '_', '\\_'));
        else
            titleString = ...
                sprintf('This Data Validation Report Summary was produced in the Kepler Science Operations Center Pipeline at NASA Ames Research Center');
        end % if
        title(titleString);
        set(get(gca, 'Title'), 'Visible', 'on');
        set(get(gca, 'Title'), 'FontWeight', 'bold');
        
        % Save the figure.
        if ~exist(fullfile(dvFiguresRootDirectory, planetDir, 'report-summary'), 'dir')
            mkdir(fullfile(dvFiguresRootDirectory, planetDir, 'report-summary'));
        end
        figureName = fullfile(dvFiguresRootDirectory, planetDir, ...
            'report-summary', ...
            sprintf('%09d-%02d-report-summary-plot', ...
            keplerId, iPlanet));
        saveas(gcf, [figureName, '.fig']);
        orient landscape
        set(gcf, 'Renderer', 'painters');
        set(gcf, 'RendererMode', 'manual');
        print('-dpdf', '-r75', [figureName, '.pdf']);
                    
        close(gcf);

        dvResultsStruct.targetResultsStruct(iTarget) ...
            .planetResultsStruct(iPlanet) ...
            .reportFilename = [figureName, '.pdf'];

    end % for iPlanet
    
end % for iTarget

% Return.
return


function [string] = generate_significance_string(significance, value, ...
name, alternate, noSigma, color)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [string] = generate_significance_string(significance, value, ...
% name, alternate, noSigma)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

if ~exist('noSigma', 'var')
    noSigma = false;
end % if

if significance ~= -1
    % Statistics are chi-square with one degree of freedom.
    sigmaValue = sqrt(value);
    if ~exist('color', 'var')
        if significance < (1 - normcdf(3, 0, 1)) * 2
            color = 'red';
        else
            color = 'black';
        end % if / else
    end % if
    if noSigma
        string = sprintf('{\\color{%s}%s: %1.1f%%}', ....
            color, name, significance * 100);
    elseif isfinite(sigmaValue)
        string = sprintf('{\\color{%s}%s: %1.1f%% [%.2f\\sigma]}', ....
            color, name, significance * 100, sigmaValue);
    else
        string = sprintf('{\\color{%s}%s: %1.1f%% [Inf-\\sigma]}', ....
            color, name, significance);
    end % if / else
else
    string = alternate;
end % if / else

return


function [string] = generate_offset_string(offset, name, alternate)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [string] = generate_offset_string(offset, name, alternate)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

offsetValue = offset.value;
offsetUncertainty = offset.uncertainty;
if offsetUncertainty ~= -1
    offsetSigma = offsetValue / offsetUncertainty;
    if offsetSigma > 3
        color = 'red';
    else
        color = 'black';
    end % if / else
    string = sprintf('{\\color{%s}%s: %.3f arcsec [%.2f\\sigma]}', ...
        color, name, offsetValue, offsetSigma);
else
    string = alternate;
end % if / else

return

