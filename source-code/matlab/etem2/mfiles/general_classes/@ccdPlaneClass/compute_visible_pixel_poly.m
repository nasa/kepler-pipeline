function ccdPlaneObject = compute_visible_pixel_poly(ccdPlaneObject, ccdObject)
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
numVisibleRows = get(ccdPlaneObject.runParamsClass, 'numVisibleRows');
numVisibleCols = get(ccdPlaneObject.runParamsClass, 'numVisibleCols');
endian = get(ccdPlaneObject.runParamsClass, 'endian');

polyOutputFilename = ccdPlaneObject.visiblePixelPolyFilename;

if exist(polyOutputFilename, 'file')
    return;
end

if isempty(ccdPlaneObject.psf)
    load(ccdPlaneObject, 'prfPoly');
end

planeNumber = ccdPlaneObject.planeNumber;
nCoefs = get(ccdPlaneObject.runParamsClass, 'nCoefs');
displayFlag = ccdPlaneObject.diagnosticDisplay;
supressAllStars = get(ccdPlaneObject.runParamsClass, 'supressAllStars');
% linear index of pixel positions of stars on this plane
pixelIndex = ccdPlaneObject.catalogData.visiblePixelIndex; 
% linear index of sub-pixel positions of stars on this plane
subPixelIndex = ccdPlaneObject.catalogData.subPixelIndex; % linear index of stars on this plane

fid = fopen(polyOutputFilename, 'w', endian);

subPixIndexRange = (1:nSubPixels:(nSubPixels*targetImageSize)) - 1;

if displayFlag
    curr_fig = figure;
end

nPrfs = length(ccdPlaneObject.psf);
for p=1:nPrfs
	h = waitbar(0, ['computing visible pixel polynomial for prf ' num2str(p)]);

	% compute each coefficient for the visible ccd polynomial
	for c = 1:nCoefs
    	visiblePixelPoly = 0;

    	% for each sub-pixel position
    	for row=1:nSubPixels
        	for col=1:nSubPixels
            	% compute the linear index of this sub-pixel position
            	linearSubPixIndex = sub2ind([nSubPixels, nSubPixels], row, col);
            	% get the sub-pixel prf poly coefficient for all pixels
            	prfPolyCoeff = squeeze(ccdPlaneObject.psf(p).prfPolyCoeffs(c, ...
                	row+subPixIndexRange, col+subPixIndexRange));
            	% find all stars that have this sub-pixel position
            	starsOnThisSubPix = find(subPixelIndex == linearSubPixIndex);
            	% sort these stars for processing
            	[starPixelIndices, starSortIndex] = sort(pixelIndex(starsOnThisSubPix));
            	% get the flux for these stars
            	starFlux = ccdPlaneObject.catalogData.flux(starsOnThisSubPix(starSortIndex));
				if supressAllStars
					starFlux = zeros(size(starFlux));
				end

            	% place the star flux on the visible CCD
            	starFluxPixels = zeros(numVisibleRows, numVisibleCols);
            	% place the stars on the starFluxPixels, but we have to be
            	% careful about repeated indices.  So pull off the stars taking
            	% each repeated index once
            	starsRemaining = starPixelIndices;
            	while ~isempty(starsRemaining)
                	% find unique indices or first of a group
                	uniqueIndices = find(diff([0; starsRemaining]));
                	% add the unique star flux to starFluxPixels
                	uniqueStarsRemaining = starsRemaining(uniqueIndices);
                	starFluxPixels(uniqueStarsRemaining) = ...
                    	starFluxPixels(uniqueStarsRemaining) + starFlux(uniqueIndices);
                	% delete the stars we've included
                	starsRemaining(uniqueIndices) = [];
                	starFlux(uniqueIndices) = [];
            	end

            	% compute actual pixel coefficients
            	visiblePixelPoly = visiblePixelPoly + conv2(starFluxPixels, ...
                	prfPolyCoeff, 'same');
        	end
    	end
    	waitbar(c/nCoefs);

    	if displayFlag && c == 1
        	% Show the current coefficient plane
        	figure(curr_fig)
        	if c>1
            	imagesc(log10(visiblePixelPoly-min(min(visiblePixelPoly))+1e-4),[-2 2]); %Display a logspaced version
        	else
            	imagesc(visiblePixelPoly,[0 1e4])
        	end
        	colorbar
        	title(['Coefficient frame ' num2str(c)])

        	% Stop if a NaN is found
        	k = find(isnan(visiblePixelPoly));
        	if ~isempty(k)
            	keyboard
        	end
    	end

    	fwrite(fid, visiblePixelPoly, 'float32');
	end
	close(h);
end % loop over PRFs
fclose(fid);
