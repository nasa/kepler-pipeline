function ccdObject = render_time_series(ccdObject)
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

if exist(ccdObject.ccdTimeSeriesFilename, 'file')
    return;
end

runParamsObject = ccdObject.runParamsClass;
nCadences = get(runParamsObject, 'runDurationCadences');
numCcdRows = get(runParamsObject, 'numCcdRows');
numCcdCols = get(runParamsObject, 'numCcdCols');
exposuresPerCadence = get(runParamsObject, 'exposuresPerCadence');
dataBufferSize = ccdObject.dataBufferSize;
endian = get(runParamsObject, 'endian');
refPixCadenceInterval = get(runParamsObject, 'refPixCadenceInterval');
refPixCadenceOffset = get(runParamsObject, 'refPixCadenceOffset');
cadenceDuration = get(runParamsObject, 'cadenceDuration');
transferTime = get(runParamsObject, 'transferTime');
cadenceType = get(runParamsObject, 'cadenceType');
outputDirectory = get(runParamsObject, 'outputDirectory');
numVisibleCols = get(runParamsObject, 'numVisibleCols');
numMaskedSmear = get(runParamsObject, 'numMaskedSmear');
numVirtualSmear = get(runParamsObject, 'numVirtualSmear');


% maxSummedValue = (2^numAtoDBits-1)*exposuresPerCadence;
% first generate the time series files for each plane
for plane=1:length(ccdObject.ccdPlaneObjectList)
    render_time_series(ccdObject.ccdPlaneObjectList(plane), ccdObject);
end

% then read the files cadence by cadence and sum over the time series

% open the ccdPlane time series files
inFid = zeros(1, length(ccdObject.ccdPlaneObjectList));
for plane=1:length(ccdObject.ccdPlaneObjectList)
    inFid(plane) = fopen( ...
        get(ccdObject.ccdPlaneObjectList(plane), 'ccdTimeSeriesFilename'), ...
        'r', endian);
end

poiStruct = get(ccdObject.cadenceDataObject, 'poiStruct');
poiPixelIndex = poiStruct.poiPixelIndex;
poiVisiblePixelIndex = poiStruct.poiVisiblePixelIndex;
trailingBlackPoiStruct = get(ccdObject.cadenceDataObject, 'trailingBlackStruct');
trailingBlackPoiIndex = trailingBlackPoiStruct.poiPixelIndex;
clear trailingBlackPoiStruct;
maskedSmearPoiStruct = get(ccdObject.cadenceDataObject, 'maskedSmearStruct');
maskedSmearPoiIndex = maskedSmearPoiStruct.poiPixelIndex;
clear maskedSmearPoiStruct;
virtualSmearPoiStruct = get(ccdObject.cadenceDataObject, 'virtualSmearStruct');
virtualSmearPoiIndex = virtualSmearPoiStruct.poiPixelIndex;
clear virtualSmearPoiStruct;
leadingBlackPoiStruct = get(ccdObject.cadenceDataObject, 'leadingBlackStruct');
leadingBlackPoiIndex = leadingBlackPoiStruct.poiPixelIndex;
clear leadingBlackPoiStruct;

outFid = fopen(ccdObject.ccdTimeSeriesFilename,'w',endian);
ssrFid = fopen(ccdObject.scienceCadenceFilename,'w',endian);
quantizedSsrFid = fopen(ccdObject.quantizedCadenceFilename,'w',endian);
requantizedSsrFid = fopen(ccdObject.requantizedCadenceFilename,'w',endian);
if strcmp(cadenceType, 'long')
    refPixFid = fopen(ccdObject.refPixFilename, 'w', endian);
end

outNoCrFid = fopen(ccdObject.ccdTimeSeriesNoCrFilename,'w',endian);
ssrNoCrFid = fopen(ccdObject.scienceCadenceNoCrFilename,'w',endian);
quantizedSsrNoCrFid = fopen(ccdObject.quantizedCadenceNoCrFilename,'w',endian);
requantizedSsrNoCrFid = fopen(ccdObject.requantizedCadenceNoCrFilename,'w',endian);
refPixNoCrFid = fopen(ccdObject.refPixNoCrFilename, 'w', endian);

% load the ccdImage to get a good background appropriate to filtering
load([outputDirectory filesep 'ccdImage'], 'ccdImage');

dataBuffer = [];
dataBufferNoCr = [];
ssrDataBuffer = [];
quantizedSsrDataBuffer = [];
requantizedSsrDataBuffer = [];
ssrDataBufferNoCr = [];
quantizedSsrDataBufferNoCr = [];
requantizedSsrDataBufferNoCr = [];

if strcmp(cadenceType, 'long')
	maskedSmearArray = zeros(numMaskedSmear, numVisibleCols, nCadences);
	virtualSmearArray = zeros(numVirtualSmear, numVisibleCols, nCadences);
end

h = waitbar(0, 'summing time series ');
for cadence = 1:nCadences
%     ccdSeries = zeros(numCcdRows, numCcdCols);
    ccdSeries = ccdImage; % initialize non-science pixels to have a representative 
                            % signal for undershoot filtering
				    
    ccdSeries(poiPixelIndex) = 0; 

    % read in and add the planes computed by each ccdPlaneObject.  These
    % planes have value 0 for pixels that are not in the poiPixelIndex
    for plane=1:length(ccdObject.ccdPlaneObjectList)
        ccdSeries(poiPixelIndex) = ccdSeries(poiPixelIndex) ...
            + fread(inFid(plane), length(poiPixelIndex), 'float32');
    end
	
	% save both types of smear pixels
	if strcmp(cadenceType, 'long')
		maskedSmearArray(:,:,cadence) = ...
    		reshape(ccdSeries(maskedSmearPoiIndex), numMaskedSmear, numVisibleCols);
		virtualSmearArray(:,:,cadence) = ...
    		reshape(ccdSeries(virtualSmearPoiIndex), numVirtualSmear, numVisibleCols);
	end

    
    % modulate quantum efficiency
    ccdSeries(poiPixelIndex) = modulate_time_qe(ccdObject.electronsToAduObject, ...
        ccdSeries(poiPixelIndex), cadence);
    
    % apply pixel noise objects
    for noise=1:length(ccdObject.pixelNoiseObjectList)
        ccdSeries(poiPixelIndex) = apply_noise(...
            ccdObject.pixelNoiseObjectList{noise}, ccdSeries(poiPixelIndex));
    end
    
    % add cosmic rays
    % create a copy of the pixels with no cosmic rays
    ccdSeriesNoCr = ccdSeries;
    % add cosmic rays
    cosmicRays = zeros(size(ccdSeries));
    if ~isempty(ccdObject.cosmicRayObject)
        % put a candence worth of cosmic rays on the visible and masked smear pixels
        cosmicRays([poiVisiblePixelIndex; maskedSmearPoiIndex]) ...
            = add_cosmic_rays(ccdObject.cosmicRayObject, ...
            cosmicRays([poiVisiblePixelIndex; maskedSmearPoiIndex]), cadenceDuration, []);
        % put a transfer time's x number of exposures per cadence worth of 
        % cosmic rays on the virtual smear pixels
        cosmicRays(virtualSmearPoiIndex) ...
            = add_cosmic_rays(ccdObject.cosmicRayObject, ...
            cosmicRays(virtualSmearPoiIndex), transferTime*exposuresPerCadence, []);
        % put a transfer time's / number of rows worth of 
        % cosmic rays on the leading black
        cosmicRays(trailingBlackPoiIndex) ...
            = add_cosmic_rays(ccdObject.cosmicRayObject, ...
            cosmicRays(trailingBlackPoiIndex), ...
            exposuresPerCadence*transferTime/numCcdRows, []);
        if ~isempty(leadingBlackPoiIndex)
            % put a transfer time's / number of rows worth of 
            % cosmic rays on the trailing black
            cosmicRays(leadingBlackPoiIndex) ...
                = add_cosmic_rays(ccdObject.cosmicRayObject, ...
                cosmicRays(leadingBlackPoiIndex), ...
                exposuresPerCadence*transferTime/numCcdRows, []);
        end
    end
    
    ccdSeries = ccdSeries + cosmicRays;
    
    % apply electronics effects objects (such as overshoot)
    % these objects act on the entire ccdSeries array
    for noise=1:length(ccdObject.electronicsEffectObjectList)
        ccdSeries = apply_effect(ccdObject.electronicsEffectObjectList{noise}, ...
            ccdSeries);
        ccdSeriesNoCr = apply_effect(ccdObject.electronicsEffectObjectList{noise}, ...
            ccdSeriesNoCr);
    end
    
    % apply read noise objects
    for noise=1:length(ccdObject.readNoiseObjectList)
        ccdSeries(poiPixelIndex) = apply_noise(...
            ccdObject.readNoiseObjectList{noise}, ccdSeries(poiPixelIndex));
        ccdSeriesNoCr(poiPixelIndex) = apply_noise(...
            ccdObject.readNoiseObjectList{noise}, ccdSeriesNoCr(poiPixelIndex));
    end
    ccdSeries = prepare_output_pixels(ccdObject, ccdSeries, cadence, poiPixelIndex);
    ccdSeriesNoCr = prepare_output_pixels(ccdObject, ccdSeriesNoCr, cadence, poiPixelIndex);

    ccdSeries(poiPixelIndex) = clip_output_pixels(ccdObject, ccdSeries(poiPixelIndex));
    ccdSeriesNoCr(poiPixelIndex) = clip_output_pixels(ccdObject, ccdSeriesNoCr(poiPixelIndex));
        
    %%%%% This completes the computation of the science data
    % now store the science data in its various forms
    
    dataBuffer = [ dataBuffer; ccdSeries(poiPixelIndex) ];
    dataBufferNoCr = [ dataBufferNoCr; ccdSeriesNoCr(poiPixelIndex) ];

    % make results as required on the SSR
    [ssrData, normalizedSsrData] = make_ssr_pixel_bytes(ccdObject.cadenceDataObject, ...
		ccdSeries(poiPixelIndex), ccdObject);
    % use normalizedSsrData for both ssrDataBuffer and
    % quantizedSsrDataBuffer to properly simulate what flight sw does when
    % requant is turned off.  Use ssrData to turn off simulation of mean
    % black correction of data.
    ssrDataBuffer = [ ssrDataBuffer; normalizedSsrData ];
    % quantize the data to 16 bits using requantization table
    % subtract 1 to convert to 0-based indexing
    quantizedSsrData = uint16(interp1(ccdObject.requantizationTable, ...
        1:length(ccdObject.requantizationTable), normalizedSsrData, 'nearest')) - 1;
    quantizedSsrDataBuffer = [ quantizedSsrDataBuffer; quantizedSsrData ];
	requantizedSsrData = ccdObject.requantizationTable(quantizedSsrData + 1);
    requantizedSsrDataBuffer = [ requantizedSsrDataBuffer; requantizedSsrData ];

    % make the version without cosmic rays
    [ssrDataNoCr, normalizedSsrDataNoCr] = make_ssr_pixel_bytes(ccdObject.cadenceDataObject, ...
		ccdSeriesNoCr(poiPixelIndex), ccdObject);
    ssrDataBufferNoCr = [ ssrDataBufferNoCr; normalizedSsrDataNoCr ];
    % quantize the data to 16 bits using requantization table
    % subtract 1 to convert to 0-based indexing
    quantizedSsrDataNoCr = uint16(interp1(ccdObject.requantizationTable, ...
        1:length(ccdObject.requantizationTable), normalizedSsrDataNoCr, 'nearest')) - 1;
    quantizedSsrDataBufferNoCr = [ quantizedSsrDataBufferNoCr; quantizedSsrDataNoCr ];
	requantizedSsrDataNoCr = ccdObject.requantizationTable(quantizedSsrDataNoCr + 1);
    requantizedSsrDataBufferNoCr = [ requantizedSsrDataBufferNoCr; requantizedSsrDataNoCr ];
    
    if length(dataBuffer) > dataBufferSize
        % write out the results for all pixels
        fwrite(outFid, dataBuffer, 'float32');
        fwrite(outNoCrFid, dataBufferNoCr, 'float32');
        fwrite(ssrFid, ssrDataBuffer, 'float32');
        fwrite(ssrNoCrFid, ssrDataBufferNoCr, 'float32');
        fwrite(quantizedSsrFid, quantizedSsrDataBuffer, 'uint16');
        fwrite(quantizedSsrNoCrFid, quantizedSsrDataBufferNoCr, 'uint16');
        fwrite(requantizedSsrFid, requantizedSsrDataBuffer, 'uint32');
        fwrite(requantizedSsrNoCrFid, requantizedSsrDataBufferNoCr, 'uint32');
        dataBuffer = [];
        dataBufferNoCr = [];
        ssrDataBuffer = [];
        ssrDataBufferNoCr = [];
        quantizedSsrDataBuffer = [];
        quantizedSsrDataBufferNoCr = [];
        requantizedSsrDataBuffer = [];
        requantizedSsrDataBufferNoCr = [];
    end
	
	if ~mod(cadence - refPixCadenceOffset - 1, refPixCadenceInterval) && strcmp(cadenceType, 'long')
		referencePixels = round(make_reference_pixels(ccdObject.cadenceDataObject, ...
            ccdSeries(poiPixelIndex), ccdObject));
		if ~isempty(referencePixels)
			fwrite(refPixFid, uint32(referencePixels), 'uint32');
		end
		referencePixelsNoCr = round(make_reference_pixels(ccdObject.cadenceDataObject, ...
            ccdSeriesNoCr(poiPixelIndex), ccdObject));
		if ~isempty(referencePixelsNoCr)
			fwrite(refPixNoCrFid, uint32(referencePixelsNoCr), 'uint32');
		end
	end
    
    if cadence == 1
        figure;
        imagesc(ccdSeries, [0, 1e6]);
        colormap(hot)
        title(['cadence 1 summed pixels ']);
        draw_final_pixels(ccdObject, ccdSeries, ['cadence ' num2str(cadence) ' of summed pixels of interest']);
    end
    
    waitbar(cadence/nCadences, h, ['summing time series ' ...
        ', cadence ' num2str(cadence) '/' num2str(nCadences)]);
    
    if ~mod(cadence, 500)
        display(['summing time series, cadence ' num2str(cadence) ' of ' num2str(nCadences)]);
    end
end
if ~isempty(dataBuffer)
    % write out the results for all pixels
    fwrite(outFid, dataBuffer, 'float32');
    fwrite(outNoCrFid, dataBufferNoCr, 'float32');
    fwrite(ssrFid, ssrDataBuffer, 'float32');
    fwrite(ssrNoCrFid, ssrDataBufferNoCr, 'float32');
    fwrite(quantizedSsrFid, quantizedSsrDataBuffer, 'uint16');
    fwrite(quantizedSsrNoCrFid, quantizedSsrDataBufferNoCr, 'uint16');
    fwrite(requantizedSsrFid, requantizedSsrDataBuffer, 'uint32');
    fwrite(requantizedSsrNoCrFid, requantizedSsrDataBufferNoCr, 'uint32');
end
% write out the smear data
if strcmp(cadenceType, 'long')
	save([outputDirectory filesep 'rawSmearData.mat'], 'maskedSmearArray', 'virtualSmearArray');
end

for plane=1:length(ccdObject.ccdPlaneObjectList)
    fclose(inFid(plane));
end
fclose(outFid);
fclose(ssrFid);
fclose(quantizedSsrFid);
fclose(requantizedSsrFid);
if strcmp(cadenceType, 'long')
    fclose(refPixFid);
end
fclose(outNoCrFid);
fclose(ssrNoCrFid);
fclose(quantizedSsrNoCrFid);
fclose(requantizedSsrNoCrFid);
fclose(refPixNoCrFid);
close (h);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function pixels = prepare_output_pixels(ccdObject, pixels, cadence, pixelIndices)
runParamsObject = ccdObject.runParamsClass;
exposuresPerCadence = get(runParamsObject, 'exposuresPerCadence');

%%%%%%
%%%%%% convert from electrons to ADU here
%%%%%%
% scale electrons to ADU, adding the low guardband
pixels(pixelIndices) = convert_electrons_to_ADU(ccdObject.electronsToAduObject, ...
    pixels(pixelIndices));
pixels = add_bias(ccdObject, pixels, cadence, pixelIndices);

if ~get(runParamsObject, 'supressQuantizationNoise')
	% add quantization noise.  
	% 1/12 is the integral of the variance of a uniform distribution from -.5
	% to .5, which is what you want to simulate the variance of roundoff
	% error.
	pixels(pixelIndices) = pixels(pixelIndices) ...
		+ randn(size(pixels(pixelIndices)))*sqrt(exposuresPerCadence/12);
end

