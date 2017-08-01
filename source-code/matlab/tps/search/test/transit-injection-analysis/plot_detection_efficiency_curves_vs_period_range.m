% plot_detection_efficiency_curves_vs_period_range.m
% Compare detection efficiency curves for a target, at different period ranges
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
close all

% For KIC3114789 run on 10/1/2015
detectionEfficiencyDir = '/codesaver/work/transit_injection/detection_efficiency_curves/KIC3114789/';

% paths to .mat files for runs of make_detection_efficiency_curve.m with different period ranges
dataSet1Path = '/codesaver/work/transit_injection/detection_efficiency_curves/KIC3114789/KIC3114789-detection-efficiency-epoch-matching-generalized-logistic-function-model-period-20-to-120-days.mat';
dataSet2Path = '/codesaver/work/transit_injection/detection_efficiency_curves/KIC3114789/KIC3114789-detection-efficiency-epoch-matching-generalized-logistic-function-model-period-120-to-320-days.mat';
dataSet3Path = '/codesaver/work/transit_injection/detection_efficiency_curves/KIC3114789/KIC3114789-detection-efficiency-epoch-matching-generalized-logistic-function-model-period-320-to-720-days.mat';

% Period range 20 to 120 days
load(dataSet1Path)
nDetected1 = nDetectedAll;
nMissed1 = nMissedAll;
fittedABC1 = [parameter1,parameter2,parameter3];
periodLabel1 = periodLabel;
detectionEfficiency1 = detectionEfficiencyAll;

% Period range 120 to 320 days
load(dataSet2Path)
nDetected2 = nDetectedAll;
nMissed2 = nMissedAll;
fittedABC2 = [parameter1,parameter2,parameter3];
periodLabel2 = periodLabel;
detectionEfficiency2 = detectionEfficiencyAll;

% Period range 320 to 720 days
load(dataSet3Path)
nDetected3 = nDetectedAll;
nMissed3 = nMissedAll;
fittedABC3 = [parameter1,parameter2,parameter3];
periodLabel3 = periodLabel;
detectionEfficiency3 = detectionEfficiencyAll;

% Model function
generalizedLogisticFunction = @(x) 1./(1+exp(-x(1).*(midMesBin'-x(2)))).^x(3);
detectionEfficiencyModel1 = generalizedLogisticFunction(fittedABC1);
detectionEfficiencyModel2 = generalizedLogisticFunction(fittedABC2);
detectionEfficiencyModel3 = generalizedLogisticFunction(fittedABC3);

% Labels for plot legend
label1 = sprintf('Period 20 to 120 days, A = %8.4f, B = %8.4f, C = %8.4f',fittedABC1(1),fittedABC1(2),fittedABC1(3));
label2 = sprintf('Period 120 to 320 days, A = %8.4f, B = %8.4f, C = %8.4f',fittedABC2(1),fittedABC2(2),fittedABC2(3));
label3 = sprintf('Period 320 to 720 days, A = %8.4f, B = %8.4f, C = %8.4f',fittedABC3(1),fittedABC3(2),fittedABC3(3));

% Detection efficiency vs. MES curve at this target
figure
hold on
box on
grid on
plot(midMesBin,detectionEfficiencyModel1,'r-.','LineWidth',2)
plot(midMesBin,detectionEfficiencyModel2,'k--','LineWidth',2)
plot(midMesBin,detectionEfficiencyModel3,'b-','LineWidth',2)
legend(label1,label2,label3,'Location','NorthWest')
axis([4,16,0,1.4])
titleString= sprintf('Period Dependence of Detection Efficiency for KIC %s\nGeneralized Logistic Function Model',num2str(uniqueKeplerId));
title(titleString)
xlabel('Expected MES')
ylabel('Detected Fraction')
set(gca,'FontSize',12)
set(findall(gcf,'type','text'),'FontSize',12)
plotName = strcat(detectionEfficiencyDir,'detectionEfficiencyVsPeriodForKIC3114789');
print('-r150','-dpng',plotName)

% Labels for plot
label1 = sprintf('Period 20 to 120 days');
label2 = sprintf('Period 120 to 320 days');
label3 = sprintf('Period 320 to 720 days');

% Detection efficiency model residual vs. MES at this target
figure
hold on
box on
grid on
plot(midMesBin,detectionEfficiency1 - detectionEfficiencyModel1,'r*-')
plot(midMesBin,detectionEfficiency2 - detectionEfficiencyModel2,'ko-')
plot(midMesBin,detectionEfficiency3 - detectionEfficiencyModel3,'bdiamond-')
legend(label1,label2,label3,'Location','NorthEast')
axis([4,16,-0.05,0.06])
titleString= sprintf('Period Dependence of Detection Efficiency Model Residual (Data - Fit)\n for KIC %s, Generalized Logistic Function Model',num2str(uniqueKeplerId));
title(titleString)
xlabel('Expected MES')
ylabel('Residual Detected Fraction')
set(gca,'FontSize',12)
set(findall(gcf,'type','text'),'FontSize',12)
plotName = strcat(detectionEfficiencyDir,'detectionEfficiencyModelResidualVsPeriodForKIC3114789');
print('-r150','-dpng',plotName)

% Poisson noise vs. MES
figure
hold on
box on
grid on
plot(midMesBin,sqrt(nMissed1+nDetected1)./(nMissed1+nDetected1),'r*-')
plot(midMesBin,sqrt(nMissed1+nDetected2)./(nMissed1+nDetected2),'ko-')
plot(midMesBin,sqrt(nMissed1+nDetected3)./(nMissed1+nDetected3),'bdiamond-')
legend(label1,label2,label3,'Location','NorthWest')
axis([4,16,0,inf])
title(['Poisson Count Errors vs MES for KIC',num2str(uniqueKeplerId)])
xlabel('Expected MES')
ylabel('Fractional Detection Efficiency Error Due to Poisson Count Noise ')
set(gca,'FontSize',12)
set(findall(gcf,'type','text'),'FontSize',12)
plotName = strcat(detectionEfficiencyDir,'poissonCountNoiseVsPeriodForKIC3114789');
print('-r150','-dpng',plotName)

