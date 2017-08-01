%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [binaryRemovedTimeSeries] =
% identify_and_remove_eclipsing_binaries(timeSeries, chunkSize, madXFactor, maxFitPolyOrder)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Description:
% This function is divided into two parts:
%    1) Determining whether the input time series contains a short period
%    eclipsing binary
%    2) fitting the eclipsing binary and removing it from the time series
%
% To determine if the time series contains a short period eclipsing binary,
% the autocorrelation of the time series is computed and compared to the
% sqrt(N) envelope (after being scaled by the mad of the regularized
% autocorrelation).  Peaks are identified in the data above the envelope
% and the peak spacings are used as trial periods.  If correlation of the
% time series with the time series that has been shifted by one period is
% above a hard coded threshold then the period is accepted as a rough
% estimate and the time series is deemed to contain either an eclipsing binary
% signature or a short period transiting planet.  To discriminate between
% the two, the interval between primary peaks is divided in half and the
% chunks are mirrored onto one another.  The EB case should have a high
% correlation since there is a secondary symmetric peak occurring beetween
% the primary peaks whereas a giant transiting planet should have a low
% correlation since it should just be noise in between.
%
% If the time series has been determined to contain a short period
% eclipsing binary then it is folded to determine the phase and period. An
% additional fine tuning of the period is done by minimizing the norm of a
% moving phase space variance over small period variation.  After the fine
% tuned period is found, the phase space representation is fitted piecewise
% and transformed back to the time domain where a residual time series is
% computed. Barycentric time correction has been determined to not make an
% appreciable difference on the residual time series.
%
% Inputs:
%       1) timeSeries: A time series
%       2) chunkSize: The size of chunks to divide the time series into
%       3) madXFactor:  MAD threshold multiplier for outlier screening
%          prior to robust estimation/fit.  This can be set relatively high
%          (10-20) since robustfit mitigates outliers.
%       4) maxFitPolyOrder:  Set a maximum to the polynomial order being
%          estimated and used for the fits to each chunk.
%       5) detrendedBoolean:  If this is set to 1, then the fitting in
%          phase space is done with wrap around chunking and tapering to
%          handle the very edges
%
%         
% Output:
%       1) fittedTimeSeries: The stitched together robustly fit polynomial
%          representation of the original time series.
%
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

function [binaryRemovedTimeSeries fittedTimeSeries isShortPeriodEclipsingBinary binaryPeriodInCadences binaryPhaseInCadences] = ...
    identify_and_remove_eclipsing_binaries(timeSeries, skipRemoval, madXFactor, maxFitPolyOrder, isDetrended)

nCadences = length(timeSeries);
cadenceTimes=1:nCadences;
cadenceTimes=cadenceTimes(:);

maxPeriodInCadences = 200;

% These parameters dont need to become module parameters
envelopeThreshold = 8.0; % lower this if some contact binaries are slipping through
correlationThreshold = 0.65; 
isOnlySecondaries = false;
periodSpacing=0.1;
phaseSpacing=0.1;

[isShortPeriodEclipsingBinary periodFromAutoCorrelation] = ...
    autocorrelation_test_for_eclipsing_binaries(timeSeries, envelopeThreshold, correlationThreshold, isOnlySecondaries);

% if it didnt pass the first test then exit
if ~isShortPeriodEclipsingBinary
    binaryRemovedTimeSeries = timeSeries;
    fittedTimeSeries = [];
    binaryPeriodInCadences = -1;
    binaryPhaseInCadences = -1;
    return;
end
if periodFromAutoCorrelation > maxPeriodInCadences
    % exit if the period is not short enough for this to be considered a
    % short period eclipsing binary
    isShortPeriodEclipsingBinary = false;
    binaryRemovedTimeSeries = timeSeries;
    fittedTimeSeries = [];
    binaryPeriodInCadences = -1;
    binaryPhaseInCadences = -1;
    return;
end

%  I can afford to go very fine in the search period spacing here since the
%  interval is going to be very small
possiblePeriodsInCadences = (periodFromAutoCorrelation-1.5):periodSpacing:(periodFromAutoCorrelation+1.5);

% inputs needed for fold_periods
possiblePeriodsInCadences = possiblePeriodsInCadences(:);
nPeriods = length(possiblePeriodsInCadences);
normalizationTimeSeries = ones(nCadences,1);
deltaLagInCadences = 1;

% Get precise period from folding
[foldedStatisticAtTrialPeriods, minStatistic,  phaseLagForMaxStatisticInCadences, phaseLagForMinStatisticInCadences] = ...
    fold_periods(possiblePeriodsInCadences, timeSeries, normalizationTimeSeries,deltaLagInCadences, nPeriods, nCadences);
indexOfBestPeriod = locate_center_of_asymmetric_peak(foldedStatisticAtTrialPeriods);
binaryPeriodInCadences = possiblePeriodsInCadences(indexOfBestPeriod) ;

% get the associated phase 
possiblePhasesInCadences =  (0:phaseSpacing:round(binaryPeriodInCadences)-1)';
foldedStatisticAtTrialPhases = fold_phases(possiblePhasesInCadences, timeSeries, binaryPeriodInCadences);
indexOfBestPhase = locate_center_of_asymmetric_peak(-foldedStatisticAtTrialPhases);    
binaryPhaseInCadences = possiblePhasesInCadences(indexOfBestPhase);

% Now I need to discriminate between planets and eclipsing binaries - the
% previous code will identify giant planetary transits.  To distinguish
% between the two cases I will collect all the regions centered between
% primary peaks with length T/2 and correlate them with a circular shift 
% of T/2. An EB should be strongly correlated since it has secondary peaks,
% whereas a transiting planet should just have noise in those regions.

% if the period is small then I need to double it for the purposes of this
% test so that the secondary chunks time series is ok
if binaryPeriodInCadences < 20
    binaryPeriodInCadencesTest = binaryPeriodInCadences*2;
else
    binaryPeriodInCadencesTest = binaryPeriodInCadences;
end

numPrimaryPeaksToUse = floor((nCadences - ceil(binaryPhaseInCadences))/binaryPeriodInCadencesTest) - 1;
secondaryChunks = zeros(numPrimaryPeaksToUse * floor(binaryPeriodInCadencesTest/2),1);

for i=1:numPrimaryPeaksToUse
    primaryPeakLocation = round(binaryPhaseInCadences + (i-1) * binaryPeriodInCadencesTest);
    lowIndex = 1+(i-1)*floor(binaryPeriodInCadencesTest/2);
    highIndex = (i)*floor(binaryPeriodInCadencesTest/2);
    lowIndexTS = primaryPeakLocation + ceil(binaryPeriodInCadencesTest/4);
    highIndexTS = lowIndexTS + floor(binaryPeriodInCadencesTest/2)-1;
    secondaryChunks(lowIndex:highIndex) = timeSeries(lowIndexTS:highIndexTS);
end

% perform the autocorrelation test on the secondary chunks time series
isOnlySecondaries = true;
envelopeThreshold = 5;
correlationThreshold = 0.5;
[isShortPeriodEclipsingBinary periodFromSecondaryChunks] = ...
    autocorrelation_test_for_eclipsing_binaries(secondaryChunks, envelopeThreshold, correlationThreshold, isOnlySecondaries);

% Now require both passing of the autocorrelation test and consistency of
% the periods for this to be acknowledged as a short period EB
if ~isShortPeriodEclipsingBinary
    % didnt pass autocorr test so exit
    binaryRemovedTimeSeries = timeSeries;
    fittedTimeSeries = [];
    binaryPeriodInCadences = -1;
    binaryPhaseInCadences = -1;
    return;
end

% if period from secondary chunks is a half integer multiple between 0.5
% and 2 of the period from the first autocorrelation then accept it
halfIntegerMultiples = [0.25, 0.5, 1, 3/2, 2]';
padding = 5;
padding = -padding:1:padding;
acceptablePeriods = round(binaryPeriodInCadences*halfIntegerMultiples);
acceptablePeriods = bsxfun(@plus,acceptablePeriods,padding);
acceptablePeriods = reshape(acceptablePeriods,numel(acceptablePeriods),1);
acceptablePeriods = unique(sort(acceptablePeriods(acceptablePeriods > 0)));
if ~isequal(ismember(periodFromSecondaryChunks,acceptablePeriods),1) 
    %periods are not consistent so exit
    isShortPeriodEclipsingBinary = false;
    binaryRemovedTimeSeries = timeSeries;
    fittedTimeSeries = [];
    binaryPeriodInCadences = -1;
    binaryPhaseInCadences = -1;
    return;
end

if binaryPeriodInCadences > maxPeriodInCadences
    % exit if the period is not short enough for this to be considered a
    % short period eclipsing binary
    isShortPeriodEclipsingBinary = false;
    binaryRemovedTimeSeries = timeSeries;
    fittedTimeSeries = [];
    binaryPeriodInCadences = -1;
    binaryPhaseInCadences = -1;
    return;
end

% Now we are done with the identification so if we dont need to do the
% removal then just exit here
if skipRemoval
    binaryRemovedTimeSeries = timeSeries;
    fittedTimeSeries = [];
    return;
end

% Vary period slightly to minimize the phase space residual
periodRangeInCadences = 0.15;
periodResolutionInCadences = periodSpacing/10;
periodFromMinimizationInCadences = minimize_phase_space_residual(timeSeries, cadenceTimes, ...
    binaryPeriodInCadences, binaryPhaseInCadences, periodRangeInCadences, periodResolutionInCadences);

% transform to phase space
[phase, phaseSorted, sortKey, phaseSpaceFluxValues] = fold_time_series(cadenceTimes,binaryPhaseInCadences,periodFromMinimizationInCadences,timeSeries);

% get the unSortKey for transforming back 
[sortedSortKey, unSortKey] = sort(sortKey);

chunkSize = round(1.5 * nCadences/binaryPeriodInCadences);

% do the piecewise robust fit in phase space
fittedPhaseSpaceFluxValues = piecewise_robustfit_timeseries(phaseSpaceFluxValues, chunkSize, madXFactor, maxFitPolyOrder);

if isDetrended
    % grab a half a chunk from beginning and end to do wrap around fitting
    halfChunkSize = floor(chunkSize);
    startChunk = phaseSpaceFluxValues(1:halfChunkSize);
    endChunk = phaseSpaceFluxValues(end-halfChunkSize+1:end);
    
    % flip and concat together
    wrappedChunk = vertcat(flipud(startChunk),flipud(endChunk));
    
    % robust fit
    fittedWrappedChunk = piecewise_robustfit_timeseries(wrappedChunk, halfChunkSize, madXFactor, maxFitPolyOrder);
    
    % now replace the beginning and end chunks with the new wrapped fit
    % chunks
    startChunk = fittedWrappedChunk(1:halfChunkSize);
    endChunk = fittedWrappedChunk(halfChunkSize+1:end);
    startChunk = flipud(startChunk);
    endChunk = flipud(endChunk);
    fittedPhaseSpaceFluxValues(1:halfChunkSize) = startChunk;
    fittedPhaseSpaceFluxValues(end-halfChunkSize+1:end) = endChunk;
end

fittedTimeSeries = fittedPhaseSpaceFluxValues(unSortKey);

% remove the binary signature from the time series
binaryRemovedTimeSeries = timeSeries - fittedTimeSeries; 

return;




%--------------------------------------------------------------------------
% locate the center of a broad, possibly asymmetric peak
%--------------------------------------------------------------------------

function peakCenter = locate_center_of_asymmetric_peak(foldedStatisticValues)

% subtract the minimum so that the distribution goes down to zero value

foldedStatisticValues = foldedStatisticValues(:) - min(foldedStatisticValues) ;

polyOrderToFit = 3;
limitOnExtentOfPeak = 10;

% find the location and value of the maximum

[maxValue, maxIndex] = max(foldedStatisticValues) ;
halfMaxValue = maxValue/2 ;

% Look forwards and backwards to find the points closest to the peak which bracket the
% half-max;

forwardIndex = find(foldedStatisticValues(maxIndex:end) < halfMaxValue , 1, 'first') ;

if(~isempty(forwardIndex))
    % in case the half width sample is found far away, limit the extent to < 3
    forwardIndex = min(forwardIndex, limitOnExtentOfPeak);
    forwardIndex = forwardIndex + maxIndex;
    forwardIndex = forwardIndex(forwardIndex <= length(foldedStatisticValues));
end

backwardIndex = find(foldedStatisticValues(1:maxIndex) < halfMaxValue , 1, 'last') ;

if(~isempty(backwardIndex))
    backwardIndex = max(backwardIndex, (maxIndex-limitOnExtentOfPeak));
end


if(~isempty(backwardIndex) && ~isempty(forwardIndex))
    indexToFit = (backwardIndex:forwardIndex)';
    
    if(length(indexToFit) > polyOrderToFit)
        
        % fit a cubic to the broad, probably asymmetric peak
        [polyCoeffts, structureS, mu]  = polyfit(indexToFit, foldedStatisticValues(indexToFit),polyOrderToFit);
        
        fittedValues = polyval(polyCoeffts, indexToFit, structureS, mu);
        [peakValue, peakCenter] = max(fittedValues);
        peakCenter = indexToFit(peakCenter(1)); % in case there are more
    else
        peakCenter = maxIndex;
    end
else
    peakCenter = maxIndex;
end

return


%--------------------------------------------------------------------------
% Autocorrelation test
%--------------------------------------------------------------------------

function [isShortPeriodEclipsingBinary periodFromAutoCorrelation correlationCoefficient] = ...
    autocorrelation_test_for_eclipsing_binaries(timeSeries, envelopeThreshold, correlationThreshold, isOnlySecondaries)

% Initialize outputs
isShortPeriodEclipsingBinary = false;
periodFromAutoCorrelation = -1;
correlationCoefficient = -1;

% Check Inputs
if isempty(timeSeries)
    return;
end
if envelopeThreshold < 0 || correlationThreshold < 0
    % invalid threshold
    return;
end

madWindowLength = min(length(timeSeries),100);
nCadences = length(timeSeries);
autoCorrCadences = (-(nCadences-1):(nCadences-1))'; %2N-1
% The envelope of the autocorrelation should scale as sqrt(N) for Gaussian
% noise
envelope = sqrt(nCadences-abs(autoCorrCadences))/sqrt(nCadences);

medianAdjPeriodicTarget = timeSeries-median(timeSeries);
autoCorrPeriodicTarget = xcorr(medianAdjPeriodicTarget); %2N-1

% Just use the last madWindowLength points to estimate MAD since for
% contact binaries you would get an overestimate otherwise.  If its
% gaussian then it shouldnt matter too much
madOfRegularizedAutoCorr = mad(autoCorrPeriodicTarget(end-madWindowLength:end)./envelope(end-madWindowLength:end),1);
normalizedAutoCorr = autoCorrPeriodicTarget/madOfRegularizedAutoCorr;

% keep only the right half to remove redundancy - dont use the very last
% point though since the envelope is zero there
normalizedAutoCorr = normalizedAutoCorr(nCadences:end);
envelope = envelope(nCadences:end);

% grab points above the threshold
pointsAboveThreshold = find(normalizedAutoCorr > envelope * envelopeThreshold);
% make sure there are points left
if length(pointsAboveThreshold) < 1
    % no points were above threshold, so this fails the test
    return;
end

% get rid of the center peak at zero
peakStartIndices = find(diff(pointsAboveThreshold)~=1) + 1;
if length(peakStartIndices) < 1
    % there are no dips so this is not consistent with an EB
    return;
end

peakEndValues = pointsAboveThreshold(peakStartIndices-1);
[tf, peakEndIndices] = ismember(peakEndValues, pointsAboveThreshold);
peakEndIndices = peakEndIndices(2:end);
%convert to indices of the time series
peakStartIndices = pointsAboveThreshold(peakStartIndices);
peakEndIndices = pointsAboveThreshold(peakEndIndices);
peakEndIndices = vertcat(peakEndIndices,nCadences);

% locate all the peaks
peaksAboveThreshold = zeros(length(peakStartIndices),1);
for i=1:length(peakStartIndices)
    peaksAboveThreshold(i) =  locate_center_of_asymmetric_peak(normalizedAutoCorr(peakStartIndices(i):peakEndIndices(i)));
    peaksAboveThreshold(i) = peaksAboveThreshold(i) + peakStartIndices(i) - 1;
end

% Some binaries have strong secondary peaks that can cause the period to be
% found at half the actual period.  Start at the highest peak out of the
% first two to avoid this.
if length(peaksAboveThreshold) > 1 && ~isOnlySecondaries
    highestPeakIndex = find(normalizedAutoCorr(peaksAboveThreshold(1:2)) == max(normalizedAutoCorr(peaksAboveThreshold(1:2))));
    peaksAboveThreshold = peaksAboveThreshold(highestPeakIndex:end);
end

% Take the first peak that gives a suitable correlation coefficient
% pad the peaks by +/- 1 cadence for the ultra low period binaries
for i=1:length(peaksAboveThreshold)
    correlationCoefficientsPadded = zeros(3,1);
    for j=1:3
        correlationCoefficientsPadded(j) = corr(timeSeries,circshift(timeSeries,-peaksAboveThreshold(i)+j-2));
    end
    correlationCoefficient = max(correlationCoefficientsPadded);
    %turn padding off with the following line
    %correlationCoefficient = correlationCoefficientsPadded(2);
    if correlationCoefficient > correlationThreshold
        % this passes the test so exit with values
        isShortPeriodEclipsingBinary = true;
        periodFromAutoCorrelation = peaksAboveThreshold(i);
        return;
    elseif isequal(i,length(peaksAboveThreshold))
        % None of the periods lead to good correlation so this is not
        % a short period eclipsing binary - exit
        return;
    else
    end
end

return


%--------------------------------------------------------------------------
% Get precise phase from folding
%--------------------------------------------------------------------------

function foldedStatisticAtTrialPhases = fold_phases(possiblePhasesInCadences, timeSeries, periodInCadences)

possiblePhasesInCadences =  possiblePhasesInCadences(:);
timeSeries=timeSeries(:);
nCadences = length(timeSeries);
correlationTimeSeriesFolded = zeros(length(possiblePhasesInCadences),1);

iCount = 0;
for jLag = possiblePhasesInCadences'
    iCount = iCount +1;
    if(jLag <= 0.5)
        kPeriodInCadences = jLag +0.5 ; % not an integer but a float
    else
        kPeriodInCadences = jLag; % not an integer but a float
    end
    while (kPeriodInCadences <= nCadences)
        if(kPeriodInCadences > nCadences)
            break;
        end;
        correlationTimeSeriesFolded(iCount) = correlationTimeSeriesFolded(iCount) + ...
            timeSeries(round(kPeriodInCadences));
        kPeriodInCadences = kPeriodInCadences + periodInCadences;
    end;
end;

foldedStatisticAtTrialPhases = correlationTimeSeriesFolded(1:iCount);

return


%--------------------------------------------------------------------------
% Locally minimize the phase space residual with respect to period
%--------------------------------------------------------------------------

function periodFromMinimizationInCadences = minimize_phase_space_residual(timeSeries, cadenceTimes, ...
    periodInCadences, phaseInCadences, periodRangeInCadences, periodResolutionInCadences)

nCadences = length(timeSeries);
tempNorm=inf;
tempT=0;
for i=periodInCadences-periodRangeInCadences:periodResolutionInCadences:periodInCadences+periodRangeInCadences
    [phase, phaseSorted, sortKey, phaseSpaceFluxValues] = fold_time_series(cadenceTimes,phaseInCadences,i,timeSeries);
    
    % Minimize the norm of the moving variance to avoid fitting - 
    % this should never be replaced with a moving mad type filter since the
    % whole point is to get the correct phase space ordering so there is no
    % outliers within a particular window
    
    % compute the moving variance using filter
    
    windowSize = round(periodInCadences);
    
    % subtract mean to minimize numerical error
    phaseSpaceFluxValues = phaseSpaceFluxValues - mean(phaseSpaceFluxValues);
    aCoeffs = 1;
    bCoeffs = ones(1,2*windowSize+1);
    movingVariance = (filter(bCoeffs,aCoeffs,phaseSpaceFluxValues.^2)-(filter(bCoeffs,aCoeffs,phaseSpaceFluxValues).^2)*(1/(2*windowSize+1)))/(2*windowSize);
    movingVariance(windowSize:(nCadences-windowSize)) = movingVariance((2*windowSize):end);
    % fix both ends since this is a central moving variance
    for j=1:windowSize
        movingVariance(j) = var(phaseSpaceFluxValues(1:(windowSize+j)));
        movingVariance(nCadences-windowSize+j) = var(phaseSpaceFluxValues((nCadences-2*windowSize+j):nCadences));
    end
    residualNormSquared = sum(movingVariance);
        
    if residualNormSquared < tempNorm
        tempNorm = residualNormSquared;
        tempT = i;
    end
    
end
periodFromMinimizationInCadences = tempT;

return
