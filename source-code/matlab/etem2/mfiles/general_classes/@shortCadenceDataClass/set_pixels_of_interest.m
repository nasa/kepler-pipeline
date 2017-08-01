function shortCadenceDataObject = set_pixels_of_interest(shortCadenceDataObject, tadInputStruct)
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

runParamsObject = shortCadenceDataObject.runParamsClass;
numCcdRows = get(runParamsObject, 'numCcdRows');
numCcdCols = get(runParamsObject, 'numCcdCols');
numMaskedSmear = get(runParamsObject, 'numMaskedSmear');
virtualSmearStart = get(runParamsObject, 'virtualSmearStart');
numLeadingBlack = get(runParamsObject, 'numLeadingBlack');
trailingBlackStart = get(runParamsObject, 'trailingBlackStart');
rowCorrection = get(runParamsObject, 'rowCorrection');
colCorrection = get(runParamsObject, 'colCorrection');
targetImageSize = get(runParamsObject, 'targetImageSize');

targetImageReferencePixel = (targetImageSize - 1)/2 + 1;

targetDefinitions = tadInputStruct.targetDefinitions;
maskDefinitions = tadInputStruct.maskDefinitions;

% initialize the pixel of interest arrays
shortCadenceDataObject.poiStruct.poiRow = [];
shortCadenceDataObject.poiStruct.poiCol = [];
shortCadenceDataObject.poiStruct.targetPoiIndex = [];
shortCadenceDataObject.targetStruct = repmat(struct( ...
    'keplerId', 0, 'poiStart',  0, 'numPoi', 0, 'poiRow', [], 'poiCol', []), ...
    1, length(targetDefinitions));

% row and column lists containing row and columns we are actually
% interested in
rowList = [];
colList = [];
% add target pixels
for t=1:length(targetDefinitions)
    shortCadenceDataObject.targetStruct(t).keplerId = targetDefinitions(t).keplerId;
    
    % get the reference row and column
    refRow = targetDefinitions(t).referenceRow + 1;
    refCol = targetDefinitions(t).referenceColumn + 1;
    % get the mask for this target
    % convert from 0-base to 1-base
    offsets = maskDefinitions(targetDefinitions(t).maskIndex+1).offsets;
    % collect the pixels associated with each target as column vectors
    % convert from 0-base to 1-base
    shortCadenceDataObject.targetStruct(t).poiRow = refRow + [offsets.row]' + rowCorrection;
    shortCadenceDataObject.targetStruct(t).poiCol = refCol + [offsets.column]' + colCorrection;
	% pixel row and column in target image coordinates
    poiImageRow = targetImageReferencePixel + shortCadenceDataObject.targetStruct(t).poiRow  ...
		- refRow - rowCorrection;
    poiImageCol = targetImageReferencePixel + shortCadenceDataObject.targetStruct(t).poiCol ...
		- refCol - colCorrection; % -1 to account for overshoot col on left;
	inBounds = find(poiImageRow <= targetImageSize & poiImageRow > 0 ...
		& poiImageCol <= targetImageSize & poiImageCol > 0);
    shortCadenceDataObject.targetStruct(t).poiImageRow = poiImageRow(inBounds);
    shortCadenceDataObject.targetStruct(t).poiImageCol = poiImageCol(inBounds);
    
    % make unique row and column lists for the later storage of collateral data
    shortCadenceDataObject.targetStruct(t).rowList ...
        = sort(unique(shortCadenceDataObject.targetStruct(t).poiRow));
    shortCadenceDataObject.targetStruct(t).colList ...
        = sort(unique(shortCadenceDataObject.targetStruct(t).poiCol));
    % add those rows and columns to total list of rows and columns of
    % interest
    rowList = union(rowList, shortCadenceDataObject.targetStruct(t).rowList);
    colList = union(colList, shortCadenceDataObject.targetStruct(t).colList);
    
    % create the linear index into the ccd pixels space.  This array
    % preserves the order in the mask definition
    % this is needed to help write out the target values to the ssr
    shortCadenceDataObject.targetStruct(t).poiPixelIndex = sub2ind([numCcdRows, numCcdCols], ...
        shortCadenceDataObject.targetStruct(t).poiRow, shortCadenceDataObject.targetStruct(t).poiCol);
	% same for target image space
	shortCadenceDataObject.targetStruct(t).poiImageIndex = sub2ind([targetImageSize, targetImageSize], ...
        shortCadenceDataObject.targetStruct(t).poiImageRow, shortCadenceDataObject.targetStruct(t).poiImageCol);
    % add target pixels to the global pixels of interest list.  Later we
    % will take unique entries in the global list, so the global list will
    % not be the same as the concat of the individual target pixel lists.
    shortCadenceDataObject.poiStruct.poiRow = [shortCadenceDataObject.poiStruct.poiRow; ...
        shortCadenceDataObject.targetStruct(t).poiRow];
    shortCadenceDataObject.poiStruct.poiCol = [shortCadenceDataObject.poiStruct.poiCol; ...
        shortCadenceDataObject.targetStruct(t).poiCol];
    % add to the global target pixel index list
	shortCadenceDataObject.poiStruct.targetPoiIndex = ...
		[ shortCadenceDataObject.poiStruct.targetPoiIndex; ...
		shortCadenceDataObject.targetStruct(t).poiPixelIndex ];
end

% add the smear rows to the row list (to later get the corner values)
rowList = union(rowList, 1:numMaskedSmear);
rowList = union(rowList, virtualSmearStart:numCcdRows);

% sort the row and column lists in increasing order
rowList = sort(rowList);
colList = sort(colList);

% add collateral pixels
% % add leading black pixels for only those rows we are interested in
% [cols, rows] = meshgrid(1:numLeadingBlack, rowList);
% shortCadenceDataObject.leadingBlackStruct.poiRow = rows(:);
% shortCadenceDataObject.leadingBlackStruct.poiCol = cols(:);
% shortCadenceDataObject.leadingBlackStruct.poiPixelIndex = sub2ind([numCcdRows, numCcdCols], ...
%         shortCadenceDataObject.leadingBlackStruct.poiRow, shortCadenceDataObject.leadingBlackStruct.poiCol);
% shortCadenceDataObject.poiStruct.poiRow = [shortCadenceDataObject.poiStruct.poiRow; shortCadenceDataObject.leadingBlackStruct.poiRow];
% shortCadenceDataObject.poiStruct.poiCol = [shortCadenceDataObject.poiStruct.poiCol; shortCadenceDataObject.leadingBlackStruct.poiCol];

% add trailing black pixels
% these are the ones that are actually used
[cols, rows] = meshgrid(trailingBlackStart:numCcdCols, rowList);
shortCadenceDataObject.trailingBlackStruct.poiRow = rows(:);
shortCadenceDataObject.trailingBlackStruct.poiCol = cols(:);
shortCadenceDataObject.trailingBlackStruct.poiPixelIndex = sub2ind([numCcdRows, numCcdCols], ...
        shortCadenceDataObject.trailingBlackStruct.poiRow, shortCadenceDataObject.trailingBlackStruct.poiCol);
shortCadenceDataObject.poiStruct.poiRow = [shortCadenceDataObject.poiStruct.poiRow; shortCadenceDataObject.trailingBlackStruct.poiRow];
shortCadenceDataObject.poiStruct.poiCol = [shortCadenceDataObject.poiStruct.poiCol; shortCadenceDataObject.trailingBlackStruct.poiCol];

% add masked smear pixels
[cols, rows] = meshgrid(colList, 1:numMaskedSmear);
shortCadenceDataObject.maskedSmearStruct.poiRow = rows(:);
shortCadenceDataObject.maskedSmearStruct.poiCol = cols(:);
shortCadenceDataObject.maskedSmearStruct.poiPixelIndex = sub2ind([numCcdRows, numCcdCols], ...
        shortCadenceDataObject.maskedSmearStruct.poiRow, shortCadenceDataObject.maskedSmearStruct.poiCol);
shortCadenceDataObject.poiStruct.poiRow = [shortCadenceDataObject.poiStruct.poiRow; shortCadenceDataObject.maskedSmearStruct.poiRow];
shortCadenceDataObject.poiStruct.poiCol = [shortCadenceDataObject.poiStruct.poiCol; shortCadenceDataObject.maskedSmearStruct.poiCol];

% add virtual smear pixels
[cols, rows] = meshgrid(colList, virtualSmearStart:numCcdRows);
shortCadenceDataObject.virtualSmearStruct.poiRow = rows(:);
shortCadenceDataObject.virtualSmearStruct.poiCol = cols(:);
shortCadenceDataObject.virtualSmearStruct.poiPixelIndex = sub2ind([numCcdRows, numCcdCols], ...
        shortCadenceDataObject.virtualSmearStruct.poiRow, shortCadenceDataObject.virtualSmearStruct.poiCol);
shortCadenceDataObject.poiStruct.poiRow = [shortCadenceDataObject.poiStruct.poiRow; shortCadenceDataObject.virtualSmearStruct.poiRow];
shortCadenceDataObject.poiStruct.poiCol = [shortCadenceDataObject.poiStruct.poiCol; shortCadenceDataObject.virtualSmearStruct.poiCol];

% create the linear index into the pixel array, allowing duplicate entries
shortCadenceDataObject.poiStruct.poiPixelIndex = sub2ind([numCcdRows, numCcdCols], ...
    shortCadenceDataObject.poiStruct.poiRow, shortCadenceDataObject.poiStruct.poiCol);

% find the visible pixels
visiblePoiIndex = find(shortCadenceDataObject.poiStruct.poiCol > numLeadingBlack & ...
    shortCadenceDataObject.poiStruct.poiCol < trailingBlackStart & ...
	shortCadenceDataObject.poiStruct.poiRow > numMaskedSmear & ...
    shortCadenceDataObject.poiStruct.poiRow < virtualSmearStart);
visiblePoiRows = shortCadenceDataObject.poiStruct.poiRow(visiblePoiIndex);
visiblePoiCols = shortCadenceDataObject.poiStruct.poiCol(visiblePoiIndex);
shortCadenceDataObject.poiStruct.poiVisiblePixelIndex = sub2ind([numCcdRows, numCcdCols], ...
    visiblePoiRows, visiblePoiCols);

% add the other pixel types that are expected
shortCadenceDataObject.backgroundStruct.poiRow = [];
shortCadenceDataObject.backgroundStruct.poiCol = [];
shortCadenceDataObject.backgroundStruct.poiPixelIndex = [];
shortCadenceDataObject.leadingBlackStruct.poiRow = [];
shortCadenceDataObject.leadingBlackStruct.poiCol = [];
shortCadenceDataObject.leadingBlackStruct.poiPixelIndex = [];

