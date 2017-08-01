function [ssrData, normalizedSsrData] = make_ssr_pixel_bytes(shortCadenceDataObject, scienceData, ccdObject)
% function write_data_ssr_bytes(shortCadenceDataObject, scienceData)
%
% return the in scienceData in the form required to imitate the SSR
% implements FS-GS ICD section 5.3.1.3.1 
%
% scienceData contains a single cadence of long-cadence science values on all 
% pixels of interest in the order
%   target pixel values in order given by
%       shortCadenceDataObject.targetStruct(t).poiPixelIndex 
%   trailing black pixel values (all leading black pixels) in order given by
%       shortCadenceDataObject.trailingBlackStruct.poiPixelIndex
%   masked smear pixel values (all masked smear pixels) in order given by
%       shortCadenceDataObject.maskedSmearStruct.poiPixelIndex
%   virtual smear pixel values (all virtual smear pixels) in order given by
%       shortCadenceDataObject.virtualSmearStruct.poiPixelIndex
%   trailing black pixel values (all trailing black pixels) in order given by
%       shortCadenceDataObject.trailingBlackStruct.poiPixelIndex
%
% we need to bin the leading black and smear data and neglect the trailing
% black data but otherwise retain the order.
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

runParamsObject = shortCadenceDataObject.runParamsClass;
numCcdRows = get(runParamsObject, 'numCcdRows');
numCcdCols = get(runParamsObject, 'numCcdCols');
numVisibleCols = get(runParamsObject, 'numVisibleCols');
numMaskedSmear = get(runParamsObject, 'numMaskedSmear');
numVirtualSmear = get(runParamsObject, 'numVirtualSmear');
numLeadingBlack = get(runParamsObject, 'numLeadingBlack');
% the masked smear rows to use for binning
maskedSmearRows = get(runParamsObject, 'maskedSmearRows');
% the virtual smear rows to use for binning
virtualSmearRows = get(runParamsObject, 'virtualSmearRows');
% the leading black columns to use for binning
blackCols = get(runParamsObject, 'blackCols');
virtualSmearStart = get(runParamsObject, 'virtualSmearStart');
trailingBlackStart = get(runParamsObject, 'trailingBlackStart');
exposuresPerCadence = get(runParamsObject, 'exposuresPerCadence');

nBlackCols = length(blackCols);
nMaskedRows = length(maskedSmearRows);
nVirtualRows = length(virtualSmearRows);

% get the requantization table data
requantOffset = get(ccdObject, 'requantTableScFixedOffset');
meanBlack = get(ccdObject, 'requantizationMeanBlack');
meanBlackPerCadence = meanBlack*exposuresPerCadence;

% make a full CCD image and set the pixels of interest
ccdImage = zeros(numCcdRows, numCcdCols);
ccdImage(shortCadenceDataObject.poiStruct.poiPixelIndex) = scienceData;

% count the target pixels
nTargetPixels = 0;
for t=1:length(shortCadenceDataObject.targetStruct)
    nTargetPixels = nTargetPixels + length(shortCadenceDataObject.targetStruct(t).poiPixelIndex);
end

% precompute the binned black-mask and black-smear corners
blackMaskBinValue = sum(sum(ccdImage(maskedSmearRows, trailingBlackStart + blackCols - 1)));
blackVirtualBinValue = sum(sum(ccdImage(...
    virtualSmearStart + virtualSmearRows - 1, trailingBlackStart + blackCols - 1)));

% for each target, place the target pixels, then place the unique binned
% collateral data in the appropriate order
pixelPointer = 1;
ssrData = [];
normalizedSsrData = [];
for t=1:length(shortCadenceDataObject.targetStruct)
    targetStruct = shortCadenceDataObject.targetStruct(t);
    nTargetPixels = length(targetStruct.poiPixelIndex);
    % first insert the target pixels for this target
	pixelData = scienceData(pixelPointer:pixelPointer + nTargetPixels - 1);
    ssrData = [ssrData; pixelData];
	normPixelData = pixelData  + requantOffset - meanBlackPerCadence;
	normalizedSsrData = [normalizedSsrData; normPixelData];
 
    % get the binned black for each row that contains a pixel in this
    % target
	blackData = sum(ccdImage(targetStruct.rowList, trailingBlackStart + blackCols - 1), 2);
	blackData = clip_output_pixels(ccdObject, blackData);
    ssrData = [ssrData; blackData];
	normBlackData = blackData  + requantOffset - meanBlackPerCadence*nBlackCols;
	normalizedSsrData = [normalizedSsrData; normBlackData];
	
    % get the binned masked smear for each column that contains a pixel in this
    % target
	maskedSmearData = (sum(ccdImage(maskedSmearRows, targetStruct.colList), 1))';
	maskedSmearData = clip_output_pixels(ccdObject, maskedSmearData);
    ssrData = [ssrData; maskedSmearData]; % transpose 'cause sum is a row vector
	normMaskedSmear = maskedSmearData + requantOffset - meanBlackPerCadence*nMaskedRows;
	normalizedSsrData = [normalizedSsrData; normMaskedSmear];
	
    % get the binned virtual smear for each column that contains a pixel in this
    % target
	virtualSmearData = (sum(ccdImage(virtualSmearStart + virtualSmearRows - 1, targetStruct.colList), 1))';
	virtualSmearData = clip_output_pixels(ccdObject, virtualSmearData);
    ssrData = [ssrData; virtualSmearData]; % transpose 'cause sum is a row vector
	normVirtualSmear = virtualSmearData + requantOffset - meanBlackPerCadence*nVirtualRows;
	normalizedSsrData = [normalizedSsrData; normVirtualSmear];
	
    % now add the corner binned black values 
    ssrData = [ssrData; blackMaskBinValue; blackVirtualBinValue];
	normalizedSsrData = [normalizedSsrData; ...
		blackMaskBinValue + requantOffset - meanBlackPerCadence*nMaskedRows*nBlackCols; ...
		blackVirtualBinValue + requantOffset - meanBlackPerCadence*nVirtualRows*nBlackCols];
	
    % point at the next target's pixels
    pixelPointer = pixelPointer + nTargetPixels;
end

