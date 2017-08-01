function run_tps_on_nas( topDir, nTasks, nCores, coreIndex, saveOutputs )
%
% run_tps_on_nas -- top-level function for running TPS on multiple NAS cores
%
% run_tps_on_nas( topDir, nTasks, nCores, coreIndex ) is the top-level function for TPS
%    execution on NAS.  The topDir is the location of the task file directories for the
%    run (typically tps-matlab-#-#); nTasks is the total number of task files which need
%    to be run (these must be under topDir in st-# directories, where # is an index from 0
%    to nTasks-1); nCores is the total number of cores in the run; coreIndex is the index
%    of the core running this function (from 0 to nCores-1).  TPS is then run on each task
%    for which the st-# directory produces the coreIndex value when the # is mod'ed with
%    nCores.  For example, when nTasks == 16, nCores == 4, and coreIndex == 2, the current
%    run will process the task files in st-2, st-6, st-10, and st-14.
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

% attempt to display the build date string

  try
      dateString = get_build_date_string ;
      disp(['MATLAB:  Build date == ',dateString]) ;
  catch
      disp('MATLAB:  Build date unavailable')
  end

% apparently, args are passed by the MATLAB runtime shell file as strings; check for that
% and correct it now

  if isa(nTasks,'char')
      nTasks = str2double(nTasks) ;
  end
  if isa(nCores,'char')
      nCores = str2double(nCores) ;
  end
  if isa(coreIndex,'char')
      coreIndex = str2double(coreIndex) ;
  end  
  if ~exist( 'saveOutputs', 'var' ) || isempty(saveOutputs)
      saveOutputs = true ;
  end
  if isa(saveOutputs,'char')
      saveOutputs = str2double(saveOutputs) ;
      saveOutputs = logical(saveOutputs) ;
  end

% prepare path variables needed herein
  initialize_soc_variables({'caller','base'});
  disp([ 'socDistRoot: ' socDistRoot ]);
  disp([ 'socDataRoot: ' socDataRoot ]);
  disp([ 'socTestDataRoot: ' socTestDataRoot ]);

% if we are not running in the MATLAB interactive environment, we need to set the java path

  if(isdeployed && ~ismcc)
    warning off backtrace;
    initialize_soc_javapath(socDistRoot);
    warning backtrace;
  end;

% get the nodename and write to the output

  [~,nodename] = system('uname -n') ;
  disp(['Running TPS on node ',nodename]) ;
  disp([]) ;

% determine the task directory numbers which are to be included in this run

  listOfTasks = 0:nTasks-1 ;
  tasksToRun = listOfTasks( mod(listOfTasks,nCores) == coreIndex ) ;
  
% get the absolute path of the topDir  

  cd(topDir) ;
  topDirAbsPath = cd ;

% loop over tasks and run them

  for iTask = tasksToRun
      
      taskSubDirName = ['st-',num2str(iTask)] ;
      cd( fullfile( topDirAbsPath, taskSubDirName ) ) ;
      load tps-inputs-0 ;
      
%     if there is a struct for generation of a synthetic planet, but that planet has not
%     been generated, generate it now

      if isfield( inputsStruct.tpsTargets.diagnostics, 'addedPlanetStruct' ) && ...
          ~isfield( inputsStruct.tpsTargets.diagnostics.addedPlanetStruct, 'lightCurve' )
          inputsStruct = instantiate_synthetic_planet( inputsStruct ) ;
          save tps-inputs-0 inputsStruct ;
      end
      
      outputsStruct = tps_matlab_controller( inputsStruct ) ;
      
%     if there was a synthetic planet in this run, put the light curve into the diagnostic
%     struct

      if isfield( inputsStruct.tpsTargets.diagnostics, 'addedPlanetStruct' )
          load tps-diagnostic-struct 
          tpsDiagnosticStruct(1).addedPlanetLightCurve = ...
              inputsStruct.tpsTargets.diagnostics.addedPlanetStruct.lightCurve ;
          save tps-diagnostic-struct tpsDiagnosticStruct ;
          load sub-task-added-planet-struct ;
          load tps-task-file-dawg-struct ;
          addedPlanetStruct.transitModelStruct.planetModel.estimatedMes = ...
              estimate_multiple_event_statistic( inputsStruct, addedPlanetStruct, ...
              tpsDiagnosticStruct, tpsDawgStruct.pulseDurations ) ;
          addedPlanetStruct.transitModelStruct.planetModel.keplerId = ...
              addedPlanetStruct.keplerId ;
          save sub-task-added-planet-struct addedPlanetStruct ;
          clear tpsDiagnosticStruct addedPlanetStruct tpsDawgStruct ;
      end
      
      if saveOutputs
          save tps-outputs-0 outputsStruct ;
      end
      clear inputsStruct outputsStruct ;
      pause(1) ;
      
  end

return

%=========================================================================================

% subfunction which completes the construction of a synthetic planet signature for a TPS
% input, if needed

function inputsStruct = instantiate_synthetic_planet( inputsStruct )

  disp('... completing construction of synthetic planet ... ')
  
  addedPlanetStruct = inputsStruct.tpsTargets.diagnostics.addedPlanetStruct ;

% make a cadence times vector for the model

  cadenceTimesBkjd = inputsStruct.cadenceTimes.midTimestamps ;
  gapIndicators    = inputsStruct.cadenceTimes.gapIndicators ;
  cadenceTimesBkjd(gapIndicators) = interp1( find(~gapIndicators), ...
      cadenceTimesBkjd(~gapIndicators), find(gapIndicators), 'linear', 'extrap' ) ;
  cadenceTimesBkjd = cadenceTimesBkjd - kjd_offset_from_mjd ;
  
  addedPlanetStruct.transitModelStruct.cadenceTimes = cadenceTimesBkjd ;
  
% construct an array which indicates which cadences are valid

  validCadences = ones( size( cadenceTimesBkjd ) ) ;
  validCadences( gapIndicators )                                             = 0 ;
  validCadences( inputsStruct.tpsTargets.gapIndices+1 )                      = 0 ;
  validCadences( inputsStruct.tpsTargets.fillIndices+1 )                     = 0 ;  
  
% build transit model

  transitObject = transitGeneratorClass(addedPlanetStruct.transitModelStruct) ;
  
% if there is epoch flexibility, do a search now to find the epoch which maximizes the
% number of in-transit cadences which are good

  epochFlexibilityDays = addedPlanetStruct.epochFlexibilityDays ;
  if epochFlexibilityDays > 0
      
%     first figure out how many cadences we expect to see with nonzero value

      planetModel          = get(transitObject,'planetModel') ;
      timeParametersStruct = get(transitObject,'timeParametersStruct') ;
      cadenceDurationHours = (timeParametersStruct.exposureTimeSec + ...
          timeParametersStruct.readoutTimeSec) * timeParametersStruct.numExposuresPerCadence ...
          * get_unit_conversion('sec2hour') ;
      cadenceDurationDays  = cadenceDurationHours * get_unit_conversion( 'hour2day' ) ;
      cadencesPerTransit   = planetModel.transitDurationHours / cadenceDurationHours ;
      numExpectedTransits  = get_number_of_transits_in_time_series( transitObject ) ;
      numExpectedCadences  = cadencesPerTransit * numExpectedTransits ;

%     figure out which cadences can be the epoch

      cadenceTimeDistanceFromEpoch = cadenceTimesBkjd - planetModel.transitEpochBkjd ;
      cadenceTimeDistanceInSteps = cadenceTimeDistanceFromEpoch / epochFlexibilityDays ;
      closestToStepBoundary = abs(cadenceTimeDistanceInSteps - ...
          floor(cadenceTimeDistanceInSteps)) < cadenceDurationDays / epochFlexibilityDays ;

      permittedEpochs = cadenceTimesBkjd( ...
          cadenceTimesBkjd - cadenceTimesBkjd(1) < planetModel.orbitalPeriodDays & ...
          closestToStepBoundary ) ;

%     sort the permitted epochs according to their distance from the user-requested epoch

      [~,sortKey] = sort( abs(permittedEpochs - planetModel.transitEpochBkjd) ) ;
      permittedEpochs = permittedEpochs(sortKey) ;
      permittedEpochs = [planetModel.transitEpochBkjd ; permittedEpochs(:)] ;

%     set up an array to track the # of cadences in transit for each epoch

      cadencesInTransit = zeros( size( permittedEpochs ) ) ;
      
%     loop over epochs and find the # of cadences in transit at that epoch

      for iEpoch = 1:length(permittedEpochs)
          
          planetModel.transitEpochBkjd = permittedEpochs( iEpoch ) ;
          transitObject = set(transitObject, 'planetModel', planetModel ) ;
          phaseShiftedLightCurve = generate_planet_model_light_curve( transitObject ) ;
          
          cadencesInTransit(iEpoch) = length( find( ...
              validCadences .* phaseShiftedLightCurve < 0 ) ) ;

%         in the unlikely event that we've found a case which has all the cadences we
%         could ever expect, we can stop searching now
          
          if cadencesInTransit(iEpoch) == numExpectedCadences
              break ;
          end
          
      end % loop over epochs
      
%     find the epoch which has the largest number of in-transit cadences and is also
%     closest in timing to the requested one

      [~,bestEpochPointer] = max(cadencesInTransit) ;
      planetModel.transitEpochBkjd = permittedEpochs( bestEpochPointer ) ;
      addedPlanetStruct.transitModelStruct.planetModel.transitEpochBkjd = ...
          planetModel.transitEpochBkjd ;
      transitObject = set( transitObject, 'planetModel', planetModel ) ;
      
  end % flexible epoch condition
  
% add the light curve from the transit object to the added planet struct

  validCadenceIndicators = validCadences > 0 ;
  addedPlanetStruct.lightCurve = generate_planet_model_light_curve( transitObject ) .* ...
      validCadenceIndicators ;
  [~,addedPlanetStruct.nTransits] = get_number_of_transits_in_time_series( transitObject, ...
      cadenceTimesBkjd, ~validCadences, [] ) ;
  inputsStruct.tpsTargets.diagnostics.addedPlanetStruct = addedPlanetStruct ;
  
% apply the flux to the data

  inputsStruct.tpsTargets.fluxValue(validCadenceIndicators) = ... 
      inputsStruct.tpsTargets.fluxValue(validCadenceIndicators) .* ...
      (1 + addedPlanetStruct.lightCurve(validCadenceIndicators) ) ;
  
% save out the added planet struct to a mat file, after making a few modifications

  addedPlanetStruct = rmfield(addedPlanetStruct, 'lightCurve') ;
  addedPlanetStruct.keplerId = inputsStruct.tpsTargets.keplerId ;
  addedPlanetStruct.transitModelStruct = rmfield(addedPlanetStruct.transitModelStruct, ...
      'cadenceTimes') ;
  addedPlanetStruct.transitModelStruct.planetModel = planetModel ;
  
  save sub-task-added-planet-struct addedPlanetStruct ;
  
return

%=========================================================================================

% subfunction which estimates the multiple event statistic for a synthetic planet

function estimatedMes = estimate_multiple_event_statistic( inputsStruct, addedPlanetStruct, ...
              tpsDiagnosticStruct, pulseDurations )
          
          
% compute the duration of a cadence in days

  timeStruct  = addedPlanetStruct.transitModelStruct.timeParametersStruct ;
  exposure    = timeStruct.exposureTimeSec + timeStruct.readoutTimeSec ;
  cadenceSec  = exposure * timeStruct.numExposuresPerCadence ;
  cadenceDays = cadenceSec * get_unit_conversion('sec2day') ;
  
% determine the epoch and period in cadences

  planetModel = addedPlanetStruct.transitModelStruct.planetModel ;
  startTimeKjd = inputsStruct.cadenceTimes.midTimestamps(1) - ...
      kjd_offset_from_mjd ;
  epochCadences = 1 + (planetModel.transitEpochBkjd - startTimeKjd) / cadenceDays ;
  epochCadences = max(epochCadences,1) ;
  periodCadences = planetModel.orbitalPeriodDays / cadenceDays ;
  
% find the cadence indices of the transits 

  fluxValues        = inputsStruct.tpsTargets.fluxValue ;
  cadencesOfTransit = round( epochCadences:periodCadences:length(fluxValues) ) ;
  cadencesOfTransit = cadencesOfTransit(:) ;
  
% eliminate cases in which the flux values are zero, indicating
% inter-quarter gaps or missing quarters

  fluxValues = fluxValues(cadencesOfTransit) ;
  cadencesOfTransit = cadencesOfTransit(fluxValues>0) ;
  
% determine the nearest trial transit duration

  durationDifference   = abs(pulseDurations - planetModel.transitDurationHours) ;
  [~,bestTransitMatch] = min(durationDifference) ;
  bestMatchedDuration  = pulseDurations(bestTransitMatch) ;
  
% find the CDPP values at the cadences of transit

  normalizationTimeSeries = tpsDiagnosticStruct(bestTransitMatch).normalizationTimeSeries ;
  cdpp                    = 1e6./normalizationTimeSeries(cadencesOfTransit) ;
  
% now we can estimate the multiple event statistic

  estimatedMes = length(cdpp) * planetModel.transitDepthPpm / ...
      sqrt(sum(cdpp.^2)) ;
  
return
  

  

