%% test_bootstrap_using_fitter_data_beb_etem
%
% function [self] = test_bootstrap_using_fitter_data_beb_etem(self)
%
% Tests bootstrap on a background eclipsing binary that triggers a TCE in 
% DV.  ETEM ground thruth is a background  eclipsing binary. 'Transit-free' 
% SES has been pre-generated from the fitter and tps caller.
% 
% Run with:
%   run(text_test_runner, testBootstrapClass('test_bootstrap_using_fitter_data_beb_etem'));
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
function [self] = test_bootstrap_using_fitter_data_beb_etem(self)

fprintf('\nTesting bootstrap with background eclipsing binary data from ETEM.\n')
fprintf('Folder being in created in the current directory:  target-005097847\n')

initialize_soc_variables;
testDataRoot = fullfile(socTestDataRoot, 'dv', 'unit-tests', 'bootstrap');
dvTestDataRoot = fullfile(socTestDataRoot, 'dv', 'unit-tests', 'dv-matlab-controller');
addpath(testDataRoot);
addpath(dvTestDataRoot);

% Load dvDataStruct_target5097847_etem_BEB and dvResultsStruct_target5097847_etem_beb
load('bootstrap_etem_beb.mat');

% TODO Delete if test data updated.
dvDataStruct_target5097847_etem_BEB = dv_convert_62_data_to_70(dvDataStruct_target5097847_etem_BEB); %#ok<NODEF>

% Update spiceFileDirectory (in the dv-matlab-controller folder)
dvDataStruct_target5097847_etem_BEB.raDec2PixModel.spiceFileDir = fullfile(socTestDataRoot, 'fc', 'spice');

% Instantiate dvDataObject
dvDataStruct_target5097847_etem_BEB = update_dv_inputs(dvDataStruct_target5097847_etem_BEB);
dvDataStruct_target5097847_etem_BEB.dvCadenceTimes = estimate_timestamps(dvDataStruct_target5097847_etem_BEB.dvCadenceTimes);
dvDataStruct_target5097847_etem_BEB = compute_barycentric_corrected_timestamps(dvDataStruct_target5097847_etem_BEB);
dvDataObject_target5097847_etem_BEB = dvDataClass(dvDataStruct_target5097847_etem_BEB);

% Create directory for figure
dvResultsStruct_target5097847_etem_beb = create_directories_for_dv_figures(dvDataObject_target5097847_etem_BEB, dvResultsStruct_target5097847_etem_beb); %#ok<NODEF>

% Perform bootstrap
dvResultsStruct_target5097847_etem_beb = perform_dv_bootstrap(dvDataObject_target5097847_etem_BEB, dvResultsStruct_target5097847_etem_beb);
fprintf('\n\nPlanet 1: False alarm using etem background eclipsing binary = %1.2e\n', dvResultsStruct_target5097847_etem_beb.targetResultsStruct.planetResultsStruct(1).planetCandidate.significance);
fprintf('This compares to %1.2e if the noise were to be gaussian with unit variance.\n', 0.5*erfc(7.1./sqrt(2)));
filename1 = 'target-005097847/planet-01/bootstrap-results/005097847-01-bootstrap-false-alarm.fig';
if exist(filename1, 'file')
    open(filename1);
end

fprintf('\n\nPlanet 2: False alarm using etem background eclipsing binary = %1.2e\n', dvResultsStruct_target5097847_etem_beb.targetResultsStruct.planetResultsStruct(2).planetCandidate.significance);
fprintf('This compares to %1.2e if the noise were to be gaussian with unit variance.\n', 0.5*erfc(7.1./sqrt(2)));
filename2 = 'target-005097847/planet-02/bootstrap-results/005097847-02-bootstrap-false-alarm.fig';
if exist(filename2, 'file')
    open(filename2);
end

rmpath(testDataRoot);
rmpath(dvTestDataRoot);

return
