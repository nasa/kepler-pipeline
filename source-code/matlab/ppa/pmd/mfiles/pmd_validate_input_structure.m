function pmd_validate_input_structure(pmdInputStruct)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function  pmd_validate_input_structure(pmdInputStruct)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% This function first checks for the presence of expected fields in the input
% structure, then checks whether each parameter is within the appropriate
% range.
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% INPUT:  A data structure 'pmdInputStruct' with the following fields:
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%   Top level
%
%     pmdInputStruct contains the following fields:
%
%                                  ccdModule: [int]  CCD module number
%                                  ccdOutput: [int]  CCD output number
%                             fcConstants: [struct]  focal plane constants
%              spacecraftConfigMaps: [struct array]  one or more spacecraft config maps
%                          raDec2PixModel: [struct]  ra-dec to pixel model
%                            cadenceTimes: [struct]  cadence times and gap indicators
%                     pmdModuleParameters: [struct]  module parameters for PMD
%                             inputTsData: [struct]  input time series data
%                        cdppTsData: [struct array]  CDPP time series data
%                         badPixels: [struct array]  bad pixels data
%          ancillaryEngineeringParameters: [struct]  module parameters for ancillary engineering data
%             ancillaryPipelineParameters: [struct]  module parameters for ancillary pipeline data
%          ancillaryEngineeringData: [struct array]  ancillary engineering data
%             ancillaryPipelineData: [struct array]  ancillary pipeline data 
%             backgroundPolyStruct: [struct series]  background polynomials structures
%                 motionPolyStruct: [struct series]  motion polynomials structures 
%
%--------------------------------------------------------------------------
%   Second level
%
%     cadenceTimes is a struct with the following fields:
%
%          startTimestamps: [double array]  cadence start times, MJD
%            midTimestamps: [double array]  cadence mid times, MJD
%            endTimestamps: [double array]  cadence end times, MJD
%           gapIndicators: [logical array]  true if cadence is unavailable
%          requantEnabled: [logical array]  true if requantization was enabled
%
%--------------------------------------------------------------------------
%   Second level
%
%     pmdModuleParameters is a struct with the following fields:
%
%                                              alertTime: [float]  number of days at the end of valid time duration for alert generation
%                                            horizonTime: [float]  number of days for trend prediction
%                                           trendFitTime: [float]  number of days at the end of valid time duration for trend fit
%                              initialAverageSampleCount: [float]  number of samples for inititial average
%                                 minTrendFitSampleCount: [float]  minimum number of samples for trend fit
%                              blackLevelSmoothingFactor: [float]  smoothing  factor of black level  metric
%                              blackLevelFixedLowerBound: [float]  fixed lower bound of black level  metric
%                              blackLevelFixedUpperBound: [float]  fixed upper bound of black level  metric
%                              blackLevelAdaptiveXFactor: [float]  adaptive bound X factor of black level  metric
%                              smearLevelSmoothingFactor: [float]  smoothing  factor of smear level  metric
%                              smearLevelFixedLowerBound: [float]  fixed lower bound of smear level  metric
%                              smearLevelFixedUpperBound: [float]  fixed upper bound of smear level  metric
%                              smearLevelAdaptiveXFactor: [float]  adaptive bound X factor of smear level  metric
%                             darkCurrentSmoothingFactor: [float]  smoothing  factor of dark current metric
%                             darkCurrentFixedLowerBound: [float]  fixed lower bound of dark current metric
%                             darkCurrentFixedUpperBound: [float]  fixed upper bound of dark current metric
%                             darkCurrentAdaptiveXFactor: [float]  adaptive bound X factor of dark current metric
%                               twoDBlackSmoothingFactor: [float]  smoothing  factor of two-D black    target metric
%                               twoDBlackFixedLowerBound: [float]  fixed lower bound of two-D black    target metric
%                               twoDBlackFixedUpperBound: [float]  fixed upper bound of two-D black    target metric
%                               twoDBlackAdaptiveXFactor: [float]  adaptive bound X factor of two-D black    target metric
%                           ldeUndershootSmoothingFactor: [float]  smoothing  factor of LDE undershoot target metric
%                           ldeUndershootFixedLowerBound: [float]  fixed lower bound of LDE undershoot target metric
%                           ldeUndershootFixedUpperBound: [float]  fixed upper bound of LDE undershoot target metric
%                           ldeUndershootAdaptiveXFactor: [float]  adaptive bound X factor of LDE undershoot target metric
%                             compressionSmoothingFactor: [float]  smoothing  factor of theoretical and achieved compression efficiency metrics
%                             compressionFixedLowerBound: [float]  fixed lower bound of theoretical and achieved compression efficiency metrics
%                             compressionFixedUpperBound: [float]  fixed upper bound of theoretical and achieved compression efficiency metrics
%                             compressionAdaptiveXFactor: [float]  adaptive bound X factor of theoretical and achieved compression efficiency metrics
%                   blackCosmicRayHitRateSmoothingFactor: [float]  smoothing  factor of cosmic ray hit rate        of black         pixels
%                   blackCosmicRayHitRateFixedLowerBound: [float]  fixed lower bound of cosmic ray hit rate        of black         pixels
%                   blackCosmicRayHitRateFixedUpperBound: [float]  fixed upper bound of cosmic ray hit rate        of black         pixels
%                   blackCosmicRayHitRateAdaptiveXFactor: [float]  adaptive bound X factor of cosmic ray hit rate        of black         pixels
%                blackCosmicRayMeanEnergySmoothingFactor: [float]  smoothing  factor of cosmic ray mean energy     of black         pixels
%                blackCosmicRayMeanEnergyFixedLowerBound: [float]  fixed lower bound of cosmic ray mean energy     of black         pixels
%                blackCosmicRayMeanEnergyFixedUpperBound: [float]  fixed upper bound of cosmic ray mean energy     of black         pixels
%                blackCosmicRayMeanEnergyAdaptiveXFactor: [float]  adaptive bound X factor of cosmic ray mean energy     of black         pixels
%            blackCosmicRayEnergyVarianceSmoothingFactor: [float]  smoothing  factor of cosmic ray energy variance of black         pixels
%            blackCosmicRayEnergyVarianceFixedLowerBound: [float]  fixed lower bound of cosmic ray energy variance of black         pixels
%            blackCosmicRayEnergyVarianceFixedUpperBound: [float]  fixed upper bound of cosmic ray energy variance of black         pixels
%            blackCosmicRayEnergyVarianceAdaptiveXFactor: [float]  adaptive bound X factor of cosmic ray energy variance of black         pixels
%            blackCosmicRayEnergySkewnessSmoothingFactor: [float]  smoothing  factor of cosmic ray energy skewness of black         pixels
%            blackCosmicRayEnergySkewnessFixedLowerBound: [float]  fixed lower bound of cosmic ray energy skewness of black         pixels
%            blackCosmicRayEnergySkewnessFixedUpperBound: [float]  fixed upper bound of cosmic ray energy skewness of black         pixels
%            blackCosmicRayEnergySkewnessAdaptiveXFactor: [float]  adaptive bound X factor of cosmic ray energy skewness of black         pixels
%            blackCosmicRayEnergyKurtosisSmoothingFactor: [float]  smoothing  factor of cosmic ray energy kurtosis of black         pixels
%            blackCosmicRayEnergyKurtosisFixedLowerBound: [float]  fixed lower bound of cosmic ray energy kurtosis of black         pixels
%            blackCosmicRayEnergyKurtosisFixedUpperBound: [float]  fixed upper bound of cosmic ray energy kurtosis of black         pixels
%            blackCosmicRayEnergyKurtosisAdaptiveXFactor: [float]  adaptive bound X factor of cosmic ray energy kurtosis of black         pixels
%             maskedSmearCosmicRayHitRateSmoothingFactor: [float]  smoothing  factor of cosmic ray hit rate        of masked  smear pixels
%             maskedSmearCosmicRayHitRateFixedLowerBound: [float]  fixed lower bound of cosmic ray hit rate        of masked  smear pixels
%             maskedSmearCosmicRayHitRateFixedUpperBound: [float]  fixed upper bound of cosmic ray hit rate        of masked  smear pixels
%             maskedSmearCosmicRayHitRateAdaptiveXFactor: [float]  adaptive bound X factor of cosmic ray hit rate        of masked  smear pixels
%          maskedSmearCosmicRayMeanEnergySmoothingFactor: [float]  smoothing  factor of cosmic ray mean energy     of masked  smear pixels
%          maskedSmearCosmicRayMeanEnergyFixedLowerBound: [float]  fixed lower bound of cosmic ray mean energy     of masked  smear pixels
%          maskedSmearCosmicRayMeanEnergyFixedUpperBound: [float]  fixed upper bound of cosmic ray mean energy     of masked  smear pixels
%          maskedSmearCosmicRayMeanEnergyAdaptiveXFactor: [float]  adaptive bound X factor of cosmic ray mean energy     of masked  smear pixels
%      maskedSmearCosmicRayEnergyVarianceSmoothingFactor: [float]  smoothing  factor of cosmic ray energy variance of masked  smear pixels
%      maskedSmearCosmicRayEnergyVarianceFixedLowerBound: [float]  fixed lower bound of cosmic ray energy variance of masked  smear pixels
%      maskedSmearCosmicRayEnergyVarianceFixedUpperBound: [float]  fixed upper bound of cosmic ray energy variance of masked  smear pixels
%      maskedSmearCosmicRayEnergyVarianceAdaptiveXFactor: [float]  adaptive bound X factor of cosmic ray energy variance of masked  smear pixels
%      maskedSmearCosmicRayEnergySkewnessSmoothingFactor: [float]  smoothing  factor of cosmic ray energy skewness of masked  smear pixels
%      maskedSmearCosmicRayEnergySkewnessFixedLowerBound: [float]  fixed lower bound of cosmic ray energy skewness of masked  smear pixels
%      maskedSmearCosmicRayEnergySkewnessFixedUpperBound: [float]  fixed upper bound of cosmic ray energy skewness of masked  smear pixels
%      maskedSmearCosmicRayEnergySkewnessAdaptiveXFactor: [float]  adaptive bound X factor of cosmic ray energy skewness of masked  smear pixels
%      maskedSmearCosmicRayEnergyKurtosisSmoothingFactor: [float]  smoothing  factor of cosmic ray energy kurtosis of masked  smear pixels
%      maskedSmearCosmicRayEnergyKurtosisFixedLowerBound: [float]  fixed lower bound of cosmic ray energy kurtosis of masked  smear pixels
%      maskedSmearCosmicRayEnergyKurtosisFixedUpperBound: [float]  fixed upper bound of cosmic ray energy kurtosis of masked  smear pixels
%      maskedSmearCosmicRayEnergyKurtosisAdaptiveXFactor: [float]  adaptive bound X factor of cosmic ray energy kurtosis of masked  smear pixels
%            virtualSmearCosmicRayHitRateSmoothingFactor: [float]  smoothing  factor of cosmic ray hit rate        of virtual smear pixels
%            virtualSmearCosmicRayHitRateFixedLowerBound: [float]  fixed lower bound of cosmic ray hit rate        of virtual smear pixels
%            virtualSmearCosmicRayHitRateFixedUpperBound: [float]  fixed upper bound of cosmic ray hit rate        of virtual smear pixels
%            virtualSmearCosmicRayHitRateAdaptiveXFactor: [float]  adaptive bound X factor of cosmic ray hit rate        of virtual smear pixels
%         virtualSmearCosmicRayMeanEnergySmoothingFactor: [float]  smoothing  factor of cosmic ray mean energy     of virtual smear pixels
%         virtualSmearCosmicRayMeanEnergyFixedLowerBound: [float]  fixed lower bound of cosmic ray mean energy     of virtual smear pixels
%         virtualSmearCosmicRayMeanEnergyFixedUpperBound: [float]  fixed upper bound of cosmic ray mean energy     of virtual smear pixels
%         virtualSmearCosmicRayMeanEnergyAdaptiveXFactor: [float]  adaptive bound X factor of cosmic ray mean energy     of virtual smear pixels
%     virtualSmearCosmicRayEnergyVarianceSmoothingFactor: [float]  smoothing  factor of cosmic ray energy variance of virtual smear pixels
%     virtualSmearCosmicRayEnergyVarianceFixedLowerBound: [float]  fixed lower bound of cosmic ray energy variance of virtual smear pixels
%     virtualSmearCosmicRayEnergyVarianceFixedUpperBound: [float]  fixed upper bound of cosmic ray energy variance of virtual smear pixels
%     virtualSmearCosmicRayEnergyVarianceAdaptiveXFactor: [float]  adaptive bound X factor of cosmic ray energy variance of virtual smear pixels
%     virtualSmearCosmicRayEnergySkewnessSmoothingFactor: [float]  smoothing  factor of cosmic ray energy skewness of virtual smear pixels
%     virtualSmearCosmicRayEnergySkewnessFixedLowerBound: [float]  fixed lower bound of cosmic ray energy skewness of virtual smear pixels
%     virtualSmearCosmicRayEnergySkewnessFixedUpperBound: [float]  fixed upper bound of cosmic ray energy skewness of virtual smear pixels
%     virtualSmearCosmicRayEnergySkewnessAdaptiveXFactor: [float]  adaptive bound X factor of cosmic ray energy skewness of virtual smear pixels
%     virtualSmearCosmicRayEnergyKurtosisSmoothingFactor: [float]  smoothing  factor of cosmic ray energy kurtosis of virtual smear pixels
%     virtualSmearCosmicRayEnergyKurtosisFixedLowerBound: [float]  fixed lower bound of cosmic ray energy kurtosis of virtual smear pixels
%     virtualSmearCosmicRayEnergyKurtosisFixedUpperBound: [float]  fixed upper bound of cosmic ray energy kurtosis of virtual smear pixels
%     virtualSmearCosmicRayEnergyKurtosisAdaptiveXFactor: [float]  adaptive bound X factor of cosmic ray energy kurtosis of virtual smear pixels
%              targetStarCosmicRayHitRateSmoothingFactor: [float]  smoothing  factor of cosmic ray hit rate        of target star   pixels
%              targetStarCosmicRayHitRateFixedLowerBound: [float]  fixed lower bound of cosmic ray hit rate        of target star   pixels
%              targetStarCosmicRayHitRateFixedUpperBound: [float]  fixed upper bound of cosmic ray hit rate        of target star   pixels
%              targetStarCosmicRayHitRateAdaptiveXFactor: [float]  adaptive bound X factor of cosmic ray hit rate        of target star   pixels
%           targetStarCosmicRayMeanEnergySmoothingFactor: [float]  smoothing  factor of cosmic ray mean energy     of target star   pixels
%           targetStarCosmicRayMeanEnergyFixedLowerBound: [float]  fixed lower bound of cosmic ray mean energy     of target star   pixels
%           targetStarCosmicRayMeanEnergyFixedUpperBound: [float]  fixed upper bound of cosmic ray mean energy     of target star   pixels
%           targetStarCosmicRayMeanEnergyAdaptiveXFactor: [float]  adaptive bound X factor of cosmic ray mean energy     of target star   pixels
%       targetStarCosmicRayEnergyVarianceSmoothingFactor: [float]  smoothing  factor of cosmic ray energy variance of target star   pixels
%       targetStarCosmicRayEnergyVarianceFixedLowerBound: [float]  fixed lower bound of cosmic ray energy variance of target star   pixels
%       targetStarCosmicRayEnergyVarianceFixedUpperBound: [float]  fixed upper bound of cosmic ray energy variance of target star   pixels
%       targetStarCosmicRayEnergyVarianceAdaptiveXFactor: [float]  adaptive bound X factor of cosmic ray energy variance of target star   pixels
%       targetStarCosmicRayEnergySkewnessSmoothingFactor: [float]  smoothing  factor of cosmic ray energy skewness of target star   pixels
%       targetStarCosmicRayEnergySkewnessFixedLowerBound: [float]  fixed lower bound of cosmic ray energy skewness of target star   pixels
%       targetStarCosmicRayEnergySkewnessFixedUpperBound: [float]  fixed upper bound of cosmic ray energy skewness of target star   pixels
%       targetStarCosmicRayEnergySkewnessAdaptiveXFactor: [float]  adaptive bound X factor of cosmic ray energy skewness of target star   pixels
%       targetStarCosmicRayEnergyKurtosisSmoothingFactor: [float]  smoothing  factor of cosmic ray energy kurtosis of target star   pixels
%       targetStarCosmicRayEnergyKurtosisFixedLowerBound: [float]  fixed lower bound of cosmic ray energy kurtosis of target star   pixels
%       targetStarCosmicRayEnergyKurtosisFixedUpperBound: [float]  fixed upper bound of cosmic ray energy kurtosis of target star   pixels
%       targetStarCosmicRayEnergyKurtosisAdaptiveXFactor: [float]  adaptive bound X factor of cosmic ray energy kurtosis of target star   pixels
%              backgroundCosmicRayHitRateSmoothingFactor: [float]  smoothing  factor of cosmic ray hit rate        of background    pixels
%              backgroundCosmicRayHitRateFixedLowerBound: [float]  fixed lower bound of cosmic ray hit rate        of background    pixels
%              backgroundCosmicRayHitRateFixedUpperBound: [float]  fixed upper bound of cosmic ray hit rate        of background    pixels
%              backgroundCosmicRayHitRateAdaptiveXFactor: [float]  adaptive bound X factor of cosmic ray hit rate        of background    pixels
%           backgroundCosmicRayMeanEnergySmoothingFactor: [float]  smoothing  factor of cosmic ray mean energy     of background    pixels
%           backgroundCosmicRayMeanEnergyFixedLowerBound: [float]  fixed lower bound of cosmic ray mean energy     of background    pixels
%           backgroundCosmicRayMeanEnergyFixedUpperBound: [float]  fixed upper bound of cosmic ray mean energy     of background    pixels
%           backgroundCosmicRayMeanEnergyAdaptiveXFactor: [float]  adaptive bound X factor of cosmic ray mean energy     of background    pixels
%       backgroundCosmicRayEnergyVarianceSmoothingFactor: [float]  smoothing  factor of cosmic ray energy variance of background    pixels
%       backgroundCosmicRayEnergyVarianceFixedLowerBound: [float]  fixed lower bound of cosmic ray energy variance of background    pixels
%       backgroundCosmicRayEnergyVarianceFixedUpperBound: [float]  fixed upper bound of cosmic ray energy variance of background    pixels
%       backgroundCosmicRayEnergyVarianceAdaptiveXFactor: [float]  adaptive bound X factor of cosmic ray energy variance of background    pixels
%       backgroundCosmicRayEnergySkewnessSmoothingFactor: [float]  smoothing  factor of cosmic ray energy skewness of background    pixels
%       backgroundCosmicRayEnergySkewnessFixedLowerBound: [float]  fixed lower bound of cosmic ray energy skewness of background    pixels
%       backgroundCosmicRayEnergySkewnessFixedUpperBound: [float]  fixed upper bound of cosmic ray energy skewness of background    pixels
%       backgroundCosmicRayEnergySkewnessAdaptiveXFactor: [float]  adaptive bound X factor of cosmic ray energy skewness of background    pixels
%       backgroundCosmicRayEnergyKurtosisSmoothingFactor: [float]  smoothing  factor of cosmic ray energy kurtosis of background    pixels
%       backgroundCosmicRayEnergyKurtosisFixedLowerBound: [float]  fixed lower bound of cosmic ray energy kurtosis of background    pixels
%       backgroundCosmicRayEnergyKurtosisFixedUpperBound: [float]  fixed upper bound of cosmic ray energy kurtosis of background    pixels
%       backgroundCosmicRayEnergyKurtosisAdaptiveXFactor: [float]  adaptive bound X factor of cosmic ray energy kurtosis of background    pixels
%                              brightnessSmoothingFactor: [float]  smoothing  factor of brightness            metric
%                              brightnessFixedLowerBound: [float]  fixed lower bound of brightness            metric
%                              brightnessFixedUpperBound: [float]  fixed upper bound of brightness            metric
%                              brightnessAdaptiveXFactor: [float]  adaptive bound X factor of brightness      metric
%                         encircledEnergySmoothingFactor: [float]  smoothing  factor of encircled energy      metric
%                         encircledEnergyFixedLowerBound: [float]  fixed lower bound of encircled energy      metric
%                         encircledEnergyFixedUpperBound: [float]  fixed upper bound of encircled energy      metric
%                         encircledEnergyAdaptiveXFactor: [float]  adaptive bound X factor of encircled energy metric
%                         backgroundLevelSmoothingFactor: [float]  smoothing  factor of background level      metric
%                         backgroundLevelFixedLowerBound: [float]  fixed lower bound of background level      metric
%                         backgroundLevelFixedUpperBound: [float]  fixed upper bound of background level      metric
%                         backgroundLevelAdaptiveXFactor: [float]  adaptive bound X factor of background level metric
%                        centroidsMeanRowSmoothingFactor: [float]  smoothing  factor of centroids mean row    metric
%                        centroidsMeanRowFixedLowerBound: [float]  fixed lower bound of centroids mean row    metric
%                        centroidsMeanRowFixedUpperBound: [float]  fixed upper bound of centroids mean row    metric
%                        centroidsMeanRowAdaptiveXFactor: [float]  adaptive bound X factor of centroids mean row metric
%                     centroidsMeanColumnSmoothingFactor: [float]  smoothing  factor of centroids mean column metric
%                     centroidsMeanColumnFixedLowerBound: [float]  fixed lower bound of centroids mean column metric
%                     centroidsMeanColumnFixedUpperBound: [float]  fixed upper bound of centroids mean column metric
%                     centroidsMeanColumnAdaptiveXFactor: [float]  adaptive bound X factor of centroids mean column metric
%                              plateScaleSmoothingFactor: [float]  smoothing  factor of plate scale           metric
%                              plateScaleFixedLowerBound: [float]  fixed lower bound of plate scale           metric
%                              plateScaleFixedUpperBound: [float]  fixed upper bound of plate scale           metric
%                              plateScaleAdaptiveXFactor: [float]  adaptive bound X factor of plate scale     metric
%                            cdppMeasuredSmoothingFactor: [float]  smoothing  factor of CDPP measured         metric
%                            cdppMeasuredFixedLowerBound: [float]  fixed lower bound of CDPP measured         metric
%                            cdppMeasuredFixedUpperBound: [float]  fixed upper bound of CDPP measured         metric
%                            cdppMeasuredAdaptiveXFactor: [float]  adaptive bound X factor of CDPP measured   metric
%                            cdppExpectedSmoothingFactor: [float]  smoothing  factor of CDPP expected         metric
%                            cdppExpectedFixedLowerBound: [float]  fixed lower bound of CDPP expected         metric
%                            cdppExpectedFixedUpperBound: [float]  fixed upper bound of CDPP expected         metric
%                            cdppExpectedAdaptiveXFactor: [float]  adaptive bound X factor of CDPP expected   metric
%                               cdppRatioSmoothingFactor: [float]  smoothing  factor of CDPP ratio            metric
%                               cdppRatioFixedLowerBound: [float]  fixed lower bound of CDPP ratio            metric
%                               cdppRatioFixedUpperBound: [float]  fixed upper bound of CDPP ratio            metric
%                               cdppRatioAdaptiveXFactor: [float]  adaptive bound X factor of CDPP ratio      metric
%                                               debugLevel: [int]  debug level of PMD
%                                      plottingEnabled: [logical]  flag indicating plot is enabled
%
%--------------------------------------------------------------------------
%   Second level
%
%     inputTsData is a struct with the following fields:
%
%                           blackLevel: [struct]  black level      metric time series 
%                           smearLevel: [struct]  smear level      metric time series 
%                          darkCurrent: [struct]  dark current     metric time series 
%                           brightness: [struct]  brightness       metric time series 
%                      encircledEnergy: [struct]  encircled energy metric time series 
%                      twoDBlack: [struct array]  two-D black    targets metric time series 
%                  ldeUndershoot: [struct array]  LDE undershoot targets metric time series 
%     theoreticalCompressionEfficiency: [struct]  theoretical compression efficiency metric
%        achievedCompressionEfficiency: [struct]  achieved    compression efficiency metric
%                blackCosmicRayMetrics: [struct]  cosmic ray metrics of black         pixels
%          maskedSmearCosmicRayMetrics: [struct]  cosmic ray metrics of masked  smear pixels
%         virtualSmearCosmicRayMetrics: [struct]  cosmic ray metrics of virtual smear pixels
%           targetStarCosmicRayMetrics: [struct]  cosmic ray metrics of target star   pixels
%           backgroundCosmicRayMetrics: [struct]  cosmic ray metrics of background    pixels
%
%   Third level
%
%     blackLevel
%     smearLevel
%     darkCurrent 
%     brightness
%     encircledEnergy are structs with the following fields:
%
%                          values: [float array]  values         of metric time series 
%                 gapIndicators: [logical array]  gap indicators of metric time series 
%                   uncertainties: [float array]  uncertainties  of metric time series 
% 
%   Third level
%
%     twoDBlack
%     ldeUndershoot are arrays of structs with the following fields:
%
%                          values: [float array]  values         of metric time series 
%                 gapIndicators: [logical array]  gap indicators of metric time series 
%                   uncertainties: [float array]  uncertainties  of metric time series 
%                                keplerId: [int]  Kepler ID
%
%   Third level
%
%     theoreticalCompressionEfficiency
%     achievedCompressionEfficiency     are structs with the following fields:
%
%                          values: [float array]  values         of metric time series 
%                 gapIndicators: [logical array]  gap indicators of metric time series 
%
%   Third level
%
%     blackCosmicRayMetrics
%     maskedSmearCosmicRayMetrics
%     virtualSmearCosmicRayMetrics
%     targetStarCosmicRayMetrics
%     backgroundCosmicRayMetrics   are structs with the following fields:
%
%                          empty: [logical]  flag indicating the cosmic ray metrics are empty
%                         hitRate: [struct]  cosmic ray hit rate
%                      meanEnergy: [struct]  cosmic ray mean energy
%                  energyVariance: [struct]  cosmic ray energy variance
%                  energySkewness: [struct]  cosmic ray energy skewness
%                  energyKurtosis: [struct]  cosmic ray energy kurtosis
%
%   Fourth level
%
%     hitRate
%     meanEnergy
%     energyVariance
%     energySkewness
%     energyKurtosis are structs with the following fields:
%
%                          values: [float array]  values         of metric time series 
%                 gapIndicators: [logical array]  gap indicators of metric time series 
%
%--------------------------------------------------------------------------
%   Second level
%
%     cdppTsData is an array of structs with the following fields:
%
%                       keplerId: {int]  Kepler ID of target star
%                    keplerMag: [float]  Kepler magnitude of target star
%                cdpp3Hr: [float array]  CDPP  3 hour time series
%                cdpp6Hr: [float array]  CDPP  6 hour time series
%               cdpp12Hr: [float array]  CDPP 12 hour time series
%              fluxTimeSeries: [struct]  flux time series
%
%   Third level
%
%     fluxTimeSeries is a struct with the following fields:
%
%                          values: [float array]  values         of metric time series 
%                 gapIndicators: [logical array]  gap indicators of metric time series 
%                   uncertainties: [float array]  uncertainties  of metric time series 
%                     filledIndices: [int array]  filled indices (0-based) of metric time series 
%--------------------------------------------------------------------------
%   Second level
%
%     badPixels is an array of structs with the following fields:
%
%                            ccdRow: [int]  bad pixel row
%                         ccdColumn: [int]  bad pixel column
%                           type: [string]  bad pixel type
%                       startMjd: [double]  bad pixel start time, MJD
%                         endMjd: [double]  bad pixel stop time, MJD
%                           value: [float]  bad pixel value  [see KADN-26176]
%
%--------------------------------------------------------------------------
%   Second level
%
%     ancillaryEngineeringParameters is a struct with the following fields:
%
%                mnemonics: [string array]  mnemonic names
%                 modelOrders: [int array]  polynomial orders
%             interactions: [string array]  array of mnemonic pairs (comma separated) 
%        quantizationLevels: [float array]  ancillary engineering data step sizes
%    intrinsicUncertainties: [float array]  ancillary engineering data uncertainties
%
%--------------------------------------------------------------------------
%   Second level
%
%     ancillaryPipelineParameters is a struct with the following fields:
%
%                mnemonics: [string array]  mnemonic names
%                 modelOrders: [int array]  polynomial orders
%             interactions: [string array]  array of mnemonic pairs (comma separated)
%
%--------------------------------------------------------------------------
%   Second level
%
%     ancillaryEngineeringData is an array of structs (one per engineering
%     mnemonic) with the following fields:
%
%                       mnemonic: [string]  name of ancillary channel
%               timestamps: [double array]  engineering time tags, MJD
%                    values: [float array]  engineering data values
%
%--------------------------------------------------------------------------
%   Second level
%
%     ancillaryPipelineData is an array of structs (one per pipeline mnemonic) 
%     with the following fields:
%
%                       mnemonic: [string]  name of ancillary channel
%               timestamps: [double array]  pipeline time tags, MJD
%                    values: [float array]  pipeline data values
%             uncertainties: [float array]  pipeline data uncertainties
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


% If no input, generate an error.
if nargin == 0
    error('PMD:validatePmdInputStruct:EmptyInputStruct', ...
        'This function must be called with an input structure');
end


%______________________________________________________________________
% top level validation
% validate the top level fields in pmdInputStruct
%______________________________________________________________________

% pmdInputStruct fields
fieldsAndBounds = cell(16,4);

fieldsAndBounds( 1,:)  = { 'ccdModule';                      []; []; '[2:4, 6:20, 22:24]''' };
fieldsAndBounds( 2,:)  = { 'ccdOutput';                      []; []; '[1 2 3 4]''' };
fieldsAndBounds( 3,:)  = { 'cadenceTimes';                   []; []; [] };      % structure
fieldsAndBounds( 4,:)  = { 'pmdModuleParameters';            []; []; [] };      % structure
fieldsAndBounds( 5,:)  = { 'fcConstants';                    []; []; [] };      % structure, do not validate
fieldsAndBounds( 6,:)  = { 'spacecraftConfigMaps';           []; []; [] };      % structure array, do not validate
fieldsAndBounds( 7,:)  = { 'raDec2PixModel';                 []; []; [] };      % structure 
fieldsAndBounds( 8,:)  = { 'inputTsData';                    []; []; [] };      % structure
fieldsAndBounds( 9,:)  = { 'cdppTsData';                     []; []; [] };      % structure array
fieldsAndBounds(10,:)  = { 'badPixels';                      []; []; [] };      % structure array
fieldsAndBounds(11,:)  = { 'backgroundPolyStruct';           []; []; [] };      % structure array
fieldsAndBounds(12,:)  = { 'motionPolyStruct';               []; []; [] };      % structure array
fieldsAndBounds(13,:)  = { 'ancillaryEngineeringParameters'; []; []; [] };      % structure
fieldsAndBounds(14,:)  = { 'ancillaryEngineeringData';       []; []; [] };      % structure array
fieldsAndBounds(15,:)  = { 'ancillaryPipelineParameters';    []; []; [] };      % structure
fieldsAndBounds(16,:)  = { 'ancillaryPipelineData';          []; []; [] };      % structure array

validate_structure(pmdInputStruct, fieldsAndBounds, 'pmdInputStruct');

clear fieldsAndBounds;

%--------------------------------------------------------------------------
% second level validation.
% validate the fields in pmdInputStruct.cadenceTimes
%--------------------------------------------------------------------------

% pmdInputStruct.cadenceTimes fields
fieldsAndBounds = cell(5,4);

fieldsAndBounds(1,:)   = { 'startTimestamps';   [];     []; 	[] };
fieldsAndBounds(2,:)   = { 'midTimestamps';     [];     [];     [] };
fieldsAndBounds(3,:)   = { 'endTimestamps';     [];     [];     [] };
fieldsAndBounds(4,:)   = { 'gapIndicators';     [];     [];     [true; false] };
fieldsAndBounds(5,:)   = { 'requantEnabled';    [];     [];     [true; false] };

validate_structure(pmdInputStruct.cadenceTimes, fieldsAndBounds, 'pmdInputStruct.cadenceTimes');

cadenceTimes = pmdInputStruct.cadenceTimes;
cadenceTimes.startTimestamps = cadenceTimes.startTimestamps(~cadenceTimes.gapIndicators);
cadenceTimes.midTimestamps   = cadenceTimes.midTimestamps(~cadenceTimes.gapIndicators);
cadenceTimes.endTimestamps   = cadenceTimes.endTimestamps(~cadenceTimes.gapIndicators);

fieldsAndBounds = cell(3,4);

fieldsAndBounds(1,:)   = { 'startTimestamps';   '>= 54000';     '<= 64000'; 	[] };
fieldsAndBounds(2,:)   = { 'midTimestamps';     '>= 54000';     '<= 64000';     [] }; 
fieldsAndBounds(3,:)   = { 'endTimestamps';     '>= 54000';     '<= 64000';     [] };

validate_structure(cadenceTimes, fieldsAndBounds, 'pmdInputStruct.cadenceTimes');

clear fieldsAndBounds;

%______________________________________________________________________
% second level validation
% validate the fields in pmdInputStruct.pmdModuleParameters  
%______________________________________________________________________

% pmdInputStruct.pmdModuleParameters fields
fieldsAndBounds = cell(167,4);

fieldsAndBounds(  1,:)  = { 'horizonTime';                                           '>= 0'; '<= 100';       [] }; 
fieldsAndBounds(  2,:)  = { 'trendFitTime';                                          '>= 0'; '<= 30';        [] };
fieldsAndBounds(  3,:)  = { 'minTrendFitSampleCount';                                '>= 0'; '<= 500';       [] };
fieldsAndBounds(  4,:)  = { 'initialAverageSampleCount';                             '>= 0'; '<= 500';       [] };
fieldsAndBounds(  5,:)  = { 'alertTime';                                             '>= 0'; '<= 30';        [] };

fieldsAndBounds(  6,:)  = { 'blackLevelSmoothingFactor';                             '>= 0'; '<= 1';         [] };
fieldsAndBounds(  7,:)  = { 'blackLevelFixedLowerBound';                             '>= -100'; '<= 0';      [] };
fieldsAndBounds(  8,:)  = { 'blackLevelFixedUpperBound';                             '>= 0';    '<= 100';    [] };
fieldsAndBounds(  9,:)  = { 'blackLevelAdaptiveXFactor';                             '>= 0'; '<= 100';       [] };   

fieldsAndBounds( 10,:)  = { 'smearLevelSmoothingFactor';                             '>= 0'; '<= 1';         [] };
fieldsAndBounds( 11,:)  = { 'smearLevelFixedLowerBound';                             '== 0'; []';            [] };
fieldsAndBounds( 12,:)  = { 'smearLevelFixedUpperBound';                             '>= 0'; '<= 100000';    [] };
fieldsAndBounds( 13,:)  = { 'smearLevelAdaptiveXFactor';                             '>= 0'; '<= 100';       [] }; 

fieldsAndBounds( 14,:)  = { 'darkCurrentSmoothingFactor';                            '>= 0'; '<= 1';         [] };
fieldsAndBounds( 15,:)  = { 'darkCurrentFixedLowerBound';                            '>= -20'; '<= 0';       [] };
fieldsAndBounds( 16,:)  = { 'darkCurrentFixedUpperBound';                            '>= 0'; '<= 20';        [] };
fieldsAndBounds( 17,:)  = { 'darkCurrentAdaptiveXFactor';                            '>= 0'; '<= 100';       [] }; 

fieldsAndBounds( 18,:)  = { 'twoDBlackSmoothingFactor';                              '>= 0'; '<= 1';         [] };
fieldsAndBounds( 19,:)  = { 'twoDBlackFixedLowerBound';                              '== 0'; [];             [] };
fieldsAndBounds( 20,:)  = { 'twoDBlackFixedUpperBound';                              '>= 0'; '<= 1e6';       [] };
fieldsAndBounds( 21,:)  = { 'twoDBlackAdaptiveXFactor';                              '>= 0'; '<= 100';       [] }; 

fieldsAndBounds( 22,:)  = { 'ldeUndershootSmoothingFactor';                          '>= 0'; '<= 1';         [] };
fieldsAndBounds( 23,:)  = { 'ldeUndershootFixedLowerBound';                          '>= -200'; '<= 0';       [] };
fieldsAndBounds( 24,:)  = { 'ldeUndershootFixedUpperBound';                          '>= 0';   '<= 200';      [] };
fieldsAndBounds( 25,:)  = { 'ldeUndershootAdaptiveXFactor';                          '>= 0'; '<= 100';       [] }; 

fieldsAndBounds( 26,:)  = { 'compressionSmoothingFactor';                            '>= 0'; '<= 1';         [] };
fieldsAndBounds( 27,:)  = { 'compressionFixedLowerBound';                            '>= 0'; '<= 10';        [] };
fieldsAndBounds( 28,:)  = { 'compressionFixedUpperBound';                            '>= 5'; '<= 50';        [] };
fieldsAndBounds( 29,:)  = { 'compressionAdaptiveXFactor';                            '>= 0'; '<= 100';       [] }; 

fieldsAndBounds( 30,:)  = { 'blackCosmicRayHitRateSmoothingFactor';                  '>= 0'; '<= 1';         [] };
fieldsAndBounds( 31,:)  = { 'blackCosmicRayHitRateFixedLowerBound';                  '== 0'; [];             [] };
fieldsAndBounds( 32,:)  = { 'blackCosmicRayHitRateFixedUpperBound';                  '>= 0'; '<= 100';       [] };
fieldsAndBounds( 33,:)  = { 'blackCosmicRayHitRateAdaptiveXFactor';                  '>= 0'; '<= 100';       [] }; 

fieldsAndBounds( 34,:)  = { 'blackCosmicRayMeanEnergySmoothingFactor';               '>= 0'; '<= 1';         [] };
fieldsAndBounds( 35,:)  = { 'blackCosmicRayMeanEnergyFixedLowerBound';               '== 0'; [];             [] };
fieldsAndBounds( 36,:)  = { 'blackCosmicRayMeanEnergyFixedUpperBound';               '>= 0'; '<= 1e10';      [] };
fieldsAndBounds( 37,:)  = { 'blackCosmicRayMeanEnergyAdaptiveXFactor';               '>= 0'; '<= 100';       [] }; 

fieldsAndBounds( 38,:)  = { 'blackCosmicRayEnergyVarianceSmoothingFactor';           '>= 0'; '<= 1';         [] };
fieldsAndBounds( 39,:)  = { 'blackCosmicRayEnergyVarianceFixedLowerBound';           '== 0'; [];             [] };
fieldsAndBounds( 40,:)  = { 'blackCosmicRayEnergyVarianceFixedUpperBound';           '>= 0'; '<= 1e10';      [] };
fieldsAndBounds( 41,:)  = { 'blackCosmicRayEnergyVarianceAdaptiveXFactor';           '>= 0'; '<= 100';       [] }; 

fieldsAndBounds( 42,:)  = { 'blackCosmicRayEnergySkewnessSmoothingFactor';           '>= 0'; '<= 1';         [] };
fieldsAndBounds( 43,:)  = { 'blackCosmicRayEnergySkewnessFixedLowerBound';           '>= -100'; '<= 0';      [] }; 
fieldsAndBounds( 44,:)  = { 'blackCosmicRayEnergySkewnessFixedUpperBound';           '>= 0';    '<= 100';    [] };
fieldsAndBounds( 45,:)  = { 'blackCosmicRayEnergySkewnessAdaptiveXFactor';           '>= 0'; '<= 100';       [] }; 

fieldsAndBounds( 46,:)  = { 'blackCosmicRayEnergyKurtosisSmoothingFactor';           '>= 0'; '<= 1';         [] };
fieldsAndBounds( 47,:)  = { 'blackCosmicRayEnergyKurtosisFixedLowerBound';           '== 0'; [];             [] };
fieldsAndBounds( 48,:)  = { 'blackCosmicRayEnergyKurtosisFixedUpperBound';           '>= 0'; '<= 1e10';      [] };
fieldsAndBounds( 49,:)  = { 'blackCosmicRayEnergyKurtosisAdaptiveXFactor';           '>= 0'; '<= 100';       [] }; 

fieldsAndBounds( 50,:)  = { 'maskedSmearCosmicRayHitRateSmoothingFactor';            '>= 0'; '<= 1';         [] };
fieldsAndBounds( 51,:)  = { 'maskedSmearCosmicRayHitRateFixedLowerBound';            '== 0'; [];             [] };
fieldsAndBounds( 52,:)  = { 'maskedSmearCosmicRayHitRateFixedUpperBound';            '>= 0'; '<= 100';       [] };
fieldsAndBounds( 53,:)  = { 'maskedSmearCosmicRayHitRateAdaptiveXFactor';            '>= 0'; '<= 100';       [] }; 

fieldsAndBounds( 54,:)  = { 'maskedSmearCosmicRayMeanEnergySmoothingFactor';         '>= 0'; '<= 1';         [] };
fieldsAndBounds( 55,:)  = { 'maskedSmearCosmicRayMeanEnergyFixedLowerBound';         '== 0'; [];             [] };
fieldsAndBounds( 56,:)  = { 'maskedSmearCosmicRayMeanEnergyFixedUpperBound';         '>= 0'; '<= 1e10';      [] };
fieldsAndBounds( 57,:)  = { 'maskedSmearCosmicRayMeanEnergyAdaptiveXFactor';         '>= 0'; '<= 100';       [] }; 

fieldsAndBounds( 58,:)  = { 'maskedSmearCosmicRayEnergyVarianceSmoothingFactor';     '>= 0'; '<= 1';         [] };
fieldsAndBounds( 59,:)  = { 'maskedSmearCosmicRayEnergyVarianceFixedLowerBound';     '== 0'; [];             [] };
fieldsAndBounds( 60,:)  = { 'maskedSmearCosmicRayEnergyVarianceFixedUpperBound';     '>= 0'; '<= 1e10';      [] };
fieldsAndBounds( 61,:)  = { 'maskedSmearCosmicRayEnergyVarianceAdaptiveXFactor';     '>= 0'; '<= 100';       [] }; 

fieldsAndBounds( 62,:)  = { 'maskedSmearCosmicRayEnergySkewnessSmoothingFactor';     '>= 0'; '<= 1';         [] };
fieldsAndBounds( 63,:)  = { 'maskedSmearCosmicRayEnergySkewnessFixedLowerBound';     '>= -100'; '<= 0';      [] }; 
fieldsAndBounds( 64,:)  = { 'maskedSmearCosmicRayEnergySkewnessFixedUpperBound';     '>= 0';    '<= 100';    [] };
fieldsAndBounds( 65,:)  = { 'maskedSmearCosmicRayEnergySkewnessAdaptiveXFactor';     '>= 0'; '<= 100';       [] }; 

fieldsAndBounds( 66,:)  = { 'maskedSmearCosmicRayEnergyKurtosisSmoothingFactor';     '>= 0'; '<= 1';         [] };
fieldsAndBounds( 67,:)  = { 'maskedSmearCosmicRayEnergyKurtosisFixedLowerBound';     '== 0'; [];             [] };
fieldsAndBounds( 68,:)  = { 'maskedSmearCosmicRayEnergyKurtosisFixedUpperBound';     '>= 0'; '<= 1e10';      [] };
fieldsAndBounds( 69,:)  = { 'maskedSmearCosmicRayEnergyKurtosisAdaptiveXFactor';     '>= 0'; '<= 100';       [] }; 

fieldsAndBounds( 70,:)  = { 'virtualSmearCosmicRayHitRateSmoothingFactor';           '>= 0'; '<= 1';         [] };
fieldsAndBounds( 71,:)  = { 'virtualSmearCosmicRayHitRateFixedLowerBound';           '== 0'; [];             [] };
fieldsAndBounds( 72,:)  = { 'virtualSmearCosmicRayHitRateFixedUpperBound';           '>= 0'; '<= 100';       [] };
fieldsAndBounds( 73,:)  = { 'virtualSmearCosmicRayHitRateAdaptiveXFactor';           '>= 0'; '<= 100';       [] }; 

fieldsAndBounds( 74,:)  = { 'virtualSmearCosmicRayMeanEnergySmoothingFactor';        '>= 0'; '<= 1';         [] };
fieldsAndBounds( 75,:)  = { 'virtualSmearCosmicRayMeanEnergyFixedLowerBound';        '== 0'; [];             [] };
fieldsAndBounds( 76,:)  = { 'virtualSmearCosmicRayMeanEnergyFixedUpperBound';        '>= 0'; '<= 1e10';      [] };
fieldsAndBounds( 77,:)  = { 'virtualSmearCosmicRayMeanEnergyAdaptiveXFactor';        '>= 0'; '<= 100';       [] }; 

fieldsAndBounds( 78,:)  = { 'virtualSmearCosmicRayEnergyVarianceSmoothingFactor';    '>= 0'; '<= 1';         [] };
fieldsAndBounds( 79,:)  = { 'virtualSmearCosmicRayEnergyVarianceFixedLowerBound';    '== 0'; [];             [] };
fieldsAndBounds( 80,:)  = { 'virtualSmearCosmicRayEnergyVarianceFixedUpperBound';    '>= 0'; '<= 1e20';      [] };
fieldsAndBounds( 81,:)  = { 'virtualSmearCosmicRayEnergyVarianceAdaptiveXFactor';    '>= 0'; '<= 100';       [] }; 

fieldsAndBounds( 82,:)  = { 'virtualSmearCosmicRayEnergySkewnessSmoothingFactor';    '>= 0'; '<= 1';         [] };
fieldsAndBounds( 83,:)  = { 'virtualSmearCosmicRayEnergySkewnessFixedLowerBound';    '>= -100'; '<= 0';      [] }; 
fieldsAndBounds( 84,:)  = { 'virtualSmearCosmicRayEnergySkewnessFixedUpperBound';    '>= 0';    '<= 100';    [] };
fieldsAndBounds( 85,:)  = { 'virtualSmearCosmicRayEnergySkewnessAdaptiveXFactor';    '>= 0'; '<= 100';       [] }; 

fieldsAndBounds( 86,:)  = { 'virtualSmearCosmicRayEnergyKurtosisSmoothingFactor';    '>= 0'; '<= 1';         [] };
fieldsAndBounds( 87,:)  = { 'virtualSmearCosmicRayEnergyKurtosisFixedLowerBound';    '== 0'; [];             [] };
fieldsAndBounds( 88,:)  = { 'virtualSmearCosmicRayEnergyKurtosisFixedUpperBound';    '>= 0'; '<= 1e10';      [] };
fieldsAndBounds( 89,:)  = { 'virtualSmearCosmicRayEnergyKurtosisAdaptiveXFactor';    '>= 0'; '<= 100';       [] }; 

fieldsAndBounds( 90,:)  = { 'targetStarCosmicRayHitRateSmoothingFactor';             '>= 0'; '<= 1';         [] };
fieldsAndBounds( 91,:)  = { 'targetStarCosmicRayHitRateFixedLowerBound';             '== 0'; [];             [] };
fieldsAndBounds( 92,:)  = { 'targetStarCosmicRayHitRateFixedUpperBound';             '>= 0'; '<= 100';       [] };
fieldsAndBounds( 93,:)  = { 'targetStarCosmicRayHitRateAdaptiveXFactor';             '>= 0'; '<= 100';       [] }; 

fieldsAndBounds( 94,:)  = { 'targetStarCosmicRayMeanEnergySmoothingFactor';          '>= 0'; '<= 1';         [] };
fieldsAndBounds( 95,:)  = { 'targetStarCosmicRayMeanEnergyFixedLowerBound';          '== 0'; [];             [] };
fieldsAndBounds( 96,:)  = { 'targetStarCosmicRayMeanEnergyFixedUpperBound';          '>= 0'; '<= 1e10';      [] };
fieldsAndBounds( 97,:)  = { 'targetStarCosmicRayMeanEnergyAdaptiveXFactor';          '>= 0'; '<= 100';       [] }; 

fieldsAndBounds( 98,:)  = { 'targetStarCosmicRayEnergyVarianceSmoothingFactor';      '>= 0'; '<= 1';         [] };
fieldsAndBounds( 99,:)  = { 'targetStarCosmicRayEnergyVarianceFixedLowerBound';      '== 0'; [];             [] };
fieldsAndBounds(100,:)  = { 'targetStarCosmicRayEnergyVarianceFixedUpperBound';      '>= 0'; '<= 1e20';      [] };
fieldsAndBounds(101,:)  = { 'targetStarCosmicRayEnergyVarianceAdaptiveXFactor';      '>= 0'; '<= 100';       [] }; 

fieldsAndBounds(102,:)  = { 'targetStarCosmicRayEnergySkewnessSmoothingFactor';      '>= 0'; '<= 1';         [] };
fieldsAndBounds(103,:)  = { 'targetStarCosmicRayEnergySkewnessFixedLowerBound';      '>= -100'; '<= 0';      [] }; 
fieldsAndBounds(104,:)  = { 'targetStarCosmicRayEnergySkewnessFixedUpperBound';      '>= 0';    '<= 100';    [] };
fieldsAndBounds(105,:)  = { 'targetStarCosmicRayEnergySkewnessAdaptiveXFactor';      '>= 0'; '<= 100';       [] }; 

fieldsAndBounds(106,:)  = { 'targetStarCosmicRayEnergyKurtosisSmoothingFactor';      '>= 0'; '<= 1';         [] };
fieldsAndBounds(107,:)  = { 'targetStarCosmicRayEnergyKurtosisFixedLowerBound';      '== 0'; [];             [] };
fieldsAndBounds(108,:)  = { 'targetStarCosmicRayEnergyKurtosisFixedUpperBound';      '>= 0'; '<= 1e10';      [] };
fieldsAndBounds(109,:)  = { 'targetStarCosmicRayEnergyKurtosisAdaptiveXFactor';      '>= 0'; '<= 100';       [] }; 

fieldsAndBounds(110,:)  = { 'backgroundCosmicRayHitRateSmoothingFactor';             '>= 0'; '<= 1';         [] };
fieldsAndBounds(111,:)  = { 'backgroundCosmicRayHitRateFixedLowerBound';             '== 0'; [];             [] };
fieldsAndBounds(112,:)  = { 'backgroundCosmicRayHitRateFixedUpperBound';             '>= 0'; '<= 100';       [] };
fieldsAndBounds(113,:)  = { 'backgroundCosmicRayHitRateAdaptiveXFactor';             '>= 0'; '<= 100';       [] }; 

fieldsAndBounds(114,:)  = { 'backgroundCosmicRayMeanEnergySmoothingFactor';          '>= 0'; '<= 1';         [] };
fieldsAndBounds(115,:)  = { 'backgroundCosmicRayMeanEnergyFixedLowerBound';          '== 0'; [];             [] };
fieldsAndBounds(116,:)  = { 'backgroundCosmicRayMeanEnergyFixedUpperBound';          '>= 0'; '<= 1e10';       [] };
fieldsAndBounds(117,:)  = { 'backgroundCosmicRayMeanEnergyAdaptiveXFactor';          '>= 0'; '<= 100';       [] }; 

fieldsAndBounds(118,:)  = { 'backgroundCosmicRayEnergyVarianceSmoothingFactor';      '>= 0'; '<= 1';         [] };
fieldsAndBounds(119,:)  = { 'backgroundCosmicRayEnergyVarianceFixedLowerBound';      '== 0'; [];             [] };   
fieldsAndBounds(120,:)  = { 'backgroundCosmicRayEnergyVarianceFixedUpperBound';      '>= 0'; '<= 1e20';      [] };  
fieldsAndBounds(121,:)  = { 'backgroundCosmicRayEnergyVarianceAdaptiveXFactor';      '>= 0'; '<= 100';       [] }; 

fieldsAndBounds(122,:)  = { 'backgroundCosmicRayEnergySkewnessSmoothingFactor';      '>= 0'; '<= 1';         [] };
fieldsAndBounds(123,:)  = { 'backgroundCosmicRayEnergySkewnessFixedLowerBound';      '>= -100'; '<= 0';      [] };  
fieldsAndBounds(124,:)  = { 'backgroundCosmicRayEnergySkewnessFixedUpperBound';      '>= 0';    '<= 100';    [] };   
fieldsAndBounds(125,:)  = { 'backgroundCosmicRayEnergySkewnessAdaptiveXFactor';      '>= 0'; '<= 100';       [] }; 

fieldsAndBounds(126,:)  = { 'backgroundCosmicRayEnergyKurtosisSmoothingFactor';      '>= 0'; '<= 1';         [] };
fieldsAndBounds(127,:)  = { 'backgroundCosmicRayEnergyKurtosisFixedLowerBound';      '== 0'; [];             [] };
fieldsAndBounds(128,:)  = { 'backgroundCosmicRayEnergyKurtosisFixedUpperBound';      '>= 0'; '<= 1e10';      [] };
fieldsAndBounds(129,:)  = { 'backgroundCosmicRayEnergyKurtosisAdaptiveXFactor';      '>= 0'; '<= 100';       [] }; 

fieldsAndBounds(130,:)  = { 'brightnessSmoothingFactor';                             '>= 0'; '<= 1';         [] };
fieldsAndBounds(131,:)  = { 'brightnessFixedLowerBound';                             '>= 0';    '<= 1';      [] };
fieldsAndBounds(132,:)  = { 'brightnessFixedUpperBound';                             '>= 0.5';  '<= 2';      [] };
fieldsAndBounds(133,:)  = { 'brightnessAdaptiveXFactor';                             '>= 0'; '<= 100';       [] }; 

fieldsAndBounds(134,:)  = { 'encircledEnergySmoothingFactor';                        '>= 0'; '<= 1';         [] };
fieldsAndBounds(135,:)  = { 'encircledEnergyFixedLowerBound';                        '>= 0'; '<= 15';        [] };
fieldsAndBounds(136,:)  = { 'encircledEnergyFixedUpperBound';                        '>= 0'; '<= 15';        [] };
fieldsAndBounds(137,:)  = { 'encircledEnergyAdaptiveXFactor';                        '>= 0'; '<= 100';       [] }; 

fieldsAndBounds(138,:)  = { 'backgroundLevelSmoothingFactor';                        '>= 0'; '<= 1';         [] };
fieldsAndBounds(139,:)  = { 'backgroundLevelFixedLowerBound';                        '>= 0'; [];             [] };
fieldsAndBounds(140,:)  = { 'backgroundLevelFixedUpperBound';                        '>= 0'; '<= 1000000';    [] };
fieldsAndBounds(141,:)  = { 'backgroundLevelAdaptiveXFactor';                        '>= 0'; '<= 100';       [] }; 

fieldsAndBounds(142,:)  = { 'centroidsMeanRowSmoothingFactor';                       '>= 0'; '<= 1';         [] };
fieldsAndBounds(143,:)  = { 'centroidsMeanRowFixedLowerBound';                       '>= -1';  '<= 0';       [] };
fieldsAndBounds(144,:)  = { 'centroidsMeanRowFixedUpperBound';                       '>= 0';   '<= 1';       [] };
fieldsAndBounds(145,:)  = { 'centroidsMeanRowAdaptiveXFactor';                       '>= 0'; '<= 100';       [] }; 

fieldsAndBounds(146,:)  = { 'centroidsMeanColumnSmoothingFactor';                    '>= 0'; '<= 1';         [] };
fieldsAndBounds(147,:)  = { 'centroidsMeanColumnFixedLowerBound';                    '>= -1';  '<= 0';       [] };
fieldsAndBounds(148,:)  = { 'centroidsMeanColumnFixedUpperBound';                    '>= 0';   '<= 1';       [] };
fieldsAndBounds(149,:)  = { 'centroidsMeanColumnAdaptiveXFactor';                    '>= 0'; '<= 100';       [] }; 

fieldsAndBounds(150,:)  = { 'plateScaleSmoothingFactor';                             '>= 0'; '<= 1';         [] };
fieldsAndBounds(151,:)  = { 'plateScaleFixedLowerBound';                             '>= 0'; '<= 10';        [] }; 
fieldsAndBounds(152,:)  = { 'plateScaleFixedUpperBound';                             '>= 0'; '<= 10';        [] };
fieldsAndBounds(153,:)  = { 'plateScaleAdaptiveXFactor';                             '>= 0'; '<= 100';       [] }; 

fieldsAndBounds(154,:)  = { 'cdppMeasuredSmoothingFactor';                           '>= 0'; '<= 1';         [] };
fieldsAndBounds(155,:)  = { 'cdppMeasuredFixedLowerBound';                           '== 0'; [];             [] };
fieldsAndBounds(156,:)  = { 'cdppMeasuredFixedUpperBound';                           '>= 0'; '<= 2e20';      [] };
fieldsAndBounds(157,:)  = { 'cdppMeasuredAdaptiveXFactor';                           '>= 0'; '<= 100';       [] }; 

fieldsAndBounds(158,:)  = { 'cdppExpectedSmoothingFactor';                           '>= 0'; '<= 1';         [] };
fieldsAndBounds(159,:)  = { 'cdppExpectedFixedLowerBound';                           '== 0'; [];             [] };
fieldsAndBounds(160,:)  = { 'cdppExpectedFixedUpperBound';                           '>= 0'; '<= 2e20';      [] };
fieldsAndBounds(161,:)  = { 'cdppExpectedAdaptiveXFactor';                           '>= 0'; '<= 100';       [] }; 

fieldsAndBounds(162,:)  = { 'cdppRatioSmoothingFactor';                              '>= 0'; '<= 1';         [] };
fieldsAndBounds(163,:)  = { 'cdppRatioFixedLowerBound';                              '>= 0'; '<= 1';         [] };
fieldsAndBounds(164,:)  = { 'cdppRatioFixedUpperBound';                              '>= 1'; '<= 2e20';      [] };
fieldsAndBounds(165,:)  = { 'cdppRatioAdaptiveXFactor';                              '>= 0'; '<= 100';       [] }; 

fieldsAndBounds(166,:)  = { 'debugLevel';                                            '>= 0'; '<= 5';         [] };
fieldsAndBounds(167,:)  = { 'plottingEnabled';                                       [];     [];             [true false] };

validate_structure(pmdInputStruct.pmdModuleParameters, fieldsAndBounds, 'pmdInputStruct.PmdModuleParameters');

clear fieldsAndBounds;

%______________________________________________________________________
% second level validation
% validate the fields in pmdInputStruct.raDec2PixModel (validate only needed fields)
%______________________________________________________________________
                  
fieldsAndBounds = cell(10,4);
fieldsAndBounds( 1,:) = { 'mjdStart';                           '>= 54000';     '<= 64000'; [] };
fieldsAndBounds( 2,:) = { 'mjdEnd';                             '>= 54000';     '<= 64000'; [] };
fieldsAndBounds( 3,:) = { 'spiceFileDir';                       [];             [];         [] };
fieldsAndBounds( 4,:) = { 'spiceSpacecraftEphemerisFilename';   [];             [];         [] };
fieldsAndBounds( 5,:) = { 'planetaryEphemerisFilename';         [];             [];         [] };
fieldsAndBounds( 6,:) = { 'leapSecondFilename';                 [];             [];         [] };
fieldsAndBounds( 7,:) = { 'pointingModel';                      [];             [];         [] };
fieldsAndBounds( 8,:) = { 'geometryModel';                      [];             [];         [] };
fieldsAndBounds( 9,:) = { 'rollTimeModel';                      [];             [];         [] };
fieldsAndBounds(10,:) = { 'mjdOffset';                          '== 2400000.5'; [];         [] };

validate_structure(pmdInputStruct.raDec2PixModel, fieldsAndBounds, 'pmdInputStruct.raDec2PixModel');

clear fieldsAndBounds;

%______________________________________________________________________
% second level validation
% validate the fields in pmdInputStruct.inputTsData
%______________________________________________________________________

% pmdInputStruct.inputTsData fields 
fieldsAndBounds = cell(14,4);
fieldsAndBounds( 1,:) = { 'blackLevel';                         []; []; [] }; % structure
fieldsAndBounds( 2,:) = { 'smearLevel';                         []; []; [] }; % structure
fieldsAndBounds( 3,:) = { 'darkCurrent';                        []; []; [] }; % structure
fieldsAndBounds( 4,:) = { 'twoDBlack';                          []; []; [] }; % structure array
fieldsAndBounds( 5,:) = { 'ldeUndershoot';                      []; []; [] }; % structure array
fieldsAndBounds( 6,:) = { 'theoreticalCompressionEfficiency';   []; []; [] }; % structure
fieldsAndBounds( 7,:) = { 'achievedCompressionEfficiency';      []; []; [] }; % structure
fieldsAndBounds( 8,:) = { 'blackCosmicRayMetrics';              []; []; [] }; % structure
fieldsAndBounds( 9,:) = { 'maskedSmearCosmicRayMetrics';        []; []; [] }; % structure
fieldsAndBounds(10,:) = { 'virtualSmearCosmicRayMetrics';       []; []; [] }; % structure
fieldsAndBounds(11,:) = { 'targetStarCosmicRayMetrics';         []; []; [] }; % structure
fieldsAndBounds(12,:) = { 'backgroundCosmicRayMetrics';         []; []; [] }; % structure
fieldsAndBounds(13,:) = { 'brightness';                         []; []; [] }; % structure
fieldsAndBounds(14,:) = { 'encircledEnergy';                    []; []; [] }; % structure

validate_structure(pmdInputStruct.inputTsData, fieldsAndBounds, 'pmdInputStruct.inputTsData');

clear fieldsAndBounds;

%______________________________________________________________________
% third level validation
% validate the fields in pmdInputStruct.inputTsData.blackLevel
%______________________________________________________________________

% pmdInputStruct.inputTsData.blackLevel fields
fieldsAndBounds = cell(3,4);
fieldsAndBounds(1,:)  = { 'values';         [];     [];     []};                % TBD
fieldsAndBounds(2,:)  = { 'gapIndicators';  [];     [];     [true, false]};
fieldsAndBounds(3,:)  = { 'uncertainties';  [];     [];     []};                % TBD

validate_structure(pmdInputStruct.inputTsData.blackLevel, fieldsAndBounds, 'pmdInputStruct.inputTsData.blackLevel');

clear fieldsAndBounds;

%______________________________________________________________________
% third level validation
% validate the fields in pmdInputStruct.inputTsData.smearLevel
%______________________________________________________________________

% pmdInputStruct.inputTsData.smearLevel fields
fieldsAndBounds = cell(3,4);
fieldsAndBounds(1,:)  = { 'values';         [];     [];     []};                % TBD
fieldsAndBounds(2,:)  = { 'gapIndicators';  [];     [];     [true, false]};
fieldsAndBounds(3,:)  = { 'uncertainties';  [];     [];     []};                % TBD

validate_structure(pmdInputStruct.inputTsData.smearLevel, fieldsAndBounds, 'pmdInputStruct.inputTsData.smearLevel');

clear fieldsAndBounds;

%______________________________________________________________________
% third level validation
% validate the fields in pmdInputStruct.inputTsData.darkCurrent
%______________________________________________________________________

% pmdInputStruct.inputTsData.darkCurrent fields
fieldsAndBounds = cell(3,4);
fieldsAndBounds(1,:)  = { 'values';         [];     [];     []};                % TBD
fieldsAndBounds(2,:)  = { 'gapIndicators';  [];     [];     [true, false]};
fieldsAndBounds(3,:)  = { 'uncertainties';  [];     [];     []};                % TBD

validate_structure(pmdInputStruct.inputTsData.darkCurrent, fieldsAndBounds, 'pmdInputStruct.inputTsData.darkCurrent');

clear fieldsAndBounds;

%______________________________________________________________________
% third level validation
% validate the fields in pmdInputStruct.inputTsData.twoDBlack
%______________________________________________________________________

% pmdInputStruct.inputTsData.twoDBlack fields
fieldsAndBounds = cell(4,4);
fieldsAndBounds(1,:)  = { 'keplerId';       '> 0';  '< 1e9';    []};                
fieldsAndBounds(2,:)  = { 'values';         [];     [];         []};                % TBD
fieldsAndBounds(3,:)  = { 'gapIndicators';  [];     [];         [true, false]};
fieldsAndBounds(4,:)  = { 'uncertainties';  [];     [];         []};                % TBD

nTwoDBlackTargets = length(pmdInputStruct.inputTsData.twoDBlack);
for j = 1:nTwoDBlackTargets
    validate_structure(pmdInputStruct.inputTsData.twoDBlack(j), fieldsAndBounds, ['pmdInputStruct.inputTsData.twoDBlack(', num2str(j), ')']);
end

clear fieldsAndBounds;

%______________________________________________________________________
% third level validation
% validate the fields in pmdInputStruct.inputTsData.ldeUndershoot
%______________________________________________________________________

% pmdInputStruct.inputTsData.ldeUndershoot fields
fieldsAndBounds = cell(4,4);
fieldsAndBounds(1,:)  = { 'keplerId';       '> 0';  '< 1e9';    []}; 
fieldsAndBounds(2,:)  = { 'values';         [];     [];         []};                % TBD
fieldsAndBounds(3,:)  = { 'gapIndicators';  [];     [];         [true, false]};
fieldsAndBounds(4,:)  = { 'uncertainties';  [];     [];         []};                % TBD

nLdeUndershootTargets = length(pmdInputStruct.inputTsData.ldeUndershoot);
for j = 1:nLdeUndershootTargets
    validate_structure(pmdInputStruct.inputTsData.ldeUndershoot(j), fieldsAndBounds, ['pmdInputStruct.inputTsData.ldeUndershoot(', num2str(j), ')']);
end

clear fieldsAndBounds;

%______________________________________________________________________
% third level validation
% validate the fields in pmdInputStruct.inputTsData.theoreticalCompressionEfficiency
%______________________________________________________________________

% pmdInputStruct.inputTsData.theoreticalCompressionEfficiency fields
fieldsAndBounds = cell(2,4);
fieldsAndBounds(1,:)  = { 'values';         [];     [];     []};                % TBD
fieldsAndBounds(2,:)  = { 'gapIndicators';  [];     [];     [true, false]};

validate_structure(pmdInputStruct.inputTsData.theoreticalCompressionEfficiency, fieldsAndBounds, 'pmdInputStruct.inputTsData.theoreticalCompressionEfficiency');

clear fieldsAndBounds;

%______________________________________________________________________
% third level validation
% validate the fields in pmdInputStruct.inputTsData.achievedCompressionEfficiency
%______________________________________________________________________

% pmdInputStruct.inputTsData.achievedCompressionEfficiency fields
fieldsAndBounds = cell(2,4);
fieldsAndBounds(1,:)  = { 'values';         [];     [];     []};                % TBD
fieldsAndBounds(2,:)  = { 'gapIndicators';  [];     [];     [true, false]};

validate_structure(pmdInputStruct.inputTsData.achievedCompressionEfficiency, fieldsAndBounds, 'pmdInputStruct.inputTsData.achievedCompressionEfficiency');

clear fieldsAndBounds;

%______________________________________________________________________
% third level validation
% validate the fields in pmdInputStruct.inputTsData.brightness
%______________________________________________________________________

% pmdInputStruct.inputTsData.brightness fields
fieldsAndBounds = cell(3,4);
fieldsAndBounds(1,:)  = { 'values';         [];     [];     []};                % TBD
fieldsAndBounds(2,:)  = { 'gapIndicators';  [];     [];     [true, false]};
fieldsAndBounds(3,:)  = { 'uncertainties';  [];     [];     []};                % TBD

validate_structure(pmdInputStruct.inputTsData.brightness, fieldsAndBounds, 'pmdInputStruct.inputTsData.brightness');

clear fieldsAndBounds;

%______________________________________________________________________
% third level validation
% validate the fields in pmdInputStruct.inputTsData.encircledEnergy
%______________________________________________________________________

% pmdInputStruct.inputTsData.encircledEnergy fields
fieldsAndBounds = cell(3,4);
fieldsAndBounds(1,:)  = { 'values';         [];     [];     []};                % TBD
fieldsAndBounds(2,:)  = { 'gapIndicators';  [];     [];     [true, false]};
fieldsAndBounds(3,:)  = { 'uncertainties';  [];     [];     []};                % TBD

validate_structure(pmdInputStruct.inputTsData.encircledEnergy, fieldsAndBounds, 'pmdInputStruct.inputTsData.encircledEnergy');

clear fieldsAndBounds;

%______________________________________________________________________
% third level validation
% validate the fields in pmdInputStruct.inputTsData.blackCosmicRayMetrics
%                        pmdInputStruct.inputTsData.maskedSmearCosmicRayMetrics
%                        pmdInputStruct.inputTsData.virtualSmearCosmicRayMetrics
%                        pmdInputStruct.inputTsData.targetStarCosmicRayMetrics
%                        pmdInputStruct.inputTsData.backgroundCosmicRayMetrics
%______________________________________________________________________

% pmdInputStruct.inputTsData.cosmicRayMetrics fields
fieldsAndBounds = cell(6,4);
fieldsAndBounds( 1,:)  = { 'empty';             []; []; [true, false] };
fieldsAndBounds( 2,:)  = { 'hitRate';           []; []; [] };   % structure
fieldsAndBounds( 3,:)  = { 'meanEnergy';        []; []; [] };   % structure
fieldsAndBounds( 4,:)  = { 'energyVariance';    []; []; [] };   % structure
fieldsAndBounds( 5,:)  = { 'energySkewness';    []; []; [] };   % structure 
fieldsAndBounds( 6,:)  = { 'energyKurtosis';    []; []; [] };   % structure

validate_structure(pmdInputStruct.inputTsData.blackCosmicRayMetrics,           fieldsAndBounds,    'pmdInputStruct.inputTsData.blackCosmicRayMetrics');
validate_structure(pmdInputStruct.inputTsData.maskedSmearCosmicRayMetrics,     fieldsAndBounds,    'pmdInputStruct.inputTsData.maskedSmearCosmicRayMetrics');
validate_structure(pmdInputStruct.inputTsData.virtualSmearCosmicRayMetrics,    fieldsAndBounds,    'pmdInputStruct.inputTsData.virtualSmearCosmicRayMetrics');
validate_structure(pmdInputStruct.inputTsData.targetStarCosmicRayMetrics,      fieldsAndBounds,    'pmdInputStruct.inputTsData.targetStarCosmicRayMetrics');
validate_structure(pmdInputStruct.inputTsData.backgroundCosmicRayMetrics,      fieldsAndBounds,    'pmdInputStruct.inputTsData.backgroundCosmicRayMetrics');

clear fieldsAndBounds;

%______________________________________________________________________
% fourth level validation
% validate the fields in pmdInputStruct.inputTsData.blackCosmicRayMetrics.hitRate
%______________________________________________________________________

fieldsAndBounds = cell(2,4);
fieldsAndBounds(1,:)  = { 'values';         [];     [];     []};                % TBD
fieldsAndBounds(2,:)  = { 'gapIndicators';  [];     [];     [true, false]};

validate_structure(pmdInputStruct.inputTsData.blackCosmicRayMetrics.hitRate,               fieldsAndBounds, 'pmdInputStruct.inputTsData.blackCosmicRayMetrics.hitRate');

clear fieldsAndBounds;

%______________________________________________________________________
% fourth level validation
% validate the fields in pmdInputStruct.inputTsData.blackCosmicRayMetrics.meanEnergy
%______________________________________________________________________

fieldsAndBounds = cell(2,4);
fieldsAndBounds(1,:)  = { 'values';         [];     [];     []};                % TBD
fieldsAndBounds(2,:)  = { 'gapIndicators';  [];     [];     [true, false]};

validate_structure(pmdInputStruct.inputTsData.blackCosmicRayMetrics.meanEnergy,            fieldsAndBounds, 'pmdInputStruct.inputTsData.blackCosmicRayMetrics.meanEnergy');

clear fieldsAndBounds;

%______________________________________________________________________
% fourth level validation
% validate the fields in pmdInputStruct.inputTsData.blackCosmicRayMetrics.energyVariance
%______________________________________________________________________

fieldsAndBounds = cell(2,4);
fieldsAndBounds(1,:)  = { 'values';         [];     [];     []};                % TBD
fieldsAndBounds(2,:)  = { 'gapIndicators';  [];     [];     [true, false]};

validate_structure(pmdInputStruct.inputTsData.blackCosmicRayMetrics.energyVariance,        fieldsAndBounds, 'pmdInputStruct.inputTsData.blackCosmicRayMetrics.energyVariance');

clear fieldsAndBounds;

%______________________________________________________________________
% fourth level validation
% validate the fields in pmdInputStruct.inputTsData.blackCosmicRayMetrics.energySkewness
%______________________________________________________________________

fieldsAndBounds = cell(2,4);
fieldsAndBounds(1,:)  = { 'values';         [];     [];     []};                % TBD
fieldsAndBounds(2,:)  = { 'gapIndicators';  [];     [];     [true, false]};

validate_structure(pmdInputStruct.inputTsData.blackCosmicRayMetrics.energySkewness,        fieldsAndBounds, 'pmdInputStruct.inputTsData.blackCosmicRayMetrics.energySkewness');

clear fieldsAndBounds;

%______________________________________________________________________
% fourth level validation
% validate the fields in pmdInputStruct.inputTsData.blackCosmicRayMetrics.energyKurtosis
%______________________________________________________________________

fieldsAndBounds = cell(2,4);
fieldsAndBounds(1,:)  = { 'values';         [];     [];     []};                % TBD
fieldsAndBounds(2,:)  = { 'gapIndicators';  [];     [];     [true, false]};

validate_structure(pmdInputStruct.inputTsData.blackCosmicRayMetrics.energyKurtosis,        fieldsAndBounds, 'pmdInputStruct.inputTsData.blackCosmicRayMetrics.energyKurtosis');

clear fieldsAndBounds;

%______________________________________________________________________
% fourth level validation
% validate the fields in pmdInputStruct.inputTsData.maskedSmearCosmicRayMetrics.hitRate
%______________________________________________________________________

fieldsAndBounds = cell(2,4);
fieldsAndBounds(1,:)  = { 'values';         [];     [];     []};                % TBD
fieldsAndBounds(2,:)  = { 'gapIndicators';  [];     [];     [true, false]};

validate_structure(pmdInputStruct.inputTsData.maskedSmearCosmicRayMetrics.hitRate,         fieldsAndBounds, 'pmdInputStruct.inputTsData.maskedSmearCosmicRayMetrics.hitRate');

clear fieldsAndBounds;

%______________________________________________________________________
% fourth level validation
% validate the fields in pmdInputStruct.inputTsData.maskedSmearCosmicRayMetrics.meanEnergy
%______________________________________________________________________

fieldsAndBounds = cell(2,4);
fieldsAndBounds(1,:)  = { 'values';         [];     [];     []};                % TBD
fieldsAndBounds(2,:)  = { 'gapIndicators';  [];     [];     [true, false]};

validate_structure(pmdInputStruct.inputTsData.maskedSmearCosmicRayMetrics.meanEnergy,      fieldsAndBounds, 'pmdInputStruct.inputTsData.maskedSmearCosmicRayMetrics.meanEnergy');

clear fieldsAndBounds;

%______________________________________________________________________
% fourth level validation
% validate the fields in pmdInputStruct.inputTsData.maskedSmearCosmicRayMetrics.energyVariance
%______________________________________________________________________

fieldsAndBounds = cell(2,4);
fieldsAndBounds(1,:)  = { 'values';         [];     [];     []};                % TBD
fieldsAndBounds(2,:)  = { 'gapIndicators';  [];     [];     [true, false]};

validate_structure(pmdInputStruct.inputTsData.maskedSmearCosmicRayMetrics.energyVariance,  fieldsAndBounds, 'pmdInputStruct.inputTsData.maskedSmearCosmicRayMetrics.energyVariance');

clear fieldsAndBounds;

%______________________________________________________________________
% fourth level validation
% validate the fields in pmdInputStruct.inputTsData.maskedSmearCosmicRayMetrics.energySkewness
%______________________________________________________________________

fieldsAndBounds = cell(2,4);
fieldsAndBounds(1,:)  = { 'values';         [];     [];     []};                % TBD
fieldsAndBounds(2,:)  = { 'gapIndicators';  [];     [];     [true, false]};

validate_structure(pmdInputStruct.inputTsData.maskedSmearCosmicRayMetrics.energySkewness,  fieldsAndBounds, 'pmdInputStruct.inputTsData.maskedSmearCosmicRayMetrics.energySkewness');

clear fieldsAndBounds;

%______________________________________________________________________
% fourth level validation
% validate the fields in pmdInputStruct.inputTsData.maskedSmearCosmicRayMetrics.energyKurtosis
%______________________________________________________________________

fieldsAndBounds = cell(2,4);
fieldsAndBounds(1,:)  = { 'values';         [];     [];     []};                % TBD
fieldsAndBounds(2,:)  = { 'gapIndicators';  [];     [];     [true, false]};

validate_structure(pmdInputStruct.inputTsData.maskedSmearCosmicRayMetrics.energyKurtosis,  fieldsAndBounds, 'pmdInputStruct.inputTsData.maskedSmearCosmicRayMetrics.energyKurtosis');

clear fieldsAndBounds;

%______________________________________________________________________
% fourth level validation
% validate the fields in pmdInputStruct.inputTsData.virtualSmearCosmicRayMetrics.hitRate
%______________________________________________________________________

fieldsAndBounds = cell(2,4);
fieldsAndBounds(1,:)  = { 'values';         [];     [];     []};                % TBD
fieldsAndBounds(2,:)  = { 'gapIndicators';  [];     [];     [true, false]};

validate_structure(pmdInputStruct.inputTsData.virtualSmearCosmicRayMetrics.hitRate,        fieldsAndBounds, 'pmdInputStruct.inputTsData.virtualSmearCosmicRayMetrics.hitRate');

clear fieldsAndBounds;

%______________________________________________________________________
% fourth level validation
% validate the fields in pmdInputStruct.inputTsData.virtualSmearCosmicRayMetrics.meanEnergy
%______________________________________________________________________

fieldsAndBounds = cell(2,4);
fieldsAndBounds(1,:)  = { 'values';         [];     [];     []};                % TBD
fieldsAndBounds(2,:)  = { 'gapIndicators';  [];     [];     [true, false]};

validate_structure(pmdInputStruct.inputTsData.virtualSmearCosmicRayMetrics.meanEnergy,     fieldsAndBounds, 'pmdInputStruct.inputTsData.virtualSmearCosmicRayMetrics.meanEnergy');

clear fieldsAndBounds;

%______________________________________________________________________
% fourth level validation
% validate the fields in pmdInputStruct.inputTsData.virtualSmearCosmicRayMetrics.energyVariance
%______________________________________________________________________

fieldsAndBounds = cell(2,4);
fieldsAndBounds(1,:)  = { 'values';         [];     [];     []};                % TBD
fieldsAndBounds(2,:)  = { 'gapIndicators';  [];     [];     [true, false]};

validate_structure(pmdInputStruct.inputTsData.virtualSmearCosmicRayMetrics.energyVariance, fieldsAndBounds, 'pmdInputStruct.inputTsData.virtualSmearCosmicRayMetrics.energyVariance');

clear fieldsAndBounds;

%______________________________________________________________________
% fourth level validation
% validate the fields in pmdInputStruct.inputTsData.virtualSmearCosmicRayMetrics.energySkewness
%______________________________________________________________________

fieldsAndBounds = cell(2,4);
fieldsAndBounds(1,:)  = { 'values';         [];     [];     []};                % TBD
fieldsAndBounds(2,:)  = { 'gapIndicators';  [];     [];     [true, false]};

validate_structure(pmdInputStruct.inputTsData.virtualSmearCosmicRayMetrics.energySkewness, fieldsAndBounds, 'pmdInputStruct.inputTsData.virtualSmearCosmicRayMetrics.energySkewness');

clear fieldsAndBounds;

%______________________________________________________________________
% fourth level validation
% validate the fields in pmdInputStruct.inputTsData.virtualSmearCosmicRayMetrics.energyKurtosis
%______________________________________________________________________

fieldsAndBounds = cell(2,4);
fieldsAndBounds(1,:)  = { 'values';         [];     [];     []};                % TBD
fieldsAndBounds(2,:)  = { 'gapIndicators';  [];     [];     [true, false]};

validate_structure(pmdInputStruct.inputTsData.virtualSmearCosmicRayMetrics.energyKurtosis, fieldsAndBounds, 'pmdInputStruct.inputTsData.virtualSmearCosmicRayMetrics.energyKurtosis');

clear fieldsAndBounds;

%______________________________________________________________________
% fourth level validation
% validate the fields in pmdInputStruct.inputTsData.targetStarCosmicRayMetrics.hitRate
%______________________________________________________________________

fieldsAndBounds = cell(2,4);
fieldsAndBounds(1,:)  = { 'values';         [];     [];     []};                % TBD
fieldsAndBounds(2,:)  = { 'gapIndicators';  [];     [];     [true, false]};

validate_structure(pmdInputStruct.inputTsData.targetStarCosmicRayMetrics.hitRate,          fieldsAndBounds, 'pmdInputStruct.inputTsData.targetStarCosmicRayMetrics.hitRate');

clear fieldsAndBounds;

%______________________________________________________________________
% fourth level validation
% validate the fields in pmdInputStruct.inputTsData.targetStarCosmicRayMetrics.meanEnergy
%______________________________________________________________________

fieldsAndBounds = cell(2,4);
fieldsAndBounds(1,:)  = { 'values';         [];     [];     []};                % TBD
fieldsAndBounds(2,:)  = { 'gapIndicators';  [];     [];     [true, false]};

validate_structure(pmdInputStruct.inputTsData.targetStarCosmicRayMetrics.meanEnergy,       fieldsAndBounds, 'pmdInputStruct.inputTsData.targetStarCosmicRayMetrics.meanEnergy');

clear fieldsAndBounds;

%______________________________________________________________________
% fourth level validation
% validate the fields in pmdInputStruct.inputTsData.targetStarCosmicRayMetrics.energyVariance
%______________________________________________________________________

fieldsAndBounds = cell(2,4);
fieldsAndBounds(1,:)  = { 'values';         [];     [];     []};                % TBD
fieldsAndBounds(2,:)  = { 'gapIndicators';  [];     [];     [true, false]};

validate_structure(pmdInputStruct.inputTsData.targetStarCosmicRayMetrics.energyVariance,   fieldsAndBounds, 'pmdInputStruct.inputTsData.targetStarCosmicRayMetrics.energyVariance');

clear fieldsAndBounds;

%______________________________________________________________________
% fourth level validation
% validate the fields in pmdInputStruct.inputTsData.targetStarCosmicRayMetrics.energySkewness
%______________________________________________________________________

fieldsAndBounds = cell(2,4);
fieldsAndBounds(1,:)  = { 'values';         [];     [];     []};                % TBD
fieldsAndBounds(2,:)  = { 'gapIndicators';  [];     [];     [true, false]};

validate_structure(pmdInputStruct.inputTsData.targetStarCosmicRayMetrics.energySkewness,   fieldsAndBounds, 'pmdInputStruct.inputTsData.targetStarCosmicRayMetrics.energySkewness');

clear fieldsAndBounds;

%______________________________________________________________________
% fourth level validation
% validate the fields in pmdInputStruct.inputTsData.targetStarCosmicRayMetrics.energyKurtosis
%______________________________________________________________________

fieldsAndBounds = cell(2,4);
fieldsAndBounds(1,:)  = { 'values';         [];     [];     []};                % TBD
fieldsAndBounds(2,:)  = { 'gapIndicators';  [];     [];     [true, false]};

validate_structure(pmdInputStruct.inputTsData.targetStarCosmicRayMetrics.energyKurtosis, 	fieldsAndBounds, 'pmdInputStruct.inputTsData.targetStarCosmicRayMetrics.energyKurtosis');

clear fieldsAndBounds;

%______________________________________________________________________
% fourth level validation
% validate the fields in pmdInputStruct.inputTsData.backgroundCosmicRayMetrics.hitRate
%______________________________________________________________________

fieldsAndBounds = cell(2,4);
fieldsAndBounds(1,:)  = { 'values';         [];     [];     []};                % TBD
fieldsAndBounds(2,:)  = { 'gapIndicators';  [];     [];     [true, false]};

validate_structure(pmdInputStruct.inputTsData.backgroundCosmicRayMetrics.hitRate,          fieldsAndBounds, 'pmdInputStruct.inputTsData.backgroundCosmicRayMetrics.hitRate');

clear fieldsAndBounds;

%______________________________________________________________________
% fourth level validation
% validate the fields in pmdInputStruct.inputTsData.backgroundCosmicRayMetrics.meanEnergy
%______________________________________________________________________

fieldsAndBounds = cell(2,4);
fieldsAndBounds(1,:)  = { 'values';         [];     [];     []};                % TBD
fieldsAndBounds(2,:)  = { 'gapIndicators';  [];     [];     [true, false]};

validate_structure(pmdInputStruct.inputTsData.backgroundCosmicRayMetrics.meanEnergy,       fieldsAndBounds, 'pmdInputStruct.inputTsData.backgroundCosmicRayMetrics.meanEnergy');

clear fieldsAndBounds;

%______________________________________________________________________
% fourth level validation
% validate the fields in pmdInputStruct.inputTsData.backgroundCosmicRayMetrics.energyVariance
%______________________________________________________________________

fieldsAndBounds = cell(2,4);
fieldsAndBounds(1,:)  = { 'values';         [];     [];     []};                % TBD
fieldsAndBounds(2,:)  = { 'gapIndicators';  [];     [];     [true, false]};

validate_structure(pmdInputStruct.inputTsData.backgroundCosmicRayMetrics.energyVariance,   fieldsAndBounds, 'pmdInputStruct.inputTsData.backgroundCosmicRayMetrics.energyVariance');

clear fieldsAndBounds;

%______________________________________________________________________
% fourth level validation
% validate the fields in pmdInputStruct.inputTsData.backgroundCosmicRayMetrics.energySkewness
%______________________________________________________________________

fieldsAndBounds = cell(2,4);
fieldsAndBounds(1,:)  = { 'values';         [];     [];     []};                % TBD
fieldsAndBounds(2,:)  = { 'gapIndicators';  [];     [];     [true, false]};

validate_structure(pmdInputStruct.inputTsData.backgroundCosmicRayMetrics.energySkewness,   fieldsAndBounds, 'pmdInputStruct.inputTsData.backgroundCosmicRayMetrics.energySkewness');

clear fieldsAndBounds;

%______________________________________________________________________
% fourth level validation
% validate the fields in pmdInputStruct.inputTsData.backgroundCosmicRayMetrics.energyKurtosis
%______________________________________________________________________

fieldsAndBounds = cell(2,4);
fieldsAndBounds(1,:)  = { 'values';         [];     [];     []};                % TBD
fieldsAndBounds(2,:)  = { 'gapIndicators';  [];     [];     [true, false]};

validate_structure(pmdInputStruct.inputTsData.backgroundCosmicRayMetrics.energyKurtosis,   fieldsAndBounds, 'pmdInputStruct.inputTsData.backgroundCosmicRayMetrics.energyKurtosis');

clear fieldsAndBounds;

%______________________________________________________________________
% second level validation
% validate the fields in pmdInputStruct.cdppTsData
%______________________________________________________________________

% pmdInputStruct.cdppTsData fields
fieldsAndBounds = cell(6,4);
fieldsAndBounds(1,:)  = { 'keplerId';       '> 0';  '< 1e9';    []}; 
fieldsAndBounds(2,:)  = { 'keplerMag';      '> 0';  '< 31';     []}; 
fieldsAndBounds(3,:)  = { 'cdpp3Hr';        [];     [];         []};                % TBD
fieldsAndBounds(4,:)  = { 'cdpp6Hr';        [];     [];         []};                % TBD
fieldsAndBounds(5,:)  = { 'cdpp12Hr';       [];     [];         []};                % TBD
fieldsAndBounds(6,:)  = { 'fluxTimeSeries'; [];     [];         []};                % structure

nCdppTsData = length(pmdInputStruct.cdppTsData);
for j = 1:nCdppTsData
    if ( ~isnan(pmdInputStruct.cdppTsData(j).keplerMag) && ~isinf(pmdInputStruct.cdppTsData(j).keplerMag) )
        validate_structure(pmdInputStruct.cdppTsData(j), fieldsAndBounds, ['pmdInputStruct.cdppTsData(' num2str(j) ')']);
    end
end

clear fieldsAndBounds;

%______________________________________________________________________
% third level validation
% validate the fields in pmdInputStruct.cdppTsData.fluxTimeSeries
%______________________________________________________________________

% pmdInputStruct.cdppTsData.fluxTimeSeries fields
fieldsAndBounds = cell(4,4);
fieldsAndBounds(1,:)  = { 'values';         [];     [];     []};                % TBD
fieldsAndBounds(2,:)  = { 'gapIndicators';  [];     [];     [true, false]};
fieldsAndBounds(3,:)  = { 'uncertainties';  [];     [];     []};                % TBD
fieldsAndBounds(4,:)  = { 'filledIndices';  [];     [];     []};                

for j = 1:nCdppTsData
    validate_structure(pmdInputStruct.cdppTsData(j).fluxTimeSeries, fieldsAndBounds, ['pmdInputStruct.cdppTsData(' num2str(j) ').fluxTimeSeries']);
end

fieldsAndBounds = cell(1,4);
fieldsAndBounds(1,:)  = { 'filledIndices';  '>= 0';     '< 10000';     []};                
for j = 1:nCdppTsData
    if ( ~isempty(pmdInputStruct.cdppTsData(j).fluxTimeSeries.filledIndices) ) 
        validate_structure(pmdInputStruct.cdppTsData(j).fluxTimeSeries, fieldsAndBounds, ['pmdInputStruct.cdppTsData(' num2str(j) ').fluxTimeSeries']);
    end
end


clear fieldsAndBounds;

%______________________________________________________________________
% second level validation
% validate the fields in pmdInputStruct.badPixels
%______________________________________________________________________

if ~isempty(pmdInputStruct.badPixels)

    % pmdInputStruct.badPixels fields
    fieldsAndBounds = cell(6,4);
%     fieldsAndBounds(1,:)  = { 'ccdRow';         '>= 0';         '< 1070';       [] };
%     fieldsAndBounds(2,:)  = { 'ccdColumn';      '>= 0';         '< 1132';       [] };
%     fieldsAndBounds(3,:)  = { 'startMjd';       '>= 54000';     '<= 64000'; 	[] };
%     fieldsAndBounds(4,:)  = { 'endMjd';         '>= 54000';     '<= 64000'; 	[] };
    fieldsAndBounds(5,:)  = { 'type';           [];             [];             [] };   % TBD
    fieldsAndBounds(6,:)  = { 'value';          [];             [];             [] };   % TBD

    % !!!!!!!!!!!!!!!!!!!  TEST ONLY !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    fieldsAndBounds(1,:)  = { 'ccdRow';         '>= -1';        '< 1070';       [] };
    fieldsAndBounds(2,:)  = { 'ccdColumn';      '>= -1';        '< 1132';       [] };
    fieldsAndBounds(3,:)  = { 'startMjd';       [];             [];             [] };
    fieldsAndBounds(4,:)  = { 'endMjd';         [];             [];             [] };
    
    nBadPixels = length(pmdInputStruct.badPixels);
    for j = 1:nBadPixels
        validate_structure(pmdInputStruct.badPixels(j), fieldsAndBounds, ['pmdInputStruct.badPixels(' num2str(j) ')']);
    end

    clear fieldsAndBounds;

end

%______________________________________________________________________
% second level validation
% validate the fields in pmdInputStruct.backgroundBlobs and pmdInputStruct.motionBlobs
%______________________________________________________________________

% pmdInputStruct.backgroundBlobs and pmdInputStruct.motionBlobs fields
% fieldsAndBounds = cell(5,4);
% fieldsAndBounds( 1,:)  = { 'blobIndices';            [];         [];         [] };                  
% fieldsAndBounds( 2,:)  = { 'gapIndicators';          [];         [];         [true false] };
% fieldsAndBounds( 3,:)  = { 'blobFilenames';          [];         [];         [] };                  
% fieldsAndBounds( 4,:)  = { 'startCadence';           [];         [];         [] };
% fieldsAndBounds( 5,:)  = { 'endCadence';             [];         [];         [] };
% 
% validate_structure(pmdInputStruct.backgroundBlobs, fieldsAndBounds, 'pmdInputStruct.backgroundBlobs');
% validate_structure(pmdInputStruct.motionBlobs,     fieldsAndBounds, 'pmdInputStruct.motionBlobs'    );
% 
% clear fieldsAndBounds;

%--------------------------------------------------------------------------
% second level validation.
% Validate the structure field pmdInputStruct.backgroundPolyStruct
%--------------------------------------------------------------------------

% pmdInputStruct.backgroundPolyStruct fields
fieldsAndBounds = cell(8,4);
fieldsAndBounds(1,:)  = { 'cadence';                '>= -1';    '< 2e7';    [] };
fieldsAndBounds(2,:)  = { 'mjdStartTime';           '>= -1';    '<= 64000'; [] };
fieldsAndBounds(3,:)  = { 'mjdMidTime';             '>= -1';    '<= 64000'; [] };
fieldsAndBounds(4,:)  = { 'mjdEndTime';             '>= -1';    '<= 64000'; [] };
fieldsAndBounds(5,:)  = { 'module';                 [];         [];         '[-1 2:4, 6:20, 22:24]''' };
fieldsAndBounds(6,:)  = { 'output';                 [];         [];         '[-1 1 2 3 4]''' };
fieldsAndBounds(7,:)  = { 'backgroundPoly';         [];         [];         [] };
fieldsAndBounds(8,:)  = { 'backgroundPolyStatus';   [];         [];         '[0 1]''' };

nBackgroundPolys = length(pmdInputStruct.backgroundPolyStruct);

for j = 1 : nBackgroundPolys
    validate_structure(pmdInputStruct.backgroundPolyStruct(j), fieldsAndBounds, ['pmdInputStruct.backgroundPolyStruct(' num2str(j) ')']);
end

clear fieldsAndBounds;

%--------------------------------------------------------------------------
% third level validation.
% Validate the structure field pmdInputStruct.backgroundPolyStruct.backgroundPoly
%--------------------------------------------------------------------------

% pmdInputStruct.backgroundPolyStruct.backgroundPoly fields
fieldsAndBounds = cell(13,4);
fieldsAndBounds(1,:)  = { 'offsetx';    [];     [];     '0'};
fieldsAndBounds(2,:)  = { 'scalex';     '>= 0'; [];     []};
fieldsAndBounds(3,:)  = { 'originx';    [];     [];     []};
fieldsAndBounds(4,:)  = { 'offsety';    [];     [];     '0'};
fieldsAndBounds(5,:)  = { 'scaley';     '>= 0'; [];     []};
fieldsAndBounds(6,:)  = { 'originy';    [];     []; 	[]};
fieldsAndBounds(7,:)  = { 'xindex';     [];     [];     '-1'};
fieldsAndBounds(8,:)  = { 'yindex';     [];     [];     '-1'};
fieldsAndBounds(9,:)  = { 'type';       [];     [];     {'standard'}};
fieldsAndBounds(10,:) = { 'order';      '>= 0'; '< 10'; []};
fieldsAndBounds(11,:) = { 'message';    [];     [];     {}};
fieldsAndBounds(12,:) = { 'coeffs';     [];     [];     []};    % TBD
fieldsAndBounds(13,:) = { 'covariance'; [];     [];     []};    % TBD

for j=1:nBackgroundPolys
    if ( pmdInputStruct.backgroundPolyStruct(j).backgroundPolyStatus )
        validate_structure(pmdInputStruct.backgroundPolyStruct(j).backgroundPoly, fieldsAndBounds, ['pmdInputStruct.backgroundPolyStruct(', num2str(j) ').backgroundPoly']);
    end
end

clear fieldsAndBounds;

%--------------------------------------------------------------------------
% second level validation.
% Validate the structure field pmdInputStruct.motionPolyStruct
%--------------------------------------------------------------------------

% pmdInputStruct.motionPolyStruct fields
fieldsAndBounds = cell(10,4);
fieldsAndBounds( 1,:)  = { 'cadence';               '>= -1';    '< 2e7';    [] };
fieldsAndBounds( 2,:)  = { 'mjdStartTime';          '>= -1';    '<= 64000'; [] };
fieldsAndBounds( 3,:)  = { 'mjdMidTime';            '>= -1';    '<= 64000'; [] };
fieldsAndBounds( 4,:)  = { 'mjdEndTime';            '>= -1';    '<= 64000'; [] };
fieldsAndBounds( 5,:)  = { 'module';                [];         [];         '[-1 2:4, 6:20, 22:24]''' };
fieldsAndBounds( 6,:)  = { 'output';                [];         [];         '[-1 1 2 3 4]''' };
fieldsAndBounds( 7,:)  = { 'rowPoly';               [];         [];         [] };                  % a structure
fieldsAndBounds( 8,:)  = { 'rowPolyStatus';         [];         [];         '[0 1]''' };
fieldsAndBounds( 9,:)  = { 'colPoly';               [];         [];         [] };                  % a structure
fieldsAndBounds(10,:)  = { 'colPolyStatus';         [];         [];         '[0 1]''' };

nMotionPolys = length(pmdInputStruct.motionPolyStruct);

for j = 1 : nMotionPolys
    validate_structure(pmdInputStruct.motionPolyStruct(j), fieldsAndBounds, ['pmdInputStruct.motionPolyStruct(' num2str(j) ')']);
end

clear fieldsAndBounds;

%--------------------------------------------------------------------------
% third level validation.
% Validate the structure field pmdInputStruct.motionPolyStruct.rowPoly and 
% pmdInputStruct.motionPolyStruct.colPoly
%--------------------------------------------------------------------------

% pmdInputStruct.motionPolyStruct.rowPoly   
% pmdInputStruct.motionPolyStruct.colPoly fields
fieldsAndBounds = cell(13,4);
fieldsAndBounds(1,:)  = { 'offsetx';    [];     [];     '0'};
fieldsAndBounds(2,:)  = { 'scalex';     '>= 0'; [];     []};
fieldsAndBounds(3,:)  = { 'originx';    [];     [];     []};
fieldsAndBounds(4,:)  = { 'offsety';    [];     [];     '0'};
fieldsAndBounds(5,:)  = { 'scaley';     '>= 0'; [];     []};
fieldsAndBounds(6,:)  = { 'originy';    [];     []; 	[]};
fieldsAndBounds(7,:)  = { 'xindex';     [];     [];     '-1'};
fieldsAndBounds(8,:)  = { 'yindex';     [];     [];     '-1'};
fieldsAndBounds(9,:)  = { 'type';       [];     [];     {'standard'}};
fieldsAndBounds(10,:) = { 'order';      '>= 0'; '< 10'; []};
fieldsAndBounds(11,:) = { 'message';    [];     [];     {}};
fieldsAndBounds(12,:) = { 'coeffs';     [];     [];     []};    % TBD
fieldsAndBounds(13,:) = { 'covariance'; [];     [];     []};    % TBD

for j=1:nMotionPolys
    if ( pmdInputStruct.motionPolyStruct(j).rowPolyStatus )
        validate_structure(pmdInputStruct.motionPolyStruct(j).rowPoly, fieldsAndBounds, ['pmdInputStruct.motionPolyStruct(', num2str(j) ').rowPoly']);
    end
    if ( pmdInputStruct.motionPolyStruct(j).colPolyStatus )
        validate_structure(pmdInputStruct.motionPolyStruct(j).colPoly, fieldsAndBounds, ['pmdInputStruct.motionPolyStruct(', num2str(j) ').colPoly']);
    end
end

clear fieldsAndBounds;

%--------------------------------------------------------------------------
% second level validation.
% Validate the structure field pmdInputStruct.ancillaryEngineeringParameters
%--------------------------------------------------------------------------
if ~isempty(pmdInputStruct.ancillaryEngineeringData)

    % pmdInputStruct.ancillaryEngineeringParameters fields
    fieldsAndBounds = cell(5,4);
    fieldsAndBounds(1,:)  = { 'mnemonics';                  [];         [];     {} };
    fieldsAndBounds(2,:)  = { 'modelOrders';                '>= 0';     '<= 5'; [] };
    fieldsAndBounds(3,:)  = { 'interactions';               [];         [];     {} };
    fieldsAndBounds(4,:)  = { 'quantizationLevels';         '>= 0';     [];     [] };   % TBD
    fieldsAndBounds(5,:)  = { 'intrinsicUncertainties';     '>= 0';     [];     [] };   % TBD

    validate_structure(pmdInputStruct.ancillaryEngineeringParameters, fieldsAndBounds, 'pmdInputStruct.ancillaryEngineeringParameters');

    clear fieldsAndBounds;

end

%--------------------------------------------------------------------------
% second level validation.
% Validate the structure field pmdInputStruct.ancillaryEngineeringData if it exists.
%--------------------------------------------------------------------------
if ~isempty(pmdInputStruct.ancillaryEngineeringData)
    
    % pmdInputStruct.ancillaryEngineeringData fields
    fieldsAndBounds = cell(3,4);
    fieldsAndBounds(1,:)  = { 'mnemonic';   [];         [];         {} };
    fieldsAndBounds(2,:)  = { 'timestamps'; '>= 54000'; '<= 64000'; [] };
    fieldsAndBounds(3,:)  = { 'values';     [];         [];         [] };           % TBD

    nAncillaryEngineeringData = length(pmdInputStruct.ancillaryEngineeringData);

    for j = 1 : nAncillaryEngineeringData
        validate_structure(pmdInputStruct.ancillaryEngineeringData(j), fieldsAndBounds, ...
            ['pmdInputStruct.ancillaryEngineeringData(' num2str(j) ')']);
    end
    
    clear fieldsAndBounds;

end % if

%--------------------------------------------------------------------------
% second level validation.
% Validate the structure field pmdInputStruct.ancillaryPipelinearameters
%--------------------------------------------------------------------------
if ~isempty(pmdInputStruct.ancillaryPipelineData)

    % pmdInputStruct.ancillaryPipelineParameters fields
    fieldsAndBounds = cell(3,4);
    fieldsAndBounds(1,:)  = { 'mnemonics';      [];     [];     {} };
    fieldsAndBounds(2,:)  = { 'modelOrders';    '>= 0'; '<= 5'; [] };
    fieldsAndBounds(3,:)  = { 'interactions';   [];     [];     {} };

    validate_structure(pmdInputStruct.ancillaryPipelineParameters, fieldsAndBounds, 'pmdInputStruct.ancillaryPipelineParameters');

    clear fieldsAndBounds;

end

%--------------------------------------------------------------------------
% second level validation.
% Validate the structure field pmdInputStruct.ancillaryPipelineData if it exists.
%--------------------------------------------------------------------------
if ~isempty(pmdInputStruct.ancillaryPipelineData)
    
    % pmdInputStruct.ancillaryPipelineData fields
    fieldsAndBounds = cell(4,4);
    fieldsAndBounds(1,:)  = { 'mnemonic';       [];         [];         {} };
    fieldsAndBounds(2,:)  = { 'timestamps';     '>= 54000'; '<= 64000'; [] };
    fieldsAndBounds(2,:)  = { 'timestamps';     [];         [];         [] };       % for test only!
    fieldsAndBounds(3,:)  = { 'values';         [];         [];         [] };       % TBD
    fieldsAndBounds(4,:)  = { 'uncertainties';  [];         [];         [] };       % TBD

    nAncillaryPipelineData = length(pmdInputStruct.ancillaryPipelineData);

    for j = 1 : nAncillaryPipelineData
        validate_structure(pmdInputStruct.ancillaryPipelineData(j), fieldsAndBounds, ['pmdInputStruct.ancillaryPipelineData(' num2str(j) ')']);
    end
    
    clear fieldsAndBounds;

end % if

%------------------------------------------------------------

return
