function generate_inputs_for_bootstrap_monte_carlo( tpsInputStructTemplate, ...
    nTransitsVector, nBatchJobs, archString, wallTimeSecs, nDuplicatesPerNTransits)

% build the nTransits vector
%nTransitsVector = 2 .^ (2:log2(2048))';
%nTransitsVector = [3; nTransitsVector];
%nTransitsVector = nTransitsVector(:);
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
  
% determine the # of CPUs per node via a lookup

  if isempty(archString)
      archString = 'wes' ;
  end
  
  archLookup = ismember({'san','wes','ivy','has'},archString) ;
  if ~any(archLookup)
      error('tps:transitInjection:architectureUnknown', ...
          'Specified NAS architecture unknown' ) ;
  end
  maxCpusPerArch = [16, 12, 20, 24] ;
  coresPerNode = maxCpusPerArch(archLookup) ;
  
% determine the total number of targets

  nTargets = nDuplicatesPerNTransits * length(nTransitsVector);
  keplerIdList = (1:nTargets)';
  
% determine the job structure

  nodesPerJob = ceil(nTargets/(nBatchJobs * coresPerNode)) ;
  nBatchJobs  = ceil(nTargets/(coresPerNode*nodesPerJob)) ;
  disp(['Total of ',num2str(nBatchJobs),' jobs utilizing ',num2str(nodesPerJob), ...
      ' nodes per job and ',num2str(coresPerNode),' cores per node']) ;
  nDigits = max( 1, ceil(log10(nBatchJobs)) ) ;
  digitString = ['%0',num2str(nDigits),'d'] ;
  nTargetsPerJobMax = coresPerNode * nodesPerJob ;
  
% determine the targets which go into each job

  targetList = zeros(1,nTargetsPerJobMax*nBatchJobs) ;
  targetList(1:nTargets) = keplerIdList ;
  targetMap = reshape(targetList,nTargetsPerJobMax,nBatchJobs) ;  
    
% convert the wall time from seconds to HH:MM:SS
  hours = floor( wallTimeSecs / 3600 ) ;
  wallTimeSecs = wallTimeSecs - hours * 3600 ;
  minutes = floor( wallTimeSecs / 60 ) ;
  wallTimeSecs = wallTimeSecs - minutes * 60 ;
  seconds = round( wallTimeSecs ) ;

  wallTimeString = [num2str(hours),':',num2str(minutes,'%02d'),...
      ':',num2str(seconds,'%02d')] ;  
  
% get the date and use it to make a directory name string

  currentTime = datestr(now,30) ; 
  currentYear = currentTime(1:4) ;
  dayOfYear   = num2str(floor(datestr2doy(now)),'%03d') ;
  dirName = ['tps-matlab-',currentYear,dayOfYear] ;
  
% TOP-LEVEL DIRECTORY WORK

  if ~exist( dirName, 'dir' )
      mkdir(dirName) ;
  end
  logDirName = fullfile(dirName,'logfiles') ;
  if ~exist(logDirName,'dir')
      mkdir(logDirName) ;
  end

% open a master shell script

  masterPointer = fopen(fullfile(dirName,[dirName,'.sh']),'w') ; 
  fprintf(masterPointer,'#!/bin/bash\n') ;
  fprintf(masterPointer,'\n') ;
  
% TASK DIRECTORY WORK

% initialize
  randSeedOffset = 0;
  nTransitCounter = 0;
  nTransits = nTransitsVector(1);
  
  for iJob = 1:nBatchJobs
      
      jobString = num2str(iJob-1,digitString) ;
      jobDirName = [dirName,'-',jobString] ;
      if ~exist(fullfile(dirName,jobDirName),'dir')
          mkdir(fullfile(dirName,jobDirName)) ;
      end
      
      disp([datestr(now,0),':  building job number ', num2str(iJob), ...
          ' of ',num2str(nBatchJobs)]) ;
      
      targetsInJob = targetMap(:,iJob) ;
      targetsInJob(targetsInJob<1) = [] ;
      nTargetsInJob = length(targetsInJob) ;
      nNodesThisJob = ceil(nTargetsInJob / coresPerNode) ;
      
%     build the script for this job

      build_pbs_script( dirName, jobDirName, jobString, ...
          archString, coresPerNode, nNodesThisJob, nTargetsInJob, ...
          wallTimeString ) ;
      
%     add to the master script

      fprintf(masterPointer,'qsub -V -o %s/output.txt %s\n',...
          ['$TPS_TASK_HOME/',dirName,'/',jobDirName], ...
          fullfile(jobDirName,[jobDirName,'.pbs'])) ;
      
% SUB-TASK DIRECTORY WORK

      for iTarget = 1:nTargetsInJob
          
          % adjust nTransits if needed
          nTransitCounter = nTransitCounter + 1;
          if nTransitCounter > nDuplicatesPerNTransits
              nTransitCounter = 1;
              nTransitsIndex = find( nTransits == nTransitsVector );
              nTransits = nTransitsVector(nTransitsIndex + 1);
          end
      
          iDir = iTarget - 1 ;
          subDirName = ['st-',num2str(iDir)] ;
          fullDirName = fullfile(dirName,jobDirName,subDirName) ;
          if ~exist(fullDirName,'dir')
              mkdir(fullDirName) ;
          end

%         set up the input

          keplerId = targetsInJob(iTarget) ;
          inputsStruct = tpsInputStructTemplate ;
          inputsStruct.tpsTargets.keplerId = keplerId ;
          inputsStruct.tpsTargets.randSeedOffset = randSeedOffset;
          inputsStruct.tpsTargets.nTransits = nTransits;

          save( fullfile(fullDirName,'tps-inputs-0.mat'),'inputsStruct' ) ;
          
      end
      
% END SUB-TASK DIRECTORY WORK

% pause for 1 second to allow garbage collection to execute

      pause(1) ;

  end
  
% END TASK DIRECTORY WORK

  fclose(masterPointer) ;
  
% write the aggregator PBS script

  write_aggregator_pbs_script( dirName, nBatchJobs ) ;
  
% END TOP-LEVEL DIRECTORY WORK
  
  return
  
  %=========================================================================================

% function which writes the contents of the batch ("pbs") file

function build_pbs_script( dirName, jobDirName, jobString, archString, nCpus, ...
    nNodesThisJob, nTargetsInJob, wallTimeString )

  scriptName = fullfile(dirName, jobDirName, [jobDirName,'.pbs']) ;
  filePointer = fopen(scriptName, 'w') ;
  
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

  if nTargetsInJob < nCpus
      nCpus = nTargetsInJob ;
      nNodesThisJob = 1 ;
  end
  
  fprintf(filePointer,'#PBS -l select=%d:',nNodesThisJob) ;
  fprintf(filePointer,'model=%s\n',archString) ;
  nCpusTotal = min(nNodesThisJob * nCpus, nTargetsInJob) ;

% write the queue

  fprintf(filePointer,'#PBS -q kepler\n') ;
  
% set the wall time

  fprintf(filePointer, '#PBS -l walltime=%s\n',wallTimeString) ;
  
  fprintf(filePointer,'\n') ;
  
% set the node and task counts

  fprintf(filePointer,'CORE_COUNT=%d\n',nCpusTotal) ;
  fprintf(filePointer,'TASK_COUNT=%d\n',nTargetsInJob) ;
  
  fprintf(filePointer,'\n') ;
  
% write the command string which generates the tasks

  fprintf(filePointer, ...
      'seq 0 $((CORE_COUNT-1)) | parallel -j %d --sshloginfile $PBS_NODEFILE ',nCpus) ;
  fprintf(filePointer,'"$TPS_EXE_HOME/run_bootstrap_monte_carlo_on_nas.sh /nasa/mw/2010b $TPS_TASK_HOME/%s '...
      ,fullfile(dirName,jobDirName)) ;
  fprintf(filePointer,'$TASK_COUNT $CORE_COUNT {} 0 > $TPS_TASK_HOME/%s/logfiles/logfile-%s-{}.txt 2>&1" \n',...
      dirName,jobString) ;
  
  fclose( filePointer ) ;
  
return

%=========================================================================================



%=========================================================================================

% subfunction which generates a PBS file for performing task-level aggregation

function write_aggregator_pbs_script( dirName, nBatchJobs )

% open the file for writing

  filePointer = fopen(fullfile(dirName,'bootstrap-aggregator.pbs'),'w') ;
  fprintf(filePointer,'#!/bin/bash\n') ;
  fprintf(filePointer,'#\n') ;
  fprintf(filePointer,'#PBS -W group_list=s1089\n\n') ;
  fprintf(filePointer,'#PBS -j oe\n\n') ;
  fprintf(filePointer,'#PBS -m n\n') ;
  fprintf(filePointer,'#PBS -r n\n\n') ;
  fprintf(filePointer,'#PBS -l select=2:model=wes\n') ;
  fprintf(filePointer,'#PBS -q devel\n') ;
  fprintf(filePointer,'#PBS -l walltime=01:00:00\n\n') ;
  fprintf(filePointer,'TASK_COUNT=%d\n\n',nBatchJobs) ;
  fprintf(filePointer,'seq 1 $((TASK_COUNT)) | parallel -j 12 ') ;
  fprintf(filePointer,'--sshloginfile $PBS_NODEFILE ') ;
  fprintf(filePointer,'"$NAS_BS_ROOT/run_aggregate_bootstrap_files_on_nas.sh ') ;
  fprintf(filePointer,'/nasa/mw/2010b $TPS_TASK_HOME/%s {} ',dirName) ;
  fprintf(filePointer,'> $TPS_TASK_HOME/%s/logfiles/aggregator-log-{}.txt 2>&1"\n',dirName) ;
  
  fclose(filePointer) ;
  
return