function [ dynamicPhotometricTwoDBlackStruct, partialFfiTwoDBlackStruct] = retrieve_dynamic_2d_black_for_photometric_data(calObject, calIntermediateStruct)
% 
% function [ dynamicPhotometricTwoDBlackStruct, partialFfiTwoDBlackStruct] = retrieve_dynamic_2d_black_for_photometric_data(calObject, calIntermediateStruct)
%
% This calClass method retrieves the dynamic 2D black for the photometric pixels and returns the values in a 2D array of size (nPixels x
% nCadences) x 1. The corresponding one-based row/column pairs are returned in the nPixels x 1 arrays, rows and columns.
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

% retrieve flags
isAvailableFfiPix = calObject.dataFlags.isAvailableFfiPix;

% retrieve dynablack fit results
initializedModels = calObject.dynoblackModels;

% get mid timestamp mjds
cadenceTimes = calObject.cadenceTimes;
midTimestamps = cadenceTimes.midTimestamps;
cadenceNumbers = cadenceTimes.cadenceNumbers;
timeGaps = cadenceTimes.gapIndicators;

% fill timestamps for gapped cadences by linear interpolation
midTimestamps(timeGaps) = interp1(cadenceNumbers(~timeGaps), midTimestamps(~timeGaps),cadenceNumbers(timeGaps),'linear','extrap');


% do photometric pixels -------------------------

% get target and background pixel rows and columns
rows = [calObject.targetAndBkgPixels.row];
columns = [calObject.targetAndBkgPixels.column];

% trim list to unique row/columns pairs
uniquePairs = unique([rows(:),columns(:)],'rows');

% retrieve blacks using pixel list mode (listMode = 1)
listMode = 1;
[ black, blackErrors ] = retrieve_dynamic_2d_black( initializedModels, uniquePairs(:,1), uniquePairs(:,2), midTimestamps, listMode );

% build output struct
dynamicPhotometricTwoDBlackStruct.photometricBlack = black;
dynamicPhotometricTwoDBlackStruct.photometricBlackErrors = blackErrors;
dynamicPhotometricTwoDBlackStruct.photometricBlackRows = uniquePairs(:,1);                                            % rows;
dynamicPhotometricTwoDBlackStruct.photometricBlackColumns = uniquePairs(:,2);                                         % columns;


% do ffi pixels ---------------------------------

if isAvailableFfiPix
    % extract ffi rows and cols
    ffiRows = calIntermediateStruct.ffiStruct(1).rows;
    ffiColumns = calIntermediateStruct.ffiStruct(1).columns;
    ffiTimestamps = [calIntermediateStruct.ffiStruct.timestamp];
    
    nRows = length(ffiRows);
    nColumns = length(ffiColumns);
    rowIndex = repmat(ffiRows(:)',nColumns,1);
    rowIndex = rowIndex(:);
    columnIndex = repmat(ffiColumns(:),1,nRows);
    columnIndex = columnIndex(:);
    
    % retrieve blacks using pixel list (listMode = 1)
    listMode = 1;
    [ black, blackErrors ] = retrieve_dynamic_2d_black( initializedModels, rowIndex, columnIndex, ffiTimestamps(:), listMode );
    
    % build output struct
    partialFfiTwoDBlackStruct.photometricBlack = black;
    partialFfiTwoDBlackStruct.photometricBlackErrors = blackErrors;
    partialFfiTwoDBlackStruct.photometricBlackRows = rowIndex;
    partialFfiTwoDBlackStruct.photometricBlackColumns = columnIndex;
    
else
    partialFfiTwoDBlackStruct = [];
end