% script to add custom masks to existing mask table
% for target sets with single halo dimmer than mag 9
% load maskDefinitions_mag9_1halo.mat;
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
load maskDefinitions_ort3_s3_1halo.mat;
% maskTableParametersStruct = maskTableParameterStruct;

% fill in dedicated mask slots with single-pixel dummy masks
assignedMaskStart = maskTableParametersStruct.nStellarMasks;
singlePixImage = ones(1,1);
for i=1:maskTableParametersStruct.nAssignedCustomMasks
	maskDefinitions(assignedMaskStart + i) ...
		= image_to_target_definition(singlePixImage, [1, 1]);	
end

largeMaskStart = maskTableParametersStruct.nStellarMasks ...
    + maskTableParametersStruct.nAssignedCustomMasks;
nLargeMasks = maskTableParametersStruct.nLargeMasks;

masksForMagRange = make_masks_per_magnitude(7:0.25:11, starTdefs, starData);

largeMaskNum = 0;
for i=1:length(masksForMagRange)
    largeMaskNum = largeMaskNum + 1;
    maskDefinitions(largeMaskStart + largeMaskNum) ...
        = masksForMagRange(i);
end
% capture 3-pixel wide saturation spill
largeMaskNum = largeMaskNum + 1;
maskDefinitions(largeMaskStart + largeMaskNum) ...
    = image_to_target_definition(ones(10, 6), [5, 2]);
% capture even more 3-pixel wide saturation spill
largeMaskNum = largeMaskNum + 1;
maskDefinitions(largeMaskStart + largeMaskNum) ...
    = image_to_target_definition(ones(60, 6), [30, 2]);
% capture upper half of the core of a brightest star plus some saturation spill
largeMaskNum = largeMaskNum + 1;
maskImage = zeros(30, 15);
maskImage(1:14,:) = 1;
maskImage(15:end, 6:12) = 1;
maskDefinitions(largeMaskStart + largeMaskNum) ...
    = image_to_target_definition(maskImage, [15, 7]);
% capture lower half of the core of a brightest star plus some saturation spill
largeMaskNum = largeMaskNum + 1;
maskImage = zeros(30, 15);
maskImage(14:end,:) = 1;
maskImage(1:13, 6:12) = 1;
maskDefinitions(largeMaskStart + largeMaskNum) ...
    = image_to_target_definition(maskImage, [15, 7]);

if largeMaskNum > nLargeMasks + 1
    error('too many large masks defined');
end

save maskDefinitions_ort3_s3_1halo_test1.mat maskDefinitions maskTableParametersStruct
mask_definitions_to_xml(maskDefinitions, 'maskDefinitions_ort3_s3_1halo_test1.xml');

return

%%
figure
for m=1:20
    mi = target_definition_to_image(maskDefinitions(largeMaskStart + m));
    imagesc(mi);
    pause;
end

%%
% % script to add custom masks to existing mask table
% % for target sets with single halo dimmer than mag 9
% load maskDefinitions_mag9_1halo.mat;
% % maskTableParametersStruct = maskTableParameterStruct;
% 
% assignedMaskStart = maskTableParametersStruct.nStellarMasks;
% singlePixImage = ones(1,1);
% for i=1:maskTableParametersStruct.nAssignedCustomMasks
% 	maskDefinitions(assignedMaskStart + i) ...
% 		= image_to_target_definition(singlePixImage, [1, 1]);	
% end
% 
% largeMaskStart = maskTableParametersStruct.nStellarMasks ...
%     + maskTableParametersStruct.nAssignedCustomMasks;
% nLargeMasks = maskTableParametersStruct.nLargeMasks;
% 
% % make a mask for magnitude 9 stars
% % load the mask image
% load mag9_mask.mat;
% % add halo and undershoot to the image
% [nRows, nCols] = size(maskImage);
% doubleSum  = sum(sum(maskImage));
% centerRow = round(sum(sum(maskImage,2).*(1:nRows)') / doubleSum);
% centerCol = round(sum(sum(maskImage,1).*(1:nCols)) / doubleSum);
% [maskImage, maskCenter] = apply_halo(maskImage, ...
%     [centerRow, centerCol], 1, 1);
% 
% largeMaskNum = 1;
% maskDefinitions(largeMaskStart + largeMaskNum) ...
%     = image_to_target_definition(maskImage, maskCenter);
% % capture 2-pixel wide saturation spill
% largeMaskNum = 2;
% maskDefinitions(largeMaskStart + largeMaskNum) ...
%     = image_to_target_definition(ones(10, 5), [5, 2]);
% % capture 3-pixel wide saturation spill
% largeMaskNum = 3;
% maskDefinitions(largeMaskStart + largeMaskNum) ...
%     = image_to_target_definition(ones(20, 6), [10, 2]);
% % capture even more 3-pixel wide saturation spill
% largeMaskNum = 4;
% maskDefinitions(largeMaskStart + largeMaskNum) ...
%     = image_to_target_definition(ones(60, 6), [30, 2]);
% % capture even more 3-pixel wide saturation spill
% largeMaskNum = 5;
% maskDefinitions(largeMaskStart + largeMaskNum) ...
%     = image_to_target_definition(ones(100, 6), [50, 2]);
% % capture upper half of the core of a brightest star plus some saturation spill
% largeMaskNum = 6;
% maskImage = zeros(30, 15);
% maskImage(1:14,:) = 1;
% maskImage(15:end, 6:12) = 1;
% maskDefinitions(largeMaskStart + largeMaskNum) ...
%     = image_to_target_definition(maskImage, [15, 7]);
% % capture lower half of the core of a brightest star plus some saturation spill
% largeMaskNum = 7;
% maskImage = zeros(30, 15);
% maskImage(14:end,:) = 1;
% maskImage(1:13, 6:12) = 1;
% maskDefinitions(largeMaskStart + largeMaskNum) ...
%     = image_to_target_definition(maskImage, [15, 7]);
% % capture a moderately bright star with some saturation spill
% largeMaskNum = 8;
% maskImage = zeros(22, 12);
% maskImage(7:14, :) = 1;
% maskImage(:, 5:9) = 1;
% maskDefinitions(largeMaskStart + largeMaskNum) ...
%     = image_to_target_definition(maskImage, [11, 6]);
% % capture a bright star with some saturation spill
% largeMaskNum = 9;
% maskImage = zeros(60, 15);
% maskImage(22:34, :) = 1;
% maskImage(:, 6:12) = 1;
% maskDefinitions(largeMaskStart + largeMaskNum) ...
%     = image_to_target_definition(maskImage, [30, 7]);
% 
% 
% % make some boxes that are likely to be useful
% largeMaskNum = 10;
% maskDefinitions(largeMaskStart + largeMaskNum) ...
%     = image_to_target_definition(ones(50, 5), [25, 2]);
% largeMaskNum = 11;
% maskDefinitions(largeMaskStart + largeMaskNum) ...
%     = image_to_target_definition(ones(75, 5), [38, 2]);
% largeMaskNum = 12;
% maskDefinitions(largeMaskStart + largeMaskNum) ...
%     = image_to_target_definition(ones(5, 20), [2, 10]);
% largeMaskNum = 13;
% maskDefinitions(largeMaskStart + largeMaskNum) ...
%     = image_to_target_definition(ones(20, 20), [10, 10]);
% largeMaskNum = 14;
% maskDefinitions(largeMaskStart + largeMaskNum) ...
%     = image_to_target_definition(ones(10, 10), [5, 5]);
% largeMaskNum = 15;
% maskDefinitions(largeMaskStart + largeMaskNum) ...
%     = image_to_target_definition(ones(14, 14), [7, 7]);
% largeMaskNum = 16;
% maskDefinitions(largeMaskStart + largeMaskNum) ...
%     = image_to_target_definition(ones(18, 18), [9, 9]);
% largeMaskNum = 17;
% maskDefinitions(largeMaskStart + largeMaskNum) ...
%     = image_to_target_definition(ones(10, 20), [5, 10]);
% largeMaskNum = 18;
% maskDefinitions(largeMaskStart + largeMaskNum) ...
%     = image_to_target_definition(ones(6, 10), [3, 5]);
% largeMaskNum = 19;
% maskDefinitions(largeMaskStart + largeMaskNum) ...
%     = image_to_target_definition(ones(8, 14), [4, 7]);
% largeMaskNum = 20;
% maskDefinitions(largeMaskStart + largeMaskNum) ...
%     = image_to_target_definition(ones(6, 18), [3, 9]);
% 
% if largeMaskNum > nLargeMasks
%     error('to many large masks defined');
% end
% 
% save maskDefinitions_mag9_1halo_badguess.mat maskDefinitions maskTableParametersStruct
% 
% return
% 

