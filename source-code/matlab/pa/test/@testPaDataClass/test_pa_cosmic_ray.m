function self = test_pa_cosmic_ray(self)
%
% test_pa_cosmic_ray -- unit test for Photometric Analysis cosmic ray cleaning algorithms
%
% test_pa_cosmic_ray tests the cosmic-ray cleaning requirements of Photometric Analysis,
% specifically the requirements:
%
% 317.PA.1:  PA shall remove cosmic ray events from photometric data
% 317.PA.6:  PA shall generate cosmic ray correction tables for background and target data
% 219.PA.1:  PA shall calculate and store cosmic ray metadata including the following
%            information:
%            1.  Hit rates
%            2.  Mean energy
%            3.  Energy variance
%            4.  Energy skewness
%            5.  Energy kurtosis
%
% This function is intended to be used in the context of mlunit.  The syntax for executing
% the test stanalone is:
%
%     run(text_test_runner,testPaDataClass('test_pa_cosmic_ray')) ;
%
% Version date:  2008-December-08.
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

% Load the input data structures which contain cosmic rays 

  initialize_soc_variables ;
  testDataPath = [socTestDataRoot,'/pa/unit-tests/cosmic-rays'] ;
  load(fullfile(testDataPath,'paInputsCR')) ;
  
% load the previous results for regression purposes

  load(fullfile(testDataPath,'paCRResultsCache')) ;
  
% call the main workhorse function with the data structures for the background

  cosmic_ray_test( inputBkgdCR, ...
      bkgdRegressionEvents, bkgdRegressionMetrics, bkgdRegressionData, ...
      false ) ;

% call the main workhorse function with the data structures for the targets

  cosmic_ray_test( inputTargCR, ...
      targRegressionEvents, targRegressionMetrics, targRegressionData, ...
      true ) ;

% cleanup:  delete the state file

  delete('pa_cr_unit_test_state_file.mat') ;
  
%=========================================================================================

% function which performs minimal subset of update_pa_inputs for the purposes of this test

function paStruct = update_input_structs( paStruct )

% add the necessary fields

  paStruct.paFileStruct.paStateFileName = 'pa_cr_unit_test_state_file.mat' ;
  paStruct.backgroundPolyStruct = struct([]) ;
  paStruct.motionPolyStruct = struct([]) ;
  paStruct = rmfield(paStruct,{'backgroundBlobs','motionBlobs','calUncertaintyBlobs'}) ;
  
return

% and that's it!

%
%
%

%=========================================================================================

% function which does the main work, since we need to do fairly similar things with the
% background and target data structures as far as cosmic rays are concerned

function cosmic_ray_test( dataStruct, ...
    regressionEvents, regressionMetrics, regressionPixels, ...
    isTarget )

% get the current rand state and set it to a desired, fixed one, since the cosmic ray
% cleaner only produces identical-to-the-digit output for a given initial rand state.
% Cosmic ray cleaning uses rand!  Who knew?

  randState = get_rand_state ;
  rand('twister', 90125) ;

% set up functions, strings, etc, depending on whether isTarget is true (target data) or
% false (background data)

  if (isTarget == true)
      
      goodMetricsField = 'targetStarCosmicRayMetrics' ;
      goodEventsField  = 'targetStarCosmicRayEvents' ;
      badMetricsField  = 'backgroundCosmicRayMetrics' ;
      badEventsField   = 'backgroundCosmicRayEvents' ;
      pixelField       = 'targetStarDataStruct' ;
      crCleanupCommand = 'clean_target_cosmic_rays' ;
      goodString = 'Target' ;
      badString  = 'Background' ;
      
  else % background

      goodMetricsField = 'backgroundCosmicRayMetrics' ;
      goodEventsField  = 'backgroundCosmicRayEvents' ;
      badMetricsField  = 'targetStarCosmicRayMetrics' ;
      badEventsField   = 'targetStarCosmicRayEvents' ;
      pixelField       = 'backgroundDataStruct' ;
      crCleanupCommand = 'clean_background_cosmic_rays' ;
      goodString = 'Background' ;
      badString  = 'Target' ;
      
  end
  
  crCleanupString = ['[paObject,resultStruct]=', crCleanupCommand,...
      '(paObject,resultStruct) ;' ] ;
  
% perform a minimal subset of the update_pa_inputs activity, to wit:  add paFileStruct,
% backgroundPolyStruct, and motionPolyStruct fields (all empty) and remove
% backgroundBlobs, motionBlobs, and calUncertaintyBlobs; initialize the state file

  dataStruct  = update_input_structs( dataStruct ) ;
  cosmicRayEvents = [];
  nValidPixels = zeros(size(dataStruct.cadenceTimes.gapIndicators)) ;
  pixelCoordinates = [] ;
  save(dataStruct.paFileStruct.paStateFileName, 'cosmicRayEvents', 'nValidPixels', 'pixelCoordinates') ;
  if (~isTarget)
      dummyStruct = struct([]) ;
      save(dataStruct.paFileStruct.paStateFileName, 'dummyStruct', '-append') ;
  end
  
% convert inputs to 1-based and construct objects from the data structure

  dataStruct   = convert_pa_inputs_to_1_base( dataStruct ) ;
  paObject     = paDataClass( dataStruct ) ;
 
% initialize a results structure

  resultStruct = initialize_pa_output_structure( paObject ) ;  
  nCadences = resultStruct.endCadence - resultStruct.startCadence + 1 ;
  
% invoke the cosmic-ray cleaning process and metric-computing process

  eval( crCleanupString ) ;
  resultStruct = compute_pa_cosmic_ray_metrics( paObject, resultStruct ) ;
  
% make sure that the correct computations were carried out; this tests one portion of
% requirement 317.PA.6 (generation of correction tables)

  goodCosmicsComputed = ~isempty(resultStruct.(goodEventsField)) ;
  goodMetricsComputed = (resultStruct.(goodMetricsField).empty == false) ;
  badCosmicsComputed  = ~isempty(resultStruct.(badEventsField)) ;
  badMetricsComputed  = (resultStruct.(badMetricsField).empty == false) ;
  mlunit_assert( goodCosmicsComputed, ...
      [goodString,' cosmic rays not computed on ', goodString, ' input structure!'] ) ;
  mlunit_assert( goodMetricsComputed, ...
      [goodString,' cosmic ray metrics not computed on ', goodString, ' input structure!'] ) ;
  mlunit_assert( ~badCosmicsComputed, ...
      [badString,' cosmic rays computed on ', goodString, ' input structure!'] ) ;
  mlunit_assert( ~badMetricsComputed, ...
      [badString,' cosmic ray metrics computed on ', goodString, ' input structure!'] ) ;
  
% make sure that the fields of the cosmic ray correction table are complete; this is an
% additional, implicit requirement of 317.PA.6 (correction tables)

  fieldsPresent = isfield(resultStruct.(goodEventsField), ...
      {'ccdRow', 'ccdColumn', 'mjd', 'delta'}) ;
  mlunit_assert( all(fieldsPresent), ...
      [lower(goodString),'CosmicRayEvents struct fields not correct!'] ) ;
  
% make sure that all of the necessary metrics have been computed; this tests requirement
% 219.PA.1 (metrics)

  hitRateOK = length(resultStruct.(goodMetricsField).hitRate.values) ...
      == nCadences ;
  meanEnergyOK = length(resultStruct.(goodMetricsField).meanEnergy.values) ...
      == nCadences ;
  varianceOK = length(resultStruct.(goodMetricsField).energyVariance.values) ...
      == nCadences ;
  skewnessOK = length(resultStruct.(goodMetricsField).energySkewness.values) ...
      == nCadences ;
  kurtosisOK = length(resultStruct.(goodMetricsField).energyKurtosis.values) ...
      == nCadences ;
  allMetricsOK = hitRateOK && meanEnergyOK && varianceOK && skewnessOK && kurtosisOK ;
  mlunit_assert( allMetricsOK, ...
      [goodString,' cosmic ray metrics not properly computed!'] ) ;
  
% perform regression test of the cosmic ray information, including the pixel data after
% cleaning.  This implicitly tests requirement 317.PA.1 (removal of cosmic ray events).
% Note that this requires breaking into the paObject to get the current background or
% target pixels.  

   eventRegressionOK = isequal(regressionEvents, ...
       resultStruct.(goodEventsField)) ;
   mlunit_assert( eventRegressionOK, ...
       [goodString,' cosmic ray event regression failed!'] ) ;
   metricsRegressionOK = isequal(regressionMetrics, ...
       resultStruct.(goodMetricsField)) ;
   mlunit_assert( metricsRegressionOK, ...
       [goodString,' cosmic ray regression failed!'] ) ;
   paStruct = struct(paObject) ;
   pixelRegressionOK = isequal(regressionPixels, ...
       paStruct.(pixelField)) ;
   mlunit_assert( pixelRegressionOK, ...
       [goodString,' cosmic ray removal from pixels regression failed!'] ) ;
   
% restore rand to its original state

  set_rand_state(randState) ;
  
return

% and that's it!

%
%
%

