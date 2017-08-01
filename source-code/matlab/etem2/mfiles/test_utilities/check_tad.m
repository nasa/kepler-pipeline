function check_tad(location)
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

load([location filesep 'catalogData.mat']);
load([location filesep 'ETEM2_tad_inputs.mat']);
targetDefs = amaResultStruct.targetDefinitions;
TADrows = [targetDefs.referenceRow]+1;
TADcols = [targetDefs.referenceColumn]+1;
targetIds = [targetDefs.keplerId];
etemTargets = ismember([catalogData.kicId], targetIds);
etemRows = catalogData.row(etemTargets);
etemCols = catalogData.column(etemTargets);

figure(300)
plot(etemCols + 12, etemRows + 20, '+', TADcols, TADrows, 'ro');
legend('etem star locations', 'tad reference pixel locations');

load([location filesep 'ccdObject.mat']);
load([location filesep 'ccdImage.mat']);

% make an array with 1 for pixels of interest
poi = zeros(size(ccdImage));
poiStruct = get(ccdObject, 'poiStruct');
poi(poiStruct.poiPixelIndex) = 1;

% construct an image with ones for the defined TAD pixels
tadImage = zeros(size(ccdImage));
% do targets
load('configuration_files/maskDefinitions.mat');
for t=1:length(targetDefs)
    mask = maskDefinitions(targetDefs(t).maskIndex+1);
    pixRow = targetDefs(t).referenceRow + 1 + [mask.offsets.row];
    pixCol = targetDefs(t).referenceColumn + 1 + [mask.offsets.column];
    for i=1:length(pixRow)
        tadImage(pixRow(i), pixCol(i)) = 1;
    end
end
backDefs = bpaResultStruct.targetDefinitions;
backMaskDefinitions = bpaResultStruct.maskDefinitions;
for t=1:length(backDefs)
    mask = backMaskDefinitions(backDefs(t).maskIndex+1);
    pixRow = backDefs(t).referenceRow + 1 + [mask.offsets.row];
    pixCol = backDefs(t).referenceColumn + 1 + [mask.offsets.column];
    for i=1:length(pixRow)
        tadImage(pixRow(i), pixCol(i)) = 1;
    end
end


figure(310)
ax(1) = subplot(1,2,1);
h = imagesc(ccdImage.*tadImage, [0 max(max(ccdImage))/5]);
set(h, 'Parent', ax(1));
title('tad apertures');
colormap(hot);
ax(2) =subplot(1,2,2);
h = imagesc(ccdImage.*poi, [0 max(max(ccdImage))/5]);
set(h, 'Parent', ax(2));
title('etem2 pixels of interest');
colormap(hot);
linkaxes(ax);
