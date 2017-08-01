function sc_requirements_verification_pa( testCasePath )

% some constants
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
exposureTimeSeconds = 6.01982;
exposuresPerSC = 9;

mag12FluxPerSecond = 214100;
exposureTimePerSC = exposuresPerSC * exposureTimeSeconds;

mag12FluxPerSC = mag12FluxPerSecond * exposureTimePerSC;


testCasePath = '/path/to/matlab/cal-pa-vandv';


TC01_inputs_0 = [testCasePath,filesep,'tc01',filesep,'sc',filesep,'pa-matlab-10-80',filesep,'pa-inputs-0.mat'];                 %#ok<NASGU>
TC01_outputs_0 = [testCasePath,filesep,'tc01',filesep,'sc',filesep,'pa-matlab-10-80',filesep,'pa-outputs-0.mat'];

TC02_inputs_0 = [testCasePath,filesep,'tc02',filesep,'sc',filesep,'pa-matlab-10-80',filesep,'pa-inputs-0.mat'];
TC02_outputs_0 = [testCasePath,filesep,'tc02',filesep,'sc',filesep,'pa-matlab-10-80',filesep,'pa-outputs-0.mat'];

TC06_inputs_0 = [testCasePath,filesep,'tc06',filesep,'sc',filesep,'pa-matlab-10-80',filesep,'pa-inputs-0.mat'];
TC06_outputs_0 = [testCasePath,filesep,'tc06',filesep,'sc',filesep,'pa-matlab-10-80',filesep,'pa-outputs-0.mat'];


%% ----------------------------------------------------------

disp('73.PA.1   PA shall process short and long cadence targets');
disp('73.PA.2   PA shall produce Relative Flux time series at the same temporal');
disp('          resolution as the original photometric data for both long and short cadences.');
disp(' ');
disp('1.    Load first target invocation input structure and associated output');
disp('      structure from test data set.');
disp('      Verify that cadence type for PA processing is specified by');
disp('      inputsStruct.cadenceType = LONG or SHORT (73.PA.1) ');

disp(' ');
disp(['Loading ',TC02_inputs_0,' ...']);
load(TC02_inputs_0);
disp(['Loading ',TC02_outputs_0,' ...']);
load(TC02_outputs_0);

display(inputsStruct);                                  %#ok<NODEF>
display(outputsStruct);                                 %#ok<NODEF>

display('Hit any key to continue ...');
pause;

disp(' ');
disp('2.    Note number of cadences in cadenceTimes structure. ');
disp('                      inputsStruct.cadenceTimes');
disp('                                      .startTimestamps');
disp('                                      .midTimestamps');
disp('                                      .endTimestamps');
disp('                                      .gapIndicators');
disp('                                      .cadenceNumbers');

disp(' ');
disp('inputsStruct.cadenceTimes');
display(inputsStruct.cadenceTimes);
disp(' ');

display('Hit any key to continue ...');
pause;

disp(' ');
disp('3.    Note that temporal resolution (number of cadences) of the original');
disp('      photometric data is consistent with cadenceTimes. ');
disp('                      inputsStruct.targetStarDataStruct(i).pixelDataStruct(j) ');
disp('                                      .values');
disp('                                      .uncertainties');
disp('                                      .gapIndicators');

disp(' ');
disp('inputsStruct.targetStarDataStruct(1).pixelDataStruct(1)');
display(inputsStruct.targetStarDataStruct(1).pixelDataStruct(1));
disp(' ');

display('Hit any key to continue ...');
pause;

disp(' ');
disp('4.    Verify that temporal resolution (number of cadences) of the raw');
disp('      flux time series is consistent with cadenceTimes (73.PA.2). ');
disp('                      outputsStruct.targetStarResultsStruct(i).fluxTimeSeries ');
disp('                                      .values');
disp('                                      .uncertainties');
disp('                                      .gapIndicators');

disp(' ');
disp('outputsStruct.targetStarResultsStruct(1).fluxTimeSeries');
display(outputsStruct.targetStarResultsStruct(1).fluxTimeSeries);
disp(' ');

display('Hit any key to continue ...');
pause;

%% ----------------------------------------------------------

disp(' ');
disp('116.PA.1  PA shall remove Zodiacal Light from calibrated pixel data.');
disp(' ');
disp('2.    The raw flux time series for each PA target is given by');
disp('      paResultsStruct.targetStarResultsStruct(i).fluxTimeSeries.values. Plot');
disp('      the mean difference over each flux time series between the raw flux time');
disp('      series with and without zodi. This may be accomplished for a specified PA');
disp('      long cadence invocation with the test script: verify_116pa1( invocation )'); 
disp(' ');

disp(' ');
disp(['Loading ',TC01_outputs_0,' ...']);
load(TC01_outputs_0);
outputsStruct_01 = outputsStruct;
disp(['Loading ',TC02_outputs_0,' ...']);
load(TC02_outputs_0);
outputsStruct_02 = outputsStruct;
clear outputsStruct

flux_01 = [outputsStruct_01.targetStarResultsStruct.fluxTimeSeries];
flux_02 = [outputsStruct_02.targetStarResultsStruct.fluxTimeSeries];
plot([flux_02.values]-[flux_01.values],'.');
grid;
xlabel('relative cadence #');
ylabel('raw flux ( e- / sc )');
title('Difference in SC Raw Flux, Zodi On - Zodi Off');

display('Hit any key to continue ...');
pause;

disp('3.    Verify that the mean flux difference for the targets in the two');
disp('      data sets is near zero, far less than the nominal zodi background level');
disp('      per pixel. The small bias in the difference is likely due to differences');
disp('      in the undershoot correction with and without zodi. It is evident that');
disp('      there are some outlier targets with input pixel differences in the two');
disp('      data sets that go beyond zodi. The differences may be introduced in');
disp('      either ETEM or CAL.      ');
disp(' ');

display('Hit any key to continue ...');
pause;

%% ----------------------------------------------------------

disp(' ');
disp('116.PA.2  PA shall be capable of exactly reconstructing the background');
disp('          corrected pixel values for both short and long cadence targets. ');
disp(' ');
disp('5.    The background polynomials are provided as input in the short');
disp('      cadence case to allow PA to reconstruct the background corrected pixel');
disp('      values for short cadence PA targets. In this case, the background');
disp('      polynomials and associated covariances are interpolated at the short');
disp('      cadence (mid-) timestamps. The background information is made available');
disp('      to SC PA through the backgroundBlobs structure in the first invocation');
disp('      inputs. Load the input struct for the first SC invocation and verify the');
disp('      fields under backgroundBlobs are not empty. e.g.');
disp(' ');
disp('inputsStruct.backgroundBlobs');
disp('      blobIndices: [nLongCadencesx1 double]');
disp('    gapIndicators: [nLongCadencesx1 logical]');
disp('    blobFilenames: {mBlobFileNamesx1} string');
disp('     startCadence: absolute long cadence start');
disp('       endCadence: absolute long cadence end');
disp(' ');

disp(' ');
disp(['Loading ',TC02_inputs_0,' ...']);
load(TC02_inputs_0);
disp(' ');

disp('inputsStruct.backgroundBlobs');
display(inputsStruct.backgroundBlobs);
disp(' ');

display('Hit any key to continue ...');
pause;

currentDir = pwd;
cd([testCasePath,filesep,'tc02',filesep,'sc',filesep,'pa-matlab-10-80']);
A = poly_blob_series_to_struct(inputsStruct.backgroundBlobs);
cd(currentDir);


deltaStartMjdMinutes = (24*60) * (A(1).mjdMidTime - inputsStruct.cadenceTimes.midTimestamps(1))
deltaEndMjdMinutes = (24*60) * (A(end).mjdMidTime - inputsStruct.cadenceTimes.midTimestamps(end))

abs(deltaStartMjd) < 3 *30
abs(deltaEndMjd) < 3 *30

display('Hit any key to continue ...');
pause;

%% ----------------------------------------------------------

disp(' ');
disp('118.PA.5');
disp('118.PA.6');
disp('118.PA.9');
disp('118.PA.10');
disp(' ');

disp(['Loading ',TC02_outputs_0,' ...']);
load(TC02_outputs_0);
outputsStruct_02 = outputsStruct;
clear outputsStruct

outputsStruct_02.targetStarResultsStruct(1).fluxWeightedCentroids.rowTimeSeries
outputsStruct_02.targetStarResultsStruct(1).fluxWeightedCentroids.columnTimeSeries
outputsStruct_02.targetStarResultsStruct(1).prfCentroids.rowTimeSeries
outputsStruct_02.targetStarResultsStruct(1).prfCentroids.columnTimeSeries

display('Hit any key to continue ...');
pause;


FW = [outputsStruct_02.targetStarResultsStruct.fluxWeightedCentroids];
FW_row = [FW.rowTimeSeries];
FW_col = [FW.columnTimeSeries];
PRF = [outputsStruct_02.targetStarResultsStruct.prfCentroids];
PRF_row = [PRF.rowTimeSeries];
PRF_col = [PRF.columnTimeSeries];


figure;
ax(1) = subplot(2,2,1);
plot([FW_row.values]);
grid;
title('SC Flux Weighted Target Centroids');
ylabel('row ( pixels )');
ax(2) = subplot(2,2,2);
plot([FW_row.uncertainties]);
grid;
ylabel('row uncertainty (pixels)');

ax(3) = subplot(2,2,3);
plot([FW_col.values]);
grid;
ylabel('col ( pixels )');
xlabel('relative cadence #');
ax(4) = subplot(2,2,4);
plot([FW_col.uncertainties]);
grid;
ylabel('col uncertainty (pixels)');
xlabel('relative cadence #');
linkaxes(ax,'x');

figure;
ax(1) = subplot(2,2,1);
plot([PRF_row.values]);
grid;
title('SC PRF Target Centroids');
ylabel('row ( pixels )');
ax(2) = subplot(2,2,2);
plot([PRF_row.uncertainties]);
grid;
ylabel('row uncertainty (pixels)');

ax(3) = subplot(2,2,3);
plot([PRF_col.values]);
grid;
ylabel('col ( pixels )');
xlabel('relative cadence #');
ax(4) = subplot(2,2,4);
plot([PRF_col.uncertainties]);
grid;
ylabel('col uncertainty (pixels)');
xlabel('relative cadence #');
linkaxes(ax,'x');

figure;
plot(mean([FW_row.uncertainties]),std([FW_row.values]),'.');
hold on;
plot(mean([FW_col.uncertainties]),std([FW_col.values]),'r.');
hold off;
grid;
title('SC Flux Weighted Target Centoirds');
ylabel('std of centroid time series (pixels)');
xlabel('mean centroid uncertainty (pixels)');
legend('Row','Column',2);

figure;
plot(mean([PRF_row.uncertainties]),std([PRF_row.values]),'.');
hold on;
plot(mean([PRF_col.uncertainties]),std([PRF_col.values]),'r.');
hold off;
grid;
title('SC PRF Target Centoirds');
ylabel('std of centroid time series (pixels)');
xlabel('mean centroid uncertainty (pixels)');
legend('Row','Column',2);

display('Hit any key to continue ...');
pause;

%% ----------------------------------------------------------

disp(' ');
disp('124.PA.1');
disp(' ');

disp(['Loading ',TC02_outputs_0,' ...']);
load(TC02_outputs_0);

outputsStruct.targetStarResultsStruct(1).fluxTimeSeries

disp(' ');
display('Hit any key to continue ...');
pause;

flux = [outputsStruct.targetStarResultsStruct.fluxTimeSeries];
keplerMag = [outputsStruct.targetStarResultsStruct.keplerMag]';
expectedFlux = mag12FluxPerSC .* (10 .^ ((12 - keplerMag)./2.5));
[nCadences, nTargets] = size([flux.values]);                                                    %#ok<NASGU>

figure;
plot([flux.values],'.');
grid;
hold on;
plot([1 nCadences],expectedFlux*[1 1]);
hold off;

xlabel('relative cadence #');
ylabel('flux ( e- )');
title('SC Target Flux - Raw == points, Expected == solid');

display('Hit any key to continue ...');
pause;

%% ----------------------------------------------------------
disp(' ');
disp('143.PA.2');
disp('143.PA.3');
disp(' ');

disp(['Loading ',TC02_outputs_0,' ...']);
load(TC02_outputs_0);

outputsStruct.targetStarResultsStruct(1).fluxTimeSeries

display('Hit any key to continue ...');
pause;

flux = [outputsStruct.targetStarResultsStruct.fluxTimeSeries];
values = [flux.values];
unc = [flux.uncertainties];
gaps = [flux.gapIndicators];

[nCadences, nTargets] = size(values);

figure;
plot([flux.uncertainties],'.');
grid;
xlabel('relative cadence #');
ylabel('flux uncertainty ( e- )');
title('SC Raw Target Flux Uncertainties');

figure;
hold on;
for i=1:nTargets
    plot(i,mean(unc(~gaps(:,i),i)),'ob');
    plot(i,std(values(~gaps(:,i),i)),'xr');
    plot(i,sqrt(mean(values(~gaps(:,i),i))),'*g');
end
hold off;
grid;
xlabel('target index');
ylabel('( e- )');
title('SC Target Flux Uncertainties - o=mean uncertanty, x=std(flux), *=sqrt(mean(flux))');

display('Hit any key to continue ...');
pause;

%% ----------------------------------------------------------
disp(' ');
disp('219.PA.1');
disp(' ');

disp(['Loading ',TC06_outputs_0,' ...']);
load(TC06_outputs_0);

display_structure(outputsStruct.targetStarCosmicRayMetrics);

display('Hit any key to continue ...');
pause;

%% ----------------------------------------------------------
disp(' ');
disp('317.PA.1');
disp('317.PA.6');
disp(' ');

disp(['Loading ',TC06_outputs_0,' ...']);
load(TC06_outputs_0);

outputsStruct.targetStarCosmicRayEvents

display('Hit any key to continue ...');
pause;

%% ----------------------------------------------------------
disp(' ');
disp('317.PA.5');
disp(' ');

disp(['Loading ',TC06_inputs_0,' ...']);
load(TC06_inputs_0);

inputsStruct.paConfigurationStruct.cosmicRayCleaningEnabled = false;
inputsStruct.paConfigurationStruct

display('Hit any key to continue ...');
pause;

% run in test directory
currentDir = pwd;
cd([testCasePath,filesep,'tc06',filesep,'sc',filesep,'pa-matlab-10-80']);
inputsStruct.raDec2PixModel.spiceFileDir = './';
inputsStruct.raDec2PixModel
disp('Copy spice files to current working directory.');
display('Hit any key to continue ...');
pause;

outputsStruct = pa_matlab_controller(inputsStruct);
cd(currentDir);

outputsStruct.targetStarCosmicRayEvents

display('Hit any key to continue ...');
pause;

outputsStruct.targetStarCosmicRayMetrics

all(outputsStruct.targetStarCosmicRayMetrics.hitRate.gapIndicators)
all(outputsStruct.targetStarCosmicRayMetrics.meanEnergy.gapIndicators)
all(outputsStruct.targetStarCosmicRayMetrics.energyVariance.gapIndicators)
all(outputsStruct.targetStarCosmicRayMetrics.energySkewness.gapIndicators)
all(outputsStruct.targetStarCosmicRayMetrics.energyKurtosis.gapIndicators)

display('Hit any key to continue ...');
pause;




