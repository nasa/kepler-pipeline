function [c A condA statistics] = weighted_polyfit2d(x,y,data,w,order,type,A)
% function [c A condA statistics] = weighted_polyfit2d(x,y,data,w,order,type,A)
% 
% Top-lovel two-dimensional polynomial fitting routine.
% Returns the coefficients of a weighted (chi-squared) least-squares fit
% to data using a specified polynomial type 
%
% This routine uses the QR decomposition method when the design matrix 
% is well-conditioned or is full rank, otherwise uses the SVD to compute
% a near-full-rank pseudo-inverse.
%
% The return struct c is passed to the routine weighted_polyval2D for 
% evaluation of the polynomial
% 
% inputs:
%   x: vector of the x-coordinate of points at which data is given
%   y: vector of the y-coordinate of points at which data is given
%   data: vector of the data at the points x,y
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
%       .coeffs: coefficient vector for the polynomial basis
%       .covariance: matrix giving the uncertainties in the coefficients
%       .order: order of the polynomial for these coefficients
%       .type: type of the polynomial for these coefficients
%       .offsetx, .scalex, .originx, .offsety, .scaley, .originy: data
%           that allows the scaling of the domain for improved numerical 
%           performance.  The values of these fields depends on the type
%           of polynomial
%       .xindex, .yindex: index of column of x and y values in design
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
%       c = weighted_polyfit2D(x,y,data,w,4);
%       [z zu] = weighted_polyval2D(x,y,c);
% 
%	for a legendre polynomial fit:
% 
%       c = weighted_polyfit2D(x,y,data,w,4,'legendre');
%       [z zu] = weighted_polyval2D(x,y,c);
% 
%   if you are evaluating the polynomial at exactly the same points
%   where the design matrix was defined and with
%   equal weights, you can avoid recomputing the design matrix in the 
%   evaluation (in this case the x and y arguments are ignored):
% 
%       [c,A] = weighted_polyfit2D(x,y,data,w,3);
%       z = weighted_polyval2D(x,y,c,A);
% 
%   See also WEIGHTED_POLYVAL2D, WEIGHTED_DESIGN_MATRIX2D, ROBUST_POLYFIT2D,
%   WEIGHTED_POLYFIT
% 
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

if nargin < 6
    type = 'standard';
end
if nargin < 7
    A = [];
end

switch type
    case 'standard'
        c.offsetx = 0;
        if std(x) ~= 0; 
            c.scalex = 1/std(x);
        else
            c.scalex = 1;
        end
        c.originx = mean(x);
        c.offsety = 0;
        if std(y) ~= 0; 
            c.scaley = 1/std(y);
        else
            c.scaley = 1;
        end
        c.originy = mean(y);
        c.xindex = -1; % this is not available in this type of matrix
        c.yindex = -1; % this is not available in this type of matrix
        
    case 'not_scaled'
        c.offsetx = 0;
        c.scalex = 1;
        c.originx = 0;
        c.offsety = 0;
        c.scaley = 1;
        c.originy = 0;
        % indicate columns of the data values in the design matrix
        % only good for not scaled matrices
        % make sure this is consistent with weighted_design_matrix2d
        c.xindex = 2;
        c.yindex = 3;
        
        
    case 'legendre'
        c.offsetx = -1;
        c.scalex = 2/(max(x) - min(x));
        c.originx = min(x);
        c.offsety = -1;
        c.scaley = 2/(max(y) - min(y));
        c.originy = min(y);
        c.xindex = 0;
        c.yindex = 0;
        c.xindex = -1; % this is not available in this type of matrix
        c.yindex = -1; % this is not available in this type of matrix
        
    otherwise
        display('unknown polynomial type');
        A = [];
        return;
end

% scale x to improve conditioning
xp = c.offsetx + c.scalex*(x - c.originx);
yp = c.offsety + c.scaley*(y - c.originy);

% define the weight vector in case a scalar was passed in
if length(w) == 1
    wp = w*ones(size(x));
else
    wp = w;
end

c.type = type;
c.order = order;
c.message = [];
if (size(A,1) == 0); % if we don't have a pre-computed design matrix 
%                       we have to make one
    A = weighted_design_matrix2d(xp,yp,w,order,type); % create the design matrix
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
        Si = zeros(size(S)); % pre-allocate the inverse S matrix
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
            error('Utilities:math:weighted_polyfit2d', 'S(good_sv_index) is empty');
        end
        c.coeffs = V*diag(Si)*U'*(data.*wp); % compute coefficients with pseudo-inverse

        % covariance matrix
        Vw=scalerow(Si,V);
        c.covariance = Vw*Vw';
        if nargout == 4
            statistics = [];
        end
    else
        c.coeffs = A\(data.*wp);
        c.covariance = inv(A'*A);
        if nargout == 4
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


