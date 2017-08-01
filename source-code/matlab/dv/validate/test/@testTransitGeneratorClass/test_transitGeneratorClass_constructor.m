function self = test_transitGeneratorClass_constructor( self )
%
% test_transitGeneratorClass_constructor -- perform unit tests of the
% transitGeneratorClass constructor:
%
%
% This unit test exercises the following functionality of the transitGeneratorClass
% constructor:
%
% ==> Gaussian model-instantiated object passes regression test.
%     Gaussian model limb darkening coeffts are zero as expected.
%     Gaussian model-instantiated limb darkening coeffts pass regression test.
%
% ==> Instantiated object with limb darkening passes regression test.
%     Limb darkening coeffts pass regression test.
%     Limb darkening coeffts are non-zero as expected.
%     Invalid limb darkening model name returns zero-valued coeffts as expected.
%
% ==> The error statements in the constructor are executed under appropriate conditions.
%
%
% Note the unit tests for the various planet model legal formats are
% included in test_transitGeneratorClass_constructor_formats
%
%
% This test is intended to be executed in the mlunit context.  For standalone execution
% use the following syntax:
%
%      run(text_test_runner, testTransitGeneratorClass('test_transitGeneratorClass_constructor'));
%
% Version date:  2009-September-29.
%
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

% Modification History:
%
%    2009-November-04, EQ:
%    updated unit tests
%
%=========================================================================================


% set test data directory
initialize_soc_variables;

testDataDir = [socTestDataRoot, filesep, 'dv', filesep, 'unit-tests', filesep, ...
    'transitGeneratorClass'] ;

clear soc*


%--------------------------------------------------------------------------
% test gaussian model option
%--------------------------------------------------------------------------
disp('... testing transit generator class constructor for gaussian model ... ')


% load the saved transitModelStruct and transitModelObject
load(fullfile(testDataDir, 'transit-model-gaussian-test.mat')) ;

% perform regression test
transitModelObjectNew = transitGeneratorClass(transitModelStruct); %#ok<NODEF>

transitModelObjectNewStruct = struct( transitModelObjectNew ) ;

% the saved transitModelObject has also been saved as a struct
assert_equals( transitModelObjectStruct, transitModelObjectNewStruct, ...
    'Gaussian model-instantiated object fails regression test.' ) ;
disp('Gaussian model-instantiated object passed regression test.')


% ensure that the limbDarkeningCoefficients are empty
limbDarkeningCoefficients    = transitModelObjectStruct.limbDarkeningCoefficients;
limbDarkeningCoefficientsNew = get(transitModelObjectNew, 'limbDarkeningCoefficients');

limbDarkeningEmptyArray = [0 0 0 0];

assert_equals( limbDarkeningCoefficients(:), limbDarkeningEmptyArray(:), ...
    'Gaussian model limb darkening coeffts are not zero.' ) ;
disp('Gaussian model limb darkening coeffts are zero as expected.') ;

assert_equals( limbDarkeningCoefficients(:), limbDarkeningCoefficientsNew(:), ...
    'Gaussian model-instantiated limb darkening coeffts fail regression test' ) ;
disp('Gaussian model-instantiated limb darkening coeffts passed regression test.')


% test the error condition for a star radius of NaN
transitModelStruct.planetModel.starRadiusSolarRadii = nan ;
try_to_catch_error_condition( 'z=transitGeneratorClass(transitModelStruct);' , ...
    'starRadiusSolarRadiiNaN', 'caller' ) ;

disp('Error condition passed for a star radius of NaN.') ;


%--------------------------------------------------------------------------
% test limb darkening coefficient retrieval
%--------------------------------------------------------------------------
disp('... testing limb darkening coefficient retrieval ... ')

% load the saved transitModelStruct and transitModelObject
load(fullfile(testDataDir, 'transit-model-constructor-test.mat')) ;


% regression test:
transitModelObjectNew = transitGeneratorClass(transitModelStruct); %#ok<NODEF>

resultsStruct = struct( transitModelObject ) ;
resultsStructNew = struct( transitModelObjectNew ) ;


assert_equals( resultsStruct, resultsStructNew, ...
    'Instantiated object with limb darkening fails regression test.' ) ;
disp('Instantiated object with limb darkening passed regression test.')


% ensure that the limbDarkeningCoefficients are equal and not empty
limbDarkeningCoefficients    = get(transitModelObject, 'limbDarkeningCoefficients');
limbDarkeningCoefficientsNew = get(transitModelObjectNew, 'limbDarkeningCoefficients');

assert_equals( limbDarkeningCoefficients(:), limbDarkeningCoefficientsNew(:), ...
    'Limb darkening coeffts fails regression test.' ) ;
disp('Limb darkening coeffts passed regression test.') ;

assert_not_equals( limbDarkeningCoefficientsNew(:), limbDarkeningEmptyArray(:), ...
    'Limb darkening coeffts are zero-valued.' ) ;
disp('Limb darkening coeffts are non-zero as expected.') ;


% test output for invalid limb darkening model name
transitModelStructNew = transitModelStruct ;
transitModelStructNew.modelNamesStruct.limbDarkeningModelName = 'dummy' ;

transitModelObjectNew = transitGeneratorClass(transitModelStructNew); %#ok<NODEF>

limbDarkeningCoefficientsNew = get(transitModelObjectNew, 'limbDarkeningCoefficients');

assert_equals( limbDarkeningCoefficientsNew(:), limbDarkeningEmptyArray(:), ...
    'Invalid limb darkening model name does not return zero-valued coeffts.' ) ;
disp('Invalid limb darkening model name returns zero-valued coeffts as expected.')


%--------------------------------------------------------------------------
% regression test for transit generator
%--------------------------------------------------------------------------
disp('... regression testing the transit signal generator ... ')


% load the saved transitModelStruct and transitModelResultsStruct
load(fullfile(testDataDir, 'transit-model-regression-test.mat')) ;


% regression test:
transitModelResultsObjectNew = transitGeneratorClass(transitModelStruct); %#ok<NODEF>

transitModelResultsStructNew = struct(transitModelResultsObjectNew);


assert_equals( transitModelResultsStructNew, transitModelResultsStruct, ...
    'TransitGeneratorClass fails regression test.' ) ;
disp('TransitGeneratorClass passed regression test.')



return;

