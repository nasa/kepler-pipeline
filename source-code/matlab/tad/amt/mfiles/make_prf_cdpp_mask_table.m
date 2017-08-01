function make_prf_cdpp_mask_table(catalogFilename, maskgenResultsLocation, ...
    pdqTargetList, outputFilenameHeader)
% script to add custom masks to existing mask table
% for prf/cdpp
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

% get the mask table from the maskgen run

load([maskgenResultsLocation '/amt-outputs-0.mat']);
maskDefinitions = outputsStruct.maskDefinitions;

% get the target definitions from the inputs to the maskgen run
load([maskgenResultsLocation '/amt-inputs-0.mat']);
optAps = inputsStruct.apertureStructs;
maskTableParametersStruct = inputsStruct.maskTableParametersStruct;

% get the catalog containing magnitude information 
load(catalogFilename); % loads catalog

% fill in the magnitude information and whether a target is a pdq stellar target
if isempty(pdqTargetList)
	pdqKicIds =  [];
else
	pdqKicIds = parse_planetary_target_definition_file(pdqTargetList);
end

for i=1:length(optAps)
	optAps(i).keplerMagnitude = catalog.keplerMagnitude(catalog.keplerId == optAps(i).keplerId);
	[optAps(i).aperture, optAps(i).center] = target_definition_to_image(optAps(i));
	% add halos and undershoot
	[optAps(i).aperture, optAps(i).center] = apply_halo(optAps(i).aperture, optAps(i).center, 2, 1);
	if ismember(optAps(i).keplerId, pdqKicIds)
		optAps(i).isPdqStellarTarget = true;
	else
		optAps(i).isPdqStellarTarget = false;
	end
end

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

masksForMagRange = make_masks_per_magnitude(7:0.25:11, optAps, optAps);

largeMaskNum = 0;
for i=1:length(masksForMagRange)
    largeMaskNum = largeMaskNum + 1;
    maskDefinitions(largeMaskStart + largeMaskNum) ...
        = masksForMagRange(i);
end
% capture 6-pixel wide saturation spill
largeMaskNum = largeMaskNum + 1;
maskDefinitions(largeMaskStart + largeMaskNum) ...
    = image_to_target_definition(ones(10, 8), [5, 4]);
% capture even more 6-pixel wide saturation spill
largeMaskNum = largeMaskNum + 1;
maskDefinitions(largeMaskStart + largeMaskNum) ...
    = image_to_target_definition(ones(60, 8), [30, 4]);
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
% make some smaller large masks
largeMaskNum = largeMaskNum + 1;
maskDefinitions(largeMaskStart + largeMaskNum) ...
    = image_to_target_definition(ones(10, 10), [5, 5]);
largeMaskNum = largeMaskNum + 1;
maskDefinitions(largeMaskStart + largeMaskNum) ...
    = image_to_target_definition(ones(10, 12), [5, 6]);
largeMaskNum = largeMaskNum + 1;
maskDefinitions(largeMaskStart + largeMaskNum) ...
    = image_to_target_definition(ones(12, 12), [6, 6]);
largeMaskNum = largeMaskNum + 1;
maskDefinitions(largeMaskStart + largeMaskNum) ...
    = image_to_target_definition(ones(13, 13), [6, 6]);
	
% make the mask for pdq targets
if any([optAps.isPdqStellarTarget]==true)
	pdqAps = optAps([optAps.isPdqStellarTarget]);
	pdqMask = make_rpts_mask(pdqAps, 0, 0, 1);
	largeMaskNum = largeMaskNum + 1;
	maskDefinitions(largeMaskStart + largeMaskNum) = pdqMask;
end

if largeMaskNum > nLargeMasks + 1
    error('too many large masks defined');
end

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


