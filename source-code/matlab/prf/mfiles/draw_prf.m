function [prfPixmesh, pixVal] = draw_prf(polys, reverse)
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
if nargin == 1
    reverse = 1;
end

resolution = 400;
rowPixelsOnASide = sqrt(size(polys, 1));
colPixelsOnASide = rowPixelsOnASide;
pointsPerRowPixel = resolution/rowPixelsOnASide;
pointsPerColPixel = resolution/colPixelsOnASide;

nSubRows = size(polys, 2);
nSubCols = size(polys, 3);

subRowSize = 1/(nSubRows);
rowCount = 1:nSubRows;
subRowStart = (rowCount - 1)*subRowSize - 0.5;
subRowEnd = rowCount*subRowSize - 0.5;

subColSize = 1/(nSubCols);
colCount = 1:nSubCols;
subColStart = (rowCount - 1)*subColSize - 0.5;
subColEnd = colCount*subColSize - 0.5;

pixmesh = zeros(resolution);
meshx = zeros(resolution);
meshy = zeros(resolution);

for r = 1:resolution
    for c = 1:resolution
        rowCoords = r/pointsPerRowPixel; % floating point pixel row position
        colCoords = c/pointsPerColPixel; % floating point pixel column position
        
        pixelRow = fix(rowCoords) + 1;
        pixelCol = fix(colCoords) + 1;
        pixelSubRowCoords = rowCoords + 1 - pixelRow - 0.5; % sub-row coords so 0 is in center of pixel
        pixelSubColCoords = colCoords + 1 - pixelCol - 0.5; % sub-row coords so 0 is in center of pixel
        if reverse
            pixelSubRowCoords = -pixelSubRowCoords;
            pixelSubColCoords = -pixelSubColCoords;
        end
        
        subRowIndex = find(pixelSubRowCoords >= subRowStart & pixelSubRowCoords < subRowEnd);
        subColIndex = find(pixelSubColCoords >= subColStart & pixelSubColCoords < subColEnd);
        pixelIndex = sub2ind([rowPixelsOnASide, colPixelsOnASide], pixelRow, pixelCol);
        
        pixmesh(r,c) = weighted_polyval2d(pixelSubRowCoords, pixelSubColCoords, ...
            polys(pixelIndex, subRowIndex, subColIndex).c);
        meshx(r,c) = rowCoords;
        meshy(r,c) = colCoords;
    end
end

% compute the high-res prf centroid
flux = sum(sum(pixmesh));
hiresCentroidRow = sum(meshx(:).*pixmesh(:))/flux;
hiresCentroidCol = sum(meshy(:).*pixmesh(:))/flux;
disp(['high resolution centroid: ' num2str(hiresCentroidRow) ' ' num2str(hiresCentroidCol)]);

figure;
mesh(meshx, meshy, pixmesh);
title('nomalized pixel response function');
xlabel('row pixel');
ylabel('column pixel');
axis tight;

prfPixmesh = pixmesh;

figure;
mesh(meshx(1:end-1, 1:end-1), meshy(1:end-1, 1:end-1), ...
    pixmesh(2:end,1:end-1) - pixmesh(1:end-1,1:end-1) ...
    + pixmesh(1:end-1,2:end) - pixmesh(1:end-1,1:end-1));
title('gradient of nomalized pixel response function');
xlabel('row pixel');
ylabel('column pixel');
axis tight;

%%
% compute the high-res prf centroid
flux = sum(sum(pixmesh));
hiresCentroidRow = sum(meshx(:).*pixmesh(:))/flux;
hiresCentroidCol = sum(meshy(:).*pixmesh(:))/flux;
disp(['high resolution centroid: ' num2str(hiresCentroidRow) ' ' num2str(hiresCentroidCol)]);


%%
% sample at some central sub-pixel position
pixelSubRowCoords = -0.0;
pixelSubColCoords = -0.0;
subRowIndex = find(pixelSubRowCoords >= subRowStart & pixelSubRowCoords < subRowEnd);
subColIndex = find(pixelSubColCoords >= subColStart & pixelSubColCoords < subColEnd);
for pixelIndex = 1:121
    pixVal(pixelIndex) = weighted_polyval2d(pixelSubRowCoords, pixelSubColCoords, ...
            polys(pixelIndex, subRowIndex, subColIndex).c);
end
disp(['total flux: ' num2str(sum(pixVal))]);

pixVal = reshape(pixVal, 11, 11);
[lowResCol lowResRow] = meshgrid(1:11, 1:11);
flux = sum(sum(pixVal));
lowresCentroidRow = sum(lowResRow(:).*pixVal(:))/flux;
lowresCentroidCol = sum(lowResCol(:).*pixVal(:))/flux;
disp(['low resolution centroid: ' num2str(lowresCentroidRow) ' ' num2str(lowresCentroidCol)]);

figure;
subplot(1,2,1);
imagesc(pixVal);
colormap('hot');

subplot(1,2,2);
mesh(reshape(pixVal, 11, 11));

%%
resolution = 5000;
rowPixelsOnASide = sqrt(size(polys, 1));
colPixelsOnASide = rowPixelsOnASide;
pointsPerRowPixel = resolution/rowPixelsOnASide;
pointsPerColPixel = resolution/colPixelsOnASide;

nSubRows = size(polys, 2);
nSubCols = size(polys, 3);

subRowSize = 1/(nSubRows);
rowCount = 1:nSubRows;
subRowStart = (rowCount - 1)*subRowSize - 0.5;
subRowEnd = rowCount*subRowSize - 0.5;

subColSize = 1/(nSubCols);
colCount = 1:nSubCols;
subColStart = (rowCount - 1)*subColSize - 0.5;
subColEnd = colCount*subColSize - 0.5;

pixmesh = zeros(resolution);

c = fix(resolution/2);
for r = 1:resolution-1
    rowCoords = r/pointsPerRowPixel; % floating point pixel row position
    colCoords = c/pointsPerColPixel; % floating point pixel column position

    pixelRow = fix(rowCoords) + 1;
    pixelCol = fix(colCoords) + 1;
    pixelSubRowCoords = rowCoords + 1 - pixelRow - 0.5; % sub-row coords so 0 is in center of pixel
    pixelSubColCoords = colCoords + 1 - pixelCol - 0.5; % sub-row coords so 0 is in center of pixel
    if reverse
        pixelSubRowCoords = -pixelSubRowCoords;
        pixelSubColCoords = -pixelSubColCoords;
    end

    subRowIndex = find(pixelSubRowCoords >= subRowStart & pixelSubRowCoords < subRowEnd);
    subColIndex = find(pixelSubColCoords >= subColStart & pixelSubColCoords < subColEnd);
    pixelIndex = sub2ind([rowPixelsOnASide, colPixelsOnASide], pixelRow, pixelCol);

    rowSectionValues(r) = weighted_polyval2d(pixelSubRowCoords, pixelSubColCoords, ...
        polys(pixelIndex, subRowIndex, subColIndex).c);
    rowSection(r) = rowCoords;
end

r = fix(resolution/2);
for c = 1:resolution-1
    rowCoords = r/pointsPerRowPixel; % floating point pixel row position
    colCoords = c/pointsPerColPixel; % floating point pixel column position

    pixelRow = fix(rowCoords) + 1;
    pixelCol = fix(colCoords) + 1;
    pixelSubRowCoords = rowCoords + 1 - pixelRow - 0.5; % sub-row coords so 0 is in center of pixel
    pixelSubColCoords = colCoords + 1 - pixelCol - 0.5; % sub-row coords so 0 is in center of pixel
    if reverse
        pixelSubRowCoords = -pixelSubRowCoords;
        pixelSubColCoords = -pixelSubColCoords;
    end

    subRowIndex = find(pixelSubRowCoords >= subRowStart & pixelSubRowCoords < subRowEnd);
    subColIndex = find(pixelSubColCoords >= subColStart & pixelSubColCoords < subColEnd);
    pixelIndex = sub2ind([rowPixelsOnASide, colPixelsOnASide], pixelRow, pixelCol);

    colSectionValues(c) = weighted_polyval2d(pixelSubRowCoords, pixelSubColCoords, ...
        polys(pixelIndex, subRowIndex, subColIndex).c);
    colSection(c) = colCoords;
end
deltaRow = rowSection(2) - rowSection(1);
deltaCol = colSection(2) - colSection(1);
figure
plot(rowSection, rowSectionValues, colSection, colSectionValues);
legend('row cross section', 'column cross section');

figure
plot(rowSection(1:end-1), diff(rowSectionValues), ...
    colSection(1:end-1), diff(colSectionValues));
legend('row cross section difference', 'column cross section difference');

