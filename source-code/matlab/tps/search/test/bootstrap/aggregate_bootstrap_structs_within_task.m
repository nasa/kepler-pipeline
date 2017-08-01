function aggregate_bootstrap_structs_within_task( fullPathToTaskFiles, nSubdirsMax, ...
    saveToWorkingDir )
%=========================================================================================
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

% handle optional arguments

if ~exist('nSubdirsMax','var') || isempty( nSubdirsMax )
    nSubdirsMax = inf ;
end
if ~exist('saveToWorkingDir','var') || isempty(saveToWorkingDir)
    saveToWorkingDir = false ;
end

% a few constants

  pattern = 'tps-matlab' ; % text which precedes instance and task numbers in dir name
  bootstrapFileName = 'bootstrap-results-struct.mat' ; % name of atomic dawg files
  saveFilenameBase = 'bootstrap-struct' ; % root of the savename for the struct
  saveErrorNameBase = 'bootstrap-errors' ; % save file for aggregation error info
  
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
  
  outputStructTemplate = struct('nTransits', -1, 'nTrials', -1, 'duration', -1, ...
      'nCadences', -1, 'mesBins', -1, 'counts', -1, 'probSum', -1);
  bootstrapOutputStruct = outputStructTemplate;
  
  targetFailureStruct = struct('directory',[], 'message',[], 'identifier', [], ...
      'stack',[] ) ;
  nFailedTasks = 0 ;
  
% loop over subdirs
  firstOutputFilled = false;
  for iDir = 1:nDirs
      
      disp( [' ... assembling Bootstrap information from ',subdirList(iDir).name, ...
          ' directory ...' ] ) ;
      
      try
     
          dummy = load(  fullfile( fullPathToTaskFiles, subdirList(iDir).name, bootstrapFileName ) ) ; 
          bootstrapResults = dummy.bootstrapResults ;
          clear dummy

          nTransitsFull = [bootstrapOutputStruct.nTransits];
          nTransitIndicator = nTransitsFull == bootstrapResults.nTransits;
          if any(nTransitIndicator)
              % we already have an output struct for this nTransits so
              % update it with the new information
              bootstrapOutputStruct(nTransitIndicator).nTrials = ...
                  bootstrapOutputStruct(nTransitIndicator).nTrials + bootstrapResults.nTrials;
              bootstrapOutputStruct(nTransitIndicator).counts = ...
                  bootstrapOutputStruct(nTransitIndicator).counts + bootstrapResults.counts;
              bootstrapOutputStruct(nTransitIndicator).probSum = ...
                  bootstrapOutputStruct(nTransitIndicator).probSum + bootstrapResults.probSum;
          else
              % we dont have an output struct for this nTransits, so add a
              % new one and copy over the information
              if firstOutputFilled
                  outputIndex = length(nTransitsFull) + 1;
              else
                  outputIndex = 1;
                  firstOutputFilled = true;
              end
              bootstrapOutputStruct(outputIndex) = outputStructTemplate;
              bootstrapOutputStruct(outputIndex).nTransits = bootstrapResults.nTransits;
              bootstrapOutputStruct(outputIndex).nTrials = bootstrapResults.nTrials;
              bootstrapOutputStruct(outputIndex).duration = bootstrapResults.duration;
              bootstrapOutputStruct(outputIndex).nCadences = bootstrapResults.nCadences;
              bootstrapOutputStruct(outputIndex).mesBins = bootstrapResults.mesBins;
              bootstrapOutputStruct(outputIndex).counts = bootstrapResults.counts;
              bootstrapOutputStruct(outputIndex).probSum = bootstrapResults.probSum;
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
      
  end % loop over subdirs

% perform the save

  fullFilename = [saveFilenameBase,dirSuffix] ;
  disp([ ' ... saving aggregated struct to ', fullFilename,' ... ']) ;
  save( fullFilename, 'bootstrapOutputStruct', '-v7' ) ;
  fullErrorName = [saveErrorNameBase,dirSuffix] ;
  disp([' ... saving target error struct to ', fullErrorName, ' ... ']) ;
  targetFailureStruct = targetFailureStruct(:) ;
  save( fullErrorName, 'targetFailureStruct' ) ;
           
return

%=========================================================================================
