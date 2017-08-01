function [c A condA statistics] = weighted_polyfit(x,data,w,order,type,A)
% function [c A condA statistics] = weighted_polyfit(x,data,w,order,type,A)
% 
% Top-lovel one-dimensional polynomial fitting routine.
% Returns the coefficients of a weighted (chi-squared) least-squares fit
% to data using a specified polynomial type 
%
% This routine uses the QR decomposition method when the design matrix 
% is well-conditioned or is full rank, otherwise uses the SVD to compute
% a near-full-rank pseudo-inverse.
%
% The return struct c is passed to the routine weighted_polyval for 
% evaluation of the polynomial
% 
% inputs:
%   x: vector of the x-coordinate of points at which data is given
%   data: linearized array of the data at the points x
%   w: multiplicative weights.  This can be a vector or scalar. 
%       Pass 1 if all points are equally valid
%   order: order of the polynomial fit
% Optional inputs:
%   type: (Default: 'standard') type of the polynomial: 'standard' 
%       'not_scaled' or 'legendre'.
%   A: (Default: []) pre-computed design matrix
%
% Note: x, y, data and w must all have the same size.
%
% returns:
%   c: a struct that comtains the following fields
%       .coeff: coefficient vector for the polynomial basis
%       .covariance: matrix giving the uncertainties in the coefficients
%       .order: order of the polynomial for these coefficients
%       .type: type of the polynomial for these coefficients
%       .offsetx, .scalex, .originx: data
%           that allows the scaling of the domain for improved numerical 
%           performance.  The values of these fields depends on the type
%           of polynomial
%       .xindex: index of column of x values in design
%       matrix.  Only valid for polys of type "not_scaled".
%       .message space for a message in case of an anomalous condition
% 
%   A: (optional) the design matrix used to compute the solution
% 
%   condA: (optional) rcond(A)
%
% Usage examples:
% 
%   for a standard polynomial fit (which returns uncertainties in 
%       the polynomial values in zu):
%
%       c = weighted_polyfit(x,data,w,4);
%       [z zu] = weighted_polyval(x,c);
% 
%	for a legendre polynomial fit:
% 
%       c = weighted_polyfit(x,data,w,4,'legendre');
%       z = weighted_polyval(x,c);
% 
%   if you are evaluating the polynomial at exactly the same points
%   where the design matrix was defined and with
%   equal weights, you can avoid recomputing the design matrix in the 
%   evaluation (in this case the x argument is ignored):
% 
%       [c,A] = weighted_polyfit(x,data,w,3);
%       z = weighted_polyval2D(x,c,A);
% 
%   See also WEIGHTED_POLYVAL, WEIGHTED_DESIGN_MATRIX, ROBUST_POLYFIT, WEIGHTED_POLYFIT2D
% 
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


if nargin < 5
    type = 'standard';
end
if nargin < 6
    A = [];
end

switch type
    case 'standard'
        c.offsetx = 0;
        c.scalex = 1/std(x);        
        c.originx = mean(x);
        c.xindex = -1; % this is not available in this type of matrix
        
    case 'not_scaled'
        c.offsetx = 0;
        c.scalex = 1;
        c.originx = 0;
        % indicate column of the data value in the design matrix
        % make sure this is consistent with weighted_design_matrix
        c.xindex = 2;

    case 'legendre'
        c.offsetx = -1;
        c.scalex = 2/(max(x) - min(x));
        c.originx = min(x);
        c.xindex = -1; % this is not available in this type of matrix
        
    otherwise
        display('unknown polynomial type');
        A = [];
        return;
end
   
% scale x to improve conditioning
xp = c.offsetx + c.scalex*(x - c.originx);


% define the weight vector in case a scalar was passed in
if length(w) == 1
    wp = w*ones(size(x));
else
    wp = w;
end

c.type = type;
c.order = order;
c.message = [];
if (size(A,1) == 0);
    A = weighted_design_matrix(xp, w, order, type); % create the design matrix
end
if nargout > 2
    condA = cond(A);
end

% if exist('regress', 'file')
%     [c.coeffs, statistics.confidenceInterval, statistics.residuals, ...
%         statistics.outlierIntervals, statistics.stats] ...
%         = regress(data.*wp, A);
%     c.covariance = inv(A'*A);
% else
    % The following code test the condition and rank of A, and uses an
    % explicit SVD method if either are defficient
    % Otherwise the problem is solved using the MATLAB '\' operator, 
    % which is somewhat faster than the manual code in the comments below.
    % The '\' operator solves via the QR decomposition

    if (cond(A) >= 1/eps) || (rank(A) < min(size(A)))
    %     A is poorly conditioned or has low rank, so use SVD
    %     display('SVD method');
        [U S V] = svd(A, 0);
        S = diag(S);
        Si = zeros(size(S));
        if max(S) > 0
            good_sv_index = find(S/max(S)>1e-9); % find good singular values
        else
            % if there are no entries bail with an invalid polynomial
            c.coeffs = 0;
            c.covariance = 0;
            c.message = 'empty diagonal matrix in SVD';
            return;
        end
        % check the rank
        rankA = length(good_sv_index);
        % if the rank is less than the degrees of freedom bail out with an
        % invalid polynomial
        if rankA < size(A, 2)
            c.coeffs = 0;
            c.covariance = 0;
            c.message = 'rank less than degrees of freedom';
            return;
        end
        if ~isempty(S(good_sv_index))
            Si(good_sv_index) = 1./S(good_sv_index); % invert the good singular values
        else
            error('Utilities:math:weighted_polyfit', 'S(good_sv_index) is empty');
        end
        c.coeffs = V*diag(Si)*U'*(data.*wp);

        % covariance matrix
        Vw=scalerow(Si,V);
        c.covariance = Vw*Vw';
        if nargout == 3
            statistics = [];
        end
    else
        c.coeffs = A\(data.*wp);
        c.covariance = inv(A'*A);
        if nargout == 3
            statistics = [];
        end
    end
% end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% The following code solves the problem explicitly.  This is somewhat
% slower than using the MATLAB '\' operator
% 
% ATA = A'*A;
% if rcond(ATA) <= eps
% %   ATA is poorly conditioned
%     if (cond(A) >= 1/eps) || (rank(A) < min(size(A)))
% %         display('SVD method');
% %       A is also poorly conditioned, so use SVD
%         [U S V] = svd(A);
%         Si = zeros(size(S));
%         good_sv_index = find(S>10*eps);
%         Si(good_sv_index) = 1./S(good_sv_index);
%         c.coeffs = V*Si'*U'*(data.*wp);
%     else
% %       A is well-conditioned, so use QR (faster than SVD but slower than normal method)
% %         display('QR method');
%         [Q R] = qr(A); % A = QR, Q orthogonal and R upper triangular
%         c.coeffs = R\Q'*(data.*wp); % normal equations method to solve for coefficients
%     end
% else
% %   ATA is well conditioned, so we can use the normal equations method
% %     display('normal method');
%     c.coeffs = ATA\A'*(data.*wp); % normal equations method to solve for coefficients
% end
% 
% End of the alternate code
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

