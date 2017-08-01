function prfObject = prfPolyClass(polyData, prfSpecification, prfParentObject)
% function prfObject = prfPolyClass(polyData, prfParentObject)
% 
% instantiator for the PRF class
% required fields: polyData can be either: 
%   - a polyStruct PRF polynomial structure
% or
%   - a 4-dimensional coefficient matrix with dimensions
%       max # of coefficients x # of pixels in PRF array x # of sub rows x
%       # of sub columns
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

switch class(polyData)
    case 'struct' % assume this is the required PRF polynomial structure
        prfData = build_from_poly_structure(polyData, prfSpecification);
        
    case 'double' % assume this is a 4D coefficient matrix
        prfData = build_from_array(polyData);
        
    otherwise
        error('prfClass: bad polyData');
end

prfData.weightEffectiveZero = 0;

prfObject = class(prfData, 'prfPolyClass', prfParentObject);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function prfData = build_from_poly_structure(polyStruct, prfSpecification)
if ~isempty(prfSpecification) ...
        && strcmp(prfSpecification.type, 'PRF_POLY_WITH_UNCERTAINTIES')
	prfData.polyStruct = polyStruct ;
else
    prfData.polyStruct =[];
end
prfData.type = prfSpecification.type;
prfData.nPrfArray = size(polyStruct, 1);
prfData.nSubRows = size(polyStruct, 2);
prfData.nSubColumns = size(polyStruct, 3);
prfData.nPrfArrayRows = sqrt(prfData.nPrfArray);
prfData.nPrfArrayCols = prfData.nPrfArrayRows;
prfData.subRowStart = [];
prfData.subRowEnd = [];
prfData.subColStart = [];
prfData.subColEnd = [];
prfData.maxOrder = 0;
prfData.polyType = 'not_scaled';
prfData.coefficientMatrix = [];

subRowSize = 1/(prfData.nSubRows);
rowCount = 1:prfData.nSubRows;
prfData.subRowStart = (rowCount - 1)*subRowSize - 0.5;
prfData.subRowEnd = rowCount*subRowSize - 0.5;

subColSize = 1/(prfData.nSubColumns);
colCount = 1:prfData.nSubColumns;
prfData.subColStart = (rowCount - 1)*subColSize - 0.5;
prfData.subColEnd = colCount*subColSize - 0.5;

% create packed matrix representation of the PRF polynomial coefficients
% and scaling
prfData.maxOrder = 0;
for p = 1:prfData.nPrfArray
    for r = 1:prfData.nSubRows
        for c = 1:prfData.nSubColumns
            if isfield(polyStruct(p,r,c).c, 'order')
                if polyStruct(p,r,c).c.order > prfData.maxOrder
                    prfData.maxOrder = polyStruct(p,r,c).c.order;
                end
            end
        end
    end
end

nCoefficients = (prfData.maxOrder+1)*(prfData.maxOrder+2)/2;

coefficientMatrix = zeros(nCoefficients, prfData.nPrfArray, prfData.nSubRows, ...
    prfData.nSubColumns);
scalingMatrix = zeros(6, prfData.nPrfArray, prfData.nSubRows, ...
    prfData.nSubColumns);

for p = 1:prfData.nPrfArray
    for r = 1:prfData.nSubRows
        for c = 1:prfData.nSubColumns
            coeffs = polyStruct(p,r,c).c.coeffs;
            coefficientMatrix(1:length(coeffs), p, r, c) = coeffs;
            if length(polyStruct(p,r,c).c.coeffs) > 1
                prfData.polyType = polyStruct(p,r,c).c.type;
            end
            if isfield(polyStruct(p,r,c).c, 'offsetx')
                scalingMatrix(1, p, r, c) = polyStruct(p,r,c).c.offsetx;
                scalingMatrix(2, p, r, c) = polyStruct(p,r,c).c.scalex;
                scalingMatrix(3, p, r, c) = polyStruct(p,r,c).c.originx;
                scalingMatrix(4, p, r, c) = polyStruct(p,r,c).c.offsety;
                scalingMatrix(5, p, r, c) = polyStruct(p,r,c).c.scaley;
                scalingMatrix(6, p, r, c) = polyStruct(p,r,c).c.originy;
            end
        end
    end
end

prfData.coefficientMatrix = coefficientMatrix;
prfData.scalingMatrix = scalingMatrix;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function prfData = build_from_array(coefficientMatrix)
%
% make data for a not_scaled polynomial prf based on input coefficient
% matrix
%

function prfData = build_from_array(coefficientMatrix)
if ndims(coefficientMatrix) ~= 4
    error('prfClass: coefficientMatrix wrong dimensions');
end

prfData.polyStruct = [];
prfData.type = 'PRF_POLY_WITHOUT_UNCERTAINTIES';
prfData.nPrfArray = size(coefficientMatrix, 2);
prfData.nSubRows = size(coefficientMatrix, 3);
prfData.nSubColumns = size(coefficientMatrix, 4);
prfData.nPrfArrayRows = sqrt(prfData.nPrfArray);
prfData.nPrfArrayCols = prfData.nPrfArrayRows;

subRowSize = 1/(prfData.nSubRows);
rowCount = 1:prfData.nSubRows;
prfData.subRowStart = (rowCount - 1)*subRowSize - 0.5;
prfData.subRowEnd = rowCount*subRowSize - 0.5;

subColSize = 1/(prfData.nSubColumns);
colCount = 1:prfData.nSubColumns;
prfData.subColStart = (rowCount - 1)*subColSize - 0.5;
prfData.subColEnd = colCount*subColSize - 0.5;

% determine order from number of coefficients
prfData.maxOrder = (-3+sqrt(9-4*(2-2*size(coefficientMatrix, 1))))/2;
prfData.polyType = 'not_scaled';

% a not_scaled poly type does not need a scaling matrix
prfData.coefficientMatrix = coefficientMatrix;
prfData.scalingMatrix = [];

