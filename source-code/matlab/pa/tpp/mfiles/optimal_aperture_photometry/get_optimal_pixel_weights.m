%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
function [fluxOptimal, optimalWtsCoeffts, svdOrder] = get_optimal_pixel_weights(starPixelTimeSeries, designMatrix, gapFillParametersStruct)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Description:
%         This function computes the optimal time varying weights for the
%         pixels in the photometric aperture of a target star for all the
%         cadences (usually in an entire quarter) using the least squares
%         via SVD method. The weights are optimal in the sense that the
%         weighting of the pixels negates the long term trend introduced in
%         the flux time series due to differential velocity aberration.
%
%         Each ith pixel weight is constructed as w(i,n) =
%         C0i+C1i*dx(n)+C2i*dy(n)+C3i*dx(n)*dy(n) where n is the time
%         index.
%
%         The quadratic error function for each aperture becomes
%                i=N          j=M
%         E = Sum(Bbar - Sum(w(j,n)*pixel(n,j))).^2
%                i=1          j=1
%         where N = number of cadences, M = number of pixels in the
%         aperture, and Bbar = sum(sum(pixels)) which is the mean value of
%         the flux (obtained as a simple sum of pixel values in the
%         aperture for each cadence) over all cadences.
%         The least squares problem is set up as A*wts = Bbar*ones(N,1)
%         where A = [starpixels, dx.starpixels, dy.starpixels,
%         (dx*dy).starpixels], starpixels being a matrix of size NxM.
%         wts = (V *inv(S)* U')*(Bbar*ones(N,1)). The complete algorithm is
%         described in the correponding Photometric Weights Assignment
%         Prototype design note.


[nCadences, nPixels] =  size(starPixelTimeSeries); % 8977x81

[nCadences, nPolynomialTerms] =  size(designMatrix); % 8977x81




A = zeros(nCadences, nPolynomialTerms*nPixels);


startColumn = 1;

for j = 1:nPolynomialTerms

    endColumn = startColumn + nPixels -1;

    A(:,startColumn:endColumn) = scalecol(designMatrix(:,j), starPixelTimeSeries);

    startColumn = endColumn +1;

    
end

meanFlux = mean(sum(starPixelTimeSeries,2)); % mean flux for the target star over ntsteps


polyCoefftForEachSingularValue = build_solution_sequence_via_svd(A,meanFlux);
% get optimal flux fit using 81*4 = 324  singular values (low order
% approximation)
fluxFits = A*polyCoefftForEachSingularValue; % 8977x324
                          



fluxFromSimpleAP = sum(starPixelTimeSeries,2); % flux time series obtained from simple aperture photometry
% determine at what order the optimal flux time series does not
% improve much

fluxFromSimpleAP = fluxFromSimpleAP./mean(fluxFromSimpleAP);

dataGapIndicators = false(nCadences,1);
[indexOfGiantTransits,indexOfNormal] = identify_giant_transits(fluxFromSimpleAP, dataGapIndicators,gapFillParametersStruct);


% [nframes nfits] = size(fluxFits);
% idx = 1:nframes;
% polyCoeffts0 = polyfit(idx',fluxFromSimpleAP,2);
% polyFit0 = polyval(polyCoeffts0,idx');
% residualFluxFromSimpleAP = fluxFromSimpleAP-polyFit0;
% 
% [idx1,idx2] = identify_giant_transits(residualFluxFromSimpleAP);
% 



if(~isempty(indexOfGiantTransits)) % there are giant trans
    A1 = A(indexOfNormal,:);
    polyCoefftForEachSingularValue = build_solution_sequence_via_svd(A1,meanFlux);
    fluxFits = A*polyCoefftForEachSingularValue; % 8977x324
end;

% idea behind taking the first difference is to makes the non
% stationary time series mostly stationary then choosing the order
% based on the min std corresponds to least noisy fit

fluxChangeAcrossCadence = diff(fluxFits,1,1);
serr = std(fluxChangeAcrossCadence,0,1);
[minerr, svdOrder] = min(serr);
svdOrder = svdOrder+1;


polyCoeffts = polyCoefftForEachSingularValue(:,svdOrder);
optimalWtsCoeffts = reshape(polyCoeffts, nPixels, nPolynomialTerms); % ncol = 9x9 =81
optimalWts = designMatrix*optimalWtsCoeffts';
fluxOptimal = sum(optimalWts.*starPixelTimeSeries,2);
% fluxOptimal = (fluxOptimal/meanFlux)-1;
% don't remove mean from fluxOptimal (DAC 12/20/2005)

return


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [polyCoefftForEachSingularValue] = build_solution_sequence_via_svd(A,meanFlux)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% do a reduced SVD on A
[U,S,V] = svd(A,0);

% number of columns of U to use
singularValues = diag(S);

[ntsteps nval] = size(A);
polyCoefftForEachSingularValue = zeros(nval, nval);
for m = 1:nval
    if( (singularValues(m)/singularValues(1)) > 1e-4)
        polyCoefftForEachSingularValue(:,m) = V(:,m)*(1/singularValues(m))*U(:,m)'*(ones(ntsteps,1).*meanFlux);
    else
        polyCoefftForEachSingularValue(:,m)  = 0;
        break;
    end;
end;
polyCoefftForEachSingularValue = cumsum(polyCoefftForEachSingularValue,2);
return;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
