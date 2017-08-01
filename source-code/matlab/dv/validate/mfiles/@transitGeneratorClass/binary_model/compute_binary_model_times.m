function intermediateStruct = compute_planet_model_times(transitModelObject, intermediateStruct)
%
%     fieldnames(transitModelObject) =
%     'cadenceTimes'
%     'log10SurfaceGravity'
%     'limbDarkeningModel'
%     'planetModel'
%     'starRadiusSolarRadii'
%     'impactParameterArray'
%     'transitModelLightCurve'
%
%     fieldnames(transitModelObject.planetModel) =
%     'transitEpochMjd'
%     'planetRadiusEarthRadii'
%     'semiMajorAxisAu'
%     'inclinationDegrees'
%     'starRadiusSolarRadii'
%     'transitDurationHours'
%     'transitDepthPpm'
%     'orbitalPeriodDays'
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


% extract intermediate struct parameters
isPlanetCompanion = intermediateStruct.isPlanetCompanion;
thetaLOS          = intermediateStruct.thetaLOS;


if isPlanetCompanion

    [transitExposureStartTimes, transitExposureEndTimes, rAtTransit, startTimeMap] ...
        = compute_single_transit_time(intermediateStruct, thetaLOS);


    % add to output struct
    intermediateStruct.transitExposureStartTimes    = transitExposureStartTimes;
    intermediateStruct.transitExposureEndTimes      = transitExposureEndTimes;
    intermediateStruct.rAtTransit                   = rAtTransit;
    intermediateStruct.startTimeMap                 = startTimeMap;

else
    % this is an eclipsing binary system, so do it for +/- thetaLOS
    [transitExposureStartTimes, transitExposureEndTimes, rAtTransit, startTimeMap] ...
        = compute_single_transit_time(intermediateStruct, thetaLOS);

    [transitExposureStartTimes2, transitExposureEndTimes2, rAtTransit2, startTimeMap2] ...
        = compute_single_transit_time(intermediateStruct, mod(thetaLOS+pi, 2*pi));


    transitExposureStartTimes = [transitExposureStartTimes; transitExposureStartTimes2];
    transitExposureEndTimes   = [transitExposureEndTimes; transitExposureEndTimes2];
    rAtTransit                = [rAtTransit; rAtTransit2];

    % concatanate the start time maps, setting the indices of the second map
    % to start after the first map to match the concatanation of the
    % data, recalling that the counting starts from 0 (so don't add 1)
    startTimeMap = [startTimeMap startTimeMap(end) + startTimeMap2];

    % add to output struct
    intermediateStruct.transitExposureStartTimes    = transitExposureStartTimes;
    intermediateStruct.transitExposureEndTimes      = transitExposureEndTimes;
    intermediateStruct.rAtTransit                   = rAtTransit;
    intermediateStruct.startTimeMap                 = startTimeMap;
end









%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [transitExposureStartTimes, transitExposureEndTimes, rAtTransit, startTimeMap] ...
    = compute_single_transit_time(intermediateStruct, thetaLOS)


e = intermediateStruct.eccentricity;
G = intermediateStruct.gravitationalConstant;
M = intermediateStruct.centralMassKg;

%Rp = intermediateStruct.primaryRadiusMeters;
%Rs = intermediateStruct.secondaryRadiusMeters;
a  = intermediateStruct.semiMajorAxisMeters;
%r0 = intermediateStruct.rPericenterMeters;

orbitalPeriodSec       = intermediateStruct.orbitalPeriodSec;
transitTimeBufferSec   = intermediateStruct.transitTimeBufferSec;
periCenterTimeSec      = intermediateStruct.periCenterTimeSec;
exposureTotalTimeSec   = intermediateStruct.exposureTotalTimeSec;
transitHalfDurationSec = intermediateStruct.transitHalfDurationSec;
initialTimeSec         = intermediateStruct.initialTimeSec;
finalTimeSec           = intermediateStruct.finalTimeSec;


% first compute the time of the maximal transit (when the secondary is at LOS angle)
arg = (e + cos(thetaLOS))/(1 + e*cos(thetaLOS));

if thetaLOS > pi
    E = 2*pi - acos(arg);
else
    E = acos(arg);
end

GM = G*M;

transitTimeOffset = sqrt(power(a, 3)/GM)*(E - e*sin(E));


%--------------------------------------------------------------------------
% find the times near transit for the beginning and end of exposures
%--------------------------------------------------------------------------

% first compute the orbital velocity at transit
cosTheta = cos(thetaLOS);

rAtTransit = a*(1 - e*e)/(1 + e*cosTheta);


%--------------------------------------------------------------------------
% compute the half duration
%--------------------------------------------------------------------------
% sinTheta = sin(thetaLOS);
%
% thetaDotAtTransit = sqrt(a*GM*(1-e*e))/power(rAtTransit, 2);
%
% rDotAtTransit = r0*thetaDotAtTransit*(e*(e+1)*sinTheta)/power(e*cosTheta+1, 2);
%
% vAtTransit = [rDotAtTransit*cosTheta - rAtTransit*thetaDotAtTransit*sinTheta ...
%    rDotAtTransit*sinTheta + rAtTransit*thetaDotAtTransit*cosTheta];
%
%
%% next project that velocity vector onto the plane of the sky
% losVector = [cosTheta, sinTheta];
%
% vAtTransitOnSky = vAtTransit - dot(vAtTransit, losVector)*losVector;
%
%% use the transit speed to estimate the time of a central transit
% halfMaxTransitDuration = (Rp + Rs)/norm(vAtTransitOnSky);


% compute the earliest and latest times of interest for this transit relative to pericenter time
earliestTransitOffset = transitTimeOffset - (transitHalfDurationSec + transitTimeBufferSec);
latestTransitOffset   = transitTimeOffset + (transitHalfDurationSec + transitTimeBufferSec);


%% we now look for exposure start and end times within the simulation run.
%% This amounts to finding n such that
%%
%%   periCenterTimeSec + earliestTransitOffset + n*orbitalPeriodSec > initialTimeSec
%% and
%%   periCenterTimeSec + latestTransitOffset + n*orbitalPeriodSec   < finalTimeSec
%%
%% so we look for integer n that runs from
%%
%% n1 = (initialTimeSec - periCenterTimeSec - earliestTransitOffset)/orbitalPeriodSec
%%  to
%% n2 = (finalTimeSec - periCenterTimeSec - latestTransitOffset)/orbitalPeriodSec


n1 = (initialTimeSec - periCenterTimeSec - latestTransitOffset)/orbitalPeriodSec;

n2 = (finalTimeSec   - periCenterTimeSec - earliestTransitOffset)/orbitalPeriodSec;

transitOrbitNumbers = ceil(n1):floor(n2);



midTransitTimesSec = intermediateStruct.midTransitTimesSec;

if isempty(midTransitTimesSec)

    % compute the central transit times if it hasn't been computed yet
    % (this applies to eccentric orbits)
    midTransitTimesSec = periCenterTimeSec + transitTimeOffset + transitOrbitNumbers*orbitalPeriodSec;
end




transitStartTimesSec = intermediateStruct.transitStartTimesSec;
transitEndTimesSec   = intermediateStruct.transitEndTimesSec;

% now find the exposure start and end times within these transit limits
% do it for each orbit individually and accumulate the times as we go
transitExposureStartTimes = [];
transitExposureEndTimes   = [];


startTimeMap = 0; % start at zero, then use as (startTimeMap(i)+1):startTimeMap(i+1) to avoid overlap

for orbit = 1:length(midTransitTimesSec)

    % for the exposure start times we want to find the smallest n such that
    %    initialTimeSec + n*exposureTotalTimeSec > transitStartTimes(orbit)
    % and the largest n such that
    %    initialTimeSec + n*exposureTotalTimeSec < transitEndTimes(orbit)

    n1 = (transitStartTimesSec(orbit) - initialTimeSec)/exposureTotalTimeSec;
    n2 = (transitEndTimesSec(orbit)   - initialTimeSec)/exposureTotalTimeSec;

    thisTransitExposureStartTimes = initialTimeSec + (ceil(n1):floor(n2))'*exposureTotalTimeSec;

    transitExposureStartTimes = [transitExposureStartTimes; thisTransitExposureStartTimes]; %#ok<AGROW>

    startTimeMap = [startTimeMap length(transitExposureStartTimes)]; %#ok<AGROW>

    % to get the end times we simply add the exposure time
    transitExposureEndTimes = [transitExposureEndTimes; thisTransitExposureStartTimes + exposureTotalTimeSec]; %#ok<AGROW>
end


return;
