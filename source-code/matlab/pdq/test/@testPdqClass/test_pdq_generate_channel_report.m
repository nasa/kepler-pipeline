%% test_pdq_generate_channel_report
%
% function [self] = test_pdq_generate_channel_report(self)
%
% This test validates PDQ channel report generation.
%
%  Example
%  =======
%  Use a test runner to run the test method:
%      run(text_test_runner, testPdqClass('test_pdq_generate_channel_report'));
%%
% 
% Copyright 2017 United States Government as represented by the
% Administrator of the National Aeronautics and Space Administration.
% All Rights Reserved.
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
function [self] = test_pdq_generate_channel_report(self)

tic;
fprintf('\nTesting pdq_generate_channel_report...\n')

initialize_soc_variables({'caller', 'base'});
testDataDir = fullfile(socTestDataRoot, 'pdq', 'unit-tests', 'report');
figures = fullfile(testDataDir, 'figures');
pdqDataFilename = 'reportInputs.mat';

%failed = false;

% Call the report. Safely. So we can restore the working directory
% later.
try
    fprintf('\nGenerating reports based upon %s\n', pdqDataFilename);
    
    % Load previously generated data structure.
    load(fullfile(testDataDir, pdqDataFilename));
    
    % Generate report for channel 1.
    reportFilename = pdq_generate_channel_report(pdqInputStruct, 1, figures);
    
    % Instruct user to inspect the generated reports.
    fprintf('Finished generating %s, please inspect!\n', reportFilename);
catch
    err = lasterror;
end

initialize_soc_variables({'base'}, 'clear');
toc;

% Now that we've restored the original directory, we can check for errors and
% test our assertion.
if (exist('err', 'var'))
    rethrow(err);
end
%mlunit_assert(~failed);

end
