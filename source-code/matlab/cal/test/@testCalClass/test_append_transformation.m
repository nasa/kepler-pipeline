function self = test_append_transformation( self )

%% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function self = test_append_transformation( self )
% This test verifies that append_transformation.m creates the expected data
% structure by comparing the data structure created using
% append_transformation.m to an explicitly created one for each of the 
% allowed transformation types. For each transformation type, all the
% allowed input data type combinations are checked however the input and
% output sizes are not checked for consistancy. This only check that the
% transformation parameters are stored correctly.
%
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
%  Use a test runner to run the test method:
%  Example: run(text_test_runner, testCalClass('test_append_transformation'));
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

%% declare some parameters to generate random primitive data
numVars = 2;
maxPorder = 10;
pOrder = floor(maxPorder*rand);
dataDim = 1200;
maxGaps = 100;
maxBinSize = 100;
scale1 = rand;
%scale2 = rand;
scaleV1 = rand(dataDim,1);
scaleV2 = rand(dataDim,1);
string1 = '-24.*ones(dataDim,1)';
string2 = ['colvec(1:',num2str(dataDim),')'];
string3 = ['unique(sort(ceil(',num2str(maxBinSize),'*rand(10,1))))'];
binSizes = unique(sort(ceil(maxBinSize*rand(10,1))));
a_filter = [1,2,3,4,5]./15;
b_filter = [10,9,8,7,6]./40;
testM = rand(dataDim, pOrder);
testMstring = ['rand(',num2str(dataDim),',',num2str(pOrder),')'];

            
% generate random primitive data
xPrimitive1 = rand(dataDim,1);
CxPrimitive1 = rand(dataDim,1);
gaps1 = int16(unique(sort(ceil(maxGaps*rand(10,1)))));
rows1 = int16(unique(sort(ceil(maxGaps*rand(10,1)))));
cols1 = int16(unique(sort(ceil(maxGaps*rand(10,1)))));

%% test tranform type 'eye' ----------------------------------------------------------------------------------------------------
E_expected  = repmat(empty_errorPropStruct,numVars,1);
E           = E_expected;
varIndex = 1; 
tIndex   = 1;
E_expected(varIndex).variableName    = 'testVariable1';
E_expected(varIndex).xPrimitive      = xPrimitive1;
E_expected(varIndex).CxPrimitive     = CxPrimitive1;
E_expected(varIndex).gapList         = gaps1;
E_expected(varIndex).row             = rows1;
E_expected(varIndex).col             = cols1;

% test numeric input
E = append_transformation(E, 'eye', 'testVariable1', [], xPrimitive1, CxPrimitive1, gaps1, rows1, cols1);
assert_equals(E, E_expected, 'Unexpected ErrorPropStruct generated for transform type "eye" - numeric input');
varIndex = 2; 
tIndex   = 1;                    %#ok<*NASGU>

E_expected(varIndex).variableName    = 'testVariable2';
E_expected(varIndex).xPrimitive      = 'testVariable1';
E_expected(varIndex).CxPrimitive     = [];
E_expected(varIndex).gapList         = [];
E_expected(varIndex).row             = [];
E_expected(varIndex).col             = [];

% test character input
E = append_transformation(E, 'eye', 'testVariable2', [], 'testVariable1', [], [], [], []);
assert_equals(E, E_expected, 'Unexpected ErrorPropStruct generated for transform type "eye" - character input');

%% test tranform type 'scale' ---------------------------------------------------------------------------------------------------
varIndex = 1; 
tIndex   = 1;
E_expected(varIndex).transformStructArray(tIndex).transformType     = 'scale';
E_expected(varIndex).transformStructArray(tIndex).disableLevel      = 0;
E_expected(varIndex).transformStructArray(tIndex).yDataInputName    = [];
E_expected(varIndex).transformStructArray(tIndex).yIndices          = [];
E_expected(varIndex).transformStructArray(tIndex).transformParamStruct.scaleORweight    = scale1;
E_expected(varIndex).transformStructArray(tIndex).transformParamStruct.filterCoeffs_b   = [];
E_expected(varIndex).transformStructArray(tIndex).transformParamStruct.filterCoeffs_a   = [];
E_expected(varIndex).transformStructArray(tIndex).transformParamStruct.polyOrder        = [];
E_expected(varIndex).transformStructArray(tIndex).transformParamStruct.polyXvector      = [];
E_expected(varIndex).transformStructArray(tIndex).transformParamStruct.binSizes         = [];
E_expected(varIndex).transformStructArray(tIndex).transformParamStruct.FCmodelCall      = [];
E_expected(varIndex).transformStructArray(tIndex).transformParamStruct.userM            = [];
E_expected(varIndex).transformStructArray(tIndex).transformParamStruct.xIndices         = [];


% test numeric input
E = append_transformation(E, 'scale', 'testVariable1', [], scale1);
assert_equals(E, E_expected, 'Unexpected ErrorPropStruct generated for transform type "scale" - numeric input');
% test character input
% ------ no character input allowed

%% test tranform type 'scaleV' ---------------------------------------------------------------------------------------------------
varIndex = 1; 
tIndex   = 2;

E_expected(varIndex).transformStructArray(tIndex) = empty_tStruct;

E_expected(varIndex).transformStructArray(tIndex).transformType     = 'scaleV';
E_expected(varIndex).transformStructArray(tIndex).disableLevel      = 0;
E_expected(varIndex).transformStructArray(tIndex).yDataInputName    = [];
E_expected(varIndex).transformStructArray(tIndex).yIndices          = [];
E_expected(varIndex).transformStructArray(tIndex).transformParamStruct.scaleORweight    = scaleV1;
E_expected(varIndex).transformStructArray(tIndex).transformParamStruct.filterCoeffs_b   = [];
E_expected(varIndex).transformStructArray(tIndex).transformParamStruct.filterCoeffs_a   = [];
E_expected(varIndex).transformStructArray(tIndex).transformParamStruct.polyOrder        = [];
E_expected(varIndex).transformStructArray(tIndex).transformParamStruct.polyXvector      = [];
E_expected(varIndex).transformStructArray(tIndex).transformParamStruct.binSizes         = [];
E_expected(varIndex).transformStructArray(tIndex).transformParamStruct.FCmodelCall      = [];
E_expected(varIndex).transformStructArray(tIndex).transformParamStruct.userM            = [];
E_expected(varIndex).transformStructArray(tIndex).transformParamStruct.xIndices         = [];

% columnify the transformStructArray
E_expected(varIndex).transformStructArray = E_expected(varIndex).transformStructArray(:);

% test numeric input
E = append_transformation(E, 'scaleV', 'testVariable1', [], scaleV1);
assert_equals(E, E_expected, 'Unexpected ErrorPropStruct generated for transform type "scaleV" - numeric input');
% test character input
E_expected(varIndex).transformStructArray(tIndex).transformParamStruct.scaleORweight    = string1;
E = remove_last_transformation(E, 'testVariable1');
E = append_transformation(E, 'scaleV', 'testVariable1', [], string1);
assert_equals(E, E_expected, 'Unexpected ErrorPropStruct generated for transform type "scaleV" - character input');

%% test tranform type 'addV' ---------------------------------------------------------------------------------------------------
varIndex = 1; 
tIndex   = 3;

E_expected(varIndex).transformStructArray(tIndex) = empty_tStruct;

E_expected(varIndex).transformStructArray(tIndex).transformType     = 'addV';
E_expected(varIndex).transformStructArray(tIndex).disableLevel      = 0;
E_expected(varIndex).transformStructArray(tIndex).yDataInputName    = 'testVariable2';
E_expected(varIndex).transformStructArray(tIndex).yIndices          = [];
E_expected(varIndex).transformStructArray(tIndex).transformParamStruct.scaleORweight    = [];
E_expected(varIndex).transformStructArray(tIndex).transformParamStruct.filterCoeffs_b   = [];
E_expected(varIndex).transformStructArray(tIndex).transformParamStruct.filterCoeffs_a   = [];
E_expected(varIndex).transformStructArray(tIndex).transformParamStruct.polyOrder        = [];
E_expected(varIndex).transformStructArray(tIndex).transformParamStruct.polyXvector      = [];
E_expected(varIndex).transformStructArray(tIndex).transformParamStruct.binSizes         = [];
E_expected(varIndex).transformStructArray(tIndex).transformParamStruct.FCmodelCall      = [];
E_expected(varIndex).transformStructArray(tIndex).transformParamStruct.userM            = [];
E_expected(varIndex).transformStructArray(tIndex).transformParamStruct.xIndices         = [];

% test numeric input
% ------ no numeric input allowed
% test character input
E = append_transformation(E, 'addV', 'testVariable1', [], 'testVariable2', []);
assert_equals(E, E_expected, 'Unexpected ErrorPropStruct generated for transform type "addV" - character input');

%% test tranform type 'diffV' ---------------------------------------------------------------------------------------------------
varIndex = 1; 
tIndex   = 4;

E_expected(varIndex).transformStructArray(tIndex) = empty_tStruct;

E_expected(varIndex).transformStructArray(tIndex).transformType     = 'diffV';
E_expected(varIndex).transformStructArray(tIndex).disableLevel      = 0;
E_expected(varIndex).transformStructArray(tIndex).yDataInputName    = 'testVariable2';
E_expected(varIndex).transformStructArray(tIndex).yIndices          = [];
E_expected(varIndex).transformStructArray(tIndex).transformParamStruct.scaleORweight    = [];
E_expected(varIndex).transformStructArray(tIndex).transformParamStruct.filterCoeffs_b   = [];
E_expected(varIndex).transformStructArray(tIndex).transformParamStruct.filterCoeffs_a   = [];
E_expected(varIndex).transformStructArray(tIndex).transformParamStruct.polyOrder        = [];
E_expected(varIndex).transformStructArray(tIndex).transformParamStruct.polyXvector      = [];
E_expected(varIndex).transformStructArray(tIndex).transformParamStruct.binSizes         = [];
E_expected(varIndex).transformStructArray(tIndex).transformParamStruct.FCmodelCall      = [];
E_expected(varIndex).transformStructArray(tIndex).transformParamStruct.userM            = [];
E_expected(varIndex).transformStructArray(tIndex).transformParamStruct.xIndices         = [];

% test numeric input
% ------ no numeric input allowed
% test character input
E = append_transformation(E, 'diffV', 'testVariable1', [], 'testVariable2', []);
assert_equals(E, E_expected, 'Unexpected ErrorPropStruct generated for transform type "diffV" - character input');

%% test tranform type 'multV' ---------------------------------------------------------------------------------------------------
varIndex = 1; 
tIndex   = 5;

E_expected(varIndex).transformStructArray(tIndex) = empty_tStruct;

E_expected(varIndex).transformStructArray(tIndex).transformType     = 'multV';
E_expected(varIndex).transformStructArray(tIndex).disableLevel      = 0;
E_expected(varIndex).transformStructArray(tIndex).yDataInputName    = 'testVariable2';
E_expected(varIndex).transformStructArray(tIndex).yIndices          = [];
E_expected(varIndex).transformStructArray(tIndex).transformParamStruct.scaleORweight    = [];
E_expected(varIndex).transformStructArray(tIndex).transformParamStruct.filterCoeffs_b   = [];
E_expected(varIndex).transformStructArray(tIndex).transformParamStruct.filterCoeffs_a   = [];
E_expected(varIndex).transformStructArray(tIndex).transformParamStruct.polyOrder        = [];
E_expected(varIndex).transformStructArray(tIndex).transformParamStruct.polyXvector      = [];
E_expected(varIndex).transformStructArray(tIndex).transformParamStruct.binSizes         = [];
E_expected(varIndex).transformStructArray(tIndex).transformParamStruct.FCmodelCall      = [];
E_expected(varIndex).transformStructArray(tIndex).transformParamStruct.userM            = [];
E_expected(varIndex).transformStructArray(tIndex).transformParamStruct.xIndices         = [];

% test numeric input
% ------ no numeric input allowed
% test character input
E = append_transformation(E, 'multV', 'testVariable1', [], 'testVariable2', []);
assert_equals(E, E_expected, 'Unexpected ErrorPropStruct generated for transform type "multV" - character input');

%% test tranform type 'divV' ---------------------------------------------------------------------------------------------------
varIndex = 1; 
tIndex   = 6;

E_expected(varIndex).transformStructArray(tIndex) = empty_tStruct;

E_expected(varIndex).transformStructArray(tIndex).transformType     = 'divV';
E_expected(varIndex).transformStructArray(tIndex).disableLevel      = 0;
E_expected(varIndex).transformStructArray(tIndex).yDataInputName    = 'testVariable2';
E_expected(varIndex).transformStructArray(tIndex).yIndices          = [];
E_expected(varIndex).transformStructArray(tIndex).transformParamStruct.scaleORweight    = [];
E_expected(varIndex).transformStructArray(tIndex).transformParamStruct.filterCoeffs_b   = [];
E_expected(varIndex).transformStructArray(tIndex).transformParamStruct.filterCoeffs_a   = [];
E_expected(varIndex).transformStructArray(tIndex).transformParamStruct.polyOrder        = [];
E_expected(varIndex).transformStructArray(tIndex).transformParamStruct.polyXvector      = [];
E_expected(varIndex).transformStructArray(tIndex).transformParamStruct.binSizes         = [];
E_expected(varIndex).transformStructArray(tIndex).transformParamStruct.FCmodelCall      = [];
E_expected(varIndex).transformStructArray(tIndex).transformParamStruct.userM            = [];
E_expected(varIndex).transformStructArray(tIndex).transformParamStruct.xIndices         = [];

% test numeric input
% ------ no numeric input allowed
% test character input
E = append_transformation(E, 'divV', 'testVariable1', [], 'testVariable2', []);
assert_equals(E, E_expected, 'Unexpected ErrorPropStruct generated for transform type "divV" - character input');

%% test tranform type 'wSum' ---------------------------------------------------------------------------------------------------
varIndex = 1; 
tIndex   = 7;

E_expected(varIndex).transformStructArray(tIndex) = empty_tStruct;

E_expected(varIndex).transformStructArray(tIndex).transformType      = 'wSum';
E_expected(varIndex).transformStructArray(tIndex).disableLevel       = 0;
E_expected(varIndex).transformStructArray(tIndex).yDataInputName    = [];
E_expected(varIndex).transformStructArray(tIndex).yIndices          = [];
E_expected(varIndex).transformStructArray(tIndex).transformParamStruct.scaleORweight    = scaleV2;
E_expected(varIndex).transformStructArray(tIndex).transformParamStruct.filterCoeffs_b   = [];
E_expected(varIndex).transformStructArray(tIndex).transformParamStruct.filterCoeffs_a   = [];
E_expected(varIndex).transformStructArray(tIndex).transformParamStruct.polyOrder        = [];
E_expected(varIndex).transformStructArray(tIndex).transformParamStruct.polyXvector      = [];
E_expected(varIndex).transformStructArray(tIndex).transformParamStruct.binSizes         = [];
E_expected(varIndex).transformStructArray(tIndex).transformParamStruct.FCmodelCall      = [];
E_expected(varIndex).transformStructArray(tIndex).transformParamStruct.userM            = [];
E_expected(varIndex).transformStructArray(tIndex).transformParamStruct.xIndices         = [];

% test numeric input
E = append_transformation(E, 'wSum', 'testVariable1', [], scaleV2);
assert_equals(E, E_expected, 'Unexpected ErrorPropStruct generated for transform type "wSum" - numeric input');
% test character input
E_expected(varIndex).transformStructArray(tIndex).transformParamStruct.scaleORweight    = string1;
E = remove_last_transformation(E, 'testVariable1');
E = append_transformation(E, 'wSum', 'testVariable1', [], string1);
assert_equals(E, E_expected, 'Unexpected ErrorPropStruct generated for transform type "wSum" - character input');

%% test tranform type 'wMean' ---------------------------------------------------------------------------------------------------
varIndex = 1; 
tIndex   = 8;

E_expected(varIndex).transformStructArray(tIndex) = empty_tStruct;

E_expected(varIndex).transformStructArray(tIndex).transformType     = 'wMean';
E_expected(varIndex).transformStructArray(tIndex).disableLevel      = 0;
E_expected(varIndex).transformStructArray(tIndex).yDataInputName    = [];
E_expected(varIndex).transformStructArray(tIndex).yIndices          = [];
E_expected(varIndex).transformStructArray(tIndex).transformParamStruct.scaleORweight    = scaleV1;
E_expected(varIndex).transformStructArray(tIndex).transformParamStruct.filterCoeffs_b   = [];
E_expected(varIndex).transformStructArray(tIndex).transformParamStruct.filterCoeffs_a   = [];
E_expected(varIndex).transformStructArray(tIndex).transformParamStruct.polyOrder        = [];
E_expected(varIndex).transformStructArray(tIndex).transformParamStruct.polyXvector      = [];
E_expected(varIndex).transformStructArray(tIndex).transformParamStruct.binSizes         = [];
E_expected(varIndex).transformStructArray(tIndex).transformParamStruct.FCmodelCall      = [];
E_expected(varIndex).transformStructArray(tIndex).transformParamStruct.userM            = [];
E_expected(varIndex).transformStructArray(tIndex).transformParamStruct.xIndices         = [];

% test numeric input
E = append_transformation(E, 'wMean', 'testVariable1', [], scaleV1);
assert_equals(E, E_expected, 'Unexpected ErrorPropStruct generated for transform type "wMean" - numeric input');
% test character input
E_expected(varIndex).transformStructArray(tIndex).transformParamStruct.scaleORweight    = string1;
E = remove_last_transformation(E, 'testVariable1');
E = append_transformation(E, 'wMean', 'testVariable1', [], string1);
assert_equals(E, E_expected, 'Unexpected ErrorPropStruct generated for transform type "wMean" - character input');

%% test tranform type 'bin' ---------------------------------------------------------------------------------------------------
varIndex = 1; 
tIndex   = 9;

E_expected(varIndex).transformStructArray(tIndex) = empty_tStruct;

E_expected(varIndex).transformStructArray(tIndex).transformType     = 'bin';
E_expected(varIndex).transformStructArray(tIndex).disableLevel      = 0;
E_expected(varIndex).transformStructArray(tIndex).yDataInputName    = [];
E_expected(varIndex).transformStructArray(tIndex).yIndices          = [];
E_expected(varIndex).transformStructArray(tIndex).transformParamStruct.scaleORweight    = [];
E_expected(varIndex).transformStructArray(tIndex).transformParamStruct.filterCoeffs_b   = [];
E_expected(varIndex).transformStructArray(tIndex).transformParamStruct.filterCoeffs_a   = [];
E_expected(varIndex).transformStructArray(tIndex).transformParamStruct.polyOrder        = [];
E_expected(varIndex).transformStructArray(tIndex).transformParamStruct.polyXvector      = [];
E_expected(varIndex).transformStructArray(tIndex).transformParamStruct.binSizes         = binSizes;
E_expected(varIndex).transformStructArray(tIndex).transformParamStruct.FCmodelCall      = [];
E_expected(varIndex).transformStructArray(tIndex).transformParamStruct.userM            = [];
E_expected(varIndex).transformStructArray(tIndex).transformParamStruct.xIndices         = [];

% test numeric input
E = append_transformation(E, 'bin', 'testVariable1', [], binSizes);
assert_equals(E, E_expected, 'Unexpected ErrorPropStruct generated for transform type "bin" - numeric input');
% test character input
E_expected(varIndex).transformStructArray(tIndex).transformParamStruct.binSizes   = string3;
E = remove_last_transformation(E, 'testVariable1');
E = append_transformation(E, 'bin', 'testVariable1', [], string3);
assert_equals(E, E_expected, 'Unexpected ErrorPropStruct generated for transform type "bin" - character input');

%% test tranform type 'lsPolyFit' ---------------------------------------------------------------------------------------------------
% - not supported in append_transformation.m
% test numeric input
% test character input

%% test tranform type 'wPoly' ---------------------------------------------------------------------------------------------------
varIndex = 1; 
tIndex   = 10;

E_expected(varIndex).transformStructArray(tIndex) = empty_tStruct;

E_expected(varIndex).transformStructArray(tIndex).transformType     = 'wPoly';
E_expected(varIndex).transformStructArray(tIndex).disableLevel      = 0;
E_expected(varIndex).transformStructArray(tIndex).yDataInputName    = [];
E_expected(varIndex).transformStructArray(tIndex).yIndices          = [];
E_expected(varIndex).transformStructArray(tIndex).transformParamStruct.scaleORweight    = scaleV1;
E_expected(varIndex).transformStructArray(tIndex).transformParamStruct.filterCoeffs_b   = [];
E_expected(varIndex).transformStructArray(tIndex).transformParamStruct.filterCoeffs_a   = [];
E_expected(varIndex).transformStructArray(tIndex).transformParamStruct.polyOrder        = pOrder;
E_expected(varIndex).transformStructArray(tIndex).transformParamStruct.polyXvector      = colvec(1:dataDim);
E_expected(varIndex).transformStructArray(tIndex).transformParamStruct.binSizes         = [];
E_expected(varIndex).transformStructArray(tIndex).transformParamStruct.FCmodelCall      = [];
E_expected(varIndex).transformStructArray(tIndex).transformParamStruct.userM            = [];
E_expected(varIndex).transformStructArray(tIndex).transformParamStruct.xIndices         = [];

% test numeric input
E = append_transformation(E, 'wPoly', 'testVariable1', [], pOrder, colvec(1:dataDim), scaleV1);
assert_equals(E, E_expected, 'Unexpected ErrorPropStruct generated for transform type "wPoly" - numeric input');
% test character input
E_expected(varIndex).transformStructArray(tIndex).transformParamStruct.scaleORweight   = string1;
E_expected(varIndex).transformStructArray(tIndex).transformParamStruct.polyXvector     = string2;
E = remove_last_transformation(E, 'testVariable1');
E = append_transformation(E, 'wPoly', 'testVariable1', [], pOrder, string2, string1);
assert_equals(E, E_expected, 'Unexpected ErrorPropStruct generated for transform type "wPoly" - character input');

%% test tranform type 'expSum' ---------------------------------------------------------------------------------------------------
varIndex = 1; 
tIndex   = 11;

exponentialDecayConst = -rand(pOrder,1) * dataDim;
stringExponentialDecayConst = '[-20; -40; -100; -1000;]';
           
E_expected(varIndex).transformStructArray(tIndex) = empty_tStruct;

E_expected(varIndex).transformStructArray(tIndex).transformType     = 'expSum';
E_expected(varIndex).transformStructArray(tIndex).disableLevel      = 0;
E_expected(varIndex).transformStructArray(tIndex).yDataInputName    = [];
E_expected(varIndex).transformStructArray(tIndex).yIndices          = [];
E_expected(varIndex).transformStructArray(tIndex).transformParamStruct.scaleORweight    = [];
E_expected(varIndex).transformStructArray(tIndex).transformParamStruct.filterCoeffs_b   = [];
E_expected(varIndex).transformStructArray(tIndex).transformParamStruct.filterCoeffs_a   = [];
E_expected(varIndex).transformStructArray(tIndex).transformParamStruct.polyOrder        = exponentialDecayConst;
E_expected(varIndex).transformStructArray(tIndex).transformParamStruct.polyXvector      = colvec(1:dataDim);
E_expected(varIndex).transformStructArray(tIndex).transformParamStruct.binSizes         = [];
E_expected(varIndex).transformStructArray(tIndex).transformParamStruct.FCmodelCall      = [];
E_expected(varIndex).transformStructArray(tIndex).transformParamStruct.userM            = [];
E_expected(varIndex).transformStructArray(tIndex).transformParamStruct.xIndices         = [];

% test numeric input
E = append_transformation(E, 'expSum', 'testVariable1', [], exponentialDecayConst, colvec(1:dataDim));
assert_equals(E, E_expected, 'Unexpected ErrorPropStruct generated for transform type "expSum" - numeric input');
% test character input
E_expected(varIndex).transformStructArray(tIndex).transformParamStruct.polyOrder    = stringExponentialDecayConst;
E_expected(varIndex).transformStructArray(tIndex).transformParamStruct.polyXvector  = string2;
E = remove_last_transformation(E, 'testVariable1');
E = append_transformation(E, 'expSum', 'testVariable1', [], stringExponentialDecayConst, string2);
assert_equals(E, E_expected, 'Unexpected ErrorPropStruct generated for transform type "expSum" - character input');

%% test tranform type 'custom01_calFitted1DBlack' ---------------------------------------------------------------------------------------------------
varIndex = 1; 
tIndex   = 12;

K = [200 650];
X = 1:1070;
mSmearRows = 6:18;
maxMaskedSmearRow = 20;
startScienceRow = 24;

stringX = '[1:1070]';
stringMSmearRows = '[6:18]';
          
E_expected(varIndex).transformStructArray(tIndex) = empty_tStruct;

E_expected(varIndex).transformStructArray(tIndex).transformType     = 'custom01_calFitted1DBlack';
E_expected(varIndex).transformStructArray(tIndex).disableLevel      = 0;
E_expected(varIndex).transformStructArray(tIndex).yDataInputName    = [];
E_expected(varIndex).transformStructArray(tIndex).yIndices          = [];
E_expected(varIndex).transformStructArray(tIndex).transformParamStruct.scaleORweight    = K;
E_expected(varIndex).transformStructArray(tIndex).transformParamStruct.filterCoeffs_b   = startScienceRow;
E_expected(varIndex).transformStructArray(tIndex).transformParamStruct.filterCoeffs_a   = maxMaskedSmearRow;
E_expected(varIndex).transformStructArray(tIndex).transformParamStruct.polyOrder        = [];
E_expected(varIndex).transformStructArray(tIndex).transformParamStruct.polyXvector      = X;
E_expected(varIndex).transformStructArray(tIndex).transformParamStruct.binSizes         = [];
E_expected(varIndex).transformStructArray(tIndex).transformParamStruct.FCmodelCall      = [];
E_expected(varIndex).transformStructArray(tIndex).transformParamStruct.userM            = [];
E_expected(varIndex).transformStructArray(tIndex).transformParamStruct.xIndices         = mSmearRows;

% test numeric input
E = append_transformation(E, 'custom01_calFitted1DBlack', 'testVariable1', [], K, X, mSmearRows, startScienceRow, maxMaskedSmearRow);
assert_equals(E, E_expected, 'Unexpected ErrorPropStruct generated for transform type "custom01_calFitted1DBlack" - numeric input');
% test character input
E_expected(varIndex).transformStructArray(tIndex).transformParamStruct.xIndices     = stringMSmearRows;
E_expected(varIndex).transformStructArray(tIndex).transformParamStruct.polyXvector  = stringX;
E = remove_last_transformation(E, 'testVariable1');
E = append_transformation(E, 'custom01_calFitted1DBlack', 'testVariable1', [], K, stringX, stringMSmearRows, startScienceRow, maxMaskedSmearRow );
assert_equals(E, E_expected, 'Unexpected ErrorPropStruct generated for transform type "custom01_calFitted1DBlack" - character input');

%% test tranform type 'filter' ---------------------------------------------------------------------------------------------------
varIndex = 1; 
tIndex   = 13;

E_expected(varIndex).transformStructArray(tIndex) = empty_tStruct;

E_expected(varIndex).transformStructArray(tIndex).transformType     = 'filter';
E_expected(varIndex).transformStructArray(tIndex).disableLevel      = 0;
E_expected(varIndex).transformStructArray(tIndex).yDataInputName    = [];
E_expected(varIndex).transformStructArray(tIndex).yIndices          = [];
E_expected(varIndex).transformStructArray(tIndex).transformParamStruct.scaleORweight    = [];
E_expected(varIndex).transformStructArray(tIndex).transformParamStruct.filterCoeffs_b   = b_filter(:);
E_expected(varIndex).transformStructArray(tIndex).transformParamStruct.filterCoeffs_a   = a_filter(:);
E_expected(varIndex).transformStructArray(tIndex).transformParamStruct.polyOrder        = [];
E_expected(varIndex).transformStructArray(tIndex).transformParamStruct.polyXvector      = [];
E_expected(varIndex).transformStructArray(tIndex).transformParamStruct.binSizes         = [];
E_expected(varIndex).transformStructArray(tIndex).transformParamStruct.FCmodelCall      = [];
E_expected(varIndex).transformStructArray(tIndex).transformParamStruct.userM            = [];
E_expected(varIndex).transformStructArray(tIndex).transformParamStruct.xIndices         = [];

% test numeric input
E = append_transformation(E, 'filter', 'testVariable1', [], b_filter, a_filter);
assert_equals(E, E_expected, 'Unexpected ErrorPropStruct generated for transform type "filter" - numeric input');
% test character input
% ------ no character input allowed

%% test tranform type 'FCmodelScale' ---------------------------------------------------------------------------------------------------
% - not supported in append_transformation.m
% test numeric input
% test character input

%% test tranform type 'FCmodelAdd' ---------------------------------------------------------------------------------------------------
% - not supported in append_transformation.m
% test numeric input
% test character input

%% test tranform type 'userM' ---------------------------------------------------------------------------------------------------
varIndex = 1; 
tIndex   = 14;

E_expected(varIndex).transformStructArray(tIndex) = empty_tStruct;

E_expected(varIndex).transformStructArray(tIndex).transformType     = 'userM';
E_expected(varIndex).transformStructArray(tIndex).disableLevel      = 0;
E_expected(varIndex).transformStructArray(tIndex).yDataInputName    = [];
E_expected(varIndex).transformStructArray(tIndex).yIndices          = [];
E_expected(varIndex).transformStructArray(tIndex).transformParamStruct.scaleORweight    = [];
E_expected(varIndex).transformStructArray(tIndex).transformParamStruct.filterCoeffs_b   = [];
E_expected(varIndex).transformStructArray(tIndex).transformParamStruct.filterCoeffs_a   = [];
E_expected(varIndex).transformStructArray(tIndex).transformParamStruct.polyOrder        = [];
E_expected(varIndex).transformStructArray(tIndex).transformParamStruct.polyXvector      = [];
E_expected(varIndex).transformStructArray(tIndex).transformParamStruct.binSizes         = [];
E_expected(varIndex).transformStructArray(tIndex).transformParamStruct.FCmodelCall      = [];
E_expected(varIndex).transformStructArray(tIndex).transformParamStruct.userM            = testM;
E_expected(varIndex).transformStructArray(tIndex).transformParamStruct.xIndices         = [];

% test numeric input
E = append_transformation(E, 'userM', 'testVariable1', [], testM);
assert_equals(E, E_expected, 'Unexpected ErrorPropStruct generated for transform type "userM" - numeric input');
% test character input
E_expected(varIndex).transformStructArray(tIndex).transformParamStruct.userM   = testMstring;
E = remove_last_transformation(E, 'testVariable1');
E = append_transformation(E, 'userM', 'testVariable1', [], testMstring);
assert_equals(E, E_expected, 'Unexpected ErrorPropStruct generated for transform type "userM" - character input');

%% test tranform type 'clearVar' ---------------------------------------------------------------------------------------------------
% - not supported in append_transformation.m
% test numeric input
% test character input

%% test tranform type 'clearAll' ---------------------------------------------------------------------------------------------------
% - not supported in append_transformation.m
% test numeric input
% test character input



