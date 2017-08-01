function [stellarTargetDefinitions, stellarIndices] = get_stellar_target_definitions(rptsObject)
% function  [stellarTargetDefinitions, stellarIndices] = get_stellar_target_definitions(rptsObject)
%
% function to create target definitions for each of the input stellar apertures.
% Target definitions are constructed by calling TAD/AMA, and the rows and columns
% of the pixels in each target definition are recorded for the collection of
% smear/black pixels.  Input aperture pixels and output target definition pixels
% are validated to ensure they are on the photometric CCD.
%
% INPUT
%   rptsObject:    the relevant fields extracted from the object for this function are:
%
%   rptsModuleParametersStruct:   [struct array] consisting of the following field used herein:
%                   nHaloRings:   number of halo rings to add to optimal aperture
%
%             stellarApertures:   [struct array] consisting of the following fields:
%                     keplerId:   target star KIC id number
%                 referenceRow:   reference row on the module output for this aperture
%              referenceColumn:   reference column on the module output for this aperture
%                      offsets:   [struct array] consisting of the fields 'row' and 'column'
%                badPixelCount:   indices of bad pixels
%
%                existingMasks:   [struct array] existing mask table consisting of the following field:
%                      offsets:   [struct array] consisting of the fields 'row' and 'column'
%
% OUTPUT
%     stellarTargetDefinitions:   [struct array] consisting of the following fields:
%               keplerId: [struct array]    target star KIC id number
%           referenceRow: [struct array]    reference row on the module output for this target definition
%        referenceColumn: [struct array]    reference column on the module output for this target definition
%              maskIndex: [struct array]    index into existingMasks table for this target definition
%           excessPixels: [struct array]    number of pixels in the assigned mask that are not in the requested aperture
%                 status: [struct array]    status indicating successful mask assignment:
%                                              status = -1: no mask assigned
%                                              status =  1: mask assigned, no problems
%                                              status = -2: mask assigned but has pixels off the CCD
%
%               stellarIndices:  [struct array] the same length as stellarTargetDefinitions, with the following fields:
%                  stellarRows:  a list of row indices that contain stellar target pixels, to be used to collect black
%               stellarColumns:  a list of column indices that contain stellar target pixels, to be used to collect smear
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


debugFlag = rptsObject.debugFlag;

close all;

ccdModule = rptsObject.module;
ccdOutput = rptsObject.output;
currentModOut = convert_from_module_output(ccdModule, ccdOutput);

% extract relevant fields from rptsObject
rptsModuleParametersStruct  = rptsObject.rptsModuleParametersStruct;
nHaloRings                  = rptsModuleParametersStruct.nHaloRings;

stellarApertures            = rptsObject.stellarApertures;
existingMasks               = rptsObject.existingMasks;

% extract module output image, which contains smear
moduleOutputImage = rptsObject.moduleOutputImage;

% convert output image from arrays of structures to 2D array
moduleOutputImage = struct_to_array2D(moduleOutputImage);


% extract focal plane constants
fcConstants = rptsObject.fcConstants;

nRowsImaging    = fcConstants.nRowsImaging;    % 1024
nColsImaging    = fcConstants.nColsImaging;    % 1100
nLeadingBlack   = fcConstants.nLeadingBlack;   % 12
%nTrailingBlack  = fcConstants.nTrailingBlack; % 20
%nVirtualSmear   = fcConstants.nVirtualSmear;  % 26
nMaskedSmear    = fcConstants.nMaskedSmear;    % 20
numCcdRows      = fcConstants.CCD_ROWS;        % 1070
numCcdColumns   = fcConstants.CCD_COLUMNS;     % 1132

%--------------------------------------------------------------------------
% validate inputs: check to ensure that stellar aperture reference
% rows/columns are on the photometric CCD
%--------------------------------------------------------------------------
apertureCenterRows      = [stellarApertures.referenceRow];
apertureCenterColumns   = [stellarApertures.referenceColumn];

validRows    = find((apertureCenterRows(:) > nMaskedSmear) & ...
    (apertureCenterRows(:) <= (nMaskedSmear + nRowsImaging)));

validColumns = find((apertureCenterColumns(:) > nLeadingBlack) & ...
    (apertureCenterColumns(:) <= (nLeadingBlack + nColsImaging)));

if ((length(validRows) < length(apertureCenterRows)) || (length(validColumns) < length(apertureCenterColumns)))
    error('RPTS:get_stellar_target_definitions: Input stellar aperture reference row and/or column is off the photometric CCD');
end

%--------------------------------------------------------------------------
% validate inputs: check to ensure all stellar aperture pixels are on the
% photometric CCD, and clip apertures if some pixels fall in collateral region
%--------------------------------------------------------------------------
stellarApertureIndices = repmat(struct('stellarApertureRows', [], ...
    'stellarApertureColumns', []), 1, length(stellarApertures));

for i = 1:length(stellarApertures)

    apertureRowOffsets = [stellarApertures(i).offsets.row];
    apertureColOffsets = [stellarApertures(i).offsets.column];

    stellarApertureRows = stellarApertures(i).referenceRow + apertureRowOffsets;
    stellarApertureCols = stellarApertures(i).referenceColumn + apertureColOffsets;

    % record input aperture pixel indices
    stellarApertureIndices(i).stellarApertureRows = stellarApertureRows;
    stellarApertureIndices(i).stellarApertureColumns = stellarApertureCols;

    validRows    = find((stellarApertureRows(:) > nMaskedSmear) & ...
        (stellarApertureRows(:) <= (nMaskedSmear + nRowsImaging)));

    validColumns = find((stellarApertureCols(:) > nLeadingBlack) & ...
        (stellarApertureCols(:) <= (nLeadingBlack + nColsImaging)));


    if ((length(validRows) < length(stellarApertureRows)) || (length(validColumns) < length(stellarApertureCols)))
        warning('RPTS:get_stellar_target_definitions', ...
            ['Input stellar aperture pixels are off the photometric CCD for KeplerID: ' num2str(stellarApertures(i).keplerID) '.  Invalid pixels are removed from aperture.']);

        validIdx = intersect(validRows, validColumns);

        validApertureRowOffsets = apertureRowOffsets(validIdx);
        validApertureColOffsets = apertureColOffsets(validIdx);

        % deal valid offsets back into stellarApertures struct
        rowCells = num2cell(validApertureRowOffsets);
        colCells = num2cell(validApertureColOffsets);

        [newOffsets(1:length(rowCells)).row]    = deal(rowCells{:});
        [newOffsets(1:length(colCells)).column] = deal(colCells{:});

        stellarApertures(i).offsets = newOffsets;
    end
end

%--------------------------------------------------------------------------
% plot input aperture pixels over ccd image
%--------------------------------------------------------------------------
if (debugFlag >= 0)
    figure;
    colormap hot(256);
    imagesc(moduleOutputImage, [0 max(moduleOutputImage(:))/100]);
    colorbar

    hold on

    stellarApertureRows    = [stellarApertureIndices.stellarApertureRows];     % row idx for all input aperture pixels
    stellarApertureColumns = [stellarApertureIndices.stellarApertureColumns];  % col idx for all input aperture pixels

    plot(stellarApertureColumns, stellarApertureRows,  'mo', 'MarkerSize', 10, 'MarkerEdgeColor','m');
    set(gca,'YDir','reverse'); % so the origin is at the top left hand corner as it is for images

    title(['RPTS stellar input apertures on image:  Mod/Out ' num2str( currentModOut) '   [' num2str(ccdModule) ',' num2str(ccdOutput) ']']);
    xlabel('Column Index');
    ylabel('Row Index');

    fileNameStr = [ 'input_aps_on_image_mod'  num2str(ccdModule) '_out' num2str(ccdOutput) ];
    paperOrientationFlag = false;
    includeTimeFlag = false;
    printJpgFlag = false;

    plot_to_file(fileNameStr, paperOrientationFlag, includeTimeFlag, printJpgFlag);
    close all;

    hold off
end

%--------------------------------------------------------------------------
% set up input struct for TAD/AMA mask assignments (calculated via
% ama_matlab_controller_1_base)
%--------------------------------------------------------------------------
amaParameterStruct = struct('maskDefinitions', [], 'apertureStructs', [], ...
    'debugFlag', [], 'amaConfigurationStruct', []);

amaParameterStruct.maskDefinitions = existingMasks;
amaParameterStruct.fcConstants     = fcConstants;
amaParameterStruct.debugFlag       = rptsObject.debugFlag;

%--------------------------------------------------------------------------
% add halos
%--------------------------------------------------------------------------
% AMA is designed to add at most a 1 pixel halo.  If the RPTS input module parameter
% nHaloRings is nonzero, the halo pixels are added to the aperture here prior
% to calling AMA (and the AMA parameter useHaloApertures must be set to false).
% In addition, a pixel to the left of each LHS aperture pixel is added here for
% calibrating the LDE undershoot (even if no halo rings are added)
[haloStellarApertures, haloPixelOffsets] = add_n_halos(nHaloRings, stellarApertures, ...
    ccdModule, ccdOutput, debugFlag);


% preallocate struct array for stellar apertures (with nHaloRings included) for amaParameterStruct.apertureStructs:
apertureStructs = repmat(struct('keplerId', [], 'badPixelCount', [], 'referenceRow', [], ...
    'referenceColumn', [], 'offsets', []), 1, length(stellarApertures));

% re-define stellarApertures structure to reflect added halos and LHS pixels
[apertureStructs(:).offsets]         = deal(haloStellarApertures.offsets);     % new offsets

[apertureStructs(:).keplerId]        = deal(stellarApertures.keplerId);
[apertureStructs(:).badPixelCount]   = deal(stellarApertures.badPixelCount);
[apertureStructs(:).referenceRow]    = deal(stellarApertures.referenceRow);    % 1-base
[apertureStructs(:).referenceColumn] = deal(stellarApertures.referenceColumn); % 1-base

amaParameterStruct.amaConfigurationStruct.useHaloApertures = 0;
amaParameterStruct.apertureStructs   = apertureStructs;

%--------------------------------------------------------------------------
% aperture mask assignment - note the output structure of ama includes:
%   amaResultStruct.targetDefinitions
%   amaResultStruct.usedMasks
%--------------------------------------------------------------------------
amaResultStruct = ama_matlab_controller_1_base(amaParameterStruct);

% stellar target definitions are just output from AMA
stellarTargetDefinitions = amaResultStruct.targetDefinitions;   % 1-base


%--------------------------------------------------------------------------
% record the rows and columns associated with each aperture (+ halo) pixels
% in order to collect corresponding collateral (black/smear) pixels.
% Plot pixels, and ensure that selected pixels are on photometric CCD
%--------------------------------------------------------------------------
stellarIndices = repmat(struct('stellarRows', [], 'stellarColumns', []), 1, ...
    length(stellarTargetDefinitions));

stellarApWithHaloIndices = repmat(struct('haloRows', [], 'haloColumns', []), 1, ...
    length(stellarApertures));


set(gca,'YDir','reverse'); % so the origin is at the top left hand corner as it is for images
figure;

%----------------------------------------------------------------------
% plot the target definition pixels, input aperture, and additional halo
% pixels added to aperture before mask selection
%----------------------------------------------------------------------
for k = 1:length(stellarApertures)


    referenceRow = stellarApertures(k).referenceRow;           % 1-base
    referenceCol = stellarApertures(k).referenceColumn;        % 1-base

    % plot input aperture pixels
    inputApertureRows = referenceRow + [stellarApertures(k).offsets.row];
    inputApertureCols = referenceCol + [stellarApertures(k).offsets.column];

    hold on
    h1 = plot(inputApertureCols, inputApertureRows, 'mo', 'MarkerSize', 10, 'MarkerEdgeColor','m', 'MarkerFaceColor','m');

    % overplot reference row/column
    h2 = plot(referenceCol, referenceRow, 'b+', 'MarkerSize', 10);
    hold on

    % plot additional pixels added to input aperture for AMA
    % haloStellarApertures are the offsets w.r.t. ref row/col used for AMA
    haloApertureRows = referenceRow + [haloStellarApertures(k).offsets.row];
    haloApertureCols = referenceCol + [haloStellarApertures(k).offsets.column];

    % record aperture with halo pixel indices
    stellarApWithHaloIndices(k).haloRows    = haloApertureRows;
    stellarApWithHaloIndices(k).haloColumns = haloApertureCols;

    hold on
    h3 = plot(haloApertureCols, haloApertureRows, 'gs', 'MarkerSize', 11);

    % double check the halo pixels
    % haloPixelOffsets are the offsets of the additional pixels only,
    % w.r.t. the ref row/col
    haloOnlyRows = referenceRow + [haloPixelOffsets(k).offsets.row];
    haloOnlyCols = referenceCol + [haloPixelOffsets(k).offsets.column];

    if (debugFlag >= 2)
        hold on
        plot(haloOnlyCols, haloOnlyRows, 'co', 'MarkerSize', 11);  %plot only for validation to keep plot clean
    end
end

for j = 1 : length(stellarTargetDefinitions)   % can be more target defs than apertures

    % record row/cols of stellar target definitions to collect corresponding
    % collateral data
    [stellarRows, stellarColumns] = get_absolute_pixel_indices(stellarTargetDefinitions(j), existingMasks);

    stellarIndices(j).stellarRows    = stellarRows;
    stellarIndices(j).stellarColumns = stellarColumns;

    % plot the stellar target definitions, which include the input aperture
    % pixels, halos, and the pixels in the mask that was assigned
    targetRefRow = stellarTargetDefinitions(j).referenceRow;
    targetRefCol = stellarTargetDefinitions(j).referenceColumn;

    maskIndex = stellarTargetDefinitions(j).maskIndex;

    targetRowOffsets = [existingMasks(maskIndex).offsets.row];
    targetColOffsets = [existingMasks(maskIndex).offsets.column];

    targetDefRows = targetRefRow + targetRowOffsets;
    targetDefCols = targetRefCol + targetColOffsets;

    % testing get_absolute_pixel_indices function:
    if ~isequal(targetDefRows, stellarRows) || ~isequal(targetDefCols, stellarColumns)
        display('RPTS:get_stellar_target_definitions: check stellar row/col indices. ');
    end

    hold on
    h5 = plot(targetDefCols, targetDefRows, 'b.');


    %----------------------------------------------------------------------
    % validate results: check to ensure that all stellar target reference
    % pixels are on the CCD
    %----------------------------------------------------------------------
    validRows    = find((stellarRows(:) > 0) & (stellarRows(:) <= numCcdRows));
    validColumns = find((stellarColumns(:) > 0) & (stellarColumns(:) <= numCcdColumns));

    if (length(validRows) < length(stellarRows)) || ((length(validColumns) < length(stellarColumns)))
        error('RPTS:get_stellar_target_definitions: Output stellar target definition row and/or column is off the CCD');
    end

    %----------------------------------------------------------------------
    % report if any pixels are in collateral
    %----------------------------------------------------------------------
    anyPixelsInLeadingBlack  =  find((stellarColumns(:) > 0) & ...
        (stellarColumns(:) <= nLeadingBlack), 1);   % 0 < cols <= 12

    if ~isempty(anyPixelsInLeadingBlack)
        warning('RPTS:get_stellar_target_definitions', ...
            ['Pixels in target definition ' num2str(j) ' are in leading black region']);
    end

    anyPixelsInTrailingBlack =  find((stellarColumns(:) > (nLeadingBlack+nColsImaging)) & ...
        (stellarColumns(:) <= numCcdColumns), 1); % 1112 < cols <= 1132

    if ~isempty(anyPixelsInTrailingBlack)
        warning('RPTS:get_stellar_target_definitions', ...
            ['Pixels in target definition ' num2str(j) ' are in trailing black region']);
    end

    anyPixelsInMaskedSmear   =  find((stellarRows(:) > 0) &  ...
        (stellarRows(:) <= nMaskedSmear), 1);   % 0 < rows <= 20

    if ~isempty(anyPixelsInMaskedSmear)
        warning('RPTS:get_stellar_target_definitions', ...
            ['Pixels in target definition ' num2str(j) ' are in masked smear region']);
    end

    anyPixelsInVirtualSmear  =  find((stellarRows(:) > (nMaskedSmear+nRowsImaging)) & ...
        (stellarRows(:) <= numCcdRows), 1);   % 1044 < rows <= 1070

    if ~isempty(anyPixelsInVirtualSmear)
        warning('RPTS:get_stellar_target_definitions', ...
            ['Pixels in target definition ' num2str(j) ' are in virtual smear region']);
    end

    hold on
end

legend([h1 h2 h3 h5], {'Input aperture', 'Reference row/col', 'Aperture with halo', 'Target definition'}, 'Location', 'Best');
title(['RPTS stellar target definitions:  Module Output ' num2str( currentModOut) '   [' num2str(ccdModule) ',' num2str(ccdOutput) ']']);
grid on
xlabel('Column Index');
ylabel('Row Index');

fileNameStr = [ 'stellar_aps_and_target_defs_mod'  num2str(ccdModule) '_out' num2str(ccdOutput) ];
paperOrientationFlag = false;
includeTimeFlag = false;
printJpgFlag = false;

plot_to_file(fileNameStr, paperOrientationFlag, includeTimeFlag, printJpgFlag);
close all;

hold off

%--------------------------------------------------------------------------
% plot target definition pixels over ccd image
%--------------------------------------------------------------------------
figure;
colormap hot(256);
imagesc(moduleOutputImage, [0 max(moduleOutputImage(:))/100]);
colorbar

hold on

stellarTargetRows = [stellarIndices.stellarRows];    % row idx for all target def pixels
stellarTargetCols = [stellarIndices.stellarColumns]; % col idx for all target def pixels

h1 = plot(stellarTargetCols, stellarTargetRows,  'mo', 'MarkerSize', 10, 'MarkerEdgeColor','m');
set(gca,'YDir','reverse'); % so the origin is at the top left hand corner as it is for images

hold on

stellarInputApertureRows    = [stellarApertureIndices.stellarApertureRows];     % row idx for all input aperture pixels
stellarInputApertureColumns = [stellarApertureIndices.stellarApertureColumns];  % col idx for all input aperture pixels

h2 = plot(stellarInputApertureColumns, stellarInputApertureRows,  'cx', 'MarkerSize', 10, 'MarkerEdgeColor','c');

haloApertureRows    = [stellarApWithHaloIndices.haloRows];
haloApertureColumns = [stellarApWithHaloIndices.haloColumns];

h3 = plot(haloApertureColumns, haloApertureRows,  'c+', 'MarkerSize', 10, 'MarkerEdgeColor','c');

legend([h1 h2 h3], {'Target definition pixels', 'Stellar aperture pixels', 'Stellar aperture with halo pixels'}, 'Location', 'Best');

title(['RPTS stellar apertures and target definitions on image:  Module Output ' num2str( currentModOut) '   [' num2str(ccdModule) ',' num2str(ccdOutput) ']']);
xlabel('Column Index');
ylabel('Row Index');

fileNameStr = [ 'stellar_aps_and_target_defs_on_image_mod'  num2str(ccdModule) '_out' num2str(ccdOutput) ];
paperOrientationFlag = false;
includeTimeFlag = false;
printJpgFlag = false;

plot_to_file(fileNameStr, paperOrientationFlag, includeTimeFlag, printJpgFlag);
close all;

hold off


%--------------------------------------------------------------------------
% save stellar figures to a local directory
%--------------------------------------------------------------------------
% create new directory with mod/out
newDirectory = ['figs_for_stellar_target_defs_mod' num2str(ccdModule) '_out' num2str(ccdOutput)];
eval(['mkdir ' newDirectory]);

% windows MATLAB doesn't recognize the unix mv command
%eval(['!mv cal_*.fig ', newDirectory]);
movefile('input_aps_on_image*.fig', newDirectory);
movefile('stellar_aps_and_target_defs*.fig', newDirectory);


return;
