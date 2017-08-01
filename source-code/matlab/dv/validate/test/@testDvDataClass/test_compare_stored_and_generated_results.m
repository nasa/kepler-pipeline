function [self] = test_compare_stored_and_generated_results(self)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [self] = test_compare_stored_and_generated_results(self)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% This test loads stored verified results and compares the generated results 
% with the verified results.
%
% If the regression test fails, an error condition occurs.
%
%  Example
%  =======
%  Use a test runner to run the test method:
%      run(text_test_runner, testDvDataClass('test_compare_stored_and_generated_results'));
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

% Define path and file names.
initialize_soc_variables;
path = ...
    [socTestDataRoot filesep 'dv' filesep 'unit-tests' filesep 'dv-matlab-controller'];

matFileName = 'dvInputs.mat';
resultsFileName = 'dvResultsStruct.mat';

cadsFileName = 'dv_cads.mat';
limbDarkeningFileName = 'atlasNonlinearLimbDarkeningData.mat';
fitResultFileName = 'fitResult_*';
trapezoidalFitFileName = 'trapezoidalFit_*';
postFitFileName = 'dv_post_fit_workspace.mat';
randFileName = 'dv_rand.mat';
outputMatrixFileName = 'dvOutputMatrixTarget.mat';
tpsDawgFileName = 'tps-task-file-dawg-struct-dv.mat';

pixelDataDirName = 'pixelData';

fullMatFileName = [path '/' matFileName];
fullResultsFileName = [path '/' resultsFileName];

% Load a previously generated test data structure dvDataStruct.
load(fullMatFileName, 'dvDataStruct');

% Update spiceFileDir.
dvDataStruct.raDec2PixModel.spiceFileDir = fullfile(socTestDataRoot, 'fc', 'spice');

% Add path so blobs can be found.
addpath(path);

% Load saved dvResultsStruct.
load(fullResultsFileName, 'dvResultsStruct');

% Generate a test results structure.
[testDvResultsStruct] = dv_matlab_controller(dvDataStruct);

% Clean up.
delete(cadsFileName);
delete(limbDarkeningFileName);
delete(fitResultFileName);
delete(trapezoidalFitFileName);
delete(postFitFileName);
delete(randFileName);
delete(outputMatrixFileName);
delete(tpsDawgFileName);

rmdir(pixelDataDirName, 's');
for iTarget = 1 : length(testDvResultsStruct.targetResultsStruct)
    rmdir(testDvResultsStruct.targetResultsStruct(iTarget).dvFiguresRootDirectory, 's');
end

% Since dvResultsStruct.alerts have changing timestamps (and strings),
% remove this field before comparing.
dvResultsStruct = rmfield(dvResultsStruct, 'alerts');                                        %#ok<NODEF>
testDvResultsStruct = rmfield(testDvResultsStruct, 'alerts');

% Compare the test and stored results at single precision.
messageOut = ...
    'Regression test failed - stored results and generated results are not identical!';
assert_equals(convert_struct_fields_to_float(testDvResultsStruct), convert_struct_fields_to_float(dvResultsStruct), messageOut);

% Return.
return
