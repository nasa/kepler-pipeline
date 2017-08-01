function [paDataObject, paResultsStruct] = ...
compute_target_centroids(paDataObject, paResultsStruct, centroidType, ...
targetList)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [paDataObject, paResultsStruct] = ...
% compute_target_centroids(paDataObject, paResultsStruct, centroidType, ...
% targetList)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Compute row and column centroid time series for each stellar target. Be
% careful when dealing with cadence gaps. Target list is optional,
% containing indices of targets to be processed. If target list is not
% supplied then all targets are processed. Compute 'flux-weighted'
% centroids for all specified targets. If 'best' centroid type is specified
% then also compute PRF-based centroids for specified targets. Seeds are
% obtained from motion polynomials for each target and cadence if motion
% polynomials are available. The motion polynomials are interpolated if
% necessary to cover gapped long cadences or all short cadences.
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


% Set constants.
RA_HOURS_TO_DEGREES = 360 / 24;
CENTROID_TOLERANCE = 1e-10;
emptyValue = -1;
MAX_POU_PIXELS = 250;               % maximum pixels in target for full pou

% Get state file name.
paFileStruct = paDataObject.paFileStruct;
paStateFileName = paFileStruct.paStateFileName;
paInputUncertaintiesFileName = paFileStruct.paInputUncertaintiesFileName;
calPouFileRoot = paDataObject.paFileStruct.calPouFileRoot;

% Are we processing K2 data?
processingK2Data = paDataObject.cadenceTimes.startTimestamps(1) > ...
                   paDataObject.fcConstants.KEPLER_END_OF_MISSION_MJD;
               
% Get fields from input object and results structures.
cadenceType = paDataObject.cadenceType;

paConfigurationStruct = paDataObject.paConfigurationStruct;
discretePrfCentroidingEnabled = paConfigurationStruct.discretePrfCentroidingEnabled;
discretePrfOversampleFactor = paConfigurationStruct.discretePrfOversampleFactor;
oapEnabled = paConfigurationStruct.oapEnabled;
debugLevel = paConfigurationStruct.debugLevel;

pouConfigurationStruct = paDataObject.pouConfigurationStruct;
pouEnabled = pouConfigurationStruct.pouEnabled;
compressionEnabled = pouConfigurationStruct.compressionEnabled;
pixelChunkSize = pouConfigurationStruct.pixelChunkSize;
cadenceChunkSize = pouConfigurationStruct.cadenceChunkSize;
interpDecimation = pouConfigurationStruct.interpDecimation;
interpMethod = pouConfigurationStruct.interpMethod;

backgroundPolyStruct = paDataObject.backgroundPolyStruct;
motionPolyStruct = paDataObject.motionPolyStruct;

cadenceTimes = paDataObject.cadenceTimes;
timestamps = cadenceTimes.midTimestamps;
cadenceGapIndicators = cadenceTimes.gapIndicators;
cadenceNumbers = cadenceTimes.cadenceNumbers;
nCadences = length(timestamps);

fcConstants = paDataObject.fcConstants;

% Set long cadence flag.
if strcmpi(cadenceType, 'long')
    processLongCadence = true;
elseif strcmpi(cadenceType, 'short')
    processLongCadence = false;
end

% Instantiate a prf object. Blob must first be converted to struct. Single
% prf model per mod out is a special case. Specify discrete PRF centroiding
% if enabled.
if strcmpi(centroidType, 'best')
    
    [prfStruct] = blob_to_struct(paDataObject.prfModel.blob);
    if isfield(prfStruct, 'c');   % it's a single prf model
        prfModel.polyStruct = prfStruct;
    else
        prfModel = prfStruct;
    end

    if discretePrfCentroidingEnabled
        discretePrfSpecification.oversample = discretePrfOversampleFactor;
        [prfObject] = prfCollectionClass(prfModel, fcConstants, discretePrfSpecification);
    else
        [prfObject] = prfCollectionClass(prfModel, fcConstants);
    end % if / else

    clear prfStruct prfModel

end % if

% Create the POU struct.
pouConfigStruct.inputUncertaintiesFileName = paInputUncertaintiesFileName;
pouConfigStruct.calPouFileRoot = calPouFileRoot;
pouConfigStruct.cadenceNumbers = cadenceNumbers;
pouConfigStruct.pouEnabled = pouEnabled;
pouConfigStruct.pouDecimationEnabled = true;
pouConfigStruct.pouCompressionEnabled = compressionEnabled;
pouConfigStruct.pouPixelChunkSize = pixelChunkSize;
pouConfigStruct.pouCadenceChunkSize = cadenceChunkSize;
pouConfigStruct.pouInterpDecimation = interpDecimation;
pouConfigStruct.pouInterpMethod = interpMethod;
pouConfigStruct.debugLevel = debugLevel;

% Interpolate the motion polynomial structure if necessary. Row and column
% poly status are identical. Save the motion polynomial structure to the
% state file for use in later invocations. At least two valid polynomials
% are required for interpolation. Only one valid polynomial is required if
% there is only one cadence.
if ~isempty(motionPolyStruct)
    
    motionPolyGapIndicators = ~logical([motionPolyStruct.rowPolyStatus]');
    nPolynomials = length(motionPolyGapIndicators);
    
    if (sum(~motionPolyGapIndicators) < 2 && nPolynomials > 1) || ...
            (sum(~motionPolyGapIndicators) == 0  && nPolynomials == 1)
        motionPolyStruct = [];
    elseif any(motionPolyGapIndicators) || length(motionPolyStruct) < nCadences
        [motionPolyStruct] = ...
            interpolate_motion_polynomials(motionPolyStruct, ...
            cadenceTimes, processLongCadence);
    end % if / elseif
    
    % Save the updated motion polynomial structure for subsequent
    % invocations.
    paDataObject.motionPolyStruct = motionPolyStruct;
    save(paStateFileName, 'motionPolyStruct', '-append');

end % if

% Initialize pouStructArray as empty. This structure will be updated with
% CAL pou blob information on the first call to
% retrieve_cal_pixel_covariance which depends only on cadence (e.g. it's
% also the same for all targets).
if pouEnabled
    pouStructArray = [];
end


% Loop through the targets and call the centroiding function. That function
% loops over the targets anyway, so there is no need to call it only once.
% If an optional target list is supplied, then process those targets only.
if ~exist('targetList', 'var')
    nTargets = length(paDataObject.targetStarDataStruct);
    targetList = 1 : nTargets;
end

for iTarget = targetList
    
    % Set up the data structure required by
    % compute_starDataStruct_centroid. Ensure that gapped values and
    % uncertainties are set to 0.
    targetDataStruct = paDataObject.targetStarDataStruct(iTarget);
    targetResultsStruct = paResultsStruct.targetStarResultsStruct(iTarget);
    
    starDataStruct.row = [targetDataStruct.pixelDataStruct.ccdRow]';
    starDataStruct.column = [targetDataStruct.pixelDataStruct.ccdColumn]';
    
    starValues = [targetDataStruct.pixelDataStruct.values]';
    starUncertainties = [targetDataStruct.pixelDataStruct.uncertainties]';
    gapArray = [targetDataStruct.pixelDataStruct.gapIndicators]';
    starValues(gapArray) = 0;
    starUncertainties(gapArray) = 0;
    
    % Determine the centroiding apertures based on the centroid type. 
    % In the flux weighted case, add a ring around the pixels in the
    % optimal aperture. Otherwise, use all available pixels. First, trim
    % any pixels that are not on the photometric region of the CCD.
    inOptimalAperture = ...
        [targetDataStruct.pixelDataStruct.inOptimalAperture]';
    
    [inFwCentroidAperture] = add_ring_to_aperture( ...
        starDataStruct.row, starDataStruct.column, inOptimalAperture);
    [inFwCentroidAperture] = ...
        trim_non_photometric_pixels_from_aperture( ...
        starDataStruct.row, starDataStruct.column, ...
        inFwCentroidAperture, fcConstants);
    
    if any(inOptimalAperture)
        inPrfCentroidAperture = true(size(inOptimalAperture));
    else
        inPrfCentroidAperture = false(size(inOptimalAperture));
    end
    [inPrfCentroidAperture] = ...
        trim_non_photometric_pixels_from_aperture( ...
        starDataStruct.row, starDataStruct.column, ...
        inPrfCentroidAperture, fcConstants);
    
    % Set the centroid aperture indicators for the FITS export. If
    % PRF-based centroiding is not being performed for a given target then
    % the PRF centroid aperture indicators should be set to false for all
    % pixels.
    pixelApertureStruct = targetResultsStruct.pixelApertureStruct;
    nPixels = length(pixelApertureStruct);
    
    apertureIndicatorsCellArray = num2cell(inFwCentroidAperture);
    [pixelApertureStruct(1 : nPixels).inFluxWeightedCentroidAperture] = ...
        apertureIndicatorsCellArray{:};
    
    if strcmpi(centroidType, 'best')
        apertureIndicatorsCellArray = num2cell(inPrfCentroidAperture);
    else
        apertureIndicatorsCellArray = ...
            num2cell(false(size(inPrfCentroidAperture)));
    end % if / else
    [pixelApertureStruct(1 : nPixels).inPrfCentroidAperture] = ...
        apertureIndicatorsCellArray{:};
    
    targetResultsStruct.pixelApertureStruct = pixelApertureStruct;
    
    % Define centroid aperture bounding boxes for validation of row/column
    % centroid coordinates. Note that centroid library extends centroid
    % aperture to full aperture if there are fewer than nine pixels in
    % centroid aperture.
    minFwApertureRow = min(starDataStruct.row(inFwCentroidAperture));
    maxFwApertureRow = max(starDataStruct.row(inFwCentroidAperture));
    minFwApertureColumn = min(starDataStruct.column(inFwCentroidAperture));
    maxFwApertureColumn = max(starDataStruct.column(inFwCentroidAperture));
    
    minPrfApertureRow = min(starDataStruct.row(inPrfCentroidAperture));
    maxPrfApertureRow = max(starDataStruct.row(inPrfCentroidAperture));
    minPrfApertureColumn = min(starDataStruct.column(inPrfCentroidAperture));
    maxPrfApertureColumn = max(starDataStruct.column(inPrfCentroidAperture));
    
    % Initialize the centroid time series structures.
    fwCentroidRowTimeSeries.values = ...
        1 + repmat(emptyValue, (size(cadenceGapIndicators)));
    fwCentroidRowTimeSeries.uncertainties = ...
        repmat(emptyValue, (size(cadenceGapIndicators)));
    fwCentroidRowTimeSeries.gapIndicators = ...
        true(size(cadenceGapIndicators));
    
    fwCentroidColumnTimeSeries.values = ...
        1 + repmat(emptyValue, (size(cadenceGapIndicators)));
    fwCentroidColumnTimeSeries.uncertainties = ...
        repmat(emptyValue, (size(cadenceGapIndicators)));
    fwCentroidColumnTimeSeries.gapIndicators = ...
        true(size(cadenceGapIndicators));
    
    prfCentroidRowTimeSeries.values = ...
        1 + repmat(emptyValue, (size(cadenceGapIndicators)));
    prfCentroidRowTimeSeries.uncertainties = ...
        repmat(emptyValue, (size(cadenceGapIndicators)));
    prfCentroidRowTimeSeries.gapIndicators = ...
        true(size(cadenceGapIndicators));
    
    prfCentroidColumnTimeSeries.values = ...
        1 + repmat(emptyValue, (size(cadenceGapIndicators)));
    prfCentroidColumnTimeSeries.uncertainties = ...
        repmat(emptyValue, (size(cadenceGapIndicators)));
    prfCentroidColumnTimeSeries.gapIndicators = ...
        true(size(cadenceGapIndicators));
    
    
    
    % Get the decimated cadences for which the target covariances will be
    % computed without interpolation if POU is enabled. This variable is
    % used as a scratchpad so it needs to be reinitialized for each target.
    % Also require nPixels < MAX_POU_PIXELS to execute full pou for target.
    % Initialize chunkedCadenceList.
    pouEnabledForTarget = false;
    if pouEnabled
        if nPixels > MAX_POU_PIXELS  
            pouEnabledForTarget = false;            
            disp(['Target ',num2str(targetDataStruct.keplerId),' pixels = ',num2str(nPixels),...
                ' > MAX_POU_PIXELS(',num2str(MAX_POU_PIXELS),'). Disabling full pou for target.']);            
        else
            pouEnabledForTarget = true;
            
            % Initialize the target pixel and flux uncertainties for POU.
            targetPixelUncertainties = zeros(size(gapArray'));
            targetPixelGaps = true(size(gapArray'));
            fluxUncertainties = zeros(size(cadenceGapIndicators));
            fluxGaps = true(size(cadenceGapIndicators));
    
            % Initialize temporary centroid time series for POU
            fwCentroidRowTemp = fwCentroidRowTimeSeries;
            fwCentroidColumnTemp = fwCentroidColumnTimeSeries;
            prfCentroidRowTemp = prfCentroidRowTimeSeries;
            prfCentroidColumnTemp = prfCentroidColumnTimeSeries;             
            
            % build decimated cadence list            
            decimatedCadenceList = downsample(cadenceNumbers, interpDecimation);
            workingDecimatedCadenceList = decimatedCadenceList;
            chunkedCadenceList = [];                        
        end
    end
    
    
    
    
    % Compute the centroid time series for all targets using valid cadences
    % only. Do the centroiding one cadence at a time to prevent out of
    % memory problems.
    for iCadence = 1 : nCadences
        
        cadence = cadenceNumbers(iCadence);
        if cadenceGapIndicators(iCadence)
            continue;
        end        
        
        starDataStruct.values = starValues( : , iCadence);
        starDataStruct.uncertainties = starUncertainties( : , iCadence);
        starDataStruct.gapIndicators = gapArray( : , iCadence);
        
        % Set the seeds for the target centroids if the motion polynomial
        % structure is not empty.
        starDataStruct.seedRow = [];
        starDataStruct.seedColumn = [];
            
        if ~isempty(motionPolyStruct)

            targetRa = targetDataStruct.raHours * RA_HOURS_TO_DEGREES;
            targetDec = targetDataStruct.decDegrees;

            if ~isnan(targetRa) && ~isnan(targetDec)
                [starDataStruct.seedRow] = weighted_polyval2d(targetRa, ...
                    targetDec, motionPolyStruct(iCadence).rowPoly);
                [starDataStruct.seedColumn] = weighted_polyval2d(targetRa, ...
                    targetDec, motionPolyStruct(iCadence).colPoly);
            end % if
            
        end % if
        
        % Get full target covariance and propagate uncertainties if POU is
        % enabled. Otherwise simplified uncertainty propagation will be
        % performed based on assumptions of independence.
        
        % --------------- COMPUTE POU ENABLED VERSION OF CENTROIDS VVVVVVV
        
        % only perform full pou on decimated cadences
        if pouEnabledForTarget && ismember(cadence, decimatedCadenceList)
            
            % Retrieve a chunk of decimated covariances if necessary.
            if isempty(chunkedCadenceList) || ...
                    (cadence > chunkedCadenceList(end) && ...
                    ~isempty(workingDecimatedCadenceList))
                
                nRemain = length(workingDecimatedCadenceList);
                chunkSize = min(cadenceChunkSize, nRemain);
                chunkedCadenceList = workingDecimatedCadenceList(1 : chunkSize);
                if chunkSize == nRemain
                    workingDecimatedCadenceList = [];
                else
                    workingDecimatedCadenceList(1 : chunkSize - 1) = [];
                end
                
                clear Cv
                [Cv, covarianceGapIndicators, pouStructArray] = ...
                    retrieve_cal_pixel_covariance( ...
                    starDataStruct.row, starDataStruct.column, ...
                    chunkedCadenceList, pouConfigStruct, pouStructArray);
                
                isValidCovariance = ~all(covarianceGapIndicators, 2);
                nValidCovariances = sum(isValidCovariance);
                Cv = Cv(isValidCovariance, : , : );
                validCadenceList = chunkedCadenceList(isValidCovariance);
                
            end % if
            
            % Interpolate the covariance matrix for the given cadence if
            % there are a sufficient number of valid matrices to do that.
            % If there is only one cadence then interpolation is not
            % necessary. Create a diagonal covariance matrix if that is the
            % best that can be done in a reasonable amount of time.
            if (nValidCovariances == 1 && nCadences ~= 1) || ...
                    nValidCovariances == 0
                
                CtargetPixBackRemoved = ...
                    diag(starDataStruct.uncertainties .^ 2);
                
            else % there is just one cadence or interpolation is possible
                
                if nValidCovariances > 1
                    CtargetPix = squeeze(interp1(validCadenceList, Cv, cadence, interpMethod, 'extrap'));
                else % nCadences == 1
                    CtargetPix = squeeze(Cv);
                end
                
                % this is correct for full pou on decimated cadences only
                % since the background polynomial was fit using the full
                % pixel covariance on those cadences
                backgroundPoly = backgroundPolyStruct(iCadence).backgroundPoly;
                [z, zu, Aback] = weighted_polyval2d(starDataStruct.row, ...
                    starDataStruct.column, backgroundPoly);                                                                             %#ok<ASGLU>
                CtargetPixBackRemoved = CtargetPix + ...
                    Aback * backgroundPoly.covariance * Aback';
                
            end % if /else
            
            % Explicitly set the rows and columns to 0 if the associated
            % pixels are gapped.
            CtargetPixBackRemoved(starDataStruct.gapIndicators, : ) = 0;
            CtargetPixBackRemoved( : , starDataStruct.gapIndicators) = 0;
                
            % Make a temp copy of starDataStruct for use with pou enabled
            % centroids
            starDataStructTemp = starDataStruct;
            
            % Duplicate the single cadence covariance matrix so that the
            % library function to compute the star centroid is not fooled
            % by the dimension of the input uncertainties array.
            starDataStructTemp.uncertainties = [];
            starDataStructTemp.uncertainties( : , : , 1) = CtargetPixBackRemoved;
            starDataStructTemp.uncertainties( : , : , 2) = CtargetPixBackRemoved;
            
            % Save the uncertainties for the background removed target
            % pixels. 
            targetPixelUncertainties(iCadence, : ) = sqrt(diag(CtargetPixBackRemoved)');
            targetPixelGaps(iCadence, : ) = false(size(targetPixelUncertainties(iCadence, : )));
            
            % Compute the proper uncertainties for the SAP flux time series
            % if OAP is disabled. Since this is in the full pou clause it
            % will be done on only the decimated cadences.
            if ~oapEnabled
                fluxUncertainties(iCadence) = ...
                    sqrt(sum(sum(CtargetPixBackRemoved(inOptimalAperture, ...
                    inOptimalAperture))));
                fluxGaps(iCadence) = false;
            end % if
            
        	% compute full pou centroids here and store in temp centroidRow
        	% and centroidColumn structs
            
            % Compute the flux-weighted centroid for the given target and
            % cadence.
            starDataStructTemp.inOptimalAperture = inFwCentroidAperture;
            
            if any(inFwCentroidAperture)
                [centroidRow, centroidColumn, centroidStatus, centroidCovariance] = ...
                    compute_starDataStruct_centroid(starDataStructTemp, [], ...
                    timestamps(iCadence), 'flux-weighted');
            else
                centroidStatus = 1;
            end
            
            % Check that flux-weighted centroid is valid. It can't be valid
            % if it does not fall within the bounding box for the
            % centroiding aperture.
            if 0 == centroidStatus && ...
                    (centroidRow + CENTROID_TOLERANCE < minFwApertureRow || ...
                    centroidRow - CENTROID_TOLERANCE > maxFwApertureRow || ...
                    centroidColumn + CENTROID_TOLERANCE < minFwApertureColumn || ...
                    centroidColumn - CENTROID_TOLERANCE > maxFwApertureColumn)
                centroidStatus = 1;
            end % if
            
            % Save the results for the given cadence.
            if ~centroidStatus
                
                fwCentroidRowTemp.values(iCadence) = centroidRow;
                fwCentroidRowTemp.uncertainties(iCadence) = ...
                    sqrt(centroidCovariance(1, 1, 1));
                fwCentroidRowTemp.gapIndicators(iCadence) = false;
                
                fwCentroidColumnTemp.values(iCadence) = centroidColumn;
                fwCentroidColumnTemp.uncertainties(iCadence) = ...
                    sqrt(centroidCovariance(1, 2, 2));
                fwCentroidColumnTemp.gapIndicators(iCadence) = false;
                
            end % if
            
            % Compute the PRF-based centroids for the given target and
            % cadence if the 'best' centroid type was specified.
            if strcmpi(centroidType, 'best')
                
                starDataStructTemp.inOptimalAperture = inPrfCentroidAperture;
                
                % If a seed for this target's centroid on this cadence has
                % not been set (ususally because motion polynomials are
                % uavailable) then set it here in one of two ways:
                % (1) Kepler prime mission : Use flux-weighted centroids as
                %     seeds.
                % (2) K2 : Estimate the centroid positions from the pointing
                %     model using raDec2Pix.
                if (isempty(starDataStructTemp.seedRow)    && ~centroidStatus) || ...
                   (isempty(starDataStructTemp.seedColumn) && ~centroidStatus)

                    if processingK2Data

                        starDataStructTemp = ...
                            compute_centroid_seed_from_nominal_pointing( ...
                                starDataStructTemp, ...
                                targetDataStruct.raHours * RA_HOURS_TO_DEGREES, ...
                                targetDataStruct.decDegrees, ...
                                timestamps(iCadence), ...
                                paDataObject.raDec2PixModel);
                        
                        if ~seed_point_is_inside_mask(starDataStructTemp)
                            starDataStructTemp.seedRow    = centroidRow;
                            starDataStructTemp.seedColumn = centroidColumn;
                        end
                    else % Processing Kepler prime data.
                        starDataStructTemp.seedRow    = centroidRow;
                        starDataStructTemp.seedColumn = centroidColumn;
                    end
                end
                
                % Compute the PRF-based centroid.
                if any(inPrfCentroidAperture)
                    [centroidRow, centroidColumn, centroidStatus, centroidCovariance] = ...
                        compute_starDataStruct_centroid(starDataStructTemp, prfObject, ...
                        timestamps(iCadence), 'best');
                else
                    centroidStatus = 1;
                end
                
                % Check that PRF-based centroid is valid. It can't be valid
                % if it does not fall within the bounding box for the
                % centroiding aperture.
                if 0 == centroidStatus && ...
                        (centroidRow + CENTROID_TOLERANCE < minPrfApertureRow || ...
                        centroidRow - CENTROID_TOLERANCE > maxPrfApertureRow || ...
                        centroidColumn + CENTROID_TOLERANCE < minPrfApertureColumn || ...
                        centroidColumn - CENTROID_TOLERANCE > maxPrfApertureColumn)
                    centroidStatus = 1;
                end % if
                
                % Save the results for the given cadence.
                if ~centroidStatus
                    
                    prfCentroidRowTemp.values(iCadence) = centroidRow;
                    prfCentroidRowTemp.uncertainties(iCadence) = ...
                        sqrt(centroidCovariance(1, 1, 1));
                    prfCentroidRowTemp.gapIndicators(iCadence) = false;
                    
                    prfCentroidColumnTemp.values(iCadence) = centroidColumn;
                    prfCentroidColumnTemp.uncertainties(iCadence) = ...
                        sqrt(centroidCovariance(1, 2, 2));
                    prfCentroidColumnTemp.gapIndicators(iCadence) = false;
                    
                end % if
                
            end % if strcmpi
            
        end % if pouEnabledForTarget
                
        % --------------- COMPUTE POU ENABLED VERSION OF CENTROIDS ^^^^^^^    
        
                
        % --------------- COMPUTE MINIMAL POU VERSION OF CENTROIDS VVVVVVV
        % Compute the flux-weighted centroid for the given target and
        % cadence.
        starDataStruct.inOptimalAperture = inFwCentroidAperture;
        
        if any(inFwCentroidAperture)
            [centroidRow, centroidColumn, centroidStatus, centroidCovariance] = ...
                compute_starDataStruct_centroid(starDataStruct, [], ...
                timestamps(iCadence), 'flux-weighted');
        else
            centroidStatus = 1;
        end

        % Check that flux-weighted centroid is valid. It can't be valid if
        % it does not fall within the bounding box for the centroiding
        % aperture.
        if 0 == centroidStatus && ...
                (centroidRow + CENTROID_TOLERANCE < minFwApertureRow || ...
                centroidRow - CENTROID_TOLERANCE > maxFwApertureRow || ...
                centroidColumn + CENTROID_TOLERANCE < minFwApertureColumn || ...
                centroidColumn - CENTROID_TOLERANCE > maxFwApertureColumn)
            centroidStatus = 1;
        end % if
        
        % Save the results for the given cadence.
        if ~centroidStatus
            
            fwCentroidRowTimeSeries.values(iCadence) = centroidRow;
            fwCentroidRowTimeSeries.uncertainties(iCadence) = ...
                sqrt(centroidCovariance(1, 1, 1));
            fwCentroidRowTimeSeries.gapIndicators(iCadence) = false;

            fwCentroidColumnTimeSeries.values(iCadence) = centroidColumn;
            fwCentroidColumnTimeSeries.uncertainties(iCadence) = ...
                sqrt(centroidCovariance(1, 2, 2));
            fwCentroidColumnTimeSeries.gapIndicators(iCadence) = false;
        
        end % if
        
        % Compute the PRF-based centroids for the given target and cadence
        % if the 'best' centroid type was specified.
        if strcmpi(centroidType, 'best')
            
            starDataStruct.inOptimalAperture = inPrfCentroidAperture;
            
            % If a seed for this target's centroid on this cadence has not
            % been set (ususally because motion polynomials are uavailable)
            % then set it here in one of two ways:
            % (1) Kepler prime mission : Use flux-weighted centroids as
            %     seeds.
            % (2) K2 : Estimate the centroid positions from the pointing
            %     model using raDec2Pix.
            if (isempty(starDataStruct.seedRow)    && ~centroidStatus) || ...
               (isempty(starDataStruct.seedColumn) && ~centroidStatus)
           
                if processingK2Data
                    
                    starDataStruct = ...
                        compute_centroid_seed_from_nominal_pointing( ...
                            starDataStruct, ...
                            targetDataStruct.raHours * RA_HOURS_TO_DEGREES, ...
                            targetDataStruct.decDegrees, ...
                            timestamps(iCadence), ...
                            paDataObject.raDec2PixModel);
                        
                        if ~seed_point_is_inside_mask(starDataStruct)
                            starDataStruct.seedRow    = centroidRow;
                            starDataStruct.seedColumn = centroidColumn;
                        end
                else % Processing Kepler prime data.
                    starDataStruct.seedRow    = centroidRow;
                    starDataStruct.seedColumn = centroidColumn;
                end
            end
                        
            % Compute the PRF-based centroid.
            if any(inPrfCentroidAperture)
                [centroidRow, centroidColumn, centroidStatus, centroidCovariance] = ...
                    compute_starDataStruct_centroid(starDataStruct, prfObject, ...
                    timestamps(iCadence), 'best');
            else
                centroidStatus = 1;
            end

            % Check that PRF-based centroid is valid. It can't be valid if
            % it does not fall within the bounding box for the centroiding
            % aperture.
            if 0 == centroidStatus && ...
                    (centroidRow + CENTROID_TOLERANCE < minPrfApertureRow || ...
                    centroidRow - CENTROID_TOLERANCE > maxPrfApertureRow || ...
                    centroidColumn + CENTROID_TOLERANCE < minPrfApertureColumn || ...
                    centroidColumn - CENTROID_TOLERANCE > maxPrfApertureColumn)
                centroidStatus = 1;
            end % if

            % Save the results for the given cadence.
            if ~centroidStatus

                prfCentroidRowTimeSeries.values(iCadence) = centroidRow;
                prfCentroidRowTimeSeries.uncertainties(iCadence) = ...
                    sqrt(centroidCovariance(1, 1, 1));
                prfCentroidRowTimeSeries.gapIndicators(iCadence) = false;

                prfCentroidColumnTimeSeries.values(iCadence) = centroidColumn;
                prfCentroidColumnTimeSeries.uncertainties(iCadence) = ...
                    sqrt(centroidCovariance(1, 2, 2));
                prfCentroidColumnTimeSeries.gapIndicators(iCadence) = false;

            end % if
            
        end % if strcmpi
        % --------------- COMPUTE MINIMAL POU VERSION OF CENTROIDS ^^^^^^^
        
    end % for iCadence
    
    % If POU is enabled then correct all of the uncertainties for the
    % background removed target pixels. These could not be properly
    % computed initially without the covariance matrix for the given target
    % pixels for each cadence. Also correct the SAP flux uncertainties if
    % OAP is not enabled. These also require the target pixel covariance
    % matrix.
    if pouEnabledForTarget
                
        % update target pixel uncertainties
        
        % calculate median delta from minimal pou on decimated cadences 
        minimalPouUncertainties = [targetDataStruct.pixelDataStruct.uncertainties];
        minimalPouGaps = [targetDataStruct.pixelDataStruct.gapIndicators];
        minimalPouUncertainties(minimalPouGaps) = nan;
        targetPixelUncertainties(targetPixelGaps) = nan;
        delta = nanmedian(targetPixelUncertainties - minimalPouUncertainties);
        delta(isnan(delta)) = 0;
        
        % update uncertainties as minimal pou + delta
        delta = repmat(delta,size(minimalPouUncertainties,1),1);        
        targetPixelUncertainties = minimalPouUncertainties + delta;
        targetPixelUncertainties(isnan(targetPixelUncertainties)) = 0;
        
        % write to data object
        nPixels = size(targetPixelUncertainties, 2);
        targetPixelUncertaintiesCellArray = ...
            num2cell(targetPixelUncertainties, 1);
        [targetDataStruct.pixelDataStruct(1 : nPixels).uncertainties] = ...
            targetPixelUncertaintiesCellArray{ : };
        paDataObject.targetStarDataStruct(iTarget) = targetDataStruct;
        
        % update target flux uncertainties
        if ~oapEnabled
            
            fluxTimeSeries = targetResultsStruct.fluxTimeSeries;
            fluxGapIndicators = fluxTimeSeries.gapIndicators;
            
            % calculate median delta from minimal pou on decimated cadences 
            minimalPouUncertainties = fluxTimeSeries.uncertainties;
            minimalPouUncertainties(fluxGapIndicators) = nan;
            fluxUncertainties(fluxGaps) = nan;
            delta = nanmedian(fluxUncertainties - minimalPouUncertainties);
            if isnan(delta)
                delta = 0;
            end
            
            % update uncertainties as minimal pou + delta
            fluxUncertainties = minimalPouUncertainties + delta;
            fluxUncertainties(isnan(fluxUncertainties)) = 0;
            
            % write to data object
            fluxTimeSeries.uncertainties(~fluxGapIndicators) = ...
                fluxUncertainties(~fluxGapIndicators);
            targetResultsStruct.fluxTimeSeries = fluxTimeSeries;
        end % if
        
        % update centroid uncertainties
        
        % fwRow
        % calculate median delta from minimal pou on decimated cadences 
        minimalPouUncertainties = fwCentroidRowTimeSeries.uncertainties;
        minimalPouGaps = fwCentroidRowTimeSeries.gapIndicators;
        fullPouUncertainties = fwCentroidRowTemp.uncertainties;
        fullPouGaps = fwCentroidRowTemp.gapIndicators;
        minimalPouUncertainties(minimalPouGaps) = nan;
        fullPouUncertainties(fullPouGaps) = nan;
        delta = nanmedian(fullPouUncertainties - minimalPouUncertainties);
        if isnan(delta)
            delta = 0;
        end        
        % update uncertainties as minimal pou + delta
        uncertainties = minimalPouUncertainties + delta;
        uncertainties(isnan(uncertainties)) = 0;        
        % write updated uncertainties to data struct
        fwCentroidRowTimeSeries.uncertainties = uncertainties;        
        
        % fwColumn
        % calculate median delta from minimal pou on decimated cadences 
        minimalPouUncertainties = fwCentroidColumnTimeSeries.uncertainties;
        minimalPouGaps = fwCentroidColumnTimeSeries.gapIndicators;
        fullPouUncertainties = fwCentroidColumnTemp.uncertainties;
        fullPouGaps = fwCentroidColumnTemp.gapIndicators;
        minimalPouUncertainties(minimalPouGaps) = nan;
        fullPouUncertainties(fullPouGaps) = nan;
        delta = nanmedian(fullPouUncertainties - minimalPouUncertainties);
        if isnan(delta)
            delta = 0;
        end        
        % update uncertainties as minimal pou + delta
        uncertainties = minimalPouUncertainties + delta;
        uncertainties(isnan(uncertainties)) = 0;        
        % write updated uncertainties to data struct
        fwCentroidColumnTimeSeries.uncertainties = uncertainties;  
        
        % prfRow
        % calculate median delta from minimal pou on decimated cadences 
        minimalPouUncertainties = prfCentroidRowTimeSeries.uncertainties;
        minimalPouGaps = prfCentroidRowTimeSeries.gapIndicators;
        fullPouUncertainties = prfCentroidRowTemp.uncertainties;
        fullPouGaps = prfCentroidRowTemp.gapIndicators;
        minimalPouUncertainties(minimalPouGaps) = nan;
        fullPouUncertainties(fullPouGaps) = nan;
        delta = nanmedian(fullPouUncertainties - minimalPouUncertainties);
        if isnan(delta)
            delta = 0;
        end        
        % update uncertainties as minimal pou + delta
        uncertainties = minimalPouUncertainties + delta;
        uncertainties(isnan(uncertainties)) = 0;        
        % write updated uncertainties to data struct
        prfCentroidRowTimeSeries.uncertainties = uncertainties;        
        
        % prfColumn
        % calculate median delta from minimal pou on decimated cadences 
        minimalPouUncertainties = prfCentroidColumnTimeSeries.uncertainties;
        minimalPouGaps = prfCentroidColumnTimeSeries.gapIndicators;
        fullPouUncertainties = prfCentroidColumnTemp.uncertainties;
        fullPouGaps = prfCentroidColumnTemp.gapIndicators;
        minimalPouUncertainties(minimalPouGaps) = nan;
        fullPouUncertainties(fullPouGaps) = nan;
        delta = nanmedian(fullPouUncertainties - minimalPouUncertainties);
        if isnan(delta)
            delta = 0;
        end        
        % update uncertainties as minimal pou + delta
        uncertainties = minimalPouUncertainties + delta;
        uncertainties(isnan(uncertainties)) = 0;        
        % write updated uncertainties to data struct
        prfCentroidColumnTimeSeries.uncertainties = uncertainties;        
        
    end % if
    
    % Update the results structure for the given target.
    targetResultsStruct.fluxWeightedCentroids.rowTimeSeries = ...
        fwCentroidRowTimeSeries;
    targetResultsStruct.fluxWeightedCentroids.columnTimeSeries = ...
        fwCentroidColumnTimeSeries;
    targetResultsStruct.prfCentroids.rowTimeSeries = ...
        prfCentroidRowTimeSeries;
    targetResultsStruct.prfCentroids.columnTimeSeries = ...
        prfCentroidColumnTimeSeries;
    
    paResultsStruct.targetStarResultsStruct(iTarget) = targetResultsStruct;
    
    % Plot the mean flux and the cluster of centroids for each target if
    % the debug flag is greater than zero.
    if debugLevel
        
        close all;
        starValues(gapArray) = 0;
        nValues = sum(~gapArray, 2);
        meanTarget = sum(starValues, 2) ./ nValues;
        isValid = nValues > 0;
        plot3(starDataStruct.column(isValid & inPrfCentroidAperture), ...
            starDataStruct.row(isValid & inPrfCentroidAperture), ...
            meanTarget(isValid & inPrfCentroidAperture), '.b');
        hold on
        plot3(starDataStruct.column(isValid & inFwCentroidAperture), ...
            starDataStruct.row(isValid & inFwCentroidAperture), ...
            meanTarget(isValid & inFwCentroidAperture), '.r');
        fwGapIndicators = fwCentroidRowTimeSeries.gapIndicators;
        plot(fwCentroidColumnTimeSeries.values(~fwGapIndicators), ...
            fwCentroidRowTimeSeries.values(~fwGapIndicators), '.g');
        prfGapIndicators = prfCentroidRowTimeSeries.gapIndicators;
        plot(prfCentroidColumnTimeSeries.values(~prfGapIndicators), ...
            prfCentroidRowTimeSeries.values(~prfGapIndicators), '.m');
        hold off
        title(['[PA] Mean Target Flux and Centroids -- Kepler Id ', num2str(targetDataStruct.keplerId)]);
        xlabel('CCD Column (1-based)');
        ylabel('CCD Row (1-based)');
        zlabel('Flux (e-)');
        pause(1);
        
        meanTarget(~isValid) = 0;
        minRow = min(starDataStruct.row);
        maxRow = max(starDataStruct.row);
        minCol = min(starDataStruct.column);
        maxCol = max(starDataStruct.column);
        nRows = maxRow - minRow + 1;
        nColumns = maxCol - minCol + 1;
        aperturePixelValues = zeros([nRows, nColumns]);
        aperturePixelIndices = sub2ind([nRows, nColumns], ...
            starDataStruct.row - minRow + 1, ...
            starDataStruct.column - minCol + 1);
        aperturePixelValues(aperturePixelIndices) = meanTarget;
        imagesc([minCol; maxCol], [minRow; maxRow], aperturePixelValues);
        set(gca, 'YDir', 'normal');
        colorbar;
        title(['[PA] Mean Target Flux -- Kepler Id ', num2str(targetDataStruct.keplerId)]);
        xlabel('CCD Column (1-based)');
        ylabel('CCD Row (1-based)');
        pause(1)
        
    end %if
    
end % for iTarget

% Return.
end


%************************************************************************** 
% function starDataStruct = compute_centroid_seed_from_nominal_pointing( ...
%     starDataStruct, raDegrees, decDegrees, mjdTimestamp, raDec2PixModel)
%************************************************************************** 
% Use a motion model to map a target's celestial coordinates to an expected
% centroid position.
%
% INPUTS
%     starDataStruct : A struct representing a single target and cadence
%                      and having the following fields:
%                                   row: [nPixels x 1 double]
%                                column: [nPixels x 1 double]
%                                values: [nPixels x 1 double]
%                         uncertainties: [nPixels x 1 double]
%                         gapIndicators: [nPixels x 1 logical]
%                               seedRow: [1x1 double] (or empty)
%                            seedColumn: [1x1 double] (or empty)
%                     inOptimalAperture: [nPixels x 1 logical]
%     raDegrees      :
%     decDegrees     :
%     mjdTimestamp   : A scalar MJD.
%     raDec2PixModel : 
%
% OUTPUTS
%     seedRow        : A scalar (floating point) row position.
%     seedColumn     : A scalar (floating point) column position..
%
% NOTES
%     The outer loop in which this function is called guarantees the 
%     current cadence is not gapped.
%************************************************************************** 
function starDataStruct = compute_centroid_seed_from_nominal_pointing( ...
    starDataStruct, raDegrees, decDegrees, mjdTimestamp, raDec2PixModel)

    raDec2PixObject = raDec2PixClass(raDec2PixModel, 'one-based');

    [~, ~, seedRow, seedColumn] = ra_dec_2_pix_absolute(raDec2PixObject, ...
            raDegrees, ...
            decDegrees, ...
            mjdTimestamp);

    starDataStruct.seedRow    = seedRow;
    starDataStruct.seedColumn = seedColumn;
end

%************************************************************************** 
% function isInside = seed_point_is_inside_mask(starDataStruct)
%************************************************************************** 
% Determine whether the seed point in a starDataStruct is inside the target
% mask.
%
% INPUTS
%     starDataStruct : A struct representing a single target and cadence
%                      and having the following fields:
%                                   row: [nPixels x 1 double]
%                                column: [nPixels x 1 double]
%                                values: [nPixels x 1 double]
%                         uncertainties: [nPixels x 1 double]
%                         gapIndicators: [nPixels x 1 logical]
%                               seedRow: [1x1 double] (or empty)
%                            seedColumn: [1x1 double] (or empty)
%                     inOptimalAperture: [nPixels x 1 logical]
%
% OUTPUTS
%     isInside       : [1x1 logical] 'true' if the seedRow and seedColumn
%                      define a point inside the target mask. 'false'
%                      otherwise. 
% NOTES
%     Assumes row and column coordinates refer to pixel centers. 
%************************************************************************** 
function isInside = seed_point_is_inside_mask(starDataStruct)
    PIXEL_DIAGONAL_LENGTH = sqrt(2.0);
    
    maskRowArray = starDataStruct.row;
    maskColArray = starDataStruct.column;
    seedRow      = starDataStruct.seedRow;
    seedCol      = starDataStruct.seedColumn;
    
    distances = ...
        sqrt((maskRowArray - seedRow).^2 + (maskColArray - seedCol).^2);
    
    isInside = min(distances) < PIXEL_DIAGONAL_LENGTH / 2;
end