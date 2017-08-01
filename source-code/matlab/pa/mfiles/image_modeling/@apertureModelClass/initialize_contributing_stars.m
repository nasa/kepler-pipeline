function initialize_contributing_stars(obj, targetArray, kics)
%**************************************************************************
% initialize_contributing_stars(obj, targetArray, kics)
%**************************************************************************
% Initialize obj.contributingStars. Use rough SNR estimates to identify
% stars to include in the model and to set position locks for RA/Dec
% fitting.
%
% INPUTS
%     targetArray : An array of PA targetDataStruct structures whose masks
%                   comprise the aperture being modeled. This array will
%                   usually have just one element. 
%     kics        : A struct array containing a partial Kepler Input
%                   Catalog (KIC). If empty, only the stars provided in the
%                   'targets' array are used to model the aperture.
% OUTPUTS
%    (none)
%     
% NOTES
%
%   - There may be multiple targets whose masks comprise what we are
%     calling an "aperture". We are constructing an array of starStruct
%     elements for the whole aperture and must loop through each target in
%     the aperture, handling the following cases:
% 
%     1.	stellar target + catalog
% 
%           Create a starStruct element for each proximate star and add
%           them to starStructArray. If the target ID is not found in the
%           catalog then create a single starStruct element for it and add
%           it to starStructArray.
% 
%     2.	stellar target + no catalog
% 
%           Create a single starStruct element for this target and add it
%           to starStructArray.
% 
%     3.	custom target + catalog
% 
%           If no proximate stars are found then do not modify
%           starStructArray.
% 
%     4.	custom target + no catalog
% 
%           skip this target without modifying starStructArray.
% 
%     Remember that custom targets have no main star to which we can attach
%     a PRF. This means that, while we can construct a good model using a
%     catalog, we have no target star information if a catalog is not
%     provided.
%
%   - This function always prefers the RA, Dec, and magnitude values
%     provided by the 'kics' input parameter. The initial step is to
%     replace the values in targetArray with the corresponding values in
%     'kics', if available.
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
    
    DEGREES_PER_HOUR    = 15.0;     
    degreesPerPixel = apertureModelClass.DEGREES_PER_PIXEL;    
    
    emptyStarStruct = struct( ...
        'keplerId',            [], ...
        'keplerMag',           [], ...
        'raDegrees',           [], ...
        'decDegrees',          [], ...
        'lockRaDec',           true, ... % Lock sky coordinates by default.
        'centroidRow',         [], ...
        'centroidCol',         [], ...
        'prf',                 [], ...
        'estimatedPeakSnr',    [], ...
        'isInsideAperture',    [], ...
        'minDistToValidPixel', [], ...
        'catalogMag',          [], ...
        'catalogRaDegrees',    [], ...
        'catalogDecDegrees',   [] ...
    );
    
    %----------------------------------------------------------------------
    % Determine the type of catalog provided, if any, and populate the
    % target attribute arrays. Prune bright UKIRT stars. Replace RA, Dec,
    % and magnitude values in targetArray with their corresponding entries
    % from the catalog, if available.
    %----------------------------------------------------------------------    
    [kepIdArray, kepMagArray, raHoursArray, decDegreesArray] = ...
            apertureModelClass.get_attribute_arrays_from_catalog_struct(kics);
    
    % Prune bright UKIRT stars.
    ukirtMagnitudeThreshold = obj.configStruct.ukirtMagnitudeThreshold;
    isUkirt = is_valid_id(kepIdArray, 'ukirt');
    pruneIndicators = isUkirt & kepMagArray < ukirtMagnitudeThreshold;   
    kepIdArray(pruneIndicators)      = [];
    kepMagArray(pruneIndicators)     = [];
    raHoursArray(pruneIndicators)    = [];
    decDegreesArray(pruneIndicators) = [];
        
    if ~isempty(kepIdArray)
        for iTarget = 1:numel(targetArray)  
            targetKicsIndex = find(kepIdArray == targetArray(iTarget).keplerId, 1);     
            if ~isempty(targetKicsIndex)
                targetArray(iTarget).keplerMag  = kepMagArray(targetKicsIndex);
                targetArray(iTarget).raHours    = raHoursArray(targetKicsIndex);
                targetArray(iTarget).decDegrees = decDegreesArray(targetKicsIndex);
            end
        end
    end
    
        
    %----------------------------------------------------------------------
    % Build an array of contributing star candidates.
    %----------------------------------------------------------------------
    starStructCellArray = {};
    
    for iTarget = 1:numel(targetArray)

        isCustomTarget = is_valid_id(targetArray(iTarget).keplerId, 'custom');
        
        if ~isCustomTarget
            thisTargetStarStruct = emptyStarStruct;
            thisTargetStarStruct.keplerId   = targetArray(iTarget).keplerId;
            thisTargetStarStruct.keplerMag  = targetArray(iTarget).keplerMag;
            thisTargetStarStruct.raDegrees  = DEGREES_PER_HOUR * targetArray(iTarget).raHours;
            thisTargetStarStruct.decDegrees = targetArray(iTarget).decDegrees;
            thisTargetStarStruct.catalogMag        = thisTargetStarStruct.keplerMag;
            thisTargetStarStruct.catalogRaDegrees  = thisTargetStarStruct.raDegrees;
            thisTargetStarStruct.catalogDecDegrees = thisTargetStarStruct.decDegrees;
        end
        
        if isempty(kepIdArray)
            % If this is a custom target, continue to the next target
            % without modifying starStructArray. Otherwise add this target
            % to the array. 
            if isCustomTarget
                continue;
            else
                starStructCellArray{end+1} = thisTargetStarStruct;
            end
        else
            %--------------------------------------------------------------
            % Search the catalog for proximate stars.
            %--------------------------------------------------------------
            
            % Obtain this target's sky coordinates.
            targetRaHours = targetArray(iTarget).raHours;
            targetDecDeg  = targetArray(iTarget).decDegrees;

            % Determine the dimensions of the area over which the PRF is
            % defined. This is typically either an 11 x 11 or 15 x 15 pixel
            % grid.
            prfWidthInPixels = obj.prfModelHandle.get_static_width_in_pixels();

            ccdRow = [targetArray(iTarget).pixelDataStruct.ccdRow];
            ccdCol = [targetArray(iTarget).pixelDataStruct.ccdColumn];
            pixRow = ccdRow - min(ccdRow);
            pixCol = ccdCol - min(ccdCol);

            % Determine length of the mask's bounding box diagonal
            % (pixels). 
            maskBoxDiagonal = sqrt(max(pixRow)^2 + max(pixCol)^2); 

            % Determine length of the PRF diagonal (pixels).
            prfDiagonal = sqrt(2)*prfWidthInPixels; 

            % Determine the angular neighborhood (degrees) in which to
            % look for influential stars, defined as half the bounding
            % box diagonal + the PRF diagonal in degrees. Note that
            % angular distances are defined in degress along a great
            % circle passing through the reference point, while right
            % ascension is not. Therefore angluar distance based on RA
            % must be scaled by cos(dec).
            radiusDeg = degreesPerPixel * ( (maskBoxDiagonal + prfDiagonal)/2 ); 

            % Find other stars within the search radius.
            if     isempty(raHoursArray)  || isempty(decDegreesArray) ...
                || isempty(targetRaHours) || isempty(targetDecDeg)
                proximateIndices = [];
            else
                proximateIndices = find( angular_distance_degrees( ...
                    raHoursArray, decDegreesArray, targetRaHours, targetDecDeg) ...
                    < radiusDeg);
            end
            
            
            %--------------------------------------------------------------
            % If proximate stars were found in the catalog, then add them
            % to the array. Otherwise add thisTargetStarStruct to the array
            % if this is a stellar target. If this is a custom target and
            % no proximate stars were found, do nothing.
            %--------------------------------------------------------------
            if isempty(proximateIndices) 
                if isCustomTarget
                    continue;
                else
                    starStructCellArray{end+1} = thisTargetStarStruct;  
                end
            else
                for iStar=1:length(proximateIndices)
                    starStruct = emptyStarStruct;
                    
                    starStruct.keplerId          = kepIdArray(proximateIndices(iStar));
                    starStruct.keplerMag         = kepMagArray(proximateIndices(iStar));
                    starStruct.raDegrees         = DEGREES_PER_HOUR * raHoursArray(proximateIndices(iStar));
                    starStruct.decDegrees        = decDegreesArray(proximateIndices(iStar));
                    starStruct.catalogMag        = starStruct.keplerMag;
                    starStruct.catalogRaDegrees  = starStruct.raDegrees;
                    starStruct.catalogDecDegrees = starStruct.decDegrees;
                    
                    starStructCellArray{end+1} = starStruct;
                end
            end
        end
    end % for iTarget = ...

    % Convert the cell array to a struct array.
    starStructArray = cell2mat(starStructCellArray);
    
    % Nothing to do if no candidates were identified.
    if isempty(starStructArray)
        return;
    end
    
    %------------------------------------------------------------------
    % Prune any duplicates and initialize the contributingStars
    % property. 
    %------------------------------------------------------------------
    [~, idx] = unique([starStructArray.keplerId]);
    obj.contributingStars = starStructArray(idx);

    %------------------------------------------------------------------
    % Initialize centroid positions.
    %------------------------------------------------------------------
    obj.compute_contributing_star_centroids();
    
    %------------------------------------------------------------------
    % Estimate the expected peak pixel SNR for the flux contributions of
    % each star and exclude stars whose expected SNR falls below a
    % threshold. If maxNumStars is not empty, limit the number of
    % contributing stars. Contributing stars are added in the order of
    % their expected peak SNR.
    %------------------------------------------------------------------
    [estimatedPeakSnr, minDistToValidPixel] = obj.estimate_peak_snr_per_star();
    cellArray = num2cell(minDistToValidPixel);
    [obj.contributingStars(:).minDistToValidPixel] = cellArray{:};

    isContributingStar = estimatedPeakSnr > obj.configStruct.excludeSnrThreshold;

    % Limit the number of contributing stars.
    if isfield(obj.configStruct, 'maxNumStars') ...
       && ~isempty(obj.configStruct.maxNumStars) ... % No limit if empty.
       && nnz(isContributingStar) > obj.configStruct.maxNumStars

        if obj.configStruct.maxNumStars > 0
            % Sort contributing stars by expected peak SNR.
            sortOnFirstColumnInDescendingOrder = -1;
            sorted = sortrows([estimatedPeakSnr(isContributingStar), ...
                colvec(find(isContributingStar))], ...
                sortOnFirstColumnInDescendingOrder);
            
            % Select the highest-ranked maxNumStars contributors.
            contributingIndices = sorted(1:obj.configStruct.maxNumStars, 2);
            isContributingStar(:) = false;
            isContributingStar(contributingIndices) = true;
        else
            isContributingStar(:) = false;
        end
    end
    
    obj.contributingStars = obj.contributingStars(isContributingStar);
    cellArray = num2cell(estimatedPeakSnr(isContributingStar));
    [obj.contributingStars(:).estimatedPeakSnr] = cellArray{:};
    
    
    %------------------------------------------------------------------
    % Set position locks, which allow or prevent updating of RA and Dec.
    % Lock positions of stars whose peak SNR is too low. Lock positions of
    % stars whose centroids are never inside a valid (i.e., non-gapped)
    % pixel in the aperture. 
    %------------------------------------------------------------------

    % Determine whether or not the centroid of each contributing star falls
    % inside the aperture on any cadence in the model.
    for iStar = 1:numel(obj.contributingStars)
        obj.contributingStars(iStar).isInsideAperture = ...
            any( obj.is_inside_aperture( ...
                obj.contributingStars(iStar).centroidRow, ...
                obj.contributingStars(iStar).centroidCol) );
    end
    
    if obj.configStruct.raDecFittingEnabled
        isBelowThreshold = [obj.contributingStars(:).estimatedPeakSnr] ...
            < obj.configStruct.lockSnrThreshold;
        isOutsideAperture = ~[obj.contributingStars(:).isInsideAperture];
        lockRaDecFlags = num2cell( isBelowThreshold | isOutsideAperture);
        [obj.contributingStars(:).lockRaDec] = lockRaDecFlags{:};   
    end
    
    %------------------------------------------------------------------
    % If using precomputed subsampled PRFs, then initialize them.
    % THIS CODE IS CURRENTLY NOT USED.
    %------------------------------------------------------------------
    if isfield(obj.configStruct, 'usePrecomputedStaticPrfs') && ...
            obj.configStruct.usePrecomputedStaticPrfs == true
        obj.precompute_subsampled_static_prfs();
    end

end



%**************************************************************************
% Compute the angular distance in degrees between each point in the arrays
% raHours and decDegrees and a reference point. 
function degrees = angular_distance_degrees(raHours, decDegrees, ...
                                            refRaHours, refDecDegrees)
    degreesPerHour = 15;    
    degrees2Rads   = pi/180;
    
    raRads     = degrees2Rads * degreesPerHour * raHours;
    refRaRads  = degrees2Rads * degreesPerHour * refRaHours;
    decRads    = degrees2Rads * decDegrees;
    refDecRads = degrees2Rads * refDecDegrees;
    
    arclength = acos( cos(pi/2 - decRads) .* cos(pi/2 - refDecRads) + ...
        sin(pi/2 - decRads) .* sin(pi/2 - refDecRads) .* cos(raRads - refRaRads) );
    
    degrees = arclength / degrees2Rads;
end



%**************************************************************************
% For each point P = [ra(n), dec(n)], determine approximate RA and Dec
% limits of a window centered on P and measuring nRaPixels pixels in the RA
% direction and nDecPix pixels in the declination direction. Note that RA
% bounds are in hours, while declination bounds are in degrees.
function [raLow, raHigh, decLow, decHigh] = ...
    get_ra_dec_window( raHours, decDegrees, nRaPix, nDecPix)

    degreesPerHour = 15;    
    degreesPerPixel = apertureModelClass.DEGREES_PER_PIXEL;    
    
    raWidthDegrees  = nRaPix  * degreesPerPixel ./ cos(decDegrees);
    decWidthDegrees = nDecPix * degreesPerPixel * ones(size(decDegrees));
    
    raHalfWidthHours     = raWidthDegrees  / (2 * degreesPerHour);
    decHalfWidthDegrees  = decWidthDegrees / 2;
    
    % Limit RA to the range [0,24]
    raLow   = mod(raHours - raHalfWidthHours, 24);
    raHigh  = mod(raHours + raHalfWidthHours, 24);
    
    % Limit Dec to the range [-360, 360]
    decLow  = rem(decDegrees - decHalfWidthDegrees, 360);
    decHigh = rem(decDegrees + decHalfWidthDegrees, 360);
    
    % Limit Dec to the range [-180, 180]
    ind = abs(decLow) > 180;
    decLow(ind) = decLow(ind) - sign(decLow(ind)) * 360;
    ind = abs(decHigh) > 180;
    decHigh(ind) = decHigh(ind) - sign(decHigh(ind)) * 360;
    
    % Limit Dec to the range [-90, 90]
    ind = abs(decLow) > 90;
    decLow(ind) = sign(decLow(ind)) * 180 - decLow(ind);
    ind = abs(decHigh) > 90;
    decHigh(ind) = sign(decHigh(ind)) * 180 - decHigh(ind);    
end


%********************************* EOF ************************************