function [cosmicRayCorrectedPixelArray, cosmicRayEventsIndicators, ...
nMaxOrders] = clean_cosmic_rays_svd(pixelArrayToCorrect, gapArray, ...
falseRejectionRate, maxSvdOrder)
% function [cosmicRayCorrectedPixelArray, cosmicRayEventsIndicators, ...
% nMaxOrders] = clean_cosmic_rays_svd(pixelArrayToCorrect, gapArray, ...
% falseRejectionRate, maxSvdOrder)
%
% Function to clean cosmic rays from input pixel time series using svd.
% The input arrays are assumed to contain time series as columns, not rows!
% The methodology is to use svd decomposition to model the time series,
% normalize the residuals by their median absolute deviations, to look at
% the negative tail of the distribution described by the normalized
% residuals to identify the appropriate threshold given the desired input
% falseRejection rate, and then to threshold the normalized residuals.
% The process is iterated, using the cleaned time series for the svd
% decomposition in case the presence of cosmic rays significantly perturbs
% the results. The process stops when no change is noted in the pixels
% identified as being hit by cosmic rays. 
% 
% The outputs include the cleaned time series and a logical array
% indicating which pixels were identified as hit by cosmic rays. The
% outputs also include the number of best orders that were limited by the
% max SVD order parameter.
%
% INPUT
%
%   pixelArrayToCorrect (double; numCadences X numTimeSeries)
%   gapArray (logical array; numCadences X numTimeSeries)
%   falseRejectionRate (double; 0<falseRejectionRate<<1)
%
% OUTPUT
% 
%   cosmicRayCorrectedPixelArray (double; numCadences X numTimeSeries)
%   cosmicRayEventsIndicators (logical; numCadences X numTimeSeries)
%   nMaxOrders (integer)
%
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

% Hard code max SVD order for now.
MAX_SVD_ORDER = 50;

if ~exist('maxSvdOrder', 'var')
    maxSvdOrder = MAX_SVD_ORDER;
end

if falseRejectionRate < 0
    error('clean_cosmic_rays_svd: falseRejectionRate<0. Select 0<falseRejectionRate<<1.')
end

if falseRejectionRate > 1
    error('clean_cosmic_rays_svd: falseRejectionRate>1. Select 0<falseRejectionRate<<1.')
end

numCadences = size(pixelArrayToCorrect,1);

numTimeSeries = size(pixelArrayToCorrect,2);

cadences = (1:numCadences)';

% Check for missing columns in pixelArrayToCorrect: ignore these using a
% recursive call. Also terminate early if the number of available columns
% in insufficient for SVD decomposition

numNonGaps = sum(~gapArray);

if any(numNonGaps<2) || numTimeSeries<2
    
    cosmicRayCorrectedPixelArray = pixelArrayToCorrect;
    cosmicRayEventsIndicators = false(size(pixelArrayToCorrect));
    
    availableColumns = numNonGaps>1;
    nAvailableColumns = sum(availableColumns);
    
    if nAvailableColumns > 1
        [cosmicRayCorrectedPixelArray(:,availableColumns), cosmicRayEventsIndicators(:,availableColumns), nMaxOrders] = ...
            clean_cosmic_rays_svd(pixelArrayToCorrect(:,availableColumns), gapArray(:,availableColumns), ...
            falseRejectionRate, maxSvdOrder);
    else
        nMaxOrders = 0;
    end
    
    return
    
end

% Get the state of the random number generator and set the seed to
% produce consistent cosmic ray cleaning results. Note that 'svds' calls
% 'eigs', which calls 'rand'
[randState] = get_rand_state();
rand('twister', 90125);

% Fill missing elements in pixelArrayToCorrect
% Assume that the gaps are largely at the cadence level, so that nearest
% neighbor interpolation is acceptable, with nearest neighbor interpolation 
% at the edges of the time series.

for i = find(any(gapArray)&~all(gapArray))
    pixelTimeSeries = pixelArrayToCorrect(:,i);
    gaps = gapArray(:,i);
    
    % must have at least one ungapped point to do interpolation
    %if(length(find(~gaps))>1)
        pixelArrayToCorrect(gaps,i) = ...
            interp1(cadences(~gaps), pixelTimeSeries(~gaps), cadences(gaps),'near','extrap');
    %end
end

cosmicRayCorrectedPixelArray = pixelArrayToCorrect;

oldCosmicRayEventsIndicators = zeros(size(pixelArrayToCorrect));

loopCount = 0;

while 1

    loopCount = loopCount + 1;
    
    %% perform svd decomposition of array
    % use current cosmicRayCorrectedPixelArray
    [U, S, V] = svds(full(cosmicRayCorrectedPixelArray), maxSvdOrder);                   %#ok<NASGU>

    %%
    sigma = sqrt(mean(pixelArrayToCorrect).^2);
    AIC = numCadences*log(sigma);

    %% Use Akaike's Information Criterion to model individual time series with
    % singular components
    pixelArrayModel = zeros(size(pixelArrayToCorrect));
    pixelArrayResidual = pixelArrayToCorrect;

    timeSeriesLeft = (1:numTimeSeries)';

    bestOrder = zeros(numTimeSeries,1);

    k = 0;

    
    while ~isempty(timeSeriesLeft)
    
        k = k + 1;

        [pixelArrayModel(:,timeSeriesLeft), pixelArrayResidual(:,timeSeriesLeft), AIC(timeSeriesLeft), keepGoingIndicator] = ...
            try_one_more_term(pixelArrayModel(:,timeSeriesLeft), pixelArrayResidual(:,timeSeriesLeft), AIC(timeSeriesLeft), U, k);

        timeSeriesLeft = timeSeriesLeft(keepGoingIndicator);
        bestOrder(timeSeriesLeft) = k;

        if k >= numCadences - 2 || k >= size(U,2)-2, % too many parameters for number of data points!
            break, 
        end
        
    end

    % compute the number of times that the best order is limited by the max
    % SVD order parameter.
    nMaxOrders = sum(bestOrder >= maxSvdOrder-2);
    
    % take median absolute deviation as a robust standard deviation
    madPixelArrayResidual = mad(pixelArrayResidual); 

    % replace any 0s with 1s
    madPixelArrayResidual(madPixelArrayResidual==0) = 1;

    % normalize by the mad
    pixelArrayResidualNormalized = pixelArrayResidual.*repmat(1./madPixelArrayResidual,numCadences,1);

    % determine the threshold from the negative tail of the distribution of the
    % normalized pixel residuals
    sampleCumulativeDistribution = sort(pixelArrayResidualNormalized(:));
    crThreshold = -sampleCumulativeDistribution(ceil(falseRejectionRate*numCadences*numTimeSeries));

    % Threshold normalized residuals
    cosmicRayEventsIndicators = (pixelArrayResidualNormalized > crThreshold) & (pixelArrayToCorrect > pixelArrayModel);

    % Reset cosmic ray corrected pixel array and update with latest events
    cosmicRayCorrectedPixelArray = pixelArrayToCorrect;
    cosmicRayCorrectedPixelArray(cosmicRayEventsIndicators) = pixelArrayModel(cosmicRayEventsIndicators);

    if isequal(cosmicRayEventsIndicators,oldCosmicRayEventsIndicators)
        break
    end

    % Only allow one clean up pass for the svd computations
    if loopCount == 2
        break
    end
    
    oldCosmicRayEventsIndicators = cosmicRayEventsIndicators;

end

% Gap cosmicRayCorrected data
cosmicRayCorrectedPixelArray(gapArray~=0) = 0;
cosmicRayEventsIndicators(gapArray~=0) = false;

% Restore the random number state
set_rand_state(randState);

return

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [pixelArrayModel, pixelArrayResidual, newAIC, keepGoingIndicator] = ...
    try_one_more_term(pixelArrayModel, pixelArrayResidual, AIC, U, k)

numCadences = size(pixelArrayModel,1);

newModelTerm = U(:,k)*( U(:,k)'*pixelArrayResidual );
    
newSigma = sqrt(mean( (pixelArrayResidual - newModelTerm).^2 ));
    
newAIC = 2*k + numCadences*log(newSigma) + 2*k*(k + 1)/(numCadences - k - 1);

keepGoingIndicator = newAIC<AIC;

pixelArrayModel(:,keepGoingIndicator) = pixelArrayModel(:,keepGoingIndicator) + ...
    newModelTerm(:,keepGoingIndicator);

pixelArrayResidual(:,keepGoingIndicator) = pixelArrayResidual(:,keepGoingIndicator) - ...
    newModelTerm(:,keepGoingIndicator);

AIC(keepGoingIndicator) = newAIC(keepGoingIndicator);

return
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

