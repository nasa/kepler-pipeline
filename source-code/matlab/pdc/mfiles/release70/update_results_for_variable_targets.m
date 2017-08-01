
function [timeSeries, harmonicTimeSeries, variableTargetList, ...
badTargetList, harmonicsFittedTargetList, harmonicsRestoredTargetList, ...
shortTimeScalePowerRatio, saturationSegmentsStruct, alerts] = ...
update_results_for_variable_targets(targetDataStruct, timeSeries, ...
variableTimeSeries, variableTargetList, harmonicTimeSeries, ...
shortTimeScalePowerRatio, variableShortTimeScalePowerRatio, ...
saturationSegmentsStruct, variableSaturationSegmentsStruct, ...
pdcModuleParameters, gapFillParametersStruct, cadenceType, alerts)
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
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [timeSeries, harmonicTimeSeries, variableTargetList, ...
% badTargetList, harmonicsFittedTargetList, harmonicsRestoredTargetList, ...
% shortTimeScalePowerRatio, saturationSegmentsStruct, alerts] = ...
% update_results_for_variable_targets(targetDataStruct, timeSeries, ...
% variableTimeSeries, variableTargetList, harmonicTimeSeries, ...
% shortTimeScalePowerRatio, variableShortTimeScalePowerRatio, ...
% saturationSegmentsStruct, variableSaturationSegmentsStruct, ...
% pdcModuleParameters, gapFillParametersStruct, cadenceType, alerts)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Determine if the targets that were initially identified as variable are
% still variable after cotrending. It can be hard to reliably identify the
% variable targets before cotrending in the presence of large data
% anomalies.
%
% Also find the targets (non-variable and variable) for which cotrending
% performed poorly, and replace the cotrending results with the raw flux
% from the PDC inputs.
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


% Define constants. The limit for good cotrending performance can become a
% module parameter in the future.
SINGLETON_REMOVAL_ENABLED = false;
LIMIT_FOR_GOOD_PERFORMANCE = 1.0;

% Get necessary fields.
stellarVariabilityDetrendOrder = ...
    pdcModuleParameters.stellarVariabilityDetrendOrder;
stellarVariabilityThreshold = ...
    pdcModuleParameters.stellarVariabilityThreshold;
cotrendPerformanceLimit = pdcModuleParameters.cotrendPerformanceLimit;

% Correct the target indices in the variable saturation segments struct.
% The variable saturation segments were identified from only a subset of
% all targets in the unit of work.
targetList = [variableSaturationSegmentsStruct.target];
if ~isempty(targetList)
    nTargets = length(targetList);
    targetCellArray = num2cell(variableTargetList(targetList));
    [variableSaturationSegmentsStruct(1 : nTargets).target] = ...
        targetCellArray{ : };
end % if

% Check if the variable targets appear to still be variable after
% cotrending. If some targets now appear to be variable that were not
% originally identified as variable then that is the way it goes (for now)!
% Remove giant transits before checking for variability.
fluxValuesArray = [timeSeries.values];
gapIndicatorsArray = [timeSeries.gapIndicators];

for iTarget = variableTargetList( : )'
    fluxValues = fluxValuesArray( : , iTarget);
    gapIndicators = gapIndicatorsArray( : , iTarget);
    [indexOfAstroEvents] = identify_astrophysical_events(fluxValues, ...
        gapIndicators, gapFillParametersStruct, ...
        SINGLETON_REMOVAL_ENABLED);
    fluxValuesArray(indexOfAstroEvents, iTarget) = 0;
    gapIndicatorsArray(indexOfAstroEvents, iTarget) = true;
end % for iTarget

if strcmpi(cadenceType, 'long')
    ensembleCorrectionEnabled = true;
else
    ensembleCorrectionEnabled = false;
end

[variableTargetListForCorrectedFlux] = ...
    identify_variable_targets(fluxValuesArray, gapIndicatorsArray, ...
    stellarVariabilityDetrendOrder, stellarVariabilityThreshold, ...
    ensembleCorrectionEnabled);

% Targets should still be considered to be variable if they were not very
% well corrected when treated as non-variable.
variableTargetListForCorrectedFlux = ...
    union(variableTargetListForCorrectedFlux, ...
    find(shortTimeScalePowerRatio > LIMIT_FOR_GOOD_PERFORMANCE));

notVariableTargetList = ...
    setdiff(variableTargetList, variableTargetListForCorrectedFlux);
isVariableTarget = ...
    ismember(variableTargetList, variableTargetListForCorrectedFlux);
variableTargetList = ...
    intersect(variableTargetList, variableTargetListForCorrectedFlux);

% Update the time series, short time scale power ratio, and saturation
% segments struct.
timeSeries(variableTargetList) = variableTimeSeries(isVariableTarget);
shortTimeScalePowerRatio(variableTargetList) = ...
    variableShortTimeScalePowerRatio(isVariableTarget);

saturatedTargetList = [saturationSegmentsStruct.target];
variableSaturatedTargetList = [variableSaturationSegmentsStruct.target];
saturationSegmentsStruct(ismember(saturatedTargetList, variableTargetList)) = [];
saturationSegmentsStruct = [saturationSegmentsStruct, ...
    variableSaturationSegmentsStruct(ismember(variableSaturatedTargetList, ...
    variableTargetList))];
saturatedTargetList = [saturationSegmentsStruct.target];
[b, ix] = sort(saturatedTargetList);
saturationSegmentsStruct = saturationSegmentsStruct(ix);

% Update the harmonic time series for the targets which have ultimately
% been determined not to be variable. Determine the final list of harmonic
% targets.
keplerIds = [harmonicTimeSeries.keplerId];
nCadences = length(timeSeries(1).values);

defaultHarmonicTimeSeries = struct( ...
    'keplerId', 0, ...
    'values', zeros([nCadences, 1]), ...
    'detrendedFluxValues', zeros([nCadences, 1]), ...
    'detrendedFluxUncertainties', zeros([nCadences, 1]), ...
    'detrendedFluxGapIndicators', false([nCadences, 1]), ...
    'indexOfGiantTransits', [], ...
    'harmonicModelStruct', [], ...
    'harmonicChiSquare', 0);

for iTarget = notVariableTargetList( : )'
    harmonicTimeSeries(iTarget) = defaultHarmonicTimeSeries;
    harmonicTimeSeries(iTarget).keplerId = keplerIds(iTarget);
end % for iTarget

harmonicValues = [harmonicTimeSeries.values];
harmonicsFittedTargetList = find(any(harmonicValues ~= 0, 1)');

% Find the targets (non-variable or variable) for which cotrending
% performed poorly. Return if there are none. Identify the targets for
% which harmonics were restored.
badTargetList = find(shortTimeScalePowerRatio > cotrendPerformanceLimit);
if isempty(badTargetList)
    harmonicsRestoredTargetList = harmonicsFittedTargetList;
    return
else
    harmonicsRestoredTargetList = setdiff(harmonicsFittedTargetList, ...
        badTargetList);
end % if / else

% Loop through the bad targets and update the cotrending results with the
% raw flux from the PDC inputs.
for iTarget = badTargetList( : )'
    
    gapIndicators = targetDataStruct(iTarget).gapIndicators;
    timeSeries(iTarget).gapIndicators = gapIndicators;
    
    timeSeries(iTarget).values = targetDataStruct(iTarget).values;
    timeSeries(iTarget).values(gapIndicators) = 0;
    
    timeSeries(iTarget).uncertainties = targetDataStruct(iTarget).uncertainties;
    timeSeries(iTarget).uncertainties(gapIndicators) = 0;
    
    harmonicTimeSeries(iTarget).values = zeros([nCadences, 1]);
    
end % for iTarget

% Issue an alert.
[alerts] = add_alert(alerts, 'warning', ...
    ['systematic error correction not performed for ', ...
    num2str(length(badTargetList)), ' target(s)']);
disp(alerts(end).message);

% Return.
return
