function cbdObj = polyfit_collateral(cbdObj, differenceBlack, badPixels)

% function cbdObj = polyfit_collateral(cbdObj, differenceBlack, badPixels)
% compare the difference between black model and the measurements from FFIs
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

[rows, cols] = size(differenceBlack);


%% loop through each of the collateral regions
polyFitOrder        = cbdObj.polyFitOrder;
polyFitIter         = 3;    % per STB recommendation
polyFitCutoff       = 2;

trailingBlackCols   = cbdObj.trailingBlackCols;
numTrailingBlackCols = length( trailingBlackCols );

leadingBlackCols   = cbdObj.leadingBlackCols;
numLeadingBlackCols = length( leadingBlackCols );

maskedSmearRows   = cbdObj.maskedSmearRows;
numMaskedSmearRows = length( maskedSmearRows );

virtualSmearRows   = cbdObj.virtualSmearRows;
numVirtualSmearRows = length( virtualSmearRows );

% pre-allocate memory for collateral columns and rows fitting
cbdObj.trailingBlackPolyFit = make_weighted_poly(1, polyFitOrder, numTrailingBlackCols);
cbdObj.leadingBlackPolyFit = make_weighted_poly(1, polyFitOrder, numLeadingBlackCols);
cbdObj.maskedSmearPolyFit = make_weighted_poly(1, polyFitOrder, numMaskedSmearRows);
cbdObj.virtualSmearPolyFit = make_weighted_poly(1, polyFitOrder, numVirtualSmearRows);

% pre-allocate memory for collateral columns and rows fitting residuals
cbdObj.residualTrailingBlack    = single( zeros(rows, numTrailingBlackCols) );
cbdObj.residualLeadingBlack     = single( zeros(rows, numLeadingBlackCols) );
cbdObj.residualMaskedSmear      = single( zeros(numMaskedSmearRows, cols) );
cbdObj.residualVirtualSmear     = single( zeros(numVirtualSmearRows, cols) );

if ( cbdObj.debugStatus )
    fprintf('polyfit_collateral(): polynominal order %d\n', polyFitOrder);
    fprintf(' TrailingBlack(%2d cols); LeadingBlack(%2d cols); MaskedSmearRows(%2d rows); VirtualSmearRows(%2d rows)\n', ...
        numTrailingBlackCols, numLeadingBlackCols, numMaskedSmearRows, numVirtualSmearRows);
end



for iCol=1:numTrailingBlackCols
    currentCol = differenceBlack(:, trailingBlackCols(iCol));

    % fit each column a high order polynominal
    polyFitStruct = robust_polyfit((1:rows)', currentCol, 1, polyFitOrder, polyFitIter, polyFitCutoff);

    polyFitResidual = currentCol - weighted_polyval([1:rows]', polyFitStruct);

    cbdObj.trailingBlackPolyFit(iCol) = polyFitStruct;

    cbdObj.residualTrailingBlack(:, iCol) = polyFitResidual;
end

% extract the data section
temp = cbdObj.residualTrailingBlack(:);
[h, prob, muhat, sighat] = compute_norm_significance( temp );
cbdObj.differenceSignificanceTrailingBlack = prob;
if ( cbdObj.debugStatus )
    fprintf(' trailingBlack, residual h = %1d; prob = %f; muhat = %f; sighat=%f\n', ...
        h, prob, muhat, sighat);
end

for iCol=1:numLeadingBlackCols
    currentCol = differenceBlack(:, leadingBlackCols(iCol));

    % fit each column a high order polynominal
    polyFitStruct = robust_polyfit((1:rows)', currentCol, 1, polyFitOrder, polyFitIter, polyFitCutoff);

    polyFitResidual = currentCol - weighted_polyval([1:rows]', polyFitStruct);

    cbdObj.leadingBlackPolyFit(iCol) = polyFitStruct;

    cbdObj.residualLeadingBlack(:, iCol) = polyFitResidual;
end

% extract the data section
temp = cbdObj.residualLeadingBlack(:);
[h, prob, muhat, sighat] = compute_norm_significance( temp );
cbdObj.differenceSignificanceLeadingBlack = prob;
if ( cbdObj.debugStatus )
    fprintf(' leadingBlack, residual h = %1d; prob = %f; muhat = %f; sighat=%f\n', ...
        h, prob, muhat, sighat);
end

for iRow=1:numMaskedSmearRows
    currentRow = differenceBlack(maskedSmearRows(iRow), :)';

    % fit each column a high order polynominal
    polyFitStruct = robust_polyfit((1:cols)', currentRow, 1, polyFitOrder, polyFitIter, polyFitCutoff);

    polyFitResidual = currentRow - weighted_polyval([1:cols]', polyFitStruct);

    cbdObj.maskedSmearPolyFit(iRow) = polyFitStruct;
    cbdObj.residualMaskedSmear(iRow, :) = polyFitResidual;   
end

% extract the data section
temp = cbdObj.residualMaskedSmear(:);
[h, prob, muhat, sighat] = compute_norm_significance( temp );
cbdObj.differenceSignificanceMaskedSmear = prob;
if ( cbdObj.debugStatus )
    fprintf(' maskedSmear, residual h = %1d; prob = %f; muhat = %f; sighat=%f\n', ...
        h, prob, muhat, sighat);
end

for iRow=1:numVirtualSmearRows
    currentRow = differenceBlack(virtualSmearRows(iRow), :)';

    % fit each column a high order polynominal
    polyFitStruct = robust_polyfit([1:cols]', currentRow, 1, polyFitOrder, polyFitIter, polyFitCutoff);

    polyFitResidual = currentRow - weighted_polyval([1:cols]', polyFitStruct);

    cbdObj.virtualSmearPolyFit(iRow) = polyFitStruct;
    
    cbdObj.residualVirtualSmear(iRow, :) = polyFitResidual;     
end

% extract the data section
temp = cbdObj.residualVirtualSmear(:);
[h, prob, muhat, sighat] = compute_norm_significance( temp );
cbdObj.differenceSignificanceVirtualSmear = prob;
if ( cbdObj.debugStatus )
    fprintf(' virtualSmear, residual h = %1d; prob = %f; muhat = %f; sighat=%f\n', ...
        h, prob, muhat, sighat);
end


return;
