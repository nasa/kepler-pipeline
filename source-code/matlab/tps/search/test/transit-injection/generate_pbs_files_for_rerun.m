function generate_pbs_files_for_rerun( topDir, archString, wallTimeSecs, gbPerTask )
%
% generate_tps_inputs_for_transit_injection:  This function generates the
%     directory structure for a transit injection run and in each subtask
%     directory generates the tps input struct.  The input flux is replaced
%     by the detrendedFluxTimeSeries from TPS if the target produced no TCE
%     in the run associated with the tpsTceStruct, or is replaced by the dv
%     model gapped flux if the target did produce a TCE.  The module
%     parameters used for each input are specified by tpsModuleParameters
%     but performQuarterStitching is explicity set to false.  
%
% Inputs:
%    keplerIdList: list of kepler IDs to perform injection study on
%    dvRunDir:     run directory from a prior DV run.  For targets that
%                  produced TCEs in the tpsTceStruct, the DV post fit flux
%                  will be pulled from here
%    tpsTceStruct: A TPS TCE struct from a previous TPS run that contains
%                  all the kepler ids in the keplerIdList
%    tpsModuleParameters:  a tpsModuleParameters struct that will be used
%                          in all the generated tps inputs
%    outputDir:    The location where the results will go.
%
% Outputs: The result is a directory structure with task directories that
%          include subtask directories.  A tpsInputStruct will be placed in
%          each subtask directory.
%
%==========================================================================
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

% PRELIMINARIES:
%
  
% determine the # of CPUs per node via a lookup

  if isempty(archString)
      archString = 'wes' ;
  end
    
% convert the wall time from seconds to HH:MM:SS

  hours = floor( wallTimeSecs / 3600 ) ;
  wallTimeSecs = wallTimeSecs - hours * 3600 ;
  minutes = floor( wallTimeSecs / 60 ) ;
  wallTimeSecs = wallTimeSecs - minutes * 60 ;
  seconds = round( wallTimeSecs ) ;

  wallTimeString = [num2str(hours),':',num2str(minutes,'%02d'),...
      ':',num2str(seconds,'%02d')] ;  

% open a master shell script

  masterPointer = fopen(fullfile(topDir,'script_for_rerun.sh'),'w') ; 
  fprintf(masterPointer,'#!/bin/bash\n') ;
  fprintf(masterPointer,'\n') ;
  
% get a list of directories

  subdirList = get_list_of_subdirs( topDir ) ;
  nDirs = length(subdirList) ;
  
  for iDir = 1:nDirs
      % get a list of subtasks
      subtaskList = get_list_of_subdirs( fullfile( topDir, subdirList(iDir).name ) );
      nSubTasks = length(subtaskList);
      
      % check which subtasks have run
      isFileMissing = false(nSubTasks,1);
      for iSub = 1:nSubTasks
          subDir = dir( fullfile(topDir,subdirList(iDir).name,subtaskList(iSub).name) );
          if isempty(strfind([subDir.name],'tps-diagnostic-struct.mat'))
              % get subtask number
              subTaskName = subtaskList(iSub).name;
              [~, subTaskNumber] = strread(subTaskName,'%s%d','delimiter','-');
              isFileMissing(subTaskNumber + 1) = true;
          end
      end
      
      if any(isFileMissing)
          
          % get existing PBS filename
          tempDirList = dir( fullfile( topDir, subdirList(iDir).name ) ) ;
          isDir = [tempDirList.isdir] ;
          tempDirList(isDir) = [] ;
          dirName = {tempDirList.name} ;
          dotDirs = strcmp('.', dirName) | strcmp('..',dirName) ;
          tempDirList(dotDirs) = [] ;
          for ii=1:length(tempDirList)
              if ~isempty(strfind(tempDirList(ii).name,'.pbs'))
                  tempIndex = ii;
              end
          end
          tempDirList = tempDirList(tempIndex);
          
          pbsFile = tempDirList.name;
          dotIndex = strfind(pbsFile,'.');
          slashIndex = strfind(topDir,'/');
          slashIndex = slashIndex(end);
          topDirTruncated = topDir(slashIndex+1:end);
          pbsFile = strcat(pbsFile(1:dotIndex-1),'-rerun',pbsFile(dotIndex:end));
          
          % for subtasks that didnt run, generate a pbs script
          subTaskNumbers = find(isFileMissing) - 1;
          build_pbs_script( pbsFile,topDirTruncated, topDir, subdirList(iDir).name, archString, subTaskNumbers, wallTimeString, gbPerTask ) ;
          
          % add to the master run script
          fprintf(masterPointer,'qsub -V -o %s/output.txt %s\n',...
              ['$TPS_TASK_HOME/',topDirTruncated,'/',subdirList(iDir).name], ...
              fullfile(subdirList(iDir).name,pbsFile) ) ;
      end
      
  end

  fclose(masterPointer) ;
  
% END TOP-LEVEL DIRECTORY WORK
  
  return
  
  %=========================================================================================

% function which writes the contents of the batch ("pbs") file

function build_pbs_script( pbsFile, topDirTruncated, topDir, subDir, archString, subTaskList, wallTimeString, gbPerTask )

  [~,~,~,jobString,~] = strread(pbsFile,'%s%s%d%s%s','delimiter','-');
  jobString = char(jobString);

  pbsFile = fullfile(topDir, subDir, pbsFile);
  filePointer = fopen(pbsFile, 'w') ;
  
% write the top-level stuff

  fprintf(filePointer,'#!/bin/bash\n') ;
  fprintf(filePointer,'#\n') ;
  fprintf(filePointer,'# set to Kepler group\n') ;
  fprintf(filePointer,'#PBS -W group_list=s1089\n\n') ;
  
  fprintf(filePointer,'# join stderr and stdout\n') ;
  fprintf(filePointer,'#PBS -j oe\n\n') ;
  
  fprintf(filePointer,'# do not send mail and do not attempt to restart\n') ;
  fprintf(filePointer,'#PBS -m n\n') ;
  fprintf(filePointer,'#PBS -r n\n\n') ;
  
% write resources which are to be used
  
  archLookup = ismember({'san','wes','ivy','has'},archString) ;
  gbPerCore = [2, 2, 3.2, 5.3] ;
  maxCpusPerArch = [16, 12, 20, 24] ;
  coresPerNode = maxCpusPerArch(archLookup) ;
  gbPerCore = gbPerCore( archLookup );
  
% calculate the number of cores per target

  nCoresPerTarget = ceil(gbPerTask / gbPerCore);
  
% calculate the number of nodes needed

  nTargets = length(subTaskList);
  nCores = nTargets * nCoresPerTarget;
  nNodesThisJob = ceil(nCores / coresPerNode);
  nTargetsPerNode = floor(coresPerNode / nCoresPerTarget);
  
  fprintf(filePointer,'#PBS -l select=%d:',nNodesThisJob) ;
  fprintf(filePointer,'model=%s\n',archString) ;

% write the queue

  fprintf(filePointer,'#PBS -q kepler\n') ;
  
% set the wall time

  fprintf(filePointer, '#PBS -l walltime=%s\n',wallTimeString) ;
  fprintf(filePointer,'\n') ;
  
% make sure its a row vector
  
  subTaskList = subTaskList(:);
  subTaskList = subTaskList';
  
% write the command string which generates the tasks

  fprintf(filePointer, ...
      'echo %s | tr " " "\\n" | parallel -j %d --sshloginfile $PBS_NODEFILE ',num2str(subTaskList),nTargetsPerNode) ;
  fprintf(filePointer,'"$TPS_EXE_HOME/rerun_tps_injection_on_nas.sh /nasa/mw/2010b $TPS_TASK_HOME/%s '...
      ,fullfile(topDirTruncated,subDir)) ;
  fprintf(filePointer,'{} 0 > $TPS_TASK_HOME/%s/logfiles/logfile-%s-{}.txt 2>&1" \n',...
      topDirTruncated,jobString) ;
  
  fclose( filePointer ) ;
  
return

%=========================================================================================



