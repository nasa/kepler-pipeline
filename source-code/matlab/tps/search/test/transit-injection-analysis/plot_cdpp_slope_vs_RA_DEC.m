% plot_cdpp_slope_vs_RA_DEC.m
% Investigate dependence of cdpp slope and other stellar parameters on stellar position (RA, DEC)
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
clear

% Note from Chris:
% use rmsCdpp2 -- which is from DV
% use dataSpans1 and dutyCycles1 -- from TPS

% Base directory for scripts
baseDir = '/path/to/matlab/tps/search/test/transit-injection-analysis/';

% Directory for saving plots
plotDir = '/codesaver/work/transit_injection/catalogs/';

% Load the completeStructArray with stellar parameters created by Chris Burke in KSO-416
load('/path/to/so-products-DR25/Complete_Seed_DR25_04-05-2016.mat');

% Catalog directory -- save results here
catalogDir = '/codesaver/work/transit_injection/catalogs/';

% Option to save cdpp_slope catalog
saveCdppSlopeCatalog = true;

% pulseDurations: 8th pulse duration is 6 hours
pulseDurationsHours = [1.5, 2.0, 2.5, 3.0, 3.5, 4.5 , 5.0, 6.0, 7.5, 9.0, 10.5, 12.0, 12.5, 15.0];
pulseIndex = 8;

% 1x198702 struct array with fields:
%    keplerId
%    kpmag
%    rstar
%    teff
%    logg
%    validKic

%    newrstar
%    newteff
%    newlogg
%    newValidKic

%    new2rstar
%    new2teff
%    new2logg
%    new2ValidKic

%    From latest DR25 catalog
%    new3rstar
%    new3teff
%    new3logg
%    new3ValidKic
%    new3ra
%    new3dec

%    fullgapped

%    These are from TPS
%    maxMess1
%    pulseNotSearched1
%    rmsCdpps1
%    exitFlag1
%    dataSpans1
%    dutyCycles1
%    cleanSearch1
%    hasTCE
%    tceIds

%    From DV
%    dvstatus: 0, did not go to DV, 1 went to DV but didn't complete; 2 completed DV
%    maxMess2
%    pulseNotSearched2
%    rmsCdpps2
%    exitFlag2
%    dataSpans2
%    dutyCycles2
%    cleanSearch2

% Get RA and DEC, other stellar parameters
RA = [completeStructArray.new3ra]';
DEC = [completeStructArray.new3dec]';
new3rstar = [completeStructArray.new3rstar]';
new3teff = [completeStructArray.new3teff]';
new3logg = [completeStructArray.new3logg]';
new3ValidKic = [completeStructArray.new3ValidKic]';
kpmag = [completeStructArray.kpmag]';
keplerId = [completeStructArray.keplerId]';
% dataSpans = [completeStructArray.dataSpans1]';
% dutyCycles = [completeStructArray.dutyCycles1]';


% Get RMS CDPP, dutyCycle and dataSpan for the 14 pulse durations
nTargets = length(completeStructArray);
nPulseDurations = length(completeStructArray(1).rmsCdpps2);
rmsCdpp2 = zeros(nTargets,nPulseDurations);
rmsCdpp1 = zeros(nTargets,nPulseDurations);
dataSpans = zeros(nTargets,nPulseDurations);
dutyCycles = zeros(nTargets,nPulseDurations);
for iTarget = 1:nTargets
    rmsCdpp2(iTarget,:) = [completeStructArray(iTarget).rmsCdpps2];
    rmsCdpp1(iTarget,:) = [completeStructArray(iTarget).rmsCdpps1];
    dataSpans(iTarget,:) = [completeStructArray(iTarget).dataSpans1];
    dutyCycles(iTarget,:) = [completeStructArray(iTarget).dutyCycles1];
end


% Get cdpp slope: takes ~150 sec
tic
% Modified: uses ordinary least squares instead of robust least squares
cdppSlope = get_cdpp_slope(rmsCdpp2,rmsCdpp1);
toc

% Check
validRmsCdpp = false(size(keplerId));
for iTarget = 1:nTargets
    validRmsCdpp(iTarget,1) = isreal(cdppSlope(iTarget,1));
end

% Histogram of cdpp slopes
edges = (-1:0.05:0.8);
NN=histc(cdppSlope,edges);
figure
box on
grid on
hold on
bar(edges,NN)
xlabel('CDPP slope')
ylabel('Counts')
title(['CDPP slope for all ',num2str(nTargets),' Kepler targets'])
legend(['Median = ',num2str(median(cdppSlope),'%6.2f')])
set(gca,'FontSize',12)
set(findall(gcf,'type','text'),'FontSize',12)
axis([-1,1,0,inf])
plotName = strcat(catalogDir,'cdpp_slope_histogram');
print('-dpng','-r150',plotName)

% Cumulative Histogram of cdpp slopes
binCenters = (edges(1:end-1)+edges(2:end))/2;
figure
box on
grid on
hold on
bar(binCenters,cumsum(NN(1:end-1))./max(cumsum(NN(1:end-1))))
xlabel('CDPP slope')
ylabel('Fraction with CDPP slope < x')
title(['Cumulative CDF of CDPP slope for ',num2str(nTargets),' Kepler target stars'])
set(gca,'FontSize',12)
set(findall(gcf,'type','text'),'FontSize',12)
plotName = strcat(catalogDir,'cdpp_slope_cdf');
print('-dpng','-r150',plotName)

% Option to save catalog of cdpp slopes
if(saveCdppSlopeCatalog)
    
    % Save as matfile in catalog dir
    save(strcat(catalogDir,'keplerId_vs_cdppSlope.mat'),'keplerId','cdppSlope')
    return
    
end


% Map of cdppSlope vs focal plane location 
figure
box on
grid on
hold on
scatter(RA(validRmsCdpp),DEC(validRmsCdpp),[],cdppSlope(validRmsCdpp),'.')
% scatter(RA,DEC,[],cdppSlope,'.')
% caxis([-.5,0])
xlabel('RA [degrees]')
ylabel('DEC [degrees]')
title(['CDPP slope (from last 6 pulse durations of rmsCdpps2) vs focal plane location for ',num2str(nTargets),' Kepler DR25 targets'])
t = colorbar('peer',gca);
set(get(t,'ylabel'),'String', 'cdppSlope');
set(gca,'FontSize',12)
set(findall(gcf,'type','text'),'FontSize',12)
plotName = strcat(plotDir,'cdppSlope_vs_position');
print('-dpng','-r150',plotName)

% Map of rstar vs focal plane location 
figure
box on
grid on
hold on
scatter(RA(validRmsCdpp),DEC(validRmsCdpp),[],new3rstar(validRmsCdpp),'.')
caxis([0.25,1.5])
xlabel('RA [degrees]')
ylabel('DEC [degrees]')
title(['new3rstar vs focal plane location for ',num2str(nTargets),' Kepler DR25 targets'])
t = colorbar('peer',gca);
set(get(t,'ylabel'),'String', 'rstar [solar radii]');
set(gca,'FontSize',12)
set(findall(gcf,'type','text'),'FontSize',12)
plotName = strcat(plotDir,'rstar_vs_position');
print('-dpng','-r150',plotName)

% Map of teff vs focal plane location 
figure
box on
grid on
hold on
scatter(RA(validRmsCdpp),DEC(validRmsCdpp),[],new3teff(validRmsCdpp),'.')
caxis([2500,7500])
xlabel('RA [degrees]')
ylabel('DEC [degrees]')
title(['new3teff vs focal plane location for ',num2str(nTargets),' Kepler DR25 targets'])
t = colorbar('peer',gca);
set(get(t,'ylabel'),'String', 'teff [K]');
set(gca,'FontSize',12)
set(findall(gcf,'type','text'),'FontSize',12)
plotName = strcat(plotDir,'teff_vs_position');
print('-dpng','-r150',plotName)

% Map of logg vs focal plane location 
figure
box on
grid on
hold on
scatter(RA(validRmsCdpp),DEC(validRmsCdpp),[],new3logg(validRmsCdpp),'.')
caxis([3,5])
xlabel('RA [degrees]')
ylabel('DEC [degrees]')
title(['new3logg vs focal plane location for ',num2str(nTargets),' Kepler DR25 targets'])
t = colorbar('peer',gca);
set(get(t,'ylabel'),'String', 'logg');
set(gca,'FontSize',12)
set(findall(gcf,'type','text'),'FontSize',12)
plotName = strcat(plotDir,'logg_vs_position');
print('-dpng','-r150',plotName)

% Map of kpmag vs focal plane location 
figure
box on
grid on
hold on
scatter(RA(validRmsCdpp),DEC(validRmsCdpp),[],kpmag(validRmsCdpp),'.')
caxis([10,17])
xlabel('RA [degrees]')
ylabel('DEC [degrees]')
title(['kpmag vs focal plane location for ',num2str(nTargets),' Kepler DR25 targets'])
t = colorbar('peer',gca);
set(get(t,'ylabel'),'String', 'kpmag');
set(gca,'FontSize',12)
set(findall(gcf,'type','text'),'FontSize',12)
plotName = strcat(plotDir,'kpmag_vs_position');
print('-dpng','-r150',plotName)

% Map of dataSpans vs focal plane location 
figure
box on
grid on
hold on
scatter(RA(validRmsCdpp),DEC(validRmsCdpp),[],dataSpans(validRmsCdpp,pulseIndex),'.')
caxis auto
xlabel('RA [degrees]')
ylabel('DEC [degrees]')
title(['dataSpans1 (at 6 hour pulse) vs focal plane location for ',num2str(nTargets),' Kepler DR25 targets'])
t = colorbar('peer',gca);
set(get(t,'ylabel'),'String', 'dataSpans [days]');
set(gca,'FontSize',12)
set(findall(gcf,'type','text'),'FontSize',12)
plotName = strcat(plotDir,'dataSpans_vs_position');
print('-dpng','-r150',plotName)

% Map of dutyCycles vs focal plane location 
figure
box on
grid on
hold on
scatter(RA(validRmsCdpp),DEC(validRmsCdpp),[],dutyCycles(validRmsCdpp,pulseIndex),'.')
caxis auto
xlabel('RA [degrees]')
ylabel('DEC [degrees]')
title(['dutyCycles1 (at 6 hour pulse) vs focal plane location for ',num2str(nTargets),' Kepler DR25 targets'])
t = colorbar('peer',gca);
set(get(t,'ylabel'),'String', 'dutyCycles');
set(gca,'FontSize',12)
set(findall(gcf,'type','text'),'FontSize',12)                                                                                                                                                                     
plotName = strcat(plotDir,'dutyCycles_vs_position');
print('-dpng','-r150',plotName)


