% plti_window_function.m
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

% plot window function for PLTI injections, and explore sensitivity to
% various selection criteria
% adapted from analyze_plti.m

%==========================================================================
% Initialize
% close all

%==========================================================================
% Constants

% Stellar temperature boundaries
Teff1 = 2400;
Teff2 = 3900;
Teff3 = 5000;
Teff4 = 6000;
Teff5 = 7000;

pulseIndex = 10;

% !!!!! Select targets with 17Q of data
select17Q = true;%logical(input('Select targets with all 17 Q of data? 1 or 0 -- '));


% MES sampling
DELMES = 0.5;
% MINMES = 3;
% MAXMES = 25;
% mesBinEdges = MINMES:DELMES:MAXMES;
% mesBinCenters = mesBinEdges(1:end-1)+diff(mesBinEdges)/2.0;

% Use wider bins at high MES where sampling is sparse
DELMES1 = DELMES;
MINMES1 = 3;
MAXMES1 = 14;
DELMES2 = 2;
MINMES2 = MAXMES1;
MAXMES2 = 25;

% MES binning scheme
mesBinEdges1 = MINMES1:DELMES1:MAXMES1;
mesBinEdges2 = MINMES2:DELMES2:MAXMES2;
mesBinEdges = [mesBinEdges1,mesBinEdges2(2:end)];
mesBinCenters = mesBinEdges(1:end-1)+diff(mesBinEdges)/2.0;

% Period sampling
MIN_PERIOD_DAYS = 0.5;
MAX_PERIOD_DAYS = 500;
DEL_PERIOD_DAYS = 2;
periodBinEdges=MIN_PERIOD_DAYS:DEL_PERIOD_DAYS:MAX_PERIOD_DAYS;
periodBinCenters=periodBinEdges(1:end-1)+diff(periodBinEdges)/2.0;

% Color wheel
xColor = 'cbgmkr';

% For Savitzky-Golay smoothing with 3rd order polynomial, and
% window size 5
polyOrder = 3;
frameSize = 25; % must be odd

% Control parameters for selection cuts
maxCdppSlope = input('Maximum CDPP slope for window function, eg. 1 -- ');
highMesCutoff = input('High-MES cutoff for window function, eg. 16 -- ');
minLogg = 4.0;
maxImpactParameter = input('Max impact parameter, eg. 0.6 -- ');
iTeff = input('Temperature range: 1(M), 2(K), 3(G), 4(F), 5(FGK) 6(FGKM)-- ');

%==========================================================================
% Directories

% Directory for PLTI taskfiles
pltiTipDataDir = '/path/to/ksoc-4995-expected-mes/dv-tip-compare/';

% Directory for saving PLTI results
pltiResultsDir = '/codesaver/work/transit_injection/plti_results/';

% Base directory for scripts
baseDir = '/path/to/matlab/tps/search/test/transit-injection-analysis/';

%==========================================================================
% Get injection data

% Load the PLTI results file
if(~exist('tipData','var'))
    fprintf('Getting injection data ...\n')
    load(strcat(pltiTipDataDir,'dv-tip-compare-reduex.mat'));
end

% Load Chris' PLTI federation file
% column 1 is keplerIds
% column 8 is match indicator
if(~exist('matchData','var'))
    fprintf('Getting injection federation file ...\n')
    matchData = dlmread(strcat(pltiResultsDir,'injmatch_DR25_03182016.txt'));
    keplerIdMatched = matchData(:,2);
    matchIdx = logical(matchData(:,8));
end

%==========================================================================
% Get stellar parameters database

% Load the completeStructArray with stellar parameters created by Chris Burke in KSO-416
if(~exist('completeStructArray','var'))
    fprintf('Getting stellar database ...\n')
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
nTargetsAll = length(completeStructArray);
nPulseDurations = length(completeStructArray(1).rmsCdpps2);
rmsCdpp2All = zeros(nTargetsAll,nPulseDurations);
rmsCdpp1All = zeros(nTargetsAll,nPulseDurations);
dataSpansAll = zeros(nTargetsAll,nPulseDurations);
dutyCyclesAll = zeros(nTargetsAll,nPulseDurations);
for iTarget = 1:nTargetsAll
    rmsCdpp2All(iTarget,:) = [completeStructArray(iTarget).rmsCdpps2];
    rmsCdpp1All(iTarget,:) = [completeStructArray(iTarget).rmsCdpps1];
    dataSpansAll(iTarget,:) = [completeStructArray(iTarget).dataSpans1];
    dutyCyclesAll(iTarget,:) = [completeStructArray(iTarget).dutyCycles1];
end

%==========================================================================
% Cross-match the PLTI targets

% Indicator for PLTI targets indexed to stellar parameters database
% locAll is index in keplerIdAll for PLTI targets
[TFall , locAll] = ismember(tipData.keplerId,keplerIdAll);

% Get dataspans for PLTI targets

% Data Span
if(select17Q)
    % Select targets with data for all 17Q
    dataSpansIdx = dataSpansAll(:,pulseIndex) == median(dataSpansAll(:,pulseIndex));
elseif(~select17Q)
    % No selection on data spans
    dataSpansIdx = true(size(dataSpansAll(:,pulseIndex)));
end


% Get cdpp slope for PLTI targets: takes ~150 sec
% Modified: uses ordinary least squares instead of robust least squares
if(~exist('cdppSlope','var'))
    fprintf('Computing CDPP slope ...\n')
    cdppSlope = get_cdpp_slope(rmsCdpp2All(locAll,:),rmsCdpp1All(locAll,:));
end

% RA and DEC of PLTI targets
RA = RAall(locAll);
DEC = DECall(locAll);

% Indicator for PLTI targets indexed to the list of matched PLTI targets
% locMatched is index in keplerIdMatched for PLTI targets
[TFmatched, locMatched] = ismember(tipData.keplerId,keplerIdMatched);

% Check: xx should be identical to yy
xx= keplerIdMatched(locMatched);
yy = double(keplerIdAll(locAll));

% Match indicator, ordered as the injection list
matchIndicator = matchIdx(locMatched); % 79396


%==========================================================================
% Select non EB and non-offset injections

skyGroupId = tipData.skyGroupId;


% Skygroups containing offset injections
skyGroupIdsWithTransitOffsetEnabled = unique(tipData.skyGroupId(tipData.transitOffsetEnabled==1));

% Skygroups with EBs are the ones with duplicate keplerIds
[~,uniqueKeplerIdIndices,~] = unique(tipData.keplerId);
duplicateKeplerIdIndices = setdiff( (1:length(tipData.keplerId))',uniqueKeplerIdIndices);
skyGroupIdsWithEbs = unique(tipData.skyGroupId(duplicateKeplerIdIndices));


% Indicator for injections with unique keplerId
% uniqueKeplerIdIdx = false(length(tipData.keplerId),1);
% uniqueKeplerIdIdx(uniqueKeplerIdIndices) = true;

% Skygroups with EBs or offsets
skyGroupIdsWithEbsOrOffsets = [skyGroupIdsWithEbs ; skyGroupIdsWithTransitOffsetEnabled];


% Indicator for  selecting injections from skyGroups that don't have EBs or Offset injections
skyGroupIdx = ~ismember(skyGroupId,skyGroupIdsWithEbsOrOffsets); % 152013

% Indexes of good skyGroups
goodSkyGroupList = unique(skyGroupId(~ismember(skyGroupId,skyGroupIdsWithEbsOrOffsets)));

% Number of skyGroups for good injections
nSkyGroupsForInjections = sum(~ismember(unique(tipData.skyGroupId),skyGroupIdsWithEbsOrOffsets));

% Number of TCEs among the good injections
nTces = sum( skyGroupIdx & tipData.isPlanetCandidateTps);

% Total number of injections in skygroups that don't have EBs or offset
% injections
fprintf('Total number of %d good injections, of which %d are TCEs, in %d skygroups\n',sum(skyGroupIdx),nTces,nSkyGroupsForInjections)

% Number of injections with zero depth
fprintf('There are %d injections with zero depth\n',sum(tipData.transitDepthPpm==0))

%==========================================================================
% Select Planet parameters

% Orbital period


% Orbital period selection
periodIdx = tipData.orbitalPeriodDays > MIN_PERIOD_DAYS & tipData.orbitalPeriodDays < MAX_PERIOD_DAYS; % 209081 (all)

% Impact parameter
impactParameter = zeros(length(tipData.injectedPlanetModelStruct),1);
for iTarget = 1:length(tipData.injectedPlanetModelStruct)
    impactParameter(iTarget) = tipData.injectedPlanetModelStruct(iTarget).planetModel.minImpactParameter;
end

% Impact parameter selection
impactParameterIdx = impactParameter < maxImpactParameter;

% MES selection
highMesIdx = tipData.windowedMes > highMesCutoff;

% Set isPlanetACandidate to zero if there is no match to an injected TCE
% Eliminates TCEs from OPS run

% Get isPlanetACandidate
isPlanetACandidate = tipData.isPlanetCandidateTps; % 95442 are true

% Set isPlanetACandidate to 0 if there is no match
isPlanetACandidate(~matchIndicator) = 0; % 79396 are true

%==========================================================================
% Select Stellar parameters

% logg
loggIdx = tipData.stellarLog10Gravity > minLogg; % 165453

% Select CDPP slope
cdppSlopeIdx = cdppSlope < maxCdppSlope;

% Select dataSpans for 17Q of data

% Make indicators for selected Teff ranges
nTeffRanges = 6;
tEffIdxAll = cell(1,nTeffRanges);
TeffLow = cell(1,nTeffRanges);
TeffHigh = cell(1,nTeffRanges);
for iRange = 1:nTeffRanges
    
    switch iRange
        
        case 1
            
            % Upper and lower Teff for M stars
            TeffLow{iRange} = Teff1;
            TeffHigh{iRange} = Teff2;
            
        case 2
            
            % Upper and lower Teff for K stars
            TeffLow{iRange} = Teff2;
            TeffHigh{iRange} = Teff3;
            
        case 3
            
            % Upper and lower Teff for G stars
            TeffLow{iRange} = Teff3;
            TeffHigh{iRange} = Teff4;
            
        case 4
            
            % Upper and lower Teff for F stars
            TeffLow{iRange} = Teff4;
            TeffHigh{iRange} = Teff5;
            
        case 5
            
            % Upper and lower Teff for FGK stars
            TeffLow{iRange} = Teff2;
            TeffHigh{iRange} = Teff5;
            
        case 6
            
            % Upper and lower Teff for FGKM stars
            TeffLow{iRange} = Teff1;
            TeffHigh{iRange} = Teff5;
    end
    
    % Set indicator for selected temperature range
    tEffIdxAll{iRange} = tipData.stellarEffectiveTempKelvin >= TeffLow{iRange} & tipData.stellarEffectiveTempKelvin < TeffHigh{iRange};
    
end

% Select stars in desired Teff range for window function
tEffIdx = tEffIdxAll{iTeff};

%==========================================================================
% Select valid injections for the window function

% Count valid injections: apply selection criteria
validInjectionIndicator = skyGroupIdx ...
    &  dataSpansIdx ...
    & loggIdx & tEffIdx & cdppSlopeIdx ...
    & periodIdx & highMesIdx & impactParameterIdx;
fprintf('%d of %d targets were selected\n', ...
    sum(validInjectionIndicator),length(validInjectionIndicator))

% Summary of selections
fprintf('Empirical Window Function for pixel-level injections on %d stars selected by:\n17 Quarters, logg >= %6.1f, cdppSlope < %6.1f, %6.0f <= Teff < = %6.0f\nMES > %6.2f, b < %6.2f ,%6.1f days < period <%6.0f days\n\n',sum(validInjectionIndicator),minLogg,maxCdppSlope,TeffLow{iRange},TeffHigh{iRange},highMesCutoff,maxImpactParameter, MIN_PERIOD_DAYS,MAX_PERIOD_DAYS)



%==================================================================

% Window function vs period

% Binned detections and misses
periodMissed = tipData.orbitalPeriodDays(isPlanetACandidate == 0 & validInjectionIndicator );
periodDetected = tipData.orbitalPeriodDays(isPlanetACandidate == 1 & validInjectionIndicator );

% Histogram of period of missed TCEs
nMissedTempWF = histc(periodMissed,periodBinEdges);
nMissedWF = nMissedTempWF(1:end-1);

% Histogram of period of detected TCEs
nDetectedTempWF = histc(periodDetected,periodBinEdges);
nDetectedWF = nDetectedTempWF(1:end-1);

% Number of injected TCEs
nInjectedWF = nDetectedWF + nMissedWF;

% Window function vs period
windowFunction = nDetectedWF./nInjectedWF;

% Plot Window Function
figure
hold on
box on
grid on
plot(periodBinCenters',windowFunction,'k-')
plot(periodBinCenters',sgolayfilt(windowFunction,polyOrder,frameSize),'r-','LineWidth',2)
title(sprintf('Empirical Window Function for pixel-level injections on %d stars selected by:\n17 Quarters, logg >= %6.1f, cdppSlope < %6.1f, %6.0f < Teff < = %6.0f\nMES > %6.2f, b < %6.2f ,%6.1f days < period <%6.0f days',sum(validInjectionIndicator),minLogg,maxCdppSlope,TeffLow{iRange},TeffHigh{iRange},highMesCutoff,maxImpactParameter, MIN_PERIOD_DAYS,MAX_PERIOD_DAYS))
axis([0,MAX_PERIOD_DAYS,0,1.3])
xlabel(['Orbital Period [Days], bin size = ',num2str(DEL_PERIOD_DAYS),' days'])
ylabel('Recovery Rate')
legend( ['400 < P < 500 days: mean ',num2str(mean(windowFunction(200:end)),'%6.2f'),' std ',num2str(std(windowFunction(200:end)),'%6.2f')] , ['Savitzky-Golay smoothed: order ',num2str(polyOrder),', frameSize ',num2str(frameSize*DEL_PERIOD_DAYS),' days'],'Location','North')
set(gca,'FontSize',12)
set(findall(gcf,'type','text'),'FontSize',12)
plotName = 'all_stars_window_function_with_impact_parameter';
print('-dpng','-r150',strcat(pltiResultsDir,plotName))


% Variation of WF with sky group

% Orbital period selection
periodIdx = tipData.orbitalPeriodDays >= 400 & tipData.orbitalPeriodDays <= 500; % 209081 (all)
windowFunction = -0.1*ones(1,84);
nInjectedWF = zeros(1,84);
meanRA = zeros(1,84);
meanDEC = zeros(1,84);
for iSkyGroup = goodSkyGroupList(:)'
    
    
    % Count valid injections: apply selection criteria
    validInjectionIndicator = skyGroupId == iSkyGroup ...
        &  dataSpansIdx ...
        & loggIdx & tEffIdx & cdppSlopeIdx ...
        & periodIdx & highMesIdx & impactParameterIdx;
    
    % Summary
    fprintf('skygroup %d: %d of %d targets were selected\n', ...
        iSkyGroup,sum(validInjectionIndicator),length(validInjectionIndicator))
    
    % Window function vs period
    
    % Binned detections and misses
    periodMissed = tipData.orbitalPeriodDays(isPlanetACandidate == 0 & validInjectionIndicator );
    periodDetected = tipData.orbitalPeriodDays(isPlanetACandidate == 1 & validInjectionIndicator );
    
    % Histogram of period of missed TCEs
    % nMissedTempWF = histc(periodMissed,periodBinEdges);
    % nMissedWF = nMissedTempWF(1:end-1);
    nMissedWF = length(periodMissed);
    
    % Histogram of period of detected TCEs
    % nDetectedTempWF = histc(periodDetected,periodBinEdges);
    % nDetectedWF = nDetectedTempWF(1:end-1);
    nDetectedWF = length(periodDetected);
    
    % Number of injected TCEs
    nInjectedWF(iSkyGroup) = nDetectedWF + nMissedWF;
    
    % Window function vs period
    if(nInjectedWF(iSkyGroup) >= 0)
        windowFunction(iSkyGroup) = nDetectedWF./nInjectedWF(iSkyGroup);
    end
    
    meanRA(iSkyGroup) = mean(RA(validInjectionIndicator));
    meanDEC(iSkyGroup) = mean(DEC(validInjectionIndicator));
    
    
    
    
    
end

% Window function vs. binomial count noise
figure
plot(windowFunction(windowFunction>=0),'k.-')
hold on
plot( sqrt( windowFunction(windowFunction>=0).*(1-windowFunction(windowFunction>=0))./nInjectedWF(windowFunction>=0) ),'r.')



% Variation of window function over the focal plane
figure

% Gray background
plot(RAall(RAall>0),DECall(RAall>0),'.','color',[0.5,0.5,0.5])
hold on
%
scatter(meanRA(windowFunction>=0),meanDEC(windowFunction>=0),[],windowFunction(windowFunction>=0),'*')
xlabel('RA [degrees]')
ylabel('DEC [degrees]')
title('Variation of mean(WindowFunction(400 < P < 500)) over the Focal Plane')
t = colorbar('peer',gca);
set(get(t,'ylabel'),'String', 'Window Function 400 < P < 500');
set(gca,'FontSize',12)
set(findall(gcf,'type','text'),'FontSize',12)


%==========================================================================
% Select valid injections for the detection efficiency function

% Period sampling
MIN_PERIOD_DAYS = input('MIN_PERIOD_DAYS, eg. 0.5 -- ');
MAX_PERIOD_DAYS = input('MAX_PERIOD_DAYS, eg. 500 -- ');
DEL_PERIOD_DAYS = 2;
periodBinEdges=MIN_PERIOD_DAYS:DEL_PERIOD_DAYS:MAX_PERIOD_DAYS;
periodBinCenters=periodBinEdges(1:end-1)+diff(periodBinEdges)/2.0;

% Period label for plot
periodLabel = ['_period_',num2str(MIN_PERIOD_DAYS),'_to_',num2str(MAX_PERIOD_DAYS),'_days'];

% CDPP slope
maxCdppSlope = input('Maximum CDPP slope for detection efficiency, eg. 1 -- ');
cdppSlopeIdx = cdppSlope < maxCdppSlope;
cdppSlopeLabel = ['_max_cdpp_slope_',num2str(maxCdppSlope)];

% Close existing plots
% close(100)
% close(200)

% Select stars in desired Teff range for detection efficiency function
% iTeff = input('Select stars by stellar type: 1(M), 2(K), 3(G), 4 (F), 5(FGK), 6(FGKM) -- ');

% Loop over M, K, G, F stars
nTeff = zeros(1,nTeffRanges);
nBinCenters = length(mesBinCenters);
nMissed = zeros(nBinCenters,nTeffRanges);
nInjected = zeros(nBinCenters,nTeffRanges);
nDetected = zeros(nBinCenters,nTeffRanges);
detectionEfficiency = zeros(nBinCenters,nTeffRanges);
for iTeff = 1:nTeffRanges
    
    % Select on Teff
    tEffIdx = tEffIdxAll{iTeff};
    
    
    % Count valid injections: apply selection criteria
    validInjectionIndicator = skyGroupIdx ...
        &  dataSpansIdx ...
        & loggIdx & tEffIdx & cdppSlopeIdx ...
        & tipData.orbitalPeriodDays < MAX_PERIOD_DAYS & tipData.orbitalPeriodDays > MIN_PERIOD_DAYS ...
        & tipData.fitSinglePulse9p2 == 0;
    
    % Number of valid injections
    nTeff(iTeff) = sum(validInjectionIndicator);
    
    % Report on selection
    fprintf('%d of %d targets were selected\n', ...
        sum(validInjectionIndicator),length(validInjectionIndicator))
    
    % Summary of selections
    fprintf('Detection Efficiency Function for pixel-level injections on %d stars selected by:\n17 Quarters, logg >= %6.1f, cdppSlope < %6.1f, %6.0f <= Teff < = %6.0f\n%6.1f days < period <%6.0f days\n\n',sum(validInjectionIndicator),minLogg,maxCdppSlope,TeffLow{iRange},TeffHigh{iRange}, MIN_PERIOD_DAYS,MAX_PERIOD_DAYS)
    
    
    % Detection Efficiency vs. MES
    
    % MES of valid injections that did not become TCEs
    mesMissed = tipData.windowedMes(isPlanetACandidate == 0 & validInjectionIndicator  );
    
    % MES of valid injections that became TCEs
    mesDetected = tipData.windowedMes(isPlanetACandidate == 1 & validInjectionIndicator );
    
    % Histogram of MES of missed TCEs
    nMissedTemp = histc(mesMissed,mesBinEdges);
    nMissed(:,iTeff) = nMissedTemp(1:end-1);
    
    % Histogram of MES of detected TCEs
    nDetectedTemp = histc(mesDetected,mesBinEdges);
    nDetected(:,iTeff) = nDetectedTemp(1:end-1);
    
    % Number of injected TCEs-
    nInjected(:,iTeff) = nDetected(:,iTeff) + nMissed(:,iTeff);
    
    % Detection efficiency vs MES
    detectionEfficiency(:,iTeff) = nDetected(:,iTeff)./nInjected(:,iTeff);
    
    % Detection efficiency vs. MES
    
    figure(100)
    hold on
    box on
    grid on
    plot(mesBinCenters,nDetected(:,iTeff)./nInjected(:,iTeff),[xColor(iTeff),'.-'])
    
    
    % Number of injections vs. MES
    figure(200)
    semilogy(mesBinCenters,nInjected(:,iTeff),[xColor(iTeff),'.-'])
    hold on
    grid on
    box on
    
    
    
end % loop over stellar types


% Save detection efficiency data in a csv file
% Format is 16 columns
% column 1 mesBinCenters
% columns 2 - 6 detection efficiency for M, K, G, F, and all stars
% columns 7 - 11 are detected counts for M, K, G, F, and all stars
% columns 11 - 16 are injected counts for M, K, G, F, and all stars
detectionEfficiencyDataRoot = 'detection_efficiency_data';
detectionEfficiencyData = [mesBinCenters',detectionEfficiency,nDetected,nMissed];
dlmwrite(strcat(pltiResultsDir,detectionEfficiencyDataRoot,'.csv'), detectionEfficiencyData, 'delimiter', ',', ...
         'precision', 15)

% Make legend strings
legendString1 = sprintf('%d M %6.0f - %6.0f K',nTeff(1),TeffLow{1},TeffHigh{1});
legendString2 = sprintf('%d K %6.0f - %6.0f K',nTeff(2),TeffLow{2},TeffHigh{2});
legendString3 = sprintf('%d G %6.0f - %6.0f K',nTeff(3),TeffLow{3},TeffHigh{3});
legendString4 = sprintf('%d F %6.0f - %6.0f K',nTeff(4),TeffLow{4},TeffHigh{4});
legendString5 = sprintf('%d FGK %6.0f - %6.0f K',nTeff(5),TeffLow{5},TeffHigh{5});
legendString6 = sprintf('%d FGKM %6.0f - %6.0f K',nTeff(6),TeffLow{6},TeffHigh{6});

% Finish figures
figure(100)
title(sprintf('Detection Efficiency vs. MES for pixel-level injections on stars selected by:\n17 Quarters, logg >= %6.1f, cdppSlope < %6.1f\n%6.1f days < period <%6.0f days',minLogg,maxCdppSlope, MIN_PERIOD_DAYS,MAX_PERIOD_DAYS))
xlabel(['MES, bin sizes ',num2str(DELMES1),' and ',num2str(DELMES2)])
ylabel('Recovery Rate')
legend(legendString1,legendString2,legendString3,legendString4,legendString5,legendString6,'Location','SouthEast')
set(gca,'FontSize',12)
set(findall(gcf,'type','text'),'FontSize',12)
plotName = strcat('all_stars_detection_efficiency_vs_MES',periodLabel,cdppSlopeLabel);
print('-dpng','-r150',strcat(pltiResultsDir,plotName,'.png'))

% Finish figures
figure(200)
title(sprintf('Number of injections vs. MES for pixel-level injections on stars selected by:\n17 Quarters, logg >= %6.1f, cdppSlope < %6.1f\n%6.1f days < period <%6.0f days',minLogg,maxCdppSlope, MIN_PERIOD_DAYS,MAX_PERIOD_DAYS))
xlabel(['MES, bin sizes ',num2str(DELMES1),' and ',num2str(DELMES2)])
ylabel('Counts')
legend(legendString1,legendString2,legendString3,legendString4,legendString5,legendString6,'Location','SouthWest')
set(gca,'FontSize',12)
set(findall(gcf,'type','text'),'FontSize',12)
plotName = strcat('all_stars_number_of_injections_vs_MES',periodLabel,cdppSlopeLabel);
print('-dpng','-r150',strcat(pltiResultsDir,plotName,'.png'))




