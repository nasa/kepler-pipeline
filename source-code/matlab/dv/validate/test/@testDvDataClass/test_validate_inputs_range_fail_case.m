function [self] = test_validate_inputs_range_fail_case(self)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [self] = test_validate_inputs_range_fail_case(self)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% This test checks whether the class constructor catches the out of bounds value
% and throws an error. This test calls assign_illegal_value_and_test_for_failure,
% which checks for NaNs, Infs, violation of lower bound, violation of upper bound,
% or violation of list membership.
%
%
%  Example
%  =======
%  Use a test runner to run the test method:
%      run(text_test_runner, testDvDataClass('test_validate_inputs_range_fail_case'));
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

% Define variables, path and file names
tic;
fprintf('\nTesting validate_dv_inputs against out of range values...\n')

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
load(fullMatFileName, 'dvDataStruct')

% Update spiceFileDirectory
dvDataStruct.raDec2PixModel.spiceFileDir = fullfile(socTestDataRoot, 'fc', 'spice');

% Update inputs, needed before class can be instantiated
dvDataStruct = update_dv_inputs(dvDataStruct);

%--------------------------------------------------------------------------
% Top level validation.
% Assign invalid fields and check for failures in dvDataStruct.
%
% If fields are structures, they are not validated at this level, but at
% the level in which they are not structures
%--------------------------------------------------------------------------

fieldsAndBounds = cell(2,4);
fieldsAndBounds(1,:)  = { 'skyGroupId';  '>= 1'; '<= 84'; []};
% fieldsAndBounds(2,:)  = { 'fcConstants'; []; []; []};                       % Validate only needed fields
% fieldsAndBounds(3,:)  = { 'configMaps'; []; []; []};                        % Do not validate
% fieldsAndBounds(4,:)  = { 'raDec2PixModel'; []; []; []};                    % Do not validate
% fieldsAndBounds(5,:)  = { 'prfModels'; []; []; []};                         % Do not validate
% fieldsAndBounds(6,:)  = { 'dvCadenceTimes'; []; []; []};
% fieldsAndBounds(7,:)  = { 'dvConfigurationStruct'; []; []; []};
% fieldsAndBounds(8,:)  = { 'fluxTypeConfigurationStruct'; []; []; []};
% fieldsAndBounds(9,:)  = { 'planetFitConfigurationStruct'; []; []; []};
% fieldsAndBounds(10,:) = { 'trapezoidalFitConfigurationStruct'; []; []; []};
% fieldsAndBounds(11,:) = { 'centroidTestConfigurationStruct'; []; []; []};
% fieldsAndBounds(12,:) = { 'pixelCorrelationConfigurationStruct'; []; []; []};
% fieldsAndBounds(13,:) = { 'differenceImageConfigurationStruct'; []; []; []};
% fieldsAndBounds(14,:) = { 'bootstrapConfigurationStruct'; []; []; []};
% fieldsAndBounds(15,:) = { 'ancillaryEngineeringConfigurationStruct'; []; []; []};
% fieldsAndBounds(16,:) = { 'ancillaryPipelineConfigurationStruct'; []; []; []};
% fieldsAndBounds(17,:) = { 'ancillaryDesignMatrixConfigurationStruct'; []; []; []};
% fieldsAndBounds(18,:) = { 'gapFillConfigurationStruct'; []; []; []};
% fieldsAndBounds(19,:) = { 'pdcConfigurationStruct'; []; []; []};
% fieldsAndBounds(20,:) = { 'saturationSegmentConfigurationStruct'; []; []; []};
% fieldsAndBounds(21,:) = { 'tpsHarmonicsIdentificationConfigurationStruct'; []; []; []};
% fieldsAndBounds(22,:) = { 'pdcHarmonicsIdentificationConfigurationStruct'; []; []; []};
% fieldsAndBounds(23,:) = { 'tpsConfigurationStruct'; []; []; []};
% fieldsAndBounds(24,:) = { 'ancillaryEngineeringDataFileName'; []; []; []};
% fieldsAndBounds(25,:) = { 'targetTableDataStruct'; []; []; []};
% fieldsAndBounds(26,:) = { 'targetStruct'; []; []; []};
% fieldsAndBounds(27,:) = { 'kics'; []; []; []};
% fieldsAndBounds(28,:) = { 'softwareRevision'; []; []; []};
% fieldsAndBounds(29,:) = { 'priorInstanceId'; []; []; []};
% fieldsAndBounds(30,:) = { 'transitParameterModelDescription'; []; []; []};
% fieldsAndBounds(31,:) = { 'transitNameModelDescription'; []; []; []};
% fieldsAndBounds(32,:) = { 'externalTceModelDescription'; []; []; []};
% fieldsAndBounds(33,:) = { 'transitInjectionParametersFileName'; []; []; []};
fieldsAndBounds(2,:)  = { 'taskTimeoutSecs'; '> 0'; []; []};

assign_illegal_value_and_test_for_failure(dvDataStruct, 'dvDataStruct', dvDataStruct, ...
    'dvDataStruct', 'validate_dv_inputs', ...
    fieldsAndBounds, quickAndDirtyCheckFlag, suppressDisplayFlag);

clear fieldsAndBounds

%--------------------------------------------------------------------------
% Second level validation.
% Assign invalid fields to dvDataStruct.dvCadenceTimes and test
% validate_dv_inputs
%--------------------------------------------------------------------------

fieldsAndBounds = cell(17,4);
fieldsAndBounds(1,:)  = { 'startTimestamps'; '> 54500'; '< 70000'; []};    
fieldsAndBounds(2,:)  = { 'midTimestamps'; '> 54500'; '< 70000'; []};      
fieldsAndBounds(3,:)  = { 'endTimestamps'; '> 54500'; '< 70000'; []};      
fieldsAndBounds(4,:)  = { 'gapIndicators'; []; []; [true; false]};         
fieldsAndBounds(5,:)  = { 'requantEnabled'; []; []; [true; false]};
fieldsAndBounds(6,:)  = { 'cadenceNumbers'; '>= 0'; '< 5e5'; []};
fieldsAndBounds(7,:)  = { 'quarters'; '>= 0'; '< 100'; []};                 
fieldsAndBounds(8,:)  = { 'lcTargetTableIds'; '> 0'; '< 256'; []};
% fieldsAndBounds(9,:)  = { 'scTargetTableIds'; []; []; []};
fieldsAndBounds(9,:)  = { 'isSefiAcc'; []; []; [true; false]};
fieldsAndBounds(10,:) = { 'isSefiCad'; []; []; [true; false]};
fieldsAndBounds(11,:) = { 'isLdeOos'; []; []; [true; false]};
fieldsAndBounds(12,:) = { 'isFinePnt'; []; []; [true; false]};
fieldsAndBounds(13,:) = { 'isMmntmDmp'; []; []; [true; false]};
fieldsAndBounds(14,:) = { 'isLdeParEr'; []; []; [true; false]};
fieldsAndBounds(15,:) = { 'isScrcErr'; []; []; [true; false]};
% fieldsAndBounds(16,:) = { 'dataAnomalyFlags'; []; []; []};
fieldsAndBounds(16,:) = { 'originalQuarters'; '>= 0'; '< 100'; []};
fieldsAndBounds(17,:) = { 'originalLcTargetTableIds'; '> 0'; '< 256'; []};

assign_illegal_value_and_test_for_failure(dvDataStruct.dvCadenceTimes, ...
    'dvDataStruct.dvCadenceTimes', dvDataStruct, 'dvDataStruct',  ...
     'validate_dv_inputs', ...
     fieldsAndBounds, quickAndDirtyCheckFlag, suppressDisplayFlag);

clear fieldsAndBounds

%--------------------------------------------------------------------------
% Second level validation.
% Assign invalid fields to dvDataStruct.dvConfigurationStruct and test
% validate_dv_inputs
%--------------------------------------------------------------------------
fieldsAndBounds = cell(19,4);
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
fieldsAndBounds(17,:) = { 'transitModelName'; []; []; {'mandel-agol_transit_model'; 'mandel-agol_geometric_transit_model'}};   % FOR NOW
fieldsAndBounds(18,:) = { 'limbDarkeningModelName'; []; []; {'claret_nonlinear_limb_darkening_model'; ...
                                                             'kepler_nonlinear_limb_darkening_model'; ...
                                                             'claret_nonlinear_limb_darkening_model_2011'}};   % FOR NOW
fieldsAndBounds(19,:) = { 'maxCandidatesPerTarget'; '>= 1'; '<= 25'; []};
% fieldsAndBounds(20,:) = { 'team'; []; []; []};

assign_illegal_value_and_test_for_failure(dvDataStruct.dvConfigurationStruct, ...
    'dvDataStruct.dvConfigurationStruct', dvDataStruct, 'dvDataStruct',  ...
     'validate_dv_inputs', ...
     fieldsAndBounds, quickAndDirtyCheckFlag, suppressDisplayFlag);

clear fieldsAndBounds

%--------------------------------------------------------------------------
% Second level validation.
% Assign invalid fields to dvDataStruct.fluxTypeConfigurationStruct and 
% test validate_dv_inputs
%--------------------------------------------------------------------------
fieldsAndBounds = cell(1,4);
fieldsAndBounds(1,:)  = { 'fluxType'; []; []; {'SAP'; 'OAP'; 'DIA'}};

assign_illegal_value_and_test_for_failure(dvDataStruct.fluxTypeConfigurationStruct, ...
    'dvDataStruct.fluxTypeConfigurationStruct', dvDataStruct, ...
    'dvDataStruct', 'validate_dv_inputs', ...
    fieldsAndBounds, quickAndDirtyCheckFlag, suppressDisplayFlag);

clear fieldsAndBounds;

%--------------------------------------------------------------------------
% Second level validation.
% Assign invalid fields to dvDataStruct.planetFitConfigurationStruct and 
% test validate_dv_inputs
%--------------------------------------------------------------------------
fieldsAndBounds = cell(45,4);
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
% fieldsAndBounds(13,:) = { 'impactParametersForReducedFits'; []; []; []};          % Can't set bounds if vector may be empty
fieldsAndBounds(13,:) = { 'trapezoidalModelFitEnabled'; []; []; [true; false]};
fieldsAndBounds(14,:) = { 'tolFun'; '> 0'; '< 1'; []};                            % FOR NOW
fieldsAndBounds(15,:) = { 'tolX'; '> 0'; '< 1'; []};                              % FOR NOW
fieldsAndBounds(16,:) = { 'tolSigma'; '> 0'; '< 1'; []};                          % FOR NOW
fieldsAndBounds(17,:) = { 'transitBufferCadences'; '> 0'; '< 20'; []};            % FOR NOW
fieldsAndBounds(18,:) = { 'transitEpochStepSizeCadences'; '>= -1'; '< 10'; []};   % FOR NOW
fieldsAndBounds(19,:) = { 'planetRadiusStepSizeEarthRadii'; '>= -1'; '< 10'; []}; % FOR NOW
fieldsAndBounds(20,:) = { 'ratioPlanetRadiusToStarRadiusStepSize'; '>= -1'; '< 10'; []};     % FOR NOW
fieldsAndBounds(21,:) = { 'semiMajorAxisStepSizeAu'; '>= -1'; '< 10'; []};        % FOR NOW
fieldsAndBounds(22,:) = { 'ratioSemiMajorAxisToStarRadiusStepSize'; '>= -1'; '< 10'; []};    % FOR NOW
fieldsAndBounds(23,:) = { 'minImpactParameterStepSize'; '>= -1'; '< 10'; []};     % FOR NOW
fieldsAndBounds(24,:) = { 'orbitalPeriodStepSizeDays'; '>= -1'; '< 10'; []};      % FOR NOW
fieldsAndBounds(25,:) = { 'fitterTransitRemovalMethod'; []; []; '[0:1]'''};       % FOR NOW
fieldsAndBounds(26,:) = { 'fitterTransitRemovalBufferTransits'; '>= 0'; []; []};  % FOR NOW
fieldsAndBounds(27,:) = { 'subtractModelTransitRemovalMethod'; []; []; '[0:1]'''};          % FOR NOW
fieldsAndBounds(28,:) = { 'subtractModelTransitRemovalBufferTransits'; '>= 0'; []; []};     % FOR NOW
fieldsAndBounds(29,:) = { 'eclipsingBinaryDepthLimitPpm'; '>= 0'; []; []};        % FOR NOW
fieldsAndBounds(30,:) = { 'eclipsingBinaryAspectRatioLimitCadences'; '>= 0'; []; []};       % FOR NOW
fieldsAndBounds(31,:) = { 'eclipsingBinaryAspectRatioDepthLimitPpm'; '>= 0'; []; []};       % FOR NOW
fieldsAndBounds(32,:) = { 'giantTransitDetectionThresholdScaleFactor'; '>= 0'; '< 5'; []};  % FOR NOW
fieldsAndBounds(33,:) = { 'fitterTimeoutFraction'; '>= 0'; '<= 1'; []};           % FOR NOW
fieldsAndBounds(34,:) = { 'impactParameterSeed'; '>= 0'; '<= 1'; []};
fieldsAndBounds(35,:) = { 'iterationToFreezeCadencesForFit'; '>= 0'; '< 10'; []};
fieldsAndBounds(36,:) = { 'defaultRadius'; '> 0'; '< 10'; []};
fieldsAndBounds(37,:) = { 'defaultEffectiveTemp'; '> 0'; '< 8000'; []};
fieldsAndBounds(38,:) = { 'defaultLog10SurfaceGravity'; '> 3'; '< 5'; []};
fieldsAndBounds(39,:) = { 'defaultLog10Metallicity'; '>= -25'; '<= 5'; []};
fieldsAndBounds(40,:) = { 'defaultAlbedo'; '>= 0'; '<= 1'; []};
fieldsAndBounds(41,:) = { 'transitDurationMultiplier'; '>= 1'; '< 100'; []};
fieldsAndBounds(42,:) = { 'robustWeightThresholdForPlots'; '>= 0'; '<= 1'; []};
fieldsAndBounds(43,:) = { 'reportSummaryClippingLevel'; '> 0'; '< 25'; []};
fieldsAndBounds(44,:) = { 'reportSummaryBinsPerTransit'; '>= 1'; '< 25'; []};
fieldsAndBounds(45,:) = { 'deemphasisWeightsEnabled'; []; []; [true; false]};

assign_illegal_value_and_test_for_failure(dvDataStruct.planetFitConfigurationStruct, ...
    'dvDataStruct.planetFitConfigurationStruct', dvDataStruct, ...
    'dvDataStruct', 'validate_dv_inputs', ...
    fieldsAndBounds, quickAndDirtyCheckFlag, suppressDisplayFlag);

clear fieldsAndBounds;

%--------------------------------------------------------------------------
% Second level validation.
% Assign invalid fields to dvDataStruct.trapezoidalFitConfigurationStruct and 
% test validate_dv_inputs
%--------------------------------------------------------------------------
fieldsAndBounds = cell(7,4);
fieldsAndBounds(1,:)  = { 'defaultSmoothingParameter'; '>= 0'; '<= 1e12'; []};
fieldsAndBounds(2,:)  = { 'filterCircularShift'; '> 0'; '<= 1000'; []};
fieldsAndBounds(3,:)  = { 'gapThreshold'; '> 0'; '<= 1000'; []};
fieldsAndBounds(4,:)  = { 'medianFilterLength'; '> 0'; '<= 1e6'; []};
fieldsAndBounds(5,:)  = { 'snrThreshold'; '> 0'; '<= 1e6'; []};
fieldsAndBounds(6,:)  = { 'transitFitRegion'; '> 1'; '<= 20'; []};
fieldsAndBounds(7,:)  = { 'transitSamplesPerCadence'; '> 0'; '<= 540'; []};

assign_illegal_value_and_test_for_failure(dvDataStruct.trapezoidalFitConfigurationStruct, ...
    'dvDataStruct.trapezoidalFitConfigurationStruct', dvDataStruct, ...
    'dvDataStruct', 'validate_dv_inputs', ...
    fieldsAndBounds, quickAndDirtyCheckFlag, suppressDisplayFlag);

clear fieldsAndBounds;

%--------------------------------------------------------------------------
% Second level validation.
% Assign invalid fields to dvDataStruct.centroidTestConfigurationStruct and 
% test validate_dv_inputs
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

assign_illegal_value_and_test_for_failure(dvDataStruct.centroidTestConfigurationStruct, ...
    'dvDataStruct.centroidTestConfigurationStruct', dvDataStruct, ...
    'dvDataStruct', 'validate_dv_inputs', ...
    fieldsAndBounds, quickAndDirtyCheckFlag, suppressDisplayFlag);

clear fieldsAndBounds;

%--------------------------------------------------------------------------
% Second level validation.
% Assign invalid fields to dvDataStruct.pixelCorrelationConfigurationStruct
% and test validate_dv_inputs
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

assign_illegal_value_and_test_for_failure(dvDataStruct.pixelCorrelationConfigurationStruct, ...
    'dvDataStruct.pixelCorrelationConfigurationStruct', dvDataStruct, ...
    'dvDataStruct', 'validate_dv_inputs', ...
    fieldsAndBounds, quickAndDirtyCheckFlag, suppressDisplayFlag);

clear fieldsAndBounds;

%--------------------------------------------------------------------------
% Second level validation.
% Assign invalid fields to dvDataStruct.differenceImageConfigurationStruct
% and test validate_dv_inputs
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

assign_illegal_value_and_test_for_failure(dvDataStruct.differenceImageConfigurationStruct, ...
    'dvDataStruct.differenceImageConfigurationStruct', dvDataStruct, ...
    'dvDataStruct', 'validate_dv_inputs', ...
    fieldsAndBounds, quickAndDirtyCheckFlag, suppressDisplayFlag);

clear fieldsAndBounds;

%--------------------------------------------------------------------------
% Second level validation.
% Assign invalid fields to dvDataStruct.bootstrapConfigurationStruct
% and test validate_dv_inputs
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

assign_illegal_value_and_test_for_failure(dvDataStruct.bootstrapConfigurationStruct, ...
    'dvDataStruct.bootstrapConfigurationStruct', dvDataStruct, ...
    'dvDataStruct', 'validate_dv_inputs', ...
    fieldsAndBounds, quickAndDirtyCheckFlag, suppressDisplayFlag);

clear fieldsAndBounds;

%--------------------------------------------------------------------------
% Second level validation.
% Assign invalid field values to dvDataStruct.ancillaryPipelineConfigurationStruct, 
% if ancillaryPipelineDataStruct not empty and test validate_dv_inputs.
%--------------------------------------------------------------------------
if ~isempty(dvDataStruct.targetTableDataStruct(1).ancillaryPipelineDataStruct)
    
    fieldsAndBounds = cell(1,4);
%    fieldsAndBounds(1,:)  = { 'mnemonics'; []; []; {}};
    fieldsAndBounds(1,:)  = { 'modelOrders'; '>= 0'; '<= 5'; []};
%     fieldsAndBounds(2,:)  = { 'interactions'; []; []; {}};

    assign_illegal_value_and_test_for_failure(dvDataStruct.ancillaryPipelineConfigurationStruct, ...
        'dvDataStruct.ancillaryPipelineConfigurationStruct', ...
        dvDataStruct, 'dvDataStruct', 'validate_dv_inputs', ...
        fieldsAndBounds, quickAndDirtyCheckFlag, suppressDisplayFlag);

    clear fieldsAndBounds;
    
end

%--------------------------------------------------------------------------
% Second level validation.
% Assign invalid field values to
% dvDataStruct.ancillaryDesignMatrixConfigurationStruct
% and test validate_dv_inputs.
%--------------------------------------------------------------------------
fieldsAndBounds = cell(4,4);
fieldsAndBounds(1,:)  = { 'filteringEnabled'; []; []; [true; false]};
fieldsAndBounds(2,:)  = { 'sgPolyOrders'; '>= 1'; '<= 4'; []};
fieldsAndBounds(3,:)  = { 'sgFrameSizes'; '> 4'; '< 10000'; []};
fieldsAndBounds(4,:)  = { 'bandpassFlags'; []; []; [true; false]};

assign_illegal_value_and_test_for_failure(dvDataStruct.ancillaryDesignMatrixConfigurationStruct, ...
    'dvDataStruct.ancillaryDesignMatrixConfigurationStruct', dvDataStruct, ...
    'dvDataStruct', 'validate_dv_inputs', ...
    fieldsAndBounds, quickAndDirtyCheckFlag, suppressDisplayFlag);

clear fieldsAndBounds;

%--------------------------------------------------------------------------
% Second level validation.
% Assign invalid fields to dvDataStruct.gapFillConfigurationStruct and test
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

assign_illegal_value_and_test_for_failure(dvDataStruct.gapFillConfigurationStruct, ...
    'dvDataStruct.gapFillConfigurationStruct', dvDataStruct, 'dvDataStruct',  ...
    'validate_dv_inputs', ...
    fieldsAndBounds, quickAndDirtyCheckFlag, suppressDisplayFlag);

clear fieldsAndBounds;

%--------------------------------------------------------------------------
% Second level validation.
% Assign invalid fields to dvDataStruct.pdcConfigurationStruct and test
% validate_dv_inputs catches it.
%--------------------------------------------------------------------------
fieldsAndBounds = cell(26,4);
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
% fieldsAndBounds(20,:) = { 'excludeTargetLabels'; []; []; {}};
fieldsAndBounds(20,:) = { 'harmonicsRemovalEnabled'; []; []; [true; false]};
fieldsAndBounds(21,:) = { 'preMapIterations'; '> 0'; '< 10'; []};
fieldsAndBounds(22,:) = { 'variabilityEpRecoveryMaskEnabled'; []; []; [true; false]};
% fieldsAndBounds(23,:) = { 'variabilityEpRecoveryMaskWindow'; []; []; []};
% fieldsAndBounds(24,:) = { 'variabilityDetrendPolyOrder'; []; []; []};
fieldsAndBounds(23,:) = { 'bandSplittingEnabled'; []; []; [true; false]};
% fieldsAndBounds(24,:) = { 'bandSplittingEnabledQuarters'; []; []; []};
fieldsAndBounds(24,:) = { 'stellarVariabilityRemoveEclipsingBinariesEnabled'; []; []; [true; false]};
% fieldsAndBounds(25,:) = { 'mapSelectionMethod'; []; []; []};
fieldsAndBounds(25,:) = { 'mapSelectionMethodCutoff'; '>= 0'; '<= 1.0'; []};
fieldsAndBounds(26,:) = { 'mapSelectionMethodMultiscaleBias'; '>= 0'; '<= 1'; []};

assign_illegal_value_and_test_for_failure(dvDataStruct.pdcConfigurationStruct, ...
    'dvDataStruct.pdcConfigurationStruct', dvDataStruct, 'dvDataStruct',  ...
    'validate_dv_inputs', ...
    fieldsAndBounds, quickAndDirtyCheckFlag, suppressDisplayFlag);

clear fieldsAndBounds;

%--------------------------------------------------------------------------
% Second level validation.
% Assign invalid fields to dvDataStruct.saturationSegmentConfigurationStruct and
% test validate_dv_inputs catches it.
%--------------------------------------------------------------------------
fieldsAndBounds = cell(5,4);
fieldsAndBounds(1,:)  = { 'sgPolyOrder'; '>= 2'; '<= 24'; []};
fieldsAndBounds(2,:)  = { 'sgFrameSize'; '>= 25'; '< 10000'; []};
fieldsAndBounds(3,:)  = { 'satSegThreshold'; '> 0'; '<= 1e6'; []};
fieldsAndBounds(4,:)  = { 'satSegExclusionZone'; '>= 1'; '<= 10000'; []};
fieldsAndBounds(5,:)  = { 'maxSaturationMagnitude'; '>= 6'; '<= 15'; []};

assign_illegal_value_and_test_for_failure(dvDataStruct.saturationSegmentConfigurationStruct, ...
    'dvDataStruct.saturationSegmentConfigurationStruct', dvDataStruct, ...
    'dvDataStruct', 'validate_dv_inputs', ...
    fieldsAndBounds, quickAndDirtyCheckFlag, suppressDisplayFlag);

clear fieldsAndBounds;

%--------------------------------------------------------------------------
% Second level validation.
% Assign invalid fields to dvDataStruct.tpsHarmonicsIdentificationConfigurationStruct and
% test validate_dv_inputs catches it.
%--------------------------------------------------------------------------
fieldsAndBounds = cell(8,4);
fieldsAndBounds(1,:)  = { 'medianWindowLengthForTimeSeriesSmoothing'; '>= 1'; []; []};   % FOR NOW
fieldsAndBounds(2,:)  = { 'medianWindowLengthForPeriodogramSmoothing'; '>= 1'; []; []};  % FOR NOW
fieldsAndBounds(3,:)  = { 'movingAverageWindowLength'; '>= 1'; []; []};                  % FOR NOW
fieldsAndBounds(4,:)  = { 'falseDetectionProbabilityForTimeSeries'; '> 0'; '< 1'; []};   % FOR NOW
fieldsAndBounds(5,:)  = { 'minHarmonicSeparationInBins'; '>= 1'; '<= 10000'; []};         % FOR NOW
fieldsAndBounds(6,:)  = { 'maxHarmonicComponents'; '>= 0'; '<= 10000'; []};              % FOR NOW
fieldsAndBounds(7,:)  = { 'retainFrequencyCombsEnabled'; [] ; [] ; [true,false]};
fieldsAndBounds(8,:)  = { 'timeOutInMinutes'; '> 0'; '<= 180'; []};                      % FOR NOW

assign_illegal_value_and_test_for_failure(dvDataStruct.tpsHarmonicsIdentificationConfigurationStruct , ...
    'dvDataStruct.tpsHarmonicsIdentificationConfigurationStruct ', dvDataStruct, ...
    'dvDataStruct', 'validate_dv_inputs', ...
    fieldsAndBounds, quickAndDirtyCheckFlag, suppressDisplayFlag);

clear fieldsAndBounds;

%--------------------------------------------------------------------------
% Second level validation.
% Assign invalid fields to dvDataStruct.pdcHarmonicsIdentificationConfigurationStruct and
% test validate_dv_inputs catches it.
%--------------------------------------------------------------------------
fieldsAndBounds = cell(8,4);
fieldsAndBounds(1,:)  = { 'medianWindowLengthForTimeSeriesSmoothing'; '>= 1'; []; []};   % FOR NOW
fieldsAndBounds(2,:)  = { 'medianWindowLengthForPeriodogramSmoothing'; '>= 1'; []; []};  % FOR NOW
fieldsAndBounds(3,:)  = { 'movingAverageWindowLength'; '>= 1'; []; []};                  % FOR NOW
fieldsAndBounds(4,:)  = { 'falseDetectionProbabilityForTimeSeries'; '> 0'; '< 1'; []};   % FOR NOW
fieldsAndBounds(5,:)  = { 'minHarmonicSeparationInBins'; '>= 1'; '<= 1000'; []};         % FOR NOW
fieldsAndBounds(6,:)  = { 'maxHarmonicComponents'; '>= 0'; '<= 10000'; []};              % FOR NOW
fieldsAndBounds(7,:)  = { 'retainFrequencyCombsEnabled'; [] ; [] ; [true,false]};
fieldsAndBounds(8,:)  = { 'timeOutInMinutes'; '> 0'; '<= 180'; []};                      % FOR NOW

assign_illegal_value_and_test_for_failure(dvDataStruct.pdcHarmonicsIdentificationConfigurationStruct , ...
    'dvDataStruct.pdcHarmonicsIdentificationConfigurationStruct ', dvDataStruct, ...
    'dvDataStruct', 'validate_dv_inputs', ...
    fieldsAndBounds, quickAndDirtyCheckFlag, suppressDisplayFlag);

clear fieldsAndBounds;

%--------------------------------------------------------------------------
% Second level validation.
% Assign invalid fields to dvDataStruct.tpsConfigurationStruct and test
% validate_dv_inputs catches it.
%--------------------------------------------------------------------------
fieldsAndBounds = get_tps_input_fields_and_bounds('tpsModuleParameters');

% Max search period may be -1.
if dvDataStruct.tpsConfigurationStruct.maximumSearchPeriodInDays == -1
    dvDataStruct.tpsConfigurationStruct.maximumSearchPeriodInDays = 1;
end

assign_illegal_value_and_test_for_failure(dvDataStruct.tpsConfigurationStruct, ...
    'dvDataStruct.tpsConfigurationStruct', dvDataStruct, 'dvDataStruct',  ...
    'validate_dv_inputs', ...
    fieldsAndBounds, quickAndDirtyCheckFlag, suppressDisplayFlag);

clear fieldsAndBounds;

%--------------------------------------------------------------------------
% Second level validation.
% Assign invalid fields to dvDataStruct.targetTableDataStruct and test
% validate_dv_inputs catches it.
%--------------------------------------------------------------------------
fieldsAndBounds = cell(6,4);
fieldsAndBounds(1,:)  = { 'targetTableId'; '> 0'; '< 256'; []};
fieldsAndBounds(2,:)  = { 'quarter'; '>= 0'; '< 100'; []};
fieldsAndBounds(3,:)  = { 'ccdModule'; []; []; '[2:4, 6:20, 22:24]'''};
fieldsAndBounds(4,:)  = { 'ccdOutput'; []; []; '[1 2 3 4]'''};
fieldsAndBounds(5,:)  = { 'startCadence'; '>= 0'; '< 5e5'; []};
fieldsAndBounds(6,:)  = { 'endCadence'; '>= 0'; '< 5e5'; []};
% fieldsAndBounds(7,:)  = { 'argabrighteningIndices'; []; []; []};            % Can't set bounds if vector may be empty
% fieldsAndBounds(8,:)  = { 'ancillaryPipelineDataStruct'; []; []; []};
% fieldsAndBounds(9,:)  = { 'motionPolyStruct'; []; []; []};
% fieldsAndBounds(10,:) = { 'cbvBlobs'; []; []; []};

nStructures = length(dvDataStruct.targetTableDataStruct);

for j = 1 : nStructures
    
    name = ['dvDataStruct.targetTableDataStruct(', num2str(j), ')'];
    assign_illegal_value_and_test_for_failure(dvDataStruct.targetTableDataStruct(j), ...
        name, dvDataStruct, 'dvDataStruct',  ...
        'validate_dv_inputs', ...
        fieldsAndBounds, quickAndDirtyCheckFlag, suppressDisplayFlag);
    
end

clear fieldsAndBounds;

%--------------------------------------------------------------------------
% Second level validation.
% Assign invalid fields to dvDataStruct.targetStruct and test validate_dv_inputs
% catches it. The keplerMag may be NaN for any target so it cannot be
% tested.
%--------------------------------------------------------------------------
fieldsAndBounds = cell(1,4);
fieldsAndBounds(1,:)  = { 'keplerId'; '> 0'; '< 1e9'; []};
% fieldsAndBounds(2,:)  = { 'categories'; []; []; []};
% fieldsAndBounds(3,:)  = { 'transits'; []; []; []};
% fieldsAndBounds(4,:)  = { 'raHours'; []; []; []};
% fieldsAndBounds(5,:)  = { 'decDegrees'; []; []; []};
% fieldsAndBounds(6,:)  = { 'keplerMag'; []; []; []};
% fieldsAndBounds(7,:)  = { 'radius'; []; []; []};
% fieldsAndBounds(8,:)  = { 'effectiveTemp'; []; []; []};
% fieldsAndBounds(9,:)  = { 'log10SurfaceGravity'; []; []; []};
% fieldsAndBounds(10,:) = { 'log10Metallicity'; []; []; []};
% fieldsAndBounds(11,:) = { 'rawFluxTimeSeries'; []; []; []};
% fieldsAndBounds(12,:) = { 'correctedFluxTimeSeries'; []; []; []};
% fieldsAndBounds(13,:) = { 'outliers'; []; []; []};
% fieldsAndBounds(14,:) = { 'discontinuityIndices'; []; []; []};              % FOR NOW
% fieldsAndBounds(15,:) = { 'centroids'; []; []; []};
% fieldsAndBounds(16,:) = { 'targetDataStruct'; []; []; []};
% fieldsAndBounds(17,:) = { 'thresholdCrossingEvent'; []; []; []};
% fieldsAndBounds(18,:) = { 'rollingBandContamination'; []; []; []};
% fieldsAndBounds(19,:) = { 'ukirtImageFileName'; []; []; []};

nStructures = length(dvDataStruct.targetStruct);

for j = 1 : nStructures
    
    name = ['dvDataStruct.targetStruct(', num2str(j), ')'];
    assign_illegal_value_and_test_for_failure(dvDataStruct.targetStruct(j), ...
        name, dvDataStruct, 'dvDataStruct',  ...
        'validate_dv_inputs', ...
        fieldsAndBounds, quickAndDirtyCheckFlag, suppressDisplayFlag);

end

clear fieldsAndBounds;

%--------------------------------------------------------------------------
% Third level validation.
% Assign invalid fields to dvDataStruct.dvCadenceTimes.dataAnomalyFlags
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

assign_illegal_value_and_test_for_failure(dvDataStruct.dvCadenceTimes.dataAnomalyFlags, ...
    'dvDataStruct.dvCadenceTimes.dataAnomalyFlags', dvDataStruct, 'dvDataStruct',  ...
    'validate_dv_inputs', ...
    fieldsAndBounds, quickAndDirtyCheckFlag, suppressDisplayFlag);

clear fieldsAndBounds;

%--------------------------------------------------------------------------
% Third level validation.
% Assign invalid fields to 
% dvDataStruct.targetTableDataStruct().ancillaryPipelineDataStruct, if not
% empty and test validate_dv_inputs catches it.
% % Just test first mnemonic.
%--------------------------------------------------------------------------
fieldsAndBounds = cell(2,4);
% fieldsAndBounds(1,:)  = { 'mnemonic'; []; []; {}};
fieldsAndBounds(1,:)  = { 'timestamps'; '> 54500'; '< 70000'; []};          % 2/4/2008 to 7/13/2050
% fieldsAndBounds(2,:)  = { 'values'; []; []; []};                          % TBD
fieldsAndBounds(2,:)  = { 'uncertainties'; '>= 0'; []; []};                 % TBD

nTables = length(dvDataStruct.targetTableDataStruct);

for i = 1 : nTables
    
    ancillaryPipelineDataStruct = ...
        dvDataStruct.targetTableDataStruct(i).ancillaryPipelineDataStruct;

    nStructures = length(ancillaryPipelineDataStruct);
    nStructures = min(nStructures, 1);

    for j = 1 : nStructures
        
        name = ['dvDataStruct.targetTableDataStruct(', num2str(i), ').ancillaryPipelineDataStruct(', num2str(j), ')'];
        assign_illegal_value_and_test_for_failure(ancillaryPipelineDataStruct(j), ...
            name, dvDataStruct, 'dvDataStruct', 'validate_dv_inputs', ...
            fieldsAndBounds, quickAndDirtyCheckFlag, suppressDisplayFlag);
        
    end

end

clear fieldsAndBounds;

%--------------------------------------------------------------------------
% Third level validation.
% Assign invalid fields to
% dvDataStruct.targetTableDataStruct().motionPolyStruct and test
% validate_dv_inputs catches it.
% Just test first motion polynomial.
%--------------------------------------------------------------------------
fieldsAndBounds = cell(6,4);
fieldsAndBounds(1,:)  = { 'cadence'; '>= 0'; '< 5e5'; []};
fieldsAndBounds(2,:)  = { 'mjdStartTime'; '> 54500'; '< 70000'; []};        % 2/4/2008 to 7/13/2050
fieldsAndBounds(3,:)  = { 'mjdMidTime'; '> 54500'; '< 70000'; []};          % 2/4/2008 to 7/13/2050
fieldsAndBounds(4,:)  = { 'mjdEndTime'; '> 54500'; '< 70000'; []};          % 2/4/2008 to 7/13/2050
fieldsAndBounds(5,:)  = { 'module'; []; []; '[2:4, 6:20, 22:24]'''};
fieldsAndBounds(6,:)  = { 'output'; []; []; '[1 2 3 4]'''};
% fieldsAndBounds(7,:)  = { 'rowPoly'; []; []; []};
% fieldsAndBounds(8,:)  = { 'rowPolyStatus'; []; []; '[0:1]'''};            % cannot make invalid because removing gaps will crash
% fieldsAndBounds(9,:)  = { 'colPoly'; []; []; []};
% fieldsAndBounds(10,:) = { 'colPolyStatus'; []; []; '[0:1]'''};            % cannot make invalid because removing gaps will crash

nTables = length(dvDataStruct.targetTableDataStruct);

for i = 1 : nTables
    
    motionPolyStruct = ...
        dvDataStruct.targetTableDataStruct(i).motionPolyStruct;

    nStructures = length(motionPolyStruct);
    nStructures = min(nStructures, 1);
    
    for j = 1 : nStructures
        
        name = ['dvDataStruct.targetTableDataStruct(', num2str(i), ').motionPolyStruct(', num2str(j), ')'];
        assign_illegal_value_and_test_for_failure(dvDataStruct.targetTableDataStruct.motionPolyStruct(j), ...
            name, dvDataStruct, 'dvDataStruct', 'validate_dv_inputs', ...
            fieldsAndBounds, quickAndDirtyCheckFlag, suppressDisplayFlag);

    end
    
end

clear fieldsAndBounds;

%--------------------------------------------------------------------------
% Third level validation.
% Assign invalid fields to dvDataStruct.targetStruct().transits and test
% validate_dv_inputs catches it. Cannot validate on this structure as
% it may be empty and NaN's are allowed to be present in the fields.
%--------------------------------------------------------------------------
% fieldsAndBounds = cell(5,4);
% fieldsAndBounds(1,:)  = { 'koiId'; []; []; []};
% fieldsAndBounds(2,:)  = { 'keplerName'; []; []; []};
% fieldsAndBounds(3,:)  = { 'duration'; '>= 0'; []; []};
% fieldsAndBounds(4,:)  = { 'epoch'; '>= 0'; []; []};
% fieldsAndBounds(5,:)  = { 'period'; '>= 0'; []; []};
% 
% nTargets = length(dvDataStruct.targetStruct);
% 
% for i = 1 : nTargets
%     
%     nStructures = length(dvDataStruct.targetStruct(i).transits);
%     nStructures = min(nStructures, 1);
%
%     for j = 1 : nStructures
%         
%         transits = dvDataStruct.targetStruct(i).transits(j);
%         
%         name = ['dvDataStruct.targetStruct(', num2str(i), ').transits(', num2str(j), ')'];
%         assign_illegal_value_and_test_for_failure(transits, ...
%             name,  dvDataStruct, 'dvDataStruct', 'validate_dv_inputs', ...
%             fieldsAndBounds, quickAndDirtyCheckFlag, suppressDisplayFlag);
%         
%     end
%     
% end
% 
% clear fieldsAndBounds;

%--------------------------------------------------------------------------
% Third level validation.
% Assign invalid fields to dvDataStruct.targetStruct().raHours and test
% validate_dv_inputs catches it. Cannot validate on this structure as
% NaN's are allowed to be present in the fields.
%--------------------------------------------------------------------------
% fieldsAndBounds = cell(3,4);
% fieldsAndBounds(1,:)  = { 'value'; '>= 0'; '< 24'; []'};
% fieldsAndBounds(2,:)  = { 'uncertainty'; '>= 0'; []; []};
% fieldsAndBounds(3,:)  = { 'provenance'; []; []; []};                        % FOR NOW
% 
% assign_illegal_value_and_test_for_failure(dvDataStruct.targetStruct.raHours, ...
%     'dvDataStruct.targetStruct.raHours',  dvDataStruct, 'dvDataStruct', ...
%     'validate_dv_inputs', ...
%     fieldsAndBounds, quickAndDirtyCheckFlag, suppressDisplayFlag);
% 
% clear fieldsAndBounds;

%--------------------------------------------------------------------------
% Third level validation.
% Assign invalid fields to dvDataStruct.targetStruct().decDegrees and test
% validate_dv_inputs catches it. Cannot validate on this structure as
% NaN's are allowed to be present in the fields.
%--------------------------------------------------------------------------
% fieldsAndBounds = cell(3,4);
% fieldsAndBounds(1,:)  = { 'value'; '>= -90'; '<= 90'; []'};
% fieldsAndBounds(2,:)  = { 'uncertainty'; '>= 0'; []; []};
% fieldsAndBounds(3,:)  = { 'provenance'; []; []; []};                        % FOR NOW
% 
% assign_illegal_value_and_test_for_failure(dvDataStruct.targetStruct.decDegrees, ...
%     'dvDataStruct.targetStruct.decDegrees',  dvDataStruct, 'dvDataStruct', ...
%     'validate_dv_inputs', ...
%     fieldsAndBounds, quickAndDirtyCheckFlag, suppressDisplayFlag);
% 
% clear fieldsAndBounds;

%--------------------------------------------------------------------------
% Third level validation.
% Assign invalid fields to dvDataStruct.targetStruct().keplerMag and test
% validate_dv_inputs catches it. Cannot validate on this structure as
% NaN's are allowed to be present in the fields.
%--------------------------------------------------------------------------
% fieldsAndBounds = cell(3,4);
% fieldsAndBounds(1,:)  = { 'value'; '>= 0'; '< 30'; []'};
% fieldsAndBounds(2,:)  = { 'uncertainty'; '>= 0'; []; []};
% fieldsAndBounds(3,:)  = { 'provenance'; []; []; []};                        % FOR NOW
% 
% assign_illegal_value_and_test_for_failure(dvDataStruct.targetStruct.keplerMag, ...
%     'dvDataStruct.targetStruct.keplerMag',  dvDataStruct, 'dvDataStruct', ...
%     'validate_dv_inputs', ...
%     fieldsAndBounds, quickAndDirtyCheckFlag, suppressDisplayFlag);
% 
% clear fieldsAndBounds;

%--------------------------------------------------------------------------
% Third level validation.
% Assign invalid fields to dvDataStruct.targetStruct().radius and test
% validate_dv_inputs catches it. Cannot validate on this structure as
% NaN's are allowed to be present in the fields.
%--------------------------------------------------------------------------
% fieldsAndBounds = cell(3,4);
% fieldsAndBounds(1,:)  = { 'value'; '> 0'; []; []};
% fieldsAndBounds(2,:)  = { 'uncertainty'; '>= 0'; []; []};
% fieldsAndBounds(3,:)  = { 'provenance'; []; []; []};
% 
% assign_illegal_value_and_test_for_failure(dvDataStruct.targetStruct.radius, ...
%     'dvDataStruct.targetStruct.radius',  dvDataStruct, 'dvDataStruct', ...
%     'validate_dv_inputs', ...
%     fieldsAndBounds, quickAndDirtyCheckFlag, suppressDisplayFlag);
% 
% clear fieldsAndBounds;

%--------------------------------------------------------------------------
% Third level validation.
% Assign invalid fields to dvDataStruct.targetStruct().effectiveTemp and test
% validate_dv_inputs catches it. Cannot validate on this structure as
% NaN's are allowed to be present in the fields.
%--------------------------------------------------------------------------
% fieldsAndBounds = cell(3,4);
% fieldsAndBounds(1,:)  = { 'value'; '> 0'; []; []};
% fieldsAndBounds(2,:)  = { 'uncertainty'; '>= 0'; []; []};
% fieldsAndBounds(3,:)  = { 'provenance'; []; []; []};
% 
% assign_illegal_value_and_test_for_failure(dvDataStruct.targetStruct.effectiveTemp, ...
%     'dvDataStruct.targetStruct.effectiveTemp',  dvDataStruct, ...
%     'dvDataStruct', 'validate_dv_inputs', ...
%     fieldsAndBounds, quickAndDirtyCheckFlag, suppressDisplayFlag);
% 
% clear fieldsAndBounds;

%--------------------------------------------------------------------------
% Third level validation.
% Assign invalid fields to dvDataStruct.targetStruct().log10SurfaceGravity and test
% validate_dv_inputs catches it. Cannot validate on this structure as
% NaN's are allowed to be present in the fields.
%--------------------------------------------------------------------------
% fieldsAndBounds = cell(3,4);
% fieldsAndBounds(1,:)  = { 'value'; '> -0.45'; []; []};
% fieldsAndBounds(2,:)  = { 'uncertainty'; '>= 0'; []; []};
% fieldsAndBounds(3,:)  = { 'provenance'; []; []; []};
% 
% assign_illegal_value_and_test_for_failure(dvDataStruct.targetStruct.log10SurfaceGravity, ...
%     'dvDataStruct.targetStruct.log10SurfaceGravity',  dvDataStruct, ...
%     'dvDataStruct', 'validate_dv_inputs', ...
%     fieldsAndBounds, quickAndDirtyCheckFlag, suppressDisplayFlag);
% 
% clear fieldsAndBounds;

%--------------------------------------------------------------------------
% Third level validation.
% Assign invalid fields to dvDataStruct.targetStruct().log10Metallicity and test
% validate_dv_inputs catches it. Cannot validate on this structure as
% NaN's are allowed to be present in the fields.
%--------------------------------------------------------------------------
% fieldsAndBounds = cell(3,4);
% fieldsAndBounds(1,:)  = { 'value'; '>= -25'; '<= 5'; []};
% fieldsAndBounds(2,:)  = { 'uncertainty'; '>= 0'; []; []};
% fieldsAndBounds(3,:)  = { 'provenance'; []; []; []};
% 
% assign_illegal_value_and_test_for_failure(dvDataStruct.targetStruct.log10Metallicity, ...
%     'dvDataStruct.targetStruct.log10Metallicity',  dvDataStruct, ...
%     'dvDataStruct', 'validate_dv_inputs', ...
%     fieldsAndBounds, quickAndDirtyCheckFlag, suppressDisplayFlag);
% 
% clear fieldsAndBounds;

%--------------------------------------------------------------------------
% Third level validation.
% Assign invalid fields to dvDataStruct.targetStruct().rawFluxTimeSeries and
% test validate_dv_inputs catches it.
%--------------------------------------------------------------------------
fieldsAndBounds = cell(2,4);
% fieldsAndBounds(1,:)  = { 'values'; []; []; []};                            % TBD
fieldsAndBounds(1,:)  = { 'uncertainties'; '>= 0'; []; []};                   % TBD
fieldsAndBounds(2,:)  = { 'gapIndicators'; []; []; [true; false]};

nStructures = length(dvDataStruct.targetStruct);

for j = 1 : nStructures
    
    name = ['dvDataStruct.targetStruct(', num2str(j), ').rawFluxTimeSeries'];
    assign_illegal_value_and_test_for_failure(dvDataStruct.targetStruct(j).rawFluxTimeSeries, ...
        name, dvDataStruct, 'dvDataStruct', 'validate_dv_inputs', ...
        fieldsAndBounds, quickAndDirtyCheckFlag, suppressDisplayFlag);

end

clear fieldsAndBounds;

%--------------------------------------------------------------------------
% Third level validation.
% Assign invalid fields to dvDataStruct.targetStruct().correctedFluxTimeSeries and
% test validate_dv_inputs catches it.
%--------------------------------------------------------------------------
fieldsAndBounds = cell(2,4);
% fieldsAndBounds(1,:)  = { 'values'; []; []; []};                            % TBD
fieldsAndBounds(1,:)  = { 'uncertainties'; '>= -1'; []; []};                  % Uncertainty = -1 for long gap filled values
fieldsAndBounds(2,:)  = { 'gapIndicators'; []; []; [true; false]};
% fieldsAndBounds(2,:)  = { 'filledIndices'; []; []; []};                     % Can't set bounds if vector may be empty

nStructures = length(dvDataStruct.targetStruct);

for j = 1 : nStructures
    
    name = ['dvDataStruct.targetStruct(', num2str(j), ').correctedFluxTimeSeries'];
    assign_illegal_value_and_test_for_failure(dvDataStruct.targetStruct(j).correctedFluxTimeSeries, ...
        name, dvDataStruct, 'dvDataStruct', 'validate_dv_inputs', ...
        fieldsAndBounds, quickAndDirtyCheckFlag, suppressDisplayFlag);

end

clear fieldsAndBounds;

%--------------------------------------------------------------------------
% Third level validation.
% Assign invalid fields to dvDataStruct.targetStruct().outliers and test
% validate_dv_inputs catches it.
%--------------------------------------------------------------------------
% fieldsAndBounds = cell(3,4);
% fieldsAndBounds(1,:)  = { 'values'; []; []; []};                            % Can't set bounds if vector may be empty
% fieldsAndBounds(2,:)  = { 'uncertainties'; []; []; []};                     % Can't set bounds if vector may be empty
% fieldsAndBounds(3,:)  = { 'indices'; []; []; []};                           % Can't set bounds if vector may be empty
% 
% assign_illegal_value_and_test_for_failure(dvDataStruct.targetStruct.outliers, ...
%     'dvDataStruct.targetStruct.outliers',  dvDataStruct, 'dvDataStruct', ...
%     'validate_dv_inputs', ...
%     fieldsAndBounds, quickAndDirtyCheckFlag, suppressDisplayFlag);
% 
% clear fieldsAndBounds;

%--------------------------------------------------------------------------
% Third level validation.
% Assign invalid fields in dvDataStruct.targetStruct().centroids and test
% validate_dv_inputs catches it.
%--------------------------------------------------------------------------
% fieldsAndBounds = cell(2,4);
% fieldsAndBounds(1,:)  = { 'prfCentroids'; []; []; []};
% fieldsAndBounds(2,:)  = { 'fluxWeightedCentroids'; []; []; []};
% 
% assign_illegal_value_and_test_for_failure(dvDataStruct.targetStruct.centroids, ...
%     'dvDataStruct.targetStruct.centroids',  dvDataStruct, 'dvDataStruct', ...
%     'validate_dv_inputs', ...
%     fieldsAndBounds, quickAndDirtyCheckFlag, suppressDisplayFlag);
% 
% clear fieldsAndBounds;

%--------------------------------------------------------------------------
% Third level validation.
% Assign invalid fields to dvDataStruct.targetStruct().targetDataStruct and test
% validate_dv_inputs catches it.
%--------------------------------------------------------------------------
fieldsAndBounds = cell(8,4);
fieldsAndBounds(1,:)  = { 'targetTableId'; '> 0'; '< 256'; []};
fieldsAndBounds(2,:)  = { 'quarter'; '>= 0'; '< 100'; []};
fieldsAndBounds(3,:)  = { 'ccdModule'; []; []; '[2:4, 6:20, 22:24]'''};
fieldsAndBounds(4,:)  = { 'ccdOutput'; []; []; '[1 2 3 4]'''};
fieldsAndBounds(5,:)  = { 'startCadence'; '>= 0'; '< 5e5'; []};
fieldsAndBounds(6,:)  = { 'endCadence'; '>= 0'; '< 5e5'; []};
% fieldsAndBounds(7,:)  = { 'labels'; []; []; {}};
fieldsAndBounds(7,:)  = { 'fluxFractionInAperture'; '>= 0'; '<= 1'; []};
fieldsAndBounds(8,:)  = { 'crowdingMetric'; '>= 0'; '<= 1'; []};
% fieldsAndBounds(8,:) = { 'pixelDataFileName'; []; []; []};

nTargets = length(dvDataStruct.targetStruct);

for i = 1 : nTargets
    
    nStructures = length(dvDataStruct.targetStruct(i).targetDataStruct);
    
    for j = 1 : nStructures
        
        targetDataStruct = dvDataStruct.targetStruct(i).targetDataStruct(j);
        
        name = ['dvDataStruct.targetStruct(', num2str(i), ').targetDataStruct(', num2str(j), ')'];
        assign_illegal_value_and_test_for_failure(targetDataStruct, ...
            name,  dvDataStruct, 'dvDataStruct', 'validate_dv_inputs', ...
            fieldsAndBounds, quickAndDirtyCheckFlag, suppressDisplayFlag);
        
    end
    
end

clear fieldsAndBounds;

%--------------------------------------------------------------------------
% Third level validation.
% Assign invalid fields to dvDataStruct.targetStruct().thresholdCrossingEvent
% and test validate_dv_inputs catches it.
%--------------------------------------------------------------------------
fieldsAndBounds = cell(15,4);
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
% fieldsAndBounds(15,:) = { 'weakSecondaryStruct'; []; []; []};
% fieldsAndBounds(16,:) = { 'deemphasizedNormalizationTimeSeries'; []; []; []};  % Can't set bounds if vector may be empty
fieldsAndBounds(15,:) = { 'thresholdForDesiredPfa'; '>= -1'; []; []};

nStructures = length(dvDataStruct.targetStruct);

for j = 1 : nStructures
    
    name = ['dvDataStruct.targetStruct(', num2str(j), ').thresholdCrossingEvent'];
    assign_illegal_value_and_test_for_failure(dvDataStruct.targetStruct(j).thresholdCrossingEvent, ...
        name, dvDataStruct, 'dvDataStruct', 'validate_dv_inputs', ...
        fieldsAndBounds, quickAndDirtyCheckFlag, suppressDisplayFlag);

end

clear fieldsAndBounds;

%--------------------------------------------------------------------------
% Third level validation.
% Assign invalid fields in 
% dvDataStruct.targetStruct().rollingBandContamination and test
% validate_dv_inputs catches it.
%--------------------------------------------------------------------------
% fieldsAndBounds = cell(2,4);
% fieldsAndBounds(1,:)  = { 'optimalAperture'; []; []; []};
% fieldsAndBounds(2,:)  = { 'fullAperture'; []; []; []};
% 
% nStructures = length(dvDataStruct.targetStruct);
% 
% for j = 1 : nStructures
%     
%     name = ['dvDataStruct.targetStruct(', num2str(j), ').rollingBandContamination'];
%     assign_illegal_value_and_test_for_failure(dvDataStruct.targetStruct(j).rollingBandContamination, ...
%         name, dvDataStruct, 'dvDataStruct', 'validate_dv_inputs', ...
%         fieldsAndBounds, quickAndDirtyCheckFlag, suppressDisplayFlag);
%     
% end
% 
% clear fieldsAndBounds;

%--------------------------------------------------------------------------
% Fourth level validation.
% Assign invalid fields to
% dvDataStruct.targetTableDataStruct().motionPolyStruct().rowPoly and test
% validate_dv_inputs catches it.
% Just test first motion polynomial.
%--------------------------------------------------------------------------
fieldsAndBounds = cell(8,4);
fieldsAndBounds(1,:)  = { 'offsetx'; []; []; '0'};
fieldsAndBounds(2,:)  = { 'scalex'; '>= 0'; []; []};
% fieldsAndBounds(3,:)  = { 'originx'; []; []; []};
fieldsAndBounds(3,:)  = { 'offsety'; []; []; '0'};
fieldsAndBounds(4,:)  = { 'scaley'; '>= 0'; []; []};
% fieldsAndBounds(5,:)  = { 'originy'; []; []; []};
fieldsAndBounds(5,:)  = { 'xindex'; []; []; '-1'};
fieldsAndBounds(6,:)  = { 'yindex'; []; []; '-1'};
fieldsAndBounds(7,:)  = { 'type'; []; []; {'standard'}};
fieldsAndBounds(8,:)  = { 'order'; '>= 0'; '< 10'; []};
% fieldsAndBounds(9,:)  = { 'message'; []; []; {}};
% fieldsAndBounds(10,:) = { 'coeffs'; []; []; []};                            % TBD
% fieldsAndBounds(11,:) = { 'covariance'; []; []; []};                        % TBD

nTables = length(dvDataStruct.targetTableDataStruct);

for i = 1 : nTables
    
    motionPolyStruct = ...
        dvDataStruct.targetTableDataStruct(i).motionPolyStruct;

    nStructures = length(motionPolyStruct);
    nStructures = min(nStructures, 1);

    for j = 1 : nStructures
        
        name = ['dvDataStruct.targetTableDataStruct(', num2str(i), ').motionPolyStruct(', num2str(j), ').rowPoly'];
        assign_illegal_value_and_test_for_failure(dvDataStruct.targetTableDataStruct(i).motionPolyStruct(j).rowPoly, ...
            name, dvDataStruct, 'dvDataStruct', 'validate_dv_inputs', ...
            fieldsAndBounds, quickAndDirtyCheckFlag, suppressDisplayFlag);

    end
    
end

clear fieldsAndBounds;

%--------------------------------------------------------------------------
% Fourth level validation.
% Assign invalid fields to
% dvDataStruct.targetTableDataStruct().motionPolyStruct().colPoly and test
% validate_dv_inputs catches it.
% Just test first motion polynomial.
%--------------------------------------------------------------------------
fieldsAndBounds = cell(8,4);
fieldsAndBounds(1,:)  = { 'offsetx'; []; []; '0'};
fieldsAndBounds(2,:)  = { 'scalex'; '>= 0'; []; []};
% fieldsAndBounds(3,:)  = { 'originx'; []; []; []};
fieldsAndBounds(3,:)  = { 'offsety'; []; []; '0'};
fieldsAndBounds(4,:)  = { 'scaley'; '>= 0'; []; []};
% fieldsAndBounds(5,:)  = { 'originy'; []; []; []};
fieldsAndBounds(5,:)  = { 'xindex'; []; []; '-1'};
fieldsAndBounds(6,:)  = { 'yindex'; []; []; '-1'};
fieldsAndBounds(7,:)  = { 'type'; []; []; {'standard'}};
fieldsAndBounds(8,:) = { 'order'; '>= 0'; '< 10'; []};
% fieldsAndBounds(9,:)  = { 'message'; []; []; {}};
% fieldsAndBounds(10,:) = { 'coeffs'; []; []; []};                            % TBD
% fieldsAndBounds(11,:) = { 'covariance'; []; []; []}                         % TBD

nTables = length(dvDataStruct.targetTableDataStruct);

for i = 1 : nTables
    
    motionPolyStruct = ...
        dvDataStruct.targetTableDataStruct(i).motionPolyStruct;

    nStructures = length(motionPolyStruct);
    nStructures = min(nStructures, 1);
    
    for j = 1 : nStructures
        
        name = ['dvDataStruct.targetTableDataStruct(', num2str(i), ').motionPolyStruct(', num2str(j), ').colPoly'];
        assign_illegal_value_and_test_for_failure(dvDataStruct.targetTableDataStruct(i).motionPolyStruct(j).colPoly, ...
            name, dvDataStruct, 'dvDataStruct', 'validate_dv_inputs', ...
            fieldsAndBounds, quickAndDirtyCheckFlag, suppressDisplayFlag);

    end
    
end

clear fieldsAndBounds;

%--------------------------------------------------------------------------
% Fourth level validation.
% Assign invalid fields to
% dvDataStruct.targetStruct().centroids.prfCentroids and test
% validate_dv_inputs catches it.
%--------------------------------------------------------------------------
% fieldsAndBounds = cell(2,4);
% fieldsAndBounds(1,:)  = { 'rowTimeSeries'; []; []; []};
% fieldsAndBounds(2,:)  = { 'columnTimeSeries'; []; []; []};
% 
% assign_illegal_value_and_test_for_failure(dvDataStruct.targetStruct.centroids.prfCentroids, ...
%      'dvDataStruct.targetStruct.centroids.prfCentroids',  dvDataStruct, ...
%      'dvDataStruct', 'validate_dv_inputs', ...
%      fieldsAndBounds, quickAndDirtyCheckFlag, suppressDisplayFlag);
% 
% clear fieldsAndBounds;

%--------------------------------------------------------------------------
% Fourth level validation.
% Assign invalid fields to 
% dvDataStruct.targetStruct().centroids.fluxWeightedCentroids and test
% validate_dv_inputs catches it.
%--------------------------------------------------------------------------
% fieldsAndBounds = cell(2,4);
% fieldsAndBounds(1,:)  = { 'rowTimeSeries'; []; []; []};
% fieldsAndBounds(2,:)  = { 'columnTimeSeries'; []; []; []};
% 
% assign_illegal_value_and_test_for_failure(dvDataStruct.targetStruct.centroids.fluxWeightedCentroids, ...
%      'dvDataStruct.targetStruct.centroids.fluxWeightedCentroids',  ...
%      dvDataStruct, 'dvDataStruct', 'validate_dv_inputs', ...
%      fieldsAndBounds, quickAndDirtyCheckFlag, suppressDisplayFlag);
% 
% clear fieldsAndBounds;

%--------------------------------------------------------------------------
% Fourth level validation.
% Assign invalid fields to
% dvDataStruct.targetStruct().thresholdCrossingEvent.weakSecondaryStruct
% and test validate_dv_inputs catches it.
%--------------------------------------------------------------------------
fieldsAndBounds = cell(2,4);
% fieldsAndBounds(1,:)  = { 'phaseInDays'; []; []; []};
% fieldsAndBounds(2,:)  = { 'mes'; []; []; []};
% fieldsAndBounds(3,:)  = { 'maxMesPhaseInDays'; []; []; []};
% fieldsAndBounds(4,:)  = { 'maxMes'; []; []; []};
% fieldsAndBounds(5,:)  = { 'minMesPhaseInDays'; []; []; []};
% fieldsAndBounds(6,:)  = { 'minMes'; []; []; []};
% fieldsAndBounds(7,:)  = { 'medianMes'; []; []; []};
fieldsAndBounds(1,:)  = { 'mesMad'; '>= -1'; []; []};
fieldsAndBounds(2,:)  = { 'nValidPhases'; '>= -1'; []; []};
% fieldsAndBounds(10,:) = { 'robustStatistic'; []; []; []};
% fieldsAndBounds(11,:) = { 'depthPpm'; []; []; []};

assign_illegal_value_and_test_for_failure(dvDataStruct.targetStruct.thresholdCrossingEvent.weakSecondaryStruct, ...
     'dvDataStruct.targetStruct.thresholdCrossingEvent.weakSecondaryStruct',  ...
     dvDataStruct, 'dvDataStruct', 'validate_dv_inputs', ...
     fieldsAndBounds, quickAndDirtyCheckFlag, suppressDisplayFlag);

clear fieldsAndBounds;

%--------------------------------------------------------------------------
% Fourth level validation.
% Assign invalid fields in 
% dvDataStruct.targetStruct().rollingBandContamination.optimalAperture and
% test validate_dv_inputs catches it.
%--------------------------------------------------------------------------
fieldsAndBounds = cell(2,4);
fieldsAndBounds(1,:)  = { 'values'; '>= 0'; '<= 4'; []};
fieldsAndBounds(2,:)  = { 'gapIndicators'; []; []; [true; false]};

nStructures = length(dvDataStruct.targetStruct);

for j = 1 : nStructures
    
    name = ['dvDataStruct.targetStruct(', num2str(j), ').rollingBandContamination.optimalAperture'];
    assign_illegal_value_and_test_for_failure(dvDataStruct.targetStruct(j).rollingBandContamination.optimalAperture, ...
        name, dvDataStruct, 'dvDataStruct', 'validate_dv_inputs', ...
        fieldsAndBounds, quickAndDirtyCheckFlag, suppressDisplayFlag);
    
end

clear fieldsAndBounds;

%--------------------------------------------------------------------------
% Fourth level validation.
% Assign invalid fields in 
% dvDataStruct.targetStruct().rollingBandContamination.fullAperture and
% test validate_dv_inputs catches it.
%--------------------------------------------------------------------------
fieldsAndBounds = cell(2,4);
fieldsAndBounds(1,:)  = { 'values'; '>= 0'; '<= 4'; []};
fieldsAndBounds(2,:)  = { 'gapIndicators'; []; []; [true; false]};

nStructures = length(dvDataStruct.targetStruct);

for j = 1 : nStructures
    
    name = ['dvDataStruct.targetStruct(', num2str(j), ').rollingBandContamination.fullAperture'];
    assign_illegal_value_and_test_for_failure(dvDataStruct.targetStruct(j).rollingBandContamination.fullAperture, ...
        name, dvDataStruct, 'dvDataStruct', 'validate_dv_inputs', ...
        fieldsAndBounds, quickAndDirtyCheckFlag, suppressDisplayFlag);
    
end

clear fieldsAndBounds;

%--------------------------------------------------------------------------
% Fifth level validation.
% Assign invalid fields to
% dvDataStruct.targetStruct().centroids.prfCentroids.rowTimeSeries and test
% validate_dv_inputs catches it.
%--------------------------------------------------------------------------
fieldsAndBounds = cell(3,4);
fieldsAndBounds(1,:)  = { 'values'; '>= 0'; '< 1070'; []};
fieldsAndBounds(2,:)  = { 'uncertainties'; '>= 0'; []; []};
fieldsAndBounds(3,:)  = { 'gapIndicators'; []; []; [true; false]};

nStructures = length(dvDataStruct.targetStruct);

for j = 1 : nStructures
    
    name = ['dvDataStruct.targetStruct(', num2str(j), ').centroids.prfCentroids.rowTimeSeries'];
    assign_illegal_value_and_test_for_failure(dvDataStruct.targetStruct(j).centroids.prfCentroids.rowTimeSeries, ...
        name, dvDataStruct, 'dvDataStruct', 'validate_dv_inputs', ...
        fieldsAndBounds, quickAndDirtyCheckFlag, suppressDisplayFlag);

end

clear fieldsAndBounds;

%--------------------------------------------------------------------------
% Fifth level validation.
% Assign invalid fields to
% dvDataStruct.targetStruct().centroids.prfCentroids.columnTimeSeries and
% test validate_dv_inputs catches it.
%--------------------------------------------------------------------------
fieldsAndBounds = cell(3,4);
fieldsAndBounds(1,:)  = { 'values'; '>= 0'; '< 1132'; []};
fieldsAndBounds(2,:)  = { 'uncertainties'; '>= 0'; []; []};
fieldsAndBounds(3,:)  = { 'gapIndicators'; []; []; [true; false]};

nStructures = length(dvDataStruct.targetStruct);

for j = 1 : nStructures
    
    name = ['dvDataStruct.targetStruct(', num2str(j), ').centroids.prfCentroids.columnTimeSeries'];
    assign_illegal_value_and_test_for_failure(dvDataStruct.targetStruct(j).centroids.prfCentroids.columnTimeSeries, ...
        name, dvDataStruct, 'dvDataStruct', 'validate_dv_inputs', ...
        fieldsAndBounds, quickAndDirtyCheckFlag, suppressDisplayFlag);

end

clear fieldsAndBounds;

%--------------------------------------------------------------------------
% Fifth level validation.
% Assign invalid fields to
% dvDataStruct.targetStruct().centroids.fluxWeightedCentroids.rowTimeSeries
% and test validate_dv_inputs catches it.
%--------------------------------------------------------------------------
fieldsAndBounds = cell(3,4);
fieldsAndBounds(1,:)  = { 'values'; '>= 0'; '< 1070'; []};
fieldsAndBounds(2,:)  = { 'uncertainties'; '>= 0'; []; []};
fieldsAndBounds(3,:)  = { 'gapIndicators'; []; []; [true; false]};

nStructures = length(dvDataStruct.targetStruct);

for j = 1 : nStructures
    
    name = ['dvDataStruct.targetStruct(', num2str(j), ').centroids.fluxWeightedCentroids.rowTimeSeries'];
    assign_illegal_value_and_test_for_failure(dvDataStruct.targetStruct(j).centroids.fluxWeightedCentroids.rowTimeSeries, ...
        name, dvDataStruct, 'dvDataStruct', 'validate_dv_inputs', ...
        fieldsAndBounds, quickAndDirtyCheckFlag, suppressDisplayFlag);

end

clear fieldsAndBounds;

%--------------------------------------------------------------------------
% Fifth level validation.
% Assign invalid fields to
% dvDataStruct.targetStruct().centroids.fluxWeightedCentroids.columnTimeSeries
% and test validate_dv_inputs catches it.
%--------------------------------------------------------------------------
fieldsAndBounds = cell(3,4);
fieldsAndBounds(1,:)  = { 'values'; '>= 0'; '< 1132'; []};
fieldsAndBounds(2,:)  = { 'uncertainties'; '>= 0'; []; []};
fieldsAndBounds(3,:)  = { 'gapIndicators'; []; []; [true; false]};
 
nStructures = length(dvDataStruct.targetStruct);

for j = 1 : nStructures
    
    name = ['dvDataStruct.targetStruct(', num2str(j), ').centroids.fluxWeightedCentroids.columnTimeSeries'];
    assign_illegal_value_and_test_for_failure(dvDataStruct.targetStruct(j).centroids.fluxWeightedCentroids.columnTimeSeries, ...
        name, dvDataStruct, 'dvDataStruct', 'validate_dv_inputs', ...
        fieldsAndBounds, quickAndDirtyCheckFlag, suppressDisplayFlag);

end

clear fieldsAndBounds;

%--------------------------------------------------------------------------
% Fifth level validation.
% Assign invalid fields to
% dvDataStruct.targetStruct().thresholdCrossingEvent().weakSecondaryStruct.depthPpm
% and test validate_dv_inputs catches it.
%--------------------------------------------------------------------------
fieldsAndBounds = cell(1,4);
% fieldsAndBounds(1,:)  = { 'value'; []; []; []};
fieldsAndBounds(1,:)  = { 'uncertainty'; '>= -1'; []; []};

nTargets = length(dvDataStruct.targetStruct);

for i = 1 : nTargets
    
    nStructures = length(dvDataStruct.targetStruct(i).thresholdCrossingEvent);
    
    for j = 1 : nStructures
        
        depthPpm = dvDataStruct.targetStruct(i).thresholdCrossingEvent(j).weakSecondaryStruct.depthPpm;
        
        name = ['dvDataStruct.targetStruct(', num2str(i), ').thresholdCrossingEvent(', num2str(j), ').weakSecondaryStruct.depthPpm'];
        assign_illegal_value_and_test_for_failure(depthPpm, ...
            name,  dvDataStruct, 'dvDataStruct', 'validate_dv_inputs', ...
            fieldsAndBounds, quickAndDirtyCheckFlag, suppressDisplayFlag);
        
    end
    
end

clear fieldsAndBounds;

%--------------------------------------------------------------------------

pixelDataDirName = 'pixelData';
rmdir(pixelDataDirName, 's');

t = toc;
fprintf('\n test_validate_inputs_range_fail_case took %d seconds to complete\n', t)

% Return.
return
