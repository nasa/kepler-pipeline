function self = test_main_requantization_table_step_size(self)
% test_main_requantization_table_step_size checks to see whether all the entries in the table
% 'requantizationMainTableVerifyFraction'  are <= quantizationFraction.
%
%  Example
%  =======
%  Use a test runner to run the test method:
%         Example: run(text_test_runner, testRequantizationTableClass('test_main_requantization_table_step_size'));
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

% Set path to unit test inputs.
initialize_soc_variables;
path = fullfile(socTestDataRoot, 'gar', 'unit-tests', 'requantization');

load(fullfile(path, 'requantizationRegressionTest.mat'));

requantizationTableObjet = requantizationTableClass(requantizationInputStruct);

requantizationOutputStruct = generate_requantization_table(requantizationTableObjet);


% This test checks to see whether all the entries in the table
% 'requantizationMainTableVerifyFraction'  are <= quantizationFraction
% quantization noise has to be <= ("quantizationFraction" X total noise stdev)
quantizationFraction = requantizationOutputStruct.requantizationMainStruct.quantizationFraction;

verifyTable = requantizationOutputStruct.requantizationMainTableVerifyFraction;

% All values in the verifyTable should be between 0 and quantizationFraction. Find any value that
% is not within this range (=> indicates invalid requantization table)
testResult = (verifyTable < 0 | verifyTable > quantizationFraction);

if(~any(testResult)) % all zeros
    testResult = 0; % just a scalar to indicate that all entries are okay
end;

% we expect all the entries in the main requantization table have a stepsize
% <= quantizationFraction which guarantees that the table maintains at each
% step the ratio of quantization noise to total noise at <= quantizationFraction
expectedResult = 0;

% you can only check whether the indices are equal
messageOut = 'This test checks to see whether the main requantization table maintains the desired ratio of quantization noise to total noise at all intervals.';
assert_equals(expectedResult, testResult, messageOut);

return


