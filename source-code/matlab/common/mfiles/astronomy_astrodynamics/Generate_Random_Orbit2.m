%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function [r,v, p, P, Q] = Generate_Random_Orbit2(T, e, nu, Mtot)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Function Name:  Generate_Random_Orbit2.m
%
% Modification History - This can be managed by a revision control system
%
% Software level: Research Code
%
% Description: This function returns an orbit with an eccentricity e and
% orbital period T 
%
% Inputs: 
%       Orbital period T in seconds
%       Orbital eccentricity e (dimensionless)
%       nu - true anomaly in radians
%       Mtot - total mass in 2-body system (solar masses)
%
% Output:
%       r - position of satellite in KM (array of dimension 3 x N)
%       v - velocity of satellite in KM/sec (array of dimension  3 X N  )
%       P,Q,W = perifocal vectors of orbit (see Bate, Fundamentals of
%           Astrodynamics, p. 57, for definitions)
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


% NOTES:
% anomaly: An angle that gives the position of an object in an elliptical orbit at any given time. 
% The true anomaly is the angle between the periapsis of an orbit and the object's current orbital position, 
% measured from the body being orbited and in the direction of orbital motion. 
% The mean anomaly is what the true anomaly would be if the object orbited in a perfect circle at constant speed. 
% The mean anomaly is 0° at periapsis and 180° at apoapsis, just as for the true anomaly, but at other points 
% along the orbit the values of the mean and true anomalies differ. 
% The mean anomaly at a given time is often used as an orbital element.
% The eccentric anomaly is an angle related to both the true anomaly and the mean anomaly 
% that is encountered when solving Kepler's equation.


%
% Jon Jenkins   -  received as email attachment 8/09/04 (randorbit2.m)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function  [r,v, p, P, Q] = Generate_Random_Orbit2(T, e, nu, Mtot)

if nargin<4
    Mtot = 1;  % default to 1 solar mass
end

W = unitv(randn(1,3)); % axis of orbit with random inclination

% angular momentum vector directed along the normal to the orbital plane
% situated in any one of the 8 quadrants in 3d space

th = rand(1)*2*pi; % angle from line of nodes to periapsis



%+++++++++ get perifocal vectors P, Q from W and th ++++++++++++++++++++++

X = [1,0,0]; % direction to observer

Yo = unitv(uxv(W,X)); % y-axis in orbital plane (line of nodes)

Xo = unitv(uxv(Yo,W)); % x-axis in orbital plane


P = cos(th)*Xo + sin(th)*Yo;

Q = uxv(W,P);

%+++++++++ END +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++



% units of a are KM, since (KM^3 s^-2 * s^2)^(1/3) = KM
a = ((T/(2*pi)).^2*Mtot*gmp(0)/1000^3).^(1/3); % mean orbital size in KM


p = a*(1-e^2); % units KM

% The chord through a focus parallel to the conic section directrix of a
% conic section is called the latus rectum, and half this length is called
% the semilatus rectum (Coxeter 1969).
%"Semilatus rectum" is a compound of the Latin semi-, meaning half, latus,
%meaning 'side,' and rectum, meaning 'straight.'
% 
% For an ellipse, the semilatus rectum is the distance L measured from a
% focus such that (1/L) = (1/2)*[(1/r+)+(1/r-)] where r+ = a(1+e) and r- =
% a(1-e) are the apoapsis(the greatest radial distance of an ellipse as
% measured from a focus)  and periapsis(the smallest radial distance of an
% ellipse as measured from a focus) respectively.
%  Plugging in the values for r+ and r- we have L = a(1-e^2)


[r,v] = rvPQW(p,e,nu,P,Q,0);% P,Q are 3d vectors



return;
