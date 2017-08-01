function transitingOrbitObject = compute_light_curve(transitingOrbitObject)
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

runParamsObject = transitingOrbitObject.runParamsClass;
runDurationCadences = get(runParamsObject, 'runDurationCadences');
runStartTime = get(runParamsObject, 'runStartTime'); % mjd
runStartTimeMks = convert_to_mks(runStartTime, 'days'); % convert to seconds
firstExposureStartTime = convert_to_mks(get(runParamsObject, 'firstExposureStartTime'), 'days'); % mjd seconds
cadenceDuration = get(runParamsObject, 'cadenceDuration');

lightCurve = ones(runDurationCadences, 1);

firstCadenceInRun = ceil((runStartTimeMks - firstExposureStartTime)/cadenceDuration);
firstCadenceInRunTime = firstCadenceInRun*cadenceDuration + firstExposureStartTime; % mjd in seconds after the first exposure of mission

timeVector = (firstCadenceInRunTime:cadenceDuration:firstCadenceInRunTime+(runDurationCadences-1)*cadenceDuration)'; % seconds
timeVector = timeVector + cadenceDuration/2;

if isempty(transitingOrbitObject.exposureStartImpactParam)
    % there is no transit
	transitingOrbitObject.lightCurve = lightCurve;
	transitingOrbitObject.timeVector = timeVector;
	transitingOrbitObject.lightCurveData = [];
    % the other fields are already empty so leave them that way
    return;
end
primaryTransitExpStart = find(transitingOrbitObject.exposureStartTransitSign == 1);
secondaryTransitExpStart = find(transitingOrbitObject.exposureStartTransitSign == -1);
primaryTransitExpEnd = find(transitingOrbitObject.exposureEndTransitSign == 1);
secondaryTransitExpEnd = find(transitingOrbitObject.exposureEndTransitSign == -1);

primaryRadiusMks = transitingOrbitObject.primaryRadiusMks;
secondaryRadiusMks = transitingOrbitObject.secondaryRadiusMks;
eclipsingObjectNormalizedRadius = secondaryRadiusMks/primaryRadiusMks;
eclipsedStarPropertiesStruct = transitingOrbitObject.primaryPropertiesStruct;

exposureStartLightCurve = analytic_light_curve(transitingOrbitObject, ...
    eclipsingObjectNormalizedRadius, eclipsedStarPropertiesStruct, ...
    transitingOrbitObject.exposureStartImpactParam(primaryTransitExpStart));
exposureEndLightCurve = analytic_light_curve(transitingOrbitObject, ...
    eclipsingObjectNormalizedRadius, eclipsedStarPropertiesStruct, ...
    transitingOrbitObject.exposureStartImpactParam(primaryTransitExpEnd));
% this is the primary eclipse with the secondary in front.  Normalize the 
% light curves according to the component luminosities
L1 = transitingOrbitObject.primaryPropertiesStruct.luminosity;
L2 = transitingOrbitObject.secondaryPropertiesStruct.luminosity;
exposureStartLightCurve = (L2 + exposureStartLightCurve*L1)/(L2 + L1);
exposureEndLightCurve = (L2 + exposureEndLightCurve*L1)/(L2 + L1);

if ~isempty(secondaryTransitExpStart) && transitingOrbitObject.secondaryMassMks ~= 0
    % if there is a secondary transit, switch the role of primary and
    % secondary
    tempPrimaryRadiusMks = transitingOrbitObject.secondaryRadiusMks;
    tempSecondaryRadiusMks = transitingOrbitObject.primaryRadiusMks;
    eclipsingObjectNormalizedRadius = tempSecondaryRadiusMks/tempPrimaryRadiusMks;
    eclipsedStarPropertiesStruct = transitingOrbitObject.secondaryPropertiesStruct;

    secondaryExpStartLightCurve = analytic_light_curve(transitingOrbitObject, ...
        eclipsingObjectNormalizedRadius, eclipsedStarPropertiesStruct, ...
        transitingOrbitObject.exposureStartImpactParam(secondaryTransitExpStart));
    secondaryExpEndLightCurve = analytic_light_curve(transitingOrbitObject, ...
        eclipsingObjectNormalizedRadius, eclipsedStarPropertiesStruct, ...
        transitingOrbitObject.exposureStartImpactParam(secondaryTransitExpEnd));
    % this is the secondary eclipse with the primary in front.  Normalize the 
    % light curves according to the component luminosities
    secondaryExpStartLightCurve = (L1 + secondaryExpStartLightCurve*L2)/(L1+L2);
    secondaryExpEndLightCurve = (L1 + secondaryExpEndLightCurve*L2)/(L1+L2);
    
    exposureStartLightCurve = [exposureStartLightCurve; secondaryExpStartLightCurve];
    exposureEndLightCurve = [exposureEndLightCurve; secondaryExpEndLightCurve];
end

% we now want to associate a single value with each exposure, using the
% trapezoidal rule to integrate a value for each exposure

exposureTotalTime = get(runParamsObject, 'exposureTotalTime');
integrationTime = get(runParamsObject, 'integrationTime');
exposuresPerCadence = get(runParamsObject, 'exposuresPerCadence');
btcObject = get(runParamsObject, 'barycentricTimeCorrectionObject');

% compute the actual integral via trapezoidal rule here
exposureLightCurve = ...
    (integrationTime/2)*(exposureStartLightCurve + exposureEndLightCurve);
exposureLightCurve = exposureLightCurve/max(exposureLightCurve);
% use the starting time of the exposure for the time of each point to
% facilitate later computations
exposureLightCurveStartTimes = transitingOrbitObject.transitExposureStartTimes;
exposureLightCurveEndTimes = transitingOrbitObject.transitExposureEndTimes;
exposureLightCurveMidTimes = (exposureLightCurveStartTimes + exposureLightCurveEndTimes)/2;

targetRa = transitingOrbitObject.primaryPropertiesStruct.ra;
targetDec = transitingOrbitObject.primaryPropertiesStruct.dec;
% apply barycentric time correction
% convert exposureLightCurveTimes in mjd seconds to julian days
startTimeMap = transitingOrbitObject.startTimeMap;
e0 = exposureLightCurveMidTimes;
for s=1:length(startTimeMap)-1
	timeRange = (startTimeMap(s)+1):startTimeMap(s+1);
	if ~isempty(timeRange)
    	e(s).c = exposureLightCurveMidTimes(timeRange);
		expTimesJulianDays = mjd_to_julian_day(exposureLightCurveMidTimes(timeRange)/convert_to_mks(1, 'days'));
%     	disp(julian2datestr(expTimesJulianDays(1)));
%     	disp(julian2datestr(expTimesJulianDays(end)));
		exposureLightCurveStartTimes(timeRange) = exposureLightCurveStartTimes(timeRange) + get_time_correction( ...
			btcObject, targetRa, targetDec, expTimesJulianDays);
		exposureLightCurveEndTimes(timeRange) = exposureLightCurveEndTimes(timeRange) + get_time_correction( ...
			btcObject, targetRa, targetDec, expTimesJulianDays);
% 		exposureLightCurveStartTimes(timeRange) = exposureLightCurveStartTimes(timeRange);
% 		exposureLightCurveEndTimes(timeRange) = exposureLightCurveEndTimes(timeRange);
	end
end

% map the transits defined at the exposure times to cadence times by first
% identifying the exposures closest to the start and end of each cadence
% then summing the exposures in this range
cadenceLightCurve = ones(size(timeVector));
for it = 1:length(timeVector)-1
    [minVal, startExposureIndex] = min(abs(exposureLightCurveStartTimes ...
        - (timeVector(it)-cadenceDuration/2)));
    [minVal, endExposureIndex] = min(abs(exposureLightCurveEndTimes ...
        - (timeVector(it+1)-cadenceDuration/2)));
    if minVal < cadenceDuration/2
        nExposures = endExposureIndex-startExposureIndex+1;
        cadenceLightCurve(it) = bin_matrix(...
            exposureLightCurve(startExposureIndex:endExposureIndex), ...
            nExposures, 1)'/nExposures;
    end
end
cadenceLightCurve = cadenceLightCurve/max(cadenceLightCurve);

lightCurveData.orbitalPeriodMks = transitingOrbitObject.orbitalPeriodMks;
lightCurveData.transitTimesMks = transitingOrbitObject.centralTransitTimes;
lightCurveData.minimumImpactParameter = transitingOrbitObject.minimumImpactParameter;
lightCurveData.secondaryRadiusMks = secondaryRadiusMks;
lightCurveData.primaryRadiusMks = primaryRadiusMks;
lightCurveData.eccentricity = transitingOrbitObject.eccentricity;
lightCurveData.primaryLuminosity = transitingOrbitObject.primaryPropertiesStruct.luminosity;
lightCurveData.secondaryLuminosity = transitingOrbitObject.secondaryPropertiesStruct.luminosity;

transitingOrbitObject.lightCurve = cadenceLightCurve;
transitingOrbitObject.timeVector = timeVector;
transitingOrbitObject.lightCurveData = lightCurveData;

transitingOrbitObject.exposureStartTransitSign = [];
transitingOrbitObject.exposureEndTransitSign = [];
transitingOrbitObject.exposureStartImpactParam = [];
transitingOrbitObject.exposureEndImpactParam = [];

function lightCurve = analytic_light_curve(transitingOrbitObject, ...
    eclipsingObjectNormalizedRadius, eclipsedStarPropertiesStruct, impactParameter);
% compute the light curves using the Agol's routines.  There is a faster
% one for small secondaries of radius less than 0.01*radius of primary.
if eclipsingObjectNormalizedRadius > 0.01
    lightCurve = large_transit_light_curve( ...
        transitingOrbitObject, eclipsingObjectNormalizedRadius, ...
        eclipsedStarPropertiesStruct, impactParameter);
else
    lightCurve = small_transit_light_curve( ...
        transitingOrbitObject, eclipsingObjectNormalizedRadius, ...
        eclipsedStarPropertiesStruct, impactParameter);
end

