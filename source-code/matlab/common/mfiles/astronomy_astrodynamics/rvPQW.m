function [r,v] = rvPQW(p,e,nu,P,Q,body)
%
% [r,v] = rvPQW(p,e,nu,P,Q,body)
%
% returns the position and velocity of a satellite orbiting body (Venus
% default) with its orbit defined by perifocal vectors P and Q, and
% semi-latus rectum p, true anomaly nu, and eccentricity e.
%
% The "body" variable is either the planet number (if an integer in the
% range [0-9]), 0 for Sol, 1 for Mercury, etc, or the GM of another body,
% in KM^3 s^-2.  N.B. the units of Km^3, not m^3!!!
%
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
if nargin < 6
    body = 2;
end
if nargin < 5
    error( 'rvPQW requires 5 arguments: semi-latus rectum p, eccentricity e, true anomaly nu, and perifocal vectors P and Q' );
end

cosnu = cos(nu);
sinnu = sin(nu);
rmag = p.*(1 + e.*cosnu).^(-1); % units are KM

% r = scalev(rmag.*cosnu,P) + scalev(rmag.*sinnu,Q);
r = ((rmag.*cosnu)*P) + ((rmag.*sinnu)*Q); % in KM

if fix( body ) == body
    allowed_planets = 0:9;
    if find( allowed_planets == body )
        if 0, disp( 'body is in allowed range' ), end
    else
        error( 'Value of body %d is not in the allowed range 0:9', body );
    end

    mu = gmp(body)/1000^3; % gmp(body) units are m^3 s^-2; units of mu are KM^3 s^-2
else
    mu = body;
end

%  v = scalev(-sqrt(mu*p.^(-1)).*sinnu,P) + scalev(sqrt(mu*p.^(-1)).*(e + cosnu),Q);
v = ((-sqrt(mu*p.^(-1)).*sinnu)*P)   + ( (sqrt(mu*p.^(-1)).*(e + cosnu) )*Q); % units are KM/sec

if(~isreal(v))
    error('complex v');
end;

return
