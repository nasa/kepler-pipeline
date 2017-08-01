function partition = partition_by_curvature(timeSeries, order, window, ...
    threshold, smallestRegion)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function partition = partition_by_curvature(timeSeries, order, window, threshold)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% Partition a time series into parts that are well-modeled by low-order
% polynomials.  Partition is performed at locations of maximal negative
% curvature, which is appropriate to partitioning planetary transits.
%
% More precisely, the partitions are place at the midpoint of a region in
% which the curvature is below a threshold multiple of the curvature
% median.  This assumes the regions of high negative curvature are isolated
% and have slowly varying curvature.  This property is satisfied by
% transits.
%
% inputs: 
%   timeSeries() # of cadences x 1 array containing pixel brightness
%       time series.  Gaps are assumed to have been filled
%   order order of the local polynomial used to estimate curvature
%   window size of window in which to fit the polynomial used to estimate
%       curvature
%   threshold threshold value that multiplies the median curvature to
%   identify regions of high negative curvature.  Partitions are placed at
%   the midpoint of each of these regions.
%
% output: 
%   partition() # of parts x 1 array of structures describing the partitioning
%       of the target's flux time series into sections which are
%       well-described by low-order polynomials.  The fields of this
%       structure are:
%       .start, .end the start and end indices of each partition
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

% flag to indicate display of local results
display = 0;

% estimate the curvature as the second derivative of a locally fitted
% polynomial via the fast local polyfit (which cannot be weighted).
% the parameter "3" requests the local second derivative
secondDeriv = fast_local_polyfit(timeSeries, order, window, 3)';
% find the regions in which the local second derivative is below the
% threshold times the median of the input series
minSecondDeriv = find(secondDeriv < -threshold*median(abs(secondDeriv)));

% do the actual partition here
% initialize the number of parts to 1, since if there is no partitioning,
% the returned partition is the entire time series
nParts = 1;
% set the start index of the first part
partition(nParts).start = 1;
% we require the regions to be at least smallestRegion entries long in
% order to avoid isolated outliers
if length(minSecondDeriv) > smallestRegion
    % a section is a contiguous region of curvature below threshold.
    % Brakes between sections is identifed by finding indices where the
    % difference is > 1
    sections = find(diff(minSecondDeriv) > 1);
    if ~isempty(sections)
        % for all the sections found find the mindpoints.  The first and last
        % sections are special cases.
        for section = 1:length(sections)
            if section == 1 
                % if this is the first section, sections(section) is the end of
                % the first section, and all previous indices in minSecondDeriv
                % are contained in this section, so center is at the half-way
                % point = sections(section)/2.  Taking ceil seems to capture
                % the corner better in most (but not all) cases.
                midSectionIndex = ceil(sections(section)/2);
            else
                % all later sections contain the start ( = sections(section-1))
                % and end ( = sections(section)) indices in minSecondDeriv, so
                % find the center by taking the midpoint.
                midSectionIndex = ...
                    fix((sections(section-1) + sections(section))/2);
            end
            % check to make sure new partition is greater than minimum size and
            % if so add new partition
            if minSecondDeriv(midSectionIndex) - partition(nParts).start >= smallestRegion
                % set the end of the partition to the midpoint of negative
                % curvature
                partition(nParts).end = minSecondDeriv(midSectionIndex);
                % increment the number of parts
                nParts = nParts + 1;
                % set the start of the next partition to the next index
                partition(nParts).start = partition(nParts-1).end + 1;
            end
        end
        % the last section is the beginning of the last region of negative
        % curvature so find midpoint index from the average of the last section
        % beginning (= sections(section)) and the end of minSecondDeriv 
        midSectionIndex = ...
            fix((length(minSecondDeriv) + sections(section))/2);
        % check to make sure last partition is greater than minimum size and
        % if so add new partition
        if minSecondDeriv(midSectionIndex) - partition(nParts).start >= smallestRegion
            % set the end of the current partition
            partition(nParts).end = minSecondDeriv(midSectionIndex);
            % increment the number of parts
            nParts = nParts + 1;
            % set the start of the next partition to the next index
            partition(nParts).start = partition(nParts-1).end + 1;
        end
    end
end
% set the end of the last partition (= end of the time series)
partition(nParts).end = length(timeSeries);

if display
    % draw a figure showing the partitions and curvature
    colors = ['r' 'g' 'b' 'y' 'k' 'b' 'c' 'm'];
    figure;
    subplot(2,1,1);
    hold on;
    for i=1:length(partition)
        plot(partition(i).start:partition(i).end, ...
            timeSeries(partition(i).start:partition(i).end),...
            colors(mod(i,length(colors))+1));
    end
    hold off;
    subplot(2,1,2);
    plot(secondDeriv);
end