function [paResultsStruct] = pa_matlab_controller(paDataStruct)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [paResultsStruct] = pa_matlab_controller(paDataStruct)
%
% This function forms the MATLAB side of the science interface for
% Photometric Analysis (PA). The function receives input via the
% paDataStruct structure. It first validates the fields of the input
% structure and calls the constructor for the paDataClass.
%
% The standard PA unit of work for long-cadence (LC) and short-cadence (SC)
% science data processing is a single module output for a duration of one
% quarter (LC) and one month (SC). By definition a PA ?task? processes a
% single unit of work. A LC task consists of the following five
% sequential steps, or 'processing states': background pixel processing,
% PPA target centroiding, motion model estimation, target processing, and
% results aggregation. Each step is executed as one or more subtasks. As
% shown in the tables below, the target processing and PPA centroiding
% steps are divided into multiple subtasks and can be performed in parallel
% if the computational environment and resources allow.
%
%     LC Processing State               # Subtasks
%     -------------------               ----------
%     1. BACKGROUND                         1 
%     2. PPA_TARGETS                    1 or more 
%     3. GENERATE_MOTION_POLYNOMIALS        1 
%     4. TARGETS                        1 or more
%     5. AGGREGATE_RESULTS                  1
%
% Short-cadence data contain neither background pixels nor sufficient PPA
% targets from which to produce high-quality motion polynomials. SC
% background and image motion models are therefore interpolated from the
% corresponding LC results. The processing states for SC data are as
% follows:
%
%     SC Processing State               # Subtasks
%     -------------------               ----------
%     1. MOTION_BACKGROUND_BLOBS            1
%     2. TARGETS                        1 or more
%     3. AGGREGATE_RESULTS                  1
%
%
% In addition to the stellar flux time series, a number of metrics are
% produced as outputs of this function on a (long) cadence by cadence
% basis. These include encircled energy (EE), brightness, centroids and
% motion polynomials. Uncertainties in the relative flux values and in each
% of the metrics are computed by standard propagation of errors. All
% science outputs are returned in the paResultsStruct structure.
%
%--------------------------------------------------------------------------
% Long-Cadence Processing
%--------------------------------------------------------------------------
%
% BACKGROUND
% ----------
% Step 1. Identify reaction wheel zero-crossing events. Create a list of
%         relative cadence numbers where any of the reaction wheel speeds
%         are zero rpm. This list of reaction wheel zero crossing cadences
%         is attached to the outputsStruct. On subsequent call, the list is
%         loaded from the paStateFile and attached to the outputsStruct. 
% Step 2. Identify and mitigate Argabrightening events. 
% Step 3. Clean cosmic ray noise from background pixels.
% Step 4. Fit low order two-dimensional polynomials to the background
%         pixels for each cadence for the given module output.
%
% PPA_TARGETS
% -----------
% Step 1. Perform barycentric timestamp correction.*
% Step 2. Mitigate Argabrightenings.
% Step 3. Clean cosmic ray noise.
% Step 4. Compute PRF centroids. 
%
% GENERATE_MOTION_POLYNOMIALS
% ---------------------------
% Step 1. Aggregate PPA target results. 
% Step 2. Fit motion polynomials.
%
% TARGETS
% -------
% Step 1. Perform barycentric timestamp correction.*
% Step 2. Mitigate Argabrightenings.
% Step 3. Clean cosmic ray noise.
% Step 4. Compute an optimal photometric aperture for each target star.
% Step 5. Perform simple aperture photometry (SAP) for each target star. 
%         Remove the estimated background from the input target pixel time
%         series and sum the pixel values within the target's optimal
%         aperture on each cadence to produce a flux time series for each
%         target star.
% Step 6. Compute flux-weighted centroids.
%
% AGGREGATE_RESULTS
% -----------------
% Step 1. Aggregate target results.
% Step 2. Compute brightness, encircled energy, and cosmic ray metrics.
% Step 3. If motion polynomial generation failed, then fit motion
%         polynomials using flux-weighted centroids from all targets. 
%
%
%--------------------------------------------------------------------------
% Short-Cadence Processing
%--------------------------------------------------------------------------
%
% MOTION_BACKGROUND_BLOBS
% -----------------------
% Step 1. Interpolate LC motion polynomials.
% Step 2. Identify and mitigate Argabrightening events. 
% Step 3. Interpolate LC background polynomials.
%
% TARGETS
% -------
% Step 1. Barycentric timestamp correction.*
% Step 2. Clean cosmic ray noise.
% Step 3. Mitigate Argabrightenings.
% Step 4. Perform simple aperture photometry. 
% Step 5. Compute flux-weighted centroids.
%
% AGGREGATE_RESULTS
% -----------------
% Step 1. Aggregate target results.
% Step 2. Compute cosmic ray metrics.
%
%
% * Note that, although barycentric timestamp corrections are performed in
%   PA, the computation is redundant and is not used outside of transit
%   injection scenarios. The barycentric corrections exported to the Kepler
%   archive are computed in the Archive (AR) module.
%
%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% INPUT:  A data structure 'paDataStruct' with the following fields:
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%    Level 1
%
%    paDataStruct is a struct with the following fields:
%
%        ccdModule ...........................................[int]     CCD module number.
%        ccdOutput ...........................................[int]     CCD output number.
%        cadenceType .........................................[string]  'LONG' or 'SHORT'.
%        startCadence ........................................[double]  start cadence index.
%        endCadence ..........................................[double]  end cadence index.
%        firstCall ...........................................[logical] true if first PA science call.
%        lastCall ............................................[logical] true if last PA science call.
%        debugFlag ...........................................[int]     always zero in pipeline runs.
%        duration ............................................[int]
%        startTime ...........................................[string]  String containing the start time (UTC) of the first cadence in this UOW.
%        fcConstants .........................................[struct]  Fc constants.
%        spacecraftConfigMap .................................[struct array]  one or more spacecraft config maps.
%        cadenceTimes ........................................[struct]  cadence times and gap indicators.
%        longCadenceTimes ....................................[struct]  long cadence times and gap indicators for attitude solution.
%        ancillaryDesignMatrixConfigurationStruct ............[struct]  module parameters for filtering ancillary design matrix for OAP.
%        ancillaryPipelineConfigurationStruct ................[struct]  module parameters for pipeline data.
%        argabrighteningConfigurationStruct ..................[struct]  Argabrightening mitigation parameters.
%        backgroundConfigurationStruct .......................[struct]  module parameters for background estimation.
%        cosmicRayConfigurationStruct ........................[struct]  module parameters for cosmic ray cleaning.
%        encircledEnergyConfigurationStruct ..................[struct]  encircled energy parameters.
%        gapFillConfigurationStruct ..........................[struct]  gap fill parameters.
%        harmonicsIdentificationConfigurationStruct ..........[struct]  harmonics identification parameters.
%        motionConfigurationStruct ...........................[struct]  module parameters for motion polynomials.
%        oapAncillaryEngineeringConfigurationStruct ..........[struct]  module parameters for oap engineering data.
%        paConfigurationStruct ...............................[struct]  module parameters for PA science.
%        paCoaConfigurationStruct ............................[struct]  configuration parameters for photometric aperture optimization (PA-COA).
%        apertureModelConfigurationStruct ....................[struct]  configuration parameters for the image modeling portion of PA-COA.
%        pouConfigurationStruct ..............................[struct]  POU parameters.
%        reactionWheelAncillaryEngineeringConfigurationStruct [struct]  module parameters for reaction wheel engineering data.
%        saturationSegmentConfigurationStruct ................[struct]  saturation segment identification parameters.
%        thrusterDataAncillaryEngineeringConfigurationStruct .[struct]  parameters for processing K2 thruster firing events.
%        ancillaryEngineeringDataStruct ......................[struct array]  engineering data for OAP.
%        ancillaryPipelineDataStruct..........................[struct array]  pipeline data for OAP.
%        backgroundDataStruct ................................[struct array]  background pixels.
%        targetStarDataStruct ................................[struct array]  target pixels.
%        ppaTargetCount ......................................[int]     total number of PPA targets for UOW.
%        prfModel ............................................[struct]  pixel response function model.
%        raDec2PixModel ......................................[struct]  model to support conversion between celestial and CCD coordinates.
%        readNoiseModel ......................................[struct]  RMS read noise values for given CCD outputs, ADU per read
%        gainModel ...........................................[struct]  gain values for given CCD outputs, electrons per ADU.
%        linearityModel ......................................[struct]  linearity model.
%        calUncertaintyBlobs .................................[struct]  input primitives and transformations from CAL.
%        backgroundBlobs .....................................[struct]  background polynomials for short cadence PA.
%        motionBlobs .........................................[struct]  motion polynomials for short cadence PA.
%        rollingBandArtifactFlags ............................[struct array]  rolling band flags by row and cadence.
%        transitInjectionParametersFileName ..................[string]  file containing configuration parameters for injecting simulated transits into target data.
%        processingState .....................................[string]  Processing state label.
%
%--------------------------------------------------------------------------
%    Level 2
%
%    fcConstants is a struct with the following fields:
%
%        BITS_IN_ADC ...............................[int]     Number of bits output by the analog-to-digital converter.
%        SATURATION_SPILL_UP_FRACTION ..............[double]  fraction of spilled saturation goes up.
%        PARALLEL_CTE ..............................[double]  parallel charge transfer efficiency.
%        SERIAL_CTE ................................[double]  serial charge transfer efficiency.
%        nRowsImaging ..............................[int]     Number of physical pixels in a CCD row.
%        nColsImaging ..............................[int]     Number of physical pixels in a CCD column.
%        nLeadingBlack .............................[int]     Number of leading black columns.
%        nTrailingBlack ............................[int]     Number of trailing black columns.
%        nVirtualSmear .............................[int]     Number of virtual smear rown.
%        nMaskedSmear ..............................[int]     Number of masked smear rows.
%        CCD_ROWS ..................................[int]     Number of rows in a CCD image.
%        CCD_COLUMNS ...............................[int]     Number of columns in a CCD image.
%        LEADING_BLACK_START .......................[int]     Zero-based CCD index of the first leading black column.
%        LEADING_BLACK_END .........................[int]     Zero-based CCD index of the last leading black column.
%        TRAILING_BLACK_START ......................[int]     Zero-based CCD index of the first trailing black column.
%        TRAILING_BLACK_END ........................[int]     Zero-based CCD index of the last trailing black column.
%        MASKED_SMEAR_START ........................[int]     Zero-based CCD index of the first masked smear row.
%        MASKED_SMEAR_END ..........................[int]     Zero-based CCD index of the last masked smear row.
%        VIRTUAL_SMEAR_START .......................[int]     Zero-based CCD index of the first virtual smear row.
%        VIRTUAL_SMEAR_END .........................[int]     Zero-based CCD index of the last virtual smear row.
%        CHARGE_INJECTION_ROW_START ................[int]     Zero-based CCD index of the first charge injection row.
%        CHARGE_INJECTION_ROW_END ..................[int]     Zero-based CCD index of the last charge injection row.
%        CHARGE_INJECTION_COLUMN_START .............[int]     Zero-based CCD index of the first charge injection column.
%        CHARGE_INJECTION_COLUMN_END ...............[int]     Zero-based CCD index of the last charge injection column.
%        PIXEL_SIZE_IN_MICRONS .....................[int]     Width of a square photometer pixel in microns.
%        FGS_PIXEL_SIZE_IN_MICRONS .................[int]     Width of a square fine guidance sensor pixel in microns.
%        crossTalkFactor ...........................[double]  
%        pixel2arcsec ..............................[double]  pixel width in seconds of arc.
%        rad2arcsec ................................[double]  Conversion factor (180*3600/pi).
%        arcsec2rad ................................[double]  Conversion factor (pi/(180*3600)).
%        HALF_OFFSET_MODULE_ANGLE_DEGREES ..........[double]
%        NOMINAL_FIRST_ROLL ........................[int]     
%        NOMINAL_CLOCKING_ANGLE ....................[double]
%        nModules ..................................[int]     Number of photometric modules (21). 
%        nModulesSpots .............................[int]     Number of module locations, including FGS (25).
%        OUTPUTS_PER_COLUMN ........................[int]     Number of CCD outputs in a column of the module output grid (10).
%        OUTPUTS_PER_ROW ...........................[int]     Number of CCD outputs in a row of the module output grid (10).
%        nOutputsPerModule .........................[int]     Number of outputs per module (4).
%        outputsList ...............................[int array] List of output indices for a module [1;2;3;4].
%        MODULE_OUTPUTS ............................[int]     Total number of module outputs (84).
%        centerModuleNumber ........................[int]     Module number at the center of the foval plane (13). 
%        modulesListWithGaps .......................[int array] 
%        modulesList ...............................[int array] List of photometric module numbers (excludes FGS modules 1, 5, 21, and 25).
%        REQUANT_TABLE_LENGTH ......................[int]     Length of requantization table.
%        REQUANT_TABLE_MIN_VALUE ...................[int]     Minimum valid integer value in the requantization table.
%        REQUANT_TABLE_MAX_VALUE ...................[int]     Maximum valid integer value in the requantization table.
%        MEAN_BLACK_TABLE_LENGTH ...................[int]
%        MEAN_BLACK_TABLE_MIN_VALUE ................[int]
%        MEAN_BLACK_TABLE_MAX_VALUE ................[int]
%        HUFFMAN_TABLE_LENGTH ......................[int]
%        HUFFMAN_CODE_WORD_LENGTH_LIMIT ............[int]
%        TWELFTH_MAGNITUDE_ELECTRON_FLUX_PER_SECOND [double]  flux of a 12th magnitude start in e-/sec
%        moduleToIndex .............................[int array]
%        IV ........................................[int]
%        module2IndexList ..........................[int array]
%        MOD_OUT_TO_INDEX ..........................[struct array]
%        MOD_OUT_IN_GRID_ORDER .....................[struct array]
%        crossTalkOutputReflection .................[int array]
%        outputArrangements ........................[struct array]
%        outputMappings ............................[int array]
%        CENTIDAYS_PER_YEAR ........................[int]
%        J2000_MJD .................................[double]
%        UNINITIALIZED_VALUE .......................[float]
%        TEST_COEFFS ...............................[double array]
%        NOMINAL_FOV_CENTER_DEGREES ................[double array]
%        NOMINAL_FOV_CENTER_RADIANS ................[double array]
%        eclipticObliquity .........................[double]
%        zodiGrid ..................................[struct array]
%        regionFile ................................[string]
%        apertureRegionFile ........................[string]
%        apertureHtmlFile ..........................[string]
%        signalProcessingChains ....................[int array]
%        signalProcessingChainMapKeys ..............[int array]
%        signalProcessingChainMapValues ............[int array]
%        signalProcessingOrderTimeSlice1 ...........[int array]
%        signalProcessingOrderTimeSlice2 ...........[int array]
%        signalProcessingOrderTimeSlice3 ...........[int array]
%        signalProcessingOrderTimeSlice4 ...........[int array]
%        signalProcessingOrderTimeSlice5 ...........[int array]
%        KEPLER_END_OF_MISSION_MJD .................[double]  MJD marking the end of observations of the Kepler FOV.
%
%--------------------------------------------------------------------------
%    Level 2
%
%    spacecraftConfigMap is a struct with the following fields:
%
%        id .....[int]
%        time ...[double]
%        entries [struct]
%
%--------------------------------------------------------------------------
%    Level 2
%
%    cadenceTimes and longCadenceTimes are structs with the following
%    fields: 
%
%        startTimestamps .[double array]  cadence start times, MJD.
%        midTimestamps ...[double array]  cadence mid times, MJD.
%        endTimestamps ...[double array]  cadence end times, MJD.
%        gapIndicators ...[logical array] true if cadence is unavailable.
%        requantEnabled ..[logical array] true if requantization was
%                                         enabled.
%        cadenceNumbers ..[int array]     absolute cadence numbers.
%        isSefiAcc .......[logical array] single event functional interrupt
%                                         in accumulation memory (isSefiAcc = T).
%        isSefiCad .......[logical array] single event functional interrupt
%                                         in cadence memory (isSefiCad = T).
%        isLdeOos ........[logical array] local detector electronics out of
%                                         synch reported (isLdeOos = T).
%        isFinePnt .......[logical array] true for a cadence if spacecraft 
%                                         was in fine point mode.
%        isMmntmDmp ......[logical array] true if momentum dump was 
%                                         performed on cadence.
%        isLdeParEr ......[logical array] local detector electronics parity
%                                         error occurred (isLdeParEr = T).
%        isScrcErr .......[logical array] SDRAM controller memory pixel
%                                         error occurred (isScrcErr = T).
%        dataAnomalyFlags [struct]        data anomaly flags - 1 x nCadence
%                                         logical vector for each anomaly
%                                         type. 
%
%--------------------------------------------------------------------------
%    Level 2
%
%    ancillaryDesignMatrixConfigurationStruct is a struct with the
%    following fields: 
%
%        bandpassFlags ...[logical array]  include lowpass, midpass,
%                                          highpass design matrix columns
%                                          respectively if true. 
%        filteringEnabled [logical]        filter design matrix columns if
%                                          true.
%        sgFrameSizes ....[int array]      frame sizes for multi-stage
%                                          Savitsky-Golay filtering.
%        sgPolyOrders ....[int array]      polynomial orders for
%                                          multi-stage Savitsky-Golay
%                                          filtering. 
%
%--------------------------------------------------------------------------
%    Level 2
%
%    ancillaryPipelineConfigurationStruct is a struct with the following
%    fields: 
%
%        mnemonics ...[string array]  mnemonic names.
%        modelOrders .[int array]     polynomial orders for OAP.
%        interactions [string array]  array of mnemonic pairs ('|'
%                                     separated) for OAP interactions.
%
%--------------------------------------------------------------------------
%    Level 2
%
%    backgroundDataStruct is an array of structs (one per background pixel)
%    with the following fields:
%
%        values ...........[float array]    data values.
%        gapIndicators ....[logical array]  data gap indicators.
%        uncertainties ....[float array]    uncertainties in data values.
%        ccdRow ...........[int]            pixel row.
%        ccdColumn ........[int]            pixel column.
%        inOptimalAperture [logical]        true if pixel is in optimal
%                                           stellar aperture.
%--------------------------------------------------------------------------
%    Level 2
%
%    targetStarDataStruct is an array of structs (one per target star) with
%    the following fields:
%
%        keplerId ..............[int]    Kepler target ID.
%        keplerMag .............[float]  target magnitude.
%        raHours ...............[double] target right ascension (hours).
%        decDegrees ............[double] target declination (degrees).
%        referenceRow ..........[int]    target reference row.
%        referenceColumn .......[int]    target reference column.
%        labels ................[string array]  target label strings.
%        fluxFractionInAperture [float]  fraction of flux in aperture for 
%                                        brightness metric.
%        signalToNoiseRatio ....[double]
%        crowdingMetric ........[double]
%        skyCrowdingMetric .....[double]
%        pixelDataStruct .......[struct array] all pixel time series for
%                                              given star.
%        rmsCdppStruct .........[struct array] CDPP for injected transits.
%        kics ..................[struct]
%        kicEntryData ..........[struct]
%        saturatedRowCount .....[double]
%
%--------------------------------------------------------------------------
%    Level 2
%
%    argabrighteningConfigurationStruct is a struct with the following
%    fields: 
%
%        mitigationEnabled .[logical]  identify Argabrightening cadences if
%                                      true and gap PA outputs.
%        fitOrder ..........[int]      polynomial order for detrending
%        medianFilterLength [int]      order of median filter
%        madThreshold ......[float]    threshold for identifying
%                                      Argabrightening cadences.
%
%--------------------------------------------------------------------------
%    Level 2
%
%    backgroundConfigurationStruct is a struct with the following fields:
%
%        aicOrderSelectionEnabled [logical]  use AIC for order selection if
%                                            true.
%        fitMaxOrder .............[int]      maximum order for AIC.
%        fitOrder ................[int]      order for 2-D background fit
%                                            if AIC is not enabled.
%        fitMinPoints ............[int]      minimum number of data points
%                                            for fit.
%
%--------------------------------------------------------------------------
%    Level 2
%
%    cosmicRayConfigurationStruct is a struct with the following fields:
%
%        gapLengthThreshold .........................[int]  gaps longer than this are used to define segments.
%        longMedianFilterLength .....................[int]  used for initial separation of large and small scale features.
%        shortMedianFilterLength ....................[int]  used for final isoalation of impulsive features.
%        arOrder ....................................[int]  Autoregressive model order.
%        detectionThreshold .........................[float]   Detection threshold in number of AR model standard deviations. 
%        cleanZeroCrossingCadencesEnabled ...........[logical] if true, dentify and clean cosmic rays on zero crossing cadences (applies to non-background targets only).
%
%        K2-Specific Parameters:
%        ----------------------
%        k2BackgroundCleaningEnabled ................[logical]  Enable/disable cleaning of background targets.
%        k2BackgroundThrusterFiringExcludeHalfWindow [int]      Do not clean within this many cadences of a thruster event. 
%        k2TargetCleaningEnabled ....................[logical]  Enable/disable cleaning of stellar/custom targets.
%        k2TargetThrusterFiringExcludeHalfWindow ....[int]      Do not clean within this many cadences of a thruster event. 
%
%        Legacy parameters (not used after release 8.3)
%        -----------------
%        detrendOrder ...............................[int]     polynomial order for detrending.
%        medianFilterLength .........................[int]     length for short median smoothing filter.
%        madThreshold ...............................[float]   threshold for cosmic ray identification.
%        thresholdMultiplierForNegativeEvents .......[float]   multiplier for negative going outliers.
%        consecutiveCosmicRayCleaningEnabled ........[logical] if true, allow cosmic rays to be identified and cleaned on consecutive cadences for a given pixel time series.
%        twoSidedFinalThresholdingEnabled ...........[logical] if true, allow both positive and negative outliers to be identified for time series with a large number of events over threshold.
%        madWindowLength ............................[int]     window for moving estimate of noise level.
%
%--------------------------------------------------------------------------
%    Level 2
%
%    encircledEnergyConfigurationStruct is a struct with the following fields:
%
%        fluxFraction ......[float]   flux fracion for encircled energy metric.
%        polyOrder .........[int]     encircled energy polynomial order.
%        targetLabel .......[string]  label indicating encircled energy target.
%        maxTargets ........[int]     maximum encircled energy targets.
%        maxPixels .........[int]     maximum encircled energy pixels.
%        seedRadius ........[float]   encircled energy seed radius.
%        maxPolyOrder ......[int]     maximum encircled energy polynomial order.
%        aicFraction .......[float]   encircled energy AIC fraction.
%        targetPolyOrder ...[int]     encircled energy target polynomial order.
%        maxRadius .........[float]   maximum radius for normalization (0 -> dynamic normalization).
%        plotsEnabled ......[logical] enable plots during metric calculation if true.
%        robustThreshold ...[float]   weight threshold below which outliers are rejected.
%        robustLimitEnabled [logical] set gap for metric when robust limit is exceeded if true.
%
%--------------------------------------------------------------------------
%    Level 2
%
%    gapFillConfigurationStruct is a struct with the following fields:
%
%        madXFactor ...........................[float]   MAD multiplication factor.
%        maxGiantTransitDurationInHours .......[float]   maximum giant transit duration (hours).
%        maxDetrendPolyOrder ..................[int]     maximum detrend polynomial order.
%        maxArOrderLimit ......................[int]     maximum AR order.
%        maxCorrelationWindowXFactor ..........[int]     maximum correlation window multiplication factor.
%        gapFillModeIsAddBackPredictionError ..[logical] true if gap fill mode is add back prediction error.
%        waveletFamily ........................[string]  name of wavelet family, e.g. 'daub'.
%        waveletFilterLength ..................[int]     number of wavelet filter coefficients.
%        giantTransitPolyFitChunkLengthInHours [float]   giant transit poly fit chunk length (hours).
%        removeEclipsingBinariesOnList ........[logical] true if short period binaries are to be removed prior to giant transit identification.
%        arAutoCorrelationThreshold ...........[float]
%
%--------------------------------------------------------------------------
%    Level 2
%
%    harmonicsIdentificationConfigurationStruct is a struct with the
%    following fields: 
%
%        falseDetectionProbabilityForTimeSeries ...[float]   probability of identifying one or more false component detections in a given time series.
%        maxHarmonicComponents ....................[int]     maximum number of harmonic components for a given time series.
%        medianWindowLengthForPeriodogramSmoothing [int]     length of median filter for frequency domain filtering in units of cadences.
%        medianWindowLengthForTimeSeriesSmoothing .[int]     length of median filter for time domain filtering in units of cadences (not used in 7.0).
%        minHarmonicSeparationInBins ..............[int]     minimum required separation for any two frequency components to be identified and fitted in a given iteration; components from iteration to iteration can (and often will) be more closely spaced than this.
%        movingAverageWindowLength ................[int]     length of periodogram smoothing filter in units of cadences.
%        retainFrequencyCombsEnabled ..............[logical]
%        timeOutInMinutes .........................[float]   timeout limit in minutes for a given time series.
%
%--------------------------------------------------------------------------
%    Level 2
%
%    motionConfigurationStruct is a struct with the following fields:
%
%        aicDecimationFactor ..........[double]
%        aicOrderSelectionEnabled .....[logical] use AIC for order
%                                                selection if true.
%        centroidBiasFitOrder .........[double]
%        centroidBiasRemovalIterations [double]
%        columnFitOrder ...............[int]     order for 2-D column
%                                                motion fit if AIC is not
%                                                enabled. 
%        fitMaxOrder ..................[int]     maximum order for AIC.
%        fitMinPoints .................[int]     minimum number of data
%                                                points for fit.
%        maxGappingIterations .........[double]
%        robustWeightGappingThreshold .[double]
%        rowFitOrder ..................[int]     order for 2-D row motion
%                                                fit if AIC is not enabled.
%
%        K2-Specific Parameters:
%        ----------------------
%        k2PpaTargetRejectionEnabled ..[logical] enable/disable rejection
%                                                of variable and
%                                                out-of-family PPA targets.  
%
%--------------------------------------------------------------------------
%    Level 2
%
%    oapAncillaryEngineeringConfigurationStruct is a struct with the
%    following fields: 
%
%        mnemonics .............[double]
%        modelOrders ...........[double]
%        quantizationLevels ....[double]
%        intrinsicUncertainties [double]
%        interactions ..........[double]
%
%--------------------------------------------------------------------------
%    Level 2
%
%    paConfigurationStruct is a struct with the following fields:
%
%        debugLevel ....................................[int]     level for science debug.
%        cosmicRayCleaningEnabled ......................[logical] true to clean cosmic rays.
%        targetPrfCentroidingEnabled ...................[logical] true for PRF centroiding of general targets; flux-weighted centroiding if false.
%        ppaTargetPrfCentroidingEnabled ................[logical] true for PRF centroiding of PPA targets; flux-weighted centroiding if false.
%        oapEnabled ....................................[logical] true for optimal aperture photometry.
%        simulatedTransitsEnabled ......................[logical] true == inject simulated transits into target data.
%        brightRobustThreshold .........................[float]   threshold weight below which outliers are rejected in robust fit.
%        minimumBrightTargets ..........................[int]     minimum number of targets needed to compute brightness metric.
%        madThresholdForCentroidOutliers ...............[float]   threshold for identification of out of family centroids.
%        thresholdMultiplierForPositiveCentroidOutliers [float]   threshold multiplier for identification of out of family centroids.
%        stellarVariabilityDetrendOrder ................[int]     detrend order for identification of variable targets.
%        stellarVariabilityThreshold ...................[float]   threshold for identification of variable targets.
%        reactionWheelMedianFilterLength ...............[int]     length of median filter used to condition reaction wheel speed data.
%        discretePrfCentroidingEnabled .................[logical] true for discrete PRF centroid approximation.
%        discretePrfOversampleFactor ...................[int]     oversample specification for discrete PRF approximation.
%        onlyProcessPpaTargetsEnabled ..................[logical] If true, skip the TARGETS  and AGGREGATE_RESULTS processing states.
%        motionBlobsInputEnabled .......................[logical] If true, refrain from computing motion polynomials. Use those provided in the blob file.
%        rollingBandContaminationFlagsEnabled ..........[logical] produce non-gapped contamination flags if true.
%        removeMedianSimulatedFlux .....................[logical] true == remove median of injected flux. Only applies if simulatedTransitsEnabled = true.
%        paCoaEnabled ..................................[logical] if true, recompute optimal apertures using paCoaClass.
%        testPulseDurations ............................[double]  transit duration for square wave transit model.
%
%        K2-Specific Parameters:
%        ----------------------
%        k2TrimAperturesEnabled ........................[logical] Trim large PPA apertures to speed up PRF centroiding.
%        k2TrimRadiusInPrfWidths .......................[float]   Trim pixels more than this many PRF widths from the raDec2Pix-predicted target centroid.
%        k2TrimMinSizeInPixels .........................[int]     Don't trim PPA apertures to fewer than this many pixels.
%        k2GapIfNotFinePntData .........................[logical] Gap cadences for which isFinePoint == false.
%        k2GapPreTweakData .............................[logical] Gap cadences up to and including the last attitude tweak cadence.
%
%--------------------------------------------------------------------------
%    Level 2
%
%    paCoaConfigurationStruct is a struct with the following fields:
%
%        cadenceStep ........................[double]
%        computeForSaturatedTargetsEnabled ..[logical]
%        cdppOptimizationEnabled ............[logical]
%        cdppVsSnrStrengthFactor ............[double]
%        cdppSweepLength ....................[double]
%        cdppMedFiltSmoothLength ............[double]
%        mnrAddedFluxBeta ...................[double]
%        mnrBeta0 ...........................[double]
%        mnrDiscriminationThreshold .........[double]
%        mnrFractionalChangeInApertureBeta ..[double]
%        mnrFractionalChangeInMedianFluxBeta [double]
%        mnrMaskUsageRatioBeta ..............[double]
%        numberOfHalosToAddToAperture .......[double]
%        raDecFittingCadenceStep ............[double]
%        revertToTadIfApertureShrank ........[logical]
%        superResolutionFactor ..............[double]
%        trialTransitPulseDurationInHours ...[double]
%        usePolyFitTransitModel .............[logical]
%        varianceWindowLengthMultiplier .....[double]
%        waveletFilterLength ................[double]
%        boundedBoxWidth ....................[double]
%
%--------------------------------------------------------------------------
%    Level 2
%
%    apertureModelConfigurationStruct is a struct with the following fields:
%
%        excludeSnrThreshold ....[float]   Include catalog stars in the
%                                          model only if their expected
%                                          peak pixel SNR is above this
%                                          threshold. 
%        lockSnrThreshold .......[float]   Do not allow RA/Dec fitting of
%                                          stars whose expected peak pixel
%                                          SNR falls below this threshold.   
%        raDecFitMethod .........[string]  Either 'nlinfit' or 'lsqnonlin' 
%                                          ('lsqnonlin' is valid only if
%                                          the Matlab.
%        amplitudeFitMethod .....[string]  One of the following: 'bbnnls', 
%                                          'lsqnonneg', or 'unconstrained'.
%        raDecFittingEnabled ....[logical] If FALSE, catalog positions are
%                                          fixed. If TRUE, update the
%                                          positions for eligible stars.
%        raDecMaxDeltaPixels ....[float]   Maximum allowed deviation from 
%                                          catalog positions in units of
%                                          pixels. 
%        raDecRestoringCoef .....[float]   Coefficient determining how 
%                                          strongly each star's position is
%                                          pulled back toward the catalog
%                                          position during the fitting
%                                          process. If zero, then no
%                                          restoring force is applied. 
%        raDecRepulsiveCoef .....[float]   Coefficient determining how 
%                                          strongly stars are pushed away
%                                          from one another during the 
%                                          fitting process. If zero, then
%                                          no repulsive force is applied.
%        raDecMaxIter ...........[int]     Maximum number of iterations 
%                                          when fitting star positions (RA
%                                          & Dec) for an aperture. 
%        raDecTolFun ............[float]   Stop the optimization procedure 
%                                          if the function value changes
%                                          less than this amount. 
%        raDecTolX ..............[float]   Stop the optimization procedure 
%                                          if the parameter vector moves
%                                          less than this amount.
%        maxDeltaMagnitude ......[float]   Maximum allowed change in Kepler  
%                                          magnitude during PA-COA.
%        maxNumStars ............[int]     Maximum number of stars to 
%                                          include in a model.
%        ukirtMagnitudeThreshold [float]   Exclude UKIRT stars brighter 
%                                          than this magnitude.
%
%--------------------------------------------------------------------------
%    Level 2
%
%    pouConfigurationStruct is a struct with the following fields:
%
%        pouEnabled ...................[logical] true if uncertainty. 
%                                                propagation is enabled.
%        compressionEnabled ...........[logical] true for compression of
%                                                POU output.
%        numErrorPropVars .............[int]     number of variables for
%                                                POU. 
%        maxSvdOrder ..................[int]     max order for SVD
%                                                compression.
%        pixelChunkSize ...............[int]     pixel chunking for POU.
%        cadenceChunkSize .............[int]     cadence chunking for POU.
%        maxBackgroundCadenceChunkSize [int]
%        interpDecimation .............[int]     resampling factor for POU.
%        interpMethod .................[string]  interpolation method for 
%                                                POU (e.g. 'linear').
%--------------------------------------------------------------------------
%    Level 2
%
%    reactionWheelAncillaryEngineeringConfigurationStruct is a struct with
%    the following fields: 
%
%        mnemonics .............[string array]  mnemonic names.
%        modelOrders ...........[int array]     polynomial orders for RW.
%        quantizationLevels ....[float array]   engineering data step sizes.
%        intrinsicUncertainties [float array]   engineering data
%                                               uncertainties.
%        interactions ..........[string array]  array of mnemonic pairs 
%                                               ('|' separated) for RW
%                                               interactions.
%
%--------------------------------------------------------------------------
%    Level 2
%
%    saturationSegmentConfigurationStruct is a struct with the following fields:
%
%        sgPolyOrder ...........[int]   order of Savitzky-Golay filter to
%                                       detect saturated segments.
%        sgFrameSize ...........[int]   length of Savitzky-Golay frame.
%        satSegThreshold .......[float] threshold for identifying
%                                       saturated segments.
%        satSegExclusionZone ...[int]   zone for excluding secondary peaks.
%        maxSaturationMagnitude [float] highest magnitude target that can
%                                       still be saturated.
%
%--------------------------------------------------------------------------
%    Level 2
%
%    thrusterDataAncillaryEngineeringConfigurationStruct is a struct with
%    the following fields: 
%
%        mnemonics .......................{cell array}
%        modelOrders .....................[float array] UNUSED
%        quantizationLevels ..............[float array] UNUSED
%        intrinsicUncertainties ..........[float array] UNUSED
%        interactions ....................[]            UNUSED
%        thrusterFiringDataCadenceSeconds [float]
%
%     Note that we are reusing the oapAncillaryConfigurationStruct and that
%     most of these fields, though "validated", are unused.
%--------------------------------------------------------------------------
%    Level 2
%
%    ancillaryEngineeringDataStruct is a struct array with the following
%    fields: 
%
%        mnemonic ..[char]        One of: 'ADRW1SPD_', 'ADRW2SPD_', 
%                                 'ADRW3SPD_', 'ADRW4SPD_'.
%        timestamps [float array] Times (MJD) corresponding to wheel speeds.
%        values ....[float array] Wheel speeds (ADU).
%
%--------------------------------------------------------------------------
%    Level 2
%
%    prfModel is a struct with the following fields:
%
%        mjd ............[double]
%        ccdModule ......[double]
%        ccdOutput ......[double]
%        blob ...........[double]
%        fcModelMetadata [struct]
%
%--------------------------------------------------------------------------
%    Level 2
%
%    raDec2PixModel is a struct with the following fields:
%
%        mjdStart ........................[double]
%        mjdEnd ..........................[double]
%        spiceFileDir ....................[char]
%        spiceSpacecraftEphemerisFilename [char]
%        planetaryEphemerisFilename ......[char]
%        leapSecondFilename ..............[char]
%        pointingModel ...................[struct]
%        geometryModel ...................[struct]
%        rollTimeModel ...................[struct]
%        HALF_OFFSET_MODULE_ANGLE_DEGREES [double]
%        OUTPUTS_PER_ROW .................[double]
%        OUTPUTS_PER_COLUMN ..............[double]
%        nRowsImaging ....................[double]
%        nColsImaging ....................[double]
%        nMaskedSmear ....................[double]
%        nLeadingBlack ...................[double]
%        NOMINAL_CLOCKING_ANGLE ..........[double]
%        nModules ........................[double]
%        mjdOffset .......................[double]
%
%--------------------------------------------------------------------------
%    Level 2
%
%    readNoiseModel is a struct with the following fields:
%
%        mjds ...........[double]
%        constants ......[struct]
%        fcModelMetadata [struct]
%
%--------------------------------------------------------------------------
%    Level 2
%
%    gainModel is a struct with the following fields:
%
%        mjds ...........[double]
%        constants ......[struct]
%        fcModelMetadata [struct]
%
%--------------------------------------------------------------------------
%    Level 2
%
%    linearityModel is a struct with the following fields:
%
%        mjds ...........[double]
%        constants ......[struct]
%        uncertainties ..[struct]
%        offsetXs .......[double]
%        scaleXs ........[double]
%        originXs .......[double]
%        types ..........[cell]
%        xIndices .......[double]
%        maxDomains .....[double]
%        fcModelMetadata [struct]
%
%--------------------------------------------------------------------------
%    Level 2
%
%    calUncertaintyBlobs is a struct with the following fields:
%
%        blobIndices ..[double]
%        gapIndicators [double]
%        blobFilenames [double]
%        startCadence .[double]
%        endCadence ...[double]
%
%--------------------------------------------------------------------------
%    Level 2
%
%    backgroundBlobs is a struct with the following fields:
%
%        blobIndices ..[double]
%        gapIndicators [double]
%        blobFilenames [double]
%        startCadence .[double]
%        endCadence ...[double]
%
%--------------------------------------------------------------------------
%    Level 2
%
%    motionBlobs is a struct with the following fields:
%
%        blobIndices ..[double]
%        gapIndicators [double]
%        blobFilenames [double]
%        startCadence .[double]
%        endCadence ...[double]
%
%--------------------------------------------------------------------------
%    Level 2
%
%    rollingBandArtifactFlags is a struct with the following fields:
%
%        row ................[double]
%        testPulseDurationLc [double]
%        flags ..............[struct]
%        variationLevel .....[struct]
%
%    Where the fields 'flags' and 'variationLevel' are structs having the
%    following fields: 
%        values ...........[double]
%        gapIndicators ....[logical]
%
%--------------------------------------------------------------------------
%    Level 3
%
%    pixelDataStruct is an array of structs (one per pixel in aperture) 
%    with the same fields as the backgroundDataStruct.
%
%        values ...........[double]
%        gapIndicators ....[logical]
%        uncertainties ....[double]
%        ccdRow ...........[double]
%        ccdColumn ........[double]
%        inOptimalAperture [logical]
%
%--------------------------------------------------------------------------
%    Level 3
%
%    kics is a struct array with many fields. Only the following are used
%    in PA:
%
%        keplerId ...........[int]
%        keplerMag ..........[struct]
%        ra .................[struct]
%        dec ................[struct]
%
%--------------------------------------------------------------------------
%    Level 3
%
%    kicEntryData is a struct with the following fields:
%
%        KICID ........[int]
%        RA ...........[double]
%        dec ..........[double]
%        magnitude ....[double]
%        effectiveTemp [double]
%
%--------------------------------------------------------------------------
%    Level 3
%
%    rmsCdppStruct is an array of structs (one per trial transit pulse
%    duration) with the following fields:
%
%        trialTransitPulseInHours [float]  trial transit pulse duration,
%                                          hours.
%                         rmsCdpp [float]  RMS CDPP for given target, pulse 
%                                          duration and UOW.
%
%--------------------------------------------------------------------------
%    Level 3
%
%     flags is a struct with the following fields:
%
%                    values: [float array]  per cadence flag values.
%           gapIndicators: [logical array]  per cadence gap indicators.
%
%--------------------------------------------------------------------------
%    Level 3
%
%    MOD_OUT_TO_INDEX is a struct with the following fields:
%
%        array [double]
%
%--------------------------------------------------------------------------
%    Level 3
%
%    MOD_OUT_IN_GRID_ORDER is a struct with the following fields:
%
%        array [double]
%
%--------------------------------------------------------------------------
%    Level 3
%
%    outputArrangements is a struct with the following fields:
%
%        array [double]
%
%--------------------------------------------------------------------------
%    Level 3
%
%    zodiGrid is a struct with the following fields:
%
%        array [double]
%
%--------------------------------------------------------------------------
%    Level 3
%
%    entries is a struct with the following fields:
%
%        mnemonic [char]
%        value ...[char]
%
%--------------------------------------------------------------------------
%    Level 3
%
%    dataAnomalyFlags is a struct with the following fields, each of which 
%    is a 1-by-nCadences logical array:
%
%        attitudeTweakIndicators ......[logical array] true for a cadence if an attitude tweak was in progress.
%        safeModeIndicators ...........[logical array] true for a cadence if the spacecraft was in safe mode.
%        coarsePointIndicators ........[logical array] true for a cadence if the spacecraft was in coarse pointing mode.
%        argabrighteningIndicators ....[logical array] true for a cadence if an Argabrightening event was in progress.
%        excludeIndicators ............[logical array] true if the cadence is to be excluded from processing.
%        earthPointIndicators .........[logical array] true for a cadence if an Earth-point cadence maneuver was in progress.
%        planetSearchExcludeIndicators [logical array] markers for cadences to exclude explicitly from TPS/DV.
%
%--------------------------------------------------------------------------
%    Level 3
%
%    fcModelMetadata is a struct with the following fields:
%
%        svnInfo .........[char]
%        ingestTime ......[char]
%        modelDescription [char]
%        databaseUrl .....[char]
%        databaseUsername [char]
%
%--------------------------------------------------------------------------
%    Level 3
%
%    pointingModel is a struct with the following fields:
%
%        mjds ............[double]
%        ras .............[double]
%        declinations ....[double]
%        rolls ...........[double]
%        segmentStartMjds [double]
%        fcModelMetadata .[struct]
%
%--------------------------------------------------------------------------
%    Level 3
%
%    geometryModel is a struct with the following fields:
%
%        mjds ...........[double]
%        constants ......[struct]
%        uncertainty ....[struct]
%        fcModelMetadata [struct]
%
%--------------------------------------------------------------------------
%    Level 3
%
%    rollTimeModel is a struct with the following fields:
%
%        mjds .................[double]
%        seasons ..............[double]
%        rollOffsets ..........[double]
%        fovCenterRas .........[double]
%        fovCenterDeclinations [double]
%        fovCenterRolls .......[double]
%        fcModelMetadata ......[struct]
%
%--------------------------------------------------------------------------
%    Level 3
%
%    fcModelMetadata is a struct with the following fields:
%
%        svnInfo .........[char]
%        ingestTime ......[char]
%        modelDescription [char]
%        databaseUrl .....[char]
%        databaseUsername [char]
%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%  OUTPUT:  A data structure paResultsStruct with the following fields.
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%    Level 1
%
%    paResultsStruct is a struct with the following fields:
%
%        processingState ...................[string]     Processing state label.
%        ccdModule .........................[int]        CCD module number.
%        ccdOutput .........................[int]        CCD output number.
%        cadenceType .......................[string]     'LONG' or 'SHORT'
%        startCadence ......................[int]        start cadence index
%        endCadence ........................[int]        end cadence index
%        targetStarResultsStruct ...........[struct array]  target flux time series.
%        backgroundCosmicRayEvents .........[struct array]  background CR events.
%        backgroundCosmicRayMetrics ........[struct]     background CR metrics
%        targetStarCosmicRayEvents .........[struct array]  target CR events.
%        targetStarCosmicRayMetrics ........[struct]     target CR metrics.
%        encircledEnergyMetrics ............[struct]     encircled energy time series.
%        brightnessMetrics .................[struct]     brightness metric time series.
%        argabrighteningIndices ............[int array]  indices of Argabrightening cadences.
%        reactionWheelZeroCrossingIndices ..[int array]  indices of reaction wheel zero crossing cadences.
%        definiteThrusterActivityIndicators [logical array]  flag cadences on which thrusters were active.
%        possibleThrusterActivityIndicators [logical array]  flag cadences on which thrusters may have been active (occasionally there is ambiguity near cadence boundaries).
%        badPixels .........................[struct array]  bad pixels.
%        backgroundBlobFileName ............[string]     background fit coefficients (file name).
%        motionBlobFileName ................[string]     motion polynomials (file name).
%        uncertaintyBlobFileName ...........[string]     output primitives and transformations (file name).
%        simulatedTransitsBlobFile .........[]
%        alerts ............................[struct array]  module alert(s).
%
%--------------------------------------------------------------------------
%    Level 2
%
%    targetStarResultsStruct is a struct with the following fields:
%
%        keplerId ........................[int]     Kepler target ID.
%        keplerMag .......................[float]   target magnitude.
%        raHours .........................[double]  target right ascension (hours).
%        decDegrees ......................[double]  target declination (degrees).
%        referenceRow ....................[int]     target reference row.
%        referenceColumn .................[int]     target reference column.
%        fluxTimeSeries ..................[struct]  target flux time series.
%        backgroundFluxTimeSeries ........[struct]  background flux time series
%        signalToNoiseRatioTimeSeries ....[struct]  The SNR found by PA-COA
%        fluxFractionInApertureTimeSeries [struct]  The Flux Fraction found
%                                                   by PA-COA.
%        crowdingMetricTimeSeries ........[struct]  The Crowding Metric
%                                                   found by PA-COA.
%        skyCrowdingMetricTimeSeries .....[struct]
%        prfCentroids ....................[struct]  PRF-based centroids
%        fluxWeightedCentroids ...........[struct]  flux-weighted centroids.
%        barycentricTimeOffset ...........[struct]  offsets for MJD to 
%                                                   barycentric MJD conversion.
%        pixelApertureStruct .............[struct]  centroid aperture 
%                                                   indicators, with one
%                                                   element per pixel.
%        optimalAperture .................[struct]
%        rollingBandContaminationStruct ..[struct]  rolling band severity  
%                                                   per levels pulse
%                                                   duration and cadence. 
%        medianPhotocurrentAdded .........[double]
%
%--------------------------------------------------------------------------
%    Level 2
%
%     backgroundCosmicRayEvents and targetStarCosmicRayEvents are arrays of
%     structs with the following fields:
%
%        ccdRow ...[double] cosmic ray event row.
%        ccdColumn [double] cosmic ray event column.
%        mjd ......[double] cosmic ray event time, MJD.
%        delta ....[double] cosmic ray event delta.
%
%--------------------------------------------------------------------------
%    Level 2
%
%     backgroundCosmicRayMetrics and targetStarCosmicRayMetrics are structs
%     with the following fields:
%
%        empty .........[logical] metric structs empty if true.
%        hitRate .......[struct]  cosmic ray hit rates.
%        meanEnergy ....[struct]  cosmic ray mean energies.
%        energyVariance [struct]  cosmic ray energy variance.
%        energySkewness [struct]  cosmic ray energy skewness.
%        energyKurtosis [struct]  cosmic ray energy kurtosis.
%
%--------------------------------------------------------------------------
%    Level 2
%
%     badPixels is an array of structs with the following fields:
%
%        ccdRow ...[int]     bad pixel row.
%        ccdColumn [int]     bad pixel column.
%        type .....[string]  bad pixel type.
%        startMjd .[double]  bad pixel start time, MJD.
%        endMjd ...[double]  bad pixel stop time, MJD.
%        value ....[float]   bad pixel value  [see KADN-26176].
%
%--------------------------------------------------------------------------
%    Level 2
%
%     encircledEnergyMetrics and brightnessMetrics are structs with the
%     following fields: 
%
%        values .......[float array]    data values.
%        uncertainties [float array]    uncertainties in data values.
%        gapIndicators [logical array]  data gap indicators.
%
%--------------------------------------------------------------------------
%    Level 2
%
%    alerts is an array of structs with the following fields:
%
%        time ....[double]  alert time, MJD.
%        severity [string]  alert severity ('error' or 'warning').
%        message .[string]  alert message.
%
%--------------------------------------------------------------------------
%    Level 3
%
%    fluxTimeSeries and backgroundFluxTimeSeries are structs with the
%    following fields: 
%
%        values .......[float array]    data values.
%        uncertainties [float array]    uncertainties in data values.
%        gapIndicators [logical array]  data gap indicators.
%
%--------------------------------------------------------------------------
%    Level 3
%
%    signalToNoiseRatioTimeSeries, fluxFractionInApertureTimeSeries,
%    crowdingMetricTimeSeries, and skyCrowdingMetricTimeSeries are a
%    structs with the following fields:  
%
%        values .......[float array]    data values.
%        gapIndicators [logical array]  data gap indicators.
%
%--------------------------------------------------------------------------
%    Level 3
%
%    prfCentroids and fluxWeightedCentroids are structs with the following
%    fields: 
%
%        rowTimeSeries ...[struct]  target row centroids
%        columnTimeSeries [struct]  target column centroids
%
%--------------------------------------------------------------------------
%    Level 3
%
%    barycentricTimeOffset is a struct with the following fields:
%
%        values .......[float array]    offsets for conversion from MJD's 
%                                       to barycentric MJD's (days).
%        gapIndicators [logical array]  true if offset is unvailable for
%                                       a given cadence.
%
%--------------------------------------------------------------------------
%    Level 3
%
%    pixelApertureStruct is an array of structs (one element per pixel for
%    the given target) with the following fields:
%
%        ccdRow ........................[int]     pixel row.
%        ccdColumn .....................[int]     pixel column.
%        inPrfCentroidAperture .........[logical] true if pixel is in
%                                                 aperture for PRF-based
%                                                 centroiding; set false by
%                                                 default if PRF centroids
%                                                 were not computed for the
%                                                 given target.
%        inFluxWeightedCentroidAperture [logical] true if pixel is in
%                                                 aperture for
%                                                 flux-weighted centroiding.
%
%--------------------------------------------------------------------------
%    Level 3
%
%    optimalAperture is a struct with the following fields:
%
%        keplerId ................[double]
%        signalToNoiseRatio ......[double]
%        fluxFractionInAperture ..[double]
%        crowdingMetric ..........[double]
%        skyCrowdingMetric .......[double]
%        badPixelCount ...........[double]
%        referenceRow ............[double]
%        referenceColumn .........[double]
%        saturatedRowCount .......[double]
%        apertureUpdatedWithPaCoa [logical]
%        offsets .................[struct]
%        distanceFromEdge ........[double]
%
%--------------------------------------------------------------------------
%    Level 3
%
%    rollingBandContaminationStruct is an array of structs (one per rolling
%    band pulse duration) with the following fields:
%
%        testPulseDurationLc [int]     pulse duration in cadences.
%        severityFlags ......[struct]  discrete rolling band severity 
%                                      metrics pertaining to optimal
%                                      aperture.
%
%--------------------------------------------------------------------------
%    Level 3
%
%    hitRate, meanEnergy, energyVariance, energySkewness and energyKurtosis
%    are structs with the following fields:
%
%        values .......[float array]    metric data values.
%        gapIndicators [logical array]  metric gap indicators.
%
%--------------------------------------------------------------------------
%    Level 4
%
%    rowTimeSeries and columnTimeSeries are structs with the following
%    fields:
%
%        values .......[double array]   centroid values.
%        uncertainties [float array]    uncertainties in centroid values.
%        gapIndicators [logical array]  centroid gap indicators.
%
%--------------------------------------------------------------------------
%    Level 4
%
%    offsets is a struct with the following fields:
%
%        row ...[double]
%        column [double]
%
%--------------------------------------------------------------------------
%    Level 4
%
%    severityFlags is a struct with the following fields:
%
%        values .......[float array]    contamination values.
%        gapIndicators [logical array]  contamination gap indicators.
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
paStateFileName = 'pa_state.mat';

% Disable debug mode if flag is not set.
if isfield(paDataStruct.paConfigurationStruct, 'debugLevel')
    debugLevel = paDataStruct.paConfigurationStruct.debugLevel;
else
    debugLevel = 0;
end

% Update the PA data structure. Add names of PA MATLAB files. Convert blobs
% to structs if this is the first call, otherwise load the structs from
% MATLAB files. Attach these structures to input data struct. Initialize
% the PA state file if this is the first call. Remove blobs from input data
% struct.
[paDataStruct, stateFileNames] = update_pa_inputs(paDataStruct);

% Check for the presence of expected fields in the input structure, check 
% whether each parameter is within the appropriate range, convert row/column
% inputs from 0-based indexing (Java) to 1-based indexing (Matlab), and
% instantiate paDataClass object.
validate_pa_inputs(paDataStruct);
[paDataStruct] = convert_pa_inputs_to_1_base(paDataStruct);
[paDataObject] = paDataClass(paDataStruct);

% If processing K2 data.
processingK2Data = paDataStruct.cadenceTimes.startTimestamps(1) > ...
    paDataStruct.fcConstants.KEPLER_END_OF_MISSION_MJD;
if processingK2Data
    
    % If aperture trimming is enabled, trim apertures of non-custom PPA
    % targets as necessary. Trimming is done to speed up PRF centroiding
    % for large apertures.
    if paDataStruct.paConfigurationStruct.k2TrimAperturesEnabled ...
    && strcmpi(paDataStruct.processingState, 'PPA_TARGETS')

        k2TrimRadiusInPrfWidths = ...
            paDataStruct.paConfigurationStruct.k2TrimRadiusInPrfWidths;
        k2TrimMinSizeInPixels = ...
            paDataStruct.paConfigurationStruct.k2TrimMinSizeInPixels;

        % NOTE that we perform this operation on the paDataObject rather
        % than the paDataStruct because the field orderings are different.
        % Constructing an raDec2PixObject here using one ordering and then
        % attempting to do so later with a different ordering (unless
        % 'clear classes' is called) will result in an error.
        paDataObject = trim_stellar_target_apertures(paDataObject, ...
            k2TrimRadiusInPrfWidths  , k2TrimMinSizeInPixels );
   end
   
    % Remove pixels for which no data was collected in the active cadence
    % range.
    paDataObject = remove_fully_gapped_pixels(paDataObject);
    
    % If this is the first call, process thruster firing data and save the
    % indicator arrays to the state file.
    if paDataStruct.firstCall
        [~, thrusterFiringEvents] = process_K2_thruster_firing_data(paDataStruct);  
        save(paStateFileName, 'thrusterFiringEvents', '-append');
    end
end

% Run PA for the given module output or perform other functions, depending
% on processing state.
switch paDataStruct.processingState
    case {'BACKGROUND', 'PPA_TARGETS', 'TARGETS'}
        
        [paResultsStruct] = photometric_analysis(paDataObject);
               
    case 'GENERATE_MOTION_POLYNOMIALS'
        
        % Aggregate results from background and PPA processing and save to
        % state file.
        aggregate_ppa_target_results_to_state_file( paDataObject );
        
        % If paDataObject.motionPolyStruct is empty and sufficient PPA
        % targets are available, Read target results from state file and
        % fit motion polynomials.
        [paResultsStruct] = generate_motion_polynomials(paDataObject);
        
        % If we are processing only PPA targets, which is done to save time
        % on the suplemental TAD run, then this is the last call. The
        % entire purpose of such a run is to generate motion polynomials,
        % so we need only populate the motionBlobFileName field of the
        % output struct.
        if paDataStruct.paConfigurationStruct.onlyProcessPpaTargetsEnabled
            [paResultsStruct] = initialize_pa_output_structure(paDataObject);
            paMotionFileName = paDataStruct.paFileStruct.paMotionFileName;
            if exist(paMotionFileName, 'file')
                paResultsStruct.motionBlobFileName = paMotionFileName;
            else
                error('Motion blob file %s does not exist', paMotionFileName);
            end
        end
        
    case 'MOTION_BACKGROUND_BLOBS'
        
        [paResultsStruct] = photometric_analysis(paDataObject);

        [paResultsStruct] = ...
            identify_argabrightening_cadences_and_fill_background_polys(...
                paDataObject, paResultsStruct);

    case 'AGGREGATE_RESULTS'
        
        aggregate_results_to_state_file(paDataObject);
        
        % Build the final PA output structure. Fit motion polynomials, if
        % necessary. Generate figures. 
        [paResultsStruct] = finalize(paDataObject);

        % Aggregate DAWG metrics for all targets, both PPA and non-PPA.
        aggregate_dawg_metrics( paDataObject );

    otherwise
        error('Invalid processing state');
end

% Validate the PA outputs.
[paResultsStruct] = validate_pa_outputs(paDataObject, paResultsStruct);

% Add the contents of thrusterFiringEvents to the paResultsStruct on the
% first pass through PA. The thrusterFiringEvents struct should always
% exist if we're processing K2 data and this is the first call, but we
% check just to be sure.
if processingK2Data && paDataStruct.firstCall && exist('thrusterFiringEvents', 'var')
    % Create and populate thrusterFiringEvents struct
    paResultsStruct.definiteThrusterActivityIndicators = ...
        thrusterFiringEvents.definiteThrusterActivityIndicators;
    paResultsStruct.possibleThrusterActivityIndicators = ...
        thrusterFiringEvents.possibleThrusterActivityIndicators;
end


% Develop metrics and plots for DAWG data reviews.
if any( strcmpi(paDataStruct.processingState, ...
    {'BACKGROUND', 'PPA_TARGETS', 'TARGETS'}) )
    generate_pa_data_validation_metrics_and_plots(paDataStruct, paResultsStruct);
end

% Convert row/column outputs from Matlab 1-base to Java 0-base.
[paResultsStruct] = convert_pa_outputs_to_0_base(paResultsStruct);

% Save the PA data and results structures if the debugLevel is not 0. Time
% stamp the debug file.
if debugLevel
    dateStr = datestr(now);
    dateStr = strrep(dateStr, '-', '_');
    dateStr = strrep(dateStr, ' ', '_');
    dateStr = strrep(dateStr, ':', '_');
    debugFileName = ['pa_debug_' dateStr '.mat'];
    save(debugFileName, 'paDataStruct', 'paResultsStruct');
end

% Move output files to root task directory.
copy_files_to_root_task_dir(paDataObject, 'move');


% Return.
return
