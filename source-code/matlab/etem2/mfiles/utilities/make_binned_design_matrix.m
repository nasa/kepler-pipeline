function A = make_binned_design_matrix(x, y, order, binFactor)
% previously: function Ajit = makeA2D(x, y, m, binFactor)
%
% Makes the design matrix Ajit for a 2D fit to parameters x and y up to
% a power of order > 0 in either x or y.
%
% x and y should be column vectors, probably representing motion w.r.t. time.
%
% Ajit's columns end up being the product of the following:
% Note that X1 is '1' and X2 is delta-X and X3 is (delta-X)^2 and so on.
% (There is an offset of 1 from the power of X and Y in the parenthesis)
%                       X1Y1 X2Y1 X1Y2 X3Y1 X2Y2 X1Y3 X4Y1 X3Y2 X2Y3 X1Y4 ETC....
% Pattern: X index(-1): 0    0    1    2    1    0    3    2    1    0    43210 543210 6543210
% Pattern: Y index(-1): 0    1    0    0    1    2    0    1    2    3    01234 012345 0123456
%                       c    x    y    x^2  xy   y^2  x^3  x^2y xy^2 y^3  ETC....
%
% binFactor >= 1 indicates the binning in the column direction.
% The default bin factor is 1.
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

if nargin < 4, binFactor = 1; end

% Allocate room for the result.
A = zeros( floor(length(x)/binFactor), (order+2)*(order+1)/2 );

% X and Y are matrices that are [length(x) or length(y) by (m+1)] with
% x.^0 x.^1 x.^2 ... x.^order, and
% y.^0 y.^1 y.^2 ... y.^order as each column.
% i.e. the first column is ones, the second is x, the third is x.^2, and so on.
X = cumprod( [ones(size(x)), repmat(x,1,order)], 2);
Y = cumprod( [ones(size(x)), repmat(y,1,order)], 2);

% k indexes the column of Ajit that is a product of specified columns of X and Y
k = 0;
for i = 0:order
    for j = 0:i

        % Next index
        k = k+1;

        % Product of selected columns of X and Y
        xiyj = X(:,i-j+1) .*Y(:,j+1);

        % If requested, bin the results in the column space
        if binFactor > 1
            xiyj = bin_matrix(xiyj, binFactor, 1);
        end

        % Finally, make the Ajit matrix itself.
        A(:,k) = xiyj;
    end
end

return