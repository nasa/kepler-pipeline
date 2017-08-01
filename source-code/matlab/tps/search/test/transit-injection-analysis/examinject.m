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
inputstruct1='tps-injection-struct_3A.mat';
inputstruct2='tps-injection-struct_3B.mat';
if (~exist('d1'));load(inputstruct1);d1=tpsInjectionStruct;end;
if (~exist('d2'));load(inputstruct2);d2=tpsInjectionStruct;end;
markerwheel={'-ro';'-bo'};
lwt=2.0; lwt2=3.5; fntsz=17.0; fntsz2=15.0; fntsz3=15.0; mrksz=6.0;
close all
houter=figure();
set(houter,'Units','pixels');
set(houter,'Position',[100 100 825 625]);
outfil='ksoc-4841_300-600';
MINPER=50.0;
MAXPER=200.0;

%{
injfnd=find(d.isPlanetACandidate == true);
plot(d.injectedPeriodDays,d.injectedEpochKjd,'.b')
hold on;plot(d.injectedPeriodDays(injfnd),d.injectedEpochKjd(injfnd),'.r');hold off;
pause

plot(d.injectedPeriodDays,d.injectedDepthPpm,'.b');
hold on;plot(d.injectedPeriodDays(injfnd),d.injectedDepthPpm(injfnd),'.r');hold off;
pause

hist(d.impactParameter,100)
pause
%}

DELMES=0.1;
xedges=2.0:DELMES:16.0;
midx=xedges(1:end-1)+diff(xedges)/2.0;
plot(midx,cdf('norm',midx,7.1,1),'-*k')
hold on
vline(7.1)
grid on

for i=1:2
clear('d');
if (i == 1);d=d1;end;
if (i == 2);d=d2;end;
epochMatchInd = abs(d.injectedEpochKjd - d.epochKjd)*48.939 < d.injectedDurationInHours *48.939 / 2 / 24 ;
ind = d.injectedDepthPpm ~=0 & ~(d.numSesInMes==3 & d.fitSinglePulse==true) & d.numSesInMes>3 & d.periodDays<MAXPER & d.periodDays>MINPER & epochMatchInd;

mes = d.injectedDepthPpm .* 1e-6 .* d.normSum000;
mesMissed = mes(d.isPlanetACandidate==0 & ind);
mesDetected = mes(d.isPlanetACandidate==1 & ind );
nMissedTemp = histc(mesMissed,xedges);
nDetectedTemp = histc(mesDetected,xedges);
nMissed = nMissedTemp(1:end-1);
nDetected = nDetectedTemp(1:end-1);
plot(midx,nDetected./(nDetected+nMissed),markerwheel{i})
end

hx=xlabel('MES');
hy=ylabel('Percent Recovered');
set([hx hy],'FontSize',fntsz,'fontWeight','b');
set(gca,'FontSize',fntsz2,'LineWidth',lwt2);
set(gca,'ticklength',[0.02 0.02])%,'layer','top');
% presentation colors
%bkgcolor='black';boxcolor=[230.0;230.0;230.0]./255.0;
% Hard copy colors
bkgcolor='white';boxcolor=[30.0;30.0;30.0]./255.0;
set(gca,'color',bkgcolor,'xcolor',boxcolor,'ycolor',boxcolor);
set(gcf,'color',bkgcolor);
set(gcf,'InvertHardCopy','off');
set(gcf, 'Renderer', 'painters');
pause(1)
print(gcf,outfil,'-depsc2','-painters','-cmyk','-loose');
pause(1)
syscom=sprintf('gs -dSAFER -dBATCH -dNOPAUSE -sDEVICE=png16m -dGraphicsAlphaBits=4 -dEPSCrop -r500 -sOutputFile=%s.png %s.eps',outfil,outfil)
stat=system(syscom);


hold off