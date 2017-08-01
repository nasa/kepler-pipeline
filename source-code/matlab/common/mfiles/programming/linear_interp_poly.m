function [yi, Ci, indexLo] = linear_interp_poly(x, y, C, xi)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [yi, Ci, indexLo] = linear_interp_poly(x, y, C, xi)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% INPUTS:
%     x:  A vector of timestamps for the y polynomials, with dimension
%         (nTimestamps)
%     y:  A 2D array of polynomial column vectors, with dimension (nCoeffs,
%         nTimestamps)
%     C:  A 3D array of covariance data where the third dimension
%         ("page") is time, with dimension (nCoeffs, nCoeffs, nTimestamps);
%         may be empty
%     xi: A vector of timestamps to interpolate to.
%
% OUTPUTS:
%     yi: A 2 dimensional array of interpolated polynomial column vectors,
%         with dimension  (nCoeffs, length(xi))
%     Ci: A 3 dimensional array of interpolated covariances, with dimension
%         (nCoeffs, nCoeffs, length(xi))
%     indexLo: A column vector with index of low polyomial for interpolation,
%              with dimension (nCoeffs, 1)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
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


% Do some error checking.
xLength = length(x);
nCoeffs = size(y, 1);

if 1 ~= min(size(x))
    error('Common:interp1Poly:improperDimension', ...
        'Improper dimension for x')
end

if xLength ~= size(y, 2)
    error('Common:interp1Poly:improperDimension', ...
        'Improper dimension between x, y')
end

if ~isempty(C)
    if xLength ~= size(C, 3)
        error('Common:interp1Poly:improperDimension', ...
        'Improper dimension between x, C')
    end
    
    if nCoeffs ~= size(C, 1) || nCoeffs ~= size(C, 2)
        error('Common:interp1Poly:improperDimension', ...
        'Improper dimension between y, C')
    end
end

    
% Get bracketing indices.
[ignore indexLo] = histc(xi, x);
indexLo(xi < x(1) | ~isfinite(xi)) = 1;
indexLo(xi >= x(xLength)) = xLength - 1;
indexHi = indexLo + 1;

% Calculate weights.
xLo = x(indexLo( : ));
xHi = x(indexHi( : ));
alpha = (xi( : ) - xLo) ./ (xHi - xLo);

% Compute weight arrays and perform polynomial interpolation.
w1 = repmat((1 - alpha)', [nCoeffs, 1]);
w2 = repmat(alpha', [nCoeffs, 1]);

yi = w1 .* y( : , indexLo) + w2 .* y( : , indexHi);

% If covariance data was provided then interpolate the covariances.
% Note that factors for covariance interpolation are 1-alpha and
% alpha. NOTE that the interpolation method was changed from the quadratic
% to (technically incorrect) linear interpolation as of SOC 8.3.
if ~isempty(C)
    
    CSize = size(C);
    w1 = repmat(reshape(1 - alpha, [1, 1, length(alpha)]), ...
        [CSize(1 : 2), 1]);
    w2 = repmat(reshape(alpha, [1, 1, length(alpha)]), ...
        [CSize(1 : 2), 1]);
    
    Ci = w1 .* C( : , : , indexLo) + w2 .* C( : , : , indexHi);
    
else
    
    Ci = [];
    
end

% Return.
return
