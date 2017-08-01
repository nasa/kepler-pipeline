function self = test_validate_inputs_pass_case(self)
% test_validate_missing_inputs checks whether the class
% constructor instantiates an object for valid parameter values without
% throwing any error
%
% Functionality tested:
%
%  ==> Basic functionality:  no error thrown for good values
%  ==> Cadence duration and cadences per hour/day appended
%  ==> deemphasis flags appended for TPS-full
%      --> correctly set for safe modes
%      --> correctly set for earth points
%      --> correctly set for attitude tweaks
% ==> deemphasis flags not set for tps-lite
% ==> If max search period is too large, it is set to a correct value based on the length
%     of the unit of work
% ==> Super-resolution factor set to 1 for tps-lite
% ==> Gap indices, fill indices, outlier indices, and discontinuity indices incremented by
%     1 (convert from 0-based to 1-based)
% ==> randStreams are added
%
%  Example
%  =======
%  Use a test runner to run the test method:
%  Example: run(text_test_runner,testTpsClass('test_validate_inputs_pass_case'));
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

% load a known-good TPS input structure and run through validation

  disp( ' ... testing validation with known-good inputs ... ' ) ;

  tpsDataFile = 'tps-full-data-struct' ;
  tpsDataStructName = 'tpsDataStruct' ;
  tps_testing_initialization ;
  tpsDataStruct.tpsModuleParameters.maximumSearchPeriodInDays = 75 ;
  lastwarn('') ;
  tpsDataStructAfter = validate_tps_input_structure(tpsDataStruct);
  [lastMsg, lastId] = lastwarn ;
  mlunit_assert( isempty(lastMsg) && isempty(lastId), ...
      'Unexpected warnings issued in validation!' ) ;
  
% the returned struct should have cadenceDurationInMinutes added

  mlunit_assert( isfield( tpsDataStructAfter.gapFillParameters, ...
      'cadenceDurationInMinutes' ), ...
      'cadenceDurationInMinutes not appended to gapFillParameters!' ) ;
  
% it should also have cadencesPerHour and cadencesPerDay added

  mlunit_assert( all( isfield( tpsDataStructAfter.tpsModuleParameters, ...
      {'cadencesPerHour', 'cadencesPerDay'} ) ), ...
      'Cadences per hour / day not appended to tpsModuleParameters!' ) ;
  
% the deemphasisParameter should be appended to cadenceTimes, and it should be all
% ones

  mlunit_assert( isfield( tpsDataStructAfter.cadenceTimes, ...
      'deemphasisParameter' ) && ...
      any( tpsDataStructAfter.cadenceTimes.deemphasisParameter ), ...
      'deemphasisParameter not as expected in basic test!' ) ;
  
% randStreams should be appended

  mlunit_assert( isfield( tpsDataStructAfter, ...
      'randStreams' ), 'randStreams were not added to Input!' ) ;
  
% set the following problems in the time series:
%
% ==> attitude tweak on cadence 500
% ==> Earth point at cadence 1000-1010
% ==> safe mode at cadence 1500-1510
%
% This should result in deemphasis of cadences 493-507, 903-1107, 1403-1607, but not
% including the cadences in the earth-point or safe-mode incident itself (except for first
% and last) -- those are marked as filled and left out of TCEs in consequence.

  tpsDataStruct.cadenceTimes.dataAnomalyTypes{500} = {'ATTITUDE_TWEAK'} ;
  for iCadence = 1000:1010
      tpsDataStruct.cadenceTimes.dataAnomalyTypes{iCadence} = {'EARTH_POINT'} ;
  end
  for iCadence = 1500:1510
      tpsDataStruct.cadenceTimes.dataAnomalyTypes{iCadence} = {'SAFE_MODE'} ;
  end
  
  tpsDataStructAfter = validate_tps_input_structure(tpsDataStruct);
  excludedCadences = find( ...
      tpsDataStructAfter.cadenceTimes.deemphasisParameter ~= 1 ) ;
  assert_equals( excludedCadences(:), [493:507 903:1107 1403:1607]', ...
      'Deemphasis cadences not as expected in presence of data anomalies!' ) ;
  
% Set the max search period longer than the unit of work and make sure that the resulting
% input struct has this value modified 

  tpsDataStruct.tpsModuleParameters.maximumSearchPeriodInDays = 375 ;
  unitOfWorkDays = length(tpsDataStruct.cadenceTimes.midTimestamps) / ...
      tpsDataStructAfter.tpsModuleParameters.cadencesPerDay ;
  
  lastwarn('') ;
  tpsDataStructAfter = validate_tps_input_structure( tpsDataStruct ) ;
  
  mlunit_assert( abs(tpsDataStructAfter.tpsModuleParameters.maximumSearchPeriodInDays - ...
      unitOfWorkDays/2) < 1e-3 * unitOfWorkDays, ...
      'Max search period not set to length of unit of work!' ) ;
%   [lastMsg, lastId] = lastwarn ;
%   assert_equals( lastId, 'TPS:validateTpsInputStructure:maxSearchPeriodReduced', ...
%       'No warning issued on change of max period search!' ) ;
  
% Set gap, fill, outlier, and discontinuity index values and see that they are properly
% incremented

  tpsDataStruct.tpsTargets(1).gapIndices = [17:22]' ;
  tpsDataStruct.tpsTargets(1).fillIndices = [201:230]' ;
  tpsDataStruct.tpsTargets(1).outlierIndices = [57 ; 2020] ;
  tpsDataStruct.tpsTargets(1).discontinuityIndices = [856] ;
  tpsDataStruct.tpsTargets(1).fillIndices = ...
      union(tpsDataStruct.tpsTargets(1).fillIndices, tpsDataStruct.tpsTargets(1).outlierIndices) ;
  tpsDataStructAfter = validate_tps_input_structure( tpsDataStruct ) ;
  mlunit_assert( isequal(tpsDataStructAfter.tpsTargets(1).gapIndices, ...
      tpsDataStruct.tpsTargets(1).gapIndices + 1) && ...
      isequal(tpsDataStructAfter.tpsTargets(1).fillIndices, ...
      tpsDataStruct.tpsTargets(1).fillIndices + 1) && ...      
      isequal(tpsDataStructAfter.tpsTargets(1).outlierIndices, ...
      tpsDataStruct.tpsTargets(1).outlierIndices + 1) && ...      
      isequal(tpsDataStructAfter.tpsTargets(1).discontinuityIndices, ...
      tpsDataStruct.tpsTargets(1).discontinuityIndices + 1) , ...
      'Gap/fill/outlier/discontinuity indices not corrected to 1-based counting!' ) ;
  
% When the TPS-lite flag is set, the following things should happen:
%
% --> The deemphasis flags should not be set or even added to the struct
% --> The super-resolution flag should be set to 1
% --> The cadence duration and cadences per hour / day values should be added
% --> The adjustment to the max search period should not occur.

  tpsDataStruct.tpsModuleParameters.tpsLiteEnabled = true ;
  tpsDataStructAfter = validate_tps_input_structure( tpsDataStruct ) ;
  
  mlunit_assert( ~isfield( tpsDataStructAfter.cadenceTimes, ...
      'deemphasizeAroundSafeModeTweakIndicators' ), ...
      'Deemphasis flags added to TPS-lite input struct!' ) ;
  assert_equals( tpsDataStructAfter.tpsModuleParameters.superResolutionFactor, ...
      1, 'Super-resolution factor not set to 1 for TPS-lite!' ) ;
  mlunit_assert( isfield( tpsDataStructAfter.gapFillParameters, ...
      'cadenceDurationInMinutes' ), ...
      'cadenceDurationInMinutes not appended to gapFillParameters in TPS-lite!' ) ;
  mlunit_assert( all( isfield( tpsDataStructAfter.tpsModuleParameters, ...
      {'cadencesPerHour', 'cadencesPerDay'} ) ), ...
      'Cadences per hour / day not appended to tpsModuleParameters in TPS-lite!' ) ;
  assert_equals( tpsDataStructAfter.tpsModuleParameters.maximumSearchPeriodInDays, ...
      tpsDataStruct.tpsModuleParameters.maximumSearchPeriodInDays, ...
      'Max search period not set to length of unit of work in TPS-lite!' ) ;
  mlunit_assert( isequal(tpsDataStructAfter.tpsTargets(1).gapIndices, ...
      tpsDataStruct.tpsTargets(1).gapIndices + 1) && ...
      isequal(tpsDataStructAfter.tpsTargets(1).fillIndices, ...
      tpsDataStruct.tpsTargets(1).fillIndices + 1) && ...      
      isequal(tpsDataStructAfter.tpsTargets(1).outlierIndices, ...
      tpsDataStruct.tpsTargets(1).outlierIndices + 1) && ...      
      isequal(tpsDataStructAfter.tpsTargets(1).discontinuityIndices, ...
      tpsDataStruct.tpsTargets(1).discontinuityIndices + 1) , ...
      'Gap/fill/outlier/discontinuity indices not corrected to 1-based counting in TPS-lite!' ) ;

  disp('') ;
  
return;