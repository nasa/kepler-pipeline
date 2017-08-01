function plot_reference_pixels(stellarTargetDefinitions, blackTargetDefinitions, ...
    smearTargetDefinitions, backgroundMaskDefinition, blackMaskDefinition, ...
    smearMaskDefinition, rptsObject, targetBounds, boundingRadius, includeLegendFlag)
% function plot_reference_pixels(stellarTargetDefinitions, blackTargetDefinitions, ...
%     smearTargetDefinitions, backgroundMaskDefinition, blackMaskDefinition, ...
%     smearMaskDefinition, rptsObject, boundingRadius, includeLegendFlag)
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

ccdModule     = rptsObject.module;
ccdOutput     = rptsObject.output;
currentModOut = convert_from_module_output(ccdModule, ccdOutput);

existingMasks  = rptsObject.existingMasks;

%--------------------------------------------------------------------------
% plot input stellar apertures and bounding radius
%--------------------------------------------------------------------------

for k = 1:length([rptsObject.stellarApertures])

    %-----------------------------------------------------------------------
    % get stellar aperture rows and columns
    %-----------------------------------------------------------------------
    apetureRowOffsets     = [rptsObject.stellarApertures(k).offsets.row];
    apetureColumnOffsets  = [rptsObject.stellarApertures(k).offsets.column];

    % compute mean centers
    apertureCenterRow     = rptsObject.stellarApertures(k).referenceRow;         % 1-base
    apertureCenterColumn  = rptsObject.stellarApertures(k).referenceColumn;      % 1-base

    apertureRows    = apertureCenterRow    + apetureRowOffsets;                  % 1-base
    apertureColumns = apertureCenterColumn + apetureColumnOffsets;               % 1-base

    %-----------------------------------------------------------------------
    % plot the stellar apertures
    %-----------------------------------------------------------------------
    if (k > 1)
        hold on;
    end

    h1 = plot(apertureColumns, apertureRows, 'mo', 'MarkerSize', 10, 'MarkerEdgeColor','m', 'MarkerFaceColor','m');

    % overplot reference row/column
    hold on
    h2 = plot(apertureCenterColumn, apertureCenterRow, 'b+', 'MarkerSize', 10);

end

for j = 1:length(stellarTargetDefinitions)

    %-----------------------------------------------------------------------
    % get stellar target definition rows and columns
    %-----------------------------------------------------------------------
    maskIndex = stellarTargetDefinitions(j).maskIndex + 1;

    targetDefRowOffsets      = [existingMasks(maskIndex).offsets.row];        % corrected for 0-base
    targetDefColumnOffsets   = [existingMasks(maskIndex).offsets.column];     % corrected for 0-base

    targetDefCenterRow       = stellarTargetDefinitions(j).referenceRow + 1;     % corrected for 0-base
    targetDefCenterColumn    = stellarTargetDefinitions(j).referenceColumn + 1;  % corrected for 0-base

    targetDefRows     = targetDefCenterRow    + targetDefRowOffsets;             % corrected for 0-base
    targetDefColumns  = targetDefCenterColumn + targetDefColumnOffsets;          % corrected for 0-base

    %-----------------------------------------------------------------------
    % plot the stellar target definitions
    %-----------------------------------------------------------------------
    hold on
    h3 = plot(targetDefColumns, targetDefRows, 'b.');


    %-----------------------------------------------------------------------
    % plot the (circular) bounding radius for background pixel selection
    % (which may have increased from the input value)
    %-----------------------------------------------------------------------
    %theta  = linspace(0, 2*pi, 500);
    %radius = ones(1, 500) * (boundingRadius + 1);
    %[x, y] = pol2cart(theta, radius);
    %
    %xNew = x + apertureCenterRow;
    %yNew = y + apertureCenterColumn;
    %
    %hold on
    %h4 = plot(yNew, xNew, 'g.');  % plot bounding radius in green

    %-----------------------------------------------------------------------
    % plot the bounding box of the target image (produced by N=boundingRadius
    % convolutions of the input aperture)

    minTargetImageRow = targetBounds(j, 1);
    maxTargetImageRow = targetBounds(j, 2);

    minTargetImageCol = targetBounds(j, 3);
    maxTargetImageCol = targetBounds(j, 4);

    targetImageRows = minTargetImageRow:maxTargetImageRow;
    targetImageCols = minTargetImageCol:maxTargetImageCol;

    hold on
    h4 = plot(repmat(minTargetImageCol, length(targetImageRows), 1), targetImageRows, 'g.');
    plot(repmat(maxTargetImageCol, length(targetImageRows), 1), targetImageRows, 'g.');

    plot(targetImageCols, repmat(minTargetImageRow, length(targetImageCols), 1), 'g.');
    plot(targetImageCols, repmat(maxTargetImageRow, length(targetImageCols), 1), 'g.');
end
grid on


%-----------------------------------------------------------------------
% plot the background pixels target/mask definitions; the target definition
% should be one pixel at position (1, 1), and the mask definition is a list
% of the offsets for all pixels (relative to (1, 1)
%-----------------------------------------------------------------------
bkgdDefRows      = [backgroundMaskDefinition.offsets.row]    + 1;     % corrected for 0-base
bkgdDefColumns   = [backgroundMaskDefinition.offsets.column] + 1;     % corrected for 0-base

%bkgdDefCenterRow       = backgroundTargetDefinition.referenceRow    + 1; % = 1
%bkgdDefCenterColumn    = backgroundTargetDefinition.referenceColumn + 1; % = 1

% above should be consistent with these arrays, which are saved to collect
% the smear and black pixels:
%backgroundRows      = [backgroundIndices.backgroundRows];   %1-base
%backgroundColumns   = [backgroundIndices.backgroundColumns];%1-base

hold on
%h5 = plot(bkgdDefColumns, bkgdDefRows, 'o','color', [0.5 0.2 0.6]);
h5 = plot(bkgdDefColumns, bkgdDefRows, 'o', 'MarkerSize', 8, 'MarkerEdgeColor', 'c');

%-----------------------------------------------------------------------
% plot the smear target/mask definition pixels; all information is in the
% mask definition columns and the target definition rows.  The mask
% definition rows and target definition columns are filled with ones
%-----------------------------------------------------------------------
for i = 1:length([smearTargetDefinitions.referenceRow])

    %smearMaskRows = [smearMaskDefinition.offsets.row]    + 1;   % all ones, corrected for 0-base
    smearMaskCols  = [smearMaskDefinition.offsets.column] + 1;   % cols with target pix, corrected for 0-base

    smearTargetDefRow   = smearTargetDefinitions(i).referenceRow    + 1;  % rows with smear, corrected for 0-base
    %smearTargetDefCol  = smearTargetDefinitions(i).referenceColumn + 1;  % all ones, corrected for 0-base

    smearTargetDefRows = repmat(smearTargetDefRow(:), length(smearMaskCols), 1);

    hold on
    h6 = plot(smearMaskCols(:), smearTargetDefRows, 'g+');
end

%-----------------------------------------------------------------------
% plot the black target/mask definition pixels; all information is in the
% mask definition rows and the target definition columns.  The mask
% definition columns and target definition rows are filled with ones
%-----------------------------------------------------------------------
for i = 1:length([blackTargetDefinitions.referenceColumn])

    blackMaskRows  = [blackMaskDefinition.offsets.row]    + 1;   % rows with target pix, corrected for 0-base
    %blackMaskCols = [blackMaskDefinition.offsets.column] + 1;   % all ones, corrected for 0-base

    %blackTargetDefRow = blackTargetDefinitions(i).referenceRow    + 1;  % all ones, corrected for 0-base
    blackTargetDefCol  = blackTargetDefinitions(i).referenceColumn + 1;  % cols with black, corrected for 0-base

    blackTargetDefCols = repmat(blackTargetDefCol(:), length(blackMaskRows), 1);

    hold on
    h7 = plot(blackTargetDefCols, blackMaskRows, 'gx');
end

if (includeLegendFlag)
    legend([h1 h2 h3 h4 h5 h6 h7], {'Input Aperture', 'Aperture Center', 'Stellar Pixels', 'Target Image Bounds', 'Background Pixels', 'Smear Pixels', 'Black Pixels'}, 'Location', 'Best');
end

title(['Module Output ' num2str( currentModOut) ' [' num2str(ccdModule) ',' num2str(ccdOutput) ']'], 'fontsize', 12);

ylabel('Row Index','fontsize', 12);
xlabel('Column Index','fontsize', 12);

set(gca,'YDir','reverse'); % so the origin is at the top left hand corner as it is for images

%close all;

return;
