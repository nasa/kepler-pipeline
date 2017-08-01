function [calObject, calIntermediateStruct] = ...
    subtract_black2DModel_from_partial_ffi_pixels(calObject, ...
    calIntermediateStruct, twoDBlackArray, ffiIndex)
% function [calObject, calIntermediateStruct] = ...
%     subtract_black2DModel_from_partial_ffi_pixels(calObject, ...
%     calIntermediateStruct, twoDBlackArray, ffiIndex)
%
% cal method to correct partial ffi pixels for 2D black level
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


% extract ffi timestamp
timestampMjd = calIntermediateStruct.ffiStruct(ffiIndex).timestamp;

% if timestamp is before the first configMap timestamp choose the first config map
cmTime = [calObject.spacecraftConfigMap.time];
if timestampMjd < min(cmTime)
    timestampMjd = min(cmTime);
end

% get number of ffi reads from config map
cmObj = configMapClass(calObject.spacecraftConfigMap);
numberOfExposures = get_number_of_exposures_per_ffi(cmObj,timestampMjd);

% save number of exposures for this ffi for later use
calIntermediateStruct.numberOfExposuresFfi(ffiIndex) = numberOfExposures;

% extract working copy of ffi pixels
ffiPixels  = calIntermediateStruct.ffiStruct(ffiIndex).image;
ffiRows    = calIntermediateStruct.ffiStruct(ffiIndex).rows;
ffiColumns = calIntermediateStruct.ffiStruct(ffiIndex).columns;

% get size of image (columns x rows) and form linear row/column index
[nColumns, nRows] = size(ffiPixels);
rowIndex = repmat(ffiRows(:)',nColumns,1);
rowIndex = rowIndex(:);
columnIndex = repmat(ffiColumns(:),1,nRows);
columnIndex = columnIndex(:);

% get linear index into 2D black array for each in image
linearIdx = sub2ind(size(twoDBlackArray), rowIndex, columnIndex);

% get black to subtract
twoDBlackToSubtract = twoDBlackArray(linearIdx);

% linearize image and correct - black array is per exposure
correctedPixels = ffiPixels(:) - numberOfExposures .* twoDBlackToSubtract(:);

% save 2D black corrected image in the correct shape
calIntermediateStruct.ffiStruct(ffiIndex).image = reshape(correctedPixels,nColumns,nRows);


return;
