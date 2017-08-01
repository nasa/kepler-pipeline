function aggregate_transit_injection_structs_within_task( fullPathToTaskFiles, nSubdirsMax, ...
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

if ~exist('nSubdirsMax','var') || isempty( nSubdirsMax )
    nSubdirsMax = inf ;
end
if ~exist('saveToWorkingDir','var') || isempty(saveToWorkingDir)
    saveToWorkingDir = false ;
end

% a few constants

  pattern = 'tps-matlab' ; % text which precedes instance and task numbers in dir name
  injectionFileName = 'tps-injection-results-struct.mat' ; % name of atomic dawg files
  saveFilenameBase = 'tps-injection-struct' ; % root of the savename for the struct
  saveErrorNameBase = 'tps-injection-errors' ; % save file for aggregation error info
  
% find the instance and task number portions of the string, we'll need them later

  dirSuffixLocation = strfind( fullPathToTaskFiles, pattern ) ;
  dirSuffix         = fullPathToTaskFiles(dirSuffixLocation(end)+length(pattern):end) ;
  
% setup save to the task file directory unless the user requests otherwise

  if ~saveToWorkingDir
      saveFilenameBase        = fullfile(fullPathToTaskFiles,saveFilenameBase) ;
      saveErrorNameBase       = fullfile(fullPathToTaskFiles,saveErrorNameBase) ;
  end
  
% get the list of subdirs, removing the '.' and '..' entries from the list

  subdirList = get_list_of_subdirs( fullPathToTaskFiles ) ;
  nDirs = min( length(subdirList),nSubdirsMax ) ;
  
  injectionOutputStruct = [] ;
  
  targetFailureStruct = struct('directory',[], 'message',[], 'identifier', [], ...
      'stack',[] ) ;
  nFailedTasks = 0 ;
  
% loop over subdirs

  firstFileParsed = false ;
  injectionCounter = 1 ;
  for iDir = 1:nDirs
      
      disp( [' ... assembling TPS transit Injection information from ',subdirList(iDir).name, ...
          ' directory ...' ] ) ;
      
      try
     
          dummy = load(  fullfile( fullPathToTaskFiles, subdirList(iDir).name, injectionFileName ) ) ; 
          atomicTpsInjectionStruct = dummy.injectionOutputStruct ;
          clear dummy

%         if this is the first task file, we can determine the # of quarters and # of
%         pulse lengths, and then pre-allocate the task-level struct

          if ~firstFileParsed

              nInjections = length( atomicTpsInjectionStruct.maxMes );
              injectionOutputStruct = preallocate_tps_injection_struct( nDirs, nInjections, ...
                  atomicTpsInjectionStruct ) ;
              injectionStructFieldNames = fieldnames( atomicTpsInjectionStruct ) ;
              firstFileParsed = true ;

          end
          
          nInjectionsCompleted = length( atomicTpsInjectionStruct.injectedPeriodDays );

          for iField = 1:length(injectionStructFieldNames)

              thisFieldName = injectionStructFieldNames{iField} ;
              thisField = atomicTpsInjectionStruct.(thisFieldName) ;
              
              % get rid of zero padded entries when all the injections are
              % not completed
              if (length(thisField) > nInjectionsCompleted)
                  thisField = thisField(1:nInjectionsCompleted);
              end

              shapeIndicator = field_size_to_shape_indicator( thisField, nInjectionsCompleted );

              switch shapeIndicator

                  case{ 1 }
                      if isequal(thisFieldName,'keplerId')
                          injectionOutputStruct.(thisFieldName)(injectionCounter:(injectionCounter + nInjectionsCompleted - 1)) = ...
                              repmat(thisField,nInjectionsCompleted,1);
                      else
                          injectionOutputStruct.(thisFieldName)(iDir) = thisField ;
                      end

                  case{ 2 }
                      
                      injectionOutputStruct.(thisFieldName)(injectionCounter:(injectionCounter + nInjectionsCompleted - 1)) = thisField;

                  otherwise

                      error( 'tps:assembleTpsInjectionStruct:fieldShapeNotRecognized', ...
                          ['assemble_tps_injection_struct: shape of field ', thisFieldName, ...
                          ' not recognized on target ', num2str(iDir)] ) ;

              end % switch statement

          end % loop over fields

%         append the taskfile information, which does not come out of the atomic DAWG
%         struct

          injectionOutputStruct.taskfile{iDir} = fullfile( dirSuffix, subdirList(iDir).name );
          injectionCounter = injectionCounter + nInjectionsCompleted;
          
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
      
  end % loop over subdirs
  
% if some directories failed due to errors remove zero entries in the
% fields that have length nDirs
  injectionStructFieldNames = fieldnames( injectionOutputStruct ) ;
  fieldLengths = structfun(@length,injectionOutputStruct);
  fieldIndices = find(fieldLengths == nDirs);
  missingIndicator = injectionOutputStruct.stellarRadiusInSolarRadii == 0;
  if any(missingIndicator)
      for iField = 1:length( fieldIndices )
          thisFieldName = injectionStructFieldNames{fieldIndices(iField)} ;
          injectionOutputStruct.(thisFieldName)(missingIndicator) = [] ;   
      end
      
  end 
  
% remove zero entries elsewhere resulting from not finishing all the injections
  fieldIndices = find(fieldLengths == nDirs * nInjections);
  missingIndicator = injectionOutputStruct.keplerId == 0;
  if any(missingIndicator)
        for iField = 1:length( fieldIndices )
            thisFieldName = injectionStructFieldNames{fieldIndices(iField)} ;
            injectionOutputStruct.(thisFieldName)(missingIndicator) = [] ;   
        end
  end 

% If there were no subdirs present, then none of the code in the loop will execute, and
% all we need to do here is prevent the final bits of the routine from trying to run in
% that case

  if nDirs > 0
  
%     perform the save

      fullFilename = [saveFilenameBase,dirSuffix] ;
      disp([ ' ... saving aggregated struct to ', fullFilename,' ... ']) ;
      save( fullFilename, 'injectionOutputStruct', '-v7' ) ;
      fullErrorName = [saveErrorNameBase,dirSuffix] ;
      disp([' ... saving target error struct to ', fullErrorName, ' ... ']) ;
      targetFailureStruct = targetFailureStruct(:) ;
      save( fullErrorName, 'targetFailureStruct' ) ;
      
  else
      
      disp( ' ... nothing to aggregate, so exiting aggregator ... ' ) ;
      
  end
      
return

%=========================================================================================

% subfunction which performs preallocation

function tpsInjectionStruct = preallocate_tps_injection_struct( nDirs, nInjections, ...
              atomicTpsInjectionStruct )
          
  injectionStructFieldNames = fieldnames( atomicTpsInjectionStruct ) ;
  
  for iField = 1:length(injectionStructFieldNames) ;
      
      thisFieldName = injectionStructFieldNames{iField} ;
      tpsInjectionStruct.(thisFieldName) = [] ;

      
          shapeIndicator = field_size_to_shape_indicator( atomicTpsInjectionStruct.(thisFieldName), ...
              nInjections ) ;
          
          switch shapeIndicator
              
              case{ 1 }
                  
                  if isequal(thisFieldName,'keplerId')
                      tpsInjectionStruct.(thisFieldName) = zeros(nDirs * nInjections, 1, 'int32') ;
                  else
                      tpsInjectionStruct.(thisFieldName) = zeros(nDirs, 1, 'single') ;
                  end
                                    
              case{ 2 }
                              
                  tpsInjectionStruct.(thisFieldName) = zeros(nDirs * ...
                      nInjections, 1, 'single') ;
                  
              otherwise
                  % some fields never got completely filled in the event that all the
                  % injections were not completed
                  tpsInjectionStruct.(thisFieldName) = zeros(nDirs * ...
                      nInjections, 1, 'single') ;
          end % switch 
          
      
  end % loop over fields
  
% put the task file and sesCombinedToYieldMes, indexOfSesAdded cell arrays 
% at the end  
  
  tpsInjectionStruct.taskfile = cell(nDirs,1) ;   

return

%=========================================================================================

% convert the size of the field to a field shape indicator
      
function shapeIndicator = field_size_to_shape_indicator( thisField, nInjections )

% manage degenerate cases 

  thisFieldSize            = size( thisField ) ;
  targetMatrix    = isequal( thisFieldSize, [1 1] ) ;
  targetInjectionMatrix     = isequal( thisFieldSize, [1 nInjections] ) ;
          
%  convert to a scalar integer value from 1 to 2

  shapeIndicator = targetMatrix + 2 * targetInjectionMatrix ;
  
return