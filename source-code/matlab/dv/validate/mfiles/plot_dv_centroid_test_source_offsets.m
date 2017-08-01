function [alertsOnly] = plot_dv_centroid_test_source_offsets(rootDir, ...
iTarget, keplerId, kics, targetResults, ukirtImageFileName, alertsOnly)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [alertsOnly] = plot_dv_centroid_test_source_offsets(rootDir, ...
% iTarget, keplerId, kics, targetResults, ukirtImageFileName, alertsOnly)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Generate standard offsets diagnostic subplot for centroid test source
% offsets for all candidates associated with given target. Also generate
% offsets subplot with UKIRT image as background for all candidates if
% image is available for given target. Issue alert if figure cannot be
% generated for given candidate, otherwise save figure with caption to fig
% file.
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

% Loop over the planet candidates for the given target and generate the
% centroid test diagnostic figures.
nPlanets = length(targetResults.planetResultsStruct);

for iPlanet = 1 : nPlanets
    
    % Generate the diagnostic figure for the given planet candidate.
    fluxWeightedMotionResults = ...
        targetResults.planetResultsStruct(iPlanet).centroidResults.fluxWeightedMotionResults;
    
    [isValidSubplot1, figureAxis] = ...
        centroid_test_offset_subplot_standard(121, fluxWeightedMotionResults, ...
        keplerId, kics);
    set(gca, 'position', [0.10, 0.12, 0.35, 0.70]);
    
    [isValidSubplot2] = ...
        centroid_test_offset_subplot_on_ukirt(122, fluxWeightedMotionResults, ...
        keplerId, kics, ukirtImageFileName, figureAxis);
    set(gca,'position', [0.55, 0.12, 0.35, 0.70]);
    
    isValidFigure = isValidSubplot1 | isValidSubplot2;
    
    % Set the figure caption.
    if ~isValidFigure
        string = 'Centroid test source offsets figure cannot be generated.';
        [alertsOnly] = add_dv_alert(alertsOnly, 'Centroid test', 'warning', ...
            string, iTarget, keplerId, iPlanet);
        disp(alertsOnly.alerts(end).message);
        continue
    end % if
        
    caption = ['Flux weighted centroid test source offsets for target ', num2str(keplerId), ...
        ', planet candidate ', num2str(iPlanet), '. ', ...
        'Symbol key: magenta cross: flux weighted centroid test source offsets ', ...
        'with 1-sigma error bars in RA and Dec; blue circle: 3-sigma radius of confusion for source offset; ', ...
        'red asterisk: location of target star; blue asterisk: location of other KIC objects in the neighborhood. KIC ID and magnitude ', ...
        'are noted in the text associated with each marked object (objects in the UKIRT extension to the KIC have IDs between 15,000,000 and 30,000,000). ', ...
        'Figure on right is displayed on UKIRT image for given target.'];

    % Add title and caption.
    axes('position', [0.1, 0.85, 0.8, .05], 'Box', 'off', 'Visible', 'off');
    title({'Centroid Test Source Offsets';
        ['Planet Candidate ', num2str(iPlanet)]});
    set(get(gca, 'Title'), 'Visible', 'on');
    set(get(gca, 'Title'), 'FontWeight', 'bold');
    set(gcf, 'UserData', caption);
    format_graphics_for_dv_report(gcf);
    
    % Save the figure.
    figureName = [rootDir, sprintf('/planet-%02d', iPlanet), ...
        '/centroid-test-results/', num2str(keplerId, '%09d'), '-', ...
        num2str(iPlanet, '%02d'), '-centroid-test-source-offsets'];
    saveas(gcf, figureName);
    
end % for iPlanet

% Close figure if one remains open.
close;

% Return.
return


function [isValidSubplot, figureAxis] = centroid_test_offset_subplot_standard( ...
mnp, motionResults, targetId, kics)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [isValidSubplot, figureAxis] = centroid_test_offset_subplot_standard( ...
% mnp, motionResults, targetId, kics)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Plot the centroid test source offset with 1-sigma error bars in magenta.
% Also plot the 3-sigma uncertainty radius in the offset distance
% associated with the source offset in blue. Note that the x-axis
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

% Plot the centroid test source offsets with error bars and plot the
% 3-sigma radius of uncertainty.
[isValidSubplot] = dv_plot_source_offsets(motionResults, '.-m', '-b', ...
    isValidSubplot);

% Mark the given target and get the coordinates.
[targetRaHours, targetDecDegrees] = dv_mark_target(targetId, kics, ...
    '*r', 'black');

% Set the offsets figure axis.
[figureAxis] = dv_set_offsets_figure_axis();

% Mark the nearby KIC objects.
dv_mark_nearby_objects(targetId, targetRaHours, targetDecDegrees, kics, ...
    '*b', 'black', figureAxis);

% Add labels.
xlabel('RA Offset (arcsec)');
ylabel('Dec Offset (arcsec)');
set(gca, 'XDir', 'reverse');

% Return.
return


function [isValidSubplot] = centroid_test_offset_subplot_on_ukirt(mnp, ...
motionResults, targetId, kics, ukirtImageFileName, figureAxis)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [isValidSubplot] = centroid_test_offset_subplot_on_ukirt(mnp, ...
% motionResults, targetId, kics, ukirtImageFileName, figureAxis)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Plot the centroid test source offset with 1-sigma error bars in magenta.
% Also plot the 3-sigma uncertainty radius in the offset distance
% associated with the source offset in blue. Note that the x-axis
% (RA Offset) is reversed. Units of offsets are arcseconds. The target is
% marked with a red asterisk and identified by keplerId and keplerMag;
% nearby KIC objects are marked with blue asterisks and identified by
% keplerId and keplerMag. Ensure that the RA and Dec axis ticking is
% consistent so that the 3-sigma uncertainty circle actually appears to be
% circular when displayed in the DV report. UKIRT image for given target
% should be displayed in background.
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

% Initialize validity flag.
isValidSubplot = false;

% Identify the subplot.
subplot(mnp);

% Lay down the UKIRT image.
if isempty(ukirtImageFileName) || ~exist(ukirtImageFileName, 'file')
    axis(figureAxis);
    set(gca,'XDir','reverse');
    return
end % if

dv_display_ukirt_image(ukirtImageFileName);

% Plot the centroid test source offsets with error bars and plot the
% 3-sigma radius of uncertainty.
[isValidSubplot] = dv_plot_source_offsets(motionResults, '.-m', '-b', ...
    isValidSubplot);

% Mark the given target and get the coordinates.
[targetRaHours, targetDecDegrees] = dv_mark_target(targetId, kics, ...
    '*r', 'red');

% Set the axis to match the associated centroid test source offsets figure.
axis(figureAxis);

% Mark the nearby KIC objects.
dv_mark_nearby_objects(targetId, targetRaHours, targetDecDegrees, kics, ...
    '*b', 'blue', figureAxis);

% Add labels.
xlabel('RA Offset (arcsec)');
ylabel('Dec Offset (arcsec)');
set(gca,'XDir','reverse');
set(gca,'YDir','normal');

% Return.
return


function [isValidSubplot] = dv_plot_source_offsets(motionResults, ...
lineSpec1, lineSpec2, isValidSubplot)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [isValidSubplot] = dv_plot_source_offsets(motionResults, ...
% lineSpec1, lineSpec2, isValidSubplot)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Plot the centroid test source offsets with error bars and plot the
% 3-sigma radius of uncertainty.
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

if motionResults.sourceRaOffset.uncertainty ~= -1 && ...
        motionResults.sourceDecOffset.uncertainty ~= -1  
    dv_errorbar2d( ...
        motionResults.sourceRaOffset.value, ...
        motionResults.sourceDecOffset.value, ...
        motionResults.sourceRaOffset.uncertainty, ...
        motionResults.sourceDecOffset.uncertainty, ...
        lineSpec1);  
    dv_ellipse3e( ...
        motionResults.sourceRaOffset.value, ...
        motionResults.sourceDecOffset.value, ...
        motionResults.sourceOffsetArcSec.uncertainty, ...
        motionResults.sourceOffsetArcSec.uncertainty, ...
        lineSpec2);
    isValidSubplot = true; 
end % if

return
