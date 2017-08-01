function pdqTempStruct = compute_black_pixels_uncertainties(pdqTempStruct, cadenceIndex, ...
    nBinnedRows, numberOfBlacksInEachRow)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function pdqTempStruct = compute_black_pixels_uncertainties(pdqTempStruct, cadenceIndex, ...
%     nBinnedRows, numberOfBlacksInEachRow)
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


%------------------------------------------------------------------------
% Step 1: see whether there is any need to bin black pixels (see whether
% they come from more than one column)
%------------------------------------------------------------------------
uniqueBlackColumns = unique(pdqTempStruct.blackColumns);

nUniqueBlackColumns = length(uniqueBlackColumns);


%------------------------------------------------------------------------
% Step 1: Compute raw measurement uncertainty associated with the the balck pixels
%------------------------------------------------------------------------

invalidBlackPixelIndices = find(pdqTempStruct.blackGapIndicators(:,cadenceIndex));

quantizationStepSizeInADU = 1; % reference pixels are not requantized

% NOTE: black measurements are still in ADUs; make sure the
% uncertainty/noise is also in the same units
% get read noise for this cadence and for this modout
readNoiseInADU = pdqTempStruct.readNoiseForAllCadencesAllModOuts(cadenceIndex,pdqTempStruct.currentModOut);

% the random variable or uncertainty associated with the measurement
deltaRawBlack = sqrt( readNoiseInADU.^2 + (quantizationStepSizeInADU.^2/12) );

%------------------------------------------------------------------------
% Step 2: Set up T (transformation or mapping from raw black to 2D
% corrected black) and delta (uncertainty or noise associated with the raw black
% measurements. Refer to the design note (KADN-26185) for further clarification.
%------------------------------------------------------------------------

numberOfExposuresPerLongCadence = pdqTempStruct.configMapStruct.numberOfExposuresPerLongCadence(cadenceIndex);


% the transform or Jacobian  (a scalar)
TrawBlackTo2Dcorrected = sqrt(numberOfExposuresPerLongCadence);

%------------------------------------------------------------------------
% Step 3: Form covariance matrix of uncertainties on the raw black pixels
%------------------------------------------------------------------------

% black2DModel has units of ADU (aka DN)
% black2DModelUncertainties can be a scalar (leading to a full cov. matrix)
% or a diagonal covariance matrix; raw black pixel uncertainties form a
% diagonal cov. matrix

nBlackRows = length(pdqTempStruct.blackRows); % collect only those rows which have data - ignore gaps

nUniqueBlackRows = length(unique(pdqTempStruct.blackRows));

blackReadNoisePerCadence = zeros(nBlackRows,1);
blackReadNoisePerCadence(1:end) = deltaRawBlack;
if(~isempty(invalidBlackPixelIndices))
    % mind the data gaps
    blackReadNoisePerCadence(invalidBlackPixelIndices) = 0;
end
% compute covariance matrix of uncertainties
CblackRaw =  diag(blackReadNoisePerCadence.^2);

% adjust the covariance matrix (each element in the new covariance
% matrix is the sum of elements of a block matrix in the original
% covariance matrix divided by nUniqueBlackColumns^2)

% don't forget to update the uncertainty matrix which shrinks by a
% factor of number of nUniqueBlackColumns
% replace all pixels that have 2^32-1 to indicate data gaps with zeros
% and reshape


%------------------------------------------------------------------------
% Step 4a: % covariance matrix of uncertainties after 2D black subtraction
% step - no change to the covariance matrix as the 2D correction operation
% is viewed as a subtraction of a constant vector (the black 2D uncertainty
% matrix represents a model bias error rather than random errors)
%------------------------------------------------------------------------

% covariance matrix of uncertainties after 2D black subtraction step
% (the T's are all scalar)
Cblack2Dcorrected = TrawBlackTo2Dcorrected * CblackRaw * TrawBlackTo2Dcorrected';


pdqTempStruct.blackUncertaintyStruct(cadenceIndex).TrawBlackTo2Dcorrected = TrawBlackTo2Dcorrected;
pdqTempStruct.blackUncertaintyStruct(cadenceIndex).deltaRawBlack = deltaRawBlack;

%------------------------------------------------------------------------
% Step 4b: covariance matrix of uncertainties after the binning step
% It is difficult to represent the binning operation in terms of the
% transform operator (which is essentially the 'binmat' operation)
% followed by division by the number of pixels binned in each block
% matrix of size nUniqueBlackColumns x nUniqueBlackColumns
%------------------------------------------------------------------------


% binmat operation can be written as a transformation T2DcorrectedToBinned

% binmat does not work here..as we have sum the block diagonal matrices of
% size (nUniqueBlackRows x nUniqueBlackRows)
% from a matrix of size (nBlackRows x nBlackRows)


Cblack2DcorrectedToBinned =  zeros(nUniqueBlackRows, nUniqueBlackRows);

startIndex = 1;

for j = 1:nUniqueBlackColumns

    endIndex = startIndex + nUniqueBlackRows -1 ;
    Cblack2DcorrectedToBinned = Cblack2DcorrectedToBinned + Cblack2Dcorrected(startIndex:endIndex, startIndex:endIndex);
    startIndex = endIndex + 1;
end


% to perform elementwise division of two matrices, both should be
% matrices

matrixOfNumberOfBlacksInEachRow = repmat(numberOfBlacksInEachRow, 1, nBinnedRows);

% divide by zero possible here...to avoid that...
validIndices = find(matrixOfNumberOfBlacksInEachRow);


Cblack2DcorrectedToBinned(validIndices) = Cblack2DcorrectedToBinned(validIndices)./(matrixOfNumberOfBlacksInEachRow(validIndices).^2);

pdqTempStruct.blackUncertaintyStruct(cadenceIndex).Cblack2DcorrectedToBinned = Cblack2DcorrectedToBinned;

return
