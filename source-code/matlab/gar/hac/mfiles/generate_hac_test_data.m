function [hacDataStruct] = generate_hac_test_data()
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% [hacDataStruct] = generate_hac_test_data()
%
% Function to generate test data for Huffman histogram accumulation with HAC.
% Output is hac data structure. This is also saved to HacInputs.mat file.
% Histogram values for accumulation are obtained from ETEM results for the
% given 'run' with generate_hgn_test_data. 
%
% Results of accumulation are computed with hac_matlab_controller and saved
% to HacResults.mat file for comparison test of stored and generated results.
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


% Define (conditional) path and file names.
if ispc
    path = '\path\to\matlab\gar';
else
    path = '/path/to/matlab/gar';
end

matFileName = 'HacInputs.mat';
binFileName = 'HacInputs-0.bin';
hacResultsFileName = 'HacResults.mat';
hgnResultsFileName = 'HgnResults.mat';
hgnStateFileName = 'hgn_state.mat';

% Save the current directory.
origDir = pwd;

% Define basic fields in input structure.
hacDataStruct.firstMatlabInvocation = true;
hacDataStruct.debugFlag = 0;

% Generate HGN test data and results from ETEM output files.
generate_hgn_test_data;

% Switch to the hgn test directory.
hgnDir = [path '/hgn'];
cd(hgnDir);

% Get the run parameters and hgn results struct.
load(hgnStateFileName, 'runParams');
load(hgnResultsFileName, 'hgnResultsStruct');

% Fill in the rest of the hac data structure.
nRuns = length(runParams);

hacDataStruct.invocationCcdModule = hgnResultsStruct.ccdModule;
hacDataStruct.invocationCcdOutput = hgnResultsStruct.ccdOutput;
hacDataStruct.cadenceStart = runParams(nRuns).overallCadenceStart;
hacDataStruct.cadenceEnd = hgnResultsStruct.invocationCadenceEnd;
hacDataStruct.histograms = hgnResultsStruct.histograms;

% Switch to the hac test directory.
hacDir = [path '/hac'];
cd(hacDir);

% Load the fcConstants file and add it to the hac data structure.
load('fcConstants.mat');
hacDataStruct.fcConstants = fcConstants;

% Save the data structure to the hac inputs .mat file.
save(matFileName, 'hacDataStruct');

% Write the data structure to a bin file.
write_HacInputs(binFileName, hacDataStruct);

% Generate results structure and save to hac results .mat file.
[hacResultsStruct] = hac_matlab_controller(hacDataStruct);
save(hacResultsFileName, 'hacResultsStruct');

% Switch back to the original working directory.
cd(origDir);

% Return.
return
    