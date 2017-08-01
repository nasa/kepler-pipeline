function lightCurve = compute_small_body_transit_light_curve(transitModelObject, ...
    intermediateStruct, impactParameterArray)
% function lightCurve = compute_small_body_transit_light_curve(transitModelObject, ...
%    intermediateStruct, impactParameterArray)
%
% function to generate a model transit light curve for the input set of 
% star/planet parameters and limb-darkening coefficients.  This function
% computes a light curve appropriate for small planets (planet/star ratio
% < ~0.1) by assuming that the surface brightness of a star is constant
% under the disk of the eclipsing object.  The semimajor axis should be
% large compared to the size of the star so that the orbit can be
% approximated by a straight line.  This is a much faster method than the
% algorithm in compute_flux_from_giant_planet_occult.
%
%
%--------------------------------------------------------------------------
%
% Algorithms herein are based on etem2 transitingOrbitClass methods.
%
% The analytic light curve generation functions are ported IDL scripts that
% implement the nonlinear limb darkening model of Mandel & Agol (2002),
% "MA02". Please cite MA02 if making use of this routine:
%   code:    http://www.astro.washington.edu/agol/microccult.html
%   article: http://arxiv.org/pdf/astro-ph/0210099
%
%--------------------------------------------------------------------------
%
% INPUTS:
%
% transitModelObject with the following fields:
%
%   .limbDarkeningCoefficients         [array] limb darkening cefficients
%   .impactParameterArray       [array] impact parameter
%
%
% OUTPUTS:
%
%   lightCurve                  flux light curve (the same size as input 
%                               cadenceTimes) which represents the change 
%                               in flux relative to the unobscured flux
%                               (which is normalized to 1) due to
%                               transiting object
%
%--------------------------------------------------------------------------
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


primaryRadiusMeters    = intermediateStruct.primaryRadiusMeters;
secondaryRadiusMeters  = intermediateStruct.secondaryRadiusMeters;

eclipsingObjectNormalizedRadius = secondaryRadiusMeters/primaryRadiusMeters;


% extract limb darkening coefficients
limbDarkeningCoefficients = transitModelObject.limbDarkeningCoefficients;

c1 = limbDarkeningCoefficients(1);
c2 = limbDarkeningCoefficients(2);
c3 = limbDarkeningCoefficients(3);
c4 = limbDarkeningCoefficients(4);

nb = length(impactParameterArray);

% allocate memory for light curve
lightCurve = ones(nb, 1);



%--------------------------------------------------------------------------
%
% Nomenclature from Mandell & Agol (2002):
%
%   d       distance between star center and planet center
%   r_p     planet radius
%   r_s     star radius
%
%  Normalize parameters by stellar radius:
%
%   z =  d  / r_s           impactParameterArray
%   p = r_p / r_s           eclipsingObjectNormalizedRadius
%
%--------------------------------------------------------------------------
z = impactParameterArray;
p = eclipsingObjectNormalizedRadius;


%--------------------------------------------------------------------------
% compute light curve for (1 - p) <  z < (1 + p)
%--------------------------------------------------------------------------
indx = find((z > 1 - p) & (z < 1 + p));

norm = pi*(1 - c1/5 - c2/3 - 3*c3/7 - c4/2);

x = 1 - (z(indx)-p).^2;

tmp = (1 - c1*(1 - 4/5*x.^0.25) - c2*(1 - 2/3.*x.^0.5) ...
    -c3*(1 - 4/7*x.^0.75) - c4*(1 - 4/8*x));

lightCurve(indx) = 1 - tmp.*(p.^2.*acos((z(indx) - 1)/p) ...
    - (z(indx) - 1).*sqrt(p.^2 - (z(indx) - 1).^2))/norm;


%--------------------------------------------------------------------------
% compute light curve for z <= (1 - p)  and z~=0
%--------------------------------------------------------------------------
indx = find((z <= 1 - p) & (z ~= 0));

lightCurve(indx) = 1 - pi*p.^2*iofr(c1, c2, c3, c4, z(indx), p)/norm;


%--------------------------------------------------------------------------
% compute light curve for z = 0
%--------------------------------------------------------------------------
indx = find(z == 0);

if ~isempty(indx)
    lightCurve(indx) = 1 - pi*p.^2/norm;
end


%--------------------------------------------------------------------------
% normalize light curve such that unobscured flux = 1
%--------------------------------------------------------------------------
lightCurve = lightCurve - 1;


return;


%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
function result = iofr(c1,c2,c3,c4,r,p)

sig1 = sqrt(sqrt(1 - (r - p).^2));

sig2 = sqrt(sqrt(1 - (r + p).^2));

result = 1 - c1*(1. + (sig2.^5 - sig1.^5)/5/p./r) ...
    -c2*(1 + (sig2.^6 - sig1.^6)/6/p./r) ...
    -c3*(1 + (sig2.^7 - sig1.^7)/7/p./r) ...
    -c4*(1 + (sig2.^8 - sig1.^8)/8/p./r);
%    -c4*(p.^2+r.^2);


return;
