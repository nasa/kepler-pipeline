function self = test_set_extended_flux( self )
%
% test_set_extended_flux -- unit test for the waveletClass method set_extended_flux
%
% The following features of the method are tested:
%
% ==> The flux is set correctly in the object, including extension
% ==> Setting the flux causes the H and G members to be set
% ==> Setting the flux causes the whitening coefficients and variance window members to be
%     cleared
% ==> The correct errors are thrown when the method is called with inappropriate
%     arguments.
%
% This test is intended to be run with an mlunit runner:
%
%      run(text_test_runner, waveletTestClass('test_set_extended_flux'));
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
  nCadences = length(detrendedFlux11752906) ;
  
% Test 1:  basic setting and flux extension

  waveletObject = waveletClass( waveletStruct ) ;
  waveletObject = set_extended_flux( waveletObject, detrendedFlux11752906 ) ;
  waveletStructNew = struct( waveletObject ) ;
  
  mismatchH = waveletStructNew.H - waveletStructPartiallyPopulated.H ;
  mismatchG = waveletStructNew.G - waveletStructPartiallyPopulated.G ;
  
%  assert_equals( waveletStructNew.H, waveletStructPartiallyPopulated.H, ...
  mlunit_assert( max(abs(mismatchH(:)))<1e-13, ...
      'Wavelet object H member not as expected!' ) ;
  
%  assert_equals( waveletStructNew.G, waveletStructPartiallyPopulated.G, ...
  mlunit_assert( max(abs(mismatchG(:)))<1e-13, ...
      'Wavelet object G member not as expected!' ) ;

  assert_equals( length(waveletStructNew.extendedFluxTimeSeries), 65536, ...
      'Extended flux length incorrect!' ) ;
  
  assert_equals( waveletStructNew.extendedFluxTimeSeries(1:nCadences), ...
      detrendedFlux11752906, ...
      'Flux values in non-extended region not as expected!' ) ;
  
  assert_equals( waveletStructNew.extendedFluxTimeSeries(nCadences+1:end), ...
      waveletStructPartiallyPopulated.extendedFluxTimeSeries(nCadences+1:end), ...
      'Flux values in extended region not as expected!' ) ;
  
% test 2:  clearing of whitening coefficients and variance window members

  waveletObject = waveletClass( waveletStructPartiallyPopulated ) ;
  waveletObject = set_extended_flux( waveletObject, detrendedFlux11752906 ) ;
  waveletStructNew = struct( waveletObject ) ;
  
  mlunit_assert( isempty( waveletStructNew.whiteningCoefficients ), ...
      'Whitening coefficients not cleared by setting extended flux!' ) ;
  mlunit_assert( isempty( waveletStructNew.varianceWindowCadences ), ...
      'Variance Window not cleared by setting extended flux!' ) ;
  
% test 3:  error cases

%    Error 1:  flux contains unreal values

     testString1 = 'set_extended_flux( waveletObject, [randn(500,1) ; nan] )' ;
     try_to_catch_error_condition( testString1, 'extendedFluxNotRealVector', ...
         waveletObject, 'waveletObject' ) ;
     testString2 = 'set_extended_flux( waveletObject, [randn(500,1) ; inf] )' ;
     try_to_catch_error_condition( testString2, 'extendedFluxNotRealVector', ...
         waveletObject, 'waveletObject' ) ;
     testString3 = 'set_extended_flux( waveletObject, [randn(500,1) ; -inf] )' ;
     try_to_catch_error_condition( testString3, 'extendedFluxNotRealVector', ...
         waveletObject, 'waveletObject' ) ;
     testString4 = 'set_extended_flux( waveletObject, [randn(500,1) ; 1+i] )' ;
     try_to_catch_error_condition( testString4, 'extendedFluxNotRealVector', ...
         waveletObject, 'waveletObject' ) ;
     testString5 = 'set_extended_flux( waveletObject, eye(2) )' ;
     try_to_catch_error_condition( testString5, 'extendedFluxNotRealVector', ...
         waveletObject, 'waveletObject' ) ;
     testString6 = 'set_extended_flux( waveletObject, [] )' ;
     try_to_catch_error_condition( testString6, 'extendedFluxNotRealVector', ...
         waveletObject, 'waveletObject' ) ;
  
     disp([]) ;

return

