function [dvDataStruct, usedDefaultValuesStruct] = ...
validate_dv_inputs(dvDataStruct)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [dvDataStruct, usedDefaultValuesStruct] = ...
% validate_dv_inputs(dvDataStruct)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% This function first checks for the presence of expected fields in the input
% structure and then checks whether each parameter is within the appropriate
% range. Once the validation of the inputs is complete, the class
% constructor for the dvDataClass may be called to instantiate a DV class
% object.
%
% Comments: This function generates an error under the following scenarios:
%
%          (1) when invoked with no inputs
%          (2) when any of the fields are missing
%          (3) when any of the fields are NaNs/Infs or outside the
%              appropriate bounds
%
% Note that the dvDataStruct input to this function is slightly different
% than that which is input to the dv_matlab_controller. Input blobs have
% been converted for each target table to polynomial structure arrays
% before this function is invoked and appended to the targetTableDataStuct:
%
%    motionBlobs -> motionPolyStruct
%
% The prfModelFileNames listing the PRF model SDF files have been converted
% to standard Pipeline PRF models.
%
%    prfModelFileNames -> prfModels
%
% New fields 'originalQuarters' and 'originalLcTargetTableIds' have been
% appended to the dvCadenceTimesStructure for calls to TPS.
%
% Furthermore, local Matlab file names have been appended at the top level
% to the dvDataStruct. These are not validated. Empty centroid time series
% vectors have also been gapped in accordance with pipeline CSCI
% conventions.
%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% INPUT:  A data structure 'dvDataStruct' with the following fields:
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%   Top level
%
%     dvDataStruct contains the following fields:
%
%                        skyGroupId: [int]  sky group identifier for planet
%                                           candidates
%                    fcConstants: [struct]  Fc constants
%               configMaps: [struct array]  one or more spacecraft config maps
%                 raDec2PixModel: [struct]  model to support conversion between
%                                           celestial and CCD coordinates
%        prfModelFileNames: [string array]  pixel response function model SDF file
%                                           names for given skgroup and UOW
%                 dvCadenceTimes: [struct]  cadence times and gap indicators
%          dvConfigurationStruct: [struct]  module parameters for DV science
%    fluxTypeConfigurationStruct: [string]  flux type for DV
%   planetFitConfigurationStruct: [struct]  module parameters for whitening/planet
%                                           fitting
%       trapezoidalFitConfigurationStruct:
%                                 [struct]  module parameters for trapezoidal fit
%         centroidTestConfigurationStruct:
%                                 [struct]  module parameters used by the
%                                           centroid test
%     pixelCorrelationConfigurationStruct:
%                                 [struct]  module parameters for the pixel
%                                           correlation test
%      differenceImageConfigurationStruct:
%                                 [struct]  module parameters for difference image
%                                           generation
%   bootstrapConfigurationStruct: [struct]  module parameters for statistical bootstrap
% ancillaryEngineeringConfigurationStruct:
%                                 [struct]  module parameters for engineering data
%    ancillaryPipelineConfigurationStruct:
%                                 [struct]  module parameters for pipeline data
% ancillaryDesignMatrixConfigurationStruct:
%                                 [struct]  module parameters for filtering ancillary
%                                           design matrix
%     gapFillConfigurationStruct: [struct]  gap fill parameters
%         pdcConfigurationStruct: [struct]  PDC module parameters
%    saturationSegmentConfigurationStruct:
%                                 [struct]  saturation segment identification parameters
% tpsHarmonicsIdentificationConfigurationStruct:
%                                 [struct]  TPS harmonics identification parameters
% pdcHarmonicsIdentificationConfigurationStruct:
%                                 [struct]  PDC harmonics identification parameters
%         tpsConfigurationStruct: [struct]  TPS module parameters
%        ancillaryEngineeringDataFileName:
%                                 [string]  ancillary engineering data SDF file
%    targetTableDataStruct: [struct array]  non-target data by target table 
%                                           for UOW
%             targetStruct: [struct array]  target characteristics, time series
%                                           and transit candidates
%                     kics: [struct array]  KIC fields for targets in task or skygroup
%               softwareRevision: [string]  software revision URL
%        transitParameterModelDescription:
%                                 [string]  cumulative KOI specification
%             transitNameModelDescription:
%                                 [string]  KOI/Kepler-name association
%    externalTceModelDescription: [string]  specification for extra-pipeline TCEs
%      transitInjectionParametersFileName:
%                                 [string]  name of file with pixel level transit
%                                           injection metadata
%                   taskTimeoutSecs: [int]  number of seconds for full task
%
%--------------------------------------------------------------------------
%   Second level
%
%     dvCadenceTimes is a struct with the following fields:
%
%          startTimestamps: [double array]  cadence start times, MJD
%            midTimestamps: [double array]  cadence mid times, MJD
%            endTimestamps: [double array]  cadence end times, MJD
%           gapIndicators: [logical array]  true if cadence is unavailable
%          requantEnabled: [logical array]  true if requantization was enabled
%              cadenceNumbers: [int array]  absolute cadence numbers
%                    quarters: [int array]  index of observing quarter for
%                                           each cadence
%            lcTargetTableIds: [int array]  long cadence target table ID for
%                                           each cadence
%            scTargetTableIds: [int array]  short cadence target table ID for
%                                           each cadence
%               isSefiAcc: [logical array]  not used in pipeline
%               isSefiCad: [logical array]  not used in pipeline
%                isLdeOos: [logical array]  not used in pipeline
%               isFinePnt: [logical array]  true if on fine point for cadence
%              isMmntmDmp: [logical array]  true if desat on cadence
%              isLdeParEr: [logical array]  not used in pipeline
%               isScrcErr: [logical array]  not used in pipeline
%               dataAnomalyFlags: [struct]  anomaly indicators per cadence
%
%--------------------------------------------------------------------------
%   Second level
%
%     dvConfigurationStruct is a struct with the following fields:
%
%                        debugLevel: [int]  level for science debug
%               modelFitEnabled: [logical]  if true, perform iterative whitening
%                                           and model fitting
%   multiplePlanetSearchEnabled: [logical]  if true, search for additional
%                                           planets per target is enabled
%      weakSecondaryTestEnabled: [logical]  if true, generate and display weak
%                                           secondary diagnostics
%        differenceImageGenerationEnabled:
%                                [logical]  if true, generate difference images
%          centroidTestsEnabled: [logical]  if true, perform centroid tests
%   ghostDiagnosticTestsEnabled: [logical]  if true, perform ghost diagnostic tests
%  pixelCorrelationTestsEnabled: [logical]  if true, perform pixel correlation tests
%        binaryDiscriminationTestsEnabled:  
%                                [logical]  if true, perform consistency tests
%                                           for odd/even and single transits
%              bootstrapEnabled: [logical]  if true, bootstrap is enabled to
%                                           assess TCE significance
% rollingBandDiagnosticsEnabled: [logical]  if true, rolling band contamination reporting
%                                           is enabled
%                 reportEnabled: [logical]  if true, DV report is generated
%            koiMatchingEnabled: [logical]  if true, perform matching against KOI ID's
%                                           and ephemerides
%            koiMatchingThreshold: [float]  correlation threshold for KOI matching
%           externalTcesEnabled: [logical]  if true, TCEs are specified by external file
%                                           and not by TPS
%      simulatedTransitsEnabled: [logical]  if true, inject transits at pixel level
%      exceptionCatchingEnabled: [logical]  if true, catch exceptions in diagnostic tests    
%               transitModelName: [string]  name of transit model
%         limbDarkeningModelName: [string]  name of limb darkening model
%            maxCandidatesPerTarget: [int]  iteration limit for multi-planet search
%                     team: [string array]  SOC roster
%
%--------------------------------------------------------------------------
%   Second level
%
%     fluxTypeConfigurationStruct is a struct with the following fields:
%
%                       fluxType: [string]  flux type, i.e. 'SAP', 'OAP', 'DIA'
%
%--------------------------------------------------------------------------
%   Second level
%
%     planetFitConfigurationStruct is a struct with the following fields:
%
%          transitSamplesPerCadence: [int]  number of time samples per cadence for
%                                           the transit signal generator
%                 smallBodyCutoff: [float]  max Rp/R* for which small body
%                                           approximation is applied
%      tightParameterConvergenceTolerance:
%                                  [float]  tolerance for halting iterative
%                                           whitening/planet model fits
%      looseParameterConvergenceTolerance:
%                                  [float]  tolerance for halting iterative
%                                           whitening/planet model fits
% tightSecondaryParameterConvergenceTolerance:
%                                  [float]  "good enough" tolerance for accepting
%                                           iterative whitening/planet model fits
% looseSecondaryParameterConvergenceTolerance:
%                                  [float]  "good enough" tolerance for accepting
%                                           iterative whitening/planet model fits
%   chiSquareConvergenceTolerance: [float]  tolerance for halting iterative
%                                           whitening/planet model fits
%       whitenerFitterMaxIterations: [int]  iteration limit for whitening/fitting
%             cotrendingEnabled: [logical]  if true, use cotrending in planet fit
%              robustFitEnabled: [logical]  if true, use robust planet fit
%         saveTimeSeriesEnabled: [logical]  if true, save per cadence time series with
%                                           other convergence diagnostics
%   reducedParameterFitsEnabled: [logical]  if true, perform 4-parameter model fits with
%                                           fixed impact parameters
%          impactParametersForReducedFits:
%                            [float array]  fixed impact parameters for 4-parameter fits
%    trapezoidalModelFitEnabled: [logical]  if true, perform trapezoidal model fit
%                          tolFun: [float]  lmfit convergence tolerance on
%                                           change in chisq
%                            tolX: [float]  lmfit convergence tolerance on
%                                           change in fit parameters
%                        tolSigma: [float]  nlinfit convergence tolerance on
%                                           parameter values
%             transitBufferCadences: [int]  padding on each side of transits
%    transitEpochStepSizeCadences: [float]  step size for fit
%  planetRadiusStepSizeEarthRadii: [float]  step size for fit
%   ratioPlanetRadiusToStarRadiusStepSize:
%                                  [float]  step size for fit
%         semiMajorAxisStepSizeAu: [float]  step size for fit
%  ratioSemiMajorAxisToStarRadiusStepSize:
%                                  [float]  step size for fit
%      minImpactParameterStepSize: [float]  step size for fit
%       orbitalPeriodStepSizeDays: [float]  step size for fit
%        fitterTransitRemovalMethod: [int]  subtract (0) or gap (1) for iterative whitener
%      fitterTransitRemovalBufferTransits:
%                                  [float]  additional cadence range for gapping, in units of
%                                           transit durations
% subtractModelTransitRemovalMethod: [int]  subtract (0) or gap (1) for multiple planet search
% subtractModelTransitRemovalBufferTransits:
%                                  [float]  additional cadence range for gapping, in units of
%                                           transit durations
%    eclipsingBinaryDepthLimitPpm: [float]  minimum transit depth for gapping
%                                           eclipsing binaries, ppm
% eclipsingBinaryAspectRatioLimitCadences:
%                                  [float]  aspect ratio limit for gapping
%                                           eclipsing binaries, cadences
% eclipsingBinaryAspectRatioDepthLimitPpm:
%                                  [float]  aspect ratio depth limit for gapping
%                                           eclipsing binaries, ppm
% giantTransitDetectionThresholdScaleFactor:
%                                  [float]  scale factor for giant transit detection
%                                           threshold
%           fitterTimeoutFraction: [float]  fraction of DV time per target allocated
%                                           to fitter
%             impactParameterSeed: [float]  initial impact parameter estimate for
%                                           5-parameter model fit
%   iterationToFreezeCadencesForFit: [int]  fitter iteration to identify cadences for model fit
%                   defaultRadius: [float]  default value to use for target's radius
%                                           if KIC value is empty or NaN, in units
%                                           of Solar radii
%              defaultEffectiveTemp: [int]  default value to use for target's effective
%                                           temperature if KIC value is
%                                           empty or missing, in units of Kelvin                                         
%      defaultLog10SurfaceGravity: [float]  default value to use for the target's
%                                           log10 surface gravity if KIC value is empty
%                                           or missing, in units cm/s^2
%         defaultLog10Metallicity: [float]  default value to use for the target's
%                                           log10 metallicity if KIC value is empty or missing,
%                                           in units [Fe/H] relative to solar value
%                   defaultAlbedo: [float]  albedo for estimation of equilibrium temperature
%                                           for each planet candidate, dimensionless
%       transitDurationMultiplier: [float]  multiplier to determine median filter length
%                                           for detrending
%   robustWeightThresholdForPlots: [float]  robust weight threshold for color coding
%      reportSummaryClippingLevel: [float]  vertical limits for display of detrended and
%                                           folded light curves, units of sigma
%     reportSummaryBinsPerTransit: [float]  number of bins per transit duration for
%                                           binning and averaging
%      deemphasisWeightsEnabled: [logical]  if true, deemphasize anomalous cadences for
%                                           model fitting
%
%--------------------------------------------------------------------------
%   Second level
%
%     trapezoidalFitConfigurationStruct is a struct with the following fields:
%
%       defaultSmoothingParameter: [float]  default value of the smoothing parameter
%               filterCircularShift: [int]  number of circular shifts to determine smoothing parameter
%                      gapThreshold: [int]  threshold of gap duration to determine segments for
%                                           separate detrending
%                medianFilterLength: [int]  length of median filter for detrending in cadences
%                    snrThreshold: [float]  threshold of SNR to update detrending
%                transitFitRegion: [float]  region of data to be used for the trapezoidal fit,
%                                           units of transit duration
%          transitSamplesPerCadence: [int]  number of time samples per cadence for
%                                           the trapezoidal model light curve generator
%
%--------------------------------------------------------------------------
%   Second level
%
%   centroidTestConfigurationStruct is a struct with the following fields:
%
%       centroidModelFineMeshFactor: [int]  number of sub-cadence divisions used for
%                                           model plotting
%      iterativeWhitenerTolerance: [float]  fractional convergence tolerance for
%                                           iterative whitener
%                    iterationLimit: [int]  iteration limit for iterative whitener 
%                padTransitCadences: [int]  cadences to pad duration on each side to
%                                           determine in-transit boolean
%            minimumPointsPerPlanet: [int]  number for points required in and out of
%                                           transit in whitener robust fits
%    maximumTransitDurationCadences: [int]  default median filter length (should be odd)
%  centroidModelFineMeshEnabled: [logical]  true == enable modelgeneration at sub-cadence
%                                           time stamps for plottting 
%          transitDurationsMasked: [float]  when plotting iPlanet, mask transits for
%                                           planet <> iPlanet 
%    transitDurationFactorForMedianFilter:
%                                  [float]  median filter length set to factor *
%                                           longest duration transit
% defaultMaxTransitDurationCadences: [int]  used for median filtering in cloud plots 
%          madsToClipForCloudPlot: [float]  one sided outlier rejection in cloud plots
%     foldedTransitDurationsShown: [float]  number of transit durations to show on folded
%                                           centroid plots
%      plotOutlierThesholdInSigma: [float]  outlier rejection threshold for plots
%                cloudPlotRaMarker: [char]  MATLAB marker string for cloud  RA
%                                           (i.e. '+s' plots black squares)
%               cloudPlotDecMarker: [char]  MATLAB marker and color string for cloud DEC
%                                           (i.e. 'or' plots red circles)
%  maximumSourceRaDecOffsetArcsec: [float]  outlier rejection for background source 1 pixel == 4 arcsec,
%                                           so 100 arc-sec is about 25 pixels
%             chiSquaredTolerance: [float]  alternative convergence criterion for whitener
%           timeoutPerTargetSeconds: [int]  maximum run time per target
%
%--------------------------------------------------------------------------
%   Second level
%
%   pixelCorrelationConfigurationStruct is a struct with the following fields:
%
%      iterativeWhitenerTolerance: [float]  fractional tolerance for iterative whitener convergence
%                    iterationLimit: [int]  iteration limit for iterative whitener
%           significanceThreshold: [float]  threshold for marking significant pixels on image
%       numIndicesDisplayedInAlerts: [int]  number of row and column indices to display in alerts
%                   apertureSymbol: [char]  MATLAB string for symbol marking in aperture pixels
%                                           (i.e. '^' is a triangle)
%            optimalApertureSymbol: [char]  MATLAB string for symbol marking in optimal aperture
%                                           pixels (i.e. 'o' is a circle) 
%               significanceSymbol: [char]  MATLAB string for symbol marking in significant pixels
%                                           (i.e. 's' is a square) 
%                         colorMap: [char]  MATLAB colormap name (e.g. 'hot')       
%                    maxColorAxis: [float]  upper limit on color axis. 0 --> automatically set color axis
%             chiSquaredTolerance: [float]  alternative convergence criterion for whitener
%           timeoutPerTargetSeconds: [int]  maximum run time per target
%
%--------------------------------------------------------------------------
%   Second level
%
%     differenceImageConfigurationStruct is a struct with the following fields:
%
%             detrendingEnabled: [logical]  if true, perform detrending prior to
%                                           generation of difference images
%                  detrendPolyOrder: [int]  polynomial order for detrending if
%                                           detrending is enabled
%         defaultMedianFilterLength: [int]  median filter length in units of cadences
%                                           if detrending is enabled and filter length
%                                           cannot be determined from fit parameters
%             anomalyBufferInDays: [float]  buffer to insert following Earth points and
%                                           safe modes for exclusion of individual transit
%                                           from difference images, in units of days
%           controlBufferInCadences: [int]  buffer to insert between transits and
%                                           associated out-of-transit reference cadences
%               minInTransitDepth: [float]  minimum depth for identification of in
%                                           transit cadences as fraction of maximum depth
%       overlappedTransitExclusionEnabled:
%                                [logical]  if true, exclude transits from difference images
%                                           if they overlap the transits of other candidates on
%                                           the same target; otherwise, do not exclude transits
%                                           if all are overlapped in given target table
%        singlePrfFitSnrThreshold: [float]  SNR threshold below which single multi-quarter
%                                           PRF fit is performed on difference (and pixel
%                                           correlation) image(s)
%             maxSinglePrfFitTrials: [int]  maximum number of bootstrap multi-quarter PRF
%                                           fit trials allowed
%           maxSinglePrfFitFailures: [int]  maximum number of consecutive failures of
%                                           multi-quarter PRF fit allowed
% singlePrfFitForCentroidPositionsEnabled: 
%                                [logical]  if true, estimate centroid positions with single
%                                           MQ PRF fit to all available quarterly images
%     mqOffsetConstantUncertainty: [float]  constant value to add in quadrature to MQ offset
%                                           uncertainties in arcseconds
%                qualityThreshold: [float]  quality metric threshold for establishing that a
%                                           difference image is good
%
%--------------------------------------------------------------------------
%   Second level
%
%     bootstrapConfigurationStruct is a struct with the following fields:
%
%                         skipCount: [int]  parameter controls building of
%                                           bootstrap histogram and performance
%                                           of algorithm
%          autoSkipCountEnabled: [logical]  if true, enable auto-skip count
%                     maxIterations: [int]  bootstrap iteration limit
%                     maxNumberBins: [int]  max number of histogram bins
%               histogramBinWidth: [float]  width of histogram bins in units
%                                           of (noise) sigma
%   binsBelowSearchTransitThreshold: [int]  bins below threshold at low end of
%                                           bootstrap histogram
%                upperLimitFactor: [float]  parameter used by bootstrap to prevent 
%                                           runaway processes
%          useTceTrialPulseOnly: [logical]  if true, use only the trial transit pulse
%                                           duration that produced the TCE
%                   maxAllowedMes: [float]  maximum allowable MES
%            maxAllowedTransitCount: [int]  maxumum number of allowable transits    
%       convolutionMethodEnabled:[logical]  if true, enable convolution bootstrap method (new in 9.2)
% deemphasizeQuartersWithoutTransits:[logical] if true, deemphasize quarters that contain no transits
%        sesZeroCrossingWidthDays: [float]  window size for zero crossing counts
%    sesZeroCrossingDensityFactor: [float]  data used in the bootstrap is required to have a SES 
%                                           sign change density above median scaled by this factor
%                 nSesPeaksToRemove: [int]  number of positive and negative ses peaks to suppress 
%                                           in the bootstrap calculation
%         sesPeakRemovalThreshold: [float]  threshold for SES peak removal
%             sesPeakRemovalFloor: [float]  remove the SES peaks down to this sigma level
%          boostrapResolutionFactor: [int]  resolution of correlation and normalization histograms
%
%--------------------------------------------------------------------------
%   Second level
%
%     ancillaryEngineeringConfigurationStruct is a struct with the following fields:
%
%                mnemonics: [string array]  mnemonic names
%                 modelOrders: [int array]  polynomial orders
%             interactions: [string array]  array of mnemonic pairs ('|'
%                                           separated) for interactions
%        quantizationLevels: [float array]  engineering data step sizes
%    intrinsicUncertainties: [float array]  engineering data uncertainties
%
%--------------------------------------------------------------------------
%   Second level
%
%     ancillaryPipelineConfigurationStruct is a struct with the following fields:
%
%                mnemonics: [string array]  mnemonic names
%                 modelOrders: [int array]  polynomial orders
%             interactions: [string array]  array of mnemonic pairs ('|'
%                                           separated) for interactions
%
%--------------------------------------------------------------------------
%   Second level
%
%     ancillaryDesignMatrixConfigurationStruct is a struct with the following fields:
%
%              filteringEnabled: [logical]  filter design matrix columns if true
%                sgPolyOrders: [int array]  polynomial orders for multi-stage Savitsky-Golay
%                                           filtering
%                sgFrameSizes: [int array]  frame sizes for multi-stage Savitsky-Golay
%                                           filtering
%           bandpassFlags: [logical array]  include lowpass, midpass, highpass design matrix
%                                           columns respectively if true
%
%--------------------------------------------------------------------------
%   Second level
%
%     gapFillConfigurationStruct is a struct with the following fields:
%
%                      madXFactor: [float]  MAD multiplication factor
%  maxGiantTransitDurationInHours: [float]  maximum giant transit duration (hours)
%   giantTransitPolyFitChunkLengthInHours:
%                                  [float]  giant transit poly fit chunk length (hours)
%               maxDetrendPolyOrder: [int]  maximum detrend polynomial order
%                   maxArOrderLimit: [int]  maximum AR order
%       maxCorrelationWindowXFactor: [int]  maximum correlation window
%                                           multiplication factor
%     gapFillModeIsAddBackPredictionError:
%                                [logical]  true if gap fill mode is add back
%                                           prediction error
% removeEclipsingBinariesOnList: [logical]  true if eclipsing binaries on input list are to
%                                           be removed prior to giant transit identification
%                  waveletFamily: [string]  name of wavelet family, e.g. 'daub'
%               waveletFilterLength: [int]  number of wavelet filter coefficients
%      arAutoCorrelationThreshold: [float]  AR threshold for short gap filling
%
%--------------------------------------------------------------------------
%   Second level
%
%     pdcConfigurationStruct is a struct with the following fields:
%
%          robustCotrendFitFlag: [logical]  robust (vs. SVD LS) fit if true
%                medianFilterLength: [int]  samples in median filter for
%                                           outlier detection
%         outlierThresholdXFactor: [float]  number of sigmas from mu to set
%                                           outlier thresholds
%          normalizationEnabled: [logical]  normalize quarter to quarter
%                                           variations in target flux if true
%    stellarVariabilityDetrendOrder: [int]  order for detrending to identify
%                                           variable targets
%     stellarVariabilityThreshold: [float]  threshold for identification of
%                                           variable targets
%         minHarmonicsForDetrending: [int]  minimum number of harmonics for
%                                           harmonics detrending
%              harmonicDetrendOrder: [int]  order for harmonics detrending
%   thermalRecoveryDurationInDays: [float]  duration of nominal safe mode recovery
%                                           transient
%   neighborhoodRadiusForAttitudeTweak: 
%                                    [int]  buffer near tweaks for coarse error
%                                           correction (cadences)
%       attitudeTweakBufferInDays: [float]  buffer near tweaks for identification of
%                                           astro events
%            safeModeBufferInDays: [float]  buffer near safe modes for identification 
%                                           of astro events
%          earthPointBufferInDays: [float]  buffer near earth points for identification 
%                                           of astro events
%         coarsePointBufferInDays: [float]  buffer near coarse points for identification 
%                                           of astro events
%  astrophysicalEventBridgeInDays: [float]  time to bridge astro events near data
%                                           anomalies
%  cotrendRatioMaxTimeScaleInDays: [float]  max time scale for computation of
%                                           corrected flux to raw flux power
%         cotrendPerformanceLimit: [float]  limit to accept cotrending results
%                    mapEnabled: [logical]  flag whether to use MAP or old PDC (least-squares
%                                           with AED)
%      excludeTargetLabels: [string array]  target labels to exclude from goodness distribution
%                                           and statistics
%       harmonicsRemovalEnabled: [logical]  harmonics removal enabled in pre-MAP DHO
%                                           iterations if true
%                  preMapIterations: [int]  number of pre-MAP DHO iterations
%     variabilityEpRecoveryMaskEnabled:
%                                [logical]  mask recovery regions for variability calculation
%   variabilityEpRecoveryMaskWindow: [int]  number of cadences after Earth-point to mask
%       variabilityDetrendPolyOrder; [int]  polynomial order for variability coarse detrending
%          bandSplittingEnabled: [logical]  if true, perform multi-scale MAP
% stellarVariabilityRemoveEclipsingBinariesEnabled:
%                                [logical]  if true, remove EB signatures
%             mapSelectionMethod: [string]  method for PDC MAP
%        mapSelectionMethodCutoff: [float]  cutoff for MAP method
%     mapSelectionMethodMultiscaleBias:
%                                  [float]  bias for MAP method
%                        debugLevel: [int]  level for PDC debugging; 0 -> no debug info
%
%--------------------------------------------------------------------------
%   Second level
%
%     saturationSegmentConfigurationStruct is a struct with the following fields:
%
%                       sgPolyOrder: [int]  order of Savitzky-Golay filter to
%                                           detect saturated segments
%                       sgFrameSize: [int]  length of Savitzky-Golay frame
%                 satSegThreshold: [float]  threshold for identifying
%                                           saturated segments
%               satSegExclusionZone: [int]  zone for excluding secondary peaks
%          maxSaturationMagnitude: [float]  highest magnitude target that
%                                           can still be saturated
%
%--------------------------------------------------------------------------
%   Second level
%
%     tpsHarmonicsIdentificationConfigurationStruct and 
%     pdcHarmonicsIdentificationConfigurationStruct are structs with the
%     following fields:
%
% medianWindowLengthForTimeSeriesSmoothing:
%                                    [int]  length of median filter for time domain
%                                           filtering in units of cadences
%                                           (not used in 7.0)
% medianWindowLengthForPeriodogramSmoothing:
%                                    [int]  length of median filter for frequency
%                                           domain filtering in units of cadences
%         movingAverageWindowLength: [int]  length of periodogram smoothing filter in
%                                           units of cadences
%  falseDetectionProbabilityForTimeSeries:
%                                  [float]  probability of identifying one or more false
%                                           component detections in a given time series
%       minHarmonicSeparationInBins: [int]  minimum required separation for any two
%                                           frequency components to be identified and
%                                           fitted in a given iteration; components
%                                           from iteration to iteration can (and often
%                                           will) be more closely spaced than this
%             maxHarmonicComponents: [int]  maximum number of harmonic components for
%                                           a given time series
%   retainFrequencyCombsEnabled: [logical]  if true, ignore combs of frequency components
%                                           in fit
%                timeOutInMinutes: [float]  timeout limit in minutes for a given time
%                                           series
%
%--------------------------------------------------------------------------
%   Second level
%
%     tpsConfigurationStruct is a struct with the following fields:
%
%                        debugLevel: [int]  level for science debug
%        requiredTrialTransitPulseInHours:
%                            [float array]  required trial pulses for transit detection,
%                                           hours
%     minTrialTransitPulseInHours: [float]  min of computed trial transit pulses, hours
%     maxTrialTransitPulseInHours: [float]  max of computed trial transit pulses, hours
% searchTrialTransitPulseDurationStepControlFactor:
%                                  [float]  resolution for trial transit pulses
%   searchPeriodStepControlFactor: [float]  trial orbital period step size factor
%         maxFoldingsInPeriodSearch: [int]  max number foldings in transit period search
%  varianceWindowLengthMultiplier: [float]  multiplies trial transit length to
%                                           obtain noise window length
%       minimumSearchPeriodInDays: [float]  minimum transit search period, days
%       maximumSearchPeriodInDays: [float]  maximum transit search period, days
%          searchTransitThreshold: [float]  threshold value for multiple event
%                                           statistics in unit of (noise) sigma
%                  waveletFamily: [string]  name of wavelet family, e.g. 'daub'
%               waveletFilterLength: [int]  number of wavelet filter coefficients
%                tpsLiteEnabled: [logical]  if true, TPS runs in 'lite' mode
%             superResolutionFactor: [int]  sub-cadence search resolution
%    deemphasizePeriodAfterSafeModeInDays:
%                                  [float]  period to ignore after safe modes, days
%   deemphasizePeriodAfterTweakInCadences:
%                                    [int]  period to ignore after attitude tweaks,
%                                           cadences
%       performQuarterStitching: [logical]  if true, perform quarter stitching
%        pixelSensitivityDropoutThreshold:
%                                  [float]  threshold for detecting SPSDs.
%                  clusterProximity: [int]  limit for treating event clusters
%                                           as independent. in cadences
%         medfiltWindowLengthDays: [float]  median filter window length, in days
%             medfiltStandoffDays: [float]  median filter standoff, in days
%        robustStatisticThreshold: [float]  threshold for robust detection statistic
%                                           in units of (noise) sigma
%    robustWeightGappingThreshold: [float]  threshold for gapping data associated
%                                           with low robust weights
%     robustStatisticConvergenceTolerance:
%                                  [float]  tolerance for convergence of
%                                           robust detection statistic
%                  minSesInMesCount: [int]  minimum number of SES for valid MES
%                    maxDutyCycle: [float]  max ratio of trial transit duration to period
%  applyAttitudeTweakCorrection: [logical]  if true, adjust flux level so that it is
%                                           consistent before/after tweaks
%           chiSquareGofThreshold: [float]  min value of MES / sqrt(chisqGof/ndof) for a 
%                                           detection to be considered valid
%             chiSquare2Threshold: [float]  min value of MES / sqrt(chisq2/ndof) for a 
%                                           detection to be considered valid
%            maxRemovedFeatureCount: [int]  maximum # of features in the SES time series
%                                           which TPS will be allowed to work around in
%                                           order to find a TCE
% deweightReactionWheelZeroCrossingCadences:
%                                [logical]  if true, deemphasize zero-crossings in
%                                           transiting planet search
%               maxFoldingLoopCount: [int]  maximum TPS looper iterations
%        weakSecondaryPeakRangeMultiplier:
%                                 [double]  transit duration multiplier to mask for weak
%                                           secondary identification
% positiveOutlierHaircutEnabled: [logical]  if true, identify positive outliers in whitened flux
%       looperMaxWallTimeFraction: [float]  fraction of task timeout to allocate to looper
%        usePolyFitTransitModel: [logical]  if true, use transit templates for search in place
%                                           of rectangular pulses
%              maxPeriodParameter: [float]  fraction used to compute the max search period
%              mesHistogramMinMes: [float]  minimum MES for MES histogram
%              mesHistogramMaxMes: [float]  maximum MES for MES histogram
%             mesHistogramBinSize: [float]  bin size for MES histogram
%      performWeakSecondaryTest: [logical]  if true, calculate weak
%                                           secondary information
%    bootstrapGaussianEquivalentThreshold: 
%                                  [float]  the threshold used for
%                                           calculating the desired false 
%                                           alarm rate achieved by the 
%                                           bootstrap veto
%           bootstrapLowMesCutoff: [float]  Only apply the bootstrap veto for detections 
%                                           above this MES
%       bootstrapThresholdReductionFactor:  
%                                  [float]  Amount to reduce the bootstrap-derived threshold
%         noiseEstimationByQuarterEnabled: 
%                                [logical]  Perform the noise estimation quarter-by-quarter
% positiveOutlierHaircutThreshold: [float]  Threshold for detecting positive-going features 
%                                           for suppression during the search
%
%--------------------------------------------------------------------------
%   Second level
%
%     targetTableDataStruct is an array of structs (one per target table)
%     with the following fields:
%
%                     targetTableId: [int]  target table ID
%                           quarter: [int]  index of observing quarter
%                         ccdModule: [int]  CCD module
%                         ccdOutput: [int]  CCD output
%                      startCadence: [int]  start cadence for target table
%                        endCadence: [int]  end cadence for target table
%            argabrighteningIndices: [int]  Argabrightening indices
%             ancillaryPipelineDataStruct:
%                           [struct array]  ancillary pipeline data
%           backgroundBlobs: [blob series]  background polynomials for given quarter
%               motionBlobs: [blob series]  motion polynomials for given quarter
%                  cbvBlobs: [blob series]  PDC cotrending basis vectors for the given
%                                           quarter
%
%--------------------------------------------------------------------------
%   Second level
%
%     targetStruct is an array of structs (one per star with TCE) with
%     the following fields:
%
%                          keplerId: [int]  Kepler target ID
%               categories: [string array]  target categories
%                 transits: [struct array]  transit ephemerides for known KOIs
%                        raHours: [struct]  target right ascension, hours
%                     decDegrees: [struct]  target declination, degrees
%                      keplerMag: [struct]  target magnitude (Kp)
%                         radius: [struct]  target radius, solar units
%                  effectiveTemp: [struct]  target effective temperature, Kelvin
%            log10SurfaceGravity: [struct]  log target surface gravity, cm/sec^2
%               log10Metallicity: [struct]  log Fe/H metallicity, solar
%              rawFluxTimeSeries: [struct]  raw flux time series for the given target, e-
%        correctedFluxTimeSeries: [struct]  corrected flux time series for the given
%                                           target, e-
%                       outliers: [struct]  corrected flux outliers and indices
%        discontinuityIndices: [int array]  indices of identified discontinuities
%                                           for the given target
%                      centroids: [struct]  PRF and flux-weighted centroid
%                                           time series
%         targetDataStruct: [struct array]  pixel data for the given target
%                                           and table
%   thresholdCrossingEvent: [struct array]  TCE details; may be list if TCEs are
%                                           specified externally to the pipeline
%          rollingBandContaminationStruct: 
%                           [struct array]  rolling band severity levels per
%                                           pulse duration and cadence
%             ukirtImageFileName: [string]  UKIRT image file name
%
%--------------------------------------------------------------------------
%   Second level
%
%     kics is an array of structs (one per target) with the following fields:
%
%                          keplerId: [int]  Kepler target ID
%                      keplerMag: [struct]  target Kepler magnitude (KEPMAG)
%                             ra: [struct]  target right ascension, hours (RA)
%                            dec: [struct]  target declination, degrees (DEC)
%                         radius: [struct]  target radius, solar units (RADIUS)
%                  effectiveTemp: [struct]  target effective temperature, Kelvin (TEFF)
%            log10SurfaceGravity: [struct]  log target surface gravity, cm/sec^2 (LOGG)
%               log10Metallicity: [struct]  log Fe/H metallicity, solar (FEH)
%                 raProperMotion: [struct]  target proper motion in right
%                                           ascension, arc sec per year (PMRA)
%                decProperMotion: [struct]  target proper motion in declination,
%                                           arc sec per year (PMDEC)
%              totalProperMotion: [struct]  target total proper motion,
%                                           arc sec per year (PMTOTAL)
%                       parallax: [struct]  target parallax, arc sec (PARALLAX)
%                           uMag: [struct]  target u-band magnitude (UMAG)
%                           gMag: [struct]  target g-band magnitude (GMAG)
%                           rMag: [struct]  target r-band magnitude (RMAG)
%                           iMag: [struct]  target i-band magnitude (IMAG)
%                           zMag: [struct]  target z-band magnitude (ZMAG)
%                        gredMag: [struct]  target GRed-band magnitude (GREDMAG)
%                         d51Mag: [struct]  target D51-band magnitude (D51MAG)
%                      twoMassId: [struct]  target 2MASS ID (TMID)
%                    twoMassJMag: [struct]  target 2MASS J-band magnitude (JMAG)
%                    twoMassHMag: [struct]  target 2MASS H-band magnitude (HMAG)
%                    twoMassKMag: [struct]  target 2MASS K-band magnitude (KMAG)
%                          scpId: [struct]  target SCP ID (SCPKEY)
%                  internalScpId: [struct]  target internal SCP ID (SCPID)
%                      catalogId: [struct]  target catalog key (CATKEY)
%                    alternateId: [struct]  target alternate ID (ALTID)
%                alternateSource: [struct]  target alternate source (ALTSOURCE)
%                galaxyIndicator: [struct]  target galaxy indicator (GALAXY)
%                 blendIndicator: [struct]  target blend indicator (BLEND)
%              variableIndicator: [struct]  target variable indicator (VARIABLE)
%                ebMinusVRedding: [struct]  target E(B-V) reddening, magnitudes (EBMINUSV)
%                    avExinction: [struct]  target A_V extinction, magnitudes (AV)
%              photometryQuality: [struct]  target photometry quality indicator (PQ)
%            astrophysicsQuality: [struct]  target astrophysics quality indicator (AQ)
%               galacticLatitude: [struct]  target galactic latitude (GLAT)
%              galacticLongitude: [struct]  target galactic longitude (GLON)
%                        grColor: [struct]  target g-r color, magnitudes (GRCOLOR)
%                        jkColor: [struct]  target J-K color, magnitudes (JKCOLOR)
%                        gkColor: [struct]  target g-K color, magnitudes (GKCOLOR)
%
%--------------------------------------------------------------------------
%   Third level
%
%     dataAnomalyFlags is a struct with the following fields:
%
% attitudeTweakIndicators: [logical array]  attitude tweak cadence markers
%      safeModeIndicators: [logical array]  safe mode cadence markers
%    earthPointIndicators: [logical array]  Earth-point cadence markers
%   coarsePointIndicators: [logical array]  coarse-point cadence markers
%               argabrighteningIndicators:  
%                          [logical array]  global Argabrightening cadence markers
%       excludeIndicators: [logical array]  markers for cadences to exclude
%           planetSearchExcludeIndicators:
%                          [logical array]  markers for cadences to exclude
%                                           explicitly from TPS/DV
%
%--------------------------------------------------------------------------
%   Third level
%
%     ancillaryPipelineDataStruct is an array of structs (one per pipeline
%     mnemonic) with the following fields:
%
%                       mnemonic: [string]  name of ancillary channel
%               timestamps: [double array]  pipeline time tags, MJD
%                    values: [float array]  pipeline data values
%             uncertainties: [float array]  pipeline data uncertainties
%
%--------------------------------------------------------------------------
%   Third level
%
%     transits is an array of structs (one per KOI for the given target)
%     with the following fields:
%
%                          koiId: [string]  KOI identifier
%                     keplerName: [string]  Kepler name
%                        duration: [float]  transit duration, hours
%                           epoch: [float]  epoch of first transit, BKJD
%                          period: [float]  transit period, days
%
%--------------------------------------------------------------------------
%   Third level
%
%     raHours, decDegrees, keplerMag, radius*, effectiveTemp*,
%     log10SurfaceGravity* and log10Metallicity* are structs with the
%     following fields:
%
%                          value: [double]  parameter value
%                    uncertainty: [double]  uncertainty in parameter value
%                     provenance: [string]  parameter provenance
%
% *If values for radius, effectiveTemp, and/or log10SurfaceGravity are missing 
% (NaN or empty) for the target, they  will be replaced by the values corresponding
% to our sun: radius = 1 solar radius, effectiveTemp = 5780 Kelvin,
% log10SurfaceGravity = log10(27400), log10Metallicity = 0. Such replacement will
% happen independently, i.e., if radius value is missing, but not effectiveTemp,
% only radius value will be filled with Sun's radius. Such values will be
% provided from module parameters in planetFitConfigurationStruct.
% 
% If such replacement occurs, fields in usedDefaultValuesStruct returned by
% this function will be marked as true.
%
%--------------------------------------------------------------------------
%   Third level
%
%     rawFluxTimeSeries is a struct with the following fields:
%
%                    values: [float array]  raw flux values
%             uncertainties: [float array]  uncertainties in raw flux values
%           gapIndicators: [logical array]  data gap indicators
%
%--------------------------------------------------------------------------
%   Third level
%
%     correctedFluxTimeSeries is a struct with the following fields:
%
%                    values: [float array]  corrected flux values
%             uncertainties: [float array]  uncertainties in corrected flux
%                                           values
%           gapIndicators: [logical array]  indicators for remaining gaps
%               filledIndices: [int array]  indices of filled flux values
%
%--------------------------------------------------------------------------
%   Third level
%
%     outliers is a struct with the following fields:
%
%                    values: [float array]  values of corrected flux outliers
%             uncertainties: [float array]  uncertainties in corrected flux
%                                           outliers
%                     indices: [int array]  indices of outliers
%
%--------------------------------------------------------------------------
%   Third level
%
%     centroids is a struct with the following fields:
%
%                   prfCentroids: [struct]  PRF-based centroid time series
%          fluxWeightedCentroids: [struct]  flux-weighted centroid time series
%
%--------------------------------------------------------------------------
%   Third level
%
%     targetDataStruct is an array of structs (one per target table in which the
%     given target was observed) with the following fields:
%
%
%                     targetTableId: [int]  target table ID
%                           quarter: [int]  index of observing quarter
%                         ccdModule: [int]  CCD module
%                         ccdOutput: [int]  CCD output
%                      startCadence: [int]  start cadence for target table
%                        endCadence: [int]  end cadence for target table
%                   labels: [string array]  target label strings
%          fluxFractionInAperture: [float]  flux fraction in aperture for
%                                           the given target and quarter
%                  crowdingMetric: [float]  crowding metric for the given target
%                                           and quarter
%              pixelDataFileName: [string]  SDF file with coordinates and time series for
%                                           all pixels in aperture mask for target table
%
%--------------------------------------------------------------------------
%   Third level
%
%     thresholdCrossingEvent is an array of structs with the following fields:
%
%                          keplerId: [int]  Kepler target ID
%       trialTransitPulseDuration: [float]  duration of transit pulse associated with
%                                           TCE, hours
%                       epochMjd: [double]  time of first transit, MJD
%                   orbitalPeriod: [float]  period between detected transits, days
%             maxSingleEventSigma: [float]  maximum single event statistic for the
%                                           given target in units of (noise) sigma
%           maxMultipleEventSigma: [float]  maximum multiple event statistic for the
%                                           given target in units of (noise) sigma
%                     maxSesInMes: [float]  maximum single event statistic of those
%                                           combined to yield maximum multiple event statistic
%                 robustStatistic: [float]  robust detection statistic
%                      chiSquare1: [float]  chi-square-1 statistic
%                     chiSquareDof1: [int]  chi-square-1 degrees of freedom
%                      chiSquare2: [float]  chi-square-2 statistic
%                     chiSquareDof2: [int]  chi-square-2 degrees of freedom
%                    chiSquareGof: [float]  chi-square gooodness of fit statistic
%                   chiSquareGofDof: [int]  chi-square goodness of fit degrees of freedom
%            weakSecondaryStruct: [struct]  MES vs phase for given period and pulse duration
%     deemphasizedNormalizationTimeSeries:
%                            [float array]  deemphasized SES denominator for bootstrap
%          thresholdForDesiredPfa: [float]  threshold determined by the bootstrap during 
%                                           the search which the MES must exceed
%
%--------------------------------------------------------------------------
%   Third level
%
%     rollingBandContaminationStruct is an array of structs (one per rolling band
%     pulse duration) with the following fields:
%
%               testPulseDurationLc: [int]  pulse duration in cadences
%                  severityFlags: [struct]  discrete rolling band severity metrics pertaining
%                                           to optimal aperture
%
%--------------------------------------------------------------------------
%   Third level
%
%     kic (field) structs contain the following fields:
%
%                          value: [double]  star parameter value
%                    uncertainty: [double]  uncertainty in parameter value
%
%--------------------------------------------------------------------------
%   Fourth level
%
%     prfCentroids and fluxWeightedCentroids are structs with the following
%     fields:
%
%                  rowTimeSeries: [struct]  centroid row time series for the given
%                                           target and table, pixels
%               columnTimeSeries: [struct]  centroid column time series for the given
%                                           target and table, pixels
%
%--------------------------------------------------------------------------
%   Fourth level
%
%     weakSecondaryStruct struct is a struct with the following fields:
%
%               phaseInDays: [float array]  phases for given period and pulse duration,
%                                           days
%                       mes: [float array]  multiple event statistics for given period
%                                           and pulse duration
%               maxMesPhaseInDays: [float]  phase for maximum secondary MES, days
%                          maxMes: [float]  maximum secondary MES
%               minMesPhaseInDays: [float]  phase for minimum secondary MES, days
%                          minMes: [float]  minimum secondary MES
%                       medianMes: [float]  median of MES series
%                          mesMad: [float]  MAD of MES series
%                      nValidPhases: [int]  Number of valid phases
%                 robustStatistic: [float]  Robust detection statistic for secondary
%                       depthPpm: [struct]  Robust depth of max secondary
%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%   Fourth level
%
%     severityFlags is a struct with the following fields:
%
%                    values: [float array]  contamination values
%           gapIndicators: [logical array]  contamination gap indicators
%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%   Fifth level
%
%     rowTimeSeries and columnTimeSeries are structs with the following
%     fields:
%
%                    values: [float array]  centroid values
%             uncertainties: [float array]  centroid uncertainties
%           gapIndicators: [logical array]  centroid gap indicators
%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%   Fifth level
%
%     depthPpm is a struct with the following fields (uncertainty = -1 if
%     value is not valid):
%
%                         value: [float]  weak secondary depth value, ppm
%                   uncertainty: [float]  uncertainty in weak secondary
%                                         depth value
%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% OUTPUTS:  
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
%                 dvDataStruct: [struct] same as inputs, but may have new (replaced) 
%                                        targetStruct.radius.value,
%                                        targetStruct.effectiveTemp.value,
%                                        targetStruct.log10SurfaceGravity.value, and/or
%                                        targetStruct.log10Metallicity.value
%
%   usedDefaultValuesStruct: [ 1 x nTarget struct] has the following fields:
%                                  keplerId: [int] keplerId corresponding to 
%                                                  dvDataStruct.targetStruct
%                        radiusReplaced: [logical] true if replacement occurs                       
%                 effectiveTempReplaced: [logical] true if replacement occurs 
%           log10SurfaceGravityReplaced: [logical] true if replacement occurs
%              log10MetallicityReplaced: [logical] true if replacement occurs 
%                                     
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

% Define constant.
MIN_CUSTOM_TARGET_ID = 100000000;

% If no input, generate an error.
if nargin == 0
    error('DV:validateDvInputs:EmptyInputStruct', ...
        'This function must be called with an input structure');
end

% Initialize usedDefaultValuesStruct
if isfield(dvDataStruct, 'targetStruct') && isfield(dvDataStruct.targetStruct, 'keplerId') % Needed for unit-test to work
    usedDefaultValuesStruct = ...
        repmat(struct('keplerId', -1, 'radiusReplaced', false, 'effectiveTempReplaced', false, ...
        'log10SurfaceGravityReplaced', false, 'log10MetallicityReplaced', false), 1, ...
        length(dvDataStruct.targetStruct));
    
    for iTarget = 1:length(dvDataStruct.targetStruct)
        usedDefaultValuesStruct(iTarget).keplerId = dvDataStruct.targetStruct(iTarget).keplerId;
    end
    
end


%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Validate inputs and check fields and bounds.
%
% (1) check for the presence of all fields
% (2) check whether the parameters are within bounds and are not NaNs/Infs
%
% Note: if fields are structures, make sure that their bounds are empty.
    
%--------------------------------------------------------------------------
% Top level validation.
% Validate fields in dvDataStruct.
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

validate_structure(dvDataStruct, fieldsAndBounds, 'dvDataStruct');

clear fieldsAndBounds;

%--------------------------------------------------------------------------
% Second level validation.
% Validate the structure field dvDataStruct.dvCadenceTimes.
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

cadenceTimes = dvDataStruct.dvCadenceTimes;

if isfield(cadenceTimes, 'startTimestamps') && isfield(cadenceTimes, 'gapIndicators')
    if numel(cadenceTimes.startTimestamps) == numel(cadenceTimes.gapIndicators)
        cadenceTimes.startTimestamps = ...
            cadenceTimes.startTimestamps(~cadenceTimes.gapIndicators);
    end
end

if isfield(cadenceTimes, 'midTimestamps') && isfield(cadenceTimes, 'gapIndicators')
    if numel(cadenceTimes.midTimestamps) == numel(cadenceTimes.gapIndicators)
        cadenceTimes.midTimestamps = ...
            cadenceTimes.midTimestamps(~cadenceTimes.gapIndicators);
    end
end

if isfield(cadenceTimes, 'endTimestamps') && isfield(cadenceTimes, 'gapIndicators')
    if numel(cadenceTimes.endTimestamps) == numel(cadenceTimes.gapIndicators)
        cadenceTimes.endTimestamps = ...
            cadenceTimes.endTimestamps(~cadenceTimes.gapIndicators);
    end
end

if isfield(cadenceTimes, 'quarters') && isfield(cadenceTimes, 'gapIndicators')
    if numel(cadenceTimes.quarters) == numel(cadenceTimes.gapIndicators)
        cadenceTimes.quarters = ...
            cadenceTimes.quarters(~cadenceTimes.gapIndicators);
    end
end

if isfield(cadenceTimes, 'lcTargetTableIds') && isfield(cadenceTimes, 'gapIndicators')
    if numel(cadenceTimes.lcTargetTableIds) == numel(cadenceTimes.gapIndicators)
        cadenceTimes.lcTargetTableIds = ...
            cadenceTimes.lcTargetTableIds(~cadenceTimes.gapIndicators);
    end
end

if isfield(cadenceTimes, 'originalQuarters') && isfield(cadenceTimes, 'gapIndicators')
    if numel(cadenceTimes.originalQuarters) == numel(cadenceTimes.gapIndicators)
        cadenceTimes.originalQuarters = ...
            cadenceTimes.originalQuarters(~cadenceTimes.gapIndicators);
    end
end

if isfield(cadenceTimes, 'originalLcTargetTableIds') && isfield(cadenceTimes, 'gapIndicators')
    if numel(cadenceTimes.originalLcTargetTableIds) == numel(cadenceTimes.gapIndicators)
        cadenceTimes.originalLcTargetTableIds = ...
            cadenceTimes.originalLcTargetTableIds(~cadenceTimes.gapIndicators);
    end
end

validate_structure(cadenceTimes, fieldsAndBounds, 'dvDataStruct.dvCadenceTimes');

clear fieldsAndBounds;

%--------------------------------------------------------------------------
% Second level validation.
% Validate the structure field dvDataStruct.dvConfigurationStruct.
%--------------------------------------------------------------------------
fieldsAndBounds = cell(21,4);
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
fieldsAndBounds(17,:) = { 'exceptionCatchingEnabled'; []; []; [true; false]};
fieldsAndBounds(18,:) = { 'transitModelName'; []; []; {'mandel-agol_geometric_transit_model'}};
fieldsAndBounds(19,:) = { 'limbDarkeningModelName'; []; []; {'claret_nonlinear_limb_darkening_model'; ...
                                                             'kepler_nonlinear_limb_darkening_model'; ...
                                                             'claret_nonlinear_limb_darkening_model_2011'}};
fieldsAndBounds(20,:) = { 'maxCandidatesPerTarget'; '>= 1'; '<= 25'; []};
fieldsAndBounds(21,:) = { 'team'; []; []; []};

validate_structure(dvDataStruct.dvConfigurationStruct, fieldsAndBounds, ...
    'dvDataStruct.dvConfigurationStruct');

clear fieldsAndBounds;

%--------------------------------------------------------------------------
% Second level validation.
% Validate the structure field dvDataStruct.fluxTypeConfigurationStruct.
%--------------------------------------------------------------------------
fieldsAndBounds = cell(1,4);
fieldsAndBounds(1,:)  = { 'fluxType'; []; []; {'SAP'; 'OAP'; 'DIA'}};

validate_structure(dvDataStruct.fluxTypeConfigurationStruct, fieldsAndBounds, ...
    'dvDataStruct.fluxTypeConfigurationStruct');

clear fieldsAndBounds;

%--------------------------------------------------------------------------
% Second level validation.
% Validate the structure field dvDataStruct.planetFitConfigurationStruct.
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

validate_structure(dvDataStruct.planetFitConfigurationStruct, fieldsAndBounds, ...
    'dvDataStruct.planetFitConfigurationStruct');

clear fieldsAndBounds;

%--------------------------------------------------------------------------
% Second level validation.
% Validate the structure field dvDataStruct.trapezoidalFitConfigurationStruct.
%--------------------------------------------------------------------------
fieldsAndBounds = cell(7,4);
fieldsAndBounds(1,:)  = { 'defaultSmoothingParameter'; '>= 0'; '<= 1e12'; []};
fieldsAndBounds(2,:)  = { 'filterCircularShift'; '> 0'; '<= 1000'; []};
fieldsAndBounds(3,:)  = { 'gapThreshold'; '> 0'; '<= 1000'; []};
fieldsAndBounds(4,:)  = { 'medianFilterLength'; '> 0'; '<= 1e6'; []};
fieldsAndBounds(5,:)  = { 'snrThreshold'; '> 0'; '<= 1e6'; []};
fieldsAndBounds(6,:)  = { 'transitFitRegion'; '> 1'; '<= 20'; []};
fieldsAndBounds(7,:)  = { 'transitSamplesPerCadence'; '> 0'; '<= 540'; []};

validate_structure(dvDataStruct.trapezoidalFitConfigurationStruct, fieldsAndBounds, ...
    'dvDataStruct.trapezoidalFitConfigurationStruct');

clear fieldsAndBounds;

%--------------------------------------------------------------------------
% Second level validation.
% Validate the structure field dvDataStruct.centroidTestConfigurationStruct.
%--------------------------------------------------------------------------
fieldsAndBounds = cell(18,4);
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
fieldsAndBounds(18,:) = { 'timeoutPerTargetSeconds'; '>= 0'; '<= 86400'; []};

validate_structure(dvDataStruct.centroidTestConfigurationStruct, fieldsAndBounds, ...
    'dvDataStruct.centroidTestConfigurationStruct');

clear fieldsAndBounds;

%--------------------------------------------------------------------------
% Second level validation.
% Validate the structure field dvDataStruct.pixelCorrelationConfigurationStruct.
%--------------------------------------------------------------------------
fieldsAndBounds = cell(11,4);
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
fieldsAndBounds(11,:) = { 'timeoutPerTargetSeconds'; '>= 0'; '<= 86400'; []};

validate_structure(dvDataStruct.pixelCorrelationConfigurationStruct, fieldsAndBounds, ...
    'dvDataStruct.pixelCorrelationConfigurationStruct');

clear fieldsAndBounds;

%--------------------------------------------------------------------------
% Second level validation.
% Validate the structure field dvDataStruct.differenceImageConfigurationStruct.
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

validate_structure(dvDataStruct.differenceImageConfigurationStruct, fieldsAndBounds, ...
    'dvDataStruct.differenceImageConfigurationStruct');

clear fieldsAndBounds;

%--------------------------------------------------------------------------
% Second level validation.
% Validate the structure field dvDataStruct.bootstrapConfigurationStruct.
%--------------------------------------------------------------------------
fieldsAndBounds = cell(18,4);
fieldsAndBounds(1,:)  = { 'skipCount'; '> 0'; '< 1000'; []};                         
fieldsAndBounds(2,:)  = { 'autoSkipCountEnabled'; []; []; [true; false]};
fieldsAndBounds(3,:)  = { 'maxIterations'; '>= 1e3'; '<= 1e12'; []};                 
fieldsAndBounds(4,:)  = { 'maxNumberBins'; '>= 10'; '<= 1e8'; []};                  
fieldsAndBounds(5,:)  = { 'histogramBinWidth'; '> 0'; '< 1'; []};                    
fieldsAndBounds(6,:)  = { 'binsBelowSearchTransitThreshold'; '>= 0'; '< 10'; []};    
fieldsAndBounds(7,:)  = { 'upperLimitFactor'; '>=1'; '<= 100'; []};                  
fieldsAndBounds(8,:)  = { 'useTceTrialPulseOnly'; []; []; [true; false]};
fieldsAndBounds(9,:)  = { 'maxAllowedMes'; '>=-1'; '<= 1e12'; []};       
fieldsAndBounds(10,:) = { 'maxAllowedTransitCount'; '>=-1'; '<= 1e12'; []};       
fieldsAndBounds(11,:) = { 'convolutionMethodEnabled'; []; []; [true; false]};
fieldsAndBounds(12,:) = { 'deemphasizeQuartersWithoutTransits'; []; []; [true; false]};
fieldsAndBounds(13,:) = { 'sesZeroCrossingWidthDays'; '>=0'; '<=50'; []};   
fieldsAndBounds(14,:) = { 'sesZeroCrossingDensityFactor'; '>0'; '<=1000'; []};   
fieldsAndBounds(15,:) = { 'nSesPeaksToRemove'; '>=0'; '<=50'; []};   
fieldsAndBounds(16,:) = { 'sesPeakRemovalThreshold'; '>=0'; '<=1e12'; []};   
fieldsAndBounds(17,:) = { 'sesPeakRemovalFloor'; '>=-1'; '<=10'; []};   
fieldsAndBounds(18,:) = { 'bootstrapResolutionFactor'; '>=1'; '<=131072'; []};   


validate_structure(dvDataStruct.bootstrapConfigurationStruct, fieldsAndBounds, ...
    'dvDataStruct.bootstrapConfigurationStruct');

clear fieldsAndBounds;

%--------------------------------------------------------------------------
% Second level validation.
% Validate the structure field dvDataStruct.ancillaryEngineeringConfigurationStruct
% in synchronize_dv_ancillary_data where it is used.
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
% Second level validation.
% Validate the structure field dvDataStruct.ancillaryPipelineConfigurationStruct
% if there is ancillary pipeline data.
%--------------------------------------------------------------------------
if ~isempty(dvDataStruct.targetTableDataStruct(1).ancillaryPipelineDataStruct)
    
    fieldsAndBounds = cell(3,4);
    fieldsAndBounds(1,:)  = { 'mnemonics'; []; []; {}};
    fieldsAndBounds(2,:)  = { 'modelOrders'; '>= 0'; '<= 5'; []};
    fieldsAndBounds(3,:)  = { 'interactions'; []; []; {}};

    validate_structure(dvDataStruct.ancillaryPipelineConfigurationStruct, fieldsAndBounds, ...
        'dvDataStruct.ancillaryPipelineConfigurationStruct');

    clear fieldsAndBounds;
    
end

%--------------------------------------------------------------------------
% Second level validation.
% Validate the structure field dvDataStruct.ancillaryDesignMatrixConfigurationStruct
%--------------------------------------------------------------------------  
fieldsAndBounds = cell(4,4);
fieldsAndBounds(1,:)  = { 'filteringEnabled'; []; []; [true; false]};
fieldsAndBounds(2,:)  = { 'sgPolyOrders'; '>= 1'; '<= 4'; []};
fieldsAndBounds(3,:)  = { 'sgFrameSizes'; '> 4'; '< 10000'; []};
fieldsAndBounds(4,:)  = { 'bandpassFlags'; []; []; [true; false]};

validate_structure(dvDataStruct.ancillaryDesignMatrixConfigurationStruct, fieldsAndBounds, ...
    'dvDataStruct.ancillaryDesignMatrixConfigurationStruct');

clear fieldsAndBounds;

%--------------------------------------------------------------------------
% Second level validation.
% Validate the structure field dvDataStruct.gapFillConfigurationStruct.
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

validate_structure(dvDataStruct.gapFillConfigurationStruct, fieldsAndBounds, ...
    'dvDataStruct.gapFillConfigurationStruct');

clear fieldsAndBounds;

%--------------------------------------------------------------------------
% Second level validation.
% Validate the structure field dvDataStruct.pdcConfigurationStruct.
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

validate_structure(dvDataStruct.pdcConfigurationStruct, fieldsAndBounds, ...
    'dvDataStruct.pdcConfigurationStruct');

clear fieldsAndBounds;

%--------------------------------------------------------------------------
% Second level validation.
% Validate the structure field dvDataStruct.saturationSegmentConfigurationStruct.
%--------------------------------------------------------------------------
fieldsAndBounds = cell(5,4);
fieldsAndBounds(1,:)  = { 'sgPolyOrder'; '>= 2'; '<= 24'; []};
fieldsAndBounds(2,:)  = { 'sgFrameSize'; '>= 25'; '< 10000'; []};
fieldsAndBounds(3,:)  = { 'satSegThreshold'; '> 0'; '<= 1e6'; []};
fieldsAndBounds(4,:)  = { 'satSegExclusionZone'; '>= 1'; '<= 10000'; []};
fieldsAndBounds(5,:)  = { 'maxSaturationMagnitude'; '>= 6'; '<= 15'; []};

validate_structure(dvDataStruct.saturationSegmentConfigurationStruct, ...
    fieldsAndBounds, 'dvDataStruct.saturationSegmentConfigurationStruct');

clear fieldsAndBounds;

%--------------------------------------------------------------------------
% Second level validation.
% Validate the structure field dvDataStruct.tpsHarmonicsIdentificationConfigurationStruct.
%--------------------------------------------------------------------------
fieldsAndBounds = cell(8,4);
fieldsAndBounds(1,:)  = { 'medianWindowLengthForTimeSeriesSmoothing'; '>= 1'; []; []};   % FOR NOW
fieldsAndBounds(2,:)  = { 'medianWindowLengthForPeriodogramSmoothing'; '>= 1'; []; []};  % FOR NOW
fieldsAndBounds(3,:)  = { 'movingAverageWindowLength'; '>= 1'; []; []};                  % FOR NOW
fieldsAndBounds(4,:)  = { 'falseDetectionProbabilityForTimeSeries'; '> 0'; '< 1'; []};   % FOR NOW
fieldsAndBounds(5,:)  = { 'minHarmonicSeparationInBins'; '>= 1'; '<= 10000'; []};         % FOR NOW
fieldsAndBounds(6,:)  = { 'maxHarmonicComponents'; '>= 0'; '<= 10000'; []};              % FOR NOW
fieldsAndBounds(7,:)  = { 'retainFrequencyCombsEnabled'; [] ; [] ; [true,false]};
fieldsAndBounds(8,:)  = { 'timeOutInMinutes'; '>= 0'; '<= 180'; []};                      % FOR NOW

validate_structure(dvDataStruct.tpsHarmonicsIdentificationConfigurationStruct, ...
    fieldsAndBounds, 'dvDataStruct.tpsHarmonicsIdentificationConfigurationStruct');

clear fieldsAndBounds;

%--------------------------------------------------------------------------
% Second level validation.
% Validate the structure field dvDataStruct.pdcHarmonicsIdentificationConfigurationStruct.
%--------------------------------------------------------------------------
fieldsAndBounds = cell(8,4);
fieldsAndBounds(1,:)  = { 'medianWindowLengthForTimeSeriesSmoothing'; '>= 1'; []; []};   % FOR NOW
fieldsAndBounds(2,:)  = { 'medianWindowLengthForPeriodogramSmoothing'; '>= 1'; []; []};  % FOR NOW
fieldsAndBounds(3,:)  = { 'movingAverageWindowLength'; '>= 1'; []; []};                  % FOR NOW
fieldsAndBounds(4,:)  = { 'falseDetectionProbabilityForTimeSeries'; '> 0'; '< 1'; []};   % FOR NOW
fieldsAndBounds(5,:)  = { 'minHarmonicSeparationInBins'; '>= 1'; '<= 1000'; []};         % FOR NOW
fieldsAndBounds(6,:)  = { 'maxHarmonicComponents'; '>= 0'; '<= 10000'; []};              % FOR NOW
fieldsAndBounds(7,:)  = { 'retainFrequencyCombsEnabled'; [] ; [] ; [true,false]};
fieldsAndBounds(8,:)  = { 'timeOutInMinutes'; '>= 0'; '<= 180'; []};                      % FOR NOW

validate_structure(dvDataStruct.pdcHarmonicsIdentificationConfigurationStruct, ...
    fieldsAndBounds, 'dvDataStruct.pdcHarmonicsIdentificationConfigurationStruct');

clear fieldsAndBounds;

%--------------------------------------------------------------------------
% Second level validation.
% Validate the structure field dvDataStruct.tpsConfigurationStruct.
%--------------------------------------------------------------------------
fieldsAndBounds = get_tps_input_fields_and_bounds( 'tpsModuleParameters' );

% Max search period may be -1.
tpsConfigurationStruct = dvDataStruct.tpsConfigurationStruct;
if isfield(tpsConfigurationStruct, 'maximumSearchPeriodInDays') && ...
        tpsConfigurationStruct.maximumSearchPeriodInDays == -1
    tpsConfigurationStruct.maximumSearchPeriodInDays = 1;
end
    
validate_structure(tpsConfigurationStruct, fieldsAndBounds, ...
    'dvDataStruct.tpsConfigurationStruct');

clear fieldsAndBounds;

%--------------------------------------------------------------------------
% Second level validation.
% Validate the structure field dvDataStruct.targetTableDataStruct.
%--------------------------------------------------------------------------
fieldsAndBounds = cell(10,4);
fieldsAndBounds(1,:)  = { 'targetTableId'; '> 0'; '< 256'; []};
fieldsAndBounds(2,:)  = { 'quarter'; '>= 0'; '< 100'; []};
fieldsAndBounds(3,:)  = { 'ccdModule'; []; []; '[2:4, 6:20, 22:24]'''};
fieldsAndBounds(4,:)  = { 'ccdOutput'; []; []; '[1 2 3 4]'''};
fieldsAndBounds(5,:)  = { 'startCadence'; '>= 0'; '< 5e5'; []};
fieldsAndBounds(6,:)  = { 'endCadence'; '>= 0'; '< 5e5'; []};
fieldsAndBounds(7,:)  = { 'argabrighteningIndices'; []; []; []};            % Can't set bounds if vector may be empty
fieldsAndBounds(8,:)  = { 'ancillaryPipelineDataStruct'; []; []; []};
fieldsAndBounds(9,:)  = { 'motionPolyStruct'; []; []; []};
fieldsAndBounds(10,:) = { 'cbvBlobs'; []; []; []};

nStructures = length(dvDataStruct.targetTableDataStruct);

for i = 1 : nStructures
    validate_structure(dvDataStruct.targetTableDataStruct(i), ...
        fieldsAndBounds, 'dvDataStruct.targetTableDataStruct()');
end

clear fieldsAndBounds;

%--------------------------------------------------------------------------
% Second level validation.
% Validate the structure field dvDataStruct.targetStruct.
% Any target may have non-existent keplerMag.
% Custom targets may have non-existent raHours, decDegrees.
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
fieldsAndBounds(18,:) = { 'rollingBandContaminationStruct'; []; []; []};
fieldsAndBounds(19,:) = { 'ukirtImageFileName'; []; []; []};

nStructures = length(dvDataStruct.targetStruct);

for i = 1 : nStructures  
    validate_structure(dvDataStruct.targetStruct(i), fieldsAndBounds, ...
        'dvDataStruct.targetStruct()');
end

clear fieldsAndBounds;

%--------------------------------------------------------------------------
% Second level validation.
% Validate the structure field dvDataStruct.kics.
% Only validate those fields that are used.
% 
% DO NOT ATTEMPT TO VALIDATE THIS.
%--------------------------------------------------------------------------
    
%--------------------------------------------------------------------------
% Second level validation.
% Validate the structure field dvDataStruct.fcConstants.
%
% DO NOT ATTEMPT TO VALIDATE THIS.
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
% Second level validation.
% Validate the structure field dvDataStruct.configMaps.
%
% DO NOT ATTEMPT TO VALIDATE THIS.
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
% Second level validation.
% Validate the structure field dvDataStruct.raDec2PixModel.
%
% DO NOT ATTEMPT TO VALIDATE THIS.
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
% Second level validation.
% Validate the structure field dvDataStruct.prfModels.
%
% DO NOT ATTEMPT TO VALIDATE THIS.
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
% Second level validation.
% Validate the structure field dvDataStruct.randStreamStruct.
%
% DO NOT ATTEMPT TO VALIDATE THIS.
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
% Third level validation.
% Validate the structure field
% dvDataStruct.dvCadenceTimes.dataAnomalyFlags.
%--------------------------------------------------------------------------
fieldsAndBounds = cell(7,4);
fieldsAndBounds(1,:)  = { 'attitudeTweakIndicators'; []; []; [true, false]};
fieldsAndBounds(2,:)  = { 'safeModeIndicators'; []; []; [true, false]};
fieldsAndBounds(3,:)  = { 'earthPointIndicators'; []; []; [true, false]};
fieldsAndBounds(4,:)  = { 'coarsePointIndicators'; []; []; [true, false]};
fieldsAndBounds(5,:)  = { 'argabrighteningIndicators'; []; []; [true, false]};
fieldsAndBounds(6,:)  = { 'excludeIndicators'; []; []; [true, false]};
fieldsAndBounds(7,:)  = { 'planetSearchExcludeIndicators'; []; []; [true, false]};

validate_structure(dvDataStruct.dvCadenceTimes.dataAnomalyFlags, ...
    fieldsAndBounds, 'dvDataStruct.dvCadenceTimes.dataAnomalyFlags');

clear fieldsAndBounds;

%--------------------------------------------------------------------------
% Third level validation.
% Validate the structure field
% dvDataStruct.targetTableDataStruct().ancillaryPipelineDataStruct.
%--------------------------------------------------------------------------
fieldsAndBounds = cell(4,4);
fieldsAndBounds(1,:)  = { 'mnemonic'; []; []; {}};
fieldsAndBounds(2,:)  = { 'timestamps'; '> 54500'; '< 70000'; []};          % 2/4/2008 to 7/13/2050
fieldsAndBounds(3,:)  = { 'values'; []; []; []};                            % TBD
fieldsAndBounds(4,:)  = { 'uncertainties'; '>= 0'; []; []};                 % TBD

nTables = length(dvDataStruct.targetTableDataStruct);

for i = 1 : nTables
    
    ancillaryPipelineDataStruct = ...
        dvDataStruct.targetTableDataStruct(i).ancillaryPipelineDataStruct;
    
    nStructures = length(ancillaryPipelineDataStruct);
    
    for j = 1 : nStructures
        validate_structure(ancillaryPipelineDataStruct(j), fieldsAndBounds, ...
            'dvDataStruct.targetTableDataStruct().ancillaryPipelineDataStruct()');
    end
    
end

clear fieldsAndBounds;

%--------------------------------------------------------------------------
% Third level validation.
% Validate the structure field
% dvDataStruct.targetTableDataStruct().motionPolyStruct.
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

nTables = length(dvDataStruct.targetTableDataStruct);

for i = 1 : nTables
    
    motionPolyStruct = ...
        dvDataStruct.targetTableDataStruct(i).motionPolyStruct;
    
    if isfield(motionPolyStruct, 'rowPolyStatus')
        motionPolyGapIndicators = ...
            ~logical([motionPolyStruct.rowPolyStatus]');
        motionPolyStruct = motionPolyStruct(~motionPolyGapIndicators);
    end

    nStructures = length(motionPolyStruct);
    
    for j = 1 : nStructures
        validate_structure(motionPolyStruct(j), fieldsAndBounds, ...
            'dvDataStruct.targetTableDataStruct().motionPolyStruct()');
    end
    
end

clear fieldsAndBounds;

%--------------------------------------------------------------------------
% Third level validation.
% Validate the structure field
% dvDataStruct.targetStruct().transits.
% Duration, epoch and period may be NaN if they are unspecified.
%--------------------------------------------------------------------------
fieldsAndBounds = cell(5,4);
fieldsAndBounds(1,:)  = { 'koiId'; []; []; []};
fieldsAndBounds(2,:)  = { 'keplerName'; []; []; []};
fieldsAndBounds(3,:)  = { 'duration'; '>= 0'; []; []};
fieldsAndBounds(4,:)  = { 'epoch'; '>= 0'; []; []};
fieldsAndBounds(5,:)  = { 'period'; '>= 0'; []; []};

nTargets = length(dvDataStruct.targetStruct);

for i = 1 : nTargets
    
    targetStruct = dvDataStruct.targetStruct(i);
    
    nStructures = length(targetStruct.transits);

    for j = 1 : nStructures
        transits = targetStruct.transits(j);
        if isfield(transits, 'duration') && isnan(transits.duration)
            transits.duration = 0;
        end
        if isfield(transits, 'epoch') && isnan(transits.epoch)
            transits.epoch = 0;
        end
        if isfield(transits, 'period') && isnan(transits.period)
            transits.period = 0;
        end
        validate_structure(transits, fieldsAndBounds, ...
            'dvDataStruct.targetStruct().transits()');
    end

end

clear fieldsAndBounds;

%--------------------------------------------------------------------------
% Third level validation.
% Validate the structure field dvDataStruct.targetStruct().raHours.
% The raHours coordinate value may be NaN for custom targets.
%--------------------------------------------------------------------------
fieldsAndBounds = cell(3,4);
fieldsAndBounds(1,:)  = { 'value'; '>= 0'; '< 24'; []'};
fieldsAndBounds(2,:)  = { 'uncertainty'; '>= 0'; []; []};
fieldsAndBounds(3,:)  = { 'provenance'; []; []; []};                        % FOR NOW

nStructures = length(dvDataStruct.targetStruct);

for i = 1 : nStructures
    
    raHours = dvDataStruct.targetStruct(i).raHours;
    keplerId = dvDataStruct.targetStruct(i).keplerId;
    
    if (isfield(raHours, 'value'))
        if (isnan(raHours.value) && (keplerId >= MIN_CUSTOM_TARGET_ID))
            raHours.value = 0.0;
        end
    end
    
    if (isfield(raHours, 'uncertainty'))
        if (isnan(raHours.uncertainty))
            raHours.uncertainty = 0.0;
            dvDataStruct.targetStruct(i).raHours.uncertainty = 0.0;
        end
    end
    
    validate_structure(raHours, fieldsAndBounds, ...
        'dvDataStruct.targetStruct().raHours');
          
end

clear fieldsAndBounds;

%--------------------------------------------------------------------------
% Third level validation.
% Validate the structure field dvDataStruct.targetStruct().decDegrees.
% The decDegrees coordinate value may be NaN for custom targets.
%--------------------------------------------------------------------------
fieldsAndBounds = cell(3,4);
fieldsAndBounds(1,:)  = { 'value'; '>= -90'; '<= 90'; []'};
fieldsAndBounds(2,:)  = { 'uncertainty'; '>= 0'; []; []};
fieldsAndBounds(3,:)  = { 'provenance'; []; []; []};                        % FOR NOW

nStructures = length(dvDataStruct.targetStruct);

for i = 1 : nStructures
    
    decDegrees = dvDataStruct.targetStruct(i).decDegrees;
    keplerId = dvDataStruct.targetStruct(i).keplerId;
    
    if (isfield(decDegrees, 'value'))
        if (isnan(decDegrees.value) && (keplerId >= MIN_CUSTOM_TARGET_ID))
            decDegrees.value = 0.0;
        end
    end
    
    if (isfield(decDegrees, 'uncertainty'))
        if (isnan(decDegrees.uncertainty))
            decDegrees.uncertainty = 0.0;
            dvDataStruct.targetStruct(i).decDegrees.uncertainty = 0.0;
        end
    end
    
    validate_structure(decDegrees, fieldsAndBounds, ...
        'dvDataStruct.targetStruct().decDegrees');
          
end

clear fieldsAndBounds;

%--------------------------------------------------------------------------
% Third level validation.
% Validate the structure field dvDataStruct.targetStruct().keplerMag.
% Kepler magnitude value may be NaN for any DV target, but it should be
% set to 0.
%--------------------------------------------------------------------------
fieldsAndBounds = cell(3,4);
fieldsAndBounds(1,:)  = { 'value'; '>= 0'; '< 30'; []'};
fieldsAndBounds(2,:)  = { 'uncertainty'; '>= 0'; []; []};
fieldsAndBounds(3,:)  = { 'provenance'; []; []; []};                        % FOR NOW

nStructures = length(dvDataStruct.targetStruct);

for i = 1 : nStructures
    
    keplerMag = dvDataStruct.targetStruct(i).keplerMag;
    
    if (isfield(keplerMag, 'value'))
        if (isnan(keplerMag.value))
            keplerMag.value = 0.0;
            keplerMag.provenance = 'Unknown';
        end
    end
    
    if (isfield(keplerMag, 'uncertainty'))
        if (isnan(keplerMag.uncertainty))
            keplerMag.uncertainty = 0.0;
        end
    end
    
    validate_structure(keplerMag, fieldsAndBounds, ...
        'dvDataStruct.targetStruct().keplerMag');
    
    dvDataStruct.targetStruct(i).keplerMag = keplerMag;
          
end

clear fieldsAndBounds;

%--------------------------------------------------------------------------
% Third level validation.
% Validate the structure field dvDataStruct.targetStruct().radius.
%--------------------------------------------------------------------------
fieldsAndBounds = cell(3,4);
fieldsAndBounds(1,:)  = { 'value'; '> 0'; []; []'};
fieldsAndBounds(2,:)  = { 'uncertainty'; '>= 0'; []; []};
fieldsAndBounds(3,:)  = { 'provenance'; []; []; []};                        % FOR NOW

nStructures = length(dvDataStruct.targetStruct);

for i = 1 : nStructures
    
    radius = dvDataStruct.targetStruct(i).radius;
    
    if (isfield(radius, 'value'))
        % if radius value is nan or empty, replace with default
        % solar value
        if (isempty(radius.value) || isnan(radius.value))
            radius.value = ...
                dvDataStruct.planetFitConfigurationStruct.defaultRadius;
            if (isfield(radius, 'provenance'))
                radius.provenance = 'Solar';
            end
            usedDefaultValuesStruct(i).radiusReplaced = true;
        end
        if (isfield(radius, 'uncertainty'))
            if (isempty(radius.uncertainty) || isnan(radius.uncertainty))
                radius.uncertainty = 0.0;
            end
        end
    end
    
    if (~isfield(radius, 'value') || ...
            ~isfield(radius, 'uncertainty') || ...
            ~isnan(radius.uncertainty))
        validate_structure(radius, fieldsAndBounds, ...
            'dvDataStruct.targetStruct().radius');
    else
        validate_structure(radius, fieldsAndBounds([1, 3], : ), ...
            'dvDataStruct.targetStruct().radius');
    end
    
    dvDataStruct.targetStruct(i).radius = radius;
          
end

clear fieldsAndBounds;

%--------------------------------------------------------------------------
% Third level validation.
% Validate the structure field dvDataStruct.targetStruct().effectiveTemp.
%--------------------------------------------------------------------------
fieldsAndBounds = cell(3,4);
fieldsAndBounds(1,:)  = { 'value'; '> 0'; []; []};
fieldsAndBounds(2,:)  = { 'uncertainty'; '>= 0'; []; []};
fieldsAndBounds(3,:)  = { 'provenance'; []; []; []};                        % FOR NOW

nStructures = length(dvDataStruct.targetStruct);

for i = 1 : nStructures
    
    effectiveTemp = dvDataStruct.targetStruct(i).effectiveTemp;
    
    if (isfield(effectiveTemp, 'value'))
        % if effectiveTemp value is nan or empty, replace with default
        % solar value
        if (isempty(effectiveTemp.value) || isnan(effectiveTemp.value))
            effectiveTemp.value = ...
                dvDataStruct.planetFitConfigurationStruct.defaultEffectiveTemp;
            if (isfield(effectiveTemp, 'provenance'))
                effectiveTemp.provenance = 'Solar';
            end
            usedDefaultValuesStruct(i).effectiveTempReplaced = true;
        end
        if (isfield(effectiveTemp, 'uncertainty'))
            if (isempty(effectiveTemp.uncertainty) || isnan(effectiveTemp.uncertainty))
                effectiveTemp.uncertainty = 0.0;
            end
        end
    end
    
    if (~isfield(effectiveTemp, 'value') || ...
            ~isfield(effectiveTemp, 'uncertainty') || ...
            ~isnan(effectiveTemp.uncertainty))
        validate_structure(effectiveTemp, fieldsAndBounds, ...
            'dvDataStruct.targetStruct().effectiveTemp');
    else
        validate_structure(effectiveTemp, fieldsAndBounds([1, 3], : ), ...
            'dvDataStruct.targetStruct().effectiveTemp');
    end
    
    dvDataStruct.targetStruct(i).effectiveTemp = effectiveTemp;
          
end

clear fieldsAndBounds;

%--------------------------------------------------------------------------
% Third level validation.
% Validate the structure field
% dvDataStruct.targetStruct().log10SurfaceGravity.
%--------------------------------------------------------------------------
fieldsAndBounds = cell(3,4);
fieldsAndBounds(1,:)  = { 'value'; '> -0.45'; []; []};
fieldsAndBounds(2,:)  = { 'uncertainty'; '>= 0'; []; []};
fieldsAndBounds(3,:)  = { 'provenance'; []; []; []};                        % FOR NOW

nStructures = length(dvDataStruct.targetStruct);

for i = 1 : nStructures
    
    log10SurfaceGravity = dvDataStruct.targetStruct(i).log10SurfaceGravity;
    
    if (isfield(log10SurfaceGravity, 'value'))
        % if log10SurfaceGravity value is nan or empty, replace with default
        % solar value
        if (isempty(log10SurfaceGravity.value) || isnan(log10SurfaceGravity.value))
            log10SurfaceGravity.value = ...
                dvDataStruct.planetFitConfigurationStruct.defaultLog10SurfaceGravity;
            if (isfield(log10SurfaceGravity, 'provenance'))
                log10SurfaceGravity.provenance = 'Solar';
            end
            usedDefaultValuesStruct(i).log10SurfaceGravityReplaced = true;
        end
        if (isfield(log10SurfaceGravity, 'uncertainty'))
            if (isempty(log10SurfaceGravity.uncertainty) || isnan(log10SurfaceGravity.uncertainty))
                log10SurfaceGravity.uncertainty = 0.0;
            end
        end
    end
    
    if (~isfield(log10SurfaceGravity, 'value') || ...
            ~isfield(log10SurfaceGravity, 'uncertainty') || ...
            ~isnan(log10SurfaceGravity.uncertainty))
        validate_structure(log10SurfaceGravity, fieldsAndBounds, ...
            'dvDataStruct.targetStruct().log10SurfaceGravity');
    else
        validate_structure(log10SurfaceGravity, fieldsAndBounds([1, 3], : ), ...
            'dvDataStruct.targetStruct().log10SurfaceGravity');
    end
    
    dvDataStruct.targetStruct(i).log10SurfaceGravity = log10SurfaceGravity;
          
end

clear fieldsAndBounds;

%--------------------------------------------------------------------------
% Third level validation.
% Validate the structure field
% dvDataStruct.targetStruct().log10Metallicity.
%--------------------------------------------------------------------------
fieldsAndBounds = cell(3,4);
fieldsAndBounds(1,:)  = { 'value'; '>= -25'; '<= 5'; []};
fieldsAndBounds(2,:)  = { 'uncertainty'; '>= 0'; []; []};
fieldsAndBounds(3,:)  = { 'provenance'; []; []; []};                        % FOR NOW

nStructures = length(dvDataStruct.targetStruct);

for i = 1 : nStructures
    
    log10Metallicity = dvDataStruct.targetStruct(i).log10Metallicity;
    
    if (isfield(log10Metallicity, 'value'))
        % if log10Metallicity value is nan or empty, replace with default
        % solar value
        if (isempty(log10Metallicity.value) || isnan(log10Metallicity.value))
            log10Metallicity.value = ...
                dvDataStruct.planetFitConfigurationStruct.defaultLog10Metallicity;
            if (isfield(log10Metallicity, 'provenance'))
                log10Metallicity.provenance = 'Solar';
            end
            usedDefaultValuesStruct(i).log10MetallicityReplaced = true;
        end
        if (isfield(log10Metallicity, 'uncertainty'))
            if (isempty(log10Metallicity.uncertainty) || isnan(log10Metallicity.uncertainty))
                log10Metallicity.uncertainty = 0.0;
            end
        end
    end
    
    if (~isfield(log10Metallicity, 'value') || ...
            ~isfield(log10Metallicity, 'uncertainty') || ...
            ~isnan(log10Metallicity.uncertainty))
        validate_structure(log10Metallicity, fieldsAndBounds, ...
            'dvDataStruct.targetStruct().log10Metallicity');
    else
        validate_structure(log10Metallicity, fieldsAndBounds([1, 3], : ), ...
            'dvDataStruct.targetStruct().log10Metallicity');
    end
    
    dvDataStruct.targetStruct(i).log10Metallicity = log10Metallicity;
          
end

clear fieldsAndBounds;

%--------------------------------------------------------------------------
% Third level validation.
% Validate the structure field
% dvDataStruct.targetStruct().rawFluxTimeSeries.
%--------------------------------------------------------------------------
fieldsAndBounds = cell(3,4);
fieldsAndBounds(1,:)  = { 'values'; []; []; []};                            % TBD
fieldsAndBounds(2,:)  = { 'uncertainties'; '>= 0'; []; []};                 % TBD
fieldsAndBounds(3,:)  = { 'gapIndicators'; []; []; [true; false]};

nStructures = length(dvDataStruct.targetStruct);

for i = 1 : nStructures
    validate_structure(dvDataStruct.targetStruct(i).rawFluxTimeSeries, ...
        fieldsAndBounds, 'dvDataStruct.targetStruct().rawFluxTimeSeries');
end

clear fieldsAndBounds;

%--------------------------------------------------------------------------
% Third level validation.
% Validate the structure field
% dvDataStruct.targetStruct().correctedFluxTimeSeries.
%--------------------------------------------------------------------------
fieldsAndBounds = cell(4,4);
fieldsAndBounds(1,:)  = { 'values'; []; []; []};                            % TBD
fieldsAndBounds(2,:)  = { 'uncertainties'; '>= 0'; []; []};
fieldsAndBounds(3,:)  = { 'gapIndicators'; []; []; [true; false]};
fieldsAndBounds(4,:)  = { 'filledIndices'; []; []; []};                     % Can't set bounds if vector may be empty

nStructures = length(dvDataStruct.targetStruct);

for i = 1 : nStructures
    
    correctedFluxTimeSeries = ...
        dvDataStruct.targetStruct(i).correctedFluxTimeSeries;
    filledIndices = correctedFluxTimeSeries.filledIndices + 1;
    correctedFluxTimeSeries.values(filledIndices) = [];
    correctedFluxTimeSeries.uncertainties(filledIndices) = [];
    correctedFluxTimeSeries.gapIndicators(filledIndices) = [];
    
    if ~isempty(correctedFluxTimeSeries.values)
        validate_structure(correctedFluxTimeSeries, ...
            fieldsAndBounds, 'dvDataStruct.targetStruct().correctedFluxTimeSeries');
    end % if
    
end

clear fieldsAndBounds;

%--------------------------------------------------------------------------
% Third level validation.
% Validate the structure field dvDataStruct.targetStruct().outliers.
%--------------------------------------------------------------------------
fieldsAndBounds = cell(3,4);
fieldsAndBounds(1,:)  = { 'values'; []; []; []};                            % Can't set bounds if vector may be empty
fieldsAndBounds(2,:)  = { 'uncertainties'; []; []; []};                     % Can't set bounds if vector may be empty
fieldsAndBounds(3,:)  = { 'indices'; []; []; []};                           % Can't set bounds if vector may be empty

nStructures = length(dvDataStruct.targetStruct);

for i = 1 : nStructures
    validate_structure(dvDataStruct.targetStruct(i).outliers, ...
        fieldsAndBounds, 'dvDataStruct.targetStruct().outliers');
end

clear fieldsAndBounds;

%--------------------------------------------------------------------------
% Third level validation.
% Validate the structure field dvDataStruct.targetStruct().centroids.
%--------------------------------------------------------------------------
fieldsAndBounds = cell(2,4);
fieldsAndBounds(1,:)  = { 'prfCentroids'; []; []; []};
fieldsAndBounds(2,:)  = { 'fluxWeightedCentroids'; []; []; []};

nStructures = length(dvDataStruct.targetStruct);

for i = 1 : nStructures
    validate_structure(dvDataStruct.targetStruct(i).centroids, ...
        fieldsAndBounds, 'dvDataStruct.targetStruct().centroids');
end

clear fieldsAndBounds;

%--------------------------------------------------------------------------
% Third level validation.
% Validate the structure field dvDataStruct.targetStruct().targetDataStruct.
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

nTargets = length(dvDataStruct.targetStruct);

for i = 1 : nTargets
    
    nStructures = length(dvDataStruct.targetStruct(i).targetDataStruct);
    
    for j = 1 : nStructures
        validate_structure(dvDataStruct.targetStruct(i).targetDataStruct(j), ...
            fieldsAndBounds, 'dvDataStruct.targetStruct().targetDataStruct()');
    end
    
end

clear fieldsAndBounds;

%--------------------------------------------------------------------------
% Third level validation.
% Validate the structure field
% dvDataStruct.targetStruct().thresholdCrossingEvent.
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
fieldsAndBounds(17,:) = { 'thresholdForDesiredPfa'; []; []; []};

nStructures = length(dvDataStruct.targetStruct);

for i = 1 : nStructures
    
    nTces = length(dvDataStruct.targetStruct(i).thresholdCrossingEvent);
    
    for j = 1 : nTces   
        validate_structure(dvDataStruct.targetStruct(i).thresholdCrossingEvent(j), ...
            fieldsAndBounds, 'dvDataStruct.targetStruct().thresholdCrossingEvent()');
    end
    
end

clear fieldsAndBounds;

%--------------------------------------------------------------------------
% Third level validation.
% Validate the structure field
% dvDataStruct.targetStruct().rollingBandContaminationStruct.
%--------------------------------------------------------------------------
fieldsAndBounds = cell(2,4);
fieldsAndBounds(1,:)  = { 'testPulseDurationLc'; '> 0'; '<= 48'; []};
fieldsAndBounds(2,:)  = { 'severityFlags'; []; []; []};

nStructures = length(dvDataStruct.targetStruct);

for i = 1 : nStructures
    
    nPulses = length(dvDataStruct.targetStruct(i).rollingBandContaminationStruct);
    
    for j = 1 : nPulses
        validate_structure(dvDataStruct.targetStruct(i).rollingBandContaminationStruct(j), ...
            fieldsAndBounds, 'dvDataStruct.targetStruct().rollingBandContaminationStruct()');   
    end
    
end

clear fieldsAndBounds;

%--------------------------------------------------------------------------
% Fourth level validation.
% Validate the structure field 
% dvDataStruct.targetTableDataStruct().motionPolyStruct().rowPoly.
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

nTables = length(dvDataStruct.targetTableDataStruct);

for i = 1 : nTables
    
    motionPolyStruct = ...
        dvDataStruct.targetTableDataStruct(i).motionPolyStruct;
    if ~isempty(motionPolyStruct)
        motionPolyGapIndicators = ...
            ~logical([motionPolyStruct.rowPolyStatus]');
        motionPolyStruct = motionPolyStruct(~motionPolyGapIndicators);
    end
    nStructures = length(motionPolyStruct);

    for j = 1 : nStructures
        validate_structure(motionPolyStruct(j).rowPoly, fieldsAndBounds, ...
            'dvDataStruct.targetTableDataStruct().motionPolyStruct().rowPoly');
    end

end % if

clear fieldsAndBounds;

%--------------------------------------------------------------------------
% Fourth level validation.
% Validate the structure field 
% dvDataStruct.targetTableDataStruct().motionPolyStruct().colPoly.
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

nTables = length(dvDataStruct.targetTableDataStruct);

for i = 1 : nTables
    
    motionPolyStruct = ...
        dvDataStruct.targetTableDataStruct(i).motionPolyStruct;
    if ~isempty(motionPolyStruct)
        motionPolyGapIndicators = ...
            ~logical([motionPolyStruct.colPolyStatus]');
        motionPolyStruct = motionPolyStruct(~motionPolyGapIndicators);
    end
    
    nStructures = length(motionPolyStruct);

    for j = 1 : nStructures
        validate_structure(motionPolyStruct(j).colPoly, fieldsAndBounds, ...
            'dvDataStruct.targetTableDataStruct().motionPolyStruct().colPoly');
    end

end % if

clear fieldsAndBounds;

%--------------------------------------------------------------------------
% Fourth level validation.
% Validate the structure field
% dvDataStruct.targetStruct().centroids.prfCentroids.
%--------------------------------------------------------------------------
fieldsAndBounds = cell(2,4);
fieldsAndBounds(1,:)  = { 'rowTimeSeries'; []; []; []};
fieldsAndBounds(2,:)  = { 'columnTimeSeries'; []; []; []};

nStructures = length(dvDataStruct.targetStruct);

for i = 1 : nStructures
    validate_structure(dvDataStruct.targetStruct(i).centroids.prfCentroids, ...
        fieldsAndBounds, 'dvDataStruct.targetStruct().centroids.prfCentroids');
end

clear fieldsAndBounds;

%--------------------------------------------------------------------------
% Fourth level validation.
% Validate the structure field
% dvDataStruct.targetStruct().centroids.fluxWeightedCentroids.
%--------------------------------------------------------------------------
fieldsAndBounds = cell(2,4);
fieldsAndBounds(1,:)  = { 'rowTimeSeries'; []; []; []};
fieldsAndBounds(2,:)  = { 'columnTimeSeries'; []; []; []};

nStructures = length(dvDataStruct.targetStruct);

for i = 1 : nStructures
    validate_structure(dvDataStruct.targetStruct(i).centroids.fluxWeightedCentroids, ...
        fieldsAndBounds, 'dvDataStruct.targetStruct().centroids.fluxWeightedCentroids');
end

clear fieldsAndBounds;

%--------------------------------------------------------------------------
% Fourth level validation.
% Validate the structure field
% dvDataStruct.targetStruct().thresholdCrossingEvent().weakSecondaryStruct.
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

nStructures = length(dvDataStruct.targetStruct);

for i = 1 : nStructures
    
    nTces = length(dvDataStruct.targetStruct(i).thresholdCrossingEvent);
    
    for j = 1 : nTces
        validate_structure(dvDataStruct.targetStruct(i).thresholdCrossingEvent(j).weakSecondaryStruct, ...
            fieldsAndBounds, 'dvDataStruct.targetStruct().thresholdCrossingEvent().weakSecondaryStruct');
    end
end

clear fieldsAndBounds;

%--------------------------------------------------------------------------
% Fourth level validation.
% Validate the structure field
% dvDataStruct.targetStruct().rollingBandContaminationStruct().severityFlags.
%--------------------------------------------------------------------------
fieldsAndBounds = cell(2,4);
fieldsAndBounds(1,:)  = { 'values'; '>= 0'; '<= 4'; []};
fieldsAndBounds(2,:)  = { 'gapIndicators'; []; []; [true; false]};

nStructures = length(dvDataStruct.targetStruct);

for i = 1 : nStructures
    
    nPulses = length(dvDataStruct.targetStruct(i).rollingBandContaminationStruct);
    
    for j = 1 : nPulses
        validate_structure(dvDataStruct.targetStruct(i).rollingBandContaminationStruct(j).severityFlags, ...
            fieldsAndBounds, 'dvDataStruct.targetStruct().rollingBandContaminationStruct(j).severityFlags');
    end
    
end

clear fieldsAndBounds;

%--------------------------------------------------------------------------
% Fifth level validation.
% Validate the structure field
% dvDataStruct.targetStruct().centroids.prfCentroids.rowTimeSeries.
%--------------------------------------------------------------------------
fieldsAndBounds = cell(3,4);
fieldsAndBounds(1,:)  = { 'values'; '>= 0'; '< 1070'; []};
fieldsAndBounds(2,:)  = { 'uncertainties'; '>= 0'; []; []};
fieldsAndBounds(3,:)  = { 'gapIndicators'; []; []; [true; false]};

nStructures = length(dvDataStruct.targetStruct);

for i = 1 : nStructures
    validate_structure(dvDataStruct.targetStruct(i).centroids.prfCentroids.rowTimeSeries, ...
        fieldsAndBounds, 'dvDataStruct.targetStruct().centroids.prfCentroids.rowTimeSeries');
end

clear fieldsAndBounds;

%--------------------------------------------------------------------------
% Fifth level validation.
% Validate the structure field
% dvDataStruct.targetStruct().centroids.prfCentroids.columnTimeSeries.
%--------------------------------------------------------------------------
fieldsAndBounds = cell(3,4);
fieldsAndBounds(1,:)  = { 'values'; '>= 0'; '< 1132'; []};
fieldsAndBounds(2,:)  = { 'uncertainties'; '>= 0'; []; []};
fieldsAndBounds(3,:)  = { 'gapIndicators'; []; []; [true; false]};

nStructures = length(dvDataStruct.targetStruct);

for i = 1 : nStructures
    validate_structure(dvDataStruct.targetStruct(i).centroids.prfCentroids.columnTimeSeries, ...
        fieldsAndBounds, 'dvDataStruct.targetStruct().centroids.prfCentroids.columnTimeSeries');
end

clear fieldsAndBounds;

%--------------------------------------------------------------------------
% Fifth level validation.
% Validate the structure field
% dvDataStruct.targetStruct().centroids.fluxWeightedCentroids.rowTimeSeries.
%--------------------------------------------------------------------------
fieldsAndBounds = cell(3,4);
fieldsAndBounds(1,:)  = { 'values'; '>= 0'; '< 1070'; []};
fieldsAndBounds(2,:)  = { 'uncertainties'; '>= 0'; []; []};
fieldsAndBounds(3,:)  = { 'gapIndicators'; []; []; [true; false]};

nStructures = length(dvDataStruct.targetStruct);

for i = 1 : nStructures
    validate_structure(dvDataStruct.targetStruct(i).centroids.fluxWeightedCentroids.rowTimeSeries, ...
        fieldsAndBounds, 'dvDataStruct.targetStruct().centroids.fluxWeightedCentroids.rowTimeSeries');
end

clear fieldsAndBounds;

%--------------------------------------------------------------------------
% Fifth level validation.
% Validate the structure field
% dvDataStruct.targetStruct().centroids.fluxWeightedCentroids.columnTimeSeries.
%--------------------------------------------------------------------------
fieldsAndBounds = cell(3,4);
fieldsAndBounds(1,:)  = { 'values'; '>= 0'; '< 1132'; []};
fieldsAndBounds(2,:)  = { 'uncertainties'; '>= 0'; []; []};
fieldsAndBounds(3,:)  = { 'gapIndicators'; []; []; [true; false]};

nStructures = length(dvDataStruct.targetStruct);

for i = 1 : nStructures
    validate_structure(dvDataStruct.targetStruct(i).centroids.fluxWeightedCentroids.columnTimeSeries, ...
        fieldsAndBounds, 'dvDataStruct.targetStruct().centroids.fluxWeightedCentroids.columnTimeSeries');
end

clear fieldsAndBounds;

%--------------------------------------------------------------------------
% Fifth level validation.
% Validate the structure field
% dvDataStruct.targetStruct().thresholdCrossingEvent().weakSecondaryStruct.depthPpm.
%--------------------------------------------------------------------------
fieldsAndBounds = cell(2,4);
fieldsAndBounds(1,:)  = { 'value'; []; []; []};
fieldsAndBounds(2,:)  = { 'uncertainty'; '>= -1'; []; []};

nStructures = length(dvDataStruct.targetStruct);

for i = 1 : nStructures
    
    nTces = length(dvDataStruct.targetStruct(i).thresholdCrossingEvent);
    
    for j = 1 : nTces
        validate_structure(dvDataStruct.targetStruct(i).thresholdCrossingEvent(j).weakSecondaryStruct.depthPpm, ...
            fieldsAndBounds, 'dvDataStruct.targetStruct().thresholdCrossingEvent().weakSecondaryStruct.depthPpm');
    end
end

clear fieldsAndBounds;

% Return.
return
