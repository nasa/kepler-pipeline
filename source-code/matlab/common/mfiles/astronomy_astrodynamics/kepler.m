function [r,v] = kepler(t0, r0, v0, t, body, p, e)
%function [r,v] = kepler(t0, r0, v0, t, body, p, e)
%
% given t0, r0, v0, t and central body number, (km, km/s)
% kepler returns the position and
% velocities for the satellite at time(s) t.
% p and e are optional parameters which may be passed, if known,
% otherwise they are computed within kepler via "findorbels.m".
%
% default body (2) is venus
%
% if "body" is an integer, the solar system planet #body is assumed
% to be the central force body (body=0 => Sun, 1=> Mercury, 2=>Venus, etc)
% if "body" is not an integer, it is assumed to be G*Mass_central_object[Kg]
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

% some initializations
if nargin<5
    body = 2;
end

% Grab a planet if "body" is an integer
if fix(body) == body
    mu = gmp(body)/1000^3;
else
    mu = body;
end

sqmu_1  = 1/sqrt(mu);
[nt,mt] = size(t);
r0dotv0 = udotv(r0,v0);
r0mag   = magvec(r0);
v0mag   = magvec(v0);
tol     = 1.e-7;

% Determine orbital elements from t0,r0,v0
if nargin < 7
    [p, e] = findorbels(t0, r0, v0, body); 
end

% Determine 1/a
a_1 = (1-e^2)/p;

% Determine orbital period T
T = 2*pi*sqrt(a_1^(-3)/mu);% sec

% Solve universal time-of-flight equation for x using Newton iteration.
t_t0  = rem(t-t0, T);
x     = sqrt(mu) * t_t0 * a_1;% as a first guess, for elliptical orbits
z     = x.^2 * a_1;
C     = c_of_z(z);
S     = s_of_z(z);

t_try = sqmu_1 * (r0dotv0 * sqmu_1 * x.^2 .* C + (1 - r0mag * a_1) * x.^3 .* S + r0mag * x);

while any(abs(t_t0 - t_try) > tol)

    dtdx  = sqmu_1 * (x.^2 .* C + r0dotv0 * sqmu_1 * x .* (1 - z .* S) + r0mag * (1 - z .* C));
    x     = x + (t_t0-t_try)./dtdx;
    z     = x .^ 2 * a_1;
    C     = c_of_z(z);
    S     = s_of_z(z);
    t_try = sqmu_1 * (r0dotv0 * sqmu_1 * x.^2 .* C + (1 - r0mag * a_1) * x.^3 .* S + r0mag * x);

end

% Evaluate f and g, then compute r and rmag
f     = 1 - x.^2 / r0mag .* C;
g     = t_t0 - x.^3 * sqmu_1 .* S;
r0mat = [r0(1)*ones(nt,1) r0(2)*ones(nt,1) r0(3)*ones(nt,1)];
v0mat = [v0(1)*ones(nt,1) v0(2)*ones(nt,1) v0(3)*ones(nt,1)];

r    = scalev(f,r0mat) + scalev(g,v0mat);
rmag = magvec(r);

% Evaluate fdot and gdot, then compute v
fdot = sqrt(mu) / r0mag ./ rmag .* x .* (z .* S - 1);
gdot = 1 - x.^2 ./ rmag .* C;

v = scalev(fdot,r0mat) + scalev(gdot,v0mat);

return
