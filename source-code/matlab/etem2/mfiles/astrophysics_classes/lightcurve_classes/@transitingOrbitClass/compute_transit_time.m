function transitingOrbitObject = compute_transit_time(transitingOrbitObject)
%
% Copyright 2017 United States Government as represented by the
% Administrator of the National Aeronautics and Space Administration.
% All Rights Reserved.
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

thetaLOS = transitingOrbitObject.lineOfSightAngle; 
if transitingOrbitObject.secondaryMassMks == 0
    % this is a planetary system
    [centralTransitTimes, transitExposureStartTimes, ...
    transitExposureEndTimes, rAtTransit, startTimeMap] ...
    = compute_single_transit_time(transitingOrbitObject, thetaLOS);

    transitingOrbitObject.centralTransitTimes = centralTransitTimes;
    transitingOrbitObject.transitExposureStartTimes = transitExposureStartTimes;
    transitingOrbitObject.transitExposureEndTimes = transitExposureEndTimes;
    transitingOrbitObject.rAtTransit = rAtTransit;
    transitingOrbitObject.startTimeMap = startTimeMap;
else
    % this is an eclipsing binary system, so do it for +-thetaLOS
    [centralTransitTimes, transitExposureStartTimes, ...
    transitExposureEndTimes, rAtTransit, startTimeMap] ...
    = compute_single_transit_time(transitingOrbitObject, thetaLOS);

    [centralTransitTimes2, transitExposureStartTimes2, ...
    transitExposureEndTimes2, rAtTransit2, startTimeMap2] ...
    = compute_single_transit_time(transitingOrbitObject, mod(thetaLOS+pi, 2*pi));
    
    transitingOrbitObject.centralTransitTimes = ...
        [centralTransitTimes centralTransitTimes2];
    transitingOrbitObject.transitExposureStartTimes = ...
        [transitExposureStartTimes; transitExposureStartTimes2];
    transitingOrbitObject.transitExposureEndTimes = ...
        [transitExposureEndTimes; transitExposureEndTimes2];
    transitingOrbitObject.rAtTransit = [rAtTransit; rAtTransit2];
	% concatanate the start time maps, setting the indices of the second map
	% to start after the first map to match the concatanation of the 
	% data, recalling that the counting starts from 0 (so don't add 1)
    transitingOrbitObject.startTimeMap = [startTimeMap startTimeMap(end) + startTimeMap2];
end    

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [centralTransitTimes, transitExposureStartTimes, ...
    transitExposureEndTimes, rAtTransit, startTimeMap] ...
    = compute_single_transit_time(transitingOrbitObject, thetaLOS)

e = transitingOrbitObject.eccentricity;
G = transitingOrbitObject.gravitationalConstant;
M = transitingOrbitObject.centralMassMks;
Rp = transitingOrbitObject.primaryRadiusMks;
Rs = transitingOrbitObject.secondaryRadiusMks;
a = transitingOrbitObject.semiMajorAxis;
r0 = transitingOrbitObject.periCenterR;
orbitalPeriodMks = transitingOrbitObject.orbitalPeriodMks;
transitTimeBuffer = transitingOrbitObject.transitTimeBuffer;
periCenterTimeMks = transitingOrbitObject.periCenterTimeMks;

runParamsObject = transitingOrbitObject.runParamsClass;
runStartTime = get(runParamsObject, 'runStartTime'); % mjd
runEndTime = get(runParamsObject, 'runEndTime'); % mjd
runStartTimeMks = convert_to_mks(runStartTime - 2, 'days'); % convert to seconds
runEndTimeMks = convert_to_mks(runEndTime + 2, 'days'); % convert to seconds
firstExposureStartTime = convert_to_mks(get(runParamsObject, 'firstExposureStartTime'), 'days'); % mjd seconds
exposureTotalTime = get(runParamsObject, 'exposureTotalTime'); % seconds

% first compute the time of the maximal transit (when the secondary is at
% the line-of-sight angle) using eqn 4.2.9 of Bate et. al.
arg = (e + cos(thetaLOS))/(1 + e*cos(thetaLOS));
if thetaLOS > pi
    E = 2*pi - acos(arg);
else
    E = acos(arg);
end

GM = G*M;
transitTimeOffset = sqrt(power(a, 3)/GM)*(E - e*sin(E));

disp(['transitTime = ' num2str(transitTimeOffset/convert_to_mks(1,'year'))]);

transitingOrbitObject.transitTimeOffset = transitTimeOffset;

% now we find the times near that transit value for the beginning and end
% of exposures

% first compute the orbital velocity at transit
cosTheta = cos(thetaLOS);
sinTheta = sin(thetaLOS);
rAtTransit = a*(1 - e*e)/(1 + e*cosTheta);
thetaDotAtTransit = sqrt(a*GM*(1-e*e))/power(rAtTransit, 2);
rDotAtTransit = r0*thetaDotAtTransit*(e*(e+1)*sinTheta)/power(e*cosTheta+1, 2);
vAtTransit = [rDotAtTransit*cosTheta - rAtTransit*thetaDotAtTransit*sinTheta ...
    rDotAtTransit*sinTheta + rAtTransit*thetaDotAtTransit*cosTheta];

% next project that velocity vector onto the plane of the sky
losVector = [cosTheta, sinTheta];
vAtTransitOnSky = vAtTransit - dot(vAtTransit, losVector)*losVector;

disp(['v at transit = ' num2str(vAtTransit) ', projected on sky = ' num2str(vAtTransitOnSky)]);

% use the transit speed to estimate the time of a central transit
halfMaxTransitDuration = (Rp + Rs)/norm(vAtTransitOnSky);

disp(['halfMaxTransitDuration = ' num2str(halfMaxTransitDuration/convert_to_mks(1, 'hour'))]);

% compute the earliest and latest times of interest for this transit
% relative to pericenter time
earliestTransitOffset = transitTimeOffset - (halfMaxTransitDuration + transitTimeBuffer);
latestTransitOffset = transitTimeOffset + (halfMaxTransitDuration + transitTimeBuffer);

% we now look for exposure start and end times within the simulation run.
% This amounts to finding n such that
%   periCenterTimeMks + earliestTransitOffset + n*orbitalPeriodMks
%       > runStartTimeMks
% and
%   periCenterTimeMks + latestTransitOffset + n*orbitalPeriodMks
%       < runEndTimeMks
% so we look for integer n that runs from 
% n1 = (runStartTimeMks - periCenterTimeMks - earliestTransitOffset)/orbitalPeriodMks
% to 
% n2 = (runEndTimeMks - periCenterTimeMks - latestTransitOffset)/orbitalPeriodMks
% 
n1 = (runStartTimeMks - periCenterTimeMks - latestTransitOffset)/orbitalPeriodMks;
n2 = (runEndTimeMks - periCenterTimeMks - earliestTransitOffset)/orbitalPeriodMks;
transitOrbitNumbers = ceil(n1):floor(n2);
% now compute the corresponding central transit times
centralTransitTimes = periCenterTimeMks + transitTimeOffset + transitOrbitNumbers*orbitalPeriodMks;
disp(['runStart = ' num2str(runStartTimeMks) ', runEnd = ' num2str(runEndTimeMks)]);
disp(['orbitalPeriodMks = ' num2str(orbitalPeriodMks)]);
disp(['centralTransitTimes = ' num2str(centralTransitTimes)]);
% compute the transit intervals for each transit event
transitStartTimes = centralTransitTimes - (halfMaxTransitDuration + transitTimeBuffer);
transitEndTimes = centralTransitTimes + (halfMaxTransitDuration + transitTimeBuffer);
% now find the exposure start and end times within these transit limits
% do it for each orbit individually and accumulate the times as we go
transitExposureStartTimes = [];
transitExposureEndTimes = [];
startTimeMap = 0; % start at zero, then use as (startTimeMap(i)+1):startTimeMap(i+1) to avoid overlap
for orbit=1:length(centralTransitTimes)
    % for the exposure start times we want to find the smallest n such that 
    % firstExposureStartTime + n*exposureTotalTime > transitStartTimes(orbit)
    % and the largest n such that
    % firstExposureStartTime + n*exposureTotalTime < transitEndTimes(orbit)
    % so as before
    n1 = (transitStartTimes(orbit) - firstExposureStartTime)/exposureTotalTime;
    n2 = (transitEndTimes(orbit) - firstExposureStartTime)/exposureTotalTime;
    thisTransitExposureStartTimes = firstExposureStartTime ...
        + (ceil(n1):floor(n2))'*exposureTotalTime;
    transitExposureStartTimes = [transitExposureStartTimes; ...
        thisTransitExposureStartTimes];
 	startTimeMap = [startTimeMap length(transitExposureStartTimes)];
   % to get the end times we simply add the exposureTotalTime
    transitExposureEndTimes = [transitExposureEndTimes; ...
        thisTransitExposureStartTimes + exposureTotalTime];
end
