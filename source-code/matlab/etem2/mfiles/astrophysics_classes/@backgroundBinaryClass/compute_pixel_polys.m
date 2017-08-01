function backgroundBinaryObject = ...
    compute_pixel_polys(backgroundBinaryObject, ccdObject)
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

runParamsObject = backgroundBinaryObject.runParamsClass;

ccdPlaneList = get(ccdObject, 'ccdPlaneObjectList');
% find the plane that contains this target
ccdPlaneObject = [];
for p=1:length(ccdPlaneList)
    catalogData = get(ccdPlaneList(p), 'catalogData');
    if ismember(backgroundBinaryObject.targetData.keplerId, catalogData.kicId)
        ccdPlaneObject = ccdPlaneList(p);
        break;
    end
end
if isempty(ccdPlaneObject)
    error('backgroundBinaryObject:compute_pixel_polys:target not found in a ccdPlane');
end

targetImageSize = get(runParamsObject, 'targetImageSize');
nCoefs = get(runParamsObject, 'nCoefs');
nSubPix = get(runParamsObject, 'nSubPixelLocations');
integrationTime = get(runParamsObject, 'integrationTime');
% get the PRF poly coefficients
psfList = get(ccdPlaneObject, 'psf');
subPixRange = (1:nSubPix:(nSubPix*targetImageSize))-1;
% get the sub pixel location of the background binary
subRow = backgroundBinaryObject.subRow;
subCol = backgroundBinaryObject.subCol;

nPrfs = length(psfList);
for p=1:nPrfs
    prfPolyCoeffs = psfList(p).prfPolyCoeffs;
    pixelPolyCoefs = prfPolyCoeffs(:, subRow+subPixRange, subCol+subPixRange) ...
        * backgroundBinaryObject.flux * integrationTime;
    % now rearrange to facilitate later multiplication by motion polynomials by
    % making it (targetImageSize*targetImageSize) x nCoefs
    pixelPolyCoefs = permute(pixelPolyCoefs, [2, 3, 1]);
    backgroundBinaryObject.pixelPolyCoefs(p).coefs = ...
        reshape(pixelPolyCoefs, [targetImageSize*targetImageSize, nCoefs]);
end
% find the pixel indices in CCD space for the pixels in this image
% compute the rows and columns of all pixels in this image
targetImageRange = -(targetImageSize - 1)/2:(targetImageSize - 1)/2;
[targetImageCols targetImageRows] = meshgrid(targetImageRange, targetImageRange);
% row and column are defined on the visible pixels
rows = backgroundBinaryObject.row + targetImageRows;
cols = backgroundBinaryObject.column + targetImageCols;
numCcdRows = get(runParamsObject, 'numCcdRows');
numCcdCols = get(runParamsObject, 'numCcdCols');
bgBinPixelCcdIndices = sub2ind([numCcdRows, numCcdCols], rows, cols);
% intersect with target pixels of interest
poiStruct = get(ccdObject, 'poiStruct');
[tf bgBinPixelIndicesInPoi] = ismember(bgBinPixelCcdIndices, poiStruct.targetPoiIndex);
% eliminate the pixels that are not on target pixels of interest
backgroundBinaryObject.bgBinPixelPoiPixelIndex = find(tf); % indices in CCD space
backgroundBinaryObject.bgBinPixelIndexInPoi = bgBinPixelIndicesInPoi(bgBinPixelIndicesInPoi ~= 0);
backgroundBinaryObject.bgBinPixelIndexInCcd = bgBinPixelCcdIndices(bgBinPixelIndicesInPoi ~= 0);
