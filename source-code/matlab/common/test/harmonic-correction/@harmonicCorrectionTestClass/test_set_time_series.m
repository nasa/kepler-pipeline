function self = test_set_time_series( self )
%
% test_set_time_series -- unit test for the harmonicCorrectionClass method set_time_series
%
% This test is intended to be executed in the context of the mlunit framework.  To run the
% individual test, use the following syntax:
%
%      run(text_test_runner, harmonicCorrectionTestClass('test_set_time_series'));
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
  
  obj = harmonicCorrectionClass( harmonicIdentificationParametersStruct ) ;
  
% do the set

  obj.set_time_series( fluxValues, sampleIntervalSeconds, gapOrFillIndicators ) ;
  
  assert_equals( obj.originalFluxTimeSeries, fluxValues, ...
      'time series values not as expected!' ) ;
  assert_equals( obj.sampleIntervalSeconds, sampleIntervalSeconds, ...
      'sample interval value not as expected!' ) ;
  assert_equals( obj.gapOrFillIndicators, gapOrFillIndicators, ...
      'gap/fill parameters not as expected!' ) ;

% put in a protected index and fill the Fourier struct, and demonstrate that setting the
% time series clears those values

  obj.set_protected_frequency( protectedPeriodCadences ) ;
  obj.add_harmonics ;
  
  oldProtectedIndices = obj.protectedIndices ;
  oldFourierStruct    = obj.fourierComponentStruct ;
  
  obj.set_time_series( fluxValues, sampleIntervalSeconds, gapOrFillIndicators ) ;
  mlunit_assert( ~isempty(oldProtectedIndices) & isempty(obj.protectedIndices), ...
      'Protected indices not as expected!' ) ;
  mlunit_assert( ~isempty(oldFourierStruct) & isempty(obj.fourierComponentStruct), ...
      'Fourier component struct not as expected!' ) ;
  
% now test the case in which the two vectors are not equal in length

  gapOrFillIndicators(end) = [] ;
  testString = 'obj.set_time_series( fluxValues, sampleIntervalSeconds, gapOrFillIndicators )' ;
  try_to_catch_error_condition( testString, 'timeSeriesLengthInconsistent', 'caller' ) ;
  
return

