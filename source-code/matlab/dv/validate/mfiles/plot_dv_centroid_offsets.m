function [alertString] = plot_dv_centroid_offsets(rootDir, keplerId, ...
iPlanet, kics, diagnosticResultsArray, diagnosticMotionResults, ...
imageTypeString, mqOffsetConstantUncertainty, ukirtImageFileName, ...
isBadQualityMetric)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [alertString] = plot_dv_centroid_offsets(rootDir, keplerId, ...
% iPlanet, kics, diagnosticResultsArray, diagnosticMotionResults, ...
% imageTypeString, mqOffsetConstantUncertainty, ukirtImageFileName, ...
% isBadQualityMetric)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Generate standard centroid offsets diagnostic figure for difference or
% pixel correlation image centroid offsets. Also generate centroid offsets
% figure with UKIRT image as background if image is available for given
% target.
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

% Check optional arguments.
if ~exist('isBadQualityMetric', 'var') || isempty(isBadQualityMetric)
    isBadQualityMetric = false([length(diagnosticResultsArray), 1]);
end  % if

% Initialize return string.
alertString = '';

% Plot the standard centroid offsets figure with subplots for offsets
% relative to out of transit centroid and KIC position of target.
if strcmp(imageTypeString, 'Difference Image')
    dirString = '/difference-image/';
    figString = '-difference-image-centroid-offsets';
elseif strcmp(imageTypeString, 'Pixel Correlation')
    dirString = '/pixel-correlation-test-results/';
    figString = '-pixel-correlation-centroid-offsets';
else
    alertString = sprintf('Unsupported image type %s for plotting centroid offsets', ...
        imageTypeString);
    return
end % if /else

[isValidFigure, figureAxes] = ...
    plot_dv_centroid_offsets_standard(keplerId, iPlanet, kics, ...
    diagnosticResultsArray, diagnosticMotionResults, imageTypeString, ...
    mqOffsetConstantUncertainty, isBadQualityMetric);

if isValidFigure
    figureName = [rootDir, sprintf('/planet-%02d', iPlanet), ...
        dirString, num2str(keplerId, '%09d'), '-', ...
        num2str(iPlanet, '%02d'), figString];
    saveas(gcf, figureName);
else
    alertString = ...
        ['Centroid offsets figure cannot be generated ', ...
        'because there are no valid centroid offsets'];
end % if / else

% Plot the centroid offsets with the UKIRT image as the background.
[isValidFigure] = ...
    plot_dv_centroid_offsets_on_ukirt(keplerId, iPlanet, kics, ...
    diagnosticResultsArray, diagnosticMotionResults, imageTypeString, ...
    mqOffsetConstantUncertainty, ukirtImageFileName, figureAxes, ...
    isBadQualityMetric);

if isValidFigure
    figureName = [rootDir, sprintf('/planet-%02d', iPlanet), ...
        dirString, num2str(keplerId, '%09d'), '-', ...
        num2str(iPlanet, '%02d'), figString, '-ukirt'];
    saveas(gcf, figureName);
end % if

% Return.
return


function [isValidFigure, figureAxes] = plot_dv_centroid_offsets_standard( ...
keplerId, iPlanet, kics, diagnosticResultsArray, diagnosticMotionResults, ...
imageTypeString, mqOffsetConstantUncertainty, isBadQualityMetric)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [isValidFigure, figureAxes] = plot_dv_centroid_offsets_standard( ...
% keplerId, iPlanet, kics, diagnosticResultsArray, diagnosticMotionResults, ...
% imageTypeString, mqOffsetConstantUncertainty, isBadQualityMetric)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Generate standard centroid offsets diagnostic figure for difference or
% pixel correlation image centroid offsets. Return logical indicating
% whether or not figure is valid (i.e. based on valid centroid offsets) and
% figure axes for later figures with UKIRT image as background.
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

% Initialize figure axes.
figureAxes = zeros(2, 4);

% Create two subplots with the centroid offsets relative to the
% (1) out-of-transit ("control") centroid, and (2) KIC reference position.
[isValidSubplot1, figureAxes(1, : )] = ...
    centroid_offset_subplot_standard(121, ...
    [diagnosticResultsArray.quarter], ...
    [diagnosticResultsArray.controlCentroidOffsets], ...
    diagnosticMotionResults.mqControlCentroidOffsets, ...
    keplerId, kics, isBadQualityMetric, ...
    {'Offsets Relative to'; 'Out of Transit Centroid'});
set(gca, 'position', [0.10, 0.12, 0.35, 0.70]);

[isValidSubplot2, figureAxes(2, : )] = ...
    centroid_offset_subplot_standard(122, ...
    [diagnosticResultsArray.quarter], ...
    [diagnosticResultsArray.kicCentroidOffsets], ...
    diagnosticMotionResults.mqKicCentroidOffsets, ...
    keplerId, kics, isBadQualityMetric, ...
    {'Offsets Relative to'; 'KIC Position'});
set(gca,'position', [0.55, 0.12, 0.35, 0.70]);

isValidFigure = isValidSubplot1 | isValidSubplot2;

% Set caption.
uncertaintyString = sprintf('%.4f', mqOffsetConstantUncertainty);

caption = [imageTypeString(1), lower(imageTypeString(2:end)), ' centroid offsets for target ', num2str(keplerId), ...
    ', planet candidate ', num2str(iPlanet), '. ', ...
    'Left: ', lower(imageTypeString), ' PRF centroid offsets in RA and Dec with respect to the quarterly out-of-transit centroids ', ...
    'for the given target. ', ...
    'Right: ', lower(imageTypeString), ' PRF centroid offsets in RA and Dec with respect to the KIC coordinates of the ', ...
    'given target. ', ...
    'Symbol key: green cross: quarterly centroid offsets with 1-sigma error bars in RA and Dec; magenta cross: robust weighted mean offset ', ...
    'over all quarters with 1-sigma error bars in RA and Dec; blue circle: 3-sigma radius of confusion for weighted mean offset; ', ...
    'red cross (where applicable): multi-quarter PRF centroid offset with 1-sigma error bars in RA and Dec; ', ...
    'cyan circle (where applicable): 3-sigma radius of confusion for multi-quarter PRF offset; ', ...
    'red asterisk: location of target star; blue asterisk: location of other KIC objects in the neighborhood. KIC ID and magnitude ', ...
    'are noted in the text associated with each marked object (objects in the UKIRT extension to the KIC have IDs between 15,000,000 and 30,000,000). ', ...
    'A constant error term of ', uncertaintyString, ' arcseconds has been added in quadrature to the ', ...
    'computed uncertainty in the RA and Dec components of the robust mean offset and the multi-quarter PRF offset.'];

if any(isBadQualityMetric)
    removalString = [' It should be noted that one or more centroid offsets have been ignored in computation of the ', ...
        'robust mean offset because they were derived from low quality difference images.'];
    caption = [caption, removalString];
end % if

% Add title and caption.
axes('position', [0.1, 0.85, 0.8, .05], 'Box', 'off', 'Visible', 'off');
title({[imageTypeString, ' Centroid Offsets'];
    ['Planet Candidate ', num2str(iPlanet)]});
set(get(gca, 'Title'), 'Visible', 'on');
set(get(gca, 'Title'), 'FontWeight', 'bold');
set(gcf, 'UserData', caption);
format_graphics_for_dv_report(gcf);

% Return.
return


function [isValidSubplot, figureAxis] = centroid_offset_subplot_standard( ...
mnp, quarters, offsetsArray, mqOffsets, targetId, kics, isBadQualityMetric, ...
titleString)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [isValidSubplot, figureAxis] = centroid_offset_subplot_standard( ...
% mnp, quarters, offsetsArray, mqOffsets, targetId, kics, isBadQualityMetric, ...
% titleString)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Plot the per target table centroid offsets with 1-sigma error bars (in RA
% and Dec) in green. Plot the mean centroid offset with 1-sigma error bars
% in magenta. Also plot the 3-sigma uncertainty radius in the offset
% distance associated with the mean offset in blue. Note that the x-axis
% (RA Offset) is reversed. Units of offsets are arcseconds. The target is
% marked with a red asterisk and identified by keplerId and keplerMag;
% nearby KIC objects are marked with blue asterisks and identified by
% keplerId and keplerMag. Ensure that the RA and Dec axis ticking is
% consistent so that the 3-sigma uncertainty circle actually appears to be
% circular when displayed in the DV report.
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

% Initialize validity flag.
isValidSubplot = false;

% Identify the subplot.
subplot(mnp);

% Plot the valid per target table centroid offsets with error bars, and
% mark the offsets with the associated quarter ID (after all of the
% quarterly offsets and error bars have been displayed).
[isValidSubplot] = dv_plot_quarterly_offsets(quarters, offsetsArray, ...
    '.-g', 'black', 'red', isBadQualityMetric, isValidSubplot);

% Plot the mean centroid offsets with error bars and plot the 3-sigma
% radius for the uncertainty in the associated sky offset.
[isValidSubplot] = dv_plot_mean_offsets(mqOffsets, '.-m', '-b', ...
    isValidSubplot);

% Plot the single fit centroid offsets with error bars and plot the 3-sigma
% radius for the uncertainty in the associated sky offset.
[isValidSubplot] = dv_plot_single_fit_offsets(mqOffsets, '.-r', '-c', ...
    isValidSubplot);

% Mark the given target and get the coordinates.
[targetRaHours, targetDecDegrees] = dv_mark_target(targetId, kics, ...
    '*r', 'black');

% Set the offsets figure axis.
[figureAxis] = dv_set_offsets_figure_axis();

% Mark the nearby KIC objects.
dv_mark_nearby_objects(targetId, targetRaHours, targetDecDegrees, kics, ...
    '*b', 'black', figureAxis);

% Add title and labels.
title(titleString);
xlabel('RA Offset (arcsec)');
ylabel('Dec Offset (arcsec)');
set(gca, 'XDir', 'reverse');

% Return.
return


function [isValidFigure] = plot_dv_centroid_offsets_on_ukirt(keplerId, ...
iPlanet, kics, diagnosticResultsArray, diagnosticMotionResults, ...
imageTypeString, mqOffsetConstantUncertainty, ukirtImageFileName, ...
figureAxes, isBadQualityMetric)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [isValidFigure] = plot_dv_centroid_offsets_on_ukirt(keplerId, ...
% iPlanet, kics, diagnosticResultsArray, diagnosticMotionResults, ...
% imageTypeString, mqOffsetConstantUncertainty, ukirtImageFileName, ...
% figureAxes, isBadQualityMetric)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Generate centroid offsets figure with UKIRT image as background if image
% is available for given target. Return logical indicating whether or not
% figure is valid (i.e. based on valid centroid offsets).
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

% Create two subplots with the centroid offsets relative to the
% (1) out-of-transit ("control") centroid, and (2) KIC reference position.
[isValidSubplot1] = ...
    centroid_offset_subplot_on_ukirt(121, ...
    [diagnosticResultsArray.quarter], ...
    [diagnosticResultsArray.controlCentroidOffsets], ...
    diagnosticMotionResults.mqControlCentroidOffsets, ...
    keplerId, kics, ukirtImageFileName, isBadQualityMetric, ...
    figureAxes(1, : ), {'Offsets Relative to'; 'Out of Transit Centroid'});
set(gca, 'position', [0.10, 0.12, 0.35, 0.70]);

[isValidSubplot2] = ...
    centroid_offset_subplot_on_ukirt(122, ...
    [diagnosticResultsArray.quarter], ...
    [diagnosticResultsArray.kicCentroidOffsets], ...
    diagnosticMotionResults.mqKicCentroidOffsets, ...
    keplerId, kics, ukirtImageFileName, isBadQualityMetric, ...
    figureAxes(2, : ), {'Offsets Relative to'; 'KIC Position'});
set(gca,'position', [0.55, 0.12, 0.35, 0.70]);

isValidFigure = isValidSubplot1 | isValidSubplot2;

% Set caption.
uncertaintyString = sprintf('%.4f', mqOffsetConstantUncertainty);

caption = [imageTypeString(1), lower(imageTypeString(2:end)), ' centroid offsets for target ', num2str(keplerId), ...
    ', planet candidate ', num2str(iPlanet), ', diplayed on UKIRT image for given target. ', ...
    'Left: ', lower(imageTypeString), ' PRF centroid offsets in RA and Dec with respect to the quarterly out-of-transit centroids ', ...
    'for the given target. ', ...
    'Right: ', lower(imageTypeString), ' PRF centroid offsets in RA and Dec with respect to the KIC coordinates of the ', ...
    'given target. ', ...
    'Symbol key: green cross: quarterly centroid offsets with 1-sigma error bars in RA and Dec; magenta cross: robust weighted mean offset ', ...
    'over all quarters with 1-sigma error bars in RA and Dec; blue circle: 3-sigma radius of confusion for weighted mean offset; ', ...
    'red asterisk: location of target star; blue asterisk: location of other KIC objects in the neighborhood. KIC ID and magnitude ', ...
    'are noted in the text associated with each marked object (objects in the UKIRT extension to the KIC have IDs between 15,000,000 and 30,000,000). ', ...
    'A constant error term of ', uncertaintyString, ' arcseconds has been added in quadrature to the ', ...
    'computed uncertainty in the RA and Dec components of the robust mean offset and the multi-quarter PRF offset.'];

if any(isBadQualityMetric)
    removalString = [' It should be noted that one or more centroid offsets have been ignored in computation of the ', ...
        'robust mean offset because they were derived from low quality difference images.'];
    caption = [caption, removalString];  
end % if

% Add title and caption.
axes('position', [0.1, 0.85, 0.8, .05], 'Box', 'off', 'Visible', 'off');
title({[imageTypeString, ' Centroid Offsets'];
    ['Planet Candidate ', num2str(iPlanet)]});
set(get(gca, 'Title'), 'Visible', 'on');
set(get(gca, 'Title'), 'FontWeight', 'bold');
set(gcf, 'UserData', caption);
format_graphics_for_dv_report(gcf);

% Return.
return


function [isValidSubplot] = centroid_offset_subplot_on_ukirt(mnp, quarters, ...
offsetsArray, mqOffsets, targetId, kics, ukirtImageFileName, ...
isBadQualityMetric, figureAxis, titleString)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [isValidSubplot] = centroid_offset_subplot_on_ukirt(mnp, quarters, ...
% offsetsArray, mqOffsets, targetId, kics, ukirtImageFileName, ...
% isBadQualityMetric, figureAxis, titleString)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Plot the per target table centroid offsets with 1-sigma error bars (in RA
% and Dec) in green. Plot the mean centroid offset with 1-sigma error bars
% in magenta. Also plot the 3-sigma uncertainty radius in the offset
% distance associated with the mean offset in blue. Note that the x-axis
% (RA Offset) is reversed. Units of offsets are arcseconds. The target is
% marked with a red asterisk and identified by keplerId and keplerMag;
% nearby KIC objects are marked with blue asterisks and identified by
% keplerId and keplerMag. Ensure that the RA and Dec axis ticking is
% consistent so that the 3-sigma uncertainty circle actually appears to be
% circular when displayed in the DV report. UKIRT image for given target
% should be displayed in background; new figure should not be generated if
% UKIRT image is not available.
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

% Initialize validity flag.
isValidSubplot = false;

% Identify the subplot.
subplot(mnp);

% Lay down the UKIRT image.
if isempty(ukirtImageFileName) || ~exist(ukirtImageFileName, 'file')
    return
end % if

dv_display_ukirt_image(ukirtImageFileName);

% Plot the valid per target table centroid offsets with error bars, and
% mark the offsets with the associated quarter ID (after all of the
% quarterly offsets and error bars have been displayed).
[isValidSubplot] = dv_plot_quarterly_offsets(quarters, offsetsArray, ...
    '.-g', 'green', 'red', isBadQualityMetric, isValidSubplot);

% Plot the mean centroid offsets with error bars and plot the 3-sigma
% radius for the uncertainty in the associated sky offset.
[isValidSubplot] = dv_plot_mean_offsets(mqOffsets, '.-m', '-b', ...
    isValidSubplot);

% Mark the given target and get the coordinates.
[targetRaHours, targetDecDegrees] = dv_mark_target(targetId, kics, ...
    '*r', 'red');

% Set the axis to match the associated centroid offsets figure.
axis(figureAxis);

% Mark the nearby KIC objects.
dv_mark_nearby_objects(targetId, targetRaHours, targetDecDegrees, kics, ...
    '*b', 'blue', figureAxis);

% Add title and labels.
title(titleString);
xlabel('RA Offset (arcsec)');
ylabel('Dec Offset (arcsec)');
set(gca,'XDir','reverse');
set(gca,'YDir','normal');

% Return.
return

function [isValidSubplot] = dv_plot_quarterly_offsets(quarters, ...
offsetsArray, lineSpec, goodQuarterColor, badQuarterColor, ...
isBadQualityMetric, isValidSubplot)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [isValidSubplot] = dv_plot_quarterly_offsets(quarters, ...
% offsetsArray, lineSpec, goodQuarterColor, badQuarterColor, ...
% isBadQualityMetric, isValidSubplot)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Plot the valid per target table centroid offsets with error bars, and
% mark the offsets with the associated quarter ID (after all of the
% quarterly offsets and error bars have been displayed).
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

nTables = length(offsetsArray);

for iTable = 1 : nTables
    
    offsets = offsetsArray(iTable);
    
    if offsets.raOffset.uncertainty ~= -1 && ...
            offsets.decOffset.uncertainty ~= -1
        dv_errorbar2d( ...
            offsets.raOffset.value, ...
            offsets.decOffset.value, ...
            offsets.raOffset.uncertainty, ...
            offsets.decOffset.uncertainty, ...
            lineSpec);
        isValidSubplot = true;
    end % if
            
end % for iTable

for iTable = 1 : nTables
    
    offsets = offsetsArray(iTable);
    
    if offsets.raOffset.uncertainty ~= -1 && ...
            offsets.decOffset.uncertainty ~= -1
        if isBadQualityMetric(iTable)
            quarterColor = badQuarterColor;
        else
            quarterColor = goodQuarterColor;
        end % if / else
        quarterString = sprintf('{\\color{%s} Q%d}', quarterColor, ...
            quarters(iTable));
        text(offsets.raOffset.value, offsets.decOffset.value, ...
            quarterString);
    end % if
            
end % for iTable

return


function [isValidSubplot] = dv_plot_mean_offsets(mqOffsets, ...
lineSpec1, lineSpec2, isValidSubplot)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [isValidSubplot] = dv_plot_mean_offsets(mqOffsets, ...
% lineSpec1, lineSpec2, isValidSubplot)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Plot the mean centroid offsets with error bars and plot the 3-sigma
% radius for the uncertainty in the associated sky offset.
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

if mqOffsets.meanRaOffset.uncertainty ~= -1 && ...
        mqOffsets.meanDecOffset.uncertainty ~= -1  
    dv_errorbar2d( ...
        mqOffsets.meanRaOffset.value, ...
        mqOffsets.meanDecOffset.value, ...
        mqOffsets.meanRaOffset.uncertainty, ...
        mqOffsets.meanDecOffset.uncertainty, ...
        lineSpec1);  
    dv_ellipse3e( ...
        mqOffsets.meanRaOffset.value, ...
        mqOffsets.meanDecOffset.value, ...
        mqOffsets.meanSkyOffset.uncertainty, ...
        mqOffsets.meanSkyOffset.uncertainty, ...
        lineSpec2);
    isValidSubplot = true;
end % if

return


function [isValidSubplot] = dv_plot_single_fit_offsets(mqOffsets, ...
lineSpec1, lineSpec2, isValidSubplot)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [isValidSubplot] = dv_plot_single_fit_offsets(mqOffsets, ...
% lineSpec1, lineSpec2, isValidSubplot)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Plot the single fit centroid offsets with error bars and plot the 3-sigma
% radius for the uncertainty in the associated sky offset.
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

if mqOffsets.singleFitRaOffset.uncertainty ~= -1 && ...
        mqOffsets.singleFitDecOffset.uncertainty ~= -1
    dv_errorbar2d( ...
        mqOffsets.singleFitRaOffset.value, ...
        mqOffsets.singleFitDecOffset.value, ...
        mqOffsets.singleFitRaOffset.uncertainty, ...
        mqOffsets.singleFitDecOffset.uncertainty, ...
        lineSpec1);
    dv_ellipse3e( ...
        mqOffsets.singleFitRaOffset.value, ...
        mqOffsets.singleFitDecOffset.value, ...
        mqOffsets.singleFitSkyOffset.uncertainty, ...
        mqOffsets.singleFitSkyOffset.uncertainty, ...
        lineSpec2);
    isValidSubplot = true;
end % if

return
