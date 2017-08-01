function rptsResultsStruct = set_result_struct(rptsObject)
% function rptsResultsStruct = set_result_struct(rptsObject)
%
% function to create an output structure from the fields in the rptsObject
%  
% rptsResultsStruct is a struct array with the following fields:
%                  stellarTargetDefinitions: [struct array]
%             dynamicRangeTargetDefinitions: [struct array]
%                backgroundTargetDefinition: [struct array]
%                    blackTargetDefinitions: [struct array]
%                    smearTargetDefinitions: [struct array]
%                  backgroundMaskDefinition: [struct array]
%                       blackMaskDefinition: [struct array]
%                       smearMaskDefinition: [struct array]
%
% *see rptsClass for struct fields and hierarchy
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

% preallocate structure to populate fields: top level fields
rptsResultsStruct = struct('stellarTargetDefinitions', [], 'dynamicRangeTargetDefinitions', [], ...
    'backgroundTargetDefinition', [], 'blackTargetDefinitions', [], 'smearTargetDefinitions', [], ...
    'backgroundMaskDefinition', [], 'blackMaskDefinition', [], 'smearMaskDefinition', []);

% extract fields from object
stellarTargetDefinitions        = rptsObject.stellarTargetDefinitions;
dynamicRangeTargetDefinitions   = rptsObject.dynamicRangeTargetDefinitions;
blackTargetDefinitions          = rptsObject.blackTargetDefinitions;
smearTargetDefinitions          = rptsObject.smearTargetDefinitions;

backgroundTargetDefinition      = rptsObject.backgroundTargetDefinition;
backgroundMaskDefinition        = rptsObject.backgroundMaskDefinition;
blackMaskDefinition             = rptsObject.blackMaskDefinition;
smearMaskDefinition             = rptsObject.smearMaskDefinition;


% populate results struct (fields and bounds will be validated prior to output)
rptsResultsStruct.stellarTargetDefinitions      = stellarTargetDefinitions;
rptsResultsStruct.dynamicRangeTargetDefinitions = dynamicRangeTargetDefinitions;
rptsResultsStruct.blackTargetDefinitions        = blackTargetDefinitions;
rptsResultsStruct.smearTargetDefinitions        = smearTargetDefinitions;


% scalars and non-array structs must not be empty, populate results struct 
% fields if data is not available (ex. no stellar input apertures)
emptyTargetDefinitionStruct.keplerId         = 0; 
emptyTargetDefinitionStruct.referenceRow     = 0;
emptyTargetDefinitionStruct.referenceColumn  = 0;
emptyTargetDefinitionStruct.maskIndex        = 0; 
emptyTargetDefinitionStruct.excessPixels     = 0;
emptyTargetDefinitionStruct.status           = 0;

emptyMaskDefinitionStruct.offsets.row        = 0;
emptyMaskDefinitionStruct.offsets.column     = 0;


if (~isempty(backgroundTargetDefinition))
    rptsResultsStruct.backgroundTargetDefinition = backgroundTargetDefinition;
else
    rptsResultsStruct.backgroundTargetDefinition = emptyTargetDefinitionStruct;
end


if (~isempty(backgroundMaskDefinition))
    rptsResultsStruct.backgroundMaskDefinition = backgroundMaskDefinition;
else
    rptsResultsStruct.backgroundMaskDefinition = emptyMaskDefinitionStruct;
end

if (~isempty(blackMaskDefinition))
    rptsResultsStruct.blackMaskDefinition = blackMaskDefinition;
else
    rptsResultsStruct.blackMaskDefinition = emptyMaskDefinitionStruct;
end

if (~isempty(smearMaskDefinition))
    rptsResultsStruct.smearMaskDefinition = smearMaskDefinition;
else
    rptsResultsStruct.smearMaskDefinition = emptyMaskDefinitionStruct;
end


return