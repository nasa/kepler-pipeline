function [c,yfit] = robustpolyfit(A,y,ysig)
% [c,yfit] = robustpolyfit(A,y,ysig)
% Returns the coefficients c of a regression of y(x) on the columns in A 
% given uncertainties in the y measurements ysig (which are set to all ones, by 
% default, if not entered). y and ysig should be
% vectors of the same size. A should have the same number of rows as y and ysig.
% Additionally, the fitted vector yfit is returned and is the same size as y.
% This method de-emphasizes points with large deviations and iteratively
% fits the data in order to reduce the effect of strong outliers in
% perturbing the trend.
% Determine ysig if not input as median absolute deviation of the residual
% of the first fit.
% 
% Copyright 2017 United States Government as represented by the
% Administrator of the National Aeronautics and Space Administration.
% All Rights Reserved.
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

tol = 1e-8; % tolerance on fractional difference of residual (difference between y and fitted values

ysize = size(y);

m = size(A,2);

thresh = jerfinv(1-1/max(ysize)/2);

y = y(:); % ensure y is a column vector

if nargin<4
    determineysig = 1;
    ysig = ones(size(y)); % initial value, not serious
end

y_yfit = zeros(size(y));

wts = ones(size(y));

keepgoing=1;

c = 0;

yfit = 0;

maxiter = 200*m; % set maximum number of iterations

iter = 0; % keep track of iterations

while keepgoing
   
    iter = iter + 1;
    
    yfit_1 = yfit;
    
    c_1 = c;
    
    Asig = scalecol(wts./ysig,A); % modify A to include uncertainties
    
    b = y.*wts./ysig;
    
    c = (Asig'*Asig)\(Asig'*b);
    
    yfit = A*c;
    
    y_yfit = y-yfit;
    
    if determineysig
        ysig = median( abs( y_yfit-median(y_yfit) ) );
        ysig = ysig/.6; % for Gaussian distribution
        %determineysig = 0;
    end
    
    %wts = .5 + .5*cos(min( abs(y_yfit./ysig/thresh).^2*pi/2, pi));
    
    %wts = 1-atan((abs(y_yfit)-thresh)./ysig);
    
    wts = 1-1./(1+exp(-(abs(y_yfit./ysig)-thresh)*2*thresh));
    
    %disp(max(abs(c-c_1)))
    
    fracdiff = max(abs(yfit-yfit_1)./max(abs(y),1));
    
    if iter>1&&(fracdiff<tol||iter>maxiter), keepgoing = 0; end
    
    %%plot((yfit-yfit_1)./y),title(iter),drawnow
    
end

yfit = reshape(yfit,ysize);

return
