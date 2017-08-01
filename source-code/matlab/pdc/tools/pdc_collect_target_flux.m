%*************************************************************************************************************
%
% Function to collect flux target data for a specified kepler ID.
%
% Call this function in the top level task directory.
%
% Inputs:
%   taskMappingFile     -- [char] filename for the task mapping file (task-to_channel-to-cadence -range files)
%   keplerId            -- [int array(nTargets)] the targets to collect
%
% Outputs:
%   uberTargetDataStruct(:)               -- [struct array(nTargets)]
%       .targetMultiQuarterDataStruct(:)    -- [struct array(nQuarters)] the collected data
%           .inputsValues                   -- [float array(nCadencesThisQuarter)]
%           .inputGapIndicators             -- [logcial array(nCadencesThisQuarter)]
%           .outputsValues                  -- [float array(nCadencesThisQuarter)]
%           .outputGapIndicators            -- [logcial array(nCadencesThisQuarter)]
%
%   uberCadenceTimes                    -- [struct array(nQuarters)]
%       .midTimestamps                  -- [float array(nCadencesThisQuarter)]
%       .cadenceGapIndicators           -- [logcial array(nCadencesThisQuarter)]
%
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

function [uberTargetDataStruct, uberCadenceTimes] = pdc_collect_target_flux (taskMappingFile, keplerId)

    nMaxQuarters = 17; % unless we fix the reaction wheel we will see no more than 17 quarters, ever! :(

    nTargets = length(keplerId);

    %***
    % Get all the task directories for each quarter for each target

    % First find the skygroup this target is on
    % Also find the mod.out for this target in Q12
    mjdQ12 = 5.5934e+04; % Something well withing Q12

    taskDirname = cell(nTargets,1);
    skyGroup = zeros(nTargets,1);
    for iTarget = 1 : nTargets
        skyGroupStruct = retrieve_sky_group(keplerId(iTarget), mjdQ12);

        skyGroup(iTarget) = skyGroupStruct.skyGroupId;
        [module, output] = get_mod_out_from_skygroup (skyGroup(iTarget), [], [1:nMaxQuarters]);

        % Now find the task directories
        taskDirname{iTarget}.quarter = get_taskfiles_from_modout(taskMappingFile, 'pdc', [module output], [1:nMaxQuarters], 'LONG');

        display(['Done finding target ', num2str(iTarget), ' of ', num2str(nTargets)]);
    end

    %***
    % Group targets by skygroup
    [~, inThisSkyGroup] = ismember(skyGroup, [1:84]);


    %***
    % Collect the data

    targetMultiQuarterDataStruct = repmat(struct( ...
            'inputValues', [], 'inputGapIndicators', [], 'outputValues', [], 'outputGapIndicators', []), [nMaxQuarters,1]);
    uberTargetDataStruct = repmat(struct('targetMultiQuarterDataStruct', targetMultiQuarterDataStruct), [nTargets,1]);
    uberCadenceTimes     = repmat(struct('midTimestamps', [], 'cadenceGapIndicators', []), [nMaxQuarters,1]);
        
    % Extract the light curves for each quarter for each target by skyGroup
    for iSkyGroup = 1 : 84

        disp('**********************************************');
        disp([ 'Working on Sky Group ', num2str(iSkyGroup)]);

        targetsInThisSkyGroup = find(inThisSkyGroup == iSkyGroup);
        if(isempty(targetsInThisSkyGroup))
            continue;
        end
        firstTargetInThisSkyGroup = targetsInThisSkyGroup(1);

        for iQuarter = 1 : nMaxQuarters
            if (isempty(taskDirname{firstTargetInThisSkyGroup}.quarter{iQuarter}))
                % Task not found for this channel and quarter
               %disp(['task not found for quarter ', num2str(iQuarter)]);
                continue;
            end

            disp(['Loading data for Sky Group ', num2str(iSkyGroup), ' quarter ', num2str(iQuarter)]);
            load([taskDirname{firstTargetInThisSkyGroup}.quarter{iQuarter}, '/', 'pdc-inputs-0.mat']);
            load([taskDirname{firstTargetInThisSkyGroup}.quarter{iQuarter}, '/', 'pdc-outputs-0.mat']);

            % process the channelDataStruct 
            inputsStruct = pdcInputClass.process_channelDataStruct(inputsStruct);

            % Get target indices in targetMultiQuarterDataStruct array
            [~, targetIndices] = ismember(keplerId(targetsInThisSkyGroup), [inputsStruct.targetDataStruct.keplerId]);
            for iTarget = 1 : length(targetsInThisSkyGroup)
                if (targetIndices(iTarget) == 0)
                    % target not found in this quarter
                    disp(['Target not found for quarter ', num2str(iQuarter)]);
                    continue;
                end
                uberTargetDataStruct(targetsInThisSkyGroup(iTarget)).targetMultiQuarterDataStruct(iQuarter).inputValues             = ...
                                    inputsStruct.targetDataStruct(targetIndices(iTarget)).values;
                uberTargetDataStruct(targetsInThisSkyGroup(iTarget)).targetMultiQuarterDataStruct(iQuarter).inputGapIndicators      = ...
                                    inputsStruct.targetDataStruct(targetIndices(iTarget)).gapIndicators;

                uberTargetDataStruct(targetsInThisSkyGroup(iTarget)).targetMultiQuarterDataStruct(iQuarter).outputValues            = ...
                                    outputsStruct.targetResultsStruct(targetIndices(iTarget)).correctedFluxTimeSeries.values;
                uberTargetDataStruct(targetsInThisSkyGroup(iTarget)).targetMultiQuarterDataStruct(iQuarter).outputGapIndicators     = ...
                                    outputsStruct.targetResultsStruct(targetIndices(iTarget)).correctedFluxTimeSeries.gapIndicators;
                
            end

            uberCadenceTimes(iQuarter).midTimestamps        = inputsStruct.cadenceTimes.midTimestamps;
            uberCadenceTimes(iQuarter).cadenceGapIndicators = inputsStruct.cadenceTimes.gapIndicators;
                
            clear inputsStruct outputsStruct;
        end
        disp([ 'Sky Group ', num2str(iSkyGroup), ' structures loaded.']);
    end

return
