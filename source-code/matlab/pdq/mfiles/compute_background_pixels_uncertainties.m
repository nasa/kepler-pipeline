function Cbkgd = compute_background_pixels_uncertainties(CsmearEstimate, CdarkCorrection, pdqTempStruct, cadenceIndex)


%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function Cbkgd = compute_background_pixels_uncertainties(CsmearEstimate,
% CdarkCorrection, pdqTempStruct, cadenceIndex)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Description:
% This function computes the uncertainties in the background pixels using
% uncertainties from the previous stages.
% This involves the following steps:
% Compute raw background pixels uncertainties covariance matrix
% Compute 2D black corrected background pixels uncertainties covariance matrix
% Compute black corrected, gain corrected background pixels uncertainties
% covariance matrix
% Compute smear corrected background pixels uncertainties covariance matrix
% Compute dark corrected background pixels uncertainties covariance matrix
% Compute flat field corrected background pixels uncertainties covariance matrix
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


readNoiseInADU = pdqTempStruct.readNoiseForAllCadencesAllModOuts(cadenceIndex,pdqTempStruct.currentModOut);
numberOfExposuresPerLongCadence = pdqTempStruct.configMapStruct.numberOfExposuresPerLongCadence(cadenceIndex);
gains = pdqTempStruct.gainForAllCadencesAllModOuts(cadenceIndex,pdqTempStruct.currentModOut); % for all cadences in electrons per ADU


quantizationStepSizeInADU           = 1; % reference pixels are not requantized



readNoiseSquared                    =  (readNoiseInADU).^2 ; % In ADU, per exposure
quantizationNoiseSquared            = (quantizationStepSizeInADU.^2/12);% In ADU, per exposure

% black uncertainty  terms
bestBlackPolyOrder                  = pdqTempStruct.blackUncertaintyStruct(cadenceIndex).bestBlackPolyOrder;
CblackPolyFit                       = pdqTempStruct.blackUncertaintyStruct(cadenceIndex).CblackPolyFit;

TgainCorrection                     =  pdqTempStruct.smearUncertaintyStruct(cadenceIndex).TgainCorrection;
smearColumns = pdqTempStruct.smearUncertaintyStruct(cadenceIndex).validSmearColumns;



% black 2D correction for background pixels


bkgdPixels                          = pdqTempStruct.bkgdPixelsBlackCorrected; % to estimate shot noise, in ADU
bkgdPixelColumns                    = pdqTempStruct.bkgdPixelColumns;
bkgdPixelRows                       = pdqTempStruct.bkgdPixelRows;


validBkgdPixelIndices               = find(~pdqTempStruct.bkgdGapIndicators(:,cadenceIndex));


% bkgdPixels                          = pdqTempStruct.bkgdPixelsBlackCorrected(bkgdPixelColumns,cadenceIndex) ; % to estimate shot noise
% bkgdPixelColumns                    = pdqTempStruct.bkgdPixelColumns(bkgdPixelColumns);
% bkgdPixelRows                       = pdqTempStruct.bkgdPixelRows(availableBkgdRows);





%--------------------------------------------------------------------------
% Compute raw background pixels uncertainties covariance matrix
%--------------------------------------------------------------------------

TrawBkgdTo2DcorrectedBkgd = sqrt(numberOfExposuresPerLongCadence);

if(~isempty(validBkgdPixelIndices))

    shotNoiseSquaredForBkgd  = bkgdPixels(validBkgdPixelIndices, cadenceIndex)/numberOfExposuresPerLongCadence/gains ;% In ADU, per exposure
    shotNoiseSquaredForBkgd(shotNoiseSquaredForBkgd < 0) = 0;

    rawBkgdUncertainties = sqrt( readNoiseSquared + quantizationNoiseSquared + shotNoiseSquaredForBkgd);


    pdqTempStruct.bkgdUncertaintyStruct(cadenceIndex).deltaRawBkgd =  rawBkgdUncertainties;

else

    pdqTempStruct.bkgdUncertaintyStruct(cadenceIndex).deltaRawBkgd = []; % does not exist for this cadenceIndex

end



% black 2D correction step
% compute covariance matrix of uncertainties

CbkgdRaw =  diag(pdqTempStruct.bkgdUncertaintyStruct(cadenceIndex).deltaRawBkgd.^2);



%--------------------------------------------------------------------------
% Compute 2D black corrected background pixels uncertainties covariance matrix
%--------------------------------------------------------------------------

Cbkgd2Dcorrected = TrawBkgdTo2DcorrectedBkgd * CbkgdRaw * TrawBkgdTo2DcorrectedBkgd';


%--------------------------------------------------------------------------
% Compute black corrected, gain corrected background pixels uncertainties
% covariance matrix
%--------------------------------------------------------------------------
nCcdRows = pdqTempStruct.nCcdRows; % 1070
% the design matrix is scaled for numerical stability

A = weighted_design_matrix(bkgdPixelRows(validBkgdPixelIndices)./nCcdRows, 1, bestBlackPolyOrder, 'standard');

CblackPolyFitForBkgd = A*CblackPolyFit*A';

CbkgdBlackCorr = TgainCorrection *(Cbkgd2Dcorrected + CblackPolyFitForBkgd)*TgainCorrection';

%--------------------------------------------------------------------------
% Compute smear corrected background pixels uncertainties covariance matrix
%--------------------------------------------------------------------------


% use only those columns that correspond to columns of background pixels -
% a subset of smear columns, use only those pixel columns with valid data
% (mind the data gaps)

[doAllBkgdColumnsHaveSmear, indexBkgdToSmearColumns] =  ismember(bkgdPixelColumns(validBkgdPixelIndices), smearColumns);

if( ~all(doAllBkgdColumnsHaveSmear))
    error('PDQ:evaluateBackgroundMeasurement:smearColumns', ...
        'After smear correction, not all background pixels columns have a matching smear pixel');

end

% extract a block matrix from CsmearEst corresponding to the background
% columns
% set up the transform or scale factor for long cadence ( a scalar)

CsmearEstimateForBkgd = CsmearEstimate;


%set up the transform or scale factor for long cadence ( a scalar)

[origRows, origCols] = size(CsmearEstimateForBkgd);
nBkgdColumns = length(bkgdPixelColumns(validBkgdPixelIndices));

rowIndex = repmat(indexBkgdToSmearColumns(:), 1, nBkgdColumns);
rowIndex = rowIndex';
rowIndex = rowIndex(:);

colIndex = repmat(indexBkgdToSmearColumns(:), nBkgdColumns, 1);
colIndex = colIndex(:);

CsmearEstimateForBkgd = CsmearEstimateForBkgd(sub2ind([origRows, origCols], rowIndex, colIndex)); % size 362x 1132
CsmearEstimateForBkgd = reshape(CsmearEstimateForBkgd, nBkgdColumns, nBkgdColumns);

%--------------------------------------------------------------------------
% Compute dark corrected background pixels uncertainties covariance matrix
%--------------------------------------------------------------------------


CdarkCorrectionForBkgd = CdarkCorrection(sub2ind([origRows, origCols], rowIndex, colIndex)); % size 362x 1132
CdarkCorrectionForBkgd = reshape(CdarkCorrectionForBkgd, nBkgdColumns, nBkgdColumns);

%--------------------------------------------------------------------------
% Compute flat field corrected background pixels uncertainties covariance matrix
%--------------------------------------------------------------------------


% same as CdarkCorrectedBkgd
CbkgdPriorToFlatFielding = CbkgdBlackCorr + CsmearEstimateForBkgd + CdarkCorrectionForBkgd;

%........................................................................
% JJ
% flat field residual error does not vary from frame to frame - it is a bias
% term not a noise term; carry it separately
% propagating uncertainties this way is incorrect because a constant bias
% term apperas as a noise term
% TdarkCorrectedBkgdToFlatCorrectedBkgd        = pdqTempStruct.bkgdFlatField(validBkgdPixelIndices,cadenceIndex); % a vector
% TflatFieldToBkgdCorrectedForFF   = pdqTempStruct.bkgdPixels(validBkgdPixelIndices, cadenceIndex); % a vector
% CffResidualError                 = diag(repmat(pdqTempStruct.flatFieldResidualError, length(TflatFieldToBkgdCorrectedForFF),1));
% Cbkgd = diag(TdarkCorrectedBkgdToFlatCorrectedBkgd) * CbkgdPriorToFlatFielding * diag(TdarkCorrectedBkgdToFlatCorrectedBkgd) + ...
%     diag(TflatFieldToBkgdCorrectedForFF) * CffResidualError * diag(TflatFieldToBkgdCorrectedForFF) ;
%........................................................................

TdarkCorrectedBkgdToFlatCorrectedBkgd        = pdqTempStruct.bkgdFlatField(validBkgdPixelIndices); % a vector

TdarkCorrectedBkgdToFlatCorrectedBkgd       = double(single(TdarkCorrectedBkgdToFlatCorrectedBkgd));% the flatfield need not be in double precision

Cbkgd = diag(TdarkCorrectedBkgdToFlatCorrectedBkgd) * CbkgdPriorToFlatFielding * diag(TdarkCorrectedBkgdToFlatCorrectedBkgd);


% RLM 3/23/11 -- Covariance matrices should be perfectly symmetric at any
% point in the computation. If they aren't it's because of round-off error.
% Below we force symmetry by substituting the average of each off-diagonal
% element and its corresponding element from the transposed matrix.
% -- RLM

% scrub Cbkgd
CbkgdEven = (Cbkgd+Cbkgd')/2;
CbkgdOdd = (Cbkgd-Cbkgd')/2;

Cbkgd = CbkgdEven; % Substitute best estimate (average value) - RLM

CevenToOddNorm = norm(CbkgdOdd)/norm(Cbkgd);

if CevenToOddNorm > 1e-10
% RLM 3/23/11 -- replaced error with warning
%    error('PDQ:backgroundPixelsUncertaintiesCalculation:InvalidCbkgdCovMat', 'Covariance Matrix must be postive semidefinite to better than 1e-10');
    warning('PDQ:backgroundPixelsUncertaintiesCalculation:InvalidCbkgdCovMat', 'Covariance Matrix should be postive semidefinite to better than 1e-10');
elseif CevenToOddNorm> eps
    warning('PDQ:backgroundPixelsUncertaintiesCalculation:SuspectCbkgdCovMat', 'Covariance Matrix should be postive semidefinite to within roundoff error (eps)');
end


[Tcolumn,errFlagColumn] = factor_covariance_matrix(Cbkgd);


if errFlagColumn < 0 % => T = []
    %  not a valid covariance matrix.
    error('PDQ:backgroundPixelsUncertaintiesCalculation:InvalidCbkgdPixelsCovMat', 'Covariance matrix must be positive definite or positive semidefinite.');
end


return
