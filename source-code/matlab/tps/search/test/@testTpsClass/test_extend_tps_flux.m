function self = test_extend_tps_flux( self )
%
% test_extend_tps_flux -- unit test of tpsClass method extend_tps_flux
%
% This unit test exercises the following functionality of the method:
%
% ==> The flux is properly extended to the nearest power of 2 in length, where in this
%     case 'properly' means the following:
%     --> The shape of the returned array is correct, nCadencesExtended x nTargets
%     --> For each target, the first nCadences values are equal to the original flux
%         values up to a constant offset (due to median subtraction of the full extended
%         flux)
%     --> The median extended flux for each target is zero
% ==> If the flux is already at a power of 2, then the returned flux is exactly identical
%     to the original flux.
%
% This test is performed in the mlunit context.  For standalone operation, use the
% following syntax:
%
%      run(text_test_runner, testTpsClass('test_extend_tps_flux'));
%
% Version date:  2010-September-28.
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

  disp(' ... testing tpsClass flux-extension method ... ') ;

% set the test data path and retrieve the input struct 

  tpsDataFile = 'tps-multi-quarter-struct' ;
  tpsDataStructName = 'tpsInputs' ;
  tps_testing_initialization ;
  
% set the random number generator to the correct value

  s = RandStream('mcg16807','Seed',10) ;
  RandStream.setDefaultStream(s) ;
  
% in the interest of speed and simplicity, reduce the # of cadences which are used -- this
% requires reducing the # of flux values in each target and also the length of the cadence
% numbers vector.  We'll go down to 4000 cadences, so the extension should be to 4096.
% While we're at it, we can accumulate a matrix of original flux values.  Finally, since
% we don't want to have to do all the tedious manipulations of the multi-quarter data,
% we'll replace the real flux with random numbers.

  nCadences    = 4000 ;
  nTargets     = length( tpsInputs.tpsTargets ) ;
  originalFlux = zeros(nCadences, nTargets) ;
  
  cadenceTimesFields = fieldnames(tpsInputs.cadenceTimes) ;

  for iTarget = 1:nTargets
      
      flux                                      = 1e-3 * randn(nCadences,1) ;
      flux                                      = flux - median(flux) ;
      tpsInputs.tpsTargets(iTarget).fluxValue   = flux ;
      tpsInputs.tpsTargets(iTarget).uncertainty = zeros(nCadences,1) ;
      tpsInputs.tpsTargets(iTarget).fillIndices = [] ;
      tpsInputs.tpsTargets(iTarget).gapIndices  = [] ;
      tpsInputs.tpsTargets(iTarget).discontinuityIndices = [] ;
      tpsInputs.tpsTargets(iTarget).outlierIndices = [] ;
      originalFlux(:,iTarget)                   = flux ;
      
  end
  for iTimeVector = 1:length(cadenceTimesFields)
      tpsInputs.cadenceTimes.(cadenceTimesFields{iTimeVector}) = ...
          tpsInputs.cadenceTimes.(cadenceTimesFields{iTimeVector})(1:nCadences) ;
  end
  
  nCadencesExtended = 2^( ceil( log2( nCadences ) ) ) ;
  
% instantiate the object

  inputStructReady = validate_tps_input_structure( tpsInputs ) ;
  inputStructReady.tpsModuleParameters.performQuarterStitching = false ;
  tpsObject        = tpsClass( inputStructReady ) ;

% call quarter stitcher to get fields added without doing quarter stitching

  tpsObject        = perform_quarter_stitching( tpsObject ) ;

  extendedFlux     = extend_tps_flux( tpsObject ) ;
  
% check the dimensions of the extended flux
  
  assert_equals( size( extendedFlux ), [nCadencesExtended nTargets], ...
      'Size of extendedFlux not as expected in 4000-cadence test!' ) ;
    
% check that the offset between the first nCadences of the extended flux and the original
% flux is constant

  mlunit_assert( all( std( originalFlux - extendedFlux(1:nCadences,:) ) < 1e-9 ) , ...
      'Offset between original and extended flux not constant in 4000-cadence test!' ) ;
  
% check that the flux extension is nonzero

  mlunit_assert( all( std( extendedFlux(nCadences+1:end,:) ) > 1e-4 ), ...
      'RMS of flux extension not as expected in 4000-cadence test!' ) ;
  
% now chop the flux down to 2048 cadences  

  nCadences    = 2048 ;
  originalFlux = zeros(nCadences, nTargets) ;

  for iTarget = 1:nTargets
      
      flux                                      = 1e-3 * randn(nCadences,1) ;
      flux                                      = flux - median(flux) ;
      tpsInputs.tpsTargets(iTarget).fluxValue   = flux ;
      tpsInputs.tpsTargets(iTarget).uncertainty = zeros(nCadences,1) ;
      tpsInputs.tpsTargets(iTarget).fillIndices = [] ;
      tpsInputs.tpsTargets(iTarget).gapIndices  = [] ;
      tpsInputs.tpsTargets(iTarget).discontinuityIndices = [] ;
      tpsInputs.tpsTargets(iTarget).outlierIndices = [] ;
      originalFlux(:,iTarget)                   = flux ;
      
  end
  for iTimeVector = 1:length(cadenceTimesFields)
      tpsInputs.cadenceTimes.(cadenceTimesFields{iTimeVector}) = ...
          tpsInputs.cadenceTimes.(cadenceTimesFields{iTimeVector})(1:nCadences) ;
  end
  
% instantiate the object

  inputStructReady = validate_tps_input_structure( tpsInputs ) ;
  inputStructReady.tpsModuleParameters.performQuarterStitching = false ;
  tpsObject        = tpsClass( inputStructReady ) ;
  tpsObject        = perform_quarter_stitching( tpsObject ) ;
  extendedFlux     = extend_tps_flux( tpsObject ) ;

% the extendedFlux should be the same as the originalFlux

  mlunit_assert( max( max( abs( originalFlux - extendedFlux ) ) ) < 1e-9, ...
      'Original and extended flux not identical in 2048-cadence test!' ) ;
 
  disp('') ;
  
return

% and that's it!

%
%
%