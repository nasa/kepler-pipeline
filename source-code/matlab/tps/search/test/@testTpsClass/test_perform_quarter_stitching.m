function self = test_perform_quarter_stitching( self ) 
%
% test_perform_quarter_stitching -- unit test of tpsClass method perform_quarter_stitching
%
% This unit test exercises the following functionality of the method:
%
% ==> Basic functionality -- the method executes correctly when called
% ==> When the performQuarterStitching flag is false, the TPS target data isn't altered by
%     the method
%
% Since the main algorithmic content of the method is actually in the
% quarterStitchingClass, the algorithmic tests are all performed on that class rather than
% on this method.
%
% This test is performed in the mlunit context.  For standalone operation, use the
% following syntax:
%
%      run(text_test_runner, testTpsClass('test_perform_quarter_stitching'));
%
% Version date:  2010-September-27.
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

  disp(' ... testing tpsClass quarter-stitching method ... ') ;

% set the test data path and retrieve the input struct 

  tpsDataFile = 'tps-multi-quarter-struct' ;
  tpsDataStructName = 'tpsInputs' ;
  tps_testing_initialization ;
  
% set the random number generator to the correct value

  s = RandStream('mcg16807','Seed',10) ;
  RandStream.setDefaultStream(s) ;  
  
% instantiate the object and execute the method -- note that this requires first
% validating the inputs, since the input-validator actually also sets values into the
% input struct (grrr...)

  tpsInputs  = validate_tps_input_structure( tpsInputs ) ;
  tpsTargets = tpsInputs.tpsTargets ;
  nTargets   = length(tpsTargets) ;
  nCadences  = length( tpsInputs.cadenceTimes.cadenceNumbers ) ;
  tpsObject  = tpsClass( tpsInputs ) ;
  
  [tpsObject, harmonicTimeSeriesAll]  = perform_quarter_stitching( tpsObject ) ;
  
% retrieve the target data and compare to the originals -- in all cases the gap indices
% should be emptied, the fill indices should be the union of the old fill indices and the
% old gap indices, the flux time series should have a median close to 0 and a MAD which is
% less than 1, and the harmonicTimeSeriesAll should have the correct shape and some values
% which are not -1

  tpsStruct       = struct(tpsObject) ;
  tpsTargetsAfter = tpsStruct.tpsTargets ;
  
  for iTarget = 1:nTargets
      
      mlunit_assert( abs( median( tpsTargetsAfter(iTarget).fluxValue ) ) < 1e-6, ...
          [ 'Median flux for target ', num2str(iTarget), ' not as expected in test 1!' ] ) ;
      mlunit_assert( mad( tpsTargetsAfter(iTarget).fluxValue, 1 ) < 1, ...
          [ 'MAD for target ', num2str(iTarget),' not as expected in test 1!' ] ) ;
      mlunit_assert( isempty( tpsTargetsAfter(iTarget).gapIndices ), ...
          [ 'Gap indicators for target ', num2str(iTarget), ' not as expected in test 1!' ] ) ;
      assert_equals( tpsTargetsAfter(iTarget).fillIndices, ...
          sort( [tpsTargets(iTarget).fillIndices ; tpsTargets(iTarget).gapIndices] ), ...
          [ 'Fill indices for target ', num2str(iTarget), ' not as expected in test 1!' ] ) ;
      % check that outlierFillValues and outlierIndicators have been added
      mlunit_assert( isfield( tpsTargetsAfter(iTarget), 'outlierFillValues' ), ...
          [ 'outlierFillValues for target ', num2str(iTarget), ' do not exist!' ] ) ;
      mlunit_assert( isfield( tpsTargetsAfter(iTarget), 'outlierIndicators' ), ...
          [ 'outlierIndicators for target ', num2str(iTarget), ' do not exist!' ] ) ;
   
  end
  assert_equals( size(harmonicTimeSeriesAll), [nCadences nTargets], ...
      'harmonicTimeSeriesAll dimensions not as expected in test 1!' ) ;
  mlunit_assert( any( harmonicTimeSeriesAll(:) ~= -1 ), ...
      'harmonicTimeSeriesAll values are not as expected in test 1!' ) ;

  
% go back and set the performQuarterStitching flag to false; in this case the input target
% data and output target data should match identically

  tpsInputs.tpsModuleParameters.performQuarterStitching = false ;
  tpsObject = tpsClass( tpsInputs ) ;
  
  [tpsObject, harmonicTimeSeriesAll]  = perform_quarter_stitching( tpsObject ) ;

  tpsStruct       = struct(tpsObject) ;
  tpsTargetsAfter = tpsStruct.tpsTargets ;

  % drop outlierIndicators from tpsTargetsAfter before checking equality -
  % this has to be passed out of the quarter stitcher this way since it is
  % needed by extend_tps_flux and the results struct has not been created
  % when the quarter stitching is run
  tpsTargetsAfter = rmfield( tpsTargetsAfter, 'outlierIndicators' ) ;
  tpsTargetsAfter = rmfield( tpsTargetsAfter, 'outlierFillValues' ) ;
  
  assert_equals( tpsTargets, tpsTargetsAfter, ...
      'tpsTargets structs not identical in test 2!' ) ;
  assert_equals( size(harmonicTimeSeriesAll), [nCadences nTargets], ...
      'harmonicTimeSeriesAll dimensions not as expected in test 2!' ) ;
  mlunit_assert( all( harmonicTimeSeriesAll(:) == -1 ), ...
      'harmonicTimeSeriesAll values are not as expected in test 2!' ) ;
  
  disp('') ;
  
return

% and that's it!

%
%
%
