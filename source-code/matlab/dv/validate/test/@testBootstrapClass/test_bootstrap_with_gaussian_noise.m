%% test_bootstrap_with_gaussian_noise
%
% function [self] = test_bootstrap_with_gaussian_noise(self)
%
% Tests bootstrap outputs by creating normally distributed random noise
% signal(using randn with unit variance) as the residual flux time series 
% and sending it in to the tps caller.  This represents the transit-free 
% SES that bootstrap would receive in dv.
% 
% This process is repeated 4 times, detailed below:
%
% First, one quarter's worth of data on 3 trial pulses are used to 
% bootstrap for 4-6 transits.
%
% Second, one year's worth of data on 3 trial pulses are used to bootstrap
% for 3-5 transits.
% 
% Third, one quarter's worth of data on 1 trial pulse is used to bootstrap
% for 4-6 transits.
%
% Fourth, one year's worth of data on 1 trial pulse is used to bootstrap
% for 3-5 transits
%
% The effects for averaging the trial transit pulses are examined aw well 
% as the effects of data length, and to some extent, number of transits.
%
% If no bootstrap histogram is built for a given transit number, 
% it means that max SES < 12 andfalse alarm =0.
% 
% Run with:
%   run(text_test_runner, testBootstrapClass('test_bootstrap_with_gaussian_noise'));
%%
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
function [self] = test_bootstrap_with_gaussian_noise(self)

fprintf('\nTesting boostrap by injecting gaussian noise into residual flux time series.\n')
fprintf('The plots will be found in the current directory, under target-000000123.\n')

initialize_soc_variables;
testDataRoot = fullfile(socTestDataRoot, 'dv', 'unit-tests', 'bootstrap');
dvTestDataRoot = fullfile(socTestDataRoot, 'dv', 'unit-tests', 'dv-matlab-controller');
addpath(testDataRoot);
addpath(dvTestDataRoot);

% Load dvDataStruct and dvResultsStruct 
load('insertGaussian.mat');
DATA_LENGTH = 3000; % length of time series in test data

% TODO Delete if test data updated.
dvDataStruct = dv_convert_62_data_to_70(dvDataStruct); %#ok<NODEF>

% Update spiceFileDirectory (in the dv-matlab-controller folder)
dvDataStruct.raDec2PixModel.spiceFileDir = fullfile(socTestDataRoot, 'fc', 'spice');

% Change the keplerId
dvDataStruct.targetStruct.keplerId = 123;

%% Create gaussian noise in 1 quarter's worth of data using 3 pulses
dvDataStruct.gapFillConfigurationStruct.cadenceDurationInMinutes = DATA_LENGTH*30;
dvResultsStruct.targetResultsStruct.residualFluxTimeSeries.values = randn(DATA_LENGTH, 1);
dvResultsStruct.targetResultsStruct.residualFluxTimeSeries.uncertainties = zeros(DATA_LENGTH, 1);

% Alter dvDataStruct for use in the tps caller
dvDataStruct = update_dv_inputs(dvDataStruct);
dvDataStruct.dvCadenceTimes = estimate_timestamps(dvDataStruct.dvCadenceTimes);
dvDataStruct = compute_barycentric_corrected_timestamps(dvDataStruct);
dvDataStruct.targetStruct.outliers.indices =  [];
dvDataStruct.targetStruct.discontinuityIndices  = [];
dvDataStruct.targetStruct.keplerMag = 12;
dvDataStruct.targetStruct.targetDataStruct.crowdingMetric = 1;
dvDataStruct.tpsConfigurationStruct.edgeDetrendingSignificanceValue = 0.01;

dvResultsStruct.targetResultsStruct.residualFluxTimeSeries.gapIndicators = [];
dvResultsStruct.targetResultsStruct.residualFluxTimeSeries.filledIndices =[];

% Instantitate dvDataObject
dvDataObject = dvDataClass(dvDataStruct);

% Create directories.  Bootstrap looks for the correct folder to save plots
dvResultsStruct = create_directories_for_dv_figures(dvDataObject, dvResultsStruct);

% Call tps
[TCE SES] = call_tps_from_dv(dvDataObject, dvResultsStruct, 1); %#ok<ASGLU>

% Populate dvResultsStruct with SES
dvResultsStruct.targetResultsStruct.singleEventStatistics = SES;

for numTransits = 4:6
    
    fprintf('\n\n Testing 1 quarter''s worth of data, 3 trial transit pulses, %d transits\n\n', numTransits);
    
    % Set observed TransitCount
    dvResultsStruct.targetResultsStruct.planetResultsStruct.planetCandidate.observedTransitCount = numTransits;

    % Call bootstrap
    dvResultsStruct = perform_dv_bootstrap(dvDataObject, dvResultsStruct);

    % Check false alarm
    fprintf('Gaussian noise in %d cadences, using %d transits\n', DATA_LENGTH, numTransits);
    fprintf('False alarm = %1.2e\n\n\n', dvResultsStruct.targetResultsStruct.planetResultsStruct.planetCandidate.significance);

    originalFileName = 'target-000000123/planet-01/bootstrap-results/000000123-01-bootstrap-false-alarm.fig';
    newFileName = ['target-000000123/planet-01/bootstrap-results/000000123-01-bootstrap-false-alarm-gaussianNoise-3500Cadences-3TrialPulses' num2str(numTransits) 'Transits.fig'];

    if exist(originalFileName, 'file')
        open(originalFileName);
        set(gcf, 'name', sprintf('%dCadences%dTransits3TrialPulses', ...
            DATA_LENGTH, num2str(numTransits)));
        saveas(gcf, newFileName);
        delete(originalFileName);
    end
   
end

% Plot residual SES
    originalFileName2  = 'target-000000123/planet-01/summary-plots/000000123-00-residual-SES.fig';
    newFileName2 = 'target-000000123/planet-01/summary-plots/000000123-00-residual-SES-gaussianNoise-3500Cadences-3TrialPulse.fig';
    
    if exist(originalFileName2, 'file')
        open(originalFileName2);
        set(gcf, 'name', sprintf('Residual SES %dCadences 3TrialPulse', DATA_LENGTH));
        saveas(gcf, newFileName2);
        delete(originalFileName2);
    end

clear dvDataObject;

% %% Create gaussian noise in 1 year's worth of data using 3 pulses
% DATA_LENGTH = 3500*4;
% dvDataStruct.gapFillConfigurationStruct.cadenceDurationInMinutes = DATA_LENGTH*30;
% dvResultsStruct.targetResultsStruct.residualFluxTimeSeries.values = randn(DATA_LENGTH, 1);
% dvResultsStruct.targetResultsStruct.residualFluxTimeSeries.uncertainties = zeros(DATA_LENGTH, 1);
% 
% % Instantitate dvDataObject
% dvDataObject = dvDataClass(dvDataStruct);
% 
% % Call tps
% [TCE SES] = call_tps_from_dv(dvDataObject, dvResultsStruct, 1); %#ok<ASGLU>
% 
% % Populate dvResultsStruct with SES
% dvResultsStruct.targetResultsStruct.singleEventStatistics = SES;
% 
% for numTransits = 3:5
%     
%     fprintf('\n\n Testing 1 year''s worth of data, 3 trial transit pulses, %d transits\n\n', numTransits);
%     
%     % Set observed TransitCount
%     dvResultsStruct.targetResultsStruct.planetResultsStruct.planetCandidate.observedTransitCount = numTransits;
% 
%     % Call bootstrap
%     dvResultsStruct = perform_dv_bootstrap(dvDataObject, dvResultsStruct);
% 
%     % Check false alarm
%     fprintf('Gaussian noise in 14000 cadences, using %d transits\n',numTransits);
%     fprintf('False alarm = %1.2e\n\n\n', dvResultsStruct.targetResultsStruct.planetResultsStruct.planetCandidate.significance);
% 
%     originalFileName = 'target-000000123/planet-01/bootstrap-results/000000123-01-bootstrap-false-alarm.fig';
%     newFileName = ['target-000000123/planet-01/bootstrap-results/000000123-01-bootstrap-false-alarm-gaussianNoise-14000Cadences-3TrialPulses' num2str(numTransits) 'Transits.fig'];
% 
%     if exist(originalFileName, 'file')
%         open(originalFileName);
%         set(gcf, 'name', ['14000Cadences', num2str(numTransits), 'Transits', '3TrialPulses']);
%         saveas(gcf, newFileName);
%         delete(originalFileName);
%     end
%     
% end
% 
% % Plot residual SES
% originalFileName2  = 'target-000000123/planet-01/summary-plots/000000123-00-residual-SES.fig';
% newFileName2 = 'target-000000123/planet-01/summary-plots/000000123-00-residual-SES-gaussianNoise-14000Cadences-3TrialPulse.fig';
% 
% if exist(originalFileName2, 'file')
%     open(originalFileName2);
%     set(gcf, 'name', 'Residual SES 14000Cadences 3TrialPulse');
%     saveas(gcf, newFileName2);
%     delete(originalFileName2);
% end
% 
% clear dvDataObject

%% Create gaussian noise in 1 quarter's worth of data using only 1 pulse
dvDataStruct.gapFillConfigurationStruct.cadenceDurationInMinutes = DATA_LENGTH*30;
dvResultsStruct.targetResultsStruct.residualFluxTimeSeries.values = randn(DATA_LENGTH, 1);
dvResultsStruct.targetResultsStruct.residualFluxTimeSeries.uncertainties = zeros(DATA_LENGTH, 1);

% Change input to 1 trial transit pulse
dvDataStruct.tpsConfigurationStruct.requiredTrialTransitPulseInHours = 3; % only 1 trial pulse, so there is no averaging of histograms
dvDataStruct.tpsConfigurationStruct.storeCdppFlag = true; % only 1 trial pulse, so there is no averaging of histograms

% Instantitate dvDataObject
dvDataObject = dvDataClass(dvDataStruct);

% Call tps
[TCE SES] = call_tps_from_dv(dvDataObject, dvResultsStruct, 1); %#ok<ASGLU>

% Populate dvResultsStruct with SES
dvResultsStruct.targetResultsStruct.singleEventStatistics = SES;

for numTransits = 4:6
    
    fprintf('\n\n Testing 1 quarter''s worth of data, 1 trial transit pulse, %d transits\n\n', numTransits);
    
    % Set observed TransitCount
    dvResultsStruct.targetResultsStruct.planetResultsStruct.planetCandidate.observedTransitCount = numTransits;

    % Call bootstrap
    dvResultsStruct = perform_dv_bootstrap(dvDataObject, dvResultsStruct);

    % Check false alarm
    fprintf('Gaussian noise in %d cadences, using %d transits\n', DATA_LENGTH, numTransits);
    fprintf('False alarm = %1.2e\n\n\n', dvResultsStruct.targetResultsStruct.planetResultsStruct.planetCandidate.significance);

    originalFileName = 'target-000000123/planet-01/bootstrap-results/000000123-01-bootstrap-false-alarm.fig';
    newFileName = ['target-000000123/planet-01/bootstrap-results/000000123-01-bootstrap-false-alarm-gaussianNoise-3500Cadences-1TrialPulse' num2str(numTransits) 'Transits.fig'];

    if exist(originalFileName, 'file')
        open(originalFileName);
        set(gcf, 'name', sprintf('%dCadences%dTransits1TrialPulse', ...
            DATA_LENGTH, num2str(numTransits)));
        saveas(gcf, newFileName);
        delete(originalFileName);
    end
    
end

% Plot residual SES
originalFileName2  = 'target-000000123/planet-01/summary-plots/000000123-00-residual-SES.fig';
newFileName2 = 'target-000000123/planet-01/summary-plots/000000123-00-residual-SES-gaussianNoise-3500Cadences-1TrialPulse.fig';

if exist(originalFileName2, 'file')
    open(originalFileName2);
    set(gcf, 'name', sprintf('Residual SES %dCadences 1TrialPulse', DATA_LENGTH));
    saveas(gcf, newFileName2);
    delete(originalFileName2);
end

clear dvDataObject;

% %% Now test 1 year's worth of data using only 1 trial transit pulse
% DATA_LENGTH = 3500*4;
% dvDataStruct.gapFillConfigurationStruct.cadenceDurationInMinutes = DATA_LENGTH*30;
% dvResultsStruct.targetResultsStruct.residualFluxTimeSeries.values = randn(DATA_LENGTH, 1);
% dvResultsStruct.targetResultsStruct.residualFluxTimeSeries.uncertainties = zeros(DATA_LENGTH, 1);
% 
% % Instantitate dvDataObject
% dvDataObject = dvDataClass(dvDataStruct);
% 
% % Call tps
% [TCE SES] = call_tps_from_dv(dvDataObject, dvResultsStruct, 1); %#ok<ASGLU>
% 
% % Populate dvResultsStruct with SES
% dvResultsStruct.targetResultsStruct.singleEventStatistics = SES;
% 
% for numTransits = 3:5
%     
%     fprintf('\n\n Testing 1 year''s worth of data, 1 trial transit pulse, %d transits\n\n', numTransits);
%     
%     % Set observed TransitCount
%     dvResultsStruct.targetResultsStruct.planetResultsStruct.planetCandidate.observedTransitCount = numTransits;
% 
%     % Call bootstrap
%     dvResultsStruct = perform_dv_bootstrap(dvDataObject, dvResultsStruct);
% 
%     % Check false alarm
%     fprintf('Gaussian noise in 14000 cadences, using %d transits\n\n\n',numTransits);
%     fprintf('False alarm = %1.2e\n', dvResultsStruct.targetResultsStruct.planetResultsStruct.planetCandidate.significance);
% 
%     originalFileName = 'target-000000123/planet-01/bootstrap-results/000000123-01-bootstrap-false-alarm.fig';
%     newFileName = ['target-000000123/planet-01/bootstrap-results/000000123-01-bootstrap-false-alarm-gaussianNoise-14000Cadences-1TrialPulse' num2str(numTransits) 'Transits.fig'];
% 
%     if exist(originalFileName, 'file')
%         open(originalFileName);
%         set(gcf, 'name', ['14000Cadences', num2str(numTransits), 'Transits', '1TrialPulse']);
%         saveas(gcf, newFileName);
%         delete(originalFileName);
%     end
%     
% 
% end
% 
% % Plot residual SES
% originalFileName2  = 'target-000000123/planet-01/summary-plots/000000123-00-residual-SES.fig';
% newFileName2 = 'target-000000123/planet-01/summary-plots/000000123-00-residual-SES-gaussianNoise-14000Cadences-1TrialPulse.fig';
% 
% if exist(originalFileName2, 'file')
%     open(originalFileName2);
%     set(gcf, 'name', 'Residual SES 14000Cadences 1TrialPulse');
%     saveas(gcf, newFileName2);
%     delete(originalFileName2);
% end

%% Clean up.
rmpath(testDataRoot);
rmpath(dvTestDataRoot);

return
