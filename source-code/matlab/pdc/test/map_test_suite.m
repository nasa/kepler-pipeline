function [] = map_test_suite ()
% This tests MinimialMAP independtly of everything else in PDC. It's for testing until the
% architecture and other functions are ready in PDC toplevel.
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

% Clear classes so that any changes to class definitions are used
% This is a problem when using an external editor to edit .m files (like gvim)
% First save the breakpoints (otherwise they're get cleared!)
breakPoints = dbstatus;
clear mapInputClass;
clear mapDataClass;
clear mapResultsClass;
clear mapDebugClass;
clear mapPdfClass;
clear mapNormalizeClass;
dbstop(breakPoints);


%*************************************************************************************
% specific tests to perform

% Fully gapped target
doFullyGappedTarget = false;
doAlmostFullyGappedTarget = false;

% Target without RA, DEC or KepMag defined
doNoRaDecKepmag = false;

% Remove the Outliers (slow)
doRemoveOutliers = false;

% Test all basis vectors together
allBasisVectorsTogether = false;

% Just load after robust data
% Be very very careful when using this!
% First set: 
%saveAfterRobustFit = true
 loadThisRobustData = [];
% Then set and rerun
 saveAfterRobustFit = false;
%loadThisRobustData = 'afterRobustData';

%*************************************************************************************
% Bands

bandSplittingConfigurationStruct = struct(...
   'edgeEffectMitigationExtrapolationRange', 500, ...
               'edgeEffectMitigationMethod', 'expointmirrortaper', ...
             'groupingManualBandBoundaries', [1023 3], ...
                           'groupingMethod', 'manual', ...
                            'numberOfBands', 3, ...
                      'numberOfWaveletTaps', 12, ...
                          'splittingMethod', 'wavelet', ...
                            'waveletFamily', 'daubechies');

bsDiagnosticStruct = bsDataClass.create_default_diagnostic_struct();

% if bandToUse = 0 then do regularMAP
nBands = 3;
bandToUse = 0;

%*************************************************************************************
% Load motion polynomial blob
loadMotionPolyBlob = true;

%*************************************************************************************
% First entry is for regular MAP others are for each band MAP run

mapParams = struct(...
        'minFractionOfTargetsForSvd',       0.01, ... % If fewer than this fraction of targets left for SVD then crash and burn
        'fractionOfStarsToUseForSvd',       0.5,...
        'useOnlyQuietStarsForSvd',          true, ...
        'fractionOfStarsToUseForPriorPdf',  1.0,...
        'useOnlyQuietStarsForPriorPdf',     true, ...
        'fitNormalizationMethod',           [], ... % Normalization method for fitting
        'svdNormalizationMethod',           [], ... % Normalization method for SVD
        'numPointsForMaximizerFirstGuess',  100,... % number of points to sweep through PDF to bracket maximum
        'maxNumMaximizerIteration',         10,... % maximum number of times the range can be expanded to bracket the maximum
        'maxTolerance',                     1.0e-4,... % tolX for fminbnd
        'randomStreamSeed',                 int8(1),... % if = 0 then use system clock
        'svdOrder',                         0,... % 0 means auto-select svdOrder
        'svdMaxOrder',                      8,... % Maximum number of basis vectors (when svdOrder = 0)
        'svdOrderForReducedRobustFit',      [4 8 4 4],...
        'svdSnrCutoff',                     5, ... % Cutoff before rejecting a singular vector
        'ditherFlux',                       false,...
        'ditherMagnitude',                  0.05,...
        'variabilityCutoff',                1.3,... % How many times the median variability
        'coarseDetrendPolyOrder',           3,... % For use with finding prior goodness (NOT GOODNESS METRIC!)
        'priorPdfVariabilityWeight',        2.0,... % Power factor to scale variability by for prior weight
        'priorPdfGoodnessWeight',           1.0,... % power factor to scale prior goodness by for prior weight 
        'priorPdfGoodnessGain',             [1.0 1.0 20.0 20.0],... % Gain factor to scale prior goodness by for prior weight (needed when changing normalization method)
        'priorWeightGoodnessCutoff',        0.01, ... % if the prior goodness is below this value then zero the prior weight (and use reduced set of basis vectors)
        'priorWeightVariabilityCutoff',     0.5, ... % if the target variability is below this value then zero the prior weight
        'priorGoodnessScalingFactor',       10.0,... % A Prior Goodness above this means bad prior
        'priorGoodnessPowerFactor',         3.0,... % How strong the prior goodness decreases for a bad prior
        'priorKeplerMagnitudeScalingFactor',2.0e0,...
        'priorRaScalingFactor',             1.0e0,...
        'priorDecScalingFactor',            1.0e0,...
        'priorEffTempScalingFactor',        0.0e0,...
        'priorLogRadiusScalingFactor',      0.0e0,...
        'priorCentroidMotionScalingFactor', 0.0e0,...
        'priorPixelScalingFactor',          0.0e0,...
        'entropyCleaningEnabled',           true,...
        'entropyCleaningCutoff',            -0.7,... % Bad basis vector entropy as this negatice level
        'entropyMadFactor',                 10.0,... % How many times the MAD(V) is considered a basis vector over-dominating
        'entropyMaxIterations',             30,...  % Max number of iterations to entropy clean basis vectors
        'goodnessMetricIterationsEnabled',  [true false false false], ...
        'goodnessMetricIterationsCutoff',   0.8, ... % A goodness above this value is considered "good"
        'goodnessMetricIterationsPriorWeightStepSize',  2.0, ... % If adjusting prior weight, adjust by this factor
        'goodnessMetricMaxIterations',      50, ...
        'quickMapEnabled',                  false, ...
        'quickMapVariabilityCutoff',        1.0, ... % Variability cutoff below which LC MAP fit is not used
        'useBasisVectorsFromBlob',          false, ... % Use cbvBlobStruct basis vectors for fitting
        'useBasisVectorsAndPriorsFromBlob', false, ... % Use cbvBlobStruct for both CBVs and Priors for fitting
        'useBasisVectorsAndPriorsFromPixels', false, ... % Use cbvBlobStruct for both CBVs and robust fit coeffs from pixel data
        'usePriorsFromPixels',              false, ... % Use cbvBlobStruct for robust fit coeffs from pixel data
        'forceRobustFit',                   [false true false false]); % Never do a MAP fit, just the robust fit.

mapParams.fitNormalizationMethod = {'mean'  'mean'  'std'  'noiseFloor'};
mapParams.svdNormalizationMethod = {'noiseFloor'  'mean'  'std'  'noiseFloor'};

%Pick proper params based on which band is being run
mapParams = bs_clone_configuration_struct(mapParams,nBands+1);
mapParams = mapParams{bandToUse+1};

 % Goodness Metric Configuration parameters
 % For median normalization
 goodnessMetricConfigurationStruct = struct( ...
     'correlationScale',             1.2e1, ...
     'variabilityScale',             2e4, ...
     'earthPointScale',              1e0, ...
     'noiseScale',                   1e-4);
 % For sqrtMedian normalization
%goodnessMetricConfigurationStruct = struct( ...
%    'coarseDetrendPolyOrder',       3, ...
%    'correlationScale',             1.2e1, ...
%    'variabilityScale',             4e-3, ...
%    'noiseScale',                   1e-4);


% populate targetDataStruct with some real data.

%**************************
% LONG CADENCE
 mapParams.quickMapEnabled = false;
%inputDir = '/path/to/sample_data/Q1/lc/module14.2/pdc-matlab-1416-61991';
%inputDir = '/path/to/sample_data/Q2/lc/module7.3/pdc-matlab-2376-88696';
%inputDir = '/path/to/sample_data/Q5/lc/module2.1/pdc-matlab-2817-105693';
%inputDir = '/path/to/sample_data/Q5/lc/module7.3/pdc-matlab-2817-105713';
%inputDir = '/path/to/sample_data/Q5/lc/module10.1/pdc-matlab-2817-105768';
%inputDir = '/path/to/sample_data/Q5/lc/module17.2/pdc-matlab-2817-105734';
%inputDir = '/path/to/sample_data/Q5/lc/module13.4/pdc-matlab-2817-105757';
%inputDir = '/path/to/sample_data/Q4/lc/module12.2/pdc-matlab-1676-71183';
%inputDir = '/path/to/sample_data/Q4/lc/module12.3/pdc-matlab-1676-71180';
%inputDir = '/path/to/sample_data/Q4/lc/module16.1/pdc-matlab-1676-71170';
%inputDir = '/path/to/sample_data/Q4/lc/module10.1/pdc-matlab-1676-71146';
%inputDir = '/path/to/sample_data/Q7/lc/module7.2/pdc-matlab-5020-190830';
%inputDir = '/path/to/sample_data/Q7/lc/module2.1/pdc-matlab-5020-190817';
%inputDir = '/path/to/sample_data/Q7/lc/module20.4/pdc-matlab-5140-191508';
%inputDir = '/path/to/sample_data/Q7/lc/module24.3/pdc-matlab-5140-191519';
%inputDir = '/path/to/sample_data/Q7/lc/module24.4/pdc-matlab-5140-191520';
%inputDir = '/path/to/sample_data/Q7/lc/module11.2/pdc-matlab-5021-197090';
%inputDir = '/path/to/sample_data/KOI70/archive_7.0_run/Q7/pdc-matlab-4861-194419';
%inputDir = '/path/to/sample_data/KOI70/archive_7.0_run/Q4/pdc-matlab-4862-194483';
%inputDir = '/path/to/sample_data/KOI70/archive_7.0_run/Q3/pdc-matlab-4781-194073';
%inputDir = '/path/to/sample_data/Q9/lc/module2.1/pdc-matlab-5542-254942';
%inputDir = '/path/to/sample_data/Q9/lc/module7.3/pdc-matlab-5542-254956';
%inputDir = '/path/to/sample_data/Q9/lc/module13.1/pdc-matlab-5542-254978';
%inputDir = '/path/to/sample_data/Q9/lc/module17.2/pdc-matlab-5542-254995';
 inputDir = '/path/to/sample_data/Q10/lc/module2.1';
%inputDir = '/path/to/sample_data/Q10/lc/module7.3';
%inputDir = '/path/to/sample_data/Q10/lc/module13.1';
%inputDir = '/path/to/sample_data/Q10/lc/module15.2';
%inputDir = '/path/to/sample_data/Q10/lc/module17.2';
%inputDir = '/path/to/sample_data/Q10/lc/module24.4';
%inputDir = '/path/to/parameter_study/008/2.1_Q10';
%inputDir = '/path/to/analysis/MAP/KSOC-1468_POU/test_pou_data';
%inputDir = '/path/to/pixel_level_basisVectors_and_priors/Q5_2.1_jeff_k_priors_run_noBS';

 cbvBlobFilename = 'jeff_k_blob.mat';

%**************************
% SHORT CADENCE
%mapParams.quickMapEnabled = true;
%pdcBlobFilename = 'pdc_LC_blob.mat';

%inputDir = '/path/to/sample_data/Q9/sc/m1/7.3/pdc-matlab-5562-259168';
%inputDir = '/path/to/sample_data/Q9/sc/m2/7.3/pdc-matlab-5562-262065';
%inputDir = '/path/to/sample_data/Q9/sc/m3/7.3/pdc-matlab-5587-265933';

%inputDir = '/path/to/sample_data/Q9/sc/m1/2.1/pdc-matlab-5562-259154';
%inputDir = '/path/to/sample_data/Q9/sc/m2/2.1/pdc-matlab-5562-262043';
%inputDir = '/path/to/sample_data/Q9/sc/m3/2.1/pdc-matlab-5587-265914';

%inputDir = '/path/to/sample_data/Q9/sc/m1/13.1/pdc-matlab-5562-259175';
%inputDir = '/path/to/sample_data/Q9/sc/m2/13.1/pdc-matlab-5562-262052';
%inputDir = '/path/to/sample_data/Q9/sc/m3/13.1/pdc-matlab-5587-265940';

%inputDir = '/path/to/sample_data/Q9/sc/m1/17.2/pdc-matlab-5562-259160';
%inputDir = '/path/to/sample_data/Q9/sc/m2/17.2/pdc-matlab-5562-262045';
%inputDir = '/path/to/sample_data/Q9/sc/m3/17.2/pdc-matlab-5587-265919';


%**************************
% Modifications to mapConfigurationStruct for Short Cadence

% Want prior to be even closer to the MAD of light curve for it to be used
if (mapParams.quickMapEnabled)
    mapParams.priorGoodnessScalingFactor = 5.0;
    goodnessMetricConfigurationStruct = struct( ...
        'correlationScale',             1.2e1, ...
        'variabilityScale',             1e4, ...
        'earthPointScale',              1e0, ...
        'noiseScale',                   2e-5);
end

%outputDir = '~/analysis/test';
 outputDir = inputDir;
%outputDir = '/path/to/dev/soc/doc/publications/pdc/minimal_map/matlab_figures/Q7_2.1';
%outputDir = '/path/to/analysis/MAP/KSOC-1468_POU/test_pou_data';
ephemerisDataDir =  '~/sample_data/';
nTargets = 0;

%% Load light curves data struct.
inputsStruct = ...
        map_load_sample_data(inputDir, outputDir, nTargets, ephemerisDataDir, loadMotionPolyBlob );

inputsStruct = pdc_convert_83_data_to_90 (inputsStruct);

%****************************************************************
% Load Blob for Pixel studies for just from Blob
if (mapParams.useBasisVectorsAndPriorsFromPixels || mapParams.usePriorsFromPixels || ...
        mapParams.useBasisVectorsFromBlob || mapParams.useBasisVectorsAndPriorsFromBlob)
    load([inputDir, '/', cbvBlobFilename]);
    if (~exist('inputStruct'));
        error ('Blob does not appear to exist');
    end
    cbvBlobStruct = inputStruct;
else
    cbvBlobStruct  = [];
end

%****************************************************************
% Load blob for short cadence
if (mapParams.quickMapEnabled)
    load([inputDir, '/', pdcBlobFilename]);
    if (~exist('inputStruct'));
        error ('pdcBlobStruct does not appear to exist');
    end
    % What a terrible name "inputStruct" I wish I could change that.
    spsdBlobStruct = inputStruct.spsdBlobStruct;
    mapBlobStruct  = inputStruct.mapBlobStruct;
else
    spsdBlobStruct = [];
    mapBlobStruct  = [];
end

if (allBasisVectorsTogether)
    load([inputDir, '/', 'allCbvsTogether.mat']);
end


%****************************************************************
%% Generate flags for all targets whether to exclude them based on their labels
inputsStruct.targetDataStruct = pdc_generate_target_exclusion_list(inputsStruct.targetDataStruct , ...
        inputsStruct.pdcModuleParameters.excludeTargetLabels);

cadenceTimes = inputsStruct.cadenceTimes;
ccdModule = inputsStruct.ccdModule;
ccdOutput = inputsStruct.ccdOutput;

%****************************************************************
% Remove outliers
% This just identifies the outliers, The call to pdc_linearly_fill_gaps below actually does the removal
if (doRemoveOutliers && isempty(loadThisRobustData))
    pdctic = tic;
    disp('Identifying and removing outliers...');

    % Adding a field to gapFillConfigurationStruct. This is poor coding practice. Looks like a hack. Who did this?
    % TODO: Get rid of this. If it's a dependent parameter then put it somewhere else
    startTimestamps  = cadenceTimes.startTimestamps;
    endTimestamps = cadenceTimes.endTimestamps;
    cadenceGapIndicators = cadenceTimes.gapIndicators;
    startTimestamps  = startTimestamps(~cadenceGapIndicators);
    endTimestamps    = endTimestamps(~cadenceGapIndicators);
    cadenceDurations = endTimestamps - startTimestamps;
    inputsStruct.gapFillConfigurationStruct.cadenceDurationInMinutes = ...
            median(cadenceDurations) * get_unit_conversion('day2min');

    [~, inputsStruct.targetDataStruct] = pdc_detect_outliers( ...
        inputsStruct.targetDataStruct, inputsStruct.pdcModuleParameters, inputsStruct.gapFillConfigurationStruct );
    duration = toc(pdctic);
    disp(['Outliers detected and removed: ' num2str(duration) ...
        ' seconds = '  num2str(duration/60) ' minutes']);
end


%****************************************************************
% Test with mostly or fully gapped target
permutedTargets = randperm(length(inputsStruct.targetDataStruct));

if (doFullyGappedTarget)
    inputsStruct.targetDataStruct(permutedTargets(1)).gapIndicators(:) = true;
end
if (doAlmostFullyGappedTarget)
    inputsStruct.targetDataStruct(permutedTargets(1)).gapIndicators(2:end) = true;
end

% Test with no Ra, Dec or KepMag for some targets
if (doNoRaDecKepmag)
    for iPermutedTarget = 1 : 10
        inputsStruct.targetDataStruct(permutedTargets(iPermutedTarget)).kic.ra.value = nan;
    end
end

%****************************************************************

% At the very least, the gaps need to be filled.
% This is slow and not needed if loading in data after robust fit
if (isempty(loadThisRobustData))
    display('Linearly filling gaps...');
    [targetDataStruct, ~] = pdc_linearly_fill_gaps(inputsStruct.targetDataStruct, cadenceTimes);
    display('Finished linearly filling gaps.');
else
    targetDataStruct = inputsStruct.targetDataStruct;
end

% Use all targets when generating the priors
targetsForBasisVectorsAndPriors = true(length(targetDataStruct),1);

% Veto specific targets
% targetsForBasisVectorsAndPriors(248) = false;

%****************************************************************
% Find stellar variability

doNormalizeFlux = true;

[variabilityStruct.variability, variabilityStruct.medianVariability] = ...
        pdc_calculate_stellar_variability (targetDataStruct, cadenceTimes, ...
                 inputsStruct.pdcModuleParameters.variabilityDetrendPolyOrder, doNormalizeFlux, ...
                 inputsStruct.pdcModuleParameters.variabilityEpRecoveryMaskEnabled, ...
                 inputsStruct.pdcModuleParameters.variabilityEpRecoveryMaskWindow, ...
                 inputsStruct.pdcModuleParameters.stellarVariabilityRemoveEclipsingBinariesEnabled);

%**************************************
mapDiagnosticStruct = struct( ...
    'doQuickDiagnosticRun',         false, ...
    'debugRun',                true, ...
    'doFigures',               true, ...
    'doSaveFigures',           false, ...
    'doCloseAfterSaveFigures', false, ...
    'doSaveResultsStruct',     false, ...
    'runLabel',                'testRun', ...
    'saveAfterRobustFit',      saveAfterRobustFit, ...
    'loadThisRobustData',      loadThisRobustData); 

if (bandToUse ~= 0)
    [ targetDataStructBands , bsDataObject ] = bs_controller_split( targetDataStruct , ...
                                                                    bandSplittingConfigurationStruct ,  ...
                                                                    bsDiagnosticStruct );
    targetDataStruct = targetDataStructBands{bandToUse};
end
    

[mapResultsObject] = map_controller(mapParams, inputsStruct.pdcModuleParameters, targetDataStruct, ...
                    cadenceTimes, targetsForBasisVectorsAndPriors, mapDiagnosticStruct, variabilityStruct, ...
                    mapBlobStruct, cbvBlobStruct, goodnessMetricConfigurationStruct, ...
                    inputsStruct.motionPolyStruct );

display(['Fraction of targets with bad priors: ', num2str(mapResultsObject.bad_prior_ratio )])
display(['Fraction of targets where MAP was performed: ', num2str(mapResultsObject.map_performed_ratio  )])

% Save blob
pdcBlobFileName = 'pdc_blob.mat';
blobStruct = struct ('mapBlobStruct', mapResultsObject.mapBlobStruct, ...
                     'spsdBlobStruct', []);
save_struct_as_blob(blobStruct, pdcBlobFileName);

%******************************************************************************
%% Calculate Goodness Metric for both MAP and robust fit

% If MAP failed then do not calculate goodness (we know it's bad)
if (~mapResultsObject.mapFailed)

    %***
    % Find Goodness Results just for all targets
    %targetsToPlot = true(length(mapResultsObject.targetsMapAppliedTo),1);
    % Find Goodness Results for only targets to analayze
   %targetsToPlot = mapResultsObject.targetsMapAppliedTo;
    targetsToPlot = mapResultsObject.debug.targetsToAnalyze;

    %***
    % MAP results
    rawDataStruct = targetDataStruct(targetsToPlot);
    correctedDataStruct = mapResultsObject.mapCorrectedTargetDataStruct(targetsToPlot);

    doSavePlots = false;
    doNormalizeFlux = true;
    [goodnessStruct] = pdc_goodness_metric (rawDataStruct, correctedDataStruct, cadenceTimes, ...
                   inputsStruct.pdcModuleParameters, goodnessMetricConfigurationStruct, doNormalizeFlux, ...
                   doSavePlots, 'MAP ', true);


    %***
    % Robust results
   %robustCorrectedDataStruct = correctedDataStruct;
   %targetIndicesToPlot = find(targetsToPlot);
   %for iTarget = 1:length(robustCorrectedDataStruct)
   %    targetFullIndex = targetIndicesToPlot(iTarget);
   %    robustCorrectedDataStruct(iTarget).values = mapResultsObject.intermediateMapResults(targetFullIndex).robustResidual;
   %end
   %[RobustGoodnessStruct] = pdc_goodness_metric (rawDataStruct, robustCorrectedDataStruct, cadenceTimes, ...
   %               inputsStruct.pdcModuleParameters, goodnessMetricConfigurationStruct, doNormalizeFlux, ...
   %               doSavePlots, 'Robust ', true);
    

    % plot coefficient utilizaton
   %mapResultsObject.plot_coefficient_utilization;

    mapResultsObject.plot_prior_goodness;

    % Plot results here again after goodness metric to compare with goodness metric results
    mapResultsObject.plot_selected_targets ();
   %mapResultsObject.plot_selected_targets ('targetIndicesToPlot', [179 190]);
end

return;

%***************************************************************************
%***************************************************************************
%***************************************************************************
%% Internal Functions

%***************************************************************************
%% function [inputsStruct] = map_load_sample_data(inputDir, ...
%                                       outputDir, nTargets, ephemerisDataDir, loadMotionPolyBlob )
%
% This function loads input and output data from a PDC module output directory
%
% Inputs:
%   inputDir    -- [string (optional)] Directory to load inout struct from
%   outputDir   -- [string (optional)] output directory to cd into at end of execution
%   nTargets    -- [int (optional)] Number of targets to load
%
% Outputs:
%   inputsStruct  -- [struct] PDC input  structure
%
%%

function [inputsStruct] = map_load_sample_data ...
                        (inputDir, outputDir, nTargets, ephemerisDataDir, loadMotionPolyBlob )

display('This will load in data for testing Empirical MAP');

display(['Directory ', inputDir, ' PDC data loaded']);

%temporarily add the path
%addpath(inputDir);

dataFromLoad = load([inputDir, '/pdc-inputs-0.mat']);
inputsStruct = dataFromLoad.inputsStruct;

% Ephemeris planetary, spacecraft and leapsecond data must be in the matlab path
%addpath(ephemerisDataDir);

%Set directory for Ephemeris data in inputStruct
inputsStruct.raDec2PixModel.spiceFileDir=ephemerisDataDir;

%Specify how many targets to load
if (nTargets ~= 0)
    if (nTargets > size(inputsStruct.targetDataStruct))
        display('***');
        display('Hold on there tiger! There are not that many targets. All will be loaded...');
        display('***');
    elseif (nTargets == -1)
        targets = input('List specific targets [# # # ...]:');
        inputsStruct.targetDataStruct = inputsStruct.targetDataStruct(targets);
    else
        inputsStruct.targetDataStruct = inputsStruct.targetDataStruct(1:nTargets);
    end
end

%****************************************************************
% Motion polynomial data

if(loadMotionPolyBlob)
    cd(inputDir);
    motionBlobs = inputsStruct.motionBlobs;
    motionPolyStruct = poly_blob_series_to_struct(motionBlobs);
    inputsStruct.motionPolyStruct = motionPolyStruct;
    clear motionBlobs motionPolyStruct
else
    inputsStruct.motionPolyStruct = [];
end

%Select the working directory
cd(outputDir);

return
