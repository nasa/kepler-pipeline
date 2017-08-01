function aggregate_tps_dawg_structs_across_tasks( topDir, nSubdirsMax, ...
    saveToWorkingDir )
%
% aggregate_tps_dawg_structs_across_tasks -- perform aggregation of the TPS task-level
% DAWG structs into one overall DAWG struct
%
% aggregate_tps_dawg_structs_across_tasks( topDir ) drills down into the sub-directories
%    of the specified topDir, aggregating the DAWG structs in those directories into a
%    single DAWG struct.  The DAWG struct, along with a unitOfWork vector and a
%    pulseLengths vector, are saved in the topDir as tps-dawg-struct.  Simultaneously, a
%    set of target-level structs describing processing failures will be aggregated to
%    tps-error-struct, also saved in topDir.
%
% aggregate_tps_dawg_structs_across_tasks( topDir, nSubdirsMax, saveToWorkingDir )
%    performs the same operation but allows the user to specify the number of
%    sub-directories to be searched and to save the resulting information in the working
%    directory instead of the topDir.  These options are intended for testing use only.
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

%=========================================================================================

% handle missing or empty optional arguments

  fill_aggregator_optional_arguments ;
  
% define the filename which is to be used for the save, a constant for now, and define the
% full path for saving the struct

  saveFilenameBase   = 'tps-dawg-struct' ; % root of the savename for the struct
  saveErrorNameBase  = 'tps-dawg-errors' ; % root for struct of target dawg errors
  savePlanetNameBase = 'task-added-planet-struct' ; % root for struct of planet ground truth
  saveTceNameBase    = 'tps-tce-struct' ;
  saveFilename       = saveFilenameBase ;
  saveErrorName      = saveErrorNameBase ;
  savePlanetName     = savePlanetNameBase ;
  saveTceName        = saveTceNameBase ;
  
  if ~saveToWorkingDir
      saveFilename   = fullfile(topDir,saveFilename) ;
      saveErrorName  = fullfile(topDir,saveErrorName) ;
      savePlanetName = fullfile(topDir,savePlanetName) ;
      saveTceName    = fullfile(topDir,saveTceName) ;
  end
  
  firstFileParsed = false ;
  targetFailureStruct = [] ;
  addedPlanetStruct   = [] ;
  
% acquire the full list of subdirectories to topDir, removing the '.' and '..' instances

  subdirList = get_list_of_subdirs( topDir ) ;
  nDirs = min( nSubdirsMax, length(subdirList) ) ;
    
% loop over directories

  for iDir = 1:nDirs
      
      disp( [' ... ', datestr(now), ...
          ':assembling TPS DAWG information from ',subdirList(iDir).name, ...
          ' directory ...' ] ) ;
      parsedDawgFile = false ;
      try
          localDawgStructDir = dir( fullfile( topDir, subdirList(iDir).name, ...
              [saveFilenameBase,'*'] ) ) ;
          
          % if the file doesnt exist then the within-task aggregator failed
          % to run so run it now
          %if isempty(localDawgStructDir)
              dirName = strcat(topDir,'/',subdirList(iDir).name) ;
              aggregate_tps_dawg_structs_within_task( char(dirName),[],[]) ;
              localDawgStructDir = dir( fullfile( topDir, subdirList(iDir).name, ...
                  [saveFilenameBase,'*'] ) ) ;
          %end
          
          localDawgStructName = localDawgStructDir.name ;
          dummy = load( fullfile( topDir, subdirList(iDir).name, localDawgStructName ) ) ;
          localDawgStruct = dummy.tpsDawgStruct ;
          clear dummy ;

%         if this is the first task, then we can construct the tpsDawgStruct with all
%         appropriate fields -- all the standard fields except for pulseDurations and
%         unitOfWorkKjd, plus we need to put topDir into position

          if ~firstFileParsed

              pulseDurations = localDawgStruct.pulseDurations ;
              unitOfWork     = localDawgStruct.unitOfWorkKjd ;
              localDawgStruct = rmfield( localDawgStruct, ...
                  {'pulseDurations','unitOfWorkKjd'} ) ;
              dawgFieldNames = fieldnames( localDawgStruct ) ;
              tpsDawgStruct.topDir = topDir ;
              for iField = 1:length( dawgFieldNames )
                  tpsDawgStruct.(dawgFieldNames{iField}) = ...
                      localDawgStruct.(dawgFieldNames{iField}) ;
              end
              firstFileParsed = true ;

          else % on subsequent passes, we can simply concatenate the appropriate fields

              for iField = 1:length( dawgFieldNames ) 
                  thisFieldName = dawgFieldNames{iField} ;
                  tpsDawgStruct.(thisFieldName) = [tpsDawgStruct.(thisFieldName) ; ...
                      localDawgStruct.(thisFieldName)] ;
              end
              
              parsedDawgFile = true ;

          end % conditional on iDir == 1

          localErrorStructDir = dir( fullfile( topDir, subdirList(iDir).name, ...
              [saveErrorNameBase,'*'] ) ) ;
          localErrorStructName = localErrorStructDir.name ;
          dummy = load( fullfile( topDir, subdirList(iDir).name, localErrorStructName ) ) ;
          if ~isempty(dummy.targetFailureStruct(1).directory)
              targetFailureStruct = [targetFailureStruct ; dummy.targetFailureStruct] ;
          end
          
          localPlanetStructDir = dir( fullfile( topDir, subdirList(iDir).name, ...
              [savePlanetNameBase,'*'] ) ) ;
          if ~isempty(localPlanetStructDir)
              localPlanetStructName = localPlanetStructDir.name ;
              dummy = load( fullfile( topDir, subdirList(iDir).name, localPlanetStructName ) ) ;
              addedPlanetStruct = [addedPlanetStruct ; dummy.taskAddedPlanetStruct] ;
          end

          clear dummy          
          clear localDawgStruct ;
          pause(1) ;

      catch
          
          thrownError = lasterror ;
          if parsedDawgFile
              disp( ['    ... error aggregating target failure info, identifier == ', ...
                  thrownError.identifier,', continuing to next sky group'] ) ;
          else
              disp( ['    ... error aggregating DAWG info, identifier == ', ...
                  thrownError.identifier,', continuing to next sky group'] ) ;
          end
          
      end
      
  end % loop over directories
  
% reattach the pulseDurations vector, and also make it into the pulseLengths vector 

  tpsDawgStruct.pulseDurations = pulseDurations ;
  pulseLengths = pulseDurations ;
  tpsDawgStruct.unitOfWorkKjd = unitOfWork ;
  
% perform the save

  disp(' ... saving full-run DAWG struct ... ' ) ;
%  save( saveFilename, 'tpsDawgStruct', 'unitOfWork', 'pulseLengths', '-v7.3' ) ;
  intelligent_save( saveFilename, 'tpsDawgStruct' ) ;
  disp(' ... saving full-run target error struct ... ') 
%  save( saveErrorName, 'targetFailureStruct', '-v7' ) ;
  intelligent_save( saveErrorName, 'targetFailureStruct' ) ;
  if ~isempty(addedPlanetStruct)
      intelligent_save( savePlanetName, 'addedPlanetStruct' ) ;
  end
  
% Get the tceStruct and save it now

  tpsTceStruct = get_tces_from_tps_dawg_struct( tpsDawgStruct ) ;
  disp(' ... saving full-run TCE struct ... ' ) ;
  intelligent_save( saveTceName, 'tpsTceStruct' ) ;

return

