function [backgroundTargetDefinition, backgroundMaskDefinition, backgroundIndices, ...
    boundingRadius, moduleOutputImageMinusSmear, targetBounds] =  ...
    get_background_target_definition(rptsObject, stellarTargetDefinitions)
% function [backgroundTargetDefinition, backgroundMaskDefinition, backgroundIndices, ...
%     boundingRadius, moduleOutputImageMinusSmear] =  ...
%     get_background_target_definition(rptsObject, stellarTargetDefinitions)
%
% function to select background reference pixels for each corresponding stellar
% reference pixel target, and define a target and mask definition.  The rows/columns
% for all background pixels in target definition are recorded for the
% collection of black/smear pixels.
%
% Note: pixels in the output mask definition struct are converted to 0-base
% herein (more efficient), whereas pixels in target definition are converted
% in separate algorithm
%
% INPUT
%   rptsObject     the relevant fields extracted from the object for this function are:
%
%                  moduleOutputImage:   [struct array] image on the module output CCD produced by TAD/coa
%                          debugFlag:   flag for debugging algorithm
%
%         rptsModuleParametersStruct:   [struct array] which includes the following relevant fields:
%                     boundingRadius:   radius (in pixels) around stellar target to bound
%                                       area from which to select background pixels
%  nBackgroundPixelsPerStellarTarget:   number of background pixels to select for each stellar target
%
%                   stellarApertures:   [struct array] consisting of the following fields:
%                           keplerId:   target star KIC id's
%                       referenceRow:   row number of center pixel
%                    referenceColumn:   column number of center pixel
%                            offsets:   [struct array] consisting of the fields 'row' and 'column'
%                      badPixelCount:   indices of bad pixels
%
%
% OUTPUT
%   backgroundTargetDefinition:   [struct] consisting of the following fields:
%               keplerId: [struct array]    target star KIC id number
% 1-base    referenceRow: [struct array]    reference row on the module output for target definition
% 1_base referenceColumn: [struct array]    reference column on the module output for target definition
%              maskIndex: [struct array]    index into backgroundMaskDefinition table for target definition
%           excessPixels: [struct array]    number of pixels in the assigned mask that are not in the requested aperture
%                 status: [struct array]    status indicating successful mask assignment:
%                                              status = -1: no mask assigned
%                                              status =  1: mask assigned, no problems
%                                              status = -2: mask assigned but has pixels off the CCD
%
%     backgroundMaskDefinition: [struct array] consisting of the following field:
% 0-base               offsets: [struct array] consisting of the fields 'row' and 'column'
%
% 1-base     backgroundIndices:  [struct] the same length as backgroundTargetDefinition, with the following fields:
%               backgroundRows:  a list of row indices that contain background pixels, to be used to collect black
%            backgroundColumns:  a list of column indices that contain background pixels, to be used to collect smear
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

% temporary time stamp until get_read_noise is updated
timestamp = 55300;

debugFlag = rptsObject.debugFlag;

close all;

%--------------------------------------------------------------------------
% extract relevant fields and module parameters from object
%--------------------------------------------------------------------------

% extract fields from object
stellarApertures           = rptsObject.stellarApertures;
rptsModuleParametersStruct = rptsObject.rptsModuleParametersStruct;
existingMasks              = rptsObject.existingMasks;

% extract focal plane constants
fcConstants = rptsObject.fcConstants;

nRowsImaging    = fcConstants.nRowsImaging;   % 1024
nColsImaging    = fcConstants.nColsImaging;   % 1100
nLeadingBlack   = fcConstants.nLeadingBlack;  % 12
%nTrailingBlack  = fcConstants.nTrailingBlack; % 20
%nVirtualSmear   = fcConstants.nVirtualSmear;  % 26
nMaskedSmear    = fcConstants.nMaskedSmear;   % 20
numCcdRows      = fcConstants.CCD_ROWS;       % 1070
numCcdColumns   = fcConstants.CCD_COLUMNS;    % 1132

% get relevant module parameters
boundingRadius         = rptsModuleParametersStruct.radiusForBackgroundPixelSelection;
nPixelsPerTarget       = rptsModuleParametersStruct.nBackgroundPixelsPerStellarTarget;
backgroundModeThresh   = rptsModuleParametersStruct.backgroundModeThresh;
smearNoiseRatioThresh  = rptsModuleParametersStruct.smearNoiseRatioThresh;

% get number of exposures per cadence
scConfigParameters = rptsObject.scConfigParameters;

integrationsPerShortCadence = scConfigParameters.integrationsPerShortCadence;
shortCadencesPerLongCadence = scConfigParameters.shortCadencesPerLongCadence;

exposuresPerCadence = integrationsPerShortCadence * shortCadencesPerLongCadence;

%--------------------------------------------------------------------------
% extract the read noise model, and get the read noise for this mod/out
%--------------------------------------------------------------------------
readNoiseModel = rptsObject.readNoiseModel;

% create the read noise object
readNoiseObject = readNoiseClass(readNoiseModel);

ccdModule = rptsObject.module;
ccdOutput = rptsObject.output;
currentModOut = convert_from_module_output(ccdModule, ccdOutput);

% retrieve the read noise for current mod/out/mjds
readNoiseInADU = get_read_noise(readNoiseObject, timestamp, ccdModule, ccdOutput);

% compute read noise squared
readNoiseSquared = readNoiseInADU.^2;

%--------------------------------------------------------------------------
% extract module output image and correct image for smear
%--------------------------------------------------------------------------
moduleOutputImage = rptsObject.moduleOutputImage;

% convert output image from arrays of structures to 2D array
moduleOutputImage = struct_to_array2D(moduleOutputImage);

% remove smear from image
smear = mean(moduleOutputImage(1:nMaskedSmear, :));
moduleOutputImageMinusSmear = moduleOutputImage - repmat(smear, size(moduleOutputImage, 1), 1);

%--------------------------------------------------------------------------
% plot the image with and without smear
%--------------------------------------------------------------------------
if (debugFlag >= 0)

    figure;
    colormap hot(256);

    subplot(1,2,1);
    imagesc(moduleOutputImage, [0 max(moduleOutputImage(:))/100]);
    title(['CCD Image:  Module Output ' num2str( currentModOut) '   [' num2str(ccdModule) ',' num2str(ccdOutput) ']']);

    subplot(1,2,2);
    imagesc(moduleOutputImageMinusSmear, [0 max(moduleOutputImageMinusSmear(:))/100]);
    title('Smear-removed CCD Image');

    fileNameStr = [ 'smear_corrected_image_mod'  num2str(ccdModule) '_out' num2str(ccdOutput) ];
    paperOrientationFlag = false;
    includeTimeFlag = false;
    printJpgFlag = false;

    plot_to_file(fileNameStr, paperOrientationFlag, includeTimeFlag, printJpgFlag);
    close all;
end


%--------------------------------------------------------------------------
% preallocate structures for target definition, mask definition, and to collect
% row/column indices of all background pixels
%--------------------------------------------------------------------------
backgroundTargetDefinition = struct('keplerId', [], 'referenceRow', [], ...  %only 1 target def at (1,1)
    'referenceColumn', [], 'maskIndex', [], 'excessPixels', []);

%nOffsetsInMask = nPixelsPerTarget * length(stellarApertures);
nOffsetsInMask = nPixelsPerTarget * length(stellarTargetDefinitions);

backgroundMaskDefinition = struct('offsets', (struct('row', zeros(1, nOffsetsInMask), 'column',  zeros(1, nOffsetsInMask))));

backgroundIndices = repmat(struct('backgroundRows', zeros(1, nPixelsPerTarget), ...
    'backgroundColumns', zeros(1, nPixelsPerTarget)), 1, length(stellarTargetDefinitions));

targetBounds = zeros(length(stellarTargetDefinitions), 4); %array to hold row/col min/max values

%--------------------------------------------------------------------------
% loop through stellar target defs to select background pixels around each
% stellar apertures:
%--------------------------------------------------------------------------
%
% (1) create target image (subset of mod/out image) centered around
% reference row/column
%
% (2) convolve image to add buffer rings (# determined by input parameter
% background radius; these will be the bkgd pixel candidates (aperture
% pixels have already been removed above).
%
% (3) find pixels close to the estimated background mode, and filter out
% pixels with flux values greater than the mode.
%
% (4) filter out pixels corrupted by smear
%
% (5) filter out pixels in the target definition
%
% If not enough good bkgd candidate pixels are available in the target image
% after all of the filters, the bounding radius is increased by 1 pixel (up
% to N=boundingRadius trials) until there are enough pixels (else a warning
% will state that no bkgd pixels selected for the kepler ID).
%
% (6) bin remaining available pixels by angle, and select pixels that are
% (roughly) evenly distributed around stellar aperture
%
%--------------------------------------------------------------------------
for j = 1 : length(stellarTargetDefinitions)

    % get reference row/col for this stellar target def to create target
    % image (subset of mod/out image)
    centerRow = stellarTargetDefinitions(j).referenceRow;
    centerCol = stellarTargetDefinitions(j).referenceColumn;

    % extract mask index for this stellar target definition
    maskIndex = stellarTargetDefinitions(j).maskIndex;

    % get row/col indices of input target definition pixels (which will
    % be excluded from the list of good background pixel candidates)
    stellarTargetRows = centerRow + [existingMasks(maskIndex).offsets.row];
    stellarTargetCols = centerCol + [existingMasks(maskIndex).offsets.column];

    %----------------------------------------------------------------------
    % clip off any pixels in collateral region or off CCD
    %----------------------------------------------------------------------
    [stellarTargetRows, stellarTargetCols] = clip_pixels_to_photometric_ccd(stellarTargetRows, ...
        stellarTargetCols, fcConstants, 'Stellar target definition ', 1);


    % the number of input buffer rings to add around target is an input
    % parameter.  Add these pixel rings by convolving the target definition
    % with a 3x3 logical image N times, where N = boundingRadius.  If not
    % enough background pixels are available, the bounding radius will
    % be increased by 1 pixel at a time (up to nTrials = boundingRadius)
    % until enough pixels are available
    for nTrials = 1:boundingRadius


        %------------------------------------------------------------------
        % find indices (offsets) for pixels within input bounding radius
        % around the stellar target
        %------------------------------------------------------------------
        newTargetImageOffsets = ...
            get_target_image_for_bkgd_pixel_selection(existingMasks(maskIndex), boundingRadius);


        % get row/col indices on mod/out of target image (including bounding radius) pixels
        newTargetImageRows = centerRow + [newTargetImageOffsets.offsets.row];
        newTargetImageCols = centerCol + [newTargetImageOffsets.offsets.column];

        %------------------------------------------------------------------
        % clip off any pixels in collateral region or off CCD
        %------------------------------------------------------------------
        [newTargetImageRows, newTargetImageCols] = clip_pixels_to_photometric_ccd(newTargetImageRows, ...
            newTargetImageCols, fcConstants, 'Target image ', 1);

        %------------------------------------------------------------------
        % extract target image subset from mod/out image
        %------------------------------------------------------------------
        % get pixels indices on smear-removed mod/out image
        targetImageLinearIdx = sub2ind(size(moduleOutputImageMinusSmear), newTargetImageRows, newTargetImageCols);

        % get target image with smear correction
        targetImageLinearArray = moduleOutputImageMinusSmear(targetImageLinearIdx);

        % get target image without smear correction (for filtering out
        % background pixels that may be corrupted by smear)
        targetImageWithSmearLinearArray = moduleOutputImage(targetImageLinearIdx);


        % find bounds for target image in 2D
        minRow = min(newTargetImageRows);        % w.r.t. mod/out coordinates
        maxRow = max(newTargetImageRows);        % w.r.t. mod/out coordinates

        minCol = min(newTargetImageCols);
        maxCol = max(newTargetImageCols);

        % save min/max row/cols for final plot of bounding image
        targetBounds(j, :) = [minRow maxRow minCol maxCol];

        % number of rows and columns that have non-zero entries
        nImageRows = maxRow - minRow + 1;
        nImageCols = maxCol - minCol + 1;

        % allocate memory for 2D image array
        targetImage = zeros(nImageRows, nImageCols);

        targetRows = newTargetImageRows - minRow + 1;  % w.r.t. new target image coordinates
        targetCols = newTargetImageCols - minCol + 1;  % w.r.t. new target image coordinates

        newCenterRow = centerRow - minRow + 1;         % w.r.t. new target image coordinates
        newCenterCol = centerCol - minCol + 1;         % w.r.t. new target image coordinates

        % vectorize!(?)
        for nTargetPixels = 1:length(targetImageLinearArray)

            % convert linear indices to 2D image
            targetImage(targetRows(nTargetPixels), targetCols(nTargetPixels)) = ...
                targetImageLinearArray(nTargetPixels);
        end

        %------------------------------------------------------------------
        % plot smear-removed 2D target image pixels within bounding radius
        %------------------------------------------------------------------
        if (debugFlag >= 0)
            figure;

            colormap hot(256);

            subplot(1,2,1);
            imagesc(targetImage, [0 max(moduleOutputImageMinusSmear(:))/100]);

            title(['Target image ' num2str(j) ', Ref row/col: [' num2str(centerRow) ', ' num2str(centerCol) ']']);

            xlabel('Columns');
            ylabel('Rows');
            colorbar('southoutside');

            hold on
            plot(newCenterCol, newCenterRow, 'mo', 'MarkerSize', 10, 'MarkerEdgeColor','m');
        end


        %----------------------------------------------------------------------
        % FILTER #1: estimate the background mode and filter out pixels with
        % flux values greater than the background mode
        %----------------------------------------------------------------------
        targetImageMin = zeros(size(targetImage));

        nTargetRows = length(targetImage(:, 1));
        nTargetCols = length(targetImage(1, :));
        nPixWindow  = 11;


        % find local minima across columns
        for i = 1:nTargetCols
            targetImageMin(:,i) = movmin(targetImage(:,i), nPixWindow);
        end

        % find local minima across rows
        for i = 1:nTargetRows
            targetImageMin(i,:) = movmin(targetImage(i,:)', nPixWindow)';
        end


        % compute median of min target image
        medianMinImage = median(targetImageMin(targetImageMin~=0));

        % compute median absolute deviation of min target image
        madMinImage = mad(targetImageMin(targetImageMin~=0));

        % include input parameter mad threshold
        madMinImage = backgroundModeThresh*madMinImage;

        %------------------------------------------------------------------
        % set 'bad' pixel candidates in target image equal to zero
        %------------------------------------------------------------------
        targetImage(targetImage > medianMinImage + madMinImage) = 0;


        %------------------------------------------------------------------
        % plot 2D target image with available background pixels (close to
        % background mode)
        %------------------------------------------------------------------
        if (debugFlag >= 0)

            colormap hot(256);

            subplot(1,2,2);
            imagesc(targetImage, [0 max(moduleOutputImageMinusSmear(:))/100]);

            title(['Map of "good" background pixels for target ' num2str(j)]);

            colorbar('southoutside');
            xlabel('Columns');
            ylabel('Rows');

            hold on
            plot(newCenterCol, newCenterRow, 'mo', 'MarkerSize', 10, 'MarkerEdgeColor','m');

            fileNameStr = ['target_image_'  num2str(j) '_and_available_bkgd_pix'];
            paperOrientationFlag = false;
            includeTimeFlag = false;
            printJpgFlag = false;

            plot_to_file(fileNameStr, paperOrientationFlag, includeTimeFlag, printJpgFlag);
            close all;
        end


        %--------------------------------------------------------------------------
        % FILTER #2: avoid selecting background pixels that are corrupted by smear:
        % filter out bad background pixel candidates by comparing the exposure noise
        % on images with & without smear (compare this ratio to the threshold value
        % that is passed in as an input parameter)

        % noise on image with smear
        noiseOnTargetImageWithSmear = sqrt(targetImageWithSmearLinearArray + exposuresPerCadence * readNoiseSquared);

        % noise on image without smear
        noiseOnTargetImageWithoutSmear = sqrt(targetImageLinearArray + exposuresPerCadence * readNoiseSquared);

        % ratio of the noise in the image with smear to that in the smear-removed image
        noiseRatio = noiseOnTargetImageWithSmear ./ noiseOnTargetImageWithoutSmear;

        if (debugFlag >= 0)

            figure;
            plot(noiseOnTargetImageWithoutSmear, noiseRatio, '.');

            title(['Smear-corrected target image vs. noise ratio.  Bad bkgd pixels declared above noise ratio threshold: ' num2str(smearNoiseRatioThresh+1)]);

            grid on
            xlabel('Smear-corrected target image');
            ylabel('Ratio of noise in raw target image to noise in smear-removed target image');

            fileNameStr = [ 'smear_corrupted_bkgd_pixel_threshold_target_'  num2str(j)];
            paperOrientationFlag = false;
            includeTimeFlag = false;
            printJpgFlag = false;

            plot_to_file(fileNameStr, paperOrientationFlag, includeTimeFlag, printJpgFlag);
            close all;
        end

        %--------------------------------------------------------------------------
        % set pixels which have a noise ratio greater than the input parameter
        % smearNoiseRatioThresh equal to zero, which eliminates pixels dominated by
        % smear from the background pixel candidates list
        %--------------------------------------------------------------------------
        targetImage(noiseRatio > smearNoiseRatioThresh + 1) = 0;


        %--------------------------------------------------------------------------
        % FILTER #3: remove all input aperture/target definition pixels from list of
        % background pixel candidates
        %--------------------------------------------------------------------------
        stellarTargetDefRows = stellarTargetRows - minRow + 1;  % w.r.t. new target image coordinates
        stellarTargetDefCols = stellarTargetCols - minCol + 1;  % w.r.t. new target image coordinates

        stellarTargetDefLinearIdx = sub2ind(size(targetImage), stellarTargetDefRows,  stellarTargetDefCols);

        %--------------------------------------------------------------------------
        % set target definition pixels equal to 0
        %--------------------------------------------------------------------------
        targetImage(stellarTargetDefLinearIdx) = 0;

        if (debugFlag >= 0)

            figure;
            colormap hot(256);
            imagesc(targetImage, [0 max(moduleOutputImageMinusSmear(:))/100]);

            hold on
            plot(stellarTargetDefCols, stellarTargetDefRows,  'mo', 'MarkerSize', 10, 'MarkerEdgeColor','m');

            title(['Target image ' num2str(j) ' with stellar target definition pixels filtered out']);

            xlabel('Column Index');
            ylabel('Row Index');

            fileNameStr = [ 'stellar_pix_removed_for_bkgd_selection_target_'  num2str(j)];
            paperOrientationFlag = false;
            includeTimeFlag = false;
            printJpgFlag = false;

            plot_to_file(fileNameStr, paperOrientationFlag, includeTimeFlag, printJpgFlag);
            close all;
        end



        %----------------------------------------------------------------------
        % if there are not enough available pixel candidates, increase
        % bounding radius by 1 pixel and try again
        %----------------------------------------------------------------------
        if (~any(any(targetImage))) || (length(find(targetImage)) < nPixelsPerTarget)

            boundingRadius = boundingRadius + 1;

        else

            break;  % a sufficient number of pixels are available for bkgd selection

        end
    end

    % if for some reason there are still no available pixels after the N
    % trials, then set background row/col fields to empty and go to next
    % stellar target
    if (~any(any(targetImage)))

        backgroundIndices(j).backgroundRows   = [];
        backgroundIndices(j).backgroundColumns = [];

        warning('RPTS:get_background_target_definition', ...
            ['No background pixels found for kepler ID ', num2str(stellarTargetDefinitions(j).keplerId)]);
        break;
    end  % go to next stellar target


    %----------------------------------------------------------------------
    % collect and save background pixels
    %----------------------------------------------------------------------
    [selectedBkgdRows, selectedBkgdColumns] = ...
        get_background_pixels(targetImage, j, nPixelsPerTarget, debugFlag);


    if (debugFlag >= 0)
        figure;
        colormap hot(256);
        imagesc(targetImage, [0 max(moduleOutputImageMinusSmear(:))/100]);

        hold on
        plot(selectedBkgdColumns, selectedBkgdRows, 'ms', 'MarkerSize', 11, 'MarkerEdgeColor','m');
        hold on
        plot(newCenterCol, newCenterRow, 'mo', 'MarkerSize', 10, 'MarkerEdgeColor','m');

        colorbar;

        title(['Background pixels selected (red squares) for target definition ' num2str(j)]);

        xlabel('Column Index');
        ylabel('Row Index');

        fileNameStr = [ 'bkgd_pixels_selected_target_'  num2str(j)];
        paperOrientationFlag = false;
        includeTimeFlag = false;
        printJpgFlag = false;

        plot_to_file(fileNameStr, paperOrientationFlag, includeTimeFlag, printJpgFlag);
        close all;
    end

    % collect row and column information for the backgroundIndices output
    if ~isempty(selectedBkgdRows) && ~isempty(selectedBkgdColumns)

        % translate background pixel indices to mod/out coordinates
        bkgdRowsOnTargetImage = selectedBkgdRows    + minRow - 1;
        bkgdColsOnTargetImage = selectedBkgdColumns + minCol - 1;


        backgroundIndices(j).backgroundRows    = bkgdRowsOnTargetImage;
        backgroundIndices(j).backgroundColumns = bkgdColsOnTargetImage;

    else
        backgroundIndices(j).backgroundRows  = [];
        backgroundIndices(j).backgroundColumns = [];

        warning('RPTS:get_background_target_definition', ...
            ['No background pixels found for kepler ID ', num2str(rptsObject.stellarApertures(j).keplerId)]);
    end
end  % j (stellar targets) loop


%--------------------------------------------------------------------------
% record the row/columns of all selected background pixels for supermask
backgroundRows      = [backgroundIndices.backgroundRows];
backgroundColumns   = [backgroundIndices.backgroundColumns];

if (isempty(backgroundRows) || isempty(backgroundColumns))
    error('RPTS:get_background_target_definition:  No background pixels selected for any targets');
end

%--------------------------------------------------------------------------
% take unique pixels, since more than one target definition may be assigned
% to a stellar aperture
backgroundPixelArray = [backgroundRows(:) backgroundColumns(:)];

uniquePixels = unique(backgroundPixelArray, 'rows');

if (length(uniquePixels(:, 1)) < length(backgroundRows))
    disp(['RPTS:get_background_target_definition: ' num2str(length(uniquePixels(:, 1))) ' unique background pixels selected for ' num2str(length(stellarTargetDefinitions)) ' stellar targets'])
end

backgroundRows    = uniquePixels(:, 1);
backgroundColumns = uniquePixels(:, 2);

%--------------------------------------------------------------------------
% check to ensure that there are no overlapping background and stellar aperture pixels
%--------------------------------------------------------------------------
backgroundLinearIdx = sub2ind(size(moduleOutputImageMinusSmear), ...
    backgroundRows, backgroundColumns);

overlappingPixels = ismember(backgroundLinearIdx, stellarTargetDefLinearIdx);

if any(overlappingPixels)
    error('RPTS:get_background_target_definition: Background pixel(s) overlap with stellar apertures!');
end

%--------------------------------------------------------------------------
% report if more/less background reference pixels are chosen than requested
%--------------------------------------------------------------------------
% number of expected background pixels
nBackgroundPixelsExpected = length(stellarTargetDefinitions) * ...
    rptsObject.rptsModuleParametersStruct.nBackgroundPixelsPerStellarTarget;

% number of selected background pixels may be less than expected (if not
% enough "good" pixels to select from)
nBackgroundPixelsSelected = length([backgroundIndices.backgroundRows]);

if (nBackgroundPixelsSelected < nBackgroundPixelsExpected)
    warning('RPTS:get_background_target_definition', ...
        ['Total number of selected background pixels [' num2str(nBackgroundPixelsSelected) '] is less than total number of requested pixels [' num2str(nBackgroundPixelsExpected) ']' ]);

elseif (nBackgroundPixelsSelected > nBackgroundPixelsExpected)
    warning('RPTS:get_background_target_definition', ...
        ['Total number of selected background pixels [' num2str(nBackgroundPixelsSelected) '] is greater than total number of requested pixels [' num2str(nBackgroundPixelsExpected) ']' ]);
else
    disp(['RPTS:get_background_target_definition: ' num2str(nBackgroundPixelsSelected) ' background pixels selected for ' num2str(length(stellarTargetDefinitions)) ' stellar targets'])
end

%--------------------------------------------------------------------------
% create the mask definition, which contain all background pixels with
% indices relative to the target def at (1, 1) in matlab 1-base
%--------------------------------------------------------------------------
% convert rows and columns to zero-base prior to output (faster to convert
% mask indices here when dealing values to struct arrays)
backgroundRows0base     = backgroundRows    - 1;
backgroundColumns0base  = backgroundColumns - 1;

backgroundRows0base     = num2cell(backgroundRows0base);
backgroundColumns0base  = num2cell(backgroundColumns0base);

[backgroundMaskDefinition.offsets(1:length(backgroundRows0base)).row] = deal(backgroundRows0base{:});
[backgroundMaskDefinition.offsets(1:length(backgroundColumns0base)).column] = deal(backgroundColumns0base{:});

display('RPTS:get_background_target_definition: Background mask definition row/col offsets converted to Java 0-based indexing for output. ');

%--------------------------------------------------------------------------
% create the (single) target definition, with the reference row and reference
% column set to zero
%--------------------------------------------------------------------------
backgroundTargetDefinition.keplerId         = 1;
backgroundTargetDefinition.referenceRow     = 1;  % will be 0 when converted to java 0-base for output
backgroundTargetDefinition.referenceColumn  = 1;  % will be 0 when converted to java 0-base for output
backgroundTargetDefinition.maskIndex        = 1;  % will be 0 when converted to java 0-base for output
backgroundTargetDefinition.excessPixels     = 0;
backgroundTargetDefinition.status           = 1;  % 1 is successful mask asignment

%--------------------------------------------------------------------------
% check to ensure background pixels (here, in 1-base) are on the CCD
%--------------------------------------------------------------------------
validRows    = find((backgroundRows(:) > 0)    & (backgroundRows(:) <= numCcdRows));
validColumns = find((backgroundColumns(:) > 0) & (backgroundColumns(:) <= numCcdColumns));

if (length(validRows) < length(backgroundRows)) || ((length(validColumns) < length(backgroundColumns)))
    error('RPTS:get_background_target_definition: Background pixel row/column is off the CCD');
end

%----------------------------------------------------------------------
% report if any pixels are in collateral
%----------------------------------------------------------------------
anyPixelsInLeadingBlack  =  find((backgroundColumns(:) > 0) & ...
    (backgroundColumns(:) <= nLeadingBlack), 1);   % 0 < cols <= 12

if ~isempty(anyPixelsInLeadingBlack)
    warning('RPTS:get_background_target_definition', ...
        'Background reference pixels are in leading black region');
end

anyPixelsInTrailingBlack =  find((backgroundColumns(:) > (nLeadingBlack+nColsImaging)) & ...
    (backgroundColumns(:) <= numCcdColumns), 1); % 1112 < cols <= 1132

if ~isempty(anyPixelsInTrailingBlack)
    warning('RPTS:get_background_target_definition', ...
        'Background reference pixels are in trailing black region');
end

anyPixelsInMaskedSmear   =  find((backgroundRows(:) > 0) &  ...
    (backgroundRows(:) <= nMaskedSmear), 1);   % 0 < rows <= 20

if ~isempty(anyPixelsInMaskedSmear)
    warning('RPTS:get_background_target_definition', ...
        'Background reference pixels are in masked smear region');
end

anyPixelsInVirtualSmear  =  find((backgroundRows(:) > (nMaskedSmear+nRowsImaging)) & ...
    (backgroundRows(:) <= numCcdRows), 1);   % 1044 < rows <= 1070

if ~isempty(anyPixelsInVirtualSmear)
    warning('RPTS:get_background_target_definition', ...
        'Background reference pixels are in virtual smear region');
end


%--------------------------------------------------------------------------
% save bkgd figures to a local directory
%--------------------------------------------------------------------------
% create new directory with mod/out
newDirectory = ['figs_for_bkgd_selection_mod' num2str(ccdModule) '_out' num2str(ccdOutput)];
eval(['mkdir ' newDirectory]);

% windows MATLAB doesn't recognize the unix mv command
%eval(['!mv cal_*.fig ', newDirectory]);
movefile('smear_corrected_image_mod*.fig', newDirectory);
movefile('target_image*.fig', newDirectory);
movefile('smear_corrupted_bkgd*.fig', newDirectory);
movefile('stellar_pix_removed_for_bkgd*.fig', newDirectory);
movefile('bkgd*.fig', newDirectory);


return;
