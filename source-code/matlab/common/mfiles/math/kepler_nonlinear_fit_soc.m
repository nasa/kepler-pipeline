function [beta,r,J,Sigma,mse, robustWeights] = kepler_nonlinear_fit_soc(X,y,model,beta,options, ...
    superSilent)
%kepler_nonlinear_fit_soc Nonlinear least-squares regression.
% [beta, r, J, Sigma, mse, robustWeights] = kepler_nonlinear_fit_soc(X, y, model, beta, options) is a
%    modification of Matlab's nlinfit function.  Changes wrt the original Matlab version
%    include the following:
%
%    1.  The robust weights computed in the robust fitting option are returned in
%        robustWeights.  The weights have the sense of being the proportionality constant
%        applied to the inverse RMS error of the data points, ie, sigma(i) -> sigma(i) /
%        robustWeight(i).
%    2.  An additional option parameter, 'convSigma', is available.  This parameter allows
%        robust fitting to stop iterating when the change in parameters from one iteration
%        to the next is < convSigma * the estimated uncertainty in the parameters.  The
%        default value of convSigma is 0, corresponding to the standard convergence
%        criterion of nlinfit.
%    3.  In order to use the additional option parameter convSigma, the Matlab functions
%        statset and statget are replaced by kepler_set_soc and kepler_get_soc.
%
%   See also nlinfit.
%
% Version date:  2010-January-11.
%
%   Copyright 1993-2005 The MathWorks, Inc.
%
%   This file is available under the terms of the MathWorks Limited License.
%   You should have received a copy of this license with the Kepler source
%   code; see the file MATHWORKS-LIMITED-LICENSE.docx.

% Modification History:
%
%     2010-January-11, PT:
%          protect getjacobian against inf value of delta.
%     2009-August-13, PT:
%          bugfix -- allow fdiffstep in getjacobian to be a vector as well as a scalar.
%          The documentation implies that this is already supported in nlinfit, but I
%          guess that the testing was not complete...
%     2008-December-17, PT:
%          Use convSigma convergence criterion in LMFit as well as in nlrobustfit (ie,
%          terminate levenberg-marquardt when change in par values is small compared to
%          par uncertainty).  Add more display statements.
%     2008-December-15, PT:
%         bugfixes to code which estimates error bars in robust fit iterator.  Add display
%         which tells the time needed for robust iterations.
%     2008-june-17, PT:
%         replace all nlinfit_fpg and statset_fpg uses with kepler_nonlinear_fit_soc and kepler_set_soc,
%         respectively.
%
%=========================================================================================


if nargin < 4
    error('stats:kepler_nonlinear_fit_soc:TooFewInputs','NLINFIT requires four input arguments.');
elseif ~isvector(y)
    error('stats:kepler_nonlinear_fit_soc:NonVectorY','Requires a vector second input argument.');
end
if nargin < 5
    options = kepler_set_soc('nlinfit');
else
    options = kepler_set_soc(kepler_set_soc('kepler_nonlinear_fit_soc'), options);
end
if ~exist('superSilent','var') || isempty( superSilent )
    superSilent = false ;
end

% Check sizes of the model function's outputs while initializing the fitted
% values, residuals, and SSE at the given starting coefficient values.
model = fcnchk(model);
try
    yfit = model(beta,X);
catch
    [errMsg,errID] = lasterr;
    if isa(model, 'inline')
        error('stats:kepler_nonlinear_fit_soc:ModelFunctionError',...
             ['The inline model function generated the following ', ...
              'error:\n%s'], errMsg);
    elseif strcmp('MATLAB:UndefinedFunction', errID) ...
                && ~isempty(strfind(errMsg, func2str(model)))
        error('stats:kepler_nonlinear_fit_soc:ModelFunctionNotFound',...
              'The model function ''%s'' was not found.', func2str(model));
    elseif strcmp('dv:modelFunction:fitTimeLimitExceeded', errID)
        error(errID, errMsg);
    else
        error('stats:kepler_nonlinear_fit_soc:ModelFunctionError',...
             ['The model function ''%s'' generated the following ', ...
              'error:\n%s'], func2str(model),errMsg);
    end
end
if ~isequal(size(yfit), size(y))
    error('stats:kepler_nonlinear_fit_soc:WrongSizeFunOutput', ...
          'MODELFUN should return a vector of fitted values the same length as Y.');
end



% Find NaNs in either the responses or in the fitted values at the starting
% point.  Since X is allowed to be anything, we can't just check for rows
% with NaNs, so checking yhat is the appropriate thing.  Those positions in
% the fit will be ignored as missing values.  NaNs that show up anywhere
% else during iteration will be treated as bad values.
nans = (isnan(y(:)) | isnan(yfit(:))); % a col vector
r = y(:) - yfit(:);
r(nans) = [];
n = numel(r);
p = numel(beta);
sse = r'*r;

funValCheck = strcmp(options.FunValCheck, 'on');
if funValCheck && ~isfinite(sse), checkFunVals(r); end

% Set the level of display
switch options.Display
    case 'off',    verbose = 0;
    case 'notify', verbose = 1;
    case 'final',  verbose = 2;
    case 'iter',   verbose = 3;
    case 'time',   verbose = 0;
end
if superSilent
    verbose = -1 ;
end
maxiter = options.MaxIter;


if strcmp(options.Robust,'off')
    % display format for non-robust fit
    if verbose > 2 % iter
        disp(' ');
        disp('                                     Norm of         Norm of    max( dBeta  ');
        disp('   Iteration             SSE        Gradient           Step       ./ Sigma )');
        disp('  ---------------------------------------------------------------------------');
        disp(sprintf('      %6d    %12g',0,sse));
    end
    [beta,J,lsiter,cause] = LMfit(X,y, model,beta,options,verbose,maxiter);
else
    % Do a preliminary fit just to get residuals and leverage from the
    % least squares coefficient.  We won't count this against the iteration
    % limit.
    if verbose >= 0
        disp(sprintf('            kepler_nonlinear_fit_soc:  perform pre-fit')) ;
    end
    timePrefitStart = clock ;
    [beta_ls,J] = LMfit(X,y, model,beta,options,0,maxiter);
    res = y - model(beta_ls,X);
    res(isnan(res)) = [];
    ols_s = norm(res) / sqrt(max(1,length(res)-length(beta)));
    timePrefitEnd = clock ;
    if verbose >= 0
        disp(sprintf(['            kepler_nonlinear_fit_soc:  pre-fit completed in ', ...
            num2str(etime(timePrefitEnd,timePrefitStart)),' seconds'])) ;
    end
    % display format for robust fit
    % Please note there are two loops for robust fit. It would be very
    % confusing if we display all iteration results. Instead, only the last
    % step of each inner loop (LM fit) will be output.
    if verbose > 2 % iter
        disp(' ');
        disp('Displaying iterations that re-calculate the robust weights');
        disp(' ');
        disp('   Iteration             SSE ');
        disp('  -----------------------------');
        disp(sprintf('      %6d    %12g',0,sse));
    end
    [beta,J,sig,cause, w] = nlrobustfit(X,y,beta,model,J,ols_s,options,verbose,maxiter);  
end;

switch(cause)
    case 'maxiter'
        warning('stats:kepler_nonlinear_fit_soc:IterationLimitExceeded', ...
                'Iteration limit exceeded.  Returning results from final iteration.');
    case 'tolx'
        if verbose > 1 % 'final' or 'iter'
            disp('Iterations terminated: relative norm of the current step is less than OPTIONS.TolX');
        end
    case 'tolfun'
        if verbose > 1 % 'final' or 'iter'
            disp('Iterations terminated: relative change in SSE less than OPTIONS.TolFun');
        end
    case 'convsigma'
        if verbose > 1 % 'final' or 'iter'
            disp('Iterations terminated: relative change in pars less than OPTIONS.convSigma');
        end
    case 'stall'
        warning('stats:kepler_nonlinear_fit_soc:UnableToDecreaseSSE', ...
                'Unable to find a step that will decrease SSE.  Returning results from last iteration.');
    end

% If the Jacobian is ill-conditioned, then two parameters are probably
% aliased and the estimates will be highly correlated.  Prediction at new x
% values not in the same column space is dubious.  NLPARCI will have
% trouble computing CIs because the inverse of J'*J is difficult to get
% accurately.  NLPREDCI will have the same difficulty, and in addition,
% will in effect end up taking the difference of two very large, but nearly
% equal, variance and covariance terms, lose precision, and so the
% prediction bands will be erratic.
[Q,R] = qr(J,0);
if n <= p
    warning('stats:kepler_nonlinear_fit_soc:Overparameterized', ...
            ['The model is overparameterized, and model parameters are not\n' ...
             'identifiable.  You will not be able to compute confidence or ' ...
             'prediction\nintervals, and you should use caution in making predictions.']);
elseif condest(R) > 1/(eps(class(beta)))^(1/2)
    warning('stats:kepler_nonlinear_fit_soc:IllConditionedJacobian', ...
            ['The Jacobian at the solution is ill-conditioned, and some\n' ...
             'model parameters may not be estimated well (they are not ' ...
             'identifiable).\nUse caution in making predictions.']);
end

if nargout > 1
    % Return residuals and Jacobian that have missing values where needed.
    yfit = model(beta,X);
    r = y - yfit;
    JJ(~nans,:) = J;
    JJ(nans,:) = NaN;
    J = JJ;  
end
if nargout > 3
    if strcmp(options.Robust,'off')
        % We could estimate the population variance and the covariance matrix
        % for beta here as
        mse = sum(abs(r(~nans)).^2)/(n-p);
        robustWeights = [];
    else
        mse = sig.^2;
        robustWeights = w;
    end
    Rinv = inv(R);
    Sigma = Rinv*Rinv'*mse;
    
end


%----------------------------------------------------------------------
function  [beta,J,iter,cause] = LMfit(X,y, model,beta,options,verbose,maxiter) 
% Levenberg-Marquardt algorithm for nonlinear regression

% Set up convergence tolerances from options.
betatol = options.TolX;
rtol = options.TolFun;
stol = options.convSigma ;
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
    J = getjacobian(beta,fdiffstep,model,X,yfit,nans,betatol);

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
    % steepest descent direction.
    if sse < sseold
        lambda = 0.1*lambda;
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
    [Q,R] = qr(J,0);
    Rinv = inv(R);
    Sigma = Rinv*Rinv'*sse;
    Sigma = sqrt(diag(Sigma)) ;
    Sigma = reshape(Sigma,size(beta)) ;
    dBetaNorm = abs(betaold(:) - beta(:)) ./ Sigma(:) ;
    if verbose > 2 % iter
        disp(sprintf('      %6d    %12g    %12g    %12g    %12g', ...
                     iter,sse,norm(2*r'*J),norm(step),max(dBetaNorm)));
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
    elseif (~isempty(stol)) && (max(dBetaNorm) < stol)
        cause = 'convsigma' ;
        break ;
    end
end
if (iter >= maxiter)
    cause = 'maxiter';
end


%--------------------------------------------------------------------------
function checkFunVals(v)
% check if the functin has the finite output
if any(~isfinite(v))
    error('stats:kepler_nonlinear_fit_soc:NonFiniteFunOutput', ...
          'MODELFUN has returned Inf or NaN values.');
end

%--------------------------------------------------------------------------
function [beta,J,sig,cause, sw]=nlrobustfit(x,y,beta,model,J,ols_s,options,verbose,maxiter)
% nonlinear robust fit

tune = options.Tune;
WgtFun = options.WgtFun;
betatol = options.TolX;
convSigma = options.convSigma ;

[eid,emsg,WgtFun,tune] = dfswitchyard('statrobustwfun', WgtFun,tune);
if ~isempty(eid)
    error(sprintf('stats:kepler_nonlinear_fit_soc:%s',eid), emsg);
end

yfit = model(beta,x);
fullr = y(:) - yfit(:);
ok = ~isnan(fullr);
r = fullr(ok);
Delta = sqrt(eps(class(beta))) ;

% Adjust residuals using leverage, as advised by DuMouchel & O'Brien
% Compute leverage based on X, the Jacobian
[Q,ignore]=qr(J,0);
h = min(.9999, sum(Q.*Q,2));

% Compute adjustment factor
adjfactor = 1 ./ sqrt(1-h);

radj = r .* adjfactor;

% If we get a perfect or near perfect fit, the whole idea of finding
% outliers by comparing them to the residual standard deviation becomes
% difficult.  We'll deal with that by never allowing our estimate of the
% standard deviation of the error term to get below a value that is a small
% fraction of the standard deviation of the raw response values.
tiny_s = 1e-6 * std(y);
if tiny_s==0
    tiny_s = 1;
end

% Main loop of repeated nonlinear fits, adjust weights each time
totiter = 0;
nLoops = 0 ;
w = repmat(NaN,size(y));
while maxiter>0
    loopStartTime = clock ;
    nLoops = nLoops + 1 ;
    if verbose >= 0
        disp(sprintf(['            kepler_nonlinear_fit_soc:  robust fit iteration ', ...
            num2str(nLoops),' started'])) ;
    end
    beta0=beta;
    s = madsigma(radj, length(beta)); % robust estimate of sigma for residual

    % Compute robust weights based on current residuals
    w(ok) = feval(WgtFun, radj/(max(s,tiny_s)*tune));

    % this is the weighted nlinfit
    sw = sqrt(w);
    yw = y .* sw;
    modelw = @(b,x) sqrt(w).*model(b,x);
    options1 = options;
    options1.Display = 'off';
    [beta,J1,lsiter,cause] = LMfit(x,yw,modelw,beta0,options,0,maxiter);
    totiter = totiter + lsiter;
    maxiter = maxiter - lsiter;
    yfit = model(beta,x);
    fullr = y - yfit;
    r = fullr(ok);
    radj = r .* adjfactor;
    p = numel(beta);
    n = length(radj);
    mad_s = madsigma(radj, p);   
    
%   PT:  calculate a convergence criterion which will be less strict and less subject to
%   instability for parameters which are close to zero.  In this case, the convergence
%   depends on the parameter variation being small compared to the parameter uncertainty,
%   rather than the parameter absolute value.

    % Compute a robust scale estimate for the covariance matrix
    sig = dfswitchyard('statrobustsigma', WgtFun,radj,p,mad_s,tune,h);
    
    % Be conservative by not allowing this to be much bigger than the ols value
    % if the sample size is not large compared to p^2
    sig = max(sig, ...
          sqrt((ols_s^2 * p^2 + sig^2 * n) / (p^2 + n)));
      
%   compute the parameter uncertainty
    [Q,R] = qr(J1,0);
    Rinv = inv(R);
    Sigma = Rinv*Rinv'*sig.^2;
    Sigma = sqrt(diag(Sigma)) ;
    Sigma = reshape(Sigma,size(beta)) ;
    
    % if there is no change in any coeffcienct, the iterations stop.
    convBetaCondition = (  abs(beta-beta0) < Delta*max(abs(beta),abs(beta0))  );
    convSigmaCondition = (  abs(beta-beta0) < convSigma*Sigma ) ;
    convCondition = (convBetaCondition | convSigmaCondition) ;
    if verbose > 2 % iter
        disp(sprintf('      %6d    %12g', ...
                     totiter, r'*r));
    end
    loopEndTime = clock ;
    loopExecTime = etime(loopEndTime,loopStartTime) ;
    if (strcmpi(options.Display,'time'))
        disp(sprintf(['            kepler_nonlinear_fit_soc:  robust fit iteration ', ...
            num2str(nLoops),' completed in ',num2str(loopExecTime),' seconds'])) ;
    end
    if  all(convCondition)
        if verbose >= 0
            disp(sprintf(['            kepler_nonlinear_fit_soc:  converged after ', ...
                num2str(nLoops),' iterations'])) ;
        end
        break;
    end
    
end

% this is a warning about the non-convergence
if maxiter<=0
    cause = 'maxiter';
end

% We need the Jacobian at the final coefficient estimates, but not the J1
% version returned by LMfit because it has robust weights included
fdiffstep = options.DerivStep;
loopStartTime = clock ;
if verbose >= 0
    disp(sprintf('            kepler_nonlinear_fit_soc:  calculating final Jacobian')) ;
end
J = getjacobian(beta,fdiffstep,model,x,yfit,~ok,betatol);

% Compute MAD of adjusted residuals after dropping p-1 closest to 0
p = numel(beta);
n = length(radj);
mad_s = madsigma(radj, p);   

% Compute a robust scale estimate for the covariance matrix
sig = dfswitchyard('statrobustsigma', WgtFun,radj,p,mad_s,tune,h);

% Be conservative by not allowing this to be much bigger than the ols value
% if the sample size is not large compared to p^2
sig = max(sig, ...
          sqrt((ols_s^2 * p^2 + sig^2 * n) / (p^2 + n)));
loopEndTime = clock ;
if verbose >= 0
    disp(sprintf(['            kepler_nonlinear_fit_soc:  final Jacobian computed in ', ...
        num2str(etime(loopEndTime,loopStartTime)),' seconds'])) ;
end



%----------------------- Robust estimate of sigma
function s = madsigma(r,p)
%MADSIGMA    Compute sigma estimate using MAD of residuals from 0
n = length(r);
rs = sort(abs(r));
s = median(rs(max(1,min(n,p)):end)) / 0.6745;

% ---------------------- Jacobian
function J = getjacobian(beta,fdiffstep,model,X,yfit,nans,betatol)
p = length(beta);
delta = zeros(size(beta));
J = zeros(length(yfit),p);
if (isscalar(fdiffstep))
    fdiffstep = repmat(fdiffstep,size(beta)) ;
end
for k = 1:p
    if (beta(k) == 0)
        nb = sqrt(norm(beta));
        delta(k) = fdiffstep(k) * (nb + (nb==0));
    else
        delta(k) = fdiffstep(k)*beta(k);
    end
    
    yplus = model(beta+delta,X);
    dy = yplus(:) - yfit(:);
    
    if(all(abs(dy) <= 1e-12)) % dy = 0
        while(all(abs(dy) <= 1e-12)) % dy = 0
            delta(k) = delta(k)*10;
            if isnan(delta(k)) || isinf(delta(k))
                error('common:nlinfitSoc:parameterDeltaInvalid', ...
                    ['kepler_nonlinear_fit_soc:  parameter ', num2str(k), ...
                    ' of ''delta'' in getjacobian invalid (inf or nan)']) ;
            end
            yplus = model(beta+delta,X);
            dy = yplus(:) - yfit(:);
        end
    end

        
        
    
    dy(nans) = [];
    J(:,k) = dy/delta(k);
    delta(k) = 0;
end

