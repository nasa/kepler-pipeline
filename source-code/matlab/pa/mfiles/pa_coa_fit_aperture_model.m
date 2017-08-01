%************************************************************************** 
% [aperturePixelArray, contributingStarStruct, apertureModelObject] = ...
%     pa_coa_fit_aperture_model(paDataStruct, targetIndex, ...
%         cadenceIndicators, raDecFitIndicators, ...
%         fittingEnabled, catalog)
%************************************************************************** 
% Construct a PRF-based model of a target aperture on the specified
% cadences and return modeled pixel values broken into the following
% components:
%
%     P(i,j,c) = targ(i,j,c) + bgStar(i,j,c) + bgConst(i,j,c)
%
% where
%     targ(i,j,c)    is the estimated target flux at pixel i,j and 
%                    cadence c.
%     bgStar(i,j,c)  is the estimated flux at pixel i,j and cadence c due
%                    to known background stars in the vicinity.
%     bgConst(i,j,c) is constant offset term intended to capture any
%                    additional background flux at pixel i,j and cadence c.
%                    Such flux may be due to imperfect background removal,
%                    unknown stars, and other sources.
%
%
% In the descriptions below,
%
%     nQtrCadences   denotes the number of cadences in the quarter (i.e., 
%                    the length of the pixel time series in paDataStruct). 
%
%     nCadences      denotes the number of cadences BEING MODELED and not 
%                    the total number of cadences in the quarter. 
%
%     nStars         denotes the number of stars in the model.
%
%
% INPUTS
%
%     paDataStruct      : The following fields are used (can also be a 
%                         struct with these fields):
%
%                         prfModel
%                         fcConstants
%                         cadenceTimes
%                         targetStarDataStruct -- with background removed
%                         motionPolyStruct (added to the PA input struct)
%                         apertureModelConfigurationStruct
%                         paConfigurationStruct
%
%     targetIndex       : An integer specifying the target aperture to
%                         model:
%                         paDataStruct.targetStarDataStruct(targetIndex).
%
%     cadenceIndicators : An nQtrCadences-length logical array indicating
%                         cadences on which to fit the model to the
%                         observations.
%
%     raDecFitIndicators: An nQtrCadences-length logical array indicating
%                         cadences to use for fitting stellar coordinates.
%                         If empty, the cadences specified by
%                         cadenceIndicators are used. 
%
%     fittingEnabled    : A logical flag. If true (the default), a model is
%                         fit to the observations. Otherwise, a model is
%                         constructed purely from information in the
%                         catalog.
%
%     catalog           : An optional struct containing, at a minimum, the 
%                         following fields: 
%
%                             keplerId:  [N-by-1 double]
%                             keplerMag: [N-by-1 double]
%                             ra:        [N-by-1 double]
%                             dec:       [N-by-1 double]
%
%                         The aperture modeling code will also accept
%                         fieldnames 'kepid' and 'kepmag' in place of
%                         'keplerId' and 'keplerMag'. If a catalog struct
%                         is not provided or is empty, then the field
%                         paDataStruct.targetStarDataStruct(targetIndex).kics
%                         will be used if it exists and is not empty. If
%                         both are empty or do not exist, then only the
%                         target star is used in contructing the aperture
%                         model. (default = [])
%
% OUTPUTS
%
%     aperturePixelArray: A copy of the pixel data struct array for the
%                         specified target the following fields added: 
%
%                              targetFluxEstimates    [nQtrCadences-by-1]
%                              bgStellarFluxEstimates [nQtrCadences-by-1]
%                              bgConstFluxEstimates   [nQtrCadences-by-1]
%
%                         These time series will contain NaN values on
%                         gapped cadences and on any cadences where the
%                         input cadenceIndicators are set to 'false' or 0.
%
%     contributingStarStruct [1-by-nStars]
%     |                 : An array of structures containing stellar
%     |                   parameters and centroid time series for each star
%     |                   contributing flux to the aperture model. Each
%     |                   struct element has the following fields:
%     |
%     |-.keplerId
%     |-.keplerMag      : The original Kepler magnitude, taken from the
%     |                   input paDataStruct.
%     |-.raDegrees      : The original right ascension, taken from the
%     |                   input paDataStruct.
%     |-.decDegrees     : The original declination, taken from the input
%     |                   paDataStruct.
%     |-.totalFlux      : An nCadences-by-1 time series of flux estimates
%     |                   in e-/cadence. These are estimates of total flux
%     |                   for the star and not just the component captured
%     |                   within the aperture. Estimates of flux from the
%     |                   target at each pixel can be found in 
%     |                   aperturePixelArray.targetFluxEstiamtes.   
%     |-.centroidRow    : An nCadences-by-1 time series of sub-pixel row
%     |                   coordinates for this target's centroid.  
%     |-.centroidCol    : An nCadences-by-1 time series of sub-pixel column
%     |                   coordinates for this target's centroid. 
%     |-.updatedMag     : An updated estimate of the Kepler magnitude.
%     |-.updatedRa      : An updated estimate of the right ascension
%     |                   (degrees).
%      -.updatedDec     : An updated estimate of the declination (degrees).
%
%     apertureModelObject : This is an optional output included mainly for
%                         debugging purposes. We always return the model
%                         for which the RA/Dec fitting was done. If a
%                         separate RA/Dec fitting model was created, then
%                         the returned model will contian only the cadences
%                         used for RA/Dec fitting.
%                         
% NOTES
%     - paDataStruct contains motion polynomials, which are added by
%       update_pa_inputs.m.
%     - For now we assume that each target aperture can be treated
%       independently, even if it hapens to overlap with another. In the
%       future we may wish to process overlapping or proximate apertures in
%       groups.
%     - While no star, including the target, is guaranteed to be included
%       in the model, the set of stars included in the RA/Dec fitting model
%       will also be included in the amplitude-fitting model even when
%       position and amplitude are fit separately.
%     - RA/Dec fitting is automatically disabled if the target mask
%       contains any saturating pixels.
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
function [aperturePixelArray, contributingStarStruct, apertureModelObject] = ...
    pa_coa_fit_aperture_model(paDataStruct, targetIndex, ...
        cadenceIndicators, raDecFitIndicators, fittingEnabled, catalog)
    
    DEGREES_PER_HOUR = 15.0;     

    if ~exist('raDecFitIndicators', 'var') || isempty(raDecFitIndicators)
        raDecFitIndicators = cadenceIndicators;
    end
    
    if ~exist('fittingEnabled', 'var') || isempty(fittingEnabled)
        fittingEnabled = true;
    end
    
    % If no 'catalog' argument is provided, use the KIC entries from the
    % target data struct. If they are unavailable, default to the empty
    % matrix.  
    if ~exist('catalog', 'var')
        catalog = [];
    end    
        
    if isempty(catalog)
        if isfield(paDataStruct.targetStarDataStruct(targetIndex), 'kics')
            catalog = paDataStruct.targetStarDataStruct(targetIndex).kics;
        end
    end    
    
    % Disable RA/Dec fitting if the target mask contains any saturating
    % pixels.
    if paDataStruct.targetStarDataStruct(targetIndex).saturatedRowCount > 0 
        paDataStruct.apertureModelConfigurationStruct.raDecFittingEnabled = false;
    end
        
    targetId = paDataStruct.targetStarDataStruct(targetIndex).keplerId;
    cadenceDurationInMinutes = ...
        compute_cadence_duration_in_minutes(paDataStruct.cadenceTimes);
    doSeparateRaDecFit = ...
        paDataStruct.apertureModelConfigurationStruct.raDecFittingEnabled ...
        && ~isequal(cadenceIndicators,raDecFitIndicators);
        
    %----------------------------------------------------------------------    
    % Construct a model based strictly on catalog parameters (RA, Dec, mag)
    % if requested with fittingEnabled=false ...
    %----------------------------------------------------------------------    
    if ~fittingEnabled
        [aperturePixelArray, contributingStarStruct, apertureModelObject] = ...
        construct_model_from_catalog_values(paDataStruct, targetIndex, ...
            cadenceIndicators, catalog);
        
    %---------------------------------------------------------------------- 
    %  ... otherwise fit a model to the observed flux.
    %----------------------------------------------------------------------    
    else 
        
        %------------------------------------------------------------------    
        % If doSeparateRaDecFit == true then create a separate aperture
        % model for joint position-magnitude fitting. Since the joint
        % fitting process is time consuming, using fewer cadences can yield
        % significant speed up.
        %------------------------------------------------------------------    
        if doSeparateRaDecFit

            apertureModelInputStruct = ...
                apertureModelClass.inputs_from_pa_data_struct( paDataStruct, ...
                    targetIndex, raDecFitIndicators);
            apertureModelInputStruct.catalog = catalog;

            % Update the catalog. If the original catalog does not have an
            % entry for the target star, the updated one will. Note that
            % the target star parameters in the updated catalog will
            % superede those in the targetDataStruct when we later fit the
            % aperture model with RA/Dec fitting disabled.
            originalCatalog = catalog;        
            [catalog, raDecFitApertureModelObject] = ...
                update_catalog_positions(apertureModelInputStruct);

            % Turn off RA/Dec fitting for the final amplitude fit.
            paDataStruct.apertureModelConfigurationStruct.raDecFittingEnabled = false;
        end    

        %------------------------------------------------------------------    
        % Perform the main model fit. If doSeparateRaDecFit == true then
        % this step performs a final amplitude fit using the updated
        % catalog from the previous RA/Dec-fitting step. Otherwise all
        % aspects of the model fit are done here, including RA/Dec fitting
        % if enabled.
        %------------------------------------------------------------------    
        apertureModelInputStruct = ...
            apertureModelClass.inputs_from_pa_data_struct( paDataStruct, ...
                targetIndex, cadenceIndicators);

        % If a catalog was passed in or an updated catalog was created from
        % a separate fit (above), then use it. Otherwise use the catalog in
        % apertureModelInputStruct.
        if ~isempty(catalog)
            apertureModelInputStruct.catalog = catalog;
        end

        % The new model should use the same stars as the one used for
        % RA/Dec fitting, so we add a list of Kepler IDs to the input
        % struct. NOTE that by setting excludeSnrThreshold to zero, we
        % guarantee these stars will be included in the amplitude-fitting
        % model. Also note that if the requested stars have migrated to far
        % in the RA/Dec fitting phase (e.g., because of bad motion
        % polynomials) this may result in a poorly-conditioned design
        % matrix.
        if exist('raDecFitApertureModelObject', 'var') && ...
           ~isempty(raDecFitApertureModelObject.contributingStars)
            apertureModelInputStruct.keplerIds = ...
                colvec([raDecFitApertureModelObject.contributingStars.keplerId]);
            apertureModelInputStruct.configStruct.excludeSnrThreshold = 0;
        end

        apertureModelObject = apertureModelClass(apertureModelInputStruct);
        apertureModelObject.fit_observations();

        %------------------------------------------------------------------    
        % Since we provided an updated catalog to the main model fitting
        % step, we need to go back and insert the original catalog values
        % into apertureModelObject.contributingStars. This is a bit messy
        % but will have to do for now.
        %------------------------------------------------------------------    
        if doSeparateRaDecFit && ~isempty(originalCatalog)

            for iStar = 1:numel(apertureModelObject.contributingStars)
                keplerId = apertureModelObject.contributingStars(iStar).keplerId;
                catalogIndex = find([originalCatalog.keplerId] == keplerId, 1);
                if ~isempty(catalogIndex)
                    apertureModelObject.contributingStars(iStar).catalogMag ...
                        = originalCatalog(catalogIndex).keplerMag.value;
                    apertureModelObject.contributingStars(iStar).catalogRaDegrees ...
                        = DEGREES_PER_HOUR * originalCatalog(catalogIndex).ra.value;
                    apertureModelObject.contributingStars(iStar).catalogDecDegrees ...
                        = originalCatalog(catalogIndex).dec.value;
                end
            end
        end

        %------------------------------------------------------------------    
        % Handle the special case in which no contributing stars were
        % identified. In this case the stellar components of the aperture
        % model are zero and all predicted flux is contained in
        % bgConstFluxEstimates.
        %------------------------------------------------------------------    
        if apertureModelObject.get_num_contributing_stars() < 1
            aperturePixelArray.bgConstFluxEstimates   ...
                = apertureModelObject.evaluate();
            aperturePixelArray.targetFluxEstimates    ...
                = zeros(size(aperturePixelArray.bgConstFluxEstimates));
            aperturePixelArray.bgStellarFluxEstimates ...
                = zeros(size(aperturePixelArray.bgConstFluxEstimates));
            contributingStarStruct = [];
            return;
        end

        %------------------------------------------------------------------
        % Construct the output contributingStarStruct and update magnitude
        % estimates.
        %------------------------------------------------------------------   
        contributingStarStruct = ...
            construct_contributing_star_struct(apertureModelObject);     
        contributingStarStruct = update_magnitudes( contributingStarStruct, ...
            apertureModelObject, cadenceDurationInMinutes);
        
        %------------------------------------------------------------------
        % Construct the output pixelDataStruct.
        %------------------------------------------------------------------   
        inputPixelArray = ...
            paDataStruct.targetStarDataStruct(targetIndex).pixelDataStruct;
        aperturePixelArray = construct_output_pixel_array(inputPixelArray, ...
            apertureModelObject, cadenceIndicators, targetId);    

        %------------------------------------------------------------------
        % Return the appropriate aperture model object. We always return
        % the model for which the RA/Dec fitting was done. If a separate
        % RA/Dec fitting model was created, then the returned model will
        % contian only the cadences used for RA/Dec fitting. NOTE that this
        % must not be done before the call to
        % construct_contributing_star_struct().
        %------------------------------------------------------------------   
        if doSeparateRaDecFit
            apertureModelObject = raDecFitApertureModelObject;
        end

        % Copy the magnitude estimates into apertureModelObject.
        nStars = numel(apertureModelObject.contributingStars);
        if ~isempty(contributingStarStruct) && ...
            numel(contributingStarStruct) == nStars
            for iStar = 1:nStars
                apertureModelObject.contributingStars(iStar).keplerMag = ...
                    contributingStarStruct(iStar).updatedMag;
            end
        end
    end    
end


%************************************************************************** 
% Construct an aperture model without fitting to observed flux. Model
% coefficients are derived directly from catalog magnitudes.
%************************************************************************** 
function [aperturePixelArray, contributingStarStruct, apertureModelObject] = ...
    construct_model_from_catalog_values(paDataStruct, targetIndex, ...
        cadenceIndicators, catalog)
    
    paDataStruct.apertureModelConfigurationStruct.raDecFittingEnabled = false;
    targetId = paDataStruct.targetStarDataStruct(targetIndex).keplerId;
    cadenceDurationInMinutes = ...
        compute_cadence_duration_in_minutes(paDataStruct.cadenceTimes);
    
    %----------------------------------------------------------------------
    % Construct the aperture model object.
    %----------------------------------------------------------------------    
    apertureModelInputStruct = ...
        apertureModelClass.inputs_from_pa_data_struct( paDataStruct, ...
            targetIndex, cadenceIndicators);

    % If a non-empty catalog was passed in then use it. Otherwise use
    % the catalog in apertureModelInputStruct.
    if ~isempty(catalog)
        apertureModelInputStruct.catalog = catalog;
    end

    apertureModelObject = apertureModelClass(apertureModelInputStruct);
    apertureModelObject.set_coefficients_from_catalog_magnitudes(cadenceDurationInMinutes);
        
    %----------------------------------------------------------------------
    % Construct the output contributingStarStruct.
    %----------------------------------------------------------------------    
    contributingStarStruct = ...
        construct_contributing_star_struct(apertureModelObject);     

    %----------------------------------------------------------------------
    % Construct the output pixelDataStruct.
    %----------------------------------------------------------------------   
    inputPixelArray = ...
        paDataStruct.targetStarDataStruct(targetIndex).pixelDataStruct;
    aperturePixelArray = construct_output_pixel_array(inputPixelArray, ...
        apertureModelObject, cadenceIndicators, targetId);    
end


%************************************************************************** 
% Upon completion of the RA/Dec fitting process, this funciton merges the
% contributing star paramters from the field
% apertureModelObject.contributingStarStruct with the existing catalog
% entries, if there are any.
function [updatedCatalog, apertureModelObject] = ...
    update_catalog_positions(apertureModelInputStruct)

    DEGREES_PER_HOUR = 15.0;     
        
    apertureModelObject = apertureModelClass(apertureModelInputStruct);
    apertureModelObject.fit_observations(); 
        
    updatedCatalog = apertureModelInputStruct.catalog;
    starArray      = apertureModelObject.contributingStars;
    
    valueStruct = struct('value', NaN, 'uncertainty', NaN);
    kicsStruct = struct( ...
       'keplerId',  int16(0), ... 
       'keplerMag', valueStruct, ...
       'ra',        valueStruct, ...
       'dec',       valueStruct);
   
    for iStar = 1:numel(starArray)
        if isfield(updatedCatalog, 'keplerId')
            catalogIndex = find( ...
                [updatedCatalog.keplerId] == starArray(iStar).keplerId, 1);
        else
            catalogIndex = [];
        end
        
        if isempty(catalogIndex)
            newEntry = kicsStruct;
            newEntry.keplerId  = starArray(iStar).keplerId;
            newEntry.keplerMag.value = starArray(iStar).keplerMag;
            newEntry.ra.value  = starArray(iStar).raDegrees / DEGREES_PER_HOUR;
            newEntry.dec.value = starArray(iStar).decDegrees;
            updatedCatalog = [updatedCatalog, newEntry];
        else
            updatedCatalog(catalogIndex).keplerMag.value ...
                = starArray(iStar).keplerMag;
            updatedCatalog(catalogIndex).ra.value ...
                = starArray(iStar).raDegrees / DEGREES_PER_HOUR;
            updatedCatalog(catalogIndex).dec.value ...
                = starArray(iStar).decDegrees;
        end        
    end

end


%************************************************************************** 
function aperturePixelArray = construct_output_pixel_array( ...
    aperturePixelArray, apertureModelObject, cadenceIndicators, targetId)
    
    pdsRowCol =  [ colvec([aperturePixelArray.ccdRow]), ...
                   colvec([aperturePixelArray.ccdColumn]) ];
    amoRowCol =  [ colvec([apertureModelObject.pixelRows]), ...
                   colvec([apertureModelObject.pixelColumns]) ];
                   
    % amo2PdsMap(i) contains the index in aperturePixelArray corresponding  
    % to amoRowCol(i)
    [~, amo2PdsMap] = ismember(amoRowCol, pdsRowCol, 'rows');
    
    [targetFluxEstimates, bgStellarFluxEstimates, bgConstFluxEstimates] ...
        = evaluate_model_components(apertureModelObject, targetId);

    nPixels = numel(apertureModelObject.pixelRows);    
    for iAperturePixel = 1:nPixels
        pdsIndex = amo2PdsMap(iAperturePixel);
        gapIndicators = aperturePixelArray(pdsIndex).gapIndicators;
        
        pixelTimeSeries = nan(length(cadenceIndicators), 1);
        pixelTimeSeries(cadenceIndicators) = targetFluxEstimates(iAperturePixel, :);
        pixelTimeSeries(gapIndicators) = NaN;
        aperturePixelArray(pdsIndex).targetFluxEstimates = pixelTimeSeries;
        
        pixelTimeSeries = nan(length(cadenceIndicators), 1);
        pixelTimeSeries(cadenceIndicators) = bgStellarFluxEstimates(iAperturePixel, :);
        pixelTimeSeries(gapIndicators) = NaN;
        aperturePixelArray(pdsIndex).bgStellarFluxEstimates = pixelTimeSeries;

        pixelTimeSeries = nan(length(cadenceIndicators), 1);
        pixelTimeSeries(cadenceIndicators) = bgConstFluxEstimates(iAperturePixel, :);
        pixelTimeSeries(gapIndicators) = NaN;
        aperturePixelArray(pdsIndex).bgConstFluxEstimates = pixelTimeSeries;
    end
end


%************************************************************************** 
% Evaluate the aperture model components of interest. Namely the estimated
% flux for the target star, the estimated flux from known background stars,
% and the constant offset.
%************************************************************************** 
function [targetFluxEstimates, bgStellarFluxEstimates, bgConstFluxEstimates] ...
        = evaluate_model_components(apertureModelObject, targetId)
        
    contributingKeplerIds = [apertureModelObject.contributingStars.keplerId];
    
    targetCoefIndex       = find(contributingKeplerIds == targetId);
    nonTargetCoefIndices  = find(contributingKeplerIds ~= targetId);
    
    nCoefs  = 1 + apertureModelObject.get_num_contributing_stars();
    bgIndex = nCoefs; % Always the last coefficient.
    
    % Create indicator arrays for the three components.
    targetCoefIndicators                             = false(nCoefs, 1);
    targetCoefIndicators(targetCoefIndex)            = true;
    nonTargetCoefIndicators                          = false(nCoefs, 1);
    nonTargetCoefIndicators(nonTargetCoefIndices)    = true;
    bgCoefIndicators                                 = false(nCoefs, 1);
    bgCoefIndicators(bgIndex)                        = true;
    
    allCoefs = apertureModelObject.coefficients;

    % Evaluate the model for the target in isolation.  
    apertureModelObject.coefficients(:, ~targetCoefIndicators) = 0;
    targetFluxEstimates = apertureModelObject.evaluate();
    apertureModelObject.coefficients = allCoefs; % Restore coefficients
    
    % Evaluate the model for background stars.
    apertureModelObject.coefficients(:, ~nonTargetCoefIndicators) = 0;
    bgStellarFluxEstimates = apertureModelObject.evaluate();
    apertureModelObject.coefficients = allCoefs; % Restore coefficients
 
    % Evaluate the constant offset.
    apertureModelObject.coefficients(:, ~bgCoefIndicators) = 0;
    bgConstFluxEstimates = apertureModelObject.evaluate();

    % Restore coefficients
    apertureModelObject.coefficients = allCoefs; 
end


%************************************************************************** 
function contributingStarStruct = construct_contributing_star_struct( ...
    apertureModelObject)

    contributingStarStruct = apertureModelObject.contributingStars;
    fieldsToRemove = setxor( {'keplerId',    'keplerMag', ...
                              'raDegrees',   'decDegrees', ...
                              'centroidRow', 'centroidCol'}, ...
                              fieldnames(contributingStarStruct));
    contributingStarStruct = rmfield( contributingStarStruct, fieldsToRemove );    

    % Add fields for updated mag, RA, and dec.
    cellArray = {contributingStarStruct(:).keplerMag};
    [contributingStarStruct(:).updatedMag] = cellArray{:};
    
    cellArray = {contributingStarStruct(:).raDegrees};
    [contributingStarStruct(:).updatedRa]  = cellArray{:};
    
    cellArray = {contributingStarStruct(:).decDegrees};
    [contributingStarStruct(:).updatedDec] = cellArray{:};

    % Add estimates of total flux for each star.
    cellArray = num2cell(apertureModelObject.coefficients(:, 1:end-1), 1);
    [contributingStarStruct(:).totalFlux] = deal(cellArray{:});
end


%************************************************************************** 
% A note about magnitude calculations:
% -----------------------------------
% We use a reference magnitude m0=12. The corresponding flux f0=214100
% e-/sec (total flux from the star) is stored in fcConstants fields of
% the PA input structure. The functions mag2b() and b2mag() capture the
% following relationships:
%
%     f/f0 = mag2b(m-m0)
%     m-m0 = b2mag(f/f0)
%
% Note that in PA pixel flux time series have units of e-/cadence.
%************************************************************************** 
function contributingStarStruct = update_magnitudes( ...
    contributingStarStruct, apertureModelObject, cadenceDurationInMinutes)
        
    % Compute median flux values in e-/sec for all contributing stars. We
    % use median values for robustness. Note that pixel flux values are in
    % e-/cadence.
    cadencesPerSecond = 1 / (cadenceDurationInMinutes * 60);
    allCoefs          = apertureModelObject.coefficients;
    medianFluxArray   = cadencesPerSecond * median( allCoefs(:, 1:end-1), 1); 
    
    % Compute magnitudes.
    m0 = 12; 
    f0 = apertureModelObject.twelfthMagFlux;
    fluxRatioArray = medianFluxArray / f0;
    newKeplerMagArray = b2mag(fluxRatioArray) + m0;
    
    % Update magnitudes.
    cellArray = num2cell(newKeplerMagArray);
    [contributingStarStruct(:).updatedMag] = cellArray{:};
end

%********************************** EOF ***********************************

