function [ldeUndershootMetrics] = ...
    compute_lde_undershoot_metrics(moduleParametersStruct, ldeUndershootIds, ...
    virtualSmearStartRow, cadenceGapIndicators, stateFilename, debugLevel)
% function [ldeUndershootMetrics] = ...
% compute_lde_undershoot_metrics(moduleParametersStruct, ldeUndershootIds, ...
% virtualSmearStartRow, cadenceGapIndicators, stateFilename, debugLevel)
%
% Compute lde undershoot metrics for all lde undershoot targets on a
% cadence by cadence basis. The metric is defined as the ratio of the
% magnitude of the corrected undershoot to the magnitude of the step directly
% preceding it. The ratio is specified in units of percent. If the value of
% the metric is positive, the undershoot has been un- or under-corrected; if
% negative it has been over-corrected.
%
% INPUT:  The following arguments must be provided to this function.
%
%
%           moduleParametersStruct: [struct]  CAL module parameters
%           ldeUndershootIds: [struct array]  definitions of undershoot targets
%                virtualSmearStartRow: [int]  first row (1-based) for virtual smear
%      cadenceGapIndicators: [logical array]  indicators for invalid cadences
%                          debugLevel: [int]  science debug level
%
%
%   Second level
%
% ldeUndershootIds is an array of structs containing the following fields:
%
%                            keplerId: [int]  Kepler lde undershoot target ID
%                          rows: [int array]  row coordinate for each target pixel
%                          cols: [int array]  column coordinate for each target pixel
%
%
% CldeUndershootIds is an array of structs containing the following fields:
%
%                Cmatrices: [3D float array]  covariance matrices for each cadence
%                                             for calibrated target pixels
%
%
%  OUTPUT:  The following are returned by this function.
%
%   Top Level
%
%       ldeUndershootMetrics: [struct array]  metric time series for
%                                             each undershoot target
%
%   Second level
%
% ldeUndershootMetrics is a struct array containing the following fields:
%
%                      values: [float array]  metric time series
%               uncertainties: [float array]  uncertainties in metric time series
%             gapIndicators: [logical array]  missing data flags
%                            keplerId: [int]  Kepler two-d black target ID
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


% parameter value for empty metric
emptyValue = -1;

% set constants here for fit to forward baseline
FORWARD_FIT_ORDER = 0;

% get module parameters
undershootReverseFitPolyOrder = ...
    moduleParametersStruct.undershootReverseFitPolyOrder;
undershootReverseFitWindow = ...
    moduleParametersStruct.undershootReverseFitWindow;

% initialize variables
nLdeUndershootIds = length(ldeUndershootIds);

% stateFilename = 'cal_metrics_state.mat';

% load the state from the state file. Throw an error if the
% state file does not exist
if ~exist(stateFilename, 'file')
    error('CAL:computeLdeUndershootMetrics:missingStateFile', ...
        'CAL state file is missing')
end

load(stateFilename, 'calibratedLdeUndershootSeries', 'ldeUndershootCoords');

% perform consistency check
if nLdeUndershootIds > 0
    ldeUndershootRows = vertcat(ldeUndershootIds.rows);
    ldeUndershootCols = vertcat(ldeUndershootIds.cols);
    ldeUndershootCoordsIn = sortrows([ldeUndershootRows ldeUndershootCols]);
else
    ldeUndershootCoordsIn = [];
end

if ~isequal(ldeUndershootCoordsIn, ldeUndershootCoords)
    error('CAL:computeLdeUndershootMetrics:invalidInputParameter', ...
        'Inconsistent lde undershoot pixel coordinates')
end

% initialize the output structure
ldeUndershootMetrics = repmat(struct( ...
    'keplerId', [], ...
    'values', [], ...
    'uncertainties', [], ...
    'gapIndicators', [] ), [1, nLdeUndershootIds]);

% for each target and cadence, compute the lde undershoot metric
for iTarget = 1 : nLdeUndershootIds
    
    % get the kepler id and row/column coordinates for the given target.
    % Throw an error if all pixels for the given target do not fall in the
    % same row
    ldeUndershootId = ldeUndershootIds(iTarget);
    keplerId = ldeUndershootId.keplerId;
    ldeUndershootRows = ldeUndershootId.rows;
    ldeUndershootCols = ldeUndershootId.cols;
    
    row = ldeUndershootRows(1);
    if any(row ~= ldeUndershootRows)
        error('CAL:computeLdeUndershootMetrics:invalidTargetSpecification', ...
            'Lde undershoot targets are restricted to single row')
    end
    
    % get all calibrated pixel time series for the given target
    pixels = calibratedLdeUndershootSeries(iTarget).pixels;
    nPixels = length(pixels);
    ldeUndershootGapIndicators = [pixels.gapIndicators]';
    ldeUndershootValues = [pixels.values]';
    ldeUndershootUncertainties = [pixels.uncertainties]';
    
    % loop over the cadences
    nCadences = size(ldeUndershootValues, 2);
    ldeUndershootMetric.keplerId = keplerId;
    ldeUndershootMetric.values = emptyValue * ones([nCadences, 1]);
    ldeUndershootMetric.uncertainties = emptyValue * ones([nCadences, 1]);
    ldeUndershootMetric.gapIndicators = true([nCadences, 1]);
    
    for iCadence = 1 : nCadences
        
        % check for valid cadence
        cadenceGapIndicator = cadenceGapIndicators(iCadence);
        if cadenceGapIndicator
            continue;
        end
        
        % get the pixel values, gap indicators and row/column coordinates
        % for the valid pixels for the given cadence
        pixelValues = ldeUndershootValues( : , iCadence);
        pixelUncertainties = ldeUndershootUncertainties( : , iCadence);
        pixelGapIndicators = ldeUndershootGapIndicators( : , iCadence);
        
        forwardPixelValues = pixelValues(~pixelGapIndicators);
        forwardCols = ldeUndershootCols(~pixelGapIndicators);
        
        reversePixelValues = flipud(forwardPixelValues);
        reverseCols = flipud(forwardCols);
        
        % find the baseline level. The procedure is different if the lde
        % undershoot target is in the virtual smear charge injection region
        % or not
        row = ldeUndershootRows(1);
        
        if row < virtualSmearStartRow
            
            % don't bother trying to estimate the undershoot metric if the
            % number of available pixel values is insufficient
            if length(forwardPixelValues) < 4
                continue;
            end
            
            % identify the extent of the baseline
            [maxDiff, indxMax] = max(diff(forwardPixelValues));
            indxMax = indxMax - 1;
            if maxDiff <= 0 || indxMax < FORWARD_FIT_ORDER + 2
                continue;
            end
            
            % try finding the baseline level looking from leading column
            % indices to trailing. This avoids errors in estimating the baseline
            % level due to under- or over-correction of the undershoot from
            % an undershoot target. Use a weighted robust estimate of the baseline
            % level to identify any outliers
            baselinePixelValues = forwardPixelValues(1 : indxMax);
            baselineCols = forwardCols(1 : indxMax);
            
            designMatrix = ...
                x2fx(baselineCols - baselineCols(1), (0 : FORWARD_FIT_ORDER)');
            
            try
                [robustParameters, robustStats] = ...
                    robustfit(designMatrix, baselinePixelValues, [], [], 'off');
            catch
                continue;
            end
            
        else % undershoot target is in virtual smear region
            
            % don't bother trying to estimate the undershoot metric for the given
            % cadence if the number of available pixel values is insufficient
            if length(reversePixelValues) < undershootReverseFitWindow + 1
                continue;
            end
            
            % perform a robust estimate of the baseline level in the last four
            % trailing black pixels. These are least affected by under or
            % over-correction for lde undershoot
            baselinePixelValues = reversePixelValues(1 : undershootReverseFitWindow);
            baselineCols = reverseCols(1 : undershootReverseFitWindow);
            
            designMatrix = x2fx(baselineCols - baselineCols(end), ...
                (0 : undershootReverseFitPolyOrder)');
            
            try
                [robustParameters, robustStats] = ...
                    robustfit(designMatrix, baselinePixelValues, [], [], 'off');
            catch
                continue;
            end
            
        end
        
        % identify outliers and remove those pixel values
        robustWeights = sqrt(robustStats.w);
        isOutlier = (0 == robustWeights);
        
        if any(isOutlier)
            robustWeights(isOutlier) = [];
            designMatrix(isOutlier, : ) = [];
            baselinePixelValues(isOutlier) = [];
            baselineCols(isOutlier) = [];
        end
        
        if size(designMatrix, 1) < size(designMatrix, 2)
            continue;
        end
        
        % baseline level is now estimated with a weighted least squares
        % fit. Find the transformation vector for evaluation of the
        % baseline polynomial fit at the endpoint. FOR NOW SET THE COVARIANCE
        % MATRIX FOR THE UNDERSHOOT TARGET TO BE DIAGONAL WITH THE SQUARED
        % UNCERTAINTIES OF THE CALIBRATED PIXELS. THIS WILL BE REPLACED
        % WHEN THE PROPAGATION OF ERRORS IS COMPLETE
        CldeUndershoot = diag(pixelUncertainties .^ 2);
        [tf, indxBaselineCols] = ismember(baselineCols, ldeUndershootCols);
        
        try
            Tparameters = lscov(designMatrix, eye(size(designMatrix, 1)), ...
                robustWeights .^ 2);
        catch
            continue;
        end
        TfitAtEndpoint = designMatrix(1, : ) * Tparameters;
        baselineLevel = TfitAtEndpoint * baselinePixelValues;
        
        % now try to find the undershoot and step levels looking from trailing
        % column indices to leading. If the undershoot pixel is not
        % adjacent to the step pixel then the metric cannot be computed for
        % this cadence
        [maxDiff, indxMax] = max(diff(reversePixelValues));
        undershootCol = reverseCols(indxMax);
        stepCol = reverseCols(indxMax + 1);
        
        if 1 ~= abs(undershootCol - stepCol)
            continue;
        end
        
        undershootLevel = reversePixelValues(indxMax);
        stepLevel = reversePixelValues(indxMax + 1);
        
        % compute the metric. Units are percent. Don't bother trying if
        % the step size is negative
        Tscale = 100;
        
        numerator = baselineLevel - undershootLevel;
        denominator = stepLevel - baselineLevel;
        
        if denominator <= 0
            continue;
        elseif abs(numerator) > denominator
            continue;
        end
        
        metric = Tscale * (numerator / denominator);
        
        % Compute the uncertainty in the metric.
        Tdifferences = zeros([2, nPixels]);
        Tdifferences(1, indxBaselineCols) = TfitAtEndpoint;
        Tdifferences(1, undershootCol == ldeUndershootCols) = -1;
        Tdifferences(2, indxBaselineCols) = -TfitAtEndpoint;
        Tdifferences(2, stepCol == ldeUndershootCols) = 1;
        
        Tratio = [1 / denominator, -numerator / denominator ^ 2];
        
        Cdifferences = Tdifferences * CldeUndershoot * Tdifferences';
        Cratio = Tratio * Cdifferences * Tratio';
        Cmetric = Tscale * Cratio * Tscale';
        
        uncertainty = sqrt(Cmetric);
        gapIndicator = false;
        
        % populate metric structure with the fields for this cadence
        ldeUndershootMetric.keplerId = keplerId;
        ldeUndershootMetric.values(iCadence) = metric;
        ldeUndershootMetric.uncertainties(iCadence) = uncertainty;
        ldeUndershootMetric.gapIndicators(iCadence) = gapIndicator;
        
        % make plots if debug level is > 0
        if debugLevel
            close all;
            plot(forwardCols, forwardPixelValues, '-ob');
            hold on
            plot(baselineCols, designMatrix * Tparameters * baselinePixelValues, '-xg');
            plot(baselineCols(1), baselineLevel, 'sr');
            plot(undershootCol, undershootLevel, 'sr');
            plot(stepCol, stepLevel, 'sr');
            grid
            hold off
            str = sprintf('[CAL] LDE Undershoot -- Target = %d; Metric = %.2f; Uncertainty = %.2f', ...
                iTarget, metric, uncertainty);
            title(str);
            xlabel('Column');
            ylabel('Calibrated Value (e-)');
            pause(1)
        end
        
    end
    
    % assign the metrics to the output structure
    ldeUndershootMetrics(iTarget) = ldeUndershootMetric;
    
end

% generate and save plots
close all;
paperOrientationFlag = true;

h = figure;
colors = 'bgrcmyk';
isValidMetric = false;

for iTarget = 1 : nLdeUndershootIds
    gapIndicators = ldeUndershootMetrics(iTarget).gapIndicators;
    if ~all(gapIndicators);
        values = ldeUndershootMetrics(iTarget).values;
        values = values(~gapIndicators);
        cadences = (1 : length(gapIndicators))';
        cadences = cadences(~gapIndicators);
        colorStr = ['.-' colors(1 + mod(iTarget-1, length(colors)))];
        plot(cadences, values, colorStr);
        hold on
        isValidMetric = true;
    end
end

if isValidMetric
    grid
    title('[CAL] LDE Undershoot Metric', 'fontsize', 14);
    xlabel(' Cadence ', 'fontsize', 14);
    ylabel(' Undershoot Metric (%) ', 'fontsize', 14);
    hold off
    
    set(h, 'PaperPositionMode', 'auto');
    set(gca, 'fontsize', 13);
    
    plot_to_file('cal_lde_undershoot_metrics', paperOrientationFlag);
    close all;
end


return
