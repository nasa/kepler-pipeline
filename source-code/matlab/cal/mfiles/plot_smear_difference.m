function plot_smear_difference(calIntermediateStruct, mSmearResidual, vSmearResidual)
%
% function to plot the difference between the masked and virtual smear
% pixels for the common columns
%
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

% hard coded constants
TITLE_FONTSIZE = 14;
AXIS_LABEL_FONTSIZE = 12;
AXIS_NUMBER_FONTSIZE = 12;

ccdModule = calIntermediateStruct.ccdModule;
ccdOutput = calIntermediateStruct.ccdOutput;

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

% load smear and dark levels from file
load(calIntermediateStruct.smearAndDarkLevelsFile);             % contains 'smearLevels', 'darkCurrentLevels', 'validSmearColumns'


% normalize data to ADU per exposure
numberOfExposures = calIntermediateStruct.numberOfExposures;
gain = calIntermediateStruct.gain;

% normalize smear levels and darkCurrentLevels
smearLevels = smearLevels./numberOfExposures/gain;                      %#ok<NODEF>
darkCurrentLevels = darkCurrentLevels./numberOfExposures/gain;          %#ok<NODEF>

delta = (mSmearResidual - vSmearResidual)./numberOfExposures/gain;

% validSmearColumns = calIntermediateStruct.validSmearColumns;


%--------------------------------------------------------------------------
% set gaps to NaNs to omit these data from plots
%--------------------------------------------------------------------------
missingMsmearCadences = calIntermediateStruct.missingMsmearCadences;
missingVsmearCadences = calIntermediateStruct.missingVsmearCadences;
missingCadences = union(missingMsmearCadences, missingVsmearCadences);

darkCurrentLevels(missingCadences) = nan;


% Allocate memory for NaN array since the following can be too
% computationally intensive for SC data:
%
% smearLevels(~validSmearColumns) = nan;
% delta(~validSmearColumns) = nan;
% correct only for cadences with valid pixels

smearLevelsNanGaps = nan(size(smearLevels));
deltaNanGaps       = nan(size(delta));

smearLevelsNanGaps(validSmearColumns) = smearLevels(validSmearColumns);
deltaNanGaps(validSmearColumns) = delta(validSmearColumns);

smearLevels = smearLevelsNanGaps;
delta = deltaNanGaps;


%--------------------------------------------------------------------------
% plot dark current and smear levels
%--------------------------------------------------------------------------
close all;
paperOrientationFlag = true;

h = figure;
subplot(2, 1, 1);
plot(darkCurrentLevels, 'b.:', 'markersize', 7, 'linewidth', 2);
title(['[CAL] ' num2str(cadenceTypeStringForPlot)  ' Dark Levels for Channel ' ...
    num2str(convert_from_module_output(ccdModule, ccdOutput))], 'fontsize', TITLE_FONTSIZE);
xlabel(' Cadence ', 'fontsize', AXIS_LABEL_FONTSIZE);
ylabel(' Dark Level (ADU/exposure) ', 'fontsize', AXIS_LABEL_FONTSIZE);
set(gca, 'fontsize', AXIS_NUMBER_FONTSIZE);

subplot(2, 1, 2);
imagesc(smearLevels);
if processLongCadence
    caxis([prctile(smearLevels(:), 5) prctile(smearLevels(:), 95)])
elseif processShortCadence
    caxis([prctile(full(smearLevels(:)), 5) prctile(full(smearLevels(:)), 95)])
end
apply_white_nan_colormap_to_image();
title(['[CAL] ' num2str(cadenceTypeStringForPlot)  ' Smear Levels (ADU/exposure) for Channel ' ...
    num2str(convert_from_module_output(ccdModule, ccdOutput))], 'fontsize', TITLE_FONTSIZE);
xlabel('Cadence', 'fontsize', AXIS_LABEL_FONTSIZE);
ylabel('Column', 'fontsize', AXIS_LABEL_FONTSIZE);
colorbar;
set(h, 'PaperPositionMode', 'auto');
set(gca, 'fontsize', AXIS_NUMBER_FONTSIZE);

plot_to_file('cal_smear_and_dark_levels', paperOrientationFlag);
close all;


%--------------------------------------------------------------------------
% plot masked minus virtual smear difference (image)
%--------------------------------------------------------------------------
h3 = figure;
imagesc(delta);

if processLongCadence
    caxis([prctile(delta(:), 5) prctile(delta(:), 95)])
elseif processShortCadence
    caxis([prctile(full(delta(:)), 5) prctile(full(delta(:)), 95)])
end

apply_white_nan_colormap_to_image();

title(['[CAL] ' num2str(cadenceTypeStringForPlot)  ' Masked-Virtual Smear Diff (ADU/exposure) for Channel ' ...
    num2str(convert_from_module_output(ccdModule, ccdOutput))], 'fontsize', TITLE_FONTSIZE)
xlabel('Cadence', 'fontsize', AXIS_LABEL_FONTSIZE)
ylabel('Column', 'fontsize', AXIS_LABEL_FONTSIZE)
colorbar;
set(h3, 'PaperPositionMode', 'auto');
set(gca, 'fontsize', AXIS_NUMBER_FONTSIZE);

plot_to_file('cal_smear_difference_imagesc', paperOrientationFlag);
close all;


%--------------------------------------------------------------------------
% plot masked minus virtual smear difference (2D plot)
%--------------------------------------------------------------------------
h4 = figure;
plot(delta', 'b.:');

title(['[CAL] ' num2str(cadenceTypeStringForPlot)  ' Masked-Virtual Smear Diff for Channel ' ...
    num2str(convert_from_module_output(ccdModule, ccdOutput))], 'fontsize', TITLE_FONTSIZE)
ylabel('Masked - Virtual Smear (ADU/exposure)', 'fontsize', AXIS_LABEL_FONTSIZE)
xlabel('Cadence', 'fontsize', AXIS_LABEL_FONTSIZE)
set(h4, 'PaperPositionMode', 'auto');
set(gca, 'fontsize', AXIS_LABEL_FONTSIZE);

plot_to_file('cal_smear_difference_plot', paperOrientationFlag);
close all;


%--------------------------------------------------------------------------
% plot masked minus virtual smear difference (mesh)
%--------------------------------------------------------------------------
if ~processFFI
    h5 = figure;
    mesh(delta);
    
    title(['[CAL] ' num2str(cadenceTypeStringForPlot)  ' Masked-Virtual Smear Diff for Channel ' ...
        num2str(convert_from_module_output(ccdModule, ccdOutput))], 'fontsize', TITLE_FONTSIZE)
    xlabel('Cadence', 'fontsize', AXIS_LABEL_FONTSIZE)
    ylabel('CCD Column', 'fontsize', AXIS_LABEL_FONTSIZE)
    zlabel('Masked - Virtual Smear (ADU/exposure)', 'fontsize', AXIS_LABEL_FONTSIZE)
    colorbar;
    set(h5, 'PaperPositionMode', 'auto');
    set(gca, 'fontsize', AXIS_NUMBER_FONTSIZE);
    
    plot_to_file('cal_smear_difference_mesh', paperOrientationFlag);
    close all;
end


return;

