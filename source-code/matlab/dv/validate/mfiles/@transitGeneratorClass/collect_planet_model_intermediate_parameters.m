function intermediateStruct = collect_planet_model_intermediate_parameters(transitModelObject)
% function intermediateStruct = collect_planet_model_intermediate_parameters(transitModelObject)
%
% function to compute or allocate memory for intermediate parameters that
% are needed to compute the light curve, but which are not part of the object
% nor output.
%
%--------------------------------------------------------------------------
% For DV Phase I, we are computing light curves for planetary circular orbits.
% The algorithms herein are designed to accomodate eccentric orbits for future
% DV releases
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

%    2010-May-05, PT:
%        convert from transitEpochMjd to transitEpochBkjd.
% 2009-August-04, PT:
%    undo correction below due to change in how configMapClass time functions operate.
% 2009-August-03, PT:
%    bugfix:  transitModelObject's exposureTimeSec is already the total time (integeration
%    plus readout), no need to add the two to get the total time.
% 2009-July-22, PT:
%    Modified to make minImpactParameter the class member and inclinationDegrees the
%    derived parameter.


%--------------------------------------------------------------------------
% unit conversions
%--------------------------------------------------------------------------
solarRadius2meter  = get_unit_conversion('solarRadius2meter');
au2meter           = get_unit_conversion('au2meter');
cm2meter           = get_unit_conversion('cm2meter');
deg2rad            = get_unit_conversion('deg2rad');
day2sec            = get_unit_conversion('day2sec');
sec2day            = get_unit_conversion('sec2day');
earthRadius2meter  = get_unit_conversion('earthRadius2meter');
hour2sec           = get_unit_conversion('hour2sec');


%--------------------------------------------------------------------------
% extract object parameters
%--------------------------------------------------------------------------
cadenceTimesMjd            = transitModelObject.cadenceTimes;
log10SurfaceGravity        = transitModelObject.log10SurfaceGravity;
planetModel                = transitModelObject.planetModel;
timeParametersStruct       = transitModelObject.timeParametersStruct;


% extract planet model parameters
transitEpochMjd         = planetModel.transitEpochBkjd;
planetRadiusEarthRadii  = planetModel.planetRadiusEarthRadii;
semiMajorAxisAu         = planetModel.semiMajorAxisAu;
minImpactParameter      = planetModel.minImpactParameter ;
starRadiusSolarRadii    = planetModel.starRadiusSolarRadii;
transitDurationHours    = planetModel.transitDurationHours;
transitDepthPpm         = planetModel.transitDepthPpm;
orbitalPeriodDays       = planetModel.orbitalPeriodDays;
eccentricity            = planetModel.eccentricity;
longitudeOfPeriDegrees  = planetModel.longitudeOfPeriDegrees;

% get the inclination angle
inclinationDegrees = compute_inclination_angle( transitModelObject ) ;


% extract time parameters
transitBufferCadences   = timeParametersStruct.transitBufferCadences;
exposureTimeSec         = timeParametersStruct.exposureTimeSec;
readoutTimeSec          = timeParametersStruct.readoutTimeSec;
numExposuresPerCadence  = timeParametersStruct.numExposuresPerCadence;


%--------------------------------------------------------------------------
% convert units to Meters-Kilograms-Seconds (MKS)
%--------------------------------------------------------------------------
cadenceTimesSec         = day2sec * cadenceTimesMjd;

log10SurfaceGravityKicUnits = log10SurfaceGravity + log10(cm2meter); % m/sec^2
surfaceGravityKicUnits  = 10^log10SurfaceGravityKicUnits;

primaryRadiusMeters     = solarRadius2meter * starRadiusSolarRadii;
semiMajorAxisMeters     = au2meter * semiMajorAxisAu;
secondaryRadiusMeters   = earthRadius2meter * planetRadiusEarthRadii;
inclinationRadians      = deg2rad * inclinationDegrees;

transitDurationSec      = hour2sec * transitDurationHours;
transitDurationDays     = sec2day * transitDurationSec;
transitDepth            = transitDepthPpm * 1e6;
orbitalPeriodSec        = day2sec * orbitalPeriodDays;
transitEpochSec         = day2sec * transitEpochMjd;

transitHalfDurationDays = transitDurationDays/2 ;
transitHalfDurationSec  = day2sec * transitHalfDurationDays;


%--------------------------------------------------------------------------
% compute the stellar mass from the surface gravity G*M = g*r^2
%--------------------------------------------------------------------------
gravitationalConstant = get_physical_constants_mks('gravitationalConstant'); % m^3/(kg*s^2)

primaryMassKg = (surfaceGravityKicUnits*primaryRadiusMeters^2)/gravitationalConstant;

% radial distance of closest approach to primary
rPericenterMeters = semiMajorAxisMeters*(1 - eccentricity);

% velocity at closest approach in Cartesian coordinate system in orbital
% plane with pericenter at [x = rPericenterMeters, y = 0]
vPericenterMks = [0, sqrt(gravitationalConstant*primaryMassKg*(1 + eccentricity)/rPericenterMeters)];

if (eccentricity==0)

    % impose pericenter time to equal to mid-transit time
    periCenterTimeSec  = transitEpochSec;

    % impose line of sight angle to equal to zero
    thetaLOS = 0;
else
    error('DV:collect_planet_model_intermediate_parameters:InvalidParameter', ...
        'Eccentric orbits are not supported at this time.');

    % For future DV releases, will need to compute pericenter time and LOS angle
    % to support non-zero eccentricities
end


%--------------------------------------------------------------------------
% compute additional time parameters
%--------------------------------------------------------------------------
exposureTotalTimeSec = exposureTimeSec + readoutTimeSec;

initialTimeMjd  = cadenceTimesMjd(1);
finalTimeMjd    = cadenceTimesMjd(end);

initialTimeSec  = day2sec*initialTimeMjd;
finalTimeSec    = day2sec*finalTimeMjd;

numCadences     = length(cadenceTimesMjd);

cadenceDurationSec     = numExposuresPerCadence*exposureTotalTimeSec;  % = longCadenceDuration, seconds
cadenceDurationDays    = sec2day*cadenceDurationSec;
cadencesPerDay         = 1/cadenceDurationDays;

transitBufferDays  = transitBufferCadences/cadencesPerDay;
transitBufferSecs   = day2sec*transitBufferDays;


%--------------------------------------------------------------------------
% compute mid-transit times for circular orbits (where there should be no
% variation between mid-transit times)
%--------------------------------------------------------------------------
if eccentricity == 0

    [numExpectedTransits, numActualTransits, transitStruct] = ...
        get_number_of_transits_in_time_series(transitModelObject, cadenceTimesMjd);

    transitStartTimesNoBufferMjd = [transitStruct.bkjdTransitStart]';
    transitEndTimesNoBufferMjd   = [transitStruct.bkjdTransitEnd]';

    midTransitTimesMjd     = zeros(numExpectedTransits, 1);
    transitStartTimesDays  = zeros(numExpectedTransits, 1);
    transitEndTimesDays    = zeros(numExpectedTransits, 1);

    for i = 1:numExpectedTransits

        % compute the central transit times
        midTransitTimesMjd(i) = transitEpochMjd + (i - 1)*orbitalPeriodDays; %#ok<AGROW>

        % compute transit start/end times including the buffer
        transitStartTimesDays(i) = midTransitTimesMjd(i) - transitHalfDurationDays - transitBufferDays;
        transitEndTimesDays(i)   = midTransitTimesMjd(i) + transitHalfDurationDays + transitBufferDays;
    end

    % convert to seconds
    midTransitTimesSec           = day2sec*midTransitTimesMjd;
    transitStartTimesNoBufferSec = day2sec*transitStartTimesNoBufferMjd;
    transitEndTimesNoBufferSec   = day2sec*transitEndTimesNoBufferMjd;

    transitStartTimesSec    = day2sec*transitStartTimesDays;
    transitEndTimesSec      = day2sec* transitEndTimesDays;

end

%--------------------------------------------------------------------------
% Save input and computed parameters to intermediate struct
%--------------------------------------------------------------------------

% PLANET AND ORBITAL PARAMETERS
intermediateStruct.secondaryRadiusMeters    = secondaryRadiusMeters;
intermediateStruct.semiMajorAxisMeters      = semiMajorAxisMeters;
intermediateStruct.eccentricity             = eccentricity;
intermediateStruct.inclinationRadians       = inclinationRadians;
intermediateStruct.longitudeOfPeriDegrees   = longitudeOfPeriDegrees;
intermediateStruct.minImpactParameter       = minImpactParameter;
intermediateStruct.orbitalPeriodSec         = orbitalPeriodSec;
intermediateStruct.rPericenterMeters        = rPericenterMeters;
intermediateStruct.vPericenterMks           = vPericenterMks;
intermediateStruct.thetaLOS                 = thetaLOS;

% STAR PARAMETERS
intermediateStruct.surfaceGravityKicUnits   = surfaceGravityKicUnits;
intermediateStruct.primaryMassKg            = primaryMassKg;
intermediateStruct.primaryRadiusMeters      = primaryRadiusMeters;

% TRANSIT PARAMETERS
intermediateStruct.transitEpochSec          = transitEpochSec;
intermediateStruct.transitDurationSec       = transitDurationSec;
intermediateStruct.transitDurationDays      = transitDurationDays;
intermediateStruct.transitHalfDurationSec   = transitHalfDurationSec;
intermediateStruct.transitDepth             = transitDepth;
intermediateStruct.numTransits              = numExpectedTransits;

% TIME PARAMETERS
intermediateStruct.cadenceTimesSec          = cadenceTimesSec;
intermediateStruct.transitBufferDays        = transitBufferDays;
intermediateStruct.transitBufferSecs        = transitBufferSecs;
intermediateStruct.periCenterTimeSec        = periCenterTimeSec;
intermediateStruct.exposureTotalTimeSec     = exposureTotalTimeSec;
intermediateStruct.initialTimeSec           = initialTimeSec;
intermediateStruct.finalTimeSec             = finalTimeSec;
intermediateStruct.numExposuresPerCadence   = numExposuresPerCadence;
intermediateStruct.cadenceDurationDays      = cadenceDurationDays;
intermediateStruct.cadenceDurationSec       = cadenceDurationSec;
intermediateStruct.numCadences              = numCadences;
intermediateStruct.midTransitTimesSec       = midTransitTimesSec;
intermediateStruct.transitStartTimesNoBufferSec = transitStartTimesNoBufferSec;
intermediateStruct.transitEndTimesNoBufferSec   = transitEndTimesNoBufferSec;
intermediateStruct.transitStartTimesSec     = transitStartTimesSec;
intermediateStruct.transitEndTimesSec       = transitEndTimesSec;

%--------------------------------------------------------------------------
% allocate memory for fields that are computed later
%--------------------------------------------------------------------------

% computed in compute_planet_model_times
intermediateStruct.transitExposureStartTimes = [];
intermediateStruct.transitExposureEndTimes   = [];
intermediateStruct.rAtTransit                = [];
intermediateStruct.startTimeMap              = [];
intermediateStruct.transitTimeOffset         = [];

% computed in compute_planet_model_orbit
intermediateStruct.exposureStartPosition     = [];
intermediateStruct.exposureEndPosition       = [];
intermediateStruct.exposureStartImpactParam  = [];
intermediateStruct.exposureEndImpactParam    = [];
intermediateStruct.exposureStartTransitSign  = [];
intermediateStruct.exposureEndTransitSign    = [];

% computed in compute_planet_model_light_curve
intermediateStruct.lightCurveData            = [];


return;
