function targetStarStruct = clean_cosmic_ray_from_target(targetStarStruct, ...
    motionPolyStruct, cosmicRayConfigurationStruct)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function targetStarStruct = clean_cosmic_ray_from_target(targetStarStruct, ...
%     motionPolyStruct, cosmicRayConfigurationStruct)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% Entry point for the cleaning of cosmic rays from targets.  Clean cosmic
% rays from the pixels in each target from an array of  targets.  To clean
% cosmic rays from time series use clean_cosmic_ray_from_time_series()
%
% inputs: 
%   targetStarStruct(): 1D array of structures describing targets that contain
%   at least the following fields:
%       .pixelTimeSeriesStruct() # of pixels x 1 array of structures
%           descrbing pixels that contain the following fields:
%           .timeSeries() # of cadences x 1 array containing pixel brightness
%               time series.  
%           .gapList() # of gaps x 1 array containing the index of gaps in
%               .timeSeries
%           .row row of this pixel
%           .column column of this pixel
%       .referenceRow row relative to which the pixels in the target are
%           located, typically the row of the target centroid
%       .referenceColumn column relative to which the pixels in the target are
%           located, typically the column of the target centroid
%   motionPolyStruct(): possibly empty # of cadences array of structures,
%       one for each cadence, containing at least the following fields:
%       .rowCoeff, .columnCoeff: structures describing the row and column
%           motion across the module output as returned by
%           weighted_polyfit2d()
%   cosmicRayConfigurationStruct: structure containing various
%       configuration values as returned by build_cr_configuration_struct()
%
% output: adds the following fields to each element of targetStarStruct:
%   .partition() # of parts x 1 array of structures describing the partitioning
%       of the target's flux time series into sections which are
%       well-described by low-order polynomials.  See
%       partition_by_curvature() for contents.
%   adds to each element of pixelTimeSeriesStruct:
%       .crCleanedSeries() same as field .timeSeries with cosmic rays removed
%           from non-gap entries.  
%       .cosmicRayIndices() # of cosmic ray events x 1 array of indices in
%           .crCleanedSeries of cosmic ray events 
%       .cosmicRayDeltas() array of same size as .cosmicRayIndices containing
%           the change in values in .crCleanedSeries from .timeSeries so
%           .timeSeries(.cosmicRayIndices) =
%           .crCleanedSeries(.cosmicRayIndices) + .cosmicRayDeltas
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

% flag to indicate display of local results
displayResults = 0;

% get parameters we use from the configuration structure
curvaturePartitionOrder = cosmicRayConfigurationStruct.curvaturePartitionOrder; 
curvaturePartitionWindow = cosmicRayConfigurationStruct.curvaturePartitionWindow; 
curvaturePartitionThreshold = cosmicRayConfigurationStruct.curvaturePartitionThreshold; 
curvaturePartitionSmallestRegion = cosmicRayConfigurationStruct.curvaturePartitionSmallestRegion; 
reconstructionThreshold = cosmicRayConfigurationStruct.reconstructionThreshold; 
saturationValueThreshold = cosmicRayConfigurationStruct.saturationValueThreshold; 
dataGapFillOrder = cosmicRayConfigurationStruct.dataGapFillOrder;

% fill data gap fill structure with suggested default values
gapFillParametersStruct.MAD_X_FACTOR = 10;
gapFillParametersStruct.MAX_GIANT_TRANSIT_DURATION_IN_HOURS = 72;
gapFillParametersStruct.MAX_DETREND_POLY_ORDER = 25;
gapFillParametersStruct.MAX_AR_ORDER_LIMIT = 25;
gapFillParametersStruct.MAX_CORRELATION_WINDOW_X_FACTOR = 5;
gapFillParametersStruct.CADENCE_DURATION_IN_MINUTES = 30;
gapFillParametersStruct.GAP_FILL_MODE_IS_ADD_BACK_PREDICTION_ERROR = true;

% get the number of targets
nTargets = length(targetStarStruct);

% for each target clean the cosmic rays
for target = 1:nTargets

    % dereference this target structure
    targetStruct = targetStarStruct(target);
    % get the number of pixels in this target
    nPixels = length(targetStruct.pixelTimeSeriesStruct);
    % get the number of cadences, assumed to be the same for all pixels
    nCadences = length(targetStruct.pixelTimeSeriesStruct(1).timeSeries);
    % put the pixel time series for all pixels in a 2D array for convenience
    pixval = zeros(nPixels, nCadences);
    % do a little pre-processing on each pixel
    for pixel = 1:nPixels 
        % fill data gaps, which must be done before we can do partition by
        % curvature
        if ~isempty(targetStruct.pixelTimeSeriesStruct(pixel).gapList)
            gaps = zeros(size(targetStruct.pixelTimeSeriesStruct(pixel).timeSeries));
            gaps(targetStruct.pixelTimeSeriesStruct(pixel).gapList) = 1;
            [targetStruct.pixelTimeSeriesStruct(pixel).timeSeries, ...
                giantTransitIndex, longGapIndicators ] = ...
                fill_short_data_gaps( ...
                targetStruct.pixelTimeSeriesStruct(pixel).timeSeries, ...
                gaps, 0, gapFillParametersStruct);
        end

        pixval(pixel, :) = ...
            targetStruct.pixelTimeSeriesStruct(pixel).timeSeries;
    end
    % build time series of flags indicating when any pixel in the target is
    % in saturation 
    % later: get saturationValueThreshold from an FC function
    saturationSeries = any(pixval > saturationValueThreshold, 1)';
    % if flux is not a field of the target, create it but don't save it
    % since our flux is not robust in the presence of gaps
    if ~isfield(targetStruct, 'flux')
        targetStruct.flux = sum(pixval, 1); 
    end
    % use the target flux to determine a partition based on curvature,
    % which partitions the time series into regions well-described by
    % low-order polynomials.  This partition is then applied to each pixel
    % time series
    partition = partition_by_curvature(targetStruct.flux, ...
        curvaturePartitionOrder, curvaturePartitionWindow, ...
        curvaturePartitionThreshold, curvaturePartitionSmallestRegion);
    % save the partition in the return value
    targetStarStruct(target).partition = partition;
    % the number of partitions
    nPartitions = length(partition);
    
    % now clean the cosmic rays from each pixel
    for pixel = 1:nPixels
        % get the current pixel structure
        pixelStruct = targetStruct.pixelTimeSeriesStruct(pixel);
        % get the pixel's time series
        pixelSeries = pixelStruct.timeSeries;
        % get the pixel's uncertainties
        uncertainties = pixelStruct.uncertainties;
        % get the pixel's gap list
        gapList = pixelStruct.gapList;
        % get the row and column of this pixel
        row = pixelStruct.row;
        column = pixelStruct.column;
        % initialize return cosmic ray event data
        cosmicRayIndices = [];
        cosmicRayDeltas = [];
        % the following fields are returned for diagnostic purposes
        residual = zeros(nCadences, 1);
        cleanedResidual = zeros(nCadences, 1);
        cleanedSeries = zeros(nCadences, 1);
        trend = zeros(nCadences, 1);
        localSd = zeros(nCadences, 1);
        
        % we clean each partition separately
        for part = 1:nPartitions
            % compute the index range of this partition
            partitionRange = partition(part).start:partition(part).end;
            % get the gaps that fall in this partition
            gapsInRange = intersect(gapList, partitionRange)';
            % clean this part of the pixel time series 
            % be careful to transform the gap indices so they are indices
            % for this part 
            if isempty(motionPolyStruct)
                % if motion data is not available, pass an empty matrix
                [cleanedSeries(partitionRange), crEventStruct, fitStruct] = ...
                    clean_cosmic_ray_from_time_series(pixelSeries(partitionRange), ...
                    uncertainties(partitionRange), ...
                    gapsInRange - (partitionRange(1) - 1), ... 
                    saturationSeries(partitionRange), ...
                    row, column, [], cosmicRayConfigurationStruct);
            else
                % if motion data is available
                [cleanedSeries(partitionRange), crEventStruct, fitStruct] = ...
                    clean_cosmic_ray_from_time_series(pixelSeries(partitionRange), ...
                    uncertainties(partitionRange), ...
                    gapsInRange - (partitionRange(1) - 1), ...
                    saturationSeries(partitionRange), ...
                    row, column, motionPolyStruct(partitionRange), cosmicRayConfigurationStruct);
            end
            % construct the cosmic ray event return data for this pixel
            % transform the cosmic ray indices in this part back to pixel
            % time series indices
            if ~isempty(cosmicRayIndices)
                cosmicRayIndices = [cosmicRayIndices; crEventStruct.indices + partitionRange(1) - 1];
                cosmicRayDeltas = [cosmicRayDeltas; crEventStruct.deltas];
            end
            
            % fill in the following for diagnostic displayResults
            residual(partitionRange) = fitStruct.residual;
            cleanedResidual(partitionRange) = fitStruct.cleanedResidual;
            trend(partitionRange) = fitStruct.trend;
            localSd(partitionRange) = fitStruct.localSd;
        end % next part of partition
        
        % add the cosmic ray event data to this pixel of the output
        % structure
        targetStarStruct(target).pixelTimeSeriesStruct(pixel).crCleanedSeries = ...
            cleanedSeries;
        targetStarStruct(target).pixelTimeSeriesStruct(pixel).cosmicRayIndices = ...
            cosmicRayIndices;
        targetStarStruct(target).pixelTimeSeriesStruct(pixel).cosmicRayDeltas = ...
            cosmicRayDeltas;
            
        if displayResults
            % display various time series for the entire pixel time series
            figure;
            subplot(3,1,1);
            plot(1:nCadences, pixelSeries, 1:nCadences, ...
                targetStarStruct(target).pixelTimeSeriesStruct(pixel).crCleanedSeries);
            title(['pixel ' num2str(pixel)]);
            legend('original pixel series', 'cleaned time series', 'Location', 'EastOutside');
            subplot(3,1,2);
            plot(1:nCadences, residual, 1:nCadences, cleanedResidual);
            legend('original residual', 'cleaned residual', 'Location', 'EastOutside');
            subplot(3,1,3);
%             twindow = 81;
%             tstd = movstd(residual, twindow);
%             plot(1:nCadences, localSd, 1:nCadences, ...
%                 targetStarStruct(target).pixelTimeSeriesStruct(pixel).uncertainties, ...
%                 1:nCadences, tstd);
            plot(1:nCadences, localSd, 1:nCadences, ...
                targetStarStruct(target).pixelTimeSeriesStruct(pixel).uncertainties);
            title('local standard deviation');
        end
        % check the event data by reconstucting the input series
        if ~isempty(cosmicRayIndices)
            rebuiltSeries = cleanedSeries;
            rebuiltSeries(cosmicRayIndices) = cleanedSeries(cosmicRayIndices) + ...
                cosmicRayDeltas;
            if any(abs(pixelSeries - rebuiltSeries) > reconstructionThreshold)
                error('cosmic ray clean from target: rebuilt series wrong');
            end
        end
        % zero out the gaps since they were messed up by the cosmic ray
        % correction
        gapList = targetStarStruct(target).pixelTimeSeriesStruct(pixel).gapList;
        targetStarStruct(target).pixelTimeSeriesStruct(pixel).timeSeries(gapList) = 0;
    end % next pixel
    clear pixval;
end % next target
