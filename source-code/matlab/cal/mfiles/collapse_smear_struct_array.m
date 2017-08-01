function smearStruct = collapse_smear_struct_array(smearStructArray)
% function smearStruct = collapse_smear_struct_array(smearStructArray)
%
% This function collapses an array of smearStruct as retrieved from the smearBlobs to produce a single structure containing the same
% information. If smearStructArray = [], smearStruct = [] is returned.
%
% INPUT:    smearStructArray == Contains one field: struct [1xm] array of structs
%                                   
%                                   Each element in struct contains the following fields:
%
%                                        cadences: absolute cadence numbers [nCadencex1 double]
%                                 startTimeStamps: mjd start times [nCadencex1 double]
%                                   midTimeStamps: mjd mid times [nCadencex1 double]
%                                   endTimeStamps: mjd end times [nCadencex1 double]
%                                          module: ccd module
%                                          output: ccd output
%                         smearCorrectionStructLC: structure containing LC smear data [1x1 struct]
%
% OUTPUT:   smearStruct == A single element of smearStruct with fields updated to contain the aggregate of the information input
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




% check trivial case
if( isempty(smearStructArray) )
    smearStruct = [];
    return;
end

% parse array of structures
if( ~isfield(smearStructArray,'struct') )
    error('Fieldname struct missing in structure returned from get_struct_for_cadence. Cannot collapse smear blob.');
else
    smearStructArray = [smearStructArray.struct];
end
    
% single element array requires no collapsing
nElements = length(smearStructArray);
if( nElements == 1 )
    smearStruct = smearStructArray;
    return;
end


% allocate space - account for possible different numbers of smear columns
nCadences(nElements) = 0;
nMaskedSmearColumns(nElements) = 0;
nVirtualSmearColumns(nElements) = 0;
for iElement = 1:nElements
    nCadences(iElement) = length(smearStructArray(iElement).cadenceNumbers);
    nMaskedSmearColumns = size(smearStructArray(iElement).smearCorrectionStructLC.mSmearColumns, 1);
    nVirtualSmearColumns = size(smearStructArray(iElement).smearCorrectionStructLC.vSmearColumns, 1);
end

totalCadences = sum(nCadences);
numMColumns = max(nMaskedSmearColumns);
numVColumns = max(nVirtualSmearColumns);


% create output structure
smearStruct = smearStructArray(1);
smearStruct.cadenceNumbers   = zeros(totalCadences,1);
smearStruct.startTimeStamps  = zeros(totalCadences,1);
smearStruct.midTimeStamps    = zeros(totalCadences,1);
smearStruct.endTimeStamps    = zeros(totalCadences,1);

smearStruct.smearCorrectionStructLC.mjd             = zeros(totalCadences,1);
smearStruct.smearCorrectionStructLC.mSmearPixels    = zeros(numMColumns,totalCadences);
smearStruct.smearCorrectionStructLC.mSmearGaps      = true(numMColumns,totalCadences);
smearStruct.smearCorrectionStructLC.vSmearPixels    = zeros(numVColumns,totalCadences);
smearStruct.smearCorrectionStructLC.vSmearGaps      = true(numVColumns,totalCadences);


% fill in the output structure
smearStruct.smearCorrectionStructLC.mSmearColumns = (1:numMColumns)';
smearStruct.smearCorrectionStructLC.vSmearColumns = (1:numVColumns)';

indexStart = 1;
for iElement = 1:nElements
    
    indexEnd = indexStart + nCadences(iElement) - 1;
    
    % fill timestamps
    smearStruct.cadenceNumbers(indexStart:indexEnd)  = smearStructArray(iElement).cadenceNumbers;
    smearStruct.startTimeStamps(indexStart:indexEnd) = smearStructArray(iElement).startTimeStamps;
    smearStruct.midTimeStamps(indexStart:indexEnd)   = smearStructArray(iElement).midTimeStamps;
    smearStruct.endTimeStamps(indexStart:indexEnd)   = smearStructArray(iElement).endTimeStamps;
    
    smearStruct.smearCorrectionStructLC.mjd (indexStart:indexEnd) = ...
        smearStructArray(iElement).smearCorrectionStructLC.mjd;
    
    % fill masked smear data
    columns = smearStructArray(iElement).smearCorrectionStructLC.mSmearColumns;
    coulmnsLogical = columns ~= 0;
    smearStruct.smearCorrectionStructLC.mSmearPixels(columns(coulmnsLogical),indexStart:indexEnd) = ...
        smearStructArray(iElement).smearCorrectionStructLC.mSmearPixels(coulmnsLogical,:);    
    
    smearStruct.smearCorrectionStructLC.mSmearGaps(columns(coulmnsLogical),indexStart:indexEnd) = ...
        smearStructArray(iElement).smearCorrectionStructLC.mSmearGaps(coulmnsLogical,:);
    
    % fill virtual smear data
    columns = smearStructArray(iElement).smearCorrectionStructLC.vSmearColumns;
    coulmnsLogical = columns ~= 0;
    smearStruct.smearCorrectionStructLC.vSmearPixels(columns(coulmnsLogical),indexStart:indexEnd) = ...
        smearStructArray(iElement).smearCorrectionStructLC.vSmearPixels(coulmnsLogical,:);    
    
    smearStruct.smearCorrectionStructLC.vSmearGaps(columns(coulmnsLogical),indexStart:indexEnd) = ...
        smearStructArray(iElement).smearCorrectionStructLC.vSmearGaps(coulmnsLogical,:);
    
    indexStart = indexEnd + 1;
end

% pick out the unique cadence indices and save result
[uniqueCadences, uniqueIndices] = unique(smearStruct.cadenceNumbers);                              %#ok<ASGLU>

smearStruct.cadenceNumbers   = smearStruct.cadenceNumbers(uniqueIndices);
smearStruct.startTimeStamps  = smearStruct.startTimeStamps(uniqueIndices);
smearStruct.midTimeStamps    = smearStruct.midTimeStamps(uniqueIndices);
smearStruct.endTimeStamps    = smearStruct.endTimeStamps(uniqueIndices);

smearStruct.smearCorrectionStructLC.mSmearPixels = smearStruct.smearCorrectionStructLC.mSmearPixels(:,uniqueIndices);
smearStruct.smearCorrectionStructLC.mSmearGaps   = smearStruct.smearCorrectionStructLC.mSmearGaps(:,uniqueIndices);
smearStruct.smearCorrectionStructLC.vSmearPixels = smearStruct.smearCorrectionStructLC.vSmearPixels(:,uniqueIndices);
smearStruct.smearCorrectionStructLC.vSmearGaps   = smearStruct.smearCorrectionStructLC.vSmearGaps(:,uniqueIndices);

% sparsify gap arrays in order to match incoming struct
smearStruct.smearCorrectionStructLC.mSmearGaps = sparse(smearStruct.smearCorrectionStructLC.mSmearGaps);
smearStruct.smearCorrectionStructLC.vSmearGaps = sparse(smearStruct.smearCorrectionStructLC.vSmearGaps);