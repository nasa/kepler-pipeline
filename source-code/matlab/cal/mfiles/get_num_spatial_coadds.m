function numCoaddedRowsOrCols = get_num_spatial_coadds(inputsStruct, pixelTypeString)
%
% function to extract the number of spatial coadds for CAL collateral
% pixel types (black or smear) for a given CAL input structure.
%
% INPUTS:
%   inputsStruct      CAL input struct
%
%   pixelTypeString   collateral pixel type = 'black', 'maskedBlack',
%                     'virtualBlack', 'maskedSmear', or 'virtualSmear'
%
%   numSpatialCoadds  number of pixels that were coadded onboard the s/c
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


% extract config maps
spacecraftConfigMap = inputsStruct.spacecraftConfigMap;
configMapObject     = configMapClass(spacecraftConfigMap);

% take first cadence timestamp of inputs
timestamp = inputsStruct.cadenceTimes.midTimestamps(1);


%--------------------------------------------------------------------------
% extract start and end row/cols for black, masked, and virtual smear regions
% that were spatially coadded into the black column, virtual smear row, or
% masked smear row that are inputs into CAL;  Row/cols have already been
% converted to 1-based indexing in these methods
%--------------------------------------------------------------------------
if strcmp(pixelTypeString, 'black')

    blackStartColumns = get_black_start_column(configMapObject, timestamp);
    blackEndColumns   = get_black_end_column(configMapObject, timestamp);
    numCoaddedRowsOrCols = blackEndColumns - blackStartColumns + 1;

elseif strcmp(pixelTypeString, 'maskedSmear')

    maskedSmearStartRows = get_masked_smear_start_row(configMapObject, timestamp);
    maskedSmearEndRows   = get_masked_smear_end_row(configMapObject, timestamp);
    numCoaddedRowsOrCols = maskedSmearEndRows - maskedSmearStartRows + 1;

elseif strcmp(pixelTypeString, 'virtualSmear')

    virtualSmearStartRows = get_virtual_smear_start_row(configMapObject, timestamp);
    virtualSmearEndRows   = get_virtual_smear_end_row(configMapObject, timestamp);
    numCoaddedRowsOrCols = virtualSmearEndRows - virtualSmearStartRows + 1;

elseif strcmp(pixelTypeString, 'maskedBlack')

    blackStartColumns = get_black_start_column(configMapObject, timestamp);
    blackEndColumns   = get_black_end_column(configMapObject, timestamp);
    numberOfBlackColumns = blackEndColumns - blackStartColumns + 1;

    maskedSmearStartRows = get_masked_smear_start_row(configMapObject, timestamp);
    maskedSmearEndRows   = get_masked_smear_end_row(configMapObject, timestamp);
    numberOfMaskedSmearRows = maskedSmearEndRows - maskedSmearStartRows + 1;

    numCoaddedRowsOrCols   = numberOfBlackColumns.*numberOfMaskedSmearRows;

elseif strcmp(pixelTypeString, 'virtualBlack')

    blackStartColumns = get_black_start_column(configMapObject, timestamp);
    blackEndColumns   = get_black_end_column(configMapObject, timestamp);
    numberOfBlackColumns = blackEndColumns - blackStartColumns + 1;

    virtualSmearStartRows = get_virtual_smear_start_row(configMapObject, timestamp);
    virtualSmearEndRows   = get_virtual_smear_end_row(configMapObject, timestamp);
    numberOfVirtualSmearRows = virtualSmearEndRows - virtualSmearStartRows + 1;

    numCoaddedRowsOrCols  = numberOfBlackColumns.*numberOfVirtualSmearRows;
end


return;
