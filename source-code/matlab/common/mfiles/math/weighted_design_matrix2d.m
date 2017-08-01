% function A = weighted_design_matrix2D(x,y,w,order,type)
% 
% returns the design matrix for a weighted (chi-squared) least-squares 
% fit using a specified basis
%
% inputs:
%   x: column vector of the x-coordinate of points
%   y: column vector of the y-coordinate of points
%   w: multiplicative weights.  This can be a column vector or scalar. 
%       Pass 1 if all points are equally valid
%   order: order of the polynomial fit
% Optional inputs:
%   type: (Default: 'standard') type of the polynomial: 'standard' 
%       or 'legendre'.
% 
% Note: x, y and w must all have the same size.
% 
% returns:
%   A: design matrix
%
% Note: type 'legendre' requires the domains x and y to be in [-1, 1]
%
%   See also WEIGHTED_POLYFIT2D, WEIGHTED_POLYVAL2D, WEIGHTED_DESIGN_MATRIX
%               
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

function A = weighted_design_matrix2d(x,y,w,order,type)

if size(x, 2) ~= 1
	x = x(:);
end
if size(y,2) ~= 1
	y = y(:);
end
if size(w,2) ~= 1
	w = w(:);
end

if nargin == 4
    type = 'standard';
end


% initialize size and design matrix A
N = length(x);
op1 = order+1;
nterms = op1*(op1+1)/2; % = order*(order-1)/2 + order, strictly upper triangular part of nxn matrix has n*(n-1)/2 elements
A = zeros(N, nterms); 

% If the input weight is a scalar convert it to a vector
if length(w) == 1
    wpMatrix = w*ones(size(A));
else
    wpMatrix = w*ones(1,length(A(1,:)));
end

% put the switch statement outside the loop for performance
switch type
    case {'standard', 'not_scaled'}
        % method based on ETEM's MakeA2D.  Faster because it treats x and y as vectors so only loops over order

        % Manually assemble these matrices to speed up this function
        xUnitMatrix = ones(length(x), order+1);
        xMatrix = xUnitMatrix;
        yMatrix = xUnitMatrix;
        for i = 2 : order+1
            xMatrix(:,i) = x;
            yMatrix(:,i) = y;
        end
        X = cumprod(xMatrix, 2);
        Y = cumprod(yMatrix, 2);

        % Speed up the design matrix formulation
        % See previous revisions for older, yet equivalent algorithms
        k = 1;
        for i = 0:order
            % Speed up this indexing as much as possible
            k = k + i;

            % Product of selected columns of X and Y
            % This has been vectorized for speed
            A(:,k + [0:i]) = (X(:,i-[0:i]+1) .*Y(:,[0:i]+1)) .* wpMatrix(:,k + [0:i]);

        end

    case 'legendre'
        maxltri = tril(realmax*ones(op1,op1), -1);
        for i=1:N
            xt = fliplr(legendre_polynomial(x(i), order));
            yt = legendre_polynomial(y(i), order);
            terms = fliplr(triu(yt'*xt) + maxltri); 
            terml = terms(:)';
            A(i,:) = terml(find(terml~=realmax))*wpMatrix(i,1);

        end
        
    otherwise
        display('unknown polynomial type');
        return;
end

