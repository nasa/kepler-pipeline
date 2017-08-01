function [targetStarStruct, backgroundStruct] ...
    = insert_data_gaps(targetStarStruct, backgroundStruct, completeness)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [targetStarStruct, backgroundStruct] ...
%   = insert_data_gaps(targetStarStruct, backgroundStruct, completeness);
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% extend the targetStarStruct and backgroundStruct structures by adding 
% data gap information to their time series
% 
% inputs:
%   targetStarStruct struct array containing all data for each target star
%       with at least the following fields:
%       .pixelTimeSeriesStruct struct array giving the pixel time series data
%           with the following fields:
%           .timeSeries time series of pixel flux data
%   backgroundStruct struct array containing data for each background
%       target with the following fields:
%       .timeSeries time series of pixel flux data
%   completeness fraction of data assumed to not be in a gap, e.g. 0.95
%
% outputs: the following fields are added to the input structures
%   targetStarStruct struct array containing all data for each target star
%       with at least the following fields:
%       .pixelTimeSeriesStruct struct array giving the pixel time series data
%           with the following fields:
%           .gapList list of cadences which are gaps
%   backgroundStruct struct array containing data for each background
%       target with the following fields:
%       .gapList list of cadences which are gaps
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

% assume all time series contain the same number of cadences
nCadences = length(targetStarStruct(1).pixelTimeSeriesStruct(1).timeSeries);
nGaps = fix((1 - completeness)*nCadences);

nTargets = length(targetStarStruct);
for target = 1:nTargets
    
    % introduce target level gaps here
    gapIndices = make_gap_indices(nGaps, nCadences);
    nPixels = length(targetStarStruct(target).pixelTimeSeriesStruct);
    for pixel = 1:nPixels
        % extend the pixelTimeSeriesStruct to include gap indices
        % use the same gaps in all pixels in a target to make target level
        % gap
        targetStarStruct(target).pixelTimeSeriesStruct(pixel).gapList = gapIndices;
    end 
    targetStarStruct(target).gapList = gapIndices;
    
%     % for pixel level gaps
%     nPixels = length(targetStarStruct(target).pixelTimeSeriesStruct);
%     for pixel = 1:nPixels
%         % extend the pixelTimeSeriesStruct to include gap indices
%         targetStarStruct(target).pixelTimeSeriesStruct(pixel).gapList = ...
%             make_gap_indices(nGaps, nCadences);
%     end    
end

nBackPix = length(backgroundStruct);
for backPixel = 1:nBackPix
    % extend the pixelTimeSeriesStruct to include gap indices
    backgroundStruct(backPixel).gapList = ...
        make_gap_indices(nGaps, nCadences);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function gapList = make_gap_indices(nGaps, seriesLength)
%
% make a list of gap indices containing nGaps for an 
%   array of length seriesLength.  Also inserts two 
%   2-cadences gaps and one 3-cadence gap
%
%   inputs: 
%       nGaps number of gaps to insert (used as a guideline)
%       seriesLength length of the series in which to insert the gaps
%
%   output: 
%       gapList array of indices giving gap locations, sorted in
%           increasing order
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function gapList = make_gap_indices(nGaps, seriesLength)
if nGaps == 0
    gapList = [];
    return;
end

gapList = unique(ceil(seriesLength*rand(nGaps, 1)));
% insert a couple 2-cadence gap, not too close to the top
startIndex = ceil((length(gapList) - 10)*rand(1,1))+5;
gapList(startIndex+1) = gapList(startIndex)+1; % make subsequent gap
startIndex = ceil((length(gapList) - 10)*rand(1,1))+5;
gapList(startIndex+1) = gapList(startIndex)+1; % make subsequent gap
% insert a couple 3-cadence gap, not too close to the top
startIndex = ceil((length(gapList) - 10)*rand(1,1))+5;
gapList(startIndex+1) = gapList(startIndex)+1; % make subsequent gap
gapList(startIndex+2) = gapList(startIndex)+2; % make subsequent gap
% insert a 5-cadence gap, not too close to the top
startIndex = ceil((length(gapList) - 20)*rand(1,1))+10;
for g=1:4
    gapList(startIndex+g) = gapList(startIndex)+g; % make subsequent ga
end
% insert a 7-cadence gap, not too close to the top
startIndex = ceil((length(gapList) - 20)*rand(1,1))+10;
for g=1:6
    gapList(startIndex+g) = gapList(startIndex)+g; % make subsequent ga
end
% insert a 9-cadence gap, not too close to the top
startIndex = ceil((length(gapList) - 20)*rand(1,1))+10;
for g=1:8
    gapList(startIndex+g) = gapList(startIndex)+g; % make subsequent ga
end
