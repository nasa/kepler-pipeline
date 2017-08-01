% test_compute_fit_single_pulse_pass_for_diagnostics.m
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

% Get an input data file from KSOP-2539 TPS SOC 9.3 V4 PLTI
% /path/to/ksop-2539-tps-q1-q17-transit-injection-reRun 

% Get taskfilesDir for input data file from KSOC-5041
% taskfilesDir = '/path/to/tps-matlab-2016127/tps-matlab-2016127-0/st-0/';

% Get taskfilesDir from input data from 
taskfilesDir = '/path/to/transitInjections/KSOC-5004/Group_1_20_stars_fractionToSampleByMes_0/tps-matlab-2016070/tps-matlab-2016070-000/st-0/';
% Load input data file
load(strcat(taskfilesDir,'tps-inputs-0.mat'))
tpsInputStruct = inputsStruct;

% add path to tps and transit_injection_controller codes -- shouldn't have to do this!
addpath /path/to/matlab/tps/search/test/transit-injection/
addpath '/path/to/matlab/tps/search/mfiles/';

%==========================================================================
% build localControlParameterStrucct

% Control parameters for local run
nInjections = 0;
minImpactParameter = 0.3;
minPlanetRadiusEarthRadii = 12;
maxPlanetRadiusEarthRadii = 15;
saveInterval = 1;
minPeriodOverride = 425;
alwaysInject = true;
collectPeriodSpaceDiagnostics = true;
saveTpsDataForEachInjection = true;
saveDir = '/codesaver/work/transit_injection/test/wavelet_coeff/';

% Package local control parameters into a struct
localControlParameterStruct.nInjections = nInjections;
localControlParameterStruct.minImpactParameter = minImpactParameter;
localControlParameterStruct.minPlanetRadiusEarthRadii = minPlanetRadiusEarthRadii;
localControlParameterStruct.maxPlanetRadiusEarthRadii = maxPlanetRadiusEarthRadii;
localControlParameterStruct.saveInterval = saveInterval;
localControlParameterStruct.minPeriodOverride = minPeriodOverride;
localControlParameterStruct.alwaysInject = alwaysInject;
localControlParameterStruct.collectPeriodSpaceDiagnostics = collectPeriodSpaceDiagnostics;
localControlParameterStruct.saveDir = saveDir;
localControlParameterStruct.saveTpsDataForEachInjection = saveTpsDataForEachInjection;


% Run transit-injection_controller
outputStruct = transit_injection_controller( tpsInputStruct, localControlParameterStruct );
load(strcat(saveDir,'tps-injection-results-struct-1-injections.mat'))
load(strcat(saveDir,'tps-data-for-injection-1.mat'))

% Trial transit pulse
trialTransitPulseInHours = injectionOutputStruct.trialTransitPulseInHours;

% Cadences per hour
cadencesPerHour = cadencesPerDay/24;

% Number of super-resolution cadences in the transit pulse.
nInTransitCadences = round( trialTransitPulseInHours*cadencesPerHour*superResolutionFactor + 1 );

% Test compute_fit_single_pulse_pass_for_diagnostics
% Try different trial pulse duration
% trialTransitPulseInHours = 2.5;
% trialTransitPulseInHours = 15;
% trialTransitPulseInHours = 7;
% trialTransitPulseInHours = 7.5;
% trialTransitPulseInHours = 8;
trialTransitPulseInHours = 10;



fitSinglePulsePass = ...
    compute_fit_single_pulse_pass_for_diagnostics( deemphasisWeight, ...
    trialTransitPulseInHours, superResolutionFactor, cadencesPerHour );

% Diagnostic plot
figure
hold on
box on
grid on
plot(cadencesAll,deemphasisWeight,'bo')
plot(cadencesAll,fitSinglePulsePass,'r.-')



