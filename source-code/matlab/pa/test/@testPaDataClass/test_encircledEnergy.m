function self = test_encircledEnergy(self)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function self = test_encircledEnergy(self)
% This function loads an abbreviated tppInputStruct generated from 3 months 
% (1 quarter) of simulated data from ETEM and perfroms the tests on the
% operation of the encircledEnergy function:
%
%    Test:      Functionality
%                   Data gaps
%                        1) Full data set.
%                        2) 90% quarter data set 
%                           100 realizations of full data set w/10% of the 
%                           target data missing at random - across cadences
%                        3) 75% monthly data set
%                           100 realizations of one month data sets w/25% of 
%                           the target data missing at random - across cadences
%
%                   NOT IMPLEMENTED YET
%                   Input robustness check
%                           Missing input fields
%                           Input data out of range data
%                           Input parameters out of range
%
%    Expected results:  1) Does not modify input data fields
%                           Output struct must contain all the fields and
%                           data of the input structure, i.e. identical
%                           fieldnames and numerically equal. Input is a
%                           subset of the output.
%                       2) Returns one ee metric data point per valid cadence
%
%                       NOT IMPLEMENTED YET
%                       3) Flags invalid cadences correctly (data gaps) 
%                       4) Metric is reasonable (i.e. >0.5, < 1.5 pixels) ???
%                          -- Depends on parameters of ETEM run
%                       5) Variation of the ee metric is reasonable (i.e. 0.1%) ???
%                          - Depends on parameters of ETEM run
%
% If any of the checks fail, an error condition occurs.
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%  Use a test runner to run the test method:
%  Example: run(text_test_runner, testPaClass('test_encircledEnergy'));
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

% Hard coded constants

INSTANCES = 1;          % number of instances of gapped data to check



% Add paths for test-data and test-meta data
initialize_soc_variables;
testDataRepo = [socTestDataRoot filesep 'pa' filesep 'unit-tests' filesep 'encircled_energy'];
testMetaDataRepo = [socTestMetaDataRoot filesep 'pa' filesep 'unit-tests' filesep 'encircled_energy'];

addpath(testMetaDataRepo);

% data filenames
dataFile	= [testDataRepo filesep 'tppStruct_run90400_quarter.mat'];

warningState = warning('query','all');
warning off all;        % disable warning echo

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TEST 1

% Load 1 quarter of ETEM Test Data
% Generated from ETEM run 90400
% path: /path/to/etem/quarter/1/run90400/long_cadence_q_black_smear_back_gcr

disp(mfilename('fullpath'));
disp(['Loading ',dataFile,' ...']);
load(dataFile);        

nTargets = length(tppInputStruct.targetStarStruct); %#ok<NASGU>
nCadences = length(tppInputStruct.targetStarStruct(1).pixelTimeSeriesStruct(1).timeSeries);

% run full data set
tempStruct=encircledEnergy(tppInputStruct);

% length of results
lenRadius=length(tempStruct.encircledEnergyStruct.eeRadius);
lenCRadius=length(tempStruct.encircledEnergyStruct.CeeRadius);
lenpolyCoeff=length(tempStruct.encircledEnergyStruct.polyCoeff);
lenCpolyCoeff=length(tempStruct.encircledEnergyStruct.CpolyCoeff);
leneeTargets=length(tempStruct.encircledEnergyStruct.numEETargets);


% check against expected

% Return struct must contain input struct with unaltered data
assert_equals(true,issubStruct(tppInputStruct,tempStruct),...
    'Input data has been modified');

% Encircled energy metrics must be calculated for each valid cadence
assert_equals(true,lenRadius==nCadences,...
    'Length of eeRadius metric not equal to number of cadences');
assert_equals(true,lenCRadius==nCadences,...
    'Length of CeeRadius metric not equal to number of cadences');
assert_equals(true,lenpolyCoeff==nCadences,...
    'Length of polyCoeff metric not equal to number of cadences');
assert_equals(true,lenCpolyCoeff==nCadences,...
    'Length of CpolyCoeff metric not equal to number of cadences');

% Must operate on all available encircled energy targets
assert_equals(true,leneeTargets==nCadences,...
    'Value eeTargets metric not equal to number of targets');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TEST 2
% run 90% quarter data set
% 
% Randomly remove 10% of the target data for the quarter.

CADENCE_GAP_FRACTION = 0.10;
TARGET_FRACTION = 0.10;
PIXEL_FRACTION = 0.10;

nTargets = length(tppInputStruct.targetStarStruct); %#ok<NASGU>
nCadences = length(tppInputStruct.targetStarStruct(1).pixelTimeSeriesStruct(1).timeSeries);


for i=1:INSTANCES

    % generate a copy of tppInputStruct with random data gaps
    fractionalDataStruct = ...
        inject_random_data_gaps(tppInputStruct,CADENCE_GAP_FRACTION,TARGET_FRACTION,PIXEL_FRACTION);

    % send gapped structure to encircledEnergy
    tempStruct =encircledEnergy(fractionalDataStruct);
    
    % length of results
    lenRadius=length(tempStruct.encircledEnergyStruct.eeRadius);
    lenCRadius=length(tempStruct.encircledEnergyStruct.CeeRadius);
    lenpolyCoeff=length(tempStruct.encircledEnergyStruct.polyCoeff);
    lenCpolyCoeff=length(tempStruct.encircledEnergyStruct.CpolyCoeff);
    leneeTargets=length(tempStruct.encircledEnergyStruct.numEETargets);


    % check against expected

    % Return struct must contain input struct with unaltered data
    assert_equals(true,issubStruct(fractionalDataStruct,tempStruct),...
        'Input data has been modified');

    % Encircled energy metrics must be calculated for each valid cadence
    assert_equals(true,lenRadius==nCadences,...
        'Length of eeRadius metric not equal to number of cadences');
    assert_equals(true,lenCRadius==nCadences,...
        'Length of CeeRadius metric not equal to number of cadences');
    assert_equals(true,lenpolyCoeff==nCadences,...
        'Length of polyCoeff metric not equal to number of cadences');
    assert_equals(true,lenCpolyCoeff==nCadences,...
        'Length of CpolyCoeff metric not equal to number of cadences');
    
    % Must operate on all available encircled energy targets    
    assert_equals(true,leneeTargets==nCadences,...
        'Value eeTargets metric not equal to number of targets');     
      
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TEST 3
% run 75% 1 month data set
% 
% Load 1 month ETEM Test Data
% Generated from ETEM run 90400
% path: /path/to/etem/quarter/1/run90400/long_cadence_q_black_smear_back_gcr

clear tppInputStruct;

dataFile	= [testDataRepo filesep 'tppStruct_run90400_month.mat'];

disp(['Loading ',dataFile,' ...']);
load(dataFile);   


% Randomly remove 25% of the target data for the month
CADENCE_GAP_FRACTION = 0.25;
TARGET_FRACTION = 0.25;
PIXEL_FRACTION = 0.25;

nTargets = length(tppInputStruct.targetStarStruct); %#ok<NASGU>
nCadences = length(tppInputStruct.targetStarStruct(1).pixelTimeSeriesStruct(1).timeSeries);


for i=1:INSTANCES
    
    % generate a copy of tppInputStruct with random data gaps
    fractionalDataStruct = ...
        inject_random_data_gaps(tppInputStruct,CADENCE_GAP_FRACTION,TARGET_FRACTION,PIXEL_FRACTION);

    % send gapped structure to encircledEnergy
    tempStruct =encircledEnergy(fractionalDataStruct);
  
    % length of results
    lenRadius=length(tempStruct.encircledEnergyStruct.eeRadius);
    lenCRadius=length(tempStruct.encircledEnergyStruct.CeeRadius);
    lenpolyCoeff=length(tempStruct.encircledEnergyStruct.polyCoeff);
    lenCpolyCoeff=length(tempStruct.encircledEnergyStruct.CpolyCoeff);
    leneeTargets=length(tempStruct.encircledEnergyStruct.numEETargets);
    
    % check against expected

    % Return struct must contain input struct with unaltered data
    assert_equals(true,issubStruct(fractionalDataStruct,tempStruct),...
        'Input data has been modified');

    % Encircled energy metrics must be calculated for each valid cadence
    assert_equals(true,lenRadius==nCadences,...
        'Length of eeRadius metric not equal to number of cadences');
    assert_equals(true,lenCRadius==nCadences,...
        'Length of CeeRadius metric not equal to number of cadences');
    assert_equals(true,lenpolyCoeff==nCadences,...
        'Length of polyCoeff metric not equal to number of cadences');
    assert_equals(true,lenCpolyCoeff==nCadences,...
        'Length of CpolyCoeff metric not equal to number of cadences');
    
    % Must operate on all available encircled energy targets
    assert_equals(true,leneeTargets==nCadences,...
        'Value eeTargets metric not equal to number of targets'); 
         
end

% restore warning state
warning(warningState);
