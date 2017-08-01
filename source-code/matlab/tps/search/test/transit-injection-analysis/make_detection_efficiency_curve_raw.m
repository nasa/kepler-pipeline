% make_detection_efficiency_curve_raw
% make detection efficiency curves, fit to a model function, and save data
% Usage notes:
% If the diagnostic structs containing the one-sigma depth function and window function
% do not yet exist, then
% 1) run get_stellar_parameters_for_injection_targets.m
% 2) run get_transit_injection_diagnostics.m
% For the version that fits detection efficiency to a model and saves the
% output files, use make_detection_efficiency_curve.m
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

% this code is
% under subversion in
% /path/to/matlab/tps/search/test/transit-injection-analysis/


% Initialize
clear all
close all

% Constants
cadencesPerDay = 48.9390982304706;
superResolutionFactor = 3;
minWindowFunction = 0.97;
correlationThreshold = 0.92;
colors = 'rcbmg'; 

% Control

% Diagnostic plots
doDiagnosticPlots = false;

% Option to show diagnostic plots
% raw detection efficiency and poisson counting errors
poissonCountPlot = false;

% Option to plot correlation histogram
plotCorrelationMatchHistogram = false;

% Get injection run
% groupId = input('groupId: 1 (20 G stars), 2 (20 K stars), 3 (20 M stars) , 4 (20 G stars), 6 (20 M stars), KSOC4886 (1 G, 1 K, and 1 M star), KIC3114789, A (3G, 2K) , B (1G, 2K, 1M), KSOC-4930 (2G): ','s');
groupId = input('groupId: 1, 2, 3, 4, 6, KSOC4886, KIC3114789, A, B, KSOC-4930, KSOC-4964: ','s');

% Choose method of matching injected transits to detected ones.
% !!!!! Should use ephemeris-matching rather than epoch-matching
% (with threshold at 0.90) to select valid
% injections.
% matchMethod = input('Match method: epoch(epoch-matching) or ephemeris(ephemeris-matching) or tpsephem(tps ephemeris matching) -- ','s');
% matchMethod = 'tpsephem'; % !!!!! hardwired now 9/16/2015 -- found that epoch matches overlap tps-ephem matches by only 87%
matchMethod = 'epoch'; % 10/01/2015 possible problem with pearsons correlation match when TPS finds a different period
% matchMethod = 'epoch';
fprintf('matchMethod = %s\n',matchMethod)

% Scripts directory
% baseDir = '/codesaver/work/transit_injection/scripts/';
baseDir = '/path/to/matlab/tps/search/test/transit-injection-analysis/';
cd(baseDir)

% Option to model detection efficiency as generalized logistic function OR CDF function
% !!!!! Hardwired to 'L'; see KSOC-4881 for demonstration that 'L' is
% better than 'G'
detectionEfficiencyModelName = 'L';%= input('Choose detection efficiency model: L(generalized logistic function) or G(gamma CDF): ','s');

% Option to fit detection efficiency curve
fitDetectionEfficiency = false; %!!!!! hard-wired

% Directories for the tpsInjectionStruct and diagnosticStruct
switch groupId
    
    case '1'
        % Group 1 20 G stars
        % load the tpsInjectionStruct
        % fprintf('Combining injection structs from parts 1, 2, and 3 into a single struct ...\n')
        % combine_group1_injection_structs
        % topDir = '/codesaver/work/transit_injection/group1-injection-topdir/';
        % diagnosticDir = '/codesaver/work/transit_injection/diagnostics/Group1/';
        % load tps-diagnostic-struct-KIC-8188636.mat
        % targetId = 8188636 ;
        % groupLabel = strcat('Group',groupId);
        error('Code is broken for Group1')
        
    case '2'
        % Group 2 20 K stars
        % load the tpsInjectionStruct
        % topDir = '/path/to/transitInjectionRuns/Group_2_1st_20_K_stars_08262015_partial/tps-matlab-2015233/';
        topDir = '/path/to/transitInjectionRuns/Group_2_1st_20_K_stars_09012015/tps-matlab-2015233/';
        diagnosticDir = '/codesaver/work/transit_injection/diagnostics/Group2/';
        % load tps-diagnostic-struct-KIC-2991321.mat
        % targetId = 2991321;
        groupLabel = strcat('Group',groupId);
        
    case 'KSOC4886'
        topDir = '/path/to/1_G_star_1_K_star_1_M_star_09052015/tps-matlab-2015247/';
        diagnosticDir = '/codesaver/work/transit_injection/diagnostics/KSOC4886/';
        groupLabel = groupId;
        
    case '3'
        % Group 3 20 M stars
        % load the tpsInjectionStruct
        topDir = '/path/to/transitInjectionRuns/Group_3_1st_20_M_stars_09082015/tps-matlab-2015244/';
        diagnosticDir = '/codesaver/work/transit_injection/diagnostics/Group3/';
        groupLabel = strcat('Group',groupId);
        
    case '4'
        % Group 4 20 G stars
        % load the tpsInjectionStruct
        topDir = '/path/to/transitInjectionRuns/Group_4_2nd_20_G_stars_09102015/tps-matlab-2015248/';
        diagnosticDir = '/codesaver/work/transit_injection/diagnostics/Group4/';
        groupLabel = strcat('Group',groupId);
        
    case '6'
        % Group 6 20 M stars
        % load the tpsInjectionStruct
        topDir = '/path/to/transitInjectionRuns_maxNumberOfAttemps_set_to_1/Group_6_2nd_20_M_stars_09242015/tps-matlab-2015260/';
        diagnosticDir = '/codesaver/work/transit_injection/diagnostics/Group6/';
        groupLabel = strcat('Group',groupId);
        
    case 'KIC3114789'
        topDir = '/path/to/transitInjectionRuns_fractionToSampleByMes_set_to_0/testRun_KIC3114789_10012015/tps-matlab-2015273/';
        diagnosticDir = '/codesaver/work/transit_injection/diagnostics/KIC3114789/';
        groupLabel = groupId;
        
    case 'A'
        % Group A (3 G stars and 2 K stars)
        % load the tpsInjectionStruct
        topDir = '/path/to/transitInjectionRuns_fractionToSampleByMes_set_to_0/Group_A_3_G_stars_and_2_K_stars_10112015/tps-matlab-2015280/';
        diagnosticDir = '/codesaver/work/transit_injection/diagnostics/GroupA/';
        groupLabel = strcat('Group',groupId);
        
    case 'B'
        % Group B (1 G star, 1 K star and 3 M stars)
        % load the tpsInjectionStruct
        topDir = '/path/to/transitInjectionRuns_fractionToSampleByMes_set_to_0/Group_B_1_G_star_1_K_star_and_3_M_stars_10112015/tps-matlab-2015282/';
        diagnosticDir = '/codesaver/work/transit_injection/diagnostics/GroupB/';
        groupLabel = strcat('Group',groupId);
        
    case 'KSOC-4930'
        % KSOC-4930 (2 G stars: KIC3114789 and KIC-9898170 -- both are previous injection targets)
        % load the tpsInjectionStruct
        topDir = '/path/to/transitInjections/KSOC-4930/testRun_2_G_stars/tps-matlab-2015308/';
        diagnosticDir = '/codesaver/work/transit_injection/diagnostics/KSOC-4930/';
        groupLabel = strcat(groupId);
        
    case 'KSOC-4964'    
        % KSOC-4964 (2 G stars: KIC-3114789 and KIC-9898170 -- both are previous injection targets)
        % Same as KSOC-4964, except with new diagnostics
        % load the tpsInjectionStruct
        topDir = '/path/to/transitInjections/KSOC-4964/testRun_1_with_2_G_stars/tps-matlab-2015344/';
        diagnosticDir = '/codesaver/work/transit_injection/diagnostics/KSOC-4964/';
        groupLabel = strcat(groupId);
end

% Directory for detection efficiency curves
detectionEfficiencyDir = strcat('/codesaver/work/transit_injection/detection_efficiency_curves/',groupLabel,'/');

% If the directory does not yet exist, create it.
if( ~( exist(detectionEfficiencyDir,'dir') == 7 ) )
    mkdir(detectionEfficiencyDir)
end

% Load the tps-injection-struct
load(strcat(topDir,'tps-injection-struct.mat'))

% Get the stellar parameters file created by
% get_stellar_parameters_for_injection_targets.m
saveDir = '/codesaver/work/transit_injection/data/';
load(strcat(saveDir,groupLabel,'_stellar_parameters.mat'))
pulseDurationsHours = [1.5, 2.0, 2.5, 3.0, 3.5, 4.5 , 5.0, 6.0, 7.5, 9.0, 10.5, 12.0, 12.5, 15.0];

% Unique keplerIds
uniqueKeplerId = unique(tpsInjectionStruct.keplerId);
nTargets = length(uniqueKeplerId);

% Initialize for plot
DELMES=0.25;
xedges=3.0:DELMES:18.0;
midMesBin=xedges(1:end-1)+diff(xedges)/2.0;
xColor = 'krbgmc';

% Prepare detectionEfficiencyModel
switch detectionEfficiencyModelName
    case 'L'
        detectionEfficiencyModelLabel = 'generalized-logistic-function';
    case 'G'
        detectionEfficiencyModelLabel = 'gamma-cdf';
end

% Nececessary fields from tpsInjectionStruct
chiSquare2 = tpsInjectionStruct.chiSquare2;                 % veto threshold = 7
robustStatistic = tpsInjectionStruct.robustStatistic;       % veto threshold = 7
chiSquareGof = tpsInjectionStruct.chiSquareGof;             % veto threshold = 6.8
isPlanetACandidate = tpsInjectionStruct.isPlanetACandidate;
chiSquareDof2 = tpsInjectionStruct.chiSquareDof2;
chiSquareGofDof = tpsInjectionStruct.chiSquareGofDof;
% maxMes is degraded from true MES due to coarseness of period grid, transit duration grid
% and shape mismatch
maxMes = tpsInjectionStruct.maxMes;
periodDays = tpsInjectionStruct.periodDays;
% thresholdForDesiredPfa field is all -1's, so bootstrapOkay is always true
% in fold_statistics_and_apply_vetores.m
thresholdForDesiredPfa = tpsInjectionStruct.thresholdForDesiredPfa;

% Expected MES -- see Shawn's notes
% This is the best estimate of MES, correcting maxMes for coarseness of period and
% transit duration grids and transit shape mismatch.
expectedMes = tpsInjectionStruct.injectedDepthPpm .* 1e-6 .* tpsInjectionStruct.normSum000;

%======================================================================
% Select desired period range for detection efficiency curves
% Optionally set period limits
setPeriodLimits = false;%logical(input('Set period limits? 1 or 0 -- '));
if(setPeriodLimits)
    minPeriodDays = input('Minimum period (days) default is 20: ');
    maxPeriodDays = input('Maximum period (days): default is 730 ');
else
    minPeriodDays = 20;
    maxPeriodDays = 730;
end

% Period ranges
periodRange{1,:} = [20, 45];
periodRange{2,:} = [45, 90];
periodRange{3,:} = [90, 180];
periodRange{4,:} = [180, 360];
periodRange{5,:} = [360, 730];
nPeriodRanges = size(periodRange,1);
periodLimits = zeros(nPeriodRanges,2);
legendString = cell(nPeriodRanges,1);
% Loop over periodRanges
% for iPeriodRange = 1:nPeriodRanges

% !!!!! NOTE -- changing the order of the loops: looping over periodRange for each target to produce a
% family of detection efficiency curves as a function of period
% This only works with fitting turned OFF, so the fitting part of this code
% is now officially broken. Also, no output file is now produced.

tic
% Loop over unique targets
for iTarget = 1:nTargets
    
    % Set up plot for this target
    figure(100*iTarget)
    hold on
    box on
    grid on
    
    
    % Loop over periodRanges
    for iPeriodRange = 1:nPeriodRanges
        
        % Period limits
        periodLimits(iPeriodRange,:) = periodRange{iPeriodRange};
        minPeriodDays = periodLimits(iPeriodRange,1);
        maxPeriodDays = periodLimits(iPeriodRange,2);
        periodLabel = [];%sprintf('-period-%d-to-%d-days',minPeriodDays,maxPeriodDays);
        fprintf('!!!!! Computing detection efficiency curve for periods ranging from %d to %d days ...\n',minPeriodDays,round(maxPeriodDays))
        legendString{iPeriodRange} = sprintf('%d < P < %d days',minPeriodDays,maxPeriodDays);
        
        % Initialize for loop over unique keplerIds
        parameter1 = zeros(nTargets,1);
        parameter2 = zeros(nTargets,1);
        parameter3 = zeros(nTargets,1);
        detectionEfficiencyAll = zeros(length(midMesBin),1);
        nDetectedAll = zeros(length(midMesBin),1);
        nMissedAll = zeros(length(midMesBin),1);
        fvalAll = zeros(nTargets,1);
        exitflagAll = zeros(nTargets,1);
        meanPeriodCutoffDueToWindowFunctionAll = zeros(nTargets,1);
        
        
        
        % keplerId and indicator, for this target
        targetId = uniqueKeplerId(iTarget);
        injectionIndicatorForThisTarget = tpsInjectionStruct.keplerId == targetId;
        fprintf('There were %d injections for keplerId %d\n',sum(injectionIndicatorForThisTarget),targetId)
        
        % Load diagnosticStruct for this target
        diagnosticStruct = load(strcat(diagnosticDir,'tps-diagnostic-struct-',groupLabel,'-KIC-',num2str(targetId),'.mat'));
        tpsDiagnosticStruct = diagnosticStruct.tpsDiagnosticStruct;
        
        % Get period cutoff above which the window function degrades below 97%
        nPulses = length(tpsDiagnosticStruct);
        periodThresh = zeros(nPulses,1);
        windowFunctionIsAlwaysAboveThreshold = false(nPulses,1);
        
        % Extract the period and the window function
        % Note that search periods in periodsWindowFunction are in superresolution cadences
        fprintf('Getting window function for KIC%d , target %d of %d\n',targetId,iTarget,nTargets)
        for iPulse = 1:nPulses
            
            % For this pulse: get search periods and window function
            % Convert search periods to days
            periodSearched = tpsDiagnosticStruct(iPulse).periodsWindowFunction/cadencesPerDay/superResolutionFactor;
            windowFunction = tpsDiagnosticStruct(iPulse).windowFunction;
            
            % Indicator if window function is always above threshold over the range of
            % periods used. In this case the pulse can't be used to estimate the
            % maximum period
            windowFunctionIsAlwaysAboveThreshold(iPulse) = all(windowFunction > minWindowFunction);
            
            % For this pulse: get longest period for which window function exceeds
            % the minimum.
            % !!!!! Error in next line -- corrected 9/15/2015
            % periodThresh(iPulse) = max(periodSearched(windowFunction>minWindowFunction));
            
            % Correction: find the *shortest* period for which window function drops
            % below the threshold window function
            if( sum( periodSearched ( windowFunction < minWindowFunction ) ) > 0 )
                periodThresh(iPulse) = min(periodSearched(windowFunction<minWindowFunction));
            else
                periodThresh(iPulse) = -1;
            end
            
            % Plot
            if(doDiagnosticPlots)
                legendString = sprintf('Pulse #%d search %6.2f to %6.2f days, thresh %6.2f days',iPulse,periodSearched(1),periodSearched(end),periodThresh(iPulse));
                figure
                hold on
                grid on
                box on
                title(['Window Function as a function of period, pulse ',num2str(iPulse)])
                xlabel('Period [days]')
                ylabel('Window Function')
                axis([0,inf,0.9,1])
                plot(periodSearched,windowFunction, 'r.' )
                plot(periodThresh(iPulse),1,'b*')
                legend(legendString)
            end
        end % loop over pulse widths
        
        % Period cutoff for detection efficiency curve, determined by the window
        % function, for this target
        % Average the period threshold over only the pulses for which the window function drops below the minimum
        % disp('Search period thresholds: ')
        % periodThresh
        disp('All period cutoffs:')
        allPeriodCutoffs = periodThresh(~windowFunctionIsAlwaysAboveThreshold);
        listString = sprintf('%8.3f \n',allPeriodCutoffs);
        fprintf('%s\n',listString)
        meanPeriodCutoffDueToWindowFunctionAll(iTarget) = mean(periodThresh(~windowFunctionIsAlwaysAboveThreshold));
        fprintf('Mean period cutoff = %6.2f days\n',meanPeriodCutoffDueToWindowFunctionAll(iTarget))
        
        %=============================
        % Plot rmsCdpp for this target -- remember that it originates from the
        % tps_tce_struct that is provided as an input to the transit injection
        % run
        if(doDiagnosticPlots)
            figure
            loglog(pulseDurationsHours,stellarParameterStruct.rmsCdpp(iTarget,:),'bp-')
            hold on
            box on
            grid on
            title(['rmsCdpp for KIC ',num2str(targetId)])
            xlabel('Pulse duration [hours]');
            ylabel('rmsCdpp');
            axis([1, 15, 1, inf])
            set(gca,'FontSize',12)
            set(findall(gcf,'type','text'),'FontSize',12)
            plotName = strcat(detectionEfficiencyDir,groupLabel,'-','rmsCdpp-KIC',num2str(targetId));
            print('-r150','-dpng',plotName)
        end
        
        
        
        %==========================================================================
        % Match injected to fitted transits
        % 'epoch' is matching by epoch only;
        % 'ephemeris' is matching by pearson's correlation implemented by
        %       Sean's fast matching code
        % 'tpsephem' is matching by Pearson's correlation already implemented by
        %       Shawn in TPS code
        switch matchMethod
            
            case 'epoch'
                % A. By epoch-matching
                % From Chris' code examinject.m
                % epochMatchIndicator = abs(tpsInjectionStruct.injectedEpochKjd - tpsInjectionStruct.epochKjd)*48.939 < tpsInjectionStruct.injectedDurationInHours *48.939 / 2 / 24 ;
                % A match is flagged if the difference between injected and detected epochs
                % is less than half a transit duration
                epochMatchIndicator = abs(tpsInjectionStruct.injectedEpochKjd - tpsInjectionStruct.epochKjd) < tpsInjectionStruct.injectedDurationInHours / 2 / 24 ;
                matchIndicator = epochMatchIndicator;
                
            case 'ephemeris' % Sean's correlation code takes about 2 sec per 1000 injections vs 80 sec for mine
                % B. By ephemeris-matching
                % Match injected transits with detected transits via Pearson's correlation.
                % Question: is the order in the fitted list the same as that of the
                % injections? If so, we only need to compute the diagonal of the
                % correlation matrix.
                % Use Sean's fast correlation code to correlate each injection with its
                % detected counterpart.
                % Inputs for ephemeris comparison
                % Ephemeris for this target
                period1 = double(tpsInjectionStruct.injectedPeriodDays(injectionIndicatorForThisTarget));
                period2 = double(tpsInjectionStruct.periodDays(injectionIndicatorForThisTarget));
                epoch1 = double(tpsInjectionStruct.injectedEpochKjd(injectionIndicatorForThisTarget));
                epoch2 = double(tpsInjectionStruct.epochKjd(injectionIndicatorForThisTarget));
                duration1 = double(tpsInjectionStruct.injectedDurationInHours(injectionIndicatorForThisTarget)./24);
                duration2 = double(tpsInjectionStruct.injectedDurationInHours(injectionIndicatorForThisTarget)./24);
                calculatePearsonCorrelation = true;
                if(calculatePearsonCorrelation)
                    fprintf('Calculating correlations ...\n')
                    % !!!!! problem with Sean's code: for now, use mine. But
                    % mine is TOO SLOW!!!
                    
                    tic
                    % Initialize
                    addpath fullfile(getenv('SOC_CODE_ROOT'), '/matlab/av/ephemeris-correlation/');
                    observationStartTime = 0;
                    observationEndTime = observationStartTime + 4 * 365.25;
                    correlationResolution = 1/(24*60); % one minute
                    ephemerisCorrelation = zeros(length(epoch1 ),1);
                    
                    % If period or epoch are negative, set correlation to 0
                    badCorrelationIndicator = period2 < 0 | epoch2 < 0;
                    ephemerisCorrelation(badCorrelationIndicator) = 0;
                    inds = 1:length(ephemerisCorrelation);
                    validInds = inds(~badCorrelationIndicator);
                    for iInjection = validInds
                        % ephemerisCorrelation(iInjection) = ephemeris_cross_correlation_matrix([targetId,epoch1(iInjection),period1(iInjection),duration1(iInjection)], ...
                        %    [targetId,epoch2(iInjection),period2(iInjection),duration2(iInjection)],observationStartTime, observationEndTime, correlationResolution);
                        ephemerisCorrelation(iInjection) = correlate_ephemerides(period1(iInjection),epoch1(iInjection),duration1(iInjection), ...
                            period2(iInjection),epoch2(iInjection),duration2(iInjection),observationStartTime,observationEndTime);
                        if(mod(iInjection,1000)==0)
                            fprintf('iInjection %d\n',iInjection)
                        end
                    end
                    toc
                    
                    % Indicator for good ephemeris matches
                    ephemerisMatchIndicator = ephemerisCorrelation > correlationThreshold;
                    save(strcat(injectionRunId,'-','ephemerisMatch.mat'),'ephemerisMatchIndicator','ephemerisCorrelation','correlationThreshold','periodLabel')
                    matchIndicator = ephemerisMatchIndicator;
                    
                    % else
                    
                    % Retrieve saved file
                    % load('ephemerisMatch.mat')
                    
                end
                
                
            case 'tpsephem'
                % !!!!! But note that transitModelMatch measures the
                % correlation of the *injected* (not detected) signal with its transit model.
                correlationMatchIndicator = tpsInjectionStruct.transitModelMatch > correlationThreshold;
                epochMatchIndicator = abs(tpsInjectionStruct.injectedEpochKjd - tpsInjectionStruct.epochKjd) < tpsInjectionStruct.injectedDurationInHours / 2 / 24 ;
                matchIndicator = correlationMatchIndicator;
                
                
        end % switch
        
        
        % Indicator that period is within bounds
        periodIsInSpecifiedRange = tpsInjectionStruct.injectedPeriodDays > minPeriodDays & tpsInjectionStruct.injectedPeriodDays < maxPeriodDays;
        
        % But many more injections were done at radii less than 1.5 than between
        % 1.5 and 3.5 even though radius sampling was 'uniform'
        
        % Impact parameters are uniform between 0 and 0.95, but density tails off
        % between 0.95 and 1
        
        % Flag valid injections: i.e. were epoch-matched, had nonzero injected depth, more than 3 transits,
        % injected period in desired range.
        % NOTE: fitSinglePulse is set by TPS in case some of the transits fell
        % in a gap
        % !!!!! replaced fitSinglePulse and numSesInMes with
        % WhenSearchedWithInjectedPeriodAndDuration versions.
        validInjectionIndicator0 = ...
            tpsInjectionStruct.injectedDepthPpm ~= 0 ...
            & tpsInjectionStruct.numSesInMesWhenSearchedWithInjectedPeriodAndDuration >= 3 ...                          % !!!!! NOTE that this was originally > 3, which requires at least 4 transits
            & ~(tpsInjectionStruct.numSesInMesWhenSearchedWithInjectedPeriodAndDuration == 3 & tpsInjectionStruct.fitSinglePulseWhenSearchedWithInjectedPeriodAndDuration==true) ...  % See Shawn's note in transit_injection_controller.m near lines 581-585
            & injectionIndicatorForThisTarget ...
            & periodIsInSpecifiedRange ...
            & matchIndicator;
        
        
        %======================================================================
        % Diagnostics: correlation for epoch-matched TCEs
        epochMatchFraction = sum(epochMatchIndicator)/length(epochMatchIndicator);
        ephemerisMatchFraction = sum(matchIndicator)/length(matchIndicator);
        % Option to plot correlation histogram
        if(plotCorrelationMatchHistogram)
            figure
            hold on
            box on
            grid on
            title('Correlation of Matched TCEs for this target')
            hist(tpsInjectionStruct.transitModelMatch(injectionIndicatorForThisTarget),0:0.02:1)
            xlabel('Ephemeris Correlation (Pearsons Correlation Coefficient)');
            ylabel('Counts');
            legendString = sprintf('Correlation threshold = %6.2f\nEphemeris match fraction = %6.2f\nEpoch match fraction = %6.2f',correlationThreshold,ephemerisMatchFraction,epochMatchFraction);
            legend(legendString,'Location','NorthWest')
            set(gca,'FontSize',12)
            set(findall(gcf,'type','text'),'FontSize',12)
            axis([0.5, 1, 0, inf])
            plotName = strcat(detectionEfficiencyDir,groupLabel,'-','correlationOfEpochMatchedTces',periodLabel);
            print('-r150','-dpng',plotName)
        end %
        
        % MES of injected transits
        if(doDiagnosticPlots)
            figure
            
            subplot(2,1,1)
            hold on
            box on
            title('MES of injected TCEs for this target')
            hist(tpsInjectionStruct.maxMes(injectionIndicatorForThisTarget),3:1:20)
            xlabel('maxMES')
            ylabel('Counts');
            set(gca,'FontSize',12)
            set(findall(gcf,'type','text'),'FontSize',12)
            axis([3,20,0,inf])
            
            subplot(2,1,2)
            hold on
            box on
            title('MES of MATCHED valid injected TCEs for this target')
            hist(tpsInjectionStruct.maxMes(validInjectionIndicator),3:1:20)
            xlabel('maxMES')
            ylabel('Counts');
            set(gca,'FontSize',12)
            set(findall(gcf,'type','text'),'FontSize',12)
            axis([3,20,0,inf])
            
            plotName = strcat(detectionEfficiencyDir,groupLabel,'-','mesOfInjectedTces',periodLabel);
            print('-r150','-dpng',plotName)
            
        end % doDiagnosticPlots
        
        % MES of injections of interest that did not become TCEs
        mesMissed = expectedMes(isPlanetACandidate==0 & validInjectionIndicator  );
        
        % Injections of interest that became TCEs
        mesDetected = expectedMes(isPlanetACandidate==1 & validInjectionIndicator );
        
        % Plot theoretical cumulative distribution vs. MES
        % plot(midMesBin,cdf('norm',midMesBin,7.1,1),'k-','LineWidth',3)
        % vline(7.1)
        
        % Histogram of MES of missed TCEs
        nMissedTemp = histc(mesMissed,xedges);
        nMissed = nMissedTemp(1:end-1);
        
        % Histogram of MES of TCEs
        nDetectedTemp = histc(mesDetected,xedges);
        nDetected = nDetectedTemp(1:end-1);
        
        % Detection efficiency vs MES
        detectionEfficiency = nDetected./(nDetected+nMissed);
        
        % Diagnostic plot of detection efficiency
        if(poissonCountPlot)
            
            % Poisson noise vs. MES
            figure
            hold on
            box on
            grid on
            % plot(midMesBin,nMissed+nDetected,'b.-')
            plot(midMesBin,sqrt(nMissed+nDetected)./(nMissed+nDetected),'r.-')
            % legend('total injections','detected injections','Location','NorthWest')
            axis([2,16,0,inf])
            set(gca,'FontSize',12)
            set(findall(gcf,'type','text'),'FontSize',12)
            title(['Poisson errors in counts for KIC',num2str(targetId)])
            xlabel('Expected MES')
            ylabel('Fractional Detection Efficiency Error Due to Poisson Noise ')
            plotName = strcat(detectionEfficiencyDir,'number-of-injections-',matchMethod,'-matching-KIC-',num2str(targetId),periodLabel);
            print('-r150','-dpng',plotName)
            
            
        end % poissonCountPlot
        
        
        % Option to fit detection efficiency curve
        if(fitDetectionEfficiency)
            
            % Max mes for fit
            % maxMesForFit = 14;
            maxMesForFit = midMesBin(end); % no truncation
            useBinInFit = midMesBin <= maxMesForFit;
            midMesBinsUsed = midMesBin(useBinInFit);
            detectionEfficiencyUsed = detectionEfficiency(useBinInFit);
            fprintf('Fitting detection efficiency for MES < %d: using %d of %d MES bins\n',maxMesForFit,sum(useBinInFit),length(midMesBin))
            
            
            % Fit the detection efficiency curve
            % Cost function to be optimized using fminsearch
            
            % Check grid of starting points
            fprintf('Fitting the detection efficiency curve for KIC%d , target %d of %d\n',targetId,iTarget,nTargets)
            fprintf('Optimizing starting point ...\n');
            nGrid = 10;
            x1grid = 1*rand(1,nGrid);
            x2grid = 10*rand(1,nGrid);
            switch detectionEfficiencyModelName
                case 'G'
                    costFunction = @(x) sum( (detectionEfficiency - gamcdf(midMesBin'- x(3),x(1),x(2))).^2 );
                    x3grid = 4 + rand(1,nGrid);
                case 'L'
                    generalizedLogisticFunction = @(x) 1./(1+exp(-x(1).*(midMesBinsUsed'-x(2)))).^x(3);
                    costFunction = @(x)sum ( ( detectionEfficiencyUsed -  generalizedLogisticFunction(x) ).^2 );
                    x3grid = 4*rand(1,nGrid);
            end
            
            % Initialize
            optOrig = optimset('fminsearch');
            % optNew = optimset(optOrig,'TolFun',1.e-4,'TolX',1.e-4,'MaxFunEvals',2000,'MaxIter',1000);
            % Stting MaxFunEvals and MaxIter to defaults of 3*numbeOfVariables
            optNew = optimset(optOrig,'TolFun',1.e-4,'TolX',1.e-4,'MaxFunEvals',600,'MaxIter',600);
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
            fprintf('Fitting detection efficiency curve...\n')
            [x,fvalAll(iTarget),exitflagAll(iTarget),output] = fminsearch(costFunction,x0,options);
            switch detectionEfficiencyModelName
                case 'G'
                    fprintf('Target #%d exitflag %d fval %8.4f, fitted gamma parameters: A = %8.4f, B = %8.4f, offset = %8.4f\n\n',iTarget,exitflagAll(iTarget),fvalAll(iTarget),x(1),x(2),x(3))
                    detectionEfficiencyModel = gamcdf(midMesBin - x(3),x(1),x(2));
                    legendString2 = sprintf('Gamma CDF: A%8.4f, B%8.4f, Offset%8.4f',x(1),x(2),x(3));
                case 'L'
                    fprintf('Target #%d exitflag %d fval %8.4f, fitted logistic parameters: x1 = %8.4f, x2 = %8.4f, x3 = %8.4f \n\n',iTarget,exitflagAll(iTarget),fvalAll(iTarget),x(1),x(2),x(3))
                    detectionEfficiencyModel = generalizedLogisticFunction([x(1),x(2),x(3)]);
                    legendString2 = sprintf('Generalized Logistic Function: A%10.4f, B%10.4f, C%10.4f',x(1),x(2),x(3));
            end
            
            % Fitted model parameters
            parameter1(iTarget) = x(1);
            parameter2(iTarget) = x(2);
            parameter3(iTarget) = x(3);
            
            % Detection efficiency data
            detectionEfficiencyAll(:,iTarget) = detectionEfficiency;
            nDetectedAll(:,iTarget) = nDetected;
            nMissedAll(:,iTarget) = nMissed;
            
            
            % Detection efficiency vs. MES curve at this target
            figure
            hold on
            box on
            grid on
            plot(midMesBinsUsed,detectionEfficiencyModel,'r-','LineWidth',2)
            plot(midMesBin,detectionEfficiency,'b.')
            legendString1 = ['Detection Efficiency: ',num2str(minPeriodDays,'%6.2f'),' < period < ',num2str(maxPeriodDays,'%6.2f'),' days'];
            legend(legendString2,legendString1,'Location','NorthWest')
            axis([2,16,0,1.25])
            set(gca,'FontSize',12)
            set(findall(gcf,'type','text'),'FontSize',12)
            title(['Detection efficiency vs ',detectionEfficiencyModelLabel,' model for KIC ',num2str(targetId)])
            xlabel('Expected MES')
            ylabel('Detected Fraction')
            plotName = strcat(detectionEfficiencyDir,'detection-efficiency-',matchMethod,'-matching-',detectionEfficiencyModelLabel,'-model-KIC-',num2str(targetId),periodLabel);
            print('-r150','-dpng',plotName)
            
            maxAbsDev = max(abs(detectionEfficiency - detectionEfficiencyModel));
            rmsDev = sqrt(mean((detectionEfficiency - detectionEfficiencyModel).^2));
            
            % Detection efficiency model residual vs. MES at this target
            figure
            hold on
            box on
            grid on
            plot(midMesBinsUsed,detectionEfficiency - detectionEfficiencyModel,'b.-')
            % legendString1 = ['Detection Efficiency minus Model: ',num2str(minPeriodDays,'%6.0f'),' days < period < ',num2str(maxPeriodDays,'%60f'),' days'];
            % legend(legendString1,'Location','NorthWest')
            % axis([2,16,0,1.25])
            set(gca,'FontSize',12)
            set(findall(gcf,'type','text'),'FontSize',12)
            title(['Detection efficiency residual (computed - model) with ',detectionEfficiencyModelLabel,' model for KIC ',num2str(targetId)])
            xlabel('Expected MES')
            ylabel('Residual Detected Fraction')
            legend(['RMS = ',num2str(rmsDev,'%8.4f'),' max abs dev = ',num2str(maxAbsDev,'%8.4f')],'Location','Best')
            plotName = strcat(detectionEfficiencyDir,'detection-efficiency-model-fit-residual-',matchMethod,'-matching-',detectionEfficiencyModelLabel,'-model-KIC-',num2str(targetId),periodLabel);
            print('-r150','-dpng',plotName)
            
            
        elseif(~fitDetectionEfficiency)
            
            % Raw Detection efficiency
            figure(100*iTarget)
            plot(midMesBin,detectionEfficiency,[colors(iPeriodRange),'-'],'LineWidth',2)
            
        end % fitDetectionEfficiency
        
        % Keep plots for a few targets open
        if(mod(iTarget,3)==0)
            close all
        end
        
    end % loop over period ranges
    
    % Finish and save plots for this target
            figure(100*iTarget)
            legend(legendString{1},legendString{2},legendString{3},legendString{4},legendString{5},'Location','NorthWest')
            axis([2,16,0,1.25])
            set(gca,'FontSize',12)
            set(findall(gcf,'type','text'),'FontSize',12)
            title(['Detection efficiency for KIC',num2str(targetId)])
            xlabel('Expected MES')
            ylabel('Detected Fraction')
            plotName = strcat(detectionEfficiencyDir,'detection-efficiency-',matchMethod,'-matching-KIC-',num2str(targetId),periodLabel);
            print('-r150','-dpng',plotName)
    
end % loop over targets


% If fits were performed, save and archive
if(fitDetectionEfficiency)
    % Save the detection efficiency curve data and the fitted model
    % parameters for all targets
    % detection efficiency curve is determined only for periods below
    % meanPeriodCutoffDueToWindowFunctionAll
    saveFileFullPathName = strcat(detectionEfficiencyDir,groupLabel,'-detection-efficiency-',matchMethod,'-matching-',detectionEfficiencyModelLabel,'-model',periodLabel,'.mat');
    saveFileName = strcat(groupLabel,'-detection-efficiency-',matchMethod,'-matching-',detectionEfficiencyModelLabel,'-model',periodLabel,'.mat');
    save(saveFileFullPathName, ...
        'parameter1','parameter2','parameter3', ...
        'detectionEfficiencyAll','nDetectedAll','nMissedAll','midMesBin', ...
        'fvalAll', 'exitflagAll','uniqueKeplerId','meanPeriodCutoffDueToWindowFunctionAll','periodLabel')
    
    % Report on fits
    fprintf('median of parameters A, B, and C are %8.4f %8.4f %8.4f\n',median(parameter1),median(parameter2),median(parameter3))
    fprintf('std deviations for parameters A, B, and C are %8.4f %8.4f %8.4f\n',std(parameter1),std(parameter2),std(parameter3))
    
    % Create a zip archive for model fits
    skip = true;
    if(~skip)
        zipFile = strcat(detectionEfficiencyDir,groupLabel,'-detection-efficiency-',matchMethod,'-matching-',detectionEfficiencyModelLabel,'-model.gz');
        cd(detectionEfficiencyDir)
        evalString = sprintf('!gzip -c %s > %s',saveFileName,zipFile);
        eval(evalString);
        cd(baseDir);
        % Copy the gzipped tarfile to the NFS
        nfsDir = '/path/to/detection-efficiency-curves/';
        evalString = sprintf('copyfile %s %s;',zipFile,nfsDir);
        eval(evalString);
    end
    
    
end %fitDetectionEfficiency

% end % Loop over periodRanges

toc
