% compare_v0_v1.m
% compares v0 contours with my computed v1 contours 
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

% Injection target group for which we want to compare v0 against v1
groupId = input('groupId: 1 (20 G stars), 2 (20 K stars), 3 (20 M stars) , 4 (20 G stars), 6 (20 K stars), KSOC4886 (1 G, 1 K, and 1 M star), or KIC3114789: ','s');


% Directories for the tpsInjectionStruct and diagnosticStruct
switch groupId
    
    case '1'
        % Group 1 20 G stars
        groupLabel = strcat('Group',groupId);
        
    case '2'
        % Group 2 20 K stars
        groupLabel = strcat('Group',groupId);
        
    case 'KSOC4886'
        groupLabel = groupId;
        
    case '3'
        % Group 3 20 M stars
        groupLabel = strcat('Group',groupId);
        
    case '4'
        % Group 4 20 G stars
        groupLabel = strcat('Group',groupId);
        
    case '6'
        % Group 6 20 M stars
        groupLabel = strcat('Group',groupId);
        
    case 'KIC3114789'
        groupLabel = groupId;
end





% Directory for v0 detection efficiency contours, and where we will save
% results
contoursDir = strcat('/codesaver/work/transit_injection/contour_plots/',groupLabel,'/');

% Set of v0 contours for this group
contourDimensionsLabel = 'period-radius';
v0DataFile = strcat(contoursDir,'v0-detection-contours-',groupLabel,'-',contourDimensionsLabel);
v1DataFile = strcat(contoursDir,'v1-detection-contours-',groupLabel,'-',contourDimensionsLabel);

% Get v0 detection contours
load(v0DataFile)
v0DetectionEfficiency = pipelineDetectionEfficiency;

% Get v1 detection contours
load(v1DataFile)
v1DetectionEfficiency = pipelineDetectionEfficiency;

nTargets = size(v0DetectionEfficiency,1);
[nYbins, nXbins] = size(xGridCenters);

% Loop over targets in list, retrieving v1 contour and producing difference (v1 - v0) contour plots
detectionEfficiencyDeviation = zeros(nTargets,nYbins,nXbins);
for iTarget = 1:nTargets
    
    
    % v1 minus v0 contour difference
    v1Data = squeeze(v1DetectionEfficiency(iTarget,:,:))';
    v0Data = squeeze(v0DetectionEfficiency(iTarget,:,:))';
    detectionEfficiencyDeviation(iTarget,:,:) = v1Data - v0Data;

    % Contour plot of difference between v1 and v0 contours
    figure
    [~,h2] = contourf(xGridCenters,yGridCenters,squeeze(detectionEfficiencyDeviation(iTarget,:,:)));
    set(h2,'ShowText','on','TextStep',get(h2,'LevelStep'))
    t = colorbar('peer',gca);
    set(get(t,'ylabel'),'String', 'Detection Efficiency Difference v1 - v0 in Bin ');
    title(['v1 minus v0 Detection Contours for ',groupLabel,' KIC ',num2str(uniqueKeplerIdAll(iTarget))])
    xlabel(['Period [Days], bin size = ',num2str(binWidthPeriod,'%6.2f')])
    ylabel(yLabelString)
    set(gca,'FontSize',12)
    set(findall(gcf,'type','text'),'FontSize',12)
    plotName = strcat(contoursDir,'v1-minus-v0-detection-contours-',groupLabel,'-',contourDimensionsLabel);
    print('-r150','-dpng',plotName)
    
end

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
    set(get(t,'ylabel'),'String', 'RMS Deviation of v1 minus v0 in Bin');
    title(['RMS Deviation in v1 minus v0 Detection Contours for ',groupLabel])
    xlabel(['Period [Days], bin size = ',num2str(binWidthPeriod,'%6.2f')])
    ylabel(yLabelString)
    set(gca,'FontSize',12)
    set(findall(gcf,'type','text'),'FontSize',12)
    plotName = strcat(contoursDir,'v1-minus-v0-detection-contours-rms-deviation-',groupLabel,'-',contourDimensionsLabel);
    print('-r150','-dpng',plotName)
    
    
    % Contour plot of mean absolute deviation of individual targets from ensemble pipeline detection efficiency
    figure
    [~,h2] = contourf(xGridCenters,yGridCenters,meanAbsDetectionEfficiencyDeviation(:,:));
    set(h2,'ShowText','on','TextStep',get(h2,'LevelStep'))
    t = colorbar('peer',gca);
    set(get(t,'ylabel'),'String', 'Mean Absolute Deviation of v1 minus v0 in Bin ');
    title(['Mean Absolute Deviation in v1 minus v0 Detection Contours for ',groupLabel])
    xlabel(['Period [Days], bin size = ',num2str(binWidthPeriod,'%6.2f')])
    ylabel(yLabelString)
    set(gca,'FontSize',12)
    set(findall(gcf,'type','text'),'FontSize',12)
    plotName = strcat(contoursDir,'v1-minus-v0-detection-contours-avg-abs-deviation-',groupLabel,'-',contourDimensionsLabel);
    print('-r150','-dpng',plotName)
    
    % Contour plot of mean deviation of individual targets from ensemble pipeline detection efficiency
    figure
    [~,h2] = contourf(xGridCenters,yGridCenters,meanDetectionEfficiencyDeviation(:,:));
    set(h2,'ShowText','on','TextStep',get(h2,'LevelStep'))
    t = colorbar('peer',gca);
    set(get(t,'ylabel'),'String', 'Mean Deviation of v1 minus v0 in Bin ');
    title(['Mean Deviation of v1 minus v0 Detection Contours for ',groupLabel])
    xlabel(['Period [Days], bin size = ',num2str(binWidthPeriod,'%6.2f')])
    ylabel(yLabelString)
    set(gca,'FontSize',12)
    set(findall(gcf,'type','text'),'FontSize',12)
    plotName = strcat(contoursDir,'v1-minus-v0-detection-contours-avg-deviation-',groupLabel,'-',contourDimensionsLabel);
    print('-r150','-dpng',plotName)
    
end