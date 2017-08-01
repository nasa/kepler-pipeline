function [metricReport, metricTempData] = ppa_create_report(parameters, metricTs, smoothingFactor, fixedLowerBound, fixedUpperBound, adaptiveBoundsXFactor, ...
    metricName, timestamps, cadenceGapIndicators, ccdModule, ccdOutput,scale,titleString)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [metricReport, metricTempData] = ppa_create_report(parameters, metricTs, smoothingFactor, fixedLowerBound, fixedUpperBound, ...
%   metricName, timestamps, cadenceGapIndicators, ccdModule, ccdOutput,scale,titleString)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Create PPA metric report for the given metric time series. Check the
% series against the given fixed bounds. Exponentially smooth the series to
% obtain running estimates of the mean and variance. Set adaptive upper
% bounds based on the running estimate of the mean and variance, and the
% adaptive X-factor that is supplied through the PPA configuration
% parameters. Check the series against the adaptive bounds as well. Fit a
% trend to the latest estimates of the mean, and predict if it will cross a
% bound (adaptive or fixed) within a horizon time obtained from the
% configuration parameters. Report separately on fixed and adaptive bounds
% crossings and predictions. Set alerts to the operator based on severity
% of a bounds crossing event or prediction.
%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% INPUT:  The following arguments are specified for this function.
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
%                    parameters: [struct]  configuration parameters for track and trend
%                      metricTs: [struct]  metric time series for single module output
%                smoothingFactor: [float]  smoothing  factor for given metric
%                fixedLowerBound: [float]  fixed lower bound for given metric
%                fixedUpperBound: [float]  fixed upper bound for given metric
%                    metricName: [string]  name of PPA metric
%              timestamps: [double array]  timestamps of metric time series (MJD)
%   cadenceGapIndicators: [logical array]  gap indicators of timestamps
%                        ccdModule: [int]  ccd module number
%                        ccdOutput: [int]  ccd output number
%                         scale [logical]  sets scaling of plot
%                      titleString [char]  optional title for plot
%
%--------------------------------------------------------------------------
%   Second level:
%     metricTs contains the following fields:
%
%                   values: [float array]  values of metric samples
%          gapIndicators: [logical array]  missing metric sample indicators
%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% OUTPUT:  A data structure metricReport with the following fields.
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%   Top level:
%
%                          time: [double]  time tag for value (MJD)
%                          value: [float]  value of metric at specified time (typically last valid sample of metric)
%                      meanValue: [float]  estimated mean value of metric at specified time (typically last valid sample of metric)
%                    uncertainty: [float]  estimated uncertainty of metric at specified time (typically last valid sample of metric)
%          adpativeBoundsXFactor: [float]  X-factor to determine adaptive bounds
%                  trackAlertLevel: [int]  track alert level (-1: no data, 0: within adaptive and fixed bounds, 
%                                                              1: beyond adaptive bounds, 2: beyond fixed bounds)
%                  trendAlertLevel: [int]  trend alert level (-1: no data, 0: within adaptive and fixed bounds, 
%                                                              1: beyond adaptive bounds, 2: beyond fixed bounds)
%          adaptiveBoundsReport: [struct]  adaptive bounds tracking and trending report
%             fixedBoundsReport: [struct]  fixed bounds tracking and trending report
%                   trendReport: [struct]  trending report
%                  alerts: [struct array]  alerts to operator
%
%--------------------------------------------------------------------------
%   Second level
%
%     The PPA adaptive and fixed bounds report structs contain the following fields:
%
%                     upperBound: [float]  upper bound
%                     lowerBound: [float]  lower bound
%              outOfUpperBound: [logical]  metric out of upper bound at report time 
%              outOfLowerBound: [logical]  metric out of lower bound at report time
%            outOfUpperBoundsCount: [int]  count of metric samples exceeding upper bound
%            outOfLowerBoundsCount: [int]  count of metric samples exceeding lower bound
%   outOfUpperBoundsTimes: [double array]  times that metric has exceeded upper bound (MJD)
%   outOfLowerBoundsTimes: [double array]  times that metric has exceeded lower bound (MJD)
%   outOfUpperBoundsValues: [float array]  metric values exceeding upper bound
%   outOfLowerBoundsValues: [float array]  metric values exceeding lower bound
%    upperBoundsCrossingXFactors: [float]  X factors of metric values exceeding upper bound
%    lowerBoundsCrossingXFactors: [float]  X factors of metric values exceeding lower bound
%  upperBoundCrossingPredicted: [logical]  true if trend in metric crosses upper bound within horizon time
%  lowerBoundCrossingPredicted: [logical]  true if trend in metric crosses lower bound within horizon time
%                  crossingTime: [double]  predicted bound crossing time (MJD)
%
%     The PPA trending report struct contains the following fields:
%
%                   trendValid: [logical]  flag indicating trend report is valid/invalid when true/false
%                   trendFitTime: [float]  time interval in which data are used for trending analysis
%                    trendOffset: [float]  offset of linear trending 
%                     trendSlope: [float]  slope of linear trending
%                    horizonTime: [flaot]  time interval in which crossing adaptive and fixed bounds is predicted
%
%     The PPA alerts is an array of structs with the following fields:
%
%                          time: [double]  time of alert to operator (MJD); same as time of last valid metric sample
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

if (~exist('scale','var'))
    scale = false ;
end
if (~exist('titleString','var'))
    titleString = char([]) ;
end

% Initialize the output structure.
boundsStruct = struct( ...
    'outOfUpperBound',              false, ...
    'outOfLowerBound',              false, ...
    'outOfUpperBoundsCount',        0, ...
    'outOfLowerBoundsCount',        0, ...
    'outOfUpperBoundsTimes',        [], ...
    'outOfLowerBoundsTimes',        [], ...
    'outOfUpperBoundsValues',       [], ...
    'outOfLowerBoundsValues',       [], ...
    'upperBoundsCrossingXFactors',  [], ...
    'lowerBoundsCrossingXFactors',  [], ...
    'upperBound',                   -1, ...
    'lowerBound',                   -1, ...
    'upperBoundCrossingPredicted',  false, ...
    'lowerBoundCrossingPredicted',  false, ...
    'crossingTime',                 -1 );

trendStruct = struct( ...
    'trendValid',                   false, ...
    'trendFitTime',                 -1, ...
    'trendOffset',                  -1, ...
    'trendSlope',                   -1, ...
    'horizonTime',                  -1 );

adaptiveBoundsReport = boundsStruct;
fixedBoundsReport    = boundsStruct;
trendReport          = trendStruct;
alerts               = struct ( [] );
    
metricReport = struct( ...
    'time',                         -1, ...
    'value',                        -1, ...
    'meanValue',                    -1, ...
    'uncertainty',                  -1, ...
    'adaptiveBoundsXFactor',        -1, ...
    'trackAlertLevel',              -1, ...
    'trendAlertLevel',              -1, ...
    'adaptiveBoundsReport',         adaptiveBoundsReport, ...
    'fixedBoundsReport',            fixedBoundsReport, ...
    'trendReport',                  trendReport, ...
    'alerts',                       alerts );

metricTempData = struct( ...
    'meanEstimates',                    [], ...
    'uncertaintyEstimates',             [], ...
    'estimatesGapIndicators',           [], ...
    'adaptiveBoundsXFactor',            -1 );

if isempty(metricTs.values) 
%   warning('PPA:createReport:noMetricSamples', ['No samples of ' metricName ]);
    disp(['PPA:createReport: No samples of ' metricName]);
    return;
end

if ( length(metricTs.values)~=length(timestamps) )
%   warning('PPA:createReport:dimensonsDoNotAgree', ['Dimensions of ' metricName ' sample array and cadence timestamp array do not agree']);
    disp(['PPA:createReport: Dimensions of ' metricName ' sample array and cadence timestamp array do not agree']);
    return;
end

metricTs.gapIndicators = metricTs.gapIndicators(:) | cadenceGapIndicators(:);

% Set linear trend order. It does not make sense to do anything other than
% a linear trend fit. Otherwise we may end up predicting both upper and
% lower bound crossings for the same metric time series!
TREND_ORDER = 1;

% Set the base time for predicting bounds crossings to the final cadence time.
startTime = timestamps(1);
baseTime  = timestamps(end);
nCadences = length(timestamps);

% Get the relevant module parameters from the input 'parameters' structure.
%adaptiveBoundsXFactor       = parameters.adaptiveBoundsXFactor;
minTrendFitSampleCount      = parameters.minTrendFitSampleCount;
trendFitTime                = parameters.trendFitTime;
initialAverageSampleCount   = parameters.initialAverageSampleCount;
horizonTime                 = parameters.horizonTime;
alertTime                   = parameters.alertTime;
debugLevel                  = parameters.debugLevel;


% Get the time series values and uncertainties, and remove the gaps. Remove
% the gaps from the cadence times as well.
metricValuesRaw         = metricTs.values;
metricGapIndicators     = metricTs.gapIndicators;

metricValuesLevel1      = metricValuesRaw(~metricGapIndicators);
cadenceTimesLevel1      = timestamps(~metricGapIndicators);

% If there are no valid metric values then return an empty report.
nValidMetricValuesLevel1 = length(metricValuesLevel1);
if 0 == nValidMetricValuesLevel1
%   warning('PPA:createReport:noValidMetricSamples', ['No valid samples of ' metricName ' after level 1 clean up']);
    disp(['PPA:createReport: No valid samples of ' metricName ' after level 1 clean up']);
    return;
end

% Determine the start and time (in MJD) of trend fit interval. 
% Alerts are generated if the metric samples are beyond the
% fixed/adaptive upper/lower bounds within the trend fit interval.
endTimeOfTrendFit       = cadenceTimesLevel1(end);
startTimeOfTrendFit     = endTimeOfTrendFit - trendFitTime;

startTimeOfAlert        = endTimeOfTrendFit - alertTime;

% Check the full series against the fixed bounds
isOutOfFixedUpperBound                      = (metricValuesLevel1 > fixedUpperBound);
isOutOfFixedLowerBound                      = (metricValuesLevel1 < fixedLowerBound);

% Check the series in the trend fit interval against the fixed bounds
indexTemp                                   = ( cadenceTimesLevel1 > startTimeOfAlert );
isOutOfFixedUpperBoundInAlertInterval       = (metricValuesLevel1( indexTemp ) > fixedUpperBound);
isOutOfFixedLowerBoundInAlertInterval       = (metricValuesLevel1( indexTemp ) < fixedLowerBound);

% Generate fixed bounds report
fixedBoundsReport.upperBound                = fixedUpperBound;
fixedBoundsReport.lowerBound                = fixedLowerBound;
fixedBoundsReport.outOfUpperBound           = isOutOfFixedUpperBound(end);
fixedBoundsReport.outOfLowerBound           = isOutOfFixedLowerBound(end);
fixedBoundsReport.outOfUpperBoundsCount     = sum(isOutOfFixedUpperBound);
fixedBoundsReport.outOfLowerBoundsCount     = sum(isOutOfFixedLowerBound);
fixedBoundsReport.outOfUpperBoundsTimes     = cadenceTimesLevel1(isOutOfFixedUpperBound);
fixedBoundsReport.outOfLowerBoundsTimes     = cadenceTimesLevel1(isOutOfFixedLowerBound);
fixedBoundsReport.outOfUpperBoundsValues    = metricValuesLevel1(isOutOfFixedUpperBound);
fixedBoundsReport.outOfLowerBoundsValues    = metricValuesLevel1(isOutOfFixedLowerBound);

% Clean the data points which are beyond the fixed bounds
% newGapIndicators                        = false(size(metricGapIndicators));
% newGapIndicators(~metricGapIndicators)  = isOutOfFixedUpperBound | isOutOfFixedLowerBound;
% metricGapIndicators                     = metricGapIndicators | newGapIndicators;

% Clean the outliers with robustfit -- 07/28/2009
if ( nValidMetricValuesLevel1 > initialAverageSampleCount )
    
    % Robustfit the metric time series with a linear model
    normalizedTime = ( cadenceTimesLevel1(:) - cadenceTimesLevel1(1) )/( cadenceTimesLevel1(end) - cadenceTimesLevel1(1) );     
    [ignored, stats] = robustfit([ones(size(normalizedTime)) normalizedTime], metricValuesLevel1(:), [], [], 'off');

    % Set the new gap indicators to be true when the robust fit weight is zero (less than eps)
    newGapIndicators                        = false(size(metricGapIndicators));
    newGapIndicators(~metricGapIndicators)  = stats.w <= eps;
    
    nNewGaps = sum(newGapIndicators);
    if ( nNewGaps>0 )
        
        % Get the start and end indices of consecutive new gaps
        diffNewGapIndicators = diff(newGapIndicators);
        indexGapIntervalStart = find(diffNewGapIndicators== 1) + 1;
        indexGapIntervalEnd   = find(diffNewGapIndicators==-1);
        if newGapIndicators(1)
            indexGapIntervalStart = [ 1; indexGapIntervalStart(:) ];
        end
        if newGapIndicators(end)
            indexGapIntervalEnd   = [ indexGapIntervalEnd(:); nCadences ];
        end

        % Set the new gap indicators to false if the number of consecutive new gaps is larger than initialAverageSampleCount
        if length(indexGapIntervalStart) == length(indexGapIntervalEnd)
            for iGapInterval = 1:length(indexGapIntervalStart)
                if ( (indexGapIntervalEnd(iGapInterval) - indexGapIntervalStart(iGapInterval) ) > initialAverageSampleCount )
                    newGapIndicators( indexGapIntervalStart(iGapInterval):indexGapIntervalEnd(iGapInterval) ) = false;
                end
            end
        end
        
    end

    % The new gap indicators are combined with existing gap indicators
    metricGapIndicators = metricGapIndicators | newGapIndicators;
    
end

cadenceTimesLevel2                      = timestamps(~metricGapIndicators);
metricValuesLevel2                      = metricValuesRaw(~metricGapIndicators);

% If there are no valid metric values then return with fixed bound report.
nValidMetricValuesLevel2 = length(metricValuesLevel2);
if 0 == nValidMetricValuesLevel2
%   warning('PPA:createReport:noValidMetricSamples', ['No valid samples of ' metricName ' after level 2 clean up']);
    disp(['PPA:createReport: No valid samples of ' metricName ' after level 2 clean up']);
    return;
end

% Use exponential smoothing to produce a running estimate of the mean and
% variance of the metric time series. Small (close to 0) factors produce
% smoother estimates than large (close to 1) factors, but are less
% responsive to real changes in the metric time series. The effective
% smoothing filter impulse response h(n) = exponentialSmoothingFactor^n.
% The initial conditions are set (see MATLAB help for 'filter') according
% to the mean and standard deviation of the samples within the initial
% average time defined in the PPA configuration. 

numeratorPolynomial          = smoothingFactor;
denominatorPolynomial        = [1; -(1 - smoothingFactor)];

if ( length(metricValuesLevel2) >= initialAverageSampleCount )
    endIndexForInitialAverage = initialAverageSampleCount;
else
    endIndexForInitialAverage = length(metricValuesLevel2);
end

ziMean                       = (1 - smoothingFactor) * mean( metricValuesLevel2(1:endIndexForInitialAverage) );
metricMeanEstimates          = filter(numeratorPolynomial, denominatorPolynomial, metricValuesLevel2,   ziMean);

residuals                    = metricValuesLevel2 - metricMeanEstimates;
metricVariance               = residuals .^ 2;

ziVariance                   = (1 - smoothingFactor) * mean( metricVariance(1:endIndexForInitialAverage) );
metricVarianceEstimates      = filter(numeratorPolynomial, denominatorPolynomial, metricVariance, ziVariance);
metricUncertaintyEstimates   = sqrt(metricVarianceEstimates);

% First delay the estimated uncertainties by one sample when setting the
% bounds for the metric values. So, the bounds that are applied to the metric
% value at time 'n' should be based on the smoothed mean at time 'n' and
% the smoothed variance at time 'n-1'. This reliably tests whether any
% sample exceeds the limits based on knowledge of prior samples. Then check
% the series against the adaptive bounds.

finalUncertaintyEstimate = metricUncertaintyEstimates(end);
metricUncertaintyEstimates(2 : end) = metricUncertaintyEstimates(1 : end-1);

normalizedMetricValuesLevel2 = zeros(size(metricValuesLevel2));
indexTemp  = (metricUncertaintyEstimates > 0);
normalizedMetricValuesLevel2(indexTemp) = ...
    (metricValuesLevel2(indexTemp) - metricMeanEstimates(indexTemp)) ./ metricUncertaintyEstimates(indexTemp);

adaptiveUpperBounds             = metricMeanEstimates      + adaptiveBoundsXFactor * metricUncertaintyEstimates;
adaptiveLowerBounds             = metricMeanEstimates      - adaptiveBoundsXFactor * metricUncertaintyEstimates;

adaptiveUpperBoundForPrediction = metricMeanEstimates(end) + adaptiveBoundsXFactor * finalUncertaintyEstimate;
adaptiveLowerBoundForPrediction = metricMeanEstimates(end) - adaptiveBoundsXFactor * finalUncertaintyEstimate;

meanEstimates                                = -1*ones(nCadences, 1);
uncertaintyEstimates                         = -1*ones(nCadences, 1);
estimatesGapIndicators                       = true(nCadences, 1);
meanEstimates(~metricGapIndicators)          = metricMeanEstimates;
uncertaintyEstimates(~metricGapIndicators)   = metricUncertaintyEstimates;
estimatesGapIndicators(~metricGapIndicators) = false;

% Set the value in the metric report to the final values of the metric time series.
% Set the time stamp for the report to the cadence time of the last valid sample of the metric.

metricReport.time                            = cadenceTimesLevel2(end);
metricReport.value                           = metricValuesLevel2(end);
metricReport.meanValue                       = metricMeanEstimates(end);
metricReport.uncertainty                     = metricUncertaintyEstimates(end);
metricReport.adaptiveBoundsXFactor           = adaptiveBoundsXFactor;

% Save the estimate results in metricTempData structure
metricTempData.meanEstimates                 = meanEstimates;
metricTempData.uncertaintyEstimates          = uncertaintyEstimates;
metricTempData.estimatesGapIndicators        = estimatesGapIndicators;
metricTempData.adaptiveBoundsXFactor         = adaptiveBoundsXFactor;

% Check the full series against the adaptive bounds
isOutOfAdaptiveUpperBound                   = (metricValuesLevel2 > adaptiveUpperBounds);
isOutOfAdaptiveLowerBound                   = (metricValuesLevel2 < adaptiveLowerBounds);

% Check the series in the trend fit time interval against the adaptive bounds
indexTemp                                   = ( cadenceTimesLevel2 > startTimeOfAlert );
isOutOfAdaptiveUpperBoundInAlertInterval    = ( metricValuesLevel2( indexTemp ) > adaptiveUpperBounds( indexTemp ) );
isOutOfAdaptiveLowerBoundInAlertInterval    = ( metricValuesLevel2( indexTemp ) < adaptiveLowerBounds( indexTemp ) );

% Generate adaptive bounds report
adaptiveBoundsReport.upperBound                  = adaptiveUpperBounds(end);
adaptiveBoundsReport.lowerBound                  = adaptiveLowerBounds(end);
adaptiveBoundsReport.outOfUpperBound             = isOutOfAdaptiveUpperBound(end);
adaptiveBoundsReport.outOfLowerBound             = isOutOfAdaptiveLowerBound(end);
adaptiveBoundsReport.outOfUpperBoundsCount       = sum(isOutOfAdaptiveUpperBound);
adaptiveBoundsReport.outOfLowerBoundsCount       = sum(isOutOfAdaptiveLowerBound);
adaptiveBoundsReport.outOfUpperBoundsTimes       = cadenceTimesLevel2(isOutOfAdaptiveUpperBound);
adaptiveBoundsReport.outOfLowerBoundsTimes       = cadenceTimesLevel2(isOutOfAdaptiveLowerBound);
adaptiveBoundsReport.outOfUpperBoundsValues      = metricValuesLevel2(isOutOfAdaptiveUpperBound);
adaptiveBoundsReport.outOfLowerBoundsValues      = metricValuesLevel2(isOutOfAdaptiveLowerBound);
adaptiveBoundsReport.upperBoundsCrossingXFactors = normalizedMetricValuesLevel2(isOutOfAdaptiveUpperBound);
adaptiveBoundsReport.lowerBoundsCrossingXFactors = normalizedMetricValuesLevel2(isOutOfAdaptiveLowerBound);

% Generate upper and lower bounds crossing X-factors of fixed bounds report
fixedBoundsReport.upperBoundsCrossingXFactors =zeros(size(fixedBoundsReport.outOfUpperBoundsTimes));
for iCount = 1:length(fixedBoundsReport.outOfUpperBoundsTimes)
    [ignoredValue, indexTemp] = min( abs( cadenceTimesLevel2 - fixedBoundsReport.outOfUpperBoundsTimes(iCount) ) );
    if metricUncertaintyEstimates(indexTemp)>0
        fixedBoundsReport.upperBoundsCrossingXFactors(iCount) = ...
            ( fixedBoundsReport.outOfUpperBoundsValues(iCount) - metricValuesLevel2(indexTemp) )/metricUncertaintyEstimates(indexTemp);
    end
end
fixedBoundsReport.lowerBoundsCrossingXFactors =zeros(size(fixedBoundsReport.outOfLowerBoundsTimes));
for iCount = 1:length(fixedBoundsReport.outOfLowerBoundsTimes)
    [ignoredValue, indexTemp] = min( abs( cadenceTimesLevel2 - fixedBoundsReport.outOfLowerBoundsTimes(iCount) ) );
    if metricUncertaintyEstimates(indexTemp)>0
        fixedBoundsReport.lowerBoundsCrossingXFactors(iCount) = ...
            ( fixedBoundsReport.outOfLowerBoundsValues(iCount) - metricValuesLevel2(indexTemp) )/metricUncertaintyEstimates(indexTemp);
    end
end

% Fit trend to the last estimates of the mean and extrapolate to determine
% if the bounds are to be exceeded within the horizon time. If not enough
% samples are available within the fit time then extend the fit.

trendFlag = false;
isEstimateToFit = ( cadenceTimesLevel2 > startTimeOfTrendFit );
if nValidMetricValuesLevel2 >= minTrendFitSampleCount
    isEstimateToFit(end - minTrendFitSampleCount + 1 : end) = true;
end

if sum(isEstimateToFit) >= minTrendFitSampleCount
    
    trendFlag = true;
%   meanEstimatesToFit = metricMeanEstimates(isEstimateToFit);
    meanEstimatesToFit = metricValuesLevel2(isEstimateToFit);
    timeStamps = cadenceTimesLevel2(isEstimateToFit);
    
    designMatrix = x2fx(timeStamps - baseTime, (0 : TREND_ORDER)');
    robustFitPolynomial = robustfit(designMatrix, meanEstimatesToFit, [], [], 'off');
    
    % Check for predicted upper bounds crossings if the slope is positive,
    % otherwise check for predicted lower bounds crossings. Crossings must
    % occur within the given horizon time. Note that the base time is the
    % time of the most recent cadence, not (necessarily) the time of the
    % last valid sample of the metric. Do not predict a crossing if the
    % bound is currently exceeded.

    trendOffset = robustFitPolynomial(1);
    trendSlope = robustFitPolynomial(2);

    if trendSlope > 0
        
        relativeCrossingTime = (fixedUpperBound          - trendOffset)/trendSlope;
        if relativeCrossingTime > 0 && relativeCrossingTime < horizonTime
            fixedBoundsReport.upperBoundCrossingPredicted    = true;
            fixedBoundsReport.crossingTime                   = baseTime + relativeCrossingTime;
        end
        
        relativeCrossingTime = (adaptiveUpperBoundForPrediction - trendOffset)/trendSlope;
        if relativeCrossingTime > 0 && relativeCrossingTime < horizonTime
            adaptiveBoundsReport.upperBoundCrossingPredicted = true;
            adaptiveBoundsReport.crossingTime                = baseTime + relativeCrossingTime;
        end
        
    elseif trendSlope < 0
        
        relativeCrossingTime = (fixedLowerBound          - trendOffset)/trendSlope;
        if relativeCrossingTime > 0 && relativeCrossingTime < horizonTime
            fixedBoundsReport.lowerBoundCrossingPredicted    = true;
            fixedBoundsReport.crossingTime                   = baseTime + relativeCrossingTime;
        end
        
        relativeCrossingTime = (adaptiveLowerBoundForPrediction - trendOffset)/trendSlope;
        if relativeCrossingTime > 0 && relativeCrossingTime < horizonTime
            adaptiveBoundsReport.lowerBoundCrossingPredicted = true;
            adaptiveBoundsReport.crossingTime                = baseTime + relativeCrossingTime;
        end
        
    end % if/elseif
   
end % if

% Generate trending report
trendReport.trendValid      = trendFlag;
trendReport.trendFitTime    = trendFitTime;
trendReport.horizonTime     = horizonTime;
if trendFlag
    trendReport.trendOffset = trendOffset;
    trendReport.trendSlope  = trendSlope;
end

% Set the alerts based on severity hierarchy. The severity is 'error' if
% the last metric is out of fixed bounds or if the metric is predicted to
% be out of fixed bounds within the horizon time. The severity is 'warning'
% otherwise.

trackAlertLevel = 0;
trendAlertLevel = 0;

if sum(isOutOfAdaptiveUpperBoundInAlertInterval)>0
    [alerts] = add_alert(alerts, 'warning',   ...
        [num2str( sum(isOutOfAdaptiveUpperBoundInAlertInterval) ) ' metric sample(s) out of adaptive upper bound in final ' num2str(alertTime) ' days']);
    trackAlertLevel = 1;
end
if sum(isOutOfAdaptiveLowerBoundInAlertInterval)>0
    [alerts] = add_alert(alerts, 'warning',   ...
        [num2str( sum(isOutOfAdaptiveLowerBoundInAlertInterval) ) ' metric sample(s) out of adaptive lower bound in final ' num2str(alertTime) ' days']);
    trackAlertLevel = 1;
end

if sum(isOutOfAdaptiveUpperBound)>0
    [alerts] = add_alert(alerts, 'warning',   ...
        [num2str( sum(isOutOfAdaptiveUpperBound) ) ' metric sample(s) out of adaptive upper bound in entire time series']);
end
if sum(isOutOfAdaptiveLowerBound)>0
    [alerts] = add_alert(alerts, 'warning',   ...
        [num2str( sum(isOutOfAdaptiveLowerBound) ) ' metric sample(s) out of adaptive lower bound in entire time series']);
end

if adaptiveBoundsReport.upperBoundCrossingPredicted
    [alerts] = add_alert(alerts, 'warning', 'Adaptive upper bound crossing predicted');
    trendAlertLevel = 1;
end
if adaptiveBoundsReport.lowerBoundCrossingPredicted
    [alerts] = add_alert(alerts, 'warning', 'Adaptive lower bound crossing predicted');
    trendAlertLevel = 1;
end

if sum(isOutOfFixedUpperBoundInAlertInterval)>0
    [alerts] = add_alert(alerts, 'error',   ...
        [num2str( sum(isOutOfFixedUpperBoundInAlertInterval) ) ' metric sample(s) out of fixed upper bound in final ' num2str(alertTime) ' days']);
    trackAlertLevel = 2;
end
if sum(isOutOfFixedLowerBoundInAlertInterval)>0
    [alerts] = add_alert(alerts, 'error',   ...
        [num2str( sum(isOutOfFixedLowerBoundInAlertInterval) ) ' metric sample(s) out of fixed lower bound in final ' num2str(alertTime) ' days']);
    trackAlertLevel = 2;
end

if sum(isOutOfFixedUpperBound)>0
    [alerts] = add_alert(alerts, 'warning',   ...
        [num2str( sum(isOutOfFixedUpperBound) ) ' metric sample(s) out of fixed upper bound in entire time series']);
end
if sum(isOutOfFixedLowerBound)>0
    [alerts] = add_alert(alerts, 'warning',   ...
        [num2str( sum(isOutOfFixedLowerBound) ) ' metric sample(s) out of fixed lower bound in entire time series']);
end

if fixedBoundsReport.upperBoundCrossingPredicted
    [alerts] = add_alert(alerts, 'error',   'Fixed upper bound crossing predicted');
    trendAlertLevel = 2;
end
if fixedBoundsReport.lowerBoundCrossingPredicted
    [alerts] = add_alert(alerts, 'error',   'Fixed lower bound crossing predicted');
    trendAlertLevel = 2;
end    

scaleExponent = 0 ;
if (scale)
    mv1 = metricValuesLevel2(isOutOfAdaptiveUpperBound) ;
    mv2 = metricValuesLevel2(isOutOfAdaptiveLowerBound) ;
    mv3 = metricValuesLevel1(isOutOfFixedUpperBound) ;
    mv4 = metricValuesLevel1(isOutOfFixedLowerBound) ;
    allValues = [metricValuesLevel2(:) ; metricMeanEstimates(:) ; ...
        mv1(:) ; mv2(:) ; mv3(:) ; mv4(:)] ;
    biggestValue = max(abs(allValues)) ;
    scaleExponent = floor(log10(biggestValue)) ;
    if (isempty(scaleExponent))
        scaleExponent = 0 ;
    elseif (scaleExponent <=1 && scaleExponent >= -1)
        scaleExponent = 0 ;
    end
end
scaleFactor = 10^scaleExponent ;

% Generate plot if debug level is non-zero. Try to place the legend out of the way.
if  ( ( debugLevel > 0 ) || (~isempty(deblank(titleString))) )
    hold off
    plot(cadenceTimesLevel2 - startTime, metricValuesLevel2/scaleFactor, '-ob');
    hold on
    plot(cadenceTimesLevel2 - startTime, metricMeanEstimates/scaleFactor, '-xg');
    if trendFlag
        plot(timeStamps - startTime, (designMatrix * robustFitPolynomial)/scaleFactor, '-vm')
    end
    plot(cadenceTimesLevel2 - startTime, adaptiveUpperBounds/scaleFactor, '-sr');
    plot(cadenceTimesLevel2 - startTime, adaptiveLowerBounds/scaleFactor, '-sr');
    plot(cadenceTimesLevel2(isOutOfAdaptiveUpperBound) - startTime, ...
        metricValuesLevel2(isOutOfAdaptiveUpperBound)/scaleFactor, 'xr');
    plot(cadenceTimesLevel2(isOutOfAdaptiveLowerBound) - startTime, ...
        metricValuesLevel2(isOutOfAdaptiveLowerBound)/scaleFactor, 'xr');

    t = [startTime; baseTime + horizonTime];
    if any(isOutOfFixedUpperBound) || fixedBoundsReport.upperBoundCrossingPredicted
        plot(t - startTime, [fixedUpperBound; fixedUpperBound]/scaleFactor, '--k');
        plot(cadenceTimesLevel1(isOutOfFixedUpperBound) - startTime, ...
            metricValuesLevel1(isOutOfFixedUpperBound)/scaleFactor, 'xk');
    end
    if any(isOutOfFixedLowerBound) || fixedBoundsReport.lowerBoundCrossingPredicted
        plot(t - startTime, [fixedLowerBound; fixedLowerBound]/scaleFactor, '--k');
        plot(cadenceTimesLevel1(isOutOfFixedLowerBound) - startTime, ...
            metricValuesLevel1(isOutOfFixedLowerBound)/scaleFactor, 'xk');
    end
    
    t = [0; horizonTime];
    if trendFlag
        plot(baseTime + t - startTime, ...
            (x2fx(t, (0 : TREND_ORDER)') * robustFitPolynomial)/scaleFactor, '-m')
    end
    plot(baseTime + t - startTime, ...
        [adaptiveUpperBoundForPrediction; adaptiveUpperBoundForPrediction]/scaleFactor, '--r');
    plot(baseTime + t - startTime, ...
        [adaptiveLowerBoundForPrediction; adaptiveLowerBoundForPrediction]/scaleFactor, '--r');
    
    if (~isempty(deblank(titleString)))
        if ( scale && scaleExponent ~= 0 )
            title([titleString,'x10^{',num2str(-scaleExponent),'}']) ;
        else
            title(titleString) ;
        end
    else
        if ( ccdModule==-1 || ccdOutput==-1 )
            title(sprintf('[PPA] Tracking and Trending:\n %s', metricName));
        else
            title(['[PPA] Tracking and Trending: ' metricName ' -- Module ' num2str(ccdModule) ' / Output ' num2str(ccdOutput)]);
        end
    end
    xlabel('Days');
    ylabel('Metric and Bounds Values');

    if ~trendFlag
        legend('Metric', 'Smoothed Metric', 'Adaptive Bounds');
    elseif trendSlope < 0
        legend('Metric', 'Smoothed Metric', 'Trend Fit', 'Adaptive Bounds');
    else
        legend('Metric', 'Smoothed Metric', 'Trend Fit', 'Adaptive Bounds');
    end
    
    if (isempty(deblank(titleString)))
        pause(1)
    end
    
end

% Copy the fixed and adaptive bounds reports, trending report and the alerts to the output report.

metricReport.trackAlertLevel      = trackAlertLevel;
metricReport.trendAlertLevel      = trendAlertLevel;
metricReport.fixedBoundsReport    = fixedBoundsReport;
metricReport.adaptiveBoundsReport = adaptiveBoundsReport;
metricReport.trendReport          = trendReport;
metricReport.alerts               = alerts;

% Return.
return
