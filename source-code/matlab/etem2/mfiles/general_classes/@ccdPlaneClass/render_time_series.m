function render_time_series(ccdPlaneObject, ccdObject)
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
if exist(ccdPlaneObject.ccdTimeSeriesFilename, 'file')
    return;
end

runParamsObject = ccdPlaneObject.runParamsClass;
numCcdRows = get(runParamsObject, 'numCcdRows');
numCcdCols = get(runParamsObject, 'numCcdCols');
numVirtualSmear = get(runParamsObject, 'numVirtualSmear');
numMaskedSmear = get(runParamsObject, 'numMaskedSmear');
numLeadingBlack = get(runParamsObject, 'numLeadingBlack');
virtualSmearStart = get(runParamsObject, 'virtualSmearStart');
trailingBlackStart = get(runParamsObject, 'trailingBlackStart');
dvaMeshOrder = get(runParamsObject, 'dvaMeshOrder');
nCadences = get(runParamsObject, 'runDurationCadences');
nCoefs = get(runParamsObject, 'nCoefs');
planeNumber = ccdPlaneObject.planeNumber;
endian = get(runParamsObject, 'endian');
targetImageSize = get(runParamsObject, 'targetImageSize');
integrationTime = get(runParamsObject, 'integrationTime');
exposuresPerCadence = get(runParamsObject, 'exposuresPerCadence');
wellCapacity = get(get(ccdObject, 'electronsToAduObject'), 'maxElectronsPerExposure')*exposuresPerCadence;
supressAllMotion = get(runParamsObject, 'supressAllMotion');

% in this code we use wellCapacity to identify those pixels that may be in
% saturation.  Therefore we test against the smallest well capacity on this
% module output
wellCapacity = wellCapacity*min(min(get(ccdObject, 'wellDepthVariation')));

dataBufferSize = get(ccdObject, 'dataBufferSize');
nTargets = length(ccdPlaneObject.targetList);
pixelEffectObjectList = get(ccdObject, 'pixelEffectObjectList');

targetScienceManagerObject = get(ccdObject, 'targetScienceManagerObject');
targetScienceList = get(targetScienceManagerObject, 'targetList');
backgroundBinaryList = get(targetScienceManagerObject, 'backgroundBinaryList');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% prepare the pixels of interest

% get the pixels of interest structure
poiStruct = get(ccdObject, 'poiStruct');
targetStruct = ccdPlaneObject.targetStruct;
nTargets = length(targetStruct);
% find each target in the science properties list
for t=1:nTargets
	targetScienceProperties(t) = ...
		targetScienceList([targetScienceList.keplerId] == targetStruct(t).keplerId);
end

% get the flux polynomial coeffients for the pixels of interest
fid = fopen(ccdPlaneObject.ccdPixelEffectPolyFilename, 'r', endian);
targetFid = fopen(ccdPlaneObject.targetPolyFilename, 'r', endian);
nPrfs = length(ccdPlaneObject.psf);
for p=1:nPrfs
    % get the polynomials for the ccd pixels of interest
	psf(p).poiPixelCoefs = zeros(length(poiStruct.poiPixelIndex), nCoefs);
	for k=1:nCoefs
    	temp = fread(fid, [numCcdRows, numCcdCols], 'float32');
    	psf(p).poiPixelCoefs(:,k) = temp(poiStruct.poiPixelIndex);
    	clear temp;
    end
    % get the polynomials for the target images
    psf(p).targetImageCoefs = fread(targetFid, nCoefs*targetImageSize ...
        *targetImageSize*nTargets, 'float32')*integrationTime;
    psf(p).targetImageCoefs = reshape(psf(p).targetImageCoefs, ...
        [nCoefs, targetImageSize, targetImageSize, nTargets]);
    % reshape targetImageCoefs into a 2D array appropriate for evaluating
    % against the motion basis
    psf(p).targetImageCoefs = permute(psf(p).targetImageCoefs, [2,3,4,1]);
    psf(p).targetImageCoefs = reshape(psf(p).targetImageCoefs, ...
        targetImageSize*targetImageSize*nTargets, nCoefs);
end
fclose(fid);
fclose(targetFid);

% find the indices into the target image pixels of the CCD
% pixels of interest
% we will have two representations of target pixels: 
%	- target pixels that are in the pixels of interest in the 
%		numCcdRows x numCcdCols ccdSeries pixel space
%	- target pixels in the targetImageSize x targetImageSize x nTargets 
%		targetImages array created later
% ccdPlaneObject.allTargetImageIndices is the linear indices of each pixel 
% in targetImages in ccdSeries space.  In other words for each pixel in targetImage
% linear index of target pixel of interest in ccdSeries 
% = allTargetImages(linear index per target in targetImages)
% We want to know which of these pixels is in the pixels of interest set.
[tf targetImageIndexInPoi] = ismember(ccdPlaneObject.allTargetImageIndices, ...
    poiStruct.targetPoiIndex);
% tf is now an array same size as targetImages with true where a target pixel 
% is in the pixels of interest.  
% targetImageIndexInPoi is the index in ccdSeries space for the corresponding 
% target pixel that occurs in the targetImages.  Thus targetImageIndexInPoi 
% gives the linear index into ccdSeries for each pixel in targetImages.
%
% now we trim targetImageIndexInPoi to eliminate the zero values
targetImageIndexInPoi = targetImageIndexInPoi(targetImageIndexInPoi ~= 0);
% Look for the indices of the targetImages pixels that are in the POI
targetImagePoiPixelIndex = find(tf);
% targetImagePoiPixelIndex now contains the indices into targetImages for each
% target pixel that is in a POI.
% Finally we need the offsets of the target pixels in ccdSeries space for the target
% pixels that are in POIs.  This is just the values in allTargetImageIndices
targetImageIndexInCcd = ccdPlaneObject.allTargetImageIndices(tf);

% location of reference pixel in target image, useful for later
targetImageReferencePixel = (targetImageSize - 1)/2 + 1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% prepare the interpolation of the motion basis at each cadence

% get the positions at which the motion basis is given
motionGridRow = get(ccdObject, 'motionGridRow');
motionGridCol = get(ccdObject, 'motionGridCol');

% make the design matrix for fitting a 2D polynomial to motionBasis
mBasisInterpDesignM = make_binned_design_matrix(motionGridCol(:)/numCcdCols, ...
    motionGridRow(:)/numCcdRows,dvaMeshOrder);
% pre-compute the solution matrix used to solve for motion basis polynomial
% coefficients = mBasisInterpSolnM*motionBasis
mBasisInterpSolnM ...
    = (mBasisInterpDesignM'*mBasisInterpDesignM)\mBasisInterpDesignM'; % Precompute for convenience

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% prepare the design matrix for the polynomial evaluation at the pixels of
% interest. poiDesignM has # of pixels of interest rows
poiDesignM = make_binned_design_matrix(poiStruct.poiCol/numCcdCols, ...
    poiStruct.poiRow/numCcdRows, dvaMeshOrder);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% prepare the data for re-rendering the badly modeled pixels

badFitPixelStruct = get(ccdObject, 'badFitPixelStruct');
% load the pixel coefficients from ccdPixelPoly
numPartitions = length(badFitPixelStruct);
for part = 1:numPartitions
    pStruct = badFitPixelStruct(part);
    colRange = pStruct.colMin:pStruct.colMax;
    rowRange = pStruct.rowMin:pStruct.rowMax;
    % read in the ccdPixelPoly coefficients for each PRF
    % result if 3D matrix .coeffs(row,column,coeff)
    for p = 1:nPrfs
        badFitPixelStruct(part).poly(p).coeffs = read_ccd_poly_segment(...
            ccdPlaneObject, ccdPlaneObject.ccdPixelPolyFilename, colRange, p);
		% trim to the rows that we actually want and put in correct shape
		badFitPixelStruct(part).poly(p).coeffs = ...
			reshape(badFitPixelStruct(part).poly(p).coeffs(pStruct.rowMin:pStruct.rowMax, :, :), ...
			[pStruct.numRows*pStruct.numCols, nCoefs]);
    end
    
    % build motion matrix for each pixel in this partition
    [colMesh, rowMesh] = meshgrid(colRange, rowRange);
    badFitPixelStruct(part).designMatrix = ...
        make_binned_design_matrix(colMesh(:)/numCcdCols, ...
        rowMesh(:)/numCcdRows, dvaMeshOrder);
    % preallocate space for the solution matrix
    badFitPixelStruct(part).motionBasis = zeros(length(colMesh(:)), nCoefs);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% prepare the storage for the individual target images
targetImages = zeros(targetImageSize, targetImageSize, nTargets);
% for each target, mask off any overlapping pixels from other targets
targetMasks = zeros(size(targetImages));
for t=1:nTargets
	targetMask = zeros(targetImageSize);
	targetMask(targetStruct(t).poiImageIndex) = 1;
	% retain only pixels in the target image for this target definition
	targetMasks(:,:,t) = targetMask;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% prepare the data for background binaries
if ~isempty(backgroundBinaryList)
    for b=1:length(backgroundBinaryList)
        backgroundBinaryData(b).pixelPolyData = get(backgroundBinaryList(b).object, 'pixelPolyData');
        backgroundBinaryData(b).targetKeplerId = get(backgroundBinaryList(b).object, 'targetKeplerId');
    end
else
    backgroundBinaryData = [];
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% render the time series
dataBuffer = [];
ccdSeries = zeros(numCcdRows, numCcdCols);
outFid = fopen(ccdPlaneObject.ccdTimeSeriesFilename,'w',endian);
h = waitbar(0, ['computing time series plane ' num2str(planeNumber)]);
for cadence = 1:nCadences
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % build the motion basis at the pixels of interest for this cadence
    poiMotionBasis = zeros(length(poiStruct.poiRow), nCoefs);
    for k=1:nCoefs
        motionBasisCoefData = zeros(size(ccdPlaneObject.motionBasis));
        for r = 1:size(motionBasisCoefData,1)
            for c = 1:size(motionBasisCoefData,2)
				if supressAllMotion
					% the following construction removes all motion
					if k==1
                		motionBasisCoefData(r,c) = ccdPlaneObject.motionBasis(r,c).designMatrix(cadence, k);
					else
						motionBasisCoefData(r,c) = 0;
					end
				else
               		motionBasisCoefData(r,c) = ccdPlaneObject.motionBasis(r,c).designMatrix(cadence, k);
				end
            end
        end
        motionBasisCoef = mBasisInterpSolnM*motionBasisCoefData(:);
        poiMotionBasis(:, k) = poiDesignM*motionBasisCoef;
        % poiMotionBasis (# of pixels of interest) x nCoefs 

        % build the motion basis for each point in a bad fit region
        for part = 1:numPartitions
            badFitPixelStruct(part).motionBasis(:,k) = ...
                badFitPixelStruct(part).designMatrix*motionBasisCoef;
        end
    end
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% interpolate PRF polys over time if necessary
	if nPrfs > 1
		interpolatedPoiPixelCoefs = psf(1).poiPixelCoefs ...
            *(1 - (cadence - 1)/(nCadences - 1)) ...
            + psf(2).poiPixelCoefs*(cadence - 1)/(nCadences - 1);
		interpolatedTargetImageCoefs = psf(1).targetImageCoefs ...
            *(1 - (cadence - 1)/(nCadences - 1)) ...
            + psf(2).targetImageCoefs*(cadence - 1)/(nCadences - 1);
    else
		interpolatedPoiPixelCoefs = psf(1).poiPixelCoefs;
		interpolatedTargetImageCoefs = psf(1).targetImageCoefs;
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % actually render the ccd image for pixels of interest
	ccdSeries(poiStruct.poiPixelIndex) = ...
        sum(interpolatedPoiPixelCoefs.*poiMotionBasis, 2);
    
    if cadence == 1
        figure;
        imagesc(ccdSeries, [0, 1e6]);
        colormap(hot)
        title(['cadence 1 plane before correction ' num2str(planeNumber)]);
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % compute the poorly modeled regions
    for part = 1:numPartitions
        pStruct = badFitPixelStruct(part);
		% interpolate the PRF polys for the poorly modeled regions
        if nPrfs > 1
            interpolatedPartCoefs = pStruct.poly(1).coeffs ...
                *(1 - (cadence - 1)/(nCadences - 1)) ...
                + pStruct.poly(2).coeffs*(cadence - 1)/(nCadences - 1);
        else
            interpolatedPartCoefs = pStruct.poly(1).coeffs;
        end
        % actuall render the pixels
        partImage = reshape( ...
            sum(interpolatedPartCoefs.*pStruct.motionBasis, 2), ...
            [pStruct.numRows, pStruct.numCols]);
        % spill saturation
        partImage = spill_saturation(ccdObject, partImage, exposuresPerCadence, ...
            pStruct.rowMin:pStruct.rowMax, pStruct.colMin:pStruct.colMax);
        % apply other pixel-level effects
        for effect = 1:length(pixelEffectObjectList)
            partImage ...
                = apply_pixel_effect(pixelEffectObjectList{effect}, partImage);
        end
        % now place the  interior of the partitions in the original image
		if pStruct.rowMin <= 2 % if the saturation reaches into top of the masked smear, capture it all
			imageRowMin = 1;
            % set rowMin so that length(rowMin:pStruct.rowMax-2) =
            % length(imageRowMin:pStruct.numRows-2)
            rowMin = pStruct.rowMax - pStruct.numRows + 1;
		else
			rowMin = pStruct.rowMin+2;
			imageRowMin = 3;
		end
        ccdSeries(rowMin:pStruct.rowMax-2, ...
            pStruct.colMin+2:pStruct.colMax-2) = partImage(imageRowMin:end-2, 3:end-2);
    end
    if cadence == 1
        figure;
        imagesc(ccdSeries, [0, 1e6]);
        colormap(hot)
        title(['cadence 1 plane after correction ' num2str(planeNumber)]);
    end
  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   % render the individual target images
    targetImages(targetImagePoiPixelIndex) = ...
        sum(interpolatedTargetImageCoefs(targetImagePoiPixelIndex, :) ...
        .* poiMotionBasis(targetImageIndexInPoi, :), 2);
		
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% modulate the target images according to science properties
	
	
	% declare useful global diagnostic matrices
%	newTargetImages = targetImages;
%	newTargetMask = zeros(size(targetImages));
%	deltaTargetImages = zeros(size(targetImages));
%	oldCcdSeries = ccdSeries;
	for t=1:nTargets
		thisTargetStruct = targetStruct(t);
		targetImage = targetImages(:,:,t).*targetMasks(:,:,t);
		% spill saturated charge in the target image
		if any(any(targetImage >= wellCapacity*exposuresPerCadence))
			targetImage = spill_saturation(ccdObject, targetImage, ...
                exposuresPerCadence, ...
                ccdPlaneObject.targetImageIndices(t).rowRange, ...
                ccdPlaneObject.targetImageIndices(t).colRange);
		end
		% apply the science light curve for this target
		newTargetImage = targetImage*targetScienceProperties(t).compositeLightCurve(cadence);
		% compute the change in brightness for this target's pixels
		deltaTargetImage =  newTargetImage - targetImage;
		% modify the ccd pixels for this target
		ccdSeries(ccdPlaneObject.targetImageIndices(t).ccdIndices) = ...
			ccdSeries(ccdPlaneObject.targetImageIndices(t).ccdIndices) ...
			+ deltaTargetImage;
		% useful global diagnostic matrices
%		newTargetMask(:,:,t) = targetMask;
%		newTargetImages(:,:,t) = newTargetImage;
%		deltaTargetImages(:,:,t) = deltaTargetImages(:,:,t) + deltaTargetImage;
	end
    if cadence == 1
        figure;
        imagesc(ccdSeries, [0, 1e6]);
        colormap(hot)
        title(['cadence 1 plane after modulation ' num2str(planeNumber)]);
    end
		
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% compute background binary pixel coefficients
	for b=1:length(backgroundBinaryData)
        pixelPolyCoefs = backgroundBinaryData(b).pixelPolyData.pixelPolyCoefs;
        if length(pixelPolyCoefs) > 1
            interpolatedBBinPixelCoefs = pixelPolyCoefs(1).coefs ...
                *(1 - (cadence - 1)/(nCadences - 1)) ...
                + pixelPolyCoefs(2).coefs*(cadence - 1)/(nCadences - 1);
        else
            interpolatedBBinPixelCoefs = pixelPolyCoefs(1).coefs;
        end
        % render the background binary pixels 
        backgroundBinaryImage = ...
            sum(interpolatedBBinPixelCoefs(backgroundBinaryData(b).pixelPolyData.bgBinPixelPoiPixelIndex, :) ...
            .* poiMotionBasis(backgroundBinaryData(b).pixelPolyData.bgBinPixelIndexInPoi, :), 2);
        % modulate the background binary pixels and add to target pixels
        ccdSeries(backgroundBinaryData(b).pixelPolyData.bgBinPixelIndexInCcd) ...
            = ccdSeries(backgroundBinaryData(b).pixelPolyData.bgBinPixelIndexInCcd) ...
            + backgroundBinaryImage*backgroundBinaryList(b).lightCurve(cadence);
    end
    
		
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% save rendered pixels
	
    dataBuffer = [ dataBuffer; ccdSeries(poiStruct.poiPixelIndex) ];
    if length(dataBuffer) > dataBufferSize
        fwrite(outFid, dataBuffer, 'float32');
        dataBuffer = [];
    end
        
    waitbar(cadence/nCadences, h, ['plane ' num2str(planeNumber) ...
        ', cadence ' num2str(cadence) '/' num2str(nCadences)]);

    if ~mod(cadence, 500)
        display(['plane '  num2str(planeNumber) ...
            ' time series, cadence ' num2str(cadence) ' of ' num2str(nCadences)]);
    end
end % end loop over cadences to render pixels
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if ~isempty(dataBuffer)
    fwrite(outFid, dataBuffer, 'float32');
end

fclose(outFid);
close (h);


