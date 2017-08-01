function [imgMedian] = img_median(rawImg, fgsMask, kernelSize)
% function [imgMedian] = img_median(rawImg, kernelSize)
% compute the robust.
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

debugFlag = false; % rarely used.

[nRows, nCols, nFrames] = size(rawImg);
[nRowsMask, nColsMask] = size(fgsMask);

if ( length(kernelSize) >= 2 )
    nKernelRows = kernelSize(1);
    nKernelCols = kernelSize(2);

    % check if the kernel size is odd in both dimensions
    if ~( mod(nKernelRows, 2) == 1 && mod(nKernelCols, 2) == 1 && ...
            nKernelRows >= 1 && nKernelCols >= 1 )
        error('img_median(): kernel size not odd');
    end
else
    error('img_median(): kernel size error');
end

if ~( nRows >= nKernelRows && nCols >= nKernelCols && ...
        nRows == nRowsMask && nCols == nColsMask )
    error('img_median(): image, mask and kernel size error');
end

% get the half kernel size
nKernelHRows = floor(nKernelRows / 2);
nKernelHCols = floor(nKernelCols / 2);

% allocate memory for output: add extra columns and rows for handling
% border pixels

rawImgTemp         = zeros(nRows + 2 * nKernelHRows, nCols  + 2 * nKernelHCols);
fgsMaskTemp        = uint8( ones (nRows + 2 * nKernelHRows, nCols  + 2 * nKernelHCols) );
imgMedian          = zeros(nRows, nCols, nFrames);

% Can we make this triple loop more efficient?
for frame = 1:nFrames

    % copy data into temporary expanded buffer
    rawImgTemp(nKernelHRows + 1: nKernelHRows + nRows,  nKernelHCols + 1 : nKernelHCols + nCols) = rawImg;
    fgsMaskTemp(nKernelHRows + 1: nKernelHRows + nRows,  nKernelHCols + 1 : nKernelHCols + nCols) = fgsMask;

    % replicate the border rows and columns
    for k=1:nKernelHRows
        rawImgTemp(nKernelHRows + 1 - k, nKernelHCols + 1 : nKernelHCols + nCols) = rawImg(k+1, :);
        rawImgTemp(nRows + nKernelHRows + k, nKernelHCols + 1 : nKernelHCols + nCols) = rawImg(nRows - k, :);

        fgsMaskTemp(nKernelHRows + 1 - k, nKernelHCols + 1 : nKernelHCols + nCols) = fgsMask(k+1, :);
        fgsMaskTemp(nRows + nKernelHRows + k, nKernelHCols + 1 : nKernelHCols + nCols) = fgsMask(nRows - k, :);
    end

    for k=1:nKernelHCols
        rawImgTemp(nKernelHRows + 1 : nKernelHRows + nRows, nKernelHCols + 1 - k) = rawImg(:, k+1);
        rawImgTemp(nKernelHRows + 1 : nKernelHRows + nRows, nCols + nKernelHCols + k) = rawImg(:, nCols - k);

        fgsMaskTemp(nKernelHRows + 1 : nKernelHRows + nRows, nKernelHCols + 1 - k) = fgsMask(:, k+1);
        fgsMaskTemp(nKernelHRows + 1 : nKernelHRows + nRows, nCols + nKernelHCols + k) = fgsMask(:, nCols - k);
    end

    for row = 1 : (nRows)
        rowTemp = row + nKernelHRows;

        for col = 1 : (nCols)
            colTemp = col + nKernelHCols;

            % get all pixels in the neighborhood
            dat = rawImgTemp(rowTemp - nKernelHRows : rowTemp + nKernelHRows, colTemp - nKernelHCols : colTemp + nKernelHCols);
            fgs = fgsMaskTemp(rowTemp - nKernelHRows : rowTemp + nKernelHRows, colTemp - nKernelHCols : colTemp + nKernelHCols);

            blackPixelIndex = (fgs == 0);

            if ( sum(blackPixelIndex) == 0 )
                if ( debugFlag )
                    warning('No valid black pixels');
                end
                imgMedian(row, col, frame) = rawImg(row, col, frame);
            else

                blackPixels = dat( blackPixelIndex );

                %                if ( length( blackPixels ) < 10 )
                %                    imgMedian(row, col, frame) = median( blackPixels );
                imgMedian(row, col, frame) = mean( blackPixels );
                %                else
                % use robust mean and std estimator
                %                    [meanDat, stdDat] = robust_mean_std( blackPixels );
                %                    imgMedian(row, col, frame) = meanDat;
                %end
            end



        end
    end
end


return;
