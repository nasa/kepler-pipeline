function [xn,yn] = doproj(testObject, alpha_deg,delta_deg,centInd)
%this function currently doesn't do anything, it just calls 
%projPlaneFromSky
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

%TODO: remove this, just call projPlaneFromSky

[xn,yn] = projPlaneFromSky(alpha_deg,delta_deg,centInd);
end

function [i_deg,j_deg] = projPlaneFromSky(alpha_deg,delta_deg,centInd)
%this function takes as inputs the ra and dec in degrees and the array
%index which specifies the reference pixel
%the outputs are the projection plan coordinates used for fitting

[phi_rad,theta_rad] = relSkyFromSky(alpha_deg,delta_deg,centInd);
[i_deg,j_deg] = projPlaneFromRelSky(theta_rad,phi_rad);

end

function radians = degToRad(degrees)
radians = degrees .* (pi/180.);
end

function degrees = radToDeg(radians)
degrees = radians .* (180./pi);
end


function [phi_rad,theta_rad] = relSkyFromSky(alpha_deg,delta_deg,centInd)
%this function converts from ra dec coords in degrees to relative sky
%coordinates.
%The calculation performs a rotation in spherical coordinates using Euler 
%angles. The equations are taken from Section 2.3 of Calabretta and 
%Greisen 2002, equation 5

alpha_rad = degToRad(alpha_deg);
delta_rad = degToRad(delta_deg);

lonpole = 180.; %if CRVAL1 == 90, lonpole = 0 -> not an issue for Kepler
phiPole_rad = degToRad(lonpole);

alpha0 = alpha_rad(centInd);
delta0 = delta_rad(centInd);

sinD = sin(delta_rad);
cosD = cos(delta_rad);
sinD0 = sin(delta0);
cosD0 = cos(delta0);
sinADiff = sin(alpha_rad - alpha0);
cosADiff = cos(alpha_rad - alpha0);

a = sinD.*cosD0 - cosD.*sinD0.*cosADiff;
b = -cosD.*sinADiff;

phi_rad = phiPole_rad +atan2(b,a);
theta_rad = asin(sinD.*sinD0 + cosD.*cosD0.*cosADiff);


end


function [i_deg,j_deg] = projPlaneFromRelSky(theta_rad,phi_rad)
%fuction converts from tangent plane spherical coordinates to tangent plane
%cartesian coordinates.
%The equations are taken from Equs. 12, 13 and 54 of Calabretta and 
%Greisen 2002

%the i and j used here as called x and y in the paper but I found this
%confusing when talking about this and CCD physical coords.

Rtheta = radToDeg(1./tan(theta_rad));

i_deg = Rtheta .* sin(phi_rad);
j_deg = -Rtheta .* cos(phi_rad);


end
