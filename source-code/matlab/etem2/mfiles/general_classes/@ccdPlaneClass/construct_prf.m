function ccdPlaneObject = construct_prf(ccdPlaneObject, ccdObject)
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

runParamsObject = ccdPlaneObject.runParamsClass;
chargeDiffusionSigma = get(runParamsObject, 'chargeDiffusionSigma');
chargeDiffusionArraySize = get(runParamsObject, 'chargeDiffusionArraySize');

displayFlag = 0;

numPsfs = length(ccdPlaneObject.psfObject);

for p = 1:numPsfs
	% get the psf for this ccd plane
	% grid resolution is in microns per grid point
	[psf, psfResolution] = get_psf(ccdPlaneObject.psfObject(p));
	% psfResolution is the size in microns of a single grid cell
	%normalize the psf
	psf = psf/sum(sum(psf));

    % add charge diffusion.  Allow for different-sized psfs
	% pre-compute the charge diffusion kernel
	psfX = (0:chargeDiffusionArraySize-1)*psfResolution;
	psfY = (0:chargeDiffusionArraySize-1)*psfResolution;
	[X, Y] = meshgrid(psfX,psfY);
	% put the center of 
	Cx = psfX(ceil(chargeDiffusionArraySize/2)); % chargeDiffusionArraySize is odd
	Cy = psfY(ceil(chargeDiffusionArraySize/2));
	chargeDiffusionKernel = exp(-(power(X-Cx,2)+power(Y-Cy,2))/chargeDiffusionSigma^2);
	chargeDiffusionKernel = chargeDiffusionKernel/sum(sum(chargeDiffusionKernel));
	
    DiffusedPsf = conv2(psf, chargeDiffusionKernel, 'same');
	if displayFlag
		figure;
		subplot(1,3,1);
% 		mesh(psf(1:10:end, 1:10:end));
		imagesc(psf);
		title('original PSF');
		subplot(1,3,2);
		mesh(chargeDiffusionKernel);
		title('charge diffusion kernel');
		subplot(1,3,3);
% 		mesh(DiffusedPsf(1:10:end, 1:10:end));
		imagesc(DiffusedPsf);
		title('diffuse PSF');
	end
        
	% compute the intrapixel variability
	intraPixVariability = make_intrapix_variability(ccdObject, ...
    	psfResolution);
	% compute the initial prf as a convolution of the psf and intra-pixel
	% variability
	ccdPlaneObject.psf(p).prf = conv2(DiffusedPsf, intraPixVariability, 'same');

	pixelWidth = get(ccdPlaneObject.runParamsClass, 'pixelWidth');
	% set up the interpolation mesh for the computation of the prf polynomial
	[psfRowCentroid, psfColCentroid] = quick_centroid(psf);
	r = ((1:size(psf,1)) - psfRowCentroid) / (pixelWidth/psfResolution);
	c = ((1:size(psf,2)) - psfColCentroid) / (pixelWidth/psfResolution);

	[ccdPlaneObject.psf(p).psfMeshCols, ccdPlaneObject.psf(p).psfMeshRows] = meshgrid(r(:),c(:));
end
