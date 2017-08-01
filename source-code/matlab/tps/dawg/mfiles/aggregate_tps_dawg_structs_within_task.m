function aggregate_tps_dawg_structs_within_task( fullPathToTaskFiles, nSubdirsMax, ...
    saveToWorkingDir )
%
% aggregate_tps_dawg_structs_within_task -- function which performs top-level
% aggregation of the TPS DAWG structs within a single task
%
% aggregate_tps_dawg_structs_within_task( fullPathToTaskFiles ) aggregates the TPS DAWG
%    structs which are within the requested task directory.  Argument fullPathToTaskFiles
%    is the full path, which ends in tps-matlab-#-#.  The function loads all of the DAWG
%    files (which are in the st-# subdirs of the task directory), builds an aggregate
%    struct, which is then saved to tps-dawg-struct-#-# in the task directory.
%
% aggregate_tps_dawg_structs_within_task( fullPathToTaskFiles, nSubdirsMax ) allows the 
%    user to specify a maximum number of sub-directories which are to be processed.  This
%    is mainly used for testing purposes and is not an intended mode of pipeline
%    operation.
%
% aggregate_tps_dawg_structs_within_task( fullPathToTaskFiles, nSubdirsMax,
%    saveToWorkingDir ) saves the tpsDawgStruct to the working directory instead of the
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
  dawgFileName = 'tps-task-file-dawg-struct.mat' ; % name of atomic dawg files
  nTargetsPerSubtask = 1 ; % each st-# directory contains results from running 
                           % this number of targets
  saveFilenameBase = 'tps-dawg-struct' ; % root of the savename for the struct
  saveErrorNameBase = 'tps-dawg-errors' ; % save file for aggregation error info
  clearPeriod = 60 ; % how often to clear local variables to avoid filling up memory
  
% find the instance and task number portions of the string, we'll need them later

  dirSuffixLocation = strfind( fullPathToTaskFiles, pattern ) ;
  dirSuffix         = fullPathToTaskFiles(dirSuffixLocation(end)+length(pattern):end) ;
  
% setup save to the task file directory unless the user requests otherwise

  if ~saveToWorkingDir
      saveFilenameBase        = fullfile(fullPathToTaskFiles,saveFilenameBase) ;
      saveErrorNameBase       = fullfile(fullPathToTaskFiles,saveErrorNameBase) ;
      saveAddedPlanetBaseName = fullfile(fullPathToTaskFiles,'task-added-planet-struct') ;
  end
  
% get the list of subdirs, removing the '.' and '..' entries from the list

  subdirList = get_list_of_subdirs( fullPathToTaskFiles ) ;
  nDirs = min( length(subdirList),nSubdirsMax ) ;
  
  tpsDawgStruct = [] ;
  
  targetFailureStruct = struct('directory',[], 'message',[], 'identifier', [], ...
      'stack',[] ) ;
  nFailedTasks = 0 ;
  taskAddedPlanetStruct = [] ;
  
% loop over subdirs

  targetStart = 1 ;
  firstFileParsed = false ;
  for iDir = 1:nDirs
      
      disp( [' ... assembling TPS DAWG information from ',subdirList(iDir).name, ...
          ' directory ...' ] ) ;
      
      try
      
          if exist( fullfile( fullPathToTaskFiles, subdirList(iDir).name, ...
                  'sub-task-added-planet-struct.mat' ), 'file' )
              load( fullfile( fullPathToTaskFiles, subdirList(iDir).name, ...
                  'sub-task-added-planet-struct.mat' ) ) ;
              taskAddedPlanetStruct = [taskAddedPlanetStruct ; ...
                  addedPlanetStruct] ;
          end
          dummy = load(  fullfile( fullPathToTaskFiles, subdirList(iDir).name, dawgFileName ) ) ; 
          atomicTpsDawgStruct = dummy.tpsDawgStruct ;
          clear dummy

%         get certain dimensional parameters from the sizes of struct member arrays

          nTargets      = length( atomicTpsDawgStruct.keplerId ) ;
          targetEnd   = targetStart + nTargets - 1 ;

%         if this is the first task file, we can determine the # of quarters and # of
%         pulse lengths, and then pre-allocate the task-level struct

          if ~firstFileParsed

              pulseDurations = atomicTpsDawgStruct.pulseDurations ;
              unitOfWorkKjd  = atomicTpsDawgStruct.unitOfWorkKjd ;
              nPulseLengths = length( pulseDurations ) ;
              atomicTpsDawgStruct = rmfield( atomicTpsDawgStruct, ...
                  {'pulseDurations','unitOfWorkKjd'} ) ;
              if isfield( atomicTpsDawgStruct, 'quartersPresent' )
                  nQuarters     = size( atomicTpsDawgStruct.quartersPresent, 1 ) ;
              else
                  nQuarters = 0 ;
              end
              if isfield( atomicTpsDawgStruct, 'mesHistogram' )
                  nHistBins = size( atomicTpsDawgStruct.mesHistogram, 1 ) ;
              else
                  nHistBins = 0 ;
              end
              tpsDawgStruct = preallocate_tps_dawg_struct( nDirs, nPulseLengths, ...
                  nQuarters, nHistBins, nTargetsPerSubtask, atomicTpsDawgStruct ) ;
              dawgStructFieldNames = fieldnames( atomicTpsDawgStruct ) ;
              firstFileParsed = true ;

          end

%         loop over fields -- note that pulseDurations and unitOfWorkKjd will not be
%         included, as it was removed from the list

          for iField = 1:length(dawgStructFieldNames)

              thisFieldName = dawgStructFieldNames{iField} ;
              thisField = atomicTpsDawgStruct.(thisFieldName) ;

              shapeIndicator = field_size_to_shape_indicator( thisField, nTargets, ...
                  nPulseLengths, nQuarters, nHistBins ) ;

            if (strcmp(thisFieldName, 'planetCandidateStruct'))
                % planetCandidateStruct is sometimes empty and sometimes a struct of arrays
                tpsDawgStruct.(thisFieldName){targetStart:targetEnd} = thisField ;
            else

              switch shapeIndicator

                  case{ 1 }
                      % Do nothing, fields already empty
                      continue;

                  case{ 2 } % Targets Vector or Empty Field

                      tpsDawgStruct.(thisFieldName)(targetStart:targetEnd) = thisField ;

                  case{ 3 } % Target Pulse Length matrix
                      
                      tpsDawgStruct.(thisFieldName)(targetStart:targetEnd,1:nPulseLengths) = reshape( thisField, nTargets, nPulseLengths ) ;

                  case{ 4 } % Target Quarters Matrix

                      tpsDawgStruct.(thisFieldName)(targetStart:targetEnd,1:nQuarters) = thisField' ;
                      
                  case{ 5 } % Target Histrograms Bins Matrix

                      tpsDawgStruct.(thisFieldName)(targetStart:targetEnd,1:nHistBins, 1:nPulseLengths) =  thisField ;    

                  otherwise

                      error( 'tps:assembleTpsDawgStruct:fieldShapeNotRecognized', ...
                          ['assemble_tps_dawg_struct: shape of field ', thisFieldName, ...
                          ' not recognized on target ', num2str(iDir)] ) ;

              end % switch statement
            end

          end % loop over fields

%         append the taskfile information, which does not come out of the atomic DAWG
%         struct

          tpsDawgStruct.taskfile(targetStart:targetEnd) = repmat( ...
              { fullfile( dirSuffix, subdirList(iDir).name ) }, nTargets, 1 ) ;

          targetStart = targetEnd + 1 ;
          
%         if we are due to perform a clear operation, do that now, and pause for 1 second
%         so that MATLAB has time to do it

          clear tpsTaskDawgStruct nTargets thisFieldName thisField fieldSize targetEnd ;
          if mod( iDir, clearPeriod ) == 0
              pause( 1 ) ;
          end
      
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

      clear tpsTaskDawgStruct nTargets thisFieldName thisField fieldSize targetEnd ;
      if mod( iDir, clearPeriod ) == 0
          pause( 1 ) ;
      end
      
  end % loop over subdirs
  
% if some directories failed due to errors, identify the number of missing targets and
% remove them from the dawg struct

  missingKeplerIdPointer = find( tpsDawgStruct.keplerId == 0 ) ;
  if ~isempty( missingKeplerIdPointer )
      for iField = 1:length( dawgStructFieldNames )
          thisFieldName = dawgStructFieldNames{iField} ;
          if isequal( length(size(tpsDawgStruct.(thisFieldName))), 3 )
              tpsDawgStruct.(thisFieldName)(missingKeplerIdPointer,:,:) = [] ;
          else
              tpsDawgStruct.(thisFieldName)(missingKeplerIdPointer,:) = [] ;
          end        
      end
      tpsDawgStruct.taskfile(missingKeplerIdPointer) = [] ;
  end 

% If there were no subdirs present, then none of the code in the loop will execute, and
% all we need to do here is prevent the final bits of the routine from trying to run in
% that case

  if nDirs > 0
  
%     append the pulse durations and unit of work

      tpsDawgStruct.pulseDurations = pulseDurations ;  
      tpsDawgStruct.unitOfWorkKjd  = unitOfWorkKjd ;
  
%     perform the save

      fullFilename = [saveFilenameBase,dirSuffix] ;
      disp([ ' ... saving aggregated struct to ', fullFilename,' ... ']) ;
      save( fullFilename, 'tpsDawgStruct', '-v7' ) ;
      fullErrorName = [saveErrorNameBase,dirSuffix] ;
      disp([' ... saving target error struct to ', fullErrorName, ' ... ']) ;
      targetFailureStruct = targetFailureStruct(:) ;
      save( fullErrorName, 'targetFailureStruct' ) ;
      if ~isempty( taskAddedPlanetStruct )
          fullAddedPlanetName = [saveAddedPlanetBaseName,dirSuffix] ;
          disp([' ... saving added planet struct to ', fullAddedPlanetName, ' ... ']) ;
          save( fullAddedPlanetName, 'taskAddedPlanetStruct' ) ;
      end
      
  else
      
      disp( ' ... nothing to aggregate, so exiting aggregator ... ' ) ;
      
  end
      
return

%=========================================================================================

% subfunction which performs preallocation

function tpsDawgStruct = preallocate_tps_dawg_struct( nDirs, nPulseLengths, ...
              nQuarters, nHistBins, nTargetsPerSubtask, atomicTpsDawgStruct )
          
  dawgStructFieldNames = fieldnames( atomicTpsDawgStruct ) ;
  nTargets             = length( atomicTpsDawgStruct.keplerId ) ;

  nTargetsTotal = nDirs * nTargetsPerSubtask ;
  
  for iField = 1:length(dawgStructFieldNames) ;
      
      thisFieldName = dawgStructFieldNames{iField} ;
      tpsDawgStruct.(thisFieldName) = [] ;

      
        if (strcmp(thisFieldName, 'planetCandidateStruct'))
            % planetCandidateStruct is sometimes empty and sometimes a struct of arrays
            tpsDawgStruct.(thisFieldName) = cell(nTargetsTotal,1) ;
        else


          shapeIndicator = field_size_to_shape_indicator( atomicTpsDawgStruct.(thisFieldName), ...
              nTargets, nPulseLengths, nQuarters, nHistBins ) ;
          
          switch shapeIndicator
              
                case{ 1 }
                    error('No fields should be empty!')

                case{ 2 }
                    if isequal(strmatch(thisFieldName,'keplerId'),1)
                        tpsDawgStruct.(thisFieldName) = zeros(nTargetsTotal,1, 'int32') ;
                    else
                        tpsDawgStruct.(thisFieldName) = zeros(nTargetsTotal,1, 'single') ;
                    end
                                    
                case{ 3 }
                  
                    if iscell( atomicTpsDawgStruct.(thisFieldName) )
                        tpsDawgStruct.(thisFieldName) = cell(nTargetsTotal,nPulseLengths) ;
                    else
                        tpsDawgStruct.(thisFieldName) = zeros(nTargetsTotal, nPulseLengths, 'single') ;
                    end
                  
                case{ 4 }
                  
                    tpsDawgStruct.(thisFieldName) = zeros(nTargetsTotal, nQuarters, 'single') ;
                  
                case{ 5 }
                  
                    tpsDawgStruct.(thisFieldName) = zeros(nTargetsTotal, nHistBins, nPulseLengths, 'single') ;     
                  
          end % switch

        end
          
      
  end % loop over fields
  
% put the task file and sesCombinedToYieldMes, indexOfSesAdded cell arrays 
% at the end  
  
  tpsDawgStruct.taskfile = cell(nDirs,1) ;   

return

%=========================================================================================

% convert the size of the field to a field shape indicator
      
function shapeIndicator = field_size_to_shape_indicator( thisField, nTargets, ...
    nPulseLengths, nQuarters, nHistBins )

% manage degenerate cases -- cases in which either nPulseLengths or nQuarters are equal to
% one, so it can't tell some of the cases apart.  The good news is, if this is the
% situation then a single shape will do the job for everything!

  if nPulseLengths == 1
      nPulseLengths = 0 ;
  end
  if nQuarters == 1
      nQuarters = 0 ;
  end

  thisFieldSize             = size( thisField ) ;
  emptyField                = isequal( thisFieldSize, [0 0] ) ;
  targetsVector             = isequal( thisFieldSize, [1 nTargets] ) ;
  targetPulseLengthsMatrix  = isequal( thisFieldSize, [1 nPulseLengths * nTargets] ) ;
  targetQuartersMatrix      = isequal( thisFieldSize, [nQuarters nTargets] ) ;
  targetHistBinsMatrix      = isequal( thisFieldSize, [nHistBins nPulseLengths * nTargets] ) ;
          
%  convert to a scalar integer value from 1 to 4

  shapeIndicator = emptyField + 2 * targetsVector + 3 * targetPulseLengthsMatrix + 4 * targetQuartersMatrix + 5 * targetHistBinsMatrix;
  
return


