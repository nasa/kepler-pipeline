function [CsmearEstimate, CmsmearGainCorrected, CvsmearGainCorrected, pdqTempStruct]   = compute_smear_pixels_uncertainties(pdqTempStruct, cadenceIndex)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [CsmearEstimate, CmsmearGainCorrected, CvsmearGainCorrected, pdqTempStruct]   =
% compute_smear_pixels_uncertainties(pdqTempStruct, cadenceIndex)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% This function computes the uncertainties in the smear levels starting with
% the raw masked smear and raw virtual smear pixels and their
% uncertainties. This involves the following steps:
% Compute raw masked smear pixel uncertainties covariance matrix
% Compute raw virtual smear pixel uncertainties covariance matrix
% Compute 2D black corrected masked smear pixel uncertainties covariance matrix
% Compute 2D black corrected virtual smear pixel uncertainties covariance matrix
% Compute binned masked smear pixel uncertainties covariance matrix
% Compute binned virtual smear pixel uncertainties covariance matrix
% Compute black corrected masked smear pixel uncertainties covariance matrix
% Compute black corrected virtual smear pixel uncertainties covariance matrix
% Compute smear pixel uncertainties covariance matrix
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
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

%--------------------------------------------------------------------------
% preliminaries...
%--------------------------------------------------------------------------

% Config map terms

readNoiseInADU = pdqTempStruct.readNoiseForAllCadencesAllModOuts(cadenceIndex,pdqTempStruct.currentModOut);
numberOfExposuresPerLongCadence = pdqTempStruct.configMapStruct.numberOfExposuresPerLongCadence(cadenceIndex);
gains = pdqTempStruct.gainForAllCadencesAllModOuts(:,pdqTempStruct.currentModOut); % for all cadences in electrons per ADU


quantizationStepSizeInADU           = 1; % reference pixels are not requantized

% smear (masked, virtual) pixels terms

numberOfMsmearsInEachColumn         = pdqTempStruct.msmearPixelsInColumnBin(:, cadenceIndex);
nUniqueMsmearRows                   = pdqTempStruct.numberOfMsmearRowsBinned(:, cadenceIndex);
nUniqueMsmearColumns                = length(unique(pdqTempStruct.msmearColumns));

numberOfVsmearsInEachColumn         = pdqTempStruct.vsmearPixelsInColumnBin(:, cadenceIndex);
nUniqueVsmearRows                   = pdqTempStruct.numberOfVsmearRowsBinned(:, cadenceIndex);
nUniqueVsmearColumns                = length(unique(pdqTempStruct.vsmearColumns));


% black uncertainty  terms
bestBlackPolyOrder                  = pdqTempStruct.blackUncertaintyStruct(cadenceIndex).bestBlackPolyOrder;
CblackPolyFit                       = pdqTempStruct.blackUncertaintyStruct(cadenceIndex).CblackPolyFit;


% uncertainties terms from smear and dark correction
darkCurrentsUncertainty             = pdqTempStruct.smearUncertaintyStruct(cadenceIndex).darkCurrentsUncertainty;
TgainCorrection                     =  pdqTempStruct.smearUncertaintyStruct(cadenceIndex).TgainCorrection;
TrawMsmearTo2Dcorrected             =  pdqTempStruct.smearUncertaintyStruct(cadenceIndex).TrawMsmearTo2Dcorrected;
TrawVsmearTo2Dcorrected             =  pdqTempStruct.smearUncertaintyStruct(cadenceIndex).TrawVsmearTo2Dcorrected;
TcorrMsmearToEstSmear               =  pdqTempStruct.smearUncertaintyStruct(cadenceIndex).TcorrMsmearToEstSmear;
TcorrVsmearToEstSmear               =  pdqTempStruct.smearUncertaintyStruct(cadenceIndex).TcorrVsmearToEstSmear;

%--------------------------------------------------------------------------
% Compute raw masked smear pixel uncertainties covariance matrix
%--------------------------------------------------------------------------

readNoiseSquared                    =  (readNoiseInADU).^2 ; % In ADU, per exposure
quantizationNoiseSquared            = (quantizationStepSizeInADU.^2/12);% In ADU, per exposure

% masked smear pixels - 2D black, black fit subtracted
msmearPixels                        = pdqTempStruct.msmearPixels;

% a major complication here.....
% the deltaRawSmear should be for raw smear pixels before they get
% binned

% Correct original (unbinned) masked smear  pixels for black level
validMsmearPixelIndices             = find(~pdqTempStruct.msmearGapIndicators(:,cadenceIndex));

if(~isempty(validMsmearPixelIndices))

    shotNoiseSquaredForMsmear       = msmearPixels(validMsmearPixelIndices, cadenceIndex)/numberOfExposuresPerLongCadence/(gains(cadenceIndex).^2);% smearPixels in e-, convert to ADU, per exposure
    
    shotNoiseSquaredForMsmear(shotNoiseSquaredForMsmear < 0) = 0;

    rawMsmearUncertainties          = sqrt(readNoiseSquared + quantizationNoiseSquared + shotNoiseSquaredForMsmear);

    pdqTempStruct.smearUncertaintyStruct(cadenceIndex).deltaRawMsmear =  rawMsmearUncertainties;
    % a vector which will become a diagonal cov. matrix of uncertainties
else

    pdqTempStruct.smearUncertaintyStruct(cadenceIndex).deltaRawMsmear = []; % does not exist for this cadenceIndex

end

% compute covariance matrix of uncertainties

CmsmearRaw =  diag(pdqTempStruct.smearUncertaintyStruct(cadenceIndex).deltaRawMsmear.^2);

%--------------------------------------------------------------------------
% Compute raw virtual smear pixel uncertainties covariance matrix
%--------------------------------------------------------------------------

% Virtual smear pixels - 2D black, black fit subtracted
vsmearPixels                        = pdqTempStruct.vsmearPixels;

% Correct original (unbinned) virtual smear pixels for black level
validVsmearPixelIndices             = find(~pdqTempStruct.vsmearGapIndicators(:,cadenceIndex));

if(~isempty(validVsmearPixelIndices))

    shotNoiseSquaredForVsmear       = vsmearPixels(validVsmearPixelIndices, cadenceIndex)/numberOfExposuresPerLongCadence/(gains(cadenceIndex).^2)  ;% In ADU, per exposure


    rawVsmearUncertainties          = sqrt( readNoiseSquared + quantizationNoiseSquared + shotNoiseSquaredForVsmear);


    pdqTempStruct.smearUncertaintyStruct(cadenceIndex).deltaRawVsmear =  rawVsmearUncertainties;

else

    pdqTempStruct.smearUncertaintyStruct(cadenceIndex).deltaRawVsmear = []; % does not exist for this cadenceIndex

end


% compute covariance matrix of uncertainties

CvsmearRaw =  diag(pdqTempStruct.smearUncertaintyStruct(cadenceIndex).deltaRawVsmear.^2);

%--------------------------------------------------------------------------
% Compute 2D black corrected masked smear pixel uncertainties covariance matrix
%--------------------------------------------------------------------------


Cmsmear2Dcorrected = TrawMsmearTo2Dcorrected * CmsmearRaw * TrawMsmearTo2Dcorrected';


%--------------------------------------------------------------------------
% Compute 2D black corrected virtual smear pixel uncertainties covariance matrix
%--------------------------------------------------------------------------

Cvsmear2Dcorrected = TrawVsmearTo2Dcorrected * CvsmearRaw * TrawVsmearTo2Dcorrected';


%--------------------------------------------------------------------------
% Compute binned masked smear pixel uncertainties covariance matrix
%--------------------------------------------------------------------------
% now we have a problem if there are data gaps in msmear pixels; number of
% pixels in each bin might vary and binmat will fail since it needs the
% same size block to bin

% temporarily expand Cmsmear to full size and fill the entries
% corresponding to invalid pixel indices to 0

CmsmearResTemp = zeros(length(msmearPixels(:, cadenceIndex)),length(msmearPixels(:, cadenceIndex)));


rowIndex = repmat(validMsmearPixelIndices(:), 1, length(validMsmearPixelIndices));
rowIndex = rowIndex';
rowIndex = rowIndex(:);

colIndex = repmat(validMsmearPixelIndices(:), length(validMsmearPixelIndices), 1);
colIndex = colIndex(:);


indicesToFill = sub2ind(size(CmsmearResTemp), rowIndex,colIndex);

CmsmearResTemp(indicesToFill) = Cmsmear2Dcorrected;

%-----------------------------------------------------------------------

% binmat does not work here..as we have sum the block diagonal matrices of
% size (nUniqueBlackRows x nUniqueBlackRows)
% from a matrix of size (nBlackRows x nBlackRows)


CmsmearBinned =  zeros(nUniqueMsmearColumns, nUniqueMsmearColumns);

startIndex = 1;

for j = 1:nUniqueMsmearRows

    endIndex = startIndex + nUniqueMsmearColumns -1 ;
    CmsmearBinned = CmsmearBinned + CmsmearResTemp(startIndex:endIndex, startIndex:endIndex);
    startIndex = endIndex + 1;
end


%-----------------------------------------------------------------------




% to perform elementwise division of two matrices, both should be
% matrices


validSmearColumns = pdqTempStruct.smearUncertaintyStruct(cadenceIndex).validSmearColumns;
binnedMsmearColumns = pdqTempStruct.binnedMsmearColumns;

matrixOfNumberOfMsmearsInEachColumn = repmat(numberOfMsmearsInEachColumn, 1, length(numberOfMsmearsInEachColumn));

% divide by zero possible here...to avoid that...
validIndices = find(matrixOfNumberOfMsmearsInEachColumn);


CmsmearBinned(validIndices) = CmsmearBinned(validIndices)./(matrixOfNumberOfMsmearsInEachColumn(validIndices).^2);

[commonValidColumns, validIndicesToKeep]  = intersect(binnedMsmearColumns(:,cadenceIndex),validSmearColumns);

CmsmearBinned = CmsmearBinned(validIndicesToKeep, validIndicesToKeep);

pdqTempStruct.smearUncertaintyStruct(cadenceIndex).CmsmearBinned = CmsmearBinned;


%--------------------------------------------------------------------------
% Compute binned virtual smear pixel uncertainties covariance matrix
%--------------------------------------------------------------------------
CvsmearResTemp = zeros(length(vsmearPixels(:, cadenceIndex)),length(vsmearPixels(:, cadenceIndex)));


rowIndex = repmat(validVsmearPixelIndices(:), 1, length(validVsmearPixelIndices));
rowIndex = rowIndex';
rowIndex = rowIndex(:);

colIndex = repmat(validVsmearPixelIndices(:), length(validVsmearPixelIndices), 1);
colIndex = colIndex(:);


indicesToFill = sub2ind(size(CvsmearResTemp), rowIndex,colIndex);

CvsmearResTemp(indicesToFill) = Cvsmear2Dcorrected;


%-----------------------------------------------------------------------

% binmat does not work here..as we have sum the block diagonal matrices of
% size (nUniqueBlackRows x nUniqueBlackRows)
% from a matrix of size (nBlackRows x nBlackRows)


CvsmearBinned =  zeros(nUniqueVsmearColumns, nUniqueVsmearColumns);

startIndex = 1;

for j = 1:nUniqueVsmearRows

    endIndex = startIndex + nUniqueVsmearColumns -1 ;
    CvsmearBinned = CvsmearBinned + CvsmearResTemp(startIndex:endIndex, startIndex:endIndex);
    startIndex = endIndex + 1;
end


%-----------------------------------------------------------------------


validSmearColumns = pdqTempStruct.smearUncertaintyStruct(cadenceIndex).validSmearColumns;
binnedVsmearColumns = pdqTempStruct.binnedVsmearColumns;

matrixOfNumberOfVsmearsInEachColumn = repmat(numberOfVsmearsInEachColumn, 1, length(numberOfVsmearsInEachColumn));

% divide by zero possible here...to avoid that...
validIndices = find(matrixOfNumberOfVsmearsInEachColumn);


CvsmearBinned(validIndices) = CvsmearBinned(validIndices)./(matrixOfNumberOfVsmearsInEachColumn(validIndices).^2);

[commonValidColumns, validIndicesToKeep]  = intersect(binnedVsmearColumns(:,cadenceIndex),validSmearColumns);

CvsmearBinned = CvsmearBinned(validIndicesToKeep, validIndicesToKeep);

pdqTempStruct.smearUncertaintyStruct(cadenceIndex).CvsmearBinned = CvsmearBinned;


pdqTempStruct.smearUncertaintyStruct(cadenceIndex).CvsmearBinned = CvsmearBinned;

%--------------------------------------------------------------------------
% Compute black corrected masked smear pixel uncertainties covariance matrix
%--------------------------------------------------------------------------
nCcdRows = pdqTempStruct.nCcdRows; % 1070

% the design matrix is scaled for numerical stability
A = weighted_design_matrix(pdqTempStruct.binnedMsmearRow(cadenceIndex)./nCcdRows, 1, bestBlackPolyOrder, 'standard');

CblackPolyFitForBinnedMsmear = A*CblackPolyFit*A';

% no scaling constants here.....
% no gain corrections yet....

CmsmearGainCorrected = CmsmearBinned + CblackPolyFitForBinnedMsmear;

pdqTempStruct.smearUncertaintyStruct(cadenceIndex).CblackPolyFitForBinnedMsmear = CblackPolyFitForBinnedMsmear;


%--------------------------------------------------------------------------
% Compute black corrected virtual smear pixel uncertainties covariance matrix
%--------------------------------------------------------------------------

A = weighted_design_matrix(pdqTempStruct.binnedVsmearRow(cadenceIndex)./nCcdRows, 1, bestBlackPolyOrder, 'standard');

CblackPolyFitForBinnedVsmear = A*CblackPolyFit*A';

% no scaling constants here.....
% no gain corrections yet....

CvsmearGainCorrected = CvsmearBinned + CblackPolyFitForBinnedVsmear;

pdqTempStruct.smearUncertaintyStruct(cadenceIndex).CblackPolyFitForBinnedVsmear = CblackPolyFitForBinnedVsmear;


%--------------------------------------------------------------------------
% Compute smear pixel uncertainties covariance matrix
%--------------------------------------------------------------------------

if(isempty(darkCurrentsUncertainty))

    CmsmearGainCorrected =   TgainCorrection* CmsmearGainCorrected * TgainCorrection;

    CvsmearGainCorrected =   TgainCorrection* CvsmearGainCorrected * TgainCorrection;


    % the matrices could be of different sizes depending on where the data
    % gaps occurred...
    % choose only the common smear columns.....done in correct_smear.m


    CsmearEstimate = TcorrMsmearToEstSmear * CmsmearGainCorrected * TcorrMsmearToEstSmear + ...
        TcorrVsmearToEstSmear * CvsmearGainCorrected * TcorrVsmearToEstSmear;

else % no virtual smear, very unlikely....


    %CmsmearGainCorrected =   TgainCorrection* CmsmearGainCorrected * TgainCorrection;


    % avoid unit mismatch
    CdarkSubtraction = darkCurrentsUncertainty.^2; % uncertainty on the median value (metric)

    CsmearEstimate =  TgainCorrection*(CmsmearGainCorrected  + CdarkSubtraction)*TgainCorrection;

end


[Tcolumn,errFlagColumn] = factor_covariance_matrix(CsmearEstimate);


if errFlagColumn < 0 % => T = []
    %  not a valid covariance matrix.
    error('PDQ:smearPixelsUncertaintiesCalculation:InvalidCsmearEstimateCovMat', 'Covariance matrix must be positive definite or positive semidefinite.');
end

return
