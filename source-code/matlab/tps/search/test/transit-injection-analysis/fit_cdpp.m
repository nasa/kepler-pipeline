function [class1Idx, class2Idx, params] = fit_cdpp(rmsCdpp,pulseDurations,nClasses)

% fit log duration vs. log cdpp to quadratic model 
% kmeans cluster analysis
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


% Initialize

% Control parameters
plotDiagnostics = false;
nPulses = 6;

% Last 6 pulses only for linear model
rmsCdpp = rmsCdpp(:,end-nPulses+1:end);
pulseDurations = pulseDurations(:,end-nPulses+1:end);


% Data from tps-dawg-struct
dataDir = '/codesaver/work/transit_injection/cluster_analysis/';

% Data array, normalized by median
nTargets = length(rmsCdpp);
data0 = log10(rmsCdpp)';
medianData0 = repmat(median(data0),nPulses,1);
data = (data0-medianData0)./medianData0;

% Build design matrix
[nStars,nPulses] = size(rmsCdpp);
ONES = ones(nPulses,1);
LOG10PULSEWIDTHS = log10(pulseDurations)';
SQUAREDLOG10PULSEWIDTHS = LOG10PULSEWIDTHS.^2;
designMatrix = [ONES, LOG10PULSEWIDTHS];% , SQUAREDLOG10PULSEWIDTHS];

% Solve quadratic model for rmsCdpp vs. pulse duration: data = a0 + a1*log10(pulsewidth) + a2*log(pulsewidth).^2;
% Solve linear model for rmsCdpp vs. pulse duration: data = a0 + a1*log10(pulsewidth);
params = pinv(designMatrix)*data;

% Fitted model of the data
estData = designMatrix*params;
estData0 = medianData0.*estData + medianData0;
estRmsCdpp = 10.^estData0';

% Visually check the model against the data
if(plotDiagnostics)
    
    figure
    hold on
    title('Comparison of data against model for the first 1000 stars')
    for iTarget = 1:min(1000,nTargets)
        loglog(pulseDurations,rmsCdpp(iTarget,:),'k-')
        hold on
        loglog(pulseDurations,estRmsCdpp(iTarget,:),'r-')
    end
    
    % Model residuals
    resid = data - estData;
    rmsResid = sqrt(mean(resid.^2,1));
    figure
    hold on
    title('Residuals of parabolic model')
    hist(rmsResid)
    xlabel('rms residual')
    ylabel('Counts')
    
end

% Try kmeans on the log cdpp data
% nClasses = input('Number of classes for kmeans clustering -- ');
xx=data';
[IDX, CENT, SUMDIST] = kmeans(xx,nClasses,'Display','final','Replicates',5,'distance','correlation');

% Class indicators
class1Idx = IDX == 1;
class2Idx = IDX == 2;
class3Idx = IDX == 3;


% Silhouette measures how close each point is to its assigned cluster
nInclude = min(10000,nTargets);
figure;
[silh,~] = silhouette(xx(1:nInclude,:),IDX(1:nInclude),'correlation');
% h.Children.EdgeColor = [.8 .8 1];
xlabel 'Silhouette Value';
ylabel 'Cluster';
fprintf('Mean silhouette value for the first %d points is %6.2f\n',nInclude,mean(silh));

% Histogram of silhouette values
figure
hold on
hist(silh)
xlabel('Silhouette value ')
ylabel('Counts')
title(['Silhouette for the first ',num2str(nInclude),' of ',num2str(length(IDX)),' points'])

% Classes
colors = 'rgbkc';
for iClass = 1:nClasses
    classInds = 1:nStars;
    classInds = classInds(IDX==iClass);
    
    % CDPP vs. pulse duration for this class
    figure
    plot(log10(pulseDurations),data(:,classInds)',[colors(iClass),'-'])
    hold on
    box on
    grid on
    title(['Class #',num2str(iClass),' of ',num2str(nClasses),' ',num2str(sum(IDX==iClass)),' of ',num2str(length(IDX)),' stars'])
    xlabel('log10(Pulse Duration [hours])')
    ylabel('Normalized log10(cdpp [ppm])')
    legend(['Class ',num2str(iClass)])
    set(gca,'FontSize',12)
    set(findall(gcf,'type','text'),'FontSize',12)
    plotName = strcat(dataDir,['kmeans_class_',num2str(iClass)]);
    print('-r150','-dpng',plotName)
    
    if(plotDiagnostics)
        
        % Quadratic parameter for this class
        figure
        hold on
        box on
        grid on
        title(['Quadratic parameter, cluster ',num2str(iClass)])
        hist(paramsQuadratic(3,IDX==iClass),-.5:.01:.5)
        legend(['class ',num2str(iClass)])
        
        
        % Linear parameter for this class
        figure
        hold on
        box on
        grid on
        title(['Linear parameter, cluster ',num2str(iClass)])
        hist(paramsQuadratic(2,IDX==iClass),-.5:.01:.5)
        legend(['class ',num2str(iClass)])
        
        % Constant parameter for each class
        figure
        hold on
        box on
        grid on
        title(['Constant parameter, cluster ',num2str(iClass)])
        hist(paramsQuadratic(1,IDX==iClass),-.5:.01:.5)
        legend(['class ',num2str(iClass)])
        
        
        % Linear vs Quadratic parameter for this class
        figure
        hold on
        grid on
        box
        title(['Linear vs Quadratic parameter, cluster ',num2str(iClass)])
        plot(paramsQuadratic(2,IDX==iClass),paramsQuadratic(3,IDX==iClass),'r.')
        xlabel('Linear parameter')
        ylabel('Quadratic parameter')
        legend(['class ',num2str(iClass)])
    end
    
end

% Note: found that kmeans on fitted parameters doesn't do as good
% a job of separating classes
skip = true;
if(~skip)
    
    nClasses2 = input('Number of classes for kmeans clustering -- ');
    IDX2 = kmeans(paramsQuadratic',nClasses);
    
    % Classes
    for iClass = 1:nClasses
        figure
        plot(log10(pulseDurations),data(IDX2==iClass,:)',[colors(iClass),'-'])
        hold on
        box on
        grid on
        title(['class #',num2str(iClass),' of ',num2str(nClasses2),' ',num2str(sum(IDX2==iClass)),' of ',num2str(length(IDX2))])
        xlabel('log10(Pulse Duration [hours])')
        ylabel('Normalized log10(cdpp [ppm])')
        legend(['Class ',numx2str(iClass)])
        set(gca,'FontSize',12)
        set(findall(gcf,'type','text'),'FontSize',12)
    end
    
end % skip

