function [maskIndex, partitionNumber, numPartitions, imageLabels, partitionIndex] = ...
    consolidate_partitions(imageMask)
% function [maskIndex, partitionNumber, numPartitions, imageLabels, partitionIndex] = ...
%     consolidate_partitions(imageMask)
%
%	partitions the binary imageMask (imageMask(i,j) = 0, or 1, only)
%   into sets depending on which "on" pixels are touching
%
%   maskIndex is an array of the linear indices of imageMask that contain non-zero values.
%   partitionNumber corresponds to maskIndex and contains the partition
%       number for each index in maskIndex. 
%   numPartitions is the number of contiguous partitions found in the imageMask.
%   imageLabels is the same as the input imageMask, except that each entry is
%       labeled with its partition number rather than with 1's. 
%   partitionIndex is a cell array, each entry of which contatins the
%       linear index into imageMask of each parition. 
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

imageSize = size(imageMask);
imageArea = imageSize(1)*imageSize(2);

% create list of row, column where mask is true
[maskRow, maskCol] = find(imageMask); % nonzero elements
% get linear index of mask true entries
maskIndex = sub2ind(imageSize, maskRow, maskCol); 
% get corresponding mask values
maskTrue = imageMask(maskIndex);               
% create a sparse version of imageMask
sparseMask = sparse(maskRow, maskCol, double(maskTrue), imageSize(1), imageSize(2));

% now create linear indices for the 9 neighbors of each true pixel in the
% mask being careful with boundaries
upperNeighborIndex = get_neighbor_index(imageSize, maskRow, maskCol, -1, 0); % Pixel above
lowerNeighborIndex = get_neighbor_index(imageSize, maskRow, maskCol, +1, 0); % Pixel below
leftNeighborIndex = get_neighbor_index(imageSize, maskRow, maskCol, 0, -1); % Pixel left
rightNeighborIndex = get_neighbor_index(imageSize, maskRow, maskCol, 0, +1); % Pixel right
upperRightNeighborIndex = get_neighbor_index(imageSize, maskRow, maskCol, -1, +1); % Pixel above and to right
lowerRightNeighborIndex = get_neighbor_index(imageSize, maskRow, maskCol, +1, +1); % Pixel below and to right
upperLeftNeighborIndex = get_neighbor_index(imageSize, maskRow, maskCol, -1, -1); % Pixel above and to left
lowerLeftNeighborIndex = get_neighbor_index(imageSize, maskRow, maskCol, +1, -1); % Pixel below and to left

numTruePixels = length(maskRow);
% create a version of the mask with each true pixel numbered in sequence to
% seed assigning an ID # to each partition
IdMask = sparseMask;
IdMask(maskIndex) = 1:numTruePixels; 

% we now assign id #s the neighbor points equal to the number of the points they are
% neighbors of
upperNeighborId = set_neightbor_number(IdMask, upperNeighborIndex, numTruePixels, imageArea);
lowerNeighborId = set_neightbor_number(IdMask, lowerNeighborIndex, numTruePixels, imageArea);
leftNeighborId = set_neightbor_number(IdMask, leftNeighborIndex, numTruePixels, imageArea);
rightNeighborId = set_neightbor_number(IdMask, rightNeighborIndex, numTruePixels, imageArea);
upperRightNeighborId = set_neightbor_number(IdMask, upperRightNeighborIndex, numTruePixels, imageArea);
lowerRightNeighborId = set_neightbor_number(IdMask, lowerRightNeighborIndex, numTruePixels, imageArea);
upperLeftNeighborId = set_neightbor_number(IdMask, upperLeftNeighborIndex, numTruePixels, imageArea);
lowerLeftNeighborId = set_neightbor_number(IdMask, lowerLeftNeighborIndex, numTruePixels, imageArea);

clear upperNeighborIndex lowerNeighborIndex leftNeighborIndex rightNeighborIndex 
clear upperRightNeighborIndex lowerRightNeighborIndex upperLeftNeighborIndex lowerLeftNeighborIndex

% we now collect the pixel IDs into a matrix where each column is the ID 
% of each neighbor, and look for the lowest ID in each column.
% Repeating this process causes the ID assigned to each pixel to be set
% to the ID of any contiguously neighboring pixel with the smallest value.
%
% in other words this method assigns a different value to each contiguous
% collection of pixels.
newPartitionId = (1:numTruePixels)';
% look for lowest numbered neighbor
newPartitionId = min([newPartitionId(newPartitionId), ...
   newPartitionId(upperNeighborId), ...
   newPartitionId(lowerNeighborId), ...
   newPartitionId(leftNeighborId), ...
   newPartitionId(rightNeighborId), ...
   newPartitionId(upperRightNeighborId), ...
   newPartitionId(lowerRightNeighborId), ...
   newPartitionId(upperLeftNeighborId), ...
   newPartitionId(lowerLeftNeighborId)],[],2);

oldPartitionId = newPartitionId-1;
% now iterate until all contiguous pixels in each partition are assigned
% the same ID
while any(oldPartitionId ~= newPartitionId)
	oldPartitionId = newPartitionId;
	
    % looking for lowest index neighbor
    newPartitionId = min([newPartitionId(newPartitionId), ...
       newPartitionId(upperNeighborId), ...
       newPartitionId(lowerNeighborId), ...
       newPartitionId(leftNeighborId), ...
       newPartitionId(rightNeighborId), ...
       newPartitionId(upperRightNeighborId), ...
       newPartitionId(lowerRightNeighborId), ...
       newPartitionId(upperLeftNeighborId), ...
       newPartitionId(lowerLeftNeighborId)],[],2);
end

% at this point newPartitionId contains sets of IDs with
% redundancy, where equal IDs indicate pixels in the same contiguous
% partition.  For example newPartitionId = [ 1 1 6 1 6 6 6 1 1 6 ]
% for two partitions labeled by the IDs 1 and 6.

% Set up output information
partitionId = unique(newPartitionId); % in example get [1 6]
numPartitions  = length(partitionId); % in example get 2
partitionNumber = zeros(size(newPartitionId));
imageLabels   = zeros(imageSize);

% initialize partitionIndex in case there is nothing to return
partitionIndex = [];

% assign pixels to a partition and give the partition a number
for i = 1:numPartitions
    % find those pixels that are in each partition
    % in the example partitionIndex{1} = [1 2 4 8 9], partitionIndex{2} =
    % [3 5 6 7 10]
	partitionIndex{i} = find(newPartitionId == partitionId(i));
    % label the pixels in the image by their partition numbers
    % note that these are not partition IDs: in the example
    % imageLabels(partitionId == 1) = 1, 
    % imageLabels(partitionId == 6) = 2;
	imageLabels(maskIndex(partitionIndex{i})) = i;
    % assign each pixel in the image with its partition
	partitionNumber(partitionIndex{i}) = i;
end

% don't return "[]" return "0"
if isempty(maskIndex)
    maskIndex = 0; 
end
if isempty(partitionNumber)
    partitionNumber = 0;
end
if isempty(partitionIndex)
    partitionIndex = 0;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function neighborIndex = get_neighbor_index(imageSize, rows, columns, rowOffset, colOffset)
% function neighborIndex = get_neighbor_index(imageSize, rows, columns, rowOffset, colOffset)
%
% return linear index to offset of pixel at rows, columns  with offset 
% specified by rowOffset, colOffset.
neighborIndex = sub2ind(imageSize, ...
    min(max(rows + rowOffset, 1), imageSize(1)), ...
    min(max(columns + colOffset, 1), imageSize(2))); 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function neighborNumber = set_neightbor_number(IdMask, neighborIndex, numTruePixels, imageArea)
% function neighborNumber = set_neightbor_number(IdMask, neighborIndex, numTruePixels, imageArea)
%
% assign to the neighbor index array in neighborIndex the same numbering as
% the pixel in IdMask that it neighbors

% restrict neighbor indices to valid indices (though we shouldn't have any
% invalid indices)
validIndex = neighborIndex >= 1 & neighborIndex <= imageArea;
% set the neightbor's number to the number of the central pixel
neighborNumber(validIndex) = IdMask(neighborIndex(validIndex));
% number the zero values
numbering = (1:numTruePixels);
neighborNumber(neighborNumber == 0) = numbering(neighborNumber == 0);


