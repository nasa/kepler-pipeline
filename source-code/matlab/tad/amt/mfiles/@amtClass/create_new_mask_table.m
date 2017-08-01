function amtObject = create_new_mask_table(amtObject)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function amtObject = create_new_mask_table(amtObject)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function which makes pre-defined geometrical aperture masks of various shapes
% 
% sets the array of structs amtObject.maskDefinitions, which is described in
% amtClass.m
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

% get various fields of the amtObject
maxMasks = amtObject.maskTableParametersStruct.nStellarMasks; % maximum number of masks to make
maxMasksToCreate = 2000; % maximum number of masks to create, will be trimmed to maxMasks after
                                % removing duplicates
maxPixelsInMask = amtObject.amtConfigurationStruct.maxPixelsInMask; % 85
maxMaskRows = amtObject.amtConfigurationStruct.maxMaskRows; % 11
maxMaskCols = amtObject.amtConfigurationStruct.maxMaskCols; % 11
centerRow = amtObject.amtConfigurationStruct.centerRow;  % 6
centerCol = amtObject.amtConfigurationStruct.centerCol; % 6
minEccentricity = amtObject.amtConfigurationStruct.minEccentricity; % 0.4
maxEccentricity = amtObject.amtConfigurationStruct.maxEccentricity; % 0.9
stepEccentricity = amtObject.amtConfigurationStruct.stepEccentricity; % 0.1
stepInclination = amtObject.amtConfigurationStruct.stepInclination; % 0.1

% pre-allocate results structure
apertureMaskStruct = repmat(struct( ...
    'defined', 0, ...
    'mask', zeros(maxMaskRows,maxMaskCols), ...
    'nPix', 0, ...
    'center', [centerRow centerCol], ...
    'size', [0 0], ...
    'boundingBox', [0 0; 0 0]), 1, maxMasksToCreate);

maskCount = 1;

% first we generate all the mask images as 2D arrays.  Will convert to
% aperture definitions at the end
% accumulate masks into list apertureMaskStruct

% generate all rectangle shapes that contain less than maxPixelsInMask pixels
centerMaxPix = ceil(maxPixelsInMask/2);
% run through row sizes
for i=1:maxPixelsInMask
    if maskCount > maxMasksToCreate
        break;
    end
    % run through column sizes
    for j=1:maxPixelsInMask
        if maskCount > maxMasksToCreate
            break;
        end
        % if this mask doees not contain too many pixels
        if (i*j <= maxPixelsInMask)
            apertureMaskStruct(maskCount).mask = zeros(maxPixelsInMask,maxPixelsInMask);
            for ii = 1:i
                for jj = 1:j
                    % compute coordinates of this pixel
                    pxi = centerMaxPix - floor(i/2) + ii - 1;
                    pxj = centerMaxPix - floor(j/2) + jj - 1;
                    apertureMaskStruct(maskCount).mask(pxi,pxj) = 1;
                end
            end
            % if this mask is not already defined
            if find_equal_mask(apertureMaskStruct(maskCount), apertureMaskStruct) == -1
                apertureMaskStruct(maskCount).defined = 1;
                % set center for display purposes
                apertureMaskStruct(maskCount).center = [centerMaxPix, centerMaxPix];
                % set number of pixels
                apertureMaskStruct(maskCount).nPix = i*j;
                % get useful data like bounding box, area of bounding box (maskArea)
                % and linear size of bounding box (dx, dy)
                [maskArea, dx, dy, boundingBox] = square_ap(apertureMaskStruct(maskCount).mask);
                apertureMaskStruct(maskCount).size = [dx dy];
                apertureMaskStruct(maskCount).boundingBox = [boundingBox(1,1) - centerMaxPix, ...
                    boundingBox(1,2) - centerMaxPix; boundingBox(2,1) - centerMaxPix, ...
                    boundingBox(2,2) - centerMaxPix];

                maskCount = maskCount + 1;
            end
        end
    end
end

% generate all rectangles with 4 corners missing that fit into maxMaskRows x 
% maxMaskCols and contain less than maxPixelsInMask pixels
for i=2:maxMaskRows-2
    if maskCount > maxMasksToCreate
        break;
    end
    for j=2:maxMaskCols-2
        if maskCount > maxMasksToCreate
            break;
        end
        % create rectangular mask 2 pixels smaller on each side
        for ii = 1:i
            for jj = 1:j
                pxi = centerRow - floor(i/2) + ii - 1;
                pxj = centerCol - floor(j/2) + jj - 1;
                apertureMaskStruct(maskCount).mask(pxi,pxj) = 1;
            end
        end
        % add row/columns to each side and above and below
        for ii = 2:i-1
            pxi = centerRow - floor(i/2) + ii - 1;
            pxj = centerCol - floor(j/2) + 1 - 2; 
            apertureMaskStruct(maskCount).mask(pxi,pxj) = 1;
            pxj = centerCol - floor(j/2) + j; 
            apertureMaskStruct(maskCount).mask(pxi,pxj) = 1;
        end
        
        % as in rectangle case
        if sum(sum(apertureMaskStruct(maskCount).mask)) <= maxPixelsInMask
            [apertureMaskStruct(maskCount) maskCount] = ...
                set_mask_parameters(apertureMaskStruct(maskCount), ...
                apertureMaskStruct, centerRow, centerCol, maskCount);
        else
            apertureMaskStruct(maskCount).mask = zeros(maxMaskRows, maxMaskCols);
        end
    end
end

% generate all rectangles with 2 left side corners missing that fit into maxMaskRows x 
% maxMaskCols and contain less than maxPixelsInMask pixels
for i=2:maxMaskRows-2
    if maskCount > maxMasksToCreate
        break;
    end
    for j=2:maxMaskCols-2
        if maskCount > maxMasksToCreate
            break;
        end
        % create rectangular mask 2 pixels smaller on each side
        for ii = 1:i
            for jj = 1:j
                pxi = centerRow - floor(i/2) + ii - 1;
                pxj = centerCol - floor(j/2) + jj - 1;
                apertureMaskStruct(maskCount).mask(pxi,pxj) = 1;
            end
        end
        % add a column to the left side
        for ii = 2:i-1
            pxi = centerRow - floor(i/2) + ii - 1;
            pxj = centerCol - floor(j/2) + 1 - 2; 
            apertureMaskStruct(maskCount).mask(pxi,pxj) = 1;
        end
        
        % as in rectangle case
        if sum(sum(apertureMaskStruct(maskCount).mask)) <= maxPixelsInMask
            [apertureMaskStruct(maskCount) maskCount] = ...
                set_mask_parameters(apertureMaskStruct(maskCount), ...
                apertureMaskStruct, centerRow, centerCol, maskCount);
        else
            apertureMaskStruct(maskCount).mask = zeros(maxMaskRows, maxMaskCols);
        end
    end
end

% generate all rectangles with 2 right side corners missing that fit into maxMaskRows x 
% maxMaskCols and contain less than maxPixelsInMask pixels
for i=2:maxMaskRows-2
    if maskCount > maxMasksToCreate
        break;
    end
    for j=2:maxMaskCols-2
        if maskCount > maxMasksToCreate
            break;
        end
        % create rectangular mask 2 pixels smaller on each side
        for ii = 1:i
            for jj = 1:j
                pxi = centerRow - floor(i/2) + ii - 1;
                pxj = centerCol - floor(j/2) + jj - 1;
                apertureMaskStruct(maskCount).mask(pxi,pxj) = 1;
            end
        end
        % add a column to the right side
        for ii = 2:i-1
            pxi = centerRow - floor(i/2) + ii - 1;
            pxj = centerCol - floor(j/2) + j; 
            apertureMaskStruct(maskCount).mask(pxi,pxj) = 1;
        end
        
        % as in rectangle case
        if sum(sum(apertureMaskStruct(maskCount).mask)) <= maxPixelsInMask
            [apertureMaskStruct(maskCount) maskCount] = ...
                set_mask_parameters(apertureMaskStruct(maskCount), ...
                apertureMaskStruct, centerRow, centerCol, maskCount);
        else
            apertureMaskStruct(maskCount).mask = zeros(maxMaskRows, maxMaskCols);
        end
    end
end

% generate all rectangles with 2 top corners missing that fit into maxMaskRows x 
% maxMaskCols and contain less than maxPixelsInMask pixels
for i=2:maxMaskRows-2
    if maskCount > maxMasksToCreate
        break;
    end
    for j=2:maxMaskCols-2
        if maskCount > maxMasksToCreate
            break;
        end
        % create rectangular mask 2 pixels smaller on each side
        for ii = 1:i
            for jj = 1:j
                pxi = centerRow - floor(i/2) + ii - 1;
                pxj = centerCol - floor(j/2) + jj - 1;
                apertureMaskStruct(maskCount).mask(pxi,pxj) = 1;
            end
        end
        % add a row to the top
        for jj = 2:j-1
            pxi = centerRow - floor(i/2) + 1 - 2;
            pxj = centerCol - floor(j/2) + jj - 1; 
            apertureMaskStruct(maskCount).mask(pxi,pxj) = 1;
        end
        
        % as in rectangle case
        if sum(sum(apertureMaskStruct(maskCount).mask)) <= maxPixelsInMask
            [apertureMaskStruct(maskCount) maskCount] = ...
                set_mask_parameters(apertureMaskStruct(maskCount), ...
                apertureMaskStruct, centerRow, centerCol, maskCount);
        else
            apertureMaskStruct(maskCount).mask = zeros(maxMaskRows, maxMaskCols);
        end
    end
end

% generate all rectangles with 2 bottom corners missing that fit into maxMaskRows x 
% maxMaskCols and contain less than maxPixelsInMask pixels
for i=2:maxMaskRows-2
    if maskCount > maxMasksToCreate
        break;
    end
    for j=2:maxMaskCols-2
        if maskCount > maxMasksToCreate
            break;
        end
        % create rectangular mask 2 pixels smaller on each side
        for ii = 1:i
            for jj = 1:j
                pxi = centerRow - floor(i/2) + ii - 1;
                pxj = centerCol - floor(j/2) + jj - 1;
                apertureMaskStruct(maskCount).mask(pxi,pxj) = 1;
            end
        end
        % add a row to the bottom
        for jj = 2:j-1
            pxi = centerRow - floor(i/2) + i;
            pxj = centerCol - floor(j/2) + jj - 1; 
            apertureMaskStruct(maskCount).mask(pxi,pxj) = 1;
        end
        
        % as in rectangle case
        if sum(sum(apertureMaskStruct(maskCount).mask)) <= maxPixelsInMask
            [apertureMaskStruct(maskCount) maskCount] = ...
                set_mask_parameters(apertureMaskStruct(maskCount), ...
                apertureMaskStruct, centerRow, centerCol, maskCount);
        else
            apertureMaskStruct(maskCount).mask = zeros(maxMaskRows, maxMaskCols);
        end
    end
end

% generate all circle shapes that fit into maxMaskRows x 
% maxMaskCols and contain less than maxPixelsInMask pixels
for radius=1:fix(maxMaskRows/2)
    if maskCount > maxMasksToCreate
        break;
    end
    for i=1:maxMaskRows
        for j=1:maxMaskCols
            di = centerRow - i;
            dj = centerCol - j;
            % turn the pixel on if it is within the radius from the center
            if sqrt(di*di + dj*dj) <= radius
                apertureMaskStruct(maskCount).mask(i,j) = 1;
            end
        end
    end
    if sum(sum(apertureMaskStruct(maskCount).mask)) <= maxPixelsInMask
        [apertureMaskStruct(maskCount) maskCount] = ...
            set_mask_parameters(apertureMaskStruct(maskCount), ...
            apertureMaskStruct, centerRow, centerCol, maskCount);
    else
        apertureMaskStruct(maskCount).mask = zeros(maxMaskRows, maxMaskCols);
    end
end

% generate all ellipse shapes that fit into maxMaskRows x 
% maxMaskCols and contain less than maxPixelsInMask pixels
% first increment through possible eccentricities
for eccentricity = minEccentricity:stepEccentricity:maxEccentricity
    if maskCount > maxMasksToCreate
        break;
    end
    % increment through several axis angles
    for angle = 0:stepInclination:2*pi
        if maskCount > maxMasksToCreate
            break;
        end
        % increment through several radii
        for radius=1:max([maxMaskRows maxMaskCols])-1
            if maskCount > maxMasksToCreate
                break;
            end
            for i=1:maxMaskRows
                for j=1:maxMaskCols
                    di = centerRow - i;
                    dj = centerCol - j;
                    % convert to polar coordinates
                    % equation of ellipse in polar coordinates is
                    % r < R*(1-e^2)/(1+e*cos(theta))
                    % where R is the variable radius of the ellipse and 
                    % theta is the sum of variables angle + thetai.  
                    ri = sqrt(di*di + dj*dj); % radius of this pixel
                    if di ~= 0
                        thetai = atan(dj/di); % angle of this pixel
                    else
                        thetai = pi/2;
                    end
                    % see if this pixel is inside ellipse
                    if radius*(1-eccentricity*eccentricity)/(1+eccentricity*cos(thetai + angle)) > ri
                        apertureMaskStruct(maskCount).mask(i,j) = 1;
                    end
                end
            end
            if sum(sum(apertureMaskStruct(maskCount).mask)) <= maxPixelsInMask
                [apertureMaskStruct(maskCount) maskCount] = ...
                    set_mask_parameters(apertureMaskStruct(maskCount), ...
                    apertureMaskStruct, centerRow, centerCol, maskCount);
            else
                apertureMaskStruct(maskCount).mask = zeros(maxMaskRows, maxMaskCols);
            end
        end
    end
end

% now convert masks into aperture definitions
nMasksCreated = maskCount;
for m = 1:nMasksCreated
    if apertureMaskStruct(m).defined == 1
        apertureMaskStruct(m).targetDefinitionStruct = ...
            image_to_target_definition(apertureMaskStruct(m).mask, ...
            apertureMaskStruct(m).center);
        maskDefinitions(m) = apertureMaskStruct(m).targetDefinitionStruct;
    end
end

% trim duplicates: the above method of removing duplicates fails when the
% underlying mask has different sizes where the difference is all zero.
% Here we trim duplicates based on target definitions
maskDefinitions = find_unique_apertures(maskDefinitions);
% trim to the maximum number of masks requested
maskDefinitions = maskDefinitions(1:maxMasks);

 
% set the output
amtObject.MaskTableStruct = apertureMaskStruct(1:nMasksCreated); % trim to the number actually created with duplicates
amtObject.maskDefinitions = maskDefinitions;
% for some reason the replaced masks will be single precision, and mixed
% types makes later code upset.  Therefore we do the following.
for m = 1:length(amtObject.maskDefinitions)
    for i=1:length(amtObject.maskDefinitions(m).offsets)
        amtObject.maskDefinitions(m).offsets(i).row = ...
            double(amtObject.maskDefinitions(m).offsets(i).row);
        amtObject.maskDefinitions(m).offsets(i).column = ...
            double(amtObject.maskDefinitions(m).offsets(i).column);
    end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function [area, dx, dy, boundingBox] = square_ap(ap)
%
% return the properties of the bounding box of the non-zero pixels in the
% mask such as area, linear size and coordinates of box.
%
%   inputs: 
%       apertureMaskStruct structure in which to set various parameters
%       centerRow, centerCol center row and column of mask
%       maskCount index of this mask
%
%   output: 
%       apertureMaskStruct structure in which to set various parameters
%       maskCount index of this mask
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [apertureMaskStruct maskCount] = ...
    set_mask_parameters(apertureMaskStruct, apertureMaskList, ...
    centerRow, centerCol, maskCount)
if find_equal_mask(apertureMaskStruct, apertureMaskList) == -1
    % this mask is new so define it
    apertureMaskStruct.defined = 1;
    % set number of pixels
    apertureMaskStruct.nPix = sum(sum(apertureMaskStruct.mask));
    % get useful data like bounding box, area of bounding box (maskArea)
    % and linear size of bounding box (dx, dy)
    [maskArea, dx, dy, boundingBox] = square_ap(apertureMaskStruct.mask);
    % set the area of the mask (= # of pixels in bounding box)
    apertureMaskStruct.size = [dx dy];
    % offset the bounding box
    apertureMaskStruct.boundingBox = [boundingBox(1,1) - centerRow, ...
        boundingBox(1,2) - centerRow; boundingBox(2,1) - centerCol, ...
        boundingBox(2,2) - centerCol];

    maskCount = maskCount + 1;
end


