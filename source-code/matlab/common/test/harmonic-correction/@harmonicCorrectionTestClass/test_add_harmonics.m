function self = test_add_harmonics( self )
%
% test_add_harmonics -- unit test for the add_harmonics method of the harmonicsCorrectionClass
%
% This unit test exercises the following functionality of the method:
%
% ==> error case:  does not run if the initial time series is absent
% ==> the expected harmonics are added when the method is invoked
% ==> all of the harmonics are fitted with cosine like and sine like amplitudes
% ==> when protected periods are present, the expected frequencies are omitted from the
%     set
% ==> when called iteratively, the method adds harmonics to the existing set
% ==> when called with a center frequency argument, that frequency will be included in the
%     list of frequencies regardless of its SNR
% ==> The method will stop adding frequencies when the user-specified limit is reached
%
% This test is intended to be executed in the context of the mlunit framework.  To run the
% individual test, use the following syntax:
%
%      run(text_test_runner, harmonicCorrectionTestClass('test_add_harmonics'));
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

%=========================================================================================

  harmonic_correction_test_initialization ;
  load( fullfile( testDataPath, 'fourier-component-struct' ) ) ;
  
  obj = harmonicCorrectionClass( harmonicIdentificationParametersStruct ) ;

% trivial case -- no time series yields error exit

  testString = 'obj.add_harmonics ;' ;
  try_to_catch_error_condition(testString, 'originalFluxTimeSeriesNotSet', 'caller') ;
  
% set the time series, compare result to expected

  obj.set_time_series( fluxValues, sampleIntervalSeconds, gapOrFillIndicators ) ;
  addTrueOrFalse = obj.add_harmonics ;
  mlunit_assert( ~isempty( obj.fourierComponentStruct ), ...
      'add_time_series did not add frequencies!' ) ;
  mlunit_assert( addTrueOrFalse, ...
      'add_time_series returns wrong value when frequencies added!' ) ;
  
  testStructFromObject = rmfield( obj.fourierComponentStruct, {'cosAmplitude', ...
      'sinAmplitude'} ) ;
  testStructFromFile = rmfield( fourierComponentStruct, {'cosAmplitude', ...
      'sinAmplitude'} ) ;
  
  assert_equals( testStructFromObject, testStructFromFile, ...
      'Added frequencies do not match expected!' ) ; 
  mlunit_assert( all( [obj.fourierComponentStruct.cosAmplitude] ~= 0 ) && ...
      all( [obj.fourierComponentStruct.sinAmplitude] ~= 0 ), ...
      'Zero amplitudes detected in fourier struct!' ) ;
  
% when we try to iterate from this point, there should be additional frequencies from the
% orphan-finder, but no additional central frequencies

  oldFourierStruct = obj.fourierComponentStruct ;
  addTrueOrFalse = obj.add_harmonics ;
  mlunit_assert( addTrueOrFalse, ...
      'Frequencies not added when expected!' ) ;
  assert_equals( unique([obj.fourierComponentStruct.centerIndex]), ...
      unique([oldFourierStruct.centerIndex]) , ...
      'New center frequencies added by orphan-handler!' ) ;
  mlunit_assert( length(obj.fourierComponentStruct) > length(oldFourierStruct), ...
      'Orphan handler did not add frequencies!' ) ;
  
% there should be 2 more iterations of orphan-finding ...

  addTrueOrFalse = obj.add_harmonics ;
  mlunit_assert( addTrueOrFalse, ...
      'Frequencies not added when expected!' ) ;
  addTrueOrFalse = obj.add_harmonics ;
  mlunit_assert( addTrueOrFalse, ...
      'Frequencies not added when expected!' ) ;

% and then we should stop seeing additional frequencies added

  finalFourierStruct = obj.fourierComponentStruct ;
  addTrueOrFalse = obj.add_harmonics ;
  mlunit_assert( ~addTrueOrFalse, ...
      'Frequencies added when not expected!' ) ;
  assert_equals( finalFourierStruct, obj.fourierComponentStruct, ...
      'Fourier component struct not as expected after convergence of frequency adder!' ) ;
  
% now set a protected period and check what add_harmonics does in this case

  obj.set_time_series( fluxValues, sampleIntervalSeconds, gapOrFillIndicators ) ;
  obj.set_protected_frequency( protectedPeriodCadences ) ;
  addTrueOrFalse = obj.add_harmonics ;
  mlunit_assert( ~isempty( obj.fourierComponentStruct ), ...
      'add_time_series did not add frequencies with protected period!' ) ;
  mlunit_assert( addTrueOrFalse, ...
      'add_time_series returns wrong value when frequencies added with protected period!' ) ;

  testStructFromObject = rmfield( obj.fourierComponentStruct, {'cosAmplitude', ...
      'sinAmplitude'} ) ;
  testStructFromFile = rmfield( fourierComponentWithProtection, {'cosAmplitude', ...
      'sinAmplitude'} ) ;
  assert_equals( testStructFromObject, testStructFromFile, ...
      'Added frequencies do not match expected when period protected!' ) ;
  mlunit_assert( all( [obj.fourierComponentStruct.cosAmplitude] ~= 0 ) && ...
      all( [obj.fourierComponentStruct.sinAmplitude] ~= 0 ), ...
      'Zero amplitudes detected in fourier struct when period protected!' ) ;

% now unprotect the period and check to see that iterative fitting actually works

  obj.set_protected_frequency ;
  addTrueOrFalse = obj.add_harmonics ;
  mlunit_assert( addTrueOrFalse, ...
      'add_time_series returns wrong value when frequencies added iteratively!' ) ;
  assert_equals( unique( [oldFourierStruct.centerIndex] ), ...
      unique( [obj.fourierComponentStruct.centerIndex] ), ...
      'Added frequencies do not match expected when frequencies added iteratively!' ) ;
  
% test what happens when a frequency is manually forced

  obj.set_time_series( fluxValues, sampleIntervalSeconds, gapOrFillIndicators ) ;
  addTrueOrFalse = obj.add_harmonics( 253.8e-6 ) ;
  mlunit_assert( addTrueOrFalse, ...
      'add_time_series returns wrong value when frequencies added forcibly!' ) ;
  assert_equals( [obj.fourierComponentStruct.frequencyIndex], ...
      1943:1949, ...
      'Frequency indices not as expected when added forcibly!' ) ;
  mlunit_assert( all( [obj.fourierComponentStruct.centerIndex]==1947 ), ...
      'Center frequency indices not as expected when added forcibly!' ) ;
  mlunit_assert( ~any( ismember( [obj.fourierComponentStruct.centerIndex], ...
      [oldFourierStruct.centerIndex] ) ), ...
      'Powerful frequencies included in forced frequency list!' ) ;
  
% check what happens when the # of frequencies permitted is reduced

  harmonicIdentificationParametersStruct.maxHarmonicComponents = 2 ;
  clear obj ;
  obj = harmonicCorrectionClass( harmonicIdentificationParametersStruct ) ;
  obj.set_time_series( fluxValues, sampleIntervalSeconds, gapOrFillIndicators ) ;
  addTrueOrFalse = obj.add_harmonics ;
  mlunit_assert( addTrueOrFalse, ...
      'add_time_series returns wrong value when frequency count limited!' ) ;
  assert_equals( length( unique( [obj.fourierComponentStruct.centerIndex] ) ), 2, ...
      'Incorrect number of center frequencies added when count is limited!' ) ;
  mlunit_assert( length( [obj.fourierComponentStruct.frequencyIndex] ) > 2, ...
      'Incorrect number of frequencies added when count is limited!' ) ;
  
return

