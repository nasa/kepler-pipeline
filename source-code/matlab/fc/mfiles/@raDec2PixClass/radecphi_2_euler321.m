function [rot321] = radecphi_2_euler321(raDec2PixObject, raDecPhiPointing, mjds)
% [rot321] = radecphi_2_euler321(raDec2PixObject, raDecPhiPointing, mjds)
% Returns the 3-2-1 Euler angles in absolute space corresponding to the (ra,dec,phi) input to ra_dec_2_pix_absolute
% representing the photometer attitude. rot321 = [rot3, rot2, rot1],
% corresponding to rotations about the z-axis (3), y-axis (2), and x-axis
% (1), respectively.
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

rollPointing = raDecPhiPointing(3);

raPointing = raDecPhiPointing(1);

decPointing = raDecPhiPointing(2);

drot1 = rollPointing; % nomenclature in ra_dec_2_pix from borrowed code

rot3 = raPointing; % ra is the same as rot3

rot2 = -decPointing; % dec is defined in the opposite sense of the standard rotation about axis 2 (or the y-axis)

% get season int and roll offset
rollTimeModel = get(raDec2PixObject, 'rollTimeModel');
rollTimeObject = rollTimeClass(rollTimeModel);
rollTimeData = get_roll_time(rollTimeObject, mjds);
rollOffset = rollTimeData(:, 2);
seasonInt = rollTimeData(:, 3);

% compute the roll angle
rot1 = raDec2PixObject.NOMINAL_CLOCKING_ANGLE + rollOffset + seasonInt * 90.0;

if isequal( size(rot1), size(drot1) ) % same size
    rot1 = rot1 + drot1;  % add optional offset in X'-axis rotation
elseif isequal( size(rot1'), size(drot1) ) % same size, transposed
    rot1 = rot1' + drot1;
else
    error('MATLAB:@raDec2PixClass:get_rot1_angle %s %d %d %d %d', 'size error in rot1', size(rot1, 1), size(rot1, 2), size(drot1, 1), size(drot1, 2));
end

rot1 = rot1 + 180; % Need to account for 180 deg rotation of field due to imaging of mirror

rot1 = rem(rot1, 360); % make small if rot1 < -360 or rot1 > 360

% populate the return vector with the 3-2-1 Euler angles
rot321 = [rot3, rot2, rot1];

return
