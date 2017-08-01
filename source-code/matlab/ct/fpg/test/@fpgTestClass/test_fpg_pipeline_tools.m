function self = test_fpg_pipeline_tools(self)
%
% test_fpg_pipeline_tools -- unit test for FPG pipeline input and output reader and writer
%
% The test_fpg_pipeline_tools unit test exercises the auto-generated functions
%    read_FpgInputs, write_FpgInputs, read_FpgOutputs, write_FpgOutputs.  It tests for the
%    following:
%
% ==> The data structure which is imported/exported by the FpgInputs functions is the
%     correct one for the FPG Matlab code.
% ==> The "round trip" through write_FpgInputs and read_FpgInputs does not make any
%     functional changes to the input data structure.
% ==> The data structure produced by fpg_matlab_controller is the correct one for the
%     FpgOutputs functions.
% ==> The "round trip" through write_FpgOutputs and read_FpgOutputs does not make any
%     changes to the output data structure.
%
% Note that in the case of the FpgInputs routines, the order of fields is changed, row
%    vectors of primitive data types are changed to column vectors, and other
%    organizational changes are made.  This test demonstrates that the resulting changes
%    are not functional, ie, the structure which is produced after a "round trip"
%    instantiates an fpgDataClass object which is identical to the original.
%
% This test is intended to operate in the mlunit context.  To run, use the following
%    syntax:
%
%      run(text_test_runner, fpgTestClass('test_fpg_pipeline_tools'));
%
% Version date:  2008-December-20.
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
%     2008-December-20, PT:
%         add test of report production.
%     2008-December-12, PT:
%         delete obsolete ephemeris file cleanup.
%     2008-October-30, PT:
%         fix a typo.
%     2008-September-19, PT:
%         add pauses after fpg_matlab_controller calls so that close all statement has
%         time to execute.
%
%=========================================================================================

% select the appropriate path and so forth

  setup_fpg_paths_and_files ;
  fpgInputsFile  = 'fpg_inputs.1' ;
  fpgOutputsFile = 'fpg_outputs.1' ;
  
% load a cached input structure in interactive format and update its raDec2PixModel

  load(fullfile(testFileDir,'fpgTestDataStruct')) ;
  fpgDataStruct.raDec2PixModel = rd2pm ;
  
% set the data struct to produce a report

  fpgDataStruct.reportGenerationEnabled = true ;
  
% convert to pipeline format

  fpgDataStructPipeline1 = convert_fpg_inputs_to_pipeline( fpgDataStruct ) ;
  
% perform the fit and capture the results

  fpgOutputs1 = fpg_matlab_controller( fpgDataStructPipeline1 ) ;
  pause(5) ;
  load fpgResultsStruct ;
  fpgResultsStruct1 = fpgResultsStruct ;
    
% send the input structure through the round trip process

  write_FpgInputs( fpgInputsFile, fpgDataStructPipeline1 ) ;
  fpgDataStructPipeline2 = read_FpgInputs( fpgInputsFile ) ;
  
% because the field order in the raDec2PixModel is changed, and because Matlab's class
% constructor is fussy, reorder the fields in the reloaded model to match the original
% order

  fpgDataStructPipeline2.raDec2PixModel = orderfields( ...
      fpgDataStructPipeline2.raDec2PixModel, fpgDataStructPipeline1.raDec2PixModel ) ;
  
% perform a new fit and test for identicality

  fpgOutputs2 = fpg_matlab_controller( fpgDataStructPipeline2 ) ;
  pause(5) ;
  load fpgResultsStruct ;
  fpgResultsStruct2 = fpgResultsStruct ;
  assert_equals( fpgResultsStruct1, fpgResultsStruct2, ...
      'unequal fpgResultsStruct structures in test_fpg_pipeline_tools!' ) ;
    
% send the output structure through the round-trip process

  write_FpgOutputs( fpgOutputsFile, fpgOutputs1 ) ;
  fpgOutputs3 = read_FpgOutputs( fpgOutputsFile ) ;
  assert_equals( fpgOutputs1, fpgOutputs3, ...
      'unequal fpg output data structures in test_fpg_pipeline_tools!' ) ;
  
% cleanup:  remove the files written by the writers

  delete( fpgInputsFile ) ;
  delete( fpgOutputsFile ) ;
  delete( 'fpgDataStruct.mat' ) ;
  delete( 'fpgResultsStruct.mat' ) ;
  
% delete the blob files written when the original struct was converted, and after
% execution

  cleanup_fpgDataStruct_blob_files( fpgDataStructPipeline2 ) ;
  delete(fpgOutputs1.geometryBlobFileName) ;
  delete(fpgOutputs2.geometryBlobFileName) ;
  
% cleanup the figure files 

  cleanup_fpg_figure_files ;