function amaObject = amaClass(amaInputStruct)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function amaObject = amaClass(amaInputStruct)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% amaInputStruct is a structure with the following fields:
%   .maskDefinitions array of structures providing the mask aperture
%   definitions, containing the following fields:
%       .offsets array of structures, one for each pixel, containing the fields
%           .row row offsets of this pixel
%           .column row offsets of this pixel
%   .apertureStructs array of structures providing the target aperture
%   definitions, containing the following fields:
%       .keplerId ID for this target
%       .referenceRow reference row on the CCD module output for this aperture
%       .referenceColumn reference column on the CCD module output for this aperture
%       .offsets array of structures, one for each pixel, containing the fields
%           .row row offsets of this pixel
%           .column row offsets of this pixel
%   .fcConstants - struct the fcConstants values
%   .amaConfigurationStruct - struct with the following fields
%
% on completion the struct array targetDefinition is added to amaObject,
% which has the following fields:
%   .keplerId ID of the apaerture
%   .referenceRow reference row of this aperture
%   .referenceCol reference column of this aperture
%   .maskIndex index into mask table for this aperture
%   in addition the following fields are for development
%   .originalAperture a copy of the original target aperture with this mask
%   assignment
%   .aperture the actual aperture used for mask selection, either
%   originalAperture or the halo aperture
%   .apertureNumPix number of pixels in the aperture
%   .status = 1 is mask was successfully assigned
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

if nargin == 0
    % if no inputs generate an error
    error('TAD:amaClass:EmptyInputStruct',...
        'The constructor must be called with an input structure.');
else
    % check for the presence of the field maskDefinitions
    if ~isfield(amaInputStruct, 'maskDefinitions')
        error('TAD:amaClass:missingField:maskDefinitions',...
            'maskDefinitions: field not present in the input structure.')
    end

    % check for the presence of the field maskDefinitions.offsets
    if ~isfield(amaInputStruct.maskDefinitions, 'offsets')
        error('TAD:amaClass:missingField:maskDefinitions:offsets',...
            'maskDefinitions.offsets: field not present in the input structure.')
    end    
    % check fields of amaInputStruct.maskDefinitions.offsets
    nfields = 1;
    fieldsAndBoundsStruct(nfields).fieldName = 'row';
    fieldsAndBoundsStruct(nfields).binaryCompare = ...
        {' > -1200 ', ' < 1200 '};
    nfields = nfields + 1;
    fieldsAndBoundsStruct(nfields).fieldName = 'column';
    fieldsAndBoundsStruct(nfields).binaryCompare = ...
        {' > -1200 ', ' < 1200 '};
    check_struct([amaInputStruct.maskDefinitions.offsets], ...
        fieldsAndBoundsStruct, 'TAD:amaClass:amaInputStruct:maskDefinitions:offsets');

    clear fieldsAndBoundsStruct;
    
    % check that the appropriate fields are all integer
    intTest = cell2mat(struct2cell([amaInputStruct.maskDefinitions.offsets]));
    if any(intTest(:) ~= fix(intTest(:)))
        error('TAD:amaClass:notInteger:maskDefinitions:offsets',...
            'offsets: not all integer')
    end

    % check for the presence of the field apertureStructs
    if ~isfield(amaInputStruct, 'apertureStructs')
        error('TAD:amaClass:missingField:apertureStructs',...
            'apertureStructs: field not present in the input structure.')
    end
    % check fields of amaInputStruct.apertureStructs
    nfields = 1;
    fieldsAndBoundsStruct(nfields).fieldName = 'keplerId';
    fieldsAndBoundsStruct(nfields).binaryCompare = ...
        {' >= 0 ', ' < 1e12 '};
    nfields = nfields + 1;
    fieldsAndBoundsStruct(nfields).fieldName = 'badPixelCount';
    fieldsAndBoundsStruct(nfields).binaryCompare = ...
        {' >= 0 ', ' < 1e6 '};
    nfields = nfields + 1;
    fieldsAndBoundsStruct(nfields).fieldName = 'referenceRow';
    fieldsAndBoundsStruct(nfields).binaryCompare = ...
        {' >= 0 ', ' < 1200 '};
    nfields = nfields + 1;
    fieldsAndBoundsStruct(nfields).fieldName = 'referenceColumn';
    fieldsAndBoundsStruct(nfields).binaryCompare = ...
        {' >= 0 ', ' < 1200 '};
    check_struct(amaInputStruct.apertureStructs, ...
        fieldsAndBoundsStruct, 'TAD:amaClass:amaInputStruct:apertureStructs');

    clear fieldsAndBoundsStruct;
    
    % check for the presence of the field apertureStructs.offsets
    if ~isfield([amaInputStruct.apertureStructs], 'offsets')
        error('TAD:amaClass:missingField:apertureStructs:offsets',...
            'apertureStructs.offsets: field not present in the input structure.')
    end    
    % check fields of amaInputStruct.apertureStructs.offsets
    nfields = 1;
    fieldsAndBoundsStruct(nfields).fieldName = 'row';
    fieldsAndBoundsStruct(nfields).binaryCompare = ...
        {' > -1200 ', ' < 1200 '};
    nfields = nfields + 1;
    fieldsAndBoundsStruct(nfields).fieldName = 'column';
    fieldsAndBoundsStruct(nfields).binaryCompare = ...
        {' > -1200 ', ' < 1200 '};
    check_struct([amaInputStruct.apertureStructs.offsets], ...
        fieldsAndBoundsStruct, 'TAD:amaClass:amaInputStruct:maskDefinitions:offsets');

    clear fieldsAndBoundsStruct;
    
    % check that the appropriate fields are all integer
    % in this case we are checking the above three fields, so we remove the
    % offsets field since that is of a different type
    % intTest = cell2mat(struct2cell(rmfield(amaInputStruct.apertureStructs, {'offsets', 'labels', 'custom', 'keplerId'})));
    % if any(intTest(:) ~= fix(intTest(:)))
    %     error('TAD:amaClass:notInteger:apertureStructs',...
    %         'apertureStructs: not all integer')
    % end

    % check that the appropriate fields are all integer
    intTest = cell2mat(struct2cell([amaInputStruct.apertureStructs.offsets]));
    if any(intTest(:) ~= fix(intTest(:)))
        error('TAD:amaClass:notInteger:apertureStructs:offsets',...
            'offsets: not all integer')
    end

    % now check the fields of fcConstants
    if(~isfield(amaInputStruct, 'fcConstants'))
        error('TAD:amaClass:missingField:fcConstants',...
            'fcConstants: field not present in the input structure.')
    end
        
%     % check for the presence of the field amaConfigurationStruct
%     if ~isfield(amaInputStruct, 'amaConfigurationStruct')
%         error('TAD:amaClass:missingField:amaConfigurationStruct',...
%             'amaConfigurationStruct: field not present in the input structure.')
%     end
%     check_struct(amaInputStruct.amaConfigurationStruct, ...
%         fieldsAndBoundsStruct, 'TAD:amaClass:amaConfigurationStruct');

    nfields = 1;
    fieldsAndBoundsStruct(nfields).fieldName = 'debugFlag';
    fieldsAndBoundsStruct(nfields).binaryCompare = [];
    check_struct(amaInputStruct, ...
        fieldsAndBoundsStruct, 'TAD:amaClass:amaInputStruct');

    % check that the appropriate fields are all integer
    if amaInputStruct.debugFlag ~= fix(amaInputStruct.debugFlag)
        error('TAD:amaInputStruct:notInteger:amaInputStruct',...
            'debugFlag: not all integer')
    end

    
    % add other fields that are computed later
    amaInputStruct.targetDefinitions = [];
    amaInputStruct.targetDefData = [];
    amaInputStruct.usedMasks = false(1024, 1);
    amaInputStruct.numDedicatedMasks = 0;
end

if ~isfield(amaInputStruct, 'maskTableParametersStruct')
    amaInputStruct.maskTableParametersStruct = [];
end
% make the amaClass object
amaObject = class(amaInputStruct, 'amaClass');

