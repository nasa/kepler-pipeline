% compare_output_structs.m
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

% KIC3114789'
topDir = '/path/to/transitInjectionRuns_fractionToSampleByMes_set_to_0/testRun_KIC3114789_10012015/tps-matlab-2015273/';
load(strcat(topDir,'tps-injection-struct.mat'))
tpsInjectionStruct1 = tpsInjectionStruct;
clear tpsInjectionStruct;


% KSOC-4930 (2 G stars: KIC-3114789 and KIC-9898170 -- both are previous injection targets)
% load the tpsInjectionStruct
topDir = '/path/to/transitInjections/KSOC-4930/testRun_2_G_stars/tps-matlab-2015308/';
load(strcat(topDir,'tps-injection-struct.mat'))
tpsInjectionStruct2 = tpsInjectionStruct;
clear tpsInjectionStruct


% Identify all injections with KIC 3114789
commonIdx2 = ismember(tpsInjectionStruct2.keplerId,tpsInjectionStruct1.keplerId);

% Injected Epoch and period from KSOC-4930
injectedEpoch2 = tpsInjectionStruct2.injectedEpochKjd(commonIdx2);
injectedPeriodDays2 = tpsInjectionStruct2.injectedPeriodDays(commonIdx2);
maxMes2 = tpsInjectionStruct2.maxMes(commonIdx2);
rmsCdpp2 = tpsInjectionStruct2.rmsCdpp(commonIdx2);
robustStatistic2 = tpsInjectionStruct2.robustStatistic(commonIdx2);
impactParameter2 = tpsInjectionStruct2.impactParameter(commonIdx2);
isPlanetACandidate2 = tpsInjectionStruct2.isPlanetACandidate(commonIdx2);

% Injected Epoch and period of original run
injectedEpoch1 = tpsInjectionStruct1.injectedEpochKjd;
injectedPeriodDays1 = tpsInjectionStruct1.injectedPeriodDays;
maxMes1 = tpsInjectionStruct1.maxMes;
rmsCdpp1 = tpsInjectionStruct1.rmsCdpp;
robustStatistic1 = tpsInjectionStruct1.robustStatistic;
impactParameter1 = tpsInjectionStruct1.impactParameter;
isPlanetACandidate1 = tpsInjectionStruct1.isPlanetACandidate;

tic % takes about a half-hour
matchIndex2 = zeros(1,length(injectedEpoch1));
for II = 1:length(injectedEpoch1)
    
    tmp = find(injectedEpoch2 == injectedEpoch1(II) & injectedPeriodDays2 == injectedPeriodDays1(II));
    if(~isempty(tmp)&&length(tmp)==1)
    matchIndex2(II) = tmp;    
    elseif(length(tmp)>1)
        fprintf('%d matches for II = %d\n',length(tmp),II)
    end
end
toc


% epochs are the same
[~, IE1, IE2] = intersect(injectedEpoch1,injectedEpoch2);

% periods are the same
[~, IP1, IP2] = intersect(injectedPeriodDays1,injectedPeriodDays2);

% epochs AND periods are the same
[~, ee, pp] = intersect(IE1,IP1);

[~, qq, rr] = intersect(IE2,IP2);


% Check
sum(injectedEpoch1(IE1(ee)) ~= injectedEpoch2(IE2(ee)))
sum(injectedPeriodDays1(IP1(pp)) ~= injectedPeriodDays2(IP2(pp)))

% More checking -- why don't these match exactly? 
e1 = injectedEpoch1(IE1(ee));
e2 = injectedEpoch2(IE2(ee));

p1 = injectedPeriodDays1(IE1(ee));
p2 = injectedPeriodDays2(IE2(ee));

m1 = maxMes2(IE2(ee));
m2 = maxMes2(IP2(pp));

r1 = rmsCdpp2(IE2(ee));
r2 = rmsCdpp2(IP2(pp));

s1 = robustStatistic2(IE2(ee));
s2 = robustStatistic2(IP2(pp));

i1 = impactParameter2(IE2(ee));
i2 = impactParameter2(IP2(pp));


c2a = isPlanetACandidate2(IE2(ee));
c2b = isPlanetACandidate2(IP2(pp));

