function [dynamicCollateralTwoDBlackStruct] = retrieve_dynamic_2d_black_for_collateral_data(calObject)
% 
% function [dynamicCollateralTwoDBlackStruct] = retrieve_dynamic_2d_black_for_collateral_data(calObject)
%
% This calClass method retrieves the dynamic 2D black for the trailing black, masked smear and virtual smear
% pixels, spatially coadds the pixels across rows or columns per the spacecraft config map, and returns the
% mean value across spatial coadds in a 2D array of size (nPixels x nCadences) x 1. The pixels are ordered 
% by region; trailing black, masked smear, virtual smear. The corresponding one-based row/column pairs are 
% returned in the nPixels x 1 arrays, rows and columns, -1 is the default value for a N/A index, e.g. trailing
% black will have a valid row number but the columns will all be -1, masked smear will have a valid column number
% but all the rows will be -1.
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


% extract flags
processShortCadence = calObject.dataFlags.processShortCadence;


% get coadded collateral rows and cols (1-based) per spacecraft config map(s)
% if more than one config map is contained inthe calObject, make the coadded regions which agree with all config maps
configMapObject = configMapClass(calObject.spacecraftConfigMap);

trailingBlackColumns = min(get_black_start_column(configMapObject)):max(get_black_end_column(configMapObject));
maskedSmearRows      = min(get_masked_smear_start_row(configMapObject)):max(get_masked_smear_end_row(configMapObject));
virtualSmearRows     = min(get_virtual_smear_start_row(configMapObject)):max(get_virtual_smear_end_row(configMapObject));

% get collateral rows - need all rows in ccd to build "black correction" in dynamic 2D case
trailingBlackRows = 1:calObject.fcConstants.CCD_ROWS;

% get collateral columns for only the pixels corrected
maskedSmearColumns  = [calObject.maskedSmearPixels.column];
virtualSmearColumns = [calObject.virtualSmearPixels.column];

% determine sizes of regions
nTrailingBlackRows      = length(trailingBlackRows);
nTrailingBlackColumns   = length(trailingBlackColumns);
nMaskedSmearRows        = length(maskedSmearRows);
nMaskedSmearColumns     = length(maskedSmearColumns);
nVirtualSmearRows       = length(virtualSmearRows);
nVirtualSmearColumns    = length(virtualSmearColumns);


% get mid timestamp mjds and dynablack fit results
cadenceTimes = calObject.cadenceTimes;
midTimestamps = cadenceTimes.midTimestamps;
cadenceNumbers = cadenceTimes.cadenceNumbers;
timeGaps = cadenceTimes.gapIndicators;
initializedModels = calObject.dynoblackModels;

% fill timestamps for gapped cadences by linear interpolation
midTimestamps(timeGaps) = interp1(cadenceNumbers(~timeGaps), midTimestamps(~timeGaps),cadenceNumbers(timeGaps),'linear','extrap');

% count number of pixels to output
nPixels = nTrailingBlackRows + nMaskedSmearColumns + nVirtualSmearColumns;
nCadences = length(midTimestamps);

% for SC add space for doubley coadded masked and virtual black pixels, two total
if processShortCadence
    nPixels = nPixels + 2;
end

% pre-allocate output arrays with enought space for all collateral pixels (black + mSmear + vSmear)
collateralBlack = zeros(nPixels,nCadences);
collateralBlackErrors = zeros(nPixels,nCadences);
collateralBlackRows = zeros(nPixels,1);
collateralBlackColumns = zeros(nPixels,1);

% collateral type identifies coadded pixels
% 1 == trailing black
% 2 == masked smear
% 3 == virtual smear
% 4 == masked black
% 5 == virtual black
collateralType = zeros(nPixels,1);


% retrieve blacks for regions using rectangular mode (listMode = 2) and populate output
% with the mean value over coadded rows/columns for each collateral pixel

% trailing black region
listMode = 2;
[ black, blackErrors ] = retrieve_dynamic_2d_black( initializedModels, trailingBlackRows, trailingBlackColumns, midTimestamps, listMode );

rows = trailingBlackRows';
cols = -1 .* ones(size(rows));

firstIndex = 1;
lastIndex = firstIndex + nTrailingBlackRows - 1;

collateralType(firstIndex:lastIndex) = 1;

collateralBlack(firstIndex:lastIndex, :) = squeeze(mean(reshape(black,nTrailingBlackRows,nTrailingBlackColumns,nCadences),2));
collateralBlackErrors(firstIndex:lastIndex, :) = squeeze(sqrt(mean(reshape(blackErrors,nTrailingBlackRows,nTrailingBlackColumns,nCadences).^2,2)));
collateralBlackRows(firstIndex:lastIndex) = rows;
collateralBlackColumns(firstIndex:lastIndex) = cols;


% masked smear region 
listMode = 2;
[ black, blackErrors ] = retrieve_dynamic_2d_black( initializedModels, maskedSmearRows, maskedSmearColumns, midTimestamps, listMode );

cols = maskedSmearColumns';
rows = -1 .* ones(size(cols));

firstIndex = lastIndex + 1;
lastIndex = firstIndex + nMaskedSmearColumns - 1;

collateralType(firstIndex:lastIndex) = 2;

collateralBlack(firstIndex:lastIndex, :) = squeeze(mean(reshape(black,nMaskedSmearRows,nMaskedSmearColumns,nCadences),1));
collateralBlackErrors(firstIndex:lastIndex, :) = squeeze(sqrt(mean(reshape(blackErrors,nMaskedSmearRows,nMaskedSmearColumns,nCadences).^2,1)));
collateralBlackRows(firstIndex:lastIndex) = rows;
collateralBlackColumns(firstIndex:lastIndex) = cols;


% virtual smear region
listMode = 2;
[ black, blackErrors ] = retrieve_dynamic_2d_black( initializedModels, virtualSmearRows, virtualSmearColumns, midTimestamps, listMode );

cols = virtualSmearColumns';
rows = -1 .* ones(size(cols));

firstIndex = lastIndex + 1;
lastIndex = firstIndex + nVirtualSmearColumns - 1;

collateralType(firstIndex:lastIndex) = 3;

collateralBlack(firstIndex:lastIndex, :) = squeeze(mean(reshape(black,nVirtualSmearRows,nVirtualSmearColumns,nCadences),1));
collateralBlackErrors(firstIndex:lastIndex, :) = squeeze(sqrt(mean(reshape(blackErrors,nVirtualSmearRows,nVirtualSmearColumns,nCadences).^2,1)));
collateralBlackRows(firstIndex:lastIndex) = rows;
collateralBlackColumns(firstIndex:lastIndex) = cols;

% do masked and virtual black for SC
if processShortCadence
    
    % masked black - coadded rows and columns into a single pixel per cadence    
    listMode = 2;
    [ black, blackErrors ] = retrieve_dynamic_2d_black( initializedModels, maskedSmearRows, trailingBlackColumns, midTimestamps, listMode );

    nMaskedBlackPixels = 1;
    cols = -1;
    rows = -1;

    firstIndex = lastIndex + 1;
    lastIndex = firstIndex + nMaskedBlackPixels - 1;
    
    collateralType(firstIndex:lastIndex) = 4;

    collateralBlack(firstIndex:lastIndex, :) = squeeze(mean(mean(reshape(black,nMaskedSmearRows,nTrailingBlackColumns,nCadences),1),2));
    collateralBlackErrors(firstIndex:lastIndex, :) = squeeze(sqrt(mean(mean(reshape(blackErrors,nMaskedSmearRows,nTrailingBlackColumns,nCadences).^2,1),2)));
    collateralBlackRows(firstIndex:lastIndex) = rows;
    collateralBlackColumns(firstIndex:lastIndex) = cols;
    
    % virtual black - coadded rows and columns into a single pixel per cadence    
    listMode = 2;
    [ black, blackErrors ] = retrieve_dynamic_2d_black( initializedModels, virtualSmearRows, trailingBlackColumns, midTimestamps, listMode );

    nVirtualBlackPixels = 1;
    cols = -1;
    rows = -1;

    firstIndex = lastIndex + 1;
    lastIndex = firstIndex + nVirtualBlackPixels - 1;
    
    collateralType(firstIndex:lastIndex) = 5;

    collateralBlack(firstIndex:lastIndex, :) = squeeze(mean(mean(reshape(black,nVirtualSmearRows,nTrailingBlackColumns,nCadences),1),2));
    collateralBlackErrors(firstIndex:lastIndex, :) = squeeze(sqrt(mean(mean(reshape(blackErrors,nVirtualSmearRows,nTrailingBlackColumns,nCadences).^2,1),2)));
    collateralBlackRows(firstIndex:lastIndex) = rows;
    collateralBlackColumns(firstIndex:lastIndex) = cols;
end

% build output struct
dynamicCollateralTwoDBlackStruct.collateralBlack = collateralBlack;
dynamicCollateralTwoDBlackStruct.collateralBlackErrors = collateralBlackErrors;
dynamicCollateralTwoDBlackStruct.collateralBlackRows = collateralBlackRows;
dynamicCollateralTwoDBlackStruct.collateralBlackColumns = collateralBlackColumns;
dynamicCollateralTwoDBlackStruct.collateralType = collateralType;
