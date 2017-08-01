function [self] = test_compare_stored_and_generated_results(self)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [self] = test_compare_stored_and_generated_results(self)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% This test loads stored verified results and compares the generated results 
% with the verified results for background and target PA invocations.
%
% If the regression test fails, an error condition occurs.
%
%  Example
%  =======
%  Use a test runner to run the test method:
%      run(text_test_runner, testPaDataClass('test_compare_stored_and_generated_results'));
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
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

initialize_soc_variables;
paTestDataDir = fullfile(socTestDataRoot, 'pa', 'unit-tests', 'r5');
addpath(paTestDataDir); % for blobs

% Define files and figures to be deleted after running PA.
paStateFileName = 'pa_state.mat';
paInputUncertaintiesFileName = 'pa_input_uncertainties.mat';
paBackgroundFileName = 'pa_background.mat';
paMotionFileName = 'pa_motion.mat';
paTempFileName = 'tempFile.mat';
paBackgroundAicFig = 'pa_background_aic.fig';
paMeanBackgroundFluxFig = 'pa_mean_background_flux.fig';
paMeanTargetFluxFig = 'pa_mean_target_flux_1.fig';
paMotionAicFig = 'pa_motion_aic.fig';
paBrightnessFig = 'pa_brightness.fig';
paEncircledEnergyFig = 'pa_encircled_energy.fig';

% Generate the input structure by one of the following methods:
% (1) Load previously generated test data structures.
load(fullfile(paTestDataDir, 'PaInputs.mat'));

% Load and update the fcConstants.
load(fullfile(paTestDataDir, 'fcConstants.mat'));
paDataStruct0.fcConstants = fcConstants;
paDataStruct1.fcConstants = fcConstants;

% Load saved results structures.
load(fullfile(paTestDataDir, 'PaOutputs.mat'));

% Run the PA matlab controller for both background and target pixels to
% obtain test results structures.
[testPaResultsStruct0] = pa_matlab_controller(paDataStruct0);
[testPaResultsStruct1] = pa_matlab_controller(paDataStruct1);

delete(paStateFileName);
delete(paInputUncertaintiesFileName);
delete(paBackgroundFileName);
delete(paMotionFileName);
delete(paTempFileName);
delete(paBackgroundAicFig);
delete(paMeanBackgroundFluxFig);
delete(paMeanTargetFluxFig);
delete(paMotionAicFig);
delete(paBrightnessFig);
delete(paEncircledEnergyFig);

clear paDataStruct0 paDataStruct1
close all

% Compare the test and stored results.
messageOut = 'Regression test failed - stored results and generated results are not identical!';
assert_equals(testPaResultsStruct0, paResultsStruct0, messageOut);

messageOut = 'Regression test failed - stored results and generated results are not identical!';
assert_equals(testPaResultsStruct1, paResultsStruct1, messageOut);

rmpath(paTestDataDir);

% Return.
return
