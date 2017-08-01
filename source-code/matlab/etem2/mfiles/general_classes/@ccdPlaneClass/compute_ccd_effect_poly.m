function ccdPlaneObject = compute_ccd_effect_poly(ccdPlaneObject, ccdObject)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% function ccdPlaneObject = compute_ccd_effect_poly(ccdPlaneObject, ccdObject)
%
% apply ccd level effect e.g. saturation spill and cte to the ccd
% polynomial coefficients.
% based on the second half of gencccdnew.m
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

if exist(ccdPlaneObject.ccdPixelEffectPolyFilename, 'file')
    return;
end

runParamsObject = ccdPlaneObject.runParamsClass;
numVisibleRows = get(runParamsObject, 'numVisibleRows');
numVisibleCols = get(runParamsObject, 'numVisibleCols');
numMaskedSmear = get(runParamsObject, 'numMaskedSmear');
numVirtualSmear = get(runParamsObject, 'numVirtualSmear');
numLeadingBlack = get(runParamsObject, 'numLeadingBlack');
numTrailingBlack = get(runParamsObject, 'numTrailingBlack');
virtualSmearStart = get(runParamsObject, 'virtualSmearStart');
numCcdRows = get(runParamsObject, 'numCcdRows');
numCcdCols = get(runParamsObject, 'numCcdCols');
integrationTime = get(runParamsObject, 'integrationTime');
transferTime = get(runParamsObject, 'transferTime');
exposuresPerCadence = get(runParamsObject, 'exposuresPerCadence');
wellCapacity = get(get(ccdObject, 'electronsToAduObject'), 'maxElectronsPerExposure'); % we're working here with single exposures
nCoefs = get(runParamsObject, 'nCoefs');
endian = get(runParamsObject, 'endian');
% in this code we use wellCapacity to identify those pixels that may be in
% saturation.  Therefore we test against the smallest well capacity on this
% module output
wellCapacity = wellCapacity*min(min(get(ccdObject, 'wellDepthVariation')));
wellCapacity

pixelEffectObjectList = get(ccdObject, 'pixelEffectObjectList');

effectBufferSize = 7; % buffer to add on left so pixel downstream effects are included
numSegments = 20; % # of segments, for memory management, from ETEM1

% get the transpose of the prf matrices
prfDesignMatrixTpse = ccdPlaneObject.prfDesignMatrix';
prfSolutionMatrixTpse = ccdPlaneObject.prfSolutionMatrix';
numPrfDitherPoints = size(prfDesignMatrixTpse, 2); % dim 2 because it's the transpose

colsInSegment = (1:ceil(numCcdCols/numSegments));

nPrfs = length(ccdPlaneObject.psf);
% open and initialize the output coefficient file
fid = fopen(ccdPlaneObject.ccdPixelEffectPolyFilename,'w',endian);
for p=1:nPrfs
	for i = 1:nCoefs
    	count = fwrite(fid,zeros([numCcdRows,numCcdCols]),'float32'); % initialize
    	if count ~= numCcdRows*numCcdCols
        	error('Write error in compute_ccd_effect_poly.m');
    	end
	end
end
fclose(fid);

for psf=1:nPrfs
	thisSegmentCols = 0;
	ccdImageConstantTerm = zeros(numCcdRows, numCcdCols);

	figure;

	for segment = 1:numSegments
    	% set up indices of columns in this segment
    	thisSegmentCols = thisSegmentCols(end) + colsInSegment;
    	% trim any excess
    	thisSegmentCols = thisSegmentCols(thisSegmentCols <= numCcdCols);
        disp(['cols: ' num2str(thisSegmentCols(1)) ', ' num2str(thisSegmentCols(end))]);

    	% add a buffer to the left for effects
    	bufferedSegmentCols = max(1,thisSegmentCols(1)-effectBufferSize):thisSegmentCols(end);

    	% read in the ccd poly coefficients for this region for all 
    	ccdPolyCoefs = read_ccd_poly_segment(ccdPlaneObject, ...
        	ccdPlaneObject.ccdPixelPolyFilename, bufferedSegmentCols, psf);

    	% evaluate them on the prfPoly grid of dithered positions to create an
    	% image for each position
    	ccdImage = reshape(ccdPolyCoefs, ...
        	[length(bufferedSegmentCols)*numCcdRows, nCoefs]) ...
        	* prfDesignMatrixTpse; 
    	% reshape the image into a series of segment-sized arrays
    	ccdImage = reshape(ccdImage, ...
        	[numCcdRows, length(bufferedSegmentCols), numPrfDitherPoints]);

    	for p=1:numPrfDitherPoints
        	% Find the saturated pixels
        	[satRow, satCol] = find(ccdImage(:, :, p) > wellCapacity);

        	% spill saturation
        	% note that saturated charge cannot spill into the virtual rows
        	% but CAN spill onto the masked rows
        	ccdImage(1:virtualSmearStart-1, satCol, p) = ...
            	spill_saturation(ccdObject, ...
                ccdImage(1:virtualSmearStart-1, satCol, p), 1, ...
                1:virtualSmearStart-1, bufferedSegmentCols(1) + satCol - 1);

        	% apply pixel-level effects
        	for effect = 1:length(pixelEffectObjectList)
            	ccdImage(:, :, segment) ...
                	= apply_pixel_effect(pixelEffectObjectList{effect}, ccdImage(:,:,segment));
        	end
    	end

    	% fit new polynomials to the image over the PRF design range
    	% first reshape for the multiply, removing the effects buffer
    	ccdImage = reshape( ...
        	ccdImage(:,length(bufferedSegmentCols)-length(thisSegmentCols)+1:end,:), ...
        	[length(thisSegmentCols)*numCcdRows,numPrfDitherPoints]);
    	% now do the fit
    	ccdEffectSegmentPoly = ccdImage * prfSolutionMatrixTpse;

    	% save the result
    	write_ccd_poly_segment(ccdPlaneObject, ...
        	ccdPlaneObject.ccdPixelEffectPolyFilename, ccdEffectSegmentPoly, thisSegmentCols, psf);

    	ccdImageConstantTerm(:, thisSegmentCols) = reshape(ccdEffectSegmentPoly(:,1), ...
        	numCcdRows, length(thisSegmentCols));

    	imagesc(ccdImageConstantTerm, [0,1e4]);
    	colormap hot(256);
    	colorbar;
 		title(['drawing ccd effect poly for PRF ' num2str(psf)]);
   		drawnow;    
	end
end
