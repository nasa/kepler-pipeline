%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [conditionedAncillaryDataStruct, alerts] = ...
% synchronize_ancillary_data(cadenceType, cadenceTimes, longCadenceTimes, ...
%     ccdModule, ccdOutput, ancillaryEngineeringConfigurationStruct, ...
%     ancillaryEngineeringDataStruct, ancillaryPipelineConfigurationStruct, ...
%     ancillaryPipelineDataStruct, ancillaryTargetConfigurationStruct, ...
%     attitudeSolutionStruct, fcConstants, spacecraftConfigMap, raDec2PixModel, ...
%     gapFillConfigurationStruct, targetDataAvailable, debugLevel, alerts)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Process the ancillary data on a channel by channel basis. Determine the
% sampling rate for each channel. If the data to be corrected are long
% cadence and the sampling rate for a given channel is greater than or equal
% to the short cadence rate, then bin the data to the short cadence
% intervals and decimate to the long cadence intervals. If the sampling rate
% for a given channel is less than the short cadence rate then bin directly
% to the long cadence intervals. Fill in (short) gaps prior to decimation
% from the short to long cadence rate. If all gaps cannot be filled then
% issue a warning that the data cannot be conditioned. If the data are
% binned directly to the long cadence rate then fill in any (short) gaps in
% the binned data. If any gaps remain where target data are available then
% issue a warning that the data cannot be conditioned. Long gaps cannot be
% filled for the purpose of ancillary data conditioning.
%
% If the data to be corrected are short cadence and the sampling rate for a
% given channel is less than or equal to the long cadence rate, then bin
% the data to the short cadence intervals and interpolate to the long
% cadence intervals. If the sampling rate for a given channel is greater
% than the long cadence rate then bin directly to the short cadence
% intervals. Fill in (short) gaps prior to interpolation from the long to
% short cadence rate. If all gaps cannot be filled then issue a warning that
% the data cannot be conditioned. If the data are binned directly to the
% short cadence rate then fill in any (short) gaps in the binned data. If
% any gaps remain where target data are available then issue a warning that
% the data cannot be conditioned.
%
% It is implicit that the timestamps for the conditioned ancillary data
% match the cadence timestamps in the unit of work.
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
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

function [conditionedAncillaryDataStruct, alerts] = ...
synchronize_ancillary_data(cadenceType, cadenceTimes, longCadenceTimes, ...
    ccdModule, ccdOutput, ancillaryEngineeringConfigurationStruct, ...
    ancillaryEngineeringDataStruct, ancillaryPipelineConfigurationStruct, ...
    ancillaryPipelineDataStruct, ancillaryTargetConfigurationStruct, ...
    attitudeSolutionStruct, fcConstants, spacecraftConfigMap, raDec2PixModel, ...
    gapFillConfigurationStruct, targetDataAvailable, debugLevel, alerts)

% Set the (fractional) interval tolerance for binning.
INTERVAL_TOLERANCE = 0.05;

% Get all of the timetags and cadence gap indicators.
cadenceStartTimes = cadenceTimes.startTimestamps;
cadenceMidTimes = cadenceTimes.midTimestamps;
cadenceEndTimes = cadenceTimes.endTimestamps;
cadenceGapIndicators = cadenceTimes.gapIndicators;
nCadences = length(cadenceGapIndicators);

% If attitude solution exists, create course grid of pseudo-stars and use
% the attitude solution to trace their paths across the CCD over the course
% of the unit of work. Append these time series to the existing pipeline
% ancillary for cotrending.
[ancillaryPipelineConfigurationStruct, ancillaryPipelineDataStruct] = ...
    merge_star_positions_with_ancillary_pipeline_structures( ...
    ancillaryTargetConfigurationStruct, attitudeSolutionStruct, ...
    ancillaryPipelineConfigurationStruct, ancillaryPipelineDataStruct, ...
    ccdModule, ccdOutput, longCadenceTimes, fcConstants, raDec2PixModel);

% Get the numbers of ancillary engineering and pipeline data channels.
% Return if there is no ancillary data available.
nEngineeringChannels = length(ancillaryEngineeringDataStruct);
nPipelineChannels = length(ancillaryPipelineDataStruct);

if 0 == nEngineeringChannels + nPipelineChannels
    conditionedAncillaryDataStruct = [];
    [alerts] = add_alert(alerts, 'warning', ...
        'no ancillary data available for systematic error correction');
    disp(alerts(end).message);
    return
end

% Check for valid cadence type. If not 'long' or 'short' it will have
% failed validation.
if strcmpi(cadenceType, 'long')
    processLongCadence = true;
elseif strcmpi(cadenceType, 'short')
    processLongCadence = false;
end

% Get the shortCadencesPerLongCadence from the spacecraft config map.
configMapObject = configMapClass(spacecraftConfigMap);

[numberOfExposuresPerLongCadence] = ...
    get_number_of_exposures_per_long_cadence_period(configMapObject, ...
    cadenceMidTimes(~cadenceGapIndicators));
[numberOfExposuresPerShortCadence] = ...
    get_number_of_exposures_per_short_cadence_period(configMapObject, ...
    cadenceMidTimes(~cadenceGapIndicators));

shortCadencesPerLongCadence = median(numberOfExposuresPerLongCadence ./ ...
    numberOfExposuresPerShortCadence);

% Create cell arrays with the ancillary interaction pairs.
[ancillaryEngineeringInteractionPairs] = ...
    generate_interactions_cell_array(ancillaryEngineeringConfigurationStruct.interactions);
[ancillaryPipelineInteractionPairs] = ...
    generate_interactions_cell_array(ancillaryPipelineConfigurationStruct.interactions);

% Get the model orders and interactions for each of the ancillary
% engineering data channels. Compute the uncertainties from the intrinsic
% uncertainties and quantization levels. Issue a warning if configuration
% parameters (model orders, interactions, intrinsic uncertainties, 
% quantization levels) are not available for any engineering mnemonics.
nChannels = 0;

for iChannel = 1 : nEngineeringChannels
    
    ancillaryStruct = ancillaryEngineeringDataStruct(iChannel);
    isMatch = strcmpi(ancillaryStruct.mnemonic, ...
        ancillaryEngineeringConfigurationStruct.mnemonics);
    if 0 == sum(isMatch)
        string = ['configuration parameters unavailable for mnemonic ', ...
            ancillaryStruct.mnemonic];
        [alerts] = add_alert(alerts, 'warning', string);
        disp(string);
        continue;
    else
        isMatch = isMatch & cumsum(isMatch) <= 1;
    end
    
    ancillaryStruct.isAncillaryEngineeringData = true;
    ancillaryStruct.modelOrder = ...
        ancillaryEngineeringConfigurationStruct.modelOrders(isMatch);
    [ancillaryStruct.interactions] = ...
        get_interactions_for_mnemonic(ancillaryStruct.mnemonic, ...
        ancillaryEngineeringInteractionPairs);
    ancillaryStruct.uncertainties = repmat(sqrt( ...
        ancillaryEngineeringConfigurationStruct.intrinsicUncertainties(isMatch) ^ 2 + ...
        (ancillaryEngineeringConfigurationStruct.quantizationLevels(isMatch) ^ 2) / 12), ...
        size(ancillaryStruct.values));
    
    nChannels = nChannels + 1;
    ancillaryDataStruct(nChannels) = orderfields(ancillaryStruct);                                                   %#ok<AGROW>
    
end % for

% Get the model orders and interactions for each of the ancillary
% pipeline data channels. Append to the ancillary engineering channels.
% Issue a warning if configuration parameters (model orders, interactions)
% are not available for any pipeline mnemonics.
for iChannel = 1 : nPipelineChannels
    
    ancillaryStruct = ancillaryPipelineDataStruct(iChannel);
    isMatch = strcmpi(ancillaryStruct.mnemonic, ...
        ancillaryPipelineConfigurationStruct.mnemonics);
    if 0 == sum(isMatch)
        string = ['configuration parameters unavailable for mnemonic ', ...
            ancillaryStruct.mnemonic];
        [alerts] = add_alert(alerts, 'warning', string);
        disp(string);
        continue;
    else
        isMatch = isMatch & cumsum(isMatch) <= 1;
    end
    
    ancillaryStruct.isAncillaryEngineeringData = false;
    ancillaryStruct.modelOrder = ...
        ancillaryPipelineConfigurationStruct.modelOrders(isMatch);
    [ancillaryStruct.interactions] = ...
        get_interactions_for_mnemonic(ancillaryStruct.mnemonic, ...
        ancillaryPipelineInteractionPairs);
    
    nChannels = nChannels + 1;
    ancillaryDataStruct(nChannels) = orderfields(ancillaryStruct);                                                   %#ok<AGROW>
    
end % for

% Interpolate any missing cadence time tags. Ancillary data will be binned
% and/or resampled to all of the cadence intervals, not only the available
% cadence intervals.
if any(cadenceGapIndicators)

    cadences = (1 : nCadences)';
    t0 = cadenceStartTimes(find(~cadenceGapIndicators, 1));

    p = polyfit(cadences(~cadenceGapIndicators), ...
        cadenceStartTimes(~cadenceGapIndicators) - t0, 1);
    cadenceStartTimes(cadenceGapIndicators) = ...
        polyval(p, cadences(cadenceGapIndicators)) + t0;
    
    p = polyfit(cadences(~cadenceGapIndicators), ...
        cadenceEndTimes(~cadenceGapIndicators) - t0, 1);
    cadenceEndTimes(cadenceGapIndicators) = ...
        polyval(p, cadences(cadenceGapIndicators)) + t0;

end % if

% Initialize the conditioned ancillary data output structure.
ancillaryTimeSeries = struct( ...
    'values', [], ...
    'uncertainties', [], ...
    'gapIndicators', [] );

conditionedAncillaryDataStruct = repmat(struct( ...
    'mnemonic', [], ...
    'isAncillaryEngineeringData', [], ...
    'modelOrder', [], ...
    'interactions', [], ...
    'ancillaryTimeSeries', ancillaryTimeSeries), [1, nChannels]);

% Pre-allocate space for the resampling filters, squared resampling
% filters and filter delays.
nStages = 2;
resamplingFilters = cell([1, 2]);
squaredResamplingFilters = cell([1, 2]);
resamplingFilterDelays = zeros([1, 2]);
dataPads = cell([1, 2]);
gapPads = cell([1, 2]);
nValuesToIgnore = zeros([1, 2]);

% Compute the median cadence interval and the cadence bin edges. Add a final
% bin edge with the last cadence end time to ensure that samples in the
% final cadence interval are properly binned.
medianCadenceInterval = median(diff(cadenceStartTimes));
cadenceBinEdges = [cadenceStartTimes ; cadenceEndTimes(end)];

% If the flag is set, condition the ancillary data for long cadence processing.
% Otherwise, condition for short cadence processing. Track the channels
% that cannot be adequately conditioned.
isConditioned = true([1, nChannels]);

if processLongCadence
    
    % Set the edges for the intermediate bins. Note that an additional
    % "final" bin edge is defined. Any samples falling exactly on this edge
    % will be discarded in the binning process. The final edge does ensure,
    % however, that all samples in the final intermediate bin are properly
    % accounted for. The nominal intervals are set to the short cadence
    % intervals. Long cadence mid times are used to set the intermediate
    % bin edges to ensure the proper phasing between the input and
    % decimated ancillary data series.
    nIntermediateBins = shortCadencesPerLongCadence * nCadences;
    nominalIntermediateInterval = ...
        (cadenceEndTimes(end) - cadenceStartTimes(1)) / nIntermediateBins;
    intermediateBinEdges = cadenceMidTimes(1) + ...
        ((0 : nIntermediateBins)' - 0.5) * nominalIntermediateInterval;
    
    % Set decimation factors, resampling filters, squared filters and
    % filter delays. Decimation is performed in multiple stages to minimize
    % sharpness, length and delay of required filters. This may be done in
    % a more general way.
    x = ones([nIntermediateBins, 1]);
    
    if 15 == shortCadencesPerLongCadence
        decimationFactors = [3 5];
    elseif 20 == shortCadencesPerLongCadence
        decimationFactors = [4 5];
    elseif 30 == shortCadencesPerLongCadence
        decimationFactors = [5 6];
    elseif 60 == shortCadencesPerLongCadence
        decimationFactors = [6 10];
    else
        error('AncillaryDataConditioning:invalidShortsPerLong', ...
            'Invalid number of short cadences per long cadence (%d)', ...
            shortCadencesPerLongCadence)
    end
        
    for iStage = 1 : nStages
        [y, resamplingFilters{iStage}] = ...
            resample(x, 1, decimationFactors(iStage));
        squaredResamplingFilters{iStage} = resamplingFilters{iStage} .^ 2;
        resamplingFilterDelays(iStage) = ...
            (length(resamplingFilters{iStage}) - 1) / 2;
        dataPads{iStage} = zeros([resamplingFilterDelays(iStage), 1]);
        gapPads{iStage} = true([resamplingFilterDelays(iStage), 1]);
        nValuesToIgnore(iStage) = ...
            resamplingFilterDelays(iStage) / decimationFactors(iStage);
    end
    
    clear x y;
        
    % Loop through the ancillary data channels.
    for iChannel = 1 : nChannels
        
        % Disregard any ancillary data samples if the associated
        % uncertainty is less than or equal to zero.
        isInvalidUncertainty = ...
            ancillaryDataStruct(iChannel).uncertainties <= 0;
        if any(isInvalidUncertainty)
            ancillaryDataStruct(iChannel).timestamps = ...
                ancillaryDataStruct(iChannel).timestamps(~isInvalidUncertainty);                                     %#ok<AGROW>
            ancillaryDataStruct(iChannel).values = ...
                ancillaryDataStruct(iChannel).values(~isInvalidUncertainty);                                         %#ok<AGROW>
            ancillaryDataStruct(iChannel).uncertainties = ...
                ancillaryDataStruct(iChannel).uncertainties(~isInvalidUncertainty);                                  %#ok<AGROW>
            string = ['one or more uncertainties for mnemonic ', ancillaryDataStruct(iChannel).mnemonic, ...
                ' are <= 0; the associated value(s) will be ignored'];
            [alerts] = add_alert(alerts, 'warning', string);
            disp(string);
        end % if
        
        % Check if there is any valid ancillary data.
        timestamps = ancillaryDataStruct(iChannel).timestamps;
        if isempty(timestamps)
            isConditioned(iChannel) = false;
            continue;
        end
        
        % Get the median sample interval for the given channel.
        medianAncillaryDataInterval = median(diff(timestamps));
        
        % If the median ancillary data interval is not greater than the
        % nominal intermediate interval then bin to the intermediate
        % intervals and decimate to the long cadence rate.
        if medianAncillaryDataInterval <= ...
                nominalIntermediateInterval * (1 + INTERVAL_TOLERANCE);
            
            % Remove and save the mean value.
            meanValue = mean(ancillaryDataStruct(iChannel).values);
            ancillaryDataStruct(iChannel).values = ...
                ancillaryDataStruct(iChannel).values - meanValue;                                                    %#ok<AGROW>
            
            % First bin to the intermediate intervals.
            [binnedValues, uncertaintyInBinnedValues, binnedDataGapIndicators] = ...
                bin_ancillary_data(ancillaryDataStruct(iChannel), ...
                intermediateBinEdges);
            
            % Resample with zero delay filters to the long cadence rate and compute
            % the uncertainties for the decimated ancillary values. Create and
            % fill gaps equal in duration to the resampling filter delays before
            % and after the time series to be resampled to greatly reduce resampling
            % edge effects.
            resampledValues = binnedValues;
            uncertaintyInResampledValues = uncertaintyInBinnedValues;
            resampledDataGapIndicators = binnedDataGapIndicators;
            
            for iStage = 1 : nStages
                
                resampledValues = ...
                    [dataPads{iStage} ; resampledValues ; dataPads{iStage}];                                         %#ok<AGROW>
                uncertaintyInResampledValues = ...
                    [dataPads{iStage} ; uncertaintyInResampledValues ; dataPads{iStage}];                            %#ok<AGROW>
                resampledDataGapIndicators = ...
                    [gapPads{iStage} ; resampledDataGapIndicators ; gapPads{iStage}];                                %#ok<AGROW>
                
                [resampledValues, masterIndexOfAstroEvents, ...
                    resampledDataGapIndicators, uncertaintyInResampledValues] = ...
                    fill_short_data_gaps(resampledValues, resampledDataGapIndicators, 0, ...
                    debugLevel, gapFillConfigurationStruct, uncertaintyInResampledValues);
                if any(resampledDataGapIndicators)
                    isConditioned(iChannel) = false;
                end
                
                varianceOfResampledValues = uncertaintyInResampledValues .^ 2;
                resampledValues = ...
                    resample(resampledValues, 1, decimationFactors(iStage));
                varianceOfResampledValues = upfirdn(varianceOfResampledValues, ...
                    squaredResamplingFilters{iStage}, 1, decimationFactors(iStage));
                
                resampledValues(1 : nValuesToIgnore(iStage)) = [];
                resampledValues(end - nValuesToIgnore(iStage) + 1 : end) = [];
                varianceOfResampledValues(1 : 2 * nValuesToIgnore(iStage)) = [];
                varianceOfResampledValues(end - 2 * nValuesToIgnore(iStage) + 1 : end) = [];
                
                uncertaintyInResampledValues = sqrt(varianceOfResampledValues);
                resampledDataGapIndicators = false(size(resampledValues));
                
            end
              
            % Assign fields to the output structure. Restore the mean value.
            % There cannot be any gaps in the conditioned sequence because
            % gaps were filled prior to decimation.
            [conditionedAncillaryDataStruct(iChannel).ancillaryTimeSeries] = ...
                populate_timeseries_structure(resampledValues + meanValue, ...
                uncertaintyInResampledValues, resampledDataGapIndicators);
      
        else % median ancillary interval is longer than intermediate intervals
            
            % Bin directly to the long cadence cadence intervals.
            [binnedValues, uncertaintyInBinnedValues, binnedDataGapIndicators] = ...
                bin_ancillary_data(ancillaryDataStruct(iChannel), ...
                cadenceBinEdges);
            
            % Fill gaps if there are any relative flux time samples for
            % which the corresponding ancillary data sample is missing.
            ancillaryGapsToBeFilled = ...
                binnedDataGapIndicators & targetDataAvailable;
            if any(ancillaryGapsToBeFilled)
                [binnedValues, masterIndexOfAstroEvents, ...
                    binnedDataGapIndicators, uncertaintyInBinnedValues] = ...
                    fill_short_data_gaps(binnedValues, binnedDataGapIndicators, 0, ...
                    debugLevel, gapFillConfigurationStruct, uncertaintyInBinnedValues);
                if any(binnedDataGapIndicators & targetDataAvailable)
                    isConditioned(iChannel) = false;
                end
            end
            
            % Assign fields to the output structure.
            [conditionedAncillaryDataStruct(iChannel).ancillaryTimeSeries] = ...
                populate_timeseries_structure(binnedValues, ...
                uncertaintyInBinnedValues, binnedDataGapIndicators);
            
        end % if/else
        
    end % for iChannel
    
else % must be short cadence data
    
    % Set the intermediate intervals to long cadence intervals. Add
    % additional interval at beginning to permit correct phasing between
    % long and short cadences.
    nominalIntermediateInterval = ...
        shortCadencesPerLongCadence * medianCadenceInterval;
    intermediateBinEdges = ...
        downsample(cadenceMidTimes, shortCadencesPerLongCadence);
    intermediateBinEdges = ...
        [intermediateBinEdges(1) - nominalIntermediateInterval ; ...
        intermediateBinEdges ; intermediateBinEdges(end) + ...
        nominalIntermediateInterval];
    
    % Set interpolation factors, resampling filters, squared filters and
    % filter delays. Decimation is performed in multiple stages to minimize
    % sharpness, length and delay of required filters. THIS MAY BE DONE IN A
    % MORE GENERAL WAY.
    x = ones([nCadences, 1]);
    
    if 15 == shortCadencesPerLongCadence
        interpolationFactors = [5 3];
    elseif 20 == shortCadencesPerLongCadence
        interpolationFactors = [5 4];
    elseif 30 == shortCadencesPerLongCadence
        interpolationFactors = [6 5];
    elseif 60 == shortCadencesPerLongCadence
        interpolationFactors = [10 6];
    else
        error('AncillaryDataConditioning:invalidShortsPerLong', ...
            'Invalid number of short cadences per long cadence (%d)', ...
            shortCadencesPerLongCadence)
    end
        
    for iStage = 1 : nStages
        [y, resamplingFilters{iStage}] = ...
            resample(x, interpolationFactors(iStage), 1);
        squaredResamplingFilters{iStage} = resamplingFilters{iStage} .^ 2;
        resamplingFilterDelays(iStage) = ...
            (length(resamplingFilters{iStage}) - 1) / 2;
        dataPads{iStage} = zeros([resamplingFilterDelays(iStage) / ...
            interpolationFactors(iStage), 1]);
        gapPads{iStage} = true([resamplingFilterDelays(iStage) / ...
            interpolationFactors(iStage), 1]);
        nValuesToIgnore(iStage) = resamplingFilterDelays(iStage);
    end
    
    clear x y;
    
    % Loop through the ancillary data channels.
    for iChannel = 1 : nChannels
        
        % Disregard any ancillary data samples if the associated
        % uncertainty is less than or equal to zero.
        isInvalidUncertainty = ...
            ancillaryDataStruct(iChannel).uncertainties <= 0;
        if any(isInvalidUncertainty)
            ancillaryDataStruct(iChannel).timestamps = ...
                ancillaryDataStruct(iChannel).timestamps(~isInvalidUncertainty);                                     %#ok<AGROW>
            ancillaryDataStruct(iChannel).values = ...
                ancillaryDataStruct(iChannel).values(~isInvalidUncertainty);                                         %#ok<AGROW>
            ancillaryDataStruct(iChannel).uncertainties = ...
                ancillaryDataStruct(iChannel).uncertainties(~isInvalidUncertainty);                                  %#ok<AGROW>
            string = ['one or more uncertainties for mnemonic ', ancillaryDataStruct(iChannel).mnemonic, ...
                ' are <= 0; the associated value(s) will be ignored'];
            [alerts] = add_alert(alerts, 'warning', string);
            disp(string);
        end % if
        
        % Check if there is any valid ancillary data.
        timestamps = ancillaryDataStruct(iChannel).timestamps;
        if isempty(timestamps)
            isConditioned(iChannel) = false;
            continue;
        end
        
        % Get the median sample interval for the given channel.
        medianAncillaryDataInterval = median(diff(timestamps));
    
        if medianAncillaryDataInterval <= ...
                medianCadenceInterval * (1 + INTERVAL_TOLERANCE)
            
            % Bin directly to the short cadence intervals.
            [binnedValues, uncertaintyInBinnedValues, binnedDataGapIndicators] = ...
                bin_ancillary_data(ancillaryDataStruct(iChannel), ...
                cadenceBinEdges);
            
            % Fill gaps if there are any relative flux time samples for
            % which the corresponding ancillary data sample is missing.
            ancillaryGapsToBeFilled = ...
                binnedDataGapIndicators & targetDataAvailable;
            if any(ancillaryGapsToBeFilled)
                [binnedValues, masterIndexOfAstroEvents, ...
                    binnedDataGapIndicators, uncertaintyInBinnedValues] = ...
                    fill_short_data_gaps(binnedValues, binnedDataGapIndicators, 0, ...
                    debugLevel, gapFillConfigurationStruct, uncertaintyInBinnedValues);
                if any(binnedDataGapIndicators & targetDataAvailable)
                    isConditioned(iChannel) = false;
                end
            end
            
            % Assign fields to the output structure.
            [conditionedAncillaryDataStruct(iChannel).ancillaryTimeSeries] = ...
                populate_timeseries_structure(binnedValues, ...
                uncertaintyInBinnedValues, binnedDataGapIndicators);
            
        else % median ancillary interval is longer than short cadence intervals
        
            % Remove and save the mean value.
            meanValue = mean(ancillaryDataStruct(iChannel).values);
            ancillaryDataStruct(iChannel).values = ...
                ancillaryDataStruct(iChannel).values - meanValue;                                                    %#ok<AGROW>
            
            % First bin to the long cadence intervals.
            [binnedValues, uncertaintyInBinnedValues, binnedDataGapIndicators] = ...
                bin_ancillary_data(ancillaryDataStruct(iChannel), ...
                intermediateBinEdges);
            
            % Interpolate to the short cadence rate with zero delay filters
            % and compute the uncertainties for the interpolated ancillary
            % values. Create and fill gaps before and after the time series
            % to be resampled to greatly reduce resampling edge effects.
            resampledValues = binnedValues;
            uncertaintyInResampledValues = uncertaintyInBinnedValues;
            resampledDataGapIndicators = binnedDataGapIndicators;
            
            for iStage = 1 : nStages
                
                resampledValues = ...
                    [dataPads{iStage} ; resampledValues ; dataPads{iStage}];                                         %#ok<AGROW>
                uncertaintyInResampledValues = ...
                    [dataPads{iStage} ; uncertaintyInResampledValues ; dataPads{iStage}];                            %#ok<AGROW>
                resampledDataGapIndicators = ...
                    [gapPads{iStage} ; resampledDataGapIndicators ; gapPads{iStage}];                                %#ok<AGROW>
                
                [resampledValues, masterIndexOfAstroEvents, ...
                    resampledDataGapIndicators, uncertaintyInResampledValues] = ...
                    fill_short_data_gaps(resampledValues, resampledDataGapIndicators, 0, ...
                    debugLevel, gapFillConfigurationStruct, uncertaintyInResampledValues);
                if any(resampledDataGapIndicators)
                    isConditioned(iChannel) = false;
                end
                
                varianceOfResampledValues = uncertaintyInResampledValues .^ 2;
                resampledValues = ...
                    resample(resampledValues, interpolationFactors(iStage), 1);
                varianceOfResampledValues = upfirdn(varianceOfResampledValues, ...
                    squaredResamplingFilters{iStage}, interpolationFactors(iStage), 1);
                
                resampledValues(1 : nValuesToIgnore(iStage)) = [];
                resampledValues(end - nValuesToIgnore(iStage) + 1 : end) = [];
                varianceOfResampledValues(1 : 2 * nValuesToIgnore(iStage)) = [];
                varianceOfResampledValues(end - (2 * nValuesToIgnore(iStage) - ...
                    interpolationFactors(iStage)) : end) = [];
                
                uncertaintyInResampledValues = sqrt(varianceOfResampledValues);
                resampledDataGapIndicators = false(size(resampledValues));
                
            end
            
            % Remove half of the resampled values from the virtual (first)
            % intermediate interval for proper phasing between the input
            % and interpolated data.
            resampledValues(1 : shortCadencesPerLongCadence/2) = [];
            uncertaintyInResampledValues(1 : shortCadencesPerLongCadence/2) = [];
            resampledDataGapIndicators(1 : shortCadencesPerLongCadence/2) = [];
            
            % Assign fields to the output structure. Restore the mean value.
            % There cannot be any gaps in the conditioned sequence because
            % gaps were filled prior to interpolation.
            [conditionedAncillaryDataStruct(iChannel).ancillaryTimeSeries] = ...
                populate_timeseries_structure( ...
                resampledValues(1 : nCadences) + meanValue, ...
                uncertaintyInResampledValues(1 : nCadences), ...
                resampledDataGapIndicators(1 : nCadences));
            
        end % if/else
        
    end % for iChannel
    
end % if processLongCadence/else

% Finish populating the output structures. Set the time stamps for all channels to
% the midpoints of the cadence intervals.
for iChannel = 1 : nChannels
    conditionedAncillaryDataStruct(iChannel).mnemonic = ...
        ancillaryDataStruct(iChannel).mnemonic;
    conditionedAncillaryDataStruct(iChannel).isAncillaryEngineeringData = ...
        ancillaryDataStruct(iChannel).isAncillaryEngineeringData;
    conditionedAncillaryDataStruct(iChannel).modelOrder = ...
        ancillaryDataStruct(iChannel).modelOrder;
    conditionedAncillaryDataStruct(iChannel).interactions = ...
        ancillaryDataStruct(iChannel).interactions;
end

% Remove the channels that could not be properly conditioned due to the
% inability to fill required gaps. Issue an alert for each mnemonic to be
% ignored.
if any(~isConditioned)
    for iChannel = find(~isConditioned)
        string = ['mnemonic ', conditionedAncillaryDataStruct(iChannel).mnemonic, ...
            ' cannot be conditioned for data processing'];
        [alerts] = add_alert(alerts, 'warning', string);
        disp(string);
    end % for
    conditionedAncillaryDataStruct = ...
        conditionedAncillaryDataStruct(isConditioned);
end % if

% Return
return
