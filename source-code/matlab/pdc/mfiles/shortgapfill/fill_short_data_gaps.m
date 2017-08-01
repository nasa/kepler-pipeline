%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function  [timeSeriesWithGapsFilled,
% masterIndexOfAstroEvents,longDataGapIndicators, uncertaintiesWithGapsFilled] = ...
%     fill_short_data_gaps(timeSeriesWithGaps, dataGapIndicators, ...
%     indexOfAstroEvents, debugFlag, gapFillParametersStruct, uncertaintiesWithGaps )
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Description:
%         This function fills the short data gaps in a non stationary time
%         series using an AR Model for each segment of the time series
%         which is rendered stationary by detrending.
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
function  [timeSeriesWithGapsFilled, masterIndexOfAstroEvents,longDataGapIndicators, uncertaintiesWithGapsFilled] = ...
    fill_short_data_gaps(timeSeriesWithGaps, dataGapIndicators, indexOfAstroEvents, debugFlag, gapFillParametersStruct, uncertaintiesWithGaps )

% 'timeSeriesWithGaps' should be an evenly sampled sequence with
% missing values filled in with zeros.

% See if there are any huge outliers/astrophysical events present in the
% ancillary/flux time series
% These events, when present, perturb the autocorrelation to
% a great extent; if the data gaps are outside such a transit,
% autocorrelation will have to exclude such points; on the other hand, if
% the events themselves show data gaps, then these samples will not be
% excluded.
% In both cases, we do need to identify samples that are part of
% such astrophysical events

if(exist('uncertaintiesWithGaps', 'var') && isempty(uncertaintiesWithGaps))
    uncertaintiesWithGapsFilled = [];
else
    uncertaintiesWithGapsFilled = zeros(size(timeSeriesWithGaps)) ;
end

% if there are no gaps then dont waste time, just exit
if ~any(dataGapIndicators)
    timeSeriesWithGapsFilled = timeSeriesWithGaps;
    masterIndexOfAstroEvents = indexOfAstroEvents;
    longDataGapIndicators = dataGapIndicators;
    return;
end

if indexOfAstroEvents == 0
    [indexOfAstroEvents] = ...
        identify_astrophysical_events(timeSeriesWithGaps, dataGapIndicators, ...
        gapFillParametersStruct);
end



if(debugFlag)
    
    indexOfAvailable = find(~dataGapIndicators);
    plot(indexOfAvailable, timeSeriesWithGaps(indexOfAvailable),'b.-');
    hold on;
    plot(indexOfAstroEvents,timeSeriesWithGaps(indexOfAstroEvents),'mo');
    
end;

% gapSize - an array of length equal to the number of missing samples
% indicating the size of the data gap each missing sample is situated in.


[gapSize, dataBlockSize, gapLocations] = find_datagap_sizes(dataGapIndicators);


if(~isempty(indexOfAstroEvents))
    
    if(exist('uncertaintiesWithGaps', 'var') && ~isempty(uncertaintiesWithGaps))
        
        [timeSeriesWithGapsFilled, masterIndexOfAstroEvents,longDataGapIndicators, uncertaintiesWithGapsFilled] = ...
            fill_short_data_gaps_in_data_with_giant_transits(timeSeriesWithGaps,...
            dataGapIndicators,debugFlag, gapSize, gapLocations, indexOfAstroEvents, gapFillParametersStruct, uncertaintiesWithGaps);
        
    else
        
        [timeSeriesWithGapsFilled, masterIndexOfAstroEvents,longDataGapIndicators] = ...
            fill_short_data_gaps_in_data_with_giant_transits(timeSeriesWithGaps,...
            dataGapIndicators,debugFlag, gapSize, gapLocations, indexOfAstroEvents, gapFillParametersStruct);  
        
    end
    
else
    
    if(exist('uncertaintiesWithGaps', 'var') && ~isempty(uncertaintiesWithGaps))
        [timeSeriesWithGapsFilled, longDataGapIndicators, uncertaintiesWithGapsFilled] = ...
            fill_short_data_gaps_in_data_without_giant_transits(timeSeriesWithGaps,...
            dataGapIndicators,debugFlag,gapSize,gapLocations, gapFillParametersStruct, uncertaintiesWithGaps);
        
    else
        [timeSeriesWithGapsFilled, longDataGapIndicators] = ...
            fill_short_data_gaps_in_data_without_giant_transits(timeSeriesWithGaps,...
            dataGapIndicators,debugFlag,gapSize,gapLocations, gapFillParametersStruct);
        
    end
    
    masterIndexOfAstroEvents = indexOfAstroEvents;
  
end



return;


