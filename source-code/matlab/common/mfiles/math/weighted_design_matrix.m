function A = weighted_design_matrix(x, w, order, type)
% function A = weighted_design_matrix(x, w, order, type)
% 
% returns the design matrix for a weighted (chi-squared) least-squares 
% fit using a specified basis
%
% inputs:
%   x: vector of the x-coordinate of points
%   w: multiplicative weights.  This can be a vector or scalar. 
%       Pass 1 if all points are equally valid
%   order: order of the polynomial fit
% Optional inputs:
%   type: (Default: 'standard') type of the polynomial: 'standard' 
%       or 'legendre'.
% 
% Note: x and w must have the same size.
% 
% returns:
%   A: design matrix
%
% Note: type 'legendre' requires the domains x to be in [-1, 1]
%
%   See also WEIGHTED_POLYFIT, WEIGHTED_POLYVAL, WEIGHTED_DESIGN_MATRIX2D
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

% if the input weight is a scalar convert it to a vector
if length(w) == 1
    wp = w*ones(size(x));
else
    wp = w;
end

N = length(x);
A = [];

% put the switch statement outside the loop for performance
switch type
    case {'standard', 'not_scaled'}
        A = repmat(x(:),1,order+1).^repmat(0:order,length(x),1).*repmat(wp(:),1,order+1);
        %for n=1:N
            %construct as sums of monomials time weights
            %A = [A; power(x(n), 0:order)*wp(n)];
        %end
        
    case 'legendre'
        for n=1:N
            v = [];
            for o=0:order
                % construct via the legendre polynomial basis function
                v = [v legendre_polynomial(x(n), o)];
            end
            % multiply by weights and add to A
            A = [A; v*wp(n)];
        end
        
    otherwise
        display('unknown polynomial type');
        return;
end
