function s = fit_2D_corrected_black_with_best_polynomial(s, cadenceIndex)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function s = fit_2D_corrected_black_with_best_polynomial(s, cadenceIndex)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% (1) use AIC to decide on the polynomial order
% (2) propagation of errors - see KADN-26185
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
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


validBlackPixelIndices  = find(~s.binnedBlackGapIndicators(:,cadenceIndex));
nCcdRows = s.nCcdRows; % 1070

% pre allocate memory to hold black fitted values for all rows
if(cadenceIndex == 1)
    s.blackCorrection = zeros(length(s.ccdRows), s.numCadences);
    s.meanBlack = zeros(s.numCadences, 1);
    s.meanBlackUncertainties = zeros(s.numCadences, 1);

end


if(isempty(validBlackPixelIndices))

    s.blackUncertaintyStruct(cadenceIndex).bestBlackPolyOrder   = -1;
    s.meanBlack(cadenceIndex)                                   = -1;
    s.meanBlackUncertainties(cadenceIndex)                      = -1;

    s.blackCorrection(:,cadenceIndex)                           = -1;

    s.blackUncertaintyStruct(cadenceIndex).CblackPolyFit        = [];

    warning('PDQ:correctBlackLevel:NoBlackLevelsAvailableAfterBinning', ...
        ['fit_2D_corrected_black_with_best_polynomial: no black levels available for ' num2str(s.numCadences) ' cadences - can''t do black correction!']);

    return;
end

if (length(validBlackPixelIndices) == 1)  % what happens when the number of reference pixels downlinked shrinks...

    Cblack2DcorrectedToBinned     = s.blackUncertaintyStruct(cadenceIndex).Cblack2DcorrectedToBinned;
    s.blackUncertaintyStruct(cadenceIndex).bestBlackPolyOrder   = 0;
    s.meanBlack(cadenceIndex)                                   = s.binnedBlackPixels(validBlackPixelIndices, cadenceIndex);
    s.meanBlackUncertainties(cadenceIndex)                      = sum(sum(Cblack2DcorrectedToBinned)); % Cblack2DcorrectedToBinned is a scalar now...

    s.blackCorrection(:,cadenceIndex)                           = s.binnedBlackPixels(validBlackPixelIndices, cadenceIndex);

    s.blackUncertaintyStruct(cadenceIndex).CblackPolyFit        = [];

    return
end


availableBlackRows      =  s.binnedBlackRows(validBlackPixelIndices, cadenceIndex);

availableBlackPixels    = s.binnedBlackPixels(validBlackPixelIndices, cadenceIndex);
nAvailableBlackPixels   = length(availableBlackPixels);

% restrict the polynomial order as otherwise we will be testing polynomial
% order > number of samples available

maxBlackPolyOrder   = min(s.maxBlackPolyOrder, nAvailableBlackPixels - 1);

criterionAIC        = zeros(maxBlackPolyOrder,1);

Cblack2DcorrectedToBinned     = s.blackUncertaintyStruct(cadenceIndex).Cblack2DcorrectedToBinned;

% RLM 2/1/11 -- If necessary, construct a new covariance matrix by extracting
% covariances between available black rows. Note that validRowIndicators 
% needs to be numerical, not logical, for matrix mult.
if any(s.binnedBlackGapIndicators(:,cadenceIndex))
    validRowIndicators = 1 - s.binnedBlackGapIndicators(:,cadenceIndex); 
    covSelectIndices = find(validRowIndicators * validRowIndicators');
    Cblack2DcorrectedToBinned = reshape(Cblack2DcorrectedToBinned(covSelectIndices), ...
        numel(validBlackPixelIndices), numel(validBlackPixelIndices));
end
% -- RLM

% turn warnings off temporaraily as we need to go beyond the polynomial
% order inherent in the data so as to identify the correct order
warning off all;

for jPolyOrder = 0:maxBlackPolyOrder

    % no weights, but a simple design matrix
    A = weighted_design_matrix(availableBlackRows./nCcdRows, 1, jPolyOrder, 'standard');

    % [x,stdx,mse,S] = lscov(A,b,V,alg)
    % lscov assumes that the covariance matrix of B is known only up to a scale
    % factor. mse is an estimate of that unknown scale factor, and lscov scales
    % the outputs S and stdx appropriately. However, if V is known to be
    % exactly the covariance matrix of B, then that scaling is unnecessary. To
    % get the appropriate estimates in this case, you should rescale S and stdx
    % by 1/mse and sqrt(1/mse), respectively.

    [polyCoeffts, std, mse] = lscov(A, availableBlackPixels, Cblack2DcorrectedToBinned);

    K = length(polyCoeffts);
    n = length(validBlackPixelIndices);

    meanSquareError = mse;
    % AICc

    criterionAIC(jPolyOrder+1) = 2*K + n*log(meanSquareError) + 2*K*(K+1)/(n-K-1);
    if(criterionAIC(jPolyOrder+1) < 0)
        break;
    end;

end

% restore warning state
warning on all;


[minAIC bestBlackPolyOrder] = min(criterionAIC);
bestBlackPolyOrder          = bestBlackPolyOrder -1;

A = weighted_design_matrix(availableBlackRows./nCcdRows, 1, bestBlackPolyOrder, 'standard');

[polyCoeffts, std, mse, CblackPolyFit] = lscov(A, availableBlackPixels, Cblack2DcorrectedToBinned);

blackPolyFitValuesOverAvailable  = A * polyCoeffts;

% cov matrix of uncertainties in the fitted values, quite big - so will not be carried around
% lscov assumes that the covariance matrix of B is known only up to a scale
% factor. mse is an estimate of that unknown scale factor, and lscov scales
% the outputs S and stdx appropriately. However, if V is known to be
% exactly the covariance matrix of B, then that scaling is unnecessary. To
% get the appropriate estimates in this case, you should rescale S and stdx
% by 1/mse and sqrt(1/mse), respectively.

if(mse <= eps('double'))
    CblackPolyFit = 0;
else
    %CblackPolyFit   = CblackPolyFit./mse;
end


[Tcolumn,errFlagColumn] = factor_covariance_matrix(CblackPolyFit);

% try - catch ? and set the order to 0 if error?
if errFlagColumn < 0 % => T = []
    %  not a valid covariance matrix.
    error('PDQ:fit_2D_corrected_black_with_best_polynomialn:InvalidCblackPolyFit', 'Covariance matrix must be positive definite or positive semidefinite.');
end



CblackFitted    = A*CblackPolyFit*A'; % 1070x1070 - so create, use, and discard





%---------------------------------------------------------------------
% may be here is the place to compute uncertainty in the mean black
% value as the tracked time series consisting of mean black level
% should have uncertainties as well
%---------------------------------------------------------------------
% the uncertainties returned are a vector, what we need is a
% covariance matrix

% Calculate mean black level per CCD module/ouput

s.blackUncertaintyStruct(cadenceIndex).bestBlackPolyOrder = bestBlackPolyOrder;

s.meanBlack(cadenceIndex) = mean(blackPolyFitValuesOverAvailable);

s.meanBlackUncertainties(cadenceIndex)                  = (1/length(availableBlackRows))* sqrt(sum(sum(CblackFitted)));

Awiggle = weighted_design_matrix(s.ccdRows./nCcdRows, 1, bestBlackPolyOrder, 'standard');

s.blackCorrection(:, cadenceIndex)                      = Awiggle * polyCoeffts; % over all CCD rows, a vector 1070 long

s.blackUncertaintyStruct(cadenceIndex).CblackPolyFit    = CblackPolyFit; % small matrix
s.blackUncertaintyStruct(cadenceIndex).polyCoeffts = polyCoeffts;

% RLM 2/18/11 -- The field blackResiduals is subsequently used only for
% validation plots, not for data processing. Therefore we don't have to
% worry too much about unintended effects of altering this code so it
% doesn't throw errors. Errors are occasionally thrown when processing
% gappy data because gaps can cause 'availableBlackRows' to have different
% numbers of elements from cadence to cadence.
residuals = availableBlackPixels - s.blackCorrection(availableBlackRows, cadenceIndex);

% If a blackResiduals matrix already exists, force agreement of dimensions
% with the residuals vector.
if isfield(s, 'blackResiduals') 
    nRows_blackResiduals = size(s.blackResiduals, 1);
    len_residuals = length(residuals);
    
    if len_residuals < nRows_blackResiduals
        tempVect = zeros(nRows_blackResiduals, 1);
        tempVect(1:len_residuals) = residuals;
        residuals = tempVect;
    else
        if len_residuals < nRows_blackResiduals
            tempMat = zeros(max(len_residuals, nRows_blackResiduals), ...
                            cadenceIndex);
            tempMat(1:nRows_blackResiduals, 1:(cadenceIndex-1)) = s.blackResiduals;
            s.blackResiduals = tempMat;
        end
    end
end

s.blackResiduals(:, cadenceIndex)  = residuals;

return