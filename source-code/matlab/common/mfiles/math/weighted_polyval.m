function [z zu A] = weighted_polyval(x,c,A)
% function [z zu A] = weighted_polyval(x,c,A)
% 
% Top-lovel two-dimensional polynomial evaluation routine. 
% Returns the polynomial values at the points x for a two-dimensional
% polynomial basis with coefficients and geometry in the struct c as set by
% weighted_polyfit
%
% inputs:
%   x: vector of the x-coordinate of points at which the polynomial is
%       evaluated
%   c: a struct created by weighted_polyfit that comtains the following fields
%       .coeff: coefficient vector for the polynomial basis
%       .covariance: matrix giving the uncertainties in the coefficients
%       .order: order of the polynomial for these coefficients
%       .type: type of the polynomial for these coefficients
%       .offsetx, .scalex, .originx: data
%           that allows the scaling of the domain for improved numerical 
%           performance.  The values of these fields depends on the type
%           of polynomial
% Optional inputs:
%   A: (Default: []) pre-computed design matrix
%
% returns:
%   z: the value of the polynomial defined by c (and optionally A) at
%       positions x
%   zu: (if present) the uncertainties in the value of the polynomial defined by 
%       c at positions x
%   A: (if present) the design matrix used to evaluate the
%       polynomial
% 
%   See also WEIGHTED_POLYFIT, WEIGHTED_DESIGN_MATRIX, WEIGHTED_POLYVAL2D
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

if (length(c(1).coeffs) == 1 && c(1).coeffs == 0)
    z = 0;
	zu = 0;
    return;
end

if nargin == 2 % don't have a pre-computed design matrix
    % scale x to improve conditioning
    xp = c.offsetx + c.scalex*(x - c.originx);
    A = weighted_design_matrix(xp, 1, c.order, c.type);
end
z = A*[c.coeffs];
% if requested, return the uncertainties in the fitted values
% this operation takes much longer (about 10 times longer) than the rest of
% this routine
if nargout > 1    
% the following line is an efficient computation of zu = sqrt(diag(A*[c.covariance]*A'));
    zu = sqrt(sum(A*[c.covariance].*A, 2));
end
