function show_ama(targetDefs, maskDefinitions, completeOutputImage, optimalApertures, figureOffset)
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

if nargin < 5
    figureOffset = 0;
end

nTargets = length(targetDefs);
% ccdImage = zeros(1024 + 46, 1100 + 32);
% load 'completeOutputImage.mat';
ccdImage = completeOutputImage;
% ccdImage(21:21+1023, 13:13+1099) = completeOutputImage;
% ccdImage = struct_to_array2d(coaResultStruct.completeOutputImage);
% ccdImage = zeros(1070, 1132);

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


% figure(3 + figureOffset);
% imagesc(maskImage);
% colormap(flipud(colormap(gray(256))));
maxBrightness = 0.95;

graymap = repmat(0:maxBrightness/2499:maxBrightness, 3,1)';
graymap = [flipud(graymap); 1.0 0.5 0.0];


figure(4 + figureOffset);
% maxIm = max(max(ccdImage));
maxIm = 3e6;
minIm = min(min(ccdImage));
scaledCcdImage = fix(((min(ccdImage, maxIm) - minIm)/(maxIm - minIm)) * (length(graymap) - 2) ) + 1;
image(scaledCcdImage);
colormap(graymap);
hold on;
maskim = image(maskImage*length(graymap), 'AlphaData', 2*maskImage/5);
hold off;

optApImage = zeros(size(ccdImage));
nTargets = length(optimalApertures);
for t=1:nTargets
    if optimalApertures(t).keplerId ~= -1
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
end

% diff = maskImage - optApImage;
% min(min(diff));
figure(5 + figureOffset);
ax(1) = subplot(1,2,1);
h = image(optApImage*(length(graymap)-2));
set(h, 'Parent', ax(1));
colormap(graymap);
hold on;
image(maskImage*length(graymap), 'AlphaData', 2*maskImage/5);
hold off;
ax(2) = subplot(1,2,2);
h = imagesc(ccdImage, [0, 6e6]);
colormap(flipud(colormap(gray(256))));
set(h, 'Parent', ax(2));
linkaxes(ax);


figure(6 + figureOffset);
image(optApImage*(length(graymap)-2));
colormap(graymap);
hold on;
image(maskImage*length(graymap), 'AlphaData', 2*maskImage/5);
hold off;

% 
% figure(6);
% imagesc(diff);
% colorbar;
% title('red: in mask but not optimal ap (OK), blue: in optimal ap but not in mask (bad)');
% 
% for t=1:nTargets
%     maskDef = maskDefinitions(targetDefs(t).maskIndex);
%     ap = target_definition_to_image(maskDef); 
%     tap = targetDefs(t).aperture;
%     ccd = zeros(1070, 1132);
%     k = find([apertureDefinitionStruct.keplerId] == targetDefs(t).keplerId);
%     referenceRow = targetDefs(t).referenceRow;
%     referenceColumn = targetDefs(t).referenceColumn;
%     % draw the mask
%     nMaskPix = length([maskDef.offsets.row]);
%     for p=1:nMaskPix
%         r = referenceRow + maskDef.offsets(p).row;
%         c = referenceColumn + maskDef.offsets(p).column;
%         ccd(r, c) = ccd(r, c) + 1/4;
%     end
% %     ccd(referenceRow, referenceColumn) = ccd(referenceRow, referenceColumn) + 1/4;
%     % draw the aperture
%     nAperturePix = length([apertureDefinitionStruct(k).offsets.row]);
%     referenceRow = apertureDefinitionStruct(k).referenceRow;
%     referenceColumn = apertureDefinitionStruct(k).referenceColumn;
%     for p=1:nAperturePix
%         r = referenceRow + apertureDefinitionStruct(k).offsets(p).row;
%         c = referenceColumn + apertureDefinitionStruct(k).offsets(p).column;
%         ccd(r, c) = ccd(r, c) + 2/4;
%     end
%     ccd(referenceRow, referenceColumn) = ccd(referenceRow, referenceColumn) + 1/4;
%     if any(any(ccd == 1/2)) || 1
%         figure(1);
%         subplot(1,2,1);
%         imagesc(ccd);
%         title(['t ' num2str(t) ' refR=' num2str(referenceRow) ' refC=' ...
%             num2str(referenceColumn)]);
%         axis([referenceColumn-10 referenceColumn+10 referenceRow-10 referenceRow+10]);
%         subplot(1,2,2);
%         imagesc(ccdImage, [0 1.30E+06]);
%         colormap hot(256);
%         axis([referenceColumn-10 referenceColumn+10 referenceRow-10 referenceRow+10]);
%         pause;
%     end
% end
