% veto_test.m
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

% Plot detection efficiency curves from the injection data from KSOC-4886
% which includes new SES/MES veto

%     KIC 2859114 G star with 128,880 injections
%     KIC 2991321 K star with 121,520 injections
%     KIC 3114789 M star with 122,150 injections

% Compare their detection efficiency curves to the ones obtained from
% KSOC-4881 before the new veto was in place
%==========================================================================

% Get stellar parameters
groupLabel = 'KSOC4886';
[stellarParameterStruct] = get_stellar_parameters_for_injection_targets(groupLabel);

% Get diagnostics
get_transit_injection_diagnostics(groupLabel)

% Make the detection efficiency curves (input KSOC4886 at prompt)
make_detection_efficiency_curve

% Overplot the detection efficiency curves for stars 1, 2 and 3 from KSOC-4881

% Get the detection efficiency curves for Group1, Group2, and Group3 stars
load('/codesaver/work/transit_injection/detection_efficiency_curves/Group1/detection-efficiency-generalized-logistic-function-model.mat')
detectionEfficiencyGroup1 = detectionEfficiencyAll;
nMissedGroup1 = nMissedAll;
nDetectedGroup1 = nDetectedAll;

load('/codesaver/work/transit_injection/detection_efficiency_curves/Group2/detection-efficiency-generalized-logistic-function-model.mat')
detectionEfficiencyGroup2 = detectionEfficiencyAll;
nMissedGroup2 = nMissedAll;
nDetectedGroup2 = nDetectedAll;

load('/codesaver/work/transit_injection/detection_efficiency_curves/Group3/detection-efficiency-epoch-matching-generalized-logistic-function-model.mat')
goodTargetIndicator = exitflagAll == true;
detectionEfficiencyGroup3 = detectionEfficiencyAll(:,goodTargetIndicator);
nMissedGroup3 = nMissedAll;
nDetectedGroup3 = nDetectedAll;

load('/codesaver/work/transit_injection/detection_efficiency_curves/KSOC4886/detection-efficiency-generalized-logistic-function-model.mat')
detectionEfficiencyKSOC4886 = detectionEfficiencyAll;
nMissedKSOC4886 = nMissedAll;
nDetectedKSOC4886 = nDetectedAll;

% detection efficiency differences
deviation_G_star_KIC_3114789 = detectionEfficiencyGroup1(:,1) - detectionEfficiencyKSOC4886(:,3);
deviation_K_star_KIC_2991321 = detectionEfficiencyGroup2(:,1) - detectionEfficiencyKSOC4886(:,2);
deviation_M_star_KIC_2859114 = detectionEfficiencyGroup3(:,1) - detectionEfficiencyKSOC4886(:,1);

%==========================================================================
% Calculate uncertainties in estimated detection efficiencies and
% differences, according to Chris Burke's note from KSOC-4861, 17 Aug 2015

% Uncertainty in detection efficiency for Group1 star, no veto
f1_noveto = detectionEfficiencyGroup1(:,1);
N1_noveto = nDetectedGroup1(:,1) + nMissedGroup1(:,1);
error1_noveto = sqrt((1-f1_noveto).*f1_noveto./(3+N1_noveto));

% Uncertainty in detection efficiency for Group2 star, no veto
f2_noveto = detectionEfficiencyGroup2(:,1);
N2_noveto = nDetectedGroup2(:,1) + nMissedGroup2(:,1);
error2_noveto = sqrt((1-f2_noveto).*f2_noveto./(3+N2_noveto));

% Uncertainty in detection efficiency for Group3 star, no veto
f3_noveto = detectionEfficiencyGroup3(:,1);
N3_noveto = nDetectedGroup3(:,1) + nMissedGroup3(:,1);
error3_noveto = sqrt((1-f3_noveto).*f3_noveto./(3+N3_noveto));

% Uncertainty in detection efficiency for Group1 star, with veto
f1_withveto = detectionEfficiencyKSOC4886(:,3);
N1_withveto = nDetectedKSOC4886(:,3) + nMissedKSOC4886(:,3);
error1_withveto = sqrt((1-f1_withveto).*f1_withveto./(3+N1_withveto));

% Uncertainty in detection efficiency for Group2 star, with veto
f2_withveto = detectionEfficiencyKSOC4886(:,2);
N2_withveto = nDetectedKSOC4886(:,2) + nMissedKSOC4886(:,2);
error2_withveto = sqrt((1-f2_withveto).*f2_withveto./(3+N2_withveto));

% Uncertainty in detection efficiency for Group3 star, with veto
f3_withveto = detectionEfficiencyKSOC4886(:,1);
N3_withveto = nDetectedKSOC4886(:,1) + nMissedKSOC4886(:,1);
error3_withveto = sqrt((1-f3_withveto).*f3_withveto./(3+N3_withveto));

% Uncertainty in difference in detection efficiency
error1 = sqrt(error1_noveto.^2 + error1_withveto.^2);
error2 = sqrt(error2_noveto.^2 + error2_withveto.^2);
error3 = sqrt(error3_noveto.^2 + error3_withveto.^2);


%==========================================================================
% Compare the detection efficiency curves for stars 1,2, and 3 from KSOC-4881
% with those from KSOC-4886
figure
hold on
grid on
box on
titleString = sprintf('Comparison of detection efficiency curves WITH (KSOC-4886)\n and WITHOUT (KSOC-4881) new veto');
title(titleString)
xlabel('MES')
ylabel('Detected Fraction')
plot(midMesBin,detectionEfficiencyKSOC4886(:,3),'r--','LineWidth',1) % G star KIC 3114789
plot(midMesBin,detectionEfficiencyGroup1(:,1),'r-','LineWidth',1)
plot(midMesBin,detectionEfficiencyKSOC4886(:,2),'b--','LineWidth',1) % K star KIC 2991321
plot(midMesBin,detectionEfficiencyGroup2(:,1),'b-','LineWidth',1)
plot(midMesBin,detectionEfficiencyKSOC4886(:,1),'g--','LineWidth',2) % M star KIC 2859114
plot(midMesBin,detectionEfficiencyGroup3(:,1),'g-','LineWidth',1)
set(gca,'FontSize',12)
set(findall(gcf,'type','text'),'FontSize',12)
axis([3,18,0, 1])
legend( ...
    'G star KIC 3114789 veto ON','G star KIC 3114789 veto OFF', ...
    'K star KIC 2991321 veto ON','K star KIC 2991321 veto OFF',...
    'M star KIC 2859114 veto ON','M star KIC 2859114 veto OFF', ...
    'Location','SouthEast')
plotName = strcat('compare_detection_efficiency_KSOC4881_vs_KSOC4886');
print('-r150','-dpng',plotName)


% Plot deviations: detection efficiency without new veto minus with new
% veto. Include error bars
figure
hold on
grid on
box on
titleString = sprintf('Deviation: detection efficiency WITHOUT new veto \n minus detection efficiency WITH new veto');
title(titleString)
xlabel('MES')
ylabel('Delta Detected Fraction')
errorbar(midMesBin,deviation_G_star_KIC_3114789,error1,'r.')
set(gca,'FontSize',12)
set(findall(gcf,'type','text'),'FontSize',12)
legend(['G star KIC 3114789 avg dev = ',num2str(mean(deviation_G_star_KIC_3114789),'%7.3f')])
axis([3,18,-0.02,0.11])
plotName = strcat('deviation_detection_efficiency_Gstar_KIC3114789_KSOC4881_vs_KSOC4886');
print('-r150','-dpng',plotName)


% Plot deviations: detection efficiency without new veto minus with new
% veto. Include error bars
figure
hold on
grid on
box on
titleString = sprintf('Deviation: detection efficiency WITHOUT new veto \n minus detection efficiency WITH new veto');
title(titleString)
xlabel('MES')
ylabel('Delta Detected Fraction')
errorbar(midMesBin,deviation_K_star_KIC_2991321,error2,'b.')
set(gca,'FontSize',12)
set(findall(gcf,'type','text'),'FontSize',12)
legend(['K star KIC 2991321 avg dev = ',num2str(mean(deviation_K_star_KIC_2991321),'%7.3f')])
axis([3,18,-0.02,0.11])
plotName = strcat('deviation_detection_efficiency_Kstar_KIC2991321_KSOC4881_vs_KSOC4886');
print('-r150','-dpng',plotName)


% Plot deviations: detection efficiency without new veto minus with new
% veto. Include error bars
figure
hold on
grid on
box on
titleString = sprintf('Deviation: detection efficiency WITHOUT new veto \n minus detection efficiency WITH new veto');
title(titleString)
xlabel('MES')
ylabel('Delta Detected Fraction')
errorbar(midMesBin,deviation_M_star_KIC_2859114,error3,'k.')
set(gca,'FontSize',12)
set(findall(gcf,'type','text'),'FontSize',12)
legend(['M star KIC 2859114 avg dev = ',num2str(mean(deviation_M_star_KIC_2859114),'%7.3f')])
axis([3,18,-0.02,0.11])
plotName = strcat('deviation_detection_efficiency_Mstar_KIC2859114_KSOC4881_vs_KSOC4886');
print('-r150','-dpng',plotName)


% Plot deviations: detection efficiency without new veto minus with new
% veto. No error bars
figure
hold on
grid on
box on
titleString = sprintf('Deviation: detection efficiency WITHOUT new veto \n minus detection efficiency WITH new veto');
title(titleString)
xlabel('MES')
ylabel('Delta Detected Fraction')
plot(midMesBin,deviation_G_star_KIC_3114789,'r.-')
plot(midMesBin,deviation_K_star_KIC_2991321,'b.-')
plot(midMesBin,deviation_M_star_KIC_2859114,'g.-')
set(gca,'FontSize',12)
set(findall(gcf,'type','text'),'FontSize',12)
legend(['G star KIC 3114789 avg dev = ',num2str(mean(deviation_G_star_KIC_3114789),'%8.4f')],...
    ['K star KIC 2991321 avg dev = ',num2str(mean(deviation_K_star_KIC_2991321),'%8.4f')],...
    ['M star KIC 2859114 avg dev = ',num2str(mean(deviation_M_star_KIC_2859114),'%8.4f')])
axis([3,18,-0.02,0.11])
plotName = strcat('deviation_detection_efficiency_KSOC4881_vs_KSOC4886');
print('-r150','-dpng',plotName)



