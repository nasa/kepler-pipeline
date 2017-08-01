function paDataObject = trim_stellar_target_apertures(paDataObject, ...
    radiusInPrfWidths, minApertureSize)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function paDataObject = trim_stellar_target_apertures(paDataObject, ...
%     radiusInPrfWidths, minApertureSize)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Trim pixels from the aperture of each catalog target that fall more than
% radiusInPrfWidths pixels from the estimated centroid position. Always
% retain pixels inside the optimal aperture and never trim apertures to
% have fewer than minApertureSize pixels.
%
% INPUTS
%     paDataObject        : A PA data structure. 
%     radiusInPrfWidths   : A scalar distance in units of PRF widths. 
%     minApertureSize     : Don't trim the apertures to be smaller than
%                           this number of pixels. If minApertureSize is
%                           set to zero, then targets having zero pixels
%                           inside the radiusInPrfWidths threshold are 
%                           removed from the paDataObject. (DEFAULT=0)
% OUTPUTS
%     paDataObject        : A copy of the input paDataObject with pixels
%                           trimmed from any catalog targets, according
%                           to the parameters 'radiusInPrfWidths' and
%                           'minApertureSize'.
% NOTES
%   - Assumes 1-based (Matlab) row and column indexing.
%   - If motion polynomials are available, they are used to estiamte each
%     target's centroid position on each cadence. If not, then the nominal
%     pointing model is used.
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
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
    DEGREES_PER_HOUR = 15.0;
    
    if ~exist('minApertureSize', 'var')
        minApertureSize = 0;
    end
    
    % Constrain minApertureSize to the valid range.
    if minApertureSize < 0
        minApertureSize = 0;
    end
    
    raDec2PixObject = raDec2PixClass(paDataObject.raDec2PixModel, 'one-based');
    targetArray     = paDataObject.targetStarDataStruct;
    gapIndicators   = paDataObject.cadenceTimes.gapIndicators;
    mjd             = paDataObject.cadenceTimes.midTimestamps(~gapIndicators);
        
    % Determine the PRF width in pixels.
    prfObject      = prfCollectionClass( blob_to_struct( ...
                     paDataObject.prfModel.blob), paDataObject.fcConstants);
    pco            = get(prfObject, 'prfCenterObject');
    prfWidthPixels = get(pco, 'nPrfArrayRows');

    for iTarget = 1:numel(targetArray)
        
        % Skip custom targets or any targets with invalid Kepler IDs.
        if ~is_valid_id(targetArray(iTarget).keplerId, 'catalog')
            continue
        end
        
        % Skip targets TAD has deemed to be "saturating".
        if targetArray(iTarget).saturatedRowCount > 0
            continue
        end
        
        %------------------------------------------------------------------
        % Estimate the target centroid time series. Use motion polynomials
        % if they're available. If not, use raDec2Pix().
        %------------------------------------------------------------------
        raDegrees  = DEGREES_PER_HOUR * targetArray(iTarget).raHours;
        decDegrees = targetArray(iTarget).decDegrees;
        
        if isfield(paDataObject, 'motionPolyStruct') && ...
            ~isempty(paDataObject.motionPolyStruct)

            starRow    = zeros(size(mjd));
            starColumn = zeros(size(mjd));
            for n = 1:nCadences
                % returns 1-based row positions
                starRow(n) = weighted_polyval2d(raDegrees, decDegrees, ...
                    paDataObject.motionPolyStruct(n).rowPoly); 

                % returns 1-based column positions                     
                starColumn(n) = weighted_polyval2d(raDegrees, decDegrees, ...
                    paDataObject.motionPolyStruct(n).colPoly); 
            end
        else
            [~, ~, starRow, starColumn] = ra_dec_2_pix_absolute( ...
                raDec2PixObject, raDegrees, decDegrees, mjd);
        end
        
        pixels       = targetArray(iTarget).pixelDataStruct;
        pixelRows    = [pixels.ccdRow];
        pixelColumns = [pixels.ccdColumn];
                
        %------------------------------------------------------------------
        % Identify pixels to trim.
        %------------------------------------------------------------------
       
        % For each pixel, compute its minimum distance (across all
        % cadences) from the moving centroid position.
        nPixels       = numel(pixels);
        distanceArray = nan(nPixels, 1);        
        for iPixel = 1:nPixels
            distances = sqrt( (starRow    - pixelRows(iPixel)   ).^2 + ...
                              (starColumn - pixelColumns(iPixel)).^2 );
            distanceArray(iPixel) = min(distances);
        end
        
        % Generate a list of pixel indices in order of their minimum
        % distances from the centroid. Flag pixels inside the specified
        % radius and pixels in the optimal aperture.
        [distanceArray, sortedPixelIndices] = sort(distanceArray); % Ascending order
        pixelsWithinRadius = ...
            colvec(distanceArray <= radiusInPrfWidths * prfWidthPixels);
        pixelsInOptimalAperture = ...
            colvec([pixels(sortedPixelIndices).inOptimalAperture]);
        
        % Flag the union of optimal aperture pixels and pixels within the
        % specifide radius.
        apertureIndicators = pixelsWithinRadius | pixelsInOptimalAperture;
        
        % If the number of aperture pixels identified falls below the
        % minApertureSize threshold, then retain the minimum complement of
        % pixels in order of their proximity to the estimated centroid
        % position.
        if nnz(apertureIndicators) < minApertureSize
            numPixelsToAdd = minApertureSize - nnz(apertureIndicators);
            apertureIndicators( find( ~apertureIndicators, ...
                numPixelsToAdd, 'first') ) = true;
        end
        
        %------------------------------------------------------------------
        % Trim the apertures.
        %------------------------------------------------------------------
        apertureIndices = sortedPixelIndices(apertureIndicators);
        targetArray(iTarget).pixelDataStruct = pixels(apertureIndices);
    end
    
    paDataObject.targetStarDataStruct = targetArray;
end

