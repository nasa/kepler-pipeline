function amaObject = assign_masks( amaObject )
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function amaObject = assign_masks( amaObject )
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% this algorithm is described in KADN-26107 "Target Aperture Mask
% Selection".  Inputs and outputs are described in amaClass.m
%
% This algorithm maps optimal apertures to masks
%
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

maskDefinitions = amaObject.maskDefinitions; % table of available aperture masks
nMasks = length(maskDefinitions); % number of masks
apertureStructs = amaObject.apertureStructs; % table of apertures to be assigned to masks
nTargetAps = length(apertureStructs); % number of apertures
fcConstants = amaObject.fcConstants;
nMaskedSmear = amaObject.fcConstants.nMaskedSmear;
nLeadingBlack = amaObject.fcConstants.nLeadingBlack;
nRowsImaging = amaObject.fcConstants.nRowsImaging;
nColsImaging = amaObject.fcConstants.nColsImaging;
debugFlag = amaObject.debugFlag;

if ~isempty(amaObject.maskTableParametersStruct)
    dedicatedMaskStart = amaObject.maskTableParametersStruct.nStellarMasks + 1; 
    dedicatedMaskEnd = dedicatedMaskStart + amaObject.maskTableParametersStruct.nAssignedCustomMasks; 
else
    dedicatedMaskStart = -1;
    dedicatedMaskEnd = -1;
end

% pre-allocate the output struct, one for each input aperture.
% On completion there will be one targetDef for each assigned mask, which
% may be more than the number of input apertures if an aperture is assigned
% more than one mask.
targetDefs = repmat(struct( ...
    'keplerId', 0,... % id of target from the input structure
    'maskIndex', 0,... % index of mask this target is assigned to
    'referenceRow', 0,... % reference row for mask
    'referenceColumn', 0,... % reference column for mask
    'excessPixels', 0,... % # of pixels in used mask not in aperture   
    'status', 0 ),  1, nTargetAps); % status indicates successful mask assignment: 
%           status = 1: mask assigned, no problems
%           status = -1: no mask assigned
%           status = -2: mask assigned but has pixels off the CCD
%           status = -3: mask assigned but has pixels off the the visible CCD

% the following fields are for debugging output
targetDefData = repmat(struct( ...
    'originalAperture', 0,... % image of original aperture, for diagnostics
    'aperture', 0,... % image of used aperture (may be halo aperture) for diagnostics
    'apertureNumPix', 0,... % # of pixels in used aperture
    'maskNumPix', 0 ),  1, nTargetAps); % status indicates successful mask assignment: 

% extend the information in maskDefinitions for convenience, adding useful
% fields including image of the mask
for m=1:nMasks
    maskStruct = maskDefinitions(m);
    if ~isempty(maskStruct.offsets)
        maskDefinitions(m).maskIndex = m;
        maskDefinitions(m).nOffsets = length(maskStruct.offsets);
        % create mask image from offsets data
        [maskDefinitions(m).mask maskDefinitions(m).center] = target_definition_to_image(maskStruct);
        maskDefinitions(m).size = size(maskDefinitions(m).mask);
        % get the bounding box etc. of the mask
        [area, numRowsInAp, numColsInAp, maskDefinitions(m).apertureBoundingBox] = ...
            square_ap(maskDefinitions(m).mask); % find the bounding box of the ap    
    else
        maskDefinitions(m).nOffsets = 0;
    end
end
% sort in ascending order of number of offsets
[s, sortIndex] = sort([maskDefinitions.nOffsets]);
sortedMaskDefinitions = maskDefinitions(sortIndex);

% index into output target defs.  May end up with more targetDefs than apertures
% if multiple masks are assigned to the same keplerId
targetIndex = 1; 

targetProperties = repmat(struct( ...
    'numHalos', 0,... 
    'undershootColumn', 0,... 
    'wantsDedicatedMask', 0),  1, nTargetAps); % status indicates successful mask assignment: 
% parse the labels
for t = 1:nTargetAps
	if isempty(apertureStructs(t).offsets)
		continue;
    end
    targetStruct = apertureStructs(t); % pull the target ap data of interest
    if ~isfield(targetStruct, 'labels')
        targetStruct.labels = [];
    end
    if ~isfield(targetStruct, 'custom')
        targetStruct.custom = 0;
    end
    if isempty(targetStruct.labels)
        % assign default lables appropriate to this target
        if targetStruct.custom
            if isfield(amaObject.amaConfigurationStruct, 'defaultCustomLabels')
                targetStruct.labels = amaObject.amaConfigurationStruct.defaultCustomLabels;
            end
        else
            if isfield(amaObject.amaConfigurationStruct, 'defaultStellarLabels')
                targetStruct.labels = amaObject.amaConfigurationStruct.defaultStellarLabels;
            end
        end
    end
    
    % parse the lables
    wantsDedicatedMask = 0;    
    for label = 1:length(targetStruct.labels)
        switch targetStruct.labels{label}
            case {'TAD_NO_HALO'}
                targetProperties(t).numHalos = 0;
            case {'TAD_ONE_HALO'}
                targetProperties(t).numHalos = 1;
            case {'TAD_TWO_HALO', 'TAD_TWO_HALOS'}
                targetProperties(t).numHalos = 2;
            case {'TAD_THREE_HALO', 'TAD_THREE_HALOS'}
                targetProperties(t).numHalos = 3;
            case {'TAD_FOUR_HALO', 'TAD_FOUR_HALOS'}
                targetProperties(t).numHalos = 4;
            case {'TAD_FIVE_HALO', 'TAD_FIVE_HALOS'}
                targetProperties(t).numHalos = 5;
            case {'TAD_SIX_HALO', 'TAD_SIX_HALOS'}
                targetProperties(t).numHalos = 6;
            case {'TAD_SEVEN_HALO', 'TAD_SEVEN_HALOS'}
                targetProperties(t).numHalos = 7;
            case {'TAD_EIGHT_HALO', 'TAD_EIGHT_HALOS'}
                targetProperties(t).numHalos = 8;
            case {'TAD_NINE_HALO', 'TAD_NINE_HALOS'}
                targetProperties(t).numHalos = 9;
            case {'TAD_TEN_HALO', 'TAD_TEN_HALOS'}
                targetProperties(t).numHalos = 10;
            case {'TAD_ELEVEN_HALO', 'TAD_ELEVEN_HALOS'}
                targetProperties(t).numHalos = 11;
            case {'TAD_TWELVE_HALO', 'TAD_TWELVE_HALOS'}
                targetProperties(t).numHalos = 12;
            case {'TAD_THIRTEEN_HALO', 'TAD_THIRTEEN_HALOS'}
                targetProperties(t).numHalos = 13;
            case {'TAD_FOURTEEN_HALO', 'TAD_FOURTEEN_HALOS'}
                targetProperties(t).numHalos = 14;
            case {'TAD_FIFTEEN_HALO', 'TAD_FIFTEEN_HALOS'}
                targetProperties(t).numHalos = 15;
            case {'TAD_SIXTEEN_HALO', 'TAD_SIXTEEN_HALOS'}
                targetProperties(t).numHalos = 16;
            case {'TAD_SEVENTEEN_HALO', 'TAD_SEVENTEEN_HALOS'}
                targetProperties(t).numHalos = 17;
            case {'TAD_EIGHTEEN_HALO', 'TAD_EIGHTEEN_HALOS'}
                targetProperties(t).numHalos = 18;
            case {'TAD_NINETEEN_HALO', 'TAD_NINETEEN_HALOS'}
                targetProperties(t).numHalos = 19;
            case {'TAD_TWENTY_HALO', 'TAD_TWENTY_HALOS'}
                targetProperties(t).numHalos = 20;
            case {'TAD_ADD_UNDERSHOOT_COLUMN'}
                targetProperties(t).undershootColumn = 1;
            case {'TAD_NO_UNDERSHOOT_COLUMN'}
                targetProperties(t).undershootColumn = 0;
            case {'TAD_DEDICATED_MASK'}
                targetProperties(t).wantsDedicatedMask = 1;
            otherwise % assume a generic stellar target
                targetProperties(t).wantsDedicatedMask = 0;
                targetProperties(t).numHalos = 1;
                targetProperties(t).undershootColumn = 1;
        end
    end
    % for backwards compatability: if useHaloApertures exists override the
    % labels
    if isfield(amaObject.amaConfigurationStruct, 'useHaloApertures')
        targetProperties(t).numHalos = amaObject.amaConfigurationStruct.useHaloApertures;
        if targetProperties(t).numHalos > 0
            targetProperties(t).undershootColumn = 1;
        else
            targetProperties(t).undershootColumn = 0;
        end
        targetProperties(t).wantsDedicatedMask = 0;
    end
end
% create the masks for dedicated targets
% only one mask is created for each dedicated target
dedicatedMaskApIndex = find([targetProperties.wantsDedicatedMask]);
for ti = 1:length(dedicatedMaskApIndex)
    t = dedicatedMaskApIndex(ti); % index into apertureStructs
	if isempty(apertureStructs(t).offsets)
		continue;
    end
    targetStruct = apertureStructs(t); % pull the target ap data of interest
    
    % create aperture pixel image from the offsets data
    [aperture apertureCenter] = target_definition_to_image( targetStruct );
      
    [aperture, apertureCenter] = apply_halo(aperture, apertureCenter, ...
        targetProperties(t).numHalos, targetProperties(t).undershootColumn);
    
    % make sure all pixels are on the CCD
    targetRefPix = [targetStruct.referenceRow, targetStruct.referenceColumn];
    aperture = trim_aperture(aperture, apertureCenter, targetRefPix, ...
        amaObject.moduleDescriptionStruct);
    
    % actually do the mask assignment and creation, throw away the
    % assignment result
    [status maskList maskDefinitions, amaObject] ...
        = assign_dedicated_masks( amaObject, targetStruct, ...
        aperture, apertureCenter, maskDefinitions);
    [s, sortIndex] = sort([maskDefinitions.nOffsets]);
    sortedMaskDefinitions = maskDefinitions(sortIndex);
end

% actual assignment of input apertures to mask
for t = 1:nTargetAps
	if isempty(apertureStructs(t).offsets)
		continue;
    end
    targetStruct = apertureStructs(t); % pull the target ap data of interest
    
%     if targetStruct.keplerId == 5429163
%         disp('here');
%     end
    % create aperture pixel image from the offsets data
    [aperture apertureCenter] = target_definition_to_image( targetStruct );
    originalAperture = aperture;
      
    [aperture, apertureCenter] = apply_halo(aperture, apertureCenter, ...
        targetProperties(t).numHalos, targetProperties(t).undershootColumn);
	
    % make sure all pixels are on the CCD
    targetRefPix = [targetStruct.referenceRow, targetStruct.referenceColumn];
    aperture = trim_aperture(aperture, apertureCenter, targetRefPix, ...
        amaObject.moduleDescriptionStruct);
    
    % actually do the mask assignment, with maskList containing the mask(s)
    % assigned to the input aperture
    if targetProperties(t).wantsDedicatedMask
        [status maskList maskDefinitions, amaObject] ...
            = assign_dedicated_masks( amaObject, targetStruct, ...
            aperture, apertureCenter, maskDefinitions);
        [s, sortIndex] = sort([maskDefinitions.nOffsets]);
        sortedMaskDefinitions = maskDefinitions(sortIndex);
    else
        [status maskList] = find_mask( amaObject, targetStruct, ...
            amaObject.moduleDescriptionStruct, ...
            aperture, apertureCenter, sortedMaskDefinitions, [], 0 );
    end
    
    % check that the assigned mask actually encloses the requested aperture
    
    maskRows = [];
    maskColumns = [];    
    for m = 1:maskList.numMasks
        maskIndex = maskList.componentMasks(m).maskIndex;
        centerOffset = maskList.componentMasks(m).centerOffset;
        maskRows = [maskRows targetStruct.referenceRow - centerOffset(1) ...
            + [maskDefinitions(maskIndex).offsets.row]];
        maskColumns = [maskColumns targetStruct.referenceColumn - centerOffset(2) ...
            + [maskDefinitions(maskIndex).offsets.column]];
    end
    maskPix = [maskRows(:), maskColumns(:)];
    requestedAp = image_to_target_definition(aperture, apertureCenter);
    apRows = targetStruct.referenceRow + [requestedAp.offsets.row];
    apCols = targetStruct.referenceColumn + [requestedAp.offsets.column];
    badPix = find(apRows <= nMaskedSmear | apRows >= nMaskedSmear + nRowsImaging + 1 ...
        | apCols <= nLeadingBlack | apCols >= nLeadingBlack + nColsImaging + 1);
    apRows(badPix) = [];
    apCols(badPix) = [];
    apPix = [apRows(:), apCols(:)];
    if ~all(ismember(apPix, maskPix, 'rows'))
        disp(targetStruct)
        warning('TAD:AMA:assign_masks:not all pixels in the aperture are in the mask');
    end

%     if( status == -1 )
%         error('TAD:AMA:assign_masks', 'failed to assign mask');
%     else
        % set up output struct, which includes several diagnostic outputs
   if( status ~= -1 )        
       for m = 1:maskList.numMasks
            targetDefs( targetIndex ).keplerId = apertureStructs(t).keplerId;
            maskIndex = maskList.componentMasks(m).maskIndex;
            targetDefs( targetIndex ).maskIndex = maskIndex;
            amaObject.usedMasks(maskIndex) = true;
            % set the reference row and column of the mask by taking the
            % difference between the target's reference row and column and
            % the center offsets computed in find_mask for this mask
            centerOffset = maskList.componentMasks(m).centerOffset;
            targetDefs( targetIndex ).referenceRow = ...
                targetStruct.referenceRow - centerOffset(1);
            targetDefs( targetIndex ).referenceColumn = ...
                targetStruct.referenceColumn - centerOffset(2);
            targetDefData( targetIndex ).originalAperture = originalAperture;
            targetDefData( targetIndex ).aperture = aperture;
            targetDefData( targetIndex ).apertureNumPix = ...
                maskList.componentMasks(m).numPixInAp;
            targetDefData( targetIndex ).maskNumPix = ...
                maskList.componentMasks(m).numPixInMask;
            targetDefs( targetIndex ).excessPixels = ...
                targetDefData( targetIndex ).maskNumPix - ...
                targetDefData( targetIndex ).apertureNumPix;
            targetDefs( targetIndex ).status = status;
            targetDefs( targetIndex ) = check_mask_on_ccd(amaObject, ...
                targetDefs( targetIndex ), maskDefinitions, targetStruct, requestedAp);
            targetIndex = targetIndex + 1;
        end
    end
end
amaObject.targetDefinitions = targetDefs;
amaObject.targetDefData = targetDefData;
if dedicatedMaskStart > 0
    for m=dedicatedMaskStart:min([length(maskDefinitions), dedicatedMaskEnd])
        amaObject.maskDefinitions(m).offsets = maskDefinitions(m).offsets;
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% targetDefs = check_mask_on_ccd(targetDefs)
%
% make sure all pixels on a mask are in the legal range of >= 1 and <= 1070
%
%   inputs: 
%       targetDefs target definition structure
%       maskDefinitions mask definition structure
%
%   output: 
%       targetDefs target definition structure with status set to -2 if a
%       pixel is not in the legal range
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function targetDef = check_mask_on_ccd(amaObject, targetDef, ...
    maskDefinitions, targetStruct, requestedAp)
inputTargetDef = targetDef;
referenceRow = targetDef.referenceRow;
referenceColumn = targetDef.referenceColumn;
% build a list of mask pixel positions in absolute row, column coordinates
maskDef = maskDefinitions(targetDef.maskIndex);
nMaskPix = length([maskDef.offsets.row]);
row = zeros(nMaskPix,1);
column = zeros(nMaskPix,1);
for p=1:nMaskPix
    row(p) = referenceRow + maskDef.offsets(p).row;
    column(p) = referenceColumn + maskDef.offsets(p).column;
end
config = amaObject.moduleDescriptionStruct;
maxRow = config.nRowPix + config.virtualSmear + config.maskedSmear;
maxCol = config.nColPix + config.leadingBlack + config.trailingBlack;
minRow = 1;
minCol = 1;

if any(row < minRow) || any(row > maxRow) || any(column < minRow) || any(column > maxCol)
    % can we fix this by shifting the mask?
    if any(row < minRow)
        targetDef.referenceRow = targetDef.referenceRow + abs(min(row)) + minRow + 1;
    elseif any(row > maxRow)
        targetDef.referenceRow = targetDef.referenceRow - (max(row) - maxRow);
    end
    
    if any(column < minCol)
        targetDef.referenceColumn = targetDef.referenceColumn + abs(min(column)) + minCol + 1;
    elseif any(column > maxCol)
        targetDef.referenceColumn = targetDef.referenceColumn - (max(column) - maxCol);
    end
    
    % check to see if mask still contains optimal ap
    optRow = targetStruct.referenceRow + [requestedAp.offsets.row];
    optCol = targetStruct.referenceColumn + [requestedAp.offsets.column];
    maskRow = targetDef.referenceRow + [maskDef.offsets.row];
    maskCol = targetDef.referenceColumn + [maskDef.offsets.column];
    optPixels = [optRow(:), optCol(:)];
    maskPixels = [maskRow(:), maskCol(:)];

    if any(~ismember(optPixels, maskPixels, 'rows'))
%		disp(['dont have all required ap pixels, kepid = ' num2str(targetDef.keplerId)]);
%        targetDef = inputTargetDef;
        targetDef.status = -2;
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ap = trim_aperture(ap, apCenter, refPix, pixStruct)
%
% trim the aperture to make sure all pixels are on accumulatoin memory
%
%   inputs: 
%       ap image of aperture
%       apCenter [row, column] of center pixel in ap image coordinates
%       refPix [row, column] of apCenter in CCD coordinates
%       pixStruct structure containing CCD size information
%
%   output: 
%       ap image of output aperture with same center pixel
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ap = trim_aperture(ap, apCenter, refPix, pixStruct)
[apFilledRows, apFilledCols] = find(ap == 1);
apFilledRowInCcd = apFilledRows + refPix(1) - apCenter(1);
apFilledColInCcd = apFilledCols + refPix(2) - apCenter(2);
badApPix = find(apFilledRowInCcd < 1 ...
    | apFilledRowInCcd > pixStruct.maskedSmear + pixStruct.nRowPix + pixStruct.virtualSmear ...
    | apFilledColInCcd < 1 ...
    | apFilledColInCcd > pixStruct.leadingBlack + pixStruct.nColPix + pixStruct.trailingBlack);
if ~isempty(badApPix)
	ap(apFilledRows(badApPix), apFilledCols(badApPix)) = 0;
end










