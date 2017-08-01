function selectedTargetList = select_targets(selectTargetByPropertyObject, catalogData)
% check to see if this is a continuation run
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

runParamsObject = selectTargetByPropertyObject.runParamsClass;
baseRun = get(runParamsObject, 'initialScienceRun');
if baseRun == -1
    magRange = selectTargetByPropertyObject.magnitudeRange;
    effTRange = selectTargetByPropertyObject.effectiveTemperatureRange;
    logGRange = selectTargetByPropertyObject.logGRange;
    maxNumTargets = get(runParamsObject, 'numberOfTargetsRequested');

    selectedTargets = find(catalogData.keplerMagnitude > magRange(1) ...
        & catalogData.keplerMagnitude < magRange(2) ...
        & catalogData.effectiveTemperature > effTRange(1) ...
        & catalogData.effectiveTemperature < effTRange(2) ...
        & catalogData.logSurfaceGravity > logGRange(1) ...
        & catalogData.logSurfaceGravity < logGRange(2));

    cadenceType = get(selectTargetByPropertyObject.runParamsClass, 'cadenceType');

    if length(selectedTargets) <= maxNumTargets
        selectedTargetList = catalogData.kicId(selectedTargets);
    elseif strcmp(cadenceType, 'short')
        selectedTargetList = catalogData.kicId(...
            selectedTargets(ceil(length(selectedTargets)*rand(1,maxNumTargets))));
    else
        selectionShuffle = randperm(length(selectedTargets));
        selectedTargetList = ...
            catalogData.kicId(selectedTargets(selectionShuffle(1:maxNumTargets)));
        
%         % pick the brightest stars
%         [temp, brightStarIndex] = sort(catalogData.keplerMagnitude);
%         kicIdList = catalogData.kicId(brightStarIndex);
%         selectedTargetList = kicIdList(1:maxNumTargets);
    end
else
    runPath = get(runParamsObject, 'etem2OutputLocation');
    % load the keplerIds of the stars from the base run
    load([runPath filesep baseRun filesep 'scienceTargetList.mat'], 'targetList');
    selectedTargetList = [targetList.keplerId];
end

