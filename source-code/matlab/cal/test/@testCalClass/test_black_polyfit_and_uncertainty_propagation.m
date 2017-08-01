function black_polyfit_test_results = test_black_polyfit_and_uncertainty_propagation
%
% function self = test_black_correction(self)
%--------------------------------------------------------------------------
% test_black_correction checks the degree to which the best model order was
% chosen in fitting the residual black, and whether the proper coefficients
% were used in propagating the uncertainties
%
%  Example
%  =======
%  Use a test runner to run the test method:
%         Example: run(text_test_runner, testCalCollateralClass('test_black_correction'));
%
% Read in input structure
% Input: A data structure 'calCollateralTmpStruct' is loaded internally
%
% MATLAB script generate_cal_collateral_input_data_etem2 creates this structure
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

% set cadence index for test
cadenceIndex = 1;

% load tmp struct for this test:
load tmp_standard calCollateralTmpStruct
s = calCollateralTmpStruct;

% clear collected fields
s.blackUncertaintyStruct(cadenceIndex) = [];
s.AbestPoly = [];
s.monteCarloC = [];

% for j = 1: nCadences
% cadenceIndex = j

% threshold value (number of sigmas) to compare monte carlo Cc with expected Cc 
sigmaThresh  = 3;

s = calCollateralTmpStruct;
debugFlag = s.debugFlag;

validBlackPixelIndices = find(~s.blackGapIndicators(cadenceIndex, :));     % from 1 x 1070 array

availableBlackRows      =  s.blackRows(validBlackPixelIndices);
availableBlackPixels    =  s.blackPixels(cadenceIndex, validBlackPixelIndices);
nAvailableBlackPixels   = length(availableBlackPixels);

%--------------------------------------------------------------------------
% create design matrix with fixed order
% x = (1:1070)';
% AnormFixed = [ones(1070,1), x/1070, (x/1070).^2, (x/1070).^3];  %4th order

% restrict the polynomial order as otherwise we will be testing polynomial order  > number of samples available
blackPolyOrderMax = min(s.blackPolyOrderMax, nAvailableBlackPixels - 1);

%--------------------------------------------------------------------------
nRealizations = 500; % use >1000 for monte carlo
%--------------------------------------------------------------------------

% preallocate empirical covariance matrix
% coefftsEmpirical = zeros(nRealizations, blackPolyOrderMax + 1);
%
% problem saving different length vectors in preallocated array, so create
% struct for now to collect coefficients for each realization:
coefftsEmpirical = repmat(struct('polyCoeffts', zeros(1, blackPolyOrderMax + 1)), nRealizations, 1);

% clear uncertainty struct
s.blackUncertaintyStruct = [];

for i = 1:nRealizations

%     % print i
%     i

    % choose coefficients, using a mean of ~1e5 ADU (constant term) and form the
    % availableBlackRows series via polyval using the coeffts
    if i == 1
        meanBinnedBlack = mean(s.blackPixels(cadenceIndex, :));
        meanBlack = meanBinnedBlack / length(s.binnedBlackColumns);

        p0 = meanBlack;
        p1 = .7;
        p2 = -.4;
        p3 = .1;
    end

    s.polycoefftsTruth = [p3 p2 p1 p0];

    availableBlackPixelsPoly = polyval([p3 p2 p1 p0], availableBlackRows);

    %     if (debugFlag)
    %         close all
    %         plot(availableBlackRows, availableBlackPixelsPoly, 'b')
    %     end

    % add a fresh realization of noise to black pixels
    whiteNoise = randn(size(availableBlackPixels'));
    availableBlackPixelsPoly = availableBlackPixelsPoly' + whiteNoise;

    % add some outliers
    availableBlackPixelsPoly(200) = availableBlackPixelsPoly(200)*1.1;
    availableBlackPixelsPoly(500) = (max(availableBlackPixelsPoly) - min(availableBlackPixelsPoly))*1.1;
    availableBlackPixelsPoly(700) = availableBlackPixelsPoly(700)*1.5;

    %     if (debugFlag)
    %         hold on
    %         plot(availableBlackRows, availableBlackPixelsPoly, 'r')
    %     end

    % set s.blackPixels to new pixels (for extraction in fit_resid script)
    s.blackPixels(cadenceIndex, validBlackPixelIndices) = availableBlackPixelsPoly;

    s.blackUncertaintyStruct(cadenceIndex).CblackRes = eye(length(availableBlackPixelsPoly));

    % (1) generate an empirical covariance matrix
    %    c(i,:) = AnormFixed\(s.availableBlackPixels);    % nRealizations x 4 (fixed poly order)

    % (2) generate an empirical covariance matrix from black fit, extract fitted poly coeffts
    s = fit_residual_black_with_poly_for_collateral(s, cadenceIndex);

    %-----------------------------------------------------------------------
    %  newest call to above function -- update this script!!
    [calObject, calIntermediateStruct] = ...
    fit_residual_black_with_poly_for_collateral(calObject, calIntermediateStruct, cadenceIndex);
    %-----------------------------------------------------------------------
    
    polyCoeffts   = s.blackUncertaintyStruct.bestPolyCoeffts';
    bestPolyOrder = s.blackUncertaintyStruct.bestBlackPolyOrder;
    CcTruth       = s.blackUncertaintyStruct.CcTruth;
    CcTruthScaled = s.blackUncertaintyStruct.CcTruthScaled;

    % save the coefficients
    coefftsEmpirical(i).polyCoeffts = polyCoeffts;
    coefftsEmpirical(i).bestBlackPolyOrder = bestPolyOrder;
    coefftsEmpirical(i).CcTruth = CcTruth;
    coefftsEmpirical(i).CcTruthScaled = CcTruthScaled;

    % write out poly coefficients
    polyCoeffts
    % write out input coefficients
    polyCoefftsTruth = [p0 p1 p2 p3]
    % write out expected cov
    % CcTruth
    % CcTruthScaled
end

% number of coeffts may be different for each realization; add zeros to
% make all same length for empirical cov

maxBestPolyOrder = max([coefftsEmpirical.bestBlackPolyOrder]);
minBestPolyOrder = min([coefftsEmpirical.bestBlackPolyOrder]);

if (minBestPolyOrder == maxBestPolyOrder)
    coefftsEmpiricalArray = cat(1, coefftsEmpirical.polyCoeffts);

    %--------------------------------------------------------------------------
    % empirical C from black fit
    %CcMonteCarlo = coefftsEmpiricalArray' * coefftsEmpiricalArray / nRealizations;
    %--------------------------------------------------------------------------
    % detrend empirical coeffs; works for same size coefftsEmpirical
    CcMonteCarloDetrend = detrendcols(coefftsEmpiricalArray)'*detrendcols(coefftsEmpiricalArray) / nRealizations;

    CcTruth = inv(s.AbestPoly' * s.AbestPoly);
    CcTruthScaled = inv(s.AbestPolyScaled' * s.AbestPolyScaled);

    % compare difference of (CcMonteCarloDetrend, CcTruth) with CcTruth/sqrt(nRealizations)
    CcDifference = abs(CcTruthScaled - CcMonteCarloDetrend) ./ (CcTruthScaled/sqrt(nRealizations));

    maxCcDeviation = max(max(CcDifference));

    if (maxCcDeviation > sigmaThresh)
        messageOut = 'test_black_correction - monte carlo generated cov is not consistent with expected cov!';
        assert_equals(1, 0, messageOut);
    end

    % if chosen polynomial order is not constant for all realizations:
else
    for j = 1:nRealizations
        nCoeffts = length(coefftsEmpirical(j).polyCoeffts);
        if (nCoeffts < maxBestPolyOrder + 1)

            % force coefftsEmpirical to have same number of coeffts by
            % adding zero to higher order terms
            zerosToAddToPoly = zeros(1, length(maxBestPolyOrder + 1 - nCoeffts));
            coefftsEmpirical(j).polyCoeffts = cat(2, coefftsEmpirical(j).polyCoeffts, zerosToAddToPoly);
        end
    end
    coefftsEmpiricalArray = cat(1, coefftsEmpirical.polyCoeffts);

    %--------------------------------------------------------------------------
    % can't compare different sized cov matrices & AbestPoly, so select mean
    % and compare results
    meanBestPolyOrder = round(mean([coefftsEmpirical.bestBlackPolyOrder]));

    idxMeanBestPoly = find([coefftsEmpirical.bestBlackPolyOrder]' == meanBestPolyOrder);

    wrongPolyOrderChosen = length(find([coefftsEmpirical.bestBlackPolyOrder]' ~= meanBestPolyOrder));
    percentageWrongPolyOrderChosen = wrongPolyOrderChosen / length([coefftsEmpirical.bestBlackPolyOrder]) *100;
    s.percentageWrongPolyOrderChosen = percentageWrongPolyOrderChosen;
    
    % write to screen
    fprintf(1,'Percentage of nRealizations that polynomial order (selected via AIC) is correct:  %g \n', 100 - percentageWrongPolyOrderChosen')
    
    % eliminate rows (coeffts) that deviate from mean
    coefftsEmpiricalArray = coefftsEmpiricalArray(idxMeanBestPoly, :);

    CcMonteCarloDetrend = detrendcols(coefftsEmpiricalArray)'*detrendcols(coefftsEmpiricalArray) / nRealizations;

    % CcTruth = inv(s.AbestPoly' * s.AbestPoly);
    % CcTruthScaled = inv(s.AbestPolyScaled' * s.AbestPolyScaled);
    CcTruthScaled = coefftsEmpirical(idxMeanBestPoly(1)).CcTruthScaled;
    
    % compare difference of (CcMonteCarloDetrend, CcTruth) with CcTruth/sqrt(nRealizations)
    CcDifference = abs(CcTruthScaled - CcMonteCarloDetrend) ./ (CcTruthScaled/sqrt(nRealizations));

    maxCcDeviation = max(max(CcDifference));

    if (maxCcDeviation > sigmaThresh)
        messageOut = 'test_black_correction - monte carlo generated cov is not consistent with expected cov!';
        assert_equals(1, 0, messageOut);
    end
end

%--------------------------------------------------------------------------
% save results to output Tmp structure
s.CcTruthScaled = CcTruthScaled;
s.CcMonteCarloDetrend = CcMonteCarloDetrend;
s.CcDifference = CcDifference;

% save output to tmp structure
black_polyfit_test_results = s;

% end % if looping over j loop over nCadences

save test_black_n100
return;

%--------------------------------------------------------------------------
% empirical C
% CcMonteCarlo = c' * c/nRealizations;
% CcMonteCarloDetrend = detrendcols(c)'*detrendcols(c)/nRealizations;
%--------------------------------------------------------------------------
% truth C
% Cc = inv(AnormFixed' * AnormFixed);

