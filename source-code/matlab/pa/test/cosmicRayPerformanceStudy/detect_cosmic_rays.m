function [detectedCREvents, detectedCRMetrics, realCRMetrics] = detect_cosmic_rays( ...
    paInputStruct, realCREventsStruct )
%
% detect_cosmic_rays -- perform cosmic ray cleaning on a PA data structure and return
%    event values and metrics
%
% [detectedCREvents, detectedCRMetrics] = detect_cosmic_rays( paInputStruct ) performs
%    cosmic ray cleaning on a PA input structure (either a background struct or a target
%    struct) and returns a structure of the detected cosmic ray events and metrics related
%    to same.
%
% [..., realCRMetrics] = detect_cosmic_rays( ..., realCREventsStruct ) also returns the
%    metrics for the actual, "ground truth" cosmic ray events.
%
% Version date:  2008-December-11.  
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

% just in case the user wants to have truly regressible results, set the random number
% generator 

  randState = get_rand_state ;
  rand('twister', 90125) ;

% detect whether this is a background or a target structure

  if (isempty(paInputStruct.targetStarDataStruct))
      isBkgd = true ;
      eventsStruct = 'backgroundCosmicRayEvents' ;
      metricsStruct = 'backgroundCosmicRayMetrics' ;
      crMethod = 'clean_background_cosmic_rays' ;
  else
      isBkgd = false ;
      eventsStruct = 'targetStarCosmicRayEvents' ;
      metricsStruct = 'targetStarCosmicRayMetrics' ;
      crMethod = 'clean_target_cosmic_rays' ;      
  end
  isTarg = ~isBkgd ;
  
% perform a minimal subset of the update_pa_inputs activity, to wit:  add paFileStruct,
% backgroundPolyStruct, and motionPolyStruct fields (all empty) and remove
% backgroundBlobs, motionBlobs, and calUncertaintyBlobs; initialize the state file

  paInputStruct  = update_input_structs( paInputStruct ) ;
  cosmicRayEvents = struct([]) ;
  nValidPixels = zeros(size(paInputStruct.cadenceTimes.gapIndicators)) ;
  pixelCoordinates = [];
  save(paInputStruct.paFileStruct.paStateFileName, 'cosmicRayEvents', 'nValidPixels', 'pixelCoordinates') ;
  
% if this is a target struct, make sure that it is set to be the last invocation

  if (isTarg)
      paInputStruct.lastCall = 1 ;
  end
  
% convert inputs to 1-based and construct objects from the data structure

  paInputStruct   = convert_pa_inputs_to_1_base( paInputStruct ) ;
  paObject     = paDataClass( paInputStruct ) ;
 
% initialize a results structure

  resultStruct = initialize_pa_output_structure( paObject ) ;  
  nCadences = resultStruct.endCadence - resultStruct.startCadence + 1 ;
  
% perform the cleaning and generation of cosmic ray metrics

  [paObject,resultStruct] = feval( crMethod, paObject, resultStruct ) ;
  resultStruct = compute_pa_cosmic_ray_metrics( paObject, resultStruct ) ;
  detectedCREvents = resultStruct.(eventsStruct) ;
  detectedCRMetrics = resultStruct.(metricsStruct) ;
    
  
% if the user wants to generate metrics from the real cosmic rays, do that now

  if (nargin == 2)
      cosmicRayEvents = realCREventsStruct ;
      save(paInputStruct.paFileStruct.paStateFileName, 'cosmicRayEvents', '-append') ;
      resultStruct = compute_pa_cosmic_ray_metrics( paObject, resultStruct ) ;
      realCRMetrics = resultStruct.(metricsStruct) ;
  end
  
% cleanup:  remove the state file and restore the rand generator

  delete(paInputStruct.paFileStruct.paStateFileName) ;
  set_rand_state(randState) ;
  
return

% and that's it!

%
%
%

  
%=========================================================================================

% function which performs minimal subset of update_pa_inputs for the purposes of this test

function paStruct = update_input_structs( paStruct )

% add the necessary fields

  paStruct.paFileStruct.paStateFileName = 'pa_state_file.mat' ;
  paStruct.backgroundPolyStruct = struct([]) ;
  paStruct.motionPolyStruct = struct([]) ;
  paStruct = rmfield(paStruct,{'backgroundBlobs','motionBlobs','calUncertaintyBlobs'}) ;
  
return

% and that's it!

%
%
%


