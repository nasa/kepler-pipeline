function  [pmdOutputStruct, pmdTempStruct] = pmd_create_output_structure(pmdScienceObject)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function  [pmdOutputStruct, pmdTempStruct] = pmd_create_output_structure(pmdScienceObject)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% This function defines the pmdOutputStruct.
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% INPUT:  The following arguments are specified for this function.
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
%             pmdScienceObject: [object]  object instantiated from PPA input structure
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


nCadences       = length(pmdScienceObject.cadenceTimes.midTimestamps);
nTwoDBlack      = length(pmdScienceObject.inputTsData.twoDBlack);
nLdeUndershoot  = length(pmdScienceObject.inputTsData.ldeUndershoot);

% Define report structure of time series metric
boundsStruct = struct( ...
    'outOfUpperBound',              false, ...
    'outOfLowerBound',              false, ...
    'outOfUpperBoundsCount',        0, ...
    'outOfLowerBoundsCount',        0, ...
    'outOfUpperBoundsTimes',        [], ...
    'outOfLowerBoundsTimes',        [], ...
    'outOfUpperBoundsValues',       [], ...
    'outOfLowerBoundsValues',       [], ...
    'upperBoundsCrossingXFactors',  [], ...
    'lowerBoundsCrossingXFactors',  [], ...
    'upperBound',                   -1, ...
    'lowerBound',                   -1, ...
    'upperBoundCrossingPredicted',  false, ...
    'lowerBoundCrossingPredicted',  false, ...
    'crossingTime',                 -1 );

trendStruct = struct( ...
    'trendValid',                   false, ...
    'trendFitTime',                 -1, ...
    'trendOffset',                  -1, ...
    'trendSlope',                   -1, ...
    'horizonTime',                  -1 );

alertsStruct = struct( [] );
   
timeSeriesReport = struct( ...
    'time',                         -1, ...
    'value',                        -1, ...
    'meanValue',                    -1, ...
    'uncertainty',                  -1, ...
    'adaptiveBoundsXFactor',        -1, ...
    'trackAlertLevel',              -1, ...
    'trendAlertLevel',              -1, ...
    'adaptiveBoundsReport',         boundsStruct, ...
    'fixedBoundsReport',            boundsStruct, ...
    'trendReport',                  trendStruct, ...
    'alerts',                       alertsStruct );

% Generate the report per ccd module/output

cosmicRayReport = struct( ...
    'hitRate',                          timeSeriesReport, ...
    'meanEnergy',                       timeSeriesReport, ...
    'energyVariance',                   timeSeriesReport, ...
    'energySkewness',                   timeSeriesReport, ...
    'energyKurtosis',                   timeSeriesReport );

cdppMagReport = struct( ...
    'threeHour',                        timeSeriesReport, ...
    'sixHour',                          timeSeriesReport, ...
    'twelveHour',                       timeSeriesReport );

cdppReport = struct( ...
    'mag9',                             cdppMagReport, ...
    'mag10',                            cdppMagReport, ...
    'mag11',                            cdppMagReport, ...
    'mag12',                            cdppMagReport, ...
    'mag13',                            cdppMagReport, ...
    'mag14',                            cdppMagReport, ...
    'mag15',                            cdppMagReport );

modOutReport = struct( ...
    'blackLevel',                       timeSeriesReport, ...
    'smearLevel',                       timeSeriesReport, ...
    'darkCurrent',                      timeSeriesReport, ...
    'twoDBlack',                        repmat(timeSeriesReport, 1, nTwoDBlack),      ...
    'ldeUndershoot',                    repmat(timeSeriesReport, 1, nLdeUndershoot),  ...
    'theoreticalCompressionEfficiency', timeSeriesReport, ...
    'achievedCompressionEfficiency',    timeSeriesReport, ...
    'blackCosmicRayMetrics',            cosmicRayReport, ...
    'maskedSmearCosmicRayMetrics',      cosmicRayReport, ...
    'virtualSmearCosmicRayMetrics',     cosmicRayReport, ...
    'targetStarCosmicRayMetrics',       cosmicRayReport, ...
    'backgroundCosmicRayMetrics',       cosmicRayReport, ...
    'brightness',                       timeSeriesReport, ...
    'encircledEnergy',                  timeSeriesReport, ...
    'backgroundLevel',                  timeSeriesReport, ...
    'centroidsMeanRow',                 timeSeriesReport, ...
    'centroidsMeanColumn',              timeSeriesReport, ...
    'plateScale',                       timeSeriesReport, ...
    'cdppMeasured',                     cdppReport, ...
    'cdppExpected',                     cdppReport, ...
    'cdppRatio',                        cdppReport );

% Generate outputTsData structure

emptyTsStruct = struct( ...
    'values',                           -1*ones(nCadences, 1), ...
    'uncertainties',                    -1*ones(nCadences, 1), ...
    'gapIndicators',                    true(nCadences, 1) );

emptyCdppMagStruct = struct( ...
    'threeHour',                        emptyTsStruct, ...
    'sixHour',                          emptyTsStruct, ...
    'twelveHour',                       emptyTsStruct );

emptyCdppStruct = struct( ...
    'mag9',                             emptyCdppMagStruct, ...
    'mag10',                            emptyCdppMagStruct, ...
    'mag11',                            emptyCdppMagStruct, ...
    'mag12',                            emptyCdppMagStruct, ...
    'mag13',                            emptyCdppMagStruct, ...
    'mag14',                            emptyCdppMagStruct, ...
    'mag15',                            emptyCdppMagStruct );
    
outputTsStruct = struct( ...
    'backgroundLevel',                  emptyTsStruct, ...
    'centroidsMeanRow',                 emptyTsStruct, ...
    'centroidsMeanColumn',              emptyTsStruct, ...
    'plateScale',                       emptyTsStruct, ...
    'cdppMeasured',                     emptyCdppStruct, ... 
    'cdppExpected',                     emptyCdppStruct, ...
    'cdppRatio',                        emptyCdppStruct );

% Generate pmdOutputStruct

pmdOutputStruct = struct( ...
    'ccdModule',                        pmdScienceObject.ccdModule, ...
    'ccdOutput',                        pmdScienceObject.ccdOutput, ...
    'outputTsData',                     outputTsStruct,             ...
    'report',                           modOutReport,               ...
    'reportFilename',                   '' );


% Generate pmdTempStruct

emptyTempStruct = struct( ...
    'meanEstimates',                    [], ...
    'uncertaintyEstimates',             [], ...
    'estimatesGapIndicators',           [], ...
    'adaptiveBoundsXFactor',            -1 );

cosmicRayTempStruct = struct( ...
    'hitRate',                          emptyTempStruct, ...
    'meanEnergy',                       emptyTempStruct, ...
    'energyVariance',                   emptyTempStruct, ...
    'energySkewness',                   emptyTempStruct, ...
    'energyKurtosis',                   emptyTempStruct );

cdppMagTempStruct = struct( ...
    'threeHour',                        emptyTempStruct, ...
    'sixHour',                          emptyTempStruct, ...
    'twelveHour',                       emptyTempStruct );

cdppTempStruct = struct( ...
    'mag9',                             cdppMagTempStruct, ...
    'mag10',                            cdppMagTempStruct, ...
    'mag11',                            cdppMagTempStruct, ...
    'mag12',                            cdppMagTempStruct, ...
    'mag13',                            cdppMagTempStruct, ...
    'mag14',                            cdppMagTempStruct, ...
    'mag15',                            cdppMagTempStruct );

pmdTempStruct = struct( ...
    'blackLevel',                       emptyTempStruct, ...
    'smearLevel',                       emptyTempStruct, ...
    'darkCurrent',                      emptyTempStruct, ...
    'twoDBlack',                        repmat(emptyTempStruct, 1, nTwoDBlack),      ...
    'ldeUndershoot',                    repmat(emptyTempStruct, 1, nLdeUndershoot),  ...
    'theoreticalCompressionEfficiency', emptyTempStruct, ...
    'achievedCompressionEfficiency',    emptyTempStruct, ...
    'blackCosmicRayMetrics',            cosmicRayTempStruct, ...
    'maskedSmearCosmicRayMetrics',      cosmicRayTempStruct, ...
    'virtualSmearCosmicRayMetrics',     cosmicRayTempStruct, ...
    'targetStarCosmicRayMetrics',       cosmicRayTempStruct, ...
    'backgroundCosmicRayMetrics',       cosmicRayTempStruct, ...
    'brightness',                       emptyTempStruct, ...
    'encircledEnergy',                  emptyTempStruct, ...
    'backgroundLevel',                  emptyTempStruct, ...
    'centroidsMeanRow',                 emptyTempStruct, ...
    'centroidsMeanColumn',              emptyTempStruct, ...
    'plateScale',                       emptyTempStruct, ...
    'cdppMeasured',                     cdppTempStruct, ...
    'cdppExpected',                     cdppTempStruct, ...
    'cdppRatio',                        cdppTempStruct);

return

