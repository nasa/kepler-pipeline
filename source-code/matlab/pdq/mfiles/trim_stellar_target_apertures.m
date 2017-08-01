function pdqDataStruct = ...
    trim_stellar_target_apertures(pdqDataStruct, radius, minApertureSize)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function pdqDataStruct = ...
% trim_stellar_target_apertures(pdqDataStruct, radius, minApertureSize)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Trim pixels from the aperture of each PDQ_STELLAR target that fall more
% than 'radius' pixels from the estimated centroid position. Re-center the
% optimal aperture on the estimated centroid position.
%
% INPUTS
%     pdqDataStruct       : A Quasar-modified PDQ input structure 
%                           containing the field
%                           'preliminaryAttitudeSolutionStruct'. 
%     radius              : A scalar distance in pixels. 
%     minApertureSize     : Don't trim the apertures to be smaller than
%                           this number of pixels. If minApertureSize is
%                           set to zero, then targets having zero pixels
%                           inside the radius threshold are removed from
%                           the pdqDataStruct. (DEFAULT=0)
% OUTPUTS
%     pdqDataStruct       : A copy of the input pdqDataStruct with pixels
%                           trimmed from any PDQ_STELLAR targets, according
%                           to the parameters 'radius' and
%                           'minApertureSize' and optimal apertures
%                           re-centered on the estimated centroids.
% 
% Note that this code will work with a multi-cadence input, but it is
% assumed that a single preliminary attitude solution is inserted by Quasar
% and that this solution can be used for all cadences.
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
    
    raDec2PixObject = raDec2PixClass(pdqDataStruct.raDec2PixModel, 'one-based');
    attitude    = pdqDataStruct.preliminaryAttitudeSolutionStruct;
    targetArray = pdqDataStruct.stellarPdqTargets;
    pruneIndicators = false(numel(targetArray), 1);
    
    for iTarget = 1:numel(targetArray)
        
        if ~ismember('PDQ_STELLAR', targetArray(iTarget).labels)
            continue
        end
        
        % Estimate the CCD position of the target's centroid.
        raDegrees  = DEGREES_PER_HOUR * targetArray(iTarget).raHours;
        decDegrees = targetArray(iTarget).decDegrees;
        
        [~, ~, starRow, starColumn] = ra_dec_2_pix_absolute(raDec2PixObject, ...
                raDegrees, ...
                decDegrees, ...
                attitude.mjd,  ...
                attitude.raDegrees, ...
                attitude.decDegrees, ...
                attitude.rollDegrees);

        pixels = targetArray(iTarget).referencePixels;
        pixelRows    = [pixels.row];
        pixelColumns = [pixels.column];
                
        % Determine pixels within the specified radius of the star
        % centroid.
        distanceSquared = (pixelRows - starRow).^2 + (pixelColumns - starColumn).^2;
        pixelsWithinRadius = distanceSquared <= radius^2;
        
        % If the number of pixels within the specified radius falls below
        % the minApertureSize threshold, then retain the minimum complement
        % of pixels in order of their proximity to the estimated centroid
        % position. 
        if nnz(pixelsWithinRadius) < minApertureSize
            [~,idx] = sort(distanceSquared); % Sort in ascending order.
            retainIndices = idx(1:min(length(idx), minApertureSize));
        else
            retainIndices = pixelsWithinRadius;
        end
        
        % Trim this target's set of pixels and re-center the optimal
        % aperture. If no pixels are to be retained, then remove the target
        % entirely.
        if any(retainIndices)
            isInOptimalAperture = [pixels.isInOptimalAperture];
            oaRows       = pixelRows(isInOptimalAperture);
            oaColumns    = pixelColumns(isInOptimalAperture);
            oaMeanRow    = mean(oaRows);
            oaMeanColumn = mean(oaColumns);
            rowShift     = round(starRow - oaMeanRow);
            columnShift  = round(starColumn - oaMeanColumn);
            oaRows       = oaRows + rowShift;
            oaColumns    = oaColumns + columnShift;
            
            % Clear optimal aperture flags.
            [pixels.isInOptimalAperture] = deal(false);
            
            % Set new optimal aperture flags.
            ind = ismember([pixelRows(:), pixelColumns(:)], [oaRows(:), oaColumns(:)], 'rows');
            [pixels(ind).isInOptimalAperture] = deal(true);
            
            % Prune pixels.
            targetArray(iTarget).referencePixels = pixels(retainIndices);            
        else
            pruneIndicators(iTarget) = true;
        end
    end    
    
    pdqDataStruct.stellarPdqTargets = targetArray(~pruneIndicators);
end

