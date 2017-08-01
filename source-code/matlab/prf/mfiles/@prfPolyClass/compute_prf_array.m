function [prfArray uncertainties] = compute_prf_array(prfObject, subRow, subCol, ...
    pixelIndex, subRowIndex, subColIndex)
% function prfArray = compute_prf_array(prfObject, subRow, subCol, ...
%     pixelIndex, subRowIndex, subColIndex)
%
% compute pixel values by evaluating a PRF at a specified sub-row and
% sub-column position for the pixels specified by pixelIndex.
% inputs:
%   subRow and subCol are the sub-pixel coordinates of the star to be imaged
%   pixelIndex is a list of the pixels in the PRF array that are to be
%       evaluated.
%   subRowIndex, subColIndex are the indices of the sub-pixel region
%   corresponding to subRow and subCol
%
% This function smooths discontinuities between sub-pixel polynomial
% patches using a smooth sigmoid function.
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

% the sub-pixel coordinate system ranges from -0.5 to 0.5 on each sub-pixel
% region, with 0 at the center of the sub-pixel region.
% The sub-pixel patches are defined in this coordinate system
%
% so on one pixel the sub-pixel coordinates look like this:
% 
%   ||                                                                   ||
%   ||----------|-----------|----------|-----------|----------|----------||
% -0.5      -0.3333      -0.1667       0        0.1667     0.3333       0.5
%
% where || denotes the pixel boundaries and | denotes the boundaries of the
% sub-pixel regions (here using 6 sub-pixel regions per pixel).

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

% distance from row boundary, used to compute smoothing weight function
% compute distance from all boundaries
dFromRowBoundary = subRow - subRowBoundaries;
% find the boundary that we're close enough to to apply smoothing
tooCloseToRowBoundary = find(abs(dFromRowBoundary) < rowOverlapSize);
% boundaryRow is the position of the boundary that we're close to
boundaryRow = subRowBoundaries(tooCloseToRowBoundary);
% do the same in the column direction
dFromColBoundary = subCol - subColBoundaries;
tooCloseToColBoundary = find(abs(dFromColBoundary) < colOverlapSize);
boundaryCol = subColBoundaries(tooCloseToColBoundary);

% convert the input pixels into row and column in local coordinates so we
% can detect when we've gone over a pixel boundary in the row or column
% direction
[pixRow, pixCol] = ind2sub([nPixArrayRows, nPixArrayCols], pixelIndex);

% weightEffectiveZero == 1 implies that the smoothing is turned off, so
% simply evaluate the PRF
if weightEffectiveZero == 1
    prfArray = compute_single_prf_array(prfObject, subRow, subCol, ...
        pixRow, pixCol, subRowIndex, subColIndex);
    if nargout >= 2
        uncertainties = compute_single_prf_uncertainties(prfObject, subRow, subCol, ...
            pixRow, pixCol, subRowIndex, subColIndex);
    end

    return;
end


% set up the input parameters to the smooth sigmoid function to compute the
% smoothing weights.  We need to identify the adjacent row/column patches,
% which may be on the next pixel over.  The convention is that, for
% example, subCol2 is the patch adjacent in the column direction to the
% patch for subCol. 
if ~isempty(tooCloseToColBoundary)
    % we're close to a boundary and have to smooth
    % first test to see if we're on the right or left of the boundary
    if dFromColBoundary(tooCloseToColBoundary) < 0 || subCol == subColBoundaries(end)
        % we're to the left of the boundary, so our sub-pixel coordinates
        % are in the range [0 0.5].  This means that the next patch over is
        % to the right.  
        % We have to worry about the possibility that the next patch over
        % may be on the next pixel (to the left!! - see below)
        if subColIndex < nSubCols
            % the patch we're working in is not in the rightmost column so
            % the next patch over is simply the next one
            subColIndex2 = subColIndex + 1;
            % deltaCol is the increment to the pixel column coordinate for
            % evaluation of the PRF. Since we didn't fall off the pixel
            % the pixel column coordinate does not change.
            deltaCol = 0;
            % the sub-pixel coordinate says the same since we're on the
            % same pixel, and sub-pixel patches on the same pixel are
            % within the same sub-pixel coordinate system.
            subCol2 = subCol;
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
            deltaCol = -1; % pick the pixel on the left
            % we want the left-most sub-pixel region to match to the
            % right-most sub-pixel region we're on
            subColIndex2 = 1; 
            % but the coordinate system is flipped, 'cause we're on the
            % negative side of the adjacent pixel
            subCol2 = subCol - 2*boundaryCol;
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
        if subColIndex > 1
            % similar to above: stay in the same
            % coordinate system on the same pixel, but move left 
            deltaCol = 0;
            subColIndex2 = subColIndex - 1;
            subCol2 = subCol;
        else
            % Oops - we fell off the pixel to the left
            %
            % this time we match to the pixel on the right
            deltaCol = 1; % move to the right
            subColIndex2 = nSubCols; % and match with its right-most column
            subCol2 = subCol - 2*boundaryCol; % and reflect the coordinates
        end
        % this time we're interpolating to the left, so we want the sigmoid
        % to decrease to the left, which is how it is defined.
        columnDir = 1;
    end
    % now compute the column smoothing weight:
    % weight = smooth_sigmoid(x, a, b) produces the value of the sigmoid at
    % x in the interval [a, b].  The interval is of size 2*colOverlapSize,
    % and is centered at boundaryCol.
    wCol = smooth_sigmoid(subCol, boundaryCol - columnDir*colOverlapSize, ...
        boundaryCol + columnDir*colOverlapSize);
    % for optimization: if the weight is below the threshold set it to
    % zero.
    if wCol < weightEffectiveZero
		wCol = 0;
    end
    % or if the weight is close enough to 1 set it to 1.
	if 1 - wCol < weightEffectiveZero
		wCol = 1;
	end
else
    wCol = 0;
end

% now do the row direction: same as in the column direction, so 
% see the comments there for details
if ~isempty(tooCloseToRowBoundary)
    if dFromRowBoundary(tooCloseToRowBoundary) < 0 || subRow == subRowBoundaries(end)
        if subRowIndex < nSubRows
            subRowIndex2 = subRowIndex + 1;
            deltaRow = 0;
            subRow2 = subRow;
        else % fell off the pixel
            deltaRow = -1;
            subRowIndex2 = 1;
            subRow2 = subRow - 2*boundaryRow;
        end
        rowDir = -1;
    else
        if subRowIndex > 1
            subRowIndex2 = subRowIndex - 1;
            deltaRow = 0;
            subRow2 = subRow;
        else
            deltaRow = 1;
            subRowIndex2 = nSubRows;
            subRow2 = subRow - 2*boundaryRow;
        end
        rowDir = 1;
    end
    wRow = smooth_sigmoid(subRow, boundaryRow - rowDir*rowOverlapSize, ...
        boundaryRow + rowDir*rowOverlapSize);
    if wRow < weightEffectiveZero
    	wRow = 0;
    end
	if 1 - wRow < weightEffectiveZero
		wRow = 1;
	end
else
    wRow = 0;
end

% now compute prfArray, which is the PRF evaluated on the desired pixels
% get the value for the sub-pixel region that we're on
v1 = compute_single_prf_array(prfObject, subRow, subCol, ...
    pixRow, pixCol, subRowIndex, subColIndex);
if nargout >= 2
    u1 = compute_single_prf_uncertainties(prfObject, subRow, subCol, ...
        pixRow, pixCol, subRowIndex, subColIndex);
end

% if wCol and wRow are both zero there is no interpolation to do
if wCol == 0 && wRow == 0    
    prfArray = v1;
    if nargout >= 2
        uncertainties = u1;
    end
else
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
    
    % if necessary get the value of the column-adjacent sub-pixel region.
    % notice from the interpolation formulas that if wRow = 0 then v2 does
    % not come into play.  
    if wRow > 0
        % this adjacent region has some weight so evaluate it
    	v2 = compute_single_prf_array(prfObject, subRow, subCol2, ...
        	pixRow, pixCol + deltaCol, subRowIndex, subColIndex2);
    else
        % this adjacent region has no weight so get zero
    	v2 = 0;
    end
    % similarly if wCol = 0 then v3 plays no part.
    if wCol > 0
    	v3 = compute_single_prf_array(prfObject, subRow2, subCol, ...
        	pixRow + deltaRow, pixCol, subRowIndex2, subColIndex);
    else
    	v3 = 0;
    end
    % finally if wRow or wCol = 1 then v4 plays no part.
    if wRow == 1 || wCol == 1
        v4 = 0;
    else
        v4 = compute_single_prf_array(prfObject, subRow2, subCol2, ...
            pixRow + deltaRow, pixCol + deltaCol, subRowIndex2, subColIndex2);
    end

    % interpolate row first
    iv1 = wRow*v1 + (1-wRow)*v3; 
    iv2 = wRow*v2 + (1-wRow)*v4;
    % interpolate column
    p1 = wCol*iv1 + (1-wCol)*iv2; 
    
    % now do the opposite order
    iv1 = wCol*v1 + (1-wCol)*v2; 
    iv2 = wCol*v3 + (1-wCol)*v4;
    p2 = wRow*iv1 + (1-wRow)*iv2; 
    
    % and take the average as the final answer
    prfArray = (p1+p2)/2;
    
    % compute the uncertainties if they are requested.  The uncertainties
    % are treated in exactly the same way as the values, except the
    % appropriate interpolation formula is used
    if nargout >= 2
        if wRow > 0
            u2 = compute_single_prf_uncertainties(prfObject, subRow, subCol2, ...
                pixRow, pixCol + deltaCol, subRowIndex, subColIndex2);
        else
            u2 = 0;
        end
        if wCol > 0
            u3 = compute_single_prf_uncertainties(prfObject, subRow2, subCol, ...
                pixRow + deltaRow, pixCol, subRowIndex2, subColIndex);
        else
            u3 = 0;
        end
        if wRow == 1 || wCol == 1
            u4 = 0;
        else
            u4 = compute_single_prf_uncertainties(prfObject, subRow2, subCol2, ...
                pixRow + deltaRow, pixCol + deltaCol, subRowIndex2, subColIndex2);
        end
        
        % interpolate the uncertainties using the formulas derived from the
        % value interpolations via standard propagation of error techniques
        iu1 = wRow.^2*u1.^2 + (1-wRow).^2*u3.^2; 
        iu2 = wRow.^2*u2.^2 + (1-wRow).^2*u4.^2;
        p1 = wCol.^2*iu1.^2 + (1-wCol).^2*iu2.^2; 

        iu1 = wCol.^2*u1.^2 + (1-wCol).^2*u2.^2; 
        iu2 = wCol.^2*u3.^2 + (1-wCol).^2*u4.^2;
        p2 = wRow.^2*iu1.^2 + (1-wRow).^2*iu2.^2; 
    
        uncertainties = sqrt((p1.^2+p2.^2)/4);
    end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function prfArray = compute_single_prf_array(prfObject, subRow, subCol, ...
    pixRows, pixCols, subRowIndex, subColIndex)

prfArray = zeros(size(pixRows));

% identify pixels that not within the PRF pixel grid
nPixArrayRows = prfObject.nPrfArrayRows;
nPixArrayCols = prfObject.nPrfArrayRows;
goodPixIndex = find(pixRows >= 1 & pixRows <= nPixArrayRows ...
    & pixCols >= 1 & pixCols <= nPixArrayCols);

pixelIndex = sub2ind([nPixArrayRows, nPixArrayCols], ...
    pixRows(goodPixIndex), pixCols(goodPixIndex));

switch(prfObject.polyType)
    case 'standard' % standard polynomial type includes scaling
        % scale subRow and subCol to match weighted_polyval2d
        % the result is a vector with an entry for each pixel in the prf pixel
        % array.  See prfClass.m for entries of scalingMatrix
        scalingMatrix = prfObject.scalingMatrix(:, :, subRowIndex, subColIndex);
        scaledSubRow = scalingMatrix(1, :) + scalingMatrix(2, :) ...
            .*(subRow - scalingMatrix(3, :));
        scaledSubCol = scalingMatrix(4, :) + scalingMatrix(5, :) ...
            .*(subCol - scalingMatrix(6, :));

        % get the coefficients for this sub row and column region for all
        % pixels in the PRF array
        % coeffMatrix = squeeze(prfObject.coefficientMatrix(:,:,subRowIndex, subColIndex));
        % make the design matrix for the scaled sub row and column values
        A = weighted_design_matrix2d(scaledSubRow(:), scaledSubCol(:), 1, prfObject.maxOrder); 
        prfArray(goodPixIndex) = diag(A(pixelIndex,:)...
            *prfObject.coefficientMatrix(:,pixelIndex, subRowIndex, subColIndex));
        
        
        
    case 'not_scaled' % this polynomial type does not requires any scaling
        % get the coefficients for this sub row and column region for all
        % pixels in the PRF array
        % coeffMatrix = squeeze(prfObject.coefficientMatrix(:,:,subRowIndex, subColIndex));
        % make the design matrix for the scaled sub row and column values
        A = weighted_design_matrix2d(subRow(:), subCol(:), 1, prfObject.maxOrder); 
        % A is now 1 x # of coefficients
        prfArray(goodPixIndex) = A ...
            * prfObject.coefficientMatrix(:,pixelIndex, subRowIndex, subColIndex);
        
    otherwise
        error('prfClass:evaluate: bad polyType');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function uncertainties = compute_single_prf_uncertainties(prfObject, subRow, subCol, ...
    pixRows, pixCols, subRowIndex, subColIndex)
	
if isempty(prfObject.polyStruct)
	disp('cannot compute PRF uncertainties');
	uncertainties = [];
	return;
end

uncertainties = zeros(size(pixRows));

% identify pixels that are within the PRF pixel grid
nPixArrayRows = prfObject.nPrfArrayRows;
nPixArrayCols = prfObject.nPrfArrayRows;
goodPixIndex = find(pixRows >= 1 & pixRows <= nPixArrayRows ...
    & pixCols >= 1 & pixCols <= nPixArrayCols);

pixelIndex = sub2ind([nPixArrayRows, nPixArrayCols], ...
    pixRows(goodPixIndex), pixCols(goodPixIndex));

for i=1:length(pixelIndex)
    if sum(prfObject.polyStruct(pixelIndex(i), subRowIndex, subColIndex).c.coeffs) ~= 0
        A = weighted_design_matrix2d(subRow(:), subCol(:), 1, prfObject.polyStruct( ...
            pixelIndex(i), subRowIndex, subColIndex).c.order); 
        uncertainties(i) = ...
            A*prfObject.polyStruct( ...
            pixelIndex(i), subRowIndex, subColIndex).c.covariance*A';
    else
        uncertainties(i) = 0;
    end
end

