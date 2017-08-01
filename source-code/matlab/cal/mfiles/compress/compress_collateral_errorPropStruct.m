function [C, S] = compress_collateral_errorPropStruct(S, SVDdegree, dataFlags)

% function [C, S] = compress_collateral_errorPropStruct(S, SVDdegree, dataFlags)
%
% Compress the primitive data time series stored in the root level of errorPropStruct
% S for the following variable names:
% residualBlack
% mSmearEstimate
% vSmearEstimate
% Also compress transform generation data for the following variable names
% at the indicated levels if it is available:
% mSmearEstimate        level 2, 3
% vSmearEstimate        level 2, 3
% darkLevelEstimate     level 3
% 
% Return the original errorPropStruct (S) with unused entries removed and 
% where the primitive data fields have been replaced with an indicator that
% an SVD compression has been done. An array of compressed data structures
% (C) is also returned where the array index corresponds to the index of 
% the errorPropStruct variableName.
%
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

% compressed data indicator
COMPRESSED_DATA = 'SVD';

% list of variable names for which primitive data will be compressed if available
collateralNames = {'residualBlack';...
                   'mSmearEstimate';...
                   'vSmearEstimate'};
               
% select transformStructArray indices to compress for mSmearEstimate and vSmearEstimate
if dataFlags.processShortCadence && dataFlags.dynamic2DBlackEnabled
    tIdx = [1,2];       % dynablack, SC
else
    tIdx = [2,3];       % everything else
end

% select transformStructArray indices to compress for darkLevels
darkIdx = 3;            % in all cases

% get list of available names
[~, inputNames] = iserrorPropStructVariable(S,'');
varNames = intersect(collateralNames(1:3), inputNames);
        
% initialize return compressed structure - allocate enough space for varNames + darkLevelEstimate
C = repmat(empty_compressedDataStruct,length(varNames)+1,1);

% compress primitive data at root level of the structure S for selected collateral variables
for i=1:length(varNames)    
    C(i) = compress_primitive_data(S, varNames{i}, SVDdegree);
    xPrim = COMPRESSED_DATA;
    CxPrim = COMPRESSED_DATA;
    gapList = [];
    S = replace_primitive_data(S, varNames{i}, xPrim, CxPrim, {gapList});
end

% before compressing transform data add 'darkLevelEstimate to the list of varNames if data is available
if ismember('darkLevelEstimate', inputNames)
    varNames{end+1} = 'darkLevelEstimate';
end


% manually add compression for transform generation data at higher levels of the structure S

% compress transforms for mSmearEstimate
varName = 'mSmearEstimate';
parameterToCompress = 'scaleORweight';
inputIndex = iserrorPropStructVariable(S,varName);
[inlist, iName] = ismember(varName, varNames);
if inlist && inputIndex > 0    
    % compress and replace transform generation data for selected transform indices
    compressedDataIdx = 1;
    for idx = tIdx        
        if length(S(inputIndex).transformStructArray) >= idx && ...
                ~isempty(S(inputIndex).transformStructArray(idx).transformParamStruct.(parameterToCompress))
            C(iName).transformData(compressedDataIdx) = compress_transform_generation_data(S, varName, idx, parameterToCompress, SVDdegree);
            S = replace_transform_generation_data(S, varName, idx, parameterToCompress, COMPRESSED_DATA);
            compressedDataIdx = compressedDataIdx + 1;
        end
    end
end

% compress transforms for vSmearEstimate
varName = 'vSmearEstimate';
parameterToCompress = 'scaleORweight';
inputIndex = iserrorPropStructVariable(S,varName);
[inlist, iName] = ismember(varName, varNames);
if inlist && inputIndex > 0    
    % compress and replace transform generation data for selected transform indices
    compressedDataIdx = 1;
    for idx = tIdx        
        if length(S(inputIndex).transformStructArray) >= idx && ...
                ~isempty(S(inputIndex).transformStructArray(idx).transformParamStruct.(parameterToCompress))
            C(iName).transformData(compressedDataIdx) = compress_transform_generation_data(S, varName, idx, parameterToCompress, SVDdegree);
            S = replace_transform_generation_data(S, varName, idx, parameterToCompress, COMPRESSED_DATA);
            compressedDataIdx = compressedDataIdx + 1;
        end
    end
end

% compress transforms for darkLevelEstimate
varName = 'darkLevelEstimate';
parameterToCompress = 'scaleORweight';
inputIndex = iserrorPropStructVariable(S,varName);
[inlist, iName] = ismember(varName, varNames);
if inlist && inputIndex > 0
    % compress and replace transform generation data for selected transform indices
    compressedDataIdx = 1;
    for idx = darkIdx        
        if length(S(inputIndex).transformStructArray) >= idx && ...
                ~isempty(S(inputIndex).transformStructArray(idx).transformParamStruct.(parameterToCompress))
            C(iName).variableName = varName;
            C(iName).transformData(compressedDataIdx) = compress_transform_generation_data(S, varName, idx, parameterToCompress, SVDdegree);
            S = replace_transform_generation_data(S, varName, idx, parameterToCompress, COMPRESSED_DATA);
            compressedDataIdx = compressedDataIdx + 1;
        end
    end    
    % if there was no transform data to compress and since there is no compressed primitive data we can remove darkLevelEstimate from compressed data struct
    if compressedDataIdx == 1        
        C = C(1:end-1);
    end
end


