function pdqTempStruct = bin_black_measurements(pdqTempStruct, cadenceIndex)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function pdqTempStruct = bin_black_measurements(pdqTempStruct, cadenceIndex)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Description:
%   This function bins the black pixels (if they come from more than one
%   column) into one column. Propagates uncertainty from raw black
%   measurements to binned black measurements.
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
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

invalidBlackPixelIndices = find(pdqTempStruct.blackGapIndicators(:,cadenceIndex));

%------------------------------------------------------------------------
% Step 1: see whether there is any need to bin black pixels (see whether
% they come from more than one column)
%------------------------------------------------------------------------
uniqueBlackColumns = unique(pdqTempStruct.blackColumns);

nUniqueBlackColumns = length(uniqueBlackColumns);
% it is possible that some column(s) might have data gaps in some of the
% rows and not all the columns will have data in the same rows
uniqueBlackRows = unique(pdqTempStruct.blackRows);
nUniqueBlackRows = length(uniqueBlackRows);

%------------------------------------------------------------------------
% Step 2: % bin black pixels from several columns into one column per row
%------------------------------------------------------------------------

% bin the covariance matrix and the gap indicator logical array and sum across
% rows - this indicates how many entries went into the average
blackGapIndicators = reshape(pdqTempStruct.blackGapIndicators(:,cadenceIndex), nUniqueBlackRows, nUniqueBlackColumns); % a matrix now
numberOfBlacksInEachRow = binmat(~blackGapIndicators, 1, nUniqueBlackColumns); % must be a vector by now

% extract black pixels for the current cadence from the structure
blackPixels = pdqTempStruct.blackPixels(:, cadenceIndex);
if(~isempty(invalidBlackPixelIndices))
    blackPixels(invalidBlackPixelIndices) = 0; % gaps are filled with 2^32-1, so set them to 0
end

blackPixels = reshape(blackPixels, nUniqueBlackRows, nUniqueBlackColumns); % a matrix now
blackPixels = binmat(blackPixels, 1, nUniqueBlackColumns);
nBinnedRows = size(blackPixels,1); % nBinnedCols must be 1 at this point

% divide by zero possible here...to avoid that...
validIndices = find(numberOfBlacksInEachRow);
blackPixels(validIndices) = blackPixels(validIndices)./numberOfBlacksInEachRow(validIndices);

if(cadenceIndex == 1)
    % allocate memory
    pdqTempStruct.binnedBlackPixels         =  zeros(nBinnedRows, pdqTempStruct.numCadences);
    pdqTempStruct.blackPixelsInRowBin       = zeros(nBinnedRows, pdqTempStruct.numCadences);
    pdqTempStruct.binnedBlackGapIndicators  = zeros(nBinnedRows, pdqTempStruct.numCadences);
    pdqTempStruct.binnedBlackRows           = zeros(nBinnedRows, pdqTempStruct.numCadences);
    pdqTempStruct.binnedBlackColumn         = zeros(pdqTempStruct.numCadences, 1);

end

pdqTempStruct.binnedBlackGapIndicators(:, cadenceIndex) = ~logical(numberOfBlacksInEachRow);
pdqTempStruct.binnedBlackPixels(:, cadenceIndex)        = blackPixels;
pdqTempStruct.blackPixelsInRowBin(:, cadenceIndex)      = numberOfBlacksInEachRow;
pdqTempStruct.binnedBlackRows(:, cadenceIndex)          = uniqueBlackRows;
pdqTempStruct.binnedBlackColumn(cadenceIndex)           = uniqueBlackColumns(1);


%------------------------------------------------------------------------
% Step 3: % compute black pixels uncertainties
%------------------------------------------------------------------------

pdqTempStruct = compute_black_pixels_uncertainties(pdqTempStruct, cadenceIndex, nBinnedRows, numberOfBlacksInEachRow);


return
















