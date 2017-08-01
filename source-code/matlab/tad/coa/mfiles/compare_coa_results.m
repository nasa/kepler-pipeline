function compare_coa_results(coaResultStruct1, coaResultStruct2)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function compare_coa_results(coaResultStruct1, coaResultStruct2)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Find the optimal aperture pixels that are common to two COA result
% structures, the pixels that are only in the first result structure, and
% the pixels that are only in the second result structure.
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

% Plot the subsets in different colors. Also plot them as overlays on the
% COA complete output images from the first result struct and the second.
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

% Get the images and check the sizes.
image1 = vertcat(coaResultStruct1.completeOutputImage.array);
image2 = vertcat(coaResultStruct2.completeOutputImage.array);

imageSize = size(image1);
if ~isequal(imageSize, size(image2))
    error('images for comparison are not the same size')
end % if

% Get a list of the indices of the optimal aperture pixels for each of the
% COA result structures.
[optimalApertureIndices1] = ...
    get_optimal_aperture_indices(coaResultStruct1, imageSize);
[optimalApertureIndices2] = ...
    get_optimal_aperture_indices(coaResultStruct2, imageSize);

% Find the common indices and the differences.
optimalApertureIndicesCommon = ...
    intersect(optimalApertureIndices1, optimalApertureIndices2);
optimalApertureIndices1Only = ...
    setdiff(optimalApertureIndices1, optimalApertureIndices2);
optimalApertureIndices2Only = ...
    setdiff(optimalApertureIndices2, optimalApertureIndices1);

disp(['Number of pixels in ap1 and ap2 = ', num2str(length(optimalApertureIndicesCommon)), '.']);
disp(['Number of pixels in ap1 but not ap2 = ', num2str(length(optimalApertureIndices1Only)), '.']);
disp(['Number of pixels in ap2 but not ap1 = ', num2str(length(optimalApertureIndices2Only)), '.']);

% Create the figures.
[rc, cc] = ind2sub(imageSize, optimalApertureIndicesCommon);
[r1, c1] = ind2sub(imageSize, optimalApertureIndices1Only);
[r2, c2] = ind2sub(imageSize, optimalApertureIndices2Only);

figure;
plot(cc, rc, 'go')
hold on
plot(c1, r1, 'bs')
plot(c2, r2, 'rd')
axis([1, imageSize(2), 1, imageSize(1)])
title('COA Aperture Comparison')
xlabel('CCD Column (1-based)')
ylabel('CCD Row (1-based)')
legend('Common to Both Optimal Apertures', 'Optimal Apertures 1 Only', ...
    'Optimal Apertures 2 Only')
ax = [];
ax(1) = gca;

figure;
imagesc(log10(image1))
set(gca, 'YDir', 'normal');
colorbar
hold on
plot(cc, rc, 'wo')
plot(c1, r1, 'ws')
plot(c2, r2, 'wd')
title('COA Aperture Overlay on Image 1')
xlabel('CCD Column (1-based)')
ylabel('CCD Row (1-based)')
ax(2) = gca;
linkaxes(ax, 'xy');

figure;
imagesc(log10(image2))
set(gca, 'YDir', 'normal');
colorbar
hold on
plot(cc, rc, 'wo')
plot(c1, r1, 'ws')
plot(c2, r2, 'wd')
title('COA Aperture Overlay on Image 2')
xlabel('CCD Column (1-based)')
ylabel('CCD Row (1-based)')
ax(3) = gca;
linkaxes(ax, 'xy');

figure;
imagesc(image1-image2)
set(gca, 'YDir', 'normal');
colorbar
hold on
plot(cc, rc, 'wo')
plot(c1, r1, 'ws')
plot(c2, r2, 'wd')
title('COA Aperture Overlay on Difference Image1 - Image 2')
xlabel('CCD Column (1-based)')
ylabel('CCD Row (1-based)')
ax(4) = gca;
linkaxes(ax, 'xy');

figure;
plot([coaResultStruct1.optimalApertures.crowdingMetric], ...
    [coaResultStruct2.optimalApertures.crowdingMetric], '.')
hold on
plot([0; 1], [0; 1], '--r')
title('Crowding Metrics Comparison')
xlabel('Crowding Metrics for Optimal Apertures 1')
ylabel('Crowding Metrics for Optimal Apertures 2')

figure;
plot([coaResultStruct1.optimalApertures.fluxFractionInAperture], ...
    [coaResultStruct2.optimalApertures.fluxFractionInAperture], '.')
hold on
plot([0; 1], [0; 1], '--r')
title('Flux Fractions Comparison')
xlabel('Flux Fractions for Optimal Apertures 1')
ylabel('Flux Fractions for Optimal Apertures 2')

hold off

% Return.
return


function [optimalApertureIndices] = ...
get_optimal_aperture_indices(coaResultStruct, imageSize)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function get_optimal_aperture_indices(coaResultStruct, imageSize)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Return sorted indices of pixels in optimal aperture for given COA result
% structure. Note that reference row/column coordinates must be converted
% from 0- to 1-based indexing.
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    
optimalApertureIndices = [];

for iAperture = 1 : length(coaResultStruct.optimalApertures)
    optimalAperture = coaResultStruct.optimalApertures(iAperture);
    referenceRow = optimalAperture.referenceRow + 1;
    referenceColumn = optimalAperture.referenceColumn + 1;
    rowOffsets = [optimalAperture.offsets.row];
    columnOffsets = [optimalAperture.offsets.column];
    optimalApertureIndices = [optimalApertureIndices, ...
        sub2ind(imageSize, referenceRow + rowOffsets, ...
        referenceColumn + columnOffsets)];                                                                            %#ok<AGROW>
end % for iAperture

optimalApertureIndices = sort(optimalApertureIndices);

return
