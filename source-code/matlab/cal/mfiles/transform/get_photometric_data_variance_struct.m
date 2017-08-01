function outputStruct = get_photometric_data_variance_struct(calTransformStruct, compressedData, pouParameterStruct)
%
% function outputStruct = get_photometric_data_variance_struct(calTransformStruct, compressedData, pouParameterStruct)
%
% This function sets up the correct form of errorPropStruct to feed to
% get_variance_from_POU_struct based on the state of the incoming data.
%
% IF: compressedData is NOT EMPTY
%       This means the calTransformStruct is minimized and compressed except
%       for the last non-null entry. That is the state of calTransformStruct
%       in CAL at the end of a photometric invocation.
% IF: compressedData is EMPTY 
%       This means the calTransformStruct is full (decompressed and maximized)
%
%
% INPUT:    calTransformStruct  = calTransformStruct from CAL containing the primitive data and transform chain for
%                                 the collateral data variable names
%           compressedData      = structure containing the compressed data
%                                 from calTransformStruct
%           pouParameterStruct  = structure containing the following
%                                 parameters:
%                                   .pouEnabled             = POU on/off
%                                   .compressFlag           = POU data compression on/off
%                                   .maxSvdOrder            = maximum order of SVD used in compression
%                                   .pixelChunkSize         = maximum chunk size used in propagating covariance
%                                                             through transformation cascade
%                                   .interpDecimation       = deciamtion factor used in interpolating variance
%                                                             across cadences
%                                   .pouInterpMethod        = method used in interpolating variance across cadences
% OUTPUT:   outputStruct        = structure containing the variance for the last photometric invocation in calTransformStruct
%                                 Note the last invocation is assumed to be uncompressed and maximized.
%                                   outputStruct.(variableName).variance; nCadences x 1; double
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

% declare parameters
calPixStr = 'calibratedPixels';
PIXEL_BATCH_LENGTH = pouParameterStruct.pixelChunkSize;


% get errorPropStruct variable name list up to this invocation
[~, varList]=iserrorPropStructVariable(calTransformStruct(:,1),'');

% [index, varList]=iserrorPropStructVariable(calTransformStruct(:,1),'');           % 2007a MATLAB version

% find the calibratedPixels# indices
photoIndices = strmatch(calPixStr, varList);                                        %#ok<REMFF1>
photoIndices = sort(photoIndices);

% get name of last set of calibrated pixels
photoPixelsName = varList{photoIndices(end)};
lastPhotoPixelsIndex = photoIndices(end);

% the rest are collateral indices
collateralIndices = setdiff(1:length(varList), photoIndices);
lenCollateralIndices = length(collateralIndices);

% build truncated array of errorPropStruct
tempStruct = calTransformStruct([collateralIndices,lastPhotoPixelsIndex],:);
photoIndex = lenCollateralIndices + 1;

if ~isempty(compressedData)
    % NOTE: photometric data is already decompressed and expanded
    % decompress collateral data into first cadence
    tempStruct(1:lenCollateralIndices,1) = ...
        decompress_errorPropStruct( tempStruct(collateralIndices,1), compressedData);

    % expand collateral data to full array
    tempStruct(1:lenCollateralIndices,:) = ...
        maximize_errorPropStructArray(tempStruct(1:lenCollateralIndices,1));
end


% get size of calibratedPixels in tempStruct
pixelRows = tempStruct(photoIndex,1).row;
numPixels = length(pixelRows);
uniqueRows = unique(pixelRows);

% Batch the pixels by grouping rows until PIXEL_BATCH_LENGTH is reached,
% then back off one row. Store the batches as groups of rows

batchStartEnd = zeros(length(uniqueRows),2);

pixelCount = 0;
firstRowIndex = 1;
batchNumber = 1;
while pixelCount < numPixels
    
    batchPixelCount = 0;
    lastRowIndex = firstRowIndex;
    batchDone = false;
     while(~batchDone && lastRowIndex <= length(uniqueRows)) 
        numPixInRow = length(find(pixelRows == uniqueRows(lastRowIndex)));  
        
        if(batchPixelCount + numPixInRow <= PIXEL_BATCH_LENGTH)
            pixelCount = pixelCount + numPixInRow;
            batchPixelCount = batchPixelCount + numPixInRow;
            lastRowIndex = lastRowIndex + 1;
        else
            batchDone = true;            
        end
    end
    
    lastRowIndex = lastRowIndex - 1;
    
    % save start and stop rows for this batch  
    batchStartEnd(batchNumber,1) = firstRowIndex;
    batchStartEnd(batchNumber,2) = lastRowIndex;
    
    % seed the indices for the next batch
    firstRowIndex = lastRowIndex + 1;
    batchNumber = batchNumber + 1;
end

% trim the array of batch start/end indices
batchStartEnd = batchStartEnd(1:batchNumber-1,:);

% save a copy of the photometric element
photoStruct(1,:) = tempStruct(photoIndex, :);
nCadences = size(tempStruct,2);     

% initialize outputStruct
outputStruct = struct(photoPixelsName,struct('variance',[],...
                                                'usedCadenceIndex',[]));

for i=1:size(batchStartEnd,1)
    
    batchRows = uniqueRows(batchStartEnd(i,1):batchStartEnd(i,2));
    
    % replace photometric element in tempStruct with truncated copy
    % of the original photometric element for this batch
    for cadence = 1:nCadences
        
        pixelIndices = find_photometric_pixel_indices(photoStruct(1,cadence), batchRows, []);
        
        tempStruct(photoIndex, cadence) = ...
            make_sub_photometric_struct(photoStruct(1,cadence), pixelIndices);
    end
    
    display(['Processing rows ',num2str(batchRows(1)),' - ',num2str(batchRows(end)),'...']);
    
    t0 = clock;
    S = get_variance_from_POU_struct(tempStruct, {photoPixelsName}, pouParameterStruct);
        
    display(['Elapsed time  = ',num2str(etime(clock,t0)/60),' minutes.']);
        
    
    if ~isempty(S)
        
        outputFieldName = fieldnames(S);
        [~, fieldIndex] = ismember({photoPixelsName},outputFieldName);
        
        % [dummy, fieldIndex] = ismember({photoPixelsName},outputFieldName);        % 2007a MATLAB version
        
        % concatenate variance arrays in output structure
        outputStruct.(outputFieldName{fieldIndex(1)}).variance = ...
            [outputStruct.(outputFieldName{fieldIndex(1)}).variance, S.(outputFieldName{fieldIndex(1)}).variance];
        
        % used cadences will be identical for all row batches - any one will do for concatenated data
        if isempty(outputStruct.(outputFieldName{fieldIndex(1)}).usedCadenceIndex)
            outputStruct.(outputFieldName{fieldIndex(1)}).usedCadenceIndex = ...
                S.(outputFieldName{fieldIndex(1)}).usedCadenceIndex;
        end
        
    end        
end

    