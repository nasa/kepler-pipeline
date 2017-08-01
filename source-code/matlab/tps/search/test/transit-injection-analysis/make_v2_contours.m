% make_v2_contours.m
% based on code from make_detection_efficiency_curves.m, and
% contourAnalysis.m
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

% Input: tpsInjectionStruct
% Output: v2 completeness contour
%==========================================================================
% Inputs: tps-injection-struct.mat

% Initialize
clear all
% close all

% Constants
cadencesPerDay = 48.9390982304706;
superResolutionFactor = 3;
minWindowFunction = 0.97;
correlationThreshold = 0.92;

% Control
% groupLabel = input('groupLabel: Group1 (20 G stars), Group2 (20 K stars), Group3 (20 M stars) , Group4 (20 G stars), Group6 (20 K stars), KSOC4886 (1 G, 1 K, and 1 M star), KIC3114789, GroupA, GroupB, or KSOC-4930: ','s');
groupLabel = input('groupLabel: Group1, Group2, Group3, Group4, Group6, KSOC4886, KIC3114789, GroupA, GroupB, KSOC-4930, KSOC-4964, KSOC-4964-2, KSOC-4964-4, KSOC-5004-1: ','s');
contourLabel = 'period-radius';%input('Contour type: ''period-mes'' or ''period-radius'': ','s');

% Choose method of matching injected transits to detected ones.
% !!!!! Should use ephemeris-matching rather than epoch-matching?
% use threshold correlation of 0.92 to select valid injections (87% pass).
% matchMethod = 'tpsephem'; % 9/16/2015 -- found that epoch matches overlap tps-ephem matches by only 87%
matchMethod = 'epoch'; % Hardwired since 10/1/2015, when I discovered that tpsephem is not what I thought it was.
fprintf('matchMethod = %s\n',matchMethod)

% Scripts directory
baseDir = '/path/to/matlab/tps/search/test/transit-injection-analysis';

cd(baseDir)

% Option to model detection efficiency as generalized logistic function OR CDF function
% !!!!! Hardwired to 'L'; see KSOC-4881 for demonstration that 'L' is
% better than 'G'
detectionEfficiencyModelName = 'L';%= input('Choose detection efficiency model: L(generalized logistic function) or G(gamma CDF): ','s');

% Directories for injection data and diagnostics
[topDir, diagnosticDir] = get_top_dir(groupLabel);

% Directory for detection efficiency curves
contoursDir = strcat('/codesaver/work/transit_injection/contour_plots/',groupLabel,'/');

% If the directory does not yet exist, create it.
if( ~( exist(contoursDir,'dir') == 7 ) )
    mkdir(contoursDir)
end

% Directory for detection efficiency curves
detectionEfficiencyDir = strcat('/codesaver/work/transit_injection/detection_efficiency_curves/',groupLabel,'/');

% Prepare detectionEfficiencyModel
switch detectionEfficiencyModelName
    case 'L'
        detectionEfficiencyModelLabel = 'generalized-logistic-function';
    case 'G'
        detectionEfficiencyModelLabel = 'gamma-cdf';
end

% Load the tps-injection-struct
load(strcat(topDir,'tps-injection-struct.mat'))

% Unique keplerIds
uniqueKeplerIdAll = unique(tpsInjectionStruct.keplerId);
nTargets = length(uniqueKeplerIdAll);

% Get the meanPeriodCutoffDueToWindowFunction for this target
% load(strcat(detectionEfficiencyDir,'detection-efficiency-',matchMethod,'-matching-',detectionEfficiencyModelLabel,'-model.mat'));
% clear parameter*
% clear detectionEfficiencyAll
% clear nDetectedAll
% clear nMissedAll
% clear midMesBin
% clear fvalAll
% clear exitflagAll


%==========================================================================
% Initialize for loop over unique keplerIds

% Necessary tpsInjectionStruct fields

% chiSquare2 = tpsInjectionStruct.chiSquare2;               % veto threshold is 7
% robustStatistic = tpsInjectionStruct.robustStatistic;     % veto threshold is 7
% chiSquareGof = tpsInjectionStruct.chiSquareGof;           % veto threshold is 6.8
% chiSquareDof2 = tpsInjectionStruct.chiSquareDof2;
% chiSquareGofDof = tpsInjectionStruct.chiSquareGofDof;
% maxMes = tpsInjectionStruct.maxMes;
% periodDays = tpsInjectionStruct.periodDays;
% thresholdForDesiredPfa field is all -1's, so bootstrapOkay is always true
% in fold_statistics_and_apply_vetoes.m
thresholdForDesiredPfa = tpsInjectionStruct.thresholdForDesiredPfa;
% Expected MES -- see Shawn's notes
% Not used in this code
% expectedMes = tpsInjectionStruct.injectedDepthPpm .* 1e-6 .* tpsInjectionStruct.normSum000;
% expectedMes = tpsInjectionStruct.injectedDepthPpm .* 1e-6 .* tpsInjectionStruct.normSum111; % 3/9/2016 Chris uses this

% !!!!! Set 2D binning scheme, same for all targets
% minPeriodDays = 250;
% maxPeriodDays = 600;
minPeriodDays = input('Minimum orbit period in days -- e.g. 20: ');
% maxPeriodDays = input('Maximum orbit period in days -- e.g. 720: ');
maxPeriodDays = input('Maximum orbit period in days -- e.g. 730: ');

minRadiusEarths = 0.5; % !!!!! This will be smaller for M stars in Groups 3 and 6
maxRadiusEarths = 15;
mesLowerLimit = 3;
mesUpperLimit = 16;
% nBins = [30 30 30];
% nBins = [70 30 30]; % binwidth of 10 days, from 20 to 720 days
nBins = [71 30 30]; % binwidth of 10 days, from 20 to 730 days
% Period bins
binWidthPeriod = (maxPeriodDays - minPeriodDays)/nBins(1); % 10 days
% Radius bins
binWidthRadius = (log10(maxRadiusEarths) - log10(minRadiusEarths))/nBins(2);
% MES bins
binWidthMES = (mesUpperLimit - mesLowerLimit)/nBins(3);

% Set up bins and labels for contour plot, depending on contour type
switch contourLabel
    case 'period-radius'
        binEdges = {minPeriodDays:binWidthPeriod:maxPeriodDays log10(minRadiusEarths):binWidthRadius:log10(maxRadiusEarths) };
        yLabelString = ['log_{10}( Radius [Earths] ), bin size =  ',num2str(binWidthRadius,'%6.2f')];
    case 'period-mes'
        binEdges = { minPeriodDays:binWidthPeriod:maxPeriodDays mesLowerLimit:binWidthMES:mesUpperLimit };
        yLabelString = ['MES, bin size =  ',num2str(binWidthMES,'%6.2f')];
end
% Calculate grids for contour plots
binEdges1 = binEdges{1};
binEdges2 = binEdges{2};
% Bin centers from binEdges
binCenters1 = (binEdges1(2:end) + binEdges1(1:end-1))./2;
binCenters2 = (binEdges2(2:end) + binEdges2(1:end-1))./2;
binCenters = {binCenters1 binCenters2};
nBinsX = length(binCenters{1});
nBinsY = length(binCenters{2});
% Make 2D meshgrid of binCenters
[xGridCenters,yGridCenters] = meshgrid(binCenters{1},binCenters{2});

% Loop over unique targets
nInjected = zeros(nTargets,nBinsX,nBinsY);
nInjectedThatBecameTces = zeros(nTargets,nBinsX,nBinsY);
v2PipelineDetectionEfficiency = zeros(nTargets,nBinsX,nBinsY);
for iTarget = 1:nTargets
    
    % keplerId and indicator, for this target
    targetId = uniqueKeplerIdAll(iTarget);
    targetIndicator = tpsInjectionStruct.keplerId == targetId;
    
    % Load diagnosticStruct for this target
    % diagnosticStruct = load(strcat(diagnosticDir,'tps-diagnostic-struct-',groupLabel,'-KIC-',num2str(targetId),'.mat'));
    % tpsDiagnosticStruct = diagnosticStruct.tpsDiagnosticStruct;
            
    % Check that keplerId from detection efficiency file matches
    % disp('keplerIds should should match:')
    % fprintf('%d %d\n',uniqueKeplerIdAll(iTarget),uniqueKeplerId(iTarget))
    
    % Period cutoff for detection efficiency curve, determined by the window
    % function
    % Average the period threshold over only the pulses for which the window function drops below the minimum
    % disp('Search period thresholds: ')
    % periodThresh
    % fprintf('Mean period cutoff = %6.2f days\n',meanPeriodCutoffDueToWindowFunctionAll(iTarget))
    
    % Match injected to fitted transits 
    tpsEphemMatchIndicator = tpsInjectionStruct.transitModelMatch > correlationThreshold;
    epochMatchIndicator = abs(tpsInjectionStruct.injectedEpochKjd - tpsInjectionStruct.epochKjd) < tpsInjectionStruct.injectedDurationInHours / 2 / 24 ;
    switch matchMethod
        case 'tpsephem'
            matchIndicator = tpsEphemMatchIndicator;
        case 'epoch'
            matchIndicator = epochMatchIndicator;
            
    end
    
    % Show the correlation for epoch-matched TCEs
    skip = true;
    if(~skip)
        figure
        hold on
        box on
        grid on
        title('Correlation of epoch-matched TCEs')
        hist(tpsInjectionStruct.transitModelMatch(epochMatchIndicator&targetIndicator),0:0.02:1)
        xabel('Ephemeris Correlation (Pearsons Correlation Coefficient)');
        ylabel('Counts');
        set(gca,'FontSize',12)
        set(findall(gcf,'type','text'),'FontSize',12)
        % plotName = strcat(detectionEfficiencyDir,groupLabel,'-','correlationOfEpochMatchedTces','.png');
        % print('-r150','-dpng',plotName)
    end
    
    % Select periods within desired range, i.e. longer than 20 days and
    % below meanPeriodCutoffDueToWindowFunction
    validPeriodIndicator = tpsInjectionStruct.injectedPeriodDays > minPeriodDays & tpsInjectionStruct.injectedPeriodDays < maxPeriodDays;
    
    % But many more injections were done at radii less than 1.5 than between
    % 1.5 and 3.5 even though radius sampling was 'uniform'
    
    % Impact parameters are uniform between 0 and 0.95, but density tails off
    % between 0.95 and 1
        
    % Flag valid injections: i.e. were epoch-matched, had nonzero injected depth, more than 3 transits,
    % injected period in desired range.
    
    % According to Chris:
    % *Don't* require ephemeris or epoch match for validInjectionIndicator;
    %   instead, if there was no (ephemeris or epoch) match, force
    %   isPlanetACandidate to be false
    % * By doing this we count unmatched injections and penalize for not matching them. 
    % !!!!! Note -- there is no exclusion of injections that don't pass the
    %       window function
    validInjectionIndicator = ...
        tpsInjectionStruct.injectedDepthPpm ~=0 ...
        & targetIndicator ...           % Indicator for all the injections on this targetId
        & validPeriodIndicator;         % Period is within desired range 20 days < period < meanPeriodCutoff due to window function
    
    % Valid injections that became planets
    isPlanetACandidate = logical(tpsInjectionStruct.isPlanetACandidate(validInjectionIndicator));
        
    % Make a contour plot for detection probability vs. T and Rp for valid
    % injections
    % isPlanet = logical(isPlanetACandidate(validInjectionIndicator));
    maxMes = tpsInjectionStruct.maxMes(validInjectionIndicator);
    periods = tpsInjectionStruct.injectedPeriodDays(validInjectionIndicator);
    log10periods = log10(periods);
    radii = tpsInjectionStruct.planetRadiusInEarthRadii(validInjectionIndicator);
    log10radii = log10(radii);
    switch contourLabel
        case 'period-radius'
            nInjected(iTarget,:,:) = hist3([periods log10radii],binCenters);
            nInjectedThatBecameTces(iTarget,:,:) = hist3([periods(isPlanetACandidate) log10radii(isPlanetACandidate)],binCenters);
        case 'period-mes'
            nInjected(iTarget,:,:) = hist3([periods maxMes],binCenters);
            nInjectedThatBecameTces(iTarget,:,:) = hist3([periods(isPlanetACandidate) maxMes(isPlanetACandidate)],binCenters);
    end
    v2PipelineDetectionEfficiency(iTarget,:,:) = nInjectedThatBecameTces(iTarget,:,:) ./  nInjected(iTarget,:,:);
    
    % Contour plot -- Number of injections
    figure
    [~,h1] = contourf(xGridCenters,yGridCenters,log10(squeeze(nInjected(iTarget,:,:))'));
    set(h1,'ShowText','on','TextStep',get(h1,'LevelStep'))
    t = colorbar('peer',gca);
    set(get(t,'ylabel'),'String', 'log_{10}( Number of injections per bin )');
    title(['Injections per bin for ',groupLabel,' target KIC ',num2str(targetId)])
    xlabel(['Period [Days], bin size = ',num2str(binWidthPeriod,'%6.2f')])
    ylabel(yLabelString)
    set(gca,'FontSize',12)
    set(findall(gcf,'type','text'),'FontSize',12)
    plotName = strcat(contoursDir,'number-of-injections-',groupLabel,'-KIC-',num2str(targetId),'-',contourLabel,'.png');
    print('-r150','-dpng',plotName)

    % Contour plot -- error in detection efficiency from binomial statistics
    % reference KSOC-4861
    N = squeeze(nInjected(iTarget,:,:))';
    f = squeeze(v2PipelineDetectionEfficiency(iTarget,:,:))';
    fractionalDetectionEfficiencyError = sqrt( (1 - f).*f./( 3 + N ) );
    figure
    [~,h1] = contourf(xGridCenters,yGridCenters,fractionalDetectionEfficiencyError);
    set(h1,'ShowText','on','TextStep',get(h1,'LevelStep'))
    t = colorbar('peer',gca);
    set(get(t,'ylabel'),'String', 'Detection efficiency error (std) per bin');
    title(['Error in detection efficiency (std) for ',groupLabel,' target KIC ',num2str(targetId)])
    xlabel(['Period [Days], bin size = ',num2str(binWidthPeriod,'%6.2f')])
    ylabel(yLabelString)
    set(gca,'FontSize',12)
    set(findall(gcf,'type','text'),'FontSize',12)
    plotName = strcat(contoursDir,'injection-noise-',groupLabel,'-KIC-',num2str(targetId),'-',contourLabel,'.png');
    print('-r150','-dpng',plotName)
    
    % Contour plot -- Pipeline detection efficiency
    figure
    [~,h2] = contourf(xGridCenters,yGridCenters,squeeze(v2PipelineDetectionEfficiency(iTarget,:,:))');
    set(h2,'ShowText','on','TextStep',get(h2,'LevelStep'))
    t = colorbar('peer',gca);
    set(get(t,'ylabel'),'String', 'Pipeline Detection Efficiency');
    title(['v2 Detection Contours for ',groupLabel,' target KIC ',num2str(targetId)])
    xlabel(['Period [Days], bin size = ',num2str(binWidthPeriod,'%6.2f')])
    ylabel(yLabelString)
    set(gca,'FontSize',12)
    set(findall(gcf,'type','text'),'FontSize',12)
    plotName = strcat(contoursDir,'v2-detection-contours-',groupLabel,'-KIC-',num2str(targetId),'-',contourLabel,'.png');
    print('-r150','-dpng',plotName)
    
    % Keep plots for 5 targets
    if(mod(iTarget,6) == 0)
        % close all
    end
   
end % loop over targets

% Save the detection contour data for all targets
dataFile = strcat(contoursDir,'v2-detection-contours-',groupLabel,'-',contourLabel);
save([dataFile,'.mat'],'xGridCenters','yGridCenters','binWidthPeriod','binWidthRadius','binWidthMES','binCenters',...
    'nInjected','nInjectedThatBecameTces','v2PipelineDetectionEfficiency', ...
    'groupLabel','uniqueKeplerIdAll','contourLabel','yLabelString');
    % 'groupLabel','uniqueKeplerIdAll','meanPeriodCutoffDueToWindowFunctionAll','contourLabel','yLabelString');
