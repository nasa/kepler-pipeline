function [transitModelObject] = compute_transit_physical_parameters(transitModelObject)
%
% [transitModelObject] = compute_transit_physical_parameters(transitModelObject)
%
% function to compute physical transit parameter values from the observed
% parameters.  The computed values are added to the planet model
% struct in the transit model object.
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
%       transitEpochMjd         [scalar] barycentric-corrected time to first mid-transit (MJD)
%       eccentricity            [scalar] planet orbital eccentricity (dimensionless)
%       longitudeOfPeriDegrees  [scalar] planet longitude of periastron (degrees)
%       transitDurationHours    [scalar] transit duration (hours)
%       transitIngressTimeHours [scalar] transit ingress time (hours)
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
%       minImpactParameter      [scalar] minimum impact parameter (dimensionless)
%       starRadiusSolarRadii    [scalar] star radius (solar radii)
%
% This function makes extensive use of Seager and Mallen-Ornelas, "On the Unique Solution
% of Planet and Star Parameters from an Extrasolar Planet Transit Light Curve"
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
%    2010-November-17, EQ:
%        updated comments for consistency with other compute_transit*
%        functions in this class
%    2009-September-15, PT:
%        make the transit depth equal to the true limb-darkened transit depth.
%    2009-July-28, EQ:
%        include eccentricity and longitude of periastron in planetModel
%    2009-July-22, PT:
%        change from inclinationDegrees to minImpactParameter in planetModel
%
%=========================================================================================


debugFlag = transitModelObject.debugFlag;

% extract observable input parameters
log10SurfaceGravity      = transitModelObject.log10SurfaceGravity;
planetModel              = transitModelObject.planetModel;

transitDurationHours     = planetModel.transitDurationHours;
transitIngressTimeHours  = planetModel.transitIngressTimeHours;
transitDepthPpm          = planetModel.transitDepthPpm;
orbitalPeriodDays        = planetModel.orbitalPeriodDays;


%--------------------------------------------------------------------------
% extract unit conversions
%--------------------------------------------------------------------------
hour2sec          = get_unit_conversion('hour2mks');
day2sec           = get_unit_conversion('day2mks');
cm2meter          = get_unit_conversion('cm2meter');
meter2solarRadius = get_unit_conversion('meter2solarRadius');
meter2earthRadius = get_unit_conversion('meter2earthRadius');
meter2au          = get_unit_conversion('meter2au');


transitDurationSec    = hour2sec * transitDurationHours;
orbitalPeriodSec      = day2sec  * orbitalPeriodDays;
transitDepth          = transitDepthPpm/1e6;
transitIngressTimeSec = hour2sec * transitIngressTimeHours;

log10SurfaceGravityKicUnits = log10SurfaceGravity + log10(cm2meter); % m/sec^2
surfaceGravityKicUnits      = 10^log10SurfaceGravityKicUnits;


%--------------------------------------------------------------------------
% compute physical parameters:
%
% First compute the S+MO derived parameters (planet-star radius ratio, impact
% parameter, star-orbit ratio.  Note that S+MO do not include the effect of
% limb-darkening in their estimates; in order for us to include that, we must
% iteratively compute the parameters, examine the effective transit depth,
% and scale the transit depth used in the calculation
%--------------------------------------------------------------------------
limbDarkeningFactor = 1;
transitDepthTolerance = 1e-10;
converged = false;

while ~converged
    
    %--------------------------------------------------------------------------
    % Minimum impact parameter:
    %--------------------------------------------------------------------------
    rRatio = sqrt(transitDepth * limbDarkeningFactor);
    
    minImpactParameter = compute_min_impact_parameter_from_observables(rRatio^2, ...
        transitDurationSec, transitIngressTimeSec, orbitalPeriodSec, true);
    
    transitModelObject.planetModel.minImpactParameter = minImpactParameter;
    
    
    %--------------------------------------------------------------------------
    % Semi-major axis:
    %
    % derive from Kepler's Third law and aOverR -- note that S+MO don't do
    % this because they assume that the mass and the surface gravity of the
    % star are unknown
    %--------------------------------------------------------------------------
    aOverR = compute_semimajor_axis_from_observables(rRatio^2, ...
        minImpactParameter, transitDurationSec, orbitalPeriodSec, true);
    
    semiMajorAxisMeters = orbitalPeriodSec^2 / aOverR^2 * surfaceGravityKicUnits / (4*pi^2);
    
    % convert to AU for output
    transitModelObject.planetModel.semiMajorAxisAu = semiMajorAxisMeters * meter2au;
    
    
    %--------------------------------------------------------------------------
    % Star radius:
    %--------------------------------------------------------------------------
    starRadiusMeters = semiMajorAxisMeters / aOverR;
    
    % convert to Solar radii for output
    transitModelObject.planetModel.starRadiusSolarRadii = starRadiusMeters * meter2solarRadius;
    
    
    %--------------------------------------------------------------------------
    % Planet radius:
    %--------------------------------------------------------------------------
    planetRadiusMeters = starRadiusMeters * rRatio;
    
    % convert to Earth radii for output
    transitModelObject.planetModel.planetRadiusEarthRadii = planetRadiusMeters * meter2earthRadius;
    
    
    
    % get the actual transit depth given by this model
    modelTransitDepth = get_limb_darkened_transit_depth(transitModelObject);
    
    % adjust the scaling factor and determine whether convergence has occurred
    if (transitDepth ~= 0)
        limbDarkeningFactor = limbDarkeningFactor * abs(transitDepth / modelTransitDepth);
        converged = abs((transitDepth-modelTransitDepth)/transitDepth) < transitDepthTolerance;
    else
        converged = true ;
    end
    
end % while not converged


%--------------------------------------------------------------------------
% display results if debug flag is set
%--------------------------------------------------------------------------
if (debugFlag > 1)
    disp(['The computed semimajor axis is      ' num2str(planetModel.semiMajorAxisAu) ' AU'])
    disp(['The computed planet radius is       ' num2str(planetModel.planetRadiusEarthRadii) ' Earth radii'])
    disp(['The computed minimumImpactParameter is ' num2str(planetModel.minImpactParameter) ])
    disp(['The computed star radius is         ' num2str(planetModel.starRadiusSolarRadii) ' Solar radii'])
end

return;

