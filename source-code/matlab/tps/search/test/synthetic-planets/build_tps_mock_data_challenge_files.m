function build_tps_mock_data_challenge_files( tpsDawgStruct, keplerIdList, ...
    kicStarParameters, syntheticPlanetParameterStruct, nBatchJobs, archString, ...
    tpsInputStructTemplate, restartTask, restartSubTask )
% 
% build_tps_mock_data_challenge_files -- construct a directory tree containing the
% appropriate files for running a planet detection monte carlo on Pleiades
%
% build_tps_mock_data_challenge_files( tpsDawgStruct, keplerIdList, kicStarParameters,
%    syntheticPlanetParameterStruct, nBatchJobs, archString, tpsInputStructTemplate )
%    takes the following inputs:
%
%    tpsDawgStruct:  usual struct for mapping Kepler IDs to task directories
%
%    keplerIdList:   list of Kepler IDs to be used in the challenge
%
%    kicStarParameters:  struct array, 1 struct per star, with the following fields:
%        keplerId
%        starRadiusSolarRadii
%        log10SurfaceGravity
%        log10Metallicity
%        effectiveTemp
%
%    syntheticPlanetParameterStruct:  struct array with the following fields:
%        planetRadiusRangeEarthRadii [2 x 1 vector]
%        periodRangeDays             [2 x 1 vector]
%        epochFlexibilityDays        [scalar]
%        relativeWeight              [scalar]
%
%    nBatchJobs:  approximate # of jobs which should be used (since the jobs will be
%        quantized by the # of CPUs per node, amongst other things, this value can only be
%        approximate)
%
%    archString:  determines whether NAS will be asked to provide nodes of the
%        Sandy Bridge ('san'), Westmere ('wes'), Nehalem ('neh'), or Harpertown ('har')
%        architecture
%
%    tpsInputStructTemplate:  TPS struct which will be used as a template for all
%        sub-structures in the TPS inputs except for the tpsTargets (optional).
%
% Given all of this, the function will build a directory tree consisting of:
%
%    tps-matlab-yyyydoy (top directory), containing
%        tps-matlab-yyyydoy.sh, shell script for submitting batch jobs
%        logfiles, logfile outputs from TPS run
%        tps-matlab-yyyydoy-nnn (1 or more subdirectories), each containing
%            tps-matlab-yyyydoy-nn.pbs, batch file for this directory
%            st-nnn (1 or more subdirectories), each containing
%                tps-inputs-0.mat, TPS input struct for 1 target star
%        tps-aggregator.pbs, a script which permits execution of the within-task
%            aggregator on the Pleiades devel queue.
%
% Each TPS input struct will contain a transitModel struct as a sub-struct of its
%    tpsTargets.diagnostics struct, which will be populated with the parameters for the
%    star and one (1) synthetic transiting planet, where the planet is randomly generated
%    based on the parameters and weights in the syntheticPlanetParameterStruct.
%
% If the script fails in mid-process, it can be restarted by specifying a restartTask
%    (1:nTasks) and a restartSubTask (1:nSubTasks).
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

% PRELIMINARIES:
%
% determine the # of CPUs per node via a lookup

  if ~exist('archString','var') || isempty(archString)
      archString = 'wes' ;
  end
  archLookup = ismember({'san','wes','neh','har'},archString) ;
  if ~any(archLookup)
      error('tps:syntheticPlanets:architectureUnknown', ...
          'Specified NAS architecture unknown' ) ;
  end
  maxCpusPerArch = [16, 12, 8, 8] ;
  nCpus=maxCpusPerArch(archLookup) ;

% handle non-restart case

  if ~exist('restartTask','var') || isempty(restartTask)
      restartTask = 1 ;
  end
  if ~exist('restartSubTask','var') || isempty(restartSubTask)
      restartSubTask = 1 ;
  end
  
% determine the # of nodes needed, and thus the # of targets per job, nodes per job, etc.

  nTargets = length( keplerIdList ) ;
  nodesPerJob = ceil(nTargets/(nBatchJobs * nCpus)) ;
  nBatchJobs  = ceil(nTargets/(nCpus*nodesPerJob)) ;
  disp(['Total of ',num2str(nBatchJobs),' jobs utilizing ',num2str(nodesPerJob), ...
      ' nodes per job and ',num2str(nCpus),' cores per node']) ;
  nDigits = max( 1, ceil(log10(nBatchJobs)) ) ;
  digitString = ['%0',num2str(nDigits),'d'] ;
  nTargetsPerJobMax = nCpus * nodesPerJob ;
  
% determine the targets which go into each job

  targetList = zeros(1,nTargetsPerJobMax*nBatchJobs) ;
  targetList(1:nTargets) = keplerIdList ;
  targetMap = reshape(targetList,nTargetsPerJobMax,nBatchJobs) ;
  
% if there's no template input struct, get a struct now to act as the template

  if ~exist( 'tpsInputStructTemplate', 'var' ) || isempty( tpsInputStructTemplate )
      tpsInputStructTemplate = get_tps_struct_by_kepid_from_task_dir_tree( ...
          tpsDawgStruct, keplerIdList(1), 'input', false ) ;
  end
  
% get the weighting information now

  weightVector = [syntheticPlanetParameterStruct.relativeWeight] ;
  weightSum    = cumsum(weightVector) ;
  totalWeight  = weightSum(end) ;

% get the KIC star parameters ready for use

  kicStarKeplerId = [kicStarParameters.keplerId] ;
  
% convert the wall time from seconds to HH:MM:SS

  wallTimeSecs = tpsInputStructTemplate.taskTimeoutSecs ;
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
  
% construct random number generator

  paramStruct = socRandStreamManagerClass.get_default_param_struct() ;
  randStreamManager = socRandStreamManagerClass('TPS', keplerIdList, paramStruct) ;
  
%==
%==
%==
%==
%==

% TOP-LEVEL DIRECTORY WORK

  if ~exist( dirName, 'dir' )
      mkdir(dirName) ;
  end
  logDirName = fullfile(dirName,'logfiles') ;
  if ~exist(logDirName,'dir')
      mkdir(logDirName) ;
  end

% open a master shell script

  if restartTask == 1 && restartSubTask == 1
      masterPointer = fopen(fullfile(dirName,[dirName,'.sh']),'w') ; 
      fprintf(masterPointer,'#!/bin/bash\n') ;
      fprintf(masterPointer,'\n') ;
  else
      fclose('all') ;
      masterPointer = fopen(fullfile(dirName,[dirName,'.sh']),'a') ;
  end
      
%==
%==
%==
%==
%==

% TASK DIRECTORY WORK

  for iJob = restartTask:nBatchJobs
      
      if iJob > restartTask
          restartSubTask = 1 ;
      end
      
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
      nNodesThisJob = ceil(nTargetsInJob / nCpus) ;
      
%     build the script for this job

      build_pbs_script( dirName, jobDirName, jobString, ...
          archString, nCpus, nNodesThisJob, nTargetsInJob, ...
          wallTimeString ) ;
      
%     add to the master script

      if restartSubTask == 1
          fprintf(masterPointer,'qsub -V -o %s/output.txt %s\n',...
              ['$TPS_TASK_HOME/',dirName,'/',jobDirName], ...
              fullfile(jobDirName,[jobDirName,'.pbs'])) ;
      end
      
%==
%==
%==
%==
%==

% SUB-TASK DIRECTORY WORK

      for iTarget = restartSubTask:nTargetsInJob
      
          iDir = iTarget - 1 ;
          subDirName = ['st-',num2str(iDir)] ;
          fullDirName = fullfile(dirName,jobDirName,subDirName) ;
          if ~exist(fullDirName,'dir')
              mkdir(fullDirName) ;
          end

%         get the task file for this target

          keplerId = targetMap(iTarget,iJob) ;
          randStreamManager.set_default( keplerId ) ;
          taskFile = get_tps_struct_by_kepid_from_task_dir_tree( tpsDawgStruct, ...
              keplerId, 'input', false ) ;
          inputsStruct = tpsInputStructTemplate ;
          inputsStruct.tpsTargets = taskFile.tpsTargets ;
          clear taskFile ;
          
%         select a class of planets to add to this target

          randomNumber = totalWeight * rand(1) ;
          planetClassNumber = find(randomNumber < weightSum, 1, 'last') ;
          stellarParsNumber = ismember(kicStarKeplerId, keplerId) ;
          
          inputsStruct = add_planet_information( inputsStruct, ...
              kicStarParameters(stellarParsNumber), ...
              syntheticPlanetParameterStruct(planetClassNumber) ) ;

          save( fullfile(fullDirName,'tps-inputs-0.mat'),'inputsStruct' ) ;
          
      end
      
% END SUB-TASK DIRECTORY WORK

%==
%==
%==
%==
%==

%�    pause for 1 second to allow garbage collection to execute

      pause(1) ;

  end
  
% END TASK DIRECTORY WORK

%==
%==
%==
%==
%==

  fclose(masterPointer) ;
  
% write the aggregator PBS script

  write_aggregator_pbs_script( dirName, nBatchJobs ) ;
  
% END TOP-LEVEL DIRECTORY WORK

%==
%==
%==
%==
%==

  randStreamManager.restore_default ;


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
  fprintf(filePointer,'"$TPS_EXE_HOME/run_tps_on_nas.sh /nasa/mw/2010b $TPS_TASK_HOME/%s '...
      ,fullfile(dirName,jobDirName)) ;
  fprintf(filePointer,'$TASK_COUNT $CORE_COUNT {} 0 > $TPS_TASK_HOME/%s/logfiles/logfile-%s-{}.txt 2>&1" \n',...
      dirName,jobString) ;
  
  fclose( filePointer ) ;
  
return

%=========================================================================================

% function which puts the synthetic planet parameters into the TPS diagnostics

function inputsStruct = add_planet_information( inputsStruct, ...
              kicStarParameters, ...
              syntheticPlanetParameterStruct )
          

% construct the timing information struct

  timeParametersStruct.exposureTimeSec        = 6.0198029032704 ;
  timeParametersStruct.readoutTimeSec         = 0.518948526144 ;
  timeParametersStruct.numExposuresPerCadence = 270 ;

% construct the model name struct

  modelNamesStruct.transitModelName       = 'mandel-agol_geometric_transit_model' ;
  modelNamesStruct.limbDarkeningModelName = 'kepler_nonlinear_limb_darkening_model' ;
  
% generate the planet size, orbital period, and epoch  

  planetRadiusEarthRadii = syntheticPlanetParameterStruct.planetRadiusRangeEarthRadii(1) + ...
      rand(1) * range(syntheticPlanetParameterStruct.planetRadiusRangeEarthRadii) ;
  orbitalPeriodDays = syntheticPlanetParameterStruct.periodRangeDays(1) + ...
      rand(1) * range(syntheticPlanetParameterStruct.periodRangeDays) ;
  epochKjd = inputsStruct.cadenceTimes.midTimestamps(1) - kjd_offset_from_mjd + ...
      rand(1) * orbitalPeriodDays ;
  starRadiusMks = kicStarParameters.starRadiusSolarRadii * ...
      get_unit_conversion('solarRadius2mks') ;
  orbitalPeriodMks = orbitalPeriodDays * get_unit_conversion('day2sec') ;
  gMks = 10^(kicStarParameters.log10SurfaceGravity) * get_unit_conversion('cm2meter') ;


% construct the planet model

  planetModel.transitEpochBkjd       = epochKjd ;
  planetModel.eccentricity           = 0 ;
  planetModel.longitudeOfPeriDegrees = 0 ;
  planetModel.minImpactParameter     = 0 ;
  planetModel.starRadiusSolarRadii   = kicStarParameters.starRadiusSolarRadii ;
  planetModel.orbitalPeriodDays      = orbitalPeriodDays ;
  planetModel.ratioPlanetRadiusToStarRadius = planetRadiusEarthRadii * ...
      get_unit_conversion('earthRadius2mks') / starRadiusMks ;
      
  
% the ratio of semi-major axis to star radius requires a calculation using Kepler's 3rd law

  semiMajorAxisMks = (orbitalPeriodMks * starRadiusMks * sqrt(gMks) / 2 / pi)^(2/3) ;
  planetModel.ratioSemiMajorAxisToStarRadius = semiMajorAxisMks / starRadiusMks ;
  
% now we are ready to build the transitModelStruct, except for the cadenceTimes vector,
% which will be added in execution in order to save that highly-repetitive vector from
% being made a part of the data structs over and over again

  transitModelStruct.cadenceTimes              = [] ;
  transitModelStruct.log10SurfaceGravity.value = kicStarParameters.log10SurfaceGravity ;
  transitModelStruct.effectiveTemp.value       = kicStarParameters.effectiveTemp ;
  transitModelStruct.log10Metallicity.value    = kicStarParameters.log10Metallicity ;
  transitModelStruct.radius.value              = kicStarParameters.starRadiusSolarRadii ;
  transitModelStruct.debugFlag                 = false ;
  transitModelStruct.modelNamesStruct          = modelNamesStruct ;
  transitModelStruct.transitBufferCadences     = 1 ;
  transitModelStruct.transitSamplesPerCadence  = 21 ;
  transitModelStruct.timeParametersStruct      = timeParametersStruct ;
  transitModelStruct.planetModel               = planetModel ;
  
  transitModelStruct.log10SurfaceGravity.uncertainty = 0 ;
  transitModelStruct.effectiveTemp.uncertainty       = 0 ;
  transitModelStruct.log10Metallicity.uncertainty    = 0 ;
  transitModelStruct.radius.uncertainty              = 0 ;

% incorporate necessary information into the tps input struct

  addedPlanetStruct.transitModelStruct   = transitModelStruct ;
  addedPlanetStruct.epochFlexibilityDays = ...
      syntheticPlanetParameterStruct.epochFlexibilityDays ;
  inputsStruct.tpsTargets.diagnostics.addedPlanetStruct = addedPlanetStruct ;
  
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
  fprintf(filePointer,'> $TPS_TASK_HOME/%s/logfiles/aggregator-log-{}.txt 2>&1"\n',dirName) ;
  
  fclose(filePointer) ;
  
return