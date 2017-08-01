% compare_v2_period_vs_mes_contours_within_group.m
% produce a contour plot showing 
% 1) Ensemble detection efficiency for a Group of targets
% 2) std deviation of detection efficiency of targets in a group from the
% ensemble detection efficiency
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

% Inputs:
% data file with v2 detection efficiency contours produced by 
% make_v2_contours.m

% Initialize
clear all
close all

% Control
groupId = input('groupId: 1 (20 G stars), 2 (20 K stars), 3 (20 M stars) , 4 (20 G stars) or KSOC4886 (1 G, 1 K, and 1 M star) : ','s');
groupLabel = strcat('Group',groupId);
contourType = 'period-mes'; %input('Contour type: ''period-mes'' or ''period-radius'': ','s');

% List of targets which got sparse injections
if(str2double(groupId) == 3)
    badKics = [6804018, 4142913, 7033670];
else 
    badKics = [];
end
        

% Directory for contour plots
contoursDir = strcat('/codesaver/work/transit_injection/contour_plots/',groupLabel,'/');

% Ensemble of detection contours
dataFile = strcat(contoursDir,'v2-detection-contours-',groupLabel,'-',contourType);

% Load the file with the ensemble of detection contours
load(dataFile)

% Overall contour for the ensemble
nInjectedAll = squeeze(sum(nInjected));
nInjectedAllThatBecameTces = squeeze(sum(nInjectedThatBecameTces));
pipelineDetectionEfficiencyAll = nInjectedAllThatBecameTces./nInjectedAll;
nXbins = length(binCenters{1});
nYbins = length(binCenters{2});
nTargets = size(nInjected,1);

% Contour plot of ensemble pipeline detection efficiency
figure
[~,h2] = contourf(xGridCenters,yGridCenters,pipelineDetectionEfficiencyAll(:,:)');
set(h2,'ShowText','on','TextStep',get(h2,'LevelStep'))
t = colorbar('peer',gca);
set(get(t,'ylabel'),'String', 'Pipeline Detection Efficiency');
title(['v2 Detection Contours for ',groupLabel])
xlabel(['Period [Days], bin size = ',num2str(binWidthPeriod,'%6.2f')])
ylabel(yLabelString)
set(gca,'FontSize',12)
set(findall(gcf,'type','text'),'FontSize',12)
plotName = strcat(contoursDir,'v2-detection-contours-all-',groupLabel,'-',contourType);
print('-r150','-dpng',plotName)

% RMS deviation in pipeline detection efficiency over the ensemble of
% targets
pipelineDetectionEfficiencyDev = zeros(nTargets,nXbins,nYbins);
for iTarget = 1:nTargets
    
    % Exclude targets for which model detection efficiency failed due to
    % sparse injections
    if(~ismember(uniqueKeplerIdAll(iTarget),badKics))
        
        % pipelineDetectionEfficiencyDevSq(iTarget,:,:) =  ...
        % (pipelineDetectionEfficiencyAll - squeeze(pipelineDetectionEfficiency(iTarget,:,:))).^2;
        
        pipelineDetectionEfficiencyDev(iTarget,:,:) =  ...
            pipelineDetectionEfficiencyAll - squeeze(pipelineDetectionEfficiency(iTarget,:,:));
        
    else
        fprintf('No contour for keplerId %d, due to insufficient injections\n',uniqueKeplerIdAll(iTarget));
        
    end

end
rmsDetectionEfficiencyDeviation = sqrt(squeeze(mean(pipelineDetectionEfficiencyDev(~ismember(uniqueKeplerIdAll,badKics),:,:).^2)));
meanAbsDetectionEfficiencyDeviation = squeeze(mean(abs(pipelineDetectionEfficiencyDev(~ismember(uniqueKeplerIdAll,badKics),:,:))));
meanDetectionEfficiencyDeviation = squeeze(mean(pipelineDetectionEfficiencyDev(~ismember(uniqueKeplerIdAll,badKics),:,:)));

% Contour plot of RMS deviation of individual targets from ensemble pipeline detection efficiency
figure
[~,h2] = contourf(xGridCenters,yGridCenters,rmsDetectionEfficiencyDeviation(:,:)');
set(h2,'ShowText','on','TextStep',get(h2,'LevelStep'))
t = colorbar('peer',gca);
set(get(t,'ylabel'),'String', 'RMS Deviation in Bin');
title(['Scatter in v2 Detection Contours for ',groupLabel])
xlabel(['Period [Days], bin size = ',num2str(binWidthPeriod,'%6.2f')])
ylabel(yLabelString)
set(gca,'FontSize',12)
set(findall(gcf,'type','text'),'FontSize',12)
plotName = strcat(contoursDir,'v2-detection-contours-rms-deviation-',groupLabel,'-',contourType);
print('-r150','-dpng',plotName)


% Contour plot of mean deviation of individual targets from ensemble pipeline detection efficiency
figure
[~,h2] = contourf(xGridCenters,yGridCenters,meanDetectionEfficiencyDeviation(:,:)');
set(h2,'ShowText','on','TextStep',get(h2,'LevelStep'))
t = colorbar('peer',gca);
set(get(t,'ylabel'),'String', 'Mean Deviation in Bin ');
title(['Scatter in v2 Detection Contours for ',groupLabel])
xlabel(['Period [Days], bin size = ',num2str(binWidthPeriod,'%6.2f')])
ylabel(yLabelString)
set(gca,'FontSize',12)
set(findall(gcf,'type','text'),'FontSize',12)
plotName = strcat(contoursDir,'v2-detection-contours-avg-deviation-',groupLabel,'-',contourType);
print('-r150','-dpng',plotName)

% Contour plots of deviation of individual target detection efficiency from ensemble pipeline detection efficiency
for iTarget = 1:nTargets
    
    % target Id
    targetId = uniqueKeplerIdAll(iTarget);
    
    % Exclude targets for which model detection efficiency failed due to
    % sparse injections
    if(~ismember(uniqueKeplerIdAll(iTarget),badKics))
        
        figure
        [~,h2] = contourf(xGridCenters,yGridCenters,squeeze(pipelineDetectionEfficiencyDev(iTarget,:,:))');
        set(h2,'ShowText','on','TextStep',get(h2,'LevelStep'))
        t = colorbar('peer',gca);
        set(get(t,'ylabel'),'String', 'Deviation of Target Detection Efficiency From Group Detection Efficiency in Bin ');
        title(['Scatter in v2 Detection Contours for ',groupLabel,' KIC ',num2str(uniqueKeplerIdAll(iTarget))])
        xlabel(['Period [Days], bin size = ',num2str(binWidthPeriod,'%6.2f')])
        ylabel(yLabelString)
        set(gca,'FontSize',12)
        set(findall(gcf,'type','text'),'FontSize',12)
        % plotName = strcat(contoursDir,'v2-detection-contours-all-avg-deviation-',groupLabel);
        plotName = strcat(contoursDir,'v2-detection-contours-deviation-',groupLabel,'-KIC-',num2str(targetId),'-',contourType);
        print('-r150','-dpng',plotName)
        
    end
    
end


