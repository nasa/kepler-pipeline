function [c condA, returnA, robustWeights] = robust_polyfit(x, data, weights, ...
    order, iterations, cutoff, type, A)
% function [c condA, A, robustWeights] = robust_polyfit(x, data, weights, ...
%     order, iterations, cutoff, type)
% 
% function that fits a one-dimensional polynomial to data in a way that 
% ignores outliers. This is done by iteratively calling weighted_polyfit
% and weighting data points by their distance from the resulting
% polynomial.
%
% The return struct c is passed to the routine weighted_polyval for 
% evaluation of the polynomial
% 
% inputs:
%   x: vector of the x-coordinate of points at which data is given
%   data: vector of the data at the point x
%   weights: multiplicative weights.  This can be a vector or scalar.
%       Typically these would be the inverse of the uncertainties
%       associated with the data values.
%       Pass 1 if all points are equally valid
%   order: order of the polynomial fit
% Optional inputs:
%   iterations: now ignored, left in for backwards compatability.
%   cutoff: now ignored, left in for backwards compatability
%   type: (Default: 'standard') type of the polynomial: 'standard',
%      'not_scaled' or 'legendre'.
%
% Note: x, data and w must all have the same size.
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
% 
%   condA: the inverse condition number of the final design matrix
%   A: the final design matrix
%   robustWeights: the final weights used in the robust fit
% 
%   See also WEIGHTED_POLYFIT, ROBUST_POLYFIT2D
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


if nargin < 7
    type = 'standard';
end
if nargin < 8
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
        returnA = [];
        return;
end
   
% scale x to improve conditioning
xp = c.offsetx + c.scalex*(x - c.originx);

% define the weight vector in case a scalar was passed in
if length(weights) == 1
    weights = weights*ones(size(x));
end
wp = weights;

% remove data points that have 0 weight
nonZeroWeightIndices = find(weights > 0);
xp = xp(nonZeroWeightIndices);
data = data(nonZeroWeightIndices);
wp = wp(nonZeroWeightIndices);

c.type = type;
c.order = order;
c.message = [];
if (size(A,1) == 0);
    A = weighted_design_matrix(xp, wp, order, type); % create the design matrix
end
if nargout >= 2
    condA = cond(A);
end

% perform the robust fit
[c.coeffs stats] = robustfit(A, data.*wp, [], [], 'off');

% if weights have been specified as an input argument then assume that they
% represent inverse uncertainties and determine the covariance matrix for
% the robust fit polynomial based on the equivalent least-squares
% solution: lscov(A, data.*wp, stats.w) returns the same polynomial
% coefficient vector as robustfit; lscov does not return the correct
% covariance matrix, however; it returns T1 * T1' below rather than
% T2 * T2' which is correct and equivalent to T1 * diag(stats.w) * T1'
if ~all(wp == 1)
    T1 = pinv(scalecol(sqrt(stats.w), A));
    T2 = scalerow(sqrt(stats.w), T1);
    c.covariance = T2 * T2';
else
    c.covariance = stats.covb;
end

robustWeights = zeros(size(weights));
robustWeights(nonZeroWeightIndices) = sqrt(stats.w);

returnA = zeros(length(weights), size(A, 2));
returnA(nonZeroWeightIndices,:) = A;

for i=1:size(returnA,1)
	returnA(i,:) = returnA(i,:)*robustWeights(i);
end

return
