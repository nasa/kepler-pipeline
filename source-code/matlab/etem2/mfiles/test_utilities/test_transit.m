% test transiting planet object
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
tic;
etem2ConfigurationStruct = ETEM2_inputs_transit_test();
runParamsObject = runParamsClass(etem2ConfigurationStruct.runParamsData);

% targetData = struct('effectiveTemperature', 5850, ...
%     'logSurfaceGravity', 4.4);
% 
targetData = struct('ra', etem2ConfigurationStruct.runParamsData.keplerData.boresiteDec, ...
    'dec', etem2ConfigurationStruct.runParamsData.keplerData.boresiteRa, ...
    'effectiveTemperature', 5800, ...
    'logSurfaceGravity', 3);

transitingPlanetData = struct( ...
    'radiusRange', [0.5 3], ...
    'radiusUnits', 'jupiterRadius', ...
    'eccentricityRange', [0 0.8], ...
    'orbitalPeriodRange', [10 40], ...
    'orbitalPeriodUnits', 'day', ...
    'periCenterDateRange', [datestr2mjd('1-Jan-2008') datestr2mjd('31-Dec-2008')], ...
    'minimumImpactParameterRange', [0 0.7], ...
    'depthRange', [0.1, 0.01]);


transitingPlanetObject = transitingPlanetClass(transitingPlanetData, ...
    targetData, [], runParamsObject);

draw(transitingPlanetObject, 12);

[lightCurve, timeVector, lightCurveData] = create_light_curve(transitingPlanetObject);

figure(1);
plot(timeVector, lightCurve);

toc

%%
tic;
% test transiting star object
etem2ConfigurationStruct = ETEM2_inputs_transit_test();
runParamsObject = runParamsClass(etem2ConfigurationStruct.runParamsData);

targetData = struct('ra', etem2ConfigurationStruct.runParamsData.keplerData.boresiteDec, ...
    'dec', etem2ConfigurationStruct.runParamsData.keplerData.boresiteRa, ...
    'effectiveTemperature', 5850, ...
    'logSurfaceGravity', 4.4);

transitingStarData = struct( ...
    'effectiveTemperatureRange', [4500 8000], ...
    'logGRange', [3 5], ...
    'orbitalPeriodRange', [10 40], ...
    'orbitalPeriodUnits', 'day', ...
    'periCenterDateRange', [datestr2mjd('1-Jan-2008') datestr2mjd('31-Dec-2008')], ...
    'minimumImpactParameterRange', [0 0.7]);

% targetData = struct('effectiveTemperature', 4700, ...
%     'logSurfaceGravity', 2.2020);
% 
% transitingStarData = struct( ...
%     'effectiveTemperatureRange', [5341.4 5341.4], ...
%     'logGRange', [3.3143 3.3143], ...
%     'orbitalPeriodRange', [43.7884 43.7884], ...
%     'orbitalPeriodUnits', 'day', ...
%     'periCenterDateRange', [1.5417e+06 1.5417e+06], ...
%     'minimumImpactParameterRange', [0.5871 0.5871]);

transitingStarObject = transitingStarClass(transitingStarData, ...
    targetData, [], runParamsObject);

draw(transitingStarObject, 13);

[lightCurve, timeVector, lightCurveData] = create_light_curve(transitingStarObject);

figure(2);
plot(timeVector, lightCurve);

toc
