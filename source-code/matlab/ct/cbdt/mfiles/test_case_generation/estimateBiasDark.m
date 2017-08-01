% estimateBiasDark - 
%   Displays bias (black) level, dark level, and uncertainty for three dark 
%   frames generated using generateDarkFrame.m
%   Written to demonstrate the Commissioning task to estimate the bias and
%   dark level from a series of (three) dark frames taken before cover
%   ejection.
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

% Uses default exposure times (seconds):
% (note: tReadOut ~0.51895 seconds of readout time is added to each exposure by
% generateDarkFrame.m)
t1 = 2.0;
t2 = 4.5;
t3 = 7.5;

% Default number of co-adds
numCoadds = 1;

% Default CCD parameters:
darkCurrent = 3.57;  % e- per pixel per second
readNoise = 25; % e- per pixel per read
gain = 88; % e-/ADU

% load CCD fomatting parameters (script sets parameter variables)
CCDFormatParams;

numSciencePix = scienceImRowSize*scienceImColSize;  % total number of science pixels
numSmearPix = maskSmearSize*scienceImColSize; % number masked smear pixels
numVSmearPix = virtualSmearSize*scienceImColSize; % # virtual smear pixels

%% generate three ffi's (single CCD output only)
ffi1 = generateDarkFrame(t1, numCoadds,darkCurrent,readNoise,gain);
ffi2 = generateDarkFrame(t2, numCoadds,darkCurrent,readNoise,gain);
ffi3 = generateDarkFrame(t3, numCoadds,darkCurrent,readNoise,gain);

% get mean and standard deviation of each each region for each dark frame
% Note: regions (A-E) are defined in Ball KEPLER.DFM.FPA.015
[mA1,mB1,mC1,mD1,mE1,sA1,sB1,sC1,sD1,sE1] = evalDarkFrame(ffi1);
[mA2,mB2,mC2,mD2,mE2,sA2,sB2,sC2,sD2,sE2] = evalDarkFrame(ffi2);
[mA3,mB3,mC3,mD3,mE3,sA3,sB3,sC3,sD3,sE3] = evalDarkFrame(ffi3);

% set total "exposure" time for science pixels (t_exp + t_readout)
t1t = t1 + tReadOut;
t2t = t2 + tReadOut;
t3t = t3 + tReadOut;

tTotal = [t1t,t2t,t3t];

% combine means into an array for fitting and convert to e-
bMean = [mC1,mC2,mC3].*gain;

% calculate error in estimate of mean of science pixel region, convert to e-
reducedError = ([sC1,sC2,sC3].*gain)./sqrt(numSciencePix);

% define design matrix for SVD least-squares fit to exposure times
A = [1,t1t; 1,t2t; 1,t3t];

% do least-squares fit to mean science pixel value vs. exposure time
% slope = dark current (e-/sec)
% intercept = bias (black) level (e-)
[csvd,yfit,CC]=svdfit(A,bMean',reducedError');

% bias and dark estimates from svd fit
biasEstimate = csvd(1);
darkEstimate = csvd(2);

% uncertainties in estimated parameters from covariance matrix
biasUnc = sqrt(CC(1,1));
darkUnc = sqrt(CC(2,2));

%% alternate estimate of dark current per second from masked & virtual smear regions
% Note: read out time is not used  since the only difference between the
% two regions is dark signal accumulated during the actual exposure time
darkSmear1 = (mB1 - mD1)*gain/t1;
darkSmear2 = (mB2 - mD2)*gain/t2;
darkSmear3 = (mB3 - mD3)*gain/t3;
 
% uncertainties of difference
% Note: assumes no uncertainty in exposure time and that uncertainty on
% bias estimate from above is << uncertainty in mean of smear regions
darkSmearUnc1 = sqrt( (sB1*gain)^2/numSmearPix + (sD1*gain)^2/numVSmearPix );
darkSmearUnc2 = sqrt( (sB2*gain)^2/numSmearPix + (sD2*gain)^2/numVSmearPix );
darkSmearUnc3 = sqrt( (sB3*gain)^2/numSmearPix + (sD3*gain)^2/numVSmearPix );

% take the mean of the three dark estimates
darkSmearMean = (darkSmear1+darkSmear2+darkSmear3)/3;
darkSmearMeanUnc = sqrt( darkSmearUnc1^2 + darkSmearUnc2^2 + darkSmearUnc3^2 )/3;

% estimate read noise from  black regions A, E
% Note: estimate will include transfer dark (region A) and serial dark (regions A & E)
readNoiseEstimate = mean([sA1,sE1,sA2,sE2,sA3,sE3]*gain);
readNoiseEstimateUnc = std([sA1,sE1,sA2,sE2,sA3,sE3]*gain);

 
%% display the results
fprintf('Input values:\n');
fprintf('****\tgain = %.2f e-/ADU\n',gain);
fprintf('****\tbias level = %.1f e-\n',blackLevel*gain);
fprintf('****\tdark current = %.3f e-/pix/sec\n',darkCurrent);
fprintf('****\tread noise = %.3f e-/pix/read\n',readNoise);
fprintf('****\texposure times (including read out):\n\t  t1 = %0.3f, t2 = %0.3f, t3 = %0.3f\n\n',t1t,t2t,t3t);
fprintf('Bias and Dark estimated from fit to science image area pixels (region C)\n');
fprintf('** Estimated Bias:\t%g +/- %.5f  e-\n', biasEstimate, biasUnc);
fprintf('** Estimated Dark:\t%.5g +/- %.5f e-/pix/sec\n', darkEstimate, darkUnc);

fprintf('\nDark estimated from difference of masked and virtual smear (region B - region D)\n');
fprintf('** Image 1 Estimated Dark (B-D):\t%.5g +/- %.4f e-/pix/sec\n',darkSmear1,darkSmearUnc1);
fprintf('** Image 2 Estimated Dark (B-D):\t%.5g +/- %.4f e-/pix/sec\n',darkSmear2,darkSmearUnc2);
fprintf('** Image 3 Estimated Dark (B-D):\t%.5g +/- %.4f e-/pix/sec\n',darkSmear3,darkSmearUnc3);
fprintf('   ----------------------------------------------------------------------------------------------------\n');
fprintf('\t mean Dark (B-D):\t%.5g +/- %.4f electrons/sec\n',darkSmearMean,darkSmearMeanUnc);

fprintf('\nRead Noise estimated from standard deviation of black regions A & E\n');
fprintf('** Estimated Read Noise:\t%.5g +/- %.4f e-/pix/read\n',readNoiseEstimate,readNoiseEstimateUnc);


% plot the results
figure
errorbar(tTotal,bMean,reducedError,'*')
hold on

% set up grid of times to display line fit
tArray = 0:0.1:tTotal(end)+0.5;
st = length(tArray);
plot( tArray, biasEstimate + darkEstimate.*tArray,'r-')
axis([0,tTotal(end) + 1, -inf, inf]);
xlabel('Exposure Time (seconds)')
ylabel(['Mean Pixel Value (electrons; gain = ',num2str(gain),' e-/ADU)'])
hold off

title('Mean Science Pixel Value vs. Exposure Time')
legend('Mean science pixel value', ['Best fit line: ',num2str(biasEstimate,'%.0f'),...
    ' + ',num2str(darkEstimate,'%.3f'),' t'],'Location','NorthWest')

%% get average vectors for black and smear regions
[leadBlackA,maskSmearB,virtualSmearD,trailBlackE,svA,svB,svD,svE] = extractCollateralVectors(ffi1);

figure
subplot(4,1,1)
plot(leadBlackA)
xlabel('Rows'), ylabel('ADU')
title('Leading Black (region A)')

subplot(4,1,2)
plot(trailBlackE)
xlabel('Rows'), ylabel('ADU')
title('Trailing Black (region E)')

subplot(4,1,3)
plot(maskSmearB)
xlabel('Columns'), ylabel('ADU')
title('Masked Smear (region B)')

subplot(4,1,4)
plot(virtualSmearD)
xlabel('Columns'), ylabel('ADU')
title('Virtual Smear (region D)')

set(gcf,'Name',['Sample collateral data vectors, T = ',num2str(t3t),' second dark'])




