function construct_pdq_pipeline_run_validation_plots_type_2(pdqOutputStruct)

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% construct_pdq_pipeline_run_validation_plots_type_2.m
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
nModOuts = length(modOuts);
nCadences = length(pdqOutputStruct.outputPdqTsData.cadenceTimes);


% plot to file parameters
isLandscapeOrientationFlag = true;
includeTimeFlag = false;
printJpgFlag = false;

%Set rand to its default initial state:
rand('twister');
modOutColors = rand(nModOuts,3);
modOutColors(modOutColors <= eps) = 0.1;
xLocations = max(rand(nModOuts,1)*nCadences, 1);
%-----------------------------------------------------
% black levels
%-----------------------------------------------------
blackLevels  = [pdqOutputStruct.outputPdqTsData.pdqModuleOutputTsData.blackLevels]; % an array of structs 1x84

blackLevelValues = [blackLevels.values]';
blackLevelUncertainties = [blackLevels.uncertainties]';


commonStr = strcat(...
    'One would expect to see several plots all almost parallel to each other and to the x-axis. Each curve \n',...
    'is labelled with its modout number and can be easily identified if an abnormal value is observed in the plot. \n',...
    'An in-depth analysis of the intermediate products left in the Matlab workspace would be necessary to understand\n',...
    'the problem.\n');

h = figure;

for j = 1:nModOuts
    
    ccdModule = pdqOutputStruct.outputPdqTsData.pdqModuleOutputTsData(j).ccdModule;
    ccdOutput = pdqOutputStruct.outputPdqTsData.pdqModuleOutputTsData(j).ccdOutput;
    modOut = convert_from_module_output(ccdModule,ccdOutput);
    modOutStr = {[num2str(modOut) ' [' num2str(ccdModule) ',' num2str(ccdOutput) ']']};
    
    validCadences = find(blackLevelValues(j,:) ~= -1);
    h1 = plot(validCadences, blackLevelValues(j,validCadences),'.-', 'Color', modOutColors(j,:));
    hold on;
    h2 = plot(validCadences, blackLevelValues(j,validCadences) + blackLevelUncertainties(j,validCadences),':', 'Color', modOutColors(j,:));
    plot(validCadences, blackLevelValues(j,validCadences) - blackLevelUncertainties(j,validCadences),':', 'Color', modOutColors(j,:));

    % Added check for empty array --RLM
    if(~isempty(validCadences))
        text(xLocations(j), blackLevelValues(j,validCadences(1)), modOutStr, 'fontsize',9);
    end 
end
if(~isempty(validCadences))
    
    set(gca, 'fontsize', 8);
    legend([h1 h2], {'Metric', 'Uncertainties'}, 'Location', 'Best');
    set(gca, 'xTick', 1:nCadences, 'xTickLabel', 1:nCadences+1);
    ylabel('in ADU');
    xlabel('Cadence Number');
    xlim([0 nCadences+1]);
    titleStr = (['Black level metric variation across the focal plane over ' num2str(nModOuts) ' modouts']);
    
    
    plotCaption = strcat(...
        'In this plot, black metric variation over several cadences is plotted along with the uncertainties for each \n',...
        'and every modout. \n',...
        'In general, if there are several cadences, one would expect to see the black level metric stay stable across \n',...
        'the cadences for each modout, with the black level metric value varying from modout to modout. \n',...
        ' \n',...
        commonStr);
    
    set(h, 'UserData', sprintf(plotCaption));
    
    title(titleStr);
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

for j = 1:nModOuts
    
    ccdModule = pdqOutputStruct.outputPdqTsData.pdqModuleOutputTsData(j).ccdModule;
    ccdOutput = pdqOutputStruct.outputPdqTsData.pdqModuleOutputTsData(j).ccdOutput;
    modOut = convert_from_module_output(ccdModule,ccdOutput);
    modOutStr = {[num2str(modOut) ' [' num2str(ccdModule) ',' num2str(ccdOutput) ']']};
    
    
    validCadences = find(smearLevelValues(j,:) ~= -1);
    h1 = plot(validCadences, smearLevelValues(j,validCadences),'.-', 'Color', modOutColors(j,:));
    hold on;
    h2 = plot(validCadences, smearLevelValues(j,validCadences) + smearLevelUncertainties(j,validCadences),':', 'Color', modOutColors(j,:));
    plot(validCadences, smearLevelValues(j,validCadences) - smearLevelUncertainties(j,validCadences),':', 'Color', modOutColors(j,:));

    % Added check for empty array --RLM
    if(~isempty(validCadences))
        text(xLocations(j), smearLevelValues(j,validCadences(1)), modOutStr, 'fontsize',9);
    end
    
end
if(~isempty(validCadences))
    
    set(gca, 'fontsize', 8);
    legend([h1 h2], {'Metric', 'Uncertainties'}, 'Location', 'Best');
    set(gca, 'xTick', 1:nCadences, 'xTickLabel', 1:nCadences+1);
    ylabel('in photoelectrons');
    xlabel('Cadence Number');
    xlim([0 nCadences+1]);
    titleStr = (['Smear level metric variation across the focal plane over ' num2str(nModOuts) ' modouts']);
    
    title(titleStr);
    
    plotCaption = strcat(...
        'In this plot, smear metric variation over several cadences is plotted along with the uncertainties for each \n',...
        'and every modout. \n',...
        ' \n',...
        'In general, if there are several cadences, one would expect to see the smear level metric stay stable across \n',...
        'the cadences for each modout, with the smear level metric value varying from modout to modout. \n',...
        ' \n',...
        commonStr);
    
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
for j = 1:nModOuts
    
    ccdModule = pdqOutputStruct.outputPdqTsData.pdqModuleOutputTsData(j).ccdModule;
    ccdOutput = pdqOutputStruct.outputPdqTsData.pdqModuleOutputTsData(j).ccdOutput;
    modOut = convert_from_module_output(ccdModule,ccdOutput);
    modOutStr = {[num2str(modOut) ' [' num2str(ccdModule) ',' num2str(ccdOutput) ']']};
    
    validCadences = find(darkCurrentsValues(j,:) ~= -1);
    h1 = plot(validCadences, darkCurrentsValues(j,validCadences),'.-', 'Color', modOutColors(j,:));
    hold on;
    h2 = plot(validCadences, darkCurrentsValues(j,validCadences) + darkCurrentsUncertainties(j,validCadences),':', 'Color', modOutColors(j,:));
    plot(validCadences, darkCurrentsValues(j,validCadences) - darkCurrentsUncertainties(j,validCadences),':', 'Color', modOutColors(j,:));

    % Added check for empty array --RLM
    if(~isempty(validCadences))
        text(xLocations(j), darkCurrentsValues(j,validCadences(1)), modOutStr, 'fontsize',9);
    end
end
if(~isempty(validCadences))
    
    set(gca, 'fontsize', 8);
    legend([h1 h2], {'Metric', 'Uncertainties'}, 'Location', 'Best');
    set(gca, 'xTick', 1:nCadences, 'xTickLabel', 1:nCadences+1);
    xlabel('Cadence Number');
    ylabel('in photoelectrons/sec/exposure');
    xlim([0 nCadences+1]);
    titleStr = (['Dark current metric variation across the focal plane over ' num2str(nModOuts) ' modouts']);
    
    title(titleStr);
    
    plotCaption = strcat(...
        'In this plot, dark current metric variation over several cadences is plotted along with the uncertainties for each \n',...
        'and every modout. \n',...
        ' \n',...
        'In general, if there are several cadences, one would expect to see the dark current metric stay stable across \n',...
        'the cadences for each modout, with the dark current metric value varying from modout to modout. \n',...
        ' \n',...
        commonStr);
    
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
for j = 1:nModOuts
    
    ccdModule = pdqOutputStruct.outputPdqTsData.pdqModuleOutputTsData(j).ccdModule;
    ccdOutput = pdqOutputStruct.outputPdqTsData.pdqModuleOutputTsData(j).ccdOutput;
    modOut = convert_from_module_output(ccdModule,ccdOutput);
    modOutStr = {[num2str(modOut) ' [' num2str(ccdModule) ',' num2str(ccdOutput) ']']};
    
    validCadences = find(backgroundLevelsValues(j,:) ~= -1);
    h1 = plot(validCadences, backgroundLevelsValues(j,validCadences),'.-', 'Color', modOutColors(j,:));
    hold on;
    h2 = plot(validCadences, backgroundLevelsValues(j,validCadences) + backgroundLevelsUncertainties(j,validCadences),':', 'Color', modOutColors(j,:));
    plot(validCadences, backgroundLevelsValues(j,validCadences) - backgroundLevelsUncertainties(j,validCadences),':', 'Color', modOutColors(j,:));
    % Added check for empty array --RLM
    if(~isempty(validCadences))
        text(xLocations(j), backgroundLevelsValues(j,validCadences(1)), modOutStr, 'fontsize',9);
    end
end
if(~isempty(validCadences))
    
    set(gca, 'fontsize', 8);
    legend([h1 h2], {'Metric', 'Uncertainties'}, 'Location', 'Best');
    
    set(gca, 'xTick', 1:nCadences, 'xTickLabel', 1:nCadences+1);
    xlabel('Cadence Number');
    ylabel('in photoelectrons');
    xlim([0 nCadences+1]);
    titleStr = (['Background level metric variation across the focal plane over ' num2str(nModOuts) ' modouts']);
    title(titleStr);
    
    plotCaption = strcat(...
        'In this plot, background level variation over several cadences is plotted along with the uncertainties for each \n',...
        'and every modout. \n',...
        ' \n',...
        'In general, if there are several cadences, one would expect to see the background level metric stay stable across \n',...
        'the cadences for each modout, with the background level metric value varying from modout to modout. \n',...
        ' \n',...
        commonStr);
    
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

for j = 1:nModOuts
    
    ccdModule = pdqOutputStruct.outputPdqTsData.pdqModuleOutputTsData(j).ccdModule;
    ccdOutput = pdqOutputStruct.outputPdqTsData.pdqModuleOutputTsData(j).ccdOutput;
    modOut = convert_from_module_output(ccdModule,ccdOutput);
    modOutStr = {[num2str(modOut) ' [' num2str(ccdModule) ',' num2str(ccdOutput) ']']};
    
    validCadences = find(dynamicRangesValues(j,:) ~= -1);
    h1 = plot(validCadences, dynamicRangesValues(j,validCadences),'.-', 'Color', modOutColors(j,:));
    hold on;
    h2 = plot(validCadences, dynamicRangesValues(j,validCadences) + dynamicRangesUncertainties(j,validCadences),':', 'Color', modOutColors(j,:));
    plot(validCadences, dynamicRangesValues(j,validCadences) - dynamicRangesUncertainties(j,validCadences),':', 'Color', modOutColors(j,:));
    % Added check for empty array --RLM
    if(~isempty(validCadences))
        text(xLocations(j), dynamicRangesValues(j,validCadences(1)), modOutStr, 'fontsize',9);
    end
end
if(~isempty(validCadences))
    
    legend([h1 h2], {'Metric', 'Uncertainties'}, 'Location', 'Best');
    
    set(gca, 'xTick', 1:nCadences, 'xTickLabel', 1:nCadences+1);
    xlabel('Cadence Number');
    
    ylabel('in ADU/exposure');
    xlim([0 nCadences+1]);
    titleStr = (['Dynamic range metric variation across the focal plane over ' num2str(nModOuts) ' modouts']);
    
    title(titleStr);
    
    plotCaption = strcat(...
        'In this plot, dynamic range variation over several cadences is plotted along with the uncertainties for each \n',...
        'and every modout. \n',...
        ' \n',...
        'In general, if there are several cadences, one would expect to see the dynamic range metric stay stable across \n',...
        'the cadences for each modout, with the dynamic range metric value varying from modout to modout. \n',...
        ' \n',...
        commonStr);
    
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

for j = 1:nModOuts
    
    ccdModule = pdqOutputStruct.outputPdqTsData.pdqModuleOutputTsData(j).ccdModule;
    ccdOutput = pdqOutputStruct.outputPdqTsData.pdqModuleOutputTsData(j).ccdOutput;
    modOut = convert_from_module_output(ccdModule,ccdOutput);
    modOutStr = {[num2str(modOut) ' [' num2str(ccdModule) ',' num2str(ccdOutput) ']']};
    
    validCadences = find(meanFluxesValues(j,:) ~= -1);
    h1 = plot(validCadences, meanFluxesValues(j,validCadences),'.-', 'Color', modOutColors(j,:));
    hold on;
    h2 = plot(validCadences, meanFluxesValues(j,validCadences) + meanFluxesUncertainties(j,validCadences),':', 'Color', modOutColors(j,:));
    plot(validCadences, meanFluxesValues(j,validCadences) - meanFluxesUncertainties(j,validCadences),':', 'Color', modOutColors(j,:));
    % Added check for empty array --RLM
    if(~isempty(validCadences))
        text(xLocations(j), meanFluxesValues(j,validCadences(1)), modOutStr, 'fontsize',9);
    end
end
if(~isempty(validCadences))
    
    set(gca, 'fontsize', 8);
    legend([h1 h2], {'Metric', 'Uncertainties'}, 'Location', 'Best');
    
    set(gca, 'xTick', 1:nCadences, 'xTickLabel', 1:nCadences+1);
    xlabel('Cadence Number');
    ylabel('unitless ratio');
    xlim([0 nCadences+1]);
    titleStr = (['Brightness metric variation across the focal plane over ' num2str(nModOuts) ' modouts']);
    
    title(titleStr);
    
    plotCaption = strcat(...
        'In this plot, brightness metric variation over several cadences is plotted along with the uncertainties for each \n',...
        'and every modout. \n',...
        ' \n',...
        'In general, if there are several cadences, one would expect to see the brightness metric stay stable across \n',...
        'the cadences for each modout, with the brightness metric value varying from modout to modout. \n',...
        ' \n',...
        commonStr);
    
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

for j = 1:nModOuts
    
    ccdModule = pdqOutputStruct.outputPdqTsData.pdqModuleOutputTsData(j).ccdModule;
    ccdOutput = pdqOutputStruct.outputPdqTsData.pdqModuleOutputTsData(j).ccdOutput;
    modOut = convert_from_module_output(ccdModule,ccdOutput);
    modOutStr = {[num2str(modOut) ' [' num2str(ccdModule) ',' num2str(ccdOutput) ']']};
    
    validCadences = find(centroidsMeanRowsValues(j,:) ~= -1);
    
    invalidCadences = find(centroidsMeanRowsValues(j,:) == -1);
    centroidsMeanRowsUncertainties(j,invalidCadences) = NaN;
    
    if(~isempty(validCadences))
        h1 = plot(validCadences, centroidsMeanRowsValues(j,validCadences),'.-', 'Color', modOutColors(j,:));
        hold on;
        h2 = plot(validCadences, centroidsMeanRowsValues(j,validCadences) + centroidsMeanRowsUncertainties(j,validCadences),':', 'Color', modOutColors(j,:));
        plot(validCadences, centroidsMeanRowsValues(j,validCadences) - centroidsMeanRowsUncertainties(j,validCadences),':', 'Color', modOutColors(j,:));
        % Added check for empty array --RLM
        if(~isempty(validCadences))
            text(xLocations(j), centroidsMeanRowsValues(j,validCadences(1)), modOutStr, 'fontsize',9);
        end
    end
    
end
if(~isempty(validCadences))
    
    set(gca, 'fontsize', 8);
    legend([h1 h2], {'Metric', 'Uncertainties'}, 'Location', 'Best');
    
    set(gca, 'xTick', 1:nCadences, 'xTickLabel', 1:nCadences+1);
    xlabel('Cadence Number');
    ylabel('in pixel units');
    xlim([0 nCadences+1]);
    titleStr = (['Centroid row metric variation across the focal plane over ' num2str(nModOuts) ' modouts']);
    
    title(titleStr);
    
    plotCaption = strcat(...
        'In this plot, centroid row metric variation over several cadences is plotted along with the uncertainties for each \n',...
        'and every modout. \n',...
        ' \n',...
        'In general, if there are several cadences, one would expect to see the centroid row metric stay stable across \n',...
        'the cadences for each modout, with the centroid row metric value varying from modout to modout. \n',...
        ' \n',...
        commonStr);
    
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

for j = 1:nModOuts
    
    ccdModule = pdqOutputStruct.outputPdqTsData.pdqModuleOutputTsData(j).ccdModule;
    ccdOutput = pdqOutputStruct.outputPdqTsData.pdqModuleOutputTsData(j).ccdOutput;
    modOut = convert_from_module_output(ccdModule,ccdOutput);
    modOutStr = {[num2str(modOut) ' [' num2str(ccdModule) ',' num2str(ccdOutput) ']']};
    
    validCadences = find(centroidsMeanColsValues(j,:) ~= -1);
    
    invalidCadences = find(centroidsMeanColsValues(j,:) == -1);
    centroidsMeanColsUncertainties(j,invalidCadences) = NaN;
    
    if(~isempty(validCadences))
        
        h1 = plot(validCadences, centroidsMeanColsValues(j,validCadences),'.-', 'Color', modOutColors(j,:));
        hold on;
        h2 = plot(validCadences, centroidsMeanColsValues(j,validCadences) + centroidsMeanColsUncertainties(j,validCadences),':', 'Color', modOutColors(j,:));
        plot(validCadences, centroidsMeanColsValues(j,validCadences) - centroidsMeanColsUncertainties(j,validCadences),':', 'Color', modOutColors(j,:));
        % Added check for empty array --RLM
        if(~isempty(validCadences))
            text(xLocations(j), centroidsMeanColsValues(j,validCadences(1)), modOutStr, 'fontsize',9);
        end
    end
    
end
if(~isempty(validCadences))
    
    set(gca, 'fontsize', 8);
    legend([h1 h2], {'Metric', 'Uncertainties'}, 'Location', 'Best');
    
    set(gca, 'xTick', 1:nCadences, 'xTickLabel', 1:nCadences+1);
    xlabel('Cadence Number');
    ylabel('in pixel units');
    xlim([0 nCadences+1]);
    titleStr = (['Centroid column metric variation across the focal plane over ' num2str(nModOuts) ' modouts']);
    title(titleStr);
    
    plotCaption = strcat(...
        'In this plot, centroid column metric variation over several cadences is plotted along with the uncertainties for each \n',...
        'and every modout. \n',...
        ' \n',...
        'In general, if there are several cadences, one would expect to see the centroid column metric stay stable across \n',...
        'the cadences for each modout, with the centroid column metric value varying from modout to modout. \n',...
        ' \n',...
        commonStr);
    
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

for j = 1:nModOuts
    
    ccdModule = pdqOutputStruct.outputPdqTsData.pdqModuleOutputTsData(j).ccdModule;
    ccdOutput = pdqOutputStruct.outputPdqTsData.pdqModuleOutputTsData(j).ccdOutput;
    modOut = convert_from_module_output(ccdModule,ccdOutput);
    modOutStr = {[num2str(modOut) ' [' num2str(ccdModule) ',' num2str(ccdOutput) ']']};
    
    validCadences = find(encircledEnergiesValues(j,:) ~= -1);
    
    invalidCadences = find(encircledEnergiesValues(j,:) == -1);
    encircledEnergiesUncertainties(j,invalidCadences) = NaN;
    
    if(isempty(validCadences))
        continue;
    end
    
    h1 = plot(validCadences, encircledEnergiesValues(j,validCadences),'.-', 'Color', modOutColors(j,:));
    hold on;
    h2 = plot(validCadences, encircledEnergiesValues(j,validCadences) + encircledEnergiesUncertainties(j,validCadences),':', 'Color', modOutColors(j,:));
    plot(validCadences, encircledEnergiesValues(j,validCadences) - encircledEnergiesUncertainties(j,validCadences),':', 'Color', modOutColors(j,:));
    % Added check for empty array --RLM
    if(~isempty(validCadences))
        text(xLocations(j), encircledEnergiesValues(j,validCadences(1)), modOutStr, 'fontsize',9);
    end
    
end
if(~isempty(validCadences))
    
    set(gca, 'fontsize', 8);
    legend([h1 h2], {'Metric', 'Uncertainties'}, 'Location', 'Best');
    
    set(gca, 'xTick', 1:nCadences, 'xTickLabel', 1:nCadences+1);
    xlabel('Cadence Number');
    ylabel('in pixel units');
    xlim([0 nCadences+1]);
    titleStr = (['Encircled energy metric variation across the focal plane over ' num2str(nModOuts) ' modouts']);
    title(titleStr);
    
    plotCaption = strcat(...
        'In this plot, encircled energy metric variation over several cadences is plotted along with the uncertainties for each \n',...
        'and every modout. \n',...
        ' \n',...
        'In general, if there are several cadences, one would expect to see the encircled energy metric stay stable across \n',...
        'the cadences for each modout, with the encircled energy metric value varying from modout to modout. \n',...
        ' \n',...
        commonStr);
    
    set(h, 'UserData', sprintf(plotCaption));
    
    plot_to_file(titleStr, isLandscapeOrientationFlag, includeTimeFlag, printJpgFlag);
    
end
close all;
figure;
%-----------------------------------------------------
% plateScales
%-----------------------------------------------------

plateScales  = [pdqOutputStruct.outputPdqTsData.pdqModuleOutputTsData.plateScales]; % an array of structs 1x84

plateScalesValues = [plateScales.values]';

plateScalesUncertainties = [plateScales.uncertainties]';

for j = 1:nModOuts
    
    ccdModule = pdqOutputStruct.outputPdqTsData.pdqModuleOutputTsData(j).ccdModule;
    ccdOutput = pdqOutputStruct.outputPdqTsData.pdqModuleOutputTsData(j).ccdOutput;
    modOut = convert_from_module_output(ccdModule,ccdOutput);
    modOutStr = {[num2str(modOut) ' [' num2str(ccdModule) ',' num2str(ccdOutput) ']']};
    
    validCadences = find(plateScalesValues(j,:) ~= -1);
    
    invalidCadences = find(plateScalesValues(j,:) == -1);
    plateScalesUncertainties(j,invalidCadences) = NaN;
    
    if(isempty(validCadences))
        continue;
    end
    h1 = plot(validCadences, plateScalesValues(j,validCadences),'.-', 'Color', modOutColors(j,:));
    hold on;
    h2 = plot(validCadences, plateScalesValues(j,validCadences) + plateScalesUncertainties(j,validCadences),':', 'Color', modOutColors(j,:));
    plot(validCadences, plateScalesValues(j,validCadences) - plateScalesUncertainties(j,validCadences),':', 'Color', modOutColors(j,:));
    % Added check for empty array --RLM
    if(~isempty(validCadences))
        text(xLocations(j), plateScalesValues(j,validCadences(1)), modOutStr, 'fontsize',9);
    end
    
end

if(~isempty(validCadences))
    
    set(gca, 'fontsize', 8);
    legend([h1 h2], {'Metric', 'Uncertainties'}, 'Location', 'Best');
    
    set(gca, 'xTick', 1:nCadences, 'xTickLabel', 1:nCadences+1);     ylabel('in ADU');
    xlabel('Cadence Number');
    ylabel('unitless');
    xlim([0 nCadences+1]);
    titleStr = (['Plate scale metric variation across the focal plane over ' num2str(nModOuts) ' modouts']);
    title(titleStr);
    
    
    plotCaption = strcat(...
        'In this plot, plate scale metric variation over several cadences is plotted along with theuncertainties for each \n',...
        'and every modout. \n',...
        ' \n',...
        'In general, if there are several cadences, one would expect to see the plate scale metric stay stable across \n',...
        'the cadences for each modout, with the plate scale metric value varying from modout to modout. \n',...
        ' \n',...
        commonStr);
    
    set(h, 'UserData', sprintf(plotCaption));
    
    plot_to_file(titleStr, isLandscapeOrientationFlag, includeTimeFlag, printJpgFlag);
end

close all;
return


