function ccdPlaneObject = compute_prf_poly(ccdPlaneObject, ccdObject)
% based on so/Released/ETEM/gencpix.m
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

prfDesignRangeBuffer = get(ccdPlaneObject.runParamsClass, 'prfDesignRangeBuffer');
motionPolyOrder = get(ccdPlaneObject.runParamsClass, 'motionPolyOrder');
nCoefs = get(ccdPlaneObject.runParamsClass, 'nCoefs');
jitterMotionObject = get(ccdObject, 'jitterMotionObject');
jitterRadius = get(jitterMotionObject, 'radius');
displayFlag = ccdPlaneObject.diagnosticDisplay;

if displayFlag
    figure;
    s1 = size(ccdPlaneObject.motionBasis, 1);
    s2 = size(ccdPlaneObject.motionBasis, 2);
    for i=1:s1
        for j=1:s2
            subplot(s1, s2, i+s1*(j-1));
            A = ccdPlaneObject.motionBasis(i,j).designMatrix;
            a1 = A(:,1);
            a2 = A(:,2);
            a3 = A(:,3);
            scatter(a2./a1, a3./a1);
        end
    end
end

rowMotion = [];
colMotion = [];
% first determine range of motion for design space
for i=1:size(ccdPlaneObject.motionBasis, 1)
    for j=1:size(ccdPlaneObject.motionBasis, 1)
        constantTerm = ccdPlaneObject.motionBasis(i,j).designMatrix(1,1);
        colMotion = [colMotion; ...
            ccdPlaneObject.motionBasis(i,j).designMatrix(:,2)/constantTerm];
        rowMotion = [rowMotion; ...
            ccdPlaneObject.motionBasis(i,j).designMatrix(:,3)/constantTerm];
    end
end
maxAbsRowMotion = max(abs(rowMotion));
maxAbsColMotion = max(abs(colMotion));

% compute final design range parameters
rowDesignRange = prfDesignRangeBuffer*(maxAbsRowMotion + jitterRadius);
colDesignRange = prfDesignRangeBuffer*(maxAbsColMotion + jitterRadius);

% make design range computation mesh
designRangeMeshRow = (-1:1/10:1)'*rowDesignRange;
designRangeMeshCol = (-1:1/10:1)'*colDesignRange; % creates a 21 x 21 mesh

% determine actual points in the design range mesh that are hit by the
% motion in [rowMotion, colMotion].  Do this via the clever method of
% interpolating the indices of rowDesignRange, colDesignRange
% onto the row, column values in rowMotion, colMotion.
activeDesignRows = interp1(designRangeMeshRow,(1:length(designRangeMeshRow))',...
    rowMotion(:),'near');
activeDesignCols = interp1(designRangeMeshCol,(1:length(designRangeMeshCol))',...
    colMotion(:),'near');

motionImage = zeros(length(designRangeMeshRow),length(designRangeMeshCol));
motionImage(sub2ind([length(designRangeMeshRow),length(designRangeMeshCol)],...
    activeDesignRows,activeDesignCols))=1;

% add ring the size of jitter ball to the motion path
jitterBufferCols = max(3,ceil( 2*jitterRadius/(.1*colDesignRange) ) ); 
jitterBufferRows = max(3,ceil( 2*jitterRadius/(.1*rowDesignRange) ) ); 

% force jitter_buffers to be odd
if ~mod(jitterBufferCols, 2)
    jitterBufferCols = jitterBufferCols + 1;
end 
if ~mod(jitterBufferRows, 2)
    jitterBufferRows = jitterBufferRows + 1;
end 

% add buffer to account for size of jitter ball
largeMotionImage = conv2(motionImage,ones(jitterBufferCols, ...
    jitterBufferRows),'same'); 

pointsWithMotionIndex = find(largeMotionImage(:)>0);
nPointsWithMotion = length(pointsWithMotionIndex); % number of offsets to fit to

% now create 2D mesh on which to do the fit
[designMeshCol, designMeshRow] = meshgrid(designRangeMeshCol,designRangeMeshRow);
designMeshCol = designMeshCol(:);  % make it linear
designMeshRow = designMeshRow(:); 

% confine fit to region containing motion only
designMeshCol = designMeshCol(pointsWithMotionIndex);
designMeshRow = designMeshRow(pointsWithMotionIndex);

% make the prf design matrix based on this mesh
ccdPlaneObject.prfDesignMatrix = make_binned_design_matrix(designMeshCol, ...
    designMeshRow, motionPolyOrder);

% Precompute (Ac'*Ac)^-1 * Ac' to speed up fit for Ac = prfDesignMatrix.
% Note that the prf poly = (Ac'*Ac)\(Ac'*pix) where pix is a matrix of pixel time series. Thus, cpix
% is a weighted sum of pixel values; effectively computes inv(Ac'*Ac)*Ac'.
%ActAc_1Act = (Ac'*Ac) \ Ac'; NEEDED TO STABILIZE THIS USING SVD

% Use SVD analysis to stabilize inverse
[U,S,V] = svd(ccdPlaneObject.prfDesignMatrix,0);
S = diag(S);
Sinv = zeros(size(S));
Sinv(S>S(1)/1e9) = 1./S(S>S(1)/1e9);
Sinv = diag(Sinv);
ccdPlaneObject.prfSolutionMatrix = (V*Sinv*Sinv*V')*ccdPlaneObject.prfDesignMatrix';

% set up the image for the PRF polynomial based on targetImageSize, which
% must be odd.
targetImageSize = get(ccdPlaneObject.runParamsClass, 'targetImageSize');
halfImageSize = (targetImageSize - 1)/2;
prfImageCols = -halfImageSize:halfImageSize;

% set up the grid of sub-pixel locations
nSubPixels = get(ccdPlaneObject.runParamsClass, 'nSubPixelLocations');
subPixelCols = (1:nSubPixels)/nSubPixels-mean((1:nSubPixels)/nSubPixels);

% combine the prfImage and subPixel points into the final interpolation
% mesh
repCols = repmat(prfImageCols(:)',nSubPixels,1);
prfInterpCols = repCols(:) - repmat(subPixelCols(:),targetImageSize,1);
prfInterpRows = prfInterpCols;

% Initialize the computations
nPositionsOnSide = targetImageSize*nSubPixels;
nTotalPositions = nPositionsOnSide*nPositionsOnSide;
nPrfs = length(ccdPlaneObject.psf);
prfValues = zeros(nPointsWithMotion, nTotalPositions);
if displayFlag
    prfFit = zeros(nPointsWithMotion, nTotalPositions);
    fitError = zeros(nPositionsOnSide);
end
for p=1:nPrfs
	h = waitbar(0, ['computing PRF ' num2str(p) ' polynomial']);

	ccdPlaneObject.psf(p).prfPolyCoeffs = zeros([nCoefs, nPositionsOnSide, nPositionsOnSide]);
	for j=1:nPositionsOnSide
    	for i=1:nPositionsOnSide
        	% absolute index into the array (input from previous line, right?)
        	k = sub2ind([nPositionsOnSide, nPositionsOnSide], i, j);

        	% interpolate the convolved prf onto the measurement positions 
        	prfValues(:,k) = interp2(ccdPlaneObject.psf(p).psfMeshCols, ...
            	ccdPlaneObject.psf(p).psfMeshRows, ccdPlaneObject.psf(p).prf, ...
            	prfInterpCols(j) - designMeshCol, ...
            	prfInterpRows(i) - designMeshRow, '*cubic', 0);  % Need the 0 for extrapolation

        	% cpix is the coefficient matrix representing the pixel response to motion
        	ccdPlaneObject.psf(p).prfPolyCoeffs(:,i,j) ...
            	= ccdPlaneObject.prfSolutionMatrix * prfValues(:,k);

        	if displayFlag
            	% generate the image from the coefficients (to compare to pix, the actual image)
            	prfFit(:,k) = ccdPlaneObject.prfDesignMatrix ...
                	* ccdPlaneObject.psf(p).prfPolyCoeffs(:,i,j);

            	% find the difference in the actual & fitted pixel response
            	% function
            	fitError(i,j) = std(prfValues(:,k) - prfFit(:,k));
        	end
    	end % i loop

    	waitbar(j/nPositionsOnSide);
	end % j loop
	close(h)
end
if displayFlag
    figure;
    imagesc(fitError*1e6)
    colorbar
    title(['plane ' num2str(ccdPlaneObject.planeNumber), ' prf RMS Fit Error, ppm'])
    xlabel(sprintf('i = %3i  j = %3i  k = %4i', i, j, k))
    drawnow
end

if displayFlag

    %Check for conservation of flux
    pixs    = permute(prfValues,[2,1]);
    pixs    = reshape(pixs,[nSubPixels*targetImageSize,nSubPixels*targetImageSize,nPointsWithMotion]);
    pixfits = permute(prfFit,[2,1]);
    pixfits = reshape(pixfits,[nSubPixels*targetImageSize,nSubPixels*targetImageSize,nPointsWithMotion]);

    for i = 1:nSubPixels   % nSubPixelsxnSubPixels subpixel grid
        for j = 1:nSubPixels
            pix11          = pixs(i:nSubPixels:end,j:nSubPixels:end,:);     %#ok
            fl11(:,i,j)    = squeeze(sum(sum(pix11)));    %#ok
            pixfit11       = pixfits(i:nSubPixels:end,j:nSubPixels:end,:);  %#ok
            flfit11(:,i,j) = squeeze(sum(sum(pixfit11))); %#ok
        end
    end

    fl11    = reshape(fl11,   [nPointsWithMotion,nSubPixels^2]);  %#ok
    flfit11 = reshape(flfit11,[nPointsWithMotion,nSubPixels^2]);  %#ok


    figure
    subplot(1,2,1);
    plot(fl11)
    title('original flux')
    xlabel('subpixel')
    ylabel('aperture-integrated flux')

    subplot(1,2,2);
    plot(flfit11)
    title('fitted flux')
    xlabel('subpixel')
    ylabel('aperture-integrated flux')
    drawnow

end

