function p = legendre_polynomial(x, order)
% function p = legendre_polynomial(x, order)
%
% WARNING: this function is not meant to be called directly as a user API.
% It is called from the weighted_polyfit family of functions.  If you wish
% to use legendre polynomials see weighted_polyfit(2d).
%
% returns legendre polynomial with specified order in x
% x must be a single scalar value.
%
%   See also WEIGHTED_POLYFIT, WEIGHTED_DESIGN_MATRIX
%   WEIGHTED_POLYFIT2D, WEIGHTED_DESIGN_MATRIX2D
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

if length(x(:)) > 1
    error('legendre_polynomial: a scalar x value is required');
end

%  test to compare with built-in
%         t = legendre(order, x);
%         p = t(1);
%         return;
switch(order)
    case 0
        p = 1;
    case 1
        p = x;
    case 2
        p = 1.5*x*x - 0.5;
    case 3
        p = 2.5*power(x,3) - 1.5*x;
    case 4
        p = (35*power(x,4) - 30*power(x,2) + 3)/8;
    case 5
        p = (63*power(x,5) - 70*power(x,3) + 15*x)/8;
    case 6
        p = (231*power(x,6) - 315*power(x,4) + 105*power(x,2) - 5)/16;
    otherwise
        t = legendre(order, x);
        p = t(1);
%         the following is slower even with the extra work the MATLAB legendre
%           funciton does
%         This is based on the expansion of Rodregues' representation as described at
%           http://mathworld.wolfram.com/LegendrePolynomial.html
%
%         p = 0;
%         for k=0:floor(order/2)
%             p = p + power(-1, k)*nchoosek(order, k)*nchoosek(2*order - 2*k, order)*power(x, order-2*k);
%         end
%         p = p/power(2,order);
end

