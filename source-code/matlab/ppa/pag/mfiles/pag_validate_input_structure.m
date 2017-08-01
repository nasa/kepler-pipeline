function pag_validate_input_structure(pagInputStruct)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function  pag_validate_input_structure(pagInputStruct)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% This function first checks for the presence of expected fields in the input
% structure, then checks whether each parameter is within the appropriate
% range.
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
    error('PAG:validatePagInputStruct:EmptyInputStruct', ...
        'This function must be called with an input structure');
end


%______________________________________________________________________
% top level validation
% validate the top level fields in pagInputStruct
%______________________________________________________________________

% pagInputStruct fields
fieldsAndBounds = cell(6,4);

fieldsAndBounds( 1,:)  = { 'fcConstants';                    []; []; [] };      % structure, do not validate
fieldsAndBounds( 2,:)  = { 'spacecraftConfigMaps';           []; []; [] };      % structure array, do not validate
fieldsAndBounds( 3,:)  = { 'cadenceTimes';                   []; []; [] };      % structure 
fieldsAndBounds( 4,:)  = { 'pagModuleParameters';            []; []; [] };      % structure
fieldsAndBounds( 5,:)  = { 'inputTsData';                    []; []; [] };      % structure array
fieldsAndBounds( 6,:)  = { 'reports';                        []; []; [] };      % structure array

validate_structure(pagInputStruct, fieldsAndBounds, 'pagInputStruct');

clear fieldsAndBounds;

%--------------------------------------------------------------------------
% second level validation.
% validate the fields in pagInputStruct.cadenceTimes
%--------------------------------------------------------------------------

% pagInputStruct.cadenceTimes fields
fieldsAndBounds = cell(5,4);

fieldsAndBounds(1,:)   = { 'startTimestamps';   [];     []; 	[] };
fieldsAndBounds(2,:)   = { 'midTimestamps';     [];     [];     [] };
fieldsAndBounds(3,:)   = { 'endTimestamps';     [];     [];     [] };
fieldsAndBounds(4,:)   = { 'gapIndicators';     [];     [];     [true; false] };
fieldsAndBounds(5,:)   = { 'requantEnabled';    [];     [];     [true; false] };

validate_structure(pagInputStruct.cadenceTimes, fieldsAndBounds, 'pagInputStruct.cadenceTimes');

cadenceTimes = pagInputStruct.cadenceTimes;
cadenceTimes.startTimestamps = cadenceTimes.startTimestamps(~cadenceTimes.gapIndicators);
cadenceTimes.midTimestamps   = cadenceTimes.midTimestamps(~cadenceTimes.gapIndicators);
cadenceTimes.endTimestamps   = cadenceTimes.endTimestamps(~cadenceTimes.gapIndicators);

fieldsAndBounds = cell(3,4);

fieldsAndBounds(1,:)   = { 'startTimestamps';   '>= 54000';     '<= 64000'; 	[] };
fieldsAndBounds(2,:)   = { 'midTimestamps';     '>= 54000';     '<= 64000';     [] }; 
fieldsAndBounds(3,:)   = { 'endTimestamps';     '>= 54000';     '<= 64000';     [] };

validate_structure(cadenceTimes, fieldsAndBounds, 'pagInputStruct.cadenceTimes');

clear fieldsAndBounds;

%______________________________________________________________________
% second level validation
% validate the fields in pagInputStruct.pagModuleParameters  
%______________________________________________________________________

% pagInputStruct.pagModuleParameters fields
fieldsAndBounds = cell(11,4);

fieldsAndBounds( 1,:)  = { 'horizonTime';                                           '>= 0'; '<= 100';       [] }; 
fieldsAndBounds( 2,:)  = { 'trendFitTime';                                          '>= 0'; '<= 30';        [] };
fieldsAndBounds( 3,:)  = { 'minTrendFitSampleCount';                                '>= 0'; '<= 500';       [] };
fieldsAndBounds( 4,:)  = { 'initialAverageSampleCount';                             '>= 0'; '<= 500';       [] };
fieldsAndBounds( 5,:)  = { 'alertTime';                                             '>= 0'; '<= 30';        [] };

fieldsAndBounds( 6,:)  = { 'compressionSmoothingFactor';                            '>= 0'; '<= 1';         [] };
fieldsAndBounds( 7,:)  = { 'compressionFixedLowerBound';                            '>= 0'; '<= 20';        [] };  
fieldsAndBounds( 8,:)  = { 'compressionFixedUpperBound';                            '>= 0'; '<= 20';        [] };   
fieldsAndBounds( 9,:)  = { 'compressionAdaptiveXFactor';                            '>= 0'; '<= 100';       [] };   

fieldsAndBounds(10,:)  = { 'debugLevel';                                            '>= 0'; '<= 5';         [] };
fieldsAndBounds(11,:)  = { 'plottingEnabled';                                       [];     [];             [true false] };

validate_structure(pagInputStruct.pagModuleParameters, fieldsAndBounds, 'pagInputStruct.pagdModuleParameters');

clear fieldsAndBounds;

%______________________________________________________________________
% second level validation
% validate the fields in pagInputStruct.inputTsData  
%______________________________________________________________________

% pagInputStruct.inputTsData fields
fieldsAndBounds = cell(4,4);

fieldsAndBounds(1,:)  = { 'ccdModule';                          []; []; '[2:4, 6:20, 22:24]''' };
fieldsAndBounds(2,:)  = { 'ccdOutput';                          []; []; '[1 2 3 4]''' };
fieldsAndBounds(3,:)  = { 'theoreticalCompressionEfficiency';   []; []; [] }; 	% structure         
fieldsAndBounds(4,:)  = { 'achievedCompressionEfficiency';      []; []; [] };   % structure

for i=1:length(pagInputStruct.inputTsData)
    validate_structure(pagInputStruct.inputTsData(i), fieldsAndBounds, ['pagInputStruct.inputTsData(' num2str(i) ')']);
end

clear fieldsAndBounds;

%______________________________________________________________________
% third level validation
% validate the fields in pagInputStruct.inputTsData.theoreticalCompressionEfficiency
%                        pagInputStruct.inputTsData.achievedCompressionEfficiency
%______________________________________________________________________

% pagInputStruct.inputTsData.compressionEfficiency fields
fieldsAndBounds = cell(3,4);

fieldsAndBounds(1,:)  = { 'values';         [];     [];     []};                % TBD
fieldsAndBounds(2,:)  = { 'gapIndicators';  [];     [];     [true, false]};
fieldsAndBounds(3,:)  = { 'nCodeSymbols';   [];     [];     []};                % TBD

for i=1:length(pagInputStruct.inputTsData)
    validate_structure(pagInputStruct.inputTsData(i).theoreticalCompressionEfficiency,  fieldsAndBounds, ...
        ['pagInputStruct.inputTsData(' num2str(i) '.theoreticalCompressionEfficiency']);
    validate_structure(pagInputStruct.inputTsData(i).achievedCompressionEfficiency,     fieldsAndBounds, ...
        ['pagInputStruct.inputTsData(' num2str(i) '.achievedCompressionEfficiency'   ]);
end

clear fieldsAndBounds;

%______________________________________________________________________
% second level validation
% validate the fields in pagInputStruct.reports
%______________________________________________________________________

% pagInputStruct.reports fields 
fieldsAndBounds = cell(23,4);

fieldsAndBounds( 1,:) = { 'ccdModule';                          []; []; '[2:4, 6:20, 22:24]''' };
fieldsAndBounds( 2,:) = { 'ccdOutput';                          []; []; '[1 2 3 4]''' };
fieldsAndBounds( 3,:) = { 'blackLevel';                         []; []; [] }; % structure
fieldsAndBounds( 4,:) = { 'smearLevel';                         []; []; [] }; % structure
fieldsAndBounds( 5,:) = { 'darkCurrent';                        []; []; [] }; % structure
fieldsAndBounds( 6,:) = { 'twoDBlack';                          []; []; [] }; % structure array
fieldsAndBounds( 7,:) = { 'ldeUndershoot';                      []; []; [] }; % structure array
fieldsAndBounds( 8,:) = { 'theoreticalCompressionEfficiency';   []; []; [] }; % structure
fieldsAndBounds( 9,:) = { 'achievedCompressionEfficiency';      []; []; [] }; % structure
fieldsAndBounds(10,:) = { 'blackCosmicRayMetrics';              []; []; [] }; % structure
fieldsAndBounds(11,:) = { 'maskedSmearCosmicRayMetrics';        []; []; [] }; % structure
fieldsAndBounds(12,:) = { 'virtualSmearCosmicRayMetrics';       []; []; [] }; % structure
fieldsAndBounds(13,:) = { 'targetStarCosmicRayMetrics';         []; []; [] }; % structure
fieldsAndBounds(14,:) = { 'backgroundCosmicRayMetrics';         []; []; [] }; % structure
fieldsAndBounds(15,:) = { 'brightness';                         []; []; [] }; % structure
fieldsAndBounds(16,:) = { 'encircledEnergy';                    []; []; [] }; % structure
fieldsAndBounds(17,:) = { 'backgroundLevel';                    []; []; [] }; % structure
fieldsAndBounds(18,:) = { 'centroidsMeanRow';                   []; []; [] }; % structure
fieldsAndBounds(19,:) = { 'centroidsMeanColumn';                []; []; [] }; % structure
fieldsAndBounds(20,:) = { 'plateScale';                         []; []; [] }; % structure
fieldsAndBounds(21,:) = { 'cdppMeasured';                       []; []; [] }; % structure
fieldsAndBounds(22,:) = { 'cdppExpected';                       []; []; [] }; % structure
fieldsAndBounds(23,:) = { 'cdppRatio';                          []; []; [] }; % structure

nReports = length(pagInputStruct.reports);
for i=1:nReports
    validate_structure(pagInputStruct.reports(i), fieldsAndBounds, ['pagInputStruct.reports(' num2str(i) ')']);
end

clear fieldsAndBounds;

%______________________________________________________________________
% third level validation
% validate the fields in pagInputStruct.reports.blackCosmicRayMetrics
%                        pagInputStruct.reports.maskedSmearCosmicRayMetrics
%                        pagInputStruct.reports.virtualSmearCosmicRayMetrics
%                        pagInputStruct.reports.targetStarCosmicRayMetrics
%                        pagInputStruct.reports.backgroundCosmicRayMetrics
%______________________________________________________________________

crString      = { 'blackCosmicRayMetrics', 'maskedSmearCosmicRayMetrics', 'virtualSmearCosmicRayMetrics' ...
                  'targetStarCosmicRayMetrics', 'backgroundCosmicRayMetrics' };
crFieldString = { 'hitRate', 'meanEnergy', 'energyVariance', 'energySkewness', 'energyKurtosis' };        

% pagInputStruct.reports.cosmicRayMetrics fields
fieldsAndBounds = cell(5,4);
fieldsAndBounds( 1,:)  = { 'hitRate';           []; []; [] };   % structure
fieldsAndBounds( 2,:)  = { 'meanEnergy';        []; []; [] };   % structure
fieldsAndBounds( 3,:)  = { 'energyVariance';    []; []; [] };   % structure
fieldsAndBounds( 4,:)  = { 'energySkewness';    []; []; [] };   % structure
fieldsAndBounds( 5,:)  = { 'energyKurtosis';    []; []; [] };   % structure

for i=1:nReports
    for iCr=1:length(crString)
        validate_structure(pagInputStruct.reports(i).(crString{iCr}),           fieldsAndBounds, ...
            ['pagInputStruct.reports(' num2str(i) ').' crString{iCr}       ]);
    end
end

clear fieldsAndBounds;

%______________________________________________________________________
% third level validation
% validate the fields in pagInputStruct.reports.cdppMeasured
%                        pagInputStruct.reports.cdppExpected
%                        pagInputStruct.reports.cdppRatio
%______________________________________________________________________

magString  = {'mag9', 'mag10', 'mag11', 'mag12', 'mag13', 'mag14', 'mag15'};
hourString = {'threeHour', 'sixHour', 'twelveHour'};

% pagInputStruct.reports.cdppMetrics fields
fieldsAndBounds = cell(7,4);
fieldsAndBounds( 1,:)  = { 'mag9';              []; []; [] };   % structure
fieldsAndBounds( 2,:)  = { 'mag10';             []; []; [] };   % structure
fieldsAndBounds( 3,:)  = { 'mag11';             []; []; [] };   % structure
fieldsAndBounds( 4,:)  = { 'mag12';             []; []; [] };   % structure
fieldsAndBounds( 5,:)  = { 'mag13';             []; []; [] };   % structure
fieldsAndBounds( 6,:)  = { 'mag14';             []; []; [] };   % structure
fieldsAndBounds( 7,:)  = { 'mag15';             []; []; [] };   % structure

for i=1:nReports
    validate_structure(pagInputStruct.reports(i).cdppMeasured, fieldsAndBounds, ['pagInputStruct.reports(' num2str(i) ').cdppMeasured']);
    validate_structure(pagInputStruct.reports(i).cdppExpected, fieldsAndBounds, ['pagInputStruct.reports(' num2str(i) ').cdppExpected']);
    validate_structure(pagInputStruct.reports(i).cdppRatio,    fieldsAndBounds, ['pagInputStruct.reports(' num2str(i) ').cdppRatio'   ]);
end

clear fieldsAndBounds;

%______________________________________________________________________
% fourth level validation
% validate the fields in pagInputStruct.reports.cdppMeasured.magN (N=9,10,11,12,13,14,15)
%                        pagInputStruct.reports.cdppExpected.magN
%                        pagInputStruct.reports.cdppRatio.magN
%______________________________________________________________________

% pagInputStruct.reports.cdppMetrics fields
fieldsAndBounds = cell(3,4);
fieldsAndBounds( 1,:)  = { 'threeHour';         []; []; [] };   % structure
fieldsAndBounds( 2,:)  = { 'sixHour';           []; []; [] };   % structure
fieldsAndBounds( 3,:)  = { 'twelveHour';        []; []; [] };   % structure

for i=1:nReports
    for iMag=1:length(magString)
        validate_structure(pagInputStruct.reports(i).cdppMeasured.(magString{iMag}),  fieldsAndBounds, ...
            ['pagInputStruct.reports(' num2str(i) ').cdppMeasured.' magString{iMag} ]);
        validate_structure(pagInputStruct.reports(i).cdppExpected.(magString{iMag}),  fieldsAndBounds, ...
            ['pagInputStruct.reports(' num2str(i) ').cdppExpected.' magString{iMag} ]);
        validate_structure(pagInputStruct.reports(i).cdppRatio.(magString{iMag}),     fieldsAndBounds, ...
            ['pagInputStruct.reports(' num2str(i) ').cdppRatio.'    magString{iMag} ]);
    end
end

clear fieldsAndBounds;

%______________________________________________________________________
% third/fourth/fifth level validation
% validate the fields in pagInputStruct.reports.blackLevel
%                        pagInputStruct.reports.smearLevel
%                        pagInputStruct.reports.darkCurrent
%                        pagInputStruct.reports.theoreticalCompressionEfficiency
%                        pagInputStruct.reports.achievedCompressionEfficiency
%                        pagInputStruct.reports.brightness
%                        pagInputStruct.reports.encircledEnergy
%                        pagInputStruct.reports.backgroundLevel
%                        pagInputStruct.reports.centroidsMeanRow
%                        pagInputStruct.reports.centroidsMeanColumn
%                        pagInputStruct.reports.centroidsPlateScale
%                        pagInputStruct.reports.twoDBlack
%                        pagInputStruct.reports.ldeUndershoot
%                        pagInputStruct.reports.blackCosmicRayMetrics.crField 
%                        pagInputStruct.reports.maskedSmearCosmicRayMetrics.crField
%                        pagInputStruct.reports.virtualSmearCosmicRayMetrics.crField
%                        pagInputStruct.reports.targetStarCosmicRayMetrics.crField
%                        pagInputStruct.reports.backgroundCosmicRayMetrics.crField
%                        pagInputStruct.reports.cdppMeasured.magField.hourField
%                        pagInputStruct.reports.cdppExpected.magField.hourField
%                        pagInputStruct.reports.cdppRatio.magField.hourField
%
% Note:  crField   = {'hitRate', 'meanEnergy', 'energyVariance', 'energySkewness', 'energyKurtosis' } 
%        magField  = {'mag9', 'mag10', 'mag11', 'mag12', 'mag13', 'mag14', 'mag15'}
%        hourField = {'threeHour', 'sixHour', 'twelveHour'}
%______________________________________________________________________

% pagInputStruct.reports.metrics fields
fieldsAndBounds = cell(11,4);
fieldsAndBounds( 1,:)  = { 'time';                  '>= -1';    '<= 64000'; [] };   
fieldsAndBounds( 2,:)  = { 'value';                 [];         [];         [] };   % TBD
fieldsAndBounds( 3,:)  = { 'meanValue';             [];         [];         [] };   % TBD
fieldsAndBounds( 4,:)  = { 'uncertainty';           [];         [];         [] };   % TBD
fieldsAndBounds( 5,:)  = { 'adaptiveBoundsXFactor'; '>= -1';    '<= 10';    [] };
fieldsAndBounds( 6,:)  = { 'trackAlertLevel';       [];         [];         '[-1 0 1 2]''' };
fieldsAndBounds( 7,:)  = { 'trendAlertLevel';       [];         [];         '[-1 0 1 2]''' };
fieldsAndBounds( 8,:)  = { 'adaptiveBoundsReport';  [];         [];         [] };   % structure
fieldsAndBounds( 9,:)  = { 'fixedBoundsReport';     [];         [];         [] };   % structure
fieldsAndBounds(10,:)  = { 'trendReport';           [];         [];         [] };   % structure
fieldsAndBounds(11,:)  = { 'alerts';                [];         [];         [] };   % structure

for i=1:nReports

    validate_structure(pagInputStruct.reports(i).blackLevel,                        fieldsAndBounds, ...
        ['pagInputStruct.reports(' num2str(i) ').blackLevel'                      ]);
    validate_structure(pagInputStruct.reports(i).smearLevel,                        fieldsAndBounds, ...
        ['pagInputStruct.reports(' num2str(i) ').smearLevel'                      ]);
    validate_structure(pagInputStruct.reports(i).darkCurrent,                       fieldsAndBounds, ...
        ['pagInputStruct.reports(' num2str(i) ').darkCurrent'                     ]);

    validate_structure(pagInputStruct.reports(i).theoreticalCompressionEfficiency,  fieldsAndBounds, ...
        ['pagInputStruct.reports(' num2str(i) ').theoreticalCompressionEfficiency']);
    validate_structure(pagInputStruct.reports(i).achievedCompressionEfficiency,     fieldsAndBounds, ...
        ['pagInputStruct.reports(' num2str(i) ').achievedCompressionEfficiency'   ]);

    validate_structure(pagInputStruct.reports(i).brightness,                        fieldsAndBounds, ...
        ['pagInputStruct.reports(' num2str(i) ').brightness'                      ]);
    validate_structure(pagInputStruct.reports(i).encircledEnergy,                   fieldsAndBounds, ...
        ['pagInputStruct.reports(' num2str(i) ').encircledEnergy'                 ]);

    validate_structure(pagInputStruct.reports(i).backgroundLevel,                   fieldsAndBounds, ...
        ['pagInputStruct.reports(' num2str(i) ').backgroundLevel'                 ]);
    validate_structure(pagInputStruct.reports(i).centroidsMeanRow,                  fieldsAndBounds, ...
        ['pagInputStruct.reports(' num2str(i) ').centroidsMeanRow'                ]);
    validate_structure(pagInputStruct.reports(i).centroidsMeanColumn,               fieldsAndBounds, ...
        ['pagInputStruct.reports(' num2str(i) ').centroidsMeanColumn'             ]);
    validate_structure(pagInputStruct.reports(i).plateScale,                        fieldsAndBounds, ...
        ['pagInputStruct.reports(' num2str(i) ').plateScale'                      ]);
    
    nTwoDBlack = length(pagInputStruct.reports(i).twoDBlack);
    for iTwoDBlack=1:nTwoDBlack
        validate_structure(pagInputStruct.reports(i).twoDBlack(iTwoDBlack),         fieldsAndBounds, ...
            ['pagInputStruct.reports(' num2str(i) ').twoDBlack('     num2str(iTwoDBlack) ')'    ]);
    end
    nLdeUndershoot = length(pagInputStruct.reports(i).ldeUndershoot);
    for iLdeUndershoot=1:nLdeUndershoot
        validate_structure(pagInputStruct.reports(i).ldeUndershoot(iLdeUndershoot), fieldsAndBounds, ...
            ['pagInputStruct.reports(' num2str(i) ').ldeUndershoot(' num2str(iLdeUndershoot) ')']);
    end

    for iCr=1:length(crString)
        for iCrField=1:length(crFieldString)
        validate_structure(pagInputStruct.reports(i).(crString{iCr}).(crFieldString{iCrField}), fieldsAndBounds, ...
            ['pagInputStruct.reports(' num2str(i) ').' crString{iCr}, '.' crFieldString{iCrField}]);
        end
    end

    for iMag=1:length(magString)
        for iHour=1:length(hourString)
            validate_structure(pagInputStruct.reports(i).cdppMeasured.(magString{iMag}).(hourString{iHour}), fieldsAndBounds, ...
                ['pagInputStruct.reports(' num2str(i) ').cdppMeasured.' magString{iMag} '.' hourString{iHour}]);
            validate_structure(pagInputStruct.reports(i).cdppExpected.(magString{iMag}).(hourString{iHour}), fieldsAndBounds, ...
                ['pagInputStruct.reports(' num2str(i) ').cdppExpected.' magString{iMag} '.' hourString{iHour}]);
            validate_structure(pagInputStruct.reports(i).cdppRatio.(magString{iMag}).(hourString{iHour}),    fieldsAndBounds, ...
                ['pagInputStruct.reports(' num2str(i) ').cdppRatio.' magString{iMag}    '.' hourString{iHour}]);
        end
    end


end

clear fieldsAndBounds;

%------------------------------------------------------------

return
