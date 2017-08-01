%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [reconstructedFilledTimeSeries,
% varianceAdjustedWaveletDetailCoefftsAtEachScale, uncertaintiesWithGapsFilled] = ...
% fill_long_data_gaps(timeSeriesWithGaps, longDataGapIndicators, ...
% indexOfAstroEvents, debugFlag, gapFillParametersStruct, ...
% powerOfTwoLengthFlag, uncertaintiesWithGaps)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Description:
%         This function fills the long data gaps in a non stationary time
%         series by
%           (0) checking for the presence of astrophysical events in the time
%           series
%               (a) if there are any, treating them as short data gaps and
%               filling them using fill_short_data_gaps
%           (1) reflecting data segments on either side of the gap across
%           the gap (for each gap)
%           (2) adjusting wavelet coefficients in each scale in such a way
%           that  the filled in data do not perturb the variance of each scale.
%           (3) reconstructing the timeseries from the adjusted wavelet
%           coefficients and completing the following step:
%               (b) keep only the filled in values for the gaps; replace rest of
%               the samples (where data exist) with their original data.
%
% Inputs:
%         1. timeSeriesWithGaps - time series into which data gaps have been introduced-
%         2. longDataGapIndicators - a logical array with 1's indicating data gaps and 0's
%            indicating available samples
%         3. IndexOfAstroEvents - cadences identified previously as being
%            part of an astrophysical event.  If it is set to zero then the
%            identification will be done internally to this function.  If
%            it is empty then no cadences will be interpolated over prior
%            to long gap filling.
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
%               allows this short gap fill agorithm act in two modes
%               (1) estimation of missing values using AR model prediction
%               (2) estimation of missing values + prediction errors - this
%               allows each wavelet scale to maintain noise variance across
%               the gaps when missing values are filled in
%                 Second mode is useful for transit detection algorithm
%                 which forms detection statistics in the wavelet domain
%                 and the algorithm is sensitive to discontinuities in the
%                 wavelet scales (if missing values are estimated over a
%                 gap, and the filled in time series is wavelet transormed,
%                 the same gap appears to have zero variance in each scale)
%            waveletFamily = 'daub' % family for generation of scaling filter
%            waveletFilterLength = 12 % number of scaling filter coefficients
%            giantTransitPolyFitChunkLengthInHours = 72 % controls the
%                 chunk length of the data when doing robust AI criteria and
%                 polynomial fitting in identify_giant_transits.m
%         6. powerOfTwoLengthFlag - a boolean when set the returned time
%             series is guaranteed to have a length which is a power of 2.
%             The length between incoming time series and the closest next
%             power of 2 length is treated as a long gap and filled by this
%             algorithm
%         7. uncertaintiesWithGaps - optional uncertainties in time
%             series with gaps
%
% Output:
%         1. reconstructedFilledTimeSeries - time series where data gaps have been
%            filled with estimated samples
%         2. varianceAdjustedWaveletDetailCoefftsAtEachScale -
%            wavelet coefficients of 'reconstructedFilledTimeSeries'
%         3. uncertainties with gaps filled - uncertainties in time series
%            with gaps filled if uncertaintiesWithGaps is provided; the
%            uncertainties are not computed for long gap filled samples,
%            but set to a specific value
%
% References:
%   [1] KADN-26068 Long data gap fill algorithm
%   [2]	J. Jenkins, "The Impact of Solar-like variability on the
%   Detectability of Transiting terrestrial Planets," The Astrophysical
%   Journal, Vol. 575, No. 1, Part 1, August 2002, pages 493 -505.
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

function  [reconstructedFilledTimeSeries, ...
    varianceAdjustedWaveletDetailCoefftsAtEachScale, uncertaintiesWithGapsFilled] = ...
    fill_long_data_gaps(timeSeriesWithGaps, longDataGapIndicators, indexOfAstroEvents, ...
    debugFlag, gapFillParametersStruct, powerOfTwoLengthFlag, uncertaintiesWithGaps)


if(exist('uncertaintiesWithGaps', 'var') && isempty(uncertaintiesWithGaps))
    uncertaintiesWithGapsFilled = [];
else
    uncertaintiesWithGapsFilled = zeros(size(timeSeriesWithGaps)) ;
end

% if there are no gaps just exit
if ~any(longDataGapIndicators)
    reconstructedFilledTimeSeries = timeSeriesWithGaps;
    varianceAdjustedWaveletDetailCoefftsAtEachScale = [];
    return;
end

% set uncertainty for long gap filled samples
uncertaintyForLongGapFilledSamples = -1;

% generate scaling filter coefficients
waveletFamily = gapFillParametersStruct.waveletFamily;
waveletFilterLength = gapFillParametersStruct.waveletFilterLength;

if strcmpi(waveletFamily, 'daub')
    scalingFilterCoefficients = ...
        daubechies_low_pass_scaling_filter(waveletFilterLength);
else
    error('PDC:fillLongDataGaps:unsupportedWaveletFamily', ...
        '%s is unsupported wavelet family', waveletFamily)
end

% 'timeSeriesWithGaps' should be an evenly sampled sequence with
% missing values filled in with zeros.
maxDetrendPolyOrder = gapFillParametersStruct.maxDetrendPolyOrder;


% Definition of 'long data gaps': Those gaps that were left unfilled by
% the short data gap fill algorithm. Short gap fill does not fill the data
% gap if gap size is longer than 'maxCorrelationWindowLimit')

%-------------------------------------------------------------------------
% Step 1: Identify samples that are part of such astrophysical events
%--------------------------------------------------------------------------

indexAvailable = find(~longDataGapIndicators);
timeSeriesWithGapsSaved = timeSeriesWithGaps;
if indexOfAstroEvents == 0
    [indexOfAstroEvents] = identify_astrophysical_events(timeSeriesWithGaps, ...
        longDataGapIndicators, gapFillParametersStruct);
end

if(debugFlag)
    
    indexOfAvailable = find(~longDataGapIndicators);
    plot(indexOfAvailable, timeSeriesWithGaps(indexOfAvailable), 'b.-');
    hold on;
    plot(indexOfAstroEvents, timeSeriesWithGaps(indexOfAstroEvents), 'mo');
    
    
end;

if(~isempty(indexOfAstroEvents))
    
    %-------------------------------------------------------------------------
    % Step 2: Treat samples that are part of such astro events as short
    % data gaps, and fill them temporarily as otherwise they may get folded
    % into the long data gaps. Make sure not to use values in existing long
    % gap(s) for the temporary filling.
    %--------------------------------------------------------------------------
    
    newGapIndicators = longDataGapIndicators;
    newGapIndicators(indexOfAstroEvents) = true;
    indexOfAstroEvents = [];
    timeSeriesWithGaps = fill_short_data_gaps(timeSeriesWithGaps, newGapIndicators, ...
        indexOfAstroEvents, debugFlag, gapFillParametersStruct);
        
end
        
%-------------------------------------------------------------------------
% Step 3: reflect segments from either side of the gap into the gap
%--------------------------------------------------------------------------

[timeSeriesWithGapsFilled, gapLocations] = ...
    fill_long_gap_iteratively_reflecting_segments_into_gap(timeSeriesWithGaps, ...
    longDataGapIndicators, maxDetrendPolyOrder, debugFlag);


%-------------------------------------------------------------------------
% Step 4: adjust the variances of the filled-in samples to match the
% variance of the samples at the edges of the gaps with a linear taper
%--------------------------------------------------------------------------

[reconstructedFilledTimeSeries, nScales] = ...
    adjust_variance_across_gaps_in_each_scale(timeSeriesWithGapsFilled, ...
    gapLocations, scalingFilterCoefficients);
    


%-------------------------------------------------------------------------
% Step 5: set the uncertainties for the long gap filled samples
%-------------------------------------------------------------------------

if(exist('uncertaintiesWithGaps', 'var') && ~isempty(uncertaintiesWithGaps))
    
    uncertaintiesWithGapsFilled = uncertaintiesWithGaps;
    uncertaintiesWithGapsFilled(longDataGapIndicators) = ...
        uncertaintyForLongGapFilledSamples;
end


%-------------------------------------------------------------------------
% Step 6: restore the available samples to the
% 'reconstructedFilledTimeSeries' - which now contains original samples +
% filled in samples in gaps
% This step insert astro events identified in Step 1 back into the time series
%--------------------------------------------------------------------------

reconstructedFilledTimeSeries(indexAvailable) = timeSeriesWithGapsSaved(indexAvailable);
[varianceAdjustedWaveletDetailCoefftsAtEachScale] = ...
    overcomplete_wavelet_transform(reconstructedFilledTimeSeries, ...
    scalingFilterCoefficients, nScales);

if(~powerOfTwoLengthFlag)
    nLength = length(longDataGapIndicators);
    reconstructedFilledTimeSeries = reconstructedFilledTimeSeries(1:nLength);
    varianceAdjustedWaveletDetailCoefftsAtEachScale = ...
        varianceAdjustedWaveletDetailCoefftsAtEachScale(1:nLength , :);
end

return;
