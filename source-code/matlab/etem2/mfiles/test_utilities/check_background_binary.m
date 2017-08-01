function [centroidx, centroidy] = check_background_binary(location, keplerId, cadenceRange)
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
targetDefs = get_target_definitions(location, 'targets');
pixelData = get_pixel_time_series(location, 'targets');
load configuration_files/maskDefinitions;

target = find([pixelData.keplerId] == keplerId);
nCadences = size(pixelData(target).pixelValues, 1);
mask = maskDefinitions(targetDefs(target).maskIndex);
pixRow = targetDefs(target).referenceRow + 1 + [mask.offsets.row];
pixCol = targetDefs(target).referenceColumn + 1 + [mask.offsets.column];
minRow =  min(pixRow);
minCol =  min(pixCol);

maxVal = max(max(pixelData(target).pixelValues));
minVal = min(min(pixelData(target).pixelValues));

for c=cadenceRange
    if c > nCadences
        break;
    end

    for i=1:length(pixRow)
        targetImage(pixRow(i) - minRow + 1, pixCol(i) - minCol + 1) ...
            = pixelData(target).pixelValues(c,i);
        targetData(i) ...
            = pixelData(target).pixelValues(c,i);
    end
    targetImage = targetImage - minVal;
    minData = min(targetData);
    targetData = targetData - minData;
    flux = sum(sum(targetData));
    centroidx(c) = pixRow*targetData'/flux;
    centroidy(c) = pixCol*targetData'/flux;
%     figure(1);
% %     subplot(1,2,1);
%     imagesc(targetImage, [0, maxVal]);
%     colormap(hot);
%     drawnow;
end
x = 1:length(centroidx);
p = polyfit(x, centroidx, 3);
centroidxResid = centroidx - polyval(p,x);
p = polyfit(x, centroidy, 3);
centroidyResid = centroidy - polyval(p,x);
figure(2);
subplot(1,2,1)
plot(centroidx);
subplot(1,2,2)
plot(centroidy);