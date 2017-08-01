% script tps_testing_initialization -- perform setups which are more or less common to all
% TPS unit tests
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

% set the path to the test data

  initialize_soc_variables ;
  testDataPath = [socTestDataRoot filesep 'tps'] ;
  
% set the default parameters for time series generation

  harmonicPeriodCadences = 59 ;
  finalPhaseShiftRadians = pi ;
  transitEpochCadence = 500 ;
  transitPeriodCadences = 1000 ;
  transitDurationCadences = 7 ;
  
% if there's a tpsDataFile variable, load it

  if exist( 'tpsDataFile', 'var' ) 
      load( fullfile( testDataPath, tpsDataFile ) ) ;
  end
  
% if there's a tpsDataStruct variable, perform the merging of the master data struct and
% the tpsDataStruct 

  if exist( 'tpsDataStructName', 'var' )
      
%     start by renaming the tpsDataStruct to a neutral name, and loading the master struct

      eval( [ 'tpsLocalDataStruct = ',tpsDataStructName, ' ; ' ] ) ;
      load( fullfile( testDataPath, 'tps-input-struct-master' ) ) ;

%     copy the tpsDataStruct target and cadence time fields

      tpsInputStructMaster.tpsTargets   = tpsLocalDataStruct.tpsTargets ;
      tpsInputStructMaster.cadenceTimes = tpsLocalDataStruct.cadenceTimes ;
      
%     if the local struct has any tpsModuleParameters, copy them over

      if isfield( tpsLocalDataStruct, 'tpsModuleParameters' ) && ...
              isstruct( tpsLocalDataStruct.tpsModuleParameters ) && ...
              ~isempty( tpsLocalDataStruct.tpsModuleParameters ) 
          parameterFields = fieldnames( tpsLocalDataStruct.tpsModuleParameters ) ;
          for iField = 1:length(parameterFields)
              thisParameterField = parameterFields{iField} ;
              tpsInputStructMaster.tpsModuleParameters.(thisParameterField) = ...
                  tpsLocalDataStruct.tpsModuleParameters.(thisParameterField) ;
          end
      end
      
%     convert input paramters - this saves us from having to maintain the
%     test input files every time the module interface changes

      tpsInputStructMaster = tps_convert_70_data_to_80( tpsInputStructMaster ) ;
      tpsInputStructMaster = tps_convert_80_data_to_81( tpsInputStructMaster ) ;
      tpsInputStructMaster = tps_convert_81_data_to_82( tpsInputStructMaster ) ;
      tpsInputStructMaster = tps_convert_82_data_to_83( tpsInputStructMaster ) ;
      
%     turn off corrections that affect particular cadences
    
      tpsInputStructMaster.tpsModuleParameters.deweightReactionWheelZeroCrossingCadences = false ;
      tpsInputStructMaster.tpsModuleParameters.applyAttitudeTweakCorrection = false ;
      
%     perform an orderfields so that if fields are added they wind up in the correct
%     place, ie in alpha order
      
      tpsInputStructMaster.tpsModuleParameters = orderfields( ...
          tpsInputStructMaster.tpsModuleParameters ) ;
      
%     if there's a gapFillParameters field in the local struct, and it contains
%     cadenceTimeInMinutes, copy that over

      if isfield( tpsLocalDataStruct, 'gapFillParameters' ) && ...
              isfield( tpsLocalDataStruct.gapFillParameters, 'cadenceDurationInMinutes' )
          tpsInputStructMaster.gapFillParameters.cadenceDurationInMinutes = ...
              tpsLocalDataStruct.gapFillParameters.cadenceDurationInMinutes ;
      end
      
%     rename the master struct to the original name of the local data struct, and do
%     cleanup

      eval( [ tpsDataStructName, ' = tpsInputStructMaster ; ' ] ) ;
      clear tpsInputStructMaster tpsLocalDataStrut iField parameterFields
      clear thisParameterField
      
  end % existence of tpsDataStruct name conditional
      
% I think that's all there is right now

return