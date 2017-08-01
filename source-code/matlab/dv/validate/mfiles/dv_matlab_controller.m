function [dvResultsStruct] = dv_matlab_controller(dvDataStruct)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [dvResultsStruct] = dv_matlab_controller(dvDataStruct)
%
% This function forms the MATLAB side of the science interface for Data
% Validation (DV). The function receives input via the dvDataStruct
% structure. It first updates and validates the fields of the input
% structure and then calls the constructor for the dvDataClass. Updates
% include the conversion of background and motion polynomial blobs to
% standard struct arrays.
%
% The DV unit of work includes a list of targets (from a single sky
% group) with transiting planet search threshold crossing events. The
% targets are processed sequentially. The duration of the unit of work
% may span one or more target tables (i.e. quarters). For each target, a
% limb darkened transiting planet model is fitted to the corrected flux
% (from PDC). Quarter stitching of flux (and centroids) for multiple
% quarter units of work is performed by common code shared with the
% Transiting Planet Search (TPS) CSCI. Once the model fit has converged,
% the transiting planet signature is removed (i.e. gapped or subtracted)
% from the corrected flux to form a residual time series.
%
% A multiple-planet search is then conducted whereby the residual flux is
% subjected to the Transiting Planet Search in TPS to determine whether
% there are any additional multiple event threshold crossings. If so, a
% transiting planet model is fitted and the process is repeated until no
% additional TCE's are generated or an iteration limit is reached.
%
% Once a residual flux time series is obtained that yields no further
% TCE's, a single event statistic time series is obtained for the
% residual against each of the TPS trial pulses. These single event
% statistics are utilized later for bootstrap validation of the TCE for
% each planet.
%
% A trapezoidal model is fitted to detrended flux data associated with each
% planet candidate. In the event that the limb darkened transiting planet
% model fit is not attempted or does not converge for a given candidate,
% the trapezoidal model is utilized as a fallback to support the diagnostic
% tests described below.
%
% If Kepler Object of Interest (KOI) details are provided to DV (following
% import from NExScI) and KOI matching is enabled then DV will attempt to
% match the ephemerides for each planet candidate associated with a given
% target to those of the KOI's associated with the same target. Matches
% will be reported along with correlation coefficients, and unmatched KOIs
% for each DV target will be reported as well.
%
% The sets of odd and even transits are also separately fitted for each
% planet candidate to support a series of consistency checks on transit
% depth and epoch. If these these parameters are not statistically
% consistent for odd and even transits, the null hypothesis can be rejected
% that the transits are due to a transiting planet. More likely, the
% observed transits are due to an eclipsing binary. For targets with more
% than one planet candidate, the fitted period of each planet candidate is
% also compared statistically with the period of the candidate with the
% next shorter period (if applicable) and the next longer period (if
% applicable). If the periods of any two planet candidates are equal, it is
% likely that these are the primaries and secondaries of an eclipsing
% binary or perhaps an artifact in the suppression of fitted transits in
% the multiple planet search.
%
% Difference images are generated for each planet candidate and target
% table. These display the mean pixel values outside of the transits,
% the mean pixel values (greater than a specified fraction of the maximum
% transit depth) inside of the transits, and the difference in the mean
% pixel values outside and inside the transits. If the model fit is not
% attempted or not successful for a given planet candidate, or if there are
% no (clean) observed transits in a given target table, then a direct image
% is generated showing then mean pixel value for the given target table.
%
% PRF centroiding and centroid offset analysis are performed on the mean
% out-of-transit and difference images for each planet candidate and target
% table. Multi-quarter averaging is performed on the offsets for each
% planet candidate across all target tables. Single PRF fits are also
% performed by bootstrap across all available quarterly data sets for
% low-SNR planet candidates to estimate the out of transit and difference
% image centroids and associated uncertainties. Offsets are then computed
% for the single-fit difference image centroid with respect to both the
% single-fit out of transit image centroid and the KIC position of the
% given target.
%
% A centroid motion test is performed for each planet candidate to assess
% the degree of correlation of the target centroid time series with the
% transit model signature. If the correlation is significant, the observed
% transit may well be due to a background source. The peak centroid offsets
% during transit (in RA and DEC) are also computed in DV as are the
% predicted source offsets (in RA and DEC) and the absolute source
% location.
%
% An optical ghost diagnost test is performed for each planet candidate to
% assess the degree of correlation between the transit model signature and
% flux time series obtained from the core aperture and the surrounding
% halo. If the transit model is more strongly correlated with flux derived
% from the halo than the core aperture then the target star is not likely
% to be the source of the transit signature.
%
% Pixel correlation tests are performed for each planet candidate and
% target table to determine the degree of correlation between each pixel
% time series and the segment of the transit model signature in the given
% target table. Pixel maps illustrating the results of the tests are
% included in the DV report. The purpose of this test is also to help
% identify astrophysical false positives. PRF centroiding and centroid
% offset analysis is performed on the pixel correlation images for each
% planet candidate and target table. Multi-quarter averaging is performed
% on the offsets for each planet candidate across all target tables. Single
% PRF fits are also performed by bootstrap across all available quarterly
% data sets for low-SNR planet candidates to estimate the pixel correlation
% image centroid and associated uncertainties. Offsets are then computed
% for the single-fit pixel correlation image centroid with respect to both
% the single-fit out of transit image centroid and the KIC position of the
% given target.
%
% The statistical bootstrap is performed for each planet candidate to
% examine the distribution of multiple event statistics, and to determine
% the significance of the TCE associated with the planet. The (false alarm)
% probability is determined such that a value equal to the maximum multiple
% event statistic or greater would have been achieved strictly by chance
% from the distribution of the null single event statistics the trial
% transit pulse duration that produced the TCE.
%
% Model fit results for all planet candidates are returned in the
% dvResultsStruct structure. Results of the centroid, pixel correlation and
% eclipsing binary (odd/even transit and shorter/longer period) tests are
% also returned in that structure. Finally, the bootstrap histogram and TCE
% significance are returned for each planet candidate as well. All model
% fit parameters (and parameters derived from the model fit) include
% associated uncertainties. A model parameter covariance matrix is also
% produced and returned by the DV fitter. All test statistics include
% statistical significances. Results and diagnostic figures for all planet
% candidates are presented in a comprehensive DV report created with LaTex.
% The name of the report file for each Kepler ID is also included in the DV
% results structure. In addition, a one-page report summary is generated in
% both Matlab FIG and PDF format for each DV planet candidate.
%
% A supplemental mode of operation is supported in DV whereby the TCE's
% for all candidates associated with each desired target are provided in an
% external (to the Pipeline) TCE file. The file is imported and lists of
% TCEs are then presented to DV for processing. There are no calls to TPS
% (other than for common quarter stitching) to search for additional planet
% candidates or to obtain null event statistics after all transiting planet
% signatures have been fitted and removed.
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
%       variabilityDetrendPolyOrder: [int]  polynomial order for variability coarse detrending
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
%     raHours, decDegrees, keplerMag, radius, effectiveTemp,
%     log10SurfaceGravity and log10Metallicity are structs with the
%     following fields:
%
%                          value: [double]  parameter value
%                    uncertainty: [double]  uncertainty in parameter value
%                     provenance: [string]  parameter provenance
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
%  OUTPUT:  A data structure dvResultsStruct with the following fields.
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%   Top level
%
%     dvResultsStruct contains the following fields:
%
%                       fluxType: [string]  flux type, i.e. 'SAP', 'OAP', 'DIA'
%                        skyGroupId: [int]  sky group identifier for planet
%                                           candidates
%        transitParameterModelDescription:
%                                 [string]  cumulative KOI specification
%             transitNameModelDescription:
%                                 [string]  KOI/Kepler-name association
%    externalTceModelDescription: [string]  specification for extra-pipeline TCEs
%      targetResultsStruct: [struct array]  results for each target with a TCE                                 
%                   alerts: [struct array]  module alert(s)
%
%   Note: skyGroupId is not persisted on the Java side.
%
%--------------------------------------------------------------------------
%   Second level
%
%     targetResultsStruct is an array of structs (one per target) with the 
%     following fields:
%
%                          keplerId: [int]  Kepler target ID
%                          koiId: [string]  target level KOI identifier
%                     keplerName: [string]  target Level Kepler name
%            matchedKoiIds: [string array]  KOI identifier for which a match was
%                                           produced in DV
%          unmatchedKoiIds: [string array]  KOI identifier for which a match was
%                                           not produced in DV
%               quartersObserved: [string]  '1' if target observed in given quarter,
%                                           '0' otherwise
%                        raHours: [struct]  target right ascension, hours
%                     decDegrees: [struct]  target declination, degrees
%                      keplerMag: [struct]  target magnitude (Kp)
%                         radius: [struct]  target radius, solar units
%                  effectiveTemp: [struct]  target effective temperature, Kelvin
%            log10SurfaceGravity: [struct]  log target surface gravity, cm/sec^2
%               log10Metallicity: [struct]  log Fe/H metallicity, solar
%          barycentricCorrectedTimestamps:
%                           [double array]  barycentric corrected timestamps for the
%                                           given target, BKJD
%      limbDarkeningStruct: [struct array]  limb darkening coefficients with one set
%                                           per target table
%      planetResultsStruct: [struct array]  results for each planet for the given
%                                           target
%         residualFluxTimeSeries: [struct]  corrected flux after all planet transit
%                                           signatures have been removed, e-
%    singleEventStatistics: [struct array]  null single event statistics for each
%                                           trial pulse width
%                 reportFilename: [string]  name of DV report file for the given
%                                           target
%
%--------------------------------------------------------------------------
%   Second level
%
%     alerts is an array of structs with the following fields:
%
%                           time: [double]  alert time, MJD
%                        severity [string]  alert severity ('error' or 'warning')
%                        message: [string]  alert message
%
%--------------------------------------------------------------------------
%   Third level
%
%     raHours and decDegrees are structs with the following fields:
%
%                          value: [double]  parameter value
%                     uncertainty: [float]  uncertainty in parameter value
%                     provenance: [string]  parameter provenance
%
%--------------------------------------------------------------------------
%   Third level
%
%     keplerMag, radius, effectiveTemp, log10SurfaceGravity and
%     log10Metallicity are structs with the following fields:
%
%                           value: [float]  parameter value
%                     uncertainty: [float]  uncertainty in parameter value
%                     provenance: [string]  parameter provenance
%
%--------------------------------------------------------------------------
%   Third level
%
%     limbDarkeningStruct is an array of structs (one per target table) with the
%     following fields:
%
%                          keplerId: [int]  Kepler target ID
%                     targetTableId: [int]  target table ID
%                           quarter: [int]  index of observing quarter
%                         ccdModule: [int]  CCD module
%                         ccdOutput: [int]  CCD output
%                      startCadence: [int]  start cadence for target table
%                        endCadence: [int]  end cadence for target table
%                      modelName: [string]  limb darkening model name
%                    coefficient1: [float]  limb darkening coefficient c1
%                    coefficient2: [float]  limb darkening coefficient c2
%                    coefficient3: [float]  limb darkening coefficient c3
%                    coefficient4: [float]  limb darkening coefficient c4
%
%--------------------------------------------------------------------------
%   Third level
%
%     planetResultsStruct is an array of structs (one per planet for the given
%     target) with the following fields:
%
%                          keplerId: [int]  Kepler target ID
%                      planetNumber: [int]  index of planet for the given target
%                          koiId: [string]  planet level KOI identifier
%                     keplerName: [string]  planet level Kepler name
%                  koiCorrelation: [float]  KOI matching correlation coefficient
%               detrendFilterLength: [int]  length of median filter for detrending, cadences
%                planetCandidate: [struct]  planet candidate details
%                 allTransitsFit: [struct]  model fit to all transits
%                 oddTransitsFit: [struct]  model fit to odd transits only
%                evenTransitsFit: [struct]  model fit to even transits only
%     reducedParameterFits: [struct array]  family of model fits to all transits with
%                                           reduced number of fit parameters
%                 trapezoidalFit: [struct]  trapezoidal model fit (to all transits)
%               foldedPhase: [float array]  folded phase time series, days
%                modelLightCurve: [struct]  model evaluated at barycentric timestamps
%        whitenedModelLightCurve: [struct]  whitened model at barycentric timestamps
%     trapezoidalModelLightCurve: [struct]  trapezoidal model at barycentric timestamps
%         whitenedFluxTimeSeries: [struct]  whitened data for fitting
%        detrendedFluxTimeSeries: [struct]  detrended flux time series for given planet
%   differenceImageResults: [struct array]  difference image results for given planet
%                                           by target table
%                centroidResults: [struct]  centroid and centroid offset diagnostics
%                                           for given planet
%         ghostDiagnosticResults: [struct]  ghost diagnostic test results
%                                           for the core and halo apertures of given planet 
%  pixelCorrelationResults: [struct array]  pixel correlation test results for
%                                           given planet by target table
%    binaryDiscriminationResults: [struct]  binary discrimination tests for
%                                           given planet
%          secondaryEventResults: [struct]  secondary event results for given planet
%           imageArtifactResults: [struct]  image artifact (e.g. rolling band) results
%                                           for given planet
%                 reportFilename: [string]  filename of the one-page report summary
%                                           for the given planet
%
%--------------------------------------------------------------------------
%   Third level
%
%     residualFluxTimeSeries is a struct with the following fields:
%
%                    values: [float array]  residual flux values
%             uncertainties: [float array]  uncertainties in residual flux values
%           gapIndicators: [logical array]  indicators for remaining gaps
%               filledIndices: [int array]  indices of filled flux values
%       outlierIndicators: [logical array]  indicators for outliers
%               fittedTrend: [float array]  trend fitted in quarter-stitcher
%            frontExponentialSize: [float]  detrending diagnostic
%             backExponentialSize: [float]  detrending diagnostic
%
%   Note: outlierIndicators, fittedTrend, frontExponentialSize and
%   backExponentialSize are not persisted on the Java side.
%
%--------------------------------------------------------------------------
%   Third level
%
%     singleEventStatistics is an array of structs (one per trial transit pulse
%     duration) with the following fields:
%
%        trialTransitPulseDuration: [float]  duration of transit pulse associated with
%                                            TCE, hours
%           correlationTimeSeries: [struct]  single event statistics numerator
%         normalizationTimeSeries: [struct]  single event statistics denominator
%               deemphasisWeights: [struct]  SES deemphasis weights for bootstrap
%
%   Note: deemphasisWeights are not persisted on the Java side.
%
%--------------------------------------------------------------------------
%   Fourth level
%
%     planetCandidate is a struct with the following fields:
%
%                          keplerId: [int]  Kepler target ID
%                      planetNumber: [int]  index of planet for given target
%          initialFluxTimeSeries: [struct]  flux time series in which TCE
%                                           was identified
%       trialTransitPulseDuration: [float]  duration of transit pulse associated with
%                                           TCE, hours
%                       epochMjd: [double]  time of first transit, MJD (from TPS)
%                   orbitalPeriod: [float]  period between detected transits, days
%                                           (from TPS)
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
%                 modelChiSquare2: [float]  DV model chi-square-2 statistic
%                modelChiSquareDof2: [int]  DV model chi-square-2 degrees of freedom
%               modelChiSquareGof: [float]  DV model chi-square-gof statistic
%              modelChiSquareGofDof: [int]  DV model chi-square-gof degrees of freedom
%            weakSecondaryStruct: [struct]  MES vs phase for given period and pulse duration
%     deemphasizedNormalizationTimeSeries:
%                            [float array]  deemphasized SES denominator for bootstrap
%          thresholdForDesiredPfa: [float]  threshold determined by the bootstrap during 
%                                           the search which the MES must exceed
%      suspectedEclipsingBinary: [logical]  planet candidate is suspected eclipsing
%                                           binary if true
%  statisticRatioBelowThreshold: [logical]  MES / SES ratio was below threshold if true
%            expectedTransitCount: [float]  expected number of transits
%            observedTransitCount: [float]  observed number of transits
%             bootstrapHistogram: [struct]  bootstrap bin statistics and probabilities
%                    significance: [double]  false alarm probability for multiple
%                                           event TCE
% bootstrapThresholdForDesiredPfa: [float]  threshold determined by the DV
%                                           bootstrap test that would yield the same Pfa 
%                                           as that of a standard normal distribution 
%                                           with the TPS search threshold
%                bootstrapMesMean: [float]  the mean of the gaussian fit to the bootstrap 
%                                           Mes distribution
%                 bootstrapMesStd: [float]  the standard deviation of the gaussian fit to 
%                                           the bootstrap Mes distribution
%
%--------------------------------------------------------------------------
%   Fourth level
%
%     allTransitsFit, oddTransitsFit, evenTransitsFit and trapezoidalFit are structs with
%     the following fields; reducedParameterFits is a struct array (one per fixed impact
%     parameter) with the following fields:
%
%                          keplerId: [int]  Kepler target ID
%                      planetNumber: [int]  index of planet for the given target
%               transitModelName: [string]  name of transit model
%         limbDarkeningModelName: [string]  name of limb darkening model
%               fullConvergence: [logical]  planet model fit fully converged if true
%            seededWithPriorFit: [logical]  iterative planet model fit seeded with result
%                                           from prior DV instance
%                  modelChiSquare: [float]  chi-square for the planet model fit
%           modelDegreesOfFreedom: [float]  degrees of freedom for the planet model fit
%                     modelFitSnr: [float]  data derived SNR for the planet model fit
%             robustWeights: [float array]  robust weights for model fit
%          modelParameters: [struct array]  fitted and derived model parameters
%  modelParameterCovariance: [float array]  model parameter covariance matrix
%
%--------------------------------------------------------------------------
%   Fourth level
%
%     modelLightCurve, whitenedModelLightCurve, trapezoidalModelLightCurve and
%     whitenedFluxTimeSeries are structs with the following fields:
%
%                    values: [float array]  light curve and flux time series values
%           gapIndicators: [logical array]  gap indicators
%
%--------------------------------------------------------------------------
%   Fourth level
%
%     detrendedFluxTimeSeries is a struct with the following fields:
%
%                    values: [float array]  detrended flux time series values
%             uncertainties: [float array]  (approximate) uncertainties in detrended
%                                           flux values
%           gapIndicators: [logical array]  gap indicators
%               filledIndices: [int array]  indices of filled flux values
%
%--------------------------------------------------------------------------
%   Fourth level
%
%     differenceImageResults is a struct array (one per target table) with the
%     following fields:
%
%                     targetTableId: [int]  target table ID
%                           quarter: [int]  index of observing quarter
%                         ccdModule: [int]  CCD module
%                         ccdOutput: [int]  CCD output
%                      startCadence: [int]  start cadence for target table
%                        endCadence: [int]  end cadence for target table
%                  numberOfTransits: [int]  number of transits used for
%                                           generation of difference image
%         numberOfCadencesInTransit: [int]  number of in-transit cadences used for
%                                           generation of difference image
%      numberOfCadenceGapsInTransit: [int]  number of in-transit cadence gaps
%                                           excluded in generation of difference image
%      numberOfCadencesOutOfTransit: [int]  number of out-of-transit cadences used for
%                                           generation of difference image
%   numberOfCadenceGapsOutOfTransit: [int]  number of out-of-transit cadence gaps
%                                           excluded in generation of difference image
%            overlappedTransits: [logical]  true if transits used to compute difference
%                                           image overlap those of other candidates
%                  qualityMetric: [struct]  difference image quality metric
%                   mjdTimestamp: [double]  mean time in transit, MJD
%              differenceImagePixelStruct:
%                           [struct array]  mean in transit, out of transit and
%                                           difference fluxes for all pixels for
%                                           given target table
%           kicReferenceCentroid: [struct]  KIC reference position for target/table
%           controlImageCentroid: [struct]  PRF-based centroid for out of transit image
%        differenceImageCentroid: [struct]  PRF-based centroid for difference image
%             kicCentroidOffsets: [struct]  offsets between difference image and KIC 
%                                           reference centroids
%         controlCentroidOffsets: [struct]  offsets between difference and control image
%                                           centroids
%
%   Note: mjdTimestamp is not persisted on the Java side.
%
%--------------------------------------------------------------------------
%   Fourth level
%
%     centroidResults is a struct with the following fields:
%
%               prfMotionResults: [struct]  PRF-based centroid motion results
%      fluxWeightedMotionResults: [struct]  flux-weighted centroid motion results
%   differenceImageMotionResults: [struct]  multi-quarter source offsets based on
%                                           PRF centroids of difference images
%  pixelCorrelationMotionResults: [struct]  multi-quarter source offsets based on
%                                           PRF centroids of pixel correlation images
%
%--------------------------------------------------------------------------
%   Fourth level
% 
%     ghostDiagnosticResults is a struct with the following fields:
% 
%      coreApertureCorrelationStatistic: [struct] transit model correlation
%           with core aperture flux minus halo aperture flux
%      haloApertureCorrelationStatistic: [struct] transit model correlation
%           with halo aperture flux
% 
%--------------------------------------------------------------------------
%   Fourth level
%
%     pixelCorrelationResults is a struct array (one per target table) with the
%     following fields:
%
%                     targetTableId: [int]  target table ID
%                           quarter: [int]  index of observing quarter
%                         ccdModule: [int]  CCD module
%                         ccdOutput: [int]  CCD output
%                      startCadence: [int]  start cadence for target table
%                        endCadence: [int]  end cadence for target table
%                   mjdTimestamp: [double]  mean time in transit, MJD
%         pixelCorrelationStatisticStruct:
%                           [struct array]  correlation statistics against transit
%                                           model for all pixels for given target table
%           kicReferenceCentroid: [struct]  KIC reference position for target/table
%           controlImageCentroid: [struct]  PRF-based centroid for out of transit image
%       correlationImageCentroid: [struct]  PRF-based centroid for correlation image
%             kicCentroidOffsets: [struct]  offsets between correlation image and KIC 
%                                           reference centroids
%         controlCentroidOffsets: [struct]  offsets between correlation and control image
%                                           centroids
%
%   Note: mjdTimestamp is not persisted on the Java side.
%
%--------------------------------------------------------------------------
%   Fourth level
%
%     binaryDiscriminationResults is a struct with the following fields:
%
%  oddEvenTransitDepthComparisonStatistic:
%                                 [struct]  odd/even depth consistency test
%  oddEvenTransitEpochComparisonStatistic:
%                                 [struct]  odd/even epoch consistency test
%   singleTransitDepthComparisonStatistic:
%                                 [struct]  single transit depth consistency
%                                           test
%  singleTransitDurationComparisonStatistic:
%                                 [struct]  single transit duration consistency
%                                           test
%   singleTransitEpochComparisonStatistic:
%                                 [struct]  single transit epoch consistency
%                                           test
%        shorterPeriodComparisonStatistic:
%                                 [struct]  test against period of planet with
%                                           next shorter period
%         longerPeriodComparisonStatistic:
%                                 [struct]  test against period of planet with
%                                           next longer period
%
%--------------------------------------------------------------------------
%   Fourth level
%
%     secondaryEventResults is a struct with the following fields:
%
%               planetParameters: [struct]  derived planet parameters from
%                                           secondary event depth
%                comparisonTests: [struct]  parameter comparison tests
%
%--------------------------------------------------------------------------
%   Fourth level
%
%     imageArtifactResults is a struct with the following fields:
%
%       rollingBandContaminationHistogram:
%                                 [struct]  counts of transits at each rolling
%                                           band severity level
%
%--------------------------------------------------------------------------
%   Fourth level
%
%     correlationTimeSeries and normalizationTimeSeries are structs with
%     the following fields:
%
%                    values: [float array]  data values
%           gapIndicators: [logical array]  data gap indicators
%
%--------------------------------------------------------------------------
%   Fifth level
%
%     initialFluxTimeSeries is a struct with the following fields:
%
%                    values: [float array]  initial flux values
%             uncertainties: [float array]  uncertainties in initial flux
%                                           values
%           gapIndicators: [logical array]  indicators for remaining gaps
%               filledIndices: [int array]  indices of filled flux values
%       outlierIndicators: [logical array]  indicators for outliers
%               fittedTrend: [float array]  trend fitted in quarter-stitcher
%            frontExponentialSize: [float]  detrending diagnostic
%             backExponentialSize: [float]  detrending diagnostic
%
%   Note: outlierIndicators, fittedTrend, frontExponentialSize and
%   backExponentialSize are not persisted on the Java side.
%
%--------------------------------------------------------------------------
%   Fifth level
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
%--------------------------------------------------------------------------
%   Fifth level
%
%     bootstrapHistogram is a struct with the following fields:
%
%                statistics: [float array]  multiple event statistics in units
%                                           of (noise) sigma
%             probabilities: [float array]  probabilities of occurrence for the
%                                           associated statistics
%                    finalSkipCount: [int]  final boostrap skip count
%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%   Fifth level
%
%     modelParameters is an array of structs (one per model parameter) with
%     the following fields:
%
%                         name: [string]  parameter name
%                        value: [double]  estimated parameter value
%                   uncertainty: [float]  uncertainty in estimated parameter
%                      fitted: [logical]  true if parameter was fitted,
%                                         false if derived
%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%   Fifth level
%
%     qualityMetric is a struct with the following fields:
%
%                   attempted: [logical]  true if attempted to compute PRF centroid
%                       valid: [logical]  true if quality metric value is valid
%                         value: [float]  correlation quality metric value
%
%--------------------------------------------------------------------------
%   Fifth level
%
%     differenceImagePixelStruct is an array of structs (one per pixel)
%     with the following fields:
%
%                            ccdRow: [int]  pixel row
%                         ccdColumn: [int]  pixel column
%              meanFluxInTransit: [struct]  mean flux for in transit cadences,
%                                           e-/cadence
%           meanFluxOutOfTransit: [struct]  mean flux for out of transit cadences,
%                                           e-/cadence
%             meanFluxDifference: [struct]  difference in mean flux between out of
%                                           transit cadences and in transit cadences,
%                                           e-/cadence
%         meanFluxForTargetTable: [struct]  mean flux for all cadences in target table 
%                                           if transits cannot be identified, e-/cadence
%
%--------------------------------------------------------------------------
%   Fifth level
%
%     kicReferenceCentroid, controlImageCentroid, differenceImageCentroid
%     and correlationImageCentroid are structs with the following fields:
%
%                            row: [struct]  centroid row coordinate, 0-based pixels
%                         column: [struct]  centroid column coordinate, 0-based pixels
%                        raHours: [struct]  projected centroid right ascension, hours
%                     decDegrees: [struct]  projected centroid declination, degrees
%  rowColumnCovariance: [2x2 double array]  covariance matrix for focal plane centroid
%      raDecCovariance: [2x2 double array]  covariance matrix for sky centroid
%            transformationCadenceIndices:
%                              [int array]  indices of cadences within target table used
%                                           for focal plane to sky transformation
%
%   Note: rowColumnCovariance, raDecCovariance and transformationCadenceIndices are not
%       persisted on the Java side.
%
%--------------------------------------------------------------------------
%   Fifth level
%
%     kicCentroidOffsets and controlCentroidOffsets are structs with the
%     following fields:
%
%                      rowOffset: [struct]  row offset with respect to reference
%                                           centroid, pixels
%                   columnOffset: [struct]  column offset with respect to reference
%                                           centroid, pixels
%               focalPlaneOffset: [struct]  total FP offset with respect to reference 
%                                           centroid, pixels
%                       raOffset: [struct]  right ascension offset with respect to
%                                           reference centroid, arcseconds
%                      decOffset: [struct]  declination offset with respect to
%                                           reference centroid, arcseconds
%                      skyOffset: [struct]  total sky offset with respect to
%                                           reference centroid, arcseconds
%
%--------------------------------------------------------------------------
%   Fifth level
%
%     prfMotionResults and fluxWeightedMotionResults are structs with the
%     following fields:
%
%       motionDetectionStatistic: [struct]  centroid motion test
%                   peakRaOffset: [struct]  centroid right ascension angle offset, arcseconds
%                  peakDecOffset: [struct]  centroid declination angle offset, arcseconds
%               peakOffsetArcSec: [struct]  magnitude of centroid offset, arcseconds
%                 sourceRaOffset: [struct]  source right ascension offset, arcsecconds
%                sourceDecOffset: [struct]  source declination angle offset, arcseconds
%             sourceOffsetArcSec: [struct]  magnitude of source offset, arcseconds
%                  sourceRaHours: [struct]  source right ascension, hours
%               sourceDecDegrees: [struct]  source declination, degrees
%    outOfTransitCentroidRaHours: [struct]  out of transit centroid right ascension, hours
% outOfTransitCentroidDecDegrees: [struct]  out of transit centroid declination, degrees
%
%--------------------------------------------------------------------------
%   Fifth level
%
%     differenceImageMotionResults is a struct with the following fields:
%
%         mqControlImageCentroid: [struct]  single PRF fit out of transit centroid
%      mqDifferenceImageCentroid: [struct]  single PRF fit difference image centroid
%           mqKicCentroidOffsets: [struct]  centroid offsets with respect to KIC
%                                           reference position
%       mqControlCentroidOffsets: [struct]  centroid offsets with respect to
%                                           out-of-transit reference position
%           summaryQualityMetric: [struct]  summary metric for quarterly difference
%                                           image quality metrics
%           summaryOverlapMetric: [struct]  summary metric for quarterly difference
%                                           image transit overlaps
%
%--------------------------------------------------------------------------
%   Fifth level
%
%     pixelCorrelationMotionResults is a struct with the following fields:
%
%         mqControlImageCentroid: [struct]  single PRF fit out of transit centroid
%     mqCorrelationImageCentroid: [struct]  single PRF fit correlation image centroid
%           mqKicCentroidOffsets: [struct]  centroid offsets with respect to KIC
%                                           reference position
%       mqControlCentroidOffsets: [struct]  centroid offsets with respect to
%                                           out-of-transit reference position
%
%--------------------------------------------------------------------------
%   Fifth level
%
%     coreApertureCorrelationStatistic and haloApertureCorrelationStatistic
%     are structs with the following fields:
%
%                           value: [float]  value of correlation statistic
%                    significance: [float]  significance of correlation statistic
%
%--------------------------------------------------------------------------
%   Fifth level
%
%     pixelCorrelationStatisticStruct is an array of structs (one per pixel)
%     with the following fields:
%
%                            ccdRow: [int]  pixel row
%                         ccdColumn: [int]  pixel column
%                           value: [float]  value of correlation statistic
%                    significance: [float]  significance of correlation statistic
%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%   Fifth level
%
%     oddEvenTransitDepthComparisonStatistic and
%     oddEvenTransitEpochComparisonStatistic are structs with the following
%     fields (significance = -1 if value is not valid):
%
%                         value: [float]  value of computed statistic
%                  significance: [float]  significance of computed statistic
%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%   Fifth level
%
%     shorterPeriodComparisonStatistic and longerPeriodComparisonStatistic
%     are structs with the following fields (significance = -1 if value is
%     not valid):
%
%                    planetNumber: [int]  number of planet for comparison 
%                         value: [float]  value of computed statistic
%                  significance: [float]  significance of computed statistic
%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%   Fifth level
%
%     planetParameters is a struct with the following fields:
% 
%              geometricAlbedo: [struct]  geometric albedo, dimensionless
%          planetEffectiveTemp: [struct]  planet effective temperature, Kelvin
%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%   Fifth level
%
%     comparisonTests is a struct with the following fields:
% 
%    albedoComparisonStatistic: [struct]  comparison of geometric albedo with 1
%      tempComparisonStatistic: [struct]  comparison of planet effective temperature
%                                         with equilibrium temperature
%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%   Fifth level
%
%     rollingBandContaminationHistogram is a struct with the following
%     fields:
%
%             testPulseDurationLc: [int]  pulse duration in cadences
%          severityLevels: [float array]  rolling band severity level 
%             transitCounts: [int array]  count of transits at each level
%        transitFractions: [float array]  fraction of transits at each level
%        transitMetadata: [struct array]  metadata for transits with severity
%                                         level > 0
%
%   Note: transitMetadata is not persisted on the Java side.
%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%   Sixth level
%
%     depthPpm is a struct with the following fields
%     (uncertainty = -1 if value is not valid):
%
%                         value: [float]  weak secondary depth value, ppm
%                   uncertainty: [float]  uncertainty in weak secondary
%                                         depth value, ppm
%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%   Sixth level
%
%     meanFluxInTransit, meanFluxOutOfTransit, meanFluxDifference and
%     meanFluxForTargetTable are structs with the following fields
%     (uncertainty = -1 if value is not valid):
%
%                         value: [float]  flux value, e-/cadence
%                   uncertainty: [float]  uncertainty in flux value, e-/cadence
%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%   Sixth level
%
%     row and column are structs with the following fields
%     (uncertainty = -1 if value is not valid):
%
%                         value: [float]  FPA centroid value
%                   uncertainty: [float]  uncertainty in centroid value
%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%   Sixth level
%
%     raHours and decDegrees are structs with the following fields
%     (uncertainty = -1 if value is not valid):
%
%                        value: [double]  sky centroid value
%                   uncertainty: [float]  uncertainty in centroid value
%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%   Sixth level
%
%     rowOffset, columnOffset, focalPlaneOffset, raOffset, decOffset and
%     skyOffset are structs with the following fields (uncertainty = -1 if
%     value is not valid):
%
%                         value: [float]  offset value
%                   uncertainty: [float]  uncertainty in offset value
%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%   Sixth level
%
%     motionDetectionStatistic is a struct with the following fields
%     (significance = -1 if value is not valid):
%
%                         value: [float]  value of computed statistic
%                  significance: [float]  significance of computed statistic
%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%   Sixth level
%
%     peakRaOffset, peakDecOffset, sourceRaOffset and sourceDecOffset
%     are structs with the following fields (uncertainty = -1 if value is
%     not valid):
%
%                         value: [float]  value of computed statistic
%                   uncertainty: [float]  uncertainty in value
%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%   Sixth level
%
%     sourceRaHours, sourceDecDegrees, outOfTransitCentroidRaHours and
%     outOfTransitCentroidDecDegrees are structs with the following
%     fields (uncertainty = -1 if value is not valid):
%
%                        value: [double] value of computed coordinate
%                   uncertainty: [float]  uncertainty in value
%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%   Sixth level
%
%     mqControlImageCentroid, mqDifferenceImageCentroid and
%     mqCorrelationImageCentroid are structs with the following fields:
%
%                      raHours: [struct]  centroid right ascension, hours
%                   decDegrees: [struct]  centroid declination, degrees
%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%   Sixth level
%
%     mqKicCentroidOffsets and mqControlCentroidOffsets are structs with
%     the following fields:
%
%                 meanRaOffset: [struct]  robust weighted mean right ascension offset
%                                         with respect to reference centroid, arcseconds
%                meanDecOffset: [struct]  robust weighted mean declination offset
%                                         with respect to reference centroid, arcseconds
%                meanSkyOffset: [struct]  total sky offset based on mean RA and Dec
%                                         offsets, arcseconds
%            singleFitRaOffset: [struct]  right ascension offset of single PRF fit centroid
%                                         with respect to reference centroid, arcseconds
%           singleFitDecOffset: [struct]  declination offset of single PRF fit centroid
%                                         with respect to reference centroid, arcseconds
%           singleFitSkyOffset: [struct]  total sky offset based on single fit RA and Dec
%                                         offsets, arcseconds
%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%   Sixth level
%
%     summaryQualityMetric is a struct with the following fields:
%
%              qualityThreshold: [float]  threshold for establishing good quality
%                                         difference image
%                numberOfAttempts: [int]  number of attempts to compute PRF centroid
%                 numberOfMetrics: [int]  number of valid quality metrics
%             numberOfGoodMetrics: [int]  number of good quality metrics
%         fractionOfGoodMetrics: [float]  fraction of good quality metrics
%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%   Sixth level
%
%     summaryOverlapMetric is a struct with the following fields:
%
%                      imageCount: [int]  number of quarterly difference images
%             imageCountNoOverlap: [int]  number of quarterly images free of overlapped
%                                         transits (by transits of other candidates)
%   imageCountFractionNoOverlap: [float]  fraction of quarterly images free of
%                                         overlapped transits
%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%   Sixth level
%
%     geometricAlbedo and planetEffectiveTemp are structs with the following
%     fields (uncertainty = -1 if value is not valid):
%
%                         value: [float]  parameter value
%                   uncertainty: [float]  uncertainty in parameter value
%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%   Sixth level
%
%     albedoComparisonStatistic and tempComparisonStatistic are structs
%     with the following fields (significance = -1 if value is not valid):
%
%                         value: [float]  statistic value
%                  significance: [float]  significance of statistic value
%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%   Sixth level
%
%     transitMetadata is an array of structs (one per severity level > 0)
%     with the following fields:
%
%                 severityLevel: [float]  rolling band severity level
%                   numbers: [int array]  transit numbers (0 = transit centered
%                                         on transitEpochBkjd) at given level
%                 epochs: [double array]  epochs of transits at given level
%
%   Note: transitMetadata is not persisted on the Java side.
%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%   Seventh level
%
%     raHours and decDegrees are structs with the following fields
%     (uncertainty = -1 if value is not valid):
%
%                        value: [double]  sky centroid value
%                   uncertainty: [float]  uncertainty in centroid value
%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%   Seventh level
%
%     meanRaOffset, meanDecOffset, meanSkyOffset, singleFitRaOffset,
%     singleFitDecOffset and singleFitSkyOffset are structs with the
%     following fields (uncertainty = -1 if value is not valid):
%
%                         value: [float]  offset value
%                   uncertainty: [float]  uncertainty in offset value
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

% Set the reference time.
refTime = clock;
disp(' ');
disp('refTime 0.00 seconds : DV reference time starts');
disp(' ');

% attach refTime to dvDataStruct
dvDataStruct.refTime = refTime;

% Initialize alerts.
alerts = [];

% Update the DV data structure. Convert blobs to structs. Attach these
% structures to the input data struct. Remove blobs from input data struct.
keplerId = dvDataStruct.targetStruct(1).keplerId;
display(['dv_matlab_controller: running dv for the following keplerId(s): ', num2str(keplerId)]);
if length(dvDataStruct.targetStruct) > 1
    for iTarget = 2 : length(dvDataStruct.targetStruct)
        fprintf('    %d\n', dvDataStruct.targetStruct(iTarget).keplerId)
    end % for iTarget
end % if
disp(' ');

startTime = clock;
display('dv_matlab_controller: updating dv inputs...');
[dvDataStruct] = update_dv_inputs(dvDataStruct);
endTime = clock;

elapsedSeconds = etime(endTime, startTime);
disp(['refTime ' num2str(etime(clock, refTime), '%6.2f') ' seconds : update_dv_inputs completed in ' num2str(elapsedSeconds, '%6.2f') ' seconds']);
disp(' ');

% Check for the presence of expected fields in the input structure, and 
% check whether each parameter is within the appropriate range.
startTime = clock;
display('dv_matlab_controller: validating dv inputs...');
[dvDataStruct, usedDefaultValuesStruct] = validate_dv_inputs(dvDataStruct);
endTime = clock;

elapsedSeconds = etime(endTime, startTime);
disp(['refTime ' num2str(etime(clock, refTime), '%6.2f') ' seconds : validate_dv_inputs completed in ' num2str(elapsedSeconds, '%6.2f') ' seconds']);
disp(' ');

% Estimate the gapped cadence timestamps and update the DV data structure.
display('dv_matlab_controller: estimating values for gapped cadence timestamps...');
[dvDataStruct.dvCadenceTimes] = ...
    estimate_timestamps(dvDataStruct.dvCadenceTimes);

% Compute the barycentric corrected cadence times and append them to the DV
% data structure.
startTime = clock;
disp(' ');
display('dv_matlab_controller: computing barycentric corrected timestamps...');
[dvDataStruct, alerts] = ...
    compute_barycentric_corrected_timestamps(dvDataStruct, alerts);
endTime = clock;

elapsedSeconds = etime(endTime, startTime);
disp(['refTime ' num2str(etime(clock, refTime), '%6.2f') ' seconds : compute_barycentric_corrected_timestamps completed in ' num2str(elapsedSeconds, '%6.2f') ' seconds']);
disp(' ');

% Instantiate a dvDataClass object and clear the DV data structure.
display('dv_matlab_controller: instantiating dv data object...');
[dvDataObject] = dvDataClass(dvDataStruct);
clear dvDataStruct

% Invoke the main DV method.
disp(' ');
disp(['refTime ' num2str(etime(clock, refTime), '%6.2f') ' seconds : data_validation starts']);
disp(' ');

startTime = clock;
display('dv_matlab_controller: starting tce data validation...');
disp(' ');
[dvResultsStruct] = data_validation(dvDataObject, ...
    usedDefaultValuesStruct, alerts, refTime);
endTime = clock;

elapsedSeconds = etime(endTime, startTime);
disp(' ');
disp(['refTime ' num2str(etime(clock, refTime), '%6.2f') ' seconds : data_validation completed in ' num2str(elapsedSeconds, '%6.2f') ' seconds']);
disp(' ');

% Return.
return
