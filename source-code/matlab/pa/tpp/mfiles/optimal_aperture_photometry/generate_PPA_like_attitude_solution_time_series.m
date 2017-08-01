function [ra0s2, dec0s2, phi0s2, Catt] = generate_PPA_like_attitude_solution_time_series(JD)
%function [ra0s2, dec0s2, phi0s2, Catt] = generate_PPA_like_attitude_solution_time_series
%   JD0 = calcJDate(2009,1,1);
%   JD = JD0 + (1:372)';
%% test_attitude_track
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
season = 0;

% get "guide star" proxies
[raGuide,decGuide]=get_guidance_stars(season);
nGuide = length(raGuide);

% set up Julian Dates
nTime = length(JD);

%% get aberrated guide star positions at each time step
aberRaGuide = zeros(nTime, nGuide);
aberDecGuide = zeros(nTime, nGuide);


for j = 1:nGuide
    [aberRaGuide(:,j), aberDecGuide(:,j)] = aberrate_ra_dec(raGuide(j), decGuide(j), JD);
end

if size(aberRaGuide,1)~=nTime
    aberRaGuide = aberRaGuide';
    aberDecGuide = aberDecGuide';
end

% set up nominal boresight
ra0    = 15*(19 + (22 + 40/60)/60);     % FOV at RA 19h 22m 40s
dec0   = 44 + 30/60;                    % FOV Dec at 44d 30m 00s
phi0   = 0; % roll angle is nominally zero

season = JD(1);
%% aberrate ra0 and dec0 for first timestep
[aberRa0, aberDec0] = aberrate_ra_dec(ra0, dec0,season);

%% initialize some arrays
mod = zeros(nTime,nGuide);
out = mod;
row = mod;
col = mod;

ra0s = zeros(nTime,1);
dec0s = zeros(nTime,1);
phi0s = zeros(nTime,1);

ra0s(1)=ra0;
dec0s(1) = dec0;
phi0s(1) = phi0;

%% get pixel locations assuming that we point at the aberrated boresight
% (no clock angle adjustments)
%[aberRa0s, aberDec0s] = aberrate_ra_dec(repmat(ra0,size(JD'))', repmat(dec0,size(JD'))',JD);
[aberRa0s, aberDec0s] = aberrate_ra_dec(ra0, dec0,JD);
aberRa0s = aberRa0s(1,:)';
aberDec0s = aberDec0s(1,:)';
%%
% for i = 1:nTime
% %    [mod,out,rowNoClock(i,:),colNoClock(i,:)] = RaDec2Pix(aberRaGuide(i,:),aberDecGuide(i,:),0,aberRa0s(i),aberDec0s(i),0);
%     [mod,out,rowNoClock(i,:),colNoClock(i,:)] = RaDec2Pix(aberRaGuide(i,:),aberDecGuide(i,:),season,aberRa0s(i),aberDec0s(i),0);
% end
% 
%% get pixel locations assuming no change in pointing
[mod,out,row,col] = RaDec2Pix(aberRaGuide,aberDecGuide,season,aberRa0,aberDec0,phi0);
mod = reshape(mod,nTime,nGuide);
out = reshape(out,nTime,nGuide);
row = reshape(row,nTime,nGuide);
col = reshape(col,nTime,nGuide);

%% solve for attitude for each timestep
h = waitbar(1/nTime, 'Progress');

Catt = zeros(3,3,nTime);


for i = 1:nTime
    [ra0s(i), dec0s(i), phi0s(i), attitudeError(i), rowNew(i,:), colNew(i,:), Catt(:,:,i)] = ...
        solve_linear_attitude(aberRaGuide(i,:),aberDecGuide(i,:),row(1,:),col(1,:),aberRa0,aberDec0,phi0, season);
    waitbar(i/nTime)
end
close(h)

%% solve for attitude for each timestep, minimizing the difference from the
% last position
rowNew2 = rowNew;
colNew2 = colNew;
ra0s2 = ra0s;
dec0s2 = dec0s;
phi0s2 = phi0s;
attitudeError2 = attitudeError;
h = waitbar(1/nTime, 'Progress');
for i = 2:nTime
    [ra0s2(i), dec0s2(i), phi0s2(i), attitudeError2(i), rowNew2(i,:), colNew2(i,:), Catt(:,:,i)] = ...
        solve_linear_attitude(aberRaGuide(i,:),aberDecGuide(i,:),rowNew(i-1,:),colNew(i-1,:),aberRa0,aberDec0,phi0, season);
    waitbar(i/nTime)
end
close(h)

return;






%%
figure(1)
plot(detrendcols(row(:,1)),detrendcols(col(:,1)),'b',detrendcols(rowNoClock(:,1)),detrendcols(colNoClock(:,1)),'g',...
    detrendcols(rowNew(:,1)),detrendcols(colNew(:,1)),'r','linewidth',1.5)
hold on
legend('Tracking Inertial Boresight','Tracking Aberrated Boresight','Tracking Aberrated Boresight and Clock Angle',0)
plot(detrendcols(row),detrendcols(col),'b',detrendcols(rowNoClock),detrendcols(colNoClock),'g',...
    detrendcols(rowNew),detrendcols(colNew),'r','linewidth',1.5)
xlabel('Relative Column, Pixels','fontsize',13)
ylabel('Relative Row, Pixels','fontsize',13)
hold off
print -dtiff attitudeTracksOnPixels.tif
%%
%% solve for attitude for each timestep minus one FGS (number 4)
h = waitbar(1/nTime, 'Progress');
for i = 1:nTime
    [ra0s_4(i), dec0s_4(i), phi0s_4(i), attitudeError_4(i), rowNew_4(i,1:3), colNew_4(i,1:3)] = ...
        solve_linear_attitude(aberRaGuide(i,1:3),aberDecGuide(i,1:3),row(1,1:3),col(1,1:3),aberRa0,aberDec0,phi0, season);
    % get positions for missing output(s)
    [mod,out,rowNew_4(i,4),colNew_4(i,4)] = RaDec2Pix(aberRaGuide(i,4),aberDecGuide(i,4),season,ra0s_4(i),dec0s_4(i),phi0s_4(i));
    waitbar(i/nTime)
end
close(h)

%%

%% solve for attitude for each timestep minus two FGS (number 3&4)
h = waitbar(1/nTime, 'Progress');
for i = 1:nTime
    [ra0s_34(i), dec0s_34(i), phi0s_34(i), attitudeError_34(i), rowNew_34(i,1:2), colNew_34(i,1:2)] = ...
        solve_linear_attitude(aberRaGuide(i,1:2),aberDecGuide(i,1:2),row(1,1:2),col(1,1:2),aberRa0,aberDec0,phi0, season);
    % get positions for missing output(s)
    [mod,out,rowNew_34(i,3:4),colNew_34(i,3:4)] = RaDec2Pix(aberRaGuide(i,3:4),aberDecGuide(i,3:4),season,ra0s_34(i),dec0s_34(i),phi0s_34(i));
    waitbar(i/nTime)
end
close(h)
%%
%% solve for attitude for each timestep minus two FGS (number 2&4)
h = waitbar(1/nTime, 'Progress');
for i = 1:nTime
    [ra0s_24(i), dec0s_24(i), phi0s_24(i), attitudeError_24(i), rowNew_24(i,[1,3]), colNew_24(i,[1,3])] = ...
        solve_linear_attitude(aberRaGuide(i,[1,3]),aberDecGuide(i,[1,3]),row(1,[1,3]),col(1,[1,3]),aberRa0,aberDec0,phi0, season);
    % get positions for missing output(s)
    [mod,out,rowNew_24(i,[2,4]),colNew_24(i,[2,4])] = RaDec2Pix(aberRaGuide(i,[2,4]),aberDecGuide(i,[2,4]),season,ra0s_24(i),dec0s_24(i),phi0s_24(i));
    waitbar(i/nTime)
end
close(h)
%%
%% solve for attitude for each timestep minus three FGS (number 2, 3, &4)
h = waitbar(1/nTime, 'Progress');
for i = 1:nTime
    [ra0s_234(i), dec0s_234(i), phi0s_234(i), attitudeError_234(i), rowNew_234(i,[1]), colNew_234(i,[1])] = ...
        solve_linear_attitude(aberRaGuide(i,[1]),aberDecGuide(i,[1]),row(1,[1]),col(1,[1]),aberRa0,aberDec0,phi0, season);
    % get positions for missing output(s)
    [mod,out,rowNew_234(i,[2:4]),colNew_234(i,[2:4])] = RaDec2Pix(aberRaGuide(i,[2:4]),aberDecGuide(i,[2:4]),season,ra0s_234(i),dec0s_234(i),phi0s_234(i));
    waitbar(i/nTime)
end
close(h)
%%
figure(2)
plot(detrendcols(rowNew(:,1)),detrendcols(colNew(:,1)),'k',detrendcols(rowNew_4(:,1)),detrendcols(colNew_4(:,1)),'b',detrendcols(rowNew_24(:,1)),detrendcols(colNew_24(:,1)),'g',detrendcols(rowNew_34(:,1)),detrendcols(colNew_34(:,1)),'r',detrendcols(rowNew_234(:,1)),detrendcols(colNew_234(:,1)),'m','linewidth',2)
legend('All FGS','All But 4','1 & 2','1 & 3','Only 1')
hold on
plot(detrendcols(rowNew),detrendcols(colNew),'k',detrendcols(rowNew_4),detrendcols(colNew_4),'b',detrendcols(rowNew_24),detrendcols(colNew_24),'g',detrendcols(rowNew_34),detrendcols(colNew_34),'r',detrendcols(rowNew_234),detrendcols(colNew_234),'m','linewidth',2),grid
hold off
print -dtiff MissingFGS.tif
%%
keyboard
return


function [ra0,dec0,phi0, attitudeError, row, col, Catt] = solve_linear_attitude(aberRa, aberDec, row0, col0, ra0, dec0, phi0,season)

tol = 1e-10;

% ensure inputs are column vectors
aberRa = aberRa(:);
aberDec = aberDec(:);
row0 = row0(:);
col0 = col0(:);

% measure initial attitude error
[mm,oo,row,col] = RaDec2Pix(aberRa,aberDec,season,ra0,dec0,phi0);

attitudeError = sqrt(mean((row-row0).^2+(col-col0).^2));

count = 1;
maxCount = 100;

while count==1||(count<maxCount&&(attitudeError(count-1)-attitudeError(count)>tol))
    count = count + 1;
    [ra0, dec0, phi0,attitudeError(count), row, col, Catt] = iterate_linear_attitude(aberRa,aberDec, row0, col0, ra0, dec0, phi0, season);
end

attitudeError = attitudeError(end);

row = row';
col = col';

return


function [ra0, dec0, phi0, attitudeError, rowNew, colNew, Catt] = iterate_linear_attitude(aberRa, aberDec, row0, col0, ra0, dec0, phi0, season)

% set up offsets in ra, dec and phi
deltaRa = 1/3600; % 1 arcsec
deltaDec = 1/3600; 
deltaPhi = 1/3600;

% get initial pixel positions of stars in this frame
[mm,oo,row,col] = RaDec2Pix(aberRa,aberDec,season,ra0,dec0,phi0);

% get positions for offsets in each attitude element
[mm,oo,rowdRa,coldRa] = RaDec2Pix(aberRa,aberDec,season,ra0+deltaRa,dec0,phi0);

[mm,oo,rowdDec,coldDec] = RaDec2Pix(aberRa,aberDec,season,ra0,dec0+deltaDec,phi0);

[mm,oo,rowdPhi,coldPhi] = RaDec2Pix(aberRa,aberDec,season,ra0,dec0,phi0+deltaPhi);

% form coefficients of linearized attitude

% terms in the Jacobian
cRa = (coldRa-col)/deltaRa;
cDec = (coldDec-col)/deltaDec;
cPhi = (coldPhi-col)/deltaPhi;

dRa = (rowdRa-row)/deltaRa;
dDec = (rowdDec-row)/deltaDec;
dPhi = (rowdPhi-row)/deltaPhi;

% set up design matrix A, and residual data array b
A = [cRa,cDec,cPhi;dRa,dDec,dPhi];
b = [col0-col;row0-row];


% this will be done correctly in PDQ (where a number of centroid feed into
% attitude solution) 
% the following idea is a proxy for what would actually be done.

% normalize A appropriately - each row of A must be normalized by the
% uncertainties in the centroid component for that time step

% do that to b as well


% To approximate sigmaRowCol (approximately)+ FWHM/(2*SNR)
% where FWHM = full width half max, SNR = signal to noise ratio of the flux
% in the aperture
% Each FGS has ~25 stars 
% sigmaRowCol = (FWHM/(2*SNR))*(1/sqrt(nstars))
% FWHM = 1.5 pixels  for a 12th magnitude star
% 1/SNR = 20 ppm for a 12th magnitude star over 6.5 hours


sigmaRowCol = ((1.5*sqrt(13)*20*1e-6)/2)*(1/sqrt(250)); % attitude solution from PPA stars available ~ 100,000

biasRowCol = (0.1/sqrt(250)); % per star basis, correlated over time

totalSigmaRowCol = sqrt(sigmaRowCol.^2+biasRowCol.^2);


% 12th magnitude stars ~ 250




%lam = A\b; % solution to linearized attitude problem


% uncertainty weighted linearized design matrix
% Each row of A must be normalized by the uncertainty in the centroid
% component (row or column as the case may be) for that time step


A = scalecol(repmat(1/totalSigmaRowCol, size(A,1),1), A); 
b = scalecol(repmat(1/totalSigmaRowCol, size(A,1),1), b);
lam = A\b;

Catt = inv(A'*A);



ra0 = ra0 + lam(1);
dec0 = dec0 + lam(2);
phi0 = phi0 + lam(3);

[mm,oo,rowNew,colNew] = RaDec2Pix(aberRa,aberDec, season, ra0, dec0, phi0);

attitudeError = sqrt(mean(sum((row0-rowNew).^2+(col0-colNew).^2)));

return
%%================================================================
function [JD] = calcJDate(year,month,day)

flag=0;
if (year > 1582)
  flag=1;
elseif (year == 1582)
  if (month > 10)
    flag=1;
  elseif ((month == 10) & (day >= 15))
    flag=1;
  end
end

if (month==1 | month==2),
  year=year-1;
  month=month+12;
end

if (flag)
  A=floor(year/100);
  B=2-A+floor(A/4);
else
  A=floor(year/100);
  B=0;
end

if (year < 0)
  C=floor((365.25*year)-0.75);
else
  C=floor(365.25*year);
end

D=floor(30.6001*(month+1));

JD=B+C+D+day+1720994.5;


