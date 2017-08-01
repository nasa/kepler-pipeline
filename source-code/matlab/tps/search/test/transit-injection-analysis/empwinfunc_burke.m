% empwinfunc_burke.m
% Chris Burke's empirical window function
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

% Get tpsInjectionStruct

%inputstruct1='/path/to/transitInjections/KSOC-4964/testRun_1_with_2_G_stars/tps-matlab-2015344/tps-injection-struct.mat';
%inputstruct1='/path/to/transitInjections/KSOC-4964/testRun_2_with_2_G_stars/tps-matlab-2015344/tps-injection-struct.mat';
% inputstruct1='/path/to/transitInjections/KSOC-4964/testRun_4_with_20_stars/tps-matlab-2015356/tps-injection-struct.mat';

% Get groupLabel
groupLabel = input('Group label, eg: KSOC-4976-1 -- ','s');

% Get directories for injection struct and diagnostics
[topDir, diagnosticDir] = get_top_dir(groupLabel);

% Load the injection struct
inputstruct1=strcat(topDir,'tps-injection-struct.mat');
load(inputstruct1);

% constants
MINPER=50.0;
MAXPER=900.0;
MINIMP=0.4;
MINMES=20.0;
kicwant=unique(tpsInjectionStruct.keplerId);
DELPER=2.0;
xedges=100.0:DELPER:750.0;
midx=xedges(1:end-1)+diff(xedges)/2.0;

% cumulative lists
cumulativeinjper=[];
cumulativeinjrp=[];
cumulativeinjepc=[];

% transit diagnostics and parameters
mes1 = tpsInjectionStruct.injectedDepthPpm .* 1e-6 .* tpsInjectionStruct.normSum000;
mes2 = tpsInjectionStruct.injectedDepthPpm ./ tpsInjectionStruct.rmsCdpp .* sqrt(tpsInjectionStruct.numSesInMes);
mes3 = tpsInjectionStruct.injectedDepthPpm .* 1e-6 .* tpsInjectionStruct.normSum111; % !!!!! using this for expected MES estimate
mes4 = tpsInjectionStruct.maxMes;
imps = tpsInjectionStruct.impactParameter;
ispc = tpsInjectionStruct.isPlanetACandidate;
spsdfrac = tpsInjectionStruct.fractionOfInTransitSpsdCadences;
deephfrac = tpsInjectionStruct.fractionOfInTransitDeemphasizedCadences;

% transit diagnostics and parameters evaluated at injected parameters
ispcat = tpsInjectionStruct.isPlanetACandidateWhenSearchedWithInjectedPeriodAndDuration;    % !!!!! use for isPlanetACandidate
mes4at = tpsInjectionStruct.maxMesWhenSearchedWithInjectedPeriodAndDuration;                % !!!!! use for maxMes
numsesat = tpsInjectionStruct.numSesInMesWhenSearchedWithInjectedPeriodAndDuration;         % !!!!! use to determine the correct number of transits for this injection
singlepulseat = tpsInjectionStruct.fitSinglePulseWhenSearchedWithInjectedPeriodAndDuration; % !!!!! use for fitSinglePulse
rsat = tpsInjectionStruct.robustStatisticWhenSearchedWithInjectedPeriodAndDuration;         % !!!!! use for robustStatistic

% Set up plot
close all
houter=figure();
set(houter,'Units','pixels');
% set(houter,'Position',[100 100 825 625]);
markerwheel={'-ro';'-bo';'-mo';'-go';'-yo';'-r*';'-b*';'-m*';'-g*';'-y*';'-r^';'-b^';'-m^';'-g^';'-y^';'-rx';'-bx';'-mx';'-gx';'-yx';};
lwt=2.0; lwt2=3.5; fntsz=17.0; fntsz2=15.0; fntsz3=15.0; mrksz=6.0;


% Loop over target stars
for i=1:length(kicwant)
  curkic=kicwant(i);
  outfil=sprintf('winfunc_wspsd_%09d',curkic);
  
  % Indicator for 'valid' injections for window function
  % current target & 
  % impact param < 0.4 & 
  % period between 50 and 900 days & 
  % MES > 20
  idx=find(tpsInjectionStruct.keplerId == curkic & tpsInjectionStruct.impactParameter < MINIMP & tpsInjectionStruct.injectedPeriodDays < MAXPER & tpsInjectionStruct.injectedPeriodDays > MINPER & mes3 > MINMES);%tpsInjectionStruct.planetRadiusInEarthRadii > 5.0);

  % transit parameters and diagnostics for 'valid' injections
  curinjepc = tpsInjectionStruct.injectedEpochKjd(idx);
  curepc = tpsInjectionStruct.epochKjd(idx);
  curinjdur = tpsInjectionStruct.injectedDurationInHours(idx);
  curpc = tpsInjectionStruct.isPlanetACandidate(idx);
  curimp = tpsInjectionStruct.impactParameter(idx);
  curper = tpsInjectionStruct.periodDays(idx);
  curinjper = tpsInjectionStruct.injectedPeriodDays(idx);
  curmes1 = mes1(idx);
  curmes2 = mes2(idx);
  curmes3 = mes3(idx); % !!!!! expectedMes
  curinjdep = tpsInjectionStruct.injectedDepthPpm(idx);
  curnormsum = tpsInjectionStruct.normSum000(idx);
  curcdpp = tpsInjectionStruct.rmsCdpp(idx);
  curnses = tpsInjectionStruct.numSesInMes(idx);
  curfsp = tpsInjectionStruct.fitSinglePulse(idx);
  curmes = tpsInjectionStruct.maxMes(idx);
  curinjrp = tpsInjectionStruct.planetRadiusInEarthRadii(idx);
  currobstat = tpsInjectionStruct.robustStatistic(idx);
  curspsdf = spsdfrac(idx);
  curdeemphf = deephfrac(idx);
  
  curnumtran = numsesat(idx);                   % !!!!! evaluated at injected transit parameters
  cursinglepulse = singlepulseat(idx);          % !!!!! evaluated at injected transit parameters
  curpcat = ispcat(idx);                        % !!!!! evaluated at injected transit parameters
  curmesat = mes4at(idx);                       % !!!!! evaluated at injected transit parameters
  currsat = rsat(idx);                          % !!!!! evaluated at injected transit parameters
  

  % WF1 : High SNR and PC flag only
  curwinpass1=zeros(size(curpc));
  
  % WF2 : High SNR and numtran and single pulse only
  curwinpass2=zeros(size(curpc));
  
  % WF3 : High SNR numtran and singlepulse and mes suppression
  curwinpass3=zeros(size(curpc));
  
  % For WF1: Pass valid injections that are PCs
  idx = curpc == 1;
  curwinpass1(idx)=1;

  % For WF2 and WF3: Pass valid injections with more than 3 transits
  idx = find(curnumtran>3);
  curwinpass2(idx)=1;
  curwinpass3(idx)=1;
  
  % For WF2 and WF3: Also pass valid injections with 3 *good* transits
  idx = find(curnumtran == 3 & cursinglepulse == 0);
  curwinpass2(idx)=1;
  curwinpass3(idx)=1;
  
  % For WF3: Fail valid injections with maxMES lower than 1/3 of expected MES
  idx = curmes3./curmesat > 3.0;
  curwinpass3(idx)=0;
  
  % Valid injections 3 good transits & maxMes lower than 1/3 of expected MES
  % that did *not* become PCs
  idx=find(curnumtran == 3 & cursinglepulse == 0 & curmes3./curmesat > 3  & curpc == 0);
  disp([curpcat(idx) curpc(idx) curmes3(idx) curmesat(idx) currobstat(idx) curdeemphf(idx) curspsdf(idx)])
  
  
  % NOTE 
  % WF1 is defined by injections that are PCs, with MES > 20
  % WF2 is defined by injections with either 3 good transits or > 3, with
  %    MES > 20
  % transits
  
  % Plot maxMes vs maxMes/expectedMes for these
  loglog(curmes3(idx),curmes3(idx)./curmesat(idx),'.b')
  hold on
  title('3 good transits & maxMes < 3*expectedMes & not PC')
  xlabel('expectedMES')
  ylabel('expectedMES/maxMES')
  set(gca,'FontSize',12)
  set(findall(gcf,'type','text'),'FontSize',12)
  pause
  
  % Update cumulative lists of injected period, radius, epoch with
  % injections on this target that had 3 good transits and maxMes lower
  % than 1.5*expectedMes
  cumulativeinjper=[cumulativeinjper;curinjper(idx)];
  cumulativeinjrp=[cumulativeinjrp;curinjrp(idx)];
  cumulativeinjepc=[cumulativeinjepc;curinjepc(idx)];
  
  % Scatter plot of period vs. radius of injections with 3 good transits and maxMes lower
  % than 1.5*expectedMes
  clf
  hold on
  title('3 good transits & maxMes < 3*expectedMes & not PC')
  plot(cumulativeinjper,cumulativeinjepc,'.b');
  xlabel('injected period [days]')
  ylabel('injected epoch [days]')
  set(gca,'FontSize',12)
  set(findall(gcf,'type','text'),'FontSize',12)
  pause
  
  % Injections Passing WF1
  % ind2= curwinpass1 == 1;
  
  % Periods of injections that failed WF1
  perMissed = curinjper(curwinpass1 == 0 );

  % Periods of injections that passed WF1
  perDetected = curinjper(curwinpass1 == 1);
  
  % PDF period of injections that failed WF1
  nMissedTemp = histc(perMissed,xedges);
  nMissed = nMissedTemp(1:end-1);
  
  % PDF of period of injections that passed WF1
  nDetectedTemp = histc(perDetected,xedges);
  nDetected = nDetectedTemp(1:end-1);
  
  % Construct WF1
  winfunc1 = double(nDetected)./double(nMissed+nDetected);
  
  % Injections passing WF2
  % ind2= curwinpass2 == 1;
  
  % Periods of injections that failed WF2
  perMissed = curinjper(curwinpass2 == 0 );
  
  % Periods of injections that passed WF2
  perDetected = curinjper(curwinpass2 == 1);
  
  % PDF of period of injections that failed WF2
  nMissedTemp = histc(perMissed,xedges);
  nMissed = nMissedTemp(1:end-1);
  
  % PDF of period of injections that passed WF2
  nDetectedTemp = histc(perDetected,xedges);
  nDetected = nDetectedTemp(1:end-1);
  
  % Construct WF2
  winfunc2 = double(nDetected)./double(nMissed+nDetected);
  
  % Injections passing WF3
  ind2= curwinpass3 == 1;
  
  % Periods of injections that failed WF3
  perMissed = curinjper(curwinpass3 == 0 );
  
  % Periods of injections that passed WF3
  perDetected = curinjper(curwinpass3 == 1);
  
  % PDF of period of injections that failed WF3
  nMissedTemp = histc(perMissed,xedges);
  nMissed = nMissedTemp(1:end-1);
  
  % PDF of period of injections that passed WF3
  nDetectedTemp = histc(perDetected,xedges);
  nDetected = nDetectedTemp(1:end-1);
 
  % Construct WF3
  winfunc3 = double(nDetected)./double(nMissed+nDetected);
  
  % Plot window functions 1 and 2
  clf
  title(['Window Functions for keplerId ',num2str(curkic)])
  hold on
  plot(midx,winfunc1,'-r')
  hold on;
  % pause
  plot(midx,winfunc2,'-b');
  % pause
  % plot(midx,winfunc3,'-m');
  % pause
  hold off;
  hx=xlabel('Period');
  hy=ylabel('Window Function');
  set([hx hy],'FontSize',fntsz,'fontWeight','b');
  set(gca,'FontSize',fntsz2,'LineWidth',lwt2);
  set(gca,'ticklength',[0.02 0.02])%,'layer','top');
  bkgcolor='white';boxcolor=[30.0;30.0;30.0]./255.0;
  set(gca,'color',bkgcolor,'xcolor',boxcolor,'ycolor',boxcolor);
  set(gcf,'color',bkgcolor);
  set(gcf,'InvertHardCopy','off');
  set(gcf, 'Renderer', 'painters');
  legend('WF1: MES > 20 & PC','WF2: MES > 20 & pass WF')
  set(gca,'FontSize',12)
  set(findall(gcf,'type','text'),'FontSize',12)
  pause
  print('-dpng','-r150',outfil)
  
  % pause(1)
  % print(gcf,outfil,'-depsc2','-painters','-cmyk','-loose');
  % pause(1)
  % syscom=sprintf('gs -dSAFER -dBATCH -dNOPAUSE -sDEVICE=png16m -dGraphicsAlphaBits=4 -dEPSCrop -r500 -sOutputFile=%s.png %s.eps',outfil,outfil)
  % stat=system(syscom);
  % pause
  
end


hold off


