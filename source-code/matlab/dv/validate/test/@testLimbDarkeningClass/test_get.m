function self = test_get( self )
%
% test_get -- test the limbDarkeningClass get method
%
% This unit test exercises the 3 use-cases for the get(limbDarkeningClass, '...') method:
%
% ==> 'help' or '?' : returns a list of members
% ==> '*'           : returns a struct with all the members
% ==> 'memberName'  : returns the named member of the object.
%
%
% This test is intended to be executed in the mlunit context.  For standalone execution
% use the following syntax:
%
%      run(text_test_runner, testLimbDarkeningClass('test_get'));
%
% Version date:  2009-November-3.
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
%=========================================================================================

disp('... testing limbDarkeningClass get method ... ')

% set test data directory
initialize_soc_variables;

testDataDir = [socTestDataRoot, filesep, 'dv', filesep, 'unit-tests', filesep, ...
    'limbDarkeningClass'] ;

clear soc*

% load the saved limb darkening model struct
load(fullfile(testDataDir, 'limb-darkening-model-get-test.mat')) ;

% instantiate the object
limbDarkeningModelObject  = limbDarkeningClass(limbDarkeningModelStruct);  %#ok<NODEF>



%--------------------------------------------------------------------------
% Test 1:  get the list of members
%--------------------------------------------------------------------------

memberList  = get( limbDarkeningModelObject, 'help' ) ;
memberList2 = get( limbDarkeningModelObject, '?' ) ;
assert_equals( memberList, memberList2, ...
    'get using "?" and "help" not identical in limbDarkeningClass' ) ;


%--------------------------------------------------------------------------
% test 2:  get all of the members at once
%--------------------------------------------------------------------------

limbDarkeningModelStruct = get( limbDarkeningModelObject, '*' ) ;
assert_equals( fieldnames(limbDarkeningModelStruct), memberList, ...
    'List of members obtained with "*" not identical to list from "?"' ) ;


%--------------------------------------------------------------------------
% test 3:  get the members one at a time and compare to the all-members approach
%--------------------------------------------------------------------------

for iMember = 1:length(memberList)

    memberName = memberList{iMember} ;
    memberValue = get( limbDarkeningModelObject, memberName ) ;
    assert_equals( memberValue, limbDarkeningModelStruct.(memberName), ...
        ['Member "',memberName,'" not equivalent to value obtained with "*" get'] ) ;
end


%--------------------------------------------------------------------------
% test 4:  try to get with an invalid member name
%--------------------------------------------------------------------------

try_to_catch_error_condition( 'memberValue = get( limbDarkeningModelObject ,''phony'' ) ; ', ...
    'badFieldName', 'caller' ) ;
disp(' ') ;


return;

