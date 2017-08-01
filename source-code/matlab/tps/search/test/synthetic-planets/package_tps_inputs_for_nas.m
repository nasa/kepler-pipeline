function package_tps_inputs_for_nas( tpsInputStruct, nasDefinitionFile, ...
    nCpusMax, nBatchJobsMax, architectureString )
%
% package_tps_inputs_for_nas -- take a TPS input struct with multiple target stars and
% repackage for NAS use
%
% package_tps_inputs_for_nas( tpsInputStruct ) takes a tpsInputStruct which
%    contains multiple targets in its tpsTargets struct, and reformats the inputs as
%    follows:
%
% ==> a top-level directory, tps-matlab-yyyyddd, is constructed, where yyyy is the 4 digit
%     year and ddd is the 3 digit day of the year (001 to 365)
% ==> a mat-file, synthetic-planet-ground-truth, is saved into the top-level directory
% ==> a logfiles directory is created in the top-level directory, which will be used to
%     store the text outputs from each TPS task, one file per task
% ==> a set of sub-directories, tps-matlab-yyyyddd-nnn, is created under the top-level
%     directory
% ==> a set of st-# directories is constructed below each tps-matlab-yyyyddd-nnn
%     directory
% ==> A full TPS input is saved into each of the st-# directories, containing a single
%     tpsTargets struct in each resulting TPS input.
%
% In addition to the actions described above, package_tps_inputs_for_nas will generate a
% PBS file in each tps-matlab-yyyyddd-nnn directory, plus a master shell script in the
% tps-matlab-yyyyddd directory which will submit all of the PBS files into the NAS queue
% system.  Finally, in the tps-matlab-yyyyddd directory, a tps-aggregator.pbs file is
% generated, which allows the Pleiades devel queue to perform the task-level DAWG
% aggregation.
%
% Function package_tps_inputs_for_nas also takes the following optional inputs:
%
% ==> nasDefinitionFile:  location of the file which defines common parameter definitions
%     for the full and development scripts.  If omitted, the default is
%     nas-definitions.pbs, which is in the SVN repository directory which contains
%     package_tps_inputs_for_nas.
% ==> nCpusMax:  Maximum number of cores per node which are to be used.  If omitted, the
%     default is the # of cores per node for the selected architecture (see below)
% ==> nBatchJobsMax:  maximum number of separate batch jobs which will be used to perform
%     the TPS run, which determines the number of tps-matlab-yyyyddd-nnn directories which
%     are produced.  The actual number of batch jobs will depend on the number of TPS
%     targets and the number of CPUs per node.  If unspecified, nBatchJobsMax defaults to
%     100.
% ==> architectureString:  determines whether NAS will be asked to provide nodes of the
%     Sandy Bridge ('san'), Westmere ('wes'), Nehalem ('neh'), or Harpertown ('har')
%     architecture.  Roughly speaking, Sandy Bridge are the fastest, Westmere are the most
%     numerous, Nehalem have the most memory per CPU, and Harpertown are a somewhat
%     obsolete architecture.  Default is Sandy Bridge.
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

% define the top-level directory name

  currentTime = datestr(now,30) ; 
  currentYear = currentTime(1:4) ;
  dayOfYear   = num2str(floor(datestr2doy(now)),'%03d') ;
  dirName = ['tps-matlab-',currentYear,dayOfYear] ;
  if ~exist(dirName,'dir')
      mkdir(dirName) ;
  end
  logDirName = fullfile(dirName,'logfiles') ;
  if ~exist(logDirName,'dir')
      mkdir(logDirName) ;
  end
  
% move the inputs struct to a safe place

  originalTpsInputStruct = tpsInputStruct ;
  
% if there is not a wall-time limit set in the struct, set it now to a default value of 14
% hours

  if ~isfield(originalTpsInputStruct,'taskTimeoutSecs')
      originalTpsInputStruct.taskTimeoutSecs = 14 * get_unit_conversion('hour2sec') ;
  end
  
  nTargets = length(originalTpsInputStruct.tpsTargets) ;
  syntheticPlanetGroundTruth = [] ;

% handle default assignments if need be

  if (exist('nNodesMax','var') && ~isempty(nNodesMax)) && ...
     (exist('nTasksPerCpuMax','var') && ~isempty(nTasksPerCpuMax))
      error('tps:syntheticPlanets:nodeCountAndTaskCountSpecified', ...
          'nNodesMax and nTasksPerCpuMax cannot be specified simultaneously') ;
  end
 
  socCodeRoot = get_socCodeRoot ;
  if ~exist('nasDefinitionFile','var') || isempty( nasDefinitionFile )
      nasDefinitionFile = fullfile(socCodeRoot, 'matlab', 'tps', 'search', ...
          'test', 'synthetic-planets','nas-definitions.pbs') ;
  end
  if ~exist('architectureString', 'var') || isempty(architectureString)
      architectureString = 'san' ;
      disp('Architecture set to Sandy Bridge') ;
  end  
  archLookup = ismember({'san','wes','neh','har'},architectureString) ;
  if ~any(archLookup)
      error('tps:syntheticPlanets:architectureUnknown', ...
          'Specified NAS architecture unknown' ) ;
  end
  maxCpusPerArch = [16, 12, 8, 8] ;
  maxCpusThisArch=maxCpusPerArch(archLookup) ;
  if ~exist('nCpusMax','var') || isempty( nCpusMax ) 
      nCpusMax = maxCpusThisArch ;
      disp(['CPUs per node set to ',num2str(nCpusMax)]) ;
  end
  if ~exist('nBatchJobsMax','var') || isempty(nBatchJobsMax)
      nBatchJobsMax = 100 ;
  end
  
% the actual number of batch jobs, and the number of nodes per job, has to be determined

  nodesPerJob = ceil(nTargets/(nBatchJobsMax * nCpusMax)) ;
  nBatchJobs  = ceil(nTargets/(nCpusMax*nodesPerJob)) ;
  disp(['Total of ',num2str(nBatchJobs),' jobs utilizing ',num2str(nodesPerJob), ...
      ' nodes per job and ',num2str(nCpusMax),' cores per node']) ;
  nDigits = max( 1, ceil(log10(nBatchJobs)) ) ;
  digitString = ['%0',num2str(nDigits),'d'] ;
  nTargetsPerJobMax = nCpusMax * nodesPerJob ;
  
% determine the targets which go into each job

  targetList = zeros(1,nTargetsPerJobMax*nBatchJobs) ;
  targetList(1:nTargets) = (1:nTargets) ;
  targetMap = reshape(targetList,nTargetsPerJobMax,nBatchJobs) ;
  
% open a master shell script

  masterPointer = fopen(fullfile(dirName,[dirName,'.sh']),'w') ; 
  fprintf(masterPointer,'#!/bin/bash\n') ;
  fprintf(masterPointer,'\n') ;
      
% loop over the individual batch jobs  

  for iJob = 1:nBatchJobs
      
      jobString = num2str(iJob-1,digitString) ;
      jobDirName = [dirName,'-',jobString] ;
      if ~exist(fullfile(dirName,jobDirName),'dir')
          mkdir(fullfile(dirName,jobDirName)) ;
      end
      
      targetsInJob = targetMap(:,iJob) ;
      targetsInJob(targetsInJob<1) = [] ;
      nTargetsInJob = length(targetsInJob) ;
      nNodesThisJob = ceil(nTargetsInJob / nCpusMax) ;
      
%     build the script for this job

      build_pbs_script( dirName, jobDirName, jobString, nasDefinitionFile, ...
          architectureString, nCpusMax, nNodesThisJob, nTargetsInJob, ...
          originalTpsInputStruct.taskTimeoutSecs ) ;
      
%     add to the master script

      fprintf(masterPointer,'qsub -V -o %s/output.txt %s\n',...
          ['$TPS_TASK_HOME/',dirName,'/',jobDirName], ...
          fullfile(jobDirName,[jobDirName,'.pbs'])) ;
      
%     loop over targets in this job
  
      for iTarget = 1:nTargetsInJob
      
          iDir = iTarget - 1 ;
          subDirName = ['st-',num2str(iDir)] ;
          fullDirName = fullfile(dirName,jobDirName,subDirName) ;
          if ~exist(fullDirName,'dir')
              mkdir(fullDirName) ;
          end
          inputsStruct = originalTpsInputStruct ;
          inputsStruct.tpsTargets = originalTpsInputStruct.tpsTargets(targetsInJob(iTarget)) ;
          keplerId = inputsStruct.tpsTargets.keplerId ;

          if isfield(inputsStruct.tpsTargets.diagnostics, 'addedPlanetStruct')
              thisPlanetInfoStruct = inputsStruct.tpsTargets.diagnostics.addedPlanetStruct ;
              thisPlanetInfoStruct.keplerId = keplerId ;
              syntheticPlanetGroundTruth = [syntheticPlanetGroundTruth ; thisPlanetInfoStruct] ;
          end

          save( fullfile(fullDirName,'tps-inputs-0.mat'),'inputsStruct' ) ;

      end

  end
  
  fclose(masterPointer) ;
  
  if ~isempty(syntheticPlanetGroundTruth)
      save( fullfile(dirName,'synthetic-planet-ground-truth.mat'), ...
           'syntheticPlanetGroundTruth' ) ;
  end
  
% write the script for the aggregation process

  write_aggregator_pbs_script( dirName, nBatchJobs ) ;
  

return

%========================================================================================

% subfunction which performs construction of the PBS script files

function build_pbs_script( dirName, jobDirName, jobDirString, nasDefinitionFile, ...
          architectureString, nCpusMax, nNodesThisJob, nTargetsInJob, ...
          taskTimeoutSecs ) 

% start by copying the definition file into the script file

  scriptName = fullfile(dirName, jobDirName, [jobDirName,'.pbs']) ;
  filePointer = copy_definition_file_to_script( scriptName, nasDefinitionFile ) ;
    
% write the resources which are to be used

  if nTargetsInJob < nCpusMax
      nCpusMax = nTargetsInJob ;
      nNodesThisJob = 1 ;
  end
  
  fprintf(filePointer,'#PBS -l select=%d:',nNodesThisJob) ;
%  fprintf(filePointer,'ncpus=%d:', nCpusMax) ;
  fprintf(filePointer,'model=%s\n',architectureString) ;
  nCpusTotal = min(nNodesThisJob * nCpusMax, nTargetsInJob) ;
    
% write the queue

  fprintf(filePointer,'#PBS -q kepler\n') ;
  
% set the wall time

  wallTimeString = get_wall_time_string( taskTimeoutSecs ) ;
  fprintf(filePointer, '#PBS -l walltime=%s\n',wallTimeString) ;
  
  fprintf(filePointer,'\n') ;
  
% set the node and task counts

  fprintf(filePointer,'CORE_COUNT=%d\n',nCpusTotal) ;
  fprintf(filePointer,'TASK_COUNT=%d\n',nTargetsInJob) ;
  
  fprintf(filePointer,'\n') ;
  
% write the command string which generates the tasks

  fprintf(filePointer, ...
      'seq 0 $((CORE_COUNT-1)) | parallel -j %d --sshloginfile $PBS_NODEFILE ',nCpusMax) ;
  fprintf(filePointer,'"$TPS_EXE_HOME/run_tps_on_nas.sh /nasa/mw/2010b $TPS_TASK_HOME/%s '...
      ,fullfile(dirName,jobDirName)) ;
  fprintf(filePointer,'$TASK_COUNT $CORE_COUNT {} > $TPS_TASK_HOME/%s/logfiles/logfile-%s-{}.txt" \n',...
      dirName,jobDirString) ;
  
  fclose( filePointer ) ;
  
return

%========================================================================================

% subfunction to copy the definition file to the script files, and in the process get a
% file pointer for the script file

function filePointer = copy_definition_file_to_script( scriptName, nasDefinitionFile )

  system(['cp ',nasDefinitionFile, ' ', scriptName]) ;
  filePointer = fopen(scriptName,'a') ;
  
return

%========================================================================================

% subfunction to convert the wall time, in seconds and double precision, to a wall time
% string of format HH:MM:SS.

function wallTimeString = get_wall_time_string( wallTimeSecs )

% get the hours

  hours = floor( wallTimeSecs / 3600 ) ;
  wallTimeSecs = wallTimeSecs - hours * 3600 ;
  
% get the minutes

  minutes = floor( wallTimeSecs / 60 ) ;
  wallTimeSecs = wallTimeSecs - minutes * 60 ;
  
% get the seconds

  seconds = round( wallTimeSecs ) ;
  
% build the string

  wallTimeString = [num2str(hours),':',num2str(minutes,'%02d'),...
      ':',num2str(seconds,'%02d')] ;
  
return

%=========================================================================================

% subfunction which generates a PBS file for performing task-level aggregation

function write_aggregator_pbs_script( dirName, nBatchJobs )

% open the file for writing

  filePointer = fopen(fullfile(dirName,'tps-aggregator.pbs'),'w') ;
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
  fprintf(filePointer,'"$NAS_CODE_ROOT/run_aggregate_dawg_files_on_nas.sh ') ;
  fprintf(filePointer,'/nasa/mw/2010b $TPS_TASK_HOME/%s {} ',dirName) ;
  fprintf(filePointer,'$TPS_TASK_HOME/%s/logfiles/aggregator-log-{}.txt"\n',dirName) ;
  
  fclose(filePointer) ;
  
return
 
  
  
  

