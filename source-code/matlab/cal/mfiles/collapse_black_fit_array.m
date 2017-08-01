function blackFitStruct = collapse_black_fit_array(blackFitStructArray)
% function blackFitStruct = collapse_black_fit_array(blackFitStructArray)
%
% This function collapses an array of blackFitStruct as retrieved from the oneDBlackBlobs to produce a single structure containing the same
% information. If blackFitStructArray = [], blackFitStruct = [] is returned.
%
% INPUT:    blackFitStructArray     Contains one field: struct [1xm] array of structs
%                                   
%                                   Each element in struct contains the following fields:
%
%                                        cadences: absolute cadence numbers [nCadencex1 double]
%                                 startTimeStamps: mjd start times [nCadencex1 double]
%                                   midTimeStamps: mjd mid times [nCadencex1 double]
%                                   endTimeStamps: mjd end times [nCadencex1 double]
%                                          module: ccd module
%                                          output: ccd output
%                         blackCorrectionStructLC: structure containing 1D black fit [1x1 struct]
%
% OUTPUT:   blackFitStruct          single element of blackFitStruct with
%                                   fields updated to contain the aggregate
%                                   of the information input
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



% check trivial case
if( isempty(blackFitStructArray) )
    blackFitStruct = [];
    return;
end

% parse array of structures
if( ~isfield(blackFitStructArray,'struct') )
    error('Fieldname struct missing in structure returned from get_struct_for_cadence. Cannot collapse 1D black blob.');
else
    blackFitStructArray = [blackFitStructArray.struct];
end
    
% single element array requires no collapsing
nElements = length(blackFitStructArray);
if( nElements == 1 )
    blackFitStruct = blackFitStructArray;
    return;
end


% allocate space
nCadences(nElements) = 0;
for iElement = 1:nElements
    nCadences(iElement) = length(blackFitStructArray(iElement).cadences);
end

totalCadences = sum(nCadences);

blackFitStruct = blackFitStructArray(1);
blackFitStruct.cadences         = zeros(totalCadences,1);
blackFitStruct.startTimeStamps  = zeros(totalCadences,1);
blackFitStruct.midTimeStamps    = zeros(totalCadences,1);
blackFitStruct.endTimeStamps    = zeros(totalCadences,1);

numCoeffs = size(blackFitStruct.blackCorrectionStructLC.original,2);

blackFitStruct.blackCorrectionStructLC.timestamp            = zeros(totalCadences,1);
blackFitStruct.blackCorrectionStructLC.gapIndicators        = false(totalCadences,1);
blackFitStruct.blackCorrectionStructLC.original             = zeros(totalCadences,numCoeffs);
blackFitStruct.blackCorrectionStructLC.originalCovariance   = zeros(totalCadences,numCoeffs,numCoeffs);
blackFitStruct.blackCorrectionStructLC.smoothed             = zeros(totalCadences,numCoeffs);
blackFitStruct.blackCorrectionStructLC.smoothedCovariance   = zeros(totalCadences,numCoeffs,numCoeffs);


% fill in the structure
indexStart = 1;
for iElement = 1:nElements
    
    indexEnd = indexStart + nCadences(iElement) - 1;
    
    blackFitStruct.cadences(indexStart:indexEnd)        = blackFitStructArray(iElement).cadences;
    blackFitStruct.startTimeStamps(indexStart:indexEnd) = blackFitStructArray(iElement).startTimeStamps;
    blackFitStruct.midTimeStamps(indexStart:indexEnd)   = blackFitStructArray(iElement).midTimeStamps;
    blackFitStruct.endTimeStamps(indexStart:indexEnd)   = blackFitStructArray(iElement).endTimeStamps;
    
    blackFitStruct.blackCorrectionStructLC.timestamp(indexStart:indexEnd) = ...
        blackFitStructArray(iElement).blackCorrectionStructLC.timestamp;
    blackFitStruct.blackCorrectionStructLC.gapIndicators(indexStart:indexEnd) = ...
        blackFitStructArray(iElement).blackCorrectionStructLC.gapIndicators;
    blackFitStruct.blackCorrectionStructLC.original(indexStart:indexEnd,:) = ...
        blackFitStructArray(iElement).blackCorrectionStructLC.original;
    blackFitStruct.blackCorrectionStructLC.originalCovariance(indexStart:indexEnd,:,:) = ...
        blackFitStructArray(iElement).blackCorrectionStructLC.originalCovariance;
    blackFitStruct.blackCorrectionStructLC.smoothed(indexStart:indexEnd,:) = ...
        blackFitStructArray(iElement).blackCorrectionStructLC.smoothed;
    blackFitStruct.blackCorrectionStructLC.smoothedCovariance(indexStart:indexEnd,:,:) = ...
        blackFitStructArray(iElement).blackCorrectionStructLC.smoothedCovariance;
    
    indexStart = indexEnd + 1;
end

% pick out the unique cadence indices and save in output struct
[uniqueCadences, uniqueIndices] = unique(blackFitStruct.cadences);                              %#ok<ASGLU>

blackFitStruct.cadences         = blackFitStruct.cadences(uniqueIndices);
blackFitStruct.startTimeStamps  = blackFitStruct.startTimeStamps(uniqueIndices);
blackFitStruct.midTimeStamps    = blackFitStruct.midTimeStamps(uniqueIndices);
blackFitStruct.endTimeStamps    = blackFitStruct.endTimeStamps(uniqueIndices);

blackFitStruct.blackCorrectionStructLC.timestamp            = blackFitStruct.blackCorrectionStructLC.timestamp(uniqueIndices);
blackFitStruct.blackCorrectionStructLC.gapIndicators        = blackFitStruct.blackCorrectionStructLC.gapIndicators(uniqueIndices);
blackFitStruct.blackCorrectionStructLC.original             = blackFitStruct.blackCorrectionStructLC.original(uniqueIndices,:);
blackFitStruct.blackCorrectionStructLC.originalCovariance   = blackFitStruct.blackCorrectionStructLC.originalCovariance(uniqueIndices,:,:);
blackFitStruct.blackCorrectionStructLC.smoothed             = blackFitStruct.blackCorrectionStructLC.smoothed(uniqueIndices,:);
blackFitStruct.blackCorrectionStructLC.smoothedCovariance   = blackFitStruct.blackCorrectionStructLC.smoothedCovariance(uniqueIndices,:,:);


