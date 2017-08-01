function generate_tps_inputs_for_transit_injection( ...
    keplerIdList, tpsTceStruct, tpsInputStructTemplate, ...
    dvRunDir, dvKepIdToTaskFilename, nBatchJobs, archString, ...
    stellarParameters, wallTimeSecs, nDuplicatesPerTarget)
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
%    tpsTceStruct: A TPS TCE struct from a previous TPS run that contains
%                  all the targets in the keplerIdList and a valid topDir
%                  that points to the run task files
%    tpsInputStructTemplate:  a dummy tps Input struct with module
%                  parameters that will be used for all generated inputs
%    dvRunDir:     run directory from a prior DV run.  For targets that
%                  produced TCEs in the tpsTceStruct, the DV post fit flux
%                  will be pulled from here
%    dvKepIdToTaskFilename:  The text file generated for each DV that
%                  contains the path to the task file for each keplerId
%    nBatchJobs:   The number of PBS jobs to shoot for.  The actual number
%                  may vary a little.
%    archString:   The architecture abbreviation for the cluster at the NAS
%                  to run the jobs on.
%    stellarParameters:  struct containing keplerIds and the stellar
%                  parameters of effectiveTemp, radius, 
%                  log10SurfactGravity, and log10Metallicity
%    wallTimeSecs: The wall time for each PBS job
%    nDuplicatesPerTarget: The number of duplicates to make of each target.
%                  A different random number seed will be added to the
%                  target struct for each target.  This helps when running
%                  a lot of injections over a small set of targets.  Set to
%                  0 for just one copy of each target.
%
% Outputs: The result is a directory structure with task directories that
%          include subtask directories.  A tpsInputStruct will be placed in
%          each subtask directory.  This structure is created in place.
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

% make sure kepIds are double

  keplerIdList = keplerIdList(:);
  keplerIdList = double( keplerIdList );

% check stellar parameters if they are an input

  if exist('stellarParameters','var') && ~isempty(stellarParameters)
      tempParamStruct = stellarParameters(1);
      % check for kepids
      if ~isfield( tempParamStruct, 'keplerId' )
          error('tps:transitInjection:stellarParameters', ...
              'keplerId is missing!');
      end
           
      % check for radius
      if ~isfield( tempParamStruct, 'radius' )
          error('tps:transitInjection:stellarParameters', ...
              'Stellar radius is missing!');
      end
      
      % check for log g
      if ~isfield( tempParamStruct, 'log10SurfaceGravity' )
          error('tps:transitInjection:stellarParameters', ...
              'Log g is missing!');
      end
      
      % check for log metallicity
      if ~isfield( tempParamStruct, 'log10Metallicity' )
          error('tps:transitInjection:stellarParameters', ...
              'Log metallicity is missing!');
      end
      
      % check for effective temp
      if ~isfield( tempParamStruct, 'effectiveTemp' )
          error('tps:transitInjection:stellarParameters', ...
              'Effective temp is missing!');
      end
      
      stellarParamIds = [stellarParameters.keplerId];
      stellarParamIds = stellarParamIds(:);
      
      % check kepids ordering
      if ~isequal(stellarParamIds, keplerIdList)
          error('tps:transitInjection:stellarParameters', ...
              'The input stellarParameters kepids dont match the keplerIdList');
      end    
  end
  
% take care of duplicates
  nDuplicatesPerTarget = nDuplicatesPerTarget + 1;
  keplerIdList = repmat(keplerIdList,1,nDuplicatesPerTarget);
  keplerIdList = keplerIdList';
  keplerIdList = keplerIdList(:);  
  
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
  
% determine the # of nodes needed, and thus the # of targets per job, nodes per job, etc.

  nTargets = length( keplerIdList ) ;
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
  
% if there's no template input struct, get a struct now to act as the template

  if isempty( tpsInputStructTemplate )
      tpsInputStructTemplate = get_tps_struct_by_kepid_from_task_dir_tree( ...
          tpsTceStruct, keplerIdList(1), 'input', false ) ;
  end
  
% get the stellar parameters to add to the target struct
  if ~exist('stellarParameters','var') || isempty(stellarParameters)
      stellarParameters = retrieve_kics_by_kepler_id_matlabstyle( double(keplerIdList) );
      stellarParameters = stellarParameters(:);
  end
    
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

  keplerIdPrev = 0;
  randSeedOffset = 0;
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

%     explicitly disable quarter stitching

      tpsInputStructTemplate.tpsModuleParameters.performQuarterStitching = false;
      
% SUB-TASK DIRECTORY WORK

      for iTarget = 1:nTargetsInJob
      
          iDir = iTarget - 1 ;
          subDirName = ['st-',num2str(iDir)] ;
          fullDirName = fullfile(dirName,jobDirName,subDirName) ;
          if ~exist(fullDirName,'dir')
              mkdir(fullDirName) ;
          end

%         get the appropriate flux for this target

          keplerId = targetsInJob(iTarget) ;
          
%         check to see if this is a duplicate, assign appropriate seed               
          
          if ~isequal(keplerId, keplerIdPrev)
              keplerIdPrev = keplerId;
              randSeedOffset = 0;
              inputsStruct = tpsInputStructTemplate ;
              
              taskFile = get_tps_struct_by_kepid_from_task_dir_tree( tpsTceStruct, ...
                  keplerId, 'input', false ) ;
          
              inputsStruct.tpsTargets = taskFile.tpsTargets ;
              inputsStruct.tpsTargets.quarterGapIndicators = false ;

    %         add in the stellar parameters

              inputsStruct.tpsTargets.radius = stellarParameters.radius(ismember([stellarParameters.keplerId],keplerId));
              inputsStruct.tpsTargets.log10SurfaceGravity = stellarParameters.log10SurfaceGravity(ismember([stellarParameters.keplerId],keplerId));
              inputsStruct.tpsTargets.log10Metallicity = stellarParameters.log10Metallicity(ismember([stellarParameters.keplerId],keplerId));
              inputsStruct.tpsTargets.effectiveTemp = stellarParameters.effectiveTemp(ismember([stellarParameters.keplerId],keplerId));

    %         add the robust rms cdpp

              taskFile = get_tps_struct_by_kepid_from_task_dir_tree( tpsTceStruct, ...
                  keplerId, 'diagnostic', false ) ;

              nPulses = length(taskFile);
              rmsCdpp = -1 * ones( nPulses,1 );
              cdppInd = taskFile(1).deemphasisWeights > 0.5;
              for iPulse = 1:nPulses
                  cdppTimeSeries = 1e6./taskFile(iPulse).normalizationTimeSeries(cdppInd);
                  rmsCdpp(iPulse) = sqrt( median(cdppTimeSeries)^2 + (1.4826 * mad(cdppTimeSeries,1))^2 );
              end
              inputsStruct.tpsTargets.rmsCdpp = rmsCdpp;

              if (tpsTceStruct.isPlanetACandidate(tpsTceStruct.keplerId == keplerId) == false)
                  inputsStruct.tpsTargets.fluxValue = double(taskFile(1).detrendedFluxTimeSeries);

                  % get the detrended flux for diagnostic collection
                  inputsStruct.tpsTargets.tpsDetrendedFlux = double(taskFile(1).detrendedFluxTimeSeries);
              else

                  % get the detrended flux for diagnostic collection
                  inputsStruct.tpsTargets.tpsDetrendedFlux = double(taskFile(1).detrendedFluxTimeSeries);
                  inputsStruct.tpsTargets.tpsGapIndices = inputsStruct.tpsTargets.gapIndices;
                  inputsStruct.tpsTargets.tpsFillIndices = inputsStruct.tpsTargets.fillIndices;

                  dvFile = fullfile(dvRunDir,dvKepIdToTaskFilename);
                  unixCommand = ['grep ', num2str(keplerId),' ', dvFile];
                  [flag, result] = unix(unixCommand);
                  parsedResult = strread(result, '%s');
                  postFitAvailable = str2num(parsedResult{4}) == 1;

                  if postFitAvailable
                      dvFile = fullfile( parsedResult{2}, 'dv_post_fit_workspace.mat' );
                      load(dvFile);

                      inputsStruct.tpsTargets.fluxValue            = dvResultsStruct.targetResultsStruct.residualFluxTimeSeries.values;
                      inputsStruct.tpsTargets.gapIndices           = find(dvResultsStruct.targetResultsStruct.residualFluxTimeSeries.gapIndicators) - 1;     % 0-based
                      inputsStruct.tpsTargets.fillIndices          = dvResultsStruct.targetResultsStruct.residualFluxTimeSeries.filledIndices       - 1;     % 0-based

                      clear dvDataObject dvResultsStruct usedDefaultValuesStruct;
                  else
                      % dv task must have failed before post fit workspace
                      % was saved  - build a special input that will just mark
                      % the case so we dont do injections for this one
                      inputsStruct.tpsTargets.fluxValue = -1 ;
                  end

              end
          else
              randSeedOffset = randSeedOffset + 1;
          end

          inputsStruct.tpsTargets.randSeedOffset = randSeedOffset;
          clear taskFile;
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
  fprintf(filePointer,'"$TPS_EXE_HOME/run_tps_injection_on_nas.sh /nasa/mw/2010b $TPS_TASK_HOME/%s '...
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
  fprintf(filePointer,'"$NAS_INJ_ROOT/run_aggregate_transit_injection_files_on_nas.sh ') ;
  fprintf(filePointer,'/nasa/mw/2010b $TPS_TASK_HOME/%s {} ',dirName) ;
  fprintf(filePointer,'> $TPS_TASK_HOME/%s/logfiles/aggregator-log-{}.txt 2>&1"\n',dirName) ;
  
  fclose(filePointer) ;
  
return