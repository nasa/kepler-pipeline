function Cz = c_of_z(z)
%function Cz = c_of_z(z)
%
% Supporting code for computer solutions of the Kepler problem
% Returns the cosine integral fucntion of an orbit (used in the time-of-flight
%   equation for 2-body orbital problems).
%
% Reference: Fundamentals of Astrodynamics, Bate, Mueller, & White
% Dover 0-486-60061-0
% Pages 208-209
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

% Allocate space for the results
[n,m] = size(z);
Cz    = zeros(n,1);

% Positive z
igt0  = find(z > 2*eps);

% negative z
ilt0  = find(z < -2*eps);

% z approximately equal to zero
i0    = find(z <= 2*eps & z >= -2*eps);

% Equation 4.4-10 page 208
if ~isempty(igt0)
    Cz(igt0) = (1 - cos(sqrt(z(igt0)))) ./ z(igt0);
end

% Equation 4.5-12 page 208
if ~isempty(ilt0)
    Cz(ilt0) = (1 - cosh(sqrt(-z(ilt0)))) ./ z(ilt0);
end

% Equation 4.5-14 evaluated at z=0, S is about 1/2
if ~isempty(i0)
    Cz(i0) = 1/2 + Cz(i0);
    k      = 1;
    term   = -z(i0) / factorial(4);

    % Keep computing the series expansion of C(z) according to
    % equation 4.5-14 until the relative size of C(z) is not changing
    % with respect to the size of "term" (i.e. the series converged)
    while abs(Cz(i0) + term - Cz(i0)) > 0
        Cz(i0) = Cz(i0) + term;
        term   = term * (-z(i0)) / (2*k+1) / (2*k+2);
    end
    
end

return
