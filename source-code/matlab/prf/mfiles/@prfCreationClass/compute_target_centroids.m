function [centroids] = ...
compute_target_centroids(prfCreationObject, prfCollectionStruct)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [prfResultStruct] = ...
% compute_target_centroids(prfCreationObject, prfCollectionStruct)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Compute row and column centroid time series for each stellar target. Be
% careful when dealing with potential cadence gaps. 'Best' centroid
% algorithm uses PRF for row and column centroid estimation. Compute the
% centroids cadence by cadence so that the centroid for each cadence is
% *not* used as the seed for the next.
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


% Set constant tolerance for centroid validation.
CENTROID_TOLERANCE = 1e-10;
POU_DEBUG_LEVEL = 0;

% Set the input uncertainties file name.
prfInputUncertaintiesFileName = 'prf_input_uncertainties.mat';

% Get fields from input object.
targetStarsStruct = prfCreationObject.targetStarsStruct;
backgroundPolyStruct = prfCreationObject.backgroundPolyStruct;

cadenceTimes = prfCreationObject.cadenceTimes;
timestamps = cadenceTimes.midTimestamps;
cadenceGapIndicators = cadenceTimes.gapIndicators;
cadenceNumbers = cadenceTimes.cadenceNumbers;
nCadences = length(cadenceGapIndicators);

fcConstants = prfCreationObject.fcConstants;

prfConfigurationStruct = prfCreationObject.prfConfigurationStruct;
magnitudeRange = prfConfigurationStruct.magnitudeRange;
crowdingThreshold = prfConfigurationStruct.crowdingThreshold;

pouConfigurationStruct = prfCreationObject.pouConfigurationStruct;
pouEnabled = pouConfigurationStruct.pouEnabled;
compressionEnabled = pouConfigurationStruct.compressionEnabled;
pixelChunkSize = pouConfigurationStruct.pixelChunkSize;
cadenceChunkSize = pouConfigurationStruct.cadenceChunkSize;
interpDecimation = pouConfigurationStruct.interpDecimation;
interpMethod = pouConfigurationStruct.interpMethod;

% Create the POU struct.
pouStruct.inputUncertaintiesFileName = prfInputUncertaintiesFileName;
pouStruct.cadenceNumbers = cadenceNumbers;
pouStruct.pouEnabled = pouEnabled;
pouStruct.pouDecimationEnabled = true;
pouStruct.pouCompressionEnabled = compressionEnabled;
pouStruct.pouPixelChunkSize = pixelChunkSize;
pouStruct.pouCadenceChunkSize = cadenceChunkSize;
pouStruct.pouInterpDecimation = interpDecimation;
pouStruct.pouInterpMethod = interpMethod;
pouStruct.debugLevel = POU_DEBUG_LEVEL;

% Initialize incoming pouStructArray as empty
pouStructArray = [];

% Instantiate a prf object. Blob must first be converted to struct.
prfObject = prfCollectionClass(prfCollectionStruct, ...
    prfCreationObject.fcConstants);

% Initialize the centroids structure.
nTargets = length(targetStarsStruct);
centroids = repmat(struct( ...
    'keplerId', 0, ...
    'rows', [], ...
    'rowUncertainties', [], ...
    'columns', [], ...
    'columnUncertainties', [], ...
    'gapIndices', [] ), [1, nTargets]);

% Loop through the targets and call the centroiding function. It loops over
% the targets anyway, so there is no need to call it only once. Select
% targets for centroiding based on magnitude range and crowding threshold.
for iTarget = 1 : nTargets
    
    % Determine if given target is in desired magnitude range and exceeds
    % crowding threshold.
    targetDataStruct = targetStarsStruct(iTarget);
    selectedTarget ... 
        = targetDataStruct.keplerMag >= 12 ...
        && targetDataStruct.keplerMag <= 13 ...
        && targetDataStruct.keplerId ~= 7880048 ...
        && targetDataStruct.keplerId ~= 5472344 ...
        && targetDataStruct.keplerId ~= 5682974 ...
        && targetDataStruct.keplerId ~= 6100142 ...
        && targetDataStruct.extendedCrowdingMetric >= crowdingThreshold;
    
    if selectedTarget
        
        % Set up the data structure required by
        % compute_starDataStruct_centroid.
        centroidStruct = centroids(iTarget);
        centroidStruct.keplerId = targetDataStruct.keplerId;

        starDataStruct.row = [targetDataStruct.pixelTimeSeriesStruct.row]';
        starDataStruct.column = [targetDataStruct.pixelTimeSeriesStruct.column]';
        starValues = [targetDataStruct.pixelTimeSeriesStruct.values]';
        starUncertainties = [targetDataStruct.pixelTimeSeriesStruct.uncertainties]';

        gapIndicesCellArray = {targetDataStruct.pixelTimeSeriesStruct.gapIndices};
        gapArray = false(size(starValues));
        for iPixel = 1 : length(gapIndicesCellArray)
            gapArray(iPixel, gapIndicesCellArray{iPixel}) = true;
        end

        % Determine the centroiding aperture and the bounding box for
        % validation of row/column centroid coordinates. All pixels in the
        % aperture that lie on the photometric region of the CCD are used
        % for PRF-based ('best') centroiding.
        isInOptimalAperture = ...
            [targetDataStruct.pixelTimeSeriesStruct.isInOptimalAperture]';
        isInCentroidAperture = true(size(isInOptimalAperture));
        [isInCentroidAperture] = ...
            trim_non_photometric_pixels_from_aperture( ...
            starDataStruct.row, starDataStruct.column, ...
            isInCentroidAperture, fcConstants);
        starDataStruct.inOptimalAperture = isInCentroidAperture;
        
        minApertureRow = min(starDataStruct.row(isInCentroidAperture));
        maxApertureRow = max(starDataStruct.row(isInCentroidAperture));
        minApertureColumn = min(starDataStruct.column(isInCentroidAperture));
        maxApertureColumn = max(starDataStruct.column(isInCentroidAperture));
    
        % Set the seed point for the given target centroids.
        starDataStruct.seedRow = [];
        starDataStruct.seedColumn = [];

        % Initialize the centroids structure.
        centroidStruct.rows = zeros(size(cadenceGapIndicators));
        centroidStruct.rowUncertainties = zeros(size(cadenceGapIndicators));
        centroidStruct.columns = zeros(size(cadenceGapIndicators));
        centroidStruct.columnUncertainties = zeros(size(cadenceGapIndicators));
        centroidGapIndicators = true(size(cadenceGapIndicators));

        % Get the decimated cadences for which the target covariances will be
        % computed without interpolation if POU is enabled.
        decimatedCadenceList = downsample(cadenceNumbers, interpDecimation);
        chunkedCadenceList = [];
    
        % Compute the centroid time series for all targets using valid cadences
        % only. Do the centroiding one cadence at a time so that the centroid
        % for each cadence is *not* used as the seed for the next.
        for iCadence = 1 : nCadences

            if cadenceGapIndicators(iCadence)
                continue;
            end

            starDataStruct.values = starValues( : , iCadence);
            starDataStruct.uncertainties = starUncertainties( : , iCadence);
            starDataStruct.gapIndicators = gapArray( : , iCadence);

            % Get full target covariance and propagate uncertainties if POU is
            % enabled. Otherwise simplified uncertainty propagation will be
            % performed based on assumptions of independence.
            if pouEnabled

                % Retrieve a chunk of decimated covariances if necessary.
                cadence = cadenceNumbers(iCadence);

                if isempty(chunkedCadenceList) || ...
                        (cadence > chunkedCadenceList(end) && ...
                        ~isempty(decimatedCadenceList))

                    nRemain = length(decimatedCadenceList);
                    chunkSize = min(cadenceChunkSize, nRemain);
                    chunkedCadenceList = decimatedCadenceList(1 : chunkSize);
                    if chunkSize == nRemain
                        decimatedCadenceList = [];
                    else
                        decimatedCadenceList(1 : chunkSize - 1) = [];
                    end

                    clear Cv
                    [Cv, covarianceGapIndicators, pouStructArray] = ...
                        retrieve_cal_pixel_covariance( ...
                        starDataStruct.row, starDataStruct.column, ...
                        chunkedCadenceList, pouStruct, pouStructArray);

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
                        CtargetPix = squeeze(interp1(validCadenceList, Cv, ...
                            cadence, interpMethod, 'extrap'));
                    else % nCadences == 1
                        CtargetPix = squeeze(Cv);
                    end

                    backgroundPoly = backgroundPolyStruct(iCadence).backgroundPoly;
                    [z, zu, Aback] = weighted_polyval2d(starDataStruct.row, ...
                        starDataStruct.column, backgroundPoly);
                    CtargetPixBackRemoved = CtargetPix + ...
                        Aback * backgroundPoly.covariance * Aback';

                end % if /else

                % Explicitly set the rows and columns to 0 if the associated
                % pixels are gapped.
                CtargetPixBackRemoved(starDataStruct.gapIndicators, : ) = 0;
                CtargetPixBackRemoved( : , starDataStruct.gapIndicators) = 0;

                % Duplicate the single cadence covariance matrix so that the
                % library function to compute the star centroid is not fooled
                % by the dimension of the input uncertainties array.
                starDataStruct.uncertainties = [];
                starDataStruct.uncertainties( : , : , 1) = CtargetPixBackRemoved;
                starDataStruct.uncertainties( : , : , 2) = CtargetPixBackRemoved;

            end % if
        
            [centroidRow, centroidColumn, centroidStatus, centroidCovariance] = ...
                compute_starDataStruct_centroid(starDataStruct, prfObject, ...
                timestamps(iCadence), 'best');

            % Check that centroid is valid. It can't be valid if it does not
            % fall within the bounding box for the centroiding aperture.
            if 0 == centroidStatus && ...
                    (centroidRow + CENTROID_TOLERANCE < minApertureRow || ...
                    centroidRow - CENTROID_TOLERANCE > maxApertureRow || ...
                    centroidColumn + CENTROID_TOLERANCE < minApertureColumn || ...
                    centroidColumn - CENTROID_TOLERANCE > maxApertureColumn)
                centroidStatus = 1;
            end % if
        
            % Distribute the results to the centroids structure if the centroid
            % is valid.
            if ~centroidStatus

                centroidStruct.rows(iCadence) = centroidRow;
                centroidStruct.rowUncertainties(iCadence) = ...
                    sqrt(centroidCovariance(1, 1, 1));

                centroidStruct.columns(iCadence) = centroidColumn;
                centroidStruct.columnUncertainties(iCadence) = ...
                    sqrt(centroidCovariance(1, 2, 2));

                centroidGapIndicators(iCadence) = false;

            end % if

        end % for iCadence

        centroidStruct.gapIndices = find(centroidGapIndicators);
        centroids(iTarget) = centroidStruct;
        
    else % is not a selected target
        
        centroids(iTarget).keplerId = targetStarsStruct(iTarget).keplerId;        
        centroids(iTarget).rows = zeros(size(cadenceGapIndicators));
        centroids(iTarget).rowUncertainties = zeros(size(cadenceGapIndicators));
        centroids(iTarget).columns = zeros(size(cadenceGapIndicators));
        centroids(iTarget).columnUncertainties = zeros(size(cadenceGapIndicators));
        centroids(iTarget).gapIndices = (1 : nCadences)';
        
    end % check on selected targets
    
end % for iTarget

% Return.
return
