function dynamicNoiseObject = dynamicNoiseClass(dynamicNoiseData, runParamsObject, electronsToAduObject)
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

offsetPattern = '/path/to/PRF/prfOffsetDeliveries/final/v1/prfOffsetPattern.mat';

load(offsetPattern, 'startDate');
startDateMjd = datestr2mjd(startDate); % start date of 242 cadence dither pattern
runStartTimeMjd = get(runParamsObject, 'runStartTime'); % time of this run in mjd
simTimeDays = runStartTimeMjd - startDateMjd;
dynamicNoiseData.simTime = simTimeDays*24; % convert to hours

cadenceDuration = get(runParamsObject, 'cadenceDuration'); % seconds
centerTime = 121 * cadenceDuration/3600; % hours
dynamicNoiseData.centerTime = centerTime;

temperatureFunctionData = dynamicNoiseData.temperatureFunctionData;
dynamicNoiseData.temperatureFunctionObject = temperatureFunctionClass(temperatureFunctionData);
centerTemperature = get_temperature(dynamicNoiseData.temperatureFunctionObject, centerTime);
dynamicNoiseData.centerTemperature = centerTemperature

fgsCrosstalkData.dataLocation = dynamicNoiseData.fgsCrosstalkDataLocation;
dynamicNoiseData.fgsCrosstalkObject = fgsCrosstalkClass(fgsCrosstalkData, runParamsObject);

rollingBandData.dataLocation = dynamicNoiseData.rollingBandDataLocation;
dynamicNoiseData.rollingBandObject = rollingBandClass(rollingBandData, runParamsObject);

dynamicNoiseData = rmfield(dynamicNoiseData, ...
	{'temperatureFunctionData', 'fgsCrosstalkDataLocation', 'rollingBandDataLocation'});
dynamicNoiseObject = class(dynamicNoiseData, 'dynamicNoiseClass', runParamsObject);
