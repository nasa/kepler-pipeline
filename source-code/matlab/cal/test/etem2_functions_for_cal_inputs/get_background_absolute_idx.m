function  [absoluteIdxPerBkgdPixelStruct, absoluteIdxPerBkgdTargetDefStruct] = ...
    get_background_absolute_idx(pixels, targetDefinitionStruct, maskDefinitionTableStruct)
%function  [absoluteIdxPerBkgdPixelStruct, absoluteIdxPerBkgdTargetDefStruct] = ...
%    get_background_absolute_idx(pixels, targetDefinitionStruct, maskDefinitionTableStruct)
%
%
%
% NOTE: this function is updated to reflect the same fields as CALs input
% struct requires, and adds a gap indicator field   (8/13)
%
% function to convert ETEM2 output for background pixel target/mask definitions 
% into (1) per pixel structs (used in CAL) and/or (2) per target definition
% structs (used in PA).  
%
% After running ETEM2, run extract_pixel_time_series_from_one_etem2_run
% to extract the following inputs:
%
% INPUTS
%
% pixels                       nCadences x nBkgdPix array   (for all background pixels)
%
% targetDefinitionStruct       backgroundTargetDefinitionStruct =
%                                   1xnBkgdPix struct array with fields:
%                                     referenceRow          (in 0 - based indexing!!!!)
%                                     referenceColumn       (in 0 - based indexing!!!!)
%                                     maskIndex             (in 1 - based indexing!!!!)  
%
% maskDefinitionTableStruct    backgroundMaskDefinitionTableStruct =   % each mask def has 4 pixels!
%                                  1x1024 struct array with fields:
%                                    offsets, with row and column fields
%
%
%
% Note: This function is called if 'background' is input pixel type in the
% following function:
%
% [absoluteIdxPerBkgdPixelStruct, absoluteIdxPerBkgdTargetDefStruct] = ...
%     get_absolute_pix_indices_from_etem2output(backgroundPixels, backgroundTargetDefinitionStruct,...
%     backgroundMaskDefinitionTableStruct, 'background')
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


nBkgdTargetDefs = length(targetDefinitionStruct);

nPixelsInBkgdTargetDef = length([maskDefinitionTableStruct.offsets]); % = 4

%nBkgdPixels = nBkgdTargetDefs .* nPixelsInBkgdTargetDef;   % = length(pixels(1, :));

nCadences = length(pixels(:, 1));


absoluteIdxPerBkgdTargetDefStruct = repmat(struct('fluxArrayOfAllPixInBkgdTargetDef', [], ...
    'absoluteRowIndices', [], 'absoluteColumnIndices', []), nBkgdTargetDefs, 1);

% save individual background pixel flux time series & absolute row/cols
absoluteIdxPerPixelArrayOfStructs =  repmat(struct('absoluteIdxPerPixInBkgdTargetStruct', []), nBkgdTargetDefs, 1);


for i = 1:nBkgdTargetDefs

    % input pixels is an (nCadences x nBkgdPixels) array, need to separate 
    % array into (nCadences x 4) flux arrays per background target definition 

    fluxArrayOfAllPixInBkgdTargetDef = pixels(:, (i + 3*(i-1)):(i + 3*i));  % nCad x 4

    % get center pixel reference row and column
    centerRow = targetDefinitionStruct(i).referenceRow + 1;
    centerColumn = targetDefinitionStruct(i).referenceColumn + 1;

    maskIndex = targetDefinitionStruct(i).maskIndex;

    maskTable = maskDefinitionTableStruct;

    if (maskIndex ~= 0)
        % get the offsets from the existing mask table
        rowOffsets = [maskTable(maskIndex).offsets.row];
        columnOffsets = [maskTable(maskIndex).offsets.column];

        absoluteRowIndices = centerRow + rowOffsets;
        absoluteColumnIndices = centerColumn + columnOffsets;

    else
        error('Mask index for background set (4) of pixels is zero');
    end

    %rowColArray = [absoluteRowIndices' absoluteColumnIndices'];


    %----------------------------------------------------------------------
    % pixels input into CAL are packaged within an array of structs, where
    % each struct consists of a pixel time series vector, logical gap indicators,
    % and a scalar row and column

    % preallocate memory:
    pixelFluxTimeSeries = zeros(1, nCadences);
    gapIndicatorTimeSeries = false(1, nCadences);    
    absoluteRowIndex = 0;       % scalar
    absoluteColumnIndex = 0;    % scalar

    absoluteIdxPerPixInBkgdTargetStruct  = repmat(struct('values', pixelFluxTimeSeries, ...
        'row', absoluteRowIndex, 'column', absoluteColumnIndex, 'gapIndicators', gapIndicatorTimeSeries), nPixelsInBkgdTargetDef, 1);

    for j = 1:nPixelsInBkgdTargetDef  % 1:4

        % pixel values are listed in order as above
        pixelFluxTimeSeries  = fluxArrayOfAllPixInBkgdTargetDef(:, j); % nCad x 1

        absoluteRowIndex = absoluteRowIndices(j);
        absoluteColumnIndex = absoluteColumnIndices(j);

        % save pixel flux time series, and absolute row/col to per-pixel struct
        absoluteIdxPerPixInBkgdTargetStruct(j).values = pixelFluxTimeSeries;
        absoluteIdxPerPixInBkgdTargetStruct(j).row = absoluteRowIndex;
        absoluteIdxPerPixInBkgdTargetStruct(j).column = absoluteColumnIndex;
        
        absoluteIdxPerPixInBkgdTargetStruct(j).gapIndicators = gapIndicatorTimeSeries(:);        
    end

    %----------------------------------------------------------------------
    % save pixel values, rows, and cols to per-target struct
    %----------------------------------------------------------------------
    absoluteIdxPerBkgdTargetDefStruct(i).fluxArrayOfAllPixInBkgdTargetDef = fluxArrayOfAllPixInBkgdTargetDef;
    absoluteIdxPerBkgdTargetDefStruct(i).absoluteRowIndices = absoluteRowIndices(:);
    absoluteIdxPerBkgdTargetDefStruct(i).absoluteColumnIndices = absoluteColumnIndices(:);

    %----------------------------------------------------------------------
    % save pixel flux time series, and absolute row/col to per-pixel struct
    % for all bkgd targets, concatenate after loop to save in one array
    %----------------------------------------------------------------------

    absoluteIdxPerPixelArrayOfStructs(i).absoluteIdxPerPixInBkgdTargetStruct = absoluteIdxPerPixInBkgdTargetStruct;

end

% save pixel time series in format as passed into CAL:
absoluteIdxPerBkgdPixelStruct = cat(1, absoluteIdxPerPixelArrayOfStructs.absoluteIdxPerPixInBkgdTargetStruct);

%save background_pixel_absolute_idx.mat  absoluteIdxPerBkgdPixelStruct absoluteIdxPerBkgdTargetDefStruct

return;
