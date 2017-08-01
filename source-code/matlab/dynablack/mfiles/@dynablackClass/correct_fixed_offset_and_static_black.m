function  dynablackObject = correct_fixed_offset_and_static_black(dynablackObject)
%
% function  dynablackObject = correct_fixed_offset_and_static_black(dynablackObject)
%
% This dynablack method removes the static 2D black and the fixed offset from the incoming data.
% The dynablack object is modified but any spatially coadded pixels remain spatially coadded on
% exit.
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
removeFixedOffset = dynablackObject.dynablackModuleParameters.removeFixedOffset;
removeStatic2DBlack = dynablackObject.dynablackModuleParameters.removeStatic2DBlack;
reverseClockedEnabled = dynablackObject.dynablackModuleParameters.reverseClockedEnabled;

if ~removeFixedOffset && ~removeStatic2DBlack    
    % nothing to be done - just return with unaltered object
    return;
end
if removeFixedOffset
    % display a message
    disp('Remove fixed offset ...');
end
if removeStatic2DBlack    
    % display a message
    disp('Remove static 2D black...');
end

t0 = clock;

% ~~~~~~~~~ get channel config
nCcdRows = dynablackObject.fcConstants.CCD_ROWS;
nCcdColumns = dynablackObject.fcConstants.CCD_COLUMNS;
channel = convert_from_module_output(dynablackObject.ccdModule, dynablackObject.ccdOutput);

% ~~~~~~~~~ retrieve static 2D black (DN/read)
staticTwoDBlackObject = twoDBlackClass(dynablackObject.twoDBlackModel);
black = get_two_d_black(staticTwoDBlackObject);

% ~~~~~~~~~ either use the static 2D black or a zero proxy
if removeStatic2DBlack
    % static black model contains the mean black but pixels do not so subtract mean black from static black
    black = black - dynablackObject.requantTables.meanBlackEntries(channel);
else
    black = zeros(nCcdRows,nCcdColumns);
end


% ~~~~~~~~~ retrieve spatial and temporal coadd parameters from config map
configMapObject = configMapClass(dynablackObject.spacecraftConfigMap);

% get timestamps - long cadence timestamps - interpolate across gaps
cadenceTimes = dynablackObject.cadenceTimes.midTimestamps;
cadenceGaps = dynablackObject.cadenceTimes.gapIndicators;
cadenceNumbers = dynablackObject.cadenceTimes.cadenceNumbers;
lcMjds = interp1( cadenceNumbers(~cadenceGaps), cadenceTimes(~cadenceGaps), cadenceNumbers, 'linear', 'extrap');

% reverse clocked and ffi timestamps - both are ungapped by definition
if reverseClockedEnabled
    rcMjds = dynablackObject.reverseClockedCadenceTimes.midTimestamps;
end
ffiMjds = [dynablackObject.rawFfis.midTimestamp];


% ~~~~~~~~~ get number of reads per for each data type (LC, RC(LC) and FFI) at timestamps
% assume these are the same for most of the timestamps - WILL BREAK DYNABLACK IF CONFIG MAP CHANGES OVER UNIT OF WORK
readsPerLongCadence = median(get_number_of_exposures_per_long_cadence_period(configMapObject,lcMjds));
if reverseClockedEnabled
    readsPerRcLongCadence = median(get_number_of_exposures_per_long_cadence_period(configMapObject,rcMjds));
end
readsPerFfi = median(get_number_of_exposures_per_ffi(configMapObject,ffiMjds));

% ~~~~~~~~~ extract one-based lc collateral coadd regions from config map
% assume these are the same for most of the timestamps - WILL BREAK DYNABLACK IF CONFIG MAP CHANGES OVER UNIT OF WORK
lcMaskedSmearRows     = median(get_masked_smear_start_row(configMapObject,lcMjds)):median(get_masked_smear_end_row(configMapObject,lcMjds));
lcVirtualSmearRows    = median(get_virtual_smear_start_row(configMapObject,lcMjds)):median(get_virtual_smear_end_row(configMapObject,lcMjds));
lcTrailingBlackColumns = median(get_black_start_column(configMapObject,lcMjds)):median(get_black_end_column(configMapObject,lcMjds));

% ~~~~~~~~~ extract one-based rc collateral coadd regions from config map
% assume these are the same for most of the timestamps - WILL BREAK DYNABLACK IF CONFIG MAP CHANGES OVER UNIT OF WORK
if reverseClockedEnabled
    rcMaskedSmearRows     = median(get_masked_smear_start_row(configMapObject,rcMjds)):median(get_masked_smear_end_row(configMapObject,rcMjds));
    rcVirtualSmearRows    = median(get_virtual_smear_start_row(configMapObject,rcMjds)):median(get_virtual_smear_end_row(configMapObject,rcMjds));
    rcTrailingBlackColumns = median(get_black_start_column(configMapObject,rcMjds)):median(get_black_end_column(configMapObject,rcMjds));
end

% ~~~~~~~~~ either use the the fixed offset retrieved from the config map or a zero proxy
if removeFixedOffset
    % extract fixed offset for lc data (ffi do not have a fixed offset applied)
    % assume these are the same for most of the timestamps - WILL BREAK DYNABLACK IF CONFIG MAP CHANGES OVER UNIT OF WORK
    lcfixedOffset = median(get_long_cadence_fixed_offset(configMapObject, lcMjds));

    % extract fixed offset for rc data (ffi do not have a fixed offset applied)
    % assume these are the same for most of the timestamps - WILL BREAK DYNABLACK IF CONFIG MAP CHANGES OVER UNIT OF WORK
    if reverseClockedEnabled
        rcfixedOffset = median(get_long_cadence_fixed_offset(configMapObject, rcMjds));
    end
else
    lcfixedOffset = 0;
    rcfixedOffset = 0;
end


% ~~~~~~~~~ extract pixel data which has been converted to one-based row/column
maskedSmearColumns = [dynablackObject.maskedSmearPixels.column];
maskedSmearValues  = [dynablackObject.maskedSmearPixels.values];
virtualSmearColumns = [dynablackObject.virtualSmearPixels.column];
virtualSmearValues  = [dynablackObject.virtualSmearPixels.values];
blackRows = [dynablackObject.blackPixels.row];
blackValues = [dynablackObject.blackPixels.values];

arpRows = [dynablackObject.arpTargetPixels.row];
arpColumns = [dynablackObject.arpTargetPixels.column];
arpValues = [dynablackObject.arpTargetPixels.values];

backgroundRows = [dynablackObject.backgroundPixels.row];
backgroundColumns = [dynablackObject.backgroundPixels.column];
backgroundValues = [dynablackObject.backgroundPixels.values];

if reverseClockedEnabled
    rcMaskedSmearColumns = [dynablackObject.reverseClockedMaskedSmearPixels.column];
    rcMaskedSmearValues  = [dynablackObject.reverseClockedMaskedSmearPixels.values];
    rcVirtualSmearColumns = [dynablackObject.reverseClockedVirtualSmearPixels.column];
    rcVirtualSmearValues  = [dynablackObject.reverseClockedVirtualSmearPixels.values];
    rcBlackRows = [dynablackObject.reverseClockedBlackPixels.row];
    rcBlackValues = [dynablackObject.reverseClockedBlackPixels.values];
    
    rcBackgroundRows = [dynablackObject.reverseClockedBackgroundPixels.row];
    rcBackgroundColumns = [dynablackObject.reverseClockedBackgroundPixels.column];
    rcBackgroundValues = [dynablackObject.reverseClockedBackgroundPixels.values];
    rcTargetRows = [dynablackObject.reverseClockedTargetPixels.row];
    rcTargetColumns = [dynablackObject.reverseClockedTargetPixels.column];
    rcTargetValues = [dynablackObject.reverseClockedTargetPixels.values];
end


% ~~~~~~~~~ build black for collateral
blackForMaskedSmear = sum(black(lcMaskedSmearRows,maskedSmearColumns)) .* readsPerLongCadence;
blackForVirtualSmear = sum(black(lcVirtualSmearRows,virtualSmearColumns)) .* readsPerLongCadence;
blackForBlack = rowvec(sum(black(blackRows,lcTrailingBlackColumns),2)) .* readsPerLongCadence;

% ~~~~~~~~~ build black for arp and background
blackForArp = black(sub2ind([nCcdRows,nCcdColumns],arpRows,arpColumns)) .* readsPerLongCadence;
blackForBackground = black(sub2ind([nCcdRows,nCcdColumns],backgroundRows,backgroundColumns)) .* readsPerLongCadence;

if reverseClockedEnabled
    % ~~~~~~~~~ build black for rc collateral
    blackForRcMaskedSmear = sum(black(rcMaskedSmearRows,rcMaskedSmearColumns)) .* readsPerRcLongCadence;
    blackForRcVirtualSmear = sum(black(rcVirtualSmearRows,rcVirtualSmearColumns)) .* readsPerRcLongCadence;
    blackForRcBlack = rowvec(sum(black(rcBlackRows,rcTrailingBlackColumns),2)) .* readsPerRcLongCadence;
    
    % ~~~~~~~~~ build black for rc target and background
    blackForRcTarget = black(sub2ind([nCcdRows,nCcdColumns],rcTargetRows,rcTargetColumns)) .* readsPerRcLongCadence;
    blackForRcBackround = black(sub2ind([nCcdRows,nCcdColumns],rcBackgroundRows,rcBackgroundColumns)) .* readsPerRcLongCadence;
end

% ~~~~~~~~~ build black for ffi (image concatenates to columns x rows)
blackForFfi = black' .* readsPerFfi;

% ~~~~~~~~~ adjust fclc and rclc data for fixed offset and static black
maskedSmearValues   = maskedSmearValues - lcfixedOffset - repmat(blackForMaskedSmear,size(maskedSmearValues,1),1);
virtualSmearValues  = virtualSmearValues - lcfixedOffset - repmat(blackForVirtualSmear,size(virtualSmearValues,1),1);
blackValues         = blackValues - lcfixedOffset - repmat(blackForBlack,size(blackValues,1),1);
arpValues           = arpValues - lcfixedOffset - repmat(blackForArp,size(arpValues,1),1);
backgroundValues    = backgroundValues - lcfixedOffset - repmat(blackForBackground,size(backgroundValues,1),1); 

if reverseClockedEnabled
    rcMaskedSmearValues     = rcMaskedSmearValues - rcfixedOffset - repmat(blackForRcMaskedSmear,size(rcMaskedSmearValues,1),1);
    rcVirtualSmearValues    = rcVirtualSmearValues - rcfixedOffset - repmat(blackForRcVirtualSmear,size(rcVirtualSmearValues,1),1);
    rcBlackValues           = rcBlackValues - rcfixedOffset - repmat(blackForRcBlack,size(rcBlackValues,1),1);
    rcTargetValues          = rcTargetValues - rcfixedOffset - repmat(blackForRcTarget,size(rcTargetValues,1),1);
    rcBackgroundValues      = rcBackgroundValues - rcfixedOffset - repmat(blackForRcBackround,size(rcBackgroundValues,1),1);
end

% ~~~~~~~~~ read back into object
for iCol = 1:size(maskedSmearValues,2)
    dynablackObject.maskedSmearPixels(iCol).values = maskedSmearValues(:,iCol);
end
for iCol = 1:size(virtualSmearValues,2)
    dynablackObject.virtualSmearPixels(iCol).values = virtualSmearValues(:,iCol);
end
for iCol = 1:size(blackValues,2)
    dynablackObject.blackPixels(iCol).values = blackValues(:,iCol);
end
for iCol = 1:size(arpValues,2)
    dynablackObject.arpTargetPixels(iCol).values = arpValues(:,iCol);
end
for iCol = 1:size(backgroundValues,2)
    dynablackObject.backgroundPixels(iCol).values = backgroundValues(:,iCol);
end

if reverseClockedEnabled
    for iCol = 1:size(rcMaskedSmearValues,2)
        dynablackObject.reverseClockedMaskedSmearPixels(iCol).values = rcMaskedSmearValues(:,iCol);
    end
    for iCol = 1:size(rcVirtualSmearValues,2)
        dynablackObject.reverseClockedVirtualSmearPixels(iCol).values = rcVirtualSmearValues(:,iCol);
    end
    for iCol = 1:size(rcBlackValues,2)
        dynablackObject.reverseClockedBlackPixels(iCol).values = rcBlackValues(:,iCol);
    end
    for iCol = 1:size(rcTargetValues,2)
        dynablackObject.reverseClockedTargetPixels(iCol).values = rcTargetValues(:,iCol);
    end
    for iCol = 1:size(rcBackgroundValues,2)
        dynablackObject.reverseClockedBackgroundPixels(iCol).values = rcBackgroundValues(:,iCol);
    end
end


% ~~~~~~~~~ adjust ffis for static black ( no fixed offset is applied on s/c for ffi data )
for iFfi = 1:length(dynablackObject.rawFfis)        
    rawImage = [dynablackObject.rawFfis(iFfi).image.array];
    rawImage = rawImage - blackForFfi;    
    % read back into object
    for iRow = 1:size(rawImage,2)
        dynablackObject.rawFfis(iFfi).image(iRow).array = rawImage(:,iRow);
    end
end
   
% display elapsed time
t1 = clock;
disp(['Elapsed time = ',num2str(etime(t1,t0)/60),' minutes']);disp(' ');


