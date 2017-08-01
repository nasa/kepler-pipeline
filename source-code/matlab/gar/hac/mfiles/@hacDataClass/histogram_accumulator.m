function [hacResultsStruct] = histogram_accumulator(hacDataObject)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [hacResultsStruct] = histogram_accumulator(hacDataObject)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Accumulate Huffman histograms computed for each module output by HGN.
% If the first matlab invocation is true then initialize all accumulated
% histogram values to zero, otherwise load the previously accumulated histogram
% values from the current working directory. New histograms are then added
% to the existing values.
%
% Return the accumulated histograms for each baseline interval, together with
% the compression performance for that interval (uncompressed baseline overhead
% rate, theoretical compression rate and total storage requirement). Also
% return the best baseline interval and best storage rate for all module
% outputs combined.
%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% INPUT:  A data object hacDataObject of the class hacDataClass.
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%   Top level:
%
%     The following fields are extracted from the hacDataObject.
%
%                 fcConstants: [struct]  Fc constants
%            invocationCcdModule: [int]  CCD module for this invocation
%            invocationCcdOutput: [int]  CCD output for this invocation
%                   cadenceStart: [int]  first cadence for histograms
%                     cadenceEnd: [int]  last cadence for histograms
%      firstMatlabInvocation: [logical]  flag to indicate initial run
%            histograms: [struct array]  histograms for each baseline interval
%                      debugFlag: [int]  indicates debug level
%
%--------------------------------------------------------------------------
%   Second level
%
%     hacDataStruct.histograms is a struct array with the following 
%     fields:
%
%                    baselineInterval: [int]  interval (cadences)
%  uncompressedBaselineOverheadRate: [float]  overhead for baseline storage (bpp)
%        theoreticalCompressionRate: [float]  entropy computed from histogram (bpp)
%                  totalStorageRate: [float]  total storage requirement (bpp)
%                    histogram: [long array]  histogram for Huffman encoding
%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%  OUTPUT:  A data structure hacResultsStruct with the following fields.
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%   Top level:
%
%     hacResultsStruct contains the following fields:
%
%            invocationCcdModule: [int]  CCD module for this invocation
%            invocationCcdOutput: [int]  CCD output for this invocation
%                   cadenceStart: [int]  first cadence for histograms
%                     cadenceEnd: [int]  last cadence for histograms
%            histograms: [struct array]  histograms for each baseline interval
%  overallBestBaselineInterval: [float]  best interval for all mod outputs (cadences)
%       overallBestStorageRate: [float]  minimum storage rate for all intervals (bpp)
%
%--------------------------------------------------------------------------
%   Second level
%
%     hacDataStruct.histograms is a struct array with the following 
%     fields:
%
%                    baselineInterval: [int]  interval (cadences)
%  uncompressedBaselineOverheadRate: [float]  overhead for baseline storage (bpp)
%        theoreticalCompressionRate: [float]  entropy computed from histogram (bpp)
%                  totalStorageRate: [float]  total storage requirement (bpp)
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
fcConstants = hacDataObject.fcConstants;
invocationCcdModule = hacDataObject.invocationCcdModule;
invocationCcdOutput = hacDataObject.invocationCcdOutput;
cadenceStart = hacDataObject.cadenceStart;
cadenceEnd = hacDataObject.cadenceEnd;
firstMatlabInvocation = hacDataObject.firstMatlabInvocation;
histograms = hacDataObject.histograms;
debugFlag = hacDataObject.debugFlag;                                                       %#ok<NASGU>

% Check that histograms struct array is not empty.
nIntervals = length(histograms);
if 0 == nIntervals
    error('GAR:histogramAccumulator:emptyHistograms', ...
        'Histograms struct array is empty')
end

% Initialize variables and file name.
baselineIntervals = [histograms.baselineInterval]';
requantTableLength = fcConstants.REQUANT_TABLE_LENGTH;
nRequantBits = ceil(log2(requantTableLength));
huffmanTableLength = 2^(nRequantBits + 1) - 1;

stateFilename = 'hac_state.mat';

% If this is the first matlab invocation, initialize the intervals and huffman
% histograms arrays and the histogram count. Otherwise load the prior state from
% the matlab state file. Throw an error if the state file does not exist in this
% case.
if firstMatlabInvocation
    intervals = baselineIntervals;
    huffmanHistograms = zeros([huffmanTableLength, nIntervals]);
    histogramCount = 0;
    indxRun = 1;
else
    if (~exist(stateFilename, 'file'))
        error('GAR:histogramAccumulator:missingStateFile', ...
            'HAC state file is missing')
    end
    load(stateFilename, 'histogramCount', 'intervals', 'huffmanHistograms', ...
        'runParams');
    indxRun = length(runParams) + 1;                                                       %#ok<NODEF>
end

% Check that baseline intervals are valid.
if ~isequal(intervals, baselineIntervals)
    error('GAR:histogramAccumulator:invalidBaselineIntervalValue', ...
        'Invalid baseline interval value (new and/or missing value)')
end
if ~isequal(baselineIntervals, fix(baselineIntervals))
    error('GAR:histogramAccumulator:nonIntegerBaselineIntervalValue', ...
        'Non-integer baseline interval value');
end

% Check that the new histograms are valid. Explicitly cast them to double
% for compatibility with legacy structures.
for i = 1 : nIntervals
    if huffmanTableLength ~= length(histograms(i).histogram)
        error('GAR:histogramAccumulator:invalidHistogramLength', ...
            'Invalid input histogram length (%d vs %d)', ...
            length(histograms(i).histogram), huffmanTableLength);
    end
end

newHistograms = double([histograms.histogram]);
if ~isequal(newHistograms, fix(newHistograms))
    error('GAR:histogramAccumulator:nonIntegerHistogramValue', ...
        'Non-integer input histogram value');
end

% Initialize structures.
runParams(indxRun) = struct( ...
    'dateStr', [], ...
    'firstMatlabInvocation', [], ...
    'invocationCcdModule', [], ...
    'invocationCcdOutput', [], ...
    'nRequantBits', [], ...
    'nIntervals', [], ...
    'histogramCount', [], ...
    'cadenceStart', [], ...
    'cadenceEnd', [], ...
    'compressionPerformance', struct( ...
        'baselineIntervals', [], ...
        'uncompressedBaselineOverheadRate', [], ...
        'theoreticalCompressionRate', [], ...
        'totalStorageRate', [] ));

hacResultsStruct = struct( ...
    'invocationCcdModule', [], ...
    'invocationCcdOutput', [], ...
    'cadenceStart', [], ...
    'cadenceEnd', [], ...
    'histograms', repmat(struct(...
        'baselineInterval', [], ...
        'uncompressedBaselineOverheadRate', [], ...
        'theoreticalCompressionRate', [], ...
        'totalStorageRate', [], ...
        'histogram', [] ), [1, nIntervals]), ...
    'overallBestBaselineInterval', [], ...
    'overallBestStorageRate', [] );


% Accumulate the histograms. These are stored as signed integers on the
% Java side, so test for loss of precision.
huffmanHistograms = huffmanHistograms + newHistograms;

signedHistograms = int64(huffmanHistograms);
if ~isequal(huffmanHistograms, signedHistograms)
    error('GAR:histogramAccumulator:lossOfPrecision', ...
        'Loss of precision in accumulated histogram(s)')
end

% Increment the histogram count.
histogramCount = histogramCount + 1;

% Clear the newHistograms array since it is large and no longer needed.
clear newHistograms;

% Compute the uncompressed baseline overhead rate, theoretical compression rate
% and total storage requirement for each of the baseline intervals for this module
% output.

compressionPerformance = ...
    compute_compression_performance(nRequantBits, baselineIntervals, huffmanHistograms);

% Update the run parameters structure.
runParams(indxRun).dateStr = datestr(clock);
runParams(indxRun).invocationCcdModule = invocationCcdModule;
runParams(indxRun).invocationCcdOutput = invocationCcdOutput;
runParams(indxRun).cadenceStart = cadenceStart;
runParams(indxRun).cadenceEnd = cadenceEnd;
runParams(indxRun).firstMatlabInvocation = firstMatlabInvocation;
runParams(indxRun).nRequantBits = nRequantBits;
runParams(indxRun).nIntervals = nIntervals;
runParams(indxRun).histogramCount = histogramCount;
runParams(indxRun).compressionPerformance = compressionPerformance;                        %#ok<NASGU>

% Save the state and run parameters to the output file.
save(stateFilename, 'histogramCount', 'intervals', 'huffmanHistograms', 'runParams');

% Fill the results structure.
hacResultsStruct.invocationCcdModule = invocationCcdModule;
hacResultsStruct.invocationCcdOutput = invocationCcdOutput;
hacResultsStruct.cadenceStart = cadenceStart;
hacResultsStruct.cadenceEnd = cadenceEnd;

for i = 1 : nIntervals
    hacResultsStruct.histograms(i).baselineInterval = baselineIntervals(i);
    hacResultsStruct.histograms(i).uncompressedBaselineOverheadRate = ...
        compressionPerformance.uncompressedBaselineOverheadRate(i);
    hacResultsStruct.histograms(i).theoreticalCompressionRate = ...
        compressionPerformance.theoreticalCompressionRate(i);
    hacResultsStruct.histograms(i).totalStorageRate = ...
        compressionPerformance.totalStorageRate(i);
    hacResultsStruct.histograms(i).histogram = huffmanHistograms( : , i);
end

[hacResultsStruct.overallBestStorageRate, indxBestStorageRate] = ...
    min(compressionPerformance.totalStorageRate);
hacResultsStruct.overallBestBaselineInterval = ...
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
semilogx(hacResultsStruct.overallBestBaselineInterval, ...
    hacResultsStruct.overallBestStorageRate, 'xk');
grid
hold off
string = sprintf('%d Module Output(s), Cadence Range %d : %d', ...
    histogramCount, cadenceStart, cadenceEnd);
title(['[GAR/HAC] Compression Performance -- ' string]);
xlabel('Baseline Interval (cadences)');
ylabel('Storage / Transmission Requirements (bits/pixel)');
legend('Uncompressed Baseline Overhead', 'Theoretical Compression', 'Total');
plot_to_file('hac_compression_perf', isLandscapeOrientation);

close all;

residualValues = (1 : huffmanTableLength)' - ceil(huffmanTableLength / 2);
plot(residualValues, huffmanHistograms);
grid
title(['[GAR/HAC] Histogram(s) -- ' string]);
xlabel('Residual Value');
ylabel('Count');
plot_to_file('hac_histograms', isLandscapeOrientation);

% Return.
return
 