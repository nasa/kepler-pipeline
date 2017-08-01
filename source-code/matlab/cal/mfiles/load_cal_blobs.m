function [calInputStruct] = load_cal_blobs(calInputStruct)
% function [calInputStruct] = load_cal_blobs(calInputStruct)
%
% This CAL function loads the blob files needed depending on the CAL configuration specified in calInputStruct. Information extracted from
% the blobs is stored in structures and attached to calInputStruct. Possible blobs specified in calInputStruct are dynablackBlob,
% oneDBlackBlob and smearBlob. In the case of the dynablackBlob, on the first call the initializedModels are attached to calInputStruct and
% also saved to a local file in order to be made available to later invocations.
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

metricsKey = metrics_interval_start;

% extract flags
dataFlags = calInputStruct.dataFlags;
processShortCadence    = dataFlags.processShortCadence;
performExpLc1DblackFit = dataFlags.performExpLc1DblackFit; 
performExpSc1DblackFit = dataFlags.performExpSc1DblackFit;
dynamic2DBlackEnabled  = dataFlags.dynamic2DBlackEnabled;

% extract input parameters
firstCall       = calInputStruct.firstCall;
ccdModule       = calInputStruct.ccdModule;
ccdOutput       = calInputStruct.ccdOutput;
season          = calInputStruct.season;
localFilenames  = calInputStruct.localFilenames; 
stateFilePath   = localFilenames.stateFilePath;

moduleParameters = calInputStruct.moduleParametersStruct;
stdRatioThreshold               = moduleParameters.stdRatioThreshold;
coefficentModelId               = moduleParameters.coefficentModelId;
dynoblackModelAutoSelectEnable  = moduleParameters.dynoblackModelAutoSelectEnable;
dynoblackChi2Threshold          = moduleParameters.dynoblackChi2Threshold;
enableLcInformSmear             = moduleParameters.enableLcInformSmear;
enableDbDataQualityGapping      = moduleParameters.enableDbDataQualityGapping;
enableMmntmDmpFlag              = moduleParameters.enableMmntmDmpFlag;
enableSefiAccFlag               = moduleParameters.enableSefiAccFlag;
enableSefiCadFlag               = moduleParameters.enableSefiCadFlag;
enableLdeOosFlag                = moduleParameters.enableLdeOosFlag;
enableLdeParErFlag              = moduleParameters.enableLdeParErFlag;
enableScrcErrFlag               = moduleParameters.enableScrcErrFlag;
enableCoarsePointProcessing     = moduleParameters.enableCoarsePointProcessing;
enableExcludeIndicators         = moduleParameters.enableExcludeIndicators;


% default is no blobs found --> no blackCorrectionStruct, no dynablackResultsStruct, no valid fit and no smear blobs 
calInputStruct.blackCorrectionStructLC  = [];
blackBlobFound                          = false;
calInputStruct.dynablackResultsStruct   = [];
overridesLogicals                       = false;
dynablackBlobFound                      = false;
validDynablackFit                       = false;
calInputStruct.smearBlob                = [];
smearBlobFound                          = false;

% initialize dynoblackModels empty (no blob found, invalid blob or no dynoblack models file found)
calInputStruct.dynoblackModels = [];

if dynamic2DBlackEnabled    
    if firstCall
        
        % load the dynablack fit results from the dynablack blob file(s) if available    
        dynablackFitBlobSeries = calInputStruct.dynamic2DBlackBlobs;
        
        if isfield(dynablackFitBlobSeries,'blobFilenames') && ~isempty(dynablackFitBlobSeries.blobFilenames)
            
            % make filenames in list full path
            % dynablackFitBlobSeries.blobFilenames = strcat(stateFilePath, dynablackFitBlobSeries.blobFilenames);            
            
            % Make the blob object
            dynablackFitObject = blobSeriesClass(dynablackFitBlobSeries);

            % get the gaps
            dynablackFitGapIndicators = get_gap_indicators(dynablackFitObject);

            if ~all(dynablackFitGapIndicators)                

                % find unique blob indices
                blobIndices = get_blob_indices(dynablackFitObject);
                [~, uniqueIndex] = unique(blobIndices(~dynablackFitGapIndicators),'first');
                
%                 % matlab-2007a version
%                 [dummy, uniqueIndex] = unique(blobIndices(~dynablackFitGapIndicators),'first');

                % retrieve array of unique structs in dynablackFitBlobSeries
                validRelativeCadences = find(~dynablackFitGapIndicators);
                dynablackFitStructArray = get_struct_for_cadence(dynablackFitObject, validRelativeCadences(uniqueIndex));

                % get start and end times for UOW
                uowStart = calInputStruct.cadenceTimes.startTimestamps(1);
                uowEnd = calInputStruct.cadenceTimes.endTimestamps(end);

                % parse the array of structs returned from get_struct_for_cadence and collapse array of dynablack fit into single array for UOW
                dynablackFitStruct = collapse_dynablack_fit_array(dynablackFitStructArray, uowStart, uowEnd);
                display('CAL:cal_matlab_controller: dynablack blob converted to struct.');
                               
                % extract validity flag
                validDynablackFit = dynablackFitStruct.validDynablackFit;                
                
                if validDynablackFit                    
                    % check coefficient overrides table for 1D black fit
                    [overridesTable, logicalIdx]  = load_coeff_overrides_table;
                    channel = convert_from_module_output(ccdModule,ccdOutput);                    
                    overridesLogicals = logical(overridesTable( 4*(channel-1) + season + 1, logicalIdx));
                    clear overridesTable;
                    
                    % find dynablack cadence logical indices in uow
                    dbCadenceIndicesFit = dynablackFitStruct.A1ModelDump.Inputs.FCLC_list;
                    dbStartTimes = dynablackFitStruct.cadenceTimes.startTimestamps;
                    dbEndTimes = dynablackFitStruct.cadenceTimes.endTimestamps;
                    dbUowLogical = dbStartTimes(dbCadenceIndicesFit) >= uowStart & dbEndTimes(dbCadenceIndicesFit) <= uowEnd;
                    
                    % extract logical indices for fgs frame, fgs parallel and trailing black pixels
                    framePixelsLogical = dynablackFitStruct.A1ModelDump.FCLC_Model.frame_pixels.Subset_datum_index;
                    parallelPixelsLogical = dynablackFitStruct.A1ModelDump.FCLC_Model.parallel_pixels.Subset_datum_index;
                    
                    nPixels = size(dynablackFitStruct.A1_fit_residInfo.LC.roi_ID,1);
                    trailingBlackLogical = false(nPixels,1);
                    for iPix = 1:nPixels
                        if strcmp(dynablackFitStruct.A1_fit_residInfo.LC.roi_ID(iPix,:),'TC1')
                           trailingBlackLogical(iPix) = true;
                        end
                    end
                    
                    % dynamically determine either robust or regress coefficients by comparing the rms over pixels of the standard deviation
                    % in residuals over uow
                    % frame FGS
                    A = dynablackFitStruct.A1_fit_residInfo.LC.full_xLC.regress_resid(dbUowLogical,framePixelsLogical);
                    B = dynablackFitStruct.A1_fit_residInfo.LC.full_xLC.robust_resid(dbUowLogical,framePixelsLogical);
                    regressResidualStd = sqrt(nanmean(nanstd(A).^2));
                    robustResidualStd = sqrt(nanmean(nanstd(B).^2));
                    if regressResidualStd > robustResidualStd
                        useRobustFrameFgsCoeffs = true;
                    else
                        useRobustFrameFgsCoeffs = false;
                    end
                    % parallel FGS                   
                    A = dynablackFitStruct.A1_fit_residInfo.LC.full_xLC.regress_resid(dbUowLogical,parallelPixelsLogical);
                    B = dynablackFitStruct.A1_fit_residInfo.LC.full_xLC.robust_resid(dbUowLogical,parallelPixelsLogical);
                    regressResidualStd = sqrt(nanmean(nanstd(A).^2));
                    robustResidualStd = sqrt(nanmean(nanstd(B).^2));
                    if regressResidualStd > robustResidualStd
                        useRobustParallelFgsCoeffs = true;
                    else
                        useRobustParallelFgsCoeffs = false;
                    end
                    % trailing black (vertical components)                   
                    A = dynablackFitStruct.A1_fit_residInfo.LC.full_xLC.regress_resid(dbUowLogical,trailingBlackLogical);
                    B = dynablackFitStruct.A1_fit_residInfo.LC.full_xLC.robust_resid(dbUowLogical,trailingBlackLogical);
                    regressResidualStd = sqrt(nanmean(nanstd(A).^2));
                    robustResidualStd = sqrt(nanmean(nanstd(B).^2));
                    if regressResidualStd > robustResidualStd
                        useRobustVerticalCoeffs = true;
                    else
                        useRobustVerticalCoeffs = false;
                    end
                    
                    % require all coefficient types are consistant - either all robust or all regress
                    if ~all([useRobustFrameFgsCoeffs, useRobustParallelFgsCoeffs, useRobustVerticalCoeffs])
                        useRobustFrameFgsCoeffs = false;
                        useRobustParallelFgsCoeffs = false;
                        useRobustVerticalCoeffs = false;
                    end                        
                    
                    % update flags in module parameters struct
                    moduleParameters.useRobustVerticalCoeffs    = useRobustVerticalCoeffs;
                    moduleParameters.useRobustFrameFgsCoeffs    = useRobustFrameFgsCoeffs;
                    moduleParameters.useRobustParallelFgsCoeffs = useRobustParallelFgsCoeffs;                    
                    calInputStruct.moduleParametersStruct = moduleParameters;
                                       
                    
                    % if no overrides are enabled use dynablack otherwise stay with default which is exponentialOneDBlack
                    if all(~overridesLogicals)
                        
                        % set found flag - we're doing dynablack for this channel/season
                        dynablackBlobFound = true;

                        % extract dynoblack configuration parameters from calInputsStruct
                        dynoblackConfigStruct = struct('stdRatioThreshold',stdRatioThreshold,...
                                                        'coefficentModelId',coefficentModelId,...
                                                        'modelAutoSelectEnable',dynoblackModelAutoSelectEnable,...
                                                        'useRobustVerticalCoeffs',useRobustVerticalCoeffs,...
                                                        'useRobustFrameFgsCoeffs',useRobustFrameFgsCoeffs,...
                                                        'useRobustParallelFgsCoeffs',useRobustParallelFgsCoeffs,...
                                                        'chi2Threshold',dynoblackChi2Threshold,...
                                                        'enableDbDataQualityGapping',enableDbDataQualityGapping,...
                                                        'enableMmntmDmpFlag',enableMmntmDmpFlag,...
                                                        'enableSefiAccFlag',enableSefiAccFlag,...
                                                        'enableSefiCadFlag',enableSefiCadFlag,...
                                                        'enableLdeOosFlag',enableLdeOosFlag,...
                                                        'enableLdeParErFlag',enableLdeParErFlag,...
                                                        'enableScrcErrFlag',enableScrcErrFlag,...
                                                        'enableCoarsePointProcessing',enableCoarsePointProcessing,...
                                                        'enableExcludeIndicators',enableExcludeIndicators);
                          
                                                
                        % initalize dynoblack models
                        display('CAL:cal_matlab_controller: Initializing dynoblack models ...');
                        initializedModels = initialize_dynoblack_models( dynablackFitStruct, dynoblackConfigStruct );                    
                        clear dynablackFitStruct;

                        % attach initialized models to the calInputStruct
                        calInputStruct.dynoblackModels = initializedModels;

                        % save initialized dynoblack models to local file
                        save ( [stateFilePath, localFilenames.dynoblackModelsFilename], 'initializedModels' );
                        display('CAL:cal_matlab_controller: dynoblack models saved to local file.');
                        clear initializedModels;
                    end                                        
                end
            end
        end        
    else
        if exist( [stateFilePath,localFilenames.dynoblackModelsFilename],'file') == 2            
            % load dynoblack initialized models from local file
            display('CAL:cal_matlab_controller: Load dynoblack models from local file.');
            load([stateFilePath,localFilenames.dynoblackModelsFilename],'initializedModels');
            
            % convert dynamicBlackModel substruct to object
            initializedModels.dynablackModel = dynamicBlackModel(initializedModels.dynablackModel);                                   %#ok<NODEF>
            
            % if initializedModels were saved the fit was valid, blob was found and rmsResiduals were ok
            validDynablackFit = true;
            dynablackBlobFound = true;
            
            % attach initialized models to the calInputStruct and clear
            calInputStruct.dynoblackModels = initializedModels;
            clear initializedModels;            
        else
            dynablackBlobFound = false;
        end        
    end
    
    if ~dynablackBlobFound || ~validDynablackFit   
        % disable dynamic 2D black correction
        performExpLc1DblackFit = true;
        performExpSc1DblackFit = true;
        dynamic2DBlackEnabled  = false;
        
        % default to exponential 1D black fit
        calInputStruct.moduleParametersStruct.blackAlgorithm = 'exponentialOneDBlack';
        calInputStruct.dynablackResultsStruct = [];
        
        if firstCall            
            if any(overridesLogicals)
                display('WARNING: One D black coefficient overrides exist.');
            elseif ~dynablackBlobFound
                display('WARNING: dynamic2DBlackBlobs not found or are gapped for all cadences.');
            elseif ~validDynablackFit
                display('WARNING: dynamic2DBlackBlobs contains invalid fit.');
            end            
        else
            display('WARNING: Black fit set to static 2D black + exponentialOneDBlack in collateral invocation.');
        end  
        display('Setting dynamic2DBlackEnabled = false and using static 2D black + exponentialOneDBlack');        
    end
end


if firstCall && processShortCadence 
    
    if ~dynamic2DBlackEnabled && performExpSc1DblackFit
        
        % load the 1D black LC fit from the blob file if available
        blackFitBlobSeries = calInputStruct.oneDBlackBlobs;
        
        if isfield(blackFitBlobSeries,'blobFilenames') && ~isempty(blackFitBlobSeries.blobFilenames)
            
            % make filenames in list full path
            % blackFitBlobSeries.blobFilenames = strcat(stateFilePath, blackFitBlobSeries.blobFilenames);
            
            % Make the blob object
            blackFitObject = blobSeriesClass(blackFitBlobSeries);
            
            % get the gaps
            blackFitGapIndicators = get_gap_indicators(blackFitObject);
            
            if ~all(blackFitGapIndicators)
                blackBlobFound = true;
                
                % find unique blob indices
                blobIndices = get_blob_indices(blackFitObject);
                [~, uniqueIndex] = unique(blobIndices(~blackFitGapIndicators),'first');
                
                %                 % matlab-2007a version
                %                 [dummy, uniqueIndex] = unique(blobIndices(~blackFitGapIndicators),'first');
                
                % retrieve array of unique structs in blackFitBlobSeries
                validRelativeCadences = find(~blackFitGapIndicators);
                blackFitStructArray = get_struct_for_cadence(blackFitObject, validRelativeCadences(uniqueIndex));
                
                % parse the array of structs returned from get_struct_for_cadence and
                % collapse array of black fit into single array
                blackFitStruct = collapse_black_fit_array(blackFitStructArray);
                clear blackFitStructArray
                display('CAL:cal_matlab_controller: One-D black blob converted to struct.');
            end
        end
        
        if blackBlobFound
            % attach needed part of the blackFitStruct to the calInputStruct
            calInputStruct.blackCorrectionStructLC = blackFitStruct.blackCorrectionStructLC;
            clear blackFitStruct;
        else
            % adjust module parameters and data flags
            calInputStruct.moduleParametersStruct.blackAlgorithm = 'polynomialOneDBlack';
            performExpLc1DblackFit = false;
            performExpSc1DblackFit = false;
            dynamic2DBlackEnabled  = false;
            display('WARNING: oneDBlackBlobs not found or are gapped for all cadences. Using polynomial fit for 1D black.');
        end
    end
    
    if enableLcInformSmear
        
        % load the smear blob and attach the smearBlob to the inputsStruct
        smearBlobSeries = calInputStruct.smearBlobs;
        
        if isfield(smearBlobSeries,'blobFilenames') && ~isempty(smearBlobSeries.blobFilenames)
            
            % make filenames in list full path
            % smearBlobSeries.blobFilenames = strcat(stateFilePath, smearBlobSeries.blobFilenames);
            
            % Make the blob object
            smearObject = blobSeriesClass(smearBlobSeries);
            
            % get the gaps
            smearGapIndicators = get_gap_indicators(smearObject);
            
            if ~all(smearGapIndicators)
                smearBlobFound = true;
                
                % find unique blob indices
                blobIndices = get_blob_indices(smearObject);
                [~, uniqueIndex] = unique(blobIndices(~smearGapIndicators),'first');
                
                %                 % matlab-2007a version
                %                 [dummy, uniqueIndex] = unique(blobIndices(~blackFitGapIndicators),'first');
                
                % retrieve array of unique structs in blackFitBlobSeries
                validRelativeCadences = find(~smearGapIndicators);
                smearStructArray = get_struct_for_cadence(smearObject, validRelativeCadences(uniqueIndex));
                
                % parse the array of structs returned from get_struct_for_cadence and
                % collapse array of black fit into single array
                smearStruct = collapse_smear_struct_array(smearStructArray);
                clear smearStructArray
                display('CAL:cal_matlab_controller: Smear blob converted to struct.');
            end
        end
        
        if smearBlobFound
            % attach needed part of the smearStruct to the calInputStruct
            
            % find lc smear time stamps which span the sc data
            lcMjds = smearStruct.midTimeStamps;
            scMjds = calInputStruct.cadenceTimes.midTimestamps;            
            validLcLogical = lcMjds >= min(scMjds) & lcMjds <= max(scMjds);
            
            if numel(find(validLcLogical)) > 1
                % keep only valid lc data
                smearStruct.cadenceNumbers  = smearStruct.cadenceNumbers(validLcLogical);
                smearStruct.startTimeStamps = smearStruct.startTimeStamps(validLcLogical);
                smearStruct.midTimeStamps   = smearStruct.midTimeStamps(validLcLogical);
                smearStruct.endTimeStamps   = smearStruct.endTimeStamps(validLcLogical);

                smearCorrectionStructLC                 = smearStruct.smearCorrectionStructLC;
                smearCorrectionStructLC.mjd             = smearCorrectionStructLC.mjd(validLcLogical);
                smearCorrectionStructLC.mSmearPixels    = smearCorrectionStructLC.mSmearPixels(:,validLcLogical);
                smearCorrectionStructLC.mSmearGaps      = smearCorrectionStructLC.mSmearGaps(:,validLcLogical);
                smearCorrectionStructLC.vSmearPixels    = smearCorrectionStructLC.vSmearPixels(:,validLcLogical);
                smearCorrectionStructLC.vSmearGaps      = smearCorrectionStructLC.vSmearGaps(:,validLcLogical);
                smearStruct.smearCorrectionStructLC     = smearCorrectionStructLC;

                calInputStruct.smearBlob = smearStruct;
            else
                % adjust module parameter
                calInputStruct.moduleParametersStruct.enableLcInformSmear = false;
                display('WARNING: Need more than 1 cadence of lc smear data to interpolate onto sc. Cannot inform sc smear with lc smear data.');
            end
            clear smearStruct;
        else
            % adjust module parameter
            calInputStruct.moduleParametersStruct.enableLcInformSmear = false;
            display('WARNING: smearBlobs not found or are gapped for all cadences. Cannot inform sc smear with lc smear data.');
        end        
    end    
end

% update data flags
calInputStruct.dataFlags.performExpLc1DblackFit = performExpLc1DblackFit;
calInputStruct.dataFlags.performExpSc1DblackFit = performExpSc1DblackFit;
calInputStruct.dataFlags.dynamic2DBlackEnabled  = dynamic2DBlackEnabled;

display('CAL:cal_matlab_controller: CAL blobs loaded.');  
metrics_interval_stop('cal.load_cal_blobs.execTimeMillis',metricsKey);