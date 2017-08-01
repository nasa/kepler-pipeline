function plot_celestial_axis(locationOfObjectsInBoundingBox, id, label, ...
rowRange, columnRange)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function plot_celestial_axis(locationOfObjectsInBoundingBox, id, label, ...
% rowRange, columnRange)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Plot celestial axis on pixel image (in CCD coordinates). Pseudo targets
% are provided 1 arsecond north of the target (id = -1) and 1 arcsecond
% east of the target (id = -2). Declination is aligned with the north axis
% and right ascension is aligned with the east axis. Mark the axis with the
% specified label. The row range and column range of the pixel image must
% also be specified (min:max).
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

% Return if there is insufficient information to plot axis.
if isempty(locationOfObjectsInBoundingBox)
    return
end % if

% Get min and max row and column coordinates.
minRow = min(rowRange);
maxRow = max(rowRange);
minColumn = min(columnRange);
maxColumn = max(columnRange);

% Get target row and column (0-based). Return if target is not actually in
% bounding box. This can happen.
targetIndex = find([locationOfObjectsInBoundingBox.isPrimaryTarget], 1);
if isempty(targetIndex)
    return
end % if
targetRow = locationOfObjectsInBoundingBox(targetIndex).zeroBasedRow;
targetColumn = locationOfObjectsInBoundingBox(targetIndex).zeroBasedColumn;

% Get pseudo-target row and column. Return if object does not exist.
objectIndex = find([locationOfObjectsInBoundingBox.keplerId] == id, 1);
if isempty(objectIndex)
    return
end % if

objectRow = locationOfObjectsInBoundingBox(objectIndex).zeroBasedRow;
objectColumn = locationOfObjectsInBoundingBox(objectIndex).zeroBasedColumn;

% Get inside and outside coordinates for intersection of direction axis
% with outer pixel halo.
[insideRow, insideColumn] = ...
    compute_intersection_coordinates( ...
    targetRow, targetColumn, objectRow, objectColumn, ...
    minRow+0.4, maxRow-0.4, minColumn+0.4, maxColumn-0.4);

[outsideRow, outsideColumn] = ...
    compute_intersection_coordinates( ...
    targetRow, targetColumn, objectRow, objectColumn, ...
    minRow-0.5, maxRow+0.5, minColumn-0.5, maxColumn+0.5);

% Plot the axis.
plot([insideColumn; outsideColumn], [insideRow; outsideRow], '-y', ...
    'Linewidth', 2);
text((insideColumn+outsideColumn)/2 + 0.3, (insideRow+outsideRow)/2, ...
    label, 'Color', 'yellow');
    
% Return.
return


function [row, column] = compute_intersection_coordinates( ...
targetRow, targetColumn, objectRow, objectColumn, ...
lowRow, highRow, lowColumn, highColumn)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [row, column] = compute_intersection_coordinates( ...
% targetRow, targetColumn, objectRow, objectColumn, ...
% lowRow, highRow, lowColumn, highColumn)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Find CCD coordinates of the intersection between the celestial axis and
% the specified box. The axis will be drawn from the intersection with the
% box inside the outer pixel halo to the box outside the pixel halo.
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

% Compute slope of axis.
slope = (objectRow - targetRow) / (objectColumn - targetColumn);

% Determine where axis intersects bounding box. The desired point is the
% closer of the intersections with the appropriate row and column.
if objectRow > targetRow 
    r0 = highRow;
else  
    r0 = lowRow;    
end % if / else

c0 = (r0 - targetRow) / slope + targetColumn;
d0 = sqrt((r0 - targetRow)^2 + (c0 - targetColumn)^2);
    
if objectColumn > targetColumn
    c1 = highColumn;
else
    c1 = lowColumn;
end % if / else
    
r1 = slope * (c1 - targetColumn) + targetRow;
d1 = sqrt((r1 - targetRow)^2 + (c1 - targetColumn)^2);
    
if d0 < d1
    row = r0;
    column = c0;
else
    row = r1;
    column = c1;
end % if / else
    
% Return.
return
