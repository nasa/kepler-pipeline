function xd = detrendcols(x,k,ibad)
%function xd = detrendcols(x,k,ibad)
% 
% x is column-wise data to be detrended via a polynomial 
% k is the order of the polynomial to subtract from each column of x
% ibad is data to skip in the polynomial construction
%
% if k is omitted, the data is mean-centered
% if ibad is omitted, all data is used
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

% Find the order of the polynomial to subtract from the data.  0=mean centering
if nargin == 1
    k = 0;
end

% ibad is the set of indices to ignore when making the polynomial fit
if nargin < 3 
    ibad = [];
end

% Size of the original data
[m,n] = size(x);

% Find the good indices
igood = setdiff(1:m,ibad);

% Allocate space for result
xd    = zeros(m,n);

% uniformly spaced vector from -1 to 1 of length m
t     = normtime((1:m)');

% X will be the set of basis functions to fit
X     = ones(m,1);

% X will end up being (depending upon the order of the polynomial (k)
% to be a set of columns, the first one being all ones, the second being
% -1:1 the third being (-1:1).^2 then (-1:1)^3 etc. up to k
for i = 1:k
	X = [X, t.*X(:,i)];
end

% c is the least squares fit to the data x via the design matrix X
c     = (X(igood,:)' * X(igood,:)) \ (X(igood,:)' * x(igood,:));

% evaluate the fitted polynomial at all locations (no "igood" subscript)
xfit  = X * c;

% subtract off the fitted polynomial from the original data leaving the residual 
xd    = x - xfit;

return