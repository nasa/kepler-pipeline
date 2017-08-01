function repair_prf_pattern()
% script to generate PRF dither pattern offsets
% load the source prfOffsetPattern.mat the needs repair
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
load prfOffsetPattern.mat
% # of points on a side for total pattern
nDithers = length(prfOffsetCol);

fcConstantsStruct = convert_fc_constants_java_2_struct();
plateScale = fcConstantsStruct.pixel2arcsec;
% compute the delta quaternions, treating the base RA and Dec as the actual
% roll etc., and the offset values as the desired roll etc.
deltaQuaternion = zeros(length(prfOffsetRow), 4);
for i=1:length(prfOffsetRow)
    deltaQuaternion(i,:) = ...
        old_delta_quaternion_from_row_column_motion(prfOffsetRow(i), prfOffsetCol(i), plateScale);
end

% now compute the ra and dec offsets for this pattern
% we do this by getting the nominal pointing vector for each cadence at which we
% take a dither.  Then we rotate that pointing vector via the above delta
% quaternions, giving an attitude for each dither.
raDec2PixModel = retrieve_ra_dec_2_pix_model();
raDec2PixObject = raDec2PixClass(raDec2PixModel, 'one-based');
pointingObject = pointingClass(raDec2PixModel.pointingModel);

startDate = '25 April 2009';
dateMjd = datestr2mjd(startDate);
timePerDither = 1/48; % days at 30 minutes per dither
for i=1:nDithers
    % set the data time to be the first 15 minutes of a dither period
     endTimestamps(i) = dateMjd + (i-0.5)*timePerDither; % end of 15 minutes of period
%      endTimestamps(i) = dateMjd; % end of 15 minutes of period
end
 % now compute the ra and dec offsets for this pattern
module = 13;
output = 1;
row = 1023; % 1 pixel off from center of FOV
col = 1099;

% get base pointing ra and dec
[baseRa, baseDec] = pix_2_ra_dec(raDec2PixObject, module, output, row, col, dateMjd, 1);

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
end

    
save repairedPrfOffsetPattern.mat prfOffsetRow prfOffsetCol baseRa baseDec baseRoll ...
    prfRa prfDec prfRoll prfRaOffset prfDecOffset prfRollOffset deltaQuaternion ...
    prfRelativeRa prfRelativeDec prfRelativeRaOffset prfRelativeDecOffset startDate ...
    deltaQuaternion


function deltaQuaternion = ...
    old_delta_quaternion_from_row_column_motion(deltaRow, deltaColumn, plateScale)
% function deltaQuaterion = 
%   make_delta_quaternion_from_row_column_motion(deltaRow, deltaColumn, plateScale)
% 
% Compute a delta quaternion when given a rotation in the spacecraft 
% frame in units of science rows and columns
% Row motion is a rotation about the spacecraft Y axis
% Column motion is a rotation about the spacecraft Z axis
% plateScale is the angular size of a pixel in arcseconds
% compute the angle of rotation in row and column directions in radians

pixToRadian = plateScale*pi/(180*3600);
rowAngle = deltaRow*pixToRadian;
colAngle = deltaColumn*pixToRadian; % minus to match coordinate system

% construct the quaternion as a concatination of rotations, doing the row
% rotation first.  The difference between this and doing the column
% rotation first is of the order 10^-11.

% row rotation = rotation about the Y axis
q1 = [0 sin(rowAngle/2) 0 cos(rowAngle/2)];
% column rotation = rotation about the Z axis
q2 = [0 0 sin(colAngle/2) cos(colAngle/2)];

deltaQuaternion = quaternion_product(q1, q2);
