function timeSeries = simple_fill_data_gaps(timeSeries, gapList, minWidth, maxWidth, order, edgeBuffer)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function timeSeries = simple_fill_data_gaps(timeSeries, gapList, minWidth, ...
%       maxWidth, order, edgeBuffer)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% Fill data gaps via a local weighted least-squares polynomial
% interpolation.  Data ingaps are given zero weight.
% Fit at edges by reflecting the data across edges so that the first
% derivatives are approximately continuous.
% 
% inputs:
%   timeSeries: column vector of data
%   gapList: list of indices into timeSeries giving location of gaps
%   minWidth: smallest half-width of window around gap location to build polynomial
%   maxWidth: largest half-width of window around gap location to build polynomial
%   order: order of polynomial fit
%   edgeBuffer: number of points on either end to use to compute mean value
%       at boudary when reflecting the data
%
% width = 5, order = 5, edgeBuffer = 5 seems to work well in the presence 
%   of large transits.
%
%   timeSeries: column vector of data with gaps filled
%
%
% 
% Copyright 2017 United States Government as represented by the
% Administrator of the National Aeronautics and Space Administration.
% All Rights Reserved.
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

debugDisplay = 0;

% encode the gaps in data weights
weights = ones(size(timeSeries));
weights(gapList) = 0;

% extend data across boundaries via reflection so that first derivatives
% are continuous, same for weights

N = length(timeSeries);
% define storage large enough to hold timeSeries plus maxWidth on either side
extendedSeries = zeros(N + 2*maxWidth, 1);
extendedWeights = zeros(N + 2*maxWidth, 1);
% left-side reflection based on mean at left boundary
% we need to compute this mean using non-gap values
% create vector of valid values
noGapSeries = timeSeries(weights  == 1);
% which is shorter than input vector
noGapLength = length(noGapSeries);
% use the edgeBuffer # of valid values on either end to compute the mean
extendedSeries(1:maxWidth) = 2*mean(noGapSeries(1:edgeBuffer)) - timeSeries(maxWidth+1:-1:2);
extendedWeights(1:maxWidth) = weights(maxWidth+1:-1:2);
% fill in the interior data
extendedSeries(maxWidth+1:maxWidth+N) = timeSeries;
extendedWeights(maxWidth+1:maxWidth+N) = weights;
% right-side reflection based on mean at right boundary
extendedSeries(maxWidth+N+1:2*maxWidth+N) = ...
    2*mean(noGapSeries(noGapLength-edgeBuffer:noGapLength)) - timeSeries(N-1:-1:N-maxWidth);
extendedWeights(maxWidth+N+1:2*maxWidth+N) = weights(N-1:-1:N-maxWidth);

% for each gap in the gap list
for gap=1:length(gapList)
    % get index of current gap in extendedSeries coordinates
    gapIndex = gapList(gap) + maxWidth;
    % look for a window size such that we have at least order non-gap data
    % points on each side by extending the width from minWidth to maxWidth
    width = minWidth;
    orderToUse = order;
    while sum(extendedWeights(gapIndex - width : gapIndex)) < 2*order || ...
            sum(extendedWeights(gapIndex : gapIndex + width)) < 2*order 
        if width == maxWidth
            if debugDisplay
                warning('PA:simple_fill_data_gaps:gap too large, doing the best I can');
            end
            orderToUse = min(sum(extendedWeights(gapIndex - width : gapIndex)), ...
                sum(extendedWeights(gapIndex : gapIndex + width)));
            break;
        end
        width = width + 1;
    end
    % extract data from extendedSeries in interval 
    % [gapIndex - width, gapIndex + width]
    dataInterval = gapIndex - width : gapIndex + width;
    % extract data from extendedSeries in interval 
    % [gapIndex - width, gapIndex + width]
    data = extendedSeries(dataInterval);
    w = extendedWeights(dataInterval);
    % perform least-squares fit
    c = weighted_polyfit(dataInterval, data, w, orderToUse);
    % evaluate fit at gap location
    timeSeries(gapList(gap)) = weighted_polyval(gapIndex, c);
end