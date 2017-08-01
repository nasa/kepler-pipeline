function calIntermediateStruct = ...
    preallocate_memory_for_calibration(calObject, calIntermediateStruct)
%function calIntermediateStruct = ...
%   preallocate_memory_for_calibration(calObject, calIntermediateStruct)
%
% This calClass method allocates memory for calibration and propagation of uncertainties data that will be computed and collected in CAL.
% All preallocated fields are attached to calIntermediateStruct, which is passed into all subsequent functions along with the calObject.
% The intermediate data structure is saved at the end of CAL to a local matfile for each invocation.
%
% OUTPUT:
%   calIntermediateStruct is a structure with the following fields:
%
% Example for long cadence collateral data:
% calIntermediateStruct = 
%                     missingBlackCadences: 3
%                    missingMsmearCadences: 3
%                    missingVsmearCadences: 3
%                                ccdModule: 14
%                                ccdOutput: 2
%                                dataFlags: [1x1 struct]
%                               pouEnabled: 1
%                                nCadences: 20
%                                 nCcdRows: 1070
%                              nCcdColumns: 1132
%                               debugLevel: 0
%                           blackAvailable: [20x1 logical]
%                                meanBlack: [20x1 double]
%                   meanBlackUncertainties: [20x1 double]
%                   blackUncertaintyStruct: [20x1 struct]
%                 mSmearNonlinearityStruct: [1x1 struct]
%                 vSmearNonlinearityStruct: [1x1 struct]
%                   smearUncertaintyStruct: [20x1 struct]
%                              smearLevels: [1132x20 double]
%                        validSmearColumns: [1132x20 logical]
%             darkCurrentUncertaintyStruct: [20x1 struct]
%                        darkCurrentLevels: [20x1 double]
%                 requantTableFixedOffsets: 419400
%                         blackColumnStart: 1119
%                           blackColumnEnd: 1132
%                           mSmearRowStart: 7
%                             mSmearRowEnd: 18
%                           vSmearRowStart: 1047
%                             vSmearRowEnd: 1058
%                     numberOfBlackColumns: 14
%                  numberOfMaskedSmearRows: 12
%                 numberOfVirtualSmearRows: 12
%                              ccdReadTime: 0.5189
%                          ccdExposureTime: 6.0198
%                        numberOfExposures: 270
%                           readNoiseInADU: 0.7498
%                                     gain: 113.9900
%                  blackRowsToExcludeInFit: [126x1 double]
%         medianResidualDeltaSmearOfColumn: [1132x1 double]
%        CmedianResidualDeltaSmearOfColumn: [1132x1 double]
%     mSmearBleedingColsLogicalSparseArray: [1132x20 logical]
%     vSmearBleedingColsLogicalSparseArray: [1132x20 logical]
%
%
%
% Example for long cadence photometric data:
% 
% calIntermediateStruct = 
%                photometricColumns: [5973x1 double]
%                   photometricRows: [5973x1 double]
%        missingPhotometricCadences: 3
%                         ccdModule: 14
%                         ccdOutput: 2
%                         dataFlags: [1x1 struct]
%                        pouEnabled: 1
%                         nCadences: 20
%                          nCcdRows: 1070
%                       nCcdColumns: 1132
%                        debugLevel: 0
%      photometricUncertaintyStruct: [20x1 struct]
%     photometricNonlinearityStruct: [1x1 struct]
%          requantTableFixedOffsets: 419400
%                       ccdReadTime: 0.5189
%                   ccdExposureTime: 6.0198
%                 numberOfExposures: 270
%                    readNoiseInADU: 0.7498
%                              gain: 113.9900
%                 pixelVariableName: 'calibratedPixels2'
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


% extract data flags and counters
isAvailableBlackPix         = calObject.dataFlags.isAvailableBlackPix;
isAvailableMaskedSmearPix   = calObject.dataFlags.isAvailableMaskedSmearPix;
isAvailableVirtualSmearPix  = calObject.dataFlags.isAvailableVirtualSmearPix;
isAvailableTargetAndBkgPix  = calObject.dataFlags.isAvailableTargetAndBkgPix;
processShortCadence         = calObject.dataFlags.processShortCadence;
dynamic2DBlackEnabled       = calObject.dataFlags.dynamic2DBlackEnabled;

pouEnabled = calObject.pouModuleParametersStruct.pouEnabled;

nCadences = calIntermediateStruct.nCadences;
ccdRows   = calIntermediateStruct.nCcdRows;

%--------------------------------------------------------------------------
% black calibration: allocate memory for metrics and additional fields collected
%--------------------------------------------------------------------------
if isAvailableBlackPix

    % allocate memory to collect available black values per cadence
    calIntermediateStruct.blackAvailable    = true(nCadences, 1);
    calIntermediateStruct.blackCorrection   = zeros(ccdRows,nCadences);
    
    if processShortCadence && dynamic2DBlackEnabled
        calIntermediateStruct.dynablackScBias   = nan(nCadences,1);
        calIntermediateStruct.CdynablackScBias  = nan(nCadences,1);
    else
        calIntermediateStruct.dynablackScBias   = [];
        calIntermediateStruct.CdynablackScBias  = [];
    end

    if pouEnabled
        % initialize fields for black uncertainty structure
        calIntermediateStruct.blackUncertaintyStruct  = repmat(struct(...
            'deltaRawBlack',                zeros(ccdRows, 1), ...
            'deltaRawMblack',               0, ...
            'deltaRawVblack',               0, ...
            'CblackPolyFit',                [], ...
            'bestPolyCoeffts',              [], ...
            'bestBlackPolyOrder',           []), nCadences, 1);
    end
end


%--------------------------------------------------------------------------
% set collateral metrics field for CAL output struct
%--------------------------------------------------------------------------
% set fields to empty for cases in which metrics are unavailable
collateralMetricsEmptyStruct = struct('values', [], 'uncertainties', [], 'gapIndicators', []);

collateralMetrics.blackLevelMetrics     = collateralMetricsEmptyStruct;
collateralMetrics.smearLevelMetrics     = collateralMetricsEmptyStruct;
collateralMetrics.darkCurrentMetrics    = collateralMetricsEmptyStruct;
calIntermediateStruct.collateralMetrics = collateralMetrics;

%--------------------------------------------------------------------------
% set cosmic ray metrics field for CAL output struct
%--------------------------------------------------------------------------
% set fields to empty for cases in which metrics are unavailable
cosmicRayMetricsEmptyStruct = struct('exists', false, ...
    'hitRates', [], 'hitRateGapIndicators', [], ...
    'meanEnergy', [], 'meanEnergyGapIndicators', [], ...
    'energyVariance', [], 'energyVarianceGapIndicators', [], ...
    'energySkewness', [], 'energySkewnessGapIndicators', [], ...
    'energyKurtosis', [], 'energyKurtosisGapIndicators', []);

calIntermediateStruct.blackCosmicRayMetrics         = cosmicRayMetricsEmptyStruct;
calIntermediateStruct.maskedBlackCosmicRayMetrics   = cosmicRayMetricsEmptyStruct;
calIntermediateStruct.virtualBlackCosmicRayMetrics  = cosmicRayMetricsEmptyStruct;
calIntermediateStruct.maskedSmearCosmicRayMetrics   = cosmicRayMetricsEmptyStruct;
calIntermediateStruct.virtualSmearCosmicRayMetrics  = cosmicRayMetricsEmptyStruct;

%--------------------------------------------------------------------------
% set cosmic ray events field for CAL output struct
%--------------------------------------------------------------------------
% if cosmic rays are detected, these will contain structs with fields:
% 'delta', 'rowOrColumn', and 'mjd' for each cosmic ray detected

cosmicRayEvents.black           = [];
cosmicRayEvents.maskedBlack     = [];
cosmicRayEvents.virtualBlack    = [];
cosmicRayEvents.maskedSmear     = [];
cosmicRayEvents.virtualSmear    = [];

calIntermediateStruct.cosmicRayEvents = cosmicRayEvents;

%--------------------------------------------------------------------------
% smear and dark level uncertainty structures: allocate memory
%--------------------------------------------------------------------------
if isAvailableMaskedSmearPix || isAvailableVirtualSmearPix
    if ~pouEnabled
        calIntermediateStruct.smearUncertaintyStruct = repmat(struct(...
            'deltaRawMsmear', [], ...
            'deltaRawVsmear', []), nCadences, 1);
    end
end


%--------------------------------------------------------------------------
% photometric pixel calibration: allocate memory
%--------------------------------------------------------------------------
if isAvailableTargetAndBkgPix
    if ~pouEnabled
        calIntermediateStruct.photometricUncertaintyStruct = repmat(struct(...
            'deltaRawPhotometric', []), nCadences, 1);
    end
end


return;
