% ensemble_detection_efficiency.m
% make a single detetection efficiency curve to represent the behavior of a
% group of targets.
% characterize the dispersion in the detection efficiency curves of
% individual targets with respect to the detection efficiency curve for the
% ensemble
%==========================================================================
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

% Control
detectionEfficiencyModelName = 'L';
groupId = input('groupId: 1 (G stars) or 2 (K stars) 3 (M stars) 4 (G stars) 7 (GK stars) 8 (GKM stars) 9 (Group6 Gstars) : ');

% Match method: default is now tpsephem
matchMethod = 'epoch';%input('Match method: epoch(epoch-matching) or ephemeris(ephemeris-matching) or tpsephem(tps ephemeris matching) -- ','s');
% !!!!! NOTE-- 01 Oct 2015 changed from tpsephem to epoch.

% Load the tpsInjectionStruct
switch groupId
    
    case 1
        % Group 1 20 G stars
        dataDir = '/codesaver/work/transit_injection/detection_efficiency_curves/Group1/';
        % Get the fitted detection efficiency curves for the targets in this group
        load(strcat(dataDir,'detection-efficiency-',matchMethod,'-matching-generalized-logistic-function-model.mat'));
        % label
        groupLabel = strcat('Group',num2str(groupId));
        goodTargetIndicator = exitflagAll == true;
    case 2
        % Group 2 20 K stars
        dataDir = '/codesaver/work/transit_injection/detection_efficiency_curves/Group2/';
        % Get the fitted detection efficiency curves for the targets in this group
        load(strcat(dataDir,'detection-efficiency-',matchMethod,'-matching-generalized-logistic-function-model.mat'));
        % label
        groupLabel = strcat('Group',num2str(groupId));
        goodTargetIndicator = exitflagAll == true;
    case 3
        % Group 3 20 M stars (but exclude the three which have bad
        % detection efficiency curves
        dataDir = '/codesaver/work/transit_injection/detection_efficiency_curves/Group3/';
        % Get the fitted detection efficiency curves for the targets in this group
        load(strcat(dataDir,'detection-efficiency-',matchMethod,'-matching-generalized-logistic-function-model.mat'));
        % label
        groupLabel = strcat('Group',num2str(groupId));
        goodTargetIndicator = exitflagAll == true;
    case 4
        % Group 4 20 G stars
        dataDir = '/codesaver/work/transit_injection/detection_efficiency_curves/Group4/';
        % Get the fitted detection efficiency curves for the targets in this group
        load(strcat(dataDir,'detection-efficiency-',matchMethod,'-matching-generalized-logistic-function-model.mat'));
        % label
        groupLabel = strcat('Group',num2str(groupId));
        goodTargetIndicator = exitflagAll == true;
    case 7
        % Combine Group1 20 G stars with Group 2 20 K stars
        
        % Group1
        dataDir = '/codesaver/work/transit_injection/detection_efficiency_curves/Group1/';
        
        % Get the fitted detection efficiency curves for the targets in this group
        load(strcat(dataDir,'detection-efficiency-',matchMethod,'-matching-generalized-logistic-function-model.mat'));
        
        % G stars data
        detectionEfficiencyAllG = detectionEfficiencyAll;
        nDetectedAllG = nDetectedAll;
        nMissedAllG = nMissedAll;
        goodTargetIndicatorG = exitflagAll == true;
        
        % Group 2
        dataDir = '/codesaver/work/transit_injection/detection_efficiency_curves/Group2/';
        
        % Get the fitted detection efficiency curves for the targets in this group
        load(strcat(dataDir,'detection-efficiency-',matchMethod,'-matching-generalized-logistic-function-model.mat'));
        
        % K stars data
        detectionEfficiencyAllK = detectionEfficiencyAll;
        nDetectedAllK = nDetectedAll;
        nMissedAllK = nMissedAll;
        goodTargetIndicatorK = exitflagAll == true;
       
        % GK stars data
        detectionEfficiencyAll = [detectionEfficiencyAllG,detectionEfficiencyAllK];
        nDetectedAll = [nDetectedAllG,nDetectedAllK];
        nMissedAll = [nMissedAllG,nMissedAllK];
        goodTargetIndicator = [goodTargetIndicatorG;goodTargetIndicatorK];
        
        
        % Label
        groupLabel = strcat('Group1&2');
        dataDir = '/codesaver/work/transit_injection/detection_efficiency_curves/Group1and2/';    
    case 8
        % Combine Group1 20 G stars with Group 2 20 K stars and Group 3 17
        % M stars
        
        % Group1
        dataDir = '/codesaver/work/transit_injection/detection_efficiency_curves/Group1/';
        
        % Get the fitted detection efficiency curves for the targets in this group
        load(strcat(dataDir,'detection-efficiency-',matchMethod,'-matching-generalized-logistic-function-model.mat'));
        
        % G stars data
        detectionEfficiencyAllG = detectionEfficiencyAll;
        nDetectedAllG = nDetectedAll;
        nMissedAllG = nMissedAll;
        goodTargetIndicatorG = exitflagAll == true;
        
        % Group 2
        dataDir = '/codesaver/work/transit_injection/detection_efficiency_curves/Group2/';
        
        % Get the fitted detection efficiency curves for the targets in this group
        load(strcat(dataDir,'detection-efficiency-',matchMethod,'-matching-generalized-logistic-function-model.mat'));
        
        % K stars data
        detectionEfficiencyAllK = detectionEfficiencyAll;
        nDetectedAllK = nDetectedAll;
        nMissedAllK = nMissedAll;
        goodTargetIndicatorK = exitflagAll == true;
        
        % Group 3 
        dataDir = '/codesaver/work/transit_injection/detection_efficiency_curves/Group3/';
        
        % Get the fitted detection efficiency curves for the targets in this group
        load(strcat(dataDir,'detection-efficiency-',matchMethod,'-matching-generalized-logistic-function-model.mat'));
       
        % M stars data
        detectionEfficiencyAllM = detectionEfficiencyAll;
        nDetectedAllM = nDetectedAll;
        nMissedAllM = nMissedAll;
        goodTargetIndicatorM = exitflagAll == true;
        
        % GKM stars data
        detectionEfficiencyAll = [detectionEfficiencyAllG,detectionEfficiencyAllK,detectionEfficiencyAllM];
        nDetectedAll = [nDetectedAllG,nDetectedAllK,nDetectedAllM];
        nMissedAll = [nMissedAllG,nMissedAllK,nMissedAllM];
        goodTargetIndicator = [goodTargetIndicatorG;goodTargetIndicatorK;goodTargetIndicatorM];
        
        
        % Label
        groupLabel = strcat('Group1&2&3');
        dataDir = '/codesaver/work/transit_injection/detection_efficiency_curves/Group1and2and3/';    

    case 9
        % Group 6 20 M stars
        dataDir = '/codesaver/work/transit_injection/detection_efficiency_curves/Group6/';
        % Get the fitted detection efficiency curves for the targets in this group
        % label
        groupLabel = 'Group6';
        load(strcat(dataDir,groupLabel,'-detection-efficiency-',matchMethod,'-matching-generalized-logistic-function-model.mat'));
        goodTargetIndicator = exitflagAll == true;
end

% Data for ensemble detection efficiency curve
% Select only targets with good detection efficiency curves
nDetectedAll = nDetectedAll(:,goodTargetIndicator);
nMissedAll = nMissedAll(:,goodTargetIndicator);
detectionEfficiencyAll = detectionEfficiencyAll(:,goodTargetIndicator);

nDetectedGroup = mean(nDetectedAll,2);
nMissedGroup = mean(nMissedAll,2);
detectionEfficiencyGroup = nDetectedGroup./(nDetectedGroup+nMissedGroup);
nTargets = size(nDetectedAll,2);
if(groupId == 9)
    nTarges = 19;
end
%==========================================================================
% Fit ensemble  detection efficiency curve
tic
fprintf('Fitting the group detection efficiency curve\n')
fprintf('Optimizing starting point ...\n');
% Grid of starting points
nGrid = 10;
x1grid = 1*rand(1,nGrid);
x2grid = 10*rand(1,nGrid);
switch detectionEfficiencyModelName
    case 'G'
        x3grid = 4+rand(1,nGrid);
        detectionEfficiencyModelLabel = 'gamma-cdf';
        costFunction = @(x) sum( (detectionEfficiencyGroup - gamcdf(midMesBin'- x(3),x(1),x(2))).^2 );
    case 'L'
        % costGeneralizedLogistic = @(x) sum ( ( detectionEfficiency -  1./(1+exp(-x(1).*(midMesBin'-x(2))) ).^x(3) ).^2 );
        x3grid = 4*rand(1,nGrid);
        detectionEfficiencyModelLabel = 'generalized-logistic-function';
        generalizedLogisticFunction = @(x) 1./(1+exp(-x(1).*(midMesBin'-x(2)))).^x(3);
        costFunction = @(x)sum ( ( detectionEfficiencyGroup -  generalizedLogisticFunction(x) ).^2 );
end

% Initialize
optOrig = optimset('fminsearch');
optNew = optimset(optOrig,'TolFun',1.e-4,'TolX',1.e-4,'MaxFunEvals',2000,'MaxIter',1000);
options = optimset(optNew);
fvalOut = zeros(nGrid,nGrid,nGrid);
for ii = 1:nGrid
    for jj = 1:nGrid
        for kk = 1:nGrid
            
            % Starting parameters
            x0 = [x1grid(ii), x2grid(jj), x3grid(kk)];
            
            % Fit the model function
            [~,fval,exitflag] = fminsearch(costFunction,x0,options);
            
            % Cost function for this trial
            fvalOut(ii,jj,kk) = fval;
            
        end % loop over kk
    end % loop over jj
end % loop over ii

% Starting point corresponding to lowest cost function
[MM, II] = min(fvalOut(:));
[IX,IY,IZ] = ind2sub([nGrid,nGrid,nGrid],II);

% Best starting point
x0 = [x1grid(IX),x2grid(IY),x3grid(IZ)];

% Fit the model function using best starting point
toc
fprintf('Fitting the group detection efficiency curve...\n')
[x,fval,exitflag,output] = fminsearch(costFunction,x0,options);
switch detectionEfficiencyModelName
    case 'G'
        fprintf('exitflag %d fval %8.4f, fitted gamma parameters: A = %8.4f, B = %8.4f, offset = %8.4f\n\n',exitflag,fval,x(1),x(2),x(3))
        detectionEfficiencyModel = gamcdf(midMesBin - x(3),x(1),x(2));
        legendString2 = sprintf('Gamma CDF: A%8.4f, B%8.4f, Offset%8.4f',x(1),x(2),x(3));
    case 'L'
        fprintf('exitflag %d fval %8.4f, fitted logistic parameters: x1 = %8.4f, x2 = %8.4f, x3 = %8.4f \n\n',exitflag,fval,x(1),x(2),x(3))
        detectionEfficiencyModel = generalizedLogisticFunction([x(1),x(2),x(3)]);
        legendString2 = sprintf('Generalized Logistic Function: A%8.4f, B%8.4f, C%8.4f',x(1),x(2),x(3));
end

% Deviation
deviation = repmat(detectionEfficiencyGroup,1,nTargets) - detectionEfficiencyAll;

% Model deviation
modelDeviation = repmat(detectionEfficiencyModel,1,nTargets) - detectionEfficiencyAll;

% Fitted model ensemble detection efficiency curve vs. detection efficiency curves of
% individual stars
figure
hold on
grid on
box on
% plot(midMesBin,detectionEfficiencyGroup,'k*','LineWidth',2)
plot(midMesBin,detectionEfficiencyModel,'k-','LineWidth',2)
for iTarget = 1:nTargets
    plot(midMesBin,detectionEfficiencyAll(:,iTarget),'r.')
end
axis([3,18,0,1.5])
titleString = sprintf('%s fitted model detection efficiency vs. \ndetection efficiencies for individual stars',groupLabel);
title(titleString)
xlabel('Multiple Event Statistic')
ylabel('Detected Fraction')
set(gca,'FontSize',12)
set(findall(gcf,'type','text'),'FontSize',12)
legendString = sprintf('Model: Generalized Logistic Function\n(1+exp(-A*(x-B)))^{-C}\nA = %8.4f, B = %8.4f, C = %8.4f',x(1),x(2),x(3));
legend(legendString,'Individual stars','Location','NorthWest')
plotName = strcat(dataDir,groupLabel,'-model-detection-efficiency-curve');
print('-r150','-dpng',plotName)


% Dispersion of individual target detection efficiency curves around
% ensemble detection efficiency curve
figure
hold on
grid on
box on
for iTarget = 1:nTargets
    plot(midMesBin,deviation(:,iTarget),'r.')
end
set(gca,'FontSize',12)
set(findall(gcf,'type','text'),'FontSize',12)
title([groupLabel,' Deviation: ensemble detection efficiency - target detection efficiency'])
xlabel('Multiple Event Statistic')
ylabel('Detected Fraction')
axis([3,18,-inf,0.02 + max(max(abs(deviation),[],2))])
legendString = sprintf('mean median abs deviation = %7.3f\nmax abs deviation = %7.3f',mean(median(abs(deviation),2)),max(max(abs(deviation),[],2)) );
legend(legendString,'Location','NorthEast')
plotName = strcat(dataDir,groupLabel,'-scatter-about-ensemble-detection-efficiency-curve');
print('-r150','-dpng',plotName)

% Dispersion of individual target detection efficiency curves around
% model detection efficiency curve
figure
hold on
grid on
box on
for iTarget = 1:nTargets
    plot(midMesBin,deviation(:,iTarget),'b.')
end
set(gca,'FontSize',12)
set(findall(gcf,'type','text'),'FontSize',12)
title([groupLabel,' Deviation: model detection efficiency - target detection efficiency'])
xlabel('Multiple Event Statistic')
ylabel('Detected Fraction')
axis([3,18,-inf,0.02 + max(max(abs(modelDeviation),[],2))])
legendString = sprintf('mean median abs deviation = %7.3f\nmax abs deviation = %7.3f',mean(median(abs(modelDeviation),2)),max(max(abs(modelDeviation),[],2)) );
legend(legendString,'Location','NorthEast')
plotName = strcat(dataDir,groupLabel,'-scatter-about-model-detection-efficiency-curve');
print('-r150','-dpng',plotName)
