function self = test_identify_transit_cadences( self )
%
% test_identify_transit_cadences -- unit test of identify_transit_cadences method of
% transitGeneratorClass.
%
% This unit test exercises the following features of the identify_transit_cadences method:
%
% ==> The transitNumber vector is correctly filled for a system with multiple transits
% ==> The refEpochTransit is correctly returned, including in the case where the time
%     series contains no cadences which overlap the transit which contains the epoch
% ==> The transit buffer factor is correctly applied
% ==> The errors in the method are correctly thrown at appropriate times.
%
% This test is intended to be executed in the mlunit context.  For standalone execution
% use the following syntax:
%
%      run(text_test_runner, testTransitGeneratorClass('test_identify_transit_cadences'));
%
% Version date:  2010-January-07.
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
%    2009-January-07, PT:
%        test for case in which no transits fall in the object's time range.
%
%=========================================================================================

  disp('... testing identify-transit-cadences method ... ')
  
  testTransitGeneratorClass_initialization ;

% generate a cadence times vector which will have 2 transits in it

  cadenceTimes = get( transitObject, 'cadenceTimes' ) ;
  cadenceTimes = [cadenceTimes ; cadenceTimes + 330] ;
  
% execute the method and check its outputs

  [transitNumberVector, refEpochTransit] = identify_transit_cadences( transitObject, ...
      cadenceTimes ) ;
  outputsOk = length( find(transitNumberVector==0) ) == 5946 ;
  outputsOk = outputsOk && isequal( find(transitNumberVector == 1), ...
      [1:26]' ) ;
  outputsOk = outputsOk && isequal( find( transitNumberVector == 2 ), ...
      [4724:4751]' ) ;
  outputsOk = outputsOk && min(transitNumberVector) == 0 && max(transitNumberVector) == 2 ;
  outputsOk = outputsOk && refEpochTransit == 1 ;
  
  mlunit_assert( outputsOk, ...
      'identify_transit_cadences fails simple test' ) ;
  
% change the epoch by 1 period and see that the ref epoch transit changes but the transit
% number vector does not

  planetModel = get( transitObject, 'planetModel' ) ;
  planetModel.transitEpochBkjd = planetModel.transitEpochBkjd + ...
      planetModel.orbitalPeriodDays ;
  transitObject1 = set( transitObject, 'planetModel', planetModel ) ;
  [transitNumberVector1, refEpochTransit1] = identify_transit_cadences( transitObject1, ...
      cadenceTimes ) ;
  outputsOk = isequal( transitNumberVector, transitNumberVector1 ) && ...
      refEpochTransit1 == 2 ;
  
  mlunit_assert( outputsOk, ...
      'identify_transit_cadences fails test with refEpochTransit -> 2' ) ;
  
% Set the transit buffer factor to zero and make sure that the output is the same

  [transitNumberVector2, refEpochTransit2] = identify_transit_cadences( transitObject1, ...
      cadenceTimes, 0 ) ;
  outputsOk = isequal( transitNumberVector2, transitNumberVector1 ) && ...
      refEpochTransit2 == 2 ;
  
  mlunit_assert( outputsOk, ...
      'identify_transit_cadences fails test with transitBufferFactor == 0' ) ;

% set the transit buffer factor to 1 and make sure that the output is correct 

  [transitNumberVector3, refEpochTransit3] = identify_transit_cadences( transitObject1, ...
      cadenceTimes, 1 ) ;
  outputsOk = length( find(transitNumberVector3==0) ) == 5867 ;
  outputsOk = outputsOk && isequal( find(transitNumberVector3 == 1), ...
      [1:52]' ) ;
  outputsOk = outputsOk && isequal( find( transitNumberVector3 == 2 ), ...
      [4697:4777]' ) ;
  outputsOk = outputsOk && min(transitNumberVector3) == 0 && max(transitNumberVector3) == 2 ;
  outputsOk = outputsOk && refEpochTransit3 == 2 ;
  
  mlunit_assert( outputsOk, ...
      'identify_transit_cadences fails test with transitBufferFactor == 1' ) ;

% change the epoch by 1 additional period and make sure that the ref epoch is now set to 0

  planetModel = get( transitObject1, 'planetModel' ) ;
  planetModel.transitEpochBkjd = planetModel.transitEpochBkjd + ...
      planetModel.orbitalPeriodDays ;
  transitObject2 = set( transitObject1, 'planetModel', planetModel ) ;
  [transitNumberVector4, refEpochTransit4] = identify_transit_cadences( transitObject2, ...
      cadenceTimes ) ;
  outputsOk = isequal( transitNumberVector, transitNumberVector4 ) && ...
      refEpochTransit4 == 0 ;
  
  mlunit_assert( outputsOk, ...
      'identify_transit_cadences fails test with ref epoch outside of cadence time range' ) ;

% Set the timing up such that no transits fall in the time range of the object and make
% sure that all returns are correct

  planetModel = get( transitObject, 'planetModel' ) ;
  cadenceTimes = get( transitObject, 'cadenceTimes' ) ;
  timeRange = range(cadenceTimes) ;
  planetModel.orbitalPeriodDays = 2*timeRange ;
  planetModel.transitEpochBkjd = cadenceTimes(1) - planetModel.orbitalPeriodDays / 4 ;
  transitObject3 = set( transitObject, 'planetModel', planetModel ) ;
  [transitNumberVector5, refEpochTransit5] = identify_transit_cadences( transitObject3, ...
      cadenceTimes ) ;
  outputsOk = all(transitNumberVector5 == 0) && refEpochTransit5 == 0 ;
  
  mlunit_assert( outputsOk, ...
      'identify_transit_cadences fails test with all transits outside of cadence time range' ) ;
  
% finally, test the error-throws which check the method inputs

  try_to_catch_error_condition( '[a,b]=identify_transit_cadences(transitObject,inf);', ...
      'bkjdTimestampsInvalid', 'caller' ) ;
  try_to_catch_error_condition( '[a,b]=identify_transit_cadences(transitObject,nan);', ...
      'bkjdTimestampsInvalid', 'caller' ) ;
  try_to_catch_error_condition( '[a,b]=identify_transit_cadences(transitObject,[1 2 ; 3 4]);', ...
      'bkjdTimestampsInvalid', 'caller' ) ;
  try_to_catch_error_condition( '[a,b]=identify_transit_cadences(transitObject,''a'');', ...
      'bkjdTimestampsInvalid', 'caller' ) ;

  try_to_catch_error_condition( ...
      '[a,b]=identify_transit_cadences(transitObject,cadenceTimes,[1 2]);', ...
      'transitBufferFactorInvalid', 'caller' ) ;
  try_to_catch_error_condition( ...
      '[a,b]=identify_transit_cadences(transitObject,cadenceTimes,''a'');', ...
      'transitBufferFactorInvalid', 'caller' ) ;
  try_to_catch_error_condition( ...
      '[a,b]=identify_transit_cadences(transitObject,cadenceTimes,-1);', ...
      'transitBufferFactorInvalid', 'caller' ) ;
  disp(' ') ;

return

% and that's it!

%
%
%
