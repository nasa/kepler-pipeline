function self = test_fpg_gapped_cadence( self )
%
% test_fpg_gapped_cadence -- test that the FPG fitter properly handles a gapped cadence.
%    When a gapIndicator is set in the pipeline-format input structure, that cadence
%    should be left out of the fit entirely.  This is indicated as follows:
%
% ==> The corresponding gap indicator is set in the fitted pointings in the output data
%     structure.
% ==> The data status map of the fit is set to bad status for all 84 mod/outs on the 
%     gapped cadence.
%
% This test is intended to operate in the mlunit context.  To run, use the following
%    syntax:
%
%      run(text_test_runner, fpgTestClass('test_fpg_gapped_cadence'));
%
% Version date:  2008-September-19.
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
%     2008-September-19, PT:
%         insert pause after fpg_matlab_controller statement so figure closure takes hold.
%
%=========================================================================================

% initialize paths and load a data structure for fitting

  setup_fpg_paths_and_files ;
  load(fullfile(testFileDir,'fpgTestDataStruct')) ;
  fpgDataStruct.raDec2PixModel = rd2pm ;
  
% convert to pipeline format

  fpgDataStructPipeline = convert_fpg_inputs_to_pipeline( fpgDataStruct ) ;
  
% instantiate an fpgDataClass object and get its dataStatusMap with no gaps

  fpgDataObjectNoGap = fpgDataClass( fpgDataStructPipeline ) ;
  fpgDataObjectNoGap = fpg_data_reformat( fpgDataObjectNoGap ) ;
  dataStatusMapNoGap = get(fpgDataObjectNoGap, 'dataStatusMap') ;
  
% perform the fit

  fpgOutputNoGap = fpg_matlab_controller( fpgDataStructPipeline ) ;
  pause(5) ;
  
% insert a gap into the fpgDataStructPipeline in the 4th cadence, and repeat the steps
% above

  fpgDataStructPipeline.timestampSeries.gapIndicators(4) = true ;
  fpgDataObjectGapped = fpgDataClass( fpgDataStructPipeline ) ;
  fpgDataObjectGapped = fpg_data_reformat( fpgDataObjectGapped ) ;
  dataStatusMapGapped = get(fpgDataObjectGapped, 'dataStatusMap') ;
  fpgOutputGapped = fpg_matlab_controller( fpgDataStructPipeline ) ;
  pause(5) ;
  
% Perform the tests.  We expect to see the following:
%
% ==> data on the 4th cadence of the ungapped dataStatusMap is all good

  mlunit_assert(isempty(find(dataStatusMapNoGap(:,4)==0)), ...
      'Unexpected bad data in dataStatusMapNoGap in test_fpg_gapped_cadence!') ;
  
% ==> no gap indicators set in the output of the fitted pointing of the 4th cadence

  gapIndices = [fpgOutputNoGap.spacecraftAttitudeStruct.ra.gapIndices(:) ...
      fpgOutputNoGap.spacecraftAttitudeStruct.dec.gapIndices(:) ...
      fpgOutputNoGap.spacecraftAttitudeStruct.roll.gapIndices(:)] ;
  
  assert(isempty(gapIndices), ...
      'Unexpected gapped data in fpgOutputNoGap in test_fpg_gapped_cadence!') ;
  
% ==> data on the 4th cadence of the gapped dataStatusMap is all bad

  mlunit_assert(isempty(find(dataStatusMapGapped(:,4)~=0)), ...
      'Unexpected good data in dataStatusMapGapped in test_fpg_gapped_cadence!') ;

% ==> all gap indicators set in the output of the fitted pointing of the 4th cadence

  gapIndices = [fpgOutputGapped.spacecraftAttitudeStruct.ra.gapIndices(:) ...
      fpgOutputGapped.spacecraftAttitudeStruct.dec.gapIndices(:) ...
      fpgOutputGapped.spacecraftAttitudeStruct.roll.gapIndices(:)] ;
  
  assert_equals(gapIndices,[3 3 3], ...
      'Unexpected ungapped data in fpgOutputGapped in test_fpg_gapped_cadence!') ;
  
% That's all the testing that needs doing.  Now we cleanup:

  delete( 'fpgDataStruct.mat' ) ;
  delete( 'fpgResultsStruct.mat' ) ;
  cleanup_fpg_figure_files ;
  delete(fpgOutputGapped.geometryBlobFileName) ;
  delete(fpgOutputNoGap.geometryBlobFileName) ;
  cleanup_fpgDataStruct_blob_files( fpgDataStructPipeline ) ;
  
