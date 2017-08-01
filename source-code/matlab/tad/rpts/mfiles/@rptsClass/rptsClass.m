function rptsObject = rptsClass(rptsInputStruct)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Constructor rptsObject = rptsClass(rptsInputStruct)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% This method is based on the constructor developed for pdqScience
% by H. Chandrasekaran
%
% This method first checks for the presence of expected fields in the input
% structure, then checks whether each parameter is within the appropriate range.
% Once the validation of the inputs is complete, this method then implements
% the constructor for the rptsClass, and then converts the required row/column
% inputs from (java) 0-base to (matlab) 1-base.
%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% INPUT:  A data structure 'rptsInputStruct' with the following fields:
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% top level
%  rptsInputStruct contains the following fields (example):
%
%  rptsInputStruct = 
%                         module: 20
%                         output: 3
%              moduleOutputImage: [1x1070 struct]
%               stellarApertures: [1x5 struct]
%          dynamicRangeApertures: [1x1 struct]
%                  existingMasks: [1x772 struct]
%                 readNoiseModel: [1x1 struct]
%     rptsModuleParametersStruct: [1x1 struct]
%             scConfigParameters: [1x1 struct]
%                      debugFlag: 0
%
% where:
%          moduleOutputImage: [struct array]    image on the module output CCD produced by COA
%           stellarApertures: [struct array]    optimal aperture for selected stellar targets
%      dynamicRangeApertures: [struct array]    optimal 'aperture' for dynamic range targets
%              existingMasks: [struct array]    input table of mask definitions
%    rptsModuleParametersStruct: [struct]       module parameters
%                  debugFlag: [logical]         flag for debug mode
%
%--------------------------------------------------------------------------
% second level
%  rptsInputStruct.rptsModuleParametersStruct is a struct array with the
%  following fields:
%                         nHaloRings: [int]     number of halo rings to add to optimal aperture
%  radiusForBackgroundPixelSelection: [int]     radius (in pixels) of circle centered around each stellar target
%                                                   that bounds area from which to select background pixels
%  nBackgroundPixelsPerStellarTarget: [int]     number of background pixels to select for each stellar target
%                          smearRows: [array]   list of smear row numbers to use for collecting
%                                                   collateral pixels [valid ranges are <=25 or (>=1050 && <= 1069)]
%                       blackColumns: [array]   list of black column numbers to use for collecting
%                                                   collateral pixels [valid ranges are <=11 or (>=1113 && 1132)]
%               backgroundModeThresh: [int]     a threshold value that is multipled to the median absolute deviation
%                                                   of the target image, which determines an upper bound for selecting
%                                                   pixels close to the background mode
%                   smearNoiseRatioThresh: [int]     a threshold value that provides an upper bound to the ratio of smear noise
%                                                   in an image to the smear-removed image
%
%     % may be implemented in future:
%                        % superMask: [logical]         flag = 1 for 1 mask, flag = 0 for 3 (super) masks
%--------------------------------------------------------------------------
% second level
%  rptsInputStruct.stellarApertures is a struct array with the following fields:
%               keplerId: [struct array]    target star KIC id number
%           referenceRow: [struct array]    reference row on the module output for this aperture
%        referenceColumn: [struct array]    reference column on the module output for this aperture
%          badPixelCount: [struct array]    list of bad pixels (logical?)
%                offsets: [struct]          list of row/column offsets relative to referenceRow and referenceColumn
% third level
%  rptsInputStruct.stellarApertures.offsets is a struct array with the fields:
%                    row: [struct array]    row offset
%                 column: [struct array]    column offset
%--------------------------------------------------------------------------
% second level
%  rptsInputStruct.dynamicRangeApertures is a struct array with the following fields:
%               keplerId: [struct array]    target star KIC id number
%           referenceRow: [struct array]    reference row on the module output for this aperture
%        referenceColumn: [struct array]    reference column on the module output for this aperture
%          badPixelCount: [struct array]    list of bad pixels (logical?)
%                offsets: [struct]          list of row/column offsets relative to referenceRow and referenceColumn
%
%  rptsInputStruct.dynamicRangeApertures.offsets is a struct array with the fields:
%                    row: [struct array]    row offset
%                 column: [struct array]    column offset
%--------------------------------------------------------------------------
% second level
%  rptsInputStruct.existingMasks is a struct with the following fields:
%                offsets: [struct]
%
% third level
%  rptsInputStruct.existingMasks.offsets is a struct array with the following fields:
%                    row: [struct array]    row offset
%                 column: [struct array]    column offset
%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%  OUTPUT: An object 'rptsResultsStruct' of class 'rptsResultsClass' containing the following fields
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% top level
%  rptsResultsStruct is a struct array with the following fields:
%                  stellarTargetDefinitions: [struct array]
%             dynamicRangeTargetDefinitions: [struct array]
%                backgroundTargetDefinition: [struct array]
%                    blackTargetDefinitions: [struct array]
%                    smearTargetDefinitions: [struct array]
%                  backgroundMaskDefinition: [struct array]
%                       blackMaskDefinition: [struct array]
%                       smearMaskDefinition: [struct array]
%
%--------------------------------------------------------------------------
% second level
%  rptsResultsStruct.stellarTargetDefinitions is a struct array with the following fields:
%               keplerId: [struct array]    target star KIC id number
%           referenceRow: [struct array]    reference row on the module output for this target definition
%        referenceColumn: [struct array]    reference column on the module output for this target definition
%              maskIndex: [struct array]    index into existingMasks table for this target definition
%           excessPixels: [struct array]    the number of pixels in the assigned mask that are not in the requested aperture
%                 status: [struct array]    status indicating successful mask assignment:
%                                              status = -1: no mask assigned
%                                              status =  1: mask assigned, no problems
%                                              status = -2: mask assigned but has pixels off the CCD
%
%  rptsResultsStruct.dynamicRangeTargetDefinitions is a struct array with the following fields:
%               keplerId: [struct array]    target star KIC id number
%           referenceRow: [struct array]    reference row on the module output for this target definition
%        referenceColumn: [struct array]    reference column on the module output for this target definition
%              maskIndex: [struct array]    index into existingMasks table for this target definition
%           excessPixels: [struct array]    the number of pixels in the assigned mask that are not in the requested aperture
%                 status: [struct array]    status indicating successful mask assignment:
%                                              status = -1: no mask assigned
%                                              status =  1: mask assigned, no problems
%                                              status = -2: mask assigned but has pixels off the CCD
%
%  rptsResultsStruct.backgroundTargetDefinition is a struct array with the following fields:
%               keplerId: [struct array]    target star KIC id number
%           referenceRow: [struct array]    reference row on the module output for this target definition
%        referenceColumn: [struct array]    reference column on the module output for this target definition
%              maskIndex: [struct array]    index into backgroundMaskDefinition table for this target definition
%           excessPixels: [struct array]    the number of pixels in the assigned mask that are not in the requested aperture
%                 status: [struct array]    status indicating successful mask assignment:
%                                              status = -1: no mask assigned
%                                              status =  1: mask assigned, no problems
%                                              status = -2: mask assigned but has pixels off the CCD
%
%  rptsResultsStruct.blackTargetDefinitions is a struct array with the following fields:
%               keplerId: [struct array]    target star KIC id number
%           referenceRow: [struct array]    reference row on the module output for this target definition
%        referenceColumn: [struct array]    reference column on the module output for this target definition
%              maskIndex: [struct array]    index into blackMaskDefinition table for this target definition
%           excessPixels: [struct array]    the number of pixels in the assigned mask that are not in the requested aperture
%                 status: [struct array]    status indicating successful mask assignment:
%                                              status = -1: no mask assigned
%                                              status =  1: mask assigned, no problems
%                                              status = -2: mask assigned but has pixels off the CCD
%
%  rptsResultsStruct.smearTargetDefinitions is a struct array with the following fields:
%               keplerId: [struct array]    target star KIC id number
%           referenceRow: [struct array]    reference row on the module output for this target definition
%        referenceColumn: [struct array]    reference column on the module output for this target definition
%              maskIndex: [struct array]    index into smearMaskDefinition table for this target definition
%           excessPixels: [struct array]    the number of pixels in the assigned mask that are not in the requested aperture
%                 status: [struct array]    status indicating successful mask assignment:
%                                              status = -1: no mask assigned
%                                              status =  1: mask assigned, no problems
%                                              status = -2: mask assigned but has pixels off the CCD
%
%  rptsResultsStruct.backgroundMaskDefinition is a struct array with the following field:
%                offsets: [struct]
%
%  rptsResultsStruct.blackMaskDefinition is a struct array with the following field:
%                offsets: [struct]
%
%  rptsResultsStruct.smearMaskDefinition is a struct array with the following field:
%                offsets: [struct]
%
%--------------------------------------------------------------------------
% third level
%  rptsResultsStruct.backgroundMaskDefinition.offsets is a struct array with the following fields:
%                    row: [struct array]    row offset
%                 column: [struct array]    column offset
%
%  rptsResultsStruct.blackMaskDefinition.offsets is a struct array with the following fields:
%                    row: [struct array]    row offset
%                 column: [struct array]    column offset
%
%  rptsResultsStruct.smearMaskDefinition.offsets is a struct array with the following fields:
%                    row: [struct array]    row offset
%                 column: [struct array]    column offset
%
%--------------------------------------------------------------------------
%
% Comments: This constructor generates an error under the following scenarios:
%          (1) when invoked with no inputs
%          (2) when any of the essential fields are missing
%          (3) when any of the fields are NaNs/Infs or outside the appropriate bounds
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

if nargin == 0
    % if no inputs generate an error
    error('TAD:rptsClass:EmptyInputStruct', 'The constructor must be called with an input structure.');
end

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% validate inputs and check fields and bounds
% (1) check for the presence of all fields
% (2) check whether the parameters are within bounds and are not NaNs/Infs
%
% Note: if fields are structures, make sure their bounds are empty

%--------------------------------------------------------------------------
% top level validation
% check for the presence of all top level fields in rptsInputStruct
%--------------------------------------------------------------------------
fieldsAndBounds(1,:)  = { 'module'; []; []; []};
fieldsAndBounds(2,:)  = { 'output'; []; []; []};
fieldsAndBounds(3,:)  = { 'rptsModuleParametersStruct'; []; []; []};
fieldsAndBounds(4,:)  = { 'moduleOutputImage'; []; []; []};
fieldsAndBounds(5,:)  = { 'stellarApertures'; []; []; []};
fieldsAndBounds(6,:)  = { 'dynamicRangeApertures'; []; []; []};
fieldsAndBounds(7,:)  = { 'existingMasks'; []; []; []};
fieldsAndBounds(8,:)  = { 'readNoiseModel'; []; []; []};
fieldsAndBounds(9,:)  = { 'scConfigParameters'; []; []; []};
fieldsAndBounds(10,:)  = { 'fcConstants'; []; []; []};
fieldsAndBounds(11,:)  = { 'debugFlag'; '>= 0'; '<= 2'; []};  

validate_structure(rptsInputStruct, fieldsAndBounds,'rptsInputStruct');
clear fieldsAndBounds

%--------------------------------------------------------------------------
% second level validation
% validate the structure field rptsInputStruct.rptsModuleParametersStruct
%--------------------------------------------------------------------------

fieldsAndBounds(1,:)  = { 'nHaloRings'; '>= 0'; '<= 100'; []};
fieldsAndBounds(2,:)  = { 'radiusForBackgroundPixelSelection'; '>= 0'; '<= 2000'; []};
fieldsAndBounds(3,:)  = { 'nBackgroundPixelsPerStellarTarget'; '>= 0'; '<= 2000'; []};
fieldsAndBounds(4,:)  = { 'smearRows'; []; []; '[1:20, 1045:1070]'};
fieldsAndBounds(5,:)  = { 'blackColumns'; []; []; '[1:12, 1113:1132]'};
fieldsAndBounds(6,:)  = { 'backgroundModeThresh'; '>= 0'; '<= 100'; []};
fieldsAndBounds(7,:)  = { 'smearNoiseRatioThresh'; '>= 0'; '<= 100'; []};

validate_structure(rptsInputStruct.rptsModuleParametersStruct, fieldsAndBounds, ...
    'rptsInputStruct.rptsModuleParametersStruct');
clear fieldsAndBounds

%--------------------------------------------------------------------------
% second level validation
% validate the structure field rptsInputStruct.moduleOutputImage, if available
if (~isempty(rptsInputStruct.moduleOutputImage))
    
    %fieldsAndBounds(1,:)  = { 'array'; '>= 0'; '< 1e10'; []};
    fieldsAndBounds(1,:)  = { 'array'; []; []; []};

    nStructures = length(rptsInputStruct.moduleOutputImage);

    for j = 1:nStructures
        validate_structure(rptsInputStruct.moduleOutputImage(j), fieldsAndBounds, ...
            'rptsInputStruct.moduleOutputImage');
    end
    clear fieldsAndBounds
end

%--------------------------------------------------------------------------
% second level validation
% validate the structure field rptsInputStruct.stellarApertures

fieldsAndBounds(1,:)  = { 'keplerId'; '> 0'; '< 1e9'; []};
fieldsAndBounds(2,:)  = { 'badPixelCount';  '>= 0'; '< 1e9'; []};
fieldsAndBounds(3,:)  = { 'referenceRow';  '>= 0'; '<= 1070'; []};
fieldsAndBounds(4,:)  = { 'referenceColumn';  '>= 0'; '<= 1132'; []};
fieldsAndBounds(5,:)  = { 'offsets'; []; []; []};

nStructures = length(rptsInputStruct.stellarApertures);
for j = 1:nStructures
    validate_structure(rptsInputStruct.stellarApertures(j), fieldsAndBounds, ...
        'rptsInputStruct.stellarApertures');
end

clear fieldsAndBounds

% third level validation
% validate the structure field rptsInputStruct.stellarApertures.offsets
% Note the value 2^15 is taken from the format (#bits) of the aperture pattern
% definition described in the FS-GS ICD
fieldsAndBounds(1,:)  = { 'row'; '> -2^15'; '< 2^15'; []};
fieldsAndBounds(2,:)  = { 'column'; '> -2^15'; '< 2^15'; []};

kStructs = length(rptsInputStruct.stellarApertures);
for i = 1:kStructs
    nStructures = length(rptsInputStruct.stellarApertures(i).offsets);

    for j = 1:nStructures
        validate_structure(rptsInputStruct.stellarApertures(i).offsets(j), ...
            fieldsAndBounds,'rptsInputStruct.stellarApertures(i).offsets');
    end

end

clear fieldsAndBounds

%--------------------------------------------------------------------------
% second level validation
% validate the structure field rptsInputStruct.dynamicRangeApertures

fieldsAndBounds(1,:)  = { 'keplerId'; '> 0'; '< 1e9'; []};
fieldsAndBounds(2,:)  = { 'badPixelCount';  '>= 0'; '< 1e9'; []};
fieldsAndBounds(3,:)  = { 'referenceRow';  '>= 0'; '<= 1070'; []};
fieldsAndBounds(4,:)  = { 'referenceColumn';  '>= 0'; '<= 1132'; []};
fieldsAndBounds(5,:)  = { 'offsets'; []; []; []};

nStructures = length(rptsInputStruct.dynamicRangeApertures);

for j = 1:nStructures
    validate_structure(rptsInputStruct.dynamicRangeApertures(j), fieldsAndBounds, ...
        'rptsInputStruct.dynamicRangeApertures');
end

clear fieldsAndBounds

% third level validation
% validate the structure field rptsInputStruct.dynamicRangeApertures.offsets
% Note the value 2^15 is taken from the format (#bits) of the aperture pattern
% definition described in the FS-GS ICD
fieldsAndBounds(1,:)  = { 'row'; '> -2^15'; '< 2^15'; []};
fieldsAndBounds(2,:)  = { 'column'; '> -2^15'; '< 2^15'; []};

kStructs = length(rptsInputStruct.dynamicRangeApertures);
for i = 1:kStructs
    nStructures = length(rptsInputStruct.dynamicRangeApertures(i).offsets);

    for j = 1:nStructures
        validate_structure(rptsInputStruct.dynamicRangeApertures(i).offsets(j), ...
            fieldsAndBounds,'rptsInputStruct.dynamicRangeApertures(i).offsets');
    end

end

clear fieldsAndBounds

%--------------------------------------------------------------------------
% second level validation
% validate the structure field rptsInputStruct.existingMasks

fieldsAndBounds(1,:)  = { 'offsets'; []; []; []};

nStructures = length(rptsInputStruct.existingMasks);

% check for empty 'offset' structures in existingMasks 
for j = 1:nStructures
    
     if(isempty(rptsInputStruct.existingMasks(j).offsets))
        error('TAD:rptsClass:emptyExistingMasksField', 'The existingMasks table has an invalid entry (offsets structure is empty).');
     end
end

% if all entries in existing masks table are valid, then proceed
for j = 1:nStructures
    validate_structure(rptsInputStruct.existingMasks(j), fieldsAndBounds, ...
        'rptsInputStruct.existingMasks');
end

clear fieldsAndBounds

% third level validation
% validate the structure field rptsInputStruct.existingMasks.offsets
% Note the value 2^15 is taken from the format (#bits) of the aperture pattern
% definition described in the FS-GS ICD
fieldsAndBounds(1,:)  = { 'row'; '> -2^15'; '< 2^15'; []};
fieldsAndBounds(2,:)  = { 'column'; '> -2^15'; '< 2^15'; []};

kStructs = length(rptsInputStruct.existingMasks);
for i = 1:kStructs
    nStructures = length(rptsInputStruct.existingMasks(i).offsets);

    for j = 1:nStructures
        validate_structure(rptsInputStruct.existingMasks(i).offsets(j), ...
            fieldsAndBounds,'rptsInputStruct.existingMasks(i).offsets');
    end
end

clear fieldsAndBounds


%--------------------------------------------------------------------------
% validate FC constants

% rptsInputStruct.fcConstants fields
fieldsAndBounds = cell(6,4);

fieldsAndBounds(1,:)  = { 'nRowsImaging'; '== 1024'; []; []};
fieldsAndBounds(2,:)  = { 'nColsImaging'; '== 1100'; []; []};
fieldsAndBounds(3,:)  = { 'nLeadingBlack'; '==12'; []; []};
fieldsAndBounds(4,:)  = { 'nTrailingBlack'; '==20'; []; []};
fieldsAndBounds(5,:)  = { 'nVirtualSmear'; '==26'; []; []};
fieldsAndBounds(6,:)  = { 'nMaskedSmear'; '== 20'; []; []};

validate_structure(rptsInputStruct.fcConstants, fieldsAndBounds, 'rptsInputStruct.fcConstants');
clear fieldsAndBounds;




%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% include additional fields to the rpts object that are computed later, so the
% object alone may be passed into subsequent functions
rptsInputStruct.stellarTargetDefinitions = [];
rptsInputStruct.stellarIndices = [];        % row/cols of stellar pixels + halo

rptsInputStruct.dynamicRangeTargetDefinitions = [];

rptsInputStruct.backgroundTargetDefinition = [];
rptsInputStruct.backgroundIndices = [];     % row/cols of background pixels
rptsInputStruct.backgroundMaskDefinition = [];

rptsInputStruct.smearTargetDefinitions = [];
rptsInputStruct.smearMaskDefinition = [];

rptsInputStruct.blackTargetDefinitions = [];
rptsInputStruct.blackMaskDefinition = [];

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% input validation successfully completed!
% create the rptsClass object
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

rptsObject = class(rptsInputStruct, 'rptsClass');

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% convert the required row/column inputs from (java) 0-base to (matlab) 1-base
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Note: fields that are converted to 1-base are:
%   stellarApertures.referenceRow
%   stellarApertures.referenceColumn
%   dynamicRangeApertures.referenceRow
%   dynamicRangeApertures.referenceColumn
%   rptsModuleParametersStruct.smearRows
%   rptsModuleParametersStruct.blackColumns

[rptsModuleParametersStruct, stellarApertures, dynamicRangeApertures] = ...
    convert_rpts_inputs_to_1_base(rptsObject);

% update fields in object to reflect matlab base-1 indices
rptsObject.rptsModuleParametersStruct = rptsModuleParametersStruct;
rptsObject.stellarApertures = stellarApertures;
rptsObject.dynamicRangeApertures = dynamicRangeApertures;

return