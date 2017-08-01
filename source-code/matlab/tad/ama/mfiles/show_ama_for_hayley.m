%
% Copyright 2017 United States Government as represented by the
% Administrator of the National Aeronautics and Space Administration.
% All Rights Reserved.
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
load show_ama_data

targetDefs = amaResultStruct.targetDefinitions;
nTargets = length(targetDefs);
ccdImage = completeOutputImage;
figure(2);
imagesc(ccdImage, [0, 6e6]);
colormap(flipud(colormap(gray(256))));

% convert target definitions to pixels in a mask image
maskImage = zeros(size(ccdImage));
for t=1:nTargets
    maskDef = maskDefinitions(targetDefs(t).maskIndex+1);
    ap = target_definition_to_image(maskDef); 
    referenceRow = targetDefs(t).referenceRow + 1;
    referenceColumn = targetDefs(t).referenceColumn + 1;
    % draw the mask
    nMaskPix(t) = length([maskDef.offsets.row]);
    for p=1:nMaskPix(t)
        r = referenceRow + maskDef.offsets(p).row;
        c = referenceColumn + maskDef.offsets(p).column;
        maskImage(r, c) = 1;
    end
end

% convert optimal apertures to pixels in an optimal aperture image
optimalApertures = amaParameterStruct.apertureStructs;
optApImage = zeros(size(ccdImage));
nTargets = length(optimalApertures);
for t=1:nTargets
    referenceRow = optimalApertures(t).referenceRow + 1;
    referenceColumn = optimalApertures(t).referenceColumn + 1;
    % draw the mask
    nApPix(t) = length([optimalApertures(t).offsets.row]);
    for p=1:nApPix(t)
        r = referenceRow + optimalApertures(t).offsets(p).row;
        c = referenceColumn + optimalApertures(t).offsets(p).column;
        optApImage(r, c) = 1;
    end
end

diff = maskImage - optApImage;
min(min(diff));

% draw the mask image
figure(3);
imagesc(maskImage);
colormap(flipud(colormap(gray(256))));
maxBrightness = 0.95;

% setup colormap for grayscale and orange
graymap = repmat(0:maxBrightness/2499:maxBrightness, 3,1)'; % make grayscale part
graymap = [flipud(graymap); 1.0 0.5 0.0]; % add an orange color

% draw stars w/ mask overlay via alpha blending
figure(4);
% set up so the gray scale image looks good
maxIm = 3e7;
minIm = min(min(ccdImage));
scaledCcdImage = fix(((min(ccdImage, maxIm) - minIm)/(maxIm - minIm)) * (length(graymap) - 2) ) + 1;
image(scaledCcdImage);
% apply our custom colormap
colormap(graymap);
hold on;
% overlay the image with transparency of 2/5
% first scale maskImage so 0 = white in the gray map and 1 = the last
% color value, which is orange
maskim = image(maskImage*length(graymap), 'AlphaData', 2*maskImage/5);
hold off;

% draw stars w/ optimal aperture overlay via alpha blending
figure(14);
% set up so the gray scale image looks good
maxIm = 3e7;
minIm = min(min(ccdImage));
scaledCcdImage = fix(((min(ccdImage, maxIm) - minIm)/(maxIm - minIm)) * (length(graymap) - 2) ) + 1;
image(scaledCcdImage);
% apply our custom colormap
colormap(graymap);
hold on;
% overlay the image with transparency of 2/5
% first scale maskImage so 0 = white in the gray map and 1 = the last
% color value, which is orange
maskim = image(optApImage*length(graymap), 'AlphaData', 2*optApImage/5);
hold off;

% draw mask and optimal apertures for comparison
% set up linked axes so they zoom together
figure(5);
% ax is a list of axes to link together
ax(1) = subplot(1,3,1);
h = image(optApImage*(length(graymap)-2));
title('optimal aperture and mask');
% assign the image handle to the axis
set(h, 'Parent', ax(1));
colormap(graymap);
hold on;
image(maskImage*length(graymap), 'AlphaData', 2*maskImage/5);
hold off;
ax(2) = subplot(1,3,2);
h = imagesc(maskImage);
title('mask');
set(h, 'Parent', ax(2));
ax(3) = subplot(1,3,3);
h = imagesc(optApImage);
title('optimal aperture');
set(h, 'Parent', ax(3));
% link the axes together
linkaxes(ax);

% graphically display difference between mask and optimal aperture
figure(6);
imagesc(diff);
colorbar;
title('red: in mask but not optimal ap (OK), blue: in optimal ap but not in mask (bad)');

