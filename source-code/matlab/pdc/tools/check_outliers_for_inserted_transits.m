function [transitAnalysisStruct, targetsWithTransitOutliers] = ...
check_outliers_for_inserted_transits(transitStruct, pdcResultsStruct, ...
widthRange, depthRange, nBins)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [transitAnalysisStruct, targetsWithTransitOutliers] = ...
% compare_inserted_and_detected_discontinuities(insertedDiscStruct, ...
% detectedDiscStruct, maxStepSize, nBins)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Cycle through the inserted transits and determine whether or not
% portions of them were misidentified by PDC as outliers. Summarize and
% plot the results.
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

% Set constants, and defaults if necessary.
WIDTH_RANGE = [1.0; 12.0];
DEPTH_RANGE = [1.0e-5; 1.0e-1];
N_BINS = 20;

if ~exist('widthRange', 'var')
    widthRange = WIDTH_RANGE;
end

if ~exist('depthRange', 'var')
    depthRange = DEPTH_RANGE;
end

if ~exist('nBins', 'var')
    nBins = N_BINS;
end

% Set the cadence rate.
cadenceType = pdcResultsStruct.cadenceType;
if strcmpi(cadenceType, 'LONG')
    cadencesPerHour = 2.0;
elseif strcmpi(cadenceType, 'SHORT')
    cadencesPerHour = 60.0;
else
    error(['unknown cadence type: ', cadenceType]);
end

% Cycle through the inserted transits and determine whether or not
% portions of them were misidentified by PDC as outliers. Note that outlier
% indices in PDC results structure are 0-based and must be converted to
% 1-based numbering.
nTransits = length(vertcat(transitStruct.index));
iTransit = 0;

transitAnalysisStruct = repmat(struct( ...
    'targetIndex', 0, ...
    'keplerId', 0, ...
    'index', 0, ...
    'transitWidth', 0, ...
    'transitDepth', 0, ...
    'outlierIndices', [], ...
    'identifiedAsOutlier', false), [1, nTransits]);

for iTarget = 1 : length(transitStruct)
    
    transit = transitStruct(iTarget);
    outlierIndices = ...
        pdcResultsStruct.targetResultsStruct(iTarget).outliers.indices + 1;
    
    for iCount = 1 : length(transit.index)
        
        iTransit = iTransit + 1;
        transitAnalysisStruct(iTransit).targetIndex = iTarget;
        transitAnalysisStruct(iTransit).keplerId = transit.keplerId;
        
        transitIndex = transit.index(iCount);
        transitWidth = transit.transitWidth(iCount);
        transitDepth = transit.transitDepth(iCount);
        transitAnalysisStruct(iTransit).index = transitIndex;
        transitAnalysisStruct(iTransit).transitWidth = transitWidth;
        transitAnalysisStruct(iTransit).transitDepth = transitDepth;
        transitAnalysisStruct(iTransit).outlierIndices = outlierIndices;
        
        halfPulseWidthCadences = transitWidth * cadencesPerHour / 2;
        
        if any(abs(transitIndex - outlierIndices) <= halfPulseWidthCadences)
            transitAnalysisStruct(iTransit).identifiedAsOutlier = true;
        end % if
        
    end % for iCount
    
end % for iTarget

% Summarize and plot the results.
isOutlier = [transitAnalysisStruct.identifiedAsOutlier];
transitWidths = [transitAnalysisStruct.transitWidth];
transitDepths = [transitAnalysisStruct.transitDepth];
outlierWidths = transitWidths(isOutlier);
outlierDepths = transitDepths(isOutlier);

logTransitDepths = log10(transitDepths);
logOutlierDepths = log10(outlierDepths);

targetsWithTransitOutliers = unique([transitAnalysisStruct(isOutlier).targetIndex]);

disp(['Transits identified as outliers = ', num2str(sum(isOutlier)), '/', ...
    num2str(length(isOutlier)), ' = ', num2str(sum(isOutlier)/length(isOutlier))]);

close all
subplot(3, 1, 1)
delta = diff(sort(widthRange));
edges = (0:nBins) * delta / nBins + min(widthRange);
centers = edges(1 : end-1) + delta / (2 * nBins);
transitWidthHistogram = histc(transitWidths, edges);
bar(centers, transitWidthHistogram(1 : end-1));
x = axis;
x(1) = min(widthRange);
x(2) = max(widthRange);
axis(x);
title('Histogram of Transit Widths')
xlabel('Transit Width (hours)')
ylabel('Count')

subplot(3, 1, 2)
outlierTransitWidthHistogram = histc(outlierWidths, edges);
bar(centers, outlierTransitWidthHistogram(1 : end-1));
x = axis;
x(1) = min(widthRange);
x(2) = max(widthRange);
axis(x);
title('Histogram of Transit Widths for Outliers')
xlabel('Transit Width (hours)')
ylabel('Count')

subplot(3, 1, 3)
bar(centers, outlierTransitWidthHistogram(1 : end-1) ./ ...
    transitWidthHistogram(1 : end-1))
x = axis;
x(1) = min(widthRange);
x(2) = max(widthRange);
axis(x);
title('Probability of Identification as Outlier')
xlabel('Transit Width (hours)')
ylabel('Probability')
pause

subplot(3, 1, 1)
logDepthRange = log10(sort(depthRange));
delta = diff(sort(logDepthRange));
edges = (0:nBins) * delta / nBins + min(logDepthRange);
centers = edges(1 : end-1) + delta / (2 * nBins);
transitDepthHistogram = histc(logTransitDepths, edges);
bar(centers, transitDepthHistogram(1 : end-1));
x = axis;
x(1) = min(logDepthRange);
x(2) = max(logDepthRange);
axis(x);
title('Histogram of Transit Depths')
xlabel('Log Transit Depth')
ylabel('Count')

subplot(3, 1, 2)
outlierTransitDepthHistogram = histc(logOutlierDepths, edges);
bar(centers, outlierTransitDepthHistogram(1 : end-1));
x = axis;
x(1) = min(logDepthRange);
x(2) = max(logDepthRange);
axis(x);
title('Histogram of Transit Depths for Outliers')
xlabel('Log Transit Depth')
ylabel('Count')

subplot(3, 1, 3)
bar(centers, outlierTransitDepthHistogram(1 : end-1) ./ ...
    transitDepthHistogram(1 : end-1))
x = axis;
x(1) = min(logDepthRange);
x(2) = max(logDepthRange);
x(3) = 0;
x(4) = 1;
axis(x);
title('Probability of Identification as Outlier')
xlabel('Log Transit Depth')
ylabel('Probability')

% Return.
return
