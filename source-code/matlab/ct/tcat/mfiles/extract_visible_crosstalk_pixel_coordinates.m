function [parallelXtalkPixelStruct, frameTransferXtalkPixelStruct]  = ...
    extract_visible_crosstalk_pixel_coordinates(tcatInputDataStruct, xTalkOutputStruct)
%______________________________________________________________________
% function [parallelXtalkPixelStruct, frameTransferXtalkPixelStruct]  = ...
%     extract_visible_crosstalk_pixel_coordinates(tcatInputDataStruct, xTalkOutputStruct)
% This function extracts parallel and frame transfer cross talk pixels in the
% visible CCD
%______________________________________________________________________
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


nModOuts = tcatInputDataStruct.fcConstantsStruct.MODULE_OUTPUTS;

numberOfFgsFramePixels = xTalkOutputStruct.numberOfFgsFramePixels;

numberOfFgsParallelPixels = xTalkOutputStruct.numberOfFgsParallelPixels;

fgsFramePixelValues = xTalkOutputStruct.fgsFramePixelValues;

fgsParallelPixelValues = xTalkOutputStruct.fgsParallelPixelValues;

fgsXtalkIndexImage = xTalkOutputStruct.fgsXtalkIndexImage;

parallelXtalkPixelStruct = repmat(struct('pixelType', 'ParallelTransferCrossTalk', 'number' , [], 'valueInXtalkImage', [], ...
    'rows', [], 'columns', [], 'weightedRMSresidual',[], 'fittedThermalCoefficients1', [], 'fittedThermalCoefficients2', []),numberOfFgsParallelPixels,1) ;

frameTransferXtalkPixelStruct = repmat(struct('pixeltype', 'FrameTransferCrossTalk', 'number' , [], 'valueInXtalkImage', [], ...
    'rows',[], 'columns', [], 'weightedRMSresidual', [],  'fittedThermalCoefficients1', [], 'fittedThermalCoefficients2', []), numberOfFgsFramePixels,1);



nCcdRows = tcatInputDataStruct.fcConstantsStruct.CCD_ROWS;
nCcdColumns = tcatInputDataStruct.fcConstantsStruct.CCD_COLUMNS;



nLeadingBlack = tcatInputDataStruct.fcConstantsStruct.nLeadingBlack;
nMaskedSmear = tcatInputDataStruct.fcConstantsStruct.nMaskedSmear;

nRowsImaging = tcatInputDataStruct.fcConstantsStruct.nRowsImaging;
nColsImaging = tcatInputDataStruct.fcConstantsStruct.nColsImaging;


collateralRows1 = (1:nMaskedSmear)';
collateralRows2 = (nRowsImaging+nMaskedSmear+1:nCcdRows)';

collateralRows = [collateralRows1; collateralRows2];


collateralColumns1 = (1:nLeadingBlack)';
collateralColumns2 = (nColsImaging+nLeadingBlack+1:nCcdColumns)';

collateralColumns = [collateralColumns1; collateralColumns2];



for k = 1:numberOfFgsParallelPixels

    pixelsIndex = find(fgsXtalkIndexImage == fgsParallelPixelValues(k));

    [rows, columns] = ind2sub([nCcdRows, nCcdColumns], pixelsIndex);

    % restrict the linear index to visible region
    [intersectRows, indexOfRowsInCollateralRegion] = intersect(rows, collateralRows);

    [intersectColumns, indexOfColumnsInCollateralRegion] = intersect(columns, collateralColumns);

    indexToRemove = unique([indexOfRowsInCollateralRegion; indexOfColumnsInCollateralRegion]);

    rows(indexToRemove) = [];
    columns(indexToRemove) = [];
    pixelsIndex(indexToRemove) = [];

    parallelXtalkPixelStruct(k).number = k;
    parallelXtalkPixelStruct(k).valueInXtalkImage = fgsParallelPixelValues(k);

    parallelXtalkPixelStruct(k).rows = rows(:);
    parallelXtalkPixelStruct(k).columns = columns(:);
    parallelXtalkPixelStruct(k).linearIndex = pixelsIndex(:);

    nTotalParallelXtalkPixels = length(pixelsIndex);

    if(k == 1) % allocate memory since number of parallel cross talk pixels is known
        parallelXtalkPixelStruct(k).weightedRMSresidual = zeros(nModOuts, nTotalParallelXtalkPixels);

        parallelXtalkPixelStruct(k).fittedThermalCoefficients1 = zeros(nModOuts, nTotalParallelXtalkPixels);
        parallelXtalkPixelStruct(k).fittedThermalCoefficients2 = zeros(nModOuts, nTotalParallelXtalkPixels);
    end

end


for k = 1:numberOfFgsFramePixels

    pixelsIndex = find(xTalkOutputStruct.fgsXtalkIndexImage == fgsFramePixelValues(k));

    [rows, columns] = ind2sub([nCcdRows, nCcdColumns], pixelsIndex);


    % restrict the linear index to visible region
    [intersectRows, indexOfRowsInCollateralRegion] = intersect(rows, collateralRows);

    [intersectColumns, indexOfColumnsInCollateralRegion] = intersect(columns, collateralColumns);

    indexToRemove = unique([indexOfRowsInCollateralRegion; indexOfColumnsInCollateralRegion]);

    rows(indexToRemove) = [];
    columns(indexToRemove) = [];
    pixelsIndex(indexToRemove) = [];


    frameTransferXtalkPixelStruct(k).number = k;
    frameTransferXtalkPixelStruct(k).valueInXtalkImage = fgsFramePixelValues(k);

    % restrict the linear index to visible region
    frameTransferXtalkPixelStruct(k).rows = rows(:);
    frameTransferXtalkPixelStruct(k).columns = columns(:);
    frameTransferXtalkPixelStruct(k).linearIndex = pixelsIndex(:);

    nTotalFrameXtalkPixels = length(pixelsIndex);

    if(k == 1) % allocate memory since number of parallel cross talk pixels is known
        frameTransferXtalkPixelStruct(k).weightedRMSresidual = zeros(nModOuts, nTotalFrameXtalkPixels);

        frameTransferXtalkPixelStruct(k).fittedThermalCoefficients1 = zeros(nModOuts, nTotalFrameXtalkPixels);
        frameTransferXtalkPixelStruct(k).fittedThermalCoefficients2 = zeros(nModOuts, nTotalFrameXtalkPixels);

    end

end



for j = 1:nModOuts

    if(tcatInputDataStruct.modelFileAvailable(j))
        % load the bartOutputModelStruct structure
        eval(['load ' tcatInputDataStruct.bartModelDir '/' tcatInputDataStruct.modelFileNames{j} ' bartOutputModelStruct  ', 'bartHistoryStruct']);

        for k = 1:numberOfFgsParallelPixels

            linearIndex = parallelXtalkPixelStruct(k).linearIndex;
            parallelXtalkPixelStruct(k).fittedThermalCoefficients1(j,:) = squeeze(bartOutputModelStruct.modelCoefficients(1,linearIndex));
            parallelXtalkPixelStruct(k).fittedThermalCoefficients2(j,:) = squeeze(bartOutputModelStruct.modelCoefficients(2,linearIndex));

        end

        for k = 1:numberOfFgsFramePixels
            linearIndex = frameTransferXtalkPixelStruct(k).linearIndex;
            frameTransferXtalkPixelStruct(k).fittedThermalCoefficients1(j,:) = squeeze(bartOutputModelStruct.modelCoefficients(1,linearIndex));
            frameTransferXtalkPixelStruct(k).fittedThermalCoefficients2(j,:) = squeeze(bartOutputModelStruct.modelCoefficients(2,linearIndex));

        end
    end
end



for j = 1:nModOuts

    if(tcatInputDataStruct.diagnosticFileAvailable(j))
        % load only the bartDiagnosticsWeightStruct structure
        eval(['load ' tcatInputDataStruct.bartDiagnosticsDir '/' tcatInputDataStruct.diagnosticFileNames{j} ' bartDiagnosticsWeightStruct']);

        for k = 1:numberOfFgsParallelPixels

            linearIndex = parallelXtalkPixelStruct(k).linearIndex;
            parallelXtalkPixelStruct(k).weightedRMSresidual (j,:) = squeeze(bartDiagnosticsWeightStruct.weightedRmsResiduals(linearIndex));

        end

        for k = 1:numberOfFgsFramePixels

            linearIndex = frameTransferXtalkPixelStruct(k).linearIndex;
            frameTransferXtalkPixelStruct(k).weightedRMSresidual (j,:) = squeeze(bartDiagnosticsWeightStruct.weightedRmsResiduals(linearIndex));

        end
    end
end

return
