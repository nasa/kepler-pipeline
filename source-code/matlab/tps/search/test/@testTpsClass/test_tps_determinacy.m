function self = test_tps_determinacy( self )
%
% test_tps_determinacy -- unit test for testing whether TPS is
% deterministic
%
% This is a unit test in the testTpsClass, which runs under mlunit.  The
% test generates an input that tests all portions of TPS for determinacy.
% Since we are managing the random number seeds internally by target and
% CSCI, the output should be deterministic. Certain features of TPS that
% were exercised in the past and not used now are not going to be tested
% with this unit test (eclipsing binary removal, SPSD detection, etc).
%
% This method is not intended to be invoked directly, but rather via an 
% mlunit call.  Here's the syntax:
%
%      run(text_test_runner, testTpsClass('test_tps_determinacy'));
%
%==========================================================================
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

disp(' ... testing TPS determinacy ... ') ;
  
% set the test data path and retrieve the input struct 

tpsDataFile = 'tps-multi-quarter-struct' ;
tpsDataStructName = 'tpsInputs' ;
tps_testing_initialization ;
  
% set rand seed

s = RandStream('mcg16807','Seed',0) ;
RandStream.setDefaultStream(s) ;
  
% set up the input to ensure that it will hit all areas of TPS

tpsInputs.tpsModuleParameters.applyAttitudeTweakCorrection = true;
tpsInputs.tpsModuleParameters.deweightReactionWheelZeroCrossingCadences = true;
tpsInputs.tpsModuleParameters.maxFoldingLoopCount = 2;
tpsInputs.tpsModuleParameters.positiveOutlierHaircutEnabled = true;
tpsInputs.tpsModuleParameters.varianceWindowLengthMultiplier = 7;
tpsInputs.gapFillParameters.removeEclipsingBinariesOnList = false;
tpsInputs.tpsModuleParameters.debugLevel = -1;

% just keep the last two targets since they touch all the areas of quarter
% stitching and haircut removal

tpsInputs.tpsTargets = tpsInputs.tpsTargets(9:10);
tpsInputsOrig = tpsInputs;

% run the input through and store results

tpsOutputs = tps_matlab_controller(tpsInputs);
tpsOutputs = tpsOutputs.tpsResults;
tpsOutputs = rmfield(tpsOutputs, 'foldingWallTimeHours');

% run the input through again and check the results

tpsOutputsTest = tps_matlab_controller(tpsInputs);
tpsOutputsTest = tpsOutputsTest.tpsResults;
tpsOutputsTest = rmfield(tpsOutputsTest, 'foldingWallTimeHours');

mlunit_assert( isequal(tpsOutputs, tpsOutputsTest), ...
    'TPS results are not deterministic' );

% now swap the target order around and run it again

tpsInputs.tpsTargets = fliplr( tpsInputs.tpsTargets );
tpsOutputsTest = tps_matlab_controller(tpsInputs);
tpsOutputsTest = tpsOutputsTest.tpsResults;
tpsOutputsTest = rmfield(tpsOutputsTest, 'foldingWallTimeHours');

% generate a vector that will match up the outputs
nTargets = length(tpsInputs.tpsTargets);
nPulses = length(tpsOutputs) / nTargets;
matchVector = (1:length(tpsOutputs))';
matchVector = reshape( matchVector, nTargets, nPulses);
matchVector = flipud(matchVector);
matchVector = reshape(matchVector, nTargets*nPulses,1);

mlunit_assert( isequal(tpsOutputs, tpsOutputsTest(matchVector)), ...
    'TPS results determinacy is not preserved with respect to target order' );

% now run only one pulse duration

tpsInputs = tpsInputsOrig;
tpsInputs.tpsModuleParameters.requiredTrialTransitPulseInHours = 12;
tpsInputs.tpsModuleParameters.storeCdppFlag = true;
tpsOutputsTest = tps_matlab_controller(tpsInputs);
tpsOutputsTest = tpsOutputsTest.tpsResults;
tpsOutputsTest = rmfield(tpsOutputsTest, 'foldingWallTimeHours');

% remove the fields that are only populated for the first pulse duration

tpsOutputsTemp = rmfield(tpsOutputs, {'frontExponentialPpm','backExponentialPpm', ...
    'harmonicTimeSeries', 'detrendedFluxTimeSeries'} );
tpsOutputsTest = rmfield(tpsOutputsTest, {'frontExponentialPpm','backExponentialPpm', ...
    'harmonicTimeSeries', 'detrendedFluxTimeSeries'} );

mlunit_assert( isequal(tpsOutputsTemp(end-nTargets+1:end), tpsOutputsTest), ...
    'TPS results determinacy is not preserved with respect to the number of trial pulses' );

clear tpsOutputsTemp;

% now run only one target

tpsInputs = tpsInputsOrig;
tpsInputs.tpsTargets = tpsInputs.tpsTargets(1);
tpsOutputsTest = tps_matlab_controller(tpsInputs);
tpsOutputsTest = tpsOutputsTest.tpsResults;
tpsOutputsTest = rmfield(tpsOutputsTest, 'foldingWallTimeHours');

mlunit_assert( isequal(tpsOutputs(1:nTargets:end), tpsOutputsTest), ...
    'TPS results determinacy is not preserved with respect to the number of targets' );

tpsInputs = tpsInputsOrig;
tpsInputs.tpsTargets = tpsInputs.tpsTargets(2);
tpsOutputsTest = tps_matlab_controller(tpsInputs);
tpsOutputsTest = tpsOutputsTest.tpsResults;
tpsOutputsTest = rmfield(tpsOutputsTest, 'foldingWallTimeHours');

mlunit_assert( isequal(tpsOutputs(2:nTargets:end), tpsOutputsTest), ...
    'TPS results determinacy is not preserved with respect to the number of targets' );


% if at some point eclipsing binary removal is turned on then it should be
% added to this test

return