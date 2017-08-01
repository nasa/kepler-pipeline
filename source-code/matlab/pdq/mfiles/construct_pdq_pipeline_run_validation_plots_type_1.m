function construct_pdq_pipeline_run_validation_plots_type_1(pdqOutputStruct)

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% construct_pdq_pipeline_run_validation_plots_type_1.m
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
close all;


ccdOutputs = [pdqOutputStruct.outputPdqTsData.pdqModuleOutputTsData.ccdOutput];
ccdModules = [pdqOutputStruct.outputPdqTsData.pdqModuleOutputTsData.ccdModule];
modOuts = convert_from_module_output(ccdModules, ccdOutputs);

nCadences = length(pdqOutputStruct.outputPdqTsData.cadenceTimes);


% plot to file parameters
isLandscapeOrientationFlag = true;
includeTimeFlag = false;
printJpgFlag = false;

%Set rand to its default initial state:
rand('twister');
cadenceColors = rand(nCadences,3);
cadenceColors(cadenceColors <= eps) = 0.1;

%-----------------------------------------------------
% black levels
%-----------------------------------------------------
blackLevels  = [pdqOutputStruct.outputPdqTsData.pdqModuleOutputTsData.blackLevels]; % an array of structs 1x84

blackLevelValues = [blackLevels.values]';
blackLevelUncertainties = [blackLevels.uncertainties]';
h = figure;
for j = 1:nCadences
    validModOuts = find(blackLevelValues(:,j) ~= -1);
    h1 = plot(modOuts(validModOuts), blackLevelValues(validModOuts,j),'.-', 'Color', cadenceColors(j,:));
    hold on;
    h2 = plot(modOuts(validModOuts), blackLevelValues(validModOuts,j) + blackLevelUncertainties(validModOuts,j),':', 'Color', cadenceColors(j,:));
    plot(modOuts(validModOuts), blackLevelValues(validModOuts,j) - blackLevelUncertainties(validModOuts,j),':', 'Color', cadenceColors(j,:));

end

if(~isempty(h1) || ~isempty(h2))
    set(gca, 'fontsize', 8);
    legend([h1 h2], {'Metric', 'Uncertainties'}, 'Location', 'Best');
    set(gca, 'xTick', (1:4:84)', 'xTickLabel', [2:4, 6:20, 22:24]');
    ylabel('in ADU');
    xlabel('Module  Number');
    titleStr = (['Black level metric variation across the focal plane over ' num2str(nCadences) ' cadences']);
    title(titleStr);

    % Set plot caption for general use.
    % The official version of this caption is in summary-metrics.tex.
    plotCaption = strcat(...
        'The black level metric is computed at the end of the calibration process which consists of the following \n',...
        'steps:\n',...
        '     1. subtract requantization table offset from the raw black collateral pixels \n',...
        '     2. add mean black level value per read multiplied by the number of exposures per long cadence \n',...
        '     3. subtract black 2D  \n',...
        '     4. bin the collateral black pixels from several columns into one column  \n',...
        '     5. fit a polynomial over the calibrated, binned  black pixels from step 4  \n',...
        '     6. evaluate the polynomial over the available rows to obtain the calibrated black pixels. \n',...
        '\n',...
        'Black metric is calculated as the mean value of calibrated black pixels from step 6. Its units are in ADU. \n',...
        '\n',...
        'In this plot, black metric variation over the focal plane over several cadences is plotted along with the \n',...
        'uncertainties. \n',...
        '\n',...
        'In general, if there is more than one cadence, one would expect to see plots for all the cadences merge into \n',...
        'one plot. If many plots are seen, then it indicates strong variations across cadences for the same module \n',...
        'output. This would warrant an in-depth analysis of the intermediate products left in the Matlab workspace. \n');


    set(h, 'UserData', sprintf(plotCaption));

    plot_to_file(titleStr, isLandscapeOrientationFlag, includeTimeFlag, printJpgFlag);
end
close all;


%-----------------------------------------------------
% smear levels
%-----------------------------------------------------

h = figure;
smearLevels  = [pdqOutputStruct.outputPdqTsData.pdqModuleOutputTsData.smearLevels]; % an array of structs 1x84

smearLevelValues = [smearLevels.values]';
smearLevelUncertainties = [smearLevels.uncertainties]';
for j = 1:nCadences
    validModOuts = find(smearLevelValues(:,j) ~= -1);
    h1 = plot(modOuts(validModOuts), smearLevelValues(validModOuts,j),'.-', 'Color', cadenceColors(j,:));
    hold on;
    h2 = plot(modOuts(validModOuts), smearLevelValues(validModOuts,j) + smearLevelUncertainties(validModOuts,j),':', 'Color', cadenceColors(j,:));
    plot(modOuts(validModOuts), smearLevelValues(validModOuts,j) - smearLevelUncertainties(validModOuts,j),':', 'Color', cadenceColors(j,:));

end
if(~isempty(h1) || ~isempty(h2))

    set(gca, 'fontsize', 8);
    legend([h1 h2], {'Metric', 'Uncertainties'}, 'Location', 'Best');
    set(gca, 'xTick', (1:4:84)', 'xTickLabel', [2:4, 6:20, 22:24]');
    ylabel('in photoelectrons');
    xlabel('Module  Number');
    titleStr = (['Smear level metric variation across the focal plane over ' num2str(nCadences) ' cadences']);
    title(titleStr);

    % Set plot caption for general use.
    % The official version of this caption is in summary-metrics.tex.
    plotCaption = strcat(...
        'The smear level metric is computed at the end of the calibration process which consists of the following \n',...
        'steps:\n',...
        ' 1. subtract requantization table offset from the raw masked/virtual smear collateral pixels  \n',...
        ' 2. add mean black level value per read multiplied by the number of exposures per long cadence  \n',...
        ' 3. subtract black 2D   \n',...
        ' 4. bin the collateral masked/virtual smear pixels from several rows into one row each   \n',...
        ' 5. correct for gain  \n',...
        ' 6. correct for undershoot  \n',...
        ' 7. estimate the smear from masked/virtual smear pixels  \n',...
        '  \n',...
        'Smear metric is calculated as the median value of calibrated smear pixels from step 7. Its units are \n',...
        'in photoelectrons.\n\n',...
        'In this plot, smear metric variation over the focal plane over several cadences is plotted along with \n',...
        'the uncertainties.\n\n',...
        'In general, if there is more than one cadence, one would expect to see plots for all the cadences merge into \n',...
        'one plot. If many plots are seen, then it indicates strong variations across cadences for the same module \n',...
        'output. This would warrant an in-depth analysis of the intermediate products left in the Matlab workspace. \n');

    set(h, 'UserData', sprintf(plotCaption));


    plot_to_file(titleStr, isLandscapeOrientationFlag, includeTimeFlag, printJpgFlag);

end
close all;

%-----------------------------------------------------
% dark currents
%-----------------------------------------------------

h = figure;
darkCurrents  = [pdqOutputStruct.outputPdqTsData.pdqModuleOutputTsData.darkCurrents]; % an array of structs 1x84

darkCurrentsValues = [darkCurrents.values]';
darkCurrentsUncertainties = [darkCurrents.uncertainties]';
for j = 1:nCadences
    validModOuts = find(darkCurrentsValues(:,j) ~= -1);
    h1 = plot(modOuts(validModOuts), darkCurrentsValues(validModOuts,j),'.-', 'Color', cadenceColors(j,:));
    hold on;
    h2 = plot(modOuts(validModOuts), darkCurrentsValues(validModOuts,j) + darkCurrentsUncertainties(validModOuts,j),':', 'Color', cadenceColors(j,:));
    plot(modOuts(validModOuts), darkCurrentsValues(validModOuts,j) - darkCurrentsUncertainties(validModOuts,j),':', 'Color', cadenceColors(j,:));

end
if(~isempty(h1) || ~isempty(h2))

    set(gca, 'fontsize', 8);
    legend([h1 h2], {'Metric', 'Uncertainties'}, 'Location', 'Best');
    set(gca, 'xTick', (1:4:84)', 'xTickLabel', [2:4, 6:20, 22:24]');
    xlabel('Module  Number');
    ylabel('in photoelectrons/sec/exposure');
    titleStr = (['Dark current metric variation across the focal plane over ' num2str(nCadences) ' cadences']);
    title(titleStr);

    % Set plot caption for general use.
    % The official version of this caption is in summary-metrics.tex.
    plotCaption = strcat(...
        'The dark current metric is computed at the end of the calibration process which consists of the following \n',...
        'steps:\n',...
        '    1. subtract requantization table offset from the raw masked/virtual smear collateral pixels\n',...
        '    2. add mean black level value per read multiplied by the number of exposures per long cadence\n',...
        '    3. subtract black 2D    \n',...
        '    4. bin the collateral masked/virtual smear pixels from several rows into one row each\n',...
        '    5. correct for gain  \n',...
        '    6. correct for undershoot  \n',...
        '    7. estimate the dark currents from  smear from the calibrated masked/virtual smear pixels  \n',...
        '\n',...
        'Dark current metric is calculated as the median value of dark current from step 7. \n',...
        'Its units are in photoelectrons per second per exposure.  \n',...
        '\n',...
        'In this plot, dark current metric variation over the focal plane over several  over several cadences is plotted \n',...
        'along with the uncertainties.\n',...
        '\n',...
        'In general, if there is more than one cadence, one would expect to see plots for all the cadences merge into \n',...
        'one plot. If many plots are seen, then it indicates strong variations across cadences for the same module \n',...
        'output. This would warrant an in-depth analysis of the intermediate products left in the Matlab workspace. \n');

    set(h, 'UserData', sprintf(plotCaption));

    plot_to_file(titleStr, isLandscapeOrientationFlag, includeTimeFlag, printJpgFlag);


end
close all;

%-----------------------------------------------------
% backgroundLevels
%-----------------------------------------------------
h = figure;

backgroundLevels  = [pdqOutputStruct.outputPdqTsData.pdqModuleOutputTsData.backgroundLevels]; % an array of structs 1x84

backgroundLevelsValues = [backgroundLevels.values]';
backgroundLevelsUncertainties = [backgroundLevels.uncertainties]';
for j = 1:nCadences
    validModOuts = find(backgroundLevelsValues(:,j) ~= -1);
    h1 = plot(modOuts(validModOuts), backgroundLevelsValues(validModOuts,j),'.-', 'Color', cadenceColors(j,:));
    hold on;
    h2 = plot(modOuts(validModOuts), backgroundLevelsValues(validModOuts,j) + backgroundLevelsUncertainties(validModOuts,j),':', 'Color', cadenceColors(j,:));
    plot(modOuts(validModOuts), backgroundLevelsValues(validModOuts,j) - backgroundLevelsUncertainties(validModOuts,j),':', 'Color', cadenceColors(j,:));

end
if(~isempty(h1) || ~isempty(h2))

    set(gca, 'fontsize', 8);
    legend([h1 h2], {'Metric', 'Uncertainties'}, 'Location', 'Best');

    set(gca, 'xTick', (1:4:84)', 'xTickLabel', [2:4, 6:20, 22:24]');
    xlabel('Module  Number');
    ylabel('in photoelectrons');
    titleStr = (['Background level metric variation across the focal plane over ' num2str(nCadences) ' cadences']);
    title(titleStr);

    % Set plot caption for general use.
    % The official version of this caption is in summary-metrics.tex.
    plotCaption = strcat(...
        'The background level metric is computed at the end of the calibration process which consists of the following \n',...
        'steps:\n',...
        '    1. subtract requantization table offset from the raw background collateral pixels   \n',...
        '    2. add mean black level value per read multiplied by the number of exposures per long cadence   \n',...
        '    3. subtract black 2D    \n',...
        '    4. correct for gain  \n',...
        '    5. correct for undershoot  \n',...
        '    6. collect additional background pixels from the aperture assigned to the targets  \n',...
        '    7. correct for flat field  \n',...
        '    8. remove outliers in the background flux   \n\n',...
        'Background level metric is calculated as the median value of background level from step 8.\n',...
        'Its units are in photoelectrons.  \n',...
        '\n',...
        'In this plot, background level metric variation over the focal plane over several  cadences is plotted \n',...
        'along with the uncertainties.   \n',...
        '\n',...
        'In general, if there is more than one cadence, one would expect to see plots for all the cadences merge into \n',...
        'one plot. If many plots are seen, then it indicates strong variations across cadences for the same module\n',...
        ' output. This would warrant an in-depth analysis of the intermediate products left in the Matlab workspace. \n');

    set(h, 'UserData', sprintf(plotCaption));
    plot_to_file(titleStr, isLandscapeOrientationFlag, includeTimeFlag, printJpgFlag);


end
close all;

%-----------------------------------------------------
% dynamicRanges
%-----------------------------------------------------
h = figure;

dynamicRanges  = [pdqOutputStruct.outputPdqTsData.pdqModuleOutputTsData.dynamicRanges]; % an array of structs 1x84

dynamicRangesValues = [dynamicRanges.values]';
dynamicRangesUncertainties = [dynamicRanges.uncertainties]';
for j = 1:nCadences
    validModOuts = find(dynamicRangesValues(:,j) ~= -1);
    h1 = plot(modOuts(validModOuts), dynamicRangesValues(validModOuts,j),'.-', 'Color', cadenceColors(j,:));
    hold on;
    h2 = plot(modOuts(validModOuts), dynamicRangesValues(validModOuts,j) + dynamicRangesUncertainties(validModOuts,j),':', 'Color', cadenceColors(j,:));
    plot(modOuts(validModOuts), dynamicRangesValues(validModOuts,j) - dynamicRangesUncertainties(validModOuts,j),':', 'Color', cadenceColors(j,:));

end
if(~isempty(h1) || ~isempty(h2))

    set(gca, 'fontsize', 8);
    legend([h1 h2], {'Metric', 'Uncertainties'}, 'Location', 'Best');

    set(gca, 'xTick', (1:4:84)', 'xTickLabel', [2:4, 6:20, 22:24]');
    xlabel('Module  Number');

    ylabel('in ADU/exposure');
    titleStr = (['Dynamic range metric variation across the focal plane over ' num2str(nCadences) ' cadences']);
    title(titleStr);

    % Set plot caption for general use.
    % The official version of this caption is in summary-metrics.tex.
    plotCaption = strcat(...
        'The dynamic range metric is computed as follows:\n',...
        '(max(all pixels) - min(all pixels))/numberOfExposuresPerLongCadence\n',...
        'Its units are in ADU per exposure. \n\n',...
        'In this plot, dynamic range metric variation over the focal plane over several cadences is plotted along \n',...
        'with the uncertainties. \n\n',...
        'In general, if there is more than one cadence, one would expect to see plots for all the cadences merge into \n',...
        'one plot. If many plots are seen, then it indicates strong variations across cadences for the same module \n',...
        'output. This would warrant an in-depth analysis of the intermediate products left in the Matlab workspace. \n');

    set(h, 'UserData', sprintf(plotCaption));

    plot_to_file(titleStr, isLandscapeOrientationFlag, includeTimeFlag, printJpgFlag);

end
close all;

%-----------------------------------------------------
% meanFluxes
%-----------------------------------------------------
h = figure;

meanFluxes  = [pdqOutputStruct.outputPdqTsData.pdqModuleOutputTsData.meanFluxes]; % an array of structs 1x84

meanFluxesValues = [meanFluxes.values]';
meanFluxesUncertainties = [meanFluxes.uncertainties]';
for j = 1:nCadences
    validModOuts = find(meanFluxesValues(:,j) ~= -1);
    h1 = plot(modOuts(validModOuts), meanFluxesValues(validModOuts,j),'.-', 'Color', cadenceColors(j,:));
    hold on;
    h2 = plot(modOuts(validModOuts), meanFluxesValues(validModOuts,j) + meanFluxesUncertainties(validModOuts,j),':', 'Color', cadenceColors(j,:));
    plot(modOuts(validModOuts), meanFluxesValues(validModOuts,j) - meanFluxesUncertainties(validModOuts,j),':', 'Color', cadenceColors(j,:));

end
if(~isempty(h1) || ~isempty(h2))

    set(gca, 'fontsize', 8);
    legend([h1 h2], {'Metric', 'Uncertainties'}, 'Location', 'Best');

    set(gca, 'xTick', (1:4:84)', 'xTickLabel', [2:4, 6:20, 22:24]');
    xlabel('Module  Number');
    ylabel('unitless ratio');
    titleStr = (['Brightness metric variation across the focal plane over ' num2str(nCadences) ' cadences']);
    title(titleStr);

    % Set plot caption for general use.
    % The official version of this caption is in summary-metrics.tex.
    plotCaption = strcat(...
        'The brightness metric metric is computed as follows:\n',...
        '1. calculate flux of each star for each cadence using simple aperture photometry \n',...
        '2. compute corrected flux by dividing the flux from step 1 by flux fraction in aperture (computed by TAD)\n',...
        '3. normalize the corrected flux by dividing the flux from step 2 by expected flux\n',...
        '\n',...
        '(Expected flux is computed as \n',...
        'expectedFlux = standardMag12Flux * ccdExposureTime * numberOfExposuresPerLongCadence * mag2b(starMag-12)\n',...
        '\n',...
        '4. derive flux metric for each cadence as the robust mean brightness of all targets in the current module \n',...
        '  \n',...
        'In this plot, brightness metric metric variation over the focal plane over several cadences is plotted along \n',...
        'with the uncertainties.\n',...
        ' \n',...
        'In general, if there is more than one cadence, one would expect to see plots for all the cadences merge into \n',...
        'one plot. If many plots are seen, then it indicates strong variations across cadences for the same module \n',...
        'output. This would warrant an in-depth analysis of the intermediate products left in the Matlab workspace. \n');

    set(h, 'UserData', sprintf(plotCaption));


    plot_to_file(titleStr, isLandscapeOrientationFlag, includeTimeFlag, printJpgFlag);


end
close all;

%-----------------------------------------------------
% centroidsMeanRows
%-----------------------------------------------------
h = figure;

centroidsMeanRows  = [pdqOutputStruct.outputPdqTsData.pdqModuleOutputTsData.centroidsMeanRows]; % an array of structs 1x84

centroidsMeanRowsValues = [centroidsMeanRows.values]';
centroidsMeanRowsUncertainties = [centroidsMeanRows.uncertainties]';
for j = 1:nCadences
    validModOuts = find(centroidsMeanRowsValues(:,j) ~= -1);

    invalidModOuts = find(centroidsMeanRowsValues(:,j) == -1);
    centroidsMeanRowsUncertainties(invalidModOuts,j) = NaN;

    h1 = plot(modOuts(validModOuts), centroidsMeanRowsValues(validModOuts,j),'.-', 'Color', cadenceColors(j,:));
    hold on;
    h2 = plot(modOuts(validModOuts), centroidsMeanRowsValues(validModOuts,j) + centroidsMeanRowsUncertainties(validModOuts,j),':', 'Color', cadenceColors(j,:));
    plot(modOuts(validModOuts), centroidsMeanRowsValues(validModOuts,j) - centroidsMeanRowsUncertainties(validModOuts,j),':', 'Color', cadenceColors(j,:));

end
if(~isempty(h1) || ~isempty(h2))

    set(gca, 'fontsize', 8);
    legend([h1 h2], {'Metric', 'Uncertainties'}, 'Location', 'Best');

    set(gca, 'xTick', (1:4:84)', 'xTickLabel', [2:4, 6:20, 22:24]');
    xlabel('Module  Number');
    ylabel('in pixel units');
    titleStr = (['Centroid row metric variation across the focal plane over ' num2str(nCadences) ' cadences']);
    title(titleStr);

    % Set plot caption for general use.
    % The official version of this caption is in summary-metrics.tex.
    plotCaption = strcat(...
        'The centroid row metric is calculated as follows: \n',...
        '\n',...
        '1. Use the recently computed pointing to compute the predicted centroid row, column positions of target stars \n',...
        '   (use ra_dec_2_pix on ra, dec of stars) \n',...
        '2. Compute centroid row metric as the robust mean of \n',...
        '   {predicted centroid row positions - measured centroid row positions}\n\n',...
        'In this plot, centroid row metric metric variation over the focal plane over several cadences is plotted along \n',...
        'with the uncertainties.  \n',...
        ' \n',...
        'In general, if there is more than one cadence, one would expect to see plots for all the cadences merge into \n',...
        'one plot. If many plots are seen, then it indicates strong variations across cadences for the same module \n',...
        'output.This would warrant an in-depth analysis of the intermediate products left in the Matlab workspace. \n');

    set(h, 'UserData', sprintf(plotCaption));

    plot_to_file(titleStr, isLandscapeOrientationFlag, includeTimeFlag, printJpgFlag);
end
close all;
%-----------------------------------------------------
% centroidsMeanCols
%-----------------------------------------------------
h = figure;

centroidsMeanCols  = [pdqOutputStruct.outputPdqTsData.pdqModuleOutputTsData.centroidsMeanCols]; % an array of structs 1x84

centroidsMeanColsValues = [centroidsMeanCols.values]';

centroidsMeanColsUncertainties = [centroidsMeanCols.uncertainties]';

for j = 1:nCadences

    validModOuts = find(centroidsMeanColsValues(:,j) ~= -1);

    invalidModOuts = find(centroidsMeanColsValues(:,j) == -1);
    centroidsMeanColsUncertainties(invalidModOuts,j) = NaN;

    h1 = plot(modOuts(validModOuts), centroidsMeanColsValues(validModOuts,j),'.-', 'Color', cadenceColors(j,:));
    hold on;
    h2 = plot(modOuts(validModOuts), centroidsMeanColsValues(validModOuts,j) + centroidsMeanColsUncertainties(validModOuts,j),':', 'Color', cadenceColors(j,:));
    plot(modOuts(validModOuts), centroidsMeanColsValues(validModOuts,j) - centroidsMeanColsUncertainties(validModOuts,j),':', 'Color', cadenceColors(j,:));

end
if(~isempty(h1) || ~isempty(h2))

    set(gca, 'fontsize', 8);
    legend([h1 h2], {'Metric', 'Uncertainties'}, 'Location', 'Best');

    set(gca, 'xTick', (1:4:84)', 'xTickLabel', [2:4, 6:20, 22:24]');
    xlabel('Module  Number');
    ylabel('in pixel units');
    titleStr = (['Centroid column metric variation across the focal plane over ' num2str(nCadences) ' cadences']);
    title(titleStr);

    % Set plot caption for general use.
    % The official version of this caption is in summary-metrics.tex.
    plotCaption = strcat(...
        'The centroid column metric is calculated as follows: \n',...
        '\n',...
        '1. Use the recently computed pointing to compute the predicted centroid row, column positions of target stars \n',...
        '   (use ra_dec_2_pix on ra, dec of stars) \n',...
        '\n',...
        '2. Compute centroid column metric as the robust mean of \n',...
        '   {predicted centroid column positions - measured centroid column positions}\n\n',...
        'In this plot, centroid column metric metric variation over the focal plane over several cadences is plotted \n',...
        'along with the uncertainties.  \n',...
        ' \n',...
        'In general, if there is more than one cadence, one would expect to see plots for all the cadences merge into \n',...
        'one plot. If many plots are seen, then it indicates strong variations across cadences for the same module \n',...
        'output. This would warrant an in-depth analysis of the intermediate products left in the Matlab workspace. \n');

    set(h, 'UserData', sprintf(plotCaption));
    plot_to_file(titleStr, isLandscapeOrientationFlag, includeTimeFlag, printJpgFlag);
end
close all;
%-----------------------------------------------------
% encircledEnergies
%-----------------------------------------------------
h = figure;

encircledEnergies  = [pdqOutputStruct.outputPdqTsData.pdqModuleOutputTsData.encircledEnergies]; % an array of structs 1x84

encircledEnergiesValues = [encircledEnergies.values]';

encircledEnergiesUncertainties = [encircledEnergies.uncertainties]';
for j = 1:nCadences
    validModOuts = find(encircledEnergiesValues(:,j) ~= -1);

    invalidModOuts = find(encircledEnergiesValues(:,j) == -1);
    encircledEnergiesUncertainties(invalidModOuts, j) = NaN;

    h1 = plot(modOuts(validModOuts), encircledEnergiesValues(validModOuts,j),'.-', 'Color', cadenceColors(j,:));
    hold on;
    h2 = plot(modOuts(validModOuts), encircledEnergiesValues(validModOuts,j) + encircledEnergiesUncertainties(validModOuts,j),':', 'Color', cadenceColors(j,:));
    plot(modOuts(validModOuts), encircledEnergiesValues(validModOuts,j) - encircledEnergiesUncertainties(validModOuts,j),':', 'Color', cadenceColors(j,:));

end
if(~isempty(h1))
    set(gca, 'fontsize', 8);
    legend([h1 h2], {'Metric', 'Uncertainties'}, 'Location', 'Best');

    set(gca, 'xTick', (1:4:84)', 'xTickLabel', [2:4, 6:20, 22:24]');
    xlabel('Module  Number');
    ylabel('in pixel units');
    titleStr = (['Encircled energy metric variation across the focal plane over ' num2str(nCadences) ' cadences']);
    title(titleStr);


    plotCaption = strcat(...
        'The encircled energy metric is calculated as the distance in pixels at which 95 percent (a parameter) of the \n',...
        'target flux is enclosed. The estimate is based on a constrained polynomial fit (or erf or sigmoid function fit) \n',...
        'to the cumulative flux sorted as a function of radius.\n',...
        '\n',...
        'In this plot, encircled energy metric metric variation over the focal plane over several cadences is plotted along  \n',...
        'with the uncertainties.  \n',...
        ' \n',...
        'In general, if there is more than one cadence, one would expect to see plots for all the cadences merge into \n',...
        'one plot. If many plots are seen, then it indicates strong variations across cadences for the same module\n',...
        ' output. This would warrant an in-depth analysis of the intermediate products left in the Matlab workspace. \n');

    set(h, 'UserData', sprintf(plotCaption));
    plot_to_file(titleStr, isLandscapeOrientationFlag, includeTimeFlag, printJpgFlag);

end
close all;

%-----------------------------------------------------
% plateScales
%-----------------------------------------------------
h = figure;

plateScales  = [pdqOutputStruct.outputPdqTsData.pdqModuleOutputTsData.plateScales]; % an array of structs 1x84

plateScalesValues = [plateScales.values]';

plateScalesUncertainties = [plateScales.uncertainties]';

for j = 1:nCadences

    validModOuts = find(plateScalesValues(:,j) ~= -1);

    invalidModOuts = find(plateScalesValues(:,j) == -1);
    plateScalesUncertainties(invalidModOuts,j) = NaN;

    h1 = plot(modOuts(validModOuts), plateScalesValues(validModOuts,j),'.-', 'Color', cadenceColors(j,:));
    hold on;
    h2 = plot(modOuts(validModOuts), plateScalesValues(validModOuts,j) + plateScalesUncertainties(validModOuts,j),':', 'Color', cadenceColors(j,:));
    plot(modOuts(validModOuts), plateScalesValues(validModOuts,j) - plateScalesUncertainties(validModOuts,j),':', 'Color', cadenceColors(j,:));

end

if(~isempty(h1) || ~isempty(h2))

    set(gca, 'fontsize', 8);
    legend([h1 h2], {'Metric', 'Uncertainties'}, 'Location', 'Best');

    set(gca, 'xTick', (1:4:84)', 'xTickLabel', [2:4, 6:20, 22:24]');
    xlabel('Module  Number');
    ylabel('unitless') ;
    titleStr = (['Plate scale metric variation across the focal plane over ' num2str(nCadences) ' cadences']);
    title(titleStr);

    % Set plot caption for general use.
    % The official version of this caption is in summary-metrics.tex.
    plotCaption = strcat(...
        'The plate scale metric is calculated as follows: \n',...
        'For each cadence, \n',...
        '1. Measure centroid positions {row, col}. \n',...
        '2. Use the computed pointing from attitude solution for all the reference pixel time stamps \n',...
        '3. Invoke pix_2_ra_dec with the measured centroids, cadence time stamps, computed pointing, and the\n',...
        '    velocity aberration flag turned on to get their predicted {ra, dec} \n',...
        '4. Estimate w from the affine transformation (ratios of distances between points are preserved)\n',...
        '    defined by A*W = Y where \n',...
        '    A is the design matrix of size [nStars X 3], with the first two columns being ra, dec of stars \n',...
        '    from the catalog and the third column being a column of 1''s, and \n',...
        '    Y is a matrix of size [nStars X 2] with the two columns being predicted ra, dec of stars obtained \n',...
        '    by a transformation of measured centroids, and \n',...
        '    W is a matrix of size [3 X 2] with the first column containing the coefficients a, b, and c and \n',...
        '    the second column containing the coefficients d,e, and f. \n',...
        ' \n',...
        'The plate scale is computed as the determinant of the matrix composed of the the first two rows of W \n',...
        'and is equal to (a*e - b*d).\n',...
        '\n',...
        'In this plot, plate scale metric metric variation over the focal plane over several cadences is plotted \n',...
        'along with the uncertainties.  \n',...
        '\n',...
        'In general, if there is more than one cadence, one would expect to see plots for all the cadences merge into \n',...
        'one plot. If many plots are seen, then it indicates strong variations across cadences for the same module \n',...
        'output. This would warrant an in-depth analysis of the intermediate products left in the Matlab workspace. \n');

    set(h, 'UserData', sprintf(plotCaption));

    plot_to_file(titleStr, isLandscapeOrientationFlag, includeTimeFlag, printJpgFlag);
end
close all;
return

%
%         '           [ ra(1) dec(1) 1    ]                                                  [ raCat(1) decCat(1) ] \n',...
%         '           | ra(2) dec(2) 1    |                                                  | rCat(2)  decCat(2) | \n',...
%         '           |                   |                     [ a  d  ]                    |  .           .     | \n',...
%         'A   =      |                   |               w =   [ b  e  ]             b   =  |  .           .     | \n',...
%         '           |  .     .    .     |                     [ c   f ]                    |  .           .     | \n',...
%         '           |  .     .    .     |                                                  |  .           .     | \n',...
%         '           |   .     .         |                                                  |  .           .     | \n',...
%         '           [ ra(N) dec(N) 1    ]                                                  [ rCat(N)  decCat(N) ] \n',...
%         ' \n',...
%         '                        |  a     b | \n',...
%         ' plate scale is         |          |                 = ae - bd \n',...
%         '                        | d     e  | \n',...
%
