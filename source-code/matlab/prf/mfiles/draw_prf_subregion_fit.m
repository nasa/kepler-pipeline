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
nSubPixelRows = size(prfStructureVector(3).subPixelData, 2);
nSubPixelCols = size(prfStructureVector(3).subPixelData, 3);
subRowSize = 1/(nSubPixelRows);
rowCount = 1:nSubPixelRows;
subRowStart = (rowCount - 1)*subRowSize - 0.5;
subRowEnd = rowCount*subRowSize - 0.5;

subColSize = 1/(nSubPixelCols);
colCount = 1:nSubPixelCols;
subColStart = (colCount - 1)*subColSize - 0.5;
subColEnd = colCount*subColSize - 0.5;

subRow = 2;
subCol = 3;
pixel = 61;
prfNumber = 3;

pixData = prfStructureVector(prfNumber).subPixelData(pixel, subRow, subCol);
figure('Color', 'white');
plot3(pixData.subRows, pixData.subCols, pixData.values, '+');
hold on;
vr = linspace(subRowStart(subRow), subRowEnd(subRow), 10);
vc = linspace(subColStart(subCol), subColEnd(subCol), 10);
[C, R] = meshgrid(vc, vr);
V = weighted_polyval2d(R(:), C(:), ...
    prfStructureVector(prfNumber).prfPolyStructure.polyCoeffStruct(pixel, subRow, subCol).c);
V = reshape(V, 10, 10);
mesh(R,C, V);
title('polynomial fit and fitted data for a sub-pixel region');
xlabel('sub-row coordinate');
ylabel('sub-column coordinate');
zlabel('observed relative flux');


