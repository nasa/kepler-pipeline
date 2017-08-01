function [estimatedPeakSnr, minDistToValidPixel] = estimate_peak_snr_per_star(obj)
%**************************************************************************
% [estimatedPeakSnr, minDistToValidPixel] = estimate_peak_snr_per_star(obj)
%**************************************************************************
% Estimate the peak pixel SNR expected from flux due to each star in the
% obj.contributingStars list. 
%
% In the interest of speed we do not evaluate the PRF on every cadence, but
% do the following instead:
%
%     1. Determine the cadence C on which the centroid is closest to any
%        valid (non-gapped) aperture pixel. 
%     2. Evaluate the (normalized) PRF on cadence C for pixels inside the
%        aperture. 
%     3. Use the stellar magnitude in combination with the normalized PRF
%        to predict flux values f_hat(p) at those pixels.
%     4. Obtain a liberal estimate of the peak pixel SNR for each star by
%        calculating SNR_hat(p) = f_hat(p) / sigma(p) for each pixel.
%
% INPUTS
%     (none)
%
% OUTPUTS
%     estimatedPeakSnr    : An nStars-by-1 array
%     minDistToValidPixel : An nStars-by-1 array
%
% NOTES
%     For convenience we assume unit pixel responsivity R(p) = 1.0 for
%     every pixel p. The tendency is therefore to OVERESTIMATE the measured
%     flux at a given pixel. Overestimating measurements is less
%     problematic than underestimating, since errors will tend toward
%     inclusiveness, which shouldn't negatively effect the quality of the
%     aperture models.
%**************************************************************************
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
    ROW_DIM   = 1;
    BIG_VALUE = 1e10;
    TWELFTH_MAGNITUDE_ELECTRON_FLUX_PER_SECOND = 214100;
    CADENCE_DURATION_IN_MINUTES = 29.4244;
    
    twelfthMagFluxPerCadence = 60 * CADENCE_DURATION_IN_MINUTES ...
        * TWELFTH_MAGNITUDE_ELECTRON_FLUX_PER_SECOND;
    
    nStars              = obj.get_num_contributing_stars();
    nPixels             = obj.get_num_pixels();
    nCadences           = obj.get_num_cadences();
    estimatedPeakSnr    = zeros(nStars, 1);
    distSquaredMat      = BIG_VALUE * ones(nPixels, nCadences);
    minDistToValidPixel = BIG_VALUE * ones(nStars, 1);
    
    % Identify valid pixels and cadences with an indicator matrix. 
    [~, pixelSigmas, pixelGaps] = obj.get_observed_values_and_sigmas();
    validInd = ~pixelGaps & ...
        ~repmat( rowvec(obj.get_motion_gap_indicators()), [nPixels, 1] );
    
    pixelRowMat = repmat( colvec(obj.pixelRows),    [1, nCadences]);
    pixelColMat = repmat( colvec(obj.pixelColumns), [1, nCadences]);
    
    % Sample the static PRF for each contributing star and mark those with
    % non-zero samples. 
    for iStar = 1:nStars
                
        centroidRows = obj.contributingStars(iStar).centroidRow;
        centroidCols = obj.contributingStars(iStar).centroidCol;
        
        centroidRowMat = repmat( rowvec(centroidRows), [nPixels, 1]);
        centroidColMat = repmat( rowvec(centroidCols), [nPixels, 1]);
        
        % The SNR is expected to peak on the cadence where the centroid is
        % nearest to a pixel center. Note the distance of this
        % star's centroid from the nearest valid pixel center.
        distSquaredMat(:) = BIG_VALUE;
        distSquaredMat(validInd) ...
            = (centroidRowMat(validInd) - pixelRowMat(validInd)) .^2 ...
            + (centroidColMat(validInd) - pixelColMat(validInd)) .^2;
        [minDistToValidPixel(iStar), expectedPeakSnrCadence] ...
            = min( min(distSquaredMat, [], ROW_DIM) );
                
        % Evaluate (normalized) PRF inside aperture at the centroid 
        % position expected to produce a peak SNR. 
        sampledPrfStruct = obj.prfModelHandle.evaluate_static(...
            centroidRows(expectedPeakSnrCadence), ...
            centroidCols(expectedPeakSnrCadence), ...
            obj.pixelRows, obj.pixelColumns);
        
        % Estimate the total flux from this star using the catalog
        % magnitude and assuming the bulk pixel responsivities are
        % uniformly 1.0. The function mag2b() captures the following
        % relationship: f/f0 = mag2b(m-m0), where we choose m0=12.
        totalElectronFluxPerCadence =  twelfthMagFluxPerCadence...
            * colvec(mag2b([obj.contributingStars(iStar).keplerMag] - 12));    
    
        % Calculate the (optimistic) expected peak SNR.
        sigmas = pixelSigmas(:, expectedPeakSnrCadence);
        gtZeroSigmaInd = sigmas > 0;
        estimatedPeakSnr(iStar) = max( totalElectronFluxPerCadence * ...
            sampledPrfStruct.values(gtZeroSigmaInd) ...
            ./ sigmas(gtZeroSigmaInd) );
    end
end

%********************************** EOF ***********************************
