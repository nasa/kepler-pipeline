function rerun_tps_injection_on_nas( topDir, subTaskNumber, saveOutputs )
%
% rerun_tps_injection_on_nas: re-run tasks that failed.  Most useful if we
% are just generating diagnostics and had fails.
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

%========================================================================================

% attempt to display the build date string

  try
      dateString = get_build_date_string ;
      disp(['MATLAB:  Build date == ',dateString]) ;
  catch
      disp('MATLAB:  Build date unavailable')
  end

% apparently, args are passed by the MATLAB runtime shell file as strings; check for that
% and correct it now

  if isa(subTaskNumber,'char')
      subTaskNumber = str2double(subTaskNumber) ;
  end
  if ~exist( 'saveOutputs', 'var' ) || isempty(saveOutputs)
      saveOutputs = true ;
  end
  if isa(saveOutputs,'char')
      saveOutputs = str2double(saveOutputs) ;
      saveOutputs = logical(saveOutputs) ;
  end

% prepare path variables needed herein
  initialize_soc_variables({'caller','base'});
  disp([ 'socDistRoot: ' socDistRoot ]);
  disp([ 'socDataRoot: ' socDataRoot ]);
  disp([ 'socTestDataRoot: ' socTestDataRoot ]);

% if we are not running in the MATLAB interactive environment, we need to set the java path

  if(isdeployed && ~ismcc)
    warning off backtrace;
    initialize_soc_javapath(socDistRoot);
    warning backtrace;
  end;

% get the nodename and write to the output

  [~,nodename] = system('uname -n') ;
  disp(['Running TPS on node ',nodename]) ;
  disp([]) ;
  
% get the absolute path of the topDir  

  cd(topDir) ;
  topDirAbsPath = cd ;

% loop over tasks and run them

  taskSubDirName = ['st-',num2str(subTaskNumber)] ;
  cd( fullfile( topDirAbsPath, taskSubDirName ) ) ;
  load tps-inputs-0 ;

  outputsStruct = transit_injection_controller( inputsStruct ) ;

  if saveOutputs
      save tps-outputs-0 outputsStruct ;
  end
  clear inputsStruct outputsStruct ;
  pause(1) ;

return