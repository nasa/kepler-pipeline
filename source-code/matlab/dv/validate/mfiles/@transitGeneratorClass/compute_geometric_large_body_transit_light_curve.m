function lightCurve = compute_geometric_large_body_transit_light_curve(...
    transitModelObject, impactParameterArray, timestampsInTransit)
%function lightCurve = compute_geometric_large_body_transit_light_curve(...
%    transitModelObject, impactParameterArray, timestampsInTransit)
%
% function to generate a transit model light curve for a planet-to-star
% radius ratio > 0.01. Algorithms are based on the nonlinear limb darkening
% model of Mandel & Agol (2002)
%
%
% INPUTS:
%
% (1) transitModelObject with the following relevant fields:
%
%   limbDarkeningCoefficients  [array] nonlinear limb darkening coefficients
%
%   ratioPlanetRadiusToStarRadius [scalar] planet radius normalized by star
%                                 radius('p' in MA02)
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
% Version date:  2013-January-15.
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

% Modification history:
%
%   2013-January-15, JL:
%     Error out when computation taking too long
%   2012-April-12, JL:
%     Add to impact parameter input array points close to
%     1+ratioPlanetRadiusToStarRadius to determine the normalization of    
%     the out-of-transit flux. Suggested by CJB.
%     Change the convergence tolerance to an absolute value rather than 
%     a relative to transit depth. Suggested by CJB.
%   2010-December-1, EQ:
%     Initial release.


% extract parameters from the object
debugFlag = transitModelObject.debugFlag;

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
%
%--------------------------------------------------------------------------
% generate light curve from uniform source:
%--------------------------------------------------------------------------
%
% the light curve F is partitioned in the following way (where r_p and d are
% normalized by r_s):
%
%   unobscured:
%
%       F = 1               d > r_s + r_p
%
%   planet transits, blocks all starlight:
%
%       F = 0               r_p > r_s  and d <= r_p - r_s
%
%   planet transits, but doesn't cover entire star disk
%
%       F = 1 - p^2         d <= r_s - r_p
%
%   planet transits, lies on limb
%
%       F = 1 - lambdae     d >= abs( r_s - r_p)  and  d <= r_s + r_p
%
%--------------------------------------------------------------------------

% Changed on 04/12/2012
% Add to impact parameter input array points  close to 1+ratioPlanetRadiusToStarRadius (very close to first contact). 
% These points will be used to determine the normalization of the out-of-transit flux. These points are removed at 
% the end of this function. Suggested by CJB.

nInputArray = length(impactParameterArray);
vEps        = (1:0.5:10)*1e-7;
nVeps       = length(vEps);
impactParameterArray = [ impactParameterArray; (1+ratioPlanetRadiusToStarRadius)*(1-vEps(:)) ];


nonLimbDarkenedLightCurve = get_transit_light_curve_for_uniform_star(...
    impactParameterArray, ratioPlanetRadiusToStarRadius);


%--------------------------------------------------------------------------
% Include limb darkening effects
%--------------------------------------------------------------------------
lightCurve = nonLimbDarkenedLightCurve;

depth = max(abs(lightCurve - 1));


% plot non-limb darkened light curve and validate that the correct model is used
if (debugFlag > 1)
    
    smallBodyCutoff = transitModelObject.smallBodyCutoff;
    
    if ratioPlanetRadiusToStarRadius < smallBodyCutoff
        error('DV:transitGeneratorClass:WrongModel', ...
        'The ratioPlanetRadiusToStarRadius is < smallBodyCutoff so the small body approximation should be used.');
    end
    
    figure;
    
    lightCurveNormalizedToOne = nonLimbDarkenedLightCurve;
    
    transitDepth = 1 - min(lightCurveNormalizedToOne);
    transitDepthPpm = transitDepth*1e6;
    
    plot(timestampsInTransit, lightCurveNormalizedToOne, 'm.-')
    
end


%--------------------------------------------------------------------------
% Additional parameters defined for convenience in MA02:
%
%  c0 = 1 - c1 - c2 - c3 - c4
%
%  a = (z - p)^2
%
%  b = (z + p)^2
%
%  Omega = Summation(n = 0 to 4) of cn*(n + 4)^(-1)
%        = c0/4 + c1/5 + c2/6 + c3/7 + c4/8
%
%  mu = cos(theta) = sqrt(1 - r^2)  where  0 <= r <= 1
%
%  r is the normalized radial coordinate on the disk of the star
%--------------------------------------------------------------------------

% define Omega in terms of known limb darkening coeffs
omega = 4*((1 - c1 - c2 - c3 - c4) / 4 + c1/5 + c2/6 + c3/7 + c4/8);    % check validity of extra 4


%--------------------------------------------------------------------------
% Partition the parameter space in z and p into regions and cases listed in
% Table 1 of MA02
%--------------------------------------------------------------------------

indx = find(lightCurve ~= 1);

% Changed on 04/12/2012
% Force the extra normalization points to be included. The points may be
% included twice in the indices, but that's fine. Suggested by CJB.
indx = [ indx; nInputArray+[1:nVeps]' ]; 

mulimb          = lightCurve(indx);
mulimbhalf      = mulimb;
mulimb1         = mulimb;
mulimb3half     = mulimb;
mulimb2         = mulimb;


dt = 1;
nr = 2;
dmumax = 1;
tic;

% Changed on 04/12/2012
% Change the convergence tolerance to an absolute value rather than a relative to transit depth.
% Suggested by CJB.

% while (dmumax > depth*1e-3)
while (dmumax > 1e-7)    

    mulimbp = mulimb;
    nr  = nr*2;
    dt  = 0.5*pi/nr;
    t   = dt*(0:nr+1);
    th  = t+0.5*dt;
    r   = sin(t);
    sig = sqrt(cos(th(nr)));
    
    mulimbhalf  =sig^3.*lightCurve(indx)./(1-r(nr));
    mulimb1     =sig^4.*lightCurve(indx)./(1-r(nr));
    mulimb3half =sig^5.*lightCurve(indx)./(1-r(nr));
    mulimb2     =sig^6.*lightCurve(indx)./(1-r(nr));
    
    for i = 2:nr
        
        % Calculate uniform magnification at intermediate radii:
        mu = get_transit_light_curve_for_uniform_star(impactParameterArray(indx)./r(i),ratioPlanetRadiusToStarRadius./r(i));
        
        sig1    = sqrt(cos(th(i-1)));
        sig2    = sqrt(cos(th(i)));
        
        mulimbhalf  = mulimbhalf  + r(i)^2*mu.*(sig1^3./(r(i) - r(i-1)) - sig2^3./(r(i + 1) - r(i)));
        mulimb1     = mulimb1     + r(i)^2*mu.*(sig1^4./(r(i) - r(i-1)) - sig2^4./(r(i + 1) - r(i)));
        mulimb3half = mulimb3half + r(i)^2*mu.*(sig1^5./(r(i) - r(i-1)) - sig2^5./(r(i + 1) - r(i)));
        mulimb2     = mulimb2     + r(i)^2*mu.*(sig1^6./(r(i) - r(i-1)) - sig2^6./(r(i + 1) - r(i)));
    end
    
    mulimb = ((1-c1-c2-c3-c4)*lightCurve(indx) + c1*mulimbhalf*dt + c2*mulimb1*dt + ...
        c3*mulimb3half*dt + c4*mulimb2*dt)/omega;
    
    ix1 = find(mulimb+mulimbp ~= 0);
    
    dmumax = max(abs(mulimb(ix1) - mulimbp(ix1))./(mulimb(ix1) + mulimbp(ix1)));
    
    tsec = toc;
    
    if tsec > 10*60 % are we stuck? hard-coded limit = 10 minutes

        save('long_light_curve_calc.mat');
        
        error('dv:computeGeometricLargeBodyTransitLightCurve:takingTooLong', 'compute_geometric_large_body_transit_light_curve:  taking too long');
        
    end
    
end


% lightCurve(indx) = mulimb + (1 - max(mulimb));

% Changed on 04/12/2012. Suggested by CJB.
lightCurve(indx) = mulimb + ( 1 - median( mulimb((end-nVeps+1):end) ) );
lightCurve       = lightCurve(1:nInputArray);

%--------------------------------------------------------------------------
% normalize light curve such that unobscured flux = 0
%--------------------------------------------------------------------------
lightCurve = lightCurve - 1;


% plot limb darkened light curve
if (debugFlag > 1)
    
    %figure;
    hold on;
    
    lightCurveNormalizedToOne = lightCurve + 1;
    
    ldTransitDepth = 1 - min(lightCurveNormalizedToOne);
    ldTransitDepthPpm = ldTransitDepth*1e6;
    
    plot(timestampsInTransit, lightCurveNormalizedToOne, 'b.-')
    
    xlabel('Timestamps in transit (- epoch (BKJD))')
    ylabel('Flux relative to unobscured star')
    title(['Large body light curve, depth = '  num2str(transitDepthPpm) ' ppm, limb-darkened depth = '  num2str(ldTransitDepthPpm) ' ppm'])
    grid on
    
end


return;
