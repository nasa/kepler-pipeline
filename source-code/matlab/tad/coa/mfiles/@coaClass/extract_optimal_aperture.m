function coaObject = extract_optimal_aperture(coaObject)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function coaObject = extract_optimal_aperture(coaObject)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Computes the optimal pixels for each target star by comparing the signal
% from the target star with the signal from the background.  This code very
% closely follows ETEM
% 
% Adds following fields to coaObject:
%   .completeOutputImage ccd output image including effects of smear, CTE,
%       saturation spill, zodiacal light
%   adds the following fields to .targetImages():
%       .optimalPixels optimal aperture image for this target
%       .signalToNoiseRatio signal-to-noise ratio for the optimal aperture for this target
%       .crowdingMetric crowding metric for this target
%       .fluxFractionInAperture fraction of target flux in optimal aperture
%       .offsets structure containing this target's optimal aperture
%           containing
%           .offsetsx, .offsetsy arrays of offsets for pixels in the aperture
% 
% 
% Copyright 2017 United States Government as represented by the
% Administrator of the National Aeronautics and Space Administration.
% All Rights Reserved.
% 
% NASA acknowledges the SETI Institute's primary role in authoring and
% producing the Kepler Data Processing Pipeline under Cooperative
% Agreement Nos. NNA04CC63A, NNX07AD96A, NNX07AD98A, NNX11AI13A,
% NNX11AI14A, NNX13AD01A & NNX13AD16A.
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

rand('seed', 0);
randn('seed', 0);

% load some useful quantities
readNoiseSquared = coaObject.pixelModelStruct.readNoiseSquared;
% constant quantization noise may be replaced with a model dependent on pixel value
quantizationNoiseSquared = coaObject.pixelModelStruct.quantizationNoiseSquared;
virtualSmear = coaObject.moduleDescriptionStruct.virtualSmear;
maskedSmear = coaObject.moduleDescriptionStruct.maskedSmear;
leadingBlack = coaObject.moduleDescriptionStruct.leadingBlack;
trailingBlack = coaObject.moduleDescriptionStruct.trailingBlack;
nRowPix = coaObject.moduleDescriptionStruct.nRowPix;
nColPix = coaObject.moduleDescriptionStruct.nColPix;
wellCapacity = coaObject.pixelModelStruct.wellCapacity;
cadenceTime = coaObject.pixelModelStruct.cadenceTime;
integrationTime = coaObject.pixelModelStruct.integrationTime;
flatFieldImage = coaObject.flatFieldImage;
flatFieldImage = flatFieldImage(maskedSmear+1:maskedSmear+nRowPix, leadingBlack+1:leadingBlack+nColPix);

debugFlag = coaObject.debugFlag;

% targetDebug triggers run-time display of optimal apertures
targetDebug = 0;

% get synthetic ccd image from inputs
outputImage = coaObject.outputImage;

% compute background level (zodi) values
zodiCcdImage = compute_zodi_image(coaObject);
% apply the flat field to the zodi image
zodiCcdImage = zodiCcdImage.*flatFieldImage;

% compute completeOutputImage
% completeOutputImage will be the image after adding all effects, e.g.
% zodi, smear, spill of saturation and cte.
completeOutputImage = outputImage;
% 1) add zodiacal light signal
completeOutputImage = add_zodi(coaObject, completeOutputImage, zodiCcdImage);
% 2) add smear effects
[completeOutputImage smearValues] = add_smear(coaObject, completeOutputImage);
% 3) spill saturated charge
completeOutputImage = spill_saturation(coaObject, completeOutputImage);
% 4) add saturated pixels from the saturation map
completeOutputImage = add_saturation_map(coaObject, completeOutputImage);
% 5) add effects of charge transfer efficiency
completeOutputImage = add_cte(coaObject, completeOutputImage);

% create a version of the output image with zodi removed for computation of the crowding metric
completeCrowdingImage = completeOutputImage - zodiCcdImage;

if debugFlag
    % draw the results
    figure;
    imagesc(completeOutputImage, [0, coaObject.pixelModelStruct.wellCapacity]);
    colormap hot(256);
    colorbar
    
    figure;
    imagesc(log10(completeOutputImage + 1e-6));
    colormap hot(256);
    colorbar
end

targetImages = coaObject.targetImages; % for convenience
nTargets = length(targetImages);
if targetDebug % set up optimal aperture figures if desired
    figure;
    targetDebugFigure = gcf;
    figure;
    targetDebugFigure2 = gcf;
    figure;
    targetDebugFigure3 = gcf;
end
% pre-allocate the output structure
% optimalApertures struct is shared with PA-COA, So this struct must also have fields for those set by PA-COA
offsetsStruct = struct( ...
        'row', 0, ...
        'column', 0);
optimalApertures = repmat( ...
    struct( ...
        'keplerId', 0, ...              
        'signalToNoiseRatio', 0, ...                  
        'fluxFractionInAperture', 0, ...              
        'crowdingMetric', 0, ...                      
        'skyCrowdingMetric', 0, ...                   
        'badPixelCount', 0, ...                       
        'distanceFromEdge', 0, ...                    
        'referenceRow', 0, ...                        
        'referenceColumn', 0, ...                     
        'saturatedRowCount', 0, ...                   
        'offsets', offsetsStruct, ...
        'apertureUpdatedWithPaCoa', false), ...
         1, nTargets);

for t=1:nTargets % for each target in .TargetImages
%     disp(['target ' num2str(t)]);
    % extract column containing this target
    % we need the entire column to allow computation of smear
    % get the offsets for imbedding the image into the CCD
    imageRange = targetImages(t).imageRange;
    pixRange = targetImages(t).pixRange;
    % get the target's columns of outputImage (without smear etc.)
    targetBackgroundColumn = outputImage(:, imageRange(3):imageRange(4));
    if targetDebug
        targetBackgroundColumn_target = targetBackgroundColumn;
    end
    %subtract off target image to get column without target
    targetBackgroundColumn(imageRange(1):imageRange(2), :) = ...
        targetBackgroundColumn(imageRange(1):imageRange(2), :) - ...
        targetImages(t).image(pixRange(1):pixRange(2), pixRange(3):pixRange(4));
    if targetDebug
        targetBackgroundColumn_notarget = targetBackgroundColumn;
    end
    % now compute the complete column image in the absense of the target
    % 1) add zodiacal light signal
    targetBackgroundColumn = add_zodi(coaObject, targetBackgroundColumn, ...
        zodiCcdImage(:, imageRange(3):imageRange(4)));
    % 2) add smear effects
    targetBackgroundColumn = add_smear(coaObject, targetBackgroundColumn);
    % 3) spill saturated charge
    targetBackgroundColumn = spill_saturation(coaObject, targetBackgroundColumn);
    % 4) add saturated pixels from the saturation map
    targetBackgroundColumn = add_saturation_map(coaObject, ...
        targetBackgroundColumn, [imageRange(3) imageRange(4)], targetImages(t).KICID);
    % 5) add effects of charge transfer efficiency
    targetBackgroundColumn = add_cte(coaObject, targetBackgroundColumn);
    if targetDebug
        targetBackgroundColumn_processed = targetBackgroundColumn;
    end
    
    % compute the target image in this column by subtracting the
    % background column from the appropriate column of the complete image
    targetImageColumn = completeOutputImage(:, imageRange(3):imageRange(4)) - ...
        targetBackgroundColumn;
    
    % now get the optimal pixels
    % pick out appropriately sized square images based on the offsets
    % targetImage is the image containing signal from the target only
    % first identify range of rows that contain saturated pixels
    [satRows, satCols] = find(integrationTime*targetImageColumn/cadenceTime > 0.9*wellCapacity);
    % clip the targetImageColumn to the larger of the image size or the
    % saturated image size
    if isempty(satRows)
        topImageRow = imageRange(2);
        bottomImageRow = imageRange(1);
        saturatedRowCount = 0;
    else
        topImageRow = max(imageRange(2), max(satRows));
        bottomImageRow = min(imageRange(1), min(satRows));
        saturatedRowCount = max(satRows) - min(satRows) + 1;
        if isempty(coaObject.saturationObject)
            saturationSpillBufferSize = coaObject.coaConfigurationStruct.saturationSpillBufferSize;
            % extend image size by the saturation buffer
            % compute the center of the image
            % assume the star is in the center of the image
            midImageRow = mean(imageRange(1:2));
            satRowUp = max(satRows) - midImageRow;
            satRowDown = midImageRow - min(satRows);

            saturationSpillUpFraction = coaObject.pixelModelStruct.saturationSpillUpFraction;
            extendUpFactor = max(1, saturationSpillBufferSize/saturationSpillUpFraction);
            extendDownFactor = max(1, saturationSpillBufferSize/(1-saturationSpillUpFraction));

            topSatRow = fix(midImageRow + extendUpFactor*satRowUp) + 1;
            topSatRow = min(nRowPix, topSatRow);
            topImageRow = max(topImageRow, topSatRow);
            topImageRow = min(nRowPix, topImageRow);

            bottomSatRow = fix(midImageRow - extendDownFactor*satRowDown) - 1;
            bottomSatRow = max(1, bottomSatRow);
            bottomImageRow = min(bottomImageRow, bottomSatRow);
            bottomImageRow = max(1, bottomImageRow);
        end
    end
    targetImage = targetImageColumn(bottomImageRow:topImageRow,:);
    targetImage(:,1) = 0; % zero out left-most column because it is confused by TCE
    % targetBackground is the image containing signal from the background only
    targetBackground = targetBackgroundColumn(bottomImageRow:topImageRow,:);
    % create linear versions of the arrays for convenience
    targetImageLinear = targetImage(:);
    targetBackgroundLinear = targetBackground(:); 
    
    % initialize counting variables.  
    % optimalPixelIndex will be a list of indices of chosen optimal pixels
    optimalPixelIndex = zeros(size(targetImageLinear));
    % optimalPixels is a mask = 1 in position of an optimal pixel
    optimalPixels = zeros(size(targetImageLinear));

    % find snr of all pixels in image by taking ratio of target image to
    % the noise due to the target and background shot noise and other noise sources
    pixSNR = targetImageLinear ./ ... % target signal
        sqrt(targetImageLinear + ... % target shot noise (including smear)
        targetBackgroundLinear + ... % background shot noise (including smear)
        readNoiseSquared + ...% read noise
        quantizationNoiseSquared); % quantization noise
    % look for pixel with highest SNR
    optimalPixelIndex(1) = findimax(pixSNR);
    % find which pixel it is in the target image.  This is our starting
    % point
    [row,col] = ind2sub(size(targetImage), optimalPixelIndex(1));
    referencePixel = [row,col];
    % the aperture SNR = sum(targetImage pixels) / sum(noise for those
    % pixels) where the sum is over pixels in the aperture.
    % now loop over the number pixels in targetImageLinear, and
    % in each loop try all remaining pixels in targetImageLinear
    % and choose the pixel that provide greatest increase in the 
    % summed aperture SNR
    allPixels = 1:length(targetImageLinear); % useful initializer
    for p=2:length(targetImageLinear) % start with 2 'cause we already have the first
        % get the pixels that have already been chosen as optimal
        pixelsAlreadyChosenIndex = optimalPixelIndex(1:p-1);
        % initialize the remainingPixels
        remainingPixelsIndex = allPixels;
        % remove the pixels that have already been chosen
        remainingPixelsIndex(pixelsAlreadyChosenIndex) = []; 
        % the result is an array containing only pixels that have not been
        % chosen.
        % form the array of signals as the (scalar) sum over the previously chosen
        % pixels plus the array of remaining pixels.  The result is an
        % array containing candidate signals depending on which remaining
        % pixel is chosen.
        targetSignal = sum(targetImageLinear(pixelsAlreadyChosenIndex)) + ...
            targetImageLinear(remainingPixelsIndex);
        % compute the corresponding noise signal, which is the shot noise
        % from the previous chosen pixels (the scalar part) plus the shot
        % noise from each candidate remaining pixel (the array part) plus
        % other noise sources
        targetNoise = sqrt(sum(targetImageLinear(pixelsAlreadyChosenIndex) +...
            targetBackgroundLinear(pixelsAlreadyChosenIndex) + ...
            readNoiseSquared + ...
            quantizationNoiseSquared) + ... % this completes the sum over previously chosen pixels
            targetImageLinear(remainingPixelsIndex) +... % shot noise from candidate signal pixels
            targetBackgroundLinear(remainingPixelsIndex) + ... % shot noise from candidate background pixels
            readNoiseSquared + ...
            quantizationNoiseSquared);
        % pixSNR is an array of SNRs for each candidate remaining pixel
        pixSNR = targetSignal./targetNoise;
        % pick the one with the highest resulting SNR
        optimalPixelIndex(p) = remainingPixelsIndex(findimax(pixSNR));
    end
    % we have the pixels in order of increasing contribution of SNR, but
    % the sum of these pixels will not constantly increase: at some point
    % the signal is small and the noise large so adding a pixel decreases
    % the total SNR even though that pixel maximized the SNR that was
    % added.  We have to find the last pixel that causes the SNR of the sum
    % up to that pixel to increase.
    % compute the SNR as a function of pixels as added in order via a
    % cumulative sum
    apertureSNR = cumsum(targetImageLinear(optimalPixelIndex)) ./ ...
        sqrt(cumsum(targetImageLinear(optimalPixelIndex) +...
            targetBackgroundLinear(optimalPixelIndex) + ...
            readNoiseSquared + ...
            quantizationNoiseSquared));
    % apertureSNR should be a curve with a maximum value.  Choose those
    % pixels that contribute to the maximum and reject those after.
    % find the index of the maximum of apertureSNR
    apertureCutoff = findimax(apertureSNR);
    % choose the optimal pixels to be all pixels up to and including the
    % apertureCutoff index.
    optimalPixels(optimalPixelIndex(1:apertureCutoff)) = 1;
    % reshape the linear optimalPixels to be an image matching the size of
    % targetImage
    optimalPixels = reshape(optimalPixels, size(targetImage));
    
    if isempty(coaObject.saturationObject)
        % now add the saturation buffer if necessary
        if ~isempty(satRows)
            minSatCol = min(satCols);
            maxSatCol = max(satCols);
            optimalPixels((bottomSatRow:topSatRow) - bottomImageRow + 1,minSatCol:maxSatCol) = 1;
        end
    end

    % compute the crowding metric
    % first get the flux due to the target
    % use only the pixels in the original target image that are non-zero
    originalTargetImage = targetImages(t).image(pixRange(1):pixRange(2), pixRange(3):pixRange(4));
    nonZeroTargetImage = originalTargetImage>0;
    
    % compute the crowding metric with respect to the optimal aperture
    % compute the target flux in the optimal aperture mask
    targetFlux = sum(sum(targetImage.*optimalPixels));
    targetOutputImage = ...
        completeCrowdingImage(bottomImageRow:topImageRow, imageRange(3):imageRange(4));
    % compute the total flux in the nonZeroTargetImage mask
    totalFlux = sum(sum(targetOutputImage.*optimalPixels));
    % take the ratio of target flux to total flux to determine the fraction
    % of flux in the mask due to the target.
    if (totalFlux > 0)
        crowdingMetric = targetFlux/totalFlux;
    else
        crowdingMetric = 0;
    end
    
    % compute the crowding metric with respect to the local sky
    % compute the target flux in the nonZeroTargetImage mask
    targetFlux = sum(sum(originalTargetImage.*nonZeroTargetImage));
    targetOutputImage = ...
        outputImage(imageRange(1):imageRange(2), imageRange(3):imageRange(4));
    % compute the total flux in the nonZeroTargetImage mask
    totalFlux = sum(sum(targetOutputImage.*nonZeroTargetImage));
    % take the ratio of target flux to total flux to determine the fraction
    % of flux in the mask due to the target.
    if (totalFlux > 0)
        skyCrowdingMetric = targetFlux/totalFlux;
    else
        skyCrowdingMetric = 0;
    end
    
    % compute the fraction of flux in the optimal aperture
    optimalFlux = sum(sum(targetImage.*optimalPixels));
    totalFlux = sum(sum(targetImage));
    if (targetFlux > 0)
        fluxFractionInAperture = optimalFlux/totalFlux;
    else
        fluxFractionInAperture = 0;
    end
        
    if (targetDebug && rand() < 1/100)
        % if desired draw some optimal apertures
        figure(targetDebugFigure);
        subplot(2,3,1);
        imagesc(targetBackgroundColumn_target(bottomImageRow:topImageRow, :), ...
            [0, coaObject.pixelModelStruct.wellCapacity]);
        title(['target ' num2str(t) 'complete output image']);
        colormap hot(256);
    
        subplot(2,3,2);
        imagesc(targetBackgroundColumn_notarget(bottomImageRow:topImageRow, :), ...
            [0, coaObject.pixelModelStruct.wellCapacity]);
        title('background without target');
        colormap hot(256);
    
        subplot(2,3,3);
        imagesc(targetBackgroundColumn_processed(bottomImageRow:topImageRow, :), ...
            [0, coaObject.pixelModelStruct.wellCapacity]);
        title('background with smear etc.');
        colormap hot(256);
    
        subplot(2,3,4);
        imagesc(targetImageColumn(bottomImageRow:topImageRow, :), ...
            [0, coaObject.pixelModelStruct.wellCapacity]);
        title(['target image, crowding metric = ' num2str(crowdingMetric)]);
        colormap hot(256);
    
        subplot(2,3,5);
        imagesc(log10(targetImageColumn(bottomImageRow:topImageRow, :) + 1e-6));
        title('log(target image)');
        colormap hot(256);
    
        subplot(2,3,6);
        imagesc(optimalPixels);
        title('optimal aperture');
        colormap hot(256);
        
        figure(targetDebugFigure2);  
        plot(apertureSNR);
        
        figure(targetDebugFigure3);
        subplot(1,3,1);
        imagesc(originalTargetImage, ...
            [0, coaObject.pixelModelStruct.wellCapacity]);
        title(['target ' num2str(t) ' targetImage']);
        colormap hot(256);
        
        subplot(1,3,2);
        imagesc(targetOutputImage, ...
            [0, coaObject.pixelModelStruct.wellCapacity]);
        title(['output image, crowding metric = ' num2str(crowdingMetric) ...
            'fluxFraction = ' num2str(fluxFractionInAperture)]);
        colormap hot(256);
        
        subplot(1,3,3);
        imagesc(nonZeroTargetImage);
        title('non-zero pixels');
       pause;
    end
    
    % set the outputs.  OptimalApertures is pre-allocated in coaClass.m
    optimalApertures(t).keplerId = targetImages(t).KICID;
    optimalApertures(t).signalToNoiseRatio = apertureSNR(apertureCutoff);
    optimalApertures(t).crowdingMetric = crowdingMetric;
    optimalApertures(t).skyCrowdingMetric = skyCrowdingMetric;
    optimalApertures(t).fluxFractionInAperture = fluxFractionInAperture;
    optimalApertures(t).saturatedRowCount = saturatedRowCount;
    % compute the coordinate offset transforming from image coordinates to
    % CCD coordinates
    rowOffset = bottomImageRow + maskedSmear - 1;
    colOffset = imageRange(3) + leadingBlack - 1;
    optimalApertures(t).referenceRow = referencePixel(1) ...
        + rowOffset;
    optimalApertures(t).referenceColumn = referencePixel(2) ...
        + colOffset;
    % transform the CCD bounding box to image coordinate bounding box
    imageBBox = [maskedSmear + 1 - rowOffset, ...
        maskedSmear + nRowPix - rowOffset, ...
        leadingBlack + 1 - colOffset, ...
        leadingBlack + nColPix - colOffset];
    % set the target definition, giving offsets to module coordinates
    targetDefinitionStruct = ...
        image_to_target_definition(optimalPixels, referencePixel, imageBBox);
    optimalApertures(t).offsets = targetDefinitionStruct.offsets;
	if isempty(optimalApertures(t).offsets)
		warning('no optimal aperture assigned to target');
	end
    % get the bad pixel count.  This is a placeholder until the api is
    % designed
%     targetImages(t).badPixelCount = get_bad_pixel_count(...
%         targetImages(t).referenceRow, targetImages(t).referenceColumn, ...
%         targetImages(t).offsets);
    optimalApertures(t).badPixelCount = 0;
	
	apertureRows = optimalApertures(t).referenceRow + ...
		[optimalApertures(t).offsets.row] - maskedSmear;
	apertureCols = optimalApertures(t).referenceColumn + ...
		[optimalApertures(t).offsets.column] - leadingBlack;
	rowDistanceFromEdge = min([min(apertureRows) - 1, nRowPix - max(apertureRows)]);
	colDistanceFromEdge = min([min(apertureCols) - 1, nColPix - max(apertureCols)]);
    optimalApertures(t).distanceFromEdge = min(rowDistanceFromEdge, colDistanceFromEdge);
	
    targetImages(t).optimalPixels = optimalPixels;
    if targetImages(t).magnitude == 30
        optimalApertures(t).offsets = [];
    end
end
coaObject.optimalApertures = optimalApertures;
coaObject.targetImages = targetImages;
% imbed the output image in a the ccd image containing smear and black
% pixels
outImage = zeros(size(completeOutputImage) + ...
    [maskedSmear + virtualSmear, leadingBlack + trailingBlack]);
outImage(maskedSmear+1:maskedSmear+nRowPix, ...
    leadingBlack+1:leadingBlack+nColPix) = completeOutputImage;
outImage(1:maskedSmear, ...
    leadingBlack+1:leadingBlack+nColPix) = repmat(smearValues, maskedSmear, 1);
outImage(maskedSmear+nRowPix+1:maskedSmear+nRowPix+virtualSmear, ...
    leadingBlack+1:leadingBlack+nColPix) = repmat(smearValues, virtualSmear, 1);
% convert to a structure array that makes java happy
coaObject.completeOutputImage = array2D_to_struct(outImage);
% we've imbedded the image in the full CCD space including collatoral
% pixels, so transform the offsets as well
coaObject.minRow = coaObject.minRow + maskedSmear;
coaObject.maxRow = coaObject.maxRow + maskedSmear;
coaObject.minCol = coaObject.minCol + leadingBlack;
coaObject.maxCol = coaObject.maxCol + leadingBlack;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function outImage = add_zodi(coaObject, inImages)
%
% add a zodiacal light model to the input image
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function outImage = add_zodi(coaObject, inImage, zodiCcdImage)
outImage = inImage + zodiCcdImage;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function outImage = add_smear(coaObject, inImage)
%
% add smear to the input image
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [outImage smear] = add_smear(coaObject, inImage)
% get the parameters we need to convert to appropriate units and take
% appropriate average
cadenceTime = coaObject.pixelModelStruct.cadenceTime;
transferTime = coaObject.pixelModelStruct.transferTime;
exposuresPerCadence = coaObject.pixelModelStruct.exposuresPerCadence;
nRowPix = coaObject.moduleDescriptionStruct.nRowPix;
virtualSmear = coaObject.moduleDescriptionStruct.virtualSmear;
maskedSmear = coaObject.moduleDescriptionStruct.maskedSmear;
% compute smear as the average over each column, being sure to include the
% smear pixels
smear = exposuresPerCadence*transferTime*...
    sum(inImage, 1)/(cadenceTime * (nRowPix + virtualSmear + maskedSmear));
% add the smear to the image as that average on each pixel of the column
outImage = inImage + repmat(smear, size(inImage,1), 1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function outImage = spill_saturation(coaObject, inImage)
%
% spill the saturated charge as the well fills up
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function outImage = spill_saturation(coaObject, inImage)
wellCapacity = coaObject.pixelModelStruct.wellCapacity;
saturationSpillUpFraction = coaObject.pixelModelStruct.saturationSpillUpFraction;
cadenceTime = coaObject.pixelModelStruct.cadenceTime;
integrationTime = coaObject.pixelModelStruct.integrationTime;
% Have to convert flux in a long cadence to flux
% in an integration time and back again
% then call a function from ETEM
outImage = spill_sat(integrationTime*inImage/cadenceTime,...
    wellCapacity, saturationSpillUpFraction);
outImage = cadenceTime*outImage/integrationTime;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function outImage = add_cte(coaObject, inImage)
%
% apply the effects of charge transfer efficiency
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function outImage = add_cte(coaObject, inImage)
parallelCTE = coaObject.pixelModelStruct.parallelCTE;
serialCTE = coaObject.pixelModelStruct.serialCTE;

% compute the effects of the charge not quite moving perfectly as the
% pixels are clocked out
packet = 0;
tmpImage = inImage;
for i=1:size(inImage, 1)
    packet = (1-parallelCTE)*packet + inImage(i,:);
    tmpImage(i,:) = parallelCTE*packet;
end
 
packet = 0;
outImage = tmpImage;
for i=1:size(inImage, 2)
    packet = (1-serialCTE)*packet + inImage(:,i);
    outImage(:,i) = serialCTE*packet;
end
 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function zodiImage = compute_zodi_image(coaObject)
%
% estimate the background level due to a zodi model
% or by evaluating the background polynomials
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function zodiImage = compute_zodi_image(coaObject)

% for zodi computation
startTimeJulian = datestr2julian(coaObject.startTime);
startTimeMjd = datestr2mjd(coaObject.startTime);
duration = coaObject.duration;
dvaMeshOrder = coaObject.coaConfigurationStruct.dvaMeshOrder;
nDvaMeshRows = coaObject.coaConfigurationStruct.nDvaMeshRows;
nDvaMeshCols = coaObject.coaConfigurationStruct.nDvaMeshCols;
raOffset = coaObject.coaConfigurationStruct.raOffset;
decOffset = coaObject.coaConfigurationStruct.decOffset;
phiOffset = coaObject.coaConfigurationStruct.phiOffset;
backgroundPolynomialsEnabled = ...
    coaObject.coaConfigurationStruct.backgroundPolynomialsEnabled;
module = coaObject.module;
output = coaObject.output;
nRowPix = coaObject.moduleDescriptionStruct.nRowPix;
nColPix = coaObject.moduleDescriptionStruct.nColPix;
cadenceTime = coaObject.pixelModelStruct.cadenceTime;
flux12 = coaObject.pixelModelStruct.flux12;
maskedSmear = coaObject.moduleDescriptionStruct.maskedSmear;
leadingBlack = coaObject.moduleDescriptionStruct.leadingBlack;

% use simple zodi model to estimate the background level per cadence if
% background polynomials are not enabled, otherwise use the background
% polynomials to estimate the background level
if ~backgroundPolynomialsEnabled
    
    % compute zodiacal light image by computing zodi signal on a coarse mesh
    % then interpolating all pixels
    % co-opt the dva mesh since we are building the same kind of polynomial
    % first construct grid on which to compute zodi signal. 
    % nDvaMeshRows and nDvaMeshCols points equally
    % spaced across a CCD as defined in the moduleDataStruct.
    [zodiMeshCol, zodiMeshRow] = meshgrid(...
        linspace(1, nColPix, nDvaMeshCols), ...
        linspace(1, nRowPix, nDvaMeshRows));
    % find the initial unaberrated RA and dec of the dva mesh points
    zodiRA = zeros(size(zodiMeshRow));
    zodiDec = zeros(size(zodiMeshRow));
    for meshRow = 1:nDvaMeshRows
        for meshCol = 1:nDvaMeshCols
    %         [zodiRA(meshRow, meshCol), zodiDec(meshRow, meshCol)] ...
    %             = pix_2_ra_dec_relative(coaObject.raDec2PixObject, ...
    %             module, output, zodiMeshRow(meshRow, meshCol) + leadingBlack, ...
    %             zodiMeshCol(meshRow, meshCol) + maskedSmear, startTimeMjd + duration/2, ...
    % 			raOffset, decOffset, phiOffset, 1);
            [zodiRA(meshRow, meshCol), zodiDec(meshRow, meshCol)] ...
                = pix_2_ra_dec_relative(coaObject.raDec2PixObject, ...
                module, output, zodiMeshRow(meshRow, meshCol) + maskedSmear, ...
                zodiMeshCol(meshRow, meshCol) + leadingBlack, startTimeMjd + duration/2, ...
                raOffset, decOffset, phiOffset, 1);
        end
    end
    % check for nan and inf
    if any(any(~isfinite(zodiRA)))
        error('TAD:extract_optimal_aperture:dvaMeshInitRA:not_finite',...
            'dvaMeshInitRA contains NAN or INF after pix_2_ra_dec.');
    end
    if any(any(~isfinite(zodiDec)))
        error('TAD:extract_optimal_aperture:dvaMeshInitDec:not_finite',...
            'dvaMeshInitDec contains NAN or INF after pix_2_ra_dec.');
    end
    % now compute the zodi signal at the mesh points
    zodiMeshValues = zeros(nDvaMeshRows, nDvaMeshCols);
    for meshRow = 1:nDvaMeshRows
        for meshCol = 1:nDvaMeshCols
            % compute the aberrated RA and dec of each dva mesh point at each
            % sample
            zodiMeshValues(meshRow, meshCol) = Zodi_Model( ...
                zodiRA(meshRow, meshCol), zodiDec(meshRow, meshCol), ...
                startTimeJulian + duration/2, coaObject.raDec2PixObject, ...
                coaObject.fcConstants.pixel2arcsec);
        end
    end
    % now create 2D polynomial for the zodi and evaluate it for all pixels
    [ccdPixCols, ccdPixRows] = meshgrid(1:nColPix, 1:nRowPix);
    zodiPoly = weighted_polyfit2d( ...
        zodiMeshRow(:)/nRowPix, zodiMeshCol(:)/nColPix, zodiMeshValues(:), 1, dvaMeshOrder, 'standard');
    check_poly2d_struct(zodiPoly, ...
        'TAD:extract_optimal_aperture:zodiPoly:');
    zodiValues = reshape(weighted_polyval2d(ccdPixRows(:)/nRowPix, ...
        ccdPixCols(:)/nColPix, zodiPoly), nRowPix, nColPix);
    zodiImage = cadenceTime * flux12 * mag2b(zodiValues) / mag2b(12);

else
    
    % find the valid background polynomials in the desired time range
    backgroundPolyStruct = coaObject.backgroundPolyStruct;

    if isempty(backgroundPolyStruct)
        error('TAD:extract_optimal_aperture:backgroundPolyStruct', ...
            'background polynomial structure array is empty');
    end
    backgroundPolyGapIndicators = ...
        ~logical([backgroundPolyStruct.backgroundPolyStatus]');
    backgroundPolyStruct = backgroundPolyStruct(~backgroundPolyGapIndicators);
    if isempty(backgroundPolyStruct)
        error('TAD:extract_optimal_aperture:backgroundPolyStruct', ...
            'all background polynomials are invalid');
    end
    backgroundPolyTimestamps = [backgroundPolyStruct.mjdMidTime]';
    isInTimeRange = backgroundPolyTimestamps >= startTimeMjd & ...
        backgroundPolyTimestamps <= startTimeMjd + duration;
    if ~any(isInTimeRange)
        error('TAD:extract_optimal_aperture:backgroundPolyStruct', ...
            'no valid background polynomials in desired time range');
    end
    backgroundPolyStruct = backgroundPolyStruct(isInTimeRange);

    % set up a pixel grid and capture the average background flux per pixel
    % over the desired time range; compute the average polynomial
    % coefficient values first and then evaluate the mean polynomial for
    % all CCD pixels (this is equivalent to evaluating the polynomials for
    % all pixels and then averaging over all cadences but is much faster)
    [ccdPixCols, ccdPixRows] = meshgrid(1:nColPix, 1:nRowPix);
    
    nCadences = length(backgroundPolyStruct);
    
    meanBackgroundPoly = backgroundPolyStruct(1).backgroundPoly;
    meanBackgroundPoly.coeffs = zeros(size(meanBackgroundPoly.coeffs));
    
    for iCadence = 1 : nCadences
        meanBackgroundPoly.coeffs = meanBackgroundPoly.coeffs + ...
            backgroundPolyStruct(iCadence).backgroundPoly.coeffs / ...
            nCadences;
    end
    
    backgroundLevels = weighted_polyval2d( ...
        ccdPixRows(:) + maskedSmear, ccdPixCols(:) + leadingBlack, ...
        meanBackgroundPoly);
    
    zodiImage = reshape(backgroundLevels, nRowPix, nColPix);
        
end % if / else

return


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function outImage = add_saturation_map(coaObject, inImage, colRange, keplerId)
%
% add pixels from the saturation map
% if the optional argument keplerId is present that keplerId
% is EXCLUDED from the saturation map, in order to make the background
% image
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function outImage = add_saturation_map(coaObject, inImage, colRange, keplerId)
if isempty(coaObject.saturationObject)
    outImage = inImage;
    return;
end

if nargin < 3
    colRange = [1 size(inImage, 2)];
    keplerId = -1;
end
wellCapacity = coaObject.pixelModelStruct.wellCapacity;
cadenceTime = coaObject.pixelModelStruct.cadenceTime;
integrationTime = coaObject.pixelModelStruct.integrationTime;
saturationValue = wellCapacity*cadenceTime/integrationTime;
leadingBlack = coaObject.moduleDescriptionStruct.leadingBlack;
maskedSmear = coaObject.moduleDescriptionStruct.maskedSmear;

saturationMap = get_saturation_info(coaObject.saturationObject);
outImage = inImage;
for i=1:length(saturationMap)
    satMap = saturationMap(i);
    if satMap.keplerId == keplerId
        continue;
    end
    for c=1:length(satMap.column)
        % the saturation map is in zero-based coordinates so we have to add
        % 1
        col = satMap.column(c) + 1 - colRange(1) - leadingBlack + 1;
        if col >= 1 && col <= colRange(end) - colRange(1) + 1
            rowStart = max(satMap.rowStart(c) + 1 - maskedSmear, 1);
            rowEnd = min(satMap.rowEnd(c) + 1, size(inImage,1) + maskedSmear) - maskedSmear;
            for r=rowStart:rowEnd
                outImage(r, col) = saturationValue;
            end
        end
    end
end
