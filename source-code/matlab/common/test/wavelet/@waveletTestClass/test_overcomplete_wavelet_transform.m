function self = test_overcomplete_wavelet_transform( self )
%
% test_overcomplete_wavelet_transoform -- unit test of the waveletClass method
% overcomplete_wavelet_transform.
%
% The following features of the method are tested:
%
% ==> correct execution when called with no flux time series argument
% ==> correct execution when called with a flux time series argument
%
% This test is intended to be run with an mlunit runner:
%
%      run(text_test_runner, waveletTestClass('test_overcomplete_wavelet_transform'));
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
  load( fullfile( testPath, 'wavelet-struct-partially-populated' ) ) ;
  waveletObject = waveletClass( waveletStructPartiallyPopulated ) ;
  
% Test 1:  call without a flux time series argument

  waveletCoeffs = overcomplete_wavelet_transform( waveletObject ) ;
  
% test 2:  call with flux time series argument

  waveletCoeffsWithArg = overcomplete_wavelet_transform( waveletObject, ...
      detrendedFlux11752906 ) ;
  
  waveletCoeffsInvertedArg = overcomplete_wavelet_transform( waveletObject, ...
      -detrendedFlux11752906 ) ;
 
% check the expected relations between the values

  assert_equals( waveletCoeffs, waveletCoeffsWithArg, ...
      'Wavelet coeffs with and without flux argument not as expected!' ) ;
  assert_equals( waveletCoeffs, -waveletCoeffsInvertedArg, ...
      'Wavelet coeffs with inverted flux not as expected!' ) ;
  
     disp([]) ;

return

