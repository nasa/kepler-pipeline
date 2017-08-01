function prfArray = compute_prf_array_variable_width(prfObject, subRow, subCol, ...
    originalPixelIndex, scaledPixelIndex, subRowIndex, subColIndex, arraySize)
% function prfArray = compute_prf_array_variable_width(prfObject, subRow, subCol, ...
%     originalPixelIndex, scaledPixelIndex, subRowIndex, subColIndex, arraySize)
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

% determine the smoothing region
nSubRows = prfObject.nSubRows;
% currently the overlap size is hard-coded to half a pixel, may be
% parameterized in the future
rowOverlapSize = 1/nSubRows/2;
nSubCols = prfObject.nSubColumns;
colOverlapSize = 1/nSubCols/2;

nPixArrayRows = prfObject.nPrfArrayRows;
nPixArrayCols = prfObject.nPrfArrayRows;

% parameter that tells the smoothing algorithm to turn itself off if the
% weighting function is below a certain value
weightEffectiveZero = prfObject.weightEffectiveZero;
% weightEffectiveZero = 1;

% get the positions of the sub-row/col boundaries
subRowBoundaries = [prfObject.subRowStart prfObject.subRowEnd(end)];
subColBoundaries = [prfObject.subColStart prfObject.subColEnd(end)];

% convert the input pixels into row and column in local coordinates so we
% can detect when we've gone over a pixel boundary in the row or column
% direction (we'll need this when we put smoothing back in)
[pixRow, pixCol] = ind2sub([nPixArrayRows, nPixArrayCols], scaledPixelIndex);

% figure
% plot(pixRow + subRow, pixCol + subCol, '+');
% set(gca, 'YTick', 0.5:prfObject.nPrfArrayRows+.5);
% set(gca, 'XTick', 0.5:prfObject.nPrfArrayCols+.5);
% grid on;
% title('input to compute prf array');

if weightEffectiveZero == 1
    prfArray = compute_single_prf_array(prfObject, subRow, subCol, ...
        pixRow, pixCol, originalPixelIndex, subRowIndex, subColIndex, arraySize);
    return;
end

subRowIndex2 = zeros(size(subRowIndex));
subColIndex2 = zeros(size(subColIndex));
subRow2 = zeros(size(subRow));
subCol2 = zeros(size(subCol));
deltaRow = zeros(size(subRow));
deltaCol = zeros(size(subCol));
% the weights have to be the same size as the prf arrays
wRow = zeros(arraySize);
wCol = zeros(arraySize);

for p = 1:length(subRow)
    % distance from row boundary, used to compute smoothing weight function
    % compute distance from all boundaries
    dFromRowBoundary = subRow(p) - subRowBoundaries;
    % find the boundary that we're close enough to to apply smoothing
    tooCloseToRowBoundary = find(abs(dFromRowBoundary) < rowOverlapSize);
    % boundaryRow is the position of the boundary that we're close to
    boundaryRow = subRowBoundaries(tooCloseToRowBoundary);
    % do the same in the column direction
    dFromColBoundary = subCol(p) - subColBoundaries;
    tooCloseToColBoundary = find(abs(dFromColBoundary) < colOverlapSize);
    boundaryCol = subColBoundaries(tooCloseToColBoundary);
    
    % we have to make a special index for the weights, which have the size
    % of the full array
%     w = scaledPixelIndex(p);
    w = p;

    % set up the input parameters to the smooth sigmoid function to compute the
    % smoothing weights.  We need to identify the adjacent row/column patches,
    % which may be on the next pixel over.  The convention is that, for
    % example, subCol2 is the patch adjacent in the column direction to the
    % patch for subCol. 
    if ~isempty(tooCloseToColBoundary)
        % we're close to a boundary and have to smooth
        % first test to see if we're on the right or left of the boundary
        if dFromColBoundary(tooCloseToColBoundary) < 0 || subCol(p) == subColBoundaries(end)
            % we're to the left of the boundary, so our sub-pixel coordinates
            % are in the range [0 0.5].  This means that the next patch over is
            % to the right.  
            % We have to worry about the possibility that the next patch over
            % may be on the next pixel (to the left!! - see below)
            if subColIndex(p) < nSubCols
                % the patch we're working in is not in the rightmost column so
                % the next patch over is simply the next one
                subColIndex2(p) = subColIndex(p) + 1;
                % deltaCol is the increment to the pixel column coordinate for
                % evaluation of the PRF. Since we didn't fall off the pixel
                % the pixel column coordinate does not change.
                deltaCol(p) = 0;
                % the sub-pixel coordinate says the same since we're on the
                % same pixel, and sub-pixel patches on the same pixel are
                % within the same sub-pixel coordinate system.
                subCol2(p) = subCol(p);
            else
                % Oops - we fell off the pixel to the right
                %
                % There is a major subtlety in matching PRF polynomials across pixel
                % boundaries.  As defined, the PRF gives the response of the
                % _pixel_ to the motion of the _star_.  This means that, for
                % example, as the star moves to the right the pixels on the
                % right get brighter.  Therefore the right boundary of a pixel
                % is matched to the right side of the pixel to the _left_.  See
                % KADN XXX for more details.
                %
                % choose the pixel on the left
                deltaCol(p) = -1; % pick the pixel on the left
                % we want the left-most sub-pixel region to match to the
                % right-most sub-pixel region we're on
                subColIndex2(p) = 1; 
                % but the coordinate system is flipped, 'cause we're on the
                % negative side of the adjacent pixel
                subCol2(p) = subCol(p) - 2*boundaryCol;
            end
            % columnDir controls the sense of the sigmoid function.  Since
            % we're interpolating to the right we need the sigmoid to be
            % decreasing to the right, which is the opposite from how it is
            % defined.  So set columnDir = -1
            columnDir = -1;
        else
            % we're to the right of the boundary, so our sub-pixel coordinates
            % are in the range [-0.5 0].  This means that the next patch over is
            % to the left.  
            if subColIndex(p) > 1
                % similar to above: stay in the same
                % coordinate system on the same pixel, but move left 
                deltaCol(p) = 0;
                subColIndex2(p) = subColIndex(p) - 1;
                subCol2(p) = subCol(p);
            else
                % Oops - we fell off the pixel to the left
                %
                % this time we match to the pixel on the right
                deltaCol(p) = 1; % move to the right
                subColIndex2(p) = nSubCols; % and match with its right-most column
                subCol2(p) = subCol(p) - 2*boundaryCol; % and reflect the coordinates
            end
            % this time we're interpolating to the left, so we want the sigmoid
            % to decrease to the left, which is how it is defined.
            columnDir = 1;
        end
        % now compute the column smoothing weight:
        % weight = smooth_sigmoid(x, a, b) produces the value of the sigmoid at
        % x in the interval [a, b].  The interval is of size 2*colOverlapSize,
        % and is centered at boundaryCol.
        wCol(w) = smooth_sigmoid(subCol(p), boundaryCol - columnDir*colOverlapSize, ...
            boundaryCol + columnDir*colOverlapSize);
        % for optimization: if the weight is below the threshold set it to
        % zero.
        if wCol(w) < weightEffectiveZero
            wCol(w) = 0;
        end
        % or if the weight is close enough to 1 set it to 1.
        if 1 - wCol(w) < weightEffectiveZero
            wCol(w) = 1;
        end
    else
        wCol(w) = 0;
    end

    % now do the row direction: same as in the column direction, so 
    % see the comments there for details
    if ~isempty(tooCloseToRowBoundary)
        if dFromRowBoundary(tooCloseToRowBoundary) < 0 || subRow(p) == subRowBoundaries(end)
            if subRowIndex(p) < nSubRows
                subRowIndex2(p) = subRowIndex(p) + 1;
                deltaRow(p) = 0;
                subRow2(p) = subRow(p);
            else % fell off the pixel
                deltaRow(p) = -1;
                subRowIndex2(p) = 1;
                subRow2(p) = subRow(p) - 2*boundaryRow;
            end
            rowDir = -1;
        else
            if subRowIndex(p) > 1
                subRowIndex2(p) = subRowIndex(p) - 1;
                deltaRow(p) = 0;
                subRow2(p) = subRow(p);
            else
                deltaRow(p) = 1;
                subRowIndex2(p) = nSubRows;
                subRow2(p) = subRow(p) - 2*boundaryRow;
            end
            rowDir = 1;
        end
        wRow(w) = smooth_sigmoid(subRow(p), boundaryRow - rowDir*rowOverlapSize, ...
            boundaryRow + rowDir*rowOverlapSize);
        if wRow(w) < weightEffectiveZero
            wRow(w) = 0;
        end
        if 1 - wRow(w) < weightEffectiveZero
            wRow(w) = 1;
        end
    else
        wRow(w) = 0;
    end
end

% now compute prfArray, which is the PRF evaluated on the desired pixels
% get the value for the sub-pixel region that we're on

% we will use bi-linear interpolation to interpolate the values
% corresponding to these indices
% Here is an example: 
%
%     v3 . -----------------------------------------. v4
%        |                                          |
%        |                                          |
%        |                                          |
%        |                                          |
%   ^    |                                          |
%   |    |                                          |
%        |                                          |
%   r    |                                          |
%   o    |                                          |
%   w    |                                          |
%        |                                          |
%    iv1 o------------x-----------------------------o iv2
%        |                                          |
%        |                                          |
%        |                                          |
%        |                                          |    
%     v1 . -----------------------------------------. v2
%
%                        column ->
%
% here we are interpolating at x.  First we interpolate along the row
% direction on both sides to create intermediate values
%
%       iv1 = wRow*v1 + (1-wRow)*v3; 
%       iv2 = wRow*v2 + (1-wRow)*v4;
%
% then we interpolate these intermediate values along the column
% direction to get the final value p1:
%
%       p1 = wCol*iv1 + (1-wCol)*iv2; 
%
% If we interpolate along the column direction first then the
% intermediate values are
%
%       iv1 = wCol*v1 + (1-wCol)*v2; 
%       iv2 = wCol*v3 + (1-wCol)*v4;
% 
% and the final value  
%       p2 = wRow*iv1 + (1-wRow)*iv2; 
% 
% will be slightly different from p1.  To increase accuracy (since it
% is cheap performancewise) we deliver the final answer as the average
% of p1 and p2.
%

v1 = compute_single_prf_array(prfObject, subRow, subCol, ...
    pixRow, pixCol, originalPixelIndex, subRowIndex, subColIndex, arraySize);
v2 = compute_single_prf_array(prfObject, subRow, subCol2, ...
    pixRow, pixCol + deltaCol, originalPixelIndex, subRowIndex, subColIndex2, arraySize);
v3 = compute_single_prf_array(prfObject, subRow2, subCol, ...
    pixRow + deltaRow, pixCol, originalPixelIndex, subRowIndex2, subColIndex, arraySize);
v4 = compute_single_prf_array(prfObject, subRow2, subCol2, ...
    pixRow + deltaRow, pixCol + deltaCol, originalPixelIndex, subRowIndex2, subColIndex2, arraySize);

% figure;
% subplot(2,2,1);
% imagesc(reshape(v1,[11,11]));
% title('v1');
% subplot(2,2,2);
% imagesc(reshape(v2,[11,11]));
% title('v2');
% subplot(2,2,3);
% imagesc(reshape(v3,[11,11]));
% title('v3');
% subplot(2,2,4);
% imagesc(reshape(v4,[11,11]));
% title('v4');

% interpolate row first
iv1 = wRow.*v1 + (1-wRow).*v3; 
iv2 = wRow.*v2 + (1-wRow).*v4;
% interpolate column
p1 = wCol.*iv1 + (1-wCol).*iv2; 

% now do the opposite order
iv1 = wCol.*v1 + (1-wCol).*v2; 
iv2 = wCol.*v3 + (1-wCol).*v4;
p2 = wRow.*iv1 + (1-wRow).*iv2; 

% and take the average as the final answer
prfArray = (p1+p2)/2;
    

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function prfArray = compute_single_prf_array(prfObject, subRow, subCol, ...
    pixRows, pixCols, originalPixelIndex, subRowIndex, subColIndex, arraySize)

% figure
% plot(pixRows + subRow, pixCols + subCol, '+');
% set(gca, 'YTick', 0.5:prfObject.nPrfArrayRows+.5);
% set(gca, 'XTick', 0.5:prfObject.nPrfArrayCols+.5);
% grid on;
% title('compute single prf');

prfArray = zeros(arraySize);

% identify pixels that not within the PRF pixel grid
nPixArrayRows = prfObject.nPrfArrayRows;
nPixArrayCols = prfObject.nPrfArrayRows;
goodPixIndex = find(pixRows >= 1 & pixRows <= nPixArrayRows ...
    & pixCols >= 1 & pixCols <= nPixArrayCols);

pixelIndex = sub2ind([nPixArrayRows, nPixArrayCols], ...
    pixRows(goodPixIndex), pixCols(goodPixIndex));

% figure
% plot(pixRows(goodPixIndex) + subRow(goodPixIndex), pixCols(goodPixIndex) + subCol(goodPixIndex), '+');
% set(gca, 'YTick', 0.5:prfObject.nPrfArrayRows+.5);
% set(gca, 'XTick', 0.5:prfObject.nPrfArrayCols+.5);
% grid on;
% title('compute single prf');
% axis([0.5 11.5 0.5 11.5]);

switch(prfObject.polyType)        
        
    case 'not_scaled' % this polynomial type does not requires any scaling
        % get the coefficients for this sub row and column region for all
        % pixels in the PRF array
        % coeffMatrix = squeeze(prfObject.coefficientMatrix(:,:,subRowIndex, subColIndex));
        % make the design matrix for the scaled sub row and column values
        A = weighted_design_matrix2d(subRow(goodPixIndex), subCol(goodPixIndex), 1, prfObject.maxOrder); 
        % A is now 1 x # of coefficients
        for i=1:length(pixelIndex)
            prfArray(goodPixIndex(i)) = A(i,:) ...
                * prfObject.coefficientMatrix(:,pixelIndex(i), subRowIndex(goodPixIndex(i)), subColIndex(goodPixIndex(i)));
        end
        
    otherwise
        error('prfClass:compute_prf_array_variable_width: bad polyType');
end


