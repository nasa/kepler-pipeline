function CtargetPixels = compute_target_pixels_uncertainties(CestSmear, CdarkCorrection, Cbkgd,...
    pdqTempStruct, cadenceIndex)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function CtargetPixels = compute_target_pixels_uncertainties(CestSmear,
% CdarkCorrection, Cbkgd, pdqTempStruct, cadenceIndex)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Description:
% This function computes the uncertainties in the target pixels using
% uncertainties from the previous stages.
% This involves the following steps:
% Compute raw target pixels uncertainties covariance matrix
% Compute 2D black corrected target pixels uncertainties covariance matrix
% Compute black corrected, gain corrected target pixels uncertainties
% covariance matrix
% Compute smear corrected target pixels uncertainties covariance matrix
% Compute dark corrected target pixels uncertainties covariance matrix
% Compute flat field corrected target pixels uncertainties covariance matrix
% Compute background corrected target pixels uncertainties covariance matrix
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

targetPixels            = pdqTempStruct.targetPixelsBlackCorrected(:,cadenceIndex) ; % to estimate shot noise
targetPixelColumns      = pdqTempStruct.targetPixelColumns;
targetPixelRows         = pdqTempStruct.targetPixelRows;
targetGapIndicators     = pdqTempStruct.targetGapIndicators(:,cadenceIndex);


validPixelIndices       = find(~targetGapIndicators);


targetPixels            = targetPixels(validPixelIndices);

targetPixelRows        = targetPixelRows(validPixelIndices);

targetPixelColumns     = targetPixelColumns(validPixelIndices);


% parameters/ FC constants

readNoiseInADU = pdqTempStruct.readNoiseForAllCadencesAllModOuts(cadenceIndex,pdqTempStruct.currentModOut);
numberOfExposuresPerLongCadence = pdqTempStruct.configMapStruct.numberOfExposuresPerLongCadence(cadenceIndex);
gains = pdqTempStruct.gainForAllCadencesAllModOuts(cadenceIndex,pdqTempStruct.currentModOut); % for all cadences in electrons per ADU


quantizationStepSizeInADU           = 1; % reference pixels are not requantized

readNoiseSquared                    =  (readNoiseInADU).^2 ; % In ADU, per exposure
quantizationNoiseSquared            = (quantizationStepSizeInADU.^2/12);% In ADU, per exposure


% black uncertainty  terms

bestBlackPolyOrder                  = pdqTempStruct.blackUncertaintyStruct(cadenceIndex).bestBlackPolyOrder;
CblackPolyFit                       = pdqTempStruct.blackUncertaintyStruct(cadenceIndex).CblackPolyFit;


% uncertainties terms from smear and dark correction

TgainCorrection                     = pdqTempStruct.smearUncertaintyStruct(cadenceIndex).TgainCorrection;
smearColumns                        = pdqTempStruct.smearUncertaintyStruct(cadenceIndex).validSmearColumns;

%--------------------------------------------------------------------------
% Compute raw target pixels uncertainties covariance matrix
%--------------------------------------------------------------------------

TrawTargetTo2DcorrectedTarget = sqrt(numberOfExposuresPerLongCadence);

if(~isempty(validPixelIndices))

    shotNoiseSquaredForTarget  = targetPixels/numberOfExposuresPerLongCadence/gains ;% in  ADU, per exposure

    shotNoiseSquaredForTarget(shotNoiseSquaredForTarget < 0) = 0;

    rawTargetUncertainties = sqrt( readNoiseSquared + quantizationNoiseSquared + shotNoiseSquaredForTarget);


    pdqTempStruct.targetUncertaintyStruct(cadenceIndex).deltaRawTarget =  rawTargetUncertainties;

else

    pdqTempStruct.targetUncertaintyStruct(cadenceIndex).deltaRawTarget = []; % does not exist for this cadenceIndex

end



% black 2D correction step
% compute covariance matrix of uncertainties

CtargetRaw =  diag(pdqTempStruct.targetUncertaintyStruct(cadenceIndex).deltaRawTarget.^2);



%--------------------------------------------------------------------------
% Compute 2D black corrected target pixels uncertainties covariance matrix
%--------------------------------------------------------------------------

Ctarget2Dcorrected = TrawTargetTo2DcorrectedTarget * CtargetRaw * TrawTargetTo2DcorrectedTarget' ;


%--------------------------------------------------------------------------
% Compute black corrected, gain corrected target pixels uncertainties
% covariance matrix
%--------------------------------------------------------------------------

nCcdRows = pdqTempStruct.nCcdRows; % 1070
% the design matrix is scaled for numerical stability


A = weighted_design_matrix(targetPixelRows./nCcdRows, 1, bestBlackPolyOrder, 'standard');

CblackFitted = A*CblackPolyFit*A';

CtargetBlackCorr = TgainCorrection *(Ctarget2Dcorrected + CblackFitted)*TgainCorrection';


%--------------------------------------------------------------------------
% Compute smear corrected target pixels uncertainties covariance matrix
%--------------------------------------------------------------------------

% use only those columns that correspond to columns of target pixels -
% a subset of smear columns, use only those pixel columns with valid data
% (mind the data gaps)

[doAllTargetColumnsHaveSmear, indexTargetToSmearColumns] =  ismember(targetPixelColumns, smearColumns);

% sanity check

if( ~all(doAllTargetColumnsHaveSmear))
    error('PDQ:computeTargetpixelUncertainties:smearColumns', ...
        'After smear correction, not all target pixels columns have a matching smear pixel');

end

% extract a block matrix from CsmearEst corresponding to the target
% columns
% set up the transform or scale factor for long cadence ( a scalar)

CsmearEstForTarget = CestSmear;


%set up the transform or scale factor for long cadence ( a scalar)

[origRows, origCols] = size(CsmearEstForTarget);
nTargetColumns = length(targetPixelColumns);

rowIndex = repmat(indexTargetToSmearColumns(:), 1, nTargetColumns);
rowIndex = rowIndex';
rowIndex = rowIndex(:);

colIndex = repmat(indexTargetToSmearColumns(:), nTargetColumns, 1);
colIndex = colIndex(:);

CsmearEstForTarget = CsmearEstForTarget(sub2ind([origRows, origCols], rowIndex, colIndex)); % size 362x 1132
CsmearEstForTarget = reshape(CsmearEstForTarget, nTargetColumns, nTargetColumns);

%--------------------------------------------------------------------------
% Compute dark corrected target pixels uncertainties covariance matrix
%--------------------------------------------------------------------------

CdarkCorrectionForTarget = CdarkCorrection;

CdarkCorrectionForTarget = CdarkCorrectionForTarget(sub2ind([origRows, origCols], rowIndex, colIndex)); % size 362x 1132
CdarkCorrectionForTarget = reshape(CdarkCorrectionForTarget, nTargetColumns, nTargetColumns);

%--------------------------------------------------------------------------
% Compute flat field corrected target pixels uncertainties covariance matrix
%--------------------------------------------------------------------------

CtargetPriorToFlatFielding = CtargetBlackCorr + CsmearEstForTarget + CdarkCorrectionForTarget;


%........................................................................
% JJ
% flat field residual error does not vary from frame to frame - it is a bias
% term not a noise term; carry it separately
% propagating uncertainties this way is incorrect because a constant bias
% term apperas as a noise term
%
% TflatFieldToTargetCorrectedForFF   = targetPixels; % a vector
% TdarkCorrectedToFlatCorrectedTarget        = pdqTempStruct.targetFlatField(validPixelIndices, cadenceIndex); % a vector
%
% CffResidualError                 = diag(repmat(pdqTempStruct.flatFieldResidualError, length(TflatFieldToTargetCorrectedForFF),1));
%
%
% CtargetPixelsAfterFlatField = diag(TdarkCorrectedToFlatCorrectedTarget) * CtargetPriorToFlatFielding * diag(TdarkCorrectedToFlatCorrectedTarget) + ...
%     diag(TflatFieldToTargetCorrectedForFF) * CffResidualError * diag(TflatFieldToTargetCorrectedForFF) ;
%........................................................................

TdarkCorrectedToFlatCorrectedTarget        = pdqTempStruct.targetFlatField(validPixelIndices); % a vector

TdarkCorrectedToFlatCorrectedTarget        = double(single(TdarkCorrectedToFlatCorrectedTarget)); % the flatfield need not be in double precision


CtargetPixelsAfterFlatField = diag(TdarkCorrectedToFlatCorrectedTarget) * CtargetPriorToFlatFielding * diag(TdarkCorrectedToFlatCorrectedTarget);



%--------------------------------------------------------------------------
% Compute background corrected target pixels uncertainties covariance matrix
%--------------------------------------------------------------------------

% after background correction

bkgdPixelWeights = pdqTempStruct.targetPixelsUncertaintyStruct(cadenceIndex).bkgdWeights;

CestBkgdLevel = bkgdPixelWeights * Cbkgd * bkgdPixelWeights';

CtargetPixels = CtargetPixelsAfterFlatField + CestBkgdLevel;

% scrub CtargetPixels
CtargetPixelsEven = (CtargetPixels+CtargetPixels')/2;
CtargetPixelsOdd = (CtargetPixels-CtargetPixels')/2;

CtargetPixels = CtargetPixelsEven;

CevenToOddNorm = norm(CtargetPixelsOdd)/norm(CtargetPixels);

if CevenToOddNorm > 1e-10
% RLM 3/23/11 -- replaced error with warning
%     error('PDQ:targetPixelsUncertaintiesCalculation:InvalidCtargetPixelsCovMat', 'Covariance Matrix must be postive semidefinite to better than 1e-10');
    warning('PDQ:targetPixelsUncertaintiesCalculation:InvalidCtargetPixelsCovMat', 'Covariance Matrix should be postive semidefinite to better than 1e-10');
elseif CevenToOddNorm> eps
    warning('PDQ:targetPixelsUncertaintiesCalculation:SuspectCtargetPixelsCovMat', 'Covariance Matrix should be postive semidefinite to within roundoff error (eps)');
end


[Tcolumn,errFlagColumn] = factor_covariance_matrix(CtargetPixels);

if errFlagColumn < 0 % => T = []
    %  not a valid covariance matrix.
    error('PDQ:targetPixelsUncertaintiesCalculation:InvalidCtargetPixelsCovMat', 'Covariance matrix must be positive definite or positive semidefinite.');
end


return


% comment out later ...used for verfication of
% imagesc(sqrt(CtargetPixels), [1e2 1e4]);colorbar;figure(gcf)

% %%
% actualPixels = zeros(length(pdqTempStruct.numPixels), 1);
% cumNumPixels = cumsum(pdqTempStruct.numPixels);
% targetgapIndicators =  pdqTempStruct.targetGapIndicators(:,1);
% actualPixels(1) = sum(targetgapIndicators(1:cumNumPixels(1)));
% for j = 1: length(cumNumPixels)
%     actualPixels(j+1) = sum(targetgapIndicators(cumNumPixels(j)+1 : cumNumPixels(j+1)));
% end
