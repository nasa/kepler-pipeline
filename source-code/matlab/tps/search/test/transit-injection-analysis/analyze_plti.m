% analyze_plti.m
% Analyze pixel-level transit injection data for 9.3
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

% Directory for PLTI taskfiles
pltiTipDataDir = '/path/to/ksoc-4995-expected-mes/dv-tip-compare/';

% Directory for PLTI results
pltiResultsDir = '/codesaver/work/transit_injection/plti_results/';

% Base directory for scripts
baseDir = '/path/to/matlab/tps/search/test/transit-injection-analysis/';

% Load Chris' federation file 
% column2 is keplerIds
% column7 is match flags
if(~exist('matchData','var'))
    fprintf('Loading federation file...\n')
    matchData = dlmread(strcat(pltiResultsDir,'injmatch_DR25_03182016.txt'));
end
keplerIdMatched = matchData(:,2);
matchIdx = logical(matchData(:,8));

% Using windowed MES

% Load the PLTI results file
if(~exist('tipData','var'))
    fprintf('Loading tip results file...\n')
    load(strcat(pltiTipDataDir,'dv-tip-compare-reduex.mat'));
end

% Option to fit detection efficiency
fitDetectionEfficiency = false;

% Choose model for detection efficiency
detectionEfficiencyModelName = 'L'; % logistic

%==========================================================================
% Get CDPP slope and stellar parameters

% Load the completeStructArray with stellar parameters created by Chris Burke in KSO-416
if(~exist('completeStructArray','var'))
    fprintf('Loading stellar parameters database...\n')
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

% Match the PLTI targets to the Kepler targets in the database

% Indicator for PLTI targets indexed to keplerIdAll; locAll is index in keplerIdAll for PLTI targets
[TFall , locAll] = ismember(tipData.keplerId,keplerIdAll);

% Get cdpp slope: takes ~150 sec
% Modified: uses ordinary least squares instead of robust least squares
if(~exist('cdppSlope','var'))
    fprintf('Computing CDPP slope for all targets...\n')
    cdppSlope = get_cdpp_slope(rmsCdpp2All(locAll,:),rmsCdpp1All(locAll,:));
end

% Dataspan
dataSpans = dataSpansAll(locAll);

% Indicator for PLTI targets indexed to keplerIdMatched; locMatched is index in keplerIdMatched for PLTI targets
[TFmatched, locMatched] = ismember(tipData.keplerId,keplerIdMatched);

% Check
xx= keplerIdMatched(locMatched);
yy = double(keplerIdAll(locAll));

% Match indicator, ordered as the injection list
matchIndicator = matchIdx(locMatched);

%==========================================================================

% Color wheel
xColor = 'cbgmk';

% MES bins for detection efficiency
% DELMES=0.25; % For FLTI
% DELMES=0.5; % For PLTI
DELMES = 0.5;
MINMES = 3;
MAXMES = 25;
xedges=(MINMES:DELMES:MAXMES)';
midMesBin=(xedges(1:end-1)+diff(xedges)/2.0);

% Skygroups containing offset injections
skyGroupIdsWithTransitOffsetEnabled = unique(tipData.skyGroupId(tipData.transitOffsetEnabled==1));

% Skygroups with EBs are the ones with duplicate keplerIds
[~,uniqueKeplerIdIndices,~] = unique(tipData.keplerId);
duplicateKeplerIdIndices = setdiff( (1:length(tipData.keplerId))',uniqueKeplerIdIndices);
skyGroupIdsWithEbs = unique(tipData.skyGroupId(duplicateKeplerIdIndices));

% Skygroups with EBs or offsets
skyGroupIdsWithEbsOrOffsets = [skyGroupIdsWithEbs ; skyGroupIdsWithTransitOffsetEnabled];

% Indicator for good (non-EB, non-offset injections)
injectionIdx = ~ismember(tipData.skyGroupId,skyGroupIdsWithEbsOrOffsets);

% Number of skyGroups for good injections
nSkyGroupsForInjections = sum(~ismember(unique(tipData.skyGroupId),skyGroupIdsWithEbsOrOffsets));

% Number of TCEs among the good injections
nTces = sum( injectionIdx & tipData.isPlanetCandidateTps);

% Total number of injections in skygroups that don't have EBs or offset
% injections
fprintf('Total number of %d good injections, of which %d are TCEs, in %d skygroups\n',sum(injectionIdx),nTces,nSkyGroupsForInjections)

% Number of injections with zero depth
fprintf('There are %d injections with zero depth\n',sum(tipData.transitDepthPpm==0))

%==========================================================================
% Orbital period Selection

% Period limits
MIN_PERIOD_DAYS = 0.5;
% MIN_PERIOD_DAYS = 20;
% MIN_PERIOD_DAYD = 100;
% MAX_PERIOD_DAYS = 100;
% MAX_PERIOD_DAYS = 240;
MAX_PERIOD_DAYS = 500;


DEL_PERIOD_DAYS = 2;
pedges=(MIN_PERIOD_DAYS:DEL_PERIOD_DAYS:MAX_PERIOD_DAYS)';
midPeriodBin=pedges(1:end-1)+diff(pedges)/2.0;

% Orbital period selection
periodIdx = tipData.orbitalPeriodDays > MIN_PERIOD_DAYS & tipData.orbitalPeriodDays < MAX_PERIOD_DAYS; % 209081 (all)

%=============================
% Planet parameter selection
impactParameter = zeros(length(tipData.injectedPlanetModelStruct),1);
for iTarget = 1:length(tipData.injectedPlanetModelStruct)
   
    impactParameter(iTarget) = tipData.injectedPlanetModelStruct(iTarget).planetModel.minImpactParameter;
    
end

% Select on impact parameter
impactParameterIdx = impactParameter < 0.6;

%==========================================================================
% Stellar parameter selection

% logg
loggIdx = tipData.stellarLog10Gravity >= 4; % 165453

% high mes indicator
highMesIdx = tipData.windowedMes > 16;

% effective temperature
% tEffIdx = tipData.stellarEffectiveTempKelvin > 4000 & tipData.stellarEffectiveTempKelvin < 7000; % 196350

% M stars
tEffIdxAll{1} = tipData.stellarEffectiveTempKelvin >= 2400 & tipData.stellarEffectiveTempKelvin < 3900;

% K stars
tEffIdxAll{2} = tipData.stellarEffectiveTempKelvin >= 3900 & tipData.stellarEffectiveTempKelvin < 5000;

% G stars
tEffIdxAll{3} = tipData.stellarEffectiveTempKelvin >= 5000 & tipData.stellarEffectiveTempKelvin < 6000;

% F stars
tEffIdxAll{4} = tipData.stellarEffectiveTempKelvin >= 6000 & tipData.stellarEffectiveTempKelvin < 7000;

% All stars
tEffIdxAll{5} = tipData.stellarEffectiveTempKelvin >= 2400 & tipData.stellarEffectiveTempKelvin < 7000;

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

% Get isPlanetACandidate
isPlanetACandidate = tipData.isPlanetCandidateTps; % 95442 are true

% Set isPlanetACandidate to 0 if there is no match
% isPlanetACandidate(~tipData.dvMatch) = 0; % 73941 are true
isPlanetACandidate(~matchIndicator) = 0; % 79396 are true
%==========================================================================
% Count valid injections that were detected and that were missed
fprintf('Selecting injections with 17 Q data & P < 240 days & logg > 4 & 3 or more transits\n')

% Loop over temperature ranges and CDPP slope

% !!!!! CDPP slope 
for cdppSlopeIndicator = true;% [false, true]
    
    offset = 3*cdppSlopeIndicator;
    
    figure(1+offset)
    hold on
    box on
    grid on
    
    figure(2+offset)
    hold on
    box on
    grid on
    
    skip = true;
    if(~skip)
        figure(3+offset)
        hold on
        box on
        grid on
    end
    
    
    figure(10+offset)
    hold on
    box on
    grid on
    
    figure(20+offset)
    hold on
    box on
    grid on
    
    % !!!!! Temperature ranges
    for iTeff = 5
        
        % Select stars in specified range
        tEffIdx = tEffIdxAll{iTeff};
        
        % Count valid injections: apply selection criteria
        % Chris: don't use fitSinglePulse; instead select injections with
        % 17 Q of data and period < 240 days
        validInjectionIndicator0 = injectionIdx ...
            & dataSpans == median(dataSpans) ...
            & periodIdx & loggIdx & tEffIdx & highMesIdx & impactParameterIdx;
        % & ~(tipData.nTransitsInt == 3 & tipData.fitSinglePulseTps == 1) ...
        % tipData.nTransitsFracTps >=3 ...
       
        % Select negative or positive CDPP slope
        % validInjectionIndicator = validInjectionIndicator0 & cdppSlope < 0 == cdppSlopeIndicator;
        validInjectionIndicator = validInjectionIndicator0;
        
        fprintf('iTeff = %d -- %d targets selected before CDPP slope selection, %d targets selected after CDPP slope selection \n', ...
            iTeff,sum(validInjectionIndicator0),sum(validInjectionIndicator))
        
        % MES of valid injections that did not become TCEs
        mesMissed = tipData.windowedMes(isPlanetACandidate == 0 & validInjectionIndicator  );
        
        % MES of valid injections that became TCEs
        mesDetected = tipData.windowedMes(isPlanetACandidate == 1 & validInjectionIndicator );
        
        
        
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
        
        
        %==================================================================
        
        % Window function vs period
        
        
        
        
        % Binned detections and misses
        periodMissed = tipData.orbitalPeriodDays(isPlanetACandidate == 0 & validInjectionIndicator );
        periodDetected = tipData.orbitalPeriodDays(isPlanetACandidate == 1 & validInjectionIndicator );
        
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
        plotWindowFunction = true;
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
            print('-dpng','-r150',strcat(pltiResultsDir,plotName))
            
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
                
                % Sample from Gaussian errors: !!!!! assuming nInjected > 0
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
                
                % !!!!! Using generalized logistic function
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
         
            
        end % fitDetectionEfficiency
        
        
        
        
        %==================================================================
        % Plots
        
        % Plot theoretical cumulative distribution vs. MES
        % plot(midMesBin,cdf('norm',midMesBin,7.1,1),'k-','LineWidth',3)
        % vline(7.1)
        
        % Ninjections vs. MES
        figure(1+offset)
        hold on
        % box on
        % grid on
        plot(midMesBin,nMissed+nDetected,[xColor(iTeff),'.-'])
        % plot(midMesBin,nDetected,'g.-')
        % plot(midMesBin,nMissed,'r.-')
        % legend('total injections','detected injections','missed injections','Location','NorthEast')
        % plotName = strcat(pltiDetectionEfficiencyDir,'n_injected_vs_MES');
        % print('-r150','-dpng',plotName)
        hold on
        
        % Detection efficiency vs. MES
        figure(2+offset)
        hold on
        % box on
        % grid on
        plot(midMesBin,nDetected./nInjected,[xColor(iTeff),'.-'])
        % plotName = strcat(pltiDetectionEfficiencyDir,'detection_efficiency_vs_MES');
        % print('-r150','-dpng',plotName)
        hold on
        
        % Poisson noise vs. MES
        skip = true;
        if(~skip)
            figure(3+offset)
            hold on
            % box on
            % grid on
            plot(midMesBin,sqrt(nInjected)./nInjected,[xColor(iTeff),'.-'])
            % plotName = strcat(pltiDetectionEfficiencyDir,'fractional_poisson_noise_vs_MES');
            % print('-r150','-dpng',plotName)
            hold on
        end
        
    end % loop  over ranges of Teff
    
    
    % Finalize plots
    figure(1+offset)
    % legend('M','K','G','F','Location','NorthEast')
    axis([MINMES-1,MAXMES,0,inf])
    set(gca,'FontSize',12)
    set(findall(gcf,'type','text'),'FontSize',12)
    title('Number of injections vs MES bin')
    xlabel('Windowed MES')
    ylabel('Counts')
    
    figure(2+offset)
    % legend('M','K','G','F','Location','NorthWest')
    axis([MINMES-1,MAXMES,0,inf])
    set(gca,'FontSize',12)
    set(findall(gcf,'type','text'),'FontSize',12)
    title('Fractional poisson noise vs MES bin')
    xlabel('Windowed MES')
    ylabel('Fractional noise')
    
    
    figure(10+offset)
    % legend('M','K','G','F','Location','NorthWest')
    title(sprintf('Detection efficiency for pixel-level injections on G stars\nCDPP slope < 0, logg > 4, %6.1f days < period < %6.0f days\nGeneralized Logistic Function Model\n(1+exp(-alpha.*(MES-beta)))**(-gamma)',MIN_PERIOD_DAYS,MAX_PERIOD_DAYS))
    axis([MINMES-1,MAXMES,0,inf])
    set(gca,'FontSize',12)
    set(findall(gcf,'type','text'),'FontSize',12)
    xlabel('Windowed MES')
    ylabel('Detection efficiency')
    plotName = 'Gstar_detection_efficiency_curve';
    print('-dpng','-r150',strcat(pltiResultsDir,plotName))
    
    
    figure(20+offset)
    % legend('M','K','G','F','Location','NorthWest')
    title(sprintf('Detection efficiency resduals for pixel-level injections on G stars\nCDPP slope < 0, logg > 4, %6.1f days < period < %6.0f days\nGeneralized Logistic Function Model\n(1+exp(-alpha.*(MES-beta)))**(-gamma)',MIN_PERIOD_DAYS,MAX_PERIOD_DAYS))
    axis([MINMES-1,MAXMES,-inf,inf])
    set(gca,'FontSize',12)
    set(findall(gcf,'type','text'),'FontSize',12)
    xlabel('Windowed MES')
    ylabel('Detection efficiency minus model')
    plotName = 'Gstar_detection_efficiency_residuals';
    print('-dpng','-r150',strcat(pltiResultsDir,plotName))
    
    skip = true;
    if(~skip)
        figure(3+offset)
        legend('M','K','G','F','Location','NorthWest')
        axis([MINMES-1,MAXMES,0,inf])
        set(gca,'FontSize',12)
        set(findall(gcf,'type','text'),'FontSize',12)
        title('Detection efficiency vs MES bin')
        xlabel('Windowed MES')
        ylabel('Fractional noise')
    end
    
    
end % loop over cdppSlopeIndicator


