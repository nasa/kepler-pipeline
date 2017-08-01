% load your prfResultData_... .mat file first
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

subPixelData = prfStructureVector.subPixelData;

%%

nPixels = size(subPixelData, 1);
nSubRows = size(subPixelData, 2);
nSubCols = size(subPixelData, 3);

subRows = [];
subCols = [];
values = [];
model = [];
residuals = [];

for pr = 3:9
    for pc = 3:9
        pixel = sub2ind([11,11], pr, pc);
        for r=1:nSubRows
            for c=1:nSubCols
                subRows = [subRows; pr + 0.5 - subPixelData(pixel, r, c).subRows];
                subCols = [subCols; pc + 0.5 - subPixelData(pixel, r, c).subCols];
                values = [values; subPixelData(pixel, r, c).values];
                model = [model; subPixelData(pixel, r, c).modelPixelValues];
                residuals = [residuals; subPixelData(pixel, r, c).residuals];
            end
        end
    end
end

randomOrder = randperm(length(subRows));
numToDraw = min([length(values), 1e5]);
pointsToDraw = randomOrder(1:numToDraw);
randomOrderModel = randperm(length(model));
numToDrawModel = min([length(model), 1e5]);
pointsToDrawModel = randomOrderModel(1:numToDrawModel);
figure
plot3(subRows(pointsToDraw), subCols(pointsToDraw), model(pointsToDraw), '+');
figure
plot3(subRows(pointsToDraw), subCols(pointsToDraw), values(pointsToDraw), '+');
randomOrder = randperm(length(residuals));
numToDraw = min([length(residuals), 1e5]);
pointsToDraw = randomOrder(1:numToDraw);
figure
plot3(subRows(pointsToDraw), subCols(pointsToDraw), residuals(pointsToDraw), '+');

%%

subPixelData = prfStructureVector.subPixelData;

orderRowPos = [];
orderColPos = [];
orderRow = [];
orderCol = [];
orderSubRow = [];
orderSubCol = [];
orderValue = [];

for pr = 1:11
    for pc = 1:11
        pixel = sub2ind([11,11], pr, pc);
        for r=1:nSubRows
            for c=1:nSubCols
                orderRowPos = [orderRowPos; (r-1)/(nSubRows-1) + pr];
                orderColPos = [orderColPos; (c-1)/(nSubCols-1) + pc];
                orderRow = [orderRow; pr];
                orderCol = [orderCol; pc];
                orderSubRow = [orderSubRow; r];
                orderSubCol = [orderSubCol; c];
                orderValue = [orderValue; subPixelData(pixel, r, c).selectedOrder];
            end
        end
    end
end

figure;
plot3(orderRowPos, orderColPos, orderValue, '+');

