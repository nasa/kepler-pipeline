%% test_bootstrap_using_fitter_data_valid_tce_etem
%
% function [self] = test_bootstrap_using_fitter_data_valid_tce_etem(self)
%
% Unit test to test generated false alarm rate on a valid
% TCE.  ETEM ground thruth is an earth.  Residual single event statistics
% has been pre-generated from fitter and tps caller.
% 
% Run with:
%   run(text_test_runner, testBootstrapClass('test_bootstrap_using_fitter_data_valid_tce_etem'));
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
function [self] = test_bootstrap_using_fitter_data_valid_tce_etem(self)

fprintf('\nTesting bootstrap with valid TCE (earth) data from ETEM.\n')
fprintf('Folder being in created in the current directory:  target-005530076.\n')

initialize_soc_variables;
testDataRoot = fullfile(socTestDataRoot, 'dv', 'unit-tests', 'bootstrap');
dvTestDataRoot = fullfile(socTestDataRoot, 'dv', 'unit-tests', 'dv-matlab-controller');
addpath(testDataRoot);
addpath(dvTestDataRoot);

% Load dvDataStruct_target5530076_etem_earth and dvResultsStruct_target5530076_etem_earth
load('bootstrap_etem_earth.mat');

% TODO Delete if test data updated.
dvDataStruct_target5530076_etem_earth = dv_convert_62_data_to_70(dvDataStruct_target5530076_etem_earth); %#ok<NODEF>

% Update spiceFileDirectory (in the dv-matlab-controller folder)
dvDataStruct_target5530076_etem_earth.raDec2PixModel.spiceFileDir = fullfile(socTestDataRoot, 'fc', 'spice');

% Instantiate dvDataObject
dvDataStruct_target5530076_etem_earth = update_dv_inputs(dvDataStruct_target5530076_etem_earth);
dvDataStruct_target5530076_etem_earth.dvCadenceTimes = estimate_timestamps(dvDataStruct_target5530076_etem_earth.dvCadenceTimes);
dvDataStruct_target5530076_etem_earth = compute_barycentric_corrected_timestamps(dvDataStruct_target5530076_etem_earth);
dvDataObject_target5530076_etem_earth = dvDataClass(dvDataStruct_target5530076_etem_earth);

% Create directory for figure
dvResultsStruct_target_5530076_etem_earth = create_directories_for_dv_figures(dvDataObject_target5530076_etem_earth, dvResultsStruct_target_5530076_etem_earth); %#ok<NODEF>

% Perform bootstrap
dvResultsStructNew = perform_dv_bootstrap(dvDataObject_target5530076_etem_earth, dvResultsStruct_target_5530076_etem_earth); %#ok<NASGU>
fprintf('False alarm using etem earth = %1.2e\n', dvResultsStruct_target_5530076_etem_earth.targetResultsStruct.planetResultsStruct.planetCandidate.significance);
fprintf('This compares to %1.2e if the noise were to be gaussian with unit variance.\n', 0.5*erfc(7.1./sqrt(2)));
open('target-005530076/planet-01/bootstrap-results/005530076-01-bootstrap-false-alarm.fig');

rmpath(testDataRoot);
rmpath(dvTestDataRoot);

return
