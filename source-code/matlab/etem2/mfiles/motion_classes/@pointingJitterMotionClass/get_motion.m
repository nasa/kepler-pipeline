function [rowMotion, colMotion] = get_motion(pointingJitterMotionObject, ...
    row, column, time, ccdObject)
% input time is in days
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

runParamsObject = pointingJitterMotionObject.runParamsClass;
raDec2PixObject = get(runParamsObject, 'raDec2PixObject');
module = get(runParamsObject, 'moduleNumber');
output = get(runParamsObject, 'outputNumber');
startTime = get(runParamsObject, 'runStartTime');

% make a 0-based time vector, convert to seconds
timeVector = (time - time(1))*24*3600;

jitterFrequency = pointingJitterMotionObject.sampleFrequency;

deltaMult = 3; % use delta of 3*standard deviation for each direction
% RA-jitter
load(pointingJitterMotionObject.jitterFilename, 'jitterRa', 'jitterTimes');
raMotion = interp1(jitterTimes, jitterRa, timeVector, 'linear', 0);
clear jitterRa;
raStd = std(raMotion);
deltaRa = deltaMult*raStd;

% dec-jitter
load(pointingJitterMotionObject.jitterFilename, 'jitterDec');
decMotion = interp1(jitterTimes, jitterDec, timeVector, 'linear', 0);
clear jitterDec;
decStd = std(decMotion);
deltaDec = deltaMult*decStd;

% phi-jitter
load(pointingJitterMotionObject.jitterFilename, 'jitterPhi');
phiMotion = interp1(jitterTimes, jitterPhi, timeVector, 'linear', 0);
clear jitterPhi;
phiStd = std(phiMotion);
deltaPhi = deltaMult*phiStd;

% build a linearized depedence of row, column motion on pointing offsets
% use centered derivatives.  
% use a 3x3x3 stencil with the corners missing

% build vectors in RA, dec, phi     space
% index   direction     RA          dec         phi
% --------------------------------------------------
% 1       none          0           0           0
% 2       RA+1          deltaRa     0           0
% 3       RA-1          -deltaRa    0           0
% 4       dec+1         0           deltaDec    0
% 5       dec-1         0           -deltaDec   0
% 6       phi+1         0           0           deltaPhi
% 7       phi-1         0           0           -deltaPhi
% 8       RA+1, dec+1   deltaRa     deltaDec    0
% 9       RA+1, dec-1   deltaRa     -deltaDec   0
% 10      RA+1, phi+1   deltaRa     0           deltaPhi
% 11      RA+1, phi-1   deltaRa     0           -deltaPhi
% 12      RA-1, dec+1   -deltaRa    deltaDec    0
% 13      RA-1, dec-1   -deltaRa    -deltaDec   0
% 14      RA-1, phi+1   -deltaRa    0           deltaPhi
% 15      RA-1, phi-1   -deltaRa    0           -deltaPhi
% 16      dec+1, phi+1  0           deltaDec    deltaPhi
% 17      dec+1, phi-1  0           deltaDec    -deltaPhi
% 18      dec-1, phi+1  0           -deltaDec   deltaPhi
% 19      dec-1, phi-1  0           -deltaDec   -deltaPhi

% define some helpful index names
Ra0_Dec0_Phi0 = 1;
Rap1_Dec0_Phi0 = 2;
Ram1_Dec0_Phi0 = 3;
Ra0_Decp1_Phi0 = 4;
Ra0_Decm1_Phi0 = 5;
Ra0_Dec0_Phip1 = 6;
Ra0_Dec0_Phim1 = 7;
Rap1_Decp1_Phi0 = 8;
Rap1_Decm1_Phi0 = 9;
Rap1_Dec0_Phip1 = 10;
Rap1_Dec0_Phim1 = 11;
Ram1_Decp1_Phi0 = 12;
Ram1_Decm1_Phi0 = 13;
Ram1_Dec0_Phip1 = 14;
Ram1_Dec0_Phim1 = 15;
Ra0_Decp1_Phim1 = 16;
Ra0_Decp1_Phip1 = 17;
Ra0_Decm1_Phip1 = 18;
Ra0_Decm1_Phim1 = 19;

raOffset = [0 deltaRa -deltaRa 0 0 0 0 deltaRa deltaRa deltaRa deltaRa ...
    -deltaRa -deltaRa -deltaRa -deltaRa 0 0 0 0];
decOffset = [0 0 0 deltaDec -deltaDec 0 0 deltaDec -deltaDec 0 0 deltaDec ...
    -deltaDec 0 0 deltaDec -deltaDec deltaDec -deltaDec];
phiOffset = [0 0 0 0 0 deltaPhi -deltaPhi 0 0 deltaPhi -deltaPhi 0 0 ...
    deltaPhi -deltaPhi deltaPhi -deltaPhi deltaPhi -deltaPhi];

% first get RA and dec of this row, column
[ra0, dec0] = pix_to_ra_dec(raDec2PixObject, module, output, row, column, startTime, 1);
% get the pixel positions for all the offsets
%
% until we get the args to ra_dec_2_pix straightened out...
% [m, o, rowOffset, colOffset] = ra_dec_to_pix(raDec2PixObject, ra0, dec0, ...
%     startTime, 1, raOffset, decOffset, phiOffset);
for i=1:length(raOffset)
	[m, o, rowOffset(i), colOffset(i)] = ra_dec_to_pix(raDec2PixObject, ra0, dec0, ...
    	startTime, 1, raOffset(i), decOffset(i), phiOffset(i));
end

% first derivatives via central difference
DrowDra = (rowOffset(Rap1_Dec0_Phi0) - rowOffset(Ram1_Dec0_Phi0))/(2*deltaRa);
DcolDra = (colOffset(Rap1_Dec0_Phi0) - colOffset(Ram1_Dec0_Phi0))/(2*deltaRa);
DrowDdec = (rowOffset(Ra0_Decp1_Phi0) - rowOffset(Ra0_Decm1_Phi0))/(2*deltaDec);
DcolDdec = (colOffset(Ra0_Decp1_Phi0) - colOffset(Ra0_Decm1_Phi0))/(2*deltaDec);
DrowDphi = (rowOffset(Ra0_Dec0_Phip1) - rowOffset(Ra0_Dec0_Phim1))/(2*deltaPhi);
DcolDphi = (colOffset(Ra0_Dec0_Phip1) - colOffset(Ra0_Dec0_Phim1))/(2*deltaPhi);

% second derivative
D2rowDra2 = (rowOffset(Rap1_Dec0_Phi0) - 2*rowOffset(Ra0_Dec0_Phi0) + rowOffset(Ram1_Dec0_Phi0))/(deltaRa^2);
D2colDra2 = (colOffset(Rap1_Dec0_Phi0) - 2*colOffset(Ra0_Dec0_Phi0) + colOffset(Ram1_Dec0_Phi0))/(deltaRa^2);
D2rowDdec2 = (rowOffset(Ra0_Decp1_Phi0) - 2*rowOffset(Ra0_Dec0_Phi0) + rowOffset(Ra0_Decm1_Phi0))/(deltaDec^2);
D2colDdec2 = (colOffset(Ra0_Decp1_Phi0) - 2*colOffset(Ra0_Dec0_Phi0) + colOffset(Ra0_Decm1_Phi0))/(deltaDec^2);
D2rowDphi2 = (rowOffset(Ra0_Dec0_Phip1) - 2*rowOffset(Ra0_Dec0_Phi0) + rowOffset(Ra0_Dec0_Phim1))/(deltaPhi^2);
D2colDphi2 = (colOffset(Ra0_Dec0_Phip1) - 2*colOffset(Ra0_Dec0_Phi0) + colOffset(Ra0_Dec0_Phim1))/(deltaPhi^2);

% mixed partials, don't simplify for clarity
D2rowDraDdec = ( (rowOffset(Rap1_Decp1_Phi0) - rowOffset(Ram1_Decp1_Phi0))/(2*deltaRa) ...
    - (rowOffset(Rap1_Decm1_Phi0) - rowOffset(Ram1_Decm1_Phi0))/(2*deltaRa) )/(2*deltaDec);
D2colDraDdec = ( (colOffset(Rap1_Decp1_Phi0) - colOffset(Ram1_Decp1_Phi0))/(2*deltaRa) ...
    - (colOffset(Rap1_Decm1_Phi0) - colOffset(Ram1_Decm1_Phi0))/(2*deltaRa) )/(2*deltaDec);
D2rowDraDphi = ( (rowOffset(Rap1_Dec0_Phip1) - rowOffset(Ram1_Dec0_Phip1))/(2*deltaRa) ...
    - (rowOffset(Rap1_Dec0_Phim1) - rowOffset(Ram1_Dec0_Phim1))/(2*deltaRa) )/(2*deltaPhi);
D2colDraDphi = ( (colOffset(Rap1_Dec0_Phip1) - colOffset(Ram1_Dec0_Phip1))/(2*deltaRa) ...
    - (colOffset(Rap1_Dec0_Phim1) - colOffset(Ram1_Dec0_Phim1))/(2*deltaRa) )/(2*deltaPhi);
D2rowDdecDphi = ( (rowOffset(Ra0_Decp1_Phip1) - rowOffset(Ra0_Decm1_Phip1))/(2*deltaDec) ...
    - (rowOffset(Ra0_Decp1_Phim1) - rowOffset(Ra0_Decm1_Phim1))/(2*deltaDec) )/(2*deltaPhi);
D2colDdecDphi = ( (colOffset(Ra0_Decp1_Phip1) - colOffset(Ra0_Decm1_Phip1))/(2*deltaDec) ...
    - (colOffset(Ra0_Decp1_Phim1) - colOffset(Ra0_Decm1_Phim1))/(2*deltaDec) )/(2*deltaPhi);

% finally compute row motion using second derivative information
% rowMotion = raMotion*DrowDra + decMotion*DrowDdec + phiMotion*DrowDphi ...
% 	+ (raMotion.^2)*(D2rowDra2 + D2rowDdec2 + D2rowDphi2)/2;

% colMotion = raMotion*DcolDra + decMotion*DcolDdec + phiMotion*DcolDphi ...
% 	+ (raMotion.^2)*(D2colDra2 + D2colDdec2 + D2colDphi2)/2;

rowMotion = raMotion*DrowDra + decMotion*DrowDdec + phiMotion*DrowDphi ...
    + (raMotion.^2)*D2rowDra2/2 + (decMotion.^2)*D2rowDdec2/2 + (phiMotion.^2)*D2rowDphi2/2 ...
    + raMotion.*decMotion*D2rowDraDdec/2 + raMotion.*phiMotion*D2rowDraDphi/2 ...
    + decMotion.*phiMotion*D2rowDdecDphi/2;

colMotion = raMotion*DcolDra + decMotion*DcolDdec + phiMotion*DcolDphi ...
    + (raMotion.^2)*D2colDra2/2 + (decMotion.^2)*D2colDdec2/2 + (phiMotion.^2)*D2colDphi2/2 ...
    + raMotion.*decMotion*D2colDraDdec/2 + raMotion.*phiMotion*D2colDraDphi/2 ...
    + decMotion.*phiMotion*D2colDdecDphi/2;
% rowMotion = phiMotion*DrowDphi;
% colMotion = phiMotion*DcolDphi;
% rowMotion = raMotion*DrowDra + decMotion*DrowDdec;
% colMotion = raMotion*DcolDra + decMotion*DcolDdec;

filename = ...
    [get(pointingJitterMotionObject.runParamsClass, 'outputDirectory') filesep ...
    'jitterMotion.mat'];
save(filename);
