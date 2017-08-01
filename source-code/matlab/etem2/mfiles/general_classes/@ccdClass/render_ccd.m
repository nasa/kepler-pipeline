function render_ccd(ccdObject, cadenceRange)
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

runParamsObject = ccdObject.runParamsClass;
cadenceDuration = get(runParamsObject, 'cadenceDuration');
numCcdRows = get(runParamsObject, 'numCcdRows');
numCcdCols = get(runParamsObject, 'numCcdCols');
numVirtualSmear = get(runParamsObject, 'numVirtualSmear');
virtualSmearStart = get(runParamsObject, 'virtualSmearStart');
numLeadingBlack = get(runParamsObject, 'numLeadingBlack');
trailingBlackStart = get(runParamsObject, 'trailingBlackStart');
transferTime = get(runParamsObject, 'transferTime');
exposuresPerCadence = get(runParamsObject, 'exposuresPerCadence');
numMemoryBits = get(runParamsObject, 'numMemoryBits');
endian = get(runParamsObject, 'endian');
wellCapacity = get(get(ccdObject, 'electronsToAduObject'), 'maxElectronsPerExposure'); % we're working here with single exposures
% include variation in well depth
wellCapacity = wellCapacity*get(ccdObject, 'wellDepthVariation');

maxSummedValue = (2^numMemoryBits-1);
modulationCadence = fix(mean(cadenceRange));

if ~exist(ccdObject.ccdImageFilename, 'file')
    ccdImage = 0;
    % first render the image using the non-sat-spilled polynomials
    for plane=1:length(ccdObject.ccdPlaneObjectList)
        ccdImage = ccdImage + render_ccd(ccdObject.ccdPlaneObjectList(plane), ...
            ccdObject, cadenceRange, 'prePixelEffects');
    end
    
    % modulate quantum efficiency
    ccdImage = modulate_time_qe(ccdObject.electronsToAduObject, ccdImage, ...
        modulationCadence);
    
    % apply pixel noise objects
    for noise=1:length(ccdObject.pixelNoiseObjectList)
        ccdImage = apply_noise(...
            ccdObject.pixelNoiseObjectList{noise}, ccdImage);
    end

%     % Find the saturated pixels
%     [satRow, satCol] = find(ccdImage > wellCapacity);
%     % now spill the saturation
%     % note that saturated charge cannot spill into the virtual rows
%     % but CAN spill onto the masked rows
%     ccdImage(1:virtualSmearStart-1, satCol) = ...
%         spill_saturation(ccdObject, ccdImage(1:virtualSmearStart-1, satCol), ...
%         exposuresPerCadence, 1:virtualSmearStart-1, satCol);

    % now spill the saturation
    % note that saturated charge cannot spill into the virtual rows
    % but CAN spill onto the masked rows
    ccdImage(1:virtualSmearStart-1, :) = ...
        spill_saturation(ccdObject, ccdImage(1:virtualSmearStart-1, :), ...
        exposuresPerCadence, 1:virtualSmearStart-1, 1:size(ccdImage,2));
    
    ccdImageCR = ccdImage;
    if ~isempty(ccdObject.cosmicRayObject)
        % add cosmic rays to the CCD

        % put a candence worth of cosmic rays on the physical pixels
        ccdImageCR(1:virtualSmearStart-1, numLeadingBlack+1:trailingBlackStart-1) ...
            = add_cosmic_rays(ccdObject.cosmicRayObject, ...
            ccdImageCR(1:virtualSmearStart-1, numLeadingBlack+1:trailingBlackStart-1), ...
            cadenceDuration, []);
        % put a transfer time's x number of exposures per cadence worth of 
        % cosmic rays on the virtual smear pixels
        ccdImageCR(virtualSmearStart:numCcdRows, numLeadingBlack+1:trailingBlackStart-1) ...
            = add_cosmic_rays(ccdObject.cosmicRayObject, ...
            ccdImageCR(virtualSmearStart:numCcdRows, numLeadingBlack+1:trailingBlackStart-1), ...
            transferTime*exposuresPerCadence, []);
        % put a transfer time's / number of rows worth of 
        % cosmic rays on the leading black
        ccdImageCR(1:numCcdRows, 1:numLeadingBlack) ...
            = add_cosmic_rays(ccdObject.cosmicRayObject, ...
            ccdImageCR(1:numCcdRows, 1:numLeadingBlack), ...
            exposuresPerCadence*transferTime/numCcdRows, []);
        % put a transfer time's / number of rows worth of 
        % cosmic rays on the trailing black
        ccdImageCR(1:numCcdRows, trailingBlackStart:numCcdCols) ...
            = add_cosmic_rays(ccdObject.cosmicRayObject, ...
            ccdImageCR(1:numCcdRows, trailingBlackStart:numCcdCols), ...
            exposuresPerCadence*transferTime/numCcdRows, []);
        
        % apply electronics effects objects (such as overshoot)
        % these objects act on the entire ccdSeries array
        for noise=1:length(ccdObject.electronicsEffectObjectList)
            ccdImageCR = apply_effect(ccdObject.electronicsEffectObjectList{noise}, ...
                ccdImageCR);
        end

        % apply read noise objects
        for noise=1:length(ccdObject.readNoiseObjectList)
            ccdImageCR = apply_noise(...
                ccdObject.readNoiseObjectList{noise}, ccdImageCR);
        end
        
        ccdImageCR = convert_electrons_to_ADU(ccdObject.electronsToAduObject, ...
            ccdImageCR);
		ccdImageCR = add_bias(ccdObject, ccdImageCR, modulationCadence);
		if ~get(runParamsObject, 'supressQuantizationNoise')
			% add quantization noise.  
			% 1/12 is the integral of the variance of a uniform distribution from -.5
			% to .5, which is what you want to simulate the variance of roundoff
			% error.
			ccdImageCR = ccdImageCR ...
				+ randn(size(ccdImageCR))*sqrt(exposuresPerCadence/12);
		end

    end
    % apply electronics effects objects (such as overshoot)
    % these objects act on the entire ccdSeries array
    for noise=1:length(ccdObject.electronicsEffectObjectList)
        ccdImage = apply_effect(ccdObject.electronicsEffectObjectList{noise}, ...
            ccdImage);
    end
    
    % apply read noise objects
    for noise=1:length(ccdObject.readNoiseObjectList)
        ccdImage = apply_noise(...
            ccdObject.readNoiseObjectList{noise}, ccdImage);
    end
    
    ccdImageElectrons = ccdImage;
    ccdImage = convert_electrons_to_ADU(ccdObject.electronsToAduObject, ccdImage);
    ccdImageADU = ccdImage;
	ccdImage = add_bias(ccdObject, ccdImage, modulationCadence);
	if ~get(runParamsObject, 'supressQuantizationNoise')
		% add quantization noise.  
		% 1/12 is the integral of the variance of a uniform distribution from -.5
		% to .5, which is what you want to simulate the variance of roundoff
		% error.
		ccdImage = ccdImage ...
			+ randn(size(ccdImage))*sqrt(exposuresPerCadence/12);
	end

    % Science data is complete.  Now clip to max and min possible values
    % make sure there are no negative values
    ccdImage = max(ccdImage, 0);
    ccdImageCR = max(ccdImageCR, 0);
    % simulate roll-over
    ccdImage = mod(ccdImage, maxSummedValue+1);
    ccdImageCR = mod(ccdImageCR, maxSummedValue+1);

    save(ccdObject.ccdImageFilename, 'ccdImage', 'ccdImageCR', 'ccdImageElectrons', 'ccdImageADU');
else
    load(ccdObject.ccdImageFilename, 'ccdImage', 'ccdImageCR');
end


ffiFid = fopen(ccdObject.ffiFilename,'w',endian);
% write out ccdImageCR as the FFI image in ssr format compliant with the
% FS-GS ICD.  We have to transpose to get column major output
if exposuresPerCadence == 1 
	% this is a single exposure ffi, need to save as 16 bit
	fwrite(ffiFid, uint16(ccdImageCR'), 'uint16');
else
	fwrite(ffiFid, uint32(ccdImageCR'), 'uint32');
end
fclose(ffiFid);
    
% draw_final_pixels(ccdObject, ccdImage, 'full ccd image');
% draw_final_pixels(ccdObject, ccdImageCR, 'full ccd image with cosmic rays');

