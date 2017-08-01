function [reportFileName, varList] = generate_report_soc( reportMFileName, ...
    reportBaseName, format, module, output, varargin )
%
% generate_report_soc -- execute the Matlab Report generator with refinements for SOC
% usage.
%
% [reportFileName, varList] = generate_report_soc( reportMFileName, reportBaseName, format, 
%    module, output, date, var1NameString, var1, var2NameString, var2, ... warnState )
%    calls the Matlab report generator.  The arguments are defined as follows:
%    
%       reportMFileName:  string with the name of the m-file used to generate the report.
%        reportBaseName:  string containing the base report name (ie, 'prf', 'pmd', etc).
%                format:  string with the desired format for output, if left empty a
%                         default of PDF will be used.
%                module:  CCD module number (for reports with a unit of work other than
%                         mod/out this can be []).
%                output:  CCD output number (for reports with a unit of work other than
%                         mod/out this can be []).
%        var1NameString:  string containing desired name in the base workspace for var1.
%                  var1:  variable needed for report generation, to be copied to the base
%                         workspace.
%             warnState:  Desired handling of warnings (optional).
%
%    The variables var1, var2, ... are copied to the base workspace with names
%    var1NameString, var2Namestring, ... , so that they are available to the report
%    generator.  Prior to copying the requested variables into the base workspace, that
%    workspace is saved to a file; after execution of the report, the base workspace is
%    restored from that file, so that variable name conflicts do not occur if
%    var1NameString, etc, are names of variables which already exist in the base
%    workspace.  The list of variables in the base workspace at the time of report
%    generation, varList, is returned (mainly for testing and diagnostic purposes).  The
%    module, output, and date are used to prepare the correct filename for the report,
%    which is returned in reportFileName.
%
%    Argument warnState indicates the way in which warnings should be handled:  warnState
%    == 0 indicates that all warnings should be displayed during report production
%    (default); warnState == 1 indicates that warnings should be displayed without
%    backtrace; warnState == 2 indicates that warnings should be suppressed during report
%    production.
%
% Example:  to generate the report associated with buildsoc.m in PDF for module 14, output
%    2, and using Matlab variable myStruct in the production of the report, the command:
%
%        generate_report_soc('buildsoc', 'soc', 'pdf', 14, 2, 'myStruct', myStruct) ;
%
%    will result in a report named soc-14-2.pdf being generated.
%
% Example 2:  to generate the same report using the soc.rpt template instead of the
%    buildsoc.m m-file, use the command
%
%        generate_report_soc('soc', 'soc', 'pdf', 14, 2, 'myStruct', myStruct) ;
%
% Version date:  2008-October-30.
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
%     2008-October-30, PT:
%         add warnState and handling for same.
%     2008-October-27, PT:
%         eliminate datestring in report title per Bugzilla 892.
%     2008-October-23, PT:
%         switch to UTC for filename datestamp.
%     2008-October-22, PT:
%         don't clear the base workspace (allows generate_report_soc to be used from the
%         command line).
%     2008-October-19, PT:
%         detect the difference between the user passing the name of the m-file report
%         template and the rpt-file version, and handle it correctly in either case.
%     2008-October-16, PT:
%         add arguments to improve generation of report with desired filename and format.
%     2008-October-13, PT:
%         add phony report call (which never executes) to make compiler pick up dependency
%         on the report generator.
%
%=========================================================================================

% determine the value of warnState, or assign it if it is missing:  we determine its
% existence by looking to see if there are an odd or even # of arguments (even indicates
% that warnState is present)

  warnStateValid = [0 1 2] ;
  if (nargin/2 ~= floor(nargin/2)) % odd, so warnState missing
      warnState = 0 ;
      nVars = (nargin-5) / 2 ;
  else
      warnState = varargin{length(varargin)} ;
      nVars = (nargin-6) / 2 ;
  end
      
% generate a filename using the current date/time string, which can be used to save the
% base; also construct a save command string, a load command string, and a delete string

  filename = ['base_workspace_safety_',datestr(now,30)] ;
  saveCommandString = ['save ',filename] ;
  loadCommandString = ['load ',filename] ;
  deleteCommandString = ['delete ',filename,'.mat'] ;
    
% perform the safety save of the base workspace

  evalin( 'base' ,saveCommandString ) ;
  
% loop over the variables and copy them one at a time into the base workspace.  This will
% be done in a try-catch block so that if there's a problem (user didn't specify the
% arguments right, etc), execution won't stop; that way we always get to the reload step
% no matter how bad the arguments to this function are messed up.

  doReport = true ;

  if (~ismember(warnState,warnStateValid))
      warning('rpt:generateReportSoc:badArguments', ...
          'generate_report_soc:  argument list is not correct') ;
      doReport = false ;
  end
  
  for iVar = 1:nVars
      varNameIndex = 1+(iVar-1)*2 ;
      varValueIndex = 2+(iVar-1)*2 ;
      try
          assignin('base',varargin{varNameIndex},varargin{varValueIndex}) ;
      catch
          warning('rpt:generateReportSoc:unableToAssignVariable', ...
              'generate_report_soc:  error occurred assigning variable %s to base', ...
              varargin{varNameIndex}) ;
          doReport = false ;
      end
  end
  
  varList = evalin('base','who') ;
  
% generate the desired filename for the report:

% if the report name starts with 'build', then it's the M-file version and no quotes are
% needed; if it does not then it's the rpt-file version and quotes are needed.  Handle
% that now.

  if (~strncmp(reportMFileName,'build',5))
      reportMFileName = ['''',reportMFileName,''''] ;
  end

  try   
      reportGenerationString = ['report(',reportMFileName,', ''-f',format,''', ''-o'] ;
      reportFileName = reportBaseName ;
      if (~isempty(module))
          reportFileName = [reportFileName,'-',num2str(module,'%02d'),'-', ...
                                               num2str(output,'%d')] ;
      end
      reportFileName = [reportFileName,'.',format] ;
      reportGenerationString = [reportGenerationString,reportFileName,''') ;'] ;
  catch
      warning('rpt:generateReportSoc:unableToConstructReportFileName', ...
          'generate_report_soc:  error occurred constructing report file name') ;
      doReport = false ;
  end
  
% if the doReport didn't get set to false, attempt to generate a report now.  Do this in a
% try-catch block as well so that failure doesn't end execution (not everyone has a report
% generator!).

  if (doReport)
      if (warnState == 1) % no-backtrace warnings
          warnStruct = warning('query','backtrace') ;
          warning('off','backtrace') ;
      elseif (warnState == 2) % no warnings at all
          warnStruct = warning('query','all') ;
          warning('off','all') ;
      end
      try
          eval(reportGenerationString) ;
      catch
          if (warnState ~= 0) % restore original warning situation
              warning(warnStruct) ;
          end
          warning('rpt:generateReportSoc:unableToGenerateReport', ...
              'generate_report_soc:  error occurred generating report') ;
          doReport = false ;
      end
      if (warnState ~= 0) % restore original warning situation
          warning(warnStruct) ;
      end
  else
      warning('rpt:generateReportSoc:reportGenerationDisabled', ...
          'generate_report_soc:  report generation disabled due to previous errors') ;
  end
  
% if report generation failed, set the filename to a blank string.

  if (~doReport)
      reportFileName = char([]) ;
  end
  
% cleanup:  clear the base workspace and reload it from the safety file, then delete the
% safety file

  evalin('base','clear') ;
  evalin('base',loadCommandString) ;
  eval(deleteCommandString) ;
  
% Since report is being executed in an EVAL statement, the compiler will not detect its
% absence.  To trick the compiler, we add the following fake statement which will cause it
% to detect the dependency:

  never = 0 ;
  if (never)
      try
          report(phonyReport) ;
      catch
      end
  end
  
% and that's it!

%
%
%

  