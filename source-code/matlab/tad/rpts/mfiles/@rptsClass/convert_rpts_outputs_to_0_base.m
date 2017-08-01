function [stellarTargetDefinitions, backgroundTargetDefinition, ...
    blackTargetDefinitions, smearTargetDefinitions, dynamicRangeTargetDefinitions] = ...
    convert_rpts_outputs_to_0_base(rptsObject)
% function [stellarTargetDefinitions, backgroundTargetDefinition, ...
%     blackTargetDefinitions, smearTargetDefinitions, dynamicRangeTargetDefinitions] = ...
%     convert_rpts_outputs_to_0_base(rptsObject)
%
% Output arrays that include row/column indices must be converted from Matlab 1-base
% to Java 0-base prior to output
%
% For each of the (stellar, dynamic range, background, black, and smear) target
% definitions structures, the fields that are converted are:
%
%    referenceRow:      [struct array]
%    referenceColumn:   [struct array]
%    maskIndex:         [struct array]
%
% Note: Mask definition indices for custom background, smear, and black
% supermasks are converted to 0-base within the individual  get_*_target_definition
% scripts where they are created (to improve performance of the rpts controller).
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

if (~isempty(rptsObject.dynamicRangeApertures))

    % extract target and mask definitions from object
    dynamicRangeTargetDefinitions = rptsObject.dynamicRangeTargetDefinitions;

    % subtract 1 from fields
    dynamicRows     = [dynamicRangeTargetDefinitions.referenceRow ] - 1;
    dynamicColumns  = [dynamicRangeTargetDefinitions.referenceColumn] - 1;
    dynamicMasks   = [dynamicRangeTargetDefinitions.maskIndex] - 1;

    % convert 2D arrays to cell arrays, and deal back into struct arrays
    dynamicRowsCellArray    = num2cell(dynamicRows);
    dynamicColumnsCellArray = num2cell(dynamicColumns);
    dynamicMasksCellArray  = num2cell(dynamicMasks);

    % save updated structure array fields
    [dynamicRangeTargetDefinitions(1:length(dynamicRowsCellArray)).referenceRow] = ...
        deal(dynamicRowsCellArray{:});
    [dynamicRangeTargetDefinitions(1:length(dynamicColumnsCellArray)).referenceColumn] = ...
        deal(dynamicColumnsCellArray{:});
    [dynamicRangeTargetDefinitions(1:length(dynamicMasksCellArray)).maskIndex] = ...
        deal(dynamicMasksCellArray{:});

    display('RPTS:convert_rpts_outputs_to_0_base: Dynamic range target definition row/column indices converted to Java 0-based indexing. ');
else
    dynamicRangeTargetDefinitions = [];
end

%--------------------------------------------------------------------------
if (~isempty(rptsObject.stellarApertures))

    % extract target and mask definitions from object
    stellarTargetDefinitions    = rptsObject.stellarTargetDefinitions ;
    backgroundTargetDefinition  = rptsObject.backgroundTargetDefinition;
    blackTargetDefinitions      = rptsObject.blackTargetDefinitions;
    smearTargetDefinitions      = rptsObject.smearTargetDefinitions;

    % multiple target definitions for the stellar, dynamic, smear, and black
    stellarRows     = [stellarTargetDefinitions.referenceRow] - 1;
    stellarColumns  = [stellarTargetDefinitions.referenceColumn] - 1;
    stellarMasks   = [stellarTargetDefinitions.maskIndex] - 1;

    blackRows       = [blackTargetDefinitions.referenceRow] - 1;
    blackColumns    = [blackTargetDefinitions.referenceColumn] - 1;
    blackMasks      = [blackTargetDefinitions.maskIndex] - 1;

    smearRows    = [smearTargetDefinitions.referenceRow] - 1;
    smearColumns = [smearTargetDefinitions.referenceColumn] - 1;
    smearMasks   = [smearTargetDefinitions.maskIndex] - 1;

    % convert 2D arrays to cell arrays, and deal back into struct arrays
    stellarRowsCellArray    = num2cell(stellarRows);
    stellarColumnsCellArray = num2cell(stellarColumns);
    stellarMasksCellArray  = num2cell(stellarMasks);

    blackRowsCellArray      = num2cell(blackRows);
    blackColumnsCellArray   = num2cell(blackColumns);
    blackMasksCellArray     = num2cell(blackMasks);

    smearRowsCellArray      = num2cell(smearRows);
    smearColumnsCellArray   = num2cell(smearColumns);
    smearMasksCellArray     = num2cell(smearMasks);

    % save updated structure array fields
    [stellarTargetDefinitions(1:length(stellarRowsCellArray)).referenceRow] = ...
        deal(stellarRowsCellArray{:});
    [stellarTargetDefinitions(1:length(stellarColumnsCellArray)).referenceColumn] = ...
        deal(stellarColumnsCellArray{:});
    [stellarTargetDefinitions(1:length(stellarMasksCellArray)).maskIndex] = ...
        deal(stellarMasksCellArray{:});

    display('RPTS:convert_rpts_outputs_to_0_base: Stellar target definition row/column indices converted to Java 0-based indexing. ');


    % subtract 1 from fields - note there is only one background target definition)
    backgroundTargetDefinition.referenceRow     = backgroundTargetDefinition.referenceRow - 1;
    backgroundTargetDefinition.referenceColumn  = backgroundTargetDefinition.referenceColumn - 1;
    backgroundTargetDefinition.maskIndex        = backgroundTargetDefinition.maskIndex - 1;

    display('RPTS:convert_rpts_outputs_to_0_base: Background target definition row/column/maskIndex converted to Java 0-based indexing. ');


    [blackTargetDefinitions(1:length(blackRowsCellArray)).referenceRow] = ...
        deal(blackRowsCellArray{:});
    [blackTargetDefinitions(1:length(blackColumnsCellArray)).referenceColumn] = ...
        deal(blackColumnsCellArray{:});
    [blackTargetDefinitions(1:length(blackMasksCellArray)).maskIndex] = ...
        deal(blackMasksCellArray{:});

    display('RPTS:convert_rpts_outputs_to_0_base: Black target definition row/column/maskIndex converted to Java 0-based indexing. ');


    [smearTargetDefinitions(1:length(smearRowsCellArray)).referenceRow] = ...
        deal(smearRowsCellArray{:});
    [smearTargetDefinitions(1:length(smearColumnsCellArray)).referenceColumn] = ...
        deal(smearColumnsCellArray{:});
    [smearTargetDefinitions(1:length(smearMasksCellArray)).maskIndex] = ...
        deal(smearMasksCellArray{:});

    display('RPTS:convert_rpts_outputs_to_0_base: Smear target definition row/column/maskIndex converted to Java 0-based indexing. ');

else
    stellarTargetDefinitions    = [];
    backgroundTargetDefinition  = [];
    blackTargetDefinitions      = [];
    smearTargetDefinitions      = [];
end

return;
