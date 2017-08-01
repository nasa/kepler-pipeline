function [prfArray, prfRow, prfColumn] = make_array(prfObject, resolution, reverse, offset)
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
if nargin < 2
    resolution = 100;
end

if nargin < 3
    reverse = 1;
end

if nargin < 4
    offset = [0 0];
end

rowPixelsOnASide = prfObject.nPrfArrayRows;
colPixelsOnASide = prfObject.nPrfArrayCols;
pointsPerRowPixel = resolution/rowPixelsOnASide;
pointsPerColPixel = resolution/colPixelsOnASide;

prfArray = zeros(resolution);
prfRow = zeros(resolution);
prfColumn = zeros(resolution);

for r = 1:resolution
    for c = 1:resolution
        rowCoords = r/pointsPerRowPixel - offset(1); % floating point pixel row position
        colCoords = c/pointsPerColPixel - offset(2); % floating point pixel column position

        if rowCoords > rowPixelsOnASide || colCoords > colPixelsOnASide
            continue;
        end
        
        pixelRow = min(fix(rowCoords) + 1, rowPixelsOnASide);
        pixelCol = min(fix(colCoords) + 1, colPixelsOnASide);
        pixelSubRowCoords = rowCoords + 1 - pixelRow - 0.5; % sub-row coords so 0 is in center of pixel
        pixelSubColCoords = colCoords + 1 - pixelCol - 0.5; % sub-row coords so 0 is in center of pixel
        if reverse
            pixelSubRowCoords = -pixelSubRowCoords;
            pixelSubColCoords = -pixelSubColCoords;
        end
        
        subRowIndex = find(pixelSubRowCoords >= prfObject.subRowStart ...
            & pixelSubRowCoords < prfObject.subRowEnd);
		if pixelSubRowCoords == prfObject.subRowEnd(end)
			subRowIndex = length(prfObject.subRowEnd);
		end
        subColIndex = find(pixelSubColCoords >= prfObject.subColStart ...
            & pixelSubColCoords < prfObject.subColEnd);
		if pixelSubColCoords == prfObject.subColEnd(end)
			subColIndex = length(prfObject.subColEnd);
		end
        pixelIndex = sub2ind([rowPixelsOnASide, colPixelsOnASide], pixelRow, pixelCol);

        prfArray(r,c) = compute_prf_array(prfObject, pixelSubRowCoords, pixelSubColCoords, ...
            pixelIndex, subRowIndex, subColIndex);
        prfRow(r,c) = rowCoords;
        prfColumn(r,c) = colCoords;
    end
end

