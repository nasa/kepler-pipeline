function backgroundStruct = clean_cosmic_ray_from_background(backgroundStruct, ...
    cosmicRayConfigurationStruct)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function backgroundStruct = clean_cosmic_ray_from_background(backgroundStruct, ...
%     cosmicRayConfigurationStruct)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% Entry point for the cleaning of cosmic rays from background pixels.  
%
% inputs: 
%   backgroundStruct(): 1D array of structures describing background pixels
%   that contain at least the following fields:
%   	.timeSeries() # of cadences x 1 array containing pixel brightness
%               time series.  
%   	.gapList() # of gaps x 1 array containing the index of gaps in
%               .timeSeries
%    	.row, column row, column of this pixel in CCD coordinates
%   cosmicRayConfigurationStruct: structure containing various
%       configuration values as returned by build_cr_configuration_struct()
%
% output: adds the following fields to each element of backgroundStruct:
%   .timeSeries is returned with gaps filled
%	.crCleanedSeries() same as field .timeSeries with cosmic rays removed
%       from non-gap entries.  
%	.cosmicRayIndices() # of cosmic ray events x 1 array of indices in
%       .crCleanedSeries of cosmic ray events 
%	.cosmicRayDeltas() array of same size as .cosmicRayIndices containing
%       the change in values in .crCleanedSeries from .timeSeries so
%       .timeSeries(.cosmicRayIndices) =
%       .crCleanedSeries(.cosmicRayIndices) + .cosmicRayDeltas
%
%   See also CLEAN_COSMIC_RAY_FROM_TIME_SERIES, PARTITION_BY_CURVATURE,
%   BUILD_CR_CONFIGURATION_STRUCT WEIGHTED_POLYFIT2D, WEIGHTED_POLYVAL2D
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

% flag to indicate displayResults of local results
displayResults = 0;

% get parameters we use from the configuration structure
dataGapFillOrder = cosmicRayConfigurationStruct.dataGapFillOrder;

% get the # of background pixels
nPixels = length(backgroundStruct);

% fill data gap fill structure with suggested default values
gapFillParametersStruct.MAD_X_FACTOR = 10;
gapFillParametersStruct.MAX_GIANT_TRANSIT_DURATION_IN_HOURS = 72;
gapFillParametersStruct.MAX_DETREND_POLY_ORDER = 25;
gapFillParametersStruct.MAX_AR_ORDER_LIMIT = 25;
gapFillParametersStruct.MAX_CORRELATION_WINDOW_X_FACTOR = 5;
gapFillParametersStruct.CADENCE_DURATION_IN_MINUTES = 30;
gapFillParametersStruct.GAP_FILL_MODE_IS_ADD_BACK_PREDICTION_ERROR = true;

% for each pixel clean the cosmic rays
for pixel = 1:nPixels
    % fill data gaps
    gaps = zeros(size(backgroundStruct(pixel).timeSeries));
    gaps(backgroundStruct(pixel).gapList) = 1;
    [backgroundStruct(pixel).timeSeries, ...
        giantTransitIndex, longGapIndicators ] = ...
        fill_short_data_gaps( ...
        backgroundStruct(pixel).timeSeries, ...
        gaps, 0, gapFillParametersStruct);

    % get the pixel series
    pixelSeries = backgroundStruct(pixel).timeSeries;
    % clean the pixel series at this row and column without motion data
    [cleanedSeries, crEventStruct, fitStruct] = ...
        clean_cosmic_ray_from_time_series(pixelSeries, [], ...
        backgroundStruct(pixel).gapList, 0, ...
        backgroundStruct(pixel).row, backgroundStruct(pixel).column, [], ...
        cosmicRayConfigurationStruct);
    
    % add the cosmic ray event data to this pixel of the output structure
    backgroundStruct(pixel).crCleanedSeries = cleanedSeries;
    backgroundStruct(pixel).cosmicRayIndices = crEventStruct.indices;
    backgroundStruct(pixel).cosmicRayDeltas = crEventStruct.deltas;

    % check the event data by reconstucting the input series
    rebuiltSeries = cleanedSeries;
    rebuiltSeries(crEventStruct.indices) = cleanedSeries(crEventStruct.indices) + ...
        crEventStruct.deltas;
    if any(abs(pixelSeries - rebuiltSeries) > ...
            cosmicRayConfigurationStruct.reconstructionThreshold)
        error('cosmic ray clean from background: rebuilt series wrong');
    end

    if displayResults
        nCadences = length(backgroundStruct(1).timeSeries);
        display(['found ' num2str(length(crEventStruct.indices)) ...
            ' cosmic rays or ' num2str(100*length(crEventStruct.indices)/(pi*(nCadences/48))) ...
            ' percent']);

        figure;
        subplot(3,1,1);
        plot(1:nCadences, backgroundStruct(pixel).timeSeries, 1:nCadences, ...
            backgroundStruct(pixel).crCleanedSeries);
        subplot(3,1,2);
        plot(1:nCadences, fitStruct.residual, 1:nCadences, fitStruct.cleanedResidual);
        subplot(3,1,3);
        plot(fitStruct.localSd);
    end
end
