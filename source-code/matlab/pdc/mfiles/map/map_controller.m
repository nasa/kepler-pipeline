%******************************************************************************
%% function [mapCorrectedTargetDataStruct, alerts, basisVectors, spikeBasisVectors] = map_controller (mapConfigurationStruct, pdcModuleParameters, ...
%               targetDataStruct, cadenceTimes, targetsForBasisVectorsAndPriors, mapDiagnosticStruct, ...
%               variabilityStruct, mapBlobStruct, cbvBlobStruct, goodnessMetricConfigurationStruct, motionPolyStruct, multiChannelMotionPolyStruct, ...
%               taskInfoStruct)
%******************************************************************************
%
%   Controller and dispatcher function for the Maximum A-Posteriori Bayesian Estimator method of
%   cotrending in PDC.
%
%   Target indexing for all intermediate and final products is referenced to the order of
%   targetDataStruct.
%
%   If mapDiagnosticStruct.quickDiagnosticRun is present and true then MAP will not plot or save diagnostic figures 
%   but will use the kic.mat file to fill in missing KIC data.
%
%   debugRun overrides quickDiagnosticRun and is used when debugging MAP and uses the debug parameters as set in
%   this file.
%
%   Map_controller is to be used inside band-splitting but the stellar variability calculation will not
%   perform properly on individual bands so map_controller now requests the variability as an input.
%
%   mapBlobStruct is used to pass the LC basis vectors and other information for use to do a quick LS
%   fit for SC data. If mapBlobStruct is empty and mapConfigurationStruct.quickMapEnabled = true then MAP
%   crashes with error.
%
%******************************************************************************
%   Inputs:
%       mapConfigurationStruct -- [struct] MAP configuration parameters
%       pdcModuleParameters    -- [struct] General PDC configuration parameters
%       targetDataStruct       -- [targeDataStruct] the flux data to apply MAP to
%       cadenceTimes           -- [struct] cadence times (used only for plotting results)
%       targetsForBasisVectorsAndPriors -- [logical array(nTargets)] targets to use for generating the basis vectors and
%                                   priors, this is normally a "clean" list of targets with no discontinuities or harmonics
%       mapDiagnosticStruct    -- [struct] contains parameters used that do not effect MAP operation but
%                                           effects how diagnostic data is saved and displayed
%               .doFigures               -- [logical] If true then generate figures
%               .doSaveFigures           -- [logical] If true then plots are saved to subdirectory.
%               .doCloseAfterSaveFigures -- [logical] If true then close each figure after it is saved.
%               .doSaveResultsStruct     -- [logical] If true then save mapResultsStruct
%               .doQuickDiagnosticRun    -- [logcial] If true then this is a diagnostic run: no figures and
%                                                   only some targets analyzied (see specificKeplerIdsToAnalyze ), Martin: this is for you!
%               .debugRun                -- [logcial] If true then this is a debug run, use debug parameters below 
%                                               (If you are not Jeff Smith then you should not use this, unless you know what you are doing!)
%               .runLabel                -- [string] What string to prepend to warnings, saved figures and mapResultsStruct
%               .specificKeplerIdsToAnalyze -- [integer array] list of KeplerIDs to apply MAP to. This is only
%                                                   used if doQuickDiagnosticRun == true. If empty apply to all targets
%               .saveAfterRobustFit      -- [logical] If true will save all data after the robust fit
%               .loadThisRobustData      -- [string] if not empty then will load the data form this file
%       variabilityStruct                   -- [struct] Calculated variability for each target
%               .variability                -- [double array(nTargets)] normalized variability for each target
%               .medianVariability          -- [double] Median value used to normalize variability
%       mapBlobStruct                       -- [struct] contains MAP data used for quick MAP run (right now for SC),
%       cbvBlobStruct                       -- [struct] contains basis vectors to explicitly use instead of creating them in MAP
%       goodnessMetricConfigurationStruct   -- [struct] use to calculate the goodness for goodness metric iterations
%       motionPolyStruct                    -- [struct] motion polynomial data from pdcInputObject
%       multiChannelMotionPolyStruct        -- [struct] motion polynomial data from pdcInputObject for a multichannel run
%       taskInfoStruct         -- [struct]
%               .ccdModule
%               .ccdOutput
%               .quarter
%               .month
%               .thisIsK2Data
%
%******************************************************************************
%   Outputs:
%       mapCorrectedTargetDataStruct    -- [targetDataStruct] the MAP corrected target data struct
%       alerts                          -- [alerts struct] Any warning messages from this MAP run
%       basisVectors                    -- [nCadences x nBasisVectors] Basis Vectors used in the cotrending
%       spikeBasisVectors               -- [nCadences x nSpikeBasisVectors] Basis Vectors used in spike removal
%
%       mapResultsObject -- [mapResultsClass] SAVED TO FILE, NOT RETURNED; All final results from MAP to be delivered to PDC. Includes
%                               diagnostic information. See mapResultsClass.m for details.
%
%******************************************************************************
%   All internal processing in MAP is handled in relation to two handle objects, mapInput and mapData. They
%   are matlab handle objects, aka passed as pointers, so these objects do not need to be returned from
%   called functions.  
%
%   Intermediate Data Products:
%       mapInput      -- [mapInputClass (handle)] all the input data for map_controller addembled ummutably in this object.
%                           see mapInputClass for details.
%       mapData       -- [mapDataClass (handle)] all intermediate and final results from MAP. see
%                           mapDataClass.m for details. The outside world does not see this object.
%%
%******************************************************************************
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

function [mapCorrectedTargetDataStruct, alerts, basisVectors, spikeBasisVectors] = map_controller (mapConfigurationStruct, pdcModuleParameters, ...
                targetDataStruct, cadenceTimes, targetsForBasisVectorsAndPriors, mapDiagnosticStruct, ...
                variabilityStruct, mapBlobStruct, cbvBlobStruct, goodnessMetricConfigurationStruct, ...
                motionPolyStruct, multiChannelMotionPolyStruct, taskInfoStruct)

component = 'mapController';

% Keep track of MAP memory usage
global mapMemUsage;
mapMemUsage = memoryUsageClass('MAP Memory Usage'); % memUSage is a global object handle

% Check if loading from after robust fit
% This is used during testing MAp where all pre-MAP operatiosn are exactly the same so no need to waste our
% time on these operations.
if (~isempty(mapDiagnosticStruct.loadThisRobustData))
    mapDiagnosticStruct_save = mapDiagnosticStruct;
    mapConfigurationStruct_save = mapConfigurationStruct;
    display('Loading all data after Robust Fit...');
    load(mapDiagnosticStruct.loadThisRobustData);
    mapDiagnosticStruct = mapDiagnosticStruct_save;
    mapConfigurationStruct = mapConfigurationStruct_save;
end

% Construct the mapInput object
mapInput = mapInputClass(mapConfigurationStruct, pdcModuleParameters, targetDataStruct, ...
                cadenceTimes, targetsForBasisVectorsAndPriors, mapBlobStruct, cbvBlobStruct, ...
                goodnessMetricConfigurationStruct, motionPolyStruct, multiChannelMotionPolyStruct, taskInfoStruct);

mapMemUsage.add('substantiated mapInput');

% This is the name of the file that data is saved to if saving after robust fit
afterRobustDataFilename = 'afterRobustDataSave';

mapInput.debug.quickDiagnosticRun = mapDiagnosticStruct.doQuickDiagnosticRun;
mapInput.debug.debugRun           = mapDiagnosticStruct.debugRun;

mapInput.debug.doSaveFigures            = mapDiagnosticStruct.doSaveFigures;
mapInput.debug.doCloseAfterSaveFigures  = mapDiagnosticStruct.doCloseAfterSaveFigures;
mapInput.debug.runLabel                 = mapDiagnosticStruct.runLabel;

%******************************************************************************
% Set debug values

% If this is a diagnostic run then turn off figures, unless debugRun = true;
if (mapInput.debug.quickDiagnosticRun && ~mapInput.debug.debugRun)
    mapInput.debug.doFigures = false;
else
    mapInput.debug.doFigures = true;
end

mapInput.debug.doFigures = mapDiagnosticStruct.doFigures;

if (mapInput.debug.debugRun)
    % This is a debug run, so turn on lots of debugging
    % DebugRun overrides diagnosticeRun
    % Pipeline-run code will never see these values so they need not be in a particular state when merging into a
    % release

    mapInput.debug.compileKicData       = mapInput.debug.VERBOSEDEBUGLEVEL;
    mapInput.debug.compileCentroidData  = mapInput.debug.VERBOSEDEBUGLEVEL;
    mapInput.debug.stellarVariability   = mapInput.debug.PLOTTINGDEBUGLEVEL;
    mapInput.debug.basisVectors         = mapInput.debug.PLOTTINGDEBUGLEVEL;
    mapInput.debug.robustFit            = mapInput.debug.VERBOSEDEBUGLEVEL;
    mapInput.debug.generatePrior        = mapInput.debug.VERBOSEDEBUGLEVEL;
    mapInput.debug.generateConditional  = mapInput.debug.VERBOSEDEBUGLEVEL;
    mapInput.debug.generatePosterior    = mapInput.debug.VERBOSEDEBUGLEVEL;
    mapInput.debug.maximizePosterior    = mapInput.debug.VERBOSEDEBUGLEVEL;
    mapInput.debug.pou                  = mapInput.debug.VERBOSEDEBUGLEVEL;
    mapInput.debug.compileResults       = mapInput.debug.PLOTTINGDEBUGLEVEL;
    mapInput.debug.resultantPlots       = mapInput.debug.PLOTTINGDEBUGLEVEL;

    mapInput.debug.doFigures            = true;
    mapInput.debug.interactive          = true;
    mapInput.debug.displayWaitbar       = true;
    mapInput.debug.doVisibleFigures     = true;
    mapInput.debug.doSaveFigures        = false;  % Save plots to subdirectory

    mapInput.debug.applyMapToAllTargets = false;

    mapInput.debug.doFindKicDatabase    = false;
    mapInput.debug.doStopOnError        = true;

    mapInput.debug.doAnalyzeReducedSetOfTargets = true;
    mapInput.debug.doSpecificTargets            = true;
    mapInput.debug.doRandomTargets              = false;
    mapInput.debug.nRandomTargetsToAnalyze      = 10;
    mapInput.debug.justDoVariable               = false;
    mapInput.debug.justDoQuiet                  = false;
    mapInput.debug.justDoNo3Vec                 = false;
    mapInput.debug.justDoEclipsingBinaries      = false;

   % List specific Kepler IDs to analyze during debug runs.
   % A bunch of interesting ones used during initial development are listed below.
   %mapInput.debug.specificKeplerIdsToAnalyze = [10088114 10286173 10288976]; % Q10 15.2
    mapInput.debug.specificKeplerIdsToAnalyze = [2569126]; % Q10 2.1
   %mapInput.debug.specificKeplerIdsToAnalyze = [2847437]; % Q10 2.1
   %mapInput.debug.specificKeplerIdsToAnalyze = [2571868]; % Q10 2.1
   %mapInput.debug.specificKeplerIdsToAnalyze = [8325180 8326537 8323578 7846693];
   %mapInput.debug.specificKeplerIdsToAnalyze = [ 8081482 8081389 8481574 8480642 8479107 8479386 8415863 8414159 ...
   % 8285349 8285254 8218274 7943602 7943535 8610483 8544996 8545456 8149616];
   %mapInput.debug.specificKeplerIdsToAnalyze = [8415928 8081389 8349582 8415752 8478994 8150065 8479386 8150320 8738809];
   %mapInput.debug.specificKeplerIdsToAnalyze = [8008067     8077137     7870390     8280511     7869917     8346342];
   %mapInput.debug.specificKeplerIdsToAnalyze = [ 8367710 8559644 8753657 8625953 8561221 8494142 8561063 8689373 8302197 8029546];
   %mapInput.debug.specificKeplerIdsToAnalyze = [10272858 10139564 10920273 10337517 10273246 10666592 10273384 10730618 10339342 10271806 ];
elseif (mapInput.debug.quickDiagnosticRun)
    % This is a non-production run but no debugging for MAP
    mapInput.debug.doFigures            = false;
    mapInput.debug.displayWaitbar       = true;
    mapInput.debug.doFindKicDatabase    = false;
    mapInput.debug.doStopOnError        = true;
    mapInput.debug.doAnalyzeReducedSetOfTargets = false;

else
    % This is a production pipeline run
    % The default values in the debugClass are appropriate.
end

if (mapInput.debug.quickDiagnosticRun && isfield (mapDiagnosticStruct, 'specificKeplerIdsToAnalyze') && ...
                ~isempty(mapDiagnosticStruct.specificKeplerIdsToAnalyze))
    % Then this is a diagnostic run and MAP was called with a specific set of targets to analyze
    mapInput.debug.doAnalyzeReducedSetOfTargets = true;
    mapInput.debug.specificKeplerIdsToAnalyze = mapDiagnosticStruct.specificKeplerIdsToAnalyze;
    mapInput.debug.applyMapToAllTargets = false;
    mapInput.debug.doSpecificTargets    = true;
    mapInput.debug.doRandomTargets      = false;
end

% This is for testing purposes only. If running MAP on the same data numerous times with no changes to the
% basis vectors then load in all data after the robust fit operation in order to speed up testing.
if (~isempty(mapDiagnosticStruct.loadThisRobustData))

    mapInput.debug.setup_reduced_set_of_targets (mapData, mapInput);

    do_MAP (mapData, mapInput);

    [mapCorrectedTargetDataStruct, alerts, basisVectors] = do_post_map_operations (mapData, mapInput, mapDiagnosticStruct);

    spikeBasisVectors = [];

    return
end

mapMemUsage.add('All preparation finished');

mapInput.debug.display(component, '*****************************************************************');
mapInput.debug.display(component, ['Starting MAP for run labelled  ', mapDiagnosticStruct.runLabel]);

%******************************************************************************

% Construct the mapData Object handle for internal use.
mapData = mapDataClass();

mapMemUsage.add('Substantiated mapData');

%******************************************************************************
% If all input flux is zeros then MAP should just return with mapFailed = true.
% This case is probably due to one or more bands being zero flux due to too short a data set
if (all(all([mapInput.targetDataStruct.values] == 0)))
    mapData.mapFailed = true;
    string = [mapInput.debug.runLabel, ': MAP failed due to all input flux being zero!'];
    mapInput.debug.display(component, string);
    [mapData.alerts] = add_alert(mapData.alerts, 'warning', string);
    mapResultsObject = mapResultsClass('mapData', mapData, 'mapInput', mapInput);
    save_mapResultsStruct(mapResultsObject, mapInput, mapDiagnosticStruct)
    % Just return the fields that are really needed in PDC
    mapCorrectedTargetDataStruct = mapResultsObject.mapCorrectedTargetDataStruct;
    alerts = mapResultsObject.alerts;
    basisVectors = mapResultsObject.basisVectors;
    spikeBasisVectors = [];
    return;
end
    
%******************************************************************************
% Normalize the flux
% It is recommend to normalize flux and uncertainties by mean so that the relative amplitudes are equivocal and intuitive
doMaskEpRecovery = mapInput.pdcModuleParameters.variabilityEpRecoveryMaskEnabled;
maskWindow = mapInput.pdcModuleParameters.variabilityEpRecoveryMaskWindow;
[mapData.normTargetDataStruct, mapData.medianFlux, mapData.meanFlux, mapData.stdFlux, mapData.noiseFloor] = ...
                                mapNormalizeClass.normalize_flux (mapInput.targetDataStruct, ...
                                    mapInput.mapParams.fitNormalizationMethod, false, ...
                                    doMaskEpRecovery,  mapInput.cadenceTimes, maskWindow);

mapMemUsage.add('Flux Normalized');

%******************************************************************************
% Some useful parameters to store so they are only calculated once
mapData.nTargets  = length(mapData.normTargetDataStruct);
mapData.nCadences = length(mapData.normTargetDataStruct(1).values);

%******************************************************************************
%% Compile Kic data in an easily readable matrix

 map_compile_kic_data (mapData, mapInput);

mapMemUsage.add('KIC data compiled');

%******************************************************************************
%% Find the centroid Motion

% This is only used for centroid priors so only do if centroid priors are being used.
% For multichannel runs it can take a really long time
if (mapInput.mapParams.useCentroidPriors)
    createEmptyObject = false;
else
    createEmptyObject = true;
end
mapData.centroid = mapCentroidClass (mapData, mapInput, createEmptyObject);

mapMemUsage.add('Centroids computed');

%******************************************************************************
%% Load and process the Pixel prior information

    if (mapInput.mapParams.useBasisVectorsAndPriorsFromPixels || mapInput.mapParams.usePriorsFromPixels)
        mapPixelDataClass.compile_pixel_priors (mapData, mapInput);

        mapMemUsage.add('Pixel Priors computed');

    else
        mapData.targetsWherePixelDataNotFound = true(mapData.nTargets,1);
    end

%******************************************************************************
%% Stellar Variability is passed as input

% This is needed right now for variability plotting
mapData.quickMap.quickMapPerformed = mapInput.mapParams.quickMapEnabled;

component = 'stellarVariability';

% These are now calulated outside of MAP
mapData.variability = variabilityStruct.variability;
mapData.medianVariability = variabilityStruct.medianVariability;

%%***
% Plot variability
if (mapInput.debug.query_do_plot(component));
    if (mapData.quickMap.quickMapPerformed)
        % plot the stellar variability as scatter plot for Short Cadence (small number of targets)
        stellarVariabilityPlot = mapInput.debug.create_figure;
        semilogy(mapData.variability, '*b');
        hold on
        semilogy(repmat(mapInput.mapParams.quickMapVariabilityCutoff, [mapData.nTargets,1]), '-r','LineWidth', 2)
        legend('Target Variability', ['LC MAP Fit used Variability Cutoff = ', num2str(mapInput.mapParams.quickMapVariabilityCutoff)])
        title('Stellar Variability for All Targets')
        xlabel('Target Index');
        ylabel('Stellar Variability');
        filename = 'stellar_variability';
        mapInput.debug.save_figure(stellarVariabilityPlot, component, filename);
    else
        % Plot histogram of variability distribution on log scale
        stellarVariabilityHist = mapInput.debug.create_figure;
        % First plot a point to force a semilogx plot (and suppress item in legend)
        % I know of no way to create a bar plot on a log scale so this forces a log scale.
        h = semilogx(0,0);
        set(get(get(h,'Annotation'),'LegendInformation'),...
            'IconDisplayStyle','off'); % Exclude line from legend
        hold on;
        [n, xout] = hist(log(mapData.variability), 100);
 
        % Plot each bar with exponential bar width so that bars look same width on log scale
        for iBar = 1: length(xout)
            h = bar(exp(xout(iBar)), n(iBar), (8 * exp(xout(iBar)) / length(xout)));
            % Don't show bars in legend
            set(get(get(h,'Annotation'),'LegendInformation'),...
                'IconDisplayStyle','off'); % Exclude line from legend
        end
 
        % Plot the thresholds
        barHeight = max(n);
        bar(mapInput.mapParams.variabilityCutoff, barHeight, ...
                    (exp(mapInput.mapParams.variabilityCutoff) / length(xout)), 'red');
        bar(mapInput.mapParams.priorWeightVariabilityCutoff, barHeight, ...
                    (exp(mapInput.mapParams.priorWeightVariabilityCutoff) / length(xout)), 'green');
        legend(['SVD and Prior Generation Variability Cutoff = ', num2str(mapInput.mapParams.variabilityCutoff)], ...
                ['Prior Used in Posterior Variability Cutoff = ', num2str(mapInput.mapParams.priorWeightVariabilityCutoff)])
        title('Stellar Variability Histogram for All Targets')
        xlabel('Stellar Variability');
        filename = 'stellar_variability_histogram';
        mapInput.debug.save_figure(stellarVariabilityHist, component, filename);
    end
end

mapMemUsage.add('Stellar Variability incorporated');

%******************************************************************************
%******************************************************************************
%******************************************************************************
% Quick-MAP is used for short cadence data.

if (mapData.quickMap.quickMapPerformed)

    if (isempty(mapBlobStruct))
        error('MAP_CONTROLLER: QuickMAP requested but MAP blob is empty!');
    end

    mapInput.debug.setup_reduced_set_of_targets (mapData, mapInput);

    mapMemUsage.add('Reduced set of targets set up');

    map_do_quick_map (mapData, mapInput);

    mapMemUsage.add('Quick MAP performed');

    % Right now no spike removal in quickMap
    spikeBasisVectors = [];

else

    %******************************************************************************
    %******************************************************************************
    %******************************************************************************
    % Normal MAP

    %******************************************************************************
    %% Basis Vector Generation

    basisVectorsFound = map_find_basis_vectors (mapData, mapInput);

    mapMemUsage.add('Basis Vectors found');

    % If we failed to find the basis vectors then neither MAP or robust fit can be performed.
    % Just pass back the unaltered basis vectors
    if (~basisVectorsFound)
        mapData.mapFailed = true;
        string = [mapInput.debug.runLabel, ': MAP failed due to basis vectors could not be found!'];
        mapInput.debug.display(component, string);
        [mapData.alerts] = add_alert(mapData.alerts, 'warning', string);
        mapResultsObject = mapResultsClass('mapData', mapData, 'mapInput', mapInput);
        save_mapResultsStruct(mapResultsObject, mapInput, mapDiagnosticStruct)
        % Just return the fields that are really needed in PDC
        mapCorrectedTargetDataStruct = mapResultsObject.mapCorrectedTargetDataStruct;
        alerts = mapResultsObject.alerts;
        basisVectors = mapResultsObject.basisVectors;
        spikeBasisVectors = [];
        return;
    end

    spikeBasisVectors = mapData.spikeBasisVectors;
    
    %******************************************************************************
    %% Robust fit

    map_robust_fit (mapData, mapInput);

    mapMemUsage.add('Robust fit performed');

    if (mapDiagnosticStruct.saveAfterRobustFit)
        mapInput.debug.display(component, 'Saving all data after Robust Fit');
        save('afterRobustData');
    end

    %******************************************************************************
    % Find a reduced set of targets to analyze.
    % Be sure to have parameters for selecting targets already before calling this so after basis vectors found.
    % Also, targets are potentially selected based on variability and KIC data so this must be set AFTER target
    % variability is calculated and KIC data is compiled
    % if doAnalyzeReducedSetOfTargets = false then this does nothing!
    mapInput.debug.setup_reduced_set_of_targets (mapData, mapInput);
    
    mapMemUsage.add('Reduced set of targets set up');

    %******************************************************************************
    % The MAP operations
    do_MAP (mapData, mapInput);

end % quickMAP or normal MAP
 
% Everything to be done after MAP
[mapCorrectedTargetDataStruct, alerts, basisVectors] = do_post_map_operations (mapData, mapInput, mapDiagnosticStruct);

mapMemUsage.add('end');

% plot memory usage
%mapMemUsage.plot_memory_usage;

end % map_controller

%******************************************************************************
%******************************************************************************
%******************************************************************************
% Internal functions

%******************************************************************************
function [] = do_MAP (mapData, mapInput)

    global mapMemUsage;

    %******************************************************************************
    %% Construct PDF class

    mapData.pdf = mapPdfClass(mapData, mapInput);

    mapMemUsage.add('substantiated mapData.pdf');

    %******************************************************************************
    %% Generate Prior PDF

    mapData.pdf.generate_prior_pdf(mapData, mapInput);
   
    mapMemUsage.add('Prior PDF generated');

    %******************************************************************************
    %% Generate Conditional PDF

    mapData.pdf.generate_conditional_pdf(mapData, mapInput);

    mapMemUsage.add('Conditional PDF generated');

    %******************************************************************************
    %% Generate Posterior PDF

    mapData.pdf.generate_posterior_pdf(mapData, mapInput);

    mapMemUsage.add('Posterior PDC generated');

    %******************************************************************************
    %% Maximize Posterior PDF
    % If forcing a robust fit then no need to call the maximizer

    if (~mapInput.mapParams.forceRobustFit)
        mapData.pdf.maximize_posterior_pdf(mapData, mapInput);

        mapMemUsage.add('Posterior PDF maximized');

    else
        mapData.pdf.targetsMapAppliedTo = false(mapData.nTargets,1);
    end

end

%******************************************************************************
function [mapCorrectedTargetDataStruct, alerts, basisVectors] = do_post_map_operations (mapData, mapInput, mapDiagnosticStruct)

    component = 'mapController';

    global mapMemUsage;

    %******************************************************************************
    %% Propogation Of Uncertainties (POU)

     map_propagation_of_uncertainties (mapData, mapInput);

    mapMemUsage.add('POU computed');

    %******************************************************************************
    %% Compile and plot results and populate the mapResultsObject for saving

     mapResultsObject = mapResultsClass('mapData', mapData, 'mapInput', mapInput);

    mapMemUsage.add('substantiated mapResultsObject');

    save_mapResultsStruct(mapResultsObject, mapInput, mapDiagnosticStruct)

    mapInput.debug.display(component, ['Finished MAP for run labelled  ', mapDiagnosticStruct.runLabel]);

    %******************************************************************************
    % Just return the fields that are really needed in PDC
    mapCorrectedTargetDataStruct = mapResultsObject.mapCorrectedTargetDataStruct;
    alerts = mapResultsObject.alerts;
    basisVectors = mapResultsObject.basisVectors;

end

%******************************************************************************
% Save the properties from the mapResultsObject only if requested
%
% NOTE: the short_mapResultsStruct which is used by pdc_create_output_struct is automatically saved when constructing mapResultsObject.

function save_mapResultsStruct(mapResultsObject, mapInput, mapDiagnosticStruct)

    if (mapDiagnosticStruct.doSaveResultsStruct)
        component = 'mapController';
        mapInput.debug.display(component, 'Saving mapResultsStruct to file...');
        mapResultsStruct = mapResultsObject.convert_to_struct;
        filename = ['mapResultsStruct_', mapInput.debug.runLabel];
        structName = ['mapResultsStruct_', mapInput.debug.runLabel];
        eval([structName ' = mapResultsStruct;']);
        intelligent_save(filename, structName);
        eval(['clear ', structName]); 
        mapInput.debug.display(component, 'Finished saving mapResultsStruct to file.');
    end
    
end

