%*************************************************************************************************************
% Truncates the input data to pdc_matlab_controller to a desired number of 
% targets and cadences per target. Start in the directory with the required
% input files, which are pdc-inputs-0.mat and the blobxxx.mat file
% NOTE: *Before* running this code, you must copy the original blobxxx.mat
% file to blobxxx_original.mat
%
% Inputs:
%  blobFileRoot     -- root of blob file name, eg. 'blob1438959443402720356'
%  nTargets         -- [int] Number of Targets, if greater than nTarget in InputsStruct then a randomly chosen list from full list are duplicated
%  nCadences        -- [int] Number of cadences to uses, if greater than original 
%                       cadence length in inputsStruct then the flux is extended using negative reflection
%
% Outputs 
%  inputsStruct     -- [inputsStruct] New inputsStruct set to the correct nTargets and nCadences
%  blobStruct       -- [blobStruct]   New blobStruct set to the correct nCadences
%
%==========================================================================
% The script will
% (1) Truncate the data in the original version of blobFile and save it as 
%     blobFile.
% (2) Truncate the data in inputsStruct in pdc-inputs-0.mat
% You can then run pdc in the normal way on the truncated data set:
% outputStruct = pdc_matlab_controller(inputsStruct)
%*************************************************************************************************************
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

function [inputsStruct, blobStruct] = pdc_set_inputsStruct_nTargets_nCadences (inputsStruct, blobStruct, nTargets, nCadences)

    % For these fields we need to advance the value, not reflect back
    cadenceTimesToAdvanceTo = {'startTimestamps', 'midTimestamps', 'endTimestamps'};
    blobToAdvanceTo = {'cadence', 'mjdStartTime', 'mjdMidTime', 'mjdEndTime'};


    % Get rid of the channelDataStruct subdivisions
    inputsStruct = pdcInputClass.process_channelDataStruct(inputsStruct);

    nOriginalCadences = length(inputsStruct.targetDataStruct(1).values);
    nOriginalTargets  = length(inputsStruct.targetDataStruct);
    nExtraCadences = nCadences - nOriginalCadences ;
    nExtraTargets = nTargets - nOriginalTargets ;

    if (nOriginalCadences  > nCadences)
        truncatingCadences = true;
        extendingCadences  = false;
    elseif (nOriginalCadences  < nCadences)
        truncatingCadences = false;
        extendingCadences  = true;
    else
        truncatingCadences = false;
        extendingCadences  = false;
    end
    
    %**************************
    % Set the blobStruct to proper length, Just reflect if extending the cadences longer
    if (truncatingCadences)
        blobStruct = blobStruct(1:nCadences);
    elseif (extendingCadences)
        blobStruct = extend_array_via_negative_reflection (blobStruct, nExtraCadences, false);
        fn = fieldnames(blobStruct(1));
        for iField = 1:length(fn);
            if (any(strcmp(fn{iField}, blobToAdvanceTo)));
                % extend via advancing
                originalArray = [blobStruct.(fn{iField})];
                originalArray = originalArray(1:nOriginalCadences);
                extendedArray =  extend_array_via_advancing (originalArray, nExtraCadences);
                for iCadence =  1 : nExtraCadences
                    blobStruct(iCadence + nOriginalCadences).(fn{iField}) = extendedArray(iCadence + nOriginalCadences);
                end
            end
        end
    end
    
    %**************************
    % Set every field of inputsStruct that depends on the number of cadences
    inputsStruct.endCadence = inputsStruct.startCadence - 1 + nCadences;
    
    %***
    % CadenceTimes and longCadenceTimes
    % Set all appropriate fields to the new length (Lots to do here!)
    for topFieldName = {'cadenceTimes' 'longCadenceTimes'}
        fn = fieldnames(inputsStruct.(topFieldName{:}));
        for iField = 1:length(fn);
            % Change the (topFieldName{:}) fields that are already nOriginalCadences in length to nCadences via reflection
            if (length(inputsStruct.(topFieldName{:}).(fn{iField})) == nOriginalCadences)
        

                originalArray = inputsStruct.(topFieldName{:}).(fn{iField});
                if (truncatingCadences)
                    inputsStruct.(topFieldName{:}).(fn{iField}) = originalArray(1:nCadences); 
                elseif (extendingCadences)
                    if (any(strcmp(fn{iField}, cadenceTimesToAdvanceTo)));
                        % extend via advancing
                        inputsStruct.(topFieldName{:}).(fn{iField}) = extend_array_via_advancing (originalArray, nExtraCadences);
                    else
                        % extend via reflection
                        inputsStruct.(topFieldName{:}).(fn{iField}) = extend_array_via_negative_reflection (originalArray, nExtraCadences, false);
                    end
                end
            elseif (strcmp(fn{iField}, 'dataAnomalyFlags'))
                % Need to recursively do the same for the dataAnomalyFlags
                fnInner = fieldnames(inputsStruct.(topFieldName{:}).(fn{iField}));
                for iInnerField = 1:length(fnInner);
                    originalArray = inputsStruct.(topFieldName{:}).(fn{iField}).(fnInner{iInnerField});
                    if (truncatingCadences)
                        inputsStruct.(topFieldName{:}).(fn{iField}).(fnInner{iInnerField}) = originalArray(1:nCadences); 
                    elseif (extendingCadences)
                        % extend via reflection
                        inputsStruct.(topFieldName{:}).(fn{iField}).(fnInner{iInnerField}) = ...
                                    extend_array_via_negative_reflection (originalArray, nExtraCadences, false);
                    end
                end
            end
        end
    end

    %***
    % Set the targetDataStruct to the proper length
    if (truncatingCadences)
        for iTarget = 1 : length(inputsStruct.targetDataStruct)
            inputsStruct.targetDataStruct(iTarget).values        = inputsStruct.targetDataStruct(iTarget).values(1:nCadences);
            inputsStruct.targetDataStruct(iTarget).gapIndicators = inputsStruct.targetDataStruct(iTarget).gapIndicators(1:nCadences);
            inputsStruct.targetDataStruct(iTarget).uncertainties = inputsStruct.targetDataStruct(iTarget).uncertainties(1:nCadences);
        end
    elseif (extendingCadences)
        for iTarget = 1 : length(inputsStruct.targetDataStruct)
            inputsStruct.targetDataStruct(iTarget).values        = ...
                extend_array_via_negative_reflection (inputsStruct.targetDataStruct(iTarget).values,        nExtraCadences, false);
            inputsStruct.targetDataStruct(iTarget).gapIndicators = ...
                extend_array_via_negative_reflection (inputsStruct.targetDataStruct(iTarget).gapIndicators, nExtraCadences, false);
            inputsStruct.targetDataStruct(iTarget).uncertainties = ...
                extend_array_via_negative_reflection (inputsStruct.targetDataStruct(iTarget).uncertainties, nExtraCadences, false);
        end
    end

    %***
    % Motion blob fields
    if (truncatingCadences)
        inputsStruct.motionBlobs.blobIndices    = inputsStruct.motionBlobs.blobIndices(1:nCadences);
        inputsStruct.motionBlobs.gapIndicators  = inputsStruct.motionBlobs.gapIndicators(1:nCadences);
        inputsStruct.motionBlobs.endCadence     = inputsStruct.endCadence;
    elseif (extendingCadences)
        lastBlobIndex = inputsStruct.motionBlobs.blobIndices(end);
        inputsStruct.motionBlobs.blobIndices    = [inputsStruct.motionBlobs.blobIndices' repmat(lastBlobIndex, [nExtraCadences,1])']';
        inputsStruct.motionBlobs.gapIndicators  = extend_array_via_negative_reflection (inputsStruct.motionBlobs.gapIndicators, nExtraCadences, false);
        inputsStruct.motionBlobs.endCadence     = inputsStruct.endCadence;
    end
    
    %**************************
    % Select the number of targets
    if (nOriginalTargets > nTargets)
        targetsToUse = randperm(nOriginalTargets);
        targetsToUse = targetsToUse(1:nTargets);
    elseif (nOriginalTargets < nTargets)
        % If more selected targets than in the original run then randomly pick more targets to add
        targetsToUse = randperm(nOriginalTargets);
        targetsToUse = [1:nOriginalTargets targetsToUse(1:nExtraTargets)];
        % Each kepler ID must be unique
        % Should non-custom, standard targets (so < 15e6)
        originalKeplerIds = [inputsStruct.targetDataStruct.keplerId];
        newTargetKeplerIds = randi(14.9e6, [nExtraTargets,1]);
        % Confirm non overlap with the real kepler Ids
        % If any overlap just roll the dice again, simple, but field is sparse enough this should work fine.
        overlapHere = find(ismember(newTargetKeplerIds, originalKeplerIds));
        while(~isempty(overlapHere))
            for iTarget = 1 : length(overlapHere)
                newTargetKeplerIds(overlapHere(iTarget)) =  randi(14.9e6);
            end
            overlapHere = find(ismember(newTargetKeplerIds, originalKeplerIds));
        end
    else
        % No change in nTargets
        targetsToUse = 1:nOriginalTargets;
    end
    inputsStruct.targetDataStruct = inputsStruct.targetDataStruct(targetsToUse);

    if(nOriginalTargets < nTargets)
        for iTarget = 1 : nExtraTargets
            inputsStruct.targetDataStruct(nOriginalTargets + iTarget).keplerId = newTargetKeplerIds(iTarget);
        end
    end




end

%*************************************************************************************************************
function extendedArray = extend_array_via_negative_reflection (array, nExtraDatums, negate)

    % TODO: fix this for when nExtraCadence > length(array)

    if (negate)
        error('extend_array_via_negative_reflection: negating not yet set up!');
        if (isstruct(array))
            error('extend_array_via_negative_reflection: Cannot negate a struct!');
        end
        % Negate the reflected flux
        factor = -1;
    else
        factor = 1;
    end

    if (size(array, 2) > 1)
        transposed = true;
        % column array
        if (size(array,1) > 1)
            error ('extend_array_via_negative_reflection does not work on matrices');
        end
        array = array';
    else
        transposed = false;
    end

    % This is needed so that fillArray is of the same class as array
    fillArray = array;
    fillArray = fillArray(1:0);

    datumsToAdd = nExtraDatums;
    flip = true;
    while(datumsToAdd > 0)
        if (flip)
            fillArray = [fillArray' fliplr(array)']';
            flip = false;
        else
            fillArray = [fillArray' array']';
            flip = true;
        end
        datumsToAdd = nExtraDatums - length(fillArray);
    end
    fillArray = fillArray(1:nExtraDatums);

    % row array
    extendedArray = [array' fillArray']';

    if (transposed)
        extendedArray = extendedArray';
    end

end

%*************************************************************************************************************
function extendedArray = extend_array_via_advancing (array, nExtraDatums)

    % Ignore gaps and such by taking the median. Should be close enough provided most datums are not gapped.
    medianStepSize = median(diff(array));
    extension = array(end)+medianStepSize : medianStepSize : nExtraDatums*medianStepSize + array(end) + medianStepSize*0.5;
    if (length(extension) ~= nExtraDatums)
        error('extend_array_via_advancing counting error!');
    end

    if (size(array, 1) > 1)
        % column array
        if (size(array,2) > 1)
            error ('extend_array_via_advancing does not work on matrices');
        end
        extendedArray = [array' extension]';
    else
        % row array
        extendedArray = [array extension];
    end

end

