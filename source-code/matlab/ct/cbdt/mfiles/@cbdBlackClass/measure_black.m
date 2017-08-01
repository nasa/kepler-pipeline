function cbdObj = measure_black(cbdObj, darkFFIs, badPixels, readoutNoiseStd)
% function cbdObj = measure_black(cbdObj, darkFFIs, badPixels)
% measure the twoDblack, mean black and the associated standard deviations at each pixel
% locations
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
constants;

[nRows, nCols, nImg] = size(darkFFIs);
if ~( nRows == FFI_ROWS && nCols == FFI_COLS )
    error('measure_black: incorrect FFI size!');
end
    
% black pixels are purely black pixels.
badPixelsMask =     ( badPixels.badPixelMap == HOT_PIXEL) | ...
                    ( badPixels.badPixelMap == DEAD_PIXEL);

% The FGS pixels
fgsXtalkPixelsMask = ( badPixels.badPixelMap == XTALK_PIXEL );

% compute 2D black & xtalk combo mean and std via running temporal mean and std
% algorithms: use robust solution! XXX
[meanFFI, stdFFI] = running_mean_std(darkFFIs);

% expand the FGS Xtalk pixel mask
AVERAGE_WINDOW_SIZE     = [1, 3];

% median filter for filling missing pixels and spatially removing outliers
MEDIAN_WINDOW_SIZE     = [11, 5];

% spatial smoothing window size for the pure 2D black
SMOOTHING_WINDOW_SIZE   = [ 3, 3];

AVERAGE_WEIGHTS         = 1;
% pick a huge number whose inverse as FGS pixel weight
FGS_WEIGHT = 10^16;

% dilate xtalk_mask horizontally to cover the extended end pixels
[fgsMaskExpanded] = moving_weighted_mean(fgsXtalkPixelsMask, AVERAGE_WEIGHTS, AVERAGE_WINDOW_SIZE);
       
% mark the injection part as FGS as we don't touch that region
% mark the injection part as FGS as we don't touch that region
injectionPixelsMask = false(FFI_ROWS, FFI_COLS);
injectionPixelsMask(SMEAR_INJECTION_ROWS, SMEAR_INJECTION_COLS) = true;

% mask for pixels that are both FGS and injection pixels
injectionFgsPixelsMask = injectionPixelsMask & fgsMaskExpanded;

badPixelsMask = badPixelsMask | injectionPixelsMask;

% both bad and FGS pixels are excluded for spatial smoothing
exclusionPixelsMask = (badPixelsMask | fgsMaskExpanded);

% filtering the temporal mean of the black FFIs before spatial smoothing
meanFFIFiltered = img_median( meanFFI, exclusionPixelsMask, MEDIAN_WINDOW_SIZE);


% Produce the map of weights with FGS xtalk pixels having small weights
blackPixelWeights = 1./ (exclusionPixelsMask * FGS_WEIGHT + 1.0);

% spatially smoothed 2D blackpixels with a small kernel
twoDBlackMeanImage = moving_weighted_mean(meanFFIFiltered, blackPixelWeights, SMOOTHING_WINDOW_SIZE);

% spatially smoothed FGS pixels with a small kernel
twoDFgsMeanImage = moving_weighted_mean(meanFFIFiltered, fgsMaskExpanded, SMOOTHING_WINDOW_SIZE);
% replace the injection pixels covered by FGS mask
meanFFIFiltered( injectionFgsPixelsMask ) = twoDFgsMeanImage( injectionFgsPixelsMask );

% put back the temporally smoothed FGS with spatially smoothed black pixels
twoDBlackXtalkMeanImage = twoDBlackMeanImage .* (fgsMaskExpanded <= 0.0) + (fgsMaskExpanded > 0.0) .* meanFFIFiltered;

% get the true 2D Black statistics, i.e. without FGS xtalk signals
%regionStatsStruct = get_pixels_statistics(twoDBlackXtalkMeanImage, 1, HIGH_GUARD, LOW_GUARD, cbdObj.debugStatus);

% we have twoDBlack that consists of both black and crosstalk pixels

cbdObj.measured2DBlack = single( twoDBlackXtalkMeanImage );
cbdObj.measured2DBlackStd = single(stdFFI);

% this has pure 2d black, useful for Doug, but not in requirement
cbdObj.measured2DBlackOnly = single(twoDBlackMeanImage);

%cbdObj.measured2dBlackRegionStats = regionStatsStruct;

% the mean and std of whole FFI of both black and FGS pixels
pixelsHighGuard = twoDBlackXtalkMeanImage < HIGH_GUARD;
pixelsLowGuard = twoDBlackXtalkMeanImage > LOW_GUARD;
temp = nonzeros( twoDBlackXtalkMeanImage( pixelsHighGuard & pixelsLowGuard ) );

cbdObj.measuredMeanBlack = mean( temp(:) );
cbdObj.measuredMeanBlackStd = std( temp(:) );

cbdObj.measured2dBlackRegionStats = get_pixels_statistics(twoDBlackXtalkMeanImage, 1, HIGH_GUARD, LOW_GUARD * ones(84, 1), cbdObj.debugStatus);

if ( cbdObj.debugStatus )
    % show the difference between 2d black model and 2d black measurement
    meanMod = cbdObj.measuredMeanBlack;
    stdMod = 0.75;
    figure, imagesc(cbdObj.measured2DBlack, [ meanMod - 3 * stdMod, meanMod + 3 * stdMod]); 
    axis xy; title('Measured 2D black');
    colorbar;
end

return;