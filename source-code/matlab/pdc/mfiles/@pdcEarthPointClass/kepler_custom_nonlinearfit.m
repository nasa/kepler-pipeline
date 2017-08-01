% =========================================================================================
% =========================================================================================
% Add in custom nlinfit and modify for speed. Original header text given below.

%NLINFIT Nonlinear least-squares regression.
%   BETA = NLINFIT(X,Y,MODELFUN,BETA0) estimates the coefficients of a
%   nonlinear regression function, using least squares estimation.  Y is a
%   vector of response (dependent variable) values.  Typically, X is a
%   design matrix of predictor (independent variable) values, with one row
%   for each value in Y and one column for each coefficient.  However, X
%   may be any array that MODELFUN is prepared to accept.  MODELFUN is a
%   function, specified using @, that accepts two arguments, a coefficient
%   vector and the array X, and returns a vector of fitted Y values.  BETA0
%   is a vector containing initial values for the coefficients.
%
%   [BETA,R,J,COVB,MSE] = NLINFIT(X,Y,MODELFUN,BETA0) returns the fitted
%   coefficients BETA, the residuals R, the Jacobian J of MODELFUN, the
%   estimated covariance matrix COVB for the fitted coefficients, and an
%   estimate MSE of the variance of the error term.  You can use these
%   outputs with NLPREDCI to produce confidence intervals for predictions,
%   and with NLPARCI to produce confidence intervals for the estimated
%   coefficients.  If you use a robust option (see below), you must use
%   COVB and may need MSE as input to NLPREDCI or NLPARCI to insure that
%   the confidence intervals take the robust fit properly into account.
%
%   [...] = NLINFIT(X,Y,MODELFUN,BETA0,OPTIONS) specifies control parameters
%   for the algorithm used in NLINFIT.  OPTIONS is a structure that can be
%   created by a call to STATSET.  Applicable STATSET parameters are:
%
%      'MaxIter'     - Maximum number of iterations allowed.  Defaults to 100.
%      'TolFun'      - Termination tolerance on the residual sum of squares.
%                      Defaults to 1e-8.
%      'TolX'        - Termination tolerance on the estimated coefficients
%                      BETA.  Defaults to 1e-8.
%      'Display'     - Level of display output during estimation.  Choices
%                      are 'off' (the default), 'iter', or 'final'.
%      'DerivStep'   - Relative difference used in finite difference gradient
%                      calculation.  May be a scalar, or the same size as
%                      the parameter vector BETA.  Defaults to EPS^(1/3).
%      'FunValCheck' - Check for invalid values, such as NaN or Inf, from
%                      the objective function.  'off' or 'on' (default).
%      'Robust'      - Flag to invoke the robust fitting option.  'off' (the default)
%                      or 'on'.
%      'WgtFun'      - A weight function for robust fitting.  Valid only when Robust
%                      is 'on'.  'bisquare' (the default), 'andrews', 'cauchy',
%                      'fair', 'huber', 'logistic', 'talwar', or 'welsch'.  Can
%                      also be a function handle that accepts a normalized residual
%                      as input and returns the robust weights as output.
%      'Tune'        - The tuning constant used in robust fitting to normalize the
%                      residuals before applying the weight function.  A positive
%                      scalar.  The default value depends upon the weight function.
%                      This parameter is required if the weight function is
%                      specified as a function handle.
%
%   NLINFIT treats NaNs in Y or MODELFUN(BETA0,X) as missing data, and
%   ignores the corresponding observations.
%
%   Examples:
%
%      Use @ to specify MODELFUN:
%         load reaction;
%         beta = nlinfit(reactants,rate,@mymodel,beta);
%
%      where MYMODEL is a MATLAB function such as:
%         function yhat = mymodel(beta, x)
%         yhat = (beta(1)*x(:,2) - x(:,3)/beta(5)) ./ ...
%                        (1+beta(2)*x(:,1)+beta(3)*x(:,2)+beta(4)*x(:,3));
%   
%      For an example of weighted fitting, see the Statistics Toolbox demo
%      "Weighted Nonlinear Regression".
%
%   See also NLPARCI, NLPREDCI, NLMEFIT, NLINTOOL, STATSET.

%   References:
%      [1] Seber, G.A.F, and Wild, C.J. (1989) Nonlinear Regression, Wiley.

%   NLINFIT can be used to make a weighted fit with known weights:
%
%      load reaction;
%      w = [8 2 1 6 12 9 12 10 10 12 2 10 8]'; % some example known weights
%      ratew = sqrt(w).*rate;
%      mymodelw = @(beta,X) sqrt(w).*mymodel(beta,X);
% 
%      [betaw,residw,Jw] = nlinfit(reactants,ratew,mymodelw,beta);
%      betaciw = nlparci(betaw,residw,Jw);
%      [ratefitw, deltafitw] = nlpredci(@mymodel,reactants,betaw,residw,Jw);
%      rmse = norm(residw) / (length(w)-length(rate))
% 
%   Predict at the observed x values.  However, the prediction band
%   assumes a weight (measurement precision) of 1 at these points.
%
%      [ratepredw, deltapredw] = ...
%            nlpredci(@mymodel,reactants,betaw,residw,Jw,[],[],'observation');

%   Copyright 1993-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.2 $  $Date: 2010/03/31 19:01:14 $
%
%   This file is available under the terms of the MathWorks Limited License.
%   You should have received a copy of this license with the Kepler source
%   code; see the file MATHWORKS-LIMITED-LICENSE.docx.
function beta = kepler_custom_nonlinearfit(X,y,model,beta,options)

if nargin < 4
    error('stats:nlinfit:TooFewInputs','NLINFIT requires four input arguments.');
elseif ~isvector(y)
    error('stats:nlinfit:NonVectorY','Requires a vector second input argument.');
end

maxIter = 50;
verbose = 0;
%options.Display = 'off';
%options.MaxIter = 50;
options.TolFun = 1e-3;
options.TolX = 1e-3;
options.DerivStep = eps^(1/3);
options.FunValCheck = 'on';
%options.Robust = 'off'; % option removed
options.WgtFun = 'bisquare';
options.Tune = []; % default varies by WgtFun, must be supplied for user-defined WgtFun

% Remove all checks to speed things up.

% Set the level of display
%switch options.Display
%    case 'off',    verbose = 0;
%    case 'notify', verbose = 1;
%    case 'final',  verbose = 2;
%    case 'iter',   verbose = 3;
%end

[beta,J,lsiter,cause] = LMfit(X,y, model,beta,options,verbose,maxIter);

end
%----------------------------------------------------------------------
function  [beta,J,iter,cause] = LMfit(X,y, model,beta,options,verbose,maxiter) 
% Levenberg-Marquardt algorithm for nonlinear regression

% Set up convergence tolerances from options.
betatol = options.TolX;
rtol = options.TolFun;
fdiffstep = options.DerivStep;
funValCheck = strcmp(options.FunValCheck, 'on');

% Set initial weight for LM algorithm.
lambda = .01;

% Set the iteration step
sqrteps = sqrt(eps(class(beta)));

p = numel(beta);

% treatment for nans
yfit = model(beta,X);
r = y(:) - yfit(:);
nans = (isnan(y(:)) | isnan(yfit(:))); % a col vector
r(nans) = [];

sse = r'*r;

zerosp = zeros(p,1,class(r));
iter = 0;
breakOut = false;
cause = '';

while iter < maxiter
    iter = iter + 1;
    betaold = beta;
    sseold = sse;

    % Compute a finite difference approximation to the Jacobian
    J = getjacobian(beta,fdiffstep,model,X,yfit,nans);

    % Levenberg-Marquardt step: inv(J'*J+lambda*D)*J'*r
    diagJtJ = sum(abs(J).^2, 1);
    if funValCheck && ~all(isfinite(diagJtJ)), checkFunVals(J(:)); end
    Jplus = [J; diag(sqrt(lambda*diagJtJ))];
    rplus = [r; zerosp];
    step = Jplus \ rplus;
    beta(:) = beta(:) + step;

    % Evaluate the fitted values at the new coefficients and
    % compute the residuals and the SSE.
    yfit = model(beta,X);
    r = y(:) - yfit(:);
    r(nans) = [];
    sse = r'*r;
    if funValCheck && ~isfinite(sse), checkFunVals(r); end
    % If the LM step decreased the SSE, decrease lambda to downweight the
    % steepest descent direction.  Prevent underflowing to zero after many
    % successful steps; smaller than eps is effectively zero anyway.
    if sse < sseold
        lambda = max(0.1*lambda,eps);
        
    % If the LM step increased the SSE, repeatedly increase lambda to
    % upweight the steepest descent direction and decrease the step size
    % until we get a step that does decrease SSE.
    else
        while sse > sseold
            lambda = 10*lambda;
            if lambda > 1e16
                breakOut = true;
                break
            end
            Jplus = [J; diag(sqrt(lambda*sum(J.^2,1)))];
            step = Jplus \ rplus;
            beta(:) = betaold(:) + step;
            yfit = model(beta,X);
            r = y(:) - yfit(:);
            r(nans) = [];
            sse = r'*r;
            if funValCheck && ~isfinite(sse), checkFunVals(r); end
        end
    end 
    if verbose > 2 % iter
        disp(sprintf('      %6d    %12g    %12g    %12g', ...
                     iter,sse,norm(2*r'*J),norm(step)));
    end

    % Check step size and change in SSE for convergence.
    if norm(step) < betatol*(sqrteps+norm(beta))
        cause = 'tolx';
        break
    elseif abs(sse-sseold) <= rtol*sse
        cause = 'tolfun';
        break
    elseif breakOut
        cause = 'stall';
        break
    end
end
if (iter >= maxiter)
    cause = 'maxiter';
end


end
%--------------------------------------------------------------------------
function checkFunVals(v)
% check if the function has finite output
if any(~isfinite(v))
    error('stats:nlinfit:NonFiniteFunOutput', ...
          'MODELFUN has returned Inf or NaN values.');
end

end

% ---------------------- Jacobian
function J = getjacobian(beta,fdiffstep,model,X,yfit,nans)
p = numel(beta);
delta = zeros(size(beta));
for k = 1:p
    if (beta(k) == 0)
        nb = sqrt(norm(beta));
        delta(k) = fdiffstep * (nb + (nb==0));
    else
        delta(k) = fdiffstep*beta(k);
    end
    yplus = model(beta+delta,X);
    dy = yplus(:) - yfit(:);
    dy(nans) = [];
    J(:,k) = dy/delta(k);
    delta(k) = 0;
end
end
