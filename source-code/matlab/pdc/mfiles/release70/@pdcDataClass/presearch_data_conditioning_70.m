function [pdcResultsStruct] = presearch_data_conditioning_70(pdcDataObject)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [pdcResultsStruct] = presearch_data_conditioning_70(pdcDataObject)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% This is the primary method of the pdcDataClass. Perform presearch data
% conditioning (PDC) for a given module output as follows:
%
%   1. Condition ancillary data
%   2. Correct systematic errors in relative flux time series by cotrending
%      against the conditioned ancillary data
%   3. Identify and remove outliers in the cotrended flux time series
%   4. Fill short and long gaps in the cotrended flux time series
%      (including those created by the removal of outliers)
%
% The typical PDC unit of work is one module output for one month or one
% quarter. The relative flux time series may be sampled at the short or
% long cadence rate. The ancillary data are synchronized with target time
% series by binning and/or resampling, depending on the sample rate of the
% individual ancillary channels. Cotrending is performed by either robust
% or standard least squares fit. Outliers are identified in a robust
% fashion without reliance on specific statistical models or distributions.
% Short gaps are filled by autoregressive (AR) modeling; long gaps are
% filled by reflecting flux segments into gaps and maintaining continuity
% in the variance of wavelet domain coefficients at multiple scales.
%
% The corrected flux time series are returned by this function, along with
% uncertainties in the corrected flux values computed by standard error
% propagation methods. Indices and values of replaced outliers are also
% returned by this function.
%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% INPUT:  A data structure 'pdcDataStruct' with the following fields:
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%   Top level
%
%     pdcDataStruct contains the following fields:
%
%                         ccdModule: [int]  CCD module number
%                         ccdOutput: [int]  CCD output number
%                    cadenceType: [string]  'LONG' or 'SHORT'
%                      startCadence: [int]  start cadence index
%                        endCadence: [int]  end cadence index
%                    fcConstants: [struct]  Fc constants
%      spacecraftConfigMap: [struct array]  one or more spacecraft config maps
%                 raDec2PixModel: [struct]  ra/dec to pixel model
%                   cadenceTimes: [struct]  cadence times and gap indicators
%               longCadenceTimes: [struct]  long cadence times and gap indicators
%                                           for attitude solution
%            pdcModuleParameters: [struct]  module parameters
%    saturationSegmentConfigurationStruct:
%                                 [struct]  saturation segment identification parameters
% harmonicsIdentificationConfigurationStruct:
%                                 [struct]  harmonics identification parameters
%        discontinuityConfigurationStruct:
%                                 [struct]  discontinuity identification parameters
% ancillaryEngineeringConfigurationStruct:
%                                 [struct]  config parameters for engineering data
%    ancillaryPipelineConfigurationStruct:
%                                 [struct]  config parameters for pipeline data
% ancillaryDesignMatrixConfigurationStruct:
%                                 [struct]  module parameters for filtering ancillary
%                                           design matrix
%     gapFillConfigurationStruct: [struct]  gap fill config parameters
%       ancillaryEngineeringDataStruct: 
%                           [struct array]  engineering data for cotrending
%          ancillaryPipelineDataStruct: 
%                           [struct array]  pipeline data for contrending
%         targetDataStruct: [struct array]  target flux to be corrected
%               motionBlobs: [blob series]  motion polynomials from PA
%
%--------------------------------------------------------------------------
%   Second level
%
%     cadenceTimes and longCadenceTimes are structs with the following fields:
%
%          startTimestamps: [double array]  cadence start times, MJD
%            midTimestamps: [double array]  cadence mid times, MJD
%            endTimestamps: [double array]  cadence end times, MJD
%           gapIndicators: [logical array]  true if cadence is unavailable
%          requantEnabled: [logical array]  true if requantization was enabled
%              cadenceNumbers: [int array]  absolute cadence numbers
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
%     pdcModuleParameters is a struct with the following fields:
%
%                        debugLevel: [int]  level for science debug
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
%     harmonicsIdentificationConfigurationStruct is a struct with the following
%     fields:
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
%                timeOutInMinutes: [float]  timeout limit in minutes for a given time
%                                           series
%
%--------------------------------------------------------------------------
%   Second level
%
%     discontinuityConfigurationStruct is a struct with the following
%     fields:
%
%       discontinuity model: [float array]  coefficients for discontinuity
%                                           identification
%                medianWindowLength: [int]  length of median filter
%         savitzkyGolayFilterLength: [int]  length of Savitzky-Golay filter
%            savitzkyGolayPolyOrder: [int]  order of Savitzky-Golay filter
%   discontinuityThresholdInSigma: [float]  discontinuity detection threshold
%             ruleOutTransitRatio: [float]  discriminator between discontinuities
%                                           and transits
%    varianceWindowLengthMultiplier: [int]  multiplier for S-G filter length for
%                                           window to estimate variance
%   maxNumberOfUnexplainedDiscontinuities:
%                                    [int]  max allowable discontinuities per
%                                           target
%
%--------------------------------------------------------------------------
%   Second level
%
%     ancillaryEngineeringConfigurationStruct is a struct with the following fields:
%
%                mnemonics: [string array]  mnemonic names
%                 modelOrders: [int array]  polynomial orders for cotrending
%             interactions: [string array]  array of mnemonic pairs ('|'
%                                           separated) for cotrending interactions
%        quantizationLevels: [float array]  engineering data step sizes
%    intrinsicUncertainties: [float array]  engineering data uncertainties
%
%--------------------------------------------------------------------------
%   Second level
%
%     ancillaryPipelineConfigurationStruct is a struct with the following fields:
%
%                mnemonics: [string array]  mnemonic names
%                 modelOrders: [int array]  polynomial orders for cotrending
%             interactions: [string array]  array of mnemonic pairs ('|'
%                                           separated) for cotrending interactions
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
%  gapFillModeIsAddBackPredictionError:
%                                [logical]  true if gap fill mode is add back
%                                           prediction error
%           removeEclipsingBinariesOnList:
%                                [logical]  true if short period binaries are to be
%                                           removed prior to giant transit identification
%                  waveletFamily: [string]  name of wavelet family, e.g. 'daub'
%               waveletFilterLength: [int]  number of wavelet filter coefficients
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
%   Second level
%
%     targetDataStruct is an array of structs (one per target) with the following
%     fields:
%
%                          keplerId: [int]  kepler target ID
%                       keplerMag: [float]  target magnitude
%          fluxFractionInAperture: [float]  fraction of target flux captured
%                                           in aperture
%                  crowdingMetric: [float]  fraction of total flux in aperture
%                                           due to target
%                    values: [float array]  flux values to be corrected
%             uncertainties: [float array]  uncertainties in flux values
%           gapIndicators: [logical array]  flux gap indicators
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
%
%--------------------------------------------------------------------------
%   Third level
%
%     kic is a struct with the following fields:
%
%                       keplerId:    [int]  Kepler target ID
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
%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%  OUTPUT:  A data structure pdcResultsStruct with the following fields.
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%   Top level
%
%     pdcResultsStruct contains the following fields:
%
%                         ccdModule: [int]  CCD module number
%                         ccdOutput: [int]  CCD output number
%                    cadenceType: [string]  'LONG' or 'SHORT'
%                      startCadence: [int]  start cadence index
%                        endCadence: [int]  end cadence index
%      targetResultsStruct: [struct array]  corrected target flux and outliers
%                   alerts: [struct array]  module alert(s)
%
%--------------------------------------------------------------------------
%   Second level
%
%     targetResultsStruct is an array of structs (one per target) with the
%     following fields:
%
%                          keplerId: [int]  Kepler target ID
%        correctedFluxTimeSeries: [struct]  corrected PDC time series as
%                                           described above
%   harmonicFreeCorrectedFluxTimeSeries:
%                                 [struct]  corrected PDC time series with
%                                           harmonics removed
%                       outliers: [struct]  outlier indices and values for
%                                           each target
%           harmonicFreeOutliers: [struct]  outlier indices and values with
%                                           harmonics removed
%        discontinuityIndices: [int array]  indices of identified discontinuities
%                                           for the given target
%           dataProcessingStruct: [struct]  data processing flags or other
%                                           characteristics for the given target                                      for the given target
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
%     correctedFluxTimeSeries and harmonicFreeCorrectedFluxTimeSeries are structs
%     with the following fields:
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
%     outliers and harmonicFreeOutliers are structs with the following fields:
%
%                    values: [float array]  values of corrected flux outliers
%             uncertainties: [float array]  uncertainties in corrected flux
%                                           outliers
%                     indices: [int array]  indices of outliers
%
%--------------------------------------------------------------------------
%   Third level
%
%     dataProcessingStruct is a struct with the following fields:
%
%               initialVariable: [logical]  if true, target initially identified as
%                                           variable for systematic error correction
%                 finalVariable: [logical]  if true, target ultimately processed as
%                                           variable for systematic error correction
%               harmonicsFitted: [logical]  if true, harmonics were successfully fitted
%             harmonicsRestored: [logical]  if true, harmonics were restored prior to PDC
%                                           termination
%        uncorrectedSystematics: [logical]  if true, raw flux passed to back end of PDC
%                                           in place of cotrended flux
%     uncorrectedSuspectedDiscontinuity: 
%                                [logical]  if true, one or more identified discontinuities
%                                           could not be corrected
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


% Set constants.
PDC_STATE_FILENAME = 'pdc_state.mat';
CONDITIONED_ANCILLARY_FILENAME = 'pdc_cads.mat';

RESTORE_MEAN_FLAG = true;

% Get the required fields and structures from the input object.
cadenceType = pdcDataObject.cadenceType;
ccdModule = pdcDataObject.ccdModule;
ccdOutput = pdcDataObject.ccdOutput;

cadenceTimes = pdcDataObject.cadenceTimes;
startTimestamps = cadenceTimes.startTimestamps;
endTimestamps = cadenceTimes.endTimestamps;
cadenceGapIndicators = cadenceTimes.gapIndicators;
dataAnomalyIndicators = cadenceTimes.dataAnomalyFlags;

longCadenceTimes = pdcDataObject.longCadenceTimes;
lcDataAnomalyIndicators = longCadenceTimes.dataAnomalyFlags;

pdcModuleParameters = pdcDataObject.pdcModuleParameters;
normalizationEnabled = pdcModuleParameters.normalizationEnabled;
saturationSegmentConfigurationStruct = ...
    pdcDataObject.saturationSegmentConfigurationStruct;
harmonicsIdentificationConfigurationStruct = ...
    pdcDataObject.harmonicsIdentificationConfigurationStruct;
discontinuityConfigurationStruct = ...
    pdcDataObject.discontinuityConfigurationStruct;
gapFillConfigurationStruct = pdcDataObject.gapFillConfigurationStruct;
ancillaryDesignMatrixConfigurationStruct = ...
    pdcDataObject.ancillaryDesignMatrixConfigurationStruct;

raDec2PixModel = pdcDataObject.raDec2PixModel;

% Compute the median cadence duration in minutes and append to the gap fill
% parameters.
startTimestamps = startTimestamps(~cadenceGapIndicators);
endTimestamps = endTimestamps(~cadenceGapIndicators);
cadenceDurations = endTimestamps - startTimestamps;

gapFillConfigurationStruct.cadenceDurationInMinutes = ...
    median(cadenceDurations) * get_unit_conversion('day2min');
pdcDataObject.gapFillConfigurationStruct = gapFillConfigurationStruct;

% Instantiate a raDec2Pix object.
raDec2PixObject = raDec2PixClass(raDec2PixModel, 'one-based');
    
% Populate the coarse PDC configuration structure.
coarsePdcConfigurationStruct.ccdModule = ccdModule;
coarsePdcConfigurationStruct.ccdOutput = ccdOutput;
coarsePdcConfigurationStruct.cadenceTimes = cadenceTimes;
coarsePdcConfigurationStruct.pdcModuleParameters = pdcModuleParameters;
coarsePdcConfigurationStruct.raDec2PixObject = raDec2PixObject;
coarsePdcConfigurationStruct.gapFillConfigurationStruct = ...
    gapFillConfigurationStruct;
coarsePdcConfigurationStruct.harmonicsIdentificationConfigurationStruct = ...
    harmonicsIdentificationConfigurationStruct;

% Initialize the alerts.
alerts = [];

% Print start message.
nTargets = length(pdcDataObject.targetDataStruct);
display(['presearch_data_conditioning: starting PDC for ', num2str(nTargets), ...
    ' targets on module output ', num2str(ccdModule), '/', num2str(ccdOutput), '!']);

% Ensure that gap-worthy anomalies are gapped. Ignore any LC exclude
% cadences if there are no primary exclude cadences for the unit of work.
% Save without '-append' to initialize the state file.
if ~any(dataAnomalyIndicators.excludeIndicators)
    lcDataAnomalyIndicators.excludeIndicators = ...
        false(size(lcDataAnomalyIndicators.excludeIndicators));
end % if
[pdcDataObject] = pdc_gap_data_anomalies(pdcDataObject, ...
    dataAnomalyIndicators, lcDataAnomalyIndicators);
targetDataStruct = pdcDataObject.targetDataStruct;
intelligent_save(PDC_STATE_FILENAME, 'dataAnomalyIndicators', 'lcDataAnomalyIndicators');

% Condition the ancillary data.
tic
display('presearch_data_conditioning: synchronizing ancillary data...');
[conditionedAncillaryDataStruct, alerts] = ...
    synchronize_pdc_ancillary_data(pdcDataObject, alerts);
intelligent_save(CONDITIONED_ANCILLARY_FILENAME, 'conditionedAncillaryDataStruct');
duration = toc;
display(['Ancillary data synchronized: ' num2str(duration) ...
    ' seconds = '  num2str(duration/60) ' minutes']);

% Identify unknown discontinuities in the raw flux time series for all
% targets.
tic
display('presearch_data_conditioning: identify and correct unexplained flux discontinuities...');
[discontinuities, alerts, events] = ...
    identify_flux_discontinuities_for_all_targets(targetDataStruct, ...
    discontinuityConfigurationStruct, gapFillConfigurationStruct, ...
    dataAnomalyIndicators, alerts, []);
[targetDataStruct, uncorrectedDiscontinuityTargetList, ...
    discontinuityIndices, alerts] = ...
    correct_time_series_discontinuities_for_all_targets(targetDataStruct, ...
    discontinuities, discontinuityConfigurationStruct, ...
    gapFillConfigurationStruct, dataAnomalyIndicators, alerts, events);
save(PDC_STATE_FILENAME, 'discontinuities', 'uncorrectedDiscontinuityTargetList', ...
    '-append');
duration = toc;
display(['Discontinuities identified and corrected: ' num2str(duration) ...
    ' seconds = '  num2str(duration/60) ' minutes']);

% Identify phase shifting harmonics in each variable target flux time
% series.
t0 = clock;
display('presearch_data_conditioning: identifying phase shifting harmonics...');
[harmonicTimeSeries0, variableTargetDataStruct, initialVariableTargetList] = ...
    pdc_identify_and_remove_phase_shifting_harmonics_from_all_targets( ...
    targetDataStruct, coarsePdcConfigurationStruct, cadenceType, []);                                                                          %#ok<NASGU>
duration = etime(clock, t0);
display(['Harmonic content identified: ' num2str(duration) ...
    ' seconds = '  num2str(duration/60) ' minutes']);

% Correct systematic errors by cotrending against the conditioned ancillary
% data. Repeat for the variable targets with harmonics removed. Make sure
% that the variable targets identified initially are in fact variable after
% cotrending. Reject the cotrended result for variable targets if the short
% time scale power ratio is over the acceptable limit. In these cases, use
% the coarsely detrended result.
tic
display('presearch_data_conditioning: correcting systematic errors...');

[intermediateFluxTimeSeries, fittedFluxTimeSeries, ...
    saturationSegmentsStruct, shortTimeScalePowerRatio] = ...
    correct_systematic_error(conditionedAncillaryDataStruct, ...
    targetDataStruct, ancillaryDesignMatrixConfigurationStruct, ...
    pdcModuleParameters, saturationSegmentConfigurationStruct, ...
    gapFillConfigurationStruct, RESTORE_MEAN_FLAG, dataAnomalyIndicators);                 %#ok<ASGLU,NASGU>

if ~isempty(variableTargetDataStruct)
    [variableFluxTimeSeries, fittedFluxTimeSeries, ...
        variableSaturationSegmentsStruct, variableShortTimeScalePowerRatio] = ...
        correct_systematic_error(conditionedAncillaryDataStruct, ...
        variableTargetDataStruct, ancillaryDesignMatrixConfigurationStruct, ...
        pdcModuleParameters, saturationSegmentConfigurationStruct, ...
        gapFillConfigurationStruct, RESTORE_MEAN_FLAG, dataAnomalyIndicators);             %#ok<ASGLU,NASGU>
else
    variableFluxTimeSeries = intermediateFluxTimeSeries([]);
    variableSaturationSegmentsStruct = saturationSegmentsStruct([]);
    variableShortTimeScalePowerRatio = [];
end % if / else

[intermediateFluxTimeSeries, harmonicTimeSeries1, variableTargetList, ...
    badCotrendTargetList, harmonicsFittedTargetList, harmonicsRestoredTargetList, ...
    shortTimeScalePowerRatio, saturationSegmentsStruct, alerts] = ...
    update_results_for_variable_targets(targetDataStruct, ...
    intermediateFluxTimeSeries, variableFluxTimeSeries, ...
    initialVariableTargetList, harmonicTimeSeries0, ...
    shortTimeScalePowerRatio, variableShortTimeScalePowerRatio, ...
    saturationSegmentsStruct, variableSaturationSegmentsStruct, ...
    pdcModuleParameters, gapFillConfigurationStruct, cadenceType, alerts);                 %#ok<ASGLU>
save(PDC_STATE_FILENAME, 'harmonicTimeSeries0', 'harmonicTimeSeries1', ...
    'initialVariableTargetList', 'variableTargetList', 'badCotrendTargetList', ...
    'harmonicsFittedTargetList', 'harmonicsRestoredTargetList', ...
    'shortTimeScalePowerRatio', 'saturationSegmentsStruct', '-append');
clear fittedFluxTimeSeries variableFluxTimeSeries
clear saturationSegmentsStruct variableSaturationSegmentsStruct
clear shortTimeScalePowerRatio variableShortTimeScalePowerRatio
duration = toc;
display(['Systematic errors corrected: ' num2str(duration) ...
    ' seconds = '  num2str(duration/60) ' minutes']);

% Correct for excess crowding and flux fraction in aperture if
% normalization is enabled.
crowdingMetricArray = [targetDataStruct.crowdingMetric]';
fluxFractionArray = [targetDataStruct.fluxFractionInAperture]';

if normalizationEnabled
    tic
    display('presearch_data_conditioning: rescaling for crowding and flux fraction...');
    [intermediateFluxTimeSeries, harmonicTimeSeries, alerts] = ...
        pdc_correct_flux_fraction_and_crowding_metric(intermediateFluxTimeSeries, ...
        harmonicTimeSeries1, crowdingMetricArray,fluxFractionArray, alerts);
    duration = toc;
    display(['Flux rescaled: ' num2str(duration) ...
        ' seconds = '  num2str(duration/60) ' minutes']);
else
    harmonicTimeSeries = harmonicTimeSeries1;
end % if / else
save(PDC_STATE_FILENAME, 'harmonicTimeSeries', '-append');

% Plot the empirical target to target correlation for the systematic error
% corrected and flux normalized time series.
plot_empirical_correlation(intermediateFluxTimeSeries);

% Identify and remove outliers. (i.e. set to 0 and gap)
tic
display('presearch_data_conditioning: identifying and removing outliers...');
[outliers, intermediateFluxTimeSeries, events] = ...
    pdc_detect_outliers(intermediateFluxTimeSeries, pdcModuleParameters, ...
    gapFillConfigurationStruct);
duration = toc;
display(['Outliers detected and removed: ' num2str(duration) ...
    ' seconds = '  num2str(duration/60) ' minutes']);

% Fill data gaps.
tic
display('presearch_data_conditioning: filling gaps...');
[correctedFluxTimeSeries] = ...
    fill_gaps_for_all_targets(intermediateFluxTimeSeries, ...
    pdcModuleParameters, gapFillConfigurationStruct, events);
duration = toc;
display(['Gaps filled: ' num2str(duration) ...
    ' seconds = '  num2str(duration/60) ' minutes']);

clear intermediateFluxTimeSeries

%----------------------------------------------------------------------------------------------------
%% Generate flags for all targets whether to exclude them based on their labels
pdcDataObject.targetDataStruct = pdc_generate_target_exclusion_list( pdcDataObject.targetDataStruct , pdcDataObject.pdcModuleParameters.excludeTargetLabels );
for i=1:nTargets
    correctedFluxTimeSeries(i).excludeBasedOnLabels = pdcDataObject.targetDataStruct(i).excludeBasedOnLabels;
end

% Goodness Metric

doSavePlots = false;
% Note: data in gaps is ignored for goodness metric calculation, so no need to fill raw data gaps
% stellar variability calculation needs to kic data so move it into the corrected data struct
for iTarget = 1 : length(correctedFluxTimeSeries)
    correctedFluxTimeSeries(iTarget).kic = pdcDataObject.targetDataStruct(iTarget).kic;
end
% When calculating Goodness also compute EP Goodness (it's slower than the other components and is optional)
doCalcEpGoodness = true;
goodnessStruct = pdc_goodness_metric (pdcDataObject.targetDataStruct, ...
                                      correctedFluxTimeSeries, cadenceTimes, ...
                                      pdcDataObject.pdcModuleParameters, ...
                                      pdcDataObject.goodnessMetricConfigurationStruct, doSavePlots, 'LS ', doCalcEpGoodness);

%----------------------------------------------------------------------------------------------------

% Populate the output structure after first converting PDC outputs to 0-base.
[pdcResultsStruct] = ...
    populate_pdc_results_structure(pdcDataObject, ...
    correctedFluxTimeSeries, harmonicTimeSeries, outliers, ...
    discontinuityIndices, uncorrectedDiscontinuityTargetList, ...
    initialVariableTargetList, variableTargetList, harmonicsFittedTargetList, ...
    harmonicsRestoredTargetList, badCotrendTargetList, goodnessStruct, alerts);

% No PDC-blobs for this version of PDC so save empty sets
pdcResultsStruct.pdcBlobFileName = [];
pdcResultsStruct.cbvBlobFileName = [];

% Identify corrected flux time series with fluctuations larger than
% expected based on statistics only. Save these to a matlab file.
[rawFluxRmsUncertainties, correctedFluxSigma, fluxRatio, isValidTarget, ...
    keplerMags] = presearch_transit_identification(pdcDataObject, ...
    pdcResultsStruct);                                                                     %#ok<NASGU,ASGLU>
save(PDC_STATE_FILENAME, 'rawFluxRmsUncertainties', 'correctedFluxSigma', ...
    'fluxRatio', 'isValidTarget', 'keplerMags', '-append');

% Return.
return
