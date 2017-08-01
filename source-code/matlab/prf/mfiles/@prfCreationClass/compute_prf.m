function [prfCreationObject prfStructure] = compute_prf(prfCreationObject)
% function [prfCreationObject prfStructure] = compute_prf(prfCreationObject)
%
% turn off all warnings and save warning state
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
warningState = warning('off', 'all');

% do a first estimate of the PRF
[prfCreationObject prfStructure] = compute_prf_model(prfCreationObject, [0,0]);

% perform a fit of each aperture to the PRF to estimate the magnitude of
% the star in the aperture
[prfCreationObject prfObject] = fit_prf_amplitude(prfCreationObject, prfStructure);

ccdChannel = prfCreationObject.ccdChannel;
nArrayRows = prfCreationObject.prfConfigurationStruct.pixelArrayRowSize(ccdChannel);

% compute the centroid of the prf, then pass offset to the compute model
prfArrayResolution = 300;
prfArray = make_array(prfObject, prfArrayResolution);
scaleFactor = nArrayRows/prfArrayResolution; % convert array coordinates to pixel coordinates
prfSum = sum(sum(prfArray));
[colMat, rowMat] = meshgrid(1:prfArrayResolution, 1:prfArrayResolution);
prfCentroidRow = scaleFactor*sum(sum(rowMat.*prfArray))/prfSum;
prfCentroidCol = scaleFactor*sum(sum(colMat.*prfArray))/prfSum;
prfCenterRow = prfCreationObject.prfConfigurationStruct.pixelArrayRowSize(ccdChannel)/2;
prfCenterCol = prfCreationObject.prfConfigurationStruct.pixelArrayColumnSize(ccdChannel)/2;
rowOffset = prfCentroidRow - prfCenterRow;
colOffset = prfCentroidCol - prfCenterCol;

% do a final fit of the PRF
[prfCreationObject prfStructure] ...
    = compute_prf_model(prfCreationObject, [rowOffset, colOffset]);

% restore the warning state
warning(warningState);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [prfCreationObject prfStructure] = compute_prf_model(prfCreationObject, prfOffset)

ccdChannel = prfCreationObject.ccdChannel;
nArrayRows = prfCreationObject.prfConfigurationStruct.pixelArrayRowSize(ccdChannel);
nArrayCols= prfCreationObject.prfConfigurationStruct.pixelArrayColumnSize(ccdChannel);
nSubPixelRows = prfCreationObject.prfConfigurationStruct.subPixelRowResolution;
nSubPixelCols= prfCreationObject.prfConfigurationStruct.subPixelColumnResolution;
subPixelOverlap = prfCreationObject.prfConfigurationStruct.prfOverlap;
maximumPolyOrder = prfCreationObject.prfConfigurationStruct.maximumPolyOrder;
contourCutoff = prfCreationObject.prfConfigurationStruct.contourCutoff;
prfPolynomialType = prfCreationObject.prfConfigurationStruct.prfPolynomialType;

cadenceGapIndicators = prfCreationObject.cadenceTimes.gapIndicators;
goodCadences = ~cadenceGapIndicators;

prfPolyStructure.prfConfigurationStruct = prfCreationObject.prfConfigurationStruct;
prfPolyStructure.row = prfCreationObject.prfRow;
prfPolyStructure.column = prfCreationObject.prfColumn;

arrayRowCenter = fix(nArrayRows/2) + 1;
arrayColCenter = fix(nArrayCols/2) + 1;

subRowSize = 1/(nSubPixelRows);
rowCount = 1:nSubPixelRows;
subRowStart = (rowCount - 1)*subRowSize - 0.5;
subRowEnd = rowCount*subRowSize - 0.5;

subColSize = 1/(nSubPixelCols);
colCount = 1:nSubPixelCols;
subColStart = (colCount - 1)*subColSize - 0.5;
subColEnd = colCount*subColSize - 0.5;

% disp(['subRowStart = ' num2str(subRowStart)]);
% disp(['subRowEnd = ' num2str(subRowEnd)]);
% disp(['subColStart = ' num2str(subColStart)]);
% disp(['subColEnd = ' num2str(subColEnd)]);

% first accumulate data from all the targets
targetStarsStruct = prfCreationObject.targetStarsStruct;
nTargets = length(targetStarsStruct);

subPixelData = repmat(struct( ...
    'subRows', [], ...
    'subCols', [], ...
    'values', [], ...
    'uncertainties', [], ...
    'AIC', [], ...
    'selectedOrder', 0), ...
    [nArrayRows*nArrayCols, nSubPixelRows, nSubPixelCols]);

totalPixels = 0;
nCadences = length(targetStarsStruct(1).pixelTimeSeriesStruct(1).values(goodCadences));
for t=1:nTargets
    if prfCreationObject.targetStarsStruct(t).selectedTarget
        totalPixels = totalPixels + nCadences*length(targetStarsStruct(t).pixelTimeSeriesStruct);
    end
end
disp([num2str(totalPixels) ' pixel values']);

targetRowAllTargets = zeros(totalPixels,1);
targetColAllTargets = zeros(totalPixels,1);
pixelRowAllTargets = zeros(totalPixels,1);
pixelColAllTargets = zeros(totalPixels,1);
pixelArrayRowAllTargets = zeros(totalPixels,1);
pixelArrayColAllTargets = zeros(totalPixels,1);
pixelArrayRowIndexAllTargets = zeros(totalPixels,1);
pixelArrayColIndexAllTargets = zeros(totalPixels,1);
subPixelRowAllTargets = zeros(totalPixels,1);
subPixelColAllTargets = zeros(totalPixels,1);
normalizedPixelValuesAllTargets = zeros(totalPixels,1);
normalizedPixelUncertaintiesAllTargets = zeros(totalPixels,1);

rowOffset = 0.5 + prfOffset(1);
colOffset = 0.5 + prfOffset(2);
pixelCounter = 0;
for t=1:nTargets
    if prfCreationObject.targetStarsStruct(t).selectedTarget
        pixelStruct = targetStarsStruct(t).pixelTimeSeriesStruct;
        nPixels = length(pixelStruct);
        pixelsPerTarget = nPixels * nCadences;
        % extract all pixel values (242 x numPixels)
        allPixelValues = [pixelStruct.values];

        % use and extract the good cadences (121 x numPixels)
        if isempty(targetStarsStruct(t).prfFlux)
            flux = sum(allPixelValues(goodCadences, :), 2);
        else
            flux = targetStarsStruct(t).prfFlux(goodCadences);
        end
%         normalizedPixelValues = scalecol(1./flux, allPixelValues(goodCadences, :));
        normalizedPixelValues = allPixelValues(goodCadences, :)/mean(flux);
        
        % extract the uncertainties
        allPixelUncertainties = [pixelStruct.uncertainties];
        % set the gaps to inf so they drop out of the fit
        % must do this before extracting good cadences because that's the
        % index space of .gapIndices
        for p=1:nPixels
            allPixelUncertainties(pixelStruct(p).gapIndices, p) = inf;
        end
        normalizedPixelUncertainties = scalecol(1./flux, allPixelUncertainties(goodCadences, :));
        % normalizedPixelUncertainties is an nCadences x nPixels array
        % set the gaps to have infinite uncertainty so they will have 0
        % weight in the polyfit
        
        % compute the pixel rows and column on the PRF pixel array for each
        % pixel for each cadence.  pixelArrayRow is nCadences x nPixels
        % pixelRow, Col is the integer row, column of each pixel
        pixelRow = repmat([pixelStruct.row], length(targetStarsStruct(t).row(goodCadences)), 1);
        pixelCol = repmat([pixelStruct.column], length(targetStarsStruct(t).column(goodCadences)), 1);
        % targetRow, Col is the floating point row and column of the star's
        % projected position on the pixel, and contains the sub-pixel
        % position
        targetRow = repmat(targetStarsStruct(t).row(goodCadences)', 1, length([pixelStruct.row])) + rowOffset;
        targetCol = repmat(targetStarsStruct(t).column(goodCadences)', 1, length([pixelStruct.column])) + colOffset;
        
        %
        % register each pixel's data onto the prf array so that the star's
        % projected position is on the central pixel
        %
        
        % pixelArrayRow, Col is the integer row, column of each pixels's
        % data
        pixelArrayRow = pixelRow - fix(targetRow) + arrayRowCenter;
        pixelArrayCol = pixelCol - fix(targetCol) + arrayColCenter;

        % compute the sub-pixel position for each pixel for each cadence,
        % transforming the sub-pixel coordinates to [-0.5, 0.5] so a
        % sub-pixel position of 0 is in the center of the pixel
        subPixelRow = targetRow - fix(targetRow) - 0.5;
        subPixelCol = targetCol - fix(targetCol) - 0.5;

        % compute the pixel indices relative to the PRF pixel array
        pixelArrayRowIndex = fix(pixelArrayRow);
        pixelArrayColIndex = fix(pixelArrayCol);

        currentPixelRange = pixelCounter+1:pixelCounter+pixelsPerTarget;
        targetRowAllTargets(currentPixelRange) = targetRow(:);
        targetColAllTargets(currentPixelRange) = targetCol(:);
        pixelRowAllTargets(currentPixelRange) = pixelRow(:);
        pixelColAllTargets(currentPixelRange) = pixelCol(:);
        
        pixelArrayRowAllTargets(currentPixelRange) = pixelArrayRow(:);
        pixelArrayColAllTargets(currentPixelRange) = pixelArrayCol(:);
        pixelArrayRowIndexAllTargets(currentPixelRange) = pixelArrayRowIndex(:);
        pixelArrayColIndexAllTargets(currentPixelRange) = pixelArrayColIndex(:);
        subPixelRowAllTargets(currentPixelRange) = subPixelRow(:);
        subPixelColAllTargets(currentPixelRange) = subPixelCol(:);
        normalizedPixelValuesAllTargets(currentPixelRange) ...
            = normalizedPixelValues(:);
        normalizedPixelUncertaintiesAllTargets(currentPixelRange) ...
            = normalizedPixelUncertainties(:);

        pixelCounter = pixelCounter + pixelsPerTarget;
    end
end

% compute the centroid of the data
flux = sum(normalizedPixelValuesAllTargets);
dataCentroidRow = sum((pixelRowAllTargets - targetRowAllTargets + arrayRowCenter - 0.5).*normalizedPixelValuesAllTargets)/flux;
dataCentroidCol = sum((pixelColAllTargets - targetColAllTargets + arrayColCenter - 0.5).*normalizedPixelValuesAllTargets)/flux;
disp(['data centroid at ' num2str([dataCentroidRow dataCentroidCol])]);

% trim the entries that are off the array
offArrayIndex = find( ...
    pixelArrayRowIndexAllTargets < 1 ...
    | pixelArrayRowIndexAllTargets > nArrayRows ...
    | pixelArrayColIndexAllTargets < 1 ...
    | pixelArrayColIndexAllTargets > nArrayCols);
pixelRowAllTargets(offArrayIndex) = [];
pixelColAllTargets(offArrayIndex) = [];
subPixelRowAllTargets(offArrayIndex) = [];
subPixelColAllTargets(offArrayIndex) = [];
pixelArrayRowIndexAllTargets(offArrayIndex) = [];
pixelArrayColIndexAllTargets(offArrayIndex) = [];
normalizedPixelValuesAllTargets(offArrayIndex) = [];
normalizedPixelUncertaintiesAllTargets(offArrayIndex) = [];

pixelArrayIndexAllTargets = sub2ind([nArrayRows, nArrayCols], ...
    pixelArrayRowIndexAllTargets(:), pixelArrayColIndexAllTargets(:));
clear pixelArrayRowIndexAllTargets pixelArrayColIndexAllTargets

% initialize the data structures
for subRow = 1:nSubPixelRows
    for subCol = 1:nSubPixelCols
        for arrayPixel = 1:nArrayRows*nArrayCols
            prfPolyStructure.polyCoeffStruct(arrayPixel, subRow, subCol).c ...
                = make_weighted_poly(2, 0, 1,prfPolynomialType);            
            prfPolyStructure.polyCoeffStruct(arrayPixel, subRow, subCol).nelements = 0;
            prfPolyStructure.polyCoeffStruct(arrayPixel, subRow, subCol).order = 0;
            prfPolyStructure.polyCoeffStruct(arrayPixel, subRow, subCol).numRows = nArrayRows;
            prfPolyStructure.polyCoeffStruct(arrayPixel, subRow, subCol).numCols = nArrayCols;
        end
    end
end



% assign this sub-pixel position to a sub-pixel bin
for subRow = 1:nSubPixelRows
    t1 = clock;
    for subCol = 1:nSubPixelCols

        % find the data point in this sub-row region
        % subPixIndex gives the index of the pixel in this sub-pixel
        % region for each cadence
        for arrayPixel = 1:nArrayRows*nArrayCols
            subPixIndex = find(subPixelRowAllTargets >= subRowStart(subRow) - subPixelOverlap ...
                & subPixelRowAllTargets < subRowEnd(subRow) + subPixelOverlap ...
                & subPixelColAllTargets >= subColStart(subCol) - subPixelOverlap ...
                & subPixelColAllTargets <= subColEnd(subCol) + subPixelOverlap ...
                & pixelArrayIndexAllTargets == arrayPixel);
            
            subPixelData(arrayPixel, subRow, subCol).pixelRows ...
                = pixelRowAllTargets(subPixIndex);            
            subPixelData(arrayPixel, subRow, subCol).pixelCols ...
                = pixelColAllTargets(subPixIndex);            
            subPixelData(arrayPixel, subRow, subCol).subRows ...
                = subPixelRowAllTargets(subPixIndex);            
            subPixelData(arrayPixel, subRow, subCol).subCols ...
                = subPixelColAllTargets(subPixIndex);            
            subPixelData(arrayPixel, subRow, subCol).values ...
                = normalizedPixelValuesAllTargets(subPixIndex);
            subPixelData(arrayPixel, subRow, subCol).uncertainties ...
                = normalizedPixelUncertaintiesAllTargets(subPixIndex);

            % now add data on adjacent pixels
            [arrayRow, arrayCol] = ind2sub([nArrayRows, nArrayCols], arrayPixel);
            
            % check the rows first
            % on the top edge of a pixel
            if subRow == 1 && arrayRow < nArrayRows % punt on bottom edge of array
                % convert the subRow coordinates as r -> r - 1 and look on
                % row below
                newSubPixIndex = find(subPixelRowAllTargets - 1 >= subRowStart(subRow) - subPixelOverlap ...
                & subPixelColAllTargets >= subColStart(subCol) - subPixelOverlap ...
                & subPixelColAllTargets <= subColEnd(subCol) + subPixelOverlap ...
                & pixelArrayIndexAllTargets == sub2ind([nArrayRows, nArrayCols], arrayRow+1, arrayCol));
                if ~isempty(newSubPixIndex)
                    subPixelData(arrayPixel, subRow, subCol).pixelRows ...
                        = [subPixelData(arrayPixel, subRow, subCol).pixelRows; ...
                        pixelRowAllTargets(newSubPixIndex) - 1];            
                    subPixelData(arrayPixel, subRow, subCol).pixelCols ...
                        = [subPixelData(arrayPixel, subRow, subCol).pixelCols; ...
                        pixelColAllTargets(newSubPixIndex)];            
                    subPixelData(arrayPixel, subRow, subCol).subRows ...
                        = [subPixelData(arrayPixel, subRow, subCol).subRows; ...
                        subPixelRowAllTargets(newSubPixIndex) - 1];            
                    subPixelData(arrayPixel, subRow, subCol).subCols ...
                        = [subPixelData(arrayPixel, subRow, subCol).subCols; ...
                        subPixelColAllTargets(newSubPixIndex)];            
                    subPixelData(arrayPixel, subRow, subCol).values ...
                        = [subPixelData(arrayPixel, subRow, subCol).values; ...
                        normalizedPixelValuesAllTargets(newSubPixIndex)];
                    subPixelData(arrayPixel, subRow, subCol).uncertainties ...
                        = [subPixelData(arrayPixel, subRow, subCol).uncertainties; ...
                        normalizedPixelUncertaintiesAllTargets(newSubPixIndex)];
                end
            % on the bottom edge of the pixel
            elseif subRow == nSubPixelRows && arrayRow > 1 % punt on top edge
                % convert the subRow coordinates as r -> r + 1 and look on
                % row above
                newSubPixIndex = find(subPixelRowAllTargets + 1 < subRowEnd(subRow) + subPixelOverlap ...
                & subPixelColAllTargets >= subColStart(subCol) - subPixelOverlap ...
                & subPixelColAllTargets <= subColEnd(subCol) + subPixelOverlap ...
                & pixelArrayIndexAllTargets == sub2ind([nArrayRows, nArrayCols], arrayRow-1, arrayCol));                
                if ~isempty(newSubPixIndex)
                    subPixelData(arrayPixel, subRow, subCol).pixelRows ...
                        = [subPixelData(arrayPixel, subRow, subCol).pixelRows; ...
                        pixelRowAllTargets(newSubPixIndex) + 1];            
                    subPixelData(arrayPixel, subRow, subCol).pixelCols ...
                        = [subPixelData(arrayPixel, subRow, subCol).pixelCols; ...
                        pixelColAllTargets(newSubPixIndex)];            
                    subPixelData(arrayPixel, subRow, subCol).subRows ...
                        = [subPixelData(arrayPixel, subRow, subCol).subRows; ...
                        subPixelRowAllTargets(newSubPixIndex) + 1];            
                    subPixelData(arrayPixel, subRow, subCol).subCols ...
                        = [subPixelData(arrayPixel, subRow, subCol).subCols; ...
                        subPixelColAllTargets(newSubPixIndex)];            
                    subPixelData(arrayPixel, subRow, subCol).values ...
                        = [subPixelData(arrayPixel, subRow, subCol).values; ...
                        normalizedPixelValuesAllTargets(newSubPixIndex)];
                    subPixelData(arrayPixel, subRow, subCol).uncertainties ...
                        = [subPixelData(arrayPixel, subRow, subCol).uncertainties; ...
                        normalizedPixelUncertaintiesAllTargets(newSubPixIndex)];
                end
            end
            
            % check the columns
            % on the right edge of a pixel
            if subCol == 1 && arrayCol < nArrayCols % punt on right edge of array
                % convert the subCol coordinates as c -> c - 1 and look on
                % col below
                newSubPixIndex = find(subPixelColAllTargets - 1 >= subColStart(subCol) - subPixelOverlap ...
                & subPixelRowAllTargets >= subRowStart(subRow) - subPixelOverlap ...
                & subPixelRowAllTargets <= subRowEnd(subRow) + subPixelOverlap ...
                & pixelArrayIndexAllTargets == sub2ind([nArrayRows, nArrayCols], arrayRow, arrayCol+1));
                if ~isempty(newSubPixIndex)
                    subPixelData(arrayPixel, subRow, subCol).pixelRows ...
                        = [subPixelData(arrayPixel, subRow, subCol).pixelRows; ...
                        pixelRowAllTargets(newSubPixIndex)];            
                    subPixelData(arrayPixel, subRow, subCol).pixelCols ...
                        = [subPixelData(arrayPixel, subRow, subCol).pixelCols; ...
                        pixelColAllTargets(newSubPixIndex) - 1];            
                    subPixelData(arrayPixel, subRow, subCol).subRows ...
                        = [subPixelData(arrayPixel, subRow, subCol).subRows; ...
                        subPixelRowAllTargets(newSubPixIndex)];            
                    subPixelData(arrayPixel, subRow, subCol).subCols ...
                        = [subPixelData(arrayPixel, subRow, subCol).subCols; ...
                        subPixelColAllTargets(newSubPixIndex) - 1];            
                    subPixelData(arrayPixel, subRow, subCol).values ...
                        = [subPixelData(arrayPixel, subRow, subCol).values; ...
                        normalizedPixelValuesAllTargets(newSubPixIndex)];
                    subPixelData(arrayPixel, subRow, subCol).uncertainties ...
                        = [subPixelData(arrayPixel, subRow, subCol).uncertainties; ...
                        normalizedPixelUncertaintiesAllTargets(newSubPixIndex)];
                end
            % on the left edge of the pixel
            elseif subCol == nSubPixelCols && arrayCol > 1 % punt on left edge of array
                % convert the subCol coordinates as c -> c + 1 and look on
                % row above
                newSubPixIndex = find(subPixelColAllTargets + 1 < subColEnd(subCol) + subPixelOverlap ...
                & subPixelRowAllTargets >= subRowStart(subRow) - subPixelOverlap ...
                & subPixelRowAllTargets <= subRowEnd(subRow) + subPixelOverlap ...
                & pixelArrayIndexAllTargets == sub2ind([nArrayRows, nArrayCols], arrayRow, arrayCol-1));                
                if ~isempty(newSubPixIndex)
                    subPixelData(arrayPixel, subRow, subCol).pixelRows ...
                        = [subPixelData(arrayPixel, subRow, subCol).pixelRows; ...
                        pixelRowAllTargets(newSubPixIndex)];            
                    subPixelData(arrayPixel, subRow, subCol).pixelCols ...
                        = [subPixelData(arrayPixel, subRow, subCol).pixelCols; ...
                        pixelColAllTargets(newSubPixIndex) + 1];            
                    subPixelData(arrayPixel, subRow, subCol).subRows ...
                        = [subPixelData(arrayPixel, subRow, subCol).subRows; ...
                        subPixelRowAllTargets(newSubPixIndex)];            
                    subPixelData(arrayPixel, subRow, subCol).subCols ...
                        = [subPixelData(arrayPixel, subRow, subCol).subCols; ...
                        subPixelColAllTargets(newSubPixIndex) + 1];            
                    subPixelData(arrayPixel, subRow, subCol).values ...
                        = [subPixelData(arrayPixel, subRow, subCol).values; ...
                        normalizedPixelValuesAllTargets(newSubPixIndex)];
                    subPixelData(arrayPixel, subRow, subCol).uncertainties ...
                        = [subPixelData(arrayPixel, subRow, subCol).uncertainties; ...
                        normalizedPixelUncertaintiesAllTargets(newSubPixIndex)];
                end
            end
            
            if isempty(subPixIndex) || length(subPixIndex) < (maximumPolyOrder+1)*(maximumPolyOrder+2)/2
                % this subpixel is partially off the 11 x 11 array (likely
                % due to centering the centroid) so set to zero polynomial
                prfPolyStructure.polyCoeffStruct(arrayPixel, subRow, subCol).c.coeffs = 0;
                prfPolyStructure.polyCoeffStruct(arrayPixel, subRow, subCol).nelements = 0;
                prfPolyStructure.polyCoeffStruct(arrayPixel, subRow, subCol).order = 0;
                prfPolyStructure.polyCoeffStruct(arrayPixel, subRow, subCol).numRows = nArrayRows;
                prfPolyStructure.polyCoeffStruct(arrayPixel, subRow, subCol).numCols = nArrayCols;
                prfPolyStructure.residualMean(arrayPixel, subRow, subCol) = 0;
                prfPolyStructure.residualStandardDeviation(arrayPixel, subRow, subCol) = 0;
            else
                
                % estimate optimal polynomial order
                pixData = subPixelData(arrayPixel, subRow, subCol);
                dataWeights = 1./pixData.uncertainties;

                nPoints = length(subPixIndex);
                AIC = zeros(maximumPolyOrder+1, 1);
                AICorders = 0:maximumPolyOrder;
                minAIC = inf;
                for o = AICorders
                    [polyStruct(o+1) condA] = robust_polyfit2d(pixData.subRows, ...
                        pixData.subCols, pixData.values, dataWeights, ...
                        o, [], [], prfPolynomialType);
                    modelPixelValues = weighted_polyval2d(pixData.subRows, ...
                        pixData.subCols, polyStruct(o+1));
                    residuals = (modelPixelValues - pixData.values).*dataWeights;
                    meanRssResidual = norm(residuals)^2/nPoints;
                    
                    k = length(polyStruct(o+1).coeffs);
                    AIC(o+1) = 2*k + nPoints*log(meanRssResidual) + 2*k*(k-1)/(nPoints - k - 1);
                    % pick first local minimum of AIC
                    if AIC(o+1) < minAIC
                        minAIC = AIC(o+1);
                        orderIndex = o+1;
                        selectedOrder = AICorders(o+1);
                    elseif AIC(o+1) > minAIC || condA >= 1/eps
                        % quit when we see AIC rising or the condition of
                        % the matrix is bad, pick the previous 
                        % order
                        if o > 0
                            orderIndex = o; % orderIndex = order + 1!
                            selectedOrder = AICorders(o);
                        else
                            orderIndex = 1; % orderIndex = order + 1!
                            selectedOrder = AICorders(1);
                        end
                        break;
                    end
                end
                subPixelData(arrayPixel, subRow, subCol).AIC = AIC;
                subPixelData(arrayPixel, subRow, subCol).selectedOrder = selectedOrder;

                % compute the actual polynomial for this sub-region
                prfPolyStructure.polyCoeffStruct(arrayPixel, subRow, subCol).c = polyStruct(orderIndex);
                prfPolyStructure.polyCoeffStruct(arrayPixel, subRow, subCol).nelements = length(subPixIndex);
                prfPolyStructure.polyCoeffStruct(arrayPixel, subRow, subCol).order = selectedOrder;
                prfPolyStructure.polyCoeffStruct(arrayPixel, subRow, subCol).numRows = nArrayRows;
                prfPolyStructure.polyCoeffStruct(arrayPixel, subRow, subCol).numCols = nArrayCols;

                modelPixelValues = weighted_polyval2d(subPixelRowAllTargets(subPixIndex), ...
                    subPixelColAllTargets(subPixIndex), ...
                    prfPolyStructure.polyCoeffStruct(arrayPixel, subRow, subCol).c);
                residuals = modelPixelValues - normalizedPixelValuesAllTargets(subPixIndex);
                prfPolyStructure.residualMean(arrayPixel, subRow, subCol) = mean(residuals);
                prfPolyStructure.residualStandardDeviation(arrayPixel, subRow, subCol) ...
                    = std(residuals);
                subPixelData(arrayPixel, subRow, subCol).residuals = residuals;
                subPixelData(arrayPixel, subRow, subCol).modelPixelValues = modelPixelValues;
%                 if mean(pixData.values) > 0.4
%                     disp('good values');
%                 end
            end
        end 
    end
    disp(['sub row ' num2str(subRow) ' took ' num2str(etime(clock, t1)) ' seconds']);
end

prfObject = prfClass(prfPolyStructure.polyCoeffStruct);
if contourCutoff > 0 && totalPixels > 0
    % now we have to trim the prf to zero out flux on boundary
    % first render the PRF onto a high-resolution mesh
    [pixMesh, meshy, meshx] = make_array(prfObject, 400);
    % determine the polygon which bounds the prf above the cutoff value
    prfBoundingPolygon = find_bounding_polygon(meshx(1,:), meshy(:,1), pixMesh, contourCutoff);
    if ~isempty(prfBoundingPolygon)
        % now go through every sub-pixel region and zero out those that fall
        % outside the bounding polygon
    %     figure
    %     hold on;
    %     imagesc(meshx(1,:), meshy(:,1), pixMesh);
    %     plot(prfBoundingPolygon.x, prfBoundingPolygon.y, 'yx-');
        for subRow = 1:nSubPixelRows
            for subCol = 1:nSubPixelCols

                % find the data point in this sub-row region
                % subPixIndex gives the index of the pixel in this sub-pixel
                % region for each cadence
                for arrayPixel = 1:nArrayRows*nArrayCols
                    [arrayRow, arrayCol] = ind2sub([nArrayRows, nArrayCols], arrayPixel);
                    % compute the coordinates of the four corners of the
                    % sub-pixel
                    % array
                    cornerY = [arrayRow - 0.5 - subRowStart(subRow), ...
                        arrayRow - 0.5 - subRowStart(subRow), ...
                        arrayRow - 0.5 - subRowEnd(subRow), ...
                        arrayRow - 0.5 - subRowEnd(subRow)];
                    cornerX = [arrayCol - subColStart(subCol), ...
                        arrayCol - 0.5 - subColEnd(subCol), ...
                        arrayCol - 0.5 - subColEnd(subCol), ...
                        arrayCol - 0.5 - subColStart(subCol)];

                    if ~inpolygon(cornerX, cornerY, prfBoundingPolygon.x, prfBoundingPolygon.y);
                        % this subpixel is entirely outside the bounding polygon so
                        % zero it
    %                     plot(cornerX, cornerY, 'r');
                        prfPolyStructure.polyCoeffStruct(arrayPixel, subRow, subCol).c.coeffs = 0;
                        prfPolyStructure.polyCoeffStruct(arrayPixel, subRow, subCol).c.covariance = 1;
                        prfPolyStructure.polyCoeffStruct(arrayPixel, subRow, subCol).nelements = 0;
                        prfPolyStructure.polyCoeffStruct(arrayPixel, subRow, subCol).order = 0;
                    end
                end 
            end
        end
	else
		disp('no enclosing polygon found');
    end
	
    prfStructure.prfBoundingPolygon = prfBoundingPolygon;
end

prfStructure.subPixelData = subPixelData;
prfStructure.prfPolyStructure = prfPolyStructure;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [prfCreationObject, prfObject] = fit_prf_amplitude(prfCreationObject, prfStructure)
cadenceGapIndicators = prfCreationObject.cadenceTimes.gapIndicators;
goodCadences = ~cadenceGapIndicators;
goodCadenceIndex = find(goodCadences);

prfObject = prfClass(prfStructure.prfPolyStructure.polyCoeffStruct);

targetStarsStruct = prfCreationObject.targetStarsStruct;
nCadences = length(targetStarsStruct(1).pixelTimeSeriesStruct(1).values(goodCadences));
nTargets = length(targetStarsStruct);
for t=1:nTargets
    if prfCreationObject.targetStarsStruct(t).selectedTarget
        prfCreationObject.targetStarsStruct(t).prfFlux = zeros(nCadences, 1);
        pixelStruct = targetStarsStruct(t).pixelTimeSeriesStruct;
        nPixels = length(pixelStruct);
        pixRows = [pixelStruct.row];
        pixCols = [pixelStruct.column];
        % extract all pixel values (242 x numPixels)
        allPixelValues = [pixelStruct.values];
        allPixelUncertainties = [pixelStruct.uncertainties];
        % set the gaps to inf so they drop out of the fit
        % must do this before extracting good cadences because that's the
        % index space of .gapIndices
        for p=1:nPixels
            allPixelUncertainties(pixelStruct(p).gapIndices, p) = inf;
        end
        for c = 1:length(goodCadenceIndex)
            cadence = goodCadenceIndex(c);
            % get the  pixel value of the first cadence
            pixelValues = allPixelValues(cadence, :);
            uncertainties = allPixelUncertainties(cadence, :);
            normPixelValues = pixelValues./uncertainties;
            
            row = targetStarsStruct(t).row(cadence);
            col = targetStarsStruct(t).column(cadence);

            prfValues = evaluate(prfObject, row, col, pixRows, pixCols);
            normPrfValues = prfValues(:)./uncertainties(:);
            % find amplitude that minimizes sum((pixelValues(i) - amplitude*prfValues(i))^2
            amplitude = normPixelValues(:)'*normPrfValues(:)/(normPrfValues(:)'*normPrfValues(:));
            if amplitude < 0
                prfCreationObject.targetStarsStruct(t).prfFlux = [];
                prfCreationObject.targetStarsStruct(t).selectedTarget = 0;
                break;
            else
                prfCreationObject.targetStarsStruct(t).prfFlux(cadence) = sum(amplitude*prfValues);
            end
        end
    end
end

