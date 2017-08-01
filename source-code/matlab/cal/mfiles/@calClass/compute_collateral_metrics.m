function [collateralMetrics] = compute_collateral_metrics(calObject, calIntermediateStruct, calTransformStruct)
% function [collateralMetrics] = compute_collateral_metrics(calObject, calIntermediateStruct, calTransformStruct)
%
% Compute and return metrics for CAL collateral data on a cadence by cadence basis:
%
% 1. Mean black level and uncertainty in mean black level (adu per read)
% 2. Mean smear level and uncertainty in the mean level (e- per cad)
% 3. Mean dark current and uncertainty in the mean current (e- per sec)
%
% INPUT:  The following arguments must be provided to this function.
%      calObject: [object]                      object instantiated from CAL input struct
%      calIntermediateStruct: [struct array]  intermediate CAL products on a cadence by cadence basis
%
%  OUTPUT:  The following are returned by this function.
%   Top Level
%                       blackLevel: [struct]  black level metric structure
%                       smearLevel: [struct]  smear level metric structure
%                      darkCurrent: [struct]  dark current metric structure
%   Second level
%       blackLevel, smearLevel and darkCurrent are structs containing the following fields:%
%                      values: [float array]  metric time series
%               uncertainties: [float array]  uncertainties in metric time series
%             gapIndicators: [logical array]  missing data flags
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

% hard coded constants
TITLE_FONTSIZE = 14;
AXIS_LABEL_FONTSIZE = 14;
AXIS_NUMBER_FONTSIZE = 12;

% parameter value for empty struct
emptyValue = -1;

% get required fields from inputs
collateralMetricUncertEnabled = calObject.moduleParametersStruct.collateralMetricUncertEnabled;
madSigmaThreshold = calObject.moduleParametersStruct.madSigmaThresholdForSmearLevels;
pouEnabled = calObject.pouModuleParametersStruct.pouEnabled;
cadenceTimes = calObject.cadenceTimes;
cadenceGapIndicators = cadenceTimes.gapIndicators;

% get config map parameters
ccdExposureTime   = calIntermediateStruct.ccdExposureTime;
ccdReadTime       = calIntermediateStruct.ccdReadTime;
numberOfExposures = calIntermediateStruct.numberOfExposures;
nCadences         = calIntermediateStruct.nCadences;

% extract 1D black flags
performExpLc1DblackFit = calIntermediateStruct.dataFlags.performExpLc1DblackFit;
performExpSc1DblackFit = calIntermediateStruct.dataFlags.performExpSc1DblackFit;
dynamic2DBlackEnabled  = calIntermediateStruct.dataFlags.dynamic2DBlackEnabled;
computeBlackMetricsFromMeanBlack = performExpLc1DblackFit || performExpSc1DblackFit || dynamic2DBlackEnabled;

% black fit is in ADU per cad.  The units of the metric are ADU per read,
% however, so the levels must be scaled appropriately.
blackLevelMetrics.values = emptyValue * ones([nCadences, 1]);
blackLevelMetrics.uncertainties = emptyValue * ones([nCadences, 1]);
blackLevelMetrics.gapIndicators = true([nCadences, 1]);

% get mean black from inputs
meanBlackPerExposure = calIntermediateStruct.meanBlackPerExposure;
meanBlackPerCadence = meanBlackPerExposure * numberOfExposures;


if computeBlackMetricsFromMeanBlack
    
    % 1D black was fit using exponential fit or as part of dynablack
    % calculate metric and uncertainty from black correction per cadence
    
    % load the black correction
    tic;
    load([stateFilePath, 'cal_black_levels.mat'], 'blackCorrection');               % nRows x nCadences  
    
    % compute the mean for the black metric
    blackLevelMean = mean(blackCorrection);
    
    % the black correction produced by dynablack includes the mean black, 1D exponential black correction does not
    if dynamic2DBlackEnabled
        blackLevelMean = blackLevelMean - meanBlackPerCadence;
    end
    
    % compute the std for the black metric uncertainty
    numValidBlackPixels = calIntermediateStruct.nCcdRows;
    blackLevelUncertainty = std(blackCorrection)./sqrt(numValidBlackPixels);
    
    % update gaps with cadences in which no black pixels were available
    blackAvailable = calIntermediateStruct.blackAvailable;
    blackLevelGaps = cadenceGapIndicators | ~blackAvailable;
    
    blackLevelMetrics.values = blackLevelMean(:) ./ numberOfExposures;    
    blackLevelMetrics.gapIndicators = blackLevelGaps(:);
    if collateralMetricUncertEnabled
        blackLevelMetrics.uncertainties = blackLevelUncertainty(:) ./ numberOfExposures;
    end    
    
    duration = toc;
    display(['CAL:compute_collateral_metrics: Black level metrics computed for all cadences: ', num2str(duration/60, '%10.2f') ' minutes']);
    
else
    
    % 1D black was fit using polynomial
    % calculate metric and uncertainty from fit coefficients and covariance
    
    lastDuration = 0;
    tic;
    for iCadence = 1 : nCadences
        
        % check for valid cadence
        cadenceGapIndicator = cadenceGapIndicators(iCadence);
        if cadenceGapIndicator
            continue;
        end
        
        if pouEnabled
            [blackPoly, CblackPoly] = get_primitive_data(calTransformStruct(:,iCadence),'fittedBlack');
            
        else
            % get the black polynomial values and covariance matrix
            blackUncertaintyStruct = calIntermediateStruct.blackUncertaintyStruct(iCadence);

            blackPoly  = blackUncertaintyStruct.bestPolyCoeffts;
            CblackPoly = blackUncertaintyStruct.CblackPolyFit;
        end
        
        % check if there is a valid black fit
        blackAvailable = calIntermediateStruct.blackAvailable(iCadence);
        
        if blackAvailable
            
            % compute the mean black as the average value of the black
            % polynomial over the continuous row domain of [0, 1]
            Tmean = 1 ./ (1 : length(blackPoly));
            blackLevelMean = Tmean * blackPoly;
            
            % compute the uncertainty in the mean black
            blackLevelUncertainty = sqrt(Tmean * CblackPoly * Tmean');            
            if numel(numberOfExposures) > 1
                numberOfExposures = numberOfExposures(iCadence);
            end
                        
            if collateralMetricUncertEnabled
                blackLevelMetrics.uncertainties(iCadence) = blackLevelUncertainty / numberOfExposures;
            end
            
            blackLevelMetrics.values(iCadence) = blackLevelMean / numberOfExposures;
            blackLevelMetrics.gapIndicators(iCadence) = false;   
        end
        
        duration = toc;
        if (duration > 10+lastDuration)
            
            lastDuration = duration;
            display(['CAL:compute_collateral_metrics: Black level metrics computed for cadence ' num2str(iCadence) ': ' num2str(duration/60, '%10.2f') ' minutes']);
        end
    end
end

% smear levels are computed in get_smear_and_dark_levels. For each cadence,
% compute the mean smear level and uncertainty in the mean.
smearLevelMetrics.values = emptyValue * ones([nCadences, 1]);
smearLevelMetrics.uncertainties = emptyValue * ones([nCadences, 1]);
smearLevelMetrics.gapIndicators = true([nCadences, 1]);

% load smear and dark levels from file
load(calIntermediateStruct.smearAndDarkLevelsFile, 'smearLevels', 'darkCurrentLevels');         % contains 'smearLevels', 'darkCurrentLevels'

% smearLevels = calIntermediateStruct.smearLevels;
mSmearGaps  = calIntermediateStruct.mSmearGaps;
vSmearGaps  = calIntermediateStruct.vSmearGaps;

smearColumnIndicators = ~(mSmearGaps & vSmearGaps);


lastDuration = 0;
tic
for iCadence = 1 : nCadences
    
    % check for valid cadence
    cadenceGapIndicator = cadenceGapIndicators(iCadence);
    if cadenceGapIndicator
        continue;
    end
    
    % get the smear level values and covariance matrix
    smearValues = smearLevels( : , iCadence);                   %#ok<NODEF>
    
    if pouEnabled && collateralMetricUncertEnabled
        [smear, Csmear] = cascade_transformations(calTransformStruct( : , iCadence), 'smearLevelEstimate'); %#ok<ASGLU>
    else
        Csmear = zeros(length(smearValues));
    end
    
    % check if there are any valid smear columns
    isSmearColumn = smearColumnIndicators( : , iCadence);
    
    if any(isSmearColumn)
        
        % compute the mean of the smear values within the mad threshold
        smearValues = smearValues(isSmearColumn);
        Csmear = Csmear(isSmearColumn, isSmearColumn);
        
        absSmear = abs(smearValues - median(smearValues));
        isWithinThreshold = absSmear <= madSigmaThreshold * median(absSmear);
        smearLevelMean = mean(smearValues(isWithinThreshold));
        
        % compute the uncertainty in the mean smear
        if collateralMetricUncertEnabled
            smearLevelUncertainty = sqrt(mean(mean(Csmear(isWithinThreshold, isWithinThreshold))));
            smearLevelMetrics.uncertainties(iCadence) = smearLevelUncertainty;
        end
        
        smearLevelMetrics.values(iCadence) = smearLevelMean;        
        smearLevelMetrics.gapIndicators(iCadence) = false;
    end
    
    duration = toc;
    if (duration > 10+lastDuration)
        
        lastDuration = duration;
        display(['CAL:compute_collateral_metrics: Smear level metrics computed for cadence ' num2str(iCadence) ': ' num2str(duration/60, '%10.2f') ' minutes']);
    end
end

% (Robust) mean dark levels are computed in get_smear_and_dark_levels. For
% each cadence, compute the mean dark current and uncertainty in the mean
% from the dark levels and variances
darkCurrentMetrics.values = emptyValue * ones([nCadences, 1]);
darkCurrentMetrics.uncertainties = emptyValue * ones([nCadences, 1]);
darkCurrentMetrics.gapIndicators = true([nCadences, 1]);

% darkCurrentLevels = calIntermediateStruct.darkCurrentLevels;
darkColumnIndicators = (~mSmearGaps & ~vSmearGaps);


lastDuration = 0;
tic
for iCadence = 1 : nCadences
    
    % check for valid cadence
    cadenceGapIndicator = cadenceGapIndicators(iCadence);
    if cadenceGapIndicator
        continue;
    end
    
    % get the mean dark level and dark level variance
    darkLevelMean = darkCurrentLevels(iCadence);
    if pouEnabled && collateralMetricUncertEnabled
        [dark, Cdark] = cascade_transformations(calTransformStruct( : , iCadence), 'darkLevelEstimate');        %#ok<ASGLU>
    else
        Cdark = zeros(length(darkLevelMean));
    end
    
    % check if there are any valid dark columns
    isValidDarkColumn = darkColumnIndicators( : , iCadence);
    
    if any(isValidDarkColumn)
        
        % the metric is dark current rather than dark level so make the conversion
        if numel(ccdExposureTime) > 1
            ccdExposureTime = ccdExposureTime(iCadence);
        end
        
        if numel(ccdReadTime) > 1
            ccdReadTime = ccdReadTime(iCadence);
        end
        
        if numel(numberOfExposures) > 1
            numberOfExposures = numberOfExposures(iCadence);
        end
        
        darkCurrentToLevel = (ccdExposureTime + ccdReadTime) * numberOfExposures;
        
        % compute the uncertainty in the mean dark level
        if collateralMetricUncertEnabled
            darkLevelUncertainty = sqrt(Cdark);
            darkCurrentMetrics.uncertainties(iCadence) = darkLevelUncertainty / darkCurrentToLevel; 
        end
        
        darkCurrentMetrics.values(iCadence) = darkLevelMean / darkCurrentToLevel;               
        darkCurrentMetrics.gapIndicators(iCadence) = false;
    end
    
    duration = toc;
    if (duration > 10+lastDuration)
        
        lastDuration = duration;
        display(['CAL:compute_collateral_metrics: Dark current metrics computed for cadence ' num2str(iCadence) ': ' num2str(duration/60, '%10.2f') ' minutes']);
    end
end

% populate the output structure
collateralMetrics.blackLevelMetrics  = blackLevelMetrics;
collateralMetrics.smearLevelMetrics  = smearLevelMetrics;
collateralMetrics.darkCurrentMetrics = darkCurrentMetrics;

% generate and save plots
close all;
paperOrientationFlag = true;

h = figure;
subplot(2, 2, 1);
set(gca, 'fontsize', AXIS_NUMBER_FONTSIZE);
gapIndicators = blackLevelMetrics.gapIndicators;
if ~all(gapIndicators)
    values = blackLevelMetrics.values;
    values = values(~gapIndicators);
    cadences = (1 : length(gapIndicators))';
    cadences = cadences(~gapIndicators);
    plot(cadences, values, '.-');
    grid
end

title('[CAL] Black Level Metric', 'fontsize', TITLE_FONTSIZE);
xlabel(' Cadence ', 'fontsize', AXIS_LABEL_FONTSIZE);
ylabel(' Black Metric (ADU/read) ', 'fontsize', AXIS_LABEL_FONTSIZE);

subplot(2, 2, 2);
set(gca, 'fontsize', AXIS_NUMBER_FONTSIZE);
gapIndicators = smearLevelMetrics.gapIndicators;
if ~all(gapIndicators)
    values = smearLevelMetrics.values;
    values = values(~gapIndicators);
    cadences = (1 : length(gapIndicators))';
    cadences = cadences(~gapIndicators);
    plot(cadences, values, '.-');
    grid
end
title('      Smear Level Metric', 'fontsize', TITLE_FONTSIZE);
xlabel(' Cadence ', 'fontsize', AXIS_LABEL_FONTSIZE);
ylabel(' Smear Metric (e-/cad) ', 'fontsize', AXIS_LABEL_FONTSIZE);

subplot(2, 2, 3);
set(gca, 'fontsize', AXIS_NUMBER_FONTSIZE);
gapIndicators = darkCurrentMetrics.gapIndicators;
if ~all(gapIndicators)
    values = darkCurrentMetrics.values;
    values = values(~gapIndicators);
    cadences = (1 : length(gapIndicators))';
    cadences = cadences(~gapIndicators);
    plot(cadences, values, '.-');
    grid
end
title('[CAL] Dark Current Metric', 'fontsize', TITLE_FONTSIZE);
xlabel(' Cadence ', 'fontsize', AXIS_LABEL_FONTSIZE);
ylabel(' Dark Metric (e-/sec) ', 'fontsize', AXIS_LABEL_FONTSIZE);
set(h, 'PaperPositionMode', 'auto');
set(gca, 'fontsize', AXIS_NUMBER_FONTSIZE);

plot_to_file('cal_collateral_metrics', paperOrientationFlag);
close all;


h2 = figure;
gapIndicators = blackLevelMetrics.gapIndicators;
if ~all(gapIndicators)
    values = blackLevelMetrics.values;
    values = values(~gapIndicators);
    cadences = (1 : length(gapIndicators))';
    cadences = cadences(~gapIndicators);
    plot(cadences, values, '.-');
    grid
    title('[CAL] Black Level Metric', 'fontsize', TITLE_FONTSIZE);
    xlabel(' Cadence ', 'fontsize', AXIS_LABEL_FONTSIZE);
    ylabel(' Black Level Metric (ADU/read) ', 'fontsize', AXIS_LABEL_FONTSIZE);
    set(h2, 'PaperPositionMode', 'auto');
    set(gca, 'fontsize', AXIS_NUMBER_FONTSIZE);
    
    plot_to_file('cal_black_level_metric', paperOrientationFlag);
    close all;
end

h3 = figure;
gapIndicators = smearLevelMetrics.gapIndicators;
if ~all(gapIndicators)
    values = smearLevelMetrics.values;
    values = values(~gapIndicators);
    cadences = (1 : length(gapIndicators))';
    cadences = cadences(~gapIndicators);
    plot(cadences, values, '.-');
    grid
    title('[CAL] Smear Level Metric', 'fontsize', TITLE_FONTSIZE);
    xlabel(' Cadence ', 'fontsize', AXIS_LABEL_FONTSIZE);
    ylabel(' Smear Level Metric (e-/cad) ', 'fontsize', AXIS_LABEL_FONTSIZE);
    set(h3, 'PaperPositionMode', 'auto');
    set(gca, 'fontsize', AXIS_NUMBER_FONTSIZE);
    
    plot_to_file('cal_smear_level_metric', paperOrientationFlag);
    close all;
end

h4 = figure;
gapIndicators = darkCurrentMetrics.gapIndicators;
if ~all(gapIndicators)
    values = darkCurrentMetrics.values;
    values = values(~gapIndicators);
    cadences = (1 : length(gapIndicators))';
    cadences = cadences(~gapIndicators);
    plot(cadences, values, '.-');
    grid
    title('[CAL] Dark Current Metric', 'fontsize', TITLE_FONTSIZE);
    xlabel(' Cadence ', 'fontsize', AXIS_LABEL_FONTSIZE);
    ylabel(' Dark Current Metric (e-/sec) ', 'fontsize', AXIS_LABEL_FONTSIZE);
    set(h4, 'PaperPositionMode', 'auto');
    set(gca, 'fontsize', AXIS_NUMBER_FONTSIZE);
    
    plot_to_file('cal_dark_current_metric', paperOrientationFlag);
    close all;
end

return
