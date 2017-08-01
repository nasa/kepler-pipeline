function [cosmicRayCorrectedPixelArray, cosmicRayEventsIndicators] = ...
clean_cosmic_rays_mad(pixelArrayToCorrect, gapArray, ...
cosmicRayConfigurationStruct, reactionWheelZeroCrossingIndices)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [cosmicRayCorrectedPixelArray, cosmicRayEventsIndicators] = ...
% clean_cosmic_rays_mad(pixelArrayToCorrect, gapArray, ...
% cosmicRayConfigurationStruct, reactionWheelZeroCrossingIndices)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% THIS IS THE FIRST COSMIC RAY CLEANING ALGORITHM THAT WAS SUPPLANTED BY
% paCosmicRayCleanerClass beginning with SOC release 8.3.
%
% Perform median filtering with short duration filter. Apply a MAD
% threshold to identify outliers ("cosmic rays"). In this sense, cosmic
% ray deltas can be both positive and negative. Perform a second pass with
% somewhat longer filter for pixels with a large number of outlier events.
% Return array of corrected pixels and logical array of cosmic ray event
% indicators (each with dimension nCadences x nPixels).
%
% Generally cosmic rays should not occur on consecutive cadences for the
% same pixel. If the optional consecutiveCosmicRayCleaningEnabled is true,
% however, then outliers detected on consecutive cadences for a given pixel
% will be identified as cosmic rays.
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


% Check optional argument.
if ~exist('reactionWheelZeroCrossingIndices', 'var')
    reactionWheelZeroCrossingIndices = [];
end

% Define constant.
GAUSSIAN_SIGMA_PER_MAD = 1.4826;

% Set parameter values if they were not specified.
detrendOrder = cosmicRayConfigurationStruct.detrendOrder;
medianFilterLength = cosmicRayConfigurationStruct.medianFilterLength;
madThreshold = cosmicRayConfigurationStruct.madThreshold;
madWindowLength = cosmicRayConfigurationStruct.madWindowLength;
thresholdMultiplierForNegativeEvents = ...
    cosmicRayConfigurationStruct.thresholdMultiplierForNegativeEvents;
consecutiveCosmicRayCleaningEnabled = ...
    cosmicRayConfigurationStruct.consecutiveCosmicRayCleaningEnabled;
twoSidedFinalThresholdingEnabled = ...
    cosmicRayConfigurationStruct.twoSidedFinalThresholdingEnabled;

% Save the input pixels values and return if insufficient data are
% available.
cosmicRayCorrectedPixelArray = pixelArrayToCorrect;
cosmicRayEventsIndicators = false(size(cosmicRayCorrectedPixelArray));

nCadences = size(pixelArrayToCorrect, 1);
if nCadences < 2 * medianFilterLength
    return
end

% Get unit Gaussian random number sequence, one value per cadence.
randn('state', 0);
unitRandomSequence = randn([size(gapArray, 1), 1]);

% Gap the data on the reaction wheel zero crossing cadences. Cosmic rays
% are not to be identified on these cadences, and this data should not
% affect the identification of cosmic rays on the other cadences.
gapArray(reactionWheelZeroCrossingIndices, : ) = true;

% Fill all gaps with linear interpolation. Do this as efficiently as
% possible.
nPixels = size(pixelArrayToCorrect, 2);
pixelList = (1 : nPixels);

isValidTimeSeries = sum(~gapArray, 1) > 2;
if any(~isValidTimeSeries)
    gapArray( : , ~isValidTimeSeries) = true;
end
if all(gapArray( : ))
    return
end
pixelArrayToCorrect(gapArray) = 0;

while ~isempty(pixelList)

    % Find all pixel time series with gap indicator sequences that match
    % the gap indicator sequence of the first pixel in the list.
    pixelToMatch = pixelList(1);
    gapIndicatorsToMatch = gapArray( : , pixelToMatch);
    gapsIndicatorsToMatchArray = ...
        repmat(gapIndicatorsToMatch, [1, length(pixelList)]);
    matchingPixelList = pixelList(all(gapsIndicatorsToMatchArray == ...
        gapArray( : , pixelList), 1));
    clear gapsIndicatorsToMatchArray;
    
    % Perform linear interpolation for all pixel time series with
    % matching gaps.
    if ~all(gapIndicatorsToMatch)
        pixelArrayToCorrect(gapIndicatorsToMatch, matchingPixelList) = ...
            interp1(find(~gapIndicatorsToMatch), ...
            pixelArrayToCorrect(~gapIndicatorsToMatch, matchingPixelList), ...
            find(gapIndicatorsToMatch), 'linear', 'extrap');
    end
    
    % Update the list of pixels to be gap filled.
    pixelList = setdiff(pixelList, matchingPixelList);
    
end % while

% Do low order polynomial detrending to reduce median filter edge effects.
pixelArrayToCorrect = detrendcols(pixelArrayToCorrect, detrendOrder);

% Perform median filtering, compute residuals and apply MAD threshold. Try
% it a second time with a slightly longer median filter for targets with
% many events. The threshold can be multiplied for negative going outliers
% to help protect transits. Note that with the short duration median
% filtering, it is possible for the MAD to be equal to 0 for some time
% series. Do something reasonable here so that processing can proceed. Add
% random noise where flux values were interpolated so that the running MAD
% produces representative results in the vicinity of long gaps.
pixelList = (1 : nPixels);
residualArray = zeros(size(pixelArrayToCorrect));
countThreshold = 2.0;

for iCount = 1 : 2
    
    residualArray( : , pixelList) = ...
        pixelArrayToCorrect( : , pixelList) - ...
        medfilt1(pixelArrayToCorrect( : , pixelList), medianFilterLength);
    
    medianAbsoluteDeviation = mad(residualArray, 1);
    isZero = medianAbsoluteDeviation < eps;
    if all(isZero)
        return
    else
        medianAbsoluteDeviation(isZero) = ...
            median(medianAbsoluteDeviation(~isZero));
    end
    
    for iPixel = pixelList
        dev = mad(residualArray(~gapArray( : , iPixel), iPixel), 1);
        if dev > medianAbsoluteDeviation(iPixel)
            medianAbsoluteDeviation(iPixel) = dev;
        end
        residualArray(gapArray( : , iPixel), iPixel) = ...
            residualArray(gapArray( : , iPixel), iPixel) + ...
            medianAbsoluteDeviation(iPixel) * GAUSSIAN_SIGMA_PER_MAD * ...
            unitRandomSequence(gapArray( : , iPixel));
    end % for iPixel
    
    residualArray( : , pixelList) = residualArray( : , pixelList) - ...
        repmat(median(residualArray( : , pixelList)), [nCadences, 1]);
    
    madArray( : , pixelList) = ...
        running_mad(residualArray( : , pixelList), madWindowLength);                               %#ok<AGROW>
    
    isZero = madArray < eps;
    tempArray = repmat(medianAbsoluteDeviation, [nCadences, 1]);
    madArray(isZero) = tempArray(isZero);                                                          %#ok<AGROW>
    clear tempArray
    
    cosmicRayEventsIndicators = ...
        residualArray > madThreshold * madArray | ...
        residualArray < -thresholdMultiplierForNegativeEvents  * ...
        madThreshold * madArray;
        
    countOverThreshold = sum(cosmicRayEventsIndicators, 1);
    
    madForCounts = max(mad(countOverThreshold, 1), 1);
    pixelList = find((countOverThreshold - median(countOverThreshold)) > ...
        countThreshold * madForCounts);
    if isempty(pixelList)
        break;
    else
        medianFilterLength = 2 * medianFilterLength - 1;
        countThreshold = 3.0;
    end
    
end % for iCount

% Raise the threshold if there are still pixels with many events, and
% identify the typical number of events. By default, events must be
% positive. However, events may be positive or negative if
% twoSidedFinalThresholdEnabled is true. There is a good chance that
% many/most of the large events will be negative going due to transits.
if ~isempty(pixelList)
    pixelResiduals = residualArray( : , pixelList);
    isLessThanZero = pixelResiduals < 0;
    pixelResiduals(isLessThanZero) = ...
        pixelResiduals(isLessThanZero) / thresholdMultiplierForNegativeEvents ;
    if twoSidedFinalThresholdingEnabled
        pixelResiduals = abs(pixelResiduals);
    end
    desiredCount = median(countOverThreshold);
    pixelResiduals = pixelResiduals ./ madArray( : , pixelList);
    thresholds = prctile(pixelResiduals, ...
        100 * (1 - desiredCount / nCadences), 1);
    thresholds = max(thresholds, madThreshold);
    cosmicRayEventsIndicators( : , pixelList) = ...
        pixelResiduals > repmat(thresholds, [nCadences, 1]);
    clear pixelResiduals isLessThanZero madArray
end % if

% Cosmic rays should not really occur sequentially. Remove all consecutive
% cosmic ray events. First ensure that gapped input values are not
% inadvertently identified as cosmic rays.
cosmicRayEventsIndicators(gapArray) = false;

if ~consecutiveCosmicRayCleaningEnabled
    sequentialEventsIndicators = cosmicRayEventsIndicators(1 : end-1, : ) ...
        & cosmicRayEventsIndicators(2 : end, : );
    cosmicRayEventsIndicators([sequentialEventsIndicators; false([1, nPixels])]) = false;
    cosmicRayEventsIndicators([false([1, nPixels]); sequentialEventsIndicators]) = false;
    clear sequentialEventsIndicators
end % if

% Compute the cosmic ray corrected pixel values.
cosmicRayCorrectedPixelArray(cosmicRayEventsIndicators) = ...
    cosmicRayCorrectedPixelArray(cosmicRayEventsIndicators) - ...
    residualArray(cosmicRayEventsIndicators);

% Return.
return
