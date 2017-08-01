%%
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
targetMotion = motionStruct.targetMotion;
pixelSeries = motionStruct.pixelSeries;
targetMaskTable = motionStruct.targetMaskTable;
figure(100)
for target=1:length(targetMotion)
    subplot(1,2,1);
    plot(targetMotion(target).rowInjectedMotion - targetMotion(target).rowInjectedMotion(1), ...
        targetMotion(target).colInjectedMotion - targetMotion(target).colInjectedMotion(1), 'o', ...);
        targetMotion(target).rowCentroid - targetMotion(target).rowCentroid(1), ...
        targetMotion(target).colCentroid - targetMotion(target).colCentroid(1), ...
        'r+');
    title(['target ' num2str(target) ' of ' num2str(length(targetMotion))]);
    
    subplot(1,2,2)
    cadence = 1;
    targetStruct = pixelSeries(target);
    pixelValues = targetStruct.pixelValues;
    mask = targetMaskTable(targetStruct.maskIndex);
    pixRow = targetStruct.referenceRow + [mask.offsets.row];
    pixCol = targetStruct.referenceColumn + [mask.offsets.column];
    row = pixRow - min(pixRow) + 1;
    col = pixCol - min(pixCol) + 1;
    star = zeros(max(row), max(col));
    for p=1:length(row)
        star(row(p), col(p)) = pixelValues(cadence, p);
    end
    
    imagesc(star);
    colorbar;
    
    drawnow
    pause;
end

%%
figure(500)
plot(motionStruct.meanInjectedRowMotion - motionStruct.meanInjectedRowMotion(1), ...
    motionStruct.meanInjectedColMotion - motionStruct.meanInjectedColMotion(1), 'o', ...
    motionStruct.meanRowMotion - motionStruct.meanRowMotion(1), ...
    motionStruct.meanColMotion - motionStruct.meanColMotion(1), 'r+');
title('mean motion');
legend('mean injected motion', 'mean measured motion');
    
%%
% show the motion that was injected for each pixel
targetMotion = motionStruct.targetMotion;
pixelSeries = motionStruct.pixelSeries;
targetMaskTable = motionStruct.targetMaskTable;
figure(101)
for pix = 1:size(pixelXMotion, 1)
plot(pixelXMotion(pix, :) - pixelXMotion(pix, 1), pixelYMotion(pix, :) - pixelYMotion(pix, 1), '+',...
    targetMotion(target).rowCenterMotion - targetMotion(target).rowCenterMotion(1), ...
    targetMotion(target).colCenterMotion - targetMotion(target).colCenterMotion(1), ...
    'gd');
drawnow
end

%%
% draw the stars in pixelSeries for the selected cadence
targetMotion = motionStruct.targetMotion;
pixelSeries = motionStruct.pixelSeries;
targetMaskTable = motionStruct.targetMaskTable;
cadence = 100;
figure(102)
for target=1:length(targetMotion)
    targetStruct = pixelSeries(target);
    pixelValues = targetStruct.pixelValues;
    mask = targetMaskTable(targetStruct.maskIndex);
    pixRow = targetStruct.referenceRow + [mask.offsets.row];
    pixCol = targetStruct.referenceColumn + [mask.offsets.column];
    row = pixRow - min(pixRow) + 1;
    col = pixCol - min(pixCol) + 1;
    star = zeros(max(row), max(col));
    for p=1:length(row)
        star(row(p), col(p)) = pixelValues(cadence, p);
    end
    
    imagesc(star);
    colorbar;
    pause;
    
    
end

%%
% draw the stars in pixelSeries for the selected target
target = 149;
targetStruct = motionStruct.pixelSeries(target);
targetMaskTable = motionStruct.targetMaskTable;
mask = targetMaskTable(targetStruct.maskIndex);
pixRow = targetStruct.referenceRow + [mask.offsets.row];
pixCol = targetStruct.referenceColumn + [mask.offsets.column];
pixelValues = targetStruct.pixelValues;
row = pixRow - min(pixRow) + 1;
col = pixCol - min(pixCol) + 1;
star = zeros(max(row), max(col));
figure(103)
cadence = 100;
for p=1:length(row)
    star(row(p), col(p)) = pixelValues(cadence, p);
end
imagesc(star);
colorbar
drawnow;
    
% for cadence=1:size(pixelValues, 1)
%     for p=1:length(row)
%         star(row(p), col(p)) = pixelValues(cadence, p);
%     end
%     imagesc(star);
%     colorbar
%     drawnow;
%     
% end

%%
% draw all stars in pixelSeries for the selected cadence
cadence = 100;
ccdImage = zeros(1070, 1132);
figure(104)
for target=1:length(pixelSeries)
    targetStruct = pixelSeries(target);
    pixelValues = targetStruct.pixelValues;
    mask = targetMaskTable(targetStruct.maskIndex);
    pixRow = targetStruct.referenceRow + [mask.offsets.row];
    pixCol = targetStruct.referenceColumn + [mask.offsets.column];
    for p=1:length(pixRow)
        ccdImage(pixRow(p), pixCol(p)) = pixelValues(cadence, p);
    end    
end
% imagesc(ccdImage, [min(ccdImage(ccdImage ~= 0)), 5e3*270] );
imagesc(ccdImage, [0, 1e6] );
