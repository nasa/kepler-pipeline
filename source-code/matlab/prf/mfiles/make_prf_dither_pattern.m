% script to generate PRF dither pattern offsets
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
clear
% # of points on a side for total pattern
nDithers = 121;
% size in pixels of the total pattern
patternSize = 1;
% size in pixels of the high-density region
highDensitySize = 1/3;
% # of points in high-density region on a size
nPointsOnSideInHighDensity = 7; % 7 is unique good number for nDithers = 121

nPointsInHighDensity = nPointsOnSideInHighDensity^2;

lowDensitySize = patternSize;
lowDensitSquareSize = (patternSize - highDensitySize)/2;

nPointsInLowDensity = nDithers - nPointsInHighDensity;
nPointsOnSideInLowSquare = sqrt(nPointsInLowDensity/8);

highDensityDelta = highDensitySize/(nPointsOnSideInHighDensity-1);
lowDensityDelta = lowDensitSquareSize/(nPointsOnSideInLowSquare);

% center the pattern on 0
lowDensityStart = -patternSize/2;
highDensityStart = -highDensitySize/2;

% compute high-density region
for i=1:nPointsOnSideInHighDensity
    highDensityPoints(i) = highDensityStart + (i-1)*highDensityDelta;
end
[highDensityCol highDensityRow] = meshgrid(highDensityPoints, highDensityPoints);

% compute low-density square region
% generate lower left corner
for i=1:nPointsOnSideInLowSquare
    lowDensitySquarePoints(i) = lowDensityStart + (i-1)*lowDensityDelta;
end
[lowDensityCol lowDensityRow] = meshgrid(lowDensitySquarePoints, lowDensitySquarePoints);

% combine with high-density region
prfOffsetCol = [highDensityCol(:); lowDensityCol(:)];
prfOffsetRow = [highDensityRow(:); lowDensityRow(:)];

% use lower left corner as template for other regions
centerScale = (nPointsOnSideInLowSquare+1)/nPointsOnSideInLowSquare;
centerOffset = -lowDensityStart - lowDensityDelta;
topOffset = - 2*(lowDensityStart + lowDensityDelta);
% left-center
prfOffsetCol = [prfOffsetCol(:); lowDensityCol(:)];
prfOffsetRow = [prfOffsetRow(:); centerScale*(lowDensityRow(:) + centerOffset)];
% upper left
prfOffsetCol = [prfOffsetCol(:); lowDensityCol(:)];
prfOffsetRow = [prfOffsetRow(:); lowDensityRow(:) + topOffset];
% lower center
prfOffsetCol = [prfOffsetCol(:); centerScale*(lowDensityCol(:) + centerOffset)];
prfOffsetRow = [prfOffsetRow(:); lowDensityRow(:)];
% top center
prfOffsetCol = [prfOffsetCol(:); centerScale*(lowDensityCol(:) + centerOffset)];
prfOffsetRow = [prfOffsetRow(:); lowDensityRow(:) + topOffset];
% lower right
prfOffsetCol = [prfOffsetCol(:); lowDensityCol(:) + topOffset];
prfOffsetRow = [prfOffsetRow(:); lowDensityRow(:)];
% right-center
prfOffsetCol = [prfOffsetCol(:); lowDensityCol(:) + topOffset];
prfOffsetRow = [prfOffsetRow(:); centerScale*(lowDensityRow(:)  + centerOffset)];
% upper right
prfOffsetCol = [prfOffsetCol(:); lowDensityCol(:) + topOffset];
prfOffsetRow = [prfOffsetRow(:); lowDensityRow(:) + topOffset];

% randomize the order of the points
shuffleIndex = randperm(length(prfOffsetRow));
prfOffsetRow = prfOffsetRow(shuffleIndex);
prfOffsetCol = prfOffsetCol(shuffleIndex);

% move the zero offset to the first entry via swap
zeroIndex = find(prfOffsetRow == 0 & prfOffsetCol == 0);
tmpRow = prfOffsetRow(1);
tmpCol = prfOffsetCol(1);
prfOffsetRow(1) = prfOffsetRow(zeroIndex);
prfOffsetCol(1) = prfOffsetCol(zeroIndex);
prfOffsetRow(zeroIndex) = tmpRow;
prfOffsetCol(zeroIndex) = tmpCol;

figure(3);
scatter(prfOffsetCol(:), prfOffsetRow(:));

fcConstantsStruct = convert_fc_constants_java_2_struct();
plateScale = fcConstantsStruct.pixel2arcsec;
% compute the delta quaternions, treating the base RA and Dec as the actual
% roll etc., and the offset values as the desired roll etc.
deltaQuaternion = zeros(length(prfOffsetRow), 4);
for i=1:length(prfOffsetRow)
    deltaQuaternion(i,:) = ...
        make_delta_quaternion_from_row_column_motion(prfOffsetRow(i), prfOffsetCol(i), plateScale);
end

% now compute the ra and dec offsets for this pattern
% we do this by getting the nominal pointing vector for each cadence at which we
% take a dither.  Then we rotate that pointing vector via the above delta
% quaternions, giving an attitude for each dither.
raDec2PixModel = retrieve_ra_dec_2_pix_model();
raDec2PixObject = raDec2PixClass(raDec2PixModel, 'one-based');
pointingObject = pointingClass(raDec2PixModel.pointingModel);

startDate = '1 April 2009';
dateMjd = datestr2mjd(startDate);
 % now compute the ra and dec offsets for this pattern
module = 13;
output = 1;
row = 1023; % 1 pixel off from center of FOV
col = 1099;

% get base pointing ra and dec
[baseRa, baseDec] = pix_2_ra_dec(raDec2PixObject, module, output, row, col, dateMjd, 1);

% compute ra and dec offsets
for i=1:length(prfOffsetRow)
	[prfRelativeRa(i), prfRelativeDec(i)] = pix_2_ra_dec(raDec2PixObject, module, output, ...
        row + prfOffsetRow(i), col - prfOffsetCol(i), dateMjd, 1);
	prfRelativeRaOffset(i) = prfRelativeRa(i) - baseRa;
	prfRelativeDecOffset(i) = prfRelativeDec(i) - baseDec;
end

% compute the time for each dither
timePerDither = 1/48; % days at 30 minutes per dither
for i=1:nDithers
    % set the data time to be the first 15 minutes of a dither period
     endTimestamps(i) = dateMjd + (i-0.5)*timePerDither; % end of 15 minutes of period
%      endTimestamps(i) = dateMjd; % end of 15 minutes of period
end

% get the nominal pointing, returning nDithers x 3 array [ra, dec, roll]
nominalPointing = get_pointing(pointingObject, endTimestamps);
% compute the offset pointing by applying the delta quaternion for each
% cadence
for i=1:nDithers
    nominalQuaternion = radecphi_to_quaternion( ...
        nominalPointing(i,:), endTimestamps(i), raDec2PixObject );
    offsetQuaternion = quaternion_product( ...
        nominalQuaternion, deltaQuaternion(i,:));
    % convert back to [ra dec roll]
    offsetPointing = quaternion_to_radecphi( ...
        offsetQuaternion, endTimestamps(i), raDec2PixObject);
    prfRa(i) = offsetPointing(1);
    prfDec(i) = offsetPointing(2);
    prfRoll(i) = offsetPointing(3);
    
    prfRaOffset(i) = prfRa(i) - prfRa(1);
    prfDecOffset(i) = prfDec(i) - prfDec(1);
    prfRollOffset(i) = prfRoll(i) - prfRoll(1);
end

baseRa = prfRa(1);
baseDec = prfDec(1);
baseRoll = prfRoll(1);

singleDeltaQuaternion = single(deltaQuaternion);

% check delta quaternion by rotating the boresite vector
boresiteVector = [1 0 0 0];
radianToPix = 180*3600/pi;
for i=1:length(prfOffsetRow)
    rotatedBoresite(i,:) = ...
        quaternion_product(quaternion_inverse(deltaQuaternion(i,:)), ...
        quaternion_product(boresiteVector, deltaQuaternion(i,:)));
    rotatedRow(i) = rotatedBoresite(i,3)*radianToPix/plateScale;
    rotatedCol(i) = rotatedBoresite(i,2)*radianToPix/plateScale;
    errorRow(i) = abs(prfOffsetRow(i) - rotatedRow(i));
    errorCol(i) = abs(prfOffsetCol(i) - rotatedCol(i));

	% check that a single-precision quaterion is OK
    rotatedBoresite(i,:) = ...
        quaternion_product(quaternion_inverse(singleDeltaQuaternion(i,:)), ...
        quaternion_product(boresiteVector, singleDeltaQuaternion(i,:)));
    rotatedRowS(i) = rotatedBoresite(i,3)*radianToPix/plateScale;
    rotatedColS(i) = rotatedBoresite(i,2)*radianToPix/plateScale;
    errorRowS(i) = abs(prfOffsetRow(i) - rotatedRowS(i));
    errorColS(i) = abs(prfOffsetCol(i) - rotatedColS(i));
	
	dRow(i) = rotatedRow(i) - rotatedRowS(i);
	dCol(i) = rotatedCol(i) - rotatedColS(i);
end


figure(4);
scatter(prfRaOffset(:)*3600, prfDecOffset(:)*3600);

figure(5);
scatter(prfRa(:), prfDec(:));

figure(6);
scatter(prfRelativeRaOffset(:)*3600, prfRelativeDecOffset(:)*3600);

figure(7);
scatter(prfRelativeRa(:), prfRelativeDec(:));

% fid = fopen('delta_quaternion.txt', 'w');
% fprintf(fid, '%6.20e %6.20e %6.20e %6.20e\n', deltaQuaternion');
% fclose(fid);
%     
% save prfOffsetPattern.mat prfOffsetRow prfOffsetCol baseRa baseDec baseRoll ...
%     prfRa prfDec prfRoll prfRaOffset prfDecOffset prfRollOffset deltaQuaternion ...
%     prfRelativeRa prfRelativeDec prfRelativeRaOffset prfRelativeDecOffset startDate ...
%     deltaQuaternion
