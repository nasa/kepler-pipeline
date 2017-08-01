function bpaObject = find_background_apertures(bpaObject)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function bpaObject = find_background_apertures(bpaObject)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% this algorithm is described in KADN-26112 "Background Pixel and Aperture
% Selection".  Inputs and outputs are described in bpaClass.m
%
% this algorithm is specific to 2x2 apertures.
%
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

rand('seed', 0);
randn('seed', 0);

% parameters that describe the geometry of the module output
nRowPix = bpaObject.moduleDescriptionStruct.nRowPix;
nColPix = bpaObject.moduleDescriptionStruct.nColPix;
leadingBlack = bpaObject.moduleDescriptionStruct.leadingBlack;
virtualSmear = bpaObject.moduleDescriptionStruct.virtualSmear;
maskedSmear = bpaObject.moduleDescriptionStruct.maskedSmear;
% get various fields of the bpaObject
nLinesRow = bpaObject.bpaConfigurationStruct.nLinesRow;
nLinesCol = bpaObject.bpaConfigurationStruct.nLinesCol; 
nEdge = bpaObject.bpaConfigurationStruct.nEdge;
edgeFraction = bpaObject.bpaConfigurationStruct.edgeFraction;
lineStartRow = bpaObject.bpaConfigurationStruct.lineStartRow;
lineEndRow = bpaObject.bpaConfigurationStruct.lineEndRow;
lineStartCol = bpaObject.bpaConfigurationStruct.lineStartCol;
lineEndCol = bpaObject.bpaConfigurationStruct.lineEndCol;
histBinSize = bpaObject.bpaConfigurationStruct.histBinSize;
% the input image contains smear
moduleOutputImageWithSmear = bpaObject.moduleOutputImage;
debugFlag = bpaObject.debugFlag;

% make sure that the 2x2 aps will be legal since they use row-1 and col-1
lineStartRow = max([lineStartRow, 2]);
lineStartCol = max([lineStartCol, 2]);

% remove smear using virtual smear
smear = mean(moduleOutputImageWithSmear(1:maskedSmear,:));
moduleOutputImage = moduleOutputImageWithSmear - ...
    repmat(smear, size(moduleOutputImageWithSmear, 1), 1); 

if (debugFlag)
    % draw the moduleOutputImage for debugging
    figure;
    colormap hot(256);
    subplot(1,2,1);
    imagesc(moduleOutputImageWithSmear, [0 max(moduleOutputImageWithSmear(:))/100]); % draw the basic moduleOutputImage with scaled color map
    title('moduleOutputImageWithSmear');
    subplot(1,2,2);
    imagesc(moduleOutputImage, [0 max(moduleOutputImageWithSmear(:))/100]); % draw the basic moduleOutputImage with scaled color map
    title('moduleOutputImage');
end

% a background pixel is defined as a pixel with value below a threshold
% find the background pixel threshold flux by looking for dominant mode of moduleOutputImage histogram 
nonZeroPixels = find(moduleOutputImage ~= 0); % ignore where pixels = 0 (in masked/virtual regions)
[imageHist, binFlux] = hist(moduleOutputImage(nonZeroPixels), ...
    length(moduleOutputImage(nonZeroPixels))/histBinSize); % get histogram of non-zero pixels (bin size arbetrary)
[mostBackground, mostBackgroundIndex] = max(imageHist); % find value for which there is a maximum # of pixels
binSize = binFlux(mostBackgroundIndex+1) - binFlux(mostBackgroundIndex); % calculate the size of the bin
binCenter  = binFlux(mostBackgroundIndex); % find center of dominant bin
backgroundThreshold = binCenter + binSize/2; % our background threshold, top of dominant bin

if (debugFlag)
    display(['there are ' num2str(mostBackground) ...
        ' background pixels with the value between ' ...
        num2str(binCenter - binSize/2) ' and ' num2str(binCenter + binSize/2)]);
    backPixDrawVal = max(moduleOutputImage(:)); % for drawing
end

% make the stretched Cartesian grid for the starting points of the
% background ap search
backSeedRow = round(make_stretched_grid(nLinesRow, nEdge, lineStartRow, lineEndRow, edgeFraction));
backSeedCol = round(make_stretched_grid(nLinesCol, nEdge, lineStartCol, lineEndCol, edgeFraction));

% make a 2x2 binned moduleOutputImage to facilitate search for aperture with smallest
% value
image2x2Bin = ...
    (moduleOutputImage(1:size(moduleOutputImage,1)-1, 1:size(moduleOutputImage,2)-1) ...
    + moduleOutputImage(2:size(moduleOutputImage,1), 1:size(moduleOutputImage,2)-1) ...
    + moduleOutputImage(1:size(moduleOutputImage,1)-1, 2:size(moduleOutputImage,2)) ...
    + moduleOutputImage(2:size(moduleOutputImage,1), 2:size(moduleOutputImage,2)))/4;

if (debugFlag)
    % draw the 2x2 binned moduleOutputImage for debugging
    figure;
    clf;
    colormap hot(256);
    imagesc(image2x2Bin, [0 max(image2x2Bin(:))/100]); % draw the basic moduleOutputImage with scaled color map
    title('binned moduleOutputImage');
end

% bounding box of moduleOutputImage of allowed locations of background apertures
imageBoundingBox = [maskedSmear + 1, maskedSmear + nRowPix - 1, leadingBlack + 1, leadingBlack + nColPix - 1];
% find row and columns of background aperture for each intersection on grid
backApRow = zeros(nLinesRow, nLinesCol);
backApCol = zeros(nLinesRow, nLinesCol);
for i=1:nLinesRow
    for j=1:nLinesCol
        [backApRow(i,j), backApCol(i,j)] = ...
            find_good_background_ap(backSeedRow(i), backSeedCol(j), ...
            moduleOutputImage, image2x2Bin, backgroundThreshold, imageBoundingBox);
    end
end

% create the target definitions for the output
targetNum = 1;
for i=1:nLinesRow
    for j=1:nLinesCol
        bpaObject.targetDefinition(targetNum).keplerId = targetNum;
        bpaObject.targetDefinition(targetNum).referenceRow = backApRow(i,j);
        bpaObject.targetDefinition(targetNum).referenceColumn = backApCol(i,j);
        bpaObject.targetDefinition(targetNum).maskIndex = 1; % in matlab 1-base counting
        bpaObject.targetDefinition(targetNum).excessPixels = 0;
        bpaObject.targetDefinition(targetNum).status = 0; 
        targetNum = targetNum + 1;
    end
end

% define and return the 2x2 mask used by this algorithm
bpaObject.maskDefinitions(1).offsets(1) = struct('row', -1, 'column', -1);
bpaObject.maskDefinitions(1).offsets(2) = struct('row', -1, 'column', 0);
bpaObject.maskDefinitions(1).offsets(3) = struct('row', 0, 'column', -1);
bpaObject.maskDefinitions(1).offsets(4) = struct('row', 0, 'column', 0);

if (debugFlag)
    % draw background aps for debugging
    % moduleOutputImage with background apertures only
    backPix = zeros(size(moduleOutputImage));
    for i=1:nLinesRow
        for j=1:nLinesCol

            backPix(backApRow(i,j)-1,backApCol(i,j)-1) = backPixDrawVal;
            backPix(backApRow(i,j)-1,backApCol(i,j)) = backPixDrawVal;
            backPix(backApRow(i,j),backApCol(i,j)-1) = backPixDrawVal;
            backPix(backApRow(i,j),backApCol(i,j)) = backPixDrawVal;
        end
    end
    figure;
    colormap hot(256);
    imagesc(moduleOutputImage + backPix, [0 backPixDrawVal/100]); % draw the basic moduleOutputImage + background aps with scaled color map
    hold on;
    % draw the grid;
    for i=1:nLinesRow
        line([lineStartCol, lineEndCol], [backSeedRow(i), backSeedRow(i)], 'Color', 'g');
    end
    for i=1:nLinesCol
        line([backSeedCol(i), backSeedCol(i)], [lineStartRow, lineEndRow], 'Color', 'g');
    end
    % draw a little line in the background aps to distinguish them from stars
    for i=1:nLinesRow
        for j=1:nLinesCol
            if test_background_ap(backApRow(i,j), backApCol(i,j), moduleOutputImage, binCenter + binSize/2)
                colorval = 'b'; % blue for good aps
            else
                colorval = 'r'; % red for bad aps
            end
            line([backApCol(i,j) backApCol(i,j)-1], [backApRow(i,j) backApRow(i,j)], 'Color', colorval);
        end
    end
    
    figure;
    for i=1:nLinesRow
        for j=1:nLinesCol
            backValues(i,j) = moduleOutputImage(backApRow(i,j), backApCol(i,j));
        end
    end
    plot3(backApRow, backApCol, backValues, 'd');
    xlabel('Row');
    ylabel('Column');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function isBackground = test_background_ap(row, col, moduleOutputImage, maxVal)
%
% check that all four pixels in the 2x2 background ap in the moduleOutputImage 
% have values below background flux threshold maxVal
%
%   inputs: 
%       row, col location of aperture
%       moduleOutputImage array of pixel values
%       maxVal background threshold value
%
%   output: 
%       isBackground boolean indicating whether all pixels are background
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function isBackground = test_background_ap(row, col, moduleOutputImage, maxVal)
if (moduleOutputImage(row,col) > maxVal ...
        || moduleOutputImage(row-1, col) > maxVal ...
        || moduleOutputImage(row, col-1) > maxVal ...
        || moduleOutputImage(row-1, col-1) > maxVal)
    isBackground = 0;
else
    isBackground = 1;
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function grid = make_stretched_grid(nLines, nEdge, lineStart, lineEnd, edgeFraction)
%
% make a cartesian one-D grid with higher density at edges
%
%   inputs: 
%       nLines # of grid nodes in grid
%       nEdge # of grid nodes in high-density region
%       lineStart lineEnd starting and ending points of grid%
%       edgeFraction fraction of grid that is high density
%
%   output: 
%       grid stretched one D grid
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function grid = make_stretched_grid(nLines, nEdge, lineStart, lineEnd, edgeFraction)
nCenter = (nLines - 2*nEdge); % # of points in center region
iEdge = round((lineEnd - lineStart)*edgeFraction); % distance from edge of boundary between edge and center region
grid = zeros(nLines, 1);
% i = 1;
for k=1:nEdge % set points for edge region
%     grid(i) = round(lineStart + (iEdge)*((k-1)/(nEdge-1)));
%     i = i+1;

    grid(1:nEdge+1) = linspace(lineStart, lineStart+iEdge, nEdge+1);
end
for k=1:nCenter % set points for center region
%     grid(i) = round(lineStart + iEdge + (lineEnd - iEdge - (lineStart + iEdge))*((k-1)/(nCenter)));
%     i = i+1;

    grid(nEdge + 1:nEdge + nCenter) = linspace(lineStart+iEdge, lineEnd-iEdge, nCenter);
end
for k=1:nEdge % set points for edge region
%     grid(i) = round(lineEnd - iEdge + (lineEnd - (lineEnd - iEdge))*((k-1)/(nEdge-1)));
%     i = i+1;

    grid(nEdge + nCenter:nLines) = linspace(lineEnd - iEdge, lineEnd, nEdge+1);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function [row,col] = find_good_background_ap(row, col, moduleOutputImage
%   image2x2Bin, maxVal, imageBoundingBox)
%
% find background aperture by searching outwards from initial point (row,
% col) a certain distance.  Uses 2x2 binned moduleOutputImage "image2x2Bin" to estimate 
% a good background ap
%
%   inputs: 
%       row, col starting point of search
%       moduleOutputImage array of pixel values
%       image2x2Bin array of binned pixel values
%       maxVal background threshold value
%       imageBoundingBox domain within which to search
%
%   output: 
%       grid stretched one D grid
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [row,col] = find_good_background_ap(row, col, moduleOutputImage, ...
    image2x2Bin, maxVal, imageBoundingBox)
bestRow = row;
bestCol = col;
bestVal = inf;
while test_background_ap(row, col, moduleOutputImage, maxVal) == 0 % while we still haven't found a good background ap
    % look in increasingly large boxes for a min value but don't get too big
    if row > 70 && row < 90 && col > 1100 && col < 1112
        disp('here');
    end
    for searchSize = 2:10 % range of square to search (side = 2*searchSize)
        rowLow = row-searchSize;
        if rowLow < imageBoundingBox(1) + 2 % add 2 to account for searchSize of 2x2 ap
            rowLow = imageBoundingBox(1) + 2; 
        end
        rowHigh = row+searchSize;
        if rowHigh > imageBoundingBox(2) - 2
            rowHigh = imageBoundingBox(2) - 3; 
        end
        colLow = col-searchSize;
        if colLow < imageBoundingBox(3) + 2 
            colLow = imageBoundingBox(3) + 2; 
        end
        colHigh = col+searchSize;
        if colHigh > imageBoundingBox(4) - 2
            colHigh = imageBoundingBox(4) - 3; 
        end
        
        % look for good 2x2 ap
        % look at the 2x2 binned moduleOutputImage to find the minimum in
        % the current search box, as a place to start our search
        [minrowval minrowindex] = min(image2x2Bin(rowLow:rowHigh,colLow:colHigh),[],1); 
        [mincolval mincolindex] = min(minrowval);
        if mincolval < bestVal
            bestRowCandidate = rowLow + minrowindex(mincolindex);
            bestColCandidate = colLow + mincolindex;
            bestValCandidate = mincolval;
            % check to see if this ap is on visible pixels
            if bestRowCandidate > imageBoundingBox(1)+1 ...
                    && bestRowCandidate < imageBoundingBox(2)-1 ...
                    && bestColCandidate > imageBoundingBox(3)+1 ...
                    && bestColCandidate < imageBoundingBox(4)-1
                bestRow = bestRowCandidate;
                bestCol = bestColCandidate;
                bestVal = bestValCandidate;
                % check to see if this ap is really good
                if test_background_ap(bestRow, bestCol, moduleOutputImage, maxVal)
                    break;
                end
            end
        end
    end
    row = bestRow;
    col = bestCol;
    if searchSize == 10
        return;
    end
end




