%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Constructor pdcInputObject = pdcInputClass(pdcInputStruct)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% pdcInputClass.m - Class Constructor
%
% This method first checks for the presence of expected fields in the input
% structure and then checks whether each parameter is within the appropriate
% range. Once the validation of the inputs is complete, this method then
% implements the constructor for the pdcInputClass object.
%
% FOR NOW, ALLOW NaN for keplerMag. SET THIS TO 20 FOR SUCH TARGETS AND
% PROCEED WITH PDC.
%
% NOTE: THis new-style Matlab Class is an upgrade from the ld-style Matlab class, hence the way the object is contructed is a little awkward.
%   The intention is to protect the inputs from unwanted changes. Any changes have to pass through set functions.
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% TODO: update header information with newest structs and fields
% INPUT:
%   pdcInputStruct                                -- [struct]
%       .ccdModule                                     -- [int]  CCD module number
%       .ccdOutput                                     -- [int]  CCD output number
%       .cadenceType                                   -- [string]  {'LONG' | 'SHORT'}
%       .startCadence                                  -- [int]  start cadence index (NOT MJD)
%       .endCadence                                    -- [int]  end cadence index (NOT MJD)
%       .fcConstants                                   -- [struct]  Fc constants
%       .spacecraftConfigMap                           -- [struct array]  one or more spacecraft config maps
%       .raDec2PixModel                                -- [struct]  ra/dec to pixel model
%       .cadenceTimes                                  -- [struct]  cadence times and gap indicators
%       .longCadenceTimes                              -- [struct]  long cadence times and gap indicators for attitude solution
%       .pdcModuleParameters                           -- [struct]  module parameters
%       .mapConfigurationStruct                        -- [struct]  MAP parameters
%       .spsdDetectionConfigurationStruct              -- [struct]  SPSD Detector parameters
%       .spsdDetectorConfigurationStruct               -- [struct]  SPSD Detection parameters
%       .spsdRemovalConfigurationStruct                -- [struct]  SPSD Removal parameters
%       .saturationSegmentConfigurationStruct          -- [struct]  saturation segment identification parameters
%       .harmonicsIdentificationConfigurationStruct    -- [struct]  harmonics identification parameters
%       .discontinuityConfigurationStruct              -- [struct]  discontinuity identification parameters
%       .ancillaryEngineeringConfigurationStruct       -- [struct]  config parameters for engineering data
%       .ancillaryPipelineConfigurationStruct          -- [struct]  config parameters for pipeline data
%       .ancillaryDesignMatrixConfigurationStruct      -- [struct]  module parameters for filtering ancillary design matrix
%       .gapFillConfigurationStruct                    -- [struct]  gap fill config parameters
%       .bandSplittingConfigurationStruct              -- [struct]  band splitting input parameters
%       .goodnessMetricConfigurationStruct             -- [struct]  goodness metric input parameters
%       .ancillaryEngineeringDataStruct                -- [struct array]  engineering data for cotrending
%       .ancillaryPipelineDataStruct                   -- [struct array]  pipeline data for contrending
%       .motionBlobs                                   -- [blob series]  location of motion polynomials from PA
%       .pdcBlobs                                      -- [LC Blob data]  location of blob from LC PDC run for SC (quickMap and SPSD)
%       .cbvBlobs                                      -- [CBV Blob data] location of basis vectors for use with this run.
%       .targetDataStruct                              -- [struct array]  target flux to be corrected
%       .transits                                      -- [struct (OPTIONAL)] optional to import transits if not by target (see pdcTransitClass)
%
%--------------------------------------------------------------------------
%   Second level structures to PdcInputStruct:
%
%--------------------------------------------------------------------------
%   cadenceTimes and longCadenceTimes      -- [struct]
%       .startTimestamps                     -- [double array]  cadence start times, MJD
%       .midTimestamps                       -- [double array]  cadence mid times, MJD
%       .endTimestamps                       -- [double array]  cadence end times, MJD
%       .gapIndicators                       -- [logical array]  true if cadence is unavailable
%       .requantEnabled                      -- [logical array]  true if requantization was enabled
%       .cadenceNumbers                      -- [int array]  absolute cadence numbers
%       .isSefiAcc                           -- [logical array]  not used in pipeline
%       .isSefiCad                           -- [logical array]  not used in pipeline
%       .isLdeOos                            -- [logical array]  not used in pipeline
%       .isFinePnt                           -- [logical array]  true if on fine point for cadence
%       .isMmntmDmp                          -- [logical array]  true if desat on cadence
%       .isLdeParEr                          -- [logical array]  not used in pipeline
%       .isScrcErr                           -- [logical array]  not used in pipeline
%       .dataAnomalyFlags                    -- [struct]  anomaly indicators per cadence (see below)
%       .quarter                             -- [int array]  quarter number
%       .month                               -- [int array]  Month number (1,2,3)
%
%--------------------------------------------------------------------------
%       NOTE: This struct contains a lot of old PDC-LS parameters
%   pdcModuleParameters                 -- [struct]
%       .debugLevel                         -- [int]  level for science debug
%       .robustCotrendFitFlag               -- [logical]  robust (vs. SVD LS) fit if true
%       .medianFilterLength                 -- [int]  samples in median filter for outlier detection
%       .outlierThresholdXFactor            -- [float]  number of sigmas from mu to set outlier thresholds
%       .normalizationEnabled               -- [logical]  normalize quarter to quarter variations in target flux if true
%       .stellarVariabilityDetrendOrder     -- [int]  order for detrending to identify variable targets
%       .stellarVariabilityThreshold        -- [float]  threshold for identification of variable targets
%       .minHarmonicsForDetrending          -- [int]  minimum number of harmonics for harmonics detrending
%       .harmonicDetrendOrder               -- [int]  order for harmonics detrending
%       .thermalRecoveryDurationInDays      -- [float]  duration of nominal safe mode recovery transient
%       .neighborhoodRadiusForAttitudeTweak -- [int]  buffer near tweaks for coarse error correction (cadences)
%       .attitudeTweakBufferInDays          -- [float]  buffer near tweaks for identification of astro events
%       .safeModeBufferInDays               -- [float]  buffer near safe modes for identification of astro events
%       .earthPointBufferInDays             -- [float]  buffer near earth points for identification of astro events
%       .coarsePointBufferInDays            -- [float]  buffer near coarse points for identification of astro events
%       .astrophysicalEventBridgeInDays     -- [float]  time to bridge astro events near data anomalies
%       .cotrendRatioMaxTimeScaleInDays     -- [float]  max time scale for computation of corrected flux to raw flux power
%       .cotrendPerformanceLimit            -- [float]  limit to accept cotrending results
%       .mapEnabled                         -- [logical]  flag whether to use MAP or old PDC (least-square with AED)
%       .bandSplittingEnabled               -- [logical] flag whether multi-scale MAP is performed
%       .excludeTargetLabels                -- [string array]  label strings to exclude from goodness metric
%       .harmonicsRemovalEnabled            -- [logical]  flag whether or not to remove harmonics for MAP (and add them back afterwards)
%       .preMapIterations                   -- [int]  number of iterations for pre-MAP operations (Discontinuities, Harmonic, Outliers)
%       .variabilityDetrendPolyOrder        -- [int] When calulcating the stellar varibaility use this polynomial order to first detrend
%       .variabilityEpRecoveryMaskEnabled   -- [logical] flag whether the earth point thermal recovery regions are masked before finding stellar variability
%       .variabilityEpRecoveryMaskWindow    -- [int] nunber of cadences past the earth point to mask for finding stellar variability
%       .mapSelectionMethod                 -- [char] Method to use for selecting which MAP type to use for results. (see presearch_dat_conditioning_map.m)
%       .stellarVariabilityRemoveEclipsingBinariesEnabled -- [logical] flag whether to remove ecplitpsing binaries before finding stellar variability
%       .mapSelectionMethodCutoff           -- [float] Goodness cutoff value for reverting back to regular MAP (I.E. above this cutoff, always use msMAP)
%       .mapSelectionMethodMultiscaleBias   -- [float] Goodness bias toward msMAP (e.g. if regMAP = 0.75 and msMAP = 0.7, msMAP will still be chosen)
%
%--------------------------------------------------------------------------
%   mapConfigurationStruct
%       .coarseDetrendPolyOrder
%       .debugRun
%       .denoiseBasisVectorsEnabled         -- [logical] Denoise the basis vectors
%       .ditherFlux                         -- [logical] Do we dither the normalized flux for SVD and basis vector generation?
%       .ditherMagnitude                    -- [double] If dithering then shift by this uniform percentage range over the absolute max flux range
%       .entropyCleaningEnabled             -- [logical] turn on entropy cleaning
%       .entropyCleaningCutoff              -- [double] entropy value limit for good entropy and no more cleaning is necessary (should be negative!)
%       .entropyMadFactor                   -- [double] remove the basis vectors that are this many times the mad contribution in the V matrix
%       .entropyMaxIterations               -- [int32] iterate the entropy cleaner this many times
%       .fitNormalizationMethod             -- [char] how to normalize the light curves for MAP fitting 
%       .forceRobustFit                     -- [logical] it true then only use the reduced robust fit for this MAP run
%       .fractionOfStarsToUseForPriorPdf    -- [double] Use this fraction sorted by target-target correlation
%       .fractionOfStarsToUseForSvd         -- [double] Use this fraction sorted by target-target correlation
%       .goodnessMetricIterationsCutoff     -- [double} cutoff where goodness iterator keeps working to improve goodness
%       .goodnessMetricIterationsEnabled    -- [logical] Tunr on Goodness Metric iterations
%       .goodnessMetricIterationsPriorWeightStepSize    -- [double] By what step factor to adjust prior weight for each iteration
%       .goodnessMetricMaxIterations        -- [int32] max goodness metric iterations
%       .maxNumMaximizerIteration           -- [int32] max iteratison to bracket the PDF maximum. If max hit then use default range.
%       .maxTolerance                       -- [double] fit tolerance for PDF fminbnd maximizer
%       .minFractionOfTargetsForSvd         -- [double] minimum fraction of targets for basis vector generation. If below this fraction then crash with error
%       .numPointsForMaximizerFirstGuess    -- [int32] Number of points in sweep to bracket maximum of PDF
%       .priorCentroidMotionScalingFactor   -- [double] Relative weight of centroid motion in prior target weighting
%       .priorDecScalingFactor              -- [double] Relative weight of Dec in prior target weighting
%       .priorEffTempScalingFactor          -- [double] Relative weight of effective temperature in prior target weighting
%       .priorGoodnessPowerFactor           -- [double] Scaling for prior goodness
%       .priorGoodnessScalingFactor         -- [double] Scaling for prior goodness
%       .priorKeplerMagnitudeScalingFactor  -- [double] Relative weight of KepMag in prior target weighting
%       .priorLogRadiusScalingFactor        -- [double] Relative weight of Log radius in prior target weighting
%       .priorPdfGoodnessGain               -- [double] Relative weight of prior goodness in prior weight
%       .priorPdfGoodnessWeight             -- [double] power scaling of prior goodness in prior weight
%       .priorPdfVariabilityWeight          -- [double] power scaling of stellar variability in prior weight
%       .priorRaScalingFactor               -- [double] Relative weight of RA in prior target weighting
%       .priorWeightGoodnessCutoff          -- [double] If prior goodness is below this value then use a reduced robust fit to basis vectors
%       .priorWeightVariabilityCutoff       -- [double] If prior weight is below this value then use a reduced robust fit to basis vectors
%       .quickMapEnabled                    -- [logical] Perform quickMAP
%       .quickMapVariabilityCutoff          -- [double] Stellar variability value where targets are declared variable
%       .randomStreamSeed                   -- [double] Random stream seed used in MAP
%       .spikeBasisVectorWindow             -- [int32] median filter for generating spike basis vectors
%       .spikeIsolationEnabled              -- [logical] Do find spike basis vectors in this MAP run
%       .svdMaxOrder                        -- [int32] Maximum number of SVD left singular vectors and basis vectors per MAP run
%       .svdNormalizationMethod             -- [char] how to normalize the light curves for SVD
%       .svdOrder                           -- [int32] Explicit number of basis vectors, set to 0 to auto-find (up to svdMaxOrder)
%       .svdOrderForReducedRobustFit        -- [int32] Number of basis vectors to use for a reduced robust fit
%       .svdSnrCutoff                       -- [double] When limiting the number of basis vectors only keep those with an SNR above this value.
%       .useBasisVectorsAndPriorsFromBlob   -- [logical] Use the basis vectors and Priors from the blob file
%       .useBasisVectorsAndPriorsFromPixels -- [logical] experimental, always set to false unless you know what this is!
%       .useBasisVectorsFromBlob            -- [logical] Use the basis vectors from the blob file
%       .useCentroidPriors                  -- [logical] Utilize target centroids and optimal apertures to obtain better priors.
%       .useOnlyQuietStarsForPriorPdf       -- [logical] Only use targets with value < variabilityCutoff
%       .useOnlyQuietStarsForSvd            -- [logical] Only use targets with value < variabilityCutoff
%       .variabilityCutoff                  -- [double] Stellar variability value where targets are declared variable
%
%-------------------------------------------------------------------------
%  spsdDetectionConfigurationStruct see spsd_controller.m
%
%       .discontinuityRatioTolerance
%       .endpointFitWindowWidth
%       .excludeWindowHalfWidth
%       .falsePositiveRateLimit
%       .harmonicsRemovalEnabled
%       .maxDetectionIterations
%       .quickSpsdEnabled
%       .transitSpsdMinmaxDiscriminator
%       .useCentroids
%       .validationSignificanceThreshold
%
%-------------------------------------------------------------------------
%  spsdDetectorConfigurationStruct see spsd_controller.m
%
%       .minWindowWidth
%       .mode
%       .sgPolyOrder
%       .sgStepPolyOrder
%       .shortSgPolyOrder
%       .shortSgStepPolyOrder
%       .shortWindowWidth
%       .windowWidth
%
%--------------------------------------------------------------------------
%   spsdRemovalConfigurationStruct see spsd_controller.m
%
%       .bigPicturePolyOrder
%       .harmonicFalsePositiveRate
%       .logTimeConstantIncrement
%       .logTimeConstantMaxValue
%       .logTimeConstantStartValue
%       .polyWindowHalfWidth
%       .recoveryWindowWidth
%       .shortCadencePostCorrectionEnabled
%       .shortCadencePostCorrectionLeftWindow
%       .shortCadencePostCorrectionMethod
%       .shortCadencePostCorrectionRightWindow
%       .useMapBasisVectors
%
%--------------------------------------------------------------------------
%   saturationSegmentConfigurationStruct
%       .sgPolyOrder                        -- [int]  order of Savitzky-Golay filter to detect saturated segments
%       .sgFrameSize                        -- [int]  length of Savitzky-Golay frame
%       .satSegThreshold                    -- [float]  threshold for identifying saturated segments
%       .satSegExclusionZone                -- [int]  zone for excluding secondary peaks
%       .maxSaturationMagnitude             -- [float]  highest magnitude target that can still be saturated
% 
%--------------------------------------------------------------------------
%   harmonicsIdentificationConfigurationStruct
%       .medianWindowLengthForTimeSeriesSmoothing   -- [int]  length of median filter for time domain filtering in units of cadences
%       .medianWindowLengthForPeriodogramSmoothing  -- [int]  length of median filter for frequency domain filtering in units of cadences
%       .movingAverageWindowLength                  -- [int]  length of periodogram smoothing filter in units of cadences
%       .falseDetectionProbabilityForTimeSeries     -- [float]  probability of identifying one or more false component detections in a given time series
%       .minHarmonicSeparationInBins                -- [int]  minimum required separation for any two frequency components to be identified and fitted in a 
%                                                              given iteration; 
%                                                               components from iteration to iteration can (and often will) be more closely spaced than this
%       .maxHarmonicComponents                      -- [int]  maximum number of harmonic components for a given time series
%       .timeOutInMinutes                           -- [float]  timeout limit in minutes for a given time series
%
%--------------------------------------------------------------------------
%   discontinuityConfigurationStruct
%       .discontinuity model                    -- [float array]  coefficients for discontinuity identification
%       .medianWindowLength                     -- [int]  length of median filter
%       .savitzkyGolayFilterLength              -- [int]  length of Savitzky-Golay filter
%       .savitzkyGolayPolyOrder                 -- [int]  order of Savitzky-Golay filter
%       .discontinuityThresholdInSigma          -- [float]  discontinuity detection threshold
%       .ruleOutTransitRatio                    -- [float]  discriminator between discontinuities and transits
%       .varianceWindowLengthMultiplier         -- [int]  multiplier for S-G filter length for window to estimate variance
%       .maxNumberOfUnexplainedDiscontinuities  -- [int]  max allowable discontinuities per target
%
%--------------------------------------------------------------------------
%   ancillaryEngineeringConfigurationStruct
%       .mnemonics                  -- [string array]  mnemonic names
%       .modelOrders                -- [int array]  polynomial orders for cotrending
%       .interactions               -- [string array]  array of mnemonic pairs ('|' separated) for cotrending interactions
%       .quantizationLevels         -- [float array]  engineering data step sizes
%       .intrinsicUncertainties     -- [float array]  engineering data uncertainties
%
%--------------------------------------------------------------------------
%   ancillaryPipelineConfigurationStruct
%       .mnemonics          -- [string array]  mnemonic names
%       .modelOrders        -- [int array]  polynomial orders for cotrending
%       .interactions       -- [string array]  array of mnemonic pairs ('|' separated) for cotrending interactions
%
%--------------------------------------------------------------------------
%   ancillaryDesignMatrixConfigurationStruct
%       .filteringEnabled   -- [logical]  filter design matrix columns if true
%       .sgPolyOrders       -- [int array]  polynomial orders for multi-stage Savitsky-Golay filtering
%       .sgFrameSizes       -- [int array]  frame sizes for multi-stage Savitsky-Golay filtering
%       .bandpassFlags      -- [logical array]  include lowpass, midpass, highpass design matrix columns respectively if true
%
%--------------------------------------------------------------------------
%   gapFillConfigurationStruct
%       .madXFactor                             -- [float]  MAD multiplication factor
%       .maxGiantTransitDurationInHours         -- [float]  maximum giant transit duration (hours)
%       .giantTransitPolyFitChunkLengthInHours  --[float]  giant transit poly fit chunk length (hours)
%       .maxDetrendPolyOrder                    -- [int]  maximum detrend polynomial order
%       .maxArOrderLimit                        -- [int]  maximum AR order
%       .maxCorrelationWindowXFactor            -- [int]  maximum correlation window multiplication factor
%       .gapFillModeIsAddBackPredictionError    -- [logical]  true if gap fill mode is add back prediction error
%       .removeEclipsingBinariesOnList          -- [logical]  true if short period binaries are to be removed prior to giant transit identification
%       .waveletFamily                          -- [string]  name of wavelet family, e.g. 'daub'
%       .waveletFilterLength                    -- [int]  number of wavelet filter coefficients
%
%--------------------------------------------------------------------------
%   Second level
%
%     ancillaryEngineeringDataStruct is an array of structs (one per engineering
%     mnemonic) with the following fields:
%
%                       mnemonic: [string]  name of ancillary channel
%               timestamps: [double array]  engineering time tags, MJD
%                    values: [float array]  engineering data values
%
%--------------------------------------------------------------------------
%   Second level
%
%     ancillaryPipelineDataStruct is an array of structs (one per pipeline mnemonic) 
%     with the following fields:
%
%                       mnemonic: [string]  name of ancillary channel
%               timestamps: [double array]  pipeline time tags, MJD
%                    values: [float array]  pipeline data values
%             uncertainties: [float array]  pipeline data uncertainties
%
%--------------------------------------------------------------------------
%   targetDataStruct   -- [struct array(nTargets)]
%       .keplerId               -- [int]  kepler target ID
%       .keplerMag              -- [float]  target magnitude
%       .labels                 -- [string array]  target label strings
%       .fluxFractionInAperture -- [float]  fraction of target flux captured in aperture
%       .crowdingMetric         -- [float]  fraction of total flux in aperture due to target
%       .values                 -- [float array]  flux values to be corrected
%       .uncertainties          -- [float array]  uncertainties in flux values
%       .gapIndicators          -- [logical array]  flux gap indicators
%       .excludeBasedOnLabels   -- [logcial] exclude from MAP statistics and for finding basis vectoes and priors
%       .kic                    -- [struct]  KIC fields
%       .transits               -- [transitStruct] list of known transits in this target. See pdcTransitClass for details.
%       .optimalAperture        -- [struct] the optimal aperture for this target
%
%--------------------------------------------------------------------------
%     cadenceTimes.dataAnomalyFlags
%       .attitudeTweakIndicators    -- [logical array]  attitude tweak cadence markers
%       .safeModeIndicators         -- [logical array]  safe mode cadence markers
%       .earthPointIndicators       -- [logical array]  Earth-point cadence markers
%       .coarsePointIndicators      -- [logical array]  coarse-point cadence markers
%       .argabrighteningIndicators  -- [logical array]  global Argabrightening cadence markers
%       .excludeIndicators          -- [logical array]  markers for cadences to exclude
%
%--------------------------------------------------------------------------
%   kic
%       .keplerId               --    [int]  Kepler target ID
%       .keplerMag              -- [struct]  target Kepler magnitude (KEPMAG)
%       .ra                     -- [struct]  target right ascension, hours (RA)
%       .dec                    -- [struct]  target declination, degrees (DEC)
%       .radius                 -- [struct]  target radius, solar units (RADIUS)
%       .effectiveTemp          -- [struct]  target effective temperature, Kelvin (TEFF)
%       .log10SurfaceGravity    -- [struct]  log target surface gravity, cm/sec^2 (LOGG)
%       .log10Metallicity       -- [struct]  log Fe/H metallicity, solar (FEH)
%       .raProperMotion         -- [struct]  target proper motion in right ascension, arc sec per year (PMRA)
%       .decProperMotion        -- [struct]  target proper motion in declination, arc sec per year (PMDEC)
%       .totalProperMotion      -- [struct]  target total proper motion, arc sec per year (PMTOTAL)
%       .parallax               -- [struct]  target parallax, arc sec (PARALLAX)
%       .uMag                   -- [struct]  target u-band magnitude (UMAG)
%       .gMag                   -- [struct]  target g-band magnitude (GMAG)
%       .rMag                   -- [struct]  target r-band magnitude (RMAG)
%       .iMag                   -- [struct]  target i-band magnitude (IMAG)
%       .zMag                   -- [struct]  target z-band magnitude (ZMAG)
%       .gredMag                -- [struct]  target GRed-band magnitude (GREDMAG)
%       .d51Mag                 -- [struct]  target D51-band magnitude (D51MAG)
%       .twoMassId              -- [struct]  target 2MASS ID (TMID)
%       .twoMassJMag            -- [struct]  target 2MASS J-band magnitude (JMAG)
%       .twoMassHMag            -- [struct]  target 2MASS H-band magnitude (HMAG)
%       .twoMassKMag            -- [struct]  target 2MASS K-band magnitude (KMAG)
%       .scpId                  -- [struct]  target SCP ID (SCPKEY)
%       .internalScpId          -- [struct]  target internal SCP ID (SCPID)
%       .catalogId              -- [struct]  target catalog key (CATKEY)
%       .alternateId            -- [struct]  target alternate ID (ALTID)
%       .alternateSource        -- [struct]  target alternate source (ALTSOURCE)
%       .galaxyIndicator        -- [struct]  target galaxy indicator (GALAXY)
%       .blendIndicator         -- [struct]  target blend indicator (BLEND)
%       .variableIndicator      -- [struct]  target variable indicator (VARIABLE)
%       .ebMinusVRedding        -- [struct]  target E(B-V) reddening, magnitudes (EBMINUSV)
%       .avExinction            -- [struct]  target A_V extinction, magnitudes (AV)
%       .photometryQuality      -- [struct]  target photometry quality indicator (PQ)
%       .astrophysicsQuality    -- [struct]  target astrophysics quality indicator (AQ)
%       .galacticLatitude       -- [struct]  target galactic latitude (GLAT)
%       .galacticLongitude      -- [struct]  target galactic longitude (GLON)
%       .grColor                -- [struct]  target g-r color, magnitudes (GRCOLOR)
%       .jkColor                -- [struct]  target J-K color, magnitudes (JKCOLOR)
%       .gkColor                -- [struct]  target g-K color, magnitudes (GKCOLOR)
%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% OUTPUT:  An object 'pdcInputObject' of class 'pdcInputClass' 
%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Comments: This function generates an error under the following scenarios:
%
%          (1) when invoked with no inputs
%          (2) when any of the fields are missing
%          (3) when any of the fields are NaNs/Infs or outside the
%              appropriate bounds
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

classdef pdcInputClass

properties(Constant)
    % Set constant for custom targets with undefined keplerMag.
    DEFAULT_KEPLER_MAG = 20;
    PDCVERSION = 9.3
end


properties(GetAccess = 'public', SetAccess = 'private')
    pdcVersion = 0;                                     % [float] SOC pipeline version
    multiChannelRun = false;                            % [logical] if this is a multi-channel PDC run
    ccdModule = [];                                     % [int]  CCD module number
    ccdOutput = [];                                     % [int]  CCD output number
    cadenceType = [];                                   % [string]  'LONG' or 'SHORT'
    startCadence = [];                                  % [int]  start cadence index
    endCadence = [];                                    % [int]  end cadence index
    fcConstants = [];                                   % [struct]  Fc constants
    spacecraftConfigMap = [];                           % [struct array]  one or more spacecraft config maps
    raDec2PixModel = [];                                % [struct]  ra/dec to pixel model
    cadenceTimes = [];                                  % [struct]  cadence times and gap indicators
    longCadenceTimes = [];                              % [struct]  long cadence times and gap indicators for attitude solution
    pdcModuleParameters = [];                           % [struct]  module parameters
    mapConfigurationStruct = [];                        % [struct]  MAP parameters
    spsdDetectionConfigurationStruct = [];              % [struct]  SPSD Detector parameters
    spsdDetectorConfigurationStruct = [];               % [struct]  SPSD Detection parameters
    spsdRemovalConfigurationStruct = [];                % [struct]  SPSD Removal parameters
    saturationSegmentConfigurationStruct = [];          % [struct]  saturation segment identification parameters
    harmonicsIdentificationConfigurationStruct = [];    % [struct]  harmonics identification parameters
    discontinuityConfigurationStruct = [];              % [struct]  discontinuity identification parameters
    ancillaryEngineeringConfigurationStruct = [];       % [struct]  config parameters for engineering data
    ancillaryPipelineConfigurationStruct = [];          % [struct]  config parameters for pipeline data
    ancillaryDesignMatrixConfigurationStruct = [];      % [struct]  module parameters for filtering ancillary design matrix
    gapFillConfigurationStruct = [];                    % [struct]  gap fill config parameters
    bandSplittingConfigurationStruct = [];              % [struct] band splitting input parameters
    goodnessMetricConfigurationStruct = [];             % [struct] goodness metric input parameters
    ancillaryEngineeringDataStruct = [];                % [struct array]  engineering data for cotrending
    ancillaryPipelineDataStruct = [];                   % [struct array]  pipeline data for contrending
    transits = [];                                      % [struct]  transit data for known transits
    motionPolyStruct = [];                              % [blob series]  motion polynomials from PA
    multiChannelMotionPolyStruct = [];                  % [blob series array]  motion polynomials from PA for each channel in a multi-channel run
    pdcBlobs = [];                                      % [LC Blob data]  Data from LC PDC run for SC (quickMap and SPSD)
    cbvBlobs = [];                                      % [CBV Blob data]  Saved basis vectors for use with this run.
    targetDataStruct = [];                              % [struct array]  target flux to be corrected
    channelDataStruct = [];                             % Vestigual, just contains module and outputs for the benefit of creating the outputsStruct
    thrusterDataAncillaryEngineeringConfigurationStruct = []; % [struct] specifies how to identify thruster firing events   
    thrusterFiringDataStruct = [];                      % [struct] thrusterFiring data synced to long or short cadence data
    thisIsK2Data = false;                               % [logical] if true then this is K2 data
end

%*******************************************************************************

methods

%*******************************************************************************
% Constructor
function obj = pdcInputClass(pdcInputStruct)

% If no input, generate an error.
if nargin == 0
    error('PDC:pdcInputClass:EmptyInputStruct', ...
        'The constructor must be called with an input structure')
end

% UPDATE OLD PDC INPUT STRUCTURES FOR CURRENT. This call only occurs if this is not a release branch
import gov.nasa.kepler.common.KeplerSocBranch;
if(~KeplerSocBranch.isRelease())
    % Call the most recent conversion function which will in-turn recursively call all the others
    [pdcInputStruct] = pdc_convert_92_data_to_93(pdcInputStruct);
else
  % Set PDC version
  pdcInputStruct.pdcVersion = pdcInputClass.PDCVERSION;
end

% Identify if this is K2 data
if (isfield(pdcInputStruct.fcConstants, 'KEPLER_END_OF_MISSION_MJD') && ...
        pdcInputStruct.cadenceTimes.midTimestamps(find(~pdcInputStruct.cadenceTimes.gapIndicators,1))  > pdcInputStruct.fcConstants.KEPLER_END_OF_MISSION_MJD)
    % This is K2 data
    thisIsK2Data = true;
else
    thisIsK2Data = false;
end

%***
% KSOC-3899 group channels together for K2 data.
% We need to process the pdcInputStruct.channelDataStruct
pdcInputStruct = obj.process_channelDataStruct(pdcInputStruct);

%***
% Convert the motion blob series to motion polynomials. Attach it to the
% PDC data structure and remove the motion blobs. Do something reasonable
% for backward compatibility with PDC data structures that do not include
% motion blobs.
%
% Motion polynomials are per channel.
if isfield(pdcInputStruct, 'motionBlobs')
    if (pdcInputStruct.multiChannelRun)
        for iChannel = 1 : length(pdcInputStruct.motionBlobs)
            pdcInputStruct.multiChannelMotionPolyStruct(iChannel).motionPolyStruct = poly_blob_series_to_struct(pdcInputStruct.motionBlobs(iChannel));
        end
    else
        pdcInputStruct.motionPolyStruct = poly_blob_series_to_struct(pdcInputStruct.motionBlobs);
    end
    pdcInputStruct = rmfield(pdcInputStruct, 'motionBlobs');
else
    pdcInputStruct.motionPolyStruct = [];
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
% Validate all fields in pdcInputStruct.
%--------------------------------------------------------------------------
fieldsAndBounds = cell(18,4);
fieldsAndBounds(1,:)  = { 'ccdModule';  []; []; '[-1 2:4, 6:20, 22:24]'''}; % if -1 then multi channel run
fieldsAndBounds(2,:)  = { 'ccdOutput';  []; []; '[-1 1 2 3 4]'''}; % if -1 then multi channel run
fieldsAndBounds(3,:)  = { 'cadenceType'; []; []; {'LONG' ; 'SHORT'}};
fieldsAndBounds(4,:)  = { 'startCadence'; '>= 0'; '< 2e7'; []};
fieldsAndBounds(5,:)  = { 'endCadence'; '>= 0'; '< 2e7'; []};
fieldsAndBounds(6,:)  = { 'fcConstants'; []; []; []};             % Validate only needed fields
fieldsAndBounds(7,:)  = { 'spacecraftConfigMap'; []; []; []};     % Do not validate
fieldsAndBounds(8,:)  = { 'raDec2PixModel'; []; []; []};          % Do not validate
fieldsAndBounds(9,:)  = { 'cadenceTimes'; []; []; []};
fieldsAndBounds(10,:) = { 'longCadenceTimes'; []; []; []};
fieldsAndBounds(11,:) = { 'pdcModuleParameters'; []; []; []};
fieldsAndBounds(12,:) = { 'ancillaryEngineeringConfigurationStruct'; []; []; []};
fieldsAndBounds(13,:) = { 'ancillaryPipelineConfigurationStruct'; []; []; []};
fieldsAndBounds(14,:) = { 'ancillaryDesignMatrixConfigurationStruct'; []; []; []};
fieldsAndBounds(15,:) = { 'gapFillConfigurationStruct'; []; []; []};
fieldsAndBounds(16,:) = { 'ancillaryEngineeringDataStruct'; []; []; []};  % Validate if exists
fieldsAndBounds(17,:) = { 'ancillaryPipelineDataStruct'; []; []; []};     % Validate if exists
fieldsAndBounds(18,:) = { 'targetDataStruct'; []; []; []};
fieldsAndBounds(19,:) = { 'thrusterDataAncillaryEngineeringConfigurationStruct'; []; []; []};
% Note: motionPolyStruct can also be a multi-channel motionPolyStruct

validate_structure(pdcInputStruct, fieldsAndBounds, 'pdcInputStruct');

clear fieldsAndBounds;

% Set debug flag to zero if it was not specified.
if ~isfield(pdcInputStruct.pdcModuleParameters, 'debugLevel')
        pdcInputStruct.pdcModuleParameters.debugLevel = 0;
end

%--------------------------------------------------------------------------
% Second level validation.
% Validate the structure field pdcInputStruct.fcConstants (only needed
% fields).
%--------------------------------------------------------------------------


%--------------------------------------------------------------------------
% Second level validation.
% Validate the structure field pdcInputStruct.cadenceTimes.
%--------------------------------------------------------------------------
cadenceTimes = pdcInputStruct.cadenceTimes;

if isfield(cadenceTimes, 'gapIndicators')
    if isfield(cadenceTimes, 'startTimestamps')
        cadenceTimes.startTimestamps = ...
            cadenceTimes.startTimestamps(~cadenceTimes.gapIndicators);
    end
    if isfield(cadenceTimes, 'midTimestamps')
        cadenceTimes.midTimestamps = ...
            cadenceTimes.midTimestamps(~cadenceTimes.gapIndicators);
    end
    if isfield(cadenceTimes, 'endTimestamps')
        cadenceTimes.endTimestamps = ...
            cadenceTimes.endTimestamps(~cadenceTimes.gapIndicators);
    end
end

fieldsAndBounds = cell(16,4);
fieldsAndBounds(1,:)  = { 'startTimestamps'; '> 54500'; '< 70000'; []}; % 2/4/2008 to 7/13/2050
fieldsAndBounds(2,:)  = { 'midTimestamps'; '> 54500'; '< 70000'; []};   % 2/4/2008 to 7/13/2050
fieldsAndBounds(3,:)  = { 'endTimestamps'; '> 54500'; '< 70000'; []};   % 2/4/2008 to 7/13/2050
fieldsAndBounds(4,:)  = { 'gapIndicators'; []; []; [true; false]};
fieldsAndBounds(5,:)  = { 'requantEnabled'; []; []; [true; false]};
fieldsAndBounds(6,:)  = { 'cadenceNumbers'; '>= 0'; '< 2e7'; []};
fieldsAndBounds(7,:)  = { 'isSefiAcc'; []; []; [true; false]};
fieldsAndBounds(8,:)  = { 'isSefiCad'; []; []; [true; false]};
fieldsAndBounds(9,:)  = { 'isLdeOos'; []; []; [true; false]};
fieldsAndBounds(10,:) = { 'isFinePnt'; []; []; [true; false]};
fieldsAndBounds(11,:) = { 'isMmntmDmp'; []; []; [true; false]};
fieldsAndBounds(12,:) = { 'isLdeParEr'; []; []; [true; false]};
fieldsAndBounds(13,:) = { 'isScrcErr'; []; []; [true; false]};
fieldsAndBounds(14,:) = { 'dataAnomalyFlags'; []; []; []};
fieldsAndBounds(15,:) = { 'quarters'; []; []; []}; % Can be empty set, so can;t use validate_structure to validate ranges!
fieldsAndBounds(16,:) = { 'months'; []; []; []}; % Can be empty set, so can;t use validate_structure to validate ranges!

validate_structure(cadenceTimes, fieldsAndBounds, 'pdcInputStruct.cadenceTimes');

clear fieldsAndBounds;

%--------------------------------------------------------------------------
% Second level validation.
% Validate the structure field pdcInputStruct.longCadenceTimes.
%--------------------------------------------------------------------------
cadenceTimes = pdcInputStruct.longCadenceTimes;

if isfield(cadenceTimes, 'gapIndicators')
    if isfield(cadenceTimes, 'startTimestamps')
        cadenceTimes.startTimestamps = ...
            cadenceTimes.startTimestamps(~cadenceTimes.gapIndicators);
    end
    if isfield(cadenceTimes, 'midTimestamps')
        cadenceTimes.midTimestamps = ...
            cadenceTimes.midTimestamps(~cadenceTimes.gapIndicators);
    end
    if isfield(cadenceTimes, 'endTimestamps')
        cadenceTimes.endTimestamps = ...
            cadenceTimes.endTimestamps(~cadenceTimes.gapIndicators);
    end
end

fieldsAndBounds = cell(16,4);
fieldsAndBounds(1,:)  = { 'startTimestamps'; '> 54500'; '< 70000'; []}; % 2/4/2008 to 7/13/2050
fieldsAndBounds(2,:)  = { 'midTimestamps'; '> 54500'; '< 70000'; []};   % 2/4/2008 to 7/13/2050
fieldsAndBounds(3,:)  = { 'endTimestamps'; '> 54500'; '< 70000'; []};   % 2/4/2008 to 7/13/2050
fieldsAndBounds(4,:)  = { 'gapIndicators'; []; []; [true; false]};
fieldsAndBounds(5,:)  = { 'requantEnabled'; []; []; [true; false]};
fieldsAndBounds(6,:)  = { 'cadenceNumbers'; '>= 0'; '< 2e7'; []};
fieldsAndBounds(7,:)  = { 'isSefiAcc'; []; []; [true; false]};
fieldsAndBounds(8,:)  = { 'isSefiCad'; []; []; [true; false]};
fieldsAndBounds(9,:)  = { 'isLdeOos'; []; []; [true; false]};
fieldsAndBounds(10,:) = { 'isFinePnt'; []; []; [true; false]};
fieldsAndBounds(11,:) = { 'isMmntmDmp'; []; []; [true; false]};
fieldsAndBounds(12,:) = { 'isLdeParEr'; []; []; [true; false]};
fieldsAndBounds(13,:) = { 'isScrcErr'; []; []; [true; false]};
fieldsAndBounds(14,:) = { 'dataAnomalyFlags'; []; []; []};
fieldsAndBounds(15,:) = { 'quarters'; []; []; []}; % Can be empty set, so can;t use validate_structure to validate ranges!
fieldsAndBounds(16,:) = { 'months'; []; []; []}; % Can be empty set, so can;t use validate_structure to validate ranges!

validate_structure(cadenceTimes, fieldsAndBounds, 'pdcInputStruct.longCadenceTimes');

clear fieldsAndBounds;

%--------------------------------------------------------------------------
% Second level validation.
% Validate the structure field pdcInputStruct.pdcModuleParameters.
%--------------------------------------------------------------------------
fieldsAndBounds = cell(27,4);
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
fieldsAndBounds(23,:) = { 'bandSplittingEnabled'; []; []; [true; false]};
fieldsAndBounds(24,:) = { 'stellarVariabilityRemoveEclipsingBinariesEnabled'; []; []; [true; false]};
fieldsAndBounds(25,:) = { 'mapSelectionMethod'; []; []; []};
fieldsAndBounds(26,:) = { 'mapSelectionMethodCutoff'; '>=0'; '<=1.0'; []};
fieldsAndBounds(27,:) = { 'mapSelectionMethodMultiscaleBias'; '>=0'; '<=1'; []};

validate_structure(pdcInputStruct.pdcModuleParameters, fieldsAndBounds, ...
    'pdcInputStruct.pdcModuleParameters');

clear fieldsAndBounds;

%--------------------------------------------------------------------------
% Second level validation.
% Validate the structure field pdcInputStruct.mapConfigurationStruct.
%--------------------------------------------------------------------------
fieldsAndBounds = cell(42,4);

fieldsAndBounds(1,:)   = { 'minFractionOfTargetsForSvd';        '>= 0'; '<= 1'; []};
fieldsAndBounds(2,:)   = { 'fractionOfStarsToUseForSvd';        '>= 0'; '<= 1'; []};      
fieldsAndBounds(3,:)   = { 'useOnlyQuietStarsForSvd';           []; []; [true; false]};      
fieldsAndBounds(4,:)   = { 'fractionOfStarsToUseForPriorPdf';   '>= 0'; '<= 1'; []};
fieldsAndBounds(5,:)   = { 'useOnlyQuietStarsForPriorPdf';      []; []; [true; false]};  
fieldsAndBounds(6,:)   = { 'fitNormalizationMethod';            []; []; []};         
fieldsAndBounds(7,:)   = { 'svdNormalizationMethod';            []; []; []};          
fieldsAndBounds(8,:)   = { 'numPointsForMaximizerFirstGuess';   '> 1'; []; []};
fieldsAndBounds(9,:)   = { 'maxNumMaximizerIteration';          '> 1'; []; []};    
fieldsAndBounds(10,:)  = { 'maxTolerance';                      '> 0'; '< 1'; []};                  
fieldsAndBounds(11,:)  = { 'randomStreamSeed';                  '>= 0'; []; []};                
fieldsAndBounds(12,:)  = { 'svdOrder';                          '>= 0'; []; []};
fieldsAndBounds(13,:)  = { 'svdMaxOrder';                       '>= 0'; []; []};                     
fieldsAndBounds(14,:)  = { 'svdOrderForReducedRobustFit';       '>= 0'; []; []};    
fieldsAndBounds(15,:)  = { 'svdSnrCutoff';                      []; []; []};                    
fieldsAndBounds(16,:)  = { 'ditherFlux';                        []; []; [true; false]};                     
fieldsAndBounds(17,:)  = { 'ditherMagnitude';                   []; []; []};                                     
fieldsAndBounds(18,:)  = { 'variabilityCutoff';                 '>= 0'; []; []};                                  
fieldsAndBounds(19,:)  = { 'coarseDetrendPolyOrder';            '>= 1'; []; []};
fieldsAndBounds(20,:)  = { 'priorPdfVariabilityWeight';         []; []; []};                           
fieldsAndBounds(21,:)  = { 'priorPdfGoodnessWeight';            []; []; []};                             
fieldsAndBounds(22,:)  = { 'priorPdfGoodnessGain';              []; []; []};                           
fieldsAndBounds(23,:)  = { 'priorWeightGoodnessCutoff';         '>= 0'; []; []};     
fieldsAndBounds(24,:)  = { 'priorWeightVariabilityCutoff';      '>= 0'; []; []};        
fieldsAndBounds(25,:)  = { 'priorGoodnessScalingFactor';        '>= 0'; []; []};           
fieldsAndBounds(26,:)  = { 'priorGoodnessPowerFactor';          '>= 0'; []; []};           
fieldsAndBounds(27,:)  = { 'priorKeplerMagnitudeScalingFactor'; '>= 0'; []; []};     
fieldsAndBounds(28,:)  = { 'priorRaScalingFactor';              '>= 0'; []; []};                 
fieldsAndBounds(29,:)  = { 'priorDecScalingFactor';             '>= 0'; []; []};               
fieldsAndBounds(29,:)  = { 'priorEffTempScalingFactor';         '>= 0'; []; []};               
fieldsAndBounds(29,:)  = { 'priorLogRadiusScalingFactor';       '>= 0'; []; []};               
fieldsAndBounds(30,:)  = { 'entropyCleaningEnabled';            []; []; [true; false]};                 
fieldsAndBounds(31,:)  = { 'entropyCleaningCutoff';             []; []; []};           
fieldsAndBounds(32,:)  = { 'entropyMadFactor';                  []; []; []};                        
fieldsAndBounds(33,:)  = { 'entropyMaxIterations';              '>= 0'; []; []};                          
fieldsAndBounds(34,:)  = { 'goodnessMetricIterationsEnabled';   []; []; [true; false]};        
fieldsAndBounds(35,:)  = { 'goodnessMetricIterationsCutoff';    '>= 0'; []; []};                        
fieldsAndBounds(36,:)  = { 'goodnessMetricIterationsPriorWeightStepSize'; []; []; []};                                 
fieldsAndBounds(37,:)  = { 'goodnessMetricMaxIterations';       '>= 0'; []; []};                             
fieldsAndBounds(38,:)  = { 'quickMapEnabled';                   []; []; [true; false]};             
fieldsAndBounds(39,:)  = { 'quickMapVariabilityCutoff';         '>= 0'; []; []};                                   
fieldsAndBounds(40,:)  = { 'forceRobustFit';                    []; []; [true; false]};                                   
fieldsAndBounds(41,:)  = { 'useCentroidPriors';                 []; []; [true; false]};                                   
fieldsAndBounds(42,:)  = { 'denoiseBasisVectorsEnabled';        []; []; [true; false]};

% Check that denoiseBasisVectorsEnabled is a scalar
if(length(pdcInputStruct.mapConfigurationStruct.denoiseBasisVectorsEnabled)>1)
    error('mapConfigurationStruct:check','denoiseBasisVectorsEnabled should be a scalar');
end

validate_structure(pdcInputStruct.mapConfigurationStruct, fieldsAndBounds, ...
    'pdcInputStruct.mapConfigurationStruct');

clear fieldsAndBounds;

%--------------------------------------------------------------------------
% Second level validation.
% Validate the structure field pdcInputStruct.goodnessMetricConfigurationStruct .
%--------------------------------------------------------------------------
fieldsAndBounds = cell(5,4);

fieldsAndBounds(1,:)   = { 'correlationScale';  '>= 0'; []; []};
fieldsAndBounds(2,:)   = { 'earthPointScale';   '>= 0'; []; []};
fieldsAndBounds(3,:)   = { 'variabilityScale';  '>= 0'; []; []};
fieldsAndBounds(4,:)   = { 'noiseScale';        '>= 0'; []; []};
fieldsAndBounds(5,:)   = { 'spikeScale';        '>= 0'; []; []};

validate_structure(pdcInputStruct.goodnessMetricConfigurationStruct , fieldsAndBounds, ...
    'pdcInputStruct.goodnessMetricConfigurationStruct ');

clear fieldsAndBounds;

%--------------------------------------------------------------------------
% Second level validation.
% Validate the structure field pdcInputStruct.pdcBlobs
%--------------------------------------------------------------------------
fieldsAndBounds = cell(5,4);

fieldsAndBounds(1,:)  = { 'blobFilenames'; []; []; []};
fieldsAndBounds(2,:)  = { 'gapIndicators'; []; []; []};
fieldsAndBounds(3,:)  = { 'blobIndices';   []; []; []};
fieldsAndBounds(4,:)  = { 'startCadence';  []; []; []};
fieldsAndBounds(5,:)  = { 'endCadence';    []; []; []};

% pdcBlobs are not used for multi-channel PDC
if (~pdcInputStruct.multiChannelRun)
    validate_structure(pdcInputStruct.pdcBlobs, fieldsAndBounds, 'pdcInputStruct.pdcBlobs');
end

clear fieldsAndBounds;

%--------------------------------------------------------------------------
% Second level validation.
% Validate the structure field pdcInputStruct.cbvBlobs
%--------------------------------------------------------------------------
fieldsAndBounds = cell(5,4);

fieldsAndBounds(1,:)  = { 'blobFilenames'; []; []; []};
fieldsAndBounds(2,:)  = { 'gapIndicators'; []; []; []};
fieldsAndBounds(3,:)  = { 'blobIndices';   []; []; []};
fieldsAndBounds(4,:)  = { 'startCadence';  []; []; []};
fieldsAndBounds(5,:)  = { 'endCadence';    []; []; []};

% cbvBlobs are not used for multi-channel PDC
if (~pdcInputStruct.multiChannelRun)
    validate_structure(pdcInputStruct.cbvBlobs, fieldsAndBounds, 'pdcInputStruct.cbvBlobs');
end

clear fieldsAndBounds;

%--------------------------------------------------------------------------
% Second level validation.
% Validate the structure field pdcInputStruct.spsdDetectorConfigurationStruct.
%--------------------------------------------------------------------------
fieldsAndBounds = spsdDetectorClass.get_fields_and_bounds(...
    pdcInputStruct.spsdDetectorConfigurationStruct);
validate_structure(pdcInputStruct.spsdDetectorConfigurationStruct, fieldsAndBounds, ...
    'pdcInputStruct.spsdDetectorConfigurationStruct');

clear fieldsAndBounds;

%--------------------------------------------------------------------------
% Second level validation.
% Validate the structure field pdcInputStruct.spsdDetectionConfigurationStruct.
%--------------------------------------------------------------------------
fieldsAndBounds = spsdCorrectedFluxClass.get_detection_fields_and_bounds();
validate_structure(pdcInputStruct.spsdDetectionConfigurationStruct, fieldsAndBounds, ...
    'pdcInputStruct.spsdDetectionConfigurationStruct');

clear fieldsAndBounds;


%--------------------------------------------------------------------------
% Second level validation.
% Validate the structure field pdcInputStruct.spsdRemovalConfigurationStruct.
%--------------------------------------------------------------------------
fieldsAndBounds = spsdCorrectedFluxClass.get_correction_fields_and_bounds(...
    pdcInputStruct.spsdRemovalConfigurationStruct);
validate_structure(pdcInputStruct.spsdRemovalConfigurationStruct, fieldsAndBounds, ...
    'pdcInputStruct.spsdRemovalConfigurationStruct');

clear fieldsAndBounds;


%--------------------------------------------------------------------------
% Second level validation.
% Validate the structure field pdcInputStruct.saturationSegmentConfigurationStruct.
%--------------------------------------------------------------------------
fieldsAndBounds = cell(5,4);
fieldsAndBounds(1,:)  = { 'sgPolyOrder'; '>= 2'; '<= 24'; []};
fieldsAndBounds(2,:)  = { 'sgFrameSize'; '>= 25'; '< 10000'; []};
fieldsAndBounds(3,:)  = { 'satSegThreshold'; '> 0'; '<= 1e6'; []};
fieldsAndBounds(4,:)  = { 'satSegExclusionZone'; '>= 1'; '<= 10000'; []};
fieldsAndBounds(5,:)  = { 'maxSaturationMagnitude'; '>= 6'; '<= 15'; []};

validate_structure(pdcInputStruct.saturationSegmentConfigurationStruct, ...
    fieldsAndBounds, 'pdcInputStruct.saturationSegmentConfigurationStruct');

clear fieldsAndBounds;

%--------------------------------------------------------------------------
% Second level validation.
% Validate the structure field pdcInputStruct.harmonicsIdentificationConfigurationStruct.
%--------------------------------------------------------------------------
fieldsAndBounds = cell(7,4);
fieldsAndBounds(1,:)  = { 'medianWindowLengthForTimeSeriesSmoothing'; '>= 1'; []; []};   % FOR NOW
fieldsAndBounds(2,:)  = { 'medianWindowLengthForPeriodogramSmoothing'; '>= 1'; []; []};  % FOR NOW
fieldsAndBounds(3,:)  = { 'movingAverageWindowLength'; '>= 1'; []; []};                  % FOR NOW
fieldsAndBounds(4,:)  = { 'falseDetectionProbabilityForTimeSeries'; '> 0'; '< 1'; []};   % FOR NOW
fieldsAndBounds(5,:)  = { 'minHarmonicSeparationInBins'; '>= 1'; '<= 1000'; []};         % FOR NOW
fieldsAndBounds(6,:)  = { 'maxHarmonicComponents'; '>= 1'; '<= 10000'; []};              % FOR NOW
fieldsAndBounds(7,:)  = { 'timeOutInMinutes'; '> 0'; '<= 180'; []};                      % FOR NOW

validate_structure(pdcInputStruct.harmonicsIdentificationConfigurationStruct, ...
    fieldsAndBounds, 'pdcInputStruct.harmonicsIdentificationConfigurationStruct');

clear fieldsAndBounds;

%--------------------------------------------------------------------------
% Second level validation.
% Validate the structure field pdcInputStruct.discontinuityConfigurationStruct.
%--------------------------------------------------------------------------
fieldsAndBounds = cell(8,4);
fieldsAndBounds(1,:)  = { 'discontinuityModel'; []; []; []};                  % TBD
fieldsAndBounds(2,:)  = { 'medianWindowLength'; '>= 1'; []; []};              % FOR NOW
fieldsAndBounds(3,:)  = { 'savitzkyGolayFilterLength'; '>= 1'; []; []};       % FOR NOW
fieldsAndBounds(4,:)  = { 'savitzkyGolayPolyOrder'; '>= 0'; []; []};          % FOR NOW
fieldsAndBounds(5,:)  = { 'discontinuityThresholdInSigma'; '> 0'; []; []};    % FOR NOW
fieldsAndBounds(6,:)  = { 'ruleOutTransitRatio'; '> 0'; []; []};              % FOR NOW
fieldsAndBounds(7,:)  = { 'varianceWindowLengthMultiplier'; '>= 1'; []; []};  % FOR NOW
fieldsAndBounds(8,:)  = { 'maxNumberOfUnexplainedDiscontinuities'; '>= 1'; []; []};  % FOR NOW

validate_structure(pdcInputStruct.discontinuityConfigurationStruct, ...
    fieldsAndBounds, 'pdcInputStruct.discontinuityConfigurationStruct');

clear fieldsAndBounds;

%--------------------------------------------------------------------------
% Second level validation.
% Validate the structure field pdcInputStruct.ancillaryEngineeringConfigurationStruct
% if there is ancillary engineering data.
%--------------------------------------------------------------------------
% KSOC-4504: The ancillary data can now take on two forms so we can no longer use the standard structure validator
% TODO: create a better validator that can handle different types and numbers of fields.
%if ~isempty(pdcInputStruct.ancillaryEngineeringDataStruct)
%    
%    fieldsAndBounds = cell(7,4);
%    fieldsAndBounds(1,:)  = { 'mnemonics'; []; []; {}}; % These are for one type of ancillary data
%    fieldsAndBounds(2,:)  = { 'modelOrders'; []; []; []};
%    fieldsAndBounds(3,:)  = { 'interactions'; []; []; {}};
%    fieldsAndBounds(4,:)  = { 'quantizationLevels'; []; []; []};
%    fieldsAndBounds(5,:)  = { 'intrinsicUncertainties'; []; []; []};
%    fieldsAndBounds(6,:)  = { 'mnemonic'; []; []; {}}; % These are for the trhuster firing information
%    fieldsAndBounds(7,:)  = { 'timestamps'; []; []; []};
%    fieldsAndBounds(8,:)  = { 'values'; []; []; []};
%
%    validate_structure(pdcInputStruct.ancillaryEngineeringConfigurationStruct, fieldsAndBounds, ...
%        'pdcInputStruct.ancillaryEngineeringConfigurationStruct');
%
%    clear fieldsAndBounds;
%    
%end

%--------------------------------------------------------------------------
% Second level validation.
% Validate the structure field pdcInputStruct.ancillaryPipelineConfigurationStruct
% if there is ancillary pipeline data.
%--------------------------------------------------------------------------
if ~isempty(pdcInputStruct.ancillaryPipelineDataStruct)
    
    fieldsAndBounds = cell(3,4);
    fieldsAndBounds(1,:)  = { 'mnemonics'; []; []; {}};
    fieldsAndBounds(2,:)  = { 'modelOrders'; '>= 0'; '<= 5'; []};
    fieldsAndBounds(3,:)  = { 'interactions'; []; []; {}};

    validate_structure(pdcInputStruct.ancillaryPipelineConfigurationStruct, fieldsAndBounds, ...
        'pdcInputStruct.ancillaryPipelineConfigurationStruct');

    clear fieldsAndBounds;

end

%--------------------------------------------------------------------------
% Second level validation.
% Validate the structure field pdcInputStruct.ancillaryDesignMatrixConfigurationStruct.
%--------------------------------------------------------------------------
fieldsAndBounds = cell(4,4);
fieldsAndBounds(1,:)  = { 'filteringEnabled'; []; []; [true; false]};
fieldsAndBounds(2,:)  = { 'sgPolyOrders'; '>= 1'; '<= 4'; []};
fieldsAndBounds(3,:)  = { 'sgFrameSizes'; '> 4'; '< 10000'; []};
fieldsAndBounds(4,:)  = { 'bandpassFlags'; []; []; [true; false]};

validate_structure(pdcInputStruct.ancillaryDesignMatrixConfigurationStruct, fieldsAndBounds, ...
    'pdcInputStruct.ancillaryDesignMatrixConfigurationStruct');

clear fieldsAndBounds;

%--------------------------------------------------------------------------
% Second level validation.
% Validate the structure field pdcInputStruct.gapFillConfigurationStruct.
%--------------------------------------------------------------------------
fieldsAndBounds = cell(10,4);
fieldsAndBounds(1,:)  = { 'madXFactor'; '> 0'; '<= 100'; []};
fieldsAndBounds(2,:)  = { 'maxGiantTransitDurationInHours'; '> 0'; '< 5*24'; []};
fieldsAndBounds(3,:)  = { 'giantTransitPolyFitChunkLengthInHours'; '> 0'; '< 24*30'; []};
fieldsAndBounds(4,:)  = { 'maxDetrendPolyOrder'; '>= 1'; '<= 100'; []};
fieldsAndBounds(5,:)  = { 'maxArOrderLimit'; '>= 1'; '<= 100'; []};
fieldsAndBounds(6,:)  = { 'maxCorrelationWindowXFactor'; '>= 1'; '<= 100'; []};
fieldsAndBounds(7,:)  = { 'gapFillModeIsAddBackPredictionError'; []; []; [true; false]};
fieldsAndBounds(8,:)  = { 'removeEclipsingBinariesOnList'; []; []; [true; false]};
fieldsAndBounds(9,:)  = { 'waveletFamily'; []; []; {'haar'; 'daub'; 'morlet'; 'coiflet'; ...
    'meyer'; 'gauss'; 'mexhat'}};
fieldsAndBounds(10,:) = { 'waveletFilterLength'; []; []; '[2:2:128]'''};

validate_structure(pdcInputStruct.gapFillConfigurationStruct, fieldsAndBounds, ...
    'pdcInputStruct.gapFillConfigurationStruct');

clear fieldsAndBounds;

%--------------------------------------------------------------------------
% Second level validation.
% Validate the structure field pdcInputStruct.ancillaryEngineeringDataStruct if it exists.
%--------------------------------------------------------------------------
if ~isempty(pdcInputStruct.ancillaryEngineeringDataStruct)
    
    fieldsAndBounds = cell(3,4);
    fieldsAndBounds(1,:)  = { 'mnemonic'; []; []; {}};
    fieldsAndBounds(2,:)  = { 'timestamps'; '> 54500'; '< 70000'; []};   % 2/4/2008 to 7/13/2050
    fieldsAndBounds(3,:)  = { 'values'; []; []; []};                     % TBD

    nStructures = length(pdcInputStruct.ancillaryEngineeringDataStruct);

    for i = 1 : nStructures
        if ( isfield(pdcInputStruct.ancillaryEngineeringDataStruct(i), 'timestamps') )
            if ~isempty(pdcInputStruct.ancillaryEngineeringDataStruct(i).timestamps)
                validate_structure(pdcInputStruct.ancillaryEngineeringDataStruct(i), ...
                    fieldsAndBounds, 'pdcInputStruct.ancillaryEngineeringDataStruct()');
            end
        else
            mnemonic = 'pdcInputStruct.ancillaryEngineeringDataStruct';
            messageIdentifier = [mnemonic ':missingField:' 'timestamps'];
            messageIdentifier = strrep(messageIdentifier, '.', '_');
            messageText = [mnemonic ':' 'timestamps' ': field not present in the input structure.'];
            error(messageIdentifier, messageText);  % this has to be an error and not a warning
        end
    end
    
    clear fieldsAndBounds;

end % if

%--------------------------------------------------------------------------
% Second level validation.
% Validate the structure field pdcInputStruct.thrusterDataAncillaryEngineeringConfigurationStruct if
% there is ancillary engineering data.
%--------------------------------------------------------------------------

if ~isempty(pdcInputStruct.ancillaryEngineeringDataStruct)
    
    fieldsAndBounds = cell(6,4);
    fieldsAndBounds(1,:)  = { 'mnemonics'; []; []; {}};
    fieldsAndBounds(2,:)  = { 'modelOrders'; '>= 0'; '<= 5'; []};
    fieldsAndBounds(3,:)  = { 'interactions'; []; []; {}};
    fieldsAndBounds(4,:)  = { 'quantizationLevels'; '>= 0'; []; []};
    fieldsAndBounds(5,:)  = { 'intrinsicUncertainties'; '>= 0'; []; []};
    fieldsAndBounds(6,:)  = { 'thrusterFiringDataCadenceSeconds'; '>= 0'; []; []};

    validate_structure(pdcInputStruct.thrusterDataAncillaryEngineeringConfigurationStruct, fieldsAndBounds, ...
        'pdcInputStruct.thrusterDataAncillaryEngineeringConfigurationStruct');

    clear fieldsAndBounds;
    
end


%--------------------------------------------------------------------------
% Second level validation.
% Validate the structure field pdcInputStruct.ancillaryPipelineDataStruct if it exists.
%--------------------------------------------------------------------------
if ~isempty(pdcInputStruct.ancillaryPipelineDataStruct)
    
    fieldsAndBounds = cell(4,4);
    fieldsAndBounds(1,:)  = { 'mnemonic'; []; []; {}};
    fieldsAndBounds(2,:)  = { 'timestamps'; '> 54500'; '< 70000'; []};   % 2/4/2008 to 7/13/2050
    fieldsAndBounds(3,:)  = { 'values'; []; []; []};                     % TBD
    fieldsAndBounds(4,:)  = { 'uncertainties'; '>= 0'; []; []};          % TBD

    nStructures = length(pdcInputStruct.ancillaryPipelineDataStruct);

    for i = 1 : nStructures
        if ( isfield(pdcInputStruct.ancillaryPipelineDataStruct(i), 'timestamps') )
            if ~isempty(pdcInputStruct.ancillaryPipelineDataStruct(i).timestamps)
                validate_structure(pdcInputStruct.ancillaryPipelineDataStruct(i), ...
                    fieldsAndBounds, 'pdcInputStruct.ancillaryPipelineDataStruct()');
            end
        else
            mnemonic = 'pdcInputStruct.ancillaryPipelineDataStruct';
            messageIdentifier = [mnemonic ':missingField:' 'timestamps'];
            messageIdentifier = strrep(messageIdentifier, '.', '_');
            messageText = [mnemonic ':' 'timestamps' ': field not present in the input structure.'];
            error(messageIdentifier, messageText);  % this has to be an error and not a warning
        end
    end
    
    clear fieldsAndBounds;

end % if


%--------------------------------------------------------------------------
% Second level validation.
% Validate the structure field pdcInputStruct.targetDataStruct.
%--------------------------------------------------------------------------
fieldsAndBounds = cell(10,4);
fieldsAndBounds(1,:)  = { 'keplerId'; '> 0'; '< 1e9'; []};
fieldsAndBounds(2,:)  = { 'keplerMag'; '>= 0'; '< 30'; []};
fieldsAndBounds(3,:)  = { 'labels'; []; []; {}};
fieldsAndBounds(4,:)  = { 'fluxFractionInAperture'; '>= 0'; '<= 1'; []};
fieldsAndBounds(5,:)  = { 'crowdingMetric'; '>= 0'; '<= 1'; []};
fieldsAndBounds(6,:)  = { 'values'; '>= 0'; '< 1e12'; []};
fieldsAndBounds(7,:)  = { 'uncertainties'; '>= 0'; '< 1e7'; []};
fieldsAndBounds(8,:)  = { 'gapIndicators'; []; []; [true; false]};
fieldsAndBounds(9,:)  = { 'kic'; []; []; []};
fieldsAndBounds(10,:) = { 'optimalAperture'; []; []; []};
fieldsAndBounds(11,:) = { 'ccdModule';  []; []; '[-1, 2:4, 6:20, 22:24]'''};
fieldsAndBounds(12,:) = { 'ccdOutput';  []; []; '[-1 1 2 3 4]'''};

nStructures = length(pdcInputStruct.targetDataStruct);

% NOTE: this keplerMag is not used by the MAP prior so converting NaNs to 20 is no big deal. I (JCS) do not know
% what in PDC uses this keplerMag
warningInsteadOfErrorFlag = true;
for j = 1 : nStructures
    if isnan(pdcInputStruct.targetDataStruct(j).keplerMag)
        pdcInputStruct.targetDataStruct(j).keplerMag = obj.DEFAULT_KEPLER_MAG;
    end
    validate_structure(pdcInputStruct.targetDataStruct(j), fieldsAndBounds, ...
        'pdcInputStruct.targetDataStruct', warningInsteadOfErrorFlag);
end

clear fieldsAndBounds;

%--------------------------------------------------------------------------
% Second level validation.
% Validate the structure field pdcInputStruct.motionPolyStruct if it
% exists.
%--------------------------------------------------------------------------
if (pdcInputStruct.multiChannelRun || ~isempty(pdcInputStruct.motionPolyStruct))
    
    fieldsAndBounds = cell(10,4);
    fieldsAndBounds(1,:)  = { 'cadence'; '>= 0'; '< 2e7'; []};
    fieldsAndBounds(2,:)  = { 'mjdStartTime'; '> 54500'; '< 70000'; []}; % 2/4/2008 to 7/13/2050
    fieldsAndBounds(3,:)  = { 'mjdMidTime'; '> 54500'; '< 70000'; []};   % 2/4/2008 to 7/13/2050
    fieldsAndBounds(4,:)  = { 'mjdEndTime'; '> 54500'; '< 70000'; []};   % 2/4/2008 to 7/13/2050
    fieldsAndBounds(5,:)  = { 'module'; []; []; '[2:4, 6:20, 22:24]'''};
    fieldsAndBounds(6,:)  = { 'output'; []; []; '[1 2 3 4]'''};
    fieldsAndBounds(7,:)  = { 'rowPoly'; []; []; []};
    fieldsAndBounds(8,:)  = { 'rowPolyStatus'; []; []; '[0:1]'''};
    fieldsAndBounds(9,:)  = { 'colPoly'; []; []; []};
    fieldsAndBounds(10,:) = { 'colPolyStatus'; []; []; '[0:1]'''};
    
    if (pdcInputStruct.multiChannelRun)
        for iChannel = 1 : length(pdcInputStruct.multiChannelMotionPolyStruct)
        
            motionPolyStruct = pdcInputStruct.multiChannelMotionPolyStruct(iChannel).motionPolyStruct;
            motionPolyGapIndicators = ~logical([motionPolyStruct.rowPolyStatus]');
            motionPolyStruct = motionPolyStruct(~motionPolyGapIndicators);
        
            nStructures = length(motionPolyStruct);
        
            for i = 1 : nStructures
                validate_structure(motionPolyStruct(i), fieldsAndBounds, 'pdcInputStruct.motionPolyStruct()');
            end
        end
    else
        motionPolyStruct = pdcInputStruct.motionPolyStruct;
        motionPolyGapIndicators = ~logical([motionPolyStruct.rowPolyStatus]');
        motionPolyStruct = motionPolyStruct(~motionPolyGapIndicators);
    
        nStructures = length(motionPolyStruct);

        for i = 1 : nStructures
            validate_structure(motionPolyStruct(i), fieldsAndBounds, 'pdcInputStruct.motionPolyStruct()');
        end
    end
    
    clear fieldsAndBounds;

end % if

%--------------------------------------------------------------------------
% Third level validation.
% Validate the structure field pdcInputStruct.motionPolyStruct().rowPoly
% if it exists.
% TODO: Get this working with multiChannelMotionPolyStruct
%--------------------------------------------------------------------------
if (isfield(pdcInputStruct, 'motionPolyStruct') && ~isempty(pdcInputStruct.motionPolyStruct))
    
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
    fieldsAndBounds(12,:) = { 'coeffs'; []; []; []};                % TBD
    fieldsAndBounds(13,:) = { 'covariance'; []; []; []};            % TBD
        
    nStructures = length(motionPolyStruct);

    for i = 1 : nStructures
        validate_structure(motionPolyStruct(i).rowPoly, ...
            fieldsAndBounds, 'pdcInputStruct.motionPolyStruct().rowPoly');
    end
    
    clear fieldsAndBounds;

end % if

%--------------------------------------------------------------------------
% Third level validation.
% Validate the structure field pdcInputStruct.motionPolyStruct().colPoly
% if it exists.
% TODO: Get this working with multiChannelMotionPolyStruct
%--------------------------------------------------------------------------
if (isfield(pdcInputStruct, 'motionPolyStruct') && ~isempty(pdcInputStruct.motionPolyStruct))
    
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
    fieldsAndBounds(12,:) = { 'coeffs'; []; []; []};                % TBD
    fieldsAndBounds(13,:) = { 'covariance'; []; []; []};            % TBD
        
    nStructures = length(motionPolyStruct);

    for i = 1 : nStructures
        validate_structure(motionPolyStruct(i).colPoly, ...
            fieldsAndBounds, 'pdcInputStruct.motionPolyStruct().colPoly');
    end
    
    clear fieldsAndBounds;

end % if

%--------------------------------------------------------------------------
% Third level validation.
% Validate the structure field
% pdcInputStruct.cadenceTimes.dataAnomalyFlags.
%--------------------------------------------------------------------------
fieldsAndBounds = cell(6,4);
fieldsAndBounds(1,:)  = { 'attitudeTweakIndicators'; []; []; [true, false]};
fieldsAndBounds(2,:)  = { 'safeModeIndicators'; []; []; [true, false]};
fieldsAndBounds(3,:)  = { 'earthPointIndicators'; []; []; [true, false]};
fieldsAndBounds(4,:)  = { 'coarsePointIndicators'; []; []; [true, false]};
fieldsAndBounds(5,:)  = { 'argabrighteningIndicators'; []; []; [true, false]};
fieldsAndBounds(6,:)  = { 'excludeIndicators'; []; []; [true, false]};

validate_structure(pdcInputStruct.cadenceTimes.dataAnomalyFlags, ...
    fieldsAndBounds, 'pdcInputStruct.cadenceTimes.dataAnomalyFlags');

clear fieldsAndBounds;

%--------------------------------------------------------------------------
% Third level validation.
% Validate the structure field
% pdcInputStruct.longCadenceTimes.dataAnomalyFlags.
%--------------------------------------------------------------------------
fieldsAndBounds = cell(6,4);
fieldsAndBounds(1,:)  = { 'attitudeTweakIndicators'; []; []; [true, false]};
fieldsAndBounds(2,:)  = { 'safeModeIndicators'; []; []; [true, false]};
fieldsAndBounds(3,:)  = { 'earthPointIndicators'; []; []; [true, false]};
fieldsAndBounds(4,:)  = { 'coarsePointIndicators'; []; []; [true, false]};
fieldsAndBounds(5,:)  = { 'argabrighteningIndicators'; []; []; [true, false]};
fieldsAndBounds(6,:)  = { 'excludeIndicators'; []; []; [true, false]};

validate_structure(pdcInputStruct.longCadenceTimes.dataAnomalyFlags, ...
    fieldsAndBounds, 'pdcInputStruct.longCadenceTimes.dataAnomalyFlags');

clear fieldsAndBounds;

%--------------------------------------------------------------------------
% Third level validation.
% Validate the structure field pdcInputStruct.targetDataStruct().kic.
% Only validate those fields that are used.
%--------------------------------------------------------------------------
if ~isempty(pdcInputStruct.targetDataStruct)
    fieldsAndBounds = cell(2,4);
    fieldsAndBounds(1,:)  = { 'keplerId'; '> 0'; '< 1e9'; []};
    fieldsAndBounds(2,:)  = { 'log10Metallicity'; []; []; []};

    nStructures = length(pdcInputStruct.targetDataStruct);

    for i = 1 : nStructures

        validate_structure(pdcInputStruct.targetDataStruct(i).kic, fieldsAndBounds, ...
            'pdcInputStruct.targetDataStruct().kic');

    end

    clear fieldsAndBounds;
    
end % if

%--------------------------------------------------------------------------
% Third level validation.
% Validate the structure field pdcInputStruct.targetDataStruct().transits.
%--------------------------------------------------------------------------
if (~isempty(pdcInputStruct.targetDataStruct) && isfield(pdcInputStruct.targetDataStruct, 'transits'))
    fieldsAndBounds = cell(5,4);
    fieldsAndBounds(1,:)  = { 'id'; []; []; []};
    fieldsAndBounds(2,:)  = { 'eclipsingBinary'; []; []; [true, false]};
    fieldsAndBounds(3,:)  = { 'epoch'; []; []; []}; % These can be Nans
    fieldsAndBounds(4,:)  = { 'period'; []; []; []}; % These can be Nans
    fieldsAndBounds(5,:)  = { 'duration'; []; []; []}; % These can be Nans

    nStructures = length(pdcInputStruct.targetDataStruct);

    for i = 1 : nStructures

        if (~isempty(pdcInputStruct.targetDataStruct(i).transits))

            nSubStructs = length(pdcInputStruct.targetDataStruct(i).transits);
            for iSubStruct = 1 : nSubStructs
                validate_structure(pdcInputStruct.targetDataStruct(i).transits(iSubStruct), fieldsAndBounds, ...
                    'pdcInputStruct.targetDataStruct().transits');
            end
        end

    end

    clear fieldsAndBounds;
    
end % if


%--------------------------------------------------------------------------



% Order the fields to avoid getting error messages like:
%   Error using ==> class 
%   Field names and parent classes for class pdcInputClass cannot be
%   changed without clear classes
pdcInputStruct = orderfields(pdcInputStruct);

pdcInputStruct.pdcModuleParameters = ...
    orderfields(pdcInputStruct.pdcModuleParameters);

pdcInputStruct.saturationSegmentConfigurationStruct = ...
    orderfields(pdcInputStruct.saturationSegmentConfigurationStruct);

pdcInputStruct.harmonicsIdentificationConfigurationStruct = ...
    orderfields(pdcInputStruct.harmonicsIdentificationConfigurationStruct);

pdcInputStruct.discontinuityConfigurationStruct = ...
    orderfields(pdcInputStruct.discontinuityConfigurationStruct);

pdcInputStruct.ancillaryEngineeringConfigurationStruct = ...
    orderfields(pdcInputStruct.ancillaryEngineeringConfigurationStruct);

pdcInputStruct.ancillaryPipelineConfigurationStruct = ...
    orderfields(pdcInputStruct.ancillaryPipelineConfigurationStruct);

pdcInputStruct.ancillaryDesignMatrixConfigurationStruct = ...
    orderfields(pdcInputStruct.ancillaryDesignMatrixConfigurationStruct);

pdcInputStruct.gapFillConfigurationStruct = ...
    orderfields(pdcInputStruct.gapFillConfigurationStruct);

pdcInputStruct.fcConstants = ...
    orderfields(pdcInputStruct.fcConstants);

pdcInputStruct.spacecraftConfigMap = ...
    orderfields(pdcInputStruct.spacecraftConfigMap);
nMaps = length(pdcInputStruct.spacecraftConfigMap);
for i = 1 : nMaps
    pdcInputStruct.spacecraftConfigMap(i).entries = ...
        orderfields(pdcInputStruct.spacecraftConfigMap(i).entries);
end

pdcInputStruct.raDec2PixModel = ...
    orderfields(pdcInputStruct.raDec2PixModel);
pdcInputStruct.raDec2PixModel.geometryModel = ...
    orderfields(pdcInputStruct.raDec2PixModel.geometryModel);
pdcInputStruct.raDec2PixModel.pointingModel = ...
    orderfields(pdcInputStruct.raDec2PixModel.pointingModel);
pdcInputStruct.raDec2PixModel.rollTimeModel = ...
    orderfields(pdcInputStruct.raDec2PixModel.rollTimeModel);

pdcInputStruct.cadenceTimes = ...
    orderfields(pdcInputStruct.cadenceTimes);
pdcInputStruct.cadenceTimes.dataAnomalyFlags = ...
    orderfields(pdcInputStruct.cadenceTimes.dataAnomalyFlags);

pdcInputStruct.longCadenceTimes = ...
    orderfields(pdcInputStruct.longCadenceTimes);
pdcInputStruct.longCadenceTimes.dataAnomalyFlags = ...
    orderfields(pdcInputStruct.longCadenceTimes.dataAnomalyFlags);

if ~isempty(pdcInputStruct.ancillaryEngineeringDataStruct)
    pdcInputStruct.ancillaryEngineeringDataStruct = ...
        orderfields(pdcInputStruct.ancillaryEngineeringDataStruct);
end

if ~isempty(pdcInputStruct.thrusterDataAncillaryEngineeringConfigurationStruct)
    pdcInputStruct.thrusterDataAncillaryEngineeringConfigurationStruct = ...
        orderfields(pdcInputStruct.thrusterDataAncillaryEngineeringConfigurationStruct);
end

if ~isempty(pdcInputStruct.ancillaryPipelineDataStruct)
    pdcInputStruct.ancillaryPipelineDataStruct = ...
        orderfields(pdcInputStruct.ancillaryPipelineDataStruct);
end

if ~isempty(pdcInputStruct.targetDataStruct)
    pdcInputStruct.targetDataStruct = ...
        orderfields(pdcInputStruct.targetDataStruct);
    % TODO: order KIC
    % TODO: order Centroids        
end

% TODO: Get this working with multiChannelMotionPolyStruct
if (isfield(pdcInputStruct, 'motionPolyStruct') && ~isempty(pdcInputStruct.motionPolyStruct))
    pdcInputStruct.motionPolyStruct = ...
        orderfields(pdcInputStruct.motionPolyStruct);
    nStructures = length(pdcInputStruct.motionPolyStruct);
    for i = 1 : nStructures
        pdcInputStruct.motionPolyStruct(i).rowPoly = ...
            orderfields(pdcInputStruct.motionPolyStruct(i).rowPoly);
        pdcInputStruct.motionPolyStruct(i).colPoly = ...
            orderfields(pdcInputStruct.motionPolyStruct(i).colPoly);
    end
end


%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Input validation successfully completed!
% Create the pdcInputClass object.
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    obj.multiChannelRun                             =  pdcInputStruct.multiChannelRun;
    obj.ccdModule                                   =  pdcInputStruct.ccdModule;                                    
    obj.ccdOutput                                   =  pdcInputStruct.ccdOutput;
    obj.cadenceType                                 =  pdcInputStruct.cadenceType;
    obj.startCadence                                =  pdcInputStruct.startCadence;
    obj.endCadence                                  =  pdcInputStruct.endCadence;
    obj.raDec2PixModel                              =  pdcInputStruct.raDec2PixModel;
    obj.cadenceTimes                                =  pdcInputStruct.cadenceTimes;
    obj.longCadenceTimes                            =  pdcInputStruct.longCadenceTimes;
    obj.pdcModuleParameters                         =  pdcInputStruct.pdcModuleParameters;
    obj.mapConfigurationStruct                      =  pdcInputStruct.mapConfigurationStruct;
    obj.spsdDetectionConfigurationStruct            =  pdcInputStruct.spsdDetectionConfigurationStruct;
    obj.spsdDetectorConfigurationStruct             =  pdcInputStruct.spsdDetectorConfigurationStruct;
    obj.spsdRemovalConfigurationStruct              =  pdcInputStruct.spsdRemovalConfigurationStruct;
    obj.harmonicsIdentificationConfigurationStruct  =  pdcInputStruct.harmonicsIdentificationConfigurationStruct;
    obj.gapFillConfigurationStruct                  =  pdcInputStruct.gapFillConfigurationStruct;
    obj.targetDataStruct                            =  pdcInputStruct.targetDataStruct;
    if (isfield(pdcInputStruct, 'motionPolyStruct') && ~isempty(pdcInputStruct.motionPolyStruct))
        obj.motionPolyStruct                        =  pdcInputStruct.motionPolyStruct;
    else
        obj.multiChannelMotionPolyStruct            =  pdcInputStruct.multiChannelMotionPolyStruct;
    end
    obj.pdcBlobs                                =  pdcInputStruct.pdcBlobs;
    obj.cbvBlobs                                =  pdcInputStruct.cbvBlobs;
    obj.bandSplittingConfigurationStruct            =  pdcInputStruct.bandSplittingConfigurationStruct;
    obj.goodnessMetricConfigurationStruct           =  pdcInputStruct.goodnessMetricConfigurationStruct;
    obj.pdcVersion                                  =  pdcInputStruct.pdcVersion;
    obj.channelDataStruct                           =  pdcInputStruct.channelDataStruct;
    obj.thrusterDataAncillaryEngineeringConfigurationStruct=  pdcInputStruct.thrusterDataAncillaryEngineeringConfigurationStruct;
    obj.thisIsK2Data                                = thisIsK2Data;

    % If the transits are imported as seperate struct then save them in the inputs object
    if (isfield(pdcInputStruct, 'transits'))
        obj.transits                                =  pdcInputStruct.transits;
    end

% This was originally place in preserch_data_conditioning. Moving to where it belongs.
obj = obj.set_cadenceDurationInMinutes;

% Create the thruster firing information structure
obj = obj.set_thrusterFiringDataStruct(pdcInputStruct);

% Generate flags for all targets whether to exclude them based on their labels
obj.targetDataStruct = pdc_generate_target_exclusion_list(obj.targetDataStruct, pdcInputStruct.pdcModuleParameters.excludeTargetLabels);

end % pdcInputClass Constructor

%*******************************************************************************
%*******************************************************************************
%*******************************************************************************

%*******************************************************************************
% Other methods to modify some input parameters
function [obj] = turn_off_band_splitting (obj)
    obj.pdcModuleParameters.bandSplittingEnabled = false;
end

%*******************************************************************************
function [obj] = set_map_selection_method(obj, methodString)
    if (~ischar(methodString));
        error ('set_map_selection_method: methodString must be a character string');
    end
    obj.pdcModuleParameters.mapSelectionMethod = methodString;
end

%*******************************************************************************
function [obj] = set_cadenceDurationInMinutes (obj)
    
    % Compute the median cadence duration in minutes and append to the gap fill
    % parameters.
    cadenceTimes = obj.cadenceTimes;
    startTimestamps = cadenceTimes.startTimestamps;
    endTimestamps = cadenceTimes.endTimestamps;
    cadenceGapIndicators = cadenceTimes.gapIndicators;

    startTimestamps = startTimestamps(~cadenceGapIndicators);
    endTimestamps = endTimestamps(~cadenceGapIndicators);
    cadenceDurations = endTimestamps - startTimestamps;

    % Adding a field to gapFillConfigurationStruct. This is poor coding practice. Looks like a hack. Who did this?
    % TODO: Get rid of this. If it's a dependent parameter then put it somewhere else
    obj.gapFillConfigurationStruct.cadenceDurationInMinutes = ...
        median(cadenceDurations) * get_unit_conversion('day2min');
end
%*******************************************************************************
function [obj] = set_thrusterFiringDataStruct (obj, pdcInputStruct)
    % Ingest the thruster firing data if it exists, create the thrusterFiringDataStruct,
    % and add it to the pdcInputObject
    if(~isempty(pdcInputStruct.thrusterDataAncillaryEngineeringConfigurationStruct.mnemonics))
        [obj.thrusterFiringDataStruct] = process_K2_thruster_firing_data(pdcInputStruct);
    end
end % set_thrusterFiringDataStruct
%*******************************************************************************

end % methods

%*******************************************************************************
%*******************************************************************************
%*******************************************************************************
methods (Static=true)

%*******************************************************************************
% For the benefit of K2 data we need the option to group channels together for each PDC unit of work. The channel dependent data is passed into PDC via
% pdcInputStruct.channelDataStruct. We need to collect that data and form the standard PDC fields.
%
% To keep compatibility with legacy inputs we have to create two fields in targetDataStruct for each target that gives the CCD module and output. These will
% just be identical to pdcInputStruct.ccdModule and .ccdOutput.
%
% The channel index each target cam from is stored in the field targetDataStruct(iTarget).channelIndex.
%
% If length(channelDataStruct) == 1 then there is no channel grouping.
%
% You cannot pass in basis vectors via cbvBlobs with channel grouping turned on. This genetrates and error.
%
% Channel grouping will not work with Short Cadence data. This is fine since the basis vector sand priors are passed in from the LC run and so the SC PDC is
% essentially only operated on each target in isolation.
%

function pdcInputStruct = process_channelDataStruct(pdcInputStruct)
 
    % If channelDataStruct does not exist then this is legacy input data.
    % Do nothing
    if (~isfield(pdcInputStruct, 'channelDataStruct'))
        pdcInputStruct.multiChannelRun = false;
        display('PDC Channel grouping not being utilized; Running on a single channel');
        % Add in the module and output field in taregtDataStruct.
        for iTarget = 1 : length(pdcInputStruct.targetDataStruct)
            pdcInputStruct.targetDataStruct(iTarget).ccdModule = pdcInputStruct.ccdModule;
            pdcInputStruct.targetDataStruct(iTarget).ccdOutput = pdcInputStruct.ccdOutput;
        end
        pdcInputStruct.channelDataStruct = [];
        return;
    elseif (~isfield(pdcInputStruct.channelDataStruct(1), 'targetDataStruct'))
        % This data has already been processed with pdcInputClass.process_channelDataStruct
        return;
    elseif (length(pdcInputStruct.channelDataStruct) == 1)
        channelDataStruct = pdcInputStruct.channelDataStruct;
        nChannels = length(channelDataStruct);
        % If channelDataStruct is an array of length one then there is no channel grouping. PDC runs as normal.
        display('PDC Channel grouping not being utilized; Running on a single channel');
        pdcInputStruct.multiChannelRun = false;
        pdcInputStruct.ccdModule                    = channelDataStruct.ccdModule;               
        pdcInputStruct.ccdOutput                    = channelDataStruct.ccdOutput;                 
        pdcInputStruct.ancillaryPipelineDataStruct  = channelDataStruct.ancillaryPipelineDataStruct;
        pdcInputStruct.cbvBlobs                     = channelDataStruct.cbvBlobs;                   
        pdcInputStruct.motionBlobs                  = channelDataStruct.motionBlobs;                
        pdcInputStruct.pdcBlobs                     = channelDataStruct.pdcBlobs;                   
        pdcInputStruct.targetDataStruct             = channelDataStruct.targetDataStruct;
        % Place ccdModule and ccdOutput in targetDataStruct for consistancy, it's not really needed
        for iTarget = 1 : length(channelDataStruct.targetDataStruct)
            pdcInputStruct.targetDataStruct(iTarget).ccdModule = channelDataStruct.ccdModule;
            pdcInputStruct.targetDataStruct(iTarget).ccdOutput = channelDataStruct.ccdOutput;
        end
    else
        % This code is when channel grouping is occuring, or at least requested
        
        channelDataStruct = pdcInputStruct.channelDataStruct;
        nChannels = length(channelDataStruct);

        % If using basis vectors from blobs and channel grouping then the same cbvBlob is used for all channels in a unit of work.
        % This ONLY works if this run uses the SAME channels as the run where the cbvBlob came from.
        % USE WITH CAUTION!
        pdcInputStruct.cbvBlobs                     = channelDataStruct(1).cbvBlobs;                   
       %% Channel grouping right now will not work with using basis vectors from blobs
       %if (pdcInputStruct.mapConfigurationStruct.useBasisVectorsFromBlob || ...
       %            pdcInputStruct.mapConfigurationStruct.useBasisVectorsAndPriorsFromBlob || ...
       %            pdcInputStruct.mapConfigurationStruct.useBasisVectorsAndPriorsFromPixels)
       %    error('Cannot currently pass in basis vectors via cbvBlobs with channel grouping.');
       %end
        
        % Short cadence data already uses the basis vectors, priors and SPSDs from PC so it is unnecessary and an extra complication to allow channele grouping for
        % short cadence data.
        if (strcmp(pdcInputStruct.cadenceType, 'SHORT'))
            error('Channel grouping is not yet implemented for Short Cadence data');
        end
        
        display('PDC Channel grouping utilized; Running on multiple channels');
        
        pdcInputStruct.multiChannelRun = true;
        
        pdcInputStruct.ccdModule       = -1;             
        pdcInputStruct.ccdOutput       = -1;            
        
        % ancillaryPipelineDataStruct is not used right now so leave as empty set  
        pdcInputStruct.ancillaryPipelineDataStruct  = [];
        
        %***
        % Group targetDataStruct and add field to keep track of the channel for each target
        
        % Count the number of total targets
        nTotTargets = int32(0);
        for iChannel = 1 : nChannels
            nTotTargets = nTotTargets + length(channelDataStruct(iChannel).targetDataStruct);
        end
        pdcInputStruct.targetDataStruct = repmat(struct('ccdModule', [], ...             
                                                 'ccdOutput', [], ...             
                                                 'keplerId', [], ...           
                                                 'keplerMag', [], ...             
                                                 'labels', [], ...                
                                                 'fluxFractionInAperture', [], ...
                                                 'crowdingMetric', [], ...        
                                                 'values', [], ...                
                                                 'uncertainties', [], ...         
                                                 'gapIndicators', [], ...         
                                                 'excludeBasedOnLabels', [], ...  
                                                 'kic', [], ...                   
                                                 'transits', [], ...              
                                                 'optimalAperture', [], ...
                                                 'channelIndex', []), [nTotTargets,1]);
        
        % PDC wants all targets in one big struct array
        combinedTargetIndex = 1;
        for iChannel = 1 : nChannels
            for iTarget = 1 : length(channelDataStruct(iChannel).targetDataStruct)
                pdcInputStruct.targetDataStruct(combinedTargetIndex).ccdModule              = channelDataStruct(iChannel).ccdModule;
                pdcInputStruct.targetDataStruct(combinedTargetIndex).ccdOutput              = channelDataStruct(iChannel).ccdOutput;
                pdcInputStruct.targetDataStruct(combinedTargetIndex).keplerId               = channelDataStruct(iChannel).targetDataStruct(iTarget).keplerId;
                pdcInputStruct.targetDataStruct(combinedTargetIndex).keplerMag              = channelDataStruct(iChannel).targetDataStruct(iTarget).keplerMag;      
                pdcInputStruct.targetDataStruct(combinedTargetIndex).labels                 = channelDataStruct(iChannel).targetDataStruct(iTarget).labels;                  
                pdcInputStruct.targetDataStruct(combinedTargetIndex).fluxFractionInAperture = channelDataStruct(iChannel).targetDataStruct(iTarget).fluxFractionInAperture;                  
                pdcInputStruct.targetDataStruct(combinedTargetIndex).crowdingMetric         = channelDataStruct(iChannel).targetDataStruct(iTarget).crowdingMetric;                        
                pdcInputStruct.targetDataStruct(combinedTargetIndex).values                 = channelDataStruct(iChannel).targetDataStruct(iTarget).values;                                 
                pdcInputStruct.targetDataStruct(combinedTargetIndex).uncertainties          = channelDataStruct(iChannel).targetDataStruct(iTarget).uncertainties;
                pdcInputStruct.targetDataStruct(combinedTargetIndex).gapIndicators          = channelDataStruct(iChannel).targetDataStruct(iTarget).gapIndicators;       
                pdcInputStruct.targetDataStruct(combinedTargetIndex).kic                    = channelDataStruct(iChannel).targetDataStruct(iTarget).kic;               
                pdcInputStruct.targetDataStruct(combinedTargetIndex).transits               = channelDataStruct(iChannel).targetDataStruct(iTarget).transits;               
                pdcInputStruct.targetDataStruct(combinedTargetIndex).optimalAperture        = channelDataStruct(iChannel).targetDataStruct(iTarget).optimalAperture;
                pdcInputStruct.targetDataStruct(combinedTargetIndex).channelIndex           = iChannel;
                combinedTargetIndex = combinedTargetIndex + 1;
            end
        end
        
        % The motion polynomials are per channel. 
        for iChannel = 1 : nChannels
            pdcInputStruct.motionBlobs(iChannel) = channelDataStruct(iChannel).motionBlobs;
        end
    end

    % Keep a vestigual channelDataStruct in pdcInputsObject for the benefit of creating the outputsStruct channel data
    for iChannel = 1 : nChannels
        newChannelDataStruct(iChannel).ccdModule = channelDataStruct(iChannel).ccdModule;
        newChannelDataStruct(iChannel).ccdOutput = channelDataStruct(iChannel).ccdOutput;
    end
    pdcInputStruct.channelDataStruct = newChannelDataStruct;

end % process_channelDataStruct

%*******************************************************************************
% This function is so that one can obtain the PDC version without instantiating a pdcInputClass object
% Why not just have static properties?!?

function pdcVersion = pdc_version ()
    pdcVersion = pdcInputClass.PDCVERSION;
end

end

end % classdef pdcInputClass
