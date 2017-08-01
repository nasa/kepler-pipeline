function [adjustedTargetDataStruct, uncorrectedTargetList, ...
discontinuityIndices, alerts] = ...
correct_time_series_discontinuities_for_all_targets(targetDataStruct, ...
discontinuities, discontinuityConfigurationStruct, ...
gapFillConfigurationStruct, dataAnomalyIndicators, alerts, eventStruct)
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
% function [adjustedTargetDataStruct, uncorrectedTargetList, ...
% discontinuityIndices, alerts] = ...
% correct_time_series_discontinuities_for_all_targets(targetDataStruct, ...
% discontinuities, discontinuityConfigurationStruct, ...
% gapFillConfigurationStruct, dataAnomalyIndicators, alerts, eventStruct)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Correct the specified discontinuities for all PDC targets. Iterate to a
% maximum limit if necessary (e.g. multiple samples in discontinuity
% transition for any given target). Issue an alert for any target that
% remains uncorrected and leave flux for those targets in their original
% condition. Cadences of giant transits are passed in through the event
% struct array.
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


% Set reasonable iteration limit.
ITERATION_LIMIT = 4;

% Set the flags for too many unexplained discontinuities and positive step
% detected to false for all targets so that an alert is not raised later
% that they could not be corrected. An alert should only be issued in the
% event that such a case arises in the iterative process of correcting
% discontinuities and detecting new ones.
nTargets = length(discontinuities);
cellArray = num2cell(false([1, nTargets]));
[discontinuities(1 : nTargets).tooManyUnexplainedDiscontinuities] = ...
    cellArray{ : };
[discontinuities(1 : nTargets).positiveStepDetected] = ...
    cellArray{ : };

% Loop over the targets and iteratively correct the identified 
% discontinuities in each flux time series. Keep track of the indices
% through the multiple iterations.
adjustedTargetDataStruct = targetDataStruct;
discontinuityIndices = cell(1, nTargets);
targetList = find([discontinuities.foundDiscontinuity]);
iterationCount = 1;

while ~isempty(targetList) && iterationCount <= ITERATION_LIMIT
    
    for iTarget = targetList

        fluxValues = targetDataStruct(iTarget).values;
        gapIndicators = targetDataStruct(iTarget).gapIndicators;
        indices = discontinuities(iTarget).index;
        stepSizes = ...
            discontinuities(iTarget).discontinuityStepSize;
        
        mergedIndices = union(discontinuityIndices{iTarget}, indices);
        discontinuityIndices{iTarget} = mergedIndices( : );
        
        [targetDataStruct(iTarget).values] = ...
            correct_time_series_discontinuities(fluxValues, indices, ...
            stepSizes, gapIndicators);
        
    end % for iTarget
    
    isOnList = ismember((1 : length(eventStruct)), targetList);
    [discontinuities(targetList), alerts] = ...
        identify_flux_discontinuities_for_all_targets( ...
        targetDataStruct(targetList), discontinuityConfigurationStruct, ...
        gapFillConfigurationStruct, dataAnomalyIndicators, ...
        alerts, eventStruct(isOnList));

    targetList = find([discontinuities.foundDiscontinuity]);
    iterationCount = iterationCount + 1;

end % while

% Update the output structure for the targets that were corrected. Issue an
% alert if there were any targets that could not be corrected.
isNoRemainingDiscontinuityToCorrect = ~[discontinuities.foundDiscontinuity];
isValidCorrection = ~[discontinuities.tooManyUnexplainedDiscontinuities] & ...
    ~[discontinuities.positiveStepDetected];
adjustedTargetDataStruct(isNoRemainingDiscontinuityToCorrect & isValidCorrection) = ...
    targetDataStruct(isNoRemainingDiscontinuityToCorrect & isValidCorrection);

uncorrectedTargetList = ...
    find(~isNoRemainingDiscontinuityToCorrect | ~isValidCorrection)';
for iTarget = uncorrectedTargetList( : )'
    discontinuityIndices{iTarget} = [];
end % for iTarget

if ~isempty(uncorrectedTargetList)
    [alerts] = add_alert(alerts, 'warning', ...
        ['unable to correct flux discontinuities for ', ...
        num2str(length(uncorrectedTargetList)), ' target(s)']);
    disp(alerts(end).message);
end % if

% Return.
return
