function self = feature_test_prf_star_selection(self)
%
% feature_test_prf_star_selection -- unit test of PRF star selection procedure for single or
% multiple PRFs per channel.  Specifically, the test verifies the following properties of
% the compute_downselection method of the prfCreationClass:
%
% ==> Are the selected stars for each fit in the correct region?
% ==> Are the selected stars for each fit in the requested magnitude range?
% ==> Are the selected stars for each fit in the requested range of crowding metric?
% ==> Is the expected region of the mod/out selected for 1 PRF per mod/out fitting?
% ==> If sufficient stars cannot be located, will the error-exit execute correctly?
%
% There is one other key feature of the star-selection process which is not tested here:
% the increase of the region fraction if sufficient stars cannot be located in a given
% region.  This feature is tested in the feature test, multiple_prf_generation_test.
%
% This test is intended to operate in the context of mlunit, the correct execution syntax
% is:
%
%     run(text_test_runner, prfTestClass('feature_test_prf_star_selection')) ;
%
% Version date:  2010-August-17.
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
%     2010-August-17, PT:
%         renamed test so that it is not autorun, since it always fails.
%     2008-December-12, PT:
%         remove reference to obsolete ephemeris cleanup procedure.
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
  
% turn off the nearly singular matrix warnings which clutter up the display  
  
  warning('off','MATLAB:nearlySingularMatrix') ;
  
% first test:  loop over regions, perform downselection, and verify that the selected
% stars are in the correct region, with the correct magnitudes and extended crowding
% metric values

  prfCreationObject = prfCreationClass(prfInputStruct);
  prfCreationObject = remove_background_from_targets(prfCreationObject);
  prfCreationObject = compute_star_positions(prfCreationObject);

  [rowRange, colRange, rowCenter, colCenter] = compute_prf_region_limits( fcConstants, ...
      prfInputStruct.prfConfigurationStruct.regionMinSize ) ;
  
  for iRegion = 1:prfInputStruct.prfConfigurationStruct.numPrfsPerChannel
      disp(['...region, range, magnitude test, region ',num2str(iRegion),' ...']) ;
      prfCreationObject = set_row_column_limits( prfCreationObject, iRegion, ...
          prfInputStruct.prfConfigurationStruct.regionMinSize ) ;
      prfCreationObject = compute_downselection(prfCreationObject) ;
      targetStarsStruct = get(prfCreationObject,'targetStarsStruct') ;
      [selectedTargets,nStars] = get_selected_target_info(prfCreationObject) ;
      targetStars = find(selectedTargets == 1) ;
      magnitude = [targetStarsStruct(targetStars).keplerMag] ;
      magnitudeOK = ( magnitude >= prfInputStruct.prfConfigurationStruct.magnitudeRange(1) & ...
          magnitude <= prfInputStruct.prfConfigurationStruct.magnitudeRange(2) ) ;
      mlunit_assert( all(magnitudeOK), ...
          'bad magnitudes detected' ) ;
      crowding = [targetStarsStruct(targetStars).extendedCrowdingMetric] ;
      crowdingOK = ( crowding >= prfInputStruct.prfConfigurationStruct.crowdingThreshold ) ;
      mlunit_assert( all(crowdingOK), ...
          'bad crowding metrics detected' ) ;
      for iStar = targetStars(:)'
          row = targetStarsStruct(iStar).row(1) ;
          col = targetStarsStruct(iStar).column(1) ;
          mlunit_assert( row >= rowRange(iRegion,1) && ...
              row <= rowRange(iRegion,2) &&    ...
              col >= colRange(iRegion,1) &&    ...
              col <= colRange(iRegion,2)     , ...
              ['bad coordinates detected in region ',num2str(iRegion), ...
              ', star # ',num2str(iStar)] ) ;
      end
  end
      
% single PRF per mod/out:  set the appropriate flag in the prfInputStruct and instantiate
% it

  prfInputStruct.prfConfigurationStruct.numPrfsPerChannel = 1 ;
  prfCreationObject = prfCreationClass(prfInputStruct);

% set the region limits and make sure that they are set at the center of the mod/out even
% though we ask for region 1

  display('... single PRF star selection test ...') ;
  prfCreationObject = set_row_column_limits( prfCreationObject, 1, ...
      prfInputStruct.prfConfigurationStruct.regionMinSize ) ;
  prfCreationStruct = struct(prfCreationObject) ;
  prfConfigurationStruct = prfCreationStruct.prfConfigurationStruct ;
  rowLimit    = prfConfigurationStruct.rowLimit ;
  columnLimit = prfConfigurationStruct.columnLimit ;
  prfRow    = prfCreationStruct.prfRow ;
  prfColumn = prfCreationStruct.prfColumn ;
  assert_equals( rowLimit, rowRange(5,:), ...
      'Row range not correct for single-PRF fit' ) ;
  assert_equals( columnLimit, colRange(5,:), ...
      'Column range not correct for single-PRF fit' ) ;
  assert_equals( prfRow, rowCenter(5), ...
      'Row center not correct for single-PRF fit' ) ;
  assert_equals( prfColumn, colCenter(5), ...
      'Column center not correct for single-PRF fit' ) ;

% remove all but two stars and make sure that the PRF fit exits with the correct error

  display('... insufficient # of stars test ...') ;
  prfInputStruct.prfConfigurationStruct.numPrfsPerChannel = 1 ;
  prfInputStruct.targetStarsStruct = prfInputStruct.targetStarsStruct(1:2) ;
  try_to_catch_error_condition('a=prf_matlab_controller(prfInputStruct)', ...
      'tooFewStars',prfInputStruct,'prfInputStruct') ;

% turn on the nearly singular matrix warnings
  
  warning('on','MATLAB:nearlySingularMatrix') ;
  
  
% and that's it!

%
%
%
