%% synchronize_ancillary_data_mp.m
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [conditionedAncillaryDataStruct, alerts] = ...
%   synchronize_ancillary_data_mp(cadenceTimes, ...
%   longCadenceTimes, ancillaryEngineeringConfigurationStruct, ...
%   ancillaryEngineeringDataStruct, ancillaryPipelineConfigurationStruct, ...
%   ancillaryPipelineDataStruct, motionPolyStruct, alerts)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% This function synchronizes the ancillary data to the flux time cadences.  The
% ancillary data is not necessarily sampled at each cadence and this function
% resamples to the target cadences using Matlab's "spline" function.
%
% The ancillary data is processed on a channel by channel basis. The sampling
% for each channel is simply the cadences for the target data (be it long or
% short cadence). If the ancillary data sampling rate is much faster then the
% cadence rate then the ancillary data is first binned and then passed thorugh
% the spline. Any other ancillary data timestamps that are too close together
% are merged to not confuse the spline interpolator.
%
% Gaps are filled using a simple polyfit linear interpolation. The ancillary
% data is extrapolated a couple timstamps past each end using ployfit so that the
% spline interpolator will correctly model the edges.
%
% There are no assumptions that the flux cadence or ancillary timerstamp
% intervals are uniform. The routine will resample to arbitrary cadence
% intervals.
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%%
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
    synchronize_ancillary_data_mp(cadenceTimes, ...
    longCadenceTimes, ancillaryEngineeringConfigurationStruct, ...
    ancillaryEngineeringDataStruct, ancillaryPipelineConfigurationStruct, ...
    ancillaryPipelineDataStruct, motionPolyStruct, alerts)

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%% Parse the input data

% Get the timetags and cadence gap indicators.
interpolatedCadenceTimes = cadenceTimes.midTimestamps;
cadenceGapIndicators = cadenceTimes.gapIndicators;
nCadences = length(cadenceGapIndicators);

% Interpolate any missing cadence time tags. Ancillary data will be binned
% and/or resampled to all of the cadence intervals, not only the available
% cadence intervals.
if any(cadenceGapIndicators)

    cadences = (1 : nCadences)';
    t0 = interpolatedCadenceTimes(find(~cadenceGapIndicators, 1));

    p = polyfit(cadences(~cadenceGapIndicators), ...
        interpolatedCadenceTimes(~cadenceGapIndicators) - t0, 1);
    interpolatedCadenceTimes(cadenceGapIndicators) = ...
        polyval(p, cadences(cadenceGapIndicators)) + t0;
    cadenceGapIndicators = false(size(interpolatedCadenceTimes,1),1); % no more gaps
    
end % if

% Merge motion polynomials with the existing pipeline ancillary for
% cotrending.
[ancillaryPipelineConfigurationStruct, ancillaryPipelineDataStruct] = ...
    merge_motion_polynomials_with_ancillary_pipeline_structures( ...
    longCadenceTimes, motionPolyStruct, ...
    ancillaryPipelineConfigurationStruct, ancillaryPipelineDataStruct);

% Get the numbers of ancillary engineering and pipeline data channels.
% Return if there is no ancillary data available.
nEngineeringChannels = length(ancillaryEngineeringDataStruct);
nPipelineChannels = length(ancillaryPipelineDataStruct);

if 0 == nEngineeringChannels + nPipelineChannels
    conditionedAncillaryDataStruct = [];
    [alerts] = add_alert(alerts, 'warning', ...
        'No ancillary data available for systematic error correction.');
    disp(alerts(end).message);
    return
end % if

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
    end % if / else
    
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
    ancillaryDataStruct(nChannels) = orderfields(ancillaryStruct);
    
end % for iChannel : nEngineeringChannels

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
    end % if / else
    
    ancillaryStruct.isAncillaryEngineeringData = false;
    ancillaryStruct.modelOrder = ...
        ancillaryPipelineConfigurationStruct.modelOrders(isMatch);
    [ancillaryStruct.interactions] = ...
        get_interactions_for_mnemonic(ancillaryStruct.mnemonic, ...
        ancillaryPipelineInteractionPairs);
    
    nChannels = nChannels + 1;
    ancillaryDataStruct(nChannels) = orderfields(ancillaryStruct);                                                   %#ok<AGROW>
    
end % for iChannel : nPipelineChannels

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%% Initialize output structures

% Initialize the conditioned ancillary data output structure.
ancillaryTimeSeries = struct( ...
    'values', [], ...
    'uncertainties', [], ...
    'gapIndicators', [], ...
    'timestamps', []);

conditionedAncillaryDataStruct = repmat(struct( ...
    'mnemonic', [], ...
    'isAncillaryEngineeringData', [], ...
    'modelOrder', [], ...
    'interactions', [], ...
    'ancillaryTimeSeries', ancillaryTimeSeries), [1, nChannels]);

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%% Interpolate using spline

% We don't care if it is long or short cadence data!
% Just interpolate to the cadence data. That's the beauty of spline.

interpolatedData = [];
interpolatedUncertainties = [];

% Initialize temporary gap filled ancillary data structure.
gapFilledAncillaryDataStruct = repmat(struct( ...
    'interactions', [], ...
    'isAncillaryEngineeringData', [], ...
    'mnemonic', [], ...
    'modelOrder', [], ...
    'timestamps', [], ...
    'uncertainties', [], ...
    'values', []), ...
    [1, nChannels]);
binnedAncillaryDataStruct = gapFilledAncillaryDataStruct; 
extendedAncillaryDataStruct = gapFilledAncillaryDataStruct; 


for iChannel = 1 : nChannels

    % The spline will be unconstrained and might go crazy through large gaps in
    % data so Fill gaps using a simple linear model
    gapFilledAncillaryDataStruct(iChannel) = fill_ancillary_data_gaps(ancillaryDataStruct(iChannel));
                
    % Downsampling with a spline can be unreliable so first bin the data if need
    % be. Also, remove isolated closely spaced timstamps
    binnedAncillaryDataStruct(iChannel) = ...
        rebin_ancillary_data(gapFilledAncillaryDataStruct(iChannel), interpolatedCadenceTimes, cadenceGapIndicators);

    % Linearly extrapolate two more points on either side of the data so that the spline is constrained at the
    % edges.
    extendedAncillaryDataStruct(iChannel) = extrapolate_ancillary_data(binnedAncillaryDataStruct(iChannel), alerts);

    % Disregard any ancillary data samples if the associated
    % uncertainty is less than zero.
    isInvalidUncertainty = extendedAncillaryDataStruct(iChannel).uncertainties < 0;
    if any(isInvalidUncertainty)
        extendedAncillaryDataStruct(iChannel).timestamps    = ...
            extendedAncillaryDataStruct(iChannel).timestamps(~isInvalidUncertainty);                                     %#ok<AGROW>
        extendedAncillaryDataStruct(iChannel).values        = ...
            extendedAncillaryDataStruct(iChannel).values(~isInvalidUncertainty);                                         %#ok<AGROW>
        extendedAncillaryDataStruct(iChannel).uncertainties = ...
            extendedAncillaryDataStruct(iChannel).uncertainties(~isInvalidUncertainty);                                  %#ok<AGROW>
        string = ['one or more uncertainties for mnemonic ', extendedAncillaryDataStruct(iChannel).mnemonic, ...
            ' are < 0; the associated value(s) will be ignored'];
        [alerts] = add_alert(alerts, 'warning', string);
        disp(string);
    end % if
        
    % Interpolate,  setting the time stamps for all channels to the
    % midpoints of the cadence intervals.
    interpolatedData = spline(extendedAncillaryDataStruct(iChannel).timestamps, ...
        extendedAncillaryDataStruct(iChannel).values, interpolatedCadenceTimes(~cadenceGapIndicators));

    % Interpolate uncertainties. A more intelegent method could be developed.
    interpolatedUncertainties = spline(extendedAncillaryDataStruct(iChannel).timestamps, ...
        extendedAncillaryDataStruct(iChannel).uncertainties, interpolatedCadenceTimes(~cadenceGapIndicators));

    % Assign ancillary time series.
    [conditionedAncillaryDataStruct(iChannel).ancillaryTimeSeries] = ...
        populate_timeseries_structure_with_gapped_data(interpolatedData, ...
        interpolatedUncertainties, cadenceGapIndicators);
    conditionedAncillaryDataStruct(iChannel).ancillaryTimeSeries.timestamps = ...
        interpolatedCadenceTimes(~cadenceGapIndicators);
    
end % for iChannel

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Finish populating the output structures.
for iChannel = 1 : nChannels
    conditionedAncillaryDataStruct(iChannel).mnemonic                   = ...
        ancillaryDataStruct(iChannel).mnemonic;
    conditionedAncillaryDataStruct(iChannel).isAncillaryEngineeringData = ...
        ancillaryDataStruct(iChannel).isAncillaryEngineeringData;
    conditionedAncillaryDataStruct(iChannel).modelOrder                 = ...
        ancillaryDataStruct(iChannel).modelOrder;
    conditionedAncillaryDataStruct(iChannel).interactions               = ...
        ancillaryDataStruct(iChannel).interactions;

    % Save raw data for analysis
    conditionedAncillaryDataStruct(iChannel).rawTimeStamps              = ...
        ancillaryDataStruct(iChannel).timestamps;
    conditionedAncillaryDataStruct(iChannel).rawValues                  = ...
        ancillaryDataStruct(iChannel).values;
end % for iChannel


return

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%% Internal functions below are not for public use.

%%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%function binnedAncillaryDataStruct = ...
%        rebin_ancillary_data(ancillaryDataStruct, cadenceTimes, cadenceGapIndicators);
%
%~~~~~
% determine if binning is necessary
% There are two cases:
% 1) ancillary sampling rate is too short so bin everything
% 2) a handfull of ancillary datums are too close together so re-bin just those few
%

function binnedAncillaryDataStruct = ...
        rebin_ancillary_data(ancillaryDataStruct, cadenceTimes, cadenceGapIndicators)

% If the ancillary sampling length is less than the cadence length divided by the samplingFactor then re-bin
samplingFactor = 5;
% binFactor is number of bins per cadence when binning all data
binFactor = 2;

% Populate all static output
binnedAncillaryDataStruct = ancillaryDataStruct;

meanCadenceLength = mean(diff(cadenceTimes(~cadenceGapIndicators)));
ancillarySamplingLength = diff(ancillaryDataStruct.timestamps);
meanAncillarySamplingLength = mean(ancillarySamplingLength);

if meanAncillarySamplingLength < (meanCadenceLength / samplingFactor)
    % This will bin the entire data set to the flux cadences
    noGapCadences = cadenceTimes(~cadenceGapIndicators);
    firstBin = noGapCadences(1);
    lastBin  = noGapCadences(end);
    bins = [firstBin:(meanCadenceLength/binFactor):lastBin]';
    [binnedAncillaryDataStruct.values, binnedAncillaryDataStruct.uncertainties, ...
        binnedGapIndicators] = bin_ancillary_data(ancillaryDataStruct, bins);
    binnedAncillaryDataStruct.timestamps = bins(~binnedGapIndicators);
    binnedAncillaryDataStruct.values = binnedAncillaryDataStruct.values(~binnedGapIndicators);
    binnedAncillaryDataStruct.uncertainties = binnedAncillaryDataStruct.uncertainties(~binnedGapIndicators);
else
    % Check if any individual bins are too close together
    % if several bins are too close together then iterate until we remove them all
    lengthenSamplingIndex = find(ancillarySamplingLength < (meanCadenceLength / samplingFactor));
    if any(lengthenSamplingIndex) % If so then average over timstamps
        for iBin = 1 : size(lengthenSamplingIndex)
            % just average over the datums
            meanValue = mean([binnedAncillaryDataStruct.values(lengthenSamplingIndex(iBin)), ... 
                             binnedAncillaryDataStruct.values(lengthenSamplingIndex(iBin)+1)]);
            meanTime = mean([binnedAncillaryDataStruct.timestamps(lengthenSamplingIndex(iBin)), ... 
                             binnedAncillaryDataStruct.timestamps(lengthenSamplingIndex(iBin)+1)]);
            meanUncertainty = mean([binnedAncillaryDataStruct.uncertainties(lengthenSamplingIndex(iBin)), ... 
                             binnedAncillaryDataStruct.uncertainties(lengthenSamplingIndex(iBin)+1)]);
            
            % use average value
            binnedAncillaryDataStruct.values(lengthenSamplingIndex(iBin)) = meanValue;
            binnedAncillaryDataStruct.timestamps(lengthenSamplingIndex(iBin)) = meanTime;
            binnedAncillaryDataStruct.uncertainties(lengthenSamplingIndex(iBin)) = meanUncertainty;

            % remove the extraneous bin
            if (size(binnedAncillaryDataStruct.values,1) <= lengthenSamplingIndex(iBin)+1)
                % For the special case where the extraneous bin is the last datum
                binnedAncillaryDataStruct.values = ...
                    binnedAncillaryDataStruct.values(1:lengthenSamplingIndex(iBin));
                binnedAncillaryDataStruct.timestamps = ...
                    binnedAncillaryDataStruct.timestamps(1:lengthenSamplingIndex(iBin));
                binnedAncillaryDataStruct.uncertainties = ...
                    binnedAncillaryDataStruct.uncertainties(1:lengthenSamplingIndex(iBin));
            else
                % The normal case
                binnedAncillaryDataStruct.values = ...
                    [binnedAncillaryDataStruct.values(1:lengthenSamplingIndex(iBin))', ...
                        binnedAncillaryDataStruct.values(lengthenSamplingIndex(iBin)+2:end)']';
                binnedAncillaryDataStruct.timestamps = ...
                    [binnedAncillaryDataStruct.timestamps(1:lengthenSamplingIndex(iBin))', ...
                        binnedAncillaryDataStruct.timestamps(lengthenSamplingIndex(iBin)+2:end)']';
                binnedAncillaryDataStruct.uncertainties = ...
                    [binnedAncillaryDataStruct.uncertainties(1:lengthenSamplingIndex(iBin))', ...
                        binnedAncillaryDataStruct.uncertainties(lengthenSamplingIndex(iBin)+2:end)']';
            end
            
            % just removed datums so indexes must be shifted down.
            lengthenSamplingIndex = lengthenSamplingIndex - 1;
        end
        % check if we need to do this again
        binnedAncillarySamplingLength = diff(binnedAncillaryDataStruct.timestamps);
        lengthenSamplingIndex = find(binnedAncillarySamplingLength < (meanCadenceLength / samplingFactor));
    end
end

return 

%%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function extendedAncillaryDataStruct = extrapolate_ancillary_data(ancillaryDataStruct, alerts)
%~~~~~~
% This function extrapolates past each endge of the data.
%
% nDatumToUSe is the number of points to use at beginning and end of data for fitting.
% polyFitOrder is the order for the polynomial fitter.
% nDatumToExtrap is the number of points past beginning and end of data to extrapolate to.

function extendedAncillaryDataStruct = extrapolate_ancillary_data(ancillaryDataStruct, alerts)

nDatumToUse = 10;
polyFitOrder = 3;
nDatumToExtrap = 2;

% First populate all static output
extendedAncillaryDataStruct = ancillaryDataStruct;

% Make sure there are enough timestamps to extrapolate
if size(ancillaryDataStruct.timestamps,1) <= nDatumToUse
    string = ['Too few timestamps to extrapolate ancillary mnemonic ', ...
        ancillaryDataStruct.mnemonic];
    [alerts] = add_alert(alerts, 'warning', string);
    disp(alerts(end).message);
    return
end


% Find beginning and end
beginningData.values = ancillaryDataStruct.values(1:nDatumToUse);
beginningData.timestamps = ancillaryDataStruct.timestamps(1:nDatumToUse);

endingData.values = ancillaryDataStruct.values(end-nDatumToUse+1:end);
endingData.timestamps = ancillaryDataStruct.timestamps(end-nDatumToUse+1:end);

% polynomial interpolation
[pBeginning, SBeginning, muBeginning] = polyfit (beginningData.timestamps, beginningData.values, polyFitOrder);
[pEnding, SEnding, muEnding]    = polyfit (endingData.timestamps   , endingData.values   , polyFitOrder);

%***
% Add in extrapolated points

% define extrapolated timestamps
meanCadenceLength = mean(diff(ancillaryDataStruct.timestamps));
extraBeginningTimeStamps = ...
    [beginningData.timestamps(1)-meanCadenceLength:-meanCadenceLength:...
        beginningData.timestamps(1)-meanCadenceLength*nDatumToExtrap]';
extraEndingTimestamps    = ...
    [endingData.timestamps(end)+meanCadenceLength:meanCadenceLength:...
        endingData.timestamps(end)+meanCadenceLength*nDatumToExtrap]';

% insert extra values
extendedAncillaryDataStruct.values = ...
    [polyval(pBeginning, extraBeginningTimeStamps, SBeginning, muBeginning)', ...
     ancillaryDataStruct.values', ...
     polyval(pEnding,extraEndingTimestamps, SEnding, muEnding)'];
extendedAncillaryDataStruct.values = extendedAncillaryDataStruct.values';

% insert zero uncertainties
extendedAncillaryDataStruct.uncertainties = ...
    [zeros(size(extraBeginningTimeStamps,1),1)', ...
     ancillaryDataStruct.uncertainties', ...
     zeros(size(extraEndingTimestamps,1),1)'];
extendedAncillaryDataStruct.uncertainties = extendedAncillaryDataStruct.uncertainties';

% insert extra timestamps
extendedAncillaryDataStruct.timestamps = ...
    [extraBeginningTimeStamps', ...
     ancillaryDataStruct.timestamps', ...
     extraEndingTimestamps'];
extendedAncillaryDataStruct.timestamps = extendedAncillaryDataStruct.timestamps';

return % function extrapolate_ancillary_data

%%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function gapFilledAncillaryDataStruct = fill_ancillary_data_gaps(ancillaryDataStruct)
%~~~~~
% This function will fill any gapps in the ancillary data using a simple first
% order polynomal fit. The ancillary data is filled over ALL gaps even those
% with no valid flux data.
%
% MaxGapFactor gives the number of times greater the timestep is than the average to be decleared a gap.
% nTimestampsToFit gives the number of timestamps to average over to find the edge values to linearly
% interpolate between.
%

function gapFilledAncillaryDataStruct = fill_ancillary_data_gaps(ancillaryDataStruct)

maxGapFactor = 5.0;
nTimestampsToFit = 10;
polyFitOrder = 1;

% First populate all static output
gapFilledAncillaryDataStruct = ancillaryDataStruct;

timestamps = ancillaryDataStruct.timestamps;

% Set the gap indicators.
% A gap is defined as a cadence length greater than maxGapFactor times the mean cadence
validDataIndicators = timestamps > 0;
timestamps = timestamps(validDataIndicators);
meanCadenceLength = mean(diff(timestamps));
maxCadenceLength = maxGapFactor * meanCadenceLength; 
gapList = diff(timestamps) > maxCadenceLength;
gapList = find(gapList);

% Fill data gaps
if ~isempty(gapList)
    for iGap = 1 : size(gapList)
        % Linearly interpolate
        % make sure there are enough datums to fit
        if gapList(iGap)-nTimestampsToFit+1 >= 1
            iStart = gapList(iGap)-nTimestampsToFit+1;
        else
            iStart = 1;
        end
        if gapList(iGap)+nTimestampsToFit <= size(gapFilledAncillaryDataStruct.values,1)
            iEnd = gapList(iGap)+nTimestampsToFit;
        else
            iEnd = size(gapFilledAncillaryDataStruct.values,1);
        end
        fitValues     = [(gapFilledAncillaryDataStruct.values    (iStart          :gapList(iGap)))', ...
                         (gapFilledAncillaryDataStruct.values    (gapList(iGap)+1:iEnd          ))']';
        fitTimestamps = [(gapFilledAncillaryDataStruct.timestamps(iStart          :gapList(iGap)))', ...
                         (gapFilledAncillaryDataStruct.timestamps(gapList(iGap)+1:iEnd          ))']';
        [p, S, mu] = polyfit (fitTimestamps, fitValues, polyFitOrder);

        % insert gaps
        fillTimestamps = [gapFilledAncillaryDataStruct.timestamps(gapList(iGap)):...
                          meanCadenceLength:...
                          gapFilledAncillaryDataStruct.timestamps(gapList(iGap)+1)]'; 

        % insert new values
        gapFilledAncillaryDataStruct.values = ...
            [gapFilledAncillaryDataStruct.values(1:gapList(iGap)-1)', ...
            polyval(p, fillTimestamps, S, mu)', ...
            gapFilledAncillaryDataStruct.values(gapList(iGap)+1:end)']';
        %gapFilledAncillaryDataStruct.values = gapFilledAncillaryDataStruct.values';

        % Fill the uncertainties with zeros
        gapFilledAncillaryDataStruct.uncertainties = ...
            [gapFilledAncillaryDataStruct.uncertainties(1:gapList(iGap)-1)', ...
            zeros(size(fillTimestamps,1),1)', ...
            gapFilledAncillaryDataStruct.uncertainties(gapList(iGap)+1:end)']';
        %gapFilledAncillaryDataStruct.uncertainties = gapFilledAncillaryDataStruct.uncertainties';

        % insert new timestamps
        gapFilledAncillaryDataStruct.timestamps = [[gapFilledAncillaryDataStruct.timestamps(1:gapList(iGap)-1)]', ...
            fillTimestamps', ...
            [gapFilledAncillaryDataStruct.timestamps(gapList(iGap)+1:end)]']';
        %gapFilledAncillaryDataStruct.timestamps = gapFilledAncillaryDataStruct.timestamps';

        % inserted datums so have to shift indexes up
        gapList = gapList + size(fillTimestamps,1) - 1;

    end % for iGap
end

return % function fill_ancillary_data_gaps

%%
