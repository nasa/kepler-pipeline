% plot_two_detection_efficiency_curves.m
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

% Load 
detectionEfficiencyDir1 = '/codesaver/work/transit_injection/detection_efficiency_curves/KIC3114789/';
load(strcat(detectionEfficiencyDir1,'KIC3114789-detection-efficiency-epoch-matching-generalized-logistic-function-model-period-20-to-730-days.mat'))
detectionEfficiency1 = detectionEfficiencyAll;
keplerId1 = uniqueKeplerId;

detectionEfficiencyDir2 = '/codesaver/work/transit_injection/detection_efficiency_curves/KSOC-4930/';
load(strcat(detectionEfficiencyDir2,'KSOC-4930-detection-efficiency-epoch-matching-generalized-logistic-function-model-period-20-to-730-days.mat'))
detectionEfficiency2 = detectionEfficiencyAll(:,1);


% Detection efficiency vs. MES curve at this target, new vs. old codebase
figure
hold on
box on
grid on
plot(midMesBin,detectionEfficiency1,'b.-','LineWidth',2)
plot(midMesBin,detectionEfficiency2,'r.-','LineWidth',2)
axis([2,16,0,1.25])
set(gca,'FontSize',12)
set(findall(gcf,'type','text'),'FontSize',12)
title(['Detection Efficiency for KIC ',num2str(keplerId1)])
xlabel('Expected MES')
ylabel('Detected Fraction')
legend('Original codebase','New codebase')
plotName  = 'detection_efficiency_KIC3114789_new_vs_old_codebase';
print('-r150','-dpng',plotName)


% Residual, new vs. old codebase
figure
hold on
box on
grid on
% plot(midMesBinsUsed,detectionEfficiencyModel,'r-','LineWidth',2)
plot(midMesBin,detectionEfficiency2(:,1) - detectionEfficiency1,'k.-')
% legendString1 = ['Detection Efficiency: ',num2str(minPeriodDays,'%6.2f'),' < period < ',num2str(maxPeriodDays,'%6.2f'),' days'];
% legend(legendString2,legendString1,'Location','NorthWest')
axis([2,16,-inf,inf])
set(gca,'FontSize',12)
set(findall(gcf,'type','text'),'FontSize',12)
title(['KIC ',num2str(keplerId1),' Detection Efficiency Residual: new codebase minus old codebase'])
xlabel('Expected MES')
ylabel('Detected Fraction Difference')
plotName = 'detection_efficiency_KIC3114789_new_vs_old_codebase_residual';
print('-r150','-dpng',plotName)

