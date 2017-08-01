function pruned = pdqval_prune_modouts_from_pdqInputStruct(pdqInputStruct, retain)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function pruned = pdqval_prune_modouts_from_pdqInputStruct(pdqInputStruct, retain)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Prune all targets and supporting data from selected channels.
%
% Inputs:
%
%     pdqInputStruct - a PDQ input struct 
%
%     retain         - an 84-element logical array. Retain channels whose
%                      flags are set to 'true' and prune those whose flags
%                      are set to 'false'
% Outputs:
%
%     pruned         - a copy of pdqInputStruct minus reference targets
%                      from excluded modouts
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
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
targetFields = [ {'stellarPdqTargets'}; {'backgroundPdqTargets'}; ...
                 {'collateralPdqTargets'}];
pruned = pdqInputStruct;

% Prune time series data
for i=1:numel(targetFields)
    targetModules = cat(1, pruned.(targetFields{i}).ccdModule);
    targetOutputs = cat(1, pruned.(targetFields{i}).ccdOutput);
    targetModouts = convert_from_module_output(targetModules, targetOutputs);
    pruneIndices = ~retain(targetModouts);
    pruned.(targetFields{i})(pruneIndices) = [];
end

% prune unneeded supporting data. PRF files are not loaded if their names
% are not listed.
pruned.prfModelFilenames(~retain) = {''}; % There must be 84 strings for correct indexing.

if ~isempty(pruned.twoDBlackModels)
    smallStruct = pruned.twoDBlackModels(1);
    smallStruct.mjds = [];
    smallStruct.rows = [];
    smallStruct.columns = [];
    smallStruct.blacks = [];
    smallStruct.uncertainties = [];
    
    if isfield(smallStruct,'fcModelMetadata')
        smallStruct.fcModelMetadata.svnInfo = '<Not set yet!>';
        smallStruct.fcModelMetadata.ingestTime = '<Not set yet!>';
        smallStruct.fcModelMetadata.modelDescription = '<Not set yet!>';
    end
    
    pruned.twoDBlackModels(~retain) = smallStruct;
end

if ~isempty(pruned.flatFieldModels)
    smallStruct = pruned.flatFieldModels(1);    
    
    smallStruct.mjds = [];
    smallStruct.rows = [];
    smallStruct.columns = [];
    smallStruct.flats = [];
    smallStruct.uncertainties = [];
    smallStruct.polynomialOrder = [];
    smallStruct.type = [];
    smallStruct.xIndex = [];
    smallStruct.offsetX = [];
    smallStruct.scaleX = [];
    smallStruct.originX = [];
    smallStruct.yIndex = [];
    smallStruct.offsetY = [];
    smallStruct.scaleY = [];
    smallStruct.originY = [];
    smallStruct.coeffs = [];
    smallStruct.covars = [];

    if isfield(smallStruct,'fcModelMetadataLargeFlat')
        smallStruct.fcModelMetadataLargeFlat.svnInfo = '<Not set yet!>';
        smallStruct.fcModelMetadataLargeFlat.ingestTime = '<Not set yet!>';
        smallStruct.fcModelMetadataLargeFlat.modelDescription = '<Not set yet!>';
    end
    
    if isfield(smallStruct,'fcModelMetadataSmallFlat')    
        smallStruct.fcModelMetadataSmallFlat.svnInfo = '<Not set yet!>';
        smallStruct.fcModelMetadataSmallFlat.ingestTime = '<Not set yet!>';
        smallStruct.fcModelMetadataSmallFlat.modelDescription = '<Not set yet!>';
    end
    
    pruned.flatFieldModels(~retain) = smallStruct;
end
 
return