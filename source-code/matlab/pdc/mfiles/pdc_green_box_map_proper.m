%%====================================================================================================
%% GREEN BOX
%% msMAP and Regular MAP
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

% INPUTS:
%   - y_tilde-H-D-O
%   - y_tilde_clean from [select_clean]
% inputs to prepare from above:
% -        inputsStruct.mapConfigurationStruct: just pass input
% -        inputsStruct.pdcModuleParameters: just pass input
% -        localTargetDataStruct: populated correctly with gaps
% -        targetsToUseForBasisVectorsAndPriors: indices of clean targets, from SPSD

function [localTargetDataStruct, alerts, fluxCorrectionStruct, variabilityStruct, pdcDebugObject] = ...
    pdc_green_box_map_proper (...
        localTargetDataStruct, ...
        pdcInputObject, ...
        cbvBlobStruct, ...
        uberDiagnosticStruct, ...
        mapBlobStruct, ...
        localMotionPolyStruct, ...
        fluxCorrectionStruct, ...
        pdcDebugObject, ...
        pdcInternalConfig, ...
        nonbsMapConfigurationStruct, ...
        targetsToUseForBasisVectorsAndPriors, ...
        bsMapConfigurationStructArray, ...
        alerts, ...
        variabilityStructK2)


global memUsage;

% Create taskInfoStruct containing task-specific information
taskInfoStruct = struct('ccdModule', pdcInputObject.ccdModule, 'ccdOutput', pdcInputObject.ccdOutput, 'quarter', pdcInputObject.cadenceTimes.quarters(1), ...
                        'month', pdcInputObject.cadenceTimes.months(1), 'thisIsK2Data', pdcInputObject.thisIsK2Data);

% When calculating Goodness also compute EP Goodness (it's slower than the other components and is optional)
doCalcEpGoodness = true;

nTargets = length(pdcInputObject.targetDataStruct);
% nCadences = length(pdcInputObject.cadenceTimes.cadenceNumbers);

% number of bands for band-splitting
if (~pdcInputObject.pdcModuleParameters.bandSplittingEnabled)
    nBands = 1;
else
    nBands = pdcInputObject.bandSplittingConfigurationStruct.numberOfBands;
end


%----------------------------------------------------------------------------------------------------
% If this is K2 data then use the stellar variability calculated with coarse MAP fit is removed

if (pdcInputObject.thisIsK2Data)
    
    disp('For K2 data use the variability calculated with the Coarse MAP fit removed.');

    variabilityStruct = variabilityStructK2;
else
    %----------------------------------------------------------------------------------------------------
    % Calculate Stellar Variability outside of MAP so that band-splitting does not screw up the calculation
    % It may be fine to use the variability from the coarse map above but it's a quick calculation so not
    % necessary, might as well calculate it again.
    disp('Calculating stellar variability...');
    doNormalizeFlux = true;

    [variabilityStruct.variability, variabilityStruct.medianVariability] = ...
         pdc_calculate_stellar_variability (localTargetDataStruct, pdcInputObject.cadenceTimes, ...
                  pdcInputObject.pdcModuleParameters.variabilityDetrendPolyOrder, doNormalizeFlux, ...
                  pdcInputObject.pdcModuleParameters.variabilityEpRecoveryMaskEnabled, ...
                  pdcInputObject.pdcModuleParameters.variabilityEpRecoveryMaskWindow, ...
                  pdcInputObject.pdcModuleParameters.stellarVariabilityRemoveEclipsingBinariesEnabled);

    disp('Stellar variability calculated!');
    memUsage.add('Stellar variability calculated for full MAP');
end



%% ==============================================================================

% ===============================
% BAND SPLITTING
% ===============================

% initialize the outputs here, so that only the values and uncertainties can be copied over later
%targetDataStructAfterBsMap = localTargetDataStruct;
%targetDataStructAfterNonBsMap = localTargetDataStruct;


if (pdcInputObject.pdcModuleParameters.bandSplittingEnabled)
%% MAP with band splitting
    % perform band-splitting
    disp('Performing band-splitting...');
    pdctic = tic;
    [targetDataStructBandsAndWaveletCoefficients] = bs_controller_split( localTargetDataStruct , ...
                                                                    pdcInputObject.bandSplittingConfigurationStruct ,  ...
                                                                    uberDiagnosticStruct.bsDiagnosticStruct );
    targetDataStructBands = targetDataStructBandsAndWaveletCoefficients.bands;
    % targetDataStructBandsAndWaveletCoefficients is really big so clear since iut's not used anymore
    clear targetDataStructBandsAndWaveletCoefficients;
    duration = toc(pdctic);
    display(['Band-splitting performed: ' num2str(duration) ' seconds = '  num2str(duration/60) ' minutes']);
    memUsage.add('Flux band split');

    %----------------------------------------------------------------------------------------------------
    pdctic = tic;
    metricsKey = metrics_interval_start;


    % this is the "real" MAP, so save figures

    uberDiagnosticStruct.mapDiagnosticStruct.doSaveResultsStruct = true;
    uberDiagnosticStruct.mapDiagnosticStruct.doFigures           = true;
    uberDiagnosticStruct.mapDiagnosticStruct.doSaveFigures       = true;
    uberDiagnosticStruct.mapDiagnosticStruct.doCloseAfterSaveFigures = true;

    % Initialize
    msMapCorrectedTargetDataStruct = cell(1,nBands);
    goodnessBands = cell(1,nBands);
    
    % Run MAP on the bands in reverse order. This is so that if wavelet denoising is enabled, we can
    % derive the universal threshold from band 3 and use it with band 2.
    bandList = fliplr(1:nBands);
    
    
   % Do MAP for each band
   for iBand = bandList

        uberDiagnosticStruct.mapDiagnosticStruct.runLabel = ['Band_', num2str(iBand)];

        cbvBlobStructThisBand = cbvBlobStruct;
        % If using basis vectors from blob then we need to get the right basis vectors for this band
        if (bsMapConfigurationStructArray{iBand}.useBasisVectorsFromBlob || ...
                    bsMapConfigurationStructArray{iBand}.useBasisVectorsAndPriorsFromBlob)
            if (isempty(cbvBlobStruct.basisVectorsBandSplit)) 
                error('msmap: loading basis vectors from blob but the band-split basis vectors are not in blob! if band splitting then blob must be generated from a band-split pdc run.')
            end
            % Map is ignorant of bands so just copy this band's basis vectors and fit coefficients to the *nobands fields
            % If the basis vectors for this band are empty then pass the empty set forcing map to fail for this band
            cbvBlobStructThisBand.basisVectorsNoBands =          cbvBlobStruct.basisVectorsBandSplit(iBand).basisVectors;
            cbvBlobStructThisBand.robustFitCoefficientsNoBands = cbvBlobStruct.robustFitCoefficientsBandSplit(iBand).coeffs;
            cbvBlobStructThisBand.priorPdfInfonoBands =          cbvBlobStruct.priorPdfInfoBandSplit(iBand);
        end

        [msMapCorrectedTargetDataStruct{iBand}, alertsOneBand] = map_controller( bsMapConfigurationStructArray{iBand}, ...
                                               pdcInputObject.pdcModuleParameters, ...
                                               targetDataStructBands{iBand}, ...
                                               pdcInputObject.cadenceTimes, ...
                                               targetsToUseForBasisVectorsAndPriors, ...
                                               uberDiagnosticStruct.mapDiagnosticStruct, ...
                                               variabilityStruct, mapBlobStruct, cbvBlobStructThisBand, ...
                                               pdcInputObject.goodnessMetricConfigurationStruct, ...
                                               localMotionPolyStruct, pdcInputObject.multiChannelMotionPolyStruct, taskInfoStruct );

        % collect alerts from all bands
        % Alerts are labelled for each band
        %alerts = [ alerts , msMapResultsObjectOneBand.alerts ];
        alerts = [ alerts , alertsOneBand ];

        memUsage.add(['BS MAP for band ', num2str(iBand)]);

       %clear msMapResultsObjectOneBand;

    end

    metrics_interval_stop('pdc.map_controller.execTimeMillis', metricsKey);

    duration = toc(pdctic);
    display(['Multiscale MAP fit performed: ' num2str(duration) ' seconds = '  num2str(duration/60) ' minutes']);
   
    % NOTE: mapResultsStruct is saved internally to map_controller using the uberDiagnosticStruct.mapDiagnosticStruct.runLabel
    % to label each band.

    % generate cumulative MAP fit across all bands

    % Do not calculate CDPP
    gapFillConfigurationStruct = [];
    % goodness metric for individual bands
    % Do not calculate spike removal goodness
    if (uberDiagnosticStruct.dataStructSaving.saveGoodnessMetricForBands)        
        doSavePlots = true;
        doNormalizeFlux = true;
        for iBand=1:nBands
           goodnessBands{iBand} = pdc_goodness_metric( targetDataStructBands{iBand} , ...
                                                   msMapCorrectedTargetDataStruct{iBand}, ...
                                                   pdcInputObject.cadenceTimes, ...
                                                   [], ...
                                                   pdcInputObject.pdcModuleParameters, ...
                                                   pdcInputObject.goodnessMetricConfigurationStruct, gapFillConfigurationStruct, ...
                                                   doNormalizeFlux, doSavePlots, ...
                                                   ['Band ' int2str(iBand)], ...
                                                   ['_band_' int2str(iBand)], doCalcEpGoodness  );                                                                      
            memUsage.add(['Goodness calulated for band ', num2str(iBand)]);

        end
        intelligent_save('goodnessBands','goodnessBands'); % not necessary to save individual files here, cell array small enough
    end
        
    % Combine bands again
    [ targetDataStructAfterBsMap ] = bs_controller_combine(msMapCorrectedTargetDataStruct, nTargets, nBands);

    memUsage.add('Bands combined');
    
    % END OF BAND SPLITTING    
else
    targetDataStructAfterBsMap = [];
end

clear msMapCorrectedTargetDataStruct;

%% ====== perform a regular MAP run ======
    pdctic = tic;
    metricsKey = metrics_interval_start;

    % This is the "real" MAP, so save figures

    uberDiagnosticStruct.mapDiagnosticStruct.doSaveResultsStruct = true;
    uberDiagnosticStruct.mapDiagnosticStruct.doFigures           = true;
    uberDiagnosticStruct.mapDiagnosticStruct.doSaveFigures       = true;
    uberDiagnosticStruct.mapDiagnosticStruct.doCloseAfterSaveFigures = true;
    uberDiagnosticStruct.mapDiagnosticStruct.runLabel = 'no_BS';

    [targetDataStructAfterNonBsMap, alertsRegular, basisVectorsRegular, spikeBasisVectorsRegular] = map_controller( nonbsMapConfigurationStruct, ...
                                           pdcInputObject.pdcModuleParameters, ...
                                           localTargetDataStruct, ...
                                           pdcInputObject.cadenceTimes, ...
                                           targetsToUseForBasisVectorsAndPriors, ...
                                           uberDiagnosticStruct.mapDiagnosticStruct, ...
                                           variabilityStruct, mapBlobStruct, cbvBlobStruct, ...
                                           pdcInputObject.goodnessMetricConfigurationStruct, ...
                                           localMotionPolyStruct, pdcInputObject.multiChannelMotionPolyStruct, taskInfoStruct );

    memUsage.add('Regular MAP completed');

    alerts = [ alerts , alertsRegular ];

    metrics_interval_stop('pdc.map_controller.execTimeMillis', metricsKey);

    duration = toc(pdctic);
    display(['Regular MAP fit performed: ' num2str(duration) ' seconds = '  num2str(duration/60) ' minutes']);

% ====== end of regular MAP run ======

%% -- DIAGNOSTIC BLOCK BEGIN -- (can be removed later)
% we have 4 targetDataStructs now:
% - localTargetDataStruct           - the original data before band-splitting and/or MAP
% - targetDataStructBands           - the band-splitted input to MAP
% - targetDataStructAfterBsMap      - data after the band-splitted MAP run
% - targetDataStructAfterNonBsMap   - data after the regular MAP run

% let's save them for diagnostic purposes for now
% - in particular to allow for direct comparison during testing and parameter refinement

if (pdcInputObject.pdcModuleParameters.bandSplittingEnabled)
    % SAVE localTargetDataStruct before band-splitting
    if (uberDiagnosticStruct.dataStructSaving.saveTargetDataStructBeforeBandSplitting)
        targetDataStruct_beforeBS = localTargetDataStruct;
        intelligent_save('targetDataStruct_beforeBS','targetDataStruct_beforeBS');
        clear targetDataStruct_beforeBS;
    end

    % SAVE targetDataStructBands
    if (uberDiagnosticStruct.dataStructSaving.saveTargetDataStructForBands)
        for k=1:nBands
            eval(['targetDataStructBands_' int2str(k) ' = targetDataStructBands{k};']);
            intelligent_save(['targetDataStructBands_' int2str(k)],['targetDataStructBands_' int2str(k)]);
            eval(['clear targetDataStructBands_' int2str(k)]);
        end
    end
    
    % SAVE targetDataStructAfterBsMap
    if (uberDiagnosticStruct.dataStructSaving.saveTargetDataStructAfterBsMap)
        intelligent_save('targetDataStructAfterBsMap','targetDataStructAfterBsMap');
    end
end


% SAVE targetDataStructAfterNonBsMap
if (uberDiagnosticStruct.dataStructSaving.saveTargetDataStructAfterMap)
    intelligent_save('targetDataStructAfterNonBsMap','targetDataStructAfterNonBsMap');
end

% -- DIAGNOSTIC BLOCK END -- (can be removed later)


%% POU and outputs from the whole bsMAP / MAP block:
%  we have several options here:
%  1) use uncertainties which were band-splitted    - a (crude?) approximation
%  2) do a proper POU for each band                 - could be done in the POU-task in 8.3 or maybe earlier
%  3) use the uncertainties of the regular MAP run  - probably pretty similar, and we do it anyway
%  for now, we do (3)

%% calc Goodness Metric for both runs
doSavePlots = true;
doNormalizeFlux = true;

% Spike removal happens before the green box so the perofmrance is identical between regualr and msMAP.
basisVectorsForGoodness = [];

% Do not calculate CDPP
gapFillConfigurationStruct = [];
goodnessRegular = pdc_goodness_metric( localTargetDataStruct , ...
                                        targetDataStructAfterNonBsMap, ...
                                        pdcInputObject.cadenceTimes, ...
                                        basisVectorsForGoodness , ...
                                        pdcInputObject.pdcModuleParameters, ...
                                        pdcInputObject.goodnessMetricConfigurationStruct, gapFillConfigurationStruct,...
                                        doNormalizeFlux, doSavePlots, ...
                                        'regular MAP ', ...
                                        '_interm_regularMAP', doCalcEpGoodness);

memUsage.add('Regular MAP goodness calculated');

if (pdcInputObject.pdcModuleParameters.bandSplittingEnabled)
    goodnessMultiscale = pdc_goodness_metric( localTargetDataStruct , ...
                                              targetDataStructAfterBsMap, ...
                                              pdcInputObject.cadenceTimes, ...
                                              basisVectorsForGoodness , ...
                                              pdcInputObject.pdcModuleParameters, ...
                                              pdcInputObject.goodnessMetricConfigurationStruct, gapFillConfigurationStruct, ...
                                              doNormalizeFlux, doSavePlots, ...
                                              'multiscale MAP ', ...
                                              '_interm_multiscaleMAP', doCalcEpGoodness);

    memUsage.add('msMAP goodness calculated');
end

if (uberDiagnosticStruct.dataStructSaving.saveGoodnessMetricMap)
    intelligent_save('goodnessRegular','goodnessRegular');
end
if (pdcInputObject.pdcModuleParameters.bandSplittingEnabled && uberDiagnosticStruct.dataStructSaving.saveGoodnessMetricBsMap)
    intelligent_save('goodnessMultiscale','goodnessMultiscale');
end

selectTic = tic;
display('Selecting best fit...');

%% copy values and uncertainties from multiscaleMAP or regularMAP
% get values from respective run
switch (pdcInputObject.pdcModuleParameters.mapSelectionMethod)
    case 'multiscale'            
        if (~pdcInputObject.pdcModuleParameters.bandSplittingEnabled)
            error('pdcInternalConfig.mapResultsValuesToUse: Multi-Scale map not performed');
        end
        for iTarget=1:nTargets
            localTargetDataStruct(iTarget).values = targetDataStructAfterBsMap(iTarget).values;
            fluxCorrectionStruct(iTarget).multiscaleMapUsed = true;
        end
    case 'regular'
        for iTarget=1:nTargets
            localTargetDataStruct(iTarget).values = targetDataStructAfterNonBsMap(iTarget).values;
            fluxCorrectionStruct(iTarget).multiscaleMapUsed = false;
        end
    case 'goodnessTotal'
        if (~pdcInputObject.pdcModuleParameters.bandSplittingEnabled)
            error('pdcModuleParameters.mapSelectionMethod: Multi-Scale map not performed');
        end
        for iTarget=1:nTargets
            if (goodnessMultiscale(iTarget).total.value + pdcInputObject.pdcModuleParameters.mapSelectionMethodMultiscaleBias ...
                                                                >= goodnessRegular(iTarget).total.value)
                localTargetDataStruct(iTarget).values = targetDataStructAfterBsMap(iTarget).values;
                fluxCorrectionStruct(iTarget).multiscaleMapUsed = true;
            else
                localTargetDataStruct(iTarget).values = targetDataStructAfterNonBsMap(iTarget).values;
                fluxCorrectionStruct(iTarget).multiscaleMapUsed = false;
            end
        end
    case 'noiseVariability'
        if (~pdcInputObject.pdcModuleParameters.bandSplittingEnabled)
            error('pdcModuleParameters.mapSelectionMethod: Multi-Scale map not performed');
        end
        for iTarget=1:nTargets
            useRegularMap.introducedNoise = ...
                    (goodnessMultiscale(iTarget).introducedNoise.value  < pdcInputObject.pdcModuleParameters.mapSelectionMethodCutoff) ...
                 && (goodnessRegular(iTarget).introducedNoise.value  - goodnessMultiscale(iTarget).introducedNoise.value > ...
                                                                                pdcInputObject.pdcModuleParameters.mapSelectionMethodMultiscaleBias);
            useRegularMap.deltaVariability = ...
                    (goodnessMultiscale(iTarget).deltaVariability.value  < pdcInputObject.pdcModuleParameters.mapSelectionMethodCutoff) ...
                 && (goodnessRegular(iTarget).deltaVariability.value  - goodnessMultiscale(iTarget).deltaVariability.value > ...
                                                                                pdcInputObject.pdcModuleParameters.mapSelectionMethodMultiscaleBias);
            useRegularMap.total = useRegularMap.introducedNoise || useRegularMap.deltaVariability;
            % Only consider using regular MAP if the msMAP goodness is below the cutoff
            if (useRegularMap.total)
                % use regular Map results
                localTargetDataStruct(iTarget).values = targetDataStructAfterNonBsMap(iTarget).values;
                fluxCorrectionStruct(iTarget).multiscaleMapUsed = false;
            else
                % Use msMAP results
                localTargetDataStruct(iTarget).values = targetDataStructAfterBsMap(iTarget).values;
                fluxCorrectionStruct(iTarget).multiscaleMapUsed = true;
            end
        end
    case 'noiseVariabilityEarthpoints'
        if (~pdcInputObject.pdcModuleParameters.bandSplittingEnabled)
            error('pdcModuleParameters.mapSelectionMethod: Multi-Scale map not performed');
        end
        for iTarget=1:nTargets
            useRegularMap.introducedNoise = ...
                    (goodnessMultiscale(iTarget).introducedNoise.value  < pdcInputObject.pdcModuleParameters.mapSelectionMethodCutoff) ...
                 && (goodnessRegular(iTarget).introducedNoise.value  - goodnessMultiscale(iTarget).introducedNoise.value > ...
                                                                                pdcInputObject.pdcModuleParameters.mapSelectionMethodMultiscaleBias);
            useRegularMap.deltaVariability = ...
                    (goodnessMultiscale(iTarget).deltaVariability.value  < pdcInputObject.pdcModuleParameters.mapSelectionMethodCutoff) ...
                 && (goodnessRegular(iTarget).deltaVariability.value  - goodnessMultiscale(iTarget).deltaVariability.value > ...
                                                                                pdcInputObject.pdcModuleParameters.mapSelectionMethodMultiscaleBias);
            useRegularMap.earthPointRemoval = ...
                    (goodnessMultiscale(iTarget).earthPointRemoval.value  < pdcInputObject.pdcModuleParameters.mapSelectionMethodCutoff) ...
                 && (goodnessRegular(iTarget).earthPointRemoval.value  - goodnessMultiscale(iTarget).earthPointRemoval.value > ...
                                                                                pdcInputObject.pdcModuleParameters.mapSelectionMethodMultiscaleBias);
            useRegularMap.total = useRegularMap.introducedNoise || useRegularMap.deltaVariability || useRegularMap.earthPointRemoval;
            % Only consider using regular MAP if the msMAP goodness is below the cutoff
            if (useRegularMap.total)
                % use regular Map results
                localTargetDataStruct(iTarget).values = targetDataStructAfterNonBsMap(iTarget).values;
                fluxCorrectionStruct(iTarget).multiscaleMapUsed = false;
            else
                % Use msMAP results
                localTargetDataStruct(iTarget).values = targetDataStructAfterBsMap(iTarget).values;
                fluxCorrectionStruct(iTarget).multiscaleMapUsed = true;
            end
        end
    case 'noneRobustMap'
        % Compares three fits: 1) none 2) Robust 3) MAP 4) msMAP and picks the best based on CDPP
        [localTargetDataStruct, fluxCorrectionStruct] = select_best_fit_none_robust_map_msmap (targetDataStructAfterNonBsMap, targetDataStructAfterBsMap, ...
                                                                                localTargetDataStruct, pdcInputObject, fluxCorrectionStruct);
    otherwise
        error('please provide a correct method for pdcModuleParameters.mapSelectionMethod');    
end
    
duration = toc(selectTic);
display(['Finished selecting best fit: ' num2str(duration) ' seconds = '  num2str(duration/60) ' minutes']);

% get uncertainties from respective run
switch (pdcInternalConfig.mapResultsUncertaintiesToUse)
    case 'multiscale'            
        if (~pdcInputObject.pdcModuleParameters.bandSplittingEnabled)
            error('pdcInternalConfig.mapResultsValuesToUse: Multi-Scale map not performed');
        end
        for iTarget=1:nTargets
            localTargetDataStruct(iTarget).uncertainties = targetDataStructAfterBsMap(iTarget).uncertainties;
        end
    case 'regular'
        for iTarget=1:nTargets
            localTargetDataStruct(iTarget).uncertainties = targetDataStructAfterNonBsMap(iTarget).uncertainties;
        end
    case 'goodnessTotal'
        if (~pdcInputObject.pdcModuleParameters.bandSplittingEnabled)
            error('pdcInternalConfig.mapResultsValuesToUse: Multi-Scale map not performed');
        end
        for iTarget=1:nTargets
            if (goodnessMultiscale(iTarget).total.value + ...
                    pdcInputObject.pdcModuleParameters.mapSelectionMethodMultiscaleBias >= goodnessRegular(iTarget).total.value)
                localTargetDataStruct(iTarget).uncertainties = targetDataStructAfterBsMap(iTarget).uncertainties;
            else
                localTargetDataStruct(iTarget).uncertainties = targetDataStructAfterNonBsMap(iTarget).uncertainties;
            end
        end
    otherwise
        error('please provide a correct method for pdcInternalConfig.mapResultsUncertaintiesToUse');    
end



% clear unused data
clear targetDataStructBands;
clear targetDataStructAfterBsMap
clear targetDataStructAfterNonBsMap;

pdcDebugObject = pdcDebugObject.add_intermediate('after MAP fit',localTargetDataStruct);

end

% -- END [green box] --
%%====================================================================================================

%*****************************************************************************************************
% function [localTargetDataStruct, fluxCorrectionStruct] = select_best_fit_none_robust_map_msmap (targetDataStructAfterNonBsMap, targetDataStructAfterBsMap, ...
%                                                                               localTargetDataStruct, pdcInputObject)
%
% This will compare 4 fits and picks the best based on CDPP:
% 1) no fit
% 2) robust fit
% 3) MAP fit
% 4) msMAP fit
%
% Inputs: 
%   targetDataStructAfterNonBsMap   -- [targetDataStruct] From MAP fit
%   targetDataStructAfterBsMap      -- [targetDataStruct] From msMAP fit                                                                         
%   noFitTargetDataStruct           -- [targetDataStruct] No fit
%   pdcInputObject                  -- [pdcInputClass
%   fluxCorrectionStruct            -- contains info on the selected fit type
%
%   Note: The reduced robust fit coefficients and basis vectors are loaded from shortMapResultsStruct_no_BS.
%
% Outputs:
%   localTargetDataStruct           -- [targetDataStruct] with the selected fit residual
%       .values                         -- only this field updated
%   fluxCorrectionStruct            -- contains info on the selected fit type
%       .multiscaleMapUsed 
%       .selectedFit 
% 
%
%*****************************************************************************************************
function [noFitTargetDataStruct, fluxCorrectionStruct] = select_best_fit_none_robust_map_msmap (targetDataStructAfterNonBsMap, targetDataStructAfterBsMap, ...
                                                                              noFitTargetDataStruct, pdcInputObject, fluxCorrectionStruct)

    nTargets  = length(noFitTargetDataStruct);
    nCadences = length(noFitTargetDataStruct(1).values);

    gapFilledTimestamps  = pdc_fill_cadence_times (pdcInputObject.cadenceTimes);

    %***
    % Normalize Flux
    doNanGaps = false;
    doMaskEpRecovery = true;
    normMethod = 'median';
    [normalizedTargetDataStructAfterNonBsMap] = mapNormalizeClass.normalize_flux (targetDataStructAfterNonBsMap, normMethod, doNanGaps, ...
                doMaskEpRecovery, pdcInputObject.cadenceTimes, pdcInputObject.pdcModuleParameters.variabilityEpRecoveryMaskWindow); 
    if (~isempty(targetDataStructAfterBsMap))
        [normalizedTargetDataStructAfterBsMap] = mapNormalizeClass.normalize_flux (targetDataStructAfterBsMap, normMethod, doNanGaps, ...
                doMaskEpRecovery, pdcInputObject.cadenceTimes, pdcInputObject.pdcModuleParameters.variabilityEpRecoveryMaskWindow); 
    end
    [normalizedNoFitTargetDataStruct] = mapNormalizeClass.normalize_flux (noFitTargetDataStruct, normMethod, doNanGaps, ...
                doMaskEpRecovery, pdcInputObject.cadenceTimes, pdcInputObject.pdcModuleParameters.variabilityEpRecoveryMaskWindow); 

    %***
    % We need to generate the robust fit from the saved data in the noBS file.
    load 'shortMapResultsStruct_no_BS'
    if (~exist('shortMapResultsStruct_no_BS', 'var'))
        error('shortMapResultsStruct_no_BS does not seem to exist');
    end

    normalizedRobustFitTargetDataStruct = normalizedNoFitTargetDataStruct;
    nRobustFitCoeffs = length(shortMapResultsStruct_no_BS.intermediateMapResults(1).robustFitCoefficients);
    nBasisVectorsForReducedRobustFit = min(nRobustFitCoeffs, pdcInputObject.mapConfigurationStruct.svdOrderForReducedRobustFit);
    for iTarget = 1 : nTargets
        reducedRobustFitCoeffs = [shortMapResultsStruct_no_BS.intermediateMapResults(iTarget).robustFitCoefficients(1:nBasisVectorsForReducedRobustFit)];
        normalizedReducedRobustFit = shortMapResultsStruct_no_BS.basisVectors(:,1:nBasisVectorsForReducedRobustFit) * reducedRobustFitCoeffs;
        % we want the normalized values so no need to denormalize
        normalizedRobustFitTargetDataStruct(iTarget).values = normalizedNoFitTargetDataStruct(iTarget).values - normalizedReducedRobustFit;
    end
    
    

    %***
    % Calculate CDPP and find best fit
    for iTarget = 1 : nTargets
        

        noFitCdpp   = calculate_cdpp (normalizedNoFitTargetDataStruct(iTarget), gapFilledTimestamps, pdcInputObject.gapFillConfigurationStruct);
        robustCdpp  = calculate_cdpp (normalizedRobustFitTargetDataStruct(iTarget), gapFilledTimestamps, pdcInputObject.gapFillConfigurationStruct);

        % If MAP was not performed on this target then pick between no fit and robust fit
        if (shortMapResultsStruct_no_BS.targetsMapAppliedTo(iTarget))
            mapCdpp     = calculate_cdpp (normalizedTargetDataStructAfterNonBsMap(iTarget), gapFilledTimestamps, pdcInputObject.gapFillConfigurationStruct);
        else
            mapCdpp = NaN;
        end

        if (~isempty(targetDataStructAfterBsMap))
            msMapCdpp   = calulate_cdpp (normalizedTargetDataStructAfterBsMap(iTarget), gapFilledTimestamps, pdcInputObject.gapFillConfigurationStruct);
        else
            msMapCdpp = NaN; % min ignores NaNs
        end

        [minVal, minLoc] = min([noFitCdpp robustCdpp mapCdpp msMapCdpp]);

        switch minLoc
            case 1
                % No fit is best
                % noFitTargetDataStruct is already set!
                % noFitTargetDataStruct(iTarget).values = noFitTargetDataStruct(iTarget).values;
                fluxCorrectionStruct(iTarget).multiscaleMapUsed = false;
                fluxCorrectionStruct(iTarget).selectedFit = 'noFit';
 
            case 2
                % Robust fit is best
                unormalizedRobustFit = mapNormalizeClass.denormalize_flux(normalizedRobustFitTargetDataStruct(iTarget));
                noFitTargetDataStruct(iTarget).values = unormalizedRobustFit.values;
                fluxCorrectionStruct(iTarget).multiscaleMapUsed = false;
                fluxCorrectionStruct(iTarget).selectedFit = 'robust';

            case 3
                % MAP fit is best
                noFitTargetDataStruct(iTarget).values = targetDataStructAfterNonBsMap(iTarget).values;
                fluxCorrectionStruct(iTarget).multiscaleMapUsed = false;
                fluxCorrectionStruct(iTarget).selectedFit = 'MAP';

            case 3
                % msMAP fit is best
                noFitTargetDataStruct(iTarget).values = targetDataStructAfterBsMap(iTarget).values;
                fluxCorrectionStruct(iTarget).multiscaleMapUsed = true;
                fluxCorrectionStruct(iTarget).selectedFit = 'msMAP';

            otherwise

        end


    end


end

%*****************************************************************************************************
% function calculate_cdpp (targetDataStruct, gapFilledTimestamps, gapFillConfigurationStruct)
%
% Based on method in PDC Goodness Metric
% TODO: add text here!
%*****************************************************************************************************

function cdpp = calculate_cdpp (targetDataStruct, gapFilledTimestamps, gapFillConfigurationStruct)

    cdppMedFiltSmoothLength = 100;

    % Flux here is normalized
    gaps = targetDataStruct.gapIndicators;
    flux = targetDataStruct.values;
    
    %***
    % Condition the data for CDPP
    flux(gaps) = nan;
    
    % NaNs will "NaN" the medfilt1 values within cdppMedFiltSmoothLength cadences from each NaNed cadence, 
    % so we need to simply fill the gaps.
    % Further down we fill gaps better
    if (~isempty(flux(~gaps)))
        flux(gaps)   = interp1(gapFilledTimestamps(~gaps), flux(~gaps), gapFilledTimestamps(gaps), 'pchip');
    end
    
    fluxDetrended  = flux - medfilt1_soc(flux, cdppMedFiltSmoothLength);
    
    % Need
    % maxCorrelationWindowLimit           = maxCorrelationWindowXFactor * maxArOrderLimit;
    % To be larger than the largest gap
    % Make local copy of gapFillConfigurationStruct so we can edit it
    gapFillConfigurationStructTemp = gapFillConfigurationStruct;
    gapFillConfigurationStructTemp.maxCorrelationWindowXFactor = 300 / gapFillConfigurationStructTemp.maxArOrderLimit;
    
    [fluxDetrended] = fill_short_gaps(fluxDetrended, gaps, 0, false, gapFillConfigurationStructTemp, []);
    
    %***
    % Compute the current CDPP
    tpsModuleParameters = [];
   %tpsModuleParameters.usePolyFitTransitModel  =
   %tpsModuleParameters.superResolutionFactor  =
   %tpsModuleParameters.varianceWindowLengthMultiplier =
   %tpsModuleParameters.waveletFilterLength =
    cadencesPerHour = 1 / (median(diff(gapFilledTimestamps))*24);
    trialTransitPulseDurationInHours = 6;
    
    if (~isnan(fluxDetrended))
        % Ignore the edge effects by only looking at the center portion
        fluxTimeSeries.values = ...
                fluxDetrended(cdppMedFiltSmoothLength:end-cdppMedFiltSmoothLength);
        if (length(fluxTimeSeries.values) < 1)
            cdpp = NaN;
        else
            cdppTemp = calculate_cdpp_wrapper (fluxTimeSeries, cadencesPerHour, trialTransitPulseDurationInHours, tpsModuleParameters);
            cdpp = cdppTemp.rms;
        end
    else
        cdpp = NaN;
    end

                
                
end

