function self = test_compute_statistics_time_series( self )
%
% test_compute_statistics_time_series -- unit test of the waveletClass method
% compute_statistics_time_series.
%
% The following features of the method are tested:
%
% ==> correct execution when called with returnComponents set to false or true
% ==> correct behavior when the shiftLength is varied
% ==> correct behavior when called with a SES index argument
% ==> correct errors are thrown when called without defined whitening coefficients or flux
%     time series.
%
% This test is intended to be run with an mlunit runner:
%
%      run(text_test_runner, waveletTestClass('test_compute_statistics_time_series'));
%
% or else as a master all-test run via wavelet_run_all_tests_txt.
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

% obtain the current value of the soc test data root

  initialize_soc_variables ;
  testPath = fullfile( socTestDataRoot,'common','unit-tests','wavelet' ) ;

  load( fullfile( testPath, 'detrended-flux-11752906' ) ) ;
  load( fullfile( testPath, 'wavelet-struct' ) ) ;
  load( fullfile( testPath, 'wavelet-struct-partially-populated' ) ) ;
  waveletObject = waveletClass( waveletStructPartiallyPopulated ) ;
  trialTransitPulse = -1*ones(9,1) ;
  
% Test 1:  correct execution

  [correlation1, normalization1] = compute_statistics_time_series( waveletObject, ...
      trialTransitPulse, 9 ) ;
  [correlation2, normalization2] = compute_statistics_time_series( waveletObject, ...
      trialTransitPulse, 8 ) ;
  [correlation3, normalization3] = compute_statistics_time_series( waveletObject, ...
      trialTransitPulse, 8, false ) ;
  [correlation4, normalization4] = compute_statistics_time_series( waveletObject, ...
      trialTransitPulse, 8, true ) ;
  [correlation5, normalization5] = compute_statistics_time_series( waveletObject, ...
      trialTransitPulse, 8, true, 10 ) ;
  
%

  assert_equals( correlation1, circshift(correlation2,1), ...
      'Effect of varying shift length on correlation not as expected!' ) ;
  assert_equals( correlation2, correlation3, ...
      'Effect of varying returnComponents==false flag on correlation not as expected!' ) ;
  assert_equals( correlation2, sum(correlation4,2), ...
      'Correlation not as expected when returnComponents == true!' ) ;
  assert_equals( size(correlation4), [65536 14], ...
      'Size of correlation component matrix not as expected!' ) ;
  assert_equals( correlation5, correlation4(10,:), ...
      'Correlation component with SES index not as expected!' ) ;
  
  assert_equals( normalization1, circshift(normalization2,1), ...
      'Effect of varying shift length on normalization not as expected!' ) ;
  assert_equals( normalization2, normalization3, ...
      'Effect of varying returnComponents==false flag on normalization not as expected!' ) ;
  assert_equals( normalization2, sqrt(sum(normalization4,2)), ...
      'Normalization not as expected when returnComponents == true!' ) ;
  assert_equals( size(normalization4), [65536 14], ...
      'Size of normalization component matrix not as expected!' ) ;
  assert_equals( normalization5, normalization4(10,:), ...
      'Normalization component with SES index not as expected!' ) ;
  

% test 2:  error cases

  waveletObject = waveletClass( waveletStruct ) ;
  errorString = ...
      'compute_statistics_time_series( waveletObject, trialTransitPulse, 9 )' ;
  try_to_catch_error_condition( errorString, 'membersUndefined', 'caller' ) ;
  waveletObject = set_extended_flux( waveletObject, detrendedFlux11752906 ) ;
  try_to_catch_error_condition( errorString, 'membersUndefined', 'caller' ) ;
  waveletObject = set_whitening_coefficients( waveletObject, 90 ) ;
  compute_statistics_time_series( waveletObject, trialTransitPulse, 9 ) ;
  
     disp([]) ;

return

