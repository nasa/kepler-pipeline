function construct_pdq_pipeline_runs_comparison_plots(pdqOutputStructOld,pdqOutputStructNew, versionOldStr, versionNewStr)

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% construct_pdq_pipeline_runs_comparison_plots(pdqOutputStruct1,pdqOutputStruct2)
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

if(~exist('versionOldStr', 'var'))
    versionOldStr = 'version 1';
end

if(~exist('versionNewStr', 'var'))
    versionNewStr = 'version 2';
end

[pdqOutputStruct1, pdqOutputStruct2] = enforce_same_cadence_range_on_pdq_outputs_for_comparison(pdqOutputStructOld,pdqOutputStructNew);


ccdOutputs = [pdqOutputStruct1.outputPdqTsData.pdqModuleOutputTsData.ccdOutput];
ccdModules = [pdqOutputStruct1.outputPdqTsData.pdqModuleOutputTsData.ccdModule];

cadenceTimeStamps = pdqOutputStruct1.outputPdqTsData.cadenceTimes;
modOuts = convert_from_module_output(ccdModules, ccdOutputs);
nModOuts = length(modOuts);
%nCadences = length(pdqOutputStruct1.outputPdqTsData.cadenceTimes);


% % plot to file parameters
% isLandscapeOrientationFlag = true;
% includeTimeFlag = false;
% printJpgFlag = false;
%
% %Set rand to its default initial state:
% rand('twister');
% modOutColors = rand(nModOuts,3);


% 10 separate figures, each figure containing 10 X 10 subplots, with corner plots missing of course, to mimic focal plane shape.

[ccdModuleTilesInFocalPlane, modOutTilesInFocalPlane] = get_ccd_modout_tile_location_in_focal_plane();

ccdModuleTilesInFocalPlane = ccdModuleTilesInFocalPlane'; % need row major order
modOutTilesInFocalPlane = modOutTilesInFocalPlane';

pdqModuleOutputTsData = pdqOutputStruct1.outputPdqTsData.pdqModuleOutputTsData;

commonStruct.ccdModuleTilesInFocalPlane = ccdModuleTilesInFocalPlane;
commonStruct.modOutTilesInFocalPlane = modOutTilesInFocalPlane;
commonStruct.pdqModuleOutputTsData = pdqModuleOutputTsData;
commonStruct.nModOuts = nModOuts;
commonStruct.cadenceTimeStamps = cadenceTimeStamps;
commonStruct.version1Str = versionOldStr;
commonStruct.version2Str = versionNewStr;


%-----------------------------------------------------
% attitude solution components ra, dec, roll comparison
%-----------------------------------------------------

attitude1.ra  = pdqOutputStruct1.outputPdqTsData.attitudeSolutionRa;
attitude2.ra  = pdqOutputStruct2.outputPdqTsData.attitudeSolutionRa;
attitude1.dec  = pdqOutputStruct1.outputPdqTsData.attitudeSolutionDec;
attitude2.dec  = pdqOutputStruct2.outputPdqTsData.attitudeSolutionDec;
attitude1.roll  = pdqOutputStruct1.outputPdqTsData.attitudeSolutionRoll;
attitude2.roll  = pdqOutputStruct2.outputPdqTsData.attitudeSolutionRoll;

metricNameString = 'Computed Attitude Solution ';
figureFileName = ['Computed Attitude Solution ' versionOldStr ' and ' versionNewStr ];
plot_focal_plane_metric_comparison_plots(commonStruct, attitude1, attitude2, metricNameString,figureFileName)
close all;


%-----------------------------------------------------
% desired attitude solution components ra, dec, roll comparison
%-----------------------------------------------------

attitude1.ra  = pdqOutputStruct1.outputPdqTsData.desiredAttitudeRa;
attitude2.ra  = pdqOutputStruct2.outputPdqTsData.desiredAttitudeRa;
attitude1.dec  = pdqOutputStruct1.outputPdqTsData.desiredAttitudeDec;
attitude2.dec  = pdqOutputStruct2.outputPdqTsData.desiredAttitudeDec;
attitude1.roll  = pdqOutputStruct1.outputPdqTsData.desiredAttitudeRoll;
attitude2.roll  = pdqOutputStruct2.outputPdqTsData.desiredAttitudeRoll;

metricNameString = 'Desired Attitude ';
figureFileName = ['Desired Attitude ' versionOldStr ' and ' versionNewStr ];
plot_focal_plane_metric_comparison_plots(commonStruct, attitude1, attitude2, metricNameString,figureFileName)
close all;


%-----------------------------------------------------
% delta attitude solution components ra, dec, roll comparison
%-----------------------------------------------------

attitude1.ra  = pdqOutputStruct1.outputPdqTsData.deltaAttitudeRa;
attitude2.ra  = pdqOutputStruct2.outputPdqTsData.deltaAttitudeRa;
attitude1.dec  = pdqOutputStruct1.outputPdqTsData.deltaAttitudeDec;
attitude2.dec  = pdqOutputStruct2.outputPdqTsData.deltaAttitudeDec;
attitude1.roll  = pdqOutputStruct1.outputPdqTsData.deltaAttitudeRoll;
attitude2.roll  = pdqOutputStruct2.outputPdqTsData.deltaAttitudeRoll;

metricNameString = 'Delta Attitude';
yUnitsLabel = 'arcsec';
figureFileName = ['Delta Attitude ' versionOldStr ' and ' versionNewStr ];
plot_focal_plane_metric_comparison_plots(commonStruct, attitude1, attitude2, metricNameString,figureFileName,yUnitsLabel)
close all;

%-----------------------------------------------------
% maximum attitude residual comparison plots
%-----------------------------------------------------
maxResidualStruct1 = pdqOutputStruct1.outputPdqTsData.maxAttitudeResidualInPixels;
maxResidualStruct2 = pdqOutputStruct2.outputPdqTsData.maxAttitudeResidualInPixels;
metricNameString = 'Maximum Attitude Residual ';
figureFileName = ['Maximum Attitude Residual ' versionOldStr ' and ' versionNewStr ];
plot_max_attitude_residual_comparison_plots(commonStruct, maxResidualStruct1,maxResidualStruct2, metricNameString,figureFileName)
close all;


%-----------------------------------------------------
% black levels
%-----------------------------------------------------
blackLevels1  = [pdqOutputStruct1.outputPdqTsData.pdqModuleOutputTsData.blackLevels]; % an array of structs 1x84
blackLevelValues1 = [blackLevels1.values]';
blackLevelUncertainties1 = [blackLevels1.uncertainties]';
blackLevelUncertainties1(blackLevelUncertainties1 == -1) = NaN;


blackLevels2 = [pdqOutputStruct2.outputPdqTsData.pdqModuleOutputTsData.blackLevels]; % an array of structs 1x84
blackLevelValues2 = [blackLevels2.values]';
blackLevelUncertainties2 = [blackLevels2.uncertainties]';

blackLevelUncertainties2(blackLevelUncertainties2 == -1) = NaN;

blackLevelUncertainties = sqrt(blackLevelUncertainties1.^2 + blackLevelUncertainties2.^2);
metricNameString = 'Black Level Metric';

%annotateString1 = {['Black Level Metric ' versionOldStr ' (in red) and ' versionNewStr ' (in blue)']; 'x axis units are in cadences, y axis units are in ADU'};

annotateString1 = {['Black Level Metric  ' versionOldStr ' (in red) and ' versionNewStr ' (in blue)']; 'x axis units are in cadences, y axis units are in ADU'};

annotateString2 = {['Difference Between the  ' versionOldStr ' and ' versionNewStr '  Black Level Metric (in magenta), Uncertainties (in dotted lines)']; 'x axis units are in cadences, y axis units are in ADU'};

figureFileName1 = ['Black level metric ' versionOldStr ' and ' versionNewStr ];
figureFileName2 = [ versionOldStr ' minus  ' versionNewStr '  black level metric compared to uncertainties'] ;


metricStruct.metricValues1 = blackLevelValues1;
metricStruct.metricValues2 = blackLevelValues2;
metricStruct.metricUncertainties = blackLevelUncertainties;
metricStruct.metricNameString = metricNameString;
metricStruct.annotateString1 = annotateString1;
metricStruct.annotateString2 = annotateString2;
metricStruct.figureFileName1 = figureFileName1;
metricStruct.figureFileName2 = figureFileName2;


plot_metric_comparison_plots_on_focal_plane(commonStruct, metricStruct);


close all;
%-----------------------------------------------------
% smear levels
%-----------------------------------------------------
smearLevels1  = [pdqOutputStruct1.outputPdqTsData.pdqModuleOutputTsData.smearLevels]; % an array of structs 1x84
smearLevelValues1 = [smearLevels1.values]';
smearLevelUncertainties1 = [smearLevels1.uncertainties]';
smearLevelUncertainties1(smearLevelUncertainties1 == -1) = NaN;

smearLevels2 = [pdqOutputStruct2.outputPdqTsData.pdqModuleOutputTsData.smearLevels]; % an array of structs 1x84
smearLevelValues2 = [smearLevels2.values]';
smearLevelUncertainties2 = [smearLevels2.uncertainties]';

smearLevelUncertainties2(smearLevelUncertainties2 == -1) = NaN;

smearLevelUncertainties = sqrt(smearLevelUncertainties1.^2 + smearLevelUncertainties2.^2);


metricNameString = 'Smear Level Metric';

annotateString1 = {['Smear Level Metric  ' versionOldStr ' (in red) and ' versionNewStr ' (in blue)']; 'x axis units are in cadences, y axis units are in photoelectrons'};

annotateString2 = {['Difference between Smear Level Metric  ' versionOldStr ' and ' versionNewStr '  (in magenta), Uncertainties (in dotted lines)']; 'x axis units are in cadences, y axis units are in photoelectrons'};

figureFileName1 = ['Smear level metric ' versionOldStr ' and ' versionNewStr ];
figureFileName2 = [ versionOldStr ' minus  ' versionNewStr '  smear level metric compared to uncertainties'] ;


metricStruct.metricValues1 = smearLevelValues1;
metricStruct.metricValues2 = smearLevelValues2;
metricStruct.metricUncertainties = smearLevelUncertainties;
metricStruct.metricNameString = metricNameString;
metricStruct.annotateString1 = annotateString1;
metricStruct.annotateString2 = annotateString2;
metricStruct.figureFileName1 = figureFileName1;
metricStruct.figureFileName2 = figureFileName2;


plot_metric_comparison_plots_on_focal_plane(commonStruct, metricStruct);


close all;

%-----------------------------------------------------
% dark currents
%-----------------------------------------------------

darkCurrents1  = [pdqOutputStruct1.outputPdqTsData.pdqModuleOutputTsData.darkCurrents]; % an array of structs 1x84
darkCurrentValues1 = [darkCurrents1.values]';
darkCurrentUncertainties1 = [darkCurrents1.uncertainties]';
darkCurrentUncertainties1(darkCurrentUncertainties1 == -1) = NaN;


darkCurrents2 = [pdqOutputStruct2.outputPdqTsData.pdqModuleOutputTsData.darkCurrents]; % an array of structs 1x84
darkCurrentValues2 = [darkCurrents2.values]';
darkCurrentUncertainties2 = [darkCurrents2.uncertainties]';
darkCurrentUncertainties2(darkCurrentUncertainties2 == -1) = NaN;

darkCurrentUncertainties = sqrt(darkCurrentUncertainties1.^2 + darkCurrentUncertainties2.^2);


metricNameString = 'Dark Current Metric';

annotateString1 = {['Dark Current Level Metric  ' versionOldStr ' (in red) and ' versionNewStr ' (in blue)']; 'x axis units are in cadences, y axis units are in photoelectrons/sec/exposure'};

annotateString2 = {['Difference Between Dark Current Level Metric  ' versionOldStr ' and ' versionNewStr '  (in magenta), Uncertainties (in dotted lines)']; 'x axis units are in cadences, y axis units are in photoelectrons/sec/exposure'};
figureFileName1 = ['Dark current level metric ' versionOldStr ' and ' versionNewStr ];
figureFileName2 = [ versionOldStr ' minus  ' versionNewStr '  dark current metric compared to uncertainties'] ;


metricStruct.metricValues1 = darkCurrentValues1;
metricStruct.metricValues2 = darkCurrentValues2;
metricStruct.metricUncertainties = darkCurrentUncertainties;
metricStruct.metricNameString = metricNameString;
metricStruct.annotateString1 = annotateString1;
metricStruct.annotateString2 = annotateString2;
metricStruct.figureFileName1 = figureFileName1;
metricStruct.figureFileName2 = figureFileName2;


plot_metric_comparison_plots_on_focal_plane(commonStruct, metricStruct);


close all;

%-----------------------------------------------------
% backgroundLevels
%-----------------------------------------------------

backgroundLevels1  = [pdqOutputStruct1.outputPdqTsData.pdqModuleOutputTsData.backgroundLevels]; % an array of structs 1x84
backgroundLevelValues1 = [backgroundLevels1.values]';
backgroundLevelUncertainties1 = [backgroundLevels1.uncertainties]';
backgroundLevelUncertainties1(backgroundLevelUncertainties1 == -1) = NaN;

backgroundLevels2 = [pdqOutputStruct2.outputPdqTsData.pdqModuleOutputTsData.backgroundLevels]; % an array of structs 1x84
backgroundLevelValues2 = [backgroundLevels2.values]';
backgroundLevelUncertainties2 = [backgroundLevels2.uncertainties]';

backgroundLevelUncertainties2(backgroundLevelUncertainties2 == -1) = NaN;

backgroundLevelUncertainties = sqrt(backgroundLevelUncertainties1.^2 + backgroundLevelUncertainties2.^2);

metricNameString = 'Background Level Metric';

annotateString1 = {['Background Level Metric  ' versionOldStr ' (in red) and ' versionNewStr ' (in blue)']; 'x axis units are in cadences, y axis units are in photoelectrons'};

annotateString2 = {['Difference Between Background Level Metric  ' versionOldStr ' and ' versionNewStr '  (in magenta), Uncertainties (in dotted lines)']; 'x axis units are in cadences, y axis units are in photoelectrons'};
figureFileName1 = ['Background level metric ' versionOldStr ' and ' versionNewStr ];
figureFileName2 = [ versionOldStr ' minus  ' versionNewStr '  background level metric compared to uncertainties'] ;


metricStruct.metricValues1 = backgroundLevelValues1;
metricStruct.metricValues2 = backgroundLevelValues2;
metricStruct.metricUncertainties = backgroundLevelUncertainties;
metricStruct.metricNameString = metricNameString;
metricStruct.annotateString1 = annotateString1;
metricStruct.annotateString2 = annotateString2;
metricStruct.figureFileName1 = figureFileName1;
metricStruct.figureFileName2 = figureFileName2;


plot_metric_comparison_plots_on_focal_plane(commonStruct, metricStruct);


close all;


%-----------------------------------------------------
% dynamicRanges
% there are no uncertainties associated with dynamicRange metric values as this metric simply reports the (max-min)
% value of the raw pixels received
%-----------------------------------------------------

dynamicRanges1  = [pdqOutputStruct1.outputPdqTsData.pdqModuleOutputTsData.dynamicRanges]; % an array of structs 1x84
dynamicRangeValues1 = [dynamicRanges1.values]';
%dynamicRangeUncertainties1 = [dynamicRanges1.uncertainties]';

dynamicRanges2 = [pdqOutputStruct2.outputPdqTsData.pdqModuleOutputTsData.dynamicRanges]; % an array of structs 1x84
dynamicRangeValues2 = [dynamicRanges2.values]';
dynamicRangeUncertainties2 = [dynamicRanges2.uncertainties]';

dynamicRangeUncertainties2(:) = NaN;

metricNameString = 'Dynamic Range Metric';
annotateString1 = {['Dynamic Range Metric  ' versionOldStr ' (in red) and ' versionNewStr ' (in blue)']; 'x axis units are in cadences, y axis units are in ADU'};

annotateString2 = {['Difference Between Dynamic Range Metric  ' versionOldStr ' and ' versionNewStr '  (in magenta), Uncertainties (in dotted lines)']; 'x axis units are in cadences, y axis units are in ADU'};
figureFileName1 = ['Dynamic range metric ' versionOldStr ' and ' versionNewStr ];
figureFileName2 = [ versionOldStr ' minus  ' versionNewStr '  dynamic range metric compared to uncertainties'] ;



metricStruct.metricValues1 = dynamicRangeValues1;
metricStruct.metricValues2 = dynamicRangeValues2;
metricStruct.metricUncertainties = dynamicRangeUncertainties2;
metricStruct.metricNameString = metricNameString;
metricStruct.annotateString1 = annotateString1;
metricStruct.annotateString2 = annotateString2;
metricStruct.figureFileName1 = figureFileName1;
metricStruct.figureFileName2 = figureFileName2;


plot_metric_comparison_plots_on_focal_plane(commonStruct, metricStruct);


close all;

%-----------------------------------------------------
% meanFluxes
%-----------------------------------------------------

meanFluxes1  = [pdqOutputStruct1.outputPdqTsData.pdqModuleOutputTsData.meanFluxes]; % an array of structs 1x84
meanFluxesValues1 = [meanFluxes1.values]';
meanFluxesUncertainties1 = [meanFluxes1.uncertainties]';
meanFluxesUncertainties1(meanFluxesUncertainties1 == -1) = NaN;


meanFluxes2 = [pdqOutputStruct2.outputPdqTsData.pdqModuleOutputTsData.meanFluxes]; % an array of structs 1x84
meanFluxesValues2 = [meanFluxes2.values]';
meanFluxesUncertainties2 = [meanFluxes2.uncertainties]';
meanFluxesUncertainties2(meanFluxesUncertainties2 == -1) = NaN;

meanFluxesUncertainties = sqrt(meanFluxesUncertainties1.^2 + meanFluxesUncertainties2.^2);

metricNameString = 'Brightness Metric';
annotateString1 = {['Brightness Metric  ' versionOldStr ' (in red) and ' versionNewStr ' (in blue)']; 'x axis units are in cadences, y axis units are in unitless ratio'};

annotateString2 = {['Difference Between Brightness Metric  ' versionOldStr ' and ' versionNewStr '  (in magenta), Uncertainties (in dotted lines)']; 'x axis units are in cadences, y axis units are in unitless ratio'};
figureFileName1 = ['Brightness metric ' versionOldStr ' and ' versionNewStr ];
figureFileName2 = [ versionOldStr ' minus  ' versionNewStr '  brightness metric compared to uncertainties'] ;

metricStruct.metricValues1 = meanFluxesValues1;
metricStruct.metricValues2 = meanFluxesValues2;
metricStruct.metricUncertainties = meanFluxesUncertainties;
metricStruct.metricNameString = metricNameString;
metricStruct.annotateString1 = annotateString1;
metricStruct.annotateString2 = annotateString2;
metricStruct.figureFileName1 = figureFileName1;
metricStruct.figureFileName2 = figureFileName2;

plot_metric_comparison_plots_on_focal_plane(commonStruct, metricStruct);


close all;

%-----------------------------------------------------
% centroidsMeanRows
%-----------------------------------------------------


centroidsMeanRows1  = [pdqOutputStruct1.outputPdqTsData.pdqModuleOutputTsData.centroidsMeanRows]; % an array of structs 1x84
centroidsMeanRowsValues1 = [centroidsMeanRows1.values]';
centroidsMeanRowsUncertainties1 = [centroidsMeanRows1.uncertainties]';
centroidsMeanRowsUncertainties1(centroidsMeanRowsUncertainties1 == -1) = NaN;


centroidsMeanRows2 = [pdqOutputStruct2.outputPdqTsData.pdqModuleOutputTsData.centroidsMeanRows]; % an array of structs 1x84
centroidsMeanRowsValues2 = [centroidsMeanRows2.values]';
centroidsMeanRowsUncertainties2 = [centroidsMeanRows2.uncertainties]';
centroidsMeanRowsUncertainties2(centroidsMeanRowsUncertainties2 == -1) = NaN;

centroidsMeanRowsUncertainties = sqrt(centroidsMeanRowsUncertainties1.^2 + centroidsMeanRowsUncertainties2.^2);

metricNameString = 'Centroid Row Metric';
annotateString1 = {['Centroid Row Metric  ' versionOldStr ' (in red) and ' versionNewStr ' (in blue)']; 'x axis units are in cadences, y axis units are in pixels'};

annotateString2 = {['Difference Between Centroid Row Metric  ' versionOldStr ' and ' versionNewStr '  (in magenta), Uncertainties (in dotted lines)']; 'x axis units are in cadences, y axis units are in pixels'};
figureFileName1 = ['Centroid row metric ' versionOldStr ' and ' versionNewStr ];
figureFileName2 = [ versionOldStr ' minus  ' versionNewStr '  centroid row metric compared to uncertainties'] ;


metricStruct.metricValues1 = centroidsMeanRowsValues1;
metricStruct.metricValues2 = centroidsMeanRowsValues2;
metricStruct.metricUncertainties = centroidsMeanRowsUncertainties;
metricStruct.metricNameString = metricNameString;
metricStruct.annotateString1 = annotateString1;
metricStruct.annotateString2 = annotateString2;
metricStruct.figureFileName1 = figureFileName1;
metricStruct.figureFileName2 = figureFileName2;

plot_metric_comparison_plots_on_focal_plane(commonStruct, metricStruct);


close all;

%-----------------------------------------------------
% centroidsMeanCols
%-----------------------------------------------------

centroidsMeanCols1  = [pdqOutputStruct1.outputPdqTsData.pdqModuleOutputTsData.centroidsMeanCols]; % an array of structs 1x84
centroidsMeanColsValues1 = [centroidsMeanCols1.values]';
centroidsMeanColsUncertainties1 = [centroidsMeanCols1.uncertainties]';

centroidsMeanColsUncertainties1(centroidsMeanColsUncertainties1 == -1) = NaN;

centroidsMeanCols2 = [pdqOutputStruct2.outputPdqTsData.pdqModuleOutputTsData.centroidsMeanCols]; % an array of structs 1x84
centroidsMeanColsValues2 = [centroidsMeanCols2.values]';
centroidsMeanColsUncertainties2 = [centroidsMeanCols2.uncertainties]';
centroidsMeanColsUncertainties2(centroidsMeanColsUncertainties2 == -1) = NaN;


centroidsMeanColsUncertainties = sqrt(centroidsMeanColsUncertainties1.^2 + centroidsMeanColsUncertainties2.^2);

metricNameString = 'Centroid Column Metric';
annotateString1 = {['Centroid Column Metric  ' versionOldStr ' (in red) and ' versionNewStr ' (in blue)']; 'x axis units are in cadences, y axis units are in pixels'};

annotateString2 = {['Difference Between Centroid Column Metric  ' versionOldStr ' and ' versionNewStr '  (in magenta), Uncertainties (in dotted lines)']; 'x axis units are in cadences, y axis units are in pixels'};
figureFileName1 = ['Centroid column metric ' versionOldStr ' and ' versionNewStr ];
figureFileName2 = [ versionOldStr ' minus  ' versionNewStr '  centroid column metric compared to uncertainties'] ;

metricStruct.metricValues1 = centroidsMeanColsValues1;
metricStruct.metricValues2 = centroidsMeanColsValues2;
metricStruct.metricUncertainties = centroidsMeanColsUncertainties;
metricStruct.metricNameString = metricNameString;
metricStruct.annotateString1 = annotateString1;
metricStruct.annotateString2 = annotateString2;
metricStruct.figureFileName1 = figureFileName1;
metricStruct.figureFileName2 = figureFileName2;

plot_metric_comparison_plots_on_focal_plane(commonStruct, metricStruct);



close all;


%-----------------------------------------------------
% encircledEnergies
%-----------------------------------------------------

encircledEnergies1  = [pdqOutputStruct1.outputPdqTsData.pdqModuleOutputTsData.encircledEnergies]; % an array of structs 1x84
encircledEnergiesValues1 = [encircledEnergies1.values]';
encircledEnergiesUncertainties1 = [encircledEnergies1.uncertainties]';

encircledEnergiesUncertainties1(encircledEnergiesUncertainties1 == -1) = NaN;

encircledEnergies2 = [pdqOutputStruct2.outputPdqTsData.pdqModuleOutputTsData.encircledEnergies]; % an array of structs 1x84
encircledEnergiesValues2 = [encircledEnergies2.values]';
encircledEnergiesUncertainties2 = [encircledEnergies2.uncertainties]';

encircledEnergiesUncertainties2(encircledEnergiesUncertainties2 == -1) = NaN;

encircledEnergiesUncertainties = sqrt(encircledEnergiesUncertainties1.^2 + encircledEnergiesUncertainties2.^2);

metricNameString = 'Encircled Energy Metric';
annotateString1 = {['Encircled Energy Metric  ' versionOldStr ' (in red) and ' versionNewStr ' (in blue)']; 'x axis units are in cadences, y axis units are in pixels'};

annotateString2 = {['Difference Between Encircled Energy Metric  ' versionOldStr ' and ' versionNewStr '  (in magenta), Uncertainties (in dotted lines)']; 'x axis units are in cadences, y axis units are in pixels'};
figureFileName1 = ['Encircled energy metric ' versionOldStr ' and ' versionNewStr ];
figureFileName2 = [versionOldStr ' minus  ' versionNewStr '  encircled energy metric compared to uncertainties' ];

metricStruct.metricValues1 = encircledEnergiesValues1;
metricStruct.metricValues2 = encircledEnergiesValues2;
metricStruct.metricUncertainties = encircledEnergiesUncertainties;
metricStruct.metricNameString = metricNameString;
metricStruct.annotateString1 = annotateString1;
metricStruct.annotateString2 = annotateString2;
metricStruct.figureFileName1 = figureFileName1;
metricStruct.figureFileName2 = figureFileName2;

plot_metric_comparison_plots_on_focal_plane(commonStruct, metricStruct);


close all;

%-----------------------------------------------------
% plateScales
%-----------------------------------------------------

plateScales1  = [pdqOutputStruct1.outputPdqTsData.pdqModuleOutputTsData.plateScales]; % an array of structs 1x84
plateScalesValues1 = [plateScales1.values]';
plateScalesUncertainties1 = [plateScales1.uncertainties]';

plateScalesUncertainties1(plateScalesUncertainties1 == -1) = NaN;

plateScales2 = [pdqOutputStruct2.outputPdqTsData.pdqModuleOutputTsData.plateScales]; % an array of structs 1x84
plateScalesValues2 = [plateScales2.values]';
plateScalesUncertainties2 = [plateScales2.uncertainties]';

plateScalesUncertainties2(plateScalesUncertainties2 == -1) = NaN;

plateScalesUncertainties = sqrt(plateScalesUncertainties1.^2 + plateScalesUncertainties2.^2);


metricNameString = 'Platescale Metric';
annotateString1 = {['Platescale Metric  ' versionOldStr ' (in red) and ' versionNewStr ' (in blue)']; 'x axis units are in cadences, y axis units are in unitless ratio'};

annotateString2 = {['Difference Between Platescale Metric  ' versionOldStr ' and ' versionNewStr '  (in magenta), Uncertainties (in dotted lines)']; 'x axis units are in cadences, y axis units are in unitless ratio'};
figureFileName1 = ['Platescale metric ' versionOldStr ' and ' versionNewStr ];
figureFileName2 = [versionOldStr ' minus  ' versionNewStr '  platescale metric compared to uncertainties' ];

metricStruct.metricValues1 = plateScalesValues1;
metricStruct.metricValues2 = plateScalesValues2;
metricStruct.metricUncertainties = plateScalesUncertainties;
metricStruct.metricNameString = metricNameString;
metricStruct.annotateString1 = annotateString1;
metricStruct.annotateString2 = annotateString2;
metricStruct.figureFileName1 = figureFileName1;
metricStruct.figureFileName2 = figureFileName2;

plot_metric_comparison_plots_on_focal_plane(commonStruct, metricStruct);


close all;

return


