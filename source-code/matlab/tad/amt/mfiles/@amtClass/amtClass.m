function amtObject = amtClass(amtInputStruct)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function amtObject = amtClass(amtInputStruct)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Returns the amtObject of type amtClass containing the following fields:
% Fields set from fields of amtInputStruct:
%   .maskDefinitions input table of mask definitions.  May be empty, in which 
%       a new mask definition array is created.  If this input is not empty
%       it is returned unmodified in amtResultStruct.maskDefinitions.
%   .apertureStructs struct containing optimal apertures.  This field 
%       is required but may be empty.  Currently
%       ignored, this is a hook for possible future use in the generation
%       of the aperture mask table.
%   .amtConfigurationStruct a structure with the following fields:
%       .maxMasks the maximum number of masks in the table
%       .maxPixelsInMask the maximum number of pixels allowed in any mask
%       .maxMaskRows the maximum number of rows in a round/elliptical mask
%       .maxMaskCols the maximum number of columns in a round/elliptical mask
%       .centerRow the center pixel row in a round/elliptical mask
%       .centerCol the center pixel column in a round/elliptical mask
%       .minEccentricity minimum eccentricity in an elliptical mask
%       .maxEccentricity maximum eccentricity in an elliptical mask
%       .stepEccentricity eccentricity increment in an elliptical mask
%   .debugFlag boolean to control debugging display
%
%   When it is filled in, the resulting structure is MaskTableStruct, which
%   contains the following fields:
%   .defined boolean indicating if the mask was defined
%   .mask image of the mask in an 85 x 85 array
%   .nPix # of non-zero pixels in the mask
%   .center center of the non-zero pixels in the mask
%   .size size of the non-zero pixels in the mask
%   .boundingBox bounding of the non-zero pixels in the mask
%   .targetDefinitionStruct structure providing the aperture definition
%   containing the following fields:
%       .offsets array of structures, one for each pixel, containing the fields
%           .row row offset of this pixel
%           .column row offset of this pixel
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
    error('TAD:amtClass:EmptyInputStruct',...
        'The constructor must be called with an input structure.');
else
    % check for the presence of the field maskDefinitions
    if ~isfield(amtInputStruct, 'maskDefinitions')
        error('TAD:amtClass:missingField:maskDefinitions',...
            'maskDefinitions: field not present in the input structure.')
    end
    % if the optional input table is not empty
    if ~isempty(amtInputStruct.maskDefinitions)
        % check fields of amtInputStruct.maskDefinitions.offsets
        nfields = 1;
        fieldsAndBoundsStruct(nfields).fieldName = 'row';
        fieldsAndBoundsStruct(nfields).binaryCompare = ...
            {' > -1200 ', ' < 1200 '};
        nfields = nfields + 1;
        fieldsAndBoundsStruct(nfields).fieldName = 'column';
        fieldsAndBoundsStruct(nfields).binaryCompare = ...
            {' > -1200 ', ' < 1200 '};
        check_struct([amtInputStruct.maskDefinitions.offsets], ...
            fieldsAndBoundsStruct, 'TAD:amtClass:amtInputStruct:maskDefinitions:offsets');

        clear fieldsAndBoundsStruct;

        % check that the appropriate fields are all integer
        intTest = cell2mat(struct2cell([amtInputStruct.maskDefinitions.offsets]));
        if any(intTest(:) ~= fix(intTest(:)))
            error('TAD:amtClass:notInteger:maskDefinitions:offsets',...
                'offsets: not all integer')
        end
    end


    % check for the presence of the field apertureStructs
    if ~isfield(amtInputStruct, 'apertureStructs')
        error('TAD:amtClass:missingField:apertureStructs',...
            'apertureStructs: field not present in the input structure.')
    end
    if ~isempty(amtInputStruct.apertureStructs)
        % check fields of amtInputStruct.apertureStructs
        nfields = 1;
        fieldsAndBoundsStruct(nfields).fieldName = 'keplerId';
        fieldsAndBoundsStruct(nfields).binaryCompare = ...
            {' >= 0 ', ' < 1e9 '};
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
        check_struct(amtInputStruct.apertureStructs, ...
            fieldsAndBoundsStruct, 'TAD:amtClass:amtInputStruct:apertureStructs');

        clear fieldsAndBoundsStruct;

        % check for the presence of the field apertureStructs.offsets
        if ~isfield([amtInputStruct.apertureStructs], 'offsets')
            error('TAD:amtClass:missingField:apertureStructs:offsets',...
                'apertureStructs.offsets: field not present in the input structure.')
        end    
        % check fields of amtInputStruct.apertureStructs.offsets
        nfields = 1;
        fieldsAndBoundsStruct(nfields).fieldName = 'row';
        fieldsAndBoundsStruct(nfields).binaryCompare = ...
            {' > -1200 ', ' < 1200 '};
        nfields = nfields + 1;
        fieldsAndBoundsStruct(nfields).fieldName = 'column';
        fieldsAndBoundsStruct(nfields).binaryCompare = ...
            {' > -1200 ', ' < 1200 '};
        check_struct([amtInputStruct.apertureStructs.offsets], ...
            fieldsAndBoundsStruct, 'TAD:amtClass:amtInputStruct:apertureStructs:offsets');

        clear fieldsAndBoundsStruct;

        % check that the appropriate fields are all integer
        % in this case we are checking the above three fields, so we remove the
        % offsets field since that is of a different type
%         intTest = cell2mat(struct2cell(rmfield(amtInputStruct.apertureStructs, ...
% 			{'offsets', 'labels'})));
%         if any(intTest(:) ~= fix(intTest(:)))
%             error('TAD:amtClass:notInteger:apertureStructs',...
%                 'apertureStructs: not all integer')
%         end

        % check that the appropriate fields are all integer
        intTest = cell2mat(struct2cell([amtInputStruct.apertureStructs.offsets]));
        if any(intTest(:) ~= fix(intTest(:)))
            error('TAD:amtClass:notInteger:apertureStructs:offsets',...
                'offsets: not all integer')
        end
    end

    % now check the fields of amtConfigurationStruct
    if(~isfield(amtInputStruct, 'amtConfigurationStruct'))
        error('TAD:amtClass:missingField:amtConfigurationStruct',...
            'amtConfigurationStruct: field not present in the input structure.')
    end
    
    nfields = 1;
    fieldsAndBoundsStruct(nfields).fieldName = 'maxPixelsInMask';
    fieldsAndBoundsStruct(nfields).binaryCompare = ...
        {' > 0 ', ' < 1e6 '};
    nfields = nfields + 1;
    fieldsAndBoundsStruct(nfields).fieldName = 'maxMaskRows';
    fieldsAndBoundsStruct(nfields).binaryCompare = ...
        {' > 0 ', ' < 2000 '};
    nfields = nfields + 1;
    fieldsAndBoundsStruct(nfields).fieldName = 'maxMaskCols';
    fieldsAndBoundsStruct(nfields).binaryCompare = ...
        {' > 0 ', ' < 2000 '};
    nfields = nfields + 1;
    fieldsAndBoundsStruct(nfields).fieldName = 'centerRow';
    fieldsAndBoundsStruct(nfields).binaryCompare = ...
        {' > 0 ', ' < 2000 '};
    nfields = nfields + 1;
    fieldsAndBoundsStruct(nfields).fieldName = 'centerCol';
    fieldsAndBoundsStruct(nfields).binaryCompare = ...
        {' > 0 ', ' < 2000 '};
    nfields = nfields + 1;
    fieldsAndBoundsStruct(nfields).fieldName = 'minEccentricity';
    fieldsAndBoundsStruct(nfields).binaryCompare = ...
        {' >= 0 ', ' <= 1 '};
    nfields = nfields + 1;
    fieldsAndBoundsStruct(nfields).fieldName = 'maxEccentricity';
    fieldsAndBoundsStruct(nfields).binaryCompare = ...
        {' >= 0 ', ' <= 1 '};
    nfields = nfields + 1;
    fieldsAndBoundsStruct(nfields).fieldName = 'stepEccentricity';
    fieldsAndBoundsStruct(nfields).binaryCompare = ...
        {' >= 0 ', ' <= 1 '};
    nfields = nfields + 1;
    fieldsAndBoundsStruct(nfields).fieldName = 'stepInclination';
    fieldsAndBoundsStruct(nfields).binaryCompare = ...
        {' >= 0 ', ' <= 2*pi '};
    nfields = nfields + 1;
    fieldsAndBoundsStruct(nfields).fieldName = 'maxPixelsInSmallMask';
    fieldsAndBoundsStruct(nfields).binaryCompare = ...
        {' >= 0 ', ' <= 600 '};
    check_struct(amtInputStruct.amtConfigurationStruct, ...
        fieldsAndBoundsStruct, 'TAD:amtClass:amtConfigurationStruct');

    clear fieldsAndBoundsStruct;
    
    % check that the appropriate fields are all integer
    intTest = amtInputStruct.amtConfigurationStruct.maxPixelsInMask;
    if any(intTest ~= fix(intTest))
        error('TAD:amtClass:notInteger:amtInputStruct',...
            'maxPixelsInMask: not all integer')
    end
    intTest = amtInputStruct.amtConfigurationStruct.maxMaskRows;
    if any(intTest ~= fix(intTest))
        error('TAD:amtClass:notInteger:amtInputStruct',...
            'maxMaskRows: not all integer')
    end
    intTest = amtInputStruct.amtConfigurationStruct.maxMaskCols;
    if any(intTest ~= fix(intTest))
        error('TAD:amtClass:notInteger:amtInputStruct',...
            'maxMaskCols: not all integer')
    end
    intTest = amtInputStruct.amtConfigurationStruct.centerRow;
    if any(intTest ~= fix(intTest))
        error('TAD:amtClass:notInteger:amtInputStruct',...
            'centerRow: not all integer')
    end
    intTest = amtInputStruct.amtConfigurationStruct.centerCol;
    if any(intTest ~= fix(intTest))
        error('TAD:amtClass:notInteger:amtInputStruct',...
            'centerCol: not all integer')
    end
    intTest = amtInputStruct.amtConfigurationStruct.maxPixelsInSmallMask;
    if any(intTest ~= fix(intTest))
        error('TAD:amtClass:notInteger:amtInputStruct',...
            'maxPixelsInSmallMask: not all integer')
    end
   
    % check the fields in amtInputStruct
    nfields = 1;
    fieldsAndBoundsStruct(nfields).fieldName = 'debugFlag';
    fieldsAndBoundsStruct(nfields).binaryCompare = [];
    check_struct(amtInputStruct, fieldsAndBoundsStruct, ...
        'TAD:amtClass');

    clear fieldsAndBoundsStruct;
    
    % add other fields that are computed later
    amtInputStruct.MaskTableStruct = [];
    amtInputStruct.maskDefinitions = [];
end

% make the amtClass object
amtObject = class(amtInputStruct, 'amtClass');

