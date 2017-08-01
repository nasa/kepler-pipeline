% synthesize_detection_efficiency_curves.m
% Run this after
% compare_detection_efficiency_curves.m, or
% model_detection_efficiency_data.m
%==========================================================================
% Fit detection efficiency at each MES bin to a quadratic model with
% CDPPslope and whitening coefficient ratio
% Use this model to predict the detection efficiency curve for each target given its Teff.
% Can also make the model independent of the target using leave-one-out-cross-validation
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

% Number of targets
nTargets = length(keplerId);
inds = 1:nTargets;

% Option to exclude the 'bad' target with keplerId = 9898170 ( target #5 in the oct 28th run )
% Hardwired to OFF
excludeKIC9898170 = false;
if(excludeKIC9898170)
    inds = inds(keplerId~=9898170);
end
nTargets = length(inds);

% Control parameters
% lowerMetricMesBinIndex = 13; % MES 6.125
% upperMetricMesBinIndex = 41; % 13.125
lowerMetricMesBinIndex = 20; % MES 7.875
upperMetricMesBinIndex = 20; % MES 7.875

% Data directory for writing detection efficiency data and curves
dataDir = '/codesaver/work/transit_injection/detection_efficiency_curves/composite/';

% Option to plot model parameters vs MES bin
plotModelParameters = false;

% Construct detection efficiency curve for each of the  good stars
% Option to do Leave-one-out cross-validation
modelType = input('L(LeaveOneOutCrossValidation) A(UseAllTargets) S(Median of empirical det eff) -- ','s');
modelLabel = input('Model? C (quadratic cdppSlope), CW (quadratic in both CDPP slope and in log(WC6/WC1) ) -- ','s' );
if(strcmp(modelLabel,'CW'))
    modelString = 'Quadratic in both CDPP slope and log(WC6/WC1)';
elseif(strcxnp(modelLabel,'C'))
    modelString = 'Quadratic in CDPP slope';
end

% Empirically measured detection efficiency -- double [ nTargets x nBins ]
% Currently this is for the 40 star deep runs
% -- from compile_detection_efficiency_curves.m
detectionEfficiencyEmpirical = detectionEfficiency(inds,:);

% Option to use mean fitted parameters over all targets as the model
useMeanModelParameters = false; %logical(input('Use mean model parametes over all target stars -- 0 or 1 -- '));

switch modelType
    
    case 'L'
        
        % Leave-one-out cross-validation: exclude from the parameter fit
        % the target for which we want the detection efficiency curve
        
        % Label for plot caption
        captionLabel = sprintf('Model: %s\nLeave-One-Out Cross-Validation:\nModel for each target uses all %d other targets',modelString,nTargets-1);
        
        % Label for plot file name
        plotLabel = '_LOOC';
        
        % Loop over targets: for each target, compute a detection efficiency
        % model from all the other good targets
        detectionEfficiencyModel = zeros(nTargets,length(midMesBin));
        detectionEfficiencyModel1 = zeros(nTargets,length(midMesBin));
        detectionEfficiencyModel2 = zeros(nTargets,length(midMesBin));
       
        if(strcmp(modelLabel,'C'))
            params = zeros(nTargets,3,length(midMesBin));
        elseif(strcmp(modelLabel,'CW'))
            params = zeros(nTargets,5,length(midMesBin));
        end
        for iTarget = 1:nTargets
            
            % Use all the *other* stars to fit the detection efficiency model: i.e. exclude only the current target
            % useTargetIdx = keplerId ~= 9898170 & keplerId ~= keplerId(inds(iTarget));
            % Adopting model that is quadratic in cdppSlope and linear in
            % log(WC6/WC1)
            useTargetIdx = keplerId ~= keplerId(inds(iTarget));
            keplerIdModel = keplerId(useTargetIdx);
            nTargetsModel = length(keplerIdModel);
            ONES = ones(nTargetsModel,1);
            PREDICTOR1 = cdppSlope(useTargetIdx);
            PREDICTOR2 = log10(medianWhiteningCoefficients(useTargetIdx,6)./medianWhiteningCoefficients(useTargetIdx,1));
            
            xx = log10(medianWhiteningCoefficients(:,6)./medianWhiteningCoefficients(:,1));
            
            if(strcmp(modelLabel,'C'))
                designMatrix = [ONES, PREDICTOR1, PREDICTOR1.^2];
            elseif(strcmp(modelLabel,'CW'))
                designMatrix = [ONES, PREDICTOR1, PREDICTOR1.^2, PREDICTOR2, PREDICTOR2.^2];
            end
            
            % Model: detectionEfficiency(bin,iTarget) = A0(bin) + A1(bin)*PREDICTOR1(iTarget) + A2(bin)*PREDICTOR1(iTarget).^2 + A3(bin)*PREDICTOR2(iTarget);
            % so that pinv(designMatrix)*detectionEfficiency(bin,iTarget) =
            % [A0(bin) ; A1(bin); A2(bin); A3(bin)]
            % Fit the model
            params(iTarget,:,:) = pinv(designMatrix)*detectionEfficiencyEmpirical(useTargetIdx,:);
            
            % Fitted detection efficiency curve for this target: quadratic
            % model
            if(strcmp(modelLabel,'C'))
                detectionEfficiencyModel(iTarget,:) = [ 1, cdppSlope(inds(iTarget)), cdppSlope(inds(iTarget)).^2]*squeeze(params(iTarget,:,:));
            elseif(strcmp(modelLabel,'CW'))
                detectionEfficiencyModel1(iTarget,:) = [ 1, cdppSlope(inds(iTarget)), cdppSlope(inds(iTarget)).^2, log10(medianWhiteningCoefficients(inds(iTarget),6)./medianWhiteningCoefficients(inds(iTarget),1)), log10(medianWhiteningCoefficients(inds(iTarget),6)./medianWhiteningCoefficients(inds(iTarget),1)).^2  ]*squeeze(params(iTarget,:,:));
            end
        end % loop over target stars
        
        % Use mean of fitted parameters over *all* the targets to make the model
        for iTarget = 1:nTargets
            if(strcmp(modelLabel,'CW'))
                detectionEfficiencyModel(iTarget,:) = [ 1, cdppSlope(inds(iTarget)), cdppSlope(inds(iTarget)).^2, log10(medianWhiteningCoefficients(inds(iTarget),6)./medianWhiteningCoefficients(inds(iTarget),1)), log10(medianWhiteningCoefficients(inds(iTarget),6)./medianWhiteningCoefficients(inds(iTarget),1)).^2  ]*squeeze(mean(params));
            end
        end
        
    case 'A'
        
        % Use the all the good stars in the model
        
        % Label for plot
        captionLabel = ['Fitted model using all ',num2str(nTargets),' targets'];
        
        % Label for plot file name
        plotLabel = '_noLOOC';
        
        % Build the design matrix
        
        % Quadratic Model:
        % detectionEfficiency(bin,iTarget) = A0(bin) + A1(bin)*PREDICTOR(iTarget) + A2(bin)*PREDICTOR(iTarget)^2;
        keplerIdModel = keplerId(inds);
        nTargetsModel = length(keplerIdModel);
        ONES = ones(nTargetsModel,1);
        PREDICTOR = cdppSlope(inds);
        designMatrix = [ONES,PREDICTOR, PREDICTOR.^2];
        
        % Fit the model
        params = pinv(designMatrix)*detectionEfficiencyEmpirical;
        
        % Fitted detection efficiency curves for all targets
        detectionEfficiencyModel = designMatrix*params;
        
    case 'S'
        
        % Sanity check -- use *median* empirical detection efficiency as model
        
        % Label for plot
        captionLabel = ['Model is median empirical detection efficiency of all ',num2str(nTargets),' targets'];
        
        % Label for plot file name
        plotLabel = '_sanity_check';
        
        
        % Sanity check -- use median empirical detection efficiency as model
        detectionEfficiencyModel = repmat(median(detectionEfficiencyEmpirical),nTargets,1);
        
end % switch modelType

%==========================================================================
% Save the model coefficients in a file
% Average model coefficients over target stars in each MES bin
modelParamsVsMes = squeeze(mean(params));

% Make a table of averaged model coefficients
% The table has 88 rows (one for each MES bin) with 4 columns
% Column 1 is MES,
% Column 2 is offset,
% Column 3 is cddp slope linear coeff
% Column 4 is cdpp slope quadratic coefficient
% Column 5 is wavelet linear coeff
% Column 6 is wavelet quadratic coeff
parameterTable = [midMesBin' modelParamsVsMes'];

% Write the table to a file
dlmwrite(strcat(dataDir,'detection_efficiency_model_table.csv'),parameterTable,'precision','%20.15f');
    


%==========================================================================
% Clean up the detection efficiency model: if deteff < 0 set to 0, if deteff > 1 set to 1
idxGtZero = detectionEfficiencyModel(:) > 1;
idxLtZero = detectionEfficiencyModel(:) < 0;
detectionEfficiencyModel(idxGtZero) = 1;
detectionEfficiencyModel(idxLtZero) = 0;
% fprintf('Target %d has CDPPslope of %6.2f, and has %d bins with deteff < 0, %d bins with deteff > 1\n',iTarget,cdppSlope(iTarget),sum(idxLtZero),sum(idxGtZero));

%==========================================================================
% Model vs. empirical detection efficiency
% colors = 'rgbkmrgbkm';
plotModel = true;
if(plotModel)
    
    for jTarget = 1:nTargets
        figure
        hold on
        box on
        grid on
        
        % Dummy plot, to set legend color
        plot(0, 0 ,'k-','LineWidth',1)
        plot(0, 0 ,'r-','LineWidth',1)
        plot(midMesBin, detectionEfficiencyModel(jTarget,:),'k-','LineWidth',2)
        % plot(midMesBin, detectionEfficiencyModel1(jTarget,:),'k-','LineWidth',2)
        % The combined model is better in general
        % plot(midMesBin, detectionEfficiencyModel2(jTarget,:),'b-','LineWidth',2)
        plot(midMesBin, detectionEfficiencyEmpirical(jTarget,:),'r.-','LineWidth',1)
        xlabel('MES')
        ylabel('Detection efficiency')
        titleString = sprintf('Fitted vs. empirical detection efficiency for keplerId %d\n%s',keplerId(jTarget),captionLabel);
        title(titleString)
        axis([min(midMesBin),max(midMesBin),0,1.2])
        legend('Model Detection Efficiency','Empirical Detection Efficiency','Location','Best')
        set(gca,'FontSize',12)
        set(findall(gcf,'type','text'),'FontSize',12)
        plotName = strcat(dataDir,'fitted_vs_empirical_detection_efficiency_keplerId',num2str(keplerId(jTarget)),plotLabel);
        print('-r150','-dpng',plotName)
        
    end
end

%==========================================================================
% Deviations of model detection efficiency from truth (empirical detection
% efficiency)

% Model residuals
deviations = detectionEfficiencyEmpirical - detectionEfficiencyModel;
plotDeviations = true;
if(plotDeviations)
    
    figure
    titleString = sprintf('Empirical detection efficiency minus fitted model\n%s',captionLabel);
    title(titleString)
    hold on
    box on
    grid on
    
    
    % Dummy plot, to set legend color
    plot(midMesBin, deviations(1,:) ,'b.','LineWidth',1)
    plot(midMesBin, deviations(1,:) ,'r.','LineWidth',1)
    
    for jTarget = 1:nTargets
        plot(midMesBin, deviations(jTarget,:) ,'b.','LineWidth',1)
    end
    
    % Plot median deviations
    plot(midMesBin, median(deviations),'r-','LineWidth',2)
    xlabel('MES Bin')
    ylabel('residual detection efficiency')
    axis([min(midMesBin),max(midMesBin),-0.25,0.30])
    set(gca,'FontSize',12)
    set(findall(gcf,'type','text'),'FontSize',12)
    legend(['Residuals (median|resid|=',num2str(median(abs(deviations(:,29))),'%7.3f'),', max|resid|=',num2str(max(abs(deviations(:,29))),'%7.3f'),' at MES 10.125)'],'Median residuals','Location','Best');
    plotName = strcat(dataDir,'empirical_minus_fitted_detection_efficiency',plotLabel);
    print('-r150','-dpng',plotName)
    
end



%==========================================================================
% Mean absolute deviations of model from truth
plotAbsDev = false;
if(plotAbsDev)
    figure
    titleString = sprintf('Mean absolute residual: Empirical detection efficiency minus fitted model\n%s',captionLabel);
    title(titleString)
    hold on
    box on
    grid on
    plot(midMesBin, mean(abs(deviations)) ,'r.-','LineWidth',2)
    xlabel('MES Bin')
    ylabel('Mean( |residual detection efficiency| ) in MES Bin')
    axis([min(midMesBin),max(midMesBin),-inf,inf])
    set(gca,'FontSize',12)
    set(findall(gcf,'type','text'),'FontSize',12)
    plotName = strcat(dataDir,'mean_absolute_residual_detection_efficiency',plotLabel);
    % axis([-inf, inf, 0, 0.05])
    legendString = sprintf('Median(mean abs deviation in bin)  = %7.2f\nMax(mean abs deviation in bin) = %7.2f\nMES = %7.2f',median(mean(abs(deviations(:,lowerMetricMesBinIndex:upperMetricMesBinIndex)))),max(mean(abs(deviations))),midMesBin(lowerMetricMesBinIndex));
    legend(legendString, 'Location','Best' );
    print('-r150','-dpng',plotName)
end

% RMS deviations of model from truth
plotRmsDev = false;
if(plotRmsDev)
    figure
    titleString = sprintf('RMS residual: Empirical detection efficiency minus fitted model\n%s',captionLabel);
    title(titleString)
    hold on
    box on
    grid on
    plot(midMesBin, sqrt(mean(deviations.^2)) ,'k.-','LineWidth',2)
    xlabel('MES Bin')
    ylabel('RMS residual detection efficiency in MES Bin')
    axis([min(midMesBin),max(midMesBin),-inf,inf])
    set(gca,'FontSize',12)
    set(findall(gcf,'type','text'),'FontSize',12)
    legendString = sprintf('Median(RMS deviation in bin) = %7.2f\nMax(RMS deviation in bin) = %7.2f\nMES = %7.2f',median(sqrt(mean(deviations(:,13:41).^2))),max(sqrt(mean(deviations.^2))),midMesBin(lowerMetricMesBinIndex));
    legend(legendString, 'Location','Best');
    plotName = strcat(dataDir,'rms_residual_detection_efficiency',plotLabel);
    print('-r150','-dpng',plotName)
end


%==========================================================================
% Deviation of model from truth
figure
% title(sprintf('Detection efficiency deviations\n empirical det. eff. minus predicted det. eff.\n for %d stars, shallow test run1',nTargetsModel))
titleString = sprintf('Residual: empirical detection efficiency minus fitted model\n%s',captionLabel);
hold on
box on
grid on

% dummy plot statements to get legend in right order
plot(-1,-1,'k')
plot(-1,-1,'b')
plot(-1,-1,'r')
plot(-1,-1,'m')

plot(midMesBin, deviations,'k.')
plot(midMesBin, median(abs(deviations)) ,'r-','LineWidth',2)
plot(midMesBin, sqrt(mean(deviations.^2)) ,'b-','LineWidth',2)
plot(midMesBin, median(deviations),'m-','LineWidth',2)

xlabel('MES')
ylabel('Measure of detection efficiency deviation')
axis([min(midMesBin),max(midMesBin),-inf,inf])
set(gca,'FontSize',12)
set(findall(gcf,'type','text'),'FontSize',12)
axis([min(midMesBin),max(midMesBin),-0.2,0.2])
plotName = strcat(dataDir,'residual_detection_efficiency',plotLabel);
legend('median |deviation|','rms deviation','median deviation','deviations, all stars','Location','NorthEast')
print('-r150','-dpng',plotName)

%==========================================================================
% Quadratic Model parameters
param1 = squeeze(params(:,1,:));
param2 = squeeze(params(:,2,:));
param3 = squeeze(params(:,3,:));
if(strcmp(modelLabel,'CW'))
    param4 = squeeze(params(:,4,:));
    param5 = squeeze(params(:,5,:));
end

%==========================================================================
% Quadratic model parameters vs bin for each target
if(plotModelParameters)
    
    % param1
    figure
    hold on
    grid on
    box on
    for iTarget = 1:nTargets
        plot(midMesBin,param1(iTarget,:),'k.-')
        
    end
    title('Quadratic Model Parameter 1 -- constant offset')
    xlabel('MES Bin')
    ylabel('Amplitude [units of detection efficiency]')
    set(gca,'FontSize',12)
    set(findall(gcf,'type','text'),'FontSize',12)
    plotName = strcat(dataDir,'model_parameter1',plotLabel);
    print('-r150','-dpng',plotName)
    
    
    % param2
    figure
    hold on
    grid on
    box on
    for iTarget = 1:nTargets
        plot(midMesBin,param2(iTarget,:),'r.-')
    end
    title('Quadratic Model Parameter 2 -- slope')
    xlabel('MES Bin')
    ylabel('Amplitude')
    set(gca,'FontSize',12)
    set(findall(gcf,'type','text'),'FontSize',12)
    plotName = strcat(dataDir,'model_parameter2',plotLabel);
    print('-r150','-dpng',plotName)
    
    
    % param3
    figure
    hold on
    grid on
    box on
    for iTarget = 1:nTargets
        plot(midMesBin,param4(iTarget,:),'b.-')
        
    end
    title('Quadratic Model Parameter 4 -- wavelet coeff 6 linear multiplier')
    xlabel('MES Bin')
    ylabel('Amplitude')
    set(gca,'FontSize',12)
    set(findall(gcf,'type','text'),'FontSize',12)
    plotName = strcat(dataDir,'model_parameter4',plotLabel);
    print('-r150','-dpng',plotName)
    
    
    % param4
    if(strcmp(modelLabel,'CW'))
        
        figure
        hold on
        grid on
        box on
        for iTarget = 1:nTargets
            plot(midMesBin,param4(iTarget,:),'b.-')
            
        end
        title('Quadratic Model Parameter 5 -- wavelet coeff 6 quadratic multiplier')
        xlabel('MES Bin')
        ylabel('Amplitude')
        set(gca,'FontSize',12)
        set(findall(gcf,'type','text'),'FontSize',12)
        plotName = strcat(dataDir,'model_parameter4',plotLabel);
        print('-r150','-dpng',plotName)
        
        figure
        hold on
        grid on
        box on
        for iTarget = 1:nTargets
            plot(midMesBin,param5(iTarget,:),'b.-')
            
        end
        title('Quadratic Model Parameter 5 -- wavelet coeff 6 quadratic multiplier')
        xlabel('MES Bin')
        ylabel('Amplitude')
        set(gca,'FontSize',12)
        set(findall(gcf,'type','text'),'FontSize',12)
        plotName = strcat(dataDir,'model_parameter4',plotLabel);
        print('-r150','-dpng',plotName)
    end
    
    
    
    %==========================================================================
    % Scatter in quadratic model parameters
    
    % param1 scatter (over targets) vs. bin
    figure
    hold on
    grid on
    box on
    plot(midMesBin,std(param1(:,:)),'k.-')
    
    % param2 scatter (over targets) vs. bin
    plot(midMesBin,std(param2(:,:)),'r.-')
    
    % param3 scatter (over targets) vs. bin
    plot(midMesBin,std(param3(:,:)),'b.-')
    
    if(strcmp(modelLabel,'CW'))
        
        % param4 scatter (over targets) vs. bin
        plot(midMesBin,std(param4(:,:)),'b.-')
        
        % param5 scatter (over targets) vs. bin
        plot(midMesBin,std(param4(:,:)),'b.-')
    end
    
    
    title('Scatter (std dev across targets) of Quadratic Model Parameters')
    xlabel('MES Bin')
    ylabel('Amplitude')
    if(strcmp(modelLabel,'C'))
        legend('Parameter1','Parameter2','Parameter3')
    elseif(strcmp(modelLabel,'CW'))
        legend('Parameter1','Parameter2','Parameter3','Parameter4','Parameter5')
    end
    set(gca,'FontSize',12)
    set(findall(gcf,'type','text'),'FontSize',12)
    plotName = strcat(dataDir,'quadratic_model_parameter_scatter',plotLabel);
    print('-r150','-dpng',plotName)
    
    
    
end % plotModelParameters


% Plot all empirical detection efficiency curves
plotAllEmpiricalDetectionEfficiencyCurves = true;
if(plotAllEmpiricalDetectionEfficiencyCurves)
    figure
    hold on
    grid on
    box on
    
    for iTarget = 1:nTargets
        plot(midMesBin,detectionEfficiencyEmpirical(iTarget,:),'r-')
        
    end
end

title('Empirical Detection Efficiency Curves for 40 Deep FLTI targets')
xlabel('MES')
ylabel('detection efficiency')
set(gca,'FontSize',12)
set(findall(gcf,'type','text'),'FontSize',12)
plotName = strcat(dataDir,'empirical_detection_efficiency_all',plotLabel);
print('-r150','-dpng',plotName)



% Wavelet coefficients
logWc6Ratio = log10(medianWhiteningCoefficients(:,6)./medianWhiteningCoefficients(:,1));
figure
hold on
grid on
box on
for iTarget = 1:40
plot( log10(medianWhiteningCoefficients(iTarget,:)./repmat(medianWhiteningCoefficients(iTarget,1),1,11)) )
end
title('Wavelet coefficients for 40 Deep FLTI targets')
xlabel('Scale')
ylabel('log10(waveletCoeff/waveletCoeff1)')
set(gca,'FontSize',12)
set(findall(gcf,'type','text'),'FontSize',12)
plotName = strcat(dataDir,'wavelet_coefficients_all',plotLabel);
print('-r150','-dpng',plotName)


% Look at deviations
maxAbsDev = zeros(nTargets,1);
for iTarget = 1:nTargets
    maxAbsDev(iTarget,1) = max(abs(deviations(iTarget,:)));
end

% !!!!! Need to save the model parameters: 88 bins @ 5 parameters per bin

