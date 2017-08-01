% analyze_mock_plti_run.m
% Analyze the detection efficiency curve from the mock plti run
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

close all

%==========================================================================
% Directories

% !!!!! Directory for PLTI taskfiles
mockPltiTaskFilesDir = '/path/to/transitInjections/KSOC-5038/Full_Run_FLTI_with_PLTI_Light_Curves/tps-matlab-2016238/';

% !!!!! Local directory for PLTI results
pltiDataDir = '/path/to/transit_injection/plti_results/';
mockPltiResultsDir = '/path/to/transit_injection/mock_plti_results/';

% !!!!! Directory for TIP file
tipFile = '/path/to/ksoc-4995-expected-mes/dv-tip-compare/dv-tip-compare-reduex.mat';

% Base directory for scripts
baseDir = '/path/to/matlab/tps/search/test/transit-injection-analysis/';

%==========================================================================
% Control parameters

% Option to fit detection efficiency
fitDetectionEfficiency = false;

% Choose model for detection efficiency
detectionEfficiencyModelName = 'L'; % logistic

% !!!!! Choose method of approximating expected MES
MES_FORMULA = 'A';
% See excerpt below, from Chris Burke's 'FLTI_oputput_cliff_notes.txt' on KSO-460
% Nominally, the pixel-level side calculates the expected MES by 'injected depth at mid-transit' / 'CDPP noise appropriate for duration' * sqrt('A deweight corrected number of transits')
% From Flux-level transit injection the closest surrogate we have is calculated by
% MES = injectedDepthPpm * 1.0e-6 * normSum111  (A)
% From FLTI we report the injected depth and normSum111 is an estimate of the noise taking into account the deweights and missing transits
% ***When doing PLTI analysis we will need to read in the injectedDepths from somewhere else.  I am not sure what we are reporting for injected depth in this case***
% The MES calculated by equation (A) will overestimate the MES when compared to what TPS actually measures.
% The MES as returned by TPS is degraded by the whitening filter supressing the depth.  Thus,
% MES = corrSum111 / normSum111 (B)
% differences between (A) and (B) imply that TPS 'sensed' a shallower effective depth after whitening than
% what was injected

% Color wheel
xColor = 'mbgrk';

% MES bins for detection efficiency
% DELMES=0.25; % For FLTI
% DELMES=0.5; % For PLTI
DELMES = 0.5;
MINMES = 3;
MAXMES = 25;
xedges=(MINMES:DELMES:MAXMES)';
midMesBin=(xedges(1:end-1)+diff(xedges)/2.0);

% Period limits
MIN_PERIOD_DAYS = input('Minimum injected period in days -- 0.5 is default -- ');
MAX_PERIOD_DAYS = input('Maximum injected period in days -- 500 is default -- ');
periodLabel = ['period_',num2str(MIN_PERIOD_DAYS),'_to_',num2str(MAX_PERIOD_DAYS),'_days'];
periodLabel2 = [num2str(MIN_PERIOD_DAYS),' days < P < ',num2str(MAX_PERIOD_DAYS),' days'];
DEL_PERIOD_DAYS = 2;
pedges=(MIN_PERIOD_DAYS:DEL_PERIOD_DAYS:MAX_PERIOD_DAYS)';
midPeriodBin=pedges(1:end-1)+diff(pedges)/2.0;

%==========================================================================
% Federation

% Load Chris' federation file
% column2 is keplerIds
% column7 is match flags
% NOTE -- the federation file is used to eliminate TCEs that were not
% injected. But in the mock PLTI run, TPS searches only the injected TCEs,
% so don't need this.
skipThis = true;
if(~skipThis)
    if(~exist('matchData','var'))
        fprintf('Loading federation file...\n')
        matchData = dlmread(strcat(pltiDataDir,'injmatch_DR25_03182016.txt'));
    end
    keplerIdMatched = matchData(:,2);
    matchIdx = logical(matchData(:,8));
end

%==========================================================================
% Get stellar parameters from completeStructArray database

% Load the completeStructArray with stellar parameters created by Chris Burke in KSO-416
if(~exist('completeStructArray','var'))
    fprintf('Loading stellar parameters database...\n')
    load('/path/to/so-products-DR25/Complete_Seed_DR25_04-05-2016.mat');
end

% Get keplerId and other stellar parameters
keplerIdAll = [completeStructArray.keplerId]';
RAall = [completeStructArray.new3ra]';
DECall = [completeStructArray.new3dec]';
new3rstarAll = [completeStructArray.new3rstar]';
new3teffAll = [completeStructArray.new3teff]';
new3loggAll = [completeStructArray.new3logg]';
new3ValidKicAll = [completeStructArray.new3ValidKic]';
kpmagAll = [completeStructArray.kpmag]';

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
% Match the mock PLTI targets to the Kepler targets in the completeStructArray database

% Load the PLTI results file
if(~exist('tpsInjectionStruct','var'))
    load(strcat(mockPltiTaskFilesDir,'tps-injection-struct.mat'));
end

% Match PLTI targets to completeStructArray;
% locAll is index in keplerIdAll for PLTI targets
[TFall , locAll] = ismember(tpsInjectionStruct.keplerId,keplerIdAll);

% Get cdpp slope: takes ~150 sec
% Modified: uses ordinary least squares instead of robust least squares
skip = true;
if(~skip)
    if(~exist('cdppSlope','var'))
        fprintf('Computing CDPP slope for all targets...\n')
        cdppSlope = get_cdpp_slope(rmsCdpp2All(locAll,:),rmsCdpp1All(locAll,:));
    end
end

% Dataspan
dataSpans = dataSpansAll(locAll);

% Indicator for PLTI targets indexed to federation file; locMatched is
% index of PLTI targets in federation file
% [TFmatched, locMatched] = ismember(tpsInjectionStruct.keplerId,keplerIdMatched);

% Check
% xx = keplerIdMatched(locMatched);
% yy = double(keplerIdAll(locAll));

% Match indicator, ordered as the injection list
% matchIndicator = matchIdx(locMatched);


%==========================================================================================================
% TIP data wrangling
if(~exist('tipData','var'))
    fprintf('Loading TIP file ...\n')
    load(tipFile);
end

transitOffsetEnabled = logical(tipData.transitOffsetEnabled);
% There are 209081 injection targets
% There are 173780 on-target injections and 35301 off-target injections
% The off-target injections are all on nonDuplicateKeplerIds (see below)
onTargetInjectionIdx = ~transitOffsetEnabled;

% Targets with EBs are the ones with duplicate keplerIds
% Want to eliminate all keplerIds that occur twice, i.e.
% identify keplerIds that are not duplicate
% NOTE -- add this code to analyze_plti.m
[~, uniqueKeplerIdInds, ~] = unique(tipData.keplerId);
allKeplerIdInds = (1:length(tipData.keplerId))';
% Identify 10,400 duplicate keplerIds
% So there are 20,800 total instances of duplicate keplerIds
duplicateKeplerIdInds = setdiff( allKeplerIdInds,uniqueKeplerIdInds);
% Identify keplerIds that are unique in the sense that they each have only
% one TCE, i.e. they occur only once in the list
nonDuplicateKeplerIds = setdiff(tipData.keplerId,tipData.keplerId(duplicateKeplerIdInds));

% Indicator for injections on nonDuplicateKeplerIds -- there are 188281
nonDuplicateTargetIdx = ismember(tipData.keplerId,nonDuplicateKeplerIds);

% Logical indicator for valid injection targets
validTipTargetIdx = onTargetInjectionIdx & nonDuplicateTargetIdx;
% keplerIds of valid injection targets
tipKeplerId = tipData.keplerId(validTipTargetIdx);

% !!!!! Injected depths corresponding to valid injection targets
% This is the injectedDepth to use for computation of expected MES via
% Formula A. See discussion on KSO-460
tipInjectedDepth = tipData.pdcMedianInjectedTransitDepthTps(validTipTargetIdx);

% Match tpsInjectionStruct.keplerId to the validInjectionTargetKeplerIds
[validFltiTargetIdx, LOC] = ismember(tpsInjectionStruct.keplerId,tipKeplerId);

% Construct validInjectionDepth corresponding to tpsInjectionStruct.keplerIds
% Entries are NaN for keplerIds that will ultimately not be included among
% the valid injection targets
measuredMidTransitDepth = nan(size(tpsInjectionStruct.keplerId));
measuredMidTransitDepth(validFltiTargetIdx) = tipInjectedDepth(LOC(LOC>0));

% Using LOC(LOC>0) to index tipKeplerId gives the
% same order as tpsInjectionStruct.keplerId(validFltiTargetIdx)
% Check:
% sum(abs(double(tpsInjectionStruct.keplerId(validFltiTargetIdx)) - double(tipKeplerId(LOC(LOC>0)))))

%==========================================================================
% Planet parameter selection

% impactParameter = zeros(length(tipData.injectedPlanetModelStruct),1);
% for iTarget = 1:length(tipData.injectedPlanetModelStruct)
%    impactParameter(iTarget) = tipData.injectedPlanetModelStruct(iTarget).planetModel.minImpactParameter;
% end

% Orbital period selection
periodIdx = tpsInjectionStruct.periodDays > MIN_PERIOD_DAYS & tpsInjectionStruct.periodDays < MAX_PERIOD_DAYS; % 209081 (all)

% Impact parameter
% impactParameter = tpsInjectionStruct.impactParameter;

% Select on impact parameter
% impactParameterIdx = impactParameter < 0.6;

% !!!!! Get isPlanetACandidate
% isPlanetACandidate = tipData.isPlanetCandidateTps; % 95442 are true
% isPlanetACandidate = tpsInjectionStruct.isPlanetACandidateWhenSearchedWithInjectedPeriodAndDuration;
% Don't use isPlanetACandidateWhenSearchedWithInjectedPeriodAndDuration
% because it can be contaminated, according to Chris.
isPlanetACandidate = tpsInjectionStruct.isPlanetACandidate;

% Set isPlanetACandidate to 0 if there is no match
% isPlanetACandidate(~tipData.dvMatch) = 0; % 73941 are true
% Eliminate all TCEs that were not injected
% isPlanetACandidate(~matchIndicator) = 0; % 79396 are true

%==========================================================================
% Stellar parameter selection

% logg
loggIdx = tpsInjectionStruct.log10SurfaceGravity >= 4; % 165453

% !!!!! NOTE after conv. with Chris Burke:
%       Apples-to-apples approx. to windowed MES is injectedDepth*1.e-6*normsum111
%       Use MES_FORMULA == 'A'

switch MES_FORMULA
    case 'A'
        % Need measured mid-transit depth
        windowedMesApprox = 1.e-6*measuredMidTransitDepth.*tpsInjectionStruct.normSum111;
        mesFormulaString = 'Expected MES -- approx by 1.e-6*injectedDepthPpm.*normSum111';
    case 'B'
        windowedMesApprox = tpsInjectionStruct.corrSum111./tpsInjectionStruct.normSum111;
        mesFormulaString = 'Expected MES -- approx by corrSum111./normSum111';
end

% M stars
tEffIdxAll{1} = tpsInjectionStruct.effectiveTemp >= 2400 & tpsInjectionStruct.effectiveTemp < 3900;

% K stars
tEffIdxAll{2} = tpsInjectionStruct.effectiveTemp >= 3900 & tpsInjectionStruct.effectiveTemp < 5000;

% G stars
tEffIdxAll{3} = tpsInjectionStruct.effectiveTemp >= 5000 & tpsInjectionStruct.effectiveTemp < 6000;

% F stars
tEffIdxAll{4} = tpsInjectionStruct.effectiveTemp >= 6000 & tpsInjectionStruct.effectiveTemp < 7000;

% All stars
tEffIdxAll{5} = tpsInjectionStruct.effectiveTemp >= 2400 & tpsInjectionStruct.effectiveTemp < 7000;

% Choose temp range
skip = true;
if(~skip)
    iTeffChoice = input('iTeff: 1 (2400 < Teff < 3900), 2 (3900 < Teff < 5000), 3 (5000 < Teff < 6000), 4 (6000 < Teff < 7000), 5 (2400 < Teff < 7000) -- ');
    
    switch iTeffChoice
        case 1
            teffLabel = 'M';
        case 2
            teffLabel = 'K';
        case 3
            teffLabel = 'G';
        case 4
            teffLabel = 'F';
        case 5
            teffLabel = 'FGKM';
    end
end

% Trial parameter values for fits
trialStartingPoints{1} = [1,10,0.6];
trialStartingPoints{2} = [1,1,1];
trialStartingPoints{3} = [1,5,1];
trialStartingPoints{4} = [1,1,1];
trialStartingPoints{5} = [1,10,0.6];

%==========================================================================
% Matching

% DV match
% dvMatchIndicator = tipData.dvMatch;


%==========================================================================
% Count valid injections that were detected and that were missed
% fprintf('Selecting injections with 17 Q data & P < 240 days & logg > 4 & 3 or more transits\n')

% Loop over temperature ranges

% Offset for figure numbers
offset = 3;

figure(1+offset)

figure(2+offset)
hold on
box on
grid on

skip = false;
if(~skip)
    figure(3+offset)
    hold on
    box on
    grid on
end

if(fitDetectionEfficiency)
    figure(10+offset)
    hold on
    box on
    grid on
    
    figure(20+offset)
    hold on
    box on
    grid on
end

% !!!!! Loop over temperature ranges
nValidTargets = zeros(5,1);
for iTeff = 1:5 % All FGKM stars
    
    % Select stars in specified range
    tEffIdx = tEffIdxAll{iTeff};
    
    % fitSinglePulse and numSesInMes
    fitSinglePulse = tpsInjectionStruct.fitSinglePulseWhenSearchedWithInjectedPeriodAndDuration;
    numSesInMes = tpsInjectionStruct.numSesInMesWhenSearchedWithInjectedPeriodAndDuration;
        
    
    % !!!!! Count valid injections
    % Exclude injections that
    %   * don't meet stellar and planet, selection critera, or
    %   * violate the window function, or
    %   * were on duplicate or EB injection targets
    validInjectionIndicator = ...
        periodIdx & loggIdx & tEffIdx & ...
        fitSinglePulse == 0 & numSesInMes >=3 & ...
        validFltiTargetIdx;
    
    nValidTargets(iTeff) = sum(validInjectionIndicator);
    fprintf('iTeff = %d -- %d targets selected  \n', ...
        iTeff,sum(validInjectionIndicator))
    
    
    % MES of valid injections that did not become TCEs
    mesMissed = windowedMesApprox(isPlanetACandidate == 0 & validInjectionIndicator  );
    
    % MES of valid injections that became TCEs
    mesDetected = windowedMesApprox(isPlanetACandidate == 1 & validInjectionIndicator );
    
    % Histogram of MES of missed TCEs
    nMissedTemp = histc(mesMissed,xedges);
    nMissed = nMissedTemp(1:end-1);
    
    % Histogram of MES of detected TCEs
    nDetectedTemp = histc(mesDetected,xedges);
    nDetected = nDetectedTemp(1:end-1);
    
    % Number of injected TCEs
    nInjected = nDetected + nMissed;
    
    % Detection efficiency vs MES
    detectionEfficiency = nDetected./nInjected;
    
    % Detection efficiency error due to binomial counts
    % Reference for this formula is Chris Burke's entry in KSOC-4861,on 17
    % Aug 2015
    % std=sqrt[((1/N+1-f)(1/N+f))/((2/N+1)^2(3+N))] 
    detectionEfficiencyError = ...
        sqrt( (1./nInjected+1.0-detectionEfficiency).*(1./nInjected+detectionEfficiency)./ ...
            ((2.0*1./nInjected+1.0).*(2.0*1./nInjected+1.0).*(3.0+nInjected)) );

    
    
    %==================================================================
    % Window function vs period
    
    % Binned detections and misses
    periodMissed = tpsInjectionStruct.periodDays(isPlanetACandidate == 0 & validInjectionIndicator );
    periodDetected = tpsInjectionStruct.periodDays(isPlanetACandidate == 1 & validInjectionIndicator );
    
    % Histogram of period of missed TCEs
    nMissedTempWF = histc(periodMissed,pedges);
    nMissedWF = nMissedTempWF(1:end-1);
    
    % Histogram of period of detected TCEs
    nDetectedTempWF = histc(periodDetected,pedges);
    nDetectedWF = nDetectedTempWF(1:end-1);
    
    % Number of injected TCEs
    nInjectedWF = nDetectedWF + nMissedWF;
    
    % Window function vs period
    windowFunction = nDetectedWF./nInjectedWF;
    
    % Plot Window Function
    plotWindowFunction = false;
    if(plotWindowFunction)
        
        figure
        hold on
        box on
        grid on
        
        plot(midPeriodBin',windowFunction,'k.-')
        plot(midPeriodBin',windowFunction,'r.')
        
        % Savitzky-Golay smoothing with 3rd order polynomial, and
        % window size 5
        polyOrder = 3;
        frameSize = 5;
        % plot(midPeriodBin',sgolayfilt(windowFunction,polyOrder,frameSize),'b-','LineWidth',2)
        
        
        title(sprintf('Empirical Window Function for pixel-level injections on %d stars selected by:\n17 Quarters, logg >= 4, MES > 16, b < 0.6,%6.1f days < period <%6.0f days',sum(validInjectionIndicator),MIN_PERIOD_DAYS,MAX_PERIOD_DAYS))
        axis([0,MAX_PERIOD_DAYS,0,1.2])
        set(gca,'FontSize',12)
        set(findall(gcf,'type','text'),'FontSize',12)
        xlabel('Orbital Period [Days]')
        ylabel('Recovery Rate')
        plotName = 'all_stars_window_function_with_impact_parameter';
        print('-dpng','-r150',strcat(mockPltiResultsDir,plotName))
        
    end
    
    
    %==================================================================
    
    
    % Fit model detection efficiency curves, using binomial hyperpriors
    
    % Option to fit detection efficiency curve
    if(fitDetectionEfficiency)
        
        % Max mes for fit
        maxMesForFit = midMesBin(end); % no truncation
        useBinInFit = midMesBin <= maxMesForFit;
        midMesBinsUsed = midMesBin(useBinInFit);
        detectionEfficiencyUsed = detectionEfficiency(useBinInFit);
        fprintf('Fitting detection efficiency for MES < %d: using %d of %d MES bins\n',maxMesForFit,sum(useBinInFit),length(midMesBin))
        
        
        % Initialize
        optOrig = optimset('fminsearch');
        
        % Setting MaxFunEvals and MaxIter to defaults of 3*numbeOfVariables
        % optNew = optimset(optOrig,'TolFun',1.e-4,'TolX',1.e-4,'MaxFunEvals',600,'MaxIter',600);
        optNew = optimset(optOrig,'TolFun',1.e-2,'TolX',1.e-2,'MaxFunEvals',600,'MaxIter',600);
        options = optimset(optNew);
        
        % Fit the detection efficiency curve
        % Cost function to be optimized using fminsearch
        % Find starting point for search
        skip = true;
        
        % Try a grid of starting points
        fprintf('Fitting the ensemble detection efficiency curve for PLTI\n')
        fprintf('Optimizing starting point ...\n');
        nGrid = 10;
        x1grid = 10*(rand(1,nGrid));
        x2grid = 10*(5-rand(1,nGrid));
        switch detectionEfficiencyModelName
            case 'G'
                costFunction = @(x) sum( (detectionEfficiencyUsed - gamcdf(midMesBin'- x(3),x(1),x(2))).^2 );
                x3grid = 4 + rand(1,nGrid);
            case 'L'
                generalizedLogisticFunction = @(x) 1./(1+exp(-x(1).*(midMesBinsUsed'-x(2)))).^x(3);
                costFunction = @(x)sum ( ( detectionEfficiencyUsed -  generalizedLogisticFunction(x) ).^2 );
                x3grid = 10*(rand(1,nGrid));
        end
        
        
        if(~skip)
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
            
        end % skip
        
        % Trial starting point
        % x0 = [1 1 1];
        x0 = trialStartingPoints{iTeff};
        
        
        %==============================================================
        % Fit point estimate of detection efficiency model directly
        % from measured data
        
        
        % Fit the model function using best starting point
        fprintf('Fitting detection efficiency curve...\n')
        [x, fval, exitflag, output] = fminsearch(costFunction,x0,options);
        
        % Generate the model function for the fit to the data
        switch detectionEfficiencyModelName
            case 'G'
                fprintf('exitflag %d fval %8.4f, fitted gamma parameters: A = %8.4f, B = %8.4f, offset = %8.4f\n\n',exitflag,fval,x(1),x(2),x(3))
                detectionEfficiencyModel0 = gamcdf(midMesBin - x(3),x(1),x(2));
                % legendString2 = sprintf('Gamma CDF: A%8.4f, B%8.4f, Offset%8.4f',x(1),x(2),x(3));
            case 'L'
                fprintf('exitflag %d fval %8.4f, fitted logistic parameters: x1 = %8.4f, x2 = %8.4f, x3 = %8.4f \n\n',exitflag,fval,x(1),x(2),x(3))
                detectionEfficiencyModel0 = generalizedLogisticFunction([x(1),x(2),x(3)]);
                % legendString2 = sprintf('Generalized Logistic Function: A%10.4f, B%10.4f, C%10.4f',x(1),x(2),x(3));
        end
        
        %==============================================================
        % Monte Carlo loop to re-sample data from binomial distribution
        % and from Gaussian distribution
        
        % Initialize
        nSamples = 25;
        fvalAllBin = zeros(1,nSamples);
        fvalAllGauss = zeros(1,nSamples);
        exitflagAllBin = zeros(1,nSamples);
        exitflagAllGauss = zeros(1,nSamples);
        parameter1Bin = zeros(1,nSamples);
        parameter2Bin = zeros(1,nSamples);
        parameter3Bin = zeros(1,nSamples);
        parameter1Gauss = zeros(1,nSamples);
        parameter2Gauss = zeros(1,nSamples);
        parameter3Gauss = zeros(1,nSamples);
        detectionEfficiencyModelBin = zeros(size(detectionEfficiencyUsed));
        detectionEfficiencyModelGauss = zeros(size(detectionEfficiencyUsed));
        
        % Progress bar for MC
        h = waitbar(0,'1','Name','Drawing samples from posterior PDF ...',...
            'CreateCancelBtn',...
            'setappdata(gcbf,''canceling'',1)');
        setappdata(h,'canceling',0)
        
        % Draw samples
        for iSample = 1:nSamples
            
            h = waitbar(iSample/nSamples,h,' percent done');
            
            
            % Replace detection efficiency curve with a set of points
            % drawn from the appropriate binomial distribution
            detectionEfficiencySampledBin = binornd(nInjected,detectionEfficiencyUsed)./(nInjected);
            
            % Sample from Gaussian errors: assuming nInjected > 0
            % If we estimate detection efficiency as p = D/N
            % Then the variance of p is p * ( 1 - p ) / N
            % From https://en.wikipedia.org/wiki/Binomial_proportion_confidence_interval
            % "The central limit theorem applies poorly to this distribution  with a
            % sample size less than 30 or where the proportion is close to 0 or 1.
            % The normal approximation fails totally when the sample proportion is
            % exactly zero or exactly one. A frequently cited rule of thumb is that
            % the normal approximation is a reasonable one as long as np > 5 and
            % n(1 − p) > 5, however even this is unreliable in many
            % cases."
            sigmaGauss = sqrt( detectionEfficiencyUsed .* ( 1 - detectionEfficiencyUsed ) ./ nInjected  );
            detectionEfficiencySampledGauss = detectionEfficiencyUsed + sigmaGauss.*randn(size(detectionEfficiencyUsed));
            
            % Using generalized logistic function
            % generalizedLogisticFunction = @(x) 1./(1+exp(-x(1).*(midMesBinsUsed'-x(2)))).^x(3);
            costFunctionBin = @(x)sum ( ( detectionEfficiencySampledBin -  generalizedLogisticFunction(x) ).^2 );
            costFunctionGauss = @(x)sum ( ( detectionEfficiencySampledGauss -  generalizedLogisticFunction(x) ).^2 );
            
            % Fit the model function using best starting point
            fprintf('Fitting detection efficiency curve...\n')
            [xBin, fvalAllBin(iSample), exitflagAllBin(iSample), ~] = fminsearch(costFunctionBin,x0,options);
            [xGauss, fvalAllGauss(iSample), exitflagAllGauss(iSample), ~] = fminsearch(costFunctionGauss,x0,options);
            
            % Generate the model function
            switch detectionEfficiencyModelName
                case 'G'
                    fprintf('Bin Sample #%d exitflag %d fval %8.4f, fitted gamma parameters: A = %8.4f, B = %8.4f, offset = %8.4f\n\n',iSample,exitflagAllBin(iSample),fvalAllBin(iSample),xBin(1),xBin(2),xBin(3))
                    fprintf('Gauss Sample #%d exitflag %d fval %8.4f, fitted gamma parameters: A = %8.4f, B = %8.4f, offset = %8.4f\n\n',iSample,exitflagAllGauss(iSample),fvalAllGauss(iSample),xGauss(1),xGauss(2),xGauss(3))
                    detectionEfficiencyModelBin(:,iSample) = gamcdf(midMesBin - xBin(3),xBin(1),xBin(2));
                    detectionEfficiencyModelGauss(:,iSample) = gamcdf(midMesBin - xGauss(3),xGauss(1),xGauss(2));
                    % legendString2 = sprintf('Gamma CDF: A%8.4f, B%8.4f, Offset%8.4f',x(1),x(2),x(3));
                case 'L'
                    fprintf('Bin Sample #%d exitflag %d fval %8.4f, fitted logistic parameters: x1 = %8.4f, x2 = %8.4f, x3 = %8.4f \n\n',iSample,exitflagAllBin(iSample),fvalAllBin(iSample),xBin(1),xBin(2),xBin(3))
                    fprintf('Gauss Sample #%d exitflag %d fval %8.4f, fitted logistic parameters: x1 = %8.4f, x2 = %8.4f, x3 = %8.4f \n\n',iSample,exitflagAllGauss(iSample),fvalAllGauss(iSample),xGauss(1),xGauss(2),xGauss(3))
                    detectionEfficiencyModelBin(:,iSample) = generalizedLogisticFunction([xBin(1),xBin(2),xBin(3)]);
                    detectionEfficiencyModelGauss(:,iSample) = generalizedLogisticFunction([xGauss(1),xGauss(2),xGauss(3)]);
                    % legendString2 = sprintf('Generalized Logistic Function: A%10.4f, B%10.4f, C%10.4f',x(1),x(2),x(3));
            end
            
            % Fitted model parameters
            parameter1Bin(iSample) = xBin(1);
            parameter2Bin(iSample) = xBin(2);
            parameter3Bin(iSample) = xBin(3);
            
            % Fitted model parameters
            parameter1Gauss(iSample) = xGauss(1);
            parameter2Gauss(iSample) = xGauss(2);
            parameter3Gauss(iSample) = xGauss(3);
            
            
            % Scatter plot of sampled binomial detection efficiency points and
            % fitted curve
            figure(10+offset)
            % plot(midMesBin,detectionEfficiencyModelBin,[xColor(iTeff),'-'])
            plot(midMesBin,detectionEfficiencySampledBin,'k+')
            
            % Scatter plot of sampled gaussian detection efficiency points and
            % fitted curve
            figure(10+offset)
            % plot(midMesBin,detectionEfficiencyModelGauss,[xColor(iTeff),'-'])
            plot(midMesBin,detectionEfficiencySampledGauss,'rx')
            
            
            figure(20+offset)
            plot(midMesBin,detectionEfficiencyUsed - detectionEfficiencySampledGauss,'rx')
            plot(midMesBin,detectionEfficiencyUsed - detectionEfficiencySampledBin,'k+')
            
            
        end % Monte Carlo loop
        
        delete(h)
        
        
        % Maximize posterior pdf for detection efficiency curve from median of fitted parameters
        medianX1Bin = median(parameter1Bin);
        medianX2Bin = median(parameter2Bin);
        medianX3Bin = median(parameter3Bin);
        
        % Maximize posterior pdf for detection efficiency curve from median of fitted parameters
        medianX1Gauss = median(parameter1Gauss);
        medianX2Gauss = median(parameter2Gauss);
        medianX3Gauss = median(parameter3Gauss);
        
        % Generate the model function that maximizes posterior PDF
        switch detectionEfficiencyModelName
            case 'G'
                detectionEfficiencyBestBin = gamcdf(midMesBin - medianX3Bin,medianX1Bin,medianX2Bin);
                detectionEfficiencyBestGauss = gamcdf(midMesGauss - medianX3Gauss,medianX1Gauss,medianX2Gauss);
                % legendString2 = sprintf('Gamma CDF: A%8.4f, B%8.4f, Offset%8.4f',medianX1Bin,medianX2Bin,medianX3Bin);
            case 'L'
                detectionEfficiencyBestBin = generalizedLogisticFunction([medianX1Bin,medianX2Bin,medianX3Bin]);
                detectionEfficiencyBestGauss = generalizedLogisticFunction([medianX1Gauss,medianX2Gauss,medianX3Gauss]);
                % legendString2 = sprintf('Generalized Logistic Function: A%10.4f, B%10.4f, C%10.4f',x(1),x(2),x(3));
        end
        
        % Plot detection efficiency curve estimated from median of binomial draws.
        figure(10+offset)
        plot(midMesBin,detectionEfficiencyBestBin,'k--','Linewidth',2')
        
        % Plot detection efficiency curve estimated from median of Gaussian draws.
        figure(10+offset)
        plot(midMesBin,detectionEfficiencyBestGauss,'r--','Linewidth',2')
        
        % Point estimate detection efficiency curve
        figure(10+offset)
        plot(midMesBin,detectionEfficiencyUsed,'g.','Linewidth',2')
        
        % Detection efficiency model curve fitted *directly* from data points
        figure(10+offset)
        plot(midMesBin,detectionEfficiencyModel0,'g--','LineWidth',2)
        
        
        % Plot median of sampled detection efficiency curves
        % figure(10+offset)
        % plot(midMesBin,median(detectionEfficiencyModel,2),'m-.','Linewidth',2')
        
        % Residuals between dete eff and
        % best fit from point estimates
        % median fit with binomial errors
        % median fit with gaussian errors
        figure(20+offset)
        plot(midMesBin+0.05,detectionEfficiencyUsed - detectionEfficiencyBestGauss,'rp')
        plot(midMesBin+0.05,detectionEfficiencyUsed - detectionEfficiencyBestBin,'kp')
        
        figure(10+offset)
        % legend('M','K','G','F','Location','NorthWest')
        title(sprintf('Detection efficiency for pixel-level injections on G stars\nCDPP slope < 0, logg > 4, %6.1f days < period < %6.0f days\nGeneralized Logistic Function Model\n(1+exp(-alpha.*(MES-beta)))**(-gamma)',MIN_PERIOD_DAYS,MAX_PERIOD_DAYS))
        axis([MINMES-1,MAXMES,0,inf])
        set(gca,'FontSize',12)
        set(findall(gcf,'type','text'),'FontSize',12)
        xlabel(mesFormulaString)
        ylabel('Detection efficiency')
        plotName = 'Gstar_detection_efficiency_curve';
        print('-dpng','-r150',strcat(mockPltiResultsDir,plotName))
        
        
        figure(20+offset)
        % legend('M','K','G','F','Location','NorthWest')
        title(sprintf('Detection efficiency resduals for pixel-level injections on G stars\nCDPP slope < 0, logg > 4, %6.1f days < period < %6.0f days\nGeneralized Logistic Function Model\n(1+exp(-alpha.*(MES-beta)))**(-gamma)',MIN_PERIOD_DAYS,MAX_PERIOD_DAYS))
        axis([MINMES-1,MAXMES,-inf,inf])
        set(gca,'FontSize',12)
        set(findall(gcf,'type','text'),'FontSize',12)
        xlabel(mesFormulaString)
        ylabel('Detection efficiency minus model')
        plotName = 'Gstar_detection_efficiency_residuals';
        print('-dpng','-r150',strcat(mockPltiResultsDir,plotName))
        
    end % fitDetectionEfficiency
    
    %==================================================================
    % Plots

    % Plot theoretical cumulative distribution vs. MES
    % plot(midMesBin,cdf('norm',midMesBin,7.1,1),'k-','LineWidth',3)
    % vline(7.1)
    
    % Ninjections vs. MES
    figure(1+offset)
    % hold on
    % box on
    % grid on
    semilogy(midMesBin,nInjected,[xColor(iTeff),'.-'])
    % plot(midMesBin,nDetected,'g.-')
    % plot(midMesBin,nMissed,'r.-')
    % legend('total injections','detected injections','missed injections','Location','NorthEast')
    % plotName = strcat(pltiDetectionEfficiencyDir,'n_injected_vs_MES');
    % print('-r150','-dpng',plotName)
    hold on
    
    % Detection efficiency vs. MES, with estimated error bars
    figure(2+offset)
    hold on
    % box on
    % grid on
    % plot(midMesBin,detectionEfficiency,[xColor(iTeff),'.-'])
    errorbar(midMesBin,detectionEfficiency,detectionEfficiencyError,[xColor(iTeff),'-'],'LineWidth',2)
    % plotName = strcat(pltiDetectionEfficiencyDir,'detection_efficiency_vs_MES');
    % print('-r150','-dpng',plotName)
    hold on
    
    
    % Estimated detection probability
    skip = false;
    if(~skip)
        figure(3+offset)
        hold on
        % box on
        % grid on
        plot(midMesBin,detectionEfficiencyError,[xColor(iTeff),'.-'])
        % plot(midMesBin,sqrt(nInjected)./nInjected,[xColor(iTeff),'.-'])
        % plotName = strcat(pltiDetectionEfficiencyDir,'fractional_poisson_noise_vs_MES');
        % print('-r150','-dpng',plotName)
        hold on
    end
    
end % loop  over ranges of Teff


% Finalize plots
figure(1+offset)
axis([MINMES-1,MAXMES,0,inf])
legend([num2str(nValidTargets(1)),' M: 2400<T<3900'],[num2str(nValidTargets(2)),' K: 3900<T<5000'],[num2str(nValidTargets(3)),' G: 5000<T<6000'],[num2str(nValidTargets(4)),' F: 6000<T<7000'],[num2str(nValidTargets(5)),' FGK: 2400<T<7000'],'Location','SouthWest')
set(gca,'FontSize',12)
set(findall(gcf,'type','text'),'FontSize',12)
titleString = sprintf('Mock PLTI run\nNumber of Injections\n%s ',periodLabel2);
title(titleString)
xlabel(mesFormulaString)
ylabel('Counts')
box on
grid on
plotName = strcat(mockPltiResultsDir,'number_of_injections_',periodLabel,'.png');
print('-dpng','-r150',plotName)


figure(2+offset)
axis([MINMES-1,MAXMES,0,inf])
legend([num2str(nValidTargets(1)),' M: 2400<T<3900'],[num2str(nValidTargets(2)),' K: 3900<T<5000'],[num2str(nValidTargets(3)),' G: 5000<T<6000'],[num2str(nValidTargets(4)),' F: 6000<T<7000'],[num2str(nValidTargets(5)),' FGK: 2400<T<7000'],'Location','SouthEast')
set(gca,'FontSize',12)
set(findall(gcf,'type','text'),'FontSize',12)
titleString = sprintf('Mock PLTI run\nDetection Efficiency\n%s ',periodLabel2);
title(titleString)
xlabel(mesFormulaString)
ylabel('Fraction recovered')
plotName = strcat(mockPltiResultsDir,'detection_efficiency_',periodLabel,'.png');
print('-dpng','-r150',plotName)


figure(3+offset)
axis([MINMES-1,MAXMES,0,inf])
legend([num2str(nValidTargets(1)),' M: 2400<T<3900'],[num2str(nValidTargets(2)),' K: 3900<T<5000'],[num2str(nValidTargets(3)),' G: 5000<T<6000'],[num2str(nValidTargets(4)),' F: 6000<T<7000'],[num2str(nValidTargets(5)),' FGK: 2400<T<7000'],'Location','NorthWest')
set(gca,'FontSize',12)
set(findall(gcf,'type','text'),'FontSize',12)
titleString = sprintf('Mock PLTI run\nDetection Efficiency Error due to Binomial Count Noise\n%s ',periodLabel2);
title(titleString)
xlabel(mesFormulaString)
ylabel('Detection Efficiency Error')
plotName = strcat(mockPltiResultsDir,'detection_efficiency_error_',periodLabel,'.png');
print('-dpng','-r150',plotName)





