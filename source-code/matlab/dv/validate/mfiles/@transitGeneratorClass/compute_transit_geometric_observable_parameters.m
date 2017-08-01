function [transitModelObject] = ...
    compute_transit_geometric_observable_parameters(transitModelObject)
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
% 2014-May-20, JL:
%     add algorithms to calculate transit duration and ingress time in
%     corner cases
% 2014-January-23, JL:
%     use accurate formula to calculate transit ingress time
% 2014-January-10, JL:
%     use accurate formula to calculate transit duration
% 2013-December-11, JL:
%     add calculation of effectiveStellarFlux
% 2012-August-23, JL:
%     add calculation of inclination angle and equilibrium temperature
% 2011-August-05, JL:
%     add algorithm to calculate transitIngressTimeDays when minImpactParameter
%     is larger than 1
% 2011-June-06, JL:
%     determine semiMajorAxisAu from orbitalPeriodDays, log10SurfaceGravity and
%     starRadiusSolarRadii based on Kepler's third law, as suggested by Jason.
% 2010-November-17, EQ:
%     updated comments for consistency with other compute_transit*
%     functions in this class
% 2010-November-08, EQ:
%     Initial release


debugFlag = transitModelObject.debugFlag;

% extract input parameters
planetModel = transitModelObject.planetModel;

orbitalPeriodDays               = planetModel.orbitalPeriodDays;
minImpactParameter              = planetModel.minImpactParameter ;
ratioPlanetRadiusToStarRadius   = planetModel.ratioPlanetRadiusToStarRadius;
ratioSemiMajorAxisToStarRadius  = planetModel.ratioSemiMajorAxisToStarRadius;
starRadiusSolarRadii            = planetModel.starRadiusSolarRadii;
log10SurfaceGravity             = transitModelObject.log10SurfaceGravity.value;
smallBodyCutoff                 = transitModelObject.smallBodyCutoff;

%--------------------------------------------------------------------------
% extract unit conversions
%--------------------------------------------------------------------------
day2Hour    = get_unit_conversion('day2hour');
solarRadius = get_physical_constants_mks('solarRadius');
earthRadius = get_physical_constants_mks('earthRadius');
astronomicalUnit = get_physical_constants_mks('astronomicalUnit');


%--------------------------------------------------------------------------
% Transit duration:
%--------------------------------------------------------------------------
% transitDurationDays = orbitalPeriodDays/pi * ...
%     sqrt( (1 + ratioPlanetRadiusToStarRadius)^2 - minImpactParameter^2 ) / ...
%     ratioSemiMajorAxisToStarRadius;

if ( ratioSemiMajorAxisToStarRadius > (1 + ratioPlanetRadiusToStarRadius) )
    
    	transitDurationDays = orbitalPeriodDays/pi * ...
              asin( sqrt( ( (1 + ratioPlanetRadiusToStarRadius)^2 - minImpactParameter^2 ) /        ...
                          ( ratioSemiMajorAxisToStarRadius^2      - minImpactParameter^2 ) ) );
            
else
    
        transitDurationDays = orbitalPeriodDays/2;                                                          % set ratioSemiMajorAxisToStarRadius = (1 + ratioPlanetRadiusToStarRadius)
    
end

% convert to hours for output
transitDurationHours = transitDurationDays * day2Hour;

transitModelObject.planetModel.transitDurationHours = transitDurationHours;

%--------------------------------------------------------------------------
% Ingress time:
%--------------------------------------------------------------------------
% if minImpactParameter<0.999
% 
%     transitIngressTimeDays = orbitalPeriodDays/pi * ratioPlanetRadiusToStarRadius / ...
%         ratioSemiMajorAxisToStarRadius / sqrt( 1 - minImpactParameter^2 );
%     
% else
%    
%     transitIngressTimeDays = 0.5 * orbitalPeriodDays/pi * ...
%         sqrt( (1 + ratioPlanetRadiusToStarRadius)^2 - minImpactParameter^2 ) / ...
%         ratioSemiMajorAxisToStarRadius;
%     
% end

if (ratioPlanetRadiusToStarRadius + minImpactParameter) < 0.999

    if ( ratioSemiMajorAxisToStarRadius > (1 + ratioPlanetRadiusToStarRadius) )
        
        transitIngressTimeDays = orbitalPeriodDays/(2*pi) * ...
            ( asin( sqrt( ( (1 + ratioPlanetRadiusToStarRadius)^2 - minImpactParameter^2 ) /        ...
                          ( ratioSemiMajorAxisToStarRadius^2      - minImpactParameter^2 ) ) ) -    ...
              asin( sqrt( ( (1 - ratioPlanetRadiusToStarRadius)^2 - minImpactParameter^2 ) /        ...
                          ( ratioSemiMajorAxisToStarRadius^2      - minImpactParameter^2 ) ) ) );

    else
        
        transitIngressTimeDays = orbitalPeriodDays/(2*pi) * ...
            ( pi/2                                                                             -    ...
              asin( sqrt( ( (1 - ratioPlanetRadiusToStarRadius)^2 - minImpactParameter^2 ) /        ...
                          ( (1 + ratioPlanetRadiusToStarRadius)^2 - minImpactParameter^2 ) ) ) );           % set ratioSemiMajorAxisToStarRadius = (1 + ratioPlanetRadiusToStarRadius)
            
    end
    
else
   
    if ( ratioSemiMajorAxisToStarRadius > (1 + ratioPlanetRadiusToStarRadius) )

        transitIngressTimeDays = orbitalPeriodDays/(2*pi) * ...
            asin( sqrt( ( (1 + ratioPlanetRadiusToStarRadius)^2 - minImpactParameter^2 ) /        ...
                        ( ratioSemiMajorAxisToStarRadius^2      - minImpactParameter^2 ) ) );
                    
    else
        
        transitIngressTimeDays = orbitalPeriodDays/4;                                                       % set ratioSemiMajorAxisToStarRadius = (1 + ratioPlanetRadiusToStarRadius)
        
    end
    
end

% convert to hours for output
transitIngressTimeHours = transitIngressTimeDays * day2Hour;

transitModelObject.planetModel.transitIngressTimeHours = transitIngressTimeHours;

%--------------------------------------------------------------------------
% Planet Radius:
%--------------------------------------------------------------------------
planetRadiusEarthRadii  = ratioPlanetRadiusToStarRadius * starRadiusSolarRadii * ...
    solarRadius/earthRadius;

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

%--------------------------------------------------------------------------
% Transit depth:
%--------------------------------------------------------------------------
transitDepth = get_geometric_limb_darkened_transit_depth(transitModelObject) ;

% convert to ppm for output
transitDepthPpm  = transitDepth*1e6;

transitModelObject.planetModel.transitDepthPpm = transitDepthPpm;

%--------------------------------------------------------------------------
% Inclination angle:
%--------------------------------------------------------------------------
inclinationDegrees = compute_inclination_angle_with_geometric_model( transitModelObject ) ;

transitModelObject.planetModel.inclinationDegrees = inclinationDegrees;

%--------------------------------------------------------------------------
% Equilibrium temperature:
%--------------------------------------------------------------------------
equilibriumTempKelvin = compute_equilibrium_temperature_value( transitModelObject ) ;

transitModelObject.planetModel.equilibriumTempKelvin = equilibriumTempKelvin;

%--------------------------------------------------------------------------
% Effective stellar flux:
%--------------------------------------------------------------------------
effectiveStellarFlux = compute_effective_stellar_flux_value( transitModelObject ) ;

transitModelObject.planetModel.effectiveStellarFlux = effectiveStellarFlux;

%--------------------------------------------------------------------------
% display results if debug flag is set
%--------------------------------------------------------------------------
if (debugFlag > 1)

    disp(' ')
    disp(['The stellar logg is   ' num2str(log10SurfaceGravity) ' ']) ;
    disp(['The stellar radius is ' num2str(starRadiusSolarRadii) ' Solar radii']) ;
    disp(['The orbital period is ' num2str(orbitalPeriodDays) ' days']) ;
    disp(['The min impact parameter is ' num2str(minImpactParameter) ' ']) ;
    disp(['The semimajor axis to star radius ratio is ' num2str(ratioSemiMajorAxisToStarRadius) ' ']) ;
    disp(' ')

    disp(['The planet-star radius ratio is ' num2str(ratioPlanetRadiusToStarRadius) ' ']) ;
    disp(['The small body cutoff is ' num2str(smallBodyCutoff) ' Earth radii'])

    disp(' ')
    disp(['The computed depth is          ' num2str(transitDepthPpm) ' ppm']) ;
    disp(['The computed duration is       ' num2str(transitDurationHours) ' hours']) ;
    disp(['The computed ingress time is   ' num2str(transitIngressTimeHours),' hours']) ;
    disp(['The computed semimajor axis is ' num2str(semiMajorAxisAu) ' AU'])
    disp(['The computed planet radius is  ' num2str(planetRadiusEarthRadii) ' Earth radii'])   
end


return;

