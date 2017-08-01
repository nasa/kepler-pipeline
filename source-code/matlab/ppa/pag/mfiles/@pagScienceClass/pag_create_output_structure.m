function  [pagOutputStruct, pagTempStruct] = pag_create_output_structure(pagScienceObject)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function  [pagOutputStruct, pagTempStruct] = pag_create_output_structure(pagScienceObject)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% This function defines the pagOutputStruct.
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% INPUT:  The following arguments are specified for this function.
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
%             pagScienceObject: [object]  object instantiated from PAG input structure
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

nCadences       = length(pagScienceObject.cadenceTimes.midTimestamps);

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

report = struct( ...
    'theoreticalCompressionEfficiency', timeSeriesReport, ...
    'achievedCompressionEfficiency',    timeSeriesReport );

% Generate outputTsData structure
emptyTsStruct = struct( ...
    'values',                           -1*ones(nCadences, 1), ...
    'uncertainties',                    -1*ones(nCadences, 1), ...
    'gapIndicators',                    true(nCadences, 1) );

outputTsStruct = struct( ...
    'theoreticalCompressionEfficiency', emptyTsStruct, ...
    'achievedCompressionEfficiency',    emptyTsStruct );

% Generate pagOutputStruct

pagOutputStruct = struct( ...
    'outputTsData',                     outputTsStruct,             ...
    'report',                           report,               ...
    'reportFilename',                   '' );

% Generate pagTempStruct

emptyTempStruct = struct( ...
    'meanEstimates',                    [], ...
    'uncertaintyEstimates',             [], ...
    'estimatesGapIndicators',           [], ...
    'adaptiveBoundsXFactor',            -1 );


pagTempStruct = struct( ...
    'theoreticalCompressionEfficiency', emptyTempStruct, ...
    'achievedCompressionEfficiency',    emptyTempStruct );

return


