%% test_manual_skip_count
%
% function [self] = test_manual_skip_count(self)
%
% Tests that if bootstrapAutoSkipCount is disabled, bootstrap will proceed
% to build  histogram using the bootstrapSkipCount specified in 
% module parameters.
%
% Run with:
%   run(text_test_runner, testBootstrapClass('test_manual_skip_count'));
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
function [self] = test_manual_skip_count(self)

fprintf('\nTesting manual skip counts on bootstrap...\n')

% TODO Update test data, which is sorely out of date, and remove this guard
% clause
if (true)
    fprintf('SKIPPING TEST. TEST DATA TOO FAR OUT OF DATE.\n');
    return;
end

% Add paths for test-data
initialize_soc_variables;
testDataRoot = fullfile(socTestDataRoot, 'dv', 'unit-tests', 'bootstrap');
addpath(testDataRoot);

% load mat file with dvDataObject and dvResultsStruct of tgt8012281
load 'bootstrapInputs.mat';

% TODO Delete if test data updated.
dvDataObject = dv_convert_62_data_to_70(dvDataObject); %#ok<NODEF>

% Make object to struct to alter bootstrapSkipCount
dvDataStruct = struct(dvDataObject);

% Turn autoSkipcount off and make default skipCount to 100.
dvDataStruct.bootstrapConfigurationStruct.autoSkipCountEnabled = false;
dvDataStruct.bootstrapConfigurationStruct.skipCount = 100;
dvDataObject = dvDataClass(dvDataStruct);

% Create directories
dvResultsStruct = create_directories_for_dv_figures(dvDataObject, dvResultsStruct); %#ok<NODEF>

% Perform bootstrap
dvResultsStruct = perform_dv_bootstrap(dvDataObject, dvResultsStruct); 
significance_100skip = dvResultsStruct.targetResultsStruct.planetResultsStruct.planetCandidate.significance;
fprintf('significance using 100 skipCount = %1.4e\n', significance_100skip)

% Check that the skipCount was 100
skipCountNew = dvResultsStruct.targetResultsStruct.planetResultsStruct.planetCandidate.bootstrapHistogram.finalSkipCount;
messageOut = 'skipcount: expected: 100 but was: %d';
assert_equals(skipCountNew, 100, sprintf(messageOut, skipCountNew));

% Change skipCount to 50
dvDataStruct.bootstrapConfigurationStruct.skipCount = 50;
dvDataObject = dvDataClass(dvDataStruct);
dvResultsStruct = perform_dv_bootstrap(dvDataObject, dvResultsStruct); 
significance_50skip = dvResultsStruct.targetResultsStruct.planetResultsStruct.planetCandidate.significance;
fprintf('significance using 50 skipCount = %1.4e\n', significance_50skip)
skipCountNew = dvResultsStruct.targetResultsStruct.planetResultsStruct.planetCandidate.bootstrapHistogram.finalSkipCount;
messageOut = 'skipcount: expected: 50 but was: %d';
assert_equals(skipCountNew, 50, sprintf(messageOut, skipCountNew));

% Change skipCount to 25
dvDataStruct.bootstrapConfigurationStruct.skipCount = 25;
dvDataObject = dvDataClass(dvDataStruct);
dvResultsStruct = perform_dv_bootstrap(dvDataObject, dvResultsStruct); 
significance_25skip = dvResultsStruct.targetResultsStruct.planetResultsStruct.planetCandidate.significance;
fprintf('significance using 25 skipCount = %1.4e\n', significance_25skip)
skipCountNew = dvResultsStruct.targetResultsStruct.planetResultsStruct.planetCandidate.bootstrapHistogram.finalSkipCount;
messageOut = 'skipcount: expected: 25 but was: %d';
assert_equals(skipCountNew, 25, sprintf(messageOut, skipCountNew));

% Change skipCount to 13
dvDataStruct.bootstrapConfigurationStruct.skipCount = 13;
dvDataObject = dvDataClass(dvDataStruct);
dvResultsStruct = perform_dv_bootstrap(dvDataObject, dvResultsStruct); 
significance_13skip = dvResultsStruct.targetResultsStruct.planetResultsStruct.planetCandidate.significance;
fprintf('significance using 13 skipCount = %1.4e\n', significance_13skip)
skipCountNew = dvResultsStruct.targetResultsStruct.planetResultsStruct.planetCandidate.bootstrapHistogram.finalSkipCount;
messageOut = 'skipcount: expected: 13 but was: %d';
assert_equals(skipCountNew, 13, sprintf(messageOut, skipCountNew));

% Max skip count can be is ceil(lengthSES/2-1)
lengthSES =  length(dvResultsStruct.targetResultsStruct.singleEventStatistics(1).correlationTimeSeries.values);
dvDataStruct.bootstrapConfigurationStruct.skipCount = ceil(lengthSES/2-1);
dvDataObject = dvDataClass(dvDataStruct);
dvResultsStruct = perform_dv_bootstrap(dvDataObject, dvResultsStruct); 
significance_maxskip = dvResultsStruct.targetResultsStruct.planetResultsStruct.planetCandidate.significance;
fprintf('significance using skipCount %d = %1.4e\n', ceil(lengthSES/2-1), significance_maxskip)
skipCountNew = dvResultsStruct.targetResultsStruct.planetResultsStruct.planetCandidate.bootstrapHistogram.finalSkipCount;
messageOut = 'skipcount: expected: ceil(lengthSES/2-1) == %d but was: %d';
assert_equals(skipCountNew, ceil(lengthSES/2-1), sprintf(messageOut, ceil(lengthSES/2-1), skipCountNew));

% Plot significance vs. skipCount
skipCount =  [13 25 50 100 ceil(lengthSES/2-1)];
significance = [ significance_13skip, ...
 significance_25skip, ...
 significance_50skip, ...
 significance_100skip, ...
 significance_maxskip];

figure;
semilogy(skipCount, significance, '-o');
xlabel('skipCount');
ylabel('significance');
grid on;
box on;
format_graphics_for_dv_report(gcf);
close;

rmpath(testDataRoot);

return