% dv_convert_92_data_to_93
%
% function dvDataStruct = dv_convert_92_data_to_93(dvDataStruct)
%
% Update 9.2-era DV input structures to 9.3. This is useful when testing
% with existing data sets.
%
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

function dvDataStruct = dv_convert_92_data_to_93(dvDataStruct)

% Add new DV cadence times field.
if ~isfield(dvDataStruct.dvCadenceTimes, 'scTargetTableIds')
    dvDataStruct.dvCadenceTimes.scTargetTableIds = ...
        zeros(size(dvDataStruct.dvCadenceTimes.lcTargetTableIds));
end

% Add new DV parameters.
if ~isfield(dvDataStruct.dvConfigurationStruct, 'rollingBandDiagnosticsEnabled')
    dvDataStruct.dvConfigurationStruct.rollingBandDiagnosticsEnabled = false;
end

if ~isfield(dvDataStruct.dvConfigurationStruct, 'ghostDiagnosticTestsEnabled')
    dvDataStruct.dvConfigurationStruct.ghostDiagnosticTestsEnabled = true;
end

if ~isfield(dvDataStruct.dvConfigurationStruct, 'exceptionCatchingEnabled')
    dvDataStruct.dvConfigurationStruct.exceptionCatchingEnabled = true;
end

if ~isfield(dvDataStruct.dvConfigurationStruct, 'team')
    dvDataStruct.dvConfigurationStruct.team = [];
end

% Add new planet fit parameter.
if ~isfield(dvDataStruct.planetFitConfigurationStruct, 'trapezoidalModelFitEnabled')
    dvDataStruct.planetFitConfigurationStruct.trapezoidalModelFitEnabled = true;
end

% Add new trapezoidal model fit parameters
if ~isfield(dvDataStruct, 'trapezoidalFitConfigurationStruct')
    trapezoidalFitConfigurationStruct.defaultSmoothingParameter = 100.0;
    trapezoidalFitConfigurationStruct.filterCircularShift = 20.0;
    trapezoidalFitConfigurationStruct.gapThreshold = 10.0;
    trapezoidalFitConfigurationStruct.medianFilterLength = 1000.0;
    trapezoidalFitConfigurationStruct.snrThreshold = 30.0;
    trapezoidalFitConfigurationStruct.transitFitRegion = 4.0;
    trapezoidalFitConfigurationStruct.transitSamplesPerCadence  = 15.0;
    dvDataStruct.trapezoidalFitConfigurationStruct = trapezoidalFitConfigurationStruct;
end
if ~isfield(dvDataStruct.trapezoidalFitConfigurationStruct, 'defaultSmoothingParameter')
    dvDataStruct.trapezoidalFitConfigurationStruct.defaultSmoothingParameter = 100.0;
end
if ~isfield(dvDataStruct.trapezoidalFitConfigurationStruct, 'filterCircularShift')
    dvDataStruct.trapezoidalFitConfigurationStruct.filterCircularShift = 20.0;
end
if ~isfield(dvDataStruct.trapezoidalFitConfigurationStruct, 'gapThreshold')
    dvDataStruct.trapezoidalFitConfigurationStruct.gapThreshold = 10.0;
end
if ~isfield(dvDataStruct.trapezoidalFitConfigurationStruct, 'medianFilterLength')
    dvDataStruct.trapezoidalFitConfigurationStruct.medianFilterLength = 1000.0;
end
if ~isfield(dvDataStruct.trapezoidalFitConfigurationStruct, 'snrThreshold')
    dvDataStruct.trapezoidalFitConfigurationStruct.snrThreshold = 30.0;
end
if ~isfield(dvDataStruct.trapezoidalFitConfigurationStruct, 'transitFitRegion')
    dvDataStruct.trapezoidalFitConfigurationStruct.transitFitRegion = 4.0;
end
if ~isfield(dvDataStruct.trapezoidalFitConfigurationStruct, 'transitSamplesPerCadence')
    dvDataStruct.trapezoidalFitConfigurationStruct.transitSamplesPerCadence = 15.0;
end

% Add new centroid test parameters.
if ~isfield(dvDataStruct.centroidTestConfigurationStruct, 'chiSquaredTolerance')
    dvDataStruct.centroidTestConfigurationStruct.chiSquaredTolerance = 0.0005;
end
if ~isfield(dvDataStruct.centroidTestConfigurationStruct,'timeoutPerTargetSeconds')
    dvDataStruct.centroidTestConfigurationStruct.timeoutPerTargetSeconds = 7200;
end

% Add new pixel correlation test parameters.
if ~isfield(dvDataStruct.pixelCorrelationConfigurationStruct, 'chiSquaredTolerance')
    dvDataStruct.pixelCorrelationConfigurationStruct.chiSquaredTolerance = 0.005;
end
if ~isfield(dvDataStruct.pixelCorrelationConfigurationStruct,'timeoutPerTargetSeconds')
    dvDataStruct.pixelCorrelationConfigurationStruct.timeoutPerTargetSeconds = 7200;
end

% New parameters for the bootstrap.
if ~isfield(dvDataStruct.bootstrapConfigurationStruct, 'deemphasizeQuartersWithoutTransits')
    dvDataStruct.bootstrapConfigurationStruct.deemphasizeQuartersWithoutTransits = true;
end
if ~isfield(dvDataStruct.bootstrapConfigurationStruct, 'sesZeroCrossingWidthDays')
    dvDataStruct.bootstrapConfigurationStruct.sesZeroCrossingWidthDays = 2;
end
if ~isfield(dvDataStruct.bootstrapConfigurationStruct, 'sesZeroCrossingDensityFactor')
    dvDataStruct.bootstrapConfigurationStruct.sesZeroCrossingDensityFactor = 4;
end
if ~isfield(dvDataStruct.bootstrapConfigurationStruct, 'nSesPeaksToRemove')
    dvDataStruct.bootstrapConfigurationStruct.nSesPeaksToRemove = 3;
end
if ~isfield(dvDataStruct.bootstrapConfigurationStruct, 'sesPeakRemovalThreshold')
    dvDataStruct.bootstrapConfigurationStruct.sesPeakRemovalThreshold = 7.1;
end
if ~isfield(dvDataStruct.bootstrapConfigurationStruct, 'sesPeakRemovalFloor')
    dvDataStruct.bootstrapConfigurationStruct.sesPeakRemovalFloor = 2;
end
if ~isfield(dvDataStruct.bootstrapConfigurationStruct, 'bootstrapResolutionFactor')
    dvDataStruct.bootstrapConfigurationStruct.bootstrapResolutionFactor = 256;
end

% Update existing bootstrap parameter for new 2D convolution bootstrap
dvDataStruct.bootstrapConfigurationStruct.maxNumberBins = 4096;

% Update to bootstrap parameter.
if dvDataStruct.bootstrapConfigurationStruct.maxIterations > 2e6
    dvDataStruct.bootstrapConfigurationStruct.maxIterations = 2e6;    
end

% Add new TCE and weak secondary fields.
nTargets = length(dvDataStruct.targetStruct);

for iTarget = 1 : nTargets
    nTces = length(dvDataStruct.targetStruct(iTarget).thresholdCrossingEvent);
    if ~isfield(dvDataStruct.targetStruct(iTarget).thresholdCrossingEvent(1), 'chiSquareGof')
        for iTce = 1 : nTces
            dvDataStruct.targetStruct(iTarget).thresholdCrossingEvent(iTce).chiSquareGof = -1;
        end
    end
    if ~isfield(dvDataStruct.targetStruct(iTarget).thresholdCrossingEvent(1), 'chiSquareGofDof')
        for iTce = 1 : nTces
            dvDataStruct.targetStruct(iTarget).thresholdCrossingEvent(iTce).chiSquareGofDof = 0;
        end
    end
    if ~isfield(dvDataStruct.targetStruct(iTarget).thresholdCrossingEvent(1), 'thresholdForDesiredPfa')
        for iTce = 1 : nTces
            dvDataStruct.targetStruct(iTarget).thresholdCrossingEvent(iTce).thresholdForDesiredPfa = -1;
        end
    end
    if ~isfield(dvDataStruct.targetStruct(iTarget).thresholdCrossingEvent(1).weakSecondaryStruct, ...
            'medianMes')
        for iTce = 1 : nTces
            dvDataStruct.targetStruct(iTarget).thresholdCrossingEvent(iTce).weakSecondaryStruct.medianMes = 0;
        end
    end
    if ~isfield(dvDataStruct.targetStruct(iTarget).thresholdCrossingEvent(1).weakSecondaryStruct, ...
            'nValidPhases')
        for iTce = 1 : nTces
            dvDataStruct.targetStruct(iTarget).thresholdCrossingEvent(iTce).weakSecondaryStruct.nValidPhases = -1;
        end
    end
    if ~isfield(dvDataStruct.targetStruct(iTarget).thresholdCrossingEvent(1).weakSecondaryStruct, ...
            'robustStatistic')
        for iTce = 1 : nTces
            dvDataStruct.targetStruct(iTarget).thresholdCrossingEvent(iTce).weakSecondaryStruct.robustStatistic = -1;
        end
    end
    if ~isfield(dvDataStruct.targetStruct(iTarget).thresholdCrossingEvent(1).weakSecondaryStruct, ...
            'depthPpm')
        for iTce = 1 : nTces
            dvDataStruct.targetStruct(iTarget).thresholdCrossingEvent(iTce).weakSecondaryStruct.depthPpm = ...
                struct( ...
                'value', 0, ...
                'uncertainty', -1);
        end
    end
end

% Update rolling band target quality flags if necessary.
if ~isfield(dvDataStruct.targetStruct(1), 'rollingBandContaminationStruct')
    for iTarget = 1 : nTargets
        dvDataStruct.targetStruct(iTarget).rollingBandContaminationStruct.testPulseDurationLc = 1;       
        dvDataStruct.targetStruct(iTarget).rollingBandContaminationStruct.severityFlags = ...
            dvDataStruct.targetStruct(iTarget).rollingBandContamination.optimalAperture;
    end
end
if isfield(dvDataStruct.targetStruct(1), 'rollingBandContamination')
    dvDataStruct.targetStruct = ...
        rmfield(dvDataStruct.targetStruct, 'rollingBandContamination');
end

% Add new PDC parameter.
if ~isfield(dvDataStruct.pdcConfigurationStruct, 'bandSplittingEnabledQuarters')
    dvDataStruct.pdcConfigurationStruct.bandSplittingEnabledQuarters = '';
end

% Add new TPS parameters.
if ~isfield(dvDataStruct.tpsConfigurationStruct, 'mesHistogramMinMes')
    dvDataStruct.tpsConfigurationStruct.mesHistogramMinMes = -10;
end

if ~isfield(dvDataStruct.tpsConfigurationStruct, 'bootstrapThresholdReductionFactor')
    dvDataStruct.tpsConfigurationStruct.bootstrapThresholdReductionFactor = 2;
end

if ~isfield(dvDataStruct.tpsConfigurationStruct, 'mesHistogramMaxMes')
    dvDataStruct.tpsConfigurationStruct.mesHistogramMaxMes = 20;
end

if ~isfield(dvDataStruct.tpsConfigurationStruct, 'mesHistogramBinSize')
    dvDataStruct.tpsConfigurationStruct.mesHistogramBinSize = 0.2;
end

if ~isfield(dvDataStruct.tpsConfigurationStruct, 'performWeakSecondaryTest' )
    dvDataStruct.tpsConfigurationStruct.performWeakSecondaryTest = true;
end

if ~isfield(dvDataStruct.tpsConfigurationStruct, 'bootstrapGaussianEquivalentThreshold')
    dvDataStruct.tpsConfigurationStruct.bootstrapGaussianEquivalentThreshold = 6.36;
end

if ~isfield(dvDataStruct.tpsConfigurationStruct, 'bootstrapLowMesCutoff')
    dvDataStruct.tpsConfigurationStruct.bootstrapLowMesCutoff = -1;
end

if ~isfield(dvDataStruct.tpsConfigurationStruct, 'noiseEstimationByQuarterEnabled')
    dvDataStruct.tpsConfigurationStruct.noiseEstimationByQuarterEnabled = true;
end

if ~isfield(dvDataStruct.tpsConfigurationStruct, 'positiveOutlierHaircutThreshold')
    dvDataStruct.tpsConfigurationStruct.positiveOutlierHaircutThreshold = 10;
end

% Remove TPS parameter.
if isfield(dvDataStruct.tpsConfigurationStruct, 'sesProbabilityThreshold') 
    dvDataStruct.tpsConfigurationStruct = ...
        rmfield(dvDataStruct.tpsConfigurationStruct, 'sesProbabilityThreshold');
end

% Remove prior instance id.
if isfield(dvDataStruct, 'priorInstanceId')
    dvDataStruct = rmfield(dvDataStruct, 'priorInstanceId');
end

% Remove DV configuration parameter.
if isfield(dvDataStruct.dvConfigurationStruct, 'useHarmonicFreeCorrectedFlux')
    dvDataStruct.dvConfigurationStruct = ...
        rmfield(dvDataStruct.dvConfigurationStruct, 'useHarmonicFreeCorrectedFlux');
end

% Remove planet fit parameters.
if isfield(dvDataStruct.planetFitConfigurationStruct, 'periodSearchWindowWidthDays')
    dvDataStruct.planetFitConfigurationStruct = ...
        rmfield(dvDataStruct.planetFitConfigurationStruct, 'periodSearchWindowWidthDays');
end

if isfield(dvDataStruct.planetFitConfigurationStruct, 'periodSearchMaxSubharmonic')
    dvDataStruct.planetFitConfigurationStruct = ...
        rmfield(dvDataStruct.planetFitConfigurationStruct, 'periodSearchMaxSubharmonic');
end

if isfield(dvDataStruct.planetFitConfigurationStruct, 'minEventStatisticRatio')
    dvDataStruct.planetFitConfigurationStruct = ...
        rmfield(dvDataStruct.planetFitConfigurationStruct, 'minEventStatisticRatio');
end

% Remove harmonic free corrected flux and outliers.
if isfield(dvDataStruct.targetStruct, 'harmonicFreeCorrectedFluxTimeSeries')
    dvDataStruct.targetStruct = ...
        rmfield(dvDataStruct.targetStruct, 'harmonicFreeCorrectedFluxTimeSeries');
end

if isfield(dvDataStruct.targetStruct, 'harmonicFreeOutliers')
    dvDataStruct.targetStruct = ...
        rmfield(dvDataStruct.targetStruct, 'harmonicFreeOutliers');
end

% Remove prior fit results for seeding.
if isfield(dvDataStruct.targetStruct, 'allTransitsFits')
    dvDataStruct.targetStruct = ...
        rmfield(dvDataStruct.targetStruct, 'allTransitsFits');
end

return
