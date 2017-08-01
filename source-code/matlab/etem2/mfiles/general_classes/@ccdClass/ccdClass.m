function ccdObject = ccdClass(ccdData, runParamsObject)
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

if ~mod(get(runParamsObject, 'targetImageSize'), 2)
    error('ccdObject: targetImageSize must be odd');
end

ccdData.className = 'ccdClass';
% instantiate the dva motion class specified in the dvaMotionData field
classString = ...
    ['ccdData.dvaMotionObject = ' ...
    ccdData.dvaMotionData.className '(ccdData.dvaMotionData, runParamsObject);'];
classString
eval(classString);
clear classString;
ccdData.dvaMotionData = [];

% instantiate the jitter motion class specified in the dvaMotionData field
classString = ...
    ['ccdData.jitterMotionObject = ' ...
    ccdData.jitterMotionData.className '(ccdData.jitterMotionData, runParamsObject);'];
classString
eval(classString);
clear classString;
ccdData.jitterMotionData = [];

% instantiate the motion class list specified in the motionDataList field
if ~isempty(ccdData.motionDataList)
    for i=1:length(ccdData.motionDataList)
        classString = ...
            ['ccdData.motionObjectList(i) = ' ...
            ccdData.motionDataList(i).className '(ccdData.motionDataList(i), runParamsObject);'];
        classString
        eval(classString);
        clear classString;
    end
else
    ccdData.motionObjectList = [];
end
ccdData.motionDataList = [];

% instantiate the visible background class list specified in the visibleBackgroundDataList field
if ~isempty(ccdData.visibleBackgroundDataList)
    for i=1:length(ccdData.visibleBackgroundDataList)
        classString = ...
            ['ccdData.visibleBackgroundObjectList{i} = ' ...
            ccdData.visibleBackgroundDataList{i}.className ...
            '(ccdData.visibleBackgroundDataList{i}, runParamsObject);'];
        classString
        eval(classString);
        clear classString;
    end
else
    ccdData.visibleBackgroundObjectList = [];
end
ccdData.visibleBackgroundDataList = [];

% instantiate the pixel background class list specified in the pixelBackgroundDataList field
if ~isempty(ccdData.pixelBackgroundDataList)
    for i=1:length(ccdData.pixelBackgroundDataList)
        classString = ...
            ['ccdData.pixelBackgroundObjectList{i} = ' ...
            ccdData.pixelBackgroundDataList{i}.className ...
            '(ccdData.pixelBackgroundDataList{i}, runParamsObject);'];
        classString
        eval(classString);
        clear classString;
    end
else
    ccdData.pixelBackgroundObjectList = [];
end
ccdData.pixelBackgroundDataList = [];

% instantiate the flat field component class list specified in the flatFieldDataList field
if ~isempty(ccdData.flatFieldDataList)
    for i=1:length(ccdData.flatFieldDataList)
        classString = ...
            ['ccdData.flatFieldObjectList{i} = ' ...
            ccdData.flatFieldDataList{i}.className ...
            '(ccdData.flatFieldDataList{i}, runParamsObject);'];
        classString
        eval(classString);
        clear classString;
    end
else
    ccdData.flatFieldObjectList = [];
end
ccdData.flatFieldDataList = [];

% instantiate the object that converts between electrons and ADU (aka DN)
if ~isempty(ccdData.electronsToAduData)
    classString = ...
        ['ccdData.electronsToAduObject = ' ...
        ccdData.electronsToAduData.className ...
        '(ccdData.electronsToAduData, runParamsObject);'];
    classString
    eval(classString);
    clear classString;
else
    error('ccdClass:no electronsToAduData');
end
ccdData.electronsToAduData = [];

% instantiate the black level object, which must come after the
% instantiation of the object that converts between electrons and ADU (aka
% DN)
if ~isempty(ccdData.blackLevelData)
    classString = ...
        ['ccdData.blackLevelObject = ' ...
        ccdData.blackLevelData.className ...
        '(ccdData.blackLevelData, runParamsObject, ccdData.electronsToAduObject);'];
    classString
    eval(classString);
    clear classString;
else
    error('ccdClass:no blackLevelData');
end
ccdData.blackLevelData = [];

% instantiate the spatially varying well depth object
if ~isempty(ccdData.wellDepthVariationData)
    classString = ...
        ['ccdData.wellDepthVariationObject = ' ...
        ccdData.wellDepthVariationData.className ...
        '(ccdData.wellDepthVariationData, runParamsObject);'];
    classString
    eval(classString);
    clear classString;
else
    error('ccdClass:no wellDepthVariationData');
end
ccdData.wellDepthVariationData = [];

% instantiate the pixel effect component class list specified in the pixelEffectDataList field
if ~isempty(ccdData.pixelEffectDataList)
    for i=1:length(ccdData.pixelEffectDataList)
        classString = ...
            ['ccdData.pixelEffectObjectList{i} = ' ...
            ccdData.pixelEffectDataList{i}.className ...
            '(ccdData.pixelEffectDataList{i}, runParamsObject);'];
        classString
        eval(classString);
        clear classString;
    end
else
    ccdData.pixelEffectObjectList = [];
end
ccdData.pixelEffectDataList = [];

% instantiate the pixel noise class list specified in the pixelNoiseDataList field, which must come after the
% instantiation of the object that converts between electrons and ADU (aka
% DN)
if ~isempty(ccdData.pixelNoiseDataList)
    for i=1:length(ccdData.pixelNoiseDataList)
        classString = ...
            ['ccdData.pixelNoiseObjectList{i} = ' ...
            ccdData.pixelNoiseDataList{i}.className ...
            '(ccdData.pixelNoiseDataList{i}, runParamsObject, ccdData.electronsToAduObject);'];
        classString
        eval(classString);
        clear classString;
    end
else
    ccdData.pixelNoiseObjectList = [];
end
ccdData.pixelNoiseDataList = [];

% instantiate the electronics effects class list specified in the
% electronicsEffectDataList field
if ~isempty(ccdData.electronicsEffectDataList)
    for i=1:length(ccdData.electronicsEffectDataList)
        classString = ...
            ['ccdData.electronicsEffectObjectList{i} = ' ...
            ccdData.electronicsEffectDataList{i}.className ...
            '(ccdData.electronicsEffectDataList{i}, runParamsObject);'];
        classString
        eval(classString);
        clear classString;
    end
else
    ccdData.electronicsEffectObjectList = [];
end
ccdData.electronicsEffectDataList = [];

% instantiate the read noise class list specified in the readNoiseDataList field, which must come after the
% instantiation of the object that converts between electrons and ADU (aka
% DN)
if ~isempty(ccdData.readNoiseDataList)
    for i=1:length(ccdData.readNoiseDataList)
        classString = ...
            ['ccdData.readNoiseObjectList{i} = ' ...
            ccdData.readNoiseDataList{i}.className ...
            '(ccdData.readNoiseDataList{i}, runParamsObject, ccdData.electronsToAduObject);'];
        classString
        eval(classString);
        clear classString;
    end
else
    ccdData.readNoiseObjectList = [];
end
ccdData.readNoiseDataList = [];

% instantiate the ccdPlane class list specified in the ccdPlaneObjectList field
for i=1:length(ccdData.ccdPlaneDataList)
    ccdData.ccdPlaneDataList(i).planeNumber = i;
    ccdData.ccdPlaneObjectList(i) = ...
        ccdPlaneClass(ccdData.ccdPlaneDataList(i), runParamsObject);
end
ccdData.ccdPlaneDataList = [];

% instantiate the cosmic ray object
if ~isempty(ccdData.cosmicRayData)
    ccdData.cosmicRayObject = ...
        cosmicRayClass(ccdData.cosmicRayData, runParamsObject);
else
    ccdData.cosmicRayObject = [];
end

% instantiate the output data manager, depending on the type of output
switch get(runParamsObject, 'cadenceType')
    case 'long'
        ccdData.cadenceDataObject = ...
        longCadenceDataClass(struct('classname', 'longCadenceDataClass'), runParamsObject);
        
    case 'short'
        ccdData.cadenceDataObject = ...
        shortCadenceDataClass(struct('classname', 'shortCadenceDataClass'), runParamsObject);
        
    otherwise 
        error('runParamsObject.cadenceType must be either <long> or <short>');
end
    
outputDirectory = get(runParamsObject, 'outputDirectory');

% load configuration_files/requantizationTable
module = get(runParamsObject, 'moduleNumber');
output = get(runParamsObject, 'outputNumber');
channel = convert_from_module_output(module, output);
% requantizationTable = double(retrieve_requant_table( ...
%     get(runParamsObject, 'requantizationTableId')));
% [requantizationTable, meanBlackTable, requantOffset] ...
%     = fake_requant_table(get(runParamsObject, 'requantizationTableId'));
[requantizationTable, meanBlackTable] ...
    = retrieve_requant_table(get(runParamsObject, 'requantizationTableId'));
ccdData.requantizationTable = double(requantizationTable);
ccdData.requantTableLcFixedOffset = get(runParamsObject, 'requantTableLcFixedOffset');
ccdData.requantTableScFixedOffset = get(runParamsObject, 'requantTableScFixedOffset');
ccdData.requantizationMeanBlack = double(meanBlackTable(channel));
save([outputDirectory filesep 'requantizationTable.mat'], 'requantizationTable', 'meanBlackTable');

ccdData.targetDefinitionSpec.moduleShift = 24;
ccdData.targetDefinitionSpec.outputShift = 16;
ccdData.targetDefinitionSpec.rowShift = 21;
ccdData.targetDefinitionSpec.colShift = 10;

ccdData.apertureDefinitionSpec.patternShift = 16;
ccdData.apertureDefinitionSpec.rowShift = 16;

ccdData.dataBufferSize = 1e6;

ccdData.motionGridRow = [];
ccdData.motionGridCol = [];
ccdData.badFitPixelStruct = [];
ccdData.targetScienceManagerObject = [];

if ~isfield(ccdData, 'targetScienceManagerData')
	% set the targetScienceManagerData field if it's not already defined
	ccdData.targetScienceManagerData = [];
end

ccdData.ccdImageFilename = [outputDirectory filesep 'ccdImage.mat'];
ccdData.poiFilename = [outputDirectory filesep 'pixelsOfInterest.mat'];
ccdData.ccdTimeSeriesFilename = [outputDirectory filesep 'ccdTimeSeries.dat'];
ccdData.ccdTimeSeriesNoCrFilename = [outputDirectory filesep 'ccdTimeSeriesNoCr.dat'];
ccdData.badFitPixelStructFilename = [outputDirectory filesep 'badFitPixelStruct.mat'];
ccdData.ssrOutputDirectory = 'ssrOutput';

apertureDefinitionFilename = 'apertureDefinitions.dat';
targetDefinitionFilename = 'targetDefinitions.dat';
backgroundApertureDefinitionFilename = 'backApertureDefinitions.dat';
backgroundTargetDefinitionFilename = 'backTargetDefinitions.dat';
referencePixelTargetDefinitionFilename = 'refPixTargetDefinitions.dat';
scienceCadenceFilename = 'scienceCadenceData.dat';
scienceCadenceNoCrFilename = 'scienceCadenceDataNoCr.dat';
quantizedCadenceFilename = 'quantizedCadenceData.dat';
quantizedCadenceNoCrFilename = 'quantizedCadenceDataNoCr.dat';
requantizedCadenceFilename = 'requantizedCadenceData.dat';
requantizedCadenceNoCrFilename = 'requantizedCadenceDataNoCr.dat';
ffiFilename = 'ffiData.dat';
refPixFilename = 'referencePixels.dat';
refPixNoCrFilename = 'referencePixelsNoCr.dat';

ccdData.apertureDefinitionFilename = [outputDirectory filesep ...
    ccdData.ssrOutputDirectory  filesep apertureDefinitionFilename];
ccdData.targetDefinitionFilename = [outputDirectory filesep ...
    ccdData.ssrOutputDirectory  filesep targetDefinitionFilename];
ccdData.backgroundApertureDefinitionFilename = [outputDirectory filesep ...
    ccdData.ssrOutputDirectory  filesep backgroundApertureDefinitionFilename];
ccdData.backgroundTargetDefinitionFilename = [outputDirectory filesep ...
    ccdData.ssrOutputDirectory  filesep backgroundTargetDefinitionFilename];
ccdData.referencePixelTargetDefinitionFilename = [outputDirectory filesep ...
    ccdData.ssrOutputDirectory  filesep referencePixelTargetDefinitionFilename];
ccdData.scienceCadenceFilename = [outputDirectory filesep ...
    ccdData.ssrOutputDirectory  filesep scienceCadenceFilename];
ccdData.scienceCadenceNoCrFilename = [outputDirectory filesep ...
    ccdData.ssrOutputDirectory  filesep scienceCadenceNoCrFilename];
ccdData.quantizedCadenceFilename = [outputDirectory filesep ...
    ccdData.ssrOutputDirectory  filesep quantizedCadenceFilename];
ccdData.quantizedCadenceNoCrFilename = [outputDirectory filesep ...
    ccdData.ssrOutputDirectory  filesep quantizedCadenceNoCrFilename];
ccdData.requantizedCadenceFilename = [outputDirectory filesep ...
    ccdData.ssrOutputDirectory  filesep requantizedCadenceFilename];
ccdData.requantizedCadenceNoCrFilename = [outputDirectory filesep ...
    ccdData.ssrOutputDirectory  filesep requantizedCadenceNoCrFilename];
ccdData.ffiFilename = [outputDirectory filesep ...
    ccdData.ssrOutputDirectory  filesep ffiFilename];
ccdData.refPixFilename = [outputDirectory filesep ...
    ccdData.ssrOutputDirectory  filesep refPixFilename];
ccdData.refPixNoCrFilename = [outputDirectory filesep ...
    ccdData.ssrOutputDirectory  filesep refPixNoCrFilename];

ccdObject = class(ccdData, 'ccdClass', runParamsObject);

% initialize the special motions
ccdObject.jitterMotionObject = ...
    load_jitter_data(ccdObject.jitterMotionObject, ccdObject);
%initialize the ccd planess
ccdObject = initialize_ccdPlanes(ccdObject);
% create the motion polynomials on the planes
ccdObject = make_motion_basis(ccdObject);
if isfield(ccdData, 'motionOnly')
    return;
end
% create the prf polynomial representation in each ccd plane
ccdObject = make_prf_poly(ccdObject);

% write out a some of these values to help the user utilities
ssrFileStruct.targetDefinitionSpec = ccdObject.targetDefinitionSpec;
ssrFileStruct.apertureDefinitionSpec = ccdObject.apertureDefinitionSpec;
ssrFileStruct.ssrOutputDirectory = ccdObject.ssrOutputDirectory;
ssrFileStruct.apertureDefinitionFilename = apertureDefinitionFilename;
ssrFileStruct.targetDefinitionFilename = targetDefinitionFilename;
ssrFileStruct.backgroundApertureDefinitionFilename = backgroundApertureDefinitionFilename;
ssrFileStruct.backgroundTargetDefinitionFilename = backgroundTargetDefinitionFilename;
ssrFileStruct.referencePixelTargetDefinitionFilename = referencePixelTargetDefinitionFilename;
ssrFileStruct.scienceCadenceFilename = scienceCadenceFilename;
ssrFileStruct.quantizedCadenceFilename = quantizedCadenceFilename;
ssrFileStruct.scienceCadenceNoCrFilename = scienceCadenceNoCrFilename;
ssrFileStruct.quantizedCadenceNoCrFilename = quantizedCadenceNoCrFilename;
ssrFileStruct.ffiFilename = ffiFilename;
ssrFileStruct.refPixFilename = refPixFilename;
ssrFileStruct.refPixNoCrFilename = refPixNoCrFilename;

save([outputDirectory filesep 'ssrFileMap.mat'], 'ssrFileStruct');
