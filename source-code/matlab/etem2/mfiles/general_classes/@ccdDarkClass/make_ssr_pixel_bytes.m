function [ssrData, quantizedSsrData] = make_ssr_pixel_bytes(ccdObject, scienceData)
% function write_data_ssr_bytes(ccdObject, scienceData)
%
% return the in scienceData in the form required to imitate the SSR
% implements FS-GS ICD section 5.3.1.3.1 
%
% scienceData contains a single cadence of long-cadence science values on all 
% pixels of interest in the order
%   target pixel values in order given by
%       ccdObject.targetStruct(t).poiPixelIndex 
%   background pixel values in order given by
%       ccdObject.backgroundStruct.poiPixelIndex
%   trailing black pixel values (all leading black pixels) in order given by
%       ccdObject.trailingBlackStruct.poiPixelIndex
%   masked smear pixel values (all masked smear pixels) in order given by
%       ccdObject.maskedSmearStruct.poiPixelIndex
%   virtual smear pixel values (all virtual smear pixels) in order given by
%       ccdObject.virtualSmearStruct.poiPixelIndex
%   trailing black pixel values (all trailing black pixels) in order given by
%       ccdObject.trailingBlackStruct.poiPixelIndex
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

runParamsObject = ccdObject.runParamsClass;
numCcdRows = get(runParamsObject, 'numCcdRows');
numVisibleCols = get(runParamsObject, 'numVisibleCols');
numMaskedSmear = get(runParamsObject, 'numMaskedSmear');
numVirtualSmear = get(runParamsObject, 'numVirtualSmear');
numTrailingBlack = get(runParamsObject, 'numTrailingBlack');
% the masked smear rows to use for binning
maskedSmearRows = get(runParamsObject, 'maskedSmearRows');
% the virtual smear rows to use for binning
virtualSmearRows = get(runParamsObject, 'virtualSmearRows');
% the leading black columns to use for binning
blackCols = get(runParamsObject, 'blackCols');

% count the target pixels
nTargetPixels = 0;
for t=1:length(ccdObject.targetStruct)
    nTargetPixels = nTargetPixels + length(ccdObject.targetStruct(t).poiPixelIndex);
end

nBackgroundPixels = length(ccdObject.backgroundStruct.poiPixelIndex);

nPixelData = nTargetPixels + nBackgroundPixels;

% use the target and background data as is
ssrData = scienceData(1:nPixelData);

% pick out the leading black data and reshape into a 2d array
nBlackPixels = length(ccdObject.trailingBlackStruct.poiPixelIndex);
blackData = ...
    reshape(scienceData(nPixelData+1:nPixelData+nBlackPixels), ...
    numCcdRows, numTrailingBlack);
% sum over the rows
ssrData = [ssrData; sum(blackData(:, blackCols), 2)];

nPixelData = nPixelData + nBlackPixels;

% pick out the masked smear data and reshape into a 2d array
nMaskedSmearPixels = length(ccdObject.maskedSmearStruct.poiPixelIndex);
maskedSmearData = ...
    reshape(scienceData(nPixelData+1:nPixelData+nMaskedSmearPixels), ...
    numMaskedSmear, numVisibleCols);
% sum over the columns
ssrData = [ssrData; (sum(maskedSmearData(maskedSmearRows, :), 1))']; % transpose 'cause sum is a row vector

nPixelData = nPixelData + nMaskedSmearPixels;

% pick out the virtual smear data and reshape into a 2d array
nVirtualSmearPixels = length(ccdObject.virtualSmearStruct.poiPixelIndex);
virtualSmearData = ...
    reshape(scienceData(nPixelData+1:nPixelData+nVirtualSmearPixels), ...
    numVirtualSmear, numVisibleCols);
% sum over the columns
ssrData = [ssrData; (sum(virtualSmearData(virtualSmearRows, :), 1))']; % transpose 'cause sum is a row vector



