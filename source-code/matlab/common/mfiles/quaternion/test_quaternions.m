% % test_quaternions.m
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

clear classes;
clc;
if ~ispc&&~ismac
    raDec2PixModel = retrieve_ra_dec_2_pix_model();
else
    load raDec2PixModelAll;
end


% load raDec2PixModelAll
% useful if modifying these parameters before instantiating the object
% raDec2PixModel.NOMINAL_CLOCKING_ANGLE = 0;
% raDec2PixModel.NOMINAL_FOV_CENTER_DEGREES = [0 0 0];
% raDec2PixModel.NOMINAL_FIRST_ROLL = 0;


raDec2PixObject = raDec2PixClass(raDec2PixModel, 'one-based');

% startDateMjd = datestr2mjd('23-Feb-2009');
dateMjdsInEachQuarter = raDec2PixModel.rollTimeModel.mjds + 10;

clc;
format compact;
for j = 1:16

    fprintf('--------------------------------------------------------------\n');
    fprintf('Season = %d\n', j);
    fprintf('--------------------------------------------------------------\n');


    dateMjd = dateMjdsInEachQuarter(j);


    dvaFlag = 0;

    module = 18;
    output = 3;
    row = 500; % 1 pixel off from center of FOV
    col = 500;


    pointingObject = pointingClass(raDec2PixModel.pointingModel);

    boreSightRaDecPhi = get_pointing(pointingObject, dateMjd);

    [baseRa, baseDec] = pix_2_ra_dec_absolute(raDec2PixObject, module, output, row, col, dateMjd, boreSightRaDecPhi(1), boreSightRaDecPhi(2), boreSightRaDecPhi(3), dvaFlag);


    [mm, oo, row0, col0] = ...
        ra_dec_2_pix_absolute(raDec2PixObject, baseRa, baseDec, dateMjd, boreSightRaDecPhi(1), boreSightRaDecPhi(2), boreSightRaDecPhi(3), dvaFlag);


    boreSightRaDecPhi(3) = boreSightRaDecPhi(3) + raDec2PixModel.NOMINAL_CLOCKING_ANGLE;

    boreSightQuaternion = euler_angles_radecphi_to_quaternion(boreSightRaDecPhi);

    % this is just to verify that we get back the boreSightRaDecPhi
    [ra, dec, phi] = quaternion_to_euler_angles_radecphi(boreSightQuaternion);

    % -----------------------from Jon's email------------------------------------------------------------------------------
    % Here are some example quaternion and their impact on star motion on the
    % FGS CCDs. Generate delta quaternion in the photometer frame, which is the
    % frame the attitude control is conducted in (it will make it far simpler
    % to implement).
    %
    % The table below shows the delta quaternion elements, the shift in
    % location for a star on Module 21, which has row values aligned with the
    % +Y photometer axis and column values aligned with the +Z photometer axis.
    % Each quaternion is roughly a 6 arc-sec rotation about a single axis.
    %
    % Rotation 	   Dquat(1)         Dquat(2)        Dquat(3)        Dquat(4)        Row Shift 	Column Shift	Note
    % +Z-axis		0               0               1.396263e-5     0.99999999      -3          0               Cross-boresight
    % +Y-axis		0               1.396263e-5     0               0.99999999       0          3               Cross-boresight
    % +X-axis		1.396263e-4     0               0               0.99999999      -2          3               About boresight
    %
    %
    % The rotation about the X-axis is necessarily larger to produce about the
    % same star motion on the focal plane.
    %
    % Q1 = [0  0  1.396263e-5  0.99999999];
    % Q2 = [0  1.396263e-5  0  0.99999999];
    % Q3 = [1.396263e-4  0  0  0.99999999];
    %  ----------------------------------------------------------------------------------------------------------------------------------------------------------------------


    deltaPsi = 3.98/3600/rad2deg;
    deltaTheta = 0; %3.98/3600/rad2deg;
    deltaPhi = 0; %3.98*5/3600/rad2deg;

    deltaQZ = [0 0 sin(deltaPsi/2) cos(deltaPsi/2)];
    deltaQY = [0 sin(deltaTheta/2) 0 cos(deltaTheta/2)];
    deltaQX = [sin(deltaPhi/2) 0 0 cos(deltaPhi/2)];

    deltaQ1 = quaternion_product(deltaQZ, quaternion_product(deltaQY, deltaQX)); % should be the same as deltaQZ

    Q1 = quaternion_product( deltaQ1, boreSightQuaternion );

    [ra1, dec1, phi1] = quaternion_to_euler_angles_radecphi(Q1);



    newAttitude = [ra1 dec1 phi1];

    newAttitude(3)  = newAttitude(3) - raDec2PixModel.NOMINAL_CLOCKING_ANGLE;

    [mm, oo, row1, col1] = ...
        ra_dec_2_pix_absolute(raDec2PixObject, baseRa , baseDec, dateMjd, newAttitude(1), newAttitude(2), newAttitude(3), dvaFlag);


    % will add print statement later
    fprintf('initial row position = %f, new row position = %f, (new row - initial row) = %f\n\n', row0, row1, (row1 - row0));
    fprintf('initial col position = %f, new col position = %f, (new col - initial col) = %f\n\n', col0, col1, (col1 - col0));
    fprintf('distance moved = sqrt( (row1-row0)^2 +  (col1-col0)^2) = %f\n\n', sqrt( (row1-row0)^2 +  (col1-col0)^2));


end
return


