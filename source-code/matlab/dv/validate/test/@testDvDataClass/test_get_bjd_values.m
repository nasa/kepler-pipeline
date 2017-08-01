function self = test_get_bjd_values( self )
%
% test_get_bjd_values -- unit test of dvDataClass method get_bjd_values
%
% This unit test exercises the following functionality of the get_bjd_values method:
%
% ==> The method executes correctly
% ==> The output has the correct fields, and the fields have the correct values
% ==> When the user supplies a vector of bcmjds, the method converts them to bjds
% ==> When the user omits the bcmjds, the user-based bjd array is empty
% ==> If the user supplies an invalid target #, the correct error is thrown.
%
% This test is intended to be executed in the mlunit context.  For standalone execution
% use the following syntax:
%
%      run(text_test_runner, testDvDataClass('test_get_bjd_values'));
%
% Version date:  2009-October-19.
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

  disp('... testing get-bjd-values method ... ')
  
  testDvDataClass_fitter_initialization ;
  
% basic functionality test

  bcmjdStruct = dvDataStruct.barycentricCadenceTimes(1) ;
  [bjdStruct, bjd0, bjdUser] = get_bjd_values( dvDataObject, 1 ) ;
  
  assert_equals( fieldnames( bjdStruct ), fieldnames( bcmjdStruct ), ...
      'bjdStruct fields are not correct!' ) ;
  
  assert_equals( bjdStruct.startTimestamps, bcmjdStruct.startTimestamps+2.4e6+0.5, ...
      'bjdStruct start timestamps are not correct!' ) ;
  assert_equals( bjdStruct.midTimestamps, bcmjdStruct.midTimestamps+2.4e6+0.5, ...
      'bjdStruct start timestamps are not correct!' ) ;
  assert_equals( bjdStruct.endTimestamps, bcmjdStruct.endTimestamps+2.4e6+0.5, ...
      'bjdStruct start timestamps are not correct!' ) ;
  
  assert_equals( bjd0, floor( bjdStruct.startTimestamps(1) ) , ...
      'BJD offset value is not correct!' ) ;
  
  mlunit_assert( isempty( bjdUser ) , ...
      'bjdUser not empty when bcmjdUser argument omitted!' ) ;
  
% user-supplied BCMJD test

  bcmjdUser = [55000 55001 55002 ; 55003 55004 55005] ;
  [bjdStruct1, bjd01, bjdUser] = get_bjd_values( dvDataObject, 1, bcmjdUser ) ;
  
  assert_equals( bjdStruct, bjdStruct1, ...
      'Adding bcmjdUser changes bjdStruct!' ) ;
  assert_equals( bjd0, bjd01, ...
      'Adding bcmjdUser changes bjd0!' ) ;
  assert_equals( bjdUser, bcmjdUser + 2.4e6 + 0.5, ...
      'bjdUser values not correct!' ) ;
  
% error conditions

  iTarget = 0 ;
  cmdString = '[bjd, bjd0] = get_bjd_values( dvDataObject, iTarget ) ;' ;
  try_to_catch_error_condition( cmdString, 'iTargetInvalid', 'caller' ) ;
  iTarget = length( dvDataStruct.barycentricCadenceTimes ) + 1 ;
  try_to_catch_error_condition( cmdString, 'iTargetInvalid', 'caller' ) ;
  iTarget = [1 2] ;
  try_to_catch_error_condition( cmdString, 'iTargetInvalid', 'caller' ) ;
  iTarget = [] ;
  try_to_catch_error_condition( cmdString, 'iTargetInvalid', 'caller' ) ;

  disp(' ') ;
  
return

% and that's it!

%
%
%
