function prfImage = draw_prf_input_structure(targetStarsStruct, cadence, crowding)
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
if nargin < 2
    cadence = 1;
end

prfImage = zeros(1070,1132);
% targetStarsStruct = prfInputStruct.targetStarsStruct;
nTargets = length(targetStarsStruct);
for t=1:nTargets
    pixelStruct = targetStarsStruct(t).pixelTimeSeriesStruct;
    nPixels = length(pixelStruct);
    for p=1:nPixels
        prfImage(pixelStruct(p).row, pixelStruct(p).column) = ...
            pixelStruct(p).values(cadence);
    end
end

figure
imagesc(prfImage, [0 4e5]);
colormap(hot);

% % compute centroids for each time
% for t=1:nTargets
%     if t == 2
%         continue;
%     end
%     pixelStruct = targetStarsStruct(t).pixelTimeSeriesStruct;
%     nPixels = length(pixelStruct);
%     nCadences = length(pixelStruct(1).values);
%     pixVal = [];
%     for c = 1:nCadences
%         for p=1:nPixels
%             pixVal(p) = pixelStruct(p).values(c);
%         end
%         flux = sum(pixVal);
%         rowCentroid(t,c) = sum([pixelStruct.row].*pixVal)/flux;
%         colCentroid(t,c) = sum([pixelStruct.column].*pixVal)/flux;
%     end
%     % shift all centroids to the same center
%     rowCentroid(t,:) = rowCentroid(t,:) - rowCentroid(t,1);
%     colCentroid(t,:) = colCentroid(t,:) - colCentroid(t,1);
% end
% 
% stdRowCentroid = std(rowCentroid, 0, 2);
% stdColCentroid = std(colCentroid, 0, 2);
% meanStdRow = mean(stdRowCentroid);
% meanStdCol = mean(stdColCentroid);
% 
% if nargin < 3
%     goodTargets = find(stdRowCentroid < 2*meanStdRow & stdColCentroid < 2*meanStdCol);
% else
%     goodTargets = find(crowding > 0.8);
% end
% 
% meanRowCentroid = mean(rowCentroid(goodTargets, :), 1);
% meanColCentroid = mean(colCentroid(goodTargets, :), 1);
% figure;
% plot(meanRowCentroid, meanColCentroid, '+');
% 
% keyboard
