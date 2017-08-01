function [transitModelObject] = ...
    compute_transit_parameters_from_tps_instantiation(transitModelObject )
%
% transitModelObject = ...
%   compute_transit_parameters_from_tps_instantiation(transitModelObject )
%
% function to fill in missing transit model parameters from parameters used
% in a TPS-based instantiation.
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
%       minImpactParameter      [scalar] minimum impact parameter (dimensionless)
%       starRadiusSolarRadii    [scalar] star radius (solar radii)
%       transitDepthPpm         [scalar] transit depth (ppm)
%       orbitalPeriodDays       [scalar] planet orbital period (days)
%
%
% OUTPUTS:
%
%   additional fields in the planetModel struct:
%
%       planetRadiusEarthRadii  [scalar] planet radius (Earth radii)
%       semiMajorAxisAu         [scalar] planet semimajor axis (AU)
%       transitDurationHours    [scalar] transit duration (hours)
%       transitIngressTimeHours [scalar] transit ingress time (hours)
%       effectiveStellarFlux    [scalar] planet effective stellar flux (dimensionless)
%
%
% This method is intended as a special case for use when the transitGeneratorClass object
%    has been instantiated from a TPS threshold-crossing event, in which case we have the
%    transit depth, duration, and period from TPS and the star radius from KIC.
%
% Version date:  2014-January-8.
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

% Modification History:
%
%    2014-January-8, SS:
%        add calculation of effectiveStellarFlux
%    2010-November-17, EQ:
%        updated comments for consistency with other compute_transit*
%        functions in this class
%    2009-October-16, PT:
%        add iteration count limit to planet-radius loop.
%    2009-September-14, PT:
%        switch to use of limb-darkened transit depth.
%    2009-August-18, PT:
%        switch to separate method for Kepler's 3rd law calculation
%    2009-July-28, EQ:
%        include eccentricity and longitude of periastron in planetModel
%    2009-July-27, PT:
%        eliminate use of transit duration as an input parameter.
%    2009-July-22, PT:
%        switch from inclinationDegrees to minImpactParameter in planetModel.
%
%=========================================================================================


debugFlag = transitModelObject.debugFlag;

% extract observable input parameters
log10SurfaceGravity  = transitModelObject.log10SurfaceGravity.value ;
planetModel          = transitModelObject.planetModel;

minImpactParameter   = planetModel.minImpactParameter ; % dimensionless
transitDepthPpm      = planetModel.transitDepthPpm;
orbitalPeriodDays    = planetModel.orbitalPeriodDays;
starRadiusSolarRadii = planetModel.starRadiusSolarRadii;


%--------------------------------------------------------------------------
% extract unit conversions
%--------------------------------------------------------------------------
hour2sec            = get_unit_conversion('hour2mks');
sec2hour            = 1 / hour2sec ;
cm2meter            = get_unit_conversion('cm2meter');
solarRadius2meter   = get_unit_conversion('solarRadius2meter');
au2meter            = get_unit_conversion('au2meter') ;
meter2earthRadius   = get_unit_conversion('meter2earthRadius');

transitDepth        = transitDepthPpm/1e6;
starRadiusMeters    = solarRadius2meter*starRadiusSolarRadii;

log10SurfaceGravityKicUnits = log10SurfaceGravity + log10(cm2meter); % m/sec^2
surfaceGravityKicUnits      = 10^log10SurfaceGravityKicUnits;


%--------------------------------------------------------------------------
% Semimajor axis:
%
% estimate from the orbital period
%
% period = (2 * pi * a^(3/2)) / sqrt(G*M),  where G*M = g * R_star^2
%--------------------------------------------------------------------------
semiMajorAxisAu = kepler_third_law(transitModelObject, [], starRadiusSolarRadii, ...
    orbitalPeriodDays);

% convert to mks for transit duration calculation
semiMajorAxisMeters = semiMajorAxisAu * au2meter;

transitModelObject.planetModel.semiMajorAxisAu = semiMajorAxisAu;
transitModelObject.planetModel.ratioSemiMajorAxisToStarRadius = ...
    semiMajorAxisMeters / starRadiusMeters ;


%--------------------------------------------------------------------------
% In order to get the rest of the parameters starting from the limb-darkened
% transit depth, we must iterate the calculation until the model depth agrees
% with the requested depth.
%---------------------------------------------------------------------------
fitterOptions = kepler_set_soc('nlinfit');
maxIter = fitterOptions.MaxIter;

transitDepthScaleFactor = 1;
modelTransitDepth = 0;
transitDepthTolerance = 1e-10;

if (transitDepth ~= 0)
    transitDepthAgreement = abs((transitDepth-modelTransitDepth)/transitDepth);
else
    transitDepthAgreement = 1;
end

nIter = 0 ;
while transitDepthAgreement > transitDepthTolerance && nIter < maxIter
    
    %--------------------------------------------------------------------------
    % Planet radius:
    %
    % estimate from the transit depth and star radius:
    %--------------------------------------------------------------------------
    planetRadiusMeters = sqrt(transitDepth * transitDepthScaleFactor * starRadiusMeters^2);
    
    % convert to Earth radii for output
    planetRadiusEarthRadii = planetRadiusMeters*meter2earthRadius;
    
    transitModelObject.planetModel.planetRadiusEarthRadii  = planetRadiusEarthRadii;
    transitModelObject.planetModel.ratioPlanetRadiusToStarRadius = ...
        planetRadiusMeters / starRadiusMeters ;
    
    
    
    %--------------------------------------------------------------------------
    % Transit duration:
    %
    % estimate thusly (note that we currently force the impact parameter
    % to zero, but that may change)
    %
    %  transitDuration = 2 * sqrt( a/(g*r_star^2) *((r_star + r_planet)^2 - (im*r_star)^2  ))
    %--------------------------------------------------------------------------
    transitDurationSec = 2 * sqrt(  semiMajorAxisMeters / ...
        (surfaceGravityKicUnits*starRadiusMeters^2) * ...
        ((planetRadiusMeters + starRadiusMeters)^2 - ...
        (minImpactParameter * starRadiusMeters)^2));
    
    % convert to hours for output
    transitDurationHours = transitDurationSec * sec2hour;
    
    transitModelObject.planetModel.transitDurationHours  = transitDurationHours;
    
    
    %--------------------------------------------------------------------------
    % Transit ingress time:
    %--------------------------------------------------------------------------
    transitIngressTimeSeconds = compute_transit_ingress_time(planetRadiusMeters, ...
        starRadiusMeters, semiMajorAxisMeters, minImpactParameter, transitDurationSec, ...
        surfaceGravityKicUnits) ;
    
    % convert to hours for output
    transitIngressTimeHours = transitIngressTimeSeconds * sec2hour;
    
    transitModelObject.planetModel.transitIngressTimeHours = transitIngressTimeHours;
    
    
    
    % compute the model transit depth and compare to the requested
    modelTransitDepth = get_limb_darkened_transit_depth(transitModelObject) ;
    
    
    % estimate the scale factor needed to get the planet radius to produce the correct
    % transit depth.  Note that if the requested transit depth is zero, that is a
    % special case and must be handled carefully
    if (transitDepth ~= 0)
        transitDepthAgreement = abs((transitDepth-modelTransitDepth)/transitDepth) ;
        transitDepthScaleFactor = transitDepthScaleFactor * transitDepth / modelTransitDepth;
    else
        transitDepthAgreement = 0;
        transitDepthScaleFactor = 1;
    end
    
    nIter = nIter + 1 ;
    
end % while transit depths out of tolerance with each other

% if we are exiting due to iteration count exhausted, issue a warning
if (transitDepthAgreement > transitDepthTolerance)
    warning('dv:computeTransitParametersFromTpsInstantiation:iterLimitExceeded', ...
        ['Iteration limit in computing planet radius exhausted, transit depth agreement == ', ...
        num2str(transitDepthAgreement)]);
end

% inclination angle and equilibrium temperature

transitModelObject.planetModel.inclinationDegrees = ...
    compute_inclination_angle_with_geometric_model( transitModelObject ) ;
transitModelObject.planetModel.equilibriumTempKelvin = ...
    compute_equilibrium_temperature_value( transitModelObject ) ;

%--------------------------------------------------------------------------
% Effective stellar flux:
%--------------------------------------------------------------------------
effectiveStellarFlux = compute_effective_stellar_flux_value(transitModelObject) ;
transitModelObject.planetModel.effectiveStellarFlux = effectiveStellarFlux ;

%--------------------------------------------------------------------------
% display results if debug flag is set
%--------------------------------------------------------------------------
if (debugFlag > 1)
    disp(['The computed semimajor axis is  ' num2str(semiMajorAxisAu) ' AU'])
    disp(['The computed planet radius is   ' num2str(planetRadiusEarthRadii) ' Earth radii'])
    disp(['The transit duration is         ' num2str(transitDurationHours) ' hours']) ;
    disp(['The computed ingress time is    ' num2str(transitIngressTimeHours),' hours']) ;
end


return;

