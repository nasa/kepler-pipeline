function sohoSolarVariabilityObject = initialize(sohoSolarVariabilityObject, initialData)
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

runParamsObject = sohoSolarVariabilityObject.runParamsClass;
numCadences = get(runParamsObject, 'runDurationCadences');
curves = sohoSolarVariabilityObject.rotationLightCurves;

if nargin < 2
    % assign a stellar rotation period to this target as a uniform distribution
    % over the number of rotations speeds 
    rotationSpeed = ...
        ceil(sohoSolarVariabilityObject.numRotationSpeeds*rand(1,1));
    % set a random offset into the stellar variability array for the selected rotation speed
    variabilityOffset = ...
        ceil(rand(1,1)*(fix(length(curves(rotationSpeed).timeSeries))/2 - numCadences));
    % disp(['rotationSpeed = ' num2str(rotationSpeed) ', variabilityOffset = ' num2str(variabilityOffset)]);
else
    rotationSpeed = initialData.rotationSpeed;
    variabilityOffset = initialData.variabilityOffset;
    % now offset the appropriate number of cadences from the start of the
    % base run
    thisRunStartTime = get(runParamsObject, 'runStartTime');
    % load the start time of the base run
    runPath = get(runParamsObject, 'etem2OutputLocation');
    baseRun = get(runParamsObject, 'initialScienceRun');
	if baseRun(1) == '/'
	    % it's a full path, so use it directly
	    load([baseRun filesep 'scienceTargetList.mat'], 'runStartTime');
	else
	    load([runPath filesep baseRun filesep 'scienceTargetList.mat'], 'runStartTime');
	end
    % load([runPath filesep baseRun filesep 'scienceTargetList.mat'], 'runStartTime');
    timePassedDays = thisRunStartTime - runStartTime; % days
    timePassedSeconds = timePassedDays*24*3600;
    timePassedCadences = fix(timePassedSeconds/get(runParamsObject, 'cadenceDuration'));
    variabilityOffset = variabilityOffset + timePassedCadences;    
end
    
sohoSolarVariabilityObject.rotationSpeed = rotationSpeed;
sohoSolarVariabilityObject.variabilityOffset = variabilityOffset;

% get the light curve now so we can remove the stellar variability data
% from this object to save space
sohoSolarVariabilityObject.lightCurve = ...
    curves(rotationSpeed).timeSeries(...
    variabilityOffset:variabilityOffset+numCadences-1);

% remove the large stellar variability data
sohoSolarVariabilityObject.rotationLightCurves = [];
