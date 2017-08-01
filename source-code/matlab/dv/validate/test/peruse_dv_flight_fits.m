function peruse_dv_flight_fits( flightFitsHomeDir, taskMappingFilename, startId, ...
    whitenedFoldedFlag )
%
% peruse_dv_flight_fits -- study sets of DV fits from flight data
%
% peruse_dv_flight_fits( flightFitsHomeDir, taskMappingFilename ) loops over the task 
%    files in a directory and displays their results using peruse_dv_fits_no_ground_truth.
%    Its loop automatically displays the first task from each skygroup first, then goes to
%    the second task from each skygroup, and so on until all tasks have been examined.
%    The name of the task mapping file is also required as an input.
%
% peruse_dv_flight_fits( ... , startId ) performs the display starting with the task
%    specified by number in startId.
%
% peruse_dv_flight_fits( ... , whitenedFoldedFlag ) allows the user to select whitened
%     folded averaged plots instead of unwhitened folded unaveraged plots.
%
%
% Version date:  2010-January-13.
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
%    2010-January-13, PT:
%        support option to allow the whitened folded averaged plot to be displayed.
%
%=========================================================================================

% parse the task mapping information and the directory tree into a struct

  taskMapStruct = parse_task_map( flightFitsHomeDir, taskMappingFilename ) ;
  maxTasksInASkyGroup = max([taskMapStruct.tasks]) ;
  
  disp('Task files per sky group:  ') ;
  disp([taskMapStruct.tasks]) ;
  disp(' ') ;
  
% If no startId is set, set it to be the first task of the first skygroup

  if ~exist( 'startId', 'var' ) || isempty( startId )
      startId = taskMapStruct(1).taskId(1) ;
  end
  
  if ~exist( 'whitenedFoldedFlag', 'var' ) || isempty( whitenedFoldedFlag )
      whitenedFoldedFlag = false ;
  end
  
% set display to false until the desired task id is found

  displayFits = false ;
  
  for iTask = 1:maxTasksInASkyGroup
      
      for iSkyGroup = 1:length(taskMapStruct)
          
          if taskMapStruct(iSkyGroup).tasks >= iTask && ...
                  taskMapStruct(iSkyGroup).taskId(iTask) == startId
              displayFits = true ;
          end
          
          if taskMapStruct(iSkyGroup).tasks >= iTask && displayFits
              
              disp( ['Sky Group:  ', num2str(iSkyGroup), ...
                  ', Task:  ', num2str(taskMapStruct(iSkyGroup).taskId(iTask))] ) ;
              if exist( taskMapStruct(iSkyGroup).taskDir{iTask}, 'dir' ) && ...
                 exist( fullfile( taskMapStruct(iSkyGroup).taskDir{iTask}, ...
                      'dv-outputs-0.mat' ), 'file' )
                  load( fullfile( taskMapStruct(iSkyGroup).taskDir{iTask}, ...
                      'dv-outputs-0.mat' ) ) ;
                  peruse_dv_fits_no_ground_truth( outputsStruct, ...
                      taskMapStruct(iSkyGroup).taskDir{iTask}, whitenedFoldedFlag ) ;
              end
              
          end
          
      end
      
  end
  
return

%=========================================================================================

% subfunction which parses the task mapping file

function taskMapStruct = parse_task_map( flightFitsHomeDir, taskMappingFilename )

% construct a blank taskMapStruct

  taskMapStruct = struct('skyGroup',[], 'tasks', 0, 'taskId', [], 'taskDir', []) ;
  taskMapStruct = repmat(taskMapStruct,84,1) ;
  for iSkyGroup = 1:84
      taskMapStruct(iSkyGroup).skyGroup = iSkyGroup ;
  end

% open the file for reading

  fileId = fopen( fullfile( flightFitsHomeDir, taskMappingFilename ), 'rt' ) ;
  
% scan down for the instance ID #

  foundInstanceIdHeader = false ;
  while ~foundInstanceIdHeader
      lineText = fgets(fileId) ;
      foundInstanceIdHeader = ~isempty( strfind( lineText, 'ID' ) ) ;
  end
  lineSkip = fgets(fileId) ;
  lineWithInstanceId = fgets(fileId) ;
  instanceIdString = strtok(lineWithInstanceId) ;
  
% scan down to find the DV tasks and get the information about the completed ones

  foundInstanceIdHeader = false ;
  while ~foundInstanceIdHeader
      lineText = fgets(fileId) ;
      foundInstanceIdHeader = ~isempty( strfind( lineText, 'ID' ) ) ;
  end
  lineSkip = fgets(fileId) ;
  atEndOfFile = false ;
  
  while ~atEndOfFile
      
      lineText = fgets(fileId) ;
      if isequal(lineText,-1)
          atEndOfFile = true ;
          continue ;
      end
      
      [taskIdText, remainder] = strtok( lineText ) ;
      [moduleText, remainder] = strtok( remainder ) ;
%      [number, remainder]     = strtok( remainder ) ;
      [uowText, remainder]    = strtok( remainder ) ;
      [statText, remainder]   = strtok( remainder ) ;
      
      if strcmp( moduleText, 'dv' ) && strcmp( statText, 'COMPLETED' )
          
%         the task ID is the # between the first = sign and the following ]

          equalsIndex = strfind( uowText, '=' ) ; equalsIndex = equalsIndex(1) ; 
          bracketIndex = strfind( uowText, ']' ) ; bracketIndex = bracketIndex(1) ;
          skyGroupText = uowText( equalsIndex+1:bracketIndex-1 ) ;
          skyGroup = str2num( skyGroupText ) ;
          
%         add the information to the relevant sky group

          taskMapStruct(skyGroup).tasks = taskMapStruct(skyGroup).tasks + 1 ;
          taskNumber = taskMapStruct(skyGroup).tasks ;
          taskMapStruct(skyGroup).taskId(taskNumber) = str2num( taskIdText ) ;
          taskMapStruct(skyGroup).taskDir{taskNumber} = ...
              [flightFitsHomeDir, filesep, 'dv-matlab-',instanceIdString, '-', ...
              taskIdText] ;
          
      end
      
  end
  
  fclose( fileId ) ;
  
return
          