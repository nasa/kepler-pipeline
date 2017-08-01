function fpgOutputs = fpg_matlab_controller( fpgDataStruct )
%
% fpg_matlab_controller -- main control function of Focal Plane Geometry
%
% fpgOutputs = fpg_matlab_controller( fpgDataStruct ) accepts a data structure which is
%    used to instantiate an fpgDataClass object, and manages execution of the Focal Plane
%    Geometry fit.  The returned structure, fpgOutputs, has fields which indicate the file
%    name used to store the fitted geometry model (in the form of a blob), and the
%    pointing solutions for all cadences which were fitted.  
%
% See also:  get_fpgOutputs.
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
%         make use of reportGenertationEnabled member of fpgDataClass object.
%     2008-December-19, PT:
%         disable report generator until further notice due to crash bug which only
%         presents itself in the pipeline.
%     2008-December-17, PT:
%         more display statements, plus a bugfix -- remove a statement put in for
%         debugging purposes a few days ago which was causing a crash in the pipeline.
%     2008-December-15, PT:
%         add display statements which show how long various processes required.
%     2008-October-27, PT:
%         eliminate use of time argument from generate_report_soc call.
%     2008-October-19, PT:
%         change report generator call to use fpg.rpt instead of buildfpg.m.
%     2008-October-16, PT:
%         modified call to generate_report_soc.
%     2008-October-13, PT:
%         move geometry model flat file generation to get_fpgOutputs method of
%         fpgResultsClass object.
%     2008-October-08, PT:
%         bugfix -- only save plots if they exist.
%     2008-October-06, PT:
%         improved method of invoking report.
%     2008-September-30, PT:
%         copy variables for report generation to the base workspace.
%     2008-September-07, PT:
%         write out the report file name, if a report is produced, as one of the outputs.
%     2008-August-04, PT:
%         preserve a vector of the MJDs in original order and pass to get_fpgOutputs, so
%         that attitude solution is in the same order as the original cadences.
%     2008-August-01, PT:
%         get outputs for pipeline operation and return to caller, per discussions with
%         PRF team.
%
%=========================================================================================

  generateReport = false ;

% instantiate the fpgDataClass object from the fpgDataStruct structure; in the process,
% perform data validation on the structure

  disp('FPG:  instantiating fpgDataClass object')
  t0 = clock ;
  t00 = t0 ;
  fpgDataObject = fpgDataClass( fpgDataStruct ) ;
  t1 = clock ;
  disp(['      fpgDataClass object instatiation completed in ',num2str(etime(t1,t0)), ...
      ' seconds']) ;
  originalMjdVector = get(fpgDataObject,'mjdLongCadence') ;

% decide whether or not to generate a report  
  
  generateReport = get(fpgDataObject,'reportGenerationEnabled') ;  
  
% perform the data reorganization, and in the process create the vector of fpgFitClass
% objects which are members of the fpgDataClass object

  disp('FPG:  reorganizing data in fpgDataClass object')
  t0 = clock ;
  fpgDataObject = fpg_data_reformat( fpgDataObject ) ;
  t1 = clock ;
  disp(['      fpgDataClass data reorganzation completed in ',num2str(etime(t1,t0)), ...
      ' seconds']) ;
  
% perform the fit -- the output of the fit is an fpgResultsClass object

  disp('FPG:  performing fit')
  t0 = clock ;
  fpgResultsObject = update_fpg( fpgDataObject ) ;
  
% compute the change in alignment of each CCD in (row,column) basis

  fpgResultsObject = convert_fit_pars_to_row_column( fpgResultsObject ) ;
  t1 = clock ;
  disp(['      FPG fit completed in ',num2str(etime(t1,t0)), ...
      ' seconds']) ;
  
% generate all of the plots which are available to the fpgResultsObject and save them
% locally

  disp('FPG:  preparing displays, report, and outputs')
  t0 = clock ;
 fpgResultsPlotHandles = prepare_fpg_displays( fpgResultsObject ) ;
 plotNames = fieldnames(fpgResultsPlotHandles) ;
  for iPlot = 1:length(plotNames)
      thisHandle = getfield(fpgResultsPlotHandles,plotNames{iPlot}) ;
      if (~isempty(thisHandle))
          saveas(thisHandle,[plotNames{iPlot},'.fig']) ;
      end
  end
  
% convert the fpgResultsObject into a structure using the object's get method, and save it
% locally; while we're at it, copy out the fpgDataStruct

  fpgResultsStruct = get(fpgResultsObject,'*') ;
  save fpgResultsStruct fpgResultsStruct ;
  save fpgDataStruct fpgDataStruct ;

% generate the report, if required 
  
  if (generateReport == true)
      [reportFileName, varList] = generate_report_soc( 'fpg', 'fpg', 'pdf', ...
          [] , [] , ...
          'fpgDataObject', fpgDataObject, ...
          'fpgResultsObject', fpgResultsObject, ...
          'fpgDataStruct', fpgDataStruct, ...
          'fpgResultsPlotHandles', fpgResultsPlotHandles ) ;  
  else
      reportFileName = '' ;
  end
  
% return to the caller the outputs which are appropriate for FPG when running in a
% pipeline / PRF context

  fpgOutputs = get_fpgOutputs( fpgResultsObject, originalMjdVector, reportFileName ) ;
  t1 = clock ;
  disp(['      FPG displays, reports, outputs completed in ',num2str(etime(t1,t0)), ...
      ' seconds']) ;

  close all ;
  tf = clock ;
  disp(['FPG:  exiting fpg_matlab_controller, elapsed time ',num2str(etime(tf,t00)), ...
      ' seconds']) ;

% and that's it!

%
%
%


  