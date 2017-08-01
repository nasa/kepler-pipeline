function [dynamicRangeTargetDefinitions] = get_dynamic_range_target_definitions(rptsObject)
% function [dynamicRangeTargetDefinitions] = get_dynamic_range_target_definitions(rptsObject)
%
% function to create target definitions for each of the (input) dynamic range apertures.
% Target definitions are constructed by calling TAD/ama.  Input aperture pixels and
% output target definition pixels are validated to ensure they are on the photometric CCD.
%
% INPUT
%   rptsObject     the fields extracted from the object for this funtion are:
%
%        dynamicRangeApertures:   [struct array] consisting of the following fields:
%                     keplerId:   target star KIC id number
%                 referenceRow:   reference row on the module output for this aperture
%              referenceColumn:   reference column on the module output for this aperture
%                      offsets:   [struct array] consisting of the fields 'row' and 'column'
%                badPixelCount:   indices of bad pixels
%
%                existingMasks:   [struct array] existing mask table consisting of the following field:
%                      offsets:   [struct array] consisting of the fields 'row' and 'column'
%
% OUTPUT
% dynamicRangeTargetDefinitions:   [struct array] consisting of the following fields:
%               keplerId: [struct array]    target star KIC id number
%           referenceRow: [struct array]    reference row on the module output for this target definition
%        referenceColumn: [struct array]    reference column on the module output for this target definition
%              maskIndex: [struct array]    index into existingMasks table for this target definition
%           excessPixels: [struct array]    the number of pixels in the assigned mask that are not in the requested aperture
%                 status: [struct array]    status indicating successful mask assignment:
%                                              status = -1: no mask assigned
%                                              status =  1: mask assigned, no problems
%                                              status = -2: mask assigned but has pixels off the CCD
% 
% Copyright 2017 United States Government as represented by the
% Administrator of the National Aeronautics and Space Administration.
% All Rights Reserved.
% 
% NASA acknowledges the SETI Institute's primary role in authoring and
% producing the Kepler Data Processing Pipeline under Cooperative
% Agreement Nos. NNA04CC63A, NNX07AD96A, NNX07AD98A, NNX11AI13A,
% NNX11AI14A, NNX13AD01A & NNX13AD16A.
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

% extract relevant fields from rptsObject
dynamicRangeApertures = rptsObject.dynamicRangeApertures;
existingMasks         = rptsObject.existingMasks;

% extract focal plane constants to ensure apertures/target definitions are
% on the accumulation memory
fcConstants     = rptsObject.fcConstants;
numCcdRows      = fcConstants.CCD_ROWS;       % 1070
numCcdColumns   = fcConstants.CCD_COLUMNS;    % 1132

nRowsImaging    = fcConstants.nRowsImaging;   % 1024
nColsImaging    = fcConstants.nColsImaging;   % 1100
nLeadingBlack   = fcConstants.nLeadingBlack;  % 12
%nTrailingBlack  = fcConstants.nTrailingBlack; % 20
%nVirtualSmear   = fcConstants.nVirtualSmear;  % 26
nMaskedSmear    = fcConstants.nMaskedSmear;   % 20

%--------------------------------------------------------------------------
% validate inputs: check to ensure that dynamic range aperture reference
% rows/columns are on the CCD
%--------------------------------------------------------------------------
apertureCenterRows      = [dynamicRangeApertures.referenceRow];
apertureCenterColumns   = [dynamicRangeApertures.referenceColumn];

validRows    = find((apertureCenterRows(:) > 0) & (apertureCenterRows(:) <= numCcdRows));
validColumns = find((apertureCenterColumns(:) > 0) & (apertureCenterColumns(:) <= numCcdColumns));

if ((length(validRows) ~= length(apertureCenterRows)) || (length(validColumns) ~= length(apertureCenterColumns)))
    error('RPTS:get_dynamic_range_target_definitions: Input dynamic range aperture reference row and/or column is off the CCD');
end

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% set up input struct for mask assignments (which are calculated via ama_matlab_controller_1_base)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
amaParameterStruct = struct('maskDefinitions', [], 'apertureStructs', [], ...
    'debugFlag', [], 'amaConfigurationStruct', []);

amaParameterStruct.maskDefinitions  = existingMasks;
amaParameterStruct.apertureStructs  = dynamicRangeApertures;
amaParameterStruct.fcConstants      = fcConstants;
amaParameterStruct.debugFlag        = rptsObject.debugFlag;

% no halos added for dynamic range targets (only stellar targets)
amaParameterStruct.amaConfigurationStruct.useHaloApertures = 0;

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% aperture mask assignment - note the output structure of ama includes:
%   amaResultStruct.targetDefinitions
%   amaResultStruct.usedMasks
amaResultStruct = ama_matlab_controller_1_base(amaParameterStruct);

% dynamic range target definitions are just output from ama
dynamicRangeTargetDefinitions = amaResultStruct.targetDefinitions;

%--------------------------------------------------------------------------
% validate results: check to ensure that all dynamic range pixels are on the CCD
%--------------------------------------------------------------------------
for j = 1 : length(dynamicRangeTargetDefinitions)

    [dynamicRows, dynamicColumns] = get_absolute_pixel_indices(dynamicRangeTargetDefinitions(j), existingMasks);

    validRows    = find((dynamicRows(:) > 0) & (dynamicRows(:) <= numCcdRows));
    validColumns = find((dynamicColumns(:) > 0) & (dynamicColumns(:) <= numCcdColumns));

    if (length(validRows) < length(dynamicRows)) || ((length(validColumns) < length(dynamicColumns)))
        error('RPTS:get_dynamic_range_target_definitions: Output dynamic range target definition row and/or column is off CCD');
    end

    %----------------------------------------------------------------------
    % report if any pixels are in collateral
    %----------------------------------------------------------------------
    anyPixelsInLeadingBlack  =  find((dynamicColumns(:) > 0) & (dynamicColumns(:) <= nLeadingBlack), 1);   % 0 < cols <= 12
    if ~isempty(anyPixelsInLeadingBlack)
        disp('RPTS:get_dynamic_range_target_definitions', ...
            ['Pixels in target definition ' num2str(j) ' are in leading black region']);
    end

    anyPixelsInTrailingBlack =  find((dynamicColumns(:) > (nLeadingBlack+nColsImaging)) & (dynamicColumns(:) <= numCcdColumns), 1); % 1112 < cols <= 1132
    if ~isempty(anyPixelsInTrailingBlack)
        disp('RPTS:get_dynamic_range_target_definitions', ...
            ['Pixels in target definition ' num2str(j) ' are in trailing black region']);
    end

    anyPixelsInMaskedSmear   =  find((dynamicRows(:) > 0) &  (dynamicRows(:) <= nMaskedSmear), 1);   % 0 < rows <= 20
    if ~isempty(anyPixelsInMaskedSmear)
        disp('RPTS:get_dynamic_range_target_definitions', ...
            ['Pixels in target definition ' num2str(j) ' are in masked smear region']);
    end

    anyPixelsInVirtualSmear  =  find((dynamicRows(:) > (nMaskedSmear+nRowsImaging)) & (dynamicRows(:) <= numCcdRows), 1);   % 1044 < rows <= 1070
    if ~isempty(anyPixelsInVirtualSmear)
        disp('RPTS:get_dynamic_range_target_definitions', ...
            ['Pixels in target definition ' num2str(j) ' are in virtual smear region']);
    end
end

return;
