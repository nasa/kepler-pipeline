function [saturationSegmentsStruct] = ...
locate_saturation_segments(saturationSegmentConfigurationStruct, ...
fluxWithoutTransitsArray, gapIndicatorsArray, keplerMags, ...
dataAnomalyIndicators)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [saturationSegmentsStruct] = ...
% locate_saturation_segments(saturationSegmentConfigurationStruct, ...
% fluxWithoutTransitsArray, gapIndicatorsArray, keplerMags, ...
% dataAnomalyIndicators)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Attempt to locate saturation segments, where flux curves have abrupt
% change in curvature. This procedure is simplified because large transits
% have been removed. The flux curve for each target is fit with a sliding
% polynomial and the second derivative is evaluated at the central point
% for every sample. See help for matlab 'sgolay' for details of
% Savitzky-Golay filtering.
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


% Set Savitzky-Golay constant. Saturated segments are identified by
% thresholding the magnitude of the 2nd derivative of the flux time series.
% That is not a parameter that can be changed.
SGOLAY_DERIVATIVE = 2;

% Get module parameters.
sgPolyOrder = saturationSegmentConfigurationStruct.sgPolyOrder;
sgFrameSize = saturationSegmentConfigurationStruct.sgFrameSize;
satSegThreshold = saturationSegmentConfigurationStruct.satSegThreshold;
satSegExclusionZone = ...
    saturationSegmentConfigurationStruct.satSegExclusionZone;
maxSaturationMagnitude = ...
    saturationSegmentConfigurationStruct.maxSaturationMagnitude;

% Set buffers around the known anomalies where "saturation segment"
% breakpoints are not permissible.
nCadences = size(gapIndicatorsArray, 1);
anomalyBufferIndicators = false([nCadences, 1]);

if ~isempty(dataAnomalyIndicators)
    safeModeIndices = find(dataAnomalyIndicators.safeModeIndicators);
    earthPointIndices = find(dataAnomalyIndicators.earthPointIndicators);
    attitudeTweakIndices = find(dataAnomalyIndicators.attitudeTweakIndicators);
    coarsePointIndices = find(dataAnomalyIndicators.coarsePointIndicators);
    for iCadence = 1 : nCadences
        if any(abs(iCadence - safeModeIndices) <= satSegExclusionZone) || ...
                any(abs(iCadence - earthPointIndices) <= satSegExclusionZone) || ...
                any(abs(iCadence - attitudeTweakIndices) <= satSegExclusionZone) || ...
                any(abs(iCadence - coarsePointIndices) <= satSegExclusionZone)
            anomalyBufferIndicators(iCadence) = true;
        end % if
    end % for iCadence
end % if
        
% Use matlab 'sgolay' to compute filter coefficients.
[b, g] = sgolay(sgPolyOrder, sgFrameSize);
sgolayFilter = g( : , SGOLAY_DERIVATIVE + 1);
sgolayFilterDelay = (sgFrameSize - 1) / 2;
clear b g;

% Initialize the array of output structures to include all possible targets.
% It will be compressed later to include only saturated targets.
nTargets = size(fluxWithoutTransitsArray, 2);

saturationSegmentsStruct = repmat(struct( ...
    'target', [], ...
    'peakStatistics', [], ...
    'indxPeakStatistics', [] ), [1, nTargets]);

% Create list of targets to be processed.
targetList = (1 : nTargets);

% Loop through the list of standard targets, processing each target with all
% other targets that have identical gaps (i.e. missing data for the same set
% of cadences).
while ~isempty(targetList)

    % Find all flux time series with gap indicator sequences that match the
    % gap indicator sequence of the first target in the list.
    targetToMatch = targetList(1);
    gapIndicatorsToMatch = gapIndicatorsArray( : , targetToMatch);
    gapsIndicatorsToMatchArray = ...
        repmat(gapIndicatorsToMatch, [1, length(targetList)]);
    matchingTargetList = targetList(all(gapsIndicatorsToMatchArray == ...
        gapIndicatorsArray( : , targetList)));
    matchingTargetMags = keplerMags(matchingTargetList);
    clear gapsIndicatorsToMatchArray;
    
    % Collect the valid flux samples (with giant transits removed) for all
    % targets in the matching list.
    fluxNoGapsArray = ...
        fluxWithoutTransitsArray(~gapIndicatorsToMatch, ...
        matchingTargetList);
    
    if size(fluxNoGapsArray, 1) < sgFrameSize
        targetList = setdiff(targetList, matchingTargetList);
        continue;
    end
    
    % Squeeze the anomaly buffer for the current set of gaps.
    anomalyBufferIndices = find(anomalyBufferIndicators(~gapIndicatorsToMatch));
    
    % Estimate 2nd order derivative for all targets at each flux sample with
    % Savitzky-Golay filter. Subtract the median flux for each target.
    filteredFluxArray = ...
        filter(sgolayFilter, 1, fluxNoGapsArray);
    filteredFluxArray = filteredFluxArray(sgFrameSize : end, : );
    nStatisticsPerTarget = size(filteredFluxArray, 1);
    medianFilteredFlux = median(filteredFluxArray);
    filteredFluxArray = filteredFluxArray - ...
        repmat(medianFilteredFlux, [nStatisticsPerTarget, 1]);

    % The test statistic for location of the saturation segments is the ratio 
    % of the absolute value of the second derivative (with the mean subtracted
    % for each target) to the median absolute deviation of the estimated second
    % derivatives for each target. Before locating the saturation segments,
    % determine the targets which have at least one peak above threshold.
    medianAbsoluteDeviations = mad(filteredFluxArray, 1);
    maxTestStatistics = ...
        max(abs(filteredFluxArray)) ./ medianAbsoluteDeviations;
    targetsOverThreshold = matchingTargetList( ...
        maxTestStatistics > satSegThreshold & ...
        matchingTargetMags <= maxSaturationMagnitude);
    nTargetsOverThreshold = length(targetsOverThreshold);

    % Locate the saturation segments for each target. The breakpoints for the
    % segments are the points at which there is a large change in curvature.
    % Strictly speaking these segments may result from phenomena other than
    % saturation. but it is still worthwhile to cotrend the segments separately.
    for iTarget = 1 : nTargetsOverThreshold
    
        % Compute all test statistics for the given target.
        target = targetsOverThreshold(iTarget);
        isTarget = (target == matchingTargetList);
        statistics = abs(filteredFluxArray( : , isTarget)) ./ ...
            medianAbsoluteDeviations(isTarget);
    
        % Locate all peaks over threshold, beginning with the largest. Exclude
        % smaller secondary peaks close to each major peak. These would
        % necessitate cotrending over short intervals and may result from
        % artifacts in estimation of the second derivatives.
        iCount = 1;
        peakStatistics = [];
        indxPeakStatistics = [];
    
        while any(statistics > satSegThreshold)
            [peak, indxPeak] = max(statistics);
            peakStatistics(iCount) = peak;                                                 %#ok<AGROW>
            indxPeak = estimate_peak_center(indxPeak, statistics, ...
                satSegExclusionZone);
            indxPeakStatistics(iCount) = indxPeak;                                         %#ok<AGROW>
            indxToExclude = ...
                (indxPeak - satSegExclusionZone : indxPeak + satSegExclusionZone);
            indxToExclude = indxToExclude(indxToExclude >= 1 & ...
                indxToExclude <= nStatisticsPerTarget);
            statistics(indxToExclude) = 0;
            iCount = iCount + 1;
        end % while
    
        % Sort the indices (and associated peaks) and fill the output
        % structure. First add the filter delay to the indices of the
        % peaks. Eliminate any peaks in the neighborhood of spacecraft safe
        % modes, attitude tweaks or coarse points.
        indxPeakStatistics = indxPeakStatistics + sgolayFilterDelay;
        [indxPeakStatistics, ix] = sort(indxPeakStatistics);
        peakStatistics = peakStatistics(ix);
        
        isPeakToExclude = ismember(indxPeakStatistics, anomalyBufferIndices);
        if ~all(isPeakToExclude)
            saturationSegmentsStruct(target).target = target;
            saturationSegmentsStruct(target).peakStatistics = ...
                peakStatistics(~isPeakToExclude);
            saturationSegmentsStruct(target).indxPeakStatistics = ...
                indxPeakStatistics(~isPeakToExclude);
        end % if
    
    end % for iTarget
    
    % Update the list of remaining targets.
    targetList = setdiff(targetList, matchingTargetList);
    
end % while

% Compress the output array.
saturatedTargetList = [saturationSegmentsStruct.target];
saturationSegmentsStruct = saturationSegmentsStruct(saturatedTargetList);

% Return
return



function [indxPeakCenter] = estimate_peak_center(indxPeak, statistics, ...
satSegExclusionZone)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [indxPeakCenter] = estimate_peak_center(indxPeak, statistics, ...
% satSegExclusionZone)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Compute and return the center of mass of the statistics distribution in
% the neighborhood of the given index.
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

% Determine the range for performing the center of mass computation.
nStatistics = length(statistics);

range = (indxPeak - ceil(satSegExclusionZone / 8) : ...
    indxPeak + ceil(satSegExclusionZone / 8))';
isValid = range > 1 & range <= nStatistics;
range = range(isValid);

% Compute and return the center of mass. Round to the closest index. Don't
% try to improve the index if some of the statistics in the neighborhood of
% the peak have been zeroed out due to proximity to a prior peak.
if any(statistics(range) == 0)
    indxPeakCenter = indxPeak;
else
    indxPeakCenter = ...
        round(sum(range .* statistics(range)) / sum(statistics(range)));
end

% Return.
return
