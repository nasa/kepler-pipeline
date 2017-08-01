% plot_window_functions.m
% Chris suggests
% calculate empirical window function directly from injection struct
% Look for expected MES >= 20
% impact parameter < 0.1
% Look at fraction recovered vs. period
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

% Intitialize
clear

% Constants
cadencesPerDay = 48.9390982304706;
superResolutionFactor = 3;
% minWindowFunction = 0.97;
% correlationThreshold = 0.92;
% mesCorrectionFactor = 0.8739;
% eccentricity = 1;
pulseDurationsHours = [1.5, 2.0, 2.5, 3.0, 3.5, 4.5 , 5.0, 6.0, 7.5, 9.0, 10.5, 12.0, 12.5, 15.0];
% rSunCm = 6.95508d10; %cm, from Allen's astrophysical quantities, 3rd ed.,  p. 340
% au2cm = 1.49598d13 ;% 1 AU = 1.49598e13 cm (agrees to 5 decimal places with Allen's astrophysical quantities, 3rd ed.,  p. 340)
% rEarthCm = 6378.136d5;

% Control parameters
mesThreshold = 15;
maxImpactParameter = 0.95;
% maxImpactParameter = 0.4;

% Period Binning Scheme
minPeriodDays = 20;
maxPeriodDays = 720;
deltaPeriodDays = 5;
periodBinEdges = minPeriodDays:deltaPeriodDays:maxPeriodDays;
periodBinCenters = (periodBinEdges(1:end-1) + periodBinEdges(2:end))./2;

% Bin centers for smoothed data
% periodBinCentersNew = mean(reshape(periodBinCenters,10,70));

% Path to floatchoose for computation of analytic window function
addpath '/codesaver/work/eta_earth/common';

% Directory to save plots
plotDir = '/codesaver/work/transit_injection/window_function/';

% Directory in which to save the diagnostic results
saveDir = '/codesaver/work/transit_injection/data/';

% Get directories for injection struct and diagnostics
groupLabel = input('Injection run label -- e.g. KSOC-4976-1: ','s');
[topDir, diagnosticDir] = get_top_dir(groupLabel);

% Load the injection struct
load(strcat(topDir,'tps-injection-struct.mat'))

% Get Unique keplerIds
keplerIdList = unique(tpsInjectionStruct.keplerId);
keplerIdList = keplerIdList(:)';

% Loop over targets
for keplerId = keplerIdList(1)
    
    % !!!!! Load the diagnostic struct
    % load(strcat(diagnosticDir,'tps-diagnostic-struct-KIC3114789-KIC-3114789.mat'))
    load( strcat(diagnosticDir,'tps-diagnostic-struct-',groupLabel,'-KIC-',num2str(keplerId),'-threshold-0.5.mat') )
    
    % Get indices into tpsInjectionStruct that correspond to the desired keplerId
    targetIndicator = tpsInjectionStruct.keplerId == keplerId;
    
    % Get the stellarParameterStruct, needed for dataspan
    % !!!!! Case of multiple target injection run is now handled below
    load(strcat(saveDir,groupLabel,'_stellar_parameters.mat'),'stellarParameterStruct')
    targetSelectIndicator = stellarParameterStruct.keplerId == keplerId;
    dataSpanInCadences = stellarParameterStruct.dataSpanInCadences(targetSelectIndicator);
    dataSpanInDays = dataSpanInCadences./cadencesPerDay;
    % Default dutyCycle is incorrect
    % dutyCycle = stellarParameterStruct.dutyCycle(targetSelectIndicator);
    
    % Expected MES -- see Shawn's notes
    % This is the best estimate of MES, correcting maxMes for coarseness of period and
    % transit duration grids and transit shape mismatch.
    % expectedMes = tpsInjectionStruct.injectedDepthPpm(targetIndicator) .* 1e-6 .* tpsInjectionStruct.normSum000(targetIndicator);
    % !!!!! NOTE -- using normSum111 in expectedMes because it is always
    % populated with a valid number
    expectedMes = tpsInjectionStruct.injectedDepthPpm(targetIndicator) .* 1e-6 .* tpsInjectionStruct.normSum111(targetIndicator);
    % maxMes = tpsInjectionStruct.maxMesWhenSearchedWithInjectedPeriodAndDuration(targetIndicator);
    
    % Impact parameter
    impactParameter = tpsInjectionStruct.impactParameter(targetIndicator);
    
    % Is Planet a Candidate
    % isPlanetACandidate = tpsInjectionStruct.isPlanetACandidateWhenSearchedWithInjectedPeriodAndDuration(targetIndicator);
    isPlanetACandidate = tpsInjectionStruct.isPlanetACandidate(targetIndicator);
    
    % Fitted Period
    periodDays = tpsInjectionStruct.periodDays(targetIndicator);
    
    % Fitted Radius
    planetRadiusInEarthRadii = tpsInjectionStruct.planetRadiusInEarthRadii(targetIndicator);
    
    % Epoch
    injectedEpochKjd = tpsInjectionStruct.injectedEpochKjd(targetIndicator);
    
    % numSesInMes
    numSesInMes = tpsInjectionStruct.numSesInMesWhenSearchedWithInjectedPeriodAndDuration(targetIndicator);
    
    % fitSinglePulse
    fitSinglePulse = tpsInjectionStruct.fitSinglePulseWhenSearchedWithInjectedPeriodAndDuration(targetIndicator);
    
    % injectedDepthPpm
    injectedDepthPpm = tpsInjectionStruct.injectedDepthPpm(targetIndicator);
    
    % fittedDepthPpm
    fittedDepthPpm = tpsInjectionStruct.fittedDepth(targetIndicator);
    fprintf('%d of %d injections for KIC %d  had no valid fittedDepth \n',sum(fittedDepthPpm<0),length(fittedDepthPpm),keplerId)
    
    %======================================================================
    % Select valid injections
    
    % Period in selected range
    validPeriodIndicator = tpsInjectionStruct.injectedPeriodDays(targetIndicator) > minPeriodDays & tpsInjectionStruct.injectedPeriodDays(targetIndicator) < maxPeriodDays;
    
    % MES higher than threshold
    highMesIndicator = expectedMes > mesThreshold & impactParameter < maxImpactParameter;
    
    % Valid injections for empiricalWindowFunction1:
    % nonzero injected depth and period in selected range
    validInjectionIndicator1 = injectedDepthPpm ~= 0 & validPeriodIndicator;% & highMesIndicator;
    
    
    % Valid injections for empiricalWindowFunction2:
    % nonzero injected depth, period in selected range, and high MES
    validInjectionIndicator2 = validInjectionIndicator1 & highMesIndicator;
   
    %======================================================================
    % Empirical Window Functions
    
    % Empirical window function1:
    % Fraction of valid injections with
    %   (nTransits > 3) OR (nTransits == 3 AND ~fitSinglePulse)   
    % numTransitIndicator = numSesInMes > 3 | numSesInMes == 3 & ~fitSinglePulse;
   
    % Recovered and not recovered for empiricalWindowFunction1
    % recoveredIndicator1 =  numTransitIndicator & validInjectionIndicator1;
    % notRecoveredIndicator1 =  ~numTransitIndicator & validInjectionIndicator1;
    % nRecovered1 = histc(periodDays(recoveredIndicator1),periodBinEdges);
    % nRecovered1 = nRecovered1(1:end-1);
    % nNotRecovered1 = histc(periodDays(notRecoveredIndicator1),periodBinEdges);
    % nNotRecovered1 = nNotRecovered1(1:end-1);
    % empiricalWindowFunction1Old = nRecovered1./( nRecovered1 + nNotRecovered1 );
    
    
    % Indicator for valid injections: equivalent to
    % denominatorIndicator1 in get_empirical_window_function
    % denIdx1 = recoveredIndicator1 | notRecoveredIndicator1;
    
    % This should be equal to the sum of nRecovered and nNotRecovered
    % nnAll1 = histc(periodDays(denIdx1),periodBinEdges);
    
    
    % Empirical window function2:
    % Fraction of valid high-MES injections that were TCEs
    % Recovered and not recovered for empiricalWindowFunction2
    % recoveredIndicator2 = isPlanetACandidate & validInjectionIndicator2;
    % notRecoveredIndicator2 = ~isPlanetACandidate & validInjectionIndicator2;
    % nRecovered2 = histc(periodDays(recoveredIndicator2),periodBinEdges);
    % nRecovered2 = nRecovered2(1:end-1);
    % nNotRecovered2 = histc(periodDays(notRecoveredIndicator2),periodBinEdges);
    % nNotRecovered2 = nNotRecovered2(1:end-1);
    % empiricalWindowFunction2Old = nRecovered2./( nRecovered2 + nNotRecovered2 );
    
    % Empirical window functions are smoothed using Savitzky-Golay filter
    [~, NNtce1, NNall1, empiricalWindowFunction1, NNtce2, NNall2, empiricalWindowFunction2] = ...
        get_empirical_window_function(minPeriodDays,maxPeriodDays,deltaPeriodDays,groupLabel,keplerId,mesThreshold,maxImpactParameter);
    
    %======================================================================
    % Analytic window functions
    
    % Effective number of transits
    nTransitsEffective = dataSpanInDays./periodBinCenters;
    
    % Analytic WF 1
    dutyCycle1 = 0.78;
    [analyticWindowFunctionBinCenters, analyticWindowFunction1] = get_analytic_window_function(minPeriodDays,maxPeriodDays,deltaPeriodDays,groupLabel,keplerId,dutyCycle1);
    
    % Analytic WF 2
    dutyCycle2 = 0.82;
    [~, analyticWindowFunction2] = get_analytic_window_function(minPeriodDays,maxPeriodDays,deltaPeriodDays,groupLabel,keplerId,dutyCycle2);
    
    
    % Average over ten 1 day bins
    % empiricalWindowFunction1Smoothed = mean(reshape(empiricalWindowFunction1,10,70));
    % empiricalWindowFunction2Smoothed = mean(reshape(empiricalWindowFunction2,10,70));
    %======================================================================
    % Window functions vs. period curve for this target
    figure
    hold on
    box on
    grid on
    % plot(periodBinCenters,empiricalWindowFunction2,'g--','LineWidth',2)
    % plot(periodBinCenters,analyticWindowFunction2,'k--','LineWidth',2)
   
    % For pulses 6 - 14, the numerical window function looks similar
    for iPulse = 14
        periodsWindowFunctionDays = tpsDiagnosticStruct(iPulse).periodsWindowFunction./superResolutionFactor./cadencesPerDay;
        windowFunctionForPulse =  tpsDiagnosticStruct(iPulse).windowFunction;
        plot(periodsWindowFunctionDays, windowFunctionForPulse,'b--','LineWidth',2)  
    end
    plot(analyticWindowFunctionBinCenters,analyticWindowFunction1,'b-','LineWidth',2)
    plot(analyticWindowFunctionBinCenters,analyticWindowFunction2,'m-','LineWidth',2)
    plot(periodBinCenters,empiricalWindowFunction1,'r-','LineWidth',2)
    plot(periodBinCenters,empiricalWindowFunction2,'k-','LineWidth',2)
    
    % Creat the new numerical window function
    % Run test_compute_fit_single_pulse_for_diagnostics to produce the
    % tps-diagnostic-struct
    load tps-diagnostic-struct.mat
   
    % Plot the new numerical window function looks similar
    for iPulse = 10
        periodsWindowFunctionDays = tpsDiagnosticStruct(iPulse).periodsWindowFunction./superResolutionFactor./cadencesPerDay;
        windowFunctionForPulse =  tpsDiagnosticStruct(iPulse).windowFunction;
        plot(periodsWindowFunctionDays, windowFunctionForPulse,'g--','LineWidth',2)  
    end
    
    legendString1 = 'Empirical WF1: at least 3 good transits';
    legendString2 = ['Empirical WF2: MES > ',num2str(mesThreshold),' & b < ',num2str(maxImpactParameter),' & PC'];
    legendString3 = ['Analytic Window Function, dutyCycle = ',num2str(dutyCycle1,'%6.2f')];
    legendString4 = ['Analytic Window Function, dutyCycle = ',num2str(dutyCycle2,'%6.2f')];
    legendString5 = ['9.2 Numerical Window Function, pulse duration ',num2str(pulseDurationsHours(iPulse)),' hours'];
    legendString6 = ['New Numerical Window Function, pulse duration ',num2str(pulseDurationsHours(iPulse)),' hours'];
    
    % legend(legendString1,legendString2,legendString3,legendString4,legendString5,'Location','North')
    legend(legendString5,legendString3,legendString4,legendString1,legendString2,legendString6,'Location','North')
    % axis([minPeriodDays,maxPeriodDays,0,1.5])
    axis([200,maxPeriodDays,0,1.75])
    set(gca,'FontSize',12)
    set(findall(gcf,'type','text'),'FontSize',12)
    title(['Window functions for ',num2str(keplerId)])
    xlabel('Period [Days]')
    ylabel('Window Function')
    plotName = strcat(plotDir,'window-functions-KIC-',num2str(keplerId));
    print('-r150','-dpng',plotName)
    
end



