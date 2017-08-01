function make_science_mask_table(catalogFilename, maskgenResultsLocation, ...
    pdqTargetList, socMagListFilename, outputFilenameHeader)
% function make_science_mask_table(catalogFilename, maskgenResultsLocation, ...
%     pdqTargetList, socMagListFilename, outputFilenameHeader);
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

% script to add custom masks to existing mask table
% for prf/cdpp

numScienceHalos = 1;
numPdqHalos = 2;
addUndershoot = 1;
numBrightStarMasks = 18;
magRangeBright = 6.9;
magRangeDim = 11;

% get the mask table from the maskgen run

load([maskgenResultsLocation '/amt-outputs-0.mat']);
maskDefinitions = outputsStruct.maskDefinitions;

% get the target definitions from the inputs to the maskgen run
load([maskgenResultsLocation '/amt-inputs-0.mat']);
optAps = inputsStruct.apertureStructs;
maskTableParametersStruct = inputsStruct.maskTableParametersStruct;

% get the catalog containing magnitude information 
load(catalogFilename); % loads catalog
catalog = apply_soc_mag_list(catalog, socMagListFilename);

% fill in the magnitude information and whether a target is a pdq stellar target
pdqKicIds = parse_planetary_target_definition_file(pdqTargetList);
starApCount = 1;
for i=1:length(optAps)
    keplerMagnitude = catalog.keplerMagnitude(catalog.keplerId == optAps(i).keplerId);
    if ~isempty(keplerMagnitude)
        starAps(starApCount).keplerId = optAps(i).keplerId;
        starAps(starApCount).custom = optAps(i).custom;
        starAps(starApCount).badPixelCount = optAps(i).badPixelCount;
        starAps(starApCount).referenceRow = optAps(i).referenceRow;
        starAps(starApCount).referenceColumn = optAps(i).referenceColumn;
        starAps(starApCount).offsets = optAps(i).offsets;
        starAps(starApCount).labels = optAps(i).labels;
        starAps(starApCount).keplerMagnitude = keplerMagnitude;
        [starAps(starApCount).aperture, starAps(starApCount).center] ...
            = target_definition_to_image(starAps(starApCount));
        % add halos and undershoot
        if ismember(starAps(starApCount).keplerId, pdqKicIds)
            [starAps(starApCount).aperture, starAps(starApCount).center] ...
                = apply_halo(starAps(starApCount).aperture, ...
                starAps(starApCount).center, numPdqHalos, addUndershoot);
            starAps(starApCount).isPdqStellarTarget = true;
        else
            [starAps(starApCount).aperture, starAps(starApCount).center] ...
                = apply_halo(starAps(starApCount).aperture, ...
                starAps(starApCount).center, numScienceHalos, addUndershoot);
            starAps(starApCount).isPdqStellarTarget = false;
        end
        starApCount = starApCount + 1;
    end
end
clear optAps

% initialize a full-size mask table with empty masks where there are no
% generated masks
nTotalNonRptsMasks = 772;
numPreDefinedMasks = length(maskDefinitions);
MasksToFillIn = nTotalNonRptsMasks - numPreDefinedMasks;
singlePixImage = ones(1,1);
for i=1:MasksToFillIn
	maskDefinitions(numPreDefinedMasks + i) ...
		= image_to_target_definition(singlePixImage, [1, 1]);	
end

largeMaskStart = maskTableParametersStruct.nStellarMasks ...
    + maskTableParametersStruct.nAssignedCustomMasks;
nLargeMasks = maskTableParametersStruct.nLargeMasks;

masksForMagRange = make_masks_per_magnitude(magRangeBright:(magRangeDim-magRangeBright)/numBrightStarMasks:magRangeDim, starAps, starAps);

largeMaskNum = 0;
for i=1:length(masksForMagRange)
    largeMaskNum = largeMaskNum + 1;
    maskDefinitions(largeMaskStart + largeMaskNum) ...
        = masksForMagRange(i);
end
% capture 6-pixel wide saturation spill
largeMaskNum = largeMaskNum + 1;
maskDefinitions(largeMaskStart + largeMaskNum) ...
    = image_to_target_definition(ones(20, 6), [10, 3]);
% capture even more 6-pixel wide saturation spill
largeMaskNum = largeMaskNum + 1;
maskDefinitions(largeMaskStart + largeMaskNum) ...
    = image_to_target_definition(ones(40, 6), [25, 3]);
% capture upper half of the core of a brightest star plus some saturation spill
largeMaskNum = largeMaskNum + 1;
maskImage = zeros(30, 15);
maskImage(1:14,:) = 1;
maskImage(15:end, 4:12) = 1;
maskDefinitions(largeMaskStart + largeMaskNum) ...
    = image_to_target_definition(maskImage, [15, 7]);
% capture lower half of the core of a brightest star plus some saturation spill
largeMaskNum = largeMaskNum + 1;
maskImage = zeros(30, 15);
maskImage(14:end,:) = 1;
maskImage(1:13, 4:12) = 1;
maskDefinitions(largeMaskStart + largeMaskNum) ...
    = image_to_target_definition(maskImage, [15, 8]);
% there are no pdq dynamic targets
% make a 1 x 11 mask for PDQ dynamic targets
% largeMaskNum = largeMaskNum + 1;
% maskImage = ones(1, 11);
% maskDefinitions(largeMaskStart + largeMaskNum) ...
%     = image_to_target_definition(maskImage, [1,6]);

% capture 8 x 100 saturation spill
largeMaskNum = largeMaskNum + 1;
maskDefinitions(largeMaskStart + largeMaskNum) ...
    = image_to_target_definition(ones(100, 8), [50, 4]);
% capture 8 x 20 saturation spill
largeMaskNum = largeMaskNum + 1;
maskDefinitions(largeMaskStart + largeMaskNum) ...
    = image_to_target_definition(ones(20, 8), [10, 4]);
% capture 11 x 10 saturation spill
largeMaskNum = largeMaskNum + 1;
maskDefinitions(largeMaskStart + largeMaskNum) ...
    = image_to_target_definition(ones(10, 11), [5, 6]);
% capture 7 x 20 saturation spill
largeMaskNum = largeMaskNum + 1;
maskDefinitions(largeMaskStart + largeMaskNum) ...
    = image_to_target_definition(ones(20, 7), [10, 4]);
% capture 6 x 50 saturation spill
largeMaskNum = largeMaskNum + 1;
maskDefinitions(largeMaskStart + largeMaskNum) ...
    = image_to_target_definition(ones(30, 6), [25, 3]);
% capture 12 x 10 saturation spill
largeMaskNum = largeMaskNum + 1;
maskDefinitions(largeMaskStart + largeMaskNum) ...
    = image_to_target_definition(ones(20, 12), [5, 6]);

	
% make the mask for pdq targets
pdqAps = starAps([starAps.isPdqStellarTarget]);
pdqMask = make_rpts_mask(pdqAps, 0, 0, 1);
largeMaskNum = largeMaskNum + 1;
maskDefinitions(largeMaskStart + largeMaskNum) = pdqMask;

if largeMaskNum > nLargeMasks + 1
    error('too many large masks defined');
end

% 750 is responsible for many large excesses
maskDefinitions(750) ...
    = image_to_target_definition(ones(100, 13), [100, 7]);

% use some unused masks
maskDefinitions(250) ...
    = image_to_target_definition(ones(200, 9), [100, 5]);
maskDefinitions(251) ...
    = image_to_target_definition(ones(120, 9), [60, 5]);
maskDefinitions(252) ...
    = image_to_target_definition(ones(60, 9), [30, 5]);
maskDefinitions(257) ...
    = image_to_target_definition(ones(100, 12), [50, 6]);
maskDefinitions(258) ...
    = image_to_target_definition(ones(60, 12), [30, 6]);

save([outputFilenameHeader '.mat'], 'maskDefinitions', 'maskTableParametersStruct');
mask_definitions_to_xml(maskDefinitions, [outputFilenameHeader '.xml']);

return

%%
figure
for m=1:20
    mi = target_definition_to_image(maskDefinitions(largeMaskStart + m));
    imagesc(mi);
    pause;
end


