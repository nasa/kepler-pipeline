function [pixelArray, rowArray, columnArray, pixelUncertainty] = evaluate(prfObject, row, column, rows, columns, polyBasis)
% function [pixelArray, rowArray, columnArray] = evaluate(prfObject, row, column, rows, columns, polyBasis)
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

if nargin < 4
    rows = [];
    columns = [];
    polyBasis = [];
end

prfParentObject = prfObject.prfClass;

[dataRows subRow dataCols subCol] = set_row_column(prfParentObject, ...
    prfObject.nPrfArrayRows,  prfObject.nPrfArrayCols, ...
    row, column, rows, columns);

rowArray = dataRows;
columnArray = dataCols;

centralRow = fix(prfObject.nPrfArrayRows/2) + 1;
centralCol = fix(prfObject.nPrfArrayCols/2) + 1;
dataRows = dataRows - fix(row) + centralRow;
dataCols = dataCols - fix(column) + centralCol;
if subRow < 0
    dataRows = dataRows - 1;
end
if subCol < 0
    dataCols = dataCols - 1;
end

subRowIndex = find(subRow >= prfObject.subRowStart ...
    & subRow < prfObject.subRowEnd);
subColIndex = find(subCol >= prfObject.subColStart ...
    & subCol < prfObject.subColEnd);

pixelArray = zeros(length(dataRows), 1);

% fast way to evaluate the PRF polynomials
% select the rows and columns on the PRF array
goodDataIndex = find(dataRows <= prfObject.nPrfArrayRows & dataRows >= 1 ...
    & dataCols <= prfObject.nPrfArrayCols & dataCols >= 1);
goodDataRows = dataRows(goodDataIndex);
goodDataCols = dataCols(goodDataIndex);

pixelIndex = sub2ind([prfObject.nPrfArrayRows, ...
    prfObject.nPrfArrayCols], goodDataRows, goodDataCols);
	
if isempty(pixelIndex) || isempty(subRowIndex) || isempty(subColIndex)
	warning('prfClass.evaluate: input data not consistent with prf');
	pixelArray = [];
	rowArray = [];
	columnArray = [];
	return;
end

if nargin < 6 || isempty(polyBasis)
    if nargout < 4
        pixelArray(goodDataIndex) = compute_prf_array(prfObject, subRow, subCol, ...
            pixelIndex, subRowIndex, subColIndex);
    else
        [pixelArray(goodDataIndex) pixelUncertainty] ...
            = compute_prf_array(prfObject, subRow, subCol, ...
            pixelIndex, subRowIndex, subColIndex);
    end
else
    pixelArray(goodDataIndex) = polyBasis...
        * prfObject.coefficientMatrix(:,pixelIndex, subRowIndex, subColIndex);        
end
% imagesc(rows(1:11), columns(1:11:end), reshape(pixelArray, 11, 11));

