function [metricReport] = ...
create_report(pdqScienceObject, metricTs, fixedLowerBound, fixedUpperBound, ...
metricName, metricUnits, cadenceTimes, newSampleTimes, castToSingle, ...
subplotMnp, ccdModule, ccdOutput, currentModOut)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [metricReport] = ...
% create_report(pdqScienceObject, metricTs, fixedLowerBound, fixedUpperBound, ...
% metricName, metricUnits, cadenceTimes, newSampleTimes, castToSingle, ...
% subplotMnp, ccdModule, ccdOutput, currentModOut)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Create PDQ metric report for the given metric time series. Check the
% series against the given fixed bounds. Exponentially smooth the series to
% obtain running estimates of the mean and variance. Set adaptive upper
% bounds based on the running estimate of the mean and variance, and the
% adaptive X-factor that is supplied through the PDQ configuration
% parameters. Check the series against the adaptive bounds as well. Fit a
% trend to the latest values of the metric, and predict if it will cross a
% bound (adaptive or fixed) within a horizon time obtained from the
% configuration parameters. Report separately on fixed and adaptive bounds
% crossings and predictions. Set alerts to the operator based on severity
% of a bounds crossing event or prediction.
%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% INPUT:  The following arguments are specified for this function.
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
%              pdqScienceObject: [object]  object instantiated from PDQ input structure
%                      metricTs: [struct]  metric time series for single module output
%                fixedLowerBound: [float]  fixed lower bound for given metric
%                fixedUpperBound: [float]  fixed upper bound for given metric
%                    metricName: [string]  name of PDQ metric
%                   metricUnits: [string]  units for PDQ metric
%            cadenceTimes: [double array]  time tags for cadences (MJD)
%          newSampleTimes: [double array]  time tags for new cadences to PDQ (MJD)
%                 castToSingle: [logical]  if true, cast time series to single precision
%                                          for tracking and trending
%                 subplotMnp: [int array]  tracking and trending subplot coordinates
%                        ccdModule: [int]  ccd module number
%                        ccdOutput: [int]  ccd output number
%                    currentModOut: [int]  index of module output
%
%--------------------------------------------------------------------------
%   Second level:
%     metricTs contains the following fields:
%
%                   values: [float array]  values of metric samples
%            uncertainties: [float array]  uncertainties in values of metric
%          gapIndicators: [logical array]  missing metric sample indicators
%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% OUTPUT:  A data structure metricReport with the following fields.
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%   Top level:
%
%                          value: [float]  value of metric at specified time
%                                          (typically last valid sample of metric)
%                    uncertainty: [float]  uncertainty in metric at specified time
%                          time: [double]  time tag for value and uncertainty (MJD)
%          adaptiveBoundsReport: [struct]  adaptive bounds tracking and trending report
%             fixedBoundsReport: [struct]  fixed bounds tracking and trending report
%                  alerts: [struct array]  alerts to operator
%
%--------------------------------------------------------------------------
%   Second level
%
%     The PDQ adaptive and fixed bounds report structs contain the following
%     fields:
%
%              outOfUpperBound: [logical]  metric out of upper bound at report time
%              outOfLowerBound: [logical]  metric out of lower bound at report time
%            outOfUpperBoundsCount: [int]  count of metric samples exceeding upper bound
%            outOfLowerBoundsCount: [int]  count of metric samples exceeding lower bound
%   outOfUpperBoundsTimes: [double array]  times that metric has exceeded upper bound (MJD)
%   outOfLowerBoundsTimes: [double array]  times that metric has exceeded lower bound (MJD)
%   outOfUpperBoundsValues: [float array]  out of upper bound metric values
%   outOfLowerBoundsValues: [float array]  out of lower bound metric values
%         upperBoundsCrossingXFactors:
%                           [float array]  normalized out of upper bound metric values
%         lowerBoundsCrossingXFactors:
%                           [float array]  normalized out of lower bound metric values
%  upperBoundCrossingPredicted: [logical]  true if trend in metric crosses upper bound
%                                          within horizon time
%  lowerBoundCrossingPredicted: [logical]  true if trend in metric crosses lower bound
%                                          within horizon time
%                  crossingTime: [double]  predicted bound crossing time (MJD)
%
%
%     The PDQ alerts is an array of structs with the following fields:
%
%                          time: [double]  time of alert to operator (MJD); same as
%                                          time of last valid metric sample
%                      severity: [string]  'error' or 'warning'
%                       message: [string]  error or warning message
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


% Set linear trend order. It does not make sense to do anything other than
% a linear trend fit. Extrapolating a higher order fit beyond the last
% available metric value is dangerous. Set the time period for initial
% estimates of mean and variance. This value (in units of days) should be
% on the order of the length of a contact so that the initial esimates are
% consistent from contact to contact. It should not be a configurable
% module parameter. Also set a multiplication factor for the initial
% adaptive bounds.
TREND_ORDER = 1;
INITIAL_ESTIMATE_TIME = 4.5;
INITIAL_BOUNDS_XFACTOR = 2.0;

% Set the start time for tracking and trending to the integer part of the
% first cadence time, and the base time for predicting bounds crossings to
% the final cadence time.
startTime = fix(cadenceTimes(1));
baseTime = cadenceTimes(end);

% Get the relevant module parameters from the input PDQ science object.
pdqConfiguration = pdqScienceObject.pdqConfiguration;

exponentialSmoothingFactor = pdqConfiguration.exponentialSmoothingFactor;
adaptiveBoundsXFactor  = pdqConfiguration.adaptiveBoundsXFactor;
minTrendFitSampleCount = pdqConfiguration.minTrendFitSampleCount;
trendFitTime = pdqConfiguration.trendFitTime;
horizonTime = pdqConfiguration.horizonTime;

debugLevel = pdqConfiguration.debugLevel;

% Get the time series values and uncertainties, and remove the gaps. Remove
% the gaps from the cadence times as well. Perform the tracking and
% trending based on single precision time series values and uncertainties
% to ensure continuity from contact to contact if castToSingle is true.
if castToSingle
    metricValues = double(single(metricTs.values));
    metricUncertainties = double(single(metricTs.uncertainties));
else
    metricValues = metricTs.values;
    metricUncertainties = metricTs.uncertainties;
end % if / else
metricGapIndicators = metricTs.gapIndicators;

metricValues = metricValues(~metricGapIndicators);
metricUncertainties = metricUncertainties(~metricGapIndicators);
cadenceTimes = cadenceTimes(~metricGapIndicators);

% Initialize the output structure.
boundsStruct = struct( ...
    'outOfUpperBound', false, ...
    'outOfLowerBound', false, ...
    'outOfUpperBoundsCount', 0, ...
    'outOfLowerBoundsCount', 0, ...
    'outOfUpperBoundsTimes', [], ...
    'outOfLowerBoundsTimes', [], ...
    'outOfUpperBoundsValues', [], ...
    'outOfLowerBoundsValues', [], ...
    'upperBoundsCrossingXFactors', [], ...
    'lowerBoundsCrossingXFactors', [], ...
    'upperBound', -1, ...
    'lowerBound', -1, ...
    'upperBoundCrossingPredicted', false, ...
    'lowerBoundCrossingPredicted', false, ...
    'crossingTime', -1 );

adaptiveBoundsReport = boundsStruct;
fixedBoundsReport = boundsStruct;

alerts = struct ( [] );
    
metricReport = struct( ...
    'time', -1, ...
    'value', -1, ...
    'uncertainty', -1, ...
    'adaptiveBoundsReport', adaptiveBoundsReport, ...
    'fixedBoundsReport', fixedBoundsReport, ...
    'alerts', alerts);

% If there are no valid metric values then return an empty report.
nValidMetricValues = length(metricValues);

if 0 == nValidMetricValues
    return;
end

% Use exponential smoothing to produce a running estimate of the mean and
% variance of the metric time series. Small (close to 0) factors produce
% smoother estimates than large (close to 1) factors, but are less
% responsive to real changes in the metric time series. The effective
% smoothing filter impulse response h(n) = exponentialSmoothingFactor^n.
% The initial conditions are set (see MATLAB help for 'filter') according
% to the mean and standard deviation of the samples within the trend fit
% time of the initial metric. This should allow the same bounds to be
% produced on all calls to PDQ in a given quarter (as long as the trend fit
% time is less than or equal to the duration of the metrics in the first
% invocation of PDQ in the quarter).
numeratorPolynomial = exponentialSmoothingFactor;
denominatorPolynomial = [1; -(1 - exponentialSmoothingFactor)];

isMetricForInitialConditions = ...
    (cadenceTimes - cadenceTimes(1)) < INITIAL_ESTIMATE_TIME;
ziMean = mean(metricValues(isMetricForInitialConditions)) - ...
    exponentialSmoothingFactor * metricValues(1);
metricMeanEstimates = filter(numeratorPolynomial, denominatorPolynomial, ...
    metricValues, ziMean);

residuals = metricValues - metricMeanEstimates;
if sum(isMetricForInitialConditions) > 1
    initialUncertainty = std(metricValues(isMetricForInitialConditions));
else
    initialUncertainty = metricUncertainties(1);
end
ziVariance = (INITIAL_BOUNDS_XFACTOR * initialUncertainty) ^ 2 - ...
    exponentialSmoothingFactor * residuals(1) ^ 2;
metricVarianceEstimates = filter(numeratorPolynomial, denominatorPolynomial, ...
    residuals .^ 2, ziVariance);
metricUncertaintyEstimates = sqrt(metricVarianceEstimates);

% Set the value and uncertainty in the metric report to the final values of
% the metric time series. Set the time stamp for the report to the cadence
% time of the last valid sample of the metric.
metricReport.time = cadenceTimes(end);
metricReport.value = metricValues(end);
metricReport.uncertainty = metricUncertainties(end);

% First delay the estimated uncertainties by one sample when setting the
% bounds for the metric values. So, the bounds that are applied to the metric
% value at time 'n' should be based on the smoothed mean at time 'n' and
% the smoothed variance at time 'n-1'. This reliably tests whether any
% sample exceeds the limits based on knowledge of prior samples. Then check
% the series against the adaptive bounds.
finalUncertaintyEstimate = metricUncertaintyEstimates(end);
metricUncertaintyEstimates(2 : end) = metricUncertaintyEstimates(1 : end - 1);
warning off all
normalizedMetricValues = ...
    (metricValues - metricMeanEstimates) ./ metricUncertaintyEstimates;
warning on all
normalizedMetricValues(~isfinite(normalizedMetricValues)) = 0;

adaptiveUpperBounds = metricMeanEstimates + ...
    adaptiveBoundsXFactor * metricUncertaintyEstimates;
adaptiveLowerBounds = metricMeanEstimates - ...
    adaptiveBoundsXFactor * metricUncertaintyEstimates;

adaptiveUpperBoundForPrediction = metricMeanEstimates(end) + ...
    adaptiveBoundsXFactor * finalUncertaintyEstimate;
adaptiveLowerBoundForPrediction = metricMeanEstimates(end) - ...
    adaptiveBoundsXFactor * finalUncertaintyEstimate;

isOutOfAdaptiveUpperBound = (metricValues > adaptiveUpperBounds);
isOutOfAdaptiveLowerBound = (metricValues < adaptiveLowerBounds);

adaptiveBoundsReport.upperBound = adaptiveUpperBounds(end);
adaptiveBoundsReport.lowerBound = adaptiveLowerBounds(end);
adaptiveBoundsReport.outOfUpperBound = isOutOfAdaptiveUpperBound(end);
adaptiveBoundsReport.outOfLowerBound = isOutOfAdaptiveLowerBound(end);
adaptiveBoundsReport.outOfUpperBoundsCount = sum(isOutOfAdaptiveUpperBound);
adaptiveBoundsReport.outOfLowerBoundsCount = sum(isOutOfAdaptiveLowerBound);
adaptiveBoundsReport.outOfUpperBoundsTimes = ...
    cadenceTimes(isOutOfAdaptiveUpperBound);
adaptiveBoundsReport.outOfLowerBoundsTimes = ...
    cadenceTimes(isOutOfAdaptiveLowerBound);
adaptiveBoundsReport.outOfUpperBoundsValues = ...
    metricValues(isOutOfAdaptiveUpperBound);
adaptiveBoundsReport.outOfLowerBoundsValues = ...
    metricValues(isOutOfAdaptiveLowerBound);
adaptiveBoundsReport.upperBoundsCrossingXFactors = ...
    normalizedMetricValues(isOutOfAdaptiveUpperBound);
adaptiveBoundsReport.lowerBoundsCrossingXFactors = ...
    normalizedMetricValues(isOutOfAdaptiveLowerBound);

% Check the series against the fixed bounds.
isOutOfFixedUpperBound = (metricValues > fixedUpperBound);
isOutOfFixedLowerBound = (metricValues < fixedLowerBound);

fixedBoundsReport.upperBound = fixedUpperBound;
fixedBoundsReport.lowerBound = fixedLowerBound;
fixedBoundsReport.outOfUpperBound = isOutOfFixedUpperBound(end);
fixedBoundsReport.outOfLowerBound = isOutOfFixedLowerBound(end);
fixedBoundsReport.outOfUpperBoundsCount = sum(isOutOfFixedUpperBound);
fixedBoundsReport.outOfLowerBoundsCount = sum(isOutOfFixedLowerBound);
fixedBoundsReport.outOfUpperBoundsTimes = ...
    cadenceTimes(isOutOfFixedUpperBound);
fixedBoundsReport.outOfLowerBoundsTimes = ...
    cadenceTimes(isOutOfFixedLowerBound);
fixedBoundsReport.outOfUpperBoundsValues = ...
    metricValues(isOutOfFixedUpperBound);
fixedBoundsReport.outOfLowerBoundsValues = ...
    metricValues(isOutOfFixedLowerBound);
fixedBoundsReport.upperBoundsCrossingXFactors = ...
    normalizedMetricValues(isOutOfFixedUpperBound);
fixedBoundsReport.lowerBoundsCrossingXFactors = ...
    normalizedMetricValues(isOutOfFixedLowerBound);

% Fit trend to the last values of the metric and extrapolate to determine
% if the bounds are to be exceeded within the horizon time. If not enough
% samples are available within the fit time then extend the fit.
trendFlag = false;
isEstimateToFit = (cadenceTimes(end) - cadenceTimes < trendFitTime);
if nValidMetricValues >= minTrendFitSampleCount
    isEstimateToFit(end - minTrendFitSampleCount + 1 : end) = true;
end

if sum(isEstimateToFit) >= minTrendFitSampleCount
    
    trendFlag = true;
%     meanEstimatesToFit = metricMeanEstimates(isEstimateToFit);
    metricValuesToFit = metricValues(isEstimateToFit);
    timeStamps = cadenceTimes(isEstimateToFit);
    
    designMatrix = x2fx(timeStamps - baseTime, (0 : TREND_ORDER)');
    
    warning off all;
%     robustFitPolynomial = ...
%         robustfit(designMatrix, meanEstimatesToFit, [], [], 'off');
    robustFitPolynomial = ...
        robustfit(designMatrix, metricValuesToFit, [], [], 'off');
    warning on all;
    
    % Check for predicted upper bounds crossings if the slope is positive,
    % otherwise check for predicted lower bounds crossings. Crossings must
    % occur within the given horizon time. Note that the base time is the
    % time of the most recent cadence, not (necessarily) the time of the
    % last valid sample of the metric. Do not predict a crossing if the
    % bound is currently exceeded.
    trendOffset = robustFitPolynomial(1);
    trendSlope = robustFitPolynomial(2);
    
    if trendSlope > 0
        
        relativeCrossingTime = ...
            (fixedUpperBound - trendOffset)/trendSlope;
        if relativeCrossingTime > 0 && relativeCrossingTime < horizonTime ...
                && ~isOutOfFixedUpperBound(end)
            fixedBoundsReport.upperBoundCrossingPredicted = true;
            fixedBoundsReport.crossingTime = ...
                baseTime + relativeCrossingTime;
        end
        
        relativeCrossingTime = ...
            (adaptiveUpperBoundForPrediction - trendOffset)/trendSlope;
        if relativeCrossingTime > 0 && relativeCrossingTime < horizonTime ...
                && ~isOutOfAdaptiveUpperBound(end)
            adaptiveBoundsReport.upperBoundCrossingPredicted = true;
            adaptiveBoundsReport.crossingTime = ...
                baseTime + relativeCrossingTime;
        end
        
    elseif trendSlope < 0
        
        relativeCrossingTime = ...
            (fixedLowerBound - trendOffset)/trendSlope;
        if relativeCrossingTime > 0 && relativeCrossingTime < horizonTime ...
                && ~isOutOfFixedLowerBound(end)
            fixedBoundsReport.lowerBoundCrossingPredicted = true;
            fixedBoundsReport.crossingTime = ...
                baseTime + relativeCrossingTime;
        end
        
        relativeCrossingTime = ...
            (adaptiveLowerBoundForPrediction - trendOffset)/trendSlope;
        if relativeCrossingTime > 0 && relativeCrossingTime < horizonTime ...
                && ~isOutOfAdaptiveLowerBound(end)
            adaptiveBoundsReport.lowerBoundCrossingPredicted = true;
            adaptiveBoundsReport.crossingTime = ...
                baseTime + relativeCrossingTime;
        end
        
    end % if/elseif
   
end % if

% Set the alerts based on severity hierarchy. The severity is 'error' if
% the last metric is out of fixed bounds or if the metric is predicted to
% be out of fixed bounds within the horizon time. The severity is 'warning'
% otherwise.
if fixedBoundsReport.outOfUpperBound
    [alerts] = add_alert(alerts, 'error', ...
        'Out of fixed upper bound in latest cadence');
elseif fixedBoundsReport.outOfLowerBound
    [alerts] = add_alert(alerts, 'error', ...
        'Out of fixed lower bound in latest cadence');
elseif fixedBoundsReport.upperBoundCrossingPredicted
    [alerts] = add_alert(alerts, 'error', ...
        'Fixed upper bound crossing predicted');
elseif fixedBoundsReport.lowerBoundCrossingPredicted
    [alerts] = add_alert(alerts, 'error', ...
        'Fixed lower bound crossing predicted');
end    

if adaptiveBoundsReport.outOfUpperBound
    [alerts] = add_alert(alerts, 'warning', ...
        'Out of adaptive upper bound in latest cadence');
elseif adaptiveBoundsReport.outOfLowerBound
    [alerts] = add_alert(alerts, 'warning', ...
        'Out of adaptive lower bound in latest cadence');
elseif adaptiveBoundsReport.upperBoundCrossingPredicted
    [alerts] = add_alert(alerts, 'warning', ...
        'Adaptive upper bound crossing predicted');
elseif adaptiveBoundsReport.lowerBoundCrossingPredicted
    [alerts] = add_alert(alerts, 'warning', ...
        'Adaptive lower bound crossing predicted');
end

% Generate alerts for collection of new samples of metric. Ensure that gaps
% are excluded from consideration.
[isValidNewSample, indxNewSampleTimes] = ismember(newSampleTimes, cadenceTimes);
indxNewSampleTimes = indxNewSampleTimes(isValidNewSample);

count = sum(isOutOfFixedUpperBound(indxNewSampleTimes));
if count > 0
    [alerts] = add_alert(alerts, 'error', ...
        [num2str(count) ' new metric value(s) out of fixed upper bound']);
end

count = sum(isOutOfFixedLowerBound(indxNewSampleTimes));
if count > 0
    [alerts] = add_alert(alerts, 'error', ...
        [num2str(count) ' new metric value(s) out of fixed lower bound']); 
end

count = sum(isOutOfAdaptiveUpperBound(indxNewSampleTimes));
if count > 0
    [alerts] = add_alert(alerts, 'warning', ...
        [num2str(count) ' new metric value(s) out of adaptive upper bounds']);
end

count = sum(isOutOfAdaptiveLowerBound(indxNewSampleTimes));
if count > 0
    [alerts] = add_alert(alerts, 'warning', ...
        [num2str(count) ' new metric value(s) out of adaptive lower bounds']);
end

% Determine where the current reference pixels are with respect to timestamps
if(isempty(pdqScienceObject.pdqTimestampSeries.excluded))
    oldOrExcludedTimeStamps = pdqScienceObject.pdqTimestampSeries.processed;
elseif(isempty(pdqScienceObject.pdqTimestampSeries.processed))
    oldOrExcludedTimeStamps = pdqScienceObject.pdqTimestampSeries.excluded ;
else
    oldOrExcludedTimeStamps = pdqScienceObject.pdqTimestampSeries.processed | pdqScienceObject.pdqTimestampSeries.excluded ;
end
latestReferencePixels = pdqScienceObject.pdqTimestampSeries.startTimes(~oldOrExcludedTimeStamps);

% Determine if there are any metrics gapped in latestReferencePixels
% Remember that cadenceTimes have already been ungapped (line 142)
gapsInLatestReferencePixels = setdiff(latestReferencePixels, cadenceTimes);

% Count gaps in latestReferencePixels and generate alert if any are found
countGapsInLatestReferencePixels =  numel(gapsInLatestReferencePixels);

% Issue alert if there are any gaps in the metrics of latestReferencePixels
if countGapsInLatestReferencePixels > 0     
    if exist('ccdModule', 'var') && exist('ccdOutput', 'var') && exist('metricName', 'var')
        [alerts] = add_alert(alerts, 'warning', ...
            [num2str(countGapsInLatestReferencePixels) ' gaps in latest reference pixels: ' metricName ', module ' num2str(ccdModule) ', output ' num2str(ccdOutput)]);
    else
        [alerts] = add_alert(alerts, 'warning', ...
            [num2str(countGapsInLatestReferencePixels) ' gaps in latest reference pixels']);
    end
end

% Generate plot and summary subplot. Try to place the plot legend out of the way,
% i.e. 'Best'.
% Plots are generated regardless of debugLevel.
    
    if exist('subplotMnp', 'var')
        h2 = figure(2);
    end
    
    hold off
    metric_h = plot(cadenceTimes - startTime, metricValues, '-ob');
    hold on
    smoothedMetric_h = plot(cadenceTimes - startTime, metricMeanEstimates, '-xg');
    if trendFlag
       trend_h =  plot(timeStamps - startTime, designMatrix * robustFitPolynomial, '-vm');
    end
    adaptiveBounds_h = plot(cadenceTimes - startTime, adaptiveUpperBounds, '-sr');
    plot(cadenceTimes - startTime, adaptiveLowerBounds, '-sr');
    plot(cadenceTimes(isOutOfAdaptiveUpperBound) - startTime, ...
        metricValues(isOutOfAdaptiveUpperBound), 'xr');
    plot(cadenceTimes(isOutOfAdaptiveLowerBound) - startTime, ...
        metricValues(isOutOfAdaptiveLowerBound), 'xr');
    t = [startTime; baseTime + horizonTime];
    if any(isOutOfFixedUpperBound) || fixedBoundsReport.upperBoundCrossingPredicted
        fixedBounds_h = plot(t - startTime, [fixedUpperBound; fixedUpperBound], '--k');
        plot(cadenceTimes(isOutOfFixedUpperBound) - startTime, ...
            metricValues(isOutOfFixedUpperBound), 'xk');
    end
    if any(isOutOfFixedLowerBound) || fixedBoundsReport.lowerBoundCrossingPredicted
        fixedBounds_h = plot(t - startTime, [fixedLowerBound; fixedLowerBound], '--k');
        plot(cadenceTimes(isOutOfFixedLowerBound) - startTime, ...
            metricValues(isOutOfFixedLowerBound), 'xk');
    end
    t = [0; horizonTime];
    if trendFlag
        plot(baseTime + t - startTime, x2fx(t, (0 : TREND_ORDER)') * robustFitPolynomial, '-m');
    end
    plot(baseTime + t - startTime, [adaptiveUpperBoundForPrediction; adaptiveUpperBoundForPrediction], '--r');
    plot(baseTime + t - startTime, [adaptiveLowerBoundForPrediction; adaptiveLowerBoundForPrediction], '--r');
    if exist('ccdModule', 'var') && exist('ccdOutput', 'var') && exist('currentModOut', 'var')
        title(['[PDQ] Tracking and Trending: ' metricName ' -- Module ' num2str(ccdModule) ' / Output ' num2str(ccdOutput)]);
        fileNameStr = ['tracking_trending_', metricName, '_module_'  num2str(ccdModule) '_output_', num2str(ccdOutput)  '_modout_' num2str(currentModOut)];
    else
        title(['[PDQ] Tracking and Trending: ' metricName]);
        fileNameStr = ['tracking_trending_', metricName, '_across_the_focal_plane'];
    end
    xlabel(['Elapsed Days from ', mjd_to_utc(startTime, 0)]);
    ylabel([metricName, ' (', metricUnits, ')']);
    
    % Add legends
    if ~trendFlag
        
        if ~exist('fixedBounds_h', 'var')
            legend([metric_h, smoothedMetric_h, adaptiveBounds_h], 'Metric', 'Smoothed Metric', 'Adaptive Bounds', 'Location', 'Best');
        else
            legend([metric_h, smoothedMetric_h, adaptiveBounds_h,  fixedBounds_h], 'Metric', 'Smoothed Metric', 'Adaptive Bounds', 'Fixed Bound', 'Location', 'Best');
        end
        
    else
        if ~exist('fixedBounds_h', 'var')
            legend([metric_h, smoothedMetric_h, trend_h, adaptiveBounds_h], 'Metric', 'Smoothed Metric', 'Trend Fit', 'Adaptive Bounds', 'Location', 'Best');
        else
            legend([metric_h, smoothedMetric_h, trend_h, adaptiveBounds_h, fixedBounds_h], 'Metric', 'Smoothed Metric', 'Trend Fit', 'Adaptive Bounds', 'Fixed Bound', 'Location', 'Best');
        end
    end
    
    isLandscapeOrientation = true;
    includeTimeFlag = false;
    printJpgFlag = false;
    fileNameStr = lower(strrep(fileNameStr, ' ', '_'));
    plot_to_file(fileNameStr, isLandscapeOrientation, includeTimeFlag, printJpgFlag);
    
    if exist('subplotMnp', 'var')
        
        close(h2);
        figure(1)
        subplot(subplotMnp(1), subplotMnp(2), subplotMnp(3));
        
        hold off
        plot(cadenceTimes - startTime, metricValues, '.-b');
        hold on
        plot(cadenceTimes - startTime, metricMeanEstimates, '.-g');
        if trendFlag
            plot(timeStamps - startTime, designMatrix * robustFitPolynomial, '.-m');
        end
        plot(cadenceTimes - startTime, adaptiveUpperBounds, '.-r');
        plot(cadenceTimes - startTime, adaptiveLowerBounds, '.-r');
        plot(cadenceTimes(isOutOfAdaptiveUpperBound) - startTime, ...
            metricValues(isOutOfAdaptiveUpperBound), 'xr');
        plot(cadenceTimes(isOutOfAdaptiveLowerBound) - startTime, ...
            metricValues(isOutOfAdaptiveLowerBound), 'xr');
        t = [startTime; baseTime + horizonTime];
        if any(isOutOfFixedUpperBound) || fixedBoundsReport.upperBoundCrossingPredicted
            plot(t - startTime, [fixedUpperBound; fixedUpperBound], '--k');
            plot(cadenceTimes(isOutOfFixedUpperBound) - startTime, ...
                metricValues(isOutOfFixedUpperBound), 'xk');
        end
        if any(isOutOfFixedLowerBound) || fixedBoundsReport.lowerBoundCrossingPredicted
            plot(t - startTime, [fixedLowerBound; fixedLowerBound], '--k');
            plot(cadenceTimes(isOutOfFixedLowerBound) - startTime, ...
                metricValues(isOutOfFixedLowerBound), 'xk');
        end
        t = [0; horizonTime];
        if trendFlag
            plot(baseTime + t - startTime, x2fx(t, (0 : TREND_ORDER)') * robustFitPolynomial, '-m');
        end
        plot(baseTime + t - startTime, [adaptiveUpperBoundForPrediction; adaptiveUpperBoundForPrediction], '--r');
        plot(baseTime + t - startTime, [adaptiveLowerBoundForPrediction; adaptiveLowerBoundForPrediction], '--r');
        title([metricName, ' (', metricUnits, ')']);
        
    end % if exist
    


% Copy the fixed and adaptive bounds reports and the alerts to the output
% report.
metricReport.fixedBoundsReport = fixedBoundsReport;
metricReport.adaptiveBoundsReport = adaptiveBoundsReport;
metricReport.alerts = alerts;

% Return.
return
