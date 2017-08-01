function tadInputStruct = get_tad_input(runTadObject, catalogData)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% function tadInputStruct = get_tad_input(runTadObject)
%
% reads the tad input file and returns structure with the following fields
%
% tadInputStruct.targetDefinitions
% tadInputStruct.maskDefinitions
% tadInputStruct.backgroundTargetDefinitions
% tadInputStruct.backgroundMaskDefinitions
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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

runParamsObject = runTadObject.runParamsClass;

% first create the catalog selector object and use it to create the target list
% instantiate the target selector class specified in the input mat file
targetSelectorString = ...
    ['targetSelectorObject = ' runTadObject.targetSelectorData.className ...
    '(runTadObject.targetSelectorData, runParamsObject);'];
targetSelectorString
eval(targetSelectorString);
clear targetSelectorData

targetList = select_targets(targetSelectorObject, catalogData);
if isempty(targetList)
    error('get_tad_input: no targets');
end
disp([num2str(length(targetList)) ' targets selected']);

% actually run tad
% load('configuration_files/maskDefinitions.mat');
debugFlag = 0;
% first coa
coaParameterStruct = make_coa_input(runTadObject, catalogData, targetList, runParamsObject, debugFlag);
coaResultStruct = coa_matlab_controller(coaParameterStruct);
% then ama
amaParameterStruct = make_ama_input(coaResultStruct, debugFlag);
amaResultStruct = ama_matlab_controller(amaParameterStruct);
% then bpa
bpaParameterStruct = make_bpa_input(coaResultStruct, debugFlag);
bpaResultStruct = bpa_matlab_controller(bpaParameterStruct);

% extract the parts we actually need
tadInputStruct.targetDefinitions = amaResultStruct.targetDefinitions;
tadInputStruct.maskDefinitions = amaResultStruct.maskDefinitions;
tadInputStruct.backgroundTargetDefinitions = bpaResultStruct.targetDefinitions;
tadInputStruct.backgroundMaskDefinitions = bpaResultStruct.maskDefinitions;
tadInputStruct.coaResultStruct = coaResultStruct;

% make a fake reference pixel target definition set
refPixCount = 1;
tadInputStruct.refPixelTargetDefinitions(refPixCount).keplerId = 0;
tadInputStruct.refPixelTargetDefinitions(refPixCount).maskIndex = 70;
tadInputStruct.refPixelTargetDefinitions(refPixCount).referenceRow = 500;
tadInputStruct.refPixelTargetDefinitions(refPixCount).referenceColumn = 500;
tadInputStruct.refPixelTargetDefinitions(refPixCount).excessPixels = 0;
tadInputStruct.refPixelTargetDefinitions(refPixCount).status = 1;
refPixCount = refPixCount+1;
tadInputStruct.refPixelTargetDefinitions(refPixCount).keplerId = 0;
tadInputStruct.refPixelTargetDefinitions(refPixCount).maskIndex = 120;
tadInputStruct.refPixelTargetDefinitions(refPixCount).referenceRow = 200;
tadInputStruct.refPixelTargetDefinitions(refPixCount).referenceColumn = 200;
tadInputStruct.refPixelTargetDefinitions(refPixCount).excessPixels = 0;
tadInputStruct.refPixelTargetDefinitions(refPixCount).status = 1;
refPixCount = refPixCount+1;
tadInputStruct.refPixelTargetDefinitions(refPixCount).keplerId = 0;
tadInputStruct.refPixelTargetDefinitions(refPixCount).maskIndex = 200;
tadInputStruct.refPixelTargetDefinitions(refPixCount).referenceRow = 200;
tadInputStruct.refPixelTargetDefinitions(refPixCount).referenceColumn = 800;
tadInputStruct.refPixelTargetDefinitions(refPixCount).excessPixels = 0;
tadInputStruct.refPixelTargetDefinitions(refPixCount).status = 1;
refPixCount = refPixCount+1;
tadInputStruct.refPixelTargetDefinitions(refPixCount).keplerId = 0;
tadInputStruct.refPixelTargetDefinitions(refPixCount).maskIndex = 140;
tadInputStruct.refPixelTargetDefinitions(refPixCount).referenceRow = 800;
tadInputStruct.refPixelTargetDefinitions(refPixCount).referenceColumn = 800;
tadInputStruct.refPixelTargetDefinitions(refPixCount).excessPixels = 0;
tadInputStruct.refPixelTargetDefinitions(refPixCount).status = 1;
% find a moderately bright star
brightTargetIndex = find(catalogData.keplerMagnitude < 17 & ismember(catalogData.kicId, targetList));
refStarKicId = catalogData.kicId(brightTargetIndex(1));
refStarTargetIndex = find([tadInputStruct.targetDefinitions.keplerId] == refStarKicId);
refPixCount = refPixCount+1;
tadInputStruct.refPixelTargetDefinitions(refPixCount).keplerId = 0;
tadInputStruct.refPixelTargetDefinitions(refPixCount).maskIndex = 20;
tadInputStruct.refPixelTargetDefinitions(refPixCount).referenceRow = tadInputStruct.targetDefinitions(refStarTargetIndex).referenceRow;
tadInputStruct.refPixelTargetDefinitions(refPixCount).referenceColumn = tadInputStruct.targetDefinitions(refStarTargetIndex).referenceColumn;
tadInputStruct.refPixelTargetDefinitions(refPixCount).excessPixels = 0;
tadInputStruct.refPixelTargetDefinitions(refPixCount).status = 1;

%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%

function coaParameterStruct = make_coa_input(runTadObject, catalogData, targetKeplerIDList, runParamsObject, debugFlag)

module = get(runParamsObject, 'moduleNumber');
output = get(runParamsObject, 'outputNumber');

kicEntryDataStruct = struct('KICID', num2cell(catalogData.kicId), ...
    'RA', num2cell(catalogData.ra/15), 'dec', num2cell(catalogData.dec),...
    'magnitude', num2cell(catalogData.keplerMagnitude), ...
    'effectiveTemp', num2cell(single(5000*ones(size(catalogData.kicId)))));

wellCapacity = get(runParamsObject, 'wellCapacity');
numAtoDBits = get(runParamsObject, 'numAtoDBits');
exposuresPerCadence = get(runParamsObject, 'exposuresPerCadence');

coaParameterStruct.startTime = get(runParamsObject, 'runStartDate');
coaParameterStruct.duration = get(runParamsObject, 'runDurationDays');
if coaParameterStruct.duration < 2
	coaParameterStruct.duration = 2;
end

runStartMjd = datestr2mjd(coaParameterStruct.startTime);
runEndMjd = runStartMjd + coaParameterStruct.duration;

coaParameterStruct.gainModel = retrieve_gain_model(runStartMjd, runEndMjd);
coaParameterStruct.readNoiseModel = retrieve_read_noise_model(runStartMjd, runEndMjd);
coaParameterStruct.linearityModel = retrieve_linearity_model(runStartMjd, runEndMjd, module, output);
coaParameterStruct.twoDBlackModel = retrieve_two_d_black_model(module, output);
coaParameterStruct.undershootModel = retrieve_undershoot_model();
coaParameterStruct.flatFieldModel = retrieve_flat_field_model(module, output);

integrationTime = get(runParamsObject, 'integrationTime');
transferTime = get(runParamsObject, 'transferTime');

coaConfigurationStruct.dvaMeshEdgeBuffer = -1; % how close to the edge of a CCD we compute the dva
coaConfigurationStruct.dvaMeshOrder = 3; % order of the polynomial fit to dva mesh
coaConfigurationStruct.nDvaMeshRows = 5; % size of the mesh on which to compute DVA
coaConfigurationStruct.nDvaMeshCols = 5; % size of the mesh on which to compute DVA
coaConfigurationStruct.nOutputBufferPix = 2; % # of pixels to allow off visible ccd
coaConfigurationStruct.nStarImageRows = 21; % rows in each star image
coaConfigurationStruct.nStarImageCols = 21; % columns in each star image
coaConfigurationStruct.starChunkLength = 5000; % # of stars to process at a time

if runTadObject.usePointingOffsets
	coaConfigurationStruct.raOffset = get(runParamsObject, 'raOffset');
	coaConfigurationStruct.decOffset = get(runParamsObject, 'decOffset');
	coaConfigurationStruct.phiOffset = get(runParamsObject, 'phiOffset');
else
	coaConfigurationStruct.raOffset = 0;
	coaConfigurationStruct.decOffset = 0;
	coaConfigurationStruct.phiOffset = 0;
end
coaConfigurationStruct.saturationSpillBufferSize = .75;

coaParameterStruct.fcConstants = get(runParamsObject, 'fcConstants');

coaParameterStruct.kicEntryDataStruct = kicEntryDataStruct;
coaParameterStruct.targetKeplerIDList = targetKeplerIDList;
coaParameterStruct.raDec2PixModel = retrieve_ra_dec_2_pix_model();

% infer file name format from psfFileLocation contents
% the name format is 'kplr2008081921-032_psf.mat', we have to pick off
% the identifier, e.g. 2008081921
prfLocation = '/path/to/prf/v7/';
fileNames = dir(prfLocation);
for n=1:length(fileNames)
    if ~isempty(strfind(fileNames(n).name, '_prf.bin'))
        % we have a psf file name
        nameData = sscanf(fileNames(n).name, 'kplr%d-%d_prf.bin');
        break;
    end
end
prfFilename = sprintf('kplr%d-%02d%d_prf.bin', nameData(1), module, output);
disp(['loading prf from ' prfLocation prfFilename]);
fid = fopen([prfLocation prfFilename]);

coaParameterStruct.prfBlob = fread(fid, 'uint8');
fclose(fid);
coaParameterStruct.coaConfigurationStruct = coaConfigurationStruct;
coaParameterStruct.startTime = get(runParamsObject, 'runStartDate');
coaParameterStruct.duration = get(runParamsObject, 'runDurationDays');
if coaParameterStruct.duration < 2
	coaParameterStruct.duration = 2;
end
coaParameterStruct.module = module;
coaParameterStruct.output = output;

coaParameterStruct.spacecraftConfigurationStruct.millisecondsPerReadout = transferTime;
coaParameterStruct.spacecraftConfigurationStruct.millisecondsPerFgsFrame = 103.79;
coaParameterStruct.spacecraftConfigurationStruct.fgsFramesPerIntegration ...
	= integrationTime/coaParameterStruct.spacecraftConfigurationStruct.millisecondsPerFgsFrame/1000;
coaParameterStruct.spacecraftConfigurationStruct.integrationsPerShortCadence ...
	= get(runParamsObject, 'exposuresPerShortCadence');
coaParameterStruct.spacecraftConfigurationStruct.shortCadencesPerLongCadence ...
	= get(runParamsObject, 'shortsPerLongCadence');

coaParameterStruct.debugFlag = debugFlag;

%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%

function amtParameterStruct = make_amt_input(coaResultStruct, debugFlag)

amaParameterStruct = make_ama_input(coaResultStruct, [], debugFlag);

amtParameterStruct.maskDefinitions = [];
amtParameterStruct.optimalApertureStructs = amaParameterStruct.apertureStructs;
amtParameterStruct.fcConstants = amaParameterStruct.fcConstants;
amtParameterStruct.amaConfigurationStruct = amaParameterStruct.amaConfigurationStruct;

amtParameterStruct.amtConfigurationStruct.maxMasks = single(770);
amtParameterStruct.amtConfigurationStruct.maxPixelsInMask = single(85);
amtParameterStruct.amtConfigurationStruct.maxMaskRows = single(11);
amtParameterStruct.amtConfigurationStruct.maxMaskCols = single(11);
amtParameterStruct.amtConfigurationStruct.centerRow = single(6);
amtParameterStruct.amtConfigurationStruct.centerCol = single(6);
amtParameterStruct.amtConfigurationStruct.minEccentricity = single(0.4);
amtParameterStruct.amtConfigurationStruct.maxEccentricity = single(0.9);
amtParameterStruct.amtConfigurationStruct.stepEccentricity = single(0.1);
amtParameterStruct.amtConfigurationStruct.stepInclination = single(pi/6);
amtParameterStruct.amtConfigurationStruct.maxPixelsInSmallMask = single(75);
amtParameterStruct.amtConfigurationStruct.nNestedBoxes = single(5);
amtParameterStruct.amtConfigurationStruct.maxMaskHeight = single(100);
amtParameterStruct.amtConfigurationStruct.maxMaskWidth = single(22);
amtParameterStruct.debugFlag = debugFlag;

%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%

function amaParameterStruct = make_ama_input(coaResultStruct, debugFlag)
apertures = coaResultStruct.optimalApertures;
apertures = rmfield(apertures, 'SNR');
apertures = rmfield(apertures, 'crowdingMetric');
apertures = rmfield(apertures, 'fluxFractionInAperture');
apertures = rmfield(apertures, 'distanceFromEdge');

load configuration_files/maskDefinitions_mag9_1halo.mat;
amaParameterStruct.maskDefinitions = maskDefinitions;
amaParameterStruct.maskTableParametersStruct = maskTableParametersStruct;

amaParameterStruct.apertureStructs = apertures;
for i=1:length(amaParameterStruct.apertureStructs)
	amaParameterStruct.apertureStructs(i).custom = 0;
	amaParameterStruct.apertureStructs(i).labels = [];
end

amaParameterStruct.fcConstants = convert_fc_constants_java_2_struct();
amaParameterStruct.amaConfigurationStruct.defaultStellarLabels ...
	= {'TAD_ONE_HALO', 'TAD_ADD_UNDERSHOOT_COLUMN'};
amaParameterStruct.amaConfigurationStruct.defaultCustomLabels ...
	= {'TAD_NO_HALO', 'TAD_NO_UNDERSHOOT_COLUMN'};
amaParameterStruct.amaConfigurationStruct.useHaloApertures = 1;
amaParameterStruct.debugFlag = debugFlag;
 
%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%

function bpaParameterStruct = make_bpa_input(coaResultStruct, debugFlag)
bpaParameterStruct.moduleOutputImage = coaResultStruct.completeOutputImage; % the full image for this module output
bpaParameterStruct.bpaConfigurationStruct.lineStartRow = coaResultStruct.minRow; % will be set by other parts of TAD
bpaParameterStruct.bpaConfigurationStruct.lineEndRow = coaResultStruct.maxRow;
bpaParameterStruct.bpaConfigurationStruct.lineStartCol = coaResultStruct.minCol;
bpaParameterStruct.bpaConfigurationStruct.lineEndCol = coaResultStruct.maxCol;
bpaParameterStruct.bpaConfigurationStruct.nLinesRow = 25;
bpaParameterStruct.bpaConfigurationStruct.nLinesCol = 45; % nLinesRow*nLinesCol should match numBackgroundApertures
bpaParameterStruct.bpaConfigurationStruct.nEdge = 6; % # of point in edge region: 2*nEdge + ncenter = nlines
bpaParameterStruct.bpaConfigurationStruct.edgeFraction = 1/10; % fractional size of hi-res edge
bpaParameterStruct.bpaConfigurationStruct.histBinSize = 100; % 
bpaParameterStruct.fcConstants = convert_fc_constants_java_2_struct();

bpaParameterStruct.debugFlag = debugFlag;

