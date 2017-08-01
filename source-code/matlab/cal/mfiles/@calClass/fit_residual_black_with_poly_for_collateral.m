function [calObject, calIntermediateStruct, calTransformStruct] = ...
    fit_residual_black_with_poly_for_collateral(calObject, calIntermediateStruct, cadenceIndex, calTransformStruct)
% function [calObject, calIntermediateStruct, calTransformStruct] = ...
%     fit_residual_black_with_poly_for_collateral(calObject, calIntermediateStruct, cadenceIndex, calTransformStruct)
%
% function to compute the black level correction (a 1D array) for the input cadence.
% A polynomial is fit to the black residual pixels (the 2D black subtracted
% black pixels) to obtain this correction.  The Akaike information criterion
% (AIC) is used to decide on the best polynomial order for the fit.  A
% robust fit is first used to protect from outliers, and a least squares
% with known covariance method is used with the design matrix of best
% polynomial order.  The output from this function is the black correction
% (1 value per row per cadence) used to correct all other pixel types for
% black, along with propagated uncertainties, the mean black and mean black
% uncertainties used to compute metrics.
%
% The black correction is the length of the ccd rows with gaps where there
% are no pixel values.  Short cadence masked and virtual black pixel values
% (which have no row or column) are embedded in the black correction at the
% mean row from which they were originally summed.
%
%--------------------------------------------------------------------------
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


pouEnabled = calObject.pouModuleParametersStruct.pouEnabled;

if pouEnabled
    % copy calTransformStruct into shorter temporary structure
    tStruct = calTransformStruct(:,cadenceIndex);
else
    tStruct = []; 
end


% extract flags to determine if long or short cadence pixels are to be processed
% In either case,
processLongCadence  = calObject.dataFlags.processLongCadence;
processShortCadence = calObject.dataFlags.processShortCadence;
processFFI          = calObject.dataFlags.processFFI;                                                     %#ok<NASGU>

% extract number of cadences
nCadences   = calIntermediateStruct.nCadences;

% logical flags for availability of black collateral pixels:
isAvailableMaskedBlackPix   = calIntermediateStruct.dataFlags.isAvailableMaskedBlackPix;
isAvailableVirtualBlackPix  = calIntermediateStruct.dataFlags.isAvailableVirtualBlackPix;

% find valid (2D black) corrected pixels for this cadence for polynomial fit
blackPixelValues = calIntermediateStruct.blackPixels(:, cadenceIndex); % nCcdRows x 1
blackPixelGaps   = calIntermediateStruct.blackGaps(:, cadenceIndex);   % nCcdRows x 1


% temporarily update black gap indicators to neglect charge injection rows
% and also frame transfer rows for the 1D black fit.  Save information in
% newBlackGaps array
if processLongCadence

    blackPixelGaps(calIntermediateStruct.blackRowsToExcludeInFit) = true;
    
%     % save charge injection rows for plots
%     calIntermediateStruct.blackRowsToExcludeInFit = blackRowsToExcludeInFit;
end


% find valid (2D black) corrected masked/virtual black pixels for this cadence
if processShortCadence

    % get smear rows that were summed onboard spacecraft to find the mean
    % value, which will be the 'row' of the masked or virtual black pixel
    mSmearRowStart   = calIntermediateStruct.mSmearRowStart;
    mSmearRowEnd     = calIntermediateStruct.mSmearRowEnd;
    vSmearRowStart   = calIntermediateStruct.vSmearRowStart;
    vSmearRowEnd     = calIntermediateStruct.vSmearRowEnd;

    if numel(mSmearRowStart) > 1 && numel(mSmearRowEnd) > 1
        mSmearRows = mSmearRowStart(cadenceIndex):mSmearRowEnd(cadenceIndex);
    else
        mSmearRows = mSmearRowStart:mSmearRowEnd;
    end

    if numel(vSmearRowStart) > 1 && numel(vSmearRowEnd) > 1
        vSmearRows = vSmearRowStart(cadenceIndex):vSmearRowEnd(cadenceIndex);
    else
        vSmearRows = vSmearRowStart:vSmearRowEnd;
    end


    if isAvailableMaskedBlackPix
        mBlackPixelValue = calIntermediateStruct.mBlackPixels(cadenceIndex); % mBlackPixels is nCadences x 1
        mBlackPixelGap = calIntermediateStruct.mBlackGaps(cadenceIndex);     % mBlackGaps is nCadences x 1

        maskedBlackRow  = round(mean(mSmearRows));

        % update black pixel vectors to include masked black pixel value
        blackPixelValues(maskedBlackRow) = mBlackPixelValue;
        blackPixelGaps(maskedBlackRow)   = mBlackPixelGap;
    end

    if isAvailableVirtualBlackPix
        vBlackPixelValue = calIntermediateStruct.vBlackPixels(cadenceIndex); % vBlackPixels is nCadences x 1
        vBlackPixelGap = calIntermediateStruct.vBlackGaps(cadenceIndex);     % vBlackGaps is nCadences x 1

        virtualBlackRow = round(mean(vSmearRows));

        % update black pixel vectors to include virtual black pixel value
        blackPixelValues(virtualBlackRow) = vBlackPixelValue;
        blackPixelGaps(virtualBlackRow)   = vBlackPixelGap;
    end
end

validBlackPixelIndices  = find(~blackPixelGaps);                        % may be < (nPixels x 1)
availableBlackPix       = blackPixelValues(validBlackPixelIndices);
nAvailableBlackPixels   = length(availableBlackPix);

ccdRows     = 1:calObject.fcConstants.CCD_ROWS;
numCcdRows  = length(ccdRows);

% list all valid rows where black correction will be needed.  If we knew where
% all the target and background pixels were going to be we could calculate the
% black correction only at those indices, but we don't have that info in the
% collateral invocation. For now we will save all rows. Consider rebuilding
% the black correction to get that info on the fly from the saved design matrix
% and fit coefficients.
%
% validRowIndices = unique( [validBlackPixelIndices(:)', mSmearRows(:)', vSmearRows(:)']' );
validRowIndices = ccdRows;

% extract max polynomial order
blackPolyOrderMax   = calObject.moduleParametersStruct.polyOrderMax;

% restrict the polynomial order to avoid testing polynomial order > number of samples available
blackPolyOrderMax   = min(blackPolyOrderMax, nAvailableBlackPixels - 1);

AIC = zeros(blackPolyOrderMax + 1, 1);


% pre allocate memory to hold black fitted values for all rows
if cadenceIndex == 1
    calIntermediateStruct.blackCorrection = zeros(length(ccdRows), nCadences);
end

% no weights, but a simple normalized design matrix (nCcdRows x blackPolyOrderMax+1)
A = repmat(ccdRows(:)/numCcdRows, 1, blackPolyOrderMax+1).^repmat(0:blackPolyOrderMax,numCcdRows,1);        % 1070 x 11

% if there are no valid black pixels, set values to -1
if isempty(validBlackPixelIndices)

    calIntermediateStruct.blackAvailable(cadenceIndex)                              = false;
    calIntermediateStruct.blackCorrection(validRowIndices, cadenceIndex)            = -1;
%     calIntermediateStruct.meanBlack(cadenceIndex)                                   = -1;
%     calIntermediateStruct.meanBlackUncertainties(cadenceIndex)                      = -1;    
    

    if(pouEnabled)
        tStruct = insert_POU_cadence_gaps(tStruct,{'fittedBlack'});
    else
        calIntermediateStruct.blackUncertaintyStruct(cadenceIndex).bestBlackPolyOrder   = -1;
        calIntermediateStruct.blackUncertaintyStruct(cadenceIndex).CblackPolyFit        = [];
        calIntermediateStruct.blackUncertaintyStruct(cadenceIndex).bestPolyCoeffts      = [];
    end

else
    bestBlackPolyOrder = 0;
    minAIC = 1e16;
    for jPolyOrder = 0:blackPolyOrderMax

        % break out of loop if warning is given:
        lastwarn('');

        warning off all
        % perform robust fit.  By default, ROBUSTFIT adds a column of ones to X
        [robustPolyCoeffts, stats] = robustfit(A(validBlackPixelIndices, 2:jPolyOrder+1), full(availableBlackPix));
        warning on all

        % extract final estimate of sigma, the larger of robust_s and a weighted
        % average of ols_s and robust_s, where stats.ols_s is the sigma estimate
        % (rmse) from least squares fit, and stats.robust_s is the robust estimate of sigma
        robustSigma = stats.s;

        msgstr = lastwarn;
        if(~isempty(msgstr))
            AIC = AIC(1:jPolyOrder - 1);

            if (isempty(AIC))
                AIC = 0; %#ok<NASGU>
            end
            break;
        end

        K = length(robustPolyCoeffts);
        n = length(validBlackPixelIndices);

        AIC(jPolyOrder+1) = 2*K + n*log(robustSigma) + 2*K*(K + 1)/(n - K - 1);

        % update bestBlackPolyOrder
        if AIC(jPolyOrder+1)<minAIC
            minAIC = AIC(jPolyOrder+1);
            bestBlackPolyOrder = jPolyOrder;
        end

        % Break out of loop if AIC fails to decrease after two attempts
        % past current minimum
        if jPolyOrder >= bestBlackPolyOrder+2
            break
        end

    end

    %----------------------------------------------------------------------
    % find best polynomial order
    %----------------------------------------------------------------------
    AbestPoly = A(:, 1:bestBlackPolyOrder+1);

    %----------------------------------------------------------------------
    % perform robust fit again to get weights associated with best black polynomial order
    %----------------------------------------------------------------------
    warning off all
    [robustPolyCoeffts, stats] = robustfit(A(validBlackPixelIndices, 2:bestBlackPolyOrder+1), full(availableBlackPix));                     %#ok<*ASGLU>
    warning on all

    %----------------------------------------------------------------------
    % evaluate polynomial for all rows  to get black correction
    %----------------------------------------------------------------------

    % extract weights from robust fit;  w typically contains either counts or inverse variances.
    robustWeightsBestPoly = sqrt(stats.w);                                 % nValidPixels x 1

    % scale design matrix with robust weights for lscov fit
    ArobustBestPoly = scalecol(robustWeightsBestPoly, AbestPoly(validBlackPixelIndices,:)); % nValidPixels x 1

    % scale available black pixels with robust weights for lscov fit
    bRobustBestPoly = robustWeightsBestPoly .* availableBlackPix;       % nValidPixels x 1

    % get 2D black covariance matrix for this cadence for input into lscov
    Cblack2D = get_Cblack2D(calObject, calIntermediateStruct, cadenceIndex, tStruct);

    robustWeightsFullCcdRowArray = zeros(numCcdRows, 1);                            % nCcdRows x 1
    robustWeightsFullCcdRowArray(validBlackPixelIndices) = robustWeightsBestPoly;   % nCcdRows x 1

    % scale Cblack2D with robust weights for lscov fit
    CrobustBestPoly = diag(robustWeightsFullCcdRowArray.^2.*diag(Cblack2D));        % nCcdRows x nCcdRows
    clear Cblack2D;

    % ignore zero-weighted data for lscov
    validWeights    = find(robustWeightsBestPoly > 0);
    ArobustBestPoly = ArobustBestPoly(validWeights,:);
    bRobustBestPoly = bRobustBestPoly(validWeights);

    validWeightsFullCcdRowsArray = find(robustWeightsFullCcdRowArray > 0);
    CrobustBestPoly = CrobustBestPoly(validWeightsFullCcdRowsArray, validWeightsFullCcdRowsArray);


    %----------------------------------------------------------------------
    % compute least squares with known covariance using design matrix with best polynomial order
    %----------------------------------------------------------------------
    [polyCoeffts, std, mse, CblackPolyFit] = lscov(ArobustBestPoly, bRobustBestPoly, 1./diag(CrobustBestPoly));

    clear CrobustBestPoly;

    % calculate cov matrix of uncertainties in the fitted values.  The covariance
    % matrix for CblackPolyFit is known, so internal (to lscov) scaling is unnecessary:
    % rescale CblackPolyFit by 1/mse (and stdx by sqrt(1/mse))
    CblackPolyFit   = CblackPolyFit ./ mse;

    %----------------------------------------------------------------------
    % calculate cov matrix for black fit
%     CblackFitted  = AbestPoly(validRowIndices,:) * CblackPolyFit * AbestPoly(validRowIndices,:)';

    % evaluate the best polynomial for all valid rows
    blackCorrection = AbestPoly(validRowIndices,:) * polyCoeffts;

    % calculate mean black level and uncertainty for valid pixels only
%     nValidPixels = length(validBlackPixelIndices);
%     calIntermediateStruct.meanBlack(cadenceIndex) = ...
        mean(blackCorrection(validBlackPixelIndices));
%     calIntermediateStruct.meanBlackUncertainties(cadenceIndex) = ...
%         (1/nValidPixels) * sqrt(sum(sum(CblackFitted(validBlackPixelIndices,validBlackPixelIndices))));

    clear CblackFitted;

    %----------------------------------------------------------------------
    % save fit coeffecients, order, design matrix and fitted vales for valid rows
    if ~pouEnabled
        calIntermediateStruct.blackUncertaintyStruct(cadenceIndex).bestPolyCoeffts      = polyCoeffts;
        calIntermediateStruct.blackUncertaintyStruct(cadenceIndex).CblackPolyFit        = CblackPolyFit;
        calIntermediateStruct.blackUncertaintyStruct(cadenceIndex).bestBlackPolyOrder   = bestBlackPolyOrder;
    end
    
    calIntermediateStruct.blackCorrection(validRowIndices, cadenceIndex) = blackCorrection;

    %----------------------------------------------------------------------

    if pouEnabled

        % NOTE: polyCoeffts and CblackPolyFit are ordered from lowest to
        % highest order since that is how the design matrix passed to lscov
        % was ordered. POU transform propagation (do_transformation.m)
        % expects weighted polynomial coefficients in standard MATLAB
        % format, e.g. ordered from highest to lowest order so we must
        % reverse the order of the fit coefficients and reflect the
        % covariance matrix about its center when they are passed to
        % append_transform. Use flipud and fliplr.

        pouCoeffs = flipud(polyCoeffts);
        pouCv = flipud(fliplr(CblackPolyFit));                                                                                              %#ok<*FLUDLR>

        % primitive for fitted black correction is fitted polynomial coefficients
        tStruct = append_transformation(tStruct, 'eye', 'fittedBlack', [], pouCoeffs, pouCv ,[],[],[]);

        % write xVector as a string to save space:  xVector = (ccdRows./numCcdRows)';
        xVector = ['[',num2str(ccdRows(1)),':',num2str(ccdRows(end)),']./',num2str(numCcdRows)];

        % write weight vector as a string to save space: w = ones(size(xVector));
        w = ['ones(',num2str(length(ccdRows)),',1)'];

        % apply polynomial design matix to the coeffs to get fitted black correction
        tStruct = append_transformation(tStruct, 'wPoly', 'fittedBlack', [], bestBlackPolyOrder, xVector , w );
    end
end

if pouEnabled
    % copy tStruct into calTransformStruct for return
    calTransformStruct(:,cadenceIndex) = tStruct;
end


return;
