function self = feature_test_multiple_prf_generation( self )
%
% feature_test_multiple_prf_generation -- feature test of star selection and PRF fitting
% procedure for multiple PRFs per channel. Specifically, the test verifies the following:
%
% ==> Does the selector properly increment the region fraction if insufficient stars are
%     detected?
% ==> When multiple PRFs are requested, does the returned data structure have the right
%     size, and are the 5 PRF data structures different from one another?
% ==> When one PRF is requested, does the returned data structure have the right size?
% ==> Does the blob packaged in the PRF output have the correct structure, when deblobbed,
%     to instantiate an appropriate prfCollectionClass object?
% ==> Does execution fail when the numPrfsPerChannel parameter is set to an illegal value?
%
% This test is intended to operate in the context of mlunit, the correct execution syntax
% is:
%
%     run(text_test_runner, prfTestClass('feature_test_multiple_prf_generation')) ;
%
% Version date:  2008-December-12.
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
%     2008-December-12, PT:
%         remove reference to obsolete ephemeris cleanup procedure.
%     2008-October-22, PT:
%         break out star selection unit test aspects and move those to
%         test_prf_star_selection.  Rename from test_multiple_prf_generation.
%     2008-October-19, PT:
%         update for consistency with current architecture of the PRF fit algorithms.
%     2008-September-30, PT:
%         use numPrfsPerChannel instead of multiplePrfFit.
%
%=========================================================================================

% set paths for test data

  setup_prf_paths ;
  
% load a test data structure and set it up for use here

  load(fullfile(testDataDir,'prfInputStruct_interpolated')) ;
  prfInputStruct.raDec2PixModel = rd2pm ;
  
% extract fcConstants for use later

  fcConstants = prfInputStruct.fcConstants ;
  
% set the multiple PRFs per channel parameters appropriately

  prfInputStruct.prfConfigurationStruct.numPrfsPerChannel = 5 ;
  prfInputStruct.prfConfigurationStruct.regionMinSize  = 0.3 ;
  prfInputStruct.prfConfigurationStruct.regionStepSize = 0.05 ;
  prfInputStruct.prfConfigurationStruct.minStars = 10 ;

% convert the prfInputStruct to 1-based indexing
  
  prfInputStruct = prfInputStruct_convert_to_1_base(prfInputStruct);
  prfInputStruct.backgroundPolyStruct = single_blob_to_struct( ...
      prfInputStruct.backgroundBlob);
  
% decimate the target star data structure; this is done with a pre-arranged pattern which
% has 11 good target stars in each PRF region, plus 2 in the area just outside region 1,
% plus all the non-target stars in all areas

  targetStarsStructOriginal = prfInputStruct.targetStarsStruct ;
  load(fullfile(testDataDir,'starIndicesToKeep_5Regions')) ;
  prfInputStruct.targetStarsStruct = targetStarsStructOriginal(starIndicesToKeep) ;
  
  prfCreationObject = prfCreationClass(prfInputStruct);
  prfCreationObject = remove_background_from_targets(prfCreationObject);
  prfCreationObject = compute_star_positions(prfCreationObject);

% turn off the nearly singular matrix warnings which clutter up the display  
  
  warning('off','MATLAB:nearlySingularMatrix') ;
  
% We need to remove 2 stars from region 1 to force it to enlarge from region fraction of
% 0.3 to 0.35.  To do that, perform star selection for that region and then delete 2 stars

  prfCreationObject = set_row_column_limits( prfCreationObject, 1, ...
      prfInputStruct.prfConfigurationStruct.regionMinSize ) ;
  prfCreationObject = compute_downselection(prfCreationObject) ;
  [selectedTargets,nStars] = get_selected_target_info(prfCreationObject) ;
  targetStars = find(selectedTargets == 1) ;
  nStarsToCut = length(targetStars) - prfInputStruct.prfConfigurationStruct.minStars + 1 ;
  
  prfInputStruct.targetStarsStruct(targetStars(1:nStarsToCut)) = [] ;
  
% now recreate the prfCreationClass object with the even-more-decimated target list  
  
  prfCreationObject = prfCreationClass(prfInputStruct);
  prfCreationObject = remove_background_from_targets(prfCreationObject);
  prfCreationObject = compute_star_positions(prfCreationObject);
  
% perform the multi-PRF per channel fit

  display('... performing initial 5-region PRF fit...') ;
  [prfCreationObject, durationList, prfResultsStruct] = fit_prf( prfCreationObject, ...
      struct([]), 1 ) ;
  display('... initial 5-region PRF completed, starting test diagnostics...') ;
  
% check to make sure that we got 5 PRFs worth of data back in the prfCollectionBlob, that
% they are different from one another, that the collection will instantiate a
% multi-PRF prfCollectionClass object, and that the object has the correct form (ie, it
% has multiple PRFs and is not just a user-interface for a single PRF)

  display('... 5 PRFs test ...') ;
  prfCollectionStruct = prfResultsStruct.prfCollectionStruct ;
  mlunit_assert( length(prfCollectionStruct)==5, ...
      'multi-PRF prfCollectionStruct has incorrect length' ) ;
  for iPrf = 1:5
      for jPrf = iPrf+1:5
          assert_not_equals( prfCollectionStruct(iPrf), prfCollectionStruct(jPrf), ...
              'multi-PRF prfCollectionStruct has identical PRF data structures' ) ;
      end
  end
  prfCollectionObject = prfCollectionClass( prfCollectionStruct, fcConstants ) ;
  interpolateFlag = get(prfCollectionObject,'interpolateFlag') ;
  mlunit_assert( interpolateFlag == 1, ...
      'prfCollectionObject interpolateFlag member has incorrect value' ) ;
      
% remove stars from region 1 until it has too few at the current region fraction; redo the
% fit and demonstrate that the region fraction is increased by the correct amount 
 
  regionFractionNew = prfResultsStruct.regionFractionVector ;
  regionFractionExpect = [prfInputStruct.prfConfigurationStruct.regionMinSize + ...
      prfInputStruct.prfConfigurationStruct.regionStepSize ...
      repmat(prfInputStruct.prfConfigurationStruct.regionMinSize,1,4)] ;
  mlunit_assert( all(abs(regionFractionNew(:)-regionFractionExpect(:)) < eps), ...
      'Region fraction did not increase as expected' ) ;
  
% switch to a single PRF per mod/out and make sure that the fit operates correctly; to
% make this run quickly, use a decimation which produces only 11 target stars in the
% entire mod/out, plus all the rest of the non-target stars

  display('... single PRF test ...') ;
  prfInputStruct.prfConfigurationStruct.numPrfsPerChannel = 1 ;
  load(fullfile(testDataDir,'starIndicesToKeep_1Region')) ;
  prfInputStruct.targetStarsStruct = targetStarsStructOriginal(starIndicesToKeep) ;
  prfCreationObject = prfCreationClass(prfInputStruct);
  prfCreationObject = remove_background_from_targets(prfCreationObject);
  prfCreationObject = compute_star_positions(prfCreationObject);
  [prfCreationObject, durationList, prfResultsStruct] = fit_prf( prfCreationObject, ...
      struct([]), 1 ) ;
  prfCollectionStruct = prfResultsStruct.prfCollectionStruct ;
  mlunit_assert( length(prfCollectionStruct)==1, ...
      'multi-PRF prfCollectionStruct has incorrect length' ) ;
  prfCollectionObject = prfCollectionClass( prfCollectionStruct, fcConstants ) ;
  interpolateFlag = get(prfCollectionObject,'interpolateFlag') ;
  mlunit_assert( interpolateFlag == 0, ...
      'prfCollectionObject interpolateFlag member has incorrect value' ) ;
  clear prfResultsStruct prfCollectionObject prfCollectionStruct ; 
  
% set the # of PRFs per channel to an illegal value and make sure the correct error is
% raised
  
  display('... illegal # of PRFs per mod/out test...') ;
  prfInputStruct.prfConfigurationStruct.numPrfsPerChannel = 2 ;
  try_to_catch_error_condition('a=prf_matlab_controller(prfInputStruct)', ...
      'numPrfsPerChannelInvalid',prfInputStruct,'prfInputStruct') ;
    
% turn on the nearly singular matrix warnings
  
  warning('on','MATLAB:nearlySingularMatrix') ;
  
  
% and that's it!

%
%
%

  