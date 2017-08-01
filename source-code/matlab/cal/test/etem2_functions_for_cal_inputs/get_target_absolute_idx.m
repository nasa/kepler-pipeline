function [absoluteIdxPerPixelStruct, absoluteIdxPerTargetDefStruct] = ...
    get_target_absolute_idx(pixels, targetDefinitionStruct, maskDefinitionTableStruct)
%function [absoluteIdxPerPixelStruct, absoluteIdxPerTargetDefStruct] = ...
%    get_target_absolute_idx(pixels, targetDefinitionStruct, maskDefinitionTableStruct)
%
%
% NOTE: this function is updated to reflect the same fields as CALs input
% struct requires, and adds a gap indicator field   (8/13)
%
%
% function to convert ETEM2 output for stellar target/mask definitions
% into (1) per pixel structs (used in CAL) and/or (2) per target definition
% structs (used in PA).
%
% After running ETEM2, run extract_pixel_time_series_from_one_etem2_run
% to extract the following inputs:
%
% INPUTS
%
% pixels                    targetPixels:
%                               1 x nTargets struct array with fields:
%                                   pixelValues
%                                   referenceRow
%                                   referenceColumn
%                                   maskIndex
%
%                           ex: targetPixels(1)
%                               pixelValues: [1392x28 double]       an nCadences x nPixels array
%                               referenceRow: 1025
%                               referenceColumn: 1041
%                               maskIndex: 469
%
% targetDefinitionStruct    targetDefinitionStruct =   %this information is captured in targetPixels struct
%                               1xnTargets struct array with fields:
%                                   referenceRow        (in 0 - based indexing!!!!)
%                                   referenceColumn     (in 0 - based indexing!!!!)
%                                   maskIndex           (in 1 - based indexing!!!!)
%
% maskDefinitionTableStruct   targetMaskDefinitionTableStruct =
%                               1 x 1024 struct array with fields:
%                               offsets, with row and column fields
%
%
% Note: This function will be called if 'target' is input pixel type in the
% following function:
%
% [absoluteIdxPerPixelStruct, absoluteIdxPerTargetDefStruct] = ...
%     get_absolute_pix_indices_from_etem2output(targetPixels, targetDefinitionStruct,...
%     targetMaskDefinitionTableStruct, 'target')
%
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


nTargets = length(pixels);

absoluteIdxPerTargetDefStruct = repmat(struct('fluxArrayOfAllPixInTarget', [], ...
    'absoluteRowIndices', [], 'absoluteColumnIndices', []), nTargets, 1);

% save individual target pixels flux time series & absolute row/cols
absoluteIdxPerPixelArrayOfStructs =  repmat(struct('absoluteIdxPerPixInTargetStruct', []), nTargets, 1);

for i = 1:nTargets

    % pixel flux (nPixInTarget x nCadences) array
    fluxArrayOfAllPixInTarget = pixels(i).pixelValues';

    nPixelsInTarget = length(fluxArrayOfAllPixInTarget(:, 1));
    nCadences = length(fluxArrayOfAllPixInTarget(1, :));

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
        error('Mask index for stellar target is zero');
    end

    %rowColArray = [absoluteRowIndices' absoluteColumnIndices'];

    %----------------------------------------------------------------------
    % pixels input into CAL are packaged within an array of structs, where
    % each struct consists of a pixel time series vector, logical gap indicators,
    % and a scalar row and column

    % preallocate memory
    pixelFluxTimeSeries = zeros(1, nCadences);
    gapIndicatorTimeSeries = false(1, nCadences);
    absoluteRowIndex = 0;       % scalar
    absoluteColumnIndex = 0;    % scalar

    absoluteIdxPerPixInTargetStruct  = repmat(struct('values', pixelFluxTimeSeries, ...
        'row', absoluteRowIndex, 'column', absoluteColumnIndex, 'gapIndicators', gapIndicatorTimeSeries), nPixelsInTarget, 1);

    for j = 1:nPixelsInTarget

        % pixel values are listed in order as above
        pixelFluxTimeSeries  = fluxArrayOfAllPixInTarget(j, :);

        absoluteRowIndex = absoluteRowIndices(j);
        absoluteColumnIndex = absoluteColumnIndices(j);

        % save pixel flux time series, and absolute row/col to per-pixel struct
        absoluteIdxPerPixInTargetStruct(j).values = pixelFluxTimeSeries(:);
        absoluteIdxPerPixInTargetStruct(j).row = absoluteRowIndex;
        absoluteIdxPerPixInTargetStruct(j).column = absoluteColumnIndex;

        absoluteIdxPerPixInTargetStruct(j).gapIndicators = gapIndicatorTimeSeries(:);


    end

    %----------------------------------------------------------------------
    % save pixel values, rows, and cols to per-target struct
    %----------------------------------------------------------------------
    absoluteIdxPerTargetDefStruct(i).fluxArrayOfAllPixInTarget = fluxArrayOfAllPixInTarget;
    absoluteIdxPerTargetDefStruct(i).absoluteRowIndices = absoluteRowIndices(:);
    absoluteIdxPerTargetDefStruct(i).absoluteColumnIndices = absoluteColumnIndices(:);

    %----------------------------------------------------------------------
    % save pixel flux time series, and absolute row/col to per-pixel struct
    % for all targets, concatenate after loop to save in one array
    %----------------------------------------------------------------------
    absoluteIdxPerPixelArrayOfStructs(i).absoluteIdxPerPixInTargetStruct = absoluteIdxPerPixInTargetStruct;
end

% save pixel time series in one array
absoluteIdxPerPixelStruct = cat(1, absoluteIdxPerPixelArrayOfStructs.absoluteIdxPerPixInTargetStruct);


%save target_pixels_absolute_idx.mat absoluteIdxPerPixelStruct absoluteIdxPerTargetDefStruct

return;
