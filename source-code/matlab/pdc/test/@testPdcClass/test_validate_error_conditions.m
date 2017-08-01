function [self] = test_validate_error_conditions(self)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [self] = test_validate_error_conditions(self)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% This test validates that pdc error conditions are properly caught. The
% following error conditions are tested:
%
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

%
%  Example
%  =======
%  Use a test runner to run the test method:
%      run(text_test_runner, testPdcClass('test_validate_error_conditions'));
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

initialize_soc_variables;
pdcTestDataDir = fullfile(socTestDataRoot, 'pdc', 'unit-tests', 'pdc-matlab-46-6550');

% Generate an input structure by one of the following methods:

% ---->> NOT provided <<----------
% (1) Create an input structure pdcDataStruct
% [pdcDataStruct] = generate_pdc_test_data;

% (2a) Load a previously generated test data structure pdcDataStruct
load(fullfile(pdcTestDataDir, 'pdc-inputs-0.mat'));

% (2b) Read a test data structure pdcDataStruct from a previously
%     generated bin file
% [pdcDataStruct] = read_PdcInputs(fullfile(pdcTestDataDir, 'pdc-inputs-0.bin'));

pdcInputDataStruct = inputsStruct;
clear inputsStruct;
% trim the number of targets 
pdcInputDataStruct.targetDataStruct = pdcInputDataStruct.targetDataStruct(1:10);

% Save the original pdc data structure.
originalPdcInputDataStruct = pdcInputDataStruct;

% Test for unmatched model orders.
pdcInputDataStruct = originalPdcInputDataStruct;
pdcInputDataStruct.ancillaryAttitudeConfigurationStruct.modelOrders(1) = 2;
pdcInputDataStruct.ancillaryAttitudeConfigurationStruct.modelOrders(2) = 3;
pdcInputDataStruct.ancillaryAttitudeConfigurationStruct.modelOrders(3) = 4;

try_to_catch_error_condition('pdc_matlab_controller(pdcInputDataStruct)', ...
    'invalidInteractionDefinition', pdcInputDataStruct, 'pdcInputDataStruct');
fprintf('\n');

% Test for model orders less than 2
pdcInputDataStruct = originalPdcInputDataStruct;

pdcInputDataStruct.ancillaryAttitudeConfigurationStruct.modelOrders(1) = 1;
pdcInputDataStruct.ancillaryAttitudeConfigurationStruct.modelOrders(2) = 1;
pdcInputDataStruct.ancillaryAttitudeConfigurationStruct.modelOrders(3) = 1;

try_to_catch_error_condition('pdc_matlab_controller(pdcInputDataStruct)', ...
    'invalidInteractionDefinition', pdcInputDataStruct, 'pdcInputDataStruct');
fprintf('\n');

% Return.
return
