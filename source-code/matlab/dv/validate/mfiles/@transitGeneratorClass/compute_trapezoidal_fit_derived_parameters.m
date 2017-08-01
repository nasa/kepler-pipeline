function [transitModelObject] = compute_trapezoidal_fit_derived_parameters(transitModelObject)
%
% [transitModelObject] = ...
%       compute_transit_geometric_physical_parameters(transitModelObject)
%
% function to compute geometric observable transit parameter values from the
% fitted (physical) parameters.  The computed values are added to the planet
% model struct of the transit model object.
%
%
% INPUTS:
%
%   transitModelObject populated with the following fields:
%
%   planetModel =
%
%     transitEpochBkjd       [scalar] barycentric-corrected time to first mid-transit (BKJD)
%     eccentricity           [scalar] planet orbital eccentricity (dimensionless)
%     longitudeOfPeriDegrees [scalar] planet longitude of periastron (degrees)
%     minImpactParameter     [scalar] minimum impact parameter (dimensionless)
%     orbitalPeriodDays      [scalar] period between detected transits (days)
%     ratioPlanetRadiusToStarRadius  [scalar] planet radius normalized by star radius
%     ratioSemiMajorAxisToStarRadius [scalar] semimajor axis normalized by star radius
%     starRadiusSolarRadii   [scalar] star radius estimate from the KIC
%
% OUTPUTS:
%
%   additional fields in the planetModel struct:
%
%       transitDurationHours    [scalar] transit duration (hours)
%       transitIngressTimeHours [scalar] transit ingress time (hours)
%       transitDepthPpm         [scalar] transit depth (ppm)
%       planetRadiusEarthRadii  [scalar] planet radius (Earth radii)
%       semiMajorAxisAu         [scalar] planet semimajor axis (AU)
%       inclinationDegrees      [scalar] inclination angle (degrees)
%       equilibriumTempKelvin   [scalar] planet equilibrium temperature (Kelvin)
%       effectiveStellarFlux    [scalar] planet effective stellar flux (dimensionless)
%
% Version date:  2014-May-20.
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


% extract input parameters
planetModel = transitModelObject.planetModel;

orbitalPeriodDays               = planetModel.orbitalPeriodDays;
starRadiusSolarRadii            = planetModel.starRadiusSolarRadii;
log10SurfaceGravity             = transitModelObject.log10SurfaceGravity.value;

%--------------------------------------------------------------------------
% extract unit conversions
%--------------------------------------------------------------------------
day2Hour         = get_unit_conversion('day2hour');
solarRadius      = get_physical_constants_mks('solarRadius');
earthRadius      = get_physical_constants_mks('earthRadius');
astronomicalUnit = get_physical_constants_mks('astronomicalUnit');

littleTDays      = planetModel.transitIngressTimeHours / day2Hour;
bigTDays         = planetModel.transitDurationHours / day2Hour + littleTDays; 

ratioPlanetRadiusToStarRadius   = sqrt( planetModel.transitDepthPpm/1e6 );
minImpactParameter              = sqrt( 1.0 - min([ratioPlanetRadiusToStarRadius*bigTDays/littleTDays; 1.0]) );
tau0                            = sqrt(bigTDays*littleTDays/4.0/ratioPlanetRadiusToStarRadius); 

transitModelObject.planetModel.ratioPlanetRadiusToStarRadius    = ratioPlanetRadiusToStarRadius;
transitModelObject.planetModel.minImpactParameter               = minImpactParameter;
transitModelObject.planetModel.ratioSemiMajorAxisToStarRadius   = orbitalPeriodDays/2.0/pi/tau0;

%--------------------------------------------------------------------------
% Planet Radius:
%--------------------------------------------------------------------------
planetRadiusEarthRadii  = ratioPlanetRadiusToStarRadius * starRadiusSolarRadii * solarRadius/earthRadius;
transitModelObject.planetModel.planetRadiusEarthRadii = planetRadiusEarthRadii;

%--------------------------------------------------------------------------
% Semi-major axis:
%--------------------------------------------------------------------------
% semiMajorAxisAu = ratioSemiMajorAxisToStarRadius * starRadiusSolarRadii * ...
%     solarRadius/astronomicalUnit;

% 2011-June-06, JL:
% Determine semiMajorAxisAu from orbitalPeriodDays, log10SurfaceGravity and
% starRadiusSolarRadii based on Kepler's third law, as suggested by Jason.

orbitalPeriodMks     = orbitalPeriodDays              * get_unit_conversion('day2sec');
starRadiusMks        = starRadiusSolarRadii           * get_unit_conversion('solarRadius2meter');
gMks                 = 10^(log10SurfaceGravity)       * get_unit_conversion('cm2meter');
semiMajorAxisMks     = (orbitalPeriodMks * starRadiusMks * sqrt(gMks) / 2 / pi)^(2/3);
semiMajorAxisAu      = semiMajorAxisMks/astronomicalUnit;

transitModelObject.planetModel.semiMajorAxisAu = semiMajorAxisAu;

transitModelObject.planetModel.inclinationDegrees    =  0;
transitModelObject.planetModel.equilibriumTempKelvin =  0;
transitModelObject.planetModel.effectiveStellarFlux  =  0;


return;

