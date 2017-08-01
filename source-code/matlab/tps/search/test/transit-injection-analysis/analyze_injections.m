% Script to examine injected TCEs
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
clear all

% Test 3 from KSOC-4841
% dataDir = '/path/to/test_3_walltime_600000_08022015/tps-matlab-2015213/tps-matlab-2015213-00/st-0/';
% load(strcat(dataDir,'tps-inputs-0.mat'));

% Directories with large injection runs
% Baseline parameter set
% Test 3 from KSOC-4841
% injectionRunDirA = '/path/to/test_3_walltime_600000_08022015/tps-matlab-2015213/';
% Parameters from TPS tuning run, KSOC-4686
% injectionRunDirB = '/path/to/test_3_walltime_600000_08022015/tps-matlab-2015214/';

% Test 2 (2 stars with 0.5 M injections each) from KSOC-4861 Sun 16 Aug 2015
injectionRunDir = '/path/to/test_2_walltime_300000_08162015/tps-matlab-2015226/';
injectionRunId = 'KSOC-4861-test2';

% Path to KSOC-4841 branch
% addpath /path/to/branches/ksoc-4841/matlab/tps/search/test/transit-injection/

% Path to this script
addpath /codesaver/work/transit_injection/scripts/

% Load the diagnostic struct I created
% load(strcat('/codesaver/work/transit_injection/scripts/','tps-diagnostic-struct.mat'));

% directories with shawn's files
shawnKsocDir = '/path/to/ksoc/ksoc-4104/';
shawnInjectionDir = '/path/to/injection/';
% addpath(shawnKsocDir);


% Run transit_injection_controller
% tpsInputStruct = inputsStruct;
% injectionOutputStruct = transit_injection_controller( tpsInputStruct )

% Load transit injection output
% Make indicators for each unique star
load(strcat(injectionRunDir,'tps-injection-struct.mat'));

% tpsInjectionStruct =
%
%                       topDir: 'tps-matlab-2015213'
%                     keplerId: [1218636x1 int32]
%                  elapsedTime: [1218636x1 single]
%          log10SurfaceGravity: [1008x1 single]
%             log10Metallicity: [1008x1 single]
%                effectiveTemp: [1008x1 single]
%    stellarRadiusInSolarRadii: [1008x1 single]
%           dataSpanInCadences: [1008x1 single]
%                    dutyCycle: [1008x1 single]
%                      rmsCdpp: [1218636x1 single]
%                       maxMes: [1218636x1 single]
%                  numSesInMes: [1218636x1 single]
%                     epochKjd: [1218636x1 single]
%                   periodDays: [1218636x1 single]
%     trialTransitPulseInHours: [1218636x1 single]
%           isPlanetACandidate: [1218636x1 single]
%              robustStatistic: [1218636x1 single]
%               fitSinglePulse: [1218636x1 single]
%                  fittedDepth: [1218636x1 single]
%               fittedDepthChi: [1218636x1 single]
%                     zCompSum: [1218636x1 single]
%       thresholdForDesiredPfa: [1218636x1 single]
%                   chiSquare2: [1218636x1 single]
%                 chiSquareGof: [1218636x1 single]
%                chiSquareDof2: [1218636x1 single]
%              chiSquareGofDof: [1218636x1 single]
%                   corrSum000: [1218636x1 single]
%                   corrSum001: [1218636x1 single]
%                   corrSum010: [1218636x1 single]
%                   corrSum011: [1218636x1 single]
%                   corrSum100: [1218636x1 single]
%                   corrSum101: [1218636x1 single]
%                   corrSum110: [1218636x1 single]
%                   corrSum111: [1218636x1 single]
%                   normSum000: [1218636x1 single]
%                   normSum001: [1218636x1 single]
%                   normSum010: [1218636x1 single]
%                   normSum011: [1218636x1 single]
%                   normSum100: [1218636x1 single]
%                   normSum101: [1218636x1 single]
%                   normSum110: [1218636x1 single]
%                   normSum111: [1218636x1 single]
%            transitModelMatch: [1218636x1 single]
%           injectedPeriodDays: [1218636x1 single]
%     planetRadiusInEarthRadii: [1218636x1 single]
%              impactParameter: [1218636x1 single]
%             injectedEpochKjd: [1218636x1 single]
%              semiMajorAxisAu: [1218636x1 single]
%      injectedDurationInHours: [1218636x1 single]
%             injectedDepthPpm: [1218636x1 single]
%           inclinationDegrees: [1218636x1 single]
%        equilibriumTempKelvin: [1218636x1 single]
%                     taskfile: {1008x1 cell}
effectiveTemperature = tpsInjectionStruct.effectiveTemp;
log10SurfaceGravity = tpsInjectionStruct.log10SurfaceGravity;
log10Metallicity = tpsInjectionStruct.log10Metallicity;
rmsCdpp = tpsInjectionStruct.rmsCdpp;
keplerId = tpsInjectionStruct.keplerId;
targetId = unique(keplerId);
nTargets = length(targetId);
% Number of injections
nInjections = length(tpsInjectionStruct.keplerId);

%==========================================================================

% Struct fields 
chiSquare2 = tpsInjectionStruct.chiSquare2;
robustStatistic = tpsInjectionStruct.robustStatistic;
chiSquareGof = tpsInjectionStruct.chiSquareGof;
isPlanetACandidate = tpsInjectionStruct.isPlanetACandidate;
chiSquareDof2 = tpsInjectionStruct.chiSquareDof2;
chiSquareGofDof = tpsInjectionStruct.chiSquareGofDof;
maxMes = tpsInjectionStruct.maxMes;
periodDays = tpsInjectionStruct.periodDays;
% thresholdForDesiredPfa field is all -1's, so bootstrapOkay is always true
% in fold_statistics_and_apply_vetores.m
thresholdForDesiredPfa = tpsInjectionStruct.thresholdForDesiredPfa;

% Veto Thresholds
chiSquareGofThreshold = 6.8;
chiSquare2Threshold = 7.0;
robustStatisticThreshold = 7.0;
mesThreshold = 7.1;

% Determine vetos: watch out for -1 values
chiSquareValid = chiSquareGof > 0;
chiSquareGofOkay = chiSquareValid & maxMes./(sqrt(chiSquareGof./chiSquareGofDof)) >= chiSquareGofThreshold;
chiSquare2Okay = chiSquareValid & maxMes./(sqrt(chiSquare2./chiSquareDof2)) >= chiSquare2Threshold;
robustStatisticOkay = robustStatistic >= robustStatisticThreshold;

% Experiment suggested by Chris: restore isPlanetACandidate == true for
% TCEs that failed the chiSquareGof veto but passed the others
% See if that accounts for the period dependence of detection efficiency
changeVetoes = true;
if(changeVetoes)
    fprintf('There are %d candidates\n',sum(tpsInjectionStruct.isPlanetACandidate))
    isPlanetACandidate(~chiSquareGofOkay & chiSquare2Okay & robustStatisticOkay ) = true;
    fprintf('There are %d TCEs that failed the chiSquareGof veto but passed the other two vetoes\n',sum(isPlanetACandidate) - sum(tpsInjectionStruct.isPlanetACandidate))
    
    % Number of TCEs that failed the chiSquareGof veto but passed the other two vetoes, for first two targets
    sum(isPlanetACandidate(keplerId==targetId(1))) - sum(tpsInjectionStruct.isPlanetACandidate(keplerId==targetId(1)))
    sum(isPlanetACandidate(keplerId==targetId(2))) - sum(tpsInjectionStruct.isPlanetACandidate(keplerId==targetId(2)))
    
    figure(10)
    hist(periodDays(~chiSquareGofOkay & chiSquare2Okay & robustStatisticOkay ))
    xlabel('Period [days]')
    ylabel('Counts')
    cc = 'r';
    
    
else
    cc = 'b';
end
%==========================================================================
% Match injected to fitted transits
% !!!!! I conclude we should use the ephemerisMatchIndicator
% (with threshold at 0.90) to select valid
% injections.
% matchMethod = 'ephemeris';
matchMethod = 'epoch';
fprintf('matchMethod = %s\n',matchMethod)

switch matchMethod
    
    case 'epoch'
        % A. By epoch-matching
        % From Chris' code examinject.m
        % epochMatchIndicator = abs(tpsInjectionStruct.injectedEpochKjd - tpsInjectionStruct.epochKjd)*48.939 < tpsInjectionStruct.injectedDurationInHours *48.939 / 2 / 24 ;
        % A match is flagged if the difference between injected and detected epochs
        % is less than half a transit duration
        epochMatchIndicator = abs(tpsInjectionStruct.injectedEpochKjd - tpsInjectionStruct.epochKjd) < tpsInjectionStruct.injectedDurationInHours / 2 / 24 ;
        period1 = double(tpsInjectionStruct.injectedPeriodDays);
        period2 = double(tpsInjectionStruct.periodDays);
        epoch1 = double(tpsInjectionStruct.injectedEpochKjd);
        epoch2 = double(tpsInjectionStruct.epochKjd);
        
    case 'ephemeris'
        % B. By ephemeris-matching
        % Match injected transits with detected transits via Pearson's correlation.
        % Question: is the order in the fitted list the same as that of the
        % injections? If so, we only need to compute the diagonal of the
        % correlation matrix.
        % Use Sean's fast correlation code to correlate each injection with its
        % detected counterpart.
        period1 = double(tpsInjectionStruct.injectedPeriodDays);
        period2 = double(tpsInjectionStruct.periodDays);
        epoch1 = double(tpsInjectionStruct.injectedEpochKjd);
        epoch2 = double(tpsInjectionStruct.epochKjd);
        duration1 = double(tpsInjectionStruct.injectedDurationInHours./24);
        duration2 = double(tpsInjectionStruct.injectedDurationInHours./24);
        calculatePearsonCorrelation = true;
        if(calculatePearsonCorrelation)
            fprintf('Calculating correlations ...\n')
            tic
            % Initialize
            fullfile(getenv('SOC_CODE_ROOT'), '/matlab/av/ephemeris-correlation/');
            observationStartTime = 0;
            observationEndTime = observationStartTime + 4 * 365.25;
            correlationResolution = 1/(24*60); % one minute
            correlationThreshold = 0.90;
            ephemerisCorrelation = zeros(length(epoch1 ),1);
            
            % If period or epoch are negative, set correlation to 0
            badCorrelationIndicator = period2 < 0 | epoch2 < 0;
            ephemerisCorrelation(badCorrelationIndicator) = 0;
            inds = 1:length(ephemerisCorrelation);
            validInds = inds(~badCorrelationIndicator);
            for iInjection = validInds
                ephemerisCorrelation(iInjection) = ephemeris_cross_correlation_matrix([1,epoch1(iInjection),period1(iInjection),duration1(iInjection)], ...
                    [1,epoch2(iInjection),period2(iInjection),duration2(iInjection)],observationStartTime, observationEndTime, correlationResolution);
                if(mod(iInjection,1000)==0)
                    fprintf('iInjection %d\n',iInjection)
                end
            end
            toc
            
            % Indicator for good ephemeris matches
            ephemerisMatchIndicator = ephemerisCorrelation > correlationThreshold;
            save(strcat(injectionRunId,'-','ephemerisMatch.mat'),'ephemerisMatchIndicator','ephemerisCorrelation','correlationThreshold')
            
        else
            
            % Retrieve saved file
            load('ephemerisMatch.mat')
            
        end
        
        % Look at the correlation of epoch-matched TCEs
        figure
        hold on
        box on
        grid on
        title('Correlation of epoch-matched TCEs')
        hist(ephemerisCorrelation(epochMatchIndicator),0:0.05:1)
        xlabel('Ephemeris Correlation (Pearsons Correlation Coefficient)');
        ylabel('Counts');
        set(gca,'FontSize',12)
        set(findall(gcf,'type','text'),'FontSize',12)
        plotName = strcat(injectionRunId,'-','correlationOfEpochMatchedTces');
        print('-r150','-dpng',plotName)
        
        % Find
        % 26,693 TCEs with correlation < 0.75
        % 52,821 TCEs with correlation < 0.90
        
end


switch matchMethod
    case 'ephemeris'
        matchIndicator = ephemerisMatchIndicator;
    case 'epoch'
        matchIndicator = epochMatchIndicator;
end


%==========================================================================
% Constants
minPeriodDays = 20;

% Note the injections were done uniformly in period, not uniformly in log10(period)
maxPeriodDays = max(tpsInjectionStruct.periodDays);

% But many more injections were done at radii less than 1.5 than between
% 1.5 and 3.5 even though radius sampling was 'uniform'

% Impact parameters are uniform between 0 and 0.95, much lower
% between 0.95 and 1

% Flag valid injections: i.e. were epoch-matched, had nonzero injected depth, more than 3 transits,
% period in desired range.
validInjectionIndicator = ...                                         % 562,017
    tpsInjectionStruct.injectedDepthPpm ~=0 ...                       % 1,218,636
    & tpsInjectionStruct.numSesInMes >= 3 ...                          % 614,699 -- !!!!! NOTE that this was originally > 3, which requires 4 transits
    & tpsInjectionStruct.periodDays < maxPeriodDays ...               % 1,218,602
    & tpsInjectionStruct.periodDays > minPeriodDays ...
    & matchIndicator ...                                              % 991,662
    & ~(tpsInjectionStruct.numSesInMes == 3 & tpsInjectionStruct.fitSinglePulse==true); % this line is superfluous if >3  transits are required

% Expected MES -- see Shawn's notes
mes = tpsInjectionStruct.injectedDepthPpm .* 1e-6 .* tpsInjectionStruct.normSum000;
% Note: changed the above line to the one below 27 Aug 2015, as per Shawn's
% email from 6/24/2015 at 10:00 AM
% mes = tpsInjectionStruct.injectedDepthPpm .* 1e-6 .* tpsInjectionStruct.normSum000.* tpsInjectionStruct.transitModelMatch;
% But the question is: should it be normSum000 as in above, or normSum111
% as in below?
% From Shawn: (reference?)
% 1) mes = injResults.injectedDepthPpm(ind) .* 1e-6 .* injResults.normSum000(ind);
%    normSum000 is the normalization sum: sqrt(s.s), with
%    all the realistic effects of whitening, timing, and shape mismatch in
%    place. So this is the expected MES but it doesnt account for
%    deweighting.
% 2) mes = injResults.injectedDepthPpm .* 1e-6 .* injResults.normSum111 .* injResults.transitModelMatch;
%    this is the expected MES with all the
%    effects of whitening, timing, and shape mismatch taken out - so this
%    should be the best achievable MES.

% Select stellar catalog (but all stellar parameters are those of
% Kepler-22)
% selectionMode = 'all';


% Single or multiple targets
targetListType = 'multiple';
switch targetListType
    case 'single'
        
        
        % Initialize figure for detection efficiency vs. MES
        figure
        hold on
        box on
        grid on
        % plot(midx,cdf('norm',midx,7.1,1),'k-','LineWidth',3)
        % vline(7.1)
        % title('Kepler-22 detection efficiency curve as a function of number of injections')
        xlabel('MES')
        % ylabel('DetectionEfficiency + offset (for clarity)')
        ylabel('DetectionEfficiency')
        
        
        % !!!!! Control parameter
        % currently two options
        % Use 'number' to investigate sensitivity of detection efficiency curve to number of injections
        % Use 'period' to investigate sensitivity of detection efficiency curve to
        % period range of injections
        % selectBy = 'number';
        selectBy = input('Investigate sensitivity to: number or period -- ','s');
        
        
        
        % Select injected catalog
        switch selectBy
            case 'period'
                selectionRange = {'quarter'};
                title('Kepler-22 detection efficiency curve: period sensitivity')
            case 'number'
                selectionRange = {'all','half', 'quarter', 'eighth', 'sixteenth','thirtysecondth'};
                title('Kepler-22 detection efficiency curve: sensitivity to number of injections')
        end
        nSelected = zeros(1,length(selectionRange));
        
        for selectionMode = selectionRange
            
            % Report selection mode
            selectionModeChar = selectionMode{:};
            fprintf('Selection mode is %s\n',selectionModeChar);
            
            % Initialize
            selectionIndicator = false(nInjections,1);
            
            % Effective temperature ranges are from Allen's Astrophysical
            % Quantitites 4th edition
            switch selectionModeChar
                
                case 'all'
                    selectionIndicator = true(nInjections,1);
                    xColor = 'k';
                    offset = 0;
                    nSelected(1) = nInjections;
                    
                case 'Fstars'
                    selectionIndicator = effectiveTemperature < 7020 & effectiveTemperature > 5930 ;
                    
                case 'Gstars'
                    selectionIndicator = effectiveTemperature < 5930 & effectiveTemperature > 5240 ;
                    
                case 'Kstars'
                    selectionIndicator = effectiveTemperature < 5240 & effectiveTemperature > 3680 ;
                    
                case 'Mstars'
                    selectionIndicator = effectiveTemperature < 3680 ;
                    
                case 'HighMetallicity' % Z > -1
                    selectionIndicator =  log10Metallicty > -1 ;
                    
                case 'LowMetallicity' % -3 < Z < -1
                    selectionIndicator =  log10Metallicty < -1 ;
                    
                case 'Bright' % keplerMag < 15
                    
                case 'Faint'  % keplerMag > 15
                    
                case 'LowGravity' % logg
                    selectionIndicator =  log10SurfaceGravity < -4 ;
                    
                case 'HighGravity' % logg
                    selectionIndicator =  log10SurfaceGravity > -4 ;
                    
                case 'LowCDPP'
                    
                case 'HighCDPP'
                    
                case 'half'
                    nSelected(2) = round(nInjections/2);
                    % !!!!! problem: randi samples with replacement
                    % we want to sample without replacement.
                    starIndices = randi(nInjections,nInjections,1);
                    starIndices = unique(starIndices);
                    starIndices = starIndices(1:nSelected(2));
                    selectionIndicator(starIndices) = true;
                    xColor = 'c';
                    offset = 0.15;
                    
                case 'quarter'
                    nSelected(3) = round(nInjections/4);
                    starIndices = randi(nInjections,nInjections,1);
                    starIndices = unique(starIndices);
                    starIndices = starIndices(1:nSelected(3));
                    selectionIndicator(starIndices) = true;
                    xColor = 'b';
                    offset = 0.3;
                    
                case 'eighth'
                    nSelected(4) = round(nInjections/8);
                    starIndices = randi(nInjections,nInjections,1);
                    starIndices = unique(starIndices);
                    starIndices = starIndices(1:nSelected(4));
                    selectionIndicator(starIndices) = true;
                    xColor = 'g';
                    offset = 0.45;
                    
                case 'sixteenth'
                    nSelected(5) = round(nInjections/16);
                    starIndices = randi(nInjections,nInjections,1);
                    starIndices = unique(starIndices);
                    starIndices = starIndices(1:nSelected(5));
                    selectionIndicator(starIndices) = true;
                    xColor = 'r';
                    offset = 0.6;
                    
                case 'thirtysecondth'
                    nSelected(6) = round(nInjections/32);
                    starIndices = randi(nInjections,nInjections,1);
                    starIndices = unique(starIndices);
                    starIndices = starIndices(1:nSelected(6));
                    selectionIndicator(starIndices) = true;
                    xColor = 'm';
                    offset = .75;
            end % switch selectionModel
            
            
            
            % Loop over period ranges
            switch selectBy
                case 'period'
                    % periodRangeSet = {'20-100','100-200','200-300','300-400','400-500'};
                    periodRangeSet = {'20-100','100-200','200-300','300-500'};
                    
                    for periodRange = periodRangeSet
                        
                        % Report selection mode
                        periodRangeX = periodRange{:};
                        fprintf('Period range is %s\n',periodRangeX);
                        
                        
                        switch periodRangeX
                            
                            % case '20-100'
                            %    pMin = 20;
                            %    pMax = 50;
                            %    xColor = 'c';
                            
                            case '20-100'
                                pMin = 50;
                                pMax = 100;
                                xColor = 'm';
                                
                            case '100-200'
                                pMin = 100;
                                pMax = 200;
                                xColor = 'b';
                                
                            case '200-300'
                                pMin = 200;
                                pMax = 300;
                                xColor = 'g';
                                
                            case '300-500'
                                pMin = 300;
                                pMax = 500;
                                xColor = 'r';
                                
                                % case '400-500'
                                %    pMin = 400;
                                %    pMax = 500;
                                %    xColor = 'm';
                                
                        end % switch periodRangeX
                        
                        periodSelectionIndicator = period1 > pMin & period1 <= pMax;
                        
                        % report number of injections for this sample
                        numberOfInjections =  sum(validInjectionIndicator & selectionIndicator & periodSelectionIndicator);
                        fprintf('Number of valid selected injections = %d\n',numberOfInjections)
                        
                        % Injections of interest that did *not* become TCEs
                        mesMissed = mes(isPlanetACandidate==0 & validInjectionIndicator & selectionIndicator & periodSelectionIndicator);
                        
                        % Injections of interest that became TCEs
                        mesDetected = mes(isPlanetACandidate==1 & validInjectionIndicator & selectionIndicator & periodSelectionIndicator);
                        
                        % Plot theoretical cumulative distribution vs. MES
                        DELMES=0.1;
                        xedges=2.0:DELMES:16.0;
                        midx=xedges(1:end-1)+diff(xedges)/2.0;
                        
                        % Histogram of MES of missed TCEs
                        nMissedTemp = histc(mesMissed,xedges);
                        nMissed = nMissedTemp(1:end-1);
                        
                        % Histogram of MES of TCEs
                        nDetectedTemp = histc(mesDetected,xedges);
                        nDetected = nDetectedTemp(1:end-1);
                        
                        % Detection efficiency vs MES
                        % figure
                        plot(midx,nDetected./(nDetected+nMissed),[xColor,'-'])
                        
                    end % Loop over period ranges
                    
                case 'number'
                    
                    periodSelectionIndicator = period1 > minPeriodDays & period1 <= maxPeriodDays;
                    
                    % Injections of interest that did *not* become TCEs
                    mesMissed = mes(isPlanetACandidate==0 & validInjectionIndicator & selectionIndicator & periodSelectionIndicator);
                    
                    % Injections of interest that became TCEs
                    mesDetected = mes(isPlanetACandidate==1 & validInjectionIndicator & selectionIndicator & periodSelectionIndicator);
                    
                    % Plot theoretical cumulative distribution vs. MES
                    DELMES=0.1;
                    xedges=2.0:DELMES:16.0;
                    midx=xedges(1:end-1)+diff(xedges)/2.0;
                    
                    % Histogram of MES of missed TCEs
                    nMissedTemp = histc(mesMissed,xedges);
                    nMissed = nMissedTemp(1:end-1);
                    
                    % Histogram of MES of TCEs
                    nDetectedTemp = histc(mesDetected,xedges);
                    nDetected = nDetectedTemp(1:end-1);
                    
                    % Detection efficiency vs MES
                    % figure
                    % plot(midx,offset+nDetected./(nDetected+nMissed),[xColor,'-'])
                    plot(midx,nDetected./(nDetected+nMissed),[xColor,'-'])
                    
            end % selectBy
            
        end % loop over number of injections
        
        % Finish plot
        set(gca,'FontSize',12)
        set(findall(gcf,'type','text'),'FontSize',12)
        switch selectBy
            case 'period'
                legend('20-100 days','100-200 days','200-300 days','300-500 days','Location','SouthEast')
                axis([2,16,0,1.1])
                plotName = strcat(injectionRunId,'-','detectionEfficiencyVsPeriod');
                
            case 'number'
                legend(['all: ',num2str(nSelected(1)),' injections'],['1/2: ',num2str(nSelected(2)),' injections'],['1/4: ',num2str(nSelected(3)),' injections'],['1/8: ',num2str(nSelected(4)),' injections'],['1/16: ',num2str(nSelected(5)),' injections'],['1/32: ',num2str(nSelected(6)),' injections'],'Location','SouthEast')
                axis([2,16,-.75 1.1])
                plotName = strcat(injectionRunId,'-','detectionEfficiencyVsNumberOfInjections');
        end
        print('-r150','-dpng',plotName)
        
        
        
    case 'multiple' % more than one star in injectionStruct
        
        % Produce plots for each period range
        periodRangeSet = {'20-50','50-100','100-200','200-400','400-730'};
        % periodRangeSet = {'20-730'};
        for periodRange = periodRangeSet
            periodRangeX = periodRange{:};
            fprintf('Period range is %s\n',periodRangeX);
            switch periodRangeX
                case '20-50'
                    pMin = 20;
                    pMax = 50;
                    periodIndicator = period1 > pMin & period1 < pMax;
                case '50-100'
                    pMin = 50;
                    pMax = 100;
                    periodIndicator = period1 > pMin & period1 < pMax;
                case '100-200'
                    pMin = 100;
                    pMax = 200;
                    periodIndicator = period1 > pMin & period1 < pMax;
                case '200-400'
                    pMin = 200;
                    pMax = 400;
                    periodIndicator = period1 > pMin & period1 < pMax;
                case '400-730'
                    pMin = 400;
                    pMax = 730;
                    periodIndicator = period1 > pMin & period1 < pMax;
                case '20-730'
                    pMin = 20;
                    pMax = 730;
                    periodIndicator = period1 > pMin & period1 < pMax;
            end
            fprintf('Number of TCEs with %s < period < %s is %d\n',num2str(pMin),num2str(pMax),sum(periodIndicator))
            
            % Detection efficiency curve for each target
            starIndicator = zeros(length(keplerId),nTargets);
            legendString = repmat('00000000',nTargets,1);
            
            % Initialize figure for detection efficiency vs. MES
            figure
            hold on
            box on
            grid on
            title([periodRangeX,' day periods: ','Detection efficiency curves for ',injectionRunId])
            xlabel('MES')
            ylabel('DetectionEfficiency')
            
            % Initialize for plot
            DELMES=0.25;
            xedges=2.0:DELMES:16.0;
            midx=xedges(1:end-1)+diff(xedges)/2.0;
            xColor = 'krbgmc';
            
            nDetected = zeros(nTargets,length(midx));
            nMissed = zeros(nTargets,length(midx));
            detectionEfficiency = zeros(nTargets,length(midx));
            for iTarget = 1:nTargets
                
                % Select the current target
                starIndicator(:,iTarget) = keplerId==targetId(iTarget);
                selectionIndicator = starIndicator(:,iTarget);
                
                % Injections of interest that did *not* become TCEs
                
                
                mesMissed = mes(isPlanetACandidate==0 & validInjectionIndicator & selectionIndicator & periodIndicator  );
                
                % Injections of interest that became TCEs
                mesDetected = mes(isPlanetACandidate==1 & validInjectionIndicator & selectionIndicator & periodIndicator);
                
                % Plot theoretical cumulative distribution vs. MES
                % plot(midx,cdf('norm',midx,7.1,1),'k-','LineWidth',3)
                % vline(7.1)
                
                % Histogram of MES of missed TCEs
                nMissedTemp = histc(mesMissed,xedges);
                nMissed(iTarget,:) = nMissedTemp(1:end-1);
                
                % Histogram of MES of TCEs
                nDetectedTemp = histc(mesDetected,xedges);
                nDetected(iTarget,:) = nDetectedTemp(1:end-1);
                
                % Detection efficiency vs MES
                detectionEfficiency(iTarget,:) = nDetected(iTarget,:)./(nDetected(iTarget,:)+nMissed(iTarget,:));
                plot(midx,detectionEfficiency(iTarget,:),[xColor(iTarget),'.-'])
                legendString(iTarget,:) = num2str(targetId(iTarget));
         
                
            end % loop over targets
            
            % Finish plot
            set(gca,'FontSize',12)
            set(findall(gcf,'type','text'),'FontSize',12)
            legend(['keplerId ',legendString(1,:)],['keplerId ',legendString(2,:)],'Location','SouthEast')
            axis([2,16,0,1.1])
            plotName = strcat(injectionRunId,'-',periodRangeX,'-days-','-','detectionEfficiency');
            print('-r150','-dpng',plotName)
            
            % Plot difference in detection efficiency
            difference = detectionEfficiency(1,:) - detectionEfficiency(2,:);
            fprintf('difference has %d NaNs\n',sum(isnan(difference)))
            
           
            % figure(3)
            figure
            hold on
            grid on
            box on
            plot(midx,difference,[cc,'*-'])
            xlabel('MES')
            ylabel('Difference')
            title([periodRangeX,' day periods: ','Det. eff. diff for keplerIds',num2str(targetId(1)),' and ',num2str(targetId(2))])
            set(gca,'FontSize',12)
            set(findall(gcf,'type','text'),'FontSize',12)
            axis([2,16,-.2,.05 ])
            if(~changeVetoes)
                legend(['median(diff) ',num2str(nanmedian(difference),'%7.3f'),', mean(|diff|) ',num2str(nanmean(abs(difference)),'%7.3f'),', std(diff) ',num2str(nanstd(difference),'%7.3f')],'Location','South')
            elseif(changeVetoes)
                legend('rs, chiSquareGof, and chiSquare2 vetoes','rs and chiSquare2 vetoes only')
            end
            plotName = strcat(injectionRunId,'-',periodRangeX,'-days-','detectionEfficiencyDifference');
            print('-r150','-dpng',plotName)
            
        end % loop over periodRange
        
end % switch targetListType

