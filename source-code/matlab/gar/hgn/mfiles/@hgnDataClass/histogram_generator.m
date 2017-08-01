function [hgnResultsStruct] = histogram_generator(hgnDataObject)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [hgnResultsStruct] = histogram_generator(hgnDataObject)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Compile Huffman histograms for each interval in the baseline intervals vector
% from the pixel values for each cadence. If the first matlab invocation is true
% then initialize all histogram values to zero, otherwise add new Huffman
% symbol counts to the previously computed histograms stored in the current
% working directory.
%
% At the end of this invocation, save the state necessary to continue processing
% with the next range of cadence pixel values in the subsequent invocation.
%
% Return the Huffman histograms for each baseline interval, together with the 
% compression performance for that interval (uncompressed baseline overhead
% rate, theoretical compression rate and total store rate). Also return the best
% baseline interval and best storage rate for this module output.
%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% INPUT:  A data object hgnDataObject of the class hgnDataClass.
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%   Top level:
%
%     hgnDataStruct contains the following fields:
%
%         hgnModuleParameters: [struct]  module parameters
%                 fcConstants: [struct]  Fc constants
%                      ccdModule: [int]  CCD module number
%                      ccdOutput: [int]  CCD output number
%         invocationCadenceStart: [int]  first cadence for this invocation
%           invocationCadenceEnd: [int]  last cadence for this invocation
%      firstMatlabInvocation: [logical]  flag to indicate initial run
%                requantTable: [struct]  requantization table
%         cadencePixels: [struct array]  requantized pixels for each cadence
%                      debugFlag: [int]  indicates debug level
%
%--------------------------------------------------------------------------
%   Second level
%
%     hgnDataStruct.hgnModuleParameters is a struct with the following
%     field:
%
%        baselineIntervals: [int array]  intervals for histogram generation
%
%--------------------------------------------------------------------------
%   Second level
%
%     hgnDataStruct.requantTable is a struct with the following fields:
%
%                     externalId: [int]  table ID
%                    startMjd: [double]  table start time, MJD
%                      endMjd: [double]  table end time, MJD
%           requantEntries: [int array]  requantization table entries
%         meanBlackEntries: [int array]  mean black table entries
%
%--------------------------------------------------------------------------
%   Second level
%
%     hgnDataStruct.cadencePixels is a struct array with the following 
%     fields:
%
%                        cadence: [int]  cadence of pixel values
%              pixelValues: [int array]  requantized pixel values
%        gapIndicators: [logical array]  missing pixel indicators
%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%  OUTPUT:  A data structure hgnResultsStruct with the following fields.
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%   Top level:
%
%     hgnResultsStruct contains the following fields:
%
%                      ccdModule: [int]  CCD module number
%                      ccdOutput: [int]  CCD output number
%         invocationCadenceStart: [int]  first cadence for this invocation
%           invocationCadenceEnd: [int]  last cadence for this invocation
%            histograms: [struct array]  histograms for each baseline interval
%     modOutBestBaselineInterval: [int]  best interval for this module output (cadences)
%        modOutBestStorageRate: [float]  minimum storage rate of all intervals (bpp)
%
%--------------------------------------------------------------------------
%   Second level
%
%     hgnResultsStruct.histograms is a struct array with the following 
%     fields:
%
%                    baselineInterval: [int]  interval (cadences)
%  uncompressedBaselineOverheadRate: [float]  overhead for baseline storage (bpp)
%        theoreticalCompressionRate: [float]  entropy computed from histogram (bpp)
%                  totalStorageRate: [float]  storage requirement (bpp)
%                    histogram: [long array]  histogram for Huffman encoding
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


% Read fields from the input data object.
hgnModuleParameters = hgnDataObject.hgnModuleParameters;
fcConstants = hgnDataObject.fcConstants;
ccdModule = hgnDataObject.ccdModule;
ccdOutput = hgnDataObject.ccdOutput;
invocationCadenceStart = hgnDataObject.invocationCadenceStart;
invocationCadenceEnd = hgnDataObject.invocationCadenceEnd;
firstMatlabInvocation = hgnDataObject.firstMatlabInvocation;
requantTableStruct = hgnDataObject.requantTable;
cadencePixels = hgnDataObject.cadencePixels;
debugFlag = hgnDataObject.debugFlag;                                                       %#ok<NASGU>

baselineIntervals = hgnModuleParameters.baselineIntervals;
requantTable = requantTableStruct.requantEntries;

% Check that input arrays are not empty.
nIntervals = length(baselineIntervals);
if 0 == nIntervals
    error('GAR:histogramGenerator:emptyBaselineIntervals', ...
        'Baseline intervals vector is empty')
end

nCadencePixels = length(cadencePixels);
if 0 == nCadencePixels
    error('GAR:histogramGenerator:emptyCadencePixels', ...
        'Cadence pixels struct array is empty')
end

nPixelsPerCadence = length(cadencePixels(1).pixelValues);
if 0 == nPixelsPerCadence
    error('GAR:histogramGenerator:emptyPixelValues', ...
        'Pixel values vector is empty')
end

% Initialize variables, vectors, arrays and file names.
requantTableLength = fcConstants.REQUANT_TABLE_LENGTH;
nRequantBits = ceil(log2(requantTableLength));
zeroOffset = 2^nRequantBits - 1;
huffmanTableLength = 2^(nRequantBits + 1) - 1;
histogramEdges = (0 : huffmanTableLength - 1)';
indxRequantTable = (0 : length(requantTable) - 1)';
newCounts = zeros([huffmanTableLength, nIntervals]);
startIndxCadencePixels = 1;

stateFilename = 'hgn_state.mat';

% If this is the first matlab invocation, initialize the intervals and current
% baseline cadence vectors, the huffman histograms array and the cadence
% count. Otherwise load the prior state from the matlab state file, and check
% that there is no cadence discontinuity from the last invocation. Throw an
% error if the state file does not exist in this case.
if firstMatlabInvocation
    intervals = baselineIntervals;
    currentBaselineCadences = ones([nIntervals, 1]);
    huffmanHistograms = zeros([huffmanTableLength, nIntervals]);
    cadenceCount = 0;
    indxRun = 1;
else
    if (~exist(stateFilename, 'file'))
        error('GAR:histogramGenerator:missingStateFile', ...
            'HGN state file is missing')
    end
    load(stateFilename, 'lastCadence', 'cadenceCount', 'intervals', ...
        'currentBaselineCadences', 'baselineValues', 'huffmanHistograms', 'runParams');
    indxRun = length(runParams) + 1;                                                       %#ok<NODEF>
    nPixelsPerCadence = size(baselineValues, 1);                                           %#ok<NODEF>
    if (1 ~= abs(invocationCadenceStart - lastCadence))                                    %#ok<NODEF>
        error('GAR:histogramGenerator:cadenceGap', ...
            'Gap between cadence start (%d) this invocation and end (%d) last invocation', ...
            invocationCadenceStart, lastCadence)
    end
end

% Check that baseline intervals are valid.
if ~isequal(intervals, baselineIntervals)
    error('GAR:histogramGenerator:invalidBaselineIntervalValue', ...
       'Invalid baseline interval value (new and/or missing value)')
end
if ~isequal(baselineIntervals, fix(baselineIntervals))
    error('GAR:histogramGenerator:nonIntegerBaselineIntervalValue', ...
       'Non-integer baseline interval value')
end

% Check that the pixel values and gap indicators vectors are valid.
for i = 1 : nCadencePixels
    if nPixelsPerCadence ~= length(cadencePixels(i).pixelValues)
        error('GAR:histogramGenerator:invalidPixelValuesLength', ...
            'Invalid pixel values vector length (%d vs %d)', ...
            length(cadencePixels(i).pixelValues), nPixelsPerCadence);
    end
    if nPixelsPerCadence ~= length(cadencePixels(i).gapIndicators)
        error('GAR:histogramGenerator:invalidGapIndicatorsLength', ...
            'Invalid gap indicators vector length (%d vs %d)', ...
            length(cadencePixels(i).gapIndicators), nPixelsPerCadence);
    end
end

% Initialize structures.
runParams(indxRun) = struct( ...
    'dateStr', [], ...
    'firstMatlabInvocation', [], ...
    'ccdModule', [], ...
    'ccdOutput', [], ...
    'nRequantBits', [], ...
    'nIntervals', [], ...
    'nCadencePixels', [], ...
    'cadenceCount', [], ...
    'overallCadenceStart', [], ...
    'invocationCadenceStart', [], ...
    'invocationCadenceEnd', [], ...
    'nPixelsPerCadence', [], ...
    'compressionPerformance', struct( ...
        'baselineIntervals', [], ...
        'uncompressedBaselineOverheadRate', [], ...
        'theoreticalCompressionRate', [], ...
        'totalStorageRate', [] ));

hgnResultsStruct = struct( ...
    'ccdModule', [], ...
    'ccdOutput', [], ...
    'invocationCadenceStart', [], ...
    'invocationCadenceEnd', [], ...
    'histograms', repmat(struct(...
        'baselineInterval', [], ...
        'uncompressedBaselineOverheadRate', [], ...
        'theoreticalCompressionRate', [], ...
        'totalStorageRate', [], ...
        'histogram', [] ), [1, nIntervals]), ...
    'modOutBestBaselineInterval', [], ...
    'modOutBestStorageRate', [] );


% If this is the initial run, read all pixels for the first cadence and set
% the baseline for all baseline intervals accordingly. The 16-bit index of the
% requantized pixel values  must be looked up in the table of quantization 
% replacement values. All missing pixels are set to NaN.
%
% Note that a zero offset is subtracted prior to storage of the baselines so that
% the delta values computed later will fall in the range 0:huffmanTableLength-1.
if firstMatlabInvocation
    indxRequantPixelValues = reverse_requant_table_lookup(requantTable, ...
        indxRequantTable, cadencePixels(startIndxCadencePixels).pixelValues, ...
        cadencePixels(startIndxCadencePixels).gapIndicators);
    baselineValues = repmat(indxRequantPixelValues - zeroOffset, [1, nIntervals]);
    startIndxCadencePixels = startIndxCadencePixels + 1;
    cadenceCount = cadenceCount + 1;
end

% Start main loop. Each pass through, read all requantized pixels for the next
% cadence, compute the delta between the new pixels and each of the (unique)
% baselines, count the number of values of each of the symbols for Huffman coding
% for each of the (unique) baselines, and update the histograms for all
% baseline intervals.
for indxCadencePixels = startIndxCadencePixels : nCadencePixels
    
    % Get the 16-bit indices of the requantized pixels in the table of requantized
    % pixel values. All missing pixels are set to NaN.
    indxRequantPixelValues = reverse_requant_table_lookup(requantTable, ...
        indxRequantTable, cadencePixels(indxCadencePixels).pixelValues, ...
        cadencePixels(indxCadencePixels).gapIndicators);
    
    % Determine the number of unique baselines (intervals for which the current
    % baseline cadences are unique) and get the number of such baselines. The
    % matlab function 'unique' also returns two index vectors such that:
    %
    %   1. uniqueCurrentBaselineCadences = ...
    %          currentBaselineCadences(indxCurrentBaselineCadences)
    %
    %   2. currentBaselineCadences = ...
    %          uniqueCurrentBaselineCadences(indxUniqueCurrentBaselineCadences)
    [uniqueCurrentBaselineCadences, indxCurrentBaselineCadences, ...
        indxUniqueCurrentBaselineCadences] = unique(currentBaselineCadences, 'first');
    nUniqueBaselines = length(uniqueCurrentBaselineCadences);

    % Compute the delta between all requantized pixel values for the given
    % cadence and each of the unique baselines. Note that the zero offset has
    % already been incorporated into the baseline pixel values.
    delta = repmat(indxRequantPixelValues, [1, nUniqueBaselines]) - ...
        baselineValues( : , indxCurrentBaselineCadences);

    % Compute the histogram counts for each of the unique baselines and then
    % update all of the baseline histograms.
    newCounts( : , 1 : nUniqueBaselines) = histc(delta, histogramEdges, 1);
    huffmanHistograms = huffmanHistograms + ...
        newCounts( : , indxUniqueCurrentBaselineCadences);

    % Increment the cadence count.
    cadenceCount = cadenceCount + 1;
    
    % Update the baselines for which an interval has been completed. Once
    % again, note that a zero offset is subtracted prior to storage of
    % the baselines so that delta values computed later will fall in the range
    % 0:huffmanTableLength-1. 
    intervalComplete = (0 == mod(cadenceCount - 1, baselineIntervals));
    if any(intervalComplete)
        currentBaselineCadences(intervalComplete) = cadenceCount;
        baselineValues( : , intervalComplete) = ...
            repmat(indxRequantPixelValues - zeroOffset, [1, sum(intervalComplete)]);
    end
    
end % for

% Clear the delta and newCounts arrays since they are large and no longer needed.
clear delta newCounts;

% Compute the uncompressed baseline overhead rate, theoretical compression rate
% and total storage requirement for each of the baseline intervals for this module
% output.
compressionPerformance = ...
    compute_compression_performance(nRequantBits, baselineIntervals, huffmanHistograms);

% Update the run parameters structure.
runParams(indxRun).dateStr = datestr(clock);
runParams(indxRun).firstMatlabInvocation = firstMatlabInvocation;
runParams(indxRun).ccdModule = ccdModule;
runParams(indxRun).ccdOutput = ccdOutput;
runParams(indxRun).nRequantBits = nRequantBits;
runParams(indxRun).nIntervals = nIntervals;
runParams(indxRun).nCadencePixels = nCadencePixels;
runParams(indxRun).cadenceCount = cadenceCount;
runParams(indxRun).invocationCadenceStart = invocationCadenceStart;
overallCadenceStart = runParams(1).invocationCadenceStart;
runParams(indxRun).overallCadenceStart = overallCadenceStart;
runParams(indxRun).invocationCadenceEnd = invocationCadenceEnd;
runParams(indxRun).nPixelsPerCadence = nPixelsPerCadence;
runParams(indxRun).compressionPerformance = compressionPerformance;                        %#ok<NASGU>

% Save the state and run parameters to the output file.
lastCadence = invocationCadenceEnd;                                                        %#ok<NASGU>
save(stateFilename, 'lastCadence', 'cadenceCount', 'intervals', ...
    'currentBaselineCadences', 'baselineValues', 'huffmanHistograms', 'runParams');

% Fill the results structure.
hgnResultsStruct.ccdModule = ccdModule;
hgnResultsStruct.ccdOutput = ccdOutput;
hgnResultsStruct.invocationCadenceStart = invocationCadenceStart;
hgnResultsStruct.invocationCadenceEnd = invocationCadenceEnd;

for i = 1 : nIntervals
    hgnResultsStruct.histograms(i).baselineInterval = baselineIntervals(i);
    hgnResultsStruct.histograms(i).uncompressedBaselineOverheadRate = ...
        compressionPerformance.uncompressedBaselineOverheadRate(i);
    hgnResultsStruct.histograms(i).theoreticalCompressionRate = ...
        compressionPerformance.theoreticalCompressionRate(i);
    hgnResultsStruct.histograms(i).totalStorageRate = ...
        compressionPerformance.totalStorageRate(i);
    hgnResultsStruct.histograms(i).histogram = huffmanHistograms( : , i);
end

[hgnResultsStruct.modOutBestStorageRate, indxBestStorageRate] = ...
    min(compressionPerformance.totalStorageRate);
hgnResultsStruct.modOutBestBaselineInterval = ...
    compressionPerformance.baselineIntervals(indxBestStorageRate);

% Plot the baseline overhead rate, theoretical compression rate, and total
% storage rate. Also plot the histograms for all baseline intervals.
close all;
isLandscapeOrientation = true;

semilogx(baselineIntervals, ...
    compressionPerformance.uncompressedBaselineOverheadRate, '-sr');
hold on
semilogx(baselineIntervals, ...
    compressionPerformance.theoreticalCompressionRate, '-dg');
semilogx(baselineIntervals, ...
    compressionPerformance.totalStorageRate, '-ob');
semilogx(hgnResultsStruct.modOutBestBaselineInterval, ...
    hgnResultsStruct.modOutBestStorageRate, 'xk');
grid
hold off
string = sprintf('Module %d, Output %d, Cadence Range %d : %d', ...
    ccdModule, ccdOutput, overallCadenceStart, invocationCadenceEnd);
title(['[GAR/HGN] Compression Performance -- ' string]);
xlabel('Baseline Interval (cadences)');
ylabel('Storage / Transmission Requirements (bits/pixel)');
legend('Uncompressed Baseline Overhead', 'Theoretical Compression', 'Total');
plot_to_file('hgn_compression_perf', isLandscapeOrientation);

close all;

residualValues = (1 : huffmanTableLength)' - ceil(huffmanTableLength / 2);
plot(residualValues, huffmanHistograms);
grid
title(['[GAR/HGN] Histogram(s) -- ' string]);
xlabel('Residual Value');
ylabel('Count');
plot_to_file('hgn_histograms', isLandscapeOrientation);

% Return.
return
