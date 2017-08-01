% compare_v0_or_v1_to_v2.m
% Combined compare_v0_v2.m and compare_v1_v2.m into a single script
% compares computed vx (v0 or v1) contours with v2 contours 
% Before running this script, run make_v0_or_v1_contours.m to make v0 or
% v1 contours, and run make_v2_contours.m to make v2 contours.
% Implement option to specify different dutyCycle for each target, so that
% a different v0 contours file is loaded.
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

% Initialize
% clear all
% close all

% Instructions
fprintf('!!!!! Before running this script, run make_v0_or_v1_contours.m and make_v2_contours.m ...\n')

% Injection target group for which we want to compare vx against v2
% groupLabel = input('groupId: Group1 (20 G stars), Group2 (20 K stars), Group3 (20 M stars) , Group4 (20 G stars), Group6 (20 K stars), KSOC4886 (1 G, 1 K, and 1 M star), KIC3114789, GroupA, GroupB, or KSOC-4930: ','s');
% groupLabel = input('groupId: Group1, Group2, Group3, Group4, Group6, KSOC4886, KIC3114789, GroupA, GroupB, KSOC-4930, KSOC-4964, KSOC-4964-2: ','s');
groupLabel = input('groupLabel, e.g. KSOC-4976-1: ','s');

% Directory for v2 detection efficiency contours, and where we will save
% results
contoursDir = strcat('/codesaver/work/transit_injection/contour_plots/',groupLabel,'/');

% Constants
contourLabel = 'period-radius';
baseDir = '/path/to/matlab/tps/search/test/transit-injection-analysis/';

% Labels
dutyCycleLabel = [];
validityThresholdLabel = [];

% Contour type -- vx is either v0 or v1
contourType = input('Contour type: v0 or v1 --  ','s');

% Set dutyCycleLabel
switch contourType
    case 'v1'
        overrideDutyCycle = false;
    case 'v0'
        overrideDutyCycle = logical(input('Override dutyCycle from TPS? 0 or 1 -- '));
end
if(overrideDutyCycle)
    dutyCycleForV0 = input('Specify dutyCycle -- 0.78 is nominal: ');
    dutyCycleLabel = strcat('-duty-cycle-',num2str(dutyCycleForV0));
    fprintf('Using duty cycle of %6.2f\n',dutyCycleForV0)
else
    dutyCycleLabel = [];
end


% Set of v2 contours for this group
v2DataFile = strcat(contoursDir,'v2-detection-contours-',groupLabel,'-',contourLabel,'.mat');
fprintf('\nv2 data file is %s\n',v2DataFile)

% Get v2 detection contours
load(v2DataFile)
nInjectedAll = squeeze(sum(nInjected));
nInjectedAllThatBecameTces = squeeze(sum(nInjectedThatBecameTces));
pipelineDetectionEfficiencyAll = nInjectedAllThatBecameTces./nInjectedAll;
nXbins = length(binCenters{1});
nYbins = length(binCenters{2});
nTargets = size(nInjected,1);

% Option to use analytic or empirical window function
chooseWindowFunction = input('Choose window function: A(analytic) E(empirical) -- ','s');


% return

% Loop over targets in list, retrieving vx contour and producing difference (vx - v2) contour plots
detectionEfficiencyDeviation = zeros(nTargets,nYbins,nXbins);
for iTarget = 1:nTargets
    
    % keplerId
    targetId = uniqueKeplerIdAll(iTarget);
    
    % Get vx detection contours -- depending on dutyCycle
    switch contourType
        case 'v0'
            
            
            % Set validity threshold to default
            validityThreshold = 0.5;
            % validityThreshold = [];% input('Validity threshold for window function, e.g. 0, 0.25, 0.5, 0.75, 0.85, 0.95 --  ');
            if(~isempty(validityThreshold))
                
                validityThresholdLabel = strcat('-threshold-',num2str(validityThreshold));
                
            else
                validityThresholdLabel = [];
            end
            
            vxDataFile = strcat(contoursDir,'v0-detection-contours-',groupLabel,'-',contourLabel,validityThresholdLabel,dutyCycleLabel,'.mat');
            fprintf('\nv0 data file is %s\n',vxDataFile)
            
        case 'v1'
            
            % Get validityThreshold label -- it's not used so leave it empty
            validityThreshold = [];% input('Validity threshold for window function, e.g. 0, 0.25, 0.5, 0.75, 0.85, 0.95 --  ');
            if(~isempty(validityThreshold))
                
                validityThresholdLabel = strcat('-threshold-',num2str(validityThreshold));
                
            else
                validityThresholdLabel = [];
            end
            vxDataFile = strcat(contoursDir,'v1-detection-contours-',groupLabel,'-',contourLabel,validityThresholdLabel,dutyCycleLabel,'.mat');
            fprintf('\nv1 data file is %s\n',vxDataFile)
            
    end
    
    % Load the vx contours file
    load(vxDataFile)
    
    % Choose window function to use
    switch chooseWindowFunction
        case 'E'
            % !!!!! Use empirical Window Function based on fitSinglePulse
            fprintf('!!!!! Using Empirical WF for v0 contours\n')
            vxPipelineDetectionEfficiency = pipelineDetectionEfficiency1;
            
        case 'A'
            % !!!!! Use Analytic Window Function
            fprintf('!!!!! Using Analytic WF for v0 contours\n')
            vxPipelineDetectionEfficiency = pipelineDetectionEfficiency;     
    end
    
    % vx minus v2 contour difference
    vxData = squeeze(vxPipelineDetectionEfficiency(iTarget,:,:))';
    v2Data = squeeze(v2PipelineDetectionEfficiency(iTarget,:,:))';
    detectionEfficiencyDeviation(iTarget,:,:) = vxData - v2Data;

    % Contour plot of difference between vx and v2 contours
    figure
    [~,h2] = contourf(xGridCenters,yGridCenters,squeeze(detectionEfficiencyDeviation(iTarget,:,:)));
    set(h2,'ShowText','on','TextStep',get(h2,'LevelStep'))
    t = colorbar('peer',gca);
    caxis([-.3,.3])
    set(get(t,'ylabel'),'String', ['Detection Efficiency Difference ',contourType,' - v2 in Bin ']);
    title([contourType,' minus v2 Detection Contours for ',groupLabel,' KIC ',num2str(uniqueKeplerIdAll(iTarget))])
    xlabel(['Period [Days], bin size = ',num2str(binWidthPeriod,'%6.2f')])
    ylabel(yLabelString)
    set(gca,'FontSize',12)
    set(findall(gcf,'type','text'),'FontSize',12)
    plotName = strcat(contoursDir,contourType,'-minus-v2-detection-contours-',groupLabel,'-KIC-',num2str(uniqueKeplerIdAll(iTarget)),'-',contourLabel,dutyCycleLabel,validityThresholdLabel,'.png');
    print('-r150','-dpng',plotName)
    
    % v0 or v1 contour plot
    figure
    [~,h2] = contourf(xGridCenters,yGridCenters,vxData);
    set(h2,'ShowText','on','TextStep',get(h2,'LevelStep'))
    t = colorbar('peer',gca);
    caxis([0,1])
    set(get(t,'ylabel'),'String', ['Detection Efficiency ',contourType,' - v2 in Bin ']);
    title([contourType,' Detection Contours for ',groupLabel,' KIC ',num2str(uniqueKeplerIdAll(iTarget))])
    xlabel(['Period [Days], bin size = ',num2str(binWidthPeriod,'%6.2f')])
    ylabel(yLabelString)
    set(gca,'FontSize',12)
    set(findall(gcf,'type','text'),'FontSize',12)
    plotName = strcat(contoursDir,contourType,'-detection-contours-',groupLabel,'-KIC-',num2str(uniqueKeplerIdAll(iTarget)),'-',contourLabel,dutyCycleLabel,validityThresholdLabel,'.png');
    print('-r150','-dpng',plotName)
    
    % vx minus v2 residual vs. period
    meanResidualVsPeriod = mean(squeeze(detectionEfficiencyDeviation(iTarget,:,:)));
    maxAbsResidualVsPeriod = max(abs(squeeze(detectionEfficiencyDeviation(iTarget,:,:))));

    % Mean residual as a function of period between vx and v2 contours
    figure
    hold on
    grid on
    box on
    title([contourType,' minus v2 mean residual vs period for ',groupLabel,' KIC ',num2str(uniqueKeplerIdAll(iTarget))])
    xlabel(['Period [Days], bin size = ',num2str(binWidthPeriod,'%6.2f')])
    ylabel('residual')
    plot(binCenters{1},meanResidualVsPeriod,'r.-')
    legend(['Mean residual = ',num2str(mean(meanResidualVsPeriod),'%7.3f')],'Location','Best')
    set(gca,'FontSize',12)
    set(findall(gcf,'type','text'),'FontSize',12)
    plotName = strcat(contoursDir,contourType,'-minus-v2-residual-vs-period-',groupLabel,'-KIC-',num2str(uniqueKeplerIdAll(iTarget)),'-',contourLabel,dutyCycleLabel,validityThresholdLabel,'.png');
    print('-r150','-dpng',plotName)
    
    % Max abs residual as a function of period between vx and v2 contours
    figure
    hold on
    grid on
    box on
    title([contourType,' minus v2 max abs residual vs period for ',groupLabel,' KIC ',num2str(uniqueKeplerIdAll(iTarget))])
    xlabel(['Period [Days], bin size = ',num2str(binWidthPeriod,'%6.2f')])
    ylabel('residual')
    plot(binCenters{1},maxAbsResidualVsPeriod,'b.-')
    set(gca,'FontSize',12)
    set(findall(gcf,'type','text'),'FontSize',12)
    plotName = strcat(contoursDir,contourType,'-minus-v2-max-abs-residual-vs-period-',groupLabel,'-KIC-',num2str(uniqueKeplerIdAll(iTarget)),'-',contourLabel,dutyCycleLabel,validityThresholdLabel,'.png');
    print('-r150','-dpng',plotName)
    
end

skip = true;
if(~skip)
    if(nTargets > 1)
        
        % Get RMS, mean, and mean absolute deviations
        rmsDetectionEfficiencyDeviation = sqrt(squeeze(mean(detectionEfficiencyDeviation.^2)));
        meanAbsDetectionEfficiencyDeviation = squeeze(mean(abs(detectionEfficiencyDeviation)));
        meanDetectionEfficiencyDeviation = squeeze(mean(detectionEfficiencyDeviation));
        
        % Contour plot of RMS deviation of individual targets from ensemble pipeline detection efficiency
        figure
        [~,h2] = contourf(xGridCenters,yGridCenters,rmsDetectionEfficiencyDeviation(:,:));
        set(h2,'ShowText','on','TextStep',get(h2,'LevelStep'))
        t = colorbar('peer',gca);
        set(get(t,'ylabel'),'String', ['RMS Deviation of ',contourType,' minus v2 in Bin']);
        title(['RMS Deviation in ',contourType,' minus v2 Detection Contours for ',groupLabel])
        xlabel(['Period [Days], bin size = ',num2str(binWidthPeriod,'%6.2f')])
        ylabel(yLabelString)
        set(gca,'FontSize',12)
        set(findall(gcf,'type','text'),'FontSize',12)
        plotName = strcat(contoursDir,contourType,'-minus-v2-detection-contours-rms-deviation-',groupLabel,'-',contourLabel,dutyCycleLabel,validityThresholdLabel,'.png');
        print('-r150','-dpng',plotName)
       
        % Contour plot of mean absolute deviation of individual targets from ensemble pipeline detection efficiency
        figure
        [~,h2] = contourf(xGridCenters,yGridCenters,meanAbsDetectionEfficiencyDeviation(:,:));
        set(h2,'ShowText','on','TextStep',get(h2,'LevelStep'))
        t = colorbar('peer',gca);
        set(get(t,'ylabel'),'String', ['Mean Absolute Deviation of ',contourType,' minus v2 in Bin ']);
        title(['Mean Absolute Deviation in ',contourType,' minus v2 Detection Contours for ',groupLabel])
        xlabel(['Period [Days], bin size = ',num2str(binWidthPeriod,'%6.2f')])
        ylabel(yLabelString)
        set(gca,'FontSize',12)
        set(findall(gcf,'type','text'),'FontSize',12)
        plotName = strcat(contoursDir,contourType,'-minus-v2-detection-contours-avg-abs-deviation-',groupLabel,'-',contourLabel,dutyCycleLabel,validityThresholdLabel,'.png');
        print('-r150','-dpng',plotName)
        
        % Contour plot of mean deviation of individual targets from ensemble pipeline detection efficiency
        figure
        [~,h2] = contourf(xGridCenters,yGridCenters,meanDetectionEfficiencyDeviation(:,:));
        set(h2,'ShowText','on','TextStep',get(h2,'LevelStep'))
        t = colorbar('peer',gca);
        set(get(t,'ylabel'),'String', ['Mean Deviation of ',contourType,' minus v2 in Bin ']);
        title(['Mean Deviation of ',contourType,' minus v2 Detection Contours for ',groupLabel])
        xlabel(['Period [Days], bin size = ',num2str(binWidthPeriod,'%6.2f')])
        ylabel(yLabelString)
        set(gca,'FontSize',12)
        set(findall(gcf,'type','text'),'FontSize',12)
        plotName = strcat(contoursDir,contourType,'-minus-v2-detection-contours-avg-deviation-',groupLabel,'-',contourLabel,dutyCycleLabel,validityThresholdLabel,'.png');
        print('-r150','-dpng',plotName)
        
    end
end