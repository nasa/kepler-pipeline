% predict_detection_efficiency_curves.m
% For a set of target stars, predict detection efficiency curves
% given cdpp slope and wavelet coefficients.
% Compare to empirical detection efficiency curves
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


%==========================================================================
% Initialize

plotDir2 = '/codesaver/work/transit_injection/detection_efficiency_curves/KSOC-5007-shallow-test1/';

% Data directory for writing detection efficiency data and curves
dataDir = '/codesaver/work/transit_injection/detection_efficiency_curves/composite/';

% Option to make detection efficiency plots for each star
makePlots = true;

% Choose model
modelLabel = 'CW'; % input('Model? C (quadratic cdppSlope), CW (quadratic in both CDPP slope and in log(WC6/WC1) ) -- ','s' );
if(strcmp(modelLabel,'CW'))
    modelString = 'Quadratic in both CDPP slope and log(WC6/WC1)';
elseif(strcxnp(modelLabel,'C'))
    modelString = 'Quadratic in CDPP slope';
end

% Label for plots
plotLabel = '_shallow_run_test1';

%==========================================================================
% Get the waveletCoefficients for selected list of keplerIds

% Get wavelet coefficients data for the shallow test run 1 -- got 95 stars
[keplerIdListWC6, medianWhiteningCoefficients0, whiteningCoefficients0] = get_wavelet_data('shallow98');

% log10 of wavelet coefficient #6 to wavelet coefficiency #1 ratio
log10WC6Ratio0 = log10(medianWhiteningCoefficients0(:,6)./medianWhiteningCoefficients0(:,1));

% Plot wavelet coefficients
figure
box on

for iTarget = 1:nTargetsModel
    
    semilogy(medianWhiteningCoefficients0(iTarget,:) )
    hold on
    
end
xlabel('wavelet coefficient index')
ylabel('wavelet coefficient value')
set(gca,'FontSize',12)
set(findall(gcf,'type','text'),'FontSize',12)
grid on
plotName = strcat(dataDir,'wavelet_coeffs_vs_scale_all_targets',plotLabel);
print('-dpng','-r150',plotName)



%==========================================================================
% Get the empirical detection efficiency curves

% This is the path to the file for KSOC-5007-shallow-test1
saveFileFullPathName = '/codesaver/work/transit_injection/detection_efficiency_curves/KSOC-5007-shallow-test1/KSOC-5007-shallow-test1-detection-efficiency-epoch-matching-generalized-logistic-function-model-period-20-to-730-days.mat';

% This is the command used to save the file
% save(saveFileFullPathName, ...
% 'detectionEfficiencyAll','nDetectedAll','nMissedAll','midMesBin', ...
% 'uniqueKeplerId','meanPeriodCutoffDueToWindowFunctionAll','periodLabel')

% Load the empirical detection efficiency data
load(saveFileFullPathName)

% Each row corresponds to a target star; each column to a midMesBin
detectionEfficiencyEmpirical0 = nDetectedAll'./(nDetectedAll' + nMissedAll');

% Column vector indicator for stars with non-NaN detection efficiency curves 
goodStarIdx = logical(sum(isnan(detectionEfficiencyEmpirical0),2)==0);

% Truncate detection efficiency to stars with non-NaN det eff curves
detectionEfficiencyEmpirical1 =  detectionEfficiencyEmpirical0(goodStarIdx,:);

nMissedAll1 = nMissedAll(:,goodStarIdx)';
nDetectedAll1 = nDetectedAll(:,goodStarIdx)';

% keplerIds of stars with non-NaN detection efficiency curves
keplerIdListEmpirical = uniqueKeplerId(goodStarIdx);



% Select stars that have non-NaN det eff curves and WC6
% Stars that have WC6 *and* good empirical detection efficiency curves
[selectedKeplerIdList, iA, iB] = intersect(keplerIdListEmpirical,keplerIdListWC6);



% Detection efficiency curves for selected stars
detectionEfficiencyEmpirical =  detectionEfficiencyEmpirical1(iA,:);
nMissed = nMissedAll1(iA,:);
nDetected = nDetectedAll1(iA,:);

% log10 WC6/WC1 for selected stars
log10WC6Ratio = log10WC6Ratio0(iB);




%==========================================================================
% Get the cdppSlope for selected list of keplerIds
% Load the completeStructArray with stellar parameters created by Chris Burke in KSO-416
if(~exist('completeStructArray','var'))
    fprintf('Loading completeStructArray...\n')
    load('/path/to/so-products-DR25/Complete_Seed_DR25_04-05-2016.mat');
end

% Get RA and DEC, other stellar parameters
RAall = [completeStructArray.new3ra]';
DECall = [completeStructArray.new3dec]';
new3rstarAll = [completeStructArray.new3rstar]';
new3teffAll = [completeStructArray.new3teff]';
new3loggAll = [completeStructArray.new3logg]';
new3ValidKicAll = [completeStructArray.new3ValidKic]';
kpmagAll = [completeStructArray.kpmag]';
keplerIdAll = [completeStructArray.keplerId]';


% Get RMS CDPP, dutyCycle and dataSpan for the 14 pulse durations
nTargets = length(completeStructArray);
nPulseDurations = length(completeStructArray(1).rmsCdpps2);
rmsCdpp2All = zeros(nTargets,nPulseDurations);
rmsCdpp1All = zeros(nTargets,nPulseDurations);
dataSpansAll = zeros(nTargets,nPulseDurations);
dutyCyclesAll = zeros(nTargets,nPulseDurations);
for iTarget = 1:nTargets
    rmsCdpp2All(iTarget,:) = [completeStructArray(iTarget).rmsCdpps2];
    rmsCdpp1All(iTarget,:) = [completeStructArray(iTarget).rmsCdpps1];
    dataSpansAll(iTarget,:) = [completeStructArray(iTarget).dataSpans1];
    dutyCyclesAll(iTarget,:) = [completeStructArray(iTarget).dutyCycles1];
end

% Match keplerIds to entries in keplerIdAll from completeStructArray,
% and cross-match to RA and DEC and other stellar parameters
[TF, indexInKeplerIdAll] = ismember(selectedKeplerIdList,keplerIdAll);
RA = RAall(indexInKeplerIdAll);
DEC = DECall(indexInKeplerIdAll);
new3rstar = new3rstarAll(indexInKeplerIdAll);
new3teff = new3teffAll(indexInKeplerIdAll);
new3logg = new3loggAll(indexInKeplerIdAll);
new3ValidKic = new3ValidKicAll(indexInKeplerIdAll);
kpmag = kpmagAll(indexInKeplerIdAll);
rmsCdpp2 = rmsCdpp2All(indexInKeplerIdAll,:);
rmsCdpp1 = rmsCdpp1All(indexInKeplerIdAll,:);


% Get cdpp slope for selectedKeplerIdList
% Modified: uses ordinary least squares instead of robust least squares
% cdppSlope is computed for the last 6 pulse durations [9:14] for consistency with
% Chris Burke
cdppSlope = get_cdpp_slope(rmsCdpp2,rmsCdpp1);

% Check
validRmsCdpp = false(size(cdppSlope));
for iTarget = 1:length(cdppSlope)
    validRmsCdpp(iTarget,1) = isreal(cdppSlope(iTarget,1));
end
fprintf('number of invalid RMS CDPP values is %d\n',sum(~validRmsCdpp))


%==========================================================================
% Construct the design matrix for the model

% Select targets with valid whitening coefficients
keplerIdModel = selectedKeplerIdList;
nTargetsModel = length(keplerIdModel);
ONES = ones(nTargetsModel,1);
PREDICTOR1 = cdppSlope;
PREDICTOR2 = log10WC6Ratio;

if(strcmp(modelLabel,'C'))
    designMatrix = [ONES, PREDICTOR1, PREDICTOR1.^2];
elseif(strcmp(modelLabel,'CW'))
    designMatrix = [ONES, PREDICTOR1, PREDICTOR1.^2, PREDICTOR2, PREDICTOR2.^2];
end

%==========================================================================
% Get the detection efficiency model parameters 
% dlmwrite(strcat(dataDir,'detection_efficiency_model_table.csv'),parameterTable,'precision','%20.15f');
parameterTable = dlmread(strcat(dataDir,'detection_efficiency_model_table.csv'));

% Get the model coefficients
modelCoefficients = parameterTable(:,2:end)';
midMesBinModel = parameterTable(:,1);

%==========================================================================
% Predict the detection efficiency curves
predictedDetectionEfficiency = designMatrix*modelCoefficients;



%==========================================================================
% Compare predicted with empirical detection efficiency curves
% Header should show the keplerId,cdppSlope, and log10(WC6/WC1)
% filename for plot should have keplerId
predictedDetectionEfficiencyEmpirical = zeros(nTargetsModel,length(midMesBin));
detEffError = zeros(nTargetsModel,length(midMesBin));
p = zeros(nTargetsModel,length(midMesBin));
q = zeros(nTargetsModel,length(midMesBin));
N = zeros(nTargetsModel,length(midMesBin));

for iTarget = 1:nTargetsModel
    
    % Interpolate predictedDetectionEfficiency for the MES grid used for the empirical detection
    % efficiency
    predictedDetectionEfficiencyEmpirical(iTarget,:) = interp1(midMesBinModel,predictedDetectionEfficiency(iTarget,:),midMesBin,'pchip');
    
    if(makePlots)
        figure
        hold on
        box on
        grid on
        
         
        % Predicted detection efficiency
        plot(midMesBin,predictedDetectionEfficiencyEmpirical(iTarget,:),'k.-')
        % plot(midMesBinModel,predictedDetectionEfficiency(iTarget,:),'k.-')
        
        % Binomial error bars
        % Ref: https://en.wikipedia.org/wiki/Binomial_proportion_confidence_interval
        % This is normal approximation, and rule of thumb says it's
        % valid for N*p > 5 and N*q > 5
        % So not valid for small counts and high or low detection
        % efficiency; in general need about 10 counts in a bin
        
        p(iTarget,:) = predictedDetectionEfficiencyEmpirical(iTarget,:);
        q(iTarget,:) = 1-p(iTarget,:);
        N(iTarget,:) = nMissed(iTarget,:) + nDetected(iTarget,:);
        detEffError(iTarget,:) = sqrt(p(iTarget,:).*q(iTarget,:)./N(iTarget,:));
        
        % Empirical detection efficiency with error bars
        lower = detEffError(iTarget,:);
        upper = detEffError(iTarget,:);
        errorbar(midMesBin,detectionEfficiencyEmpirical(iTarget,:),lower,upper,'r')
        
        set(gca,'FontSize',12)
        set(findall(gcf,'type','text'),'FontSize',12)
        title(['KIC ',num2str(selectedKeplerIdList(iTarget))])
        xlabel('Expected MES')
        ylabel('Detection Efficiency')
        legend('Predicted','Empirical, with error bars','Location','NorthWest')
        axis([0,max(midMesBin),0,1.3])
        plotName = strcat(plotDir2,'KIC-',num2str(keplerIdModel(iTarget)),periodLabel);
        print('-r150','-dpng',plotName)
        
    end % makePlots
    
end % loop over nTargetsModel

% Empirical minus Prediction deviations
deviations = detectionEfficiencyEmpirical - predictedDetectionEfficiencyEmpirical;
maxAbsDeviations = max(abs(deviations),[],2);






%==========================================================================
% Max abs deviations
figure
hold on
box on
grid on
hist(maxAbsDeviations,0:0.05:0.66)

% PDF of deviations at MES 9.5
figure
hold on
box on
grid on
hist(deviations(:,7),-0.6:0.05:0.2)


%==========================================================================
% Deviation of model from truth
figure
title(sprintf('Detection efficiency deviations\n empirical det. eff. minus predicted det. eff.\n for %d stars, shallow test run1',nTargetsModel))
hold on
box on
grid on
plot(midMesBin, median(abs(deviations)) ,'r-','LineWidth',2)
plot(midMesBin, sqrt(mean(deviations.^2)) ,'b-','LineWidth',2)
plot(midMesBin, median(deviations),'m-','LineWidth',2)
plot(midMesBin, deviations,'k.')

xlabel('MES')
% ylabel('Mean( |residual detection efficiency| ) in MES Bin')
ylabel('Measure of detection efficiency deviation')
axis([min(midMesBin),max(midMesBin),-inf,inf])
set(gca,'FontSize',12)
set(findall(gcf,'type','text'),'FontSize',12)
plotName = strcat(plotDir2,'residual_detection_efficiency',plotLabel);
% legend('mean abs dev','median abs dev', 'max abs dev' ,'rms dev','Location','Best')
legend('median |deviation|','rms deviation','median deviation','deviations, all stars','Location','SouthEast')
print('-r150','-dpng',plotName)

%==========================================================================
% Plot model deviations vs. log10(WC6/WC1)
figure
plot(log10WC6Ratio,deviations,'r.')


% Plot model deviations vs. cdppSlope
figure
plot(cdppSlope,deviations,'r.')


%==========================================================================
% Save the data


