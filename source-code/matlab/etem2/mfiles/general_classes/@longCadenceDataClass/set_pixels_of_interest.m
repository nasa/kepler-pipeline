function longCadenceDataObject = set_pixels_of_interest(longCadenceDataObject, tadInputStruct)
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

runParamsObject = longCadenceDataObject.runParamsClass;
numCcdRows = get(runParamsObject, 'numCcdRows');
numCcdCols = get(runParamsObject, 'numCcdCols');
numMaskedSmear = get(runParamsObject, 'numMaskedSmear');
virtualSmearStart = get(runParamsObject, 'virtualSmearStart');
numLeadingBlack = get(runParamsObject, 'numLeadingBlack');
trailingBlackStart = get(runParamsObject, 'trailingBlackStart');
rowCorrection = get(runParamsObject, 'rowCorrection');
colCorrection = get(runParamsObject, 'colCorrection');
targetImageSize = get(runParamsObject, 'targetImageSize');

targetDefinitions = tadInputStruct.targetDefinitions;
maskDefinitions = tadInputStruct.maskDefinitions;
backgroundTargetDefinitions = tadInputStruct.backgroundTargetDefinitions;
backgroundMaskDefinitions = tadInputStruct.backgroundMaskDefinitions;
refPixelTargetDefinitions = tadInputStruct.refPixelTargetDefinitions; 

% initialize the pixel of interest arrays
longCadenceDataObject.poiStruct.poiRow = [];
longCadenceDataObject.poiStruct.poiCol = [];
longCadenceDataObject.poiStruct.targetPoiIndex = [];
longCadenceDataObject.targetStruct = repmat(struct( ...
    'keplerId', 0, 'poiStart',  0, 'numPoi', 0, ...
	'referenceRow', 0, 'referenceColumn', 0, ...
	'poiRow', [], 'poiCol', []), ...
    1, length(targetDefinitions));

targetImageReferencePixel = (targetImageSize - 1)/2 + 1;

% add target pixels
for t=1:length(targetDefinitions)
    longCadenceDataObject.targetStruct(t).keplerId = targetDefinitions(t).keplerId;
    
    % get the reference row and column
    refRow = targetDefinitions(t).referenceRow + 1;
    refCol = targetDefinitions(t).referenceColumn + 1;
    % get the mask for this target
    % convert from 0-base to 1-base
    offsets = maskDefinitions(targetDefinitions(t).maskIndex+1).offsets;
    % collect the pixels associated with each target as column vectors
    % convert from 0-base to 1-base
    longCadenceDataObject.targetStruct(t).referenceRow = refRow;
    longCadenceDataObject.targetStruct(t).referenceColumn = refCol;
	% pixel row and column in ccd coordinates
    longCadenceDataObject.targetStruct(t).poiRow = refRow + [offsets.row]' + rowCorrection;
    longCadenceDataObject.targetStruct(t).poiCol = refCol + [offsets.column]' + colCorrection;
	% pixel row and column in target image coordinates
    poiImageRow = targetImageReferencePixel + longCadenceDataObject.targetStruct(t).poiRow  ...
		- refRow - rowCorrection;
    poiImageCol = targetImageReferencePixel + longCadenceDataObject.targetStruct(t).poiCol ...
		- refCol - colCorrection - 1; % -1 to account for overshoot col on left
	inBounds = find(poiImageRow <= targetImageSize & poiImageRow > 0 ...
		& poiImageCol <= targetImageSize & poiImageCol > 0);
    longCadenceDataObject.targetStruct(t).poiImageRow = poiImageRow(inBounds);
    longCadenceDataObject.targetStruct(t).poiImageCol = poiImageCol(inBounds);
    % create the linear index into the ccd pixels space.  This array
    % preserves the order in the mask definition
    % this is needed to help write out the target values to the ssr
    longCadenceDataObject.targetStruct(t).poiPixelIndex = sub2ind([numCcdRows, numCcdCols], ...
        longCadenceDataObject.targetStruct(t).poiRow, longCadenceDataObject.targetStruct(t).poiCol);
	% same for target image space
	longCadenceDataObject.targetStruct(t).poiImageIndex = sub2ind([targetImageSize, targetImageSize], ...
        longCadenceDataObject.targetStruct(t).poiImageRow, longCadenceDataObject.targetStruct(t).poiImageCol);
    % add target pixels to the global pixels of interest list.  Later we
    % will take unique entries in the global list, so the global list will
    % not be the same as the concat of the individual target pixel lists.
    longCadenceDataObject.poiStruct.poiRow = [longCadenceDataObject.poiStruct.poiRow; ...
        longCadenceDataObject.targetStruct(t).poiRow];
    longCadenceDataObject.poiStruct.poiCol = [longCadenceDataObject.poiStruct.poiCol; ...
        longCadenceDataObject.targetStruct(t).poiCol];
    % add to the global target pixel index list
	longCadenceDataObject.poiStruct.targetPoiIndex = ...
		[ longCadenceDataObject.poiStruct.targetPoiIndex; ...
		longCadenceDataObject.targetStruct(t).poiPixelIndex ];
end

% add background pixels.  We do not retain the target structure, and treat
% the background pixels as a flat list of pixels.
longCadenceDataObject.backgroundStruct.poiRow = [];
longCadenceDataObject.backgroundStruct.poiCol = [];
for t=1:length(backgroundTargetDefinitions)
    % get the reference row and column
    refRow = backgroundTargetDefinitions(t).referenceRow + 1;
    refCol = backgroundTargetDefinitions(t).referenceColumn + 1;
    % get the mask for this target
    offsets = backgroundMaskDefinitions(backgroundTargetDefinitions(t).maskIndex+1).offsets;
    % add each pixel row, column to the list of background pixels as column
    % vectors
    longCadenceDataObject.backgroundStruct.poiRow = [longCadenceDataObject.backgroundStruct.poiRow; refRow + [offsets.row]' + rowCorrection];
    longCadenceDataObject.backgroundStruct.poiCol = [longCadenceDataObject.backgroundStruct.poiCol; refCol + [offsets.column]' + colCorrection];

end
longCadenceDataObject.backgroundStruct.poiPixelIndex = sub2ind([numCcdRows, numCcdCols], ...
        longCadenceDataObject.backgroundStruct.poiRow, longCadenceDataObject.backgroundStruct.poiCol);
% add background pixels to global list
longCadenceDataObject.poiStruct.poiRow = [longCadenceDataObject.poiStruct.poiRow; longCadenceDataObject.backgroundStruct.poiRow];
longCadenceDataObject.poiStruct.poiCol = [longCadenceDataObject.poiStruct.poiCol; longCadenceDataObject.backgroundStruct.poiCol];

% add collateral pixels
% add trailing black pixels
% these are the ones that are actually used
[cols, rows] = meshgrid(trailingBlackStart:numCcdCols, 1:numCcdRows);
longCadenceDataObject.trailingBlackStruct.poiRow = rows(:);
longCadenceDataObject.trailingBlackStruct.poiCol = cols(:);
longCadenceDataObject.trailingBlackStruct.poiPixelIndex = sub2ind([numCcdRows, numCcdCols], ...
        longCadenceDataObject.trailingBlackStruct.poiRow, longCadenceDataObject.trailingBlackStruct.poiCol);
longCadenceDataObject.poiStruct.poiRow = [longCadenceDataObject.poiStruct.poiRow; longCadenceDataObject.trailingBlackStruct.poiRow];
longCadenceDataObject.poiStruct.poiCol = [longCadenceDataObject.poiStruct.poiCol; longCadenceDataObject.trailingBlackStruct.poiCol];

% add masked smear pixels
[cols, rows] = meshgrid(numLeadingBlack+1:trailingBlackStart-1, 1:numMaskedSmear);
longCadenceDataObject.maskedSmearStruct.poiRow = rows(:);
longCadenceDataObject.maskedSmearStruct.poiCol = cols(:);
longCadenceDataObject.maskedSmearStruct.poiPixelIndex = sub2ind([numCcdRows, numCcdCols], ...
        longCadenceDataObject.maskedSmearStruct.poiRow, longCadenceDataObject.maskedSmearStruct.poiCol);
longCadenceDataObject.poiStruct.poiRow = [longCadenceDataObject.poiStruct.poiRow; longCadenceDataObject.maskedSmearStruct.poiRow];
longCadenceDataObject.poiStruct.poiCol = [longCadenceDataObject.poiStruct.poiCol; longCadenceDataObject.maskedSmearStruct.poiCol];

% add virtual smear pixels
[cols, rows] = meshgrid(numLeadingBlack+1:trailingBlackStart-1, virtualSmearStart:numCcdRows);
longCadenceDataObject.virtualSmearStruct.poiRow = rows(:);
longCadenceDataObject.virtualSmearStruct.poiCol = cols(:);
longCadenceDataObject.virtualSmearStruct.poiPixelIndex = sub2ind([numCcdRows, numCcdCols], ...
        longCadenceDataObject.virtualSmearStruct.poiRow, longCadenceDataObject.virtualSmearStruct.poiCol);
longCadenceDataObject.poiStruct.poiRow = [longCadenceDataObject.poiStruct.poiRow; longCadenceDataObject.virtualSmearStruct.poiRow];
longCadenceDataObject.poiStruct.poiCol = [longCadenceDataObject.poiStruct.poiCol; longCadenceDataObject.virtualSmearStruct.poiCol];

% add leading black pixels
[cols, rows] = meshgrid(1:numLeadingBlack, 1:numCcdRows);
longCadenceDataObject.leadingBlackStruct.poiRow = rows(:);
longCadenceDataObject.leadingBlackStruct.poiCol = cols(:);
longCadenceDataObject.leadingBlackStruct.poiPixelIndex = sub2ind([numCcdRows, numCcdCols], ...
        longCadenceDataObject.leadingBlackStruct.poiRow, longCadenceDataObject.leadingBlackStruct.poiCol);
longCadenceDataObject.poiStruct.poiRow = [longCadenceDataObject.poiStruct.poiRow; longCadenceDataObject.leadingBlackStruct.poiRow];
longCadenceDataObject.poiStruct.poiCol = [longCadenceDataObject.poiStruct.poiCol; longCadenceDataObject.leadingBlackStruct.poiCol];

% add reference pixels
for t=1:length(refPixelTargetDefinitions)
    
    % get the reference row and column
    refRow = refPixelTargetDefinitions(t).referenceRow + 1;
    refCol = refPixelTargetDefinitions(t).referenceColumn + 1;
    % get the mask for this target
    % convert from 0-base to 1-base
    offsets = maskDefinitions(refPixelTargetDefinitions(t).maskIndex+1).offsets;
    % collect the pixels associated with each target as column vectors
    % convert from 0-base to 1-base
    longCadenceDataObject.referencePixelStruct(t).poiRow = refRow + [offsets.row]' + rowCorrection;
    longCadenceDataObject.referencePixelStruct(t).poiCol = refCol + [offsets.column]' + colCorrection;
    
    % create the linear index into the ccd pixels space.  This array
    % preserves the order in the mask definition
    longCadenceDataObject.referencePixelStruct(t).poiPixelIndex = sub2ind([numCcdRows, numCcdCols], ...
        longCadenceDataObject.referencePixelStruct(t).poiRow, longCadenceDataObject.referencePixelStruct(t).poiCol);
    
    % add target pixels to the global pixels of interest list.  Later we
    % will take unique entries in the global list, so the global list will
    % not be the same as the concat of the individual target pixel lists.
    longCadenceDataObject.poiStruct.poiRow = [longCadenceDataObject.poiStruct.poiRow; ...
        longCadenceDataObject.referencePixelStruct(t).poiRow];
    longCadenceDataObject.poiStruct.poiCol = [longCadenceDataObject.poiStruct.poiCol; ...
        longCadenceDataObject.referencePixelStruct(t).poiCol];
end

% create the linear index into the pixel array, allowing duplicate entries
longCadenceDataObject.poiStruct.poiPixelIndex = sub2ind([numCcdRows, numCcdCols], ...
    longCadenceDataObject.poiStruct.poiRow, longCadenceDataObject.poiStruct.poiCol);

% find the visible pixels
visiblePoiIndex = find(longCadenceDataObject.poiStruct.poiCol > numLeadingBlack & ...
    longCadenceDataObject.poiStruct.poiCol < trailingBlackStart & ...
	longCadenceDataObject.poiStruct.poiRow > numMaskedSmear & ...
    longCadenceDataObject.poiStruct.poiRow < virtualSmearStart);
visiblePoiRows = longCadenceDataObject.poiStruct.poiRow(visiblePoiIndex);
visiblePoiCols = longCadenceDataObject.poiStruct.poiCol(visiblePoiIndex);
longCadenceDataObject.poiStruct.poiVisiblePixelIndex = sub2ind([numCcdRows, numCcdCols], ...
    visiblePoiRows, visiblePoiCols);


