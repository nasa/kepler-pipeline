function [blackTargetDefinitions, blackMaskDefinition] = get_black_target_definitions(rptsObject)
% function [blackTargetDefinitions, blackMaskDefinition] = get_black_target_definitions(rptsObject)
%
% function to create target definitions for each black column (an input parameter),
% each of which will contain a row index of 0.  The black pixels are
% collected with a supermask, in which the column indices are set to 0, and the
% row indices are those of the combined stellar, background, and smear row indices.
%
% Note: pixels in the mask definition are converted to 0-base herein (more efficient),
% whereas pixels in target definitions are converted in separate algorithm
%
% INPUT
%   rptsObject     the fields extracted from the object for this funtion are:
%            rptsModuleParametersStruct:   [struct array] which includes the following relevant fields:
%                       blackColumns:   [struct array] list of input black column numbers
%                         smearRows:    [struct array] list of input smear row numbers
%
%                     stellarIndices:   [struct array] row and column indices from stellar target reference pixels
%                  backgroundIndices:   [struct array] row and column indices from background reference pixels
% OUTPUT
%       blackTargetDefinitions:   [struct array] consisting of the following fields:
%               keplerId: [struct array]    target star KIC id number
% 1-base    referenceRow: [struct array]    reference row on the module output for this target definition
% 1-base referenceColumn: [struct array]    reference column on the module output for this target definition
%              maskIndex: [struct array]    index into blackMaskDefinition table for this target definition
%           excessPixels: [struct array]    the number of pixels in the assigned mask that are not in the requested aperture
%                 status: [struct array]    status indicating successful mask assignment:
%                                              status = -1: no mask assigned
%                                              status =  1: mask assigned, no problems
%                                              status = -2: mask assigned but has pixels off the CCD
%
% 0-base   blackMaskDefinition:   [struct array] consisting of the following field:
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
blackColumns        = rptsObject.rptsModuleParametersStruct.blackColumns; %1-base
smearRows           = rptsObject.rptsModuleParametersStruct.smearRows;    %1-base
stellarIndices      = rptsObject.stellarIndices;
backgroundIndices   = rptsObject.backgroundIndices;

% extract focal plane constants
fcConstants = rptsObject.fcConstants;

%nRowsImaging     = fcConstants.nRowsImaging;   % 1024
nColsImaging     = fcConstants.nColsImaging;   % 1100
nLeadingBlack    = fcConstants.nLeadingBlack;  % 12
%nTrailingBlack  = fcConstants.nTrailingBlack; % 20
%nVirtualSmear    = fcConstants.nVirtualSmear;  % 26
%nMaskedSmear     = fcConstants.nMaskedSmear;   % 20
numCcdRows       = fcConstants.CCD_ROWS;       % 1070
numCcdColumns    = fcConstants.CCD_COLUMNS;    % 1132

%--------------------------------------------------------------------------
% create black supermask
%--------------------------------------------------------------------------
% preallocate mask structure
blackMaskDefinition = struct('offsets', []);

% collect row values from stellar and background targets
stellarRows    = [stellarIndices.stellarRows];          %1-base
backgroundRows = [backgroundIndices.backgroundRows];    %1-base

% concatenate and find unique row values (include smear rows)
allBlackRows = unique([stellarRows backgroundRows smearRows']);  %1-base

% create array for mask definition columns
allBlackColumns = ones(1, length(allBlackRows));                 %1-base

% convert rows to 0-base (which is more efficient to do here prior to defining supermask)
allBlackRows0base    =  allBlackRows    - 1;    % 0-base
allBlackColumns0base =  allBlackColumns - 1;    % 0-base

% deal mask row/columns into struct arrays for output
allBlackRows0baseCellArray    = num2cell(allBlackRows0base);
allBlackColumns0baseCellArray = num2cell(allBlackColumns0base);

[blackMaskDefinition.offsets(1:length(allBlackRows0baseCellArray)).row] = ...
    deal(allBlackRows0baseCellArray{:});

[blackMaskDefinition.offsets(1:length(allBlackColumns0baseCellArray)).column] = ...
    deal(allBlackColumns0baseCellArray{:});

display('RPTS:get_black_target_definitions: Black mask definition row/col offsets converted to Java 0-based indexing for output. ');

%--------------------------------------------------------------------------
% create black target defintions - a black target will contain a
% blackColumn, a row offset of 0, and the index of the superMask
%--------------------------------------------------------------------------
% preallocate target definitions struct - there will be as many black target
% definitions as there are input blackColumns
blackTargetDefinitions  = repmat(struct('keplerId', [], 'referenceRow', [], 'referenceColumn', [], ...
    'maskIndex', [], 'excessPixels', [], 'status', []), 1, length(blackColumns));

% create the target definitions for the output
for i=1:length(blackColumns)
    blackTargetDefinitions(i).keplerId          = 1;
    blackTargetDefinitions(i).referenceRow      = 1;   % will be 0 when converted to java 0-base for output
    blackTargetDefinitions(i).referenceColumn   = blackColumns(i); %1-base
    blackTargetDefinitions(i).maskIndex         = 1;   % will be 0 when converted to java 0-base for output
    blackTargetDefinitions(i).excessPixels      = 0;
    blackTargetDefinitions(i).status            = 1;
end

%--------------------------------------------------------------------------
% validate results: check to ensure that all black reference pixels (in 1-base)
% have valid ranges and are on the photometric CCD
%--------------------------------------------------------------------------
for j = 1 : length(blackTargetDefinitions)

    negativeRows    = find(allBlackRows(:) < 0);
    negativeColumns = find(allBlackColumns(:) < 0);

    if any(negativeRows) || any(negativeColumns)
        error('RPTS:get_black_target_definitions: Black reference pixel(s) have a negative value');
    end

    validRows    = find((allBlackRows(:) > 0) & (allBlackRows(:) <= numCcdRows));

    validColumns = find((allBlackColumns(:) > 0) & (allBlackColumns(:) <= nLeadingBlack)) | ...
        ((allBlackColumns(:) >= (nLeadingBlack + nColsImaging + 1)) & (allBlackColumns(:) <= numCcdColumns));

    if (length(validRows) < length(allBlackRows)) || ((length(validColumns) < length(allBlackColumns)))
        error('RPTS:get_black_target_definitions: Black reference pixels are not in valid ranges');
    end
end

return;
