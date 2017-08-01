% function combine_group1_injection_structs()
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

% Combine the injection structs for the Group1 targets into a
% single injection struct and save it
group1Dir = '/path/to/transitInjectionRuns/Group_1_1st_20_G_stars_09032015/';

% Three parts
part1Dir = strcat(group1Dir,'tps-matlab-2015231/');
part2Dir = strcat(group1Dir,'tps-matlab-2015239/');
part3Dir = strcat(group1Dir,'tps-matlab-2015240/');

% Load the 3 injection structs
injectionStructPart1 = load(strcat(part1Dir,'tps-injection-struct.mat'));
injectionStructPart2 = load(strcat(part2Dir,'tps-injection-struct.mat'));
injectionStructPart3 = load(strcat(part3Dir,'tps-injection-struct.mat'));
part1 = injectionStructPart1.tpsInjectionStruct; % 10080 entries
part2 = injectionStructPart2.tpsInjectionStruct; % 6048 entries
part3 = injectionStructPart3.tpsInjectionStruct; % 3528 entries

% Template
tpsInjectionStruct = part1;

% Concatenate tpsInjectionStructs from the three parts into a single struct
tpsInjectionStruct.topDir = 'group1-injection-topdir';
tpsInjectionStruct.keplerId =  [part1.keplerId;part2.keplerId;part3.keplerId];
tpsInjectionStruct.elapsedTime =  [part1.elapsedTime;part2.elapsedTime;part3.elapsedTime];
tpsInjectionStruct.log10SurfaceGravity =  [part1.log10SurfaceGravity;part2.log10SurfaceGravity;part3.log10SurfaceGravity];
tpsInjectionStruct.log10Metallicity =  [part1.log10Metallicity;part2.log10Metallicity;part3.log10Metallicity];
tpsInjectionStruct.effectiveTemp =  [part1.effectiveTemp;part2.effectiveTemp;part3.effectiveTemp];
tpsInjectionStruct.stellarRadiusInSolarRadii =  [part1.stellarRadiusInSolarRadii;part2.stellarRadiusInSolarRadii;part3.stellarRadiusInSolarRadii];
tpsInjectionStruct.dataSpanInCadences =  [part1.dataSpanInCadences;part2.dataSpanInCadences;part3.dataSpanInCadences];
tpsInjectionStruct.dutyCycle =  [part1.dutyCycle;part2.dutyCycle;part3.dutyCycle];
tpsInjectionStruct.keplerId =  [part1.keplerId;part2.keplerId;part3.keplerId];
tpsInjectionStruct.rmsCdpp =  [part1.rmsCdpp;part2.rmsCdpp;part3.rmsCdpp];
tpsInjectionStruct.maxMes =  [part1.maxMes;part2.maxMes;part3.maxMes];
tpsInjectionStruct.numSesInMes =  [part1.numSesInMes;part2.numSesInMes;part3.numSesInMes];
tpsInjectionStruct.epochKjd =  [part1.epochKjd;part2.epochKjd;part3.epochKjd];
tpsInjectionStruct.periodDays =  [part1.periodDays;part2.periodDays;part3.periodDays];
tpsInjectionStruct.trialTransitPulseInHours =  [part1.trialTransitPulseInHours;part2.trialTransitPulseInHours;part3.trialTransitPulseInHours];
tpsInjectionStruct.isPlanetACandidate =  [part1.isPlanetACandidate;part2.isPlanetACandidate;part3.isPlanetACandidate];
tpsInjectionStruct.robustStatistic =  [part1.robustStatistic;part2.robustStatistic;part3.robustStatistic];
tpsInjectionStruct.fitSinglePulse =  [part1.fitSinglePulse;part2.fitSinglePulse;part3.fitSinglePulse];
tpsInjectionStruct.fittedDepth =  [part1.fittedDepth;part2.fittedDepth;part3.fittedDepth];
tpsInjectionStruct.fittedDepthChi =  [part1.fittedDepthChi;part2.fittedDepthChi;part3.fittedDepthChi];
tpsInjectionStruct.zCompSum =  [part1.zCompSum;part2.zCompSum;part3.zCompSum];
tpsInjectionStruct.thresholdForDesiredPfa =  [part1.thresholdForDesiredPfa;part2.thresholdForDesiredPfa;part3.thresholdForDesiredPfa];
tpsInjectionStruct.chiSquare2 =  [part1.chiSquare2;part2.chiSquare2;part3.chiSquare2];
tpsInjectionStruct.chiSquareGof =  [part1.chiSquareGof;part2.chiSquareGof;part3.chiSquareGof];
tpsInjectionStruct.chiSquareDof2 =  [part1.chiSquareDof2;part2.chiSquareDof2;part3.chiSquareDof2];
tpsInjectionStruct.chiSquareGofDof =  [part1.chiSquareGofDof;part2.chiSquareGofDof;part3.chiSquareGofDof];
tpsInjectionStruct.corrSum000 =  [part1.corrSum000;part2.corrSum000;part3.corrSum000];
tpsInjectionStruct.corrSum001 =  [part1.corrSum001;part2.corrSum001;part3.corrSum001];
tpsInjectionStruct.corrSum010 =  [part1.corrSum010;part2.corrSum010;part3.corrSum010];
tpsInjectionStruct.corrSum011 =  [part1.corrSum011;part2.corrSum011;part3.corrSum011];
tpsInjectionStruct.corrSum100 =  [part1.corrSum100;part2.corrSum100;part3.corrSum100];
tpsInjectionStruct.corrSum101 =  [part1.corrSum101;part2.corrSum101;part3.corrSum101];
tpsInjectionStruct.corrSum110 =  [part1.corrSum110;part2.corrSum110;part3.corrSum110];
tpsInjectionStruct.corrSum111 =  [part1.corrSum111;part2.corrSum111;part3.corrSum111];
tpsInjectionStruct.normSum000 =  [part1.normSum000;part2.normSum000;part3.normSum000];
tpsInjectionStruct.normSum001 =  [part1.normSum001;part2.normSum001;part3.normSum001];
tpsInjectionStruct.normSum010 =  [part1.normSum010;part2.normSum010;part3.normSum010];
tpsInjectionStruct.normSum011 =  [part1.normSum011;part2.normSum011;part3.normSum011];
tpsInjectionStruct.normSum100 =  [part1.normSum100;part2.normSum100;part3.normSum100];
tpsInjectionStruct.normSum101 =  [part1.normSum101;part2.normSum101;part3.normSum101];
tpsInjectionStruct.normSum110 =  [part1.normSum110;part2.normSum110;part3.normSum110];
tpsInjectionStruct.normSum111 =  [part1.normSum111;part2.normSum111;part3.normSum111];
tpsInjectionStruct.transitModelMatch =  [part1.transitModelMatch;part2.transitModelMatch;part3.transitModelMatch];
tpsInjectionStruct.injectedPeriodDays =  [part1.injectedPeriodDays;part2.injectedPeriodDays;part3.injectedPeriodDays];
tpsInjectionStruct.planetRadiusInEarthRadii =  [part1.planetRadiusInEarthRadii;part2.planetRadiusInEarthRadii;part3.planetRadiusInEarthRadii];
tpsInjectionStruct.impactParameter =  [part1.impactParameter;part2.impactParameter;part3.impactParameter];
tpsInjectionStruct.injectedEpochKjd =  [part1.injectedEpochKjd;part2.injectedEpochKjd;part3.injectedEpochKjd];
tpsInjectionStruct.semiMajorAxisAu =  [part1.semiMajorAxisAu;part2.semiMajorAxisAu;part3.semiMajorAxisAu];
tpsInjectionStruct.injectedDurationInHours =  [part1.injectedDurationInHours;part2.injectedDurationInHours;part3.injectedDurationInHours];
tpsInjectionStruct.injectedDepthPpm =  [part1.injectedDepthPpm;part2.injectedDepthPpm;part3.injectedDepthPpm];
tpsInjectionStruct.inclinationDegrees =  [part1.inclinationDegrees;part2.inclinationDegrees;part3.inclinationDegrees];
tpsInjectionStruct.equilibriumTempKelvin =  [part1.equilibriumTempKelvin;part2.equilibriumTempKelvin;part3.equilibriumTempKelvin];
tpsInjectionStruct.taskfile =  [part1.taskfile;part2.taskfile;part3.taskfile];

% Save the struct
saveDir = '/codesaver/work/transit_injection/group1-injection-topdir/';
save(strcat(saveDir,'tps-injection-struct.mat'),'tpsInjectionStruct','-v7.3');
