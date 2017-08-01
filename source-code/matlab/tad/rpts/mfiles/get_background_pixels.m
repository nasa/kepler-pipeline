function [selectedBkgdRows, selectedBkgdColumns] = ...
    get_background_pixels(targetImage, k, nPixelsPerTarget, debugFlag)
% function to select background reference pixels for each corresponding stellar
% aperture.  The rows/columns of good background candidate pixels are sorted by angle
% surrounding the stellar target, and are subsequently selected at random from
% the binned distribution.  Either the number of requested background pixels per stellar
% target are output, or the maximum of the 'good' (post-filtered) background pixels available.
%
% INPUT
%       targetImage         subset of module output image (minus smear)
%                              with good background pixel candidates
%  nPixelsPerTarget         input parameter nBackgroundPixelsPerStellarTarget
%         centerRow         mean row of target image
%      centerColumn         mean column of target image
%      apertureLinearIdx    linear indices on mod/out image of aperture
%                           pixels, used to check for overlapping pixels
%
%
% OUTPUT
% collectedAllPixels  [array]  an array of absolute rows and columns of
%                              background pixels for the input stellar aperture
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

if ~any(any(targetImage))

    selectedBkgdRows = [];
    selectedBkgdColumns = [];
    display(['RPTS:get_background_pixels: No available background pixels for stellar target definition: ' num2str(k)]);
    return;
end

% set random seed
rand('seed',0);

% get indices of background candidate pixels on target image
[targetImageRow, targetImageColumn] = find(targetImage);

% find mean center pixel on target image
meanCenterRow       = round(mean(targetImageRow));
meanCenterColumn    = round(mean(targetImageColumn));

% translate row/columns relative to mean center
rowRelative         = targetImageRow    - meanCenterRow;
columnRelative      = targetImageColumn - meanCenterColumn;

% convert pixel idx to polar coords
[thetaGoodPixels, rGoodPixels] = cart2pol(rowRelative, columnRelative);   % Units: radians, pixels


% plot an angle histogram showing the distribution of theta (radians) in #bins
% determined by the desired #bkgd pixels per target, equally spaced in range [0, 2*pi]
if (debugFlag >= 0)
    figure;
    rose(thetaGoodPixels, nPixelsPerTarget);

    title(['Distribution of background pixel angles (radians) around mean center for stellar target ' num2str(k)]);

    fileNameStr = [ 'bkgd_pixel_rose_hist_for_target_'  num2str(k)];
    paperOrientationFlag = false;
    includeTimeFlag = false;
    printJpgFlag = false;

    plot_to_file(fileNameStr, paperOrientationFlag, includeTimeFlag, printJpgFlag);
    close all;
end

% convert theta in degrees for histrogram
goodPixelsAngleArray        = [thetaGoodPixels * 180/pi,  rGoodPixels];

% sort [theta, R] by angle (degrees)
sortedGoodPixelsAngleArray  = sortrows(goodPixelsAngleArray);

goodPixelsThetaSorted       = sortedGoodPixelsAngleArray(:, 1);
goodPixelsRSorted           = sortedGoodPixelsAngleArray(:, 2);

% plot histogram of theta (degrees)
if (debugFlag >= 0)
    figure;

    hist(goodPixelsThetaSorted, nPixelsPerTarget);

    title(['Histogram of background pixel angles (degrees) around mean center for stellar target ' num2str(k)]);

    fileNameStr = [ 'bkgd_pixel_hist_for_target_'  num2str(k)];
    paperOrientationFlag = false;
    includeTimeFlag = false;
    printJpgFlag = false;

    plot_to_file(fileNameStr, paperOrientationFlag, includeTimeFlag, printJpgFlag);
    close all;
end


% bin pixels by angle (degrees)
[nPixels, binCenter] = hist(goodPixelsThetaSorted, nPixelsPerTarget);

binSize             = diff(binCenter);
binNumber           = 1:length(nPixels);

binStartValues      = round(binCenter - binSize(1)/2);
binEndValues        = round(binCenter + binSize(1)/2);

validBinNumbers     = binNumber(nPixels>0);

binStartEndArray    = [binStartValues(validBinNumbers)'  binEndValues(validBinNumbers)'];


% allocate memory for selected background pixels (rows and columns on target image)
backgroundPixelsSelected   = repmat(struct('backgroundRow', [], 'backgroundColumn', []), nPixelsPerTarget, 1);

% first loop over each bin with available (valid) pixels
for i = 1:length(validBinNumbers)

    % select a pixel from each valid bin at random
    [rowKeep, columnKeep, randomPixelIndex] = find_good_pixels(goodPixelsThetaSorted, ...
        goodPixelsRSorted, binStartEndArray(i, :));

    % add to list of selected background pixels if valid
    if ~isempty(rowKeep) && ~isempty(columnKeep)

        % save pixel indices to output struct
        backgroundPixelsSelected(i).backgroundRow       = rowKeep;
        backgroundPixelsSelected(i).backgroundColumn    = columnKeep;

        % remove pixel indices from good pixels list
        goodPixelsThetaSorted(randomPixelIndex) = [];
        goodPixelsRSorted(randomPixelIndex)     = [];
    end
end

nPixelsCollected = length([backgroundPixelsSelected.backgroundRow]);

% record how many additional pixels are needed
nPixelsToCollect = min((length(goodPixelsThetaSorted)), nPixelsPerTarget - nPixelsCollected);

if nPixelsToCollect == 0

    % translate row/columns indices from mean center back to target image
    selectedBkgdRows      = [backgroundPixelsSelected.backgroundRow]    + meanCenterRow;
    selectedBkgdColumns   = [backgroundPixelsSelected.backgroundColumn] + meanCenterColumn;

    return;
end


% start counter
while (nPixelsCollected < min(length(goodPixelsThetaSorted), nPixelsPerTarget))

    % select a bin at random
    randomBinIndex = unidrnd(length(validBinNumbers));

    % select a pixel from each valid bin at random
    [rowKeep, columnKeep, randomPixelIndex] = find_good_pixels(goodPixelsThetaSorted, ...
        goodPixelsRSorted, binStartEndArray(randomBinIndex, :));

    % add to list of selected background pixels if valid
    if ~isempty(rowKeep) && ~isempty(columnKeep)

        % increment if pixels are collected
        nPixelsCollected = nPixelsCollected + 1;

        % save pixel indices to output struct
        backgroundPixelsSelected(nPixelsCollected).backgroundRow    = rowKeep;
        backgroundPixelsSelected(nPixelsCollected).backgroundColumn = columnKeep;

        % remove pixel indices from good pixels list
        goodPixelsThetaSorted(randomPixelIndex) = [];
        goodPixelsRSorted(randomPixelIndex)     = [];
    end
end

% translate row/columns indices from mean center back to target image
selectedBkgdRows      = [backgroundPixelsSelected.backgroundRow]    + meanCenterRow;
selectedBkgdColumns   = [backgroundPixelsSelected.backgroundColumn] + meanCenterColumn;


return;
