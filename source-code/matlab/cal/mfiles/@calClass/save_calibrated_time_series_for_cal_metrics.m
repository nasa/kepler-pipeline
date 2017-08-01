function [nSavedCalibratedSeries] = save_calibrated_time_series_for_cal_metrics(calObject, calOutputStruct)
% function [nSavedCalibratedSeries] = save_calibrated_time_series_for_cal_metrics(calObject, calOutputStruct)
%
% This calClass method is modeled after the function save_calibrated_time_series_for_computation_of_metrics. The difference here is that a
% separate file containing the calibrated time series for cal metrics is saved on each invocation. On the last invocation the saved output
% from all of the invocations is concatenated and the cal metrics state file is produced. This is intended to break the invocation order
% dependency for the CAL metrics.
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

stateFilePath = calObject.localFilenames.stateFilePath;

% Get required fields from input object and cal output structure.
firstCall = calObject.firstCall;
lastCall = calObject.lastCall;
invocation = calObject.calInvocationNumber;
twoDBlackIds = calObject.twoDBlackIds;
ldeUndershootIds = calObject.ldeUndershootIds;
targetAndBackgroundPixels = calOutputStruct.targetAndBackgroundPixels;

localFiles = calObject.localFilenames;
invocationFilename = localFiles.invocationMetricsFilename;
stateFilename = localFiles.calMetricsFilename;
rootFilename = [stateFilePath, localFiles.metricsRootFilename];

% initialize 2d balck and lde variables
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


% initialize the calibrated two-d black and lde undershoot series structures
% and set the number of saved calibrated pixel series to 0
calibratedSeriesStruct = struct( ...
    'row', [], ...
    'column', [], ...
    'values', [], ...
    'uncertainties', [], ...
    'gapIndicators', [] );

calibratedTwoDBlackSeries = repmat(struct( 'pixels', [], 'isFound', [] ), [1, nTwoDBlackIds]);
calibratedLdeUndershootSeries = repmat(struct( 'pixels', [], 'isFound', [] ), [1, nLdeUndershootIds]);
nSavedCalibratedSeries = 0;
   

% get [row, column] coordinates of calibrated target and background pixels
if nTargetAndBackgroundPixels > 0
    calibratedPixelCoords = [vertcat(targetAndBackgroundPixels.row) ...
        vertcat(targetAndBackgroundPixels.column)];
else
    calibratedPixelCoords = [];
end

% save calibrated two-d black series for later computation of two-d black metrics
for iTarget = 1 : nTwoDBlackIds

    twoDBlackId = twoDBlackIds(iTarget);
    twoDBlackIdCoords = [twoDBlackId.rows twoDBlackId.cols];
    nTwoDBlackPixels = size(twoDBlackIdCoords, 1);

    % initialize sub structure for this target
    calibratedTwoDBlackSeries(iTarget).pixels = repmat(calibratedSeriesStruct, [1, nTwoDBlackPixels]);

    [isFound, indxFound] = ismember(twoDBlackIdCoords, calibratedPixelCoords, 'rows');
    
    calibratedTwoDBlackSeries(iTarget).isFound = isFound;

    if any(isFound)
        pixels = targetAndBackgroundPixels(indxFound(isFound));
        pixels = orderfields(pixels, calibratedSeriesStruct);
        calibratedTwoDBlackSeries(iTarget).pixels(isFound) = pixels;
        nSavedCalibratedSeries = nSavedCalibratedSeries + sum(isFound);
    end
end

% save calibrated lde undershoot series for later computation of lde undershoot metrics
for iTarget = 1 : nLdeUndershootIds

    ldeUndershootId = ldeUndershootIds(iTarget);
    ldeUndershootIdCoords = [ldeUndershootId.rows ldeUndershootId.cols];
    nLdeUndershootPixels = size(ldeUndershootIdCoords, 1);
    
    % initialize sub structure for this target
    calibratedLdeUndershootSeries(iTarget).pixels = repmat(calibratedSeriesStruct, [1, nLdeUndershootPixels]);

    [isFound, indxFound] = ismember(ldeUndershootIdCoords, calibratedPixelCoords, 'rows');
    
    calibratedLdeUndershootSeries(iTarget).isFound = isFound;

    if any(isFound)
        pixels = targetAndBackgroundPixels(indxFound(isFound));
        pixels = orderfields(pixels, calibratedSeriesStruct);
        calibratedLdeUndershootSeries(iTarget).pixels(isFound) = pixels;
        nSavedCalibratedSeries = nSavedCalibratedSeries + sum(isFound);
    end
end


if ~lastCall
    % save to invocation file
    display(['     Saving calibrated time series for invocation ',num2str(invocation),' for cal metrics ...']);
    
    % clear warning message
    lastwarn('');
    % try to save under v7.0
    save([stateFilePath,invocationFilename], 'calibratedTwoDBlackSeries', ...
        'calibratedLdeUndershootSeries', 'twoDBlackCoords', ...
        'ldeUndershootCoords', 'nSavedCalibratedSeries');
    % if warning is issued and contains 'use the -v7.3 switch' re-save under v7.3
    if ~isempty(lastwarn) && ~isempty(strfind(lastwarn,'use the -v7.3 switch'))
        save('-v7.3', [stateFilePath, invocationFilename], 'calibratedTwoDBlackSeries', ...
            'calibratedLdeUndershootSeries', 'twoDBlackCoords', ...
            'ldeUndershootCoords', 'nSavedCalibratedSeries');
    end

else
    
    % If accumulated metrics state file already exists load return value and return out of function
    % This condition should only occur if the lastCall invocation crashed on the previous attempt after
    % the state file was written in this method and it is now being re-run
    if exist([stateFilePath, stateFilename],'file') == 2
        load([stateFilePath, stateFilename],'nSavedCalibratedSeries');
        return;
    end
    
    
    % concatenate current variables with those from all previous invocations and save to state file    
    display('     Concatenating calibrated time series across invocations for cal metrics ...');
    
    % save current invocation (which is the last invocation) output in temporary variables
    tempTwoDBlackTs     = calibratedTwoDBlackSeries;
    tempLdeTs           = calibratedLdeUndershootSeries;
    tempTwoDBlackCoords = twoDBlackCoords;
    tempLdeCoords       = ldeUndershootCoords;
    tempNumSavedSeries  = nSavedCalibratedSeries;
    
    % get output for the rest of the invocations
    for i = 0:(invocation - 1)
        
        % read 'em
        currentFile = [rootFilename,'_',num2str(i),'.mat'];
%         display(['     Loading ',currentFile,' ...']);
        load(currentFile);
        
        % update two-d black time series for target
        for iTarget = 1 : nTwoDBlackIds
            isFound = calibratedTwoDBlackSeries(iTarget).isFound;
            tempTwoDBlackTs(iTarget).pixels(isFound) = ...
                calibratedTwoDBlackSeries(iTarget).pixels(isFound);
            tempTwoDBlackTs(iTarget).isFound = tempTwoDBlackTs(iTarget).isFound | isFound;                
        end
        % update lde undershoot time series for target
        for iTarget = 1 : nLdeUndershootIds
            isFound = calibratedLdeUndershootSeries(iTarget).isFound;
            tempLdeTs(iTarget).pixels(isFound) = ...
                calibratedLdeUndershootSeries(iTarget).pixels(isFound);
            tempLdeTs(iTarget).isFound = tempLdeTs(iTarget).isFound | isFound;
        end
        
        % adjust running time series count
        tempNumSavedSeries = tempNumSavedSeries + nSavedCalibratedSeries;        
    end
        
    % copy temp variables for output to state file
    calibratedTwoDBlackSeries = tempTwoDBlackTs;                                                %#ok<*NASGU>
    calibratedLdeUndershootSeries = tempLdeTs;
    twoDBlackCoords = tempTwoDBlackCoords;
    ldeUndershootCoords = tempLdeCoords;
    nSavedCalibratedSeries = tempNumSavedSeries;
    
    % check consistancy
    if nSavedCalibratedSeries ~= nTotalTwoDBlackPixels + nTotalLdeUndershootPixels
    error('CAL:saveCalibratedTimeSeriesForComputationOfMetrics:incorrectNumberCalibratedSeries', ...
        'Incorrect number of calibrated pixel time series (%d vs %d)', ...
        nSavedCalibratedSeries, nTotalTwoDBlackPixels + nTotalLdeUndershootPixels)
    end
    
    
    % save to state file    
    % clear warning message
    lastwarn('');
    % try to save under v7.0
    save([stateFilePath, stateFilename], 'calibratedTwoDBlackSeries', ...
        'calibratedLdeUndershootSeries', 'twoDBlackCoords', ...
        'ldeUndershootCoords', 'nSavedCalibratedSeries');
    % if warning is issued and contains 'use the -v7.3 switch' re-save under v7.3
    if ~isempty(lastwarn) && ~isempty(strfind(lastwarn,'use the -v7.3 switch'))
        save('-v7.3', [stateFilePath, stateFilename], 'calibratedTwoDBlackSeries', ...
            'calibratedLdeUndershootSeries', 'twoDBlackCoords', ...
            'ldeUndershootCoords', 'nSavedCalibratedSeries');
    end
end

