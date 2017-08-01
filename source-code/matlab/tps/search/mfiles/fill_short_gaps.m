%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function  [timeSeriesWithGapsFilled, masterIndexOfAstroEvents, ...
%               longDataGapIndicators, uncertaintiesWithGapsFilled] = ...
%               fill_short_gaps(timeSeriesWithGaps, dataGapIndicators, ...
%               indexOfAstroEvents, debugFlag, gapFillParametersStruct, ...
%               uncertaintiesWithGaps )
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Description:
%         This function fills the short data gaps in a non stationary time
%         series using an AR Model.  Trends are removed to render the time
%         series stationary and the autocorrelation function is built using
%         all available cadences in the stationary time series.
%
% Inputs:
%         1. timeSeriesWithGaps - time series into which data gaps have been introduced-
%         2. dataGapIndicators - a logical array with 1's indicating data gaps and 0's
%            indicating available samples
%         3. indexOfAstroEvents - cadence indices that were previously
%            identified as being part of astrophysical events.  If set to
%            zero then the identification will be done internally to this
%            function.
%         4. debugFlag - flag to turn on plotting the data gaps as they are filled
%         5. gapFillParametersStruct - a structure containing the following
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
%               chunk length of the data when doing robust AI criteria and
%               polynomial fitting in identify_giant_transits.m
%         6. uncertaintiesWithGaps - a time series of uncertainties
%                  associated with each sample, with zeros where no samples exis
%         7. fittedTrend - specify the trend if available to avoid the
%               costly call to piecewise_robustfit_timeseries.
%
% Output:
%         1. timeSeriesWithGapsFilled - time series where data gaps have been
%            filled with estimated samples
%         2. masterIndexOfAstroEvents - index of samples identified as
%            part of astrophysical events
%         3. longDataGapIndicators - a logical array with 1's indicating
%            long data gaps that were left unfilled and 0's indicating available samples
%         4. uncertaintiesWithGapsFilled - time series of uncertainties
%            where filled-in samples also have uncertainties associated
%            with them
%         5. fittedTrend - output the trend for use in subsequent calls
%
%
% References:
%         [1] KADN-26067 Short Data Gap Filling Algorithm
%         [2] Peter J. Brockwell and Richard A. Davis, "Introduction to Time
%             Series and Forecasting", Springer, 2002 pages 170 -171
%         [3] M. Hayes, "Statistical Signal Processing and Modeling", John
%             wiley & Sons inc.,1996
%         [4] C. W. Therrien, "Discrete Random Signals and Statistical
%             Signal Processing", Prentice-Hall Inc., Englewood Cliffs, New
%             Jersey, 1992.
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
function  [timeSeriesWithGapsFilled, indexOfAstroEvents, longDataGapIndicators, ...
    uncertaintiesWithGapsFilled, fittedTrend] = fill_short_gaps(timeSeriesWithGaps, ...
    dataGapIndicators, indexOfAstroEvents, debugFlag, gapFillParametersStruct, ...
    uncertaintiesWithGaps, fittedTrend )

if ~isfield(gapFillParametersStruct,'cadenceDurationInMinutes')
    gapFillParametersStruct.cadenceDurationInMinutes = 29.4244;
end 

MAX_ADAPTIVE_WINDOW_X_FACTOR = 25; % set a hard limit to the window size for the adaptive AR model

% constants
maxArOrderLimit                     = gapFillParametersStruct.maxArOrderLimit;
maxCorrelationWindowXFactor         = gapFillParametersStruct.maxCorrelationWindowXFactor;
maxDetrendPolyOrder                 = gapFillParametersStruct.maxDetrendPolyOrder;
gapFillModeIsAddBackPredictionError = gapFillParametersStruct.gapFillModeIsAddBackPredictionError;
madXFactor                          = gapFillParametersStruct.madXFactor;
cadenceDurationInMinutes            = gapFillParametersStruct.cadenceDurationInMinutes;
giantTransitPolyFitChunkLength      = gapFillParametersStruct.giantTransitPolyFitChunkLengthInHours;
autoCorrThreshold                   = gapFillParametersStruct.arAutoCorrelationThreshold;
maxCorrelationWindowLimit           = maxCorrelationWindowXFactor * maxArOrderLimit;
polyFitChunkLengthInCadences        = fix(giantTransitPolyFitChunkLength * 60/cadenceDurationInMinutes);
maxAdaptiveWindowSize               = maxCorrelationWindowLimit * MAX_ADAPTIVE_WINDOW_X_FACTOR;

upwardAstroEvents = [];

if ( exist('uncertaintiesWithGaps', 'var') && ~isempty(uncertaintiesWithGaps) )
    uncertaintiesWithGapsFilled =  uncertaintiesWithGaps;
else
    uncertaintiesWithGapsFilled = [] ;
end

indexAvailable = find(~dataGapIndicators); % index of available points
indexUnavailable = find(dataGapIndicators); % index of not available points

if (indexOfAstroEvents == 0)
    [indexOfAstroEvents, fittedTrend] = identify_astrophysical_events(timeSeriesWithGaps, ...
        dataGapIndicators, gapFillParametersStruct); 
end

if isempty(indexUnavailable)
    % there are no gaps so just exit
    timeSeriesWithGapsFilled = timeSeriesWithGaps;
    longDataGapIndicators = dataGapIndicators;
    if isequal(indexOfAstroEvents,0)
        indexOfAstroEvents = [];
    end
    
    % if we need to output a fittedTrend but dont have one, then generate
    if( isequal(nargout,5) && ( ~exist('fittedTrend', 'var') || isempty(fittedTrend) ) )
        fittedTrend = piecewise_robustfit_timeseries(timeSeriesWithGaps, polyFitChunkLengthInCadences, ...
            madXFactor, maxDetrendPolyOrder, dataGapIndicators); 
    end

    return;
end

if debugFlag    
    indexOfAvailable = find(~dataGapIndicators);
    plot(indexOfAvailable, timeSeriesWithGaps(indexOfAvailable),'b.-');
    if ~isempty(indexOfAstroEvents)
        hold on;
        plot(indexOfAstroEvents,timeSeriesWithGaps(indexOfAstroEvents),'mo');
    end   
end

% this code is sometimes called with fillIndices so we need to
% explicitly throw out astro events that are in data gaps
indexOfAstroEvents = setdiff(indexOfAstroEvents, find(dataGapIndicators)) ;

% There is a tradeoff between loosening the detrending and autocorrelation
% window size for AR.  If we do a loose global detrend then we would need a
% larger window when we construct the autocorrelation function since the
% residual would have a lot of correlation structure left.  This can lead
% to noisy prediction values.  Here I elect to do a more sophisticated
% piecewise detrend which should give me a more well behaved residual and
% allow me to use a smaller autocorrelation window for AR.  Of course the
% draw back to this approach is that the fitted trend has to be spot on.

if( ~exist('fittedTrend', 'var') || isempty(fittedTrend) )
    fittedTrend = piecewise_robustfit_timeseries(timeSeriesWithGaps, polyFitChunkLengthInCadences, ...
        madXFactor, maxDetrendPolyOrder, dataGapIndicators); 
end
 
timeSeriesForAutoCorr = timeSeriesWithGaps - fittedTrend;

% determine the auto corr window size for AR by thresholding on the full
% autocorrelation both with and without giant transits

adaptiveWindowLengthWithTransits = compute_autocorrelation_window_size( timeSeriesForAutoCorr, ...
    autoCorrThreshold, indexUnavailable);

adaptiveWindowLengthNoTransits = compute_autocorrelation_window_size( timeSeriesForAutoCorr, ...
    autoCorrThreshold, union(indexUnavailable,indexOfAstroEvents));

% ensure the window is not too large

adaptiveWindowLengthWithTransits = min( maxAdaptiveWindowSize, adaptiveWindowLengthWithTransits );
adaptiveWindowLengthNoTransits = min( maxAdaptiveWindowSize, adaptiveWindowLengthNoTransits );

[gapArray, ~] =  identify_contiguous_integer_values(indexUnavailable);
numGaps = length(gapArray);

% if there is a data gap in the very beginning, it makes sense to fill the
% missing samples that are far from the beginning (closer to existing
% samples) first; so reverse the missing samples fill order for the first
% gap
endSamples = zeros(length(indexUnavailable),1);
if (gapArray{1}(1) == 1) % there is a gap in the beginning
    % reverse the indexUnavailable order in the first gap            
    sizeOfFirstGap = length(gapArray{1});
    indexUnavailable(1:sizeOfFirstGap) = flipud(indexUnavailable(1:sizeOfFirstGap));
    gapArray{1} = flipud(gapArray{1});
    endSamples(1:sizeOfFirstGap) = indexUnavailable(1:sizeOfFirstGap);
    % collect first gap and last gap missing samples (extrapolation)
end
if (gapArray{end}(end) == length(timeSeriesWithGaps)) % there is a gap in the end
    sizeOfLastGap = length(gapArray{end});
    startIndex = find(endSamples==0, 1, 'first');
    endSamples(startIndex:startIndex+sizeOfLastGap-1) = indexUnavailable(end - sizeOfLastGap +1 :end);
    % collect first gap and last gap missing samples (extrapolation)
end
% trim endSamples so we store only cadences associated with gaps that 
%include the first and/or last cadence in the order in which they will be
%filled - this only affects the way the fitted trend is done later
startIndex = find(endSamples==0, 1, 'first');
endSamples(startIndex:end) = [];

for j = 1:numGaps
    
    gapIndices = gapArray{j};
    gapSize = length(gapArray{j});
    wasPartOfGiantTransit = false;
    needNewAutoCorrFlag = false;
    
    % do not fill the data gap if gap size is long (i.e., >= maxCorrelationWindowLimit)
    if (gapSize > maxCorrelationWindowLimit)
        continue;
    end;
    
    for i = gapIndices(:)'
        
        [isMiddleOfGiantTransit, isPartOfGiantTransit] = ...
            assess_giant_transit_association( indexAvailable, ...
            indexOfAstroEvents, i,timeSeriesWithGaps );
        
        % check to see if the value of isPartOfGiantTransit has changed
        % since the last i.  If it has changed then we need to redo the
        % autocorrelation
        
        if ~isequal(isPartOfGiantTransit, wasPartOfGiantTransit)
            needNewAutoCorrFlag = true;
        end
        
        % double check that there will be available lags for this cadence -
        % if not then we need to recompute the autocorrelation.  This can
        % happen when the available cadences are all on one side of the gap
        % and the gap is larger than the number of available cadences in
        % the window
        if( i~=gapIndices(1) )
            iLags = compute_lags(i, indexOfAvailableInARWindow, nTimeSteps) ;
            if( isempty(iLags) )
                needNewAutoCorrFlag = true;
            end
        end
        
        % if this is the first sample for this gap then set up the
        % correlation window and compute the autocorrelation
        if ( i==gapIndices(1) || ismember(i,endSamples) || needNewAutoCorrFlag )
            
            needNewAutoCorrFlag = false;
            wasPartOfGiantTransit = isPartOfGiantTransit;
            
            correlationWindowLength = max(2*gapSize,maxCorrelationWindowLimit);
            if isPartOfGiantTransit
                correlationWindowLength = max(correlationWindowLength,adaptiveWindowLengthWithTransits);
            else
                correlationWindowLength = max(correlationWindowLength,adaptiveWindowLengthNoTransits); 
            end
            
            iAttempt=0;
            indexOfAvailableInCorrWindow = [];
            while (length(indexOfAvailableInCorrWindow) <= 2 && iAttempt < 5)
                iAttempt = iAttempt+1;
                
                if (i <= gapIndices(end))
                    indexOfAvailableInCorrWindow = (i-iAttempt*correlationWindowLength):(gapIndices(end)+iAttempt*correlationWindowLength);
                    indexOfAvailableInCorrWindow = indexOfAvailableInCorrWindow(:);
                else
                    % the gap is on an end, so the correlation window
                    % extends in one direction
                    indexOfAvailableInCorrWindow = i:(i+iAttempt*correlationWindowLength);
                    indexOfAvailableInCorrWindow = indexOfAvailableInCorrWindow(:);
                end
                % collect indices of available points that are within the correlation window
                indexOfAvailableInCorrWindow = intersect(indexAvailable,indexOfAvailableInCorrWindow);
                if ~isPartOfGiantTransit
                    indexOfAvailableInCorrWindow = setdiff(indexOfAvailableInCorrWindow, indexOfAstroEvents);
                end
            end
              
            % do not fill the data gap if there is only one sample in the
            % correlation window or none at all
            if(isempty(indexOfAvailableInCorrWindow) || length(indexOfAvailableInCorrWindow) <= 2)
                break;
            end;
            
            nTimeSteps = (min(indexOfAvailableInCorrWindow):max(indexOfAvailableInCorrWindow))';
            timeSeriesWithGapInCorrWindow = timeSeriesWithGaps(nTimeSteps);

            % check to see whether this 'i' is part of the first gap or last gap -
            % involves extrapolationfind(indexOfAvailableInCorrWindow > i, 1, 'first');
            if ismember(i,endSamples)
                [fittedTrendInCorrWindow]  = fit_trend(nTimeSteps, indexOfAvailableInCorrWindow, ...
                    timeSeriesWithGaps,  maxDetrendPolyOrder);
            else
                 fittedTrendInCorrWindow = fittedTrend(nTimeSteps);
            end

            % remove trend and obtain residuals which are  ~ stationary
            timeSeriesWithGapInCorrWindow = timeSeriesWithGapInCorrWindow - fittedTrendInCorrWindow;
            
            % set gaps to zeros
            [indexToIgnore, ia ] = setdiff(nTimeSteps,indexOfAvailableInCorrWindow);
            timeSeriesWithGapInCorrWindow(ia) = 0;
            
            % for samples that are in the middle of giant transits, linearly
            % interpolate
            if(isMiddleOfGiantTransit )
                timeSeriesWithGapInCorrWindow = interp1(indexOfAvailableInCorrWindow,timeSeriesWithGaps(indexOfAvailableInCorrWindow), nTimeSteps, 'linear');
            end;

            % get the autocovariance of timeSeriesWithGapInCorrWindow vector
            r = xcorr(timeSeriesWithGapInCorrWindow, 'biased');
            r = r(length(timeSeriesWithGapInCorrWindow):end);
            
            % choose model order here for this segment of the time series
            % adaptively
            maxAROrder =  min(fix(length(timeSeriesWithGapInCorrWindow)/2),maxArOrderLimit);

            % finalPredictionError(p) is the variance estimate of the white noise
            % input to the AR model of order p
            [modelOrderAR, finalPredictionError] = choose_fpe_model_order( timeSeriesWithGapInCorrWindow,maxAROrder); % finalPredictionError is an array
            
            % collect indices of availble samples in the AR model order size window
            % determine the first available cadence in both directions and collect
            % all cadences within the AR window starting from there
            rightStart = indexOfAvailableInCorrWindow( find(indexOfAvailableInCorrWindow > i, 1, 'first') );
            leftStart = indexOfAvailableInCorrWindow( find(indexOfAvailableInCorrWindow < i, 1, 'last') );
            cadencesInARWindow = [leftStart-modelOrderAR+1:leftStart,rightStart:rightStart+modelOrderAR-1]';
            indexOfAvailableInARWindow = intersect(cadencesInARWindow,indexOfAvailableInCorrWindow)';

            jAttempt = 1;
            % enlarge the modelOrderAR window if indexOfAvailableInARWindow
            % is empty for the current modelOrderAR size
            while (isempty(indexOfAvailableInARWindow))
                jAttempt = jAttempt+1;
                cadencesInARWindow = [(leftStart-modelOrderAR*jAttempt+1):leftStart,rightStart:(rightStart+modelOrderAR*jAttempt-1)]';
                indexOfAvailableInARWindow = intersect(cadencesInARWindow,indexOfAvailableInCorrWindow)';
            end;
            
            [~, indexInTimeSteps] = intersect(nTimeSteps, indexOfAvailableInARWindow); % 'indexInTimeSteps' locates 'indexOfAvailableInARWindow' in  'nTimeSteps'
        end

        [~, iInTimeSteps] = intersect(nTimeSteps, i); % 'iInTimeSteps' locates 'i' in 'nTimeSteps'

        % compute the lags of samples in the window from 'i'.  Note that the +1
        % is necessary because zero lag is at the first index of r
        [iLags, lagsToKeep] = compute_lags(i, indexOfAvailableInARWindow, nTimeSteps) ;

        % form a subset of correlation vector; note that samples that are at
        % the same distance on either side of 'i' have the same lags and the
        % correlation function is symmetric.  Note that the +1 is necessary 
        % because zero lag is at the first index of r
        ri = r(abs(iLags)+1);

        % T = toeplitz(r) returns the symmetric or Hermitian Toeplitz matrix
        % formed from vector r, where r defines the first row of the matrix.
        % remember that the correlation matrix for any stationary random
        % process is always a symmetric toeplitz matrix and is completely
        % defined by the correlation function (here by r) for the process
        %R = toeplitz(r);
        
        % The toeplitz() is slow and takes up too much memory when r is
        % large.  We dont need the whole matrix anyway, so just generate
        % the parts that we do need instead
        iLagMatrix=repmat(iLags,1,length(iLags));
        Ri = r( abs(iLagMatrix - iLagMatrix') + 1 );

        a = Ri\ri; % solve for AR parameters from the equation Ri*a = ri

        if(any(isnan(a(:))) || isempty(a)) % check for NaNs

            [fittedTrendInCorrWindow, fittedPolyOrder,polynomialCoefficients, structureS, scalingCenteringMu]  = ...
                fit_trend(nTimeSteps, indexOfAvailableInCorrWindow,  timeSeriesWithGaps,  maxDetrendPolyOrder);
            if ~isempty( uncertaintiesWithGapsFilled )
                finalPredictionError = uncertaintiesWithGapsFilled(indexOfAvailableInARWindow(lagsToKeep)) .^ 2;
            else
                finalPredictionError = zeros( size( indexOfAvailableInARWindow(lagsToKeep) ) ) ;
            end

            trendValueAtUnavailableSample = polyval(polynomialCoefficients, i, structureS, scalingCenteringMu);
            fitValue = timeSeriesForAutoCorr(i);
            needNewAutoCorrFlag = true;
            
            if isempty(finalPredictionError)
                finalPredictionError = 1;
            end

        else % valid a, so proceed

            % most of the time missing sample 'i' is flanked by available samples -
            % in which case we can get the trend value at 'i' by looking up the
            % correct index in 'fittedTrend'
            if(~isempty(iInTimeSteps))
                trendValueAtUnavailableSample = fittedTrendInCorrWindow(iInTimeSteps);
            else
                % but some times if 'i' is at the very beginning or end,
                % 'fittedTrend' has to be extrapolated just 1 step ahead/behind
                % since 'fittedTrend' will not include 'i'  - so use polyval
                % instead

                [fittedTrendInCorrWindow, fittedPolyOrder,polynomialCoefficients, structureS, scalingCenteringMu]  = ...
                    fit_trend(nTimeSteps, indexOfAvailableInCorrWindow,  timeSeriesWithGaps,  maxDetrendPolyOrder);
                trendValueAtUnavailableSample = polyval(polynomialCoefficients, i, structureS, scalingCenteringMu);

            end;

            fitValue = a'*(timeSeriesWithGaps(indexOfAvailableInARWindow(lagsToKeep))- fittedTrendInCorrWindow(indexInTimeSteps(lagsToKeep)));% first step, estimate as weighted sum of residuals
        end

        % let uncertainty in filled sample equal the rms uncertainty of samples
        % used to fill gap
        if ~isempty(uncertaintiesWithGapsFilled)
            uncertaintiesWithGapsFilled(i) = sqrt(mean(uncertaintiesWithGapsFilled(indexOfAvailableInARWindow(lagsToKeep)) .^ 2));
        end

        if(gapFillModeIsAddBackPredictionError) % add prediction error back into the estimated sample - this maintains the noise variance across the gap
            whiteGaussianNoiseSample = max(min(randn(1,1),3), -3);
            timeSeriesWithGaps(i) = fitValue  + trendValueAtUnavailableSample + sqrt(min(finalPredictionError))*whiteGaussianNoiseSample; % add back trend
        else  % just estimate, do not add back prediction error
            timeSeriesWithGaps(i) = fitValue  + trendValueAtUnavailableSample; % add back trend
        end
        
        if isPartOfGiantTransit 
            indexForMad = ~ismember(nTimeSteps, indexOfAstroEvents) & (timeSeriesWithGapInCorrWindow~=0);
            corrWindowMad = mad(timeSeriesWithGapInCorrWindow(indexForMad),1);
            if (timeSeriesWithGaps(i) < (trendValueAtUnavailableSample-madXFactor*corrWindowMad))
                indexOfAstroEvents = union(indexOfAstroEvents,i);
                indexOfAstroEvents = indexOfAstroEvents(:);
            else
                % remove giant transits that remain bordering this gap
                % since we just moved outside the giant transit.  Just add
                % them to the upward indices so they get added back in the
                % end
                astroEventsRight = indexOfAstroEvents( indexOfAstroEvents > gapIndices(end) );
                if ( ~isempty(astroEventsRight) && isequal(astroEventsRight(1)-1,gapIndices(end)) && ~ismember(i,endSamples) )
                    [astroEventsRightChunks, ~] = identify_contiguous_integer_values( astroEventsRight );
                    upwardAstroEvents = union(upwardAstroEvents,astroEventsRightChunks{1});
                    indexOfAstroEvents = setdiff(indexOfAstroEvents,astroEventsRightChunks{1});
                    upwardAstroEvents = upwardAstroEvents(:);
                    indexOfAstroEvents = indexOfAstroEvents(:);
                end
            end
        end
        
        % make index available next time the autocorrelation is constructed
        indexAvailable = union(indexAvailable, i);
        indexUnavailable  =  setdiff(indexUnavailable, i);
        indexAvailable = indexAvailable(:);
        indexUnavailable = indexUnavailable(:);

    end % for i=gapIndices(:)
    
end % for j=1:numGaps

timeSeriesWithGapsFilled = timeSeriesWithGaps;
longDataGapIndicators = false(size(dataGapIndicators));

% see if 'indexUnavailable' is empty; if it is not empty, unfilled cadences
% form one or more long gaps; mark those gaps in 'longDataGapIndicators'
if(~isempty(indexUnavailable))
    longDataGapIndicators(indexUnavailable) = true;
end;

% add back the upward astro events
indexOfAstroEvents = union(indexOfAstroEvents, upwardAstroEvents);
indexOfAstroEvents = indexOfAstroEvents(:);

return;

%--------------------------------------------------------------------------
% Determine the window size by applying a threshold to the normalized
% autocorrelation function
%--------------------------------------------------------------------------

function windowLengthInCadences = compute_autocorrelation_window_size( timeSeries, ...
    threshold, indexUnavailable)

timeSeries(indexUnavailable) = 0;
autoCorr = xcorr(timeSeries, 'biased');
autoCorr = autoCorr(length(timeSeries):end);
autoCorr=abs(autoCorr);
windowLengthInCadences = find(autoCorr/max(autoCorr) >= threshold, 1, 'last') + 1;

if isempty(windowLengthInCadences)
    windowLengthInCadences = 0;
end

return

%--------------------------------------------------------------------------
% Determine the fill cadence's association to giant transits in the
% correlation window
%--------------------------------------------------------------------------

function [isMiddleOfGiantTransit, isPartOfGiantTransit] = ...
    assess_giant_transit_association( indexOfAvailableInCorrWindow, ...
    indexOfGiantTransitsInCorrWindow, sampleIndex, timeSeriesWithGaps )

isMiddleOfGiantTransit = false;
isPartOfGiantTransit = false;

% if inputs are empty then return
if isempty(indexOfAvailableInCorrWindow)
    return;
end

if isempty(indexOfGiantTransitsInCorrWindow)
    return;
end

leftOfi = sampleIndex -1;
rightOfIndex = find(indexOfAvailableInCorrWindow > sampleIndex, 1, 'first');
if(~isempty(rightOfIndex))
    rightOfi = indexOfAvailableInCorrWindow(rightOfIndex);
else
    rightOfi = -1;
end;

[giantTransitChunks, ~] = identify_contiguous_integer_values( indexOfGiantTransitsInCorrWindow );
chunkNumRight =  cellfun(@(x) ismember(rightOfi,x), giantTransitChunks) ;
chunkNumLeft =  cellfun(@(x) ismember(leftOfi,x), giantTransitChunks) ;

if((ismember(leftOfi, indexOfGiantTransitsInCorrWindow) || ismember(rightOfi, indexOfGiantTransitsInCorrWindow)))

    % decide whether the sample sampleIndex is in the middle of the
    % transit or descends into a transit on the left/right side
    if((ismember(leftOfi, indexOfGiantTransitsInCorrWindow) && ismember(rightOfi, indexOfGiantTransitsInCorrWindow)))

        isMiddleOfGiantTransit = true;
        isPartOfGiantTransit = true;

    elseif( (ismember(rightOfi, indexOfGiantTransitsInCorrWindow)) && (~ismember(leftOfi, indexOfGiantTransitsInCorrWindow)))
        
        % keep only giant transits directly bordering the gap for the assessment
        indexOfGiantTransitsInCorrWindow = giantTransitChunks{chunkNumRight};
        sortedTransitFlux = sort(timeSeriesWithGaps(indexOfGiantTransitsInCorrWindow),'descend');
        distanceToTransit = (find(sortedTransitFlux <= timeSeriesWithGaps(rightOfi), 1, 'first'));
        if isempty(distanceToTransit)
            isPartOfGiantTransit = false;
        elseif ((rightOfi - sampleIndex) >= distanceToTransit)
            isPartOfGiantTransit = false;
        else
            isPartOfGiantTransit = true;
        end

    elseif( (ismember(leftOfi, indexOfGiantTransitsInCorrWindow)) && (~ismember(rightOfi, indexOfGiantTransitsInCorrWindow)) )
        
        % keep only giant transits directly bordering the gap for the assessment
        indexOfGiantTransitsInCorrWindow = giantTransitChunks{chunkNumLeft};
        sortedTransitFlux = sort(timeSeriesWithGaps(indexOfGiantTransitsInCorrWindow),'descend');
        distanceToTransit = (find(sortedTransitFlux <= timeSeriesWithGaps(leftOfi), 1, 'first')) - 1; % leftOfi is part of transit, distance to it shows up as 1; correct it to 0
        if isempty(distanceToTransit)
            isPartOfGiantTransit = false;
        elseif (distanceToTransit <= 2) 
            isPartOfGiantTransit = false;
        else
            isPartOfGiantTransit = true;
        end
    end

%else
%    indexOfAvailableInCorrWindow = indexOfNormal; % exclude samples part of giant transits
end;

return



%--------------------------------------------------------------------------
% sub function to compute lags
%--------------------------------------------------------------------------

function [lagIndices, lagsToKeep] = compute_lags(sampleIndex, indexOfAvailable, nTimeSteps)
lagIndices = indexOfAvailable - sampleIndex;
spanLeft = sum(nTimeSteps < sampleIndex);
spanRight = sum(nTimeSteps > sampleIndex);

%need special handling when the cadence being filled has no
%available samples to the left or right since it will not be
%included in the autocorrelation
if isequal(spanLeft,0)
    lagsToKeep = lagIndices < spanRight;
elseif isequal(spanRight,0)
    lagsToKeep = lagIndices > -spanLeft;
else
    lagsToKeep = lagIndices <= spanRight & lagIndices >= -spanLeft;
end

lagIndices = lagIndices( lagsToKeep );
lagIndices = lagIndices(:);
return








