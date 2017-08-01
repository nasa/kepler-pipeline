function self = test_generate_report_soc( self )
%
% test_generate_report_soc -- unit test for generate_report_soc.  This test exercises
% generate_report_soc.  It performs the following tests:
%
% ==> tests that the base workspace is cleared of existing variables and filled with
%     user-supplied ones prior to report generation.
% ==> tests that the base workspace is restored to its original condition after report
%     generation has completed.
% ==> tests that the safety file is deleted after execution.
% ==> tests that restoration of the base workspace occurs correctly even if report
%     generation fails or other malfunctions occur in generate_report_soc.
%
% Note that this test empties the base workspace and then restores it.  It is recommended
% that this test not be executed when irreplacable data is present in the base workspace,
% just in case.
%
% This test is intended to execute in the mlunit context.  To execute, use the following
% syntax:
%
%     run(text_test_runner, rptTestClass('test_generate_report_soc')) ;
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
%    2008-December-12, PT:
%        use socTestDataRoot to set path to the test data.
%    2008-October-31, PT:
%        return to original directory after execution.  Test report generation with
%        various values of warnState.
%    2008-October-27, PT:
%        generate_report_soc no longer takes a date argument.
%    2008-October-24, PT:
%        change to keep up to date with generate_report_soc:  base workspace is no longer
%        cleared prior to report generation.
%
%=========================================================================================

% change directory into the directory which contains the report files

  initialize_soc_variables ;
  testDataDir = [socTestDataRoot,'/rpt/unit-tests'] ;

  currentDir = cd ;
  cd(testDataDir) ;
  
% clear the last warning out

  lastwarn('') ;
  
% look to see if the base workspace is empty; if so, put in some dummy variables

  usedDummyVars = false ;
  baseWorkspaceBefore = evalin('base','who') ;
  if (isempty(baseWorkspaceBefore))
      usedDummyVars = true ;
      assignin('base','testVar1',7) ;
      assignin('base','testVar2','abc') ;
      assignin('base','testVar3',2092) ;
      baseWorkspaceBefore = evalin('base','who') ;
  end
  
% call the report generator with a variable which is to be used in the report generation

  [reportName,tempVarList] = generate_report_soc('buildtest_report_soc','testrep', ...
      'pdf', [], [], 'sampleVar',10) ;
  warnString = lastwarn ; 
  if (strcmp(warnString,'generate_report_soc:  error occurred generating report') || ...
      strcmp(warnString,...
      'generate_report_soc:  report generation disabled due to previous errors'))
      error('Report generation failed during use of .m format') ;
      lastwarn('') ;
  end
  baseWorkspaceAfter = evalin('base','who') ;

% check 1:  tempVarList should not be the same as baseWorkspaceBefore

  assert_not_equals( tempVarList, baseWorkspaceBefore, ...
      'Base workspace is the same before and during report generation' ) ;
  
% check 2:  baseWorkspaceBefore should be equal to baseWorkspaceAfter

  assert_equals( baseWorkspaceBefore, baseWorkspaceAfter, ...
      'Base workspace is the not the same before and after report generation' ) ;

% check 3:  tempVarList should include sampleVar

  assert( ismember({'sampleVar'},tempVarList), ...
      'Base workspace during report generation is not as expected' ) ;
  
% check 4:  the safety file should not be present in the local directory

  safetyString = 'base_workspace_safety_' ;
  localDir = dir ; 
  for count = 1:length(localDir)
      mlunit_assert( ~strncmp(localDir(count).name,safetyString,length(safetyString)), ...
          'safety file not deleted after report generation' ) ;
  end
  
% check 5:  if we call the generate_report_soc with bad arguments, it still puts the base
% workspace back the way it was supposed to and cleans up the safety file

  [reportFileName,tempVarList] = generate_report_soc('buildtest_report_soc','testrep', ...
      'pdf', [], [], 'sampleVar') ;
  baseWorkspaceAfter = evalin('base','who') ;
  assert_equals( baseWorkspaceBefore, baseWorkspaceAfter, ...
      'Base workspace is the not the same before and after failed report generation' ) ;
  localDir = dir ; 
  for count = 1:length(localDir)
      mlunit_assert( ~strncmp(localDir(count).name,safetyString,length(safetyString)), ...
          'safety file not deleted after failed report generation' ) ;
  end
  
% check 6:  executes correctly with warnState values set, and with the .rpt file instead
% of the .m file as an argument

  lastwarn('') ;
  reportFileName = generate_report_soc('test_report_soc','testrep','pdf', [], [], ...
      'sampleVar',10,0) ;
  warnString = lastwarn ; 
  if (strcmp(warnString,'generate_report_soc:  error occurred generating report') || ...
      strcmp(warnString,...
      'generate_report_soc:  report generation disabled due to previous errors'))
      error('Report generation failed during use of .rpt format') ;
  end
  reportFileName = generate_report_soc('test_report_soc','testrep','pdf', [], [], ...
      'sampleVar',10,1) ;
  reportFileName = generate_report_soc('test_report_soc','testrep','pdf', [], [], ...
      'sampleVar',10,2) ;
  
% cleanup:  if it was necessary to put variables in the calling workspace, clear them now

  if (usedDummyVars)
      evalin('base','clear') ;
  end
  
  cd(currentDir) ;
  
% and that's it!

%
%
%

