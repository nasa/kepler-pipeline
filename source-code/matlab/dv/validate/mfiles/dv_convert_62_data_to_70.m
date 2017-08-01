%% dv_convert_62_data_to_70
%
% function dvDataStruct = dv_convert_62_data_to_70(dvDataStruct)
%
% Update 6.2-era DV input structures to 7.0. This is useful when testing
% with existing data sets.
%%
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

function dvDataStruct = dv_convert_62_data_to_70(dvDataStruct)

if isfield(dvDataStruct, 'ancillaryPipelineDataStruct')
    dvDataStruct.targetTableDataStruct(1).ancillaryPipelineDataStruct = ...
        dvDataStruct.ancillaryPipelineDataStruct;
    dvDataStruct = rmfield(dvDataStruct, 'ancillaryPipelineDataStruct');
end % if

if isfield(dvDataStruct, 'firstCall')
    dvDataStruct = rmfield(dvDataStruct, 'firstCall');
end % if

if isfield(dvDataStruct, 'targetTimeoutHours')
    targetTimeoutHours = dvDataStruct.targetTimeoutHours;
    dvDataStruct.dvConfigurationStruct.targetTimeoutHours = targetTimeoutHours;
    dvDataStruct = rmfield(dvDataStruct, 'targetTimeoutHours');
end % if

if isfield(dvDataStruct, 'harmonicsIdentificationConfigurationStruct')
    dvDataStruct.tpsHarmonicsIdentificationConfigurationStruct = ...
        dvDataStruct.harmonicsIdentificationConfigurationStruct;
    dvDataStruct.pdcHarmonicsIdentificationConfigurationStruct = ...
        dvDataStruct.harmonicsIdentificationConfigurationStruct;
    dvDataStruct = ...
        rmfield(dvDataStruct, 'harmonicsIdentificationConfigurationStruct');
end % if

if ~isfield(dvDataStruct.tpsHarmonicsIdentificationConfigurationStruct, 'medianWindowLengthForTimeSeriesSmoothing')
    harmonicsIdentificationConfigurationStruct.medianWindowLengthForTimeSeriesSmoothing = 21;
    harmonicsIdentificationConfigurationStruct.medianWindowLengthForPeriodogramSmoothing = 47;
    harmonicsIdentificationConfigurationStruct.movingAverageWindowLength = 47;
    harmonicsIdentificationConfigurationStruct.falseDetectionProbabilityForTimeSeries = 0.1;
    harmonicsIdentificationConfigurationStruct.minHarmonicSeparationInBins = 25;
    harmonicsIdentificationConfigurationStruct.maxHarmonicComponents = 100;
    harmonicsIdentificationConfigurationStruct.timeOutInMinutes = 10.0;
    dvDataStruct.tpsHarmonicsIdentificationConfigurationStruct = ...
        harmonicsIdentificationConfigurationStruct;
end % if

if ~isfield(dvDataStruct.pdcHarmonicsIdentificationConfigurationStruct, 'medianWindowLengthForTimeSeriesSmoothing')
    harmonicsIdentificationConfigurationStruct.medianWindowLengthForTimeSeriesSmoothing = 21;
    harmonicsIdentificationConfigurationStruct.medianWindowLengthForPeriodogramSmoothing = 47;
    harmonicsIdentificationConfigurationStruct.movingAverageWindowLength = 47;
    harmonicsIdentificationConfigurationStruct.falseDetectionProbabilityForTimeSeries = 0.1;
    harmonicsIdentificationConfigurationStruct.minHarmonicSeparationInBins = 25;
    harmonicsIdentificationConfigurationStruct.maxHarmonicComponents = 100;
    harmonicsIdentificationConfigurationStruct.timeOutInMinutes = 10.0;
    dvDataStruct.pdcHarmonicsIdentificationConfigurationStruct = ...
        harmonicsIdentificationConfigurationStruct;
end % if

if ~isfield(dvDataStruct.dvConfigurationStruct, 'differenceImageGenerationEnabled')
    dvDataStruct.dvConfigurationStruct.differenceImageGenerationEnabled = true;
end % if

if ~isfield(dvDataStruct.dvConfigurationStruct, 'pixelCorrelationTestsEnabled')
    dvDataStruct.dvConfigurationStruct.pixelCorrelationTestsEnabled = true;
end % if

if ~isfield(dvDataStruct.planetFitConfigurationStruct, 'secondaryConvergenceTolerance')
    dvDataStruct.planetFitConfigurationStruct.secondaryConvergenceTolerance = 0.1;
end % if

if ~isfield(dvDataStruct.planetFitConfigurationStruct, 'ratioPlanetRadiusToStarRadiusStepSize')
    dvDataStruct.planetFitConfigurationStruct.ratioPlanetRadiusToStarRadiusStepSize = 1e-5;
end % if

if ~isfield(dvDataStruct.planetFitConfigurationStruct, 'ratioSemiMajorAxisToStarRadiusStepSize')
    dvDataStruct.planetFitConfigurationStruct.ratioSemiMajorAxisToStarRadiusStepSize = 1e-5;
end % if

if ~isfield(dvDataStruct.planetFitConfigurationStruct, 'transitSamplesPerCadence')
    dvDataStruct.planetFitConfigurationStruct.transitSamplesPerCadence = 11;
end % if

if ~isfield(dvDataStruct, 'differenceImageConfigurationStruct')
    differenceImageConfigurationStruct.detrendingEnabled = false;
    differenceImageConfigurationStruct.detrendPolyOrder = 2;
    differenceImageConfigurationStruct.defaultMedianFilterLength = 73;
    differenceImageConfigurationStruct.anomalyBufferInDays = 1.0;
    differenceImageConfigurationStruct.controlBufferInCadences = 3;
    differenceImageConfigurationStruct.minInTransitDepth = 0.75;
    dvDataStruct.differenceImageConfigurationStruct = ...
        differenceImageConfigurationStruct;
elseif ~isfield(dvDataStruct.differenceImageConfigurationStruct, 'controlBufferInCadences')
    dvDataStruct.differenceImageConfigurationStruct.controlBufferInCadences = 3;
end % if / elseif

if isfield(dvDataStruct.dvConfigurationStruct, 'bootstrapSkipCount')
    dvDataStruct.bootstrapConfigurationStruct.skipCount = ...
        dvDataStruct.dvConfigurationStruct.bootstrapSkipCount;
    dvDataStruct.dvConfigurationStruct = ...
        rmfield(dvDataStruct.dvConfigurationStruct, 'bootstrapSkipCount');
end % if

if isfield(dvDataStruct.dvConfigurationStruct, 'bootstrapAutoSkipCountEnabled')
    dvDataStruct.bootstrapConfigurationStruct.autoSkipCountEnabled = ...
        dvDataStruct.dvConfigurationStruct.bootstrapAutoSkipCountEnabled;
    dvDataStruct.dvConfigurationStruct = ...
        rmfield(dvDataStruct.dvConfigurationStruct, 'bootstrapAutoSkipCountEnabled');
end % if

if isfield(dvDataStruct.dvConfigurationStruct, 'bootstrapMaxIterations')
    dvDataStruct.bootstrapConfigurationStruct.maxIterations = ...
        dvDataStruct.dvConfigurationStruct.bootstrapMaxIterations;
    dvDataStruct.dvConfigurationStruct = ...
        rmfield(dvDataStruct.dvConfigurationStruct, 'bootstrapMaxIterations');
end % if

if ~isfield(dvDataStruct.dvConfigurationStruct, 'maxNumberBins')
    dvDataStruct.bootstrapConfigurationStruct.maxNumberBins = 100;
end % if

if isfield(dvDataStruct.dvConfigurationStruct, 'histogramBinWidth')
    dvDataStruct.bootstrapConfigurationStruct.histogramBinWidth = ...
        dvDataStruct.dvConfigurationStruct.histogramBinWidth;
    dvDataStruct.dvConfigurationStruct = ...
        rmfield(dvDataStruct.dvConfigurationStruct, 'histogramBinWidth');
end % if

if isfield(dvDataStruct.dvConfigurationStruct, 'binsBelowSearchTransitThreshold')
    dvDataStruct.bootstrapConfigurationStruct.binsBelowSearchTransitThreshold = ...
        dvDataStruct.dvConfigurationStruct.binsBelowSearchTransitThreshold;
    dvDataStruct.dvConfigurationStruct = ...
        rmfield(dvDataStruct.dvConfigurationStruct, 'binsBelowSearchTransitThreshold');
end % if

if isfield(dvDataStruct.dvConfigurationStruct, 'bootstrapUpperLimitFactor')
    dvDataStruct.bootstrapConfigurationStruct.upperLimitFactor = ...
        dvDataStruct.dvConfigurationStruct.bootstrapUpperLimitFactor;
    dvDataStruct.dvConfigurationStruct = ...
        rmfield(dvDataStruct.dvConfigurationStruct, 'bootstrapUpperLimitFactor');
end % if

if isfield(dvDataStruct.tpsConfigurationStruct, 'trialTransitPulseInHours')
    dvDataStruct.tpsConfigurationStruct.requiredTrialTransitPulseInHours = ...
        dvDataStruct.tpsConfigurationStruct.trialTransitPulseInHours;
    dvDataStruct.tpsConfigurationStruct = ...
        rmfield(dvDataStruct.tpsConfigurationStruct, 'trialTransitPulseInHours');
end % if

if ~isfield(dvDataStruct.tpsConfigurationStruct, 'minTrialTransitPulseInHours')
    dvDataStruct.tpsConfigurationStruct.minTrialTransitPulseInHours = -1;
end % if

if ~isfield(dvDataStruct.tpsConfigurationStruct, 'maxTrialTransitPulseInHours')
    dvDataStruct.tpsConfigurationStruct.maxTrialTransitPulseInHours = -1;
end % if

if ~isfield(dvDataStruct.tpsConfigurationStruct, ...
        'searchTrialTransitPulseDurationStepControlFactor')
    dvDataStruct.tpsConfigurationStruct.searchTrialTransitPulseDurationStepControlFactor= 0.8;
end % if

if ~isfield(dvDataStruct.tpsConfigurationStruct, 'maxFoldingsInPeriodSearch')
    dvDataStruct.tpsConfigurationStruct.maxFoldingsInPeriodSearch = -1;
end % if

if ~isfield(dvDataStruct.tpsConfigurationStruct, 'performQuarterStitching')
    dvDataStruct.tpsConfigurationStruct.performQuarterStitching = true;
end % if

if ~isfield(dvDataStruct.tpsConfigurationStruct, 'pixelSensitivityDropoutThreshold')
    dvDataStruct.tpsConfigurationStruct.pixelSensitivityDropoutThreshold = 5.0;
end % if

if ~isfield(dvDataStruct.tpsConfigurationStruct, 'clusterProximity')
    dvDataStruct.tpsConfigurationStruct.clusterProximity = 1;
end % if

if ~isfield(dvDataStruct.tpsConfigurationStruct, 'medfiltWindowLengthDays')
    dvDataStruct.tpsConfigurationStruct.medfiltWindowLengthDays = 1.5;
end % if

if ~isfield(dvDataStruct.tpsConfigurationStruct, 'medfiltStandoffDays')
    dvDataStruct.tpsConfigurationStruct.medfiltStandoffDays = 3.0;
end % if

if ~isfield(dvDataStruct.tpsConfigurationStruct, 'minEventStatisticRatio')
    dvDataStruct.tpsConfigurationStruct.minEventStatisticRatio = 1.4142;
end % if

if ~isfield(dvDataStruct.gapFillConfigurationStruct, 'giantTransitPolyFitChunkLengthInHours')
    dvDataStruct.gapFillConfigurationStruct.giantTransitPolyFitChunkLengthInHours = 72;
end % if

if ~isfield(dvDataStruct.gapFillConfigurationStruct, 'removeShortPeriodEclipsingBinaries')
    dvDataStruct.gapFillConfigurationStruct.removeShortPeriodEclipsingBinaries = false;
end % if

if ~isfield(dvDataStruct.targetTableDataStruct(1), 'argabrighteningIndices')
    nTables = length(dvDataStruct.targetTableDataStruct);
    for iTable = 1 : nTables
        dvDataStruct.targetTableDataStruct(iTable).argabrighteningIndices = [];
    end % for iTable
end % if

% Set the raw flux equal to the corrected flux if it does not exist.
if ~isfield(dvDataStruct.targetStruct(1), 'rawFluxTimeSeries')
    nTargets = length(dvDataStruct.targetStruct);
    for iTarget = 1 : nTargets
        dvDataStruct.targetStruct(iTarget).rawFluxTimeSeries.values = ...
            dvDataStruct.targetStruct(iTarget).correctedFluxTimeSeries.values;
        dvDataStruct.targetStruct(iTarget).rawFluxTimeSeries.uncertainties = ...
            dvDataStruct.targetStruct(iTarget).correctedFluxTimeSeries.uncertainties;
        isLongGapFilled = dvDataStruct.targetStruct(iTarget).rawFluxTimeSeries.uncertainties  < 0;
        dvDataStruct.targetStruct(iTarget).rawFluxTimeSeries.uncertainties(isLongGapFilled) = 0;
        dvDataStruct.targetStruct(iTarget).rawFluxTimeSeries.gapIndicators = ...
            dvDataStruct.targetStruct(iTarget).correctedFluxTimeSeries.gapIndicators;
    end % for iTarget
end % if

% Add empty cosmic ray events fields (times, values) for all pixels.
if isfield(dvDataStruct.targetStruct(1).targetDataStruct(1), 'pixelDataStruct') && ...
        ~isfield(dvDataStruct.targetStruct(1).targetDataStruct(1).pixelDataStruct(1), 'cosmicRayEvents')
    nTargets = length(dvDataStruct.targetStruct);
    for iTarget = 1 : nTargets
        nTables = length(dvDataStruct.targetStruct(iTarget).targetDataStruct);
        for iTable = 1 : nTables
            nPixels = length(dvDataStruct.targetStruct(iTarget).targetDataStruct(iTable).pixelDataStruct);
            for iPixel = 1 : nPixels
                dvDataStruct.targetStruct(iTarget).targetDataStruct(iTable).pixelDataStruct(iPixel).cosmicRayEvents.times = [];
                dvDataStruct.targetStruct(iTarget).targetDataStruct(iTable).pixelDataStruct(iPixel).cosmicRayEvents.values = [];
            end % for iPixel
        end % for iTable
    end % for iTarget
end % if

% Add empty kics.
if ~isfield(dvDataStruct, 'kics')
    dvDataStruct.kics = [];
end % if

% Add default centroidTestConfigurationStruct if needed
if ~isfield(dvDataStruct, 'centroidTestConfigurationStruct')
    centroidTestConfigurationStruct = struct( ...
        'centroidModelFineMeshFactor', 10,...
        'iterativeWhitenerTolerance', 0.003,...
        'iterationLimit', 50,...
        'padTransitCadences', 2,...
        'minimumPointsPerPlanet', 3,...
        'maximumTransitDurationCadences', 101,...
        'centroidModelFineMeshEnabled', true,...
        'transitDurationsMasked', 1.5,...
        'transitDurationFactorForMedianFilter', 10,...
        'defaultMaxTransitDurationCadences', 50,...
        'madsToClipForCloudPlot', 100,...
        'foldedTransitDurationsShown',6,...
        'plotOutlierThesholdInSigma', 5,...
        'cloudPlotRaMarker', '+b',...
        'cloudPlotDecMarker', 'or',...
        'maximumSourceRaDecOffsetArcsec', 100); 
    % move field value from dvConfigurationStruct to centroidTestConfigurationStruct
    if isfield(dvDataStruct.dvConfigurationStruct, 'centroidModelFineMeshFactor')
        centroidTestConfigurationStruct.centroidModelFineMeshFactor = ...
            dvDataStruct.dvConfigurationStruct.centroidModelFineMeshFactor;
        dvDataStruct.dvConfigurationStruct = ...
            rmfield(dvDataStruct.dvConfigurationStruct, 'centroidModelFineMeshFactor');
    end        
    dvDataStruct.centroidTestConfigurationStruct = centroidTestConfigurationStruct;
end % if

% Add default pixelCorrelationConfigurationStruct if needed
if ~isfield(dvDataStruct, 'pixelCorrelationConfigurationStruct')
    pixelCorrelationConfigurationStruct = struct( ...
        'iterativeWhitenerTolerance', 0.01,...
        'iterationLimit', 25,...
        'significanceThreshold', 0.99,...
        'numIndicesDisplayedInAlerts', 6,...
        'apertureSymbol', '^',...
        'optimalApertureSymbol', 'o',...
        'significanceSymbol', 's',...
        'colorMap', 'hot',...
        'maxColorAxis', 0);   
    dvDataStruct.pixelCorrelationConfigurationStruct = ...
        pixelCorrelationConfigurationStruct;
end % if

% Remove obsolete field
if isfield(dvDataStruct.dvConfigurationStruct, 'centroidUncertaintySigmasAllowed')
    dvDataStruct.dvConfigurationStruct = ...
        rmfield(dvDataStruct.dvConfigurationStruct, 'centroidUncertaintySigmasAllowed');
end % if

% Add fc model metadata
fcModelMetadata = struct( ...
    'svnInfo', '', ...
    'ingestTime', '', ...
    'modelDescription', '', ...
    'databaseUrl', '', ...
    'databaseUsername', '');

if ~isfield(dvDataStruct.raDec2PixModel.geometryModel, 'fcModelMetadata')
    dvDataStruct.raDec2PixModel.geometryModel.fcModelMetadata = ...
        fcModelMetadata;
end % if

if ~isfield(dvDataStruct.raDec2PixModel.pointingModel, 'fcModelMetadata')
    dvDataStruct.raDec2PixModel.pointingModel.fcModelMetadata = ...
        fcModelMetadata;
end % if

if ~isfield(dvDataStruct.raDec2PixModel.rollTimeModel, 'fcModelMetadata')
    dvDataStruct.raDec2PixModel.rollTimeModel.fcModelMetadata = ...
        fcModelMetadata;
end % if

return
