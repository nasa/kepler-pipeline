function [smearTargetDefinitions, smearMaskDefinition] = get_smear_target_definitions(rptsObject)
% function [smearTargetDefinitions, smearMaskDefinition] = get_smear_target_definitions(rptsObject)
%
% function to create target definitions for each smear row (an input parameter),
% each of which will contain a column index of 0.  The smear pixels are
% collected with a supermask, in which the row indices are set to 0, and the
% column indices are those of the combined stellar and background column indices.
%
% Note: pixels in the mask definition are converted to 0-base herein (more efficient),
% whereas pixels in target definitions are converted in separate algorithm
%
% INPUT
%   rptsObject     the fields extracted from the object for this funtion are:
%            rptsModuleParametersStruct:   [struct array] which includes the following relevant field:
%                          smearRows:   [struct array] list of input smear row numbers
%
%                     stellarIndices:   [struct array] row and column indices from stellar target reference pixels
%                  backgroundIndices:   [struct array] row and column indices from background reference pixels
%
% OUTPUT
%       smearTargetDefinitions:   [struct array] consisting of the following fields:
%               keplerId: [struct array]    target star KIC id number
% 1-base    referenceRow: [struct array]    reference row on the module output for this target definition
% 1-base referenceColumn: [struct array]    reference column on the module output for this target definition
%              maskIndex: [struct array]    index into smearMaskDefinition table for this target definition
%           excessPixels: [struct array]    the number of pixels in the assigned mask that are not in the requested aperture
%                 status: [struct array]    status indicating successful mask assignment:
%                                              status = -1: no mask assigned
%                                              status =  1: mask assigned, no problems
%                                              status = -2: mask assigned but has pixels off the CCD
%
% 0-base   smearMaskDefinition:   [struct array] consisting of the following field:
%                      offsets:   [struct array] consisting of the fields 'row' and 'column'
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

%debugFlag = rptsObject.debugFlag;

% extract relevant fields from rptsObject
smearRows           = rptsObject.rptsModuleParametersStruct.smearRows; %1-base
stellarIndices      = rptsObject.stellarIndices;
backgroundIndices   = rptsObject.backgroundIndices;

% extract focal plane constants
fcConstants = rptsObject.fcConstants;

nRowsImaging     = fcConstants.nRowsImaging;   % 1024
%nColsImaging     = fcConstants.nColsImaging;   % 1100
%nLeadingBlack    = fcConstants.nLeadingBlack;  % 12
%nTrailingBlack   = fcConstants.nTrailingBlack; % 20
%nVirtualSmear   = fcConstants.nVirtualSmear;  % 26
nMaskedSmear     = fcConstants.nMaskedSmear;   % 20
numCcdRows       = fcConstants.CCD_ROWS;       % 1070
numCcdColumns    = fcConstants.CCD_COLUMNS;    % 1132

%--------------------------------------------------------------------------
% create smear supermask
%--------------------------------------------------------------------------
% preallocate mask structure
smearMaskDefinition = struct('offsets', []);

% collect column values from stellar and background targets
stellarColumns      = [stellarIndices.stellarColumns];          % 1-base
backgroundColumns   = [backgroundIndices.backgroundColumns];    % 1-base

% concatenate and find unique column values
allSmearColumns = unique([stellarColumns backgroundColumns]); % 1-base

% create array for mask definition rows in 1-base
allSmearRows = ones(1, length(allSmearColumns)); % 1-base

% convert columns to 0-base (more efficient to convert here prior to defining supermask)
allSmearColumns0base = allSmearColumns - 1;      % 0-base
allSmearRows0base    = allSmearRows    - 1;      % 0-base

% deal all row/columns into struct arrays for output
allSmearRows0baseCellArray    = num2cell(allSmearRows0base);
allSmearColumns0baseCellArray = num2cell(allSmearColumns0base);

[smearMaskDefinition.offsets(1:length(allSmearRows0baseCellArray)).row] = ...
    deal(allSmearRows0baseCellArray{:});

[smearMaskDefinition.offsets(1:length(allSmearColumns0baseCellArray)).column] = ...
    deal(allSmearColumns0baseCellArray{:});

display('RPTS:get_smear_target_definitions: Smear mask definition row/col offsets converted to Java 0-based indexing for output. ');

%--------------------------------------------------------------------------
% create smear target defintions - a smear target will contain a smearRow,
% a column offset of 0, and the index of the smear superMask
%--------------------------------------------------------------------------
% preallocate target definitions structure - there will be as many smear target
% definitions as there are input smearRows
smearTargetDefinitions  = repmat(struct('keplerId', [], 'referenceRow', [], 'referenceColumn', [], ...
    'maskIndex', [], 'excessPixels', [], 'status', []), 1, length(smearRows));

% create the target definitions for the output
for i=1:length(smearRows)

    smearTargetDefinitions(i).keplerId          = 1;
    smearTargetDefinitions(i).referenceRow      = smearRows(i);  %1-base
    smearTargetDefinitions(i).referenceColumn   = 1;   % will be 0 when converted to java 0-base for output
    smearTargetDefinitions(i).maskIndex         = 1;   % will be 0 when converted to java 0-base for output
    smearTargetDefinitions(i).excessPixels      = 0;
    smearTargetDefinitions(i).status            = 1;
end

%--------------------------------------------------------------------------
% validate results: check to ensure that all smear reference pixels (in 1-base)
% have valid ranges
%--------------------------------------------------------------------------
for j = 1 : length(smearTargetDefinitions)

    negativeRows    = find(allSmearRows(:)    < 0);
    negativeColumns = find(allSmearColumns(:) < 0);

    if any(negativeRows) || any(negativeColumns)
        error('RPTS:get_smear_target_definitions: Smear reference pixel(s) have a negative value');
    end

    validRows    = find((allSmearRows(:) > 0) & (allSmearRows(:) <= nMaskedSmear)) | ...
        ((allSmearRows(:) >= (nMaskedSmear + nRowsImaging + 1)) & (allSmearRows(:) <= numCcdRows));

    validColumns = find((allSmearColumns(:) > 0) & (allSmearColumns(:) <= numCcdColumns));

    if (length(validRows) < length(allSmearRows)) || ((length(validColumns) < length(allSmearColumns)))
        error('RPTS:get_smear_target_definitions: Smear reference pixels are not in valid ranges');
    end
end

return;

