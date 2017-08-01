function wm = weighted_mean(X,W,dim)
% wmean: compute a weighted mean along a given dimension
% Usage: wm = wmean(X,W,dim)
%
% Arguments: (input)
% X - vector or array of any dimension
%
% W - (OPTIONAL) vector of weights, must be the same length
% as the size of X in the specified dimension. If W is
% not supplied or is left empty, then the built-in mean
% is called.
%
% At least one weight must be a positive number, all
% must be non-negative.
%
% dim - (OPTIONAL) positive integer scalar - denotes the
% dimension to compute the weighted mean over.
%
% If dim is not specified, then it will be the first
% dimension that matches the length of W.
%
% Arguments: (output)
% wm - weighted mean array (or vector). wm will be
% the same shape/size as X, except in the specified
% dimension.
%
% Example:
% X = rand(3,5);
% wmean(X,[0 1 3.5],1)
% ans =
% 0.19754 0.53772 0.49303 0.61549 0.13113
%
% See also: mean, median, mode, var, std
%
% Author: John D'Errico
% e-mail: woodchips@rochester.rr.com
% Release: 1.0
% Release date: 7/7/08
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

if (nargin==1) || (isempty(W) && (nargin<3))
    % no weights, no dim
    wm = mean(X);
    return
elseif isempty(W)
    % no weights, dim provided
    wm = mean(X,dim);
    return
end

% weights were provided, and were not empty
if ~isvector(W)
    error('W must be a vector.')
end
W = W(:);
if any(W<0)
    error('All weights must be non-negative')
elseif all(W==0)
    error('At least one must be positive')
end
nw = length(W);
nx = size(X);

% Normalize the weight vector to unit 1-norm
W = W/norm(W,1);

% we need to find dim?
if (nargin<3) || isempty(dim)
    dim = find(nx==nw,1,'first');
    if isempty(dim)
        dim = 1;
    end
elseif (dim<=0) || ~isscalar(dim) || dim~=round(dim)
    error('dim must be a positive integer scalar')
end
if nx(dim) ~= nw
    error('Weight vector is incompatible with size of X')
end

% compute the weighted mean - use bsxfun, then
% just sum down the specified dimension.
Wshape = ones(1,length(nx));
Wshape(dim) = nw;
wm = sum(bsxfun(@times,X,reshape(W,Wshape)),dim);

return

