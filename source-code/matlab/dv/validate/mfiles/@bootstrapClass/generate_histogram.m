function [bootstrapResultsStruct, dvResultsStruct] = ...
    generate_histogram(bootstrapObject, bootstrapResultsStruct, dvResultsStruct)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [bootstrapResultsStruct, dvResultsStruct] = ...
%    generate_histogram(bootstrapObject, bootstrapResultsStruct, dvResultsStruct)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Controller for generating bootstrap histograms.  If
% bootstrapAutoSkipCountEnabled is true then the number of iterations is
% estimated using bootstrapSkipCounts and compared to
% bootstrapMaxIterations; if this number is exceeded, then another
% skip count will be attempted so that predicted number of iterations is
% below bootstrapMaxIterations.  Once the first histogram is built, it is
% checked for timeout and "smoothness" and if it did not timeout and 
% skipCounts are avalilable then a finer skip count is
% used so long as the estimated number of iterations is below
% bootstrapMaxIterations.  If skip count = 0 (equivalent of no skipCount),
% then the histogram is considered to be smooth.
%
% The histogram for the trial pulse requiring the most predicted number of
% iterations is built first while the subsequent histograms for the latter
% trial pulses are built using the last skipCount employed in the
% construction of the fist histogram.
%
% If subsequent pulses trigger a timeout using the last skipCount and if
% larger skipCounts are available, then skipCount is incremented and
% bootstrap is redone.  All previously bootstrapped pulses are also
% regenerated.  However, if timeout is triggered and there are no
% larger skipCounts available, run_bootstrap aborts.
%
% If bootstrapAutoSkipCountEnabled is false, then histograms are built
% without regard to how many iterations will be required using the
% skipCount value indicated in this module parameter.  In this mode, c-mex
% routine also aborts when bootstrapUpperLimitFactor x
% bootstrapMaxIterations is encountered.
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
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

nPulseWidths = bootstrapObject.numberPulseWidths;

% adjust maxIterations and skipCount based on the number of cadences available
bootstrapMaxIterations = bootstrapObject.bootstrapMaxIterations;
maxSesCadences = max([bootstrapObject.degappedSingleEventStatistics.lengthSES]);
numQuarters = ceil(maxSesCadences * 1/48.939 * 4/365); 
bootstrapMaxIterations = max(bootstrapMaxIterations, bootstrapMaxIterations * numQuarters);
bootstrapObject.bootstrapMaxIterations = bootstrapMaxIterations;
bootstrapObject.bootstrapSkipCount = bootstrapObject.bootstrapSkipCount * numQuarters;

lowerMarginSigma = (bootstrapObject.binsBelowSearchTransitThreshold)*(bootstrapObject.histogramBinWidth);

searchTransitThreshold = bootstrapObject.searchTransitThreshold;
observedTransitCount = bootstrapObject.observedTransitCount;
statistics = bootstrapResultsStruct.statistics;
debugLevel = bootstrapObject.debugLevel;
bootstrapUpperLimitFactor = bootstrapObject.bootstrapUpperLimitFactor;


% Fix for KSOC 897: if bin widths are wide, this has to be conservative to avoid timing out
if lowerMarginSigma > 1
    lowerMarginSigma = 0.2;
end

% determine skipcounts
[skipCountArray numIterationsArray pulseOrder] = determine_skipcounts(bootstrapObject);

% check that the largest predicted number of iterations can be bootstrapped
if ~any(numIterationsArray(1,:) <= bootstrapMaxIterations)
    messageString = sprintf('Smallest estimated number of iterations required to bootstrap=%1.2e using %d skipCount.  Exceeds bootstrapMaxIterations.\n',...
        min(numIterationsArray(1,:)), max(skipCountArray(1,:)));
    warning(messageString) %#ok<SPWRN,WNTAG>
    dvResultsStruct = add_dv_alert(dvResultsStruct, 'bootstrap', ...
        'warning', messageString, bootstrapObject.targetNumber, ...
        bootstrapObject.keplerId, bootstrapObject.planetNumber);
    %return;
end

% get the rest of the needed inputs in the same order from highest
% predicted number of iterations to lowest
lengthSES = [bootstrapObject.degappedSingleEventStatistics(pulseOrder).lengthSES]';
numerator = vertcat(bootstrapObject.degappedSingleEventStatistics(pulseOrder).degappedSortedCorrelationTimeSeries);
denominator = vertcat(bootstrapObject.degappedSingleEventStatistics(pulseOrder).degappedSortedNormalizationTimeSeries);
pulseDurations = [bootstrapObject.degappedSingleEventStatistics(pulseOrder).trialTransitPulseDuration]';

% determine indices for start and end of each pulse
endIndices = cumsum(lengthSES);
startIndices = [1;endIndices(1:end-1)+1];

% convert inputs that need converting
startIndices = uint64(startIndices);
observedTransitCount = uint64(observedTransitCount);
%bootstrapMaxIterations = uint64(bootstrapMaxIterations);
bootstrapUpperLimitFactor = int8(bootstrapUpperLimitFactor);
debugLevel = int8(debugLevel);
pulseOrder = uint32(pulseOrder);
skipCountArray = uint32(skipCountArray);
lengthSES = uint64(lengthSES);
pulseDurations = single(pulseDurations);

% run the bootstrap    
[probabilitiesPulse, probabilitiesCombined, iterations, finalSkipCount, isHistSmooth] = ...
    bootstrap( searchTransitThreshold, lowerMarginSigma, skipCountArray, ...
    observedTransitCount, lengthSES, numerator, denominator, statistics, ...
    debugLevel, bootstrapMaxIterations, bootstrapUpperLimitFactor, startIndices, ...
    pulseOrder, pulseDurations, numIterationsArray);

% check for failure
failIndex = find(iterations(:,2) == 0, 1, 'first');
% If timeout occured then abort
if ~isempty(failIndex)
    dvResultsStruct = exit_from_run_bootstrap(bootstrapObject, dvResultsStruct);
    return
end
        
% reorder outputs in original pulse order
[sortedPulses,sortKey] = sort(pulseOrder);
probabilitiesPulse = probabilitiesPulse(:,sortKey);
iterations = iterations(sortKey,:);
finalSkipCount = finalSkipCount(sortKey);
isHistSmooth = isHistSmooth(sortKey);
        
% copy outputs to results struct
bootstrapResultsStruct.probabilities = probabilitiesCombined;
for i=1:nPulseWidths
    bootstrapResultsStruct.histogramStruct(i).probabilities = probabilitiesPulse(:,i);
    bootstrapResultsStruct.histogramStruct(i).iterationsActual = iterations(i,1);
    bootstrapResultsStruct.histogramStruct(i).iterationsEstimate = iterations(i,2);
    bootstrapResultsStruct.histogramStruct(i).finalSkipCount = finalSkipCount(i);
    bootstrapResultsStruct.histogramStruct(i).isHistSmooth = isHistSmooth(i);
end

return 



%--------------------------------------------------------------------------
% Subfunction to exit from run_bootstrap if c-mex aborts
function dvResultsStruct = exit_from_run_bootstrap(bootstrapObject, dvResultsStruct)

messageString = sprintf('Bootstrap aborted in c-mex because it exceeded bootstrapUpperLimitFactor x bootstrapMaxIterations or because of a memory failure.\n');
warning(messageString)  %#ok<SPWRN,WNTAG>
dvResultsStruct = add_dv_alert(dvResultsStruct, 'bootstrap', ...
    'warning', messageString, bootstrapObject.targetNumber, ...
    bootstrapObject.keplerId, bootstrapObject.planetNumber);
return


