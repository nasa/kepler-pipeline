function [padOutputStruct, padTempStruct] = pad_create_output_structure(padScienceObject)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [padOutputStruct, padTempStruct] = pad_create_output_structure(padScienceObject)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% This function defines padOutputStruct.
%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Input:  
%
%             padScienceObject: [object]  object instantiated from PAD input structure
%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Outputs:
%
%              padOutputStruct: [struct]  PAD output structure
%                padTempStruct: [struct]  PAD temporary data structure
%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%   Top level
%
%     padOutputStruct contains the following fields:
%
%               attitudeSolution: [struct]  reconstructed attitude solution
%                         report: [struct]  report of delta attitude solution
%                 reportFilename: [String]  filename of report
%
%--------------------------------------------------------------------------
%   Second level
%
%     attitudeSolution is a struct with the following fields:
%
%                                 ra: [double array]  time series of ra
%                                dec: [double array]  time series of dec
%                               roll: [double array]  time series of roll
%                  covarianceMatrix11: [float array]  time series of covariance matrix element (1,1) 
%                  covarianceMatrix22: [float array]  time series of covariance matrix element (2,2) 
%                  covarianceMatrix33: [float array]  time series of covariance matrix element (3,3) 
%                  covarianceMatrix12: [float array]  time series of covariance matrix element (1,2) 
%                  covarianceMatrix13: [float array]  time series of covariance matrix element (1,3) 
%                  covarianceMatrix23: [float array]  time series of covariance matrix element (2,3) 
%       maxAttitudeFocalPlaneResidual: [float array]  time series of maximum attitude focal plane residual error
%                     gapIndicators: [logical array]  gap indicators of attitude solution time series 
%               
%--------------------------------------------------------------------------
%   Second level
%
%     report is a struct with the following fields:
%
%                        deltaRa: [struct]  report of delta ra
%                       deltaDec: [struct]  report of delta dec
%                      deltaRoll: [struct]  report of delta roll
% 
%--------------------------------------------------------------------------
%   Third level
%
%     The reports of deltaRa, deltaDec and deltaRoll contain the following fields:
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
%   Top level
%
%     padTempStruct contains the following fields:
%
%                       deltaRa: [struct]  temporary data of delta ra
%                      deltaDec: [struct]  temporary data of delta dec
%                     deltaRoll: [struct]  temporary data of delta roll
%
%--------------------------------------------------------------------------
%   Second level
%
%     The temporary data structures of deltaRa, deltaDec and deltaRoll contain the following fields:
%
%                  meanEstimates: [float array]  time series of mean estimates
%           uncertaintyEstimates: [float array]  time series of uncertainty estimates
%       estimatesGapIndicators: [logical array]  gap indicators of estimates
%                adpativeBoundsXFactor: [float]  X-factor to determine adaptive bounds
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


nCadences = length(padScienceObject.cadenceTimes.midTimestamps);

% Define attitudeSolution structure
s.ra                            = -1*ones(nCadences, 1);
s.dec                           = -1*ones(nCadences, 1);
s.roll                          = -1*ones(nCadences, 1);
s.covarianceMatrix11            = -1*ones(nCadences, 1);
s.covarianceMatrix22            = -1*ones(nCadences, 1);
s.covarianceMatrix33            = -1*ones(nCadences, 1);
s.covarianceMatrix12            = -1*ones(nCadences, 1);
s.covarianceMatrix13            = -1*ones(nCadences, 1);
s.covarianceMatrix23            = -1*ones(nCadences, 1);
s.maxAttitudeFocalPlaneResidual = -1*ones(nCadences, 1);
s.attitudeErrorPixels           = -1*ones(nCadences, 1);
s.gapIndicators                 =  true(nCadences, 1);

% Define report structure
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
    'trendFlag',                    false, ...
    'trendFitTime',                 [], ...
    'trendOffset',                  [], ...
    'trendSlope',                   [], ...
    'horizonTime',                  [] );

alertsStruct = struct( [] );
    
reportStruct = struct( ...
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

report.deltaRa   = reportStruct;
report.deltaDec  = reportStruct;
report.deltaRoll = reportStruct;

% Generate padOutputStruct
padOutputStruct = struct( ...
    'attitudeSolution',             s,                  ... 
    'report',                       report,             ...
    'reportFilename',               '');

emptyTempStruct = struct( ...
    'meanEstimates',                [], ...
    'uncertaintyEstimates',         [], ...
    'estimatesGapIndicators',       [], ...
    'adaptiveBoundsXFactor',        -1);

padTempStruct = struct( ...
    'deltaRa',                      emptyTempStruct, ...
    'deltaDec',                     emptyTempStruct, ...
    'deltaRoll',                    emptyTempStruct);


return

