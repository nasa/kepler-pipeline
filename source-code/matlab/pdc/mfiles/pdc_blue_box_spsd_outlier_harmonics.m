%%====================================================================================================
%% BLUE BOX
% Coarse MAP, SPSDs, outliers and harmonics
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

function [localTargetDataStruct, alerts, fluxCorrectionStruct, pdcDebugObject, ...
    targetsToUseForBasisVectorsAndPriors, spikeBasisVectors, variabilityStructK2 ] = pdc_blue_box_spsd_outlier_harmonics (...
    localTargetDataStruct, ...
    pdcInputObject, ...
    uberDiagnosticStruct, ...
    cbvBlobStruct, ...
    mapBlobStruct, ...
    localMotionPolyStruct, ...
    fluxCorrectionStruct, ...
    pdcDebugObject, ...
    pdcInternalConfig, ...
    localConfigurationStruct, ...
    spsdBlobStruct, ...
    dataAnomalyIndicators, ...
    nonbsMapConfigurationStruct, ...
    alerts)

global memUsage;

nTargets = length(pdcInputObject.targetDataStruct);

%----------------------------------------------------------------------------------------------------
% Coarse Map
% use all targets for this coarse MAP run
targetsToUseForBasisVectorsAndPriors = true(nTargets,1);

metricsKey = metrics_interval_start;

% Calculate Stellar Variability outside of MAP so that band-splitting does not screw up the calculation
disp('Calculating stellar variability...');
if (pdcInputObject.thisIsK2Data)
    doNormalizeFlux = 'noiseFloor';
else
    doNormalizeFlux = true;
end

 [variabilityStruct.variability, variabilityStruct.medianVariability] = ...
         pdc_calculate_stellar_variability (localTargetDataStruct, pdcInputObject.cadenceTimes, ...
                  pdcInputObject.pdcModuleParameters.variabilityDetrendPolyOrder, doNormalizeFlux, ...
                  pdcInputObject.pdcModuleParameters.variabilityEpRecoveryMaskEnabled, ...
                  pdcInputObject.pdcModuleParameters.variabilityEpRecoveryMaskWindow, ...
                  pdcInputObject.pdcModuleParameters.stellarVariabilityRemoveEclipsingBinariesEnabled);

memUsage.add('Stellar Variability Calculated (coarse)');

disp('Stellar variability calculated!');

disp('doing coarse MAP...');
pdctic = tic;

uberDiagnosticStruct.mapDiagnosticStruct.runLabel = 'Coarse';
% coarse MAP, save figures
uberDiagnosticStruct.mapDiagnosticStruct.doFigures           = true;
uberDiagnosticStruct.mapDiagnosticStruct.doSaveFigures       = true;
uberDiagnosticStruct.mapDiagnosticStruct.doSaveResultsStruct = true;

% set specificKeplerIdsToAnalyze to [] for coarseMAP, which will process all targets and is needed for SPSD
specificKeplerIdsToAnalyze = uberDiagnosticStruct.mapDiagnosticStruct.specificKeplerIdsToAnalyze;
uberDiagnosticStruct.mapDiagnosticStruct.specificKeplerIdsToAnalyze = [];

% If using prior from blob then we need to get the right priors for the coarse run
cbvBlobStructCoarse = cbvBlobStruct;
if (nonbsMapConfigurationStruct.useBasisVectorsFromBlob || nonbsMapConfigurationStruct.useBasisVectorsAndPriorsFromBlob)
    % map is ignorant of specific runs so just copy the basis vectors and fit coefficients to the *nobands fields
    % if the basis vectors for this band are empty then pass the empty set forcing map to fail for this band
    cbvBlobStructCoarse.basisVectorsNoBands =          cbvBlobStruct.basisVectorsCoarse;
    cbvBlobStructCoarse.robustFitCoefficientsNoBands = cbvBlobStruct.robustFitCoefficientsCoarse;
    cbvBlobStructCoarse.priorPdfInfoNoBands =          cbvBlobStruct.priorPdfInfoCoarse;
end

% Create taskInfoStruct containing task-specific information
taskInfoStruct = struct('ccdModule', pdcInputObject.ccdModule, 'ccdOutput', pdcInputObject.ccdOutput, 'quarter', pdcInputObject.cadenceTimes.quarters(1), ...
                        'month', pdcInputObject.cadenceTimes.months(1), 'thisIsK2Data', pdcInputObject.thisIsK2Data);

 [mapCorrectedTargetDataStruct, mapAlerts, basisVectors, spikeBasisVectors] = map_controller( nonbsMapConfigurationStruct, ...
                                              pdcInputObject.pdcModuleParameters, ...
                                              localTargetDataStruct, ...
                                              pdcInputObject.cadenceTimes, ...
                                              targetsToUseForBasisVectorsAndPriors, ...
                                              uberDiagnosticStruct.mapDiagnosticStruct, ...
                                              variabilityStruct, mapBlobStruct, cbvBlobStructCoarse, ...
                                              pdcInputObject.goodnessMetricConfigurationStruct, ...
                                              localMotionPolyStruct, pdcInputObject.multiChannelMotionPolyStruct, taskInfoStruct);

%*************************************************************************************************************

memUsage.add('Coarse MAP finished');

% set specificKeplerIdsToAnalyze to the original list of keplerIds
uberDiagnosticStruct.mapDiagnosticStruct.specificKeplerIdsToAnalyze = specificKeplerIdsToAnalyze;

alerts = [ alerts , mapAlerts ];
                                         
metrics_interval_stop('pdc.map_controller.execTimeMillis', metricsKey);

duration = toc(pdctic);
disp(['  ...done after ' num2str(duration) ' seconds.']);

localTargetDataStruct = mapCorrectedTargetDataStruct;
doNanGaps = false;

if (pdcDebugObject.preparation.plotCoarseMap)
    s = ['[4] - after coarse MAP (kId ' int2str(localTargetDataStruct(pdcDebugObject.targetsToMonitor(1)).keplerId) ')'];
    figure; plot(localTargetDataStruct(pdcDebugObject.targetsToMonitor(1)).values,'.'); set(gcf,'Name',s); title(s);
end
pdcDebugObject = pdcDebugObject.add_intermediate('after coarse MAP',localTargetDataStruct);

    
%----------------------------------------------------------------------------------------------------

%----------------------------------------------------------------------------------------------------
% the following block is iterated

% build an index of clean targets
idxCleanTargets = (1:nTargets)';
idxTargetHadHarmonics = cell(pdcInputObject.pdcModuleParameters.preMapIterations,1);
idxTargetHadDiscontinuities = cell(pdcInputObject.pdcModuleParameters.preMapIterations,1);

% pre initialize this flag, as it's OR'ed in each iteration of preMapIterations
for i=1:nTargets
    fluxCorrectionStruct(i).uncorrectedSuspectedDiscontinuity = false;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PRE-MAP ITERATIONS

for iIter = 1:pdcInputObject.pdcModuleParameters.preMapIterations
    disp(' ');
    disp(['Doing data preparation (Iteration ' num2str(iIter) ')']);
    
    idxTargetHadHarmonics{iIter} = zeros(nTargets,1);
    idxTargetHadDiscontinuities{iIter} = zeros(nTargets,1);

    
%----------------------------------------------------------------------------------------------------

    % ID SPSDs
    disp(['doing Discontinuities (iteration ' int2str(iIter) ')...']);
    if (pdcInternalConfig.useNewSpsd)
        %=============================================
        % new SPSD module
        %=============================================
        disp('  ...doing SPSD now.');
        pdctic = tic;


        % remove harmonics for SPSD, if enabled - using a copy of the localTargetDataStruct for that
        targetDataStructSpsdInput = localTargetDataStruct;
        if (pdcInputObject.spsdDetectionConfigurationStruct.harmonicsRemovalEnabled)
            for i=1:nTargets
                [ harmonicRemovedValues, harmonicTimeSeriesValues, indexOfGiantTransits, harmonicModelStruct ] = ...
                    pdc_remove_harmonics( localTargetDataStruct(i).values, ...
                                          localTargetDataStruct(i).gapIndicators, ...
                                          localConfigurationStruct.gapFillConfigurationStruct, ...
                                          localConfigurationStruct.harmonicsIdentificationConfigurationStruct ) ;
                    targetDataStructSpsdInput(i).values = harmonicRemovedValues;
            end
        end
            
        
        metricsKey = metrics_interval_start;
        [ spsdOutputStruct spsdCorrectedFluxStruct ]  = spsd_controller( pdcInputObject, ...
                                                                         targetDataStructSpsdInput, ...
                                                                         basisVectors', ...
                                                                         spsdBlobStruct );
        memUsage.add(['after spsd_controller iteration ', num2str(iIter)]);

    	% clear temporary data again
        clear targetDataStructSpsdInput;

        % save the SPSD diagnostic information for this iteration
        if (uberDiagnosticStruct.dataStructSaving.saveSpsdCorrectedFluxObject)
            intelligent_save(['spsdCorrectedFluxStruct_' num2str(iIter)],'spsdCorrectedFluxStruct');
        end

        metrics_interval_stop('pdc.spsd_controller.execTimeMillis', metricsKey);
        duration = toc(pdctic);
        disp(['  ...done after ' num2str(duration) ' seconds.']);

        % remove targets with discontinuities from list of targets to use for prior
        idxTargetHadDiscontinuities{iIter} = zeros(nTargets,1);
        idxTargetHadDiscontinuities{iIter}(spsdOutputStruct.spsds.index) = 1;
        idxCleanTargets = setdiff( idxCleanTargets, find(idxTargetHadDiscontinuities{iIter}) );
        % populate SPSD cumulativeCorrection into fluxCorrectionStruct (inverse sign!!)
        % and correct flux times series
        for i=1:length(spsdOutputStruct.spsds.index)
            fluxCorrectionStruct(spsdOutputStruct.spsds.index(i)).spsd{iIter} = - spsdOutputStruct.spsds.targets(i).cumulativeCorrection;
            localTargetDataStruct(spsdOutputStruct.spsds.index(i)).values = localTargetDataStruct(spsdOutputStruct.spsds.index(i)).values + spsdOutputStruct.spsds.targets(i).cumulativeCorrection;
        end
        % check if there are uncorrectedSuspectedDiscontinuities in this iteration
        for i=1:nTargets
            [ inList , loc ] = ismember(i,spsdCorrectedFluxStruct.resultsStruct.spsds.index);
            if (inList)
                fluxCorrectionStruct(i).uncorrectedSuspectedDiscontinuity = ...
                    (fluxCorrectionStruct(i).uncorrectedSuspectedDiscontinuity || spsdOutputStruct.spsds.targets(loc).uncorrectedSuspectedDiscontinuity);
            end
        end
        spsdOutput{iIter} = spsdOutputStruct;
        % generate spsd blob
        spsdBlob = compile_spsd_blob(pdcInputObject, spsdCorrectedFluxStruct);

    else
        %=============================================
        % old (pre-8.0) discontinuity correction code
        %=============================================
        disp('  ...doing old discontinuity correction now.');
        intermediateFluxBeforeSpsd = localTargetDataStruct; % this is only to build the difference later on
        metricsKey = metrics_interval_start;
        [ discontinuities, alerts, events ] = identify_flux_discontinuities_for_all_targets( ...
                localTargetDataStruct, ...
                pdcInputObject.discontinuityConfigurationStruct, ...
                pdcInputObject.gapFillConfigurationStruct, ...
                dataAnomalyIndicators, ...
                alerts, [] );
        metrics_interval_stop('pdc.identify_flux_discontinuities_for_all_targets.execTimeMillis', metricsKey);
        
        metricsKey = metrics_interval_start;
        [ localTargetDataStruct, uncorrectedDiscontinuityTargetList, ...
            discontinuityIndices, alerts ] = ...
            correct_time_series_discontinuities_for_all_targets( ...
                localTargetDataStruct, ...
                discontinuities, ...
                pdcInputObject.discontinuityConfigurationStruct, ...
                pdcInputObject.gapFillConfigurationStruct, ...
                dataAnomalyIndicators, ...
                alerts, events );
        metrics_interval_stop('pdc.correct_time_series_discontinuities_for_all_targets.execTimeMillis', metricsKey);
            

        if (pdcDebugObject.preparation.plotSpsds)
            found = 0;
            disp('[DEBUG] listing discontinuities');        
            for i=1:nTargets           
                if (discontinuities(i).foundDiscontinuity)
                    found = 1;
                end
                disp(['[DEBUG]    found ' num2str(length(discontinuities(i).index)) ' discontinuities for target ' num2str(i) '.']);
            end
            if (~found)
                disp('[DEBUG]  found no discontinuities');
            end
        end

        
        % remove targets with discontinuities from list of targets to use for prior
        idxTargetHadDiscontinuities{iIter} = [ discontinuities(:).foundDiscontinuity ];
        idxCleanTargets = setdiff( idxCleanTargets, find(idxTargetHadDiscontinuities{iIter}) );
        % populate discontinuity into fluxCorrectionStruct
        for i = find(idxTargetHadDiscontinuities{iIter})
            fluxCorrectionStruct(i).spsd{iIter} = intermediateFluxBeforeSpsd(i).values - localTargetDataStruct(i).values;
        end
        clear intermediateFluxBeforeSpsd;    

        % Use discontinuities struct so that pdc_create_output_struct knows old spsd corrector is being used
        spsdOutput{iIter}.discontinuityIndices = discontinuityIndices;
        spsdOutput{iIter}.spsds = [];
        % no spsd blob generated from old code
        spsdBlob = [];
    
    end % (Discontinuities - if ... then new_code else old_code ...)

    if (pdcDebugObject.preparation.plotSpsds)
        s = ['[6] - after Discontinuities(' num2str(iIter) ') (kId ' int2str(localTargetDataStruct(pdcDebugObject.targetsToMonitor(1)).keplerId) ')'];
        figure; plot(localTargetDataStruct(pdcDebugObject.targetsToMonitor(1)).values,'.'); set(gcf,'Name',s); title(s);
    end

    pdcDebugObject = pdcDebugObject.add_intermediate(['after correcting Discontinuities (' int2str(iIter) ')'],localTargetDataStruct);

    
    %----------------------------------------------------------------------------------------------------
    % ID Harmonics
    if (pdcInputObject.pdcModuleParameters.harmonicsRemovalEnabled)
        disp('presearch_data_conditioning: identifying phase shifting harmonics...');
        pdctic = tic;
        metricsKey = metrics_interval_start;
    end
    for i=1:nTargets
        if (pdcInputObject.pdcModuleParameters.harmonicsRemovalEnabled)
            metricsKey = metrics_interval_start;
            [ harmonicRemovedValues, harmonicTimeSeriesValues, indexOfGiantTransits, harmonicModelStruct ] = ...
                pdc_remove_harmonics( localTargetDataStruct(i).values, ...
                                      localTargetDataStruct(i).gapIndicators, ...
                                      localConfigurationStruct.gapFillConfigurationStruct, ...
                                      localConfigurationStruct.harmonicsIdentificationConfigurationStruct ) ;
            metrics_interval_stop('pdc.pdc_remove_harmonics.execTimeMillis', metricsKey);
            memUsage.add(['after removing harmonics iteration', num2str(iIter)]);
    
            
        % populate fluxCorrectionStruct with the harmonics and remove from flux time series
            if (~isempty(harmonicTimeSeriesValues))
                idxTargetHadHarmonics{iIter}(i) = 1;
                fluxCorrectionStruct(i).harmonics{iIter} = harmonicTimeSeriesValues;
                localTargetDataStruct(i).values = harmonicRemovedValues;
            else
                fluxCorrectionStruct(i).harmonics{iIter} = [];
            end
        else
            fluxCorrectionStruct(i).harmonics{iIter} = [];
        end 
    end
    if (pdcInputObject.pdcModuleParameters.harmonicsRemovalEnabled)    
        metrics_interval_stop('pdc.pdc_remove_harmonics.all_targets.execTimeMillis', metricsKey);
        duration = toc(pdctic);
        disp(['  ...done after ' num2str(duration) ' seconds.']);
    end
    
    % remove targets with harmonics from list of targets to use for prior
    if (pdcInternalConfig.removeHarmonicTargetsFromCleanlist)
        idxCleanTargets = setdiff( idxCleanTargets, find(idxTargetHadHarmonics{iIter}) );
    end
    
    if (pdcDebugObject.preparation.plotHarmonics)
        found = 0;
        for i=1:nTargets
            if (idxTargetHadHarmonics{iIter}(i))
                found = found+1;
                disp(['[DEBUG]    found harmonics in target #' num2str(i)]);
            end
        end
        disp(['[DEBUG]    found harmonics in ' int2str(found) ' targets']);
        s = ['[5] - after Harmonics(' num2str(iIter) ') (kId ' int2str(localTargetDataStruct(pdcDebugObject.targetsToMonitor(1)).keplerId) ')'];
        figure; plot(localTargetDataStruct(pdcDebugObject.targetsToMonitor(1)).values,'.'); set(gcf,'Name',s); title(s);
    end
    
    if (pdcInputObject.pdcModuleParameters.harmonicsRemovalEnabled)
        pdcDebugObject = pdcDebugObject.add_intermediate(['after removing Harmonics (' int2str(iIter) ')'],localTargetDataStruct);
    end
        
    
    %----------------------------------------------------------------------------------------------------
    
    % detect Outliers. set their values to 0 and gap them, then do gap filling
    pdctic = tic;
    disp('presearch_data_conditioning: identifying and removing outliers...');
    outlierDetectTargetDataStruct = localTargetDataStruct;
    % Detect outliers and gap them
    metricsKey = metrics_interval_start;
    [ outliers, outlierDetectTargetDataStruct ] = pdc_detect_outliers( ...
            outlierDetectTargetDataStruct, ...
            pdcInputObject.pdcModuleParameters, ...
            pdcInputObject.gapFillConfigurationStruct );
    memUsage.add(['Outliers detected iteration', num2str(iIter)]);
    

    metrics_interval_stop('pdc.pdc_detect_outliers.execTimeMillis', metricsKey);
    % Fill those gaps.
    % -- using simple (but fast!) gap filling
    metricsKey = metrics_interval_start;
    [outlierDetectTargetDataStruct, ~] = pdc_fill_gaps(outlierDetectTargetDataStruct,pdcInputObject.cadenceTimes);
    metrics_interval_stop('pdc.pdc_fill_gaps.execTimeMillis', metricsKey);
    duration = toc(pdctic);
    disp(['Outliers detected and removed: ' num2str(duration) ' seconds = '  num2str(duration/60) ' minutes']);
    
    if (pdcDebugObject.preparation.plotOutliers)
        disp('[DEBUG] listing outliers');
        for i=1:nTargets
            disp(['[DEBUG]    found ' num2str(length(outliers(i).values)) ' outliers for target ' num2str(i) '.']);
        end
    end
    
    % store Outliers in fluxCorrectionStruct, and update localTargetDataStruct
    % for the outliers, two fields are being stored. probably only the first one will be used,
    % so check again later if the second one can be omitted
    % IMPORTANT: we do not update the gapIndicators. they should still be preserved for functions         
    for i=1:nTargets
        fluxCorrectionStruct(i).outlierStruct{iIter} = outliers(i);
        fluxCorrectionStruct(i).outliers{iIter} = localTargetDataStruct(i).values - outlierDetectTargetDataStruct(i).values;
        localTargetDataStruct(i).values = outlierDetectTargetDataStruct(i).values;
        if (pdcInputObject.thisIsK2Data)
            % Add the outliers to the target gapIndicators IF this is K2 data
            localTargetDataStruct(i).gapIndicators(find(outlierDetectTargetDataStruct(i).gapIndicators)) = true;
        end

    end
    clear outlierDetectTargetDataStruct;

    if (pdcDebugObject.preparation.plotOutliers)
        s = ['[7] - after Outliers(' num2str(iIter) ') (kId ' int2str(localTargetDataStruct(pdcDebugObject.targetsToMonitor(1)).keplerId) ')'];
        figure; plot(localTargetDataStruct(pdcDebugObject.targetsToMonitor(1)).values,'.'); set(gcf,'Name',s); title(s);
    end

    pdcDebugObject = pdcDebugObject.add_intermediate(['after removing Outliers (' int2str(iIter) ')'],localTargetDataStruct);
    

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end % for iIter = 1:pdcInputObject.pdcModuleParameters.preMapIterations

% save spsdOutput and spsdBlob for use by pdc_create_output_Struct
intelligent_save('spsdOutput', 'spsdOutput');
intelligent_save('spsdBlob', 'spsdBlob');

%----------------------------------------------------------------------------------------------------
targetsToUseForBasisVectorsAndPriors = false(nTargets,1);
targetsToUseForBasisVectorsAndPriors(idxCleanTargets) = true;

if (pdcDebugObject.dispCleanTargets)
    disp('Targets to use for priors:');
    disp(find(targetsToUseForBasisVectorsAndPriors));
end


%----------------------------------------------------------------------------------------------------
% For K2 data recalculate the variability with coarse MAP and everything else removed
if (pdcInputObject.thisIsK2Data)
    disp('Calculating stellar variability with Coarse MAP removed for K2...');
    doNormalizeFlux = 'noiseFloor';

    [variabilityStructK2.variability, variabilityStructK2.medianVariability] = ...
         pdc_calculate_stellar_variability (localTargetDataStruct, pdcInputObject.cadenceTimes, ...
                  pdcInputObject.pdcModuleParameters.variabilityDetrendPolyOrder, doNormalizeFlux, ...
                  pdcInputObject.pdcModuleParameters.variabilityEpRecoveryMaskEnabled, ...
                  pdcInputObject.pdcModuleParameters.variabilityEpRecoveryMaskWindow, ...
                  pdcInputObject.pdcModuleParameters.stellarVariabilityRemoveEclipsingBinariesEnabled);

    disp('Stellar variability calculated!');
else
    variabilityStructK2 = [];
end


%----------------------------------------------------------------------------------------------------
% remove H,D,O from y_tilde_all
% This is actually not perform, In it's stead we call map_remove_map_correction which is equivalent. Keeping
% lines here for reference just in case someone wonders what's going on.
% localTargetDataStruct = pdc_remove_hdo_from_flux( localTargetDataStruct, harmonics, discontinuities, outliers );
%----------------------------------------------------------------------------------------------------

%----------------------------------------------------------------------------------------------------
% -- generate [ y_tilde - H - D - O ]
% The input to MAP should be the original flux, with outliers, harmonics, and discontinuities removed.
% This is equivalent of the current localTargetDataStruct when adding back the coarseMap results.

% Add the coarse MAP correction back in.
coarseMapStructFilename = 'mapResultsStruct_Coarse';
localTargetDataStruct = map_remove_map_correction (localTargetDataStruct, coarseMapStructFilename , ...
                        nonbsMapConfigurationStruct.fitNormalizationMethod, ...
                        pdcInputObject.cadenceTimes, pdcInputObject.pdcModuleParameters);

system(['rm ', coarseMapStructFilename]);

pdcDebugObject = pdcDebugObject.add_intermediate('after removing coarseMAP correction',localTargetDataStruct);

%----------------------------------------------------------------------------------------------------
% Perform spike removal using the spike basis Vectors found in coarse MAP
% This operation is performed after removing the coarse map correction above. The coarse regular basis vectors contains the spike features still in them and so
% the coarse MAP correction will partially remove the spikes. If the spike removing occurs on the coarse MAP corrected light curves then the spikes would not be
% completely removed once the coarse MAP correction is removed.
if (~isempty(spikeBasisVectors))
    localTargetDataStruct = pdc_remove_spikes (localTargetDataStruct, spikeBasisVectors, pdcInputObject.mapConfigurationStruct.spikeBasisVectorWindow);
end

pdcDebugObject = pdcDebugObject.add_intermediate('after removing spikes',localTargetDataStruct);

% -- END [blue box] --
%====================================================================================================

return
