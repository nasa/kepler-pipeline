% compare_detection_efficiency_curves.m
% Adapted from plot_detection_efficiency_curves_vs_period_range.m
% Compare detection efficiency curves for a group of targets
% Run synthesize_detection_efficiency_curves.m after this, to fit detection
% efficiency curves as a function of temperature.
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

clear all
%close all

% For plots
colors = 'cmkgrb';
symbols{1} = 'square-';
symbols{2} = 'square-';
symbols{3} = 'diamond--';
symbols{4} = 'diamond--';
symbols{5} = 'o-.';
symbols{6} = 'o-.';
symbols{7} = 'square-';

% Run the script in this directory
baseDir = '/path/to/matlab/tps/search/test/transit-injection-analysis/';

% For Group A and Group B runs
detectionEfficiencyDir1 = '/codesaver/work/transit_injection/detection_efficiency_curves/GroupA/';
detectionEfficiencyDir2 = '/codesaver/work/transit_injection/detection_efficiency_curves/GroupB/';
detectionEfficiencyDir3 = '/codesaver/work/transit_injection/detection_efficiency_curves/KIC3114789/';

% Pulse durations
pulseDurationsHours = [1.5, 2.0, 2.5, 3.0, 3.5, 4.5 , 5.0, 6.0, 7.5, 9.0, 10.5, 12.0, 12.5, 15.0];

% Detection efficiency curve data for Group A
dataSetPath1 = strcat(detectionEfficiencyDir1,'GroupA-detection-efficiency-epoch-matching-generalized-logistic-function-model-period-20-to-730-days.mat');
load(dataSetPath1)
nStars1 = length(uniqueKeplerId);
nDetected1 = nDetectedAll;
nMissed1 = nMissedAll;
fittedABC1 = [parameter1,parameter2,parameter3];
periodLabel1 = periodLabel;
detectionEfficiency1 = detectionEfficiencyAll;
midMesBin1 = midMesBin;
keplerId1 = uniqueKeplerId;

% Detection efficiency curve data for Group B
dataSetPath2 = strcat(detectionEfficiencyDir2,'GroupB-detection-efficiency-epoch-matching-generalized-logistic-function-model-period-20-to-730-days.mat');
load(dataSetPath2)
nStars2 = length(uniqueKeplerId);
nDetected2 = nDetectedAll;
nMissed2 = nMissedAll;
fittedABC2 = [parameter1,parameter2,parameter3];
periodLabel2 = periodLabel;
detectionEfficiency2 = detectionEfficiencyAll;
midMesBin2 = midMesBin;
keplerId2 = uniqueKeplerId;

% Detection efficiency curve data for KIC 3114789
dataSetPath3 = strcat(detectionEfficiencyDir3,'KIC3114789-detection-efficiency-epoch-matching-generalized-logistic-function-model.mat');
load(dataSetPath3)
nStars3 = length(uniqueKeplerId);
nDetected3 = nDetectedAll;
nMissed3 = nMissedAll;
fittedABC3 = [parameter1,parameter2,parameter3];
periodLabel3 = periodLabel;
detectionEfficiency3 = detectionEfficiencyAll;
midMesBin3 = midMesBin;
keplerId3 = uniqueKeplerId;

% KeplerId
keplerId = [keplerId1;keplerId2;keplerId3];

% Fitted ABC
fittedABC = [fittedABC1;fittedABC2;fittedABC3];

% Get stellar parameters fir each target
dataDir = '/codesaver/work/transit_injection/data/';
stellarParameters1 = load(strcat(dataDir,'GroupA_stellar_parameters.mat'));
stellarParameters2 = load(strcat(dataDir,'GroupB_stellar_parameters.mat'));
stellarParameters3 = load(strcat(dataDir,'KIC3114789_stellar_parameters.mat'));

% Group A
effectiveTemp1 = zeros(1,nStars1);
stellarRadiusInSolarRadii1 = zeros(1,nStars1);
log10SurfaceGravity1 = zeros(1,nStars1);
log10Metallicity1 = zeros(1,nStars1);
keplerMag1 = zeros(1,nStars1);
rmsCdpp1 = zeros(nStars1,14);
for iStar = 1:nStars1
    effectiveTemp1(iStar) = stellarParameters1.stellarParameterStruct.effectiveTemp(iStar);
    stellarRadiusInSolarRadii1(iStar) = stellarParameters1.stellarParameterStruct.stellarRadiusInSolarRadii(iStar);
    log10SurfaceGravity1(iStar) = stellarParameters1.stellarParameterStruct.log10SurfaceGravity(iStar);
    log10Metallicity1(iStar) = stellarParameters1.stellarParameterStruct.log10Metallicity(iStar);
    rmsCdpp1(iStar,:) = stellarParameters1.stellarParameterStruct.rmsCdpp(iStar,:);
    keplerMag1(iStar) = stellarParameters1.stellarParameterStruct.keplerMag(iStar);
end

% Group B
effectiveTemp2 = zeros(1,nStars2);
stellarRadiusInSolarRadii2 = zeros(1,nStars2);
log10SurfaceGravity2 = zeros(1,nStars2);
log10Metallicity2 = zeros(1,nStars2);
keplerMag2 = zeros(1,nStars2);
rmsCdpp2 = zeros(nStars2,14);
for iStar = 1:nStars2
    effectiveTemp2(iStar) = stellarParameters2.stellarParameterStruct.effectiveTemp(iStar);
    stellarRadiusInSolarRadii2(iStar) = stellarParameters2.stellarParameterStruct.stellarRadiusInSolarRadii(iStar);
    log10SurfaceGravity2(iStar) = stellarParameters2.stellarParameterStruct.log10SurfaceGravity(iStar);
    log10Metallicity2(iStar) = stellarParameters2.stellarParameterStruct.log10Metallicity(iStar);
    rmsCdpp2(iStar,:) = stellarParameters2.stellarParameterStruct.rmsCdpp(iStar,:);
    keplerMag2(iStar) = stellarParameters2.stellarParameterStruct.keplerMag(iStar);
end

% KIC 3114789
effectiveTemp3 = zeros(1,nStars3);
stellarRadiusInSolarRadii3 = zeros(1,nStars3);
log10SurfaceGravity3 = zeros(1,nStars3);
log10Metallicity3 = zeros(1,nStars3);
keplerMag3 = zeros(1,nStars3);
rmsCdpp3 = zeros(nStars3,14);
for iStar = 1:nStars3
    effectiveTemp3(iStar) = stellarParameters3.stellarParameterStruct.effectiveTemp(iStar);
    stellarRadiusInSolarRadii3(iStar) = stellarParameters3.stellarParameterStruct.stellarRadiusInSolarRadii(iStar);
    log10SurfaceGravity3(iStar) = stellarParameters3.stellarParameterStruct.log10SurfaceGravity(iStar);
    log10Metallicity3(iStar) = stellarParameters3.stellarParameterStruct.log10Metallicity(iStar);
    rmsCdpp3(iStar,:) = stellarParameters3.stellarParameterStruct.rmsCdpp(iStar,:);
    keplerMag3(iStar) = stellarParameters3.stellarParameterStruct.keplerMag(iStar);
end

% Combine keplerMag
keplerMag = [keplerMag1,keplerMag2,keplerMag3]';

% Gather up stellar parameters for all targets
log10Metallicity = [log10Metallicity1, log10Metallicity2, log10Metallicity3]';
log10SurfaceGravity = [log10SurfaceGravity1, log10SurfaceGravity2, log10SurfaceGravity3]';
stellarRadiusInSolarRadii = [stellarRadiusInSolarRadii1, stellarRadiusInSolarRadii2, stellarRadiusInSolarRadii3]';
effectiveTemp = [effectiveTemp1, effectiveTemp2, effectiveTemp3]';
rmsCdpp = [rmsCdpp1; rmsCdpp2; rmsCdpp3];
nTargets = length(effectiveTemp);

% Detection efficiency for all targets
detectionEfficiency = [detectionEfficiency1';detectionEfficiency2';detectionEfficiency3'];

% Detection efficiency vs. MES curves
figure
hold on
box on
grid on

% Group A
for iStar = 1:nStars1
    plot(midMesBin1,detectionEfficiency1(:,iStar),[colors(iStar),'.-'],'LineWidth',2)
end

% Group B
for iStar = 1:nStars2
    plot(midMesBin2,detectionEfficiency2(:,iStar),[colors(iStar),'--'],'LineWidth',2)
end

% KIC 3114789
plot(midMesBin3,detectionEfficiency3(:,1),[colors(6),'.-'],'LineWidth',2)

xlabel('Expected MES')
ylabel('Detected Fraction')
set(gca,'FontSize',12)
set(findall(gcf,'type','text'),'FontSize',12)

title('Detection efficiency curves for 11 stars: Group A, Group B and KIC 3114789')
skip = true;
if(~skip)
    legend(['',num2str(keplerId1(1),'%d'),' ',num2str(effectiveTemp1(1),'%d'),'K',num2str(keplerMag1(1)),' mag'], ...
        ['',num2str(keplerId1(2),'%d'),' ',num2str(effectiveTemp1(2),'%d'),'K',num2str(keplerMag1(2),'%6.2f'),' mag'], ...
        ['',num2str(keplerId1(3),'%d'),' ',num2str(effectiveTemp1(3),'%d'),'K',num2str(keplerMag1(3),'%6.2f'),' mag'], ...
        ['',num2str(keplerId1(4),'%d'),' ',num2str(effectiveTemp1(4),'%d'),'K',num2str(keplerMag1(4),'%6.2f'),' mag'], ...
        ['',num2str(keplerId1(5),'%d'),' ',num2str(effectiveTemp1(5),'%d'),'K',num2str(keplerMag1(5),'%6.2f'),' mag'], ...
        ['',num2str(keplerId2(1),'%d'),' ',num2str(effectiveTemp2(1),'%d'),'K',num2str(keplerMag2(1),'%6.2f'),' mag'], ...
        ['',num2str(keplerId2(2),'%d'),' ',num2str(effectiveTemp2(2),'%d'),'K',num2str(keplerMag2(2),'%6.2f'),' mag'], ...
        ['',num2str(keplerId2(3),'%d'),' ',num2str(effectiveTemp2(3),'%d'),'K',num2str(keplerMag2(3),'%6.2f'),' mag'], ...
        ['',num2str(keplerId2(4),'%d'),' ',num2str(effectiveTemp2(4),'%d'),'K',num2str(keplerMag2(4),'%6.2f'),' mag'], ...
        ['',num2str(keplerId2(5),'%d'),' ',num2str(effectiveTemp2(5),'%d'),'K',num2str(keplerMag2(5),'%6.2f'),' mag'], ...
        ['',num2str(keplerId3(1),'%d'),' ',num2str(effectiveTemp3(1),'%d'),'K',num2str(keplerMag3(1),'%6.2f'),' mag'],'Location','EastOutside');
else
    legend([num2str(effectiveTemp1(1),'%d'),'K',num2str(keplerMag1(1),'%6.2f'),' mag'], ...
        [num2str(effectiveTemp1(2),'%d'),'K',num2str(keplerMag1(2),'%6.2f'),' mag'], ...
        [num2str(effectiveTemp1(3),'%d'),'K',num2str(keplerMag1(3),'%6.2f'),' mag'], ...
        [num2str(effectiveTemp1(4),'%d'),'K',num2str(keplerMag1(4),'%6.2f'),' mag'], ...
        [num2str(effectiveTemp1(5),'%d'),'K',num2str(keplerMag1(5),'%6.2f'),' mag'], ...
        [num2str(effectiveTemp2(1),'%d'),'K',num2str(keplerMag2(1),'%6.2f'),' mag'], ...
        [num2str(effectiveTemp2(2),'%d'),'K',num2str(keplerMag2(2),'%6.2f'),' mag'], ...
        [num2str(effectiveTemp2(3),'%d'),'K',num2str(keplerMag2(3),'%6.2f'),' mag'], ...
        [num2str(effectiveTemp2(4),'%d'),'K',num2str(keplerMag2(4),'%6.2f'),' mag'], ...
        [num2str(effectiveTemp2(5),'%d'),'K',num2str(keplerMag2(5),'%6.2f'),' mag'], ...
        [num2str(effectiveTemp3(1),'%d'),'K',num2str(keplerMag3(1),'%6.2f'),' mag'],'Location','EastOutside');
    
end
axis([2,18,0,1])


% Fitted detection efficiency parameters A, B and C vs. radius, Teff, logg
% and logFeH

% A, B, C parameters vs. stellar radius
figure
hold on
grid on
box on
title('Rstar')
plot(stellarRadiusInSolarRadii,fittedABC(:,1),'r.');
plot(stellarRadiusInSolarRadii,fittedABC(:,2),'b.');
plot(stellarRadiusInSolarRadii,fittedABC(:,3),'g.');
xlabel('Stellar radius [Suns]')
ylabel('Fitted parameter')
legend('A','B','C')
set(gca,'FontSize',12)
set(findall(gcf,'type','text'),'FontSize',12)

% A, B, C parameters vs. stellar Teff
figure
hold on
grid on
box on
title('Teff')
plot(effectiveTemp,fittedABC(:,1),'r.');
plot(effectiveTemp,fittedABC(:,2),'b.');
plot(effectiveTemp,fittedABC(:,3),'g.');
xlabel('Stellar effective temperature [K]')
ylabel('Fitted parameter')
legend('A','B','C')
set(gca,'FontSize',12)
set(findall(gcf,'type','text'),'FontSize',12)

% A, B, C parameters vs. logg
figure
hold on
grid on
box on
title('logg')
plot(log10SurfaceGravity,fittedABC(:,1),'r.');
plot(log10SurfaceGravity,fittedABC(:,2),'b.');
plot(log10SurfaceGravity,fittedABC(:,3),'g.');
xlabel('log10(Surface Gravity [cm/sec^2])')
ylabel('Fitted parameter')
legend('A','B','C')
set(gca,'FontSize',12)
set(findall(gcf,'type','text'),'FontSize',12)


% A, B, C parameters vs. metallicity
figure
hold on
grid on
box on
title('logFeH')
plot(log10Metallicity,fittedABC(:,1),'r.');
plot(log10Metallicity,fittedABC(:,2),'b.');
plot(log10Metallicity,fittedABC(:,3),'g.');
xlabel('log10(Metallicity)')
ylabel('Fitted parameter')
legend('A','B','C')
set(gca,'FontSize',12)
set(findall(gcf,'type','text'),'FontSize',12)

%==========================================================================
% Stellar parameters vs. detection efficiency metric
% metric is detection efficiency at midMesBin with MES = 8.125
iMesBin = 21;

% Exclude bad star keplerId 9898170
iBadStar = 5;
II = setdiff(1:11,iBadStar);

% log10Metallicty
figure
hold on
grid on
box on
title('log10Metallicity vs. detection effiency at MES = 8.125')
plot(log10Metallicity(II),detectionEfficiency(II,iMesBin),'kp');
xlabel('log10Metallicity [dex]')
ylabel('Detection efficiency at MES = 8.125')
axis([-inf,inf,0.4,0.6])
set(gca,'FontSize',12)
set(findall(gcf,'type','text'),'FontSize',12)
plotName = strcat(dataDir,'detection_efficiency_vs_log10Metallicity');
print('-r150','-dpng',plotName)

% log10SurfaceGravity
figure
hold on
grid on
box on
title('log10SurfaceGravity vs. detection effiency at MES = 8.125')
xlabel('log10SurfaceGravity [dex]')
ylabel('Detection efficiency at MES = 8.125')
axis([-inf,inf,0.4,0.6])
plot(log10SurfaceGravity(II),detectionEfficiency(II,iMesBin),'bp');
set(gca,'FontSize',12)
set(findall(gcf,'type','text'),'FontSize',12)
plotName = strcat(dataDir,'detection_efficiency_vs_log10SurfaceGravity');
print('-r150','-dpng',plotName)

% Stellar radius
figure
hold on
grid on
box on
title('Stellar Radius vs. detection effiency at MES = 8.125')
xlabel('Stellar radius [solar radii]')
ylabel('Detection efficiency at MES = 8.125')
axis([-inf,inf,0.4,0.6])
plot(stellarRadiusInSolarRadii(II),detectionEfficiency(II,iMesBin),'mp');
set(gca,'FontSize',12)
set(findall(gcf,'type','text'),'FontSize',12)
plotName = strcat(dataDir,'detection_efficiency_vs_stellarRadiusInSolarRadii');
print('-r150','-dpng',plotName)

% EffectiveTemp
figure
hold on
grid on
box on
title('Stellar Effective Temperature vs. detection effiency at MES = 8.125')
xlabel('Stellar effective temperature [K]')
ylabel('Detection efficiency at MES = 8.125')
axis([-inf,inf,0.4,0.6])
plot(effectiveTemp(II),detectionEfficiency(II,iMesBin),'gp');
set(gca,'FontSize',12)
set(findall(gcf,'type','text'),'FontSize',12)
plotName = strcat(dataDir,'detection_efficiency_vs_effectiveTemp');
print('-r150','-dpng',plotName)

% rmsCDPP at 6 hours
iPulseBin = 8;
figure
hold on
grid on
box on
title('RMS CDPP at 6 hour pulse vs. detection effiency at MES = 8.125')
xlabel('RMS CDPP at 6 hour pulse [ppm]')
ylabel('Detection efficiency at MES = 8.125')
axis([-inf,inf,0.4,0.6])
plot(rmsCdpp(II,iPulseBin),detectionEfficiency(II,iMesBin),'rp');
set(gca,'FontSize',12)
set(findall(gcf,'type','text'),'FontSize',12)
plotName = strcat(dataDir,'detection_efficiency_vs_rmsCDPP');
print('-r150','-dpng',plotName)

%==========================================================================
% CDPP vs. pulse duration
legendString = cell(11,1);
figure
for iTarget = 1:nTargets
    loglog( pulseDurationsHours',rmsCdpp(iTarget,:),strcat(colors(1+mod(iTarget,6)),symbols{1+mod(3*iTarget,7)}) ,'LineWidth',2);
    legendString{iTarget} = strcat( 'KIC',num2str(keplerId(iTarget),'%d'),' , ',num2str(effectiveTemp(iTarget),'%d'),'K',' , ',num2str(keplerMag(iTarget),'%6.2f'),'mag') ;
    hold on
end
title('CDPP vs Pulse Duration for 11 injection targets')
legend(legendString{1},legendString{2},legendString{3}, ...
    legendString{4},legendString{5},legendString{6}, ...
    legendString{7},legendString{8},legendString{9}, ...
    legendString{10},legendString{11},'Location','EastOutside')
box on
grid on
axis([1,20,50,500])
xlabel('Pulse Duration [hours]')
ylabel('CDPP [ppm]')
set(gca,'FontSize',12)
set(findall(gcf,'type','text'),'FontSize',12)
plotName = strcat(dataDir,'CDPP_vs_pulse_duration');
print('-r150','-dpng',plotName)

