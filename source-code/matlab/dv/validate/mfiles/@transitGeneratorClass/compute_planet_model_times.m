function intermediateStruct = compute_planet_model_times(transitModelObject, intermediateStruct)
% function intermediateStruct = compute_planet_model_times(transitModelObject, intermediateStruct)
%
% function to compute the time parameters for the transit model light curve
% generator, which includes the start/end times of each exposure during
% each transit event.
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

debugFlag = transitModelObject.debugFlag;

% extract intermediate struct parameters
thetaLOS  = intermediateStruct.thetaLOS;


G = get_physical_constants_mks('gravitationalConstant');

M = intermediateStruct.primaryMassKg;

Rp = intermediateStruct.primaryRadiusMeters;
Rs = intermediateStruct.secondaryRadiusMeters;
a  = intermediateStruct.semiMajorAxisMeters;
e  = intermediateStruct.eccentricity;
r0 = intermediateStruct.rPericenterMeters;

orbitalPeriodSec       = intermediateStruct.orbitalPeriodSec;
transitBufferSecs      = intermediateStruct.transitBufferSecs;
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
sinTheta = sin(thetaLOS);

thetaDotAtTransit = sqrt(a*GM*(1-e*e))/power(rAtTransit, 2);

rDotAtTransit = r0*thetaDotAtTransit*(e*(e+1)*sinTheta)/power(e*cosTheta+1, 2);

vAtTransit = [rDotAtTransit*cosTheta - rAtTransit*thetaDotAtTransit*sinTheta ...
    rDotAtTransit*sinTheta + rAtTransit*thetaDotAtTransit*cosTheta];


% next project that velocity vector onto the plane of the sky
losVector = [cosTheta, sinTheta];

vAtTransitOnSky = vAtTransit - dot(vAtTransit, losVector)*losVector;

% use the transit speed to estimate the time of a central transit
halfMaxTransitDuration = (Rp + Rs)/norm(vAtTransitOnSky);


% compute the earliest and latest times of interest for this transit relative to pericenter time
earliestTransitOffset = transitTimeOffset - (transitHalfDurationSec + transitBufferSecs);
latestTransitOffset   = transitTimeOffset + (transitHalfDurationSec + transitBufferSecs);


%% we now look for exposure start and end times within the simulation run.
%% This amounts to finding n such that
%%
%%   periCenterTimeSec + earliestTransitOffset + n*orbitalPeriodSec > initialTimeSec
%% and
%%   periCenterTimeSec + latestTransitOffset + n*orbitalPeriodSec   < finalTimeSec

n1 = (initialTimeSec - periCenterTimeSec - latestTransitOffset)/orbitalPeriodSec;

n2 = (finalTimeSec   - periCenterTimeSec - earliestTransitOffset)/orbitalPeriodSec;

transitOrbitNumbers = ceil(n1):floor(n2);



midTransitTimesSec   = intermediateStruct.midTransitTimesSec;

if isempty(midTransitTimesSec)

    % compute the central transit times if it hasn't been computed yet
    % (this applies to eccentric orbits)
    midTransitTimesSec = periCenterTimeSec + transitTimeOffset + transitOrbitNumbers*orbitalPeriodSec;
    
    transitStartTimesSec = zeros(length(midTransitTimesSec), 1);
    transitEndTimesSec   = zeros(length(midTransitTimesSec), 1); 
    
    for i = 1:length(midTransitTimesSec)

        % compute transit start/end times including the buffer
        transitStartTimesSec(i) = midTransitTimesSec(i) - transitHalfDurationSec - transitBufferSecs;
        transitEndTimesSec(i)   = midTransitTimesSec(i) + transitHalfDurationSec + transitBufferSecs;
    end
else

    transitStartTimesSec = intermediateStruct.transitStartTimesSec;
    transitEndTimesSec   = intermediateStruct.transitEndTimesSec;      
end





% now find the exposure start and end times within these transit limits
% do it for each orbit individually and accumulate the times as we go
transitExposureStartTimes = [];
transitExposureEndTimes   = [];


startTimeMap = 0; % start at zero, then use as (startTimeMap(i)+1):startTimeMap(i+1) to avoid overlap

timeSpentInTransitSeconds = sum( transitEndTimesSec - transitStartTimesSec ) ;

% if the number of exposures gets too large, the memory will run out.  Set the max # of
% exposures to be correct for a 15 year mission

missionDurationYears = 15 ;
maxTransitFraction = 0.05 ;
missionDurationSeconds = missionDurationYears * get_unit_conversion('year2sec') ;

if timeSpentInTransitSeconds > missionDurationSeconds * maxTransitFraction
    error( 'transitGeneratorClass:computePlanetModelTimes:tooManyExposures', ...
        'compute_planet_model_times:  too many exposures required' ) ;
end
 
for orbit = 1:length(midTransitTimesSec)

    % for the exposure start times we want to find the smallest n such that
    %    initialTimeSec + n*exposureTotalTimeSec > transitStartTimes(orbit)
    % and the largest n such that
    %    initialTimeSec + n*exposureTotalTimeSec < transitEndTimes(orbit)

    n1 = (transitStartTimesSec(orbit) - initialTimeSec)/exposureTotalTimeSec;
    n2 = (transitEndTimesSec(orbit)   - initialTimeSec)/exposureTotalTimeSec;

    % require that the total memory space needed for the big exposure time arrays does
    % not exceed a rather arbitrary limit of 1.5 GB
    
    thisTransitExposureStartTimes = initialTimeSec + (ceil(n1):floor(n2))'*exposureTotalTimeSec;

    transitExposureStartTimes = [transitExposureStartTimes; thisTransitExposureStartTimes]; %#ok<AGROW>

    startTimeMap = [startTimeMap length(transitExposureStartTimes)]; %#ok<AGROW>

    % to get the end times we simply add the exposure time
    transitExposureEndTimes = [transitExposureEndTimes; thisTransitExposureStartTimes + exposureTotalTimeSec]; %#ok<AGROW>
    
    % clear the existing thisTransitExposureStartTimes array for memory efficiency
    clear thisTransitExposureStartTimes ;
    
end


% add to output struct
intermediateStruct.transitExposureStartTimes    = transitExposureStartTimes;
intermediateStruct.transitExposureEndTimes      = transitExposureEndTimes;
intermediateStruct.rAtTransit                   = rAtTransit;
intermediateStruct.startTimeMap                 = startTimeMap;



return;
