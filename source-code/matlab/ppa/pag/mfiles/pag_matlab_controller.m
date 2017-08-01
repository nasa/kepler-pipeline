function pagOutputStruct = pag_matlab_controller(pagInputStruct)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function pagOutputStruct = pag_matlab_controller(pagInputStruct)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% This function forms the MATLAB side of the science interface for photometer
% performance assessment (PPA) : PMD aggregator (PAG). The function receives
% input via the pagInputStruct structure and generates output via the
% pagOutputStruct structure.
%
% It first calls the contructor for the pagScienceClass which also validates the
% fields of pagdInputStruct.
%
% Secondly it calculates the metric time series of theoretical and achieved
% compression efficiency of the full focal plane.
%
% Then it takes track and trend analysis on the compression efficiency metrics.
%
% Finally the reports of metric time series are generated. 
%
% PAG is performed once for all module/outputs.
%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% INPUT:  A data structure 'pagInputStruct' with the following fields:
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%   Top level
%
%     pagInputStruct contains the following fields:
%
%                             fcConstants: [struct]  Fc constants
%              spacecraftConfigMaps: [struct array]  one or more spacecraft config maps
%                            cadenceTimes: [struct]  cadence times and gap indicators
%                     pagModuleParameters: [struct]  module parameters for PAG
%                       inputTsData: [struct array]  compression efficiency metric time series of all module/outputs
%                           reports: [struct array]  reports of metric time series of all module/outputs
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
%     pagModuleParameters is a struct with the following fields:
%
%                       alertTime: [float]  number of days at the end of valid time duration for alert generation
%                     horizonTime: [float]  number of days for trend prediction
%                    trendFitTime: [float]  number of days at the end of valid time duration for trend fit
%       initialAverageSampleCount: [float]  number of samples for inititial average
%          minTrendFitSampleCount: [float]  minimum number of samples for trend fit
%      compressionSmoothingFactor: [float]  smoothing  factor of theoretical and achieved compression efficiency metrics
%      compressionFixedLowerBound: [float]  fixed lower bound of theoretical and achieved compression efficiency metrics
%      compressionFixedUpperBound: [float]  fixed upper bound of theoretical and achieved compression efficiency metrics
%      compressionAdaptiveXFactor: [float]  adaptive bound X factor of theoretical and achieved compression efficiency metrics
%                        debugLevel: [int]  debug level of PAG
%               plottingEnabled: [logical]  flag indicating plot is enabled
%
%--------------------------------------------------------------------------
%   Second level
%
%     inputTsData is an array of structs with the following fields:
%
%                                 ccdModule: [int]  CCD module number
%                                 ccdOutput: [int]  CCD output number
%       theoreticalCompressionEfficiency: [struct]  theoretical compression efficiency metric of the module/output
%          achievedCompressionEfficiency: [struct]  theoretical compression efficiency metric of the module/output
%
%               
%   Third level
%
%     theoreticalCompressionEfficiency
%     achievedCompressionEfficiency     are structs with the following fields:
%
%                          values: [float array]  values         of metric time series 
%                 gapIndicators: [logical array]  gap indicators of metric time series
%                      nCodeSymbols: [int array]  code symbols number time series
%
%--------------------------------------------------------------------------
%   Second level
%
%     reports is an array of structs (one for each module/output) with the following fields:
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
%     The report of a metric time series contains the following fields:
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
%  OUTPUT:  A data structure 'pagOutputStruct' with the following fields.
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%   Top level
%
%     pagOutputStruct contains the following fields:
%
%                   outputTsData: [struct]  output time series data
%                         report: [struct]  time series metric report
%                 reportFilename: [String]  filename of report
%
%--------------------------------------------------------------------------
%   Second level
%
%     outputTsData is a struct with the following fields:
%
%       theoreticalCompressionEfficiency: [struct]  theoretical compression efficiency metric of full focal plane
%          achievedCompressionEfficiency: [struct]  theoretical compression efficiency metric of full focal plane
%
%               
%   Third level
%
%     theoreticalCompressionEfficiency
%     achievedCompressionEfficiency     are structs with the following fields:
%
%                          values: [float array]  values         of metric time series 
%                 gapIndicators: [logical array]  gap indicators of metric time series
%               
%--------------------------------------------------------------------------
%   Second level
%
%     report is a struct with the following fields:
%
%     theoreticalCompressionEfficiency: [struct]  report of theoretical compression efficiency
%        achievedCompressionEfficiency: [struct]  report of achieved    compression efficiency
%
%  
%  Third level
%
%    theoreticalCompressionEfficiency and achievedCompressionEfficiency have the same structure
%    as the metric time series report defined for the PAG inputs.
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
pagScienceObject = pagScienceClass(pagInputStruct);

% create PAG output structure
[pagOutputStruct, pagTempStruct] = pag_create_output_structure(pagScienceObject);

% create PAG output time series structure
fprintf('\nPAG: Generate output time series ...\n');
pagOutputStruct = pag_generate_output_time_series(pagScienceObject, pagOutputStruct);

% PAG: track and trend
fprintf('\nPAG: Track and trend time series ...\n');
[pagOutputStruct, pagTempStruct] = pag_track_trend(pagScienceObject, pagOutputStruct, pagTempStruct);

% PAG: generate reports
if (pagInputStruct.pagModuleParameters.plottingEnabled)

    fprintf('\nPAG: Generate mission report ...\n');
    pagOutputStruct.reportFilename = pag_generate_report(pagScienceObject, pagInputStruct, pagOutputStruct);

end

return

