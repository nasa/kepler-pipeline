function [twoDBlackMetrics] = ...
    compute_two_d_black_metrics(twoDBlackIds, readNoiseDn, gainElectronsPerDn, ...
    numberOfExposuresPerCadence, cadenceGapIndicators, stateFilename)
% function [twoDBlackMetrics] = ...
% compute_two_d_black_metrics(twoDBlackIds, readNoiseDn, gainElectronsPerDn, ...
% numberOfExposuresPerCadence, cadenceGapIndicators, stateFilename)
%
% Compute two-d black (crosstalk) metrics for all two-d black targets on a
% cadence by cadence basis. The metric is defined as the ratio of the mean
% squared value of the calibrated pixels in each target region to the square
% of the read noise (in electrons) for the given mod/out for the given
% cadence.
%
%
% INPUT:  The following arguments must be provided to this function.
%
%               twoDBlackIds: [struct array]  definitions of two-d black targets
%                 readNoiseDn: [float array]  read noise (in DN) for each cadence
%          gainElectronsPerDn: [float array]  gain (e- per DN) for each cadence
%   numberOfExposuresPerCadence: [int array]  exposures (and reads) for each cadence
%      cadenceGapIndicators: [logical array]  indicators for invalid cadences
%
%
%   Second level
%
% twoDBlackIds is an array of structs containing the following fields:
%
%                            keplerId: [int]  Kepler two-d black target ID
%                          rows: [int array]  row coordinate for each target pixel
%                          cols: [int array]  column coordinate for each target pixel
%
%
%  OUTPUT:  The following are returned by this function.
%
%   Top Level
%
%                 twoDBlackMetrics: [struct array]  metric time series for
%                                                   each two-d black target
%
%   Second level
%
% twoDBlackMetrics is a struct array containing the following fields:
%
%                      values: [float array]  metric time series
%               uncertainties: [float array]  uncertainties in metric time series
%             gapIndicators: [logical array]  missing data flags
%                            keplerId: [int]  Kepler two-d black target ID
%
%--------------------------------------------------------------------------
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

% initialize variables
nTwoDBlackIds = length(twoDBlackIds);

% stateFilename = 'cal_metrics_state.mat';

% load the state from the state file. Throw an error if the
% state file does not exist
if ~exist(stateFilename, 'file')
    error('CAL:computeTwoDBlackMetrics:missingStateFile', ...
        'CAL state file is missing')
end

load(stateFilename, 'calibratedTwoDBlackSeries', 'twoDBlackCoords');

% perform consistency check
if nTwoDBlackIds > 0
    twoDBlackRows = vertcat(twoDBlackIds.rows);
    twoDBlackCols = vertcat(twoDBlackIds.cols);
    twoDBlackCoordsIn = sortrows([twoDBlackRows twoDBlackCols]);
else
    twoDBlackCoordsIn = [];
end

if ~isequal(twoDBlackCoordsIn, twoDBlackCoords)
    error('CAL:computeTwoDBlackMetrics:invalidInputParameter', ...
        'Inconsistent two-d black pixel coordinates')
end

% initialize the output structure
twoDBlackMetrics = repmat(struct( ...
    'keplerId', [], ...
    'values', [], ...
    'uncertainties', [], ...
    'gapIndicators', [] ), [1, nTwoDBlackIds]);

% compute the read noise for each cadence in electrons
readNoiseElectrons = readNoiseDn .* gainElectronsPerDn;

% for each target and cadence, compute the two-d black metric
for iTarget = 1 : nTwoDBlackIds
    
    % get the kepler id for the given target
    twoDBlackId = twoDBlackIds(iTarget);
    keplerId = twoDBlackId.keplerId;
    
    % get all calibrated pixel time series for the given target
    pixels = calibratedTwoDBlackSeries(iTarget).pixels;
    twoDBlackGapIndicators = [pixels.gapIndicators]';
    twoDBlackValues = [pixels.values]';
    twoDBlackUncertainties = [pixels.uncertainties]';
    
    % loop over the cadences
    nCadences = size(twoDBlackValues, 2);
    twoDBlackMetric.keplerId = keplerId;
    twoDBlackMetric.values = emptyValue * ones([nCadences, 1]);
    twoDBlackMetric.uncertainties = emptyValue * ones([nCadences, 1]);
    twoDBlackMetric.gapIndicators = true([nCadences, 1]);
    
    for iCadence = 1 : nCadences
        
        % check for valid cadence. Prevent later division by 0
        cadenceGapIndicator = cadenceGapIndicators(iCadence);
        if cadenceGapIndicator
            continue;
        end
        
        % get the pixel values, gap indicators and row/column coordinates
        % for the valid pixels for the given cadence
        pixelValues = twoDBlackValues( : , iCadence);
        pixelUncertainties = twoDBlackUncertainties( : , iCadence);
        pixelGapIndicators = twoDBlackGapIndicators( : , iCadence);
        
        nValidTwoDBlackValues = sum(~pixelGapIndicators);
        if 0 == nValidTwoDBlackValues
            continue;
        end
        
        pixelValues = pixelValues(~pixelGapIndicators);
        pixelUncertainties = pixelUncertainties(~pixelGapIndicators);
        
        % for each target and cadence, the two-d black metric is defined as
        % the ratio of the mean squared value of the calibrated pixel
        % values in the two-d black region to the square of the read noise
        % for the given mod/out and cadence
        Tscale = 1 / (numberOfExposuresPerCadence(iCadence) * ...
            readNoiseElectrons(iCadence) ^ 2);
        metric = Tscale * sum(pixelValues .^ 2) / nValidTwoDBlackValues;
        
        % compute uncertainty in two-d black metric. FOR NOW SET THE COVARIANCE
        % MATRIX FOR THE TWO-D BLACK TARGET TO BE DIAGONAL WITH THE SQUARED
        % UNCERTAINTIES OF THE CALIBRATED PIXELS. THIS WILL BE REPLACED WHEN THE
        % PROPAGATION OF ERRORS IS COMPLETE
        CtwoDBlack = diag(pixelUncertainties .^ 2);
        TtwoDBlack = ...
            (2 / nValidTwoDBlackValues) * pixelValues';
        Cmetric = Tscale * TtwoDBlack * CtwoDBlack * TtwoDBlack' * Tscale';
        
        uncertainty = sqrt(Cmetric);
        gapIndicator = false;
        
        % populate metric structure with the fields for this cadence
        twoDBlackMetric.keplerId = keplerId;
        twoDBlackMetric.values(iCadence) = metric;
        twoDBlackMetric.uncertainties(iCadence) = uncertainty;
        twoDBlackMetric.gapIndicators(iCadence) = gapIndicator;
        
    end
    
    % assign the metrics to the output structure
    twoDBlackMetrics(iTarget) = twoDBlackMetric;
    
end

% generate and save plots
close all;
paperOrientationFlag = true;

h = figure;
colors = 'bgrcmyk';
isValidMetric = false;

for iTarget = 1 : nTwoDBlackIds
    gapIndicators = twoDBlackMetrics(iTarget).gapIndicators;
    if ~all(gapIndicators);
        values = twoDBlackMetrics(iTarget).values;
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
    title('[CAL] Two-D Black Metric', 'fontsize', 14);
    xlabel(' Cadence ', 'fontsize', 14);
    ylabel(' Two-D Black Metric ', 'fontsize', 14);
    hold off
    
    set(h, 'PaperPositionMode', 'auto');
    set(gca, 'fontsize', 13);
    
    plot_to_file('cal_two_d_black_metrics', paperOrientationFlag);
    close all;
end


return
