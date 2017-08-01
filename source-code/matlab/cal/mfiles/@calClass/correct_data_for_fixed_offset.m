function [calObject, calIntermediateStruct] = correct_data_for_fixed_offset(calObject, calIntermediateStruct)
%function [calObject, calIntermediateStruct] = correct_data_for_fixed_offset(calObject, calIntermediateStruct)
%
% This calClass method corrects all input pixel data for the fixed offset, which is extracted from the spacecraft config map in the function
% get_config_map_parameters. For collateral data, the fixed offset should be subtracted from each spatially coadded black row or smear
% columns that are inputs in the first invocation of CAL. FFI data has no fixed offset added so there is no need to correct for fixed
% offset. 
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


%--------------------------------------------------------------------------
% extract data flags
%--------------------------------------------------------------------------
processShortCadence         = calObject.dataFlags.processShortCadence;

isAvailableBlackPix         = calObject.dataFlags.isAvailableBlackPix;
isAvailableMaskedBlackPix   = calObject.dataFlags.isAvailableMaskedBlackPix;
isAvailableVirtualBlackPix  = calObject.dataFlags.isAvailableVirtualBlackPix;
isAvailableMaskedSmearPix   = calObject.dataFlags.isAvailableMaskedSmearPix;
isAvailableVirtualSmearPix  = calObject.dataFlags.isAvailableVirtualSmearPix;
isAvailableTargetAndBkgPix  = calObject.dataFlags.isAvailableTargetAndBkgPix;

%--------------------------------------------------------------------------
% extract the fixed offset: either a nCadence x 1 array or a scalar
%--------------------------------------------------------------------------
fixedOffset = calIntermediateStruct.requantTableFixedOffsets(:);


%--------------------------------------------------------------------------
% extract black pixels and gaps if they are available, and correct for
% fixed offset
%--------------------------------------------------------------------------
if isAvailableBlackPix

    blackPixels = calIntermediateStruct.blackPixels;   %nPixels x nCadences
    blackGaps   = calIntermediateStruct.blackGaps;

    % find valid pixel indices:
    validBlackPixelIndicators = ~blackGaps;
    nBlackPixels = length(blackPixels(:, 1));

    if numel(fixedOffset) > 1
        fixedOffset = repmat(fixedOffset', nBlackPixels, 1);   %nPixels x nCadences
        fixedOffset = fixedOffset(validBlackPixelIndicators);
    end

    % correct for fixed offset
    if issparse(blackPixels)
        blackPixels(validBlackPixelIndicators) = blackPixels(validBlackPixelIndicators) - sparse(fixedOffset);
    else
        blackPixels(validBlackPixelIndicators) = blackPixels(validBlackPixelIndicators) - fixedOffset;
    end
    calIntermediateStruct.blackPixels = blackPixels;
end


%--------------------------------------------------------------------------
% extract masked/virtual black pixels and gaps if they are available, and
% correct for fixed offset
%--------------------------------------------------------------------------
if processShortCadence

    if isAvailableMaskedBlackPix

        mBlackPixels = calIntermediateStruct.mBlackPixels;
        mBlackGaps = calIntermediateStruct.mBlackGaps;

        % find valid pixel indices:
        validMblackPixelIndicators = ~mBlackGaps;
        if numel(fixedOffset) > 1
            fixedOffset = fixedOffset(validMblackPixelIndicators);
        end

        mBlackPixels(validMblackPixelIndicators) = mBlackPixels(validMblackPixelIndicators) - fixedOffset;
        calIntermediateStruct.mBlackPixels = mBlackPixels;
    end

    if isAvailableVirtualBlackPix

        vBlackPixels = calIntermediateStruct.vBlackPixels;
        vBlackGaps = calIntermediateStruct.vBlackGaps;

        % find valid pixel indices:
        validVblackPixelIndicators = ~vBlackGaps;
        if numel(fixedOffset) > 1
            fixedOffset = fixedOffset(validVblackPixelIndicators);
        end

        vBlackPixels(validVblackPixelIndicators) = vBlackPixels(validVblackPixelIndicators) - fixedOffset;
        calIntermediateStruct.vBlackPixels = vBlackPixels;
    end
end


%--------------------------------------------------------------------------
% extract masked smear pixels and gaps if they are available, and correct for
% fixed offset
%--------------------------------------------------------------------------
if isAvailableMaskedSmearPix

    mSmearPixels = calIntermediateStruct.mSmearPixels;
    mSmearGaps   = calIntermediateStruct.mSmearGaps;

    % find valid pixel indices:
    validMsmearPixelIndicators = ~mSmearGaps;
    nMsmearPixels = length(mSmearPixels(:, 1));
    if numel(fixedOffset) > 1
        fixedOffset = repmat(fixedOffset', nMsmearPixels, 1);   %nPixels x nCadences
        fixedOffset = fixedOffset(validMsmearPixelIndicators);
    end

    % correct for fixed offset
    if issparse(mSmearPixels)
        mSmearPixels(validMsmearPixelIndicators) = mSmearPixels(validMsmearPixelIndicators) - sparse(fixedOffset);
    else
        mSmearPixels(validMsmearPixelIndicators) = mSmearPixels(validMsmearPixelIndicators) - fixedOffset;
    end
    calIntermediateStruct.mSmearPixels = mSmearPixels;
end


%--------------------------------------------------------------------------
% extract virtual smear pixels and gaps if they are available, and correct for
% fixed offset
%--------------------------------------------------------------------------
if isAvailableVirtualSmearPix

    vSmearPixels = calIntermediateStruct.vSmearPixels;
    vSmearGaps = calIntermediateStruct.vSmearGaps;

    % find valid pixel indices:
    validVsmearPixelIndicators = ~vSmearGaps;
    nVsmearPixels = length(vSmearPixels(:, 1));
    if numel(fixedOffset) > 1
        fixedOffset = repmat(fixedOffset', nVsmearPixels, 1);   %nPixels x nCadences
        fixedOffset = fixedOffset(validVsmearPixelIndicators);
    end

    % correct for fixed offset
    if issparse(vSmearPixels)
        vSmearPixels(validVsmearPixelIndicators) = vSmearPixels(validVsmearPixelIndicators) - sparse(fixedOffset);
    else
        vSmearPixels(validVsmearPixelIndicators) = vSmearPixels(validVsmearPixelIndicators) - fixedOffset;
    end
    calIntermediateStruct.vSmearPixels = vSmearPixels;
end


%--------------------------------------------------------------------------
% extract photometric pixels and gaps if they are available, and correct for
% fixed offset
%--------------------------------------------------------------------------
if isAvailableTargetAndBkgPix

    photometricPixels = calIntermediateStruct.photometricPixels;
    photometricGaps   = calIntermediateStruct.photometricGaps;

    % find valid pixel indices:
    validPhotometricPixelIndicators = ~photometricGaps;
    nPhotometricPixels = length(photometricPixels(:, 1));
    if numel(fixedOffset) > 1
        fixedOffset = repmat(fixedOffset', nPhotometricPixels, 1);   %nPixels x nCadences
        fixedOffset = fixedOffset(validPhotometricPixelIndicators);
    end

    % correct for fixed offset
    photometricPixels(validPhotometricPixelIndicators) = photometricPixels(validPhotometricPixelIndicators) - fixedOffset;
    calIntermediateStruct.photometricPixels = photometricPixels;
end

return;
