function initialize_contributing_stars_from_list(obj, targetArray, kics, keplerIds)
%**************************************************************************
% initialize_contributing_stars_from_list(obj, targetArray, kics, keplerIds)
%**************************************************************************
% Initialize obj.contributingStars from a list of kepler IDs. 
%
% INPUTS
%     targetArray : An array of PA targetDataStruct structures whose masks
%                   comprise the aperture being modeled. This array will
%                   usually have just one element. 
%     kics        : A struct array containing a partial Kepler Input
%                   Catalog (KIC). If empty, only the stars provided in the
%                   'targets' array are used to model the aperture.
%     keplerIds   : An array of kepler IDs to be used in constructing the
%                   model. Only stars from this list are included. If any
%                   of the specified stars do not have corresponding
%                   entries in either the 'kics' catalog or targetArray,
%                   they are omitted from the model.   
% OUTPUTS
%    (none)
%     
% NOTES
%   - If entries for sellar target stars exist in the catalog, the catalog
%     parameters are used. Otherwise, the parameters in the target struct 
%     are used.
%   - We still exclude stars whose expected flux contributions are too low
%     (based on excludeSnrThreshold) and limit the number of contributing
%     stars to maxNumStars. Therefore, stars listed in the keplerIds input
%     are NOT GUARANTEED to be included in the model.
%
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
    
    DEGREES_PER_HOUR = 15.0;     
    
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

    % If stellar targets do not have entries in the catalog arrays, create
    % entries for them. 
    for iTarget = 1:numel(targetArray)
        
        if is_valid_id(targetArray(iTarget).keplerId, 'catalog');
            
            targetId  = targetArray(iTarget).keplerId;
            targetMag = targetArray(iTarget).keplerMag;
            targetRa  = targetArray(iTarget).raHours;
            targetDec = targetArray(iTarget).decDegrees;

            % Skip this target if any required fields are empty.
            if isempty(targetId) || isempty(targetMag) || ...
               isempty(targetRa) || isempty(targetDec)
               continue;
            end

            % Add to the catalog if not already there.
            if ~ismember(targetId, kepIdArray)
                kepIdArray(end+1)      = targetId;
                kepMagArray(end+1)     = targetMag;
                raHoursArray(end+1)    = targetRa;
                decDegreesArray(end+1) = targetDec;
            end
        end
    end
    
 
    %----------------------------------------------------------------------
    % Build an array of contributing star candidates.
    %----------------------------------------------------------------------  
    
    % Identify valid stars. That is, stars whose Kepler IDs were specified
    % in the input list and that have corresponding entries in the
    % attribute arrays constructed above.
    isValid   = ismember(keplerIds, kepIdArray);
    keplerIds = keplerIds(isValid);
    
    starStructCellArray = cell(1, length(keplerIds));
    [starStructCellArray{:}] = deal(emptyStarStruct);
    
    for iStar = 1:length(keplerIds)
        
        index = find(kepIdArray == keplerIds(iStar));
        
        starStructCellArray{iStar}.keplerId          = kepIdArray(index);
        starStructCellArray{iStar}.keplerMag         = kepMagArray(index);
        starStructCellArray{iStar}.raDegrees         = DEGREES_PER_HOUR * raHoursArray(index);
        starStructCellArray{iStar}.decDegrees        = decDegreesArray(index);
        starStructCellArray{iStar}.catalogMag        = kepMagArray(index);
        starStructCellArray{iStar}.catalogRaDegrees  = DEGREES_PER_HOUR * raHoursArray(index);
        starStructCellArray{iStar}.catalogDecDegrees = decDegreesArray(index);
    end
    
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

%********************************* EOF ************************************