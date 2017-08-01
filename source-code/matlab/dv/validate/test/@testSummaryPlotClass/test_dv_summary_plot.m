%% test_dv_summary_plot
% function [self] = test_dv_summary_plot(self)
%
% This test tests that the summary plots are created by
% generate_flux_time_series_and_transits_plots.  
%
% Use a test runner to run the test method:
%   run(text_test_runner, testSummaryPlotClass('test_dv_summary_plot'));
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
function self = test_dv_summary_plot(self)

initialize_soc_variables;
testDataDir = fullfile(socTestDataRoot, 'dv', 'unit-tests', 'summaryPlot');
addpath(testDataDir);

load('dv-inputs-0.mat');
dvDataStruct = inputsStruct;

load('dv-outputs-0.mat');
dvResultsStruct = outputsStruct;

nTargets = length(dvResultsStruct.targetResultsStruct);
for iTarget = 1:nTargets
    targetName = dvResultsStruct.targetResultsStruct(iTarget).dvFiguresRootDirectory;
    mkdir(fullfile(targetName, 'summary-plots'));
end

display(' ');
display('Test DV:SummaryPlot: test_dv_summary_plot');
display(' ');

% Update spiceFileDir
dvDataStruct.raDec2PixModel.spiceFileDir = fullfile(socTestDataRoot, 'fc', 'spice');

% Update the DV data structure. Convert blobs to structs. Attach these
% structures to the input data struct. Remove blobs from input data struct.
display('dv_matlab_controller: updating dv inputs...');
[dvDataStruct] = update_dv_inputs(dvDataStruct);

% Estimate the gapped cadence timestamps and update the DV data structure.
display('dv_matlab_controller: estimating values for gapped cadence timestamps...');
[dvDataStruct.dvCadenceTimes] = estimate_timestamps(dvDataStruct.dvCadenceTimes);

% Compute the barycentric corrected cadence times and append them to the DV
% data structure.
display('dv_matlab_controller: computing barycentric corrected timestamps...');
[dvDataStruct] = compute_barycentric_corrected_timestamps(dvDataStruct);

% Instantiate a dvDataClass object.
display('dv_matlab_controller: instantiating dv data object...');
[dvDataObject] = dvDataClass(dvDataStruct);

display('data_validation: normalizing and quarter stitching flux time series with harmonic content...');
useHarmonicFreeCorrectedFlux = true;
[normalizedFluxTimeSeriesArray] = ...
    perform_dv_flux_normalization(dvDataObject, useHarmonicFreeCorrectedFlux);
for iTarget=1:nTargets
    [dvResultsStruct] = generate_flux_time_series_and_transits_plots(...
        dvDataObject, dvResultsStruct, iTarget, useHarmonicFreeCorrectedFlux, ...
        normalizedFluxTimeSeriesArray);
end

messageOut = 'Test failed - Could not find summary plot at %s';

for iTarget=1:nTargets
    keplerId = dvResultsStruct.targetResultsStruct(iTarget).keplerId;
    targetName = dvResultsStruct.targetResultsStruct(iTarget).dvFiguresRootDirectory;
    targetTableData = dvDataStruct.targetTableDataStruct;
    filename = fullfile(targetName, 'summary-plots', ...
        sprintf('%09d-00-flux-harmonics-free-tps-%02d-%03d.fig', ...
        keplerId, targetTableData.quarter, targetTableData.targetTableId));
    if (~exist(filename, 'file'))
        assert_equals(1, 0, sprintf(messageOut, filename));
    end
    filename = fullfile(targetName, 'summary-plots', ...
        sprintf('%09d-00-flux-harmonics-free-dv-fit-%02d-%03d.fig', ...
        keplerId, targetTableData.quarter, targetTableData.targetTableId));
    if (~exist(filename, 'file'))
        assert_equals(1, 0, sprintf(messageOut, filename));
    end
    filename = fullfile(targetName, 'summary-plots', ...
        sprintf('%09d-00-raw-flux-%02d-%03d.fig', ...
        keplerId, targetTableData.quarter, targetTableData.targetTableId));
    if (~exist(filename, 'file'))
        assert_equals(1, 0, sprintf(messageOut, filename));
    end
    rmdir(targetName, 's');
end

if exist('dv_state.mat', 'file')
    delete('dv_state.mat');
end

rmpath(testDataDir);

return

