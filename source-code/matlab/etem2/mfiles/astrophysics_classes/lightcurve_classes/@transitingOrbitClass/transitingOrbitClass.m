function transitingOrbitObject = transitingOrbitClass(transitingOrbitData, runParamsObject)
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

gravitationalConstant = get_physical_constants_mks('gravitationalConstant'); % mks: m^3/(kg*s^2)

primaryPropertiesStruct = transitingOrbitData.primaryPropertiesStruct;
primaryMassMks = convert_to_mks(primaryPropertiesStruct.mass, ...
    primaryPropertiesStruct.massUnits);
primaryRadiusMks = convert_to_mks(primaryPropertiesStruct.radius, ...
    primaryPropertiesStruct.radiusUnits);

secondaryPropertiesStruct = transitingOrbitData.secondaryPropertiesStruct;
secondaryMassMks = convert_to_mks(secondaryPropertiesStruct.mass, ...
    secondaryPropertiesStruct.massUnits);
secondaryRadiusMks = convert_to_mks(secondaryPropertiesStruct.radius, ...
    secondaryPropertiesStruct.radiusUnits);

if secondaryMassMks == 0
    % this is a planetary system
    centralMassMks = primaryMassMks;
else
    % this is an eclipsing binary system, so use reduced mass
    centralMassMks = (primaryMassMks*secondaryMassMks)/(primaryMassMks + secondaryMassMks);
end    

periCenterTimeMks = transitingOrbitData.periCenterTimeMks;

% set up the basic orbital elements
orbitalPeriodMks = convert_to_mks(transitingOrbitData.orbitalPeriod, ...
    transitingOrbitData.orbitalPeriodUnits);
eccentricity = transitingOrbitData.eccentricity;

semiMajorAxis = power(...
    power(orbitalPeriodMks/(2*pi),2) * gravitationalConstant*centralMassMks, 1/3);

% radial distance of closest approach to primary
periCenterR = semiMajorAxis*(1 - eccentricity);
% velocity at closest approach in Cartesian coordinate system in orbital
% plane with pericenter at = [x=periCenterR, y=0]
periCenterV = [0, ...
    sqrt(gravitationalConstant*centralMassMks*(1 + eccentricity)/periCenterR)];

sumOfRadiiMks = primaryRadiusMks + secondaryRadiusMks;
if periCenterR < 2*sumOfRadiiMks
	periCenterR = 2*sumOfRadiiMks;
    periCenterV = [0, ...
        sqrt(gravitationalConstant*centralMassMks*(1 + eccentricity)/periCenterR)];
    semiMajorAxis = periCenterR/(1 - eccentricity);
	orbitalPeriodMks = 2*pi*sqrt(power(semiMajorAxis, 3)/(gravitationalConstant*centralMassMks));
end
	

transitingOrbitData.centralMassMks = centralMassMks;
transitingOrbitData.primaryMassMks = primaryMassMks;
transitingOrbitData.primaryRadiusMks = primaryRadiusMks;
transitingOrbitData.secondaryMassMks = secondaryMassMks;
transitingOrbitData.secondaryRadiusMks = secondaryRadiusMks;
transitingOrbitData.periCenterTimeMks = periCenterTimeMks;
transitingOrbitData.orbitalPeriodMks = orbitalPeriodMks;
transitingOrbitData.orbitalPeriod = ...
    orbitalPeriodMks/convert_to_mks(1, transitingOrbitData.orbitalPeriodUnits);
transitingOrbitData.eccentricity = eccentricity;
transitingOrbitData.semiMajorAxis = semiMajorAxis;
transitingOrbitData.periCenterR = periCenterR;
transitingOrbitData.periCenterV = periCenterV;
transitingOrbitData.gravitationalConstant = gravitationalConstant;

% disp(transitingOrbitData);

transitingOrbitData.transitTimeOffset = [];
transitingOrbitData.transitExposureStartTimes = [];
transitingOrbitData.transitExposureEndTimes = [];
transitingOrbitData.exposureStartPosition = [];
transitingOrbitData.exposureEndPosition = [];
transitingOrbitData.rotatedExposureStartPosition = [];
transitingOrbitData.rotatedExposureEndPosition = [];
transitingOrbitData.exposureStartImpactParam = [];
transitingOrbitData.exposureEndImpactParam = [];
transitingOrbitData.exposureStartTransitSign = [];
transitingOrbitData.exposureEndTransitSign = [];
transitingOrbitData.rAtTransit = [];
transitingOrbitData.centralTransitTimes = [];
transitingOrbitData.lightCurve = [];
transitingOrbitData.cadenceLightCurve = [];
transitingOrbitData.cadenceLightCurveTimes = [];
transitingOrbitData.cadenceIndex = [];
transitingOrbitData.timeVector = [];
transitingOrbitData.lightCurveData = [];
transitingOrbitData.startTimeMap = [];

transitingOrbitObject = class(transitingOrbitData, 'transitingOrbitClass', runParamsObject);

transitingOrbitObject = compute_transit_time(transitingOrbitObject);
transitingOrbitObject = compute_transit_orbit(transitingOrbitObject);
transitingOrbitObject = compute_light_curve(transitingOrbitObject);


