% compare_PLTI_FLTI.m
% Compare 9.3 detection efficiency curves for 
% PLTI vs. FLTI, in similar period ranges.
% Adapted from plti_window_function.m
% Ran make_detection_efficiency_curve.m on KSOC-5004-1-run2with periods of 20 to 500 days
% in order to generate a comparable detection efficiency data set.
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
% Select valid injections for the detection efficiency function


%==========================================================================
% Initialize
clear all
% close all

%==========================================================================
% Constants

% Stellar temperature boundaries
Teff1 = 2400;
Teff2 = 3900;
Teff3 = 5000;
Teff4 = 6000;
Teff5 = 7000;

% Use wider bins at high MES where sampling is sparse
DELMES = 0.5;
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
MIN_PERIOD_DAYS = input('Minimum orbital period in days, eg. 20: ');
MAX_PERIOD_DAYS = input('Maximum orbital period in days, eg. 500: ');
DEL_PERIOD_DAYS = 2;
periodBinEdges=MIN_PERIOD_DAYS:DEL_PERIOD_DAYS:MAX_PERIOD_DAYS;
periodBinCenters=periodBinEdges(1:end-1)+diff(periodBinEdges)/2.0;

% Period label for plot
periodLabel = ['_period_',num2str(MIN_PERIOD_DAYS),'_to_',num2str(MAX_PERIOD_DAYS),'_days'];

% Color wheel
xColor = 'cbgmk';

% Control parameters for selection cuts
% maxCdppSlope = input('Maximum CDPP slope for window function, eg. 1 -- ');
% highMesCutoff = input('High-MES cutoff for window function, eg. 16 -- ');
minLogg = 4.0;
% maxImpactParameter = input('Max impact parameter, eg. 0.6 -- ');
% iTeff = input('Temperature range: 1(M), 2(K), 3(G), 4(F), 5(FGK), 6(FGKM) -- ');

% For comparison to FLTI results, we want apples-to-apples
select17Q = true;% logical(input('Select targets with all 17 Q of data? 1 or 0 -- '));


%==========================================================================
% Directories

% Directory for PLTI taskfiles
pltiTipDataDir = '/path/to/ksoc-4995-expected-mes/dv-tip-compare/';

% Directory for saving PLTI results
pltiResultsDir = '/codesaver/work/transit_injection/plti_results/';

% Base directory for scripts
baseDir = '/path/to/matlab/tps/search/test/transit-injection-analysis/';

% Directory for FLTI results
fltiDir = '/codesaver/work/transit_injection/detection_efficiency_curves/KSOC-5004-1-run2/';


%==========================================================================
% Get PLTI injection data

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
pulseIndex = 10;
dataSpans = dataSpansAll(locAll,pulseIndex);

% Data Span Selection
if(select17Q)
    % Select targets with data for all 17Q
    dataSpansIdx = dataSpans == median(dataSpans);
elseif(~select17Q)
    % No selection on data spans
    dataSpansIdx = true(size(dataSpans));
end

% Get cdpp slope for PLTI targets: takes ~150 sec
% Modified: uses ordinary least squares instead of robust least squares
% if(~exist('cdppSlope','var'))
%    fprintf('Computing CDPP slope ...\n')
%    cdppSlope = get_cdpp_slope(rmsCdpp2All(locAll,:),rmsCdpp1All(locAll,:));
% end

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
% Select Planet parameters for PLTI injections

% Orbital period


% Orbital period selection
periodIdx = tipData.orbitalPeriodDays > MIN_PERIOD_DAYS & tipData.orbitalPeriodDays < MAX_PERIOD_DAYS; % 209081 (all)

% Impact parameter
impactParameter = zeros(length(tipData.injectedPlanetModelStruct),1);
for iTarget = 1:length(tipData.injectedPlanetModelStruct)
    impactParameter(iTarget) = tipData.injectedPlanetModelStruct(iTarget).planetModel.minImpactParameter;
end

% Impact parameter selection
% impactParameterIdx = impactParameter < maxImpactParameter;

% MES selection
% highMesIdx = tipData.windowedMes > highMesCutoff;

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
% cdppSlopeIdx = cdppSlope < maxCdppSlope;

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

%==========================================================================

% uniqueKeplerIdPlti = uniqueKeplerId;
clear uniqueKeplerId;
clear midMesBin;

% Get FLTI injection data
fltiFile = strcat(fltiDir,'KSOC-5004-1-run2-detection-efficiency-epoch-matching-generalized-logistic-function-model-period-',num2str(MIN_PERIOD_DAYS),'-to-',num2str(MAX_PERIOD_DAYS),'-days.mat');
load(fltiFile);
% Variables
% 'detectionEfficiencyAll'
% 'nDetectedAll'
% 'nMissedAll'
% 'midMesBin'
% 'uniqueKeplerId'
% 'meanPeriodCutoffDueToWindowFunctionAll'
% 'periodLabel'



%==========================================================================
% Loop over M, K, G, F stars
nTeff = zeros(1,nTeffRanges);
nBinCenters = length(mesBinCenters);
nMissedPLTI = zeros(nBinCenters,nTeffRanges);
nInjectedPLTI = zeros(nBinCenters,nTeffRanges);
nDetectedPLTI = zeros(nBinCenters,nTeffRanges);
detectionEfficiencyPLTI = zeros(nBinCenters,nTeffRanges);
% !!!!! Select FGKM stars for apples-to-apples comparison
for iTeff = 6;% 1:nTeffRanges
    
    
    % Select on Teff
    tEffIdx = tEffIdxAll{iTeff};
    
    
    % Count valid injections: apply selection criteria
    validInjectionIndicatorPLTI = skyGroupIdx ...
        &  dataSpansIdx ...
        & loggIdx & tEffIdx ...
        & tipData.orbitalPeriodDays < MAX_PERIOD_DAYS & tipData.orbitalPeriodDays > MIN_PERIOD_DAYS ...
        & tipData.fitSinglePulse9p2 == 0;
    
    
    % Report on selection
    fprintf('%d of %d PLTI targets were selected\n', ...
        sum(validInjectionIndicatorPLTI),length(validInjectionIndicatorPLTI))
    
    % Summary of selections
    fprintf('Detection Efficiency Function for pixel-level injections on %d stars selected by:\n17 Quarters, logg >= %6.1f, %6.0f <= Teff < = %6.0f\n%6.1f days < period <%6.0f days\n\n',sum(validInjectionIndicatorPLTI),minLogg,TeffLow{iRange},TeffHigh{iRange}, MIN_PERIOD_DAYS,MAX_PERIOD_DAYS)
    
    
    %==========================================================================
    % Detection Efficiency vs. MES, for PLTI
    
    % MES of valid injections that did not become TCEs
    mesMissedPLTI = tipData.windowedMes(isPlanetACandidate == 0 & validInjectionIndicatorPLTI  );
    
    % MES of valid injections that became TCEs
    mesDetectedPLTI = tipData.windowedMes(isPlanetACandidate == 1 & validInjectionIndicatorPLTI );
    
    % Histogram of MES of missed TCEs
    nMissedTempPLTI = histc(mesMissedPLTI,mesBinEdges);
    nMissedPLTI(:,iTeff) = nMissedTempPLTI(1:end-1);
    
    % Histogram of MES of detected TCEs
    nDetectedTempPLTI = histc(mesDetectedPLTI,mesBinEdges);
    nDetectedPLTI(:,iTeff) = nDetectedTempPLTI(1:end-1);
    
    % Number of injected TCEs-
    nInjectedPLTI(:,iTeff) = nDetectedPLTI(:,iTeff) + nMissedPLTI(:,iTeff);
    
    % Detection efficiency vs MES for PLTI
    detectionEfficiencyPLTI(:,iTeff) = nDetectedPLTI(:,iTeff)./nInjectedPLTI(:,iTeff);
    
    % Mean detection efficiency vs MES for FLTI
    detectionEfficiencyFLTI = mean(nDetectedAll./(nDetectedAll+nMissedAll),2);
    
    % Plot Detection efficiency vs. MES
   
    figure
    hold on
    box on
    grid on
    plot(mesBinCenters,detectionEfficiencyPLTI(:,iTeff),'b.-')
    plot(midMesBin,detectionEfficiencyFLTI,'r.-')
    title(sprintf('Detection Efficiency vs. MES for PLTI vs FLTI on stars selected by:\n17 Quarters, logg >= %6.1f\n%6.0f days < period <%6.0f days\n%6.0f < Teff < %6.0f',minLogg, MIN_PERIOD_DAYS,MAX_PERIOD_DAYS,TeffLow{iTeff},TeffHigh{iTeff}))
    xlabel('expected MES')
    ylabel('Recovery Rate')
    legend('PLTI','FLTI','Location','SouthEast')
    set(gca,'FontSize',12)
    set(findall(gcf,'type','text'),'FontSize',12)
    plotName = strcat('detection_efficiency_vs_MES_PLTI_vs_FLTI',periodLabel);
    print('-dpng','-r150',strcat(pltiResultsDir,plotName,'.png'))

    
end % loop over stellar types

