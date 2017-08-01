function [transitModelObject] = compute_transit_observable_parameters(transitModelObject)
%
% [transitModelObject] = compute_transit_observable_parameters(transitModelObject)
%
% function to compute observable transit parameter values from the fitted
% (physical) parameters.  The computed values are added to the planet model
% struct of the transit model object.
%
%
% INPUTS:
%
%   transitModelObject populated with the following fields:
%
%   log10SurfaceGravity         [scalar] log stellar surface gravity (cm/sec^2)
%
%   planetModel =
%
%       transitEpochMjd         [scalar] barycentric-corrected time to first transit, MJD
%       eccentricity            [scalar] planet orbital eccentricity (dimensionless)
%       longitudeOfPeriDegrees  [scalar] planet longitude of periastron (degrees)
%       planetRadiusEarthRadii  [scalar] planet radius (Earth radii)
%       semiMajorAxisAu         [scalar] planet semimajor axis (AU)
%       minImpactParameter      [scalar] minimum impact parameter (dimensionless)
%       starRadiusSolarRadii    [scalar] star radius (solar radii)
%
%
% OUTPUTS:
%
%   additional fields in the planetModel struct:
%
%       transitDurationHours    [scalar] transit duration (hours)
%       transitIngressTimeHours [scalar] transit ingress time (hours)
%       transitDepthPpm         [scalar] transit depth (ppm)
%       orbitalPeriodDays       [scalar] planet orbital period (days)
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
% 2010-November-17, EQ:
%     updated comments for consistency with other compute_transit*
%     functions in this class
% 2009-September-14, PT:
%     support for putting the limb-darkened transit depth into the planet model
%     rather than the ratio of the square of the radii.
% 2009-August-18, PT:
%     use separate method to do Kepler's third law calculation
% 2009-July-28, EQ:
%     include eccentricity and longitude of periastron in planetModel
% 2009-July-22, PT:
%     change from inclinationDegrees to minImpactParameter in the planetModel.
%
%=========================================================================================


debugFlag = transitModelObject.debugFlag;

% extract physical/fitted input parameters
log10SurfaceGravity     = transitModelObject.log10SurfaceGravity;
planetModel             = transitModelObject.planetModel;

planetRadiusEarthRadii  = planetModel.planetRadiusEarthRadii;
semiMajorAxisAu         = planetModel.semiMajorAxisAu;
minImpactParameter      = planetModel.minImpactParameter;   % dimensionless
starRadiusSolarRadii    = planetModel.starRadiusSolarRadii;


%--------------------------------------------------------------------------
% extract unit conversions
%--------------------------------------------------------------------------
earthRadius2meter = get_unit_conversion('earthRadius2meter');
solarRadius2meter = get_unit_conversion('solarRadius2meter');
au2meter          = get_unit_conversion('au2meter');
cm2meter          = get_unit_conversion('cm2meter');
sec2hour          = get_unit_conversion('sec2hour');

planetRadiusMeters  = planetRadiusEarthRadii*earthRadius2meter;
semiMajorAxisMeters = semiMajorAxisAu*au2meter;
starRadiusMeters    = starRadiusSolarRadii*solarRadius2meter;

log10SurfaceGravityKicUnits  = log10SurfaceGravity + log10(cm2meter); % m/sec^2
surfaceGravityKicUnits       = 10^log10SurfaceGravityKicUnits;

% compute the product of impact parameter ('b') and star radius
bMeters = starRadiusMeters * minImpactParameter ;


%--------------------------------------------------------------------------
% Orbital period:
%
% estimate from the planet semimajor axis, the surface gravity, and the
% stellar radius:
%
% period = (2 * pi * a^(3/2)) / sqrt(G*M),  where G*M = g * R_star^2
%--------------------------------------------------------------------------
periodDays = kepler_third_law(transitModelObject, semiMajorAxisAu, ...
    starRadiusSolarRadii, []) ;

transitModelObject.planetModel.orbitalPeriodDays = periodDays;


%--------------------------------------------------------------------------
% Transit duration:
%
% estimate from the star and planet radii, the semimajor axis, the surface
% gravity, and the orbital inclination.
%
% transitDuration = distance the planet travels across star disk / orbital velocity
%
%
%  (1)    (distance/2)^2  +  b^2  =  (r_star + r_planet)^2
%
%  (2)    velocity  =  sqrt((G*M)/a)  =  sqrt((g * r_star^2)/a)
%
%
%  dividing (1) by (2):
%
%  transitDuration = 2 * sqrt( a/(g*r_star^2) *((r_star + r_planet)^2 - b^2  ))
%--------------------------------------------------------------------------
transitDurationSec = 2 * sqrt( ...
    semiMajorAxisMeters / (surfaceGravityKicUnits*starRadiusMeters^2) * ...
    ((planetRadiusMeters + starRadiusMeters)^2 - bMeters^2));

% convert to hours for output
transitDurationHours = transitDurationSec*sec2hour;

transitModelObject.planetModel.transitDurationHours = transitDurationHours;


%--------------------------------------------------------------------------
% Transit depth:
%
% estimate from the light curve itself
%--------------------------------------------------------------------------
transitDepth = get_limb_darkened_transit_depth(transitModelObject) ;

% convert to ppm for output
transitDepthPpm  = transitDepth*1e6;

transitModelObject.planetModel.transitDepthPpm = transitDepthPpm;


%--------------------------------------------------------------------------
% Transit ingress time:
%--------------------------------------------------------------------------
transitIngressTimeSeconds = compute_transit_ingress_time(planetRadiusMeters, ...
    starRadiusMeters, semiMajorAxisMeters, minImpactParameter, transitDurationSec, ...
    surfaceGravityKicUnits) ;

% convert to hours for output
transitIngressTimeHours = transitIngressTimeSeconds * sec2hour ;

transitModelObject.planetModel.transitIngressTimeHours   = transitIngressTimeHours;


%--------------------------------------------------------------------------
% display results if debug flag is set
%--------------------------------------------------------------------------
if (debugFlag > 1)
    disp(['The computed orbital period is       ' num2str(periodDays) ' days'])
    disp(['The computed transit depth is        ' num2str(transitDepthPpm) ' ppm'])
    disp(['The computed transit duration is     ' num2str(transitDurationHours) ' hours'])
    disp(['The computed transit ingress time is ' num2str(transitIngressTimeHours) ' hours'])
end


return;

