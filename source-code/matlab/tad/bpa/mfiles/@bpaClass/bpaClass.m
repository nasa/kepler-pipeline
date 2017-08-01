function bpaObject = bpaClass(bpaInputStruct)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function bpaObject = bpaClass(bpaInputStruct)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% 
% background pixel apertures first lays down a grid of initial positions on
% the module output.  This grid is stretched to have a higher density near
% the edges of the output.  The grid nodes are used as initial positions
% for background apertures, which are then moved slightly to appropriate
% background pixels.
%
% bpaInputStruct is a structure with the following fields:
%   .bpaConfigurationStruct structure with various control parameters with
%       the following fields:
%       .nLinesRow the number of lines in the row direction in the initial grid
%       .nLinesCol the number of lines in the column direction in the initial grid
%       .nEdge the number of lines to have in the stretched regions
%       .edgeFraction fraction of the grid that should be higher density
%       .lineStartRow row for the first line of the grid
%       .lineEndRow row for the last line of the grid
%       .lineStartCol column for the first line of the grid
%       .lineEndCol column for the first line of the grid
%       .histBinSize size of histogram bins used to find dominant
%           background mode
%   .moduleOutputImage 2D array containing the image on the module output
%       CCD produced by COA
%   .moduleDescriptionStruct - struct with the following fields
%       .nRowPix # of visible rows in the synthetic image we are generating
%       .nColPix # of visible columns in the synthetic image we are generating
%       .leadingBlack # of leading black pixels
%       .trailingBlack # of trailing black pixels
%       .virtualSmear # of virtual smear pixels
%       .maskedSmear # of masked smear pixels
%
% on completion the struct array targetDefinition is added to bpaObject,
% which has the following fields:
%   .keplerId ID of the background aperture
%   .referenceRow reference row of this aperture
%   .referenceColumn reference column of this aperture
%   .maskIndex index into mask table for this aperture
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
    error('TAD:bpaClass:EmptyInputStruct',...
        'The constructor must be called with an input structure.');
else
    % check the fields of bpaConfigurationStruct
    if(~isfield(bpaInputStruct, 'bpaConfigurationStruct'))
        error('TAD:bpaClass:missingField:bpaConfigurationStruct',...
            'bpaConfigurationStruct: field not present in the input structure.')
    end
    
    nfields = 1;
    fieldsAndBoundsStruct(nfields).fieldName = 'nLinesRow';
    fieldsAndBoundsStruct(nfields).binaryCompare = ...
        {' > 0 ', ' <= 1100 '};
    nfields = nfields + 1;
    fieldsAndBoundsStruct(nfields).fieldName = 'nLinesCol';
    fieldsAndBoundsStruct(nfields).binaryCompare = ...
        {' > 0 ', ' <= 1100 '};
    nfields = nfields + 1;
    fieldsAndBoundsStruct(nfields).fieldName = 'nEdge';
    fieldsAndBoundsStruct(nfields).binaryCompare = ...
        {' >= 0 ', ' <= 1000 '};
    nfields = nfields + 1;
    fieldsAndBoundsStruct(nfields).fieldName = 'edgeFraction';
    fieldsAndBoundsStruct(nfields).binaryCompare = ...
        {' >= 0 ', ' <= 0.5 '};
    nfields = nfields + 1;
    fieldsAndBoundsStruct(nfields).fieldName = 'lineStartRow';
    fieldsAndBoundsStruct(nfields).binaryCompare = ...
        {' > 0 ', ' <= 1200 '};
    nfields = nfields + 1;
    fieldsAndBoundsStruct(nfields).fieldName = 'lineEndRow';
    fieldsAndBoundsStruct(nfields).binaryCompare = ...
        {' > 0 ', ' <= 1200 '};
    nfields = nfields + 1;
    fieldsAndBoundsStruct(nfields).fieldName = 'lineStartCol';
    fieldsAndBoundsStruct(nfields).binaryCompare = ...
        {' > 0 ', ' <= 1200 '};
    nfields = nfields + 1;
    fieldsAndBoundsStruct(nfields).fieldName = 'lineEndCol';
    fieldsAndBoundsStruct(nfields).binaryCompare = ...
        {' > 0 ', ' <= 1200 '};
    nfields = nfields + 1;
    fieldsAndBoundsStruct(nfields).fieldName = 'histBinSize';
    fieldsAndBoundsStruct(nfields).binaryCompare = ...
        {' > 1 ', ' <= 1e6 '};
    check_struct(bpaInputStruct.bpaConfigurationStruct, fieldsAndBoundsStruct, ...
        'TAD:bpaClass');

    clear fieldsAndBoundsStruct;

    % check that the appropriate fields are all integer
    % remove the field edgeFraction since it is a float
    intTest = cell2mat(struct2cell(rmfield(bpaInputStruct.bpaConfigurationStruct, 'edgeFraction')));
    if any(intTest(:) ~= fix(intTest(:)))
        error('TAD:bpaClass:notInteger:bpaConfigurationStruct',...
            'bpaConfigurationStruct: not all integer')
    end

    % now check the fields of moduleDescriptionStruct
    if(~isfield(bpaInputStruct, 'moduleDescriptionStruct'))
        error('TAD:bpaClass:missingField:moduleDescriptionStruct',...
            'moduleDescriptionStruct: field not present in the input structure.')
    end
    
    nfields = 1;
    fieldsAndBoundsStruct(nfields).fieldName = 'nRowPix';
    fieldsAndBoundsStruct(nfields).binaryCompare = ...
        {' >= 1000 ', ' <= 2000 '};
    nfields = nfields + 1;
    fieldsAndBoundsStruct(nfields).fieldName = 'nColPix';
    fieldsAndBoundsStruct(nfields).binaryCompare = ...
        {' >= 1000 ', ' <= 2000 '};
    nfields = nfields + 1;
    fieldsAndBoundsStruct(nfields).fieldName = 'leadingBlack';
    fieldsAndBoundsStruct(nfields).binaryCompare = ...
        {' >= 0 ', ' <= 100 '};
    nfields = nfields + 1;
    fieldsAndBoundsStruct(nfields).fieldName = 'trailingBlack';
    fieldsAndBoundsStruct(nfields).binaryCompare = ...
        {' >= 0 ', ' <= 100 '};
    nfields = nfields + 1;
    fieldsAndBoundsStruct(nfields).fieldName = 'virtualSmear';
    fieldsAndBoundsStruct(nfields).binaryCompare = ...
        {' >= 0 ', ' <= 100 '};
    nfields = nfields + 1;
    fieldsAndBoundsStruct(nfields).fieldName = 'maskedSmear';
    fieldsAndBoundsStruct(nfields).binaryCompare = ...
        {' >= 0 ', ' <= 100 '};
     check_struct(bpaInputStruct.moduleDescriptionStruct, ...
        fieldsAndBoundsStruct, 'TAD:bpaClass:moduleDescriptionStruct');

    clear fieldsAndBoundsStruct;

    % check that the appropriate fields are all integer
    intTest = cell2mat(struct2cell(bpaInputStruct.moduleDescriptionStruct));
    if any(intTest ~= fix(intTest))
        error('TAD:bpaClass:notInteger:moduleDescriptionStruct',...
            'moduleDescriptionStruct: not all integer')
    end

    % check the fields in bpaInputStruct
    nfields = 1;
    fieldsAndBoundsStruct(nfields).fieldName = 'debugFlag';
    fieldsAndBoundsStruct(nfields).binaryCompare = [];
    check_struct(bpaInputStruct, fieldsAndBoundsStruct, ...
        'TAD:bpaClass');
    
    % check that the appropriate fields are all integer
    if bpaInputStruct.debugFlag ~= fix(bpaInputStruct.debugFlag)
        error('TAD:bpaClass:notInteger:bpaInputStruct',...
            'debugFlag: not all integer')
    end

    % do a special case for the 2d moduleOutputImage
    if ~isfield(bpaInputStruct, 'moduleOutputImage')
        error('TAD:bpaClass:missingField:moduleOutputImage',...
            'moduleOutputImage: field not present in the input structure.')
    end
    % test to make sure is non-negative
    if ~all(all(bpaInputStruct.moduleOutputImage >= 0))
        error('bpaClass:rangeCheck:moduleOutputImage', ...
            'moduleOutputImage: not all non-negative.');
    end
    % test to make sure is not too large
    if ~all(all(bpaInputStruct.moduleOutputImage < 1e10))
        error('bpaClass:rangeCheck:moduleOutputImage', ...
            'moduleOutputImage: not all < 1e10.');
    end
    % test to make sure is not nan
    if any(any(~isfinite(bpaInputStruct.moduleOutputImage)))
        error('bpaClass:rangeCheck:moduleOutputImage', ...
            'moduleOutputImage: found inf or NaN.');
    end
    
    % do a special case to make sure the edge parameters make sense
    if (bpaInputStruct.bpaConfigurationStruct.nEdge > ...
            bpaInputStruct.bpaConfigurationStruct.nLinesRow/2)
        error('bpaClass:rangeCheck:edgeFraction', ...
            'moduleOutputImage: nEdge > nLinesRow/2.');
    end
    if (bpaInputStruct.bpaConfigurationStruct.nEdge > ...
            bpaInputStruct.bpaConfigurationStruct.nLinesCol/2)
        error('bpaClass:rangeCheck:edgeFraction', ...
            'moduleOutputImage: nEdge > nLinesCol/2.');
    end
end

% create fields filled in later
bpaInputStruct.targetDefinition = repmat( ...
    struct('keplerId', 0, 'excessPixels', 0, 'referenceRow', 0, ...
    'referenceColumn', 0, 'maskIndex', 0), ...
    1, bpaInputStruct.bpaConfigurationStruct.nLinesRow*bpaInputStruct.bpaConfigurationStruct.nLinesCol);
bpaInputStruct.maskDefinitions = [];

% make the bpaClass object
bpaObject = class(bpaInputStruct, 'bpaClass');

