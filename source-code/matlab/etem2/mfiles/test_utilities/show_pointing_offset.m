function show_pointing_offset(location)
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

load configuration_files/maskDefinitions;

baseTargetDefinitions = get_target_definitions([location '_base'], 'targets');
baseBackgroundDefinitions = get_target_definitions([location '_base'], 'background');
baseReferenceDefinitions = get_target_definitions([location '_base'], 'reference');

load([location '_base/ccdImage.mat']);
baseCcdImage = ccdImageCR;

basePoi = zeros(size(baseCcdImage));
for t=1:length(baseTargetDefinitions)
    mask = maskDefinitions(baseTargetDefinitions(t).maskIndex);
    basePoi(baseTargetDefinitions(t).referenceRow + [mask.offsets.row] + 1, ...
        baseTargetDefinitions(t).referenceColumn + [mask.offsets.column] + 1) = 1;
end
for t=1:length(baseBackgroundDefinitions)
    mask = maskDefinitions(baseBackgroundDefinitions(t).maskIndex);
    basePoi(baseBackgroundDefinitions(t).referenceRow + [mask.offsets.row] + 1, ...
        baseBackgroundDefinitions(t).referenceColumn + [mask.offsets.column] + 1) = 1;
end
for t=1:length(baseReferenceDefinitions)
    mask = maskDefinitions(baseReferenceDefinitions(t).maskIndex);
    basePoi(baseReferenceDefinitions(t).referenceRow + [mask.offsets.row] + 1, ...
        baseReferenceDefinitions(t).referenceColumn + [mask.offsets.column] + 1) = 1;
end

starTargetDefinitions = get_target_definitions([location '_move_stars'], 'targets');
starBackgroundDefinitions = get_target_definitions([location '_move_stars'], 'background');
starReferenceDefinitions = get_target_definitions([location '_move_stars'], 'reference');

load([location '_move_stars/ccdImage.mat']);
starCcdImage = ccdImageCR;

starPoi = zeros(size(starCcdImage));
for t=1:length(starTargetDefinitions)
    mask = maskDefinitions(starTargetDefinitions(t).maskIndex);
    starPoi(starTargetDefinitions(t).referenceRow + [mask.offsets.row] + 1, ...
        starTargetDefinitions(t).referenceColumn + [mask.offsets.column] + 1) = 1;
end
for t=1:length(starBackgroundDefinitions)
    mask = maskDefinitions(starBackgroundDefinitions(t).maskIndex);
    starPoi(starBackgroundDefinitions(t).referenceRow + [mask.offsets.row] + 1, ...
        starBackgroundDefinitions(t).referenceColumn + [mask.offsets.column] + 1) = 1;
end
for t=1:length(starReferenceDefinitions)
    mask = maskDefinitions(starReferenceDefinitions(t).maskIndex);
    starPoi(starReferenceDefinitions(t).referenceRow + [mask.offsets.row] + 1, ...
        starReferenceDefinitions(t).referenceColumn + [mask.offsets.column] + 1) = 1;
end


% targTargetDefinitions = get_target_definitions([location '_move_stars_and_targets'], 'targets');
% targBackgroundDefinitions = get_target_definitions([location '_move_stars_and_targets'], 'background');
% targReferenceDefinitions = get_target_definitions([location '_move_stars_and_targets'], 'reference');
% 
% load([location '_move_stars_and_targets/ccdImage.mat']);
% targCcdImage = ccdImageCR;
% 
% targPoi = zeros(size(targCcdImage));
% for t=1:length(targTargetDefinitions)
%     mask = maskDefinitions(targTargetDefinitions(t).maskIndex);
%     targPoi(targTargetDefinitions(t).referenceRow + [mask.offsets.row] + 1, ...
%         targTargetDefinitions(t).referenceColumn + [mask.offsets.column] + 1) = 1;
% end
% for t=1:length(targBackgroundDefinitions)
%     mask = maskDefinitions(targBackgroundDefinitions(t).maskIndex);
%     targPoi(targBackgroundDefinitions(t).referenceRow + [mask.offsets.row] + 1, ...
%         targBackgroundDefinitions(t).referenceColumn + [mask.offsets.column] + 1) = 1;
% end
% for t=1:length(targReferenceDefinitions)
%     mask = maskDefinitions(targReferenceDefinitions(t).maskIndex);
%     targPoi(targReferenceDefinitions(t).referenceRow + [mask.offsets.row] + 1, ...
%         targReferenceDefinitions(t).referenceColumn + [mask.offsets.column] + 1) = 1;
% end

figure(1);
ax(1) = subplot(1,2,1);
h = imagesc(baseCcdImage.*basePoi, [0, max(max(baseCcdImage))/6]);
set(h, 'Parent', ax(1));
title('no offset');
colormap(hot);
ax(2) = subplot(1,2,2);
h = imagesc(starCcdImage.*starPoi, [0, max(max(starCcdImage))/6]);
set(h, 'Parent', ax(2));
title('stars offset, not apertures');
colormap(hot);
% ax(3) = subplot(2,2,3);
% h = imagesc(targCcdImage.*targPoi, [0, max(max(targCcdImage))/6]);
% set(h, 'Parent', ax(3));
% title('stars and aperture offset');
% colormap(hot);
linkaxes(ax);

