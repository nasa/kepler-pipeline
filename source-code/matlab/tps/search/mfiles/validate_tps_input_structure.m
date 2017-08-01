function tpsInputStruct = validate_tps_input_structure(tpsInputStruct)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function tpsInputStruct = validate_tps_input_structure(tpsInputStruct)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% This function first checks for the presence of expected fields in the input
% structure, then checks whether each parameter is within the appropriate
% range.
% Comments: This function generates an error under the following scenarios:
%          (1) when invoked with no inputs
%          (2) when any of the essential fields are missing
%          (3) when any of the fields are NaNs/Infs or outside the
%              appropriate bounds
%__________________________________________________________________________
% Input:  A data structure 'tpsInputStruct' 
%__________________________________________________________________________
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

% unpack
tpsModuleParameters               = tpsInputStruct.tpsModuleParameters;
gapFillParameters                 = tpsInputStruct.gapFillParameters;
bootstrapParameters               = tpsInputStruct.bootstrapParameters;
cadenceTimes                      = tpsInputStruct.cadenceTimes;
tpsTargets                        = tpsInputStruct.tpsTargets;
rollTimeModel                     = tpsInputStruct.rollTimeModel;
harmonicsIdentificationParameters = tpsInputStruct.harmonicsIdentificationParameters;
nCadences                         = length(cadenceTimes.gapIndicators);
nTargets                          = length(tpsTargets);
warningInsteadOfErrorFlag         = true;
gapIndicators                     = cadenceTimes.gapIndicators ;


%______________________________________________________________________
% check for the presence of all top level fields in tpsInputStruct
%______________________________________________________________________

fieldsAndBounds = get_tps_input_fields_and_bounds( 'inputsStruct' );
validate_structure(tpsInputStruct, fieldsAndBounds, 'tpsInputStruct');

% if there is not skyGroup, add it and set to zero
if ~isfield(tpsInputStruct,'skyGroup')
    tpsInputStruct.skyGroup = 0 ;
end

clear fieldsAndBounds;

%______________________________________________________________________
% second level validation for tpsInputStruct.tpsModuleParameters
% validate only the fields for TPS-Lite first; check for the existence of
% the rest of the fields
%______________________________________________________________________

fieldsAndBounds = get_tps_input_fields_and_bounds( 'tpsModuleParametersLite' );
validate_structure(tpsModuleParameters, fieldsAndBounds, 'tpsModuleParameters');
clear fieldsAndBounds;

if(~tpsModuleParameters.tpsLiteEnabled)    
    fieldsAndBounds = get_tps_input_fields_and_bounds( 'tpsModuleParameters' );
    validate_structure(tpsModuleParameters, fieldsAndBounds, 'tpsModuleParameters');
    clear fieldsAndBounds;  
end
  
% check the mesHistogram parameters for consistency
if(~tpsModuleParameters.tpsLiteEnabled)
    if(tpsModuleParameters.mesHistogramMinMes > ...
            tpsModuleParameters.mesHistogramMaxMes)
        error('TPS:validateTpsInputStructure:mesHistogramMinMaxInconsistent', ...
            'The mesHistogramMinMes must be less than the mesHistogramMaxMes. Cant proceed! \n')
    end
end

% check the bootstrap parameters for consistency
if(~tpsModuleParameters.tpsLiteEnabled)
    if(tpsModuleParameters.bootstrapGaussianEquivalentThreshold == -1 && ...
            tpsModuleParameters.bootstrapThresholdReductionFactor ~= -1)
        error('TPS:validateTpsInputStructure:bootstrapThresholdReductionFactorInconsistent', ...
            'The bootstrapThresholdReductionFactor is not -1 so the bootstrap veto needs a threshold! \n')
    end
end

if(~tpsModuleParameters.tpsLiteEnabled)
    if(tpsModuleParameters.bootstrapLowMesCutoff ~= -1 && ...
            tpsModuleParameters.bootstrapThresholdReductionFactor ~= -1)
        warning('tps:validateTpsInputStructure:bootstrapLowMesCutoffNotUsed', ...
            'validate_tps_input_structure:  if the bootstrapThresholdReductionFactor is not -1, then the bootstrap veto does not use the bootstrapLowMesCutoff.  Setting it to -1. \n') ;
        tpsModuleParameters.bootstrapLowMesCutoff = -1;
    end
end

% Check to make sure that minTrialTransitPulseInHours is less than
% maxTrialTransitPulseInHours unless they are both equal to -1.  Setting
% them both to -1 will bypass the algorithmically determined D spacing and
% just use requiredTrialTransitPulseInHours.  Note that when D is
% determined algorithmically, the code ensures that each of
% requiredTrialTransitPulseInHours are searched over as well. Note that
% since cdpp computation depends on D's, these values must be set correctly
% regardless if tpsLite is enabled.

if(tpsModuleParameters.minTrialTransitPulseInHours == -1 && ...
        tpsModuleParameters.maxTrialTransitPulseInHours ~= -1)
    
    error('TPS:validateTpsInputStructure:minmaxTrialTransitPulseInHoursInconsistent', ...
        ['validate_tps_input_structure: the field ''maxTrialTransitPulseInHours'' must be set to -1 if minTrialTransitPulseInHours is -1 to bypass algorithmically determined D spacing; \n can''t proceed ...']);
end
if(tpsModuleParameters.minTrialTransitPulseInHours ~= -1 && ...
        tpsModuleParameters.maxTrialTransitPulseInHours == -1)
   
    error('TPS:validateTpsInputStructure:minmaxTrialTransitPulseInHoursInconsistent', ...
        ['validate_tps_input_structure: the field ''minTrialTransitPulseInHours'' must be set to -1 if maxTrialTransitPulseInHours is -1 to bypass algorithmically determined D spacing; \n can''t proceed ...']);
end
if(tpsModuleParameters.minTrialTransitPulseInHours ~= -1 && ...
        tpsModuleParameters.maxTrialTransitPulseInHours ~= -1)
    if(tpsModuleParameters.minTrialTransitPulseInHours <= 0 || ...
            tpsModuleParameters.maxTrialTransitPulseInHours <= 0)
        
        error('TPS:validateTpsInputStructure:minmaxTrialTransitPulseInHoursSetIncorrectly', ...
        ['validate_tps_input_structure: the fields ''min/max TrialTransitPulseInHours'' must both be set to -1 or must both be greater than zero; \n can''t proceed ...']);
        
    end
    if(tpsModuleParameters.minTrialTransitPulseInHours >= ...
            tpsModuleParameters.maxTrialTransitPulseInHours)
        
        error('TPS:validateTpsInputStructure:minGreaterThanMaxTransitDuration', ...
        ['validate_tps_input_structure: the field ''maxTrialTransitPulseInHours'' must be greater than ''minTrialTransitPulseInHours''; \n can''t proceed ...']);
        
    end
end

% Make sure maxFoldingsInPeriodSearch is not in (-1,0]
if(tpsModuleParameters.maxFoldingsInPeriodSearch ~= -1 && tpsModuleParameters.maxFoldingsInPeriodSearch <= 0)
        
    error('TPS:validateTpsInputStructure:maxFoldingInPeriodSearchSetIncorrectly', ...
        ['validate_tps_input_structure: the field ''maxFoldingInPeriodSearch'' must be set to -1 or must be greater than zero; \n can''t proceed ...']);
        
end


%______________________________________________________________________
% second level validation for tpsInputStruct.gapFillParameters
%______________________________________________________________________

fieldsAndBounds = get_tps_input_fields_and_bounds( 'gapFillParameters' );
validate_structure(gapFillParameters, fieldsAndBounds,'tpsInputStruct.gapFillParameters');
clear fieldsAndBounds;

%
% the old harmonicsIdentificationParameters are now totally obsolete.  At this time,
% we do not have min/max values for the new harmonics identification parameters, so we do
% a check for presence of the required fields and look to see that their values aren't
% crazy (crazy values indicates a corrupted input).
%
%______________________________________________________________________
% second level validation for tpsInputStruct.harmonicsIdentificationParameters
%______________________________________________________________________

fieldsAndBounds = get_tps_input_fields_and_bounds( 'harmonicsIdentificationParameters' );
validate_structure(harmonicsIdentificationParameters, fieldsAndBounds,'tpsInputStruct.harmonicsIdentificationParameters');
clear fieldsAndBounds;

%______________________________________________________________________
% second level validation for tpsInputStruct.bootstrapParameters
%______________________________________________________________________

fieldsAndBounds = get_tps_input_fields_and_bounds( 'bootstrapParameters' );
validate_structure(bootstrapParameters, fieldsAndBounds,'tpsInputStruct.bootstrapParameters');
clear fieldsAndBounds;

%______________________________________________________________________
% second level validation for tpsInputStruct.cadenceTimes
%______________________________________________________________________

% we are going to replace the dataAnomalyTypes cell array with a dataAnomalyFlags struct,
% but we want to have backwards compatibility for awhile.  Thus, if a cadenceTimes struct
% comes in with a dataAnomalyTypes array, replace it with the dataAnomalyFlags struct.

cadenceTimes = replace_data_anomaly_types_with_flags( cadenceTimes ) ;

% do not validate time stamps if gap indicators are set to true...
fieldsAndBounds = get_tps_input_fields_and_bounds( 'cadenceTimes' );
validate_cadence_times_structure(cadenceTimes, fieldsAndBounds,'tpsInputStruct.cadenceTimes');
clear fieldsAndBounds;

if(sum(~cadenceTimes.gapIndicators) <= 125) % varianceWindowLength*trialTransitPulseWidth
    nValidCadences = sum(~cadenceTimes.gapIndicators);
    
    error('TPS:validateTpsInputStructure:timeSeriesTooShort', ...
        ['validate_tps_input_structure: cadence time series contains only  ' num2str(nValidCadences) ' cadences; the rest are gaps. \n' ...
        'can''t search for transits in such short flux time series, so quitting ...']);
    
end

% confirm that all fields in the cadenceTimes struct are vectors with the same length

nCadenceTimes = validate_cadence_times_field_lengths( cadenceTimes ) ;

%______________________________________________________________________
% second level validation for tpsInputStruct.tpsTargets
%______________________________________________________________________

fieldsAndBounds = get_tps_input_fields_and_bounds( 'tpsTargetsGross' );

for j = 1:nTargets
    % explicitly add outlierIndices to fillIndices since they should be
    % there but it is possible they are not because of an upstream change
    
    tpsTargets(j).fillIndices = union( tpsTargets(j).fillIndices, tpsTargets(j).outlierIndices );
    % convert NaN or Inf values which fall on gaps or fills to zero values -- this is to
    % patch a problem in PDC which we will probably have to live with for awhile
    
    gapIndicators(tpsTargets(j).fillIndices + 1) = true ;
    gapIndicators(tpsTargets(j).gapIndices + 1) = true ;
    
    badFluxValues = isnan(tpsTargets(j).fluxValue) | isinf(tpsTargets(j).fluxValue) | ...
        isnan(tpsTargets(j).uncertainty) | isinf(tpsTargets(j).uncertainty) ;
    tpsTargets(j).fluxValue(badFluxValues & gapIndicators) = 0 ;
    tpsTargets(j).uncertainty(badFluxValues & gapIndicators) = 0 ;
    
%   in an extremely rare corner case, we will get a target which is all gaps or fills.  In
%   this case, validation should fail now

    if all(gapIndicators)
        error('tps:validateTpsInputStructure:noValidCadences', ...
            'validate_tps_input_structure:  no valid cadences present') ;
    end
    
    validate_structure(tpsTargets(j), fieldsAndBounds, 'tpsInputStruct.tpsTargets');
end

clear fieldsAndBounds;


%------------------------------------------------------------
% validate diagnostics structure when developing TPS Phase III code
% for now comment out
% fieldsAndBounds = cell(5,4);
% fieldsAndBounds(1,:)  = { 'keplerMag'; '>= 0'; '<= 25'; []};
% fieldsAndBounds(2,:)  = { 'validKeplerMag';  '>= 0'; '<= 25'; []};
% fieldsAndBounds(3,:)  = { 'ccdModule'; []; []; '[2:4, 6:20, 22:24]''';};
% fieldsAndBounds(4,:)  = { 'ccdOutput'; []; []; '[1 2 3 4]'''};
% fieldsAndBounds(5,:)  = { 'crowding'; '>= -1'; '<= 1'; []};



% all the expected fields are present - so validate values after excluding the gaps
% convert all the indices to 1-base as java uses 0-base counting system

for j = 1:nTargets
    
    fieldsAndBounds = get_tps_input_fields_and_bounds( 'tpsTargetsFine' );
    
    if(~isempty(tpsTargets(j).gapIndices))
        tpsTargets(j).gapIndices(:) = tpsTargets(j).gapIndices(:) + 1;
        fieldsAndBounds(4,:)  = { 'gapIndices'; '> 0';['<= ' num2str(nCadences)] ; []};
    end
    
    if(~isempty(tpsTargets(j).fillIndices))
        tpsTargets(j).fillIndices(:) = tpsTargets(j).fillIndices(:) + 1;
        fieldsAndBounds(5,:)  = { 'fillIndices';'> 0';['<= ' num2str(nCadences)] ; []};
    end
    
    if(~isempty(tpsTargets(j).outlierIndices))
        tpsTargets(j).outlierIndices(:) = tpsTargets(j).outlierIndices(:) + 1;
        fieldsAndBounds(6,:)  = { 'outlierIndices';'> 0';['<= ' num2str(nCadences)] ; []};
    end
        
    if(~isempty(tpsTargets(j).discontinuityIndices))
        tpsTargets(j).discontinuityIndices(:) = tpsTargets(j).discontinuityIndices(:) + 1;
        fieldsAndBounds(7,:)  = { 'discontinuityIndices';'> 0';['<= ' num2str(nCadences)] ; []};
    end
    
    validate_structure(tpsTargets(j), fieldsAndBounds,['tpsInputStruct.tpsTargets(' num2str(j) ')'] ,warningInsteadOfErrorFlag); % set the flag to false once things stabilize
    %validate_structure(tpsInputStruct.tpsTargets(j).diagnostics, fieldsAndBounds,['tpsInputStruct.tpsTargets(' num2str(j) ').diagnostics']);
    clear fieldsAndBounds;
    
end

% confirm that all flux time series are vectors with the correct length

validate_flux_time_series_lengths( tpsTargets, nCadenceTimes ) ;


%_____________________________________________________________________
% second level validation for tpsInputStruct.rollTimeModel
%______________________________________________________________________

fieldsAndBounds = get_tps_input_fields_and_bounds( 'rollTimeModel' );
validate_structure(rollTimeModel, fieldsAndBounds,'tpsInputStruct.rollTimeModel');
clear fieldsAndBounds;

%______________________________________________________________________
% third level validation for tpsInputStruct.cadenceTimes.dataAnomalyFlags
%______________________________________________________________________

fieldsAndBounds = get_tps_input_fields_and_bounds( 'dataAnomalyFlags' );
validate_structure(cadenceTimes.dataAnomalyFlags, ...
    fieldsAndBounds,'tpsInputStruct.cadenceTimes.dataAnomalyFlags');
clear fieldsAndBounds;

% make sure that all vectors are the correct length

dataAnomalyFlagNames = fieldnames( cadenceTimes.dataAnomalyFlags ) ;

for iFlag = 1:length(dataAnomalyFlagNames)
    if length( cadenceTimes.dataAnomalyFlags.(dataAnomalyFlagNames{iFlag}) ) ...
            ~= nCadenceTimes
        error('TPS:validateTpsInputStructure:dataAnomalyFlagSizesIncorrect', ...
            'validate_tps_input_structure:  data anomaly flag vectors have incorrect sizes') ;
    end
end

%______________________________________________________________________
% add cadence duration in minutes to gapFillparameters for now
%______________________________________________________________________

cadenceDurationInMinutes = compute_cadence_duration_in_minutes(cadenceTimes);
gapFillParameters.cadenceDurationInMinutes = cadenceDurationInMinutes;

%______________________________________________________________________
% update the module parameters where needed
%______________________________________________________________________

tpsModuleParameters = update_tps_module_parameters( tpsModuleParameters, nCadences, cadenceDurationInMinutes );

%______________________________________________________________________
% collect the cadences after safe modes, attitude tweaks, and
% discontinuities. Set the deemphasis parameters in the safe mode,
% earth point, and attitude tweak cadences, and the surrounding ones.
%______________________________________________________________________

if(~tpsModuleParameters.tpsLiteEnabled)
    
    dataAnomalyIndicators = cadenceTimes.dataAnomalyFlags;
    cadencesPerDay = tpsModuleParameters.cadencesPerDay;
    deemphasizePeriodAfterSafeModeInDays = tpsModuleParameters.deemphasizePeriodAfterSafeModeInDays;
    deemphasizePeriodAfterSafeModeInCadences = round( cadencesPerDay * deemphasizePeriodAfterSafeModeInDays ) ;
    deemphasizePeriodAfterTweakInCadences = tpsModuleParameters.deemphasizePeriodAfterTweakInCadences;
    
    %--------------------------------------------------------------------------
    % check for safe mode events
    %--------------------------------------------------------------------------
    
    % combine the earthPointIndicators with safeModeIndicators as pointing the
    % spacecraft towards earth for monthly downlink and returning it back to
    % science collection results in a thermal recovery profile similar to the one
    % folowing safe mode recovery
    
    
    earthPointIndicators          = dataAnomalyIndicators.earthPointIndicators;
    safeModeIndicators            = dataAnomalyIndicators.safeModeIndicators;
    
    if deemphasizePeriodAfterSafeModeInCadences > 0
        deemphasisParameterSafeMode = set_deemphasis_parameter( ...
            find_datagap_locations( safeModeIndicators ), ...
            deemphasizePeriodAfterSafeModeInCadences, nCadences ) ;
        
        % insert an earth point at the very start and end of the data to be
        % consistent
        
        deemphasisParameterEarthPoint = set_deemphasis_parameter( ...
            find_datagap_locations( [true;earthPointIndicators;true] ), ...
            deemphasizePeriodAfterSafeModeInCadences, nCadences + 2 ) ;
        deemphasisParameterEarthPoint = deemphasisParameterEarthPoint(2:end-1);
    else
        deemphasisParameterEarthPoint = ones(nCadences,1) ;
        deemphasisParameterSafeMode = ones(nCadences,1) ;
    end
            
    attitudeTweakIndicators = dataAnomalyIndicators.attitudeTweakIndicators ;
    if deemphasizePeriodAfterTweakInCadences > 0
        deemphasisParameterAttitudeTweak = set_deemphasis_parameter( ...
            find_datagap_locations( attitudeTweakIndicators ), ...
            deemphasizePeriodAfterTweakInCadences, nCadences ) ;
    else
        deemphasisParameterAttitudeTweak = ones(nCadences,1) ;
    end
        
    cadenceTimes.deemphasisParameter = min( [deemphasisParameterAttitudeTweak ...
         deemphasisParameterEarthPoint  deemphasisParameterSafeMode ], [],  2 ) ;
     
%   Any "orphaned" data anomaly indicators (data anomaly indicators which are not marked
%   as either gaps or fills in each target) should be marked as a target-level data gap,
%   since we cannot know whether there is or is not data present in this case

    dataAnomalies = fieldnames(dataAnomalyIndicators) ;
    anomalySum = false( nCadences, 1 ) ;
    for iAnomaly = 1:length(dataAnomalies)
        anomalySum = anomalySum | dataAnomalyIndicators.(dataAnomalies{iAnomaly}) ;
    end

    for iTarget = 1:nTargets
        
        targetLevelGapIndicators = false( nCadences, 1 ) ;
        targetLevelGapIndicators(tpsTargets(iTarget).gapIndices) = true ;
        targetLevelGapIndicators(tpsTargets(iTarget).fillIndices) = true ;
        
        orphanedAnomalies = anomalySum & ~targetLevelGapIndicators ;
                
        tpsTargets(iTarget).gapIndices = unique( [tpsTargets(iTarget).gapIndices ; ...
            find(orphanedAnomalies) ] ) ;

    end
    
    
else
    
%  Need to add in the deemphasis parameter even when TPS lite is enabled 
% now since it gets used during output initialization
    
    cadenceTimes.deemphasisParameter = ones(nCadences, 1);
        
end

%______________________________________________________________________
% generate the random number streams and add them to the input
%______________________________________________________________________

kepIdArray = [tpsTargets.keplerId] ;
kepIdArray = kepIdArray(:) ;
paramStruct = socRandStreamManagerClass.get_default_param_struct() ;
randStreamStruct = socRandStreamManagerClass('TPS', kepIdArray, paramStruct) ;

%______________________________________________________________________
% pack everything that was modified back into tpsInputStruct
%______________________________________________________________________

tpsInputStruct.tpsModuleParameters = tpsModuleParameters ;
tpsInputStruct.gapFillParameters = gapFillParameters ;
tpsInputStruct.cadenceTimes = cadenceTimes ;
tpsInputStruct.tpsTargets = tpsTargets ;
tpsInputStruct.randStreams = randStreamStruct ;

return

%=========================================================================================

% subfunction which determines that all cadenceTimes fields are vectors of equal lengths

function nCadences = validate_cadence_times_field_lengths( cadenceTimes )

% loop over all fields in cadenceTimes, except for dataAnomalyFlags

  cadenceTimesLocal = rmfield( cadenceTimes, 'dataAnomalyFlags' ) ;

  fieldNames = fieldnames( cadenceTimesLocal ) ;
  fieldNames = fieldNames(:) ;
  nCadences = length( cadenceTimes.(fieldNames{1}) ) ;
  
  for iField = fieldNames'
      
      if length( cadenceTimes.(iField{1}) ) ~= nCadences
          error( 'tps:validateTpsInputStructure:cadenceTimesLengthsNotValid', ...
              'validate_tps_input_structure: cadenceTimes field lengths not all equal' ) ;
      end
      
  end
  
return

%=========================================================================================

% subfunction which determines that flux time series all have correct length

function validate_flux_time_series_lengths( tpsTargets, nCadenceTimes )

  tpsTargets = tpsTargets(:) ;
  for iTarget = tpsTargets'
      
      if length( iTarget.fluxValue ) ~= nCadenceTimes || ...
              length( iTarget.uncertainty ) ~= nCadenceTimes
          error( 'tps:validateTpsInputStructure:timeSeriesLengthsNotValid', ...
              'validate_tps_input_structure: flux time series lengths do not match # cadence times' ) ;
      end
      
  end
  
return


