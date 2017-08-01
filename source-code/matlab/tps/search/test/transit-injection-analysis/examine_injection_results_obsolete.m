% examine_injection_results.m
% load tpsInjectionStruct from injection run
% do some tests and plots
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

% this code is in
% /path/to/matlab/tps/search/test/transit-injection-analysis/

% Initialize
clear all
% close all

% Directory for test results
testDir = '/codesaver/work/transit_injection/test/';

% Load the tpsInjectionStruct from KSOC-4930
skip = true;
if(~skip)
    topDir = '/path/to/transitInjections/KSOC-4930/testRun_2_G_stars/tps-matlab-2015308/';
    % diagnosticDir = '/codesaver/work/transit_injection/diagnostics/KSOC-4930/';
    % load(strcat(topDir,'tps-injection-struct.mat'));
    load(strcat(topDir,'tps-injection-results-struct-local-10.mat'));
    tpsInjectionStruct = injectionOutputStruct;
    clear injectionOutputStruct
end


% results from local injection run with injection code modified as per KSOC-4958
skip = false;
if(~skip)
    % outputStructFile = strcat('/codesaver/work/transit_injection/test/KSOC-4930/','tps-output-struct-KSOC-4930-KIC-9898170-1500-injections.mat');
    outputStructFile = strcat('/codesaver/work/transit_injection/test/KSOC-4930_11Dec2015T124654/','tps-injection-results-struct-500-injections.mat');
  
    load(outputStructFile)
    
    tpsInjectionStruct = injectionOutputStruct;
    clear outputStruct;
end


% Choose keplerId
keplerId = tpsInjectionStruct.keplerId;
selectedKeplerId = input('KeplerId to select: 3114789 or 9898170 -- ');
% !!!!! injectionIdx = keplerId == selectedKeplerId;
injectionIdx = true(size(tpsInjectionStruct.rmsCdpp));

% Nececessary fields from tpsInjectionStruct
chiSquare2 = tpsInjectionStruct.chiSquare2(injectionIdx);                 % veto threshold = 7
robustStatistic = tpsInjectionStruct.robustStatistic(injectionIdx);       % veto threshold = 7
chiSquareGof = tpsInjectionStruct.chiSquareGof(injectionIdx);             % veto threshold = 6.8
chiSquareDof2 = tpsInjectionStruct.chiSquareDof2(injectionIdx);
chiSquareGofDof = tpsInjectionStruct.chiSquareGofDof(injectionIdx);
periodDays = tpsInjectionStruct.periodDays(injectionIdx);
% thresholdForDesiredPfa field is all -1's, so bootstrapOkay is always true
% in fold_statistics_and_apply_vetores.m
thresholdForDesiredPfa = tpsInjectionStruct.thresholdForDesiredPfa(injectionIdx);
% Get necessary information from the tpsInjectionStruct
impactParameter = tpsInjectionStruct.impactParameter(injectionIdx);
injectedPeriodDays = tpsInjectionStruct.injectedPeriodDays(injectionIdx);
planetRadiusInEarthRadii = tpsInjectionStruct.planetRadiusInEarthRadii(injectionIdx);
isPlanetACandidate = logical(tpsInjectionStruct.isPlanetACandidate(injectionIdx));
fitSinglePulse = tpsInjectionStruct.fitSinglePulse(injectionIdx);
injectedEpochKjd = tpsInjectionStruct.injectedEpochKjd(injectionIdx);
numSesInMes = tpsInjectionStruct.numSesInMes(injectionIdx);
injectedDepthPpm = tpsInjectionStruct.injectedDepthPpm(injectionIdx);
epochKjd = tpsInjectionStruct.epochKjd(injectionIdx);
injectedDurationInHours = tpsInjectionStruct.injectedDurationInHours(injectionIdx);
trialTransitPulseInHours = tpsInjectionStruct.trialTransitPulseInHours(injectionIdx);
transitModelMatch = tpsInjectionStruct.transitModelMatch(injectionIdx);
% maxMes is degraded from true MES due to coarseness of period grid, transit duration grid
% and shape mismatch
maxMes = tpsInjectionStruct.maxMes(injectionIdx);
maxSesInMes = tpsInjectionStruct.maxSesInMes(injectionIdx);
maxSesMesRatio = maxSesInMes./maxMes;
fittedDepthPpm = 1.e6*tpsInjectionStruct.fittedDepth(injectionIdx);
fittedDepthChiPpm = 1.e6*tpsInjectionStruct.fittedDepthChi(injectionIdx);
fittedDepth = tpsInjectionStruct.fittedDepth(injectionIdx);
fittedDepthChi = tpsInjectionStruct.fittedDepthChi(injectionIdx);

% Epoch match
epochMatchIndicator = abs(tpsInjectionStruct.injectedEpochKjd(injectionIdx) - tpsInjectionStruct.epochKjd(injectionIdx)) < tpsInjectionStruct.injectedDurationInHours(injectionIdx) / 2 / 24 ;

% Expected MES -- see Shawn's notes
% This is the best estimate of MES, correcting maxMes for coarseness of period and
% transit duration grids, whitener, and transit shape mismatch.
% !!!!! should we use normSum000 instead ?????
% What about the formula used in fold_time_series.c, which is 
% maximumMultipleEventStatistic = corrsum/sqrt(normsum)
expectedMes = injectedDepthPpm .* 1e-6 .* tpsInjectionStruct.normSum000(injectionIdx);


expectedMes001 = injectedDepthPpm .* 1e-6 .* tpsInjectionStruct.normSum001(injectionIdx);
expectedMes011 = injectedDepthPpm .* 1e-6 .* tpsInjectionStruct.normSum011(injectionIdx);
expectedMes010 = injectedDepthPpm .* 1e-6 .* tpsInjectionStruct.normSum010(injectionIdx);
expectedMes100 = injectedDepthPpm .* 1e-6 .* tpsInjectionStruct.normSum100(injectionIdx);
expectedMes101 = injectedDepthPpm .* 1e-6 .* tpsInjectionStruct.normSum101(injectionIdx);
expectedMes111 = injectedDepthPpm .* 1e-6 .* tpsInjectionStruct.normSum111(injectionIdx);
expectedMes110 = injectedDepthPpm .* 1e-6 .* tpsInjectionStruct.normSum110(injectionIdx);




% histogram maxMes - expectedMes for non-candidates
skip = true;
if(~skip)
    figure
    hold on
    grid on
    box on
    hist(expectedMes(~isPlanetACandidate) - maxMes(~isPlanetACandidate),-100:0.1:1000)
    xlabel('Expected MES - Max MES')
    ylabel('Counts')
    title(['KIC ',num2str(selectedKeplerId)])
    set(gca,'FontSize',12)
    set(findall(gcf,'type','text'),'FontSize',12)
    plotName = strcat(num2str(selectedKeplerId),'maxMes_minus_expectedMes_candidates','.png');
    print('-r150','-dpng',plotName)
end

% maxMes vs expectedMes for candidates
figure
hold on
grid on
box on
plot(maxMes(isPlanetACandidate),expectedMes(isPlanetACandidate),'k.')
xlabel('Max MES')
ylabel('Expected MES')
axis equal
legend('Planet Candidates')
title(['KIC ',num2str(selectedKeplerId)])
set(gca,'FontSize',12)
set(findall(gcf,'type','text'),'FontSize',12)
plotName = strcat(testDir,'KIC',num2str(selectedKeplerId),'_maxMes_vs_expectedMes_candidates','.png');
print('-r150','-dpng',plotName)

% maxMes vs expectedMes for ~candidates
figure
hold on
grid on
box on
plot(maxMes(~isPlanetACandidate&fittedDepthPpm>0&injectedPeriodDays>100),expectedMes(~isPlanetACandidate&fittedDepthPpm>0&injectedPeriodDays>100),'r.')
xlabel('Max MES')
ylabel('Expected MES')
% axis([0,16,0,16])
legend(sprintf('Not Candidates\nfittedDepthPpm > 0\ninjectedPeriod > 100 days'))
title(['KIC ',num2str(selectedKeplerId)])
set(gca,'FontSize',12)
set(findall(gcf,'type','text'),'FontSize',12)
plotName = strcat(testDir,'KIC',num2str(selectedKeplerId),'_maxMes_vs_expectedMes_not_candidates','.png');
print('-r150','-dpng',plotName)

% injectedDepth vs fittedDepth for non-candidates
% Note: for KIC 9898170: 277055 of 290816 injections that were not candidates
% had fittedDepthPpm is -1e-6, this means robust fit failed, or was never reached (?)
figure
hold on
grid on
box on
plot(injectedDepthPpm(~isPlanetACandidate&fittedDepthPpm>0&injectedPeriodDays>100&expectedMes>20), ...
    fittedDepthPpm(~isPlanetACandidate&fittedDepthPpm>0&injectedPeriodDays>100&expectedMes>20),'r.')
xlabel('Injected depth [ppm]')
ylabel('Fitted depth [ppm]')
legend(sprintf('Not Candidates\nfittedDepthPpm > 0\ninjectedPeriod > 100 days\nExpected MES > 20'))
title(['KIC ',num2str(selectedKeplerId)])
set(gca,'FontSize',12)
set(findall(gcf,'type','text'),'FontSize',12)
axis([0,15000,0,35000])
plotName = strcat(testDir,'KIC',num2str(selectedKeplerId),'_injectedDepth_vs_fittedDepth_not_candidates','.png');
print('-r150','-dpng',plotName)

% Histogram of period for non-candidates with positive fittedDepth
skip = true;
if(~skip)
    figure
    hold on
    grid on
    box on
    hist(injectedPeriodDays(~isPlanetACandidate&fittedDepthPpm>0),0:10:800)
    title(['KIC ',num2str(selectedKeplerId)])
    xlabel('Injected period [days]')
    ylabel('Counts')
    legend('Not Planet Candidates, fittedDepthPpm > 0')
    set(gca,'FontSize',12)
    set(findall(gcf,'type','text'),'FontSize',12)
    plotName = strcat(testDir,'KIC',num2str(selectedKeplerId),'_period_histogram_fittedDepth_gt_0_and_not_candidates','.png');
    print('-r150','-dpng',plotName)
end

% Scatter plot of period vs expectedMes for the non-candidates with positive fitted depth
figure
hold on
grid on
box on
plot(injectedPeriodDays(~isPlanetACandidate&fittedDepthPpm>0&injectedPeriodDays>100),expectedMes(~isPlanetACandidate&fittedDepthPpm>0&injectedPeriodDays>100),'.')
xlabel('Injected period [days]')
ylabel('Expected MES')
legend(sprintf('Not Candidates\nfittedDepthPpm > 0\ninjectedPeriod > 100 days'))
title(['KIC ',num2str(selectedKeplerId)])
set(gca,'FontSize',12)
set(findall(gcf,'type','text'),'FontSize',12)
plotName = strcat(testDir,'KIC',num2str(selectedKeplerId),'_period_vs_expectedMes_not_candidates','.png');
axis([0, 750, 0 inf])
print('-r150','-dpng',plotName)

% Report 
fprintf('There are %d injections with expected MES > 20 and fittedDepth > 0 that are not candidates\n',sum(expectedMes(~isPlanetACandidate&fittedDepthPpm>0) > 20))
fprintf('There are %d of %d injections with fittedDepth = -1\n',sum(fittedDepthPpm == -1000000),length(fittedDepthPpm))


fprintf('%d of %d injections have maxSesInMesRatio > 0.9\n',sum(maxSesMesRatio(isfinite(maxSesMesRatio))>0.9),length(isfinite(maxSesMesRatio)) )
fprintf('%d injections had maxSesInMesRatio > 0.9 and became TCEs\n',sum(maxSesMesRatio>0.9&isPlanetACandidate) )


fprintf('%d injections, comprising a fraction %7.2f of those with fittedDepthPpm > 0 and period > 100 days, that fail to become candidates\n',sum(fittedDepthPpm>0&~isPlanetACandidate&periodDays>100),sum(fittedDepthPpm>0&~isPlanetACandidate&periodDays>100)/sum(fittedDepthPpm>0&periodDays>150) );

% population of non-candidates that have nonzero fittedDepth, long period >
% 100 days, and high SNR > 20
xx=fittedDepthPpm(~isPlanetACandidate&fittedDepthPpm>0&expectedMes>20&periodDays>100)./injectedDepthPpm(~isPlanetACandidate&fittedDepthPpm>0&expectedMes>20&periodDays>100);
figure
hold on
grid on
box on
hist(log10(xx))
title(['KIC ',num2str(selectedKeplerId)])
xlabel('log10[depthRatio (= fittedDepth/injectedDepth)]')
ylabel('Counts')
legendString = sprintf('isPlanetACandidate==0&\nfittedDepthPpm > 0&\nperiodDays > 100&\nexpectedMes > 20:\n\npopulation = %s\nmedian depthRatio = %s',num2str(sum(xx>0)),num2str(median(xx),'%7.2f'));
legend(legendString,'Location','Best')
set(gca,'FontSize',12)
set(findall(gcf,'type','text'),'FontSize',12)
plotName = strcat(testDir,'KIC',num2str(selectedKeplerId),'_fittedDepth_to_injectedDepth','.png');
print('-r150','-dpng',plotName)


% Retrieve the inputStruct for 9898170 in KSOC-4930
topDir = '/path/to/transitInjections/KSOC-4930/testRun_2_G_stars/tps-matlab-2015308/';
inputStructDir = strcat(topDir,'/tps-matlab-2015308-27/st-0/');
load(strcat(inputStructDir,'tps-inputs-0.mat'))

% Get cadence times
cadenceNumbers = inputsStruct.cadenceTimes.cadenceNumbers;
midTimestamps = inputsStruct.cadenceTimes.midTimestamps;
timeIdx = midTimestamps~=0;
startTimestamps = inputsStruct.cadenceTimes.startTimestamps;
endTimestamps = inputsStruct.cadenceTimes.endTimestamps;

% Data anomaly flags
% sum(inputsStruct.cadenceTimes.dataAnomalyFlags.attitudeTweakIndicators)     = 15
% sum(inputsStruct.cadenceTimes.dataAnomalyFlags.safeModeIndicators)          = 749
% sum(inputsStruct.cadenceTimes.dataAnomalyFlags.coarsePointIndicators)       = 322
% sum(inputsStruct.cadenceTimes.dataAnomalyFlags.argabrighteningIndicators)   = 52
% sum(inputsStruct.cadenceTimes.dataAnomalyFlags.excludeIndicators)           = 547
% sum(inputsStruct.cadenceTimes.dataAnomalyFlags.earthPointIndicators)        = 4522
% sum(inputsStruct.cadenceTimes.dataAnomalyFlags.planetSearchExcludeIndicators) = 979

% Data anomaly flags
attitudeTweakIndicators = inputsStruct.cadenceTimes.dataAnomalyFlags.attitudeTweakIndicators;
safeModeIndicators= inputsStruct.cadenceTimes.dataAnomalyFlags.safeModeIndicators;
coarsePointIndicators = inputsStruct.cadenceTimes.dataAnomalyFlags.coarsePointIndicators;
argabrighteningIndicators = inputsStruct.cadenceTimes.dataAnomalyFlags.argabrighteningIndicators;
excludeIndicators = inputsStruct.cadenceTimes.dataAnomalyFlags.excludeIndicators;
earthPointIndicators = inputsStruct.cadenceTimes.dataAnomalyFlags.earthPointIndicators;
planetSearchExcludeIndicators = inputsStruct.cadenceTimes.dataAnomalyFlags.planetSearchExcludeIndicators;

dataAnomalyIndicators = attitudeTweakIndicators | safeModeIndicators | coarsePointIndicators | argabrighteningIndicators ...
    | excludeIndicators | earthPointIndicators | planetSearchExcludeIndicators;

% Linear interpolation to fill in timestamps with zeros
yy = interp1(cadenceNumbers,midTimestamps,cadenceNumbers(midTimestamps==0));


% Fit nonzero timestamps and corresponding cadences to a linear model
% Check if it is good enough
% Y = A*P
idx = midTimestamps ~= 0;
Y = midTimestamps(idx);
X = cadenceNumbers(idx);
A = [ones(length(Y),1), X];
P = pinv(A)*Y;
Ymodel = A*P;
% Linear model is good to better than 3 seconds, good enough!
figure
hold on
plot(X,Y,'r.')
plot(X,Ymodel,'g.')
pause
clf
plot(X,Y-Ymodel,'k.')

% Interpolate to fill in interpolated midTimestamps where they were zeros
midTimestamps((~idx)) = interp1(X,Ymodel,cadenceNumbers(~idx));
midTimestamps = midTimestamps - kjd_offset_from_mjd;
startTimestamps = startTimestamps - kjd_offset_from_mjd;
endTimestamps = endTimestamps - kjd_offset_from_mjd;
gapIndices = inputsStruct.tpsTargets.gapIndices;


%==========================================================================
% 'Black-hole' injections. 
inds = find(isPlanetACandidate == 0 & expectedMes > 20 & fittedDepth > 0 & planetRadiusInEarthRadii > 3 & impactParameter < 0.3  & injectedPeriodDays > 150);
% Mid-transit times
maxNumTransits = zeros(length(injectedEpochKjd),1);
midTransitTimes = cell(1,length(injectedEpochKjd));
startTransitTimes = cell(1,length(injectedEpochKjd));
endTransitTimes = cell(1,length(injectedEpochKjd));
for iInj = 1:length(injectedEpochKjd)
    maxNumTransits(iInj) = floor( (endTimestamps(end) - injectedEpochKjd(iInj))./injectedPeriodDays(iInj) );
    midTransitTimes{iInj} = injectedEpochKjd(iInj) + (0:maxNumTransits(iInj)).*injectedPeriodDays(iInj);
    startTransitTimes{iInj} = injectedEpochKjd(iInj) - 0.5*injectedDurationInHours(iInj)/24 + (0:maxNumTransits(iInj)).*injectedPeriodDays(iInj);
    endTransitTimes{iInj} = injectedEpochKjd(iInj) + 0.5*injectedDurationInHours(iInj)/24 + (0:maxNumTransits(iInj)).*injectedPeriodDays(iInj);
end


% 'Black-hole' injections. 
for iInj = inds
    
    
    % Plot the PDC light curve and mark gapIndices, outlierIndices, and
    % outlierIndices
    figure(100)
    hold on
    box on
    plot(midTimestamps,inputsStruct.tpsTargets.fluxValue,'b-')
    % plot(midTimestamps(inputsStruct.tpsTargets.gapIndices),inputsStruct.tpsTargets.fluxValue(inputsStruct.tpsTargets.gapIndices),'r.')
    % plot(midTimestamps(inputsStruct.tpsTargets.outlierIndices),inputsStruct.tpsTargets.fluxValue(inputsStruct.tpsTargets.outlierIndices),'y.')
    % plot(midTimestamps(inputsStruct.tpsTargets.discontinuityIndices),inputsStruct.tpsTargets.fluxValue(inputsStruct.tpsTargets.discontinuityIndices),'c.')
    % plot(midTimestamps(dataAnomalyIndicators),inputsStruct.tpsTargets.fluxValue(dataAnomalyIndicators),'k.')
    plot(midTimestamps(dataAnomalyIndicators),0,'g.')
    
    
    % reconstruct the figure
    xx = midTransitTimes{iInj};
    nTransits = length(xx);
    plot( midTransitTimes{iInj} , zeros( 1 , nTransits ),'ro') %,'MarkerSize',10)
    plot( startTransitTimes{iInj}, zeros( 1 , nTransits ),'ro')%,'MarkerSize',10)
    plot( endTransitTimes{iInj}, zeros( 1 , nTransits ),'ro')%,'MarkerSize',10)
    fprintf('iInj %d numSesInMes %d, injectedDepthPpm %6.2f fittedDepthPpm %6.2f, injected period %6.2f \n',iInj,numSesInMes(iInj), injectedDepthPpm(iInj), fittedDepthPpm(iInj),injectedPeriodDays(iInj))
    pause
    clf
end

return

%==========================================================================
% Like 'Black-hole' injections, but failed robust fit
% Injections with same characteristics as 'black-hole' but with fittedDepth < 0
inds = find(isPlanetACandidate == 0 & expectedMes > 20 & fittedDepth < 0 & planetRadiusInEarthRadii > 3 & impactParameter < 0.3 & injectedPeriodDays > 150 );
% Mid-transit times
midTransitTimes = cell(1,length(injectedEpochKjd));
for iInj = 1:length(injectedEpochKjd)
    maxNumTransits = floor( (endTimestamps(end) - injectedEpochKjd(iInj))./injectedPeriodDays(iInj) );
    midTransitTimes{iInj} = injectedEpochKjd(iInj) + (0:maxNumTransits).*injectedPeriodDays(iInj);
end


% Like 'Black-hole' injections, but failed robust fit
for iInj = inds'
    
    
    % Plot the PDC light curve and mark gapIndices, outlierIndices, and
    % outlierIndices
    figure(100)
    hold on
    box on
    plot(midTimestamps,inputsStruct.tpsTargets.fluxValue,'b-')
    % plot(midTimestamps(inputsStruct.tpsTargets.gapIndices),inputsStruct.tpsTargets.fluxValue(inputsStruct.tpsTargets.gapIndices),'r.')
    % plot(midTimestamps(inputsStruct.tpsTargets.outlierIndices),inputsStruct.tpsTargets.fluxValue(inputsStruct.tpsTargets.outlierIndices),'y.')
    % plot(midTimestamps(inputsStruct.tpsTargets.discontinuityIndices),inputsStruct.tpsTargets.fluxValue(inputsStruct.tpsTargets.discontinuityIndices),'c.')
    % plot(midTimestamps(dataAnomalyIndicators),inputsStruct.tpsTargets.fluxValue(dataAnomalyIndicators),'k.')
    plot(midTimestamps(dataAnomalyIndicators),0,'g.')
    
    
    % reconstruct the figure
    
    plot(midTransitTimes{iInj},0,'ro')%,'MarkerSize',10)
    fprintf('iInj %d numSesInMes %d, injectedDepthPpm %6.2f fittedDepthPpm %6.2f, injected period %6.2f \n',iInj,numSesInMes(iInj), injectedDepthPpm(iInj), fittedDepthPpm(iInj),injectedPeriodDays(iInj))
    pause
    clf
end


%==========================================================================
% Like 'Black-hole' injections, but *were* detected
% Injections with same characteristics as 'black-hole' but with fittedDepth < 0
inds = find(isPlanetACandidate == 1 & expectedMes > 20 & fittedDepth > 0 & planetRadiusInEarthRadii > 3 & impactParameter < 0.3 & injectedPeriodDays > 150);
% Mid-transit times
midTransitTimes = cell(1,length(injectedEpochKjd));
for iInj = 1:length(injectedEpochKjd)
    maxNumTransits = floor( (endTimestamps(end) - injectedEpochKjd(iInj))./injectedPeriodDays(iInj) );
    midTransitTimes{iInj} = injectedEpochKjd(iInj) + (0:maxNumTransits).*injectedPeriodDays(iInj);
end

% Like 'Black-hole' injections, but *were* detected
for iInj = inds'
    
    
    % Plot the PDC light curve and mark gapIndices, outlierIndices, and
    % outlierIndices
    figure(100)
    hold on
    box on
    plot(midTimestamps,inputsStruct.tpsTargets.fluxValue,'b-')
    % plot(midTimestamps(inputsStruct.tpsTargets.gapIndices),inputsStruct.tpsTargets.fluxValue(inputsStruct.tpsTargets.gapIndices),'r.')
    % plot(midTimestamps(inputsStruct.tpsTargets.outlierIndices),inputsStruct.tpsTargets.fluxValue(inputsStruct.tpsTargets.outlierIndices),'y.')
    % plot(midTimestamps(inputsStruct.tpsTargets.discontinuityIndices),inputsStruct.tpsTargets.fluxValue(inputsStruct.tpsTargets.discontinuityIndices),'c.')
    % plot(midTimestamps(dataAnomalyIndicators),inputsStruct.tpsTargets.fluxValue(dataAnomalyIndicators),'k.')
    plot(midTimestamps(dataAnomalyIndicators),0,'g.')
    
    
    % reconstruct the figure
    
    plot(midTransitTimes{iInj},0,'ro')%,'MarkerSize',10)
    fprintf('iInj %d numSesInMes %d, injectedDepthPpm %6.2f fittedDepthPpm %6.2f, injected period %6.2f \n',iInj,numSesInMes(iInj), injectedDepthPpm(iInj), fittedDepthPpm(iInj),injectedPeriodDays(iInj))
    pause
    clf
end
