%*************************************************************************************************************
% function targetMultiQuarterDataStruct = pdc_quarter_stitching_plot (taskMappingFile, keplerId)
%
% Stitches together all quarters available in this task directory and plots together in one plot. Alse plots MAP fits if requested.
%
% Call this function in the top level task directory.
%
% Inputs:
%   taskMappingFile     -- [char] filename for the task mapping file (task-to_channel-to-cadence -range files)
%   keplerId            -- [int] the target to plot
%
% Outputs:
%   targetMultiQuarterDataStruct    -- [struct array(nQuarters)] the collected data
%       .inputsValues               -- [float array(nCadencesThisQuarter)]
%       .inputGapIndicators         -- [logcial array(nCadencesThisQuarter)]
%       .outputsValues              -- [float array(nCadencesThisQuarter)]
%       .outputGapIndicators        -- [logcial array(nCadencesThisQuarter)]
%       .midTimestamps              -- [float array(nCadencesThisQuarter)]
%       .cadenceGapIndicators       -- [logcial array(nCadencesThisQuarter)]
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


function targetMultiQuarterDataStruct = pdc_quarter_stitching_plot (taskMappingFile, keplerId)

    nMaxQuarters = 17; % unless we fix the reaction wheel we will see no more than 17 quarters, ever! :(

    if (length(keplerId) > 1)
        error ('Only one KeplerId can be passed to pdc_quarter_stitching_plot');
    end

    %*** get the target data
    [uberTargetDataStruct, uberCadenceTimes] = pdc_collect_target_flux(taskMappingFile, keplerId);

    % There's only one target do reformulate targetMultiQuarterDataStruct accordingly

    if (length(uberTargetDataStruct) > 1)
        error ('There appears to be more than one target in uberTargetDataStruct!');
    end
    targetMultiQuarterDataStruct = uberTargetDataStruct(1).targetMultiQuarterDataStruct;
    clear uberTargetDataStruct;

    %***
    % Create full cadence times array
    startIndex = 1;
    for iQuarter = 1 : nMaxQuarters
        if (isempty(uberCadenceTimes(iQuarter).midTimestamps))
            continue
        end
        nCadences = length(uberCadenceTimes(iQuarter).midTimestamps);
        cadenceTimes.midTimestamps(startIndex:startIndex+nCadences-1) = uberCadenceTimes(iQuarter).midTimestamps;
        cadenceTimes.gapIndicators(startIndex:startIndex+nCadences-1) = uberCadenceTimes(iQuarter).cadenceGapIndicators;
        startIndex = length(cadenceTimes.midTimestamps) + 1;
    end
    % Fill gaps in cadence Times
    gapFilledMidTimestamps = pdc_fill_cadence_times (cadenceTimes);

    % Create full flux array
    startIndex = 1;
    for iQuarter = 1 : nMaxQuarters
        if (isempty(targetMultiQuarterDataStruct(iQuarter).inputValues))
            continue
        end
        nCadences = length(targetMultiQuarterDataStruct(iQuarter).inputValues);
        inputValues(startIndex:startIndex+nCadences-1)          = targetMultiQuarterDataStruct(iQuarter).inputValues;
        inputGapIndicators(startIndex:startIndex+nCadences-1)   = targetMultiQuarterDataStruct(iQuarter).inputGapIndicators;

        outputValues(startIndex:startIndex+nCadences-1)         = targetMultiQuarterDataStruct(iQuarter).outputValues;
        outputGapIndicators(startIndex:startIndex+nCadences-1)  = targetMultiQuarterDataStruct(iQuarter).outputGapIndicators;

        startIndex = length(inputValues) + 1;
    end

    % Fill data gaps 
    inputValues(inputGapIndicators) = ...
            interp1(gapFilledMidTimestamps(~inputGapIndicators), inputValues(~inputGapIndicators), ...
                                                gapFilledMidTimestamps(inputGapIndicators), 'pchip');
    % Intra gaps are filled for output flux but inter gaps are not.
    outputValues(outputGapIndicators) = ...
            interp1(gapFilledMidTimestamps(~outputGapIndicators), outputValues(~outputGapIndicators), ...
                                                gapFilledMidTimestamps(outputGapIndicators), 'pchip');
    % Don't worry about extrapolating any beginning or ending gaps

    % Stitch quarters using simple offsets
    for iQuarter = 1 : nMaxQuarters
        if (isempty(targetMultiQuarterDataStruct(iQuarter).inputValues))
            continue
        end
        outputValues = stitch_quarters(outputValues, gapFilledMidTimestamps, uberCadenceTimes(iQuarter).midTimestamps);
    end


    %***
    % Now plot!
    figure;
    plot(gapFilledMidTimestamps(~inputGapIndicators), inputValues(~inputGapIndicators), '-b');
    hold on;
    plot(gapFilledMidTimestamps(~outputGapIndicators), outputValues(~outputGapIndicators), '-r');
    legend('Input Flux', 'OutputFlux');

    % Plot markers for quarter boundaries
    maxVal = max([inputValues, outputValues]);
    minVal = min([inputValues, outputValues]);
    meanOutputValue = mean(outputValues);
    for iQuarter = 1 : nMaxQuarters
        if (isempty(uberCadenceTimes(iQuarter).midTimestamps))
            continue
        end
        plot([uberCadenceTimes(iQuarter).midTimestamps(1), uberCadenceTimes(iQuarter).midTimestamps(1)], [minVal, maxVal], '-m');
        plot([uberCadenceTimes(iQuarter).midTimestamps(end), uberCadenceTimes(iQuarter).midTimestamps(end)], [minVal, maxVal], '-m');
        % label the markers, placing text 5% above the output flux
        text(uberCadenceTimes(iQuarter).midTimestamps(1), meanOutputValue*1.005, ['Q', num2str(iQuarter)]);
    end
    title(['Kepler ID: ', num2str(keplerId)]);
    xlabel('Cadence [MJD]');
    ylabel('Flux [e- / cadence]');

end

%*************************************************************************************************************
%
% Uses a Savitsky-Golay filter to smooth the data near each quarter edge. Gaps should be filled with pchip.
% It then lines up the end of the previous quarter with the beginning of this quarter.
%
function outputValues = stitch_quarters(outputValues, gapFilledMidTimestamps, midTimestampsForThisQuarter)

    sgPolyOrder = 3;
    sgWindow = 201;

    firstCadenceIndexOfThisQuarter = find(midTimestampsForThisQuarter(1) == gapFilledMidTimestamps);
    lastCadenceIndexOfThisQuarter = find(midTimestampsForThisQuarter(end) == gapFilledMidTimestamps);
    % Check if this is the first quarter with data
    if (firstCadenceIndexOfThisQuarter == 1)
        return
    end
    
    % Not all data may be present for this taregt in this quarter.
    lastCadenceIndexOfThisQuarter = min(lastCadenceIndexOfThisQuarter, length(outputValues));
    
    % Smooth data in previous quarter
    smoothedBefore = sgolayfilt(outputValues(1:firstCadenceIndexOfThisQuarter-1), sgPolyOrder , sgWindow);

    % Smooth data in this quarter
    smoothedAfter = sgolayfilt(outputValues(firstCadenceIndexOfThisQuarter:lastCadenceIndexOfThisQuarter), sgPolyOrder, sgWindow);

    offset = smoothedBefore(end) - smoothedAfter(1);

    % Offset all values after interface
    outputValues(firstCadenceIndexOfThisQuarter:end) = outputValues(firstCadenceIndexOfThisQuarter:end) + offset;

end
