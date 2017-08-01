function [crossSectionValues, crossSectionLocation] = cross_section(prfObject, dim, slice, resolution, reverse)
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
if nargin < 4
    resolution = 5000;
end

if nargin < 5
    reverse = 1;
end

if nargin < 3
    slice = fix(resolution/2);
end

rowPixelsOnASide = get(prfObject, 'nPrfArrayRows');
colPixelsOnASide = rowPixelsOnASide;
pointsPerRowPixel = resolution/rowPixelsOnASide;
pointsPerColPixel = resolution/colPixelsOnASide;

crossSectionValues = zeros(resolution, 1);
crossSectionLocation = zeros(resolution, 1);

colCoords = slice/pointsPerColPixel; % floating point pixel column position
for r = 1:resolution-1
    rowCoords = r/pointsPerRowPixel; % floating point pixel row position

    pixelRow = fix(rowCoords) + 1;
    pixelCol = fix(colCoords) + 1;
    pixelSubRowCoords = rowCoords + 1 - pixelRow - 0.5; % sub-row coords so 0 is in center of pixel
    pixelSubColCoords = colCoords + 1 - pixelCol - 0.5; % sub-row coords so 0 is in center of pixel
    if reverse
        pixelSubRowCoords = -pixelSubRowCoords;
        pixelSubColCoords = -pixelSubColCoords;
    end

    subRowStart = get(prfObject, 'subRowStart');
    subRowEnd = get(prfObject, 'subRowEnd');
    subColStart = get(prfObject, 'subColStart');
    subColEnd = get(prfObject, 'subColEnd');
    
    subRowIndex = find(pixelSubRowCoords >= subRowStart ...
        & pixelSubRowCoords < subRowEnd);
    if pixelSubRowCoords == subRowEnd(end)
        subRowIndex = length(subRowEnd);
    end
    subColIndex = find(pixelSubColCoords >= subColStart ...
        & pixelSubColCoords < subColEnd);
    if pixelSubColCoords == subColEnd(end)
        subColIndex = length(subColEnd);
    end
    
    if dim == 1
        pixelIndex = sub2ind([rowPixelsOnASide, colPixelsOnASide], pixelRow, pixelCol);
        crossSectionValues(r) = compute_prf_array(prfObject, pixelSubRowCoords, pixelSubColCoords, ...
            pixelIndex, subRowIndex, subColIndex);        
    else
        pixelIndex = sub2ind([rowPixelsOnASide, colPixelsOnASide], pixelCol, pixelRow);
        crossSectionValues(r) = compute_prf_array(prfObject, pixelSubColCoords, pixelSubRowCoords, ...
            pixelIndex, subColIndex, subRowIndex);        
    end
    crossSectionLocation(r) = rowCoords;
end

