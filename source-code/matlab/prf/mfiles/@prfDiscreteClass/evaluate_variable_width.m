function [pixelArray, rowArray, columnArray, pixelUncertainty] = evaluate(prfObject, row, column, rows, columns, xform, polyBasis)
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

if nargin >= 6
	if size(xform, 1) == 1
		xform = xform*eye(2);
	end
end

if nargin >= 4 && ~isempty(rows) && ~isempty(columns)
%	keyboard;
	v = inv(xform)*[columns' - column; rows' - row];
    pixelArray = interp2(prfObject.arrayCol, prfObject.arrayRow, prfObject.prfArray, ...
        v(1,:), v(2,:), '*linear', 0)';   
    
    rowArray = rows;
    columnArray = columns;
    return
end
rows = [];
columns = [];
polyBasis = [];

prfParentObject = prfObject.prfClass;

[dataRows subRow dataCols subCol] = set_row_column(prfParentObject, ...
    prfObject.nPrfArrayRows,  prfObject.nPrfArrayCols, ...
    row, column, rows, columns);

rowArray = dataRows;
columnArray = dataCols;

if subRow < 0
    dataRows = dataRows - 1;
end
if subCol < 0
    dataCols = dataCols - 1;
end

dataRows = dataRows - fix(row);
dataCols = dataCols - fix(column);

% the total transformation of the inputs for the interp2 call are:
% for row/column:
%	subRow = frac(row), subtract 1 if frac(row) >= 0.5 (putting it in range [-0.5 to 0) on next pixel)
%	dataRows = fix(row), add 1 if frac(row) >= 0.5 (to shift to next pixel because frac(row) = 0 is center of pixel)
% for rows/columns:
%	dataRows = rows (these are integer row coordinate indices)
% 	if fix(rows) >= 0.5, dataRows = dataRows - 1 (shifts rows to match the centered coordinate system)
%	dataRows = dataRows - fix(row) (puts index relative to the index of the row containg the star)
%
% The interpolation is then from 
%	dataRows - subRow 
%	for frac(row) < 0.5, this is rows - fix(row) - frac(row) = rows - (fix(row) + frac(row)) = rows - row
%	for frac(row) > 0.5, this is rows - 1 - fix(row) - (frac(row) - 1) = rows - (fix(row) + frac(row)) = rows - row
%

v = inv(xform)*[dataCols' - subCol; dataRows' - subRow];
pixelArray = interp2(prfObject.arrayCol, prfObject.arrayRow, prfObject.prfArray, ...
    v(1,:), v(2,:), '*linear', 0)';

