function [dvResultsStruct] = perform_dv_pixel_correlation_tests(dvDataObject, dvResultsStruct)
%
% dvResultsStruct = perform_dv_pixel_correlation_tests(dvDataObject, dvResultsStruct);
% 
% INPUT:
% The targetDataStruct is an array of structs (one per target table) with the
%     following fields:
%
%                     targetTableId: [int]  target table ID
%                           quarter: [int]  index of observing quarter
%                         ccdModule: [int]  CCD module
%                         ccdOutput: [int]  CCD output
%                      startCadence: [int]  start cadence for target table
%                        endCadence: [int]  end cadence for target table
%                   labels: [string array]  target label strings
%          fluxFractionInAperture: [float]  flux fraction in aperture for
%                                           the given target and quarter
%                  crowdingMetric: [float]  crowding metric for the given target
%                                           and quarter
%              pixelDataFileName: [string]  SDF file with coordinates and time series for
%                                           all pixels in aperture mask for target table
%
%     pixelDataStruct is an array of structs (one per pixel in the aperture mask for
%     the given target and target table) that is loaded from the pixel data file with
%     the following fields:
%
%                            ccdRow: [int]  pixel row
%                         ccdColumn: [int]  pixel column
%             inOptimalAperture: [logical]  true if pixel is in optimal
%                                           stellar aperture
%           calibratedTimeSeries: [struct]  calibrated pixel time series, e-
%                                           target and table, pixels
%                cosmicRayEvents: [struct]  cosmic ray events for given pixel
%
%
% OUTPUT:
% The pixelCorrelationResults array is at the third level of the dvResultsStruct.
%
% dvResultsStruct.targetResultsStruct().pixelCorrelationResults
%
% pixelCorrelationResults is a struct array (one per target table) with the
%     following fields:
%
%                     targetTableId: [int]  target table ID
%                           quarter: [int]  index of observing quarter
%                         ccdModule: [int]  CCD module
%                         ccdOutput: [int]  CCD output
%                      startCadence: [int]  start cadence for target table
%                        endCadence: [int]  end cadence for target table
%         pixelCorrelationStatisticStruct:
%                           [struct array]  correlation statistics against transit
%                                           model for all pixels for given target table
%           kicReferenceCentroid: [struct]  KIC reference position for target/table
%           controlImageCentroid: [struct]  PRF-based centroid for out of transit image
%       correlationImageCentroid: [struct]  PRF-based centroid for correlation image
%             kicCentroidOffsets: [struct]  offsets between correlation image and KIC 
%                                           reference centroids
%         controlCentroidOffsets: [struct]  offsets between correlation and control image
%                                           centroids
%
%     pixelCorrelationStatisticStruct is an array of structs (one per pixel)
%     with the following fields:
%
%                            ccdRow: [int]  pixel row
%                         ccdColumn: [int]  pixel column
%                           value: [float]  value of correlation statistic
%                    significance: [float]  significance of correlation statistic
%
%     kicReferenceCentroid, controlImageCentroid and correlationImageCentroid are
%     structs with the following fields:
%
%                            row: [struct]  centroid row coordinate, 0-based pixels
%                         column: [struct]  centroid column coordinate, 0-based pixels
%                        raHours: [struct]  projected centroid right ascension, hours
%                     decDegrees: [struct]  projected centroid declination, degrees
%  rowColumnCovariance: [2x2 double array]  covariance matrix for focal plane centroid
%      raDecCovariance: [2x2 double array]  covariance matrix for sky centroid
%            transformationCadenceIndices:
%                              [int array]  indices of cadences within target table used
%                                           for focal plane to sky transformation
%
% Note: rowColumnCovariance, raDecCovariance and transformationCadenceIndices are not
%       persisted on the Java side.
%
%     kicCentroidOffsets and controlCentroidOffsets are structs with the
%     following fields:
%
%                      rowOffset: [struct]  row offset with respect to reference
%                                           centroid, pixels
%                   columnOffset: [struct]  column offset with respect to reference
%                                           centroid, pixels
%               focalPlaneOffset: [struct]  total FP offset with respect to reference 
%                                           centroid, pixels
%                       raOffset: [struct]  right ascension offset with respect to
%                                           reference centroid, arcseconds
%                      decOffset: [struct]  declination offset with respect to
%                                           reference centroid, arcseconds
%                      skyOffset: [struct]  total sky offset with respect to
%                                           reference centroid, arcseconds
%
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

% HARD CODE FOR NOW (8.2).
MAX_PIXELS_FOR_CORRELATION_TEST = 120;
MAGNITUDE_CUTOFF_FOR_CORRELATION_TEST = 11;
DV_BACKEND_PROCESSING_PER_TARGET_SECS = 3600;

% unit conversions
SECONDS_PER_MINUTE = get_unit_conversion('min2sec');

% parse fields from the dvDataObject
planetFitConfigurationStruct = dvDataObject.planetFitConfigurationStruct;
trapezoidalFitConfigurationStruct = dvDataObject.trapezoidalFitConfigurationStruct;
configMaps = dvDataObject.configMaps;
dataAnomalyIndicators = dvDataObject.dvCadenceTimes.dataAnomalyFlags;
raDec2PixModel = dvDataObject.raDec2PixModel;
mqOffsetConstantUncertainty = ...
    dvDataObject.differenceImageConfigurationStruct.mqOffsetConstantUncertainty;

% parse timeout parameters
taskTimeoutSecs = dvDataObject.taskTimeoutSecs;
refTime = dvDataObject.refTime;

% count targets
nTargets = length(dvResultsStruct.targetResultsStruct);


% extract centroidTestConfigurationStruct
centroidTestConfigurationStruct = dvDataObject.centroidTestConfigurationStruct;

% calculate and attach minutes per cadence
centroidTestConfigurationStruct.minutesPerCadence = nanmedian(get_long_cadence_period(configMapClass(configMaps))) / SECONDS_PER_MINUTE;

% extract pixelCorrerlationConfigurationStruct
pixelCorrelationConfigurationStruct = dvDataObject.pixelCorrelationConfigurationStruct;
timeoutPerTargetSeconds = pixelCorrelationConfigurationStruct.timeoutPerTargetSeconds;

% attach now as start time of test
pixelCorrelationConfigurationStruct.testStartTimeSeconds = clock;

% calculate time limit per target and return if insufficient time remaining
tLimitSecs = min(taskTimeoutSecs - etime(clock,refTime) - DV_BACKEND_PROCESSING_PER_TARGET_SECS .* nTargets, timeoutPerTargetSeconds .* nTargets);
if tLimitSecs < 0
    % add alert and return
    message = 'Insufficient processing time remaining. Returning default values.';
    for iTarget = 1 : nTargets
        [dvResultsStruct] = add_dv_alert(dvResultsStruct,...
            'Pixel correlation test', ...
            'warning', message, iTarget, ...
            dvResultsStruct.targetResultsStruct(iTarget).keplerId);
        disp(dvResultsStruct.alerts(end).message);
    end % for iTarget
    return;
else
    pixelCorrelationConfigurationStruct.tLimitSecs = tLimitSecs / nTargets;
end

% add other fields needed by centroid_test_iterative_whitener
pixelCorrelationConfigurationStruct.centroidModelFineMeshEnabled    = false;
pixelCorrelationConfigurationStruct.centroidModelFineMeshFactor     = centroidTestConfigurationStruct.centroidModelFineMeshFactor;
pixelCorrelationConfigurationStruct.padTransitCadences              = centroidTestConfigurationStruct.padTransitCadences;
pixelCorrelationConfigurationStruct.minimumPointsPerPlanet          = centroidTestConfigurationStruct.minimumPointsPerPlanet;

% unpack parameters                      
NUM_INDICES_TO_DISPLAY_IN_ALERTS = pixelCorrelationConfigurationStruct.numIndicesDisplayedInAlerts;               

% load conditioned ancillary data from local file containing single
% variable: conditionedAncillaryDataArray 
load(dvDataObject.conditionedAncillaryDataFile);

% instantiate a raDec2Pix object
raDec2PixObject = raDec2PixClass(raDec2PixModel,'one-based');


% ~~~~~~~~~~~~~~~~~~ set up detrending structures 
coarsePdcConfigurationStruct = struct('ccdModule',0, ...
                                      'ccdOutput',0, ...
                                      'cadenceTimes',dvDataObject.dvCadenceTimes, ...
                                      'pdcModuleParameters',dvDataObject.pdcConfigurationStruct,...
                                      'raDec2PixObject',raDec2PixObject,...
                                      'gapFillConfigurationStruct',dvDataObject.gapFillConfigurationStruct,...
                                      'harmonicsIdentificationConfigurationStruct',dvDataObject.pdcHarmonicsIdentificationConfigurationStruct);
                                  
detrendParamStruct = struct('ancillaryDesignMatrixConfigurationStruct',dvDataObject.ancillaryDesignMatrixConfigurationStruct, ...
                             'pdcConfigurationStruct',dvDataObject.pdcConfigurationStruct,...
                             'coarsePdcConfigurationStruct',coarsePdcConfigurationStruct,...
                             'saturationSegmentConfigurationStruct',dvDataObject.saturationSegmentConfigurationStruct,...
                             'gapFillConfigurationStruct',dvDataObject.gapFillConfigurationStruct,...
                             'tpsConfigurationStruct',dvDataObject.tpsConfigurationStruct);


% get the randstreams if they exist
streams = false;
fields = fieldnames(dvDataObject);
if any(strcmp('randStreamStruct', fields))
    randStreams = dvDataObject.randStreamStruct.pixelCorrelationTestRandStreams;
    streams = true;
end % if




% ~~~~~~~~~~~~~~~~~~ loop over targets
for iTarget = 1:nTargets
    
    % Parse data, results and alerts structures for this target
    % Add some fields to the target data struct which may or may not be needed
    targetStruct = dvDataObject.targetStruct(iTarget);
    targetResults = dvResultsStruct.targetResultsStruct(iTarget);
    targetStruct.debugLevel = dvDataObject.dvConfigurationStruct.debugLevel;
    targetStruct.targetIndex = iTarget;    
    keplerId = targetStruct.keplerId;
    keplerMag = targetStruct.keplerMag.value;
    ukirtImageFileName = targetStruct.ukirtImageFileName;
    
    % Determine whether or not to proceed for this target.
    maxPixels = 0;
    for iTable = 1:length(targetResults.planetResultsStruct(1).pixelCorrelationResults)
        nPixels = ...
            length(targetResults.planetResultsStruct(1).pixelCorrelationResults(iTable).pixelCorrelationStatisticStruct);
        maxPixels = max(nPixels, maxPixels);
    end % for iTable
    
    if maxPixels > MAX_PIXELS_FOR_CORRELATION_TEST && ...
            keplerMag < MAGNITUDE_CUTOFF_FOR_CORRELATION_TEST
        messageString = 'Pixel correlation test will not be performed for saturated target with large pixel mask(s).';
        [dvResultsStruct] = add_dv_alert(dvResultsStruct, 'Pixel correlation test', 'warning', ...
            messageString, targetStruct.targetIndex, keplerId);                            
        disp(dvResultsStruct.alerts(end).message);
        continue;
    end % if
    
    % Set target-specific randstreams
    if streams
        randStreams.set_default(keplerId);
    end % if
    
    % Parse alerts struct from dvResultsStruct. Place in two layer struct in order
    % to use directly in add_dv_alert
    alertsOnly = struct('alerts',dvResultsStruct.alerts);
    
    % begin processing this target
    disp(['Processing pixels for KeplerId = ',num2str(keplerId)]);    

    % loop over target data structs (one for each target table)
    nTargetTables = length(targetStruct.targetDataStruct);
    for iTable = 1:nTargetTables
        
        % check that transit fit is available for at least one planet - if not, skip to next table
        allTransitsFitArray = [targetResults.planetResultsStruct.allTransitsFit];
        transitModelsChiSquare = [allTransitsFitArray.modelChiSquare];
        trapezoidalFitArray = [targetResults.planetResultsStruct.trapezoidalFit];
        trapezoidalModelsChiSquare = [trapezoidalFitArray.modelChiSquare];
        if isequal(transitModelsChiSquare, -ones(size(transitModelsChiSquare))) && ...
               isequal(trapezoidalModelsChiSquare, -ones(size(trapezoidalModelsChiSquare)))
            allPlanetModelFitsFailed = true;
        else
            allPlanetModelFitsFailed = false;
        end


        if ~allPlanetModelFitsFailed
            
            % get the PRF model for the given target table and instantiate
            % a PRF collection class object
            if ~isempty(dvDataObject.prfModels)
                
                targetTableCcdModule = ...
                    targetStruct.targetDataStruct(iTable).ccdModule;
                targetTableCcdOutput = ...
                    targetStruct.targetDataStruct(iTable).ccdOutput;

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
                    end
                    [prfObject] = ...
                        prfCollectionClass(prfModel, dvDataObject.fcConstants);
                    clear prfStruct prfModel
                else
                    error('DV:performDvPixelCorrelationTests', ...
                        'PRF for module %d output %d is not present in DV inputs', ...
                        targetTableCcdModule, targetTableCcdOutput);
                end

            end
            
            % parse cadence indices from object
            cadenceNumbers = dvDataObject.dvCadenceTimes.cadenceNumbers;
            startCadence = targetStruct.targetDataStruct(iTable).startCadence;
            endCadence = targetStruct.targetDataStruct(iTable).endCadence;
            
            % Build barycentric time structure for this target and this table
            validCadences = cadenceNumbers >= startCadence & cadenceNumbers <= endCadence;
            
            barycentricTimeStruct = struct('values',dvDataObject.barycentricCadenceTimes(iTarget).midTimestamps(validCadences),...
                                   'gapIndicators',dvDataObject.barycentricCadenceTimes(iTarget).gapIndicators(validCadences),...
                                   'quarters',dvDataObject.dvCadenceTimes.quarters(validCadences));
                        
            % detrend all pixels at once against ancillary data and DVA
            disp(['     Detrending pixels for target table ',num2str(targetStruct.targetDataStruct(iTable).targetTableId)]);
            detrendedPixels = detrend_pixel_timeseries(conditionedAncillaryDataArray,...
                                                        targetStruct.targetDataStruct(iTable),...
                                                        detrendParamStruct,...
                                                        dataAnomalyIndicators);
            nPixels = length(detrendedPixels);

            % ~~~~~~~~~~~~~~~~~~~~~~~ develop pixel correlation statistics

            disp(['     Performing iterative whitening for ',num2str(nPixels),' pixels.']);
            whitenerResultsStruct = [];

            allCadencesGapped = false(nPixels,1);
            whitenerResultsUnavailable = true(nPixels,1);
            whitenerConverged = false(nPixels,1);

            pixelRows = [targetResults.planetResultsStruct(1).pixelCorrelationResults(iTable).pixelCorrelationStatisticStruct.ccdRow];
            pixelColumns = [targetResults.planetResultsStruct(1).pixelCorrelationResults(iTable).pixelCorrelationStatisticStruct.ccdColumn];

            for iPixel = 1:nPixels

                % Make detrended pixel time series look like centroids with dec time series all gapped so we can use the
                % centroid_test_iterative_whitener to produce fit coefficients and correlation statistics.
                centroidStruct.ra = detrendedPixels(iPixel);
                centroidStruct.dec = centroidStruct.ra;
                centroidStruct.dec.gapIndicators = true(size(centroidStruct.dec.gapIndicators));


                % do the tests if data is not all gapped otherwise throw alert
                if( all(centroidStruct.ra.gapIndicators) )
                    allCadencesGapped(iPixel) = true;
                else

                    % centroidType = 'none' since pixel time series rather than centroid time
                    % series are being processed using the centroid test iterative whitener
                    centroidType = 'none';
                    typeNoneIdentifier = ['row [',num2str(pixelRows(iPixel)),'], column [',num2str(pixelColumns(iPixel)),']'];

                    % develop correlation statistic
                    [whitenerResultsStruct, alertsOnly] = ...
                            centroid_test_iterative_whitener(whitenerResultsStruct,...
                                                                centroidStruct,...
                                                                targetStruct,...
                                                                targetResults,...
                                                                planetFitConfigurationStruct,...
                                                                trapezoidalFitConfigurationStruct,...
                                                                configMaps,...
                                                                detrendParamStruct,...
                                                                barycentricTimeStruct,...
                                                                pixelCorrelationConfigurationStruct,...
                                                                centroidType,...                                                                
                                                                typeNoneIdentifier,...
                                                                alertsOnly);
                                                            
                    % break iPixel for-loop if timeout in iterative whitener
                    if whitenerResultsStruct.timeoutTriggered
                        break;
                    end
            
                    % if whitener results available for ra dimension reset flag
                    if ~isempty(whitenerResultsStruct.ra.whitenedResidual)
                        whitenerResultsUnavailable(iPixel) = false;
                        whitenerConverged(iPixel) = whitenerResultsStruct.ra.converged;                    

                        if whitenerConverged(iPixel)
                            % determine significance
                            [targetResults, alertsOnly] = ...
                                    generate_dv_pixel_detection_statistic(whitenerResultsStruct,...
                                                                            targetResults,...
                                                                            iTable,...
                                                                            iPixel,...
                                                                            alertsOnly);
                        end
                    end
                end
            end        

            % break iTable for-loop if timeout in iterative whitener
            if whitenerResultsStruct.timeoutTriggered
                break;
            end
            
            % ~~~~~~~~~~~~~~~~~~~~~~~ check alert status flags and issue alerts if set

            % gapped data alerts
            if any(allCadencesGapped)
                unavailableRows = rowvec(pixelRows(allCadencesGapped));
                unavailableColumns = rowvec(pixelColumns(allCadencesGapped));            
                if( length(unavailableRows) < NUM_INDICES_TO_DISPLAY_IN_ALERTS )
                    messageString = ['No pixel data available for row [',num2str(unavailableRows),']',...
                                    ', column [',num2str(unavailableColumns),'] . Using default results for these pixels for all planets.'];
                else
                    messageString = 'No pixel data available for many pixels. Using default results for all planets.';
                end

                disp(['     ',messageString]);
                alertsOnly = add_dv_alert(alertsOnly, 'Pixel correlation test', 'warning',...
                                            messageString, targetStruct.targetIndex, keplerId);
            end

            % whitener results alerts
            if any(whitenerResultsUnavailable)
                unavailableRows = rowvec(pixelRows(whitenerResultsUnavailable));
                unavailableColumns = rowvec(pixelColumns(whitenerResultsUnavailable));            
                if( length(unavailableRows) < NUM_INDICES_TO_DISPLAY_IN_ALERTS )
                    messageString = ['Whitener results not available for row [',num2str(unavailableRows),']',...
                                    ', column [',num2str(unavailableColumns),'] . Using default results for these pixels for all planets.'];
                else
                    messageString = 'Whitener results not available for many pixels. Using default results for all planets.';
                end            
                disp(['     ',messageString]);
                alertsOnly = add_dv_alert(alertsOnly, 'Pixel Correlation test ', 'warning',...
                                            messageString, targetStruct.targetIndex, keplerId); 
            end

            % whitener convergence alerts
            if any(~whitenerConverged)
                unavailableRows = rowvec(pixelRows(~whitenerConverged));
                unavailableColumns = rowvec(pixelColumns(~whitenerConverged));            
                if( length(unavailableRows) < NUM_INDICES_TO_DISPLAY_IN_ALERTS )
                    messageString = ['Iterative whitener did not converge for row [',num2str(unavailableRows),']',...
                                    ', column [',num2str(unavailableColumns),'] . Detection statistic and significance set ',...
                                    'to default values for all planets.'];
                else
                    messageString = ['Iterative whitener did not converge for many pixels. Detection statistic and significance set ',...
                                    'to default values for all planets.'];
                end     

                disp(['     ',messageString]);
                alertsOnly = add_dv_alert(alertsOnly,'Pixel correlation test ', 'warning',...
                                            messageString, targetStruct.targetIndex, keplerId);  
            end

            % transit model availability alerts
            if ~isempty(whitenerResultsStruct)
                transitModelAvailable = rowvec(whitenerResultsStruct.validDesignColumn);
                unavailablePlanets = find(~transitModelAvailable);
                if ~isempty(unavailablePlanets)
                    disp(['     Transit model not available for planets [',num2str(unavailablePlanets),'].',...
                        ' Detection statistic and significance set to default values for all pixels.']);
                    alertsOnly = add_dv_alert(alertsOnly,'Pixel correlation test ', 'warning',...
                        ['Transit model not available for planets [',num2str(unavailablePlanets),'].',...
                        ' Detection statistic and significance set to default values for all pixels.'],...
                        targetStruct.targetIndex, keplerId);  
                end
            end
            
            % perform PRF-based centroiding on pixel correlation images if
            % the models are available and perform offset analysis with
            % respect to the mean out of transit (i.e. "control") image;
            % also perform the offset analysis with respect to the KIC
            % reference position of the target on the in transit cadences
            if ~isempty(dvDataObject.prfModels)
                for iPlanet = 1 : length(targetResults.planetResultsStruct)
                    differenceImageResults = ...
                        targetResults.planetResultsStruct(iPlanet).differenceImageResults(iTable);
                    pixelCorrelationResults = ...
                        targetResults.planetResultsStruct(iPlanet).pixelCorrelationResults(iTable);
                    [pixelCorrelationResults] = ...
                        perform_dv_correlation_image_centroiding_and_offset_analysis( ...
                        dvDataObject, pixelCorrelationResults, differenceImageResults, ...
                        prfObject);
                    targetResults.planetResultsStruct(iPlanet).pixelCorrelationResults(iTable) = ...
                        pixelCorrelationResults;
                end
            end
        else
            message = 'No transit fits available for any planet. Detection statistic and significance set to default values for all pixels.';
            disp(['     ',message]);
            alertsOnly = add_dv_alert(alertsOnly,'Pixel correlation test ', 'warning',...
                                        message,targetStruct.targetIndex, keplerId);  
        end
    end

    if whitenerResultsStruct.timeoutTriggered
        % throw alert if timeout in iterative whitener
        message = ['Pixel correlation test timed out. Results set to default values for target ',num2str(keplerId),'.'];
        disp(message);
        alertsOnly = add_dv_alert(alertsOnly, 'Pixel correlation test ', 'warning',message,targetStruct.targetIndex,keplerId);        
        % update alerts in dvResultsStruct
        dvResultsStruct.alerts = alertsOnly.alerts;        
        % restore default streams
        if streams
            randStreams.restore_default();
        end       
        % continue to next target
        continue;
    end
    
    % update dvResultsStruct with results  and alerts for iTarget
    dvResultsStruct.targetResultsStruct(iTarget) = targetResults;
    dvResultsStruct.alerts = alertsOnly.alerts;    

    
    % ~~~~~~~~~~~~~~~~~~~~~~~ plot results as image
    kics = dvDataObject.kics;
    targetTableDataStruct = dvDataObject.targetTableDataStruct;
    [dvResultsStruct] = plot_pixel_correlation_image( targetStruct, dvResultsStruct, ...
        pixelCorrelationConfigurationStruct, kics, targetTableDataStruct);
    
    % ~~~~~~~~~~~~~~~~~~~~~~~ compute the mean centroid offsets over all target tables and perform the bootstrap multi-quarter PRF fit
    for iPlanet = 1 : length(dvResultsStruct.targetResultsStruct(iTarget).planetResultsStruct)
        
        planetResultsStruct = ...
            dvResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(iPlanet);
        
        differenceImageResults = ...
            planetResultsStruct.differenceImageResults;                                     %#ok<NASGU>
        pixelCorrelationResults = ...
            planetResultsStruct.pixelCorrelationResults;
        
        centroidResults = planetResultsStruct.centroidResults;
        pixelCorrelationMotionResults = ...
            centroidResults.pixelCorrelationMotionResults;
        mqKicCentroidOffsets = ...
            pixelCorrelationMotionResults.mqKicCentroidOffsets;
        mqControlCentroidOffsets = ...
            pixelCorrelationMotionResults.mqControlCentroidOffsets;
        
        [pixelCorrelationMotionResults.mqKicCentroidOffsets] = ...
            compute_robust_weighted_mean_centroid_offsets( ...
            [pixelCorrelationResults.kicCentroidOffsets], ...
            mqKicCentroidOffsets, mqOffsetConstantUncertainty);
        [pixelCorrelationMotionResults.mqControlCentroidOffsets] = ...
            compute_robust_weighted_mean_centroid_offsets( ...
            [pixelCorrelationResults.controlCentroidOffsets], ...
            mqControlCentroidOffsets, mqOffsetConstantUncertainty);
        
        allTransitsFit = planetResultsStruct.allTransitsFit;                                %#ok<NASGU>
        
        % DISABLE MULTI-QUARTER BOOTSTRAP PRF FIT FOR PIXEL CORRELATION
        % TEST. HIGH COST/LOW RETURN.
%         [pixelCorrelationMotionResults, diagnostics, string] = ...
%             perform_dv_correlation_image_centroid_fit_and_offset_analysis( ...
%             dvDataObject, pixelCorrelationResults, differenceImageResults, ...
%             pixelCorrelationMotionResults, allTransitsFit);
        diagnostics = [];                                                                   %#ok<NASGU>
        rootDir = dvResultsStruct.targetResultsStruct(iTarget).dvFiguresRootDirectory;
        string = 'Multi-quarter PRF fitting and offset analysis is disabled for pixel correlation images';
        if ~isempty(string)
            [dvResultsStruct] = add_dv_alert(dvResultsStruct, 'performDvPixelCorrelationTests', ...
                'warning', string, iTarget, keplerId, iPlanet);
            disp(dvResultsStruct.alerts(end).message);
        end % if
        fileName = [rootDir, sprintf('/planet-%02d', iPlanet), ...
            '/pixel-correlation-test-results/', num2str(keplerId, '%09d'), '-', ...
            num2str(iPlanet, '%02d'), '-prf-bootstrap-diagnostics.mat'];
        save(fileName, 'diagnostics');
        
        centroidResults.pixelCorrelationMotionResults = ...
            pixelCorrelationMotionResults;
        planetResultsStruct.centroidResults = centroidResults;
        dvResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(iPlanet) = ...
            planetResultsStruct;
        
        hold off;
        
        [string] = plot_dv_centroid_offsets(rootDir, keplerId, iPlanet, ...
            dvDataObject.kics, pixelCorrelationResults, pixelCorrelationMotionResults, ...
            'Pixel Correlation', mqOffsetConstantUncertainty, ...
            ukirtImageFileName);
        if ~isempty(string)
            [dvResultsStruct] = add_dv_alert(dvResultsStruct, ...
                'Pixel correlation test ', 'warning', string, ...
                iTarget, keplerId, iPlanet);
            disp(dvResultsStruct.alerts(end).message);
        end
        
        close;
        
    end
    
    % restore the default randstreams
    if streams
        randStreams.restore_default();
    end % if
    
end

return
