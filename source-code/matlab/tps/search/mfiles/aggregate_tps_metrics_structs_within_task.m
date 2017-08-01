function aggregate_tps_metrics_structs_within_task( fullPathToTaskFiles, nSubdirsMax, ...
    saveToWorkingDir )
%
% aggregate_tps_metrics_structs_within_task -- function which performs top-level
% aggregation of the TPS METRICS structs within a single task
%
% aggregate_tps_metrics_structs_within_task( fullPathToTaskFiles ) aggregates the TPS METRICS
%    structs which are within the requested task directory.  Argument fullPathToTaskFiles
%    is the full path, which ends in tps-matlab-#-#.  The function loads all of the METRICS
%    files (which are in the st-# subdirs of the task directory), builds an aggregate
%    struct, which is then saved to tps-metrics-struct-#-# in the task directory.
%
% aggregate_tps_metrics_structs_within_task( fullPathToTaskFiles, nSubdirsMax ) allows the 
%    user to specify a maximum number of sub-directories which are to be processed.  This
%    is mainly used for testing purposes and is not an intended mode of pipeline
%    operation.
%
% aggregate_tps_metrics_structs_within_task( fullPathToTaskFiles, nSubdirsMax,
%    saveToWorkingDir ) saves the tpsMetricsStruct to the working directory instead of the
%    task directory (default is false).  This is another testing-only option.
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

%=========================================================================================

% handle optional arguments

  fill_aggregator_optional_arguments ;

% a few constants

  pattern = 'tps-matlab' ; % text which precedes instance and task numbers in dir name
  metricsFileName = 'tps-task-file-metrics-struct.mat' ; % name of atomic metrics files
  nTargetsPerSubtask = 1 ; % each st-# directory contains results from running 
                           % this number of targets
  saveFilenameBase = 'tps-metrics-struct' ; % root of the savename for the struct
  saveErrorNameBase = 'tps-metrics-errors' ; % save file for aggregation error info
  clearPeriod = 60 ; % how often to clear local variables to avoid filling up memory
  
% find the instance and task number portions of the string, we'll need them later

  dirSuffixLocation = strfind( fullPathToTaskFiles, pattern ) ;
  dirSuffix         = fullPathToTaskFiles(dirSuffixLocation(end)+length(pattern):end) ;
  
% setup save to the task file directory unless the user requests otherwise

  if ~saveToWorkingDir
      saveFilenameBase = fullfile(fullPathToTaskFiles,saveFilenameBase) ;
      saveErrorNameBase = fullfile(fullPathToTaskFiles,saveErrorNameBase) ;
  end
  
% get the list of subdirs, removing the '.' and '..' entries from the list

  subdirList = get_list_of_subdirs( fullPathToTaskFiles ) ;
  nDirs = min( length(subdirList),nSubdirsMax ) ;
  
  tpsMetricsStruct = [] ;
  
  targetFailureStruct = struct('directory',[], 'message',[], 'identifier', [], ...
      'stack',[] ) ;
  nFailedTasks = 0 ;
  
% loop over subdirs

  targetStart = 1 ;
  firstFileParsed = false ;
  for iDir = 1:nDirs
      
      disp( [' ... assembling TPS METRICS information from ',subdirList(iDir).name, ...
          ' directory ...' ] ) ;
      
      try
          % Check for the presence of metricsFile; if it exists, load it
          % and process it
          metricsFileFull = fullfile( fullPathToTaskFiles, subdirList(iDir).name, metricsFileName );
          
          if(exist(metricsFileFull,'file')==2)
              dummy = load(  fullfile( fullPathToTaskFiles, subdirList(iDir).name, metricsFileName ) ) ;
              atomicTpsMetricsStruct = dummy.tpsMetricsStruct ;
              clear dummy
              
              %         get certain dimensional parameters from the sizes of struct member arrays
              
              nTargets      = length( atomicTpsMetricsStruct.keplerId ) ;
              targetEnd   = targetStart + nTargets - 1 ;
              
              %         if this is the first task file, we can determine the # of quarters and # of
              %         pulse lengths, and then pre-allocate the task-level struct
              
              if ~firstFileParsed
                  
                  nPulseLengths = atomicTpsMetricsStruct.nPulseLengths ;
                  atomicTpsMetricsStruct = rmfield( atomicTpsMetricsStruct, ...
                      {'nPulseLengths'} ) ;
                  if isfield( atomicTpsMetricsStruct, 'quartersPresent' )
                      nQuarters     = size( atomicTpsMetricsStruct.quartersPresent, 1 ) ;
                  else
                      nQuarters = 0 ;
                  end
                  % Count the number of subtask directories for which
                  % metricsFiles are present, and pre-allocate the
                  % tpsMetricsStruct accordingly
                  [~, nDirsWithMetricsFile] = unix('ls st-*/tps-task-file-metrics-struct.mat | wc -l');
                  tpsMetricsStruct = preallocate_tps_metrics_struct( nDirsWithMetricsFile, nPulseLengths, ...
                      nQuarters, nTargetsPerSubtask, atomicTpsMetricsStruct ) ;
                  % tpsMetricsStruct.keplerId = int32( tpsMetricsStruct.keplerId ) ;
                  metricsStructFieldNames = fieldnames( atomicTpsMetricsStruct ) ;
                  firstFileParsed = true ;
                  
              end
              
              %         loop over fields -- note that nPulseLengths will not be
              %         included, as it was removed from the list
              
              for iField = 1:length(metricsStructFieldNames)
                  
                  thisFieldName = metricsStructFieldNames{iField} ;
                  thisField = atomicTpsMetricsStruct.(thisFieldName) ;
                  
                  shapeIndicator = field_size_to_shape_indicator( thisField, nTargets, ...
                      nPulseLengths, nQuarters ) ;
                  
                  switch shapeIndicator
                      
                      case{ 1 }
                          
                          tpsMetricsStruct.(thisFieldName)(targetStart:targetEnd) = ...
                              thisField ;
                          
                      case{ 2 }
                          
                          tpsMetricsStruct.(thisFieldName)(targetStart:targetEnd,1:nPulseLengths) = ...
                              reshape( thisField, nTargets, nPulseLengths ) ;
                          
                      case{ 3 }
                          
                          tpsMetricsStruct.(thisFieldName)(targetStart:targetEnd,1:nQuarters) = ...
                              thisField' ;
                          
                      otherwise
                          
                          error( 'tps:assembleTpsMetricsStruct:fieldShapeNotRecognized', ...
                              ['assemble_tps_metrics_struct: shape of field ', thisFieldName, ...
                              ' not recognized on target ', num2str(iDir)] ) ;
                          
                  end % switch statement
                  
              end % loop over fields
              
              %         append the taskfile information, which does not come out of the atomic METRICS
              %         struct
              
              tpsMetricsStruct.taskfile(targetStart:targetEnd) = repmat( ...
                  { fullfile( dirSuffix, subdirList(iDir).name ) }, nTargets, 1 ) ;
              
              targetStart = targetEnd + 1 ;
              
              %         if we are due to perform a clear operation, do that now, and pause for 1 second
              %         so that MATLAB has time to do it
              
              clear tpsTaskMetricsStruct nTargets thisFieldName thisField fieldSize targetEnd ;
              if mod( iDir, clearPeriod ) == 0
                  pause( 1 ) ;
              end
              
          end % if metricsFile exists
          
      catch
          
          thisTaskFailure = lasterror ;
          disp(['     ... error occurred processing directory ', subdirList(iDir).name, ...
              ', error: ', thisTaskFailure.identifier,', skipping to next directory ... '] ) ;
          nFailedTasks = nFailedTasks + 1 ;
          targetFailureStruct(nFailedTasks).directory = fullfile( fullPathToTaskFiles, ...
              subdirList(iDir).name ) ;
          targetFailureStruct(nFailedTasks).message = thisTaskFailure.message ;
          targetFailureStruct(nFailedTasks).identifier = thisTaskFailure.identifier ;
          targetFailureStruct(nFailedTasks).stack = thisTaskFailure.stack ;
          clear thisTaskFailure ;
          
      end
      
      %     if we are due to perform a clear operation, do that now, and pause for 1 second
      %     so that MATLAB has time to do it
      
      clear tpsTaskMetricsStruct nTargets thisFieldName thisField fieldSize targetEnd ;
      if mod( iDir, clearPeriod ) == 0
          pause( 1 ) ;
      end
      
  end % loop over subdirs
  
  % if some directories failed due to errors, identify the number of missing targets and
  % remove them from the metrics struct
  
  missingKeplerIdPointer = find( tpsMetricsStruct.keplerId == 0 ) ;
  if ~isempty( missingKeplerIdPointer )
      for iField = 1:length( metricsStructFieldNames )
          thisFieldName = metricsStructFieldNames{iField} ;
          tpsMetricsStruct.(thisFieldName)(missingKeplerIdPointer,:) = [] ;
      end
      tpsMetricsStruct.taskfile(missingKeplerIdPointer) = [] ;
  end
  
  % If there were no subdirs present, then none of the code in the loop will execute, and
  % all we need to do here is prevent the final bits of the routine from trying to run in
  % that case
  
  if nDirs > 0
      
      %     append the pulse durations and unit of work
      
      % tpsMetricsStruct.nPulseLengths = nPulseLengths ;
      
      %     perform the save
      
      fullFilename = [saveFilenameBase,dirSuffix] ;
      disp([ ' ... saving aggregated struct to ', fullFilename,' ... ']) ;
      save( fullFilename, 'tpsMetricsStruct', '-v7' ) ;
      fullErrorName = [saveErrorNameBase,dirSuffix] ;
      disp([' ... saving target error struct to ', fullErrorName, ' ... ']) ;
      targetFailureStruct = targetFailureStruct(:) ;
      save( fullErrorName, 'targetFailureStruct', '-v7' ) ;
      
  else
      
      disp( ' ... nothing to aggregate, so exiting aggregator ... ' ) ;
      
  end
      
return

%=========================================================================================

% subfunction which performs preallocation

function tpsMetricsStruct = preallocate_tps_metrics_struct( nDirsWithMetricsFile, nPulseLengths, ...
              nQuarters, nTargetsPerSubtask, atomicTpsMetricsStruct )
          
  metricsStructFieldNames = fieldnames( atomicTpsMetricsStruct ) ;
  nTargets             = length( atomicTpsMetricsStruct.keplerId ) ;

  nTargetsTotal = nDirsWithMetricsFile * nTargetsPerSubtask ;
  
  for iField = 1:length(metricsStructFieldNames) ;
      
      thisFieldName = metricsStructFieldNames{iField} ;
      tpsMetricsStruct.(thisFieldName) = [] ;

      
          shapeIndicator = field_size_to_shape_indicator( atomicTpsMetricsStruct.(thisFieldName), ...
              nTargets, nPulseLengths, nQuarters ) ;
          
          switch shapeIndicator
              
              case{ 1 }
                  
                  if(~strcmp(thisFieldName,'keplerId'))
                      tpsMetricsStruct.(thisFieldName) = zeros(nTargetsTotal,1, 'single') ;
                  elseif(strcmp(thisFieldName,'keplerId'))
                      tpsMetricsStruct.(thisFieldName) = zeros(nTargetsTotal,1, 'int32') ;
                  end
                  
              case{ 2 }
                  
                  if iscell( atomicTpsMetricsStruct.(thisFieldName) )
                      tpsMetricsStruct.(thisFieldName) = cell(nTargetsTotal,nPulseLengths) ;
                  else
                      if(~strcmp(thisFieldName,'keplerId'))
                          tpsMetricsStruct.(thisFieldName) = zeros(nTargetsTotal,...
                              nPulseLengths, 'single') ;
                      elseif(strcmp(thisFieldName,'keplerId'))
                          tpsMetricsStruct.(thisFieldName) = zeros(nTargetsTotal,...
                              nPulseLengths, 'int32') ;
                      end
                  end
                  
              case{ 3 }
                                  
                  if(~strcmp(thisFieldName,'keplerId'))
                      tpsMetricsStruct.(thisFieldName) = zeros(nTargetsTotal,...
                          nQuarters, 'single') ;
                  elseif(strcmp(thisFieldName,'keplerId'))
                      tpsMetricsStruct.(thisFieldName) = zeros(nTargetsTotal,...
                          nQuarters, 'int32') ;
                  end
                  
         end % switch
          
      
  end % loop over fields
  
% put the task file and sesCombinedToYieldMes, indexOfSesAdded cell arrays 
% at the end  
  
  tpsMetricsStruct.taskfile = cell(nDirsWithMetricsFile,1) ;   

return

%=========================================================================================

% convert the size of the field to a field shape indicator
      
function shapeIndicator = field_size_to_shape_indicator( thisField, nTargets, ...
    nPulseLengths, nQuarters )

% manage degenerate cases -- cases in which either nPulseLengths or nQuarters are equal to
% one, so it can't tell some of the cases apart.  The good news is, if this is the
% situation then a single shape will do the job for everything!

  if nPulseLengths == 1
      nPulseLengths = 0 ;
  end
  if nQuarters == 1
      nQuarters = 0 ;
  end

  thisFieldSize            = size( thisField ) ;
  targetsVector            = isequal( thisFieldSize, [1 nTargets] ) ;
  targetPulseLengthsMatrix = isequal( thisFieldSize, ...
      [1 nPulseLengths * nTargets] ) ;
  targetQuartersMatrix     = isequal( thisFieldSize, [nQuarters nTargets] ) ;
          
%  convert to a scalar integer value from 1 to 4

  shapeIndicator = targetsVector +  ...
      2 * targetPulseLengthsMatrix + 3 * targetQuartersMatrix ;
  
return


