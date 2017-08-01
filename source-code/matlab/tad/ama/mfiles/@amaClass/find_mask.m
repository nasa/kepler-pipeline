function [status, assignedMaskStruct] = find_mask(amaObject, targetStruct, ...
    pixStruct, ap, apCenter, ...
    maskDefinitions, assignedMaskStruct, recursionCount)
% function [status, assignedMaskStruct] = find_mask(ap, apCenter, maskDefinitions, assignedMaskStruct)
%
% find the set of masks that best fit the intput aperture, with best being
% characterized as the mask enclosing the desired aperture with the smallest number
% of pixels.  Recursively subdivides the input aperture if no mask is
% found.
%
%   inputs: 
%       ap aperture to be assigned mask(s)
%       apCenter the assigned center of the aperture
%       maskDefinitions struct array containing mask data (see calling
%           routine for contents of struct)
%       assignedMaskStruct struct array of masks already assigned to this
%           aperture.  This field is empty when calling this function
%           (first invocation in the recursion).
%       recursionCount integer that counts the number of recursions of this
%           funtion.  Used to bail if there are too many recursions
%
%   output: 
%       status indicating whether a mask was successfully assigned: 1 on
%           successful assignment, -1 on failure
%       assignedMaskStruct struct array of masks assigned to this
%           aperture
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% check to see that ap is not all zero (no pixels in the aperture)
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
if sum(sum(ap)) == 0
	status = 1; % nothing to do with this aperture
	return;
end
	
recursionCount = recursionCount + 1;
% if recursionCount > 1
%     disp(['recursionCount = ' num2str(recursionCount)]);
% end
nMasks = length(maskDefinitions);
nOffsets = sum(sum(ap)); % # of pixels in the input aperture
leastpix = inf; % The smallest # of pixels found so far (initialized large)
status = -1; % failure condition
if isempty(assignedMaskStruct) % top-level call of this routine, initialize output fields
    assignedMaskStruct.numMasks = 0; % allows for the possibility of multiple masks to be assigned to this target
    assignedMaskStruct.componentMasks(1).mask = [];
    assignedMaskStruct.componentMasks(1).maskIndex = 0;
    assignedMaskStruct.componentMasks(1).center = [0 0];
end

targetRefPix = [targetStruct.referenceRow, targetStruct.referenceColumn];
[area, numRowsInAp, numColsInAp, apertureBoundingBox] = square_ap(ap); % find the bounding box of the ap
targetApOnVisiblePixels = check_ap_on_visible_pixels(apertureBoundingBox,  ...
    apCenter, targetRefPix, pixStruct);
% if ~targetApOnVisiblePixels
%     status = -2;
% end
for m = 1:nMasks % for each mask in the aperture mask table, in order of number of offsets
% attempt to do the mask assignment via conv2
    if maskDefinitions(m).nOffsets >= nOffsets % the aperture mask has to have at least the same number of pixels as the input ap
        % have to make sure the dimensions of the bounding box of the ap are not larger 
        % than that of the mask
        if (numRowsInAp <= maskDefinitions(m).size(1) && numColsInAp <= maskDefinitions(m).size(2))
            convCount = conv2(rot90(ap,2),maskDefinitions(m).mask);
            if max(max(convCount)) == nOffsets 
                % every pixel in the aperture is in the mask, so compute
                % the offset by taking the centroid of convoluted values
                % equal to nOffsets
                [nRows, nCols] = size(convCount);
                goodFit = convCount == nOffsets;
                % try to find a good fit near the center of the mask, use
                % the centroid of the good fit pixels
                maxRow = round(sum(sum(goodFit,2).*(1:nRows)') / sum(sum(goodFit,2)));
                maxCol = round(sum(sum(goodFit,1).*(1:nCols)) / sum(sum(goodFit,1)));
               
                [goodFitRow goodFitCol] = find(goodFit);
                % sort the good fit entries by increasing distance from the
                % good fit centroid, and pick the first mask that contains the ap
                % which will be closest to the good fit centroid
                [goodFitDist goodFitDistIdx] = sort(sqrt((goodFitRow - maxRow).^2 + (goodFitCol - maxCol).^2));
				maskOffset = - round([nRows, nCols]/2) ... % gives the offset of the match from the center of the convolution
                    + fix((size(maskDefinitions(m).mask) - size(ap))/2) ...
                    + apCenter - maskDefinitions(m).center; % offset between the mask centers
                for gfi = 1:length(goodFitDistIdx)
                    centerOffset = [goodFitRow(goodFitDistIdx(gfi)), goodFitCol(goodFitDistIdx(gfi))] ...
                        + maskOffset;
                    if check_ap_on_visible_pixels( ... % while the aperture is not on visible pixels
                        maskDefinitions(m).apertureBoundingBox, ...
                        maskDefinitions(m).center, targetRefPix - centerOffset, pixStruct)
                        break;
                    end
					% didn't find one, pick the mask that centers the target
                    centerOffset = [goodFitRow(goodFitDistIdx(1)), goodFitCol(goodFitDistIdx(1))] ...
                        + maskOffset;
                end

                if ~targetApOnVisiblePixels || check_ap_on_legal_pixels( ... % if the mask is on legal pixels
                        maskDefinitions(m).apertureBoundingBox, ...
                        maskDefinitions(m).center, targetRefPix - centerOffset, pixStruct)
                    assignedMaskStruct.componentMasks(assignedMaskStruct.numMasks + 1).mask = maskDefinitions(m).mask; % put in return list in new mask slot
                    assignedMaskStruct.componentMasks(assignedMaskStruct.numMasks + 1).maskIndex = maskDefinitions(m).maskIndex;
                    assignedMaskStruct.componentMasks(assignedMaskStruct.numMasks + 1).centerOffset = centerOffset;
                    assignedMaskStruct.componentMasks(assignedMaskStruct.numMasks + 1).numPixInAp = nOffsets;
                    assignedMaskStruct.componentMasks(assignedMaskStruct.numMasks + 1).numPixInMask = maskDefinitions(m).nOffsets;
                    status = 1;
                    break;
                end
            end
        end
    end
end

if status == 1 % found a mask so reflect in return list
    assignedMaskStruct.numMasks = assignedMaskStruct.numMasks + 1;
elseif recursionCount <= 7 % 7 masks splits is 2^7 = 128 masks
% didn't find a mask, subdivide the input aperture and call for the two
% parts
    if numRowsInAp < numColsInAp % subdivide along columns
        subap1 = ap(:,1:fix(numColsInAp/2));
        subap2 = ap(:,fix(numColsInAp/2)+1:end);
        if ~isempty(subap1)
            % we have to account for the possibility that for disconnected apertures the split
            % aperture may have zero pixels around the actual remaining ap.
            % So compute the offset to the non-zero pixels in the
            % appropriate direction
            [r, c] = find(subap1 == 1);
            deltaCol = min(c) - 1;
            subapTdef1 = image_to_target_definition(subap1, apCenter);
            [subap1, apCenter1] = target_definition_to_image(subapTdef1);
            [status, assignedMaskStruct] = find_mask(amaObject, targetStruct, pixStruct, subap1, ...
                [apCenter1(1), apCenter(2) - deltaCol], maskDefinitions, ...
                assignedMaskStruct, recursionCount);
        end
        if ~isempty(subap2)
            [r, c] = find(subap2 == 1);
            deltaCol = min(c) - 1;
            subapTdef2 = image_to_target_definition(subap2, apCenter);
            [subap2, apCenter2] = target_definition_to_image(subapTdef2);
            [status, assignedMaskStruct] = find_mask(amaObject, targetStruct, pixStruct, subap2, ...
                [apCenter2(1), apCenter(2) - fix(numColsInAp/2) - deltaCol], maskDefinitions, ...
                assignedMaskStruct, recursionCount);
        end
    else % subdivide along rows
        subap1 = ap(1:fix(numRowsInAp/2), :);
        subap2 = ap(fix(numRowsInAp/2)+1:end, :);
        if ~isempty(subap1)
            [r, c] = find(subap1 == 1);
            deltaRow = min(r) - 1;
            subapTdef1 = image_to_target_definition(subap1, apCenter);
            [subap1, apCenter1] = target_definition_to_image(subapTdef1);
            [status, assignedMaskStruct] = find_mask(amaObject, targetStruct, pixStruct, subap1, ...
                [apCenter(1) - deltaRow, apCenter1(2)], maskDefinitions, ...
                assignedMaskStruct, recursionCount);
        end
        if ~isempty(subap2)
            [r, c] = find(subap2 == 1);
            deltaRow = min(r) - 1;
            subapTdef2 = image_to_target_definition(subap2, apCenter);
            [subap2, apCenter2] = target_definition_to_image(subapTdef2);
            [status, assignedMaskStruct] = find_mask(amaObject, targetStruct, pixStruct, subap2, ...
                [apCenter(1) - fix(numRowsInAp/2) - deltaRow, apCenter2(2)], maskDefinitions, ...
                assignedMaskStruct, recursionCount);
        end
    end
end
% check to see if optimal ap comes too close to the edge of the visible
% pixels
closeToVisiblePixelEdge = check_ap_on_visible_pixels(apertureBoundingBox,  ...
    apCenter, targetRefPix, pixStruct, 2);

% set status to -3 if the optimal aperture fell off visible pixels
if status ~= -1 && ~closeToVisiblePixelEdge
    status = -3;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% status = check_ap_on_visible_pixels(ap, apCenter, refPix, pixStruct)
%
% make sure all pixels on a mask are in the legal range of >= 0 and <= 1069
%
%   inputs: 
%       apBoundingBox bounding box of image of aperture in image coordiantes: 
%           [minRow, maxRow, minCol, maxCol]
%       apCenter [row, column] of center pixel in ap image coordinates
%       refPix [row, column] of apCenter in CCD coordinates
%       pixStruct structure containing CCD size information
%
%   output: 
%       status 1 if ap is on visible pixels, 0 otherwise
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function status = check_ap_on_visible_pixels(apBoundingBox, apCenter, refPix, pixStruct, buffer)
if nargin < 5
    buffer = 0;
end

status = 1; % default to on pixels
minApRow = refPix(1) + apBoundingBox(1,1) - apCenter(1);
maxApRow = refPix(1) + apBoundingBox(1,2) - apCenter(1);
minApCol = refPix(2) + apBoundingBox(2,1) - apCenter(2);
maxApCol = refPix(2) + apBoundingBox(2,2) - apCenter(2);

minVisRow = pixStruct.maskedSmear + 1 + buffer;
maxVisRow = pixStruct.maskedSmear + pixStruct.nRowPix - buffer;
minVisCol = pixStruct.leadingBlack + 1 + buffer;
maxVisCol = pixStruct.leadingBlack + pixStruct.nColPix - buffer;
if minApRow < minVisRow || maxApRow > maxVisRow || minApCol < minVisCol || maxApCol > maxVisCol
    status = 0;
end

function status = check_ap_on_legal_pixels(apBoundingBox, apCenter, refPix, pixStruct, buffer)
if nargin < 5
    buffer = 0;
end

status = 1; % default to on pixels
minApRow = refPix(1) + apBoundingBox(1,1) - apCenter(1);
maxApRow = refPix(1) + apBoundingBox(1,2) - apCenter(1);
minApCol = refPix(2) + apBoundingBox(2,1) - apCenter(2);
maxApCol = refPix(2) + apBoundingBox(2,2) - apCenter(2);

minVisRow = 1 + buffer;
maxVisRow = pixStruct.maskedSmear + pixStruct.nRowPix + pixStruct.maskedSmear - buffer;
minVisCol = 1 + buffer;
maxVisCol = pixStruct.leadingBlack + pixStruct.nColPix + pixStruct.trailingBlack - buffer;
if minApRow < minVisRow || maxApRow > maxVisRow || minApCol < minVisCol || maxApCol > maxVisCol
    status = 0;
end

