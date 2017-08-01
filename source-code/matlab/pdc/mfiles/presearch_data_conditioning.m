%*************************************************************************************************************
%% function [pdcOutputsStruct] = presearch_data_conditioning (pdcInputObject, uberDiagnosticStruct)
%
%      Performs presearch data conditioning (PDC) with maximum a posteriori (MAP) detrending.
%
%      If this is a run on Short Cadence data then the Blob is loaded and passed to MAP and SPSD.
%
%      INPUTS:
%       pdcInputObject          -- see description in pdcInputClass.m
%       uberDiagnosticStruct    -- diagnostic struct for PDC, MAP and SPSD (see pdc_populate_diagnosticinputstruct.m)
%
%      Outputs:
%       pdcOutputsStruct        -- see pdc_create_output_struct
%
%*************************************************************************************************************
%
%      Phases:                                                             _
%      0. Preparation                                                       |
%         a) gap the data anomalies                                         | 
%         b) do linear gap filling                                          |
%         c) Correct Attitude Tweaks                                        |
%      1. Harmonics, SPSDs, Outliers (loop <preMapIterations>)              |
%         a) coarse MAP                                                     |
%         b) ID SPSDs                                                       |
%         c) ID Harmonics (Optional)                                        }- BLUE BOX 
%         d) ID Outliers                                                    |
%      0. Preparation                                                       |
%         a) remove H, D, O from normalized flux                            |
%         b) select clean targets (no SPSDs or Harmonics)                   |
%         d) remove spikes                                                 _|
%      2. MAP                                                               |
%         a) call multi-scale MAP                                           |
%         b) call single-scale MAP                                          }- GREEN BOX
%         c) Compute Goodness Metrics for both single and multi-scale MAP   |
%         d) Select best fit and remove systematics from flux              _|
%      3. Output Preparation                                                |
%         a) propagate the Outliers (O) through PDC                         |
%         b) restore harmonics (H)  (Optional)                              }- YELLOW BOX
%         c) flux-fraction and crowding-metric correction                   |
%         d) calculate final Goodness Metric                                |
%         e) populate output structure                                     _|
%
% There are several options to choose which MAP results to use (regular vs multi-scale, Step 2.d above)). The choices are:
%   pdcModuleParameters.mapSelectionMethod.
%       regular                      -- Use regular MAP results
%       multiscale                   -- Use Multi-scale MAP results
%       goodnessTotal                -- Pick which results per target have a better total goodness 
%       noiseVariability             -- Pick based on which has better Introduced Noise and Delta Variability using
%                                       pdcModuleParameters.mapSelectionMethodMultiscaleBias as a bias towards msMAP.
%       noiseVariabilityEarthpoints  -- Check if any of the three components is below 0.8 and if the regular MAP goodness
%                                       for that component is more than mapSelectionMethodMultiscaleBias better 
%       noneRobustMap                -- Designed for K2 data select between no correction, robust fit, MAP and msMAP
%
%*************************************************************************************************************
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

function [pdcOutputsStruct] = presearch_data_conditioning (pdcInputObject , uberDiagnosticStruct)

% For tracking memory usage, see memoryUsageClass
global memUsage;

% When calculating Goodness also compute EP Goodness (it's slower than the other components and is optional)
doCalcEpGoodness = true;

% Number of Targets and number of Cadences
nTargets = length(pdcInputObject.targetDataStruct);
nCadences = length(pdcInputObject.cadenceTimes.cadenceNumbers);

startTimestamp = pdcInputObject.cadenceTimes.midTimestamps(1);
endTimestamp   = pdcInputObject.cadenceTimes.midTimestamps(end);

% Monitor all targets' flux values at intermediate steps
uberDiagnosticStruct.pdcDiagnosticStruct.targetsToMonitor = 1:nTargets;

% Set internal config
pdcInternalConfig = struct( 'useNewSpsd', 1 , ...     % this will not be required later (or it might again for SC runs)
                            'mapResultsUncertaintiesToUse' , 'regular' , ... % decides which uncertainties to use (regular vs multiscale)
                            'removeHarmonicTargetsFromCleanlist', 0, ...
                            'fluxFractionAndCrowdingMetricNormalizationEnabled', true ); % why would it not be true?

% Bandsplitting is now fixed to handle cases of nCadences <= 13, but with the caveat that 3 bands must be used. see KSOC-2726
if(nCadences<13)
    display('Too few cadences to perform multi-scale MAP. Only regular MAP will be performed.');
    pdcInputObject = pdcInputObject.turn_off_band_splitting ();
end

% make sure bandSplitting is disabled for short-cadence (at least for now)
if (strcmp(pdcInputObject.cadenceType, 'SHORT'))
    pdcInputObject = pdcInputObject.turn_off_band_splitting ();
end

% make sure that regularMAP results are taken if bandSplitting is not performed and not working on K2 data
if (~pdcInputObject.thisIsK2Data && ~pdcInputObject.pdcModuleParameters.bandSplittingEnabled)
    pdcInputObject = pdcInputObject.set_map_selection_method('regular');
    pdcInternalConfig.mapResultsUncertaintiesToUse = 'regular';
end


% Populate the uberDiagnosticStruct with default values for fields that do not exist.
uberDiagnosticStruct = pdc_populate_diagnosticinputstruct( uberDiagnosticStruct , nTargets );

%***
% Init PDC debug struct
pdcDebugObject = pdcDebugClass();
% Plot the preparation plots?
pdcDebugObject = pdcDebugObject.set_preparation_plots(false);
% Plot the finishing plots?
pdcDebugObject = pdcDebugObject.set_finishing_plots(false);
% display the list of clean targets for MAP runs
pdcDebugObject.dispCleanTargets = false;
pdcDebugObject.targetsToMonitor = intersect(uberDiagnosticStruct.pdcDiagnosticStruct.targetsToMonitor,1:nTargets);

memUsage.add('After substantiating pdcDebugObject');

%========================================================================================
if (strcmp(pdcInputObject.cadenceType, 'SHORT'))
    % This is a short cadence run so we need to load and use the blob from long cadence.
    % For now we only use the first blob file that brackets the cadences. Later we can add functionality to use multiple blobs.
    % Note that quickMap (and the blob) will not actually be used unless
    % mapConfigurationStruct.quickMapEnabled = true and here PDC crashes if false

    % Cycle through each blob to find the one that actually brackets the short cadence data
    if (length(pdcInputObject.pdcBlobs.blobFilenames) > 1)
        properCadenceRange = false(length(pdcInputObject.pdcBlobs.blobFilenames), 1);
        for iBlob = 1 : length(pdcInputObject.pdcBlobs.blobFilenames)
            load(pdcInputObject.pdcBlobs.blobFilenames{1});
            if (~exist('inputStruct'));
                error ('pdcBlobStruct does not appear to exist');
            end
            % Make sure vector cadence data brackets sync to cadence data.

            vectorCadenceTimestamps     = inputStruct.mapBlobStruct.cadenceTimes.midTimestamps;
            vectorCadenceGapIndicators  = inputStruct.mapBlobStruct.cadenceTimes.gapIndicators;

            cadencesToSyncToTimestamps      = pdcInputObject.cadenceTimes.midTimestamps;
            cadencesToSyncToGapIndicators   = pdcInputObject.cadenceTimes.gapIndicators;

            gapRemovedSyncToCadences = cadencesToSyncToTimestamps(~cadencesToSyncToGapIndicators);
            gapRemovedVectorCadences = vectorCadenceTimestamps(~vectorCadenceGapIndicators);

            % Round to the nearest tenth of a day
            if (floor(10*min(gapRemovedSyncToCadences)) > floor(10*min(gapRemovedVectorCadences)) || ...
                ceil(10*max(gapRemovedSyncToCadences)) < ceil(10*max(gapRemovedVectorCadences)) )
                properCadenceRange(iBlob) = true;
                break;
            end
        end
        % See if any blob cadence ranges overlap with the SC data
        if (~any(properCadenceRange))
            error('None of the map Blobs cadences appears to bracket the SC cadences');
        end
    else
        load(pdcInputObject.pdcBlobs.blobFilenames{1});
        if (~exist('inputStruct'));
            error ('pdcBlobStruct does not appear to exist');
        end
    end
    % What a terrible name "inputStruct" I wish I could change that.
    % Me too!
    spsdBlobStruct = inputStruct.spsdBlobStruct;
    mapBlobStruct  = inputStruct.mapBlobStruct;
    clear inputStruct;

    % Check if quick map is being requested. If not then crash
    if (~pdcInputObject.mapConfigurationStruct.quickMapEnabled)
        error('PDC-MAP called on short cadence data but quick MAP not requested!');
    end
    
else
    spsdBlobStruct = [];
    mapBlobStruct  = [];
end

%========================================================================================
% If we want to use specific basis vectors specified in cbvBlobStruct then load the blob.
% Using the blob basis vectors can be done on a per-band basis so if we request the CBVs from the blob for any
% band then load the blob.

if (pdcInputObject.mapConfigurationStruct.useBasisVectorsFromBlob || ...
                pdcInputObject.mapConfigurationStruct.useBasisVectorsAndPriorsFromBlob || ...
                pdcInputObject.mapConfigurationStruct.useBasisVectorsAndPriorsFromPixels)
    % can only have one option true
    if (pdcInputObject.mapConfigurationStruct.useBasisVectorsFromBlob + ...
                pdcInputObject.mapConfigurationStruct.useBasisVectorsAndPriorsFromBlob + ...
                pdcInputObject.mapConfigurationStruct.useBasisVectorsAndPriorsFromPixels > 1)
        error('Only one ''use CBV or priors from blob'' can be true');
    end
    % This functionaility is right now only compatable with a single cbvBlobStruct.
    if (length(pdcInputObject.cbvBlobs.blobFilenames) > 1)
        error('Only a single cbvBlobStruct can be passed to PDC.');
    else
        if (isempty(pdcInputObject.cbvBlobs.blobFilenames))
            error('Asked to use basis vectors from blob but cbvBlobs.blobFilenames is empty');
        end
        load(pdcInputObject.cbvBlobs.blobFilenames{1});
        if (~exist('inputStruct'));
            error ('cbvBlobStruct does not appear to exist');
        end
    end
    % The struct inside a blob is ALWAYS called inputStruct
    cbvBlobStruct = inputStruct;
    clear inputStruct;

    % Check that this blob CBVs are for the mod.out passed into pdc through the inputsStruct
    % Cadence times must agree to a tenth of a day
    if (cbvBlobStruct.ccdModule ~= pdcInputObject.ccdModule || ...
        cbvBlobStruct.ccdOutput ~= pdcInputObject.ccdOutput || ...
        abs(min(startTimestamp) - min(cbvBlobStruct.startTimestamp)) > 0.1 || ...
        abs(max(endTimestamp) - max(cbvBlobStruct.endTimestamp)) > 0.1 )
            error('cbvBlobStruct does not appear to contain the correct cadence or mod.out basis vectors for this task run.');
    end
    
else
    cbvBlobStruct = [];
end

%========================================================================================
% Some pre-data setup for local structures etc...

% all the individual correction terms are stored in fluxCorrectionStruct for internal use
% it will contain:
% - median
% - harmonics
% - outliers
% - ...and now even more goodies!
fluxCorrectionStruct = repmat(struct('isFullyGapped', [], 'uncorrectedSuspectedDiscontinuity', [], 'spsd', [], 'harmonics', [], ...
                                        'outlierStruct', [], 'outliers', [], 'multiscaleMapUsed', [], 'selectedFit', []), [nTargets,1]);

% Instantiate a raDec2Pix object.
raDec2PixObject = raDec2PixClass(pdcInputObject.raDec2PixModel, 'one-based');


% make a local copy of some fields of the ConfigurationStruct
% this is passed as argument to Harmonics removal (fields are private in class)
localConfigurationStruct.ccdModule = pdcInputObject.ccdModule;
localConfigurationStruct.ccdOutput = pdcInputObject.ccdOutput;
localConfigurationStruct.cadenceTimes = pdcInputObject.cadenceTimes;
localConfigurationStruct.pdcModuleParameters = pdcInputObject.pdcModuleParameters;
localConfigurationStruct.raDec2PixObject = raDec2PixObject;
localConfigurationStruct.gapFillConfigurationStruct = ...
    pdcInputObject.gapFillConfigurationStruct;
localConfigurationStruct.harmonicsIdentificationConfigurationStruct = ...
    pdcInputObject.harmonicsIdentificationConfigurationStruct;

% number of bands for band-splitting
if (~pdcInputObject.pdcModuleParameters.bandSplittingEnabled)
    nBands = 1;
else
    nBands = pdcInputObject.bandSplittingConfigurationStruct.numberOfBands;
end


% create mapConfigurationStructArray - which contains MAP parameters for each band.
% NOTE:
% The first values in the mapConfigurationStruct arrays are for the coarse run, the second for the non-bs run, and all afterwards for the bands
% therefore, call clone_configuration_struct with nBands+2
% this is also called if bandSplittingEnabled==false, in order to extract only first parameters (in case multiple values
% were for a field)
mapConfigurationStructsForBands = bs_clone_configuration_struct(pdcInputObject.mapConfigurationStruct,nBands+2);
coarseMapConfigurationStruct = mapConfigurationStructsForBands{1};
nonbsMapConfigurationStruct = mapConfigurationStructsForBands{2};
bsMapConfigurationStructArray = { mapConfigurationStructsForBands{3:end} }; % {3} will always exist
clear mapConfigurationStructsForBands; % to avoid confusion later, not needed anymore now

% Initialize the alerts.
alerts = [];

memUsage.add('After everything initialized');

%%====================================================================================================
%% PREPARATION

%----------------------------------------------------------------------------------------------------
%% make local copy of flux time series for working purposes (from raw input from PA)
localTargetDataStruct = pdcInputObject.targetDataStruct;


%----------------------------------------------------------------------------------------------------
% Find transits for protecting from SPSD and Outlier detection
% Set up KOI information
% Check if the testing struct pdcInputStruct.transits exists and if so distribute it's KOIs
if (any(strcmp('transits', properties(pdcInputObject))) && ~isempty(pdcInputObject.transits))
    localTargetDataStruct = pdcTransitClass.distribute_transits (pdcInputObject.transits, localTargetDataStruct);
end
[localTargetDataStruct, TargetsWithAllCadencesInTransit] = pdcTransitClass.find_transit_gaps(pdcInputObject.cadenceTimes, localTargetDataStruct);
% Display alert for any targets that become fully gapped due to transit information
fullyGappedTargetIndices = find(TargetsWithAllCadencesInTransit);
for iTarget = 1 : length(fullyGappedTargetIndices)
    [alerts] = add_alert(alerts, 'Warning', ['Kepler ID ', num2str(localTargetDataStruct(fullyGappedTargetIndices(iTarget)).keplerId), ...
                    ' has every cadence flagged as in a known transit.']);
    disp(['WARNING: ', alerts(end).message]);
end

memUsage.add('KOI information set up');

%----------------------------------------------------------------------------------------------------
%% Gap Data Anomalies
% extract the anomalies
dataAnomalyIndicators = pdcInputObject.cadenceTimes.dataAnomalyFlags;
lcDataAnomalyIndicators = pdcInputObject.longCadenceTimes.dataAnomalyFlags;
if ~any(dataAnomalyIndicators.excludeIndicators)
    lcDataAnomalyIndicators.excludeIndicators = false(size(lcDataAnomalyIndicators.excludeIndicators));
end % if

% gap the anomalies
metricsKey = metrics_interval_start;
[ localTargetDataStruct localMotionPolyStruct ] = pdc_gap_data_anomalies(localTargetDataStruct, dataAnomalyIndicators, ...
                        lcDataAnomalyIndicators, pdcInputObject.motionPolyStruct, pdcInputObject.cadenceTimes, pdcInputObject.thrusterFiringDataStruct);
metrics_interval_stop('pdc.pdc_gap_data_anomalies.execTimeMillis', metricsKey);

memUsage.add('Data anomalies gapped');

%----------------------------------------------------------------------------------------------------

if (pdcDebugObject.preparation.plotInputs)
    % Plot the current flux values
    s = ['[1] - input (kId ' int2str(localTargetDataStruct(pdcDebugObject.targetsToMonitor(1)).keplerId) ')'];
    figure; 
    for j=1:length(pdcDebugObject.targetsToMonitor)
        plot(localTargetDataStruct(pdcDebugObject.targetsToMonitor(j)).values,'.'); 
    end
    set(gcf,'Name',s); title(s);
end
    
% Save the flux values intermediates for diagnostic purposes
pdcDebugObject = pdcDebugObject.add_intermediate('input',localTargetDataStruct);



%----------------------------------------------------------------------------------------------------
%% Check for Fully-Gapped-Targets
for iTarget=1:nTargets
    fluxCorrectionStruct(iTarget).isFullyGapped = all(localTargetDataStruct(iTarget).gapIndicators);
end

%----------------------------------------------------------------------------------------------------
%% Fill Gaps
pdctic = tic;
disp('filling gaps...');

metricsKey = metrics_interval_start;
[localTargetDataStruct, gapFilledCadenceMidTimestamps] = pdc_fill_gaps(localTargetDataStruct,pdcInputObject.cadenceTimes);
metrics_interval_stop('pdc.pdc_fill_gaps.execTimeMillis', metricsKey);

duration = toc(pdctic);
disp(['  ...done after ' num2str(duration) ' seconds.']);

%----------------------------------------------------------------------------------------------------
%% Attitude Tweak adjustment

pdctic = tic;
disp('Correcting Attitude Tweaks...');

localTargetDataStruct  = pdc_correct_attitude_tweaks (localTargetDataStruct, pdcInputObject.cadenceTimes.dataAnomalyFlags.attitudeTweakIndicators, ...
                                                        gapFilledCadenceMidTimestamps);

duration = toc(pdctic);
disp(['  ...done after ' num2str(duration) ' seconds, ', num2str(duration / 60), ' minutes']);

%----------------------------------------------------------------------------------------------------

if (pdcDebugObject.preparation.plotGapFilling)
    s = ['[2] - after gapfilling (kId ' int2str(localTargetDataStruct(pdcDebugObject.targetsToMonitor(1)).keplerId) ')'];
    figure; plot(localTargetDataStruct(pdcDebugObject.targetsToMonitor(1)).values,'.'); set(gcf,'Name',s); title(s);
end

pdcDebugObject = pdcDebugObject.add_intermediate('after initial gap filling',localTargetDataStruct);

memUsage.add('Linearly filled gaps');

%----------------------------------------------------------------------------------------------------

%%====================================================================================================
% Do the Blue Box: Coarse MAP, SPSDs, outliers and harmonics
[localTargetDataStruct, alerts, fluxCorrectionStruct, pdcDebugObject, targetsToUseForBasisVectorsAndPriors, spikeBasisVectors, variabilityStructK2 ] = ...
    pdc_blue_box_spsd_outlier_harmonics (...
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
        coarseMapConfigurationStruct, ...
        alerts);

memUsage.add('After Blue Box spsd outlier harmonics');


%%====================================================================================================
% Do the Green Box: Regular MAP and msMAP
[localTargetDataStruct, alerts, fluxCorrectionStruct, variabilityStruct, pdcDebugObject] = ...
    pdc_green_box_map_proper(...
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
        alerts,...
        variabilityStructK2);

memUsage.add('After Green Box MAP Proper');

%%====================================================================================================
%% YELLOW BOX (outputs)
% INPUTS:
%   - clean y_tilde (in localTargetDataStruct)
%   - outliers
%   - harmonics
%   - median from normalization
% DO:
%   - flux fraction and crowding metric
%   - restore harmonics (optional)
%   - restore outliers for export
%   -Propagation of Uncertainties
%   - Goodness Metric calculation


%----------------------------------------------------------------------------------------------------
% Outlier Propagation
%    in general, there would be three options:
%    1) propagate the outliers through the all corrections of the PDC pipeline
%    2) unwind the stack from the current flux series with the inverse operations, carried out in reverse order
%    3) however, since only additive corrections have been performed since removing the outliers, we can simply
%    subtract the outlier correction(s) to add the outliers back in
%
%    option (3) is done here, so that the outliered flux time series can be processed through
%    flux fraction / crowding metric correction
%    we also copy the uncertainties and the gapIndicators. not that anyone would need them, 
%    but pdc_correct_flux_fraction_and_crowding_metric expects them as fields
for i=1:nTargets
    outlieredFluxSeries(i).values = localTargetDataStruct(i).values;
    for iIter = 1:pdcInputObject.pdcModuleParameters.preMapIterations
        outlieredFluxSeries(i).values = outlieredFluxSeries(i).values + fluxCorrectionStruct(i).outliers{iIter};
    end
    outlieredFluxSeries(i).uncertainties = localTargetDataStruct(i).uncertainties;
    outlieredFluxSeries(i).gapIndicators = localTargetDataStruct(i).gapIndicators;
end
    
%----------------------------------------------------------------------------------------------------
% Restore Harmonics
nCadences = length(localTargetDataStruct(1).values);    
disp('adding back harmonics');
for i = 1:nTargets
    harmonicsAll(i).values = zeros(nCadences,1);
    for iIter = 1:pdcInputObject.pdcModuleParameters.preMapIterations
        if ~isempty(fluxCorrectionStruct(i).harmonics{iIter})
            harmonicsAll(i).values = harmonicsAll(i).values + fluxCorrectionStruct(i).harmonics{iIter};
        end
    end
    localTargetDataStruct(i).harmonicFreeValues = localTargetDataStruct(i).values; % TODO: do these make sense? probably remove them
    localTargetDataStruct(i).values = localTargetDataStruct(i).values + harmonicsAll(i).values;
    outlieredFluxSeries(i).values = outlieredFluxSeries(i).values + harmonicsAll(i).values;
end
if (pdcDebugObject.finishing.plotHarmonics)
    figure; set(gcf,'Name','Harmonics added back in');
    subplot(2,1,1);
    hold on;
    plot(localTargetDataStruct(pdcDebugObject.targetsToMonitor(1)).harmonicFreeValues,'b.');
    plot(localTargetDataStruct(pdcDebugObject.targetsToMonitor(1)).values,'r.');
    legend('before','after');
    title(['Harmonics before/after (kId ' int2str(localTargetDataStruct(pdcDebugObject.targetsToMonitor(1)).keplerId) ')' ]);
    subplot(2,1,2);
    plot(harmonicsAll(pdcDebugObject.targetsToMonitor(1)).values);
    title(['Harmonics (kId ' int2str(localTargetDataStruct(pdcDebugObject.targetsToMonitor(1)).keplerId) ')' ]);
end

if (pdcInputObject.pdcModuleParameters.harmonicsRemovalEnabled)
    pdcDebugObject = pdcDebugObject.add_intermediate('after restoring harmonics',localTargetDataStruct);
end

%----------------------------------------------------------------------------------------------------
% For K2 also identify residual or injected sawtooths
% These identified and gapped cadences will for now not be considered outliers. We can change that decision later.
if (pdcInputObject.thisIsK2Data)
    [localTargetDataStruct, fluxCorrectionStruct] = pdc_remove_residual_roll_sawtooth (localTargetDataStruct, pdcInputObject, fluxCorrectionStruct );
    pdcDebugObject = pdcDebugObject.add_intermediate(['after removing residual sawtooth'],localTargetDataStruct);
end


    
%----------------------------------------------------------------------------------------------------
% PDC no longer doing proper gap filling. Moved to TPS
%% Refill all Gaps for K2, including outliers, since the outliers need to be refilled after MAP
%% NOTE: for K2, data outliers are added to gapIndicators when the outliers are identified!
% TODO:
if (pdcInputObject.thisIsK2Data)
    pdctic = tic;
    disp('filling gaps for K2 data...');

    metricsKey = metrics_interval_start;
    [localTargetDataStruct, ~] = pdc_fill_gaps(localTargetDataStruct,pdcInputObject.cadenceTimes);
    metrics_interval_stop('pdc.pdc_fill_gaps.execTimeMillis', metricsKey);

    duration = toc(pdctic);
    disp(['  ...done after ' num2str(duration) ' seconds.']);
end


%----------------------------------------------------------------------------------------------------
% gaps are still filled so still list the filled gaps.
% Flux fraction and crowding metric correction will ZERO gaps so remove gapIndicators here then restore below
% for the Goodness Metric.
% Note that the filledIndices will be complimented with the outlier cadences in the export function
savedGaps           = [localTargetDataStruct.gapIndicators];
savedOutlieredGaps  = [outlieredFluxSeries.gapIndicators];
for iTarget=1:nTargets
    % Linearly filled gaps fills all gap locations, so indexing them is simple
    localTargetDataStruct(iTarget).filledIndices = find(localTargetDataStruct(iTarget).gapIndicators);    
    localTargetDataStruct(iTarget).gapIndicators = false(nCadences,1);
    outlieredFluxSeries(iTarget).filledIndices = find(outlieredFluxSeries(iTarget).gapIndicators);    
    outlieredFluxSeries(iTarget).gapIndicators = false(nCadences,1);
end

%----------------------------------------------------------------------------------------------------
% Flux Fraction and Crowding Metric Correction
% Correct for excess crowding and flux fraction in aperture if
% normalization is enabled.
if (pdcInternalConfig.fluxFractionAndCrowdingMetricNormalizationEnabled)
    crowdingMetricArray = [localTargetDataStruct.crowdingMetric]';
    fluxFractionArray = [localTargetDataStruct.fluxFractionInAperture]';
    pdctic = tic;
    if (pdcDebugObject.finishing.plotFluxFractionCrowdingMetric)
        before = localTargetDataStruct;
    end
    display('presearch_data_conditioning: rescaling for crowding and flux fraction...');

    [ localTargetDataStruct , harmonicTimeSeries , alerts ] = ...
        pdc_correct_flux_fraction_and_crowding_metric(localTargetDataStruct, harmonicsAll, ...
        crowdingMetricArray,fluxFractionArray, alerts);
    [ outlieredFluxSeries , ~ , ~ ] = ...
        pdc_correct_flux_fraction_and_crowding_metric(outlieredFluxSeries, harmonicsAll, ...
        crowdingMetricArray,fluxFractionArray, alerts);
    duration = toc(pdctic);
    display(['Flux rescaled: ' num2str(duration) ...
        ' seconds = '  num2str(duration/60) ' minutes']);
    
    if (pdcDebugObject.finishing.plotFluxFractionCrowdingMetric)
        figure; set(gcf,'Name','FluxFraction and CrowdingMetric');
        hold on;
        plot(before(pdcDebugObject.targetsToMonitor(1)).values,'b.');
        plot(localTargetDataStruct(pdcDebugObject.targetsToMonitor(1)).values,'r.');
        legend('before','after');
        title(['FluxFraction and CrowdingMetric (kId ' int2str(localTargetDataStruct(pdcDebugObject.targetsToMonitor(1)).keplerId) ')' ]);
    end

else
    harmonicTimeSeries = harmonicsAll;
end

memUsage.add('Flux Fraction and Crowding metric correction');
    
pdcDebugObject = pdcDebugObject.add_intermediate('after flux fraction and crowding metric correction',localTargetDataStruct);
    
%----------------------------------------------------------------------------------------------------
% Final Goodness Metric comparing input flux to final output flux


% Note: Data in gaps is ignored for goodness metric calculation so we need to recover the gaps
% NOTE: This also means don't remove gaps until after calling the goodness metric.
doSavePlots = true;
doNormalizeFlux = true;

% Restore gaps so that Goodness Metric overlooks them
for iTarget=1:nTargets
    localTargetDataStruct(iTarget).gapIndicators = savedGaps(:,iTarget);
end

% Always use Coarse MAP basisVectors for spike goodness
if(pdcInputObject.mapConfigurationStruct.spikeIsolationEnabled(1))
    basisVectorsForGoodness = spikeBasisVectors;
else
    basisVectorsForGoodness = [];
end

goodnessStruct = pdc_goodness_metric ( pdcInputObject.targetDataStruct, ...
                                       localTargetDataStruct, pdcInputObject.cadenceTimes, basisVectorsForGoodness , ...
                                       pdcInputObject.pdcModuleParameters, ...
                                       pdcInputObject.goodnessMetricConfigurationStruct, pdcInputObject.gapFillConfigurationStruct,...
                                       doNormalizeFlux, doSavePlots, 'MAP ', doCalcEpGoodness);
                                   
% Remove gaps again
for iTarget=1:nTargets
    localTargetDataStruct(iTarget).gapIndicators = false(nCadences,1);
end


memUsage.add('Final Goodness calculation');

%----------------------------------------------------------------------------------------------------
% Force fully gapped targets to zero flux and all gaps = true
for iTarget = 1 : nTargets
    if (fluxCorrectionStruct(iTarget).isFullyGapped)
        localTargetDataStruct(iTarget).gapIndicators = true(nCadences,1);
        localTargetDataStruct(iTarget).filledIndices = [];
        localTargetDataStruct(iTarget).values = zeros(nCadences,1);
        outlieredFluxSeries(iTarget).gapIndicators = true(nCadences,1);
        outlieredFluxSeries(iTarget).filledIndices = [];
        outlieredFluxSeries(iTarget).values = zeros(nCadences,1);
    end
end


%----------------------------------------------------------------------------------------------------
% prepare output for TPS, DV, short cadence and archive
% This also creates the blob files
pdcOutputsStruct = ...
    pdc_create_output_struct(pdcInputObject,localTargetDataStruct,harmonicTimeSeries,outlieredFluxSeries,...
                                fluxCorrectionStruct, alerts, goodnessStruct, variabilityStruct, gapFilledCadenceMidTimestamps);

memUsage.add('Output struct created');

% Pie Chart of selected fit
saveFigure = true;
pdc_map_selection_method_pie_chart (pdcOutputsStruct, saveFigure);
    
%----------------------------------------------------------------------------------------------------
% Save the debug structure from this run
warningState = warning('query','all');
warning off;
pdcDebugStruct = struct(pdcDebugObject);
warning( warningState );
% Add in the fluxCorrectionStruct to contain a full picture of the PDC correction
pdcDebugStruct.fluxCorrectionStruct = fluxCorrectionStruct;

if (uberDiagnosticStruct.dataStructSaving.savePdcDebugStruct)
    intelligent_save('pdcDebugStruct', 'pdcDebugStruct');
end

% -- END [yellow box]
%%====================================================================================================

memUsage.add('End of presearch_data_conditioning');

end

