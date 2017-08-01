function ccdPlaneObject = compute_target_poly(ccdPlaneObject, ccdObject)
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

targetImageSize = get(ccdPlaneObject.runParamsClass, 'targetImageSize');
nSubPixels = get(ccdPlaneObject.runParamsClass, 'nSubPixelLocations');
endian = get(ccdPlaneObject.runParamsClass, 'endian');
nCoefs = get(ccdPlaneObject.runParamsClass, 'nCoefs');
numCcdRows = get(ccdPlaneObject.runParamsClass, 'numCcdRows');
numCcdCols = get(ccdPlaneObject.runParamsClass, 'numCcdCols');
numVisibleRows = get(ccdPlaneObject.runParamsClass, 'numVisibleRows');
numVisibleCols = get(ccdPlaneObject.runParamsClass, 'numVisibleCols');
numLeadingBlack = get(ccdPlaneObject.runParamsClass, 'numLeadingBlack');
numMaskedSmear = get(ccdPlaneObject.runParamsClass, 'numMaskedSmear');
virtualSmearStart = get(ccdPlaneObject.runParamsClass, 'virtualSmearStart');
trailingBlackStart = get(ccdPlaneObject.runParamsClass, 'trailingBlackStart');

targetStruct = get(ccdObject, 'targetStruct');
targetPolyOutputFilename = ccdPlaneObject.targetPolyFilename;

% get the catalog data for targets on this ccdPlane
[tf, targetIndex] = ismember(ccdPlaneObject.targetList, ccdPlaneObject.catalogData.kicId);
nTargets = length(targetIndex);
% We have to set up the linear indices in CCD space of the pixels
% get the target row and column in CCD coordinates
targetRow = ccdPlaneObject.catalogData.row(targetIndex);
targetColumn = ccdPlaneObject.catalogData.column(targetIndex);
% range of pixels in target image centered on zero
targetImageRange = -(targetImageSize - 1)/2:(targetImageSize - 1)/2;
[targetImageCols targetImageRows] = meshgrid(targetImageRange, targetImageRange);

ccdPlaneObject.allTargetImageIndices = [];
for t=1:length(targetRow)
    ccdPlaneObject.allTargetImageIndices = ...
        [ ccdPlaneObject.allTargetImageIndices sub2ind([numCcdRows, numCcdCols], ...
        targetRow(t) + targetImageRows, targetColumn(t) + targetImageCols) ];
    ccdPlaneObject.targetImageIndices(t).ccdIndices = sub2ind([numCcdRows, numCcdCols], ...
        targetRow(t) + targetImageRows, targetColumn(t) + targetImageCols);
    ccdPlaneObject.targetImageIndices(t).rowRange = targetRow(t) + targetImageRange;
    ccdPlaneObject.targetImageIndices(t).colRange = targetColumn(t) + targetImageRange;
end

if exist(targetPolyOutputFilename, 'file')
    return;
end

if isempty(ccdPlaneObject.psf)
    load(ccdPlaneObject, 'prfPoly');
end

% linear index of sub-pixel positions of target stars on this plane
subPixelIndex = ccdPlaneObject.catalogData.subPixelIndex(targetIndex); % linear index of stars on this plane
% get the target fluxes for target stars on this plane
targetFlux = ccdPlaneObject.catalogData.flux(targetIndex);

fid = fopen(targetPolyOutputFilename, 'w', endian);

flatFieldObjectList = get(ccdObject, 'flatFieldObjectList');
% multiply by the flat field signals
flatField = ones(numVisibleRows, numVisibleCols);
nSignals = length(flatFieldObjectList);
for s = 1:nSignals 
    flatField = flatField .* get(flatFieldObjectList{s});
end
% imbed the flat field in a full CCD
ccdFlat = ones(numCcdRows, numCcdCols);
ccdFlat(numMaskedSmear + 1:virtualSmearStart-1, ...
    numLeadingBlack+1:trailingBlackStart-1) = flatField;

subPixIndexRange = (1:nSubPixels:(nSubPixels*targetImageSize)) - 1;
targetPixelPoly = zeros(nCoefs, targetImageSize, targetImageSize, nTargets);
nPrfs = length(ccdPlaneObject.psf);
for p=1:nPrfs
	% compute each coefficient for the visible ccd polynomial
    % for each sub-pixel position
    for row=1:nSubPixels
        for col=1:nSubPixels
            % compute the linear index of this sub-pixel position
            linearSubPixIndex = sub2ind([nSubPixels, nSubPixels], row, col);
            % get the sub-pixel prf poly coefficient for all pixels
            % .prfPolyCoeffs has size (nCoeffs, nSubPixels*targetImageSize, 
            % nSubPixels*targetImageSize).  The result is an array of size
            % size (nCoeffs, targetImageSize, targetImageSize).  
            prfPolyCoeff = squeeze(ccdPlaneObject.psf(p).prfPolyCoeffs(:, ...
                row+subPixIndexRange, col+subPixIndexRange));
            % find all stars that have this sub-pixel position
            starsOnThisSubPix = find(subPixelIndex == linearSubPixIndex);
            nStarsOnThisSubPix = length(starsOnThisSubPix);
            % get the flux for these stars
            starFlux = targetFlux(starsOnThisSubPix);

            % we now build the target pixel poly array, where for each poly
            % coefficient (dimension 1) and for each target on this
            % sub-pixel position (dimension 4) we fill the pixel image
            % (dimensions 2 and 3) with a copy of prfPolyCoeff scaled by the
            % flux.  The flux is a 1D array indexed by target and
            % prfPolyCoeff is a 3D array of size (nCoeff, targetImageSize,
            % targetImageSize).   We use repmat to make each product matrix
            % the same shape then do an element-level multiply
            if nStarsOnThisSubPix > 0
                targetPixelPoly(:,:,:,starsOnThisSubPix) = ...
                    repmat(...
                        reshape(starFlux, [1, 1, 1, nStarsOnThisSubPix]), ...
                        [nCoefs, targetImageSize, targetImageSize, 1] ) ...
                    	.* repmat(prfPolyCoeff, [1, 1, 1, nStarsOnThisSubPix]);
            end
        end
    end
	for t=1:nTargets
		for c=1:nCoefs
        	targetPixelPoly(c,:,:,t) = ...
                squeeze(targetPixelPoly(c,:,:,t)) ...
				.* ccdFlat(ccdPlaneObject.targetImageIndices(t).ccdIndices);
		end
	end
    fwrite(fid, targetPixelPoly, 'float32');
end % loop over PRFs
fclose(fid);

