function [cleanedSeries, crEventStruct, fitStruct] = ...
    clean_cosmic_ray_from_time_series(timeSeries, uncertainties, ...
    gapIndices, saturationSeries, ...
    row, column, motionPolyStruct, cosmicRayConfigurationStruct)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [cleanedSeries, crEventStruct, fitStruct] = ...
%     clean_cosmic_ray_from_time_series(timeSeries, gapIndices, saturationSeries, ...
%     row, column, motionPolyStruct, cosmicRayConfigurationStruct)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% Entry point for the cleaning of cosmic rays from time series.  Clean cosmic
% rays from the pixels in each target from an array of  targets.  To clean
% cosmic rays from targets use clean_cosmic_ray_from_targets()
%
% inputs: 
%   timeSeries() # of cadences x 1 array containing pixel brightness
%       time series.  Gaps are assumed to have been filled
%   gapIndices() # of gaps x 1 array containing the index of gaps in
%       timeSeries
%   saturationSeries() # of gaps x 1 array containing a logical flag.
%       If this flag is non-zero the cosmic ray identification
%       threshold is increased
%   row, column row and column of this pixel in CCD module output coordinates
%   motionPolyStruct(): possibly empty # of cadences array of structures,
%       one for each cadence, containing at least the following fields:
%       .rowCoeff, .columnCoeff: structures describing the row and column
%           motion across the module output as returned by
%           weighted_polyfit2d()
%   cosmicRayConfigurationStruct: structure containing various
%       configuration values as returned by build_cr_configuration_struct()
%
% output: 
%   cleanedSeries() same as field .timeSeries with cosmic rays removed
%       from non-gap entries.
%	crEventStruct structure describing cosmic ray events with the
%       following fields:
%       .indices() # of cosmic ray events x 1 array of indices in
%           .cleanedSeries of cosmic ray events 
%       .deltas() array of same size as .indices containing
%           the change in values in cleanedSeries from timeSeries so
%           timeSeries(.indices) =
%           cleanedSeries(.indices) + .deltas
%   fitStruct structure containing results of the detrend polynomial fits,
%       returned for diagnostic purposes, which contains the following
%       fields:
%       .trend(): size of timeSeries array containing the trends removed from
%           timeSeries
%       .residual(): size of timeSeries array containing the residual
%           remaining after the trend is removed from timeSeries
%       .cleanedResidual(): size of timeSeries array containing the residual
%           after cosmic ray cleaning
%       .localSd(): size of timeSeries array containing the local standard
%           deviation of the residual
%
%   See also CLEAN_COSMIC_RAY_FROM_TARGET, DETREND_TIME_SERIES,
%   BUILD_CR_CONFIGURATION_STRUCT WEIGHTED_POLYFIT2D, WEIGHTED_POLYVAL2D,
%   FAST_LOCAL_STANDARD_DEVIATION
%
% 
% Copyright 2017 United States Government as represented by the
% Administrator of the National Aeronautics and Space Administration.
% All Rights Reserved.
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

% flag to indicate display of local results
displayResults = 0;

% get parameters we use from the configuration structure
threshold = cosmicRayConfigurationStruct.threshold; 
saturationThresholdMultiplier = cosmicRayConfigurationStruct.saturationThresholdMultiplier;

% detrend the input time series
fitStruct = detrend_time_series(timeSeries, row, column, motionPolyStruct, ...
    cosmicRayConfigurationStruct);
% pick out the residual and trend
residual = fitStruct.residual;
trend = fitStruct.trend;

% compute a local clean (suppressing outliers) average and standard deviation
[localSd, cleanAverage] = compute_clean_local_sd(residual, cosmicRayConfigurationStruct);
% make sure the local uncertainty does not go below the estimated
% uncertainty for this pixel
if ~isempty(uncertainties)
    sdTooLow = find(localSd < uncertainties);
    localSd(sdTooLow) = uncertainties(sdTooLow);
end
% magnify the standard deviation of any cadence flagged by saturationSeries
% (intended to raise threshold whenever any pixel in an aperture is near
% saturation)
localSd = localSd.*(saturationSeries*saturationThresholdMultiplier + 1);
% identify large positive outliers as a cosmic ray event
crEventIndices = find(residual > threshold*localSd);
% if the result is empty really set it to empty to avoid shape strangeness
% (in the above case shape(crEventIndices) = 1x0 when crEventIndices is
% empty)
if isempty(crEventIndices)
    crEventIndices = [];
end
% take out cosmic ray events that occured in in gaps
crEventIndices = setdiff(crEventIndices, gapIndices);
% prepare output series
cleanedResidual = residual;
% replace cosmic ray events with local average
cleanedResidual(crEventIndices) = cleanAverage(crEventIndices);
% set the return cleaned time series
cleanedSeries = cleanedResidual + trend;

% set up the cosmic ray event structure
crEventStruct.indices = crEventIndices;
crEventStruct.deltas = timeSeries(crEventIndices) - cleanedSeries(crEventIndices);

% add a couple useful diagnostic fields to fitStruct
fitStruct.cleanedResidual = cleanedResidual;
fitStruct.localSd = localSd;

% we're done at this point

if displayResults
    % display various time series for the input time series, which may be a
    % single partition
    gapResidual = residual;
    % draw gaps offset from the series so they are obvious
    gapResidual(gapIndices) = - 10*std(residual);
    nCadences = length(timeSeries);
    figure;
    subplot(4,1,1);
    plot(1:nCadences, timeSeries, 1:nCadences, trend, 1:nCadences, cleanedSeries);
    legend('original time series', 'trend', 'cleaned time series', 'Location', 'EastOutside');
    subplot(4,1,2);
    plot(1:nCadences, residual, 1:nCadences, gapResidual, 1:nCadences, cleanedResidual);
    legend('original residual', 'residual with gaps', 'cleaned residual', 'Location', 'EastOutside');
    subplot(4,1,3);
    plot(localSd);
    title('local standard deviation');
    subplot(4,1,4);
    plot(cleanAverage);
    title('local clean average');
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function [localSd, cleanAverage] = compute_clean_local_sd(timeSeries, ...
%     cosmicRayConfigurationStruct)
%
% compute the local average and standard deviation supressing outliers
% through an iterative process
%
%   inputs: 
%       timeSeries() 1D time series array
%       cosmicRayConfigurationStruct: structure containing various
%       	configuration values as returned by build_cr_configuration_struct()
%
%   output: 
%       cleanAverage() local average of the intput timeSeries%
%       localSd() local standard deviation intput timeSeries
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [localSd, cleanAverage] = compute_clean_local_sd(timeSeries, ...
    cosmicRayConfigurationStruct)

% get parameters we use from the configuration structure
threshold = cosmicRayConfigurationStruct.threshold; 
localSdWindow = 2*cosmicRayConfigurationStruct.localSdWindow+1; 
localSdIterations = cosmicRayConfigurationStruct.localSdIterations;

% compute local standard deviation and average by iterating and removing
% isolated large positive outliers (cosmic rays) with each iteration
series = timeSeries; % copy so we leave timeSeries intact
% compute a fast, efficient local average and standard deviation (cannot be
% weighted)
[localSd, cleanAverage] = fast_local_standard_deviation(timeSeries, localSdWindow);
% now iterate to suppress positive outliers
for i=1:localSdIterations
    % find positive outliers
    outlierIndices = find(series > threshold*localSd);
    % replace them with the local average
    series(outlierIndices) = cleanAverage(outlierIndices);
    % get the new local average and standard deviation
    [localSd, cleanAverage] = fast_local_standard_deviation(series, localSdWindow);
end


