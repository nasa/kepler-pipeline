function [theoreticalCompressionEfficiency, achievedCompressionEfficiency, ...
    compressionByCadence] = ...
    compute_compression_efficiency(nRequantBits, requantTables, huffmanTables, ...
    cadenceTimes, baselineIntervals, nTotalPixelSeries, nCadences, localFilenames, debugLevel) %#ok<INUSD>
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [theoreticalCompressionEfficiency, achievedCompressionEfficiency, ...
%     compressionByCadence] = ...
%     compute_compression_efficiency(nRequantBits, requantTables, huffmanTables, ...
%     cadenceTimes, baselineIntervals, nTotalPixelSeries, nCadences, localFilenames, debugLevel)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Compute the theoretical and achieved compression performance on a cadence
% by cadence basis. Perform a reverse requantization table lookup to obtain
% the indices of the given requantized pixel values. Calculate the residuals
% between the table indices and the current baseline values. Compute the
% effective compression rate for the given cadence as the average Huffman
% codeword length for the residuals (i.e. Huffman symbols). Calculate the
% theoretical compression rate as the entropy in the histogram of Huffman
% symbol counts for the given cadence. Return an array of structs, one per
% cadence, with the computed compression performance.
%
% It is assumed that all pixel time series for the given module output have
% been saved to an array in the cal_comp_eff_state.mat file with the
% pack_pixel_time_series_for_access_by_cadence function.
%
% Missing data values are flagged by NAN_VALUE's. These produce NaN's in the
% reverse requantization table lookup process, and are disregarded when
% calculating the theoretical and achieved compression rates. If all
% pixels for a given cadence or for the current baseline cadence are missing
% then it is not possible to compute the compression rates for the given
% cadence. In this case, the gap indicator flag is set to true in the
% the output structures. This flag is also set to true for the first cadence
% where the pixel values are used only to set the initial baseline.
%
% The theoretical and achieved compression rates both include the overhead
% for storage of the (uncompressed) baselines. This overhead is amortized
% over all cadences.
%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% INPUT:  The following arguments must be provided to this function.
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
%                        nRequantBits: [int]  number of bits in indices of
%                                             requantization table
%              requantTables: [struct array]  requantization tables
%              huffmanTables: [struct array]  Huffman tables
%                     cadenceTimes: [struct]  cadence time tags and gap
%                                             indicators
%               baselineIntervals[int array]  baseline interval in effect
%                                             at each cadence
%                   nTotalPixelSeries: [int]  total pixels for module output
%                           nCadences: [int]  number of cadences per pixel
%                          debugLevel: [int]  science debug level
%
%--------------------------------------------------------------------------
%
%   Second level
%
% requantTables is an array of structs containing the following fields:
%
%                          externalId: [int]  requantization table ID
%                         startMjd: [double]  start time tag for table (MJD)
%                requantEntries: [int array]  requantization table values
%              meanBlackEntries: [int array]  requantization table values
%
%
% huffmanTables is an array of structs containing the following fields:
%
%                          externalId: [int]  Huffman table ID
%                         startMjd: [double]  start time tag for table (MJD)
%                     bitString: [int array]  Huffman code strings
%
% cadenceTimes is a struct with the following fields:
%
%                 timestamp: [double array]  cadence time tags (MJD)
%             gapIndicators: [logical array]  missing time tag indicators
%            requantEnabled: [logical array]  flags to indicate whether
%                                             or not requantization was enabled
%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%  OUTPUT:  The following are returned by this function.
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
%   Top Level
%
% theoreticalCompressionEfficiency: [struct array]  entropy time series
%    achievedCompressionEfficiency: [struct array]  achieved compression
%                                                   time series
%             compressionByCadence: [struct array]  compression performance,
%                                                   coded symbols and bits
%
%--------------------------------------------------------------------------
%
%   Second level
%
% theoreticalCompressionEfficiency is a struct containing the following
% fields:
%
%                      values: [float array]  entropy time series
%             gapIndicators: [logical array]  missing data flags
%                nCodeSymbols: [float array]  number of coded symbols
%
%
% achievedCompressionEfficiency is a struct containing the following
% fields:
%
%                      values: [float array]  achieved compression time series
%             gapIndicators: [logical array]  missing data flags
%                nCodeSymbols: [float array]  number of coded symbols
%
%
% compressionByCadence is an array of structs (one per cadence) containing
% the following fields:
%
%                    gapIndicator: [logical]  flag indicates that compression
%                                             rates are not valid (will not be
%                                             if all pixel values are missing)
%        theoreticalCompressionRate: [float]  theoretical compression rate for
%                                             the given cadence (bpp)
%           achievedCompressionRate: [float]  achieved compression ratevfor the
%                                             given cadence (bpp)
%                        nCodeSymbols: [int]  number of coded symbols
%                           nCodeBits: [int]  number of code bits
%                      requantTableId: [int]  ID of requant table for given cadence
%                      huffmanTableId: [int]  ID of Huffman table for given cadence
%
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

tic;
metricsKey = metrics_interval_start;

% hard coded constants
TITLE_FONTSIZE = 14;
AXIS_LABEL_FONTSIZE = 12;
AXIS_NUMBER_FONTSIZE = 12;
LEGEND_FONTSIZE = 10;

% Parameter value for empty metric.
emptyValue = -1;

% Initialize variables.
zeroOffset = 2^nRequantBits - 1;
huffmanTableLength = 2^(nRequantBits + 1) - 1;
histogramEdges = (0 : huffmanTableLength - 1)';
huffmanStartTags = [huffmanTables.startMjd];

stateFilename = [ localFilenames.stateFilePath, localFilenames.calCompEffFilename ];

% Load the state from the state file. Throw an error if the
% state file does not exist or if the requantPixelValuesArray cannot be
% loaded.
nTotalPixelSeriesIn = nTotalPixelSeries;
nCadencesIn = nCadences;

if ~exist(stateFilename, 'file')
    error('CAL:computeCompressionEfficiency:missingStateFile', ...
        'CAL state file is missing')
end

load(stateFilename, 'requantPixelValuesArray', 'nInvocations', ...
    'nPackedPixelSeries', 'nTotalPixelSeries', 'nCadences');

if ~exist('requantPixelValuesArray', 'var')
    error('CAL:computeCompressionEfficiency:loadFailure', ...
        'Unable to load requantPixelValuesArray from state file');
end

% Perform consistency checks.
if nTotalPixelSeriesIn ~= nTotalPixelSeries
    error('CAL:computeCompressionEfficiency:invalidInputParameter', ...
        'Inconsistent number of total pixel series (%d vs %d)', ...
        nTotalPixelSeriesIn, nTotalPixelSeries);
end

if nCadencesIn ~= nCadences
    error('CAL:computeCompressionEfficiency:invalidInputParameter', ...
        'Inconsistent number of cadences (%d vs %d)', ...
        nCadencesIn, nCadences);
end

if ~isequal(size(requantPixelValuesArray), [nTotalPixelSeries, nCadences])
    error('CAL:computeCompressionEfficiency:invalidPixelValuesArray', ...
        'Pixel values array is not the proper size (%dx%d vs %dx%d)', ...
        size(requantPixelValuesArray, 1), size(requantPixelValuesArray, 2), ...
        nTotalPixelSeries, nCadences);
end

% Perform some additional error checks. Bounds checks should be
% performed when CAL class objects are instantiated by the
% cal_matlab_controller.
if nCadences ~= length(cadenceTimes.timestamp)
    error('CAL:computeCompressionEfficiency:invalidTimestampsLength', ...
        'Invalid timestamp vector length (%d vs %d)', ...
        length(cadenceTimes.timestamp), nCadences);
end

if nCadences ~= length(cadenceTimes.gapIndicators)
    error('CAL:computeCompressionEfficiency:invalidGapIndicatorsLength', ...
        'Invalid cadence times gap indicators vector length (%d vs %d)', ...
        length(cadenceTimes.gapIndicators), nCadences);
end

for iTable = 1 : length(requantTables)
    if 2^nRequantBits ~= length(requantTables(iTable).requantEntries)
        error('CAL:computeCompressionEfficiency:invalidRequantTableLength', ...
            'Invalid requant table vector length (%d vs %d)', ...
            length(requantTables(iTable).requantEntries), ...
            2^nRequantBits)
    end
end

for iTable = 1 : length(huffmanTables)
    if 2^(nRequantBits + 1) - 1 ~= ...
            length(huffmanTables(iTable).bitString)
        error('CAL:computeCompressionEfficiency:invalidHuffmanTable', ...
            'Invalid Huffman table size (%d vs %d)', ...
            length(huffmanTables(iTable).bitString), ...
            2^(nRequantBits + 1) - 1)
    end
end

% Initialize the output structure.
compressionByCadence = repmat(struct(...
    'gapIndicator', [], ...
    'theoreticalCompressionRate', [], ...
    'achievedCompressionRate', [], ...
    'nCodeSymbols', [], ...
    'nCodeBits', [], ...
    'requantTableId', [], ...
    'huffmanTableId', [] ), [1, nCadences]);

% Compute the (column) vectors of Huffman code lengths for each table.
for iTable = 1 : length(huffmanTables)
    huffmanBitStrings = huffmanTables(iTable).bitString;
    huffmanCodeLengths = cellfun('length', huffmanBitStrings);
    if 1 == size(huffmanCodeLengths, 1)
        huffmanCodeLengths = huffmanCodeLengths';
    end
    huffmanTables(iTable).codeLengths = huffmanCodeLengths;
end

% Perform reverse requantization table lookup to obtain the table indices
% for the initial pixel values. These represent the initial baseline.
[baselineValues, requantTableId] = ...
    get_table_indices(requantTables, requantPixelValuesArray, ...
    cadenceTimes, 1);

compressionByCadence(1) = ...
    populate_output_struct(true, emptyValue, emptyValue, 0, 0, ...
    requantTableId, emptyValue);

% Loop over the remaining cadences and compute the compression efficiency
% for each one.
for iCadence = 2 : nCadences
    
    % Get the baseline interval in effect for the given cadence. This
    % should not change often if at all.
    baselineInterval = baselineIntervals(iCadence);
    
    % Perform reverse requantization table lookup to obtain the table indices
    % for the pixel values for the given cadence.
    [indxRequantPixelValues, requantTableId] = ...
        get_table_indices(requantTables, requantPixelValuesArray, ...
        cadenceTimes, iCadence);
    
    % Check validity of cadence timestamp.
    if ~cadenceTimes.gapIndicators(iCadence)
        
        % Compute the residual between the requantization table indices for
        % the given pixel values and the current baseline values. Add in a
        % zero offset so that the residuals are not negative.
        delta = indxRequantPixelValues - baselineValues + zeroOffset;
        
        % Compute the histogram counts for the given cadence. Make sure
        % that histogram counts is a column vector even if there is only
        % delta value (for one requantized pixel value).
        histogramCounts = histc(delta, histogramEdges, 1);
        
        % Identify the correct Huffman table for the given cadence. Determine
        % the number of coded symbols by summing the histogram counts.
        % Compute the total number of bits to encode the symbols with a dot
        % product of the histogram counts of code symbols and the Huffman
        % code lengths for each symbol.
        cadenceTimestamp = cadenceTimes.timestamp(iCadence);
        [sortedStartTags, indxSortedStartTags] = ...
            sort(huffmanStartTags, 'descend');
        indxSortedStartTags = ...
            indxSortedStartTags(sortedStartTags <= cadenceTimestamp);
        
        if isempty(indxSortedStartTags)
            error('CAL:computeCompressionEfficiency:huffmanTableIdFailure', ...
                'Unable to identify Huffman table for cadence time tag (%f)', ...
                cadenceTimestamp);
        else
            indxTable = indxSortedStartTags(1);
        end
        
        huffmanTableId = huffmanTables(indxTable).externalId;
        huffmanCodeLengths = huffmanTables(indxTable).codeLengths;
        nCodeSymbols = sum(histogramCounts);
        nCodeBits = histogramCounts' * huffmanCodeLengths;
        
    else % cadence timestamp is not valid
        
        huffmanTableId = emptyValue;
        nCodeSymbols = 0;
        nCodeBits = 0;
        
    end % if/else
    
    % Compute the theoretical and achieved compression rates. Add the
    % uncompressed baseline overhead rate to the compression rates so
    % that it does not get lost in the shuffle. Set the rates to 0 if
    % there are no new coded symbols.
    if nCodeSymbols > 0
        
        gapIndicator = false;
        achievedCompressionRate = nCodeBits / nCodeSymbols;
        
        % There are too few histogram counts per mod/out per cadence to
        % allow setting all zero counts to one. That greatly inflates the
        % theoretical compression rate. Just ensure that the computation of
        % the theoretical rate does not fail by attempting to compute the
        % log2(0).
        %histogramCounts(0 == histogramCounts) = 1;
        isPositive = (histogramCounts > 0);
        histogramCounts = histogramCounts(isPositive);
        
        probabilityOfSymbols = histogramCounts / sum(histogramCounts);
        theoreticalCompressionRate = ...
            -sum(probabilityOfSymbols .* log2(probabilityOfSymbols));
        
        uncompressedBaselineOverheadRate = nRequantBits / baselineInterval;
        achievedCompressionRate = achievedCompressionRate + ...
            uncompressedBaselineOverheadRate;
        theoreticalCompressionRate = theoreticalCompressionRate + ...
            uncompressedBaselineOverheadRate;
        
    else % no coded symbols
        
        gapIndicator = true;
        achievedCompressionRate = emptyValue;
        theoreticalCompressionRate = emptyValue;
        
    end % if/else
    
    % Update the baseline values if the end of a baseline interval has been
    % reached. If the cadence is invalid then do not update the baseline.
    if ~cadenceTimes.gapIndicators(iCadence)
        if 0 == mod(iCadence - 1, baselineInterval)
            baselineValues = indxRequantPixelValues;
        end
    end
    
    % Populate the output structure by cadence.
    compressionByCadence(iCadence) = ...
        populate_output_struct(gapIndicator, ...
        theoreticalCompressionRate, achievedCompressionRate, ...
        nCodeSymbols, nCodeBits, requantTableId, huffmanTableId);
    
end % for iCadence

% Create additional output structures for theoretical and achieved
% compression efficiency.
theoreticalCompressionEfficiency.values = ...
    [compressionByCadence.theoreticalCompressionRate]';
theoreticalCompressionEfficiency.gapIndicators = ...
    [compressionByCadence.gapIndicator]';
theoreticalCompressionEfficiency.nCodeSymbols = ...
    [compressionByCadence.nCodeSymbols]';

achievedCompressionEfficiency.values = ...
    [compressionByCadence.achievedCompressionRate]';
achievedCompressionEfficiency.gapIndicators = ...
    [compressionByCadence.gapIndicator]';
achievedCompressionEfficiency.nCodeSymbols = ...
    [compressionByCadence.nCodeSymbols]';

% Generate and save plots.
close all;
paperOrientationFlag = true;

h = figure;
legendStrings = {};
stringCount = 0;

acrGapIndicators = achievedCompressionEfficiency.gapIndicators;
if ~all(acrGapIndicators)
    acrValues = achievedCompressionEfficiency.values;
    acrValues = acrValues(~acrGapIndicators);
    cadences = (1 : length(acrGapIndicators))';
    cadences = cadences(~acrGapIndicators);
    plot(cadences, acrValues, '.-b');
    hold on
    stringCount = stringCount + 1;
    legendStrings{stringCount} = 'Achieved';
end

tcrGapIndicators = theoreticalCompressionEfficiency.gapIndicators;
if ~all(tcrGapIndicators)
    tcrValues = theoreticalCompressionEfficiency.values;
    tcrValues = tcrValues(~tcrGapIndicators);
    cadences = (1 : length(tcrGapIndicators))';
    cadences = cadences(~tcrGapIndicators);
    plot(cadences, tcrValues, '.-r');
    stringCount = stringCount + 1;
    legendStrings{stringCount} = 'Theoretical';
end

if ~all(acrGapIndicators) || ~all(tcrGapIndicators)
    grid
    title('[CAL] Compression Efficiency Metrics', 'fontsize', TITLE_FONTSIZE);
    xlabel('Cadence', 'fontsize', AXIS_LABEL_FONTSIZE)
    ylabel('Compression Rate (bpp)', 'fontsize', AXIS_LABEL_FONTSIZE)
    %legend('Achieved', 'Theoretical');
    z = legend(legendStrings);
    set(z, 'fontsize', LEGEND_FONTSIZE);
    hold off;    
    set(h, 'PaperPositionMode', 'auto');
    set(gca, 'fontsize', AXIS_NUMBER_FONTSIZE);
    
    plot_to_file('cal_compression_metrics', paperOrientationFlag);
    close all;
end

display_cal_status('CAL:cal_matlab_controller: Compression efficiency computed', 1);
metrics_interval_stop('cal.compute_compression_efficiency.execTimeMillis',metricsKey);

% Return.
return


function [compressionEfficiency] = ...
    populate_output_struct(gapIndicator, theoreticalCompressionRate, ...
    achievedCompressionRate, nCodeSymbols, nCodeBits, requantTableId, ...
    huffmanTableId)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [compressionEfficiency] = ...
% populate_output_struct(gapIndicator, theoreticalCompressionRate, ...
% achievedCompressionRate, nCodeSymbols, nCodeBits, requantTableId, ...
% huffmanTableId)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

% Populate the output structure.
compressionEfficiency.gapIndicator = gapIndicator;
compressionEfficiency.theoreticalCompressionRate = ...
    theoreticalCompressionRate;
compressionEfficiency.achievedCompressionRate = ...
    achievedCompressionRate;
compressionEfficiency.nCodeSymbols = nCodeSymbols;
compressionEfficiency.nCodeBits = nCodeBits;
compressionEfficiency.requantTableId = requantTableId;
compressionEfficiency.huffmanTableId = huffmanTableId;

% Return.
return

