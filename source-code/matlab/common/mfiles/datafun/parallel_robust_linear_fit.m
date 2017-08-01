function [c, stats] = parallel_robust_linear_fit(x, y, debugFlag)
% [c, stats] = parallel_robust_linear_fit(x, y, debugFlag)
% This hastily cobbled together script vectorizes robustfit for the special
% case of a linear fit. The column vector x contains the abscissas for the
% fit while y is a matrix whose columns are the data to be fitted. The
% outputs are a matrix of coefficients, c, which has one column for each
% column of y, and a stats structure that conforms to the optional stats
% structure output by robustfit.

%   Copyright 1993-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.2 $  $Date: 2010/03/31 19:01:14 $
%
%   This file is available under the terms of the MathWorks Limited License.
%   You should have received a copy of this license with the Kepler source
%   code; see the file MATHWORKS-LIMITED-LICENSE.docx.
stats = [];

if nargin<3
    debugFlag = false;
end

MAX_ITERATIONS = 50;
nDoneThisIter = zeros(1,MAX_ITERATIONS) ;

D = sqrt(eps(class(x))); % from robustfit

tune = 4.685; % default tune from robustfit

nPoints = size(x,1);

nFits = size(y,2);

X = [x, ones(size(x))]; % design matrix

p = 2; % number of parameters to fit

absoluteTolerance = 1e-8;

%% initialize weights
weights = ones(size(y));

%% Find the least squares solution.
[Q, R, perm] = qr(X,0);
tol = abs(R(1)) * max(nPoints, p) * eps(class(R));
xRank = sum(abs(diag(R)) > tol);
if xRank == p
    c(perm,:) = R \ (Q'*y);
else
    error('datafun:parallelRobustLinearFit:xRankInvalid', ...
        'parallel_robust_linear_fit: rank of X ~= 2') ;
end
cOld = zeros(size(c));

% Adjust residuals using leverage, as advised by DuMouchel & O'Brien
E = X(:,perm)/R(1:xRank,1:xRank);
h = min(.9999, sum(E.*E,2));
adjFactor = 1 ./ sqrt(1-h);

dfe = nPoints - xRank;
if (dfe > 0)
  ols_s = sqrt(sum((y-X*c).^2)) / sqrt(dfe);
else
  ols_s = zeros(1,nFits) ;
end

% If we get a perfect or near perfect fit, the whole idea of finding
% outliers by comparing them to the residual standard deviation becomes
% difficult.  We'll deal with that by never allowing our estimate of the
% standard deviation of the error term to get below a value that is a small
% fraction of the standard deviation of the raw response values.
tiny_s = 1e-6 * std(y);
tiny_s(tiny_s==0) = 1;

%% 
count = 0;

cOld = zeros(2, nFits);

iKeepGoing = 1:nFits;
nDoneIterating = 0 ;
    
A = [x, ones(size(x))];

while 1
    count = count + 1;
    
    cOld = c;
    
    [c(:,iKeepGoing), weights(:,iKeepGoing), ySigmaMad(iKeepGoing)] = ...
        update_solution(X, y(:,iKeepGoing), c(:,iKeepGoing), adjFactor, tiny_s(iKeepGoing));

    %%
    if count > MAX_ITERATIONS
        nDoneThisIter(MAX_ITERATIONS) = sum(iKeepGoing) ;
        break
    end
    
%     Convergence criterion is that all parameters in a fit are changing by amounts small
%     compared to their values, OR by amounts small in absolute.  Note that, in a fit, one
%     coefficient can satisfy the absolute criterion and the other satisfy the relative
%     criterion, and this is a valid signal to stop iterating.

%     iKeepGoing = any(abs(c-cOld)>sqrt(eps)*max(abs(c),abs(cOld))) |...
%                  all(abs(c-cOld) < absoluteTolerance);
      iKeepGoing = any( ...
          abs(c-cOld)>sqrt(eps)*max(abs(c),abs(cOld)) & ...
          abs(c-cOld) > absoluteTolerance );
    
    nKeepGoing = sum(iKeepGoing) ;
    nDoneThisIter(count) = nFits - nKeepGoing - nDoneIterating ;
    nDoneIterating = nFits - nKeepGoing ;
    
%     if sum(iKeepGoing)==0
    if nKeepGoing == 0 
        break
    end
    
    
    if debugFlag
        semilogy(1e-10+abs(c'-cOld')),title([count,sum(iKeepGoing)]),drawnow
    end
    S(count, : ) = ySigmaMad;
    
end

if (nargout>1)
%%
   yResidual = y - X*c;
   yResidualAdjusted = yResidual .* repmat(adjFactor, 1, nFits);
   ySigmaMad = mad_sigma(abs(yResidualAdjusted), xRank);
   
   robust_s = zeros(1,nFits) ;
   % Compute a robust estimate of s -- this is somewhat more complicated for vectorized
   % linear fits
   allWeights0or1 = all(weights<D | weights>1-D);
   notAllWeights0or1 = any(weights>=D & weights<=1-D) ;
   sumWeightsIsTwo = sum(weights)>xRank*(1-D) ;
   twoPointFit = allWeights0or1 & sumWeightsIsTwo ;
   multiPointFit = allWeights0or1 & ~sumWeightsIsTwo ;
   
   % if there are only 2 points in the fits, then we should force the values of
   % allWeights0or1, etc.  This is because the fitter sometimes varies the weights by a
   % few times D in those cases.
   
   if ( dfe == 0 )
       allWeights0or1 = true(size(allWeights0or1)) ;
       notAllWeights0or1 = false(size(notAllWeights0or1)) ;
       sumWeightsIsTwo = true(size(sumWeightsIsTwo)) ;
       twoPointFit = true(size(twoPointFit)) ;
       multiPointFit = false(size(multiPointFit)) ;
   end
   
   if any(allWeights0or1)
       % All weights 0 or 1, this amounts to ols using a subset of the data
       robust_s(twoPointFit) = 0 ;
       included = weights(:,multiPointFit)>1-D;
       robust_s(multiPointFit) = sqrt(sum((yResidual(:,multiPointFit).*included).^2)) ...
           ./ sqrt(sum(included) - xRank);
   end
   if any(notAllWeights0or1)
       % Compute robust mse according to DuMouchel & O'Brien (1989)
       robust_s_2 = dfswitchyard('statrobustsigma', 'bisquare', yResidualAdjusted, xRank, ...
           max(ySigmaMad,tiny_s), tune, h);
       
       % it is occasionally possible for a fit with n parameters = n constraints to not be
       % caught in the allWeights0or1 logic above.  When that happens, robust_s_2 becomes
       % inf due to a div0 error.  Replace all such infs with 0 now (how QFT of us)
       robust_s_2(isinf(robust_s_2)) = 0 ;
       robust_s(notAllWeights0or1) = robust_s_2(notAllWeights0or1) ;
   end

   % Shrink robust value toward ols value if the robust version is
   % smaller, but never decrease it if it's larger than the ols value
   sigma = max(robust_s, ...
               sqrt((ols_s.^2 * xRank^2 + robust_s.^2 * nPoints) / (xRank^2 + nPoints)));

   % Get coefficient standard errors and related quantities
   RI = R(1:xRank,1:xRank)\eye(xRank);
   %tempC = (RI * RI') * sigma.^2; % this is a 2x2 for one input y vector
   RIRI = RI*RI';
   tempC = reshape(RIRI(:)*sigma(:)'.^2, [2, 2, nFits]);
   tempCdiag = [RIRI(1,1)*sigma.^2;RIRI(2,2)*sigma.^2];
   tempse = sqrt(max(eps(class(tempCdiag)),tempCdiag)); % This replaces zeros on the diagonal of tempC with sqrt(eps) and is 2x1 for one y vector
   C = repmat(NaN,[p,p,nFits]); % 2x2 in robustfit
   se = repmat(0,[p,1,nFits]); % 2x1 in robustfit
   covb(perm,perm,:) = tempC; % accounts for permutations
   C(perm,perm,:) = tempC ./ repmat(reshape(sum(tempse.^2), [1,1,nFits]), [2,2,1]); % normalizes to yield correlation coefficients
   se(perm,1,:) = reshape(tempse, [2,1,nFits]);

   % Make outputs conform with inputs
   %[r,w,h,adjfactor] = statinsertnan(wasnan,r,w,h,adjfactor);
   
   % Save everything
   stats.ols_s = ols_s;
   stats.robust_s = robust_s;
   stats.mad_s = ySigmaMad;
   stats.s = sigma;
   stats.resid = yResidual;
   stats.rstud = yResidual .* (adjFactor * sigma.^-1);
   stats.se = se;
   stats.covb = covb;
   stats.coeffcorr = C;
   stats.t = repmat(NaN,size(c));
   stats.t(se>0) = c(se>0) ./ se(se>0);
   stats.p = 2 * tcdf(-abs(stats.t), dfe);
   stats.w = weights;
   %stats.R(perm,perm) = R;
   z = zeros(p,p);
   z(perm,perm) = R(1:xRank,1:xRank);
   stats.R = z;
   stats.dfe = dfe;
   stats.h = h;
   stats.iterconv = nDoneThisIter ;
end


return

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [c, weights, ySigmaMad] = update_solution(X, y, c, adjFactor, tiny_s)
% [c, weights] = update_solution(X, y, c, adjFactor, tiny_s)

x = X(:,1);

nPoints = length(x);

tune = 4.685; % default tune from robustfit

% Compute residuals from previous fit, then compute scale estimate
yResidual = y - X*c;

yResidualAdjusted = yResidual .* repmat(adjFactor, 1, size(y,2));
   
% Compute new weights from these residuals, then re-fit

ySigmaMad = mad_sigma(abs(yResidualAdjusted), 2);

yResidualAdjustedNormalized = yResidualAdjusted./repmat( tune*max(ySigmaMad, tiny_s), nPoints, 1);

weights = bisquare(abs(yResidualAdjustedNormalized));


% fit line to data with new weights
S = sum(weights);

Sxx = x.^2'*weights;

Sx = x'*weights;

Sxy = x'*(weights.*y);

Sy = sum(weights.*y);

Delta = S.*Sxx-Sx.^2;

%%
c0 = (Sxx.*Sy-Sx.*Sxy)./Delta;
c1 = (S.*Sxy-Sx.*Sy)./Delta;

c = [c1(:)';c0(:)'];


return

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function x = jerfinv(y)
x=2/sqrt(2)*erfinv(2*(y-.5));

return

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function w = bisquare(r)
w = (abs(r)<1) .* (1 - r.^2).^2;

return

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function sigma = mad_sigma(absResidualAdjusted, p)
[nPoints, nFits] = size(absResidualAdjusted);

% remove smallest p-1 absolute residuals from each fit
for i = 1:p-1
    [absResidAdjustedMin, imin] = min(absResidualAdjusted);
    iimin = (0:nFits-1)*nPoints + imin;
    absResidualAdjusted = absResidualAdjusted(:);
    absResidualAdjusted(iimin) = [];
    absResidualAdjusted = reshape(absResidualAdjusted, nPoints-i, nFits);
end

sigma = median(absResidualAdjusted,1)/0.6745;

return
