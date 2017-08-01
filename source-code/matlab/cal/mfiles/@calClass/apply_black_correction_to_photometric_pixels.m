function [calObject, calIntermediateStruct, calTransformStruct] = ...
    apply_black_correction_to_photometric_pixels(calObject, calIntermediateStruct, calTransformStruct)
%function [calObject, calIntermediateStruct] = ...
%    apply_black_correction_to_photometric_pixels(calObject, calIntermediateStruct);
%
% function to apply the black correction to photometric pixels, which was
% computed in the first invocation of CAL and saved to cal_black_levels.mat
%
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

% extract stuff from object
stateFilePath       = calObject.localFilenames.stateFilePath;
pouEnabled          = calObject.pouModuleParametersStruct.pouEnabled;
enableFfiInform     = calObject.moduleParametersStruct.enableFfiInform;
isAvailableFfiPix   = calObject.dataFlags.isAvailableFfiPix;
midTimestamps       = calObject.cadenceTimes.midTimestamps;
cadenceGaps         = calObject.cadenceTimes.gapIndicators;

% extract stuff from intermediate struct
nCadences           = calIntermediateStruct.nCadences;
numberOfExposures   = calIntermediateStruct.numberOfExposures;

% extract photometric pixels and gap arrays
photometricPixels = calIntermediateStruct.photometricPixels;    % nPixels x nCadences
photometricGaps   = calIntermediateStruct.photometricGaps;      % nPixels x nCadences logical
photometricRows   = calIntermediateStruct.photometricRows;      % nPixels x 1



%--------------------------------------------------------------------------
% load black level correction array and blackAvailable logical array, which
% were computed in first invocation of CAL and saved to a local .mat file
% If blackAvailable is false, black correction has been set equal to -1
%--------------------------------------------------------------------------
load([stateFilePath, 'cal_black_levels.mat'], 'blackCorrection', 'blackAvailable');


% update photometric gaps if no black pixels are available for a given cadence
photometricGaps(:, (blackAvailable == -1)) = 1;
calIntermediateStruct.photometricGaps = photometricGaps;

% blackCorrection = blackCorrection(photometricRows, :);          %#ok<NODEF>

%--------------------------------------------------------------------------
% correct pixels for black level
%--------------------------------------------------------------------------
blackCorrectedPixels = photometricPixels - blackCorrection(photometricRows, :);             %#ok<*NODEF>
calIntermediateStruct.photometricPixels = blackCorrectedPixels;

if pouEnabled
    % save transform chain for each cadence
    for cadenceIndex=1:nCadences
        % initialize temporary tranformStruct for this cadence
        tStruct = calTransformStruct(:,cadenceIndex);

        disableLevel = 0;
        tStruct = append_transformation(tStruct,'diffV',calIntermediateStruct.pixelVariableName, disableLevel,...
            'fittedBlack', photometricRows(:) );

        % add back to calTransformStruct
        calTransformStruct(:,cadenceIndex) = tStruct;
    end
end


%--------------------------------------------------------------------------
% correct partial ffi pixels for black level
% use cadence correction just preceeding ffi if available
% scale for number of exposures
%--------------------------------------------------------------------------

if isAvailableFfiPix && enableFfiInform
        
    % extract number of exposures
    numberOfExposuresPerFFI = calIntermediateStruct.numberOfExposuresFfi;
    nFfis = length(calIntermediateStruct.ffiStruct);
        
    for iFfi = 1:nFfis
        
        imageToCorrect = calIntermediateStruct.ffiStruct(iFfi).image;
        [nCols, nRows] = size(imageToCorrect);
        
        % get ffi timestamp
        timestamp = calIntermediateStruct.ffiStruct(iFfi).timestamp;
        
        % get cadence times preceeding ffi timestamp
        beforeIndicator = midTimestamps <= timestamp;
        
        if any(beforeIndicator & ~cadenceGaps)
            % find closest preceeding valid cadence time
            t = midTimestamps(beforeIndicator & ~cadenceGaps);
            [~, minIdx] = min(timestamp - t); 
        else
            % otherwise use closest cadence after
            t = midTimestamps(~beforeIndicator & ~cadenceGaps);
            [~, minIdx] = min(t - timestamp);            
        end
        selectedCadenceTime = t(minIdx);
        cadenceLogical = midTimestamps == selectedCadenceTime;
        
        % build vector of photometric rows
        ffiRows = repmat(calIntermediateStruct.ffiStruct(iFfi).rows, nCols, 1);
        ffiRows = ffiRows(:);
       
        % use black correction for cadence identified and correct for possible difference in number of exposures
        correctedImage = imageToCorrect(:) - blackCorrection(ffiRows, cadenceLogical) .* (numberOfExposuresPerFFI(iFfi) ./ numberOfExposures);
        
        % store
        calIntermediateStruct.ffiStruct(iFfi).image = reshape(correctedImage, nCols, nRows);
    end
end

return;
