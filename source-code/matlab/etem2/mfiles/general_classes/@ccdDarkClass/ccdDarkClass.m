function ccdDarkObject = ccdDarkClass(ccdDarkData, runParamsObject)
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
    error('ccdDarkObject: targetImageSize must be odd');
end

ccdDarkData.className = 'ccdDarkClass';

% instantiate the object that converts between electrons and ADU (aka DN)
if ~isempty(ccdDarkData.electronsToAduData)
    classString = ...
        ['ccdDarkData.electronsToAduObject = ' ...
        ccdDarkData.electronsToAduData.className ...
        '(ccdDarkData.electronsToAduData, runParamsObject);'];
    classString
    eval(classString);
    clear classString;
else
    error('ccdClass:no electronsToAduData');
end
ccdDarkData.electronsToAduData = [];

% instantiate the black level object, which must come after the
% instantiation of the object that converts between electrons and ADU (aka
% DN)
if ~isempty(ccdDarkData.blackLevelData)
    classString = ...
        ['ccdDarkData.blackLevelObject = ' ...
        ccdDarkData.blackLevelData.className ...
        '(ccdDarkData.blackLevelData, runParamsObject, ccdDarkData.electronsToAduObject);'];
    classString
    eval(classString);
    clear classString;
else
    error('ccdClass:no blackLevelData');
end
ccdDarkData.blackLevelData = [];

% instantiate the spatially varying well depth object
if ~isempty(ccdDarkData.wellDepthVariationData)
    classString = ...
        ['ccdDarkData.wellDepthVariationObject = ' ...
        ccdDarkData.wellDepthVariationData.className ...
        '(ccdDarkData.wellDepthVariationData, runParamsObject);'];
    classString
    eval(classString);
    clear classString;
else
    error('ccdClass:no wellDepthVariationData');
end
ccdDarkData.wellDepthVariationData = [];

% instantiate the pixel effect component class list specified in the pixelEffectDataList field
if ~isempty(ccdDarkData.pixelEffectDataList)
    for i=1:length(ccdDarkData.pixelEffectDataList)
        classString = ...
            ['ccdDarkData.pixelEffectObjectList{i} = ' ...
            ccdDarkData.pixelEffectDataList{i}.className ...
            '(ccdDarkData.pixelEffectDataList{i}, runParamsObject);'];
        classString
        eval(classString);
        clear classString;
    end
else
    ccdDarkData.pixelEffectObjectList = [];
end
ccdDarkData.pixelEffectDataList = [];

% instantiate the pixel noise class list specified in the pixelNoiseDataList field, which must come after the
% instantiation of the object that converts between electrons and ADU (aka
% DN)
if ~isempty(ccdDarkData.pixelNoiseDataList)
    for i=1:length(ccdDarkData.pixelNoiseDataList)
        classString = ...
            ['ccdDarkData.pixelNoiseObjectList{i} = ' ...
            ccdDarkData.pixelNoiseDataList{i}.className ...
            '(ccdDarkData.pixelNoiseDataList{i}, runParamsObject, ccdDarkData.electronsToAduObject);'];
        classString
        eval(classString);
        clear classString;
    end
else
    ccdDarkData.pixelNoiseObjectList = [];
end
ccdDarkData.pixelNoiseDataList = [];

% instantiate the electronics effects class list specified in the
% electronicsEffectDataList field
if ~isempty(ccdDarkData.electronicsEffectDataList)
    for i=1:length(ccdDarkData.electronicsEffectDataList)
        classString = ...
            ['ccdDarkData.electronicsEffectObjectList{i} = ' ...
            ccdDarkData.electronicsEffectDataList{i}.className ...
            '(ccdDarkData.electronicsEffectDataList{i}, runParamsObject);'];
        classString
        eval(classString);
        clear classString;
    end
else
    ccdDarkData.electronicsEffectObjectList = [];
end
ccdDarkData.electronicsEffectDataList = [];

% instantiate the read noise class list specified in the readNoiseDataList field, which must come after the
% instantiation of the object that converts between electrons and ADU (aka
% DN)
if ~isempty(ccdDarkData.readNoiseDataList)
    for i=1:length(ccdDarkData.readNoiseDataList)
        classString = ...
            ['ccdDarkData.readNoiseObjectList{i} = ' ...
            ccdDarkData.readNoiseDataList{i}.className ...
            '(ccdDarkData.readNoiseDataList{i}, runParamsObject, ccdDarkData.electronsToAduObject);'];
        classString
        eval(classString);
        clear classString;
    end
else
    ccdDarkData.readNoiseObjectList = [];
end
ccdDarkData.readNoiseDataList = [];

% instantiate the cosmic ray object
if ~isempty(ccdDarkData.cosmicRayData)
    ccdDarkData.cosmicRayObject = ...
        cosmicRayClass(ccdDarkData.cosmicRayData, runParamsObject);
else
    ccdDarkData.cosmicRayObject = [];
end

% instantiate the output data manager, depending on the type of output
switch get(runParamsObject, 'cadenceType')
    case 'long'
        ccdDarkData.cadenceDataObject = ...
        longCadenceDataClass(struct('classname', 'longCadenceDataClass'), runParamsObject);
        
    case 'short'
        ccdDarkData.cadenceDataObject = ...
        shortCadenceDataClass(struct('classname', 'shortCadenceDataClass'), runParamsObject);
        
    otherwise 
        error('runParamsObject.cadenceType must be either <long> or <short>');
end
    
outputDirectory = get(runParamsObject, 'outputDirectory');

ccdDarkData.dataBufferSize = 1e6;

ccdDarkData.ccdImageFilename = [outputDirectory filesep 'ccdDarkImage'];
ccdDarkData.ssrOutputDirectory = 'ssrOutput';

ffiFilename = 'ffiData';

ccdDarkData.ffiFilename = [outputDirectory filesep ...
    ccdDarkData.ssrOutputDirectory  filesep ffiFilename];

ccdDarkObject = class(ccdDarkData, 'ccdDarkClass', runParamsObject);

% write out a some of these values to help the user utilities
ssrFileStruct.ffiFilename = ffiFilename;

save([outputDirectory filesep 'ssrFileMap.mat'], 'ssrFileStruct');
