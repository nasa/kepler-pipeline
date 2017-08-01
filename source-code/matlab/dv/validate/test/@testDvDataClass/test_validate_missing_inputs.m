function [self] = test_validate_missing_inputs(self)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% [self] = test_validate_missing_inputs(self)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% This test checks whether validate_dv_input catches missing fields and
% throws an error.  This test calls remove_field_and_test_for_failure.
%
%
%  Example
%  =======
%  Use a test runner to run the test method:
%      run(text_test_runner, testDvDataClass('test_validate_missing_inputs'));
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
tic;
fprintf('\nTesting validate_dv_inputs against missing fields in dv inputs...\n')

% Define variables, path and file names
quickAndDirtyCheckFlag = false;
suppressDisplayFlag = true;

initialize_soc_variables;
path = [socTestDataRoot filesep 'dv' filesep 'unit-tests' filesep 'dv-matlab-controller'];
matFileName = 'dvInputs.mat';
fullMatFileName = [path filesep matFileName];

% Add path so that blobs can be found
addpath(path);

% load previously generated data structure
load(fullMatFileName, 'dvDataStruct');

% Update spiceFileDirectory
dvDataStruct.raDec2PixModel.spiceFileDir = fullfile(socTestDataRoot, 'fc', 'spice');

% Update inputs, needed before class can be instantiated
dvDataStruct = update_dv_inputs(dvDataStruct);

%--------------------------------------------------------------------------
% Top level validation.
% Remove fields in dvDataStruct and test validate_dv_inputs catches it.
%--------------------------------------------------------------------------
fieldsAndBounds = cell(33,4);
fieldsAndBounds(1,:)  = { 'skyGroupId';  '>= 1'; '<= 84'; []};
fieldsAndBounds(2,:)  = { 'fcConstants'; []; []; []};                       % Validate only needed fields
fieldsAndBounds(3,:)  = { 'configMaps'; []; []; []};                        % Do not validate
fieldsAndBounds(4,:)  = { 'raDec2PixModel'; []; []; []};                    % Do not validate
fieldsAndBounds(5,:)  = { 'prfModels'; []; []; []};                         % Do not validate
fieldsAndBounds(6,:)  = { 'dvCadenceTimes'; []; []; []};
fieldsAndBounds(7,:)  = { 'dvConfigurationStruct'; []; []; []};
fieldsAndBounds(8,:)  = { 'fluxTypeConfigurationStruct'; []; []; []};
fieldsAndBounds(9,:)  = { 'planetFitConfigurationStruct'; []; []; []};
fieldsAndBounds(10,:) = { 'trapezoidalFitConfigurationStruct'; []; []; []};
fieldsAndBounds(11,:) = { 'centroidTestConfigurationStruct'; []; []; []};
fieldsAndBounds(12,:) = { 'pixelCorrelationConfigurationStruct'; []; []; []};
fieldsAndBounds(13,:) = { 'differenceImageConfigurationStruct'; []; []; []};
fieldsAndBounds(14,:) = { 'bootstrapConfigurationStruct'; []; []; []};
fieldsAndBounds(15,:) = { 'ancillaryEngineeringConfigurationStruct'; []; []; []};
fieldsAndBounds(16,:) = { 'ancillaryPipelineConfigurationStruct'; []; []; []};
fieldsAndBounds(17,:) = { 'ancillaryDesignMatrixConfigurationStruct'; []; []; []};
fieldsAndBounds(18,:) = { 'gapFillConfigurationStruct'; []; []; []};
fieldsAndBounds(19,:) = { 'pdcConfigurationStruct'; []; []; []};
fieldsAndBounds(20,:) = { 'saturationSegmentConfigurationStruct'; []; []; []};
fieldsAndBounds(21,:) = { 'tpsHarmonicsIdentificationConfigurationStruct'; []; []; []};
fieldsAndBounds(22,:) = { 'pdcHarmonicsIdentificationConfigurationStruct'; []; []; []};
fieldsAndBounds(23,:) = { 'tpsConfigurationStruct'; []; []; []};
fieldsAndBounds(24,:) = { 'ancillaryEngineeringDataFileName'; []; []; []};
fieldsAndBounds(25,:) = { 'targetTableDataStruct'; []; []; []};
fieldsAndBounds(26,:) = { 'targetStruct'; []; []; []};
fieldsAndBounds(27,:) = { 'kics'; []; []; []};
fieldsAndBounds(28,:) = { 'softwareRevision'; []; []; []};
fieldsAndBounds(29,:) = { 'transitParameterModelDescription'; []; []; []};
fieldsAndBounds(30,:) = { 'transitNameModelDescription'; []; []; []};
fieldsAndBounds(31,:) = { 'externalTceModelDescription'; []; []; []};
fieldsAndBounds(32,:) = { 'transitInjectionParametersFileName'; []; []; []};
fieldsAndBounds(33,:) = { 'taskTimeoutSecs'; '> 0'; []; []};

remove_field_and_test_for_failure(dvDataStruct, 'dvDataStruct', dvDataStruct, ...
    'dvDataStruct', 'validate_dv_inputs', ...
    fieldsAndBounds, quickAndDirtyCheckFlag, suppressDisplayFlag);

clear fieldsAndBounds

%--------------------------------------------------------------------------
% Second level validation.
% Remove fields in dvDataStruct.dvCadenceTimes and test validate_dv_inputs
% catches it.
%--------------------------------------------------------------------------
fieldsAndBounds = cell(19,4);
fieldsAndBounds(1,:)  = { 'startTimestamps'; '> 54500'; '< 70000'; []};     % 2/4/2008 to 7/13/2050
fieldsAndBounds(2,:)  = { 'midTimestamps'; '> 54500'; '< 70000'; []};       % 2/4/2008 to 7/13/2050
fieldsAndBounds(3,:)  = { 'endTimestamps'; '> 54500'; '< 70000'; []};       % 2/4/2008 to 7/13/2050
fieldsAndBounds(4,:)  = { 'gapIndicators'; []; []; [true; false]};
fieldsAndBounds(5,:)  = { 'requantEnabled'; []; []; [true; false]};
fieldsAndBounds(6,:)  = { 'cadenceNumbers'; '>= 0'; '< 5e5'; []};
fieldsAndBounds(7,:)  = { 'quarters'; '>= 0'; '< 100'; []};
fieldsAndBounds(8,:)  = { 'lcTargetTableIds'; '> 0'; '< 256'; []};          % FOR NOW
fieldsAndBounds(9,:)  = { 'scTargetTableIds'; []; []; []};                  % NOT USED IN DV
fieldsAndBounds(10,:) = { 'isSefiAcc'; []; []; [true; false]};
fieldsAndBounds(11,:) = { 'isSefiCad'; []; []; [true; false]};
fieldsAndBounds(12,:) = { 'isLdeOos'; []; []; [true; false]};
fieldsAndBounds(13,:) = { 'isFinePnt'; []; []; [true; false]};
fieldsAndBounds(14,:) = { 'isMmntmDmp'; []; []; [true; false]};
fieldsAndBounds(15,:) = { 'isLdeParEr'; []; []; [true; false]};
fieldsAndBounds(16,:) = { 'isScrcErr'; []; []; [true; false]};
fieldsAndBounds(17,:) = { 'dataAnomalyFlags'; []; []; []};
fieldsAndBounds(18,:) = { 'originalQuarters'; '>= 0'; '< 100'; []};
fieldsAndBounds(19,:) = { 'originalLcTargetTableIds'; '> 0'; '< 256'; []};  % FOR NOW

remove_field_and_test_for_failure(dvDataStruct.dvCadenceTimes, ...
    'dvDataStruct.dvCadenceTimes', dvDataStruct, 'dvDataStruct',  ...
     'validate_dv_inputs', ...
     fieldsAndBounds, quickAndDirtyCheckFlag, suppressDisplayFlag);

clear fieldsAndBounds

%--------------------------------------------------------------------------
% Second level validation.
% Remove fields in dvDataStruct.dvConfigurationStruct and test validate_dv_inputs
% catches it.
%--------------------------------------------------------------------------
fieldsAndBounds = cell(20,4);
fieldsAndBounds(1,:)  = { 'debugLevel'; '>= 0'; '<= 5'; []};
fieldsAndBounds(2,:)  = { 'modelFitEnabled'; []; []; [true; false]};
fieldsAndBounds(3,:)  = { 'multiplePlanetSearchEnabled'; []; []; [true; false]};
fieldsAndBounds(4,:)  = { 'weakSecondaryTestEnabled'; []; []; [true; false]};
fieldsAndBounds(5,:)  = { 'differenceImageGenerationEnabled'; []; []; [true; false]};
fieldsAndBounds(6,:)  = { 'centroidTestsEnabled'; []; []; [true; false]};
fieldsAndBounds(7,:)  = { 'ghostDiagnosticTestsEnabled'; []; []; [true; false]};
fieldsAndBounds(8,:)  = { 'pixelCorrelationTestsEnabled'; []; []; [true; false]};
fieldsAndBounds(9,:)  = { 'binaryDiscriminationTestsEnabled'; []; []; [true; false]};
fieldsAndBounds(10,:) = { 'bootstrapEnabled'; []; []; [true; false]};
fieldsAndBounds(11,:) = { 'rollingBandDiagnosticsEnabled'; []; []; [true; false]};
fieldsAndBounds(12,:) = { 'reportEnabled'; []; []; [true; false]};
fieldsAndBounds(13,:) = { 'koiMatchingEnabled'; []; []; [true; false]};
fieldsAndBounds(14,:) = { 'koiMatchingThreshold'; '> 0'; '<= 1'; []};
fieldsAndBounds(15,:) = { 'externalTcesEnabled'; []; []; [true; false]};
fieldsAndBounds(16,:) = { 'simulatedTransitsEnabled'; []; []; [true; false]};
fieldsAndBounds(17,:) = { 'transitModelName'; []; []; {'mandel-agol_geometric_transit_model'}};
fieldsAndBounds(18,:) = { 'limbDarkeningModelName'; []; []; {'claret_nonlinear_limb_darkening_model'; ...
                                                             'kepler_nonlinear_limb_darkening_model'; ...
                                                             'claret_nonlinear_limb_darkening_model_2011'}};
fieldsAndBounds(19,:) = { 'maxCandidatesPerTarget'; '>= 1'; '<= 25'; []};
fieldsAndBounds(20,:) = { 'team'; []; []; []};

remove_field_and_test_for_failure(dvDataStruct.dvConfigurationStruct, ...
    'dvDataStruct.dvConfigurationStruct', dvDataStruct, 'dvDataStruct',  ...
     'validate_dv_inputs', ...
     fieldsAndBounds, quickAndDirtyCheckFlag, suppressDisplayFlag);

clear fieldsAndBounds

%--------------------------------------------------------------------------
% Second level validation.
% Remove fields in dvDataStruct.fluxTypeConfigurationStruct and test validate_dv_inputs
% catches it.
%--------------------------------------------------------------------------
fieldsAndBounds = cell(1,4);
fieldsAndBounds(1,:)  = { 'fluxType'; []; []; {'SAP'; 'OAP'; 'DIA'}};

remove_field_and_test_for_failure(dvDataStruct.fluxTypeConfigurationStruct, ...
    'dvDataStruct.fluxTypeConfigurationStruct', dvDataStruct, ...
    'dvDataStruct', 'validate_dv_inputs', ...
    fieldsAndBounds, quickAndDirtyCheckFlag, suppressDisplayFlag);

clear fieldsAndBounds

%--------------------------------------------------------------------------
% Second level validation.
% Remove fields in dvDataStruct.planetFitConfigurationStruct and test validate_dv_inputs
% catches it.
%--------------------------------------------------------------------------
fieldsAndBounds = cell(46,4);
fieldsAndBounds(1,:)  = { 'transitSamplesPerCadence'; '> 0'; '<= 540'; []};
fieldsAndBounds(2,:)  = { 'smallBodyCutoff'; '>= 0'; '<= 1e12'; []};
fieldsAndBounds(3,:)  = { 'tightParameterConvergenceTolerance'; '> 0'; '< 1'; []};
fieldsAndBounds(4,:)  = { 'looseParameterConvergenceTolerance'; '> 0'; '< 1'; []};
fieldsAndBounds(5,:)  = { 'tightSecondaryParameterConvergenceTolerance'; '> 0'; '< 1'; []};
fieldsAndBounds(6,:)  = { 'looseSecondaryParameterConvergenceTolerance'; '> 0'; '< 1'; []};
fieldsAndBounds(7,:)  = { 'chiSquareConvergenceTolerance'; '> 0'; '< 1'; []};
fieldsAndBounds(8,:)  = { 'whitenerFitterMaxIterations'; '>= 1'; '<= 10000'; []};
fieldsAndBounds(9,:)  = { 'cotrendingEnabled'; []; []; [true; false]};
fieldsAndBounds(10,:) = { 'robustFitEnabled'; []; []; [true; false]};
fieldsAndBounds(11,:) = { 'saveTimeSeriesEnabled'; []; []; [true; false]};
fieldsAndBounds(12,:) = { 'reducedParameterFitsEnabled'; []; []; [true; false]};
fieldsAndBounds(13,:) = { 'impactParametersForReducedFits'; []; []; []};          % Can't set bounds if vector may be empty
fieldsAndBounds(14,:) = { 'trapezoidalModelFitEnabled'; []; []; [true; false]};
fieldsAndBounds(15,:) = { 'tolFun'; '> 0'; '< 1'; []};                            % FOR NOW
fieldsAndBounds(16,:) = { 'tolX'; '> 0'; '< 1'; []};                              % FOR NOW
fieldsAndBounds(17,:) = { 'tolSigma'; '> 0'; '< 1'; []};                          % FOR NOW
fieldsAndBounds(18,:) = { 'transitBufferCadences'; '> 0'; '< 20'; []};            % FOR NOW
fieldsAndBounds(19,:) = { 'transitEpochStepSizeCadences'; '>= -1'; '< 10'; []};   % FOR NOW
fieldsAndBounds(20,:) = { 'planetRadiusStepSizeEarthRadii'; '>= -1'; '< 10'; []}; % FOR NOW
fieldsAndBounds(21,:) = { 'ratioPlanetRadiusToStarRadiusStepSize'; '>= -1'; '< 10'; []};     % FOR NOW
fieldsAndBounds(22,:) = { 'semiMajorAxisStepSizeAu'; '>= -1'; '< 10'; []};        % FOR NOW
fieldsAndBounds(23,:) = { 'ratioSemiMajorAxisToStarRadiusStepSize'; '>= -1'; '< 10'; []};    % FOR NOW
fieldsAndBounds(24,:) = { 'minImpactParameterStepSize'; '>= -1'; '< 10'; []};     % FOR NOW
fieldsAndBounds(25,:) = { 'orbitalPeriodStepSizeDays'; '>= -1'; '< 10'; []};      % FOR NOW
fieldsAndBounds(26,:) = { 'fitterTransitRemovalMethod'; []; []; '[0:1]'''};       % FOR NOW
fieldsAndBounds(27,:) = { 'fitterTransitRemovalBufferTransits'; '>= 0'; []; []};  % FOR NOW
fieldsAndBounds(28,:) = { 'subtractModelTransitRemovalMethod'; []; []; '[0:1]'''};          % FOR NOW
fieldsAndBounds(29,:) = { 'subtractModelTransitRemovalBufferTransits'; '>= 0'; []; []};     % FOR NOW
fieldsAndBounds(30,:) = { 'eclipsingBinaryDepthLimitPpm'; '>= 0'; []; []};        % FOR NOW
fieldsAndBounds(31,:) = { 'eclipsingBinaryAspectRatioLimitCadences'; '>= 0'; []; []};       % FOR NOW
fieldsAndBounds(32,:) = { 'eclipsingBinaryAspectRatioDepthLimitPpm'; '>= 0'; []; []};       % FOR NOW
fieldsAndBounds(33,:) = { 'giantTransitDetectionThresholdScaleFactor'; '>= 0'; '< 5'; []};  % FOR NOW
fieldsAndBounds(34,:) = { 'fitterTimeoutFraction'; '>= 0'; '<= 1'; []};           % FOR NOW
fieldsAndBounds(35,:) = { 'impactParameterSeed'; '>= 0'; '<= 1'; []};
fieldsAndBounds(36,:) = { 'iterationToFreezeCadencesForFit'; '>= 0'; '< 10'; []};
fieldsAndBounds(37,:) = { 'defaultRadius'; '> 0'; '< 10'; []};
fieldsAndBounds(38,:) = { 'defaultEffectiveTemp'; '> 0'; '< 8000'; []};
fieldsAndBounds(39,:) = { 'defaultLog10SurfaceGravity'; '> 3'; '< 5'; []};
fieldsAndBounds(40,:) = { 'defaultLog10Metallicity'; '>= -25'; '<= 5'; []};
fieldsAndBounds(41,:) = { 'defaultAlbedo'; '>= 0'; '<= 1'; []};
fieldsAndBounds(42,:) = { 'transitDurationMultiplier'; '>= 1'; '< 100'; []};
fieldsAndBounds(43,:) = { 'robustWeightThresholdForPlots'; '>= 0'; '<= 1'; []};
fieldsAndBounds(44,:) = { 'reportSummaryClippingLevel'; '> 0'; '< 25'; []};
fieldsAndBounds(45,:) = { 'reportSummaryBinsPerTransit'; '>= 1'; '< 25'; []};
fieldsAndBounds(46,:) = { 'deemphasisWeightsEnabled'; []; []; [true; false]};

remove_field_and_test_for_failure(dvDataStruct.planetFitConfigurationStruct, ...
    'dvDataStruct.planetFitConfigurationStruct', dvDataStruct, ...
    'dvDataStruct', 'validate_dv_inputs', ...
    fieldsAndBounds, quickAndDirtyCheckFlag, suppressDisplayFlag);

clear fieldsAndBounds

%--------------------------------------------------------------------------
% Second level validation.
% Remove fields in dvDataStruct.trapezoidalFitConfigurationStruct and test validate_dv_inputs
% catches it.
%--------------------------------------------------------------------------
fieldsAndBounds = cell(7,4);
fieldsAndBounds(1,:)  = { 'defaultSmoothingParameter'; '>= 0'; '<= 1e12'; []};
fieldsAndBounds(2,:)  = { 'filterCircularShift'; '> 0'; '<= 1000'; []};
fieldsAndBounds(3,:)  = { 'gapThreshold'; '> 0'; '<= 1000'; []};
fieldsAndBounds(4,:)  = { 'medianFilterLength'; '> 0'; '<= 1e6'; []};
fieldsAndBounds(5,:)  = { 'snrThreshold'; '> 0'; '<= 1e6'; []};
fieldsAndBounds(6,:)  = { 'transitFitRegion'; '> 1'; '<= 20'; []};
fieldsAndBounds(7,:)  = { 'transitSamplesPerCadence'; '> 0'; '<= 540'; []};

remove_field_and_test_for_failure(dvDataStruct.trapezoidalFitConfigurationStruct, ...
    'dvDataStruct.trapezoidalFitConfigurationStruct', dvDataStruct, ...
    'dvDataStruct', 'validate_dv_inputs', ...
    fieldsAndBounds, quickAndDirtyCheckFlag, suppressDisplayFlag);

clear fieldsAndBounds

%--------------------------------------------------------------------------
% Second level validation.
% Remove fields in dvDataStruct.centroidTestConfigurationStruct and test validate_dv_inputs
% catches it.
%--------------------------------------------------------------------------
fieldsAndBounds = cell(17,4);
fieldsAndBounds(1,:)  = { 'centroidModelFineMeshFactor'; '>= 1'; '<= 100'; []};
fieldsAndBounds(2,:)  = { 'iterativeWhitenerTolerance'; '>= 0.000001'; '<= 1'; []};
fieldsAndBounds(3,:)  = { 'iterationLimit'; '>= 1'; '<= 1000'; []};
fieldsAndBounds(4,:)  = { 'padTransitCadences'; '>= 0'; '<= 50'; []};
fieldsAndBounds(5,:)  = { 'minimumPointsPerPlanet'; '>= 1'; '<= 100'; []};
fieldsAndBounds(6,:)  = { 'maximumTransitDurationCadences'; '>= 10'; '<= 200'; []};
fieldsAndBounds(7,:)  = { 'centroidModelFineMeshEnabled'; []; []; [true false]};
fieldsAndBounds(8,:)  = { 'transitDurationsMasked'; '>= 0'; '<= 10'; []};
fieldsAndBounds(9,:)  = { 'transitDurationFactorForMedianFilter'; '>= 1'; '<= 100'; []};
fieldsAndBounds(10,:) = { 'defaultMaxTransitDurationCadences'; '>= 1'; '<= 200'; []};
fieldsAndBounds(11,:) = { 'madsToClipForCloudPlot'; '>= 0'; '<= 1000'; []};
fieldsAndBounds(12,:) = { 'foldedTransitDurationsShown'; '>= 1'; '<= 50'; []};
fieldsAndBounds(13,:) = { 'plotOutlierThesholdInSigma'; '>= 0'; '<= 1000'; []};
fieldsAndBounds(14,:) = { 'cloudPlotRaMarker'; []; []; {'+b','or','*g','.c','xm','sk','dk','^k','vk','>k','<k','pk','hk'}};
fieldsAndBounds(15,:) = { 'cloudPlotDecMarker'; []; []; {'+b','or','*g','.c','xm','sk','dk','^k','vk','>k','<k','pk','hk'}};
fieldsAndBounds(16,:) = { 'maximumSourceRaDecOffsetArcsec'; '>= 1'; '<= 1000'; []};
fieldsAndBounds(17,:) = { 'chiSquaredTolerance'; '>= 0'; '<= 1'; []};

remove_field_and_test_for_failure(dvDataStruct.centroidTestConfigurationStruct, ...
    'dvDataStruct.centroidTestConfigurationStruct', dvDataStruct, ...
    'dvDataStruct', 'validate_dv_inputs', ...
    fieldsAndBounds, quickAndDirtyCheckFlag, suppressDisplayFlag);

clear fieldsAndBounds

%--------------------------------------------------------------------------
% Second level validation.
% Remove fields in dvDataStruct.pixelCorrelationConfigurationStruct and test validate_dv_inputs
% catches it.
%--------------------------------------------------------------------------
fieldsAndBounds = cell(10,4);
fieldsAndBounds(1,:)  = { 'iterativeWhitenerTolerance'; '>= 0.000001'; '<= 1'; []};
fieldsAndBounds(2,:)  = { 'iterationLimit'; '>= 1'; '<= 1000'; []};
fieldsAndBounds(3,:)  = { 'significanceThreshold'; '>= 0'; '<= 1'; []};
fieldsAndBounds(4,:)  = { 'numIndicesDisplayedInAlerts'; '>= 0'; '<= 100'; []};
fieldsAndBounds(5,:)  = { 'apertureSymbol'; []; []; {'+','o','*','.','x','s','d','^','v','>','<','p','h'}};
fieldsAndBounds(6,:)  = { 'optimalApertureSymbol'; []; []; {'+','o','*','.','x','s','d','^','v','>','<','p','h'}};
fieldsAndBounds(7,:)  = { 'significanceSymbol'; []; []; {'+','o','*','.','x','s','d','^','v','>','<','p','h'}};
fieldsAndBounds(8,:)  = { 'colorMap'; []; []; {'hot','cool','spring','summer','autumn','winter','jet','grey','bone','copper','pink','HSV'}};
fieldsAndBounds(9,:)  = { 'maxColorAxis'; '>= 0'; '<= 100000'; []};
fieldsAndBounds(10,:) = { 'chiSquaredTolerance'; '>= 0'; '<= 1'; []};

remove_field_and_test_for_failure(dvDataStruct.pixelCorrelationConfigurationStruct, ...
    'dvDataStruct.pixelCorrelationConfigurationStruct', dvDataStruct, ...
    'dvDataStruct', 'validate_dv_inputs', ...
    fieldsAndBounds, quickAndDirtyCheckFlag, suppressDisplayFlag);

clear fieldsAndBounds

%--------------------------------------------------------------------------
% Second level validation.
% Remove fields in dvDataStruct.differenceImageConfigurationStruct and test validate_dv_inputs
% catches it.
%--------------------------------------------------------------------------
fieldsAndBounds = cell(13,4);
fieldsAndBounds(1,:)  = { 'detrendingEnabled'; []; []; [true; false]};
fieldsAndBounds(2,:)  = { 'detrendPolyOrder'; '>= 0'; '<= 6'; []};
fieldsAndBounds(3,:)  = { 'defaultMedianFilterLength'; '>= 25'; '< 1000'; []};
fieldsAndBounds(4,:)  = { 'anomalyBufferInDays'; '>= 0.0'; '<= 10.0'; []};
fieldsAndBounds(5,:)  = { 'controlBufferInCadences'; '>= 0'; '< 50'; []};
fieldsAndBounds(6,:)  = { 'minInTransitDepth'; '>= 0.2'; '< 1.0'; []};
fieldsAndBounds(7,:)  = { 'overlappedTransitExclusionEnabled'; []; []; [true; false]};
fieldsAndBounds(8,:)  = { 'singlePrfFitSnrThreshold'; '>= 0.0'; '<= 1000.0'; []};
fieldsAndBounds(9,:)  = { 'maxSinglePrfFitTrials'; '> 0'; '<= 1024'; []};
fieldsAndBounds(10,:) = { 'maxSinglePrfFitFailures'; '> 0'; '<= 100'; []};
fieldsAndBounds(11,:) = { 'singlePrfFitForCentroidPositionsEnabled'; []; []; [true; false]};
fieldsAndBounds(12,:) = { 'mqOffsetConstantUncertainty'; '>= 0.0'; '< 1.0'; []};
fieldsAndBounds(13,:) = { 'qualityThreshold'; '> 0.0'; '< 1.0'; []};

remove_field_and_test_for_failure(dvDataStruct.differenceImageConfigurationStruct, ...
    'dvDataStruct.differenceImageConfigurationStruct', dvDataStruct, ...
    'dvDataStruct', 'validate_dv_inputs', ...
    fieldsAndBounds, quickAndDirtyCheckFlag, suppressDisplayFlag);

clear fieldsAndBounds

%--------------------------------------------------------------------------
% Second level validation.
% Remove fields in dvDataStruct.bootstrapConfigurationStruct and test validate_dv_inputs
% catches it.
%--------------------------------------------------------------------------
fieldsAndBounds = cell(12,4);
fieldsAndBounds(1,:)  = { 'skipCount'; '> 0'; '< 1000'; []};                         % FOR NOW
fieldsAndBounds(2,:)  = { 'autoSkipCountEnabled'; []; []; [true; false]};
fieldsAndBounds(3,:)  = { 'maxIterations'; '>= 1e3'; '<= 1e12'; []};                 % FOR NOW
fieldsAndBounds(4,:)  = { 'maxNumberBins'; '>= 10'; '<= 1e8'; []};                   % FOR NOW
fieldsAndBounds(5,:)  = { 'histogramBinWidth'; '> 0'; '< 1'; []};                    % FOR NOW
fieldsAndBounds(6,:)  = { 'binsBelowSearchTransitThreshold'; '>= 0'; '< 10'; []};    % FOR NOW
fieldsAndBounds(7,:)  = { 'upperLimitFactor'; '>=1'; '<= 100'; []};                  % FOR NOW
fieldsAndBounds(8,:)  = { 'useTceTrialPulseOnly'; []; []; [true; false]};
fieldsAndBounds(9,:)  = { 'maxAllowedMes'; '>=-1'; '<= 1e12'; []};       
fieldsAndBounds(10,:) = { 'maxAllowedTransitCount'; '>=-1'; '<= 1e12'; []};       
fieldsAndBounds(11,:) = { 'convolutionMethodEnabled'; []; []; [true; false]};
fieldsAndBounds(12,:) = { 'deemphasizeQuartersWithoutTransits'; []; []; [true; false]};

remove_field_and_test_for_failure(dvDataStruct.bootstrapConfigurationStruct, ...
    'dvDataStruct.bootstrapConfigurationStruct', dvDataStruct, ...
    'dvDataStruct', 'validate_dv_inputs', ...
    fieldsAndBounds, quickAndDirtyCheckFlag, suppressDisplayFlag);

clear fieldsAndBounds

%--------------------------------------------------------------------------
% Second level validation.
% Remove fields in dvDataStruct.ancillaryPipelineConfigurationStruct, 
% if ancillaryPipelineDataStruct not empty and test validate_dv_inputs catches it.
%--------------------------------------------------------------------------
if ~isempty(dvDataStruct.targetTableDataStruct(1).ancillaryPipelineDataStruct)
    
    fieldsAndBounds = cell(3,4);
    fieldsAndBounds(1,:)  = { 'mnemonics'; []; []; {}};
    fieldsAndBounds(2,:)  = { 'modelOrders'; '>= 0'; '<= 5'; []};
    fieldsAndBounds(3,:)  = { 'interactions'; []; []; {}};

    remove_field_and_test_for_failure(dvDataStruct.ancillaryPipelineConfigurationStruct, ...
        'dvDataStruct.ancillaryPipelineConfigurationStruct', ...
        dvDataStruct, 'dvDataStruct', 'validate_dv_inputs', ...
        fieldsAndBounds, quickAndDirtyCheckFlag, suppressDisplayFlag);

    clear fieldsAndBounds;
    
end

%--------------------------------------------------------------------------
% Second level validation.
% Remove fields in dvDataStruct.ancillaryDesignMatrixConfigurationStruct, 
% and test validate_dv_inputs catches it.
%--------------------------------------------------------------------------
fieldsAndBounds = cell(4,4);
fieldsAndBounds(1,:)  = { 'filteringEnabled'; []; []; [true; false]};
fieldsAndBounds(2,:)  = { 'sgPolyOrders'; '>= 1'; '<= 4'; []};
fieldsAndBounds(3,:)  = { 'sgFrameSizes'; '> 4'; '< 10000'; []};
fieldsAndBounds(4,:)  = { 'bandpassFlags'; []; []; [true; false]};

validate_structure(dvDataStruct.ancillaryDesignMatrixConfigurationStruct, fieldsAndBounds, ...
    'dvDataStruct.ancillaryDesignMatrixConfigurationStruct');

clear fieldsAndBounds

%--------------------------------------------------------------------------
% Second level validation.
% Remove fields indvDataStruct.gapFillConfigurationStruct and test
% validate_dv_inputs catches it.
%--------------------------------------------------------------------------
fieldsAndBounds = cell(11,4);
fieldsAndBounds(1,:)  = { 'madXFactor'; '> 0'; '<= 100'; []};
fieldsAndBounds(2,:)  = { 'maxGiantTransitDurationInHours'; '> 0' ; '< 24*5'; []};
fieldsAndBounds(3,:)  = { 'maxDetrendPolyOrder'; []; []; '[1:25]'''};                 % can take only integer values
fieldsAndBounds(4,:)  = { 'maxArOrderLimit'; []; []; '[1:25]'''};                     % can take only integer values
fieldsAndBounds(5,:)  = { 'maxCorrelationWindowXFactor'; '> 0'; '<= 25'; []};
fieldsAndBounds(6,:)  = { 'gapFillModeIsAddBackPredictionError'; []; []; [true, false]};
fieldsAndBounds(7,:)  = { 'waveletFamily'; []; []; {'haar'; 'daub'; 'morlet'; 'coiflet'; 'meyer'; 'gauss'; 'mexhat'}};
fieldsAndBounds(8,:)  = { 'waveletFilterLength'; []; []; '[2:2:128]'''};
fieldsAndBounds(9,:)  = { 'giantTransitPolyFitChunkLengthInHours'; '> 0'; '< 24*30'; []};
fieldsAndBounds(10,:) = { 'removeEclipsingBinariesOnList'; [] ; []; [true, false]} ;
fieldsAndBounds(11,:) = { 'arAutoCorrelationThreshold'; '>= 0' ; '<= 1'; []} ;

remove_field_and_test_for_failure(dvDataStruct.gapFillConfigurationStruct, ...
    'dvDataStruct.gapFillConfigurationStruct', dvDataStruct, 'dvDataStruct',  ...
    'validate_dv_inputs', fieldsAndBounds, quickAndDirtyCheckFlag, suppressDisplayFlag);

clear fieldsAndBounds

%--------------------------------------------------------------------------
% Second level validation.
% Remove fields indvDataStruct.pdcConfigurationStruct and test
% validate_dv_inputs catches it.
%--------------------------------------------------------------------------
fieldsAndBounds = cell(31,4);
fieldsAndBounds(1,:)  = { 'debugLevel'; '>= 0'; '<= 5'; []};
fieldsAndBounds(2,:)  = { 'robustCotrendFitFlag'; []; []; [true; false]};
fieldsAndBounds(3,:)  = { 'medianFilterLength'; '>= 1'; '< 1000'; []};
fieldsAndBounds(4,:)  = { 'outlierThresholdXFactor'; '> 0'; '<= 1000'; []};
fieldsAndBounds(5,:)  = { 'normalizationEnabled'; []; []; [true; false]};
fieldsAndBounds(6,:)  = { 'stellarVariabilityDetrendOrder'; '>= 0'; '< 10'; []};
fieldsAndBounds(7,:)  = { 'stellarVariabilityThreshold'; '> 0'; '< 1'; []};
fieldsAndBounds(8,:)  = { 'minHarmonicsForDetrending'; '>= 1'; '< 100'; []};
fieldsAndBounds(9,:)  = { 'harmonicDetrendOrder'; '>= 0'; '< 10'; []};
fieldsAndBounds(10,:) = { 'thermalRecoveryDurationInDays'; '>= 0'; '< 10'; []};        % FOR NOW
fieldsAndBounds(11,:) = { 'neighborhoodRadiusForAttitudeTweak'; '>= 0'; '< 500'; []};  % FOR NOW
fieldsAndBounds(12,:) = { 'attitudeTweakBufferInDays'; '>= 0'; '< 10'; []};            % FOR NOW
fieldsAndBounds(13,:) = { 'safeModeBufferInDays'; '>= 0'; '< 10'; []};                 % FOR NOW
fieldsAndBounds(14,:) = { 'earthPointBufferInDays'; '>= 0'; '< 10'; []};               % FOR NOW
fieldsAndBounds(15,:) = { 'coarsePointBufferInDays'; '>= 0'; '< 10'; []};              % FOR NOW
fieldsAndBounds(16,:) = { 'astrophysicalEventBridgeInDays'; '>= 0'; '< 1'; []};        % FOR NOW
fieldsAndBounds(17,:) = { 'cotrendRatioMaxTimeScaleInDays'; '>= 0'; '< 10'; []};       % FOR NOW
fieldsAndBounds(18,:) = { 'cotrendPerformanceLimit'; '>= 1'; '< 1e12'; []};            % FOR NOW
fieldsAndBounds(19,:) = { 'mapEnabled'; []; []; [true; false]};
fieldsAndBounds(20,:) = { 'excludeTargetLabels'; []; []; {}};
fieldsAndBounds(21,:) = { 'harmonicsRemovalEnabled'; []; []; [true; false]};
fieldsAndBounds(22,:) = { 'preMapIterations'; '> 0'; '< 10'; []};
fieldsAndBounds(23,:) = { 'variabilityEpRecoveryMaskEnabled'; []; []; [true; false]};
fieldsAndBounds(24,:) = { 'variabilityEpRecoveryMaskWindow'; []; []; []};
fieldsAndBounds(25,:) = { 'variabilityDetrendPolyOrder'; []; []; []};
fieldsAndBounds(26,:) = { 'bandSplittingEnabled'; []; []; [true; false]};
fieldsAndBounds(27,:) = { 'bandSplittingEnabledQuarters'; []; []; []};
fieldsAndBounds(28,:) = { 'stellarVariabilityRemoveEclipsingBinariesEnabled'; []; []; [true; false]};
fieldsAndBounds(29,:) = { 'mapSelectionMethod'; []; []; []};
fieldsAndBounds(30,:) = { 'mapSelectionMethodCutoff'; '>= 0'; '<= 1.0'; []};
fieldsAndBounds(31,:) = { 'mapSelectionMethodMultiscaleBias'; '>= 0'; '<= 1'; []};

remove_field_and_test_for_failure(dvDataStruct.pdcConfigurationStruct, ...
    'dvDataStruct.pdcConfigurationStruct', dvDataStruct, 'dvDataStruct',  ...
    'validate_dv_inputs', ...
    fieldsAndBounds, quickAndDirtyCheckFlag, suppressDisplayFlag);

clear fieldsAndBounds

%--------------------------------------------------------------------------
% Second level validation.
% Remove fields in dvDataStruct.saturationSegmentConfigurationStruct and
% test validate_dv_inputs catches it.
%--------------------------------------------------------------------------
fieldsAndBounds = cell(5,4);
fieldsAndBounds(1,:)  = { 'sgPolyOrder'; '>= 2'; '<= 24'; []};
fieldsAndBounds(2,:)  = { 'sgFrameSize'; '>= 25'; '< 10000'; []};
fieldsAndBounds(3,:)  = { 'satSegThreshold'; '> 0'; '<= 1e6'; []};
fieldsAndBounds(4,:)  = { 'satSegExclusionZone'; '>= 1'; '<= 10000'; []};
fieldsAndBounds(5,:)  = { 'maxSaturationMagnitude'; '>= 6'; '<= 15'; []};

remove_field_and_test_for_failure(dvDataStruct.saturationSegmentConfigurationStruct, ...
    'dvDataStruct.saturationSegmentConfigurationStruct', dvDataStruct, ...
    'dvDataStruct', 'validate_dv_inputs', ...
    fieldsAndBounds, quickAndDirtyCheckFlag, suppressDisplayFlag);

clear fieldsAndBounds

%--------------------------------------------------------------------------
% Second level validation.
% Remove fields in dvDataStruct.tpsHarmonicsIdentificationConfigurationStruct and
% test validate_dv_inputs catches it.
%--------------------------------------------------------------------------
fieldsAndBounds = cell(8,4);
fieldsAndBounds(1,:)  = { 'medianWindowLengthForTimeSeriesSmoothing'; '>= 1'; []; []};   % FOR NOW
fieldsAndBounds(2,:)  = { 'medianWindowLengthForPeriodogramSmoothing'; '>= 1'; []; []};  % FOR NOW
fieldsAndBounds(3,:)  = { 'movingAverageWindowLength'; '>= 1'; []; []};                  % FOR NOW
fieldsAndBounds(4,:)  = { 'falseDetectionProbabilityForTimeSeries'; '> 0'; '< 1'; []};   % FOR NOW
fieldsAndBounds(5,:)  = { 'minHarmonicSeparationInBins'; '>= 1'; '<= 10000'; []};         % FOR NOW
fieldsAndBounds(6,:)  = { 'maxHarmonicComponents'; '>= 1'; '<= 10000'; []};              % FOR NOW
fieldsAndBounds(7,:)  = { 'retainFrequencyCombsEnabled'; [] ; [] ; [true,false]};
fieldsAndBounds(8,:)  = { 'timeOutInMinutes'; '> 0'; '<= 180'; []};                      % FOR NOW

remove_field_and_test_for_failure(dvDataStruct.tpsHarmonicsIdentificationConfigurationStruct, ...
    'dvDataStruct.tpsHarmonicsIdentificationConfigurationStruct', dvDataStruct, ...
    'dvDataStruct', 'validate_dv_inputs', ...
    fieldsAndBounds, quickAndDirtyCheckFlag, suppressDisplayFlag);

clear fieldsAndBounds

%--------------------------------------------------------------------------
% Second level validation.
% Remove fields in dvDataStruct.pdcHarmonicsIdentificationConfigurationStruct and
% test validate_dv_inputs catches it.
%--------------------------------------------------------------------------
fieldsAndBounds = cell(8,4);
fieldsAndBounds(1,:)  = { 'medianWindowLengthForTimeSeriesSmoothing'; '>= 1'; []; []};   % FOR NOW
fieldsAndBounds(2,:)  = { 'medianWindowLengthForPeriodogramSmoothing'; '>= 1'; []; []};  % FOR NOW
fieldsAndBounds(3,:)  = { 'movingAverageWindowLength'; '>= 1'; []; []};                  % FOR NOW
fieldsAndBounds(4,:)  = { 'falseDetectionProbabilityForTimeSeries'; '> 0'; '< 1'; []};   % FOR NOW
fieldsAndBounds(5,:)  = { 'minHarmonicSeparationInBins'; '>= 1'; '<= 1000'; []};         % FOR NOW
fieldsAndBounds(6,:)  = { 'maxHarmonicComponents'; '>= 1'; '<= 10000'; []};              % FOR NOW
fieldsAndBounds(7,:)  = { 'retainFrequencyCombsEnabled'; [] ; [] ; [true,false]};
fieldsAndBounds(8,:)  = { 'timeOutInMinutes'; '> 0'; '<= 180'; []};                      % FOR NOW

remove_field_and_test_for_failure(dvDataStruct.pdcHarmonicsIdentificationConfigurationStruct, ...
    'dvDataStruct.pdcHarmonicsIdentificationConfigurationStruct', dvDataStruct, ...
    'dvDataStruct', 'validate_dv_inputs', ...
    fieldsAndBounds, quickAndDirtyCheckFlag, suppressDisplayFlag);

clear fieldsAndBounds

%--------------------------------------------------------------------------
% Second level validation.
% Remove fields in dvDataStruct.tpsConfigurationStruct and test
% validate_dv_inputs catches it.
%--------------------------------------------------------------------------
fieldsAndBounds = get_tps_input_fields_and_bounds( 'tpsModuleParameters' );

if dvDataStruct.tpsConfigurationStruct.maximumSearchPeriodInDays == -1
    dvDataStruct.tpsConfigurationStruct.maximumSearchPeriodInDays = 1;
end

remove_field_and_test_for_failure(dvDataStruct.tpsConfigurationStruct, ...
    'dvDataStruct.tpsConfigurationStruct', dvDataStruct, 'dvDataStruct',  ...
    'validate_dv_inputs', ...
    fieldsAndBounds, quickAndDirtyCheckFlag, suppressDisplayFlag);

clear fieldsAndBounds

%--------------------------------------------------------------------------
% Second level validation.
% Remove fields in dvDataStruct.targetTableDataStruct() and test
% validate_dv_inputs catches it.
%--------------------------------------------------------------------------
fieldsAndBounds = cell(9,4);
fieldsAndBounds(1,:)  = { 'targetTableId'; '> 0'; '< 256'; []};
fieldsAndBounds(2,:)  = { 'quarter'; '>= 0'; '< 100'; []};
fieldsAndBounds(3,:)  = { 'ccdModule'; []; []; '[2:4, 6:20, 22:24]'''};
fieldsAndBounds(4,:)  = { 'ccdOutput'; []; []; '[1 2 3 4]'''};
fieldsAndBounds(5,:)  = { 'startCadence'; '>= 0'; '< 5e5'; []};
fieldsAndBounds(6,:)  = { 'endCadence'; '>= 0'; '< 5e5'; []};
fieldsAndBounds(7,:)  = { 'argabrighteningIndices'; []; []; []};            % Can't set bounds if vector may be empty
% fieldsAndBounds(8,:)  = { 'ancillaryPipelineDataStruct'; []; []; []};     % Can't test that this is missing; wrong error is thrown
fieldsAndBounds(8,:)  = { 'motionPolyStruct'; []; []; []};
fieldsAndBounds(9,:)  = { 'cbvBlobs'; []; []; []};

remove_field_and_test_for_failure(dvDataStruct.targetTableDataStruct, ...
    'dvDataStruct.targetTableDataStruct', dvDataStruct, 'dvDataStruct',  ...
    'validate_dv_inputs', ...
    fieldsAndBounds, quickAndDirtyCheckFlag, suppressDisplayFlag);

clear fieldsAndBounds

%--------------------------------------------------------------------------
% Second level validation.
% Remove fields in dvDataStruct.targetStruct() and test validate_dv_inputs
% catches it.
%--------------------------------------------------------------------------
fieldsAndBounds = cell(19,4);
fieldsAndBounds(1,:)  = { 'keplerId'; '> 0'; '< 1e9'; []};
fieldsAndBounds(2,:)  = { 'categories'; []; []; []};
fieldsAndBounds(3,:)  = { 'transits'; []; []; []};
fieldsAndBounds(4,:)  = { 'raHours'; []; []; []};
fieldsAndBounds(5,:)  = { 'decDegrees'; []; []; []};
fieldsAndBounds(6,:)  = { 'keplerMag'; []; []; []};
fieldsAndBounds(7,:)  = { 'radius'; []; []; []};
fieldsAndBounds(8,:)  = { 'effectiveTemp'; []; []; []};
fieldsAndBounds(9,:)  = { 'log10SurfaceGravity'; []; []; []};
fieldsAndBounds(10,:) = { 'log10Metallicity'; []; []; []};
fieldsAndBounds(11,:) = { 'rawFluxTimeSeries'; []; []; []};
fieldsAndBounds(12,:) = { 'correctedFluxTimeSeries'; []; []; []};
fieldsAndBounds(13,:) = { 'outliers'; []; []; []};
fieldsAndBounds(14,:) = { 'discontinuityIndices'; []; []; []};              % FOR NOW
fieldsAndBounds(15,:) = { 'centroids'; []; []; []};
fieldsAndBounds(16,:) = { 'targetDataStruct'; []; []; []};
fieldsAndBounds(17,:) = { 'thresholdCrossingEvent'; []; []; []};
fieldsAndBounds(18,:) = { 'rollingBandContamination'; []; []; []};
fieldsAndBounds(19,:) = { 'ukirtImageFileName'; []; []; []};

remove_field_and_test_for_failure(dvDataStruct.targetStruct, ...
    'dvDataStruct.targetStruct', dvDataStruct, 'dvDataStruct',  ...
    'validate_dv_inputs', ...
    fieldsAndBounds, quickAndDirtyCheckFlag, suppressDisplayFlag);

clear fieldsAndBounds

%--------------------------------------------------------------------------
% Third level validation.
% Remove fields in dvDataStruct.dvCadenceTimes.dataAnomalyFlags
% and test validate_dv_inputs catches it.
%--------------------------------------------------------------------------
fieldsAndBounds = cell(7,4);
fieldsAndBounds(1,:)  = { 'attitudeTweakIndicators'; []; []; [true, false]};
fieldsAndBounds(2,:)  = { 'safeModeIndicators'; []; []; [true, false]};
fieldsAndBounds(3,:)  = { 'earthPointIndicators'; []; []; [true, false]};
fieldsAndBounds(4,:)  = { 'coarsePointIndicators'; []; []; [true, false]};
fieldsAndBounds(5,:)  = { 'argabrighteningIndicators'; []; []; [true, false]};
fieldsAndBounds(6,:)  = { 'excludeIndicators'; []; []; [true, false]};
fieldsAndBounds(7,:)  = { 'planetSearchExcludeIndicators'; []; []; [true, false]};

remove_field_and_test_for_failure(dvDataStruct.dvCadenceTimes.dataAnomalyFlags, ...
    'dvDataStruct.dvCadenceTimes.dataAnomalyFlags', dvDataStruct, 'dvDataStruct',  ...
    'validate_dv_inputs', ...
    fieldsAndBounds, quickAndDirtyCheckFlag, suppressDisplayFlag);

clear fieldsAndBounds;

%--------------------------------------------------------------------------
% Third level validation.
% Remove fields in 
% dvDataStruct.targetTableDataStruct().ancillaryPipelineDataStruct, if not
% empty and test validate_dv_inputs catches it.
%--------------------------------------------------------------------------
fieldsAndBounds = cell(4,4);
fieldsAndBounds(1,:)  = { 'mnemonic'; []; []; {}};
fieldsAndBounds(2,:)  = { 'timestamps'; '> 54500'; '< 70000'; []};          % 2/4/2008 to 7/13/2050
fieldsAndBounds(3,:)  = { 'values'; []; []; []};                            % TBD
fieldsAndBounds(4,:)  = { 'uncertainties'; '>= 0'; []; []};                 % TBD

ancillaryPipelineDataStruct = ...
    dvDataStruct.targetTableDataStruct.ancillaryPipelineDataStruct;

if ~isempty(ancillaryPipelineDataStruct)

    remove_field_and_test_for_failure(ancillaryPipelineDataStruct, ...
        'dvDataStruct.targetTableDataStruct.ancillaryPipelineDataStruct', ...
        dvDataStruct, 'dvDataStruct', 'validate_dv_inputs', ...
        fieldsAndBounds,quickAndDirtyCheckFlag, suppressDisplayFlag);

end

clear fieldsAndBounds

%--------------------------------------------------------------------------
% Third level validation.
% Remove fields in
% dvDataStruct.targetTableDataStruct().motionPolyStruct and test
% validate_dv_inputs catches it.
%--------------------------------------------------------------------------
fieldsAndBounds = cell(10,4);
fieldsAndBounds(1,:)  = { 'cadence'; '>= 0'; '< 5e5'; []};
fieldsAndBounds(2,:)  = { 'mjdStartTime'; '> 54500'; '< 70000'; []};        % 2/4/2008 to 7/13/2050
fieldsAndBounds(3,:)  = { 'mjdMidTime'; '> 54500'; '< 70000'; []};          % 2/4/2008 to 7/13/2050
fieldsAndBounds(4,:)  = { 'mjdEndTime'; '> 54500'; '< 70000'; []};          % 2/4/2008 to 7/13/2050
fieldsAndBounds(5,:)  = { 'module'; []; []; '[2:4, 6:20, 22:24]'''};
fieldsAndBounds(6,:)  = { 'output'; []; []; '[1 2 3 4]'''};
fieldsAndBounds(7,:)  = { 'rowPoly'; []; []; []};
fieldsAndBounds(8,:)  = { 'rowPolyStatus'; []; []; '[0:1]'''};
fieldsAndBounds(9,:)  = { 'colPoly'; []; []; []};
fieldsAndBounds(10,:) = { 'colPolyStatus'; []; []; '[0:1]'''};

remove_field_and_test_for_failure(dvDataStruct.targetTableDataStruct.motionPolyStruct, ...
    'dvDataStruct.targetTableDataStruct.motionPolyStruct', ...
    dvDataStruct, 'dvDataStruct', 'validate_dv_inputs', ...
    fieldsAndBounds, quickAndDirtyCheckFlag, suppressDisplayFlag);

clear fieldsAndBounds

%--------------------------------------------------------------------------
% Third level validation.
% Remove fields in dvDataStruct.targetStruct().transits and test
% validate_dv_inputs catches it.
%--------------------------------------------------------------------------
fieldsAndBounds = cell(5,4);
fieldsAndBounds(1,:)  = { 'koiId'; []; []; []};
fieldsAndBounds(2,:)  = { 'keplerName'; []; []; []};
fieldsAndBounds(3,:)  = { 'duration'; '>= 0'; []; []};
fieldsAndBounds(4,:)  = { 'epoch'; '>= 0'; []; []};
fieldsAndBounds(5,:)  = { 'period'; '>= 0'; []; []};

if ~isempty(dvDataStruct.targetStruct.transits)
    remove_field_and_test_for_failure(dvDataStruct.targetStruct.transits, ...
        'dvDataStruct.targetStruct.transits',  dvDataStruct, 'dvDataStruct', ...
        'validate_dv_inputs', ...
        fieldsAndBounds, quickAndDirtyCheckFlag, suppressDisplayFlag);
end

clear fieldsAndBounds

%--------------------------------------------------------------------------
% Third level validation.
% Remove fields in dvDataStruct.targetStruct().raHours and test
% validate_dv_inputs catches it.
%--------------------------------------------------------------------------
fieldsAndBounds = cell(3,4);
fieldsAndBounds(1,:)  = { 'value'; '>= 0'; '< 24'; []'};
fieldsAndBounds(2,:)  = { 'uncertainty'; '>= 0'; []; []};
fieldsAndBounds(3,:)  = { 'provenance'; []; []; []};

remove_field_and_test_for_failure(dvDataStruct.targetStruct.raHours, ...
    'dvDataStruct.targetStruct.raHours',  dvDataStruct, 'dvDataStruct', ...
    'validate_dv_inputs', ...
    fieldsAndBounds, quickAndDirtyCheckFlag, suppressDisplayFlag);

clear fieldsAndBounds

%--------------------------------------------------------------------------
% Third level validation.
% Remove fields in dvDataStruct.targetStruct().decDegrees and test
% validate_dv_inputs catches it.
%--------------------------------------------------------------------------
fieldsAndBounds = cell(3,4);
fieldsAndBounds(1,:)  = { 'value'; '>= -90'; '<= 90'; []'};
fieldsAndBounds(2,:)  = { 'uncertainty'; '>= 0'; []; []};
fieldsAndBounds(3,:)  = { 'provenance'; []; []; []};

remove_field_and_test_for_failure(dvDataStruct.targetStruct.decDegrees, ...
    'dvDataStruct.targetStruct.decDegrees',  dvDataStruct, 'dvDataStruct', ...
    'validate_dv_inputs', ...
    fieldsAndBounds, quickAndDirtyCheckFlag, suppressDisplayFlag);

clear fieldsAndBounds

%--------------------------------------------------------------------------
% Third level validation.
% Remove fields in dvDataStruct.targetStruct().keplerMag and test
% validate_dv_inputs catches it.
%--------------------------------------------------------------------------
fieldsAndBounds = cell(3,4);
fieldsAndBounds(1,:)  = { 'value'; '>= 0'; '< 30'; []'};
fieldsAndBounds(2,:)  = { 'uncertainty'; '>= 0'; []; []};
fieldsAndBounds(3,:)  = { 'provenance'; []; []; []};

remove_field_and_test_for_failure(dvDataStruct.targetStruct.keplerMag, ...
    'dvDataStruct.targetStruct.keplerMag',  dvDataStruct, 'dvDataStruct', ...
    'validate_dv_inputs', ...
    fieldsAndBounds, quickAndDirtyCheckFlag, suppressDisplayFlag);

clear fieldsAndBounds

%--------------------------------------------------------------------------
% Third level validation.
% Remove fields in dvDataStruct.targetStruct().radius and test
% validate_dv_inputs catches it.
%--------------------------------------------------------------------------
fieldsAndBounds = cell(3,4);
fieldsAndBounds(1,:)  = { 'value'; '> 0'; []; []};
fieldsAndBounds(2,:)  = { 'uncertainty'; '>= 0'; []; []};
fieldsAndBounds(3,:)  = { 'provenance'; []; []; []};

remove_field_and_test_for_failure(dvDataStruct.targetStruct.radius, ...
    'dvDataStruct.targetStruct.radius',  dvDataStruct, 'dvDataStruct', ...
    'validate_dv_inputs', ...
    fieldsAndBounds, quickAndDirtyCheckFlag, suppressDisplayFlag);

clear fieldsAndBounds

%--------------------------------------------------------------------------
% Third level validation.
% Remove fields in dvDataStruct.targetStruct().effectiveTemp and test
% validate_dv_inputs catches it.
%--------------------------------------------------------------------------
fieldsAndBounds = cell(3,4);
fieldsAndBounds(1,:)  = { 'value'; '> 0'; []; []};
fieldsAndBounds(2,:)  = { 'uncertainty'; '>= 0'; []; []};
fieldsAndBounds(3,:)  = { 'provenance'; []; []; []};

remove_field_and_test_for_failure(dvDataStruct.targetStruct.effectiveTemp, ...
    'dvDataStruct.targetStruct.effectiveTemp',  dvDataStruct, ...
    'dvDataStruct', 'validate_dv_inputs', ...
    fieldsAndBounds, quickAndDirtyCheckFlag, suppressDisplayFlag);

clear fieldsAndBounds

%--------------------------------------------------------------------------
% Third level validation.
% Remove fields in dvDataStruct.targetStruct().log10SurfaceGravity and test
% validate_dv_inputs catches it.
%--------------------------------------------------------------------------
fieldsAndBounds = cell(3,4);
fieldsAndBounds(1,:)  = { 'value'; '> -0.45'; []; []};
fieldsAndBounds(2,:)  = { 'uncertainty'; '>= 0'; []; []};
fieldsAndBounds(3,:)  = { 'provenance'; []; []; []};

remove_field_and_test_for_failure(dvDataStruct.targetStruct.log10SurfaceGravity, ...
    'dvDataStruct.targetStruct.log10SurfaceGravity',  dvDataStruct, ...
    'dvDataStruct', 'validate_dv_inputs', ...
    fieldsAndBounds, quickAndDirtyCheckFlag, suppressDisplayFlag);

clear fieldsAndBounds

%--------------------------------------------------------------------------
% Third level validation.
% Remove fields in dvDataStruct.targetStruct().log10Metallicity and test
% validate_dv_inputs catches it.
%--------------------------------------------------------------------------
fieldsAndBounds = cell(3,4);
fieldsAndBounds(1,:)  = { 'value'; '>= -25'; '<= 5'; []};
fieldsAndBounds(2,:)  = { 'uncertainty'; '>= 0'; []; []};
fieldsAndBounds(3,:)  = { 'provenance'; []; []; []}; 

remove_field_and_test_for_failure(dvDataStruct.targetStruct.log10Metallicity, ...
    'dvDataStruct.targetStruct.log10Metallicity',  dvDataStruct, ...
    'dvDataStruct', 'validate_dv_inputs', ...
    fieldsAndBounds, quickAndDirtyCheckFlag, suppressDisplayFlag);

clear fieldsAndBounds

%--------------------------------------------------------------------------
% Third level validation.
% Remove fields in dvDataStruct.targetStruct().rawFluxTimeSeries and
% test validate_dv_inputs catches it.
%--------------------------------------------------------------------------
fieldsAndBounds = cell(3,4);
fieldsAndBounds(1,:)  = { 'values'; []; []; []};                            % TBD
fieldsAndBounds(2,:)  = { 'uncertainties'; '>= 0'; []; []};                 % TBD
fieldsAndBounds(3,:)  = { 'gapIndicators'; []; []; [true; false]};

remove_field_and_test_for_failure(dvDataStruct.targetStruct.rawFluxTimeSeries, ...
    'dvDataStruct.targetStruct.rawFluxTimeSeries',  ...
    dvDataStruct, 'dvDataStruct', 'validate_dv_inputs', ...
    fieldsAndBounds, quickAndDirtyCheckFlag, suppressDisplayFlag);

clear fieldsAndBounds

%--------------------------------------------------------------------------
% Third level validation.
% Remove fields in dvDataStruct.targetStruct().correctedFluxTimeSeries and
% test validate_dv_inputs catches it.
%--------------------------------------------------------------------------
% fieldsAndBounds = cell(4,4);
% fieldsAndBounds(1,:)  = { 'values'; []; []; []};                            % TBD
% fieldsAndBounds(2,:)  = { 'uncertainties'; '>= -1'; []; []};                % Uncertainty = -1 for long gap filled values
% fieldsAndBounds(3,:)  = { 'gapIndicators'; []; []; [true; false]};
% fieldsAndBounds(4,:)  = { 'filledIndices'; []; []; []};                     % Can't set bounds if vector may be empty
% 
% remove_field_and_test_for_failure(dvDataStruct.targetStruct.correctedFluxTimeSeries, ...
%     'dvDataStruct.targetStruct.correctedFluxTimeSeries',  ...
%     dvDataStruct, 'dvDataStruct', 'validate_dv_inputs', ...
%     fieldsAndBounds, quickAndDirtyCheckFlag, suppressDisplayFlag);
% 
% clear fieldsAndBounds

%--------------------------------------------------------------------------
% Third level validation.
% Remove fields in dvDataStruct.targetStruct().outliers and test
% validate_dv_inputs catches it.
%--------------------------------------------------------------------------
fieldsAndBounds = cell(3,4);
fieldsAndBounds(1,:)  = { 'values'; []; []; []};                            % Can't set bounds if vector may be empty
fieldsAndBounds(2,:)  = { 'uncertainties'; []; []; []};                     % Can't set bounds if vector may be empty
fieldsAndBounds(3,:)  = { 'indices'; []; []; []};                           % Can't set bounds if vector may be empty

remove_field_and_test_for_failure(dvDataStruct.targetStruct.outliers, ...
    'dvDataStruct.targetStruct.outliers',  dvDataStruct, 'dvDataStruct', ...
    'validate_dv_inputs', ...
    fieldsAndBounds, quickAndDirtyCheckFlag, suppressDisplayFlag);

clear fieldsAndBounds

%--------------------------------------------------------------------------
% Third level validation.
% Remove missing fields in dvDataStruct.targetStruct().centroids and test
% validate_dv_inputs catches it.
%--------------------------------------------------------------------------
fieldsAndBounds = cell(2,4);
fieldsAndBounds(1,:)  = { 'prfCentroids'; []; []; []};
fieldsAndBounds(2,:)  = { 'fluxWeightedCentroids'; []; []; []};

remove_field_and_test_for_failure(dvDataStruct.targetStruct.centroids, ...
    'dvDataStruct.targetStruct.centroids',  dvDataStruct, 'dvDataStruct', ...
    'validate_dv_inputs', ...
    fieldsAndBounds, quickAndDirtyCheckFlag, suppressDisplayFlag);

clear fieldsAndBounds

%--------------------------------------------------------------------------
% Third level validation.
% Remove fields in dvDataStruct.targetStruct().targetDataStruct() and test
% validate_dv_inputs catches it.
%--------------------------------------------------------------------------
fieldsAndBounds = cell(10,4);
fieldsAndBounds(1,:)  = { 'targetTableId'; '> 0'; '< 256'; []};
fieldsAndBounds(2,:)  = { 'quarter'; '>= 0'; '< 100'; []};
fieldsAndBounds(3,:)  = { 'ccdModule'; []; []; '[2:4, 6:20, 22:24]'''};
fieldsAndBounds(4,:)  = { 'ccdOutput'; []; []; '[1 2 3 4]'''};
fieldsAndBounds(5,:)  = { 'startCadence'; '>= 0'; '< 5e5'; []};
fieldsAndBounds(6,:)  = { 'endCadence'; '>= 0'; '< 5e5'; []};
fieldsAndBounds(7,:)  = { 'labels'; []; []; {}};
fieldsAndBounds(8,:)  = { 'fluxFractionInAperture'; '>= 0'; '<= 1'; []};
fieldsAndBounds(9,:)  = { 'crowdingMetric'; '>= 0'; '<= 1'; []};
fieldsAndBounds(10,:) = { 'pixelDataFileName'; []; []; []};

remove_field_and_test_for_failure(dvDataStruct.targetStruct.targetDataStruct, ...
    'dvDataStruct.targetStruct.targetDataStruct',  dvDataStruct, ...
    'dvDataStruct', 'validate_dv_inputs', ...
    fieldsAndBounds, quickAndDirtyCheckFlag, suppressDisplayFlag);

clear fieldsAndBounds

%--------------------------------------------------------------------------
% Third level validation.
% Remove fields in dvDataStruct.targetStruct().thresholdCrossingEvent and
% test validate_dv_inputs catches it.
%--------------------------------------------------------------------------
fieldsAndBounds = cell(17,4);
fieldsAndBounds(1,:)  = { 'keplerId'; '> 0'; '< 1e9'; []};
fieldsAndBounds(2,:)  = { 'trialTransitPulseDuration'; '> 0'; '<= 72'; []};
fieldsAndBounds(3,:)  = { 'epochMjd'; '> 54500'; '< 70000'; []};            % 2/4/2008 to 7/13/2050
fieldsAndBounds(4,:)  = { 'orbitalPeriod'; '>= 0'; '< 2000'; []};
fieldsAndBounds(5,:)  = { 'maxSingleEventSigma'; '> 0'; []; []};
fieldsAndBounds(6,:)  = { 'maxMultipleEventSigma'; '> 0'; []; []};
fieldsAndBounds(7,:)  = { 'maxSesInMes'; '> 0'; []; []};
fieldsAndBounds(8,:)  = { 'robustStatistic'; '>= -1'; []; []};
fieldsAndBounds(9,:)  = { 'chiSquare1'; '>= -1'; []; []};                   % TBD
fieldsAndBounds(10,:) = { 'chiSquareDof1'; '>= -1'; []; []};                % TBD
fieldsAndBounds(11,:) = { 'chiSquare2'; '>= -1'; []; []};                   % TBD
fieldsAndBounds(12,:) = { 'chiSquareDof2'; '>= -1'; []; []};                % TBD
fieldsAndBounds(13,:) = { 'chiSquareGof'; '>= -1'; []; []};                 % TBD
fieldsAndBounds(14,:) = { 'chiSquareGofDof'; '>= -1'; []; []};              % TBD
fieldsAndBounds(15,:) = { 'weakSecondaryStruct'; []; []; []};
fieldsAndBounds(16,:) = { 'deemphasizedNormalizationTimeSeries'; []; []; []};  % Can't set bounds if vector may be empty
fieldsAndBounds(17,:) = { 'thresholdForDesiredPfa'; '>= -1'; []; []};

remove_field_and_test_for_failure(dvDataStruct.targetStruct.thresholdCrossingEvent, ...
    'dvDataStruct.targetStruct.thresholdCrossingEvent', ...
    dvDataStruct, 'dvDataStruct', 'validate_dv_inputs', ...
    fieldsAndBounds, quickAndDirtyCheckFlag, suppressDisplayFlag);

clear fieldsAndBounds

%--------------------------------------------------------------------------
% Third level validation.
% Remove fields in dvDataStruct.targetStruct().rollingBandContamination and
% test validate_dv_inputs catches it.
%--------------------------------------------------------------------------
fieldsAndBounds = cell(2,4);
fieldsAndBounds(1,:)  = { 'optimalAperture'; []; []; []};
fieldsAndBounds(2,:)  = { 'fullAperture'; []; []; []};

remove_field_and_test_for_failure(dvDataStruct.targetStruct.rollingBandContamination, ...
    'dvDataStruct.targetStruct.rollingBandContamination',  dvDataStruct, ...
    'dvDataStruct', 'validate_dv_inputs', ...
    fieldsAndBounds, quickAndDirtyCheckFlag, suppressDisplayFlag);

clear fieldsAndBounds

%--------------------------------------------------------------------------
% Fourth level validation.
% Remove fields in
% dvDataStruct.targetTableDataStruct().motionPolyStruct().rowPoly and test
% validate_dv_inputs catches it.
%--------------------------------------------------------------------------
fieldsAndBounds = cell(13,4);
fieldsAndBounds(1,:)  = { 'offsetx'; []; []; '0'};
fieldsAndBounds(2,:)  = { 'scalex'; '>= 0'; []; []};
fieldsAndBounds(3,:)  = { 'originx'; []; []; []};
fieldsAndBounds(4,:)  = { 'offsety'; []; []; '0'};
fieldsAndBounds(5,:)  = { 'scaley'; '>= 0'; []; []};
fieldsAndBounds(6,:)  = { 'originy'; []; []; []};
fieldsAndBounds(7,:)  = { 'xindex'; []; []; '-1'};
fieldsAndBounds(8,:)  = { 'yindex'; []; []; '-1'};
fieldsAndBounds(9,:)  = { 'type'; []; []; {'standard'}};
fieldsAndBounds(10,:) = { 'order'; '>= 0'; '< 10'; []};
fieldsAndBounds(11,:) = { 'message'; []; []; {}};
fieldsAndBounds(12,:) = { 'coeffs'; []; []; []};                            % TBD
fieldsAndBounds(13,:) = { 'covariance'; []; []; []};                        % TBD

% Must use (1) or matlab complains about too many args
remove_field_and_test_for_failure(dvDataStruct.targetTableDataStruct.motionPolyStruct(1).rowPoly, ...
    'dvDataStruct.targetTableDataStruct.motionPolyStruct(1).rowPoly',...
    dvDataStruct, 'dvDataStruct', 'validate_dv_inputs', ...
    fieldsAndBounds, quickAndDirtyCheckFlag, suppressDisplayFlag);

clear fieldsAndBounds

%--------------------------------------------------------------------------
% Fourth level validation.
% Remove fields in
% dvDataStruct.targetTableDataStruct().motionPolyStruct().colPoly and test
% validate_dv_inputs catches it.
%--------------------------------------------------------------------------
fieldsAndBounds = cell(13,4);
fieldsAndBounds(1,:)  = { 'offsetx'; []; []; '0'};
fieldsAndBounds(2,:)  = { 'scalex'; '>= 0'; []; []};
fieldsAndBounds(3,:)  = { 'originx'; []; []; []};
fieldsAndBounds(4,:)  = { 'offsety'; []; []; '0'};
fieldsAndBounds(5,:)  = { 'scaley'; '>= 0'; []; []};
fieldsAndBounds(6,:)  = { 'originy'; []; []; []};
fieldsAndBounds(7,:)  = { 'xindex'; []; []; '-1'};
fieldsAndBounds(8,:)  = { 'yindex'; []; []; '-1'};
fieldsAndBounds(9,:)  = { 'type'; []; []; {'standard'}};
fieldsAndBounds(10,:) = { 'order'; '>= 0'; '< 10'; []};
fieldsAndBounds(11,:) = { 'message'; []; []; {}};
fieldsAndBounds(12,:) = { 'coeffs'; []; []; []};                            % TBD
fieldsAndBounds(13,:) = { 'covariance'; []; []; []};                        % TBD

% Must use (1) or matlab complains about too many args
remove_field_and_test_for_failure(dvDataStruct.targetTableDataStruct.motionPolyStruct(1).colPoly, ...
    'dvDataStruct.targetTableDataStruct.motionPolyStruct(1).colPoly', ...
    dvDataStruct, 'dvDataStruct', 'validate_dv_inputs', ...
    fieldsAndBounds, quickAndDirtyCheckFlag, suppressDisplayFlag);

clear fieldsAndBounds

%--------------------------------------------------------------------------
% Fourth level validation.
% Remove fields in
% dvDataStruct.targetStruct().centroids.prfCentroids and test
% validate_dv_inputs catches it.
%--------------------------------------------------------------------------
fieldsAndBounds = cell(2,4);
fieldsAndBounds(1,:)  = { 'rowTimeSeries'; []; []; []};
fieldsAndBounds(2,:)  = { 'columnTimeSeries'; []; []; []};

remove_field_and_test_for_failure(dvDataStruct.targetStruct.centroids.prfCentroids, ...
    'dvDataStruct.targetStruct.centroids.prfCentroids',  dvDataStruct, ...
    'dvDataStruct', 'validate_dv_inputs', ...
    fieldsAndBounds, quickAndDirtyCheckFlag, suppressDisplayFlag);

clear fieldsAndBounds

%--------------------------------------------------------------------------
% Fourth level validation.
% Remove fields in 
% dvDataStruct.targetStruct().centroids.fluxWeightedCentroids and test
% validate_dv_inputs catches it.
%--------------------------------------------------------------------------
fieldsAndBounds = cell(2,4);
fieldsAndBounds(1,:)  = { 'rowTimeSeries'; []; []; []};
fieldsAndBounds(2,:)  = { 'columnTimeSeries'; []; []; []};

remove_field_and_test_for_failure(dvDataStruct.targetStruct.centroids.fluxWeightedCentroids, ...
    'dvDataStruct.targetStruct.centroids.fluxWeightedCentroids',  ...
    dvDataStruct, 'dvDataStruct', 'validate_dv_inputs', ...
    fieldsAndBounds, quickAndDirtyCheckFlag, suppressDisplayFlag);

clear fieldsAndBounds

%--------------------------------------------------------------------------
% Fourth level validation.
% Remove fields in
% dvDataStruct.targetStruct().thresholdCrossingEvent.weakSecondaryStruct
% and test validate_dv_inputs catches it.
%--------------------------------------------------------------------------
fieldsAndBounds = cell(11,4);
fieldsAndBounds(1,:)  = { 'phaseInDays'; []; []; []};
fieldsAndBounds(2,:)  = { 'mes'; []; []; []};
fieldsAndBounds(3,:)  = { 'maxMesPhaseInDays'; []; []; []};
fieldsAndBounds(4,:)  = { 'maxMes'; []; []; []};
fieldsAndBounds(5,:)  = { 'minMesPhaseInDays'; []; []; []};
fieldsAndBounds(6,:)  = { 'minMes'; []; []; []};
fieldsAndBounds(7,:)  = { 'medianMes'; []; []; []};
fieldsAndBounds(8,:)  = { 'mesMad'; '>= -1'; []; []};
fieldsAndBounds(9,:)  = { 'nValidPhases'; '>= -1'; []; []};
fieldsAndBounds(10,:) = { 'robustStatistic'; []; []; []};
fieldsAndBounds(11,:) = { 'depthPpm'; []; []; []};

remove_field_and_test_for_failure(dvDataStruct.targetStruct.thresholdCrossingEvent.weakSecondaryStruct, ...
    'dvDataStruct.targetStruct.thresholdCrossingEvent.weakSecondaryStruct',  ...
    dvDataStruct, 'dvDataStruct', 'validate_dv_inputs', ...
    fieldsAndBounds, quickAndDirtyCheckFlag, suppressDisplayFlag);

clear fieldsAndBounds

%--------------------------------------------------------------------------
% Fourth level validation.
% Remove fields in
% dvDataStruct.targetStruct().rollingBandContamination.optimalAperture and
% test validate_dv_inputs catches it.
%--------------------------------------------------------------------------
fieldsAndBounds = cell(2,4);
fieldsAndBounds(1,:)  = { 'values'; '>= 0'; '<= 4'; []};
fieldsAndBounds(2,:)  = { 'gapIndicators'; []; []; [true; false]};

remove_field_and_test_for_failure(dvDataStruct.targetStruct.rollingBandContamination.optimalAperture, ...
    'dvDataStruct.targetStruct.rollingBandContamination.optimalAperture', ...
    dvDataStruct, 'dvDataStruct', 'validate_dv_inputs', ...
    fieldsAndBounds, quickAndDirtyCheckFlag, suppressDisplayFlag);

clear fieldsAndBounds

%--------------------------------------------------------------------------
% Fourth level validation.
% Remove fields in
% dvDataStruct.targetStruct().rollingBandContamination.fullAperture and
% test validate_dv_inputs catches it.
%--------------------------------------------------------------------------
fieldsAndBounds = cell(2,4);
fieldsAndBounds(1,:)  = { 'values'; '>= 0'; '<= 4'; []};
fieldsAndBounds(2,:)  = { 'gapIndicators'; []; []; [true; false]};

remove_field_and_test_for_failure(dvDataStruct.targetStruct.rollingBandContamination.fullAperture, ...
    'dvDataStruct.targetStruct.rollingBandContamination.fullAperture', ...
    dvDataStruct, 'dvDataStruct', 'validate_dv_inputs', ...
    fieldsAndBounds, quickAndDirtyCheckFlag, suppressDisplayFlag);

clear fieldsAndBounds

%--------------------------------------------------------------------------
% Fifth level validation.
% Remove fields in
% dvDataStruct.targetStruct().centroids.prfCentroids.rowTimeSeries and test
% validate_dv_inputs catches it.
%--------------------------------------------------------------------------
fieldsAndBounds = cell(3,4);
fieldsAndBounds(1,:)  = { 'values'; '>= 0'; '< 1070'; []};
fieldsAndBounds(2,:)  = { 'uncertainties'; '>= 0'; []; []};
fieldsAndBounds(3,:)  = { 'gapIndicators'; []; []; [true; false]};

remove_field_and_test_for_failure(dvDataStruct.targetStruct.centroids.prfCentroids.rowTimeSeries, ...
    'dvDataStruct.targetStruct.centroids.prfCentroids.rowTimeSeries', ...
    dvDataStruct, 'dvDataStruct', 'validate_dv_inputs', ...
    fieldsAndBounds, quickAndDirtyCheckFlag, suppressDisplayFlag);

clear fieldsAndBounds

%--------------------------------------------------------------------------
% Fifth level validation.
% Remove fields in
% dvDataStruct.targetStruct().centroids.prfCentroids.columnTimeSeries and
% test validate_dv_inputs catches it.
%--------------------------------------------------------------------------
fieldsAndBounds = cell(3,4);
fieldsAndBounds(1,:)  = { 'values'; '>= 0'; '< 1132'; []};
fieldsAndBounds(2,:)  = { 'uncertainties'; '>= 0'; []; []};
fieldsAndBounds(3,:)  = { 'gapIndicators'; []; []; [true; false]};

remove_field_and_test_for_failure(dvDataStruct.targetStruct.centroids.prfCentroids.columnTimeSeries, ...
    'dvDataStruct.targetStruct.centroids.prfCentroids.columnTimeSeries', ...
    dvDataStruct, 'dvDataStruct', 'validate_dv_inputs', ...
    fieldsAndBounds, quickAndDirtyCheckFlag, suppressDisplayFlag);

clear fieldsAndBounds

%--------------------------------------------------------------------------
% Fifth level validation.
% Remove fields in
% dvDataStruct.targetStruct().centroids.fluxWeightedCentroids.rowTimeSeries
% and test validate_dv_inputs catches it.
%--------------------------------------------------------------------------
fieldsAndBounds = cell(3,4);
fieldsAndBounds(1,:)  = { 'values'; '>= 0'; '< 1070'; []};
fieldsAndBounds(2,:)  = { 'uncertainties'; '>= 0'; []; []};
fieldsAndBounds(3,:)  = { 'gapIndicators'; []; []; [true; false]};

remove_field_and_test_for_failure(dvDataStruct.targetStruct.centroids.fluxWeightedCentroids.rowTimeSeries, ...
    'dvDataStruct.targetStruct.centroids.fluxWeightedCentroids.rowTimeSeries',  ...
    dvDataStruct, 'dvDataStruct', 'validate_dv_inputs', ...
    fieldsAndBounds, quickAndDirtyCheckFlag, suppressDisplayFlag);

clear fieldsAndBounds

%--------------------------------------------------------------------------
% Fifth level validation.
% Remove fields in
% dvDataStruct.targetStruct().centroids.fluxWeightedCentroids.columnTimeSeries
% and test validate_dv_inputs catches it.
%--------------------------------------------------------------------------
fieldsAndBounds = cell(3,4);
fieldsAndBounds(1,:)  = { 'values'; '>= 0'; '< 1070'; []};
fieldsAndBounds(2,:)  = { 'uncertainties'; '>= 0'; []; []};
fieldsAndBounds(3,:)  = { 'gapIndicators'; []; []; [true; false]};

remove_field_and_test_for_failure(dvDataStruct.targetStruct.centroids.fluxWeightedCentroids.columnTimeSeries, ...
    'dvDataStruct.targetStruct.centroids.fluxWeightedCentroids.columnTimeSeries', ...
    dvDataStruct, 'dvDataStruct', 'validate_dv_inputs', ...
    fieldsAndBounds, quickAndDirtyCheckFlag, suppressDisplayFlag);

clear fieldsAndBounds

%--------------------------------------------------------------------------
% Fifth level validation.
% Remove fields in
% dvDataStruct.targetStruct().thresholdCrossingEvent().weakSecondaryStruct.depthPpm
% and test validate_dv_inputs catches it.
%--------------------------------------------------------------------------
fieldsAndBounds = cell(2,4);
fieldsAndBounds(1,:)  = { 'value'; []; []; []};
fieldsAndBounds(2,:)  = { 'uncertainty'; '>= -1'; []; []};

remove_field_and_test_for_failure(dvDataStruct.targetStruct.thresholdCrossingEvent.weakSecondaryStruct.depthPpm, ...
    'dvDataStruct.targetStruct.thresholdCrossingEvent.weakSecondaryStruct.depthPpm', ...
    dvDataStruct, 'dvDataStruct', 'validate_dv_inputs', ...
    fieldsAndBounds, quickAndDirtyCheckFlag, suppressDisplayFlag);

clear fieldsAndBounds

%--------------------------------------------------------------------------

pixelDataDirName = 'pixelData';
rmdir(pixelDataDirName, 's');

t = toc;
fprintf('\n test_validate_missing_inputs took %d seconds to complete\n', t)
rmpath(path);

% Return.
return
