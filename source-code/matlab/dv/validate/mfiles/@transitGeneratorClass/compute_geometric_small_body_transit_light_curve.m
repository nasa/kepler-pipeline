function lightCurve = compute_geometric_small_body_transit_light_curve(...
    transitModelObject, impactParameterArray, timestampsInTransit)
%function lightCurve = compute_geometric_small_body_transit_light_curve(...
%    transitModelObject, impactParameterArray, timestampsInTransit)
%
% function to generate a transit model light curve for a planet-to-star
% radius ratio < 0.01. Algorithms are based on the nonlinear limb darkening
% model of Mandel & Agol (2002).  These algorithms assume that the surface
% brightness of a star is constant under the disk of the eclipsing object,
% and that the semimajor axis is large compared to the size of the star so
% that the orbit can be approximated by a straight line.
%
%
% INPUTS:
%
% (1) transitModelObject with the following relevant fields:
%
%   limbDarkeningCoefficients  [array] nonlinear limb darkening coefficients
%
%   ratioPlanetRadiusToStarRadius [scalar] planet radius normalized by star
%                                  radius('p' in MA02)
%
% (2) impactParameterArray [array] impact parameter (separation distance of
%                          the planet and star centers as a function of time)
%                          normalized by star radius ('z' in MA02)
%
% (3) timestampsInTransit  [array] timestamps array (same size as impact
%                          parameter array), used for debug figures
%
% OUTPUTS:
%
%   lightCurve  [array] a light curve (the same size as the impact parameter
%                       array) that represents the change in flux relative
%                       to the unobscured flux due to transiting planet
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

% Modification history:
%
% 2010-December-1, EQ:
%     Initial release.

% allocate the light curve to the same size as the impact parameter array
lightCurve = ones(length(impactParameterArray), 1);

% extract parameters from the object
debugFlag  = transitModelObject.debugFlag;

ratioPlanetRadiusToStarRadius = transitModelObject.planetModel.ratioPlanetRadiusToStarRadius;
limbDarkeningCoefficients     = transitModelObject.limbDarkeningCoefficients;

% extract limb darkening coeffts
c1 = limbDarkeningCoefficients(1);
c2 = limbDarkeningCoefficients(2);
c3 = limbDarkeningCoefficients(3);
c4 = limbDarkeningCoefficients(4);


%--------------------------------------------------------------------------
% Nomenclature from Mandell & Agol (2002):
%
%   d       distance between star center and planet center
%   r_p     planet radius
%   r_s     star radius
%
%  Normalize parameters by stellar radius:
%
%   z =  d  / r_s           impactParameterArray
%   p = r_p / r_s           ratioPlanetRadiusToStarRadius
%
%--------------------------------------------------------------------------
z = impactParameterArray;
p = ratioPlanetRadiusToStarRadius;


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
% normalize light curve such that unobscured flux = 0
%--------------------------------------------------------------------------
lightCurve = lightCurve - 1;



% plot limb darkened light curve and validate that the correct model is used
if (debugFlag > 1)
    
    smallBodyCutoff = transitModelObject.smallBodyCutoff;
    
    if ratioPlanetRadiusToStarRadius > smallBodyCutoff
        error('DV:transitGeneratorClass:WrongModel', ...
        'The ratioPlanetRadiusToStarRadius is > smallBodyCutoff so the small body approximation should not be used.');
    end
    
    figure;
    
    lightCurveNormalizedToOne = lightCurve + 1;
    
    transitDepth = 1 - min(lightCurveNormalizedToOne);
    transitDepthPpm = transitDepth*1e6;
    
    plot(timestampsInTransit, lightCurveNormalizedToOne, 'b.-')
    
    xlabel('Timestamps in transit (- epoch (BKJD))')
    ylabel('Flux relative to unobscured star')
    title(['Small body limb darkened light curve,   Depth = '  num2str(transitDepthPpm) ' ppm'])
    grid on
end


return;



function result = iofr(c1,c2,c3,c4,r,p)

sig1 = sqrt(sqrt(1 - (r - p).^2));

sig2 = sqrt(sqrt(1 - (r + p).^2));

result = 1 - c1*(1. + (sig2.^5 - sig1.^5)/5/p./r) ...
    -c2*(1 + (sig2.^6 - sig1.^6)/6/p./r) ...
    -c3*(1 + (sig2.^7 - sig1.^7)/7/p./r) ...
    -c4*(1 + (sig2.^8 - sig1.^8)/8/p./r);
%    -c4*(p.^2+r.^2);


return;
