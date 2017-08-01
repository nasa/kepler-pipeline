function [calObject, calIntermediateStruct] = correct_collateral_data_for_spatial_coadds(calObject, calIntermediateStruct)
%function [calObject, calIntermediateStruct] = correct_collateral_data_for_spatial_coadds(calObject, calIntermediateStruct)
%
% This calClass method corrects collateral pixels for the number or rows/cols that were summed onboard the spacecraft to create the black
% column and smear row pixels.
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


% extract data flags
isAvailableBlackPix         = calObject.dataFlags.isAvailableBlackPix;
isAvailableMaskedBlackPix   = calObject.dataFlags.isAvailableMaskedBlackPix;
isAvailableVirtualBlackPix  = calObject.dataFlags.isAvailableVirtualBlackPix;
isAvailableMaskedSmearPix   = calObject.dataFlags.isAvailableMaskedSmearPix;
isAvailableVirtualSmearPix  = calObject.dataFlags.isAvailableVirtualSmearPix;


%--------------------------------------------------------------------------
% extract black pixels and gaps if they are available, and correct for
% number of summed black columns
%--------------------------------------------------------------------------
if isAvailableBlackPix

    blackPixels = calIntermediateStruct.blackPixels;   %nPixels x nCadences
    blackGaps = calIntermediateStruct.blackGaps;

    % find valid pixel indicators:
    validBlackPixelIndicators = ~blackGaps;

    % extract number of row/columns that were spatially coadded
    numberOfBlackColumns = calIntermediateStruct.numberOfBlackColumns;

    if numel(numberOfBlackColumns) > 1

        nBlackPixels = length(blackPixels(:, 1));
        numberOfBlackColumns = repmat(numberOfBlackColumns(:)', nBlackPixels, 1);
        numberOfBlackColumns = numberOfBlackColumns(validBlackPixelIndicators);
    end

    % correct for number of summed black columns
    blackPixels(validBlackPixelIndicators) = blackPixels(validBlackPixelIndicators) ...
        ./ numberOfBlackColumns;

    calIntermediateStruct.blackPixels = blackPixels;
end


%--------------------------------------------------------------------------
% extract masked/virtual black pixels and gaps if they are available, and
% correct for number of summed black columns and summed smear rows
%--------------------------------------------------------------------------
if isAvailableMaskedBlackPix

    mBlackPixels = calIntermediateStruct.mBlackPixels;
    mBlackGaps = calIntermediateStruct.mBlackGaps;

    % find valid pixel indices:
    validMblackPixelIndicators = ~mBlackGaps;

    % extract number of row/columns that were spatially coadded
    numberOfMaskedBlackPixels   = calIntermediateStruct.numberOfMaskedBlackPixels;

    if numel(numberOfMaskedBlackPixels) > 1
        numberOfMaskedBlackPixels = numberOfMaskedBlackPixels(validMblackPixelIndicators);
    end

    mBlackPixels(validMblackPixelIndicators) = mBlackPixels(validMblackPixelIndicators) ...
        ./ numberOfMaskedBlackPixels;

    calIntermediateStruct.mBlackPixels = mBlackPixels;
end

if isAvailableVirtualBlackPix

    vBlackPixels = calIntermediateStruct.vBlackPixels;
    vBlackGaps = calIntermediateStruct.vBlackGaps;

    % find valid pixel indices:
    validVblackPixelIndicators = ~vBlackGaps;

    % extract number of row/columns that were spatially coadded
    numberOfVirtualBlackPixels  = calIntermediateStruct.numberOfVirtualBlackPixels;

    if numel(numberOfVirtualBlackPixels) > 1
        numberOfVirtualBlackPixels = numberOfVirtualBlackPixels(validVblackPixelIndicators);
    end

    vBlackPixels(validVblackPixelIndicators) = vBlackPixels(validVblackPixelIndicators) ...
        ./ numberOfVirtualBlackPixels;

    calIntermediateStruct.vBlackPixels = vBlackPixels;
end


%--------------------------------------------------------------------------
% extract masked smear pixels and gaps if they are available, and correct for
% number of summed smear rows
%--------------------------------------------------------------------------
if isAvailableMaskedSmearPix

    mSmearPixels = calIntermediateStruct.mSmearPixels;
    mSmearGaps = calIntermediateStruct.mSmearGaps;

    % find valid pixel indices:
    validMsmearPixelIndicators = ~mSmearGaps;

    % extract number of row/columns that were spatially coadded
    numberOfMaskedSmearRows = calIntermediateStruct.numberOfMaskedSmearRows;

    if numel(numberOfMaskedSmearRows) > 1
        nMsmearPixels = length(mSmearPixels(:, 1));
        numberOfMaskedSmearRows = repmat(numberOfMaskedSmearRows(:)', nMsmearPixels, 1);
        numberOfMaskedSmearRows = numberOfMaskedSmearRows(validMsmearPixelIndicators);
    end

    % correct for number of summed smear rows
    mSmearPixels(validMsmearPixelIndicators) = mSmearPixels(validMsmearPixelIndicators) ...
        ./ numberOfMaskedSmearRows;

    calIntermediateStruct.mSmearPixels = mSmearPixels;
end

%--------------------------------------------------------------------------
% extract virtual smear pixels and gaps if they are available, and correct for
% number of summed smear rows
%--------------------------------------------------------------------------
if isAvailableVirtualSmearPix

    vSmearPixels = calIntermediateStruct.vSmearPixels;
    vSmearGaps = calIntermediateStruct.vSmearGaps;

    % find valid pixel indices:
    validVsmearPixelIndicators = ~vSmearGaps;

    % extract number of row/columns that were spatially coadded
    numberOfVirtualSmearRows = calIntermediateStruct.numberOfVirtualSmearRows;

    if numel(numberOfVirtualSmearRows) > 1
        nVsmearPixels = length(vSmearPixels(:, 1));
        numberOfVirtualSmearRows = repmat(numberOfVirtualSmearRows(:)', nVsmearPixels, 1);
        numberOfVirtualSmearRows = numberOfVirtualSmearRows(validVsmearPixelIndicators);
    end

    % correct for number of summed smear rows
    vSmearPixels(validVsmearPixelIndicators) = vSmearPixels(validVsmearPixelIndicators) ...
        ./ numberOfVirtualSmearRows;

    calIntermediateStruct.vSmearPixels = vSmearPixels;
end


return;
