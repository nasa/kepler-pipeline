function self = test_prepare_fpgDataStruct( self )
%
% test_prepare_fpgDataStruct -- unit test of prepare_fpgDataStruct
%
% This unit test verifies that the prepare_fpgDataStruct tool (for use with focal plane
%    geometry in interactive mode) operates properly when the necessary inputs are
%    provided, and that it catches unacceptable inputs when they are provided.  It also
%    tests that both user-provided and default-valued field generation are operating
%    properly.  
%
% This test operates in the mlunit context, and can be run independent of the other tests
% with the command:
%
%      run(text_test_runner, fpgTestClass('test_prepare_fpgDataStruct')) ;
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
%         add test of reportGenerationEnabled field.
%     2008-December-12, PT:
%         delete obsolete ephemeris file cleanup.
%
%=========================================================================================

% first things first:  figure out where we are running from (the FPG development laptop or
% a SOC workstation), and set the location of the test files accordingly:

  setup_fpg_paths_and_files ;

%=========================================================================================
%  
% First test:  prepare an fpgDataStruct using the default options
%
%=========================================================================================

  raDec2PixModel = rd2pm ;
  testExecution = true ;
  load fcConstants ;
  
% define the fakedata generation to make 1 cadence which takes 0.02 days, starting on MJD
% 54936.5
  
  mjdRange = [54936.5 54936.5+0.02] ;
  
  prepare_fpgDataStruct ;
  
  fpgDataObject = fpgDataClass( fpgDataStruct ) ;
  
  fpgDataStructDefault = fpgDataStruct ;
  clear fpgDataStruct ;
  
  cleanup_after_prepare_fpgDataStruct ;
  clear fpgDataObject ;
  
%=========================================================================================
%  
% Second test:  prepare an fpgDataStruct using user-specified options
%
%=========================================================================================

% define the fakedata generation to make 3 cadence which take 0.02 days each, starting on
% MJD 54936.5, and use the 3rd cadence as reference

  mjdRange = [54936.5 54936.5+3*0.02] ;
  mjdRefCadence = 54937 ;
  pointingFakeData = [1/7200 -1/7200 0 ; 0 0 0 ; 0 0 0] ;
  
% define all the data fields to be different from their default values

  excludedModules = 2 ; excludedOutputs = 4 ;
  rowGridValues = [350 650] ; columnGridValues = [250 950] ;
  pointingRefCadence = [290.6673   44.4944   -0.0026] ;
  fitPointingRefCadence = true ; 
  fitPlateScaleFlag = false ;
  tolX = 1e-7 ; tolFun = 2e-7 ; tolSigma = 3e-1 ;
  doRobustFit = false ;
  reportGenerationEnabled = false ;
  
  prepare_fpgDataStruct ;
  fpgDataObject = fpgDataClass( fpgDataStruct ) ;
  
% lop off the raDec2PixModel and fcConstants from each structure, and test to make sure
% that none of the fields are identical, demonstrating that the default and non-default
% options produce different data structures

  fpgDataStruct = rmfield(fpgDataStruct, 'raDec2PixModel') ;
  fpgDataStruct = rmfield(fpgDataStruct, 'fcConstants') ;
  
  fpgDataStructDefault = rmfield(fpgDataStructDefault, 'raDec2PixModel') ;
  fpgDataStructDefault = rmfield(fpgDataStructDefault, 'fcConstants') ;
  
  fpgDataStructFieldNames = fieldnames(fpgDataStruct) ;
  
  for iField = 1:length(fpgDataStructFieldNames)
      msg = ['fpgDataStruct.',fpgDataStructFieldNames{iField},' fields are identical'] ;
      assert_not_equals( getfield(fpgDataStruct, fpgDataStructFieldNames{iField}), ...
          getfield(fpgDataStructDefault, fpgDataStructFieldNames{iField}), msg ) ;
  end
  
%=========================================================================================
%  
% Third test:  mandatory data is missing
%
%=========================================================================================
  
% demonstrate that fpgDataStruct can't be constructed without the mjdRange variable
% present

  cleanup_after_prepare_fpgDataStruct ;
  
  clear mjdRange ;
  try_to_catch_error_condition( 'prepare_fpgDataStruct', 'mjdRangeBad', 'caller' ) ;
  
  mjdRange = [54936.5 54936.5+3*0.02] ;
  
%=========================================================================================
%  
% Fourth test:  mandatory data is screwed up
%
%=========================================================================================
  
% here we exercise the other ways that the error statements in prepare_fpgDataStruct can
% be executed.  

% first errors in mjdRange

  mjdRange = 54936.5 ;
  try_to_catch_error_condition( 'prepare_fpgDataStruct', 'mjdRangeBad', 'caller' ) ;

  mjdRange = [54936.5 54936.5 ; 54936.5 54936.5] ;
  try_to_catch_error_condition( 'prepare_fpgDataStruct', 'mjdRangeBad', 'caller' ) ;

  mjdRange = ['string'] ;
  try_to_catch_error_condition( 'prepare_fpgDataStruct', 'mjdRangeBad', 'caller' ) ;

  mjdRange = [54936 54935] ;
  try_to_catch_error_condition( 'prepare_fpgDataStruct', 'mjdRangeBad', 'caller' ) ;
  
  mjdRange = [54936 54937+i] ;
  try_to_catch_error_condition( 'prepare_fpgDataStruct', 'mjdRangeBad', 'caller' ) ;
  
  mjdRange = [54936 54937] ;
  
% next errors in mjdRefCadence

  mjdRefCadence = [54936 54936] ;
  try_to_catch_error_condition( 'prepare_fpgDataStruct', 'mjdRefCadenceBad', 'caller' ) ;

  mjdRefCadence = 'a' ;
  try_to_catch_error_condition( 'prepare_fpgDataStruct', 'mjdRefCadenceBad', 'caller' ) ;

  mjdRefCadence = 54936+i ;
  try_to_catch_error_condition( 'prepare_fpgDataStruct', 'mjdRefCadenceBad', 'caller' ) ;

% and that's it!

%
%
%
