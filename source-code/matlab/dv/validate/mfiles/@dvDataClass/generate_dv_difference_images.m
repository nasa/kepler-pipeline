function [dvResultsStruct] = ...
generate_dv_difference_images(dvDataObject, dvResultsStruct)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [dvResultsStruct] = ...
% generate_dv_difference_images(dvDataObject, dvResultsStruct)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Generate the difference images for each planet candidate and target table
% for the respective DV target reports. Each image contains four subplots:
% (1) an image of mean out of transit pixel values in the neightborhood of
% the transits for the given planet candidate and target table; (2) an
% image of the mean in transit pixel values for the given planet candidate
% and target table; (3) a difference image (mean out of transit minus mean
% in transit) for the given planet candidate and target table; (4) a
% difference image (mean out of transit minus mean in transit) scaled by
% the uncertainties in the difference for each pixel for the given planet
% candidate and target table.
%
% In transit cadences are those for which the depth exceeds a specified
% fraction of the maximum transit depth. Out of transit cadences are
% defined for each transit by one transit duration on either side of the
% transit. A fixed-cadence buffer is included between the in- and out-of-
% transit cadences to ensure that in-transit values do not corrupt the
% out-of-transit flux estimates. The limb darkened model fit to all
% transits is utilized if the fit was performed successfully; otherwise the
% trapezoidal model fit result is utilized to identify the in and out of
% transit cadences.
%
% A one-pixel halo surrounding the bounding box for the target mask is
% added to each of the four subplots. The target mask and optimal aperture
% are clearly identified in the subplots for each target table. The mean
% location of the target in CCD coordinates based on evaluation of the
% motion polynomials at the in transit cadences for each target table is
% overlaid on all of the image subplots. The PRF-based centroids of the
% mean out of transit and difference images are also overlaid on those
% images. In addition the mean locations of all nearby KIC objects based on
% evaluation of the motion polynomials are marked on all of the image
% subplots. The target and nearby objects are identified by Kepler ID and
% associated Kepler magnitude.
%
% The mean out of transit pixel values and the mean in transit pixel values
% are determined on a transit by transit basis and subsequently averaged
% over all transits. This permits high quality difference imaging without
% the need for prior detrending (which may introduce artifacts in the
% respective pixel time series).
%
% A direct image showing the mean flux over all cadences for a given target
% table is generated for planet candidates without successful fits and for
% planet candidates without (clean) observed transits in the target table.
% Clean transits must not overlap known data anomalies (with extensions
% following Earth points and safe modes) and must not overlap the in
% transit cadences for other planet candidates associated with the given
% target.
%
% The DV results structure is updated for each planet candidate and target
% table with the mean in transit pixel values and uncertainties (where
% applicable), mean out of transit pixel values and uncertainties (where
% applicable), mean difference pixel values and uncertainties (where
% applicable), and mean pixel values and uncertainties for the given
% target table. The results structure is also updated with the number of
% clean transits from which the difference image was generated, the number
% of valid in-transit cadences (per pixel time series), the number of
% gapped in-transit cadences, the number of valid out-of-transit cadences,
% and the number of gapped out-of-transit cadences.
%
% PRF-based centroids are computed for the control (i.e. mean out of
% transit) and difference images for each planet candidate and target
% table. The offsets between the respective centroids are computed, along
% with the associated uncertainties. The KIC reference position of the
% target is also estimated by determining the mean position of the target
% on the in transit cadences for a given target table. The offsets between
% the difference image centroid and the KIC reference position are also
% computed along with the associate uncertainties. The robust weighted mean
% of the difference image centroid offsets (with respect to both control
% centroid and KIC reference) are also computed over all target tables.
% For planet candidates with low-SNR model fits, a bootstrap multi-quarter
% PRF fit is performed along with a centroid offset computation and
% analysis. A quality metric is computed for each quarterly difference
% image, and a summary quality metric is determined for each planet
% candidate based on the quality metrics for all of the quarterly
% difference images associated with it.
%
% The DV results structure is updated for each planet candidate and target
% table with the PRF-based centroids (on focal plane and sky) of the
% control (i.e. mean out of transit) and difference images and with the KIC
% reference position derived through the motion polynomials. The results
% structure is also updated with the offsets (on both focal plane and sky)
% of the difference image centroid relative to the control image centroid
% and the KIC reference position. Finally, the DV results structure is
% updated with the robust weighted mean centroid offsets computed over all
% targets tables for each planet candidate and with the bootstrap PRF fit
% centroids and offsets where applicable.
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

% Define constants.
DEGREES_PER_HOUR = 360 / 24;
ORBITAL_PERIOD_STRING = 'orbitalPeriodDays';
TRANSIT_DURATION_STRING = 'transitDurationHours';
HALO_PIXELS = 1;
GAP_VALUE = -1;
MAX_PIXELS_FOR_PIXEL_TIME_SERIES_FIGURES = 120;

% Get difference image generation parameters.
differenceImageConfigurationStruct = ...
    dvDataObject.differenceImageConfigurationStruct;

detrendingEnabled = differenceImageConfigurationStruct.detrendingEnabled;
detrendPolyOrder = differenceImageConfigurationStruct.detrendPolyOrder;
defaultMedianFilterLength = ...
    differenceImageConfigurationStruct.defaultMedianFilterLength;
anomalyBufferInDays = ...
    differenceImageConfigurationStruct.anomalyBufferInDays;
controlBufferInCadences = ...
    differenceImageConfigurationStruct.controlBufferInCadences;
minInTransitDepth = ...
    differenceImageConfigurationStruct.minInTransitDepth;
overlappedTransitExclusionEnabled = ...
    differenceImageConfigurationStruct.overlappedTransitExclusionEnabled;
mqOffsetConstantUncertainty = ...
    differenceImageConfigurationStruct.mqOffsetConstantUncertainty;
qualityThreshold = ...
    differenceImageConfigurationStruct.qualityThreshold;
badQualityOffsetRemovalEnabled = ...
    differenceImageConfigurationStruct.badQualityOffsetRemovalEnabled;

% Get the LC target table ID's and determine the cadence duration.
dvCadenceTimes = dvDataObject.dvCadenceTimes;
cadenceNumbers = dvCadenceTimes.cadenceNumbers;
lcTargetTableIds = dvCadenceTimes.lcTargetTableIds;
dataAnomalyIndicators = dvCadenceTimes.dataAnomalyFlags;
cadenceGapIndicators = dvCadenceTimes.gapIndicators;
midTimestamps = dvCadenceTimes.midTimestamps;

startTimestamps = dvCadenceTimes.startTimestamps(~cadenceGapIndicators);
endTimestamps = dvCadenceTimes.endTimestamps(~cadenceGapIndicators);
cadenceDurations = endTimestamps - startTimestamps;
cadenceDurationInDays = median(cadenceDurations);
clear startTimestamps endTimestamps cadenceDurations

nCadences = length(cadenceGapIndicators);

% Get the KICs.
kics = dvDataObject.kics;

% Parse the data anomaly types. Add buffers for the Earth-points and safe
% modes. Aggregate the anomaly cadences including the start and end of the
% time series. Ensure that interquarter Earth-points are covered even if
% the associated anomaly flags are not set for the full interquarter gaps.
% Transits that are coincident with the anomaly cadences will later be
% excluded from the difference images.
anomalyBufferCadences = ...
    round(anomalyBufferInDays / cadenceDurationInDays);

[dataAnomalyIndicators.earthPointIndicators] = ...
    buffer_anomaly_indicators(dataAnomalyIndicators.earthPointIndicators, ...
    anomalyBufferCadences);
[dataAnomalyIndicators.safeModeIndicators] = ...
    buffer_anomaly_indicators(dataAnomalyIndicators.safeModeIndicators, ...
    anomalyBufferCadences);

anomalyIndicators = ...
    dataAnomalyIndicators.attitudeTweakIndicators | ...
    dataAnomalyIndicators.safeModeIndicators | ...
    dataAnomalyIndicators.earthPointIndicators | ...
    dataAnomalyIndicators.coarsePointIndicators | ...
    dataAnomalyIndicators.excludeIndicators | ...
    dataAnomalyIndicators.planetSearchExcludeIndicators;

targetTableDataStruct = dvDataObject.targetTableDataStruct;

for iTable = 1 : length(targetTableDataStruct)
    startCadence = targetTableDataStruct(iTable).startCadence;
    endCadence = targetTableDataStruct(iTable).endCadence;
    startCadenceIndex = find(cadenceNumbers == startCadence);
    endCadenceIndex = find(cadenceNumbers == endCadence);
    anomalyIndicators(max(startCadenceIndex-1, 1)) = true;
    anomalyIndicators(min(endCadenceIndex+1, nCadences)) = true;
end % for iTable

% Get the randstreams if they exist.
streams = false;
fields = fieldnames(dvDataObject);
if any(strcmp('randStreamStruct', fields))
    randStreams = dvDataObject.randStreamStruct.differenceImageRandStreams;
    streams = true;
end % if

% Loop over the targets and generate the difference images.
nTargets = length(dvResultsStruct.targetResultsStruct);

for iTarget = 1 : nTargets
    
    % Get the keplerId and UKIRT image file name.
    keplerId = dvDataObject.targetStruct(iTarget).keplerId;
    ukirtImageFileName = ...
        dvDataObject.targetStruct(iTarget).ukirtImageFileName;
    
    % Set target-specific randstreams.
    if streams
        randStreams.set_default(keplerId);
    end % if
    
    % Get the Ra and Dec for the given target in degrees.
    targetRaHours = dvDataObject.targetStruct(iTarget).raHours.value;
    targetRaDegrees = targetRaHours * DEGREES_PER_HOUR;
    targetDecDegrees = dvDataObject.targetStruct(iTarget).decDegrees.value;
    
    % Get the barycentric corrected timestamps for the given target.
    barycentricCadenceTimes = ...
        dvDataObject.barycentricCadenceTimes(iTarget);
    bkjdTimestamps = barycentricCadenceTimes.midTimestamps;
    
    % Initialize the transit model for the given target.
    thresholdCrossingEvent = ...
        dvDataObject.targetStruct(iTarget).thresholdCrossingEvent(1);
    [transitModel] = ...
        convert_tps_parameters_to_transit_model(dvDataObject, ...
        iTarget, thresholdCrossingEvent);
    
    % Get the orbital periods and transit durations for each planet
    % candidate while cycling through the fit results. Generate a model
    % light curve and identify the in and out of transit cadences for each
    % planet candidate with a valid fit.
    targetResultsStruct = dvResultsStruct.targetResultsStruct(iTarget);
    nPlanets = length(targetResultsStruct.planetResultsStruct);
    rootDir = targetResultsStruct.dvFiguresRootDirectory;
    
    orbitalPeriodsInDays = inf([nPlanets, 1]);
    transitDurationsInHours = zeros([nPlanets, 1]);
    isValidFit = false([nPlanets, 1]);
    
    modelLightCurveArray = zeros([nCadences, nPlanets]);
    transitNumberArray = zeros([nCadences, nPlanets]);
    transitNumberWithoutBufferArray = zeros([nCadences, nPlanets]);
    transitNumberWithBufferArray = zeros([nCadences, nPlanets]);
    isInTransitArray = false([nCadences, nPlanets]);
    isOutOfTransitArray = false([nCadences, nPlanets]);
    
    fitResultsStructArray = ...
        [targetResultsStruct.planetResultsStruct.allTransitsFit];
    
    for iPlanet = 1 : nPlanets
        
        % Get the best model fit results for the given candidate. Move on
        % to the next candidate if there are no valid fit results. Issue
        % a warning alert if falling back to the trapezoidal model fit
        % results in support of difference imaging and offset analysis.        
        planetResultsStruct = ...
            targetResultsStruct.planetResultsStruct(iPlanet);
        [fitResultsStruct, modelLightCurve, ...
            allTransitsFitReturned, trapezoidalFitReturned] = ...
            get_fit_results_for_diagnostic_test(planetResultsStruct);                      %#ok<ASGLU>
        
        if isempty(fitResultsStruct)
            continue;
        elseif trapezoidalFitReturned
            fitResultsStructArray(iPlanet) = fitResultsStruct;
            string = sprintf('Falling back to trapezoidal model fit results to support difference imaging');
            [dvResultsStruct] = add_dv_alert(dvResultsStruct, 'generateDvDifferenceImages', ...
                'warning', string, iTarget, keplerId, iPlanet);
            disp(dvResultsStruct.alerts(end).message);
        end % if / elseif
        
        modelLightCurveArray( : , iPlanet) = modelLightCurve;
        
        % Mark the fit for the given planet candidate as valid and
        % retrieve the fitted orbital period and transit duration.
        isValidFit(iPlanet) = true;

        [modelParameter, uniqueMatchFlag] = ...
            retrieve_model_parameter(fitResultsStruct.modelParameters, ...
            ORBITAL_PERIOD_STRING);
        if uniqueMatchFlag
            orbitalPeriodsInDays(iPlanet) = modelParameter.value;
        end % if

        [modelParameter, uniqueMatchFlag] = ...
            retrieve_model_parameter(fitResultsStruct.modelParameters, ...
            TRANSIT_DURATION_STRING);
        if uniqueMatchFlag
            transitDurationsInHours(iPlanet) = modelParameter.value;
        end % if

        % Update the planet model for the given candidate and instantiate a
        % transit object.
        transitModel.planetModel = fitResultsStruct.modelParameters;
        [transitObject] = transitGeneratorClass(transitModel);

        % Identify the in- and out-of-transit cadences for the given 
        % planet candidate. Add a control buffer between the in and out
        % of transit cadences.
        [transitNumber] = ...
            identify_transit_cadences(transitObject, bkjdTimestamps, 0);
        transitNumberArray( : , iPlanet) = transitNumber;
        [transitNumber] = ...
            add_control_buffer(transitNumber, controlBufferInCadences);
        transitNumberWithoutBufferArray( : , iPlanet) = transitNumber;

        [transitNumber] = ...
            identify_transit_cadences(transitObject, bkjdTimestamps, 1);
        [transitNumber] = ...
            add_control_buffer(transitNumber, controlBufferInCadences);
        transitNumberWithBufferArray( : , iPlanet) = transitNumber;
        
    end % for iPlanet
    
    % Now that the transits have been identified for all planet candidates,
    % exclude transits that are coincident from one candidate to another
    % and exclude the transits near known anomalies and the start/end of
    % the time series. Also, keep only the in transit cadences for which
    % the transit depth is greater than a specified fraction of the maximum
    % depth.
    for iPlanet = 1 : nPlanets
        
        % Set logical indicators for the in and out of transit cadences.
        modelLightCurve = modelLightCurveArray( : , iPlanet);
        transitNumberWithBuffer = transitNumberWithBufferArray( : , iPlanet);
        transitNumberWithoutBuffer = transitNumberWithoutBufferArray( : , iPlanet);
        
        isInTransit = transitNumberWithoutBuffer > 0;
        isOutOfTransit = transitNumberWithBuffer > 0 & ~isInTransit;
        
        maxDepth = min(modelLightCurve);
        if maxDepth < 0
            isInTransit = isInTransit & ...
                modelLightCurve < minInTransitDepth * maxDepth;
        end % if
        
        isInTransitOrig = isInTransit;
        isOutOfTransitOrig = isOutOfTransit;
        
        % Exclude transits that are near known anomalies and the start/end
        % of the time series.
        transitsToExclude1 = ...
            setdiff(unique(transitNumberWithBuffer(anomalyIndicators)), 0);
        isInTransit(ismember(transitNumberWithBuffer, transitsToExclude1)) = false;
        isOutOfTransit(ismember(transitNumberWithBuffer, transitsToExclude1)) = false;
        
        % Exclude transits that are coincident from one planet candidate to
        % another. Under certain circumstances the exclusion of transits
        % due to overlap with other transits may be overridden however.
        otherPlanetIndicators = true([nPlanets, 1]);
        otherPlanetIndicators(iPlanet) = false;
            
        if nPlanets > 1
            
            % Identify the transits that overlap those of the other
            % candidates.
            otherTransitCadenceIndicators = ...
                any(transitNumberWithoutBufferArray( : , otherPlanetIndicators) > 0, 2);
            transitsToExclude2 = ...
                setdiff(unique(transitNumberWithBuffer(otherTransitCadenceIndicators)), 0);
            
            % Loop over the target tables and ensure that *all* of the
            % (remaining) transits in a given quarter are not excluded due
            % to overlap with transits of other planets on the same target.
            % The SO has stated that it is preferable to produce
            % compromised difference images than no differences under such
            % circumstances. Issue an alert for each planet candidate and
            % target table (i.e. quarter) where the exclusion of one or
            % more overlapped transits is overridden.
            nTables = length(dvDataObject.targetStruct(iTarget).targetDataStruct);
    
            for iTable = 1 : nTables
                
                targetDataStruct = ...
                    dvDataObject.targetStruct(iTarget).targetDataStruct(iTable);
                targetTableId = targetDataStruct.targetTableId;
                targetTableQuarter = targetDataStruct.quarter;
                targetTableStartCadence = targetDataStruct.startCadence;
                targetTableEndCadence = targetDataStruct.endCadence;
                
                isInTable = lcTargetTableIds == targetTableId;
                firstTableCadenceIndex = find(isInTable, 1, 'first');
                nCadencesInTable = targetTableEndCadence - targetTableStartCadence + 1;
                cadenceRange = firstTableCadenceIndex : ...
                    firstTableCadenceIndex + nCadencesInTable - 1;
                
                transitsInTable = setdiff(unique(transitNumberWithBuffer(cadenceRange)), ...
                    [0; transitsToExclude1]);
                if ~isempty(transitsInTable) && all(ismember(transitsInTable, transitsToExclude2)) ...
                        && ~overlappedTransitExclusionEnabled
                    transitsToExclude2 = ...
                        setdiff(transitsToExclude2, transitsInTable);
                    targetResultsStruct.planetResultsStruct(iPlanet).differenceImageResults(iTable).overlappedTransits = true;
                    string = sprintf('Overriding exclusion of transits that overlap those of another candidate in Q%d', ...
                        targetTableQuarter);
                    [dvResultsStruct] = add_dv_alert(dvResultsStruct, 'generateDvDifferenceImages', ...
                        'warning', string, iTarget, keplerId, iPlanet, targetTableId);
                    disp(dvResultsStruct.alerts(end).message);
                end % if
                
            end % for iTable
            
            % Exclude the transits which are not overridden.
            isInTransit(ismember(transitNumberWithBuffer, transitsToExclude2)) = false;
            isOutOfTransit(ismember(transitNumberWithBuffer, transitsToExclude2)) = false;
            
        end % if
        
        isInTransitArray( : , iPlanet) = isInTransit;
        isOutOfTransitArray( : , iPlanet) = isOutOfTransit;
        
        % Create model light curve diagnostic figure for the given planet
        % candidate.
        if isValidFit(iPlanet)
            
            close;
            
            plot(modelLightCurveArray( :  , otherPlanetIndicators & isValidFit), '--r');
            hold on
            planetResultsStruct = targetResultsStruct.planetResultsStruct(iPlanet);
            tableIds = [planetResultsStruct.differenceImageResults.targetTableId];
            isInTables = ismember(lcTargetTableIds, tableIds);
            lc = modelLightCurve;
            lc(~isInTables) = NaN;
            plot(lc, '.-b');
            lc = modelLightCurve;
            lc(isInTables) = NaN;
            plot(lc, '.-c');
            plot(find(anomalyIndicators), modelLightCurve(anomalyIndicators), 'sm');
            plot(find(isInTransit), modelLightCurve(isInTransit), 'or', 'MarkerSize', 7)
            plot(find(isOutOfTransit), modelLightCurve(isOutOfTransit), 'og', 'MarkerSize', 7)
            plot(find(isInTransitOrig & ~isInTransit), modelLightCurve(isInTransitOrig & ~isInTransit), 'xr', 'MarkerSize', 7)
            plot(find(isOutOfTransitOrig & ~isOutOfTransit), modelLightCurve(isOutOfTransitOrig & ~isOutOfTransit), 'xg', 'MarkerSize', 7)
            title({'Model Light Curve';
                ['Planet Candidate ', num2str(iPlanet)]});
            xlabel('Relative Cadence Number');
            ylabel('Fractional Transit Depth');
            
            tableIds = unique(lcTargetTableIds);
            if length(tableIds) > 1
                x = axis;
                for iTable = 2 : length(tableIds)
                    startIndex = ...
                        find(lcTargetTableIds == tableIds(iTable), 1, 'first');
                    plot([startIndex; startIndex], [x(3); x(4)], '--k');
                end % for iTable
            end % if
            
            figureName = [rootDir, sprintf('/planet-%02d', iPlanet), ...
                '/difference-image/', num2str(keplerId, '%09d'), '-', ...
                num2str(iPlanet, '%02d'), '-candidate-model-light-curve'];
            saveas(gcf, figureName);
            
        end % if
        
    end % for iPlanet
          
    % Loop over the target tables and produce the direct and difference
    % images for the respective planet candidates.
    nTables = length(dvDataObject.targetStruct(iTarget).targetDataStruct);
    
    for iTable = 1 : nTables
        
        % Get the (zero-based) CCD coordinates for the target pixels in the
        % given target table. Assemble the respective time series into
        % arrays of pixel values, uncertainties, and gap indicators.
        targetDataStruct = ...
            dvDataObject.targetStruct(iTarget).targetDataStruct(iTable);
        targetTableId = targetDataStruct.targetTableId;
        targetTableQuarter = targetDataStruct.quarter;
        targetTableCcdModule = targetDataStruct.ccdModule;
        targetTableCcdOutput = targetDataStruct.ccdOutput;
        targetTableStartCadence = targetDataStruct.startCadence;
        targetTableEndCadence = targetDataStruct.endCadence;
        
        pixelDataFileName = targetDataStruct.pixelDataFileName;
        [pixelDataStruct, status, path, name, ext] = ...
            file_to_struct(pixelDataFileName, 'pixelDataStruct');                          %#ok<ASGLU>
        if ~status
            error('DV:generateDvDifferenceImages:unknownDataFileType', ...
                'unknown pixel data file type (%s%s)', ...
                name, ext);
        end % if
        
        nPixels = length(pixelDataStruct);
        pixelTimeSeriesFiguresEnabled = true;
        if nPixels > MAX_PIXELS_FOR_PIXEL_TIME_SERIES_FIGURES
            pixelTimeSeriesFiguresEnabled = false;
        end % if
        
        ccdRows = [pixelDataStruct.ccdRow]'-1;
        ccdColumns = [pixelDataStruct.ccdColumn]'-1;
        inOptimalAperture = [pixelDataStruct.inOptimalAperture]';

        timeSeriesArray = [pixelDataStruct.calibratedTimeSeries];
        pixelValues = [timeSeriesArray.values];
        pixelUncertainties = [timeSeriesArray.uncertainties];
        gapArray = [timeSeriesArray.gapIndicators];
        pixelValues(gapArray) = NaN;
        pixelUncertainties(gapArray) = 0;
        clear pixelDataStruct timeSeriesArray
        
        % Get the PRF model for the given target table and instantiate a
        % PRF collection class object.
        if ~isempty(dvDataObject.prfModels)
            
            ccdModules = [dvDataObject.prfModels.ccdModule]';
            ccdOutputs = [dvDataObject.prfModels.ccdOutput]';
            
            [tf, loc] = ismember([targetTableCcdModule, targetTableCcdOutput], ...
                [ccdModules, ccdOutputs], 'rows');
            
            if tf
                [prfStruct] = ...
                    blob_to_struct(dvDataObject.prfModels(loc).blob);
                if isfield(prfStruct, 'c')   % it's a single prf model
                    prfModel.polyStruct = prfStruct;
                else
                    prfModel = prfStruct;
                end % if / else
                [prfObject] = ...
                    prfCollectionClass(prfModel, dvDataObject.fcConstants);
                clear prfStruct prfModel
            else
                error('DV:generateDvDifferenceImages', ...
                    'PRF for module %d output %d is not present in DV inputs', ...
                    targetTableCcdModule, targetTableCcdOutput);
            end % if / else
            
        end % if
        
        % Issue alert if there is no ungapped pixel data for the given
        % target table and move on to the next target table.
        gapIndicators = any(gapArray, 2);
        clear gapArray
        
        if all(gapIndicators)
            string = ['All pixel data gapped for target table ', num2str(targetTableId), ...
                '; no direct or difference images will be generated for any planet candidate'];
            [dvResultsStruct] = add_dv_alert(dvResultsStruct, 'generateDvDifferenceImages', ...
                'warning', string, iTarget, keplerId);
            disp(dvResultsStruct.alerts(end).message);
            continue;
        end % if

        % Set up the aperture for the given target. Pad for display of
        % nearby objects.
        minRow = min(ccdRows) - HALO_PIXELS;
        maxRow = max(ccdRows) + HALO_PIXELS;
        minCol = min(ccdColumns) - HALO_PIXELS;
        maxCol = max(ccdColumns) + HALO_PIXELS;
        
        nRows = maxRow - minRow + 1;
        nColumns = maxCol - minCol + 1;

        aperturePixelIndices = sub2ind([nRows, nColumns], ...
            ccdRows - minRow + 1, ccdColumns - minCol + 1);

        % Get the cadence range for the given target table.
        isInTable = lcTargetTableIds == targetTableId;
        firstTableCadenceIndex = find(isInTable, 1, 'first');
        nCadencesInTable = targetTableEndCadence - targetTableStartCadence + 1;
        cadenceRange = firstTableCadenceIndex : ...
            firstTableCadenceIndex + nCadencesInTable - 1;
        
        % Detrend the target pixels based on the planet candidate with the
        % longest duration transits and the candidate with the shortest
        % period. First, perform low-order polynomial detrending. Then,
        % interpolate the gaps and perform median filtering. Use the
        % default median filter length if there were no valid model fits
        % for the given target. Squeeze gaps from the detrended target
        % pixels.
        if detrendingEnabled
            
            if any(isValidFit)
                minOrbitalPeriodInCadences = ...
                    min(orbitalPeriodsInDays) / cadenceDurationInDays;
                maxTransitDurationInCadences = ...
                    max(transitDurationsInHours) * get_unit_conversion('hour2day') / ...
                    cadenceDurationInDays;
                medianFilterLength = ...
                    sqrt(maxTransitDurationInCadences * minOrbitalPeriodInCadences);
            else
                medianFilterLength = defaultMedianFilterLength;
            end % if / else

            medianFilterLength = min(medianFilterLength, nCadencesInTable-1);
            medianFilterLength = 2 * floor(medianFilterLength / 2) + 1;

            detrendedPixelValues = detrendcols(pixelValues, detrendPolyOrder, ...
                find(gapIndicators));
            detrendedPixelValues(gapIndicators, : ) = ...
                interp1(find(~gapIndicators), ...
                detrendedPixelValues(~gapIndicators, : ), ...
                find(gapIndicators), 'linear', 'extrap');
            
            medianValues = nanmedian(pixelValues, 1);
            medianArray = repmat(medianValues, [size(pixelValues, 1), 1]);
            detrendedPixelValues = detrendedPixelValues - ...
                medfilt1_soc(detrendedPixelValues, medianFilterLength) + medianArray;
            
            detrendedPixelValues = detrendedPixelValues(~gapIndicators, : );
            pixelValues = pixelValues(~gapIndicators, : );                                  %#ok<NASGU>
            pixelUncertainties = pixelUncertainties(~gapIndicators, : );
            clear pixelValues medianArray
        
        else % detrending is not enabled
            
            pixelValues = pixelValues(~gapIndicators, : );
            pixelUncertainties = pixelUncertainties(~gapIndicators, : );
            detrendedPixelValues = pixelValues;
            clear pixelValues
            
        end % if / else
        
        % Compute the reference CCD position over the given target table
        % from the motion polynomials based on the KIC RA/DEC  (if
        % available). Note that the motion polynomials return 1-based CCD
        % coordinates, but the direct images will be plotted in 0-based
        % coordinates.
        targetTableIds = [dvDataObject.targetTableDataStruct.targetTableId];
        targetTableDataStruct = ...
            dvDataObject.targetTableDataStruct(targetTableIds == targetTableId);
        
        motionPolyStruct = targetTableDataStruct.motionPolyStruct;
        coordinateGapIndicators = ~logical([motionPolyStruct.rowPolyStatus]');
        transformationCadenceIndices = find(~coordinateGapIndicators);
        
        [directRow, directRowUncertainty, directColumn, directColumnUncertainty] = ...
            transform_kic_position_to_fpa_coordinates( ...
            targetRaDegrees, targetDecDegrees, motionPolyStruct, ...
            transformationCadenceIndices);
        
        % Loop over the planet candidates and create the images.
        for iPlanet = 1 : nPlanets
            
            % Get the planet results structure for the given planet candidate.
            planetResultsStruct = ...
                targetResultsStruct.planetResultsStruct(iPlanet);
            
            % Get the segment of the model light curve and the in and out
            % of transit cadences for the given target table and planet
            % candidate. Also save the in transit cadences for later
            % transformation of image centroids from focal plane to sky
            % coordinates.
            isInTransit = isInTransitArray(cadenceRange, iPlanet);
            isOutOfTransit = isOutOfTransitArray(cadenceRange, iPlanet);
            
            isCadenceForFpaToSkyTransformation = isInTransit;

            % Determine the numbers of in and out of transit cadences and
            % in and out of transit cadence gaps for the valid transits.
            % Some of this will be repeated later, but it is not possible
            % to know the number of cadence gaps specifically for the
            % valid remaining transits unless it is determined now before
            % the gaps are squeezed.
            if isValidFit(iPlanet)
                
                numberOfTransits = 0;
                numberOfCadencesInTransit = 0;
                numberOfCadenceGapsInTransit = 0;
                numberOfCadencesOutOfTransit = 0;
                numberOfCadenceGapsOutOfTransit = 0;
                
                mjdTimestamp = 0;
                timestamps = midTimestamps(cadenceRange);
                
                transitNumberWithBuffer = ...
                    transitNumberWithBufferArray(cadenceRange, iPlanet);
                transitNumbers = ...
                    unique(transitNumberWithBuffer(isOutOfTransit));
                
                transitNumber = ...
                    transitNumberArray(cadenceRange, iPlanet);
                noTransitsInTargetTable = all(transitNumber == 0);

                for iTransit = 1 : length(transitNumbers)

                    transitNumber = transitNumbers(iTransit);
                    transitCadenceIndicators = ...
                        transitNumberWithBuffer == transitNumber;

                    inTransitCadenceIndicators = ...
                        isInTransit & transitCadenceIndicators;
                    nCadencesInTransit = ...
                        sum(inTransitCadenceIndicators & ~gapIndicators);
                    nCadenceGapsInTransit = ...
                        sum(inTransitCadenceIndicators & gapIndicators);
                    
                    outOfTransitCadenceIndicators = ...
                        isOutOfTransit & transitCadenceIndicators;
                    nCadencesOutOfTransit = ...
                        sum(outOfTransitCadenceIndicators & ~gapIndicators);
                    nCadenceGapsOutOfTransit = ...
                        sum(outOfTransitCadenceIndicators & gapIndicators);

                    if nCadencesInTransit > 0 && ...
                            nCadencesOutOfTransit > 0
                        numberOfTransits = numberOfTransits + 1;
                        numberOfCadencesInTransit = ...
                            numberOfCadencesInTransit + nCadencesInTransit;
                        numberOfCadenceGapsInTransit = ...
                            numberOfCadenceGapsInTransit + nCadenceGapsInTransit;
                        numberOfCadencesOutOfTransit = ...
                            numberOfCadencesOutOfTransit + nCadencesOutOfTransit;
                        numberOfCadenceGapsOutOfTransit = ...
                            numberOfCadenceGapsOutOfTransit + nCadenceGapsOutOfTransit;
                        mjdTimestamp = mjdTimestamp + ...
                            sum(timestamps(inTransitCadenceIndicators & ~gapIndicators));
                    end % if
                    
                end % for iTransit
            
                if numberOfCadencesInTransit > 0
                    mjdTimestamp = mjdTimestamp / numberOfCadencesInTransit;
                end % if
                
            end % if isValidFit(iPlanet)
                
            % Attempt to generate a difference image if the fit succeeded
            % and there *appears* to be at least one observed transit in
            % the given target table. Ignore gaps.
            isInTransit = isInTransit(~gapIndicators);
            isOutOfTransit = isOutOfTransit(~gapIndicators);

            nCadencesInTransit = sum(isInTransit);
            nCadencesOutOfTransit = sum(isOutOfTransit);

            differenceImageGenerated = false;
            
            if isValidFit(iPlanet) && nCadencesInTransit > 0 && ...
                    nCadencesOutOfTransit > 0
                
                % Compute the mean flux in and out of transit on a per
                % transit basis. First identify the transit numbers.
                transitNumberWithBuffer = ...
                    transitNumberWithBufferArray(cadenceRange, iPlanet);
                transitNumberWithBuffer = transitNumberWithBuffer(~gapIndicators);
                transitNumbers = unique(transitNumberWithBuffer(isOutOfTransit));
                
                % Loop over the transits and compute the mean flux in and
                % out of transit for each. Also compute the respective
                % uncertainties. Note the transits for which there was not
                % at least one valid data point in and out of transit.
                % These will not be included in the difference image.
                % Generate diagnostic figure marking in- and out-of-transit
                % cadences and per transit in- and out-of-transit flux
                % values for each pixel time series.
                close;
                
                if pixelTimeSeriesFiguresEnabled
                    h = plot(detrendedPixelValues, '.-');
                    n = size(detrendedPixelValues, 1);
                    hold on
                    for iPixel = 1 : length(h)
                        color = get(h(iPixel), 'Color');
                        if inOptimalAperture(iPixel)
                            string = sprintf('R%d / C%d / OA', ...
                                ccdRows(iPixel), ccdColumns(iPixel));
                        else
                            string = sprintf('R%d / C%d', ...
                                ccdRows(iPixel), ccdColumns(iPixel));
                        end % if / else
                        text(n+10.0, detrendedPixelValues(n, iPixel), ...
                            string, 'Color', color);
                    end % for iPixel
                    clear h n
                    plot(find(isInTransit), detrendedPixelValues(isInTransit, : ), 'or');
                    plot(find(isOutOfTransit), detrendedPixelValues(isOutOfTransit, : ), 'og');
                end % if
                
                nTransits = length(transitNumbers);
                
                meanFluxInTransitByTransit = zeros([nTransits, nPixels]);
                meanFluxInTransitByTransitUncertainty = zeros([nTransits, nPixels]);
                meanFluxOutOfTransitByTransit = zeros([nTransits, nPixels]);
                meanFluxOutOfTransitByTransitUncertainty = zeros([nTransits, nPixels]);
                
                isValidTransit = true([nTransits, 1]);
                
                for iTransit = 1 : nTransits
                    
                    transitNumber = transitNumbers(iTransit);
                    transitCadenceIndicators = ...
                        transitNumberWithBuffer == transitNumber;
                    
                    inTransitCadenceIndicators = ...
                        isInTransit & transitCadenceIndicators;
                    nCadencesInTransit = sum(inTransitCadenceIndicators);
                    outOfTransitCadenceIndicators = ...
                        isOutOfTransit & transitCadenceIndicators;
                    nCadencesOutOfTransit = sum(outOfTransitCadenceIndicators);
                    
                    if nCadencesInTransit > 0 && nCadencesOutOfTransit > 0
                        
                        meanFluxInTransitByTransit(iTransit, : ) = ...
                            mean(detrendedPixelValues(inTransitCadenceIndicators, : ), 1);
                        meanFluxInTransitByTransitUncertainty(iTransit, : ) = sqrt( ...
                            sum(pixelUncertainties(inTransitCadenceIndicators, : ) .^ 2, 1) / ...
                            nCadencesInTransit ^ 2);

                        meanFluxOutOfTransitByTransit(iTransit, : ) = ...
                            mean(detrendedPixelValues(outOfTransitCadenceIndicators, : ), 1);
                        meanFluxOutOfTransitByTransitUncertainty(iTransit, : ) = sqrt( ...
                            sum(pixelUncertainties(outOfTransitCadenceIndicators, : ) .^ 2, 1) / ...
                            nCadencesOutOfTransit ^ 2);
                        
                    else
                    
                        isValidTransit(iTransit) = false;
                        
                    end % if / else
                    
                    if pixelTimeSeriesFiguresEnabled && isValidTransit(iTransit)
                        
                        inTransitFlux = meanFluxInTransitByTransit(iTransit, : );
                        inTransitFluxUncertainty = meanFluxInTransitByTransitUncertainty(iTransit, : );
                        plot(find(inTransitCadenceIndicators), repmat(inTransitFlux, ...
                            [sum(inTransitCadenceIndicators), 1]), '--r');
                        plot(find(inTransitCadenceIndicators), repmat(inTransitFlux+inTransitFluxUncertainty, ...
                            [sum(inTransitCadenceIndicators), 1]), '--k');
                        plot(find(inTransitCadenceIndicators), repmat(inTransitFlux-inTransitFluxUncertainty, ...
                            [sum(inTransitCadenceIndicators), 1]), '-.k');
                        outOfTransitFlux = meanFluxOutOfTransitByTransit(iTransit, : );
                        outOfTransitFluxUncertainty = meanFluxOutOfTransitByTransitUncertainty(iTransit, : );
                        plot(find(outOfTransitCadenceIndicators), repmat(outOfTransitFlux, ...
                            [sum(outOfTransitCadenceIndicators), 1]), '--g');
                        plot(find(outOfTransitCadenceIndicators), repmat(outOfTransitFlux+outOfTransitFluxUncertainty, ...
                            [sum(outOfTransitCadenceIndicators), 1]), '--k');
                        plot(find(outOfTransitCadenceIndicators), repmat(outOfTransitFlux-outOfTransitFluxUncertainty, ...
                            [sum(outOfTransitCadenceIndicators), 1]), '-.k');
                        
                        clear inTransitFlux inTransitFluxUncertainty
                        clear outOfTransitFlux outOfTransitFluxUncertainty
            
                    end % if
                    
                end % for iTransit
                
                % Compute the overall mean in and out of transit flux and
                % the difference (out of transit minus in transit). Also
                % compute the associated uncertainties. Squeeze out any
                % transit "results" for which there were not valid samples
                % in and out of transit.
                nTransits = sum(isValidTransit);
                
                if nTransits > 0
                    
                    meanFluxInTransitByTransit = ...
                        meanFluxInTransitByTransit(isValidTransit, : );
                    meanFluxInTransitByTransitUncertainty = ...
                        meanFluxInTransitByTransitUncertainty(isValidTransit, : );
                    meanFluxOutOfTransitByTransit = ...
                        meanFluxOutOfTransitByTransit(isValidTransit, : );
                    meanFluxOutOfTransitByTransitUncertainty = ...
                        meanFluxOutOfTransitByTransitUncertainty(isValidTransit, : );

                    meanFluxInTransit = mean(meanFluxInTransitByTransit, 1);
                    meanFluxInTransitUncertainty = sqrt( ...
                        sum(meanFluxInTransitByTransitUncertainty .^ 2, 1) / nTransits ^ 2);

                    meanFluxOutOfTransit = mean(meanFluxOutOfTransitByTransit, 1);
                    meanFluxOutOfTransitUncertainty = sqrt( ...
                        sum(meanFluxOutOfTransitByTransitUncertainty .^ 2, 1) / nTransits ^ 2);

                    meanFluxDifference = meanFluxOutOfTransit - meanFluxInTransit;
                    meanFluxDifferenceUncertainty = sqrt( ...
                        meanFluxOutOfTransitUncertainty .^ 2 + ...
                        meanFluxInTransitUncertainty .^ 2);
                    
                    meanFluxForTargetTable = mean(detrendedPixelValues, 1);
                    meanFluxForTargetTableUncertainty = sqrt( ...
                        sum(pixelUncertainties .^ 2, 1) / ...
                        size(pixelUncertainties, 1) ^ 2);
                    
                    if pixelTimeSeriesFiguresEnabled
                        
                        plot(repmat(meanFluxInTransit, [size(detrendedPixelValues, 1), 1]), '--r');
                        plot(repmat(meanFluxInTransit+meanFluxInTransitUncertainty, ...
                            [size(detrendedPixelValues, 1), 1]), '--k');
                        plot(repmat(meanFluxInTransit-meanFluxInTransitUncertainty, ...
                            [size(detrendedPixelValues, 1), 1]), '-.k');
                        plot(repmat(meanFluxOutOfTransit, [size(detrendedPixelValues, 1), 1]), '--g');
                        plot(repmat(meanFluxOutOfTransit+meanFluxOutOfTransitUncertainty, ...
                            [size(detrendedPixelValues, 1), 1]), '--k');
                        plot(repmat(meanFluxOutOfTransit-meanFluxOutOfTransitUncertainty, ...
                            [size(detrendedPixelValues, 1), 1]), '-.k');
                        
                        title({'Pixel Time Series'; 
                            ['Planet Candidate ', num2str(iPlanet), ...
                            ' / Quarter ', num2str(targetTableQuarter), ' / Target Table ', ...
                            num2str(targetTableId)]});
                        xlabel('Relative Cadence Number (after squeezing of gaps)');
                        ylabel('Flux (e-/cadence)');
                        
                        figureName = [rootDir, ...
                            sprintf('/planet-%02d', iPlanet), ...
                            '/difference-image/', num2str(keplerId, '%09d'), '-', ...
                            num2str(iPlanet, '%02d'), '-pixel-time-series-', num2str(targetTableQuarter, '%02d'), ...
                            '-', num2str(targetTableId, '%03d')];
                        saveas(gcf, figureName);
                        
                    end % if pixelTimeSeriesFiguresEnabled

                    % Save the image results by pixel for the given target
                    % table.
                    differenceImageResults = ...
                        planetResultsStruct.differenceImageResults(iTable);
                    differenceImagePixelStruct = ...
                        differenceImageResults.differenceImagePixelStruct;
                    
                    for iPixel = 1 : nPixels
                        
                        differenceImagePixelStruct(iPixel).meanFluxInTransit.value = ...
                            meanFluxInTransit(iPixel);
                        differenceImagePixelStruct(iPixel).meanFluxInTransit.uncertainty = ...
                            meanFluxInTransitUncertainty(iPixel);
                        
                        differenceImagePixelStruct(iPixel).meanFluxOutOfTransit.value = ...
                            meanFluxOutOfTransit(iPixel);
                        differenceImagePixelStruct(iPixel).meanFluxOutOfTransit.uncertainty = ...
                            meanFluxOutOfTransitUncertainty(iPixel);
                        
                        differenceImagePixelStruct(iPixel).meanFluxDifference.value = ...
                            meanFluxDifference(iPixel);
                        differenceImagePixelStruct(iPixel).meanFluxDifference.uncertainty = ...
                            meanFluxDifferenceUncertainty(iPixel);
                        
                        differenceImagePixelStruct(iPixel).meanFluxForTargetTable.value = ...
                            meanFluxForTargetTable(iPixel);
                        differenceImagePixelStruct(iPixel).meanFluxForTargetTable.uncertainty = ...
                            meanFluxForTargetTableUncertainty(iPixel);
                        
                    end % for iPixel
                    
                    differenceImageResults.differenceImagePixelStruct = ...
                        differenceImagePixelStruct;
                    differenceImageResults.numberOfTransits = ...
                        numberOfTransits;
                    differenceImageResults.numberOfCadencesInTransit = ...
                        numberOfCadencesInTransit;
                    differenceImageResults.numberOfCadenceGapsInTransit = ...
                        numberOfCadenceGapsInTransit;
                    differenceImageResults.numberOfCadencesOutOfTransit = ...
                        numberOfCadencesOutOfTransit;
                    differenceImageResults.numberOfCadenceGapsOutOfTransit = ...
                        numberOfCadenceGapsOutOfTransit;
                    differenceImageResults.mjdTimestamp = mjdTimestamp;
                    
                    % Save the KIC reference position in sky coordinates.
                    % Assume that the uncertainties in RA/DEC are
                    % identically equal to zero (as per JJ).
                    if ~isnan(targetRaDegrees) && ~isnan(targetDecDegrees)                    
                        differenceImageResults.kicReferenceCentroid.raHours.value = ...
                            targetRaHours;
                        differenceImageResults.kicReferenceCentroid.raHours.uncertainty = ...
                            0;
                        differenceImageResults.kicReferenceCentroid.decDegrees.value = ...
                            targetDecDegrees;
                        differenceImageResults.kicReferenceCentroid.decDegrees.uncertainty = ...
                            0;
                        differenceImageResults.kicReferenceCentroid.raDecCovariance = ...
                            zeros([2, 2]);                      
                    end % if
                        
                    % Perform PRF-based centroiding and offset analysis on
                    % mean out of transit (i.e. "control") and difference
                    % images if the models are available. Also determine
                    % the KIC reference position of the target on the in
                    % transit cadences and repeat the difference image 
                    % offset analysis with respect to that position.
                    if ~isempty(dvDataObject.prfModels)
                        [differenceImageResults] = ...
                            perform_dv_difference_image_centroiding_and_offset_analysis( ...
                            dvDataObject, differenceImageResults, prfObject, ...
                            isCadenceForFpaToSkyTransformation);
                    end % if
                    
                    % Update the planet and target results structures.
                    planetResultsStruct.differenceImageResults(iTable) = ...
                        differenceImageResults;
                    targetResultsStruct.planetResultsStruct(iPlanet) = ...
                        planetResultsStruct;
                    
                    % Create the difference image subplots. Overlay the
                    % KIC reference position and image centroids where
                    % applicable. Mark the nearby KIC objects. Note that
                    % the centroid coordinates must be converted to a
                    % 0-based system.
                    kicReferenceCentroid = ...
                        differenceImageResults.kicReferenceCentroid;
                    [locationOfObjectsInBoundingBox] = ...
                        locate_nearby_kic_objects(keplerId, kics, ...
                        motionPolyStruct, kicReferenceCentroid, ...
                        [minRow; maxRow], [minCol; maxCol]);
                    
                    close;
                    
                    if differenceImageResults.differenceImageCentroid.row.uncertainty ~= GAP_VALUE
                        differenceCentroidRow = ...
                            differenceImageResults.differenceImageCentroid.row.value - 1;
                    else
                        differenceCentroidRow = NaN;
                    end % if / else
                    if differenceImageResults.differenceImageCentroid.column.uncertainty ~= GAP_VALUE
                        differenceCentroidColumn = ...
                            differenceImageResults.differenceImageCentroid.column.value - 1;
                    else
                        differenceCentroidColumn = NaN;
                    end % if / else
                    
                    if differenceImageResults.controlImageCentroid.row.uncertainty ~= GAP_VALUE
                        controlCentroidRow = ...
                            differenceImageResults.controlImageCentroid.row.value - 1;
                    else
                        controlCentroidRow = NaN;
                    end % if / else
                    if differenceImageResults.controlImageCentroid.column.uncertainty ~= GAP_VALUE
                        controlCentroidColumn = ...
                            differenceImageResults.controlImageCentroid.column.value - 1;
                    else
                        controlCentroidColumn = NaN;
                    end % if / else

                    difference_image_subplot(221, nRows, nColumns, ...
                        [minRow; maxRow], [minCol; maxCol], ccdRows, ccdColumns, ...
                        inOptimalAperture, aperturePixelIndices, ...
                        meanFluxDifference, 'Difference Flux (e-/cadence)', ...
                        locationOfObjectsInBoundingBox, controlCentroidRow, controlCentroidColumn, ...
                        differenceCentroidRow, differenceCentroidColumn);
                    set(gca, 'position', [0.1, 0.53, 0.27, 0.32]);

                    difference_image_subplot(222, nRows, nColumns, ...
                        [minRow; maxRow], [minCol; maxCol], ccdRows, ccdColumns, ...
                        inOptimalAperture, aperturePixelIndices, ...
                        meanFluxOutOfTransit, 'Out of Transit Flux (e-/cadence)', ...
                        locationOfObjectsInBoundingBox, controlCentroidRow, controlCentroidColumn, ...
                        differenceCentroidRow, differenceCentroidColumn);
                    set(gca,'position', [0.58, 0.53, 0.27, 0.32]);

                    difference_image_subplot(223, nRows, nColumns, ...
                        [minRow; maxRow], [minCol; maxCol], ccdRows, ccdColumns, ...
                        inOptimalAperture, aperturePixelIndices, ...
                        meanFluxInTransit, 'In Transit Flux (e-/cadence)', ...
                        locationOfObjectsInBoundingBox);
                    set(gca,'position', [0.1, 0.09, 0.27, 0.32]);
                    
                    difference_image_subplot(224, nRows, nColumns, ...
                        [minRow; maxRow], [minCol; maxCol], ccdRows, ccdColumns, ...
                        inOptimalAperture, aperturePixelIndices, ...
                        meanFluxDifference ./ meanFluxDifferenceUncertainty, ...
                        'Difference SNR', locationOfObjectsInBoundingBox);
                    set(gca, 'position', [0.58, 0.09, 0.27, 0.32]);
                    
                    mainTitle = 'Difference Image';
                    
                    % Generate a detailed caption for the figure.
                    qualityMetric = differenceImageResults.qualityMetric;
                    
                    if qualityMetric.valid
                        if qualityMetric.value > qualityThreshold
                            qualityString = [num2str(qualityMetric.value, '%.2f'), ...
                                ' (good).'];
                        else
                            qualityString = [num2str(qualityMetric.value, '%.2f'), ...
                                ' (not good).'];
                        end % if / else
                    else
                        qualityString = 'N/A.';
                    end % if / else
                    
                    overlappedTransits = differenceImageResults.overlappedTransits;
                    
                    if overlappedTransits
                        overlapString = ' Transits used to compute this difference image are overlapped by those of other candidates on this target.';
                    else
                        overlapString = '';
                    end
                    
                    caption = ['Difference image for target ', num2str(keplerId), ', planet candidate ', num2str(iPlanet), ...
                        ', quarter ', num2str(targetTableQuarter), ', target table ', num2str(targetTableId),  '. ', ...
                        'Upper left: difference between mean flux out-of-transit and in-transit; ', ...
                        'upper right: mean out-of-transit flux; ', ...
                        'lower left: mean in-transit flux; ', ...
                        'lower right: difference between mean flux out-of-transit and in-transit after normalizing by the uncertainty in the difference for each pixel. ', ...
                        'The optimal aperture is outlined with a white dash-dotted line in each panel and the target mask is outlined with a solid white line. ', ...
                        'Symbol key: ', ...
                        'x: target position from KIC RA and Dec converted to CCD coordinates via motion polynomials; ', ...
                        '*: position of nearby KIC objects converted to CCD coordinates via motion polynomials (objects in the UKIRT extension ', ...
                        'to the KIC have IDs between 15,000,000 and 30,000,000); ', ...
                        '+: PRF-fit location of target from out-of-transit image; ', ...
                        'triangle: PRF-fit location of transit source from the difference image. ', ...
                        'CCD row and column coordinates are 0-based. Number of transits = ', num2str(numberOfTransits), '; number of valid in-transit cadences = ', num2str(numberOfCadencesInTransit), ...
                        '; number of in-transit cadence gaps = ', num2str(numberOfCadenceGapsInTransit), '; number of valid out-of-transit cadences = ', num2str(numberOfCadencesOutOfTransit), ...
                        '; number of out-of-transit cadence gaps = ', num2str(numberOfCadenceGapsOutOfTransit), ...
                        '. Difference image quality metric = ', qualityString, overlapString];
                    
                    % Note that a difference image has been generated.
                    differenceImageGenerated = true;
                    
                end % if nTransits > 0
                
                clear meanFluxInTransitByTransit meanFluxInTransitByTransitUncertainty
                clear meanFluxOutOfTransitByTransit meanFluxOutOfTransitByTransitUncertainty
                
            end % if
            
            % Generate a direct image if the fit did not succeed for the
            % given planet candidate or there were no (clean) observed
            % transits in the given target table.
            if ~differenceImageGenerated
                
                % Compute the mean flux and associated uncertainties over
                % all cadences.
                meanFluxForTargetTable = mean(detrendedPixelValues, 1);
                meanFluxForTargetTableUncertainty = sqrt( ...
                    sum(pixelUncertainties .^ 2, 1) / ...
                    size(pixelUncertainties, 1) ^ 2);
                
                % Save the image results by pixel for the given target
                % table. Make sure that the overlapped transits flag is set
                % to false because a difference image could not be
                % produced.
                differenceImageResults = ...
                    planetResultsStruct.differenceImageResults(iTable);
                differenceImagePixelStruct = ...
                    differenceImageResults.differenceImagePixelStruct;
                
                for iPixel = 1 : nPixels

                    differenceImagePixelStruct(iPixel).meanFluxForTargetTable.value = ...
                        meanFluxForTargetTable(iPixel);
                    differenceImagePixelStruct(iPixel).meanFluxForTargetTable.uncertainty = ...
                        meanFluxForTargetTableUncertainty(iPixel);

                end % for iPixel
                
                differenceImageResults.overlappedTransits = false;

                differenceImageResults.differenceImagePixelStruct = ...
                    differenceImagePixelStruct;
                planetResultsStruct.differenceImageResults(iTable) = ...
                    differenceImageResults;
                targetResultsStruct.planetResultsStruct(iPlanet) = ...
                    planetResultsStruct;
                
                % Create the direct image plot.
                row = struct( ...
                    'value', directRow, ...
                    'uncertainty', directRowUncertainty);
                column = struct( ...
                    'value', directColumn, ...
                    'uncertainty', directColumnUncertainty);
                referenceCentroid = struct( ...
                    'transformationCadenceIndices', find(~coordinateGapIndicators), ...
                    'row', row, ...
                    'column', column);
                
                [locationOfObjectsInBoundingBox] = ...
                    locate_nearby_kic_objects(keplerId, kics, ...
                    motionPolyStruct, referenceCentroid, ...
                    [minRow; maxRow], [minCol; maxCol]);
                
                close;
                
                difference_image_subplot(111, nRows, nColumns, ...
                    [minRow; maxRow], [minCol; maxCol], ccdRows, ccdColumns, ...
                    inOptimalAperture, aperturePixelIndices, ...
                    meanFluxForTargetTable, 'Mean Flux (e-/cadence)', ...
                    locationOfObjectsInBoundingBox);
                set(gca,'position', [0.15, 0.12, 0.7, 0.75])
                    
                mainTitle = 'Direct Image';
                
                % Generate a detailed caption for the figure depending upon
                % whether there was not a successful fit or there were no
                % observed transits.
                if ~isValidFit(iPlanet)
                    caption = ['Direct image for target ', num2str(keplerId), ', planet candidate ', num2str(iPlanet), ...
                        ', quarter ', num2str(targetTableQuarter), ', target table ', num2str(targetTableId),  '. ', ...
                        'A difference image cannot be generated because there was not a successful model fit for this planet candidate. ', ...
                        'The mean flux over all cadences is shown in the figure. ', ...
                        'The optimal aperture is outlined with a white dash-dotted line and the target mask is outlined with a solid white line. ', ...
                        'Symbol key: ', ...
                        'x: target position from KIC RA and Dec converted to CCD coordinates via motion polynomials; ', ...
                        '*: position of nearby KIC objects converted to CCD coordinates via motion polynomials (objects in the UKIRT extension ', ...
                        'to the KIC have IDs between 15,000,000 and 30,000,000). ', ...
                        'CCD row and column coordinates are 0-based.'];
                    string = 'Difference image cannot be generated because there was not a successful model fit for this planet candidate';  
                    [dvResultsStruct] = add_dv_alert(dvResultsStruct, 'generateDvDifferenceImages', ...
                        'warning', string, iTarget, keplerId, iPlanet, targetTableId);
                    disp(dvResultsStruct.alerts(end).message);
                elseif noTransitsInTargetTable
                    caption = ['Direct image for target ', num2str(keplerId), ', planet candidate ', num2str(iPlanet), ...
                        ', quarter ', num2str(targetTableQuarter), ', target table ', num2str(targetTableId),  '. ', ...
                        'A difference image cannot be generated because there were no transits for this planet candidate and target table. ', ...
                        'The mean flux over all cadences is shown in the figure. ', ...
                        'The optimal aperture is outlined with a white dash-dotted line and the target mask is outlined with a solid white line. ', ...
                        'Symbol key: ', ...
                        'x: target position from KIC RA and Dec converted to CCD coordinates via motion polynomials; ', ...
                        '*: position of nearby KIC objects converted to CCD coordinates via motion polynomials (objects in the UKIRT extension ', ...
                        'to the KIC have IDs between 15,000,000 and 30,000,000). ', ...
                        'CCD row and column coordinates are 0-based.'];
                    string = 'Difference image cannot be generated because there were no transits for this planet candidate and target table';  
                    [dvResultsStruct] = add_dv_alert(dvResultsStruct, 'generateDvDifferenceImages', ...
                        'warning', string, iTarget, keplerId, iPlanet, targetTableId);
                    disp(dvResultsStruct.alerts(end).message);
                else
                    caption = ['Direct image for target ', num2str(keplerId), ', planet candidate ', num2str(iPlanet), ...
                        ', quarter ', num2str(targetTableQuarter), ', target table ', num2str(targetTableId),  '. ', ...
                        'A difference image cannot be generated because there were no clean transits for this planet candidate and target table. ', ...
                        'The mean flux over all cadences is shown in the figure. ', ...
                        'The optimal aperture is outlined with a white dash-dotted line and the target mask is outlined with a solid white line. ', ...
                        'Symbol key: ', ...
                        'x: target position from KIC RA and Dec converted to CCD coordinates via motion polynomials; ', ...
                        '*: position of nearby KIC objects converted to CCD coordinates via motion polynomials (objects in the UKIRT extension ', ...
                        'to the KIC have IDs between 15,000,000 and 30,000,000). ', ...
                        'CCD row and column coordinates are 0-based.'];
                    string = 'Difference image cannot be generated because there were no clean transits for this planet candidate and target table';  
                    [dvResultsStruct] = add_dv_alert(dvResultsStruct, 'generateDvDifferenceImages', ...
                        'warning', string, iTarget, keplerId, iPlanet, targetTableId);
                    disp(dvResultsStruct.alerts(end).message);
                end % if / elseif / else
                
            end % if ~differenceImageGenerated
                
            % Add title and caption.
            axes('position', [0.1, 0.85, 0.8, .05], 'Box', 'off', 'Visible', 'off');
            title({mainTitle;
                ['Planet Candidate ', num2str(iPlanet), ' / Quarter ', num2str(targetTableQuarter), ' / Target Table ', num2str(targetTableId)]});
            set(get(gca, 'Title'), 'Visible', 'on');
            set(get(gca, 'Title'), 'FontWeight', 'bold');
            set(gcf, 'UserData', caption);

            % Format figure to correct size and font.
            format_graphics_for_dv_report(gcf);

            % Save the figure.
            figureName = [rootDir, ...
                sprintf('/planet-%02d', iPlanet), ...
                '/difference-image/', num2str(keplerId, '%09d'), '-', ...
                num2str(iPlanet, '%02d'), '-difference-image-', num2str(targetTableQuarter, '%02d'), ...
                '-', num2str(targetTableId, '%03d')];
            saveas(gcf, figureName);
            
        end % for iPlanet
        
        % Clear large variables for the given target table that are no
        % longer needed.
        clear detrendedPixelValues pixelUncertainties prfObject
        
    end % for iTable
    
    % For each planet candidate, compute the robust weighted mean
    % difference image centroid offsets (on the sky) with respect to the
    % out of transit control centroids and the KIC reference coordinates.
    % Create two-panel subplots for each planet candidate.
    for iPlanet = 1 : nPlanets
        
        planetResultsStruct = ...
            targetResultsStruct.planetResultsStruct(iPlanet);
        
        differenceImageResults = ...
            planetResultsStruct.differenceImageResults;
        
        centroidResults = planetResultsStruct.centroidResults;
        differenceImageMotionResults = ...
            centroidResults.differenceImageMotionResults;
        mqKicCentroidOffsets = ...
            differenceImageMotionResults.mqKicCentroidOffsets;
        mqControlCentroidOffsets = ...
            differenceImageMotionResults.mqControlCentroidOffsets;
        
        qualityMetricArray = [differenceImageResults.qualityMetric];
        qualityMetricValid = [qualityMetricArray.valid]';
        qualityMetricValues = [qualityMetricArray.value]';
        
        if badQualityOffsetRemovalEnabled
            isBadQualityMetric = qualityMetricValid & ...
                qualityMetricValues <= qualityThreshold;
        else
            isBadQualityMetric = [];
        end % if
        
        [differenceImageMotionResults.mqKicCentroidOffsets] = ...
            compute_robust_weighted_mean_centroid_offsets( ...
            [differenceImageResults.kicCentroidOffsets], ...
            mqKicCentroidOffsets, mqOffsetConstantUncertainty, ...
            isBadQualityMetric);
        [differenceImageMotionResults.mqControlCentroidOffsets] = ...
            compute_robust_weighted_mean_centroid_offsets( ...
            [differenceImageResults.controlCentroidOffsets], ...
            mqControlCentroidOffsets, mqOffsetConstantUncertainty, ...
            isBadQualityMetric);
        
        fitResultsStruct = fitResultsStructArray(iPlanet);
        
        [differenceImageMotionResults, diagnostics, string] = ...
            perform_dv_difference_image_centroid_fit_and_offset_analysis( ...
            dvDataObject, differenceImageResults, differenceImageMotionResults, ...
            fitResultsStruct);                                                              %#ok<ASGLU>
        if ~isempty(string)
            [dvResultsStruct] = add_dv_alert(dvResultsStruct, 'generateDvDifferenceImages', ...
                'warning', string, iTarget, keplerId, iPlanet);
            disp(dvResultsStruct.alerts(end).message);
        end % if
        fileName = [rootDir, sprintf('/planet-%02d', iPlanet), ...
            '/difference-image/', num2str(keplerId, '%09d'), '-', ...
            num2str(iPlanet, '%02d'), '-prf-bootstrap-diagnostics.mat'];
        save(fileName, 'diagnostics'); 
        
        centroidResults.differenceImageMotionResults = ...
            differenceImageMotionResults;
        planetResultsStruct.centroidResults = centroidResults;
        targetResultsStruct.planetResultsStruct(iPlanet) = ...
            planetResultsStruct;
        
        close;
        
        [string] = plot_dv_centroid_offsets(rootDir, keplerId, iPlanet, ...
            kics, differenceImageResults, differenceImageMotionResults, ...
            'Difference Image', mqOffsetConstantUncertainty, ...
            ukirtImageFileName, isBadQualityMetric);
        if ~isempty(string)
            [dvResultsStruct] = add_dv_alert(dvResultsStruct, ...
                'generateDvDifferenceImages', 'warning', string, ...
                iTarget, keplerId, iPlanet);
            disp(dvResultsStruct.alerts(end).message);
        end % if / else
        
    end % for iPlanet
    
    % For each planet compute the summary quality and overlap metrics.
    for iPlanet = 1 : nPlanets
        
        planetResultsStruct = ...
            targetResultsStruct.planetResultsStruct(iPlanet);
        differenceImageResults = ...
            planetResultsStruct.differenceImageResults;
        centroidResults = planetResultsStruct.centroidResults;
        differenceImageMotionResults = ...
            centroidResults.differenceImageMotionResults;
        summaryQualityMetric = ...
            differenceImageMotionResults.summaryQualityMetric;
        summaryOverlapMetric = ...
            differenceImageMotionResults.summaryOverlapMetric;
        
        qualityMetricArray = [differenceImageResults.qualityMetric];
        qualityMetricAttempted = [qualityMetricArray.attempted];
        qualityMetricValid = [qualityMetricArray.valid];
        qualityMetricValues = [qualityMetricArray.value];
        qualityMetricValues = qualityMetricValues(qualityMetricValid);
        
        summaryQualityMetric.numberOfAttempts = ...
            sum(qualityMetricAttempted);
        if ~isempty(qualityMetricValues)
            summaryQualityMetric.numberOfMetrics = ...
                length(qualityMetricValues);
            summaryQualityMetric.numberOfGoodMetrics = ...
                sum(qualityMetricValues > qualityThreshold);
            summaryQualityMetric.fractionOfGoodMetrics = ...
                summaryQualityMetric.numberOfGoodMetrics / ...
                summaryQualityMetric.numberOfMetrics;
        end % if
        
        imageCount = summaryQualityMetric.numberOfAttempts;
        summaryOverlapMetric.imageCount = imageCount;
        if imageCount > 0
            overlaps = [differenceImageResults.overlappedTransits];
            imageCountOverlap = sum(overlaps);
            imageCountNoOverlap = imageCount - imageCountOverlap;
            summaryOverlapMetric.imageCountNoOverlap = imageCountNoOverlap;
            summaryOverlapMetric.imageCountFractionNoOverlap = ...
                imageCountNoOverlap / imageCount;
        end % if
        
        differenceImageMotionResults.summaryQualityMetric = ...
            summaryQualityMetric;
        differenceImageMotionResults.summaryOverlapMetric = ...
            summaryOverlapMetric;
        centroidResults.differenceImageMotionResults = ...
            differenceImageMotionResults;
        planetResultsStruct.centroidResults = centroidResults;
        targetResultsStruct.planetResultsStruct(iPlanet) = ...
            planetResultsStruct;
        
    end % for iPlanet
    
    % Update the results for the given target.
    dvResultsStruct.targetResultsStruct(iTarget) = targetResultsStruct;
    
    % Restore the default randstreams.
    if streams
        randStreams.restore_default();
    end % if
    
end % for iTarget

% Close last image.
close;

% Return.
return


function [bufferedAnomalyIndicators] = ...
buffer_anomaly_indicators(anomalyIndicatorsToBuffer, anomalyBufferCadences)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [bufferedAnomalyIndicators] = ...
% buffer_anomaly_indicators(anomalyIndicatorsToBuffer, anomalyBufferCadences)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Extend the indicated data anomalies by the specified number of cadences.
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

nCadences = length(anomalyIndicatorsToBuffer);

anomalyIndicatorsToBuffer = ...
    conv(double(anomalyIndicatorsToBuffer), ones([anomalyBufferCadences, 1]));
bufferedAnomalyIndicators = ...
    logical(anomalyIndicatorsToBuffer(1 : nCadences) > 0);

% Return.
return


function difference_image_subplot(mnp, nRows, nColumns, rowRange, columnRange, ...
ccdRows, ccdColumns, inOptimalAperture, aperturePixelIndices, values, ...
titleString, locationOfObjectsInBoundingBox, controlCentroidRow, controlCentroidColumn, ...
differenceCentroidRow, differenceCentroidColumn)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function difference_image_subplot(mnp, nRows, nColumns, rowRange, columnRange, ...
% ccdRows, ccdColumns, inOptimalAperture, aperturePixelIndices, values, ...
% titleString, locationOfObjectsInBoundingBox, controlCentroidRow, controlCentroidColumn, ...
% differenceCentroidRow, differenceCentroidColumn)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Create subplot for the DV report difference image. Overlay markers for
% the target and other nearby KIC object positions and the image centroids
% (if these optional arguments are specified). Note that all pixel and
% marker coordinates are assumed to be 0-based by this plotting function.
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

% Set constant.
PIXELS_TO_PAD = 0.5;

% Set the marker positions to NaN if the optional arguments are not
% specified.
if ~exist('controlCentroidRow', 'var')
    controlCentroidRow = NaN;
end % if

if ~exist('controlCentroidColumn', 'var')
    controlCentroidColumn = NaN;
end % if

if ~exist('differenceCentroidRow', 'var')
    differenceCentroidRow = NaN;
end % if

if ~exist('differenceCentroidColumn', 'var')
    differenceCentroidColumn = NaN;
end % if

% Print the image map for the given subplot. Clipping of negative values
% removed following 9.0 V&V run at SO request.
subplot(mnp);

aperturePixelValues = nan([nRows, nColumns]);
aperturePixelValues(aperturePixelIndices) = values;
imagesc(columnRange, rowRange, aperturePixelValues);
% minValue = min(aperturePixelValues( : ));
% maxValue = max(aperturePixelValues( : ));
% if maxValue > 0
%     caxis([0, maxValue]);
% else
%     caxis([minValue, maxValue]);
% end % if / else
set(gca, 'YDir', 'normal');
colorbar;

% Mark the target pixels in the optimal aperture and outside of the optimal
% aperture.
hold on

plot_aperture_outline(ccdRows, ccdColumns, inOptimalAperture, '-.w');
plot_aperture_outline(ccdRows, ccdColumns, true(size(inOptimalAperture)), '-w');

% Overlay the target and other KIC object positions.
minRow = min(rowRange);
maxRow = max(rowRange);
minColumn = min(columnRange);
maxColumn = max(columnRange);

for iKic = 1 : length(locationOfObjectsInBoundingBox)

    keplerId = locationOfObjectsInBoundingBox(iKic).keplerId;
    keplerMag = locationOfObjectsInBoundingBox(iKic).keplerMag;
    isPrimaryTarget = locationOfObjectsInBoundingBox(iKic).isPrimaryTarget;
    kicRow = locationOfObjectsInBoundingBox(iKic).zeroBasedRow;
    kicColumn = locationOfObjectsInBoundingBox(iKic).zeroBasedColumn;
    
    if kicRow >= minRow-PIXELS_TO_PAD && kicRow <= maxRow+PIXELS_TO_PAD && ...
            kicColumn >= minColumn-PIXELS_TO_PAD && kicColumn <= maxColumn+PIXELS_TO_PAD && ...
            keplerId >= 0
        if isPrimaryTarget
            plot(kicColumn, kicRow, 'xw', 'MarkerSize', 10, 'LineWidth', 1);
        else
            plot(kicColumn, kicRow, '*w', 'MarkerSize', 10, 'LineWidth', 1)
        end
        text(kicColumn, kicRow, [' ', num2str(keplerId), ', ', num2str(keplerMag, '%.3f')], 'Color', 'w');
    end % if

end % for iKic

% Overlay the optional image centroids.
if controlCentroidRow >= minRow-PIXELS_TO_PAD && controlCentroidRow <= maxRow+PIXELS_TO_PAD && ...
        controlCentroidColumn >= minColumn-PIXELS_TO_PAD && controlCentroidColumn <= maxColumn+PIXELS_TO_PAD
    plot(controlCentroidColumn, controlCentroidRow, '+w', 'MarkerSize', 10, 'LineWidth', 1);
end % if

if differenceCentroidRow >= minRow-PIXELS_TO_PAD && differenceCentroidRow <= maxRow+PIXELS_TO_PAD && ...
        differenceCentroidColumn >= minColumn-PIXELS_TO_PAD && differenceCentroidColumn <= maxColumn+PIXELS_TO_PAD
    plot(differenceCentroidColumn, differenceCentroidRow, '^w', 'MarkerSize', 8, 'LineWidth', 1);
end % if

% Overlay the N and E celestial axis markers.
plot_celestial_axis(locationOfObjectsInBoundingBox, -1, 'N', rowRange, columnRange);
plot_celestial_axis(locationOfObjectsInBoundingBox, -2, 'E', rowRange, columnRange);

% Print the title and axis labels.
title(titleString);
xlabel('CCD Column');
ylabel('CCD Row');

% Return.
return


function [bufferedTransitNumber] = ...
add_control_buffer(transitNumber, controlBufferInCadences)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [bufferedTransitNumber] = ...
% add_control_buffer(transitNumber, controlBufferInCadences)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Add buffer surrounding transits specified by the given number of
% cadences. This helps to ensure that in-transit samples are not used for
% computation of the out-of-transit pixel levels in the event that the
% model fit is not spot-on or there are transit timing variations.
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

% Loop over the transits and extend them by the specified number of
% cadences.
nTransits = max(transitNumber);
nCadences = length(transitNumber);
bufferedTransitNumber = zeros(size(transitNumber));

for iTransit = 1 : nTransits
    
    transitIndices = find(transitNumber == iTransit);
    
    minIndex = max(min(transitIndices) - controlBufferInCadences, 1);
    maxIndex = min(max(transitIndices) + controlBufferInCadences, nCadences);
    
    bufferedTransitNumber(minIndex : maxIndex) = iTransit;
    
end % for iTransit

% Return.
return
