function padOutputStruct = pad_matlab_controller(padInputStruct)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function padOutputStruct = pad_matlab_controller(padInputStruct)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% This function forms the MATLAB side of the science interface for photometer
% performance assessment (PPA) : PPA attitude determination (PAD). The function
% receives input via the padInputStruct structure and generates output via the
% padOutputStruct structure.
%
% It first calls the constructor for the padScienceClass which also validates the
% fields of padInputStruct and converts the motion blob series to corresponding
% polynomial structure.
%
% Secondly reconstructed attitude solution is determined: a grid of fake target
% stars are selected for each module/output and the measured positions of
% target stars, given by (module, output, row, column), are calculated from 
% motion polynomials. Reconstructed attitude solution is determined by minimizing
% the sum of squared distances between the measured and expected positions of 
% target stars.
%
% Then it takes track and trend analysis on the differences between attitude 
% solution time series (ra, dec, roll) and the corresponding nominal values.
%
% Finally the report of delta attitude solution is generated. 
%
% PAD is performed once for all module/outputs.
%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% INPUT:  A data structure 'padInputStruct' with the following fields:
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%   Top level
%
%     padInputStruct contains the following fields:
%
%                            cadenceTimes: [struct]  cadence times and gap indicators
%                     padModuleParameters: [struct]  module parameters for PAD
%                             fcConstants: [struct]  focal plane constants
%              spacecraftConfigMaps: [struct array]  one or more spacecraft config maps
%                          raDec2PixModel: [struct]  ra-dec to pixel model
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
%     padModuleParameters is a struct with the following fields:
%
%                      gridRowStart: [int]  start of row    of grid for grid of fake target stars
%                        gridRowEnd: [int]  end   of row    of grid for grid of fake target stars
%                      gridColStart: [int]  start of column of grid for grid of fake target stars
%                        gridColEnd: [int]  end   of column of grid for grid of fake target stars
%                       alertTime: [float]  number of days at the end of valid time duration for alert generation
%                     horizonTime: [float]  number of days for trend prediction
%                    trendFitTime: [float]  number of days at the end of valid time duration for trend fit
%       initialAverageSampleCount: [float]  number of samples for inititial average
%          minTrendFitSampleCount: [float]  minimum number of samples for trend fit
%          deltaRaSmoothingFactor: [float]  smoothing  factor of delta ra
%          deltaRaFixedLowerBound: [float]  fixed lower bound of delta ra
%          deltaRaFixedUpperBound: [float]  fixed upper bound of delta ra
%          deltaRaAdaptiveXFactor: [float]  adaptive bound X factor of delta ra
%         deltaDecSmoothingFactor: [float]  smoothing  factor of delta dec 
%         deltaDecFixedLowerBound: [float]  fixed lower bound of delta dec
%         deltaDecFixedUpperBound: [float]  fixed upper bound of delta dec   
%         deltaDecAdaptiveXFactor: [float]  adaptive bound X factor of delta dec
%        deltaRollSmoothingFactor: [float]  smoothing  factor of delta roll  
%        deltaRollFixedLowerBound: [float]  fixed lower bound of delta roll 
%        deltaRollFixedUpperBound: [float]  fixed upper bound of delta roll
%        deltaRollAdaptiveXFactor: [float]  adaptive bound X factor of delta roll
%                        debugLevel: [int]  debug level of PAD
%               plottingEnabled: [logical]  flag indicating plot is enabled
%
%--------------------------------------------------------------------------
%   Second level
%
%     motionBlobs is blob series with the following fields:
%   
%           blobIndices: [float array]  blob indices
%       gapIndicators: [logical array]  blob gap indicators
%              blobFilenames: [string]  blob filenames
%                  startCadence: [int]  start cadence index
%                    endCadence: [int]  end   cadence index
%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%  OUTPUT:  A data structure 'padOutputStruct' with the following fields.
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

% invoke class constructor for padScienceClass
padScienceObject = padScienceClass(padInputStruct);

fprintf('\nPAD: Creating output structure ...\n');
[padOutputStruct, padTempStruct] = pad_create_output_structure(padScienceObject);

fprintf('\nPAD: Attitude reconstruction ...\n');
[padOutputStruct, nominalPointingStruct] = pad_attitude_reconstruction(padScienceObject, padOutputStruct);

fprintf('\nPAD: Track and trend delta attitude solution ...\n');
[padOutputStruct, padTempStruct] = pad_track_trend(padScienceObject, padOutputStruct, nominalPointingStruct, padTempStruct);

if (padInputStruct.padModuleParameters.plottingEnabled)
    fprintf('\nPAD: Generate report of delta attitude solution ...\n');
    padOutputStruct = pad_generate_track_trend_reports(padScienceObject, padOutputStruct, nominalPointingStruct, padTempStruct);

    fprintf('\nPAD: Generate mission report ...\n');
    padOutputStruct.reportFilename = pad_generate_report(padInputStruct, padOutputStruct);
end

return


