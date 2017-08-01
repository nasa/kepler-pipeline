function initialize_soc_variables( workspaceCellArray, clearString )
%
% initialize_soc_variables -- set the values of the standard SOC environment variables in
% the requested workspace
%
% initialize_soc_variables sets initializes the current set of SOC variables based on the
%    values of standard SOC environment variables. The initialized values are exported to
%    the caller's workspace.
%
% initialize_soc__variables( workspaceCellArray ) exports the SOC variables to the
%    workspace(s) which are specified in the cell array argument.  Valid values are
%    'caller' and 'base'.  The current set of SOC environment variables are as follows:
%
%    socDataRoot         == $SOC_DATA_ROOT
%    socDistRoot         == $SOC_DIST_ROOT
%    socTestDataRoot     == $SOC_TESTDATA_ROOT
%    socTestMetaDataRoot == $SOC_TESTMETADATA_ROOT
%    socSpiceFileRoot    == $SOC_SPICEFILE_ROOT
%
% Variable socCodeRoot (== $SOC_CODE_ROOT) is not initialized by this function, but can be
%    obtained via a call to get_socCodeRoot.  
% initialize_soc_variables( 'clear' ) or initialize_soc_variables( workspaceCellArray,
%    'clear' ) causes the SOC path variables to be cleared, rather than assigned, from the
%    desired workspace(s).
%
% See also get_socCodeRoot.
%
% Version date:  2010-October-15.
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
%    2010-October-15, PT:
%        bugfix:  handle general case of a string rather than a cell array for arg 1.
%    2010-June-02, PT:
%        addition of function method to set socDistRoot from socCodeRoot.
%    2008-December-31, PT:
%        revise to use Bill and Forrest's approach to maintenance.  Back out function for
%        retrieving socSpiceFileRoot from kepler.properties (not ready for release yet)
%    2008-December-21, PT:
%        add socSpiceFileRoot.  Make improvements which simplify maintenance and addition
%        of new variables.
%    2008-December-19, PT:
%        add socTestMetaDataRoot.
%    2008-December-12, PT:
%        eliminate reference to SOC_CODE_ROOT.
%
%=========================================================================================

% clearVars defaults to false

  clearVars = false ;

% handle the case of zero arguments or empty workspace list

  if nargin == 0 || isempty(workspaceCellArray)
      workspaceCellArray{1} = 'caller' ;
  end
  
% handle the case of a string, rather than a cell array of strings, for arg 1

  if ischar(workspaceCellArray)
      workspaceString = workspaceCellArray ;
      clear workspaceCellArray ;
      workspaceCellArray{1} = workspaceString ;
  end
 
% handle the case of one argument, which is 'clear'

  if nargin == 1 && isscalar(workspaceCellArray) && strcmpi(workspaceCellArray{1},'clear')
      clear workspaceCellArray ;
      workspaceCellArray{1} = 'caller' ;
      clearVars = true ;
  end  
  
  if (nargin == 2) && (strcmpi(clearString,'clear'))
      clearVars = true ;
  end
  
% Define the variables we are going to set.  Each variable requires 4 entries in the
% following cell array to fully define it:
%
%    The name of the Matlab variable
%    The name of the environment variable, if any
%    The name of a function which can set the variable, if any
%    The default value of the variable, if any
%
% The assignment heirarchy is as shown above (ie, environment variable if available,
% otherwise setting function if available, otherwise default).

  socDistRootCmdString = 'socDistRoot_from_socCodeRoot ;' ;
  valueCellArray = { ...
      'socDataRoot', 'SOC_DATA_ROOT', char([]), '/path/to/rec' ; ...
      'socDistRoot', '', socDistRootCmdString, '/path/to/dist' ; ...
      'socTestDataRoot', 'SOC_TESTDATA_ROOT', char([]), '/path/to/test-data' ; ...
      'socTestMetaDataRoot', 'SOC_TESTMETADATA_ROOT', char([]), ...
                '/path/to/test-meta-data' ; ...
      'socSpiceFileRoot', 'SOC_SPICEFILE_ROOT', char([]), ...
                '/path/to/tmp/cache/spice' ...
                   } ;
  
% convert the valueCellArray to a struct

  variableStructFields = {'varName', 'environmentVariable', 'functionName', ...
                               'defaultValue' } ;
  variableStruct = cell2struct(valueCellArray,variableStructFields,2) ;

% define cell arrays to contain the necessary strings

                
% loop over variables

  for iVar = 1:length(variableStruct)
      
%     if the user wants to perform a clear operation, that is simple

      if (clearVars)
          varAssignString = ['clear ',variableStruct(iVar).varName] ;
      else
          
%         otherwise, we need to go up the heirarchy of obtaining the correct value for the
%         variable, starting with the default

          varValue = variableStruct(iVar).defaultValue ;
          varValueSpecialFunction = '' ;
          varValueEnvironmentVariable = '' ;
          
%         if there's a special function, use it and replace the varValue

          if ( ~isempty(variableStruct(iVar).functionName) )
              varValueSpecialFunction = eval( variableStruct(iVar).functionName ) ;
          end
          if (~isempty(varValueSpecialFunction))
              varValue = varValueSpecialFunction ;
          end
          
%         finally, if there's an environment variable, use it
          
          if (~isempty(variableStruct(iVar).environmentVariable) )
              varValueEnvironmentVariable = getenv( variableStruct(iVar).environmentVariable ) ;
          end
          if (~isempty(varValueEnvironmentVariable))
              varValue = varValueEnvironmentVariable ;
          end
          
          varAssignString = [variableStruct(iVar).varName,' = ''', varValue,''' ; '] ;
          
      end % clearVars condition
      
%     loop over workspaces and perform the assignment or clear operation

      for iWS = 1:length( workspaceCellArray )
          evalin( workspaceCellArray{iWS}, varAssignString ) ;
      end
      
  end % loop over variable names

return

% and that's it!

%
%
%

%=========================================================================================

% special function which obtains the spice file directory from the KEPLER_CONFIG_PATH
% environment variable.  This function isn't ready for release yet, and I don't want the
% build reading it in (it calls a function that I don't want in the build yet, so I don't
% want Matlab to automatically detect the dependency).  On the other hand I don't want to
% forget how it works, either!  So I am commenting out the whole thing until further
% notice.

% function spiceFileDir = get_spiceFileDir_from_kepler_config_path
% 
% % this function will only work correctly if the dynamic Java path has been set with its
% % SOC value.  Check that now.  If it is set, continue; otherwise, return an empty string.
% % Also, we do not want to execute at all if this is in a deployed app
% 
%   spiceFileDir = '' ;
%   socPathSet = false ;
%   socJavaPath = 'soc-classpath.jar' ;
%   lenPathString = length(socJavaPath) ;
%   javaDynamicPath = javaclasspath ;
%   if ( ~isempty(javaDynamicPath) && ~isdeployed )
%       for iPath = 1:length(javaDynamicPath)
%           if strcmp(javaDynamicPath{iPath}(end-lenPathString+1:end), ...
%                   socJavaPath) == true
%               socPathSet = true ;
%           end
%       end
%   end
%   
%   if (socPathSet)
% 
%       spiceFileDir = get_spiceFileDir_path_from_config_info ;
%       
%   end
%   
% return
% 
% % and that's it!
% 
% %
% %
% %
% 


%=========================================================================================

% subfunction which sets socDistRoot from SOC_CODE_ROOT if the latter is set

function socDistRoot = socDistRoot_from_socCodeRoot

% try to get socCodeRoot ; if we are deployed, it will error out, so use a try-catch block
% to defeat the error ; also, disable the functionality which causes get_socCodeRoot to
% try to use socDistRoot if SOC_CODE_ROOT is empty

  try
      socCodeRoot = get_socCodeRoot( false ) ;
  catch
      socCodeRoot = getenv('SOC_CODE_ROOT') ;
  end
  
  if ~isempty( socCodeRoot )
      socDistRoot = [socCodeRoot, filesep, 'dist'] ;
  else
      socDistRoot = '' ;
  end
  
return

% and that's it!

%
%
%

