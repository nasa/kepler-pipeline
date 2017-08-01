function [retPixelArray, rowArray, columnArray] ...
    = evaluate_variable_width(prfObject, row, column, rows, columns, width, polyBasis)
% function [pixelArray, rowArray, columnArray] ...
%     = evaluate_variable_width(prfObject, row, column, rows, columns, width, polyBasis)
% 
% evaluate the prf at the specified row, column.  Optional arguments rows
% and columns specify pixels to evalute on.  If these are missing or empty
% the PRF is evaluated on a standard array.  Optional argument polyBasis
% overrides the design matrix based on row and column.
%
% NOTE: returned uncertainties have been code-inspected but not thoroughly
% tested.  Use with caution, and request that such testing be done if your
% use of uncertainties is critical.
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

if nargin < 6
    width = 1;
end

% disp(['row ' num2str(row) ', column ' num2str(column)]);
pixRow = fix(row);
pixCol = fix(column);
subRow = row - fix(row);
if subRow >= 0.5
    subRow = subRow - 1;
    pixRow = pixRow + 1;
end
subCol = column - fix(column);
if subCol >= 0.5
    subCol = subCol - 1;
    pixCol = pixCol + 1;
end

if nargin < 4 || isempty(rows) || isempty(columns) % we are not given rows and columns to evaluate the prf on
    halfRow = fix(prfObject.nPrfArrayRows/2);
    halfCol = fix(prfObject.nPrfArrayCols/2);
    [columns, rows] = meshgrid(pixCol + (-halfCol:halfCol), pixRow + (-halfRow:halfRow));
    rows = rows(:);
    columns = columns(:);
end

centralRow = fix(prfObject.nPrfArrayRows/2) + 1;
centralCol = fix(prfObject.nPrfArrayCols/2) + 1;
dataRows = rows - fix(row) + centralRow;
dataCols = columns - fix(column) + centralCol;
if subRow < 0
    dataRows = dataRows - 1;
end
if subCol < 0
    dataCols = dataCols - 1;
end

% transform to star perspective, where the PRF looks like a PSF
dataRowsStars = dataRows;
dataColsStars = dataCols;
dataSubRowsStars = -subRow;
dataSubColsStars = -subCol;

% perform contraction scaling around central pixel
% dataRowsStarScaled = (dataRowsStars - (centralRow + dataSubRowsStars))/width + centralRow + dataSubRowsStars;
% dataColsStarScaled = (dataColsStars - (centralCol + dataSubColsStars))/width + centralCol + dataSubColsStars;
row0 = centralRow + dataSubRowsStars;
col0 = centralCol + dataSubColsStars;
dataRowsStarScaledVal = (dataRowsStars + dataSubRowsStars - row0)/width + row0;
dataColsStarScaledVal = (dataColsStars + dataSubColsStars - col0)/width + col0;

dataRowsStarScaled = fix(dataRowsStarScaledVal);
dataSubRowsStarScaled = dataRowsStarScaledVal - fix(dataRowsStarScaledVal);
wrapIdx = find(dataSubRowsStarScaled >= 0.5);
dataRowsStarScaled(wrapIdx) = dataRowsStarScaled(wrapIdx) + 1;
dataSubRowsStarScaled(wrapIdx) = dataSubRowsStarScaled(wrapIdx) - 1;

dataColsStarScaled = fix(dataColsStarScaledVal);
dataSubColsStarScaled = dataColsStarScaledVal - fix(dataColsStarScaledVal);
wrapIdx = find(dataSubColsStarScaled >= 0.5);
dataColsStarScaled(wrapIdx) = dataColsStarScaled(wrapIdx) + 1;
dataSubColsStarScaled(wrapIdx) = dataSubColsStarScaled(wrapIdx) - 1;


% figure;
% plot(dataRowsStars + dataSubRowsStars, dataColsStars + dataSubColsStars, '+', ...
%     dataRowsStarScaled + dataSubRowsStarScaled, dataColsStarScaled + dataSubColsStarScaled, 'o');
% set(gca, 'xtick', 1:prfObject.nPrfArrayRows);
% set(gca, 'ytick', 1:prfObject.nPrfArrayCols);
% grid on
% transform back to pixel perspective
dataRowsScaled = dataRowsStarScaled;
dataColsScaled = dataColsStarScaled;
dataSubRowsScaled = -dataSubRowsStarScaled;
dataSubColsScaled = -dataSubColsStarScaled;

% figure
% plot(dataRowsStars + dataSubRowsStars, dataColsStars + dataSubColsStars, '+', ...
%     dataRowsStarScaledVal, dataColsStarScaledVal, 'ro', ...
%     dataRowsScaled+dataSubRowsScaled, dataColsScaled+dataSubColsScaled, 'gd');
% set(gca, 'YTick', 0.5:prfObject.nPrfArrayRows+.5);
% set(gca, 'XTick', 0.5:prfObject.nPrfArrayCols+.5);
% grid on;

% figure;
% plot(dataRows + subRow, dataCols + subCol, '+', ...
%     dataRowsScaled + dataSubRowsScaled, dataColsScaled + dataSubColsScaled, 'o');
% set(gca, 'xtick', 1:prfObject.nPrfArrayRows);
% set(gca, 'ytick', 1:prfObject.nPrfArrayCols);
% grid on

% fast way to evaluate the PRF polynomials
% select the rows and columns on the PRF array
goodDataIndex = find(dataRows <= prfObject.nPrfArrayRows & dataRows >= 1 ...
    & dataCols <= prfObject.nPrfArrayCols & dataCols >= 1);
goodDataRows = dataRows(goodDataIndex);
goodDataCols = dataCols(goodDataIndex);
	
originalPixelIndex0 = sub2ind([prfObject.nPrfArrayRows, ...
    prfObject.nPrfArrayCols], goodDataRows, goodDataCols);

% keep the scaled arrays parallel
goodDataRowsScaled0 = dataRowsScaled(goodDataIndex);
goodDataSubRowsScaled0 = dataSubRowsScaled(goodDataIndex);
goodDataColsScaled0 = dataColsScaled(goodDataIndex);
goodDataSubColsScaled0 = dataSubColsScaled(goodDataIndex);

% select scaled rows and columns on the array
goodScaledDataIndex = find(goodDataRowsScaled0 <= prfObject.nPrfArrayRows & goodDataRowsScaled0 >= 1 ...
    & goodDataColsScaled0 <= prfObject.nPrfArrayCols & goodDataColsScaled0 >= 1);
goodDataRowsScaled = goodDataRowsScaled0(goodScaledDataIndex);
goodDataSubRowsScaled = goodDataSubRowsScaled0(goodScaledDataIndex);
goodDataColsScaled = goodDataColsScaled0(goodScaledDataIndex);
goodDataSubColsScaled = goodDataSubColsScaled0(goodScaledDataIndex);

% keep the original pixel index in parallel
originalPixelIndex = originalPixelIndex0(goodScaledDataIndex);

scaledPixelIndex = sub2ind([prfObject.nPrfArrayRows, ...
    prfObject.nPrfArrayCols], goodDataRowsScaled, goodDataColsScaled);

for i=1:length(goodDataSubRowsScaled)
    subRowIndex(i) = find(goodDataSubRowsScaled(i) > prfObject.subRowStart ...
        & goodDataSubRowsScaled(i) <= prfObject.subRowEnd);
end
for i=1:length(goodDataSubColsScaled)
    subColIndex(i) = find(goodDataSubColsScaled(i) > prfObject.subColStart ...
        & goodDataSubColsScaled(i) <= prfObject.subColEnd);
end

pixelArray = zeros(length(rows), 1);

if isempty(originalPixelIndex) || isempty(subRowIndex) || isempty(subColIndex)
	warning('prfClass.evaluate: input data not consistent with prf');
	pixelArray = [];
	rowArray = [];
	columnArray = [];
	return;
end

if nargin < 7 || isempty(polyBasis)
    pixelArray = compute_prf_array_variable_width(prfObject, ...
        goodDataSubRowsScaled, goodDataSubColsScaled, ...
        originalPixelIndex, scaledPixelIndex, ...
        subRowIndex, subColIndex, size(scaledPixelIndex));
else
    pixelArray(goodDataIndex) = polyBasis...
        * prfObject.coefficientMatrix(:,scaledPixelIndex, subRowIndex, subColIndex);        
end

% extract original data pixels
% retPixelArray = zeros(size(pixelArray));
retPixelArray = zeros(size(rows));
retPixelArray(goodScaledDataIndex) = pixelArray;
% retPixelArray = zeros(size(originalPixelIndex0));
% retPixelArray(originalPixelIndex0(goodScaledDataIndex)) = pixelArray(originalPixelIndex0(goodScaledDataIndex));
% 
rowArray = rows;
columnArray = columns;
% imagesc(rows(1:11), columns(1:11:end), reshape(pixelArray, 11, 11));

