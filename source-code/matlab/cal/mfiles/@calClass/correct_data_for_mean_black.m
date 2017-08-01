function [calObject, calIntermediateStruct] = correct_data_for_mean_black(calObject, calIntermediateStruct)
%function [calObject, calIntermediateStruct] = correct_data_for_mean_black(calObject, calIntermediateStruct)
%
% This calClass method corrects all pixel data for the mean black (per mod/out) value, in order to account for the variations in black
% (bias) and gain found across the focal plane.  The mean black is an (nModOuts x 1) array given with the input requantization table. FFI
% data has no mean black subtracted so there is no need to correct for mean black.
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


% extract logical flags that indicate the availability of pixel types
isAvailableBlackPix         = calObject.dataFlags.isAvailableBlackPix;
isAvailableMaskedBlackPix   = calObject.dataFlags.isAvailableMaskedBlackPix;
isAvailableVirtualBlackPix  = calObject.dataFlags.isAvailableVirtualBlackPix;
isAvailableMaskedSmearPix   = calObject.dataFlags.isAvailableMaskedSmearPix;
isAvailableVirtualSmearPix  = calObject.dataFlags.isAvailableVirtualSmearPix;
isAvailableTargetAndBkgPix  = calObject.dataFlags.isAvailableTargetAndBkgPix;

numberOfExposures = calIntermediateStruct.numberOfExposures;
nCadences = calIntermediateStruct.nCadences;

% extract current module/output
ccdModule = calObject.ccdModule;
ccdOutput = calObject.ccdOutput;

% find mean black value for current mod/out and save - mean black table values (84 x 1 array)
meanBlackEntries = calObject.requantTables.meanBlackEntries;
moduleOutputChannel = convert_from_module_output(ccdModule, ccdOutput);
meanBlack = meanBlackEntries(moduleOutputChannel); % scalar
calIntermediateStruct.meanBlackPerExposure = meanBlack;

%--------------------------------------------------------------------------
% correct collateral pixels for mean black
%--------------------------------------------------------------------------

for cadenceIndex = 1:nCadences
    
    if isAvailableBlackPix
        
        % scale mean black level by number of exposures and spatial coadds
        numberOfBlackColumns = calIntermediateStruct.numberOfBlackColumns;          % nCadences x 1
        meanBlackForBlack = meanBlack * numberOfExposures .* numberOfBlackColumns;  % nCadences x 1
        
        if numel(numberOfBlackColumns) > 1 || numel(numberOfExposures) > 1
            meanBlackForBlack = meanBlackForBlack(cadenceIndex);
        end
        
        % extract pixels for this cadence
        blackPixels = calIntermediateStruct.blackPixels(:, cadenceIndex);  % nPixels x 1
        blackGaps   = calIntermediateStruct.blackGaps(:, cadenceIndex);    % nPixels x 1
        
        % find valid pixel indices
        validBlackPixelIndicators = ~blackGaps;
        
        % correct for mean black value for this cadence and pixel type
        if issparse(blackPixels)
            blackPixels(validBlackPixelIndicators) = blackPixels(validBlackPixelIndicators) + sparse(meanBlackForBlack);
        else
            blackPixels(validBlackPixelIndicators) = blackPixels(validBlackPixelIndicators) + meanBlackForBlack;
        end
        
        % save updated pixel values back to intermediate struct
        calIntermediateStruct.blackPixels(:, cadenceIndex) = blackPixels;
    end
    
    
    if isAvailableMaskedBlackPix
        
        % scale mean black level by number of exposures and spatial coadds
        numberOfMaskedBlackPixels = calIntermediateStruct.numberOfMaskedBlackPixels;        % nCadences x 1
        meanBlackForMblack = meanBlack * numberOfExposures .* numberOfMaskedBlackPixels;    % nCadences x 1
        
        if numel(numberOfMaskedBlackPixels) > 1 || numel(numberOfExposures) > 1
            meanBlackForMblack = meanBlackForMblack(cadenceIndex);
        end
        
        % extract pixels for this cadence
        mBlackPixels = calIntermediateStruct.mBlackPixels(cadenceIndex); % scalar
        mBlackGaps   = calIntermediateStruct.mBlackGaps(cadenceIndex);   % scalar
        
        % determine if masked black value is valid for this cadence
        validMblackValue = ~mBlackGaps;
        
        % correct for mean black value for this cadence and pixel type
        mBlackPixels(validMblackValue) = mBlackPixels(validMblackValue) + meanBlackForMblack;
        
        % save updated pixel values back to intermediate struct
        calIntermediateStruct.mBlackPixels(cadenceIndex) = mBlackPixels;
    end
    
    
    if isAvailableVirtualBlackPix
        
        % scale mean black level by number of exposures and spatial coadds
        numberOfVirtualBlackPixels = calIntermediateStruct.numberOfVirtualBlackPixels;      % nCadences x 1
        meanBlackForVblack = meanBlack * numberOfExposures .* numberOfVirtualBlackPixels;   % nCadences x 1
        
        if numel(numberOfVirtualBlackPixels) > 1 || numel(numberOfExposures) > 1
            meanBlackForVblack = meanBlackForVblack(cadenceIndex);
        end
        
        % extract pixels for this cadence
        vBlackPixels = calIntermediateStruct.vBlackPixels(cadenceIndex); % scalar
        vBlackGaps   = calIntermediateStruct.vBlackGaps(cadenceIndex);   % scalar
        
        % determine if virtual black value is valid for this cadence
        validVblackValue = ~vBlackGaps;
        
        % correct for mean black value for this cadence and pixel type
        vBlackPixels(validVblackValue) = vBlackPixels(validVblackValue) + meanBlackForVblack;
        
        % save updated pixel values back to intermediate struct
        calIntermediateStruct.vBlackPixels(cadenceIndex) = vBlackPixels;
    end
    
    
    if isAvailableMaskedSmearPix
        
        % scale mean black level by number of exposures and spatial coadds
        numberOfMaskedSmearRows = calIntermediateStruct.numberOfMaskedSmearRows;            % nCadences x 1
        meanBlackForMsmear = meanBlack * numberOfExposures .* numberOfMaskedSmearRows;      % nCadences x 1
        
        if numel(numberOfMaskedSmearRows) > 1 || numel(numberOfExposures) > 1
            meanBlackForMsmear = meanBlackForMsmear(cadenceIndex);
        end
        
        % extract pixels for this cadence
        mSmearPixels = calIntermediateStruct.mSmearPixels(:, cadenceIndex); % nPixels x 1
        mSmearGaps   = calIntermediateStruct.mSmearGaps(:, cadenceIndex);   % nPixels x 1
        
        % find valid pixel indices
        validMsmearPixelIndicators = ~mSmearGaps;
        
        % correct for mean black value for this cadence and pixel type
        if issparse(mSmearPixels)
            mSmearPixels(validMsmearPixelIndicators) = mSmearPixels(validMsmearPixelIndicators) + sparse(meanBlackForMsmear);
        else
            mSmearPixels(validMsmearPixelIndicators) = mSmearPixels(validMsmearPixelIndicators) + meanBlackForMsmear;
        end
        
        % save updated pixel values back to intermediate struct
        calIntermediateStruct.mSmearPixels(:, cadenceIndex) = mSmearPixels;
    end
    
    
    if isAvailableVirtualSmearPix
        
        % scale mean black level by number of exposures and spatial coadds
        numberOfVirtualSmearRows = calIntermediateStruct.numberOfVirtualSmearRows;          % nCadences x 1
        meanBlackForVsmear = meanBlack * numberOfExposures .* numberOfVirtualSmearRows;     % nCadences x 1
        
        if numel(numberOfVirtualSmearRows) > 1 || numel(numberOfExposures) > 1
            meanBlackForVsmear = meanBlackForVsmear(cadenceIndex);
        end
        
        % extract pixels for this cadence
        vSmearPixels = calIntermediateStruct.vSmearPixels(:, cadenceIndex);     % nPixels x 1
        vSmearGaps   = calIntermediateStruct.vSmearGaps(:, cadenceIndex);       % nPixels x 1
        
        % find valid pixel indices
        validVsmearPixelIndicators = ~vSmearGaps;
        
        % correct for mean black value for this cadence and pixel type
        if issparse(vSmearPixels)
            vSmearPixels(validVsmearPixelIndicators) = vSmearPixels(validVsmearPixelIndicators) + sparse(meanBlackForVsmear);
        else
            vSmearPixels(validVsmearPixelIndicators) = vSmearPixels(validVsmearPixelIndicators) + meanBlackForVsmear;
        end
        
        % save updated pixel values back to intermediate struct
        calIntermediateStruct.vSmearPixels(:, cadenceIndex) = vSmearPixels;
    end    
end


%--------------------------------------------------------------------------
% correct photometric pixels for mean black value
%--------------------------------------------------------------------------
if isAvailableTargetAndBkgPix
    
    % scale mean black level by number of exposures
    meanBlackForPhotometric = meanBlack .* numberOfExposures;
    
    % extract pixels for this cadence
    photometricPixels = calIntermediateStruct.photometricPixels;
    photometricGaps   = calIntermediateStruct.photometricGaps;
    
    if numel(numberOfExposures) > 1
        nPhotometricPixels = length(photometricPixels(:, 1));
        meanBlackForPhotometric = repmat(meanBlackForPhotometric(:)', nPhotometricPixels, 1);
    end
    
    % find valid pixel indices
    validPhotometricPixelIndicators = ~photometricGaps;    
    
    % correct for mean black (nCadences x 1 array)
    photometricPixels = photometricPixels + meanBlackForPhotometric;
    
    % save updated pixel values back to intermediate struct
    calIntermediateStruct.photometricPixels(validPhotometricPixelIndicators) = ...
        photometricPixels(validPhotometricPixelIndicators);
end


return;
