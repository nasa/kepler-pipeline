function reportFilename = fpg_generate_report( fpgDataStruct, fpgResultsStruct, ...
    spiceFileDir )
%
% fpg_generate_report -- generate the FPG report from workspace data structures
%
% reportFilename = fpg_generate_report( fpgDataStruct, fpgResultsStruct, spiceFileDir ) 
%    uses workspace copies of the fpgDataStruct and fpgResultsStruct to generate the FPG
%    report.  This allows standalone report generation without going through all the
%    rigamarole of running fpg_matlab_controller.  The FPG report filename is returned to
%    the caller.  A directory for spice files is necessary because raDec2PixClass methdods 
%    are called in generation of figures.
%
% Note:  when using a structure which is in pipeline format (ie, with motion polynomials
%    in the form of blobs written to local storage), the motion polynomial blobs must be
%    present in local storage as expected.
%
% Version date:  2008-December-18.
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

% construct the fpgDataClass and fpgResultsClass objects from the inputs

  t00 = clock ;
  disp('fpg_generate_report:  instantiating fpgDataClass object') ;
  t0 = clock ;
  fpgDataObject = fpgDataClass(fpgDataStruct) ;
  t1 = clock ;
  disp(['                      done with fpgDataClass instantiation after ', ...
      num2str(etime(t1,t0)),' seconds']) ;
  
  disp('fpg_generate_report:  instantiating fpgResultsClass object') ;
  t0 = clock ;
  raDec2PixModel = struct(fpgResultsStruct.fpgFitClass.raDec2PixObject) ;
  raDec2PixModel.spiceFileDir = spiceFileDir ;
  fpgResultsStruct.fpgFitClass.raDec2PixObject = raDec2PixModel ;
  fpgResultsObject = fpgResultsClass(fpgResultsStruct) ;  
  t1 = clock ;
  disp(['                      done with fpgResultsClass instantiation after ', ...
      num2str(etime(t1,t0)),' seconds']) ;

% plot the figures and save to local storage

  disp('fpg_generate_report:  generating figures') ;
  t0 = clock ;
  fpgResultsPlotHandles = prepare_fpg_displays( fpgResultsObject ) ;
  plotNames = fieldnames(fpgResultsPlotHandles) ;
  for iPlot = 1:length(plotNames)
      thisHandle = getfield(fpgResultsPlotHandles,plotNames{iPlot}) ;
      if (~isempty(thisHandle))
          saveas(thisHandle,[plotNames{iPlot},'.fig']) ;
      end
  end
  t1 = clock ;
  disp(['                      done with plot generation after ', ...
      num2str(etime(t1,t0)),' seconds']) ;

% deep breath now ... and ... call the report generator!

  disp('fpg_generate_report:  generating report') ;
  t0 = clock ;
  [reportFilename, varList] = generate_report_soc( 'fpg', 'fpg', 'pdf', ...
      [] , [] , ...
      'fpgDataObject', fpgDataObject, ...
      'fpgResultsObject', fpgResultsObject, ...
      'fpgDataStruct', fpgDataStruct, ...
      'fpgResultsPlotHandles', fpgResultsPlotHandles ) ;  
  t1 = clock ;
  disp(['                      done with report generation after ', ...
      num2str(etime(t1,t0)),' seconds']) ;

% cleanup:  close displays

  close all ;
  
% all done

  t01 = clock ;
  disp(['fpg_generate_report:  all complete, elapsed time = ', ...
      num2str(etime(t01,t00)),' seconds']) ;
  
return 

% and that's it!

%
%
%