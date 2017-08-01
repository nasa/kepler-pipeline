function ccdObject = identify_bad_fit_regions(ccdObject)
% function ccdObject = identify_bad_fit_regions(ccdObject)
% 
% identify pixels that are not well fit by polynomials and/or are in
% saturation.  We do this by generating an image using the
% ccdPixelPoly, prior to ccd effects, applying pixel effects to that
% image and comparing with an image generated using the
% ccdPixelEffectsPoly. The result is a collection of pixels that must be
% treated specially, which are collected into distinct, disjoint
% rectangular partitions, whose data is set in the badFitPixelStruct field.
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

% return an empty structure if this is short cadence
if strcmp(get(ccdObject.runParamsClass, 'cadenceType'), 'short')
    ccdObject.badFitPixelStruct = [];
    return;
end

if exist(ccdObject.badFitPixelStructFilename, 'file')
	load(ccdObject.badFitPixelStructFilename);
	ccdObject.badFitPixelStruct = badFitPixelStruct;
	return;
end

runParamsObject = ccdObject.runParamsClass;
numVirtualSmear = get(runParamsObject, 'numVirtualSmear');
numMaskedSmear = get(runParamsObject, 'numMaskedSmear');
numLeadingBlack = get(runParamsObject, 'numLeadingBlack');
virtualSmearStart = get(runParamsObject, 'virtualSmearStart');
trailingBlackStart = get(runParamsObject, 'trailingBlackStart');
numCcdRows = get(runParamsObject, 'numCcdRows');
numCcdCols = get(runParamsObject, 'numCcdCols');
saturationBoxSize = get(runParamsObject, 'saturationBoxSize');
exposuresPerCadence = get(runParamsObject, 'exposuresPerCadence');
badFitTolerance = get(runParamsObject, 'badFitTolerance');
wellCapacity = get(get(ccdObject, 'electronsToAduObject'), 'maxElectronsPerExposure')*exposuresPerCadence; % we're working here with single exposures
% include variation in well depth
wellCapacity = wellCapacity*get(ccdObject, 'wellDepthVariation');


pixelEffectObjectList = get(ccdObject, 'pixelEffectObjectList');

% first build image without saturation spill and other effects
standardImage = 0;
for plane=1:length(ccdObject.ccdPlaneObjectList)
    standardImage = standardImage + render_ccd(ccdObject.ccdPlaneObjectList(plane), ...
        ccdObject, 1, 'prePixelEffects');
end

% now apply the effects directly in image space
% Find the saturated pixels
[satRow, satCol] = find(standardImage > wellCapacity);

% spill saturation
% note that saturated charge cannot spill into the virtual rows
% but CAN spill onto the masked rows
standardImage(1:virtualSmearStart-1, satCol) = ...
    spill_saturation(ccdObject, standardImage(1:virtualSmearStart-1, satCol), ...
    exposuresPerCadence, 1:virtualSmearStart-1, satCol);

% apply pixel-level effects
for effect = 1:length(pixelEffectObjectList)
    standardImage ...
        = apply_pixel_effect(pixelEffectObjectList{effect}, standardImage);
end

% the standard image is now complete, which provides the truth standard
% now render the image via the pixel effect polynomial
ccdImage = 0;
for plane=1:length(ccdObject.ccdPlaneObjectList)
    ccdImage = ccdImage + render_ccd(ccdObject.ccdPlaneObjectList(plane), ...
        ccdObject, 1);
end

% take the image error
imageError = abs(ccdImage - standardImage);
% identify those pixels which are poorly fit, normalized for the max value
% badFitPixelIndex = find(imageError/max(max(standardImage)) > badFitTolerance);
badFitPixelIndex = find(imageError/std(imageError(:)) > badFitTolerance);

% get the pixels of interest
poiStruct = get(ccdObject, 'poiStruct');
% intersect the bad fit pixels with the pixels of interest
badFitPixelIndex = intersect(badFitPixelIndex, poiStruct.poiPixelIndex);
[badFitRow, badFitCol] = ind2sub([numCcdRows, numCcdCols], badFitPixelIndex);

% now we add the pixels that are in saturation, based on standardImage
% first find the pixels in saturation
[saturatedRow, saturatedCol] = find(standardImage >= 0.999*wellCapacity);

% we create a mask that has 1 for each saturated pixel
% and put a box around sucn pixels to allow their reconstruction
% being careful at the bounaries
saturatedPixelMask = zeros(size(standardImage));
saturationBoxWidth = -saturationBoxSize:saturationBoxSize;
for p=1:length(saturatedRow)
   saturatedPixelMask( ...
       min(numCcdRows, max(1, saturatedRow(p) + saturationBoxWidth)), ...
       min(numCcdCols, max(1, saturatedCol(p) + saturationBoxWidth))) = 1;
end
% get the index of the non-zero pixels in saturatedPixelMask
saturatedPixMaskIndex = find(saturatedPixelMask);

% now add whatever poorly fit pixels may not be covered by the saturation
% analysis above
badFitNonSatPixMask = ~ismember(badFitPixelIndex, saturatedPixMaskIndex);
if ~isempty(badFitNonSatPixMask)
    badFitNonSatPixIndex = find(badFitNonSatPixMask);
    for p=1:length(badFitNonSatPixIndex)
       saturatedPixelMask( ...
           min(numCcdRows, max(1, badFitRow(p) + saturationBoxWidth)), ...
           min(numCcdCols, max(1, badFitCol(p) + saturationBoxWidth))) = 1;
    end
end
% saturatedPixelMask is now an array of 1's and 0's with size = full CCD
% (accumulation memory) with 1's where pixels need to be directly computed
% from the pre-pixel effects polynomial 

% saturatedPixelMask will contain several possibly overlapping non-zero
% regions.  We want to consolidate this mask to identify those regions that
% do not touch.
[maskIndex, partitionNumber, numPartitions, imageLabels] = ...
    consolidate_partitions(saturatedPixelMask);

% return an empty structure if there are no partitions
if partitionNumber == 0
    ccdObject.badFitPixelStruct = [];
    return;
end

% identify those partition numbers that do not correspond to a badly fit
% pixel, so we don't have to recompute them
superfluousPartitions = setdiff(1:numPartitions, unique(imageLabels(badFitPixelIndex)));
clear imageLabels

% remove those pixels we that don't need to be remodeled
superfluousIndex = find(ismember(partitionNumber, superfluousPartitions));
maskIndex(superfluousIndex) = [];
partitionNumber(superfluousIndex) = [];

% find the unique patition numbers
uniquePartitionNumber = unique(partitionNumber);
numUniquePartitions = length(uniquePartitionNumber);

% return an empty structure if there are no partitions
if numUniquePartitions == 0
    ccdObject.badFitPixelStruct = [];
    return;
end

% define the output structure, which will contain the rectangular region
% containing the pixels that need to be recomputed.  We leave a slot for
% the polynomial coefficients in each region, which will be filled in the
% copies of this structure created in the ccdPlaneObject rendering process.
badFitPixelStruct = repmat(struct('rowMin', 0, 'rowMax', 0, 'colMin', 0, ...
    'colMax', 0, 'numRows', 0, 'numCols', 0, 'polyCoeffs', []), 1, numUniquePartitions);
% we now find the bounding boxes of the regions that need to be recomputed
for i=1:numUniquePartitions
    % for each partition number...
    
    % get the row and column of the pixels in this partition
    [partRow, partCol] = ind2sub([numCcdRows, numCcdCols], ...
        maskIndex(partitionNumber == uniquePartitionNumber(i)));
    % set the bounding box of this partition, clipping to visible pixels + masked smear
    rowMin = min(partRow);
    rowMax = min([max(partRow), virtualSmearStart-1]);
    colMin = max([min(partCol), numLeadingBlack+1]);
    colMax = min([max(partCol), trailingBlackStart-1]);
    badFitPixelStruct(i).rowMin = rowMin;
    badFitPixelStruct(i).rowMax = rowMax;
    badFitPixelStruct(i).colMin = colMin;
    badFitPixelStruct(i).colMax = colMax;
    badFitPixelStruct(i).numRows = rowMax - rowMin + 1;
    badFitPixelStruct(i).numCols = colMax - colMin + 1;
    % at this point ETEM1 loaded the coefficents for this rectangle.  This
    % only makes sense at the ccdPlaneObject so we defer this load to the
    % rendering code in ccdPlane, leaving polyCoeffs empty.
end
ccdObject.badFitPixelStruct = badFitPixelStruct;

save(ccdObject.badFitPixelStructFilename, 'badFitPixelStruct');


