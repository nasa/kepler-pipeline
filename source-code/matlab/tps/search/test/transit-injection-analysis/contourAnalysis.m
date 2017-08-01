% construct the aggregate detection probability vs. MES estimate 000
% ind=injResults.transitModelMatch>0.95 & ~(injResults.numSesInMes==3 & injResults.fitSinglePulse==true);
% ind=true(size(injResults.keplerId));
% ind = injResults.numSesInMes>2;
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

% remove injections that have a perfect mes Estimate less than 7.1
ind=injResults.transitModelMatch>0.95 & ~(injResults.numSesInMes==3 & injResults.fitSinglePulse==true) & ...
    injResults.corrSum111./injResults.normSum111 > 7.1;

% Cumulative probability of planet
bins = 0:0.5:25;
mes = injResults.corrSum000(ind)./injResults.normSum000(ind);
%mes = injResults.maxMes(ind);
isPlanet = injResults.isPlanetACandidate(ind);
cumProb = hist(mes(isPlanet==true),bins)./hist(mes,bins);
figure
plot(bins,cumProb,'-o')
grid on
hold on
plot(bins,1-0.5*erfc((bins-7.1)./sqrt(2)),'-r*')
xlabel('Expected MES')
ylabel('Detection Probability')
title('Detection Probability for 992 K Stars - match > 0.95')
legend('Injection Data','Theoretical MES Only')


% histogram period and Rp
figure
hist(injResults.injectedPeriodDays,100)
figure
hist(log10(injResults.planetRadiusInEarthRadii(ind)),100)
figure
hist(log10(injResults.injectedPeriodDays(ind)),100)
figure
hist(injResults.numSesInMes(ind),min(injResults.numSesInMes(ind)):1:max(injResults.numSesInMes(ind))')

% make a contour plot for detection probability vs. T and Rp for only
% the injections that had a good transitModelMatch
isPlanet = injResults.isPlanetACandidate(ind);
periods = injResults.injectedPeriodDays(ind);
radii = log10(injResults.planetRadiusInEarthRadii(ind));
nBins = [45 45];
binsXDelta = (max(periods) - min(periods))/nBins(1);
binsYDelta = (max(radii) - min(radii))/nBins(2);
bins = {min(periods):binsXDelta:max(periods) min(radii):binsYDelta:max(radii)};
detProb = hist3([periods radii],bins);
detProb2 = hist3([periods(isPlanet==true) radii(isPlanet==true)],bins) ./ detProb;
[X,Y] = meshgrid(bins{1},bins{2});
figure
[~,h] = contourf(X,Y,detProb2');
set(h,'ShowText','on','TextStep',get(h,'LevelStep'))


% construct bins that have equal numbers of injections and plot both radius
% and period uniformly rather than log

% ind = ~(injResults.numSesInMes==3 & injResults.fitSinglePulse==true) & ...
%    injResults.planetRadiusInEarthRadii<=10 & injResults.planetRadiusInEarthRadii>=0.5;

% ind = injResults.planetRadiusInEarthRadii<=10 & injResults.planetRadiusInEarthRadii>=0.5;

% kepids=uniqueId(ismember(skyGroups,[18 26 58 66 41 42 43 44 62 38 46 22]));
kepids = 10593626; % by jcat
% ind = injResults.injectedDepthPpm ~=0 & injResults.planetRadiusInEarthRadii > 0.5 & ...
%    injResults.planetRadiusInEarthRadii < 10 & ismember(injResults.keplerId,kepids);

% ind = injResults.injectedDepthPpm ~=0 & injResults.planetRadiusInEarthRadii > 0.5 & ...
%    injResults.planetRadiusInEarthRadii < 10 & injResults.normSum000>0 & injResults.corrSum000>0 & ...
%    injResults.numSesInMes>2 & ~(injResults.numSesInMes==3 & injResults.fitSinglePulse==true);

%ind = injResults.injectedDepthPpm ~=0 & injResults.planetRadiusInEarthRadii > 0.5 & ...
%    injResults.planetRadiusInEarthRadii < 10 & ismember(injResults.keplerId,kepids);

ind=injResults.injectedDepthPpm~=0 & ismember(injResults.keplerId,kepids(1));

isPlanet = injResults.isPlanetACandidate(ind);
% epochMatchInd = abs(injResults.injectedEpochKjd - injResults.epochKjd)*48.939 < injResults.injectedDurationInHours *48.939 / 2 / 24 ;
%epochMatchInd = abs(injResults.injectedEpochKjd - injResults.epochKjd)*48.939 < 1;
epochMatchInd = epochMatchInd(ind);
periods = log10(injResults.injectedPeriodDays(ind));
radii = log10(injResults.planetRadiusInEarthRadii(ind));
nBins = [40 40];
binsXDelta = (max(periods) - min(periods))/nBins(1);
binsYDelta = (max(radii) - min(radii))/nBins(2);
bins = {min(periods):binsXDelta:max(periods) min(radii):binsYDelta:max(radii)};
detProb = hist3([periods radii],bins);
detProb2 = hist3([periods(isPlanet==true & epochMatchInd) radii(isPlanet==true & epochMatchInd)],bins) ./ detProb;
[X,Y] = meshgrid(10.^bins{1},10.^bins{2});
figure
[~,h] = contourf(X,Y,detProb2');
set(h,'ShowText','on','TextStep',get(h,'LevelStep'))
xlabel('Period (days)')
ylabel('Planet Radius (Earth radii)')

periods = log10(injResults.injectedPeriodDays(ind));
radii = log10(injResults.planetRadiusInEarthRadii(ind));
nBins = [45 45];
binsXDelta = (max(periods) - min(periods))/nBins(1);
binsYDelta = (max(radii) - min(radii))/nBins(2);
bins = {min(periods):binsXDelta:max(periods) min(radii):binsYDelta:max(radii)};
detProb = hist3([periods radii],bins);
detProb2 = hist3([periods(isPlanet==true) radii(isPlanet==true)],bins) ./ detProb;
[X,Y] = meshgrid(10.^bins{1},10.^bins{2});
figure
[~,h] = contourf(X,Y,detProb2');
set(h,'ShowText','on','TextStep',get(h,'LevelStep'))
xlabel('Period (days)')
ylabel('Planet Radius (Earth radii)')


nTransits = injResults.numSesInMes(ind);
radii = log10(injResults.planetRadiusInEarthRadii(ind));
nBins = [50 50];
binsXDelta = (max(nTransits) - min(nTransits))/nBins(1);
%binsXDelta=1;
binsYDelta = (max(radii) - min(radii))/nBins(2);
bins = {min(nTransits):binsXDelta:max(nTransits) min(radii):binsYDelta:max(radii)};
detProb = hist3([nTransits radii],bins);
detProb2 = hist3([nTransits(isPlanet==true) radii(isPlanet==true)],bins) ./ detProb;
[X,Y] = meshgrid(bins{1},10.^bins{2});
figure
[~,h] = contourf(X,Y,detProb2');
set(h,'ShowText','on','TextStep',get(h,'LevelStep'))
xlabel('nTransits')
ylabel('Planet Radius (Earth radii)')

plotIndicator = generate_plot_point_indicator( bins, nTransits,radii );
nTransits = nTransits(plotIndicator);
radii = radii(plotIndicator);
% isPlanet=isPlanet(plotIndicator);

isPlanet = injResults.isPlanetACandidate(ind);
nTransits = injResults.nTransitsExpected(ind);
radii = log10(injResults.planetRadiusInEarthRadii(ind));
nBins = [45 45];
binsXDelta = (max(nTransits) - min(nTransits))/nBins(1);
%binsXDelta=1;
binsYDelta = (max(radii) - min(radii))/nBins(2);
bins = {min(nTransits):binsXDelta:max(nTransits) min(radii):binsYDelta:max(radii)};
detProb = hist3([nTransits radii],bins);
detProb2 = hist3([nTransits(isPlanet==true) radii(isPlanet==true)],bins) ./ detProb;
[X,Y] = meshgrid(bins{1},10.^bins{2});
figure
[~,h] = contourf(X,Y,detProb2');
set(h,'ShowText','on','TextStep',get(h,'LevelStep'))
xlabel('Expected nTransits')
ylabel('Planet Radius (Earth radii)')

nTransits = injResults.nTransitsExpected(ind);
%radii = log10(injResults.planetRadiusInEarthRadii(ind));
depth = injResults.injectedDepthPpm(ind);
nBins = [40 40];
binsXDelta = (max(nTransits) - min(nTransits))/nBins(1);
%binsXDelta=1;
binsYDelta = (max(depth) - min(depth))/nBins(2);
bins = {min(nTransits):binsXDelta:max(nTransits) min(depth):binsYDelta:max(depth)};
detProb = hist3([nTransits depth],bins);
detProb2 = hist3([nTransits(isPlanet==true) depth(isPlanet==true)],bins) ./ detProb;
[X,Y] = meshgrid(bins{1},bins{2});
figure
[~,h] = contourf(X,Y,detProb2');
set(h,'ShowText','on','TextStep',get(h,'LevelStep'))
xlabel('Expected nTransits')
ylabel('Injected Depth (ppm)')


% get the expected number of transits
endTime=inputsStruct.cadenceTimes.midTimestamps(end) - kjd_offset_from_mjd;
nTransitsFull = -1 * ones(length(injResults.injectedEpochKjd),1);
for i=1:length(injResults.injectedEpochKjd)
    nTransitsFull(i) = length(injResults.injectedEpochKjd(i):injResults.injectedPeriodDays(i):endTime);
end
nTransits = nTransitsFull(ind);
radii = log10(injResults.planetRadiusInEarthRadii(ind));
nBins = [50 50];
binsXDelta = (max(nTransits) - min(nTransits))/nBins(1);
%binsXDelta=1;
binsYDelta = (max(radii) - min(radii))/nBins(2);
bins = {min(nTransits):binsXDelta:max(nTransits) min(radii):binsYDelta:max(radii)};
detProb = hist3([nTransits radii],bins);
detProb2 = hist3([nTransits(isPlanet==true) radii(isPlanet==true)],bins) ./ detProb;
[X,Y] = meshgrid(bins{1},10.^bins{2});
figure
[~,h] = contourf(X,Y,detProb2');
set(h,'ShowText','on','TextStep',get(h,'LevelStep'))
xlabel('nTransits')
ylabel('Planet Radius (Earth radii)')




nSamples = 15000;
radii = sort(log10(injResults.planetRadiusInEarthRadii(ind)));
periods = sort(log10(injResults.injectedPeriodDays(ind)));
bins = {periods(1:nSamples:end) radii(1:nSamples:end)};
detProb = hist3([periods radii],bins);
detProb2 = hist3([periods(isPlanet==true) radii(isPlanet==true)],bins) ./ detProb;
[X,Y] = meshgrid(10.^bins{1},10.^bins{2});
figure
[~,h] = contourf(X,Y,detProb2');
set(h,'ShowText','on','TextStep',get(h,'LevelStep'))

% make a contour plot for detection probability vs. nTransits and Rp for 
isPlanet = injResults.isPlanetACandidate(ind);
nTransits = injResults.numSesInMes(ind);
radii = log10(injResults.planetRadiusInEarthRadii(ind));
nBins = [50 50];
binsXDelta = (max(nTransits) - min(nTransits))/nBins(1);
%binsXDelta=1;
binsYDelta = (max(radii) - min(radii))/nBins(2);
bins = {min(nTransits):binsXDelta:max(nTransits) min(radii):binsYDelta:max(radii)};
detProb = hist3([nTransits radii],bins);
detProb2 = hist3([nTransits(isPlanet==true) radii(isPlanet==true)],bins) ./ detProb;
[X,Y] = meshgrid(bins{1},bins{2});
figure
[~,h] = contourf(X,Y,detProb2');
set(h,'ShowText','on','TextStep',get(h,'LevelStep'))

% make a contour plot of the mean delta % between mes and zCompSum
ind = injResults.transitModelMatch>0.95 & ~(injResults.numSesInMes==3 & injResults.fitSinglePulse==true) & ...
    injResults.isPlanetACandidate==true;
%ind = injResults.transitModelMatch>0.95 & ~(injResults.numSesInMes==3 & injResults.fitSinglePulse==true);
nTransits = injResults.numSesInMes(ind);
periods = injResults.injectedPeriodDays(ind);
radii = log10(injResults.planetRadiusInEarthRadii(ind));
%deltaPercent = 100*(abs(injResults.maxMes(ind)-injResults.zCompSum(ind))./injResults.maxMes(ind));
deltaPercent = 100*(abs(injResults.maxMes(ind)-injResults.injectedDepthPpm(ind).*1e-6.*injResults.normSum000(ind)) ...
    ./injResults.maxMes(ind));
%deltaPercent = 100*(abs(injResults.corrSum111(ind)./injResults.normSum111(ind)-injResults.injectedDepthPpm(ind).*1e-6.*injResults.normSum111(ind)) ...
%    ./(injResults.corrSum111(ind)./injResults.normSum111(ind)));
%ind2 = ~isinf(deltaPercent) & deltaPercent < prctile(deltaPercent,99);
ind2 = deltaPercent < prctile(deltaPercent,99) & deltaPercent > prctile(deltaPercent,1);
%ind2=true(size(deltaPercent));
deltaPercent = deltaPercent(ind2);
nTransits = nTransits(ind2);
radii = radii(ind2);
periods = periods(ind2);
figure
scatter(nTransits,radii,[],deltaPercent);
xlabel('nTransits');
ylabel('log10(Rp)');
colorbar


ind = injResults.transitModelMatch>0.95 & ~(injResults.numSesInMes==3 & injResults.fitSinglePulse==true) & ...
    injResults.isPlanetACandidate==true;
mes = injResults.maxMes(ind);
mes2 = injResults.corrSum111(ind)./injResults.normSum111(ind);
mesEstimate = injResults.injectedDepthPpm(ind).*1e-6.*injResults.normSum000(ind);
mesEstimate2 = injResults.injectedDepthPpm(ind).*1e-6.*injResults.normSum111(ind);
mesDiff = mesEstimate - mes;
mes = mes(mesDiff > prctile(mesDiff,1) & mesDiff < prctile(mesDiff,99));
mesDiff = mesDiff( mesDiff > prctile(mesDiff,1) & mesDiff < prctile(mesDiff,99));
mesDiff2 = mesEstimate2 - mes2;
mes2 = mes2(mesDiff2 > prctile(mesDiff2,1) & mesDiff2 < prctile(mesDiff2,99));
mesDiff2 = mesDiff2( mesDiff2 > prctile(mesDiff2,1) & mesDiff2 < prctile(mesDiff2,99));


figure
hist(mesDiff,100)
sum(mesDiff < 0)/length(mesDiff)
sum(mesDiff>0)/length(mesDiff)
xlabel('MesEstimate - Mes')
ylabel('Counts');
title('Mes Difference Histogram (worst case): 80% are > 0')
grid on

figure
plot(mes,mesEstimate,'o') % error vectors must be same lengths
grid on
hline = refline(1,0)
set(hline,'Color','r')
xlabel('MES')
ylabel('MES Estimate')

plot(injResults.corrSum111(ind)./injResults.normSum111(ind),injResults.injectedDepthPpm(ind).*1e-6.*injResults.normSum111(ind),'o')
grid on
hline = refline(1,0)
set(hline,'Color','r')
xlabel('MES')
ylabel('MES Estimate')

ind = injResults.transitModelMatch>0.98 & ~(injResults.numSesInMes==3 & injResults.fitSinglePulse==true) & ...
    injResults.isPlanetACandidate==true;
nTransits = injResults.numSesInMes(ind);
periods = injResults.injectedPeriodDays(ind);
radii = log10(injResults.planetRadiusInEarthRadii(ind));
deltaPercent = 100*(abs(injResults.maxMes(ind)-injResults.zCompSum(ind))./injResults.maxMes(ind));
%ind2 = ~isinf(deltaPercent) & deltaPercent < prctile(deltaPercent,99);
ind2 = deltaPercent < prctile(deltaPercent,99);
%ind2=true(size(deltaPercent));
deltaPercent = deltaPercent(ind2);
nTransits = nTransits(ind2);
radii = radii(ind2);
periods = periods(ind2);
figure
scatter(periods,radii,[],deltaPercent);
xlabel('period (day)');
ylabel('log10(Rp)');
colorbar


figure
pcolor(bins{1},bins{2},detProb2)

% analyze why the detection probability is so low at short periods
load ~/externalHD/injection/ksoc-4104/contours/tps-matlab-2015043/tps-matlab-2015043-00/st-0/tps-inputs-0.mat % !!!!! file is not there
load /path/to/so-products-soc9.2/D.4-tps-contour/injection_results_992Kstars.mat
cd ~/ksoc/ksoc-4104
ind=injResults.transitModelMatch>0.95 & ~(injResults.numSesInMes==3 & injResults.fitSinglePulse==true);

% det prob vs. period
periods = injResults.injectedPeriodDays(ind);
isPlanet = injResults.isPlanetACandidate(ind);
bins = min(periods):1:max(periods);
cumProb = hist(periods(isPlanet==true),bins)./hist(periods,bins);
figure
plot(bins,cumProb,'-o')
grid on
hold on


% test an older struct
% old = load('/path/to/tps-matlab-2014104/tps-injection-struct.mat')
%!!!!! edited location of shawn's files
old = load('/path/to/injection/transitInj/tps-matlab-2014104/tps-injection-struct.mat')
old=old.injResults;
ind=old.transitModelMatch>0.95 & ~(old.numSesInMes==3 & old.fitSinglePulse==true);
isPlanet = old.isPlanetACandidate(ind);
periods = log10(old.injectedPeriodDays(ind));
radii = log10(old.planetRadiusInEarthRadii(ind));
nBins = [45 45];
binsXDelta = (max(periods) - min(periods))/nBins(1);
binsYDelta = (max(radii) - min(radii))/nBins(2);
bins = {min(periods):binsXDelta:max(periods) min(radii):binsYDelta:max(radii)};
detProb = hist3([periods radii],bins);
detProb2 = hist3([periods(isPlanet==true) radii(isPlanet==true)],bins) ;
detProb2 = detProb2 ./ detProb;
[X,Y] = meshgrid(bins{1},bins{2});
figure
[~,h] = contourf(X,Y,detProb2');
set(h,'ShowText','on','TextStep',get(h,'LevelStep'))


ind=old.transitModelMatch>0.95 & ~(old.numSesInMes==3 & old.fitSinglePulse==true);
isPlanet = old.isPlanetACandidate(ind);
nTransits = old.numSesInMes(ind);
radii = log10(old.planetRadiusInEarthRadii(ind));
nBins = [45 45];
binsXDelta = (max(nTransits) - min(nTransits))/nBins(1);
binsYDelta = (max(radii) - min(radii))/nBins(2);
bins = {min(nTransits):binsXDelta:max(nTransits) min(radii):binsYDelta:max(radii)};
detProb = hist3([nTransits radii],bins);
detProb2 = hist3([nTransits(isPlanet==true) radii(isPlanet==true)],bins) ;
detProb2 = detProb2 ./ detProb;
[X,Y] = meshgrid(bins{1},bins{2});
figure
[~,h] = contourf(X,Y,detProb2');
set(h,'ShowText','on','TextStep',get(h,'LevelStep'))

% !!!!! undefined function or variable 'chi2', 'chiGof', 'maxMes',
% but these can all be found in the tpsInjectionStruct
isPlanet=old.transitModelMatch>0.95 & ~(old.numSesInMes==3 & old.fitSinglePulse==true) & ...
    chi2>6.8 & chiGof>6.8 & old.maxMes>7.1 & old.robustStatistic>6.8 & old.corrSum000./old.normSum000 > 6.5;
isPlanet = isPlanet(ind);
ind=old.transitModelMatch>0.95 & ~(old.numSesInMes==3 & old.fitSinglePulse==true) & ...
    old.maxMes>old.bootstrapThreshold;

% det prob vs. period
periods = log10(old.injectedPeriodDays(ind));
isPlanet = old.isPlanetACandidate(ind);
bins = min(periods):0.01:max(periods);
cumProb = hist(periods(isPlanet==true),bins)./hist(periods,bins);
figure
plot(bins,cumProb,'-o')
grid on
hold on

% stitch two structs together
fieldNames = fieldnames(tpsInjectionStruct);
for i=2:length(fieldNames)-1
    injResults.(fieldNames{i}) = [injResults.(fieldNames{i});tpsInjectionStruct.(fieldNames{i})];
end

epochMatchInd = abs(injResults.injectedEpochKjd - injResults.epochKjd)*48.939 < injResults.injectedDurationInHours *48.939 / 2 / 24 ;
ind = injResults.numSesInMes>2 & ~(injResults.numSesInMes==3 & injResults.fitSinglePulse==true);
isPlanet = injResults.isPlanetACandidate(ind);
epochMatchInd = epochMatchInd(ind);
depth = log10(injResults.injectedDepthPpm(ind));
mes = injResults.injectedDepthPpm(ind) .* 1e-6 .* injResults.normSum000(ind);
nBins = [50 50];
binsXDelta = (max(mes) - min(mes))/nBins(1);
%binsXDelta=1;
binsYDelta = (max(depth) - min(depth))/nBins(2);
bins = {3:0.2:18 1:0.04:3};
detProb = hist3([mes depth],bins);
detProb2 = hist3([mes(isPlanet==true & epochMatchInd) depth(isPlanet==true & epochMatchInd)],bins) ./ detProb;
[X,Y] = meshgrid(bins{1},bins{2});
figure
[~,h] = contourf(X,Y,detProb2');
set(h,'ShowText','on','TextStep',get(h,'LevelStep'))

% !!!!! injResultsNew is not defined
epochMatchInd = abs(injResultsNew.injectedEpochKjd - injResultsNew.epochKjd)*48.939 < injResultsNew.injectedDurationInHours *48.939 / 2 / 24 ;
ind = injResultsNew.numSesInMes>2 & ~(injResultsNew.numSesInMes==3 & injResultsNew.fitSinglePulse==true);
isPlanet = injResultsNew.isPlanetACandidate(ind);
epochMatchInd = epochMatchInd(ind);
depth = log10(injResultsNew.injectedDepthPpm(ind));
mes = injResultsNew.injectedDepthPpm(ind) .* 1e-6 .* injResultsNew.normSum000(ind);
nBins = [50 50];
binsXDelta = (max(mes) - min(mes))/nBins(1);
%binsXDelta=1;
binsYDelta = (max(depth) - min(depth))/nBins(2);
bins = {3:0.2:18 1:0.04:3};
detProb = hist3([mes depth],bins);
detProb2 = hist3([mes(isPlanet==true & epochMatchInd) depth(isPlanet==true & epochMatchInd)],bins) ./ detProb;
[X,Y] = meshgrid(bins{1},bins{2});
figure
[C,h] = contourf(X,Y,detProb2');
set(h,'ShowText','on','TextStep',get(h,'LevelStep'))

% plot the 1D detection probability curves - first just require that the
% depth is not zero
%ind = ~(injResults.numSesInMes==3 & injResults.fitSinglePulse==true) & injResults.numSesInMes>2 & injResults.normSum000~=-1;
% abs(injResults.injectedEpochKjd - injResults.epochKjd)*48.939 < 3 &
epochMatchInd = abs(injResults.injectedEpochKjd - injResults.epochKjd)*48.939 < injResults.injectedDurationInHours *48.939 / 2 / 24 ;
ind = injResults.numSesInMes>2 & ~(injResults.numSesInMes==3 & injResults.fitSinglePulse==true);
%kepids=uniqueId(~ismember(skyGroups,[18 26 58 66 41 42 43 44 62 38 46 22]));
%mesBins = 0:0.1:500;
mesBins=0:.1:50;
%ind = injResults.injectedDepthPpm ~=0 & injResults.normSum000>0 & injResults.corrSum000 > 0 & injResults.planetRadiusInEarthRadii > 0.5 & ...
%    injResults.planetRadiusInEarthRadii < 10 & ismember(injResults.keplerId,kepids);
mes = injResults.injectedDepthPpm .* 1e-6 .* injResults.normSum111 .* injResults.transitModelMatch;
%mes = injResults.injectedDepthPpm;
chi2 = injResults.maxMes./sqrt(injResults.chiSquare2./injResults.chiSquareDof2);
chigof = injResults.maxMes./sqrt(injResults.chiSquareGof./injResults.chiSquareGofDof);
%mes = injResults.maxMes;
%mes = injResults.corrSum000./injResults.normSum000;
%detectionInd = injResults.isPlanetACandidate==1 & ind & epochMatchInd;
%missedInd = (injResults.isPlanetACandidate==0 & ind) | (injResults.isPlanetACandidate==1 & ind & ~epochMatchInd);
detectionInd = injResults.maxMes > 7.1 & ind & epochMatchInd;
missedInd = injResults.maxMes<7.1 & ind;
mesMissed = mes(missedInd );
mesDetected = mes(detectionInd);
nMissed = histc(mesMissed,mesBins);
nDetected = histc(mesDetected,mesBins);
nMissed = nMissed(1:end-1);
nDetected = nDetected(1:end-1);
figure
plot(mesBins(1:end-1),nDetected./(nDetected+nMissed),'-o')
hold on
plot(mesBins,cdf('norm',mesBins,7.1,1),'-*r')
vline(7.1)
grid on
xlabel('Expected MES')
ylabel('Detection Probability')

% !!!!! injResultsNew is not defined
epochMatchInd = abs(injResultsNew.injectedEpochKjd - injResultsNew.epochKjd)*48.939 < injResultsNew.injectedDurationInHours *48.939 / 2 / 24 ;
ind = injResultsNew.numSesInMes>2 & ~(injResultsNew.numSesInMes==3 & injResultsNew.fitSinglePulse==true);
%kepids=uniqueId(~ismember(skyGroups,[18 26 58 66 41 42 43 44 62 38 46 22]));
%mesBins = 0:0.1:500;
mesBins=0:0.1:50;
%ind = injResultsNew.injectedDepthPpm ~=0 & injResultsNew.normSum000>0 & injResultsNew.corrSum000 > 0 & injResultsNew.planetRadiusInEarthRadii > 0.5 & ...
%    injResultsNew.planetRadiusInEarthRadii < 10 & ismember(injResultsNew.keplerId,kepids);
mes = injResultsNew.injectedDepthPpm .* 1e-6 .* injResultsNew.normSum111 .* injResultsNew.transitModelMatch;
%mes = injResultsNew.injectedDepthPpm;
chi2 = injResultsNew.maxMes./sqrt(injResultsNew.chiSquare2./injResultsNew.chiSquareDof2);
chigof = injResultsNew.maxMes./sqrt(injResultsNew.chiSquareGof./injResultsNew.chiSquareGofDof);
%mes = injResultsNew.maxMes;
%mes = injResultsNew.corrSum000./injResultsNew.normSum000;
%detectionInd = injResultsNew.isPlanetACandidate==1 & ind & epochMatchInd;
detectionInd = injResultsNew.maxMes>7.1 & epochMatchInd & ind;
missedInd = injResultsNew.maxMes<7.1 & ind;
%missedInd = (injResultsNew.isPlanetACandidate==0 & ind) | (injResultsNew.isPlanetACandidate==1 & ind & ~epochMatchInd);
%detectionInd = injResultsNew.maxMes > 7.1 & ind & epochMatchInd;
mesMissed = mes(missedInd );
mesDetected = mes(detectionInd);
nMissed = histc(mesMissed,mesBins);
nDetected = histc(mesDetected,mesBins);
nMissed = nMissed(1:end-1);
nDetected = nDetected(1:end-1);
figure
plot(mesBins(1:end-1),nDetected./(nDetected+nMissed),'-o')
hold on
plot(mesBins,cdf('norm',mesBins,7.1,1),'-*r')
vline(7.1)
grid on
xlabel('Expected MES')
ylabel('Detection Probability')



% generate a contour for each target then average them together
% !!!!! This takes a long time (hours)
mesBins = 0:0.1:50;

% !!!!! added the following line in order to define uniqueId-- jcat
uniqueId = tpsInjectionStruct.keplerId;
nMissed = -1 * ones(length(uniqueId),500);
nDetected = -1 * ones(length(uniqueId),500);
for i=1:length(uniqueId)
    kepids=uniqueId(i);
    ind = injResults.injectedDepthPpm ~=0 & ~(injResults.numSesInMes==3 & injResults.fitSinglePulse==true) & ...
        ismember(injResults.keplerId,kepids) & injResults.numSesInMes>3 & injResults.periodDays<280 & injResults.periodDays>160;
    epochMatchInd = abs(injResults.injectedEpochKjd - injResults.epochKjd)*48.939 < injResults.injectedDurationInHours *48.939 / 2 / 24 ;
    mes = injResults.injectedDepthPpm .* 1e-6 .* injResults.normSum000;
    %mes = injResults.maxMes;
    mesMissed = mes(injResults.isPlanetACandidate==0 & ind);
    mesDetected = mes(injResults.isPlanetACandidate==1 & ind );
    nMissedTemp = histc(mesMissed,mesBins);
    nDetectedTemp = histc(mesDetected,mesBins);
    nMissed(i,:) = nMissedTemp(1:end-1);
    nDetected(i,:) = nDetectedTemp(1:end-1);
end
figure
plot(mesBins(1:end-1),nDetected./(nDetected+nMissed),'-o')
grid on
hold on
plot(mesBins,cdf('norm',mesBins,7.1,1),'-*r')
vline(7.1)
grid on
xlabel('Expected MES')
ylabel('Detection Probability')

legend('Pseudo 9.3 - Kepler22 - T in [10,40] days','Pseudo 9.3 - Kepler22 - T in [40,160] days','Pseudo 9.3 - Kepler22 - T in [160,280] days', ...
    'Pseudo 9.3 - KIC 6775689 - T in [10,40] days','Pseudo 9.3 - KIC 6775689 - T in [40,160] days','Pseudo 9.3 - KIC 6775689 - T in [160,280],days', ...
    '9.2 - KIC 6775689 - T in [10,40] days','9.2 - KIC 6775689 - T in [40,160] days','9.2 - KIC 6775689 - T in [160,280],days','Expected');

% average them together
nDetectedSmall = mean(nDetected)';
nMissedSmall = mean(nMissed)';
figure
plot(mesBins(1:end-1),nDetectedSmall./(nDetectedSmall+nMissedSmall),'-o')
hold on
plot(mesBins,cdf('norm',mesBins,7.1,1),'-*r')
vline(7.1)
grid on
xlabel('Expected MES')
ylabel('Detection Probability')


infoArray = zeros(992,3);
prev=0;
k=0;
kk=0;
for i=1:3632242
    temp=injResults.keplerId(i);
    if temp~=prev 
        kk=kk+1;
        prev = temp;
        if ~any(ismember(infoArray(:,1),temp))
            k=k+1;
            infoArray(k,1)=temp;
            infoArray(k,2)=injResults.dataSpanInCadences(kk);
            infoArray(k,3)=injResults.dutyCycle(kk);
        end
    end
end

        
detRates = zeros(length(uniqueId),1);
for i=1:length(uniqueId)
    detRates(i) = sum(injResults.isPlanetACandidate(ismember(injResults.keplerId,uniqueId(i)))==true)/sum(ismember(injResults.keplerId,uniqueId(i)));
end


% check response of chi2 - note that in 9.2 the dofs were whole numbers
nTransitsBins = 3:max(injResults.numSesInMes);
epochMatchInd = abs(injResults.injectedEpochKjd - injResults.epochKjd)*48.939 < injResults.injectedDurationInHours *48.939 / 2 / 24 ;
ind = injResults.numSesInMes>2 & ~(injResults.numSesInMes==3 & injResults.fitSinglePulse==true);
chi = injResults.maxMes./sqrt(injResults.chiSquare2./(injResults.chiSquareDof2 - ...
    0.08434239.*injResults.zCompSum.^2 + epsilon2.*(2-epsilon2)./((1-epsilon2).^2).*injResults.zCompSum.^2));
%chi = injResults.maxMes./sqrt(injResults.chiSquare2./(injResults.chiSquareDof2 - 0.084151.*injResults.zCompSum.^2));
%chi = injResults.maxMes./sqrt(injResults.chiSquareGof./injResults.chiSquareGofDof);
detectionInd = injResults.maxMes>7.1 & injResults.robustStatistic>6.8 & ind & epochMatchInd & chi>6.8;
missedInd = injResults.maxMes>7.1 & injResults.robustStatistic>6.8 & ind & epochMatchInd & chi<6.8;
%detectionInd = injResults.maxMes>7.1 & injResults.robustStatistic>6.8 & ...
%    injResults.thresholdForDesiredPfa<injResults.maxMes & ind & epochMatchInd;
%missedInd = injResults.maxMes>7.1 & injResults.robustStatistic<6.8 & ...
%    injResults.thresholdForDesiredPfa<injResults.maxMes & ind & epochMatchInd;
nTransits = injResults.numSesInMes;
nMissed = nTransits(missedInd);
nDetected = nTransits(detectionInd);
nnMissed = histc(nMissed,nTransitsBins);
nnDetected = histc(nDetected,nTransitsBins);
nnMissed = nnMissed(1:end-1);
nnDetected = nnDetected(1:end-1);
figure
plot(nTransitsBins(1:end-1),nnDetected./(nnDetected+nnMissed),'-o')
grid on
xlabel('nTransits')
ylabel('Detection Probability')


ind = injResults.fitSinglePulse==1 | injResults.numSesInMes<3;
ind = ~ind;
ind2 = ind & injResults.normSum111 ~=-1 & injResults.transitModelMatch ~= -1 ...
    & injResults.normSum000 ~= -1 & injResults.normSum001 ~= -1 ...
    & injResults.normSum010 ~= -1 & injResults.normSum011 ~= -1 ...
    & injResults.normSum100 ~= -1 & injResults.normSum101 ~= -1 ...
    & injResults.normSum110 ~= -1;
%vetoInd=ind2 & abs(injResults.injectedEpochKjd-injResults.epochKjd)<3/48.939 & injResults.maxMes>=7.1 & injResults.maxMes>injResults.bootstrapThreshold ;
%vetoInd=ind2 & abs(injResults.injectedEpochKjd-injResults.epochKjd)<3/48.939 & injResults.maxMes>=7.1 & injResults.maxMes>injResults.bootstrapThreshold & injResults.robustStatistic>6.4 ;
vetoInd=ind2 & abs(injResults.injectedEpochKjd-injResults.epochKjd)<1/48.939 & injResults.maxMes>=7.1 & injResults.maxMes>injResults.thresholdForDesiredPfa & injResults.robustStatistic>6.4 ;

nSes = injResults.numSesInMes;
chi2 = injResults.zCompSum./sqrt(injResults.chiSquare2./injResults.chiSquareDof2);
chiGof = injResults.zCompSum./sqrt(injResults.chiSquareGof./injResults.chiSquareGofDof);

temp=hist(nSes(vetoInd),3:146);
temp2=hist(nSes(vetoInd & chiGof<7.5),3:146);
figure
plot((3:146)',100*temp2./temp,'-o')
hold on
temp3=hist(nSes(vetoInd & chi2<7),3:146);
plot((3:146)',100*temp3./temp,'-go')
grid on


uniqueId=zeros(length(injResults.dutyCycle),1);
tempId=0;
counter = 0;
for i=1:length(injResults.keplerId)
    if ~(injResults.keplerId(i)==tempId)
        counter = counter + 1;
        uniqueId(counter) = injResults.keplerId(i);
        tempId = injResults.keplerId(i);
    end
end

 % generate a contour for each target then average them together
mesBins = 0:0.1:50;
ind=injResults.injectedPeriodDays<200 & injResults.planetRadiusInEarthRadii<1.5 ;
nMissed = -1 * ones(500,1);
nDetected = -1 * ones(500,1);

mes = injResults.injectedDepthPpm .* 1e-6 .* injResults.normSum000;
%mes = injResults.maxMes;
mesMissed = mes(injResults.isPlanetACandidate==0 & ind);
mesDetected = mes(injResults.isPlanetACandidate==1 & ind);
nMissedTemp = histc(mesMissed,mesBins);
nDetectedTemp = histc(mesDetected,mesBins);
nMissed = nMissedTemp(1:end-1);
nDetected = nDetectedTemp(1:end-1);

figure
plot(mesBins(1:end-1),nDetected./(nDetected+nMissed),'-o')
hold on
plot(mesBins,cdf('norm',mesBins,7.1,1),'-*r')
vline(7.1)
grid on
xlabel('Expected MES')
ylabel('Detection Probability')       



load ~/externalHD/injection/ksoc-4686/injection/tps-matlab-2015135_Kepler22/tps-injection-struct.mat
injResults=tpsInjectionStruct;
uniqueId=unique(injResults.keplerId);
mesBins = 0:0.1:50;
nMissed = -1 * ones(length(uniqueId),500);
nDetected = -1 * ones(length(uniqueId),500);
for i=1:length(uniqueId)
kepids=uniqueId(i);
ind = injResults.injectedDepthPpm ~=0 & ~(injResults.numSesInMes==3 & injResults.fitSinglePulse==true) & ...
ismember(injResults.keplerId,kepids) & injResults.numSesInMes>3 & injResults.periodDays<40 & injResults.periodDays>10;
epochMatchInd = abs(injResults.injectedEpochKjd - injResults.epochKjd)*48.939 < injResults.injectedDurationInHours *48.939 / 2 / 24 ;
mes = injResults.injectedDepthPpm .* 1e-6 .* injResults.normSum000;
%mes = injResults.maxMes;
mesMissed = mes(injResults.isPlanetACandidate==0 & ind);
mesDetected = mes(injResults.isPlanetACandidate==1 & ind );
nMissedTemp = histc(mesMissed,mesBins);
nDetectedTemp = histc(mesDetected,mesBins);
nMissed(i,:) = nMissedTemp(1:end-1);
nDetected(i,:) = nDetectedTemp(1:end-1);
end
figure
plot(mesBins(1:end-1),nDetected./(nDetected+nMissed),'-go')
grid on
hold on
mesBins = 0:0.1:50;
nMissed = -1 * ones(length(uniqueId),500);
nDetected = -1 * ones(length(uniqueId),500);
for i=1:length(uniqueId)
kepids=uniqueId(i);
ind = injResults.injectedDepthPpm ~=0 & ~(injResults.numSesInMes==3 & injResults.fitSinglePulse==true) & ...
ismember(injResults.keplerId,kepids) & injResults.numSesInMes>3 & injResults.periodDays<160 & injResults.periodDays>40;
epochMatchInd = abs(injResults.injectedEpochKjd - injResults.epochKjd)*48.939 < injResults.injectedDurationInHours *48.939 / 2 / 24 ;
mes = injResults.injectedDepthPpm .* 1e-6 .* injResults.normSum000;
%mes = injResults.maxMes;
mesMissed = mes(injResults.isPlanetACandidate==0 & ind);
mesDetected = mes(injResults.isPlanetACandidate==1 & ind );
nMissedTemp = histc(mesMissed,mesBins);
nDetectedTemp = histc(mesDetected,mesBins);
nMissed(i,:) = nMissedTemp(1:end-1);
nDetected(i,:) = nDetectedTemp(1:end-1);
end
plot(mesBins(1:end-1),nDetected./(nDetected+nMissed),'-g+')
mesBins = 0:0.1:50;
nMissed = -1 * ones(length(uniqueId),500);
nDetected = -1 * ones(length(uniqueId),500);
for i=1:length(uniqueId)
kepids=uniqueId(i);
ind = injResults.injectedDepthPpm ~=0 & ~(injResults.numSesInMes==3 & injResults.fitSinglePulse==true) & ...
ismember(injResults.keplerId,kepids) & injResults.numSesInMes>3 & injResults.periodDays<280 & injResults.periodDays>160;
epochMatchInd = abs(injResults.injectedEpochKjd - injResults.epochKjd)*48.939 < injResults.injectedDurationInHours *48.939 / 2 / 24 ;
mes = injResults.injectedDepthPpm .* 1e-6 .* injResults.normSum000;
%mes = injResults.maxMes;
mesMissed = mes(injResults.isPlanetACandidate==0 & ind);
mesDetected = mes(injResults.isPlanetACandidate==1 & ind );
nMissedTemp = histc(mesMissed,mesBins);
nDetectedTemp = histc(mesDetected,mesBins);
nMissed(i,:) = nMissedTemp(1:end-1);
nDetected(i,:) = nDetectedTemp(1:end-1);
end
plot(mesBins(1:end-1),nDetected./(nDetected+nMissed),'-gd')
load ~/externalHD/injection/ksoc-4686/injection/tps-matlab-2015133_SingleTarget/tps-injection-struct.mat
injResults=tpsInjectionStruct;
uniqueId=unique(injResults.keplerId);
mesBins = 0:0.1:50;
nMissed = -1 * ones(length(uniqueId),500);
nDetected = -1 * ones(length(uniqueId),500);
for i=1:length(uniqueId)
kepids=uniqueId(i);
ind = injResults.injectedDepthPpm ~=0 & ~(injResults.numSesInMes==3 & injResults.fitSinglePulse==true) & ...
ismember(injResults.keplerId,kepids) & injResults.numSesInMes>3 & injResults.periodDays<40 & injResults.periodDays>10;
epochMatchInd = abs(injResults.injectedEpochKjd - injResults.epochKjd)*48.939 < injResults.injectedDurationInHours *48.939 / 2 / 24 ;
mes = injResults.injectedDepthPpm .* 1e-6 .* injResults.normSum000;
%mes = injResults.maxMes;
mesMissed = mes(injResults.isPlanetACandidate==0 & ind);
mesDetected = mes(injResults.isPlanetACandidate==1 & ind );
nMissedTemp = histc(mesMissed,mesBins);
nDetectedTemp = histc(mesDetected,mesBins);
nMissed(i,:) = nMissedTemp(1:end-1);
nDetected(i,:) = nDetectedTemp(1:end-1);
end
plot(mesBins(1:end-1),nDetected./(nDetected+nMissed),'-o')
mesBins = 0:0.1:50;
nMissed = -1 * ones(length(uniqueId),500);
nDetected = -1 * ones(length(uniqueId),500);
for i=1:length(uniqueId)
kepids=uniqueId(i);
ind = injResults.injectedDepthPpm ~=0 & ~(injResults.numSesInMes==3 & injResults.fitSinglePulse==true) & ...
ismember(injResults.keplerId,kepids) & injResults.numSesInMes>3 & injResults.periodDays<160 & injResults.periodDays>40;
epochMatchInd = abs(injResults.injectedEpochKjd - injResults.epochKjd)*48.939 < injResults.injectedDurationInHours *48.939 / 2 / 24 ;
mes = injResults.injectedDepthPpm .* 1e-6 .* injResults.normSum000;
%mes = injResults.maxMes;
mesMissed = mes(injResults.isPlanetACandidate==0 & ind);
mesDetected = mes(injResults.isPlanetACandidate==1 & ind );
nMissedTemp = histc(mesMissed,mesBins);
nDetectedTemp = histc(mesDetected,mesBins);
nMissed(i,:) = nMissedTemp(1:end-1);
nDetected(i,:) = nDetectedTemp(1:end-1);
end
plot(mesBins(1:end-1),nDetected./(nDetected+nMissed),'-+')
mesBins = 0:0.1:50;
nMissed = -1 * ones(length(uniqueId),500);
nDetected = -1 * ones(length(uniqueId),500);
for i=1:length(uniqueId)
kepids=uniqueId(i);
ind = injResults.injectedDepthPpm ~=0 & ~(injResults.numSesInMes==3 & injResults.fitSinglePulse==true) & ...
ismember(injResults.keplerId,kepids) & injResults.numSesInMes>3 & injResults.periodDays<280 & injResults.periodDays>160;
epochMatchInd = abs(injResults.injectedEpochKjd - injResults.epochKjd)*48.939 < injResults.injectedDurationInHours *48.939 / 2 / 24 ;
mes = injResults.injectedDepthPpm .* 1e-6 .* injResults.normSum000;
%mes = injResults.maxMes;
mesMissed = mes(injResults.isPlanetACandidate==0 & ind);
mesDetected = mes(injResults.isPlanetACandidate==1 & ind );
nMissedTemp = histc(mesMissed,mesBins);
nDetectedTemp = histc(mesDetected,mesBins);
nMissed(i,:) = nMissedTemp(1:end-1);
nDetected(i,:) = nDetectedTemp(1:end-1);
end
plot(mesBins(1:end-1),nDetected./(nDetected+nMissed),'-d')
injResults=injResultsTemp;
uniqueId=6775689;
mesBins = 0:0.1:50;
nMissed = -1 * ones(length(uniqueId),500);
nDetected = -1 * ones(length(uniqueId),500);
for i=1:length(uniqueId)
kepids=uniqueId(i);
ind = injResults.injectedDepthPpm ~=0 & ~(injResults.numSesInMes==3 & injResults.fitSinglePulse==true) & ...
ismember(injResults.keplerId,kepids) & injResults.numSesInMes>3 & injResults.periodDays<40 & injResults.periodDays>10;
epochMatchInd = abs(injResults.injectedEpochKjd - injResults.epochKjd)*48.939 < injResults.injectedDurationInHours *48.939 / 2 / 24 ;
mes = injResults.injectedDepthPpm .* 1e-6 .* injResults.normSum000;
%mes = injResults.maxMes;
mesMissed = mes(injResults.isPlanetACandidate==0 & ind);
mesDetected = mes(injResults.isPlanetACandidate==1 & ind );
nMissedTemp = histc(mesMissed,mesBins);
nDetectedTemp = histc(mesDetected,mesBins);
nMissed(i,:) = nMissedTemp(1:end-1);
nDetected(i,:) = nDetectedTemp(1:end-1);
end
plot(mesBins(1:end-1),nDetected./(nDetected+nMissed),'-ro')
mesBins = 0:0.1:50;
nMissed = -1 * ones(length(uniqueId),500);
nDetected = -1 * ones(length(uniqueId),500);
for i=1:length(uniqueId)
kepids=uniqueId(i);
ind = injResults.injectedDepthPpm ~=0 & ~(injResults.numSesInMes==3 & injResults.fitSinglePulse==true) & ...
ismember(injResults.keplerId,kepids) & injResults.numSesInMes>3 & injResults.periodDays<160 & injResults.periodDays>40;
epochMatchInd = abs(injResults.injectedEpochKjd - injResults.epochKjd)*48.939 < injResults.injectedDurationInHours *48.939 / 2 / 24 ;
mes = injResults.injectedDepthPpm .* 1e-6 .* injResults.normSum000;
%mes = injResults.maxMes;
mesMissed = mes(injResults.isPlanetACandidate==0 & ind);
mesDetected = mes(injResults.isPlanetACandidate==1 & ind );
nMissedTemp = histc(mesMissed,mesBins);
nDetectedTemp = histc(mesDetected,mesBins);
nMissed(i,:) = nMissedTemp(1:end-1);
nDetected(i,:) = nDetectedTemp(1:end-1);
end
plot(mesBins(1:end-1),nDetected./(nDetected+nMissed),'-r+')
mesBins = 0:0.1:50;
nMissed = -1 * ones(length(uniqueId),500);
nDetected = -1 * ones(length(uniqueId),500);
for i=1:length(uniqueId)
kepids=uniqueId(i);
ind = injResults.injectedDepthPpm ~=0 & ~(injResults.numSesInMes==3 & injResults.fitSinglePulse==true) & ...
ismember(injResults.keplerId,kepids) & injResults.numSesInMes>3 & injResults.periodDays<280 & injResults.periodDays>160;
epochMatchInd = abs(injResults.injectedEpochKjd - injResults.epochKjd)*48.939 < injResults.injectedDurationInHours *48.939 / 2 / 24 ;
mes = injResults.injectedDepthPpm .* 1e-6 .* injResults.normSum000;
%mes = injResults.maxMes;
mesMissed = mes(injResults.isPlanetACandidate==0 & ind);
mesDetected = mes(injResults.isPlanetACandidate==1 & ind );
nMissedTemp = histc(mesMissed,mesBins);
nDetectedTemp = histc(mesDetected,mesBins);
nMissed(i,:) = nMissedTemp(1:end-1);
nDetected(i,:) = nDetectedTemp(1:end-1);
end
plot(mesBins(1:end-1),nDetected./(nDetected+nMissed),'-rd')
plot(mesBins,cdf('norm',mesBins,7.1,1),'-*k')
vline(7.1)
grid on
xlabel('Expected MES')
ylabel('Detection Probability')
legend('Pseudo 9.3 - Kepler22 - T in [10,40] days','Pseudo 9.3 - Kepler22 - T in [40,160] days','Pseudo 9.3 - Kepler22 - T in [160,280] days', ...
'Pseudo 9.3 - KIC 6775689 - T in [10,40] days','Pseudo 9.3 - KIC 6775689 - T in [40,160] days','Pseudo 9.3 - KIC 6775689 - T in [160,280],days', ...
'9.2 - KIC 6775689 - T in [10,40] days','9.2 - KIC 6775689 - T in [40,160] days','9.2 - KIC 6775689 - T in [160,280],days','Expected');

