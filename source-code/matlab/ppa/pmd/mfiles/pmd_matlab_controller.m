function pmdOutputStruct = pmd_matlab_controller(pmdInputStruct)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function pmdOutputStruct = pmd_matlab_controller(pmdInputStruct)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% This function forms the MATLAB side of the science interface for photometer
% performance assessment (PPA) : PPA metrics determination (PMD). The function
% receives input via the pmdInputStruct structure and generates output via the
% pmdOutputStruct structure.
%
% It first calls the contructor for the pmdScienceClass which also validates the
% fields of pmdInputStruct and converts the background and motion blob series 
% to corresponding polynomial structure.
%
% Secondly it calculates the metrics time series of background level, centroids
% mean row, centroids mean column, plate scale, CDPP measured, CDPP
% expected and CDPP ratio, which are stored in outputTsData struct of
% pmdOutputStruct.
%
% Then it takes track and trend analysis on metrics time series.
%
% Finally the reports of track and trend are generated. 
%
% PMD is performed in multiple runs, one for each module/output.
%
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
%                    backgroundBlobs: [blob series]  background polynomials 
%                        motionBlobs: [blob series]  motion polynomials 
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
%--------------------------------------------------------------------------
%   Second level
%
%     backgroundBlobs
%     motionBlobs       are blob series with the following fields:
%   
%           blobIndices: [float array]  blob indices
%       gapIndicators: [logical array]  blob gap indicators
%              blobFilenames: [string]  blob filenames
%                  startCadence: [int]  start cadence index
%                    endCadence: [int]  end   cadence index
%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%  OUTPUT:  A data structure 'pmdOutputStruct' with the following fields.
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%   Top level
%
%     pmdOutputStruct contains the following fields:
%
%                         ccdModule: [int]  CCD module number
%                         ccdOutput: [int]  CCD output number
%                   outputTsData: [struct]  output time series data
%                         report: [struct]  time series metric report
%                 reportFilename: [String]  filename of report
%
%--------------------------------------------------------------------------
%   Second level
%
%     outputTsData is a struct with the following fields:
%
%               backgroundLevel: [struct]  background level      metric time series 
%              centroidsMeanRow: [struct]  centroids mean row    metric time series 
%           centroidsMeanColumn: [struct]  centroids mean column metric time series 
%                    plateScale: [struct]  plate scale           metric time series 
%                  cdppMeasured: [struct]  CDPP measured         metric time series 
%                  cdppExpected: [struct]  CDPP expected         metric time series 
%                     cdppRatio: [struct]  CDPP ratio            metric time series 
%               
%   Third level 
%
%     backgroundLevel
%     centroidsMeanRow
%     centroidsMeanColumn
%     plateScale            are structs with the following fields:
%
%                          values: [float array]  values         of metric time series 
%                 gapIndicators: [logical array]  gap indicators of metric time series 
%                   uncertainties: [float array]  uncertainties  of metric time series 
%               
%   Third level 
%
%     cdppMeasured
%     cdppExpected
%     cdppRatio     are structs with the following fields:
%
%                   mag9:  [struct]  CDPP metrics of Mag  9 target stars  
%                   mag10: [struct]  CDPP metrics of Mag 10 target stars  
%                   mag11: [struct]  CDPP metrics of Mag 11 target stars  
%                   mag12: [struct]  CDPP metrics of Mag 12 target stars  
%                   mag13: [struct]  CDPP metrics of Mag 13 target stars  
%                   mag14: [struct]  CDPP metrics of Mag 14 target stars  
%                   mag15: [struct]  CDPP metrics of Mag 15 target stars  
%
%   Fourth level 
%
%     mag9
%     mag10
%     mag11
%     mag12
%     mag13
%     mag14
%     mag15 are structs with the following fields:
%
%             threeHour:  [struct]  CDPP  3 hour metric time series   
%               sixHour:  [struct]  CDPP  6 hour metric time series   
%            twelveHour:  [struct]  CDPP 12 hour metric time series   
%
%   Fifth level 
%
%     threeHour
%     sixHour
%     twelveHour are structs with the following fields:
%
%                          values: [float array]  values         of metric time series 
%                 gapIndicators: [logical array]  gap indicators of metric time series 
%                   uncertainties: [float array]  uncertainties  of metric time series 
%               
%--------------------------------------------------------------------------
%   Second level
%
%     report is a struct with the following fields:
%
%                           blackLevel: [struct]  report  of black level  metric
%                           smearLevel: [struct]  report  of smear level  metric
%                          darkCurrent: [struct]  report  of dark current metric
%                      twoDBlack: [struct array]  reports of two-D black    targets metrics
%                  ldeUndershoot: [struct array]  reports of LDE undershoot targets metrics
%     theoreticalCompressionEfficiency: [struct]  report of theoretical compression efficiency
%        achievedCompressionEfficiency: [struct]  report of achieved    compression efficiency
%                blackCosmicRayMetrics: [struct]  reports of cosmic ray metrics of black         pixels
%          maskedSmearCosmicRayMetrics: [struct]  reports of cosmic ray metrics of masked  smear pixels
%         virtualSmearCosmicRayMetrics: [struct]  reports of cosmic ray metrics of virtual smear pixels
%           targetStarCosmicRayMetrics: [struct]  reports of cosmic ray metrics of target star   pixels
%           backgroundCosmicRayMetrics: [struct]  reports of cosmic ray metrics of background    pixels
%                           brightness: [struct]  report  of brightness            metric
%                      encircledEnergy: [struct]  report  of encircled energy      metric
%                      backgroundLevel: [struct]  report  of background level      metric
%                     centroidsMeanRow: [struct]  report  of centroids mean row    metric
%                  centroidsMeanColumn: [struct]  report  of centroids mean column metric
%                           plateScale: [struct]  report  of plate scale           metric
%                         cdppExpected: [struct]  report of CDPP expected          metric
%                         cdppMeasured: [struct]  report of CDPP measured          metric
%                            cdppRatio: [struct]  report of CDPP ratio             metric
% 
%   Third level
%
%     blackCosmicRayMetrics
%     maskedSmearCosmicRayMetrics
%     virtualSmearCosmicRayMetrics
%     targetStarCosmicRayMetrics
%     backgroundCosmicRayMetrics    are structs with the following fields:
%
%                  hitRate: [struct]  report of cosmic ray hit rate
%               meanEnergy: [struct]  report of cosmic ray mean energy
%           energyVariance: [struct]  report of cosmic ray energy variance
%           energySkewness: [struct]  report of cosmic ray energy skewness
%           energyKurtosis: [struct]  report of cosmic ray energy kurtosis
%
%   Third level
%
%     cdppExpected
%     cdppMeasured
%     cdppRatio     are structs with the following fields:
%
%            mag9:  [struct]  report of CDPP metrics of mag  9 target stars
%            mag10: [struct]  report of CDPP metrics of mag 10 target stars
%            mag11: [struct]  report of CDPP metrics of mag 11 target stars
%            mag12: [struct]  report of CDPP metrics of mag 12 target stars
%            mag13: [struct]  report of CDPP metrics of mag 13 target stars
%            mag14: [struct]  report of CDPP metrics of mag 14 target stars
%            mag15: [struct]  report of CDPP metrics of mag 15 target stars
%
%   Fourth level
%
%     mag9
%     mag10
%     mag11
%     mag12
%     mag13
%     mag14
%     mag15 are structs with the following fields:
%
%           threeHour: [struct]  report of CDPP  3 hour metric
%             sixHour: [struct]  report of CDPP  6 hour metric
%          twelveHour: [struct]  report of CDPP 12 hour metric
%
%--------------------------------------------------------------------------
%   Third/Fourth/Fifth level
%
%     The report of a time series metric contains the following fields:
%
%                          time: [double]  time tag for value (MJD)
%                          value: [float]  value of metric at specified time (typically last valid sample of metric)
%                      meanValue: [float]  estimated mean value of metric at specified time (typically last valid sample of metric)
%                    uncertainty: [float]  estimated uncertainty of metric at specified time (typically last valid sample of metric)
%          adpativeBoundsXFactor: [float]  X-factor to determine adaptive bounds
%                  trackAlertLevel: [int]  track alert level (-1: no data, 0: within adaptive and fixed bounds, 
%                                                              1: beyond adaptive bounds, 2: beyond fixed bounds)
%                  trendAlertLevel: [int]  trend alert level (-1: no data, 0: within adaptive and fixed bounds, 
%                                                              1: beyond adaptive bounds, 2: beyond fixed bounds)
%          adaptiveBoundsReport: [struct]  adaptive bounds tracking and trending report
%             fixedBoundsReport: [struct]  fixed bounds tracking and trending report
%                   trendReport: [struct]  trending report
%                  alerts: [struct array]  alerts to operator
%
%     adaptiveBoundsReport
%     fixedBoundsReport     are structs with the following fields:
%
%                     upperBound: [float]  upper bound
%                     lowerBound: [float]  lower bound
%              outOfUpperBound: [logical]  metric out of upper bound at report time 
%              outOfLowerBound: [logical]  metric out of lower bound at report time
%            outOfUpperBoundsCount: [int]  count of metric samples exceeding upper bound
%            outOfLowerBoundsCount: [int]  count of metric samples exceeding lower bound
%   outOfUpperBoundsTimes: [double array]  times that metric has exceeded upper bound (MJD)
%   outOfLowerBoundsTimes: [double array]  times that metric has exceeded lower bound (MJD)
%   outOfUpperBoundsValues: [float array]  metric values exceeding upper bound
%   outOfLowerBoundsValues: [float array]  metric values exceeding lower bound
%    upperBoundsCrossingXFactors: [float]  X factors of metric values exceeding upper bound
%    lowerBoundsCrossingXFactors: [float]  X factors of metric values exceeding lower bound
%  upperBoundCrossingPredicted: [logical]  true if trend in metric crosses upper bound within horizon time
%  lowerBoundCrossingPredicted: [logical]  true if trend in metric crosses lower bound within horizon time
%                  crossingTime: [double]  predicted bound crossing time (MJD)
%
%     trendReport is a struct with the following fields:
%
%                   trendValid: [logical]  flag indicating trend report is valid/invalid when true/false
%                   trendFitTime: [float]  time interval in which data are used for trending analysis
%                    trendOffset: [float]  offset of linear trending 
%                     trendSlope: [float]  slope of linear trending
%                    horizonTime: [flaot]  time interval in which crossing adaptive and fixed bounds is predicted
%
%     alerts is an array of structs with the following fields:
%
%                          time: [double]  time of alert to operator (MJD); same as time of last valid metric sample
%                      severity: [string]  'error' or 'warning'
%                       message: [string]  error or warning message
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


% invoke class constructor for pmdScienceClass
pmdScienceObject = pmdScienceClass(pmdInputStruct);

% create PMD output structure
[pmdOutputStruct, pmdTempStruct] = pmd_create_output_structure(pmdScienceObject);

% create PMD output time series structure
fprintf('\nPMD: Generate output time series ...\n');
pmdOutputStruct = pmd_generate_output_time_series(pmdScienceObject, pmdOutputStruct);

% PMD: track and trend
fprintf('\nPMD: Track and trend time series ...\n');
[pmdOutputStruct, pmdTempStruct] = pmd_track_trend(pmdScienceObject, pmdOutputStruct, pmdTempStruct);

% PMD: generate track and trend reports
if (pmdInputStruct.pmdModuleParameters.plottingEnabled)
    fprintf('\nPMD: Generate track and trend reports ...\n');
    pmdOutputStruct = pmd_generate_track_trend_reports(pmdScienceObject, pmdOutputStruct, pmdTempStruct);
end

% Generate the report and return its file name in the output structure
fprintf('\nPMD: Generate mission report ...\n');
pmdOutputStruct.reportFilename = pmd_generate_report(...
    pmdInputStruct, pmdOutputStruct, pmdTempStruct);

% Validate PMD output structure
fprintf('\nPMD: Validate PMD output structure ...\n');
pmdOutputStruct = pmd_validate_output_structure(pmdOutputStruct);


return

