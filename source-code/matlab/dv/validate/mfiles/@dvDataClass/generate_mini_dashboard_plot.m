%% generate_dashboard_plot
% function generate_mini_dashboard_plot(dvDataObject, dvResultsStruct, usedDefaultValuesStruct)
% 
% Generate mini-dashboard plots for DV report summaries.
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
function generate_mini_dashboard_plot(dvDataObject, dvResultsStruct, usedDefaultValuesStruct)

warning('off', 'all')

INDENT = 0.5;

for iTarget = 1:length(dvResultsStruct.targetResultsStruct)
    targetStruct = dvDataObject.targetStruct(iTarget);
    keplerId = dvResultsStruct.targetResultsStruct(iTarget).keplerId;
    
    if (usedDefaultValuesStruct(iTarget).radiusReplaced)
        radiusReplacedFlag = true;
    else
        radiusReplacedFlag = false;
    end
    
    for iPlanet = 1:length(dvResultsStruct.targetResultsStruct(iTarget).planetResultsStruct)
        
        planetResultsStruct = dvResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(iPlanet);
        planetNumber = planetResultsStruct.planetNumber;
        
        figure();
        rectangle('Position', [0 0 35 30]);

        createModelFitterTitle([0 15 2.5 15]);
        createModelFitterDashboard([2.5 15 15 15]);
        createKicStellarRadius([2.5 27.5 15.0 2.5]);

        createCentroidTestTitle([32.5 22.5 2.5 7.5]);
        createCentroidTestDashboard([17.5 22.5 15 7.5]);

        createEclipsingBinaryDiscriminationTestTitle([0 0 2.5 15]);
        createEclipsingBinaryDiscriminationTestDashboard([2.5, 7.5, 7.5, 7.5], 'O/E Depth', ...
            planetResultsStruct.binaryDiscriminationResults.oddEvenTransitDepthComparisonStatistic);
        createEclipsingBinaryDiscriminationTestDashboard([10, 7.5, 7.5, 7.5], 'O/E Epoch', ...
            planetResultsStruct.binaryDiscriminationResults.oddEvenTransitEpochComparisonStatistic);
        createEclipsingBinaryDiscriminationTestDashboard([2.5, 0, 7.5, 7.5], 'Shorter Period', ...
            planetResultsStruct.binaryDiscriminationResults.shorterPeriodComparisonStatistic);
        createEclipsingBinaryDiscriminationTestDashboard([10, 0, 7.5, 7.5], 'Longer Period', ...
            planetResultsStruct.binaryDiscriminationResults.longerPeriodComparisonStatistic);

        createDifferenceImageCentroidOffsetsTitle([32.5 7.5 2.5 15]);
        createDifferenceImageCentroidOffsetsDashboard([17.5 7.5 15 15]);
        
        createBootstrapTestTitle([32.5 0 2.5 7.5]);
        createBootstrapTestDashboard([17.5 0 15 7.5]);

        set(gcf, 'UserData', caption(keplerId, planetNumber, radiusReplacedFlag));
        format_graphics_for_dv_report(gcf);
        set(gca, 'xtick', [], 'ytick', [], 'FontSize', 5);
        set(gca, 'Position', [0.025, 0.07, 0.95, 0.85]);

        if isfield(dvResultsStruct.targetResultsStruct(iTarget), 'dvFiguresRootDirectory')
            dvFiguresRootDirectory = dvResultsStruct.targetResultsStruct(iTarget).dvFiguresRootDirectory;
        else
            dvFiguresRootDirectory = sprintf('target-%09d', targetStruct(iTarget).keplerId);
        end
        planetDir = sprintf('planet-%02d', planetResultsStruct.planetNumber);
        if ~exist(fullfile(dvFiguresRootDirectory, planetDir, 'report-summary'), 'dir')
            mkdir(fullfile(dvFiguresRootDirectory, planetDir, 'report-summary'));
        end
        dashboardPlotName = fullfile(dvFiguresRootDirectory, planetDir, 'report-summary', ...
            sprintf('%09d-%02d-mini-dashboard-plot.fig', keplerId, planetResultsStruct.planetNumber));
        saveas(gcf, dashboardPlotName);
        close(gcf);
    end
end

warning('on', 'all')

%%
% Create title for model fitter dashboard.
    function createModelFitterTitle(position)
        rectangle('Position', position);
        x = position(1);
        y = position(2);
        dtext(x+1.3, y+5, 'Model Fitter', 'rotation', 90);
    end

%%
% Create model fitter dashboard. All-transit values are used.
    function createModelFitterDashboard(position)
        
        periodStruct = retrieve_model_parameter(...
            planetResultsStruct.allTransitsFit.modelParameters, 'orbitalPeriodDays');
        epochStruct = retrieve_model_parameter(...
            planetResultsStruct.allTransitsFit.modelParameters, 'transitEpochBkjd');
        
        if (planetResultsStruct.allTransitsFit.modelChiSquare ~= -1)
            % Fit succeeded.
            
            reducedRadiusStruct = retrieve_model_parameter(...
                planetResultsStruct.allTransitsFit.modelParameters, 'ratioPlanetRadiusToStarRadius');
            reducedSemiMajorAxisStruct = retrieve_model_parameter(...
                planetResultsStruct.allTransitsFit.modelParameters, 'ratioSemiMajorAxisToStarRadius');
            impactParameterStruct = retrieve_model_parameter(...
                planetResultsStruct.allTransitsFit.modelParameters, 'minImpactParameter');
            
            chiSquaredOverDofString = sprintf('Chi-squared/DoF = %1.1f', ...
                planetResultsStruct.allTransitsFit.modelChiSquare / ...
                planetResultsStruct.allTransitsFit.modelDegreesOfFreedom);
            snr = planetResultsStruct.allTransitsFit.modelFitSnr;
            snrString = sprintf('SNR = %1.1f', snr);
            
            periodString = sprintf('Per = %.5f +/- %.5f d', ...
                periodStruct.value, periodStruct.uncertainty);
            epochString = sprintf('Ep = %.4f +/- %.4f d', ...
                epochStruct.value, epochStruct.uncertainty);
            reducedRadiusString = sprintf('Rp/Rs = %.4f +/- %.4f', ...
                reducedRadiusStruct.value, reducedRadiusStruct.uncertainty);
            reducedSemiMajorAxisString = sprintf('a/Rs = %.2f +/- %.2f', ...
                reducedSemiMajorAxisStruct.value, reducedSemiMajorAxisStruct.uncertainty);
            impactParameterString = sprintf('b = %.2f +/- %.2f', ...
                impactParameterStruct.value, impactParameterStruct.uncertainty);
            
            if (snr >= 10)
                color = 'g';
            elseif (snr >= dvDataObject.tpsConfigurationStruct.searchTransitThreshold)
                color = 'y';
            else
                color = 'r';
            end
            if (planetResultsStruct.allTransitsFit.fullConvergence)
                resultString = '';
            else
                resultString = 'Model fit did not fully converge';
            end
            resultColor = 'w';
            
        elseif (planetResultsStruct.planetCandidate.suspectedEclipsingBinary)
            
            % EB.
            chiSquaredOverDofString = 'Chi-squared/DoF = N/A';
            snrString = 'SNR = N/A';
            
            periodString = sprintf('Per = %.5f d', periodStruct.value);
            epochString = sprintf('Ep = %.4f +/- %.4f d', epochStruct.value);
            reducedRadiusString = 'Rp/Rs = N/A';
            reducedSemiMajorAxisString = 'a/Rs = N/A';
            impactParameterString = 'b = N/A';
            
            color = 'c';
            resultString = 'Planet candidate suspected to be an EB';
            resultColor = 'm';
            
        else
            
            % MES/SES or fitter failure.
            chiSquaredOverDofString = 'Chi-squared/DoF = N/A';
            snrString = 'SNR = N/A';
            
            periodString = 'Per = N/A';
            epochString = 'Ep = N/A';
            reducedRadiusString = 'Rp/Rs = N/A';
            reducedSemiMajorAxisString = 'a/Rs = N/A';
            impactParameterString = 'b = N/A';
            
            if (planetResultsStruct.planetCandidate.statisticRatioBelowThreshold)
                color = 'c';
                resultString = 'MES/SES < threshold';
                resultColor = 'm';
            else
                color = 'r';
                resultString = 'Model fit failed';
                resultColor = 'w';
            end
            
        end
        
        h = rectangle('Position', position);
        x = position(1);
        y = position(2);

        set(h, 'FaceColor', color);
        dtext(x+INDENT, y+11, chiSquaredOverDofString);
        dtext(x+INDENT, y+9.66, snrString);
        dtext(x+INDENT, y+8.33, periodString);
        dtext(x+INDENT, y+7, epochString);
        dtext(x+INDENT, y+5.66, reducedRadiusString);
        dtext(x+INDENT, y+4.33, reducedSemiMajorAxisString);
        dtext(x+INDENT, y+3, impactParameterString);
        dtext(x+INDENT, y+1.66, resultString, 'Color', resultColor);

    end
        
%%
% Create KIC stellar radius dashboard.
    function createKicStellarRadius(position)
        if (isnan(targetStruct.radius.uncertainty) || isempty(targetStruct.radius.uncertainty))
            if (~radiusReplacedFlag)
                kicRadiusString = sprintf('Stellar Radius\n%1.1f Solar units', ...
                    targetStruct.radius.value);
            else
                kicRadiusString = sprintf('*Stellar Radius\n%1.1f Solar units', ...
                    targetStruct.radius.value);
            end
        else
            if (~radiusReplacedFlag)
                kicRadiusString = sprintf('Stellar Radius\n%1.1f +/- %1.1f Solar units', ...
                    targetStruct.radius.value, targetStruct.radius.uncertainty);
            else
                kicRadiusString = sprintf('*Stellar Radius\n%1.1f +/- %1.1f Solar units', ...
                    targetStruct.radius.value, targetStruct.radius.uncertainty);
            end
        end
        
        h = rectangle('Position', position);
        x = position(1);
        y = position(2);
        
        dtext(x+INDENT, y+1.2, kicRadiusString);
        color = getStellarRadiusColor();
        if (radiusReplacedFlag)
            color = 'c';
        end
        set(h, 'FaceColor', color);
    end

%%
% Create title for centroid test dashboard.
    function createCentroidTestTitle(position)
        rectangle('Position', position);
        x = position(1);
        y = position(2);
        dtext(x+1.25, y+7.1, 'Centroid Test', 'rotation', -90);
    end

%%
% Create centroid test dashboard. Flux-weighted centroid values are used.
    function createCentroidTestDashboard(position)
        motionResults = planetResultsStruct.centroidResults.fluxWeightedMotionResults;
        significance = motionResults.motionDetectionStatistic.significance;
        
        if (significance ~= -1)
            significanceString = sprintf(...
                'Sig = %1.2f%%', significance*100);
            sigmaValue = norminv(1-significance/2, 0, 1);
            if isfinite(sigmaValue)
                sigmaString = sprintf('[%.2f\\sigma]', sigmaValue);
            else
                sigmaString = '';
            end
        else
            significanceString = 'Sig = N/A';
            sigmaString = '';
        end
        
        h = rectangle('Position', position);
        x = position(1);
        y = position(2);
        dtext(x+INDENT, y+6.0, 'Flux Weighted Motion');
        dtext(x+INDENT, y+4.0, significanceString);
        dtext(x+INDENT, y+2.67, sigmaString);
        set(h, 'FaceColor', getSignificanceColor(significance));
    end

%%
% Create title for eclipsing binary discrimination test dashboard.
    function createEclipsingBinaryDiscriminationTestTitle(position)
        rectangle('Position', position);
        x = position(1);
        y = position(2);
        dtext(x+1.3, y+3.25, {'Eclipsing Binary', 'Discrimination Test'}, 'rotation', 90);
    end

%%
% Create eclipsing binary discrimination test dashboard.
    function createEclipsingBinaryDiscriminationTestDashboard(position, title, statistic)
        if (statistic.significance ~= -1)
            significanceString = sprintf('Sig = %1.2f%%', ...
                statistic.significance*100);
            sigmaValue = norminv(1-statistic.significance/2, 0, 1);
            if isfinite(sigmaValue)
                sigmaString = sprintf('[%.2f\\sigma]', sigmaValue);
            else
                sigmaString = '';
            end
        else
            significanceString = 'Sig = N/A';
            sigmaString = '';
        end
        
        h = rectangle('Position', position);
        x = position(1);
        y = position(2);
        dtext(x+0.5, y+6.0, title);
        dtext(x+0.5, y+4.0, significanceString);
        dtext(x+0.5, y+2.67, sigmaString);
        set(h, 'FaceColor', getSignificanceColor(statistic.significance));
    end

%%
% Create title for difference image centroid offsets dashboard.
    function createDifferenceImageCentroidOffsetsTitle(position)
        rectangle('Position', position);
        x = position(1);
        y = position(2);
        dtext(x+1.3, y+10.75, {'Difference Image', 'Centroid Offsets'}, 'rotation', -90);
    end

%%
% Create difference image centroid offsets dashboard.
    function createDifferenceImageCentroidOffsetsDashboard(position)
        motionResults = planetResultsStruct.centroidResults.differenceImageMotionResults;
        
        mqControlCentroidOffsets = motionResults.mqControlCentroidOffsets;
        meanSkyOffset = mqControlCentroidOffsets.meanSkyOffset;
        meanSkyOffsetValue1 = meanSkyOffset.value;
        meanSkyOffsetUncertainty1 = meanSkyOffset.uncertainty;
        
        if (meanSkyOffsetUncertainty1 ~= -1)
            valueString = sprintf(...
                'Dist = %1.2e arcsec', meanSkyOffsetValue1);
            sigmaValue1 = meanSkyOffsetValue1 / meanSkyOffsetUncertainty1;
            if isfinite(sigmaValue1)
                sigmaString = sprintf('[%.2f\\sigma]', sigmaValue1);
            else
                sigmaString = '';
            end
        else
            valueString = 'Dist = N/A';
            sigmaString = '';
        end
        
        h = rectangle('Position', position);
        x = position(1);
        y = position(2);
        dtext(x+INDENT, y+13.5, 'Out of Transit');
        dtext(x+INDENT, y+11.5, valueString);
        dtext(x+INDENT, y+10.17, sigmaString);
        
        mqKicCentroidOffsets = motionResults.mqKicCentroidOffsets;
        meanSkyOffset = mqKicCentroidOffsets.meanSkyOffset;
        meanSkyOffsetValue2 = meanSkyOffset.value;
        meanSkyOffsetUncertainty2 = meanSkyOffset.uncertainty;
        
        if (meanSkyOffsetUncertainty2 ~= -1)
            valueString = sprintf(...
                'Dist = %1.2e arcsec', meanSkyOffsetValue2);
            sigmaValue2 = meanSkyOffsetValue2 / meanSkyOffsetUncertainty2;
            if isfinite(sigmaValue2)
                sigmaString = sprintf('[%.2f\\sigma]', sigmaValue2);
            else
                sigmaString = '';
            end
        else
            valueString = 'Dist = N/A';
            sigmaString = '';
        end
        
        dtext(x+INDENT, y+6.0, 'KIC');
        dtext(x+INDENT, y+4.0, valueString);
        dtext(x+INDENT, y+2.67, sigmaString);
        
        significance = 2 * (1 - normcdf(max(sigmaValue1, sigmaValue2), 0, 1));
        set(h, 'FaceColor', getSignificanceColor(significance));
    end

%%
% Create title for bootstrap test dashboard.
    function createBootstrapTestTitle(position)
        rectangle('Position', position);
        x = position(1);
        y = position(2);
        dtext(x+1.25, y+7.2, 'Bootstrap Test', 'rotation', -90);
    end

%%
% Create bootstrap test dashboard.
    function createBootstrapTestDashboard(position)

        bootstrapFalseAlarm = planetResultsStruct.planetCandidate.significance;
        maxMultipleEventStatistic = planetResultsStruct.planetCandidate.maxMultipleEventSigma;
        
        if (bootstrapFalseAlarm ~= -1)
            bootstrapFalseAlarmString = sprintf('PFA = %1.2e', bootstrapFalseAlarm);
            % If false alarm was set to 0 because no null total detection
            % statistic > search transit theshold.
            falseAlarmLimit = 1e-12;
            if (bootstrapFalseAlarm <= max(0.5*erfc(maxMultipleEventStatistic/sqrt(2)), falseAlarmLimit))
                color = 'g';
            elseif (bootstrapFalseAlarm <=  2*0.5*erfc(maxMultipleEventStatistic/sqrt(2)))
                color = 'y';
            else
                color = 'r';
            end
        else
            bootstrapFalseAlarmString = 'PFA = N/A';
            color = 'c';
        end
        
        if (planetResultsStruct.allTransitsFit.modelChiSquare ~= -1)
            observedTransitCountString = sprintf('Observed Transits = %d', ...
                planetResultsStruct.planetCandidate.observedTransitCount);
        else
            observedTransitCountString = 'Observed Transits = N/A';
        end

        h = rectangle('Position', position);
        x = position(1);
        y = position(2);
        dtext(x+INDENT, y+5.83, bootstrapFalseAlarmString);
        dtext(x+INDENT, y+4.50, observedTransitCountString);
        dtext(x+INDENT, y+3.17, sprintf('MES = %1.2e', ...
            maxMultipleEventStatistic));
        set(h, 'FaceColor', color);
    end

%%
% Determine the color for the given significance.
%
% A significance of less than or equal to 2-sigma yields green, less than
% or equal to 3-sigma yields yellow, and a significance above 3-sigma
% yields red.
%
% A significance of -1 (no data) yields cyan.

    function color = getSignificanceColor(significance)
        if (significance == -1)
            color = 'c';
        elseif (significance >= erfc(2/sqrt(2)))
            color = 'g';
        elseif (significance >= erfc(3/sqrt(2)))
            color = 'y';
        else
            color = 'r';
        end
    end

%%
% Determine the color for the stellar radius dashboard.
    function color = getStellarRadiusColor()
        starRadiusStruct = retrieve_model_parameter(...
            planetResultsStruct.allTransitsFit.modelParameters, 'starRadiusSolarRadii');
        
        if (planetResultsStruct.allTransitsFit.modelChiSquare ~= -1)
            if (abs(targetStruct.radius.value - starRadiusStruct.value)/targetStruct.radius.value < 0.2)
                color = 'g';
            elseif ((abs(targetStruct.radius.value - starRadiusStruct.value)/targetStruct.radius.value >= 0.2) ...
                    && (abs(targetStruct.radius.value - starRadiusStruct.value)/targetStruct.radius.value <= 1))
                color = 'y';
            else
                % abs(targetStruct.radius.value - starRadiusStruct.value)/targetStruct.radius.value > 1
                color = 'r';
            end
        else
            % Fitter failed, or MES/SES < threshold, or EB
            color = 'c';
        end
    end

%% 
% Create a caption for the figure.
    function caption = caption(keplerId, planetNumber, radiusReplacedFlag)
        caption = ['Summary of model fitter results and validation test results for target ' ...
            num2str(keplerId)  ', planet candidate ' num2str(planetNumber) '. ' ...
            'In general, green denotes that the candidate is likely a planet, while red denotes that the candidate is unlikely to be a planet. ' ...
            'Cyan denotes that no data is available. ' ...
            'The color of the Model Fitter block is: ' ...
            'green, when the SNR of the fit is greater than or equal to 4.5; ' ...
            'yellow, when 0 <= SNR < 4.5; ' ...
            'red, if the fitter failed. ' ...
            'The color of the Stellar Radius blocks are: ' ...
            'green, if the KIC stellar radius differs from the fitted stellar radius by less than 20%; ' ...
            'yellow, if this difference is greater than or equal to 20% but less than or equal to 100%; ' ...
            'red, if the difference is greater than 100%. ' ...
            'The color of the Centroid Test and Eclipsing Binary Discrimination Test blocks are: ' ...
            'green, when the significance is within 2-sigma; ' ...
            'yellow, when the significance is between 2- and 3-sigma; ' ...
            'red when the significance is greater than 3-sigma. ' ...
            'The color of the Bootstrap Test block is: ' ...
            'green, when the false alarm is less than or equal to the CCDF of the Gaussian at the max multiple event statistic; ' ...
            'yellow, if the false alarm is greater than the CCDF of the Gaussian at the max multiple event statistic but less than or equal to 2 times the CCDF of the Gaussian at the max multiple event statistic; ' ...
            'red, if the false alarm is greater than 2 times the CCDF of the Gaussian at the max multiple event statistic.'];
        
        if (radiusReplacedFlag)
            note = ['  *Stellar radius from KIC was unavailable for this target and replaced with ' ...
                num2str(dvDataObject.planetFitConfigurationStruct.defaultRadius) ' Solar unit(s).'];
            caption = strcat(caption, note);
        end
        
    end

%%
% Dashboard text. The default font size is 12 and weight is bold. If
% additional properties are needed, they can be appended.
    function dtext(x, y, s, varargin)
        text(x, y, s, 'FontSize', 12, 'FontWeight', 'bold', varargin{:});
    end

end