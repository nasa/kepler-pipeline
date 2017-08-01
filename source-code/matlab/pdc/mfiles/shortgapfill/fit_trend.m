function [fittedTrend, fittedPolyOrder,polynomialCoefficients, structureS, scalingCenteringMu] = fit_trend(nTimeSteps, indexOfAvailable,  timeSeriesWithGaps,  maxDetrendPolyOrder)
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

maxDetrendPolyOrder = min(maxDetrendPolyOrder, length(indexOfAvailable)-1);

criterionAIC        = zeros(maxDetrendPolyOrder+1,1);

isBadlyConditionedR = false;

% for saturated flux time series, very low order polynomial
% detrending is inadequate; such flux time series are few but
% still need to accommodate them
% iteratively choose higher poly order by comparing moving std
% and the 95% confidence interval generated

detrendPolyOrder = 0;
previousMeanFitConfidenceInterval = 1e9;


while true

    [polynomialCoefficients, structureS, scalingCenteringMu] = polyfit(indexOfAvailable, timeSeriesWithGaps(indexOfAvailable), detrendPolyOrder);


    if(structureS.df ==0)
        % restore last results
        detrendPolyOrder = max((detrendPolyOrder - 1),0);
        [polynomialCoefficients, structureS, scalingCenteringMu] = polyfit(indexOfAvailable, timeSeriesWithGaps(indexOfAvailable), detrendPolyOrder);
        [fittedTrend] = polyconf(polynomialCoefficients,nTimeSteps, structureS, 'mu', scalingCenteringMu, 'alpha', .05);

        break;
    end


    % badly conditioned


    % Y = polyconf(P,X) returns the value of a polynomial, P, evaluated at X.
    % The polynomial P is a vector of length N+1 whose elements are the
    % coefficients of the polynomial in descending powers.[Y,DELTA] =
    % polyconf(P,X,S) uses the optional output, S, created by polyfit to
    % generate 95% prediction intervals.
    % If the coefficients in P are least squares estimates computed by polyfit,
    % and the errors in the data input to polyfit were independent, normal,
    % with constant variance, then there is a 95% probability that Y ? DELTA
    % will contain a future observation at X.


    [fittedTrend, fitConfidenceInterval] = polyconf(polynomialCoefficients,nTimeSteps, structureS, 'mu', scalingCenteringMu, 'alpha', .05);
    %fittedTrend = polyconf(polynomialCoefficients,nTimeSteps, structureS, 'mu', scalingCenteringMu, 'alpha', .05);

    %--------------------------------------------
    % AIC criterion
    %--------------------------------------------

    K = length(polynomialCoefficients);

    commonIndex = intersect(nTimeSteps, indexOfAvailable);
    n = length(commonIndex);

    %meanSquareError = mean((timeSeriesWithGaps(commonIndex) - fittedTrend(commonIndex - nTimeSteps(1) + 1)).^2);
    meanSquareError = (structureS.normr)^2/n; % same as the previous statement
    % AICc

    % when the polynomial is evaluated over nTimeSteps, it may so happen
    % that it is exatrapolated unacceptably, leading to large errors


    % so calculate mean square error differently for this case

    if((indexOfAvailable(end) < nTimeSteps(end)) ||(indexOfAvailable(1) > nTimeSteps(1))) % beware of extrapolation

        tempTimeSeries = interp1(indexOfAvailable, timeSeriesWithGaps(indexOfAvailable), nTimeSteps(:),'nearest', 'extrap');

        meanSquareError = mean((tempTimeSeries - fittedTrend).^2);

    end


    if(K ~= (n-1))
        if(meanSquareError > 0)
            if(log(meanSquareError) >= 0)
                criterionAIC(detrendPolyOrder+1) = 2*K + n*log(meanSquareError) + 2*K*(K+1)/(n-K-1);
            else
                criterionAIC(detrendPolyOrder+1) = log(n*meanSquareError) + 2*K*(K+1)/(n-K-1);
            end
        else
            criterionAIC(detrendPolyOrder+1)  = Inf;
            break;
        end
    else
        criterionAIC(detrendPolyOrder+1)  = Inf;
    end

    [mrows mcolumns] = size(structureS.R);

    if(mrows == mcolumns) % matrix is square

        if(condest(structureS.R) > 1e6)
            isBadlyConditionedR = true;
        end;

    else
        isBadlyConditionedR = true;
    end

    %if((detrendPolyOrder >= maxDetrendPolyOrder) || isBadlyConditionedR)
    if((detrendPolyOrder >= maxDetrendPolyOrder) || isBadlyConditionedR || (mean(fitConfidenceInterval) > previousMeanFitConfidenceInterval))

        if(isBadlyConditionedR)
            % restore last results
            detrendPolyOrder = detrendPolyOrder - 1;
            [polynomialCoefficients, structureS, scalingCenteringMu] = polyfit(indexOfAvailable, timeSeriesWithGaps(indexOfAvailable), detrendPolyOrder);
            [fittedTrend] = polyconf(polynomialCoefficients,nTimeSteps, structureS, 'mu', scalingCenteringMu, 'alpha', .05);
        end

        break;

    else
        detrendPolyOrder = detrendPolyOrder+1;
        previousMeanFitConfidenceInterval = mean(fitConfidenceInterval);
    end;
end;

fittedPolyOrder = detrendPolyOrder;

if(detrendPolyOrder > 0)

    criterionAIC = criterionAIC(1:detrendPolyOrder+1);
    [minAICvalue, minPolyOrderFromAIC] = min(criterionAIC);
    minPolyOrderFromAIC = minPolyOrderFromAIC -1;
    fittedPolyOrder = min(fittedPolyOrder, minPolyOrderFromAIC);

    % recompute the trend
    [polynomialCoefficients, structureS, scalingCenteringMu] = polyfit(indexOfAvailable, timeSeriesWithGaps(indexOfAvailable), fittedPolyOrder);
    [fittedTrend] = polyconf(polynomialCoefficients,nTimeSteps, structureS, 'mu', scalingCenteringMu, 'alpha', .05);

elseif(detrendPolyOrder == 0)

    [polynomialCoefficients, structureS, scalingCenteringMu] = polyfit(indexOfAvailable, timeSeriesWithGaps(indexOfAvailable), fittedPolyOrder);
    [fittedTrend] = polyconf(polynomialCoefficients,nTimeSteps, structureS, 'mu', scalingCenteringMu, 'alpha', .05);


end

% if NaNs are detected, then simply return the oth order polynomial fit
if(any(isnan(fittedTrend)))

    fittedPolyOrder = 0;
    [polynomialCoefficients, structureS, scalingCenteringMu] = polyfit(indexOfAvailable, timeSeriesWithGaps(indexOfAvailable), fittedPolyOrder);
    [fittedTrend] = polyconf(polynomialCoefficients,nTimeSteps, structureS, 'mu', scalingCenteringMu, 'alpha', .05);

end


% if(any(isnan(fittedTrend)))
%     fprintf('NaNs...\n')
% end


return;

