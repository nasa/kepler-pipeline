function intermediateStruct = collect_binary_model_intermediate_parameters(transitModelObject, debugFlag)
% function intermediateStruct = collect_binary_model_intermediate_parameters(transitModelObject, debugFlag)
%
% function to compute or allocate memory for intermediate parameters that
% are needed to compute the light curve, but which are not part of the object
% nor output.
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

%--------------------------------------------------------------------------
% Parameters to add to inputs
%--------------------------------------------------------------------------

% set the following parameter for circular orbit
if ~isfield(transitModelObject, 'eccentricity')
    eccentricity = 0;
end

% set the following parameter for circular orbit
if ~isfield(transitModelObject, 'longitudeOfPeri')
    longitudeOfPeri = 0;
end

% include cadences to add to each side of a transit if not available
if ~isfield(transitModelObject, 'transitTimeBufferCadences')
    transitTimeBufferCadences = 1;
end

% include integration time if not available
if ~isfield(transitModelObject, 'integrationTimeSec')
    integrationTimeSec = 6.12361;
end

% include transfer time if not available
if ~isfield(transitModelObject, 'transferTimeSec')
    transferTimeSec =  0.51895;
end

% include #exposures per short cadence if not available
if ~isfield(transitModelObject, 'exposuresPerShortCadence')
    exposuresPerShortCadence =  9;
end

% include #shorts per long cadence if not available
if ~isfield(transitModelObject, 'shortsPerLongCadence')
    shortsPerLongCadence =  30;
end


%--------------------------------------------------------------------------
% unit conversions
%--------------------------------------------------------------------------
solarRadius2meter  = get_unit_conversion('solarRadius2meter');
au2meter           = get_unit_conversion('au2meter');
cm2meter           = get_unit_conversion('cm2meter');
deg2rad            = get_unit_conversion('deg2rad');
rad2deg            = get_unit_conversion('rad2deg');
day2sec            = get_unit_conversion('day2sec');
sec2day            = get_unit_conversion('sec2day');
earthRadius2meter  = get_unit_conversion('earthRadius2meter');
hour2sec           = get_unit_conversion('hour2sec');


%--------------------------------------------------------------------------
% extract object parameters
%--------------------------------------------------------------------------
cadenceTimesMjd         = transitModelObject.cadenceTimes;

log10SurfaceGravity     = transitModelObject.log10SurfaceGravity;
binaryModel             = transitModelObject.binaryModel;

primaryRadiusSolarRadii   = binaryModel.primaryRadiusSolarRadii;
transitEpochMjd           = binaryModel.transitEpochMjd;
semiMajorAxisAu           = binaryModel.semiMajorAxisAu;
inclinationDegrees        = binaryModel.inclinationDegrees;
secondaryRadiusSolarRadii = binaryModel.secondaryRadiusSolarRadii;

transitDurationHours    = binaryModel.transitDurationHours;
transitDepthPpm         = binaryModel.transitDepthPpm;
orbitalPeriodDays       = binaryModel.orbitalPeriodDays;


%--------------------------------------------------------------------------
% convert units to Meters-Kilograms-Seconds (MKS)
%--------------------------------------------------------------------------
cadenceTimesSec             = day2sec * cadenceTimesMjd;

log10SurfaceGravityKicUnits = log10SurfaceGravity + log10(cm2meter); % m/sec^2
surfaceGravityKicUnits      = 10^log10SurfaceGravityKicUnits;

primaryRadiusMeters         = solarRadius2meter * primaryRadiusSolarRadii;
semiMajorAxisMeters         = au2meter * semiMajorAxisAu;
secondaryRadiusMeters       = earthRadius2meter * secondaryRadiusSolarRadii;
inclinationRadians          = deg2rad * inclinationDegrees;

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

secondaryMassKg      = transitModelObject.secondaryMassKg;
primaryLuminosity    = transitModelObject.primaryLuminosity;
secondaryLuminosity  = transitModelObject.secondaryLuminosity;

primaryMassKg = (surfaceGravityKicUnits*primaryRadiusMeters^2)/gravitationalConstant;

% use reduced mass for eclipsing binaries
centralMassKg        = (primaryMassKg*secondaryMassKg)/(primaryMassKg + secondaryMassKg);


% radial distance of closest approach to primary
rPericenterMeters = semiMajorAxisMeters*(1 - eccentricity);

% velocity at closest approach in Cartesian coordinate system in orbital
% plane with pericenter at [x = rPericenterMeters, y = 0]
vPericenterMks = [0, sqrt(gravitationalConstant*centralMassKg*(1 + eccentricity)/rPericenterMeters)];

% compute the minimum impact parameter
minImpactParameter = (semiMajorAxisMeters/primaryRadiusMeters)*cos(inclinationRadians);


if (eccentricity==0)

    % impose pericenter time to equal to mid-transit time
    periCenterTimeSec  = transitEpochSec;

    % impose line of sight angle to equal to zero
    thetaLOS = 0;
else
    % compute pericenter time and LOS angle
end



%--------------------------------------------------------------------------
% compute additional time parameters
%--------------------------------------------------------------------------
exposureTotalTimeSec      = integrationTimeSec + transferTimeSec;

initialTimeMjd  = cadenceTimesMjd(1);
finalTimeMjd    = cadenceTimesMjd(end);

initialTimeSec  = day2sec*initialTimeMjd;
finalTimeSec    = day2sec*finalTimeMjd;

numCadences     = length(cadenceTimesMjd);

exposuresPerCadence    = exposuresPerShortCadence*shortsPerLongCadence;  % = exposuresPerLongCadence

cadenceDurationSec     = exposuresPerCadence*exposureTotalTimeSec;  % = longCadenceDuration, seconds
cadenceDurationDays    = sec2day*cadenceDurationSec;
cadencesPerDay         = 1/cadenceDurationDays;

transitTimeBufferDays  = transitTimeBufferCadences/cadencesPerDay;
transitTimeBufferSec   = day2sec*transitTimeBufferDays;


%--------------------------------------------------------------------------
% compute mid-transit times for circular orbits (where there should be no
% variation between mid-transit times)
%--------------------------------------------------------------------------
if eccentricity == 0

    [numExpectedTransits, numActualTransits, transitStruct] = ...
        get_number_of_transits_in_time_series(transitModelObject, cadenceTimesMjd);

    transitStartTimesNoBufferMjd = [transitStruct.mjdTransitStart]';
    transitEndTimesNoBufferMjd   = [transitStruct.mjdTransitEnd]';

    midTransitTimesMjd        = zeros(numExpectedTransits, 1);
    transitStartTimesDays  = zeros(numExpectedTransits, 1);
    transitEndTimesDays    = zeros(numExpectedTransits, 1);

    for i = 1:numExpectedTransits

        % compute the central transit times
        midTransitTimesMjd(i) = transitEpochMjd + (i - 1)*orbitalPeriodDays; %#ok<AGROW>

        % compute transit start/end times including the buffer
        transitStartTimesDays(i) = midTransitTimesMjd(i) - transitHalfDurationDays - transitTimeBufferDays;
        transitEndTimesDays(i)   = midTransitTimesMjd(i) + transitHalfDurationDays + transitTimeBufferDays;
    end

    % convert to seconds
    midTransitTimesSec           = day2sec*midTransitTimesMjd;
    transitStartTimesNoBufferSec = day2sec*transitStartTimesNoBufferMjd;
    transitEndTimesNoBufferSec   = day2sec*transitEndTimesNoBufferMjd;

    transitStartTimesSec    = day2sec*transitStartTimesDays;
    transitEndTimesSec      = day2sec* transitEndTimesDays;

else
    % central transit times will be computed later
    midTransitTimesSec = [];
end



%--------------------------------------------------------------------------
% Save input and computed parameters to intermediate struct
%--------------------------------------------------------------------------
intermediateStruct.debugFlag                = debugFlag;

intermediateStruct.eccentricity             = eccentricity;
intermediateStruct.secondaryMassKg          = secondaryMassKg;
intermediateStruct.longitudeOfPeri          = longitudeOfPeri;
intermediateStruct.primaryLuminosity        = primaryLuminosity;
intermediateStruct.secondaryLuminosity      = secondaryLuminosity;

intermediateStruct.transitTimeBufferCadences = transitTimeBufferCadences;
intermediateStruct.transitTimeBufferDays    = transitTimeBufferDays;
intermediateStruct.transitTimeBufferSec     = transitTimeBufferSec;

intermediateStruct.cadenceTimesSec          = cadenceTimesSec;
intermediateStruct.surfaceGravityKicUnits   = surfaceGravityKicUnits;
intermediateStruct.semiMajorAxisMeters      = semiMajorAxisMeters;
intermediateStruct.inclinationRadians       = inclinationRadians;

intermediateStruct.transitDurationSec       = transitDurationSec;
intermediateStruct.transitDurationDays      = transitDurationDays;
intermediateStruct.transitDepth             = transitDepth;
intermediateStruct.orbitalPeriodSec         = orbitalPeriodSec;
intermediateStruct.transitEpochSec          = transitEpochSec;
intermediateStruct.transitHalfDurationSec   = transitHalfDurationSec;

intermediateStruct.gravitationalConstant    = gravitationalConstant;
intermediateStruct.primaryMassKg            = primaryMassKg;
intermediateStruct.centralMassKg            = centralMassKg;
intermediateStruct.primaryRadiusMeters      = primaryRadiusMeters;
intermediateStruct.secondaryRadiusMeters    = secondaryRadiusMeters;

intermediateStruct.rPericenterMeters        = rPericenterMeters;
intermediateStruct.vPericenterMks           = vPericenterMks;
intermediateStruct.thetaLOS                 = thetaLOS;
intermediateStruct.minImpactParameter       = minImpactParameter;
intermediateStruct.periCenterTimeSec        = periCenterTimeSec;

intermediateStruct.integrationTimeSec       = integrationTimeSec;
intermediateStruct.transferTimeSec          = transferTimeSec;
intermediateStruct.exposureTotalTimeSec     = exposureTotalTimeSec;
intermediateStruct.initialTimeSec           = initialTimeSec;
intermediateStruct.finalTimeSec             = finalTimeSec;

intermediateStruct.exposuresPerCadence      = exposuresPerCadence;
intermediateStruct.cadenceDurationDays      = cadenceDurationDays;
intermediateStruct.cadenceDurationSec       = cadenceDurationSec;
intermediateStruct.numCadences              = numCadences;

intermediateStruct.numTransits               = numExpectedTransits;
intermediateStruct.midTransitTimesSec        = midTransitTimesSec;
intermediateStruct.transitStartTimesNoBufferSec = transitStartTimesNoBufferSec;
intermediateStruct.transitEndTimesNoBufferSec  = transitEndTimesNoBufferSec;
intermediateStruct.transitStartTimesSec     = transitStartTimesSec;
intermediateStruct.transitEndTimesSec       = transitEndTimesSec;


%--------------------------------------------------------------------------
% allocate memory for fields that are computed later
%--------------------------------------------------------------------------

% computed in compute_transit_model_times
intermediateStruct.transitExposureStartTimes = [];
intermediateStruct.transitExposureEndTimes   = [];
intermediateStruct.rAtTransit                = [];
intermediateStruct.startTimeMap              = [];
intermediateStruct.transitTimeOffset         = [];

% computed in compute_transit_model_orbit
intermediateStruct.exposureStartPosition        = [];
intermediateStruct.exposureEndPosition          = [];
intermediateStruct.rotatedExposureStartPosition = [];
intermediateStruct.rotatedExposureEndPosition   = [];

intermediateStruct.exposureStartImpactParam     = [];
intermediateStruct.exposureEndImpactParam       = [];
intermediateStruct.exposureStartTransitSign     = [];
intermediateStruct.exposureEndTransitSign       = [];


% computed in compute_transit_model_light_curve
intermediateStruct.lightCurve                   = [];
intermediateStruct.lightCurveData               = [];


return;
