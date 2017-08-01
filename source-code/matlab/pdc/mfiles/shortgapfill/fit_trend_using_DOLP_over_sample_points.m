%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [fittedTrendForAllTimeSteps, fittedPolyOrder, fittedPolyCoefficients, basisWts,legendreBasis ] = ...
%     fit_trend_using_DOLP_over_sample_points(nAllTimeSteps, indexOfAvailable, timeSeriesForIndexOfAvailable,  maxDetrendPolyOrder)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Description:
%       This function fits the the given time series, which contains gaps,
%       (oconsider it unevenly sampled) with the best trend (in the sense
%       of tightest confidence interval) using discrete orthonormal
%       Legendre polynomials. These polynomials obey a particular
%       orthogonality condition suggested by Minerbo and Levy - the
%       ocndition being that the polynomials be orthogonal over the
%       measurement abscissas.
%
% Inputs:
%       1. nAllTimeSteps  - xaxis values or time instants over which the
%          trend is needed, longer than 'indexOfAvailable'
%       2. indexOfAvailable - xaxis values (abscissas) for which the measurements
%          are available
%       3. timeSeriesForIndexOfAvailable - a vector measurements over 'indexOfAvailable',
%          same length as 'indexOfAvailable'
%       4. maxDetrendPolyOrder - maximum polynomial order to be tried while
%          fitting a trend
%
% Outputs:
%       1. fittedTrendForAllTimeSteps - trend evaluated for all time steps including gaps
%       2. fittedPolyOrder - order of the best fit polynomial order
%       3. fittedPolyCoefficients - polynomial coefficients for the best
%          fit polynomial
%       4. basisWts - weights for discrete Legendre orthonormal basis
%       5. legendreBasis - orthonormal legendre basis vectors which are
%          orthonormal over 'indexOfAvailable'
%
% References:
%      [1]  J. Jenkins, 'Variations in the 13 cm Opacity below the Main Cloud
%           layer in the Atmosphere of Venus Inferred from Pioneer-Venus radio
%           Occultation Studies 1978-1987', Ph.D. Thesis, Georgia Inst. of
%           Technology, 1992, pages 75-82.
%      [2]  Milton Abramowitz and Irene A. Stegun, 'Handbook of
%           Mathematical Functions With Formulas, Graphs, and Mathematical
%           Tables', Dover Publications, Inc., NY, 1972.
%
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

function [fittedTrendForAllTimeSteps, fittedPolyOrder, fittedPolyCoefficients,  basisWts,legendreBasis ] = ...
    fit_trend_using_DOLP_over_sample_points(nAllTimeSteps, indexOfAvailable, timeSeriesForIndexOfAvailable,  maxDetrendPolyOrder)


maxDetrendPolyOrder = min(maxDetrendPolyOrder, length(indexOfAvailable)-1);


% do not worry about this hard coded constant - it merely denotes the
% significance level at which we are estimating our confidence interval (1
% -.05 = .95 or 95% confidence) This value should not have much influence
% on how we arrive at the best polynomial order or fit
alphaSignificanceValue = .05;


nLength = length(indexOfAvailable);

legendreCoeffts = zeros(maxDetrendPolyOrder,maxDetrendPolyOrder);

alpha = zeros(maxDetrendPolyOrder,1);
beta = zeros(maxDetrendPolyOrder,1);
innerProductOfLegendreBasis = alpha;

basisWts = zeros(maxDetrendPolyOrder,1);
orthonormalBasisWts = zeros(maxDetrendPolyOrder,1);

legendreBasis = zeros(nLength,maxDetrendPolyOrder);
orthonormalLegendreBasis = zeros(nLength,maxDetrendPolyOrder);
fittedTrend = zeros(nLength,maxDetrendPolyOrder);

% coordinate transformations
beginTimeStep = indexOfAvailable(1);
endTimeStep = indexOfAvailable(nLength);
scaledTimeSteps = (indexOfAvailable-(beginTimeStep+endTimeStep)/2)/((endTimeStep-beginTimeStep)/2);


% orthonormalize legendre poynomial basis functions, absorb into basisWts
confidenceInterval = zeros(maxDetrendPolyOrder,1);
polynomialCoefficients = zeros(maxDetrendPolyOrder,maxDetrendPolyOrder);

% now use recursion to build higher order poly
E = 0;
k=0;

while (k < maxDetrendPolyOrder)

    k = k+1;

    switch k
        case 1

            legendreCoeffts(maxDetrendPolyOrder,k) = 1;
            legendreBasis(:,k) =  1;
            innerProductOfLegendreBasis(k) = legendreBasis(:,k)'*legendreBasis(:,k);
            beta(k) = 0;
            alpha(k) = legendreBasis(:,k)'*(scaledTimeSteps.*legendreBasis(:,k))/innerProductOfLegendreBasis(k);
            basisWts(k) = ( legendreBasis(:,k)'*timeSeriesForIndexOfAvailable )/innerProductOfLegendreBasis(k);

        case 2

            legendreCoeffts(:,k) = circshift(legendreCoeffts(:,k-1), -1) - alpha(k-1)*legendreCoeffts(:,k-1);

        otherwise

            legendreCoeffts(:,k) = circshift(legendreCoeffts(:,k-1), -1) - ...
                alpha(k-1)*legendreCoeffts(:,k-1) -  beta(k-1)*legendreCoeffts(:,k-2);

    end

    legendreBasis(:,k) = polyval(legendreCoeffts(:,k),scaledTimeSteps);

    innerProductOfLegendreBasis(k) = legendreBasis(:,k)'*legendreBasis(:,k);

    if (k > 1)
        beta(k) = innerProductOfLegendreBasis(k)/innerProductOfLegendreBasis(k-1);
    end

    alpha(k) = legendreBasis(:,k)'*(scaledTimeSteps.*legendreBasis(:,k))/innerProductOfLegendreBasis(k);

    basisWts(k) = dot(legendreBasis(:,k), timeSeriesForIndexOfAvailable)*(1/innerProductOfLegendreBasis(k));


    flipLegendreCoeffts = flipud(legendreCoeffts);

    polynomialCoefficients(1:k,k) = (flipLegendreCoeffts(1:k,1:k))*basisWts(1:k);

    orthonormalBasisWts(k) = basisWts(k)*norm(legendreBasis(:,k));

    orthonormalLegendreBasis(:,k) = legendreBasis(:,k)/norm(legendreBasis(:,k));

    fittedTrend(:,k) = orthonormalLegendreBasis(:,1:k)*orthonormalBasisWts(1:k);

    residualsAfterFit = timeSeriesForIndexOfAvailable - fittedTrend(:,k);

    % compute deltas and confidence values for each fit order

    degressOfFreedom = nLength - k;

    % S is a structure containing three elements: the triangular factor of
    % the Vandermonde matrix for the original X, the degrees of freedom,
    % and the norm of the residuals. Part of this code extracted from
    % 'polyconf' but modified to take advantage of the orthonormal basis
    % while computing E

    % ==========================================
    % See atatched note at the end of this script
    % ==========================================

    E = E + orthonormalLegendreBasis(:,k)*orthonormalLegendreBasis(:,k)'; % similar to    E = V/R;

    e = sqrt(1+sum(E.*E,2));
    if degressOfFreedom == 0
        warning('MATLAB:polyval:ZeroDOF',['Zero degrees of freedom implies ' ...
            'infinite error bounds.']);
        delta = repmat(Inf,size(e));
    else
        delta = norm(residualsAfterFit)/sqrt(degressOfFreedom)*e;
    end
    predictionVariance = delta;                % variance for predicting observation

    % What is the 95th percentile of the t distribution for degressOfFreedom?
    criticalValue = tinv(1-alphaSignificanceValue/2,degressOfFreedom);           % non-simultaneous value
    delta = criticalValue * predictionVariance;


    %   DELTA is an  estimate of the standard deviation of the error in
    %   predicting a future observation at X by P(X).
    %
    %   If the coefficients in P are least squares estimates computed by
    %   POLYFIT, and the errors in the data input to POLYFIT are independent,
    %   normal, with constant variance, then Y +/- DELTA will contain at least
    %   95% of future observations at X.

    confidenceInterval(k) = mean(delta);

    fittedPolyOrder = find(diff(confidenceInterval) > 0,1,'first');
    if(~isempty(fittedPolyOrder))
        break;
    end;


end
if(isempty(fittedPolyOrder))

    [bestConfidenceInterval, fittedPolyOrder] = min(confidenceInterval);

end



% coordinate transformations
beginTimeStep = nAllTimeSteps(1);
endTimeStep = nAllTimeSteps(end);
scaledAllTimeSteps = (nAllTimeSteps-(beginTimeStep+endTimeStep)/2)/((endTimeStep-beginTimeStep)/2);

fittedPolyCoefficients = flipud(polynomialCoefficients(1:fittedPolyOrder,fittedPolyOrder));
fittedTrendForAllTimeSteps = polyval(flipud(polynomialCoefficients(1:fittedPolyOrder,fittedPolyOrder)),scaledAllTimeSteps);


% if NaNs are detected, then simply return the oth order polynomial fit
if(any(isnan(fittedTrendForAllTimeSteps)))
    fittedPolyOrder = 0;
    [fittedPolyCoefficients, structureS, scalingCenteringMu] = polyfit(indexOfAvailable, timeSeriesForIndexOfAvailable, fittedPolyOrder);
    [fittedTrendForAllTimeSteps] = polyconf(fittedPolyCoefficients,nAllTimeSteps, structureS, 'mu', scalingCenteringMu, 'alpha', .05);

end

% if(any(isnan(fittedTrendForAllTimeSteps)))
%     fprintf('NaNs...\n')
% end

return


%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% excerpts from Jon's email on 5/16/2007
% how to compute confidence interval for discrete orthonormal Legendre poly
% fit?
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Polyval and polyconf are applying the standard propagation of errors to
% combine the observation noise with the errors in the fit at each point.
%
%
% Let V be the Van der Monde (sp?) matrix (design matrix). Then let V = QR
% be the QR decomposition of V.
%
% We have Q'*Q = I (the identity matrix).
%
% Solving for the coefficients c in terms of the data y: c = V\y = R\Q'*y
% by noting that (A'*A)\(A'*y) = (R'*R)\R'*(Q'*y) = R\Q'*y
%
% In the standard propagation of errors, the covariance matrix for the
% coefficients is
%
% inv(V'*V) = inv((Q*R)'*(Q*R)) = inv(R'*Q'*Q*R) = inv(R'*R)
%
% Propagating the errors through to the polynomial samples for the same
% locations would be
%
% yhat = V*c = V*[(V'*V)^-1*V'*y]
%
% So Cyhat = [V*inv(V'*V)*V']*Cy*[V*inv(V'*V)*V']'
%
% If Cy = sigy2*I then (where sigy2 is the variance of the data)
%
% Cyhat = sigy2*V*inv(R'*R)*V'*V*inv(R'*R)*V' (substituting R'*R for V'*V)
% = sigy2*V*inv(R'*R)*R'*R*inv(R'*R)*V' = sigy2*V*inv(R'*R)*V'
%
% If we are only interested in the expected variances then we can define E
% = V/R, and sum(E.*E,2) represent the variances for each sample point
% (predicted y value). You can verify that E*E' = V*inv(R'*R)*V'. (Some
% magic of the '/' and '\' notation in MATLAB).
%
% The rest of the story is that sqrt(1+sum(E.*E,2)) is the RSS of the
% observation noise + the uncertainty in the fitted value. The residuals
% from the fit says something about the observational noise, and the
% degrees of freedom can be used with Student's t-distribution to estimate
% the slop needed to predict the confidence interval for the prediction,
% since we are estimating the mean and the standard deviation from the
% observations (see the wikipedia entry for Students t-distribution).
%
% This is pretty slick and we can apply it to the results from the
% othogonal polynomials as here we have (once we make them orthonormal!!!)
%
% c = U'*y where the columns of U are the polynomial values on the
% abscissas x.
%
% So Cc = U'*Cy*U = sigy2*U'*U
%
% and Cyhat = U*Cc*U' = sigy2*U*U'*U*U' and we can use sigyhat2 =
% sigy2*sum((U*U').^2,2) similar to the sum((V/R).^2,2).
%
% Everything else is the same with respect to degrees of freedom and
% rrs'ing the observational noise, and we ought to be able to make it
% shorter since we aren't inverting the R matrix.
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


