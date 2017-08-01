function [lightCurve, nonLimbDarkenedTransitDepthPpm, nonLimbDarkenedLightCurve, componentLightCurves] = ...
    compute_large_body_transit_light_curve(transitModelObject, intermediateStruct, impactParameterArray)
% function [lightCurve, nonLimbDarkenedTransitDepthPpm, nonLimbDarkenedLightCurve, componentLightCurves] = ...
%    compute_large_body_transit_light_curve(transitModelObject, intermediateStruct, impactParameterArray)
%
% function to generate a model transit light curve for a given set of star/planet
% parameters and limb-darkening coefficients
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
%   .cadenceTimes               [array] barycentric corrected MJDs
%
%   .limbDarkeningCoefficients         [array] limb darkening coefficients
%
%   .impactParameterArray            [array] impact parameter
%
%   .planetModel
%       .starRadiusMeters       [scalar] stellar radius, meters
%       .planetRadiusMeters     [scalar] planet radius, meters
%
%
% OUTPUTS:
%
%   lightCurve                  light curve (same size as cadenceTimes) that
%                               represents the change in flux relative the the
%                               unobscured flux due to transiting planet
%
%   componentLightCurves        optional output
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

debugFlag              = transitModelObject.debugFlag;

primaryRadiusMeters    = intermediateStruct.primaryRadiusMeters;
secondaryRadiusMeters  = intermediateStruct.secondaryRadiusMeters;

eclipsingObjectNormalizedRadius = secondaryRadiusMeters/primaryRadiusMeters;


% extract limb darkening coefficients
limbDarkeningCoefficients = transitModelObject.limbDarkeningCoefficients;

c1 = limbDarkeningCoefficients(1);
c2 = limbDarkeningCoefficients(2);
c3 = limbDarkeningCoefficients(3);
c4 = limbDarkeningCoefficients(4);


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
%
%--------------------------------------------------------------------------
% generate light curve from uniform source
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
nonLimbDarkenedLightCurve = ...
    get_transit_light_curve_for_uniform_star(impactParameterArray, eclipsingObjectNormalizedRadius);


%--------------------------------------------------------------------------
% Include limb darkening effects
%--------------------------------------------------------------------------
lightCurve = nonLimbDarkenedLightCurve;

depth = max(abs(lightCurve - 1));




if (debugFlag > 2)
    sec2day = get_unit_conversion('sec2day');

    transitExposureStartTimesSec = intermediateStruct.transitExposureStartTimes;
    transitExposureEndTimesSec   = intermediateStruct.transitExposureEndTimes;

    transitExposureStartTimesDays = sec2day*transitExposureStartTimesSec;
    transitExposureEndTimesDays   = sec2day*transitExposureEndTimesSec;

    transitExposureTimesDays = 1/2*(transitExposureStartTimesDays+transitExposureEndTimesDays);

    cadenceMidTimesSec      = intermediateStruct.cadenceTimesSec;
    cadenceMidTimesDays     = sec2day*cadenceMidTimesSec;

    figure;
    plot(transitExposureTimesDays - cadenceMidTimesDays(1), nonLimbDarkenedLightCurve, 'c.')

    xlabel(['Barycentric-corrected MJDs - ' num2str(cadenceMidTimesDays(1))])
    ylabel('Flux relative to unobscured star')
    title(['Non-limb darkened light curve,   Depth = '  num2str(depth*1e6) ' ppm'])
    grid on

end

% output depth of non-limb darkened light curve
nonLimbDarkenedTransitDepthPpm = depth*1e6;

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
%
%  mu = cos(theta) = sqrt(1 - r^2)  where  0 <= r <= 1
%
%  r is the normalized radial coordinate on the disk of the star
%
%--------------------------------------------------------------------------

% define Omega in terms of known limb darkening coeffs 
omega = 4*((1 - c1 - c2 - c3 - c4) / 4 + c1/5 + c2/6 + c3/7 + c4/8);    % check validity of extra 4


%--------------------------------------------------------------------------
% Partition the parameter space in z and p into regions and cases listed in
% Table 1 of MA02
%--------------------------------------------------------------------------
numImpactParamValues = length(impactParameterArray);

indx = find(lightCurve ~= 1);

mulimb          = lightCurve(indx);
mulimbhalf      = mulimb;
mulimb1         = mulimb;
mulimb3half     = mulimb;
mulimb2         = mulimb;

% allocate memory for component light curves
componentLightCurves        = zeros(numImpactParamValues, 5);

componentLightCurves(:, 1)  = componentLightCurves(:,1) + 1;
componentLightCurves(:, 2)  = componentLightCurves(:,2) + 0.8;
componentLightCurves(:, 3)  = componentLightCurves(:,3) + 2/3;  % check on this index (same as #2 in svn) !
componentLightCurves(:, 4)  = componentLightCurves(:,4) + 4/7;
componentLightCurves(:, 5)  = componentLightCurves(:,5) + 0.5;

dt = 1;
nr = 2;
dmumax = 1;
tic;
while (dmumax > depth*1e-3)

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
        mu = get_transit_light_curve_for_uniform_star(impactParameterArray(indx)./r(i),eclipsingObjectNormalizedRadius./r(i));

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

    if toc > 10*60 % are we stuck?

        save('long_light_curve_calc.mat');

        disp('generate_planet_model_light_curve: taking too long');
        break;
    end
end

componentLightCurves(indx,1) = lightCurve(indx);
componentLightCurves(indx,2) = mulimbhalf*dt;
componentLightCurves(indx,3) = mulimb1*dt;
componentLightCurves(indx,4) = mulimb3half*dt;
componentLightCurves(indx,5) = mulimb2*dt;


lightCurve(indx) = mulimb + (1 - max(mulimb));

%--------------------------------------------------------------------------
% normalize light curve such that unobscured flux = 1
%--------------------------------------------------------------------------
lightCurve = lightCurve - 1;

return;
