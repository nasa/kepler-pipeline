function rebuild_corrupt_inputs( keplerIdList, tpsTceStruct, tpsInputStructTemplate, tpsRunDir, ...
    dvRunDir, dvKepIdToTaskFilename, archString, nBatchJobs, stellarParameters, taskDir, subTaskDirs, dirName)

%rebuild_corrupt_inputs( totalKepIdsForTransitInjection, tceStruct, inputsStruct, '/path/to/mq-q1-q17/pipeline_results/tps/', ...
%    '/path/to/mq-q1-q17/pipeline_results/dv/', 'keplerId_dvTaskFilePath_table_r9p2_full_run_Q1_Q17_i9794_10012014.txt', ...
%    'wes', 100, stellarParameters, 99, 1391, 'tps-matlab-2015022')
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
  
% determine the # of CPUs per node via a lookup

  if isempty(archString)
      archString = 'wes' ;
  end
  
  archLookup = ismember({'san','wes','neh','har'},archString) ;
  if ~any(archLookup)
      error('tps:transitInjection:architectureUnknown', ...
          'Specified NAS architecture unknown' ) ;
  end
  maxCpusPerArch = [16, 12, 8, 8] ;
  nCpus=maxCpusPerArch(archLookup) ;
  
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
  
% get the date and use it to make a directory name string
  %dirName = ['tps-matlab-2015022'] ;
  
  iJob = taskDir + 1;    
  jobString = num2str(taskDir) ;
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

%     explicitly disable quarter stitching

  tpsInputStructTemplate.tpsModuleParameters.performQuarterStitching = false;

% SUB-TASK DIRECTORY WORK

  for iTarget = 1:nTargetsInJob

      iDir = iTarget - 1 ;
      
      if ismember(iDir,subTaskDirs)
      
          subDirName = ['st-',num2str(iDir)] ;
          fullDirName = fullfile(dirName,jobDirName,subDirName) ;
          if ~exist(fullDirName,'dir')
              mkdir(fullDirName) ;
          end

    %         get the appropriate flux for this target

          keplerId = targetMap(iTarget,iJob) ;
          inputsStruct = tpsInputStructTemplate ;

          taskFile = get_tps_struct_by_kepid_from_task_dir_tree( tpsTceStruct, ...
              keplerId, 'input', false ) ;

          inputsStruct.tpsTargets = taskFile.tpsTargets ;
          inputsStruct.tpsTargets.quarterGapIndicators = false ;

    %         add in the stellar parameters

          inputsStruct.tpsTargets.radius = stellarParameters.radius(iTarget);
          inputsStruct.tpsTargets.log10SurfaceGravity = stellarParameters.log10SurfaceGravity(iTarget);
          inputsStruct.tpsTargets.log10Metallicity = stellarParameters.log10Metallicity(iTarget);
          inputsStruct.tpsTargets.effectiveTemp = stellarParameters.effectiveTemp(iTarget);

          clear taskFile ;

          if (tpsTceStruct.isPlanetACandidate(tpsTceStruct.keplerId == keplerId) == false)
              tpsDiagnosticStruct = get_tps_struct_by_kepid_from_task_dir_tree( ...
                  tpsTceStruct, keplerId, 'diagnostic', false );
              inputsStruct.tpsTargets.fluxValue = double(tpsDiagnosticStruct(1).detrendedFluxTimeSeries);

              % get the detrended flux for diagnostic collection
              inputsStruct.tpsTargets.tpsDetrendedFlux = double(tpsDiagnosticStruct(1).detrendedFluxTimeSeries);
          else

              % get the detrended flux for diagnostic collection
              tpsDiagnosticStruct = get_tps_struct_by_kepid_from_task_dir_tree( ...
                  tpsTceStruct, keplerId, 'diagnostic', false );
              inputsStruct.tpsTargets.tpsDetrendedFlux = double(tpsDiagnosticStruct(1).detrendedFluxTimeSeries);
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

          save( fullfile(fullDirName,'tps-inputs-0.mat'),'inputsStruct' ) ;
          pause(1) ;
      end
  end
      


  
  return
  
  %=========================================================================================

