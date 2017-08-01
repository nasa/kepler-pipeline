function [self] = test_pa_matlab_controller(self)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [self] = test_pa_matlab_controller(self)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% This test loads previously generated PA input data structures (first
% invocation for background, second invocation for targets) and then compares
% those structures with others obtained by writing and reading binary files.
%
% After generating PA results structures with the pa_matlab_controller,
% this test also compares those structures with others obtained by writing
% and reading binary files.
%
% paDataStruct =
%                         ccdModule: [int]  CCD module number
%                         ccdOutput: [int]  CCD output number
%                    cadenceType: [string]  'LONG' or 'SHORT'
%                      startCadence: [int]  start cadence index
%                        endCadence: [int]  end cadence index
%                     firstCall: [logical]  true if first PA science call
%                      lastCall: [logical]  true if last PA science call
%                    fcConstants: [struct]  Fc constants
%      spacecraftConfigMap: [struct array]  one or more spacecraft config maps
%                   cadenceTimes: [struct]  cadence times and gap indicators
%               longCadenceTimes: [struct]  long cadence times and gap indicators
%                                           for attitude solution
%          paConfigurationStruct: [struct]  module parameters for PA science
% oapAncillaryEngineeringConfigurationStruct:
%                                 [struct]  module parameters for engineering data
%    ancillaryPipelineConfigurationStruct:
%                                 [struct]  module parameters for pipeline data
%    ancillaryAttitudeConfigurationStruct:
%                                 [struct]  module parameters for attitude solution
%  backgroundConfigurationStruct: [struct]  module parameters for background 
%                                           estimation
%      motionConfigurationStruct: [struct]  module parameters for motion polynomials 
%   encircledEnergyConfigurationStruct: 
%                                 [struct]  encircled energy parameters
%     gapFillConfigurationStruct: [struct]  gap fill parameters
%         pouConfigurationStruct: [struct]  POU parameters
%       ancillaryEngineeringDataStruct: 
%                           [struct array]  engineering data for OAP
%          ancillaryPipelineDataStruct: 
%                           [struct array]  pipeline data for OAP
%         attitudeSolutionStruct: [struct]  attitude solution from PPA for OAP
%     backgroundDataStruct: [struct array]  background pixels
%     targetStarDataStruct: [struct array]  target pixels
%                       prfModel: [struct]  pixel response function model
%           backgroundBlobs: [blob series]  background polynomials for short cadence PA
%               motionBlobs: [blob series]  motion polynomials for short cadence PA
%       calUncertaintyBlobs: [blob series]  input primitives and transformations
%                                           from CAL
%
% paResultsStruct =
%                         ccdModule: [int]  CCD module number
%                         ccdOutput: [int]  CCD output number
%                    cadenceType: [string]  'LONG' or 'SHORT'
%                      startCadence: [int]  start cadence index
%                        endCadence: [int]  end cadence index
%  targetStarResultsStruct: [struct array]  target flux time series
%            backgroundCosmicRayEvents:
%                           [struct array]  background CR events
%     backgroundCosmicRayMetrics: [struct]  background CR metrics
%            targetStarCosmicRayEvents: 
%                           [struct array]  target CR events
%     targetStarCosmicRayMetrics: [struct]  target CR metrics
%         encircledEnergyMetrics: [struct]  encircled energy time series
%              brightnessMetrics: [struct]  brightness metric time series
%                badPixels: [struct array]  bad pixels
%         backgroundBlobFileName: [string]  background fit coefficients (file name)
%             motionBlobFileName: [string]  motion polynomials (file name)
%        uncertaintyBlobFileName: [string]  output primitives and transformations (file name)
%                   alerts: [struct array]  module alert(s)
%
%
% If the regression test fails, an error condition occurs.
%
%  Example
%  =======
%  Use a test runner to run the test method:
%      run(text_test_runner, testPaDataClass('test_pa_matlab_controller'));
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

% Define files and figures to be deleted after running matlab controller.
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

% Load previously generated test data.
load(fullfile(paTestDataDir, 'PaInputs.mat'));

% Load and update the fcConstants.
load(fullfile(paTestDataDir, 'fcConstants.mat'));
paDataStruct0.fcConstants = fcConstants;
paDataStruct1.fcConstants = fcConstants;

% Perform quick flux-weighted centroiding as this is not a regression test.
paDataStruct0.paConfigurationStruct.ppaTargetPrfCentroidingEnabled = false;
paDataStruct0.paConfigurationStruct.targetPrfCentroidingEnabled = false;
paDataStruct1.paConfigurationStruct.ppaTargetPrfCentroidingEnabled = false;
paDataStruct1.paConfigurationStruct.targetPrfCentroidingEnabled = false;

% Write to, and read from, auto-generated scripts for input.
inputFileName0 = 'inputs-0.bin';
write_PaInputs(inputFileName0, paDataStruct0);
[paDataStructNew0] = read_PaInputs(inputFileName0);
delete(inputFileName0);

inputFileName1 = 'inputs-1.bin';
write_PaInputs(inputFileName1, paDataStruct1);
[paDataStructNew1] = read_PaInputs(inputFileName1);
delete(inputFileName1);

% Convert to floats for assert equals test. Make sure that empty background
% and target input structures do not cause the test to fail.
[paDataStruct0] = convert_struct_fields_to_float(paDataStruct0);
[paDataStructNew0] = convert_struct_fields_to_float(paDataStructNew0);

[paDataStruct1] = convert_struct_fields_to_float(paDataStruct1);
[paDataStructNew1] = convert_struct_fields_to_float(paDataStructNew1);

if isempty(paDataStruct0.targetStarDataStruct)
    paDataStruct0.targetStarDataStruct = [];
end

if isempty(paDataStruct1.backgroundDataStruct)
    paDataStruct1.backgroundDataStruct = [];
end

% Compare structures that are written to and read back from a bin file.
messageOut = 'pa_matlab_controller - data loaded and read back by read_PaInputs are not identical!';
assert_equals(paDataStructNew0, paDataStruct0, messageOut);

messageOut = 'pa_matlab_controller - data loaded and read back by read_PaInputs are not identical!';
assert_equals(paDataStructNew1, paDataStruct1, messageOut);

clear paDataStruct0 paDataStruct1

%--------------------------------------------------------------------------
% Generate output test data and clean up PA mat files and figures.
%--------------------------------------------------------------------------
[paResultsStruct0] = pa_matlab_controller(paDataStructNew0);
[paResultsStruct1] = pa_matlab_controller(paDataStructNew1);

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

clear paDataStructNew0 paDataStructNew1
close all

% Write to, and read from, auto-generated scripts for output.
outputFileName0 = 'outputs-0.bin';
write_PaOutputs(outputFileName0, paResultsStruct0);
[paResultsStructNew0] = read_PaOutputs(outputFileName0);
delete(outputFileName0);

outputFileName1 = 'outputs-1.bin';
write_PaOutputs(outputFileName1, paResultsStruct1);
[paResultsStructNew1] = read_PaOutputs(outputFileName1);
delete(outputFileName1);

% Convert to floats for assert equals test.
[paResultsStruct0] = convert_struct_fields_to_float(paResultsStruct0);
[paResultsStructNew0] = convert_struct_fields_to_float(paResultsStructNew0);

[paResultsStruct1] = convert_struct_fields_to_float(paResultsStruct1);
[paResultsStructNew1] = convert_struct_fields_to_float(paResultsStructNew1);

% Compare structures that are written to and read back from a bin file.
messageOut = 'pa_matlab_controller - results received and read back by read_PaOutputs are not identical!';
assert_equals(paResultsStruct0, paResultsStructNew0, messageOut);

messageOut = 'pa_matlab_controller - results received and read back by read_PaOutputs are not identical!';
assert_equals(paResultsStruct1, paResultsStructNew1, messageOut);

rmpath(paTestDataDir);

% Return.
return
