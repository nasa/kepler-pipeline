function referencePixels = make_reference_pixels(longCadenceDataObject, scienceData, ccdObject)
% function referencePixels = make_reference_pixels(longCadenceDataObject, scienceData, ccdObject)
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

runParamsObject = longCadenceDataObject.runParamsClass;
exposuresPerCadence = get(runParamsObject, 'exposuresPerCadence');

% get the requantization table data
requantOffset = get(ccdObject, 'requantTableLcFixedOffset');
meanBlack = get(ccdObject, 'requantizationMeanBlack');
meanBlackPerCadence = meanBlack*exposuresPerCadence;

% count the target pixels
nTargetPixels = 0;
for t=1:length(longCadenceDataObject.targetStruct)
    nTargetPixels = nTargetPixels + length(longCadenceDataObject.targetStruct(t).poiPixelIndex);
end

nBackgroundPixels = length(longCadenceDataObject.backgroundStruct.poiPixelIndex);

nPixelData = nTargetPixels + nBackgroundPixels;

% pick out the leading black data and reshape into a 2d array
nTrailingBlackPixels = length(longCadenceDataObject.trailingBlackStruct.poiPixelIndex);

nPixelData = nPixelData + nTrailingBlackPixels;

% pick out the masked smear data and reshape into a 2d array
nMaskedSmearPixels = length(longCadenceDataObject.maskedSmearStruct.poiPixelIndex);

nPixelData = nPixelData + nMaskedSmearPixels;

% pick out the virtual smear data and reshape into a 2d array
nVirtualSmearPixels = length(longCadenceDataObject.virtualSmearStruct.poiPixelIndex);

nPixelData = nPixelData + nVirtualSmearPixels;

nLeadingBlackPixels = length(longCadenceDataObject.leadingBlackStruct.poiPixelIndex);
nPixelData = nPixelData + nLeadingBlackPixels;

% count the reference pixels
nReferencePixels = 0;
for t=1:length(longCadenceDataObject.referencePixelStruct)
    nReferencePixels = nReferencePixels + length(longCadenceDataObject.referencePixelStruct(t).poiPixelIndex);
end

referencePixels = scienceData(nPixelData+1:nPixelData + nReferencePixels) ...
    + requantOffset - meanBlackPerCadence;
