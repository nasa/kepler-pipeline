%%
% compare centroid and injected motion
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
% find correlations between pixel brightness and injected motion
targetMotion = motionStruct.targetMotion;
pixelSeries = motionStruct.pixelSeries;
targetMaskTable = motionStruct.targetMaskTable;
t = 1:size(pixelSeries(1).pixelValues, 1);
for target=1:length(targetMotion)
    % find the brightest pixel
    [m, brightPixIndex] = max(pixelSeries(target).pixelValues(1,:));
    [stat(target).rowCorrelation, stat(target).rowConfidence] = corrcoef( ...
        targetMotion(target).rowInjectedMotion, ...
        pixelSeries(target).pixelValues(:,brightPixIndex));
    [stat(target).colCorrelation, stat(target).colConfidence] = corrcoef( ...
        targetMotion(target).colInjectedMotion, ...
        pixelSeries(target).pixelValues(:,brightPixIndex));
    rowCorrelation(target) = abs(stat(target).rowCorrelation(1,2));
    rowConfidence(target) = 1 - abs(stat(target).rowConfidence(1,2));
    colCorrelation(target) = abs(stat(target).colCorrelation(1,2));
    colConfidence(target) = 1 - abs(stat(target).colConfidence(1,2));
%     subplot(1,2,1);
%     plotyy(t, targetMotion(target).rowInjectedMotion - targetMotion(target).rowInjectedMotion(1), ...
%         t, pixelSeries(target).pixelValues(:,brightPixIndex) - pixelSeries(target).pixelValues(1,brightPixIndex));
%     subplot(1,2,2);
%     plotyy(t, targetMotion(target).colInjectedMotion - targetMotion(target).colInjectedMotion(1), ...);
%         t, pixelSeries(target).pixelValues(:,brightPixIndex) - pixelSeries(target).pixelValues(1,brightPixIndex));
%     title(['target ' num2str(target) ' of ' num2str(length(targetMotion))]);
%     
%     
%     drawnow
%     pause;
end
figure(100)
subplot(2,2,1);
hist(rowCorrelation, 1000);
title('row correlation');
subplot(2,2,2);
hist(rowConfidence, 1000);
title('row confidence');
subplot(2,2,3);
hist(colCorrelation, 1000);
title('col correlation');
subplot(2,2,4);
hist(colConfidence, 1000);
title('col confidence');
