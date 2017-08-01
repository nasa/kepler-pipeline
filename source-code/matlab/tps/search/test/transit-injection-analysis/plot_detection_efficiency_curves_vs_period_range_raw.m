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

% Get injection run
% groupLabel = input('Group ID: e.g. (see list in get_top_dir.m) KSOC-5004-1 -- ','s');
groupLabel1 = 'KSOC-5004-1-run2'; % 20 stars
groupLabel2 = 'KSOC-5004-2'; % 20 stars

% Choose method of matching injected transits to detected ones.
% matchMethod = 'tpsephem'; % epoch matches overlap tps-ephem matches by 87%
matchMethod = 'epoch'; % 10/01/2015 possible problem with pearsons correlation match when TPS finds a different period
fprintf('matchMethod = %s\n',matchMethod)

% Scripts directory
baseDir = '/path/to/matlab/tps/search/test/transit-injection-analysis/';
cd(baseDir)

% Option to model detection efficiency as generalized logistic function OR CDF function
% !!!!! Hardwired to 'L'; see KSOC-4881 for demonstration that 'L' is better than 'G'
detectionEfficiencyModelName = 'L';%= input('Choose detection efficiency model: L(generalized logistic function) or G(gamma CDF): ','s');

% Directories for injection data and diagnostics
[topDir1, diagnosticDir1] = get_top_dir(groupLabel1);
[topDir2, diagnosticDir2] = get_top_dir(groupLabel2);

% Directories with detection efficiency curves
detectionEfficiencyDir1 = strcat('/codesaver/work/transit_injection/detection_efficiency_curves/',groupLabel1,'/');
detectionEfficiencyDir2 = strcat('/codesaver/work/transit_injection/detection_efficiency_curves/',groupLabel2,'/');

% Directory for results
resultsDir = strcat('/codesaver/work/transit_injection/detection_efficiency_curves/composite/');

% Period ranges
periodLimits{1} = [320,730];
periodLimits{2} = [120,320];
periodLimits{3} = [20,120];
periodLimits{4} = [20,730];

% Colors
colors{1} = 'r';
colors{2} = 'k';
colors{3} = 'g';
colors{4} = 'b';

% Initialize figures
figure(1)
hold on
box on
grid on
% Cloodge to set legend symbols
plot(-1,1,'r.-')
plot(-1,1,'k.-')
plot(-1,1,'g.-')
plot(-1,1,'b.-')

figure(2)
hold on
box on
grid on



% Mid mes bin #17 corresponds to MES = 7.125
% 29 --> MES = 9.875
% 30 --> MES = 10.125
% metricBin = 17;
metricBin = 29;


% Associated detection efficiency mat-files and names
matFile1 = cell(1,length(periodLimits));
matFile2 = cell(1,length(periodLimits));
sufficientStatisticMedian = cell(1,length(periodLimits));
% sufficientStatisticMean = cell(1,length(periodLimits));
sufficientStatisticStd = cell(1,length(periodLimits));
for iRange = 1:length(periodLimits)
    
    % Make a label for the period range
    switch iRange
        case 1
            periodLabel1 = '320 < P < 730 days: ';
        case 2
            periodLabel2 = '120 < P < 320 days: ';
        case 3
            periodLabel3 = '20 < P < 120 days: ';
        case 4
            periodLabel4 = '20 < P < 730 days: ';
    end
    
    % Data files for the two datasets
    matFile1{iRange} = strcat(detectionEfficiencyDir1,groupLabel1,'-detection-efficiency-epoch-matching-generalized-logistic-function-model-period-',num2str(periodLimits{iRange}(1)),'-to-',num2str(periodLimits{iRange}(2)),'-days.mat');
    matFile2{iRange} = strcat(detectionEfficiencyDir2,groupLabel2,'-detection-efficiency-epoch-matching-generalized-logistic-function-model-period-',num2str(periodLimits{iRange}(1)),'-to-',num2str(periodLimits{iRange}(2)),'-days.mat');
    
    % Get data from the two datasets
    load(matFile1{iRange});
    detectionEfficiencyAll1 = detectionEfficiencyAll;
    uniqueKeplerId1 = uniqueKeplerId;
    nMissedAll1 = nMissedAll;
    nDetectedAll1 = nDetectedAll;
    load(matFile2{iRange});
    detectionEfficiencyAll2 = detectionEfficiencyAll;
    uniqueKeplerId2 = uniqueKeplerId;
    nMissedAll2 = nMissedAll;
    nDetectedAll2 = nDetectedAll;
    
    
    % Combine the two datasets to make a 88x40 array of detection
    % efficiency curves
    % detectionEfficiencyAll = [detectionEfficiencyAll1 , detectionEfficiencyAll2];
    % uniqueKeplerId = [uniqueKeplerId1 ; uniqueKeplerId2];
    % nMissedAll = sum(nMissedAll1(:)) +  sum(nMissedAll2(:));
    
    % Include only Group1-run2
    detectionEfficiencyAll = detectionEfficiencyAll1;
    uniqueKeplerId = uniqueKeplerId1;
    nMissedAll = sum(nMissedAll1(:));
    
    % Statistic = median detection efficiency at MES 7.125
    sufficientStatisticMedian{iRange} = median(detectionEfficiencyAll(metricBin,:));
    % sufficientStatisticMean{iRange} = mean(detectionEfficiencyAll(metricBin,:));
    sufficientStatisticStd{iRange} = std(detectionEfficiencyAll(metricBin,:));
    
    
    % Plot detection efficiency curves for all targets in this period range
    figure(1)
    for iTarget = 1:length(uniqueKeplerId)
        
        % Detection efficiency vs. MES curve at this target
        plot(midMesBin,detectionEfficiencyAll(:,iTarget),strcat(colors{iRange},'.-'),'LineWidth',1)
        
    end
    
    % median detection efficiency curve in this period range
    figure(2)
    plot(midMesBin,median(detectionEfficiencyAll,2),strcat(colors{iRange},'-'),'LineWidth',3)
        
end


% Finalize plots
figure(1)
axis([0,25,0,1])
titleString= sprintf('Period Dependence of Detection Efficiency');
title(titleString)
xlabel('Expected MES')
ylabel('Detected Fraction')
legend([periodLabel1,'deteff@MES=',num2str(midMesBin(metricBin),'%6.2f'),': MEDIAN ',num2str(sufficientStatisticMedian{1},'%6.2f'),' STD ',num2str(sufficientStatisticStd{1},'%6.2f')], ...
    [periodLabel2,'deteff@MES=',num2str(midMesBin(metricBin),'%6.2f'),': MEDIAN ',num2str(sufficientStatisticMedian{2},'%6.2f'),' STD ',num2str(sufficientStatisticStd{2},'%6.2f')], ...
    [periodLabel3,'deteff@MES=',num2str(midMesBin(metricBin),'%6.2f'),': MEDIAN ',num2str(sufficientStatisticMedian{3},'%6.2f'),' STD ',num2str(sufficientStatisticStd{3},'%6.2f')], ...
    [periodLabel4,'deteff@MES=',num2str(midMesBin(metricBin),'%6.2f'),': MEDIAN ',num2str(sufficientStatisticMedian{4},'%6.2f'),' STD ',num2str(sufficientStatisticStd{4},'%6.2f')],'Location','Best')
set(gca,'FontSize',12)
set(findall(gcf,'type','text'),'FontSize',12)
plotName = strcat(resultsDir,'detectionEfficiencyAllVsPeriod');
print('-r150','-dpng',plotName)

figure(2)
axis([0,25,0,1])
titleString= sprintf('Median Detection Efficiency vs. Period Range');
title(titleString)
xlabel('Expected MES')
ylabel('Detected Fraction')
legend(periodLabel1,periodLabel2,periodLabel3,periodLabel4,'Location','Best')
set(gca,'FontSize',12)
set(findall(gcf,'type','text'),'FontSize',12)
plotName = strcat(resultsDir,'medianDetectionEfficiencyVsPeriod');
print('-r150','-dpng',plotName)





