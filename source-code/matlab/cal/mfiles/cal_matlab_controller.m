function calOutputStruct = cal_matlab_controller(calInputStruct)
% function calOutputStruct = cal_matlab_controller(calInputStruct)
%
% This function forms the MATLAB side of the calibration (CAL) CSCI interface.
% The following data (long cadence, short cadence, or ffi) are calibrated on
% a per module/output basis:
%
% Long cadence:
%    1st invocation: collateral pixels (black, masked smear, and virtual smear)
%                    are calibrated for all cadences.  The input black columns
%                    and smear rows are coadded values of a subset of collateral
%                    data that are summed onboard the spacecraft.
%
%    2nd through remaining invocations: photometric (target and background)
%                    pixels are calibrated.  Each invocation processes a subset
%                    of photometric pixels chunked by rows (to correct for
%                    lde undershoot).
%
% Short cadence:
%    1st invocation: collateral pixels (black, masked smear, virtual smear,
%                    masked black, and virtual black) are calibrated for all
%                    cadences.  Only the black and smear pixels that lie on the
%                    projection of the short cadence targets are available,
%                    in addition to black pixels that are needed to correct
%                    the smear pixels. The input black columns, smear rows,
%                    and masked/virtual black values are each coadded values
%                    of a subset of collateral data that are summed onboard
%                    the spacecraft.
%
%    2nd through remaining invocations: photometric (target and background)
%                    pixels are calibrated. Each invocation processes a subset of
%                    photometric pixels chunked by cadences since there are
%                    fewer targets but more cadences.
%
% FFI single cadence:
%    1st invocation: collateral pixels (black, masked smear, and virtual smear
%                    2D arrays) are coadded within CAL and processed to estimate
%                    the black and smear levels.
%
%    2nd invocation: the full frame image (all pixels on module/output) are
%                    calibrated similar to a single long cadence with some
%                    exceptions (the FFI pixels are not requantized, for example,
%                    so the mean black and fixed offset corrections are skipped).
%
%
% This function validates the fields of the input structure, converts the
% spatial inputs from JAVA 0-based to MATLAB 1-based indexing, and calls the
% constructor for the calClass.  Each invocation will call either
% calibrate_collateral_data or calibrate_photometric_data.
%
% On the last CAL invocation, the achieved and theoretical compression
% efficiencies are computed, and the special targets for PPA (2D black and
% lde undershoot targets) are calibrated.  The required fields are then converted
% back to 0-based indices prior to output.  If the uncertainties are
% propagated, all information is saved at the end in an output blob.
%
%--------------------------------------------------------------------------
% INPUTS:
%
% calInputStruct: [struct] containing the following fields:
%
%                 version: [string]  version (ex. 'CalInputs Version 5')
%      pipelineInfoStruct: [struct]  contains information about the pipeline version
%              debugLevel: [int]     debug level (= 0 in pipeline)
%               firstCall: [logical] flag to indicate if first CAL invocation
%                lastCall: [logical] flag to indicate if last CAL invocation
%             emptyInputs: [logical] flag to indicate if CAL inputs contain all gapped essential pixel data
%             totalPixels: [int]     total number of pixels to calibrate in all CAL invocations
%             cadenceType: [string]  cadence type 'LONG', 'SHORT', or 'FFI'
%               ccdModule: [int]     module
%               ccdOutput: [int]     output
%     calInvocationNumber: [int]     zero-based invocation number ( 0 == collateral, 1:totalCalInvocations - 2 == photometric, last invocation == metrics )
%     totalCalInvocations: [int]     total number of invocations used for this run of cal
%                  season: [int]     Kepler season for data set [0,1,2,3]
%                 quarter: [int]     Kepler quarter number. Set to -1 if K2 data
%              k2Campaign: [int]     K2 campaign number. Set to -1 if Kepler data
%             fcConstants: [struct] containing focal plane constants
%               gainModel: [struct] containing gain model
%          flatFieldModel: [struct] containing flat field model
%          twoDBlackModel: [struct] containing 2D black model
%          linearityModel: [struct] containing nonlinearity model
%         undershootModel: [struct] containing undershoot model
%          readNoiseModel: [struct] containing read noise model
%     spacecraftConfigMap: [struct] configuration map parameters struct
%           requantTables: [struct] requantization table struct
%           huffmanTables: [struct] huffman table struct
%
%  moduleParametersStruct: [struct] containing the following fields:
%                       .crCorrectionEnabled: [logical] flag to enable cosmic ray correction
%                .linearityCorrectionEnabled: [logical] flag to enable nonlinearity correction
%                .flatFieldCorrectionEnabled: [logical] flag to enable flat field correction
%                         .undershootEnabled: [logical] flag to enable lde undershoot correction
%             .collateralMetricUncertEnabled: [logical] flag to enable/disable calculation of collateral metrics uncertainty
%           .madSigmaThresholdForSmearLevels: [double]  threshold for smear levels to compute metrics (default = 3.5)
%             .undershootReverseFitPolyOrder: [int]     order of robust fit at each cadence for LDE undershoot targets in descending column order to
%                                                       estimate the baseline value of the undershoot step (default = 0 or 1) 
%                .undershootReverseFitWindow: [int]     number of LDE undershoot target pixel values to be fit at each cadence in descending
%                                                       column order (default = 10)  
%                              .polyOrderMax: [int]     maximum polynomial order in fit to the black pixels (default = 10)
%                            .blackAlgorithm: [char]    string indicating which black correction algorithm should be applied to the data
%                                                       'polynomialOneDBlack' == static 2D black + robust polynomial fit to trailing black per cadence
%                                                       'exponentialOneDBlack' == static 2D black + robust custom exponential model fit to
%                                                       trailing black per cadence 
%                                                       'dynablack' == 2D black is produced per cadence from fit to collateral + background
%                                                       + FFIs + reverse clocked 
%                                                       LC data. Reads input as blob produced by DYNABLACK module. 
%         .defaultDarkCurrentElectronsPerSec: [double]  assumed dark current in e-/s used for removing outliers in FFI collateral data
%                 .minCadencesForCompression: [int]     threshold below which SVD compression is not applied to POU struct
%              .nSigmaForFfiOutlierRejection: [double]  threshold in sigma above which outliers are rejected in FFI collateral data
%                     .errorOnCoarsePointFfi: [logical] flag enables FS data quality flag checking for FFI processing. If any FS data quality flags are
%                                                       anomalous the data for the entire cadence (FFI) will be gapped and CAL will throw an error. The
%                                                       FS flags and their nominal states are:
%                                                       isMmntmDmp  = T
%                                                       isFinePnt   = F
%                                                       isSefiAcc   = T
%                                                       isSefiCad   = T
%                                                       isLdeOos    = T
%                                                       isLdeParEr  = T
%                                                       isScrcErr   = T
%                                                       Note: This module parameter used to control the logic for only the
%                                                       isFinePt flag so the name is a bit misleading.
%                              .debugEnabled: [logical] flag to enable debug level
%                         .stdRatioThreshold: [double]  threshold used by dynoblack retrieval function for model order selection based on noise floor
%                         .coefficentModelId: [int]     identifies dynablack model order to use if dynoblackModelAutoSelectEnable = false
%                   .useRobustVerticalCoeffs: [logical] enable use of robust fit model coefficients in the vertical part of dynoblack black retrieval
%                   .useRobustFrameFgsCoeffs: [logical] enable use of robust fit model coefficients in the fgs frame pixels part of dynoblack black retrieval
%                .useRobustParallelFgsCoeffs: [logical] enable use of robust fit model coefficients in the fgs parallel pixels part of dynoblack black retrieval
%             .dynoblackModelAutoSelectEnable: [logical] enable automatic selction of model order based on chi^2 of fit in dynoblack black retrieval
%                    .dynoblackChi2Threshold: [double]  chi square threshold used in automatically determining model order in dynoblack black retrieval
%                       .enableLcInformSmear: [logical] enable use of long cadence smear blob in short cadence smear processing in order to mitigate
%                                                       issues in applying the undershoot filter
%                           .enableFfiInform: [logical] enable use of ffi data in long and short cadence target and background pixel processing to
%                                                       mitigate issues in applying the undershoot filter 
%               .enableCoarsePointProcessing: [logical] enable processing of coarse point data by not gapping cadences where the FS data
%                                                       quality flag isFinePnt = false 
%                        .enableMmntmDmpFlag: [logical] enable gapping of cadences where the FS data quality flag isMmntmDmp = true
%                         .enableSefiAccFlag: [logical] enable gapping of cadences where the FS data quality flag isSefiAcc = true
%                         .enableSefiCadFlag: [logical] enable gapping of cadences where the FS data quality flag isSefiCad = true
%                          .enableLdeOosFlag: [logical] enable gapping of cadences where the FS data quality flag isLdeOos = true
%                        .enableLdeParErFlag: [logical] enable gapping of cadences where the FS data quality flag isLdePar = true
%                         .enableScrcErrFlag: [logical] enable gapping of cadences where the FS data quality flag isScrcErr = true
%               .enableSmearExcludeColumnMap: [logical] enable use of bleeding columns map stored in get_masked_smear_columns_to_exclude.m
%                                                       and get_virtual_smear_columns_to_exclude.m 
%                .enableSceneDependentRowMap: [logical] enable use of scene dependent row map stored in scene_dependent_rows.m
%           .enableBlackCoefficientOverrides: [logical] enable use of 1D black coefficeint overrides stored in load_coeff_overrides_table.m
%                   .enableExcludeIndicators: [logical] enable gapping of cadences with excludeIndicators = true
%                     .enableExcludePreserve: [logical] preserve (ungap) cadences with excludeIndicators = true for all CAL operations
%                                                       except cosmic ray cleaning and POU 
%                .enableDbDataQualityGapping: [logical] apply CAL enhanced data gapping scheme to Dynablack reads based on s/c data quality flags and
%                                                       data anomaly flags per CAL enable flags
%
%  cosmicRayParametersStruct: [struct] containing the following fields:
%                              .detrendOrder: [int]     (default = 2)
%                        .medianFilterLength: [int]     (default = 5)
%                              .madThreshold: [double]  (default = 12)
%      .thresholdMultiplierForNegativeEvents: [double]  (default = 2)
%       .consecutiveCosmicRayCleaningEnabled: [logical] (default = false)
%          .twoSidedFinalThresholdingEnabled: [logical] (default = false)
%                           .madWindowLength: [int]     (default = 145)
%
% harmonicsIdentificationConfigurationStruct: [struct] containing the following fields:
%    .falseDetectionProbabilityForTimeSeries: [double] (default = 0.0010)
%                     .maxHarmonicComponents: [int]    (default = 25)
% .medianWindowLengthForPeriodogramSmoothing: [int]    (default = 47)
%  .medianWindowLengthForTimeSeriesSmoothing: [int]    (default = 21)
%               .minHarmonicSeparationInBins: [int]    (default = 25)
%                 .movingAverageWindowLength: [int]    (default = 47)
%               .retainFrequencyCombsEnabled: [logical](default = false)
%                          .timeOutInMinutes: [double] (default = 2.5000)
% 
%  pouModuleParametersStruct: [struct] containing the following fields:
%                                .pouEnabled: [logical] flag to enable full propagation of uncertainties (pou)(default = true)
%                        .compressionEnabled: [logical] flag to enable pou compression (default = true)
%                          .numErrorPropVars: [int] maximum expected number of variable names to track in errorPropStruct (default = 30)
%                               .maxSvdOrder: [int] maximum order of SVD compression. All SVD compressions in CAL are compressed to the order which
%                                             produces the minimum Akaike Information Criterion metric or pouMaxSVDorder, whichever is less.  (default = 10)
%                            .pixelChunkSize: [int] number of pixels used to propagate errors due to memory constraints (default = 2500)
%                          .cadenceChunkSize: [int] number of cadences used to propagate errors due to memory constraints (default = 1)
%                          .interpDecimation: [int] the number of days between POU computations that have interpolated values (default = 24)
%                              .interpMethod: [char] interpolation method applied between POU computations (default = 'linear')
%
%            cadenceTimes: [struct]  containing the following fields:
%                       .startTimestamps: [nCadencesx1 double] timestamp (MJD) at beginning of each ungapped cadence (0 for gapped cadences)
%                         .midTimestamps: [nCadencesx1 double] timestamp (MJD) at middle of each ungapped cadence (0 for gapped cadences)
%                         .endTimestamps: [nCadencesx1 double] timestamp (MJD) at end of each ungapped cadence (0 for gapped cadences)
%                         .gapIndicators: [nCadencesx1 logical] gapped cadence flags
%                        .requantEnabled: [nCadencesx1 logical] per cadence flag to indicate whether or not requantization was enabled
%
%      targetAndBkgPixels: [1 x nPixels struct] containing the following fields:
%                   *only non-empty for photometric invocations
%                                   .row: [int] pixel row (0-based)
%                                .column: [int] pixel column (0-based)
%                                .values: [nCadencesx1 double] pixel flux values
%                         .gapIndicators: [nCadencesx1 logical] temporal data gap flags
%
%            twoDBlackIds: [1xnTargets struct] containing the following fields:
%                              .keplerId: kepler ID of target
%                                  .rows: [nPixelsInTargetx1 double] rows of target pixels (0-based)
%                                  .cols: [nPixelsInTargetx1 double] columns of target pixels (0-based)
%
%        ldeUndershootIds: [1xnTargets struct] containing the following fields:
%                              .keplerId: [int] kepler ID of target
%                                  .rows: [nPixelsInTargetx1 double] rows of target pixels (0-based)
%                                  .cols: [nPixelsInTargetx1 double] columns of target pixels (0-based)
%
%       maskedSmearPixels: [1xnPixels struct] containing the following fields:
%                   *only non-empty for collateral
%                                .column: [int] pixel column (0-based)
%                                .values: [nCadencesx1 double] pixel flux values
%                         .gapIndicators: [nCadencesx1 logical] temporal data gap flags
%
%      virtualSmearPixels: [1xnPixels struct] containing the following fields:
%                   *only non-empty for collateral
%                                .column: [int] pixel column (0-based)
%                                .values: [nCadencesx1 double] pixel flux values
%                         .gapIndicators: [nCadencesx1 logical]  temporal data gap flags
%
%             blackPixels: [1xnPixels struct] containing the following fields:
%                   *only non-empty for collateral
%                                   .row: [int] pixel row (0-based)
%                                .values: [nCadencesx1 double] pixel flux values
%                         .gapIndicators: [nCadencesx1 logical]  temporal data gap flags
%
%       maskedBlackPixels: [struct] containing the following fields:
%                   *only non-empty for short cadence collateral
%                                .values: [nCadencesx1 double] value (per cadence) of summed pixels in the overlapping black and masked
%                                           smear region of the CCD.  The pixels in this sum are determined by the black columns and masked
%                                           smear rows that were spatially coadded onboard the spacecraft to yield the CAL input black
%                                           column and masked smear row
%                         .gapIndicators: [nCadencesx1 logical] temporal data gap flags
%
%      virtualBlackPixels: [struct] containing the following fields:
%                   *only non-empty for short cadence collateral
%                                .values: [nCadencesx1 double] value (per cadence) of summed pixels in the overlapping black and virtual
%                                           smear region of the CCD. The pixels in this sum are determined by the black columns and virtual
%                                           smear rows that were spatially coadded onboard the spacecraft to yield the CAL input black
%                                           column and virtual smear row 
%                         .gapIndicators: [nCadencesx1 logical]  temporal data gap flags
%
%          twoDCollateral: [struct] containing the following fields:
%                   *only non-empty for FFI single cadence
%                           .blackStruct: [struct] 
%                    .virtualSmearStruct: [struct]
%                     .maskedSmearStruct: [struct]
%
%          oneDBlackBlobs: [struct] containing the following fields:
%                           .blobIndices: [nCadencesx1 double]
%                         .gapIndicators: [nCadencesx1 logical]
%                         .blobFilenames: [nBlobfilesx1 char]
%                          .startCadence: [int]
%                            .endCadence: [int]
%
%     dynamic2DBlackBlobs: [struct] containing the following fields:
%                           .blobIndices: [nCadencesx1 double]
%                         .gapIndicators: [nCadencesx1 logical]
%                         .blobFilenames: [nBlobfilesx1 char]
%                          .startCadence: [int]
%                            .endCadence: [int]
%
%              smearBlobs: [struct] containing the following fields:
%                           .blobIndices: [nCadencesx1 double]
%                         .gapIndicators: [nCadencesx1 logical]
%                         .blobFilenames: [nBlobfilesx1 char]
%                          .startCadence: [int]
%                            .endCadence: [int]
%
%                    ffis: [1xnFfi struct array] containing the following fields:
%                              .fileName: [char array]
%                        .startTimestamp: [double]
%                          .midTimestamp: [double]
%                          .endTimestamp: [double]
%                    .absoluteRowNumbers: [1xnRows double array]
%                                 .image: [1xnRows struct array]
%
%--------------------------------------------------------------------------
% OUTPUTS:
%
% calOutputStruct: [struct] containing the following fields:
%             pipelineInfoStruct: [struct] contains information about the pipeline version. Copied from calInputStruct
%        uncertaintyBlobFileName: [char] name of MATLAB .mat file (e.g. 'errorPropStruct.mat')
%           oneDBlackFitFilename: [char] name of MATLAB .mat file containing two-exponential fit to long cadence black collateral data
%              smearBlobFilename: [char] name of MATLAB .mat file containing pre-undershoot corrected long cadence smear pixels                                       
%          blackAlgorithmApplied: [char] name of black correction algorithm applied to all data in this unit of work. Allowed strings are
%                                           {'polynomialOneDBlack', 'exponentialOneDBlack', 'dynablack'} as they are defined in the inputs comments. 
%             dynablackCoeffType: [char] Indicates source of coefficients used when retrieving the blacks when blackAlgorithm = 'dynablack'.
%                                           Either 'robust' (for coefficients produced by robustfit) or 'regress' (for coefficients produced
%                                           by the non-robust function regress). If blackAlgorithm <> 'dynablack' this field will be empty.
%
%     calibratedCollateralPixels: [struct] containing the following fields:
%                         .blackResidual: [1xnPixels struct] with the following fields:
%                                    .values: [nCadencesx1 double]  black-corrected black pixel values
%                             .uncertainties: [nCadencesx1 double]  propagated uncertainties
%                             .gapIndicators: [nCadencesx1 logical] temporal data gap flags
%                                       .row: [int]                 pixel row (0-based)
%
%                    .maskedBlackResidual: [struct] containing the following fields:
%                                    .exists: [logical] flag to indicate if masked black pixels are available
%                                    .values: [nCadencesx1 double]  black-corrected masked black pixel values
%                             .uncertainties: [nCadencesx1 double]  propagated uncertainties
%                             .gapIndicators: [nCadencesx1 logical] temporal data gap flags
%
%                   .virtualBlackResidual: [struct] containing the following fields:
%                                    .exists:[logical] flag to indicate if virtual black pixels are available
%                                    .values:[nCadencesx1 double]   black-corrected virtual black pixel values
%                             .uncertainties:[nCadencesx1 double]   propagated uncertainties
%                             .gapIndicators:[nCadencesx1 logical]  temporal data gap flags
%
%                            .maskedSmear: [1xnPixels struct] containing the following fields:
%                                    .values: [nCadencesx1 double]  black-corrected masked smear pixel values (may also be corrected for
%                                                                   linearity and undershoot)
%                             .uncertainties: [nCadencesx1 double]  propagated uncertainties
%                             .gapIndicators: [nCadencesx1 logical] temporal data gap flags
%                                    .column: [int]                 pixel column (0-based)
%
%                          .virtualSmear: [1xnPixels struct] containing the following fields:
%                                    .values: [nCadencesx1 double]  black-corrected virtual smear pixel values (may also be corrected for
%                                                                   linearity and undershoot)  
%                             .uncertainties: [nCadencesx1 double]  propagated uncertainties
%                             .gapIndicators: [nCadencesx1 logical] temporal data gap flags
%                                    .column: [int]                 pixel column (0-based)
%
%      targetAndBackgroundPixels: [1xnPixels struct] containing the following fields:
%                                    .values: [nCadencesx1 double]  calibrated photometric pixel values
%                             .gapIndicators: [nCadencesx1 logical] temporal data gap flags
%                             .uncertainties: [nCadencesx1 double]  uncertainties in calibrated photometric pixel values
%                                    .column: [int]                 pixel row (0-based)
%                                       .row: [int]                 pixel column (0-based)
%
%                cosmicRayEvents: [struct] containing the following fields:
%                                     .black: [1xnEvents struct]
%                               .maskedBlack: [1xnEvents struct]
%                              .virtualBlack: [1xnEvents struct]
%                               .maskedSmear: [1xnEvents struct]
%                              .virtualSmear: [1xnEvents struct]
%                               These five 2nd level fields all have the same 3rd level fields:
%                                           .delta: [double]  cosmic ray pixel flux value
%                                     .rowOrColumn: [int]     row or column of collateral pixel (0-based)
%                                             .mjd: [double]  timestamp of cosmic ray hit
%
%               cosmicRayMetrics: [struct] containing the following fields:
%                     .blackCosmicRayMetrics: [struct]
%               .maskedBlackCosmicRayMetrics: [struct]
%              .virtualBlackCosmicRayMetrics: [struct]
%               .maskedSmearCosmicRayMetrics: [struct]
%              .virtualSmearCosmicRayMetrics: [struct]
%                               These five 2nd level fields have the same 3rd level fields:
%                                          .exists: [logical]
%                                        .hitRates: [nCadencesx1 double]
%                            .hitRateGapIndicators: [nCadencesx1 logical]
%                                      .meanEnergy: [nCadencesx1 double]
%                         .meanEnergyGapIndicators: [nCadencesx1 logical]
%                                  .energyVariance: [nCadencesx1 double]
%                     .energyVarianceGapIndicators: [nCadencesx1 logical]
%                                  .energySkewness: [nCadencesx1 double]
%                     .energySkewnessGapIndicators: [nCadencesx1 logical]
%                                  .energyKurtosis: [nCadencesx1 double]
%                     .energyKurtosisGapIndicators: [nCadencesx1 logical]
%
%              collateralMetrics: [struct] containing the following fields:
%                         .blackLevelMetrics: [struct]
%                         .smearLevelMetrics: [struct]
%                        .darkCurrentMetrics: [struct]%
%                               These three 2nd level fields have the same 3rd level fields:%
%                                          .values: [nCadencesx1 double]    metric time series
%                                   .gapIndicators: [nCadencesx1 logical]   temporal data gap flags
%                                   .uncertainties: [nCadencesx1 double]    uncertainties in metric time series
%
% theoreticalCompressionEfficiency: [struct] with the following fields:
%                               .values: [double array]      entropy time series
%                        .gapIndicators: [logical array]    temporal data gap flags
%                         .nCodeSymbols: [double array]      number of coded symbols
%
%    achievedCompressionEfficiency: [struct] with the following fields:
%                               .values: [double array]     achieved compression time series
%                        .gapIndicators: [logical array]    temporal data gap flags
%                         .nCodeSymbols: [double array]     number of coded symbols
%
%             ldeUndershootMetrics: [struct] with the following fields:
%                               .values: [double array]     metric time series
%                        .uncertainties: [double array]     uncertainties in metric time series
%                        .gapIndicators: [logical array]    temporal data gap flags
%                             .keplerId: [int]              Kepler target ID
%
%                 twoDBlackMetrics: [struct] with the following fields:
%                               .values: [double array]     metric time series
%                        .uncertainties: [double array]     uncertainties in metric time series
%                        .gapIndicators: [logical array]    temporal data gap flags
%                             .keplerId: [int]              Kepler target ID
%
%--------------------------------------------------------------------------
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

% state files sit in the super task directory
stateFilePath = char(get_cwd_parent);

% add file separator to path (expected in save function calls)
stateFilePath = [stateFilePath,filesep];

% convert legacy inputs if running in development
import gov.nasa.kepler.common.KeplerSocBranch; 
if ~KeplerSocBranch.isRelease()
    calInputStruct = cal_convert_93_data_to_94(calInputStruct);
end

% hard coded filename roots (pre invocation tag)
compressionStateRootFilename    = 'cal_comp_eff_state'; 
metricsStateRootFilename        = 'cal_metrics_state'; 
pouRootFilename                 = 'cal_pou_state';
pouBlobFilename                 = 'cal_pou_blob.mat';
oneDBlackFitFilename            = 'cal_lc_1D_black_fit.mat';
smearBlobFilename               = 'cal_lc_smear_correction.mat';
dynoblackModelsFilename         = 'dynoblack_models.mat';
backupTag                       = '.backup';


% extract flags from inputsStruct
firstCall = calInputStruct.firstCall;
lastCall = calInputStruct.lastCall;
emptyInputs = calInputStruct.emptyInputs;

% add dataFlags structure to calInputsStruct
[calInputStruct] = add_cal_data_flags(calInputStruct);

% create all gapped output struct if inputs are flagged as empty
if emptyInputs
    calOutputStruct = set_all_gapped_outputs(calInputStruct);
    return;
end


% ~~~~~~~~~~~~~ manage local files
% make local filenames block
invocation = calInputStruct.calInvocationNumber;
localFilenames = struct('calCompEffFilename',       [compressionStateRootFilename,'.mat'],...
                        'compRootFilename',         compressionStateRootFilename,...
                        'metricsRootFilename',      metricsStateRootFilename,...
                        'invocationCompFilename',   [compressionStateRootFilename,'_',num2str(invocation),'.mat'],...
                        'calMetricsFilename',       [metricsStateRootFilename,'.mat'],...
                        'invocationMetricsFilename',[metricsStateRootFilename,'_',num2str(invocation),'.mat'],...
                        'pouBlobFilename',          pouBlobFilename,...
                        'pouRootFilename',          pouRootFilename,...
                        'oneDBlackFitFilename',     oneDBlackFitFilename,...
                        'smearBlobFilename',        smearBlobFilename,...
                        'dynoblackModelsFilename',  dynoblackModelsFilename,...
                        'backupTag',                backupTag,...                             
                        'stateFilePath',            stateFilePath); 

% attach to inputsStruct
calInputStruct.localFilenames = localFilenames;

% load blobs
[calInputStruct] = load_cal_blobs(calInputStruct); 
display_memory(whos);


% ~~~~~~~~~~~~~ prepare input
% pre-process FFI data if this is cadenceType = 'ffi'
[calInputStruct] = coadd_ffi_collateral_data(calInputStruct);    

% validate inputs
[calInputStruct] = validate_cal_inputs(calInputStruct);
display_memory(whos);

% set up POU structure (Propagation Of Uncertainties) 
[calInputStruct, calTransformStruct, compressedData] = initialize_cal_pou_struct(calInputStruct);
display_memory(whos);

% convert row/column indices from (Java) 0-based to (Matlab) 1-based
[calInputStruct] = convert_cal_inputs_to_1_base(calInputStruct);
display_memory(whos);

% instantiate the calClass object from inputsStruct
calObject = calClass(calInputStruct);
clear calInputStruct
display_memory(whos);


% ~~~~~~~~~~~~~ calibrate pixel data
% initialize empty black and smear correction structs
blackCorrectionStructLC = [];
smearCorrectionStructLC = [];

if firstCall
    % calibrate collateral pixels
    [calOutputStruct, calTransformStruct, blackCorrectionStructLC, smearCorrectionStructLC] = ...
        calibrate_collateral_data(calObject, calTransformStruct);
else
    % calibrate photometric pixels
    [calOutputStruct, calTransformStruct] = calibrate_photometric_data(calObject, calTransformStruct);    
end

display('CAL:cal_matlab_controller: Pixel calibration complete');
display_memory(whos);


% ~~~~~~~~~~~~~ prepare output
% create calibrated full frame image if processing FFIs
create_cal_ffi_image(calObject, calOutputStruct);

% pack the pixel time series
cal_pack_pixel_time_series(calObject);
display_memory(whos);

% compute compression efficiency
[calOutputStruct] = compute_compression_efficiency(calObject, calOutputStruct);
display_memory(whos);

% perform propagation of uncertainties (POU) for calibrated pixels
[calOutputStruct, calTransformStruct, compressedData ] = update_uncertainties_in_cal_outputs(calObject, calOutputStruct, calTransformStruct, compressedData);
display_memory(whos);

% write pou and black blobs if avaliable
[calOutputStruct] = write_cal_blobs(calObject, calOutputStruct, blackCorrectionStructLC, smearCorrectionStructLC, calTransformStruct, compressedData);
display_memory(whos);

% save the calibrated pixel time series for 2D black and lde undershoot targets for computation of metrics
cal_save_calibrated_time_series(calObject, calOutputStruct);
display_memory(whos);

% compute the 2D black and lde undershoot metrics
[calOutputStruct] = compute_two_d_black_and_undershoot_metrics(calObject, calOutputStruct);
display_memory(whos);

% convert row/column outputs from (matlab) 1-based to (java) 0-based
[calOutputStruct] = convert_cal_outputs_to_0_base(calOutputStruct);
display_memory(whos);

% ~~~~~~~~~~~~~ manage figures and state files
% move figures
move_figs_to_figures_directory( localFilenames );

% clean up stale invocation state files on last call
if lastCall
    remove_invocation_state_files( localFilenames );
end
