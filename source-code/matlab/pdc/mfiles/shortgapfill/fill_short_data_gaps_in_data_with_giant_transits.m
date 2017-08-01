%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [timeSeriesWithGapsFilled, masterIndexOfGiantTransits,
% longDataGapIndicators, uncertaintiesWithGapsFilled] = ...
%     fill_short_data_gaps_in_data_with_giant_transits(timeSeriesWithGaps,...
%     dataGapIndicators,debugFlag, gapSize,gapLocations,indexOfGiantTransits,...
%     gapFillParametersStruct, uncertaintiesWithGaps)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% Description:
%      This function fills the data gaps in a non-stationary timeseries by
%      rendering the time series in the correlation window stationary and
%      fitting an AR model to it. This AR model either can be inferred from the
%      segmented timeseries by applying Akaike's finalPredictionError (final prediction
%      error criterion) or can be fed in as a parameter.
%
% Inputs:
%         1. timeSeriesWithGaps = time series with data gaps
%         2. dataGapIndicators = a logical array with 1's indicating data gaps and 0's
%            indicating available samples
%         3. debugFlag = flag to turn on plotting the data gaps as they are filled
%         4. gapSize - an array of length equal to the number of missing samples
%            indicating the size of the data gap each missing sample is situated in.
%         5. gapLocations - a matrix with two columns x number of data
%            gaps, indicating the beginning and the end of each gap
%         6. indexOfGiantTransits - an array containing indices of available samples
%            identified as part of giant transits
%         7. gapFillParametersStruct - a structure containing the following
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
%                 chunk length of the data when doing robust AI criteria and
%                 polynomial fitting in identify_giant_transits.m
%         8. uncertaintiesWithGaps - a time series of uncertainties
%                associated with each sample, with zeros where no samples exist
% Output:
%         1. timeSeriesWithGapsFilled - time series where data gaps have been
%            filled with estimated samples
%         2. masterIndexOfGiantTransits - indices of samples identified as
%            part of giant transits
%         3. longDataGapIndicators - a logical array with 1's indicating
%            long data gaps that were left unfilled and 0's indicating available samples
%         4. uncertaintiesWithGapsFilled - time series of uncertainties
%            where filled-in samples also have uncertainties associated
%            with them
%
%  Note:
%     The elaborate logic used in this script is necessary to avoid the
%     ringing artifact (Gibb's oscillations - overshoot followed by
%     undershoot) introduced by the gap filling AR algorithm.  This ringing
%     occurs under the following conditions:
%       (1) a gap in the vicinity of a giant transit
%       (2) correlation window contains one or more  giant transits
%     Modify the logic only after understanding it completely. This function
%     is thoroughly  tested.
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
function [timeSeriesWithGapsFilled, masterIndexOfGiantTransits, longDataGapIndicators, uncertaintiesWithGapsFilled] = ...
    fill_short_data_gaps_in_data_with_giant_transits(timeSeriesWithGaps,...
    dataGapIndicators,debugFlag, gapSize,gapLocations,indexOfGiantTransits, gapFillParametersStruct, uncertaintiesWithGaps)

%--------------------------------------------------------------------------
% CONSTANTS USED
%--------------------------------------------------------------------------
maxArOrderLimit = gapFillParametersStruct.maxArOrderLimit; %% max AR model order limit set for choose_fpe_model_order function.

% samples in giant transit are excluded for filling in normal missing points, so don't change this
maxCorrelationWindowLimit = (gapFillParametersStruct.maxCorrelationWindowXFactor)*maxArOrderLimit;
maxDetrendPolyOrder = gapFillParametersStruct.maxDetrendPolyOrder;

% to add abck prediction error to the estimated sample or not
gapFillModeIsAddBackPredictionError = gapFillParametersStruct.gapFillModeIsAddBackPredictionError;


%--------------------------------------------------------------------------

indexAvailable = find(~dataGapIndicators); % index of available points

indexUnavailable = find(dataGapIndicators); % index of not available points

% if there are no gaps, return input back
if(exist('uncertaintiesWithGaps', 'var'))
    uncertaintiesWithGapsFilled =  uncertaintiesWithGaps;
else
    uncertaintiesWithGapsFilled = zeros(size(timeSeriesWithGaps)) ;
end

if(isempty(indexUnavailable))
    timeSeriesWithGapsFilled = timeSeriesWithGaps;
    masterIndexOfGiantTransits = indexOfGiantTransits;
    longDataGapIndicators = dataGapIndicators;

    return

end




numberOfMissingSamples = length(indexUnavailable); % total number of missing samples

iCount = 0; % counter keeping track of how many missing samples have been filled so far

% if there is a data gap in the very beginning, it makes sense to fill the
% missing samples that are far from the beginning (closer to existing
% samples) first; so reverse the missing samples fill order for the first
% gap
endSamples = zeros(length(indexUnavailable),1);
if(gapLocations(1,1) == 1) % there is a gap in the beginning
    % reverse the indexUnavailable order in the first gap
    sizeOfFirstGap = gapSize(1);
    indexUnavailable(1:sizeOfFirstGap) = flipud(indexUnavailable(1:sizeOfFirstGap));

    endSamples(1:sizeOfFirstGap) = indexUnavailable(1:sizeOfFirstGap);
    % collect first gap and last gap missing samples (extrapolation)
end
if(gapLocations(end,2) == length(timeSeriesWithGaps)) % there is a gap in the beginning
    % reverse the indexUnavailable order in the first gap
    sizeOfLastGap = gapSize(end);
    startIndex = find(endSamples==0, 1, 'first');

    endSamples(startIndex:startIndex+sizeOfLastGap-1) = indexUnavailable(end - sizeOfLastGap +1 :end);
    % collect first gap and last gap missing samples (extrapolation)
end
startIndex = find(endSamples==0, 1, 'first');
endSamples(startIndex:end) = [];


nLength = length(timeSeriesWithGaps);

masterIndexOfGiantTransits = indexOfGiantTransits; % initial list of samples in the giant transits


for i = indexUnavailable(:)'

    iCount = iCount+1;
    % do not fill the data gap if gap size is long (i.e., >= maxCorrelationWindowLimit)
    if(gapSize(iCount) >= maxCorrelationWindowLimit)
        continue;
    end;

    % normally correlationWindowLength need only be as long as the AR model
    % order chosen. The problem here is, we estimate model order for a
    % section of the time series around the missing sample - so we do need
    % to set a value here which will determine length of the segment around
    % the missing sample; this segment gets detrended to produce a
    % staionary segment (assuming there is no regime change in the segment
    % - i.e., drastic change in the variance)
    correlationWindowLength = max(2*gapSize(iCount),maxCorrelationWindowLimit);


    % set up flags for this missing sample
    isPartOfGiantTransit = false;
    isMiddleOfGiantTransit = false;


    % get the distance of the missing point from all available points
    ithDistanceFromAvailableSamples = abs(indexAvailable-i);


    % collect indices of available points that are within the correlation window
    % correlation window should be bigger than the fill data window
    indexOfAvailableInCorrWindow = find(ithDistanceFromAvailableSamples <= correlationWindowLength);

    % enlarge the correlation window if indexOfAvailableInCorrWindow
    % is empty for the current window size
    iAttempt = 1;
    while (isempty(indexOfAvailableInCorrWindow) && iAttempt < 5)
        iAttempt = iAttempt+1;
        indexOfAvailableInCorrWindow = find(ithDistanceFromAvailableSamples <= iAttempt*correlationWindowLength);
    end;

    % do not fill the data gap if there is only one sample in the
    % correlation window or none at all
    if(isempty(indexOfAvailableInCorrWindow) || length(indexOfAvailableInCorrWindow) <= 3)
        continue;
    end;

    % convert 'indexOfAvailableInCorrWindow' which refers to available
    % samples to actual sample indices
    % for examples, say actual sample indices are [1 2 3 4 5 6 7 8 9 10]
    % available samples are [1 2 5 6 8 9]
    % 'indexOfAvailableInCorrWindow' indicates that indices [1 2 3 4 ] in the available
    % sample are in the correlation window
    % converting this reference to original sample index, will lead to
    % [1 2 5 6] being in the correlation window

    % convert to original sample indices from indices referring to
    % available samples only

    indexOfAvailableInCorrWindow = indexAvailable(indexOfAvailableInCorrWindow);

    % see if there any big transits in the correlation window
    indexOfGiantTransitsInCorrWindow = intersect(indexOfAvailableInCorrWindow, masterIndexOfGiantTransits);


    % see if the missing sample 'i' is in the middle of a transit or
    % contains a transit on its left or right side
    if(~isempty(indexOfGiantTransitsInCorrWindow))
        indexOfNormal = setxor(indexOfAvailableInCorrWindow, indexOfGiantTransitsInCorrWindow);
        leftOfi = i -1;
        rightOfIndex = find(indexOfAvailableInCorrWindow > i, 1, 'first');
        if(~isempty(rightOfIndex))
            rightOfi = indexOfAvailableInCorrWindow(rightOfIndex);
        else
            rightOfi = -1;
        end;

        if((ismember(leftOfi, indexOfGiantTransitsInCorrWindow) || ismember(rightOfi, indexOfGiantTransitsInCorrWindow)))

            sortedTransitFlux = sort(timeSeriesWithGaps(indexOfGiantTransitsInCorrWindow),'descend');

            % decide whether the sample i is in the middle of the
            % transit or descends into a transit on the left/right side
            if((ismember(leftOfi, indexOfGiantTransitsInCorrWindow) && ismember(rightOfi, indexOfGiantTransitsInCorrWindow)))

                isMiddleOfGiantTransit = true;
                isPartOfGiantTransit = true;

            elseif( (ismember(rightOfi, indexOfGiantTransitsInCorrWindow)) && (~ismember(leftOfi, indexOfGiantTransitsInCorrWindow)))
                distanceToTransit = (find(sortedTransitFlux <= timeSeriesWithGaps(rightOfi), 1, 'first'));
                if(isempty(distanceToTransit))
                    indexOfAvailableInCorrWindow = indexOfNormal; % exclude samples part of giant transits
                    isPartOfGiantTransit = false;
                else
                    if((rightOfi - i) > distanceToTransit)
                        indexOfAvailableInCorrWindow = indexOfNormal; % exclude samples part of giant transits
                        isPartOfGiantTransit = false;
                    else
                        isPartOfGiantTransit = true;
                    end;
                end

            elseif( (ismember(leftOfi, indexOfGiantTransitsInCorrWindow)) && (~ismember(rightOfi, indexOfGiantTransitsInCorrWindow)) )

                distanceToTransit = (find(sortedTransitFlux <= timeSeriesWithGaps(leftOfi), 1, 'first')) - 1; % leftOfi is part of transit, distance to it shows up as 1; correct it to 0

                if(isempty(distanceToTransit))
                    indexOfAvailableInCorrWindow = indexOfNormal; % exclude samples part of giant transits
                    isPartOfGiantTransit = false;
                else
                    % the previous sample is at a distance of 1 from normal

                    if(distanceToTransit <= 1)
                        indexOfAvailableInCorrWindow = sort([leftOfi; indexOfNormal]); % exclude samples part of giant transits
                        isPartOfGiantTransit = false;
                    else
                        isPartOfGiantTransit = true;
                    end;


                end;

            end;

        else
            indexOfAvailableInCorrWindow = indexOfNormal; % exclude samples part of giant transits
        end;
    end;

    % do not fill the data gap if there is only one sample in the
    % correlation window or none at all
    if(isempty(indexOfAvailableInCorrWindow) )

        continue;

    elseif (length(indexOfAvailableInCorrWindow) <= 3)

        % compute the max. distance of the availble samples from the
        % missing sample as we linearly interpolate
        % get the distance of the missing point from all available points


        greatestDistance = max(abs(indexOfAvailableInCorrWindow-i));
        if((gapSize(iCount) <= 3) && greatestDistance <= 5) % and if the available samples are within gap size distance

            if(length(indexOfAvailableInCorrWindow) >= 2)
                timeSeriesWithGaps(i) = interp1(indexOfAvailableInCorrWindow, timeSeriesWithGaps(indexOfAvailableInCorrWindow), i, 'linear', 'extrap');
            else
                timeSeriesWithGaps(i) = timeSeriesWithGaps(indexOfAvailableInCorrWindow);
            end

            % make the just estimated point available
            % if there is a long data gap to the left of i, then it would still be
            % a data gap ( can't assume all the gaps to the left have been filled)
            indexAvailable = sort([indexAvailable;i]);

            indexUnavailable  =  setxor(indexUnavailable,i); % remove the just estimated point from 'not available'
            continue;

        else
            continue;
        end

    end;


    nTimeSteps = (min(indexOfAvailableInCorrWindow):max(indexOfAvailableInCorrWindow))';

    timeSeriesWithGapInCorrWindow = timeSeriesWithGaps(nTimeSteps);

    % fit trend for 'nTimeSteps' from data available for
    % indexOfAvailableInCorrWindow only
    %     [fittedTrend, fittedPolyOrder,polynomialCoefficients, structureS, scalingCenteringMu]  = ...
    %         fit_trend(nTimeSteps, indexOfAvailableInCorrWindow,  timeSeriesWithGaps(indexOfAvailableInCorrWindow),  maxDetrendPolyOrder);


    % check to see whether this 'i' is part of the first gap or last gap -
    % involves extrapolation
    if(ismember(i,endSamples))

        [fittedTrend, fittedPolyOrder,polynomialCoefficients, structureS, scalingCenteringMu]  = ...
            fit_trend(nTimeSteps, indexOfAvailableInCorrWindow,  timeSeriesWithGaps,  maxDetrendPolyOrder);
    else
        % alternate way of determining the fit using discrete orthogonal
        % Legendre polynomials
        [fittedTrend, fittedPolyOrder, polynomialCoefficients ] = ...
            fit_trend_using_DOLP_over_sample_points(nTimeSteps, indexOfAvailableInCorrWindow,  timeSeriesWithGaps(indexOfAvailableInCorrWindow),  maxDetrendPolyOrder);
    end

    % remove trend and obtain residuals which are  ~ stationary
    timeSeriesWithGapInCorrWindow = timeSeriesWithGapInCorrWindow - fittedTrend;

    % gaps still remain at 0
    [indexToIgnore, ia ] = setxor(nTimeSteps,indexOfAvailableInCorrWindow);
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
    inputTimeSeries = timeSeriesWithGapInCorrWindow;
    maxAROrder =  min(fix(length(inputTimeSeries)/2),maxArOrderLimit);

    % finalPredictionError(p) is the variance estimate of the white noise
    % input to the AR model of order p
    [modelOrderAR, finalPredictionError] = choose_fpe_model_order( inputTimeSeries,maxAROrder); % finalPredictionError is an array


    % collect indices of availble samples in the AR model order size window
    indexOfAvailableInARWindow0 = find(ithDistanceFromAvailableSamples <= modelOrderAR & ithDistanceFromAvailableSamples >= 1);

    jAttempt = 1;
    while true % this loop prevents indexOfAvailableInARWindow from ever being empty

        % enlarge the modelOrderAR window if indexOfAvailableInARWindow0
        % is empty for the current modelOrderAR size
        while (isempty(indexOfAvailableInARWindow0))
            jAttempt = jAttempt+1;
            indexOfAvailableInARWindow0 = find(ithDistanceFromAvailableSamples <= jAttempt*modelOrderAR & ithDistanceFromAvailableSamples >= 1);
        end;

        indexOfAvailableInARWindow1 = indexAvailable(indexOfAvailableInARWindow0); % collect index of available samples in the fill window

        % may have to exclude samples that are part of giant transits
        [indexOfAvailableInARWindow] = intersect(indexOfAvailableInCorrWindow, indexOfAvailableInARWindow1);

        if(~isempty(indexOfAvailableInARWindow))
            break;
        else
            indexOfAvailableInARWindow0 = [];
        end;
    end;

    % T = toeplitz(r) returns the symmetric or Hermitian Toeplitz matrix
    % formed from vector r, where r defines the first row of the matrix.
    % remember that the correlation matrix for any stationary random
    % process is always a symmetric toeplitz matrix and is completely
    % defined by the correlation function (here by r) for the process
    R = toeplitz(r(1:min(2*jAttempt*modelOrderAR+1,length(r))));

    % collect all the samples that are within length(r) on either side of
    % the missing sample 'i'
    indexOfAvailableInARWindow = indexOfAvailableInARWindow(abs(indexOfAvailableInARWindow-i) < length(r));

    % there is a very weird corner case in which the line above does not find any valid
    % values for indexOfAvailableInARWindow, and the subsequent logic fails.  In this
    % case, use fit_trend to handle the correction
    
    if isempty( indexOfAvailableInARWindow )
        
        [fittedTrend, fittedPolyOrder,polynomialCoefficients, structureS, scalingCenteringMu]  = ...
            fit_trend(nTimeSteps, indexOfAvailableInCorrWindow,  timeSeriesWithGaps,  maxDetrendPolyOrder);
        finalPredictionError = 0 ;
        trendValueAtUnavailableSample = polyval(polynomialCoefficients, i, structureS, scalingCenteringMu);
    else       
    
        [iValues, indexInTimeSteps] = intersect(nTimeSteps, indexOfAvailableInARWindow); % 'indexInTimeSteps' locates 'indexOfAvailableInARWindow' in  'nTimeSteps'

        [jValues, iInTimeSteps] = intersect(nTimeSteps, i); % 'iInTimeSteps' locates 'i' in 'nTimeSteps'

        % compute the lags of samples in the window from 'i'
        iLags = abs(indexOfAvailableInARWindow-i)+1;

        % form a subset of correlation vector; note that samples that are at
        % the same distance on either side of 'i' have the same lags and the
        % correlation function is symmetric
        ri = r(iLags);

        % convert indices to lags so we can refer to columns and rows of R
        jLags = indexOfAvailableInARWindow-indexOfAvailableInARWindow(1)+1;

        Ri=R(:,jLags); % remove columns corresponding to missing samples
        Ri=Ri(jLags,:); % remove rows corresponding to missing samples

    %     if(any(isnan(R(:))))
    %         fprintf('Nans in R...\n');
    %     end

        a = Ri\ri; % solve for AR parameters from the equation Ri*a = ri

        if(any(isnan(a(:)))) % check for NaNs

            [fittedTrend, fittedPolyOrder,polynomialCoefficients, structureS, scalingCenteringMu]  = ...
                fit_trend(nTimeSteps, indexOfAvailableInCorrWindow,  timeSeriesWithGaps,  maxDetrendPolyOrder);
            if exist( 'uncertaintiesWithGapsFilled', 'var' ) && ~isempty( uncertaintiesWithGapsFilled )
                finalPredictionError = uncertaintiesWithGapsFilled(indexOfAvailableInARWindow) .^ 2;
            else
                finalPredictionError = zeros( size( indexOfAvailableInARWindow ) ) ;
            end

            trendValueAtUnavailableSample = polyval(polynomialCoefficients, i, structureS, scalingCenteringMu);

        else % valid a, so proceed


            % most of the time missing sample 'i' is flanked by available samples -
            % in which case we can get the trend value at 'i' by looking up the
            % correct index in 'fittedTrend'
            if(~isempty(iInTimeSteps))
                trendValueAtUnavailableSample = fittedTrend(iInTimeSteps);
            else
                % but some times if 'i' is at the very beginning or end,
                % 'fittedTrend' has to be extrapolated just 1 step ahead/behind
                % since 'fittedTrend' will not include 'i'  - so use polyval
                % instead

                [fittedTrend, fittedPolyOrder,polynomialCoefficients, structureS, scalingCenteringMu]  = ...
                    fit_trend(nTimeSteps, indexOfAvailableInCorrWindow,  timeSeriesWithGaps,  maxDetrendPolyOrder);

                trendValueAtUnavailableSample = polyval(polynomialCoefficients, i, structureS, scalingCenteringMu);

            end;



            timeSeriesWithGaps(i) = a'*(timeSeriesWithGaps(indexOfAvailableInARWindow)- fittedTrend(indexInTimeSteps));% first step, estimate as weighted sum of residuals
        end

    end
    
    % let uncertainty in filled sample equal the rms uncertainty of samples
    % used to fill gap
    if(exist('uncertaintiesWithGaps', 'var'))
        %uncertaintiesWithGapsFilled(i) = ...
        %    sqrt(a' .^ 2 * uncertaintiesWithGapsFilled(indexOfAvailableInARWindow) .^ 2);
        uncertaintiesWithGapsFilled(i) = sqrt(mean(uncertaintiesWithGapsFilled(indexOfAvailableInARWindow) .^ 2));
    end


    if(gapFillModeIsAddBackPredictionError) % add prediction error back into the estimated sample - this maintains the noise variance across the gap
        whiteGaussianNoiseSample = max(min(randn(1,1),3), -3);
        timeSeriesWithGaps(i) = timeSeriesWithGaps(i)  + trendValueAtUnavailableSample + sqrt(min(finalPredictionError))*whiteGaussianNoiseSample; % add back trend
    else  % just estimate, do not add back prediction error
        timeSeriesWithGaps(i) = timeSeriesWithGaps(i)  + trendValueAtUnavailableSample; % add back trend
    end




    if debugFlag,
        %% plot points in the correlation window and the just filled in point
        plot(indexOfAvailableInCorrWindow,timeSeriesWithGaps(indexOfAvailableInCorrWindow),'bx-',nTimeSteps,fittedTrend, 'g.-', i,timeSeriesWithGaps(i),'rp-');
        ylim([min(timeSeriesWithGaps(indexOfAvailableInCorrWindow)),max(timeSeriesWithGaps(indexOfAvailableInCorrWindow))])
        title([int2str(iCount),'/',int2str(numberOfMissingSamples)])
        drawnow
        %%
    end

    % make the just estimated point available
    % if there is a long data gap to the left of i, then it would still be
    % a data gap ( can't assume all the gaps to the left have been filled)
    indexAvailable = sort([indexAvailable;i]);

    indexUnavailable  =  setxor(indexUnavailable,i); % remove the just estimated point from 'not available'

    % decide whether to include this sample as part of the giant transit or
    % not
    if(isPartOfGiantTransit)
        if(isMiddleOfGiantTransit)
            masterIndexOfGiantTransits = sort( [masterIndexOfGiantTransits; i]);
% Comment this clause out. The added calls to identify_giant_transits are
% excessive and very slow, and the value added based on analysis of Q2/Q3
% light curves is questionable.
%         else
%             currentDataGaps = false(nLength,1);
%             indexOfDataGaps = indexUnavailable(indexUnavailable > i);
%             currentDataGaps(indexOfDataGaps) = true;
%             indexOfNewGiantTransits = ...
%                 identify_astrophysical_events(timeSeriesWithGaps,...
%                 currentDataGaps,gapFillParametersStruct);
%             masterIndexOfGiantTransits = unique([masterIndexOfGiantTransits; indexOfNewGiantTransits]);
        end;
    end;
end

timeSeriesWithGapsFilled = timeSeriesWithGaps;

longDataGapIndicators = false(size(dataGapIndicators));

% see if 'indexUnavailable' is empty; if it is not empty, unfilled cadences
% form one or more long gaps; mark those gaps in 'longDataGapIndicators'
if(~isempty(indexUnavailable))
    longDataGapIndicators(indexUnavailable) = true;
end;

return
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


