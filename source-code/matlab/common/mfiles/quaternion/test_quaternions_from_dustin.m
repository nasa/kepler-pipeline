function test_quaternions_from_dustin(boresightRaDecPhi)
% Tests quaternions from Dustin to ensure that we are on the same page as
% the ADCS team.
%
% Note that Dustin's assumed plate scale is a little different from ours.
%
% -----------------------from Dustin Putnam------------------------------------------------------------------------------
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

%clear classes;
clc

if nargin==0
    boresightRaDecPhi = [290.66, 44.5, 0]; % for simplicity
end

%% Load raDec2PixModel
if ~ispc&&~ismac
    raDec2PixModel = retrieve_ra_dec_2_pix_model();
else
    load raDec2PixModelAll
end


dvaFlag = 0; % aberration is unimportant for this test


raDec2PixObject = raDec2PixClass(raDec2PixModel, 'one-based');


dateMjdsInEachQuarter = raDec2PixModel.rollTimeModel.mjds + 10;
 
dateMjd = dateMjdsInEachQuarter(1); % just need one timetag

%clc;
format compact


% calculate boresight Euler angles
boresightRot321 = radecphi_2_euler321(raDec2PixObject, boresightRaDecPhi, dateMjd);

%% generate sample "stars" on mod/outs with same orientation as module 21

centerMods = [2:4,7:8,18:19,22:24]';
centerOuts = [1,1,1,1,1,3,3,3,3,3]';
centerRows = repmat(500,size(centerMods));
centerCols = centerRows;    

nstars = length(centerCols);

%% Set up ra/dec for each "star" and anonymous functions to allow us to
%% investigate the match between our quaternion code base, ra_dec_2_pix,
%% and Dustin's results

[centerRas, centerDecs] = pix_2_ra_dec_absolute(raDec2PixObject, centerMods, centerOuts, centerRows, centerCols, dateMjd, boresightRaDecPhi(1), boresightRaDecPhi(2), boresightRaDecPhi(3), dvaFlag);

Qboresight = radecphi_to_quaternion(boresightRaDecPhi, dateMjd, raDec2PixObject);

rowColFcn = @(x) getels(stuff_ra_dec_2_pix_absolute(raDec2PixObject, centerRas , centerDecs, dateMjd, ...
    boresightRaDecPhi(1) + x(1), boresightRaDecPhi(2) + x(2), boresightRaDecPhi(3)+x(3), dvaFlag),':,3:4');

rowColDiffFcn = @(x) rowColFcn(x) - [centerRows(:),centerCols(:)];

%% find deltaRaDecPhi to move stars 1.5 pix along rows (Dustin's first
%% quaternion
fminsearchOptions = optimset('tolX',1e-6,'tolFun',1e-6);

scaleFactor = 1.0417; % Dustin's platescale is 4.17% smaller than raDec2Pix thinks it is

rowMotionFcn = @(x) sum(sum((rowColDiffFcn(x) - repmat([-1.5,0]/scaleFactor, nstars, 1)).^2));

deltaRaDecPhiForRowMotion = fminsearch(@(x)rowMotionFcn(x),3600\[0,3.98,0],fminsearchOptions);

%% Convert to a delta quaternion

raDecPhiForRowMotion = boresightRaDecPhi + deltaRaDecPhiForRowMotion;

QrowMotion = radecphi_to_quaternion(raDecPhiForRowMotion, dateMjd, raDec2PixObject);

deltaQrowMotion = quaternion_product(quaternion_conjugate(Qboresight), QrowMotion);

rowColDiffForRowMotion = rowColDiffFcn(deltaRaDecPhiForRowMotion);

%% start with Dustin's deltaQ for row motion
dustinsDeltaQforRowMotion = [0,0,1.396263e-5, sqrt(1-1.396263e-5^2)];
dustinsQforRowMotion = quaternion_product(Qboresight, dustinsDeltaQforRowMotion);
dustinsRaDecPhiForRowMotion = quaternion_to_radecphi(dustinsQforRowMotion, dateMjd, raDec2PixObject);
dustinsDeltaRaDecPhiForRowMotion = dustinsRaDecPhiForRowMotion - boresightRaDecPhi;
dustinsRowColDiffForRowMotion = rowColDiffFcn(dustinsDeltaRaDecPhiForRowMotion);

%% compare to Dustin's numbers
% Rotation 	   Dquat(1)         Dquat(2)        Dquat(3)        Dquat(4)        Row Shift	Column Shift	  Note
% +Z-axis		0               0               1.396263e-5     0.99999999      -3          0               Cross-boresight
disp('Validating Quaternions...')
disp(' ')
disp('Z-axis Rotation        Dquat(1)        Dquat(2)        Dquat(3)        Dquat(4)       Row Shift    Column Shift        Note')
disp(sprintf('Dustin''s Numbers:%14.6e%16.6e%16.6e%16.6e%16.6e%16.6e   Cross-boresight',[0, 0, 1.396263e-5, 0.99999999, -3/2, 0]))
disp(sprintf('Our numbers:     %14.6e%16.6e%16.6e%16.6e%16.6e%16.6e   Cross-boresight',[deltaQrowMotion', mean(rowColDiffForRowMotion(:,1))*scaleFactor, scaleFactor*mean(rowColDiffForRowMotion(:,2))]))
disp(' ')
disp('Motion for our delta quaterion')
disp('mod    out  delta row   delta col')
disp(sprintf('%3i %5i %10.4f %10.4f \n',[centerMods, centerOuts, scaleFactor*rowColDiffForRowMotion]'))
disp('Motion for Dustin''s delta quaterion')
disp('mod    out  delta row   delta col')
disp(sprintf('%3i %5i %10.4f %10.4f \n',[centerMods, centerOuts, scaleFactor*dustinsRowColDiffForRowMotion]'))

%%
Zdiffs = rowColDiffFcn(deltaRaDecPhiForRowMotion);
figure(1)

quiver(centerRas, centerDecs, Zdiffs(:,2), Zdiffs(:,1))   
set(gca,'xdir','reverse')
title('Rotation about Z''')
xlabel('Ra, degrees; change in row')
ylabel('Dec, degrees; change in col')

%% find deltaRaDecPhi to move stars 1.5 pix along cols

colMotionFcn = @(x) sum(sum((rowColDiffFcn(x) - repmat([0,1.5]/scaleFactor, nstars, 1)).^2));

deltaRaDecPhiForColMotion = fminsearch(@(x)colMotionFcn(x),3600\[0,3.98,0],fminsearchOptions);

% Convert to a delta quaternion

raDecPhiForColMotion = boresightRaDecPhi + deltaRaDecPhiForColMotion;

QcolMotion = radecphi_to_quaternion(raDecPhiForColMotion, dateMjd, raDec2PixObject);

deltaQcolMotion = quaternion_product(quaternion_conjugate(Qboresight), QcolMotion);

rowColDiffForColMotion = rowColDiffFcn(deltaRaDecPhiForColMotion);

%% start with Dustin's deltaQ for col motion
dustinsDeltaQforColMotion = [0, 1.396263e-5, 0, sqrt(1-1.396263e-5^2)];
dustinsQforColMotion = quaternion_product(Qboresight, dustinsDeltaQforColMotion);
dustinsRaDecPhiForColMotion = quaternion_to_radecphi(dustinsQforColMotion, dateMjd, raDec2PixObject);
dustinsDeltaRaDecPhiForColMotion = dustinsRaDecPhiForColMotion - boresightRaDecPhi;
dustinsRowColDiffForColMotion = rowColDiffFcn(dustinsDeltaRaDecPhiForColMotion);


%% compare to Dustin's numbers
% Rotation 	   Dquat(1)         Dquat(2)        Dquat(3)        Dquat(4)        Row Shift 	Column Shift       Note
% +Y-axis		0               1.396263e-5     0               0.99999999       0          3               Cross-boresight
disp(' ')
disp('Y-axis Rotation        Dquat(1)        Dquat(2)        Dquat(3)        Dquat(4)       Row Shift    Column Shift       Note')
disp(sprintf('Dustin''s Numbers:%14.6e%16.6e%16.6e%16.6e%16.6e%16.6e   Cross-boresight',[0, 1.396263e-5, 0, 0.99999999, 0, 3/2]))
disp(sprintf('Our numbers:     %14.6e%16.6e%16.6e%16.6e%16.6e%16.6e',[deltaQcolMotion', mean(rowColDiffForColMotion(:,1))*scaleFactor, scaleFactor*mean(rowColDiffForColMotion(:,2))]))
disp(' ')
disp('mod    out  delta row   delta col')
disp(sprintf('%3i %5i %10.4f %10.4f \n',[centerMods, centerOuts, scaleFactor*rowColDiffForColMotion]'))
disp(' ')
disp('Motion for our delta quaterion')
disp('mod    out  delta row   delta col')
disp(sprintf('%3i %5i %10.4f %10.4f \n',[centerMods, centerOuts, scaleFactor*rowColDiffForColMotion]'))
disp('Motion for Dustin''s delta quaterion')
disp('mod    out  delta row   delta col')
disp(sprintf('%3i %5i %10.4f %10.4f \n',[centerMods, centerOuts, scaleFactor*dustinsRowColDiffForColMotion]'))
%%
Ydiffs = rowColDiffFcn(deltaRaDecPhiForColMotion);
figure(2)

quiver(centerRas, centerDecs, -Ydiffs(:,2), Ydiffs(:,1))   
set(gca,'xdir','reverse')
title('Rotation about Y''')
xlabel('Ra, degrees; change in row')
ylabel('Dec, degrees; change in col')

%% Rotate about the X' axis (FPA frame)
rotAngle = asin(1.396263e-4)*2*rad2deg;
deltaQZ = [sin(deg2rad*rotAngle/2)*[1, 0, 0],cos(deg2rad*rotAngle/2)]';
QnewZ = quaternion_product(Qboresight, deltaQZ);
deltaRaDecPhiForZrot = quaternion_to_radecphi(QnewZ, dateMjd, raDec2PixObject) - boresightRaDecPhi;
rowColDiffForZrot = rowColDiffFcn(deltaRaDecPhiForZrot);

%% compare to Dustin's numbers
% Rotation 	   Dquat(1)         Dquat(2)        Dquat(3)        Dquat(4)        Row Shift 	Column Shift       Note
% +X-axis		1.396263e-4     0               0               0.99999999      -2          3               About boresight
iiMod22 = find(centerMods == 22);

% scale mod 22 out 3 for distance from center of FOV compared to Mod 21
distRatio = 60/58; % eye-balled with ruler from picture of FPA
disp(' ')
disp('X-axis Rotation        Dquat(1)        Dquat(2)        Dquat(3)        Dquat(4)       Row Shift    Column Shift       Note')
disp(sprintf('Dustin''s Numbers:%14.6e%16.6e%16.6e%16.6e%16.6e%16.6e   About boresight',[1.396263e-4, 0, 0, 0.99999999, -2/2, 3/2]))
disp(sprintf('Our numbers:     %14.6e%16.6e%16.6e%16.6e%16.6e%16.6e   About boresight',[deltaQZ', rowColDiffForZrot(iiMod22,1)*scaleFactor*distRatio, distRatio*scaleFactor*rowColDiffForZrot(iiMod22,2)]))
disp('Note that there is a small difference in angle from mod/out 22/3 and the center of the FOV relative to mod 21!')

%%
Xdiffs = rowColDiffForZrot;
figure(3)

quiver(centerRas, centerDecs, Xdiffs(:,2), -Xdiffs(:,1))   
text(centerRas,centerDecs,int2str(centerMods))
set(gca,'xdir','reverse')
title('Rotation about Boresight')
xlabel('Ra, degrees; change in row')
ylabel('Dec, degrees; change in col')
    
%%

return

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



    

%%
return

function morc = stuff_ra_dec_2_pix_absolute(varargin)

[mm, oo, rr, cc] = ra_dec_2_pix_absolute(varargin{:});

morc = [mm,oo,rr,cc];

return

