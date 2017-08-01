% check_nondetections.m
% check why high-mes injections are being missed
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
injectedPeriodDays = tpsInjectionStruct.injectedPeriodDays;
impactParameter = tpsInjectionStruct.impactParameter;
lowMES = 15.5;
hiMES = 16;
hiPeriod = 730;
lowPeriod = 20;
injectedPeriodInRange = injectedPeriodDays > lowPeriod&injectedPeriodDays < hiPeriod;
planetRadiusInEarthRadii = tpsInjectionStruct.planetRadiusInEarthRadii;

figure
plot(log10(maxMes(isPlanetACandidate==1 & validInjectionIndicator)),log10(expectedMes(isPlanetACandidate==1 & validInjectionIndicator)),'b.')


figure
plot(maxMes(isPlanetACandidate==0 & validInjectionIndicator ),expectedMes(isPlanetACandidate==0 & validInjectionIndicator ),'b.')



figure
plot(maxMes(isPlanetACandidate==1 & validInjectionIndicator ),expectedMes(isPlanetACandidate==1 & validInjectionIndicator ),'b.')

mesOkay = maxMes > 7.1;
bootstrapOkay = maxMes > tpsInjectionStruct.thresholdForDesiredPfa;
chiSquare2Okay = chiSquare2 > 7;
chiSquareGofOkay = chiSquareGof > 6.8;
robustStatisticOkay = robustStatistic > 7;

% Impact parameter of valid injections that did *not* become TCEs
% distribution is flat out to impact parameter of 0.9 where it suddenly
% drops by more than half
figure
hist(tpsInjectionStruct.impactParameter(mesOkay&robustStatisticOkay&chiSquareGofOkay&chiSquare2Okay&~isPlanetACandidate&validInjectionIndicator))


% Impact parameter of valid injections that became TCEs
% distribution rolls off starting at 0.3 
% down by 1/8 in 0.5 to 0.6, 
% by another 1/8 in 0.7 to 0.8
% and by another 4/8 in 0.9 to 0.1
figure
hist(tpsInjectionStruct.impactParameter(mesOkay&robustStatisticOkay&chiSquareGofOkay&chiSquare2Okay&isPlanetACandidate&validInjectionIndicator))



figure
plot((planetRadiusInEarthRadii(expectedMes<16&validInjectionIndicator&isPlanetACandidate)),tpsInjectionStruct.impactParameter(expectedMes<16&validInjectionIndicator&isPlanetACandidate),'r.')

% Scatter plot showing that for MES < 16, minimum impact parameter
% increases with radius for radii larger than 1 Earth
figure
plot((planetRadiusInEarthRadii(expectedMes<16&validInjectionIndicator)),tpsInjectionStruct.impactParameter(expectedMes<16&validInjectionIndicator),'r.')
titleString = sprintf('Impact parameter vs radius for valid injections with expected MES < 16\nGroup 6, KIC%d',targetId);
title(titleString)
xlabel('Planet Radius [Earth Radii]')
ylabel('Impact Parameter')
set(gca,'FontSize',12)
set(findall(gcf,'type','text'),'FontSize',12)
plotName = strcat(detectionEfficiencyDir,'radius-vs-impact-parameter-for-mes-below-16-KIC-',num2str(targetId),periodLabel);
print('-r150','-dpng',plotName)

sum(validInjectionIndicator&~isPlanetACandidate&expectedMes<16&expectedMes>15) % 1690
sum(validInjectionIndicator&isPlanetACandidate&expectedMes<16&expectedMes>15)  % 3975
sum(validInjectionIndicator&~isPlanetACandidate&expectedMes<16&expectedMes>15&impactParameter < 0.9) % 1021
sum(validInjectionIndicator&isPlanetACandidate&expectedMes<16&expectedMes>15&impactParameter < 0.9)  % 3776
sum(validInjectionIndicator&~isPlanetACandidate&expectedMes<16&expectedMes>15&~mesOkay) % 1690

% Plot impact parameter vs. radius for detected and missed planets over a range of MES
% Band of radius at upper limit with missed detections were mostly at
% period > 450 days
figure
hold on
grid on
plot(impactParameter(injectedPeriodInRange&validInjectionIndicator&isPlanetACandidate&expectedMes<hiMES&expectedMes>lowMES),planetRadiusInEarthRadii(injectedPeriodInRange&validInjectionIndicator&isPlanetACandidate&expectedMes<hiMES&expectedMes>lowMES),'r.')
plot(impactParameter(injectedPeriodInRange&validInjectionIndicator&~isPlanetACandidate&expectedMes<hiMES&expectedMes>lowMES),planetRadiusInEarthRadii(injectedPeriodInRange&validInjectionIndicator&~isPlanetACandidate&expectedMes<hiMES&expectedMes>lowMES),'k.')
legend('Detected','Missed','Location','NorthWest')
ylabel('Radius [Earths]')
xlabel('Impact parameter')
title(['Valid injections ',num2str(lowMES),' < expected MES < ',num2str(hiMES),' and ',num2str(lowPeriod),' < period < ',num2str(hiPeriod)])
set(gca,'FontSize',12)
set(findall(gcf,'type','text'),'FontSize',12)

% Plot injected period vs. radius for detected and missed planets over a range of MES
figure
hold on
grid on
plot(injectedPeriodDays(injectedPeriodInRange&validInjectionIndicator&expectedMes<hiMES&expectedMes>lowMES),planetRadiusInEarthRadii(injectedPeriodInRange&validInjectionIndicator&expectedMes<hiMES&expectedMes>lowMES),'k.')
plot(injectedPeriodDays(injectedPeriodInRange&validInjectionIndicator&isPlanetACandidate&expectedMes<hiMES&expectedMes>lowMES),planetRadiusInEarthRadii(injectedPeriodInRange&validInjectionIndicator&isPlanetACandidate&expectedMes<hiMES&expectedMes>lowMES),'ro')
legend('Injected','Detected','Location','Southeast')
ylabel('Radius [Earths]')
xlabel('Period [days]')
title(['Valid injections ',num2str(lowMES),' < expected MES < ',num2str(hiMES)])
set(gca,'FontSize',12)
set(findall(gcf,'type','text'),'FontSize',12)

% Plot detected period vs. radius for detected and missed planets over a range of MES
figure
hold on
grid on
plot(periodDays(injectedPeriodInRange&validInjectionIndicator&expectedMes<hiMES&expectedMes>lowMES),planetRadiusInEarthRadii(injectedPeriodInRange&validInjectionIndicator&expectedMes<hiMES&expectedMes>lowMES),'k.')
plot(periodDays(injectedPeriodInRange&validInjectionIndicator&isPlanetACandidate&expectedMes<hiMES&expectedMes>lowMES),planetRadiusInEarthRadii(injectedPeriodInRange&validInjectionIndicator&isPlanetACandidate&expectedMes<hiMES&expectedMes>lowMES),'ro')
legend('Injected','Detected','Location','Southeast')
ylabel('Radius [Earths]')
xlabel('Period [days]')
title(['Valid injections ',num2str(lowMES),' < expected MES < ',num2str(hiMES)])
set(gca,'FontSize',12)
set(findall(gcf,'type','text'),'FontSize',12)



% Scatter plot showing period vs radius with color showing impact
% parameters
figure
hold on
grid on
scatter(periodDays(validInjectionIndicator),log10(planetRadiusInEarthRadii(validInjectionIndicator)),[],impactParameter(validInjectionIndicator),'.')
xlabel('Period [days]')
ylabel('log10(Radius) [Earths]')
title('KIC 3114789 Injected impact parameter, original run')
t = colorbar('peer',gca);
set(get(t,'ylabel'),'String', 'Impact parameter');
set(gca,'FontSize',12)
set(findall(gcf,'type','text'),'FontSize',12)
plotName = 'InjectedImpactParameterKIC3114789OriginalRun';
print('-r150','-dpng',plotName)

