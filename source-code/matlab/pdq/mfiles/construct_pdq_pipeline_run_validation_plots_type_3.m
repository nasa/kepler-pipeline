function construct_pdq_pipeline_run_validation_plots_type_3(so, sogap, modOutToCompare)

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% construct_pdq_pipeline_run_validation_plots_type_3.m
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


ccdModules1 = cat(1,so.outputPdqTsData.pdqModuleOutputTsData.ccdModule);
ccdOutputs1 = cat(1,so.outputPdqTsData.pdqModuleOutputTsData.ccdOutput);

modOuts1 = convert_from_module_output(ccdModules1, ccdOutputs1);

indexToModOut1 = find(modOuts1 == modOutToCompare);


ccdModules2 = cat(1,sogap.outputPdqTsData.pdqModuleOutputTsData.ccdModule);
ccdOutputs2 = cat(1,sogap.outputPdqTsData.pdqModuleOutputTsData.ccdOutput);

modOuts2 = convert_from_module_output(ccdModules2, ccdOutputs2);


indexToModOut2 = find(modOuts2 == modOutToCompare);


if(isempty(indexToModOut1) ||isempty(indexToModOut2))

    warning('PDQ:construct_pdq_pipeline_run_validation_plots_type_3',...
        ['Modout ' num2str(modOutToCompare) ' was not found in both the output struct; hence can''t comapre']);
    return
end



ccdModule = so.outputPdqTsData.pdqModuleOutputTsData(indexToModOut1).ccdModule;
ccdOutput = so.outputPdqTsData.pdqModuleOutputTsData(indexToModOut1).ccdOutput;

modOut = convert_from_module_output(ccdModule, ccdOutput);


cadenceTimes = so.outputPdqTsData.cadenceTimes;
[cadenceTimeStamps, validCadences] = intersect(cadenceTimes, sogap.outputPdqTsData.cadenceTimes);

% plot to file parameters
isLandscapeOrientationFlag = true;
includeTimeFlag = false;
printJpgFlag = false;

%-----------------------------------------------------
% black levels
%-----------------------------------------------------
blackLevels  = [so.outputPdqTsData.pdqModuleOutputTsData(indexToModOut1).blackLevels]; % an array of structs 1x84
blackLevelValues = [blackLevels.values]';
blackLevelUncertainties = [blackLevels.uncertainties]';



h1 = plot(cadenceTimes, blackLevelValues,'m.-');
hold on;
plot(cadenceTimes, blackLevelValues + blackLevelUncertainties,'m:');
plot(cadenceTimes, blackLevelValues - blackLevelUncertainties,'m:');


blackLevelsWithGaps  = [sogap.outputPdqTsData.pdqModuleOutputTsData(indexToModOut2).blackLevels]; % an array of structs 1x84
blackLevelValuesWithGaps = [blackLevelsWithGaps.values]';
blackLevelUncertaintiesWithGaps = [blackLevelsWithGaps.uncertainties]';


h2 = plot(cadenceTimes(validCadences), blackLevelValuesWithGaps,'ko-');
hold on;
plot(cadenceTimes(validCadences), blackLevelValuesWithGaps + blackLevelUncertaintiesWithGaps,'k:');
plot(cadenceTimes(validCadences), blackLevelValuesWithGaps - blackLevelUncertaintiesWithGaps,'k:');


legend([h1 h2], {'complete', 'with gaps'}, 'Location', 'Best');
ylabel('in ADU');
xlabel('Cadence Number');
titleStr = (['Blacklevel metric for module ' num2str(ccdModule) ' output ' num2str(ccdOutput) ' modout ' num2str(modOut)]);

title(titleStr);
plot_to_file(titleStr, isLandscapeOrientationFlag, includeTimeFlag, printJpgFlag);

close all;
%-----------------------------------------------------
% smear levels
%-----------------------------------------------------

figure;
smearLevels  = [so.outputPdqTsData.pdqModuleOutputTsData(indexToModOut1).smearLevels]; % an array of structs 1x84
smearLevelValues = [smearLevels.values]';
smearLevelUncertainties = [smearLevels.uncertainties]';

h1 = plot(cadenceTimes, smearLevelValues,'m.-');
hold on;
plot(cadenceTimes, smearLevelValues + smearLevelUncertainties,'m:');
plot(cadenceTimes, smearLevelValues - smearLevelUncertainties,'m:');


smearLevelsWithGaps  = [sogap.outputPdqTsData.pdqModuleOutputTsData(indexToModOut2).smearLevels]; % an array of structs 1x84
smearLevelValuesWithGaps = [smearLevelsWithGaps.values]';
smearLevelUncertaintiesWithGaps = [smearLevelsWithGaps.uncertainties]';

h2 = plot(cadenceTimes(validCadences), smearLevelValuesWithGaps,'ko-');
hold on;
plot(cadenceTimes(validCadences), smearLevelValuesWithGaps + smearLevelUncertaintiesWithGaps,'k:');
plot(cadenceTimes(validCadences), smearLevelValuesWithGaps - smearLevelUncertaintiesWithGaps,'k:');


legend([h1 h2], {'complete', 'with gaps'}, 'Location', 'Best');
ylabel('in photoelectrons');
xlabel('Cadence Number');
titleStr = (['Smearlevel metric for module ' num2str(ccdModule) ' output ' num2str(ccdOutput) ' modout ' num2str(modOut)]);


title(titleStr);
plot_to_file(titleStr, isLandscapeOrientationFlag, includeTimeFlag, printJpgFlag);

close all;

%-----------------------------------------------------
% dark currents
%-----------------------------------------------------
figure;

darkCurrents  = [so.outputPdqTsData.pdqModuleOutputTsData(indexToModOut1).darkCurrents]; % an array of structs 1x84
darkCurrentsValues = [darkCurrents.values]';
darkCurrentsUncertainties = [darkCurrents.uncertainties]';

h1 = plot(cadenceTimes, darkCurrentsValues,'m.-');
hold on;
plot(cadenceTimes, darkCurrentsValues + darkCurrentsUncertainties,'m:');
plot(cadenceTimes, darkCurrentsValues - darkCurrentsUncertainties,'m:');


darkCurrentsWithGaps  = [sogap.outputPdqTsData.pdqModuleOutputTsData(indexToModOut2).darkCurrents]; % an array of structs 1x84
darkCurrentsValuesWithGaps = [darkCurrentsWithGaps.values]';
darkCurrentsUncertaintiesWithGaps = [darkCurrentsWithGaps.uncertainties]';

h2 = plot(cadenceTimes(validCadences), darkCurrentsValuesWithGaps,'ko-');
hold on;
plot(cadenceTimes(validCadences), darkCurrentsValuesWithGaps + darkCurrentsUncertaintiesWithGaps,'k:');
plot(cadenceTimes(validCadences), darkCurrentsValuesWithGaps - darkCurrentsUncertaintiesWithGaps,'k:');


legend([h1 h2], {'complete', 'with gaps'}, 'Location', 'Best');
ylabel('in photoelectrons/sec/exposure');
xlabel('Cadence Number');
titleStr = (['Dark current metric for module ' num2str(ccdModule) ' output ' num2str(ccdOutput) ' modout ' num2str(modOut)]);


title(titleStr);
plot_to_file(titleStr, isLandscapeOrientationFlag, includeTimeFlag, printJpgFlag);

close all;
%-----------------------------------------------------
% backgroundLevels
%-----------------------------------------------------
figure;

backgroundLevels  = [so.outputPdqTsData.pdqModuleOutputTsData(indexToModOut1).backgroundLevels]; % an array of structs 1x84
backgroundLevelsValues = [backgroundLevels.values]';
backgroundLevelsUncertainties = [backgroundLevels.uncertainties]';

h1 = plot(cadenceTimes, backgroundLevelsValues,'m.-');
hold on;
plot(cadenceTimes, backgroundLevelsValues + backgroundLevelsUncertainties,'m:');
plot(cadenceTimes, backgroundLevelsValues - backgroundLevelsUncertainties,'m:');


backgroundLevelsWithGaps  = [sogap.outputPdqTsData.pdqModuleOutputTsData(indexToModOut2).backgroundLevels]; % an array of structs 1x84
backgroundLevelsValuesWithGaps = [backgroundLevelsWithGaps.values]';
backgroundLevelsUncertaintiesWithGaps = [backgroundLevelsWithGaps.uncertainties]';

h2 = plot(cadenceTimes(validCadences), backgroundLevelsValuesWithGaps,'ko-');
hold on;
plot(cadenceTimes(validCadences), backgroundLevelsValuesWithGaps + backgroundLevelsUncertaintiesWithGaps,'k:');
plot(cadenceTimes(validCadences), backgroundLevelsValuesWithGaps - backgroundLevelsUncertaintiesWithGaps,'k:');


legend([h1 h2], {'complete', 'with gaps'}, 'Location', 'Best');
ylabel('in photoelectrons');
xlabel('Cadence Number');
titleStr = (['Background level metric for module ' num2str(ccdModule) ' output ' num2str(ccdOutput) ' modout ' num2str(modOut)]);

title(titleStr);
plot_to_file(titleStr, isLandscapeOrientationFlag, includeTimeFlag, printJpgFlag);

close all;

%-----------------------------------------------------
% dynamicRanges
%-----------------------------------------------------
figure;

dynamicRanges  = [so.outputPdqTsData.pdqModuleOutputTsData(indexToModOut1).dynamicRanges]; % an array of structs 1x84
dynamicRangesValues = [dynamicRanges.values]';
dynamicRangesUncertainties = [dynamicRanges.uncertainties]';

h1 = plot(cadenceTimes, dynamicRangesValues,'m.-');
hold on;
plot(cadenceTimes, dynamicRangesValues + dynamicRangesUncertainties,'m:');
plot(cadenceTimes, dynamicRangesValues - dynamicRangesUncertainties,'m:');



dynamicRangesWithGaps  = [sogap.outputPdqTsData.pdqModuleOutputTsData(indexToModOut2).dynamicRanges]; % an array of structs 1x84
dynamicRangesValuesWithGaps = [dynamicRangesWithGaps.values]';
dynamicRangesUncertaintiesWithGaps = [dynamicRangesWithGaps.uncertainties]';

h2 = plot(cadenceTimes(validCadences), dynamicRangesValuesWithGaps,'ko-');
hold on;
plot(cadenceTimes(validCadences), dynamicRangesValuesWithGaps + dynamicRangesUncertaintiesWithGaps,'k:');
plot(cadenceTimes(validCadences), dynamicRangesValuesWithGaps - dynamicRangesUncertaintiesWithGaps,'k:');


legend([h1 h2], {'complete', 'with gaps'}, 'Location', 'Best');
ylabel('in ADU/exposure');
xlabel('Cadence Number');
titleStr = (['Dynamic ranges metric for module ' num2str(ccdModule) ' output ' num2str(ccdOutput) ' modout ' num2str(modOut)]);


title(titleStr);
plot_to_file(titleStr, isLandscapeOrientationFlag, includeTimeFlag, printJpgFlag);

close all;
%-----------------------------------------------------
% meanFluxes
%-----------------------------------------------------
figure;

meanFluxes  = [so.outputPdqTsData.pdqModuleOutputTsData(indexToModOut1).meanFluxes]; % an array of structs 1x84
meanFluxesValues = [meanFluxes.values]';
meanFluxesUncertainties = [meanFluxes.uncertainties]';

h1 = plot(cadenceTimes, meanFluxesValues,'m.-');
hold on;
plot(cadenceTimes, meanFluxesValues + meanFluxesUncertainties,'m:');
plot(cadenceTimes, meanFluxesValues - meanFluxesUncertainties,'m:');


meanFluxesWithGaps  = [sogap.outputPdqTsData.pdqModuleOutputTsData(indexToModOut2).meanFluxes]; % an array of structs 1x84
meanFluxesValuesWithGaps = [meanFluxesWithGaps.values]';
meanFluxesUncertaintiesWithGaps = [meanFluxesWithGaps.uncertainties]';

h2 = plot(cadenceTimes(validCadences), meanFluxesValuesWithGaps,'ko-');
hold on;
plot(cadenceTimes(validCadences), meanFluxesValuesWithGaps + meanFluxesUncertaintiesWithGaps,'k:');
plot(cadenceTimes(validCadences), meanFluxesValuesWithGaps - meanFluxesUncertaintiesWithGaps,'k:');


legend([h1 h2], {'complete', 'with gaps'}, 'Location', 'Best');
ylabel('unitless ratio');
xlabel('Cadence Number');
titleStr = (['Mean fluxes metric for module ' num2str(ccdModule) ' output ' num2str(ccdOutput) ' modout ' num2str(modOut)]);


title(titleStr);
plot_to_file(titleStr, isLandscapeOrientationFlag, includeTimeFlag, printJpgFlag);

close all;
%-----------------------------------------------------
% centroidsMeanRows
%-----------------------------------------------------
figure;

centroidsMeanRows  = [so.outputPdqTsData.pdqModuleOutputTsData(indexToModOut1).centroidsMeanRows]; % an array of structs 1x84
centroidsMeanRowsValues = [centroidsMeanRows.values]';
centroidsMeanRowsUncertainties = [centroidsMeanRows.uncertainties]';

h1 = plot(cadenceTimes, centroidsMeanRowsValues,'m.-');
hold on;
plot(cadenceTimes, centroidsMeanRowsValues + centroidsMeanRowsUncertainties,'m:');
plot(cadenceTimes, centroidsMeanRowsValues - centroidsMeanRowsUncertainties,'m:');


centroidsMeanRowsWithGaps  = [sogap.outputPdqTsData.pdqModuleOutputTsData(indexToModOut2).centroidsMeanRows]; % an array of structs 1x84
centroidsMeanRowsValuesWithGaps = [centroidsMeanRowsWithGaps.values]';
centroidsMeanRowsUncertaintiesWithGaps = [centroidsMeanRowsWithGaps.uncertainties]';

h2 = plot(cadenceTimes(validCadences), centroidsMeanRowsValuesWithGaps,'ko-');
hold on;
plot(cadenceTimes(validCadences), centroidsMeanRowsValuesWithGaps + centroidsMeanRowsUncertaintiesWithGaps,'k:');
plot(cadenceTimes(validCadences), centroidsMeanRowsValuesWithGaps - centroidsMeanRowsUncertaintiesWithGaps,'k:');


legend([h1 h2], {'complete', 'with gaps'}, 'Location', 'Best');
ylabel('in pixel units');
xlabel('Cadence Number');
titleStr = (['centroidsMeanRows metric for module ' num2str(ccdModule) ' output ' num2str(ccdOutput) ' modout ' num2str(modOut)]);


title(titleStr);
plot_to_file(titleStr, isLandscapeOrientationFlag, includeTimeFlag, printJpgFlag);

close all;
%-----------------------------------------------------
% centroidsMeanCols
%-----------------------------------------------------
figure;

centroidsMeanCols  = [so.outputPdqTsData.pdqModuleOutputTsData(indexToModOut1).centroidsMeanCols]; % an array of structs 1x84
centroidsMeanColsValues = [centroidsMeanCols.values]';
centroidsMeanColsUncertainties = [centroidsMeanCols.uncertainties]';

h1 = plot(cadenceTimes, centroidsMeanColsValues,'m.-');
hold on;
plot(cadenceTimes, centroidsMeanColsValues + centroidsMeanColsUncertainties,'m:');
plot(cadenceTimes, centroidsMeanColsValues - centroidsMeanColsUncertainties,'m:');


centroidsMeanColsWithGaps  = [sogap.outputPdqTsData.pdqModuleOutputTsData(indexToModOut2).centroidsMeanCols]; % an array of structs 1x84
centroidsMeanColsValuesWithGaps = [centroidsMeanColsWithGaps.values]';
centroidsMeanColsUncertaintiesWithGaps = [centroidsMeanColsWithGaps.uncertainties]';

h2 = plot(cadenceTimes(validCadences), centroidsMeanColsValuesWithGaps,'ko-');
hold on;
plot(cadenceTimes(validCadences), centroidsMeanColsValuesWithGaps + centroidsMeanColsUncertaintiesWithGaps,'k:');
plot(cadenceTimes(validCadences), centroidsMeanColsValuesWithGaps - centroidsMeanColsUncertaintiesWithGaps,'k:');


legend([h1 h2], {'complete', 'with gaps'}, 'Location', 'Best');
ylabel('in pixel units');
xlabel('Cadence Number');
titleStr = (['centroidsMeanCols metric for module ' num2str(ccdModule) ' output ' num2str(ccdOutput) ' modout ' num2str(modOut)]);

title(titleStr);
plot_to_file(titleStr, isLandscapeOrientationFlag, includeTimeFlag, printJpgFlag);

close all;
%-----------------------------------------------------
% encircledEnergies
%-----------------------------------------------------
figure;

encircledEnergies  = [so.outputPdqTsData.pdqModuleOutputTsData(indexToModOut1).encircledEnergies]; % an array of structs 1x84

encircledEnergiesValues = [encircledEnergies.values]';
encircledEnergiesUncertainties = [encircledEnergies.uncertainties]';


h1 = plot(cadenceTimes, encircledEnergiesValues,'m.-');
hold on;
plot(cadenceTimes, encircledEnergiesValues + encircledEnergiesUncertainties,'m:');
plot(cadenceTimes, encircledEnergiesValues - encircledEnergiesUncertainties,'m:');



encircledEnergiesWithGaps  = [sogap.outputPdqTsData.pdqModuleOutputTsData(indexToModOut2).encircledEnergies]; % an array of structs 1x84

encircledEnergiesValuesWithGaps = [encircledEnergiesWithGaps.values]';
encircledEnergiesUncertaintiesWithGaps = [encircledEnergiesWithGaps.uncertainties]';


h2 = plot(cadenceTimes(validCadences), encircledEnergiesValuesWithGaps,'ko-');
hold on;
plot(cadenceTimes(validCadences), encircledEnergiesValuesWithGaps + encircledEnergiesUncertaintiesWithGaps,'k:');
plot(cadenceTimes(validCadences), encircledEnergiesValuesWithGaps - encircledEnergiesUncertaintiesWithGaps,'k:');



legend([h1 h2], {'complete', 'with gaps'}, 'Location', 'Best');
ylabel('in pixel units');
xlabel('Cadence Number');
titleStr = (['encircledEnergy metric for module ' num2str(ccdModule) ' output ' num2str(ccdOutput) ' modout ' num2str(modOut)]);

title(titleStr);
plot_to_file(titleStr, isLandscapeOrientationFlag, includeTimeFlag, printJpgFlag);

close all;
%-----------------------------------------------------
% plateScales
%-----------------------------------------------------
figure;

plateScales  = [so.outputPdqTsData.pdqModuleOutputTsData(indexToModOut1).plateScales]; % an array of structs 1x84
plateScalesValues = [plateScales.values]';
plateScalesUncertainties = [plateScales.uncertainties]';

h1 = plot(cadenceTimes, plateScalesValues,'m.-');
hold on;
plot(cadenceTimes, plateScalesValues + plateScalesUncertainties,'m:');
plot(cadenceTimes, plateScalesValues - plateScalesUncertainties,'m:');


plateScalesWithGaps  = [sogap.outputPdqTsData.pdqModuleOutputTsData(indexToModOut2).plateScales]; % an array of structs 1x84
plateScalesValuesWithGaps = [plateScalesWithGaps.values]';
plateScalesUncertaintiesWithGaps = [plateScalesWithGaps.uncertainties]';

h2 = plot(cadenceTimes(validCadences), plateScalesValuesWithGaps,'ko-');
hold on;
plot(cadenceTimes(validCadences), plateScalesValuesWithGaps + plateScalesUncertaintiesWithGaps,'k:');
plot(cadenceTimes(validCadences), plateScalesValuesWithGaps - plateScalesUncertaintiesWithGaps,'k:');


legend([h1 h2], {'complete', 'with gaps'}, 'Location', 'Best');
ylabel('unitless ');
xlabel('Cadence Number');
titleStr = (['Platescale metric for module ' num2str(ccdModule) ' output ' num2str(ccdOutput) ' modout ' num2str(modOut)]);

title(titleStr);
plot_to_file(titleStr, isLandscapeOrientationFlag, includeTimeFlag, printJpgFlag);

close all;
return


