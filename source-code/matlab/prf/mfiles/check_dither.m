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
load prfOffsetPattern.mat prfOffsetCol prfOffsetRow deltaQuaternion prfRelativeRaOffset prfRelativeDecOffset startDate

nDithers = length(prfOffsetCol);

load prfInputStruct_m14o1_z1f2F4.mat

% now compute the ra and dec offsets for this pattern
% we do this by getting the nominal pointing vector for each cadence at which we
% take a dither.  Then we rotate that pointing vector via the above delta
% quaternions, giving an attitude for each dither.
raDec2PixModel = prfInputStruct.raDec2PixModel;
raDec2PixObject = raDec2PixClass(raDec2PixModel, 'one-based');
pointingObject = pointingClass(raDec2PixModel.pointingModel);

dateMjd = datestr2mjd(startDate);
% dateMjd = datestr2mjd('23 Feb 2009');
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
        row + prfOffsetRow(i), col + prfOffsetCol(i), dateMjd, 1);
	prfRelativeRaOffset1(i) = prfRelativeRa(i) - baseRa;
	prfRelativeDecOffset1(i) = prfRelativeDec(i) - baseDec;
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
    prfRa1(i) = offsetPointing(1);
    prfDec1(i) = offsetPointing(2);
    prfRoll1(i) = offsetPointing(3);
    
    prfRaOffset1(i) = prfRa1(i) - prfRa1(1);
    prfDecOffset1(i) = prfDec1(i) - prfDec1(1);
    prfRollOffset1(i) = prfRoll1(i) - prfRoll1(1);
end

targetStruct = prfInputStruct.targetStarsStruct(30);
ra = targetStruct.ra;
dec = targetStruct.dec;
[m o rowRelative colRelative] = ra_dec_2_pix_relative(raDec2PixObject, ra, dec, ...
    endTimestamps, prfRelativeRaOffset1, prfRelativeDecOffset1, 0);

[m o rowPrfRelative colPrfRelative] = ra_dec_2_pix_relative(raDec2PixObject, ra, dec, ...
    endTimestamps, prfRelativeRaOffset, prfRelativeDecOffset, 0);

[m o rowAbsolute colAbsolute] = ra_dec_2_pix_absolute(raDec2PixObject, ra, dec, ...
    endTimestamps, prfRa1, prfDec1, prfRoll1);

[m o rowPrfAbsolute colPrfAbsolute] = ra_dec_2_pix_absolute(raDec2PixObject, ra, dec, ...
    endTimestamps, ...
    prfInputStruct.spacecraftAttitudeStruct.ra.values, ...
    prfInputStruct.spacecraftAttitudeStruct.dec.values, ...
    prfInputStruct.spacecraftAttitudeStruct.roll.values);
%%

figure
for i=1:length(rowRelative)
    plot(rowRelative(1:i), colRelative(1:i), 'r+', rowAbsolute(1:i), colAbsolute(1:i), 'go', ...
        rowPrfRelative(1:i), colPrfRelative(1:i), 'bd', rowPrfAbsolute(1:i), colPrfAbsolute(1:i), 'mx');
    legend('relative from ra_dec_2_pix', 'absolute from quaternions', ...
        'relative from dither file', 'absolute from attitude struct');
    pause;
end
