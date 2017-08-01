function [nSavedCalibratedSeries] = ...
    save_calibrated_time_series_for_computation_of_metrics(firstCall, lastCall, ...
    twoDBlackIds, ldeUndershootIds, targetAndBackgroundPixels, localFilenames)
% function [nSavedCalibratedSeries] = ...
%     save_calibrated_time_series_for_computation_of_metrics(firstCall, lastCall, ...
%     twoDBlackIds, ldeUndershootIds, targetAndBackgroundPixels, localFilenames)
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

% initialize variables
nTwoDBlackIds = length(twoDBlackIds);
nLdeUndershootIds = length(ldeUndershootIds);
nTargetAndBackgroundPixels = length(targetAndBackgroundPixels);

if nTwoDBlackIds > 0
    twoDBlackRows = vertcat(twoDBlackIds.rows);
    twoDBlackCols = vertcat(twoDBlackIds.cols);
    twoDBlackCoords = sortrows([twoDBlackRows twoDBlackCols]);
else
    twoDBlackCoords = [];
end

if nLdeUndershootIds > 0
    ldeUndershootRows = vertcat(ldeUndershootIds.rows);
    ldeUndershootCols = vertcat(ldeUndershootIds.cols);
    ldeUndershootCoords = sortrows([ldeUndershootRows ldeUndershootCols]);
else
    ldeUndershootCoords = [];
end

nTotalTwoDBlackPixels = size(twoDBlackCoords, 1);
nTotalLdeUndershootPixels = size(ldeUndershootCoords, 1);

stateFilename = [localFilenames.stateFilePath, localFilenames.calMetricsFilename];

% initialize the state if this is the first invocation, otherwise load
% the state from the state file
if firstCall

    % if the first invocation flag is set, initialize the calibrated two-d
    % black and lde undershoot series structures. Set the number of saved
    % calibrated pixel series to 0
    calibratedTwoDBlackSeries = repmat(struct( ...
        'pixels', [] ), [1, nTwoDBlackIds]);
    calibratedLdeUndershootSeries = repmat(struct( ...
        'pixels', [] ), [1, nLdeUndershootIds]);
    nSavedCalibratedSeries = 0;

else

    % load the state from the state file. Throw an error if the
    % state file does not exist
    twoDBlackCoordsIn = twoDBlackCoords;
    ldeUndershootCoordsIn = ldeUndershootCoords;

    if ~exist(stateFilename, 'file')
        error('CAL:saveCalibratedTimeSeriesForComputationOfMetrics:missingStateFile', ...
            'CAL state file is missing')
    end

    load(stateFilename, 'calibratedTwoDBlackSeries', ...
        'calibratedLdeUndershootSeries', 'twoDBlackCoords', ...
        'ldeUndershootCoords', 'nSavedCalibratedSeries');

    % perform invocation to invocation consistency checks
    if ~isempty(setxor(twoDBlackCoordsIn, twoDBlackCoords, 'rows'))
        error('CAL:saveCalibratedTimeSeriesForComputationOfMetrics:invalidInputParameter', ...
            'Inconsistent definition of two-d black ids');
    end

    if ~isempty(setxor(ldeUndershootCoordsIn, ldeUndershootCoords, 'rows'))
        error('CAL:saveCalibratedTimeSeriesForComputationOfMetrics:invalidInputParameter', ...
            'Inconsistent definition of lde undershoot ids');
    end

end

% get row, column coordinates of calibrated target and background pixels
if nTargetAndBackgroundPixels > 0
    calibratedPixelCoords = [vertcat(targetAndBackgroundPixels.row) ...
        vertcat(targetAndBackgroundPixels.column)];
else
    calibratedPixelCoords = [];
end

% save calibrated two-d black series for later computation of two-d black
% metrics
calibratedSeriesStruct = struct( ...
    'row', [], ...
    'column', [], ...
    'values', [], ...
    'uncertainties', [], ...
    'gapIndicators', [] );

for iTarget = 1 : nTwoDBlackIds

    twoDBlackId = twoDBlackIds(iTarget);
    twoDBlackIdCoords = [twoDBlackId.rows twoDBlackId.cols];
    nTwoDBlackPixels = size(twoDBlackIdCoords, 1);

    if isempty(calibratedTwoDBlackSeries(iTarget).pixels)
        calibratedTwoDBlackSeries(iTarget).pixels = ...
            repmat(calibratedSeriesStruct, [1, nTwoDBlackPixels]);
    end

    [isFound, indxFound] = ...
        ismember(twoDBlackIdCoords, calibratedPixelCoords, 'rows');

    if any(isFound)
        pixels = targetAndBackgroundPixels(indxFound(isFound));
        pixels = orderfields(pixels, calibratedSeriesStruct);
        calibratedTwoDBlackSeries(iTarget).pixels(isFound) = pixels;
        nSavedCalibratedSeries = nSavedCalibratedSeries + sum(isFound);
    end

end

% save calibrated lde undershoot series for later computation of lde
% undershoot metrics
for iTarget = 1 : nLdeUndershootIds

    ldeUndershootId = ldeUndershootIds(iTarget);
    ldeUndershootIdCoords = [ldeUndershootId.rows ldeUndershootId.cols];
    nLdeUndershootPixels = size(ldeUndershootIdCoords, 1);

    if isempty(calibratedLdeUndershootSeries(iTarget).pixels)
        calibratedLdeUndershootSeries(iTarget).pixels = ...
            repmat(calibratedSeriesStruct, [1, nLdeUndershootPixels]);
    end

    [isFound, indxFound] = ...
        ismember(ldeUndershootIdCoords, calibratedPixelCoords, 'rows');

    if any(isFound)
        pixels = targetAndBackgroundPixels(indxFound(isFound));
        pixels = orderfields(pixels, calibratedSeriesStruct);
        calibratedLdeUndershootSeries(iTarget).pixels(isFound) = pixels;
        nSavedCalibratedSeries = nSavedCalibratedSeries + sum(isFound);
    end

end

% perform one last check if this is the last invocation
if lastCall
    if nSavedCalibratedSeries ~= ...
            nTotalTwoDBlackPixels + nTotalLdeUndershootPixels
        error('CAL:saveCalibratedTimeSeriesForComputationOfMetrics:incorrectNumberCalibratedSeries', ...
            'Incorrect number of calibrated pixel time series (%d vs %d)', ...
            nSavedCalibratedSeries, ...
            nTotalTwoDBlackPixels + nTotalLdeUndershootPixels)
    end
end

% save the state
save( stateFilename, 'calibratedTwoDBlackSeries', ...
    'calibratedLdeUndershootSeries', 'twoDBlackCoords', ...
    'ldeUndershootCoords', 'nSavedCalibratedSeries');

return
