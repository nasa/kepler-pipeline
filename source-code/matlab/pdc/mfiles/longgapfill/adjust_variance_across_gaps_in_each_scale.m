%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [reconstructedFilledTimeSeries, nScales] = ...
%     adjust_variance_across_gaps_in_each_scale(timeSeriesWithGapsFilled,gapLocations,scalingFilterCoefficients)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Description: 
%         This function fills the long data gaps in a non stationary time
%         series by 
%           (1) reflecting data segments on either side of the gap across
%           the gap 
%           (2) adjusting wavelet coefficients in each scale in such a way
%           that  the filled in data does not perturb the variance of each scale.
%
% Inputs: 
%       1. timeSeriesWithGapsFilled - time series with large data gaps
%          closed temporarily by reflecting data segments (on either side of
%          a gap) into the gaps
%       2. gapLocations - a 2-D array indicating the beginning and the
%          end of gaps locations
%       3. scalingFilterCoefficients - scaling filter coefficients (currently
%          using Daubechies 12 tap filter coefficients but could be any other)
% Output: 
%       1. reconstructedFilledTimeSeries -  time series obtained from the
%       input 'timeSeriesWithGapsFilled' after the following sequence of
%       operations:
%           (a) compute the OWT (wavelet coefficients at each scale) of
%           'timeSeriesWithGapsFilled'
%           (b) adjust the variance across the gaps in each scale using
%           linear tapers
%           (3) compute the time series using multiresolution analysis
%           (inverse OWT) of this adjusted wavelet coefficients
%       2. nScales - number of scales computed
%
% Note: 
%   This is not the final filled in time series as two more steps are necessary:
%   (a) giant transits, if any, must be added back
%   (b) samples from the original time series where data exists
%       must replace the filled in values. 
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
function [reconstructedFilledTimeSeries, nScales] = ...
    adjust_variance_across_gaps_in_each_scale(timeSeriesWithGapsFilled,gapLocations,...
    scalingFilterCoefficients)
    
nLength = length(timeSeriesWithGapsFilled);
filterLength = length(scalingFilterCoefficients);

% find out how many stages of filtering to do.
% for any signal that is band limited, there will be an upper nScales j = J,
% above which the wavelet coefficients are negligibly small
% nScales = log2(nLength)-floor(log2(filterLength))+1;

nScales = round(log2(nLength)-floor(log2(filterLength)));

% we only have to do all this stuff if there are actual gaps present

if ~isempty( gapLocations )  

    [waveletDetailCoefftsAtEachScale] = overcomplete_wavelet_transform( ...
        timeSeriesWithGapsFilled,scalingFilterCoefficients,nScales);

    % adjust the variance of the gaps to match the variances of the points at
    % the edges of the gaps, with a linear transition from one to the next

    varianceAdjustedWaveletDetailCoefftsAtEachScale = waveletDetailCoefftsAtEachScale;
    nGaps = length(gapLocations(:,1));
    gapLengths = gapLocations(:,2) - gapLocations(:,1)+ 1;



    % Q: At what nScales do we stop adjusting the variance across the gaps?
    % A: When the gap length exceeds the wavelet filter length at that nScales.

    filterLengthAtEachScale = filterLength*(2.^(0:nScales));
    minGapSize = min(abs(gapLocations(:,2)-gapLocations(:,1)));

    lastScaleFilterLengthIndex = find(filterLengthAtEachScale <= minGapSize, 1, 'last');
    lastScaleFilterLength = filterLengthAtEachScale(lastScaleFilterLengthIndex);
    stopScale = log2(lastScaleFilterLength/filterLength)+1;

    for j = 1:stopScale

        for i = 1:nGaps

            currentGapSize = gapLengths(i);


            iGapBegin = gapLocations(i,1);
            iGapEnd = gapLocations(i,2);

            % it is possible that this gap could be the first (or the last) in which case
            % there may not be enough points to compute the mean or the std
            % Use only the available points

            iLeftDataSegmentEnd = gapLocations(i,2)-1;

            iLeftDataSegmentBegin = max(gapLocations(i,1)-1- currentGapSize, 1);

            % for each gap, adjust the variances in each nScales
            leftSegmentMean = mean(...
                waveletDetailCoefftsAtEachScale(iLeftDataSegmentBegin:iLeftDataSegmentEnd, j) );
            leftSegmentStd = std(...
                waveletDetailCoefftsAtEachScale(iLeftDataSegmentBegin:iLeftDataSegmentEnd, j));

            iRightDataSegmentBegin = gapLocations(i,2)+1;

            % obtain the local variances of the wavelet coefficients in each
            % scale near the edges of a gap

            if(iRightDataSegmentBegin < nLength)

                iRightDataSegmentEnd = min(gapLocations(i,2)+1+ currentGapSize, nLength);

                rightSegmentMean = mean(waveletDetailCoefftsAtEachScale(...
                    iRightDataSegmentBegin:iRightDataSegmentEnd, j) );
                rightSegmentStd = std(...
                    waveletDetailCoefftsAtEachScale(iRightDataSegmentBegin:iRightDataSegmentEnd, j) );

                linearTaperStd = leftSegmentStd - ...
                    (leftSegmentStd - rightSegmentStd).*(0:currentGapSize)./currentGapSize;
                linearTaperMean = leftSegmentMean - ...
                    (leftSegmentMean - rightSegmentMean).*(0:currentGapSize)./currentGapSize;

                gapStd = std(waveletDetailCoefftsAtEachScale(iGapBegin:iGapEnd,j));

                filledGap = waveletDetailCoefftsAtEachScale(iGapBegin:iGapEnd,j); % get the 

                % the variances of the filled-in samples are adjusted to match the
                % variance of the samples at the edges of the gaps with a linear
                % taper
                varianceAdjustedGap = (linearTaperStd(2:end)./gapStd)'.*filledGap;

                varianceAdjustedGap = varianceAdjustedGap+linearTaperMean(2:end)';

            else % the last gap introduced to make signal length a power of 2 
                leftDataSegmentEnd = iGapBegin-1;
                leftDataSegmentBegin = leftDataSegmentEnd - currentGapSize + 1;
                varianceAdjustedGap = ...
                    waveletDetailCoefftsAtEachScale(leftDataSegmentBegin:leftDataSegmentEnd,j);
                %varianceAdjustedGap = flipud(varianceAdjustedGap);
            end;


            varianceAdjustedWaveletDetailCoefftsAtEachScale(iGapBegin:iGapEnd,j) = ...
                varianceAdjustedGap;
        end;

    end;

    % inverse wavelet transform to get the multi resolution time series
    [multiResolutionTimeSeries] = reconstruct_in_frequency_domain(...
        varianceAdjustedWaveletDetailCoefftsAtEachScale,scalingFilterCoefficients);


    % inverse wavelet transform to get the new gap filled time series
    % sum multi resolution time series (one time series /scale) to obtain
    % reconstructed time series
    reconstructedFilledTimeSeries = sum(multiResolutionTimeSeries,2);

else % no gaps, so prepare trivial return
    
    reconstructedFilledTimeSeries = timeSeriesWithGapsFilled ;

end

return;

