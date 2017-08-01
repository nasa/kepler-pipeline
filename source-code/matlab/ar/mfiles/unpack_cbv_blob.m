function [ cbvOutput ] = unpack_cbv_blob(inputsStruct)
% inputsStruct
%     .cotrendingBasisVectorBlobs
%     .unpackCbvBlob - logical.  When false this returns a default struct suitable
%            for passing back through the Java interface.
%     .cadenceTimesStruct - struct.  The usual set of per cadence timestamps.
% cbvOutput - struct
%    .mapOrder
%    .nobandVectors - a 2d matrix processed by array2D_to_struct
%    .additionalGaps - These are any kind of gaps that may be present int
%         in the CBV vectors.  Usually this is because the unit of work may
%         span more cadences than the basis vector blob.
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

if ~inputsStruct.unpackCbvBlob
    cbvOutput.mapOrder = -1;
    cbvOutput.nobandVectors = [];
    cbvOutput.additionalGaps = [];
    return
end

cbvStruct = ...
    cbv_blob_series_to_struct(inputsStruct.cotrendingBasisVectorBlobs, inputsStruct.cadenceTimesStruct.cadenceNumbers(1), inputsStruct.cadenceTimesStruct.cadenceNumbers(end));

cbvOutput.mapOrder = size(cbvStruct.basisVectorsNoBands, 2);
cbvOutput.nobandVectors =  [cbvStruct.basisVectorsNoBands cbvStruct.lesserBasisVectorsNoBands];

uowStartCadence = inputsStruct.cadenceTimesStruct.cadenceNumbers(1);
uowEndCadence = inputsStruct.cadenceTimesStruct.cadenceNumbers(end);

%  Just incase the basis vector spans fewer cadences than we want return
% the matrix sized for the correct basis vectors.
basisVectorsForExport = zeros(uowEndCadence - uowStartCadence + 1, 16);
startIndex = cbvStruct.startCadence - uowStartCadence + 1;
endIndex = cbvStruct.endCadence - uowStartCadence + 1;
basisVectorsForExport(startIndex:endIndex, :) =  cbvOutput.nobandVectors(:, 1:16);

cbvOutput.additionalGaps = true(uowEndCadence - uowStartCadence + 1, 1);
cbvOutput.additionalGaps(startIndex:endIndex) = false;

cbvOutput.nobandVectors = basisVectorsForExport';
cbvOutput.nobandVectors = array2D_to_struct(cbvOutput.nobandVectors);
return

