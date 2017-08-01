function self = test_tps_validator_error_cases( self ) 
%
% test_tps_validator_error_cases -- unit test of the validate_tps_input_structure function
% for cases in which an error is expected
%
% This unit test exercises the following error-related functionality of the TPS function
% validate_tps_input_structure:
%
% ==> Error occurs when cadenceTimes gap indicators reveal < 125 good cadences present
% ==> Error occurs when storeCdppFlag and trialTransitPulseInHours have different lengths
% ==> Error occurs for TPS-full when # of cadences < minimum search period
%     --> But no such error occurs for TPS-lite
% ==> Error occurs for TPS-full if min search period > max search period
%     --> But no such error occurs for TPS-lite
% ==> Error occurs when fields in cadenceTimes are not all the same length
% ==> Error occurs when fluxValue or uncertainty lengths do not match cadenceTimes length
% 
% This unit test is intended to be executed in the mlunit context.  For standalone
% execution, use the following syntax:
%
%      run(text_test_runner, testTpsClass('test_tps_validator_error_cases'));
%
% Version date:  2010-December-07.
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

% Modification History:
%
%    2010-December-07, PT:
%        add tests for uniformity of cadence count within cadenceTimes and between
%        cadenceTimes and tpsTargets time series.
%
%=========================================================================================

  disp(' ... testing TPS validator error cases ... ') ;

% start with TPS-full  
  
  tpsDataFile = 'tps-full-data-struct' ;
  tpsDataStructName = 'tpsDataStruct' ;
  tps_testing_initialization ;

  tpsDataStruct.cadenceTimes.gapIndicators(125:end) = true ;
  try_to_catch_error_condition( 't=validate_tps_input_structure(tpsDataStruct);', ...
      'timeSeriesTooShort', 'caller' ) ;
  tpsDataStruct.cadenceTimes.gapIndicators(1:end) = false ;
  
  tpsDataStruct.tpsModuleParameters.maxTrialTransitPulseInHours = 15 ;
  tpsDataStruct.tpsModuleParameters.minTrialTransitPulseInHours = -1 ;
  try_to_catch_error_condition( 't=validate_tps_input_structure(tpsDataStruct);', ...
      'minmaxTrialTransitPulseInHoursInconsistent', 'caller' ) ;
  tpsDataStruct.tpsModuleParameters.minTrialTransitPulseInHours = 1.5 ;
  
  tpsDataStruct.tpsModuleParameters.maxTrialTransitPulseInHours = -1 ;
  try_to_catch_error_condition( 't=validate_tps_input_structure(tpsDataStruct);', ...
      'minmaxTrialTransitPulseInHoursInconsistent', 'caller' ) ;
  tpsDataStruct.tpsModuleParameters.maxTrialTransitPulseInHours = 15 ;
  
  tpsDataStruct.tpsModuleParameters.maxTrialTransitPulseInHours = 0 ;
  try_to_catch_error_condition( 't=validate_tps_input_structure(tpsDataStruct);', ...
      'minmaxTrialTransitPulseInHoursSetIncorrectly', 'caller' ) ;
  tpsDataStruct.tpsModuleParameters.maxTrialTransitPulseInHours = 15 ;
  
  tpsDataStruct.tpsModuleParameters.maxTrialTransitPulseInHours = 0.01 ;
  try_to_catch_error_condition( 't=validate_tps_input_structure(tpsDataStruct);', ...
      'minGreaterThanMaxTransitDuration', 'caller' ) ;
  tpsDataStruct.tpsModuleParameters.maxTrialTransitPulseInHours = 15 ;
  
  tpsDataStruct.tpsModuleParameters.maxFoldingsInPeriodSearch = 0 ;
  try_to_catch_error_condition( 't=validate_tps_input_structure(tpsDataStruct);', ...
      'maxFoldingInPeriodSearchSetIncorrectly', 'caller' ) ;
  tpsDataStruct.tpsModuleParameters.maxFoldingsInPeriodSearch = -1 ;
  
  nCadences = length(tpsDataStruct.tpsTargets(1).fluxValue) ;
  tpsDataStruct.cadenceTimes = replace_data_anomaly_types_with_flags( ...
    tpsDataStruct.cadenceTimes ) ;
  dataAnomalyFlagNames = fieldnames( tpsDataStruct.cadenceTimes.dataAnomalyFlags ) ;
  tpsDataStruct.cadenceTimes.dataAnomalyFlags.(dataAnomalyFlagNames{1}) = true(nCadences-1,1) ;
  try_to_catch_error_condition( 't=validate_tps_input_structure(tpsDataStruct);', ...
      'dataAnomalyFlagSizesIncorrect', 'caller' ) ;
  tpsDataStruct.cadenceTimes.dataAnomalyFlags.(dataAnomalyFlagNames{1}) = false(nCadences,1) ;
  
  tpsDataStruct.tpsModuleParameters.storeCdppFlag(end) = [] ;
  try_to_catch_error_condition( 't=validate_tps_input_structure(tpsDataStruct);', ...
      'cdppFieldLengthsUnequal', 'caller' ) ;
  tpsDataStruct.tpsModuleParameters.storeCdppFlag(3) = true ;
  
  tpsDataStruct.tpsModuleParameters.minimumSearchPeriodInDays = 100 ;
  try_to_catch_error_condition( 't=validate_tps_input_structure(tpsDataStruct);', ...
      'minimumSearchPeriodTooLong', 'caller' ) ;
  tpsDataStruct.tpsModuleParameters.minimumSearchPeriodInDays = 1 ;
  
  tpsDataStruct.tpsModuleParameters.minimumSearchPeriodInDays = 2 ;
  tpsDataStruct.tpsModuleParameters.maximumSearchPeriodInDays = 1 ;
  try_to_catch_error_condition( 't=validate_tps_input_structure(tpsDataStruct);', ...
      'MinPeriodGreaterThanMaxPeriod', 'caller' ) ;
  tpsDataStruct.tpsModuleParameters.minimumSearchPeriodInDays = 1 ;
  tpsDataStruct.tpsModuleParameters.maximumSearchPeriodInDays = 365 ;
  
  lastCadenceTime = tpsDataStruct.cadenceTimes.midTimestamps(end) ;
  tpsDataStruct.cadenceTimes.midTimestamps(end) = [] ;
  tpsDataStruct.cadenceTimes.gapIndicators(end) = [] ;
  try_to_catch_error_condition( 't=validate_tps_input_structure(tpsDataStruct);', ...
      'cadenceTimesLengthsNotValid', 'caller' ) ;
  tpsDataStruct.cadenceTimes.midTimestamps = [ tpsDataStruct.cadenceTimes.midTimestamps ; ...
      lastCadenceTime ] ;
  tpsDataStruct.cadenceTimes.gapIndicators = [ tpsDataStruct.cadenceTimes.gapIndicators ; ...
      false ] ;
  
  lastFluxValue = tpsDataStruct.tpsTargets(1).fluxValue(end) ;
  tpsDataStruct.tpsTargets(1).fluxValue(end) = [] ;
%   try_to_catch_error_condition( 't=validate_tps_input_structure(tpsDataStruct);', ...
%       'timeSeriesLengthsNotValid', 'caller' ) ;
   try_to_catch_error_condition( 't=validate_tps_input_structure(tpsDataStruct);', ...
       'dimagree', 'caller' ) ;
  tpsDataStruct.tpsTargets(1).fluxValue = [ tpsDataStruct.tpsTargets(1).fluxValue ; ...
      lastFluxValue ] ;
  
  lastUncertainty = tpsDataStruct.tpsTargets(1).uncertainty(end) ;
  tpsDataStruct.tpsTargets(1).uncertainty(end) = [] ;
%  try_to_catch_error_condition( 't=validate_tps_input_structure(tpsDataStruct);', ...
%      'timeSeriesLengthsNotValid', 'caller' ) ;
  try_to_catch_error_condition( 't=validate_tps_input_structure(tpsDataStruct);', ...
      'dimagree', 'caller' ) ;
  tpsDataStruct.tpsTargets(1).uncertainty = [ tpsDataStruct.tpsTargets(1).uncertainty ; ...
      lastUncertainty ] ;
  
% now TPS-lite

  tpsDataStruct.tpsModuleParameters.tpsLiteEnabled = true ;
  
  tpsDataStruct.cadenceTimes.gapIndicators(125:end) = true ;
  try_to_catch_error_condition( 't=validate_tps_input_structure(tpsDataStruct);', ...
      'timeSeriesTooShort', 'caller' ) ;
  tpsDataStruct.cadenceTimes.gapIndicators(1:end) = false ;
  
  tpsDataStruct.tpsModuleParameters.storeCdppFlag(end) = [] ;
  try_to_catch_error_condition( 't=validate_tps_input_structure(tpsDataStruct);', ...
      'cdppFieldLengthsUnequal', 'caller' ) ;
  tpsDataStruct.tpsModuleParameters.storeCdppFlag(3) = true ;
  
  lastCadenceTime = tpsDataStruct.cadenceTimes.midTimestamps(end) ;
  tpsDataStruct.cadenceTimes.midTimestamps(end) = [] ;
  tpsDataStruct.cadenceTimes.gapIndicators(end) = [] ;
  try_to_catch_error_condition( 't=validate_tps_input_structure(tpsDataStruct);', ...
      'cadenceTimesLengthsNotValid', 'caller' ) ;
  tpsDataStruct.cadenceTimes.midTimestamps = [ tpsDataStruct.cadenceTimes.midTimestamps ; ...
      lastCadenceTime ] ;
  tpsDataStruct.cadenceTimes.gapIndicators = [ tpsDataStruct.cadenceTimes.gapIndicators ; ...
      false ] ;
  
  lastFluxValue = tpsDataStruct.tpsTargets(1).fluxValue(end) ;
  tpsDataStruct.tpsTargets(1).fluxValue(end) = [] ;
%   try_to_catch_error_condition( 't=validate_tps_input_structure(tpsDataStruct);', ...
%       'timeSeriesLengthsNotValid', 'caller' ) ;
   try_to_catch_error_condition( 't=validate_tps_input_structure(tpsDataStruct);', ...
       'dimagree', 'caller' ) ;
  tpsDataStruct.tpsTargets(1).fluxValue = [ tpsDataStruct.tpsTargets(1).fluxValue ; ...
      lastFluxValue ] ;
  
  lastUncertainty = tpsDataStruct.tpsTargets(1).uncertainty(end) ;
  tpsDataStruct.tpsTargets(1).uncertainty(end) = [] ;
%   try_to_catch_error_condition( 't=validate_tps_input_structure(tpsDataStruct);', ...
%       'timeSeriesLengthsNotValid', 'caller' ) ;
  try_to_catch_error_condition( 't=validate_tps_input_structure(tpsDataStruct);', ...
      'dimagree', 'caller' ) ;
  tpsDataStruct.tpsTargets(1).uncertainty = [ tpsDataStruct.tpsTargets(1).uncertainty ; ...
      lastUncertainty ] ;
  
% the errors related to search periods are not thrown in TPS-lite  

  tpsDataStruct.tpsModuleParameters.minimumSearchPeriodInDays = 100 ;
  try
      tpsDataStructAfter = validate_tps_input_structure( tpsDataStruct ) ;
  catch
      mlunit_assert( false, ...
          'TPS-lite threw error for excessive min search period!' ) ;
  end
  tpsDataStruct.tpsModuleParameters.minimumSearchPeriodInDays = 1 ;
  
  tpsDataStruct.tpsModuleParameters.minimumSearchPeriodInDays = 2 ;
  tpsDataStruct.tpsModuleParameters.maximumSearchPeriodInDays = 1 ;
  try
      tpsDataStructAfter = validate_tps_input_structure( tpsDataStruct ) ;
  catch
      mlunit_assert( false, ...
          'TPS-lite threw error for min search period > max search period!' ) ;
  end
  tpsDataStruct.tpsModuleParameters.minimumSearchPeriodInDays = 1 ;
  tpsDataStruct.tpsModuleParameters.maximumSearchPeriodInDays = 365 ;


  disp('') ;
  
return