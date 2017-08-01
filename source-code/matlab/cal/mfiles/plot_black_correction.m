function plot_black_correction(calIntermediateStruct, stateFilePath)
%
% function to plot the black-corrected black pixels (residuals)
%
% This function produces the following diagnostic figures related to the calibrated black pixles.
% cal_black_residuals_imagesc.fig
% cal_std_dev_black_residuals.fig
% cal_black_residuals_plot.fig
% cal_black_residuals_mesh.fig
% 
% With debugLevel > 1 these additional diagnostic figures are created:
% cal_black_levels_imagesc.fig
% cal_black_levels_plot.fig
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

% hard coded constants
TITLE_FONTSIZE = 14;
AXIS_LABEL_FONTSIZE = 12;
AXIS_NUMBER_FONTSIZE = 12;
paperOrientationFlag = true;

% extract fields from calIntermediateStruct
debugLevel          = calIntermediateStruct.debugLevel;
ccdModule           = calIntermediateStruct.ccdModule;
ccdOutput           = calIntermediateStruct.ccdOutput;
cadenceType         = calIntermediateStruct.dataFlags.cadenceType;
processLongCadence  = calIntermediateStruct.dataFlags.processLongCadence;
processShortCadence = calIntermediateStruct.dataFlags.processShortCadence;
processFFI          = calIntermediateStruct.dataFlags.processFFI;

% rename (shorten) strings for titles/filenames
if strcmpi(cadenceType, 'long')
    cadenceTypeStringForPlot = 'LC';
elseif strcmpi(cadenceType, 'short')
    cadenceTypeStringForPlot = 'SC';
elseif strcmpi(cadenceType, 'ffi')
    cadenceTypeStringForPlot = 'FFI';
end

% load black correction and extract black pixels/gaps (residuals): blackCorrection = nRows x nCadences
load([stateFilePath, 'cal_black_levels.mat'], 'blackCorrection');
blackPixels = calIntermediateStruct.blackPixels;
blackGaps   = calIntermediateStruct.blackGaps;                                  % this is kind of silly since all blackGap = false after
                                                                                % filling with nearest neighbor in correct_collateral_pix_black_level
                                                                                % around line 404

% since we don't write blackGaps out to the intermediateStruct we can
% modify it here for use only in this plotting function - I think we only
% want to gap the cadence gaps in these images
cadenceGaps = calIntermediateStruct.cadenceGapIndicators;
blackGaps = repmat(cadenceGaps(:)',size(blackGaps,1),1);

% normalize data to ADU per exposure
numberOfExposures = calIntermediateStruct.numberOfExposures;

% update gaps to exclude charge injection rows (which are omitted in the fit)
if processLongCadence    
    blackRowsToExcludeInFit = calIntermediateStruct.chargeInjectionRows;
    blackGaps(blackRowsToExcludeInFit, :) = true;
end

%--------------------------------------------------------------------------
% set gaps to NaNs to omit these data from plots
%--------------------------------------------------------------------------
% Allocate memory for NaN array since the following can be too
% computationally intensive for SC data:

blackPixelsNanGaps = nan(size(blackPixels));
blackCorrectionNanGaps = nan(size(blackCorrection)); %#ok<NODEF>
blackPixelsNanGaps(~blackGaps) = blackPixels(~blackGaps);
blackCorrectionNanGaps(~blackGaps) = blackCorrection(~blackGaps);
blackPixels = blackPixelsNanGaps./numberOfExposures;
blackCorrection = blackCorrectionNanGaps./numberOfExposures;

% find stddev of black residuals over cadences per pixel
stdBlackPixels = nanstd(blackPixels,0,2);

%--------------------------------------------------------------------------
% save black residuals
%--------------------------------------------------------------------------
save( [stateFilePath, 'black_residuals.mat'], 'blackPixels');

%--------------------------------------------------------------------------
% figures created with debugLevel > 1 are not used in data reviews
%--------------------------------------------------------------------------
if debugLevel > 1
    %--------------------------------------------------------------------------
    % plot black levels (image)
    %--------------------------------------------------------------------------
    close all;
    h = figure;
    imagesc(blackCorrection);    
    if ~processFFI && processLongCadence
        caxis([prctile(blackCorrection(:), 5) prctile(blackCorrection(:), 95)]);
    elseif processShortCadence
        caxis([prctile(full(blackCorrection(:)), 5) prctile(full(blackCorrection(:)), 95)]);
    end    
    apply_white_nan_colormap_to_image();    
    title(['[CAL] ' num2str(cadenceTypeStringForPlot)  ' Black Level Correction (ADU/exposure) for Channel ' ...
        num2str(convert_from_module_output(ccdModule, ccdOutput))], 'fontsize', TITLE_FONTSIZE);
    xlabel(' Cadence ', 'fontsize', AXIS_LABEL_FONTSIZE);
    ylabel(' Row ', 'fontsize', AXIS_LABEL_FONTSIZE);
    colorbar;    
    set(h, 'PaperPositionMode', 'auto');
    set(gca, 'fontsize', AXIS_NUMBER_FONTSIZE);    
    plot_to_file('cal_black_levels_imagesc', paperOrientationFlag);
    close all;
        
    %--------------------------------------------------------------------------
    % plot median black levels (2D plot)
    %--------------------------------------------------------------------------
    h2 = figure;
    subplot(2, 1, 1)
    plot(nanmedian(blackCorrection), 'r.:', 'markersize', 7, 'linewidth', 2);    
    title(['[CAL] ' num2str(cadenceTypeStringForPlot)  ' Median Black Level for Channel ' ...
        num2str(convert_from_module_output(ccdModule, ccdOutput))], 'fontsize', TITLE_FONTSIZE);
    xlabel('Cadence', 'fontsize', AXIS_LABEL_FONTSIZE);
    ylabel('ADU/exposure', 'fontsize', AXIS_LABEL_FONTSIZE);    
    subplot(2, 1, 2)
    plot(blackCorrection, '.', 'markersize', 7);    
    title(['[CAL] ' num2str(cadenceTypeStringForPlot)  ' Black Levels (All Cadences) for Channel ' ...
        num2str(convert_from_module_output(ccdModule, ccdOutput))], 'fontsize', TITLE_FONTSIZE);
    xlabel('Row', 'fontsize', AXIS_LABEL_FONTSIZE);
    ylabel('ADU/exposure', 'fontsize', AXIS_LABEL_FONTSIZE);    
    set(h2, 'PaperPositionMode', 'auto');
    set(gca, 'fontsize', AXIS_NUMBER_FONTSIZE);    
    plot_to_file('cal_black_levels_plot', paperOrientationFlag);
    close all;
end

%--------------------------------------------------------------------------
% plot black residuals (image)
%--------------------------------------------------------------------------
h4 = figure;
imagesc(blackPixels);
if processLongCadence
    caxis([prctile(blackPixels(:), 5) prctile(blackPixels(:), 95)]);
elseif processShortCadence
    caxis([prctile(full(blackPixels(:)), 5) prctile(full(blackPixels(:)), 95)]);
end
apply_white_nan_colormap_to_image();
title(['[CAL] ' num2str(cadenceTypeStringForPlot)  ' Black Residuals (ADU/exposure) for Channel ' ...
    num2str(convert_from_module_output(ccdModule, ccdOutput))], 'fontsize', TITLE_FONTSIZE);
xlabel('Cadence', 'fontsize', AXIS_LABEL_FONTSIZE);
ylabel('Row', 'fontsize', AXIS_LABEL_FONTSIZE);
colorbar;
set(h4, 'PaperPositionMode', 'auto');
set(gca, 'fontsize', AXIS_NUMBER_FONTSIZE);
plot_to_file('cal_black_residuals_imagesc', paperOrientationFlag);
close all;

%--------------------------------------------------------------------------
% plot robust standard deviation of black residuals (2D plot)
%--------------------------------------------------------------------------
h4 = figure;
plot(stdBlackPixels,'o');
grid;
title(['[CAL] ' num2str(cadenceTypeStringForPlot)  ' Standard Deviation of Black Residuals Per Row for Channel ' ...
    num2str(convert_from_module_output(ccdModule, ccdOutput))], 'fontsize', TITLE_FONTSIZE);
xlabel('Row', 'fontsize', AXIS_LABEL_FONTSIZE);
ylabel('ADU/read', 'fontsize', AXIS_LABEL_FONTSIZE);
set(h4, 'PaperPositionMode', 'auto');
set(gca, 'fontsize', AXIS_NUMBER_FONTSIZE);
plot_to_file('cal_std_dev_black_residuals', paperOrientationFlag);
close all;

%--------------------------------------------------------------------------
% plot black residuals (2D plot)
%--------------------------------------------------------------------------
h5 = figure;
plot(blackPixels, 'b.:');
title(['[CAL] ' num2str(cadenceTypeStringForPlot)  ' Black Residuals for Channel ' ...
    num2str(convert_from_module_output(ccdModule, ccdOutput))], 'fontsize', TITLE_FONTSIZE);
ylabel('ADU/exposure', 'fontsize', AXIS_LABEL_FONTSIZE);
xlabel('Row', 'fontsize', AXIS_LABEL_FONTSIZE);
set(h5, 'PaperPositionMode', 'auto');
set(gca, 'fontsize', AXIS_NUMBER_FONTSIZE);
plot_to_file('cal_black_residuals_plot', paperOrientationFlag);
close all;

%--------------------------------------------------------------------------
% plot black residuals (mesh)
%--------------------------------------------------------------------------
if ~processFFI    
    h6 = figure;
    mesh(blackPixels);    
    title(['[CAL] ' num2str(cadenceTypeStringForPlot)  ' Black Residuals for Channel ' ...
        num2str(convert_from_module_output(ccdModule, ccdOutput))], 'fontsize', TITLE_FONTSIZE);
    xlabel('Cadence ', 'fontsize', AXIS_LABEL_FONTSIZE);
    ylabel('Row ', 'fontsize', AXIS_LABEL_FONTSIZE);
    zlabel('ADU/exposure', 'fontsize', AXIS_LABEL_FONTSIZE)
    colorbar;    
    set(h6, 'PaperPositionMode', 'auto');
    set(gca, 'fontsize', AXIS_NUMBER_FONTSIZE);    
    plot_to_file('cal_black_residuals_mesh', paperOrientationFlag);
    close all;
end

return;
