function [dvDataObject] = correct_pixel_timeseries(dvDataObject, ...
gapIndicators)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [dvDataObject] = correct_pixel_timeseries(dvDataObject, ...
% gapIndicators)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% This method corrects calibrated pixel time series for all DV targets and
% target tables by subtracting the cosmic rays that were identified in PA.
% The background is also estimated and removed for each pixel and cadence
% based on the background polynomials fitted in PA for each target table.
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

% Get fields from the input object.
dvCadenceTimes = dvDataObject.dvCadenceTimes;
lcTargetTableIds = dvCadenceTimes.lcTargetTableIds;
midTimestamps = dvCadenceTimes.midTimestamps;
cadenceNumbers = dvCadenceTimes.cadenceNumbers;
simulatedTransitsEnabled = dvDataObject.dvConfigurationStruct.simulatedTransitsEnabled;
transitInjectionParametersFileName = dvDataObject.transitInjectionParametersFileName;
keplerIds = [dvDataObject.targetStruct.keplerId];
targetTableDataStruct = dvDataObject.targetTableDataStruct;

% % revisit if enabling pou in PA
% %
% % extract pou configuration
% pouConfigurationStruct = paDataObject.pouConfigurationStruct;
% pouEnabled = pouConfigurationStruct.pouEnabled;
% compressionEnabled = pouConfigurationStruct.compressionEnabled;
% pixelChunkSize = pouConfigurationStruct.pixelChunkSize;
% cadenceChunkSize = pouConfigurationStruct.cadenceChunkSize;
% interpDecimation = pouConfigurationStruct.interpDecimation;
% interpMethod = pouConfigurationStruct.interpMethod;
% 
% % set up pouStruct
% pouStruct.inputUncertaintiesFileName = paInputUncertaintiesFileName;
% pouStruct.calPouFileRoot = calPouFileRoot;
% pouStruct.cadenceNumbers = cadenceNumbers;
% pouStruct.pouEnabled = pouEnabled;
% pouStruct.pouDecimationEnabled = true;
% pouStruct.pouCompressionEnabled = compressionEnabled;
% pouStruct.pouPixelChunkSize = pixelChunkSize;
% pouStruct.pouCadenceChunkSize = cadenceChunkSize;
% pouStruct.pouInterpDecimation = interpDecimation;
% pouStruct.pouInterpMethod = interpMethod;

% set up simulated transits struct
if simulatedTransitsEnabled
    
    % get simulated transit information from txt file and convert epoch 
    % from BMJD to BKJD
    simulatedTransitsStruct = build_simulated_transits_struct_from_tip_text_file(transitInjectionParametersFileName, keplerIds); 
    
    if ~isempty(simulatedTransitsStruct)
        for iModel = 1 : length(simulatedTransitsStruct.transitModelStructArray)
            simulatedTransitsStruct.transitModelStructArray(iModel).planetModel.transitEpochBkjd = ...
                simulatedTransitsStruct.transitModelStructArray(iModel).planetModel.transitEpochBkjd - ...
                kjd_offset_from_mjd();
        end
    end
    
    % retrieve needed parameters if simulation parameters are found for target
    if ~isempty(simulatedTransitsStruct)
        
        % extract configMap and fcConstant info
        configMapObject = configMapClass(dvDataObject.configMaps);
        exposureTimePerRead = median(get_exposure_time(configMapObject));
        exposuresPerCadence = median(get_number_of_exposures_per_long_cadence_period(configMapObject));
        
        % calculate total integration time per cadence as CADENCE_DURATION_SEC
        CADENCE_DURATION_SEC = exposureTimePerRead * exposuresPerCadence;    
        MAG12_E_PER_S = dvDataObject.fcConstants.TWELFTH_MAGNITUDE_ELECTRON_FLUX_PER_SECOND;

        % add target independent and target table indpendent info to simulatedTransitsStruct
        simulatedTransitsStruct.CADENCE_DURATION_SEC = CADENCE_DURATION_SEC;
        simulatedTransitsStruct.MAG12_E_PER_S = MAG12_E_PER_S;
    end
end

% Load and validate the background polynomials for each target table. Gap
% anomaly cadences and then interpolate the polynomials if necessary.
% Subtract background estimates from the calibrated pixels.
nTargets = length(dvDataObject.targetStruct);
nTables = length(targetTableDataStruct);
baseCadence = cadenceNumbers(1);

for iTable = 1 : nTables
    
    targetTableCcdModule = targetTableDataStruct(iTable).ccdModule;
    targetTableCcdOutput = targetTableDataStruct(iTable).ccdOutput;
    targetTableId = targetTableDataStruct(iTable).targetTableId;
    isInTable = lcTargetTableIds == targetTableId;
    
    
    % Convert the background polynomial blobs for the given target table.
    [backgroundPolyStruct, cadenceRange, gapIndicatorsForTargetTable] = ...
        load_and_gap_polynomials(targetTableDataStruct(iTable), ...
        'backgroundBlobs', baseCadence, gapIndicators);
    
    % Validate the background polynomials for the given target table.
    validate_background_polynomials(backgroundPolyStruct);
    
    % Interpolate the background polynomials if necessary.
    [cadenceTimes] = trim_dv_cadence_times(dvCadenceTimes, cadenceRange);
    
    if ~isempty(backgroundPolyStruct)
        
        backgroundPolyGapIndicators = ...
            ~logical([backgroundPolyStruct.backgroundPolyStatus]');

        if any(backgroundPolyGapIndicators)
            [backgroundPolyStruct] = ...
                interpolate_background_polynomials(backgroundPolyStruct,...
                cadenceTimes);
        end % if
    
    end % if
    
    
    % add target table dependent info to simulated transits struct if needed
    if simulatedTransitsEnabled && ~isempty( simulatedTransitsStruct )
        
        % add prf object if available
        if ~isempty(dvDataObject.prfModels)
            % Get the PRF model for the given target table and instantiate a prf collection class object
            ccdModules = [dvDataObject.prfModels.ccdModule]';
            ccdOutputs = [dvDataObject.prfModels.ccdOutput]';            
            [tf, loc] = ismember([targetTableCcdModule, targetTableCcdOutput], [ccdModules, ccdOutputs], 'rows');
            if tf
                prfStruct = blob_to_struct(dvDataObject.prfModels(loc).blob);
                if isfield(prfStruct, 'c')                                         % it's a single prf model
                    prfModel.polyStruct = prfStruct;
                else
                    prfModel = prfStruct;
                end
                simulatedTransitsStruct.prfObject = prfCollectionClass(prfModel, dvDataObject.fcConstants);
                clear prfStruct prfModel
            else
                error('DV:correctPixelTimeseries', 'PRF for module %d output %d is not present in DV inputs', ...
                    targetTableCcdModule, targetTableCcdOutput);
            end            
        end
        
        % add motion polynomials
        simulatedTransitsStruct.motionPolyStruct = targetTableDataStruct(iTable).motionPolyStruct;
        
        % add background polys
        simulatedTransitsStruct.backgroundPolyStruct = backgroundPolyStruct;
        
        % Add cadence times struct for this target table. Note the cadences in the gaps between quarters are *not* represented in the pixel
        % time series -  this only becomes an issue if processing multi-quarter data. cadenceTimes has been trimmed properly above using
        % target table start and stop cadences        
        simulatedTransitsStruct.cadenceTimes = cadenceTimes;
    end    
     
    
    % Loop over the targets for the given target table, load the pixel
    % data, remove the background and cosmic rays, and then write the
    % results to a mat-file.
    
    for iTarget = 1 : nTargets
        
        targetStruct = dvDataObject.targetStruct(iTarget);
        targetTableIds = [targetStruct.targetDataStruct.targetTableId];
        [tf, loc] = ismember(targetTableId, targetTableIds);
        if ~tf
            continue
        end %  if
        targetDataStruct = targetStruct.targetDataStruct(loc);
        
        % Load pixel data for given target and target table from file.
        pixelDataFileName = targetDataStruct.pixelDataFileName;
        [pixelDataStruct, status, path, name, ext] = ...
            file_to_struct(pixelDataFileName, 'pixelDataStruct');
        if ~status
            error('dv:correctPixelTimeseries:unknownDataFileType', ...
                'unknown pixel data file type (%s%s)', ...
                name, ext);
        end % if
        
        % Validate the pixel data for the given target and target table.
        validate_pixel_data(pixelDataStruct);
        
        % Convert the CCD coordinates to 1-based.
        nPixels = length(pixelDataStruct);
        
        for iPixel = 1 : nPixels
            pixelDataStruct(iPixel).ccdRow = ...
                pixelDataStruct(iPixel).ccdRow + 1;
            pixelDataStruct(iPixel).ccdColumn = ...
                pixelDataStruct(iPixel).ccdColumn + 1;
        end % for iPixel
        
        % Gap the data anomalies.
        for iPixel = 1 : nPixels
            calibratedTimeSeries = ...
                pixelDataStruct(iPixel).calibratedTimeSeries;
            calibratedTimeSeries.values(gapIndicatorsForTargetTable) = 0;
            calibratedTimeSeries.uncertainties(gapIndicatorsForTargetTable) = 0;
            calibratedTimeSeries.gapIndicators(gapIndicatorsForTargetTable) = true;
            pixelDataStruct(iPixel).calibratedTimeSeries = ...
                calibratedTimeSeries;      
        end % for iPixel
        
        % Loop over the pixels and subtract the cosmic ray deltas.
        for iPixel = 1 : nPixels

            calibratedTimeSeries = ...
                pixelDataStruct(iPixel).calibratedTimeSeries;
            cosmicRayEvents = pixelDataStruct(iPixel).cosmicRayEvents;
            eventTimes = cosmicRayEvents.times;
            eventValues = cosmicRayEvents.values;

            [tf, loc] = ismember(eventTimes, midTimestamps(isInTable));
            calibratedTimeSeries.values(loc(tf)) = ...
                calibratedTimeSeries.values(loc(tf)) - eventValues(tf);

            pixelDataStruct(iPixel).calibratedTimeSeries = ...
                calibratedTimeSeries;

        end % for iPixel
        

        % Estimate and remove the background, cadence by cadence, based on
        % the background polynomials for the given target table. Ensure
        % that the values and uncertainties are zero if the associated gap
        % indicator is set.
        ccdRows = [pixelDataStruct.ccdRow]';
        ccdColumns = [pixelDataStruct.ccdColumn]';

        calibratedTimeSeriesArray = ...
            [pixelDataStruct.calibratedTimeSeries];
        pixelValues = [calibratedTimeSeriesArray.values];
        pixelUncertainties = [calibratedTimeSeriesArray.uncertainties];
        gapArray = [calibratedTimeSeriesArray.gapIndicators];
        clear calibratedTimeSeriesArray

% revisit if enabling pou in PA
%
%         [pixelValues, pixelUncertainties] = ...
%             remove_background_from_pixels(pixelValues, pixelUncertainties, ...
%             ccdRows, ccdColumns, [backgroundPolyStruct.backgroundPoly], gapArray, pouStruct);
        
        [pixelValues, pixelUncertainties] = ...
            remove_background_from_pixels(pixelValues, pixelUncertainties, ...
            ccdRows, ccdColumns, [backgroundPolyStruct.backgroundPoly], gapArray);
          
        
        % Update pixelDataStruct.
        pixelValues(gapArray) = 0;
        pixelUncertainties(gapArray) = 0;   
        
        for iPixel = 1 : nPixels
            pixelDataStruct(iPixel).calibratedTimeSeries.values = ...
                pixelValues( : , iPixel);
            pixelDataStruct(iPixel).calibratedTimeSeries.uncertainties = ...
                pixelUncertainties( : , iPixel);
        end % for iPixel


        % Inject transits as they were done in PA if enabled and found
        if simulatedTransitsEnabled && ~isempty( simulatedTransitsStruct )
            
            % build transit injection inputs for this target - need to mock up targetDataStruct with updated pixels and gaps. cadenceRange
            % from selects correct barycentric timestamps for trimmed cadenceTimes in simulatedTransitsStruct
            transitInjectionInputs = build_dv_transit_injection_struct(dvDataObject, pixelDataStruct, iTarget, cadenceRange, simulatedTransitsStruct);
            
            if ~isempty(transitInjectionInputs)
            
                % inject transits
                % set dvStyleInputs flag to true
                transitInjectionOutputs = inject_transits_into_target_pixels( transitInjectionInputs, true );            
                            
                if ~isempty(transitInjectionOutputs) && any(transitInjectionOutputs.cadenceModified)
                    % display log message
                    disp(['Injecting transits for target index ',num2str(iTarget),' - keplerId ',...
                        num2str(targetStruct.keplerId),' - Target Table Id ',num2str(targetTableId)]);
                    % read pixels and gaps from transit injection outputs
                    pixelValues = transitInjectionOutputs.pixelValues;
                    gapArray    = transitInjectionOutputs.pixelGaps;
                end
            end
            
            % update pixelDataStruct
            pixelValues(gapArray) = 0;
            pixelUncertainties(gapArray) = 0;

            for iPixel = 1 : nPixels
                pixelDataStruct(iPixel).calibratedTimeSeries.values = ...
                    pixelValues( : , iPixel);
                pixelDataStruct(iPixel).calibratedTimeSeries.uncertainties = ...
                    pixelUncertainties( : , iPixel);
            end % for iPixel
        end
        
        
        % Generate a pixel meta data structure with CCD coordinates and
        % optimal aperture indicators, but without the pixel time series
        % data.
        pixelMetaDataStruct = rmfield(pixelDataStruct, ...
            {'calibratedTimeSeries', 'cosmicRayEvents'});                                   %#ok<NASGU>
        
        % Write the pixel data to a MAT-file for the given target and
        % target table. Clear the pixel data from memory.
        pixelDataFileName = fullfile(path, [name, '.mat']);
        save(pixelDataFileName, 'pixelDataStruct', 'pixelMetaDataStruct');
        targetDataStruct.pixelDataFileName = pixelDataFileName;
        clear pixelDataStruct pixelMetaDataStruct
        
        % Update the target data structure for the given target table.
        targetStruct.targetDataStruct(targetTableId == targetTableIds) = ...
            targetDataStruct;

        % Update the target structure for the given target.
        dvDataObject.targetStruct(iTarget) = targetStruct;

    end % for iTarget
    
    % Clear the background polynomials from memory.
    clear backgroundPolyStruct
    
end % for iTable

% Return.
return
