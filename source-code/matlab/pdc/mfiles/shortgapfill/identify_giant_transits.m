%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [indexOfGiantTransits,indexOfNormal,fittedTrend] =
%     identify_giant_transits(timeSeriesWithGaps, dataGapIndicators, ...
%     gapFillParametersStruct, maxDutyCycle, fittedTrend)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Description:
% This function identifies 'giant' transits (transits due to eclipsing
% binaries and transiting Jupiters).
%
% Inputs:
%         1. timeSeriesWithGaps -  time series with data gaps
%         2. dataGapIndicators - a logical array with 1's indicating data gaps and 0's
%            indicating available samples
%         3. gapFillParametersStruct - a structure containing the following
%            fields
%            madXFactor = 10 % this factor will be used to multiply the
%                median absolute deviation to set the threshold for outliers
%            maxGiantTransitDurationInHours = 72 % if large number of consecutive
%                cadences are identified as part of giant transits (because
%                of inappropriate outlier threshold setting), only the first
%                ncadences in 'maxGiantTransitDurationInHours' will be
%                marked as being part of giant transits
%            maxDetrendPolyOrder = 25 % max order of polynomial used
%                for detrending
%            maxArOrderLimit =  25; % max AR model order limit set for choose_fpe_model_order function.
%            maxCorrelationWindowXFactor =  5; % correlation window
%                size is 'maxCorrelationWindowXFactor' times
%                'maxArOrderLimit'
%            cadenceDurationInMinutes = 30 % long/short cadence duration
%                in minutes
%            gapFillModeIsAddBackPredictionError = true % this flag
%            allows this short gap fill agorithm act in two modes
%               (1) estimation of missing values using AR model prediction
%               (2) estimation of missing values + prediction errors - this
%               allows each eavelet scale to maintain noise variance across
%               the gaps when missing values are filled in
%                 Second mode is useful for transit detection algorithm
%                 which forms detection statistics in the wavelet domain
%                 and the algorithm is sensitive to discontinuities in the
%                 wavelet scales (if missing values are estimated over a
%                 gap, and the filled in time series is wavelet transormed,
%                 the same gap appears to have zero variance in each scale)
%            giantTransitPolyFitChunkLengthInHours = 72 % controls the
%                chunk length of the data when doing robust AI criteria and
%                polynomial fitting in identify_giant_transits.m
% Output:
%         1. indexOfGiantTransits - indices of samples that are detected to be
%            part of giant transits
%         2. indexOfNormal - indices of samples that are normal
%         3. fittedTrend - the piecewise poly fit from the first call to
%            isolate_giant_transits.
%
% Note:
%   Changing the madXFactor may alter the number of samples declared as
%   part of giant transits. maxGiantTransitDurationInCadences is to control the
%   number of consecutive samples declared as part of giant transits (in
%   saturated flux time series, sometimes 300 consecutive cadences are
%   identified as part of giant transits).
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
function [indexOfGiantTransits, indexOfNormal, fittedTrend] = ...
    identify_giant_transits(timeSeriesWithGaps, dataGapIndicators, ...
    gapFillParametersStruct, maxDutyCycle, fittedTrend)


if(any(isnan(timeSeriesWithGaps)))
    indexOfNaNs = find(isnan(timeSeriesWithGaps));
    dataGapIndicators(indexOfNaNs) = true;
    timeSeriesWithGaps(indexOfNaNs) = 0;
    warning('GapFill:identify_giant_transits', ...
        'GapFill:identify_giant_transits:found NaNs in the input; treating NaNs as data gaps and proceeding with identification of giant transits...');

end

% if there is no fittedTrend input then one will need to be generated
if ~exist('fittedTrend', 'var') 
    fittedTrend = [];
end

% if maxDutyCycle doesnt exist then use a default value
if ~exist('maxDutyCycle', 'var')
    maxDutyCycle = 0.2;
end

% if the maxDutyCycle is empty then turn it off
if (isempty( maxDutyCycle ) || maxDutyCycle < 0)
    maxDutyCycle = 1;
end

madXFactor = gapFillParametersStruct.madXFactor; % unitless multiplying factor

if ~isfield(gapFillParametersStruct,'cadenceDurationInMinutes')
    gapFillParametersStruct.cadenceDurationInMinutes = 29.4244;
end % if

% maxGiantTransitDurationInCadences in number of cadences
cadenceDurationInMinutes = gapFillParametersStruct.cadenceDurationInMinutes;
maxGiantTransitDurationInCadences = fix(gapFillParametersStruct.maxGiantTransitDurationInHours * ...
    60/cadenceDurationInMinutes);

polyFitChunkLengthInCadences = fix(gapFillParametersStruct.giantTransitPolyFitChunkLengthInHours * ...
    60/cadenceDurationInMinutes);

maxDetrendPolyOrder = gapFillParametersStruct.maxDetrendPolyOrder;

% perform low order robust detrend of the flux time series prior to
% extending the series at the ends
nCadences = length(timeSeriesWithGaps);
timeSeriesWithGaps = timeSeriesWithGaps(:);
dataGapIndicators = dataGapIndicators(:);
indexAvailable = find(~dataGapIndicators);

if(length(indexAvailable) < 4)
    warning('GapFill:identify_giant_transits', ...
        'GapFill:identify_giant_transits:can''t look for giant transits as insufficient number of samples are available...');
    indexOfGiantTransits = [];
    indexOfNormal = indexAvailable;
    fittedTrend = [];
    return
end

%--------------------------------------------------------------------------
% Step 1: If the time series contains data gaps, then use interp1 to fill
% in the missing values temporarily; use 'extrap' interpolation so that
% transits can still be indentified if there is a gap at the beginning or
% end of the time series
%--------------------------------------------------------------------------

timeSteps = (1:nCadences)';

% check to see whether the data gaps occur at the end or at the beginning
indexOfMissing = find(dataGapIndicators);

if(~isempty(indexOfMissing))
    % beginning
    if( (indexOfMissing(1) == 1) ||(indexOfMissing(end) == length(timeSeriesWithGaps)) )
        trendValue = median(timeSeriesWithGaps(indexAvailable));
        timeSeries = interp1(indexAvailable, timeSeriesWithGaps(indexAvailable), timeSteps, 'linear', trendValue);
    else
        timeSeries = interp1(indexAvailable, timeSeriesWithGaps(indexAvailable), timeSteps);
    end
else
    timeSeries = timeSeriesWithGaps;
end

%--------------------------------------------------------------------------
% Step 2: Invoke isolate_giant_transits to identify cadences that are part
% of giant transits - this is the first attempt
% The reason for making two iterations through isolate_giant_transits is to
% get better at removing trend as we remove the samples that are part of giant
% transits (these samples perturb the trend severely)
%--------------------------------------------------------------------------

% first time through we should just use madXFactor without any scaling

madXScaleFactor = 1;

transitDutyCycle = 2;
chunkLength = polyFitChunkLengthInCadences;
dataGapIndicatorsInitial = dataGapIndicators;
while (transitDutyCycle > maxDutyCycle && chunkLength > maxDetrendPolyOrder+1)
    
    dataGapIndicators = dataGapIndicatorsInitial;
    [indexOfGiantTransits, indexOfNormal, medianAbsDeviationFirstPass, fittedTrend] = ...
        isolate_giant_transits(timeSeries, madXFactor, madXScaleFactor, maxDetrendPolyOrder, ...
        chunkLength, cadenceDurationInMinutes, dataGapIndicators, fittedTrend);

    if(~isempty(indexOfGiantTransits) && ~isempty(indexOfNormal)) % found giant transits in the first pass

        timeSeriesWithoutGiantTransits = timeSeries(indexOfNormal); % remove them temporarily
        dataGapIndicators = dataGapIndicators(indexOfNormal);
        fittedTrendWithoutGiantTransits = fittedTrend(indexOfNormal);

        %--------------------------------------------------------------------------
        % Step 3: Invoke isolate_giant_transits to identify cadences that are part
        % of giant transits - this is the last attempt
        % collect the remaining samples that are part of giant transits that
        % were not identified in the first pass
        %--------------------------------------------------------------------------

        % Before passing through a second time, I n/path/to/TEST/8.2-vv/flight/dv/i6755/eed to scale down madXFactor
        % by the amount that medianAbsDeviation was improved after removing
        % the first batch of giant transits

        [indexOfGiantTransitsInNewTimeSeries] = ...
            isolate_giant_transits(timeSeriesWithoutGiantTransits, madXFactor, ...
            medianAbsDeviationFirstPass, maxDetrendPolyOrder, chunkLength, ...
            cadenceDurationInMinutes, dataGapIndicators, fittedTrendWithoutGiantTransits);

        if(~isempty(indexOfGiantTransitsInNewTimeSeries))
            moreIindexOfGiantTransits = indexOfNormal(indexOfGiantTransitsInNewTimeSeries);
            % moreIindexOfGiantTransits has to be a row vector
            moreIindexOfGiantTransits = moreIindexOfGiantTransits(:);

            indexOfGiantTransits = sort([indexOfGiantTransits; moreIindexOfGiantTransits]);
        end;

        isValidIndex = indexOfGiantTransits > 0 & indexOfGiantTransits <= nCadences;
        indexOfGiantTransits = indexOfGiantTransits(isValidIndex);

        % if there are too many samples detected as part of huge transits, it
        % could be because the flux time series is saturated...
        % sanity check...
        % find the longest consecutive transit

        giantTransitIndicators = false(nCadences,1);
        giantTransitIndicators(indexOfGiantTransits) = true;

        [giantTransitsLocations, sizeOfGiantTransits] = find_datagap_locations(giantTransitIndicators);
        timeSeries = interp1(indexAvailable, timeSeriesWithGaps(indexAvailable), timeSteps);
        % number of consecutive cadences identified as part of giant transits
        % exceeds the maxGiantTransitDurationInCadences
        if( max(sizeOfGiantTransits) > maxGiantTransitDurationInCadences)

            indexOfSuspects = find(sizeOfGiantTransits > maxGiantTransitDurationInCadences);

            % return only max. cadences specified by
            % maxGiantTransitDurationInCadences in each those giant
            % transits

            for kSuspects = 1:length(indexOfSuspects)
                % untag the giant transit indicator beyond maxGiantTransitDurationInCadences

                indexOfThisGiantTransit = (giantTransitsLocations(indexOfSuspects(kSuspects),1):giantTransitsLocations(indexOfSuspects(kSuspects),2))';

                unTagIndex = indexOfThisGiantTransit(maxGiantTransitDurationInCadences+1:end) ;

                giantTransitIndicators(unTagIndex) = false;

            end
        end;

        indexOfGiantTransits = find(giantTransitIndicators);
        indexOfNormal = find(~giantTransitIndicators);
        indexOfNormal = intersect(indexAvailable, indexOfNormal);
        indexOfNormal = indexOfNormal(:);
        indexOfGiantTransits = intersect(indexAvailable, indexOfGiantTransits);
        indexOfGiantTransits = indexOfGiantTransits(:);
        transitDutyCycle = length(indexOfGiantTransits)/length(timeSeries);
        chunkLength = round(chunkLength/2);
    else
        % indexOfGiantTransit = [];
        indexOfNormal = intersect(indexAvailable, indexOfNormal);
        indexOfNormal = indexOfNormal(:);
        indexOfGiantTransits = [];
        transitDutyCycle = 0;
    end 
end
    
return



%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
function [indexOfGiantTransits, indexOfNormal, medianAbsDeviation, taperedPolyFit] = ...
    isolate_giant_transits(timeSeries, madXFactor, madXScaleFactor, ...
    maxDetrendPolyOrder, polyFitChunkLengthInCadences, ...
    cadenceDurationInMinutes, dataGapIndicators, taperedPolyFit)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% This function first detrends the time series by splitting it into small
% chunks and robustly fitting polynomials to each chunk.  This is then 
% repeated after shifting the chunks by half a chunk.  The fitted time 
% series for the shifted and non-shifted case are then added together after
% tapering using a bartlett window.  This robust fit polynomial time series
% is then subtracted from the original time series to get the residuals.
% Some thresholding is then done on the MAD time series to find the giant
% transits.
%
% Note that the detrendPolyOrder should be set to -1 so that the AIC is/path/to/TEST/8.2-vv/flight/dv/i6755/
% used to determine the optimal polynomial order for fitting.  If the
% optimal order has already been determined, then specify that order
% instead.
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

% these parameters need not become module parameters
shortCadenceFlag = false;
if(cadenceDurationInMinutes <= 5)
    shortCadenceFlag = true;
end

if(shortCadenceFlag)
    cadencesToPad = 25;
else
    cadencesToPad = 2;
end

nCadences = length(timeSeries);
timeSteps = (1:nCadences)';

if ~exist('dataGapIndicators', 'var') || isempty(dataGapIndicators)
    dataGapIndicators = false(nCadences,1);
end

if isempty(taperedPolyFit)
    taperedPolyFit = piecewise_robustfit_timeseries(timeSeries, polyFitChunkLengthInCadences, ...
        madXFactor, maxDetrendPolyOrder, dataGapIndicators);
end

% remove trend and obtain the residuals
residualTimeSeries = timeSeries - taperedPolyFit; 

% Collect samples in the left tail ( < median and call this array
% tLeftResidualSeries) and find the left tail median - dont allow gap
% cadences to contribute to medians

leftIndex = find(residualTimeSeries < median(residualTimeSeries(~dataGapIndicators)));
rightIndex = find(residualTimeSeries > median(residualTimeSeries(~dataGapIndicators)));
tLeftResidualSeries = residualTimeSeries(leftIndex);
tRightResidualSeries = residualTimeSeries(rightIndex);
gapIndicatorsLeft = dataGapIndicators(leftIndex);
gapIndicatorsRight = dataGapIndicators(rightIndex);

% Compute the absolute deviations of the samples in tLeftResidualSeries  from the left
% tail median and find the median absolute deviation (call it medianAbsDeviation).

absDeviationFromMedian = abs(tRightResidualSeries - median(tRightResidualSeries(~gapIndicatorsRight)));
medianAbsDeviation = median(absDeviationFromMedian);
    
% scale madXFactor for second pass if it is not set to one - if we are
% doing multiple passes then it should be scaled by the ratio of
% medianAbsDeviations to maintain the same level of sensitivity
if ~isequal(madXScaleFactor,1)
    madXScaleFactor = medianAbsDeviation/madXScaleFactor;
    if madXScaleFactor > 1
        madXScaleFactor = 1;
    end
    % set a hard lower limit for light curves that are extreme
    if madXScaleFactor < 0.5
        madXScaleFactor = 0.5;
    end  
end

% Now look at the samples in tLeftResidualSeries and identify the samples
% that are  madXFactor*medianAbsDeviation to the left of the left median
% as  possible transit outliers (outlierIndex)

%deviationFromMedian = (tLeftResidualSeries - median(tLeftResidualSeries(~gapIndicatorsLeft)));
deviationFromMedian = tLeftResidualSeries - median(residualTimeSeries(~dataGapIndicators));
farLeftIndicators = deviationFromMedian < -madXFactor*madXScaleFactor*medianAbsDeviation;
outlierIndex = sort(leftIndex(farLeftIndicators));
outlierIndex = outlierIndex(:)'; % definitely a row vector

giantTransitIndicators = false(nCadences,1);
giantTransitIndicators(outlierIndex) = true;

if(isempty(outlierIndex))
    indexOfGiantTransits = [];
    indexOfNormal = timeSteps;


elseif (length(outlierIndex) == 1)

    % accommodate single point outliers
    indexOfGiantTransits = outlierIndex;
    indexOfNormal = find(~giantTransitIndicators);

else % length(outlierIndex) > 1

    % To be part of a transit, all the outlying samples should be in temporal
    % sequence. Therefore look for samples that are consecutive. If there is
    % more than one group, it is okay.

    giantTransitsLocations = find_datagap_locations(giantTransitIndicators);

    nGiantTransits = size(giantTransitsLocations,1);

    for jGiantTransit = 1:nGiantTransits

        indexOfThisGiantTransit = (giantTransitsLocations(jGiantTransit,1):giantTransitsLocations(jGiantTransit,2))';
        indexOfThisGiantTransit     = indexOfThisGiantTransit(:);
        
        % need to be careful here to only pad when there is more than one
        % giant transit cadence, excluding gap cadences which will get
        % tossed out in the main function
        
        nValidGiantTransitCadences = length( setdiff(indexOfThisGiantTransit, find(dataGapIndicators)) ) ; 
        
        if((~shortCadenceFlag && nValidGiantTransitCadences > 1) || ...
                (shortCadenceFlag && nValidGiantTransitCadences > 5))
            
            % extend the giant transits (those containing more than one LC sample)
            % or more than five SC samples) by a defined number of samples at 
            % each end to ensure that the first and last samples in giant transits
            % that may escape identification here are not removed as outliers

            % expand this giant transit by padding 'cadencesToPad' on either side
            indexOfThisGiantTransit = (indexOfThisGiantTransit(1)-cadencesToPad:indexOfThisGiantTransit(end)+cadencesToPad)';

            % make sure that 1>= indexOfThisGiantTransit <= nCadences
            indexOfThisGiantTransit = indexOfThisGiantTransit(indexOfThisGiantTransit >= 1 & indexOfThisGiantTransit <= nCadences);
        end
        giantTransitIndicators(indexOfThisGiantTransit) = true;

    end

    indexOfGiantTransits = find(giantTransitIndicators);
    indexOfNormal = find(~giantTransitIndicators);
end;

return
