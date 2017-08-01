function validate_pa_inputs(paDataStruct)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function validate_pa_inputs(paDataStruct)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% This function first checks for the presence of expected fields in the
% input structure and then checks whether each parameter is within the
% appropriate range. Once the validation of the inputs is complete, the
% class constructor for the paDataClass may be called to instantiate a PA
% class object.
%
% Comments: This function generates an error under the following scenarios:
%
%          (1) when invoked with no inputs
%          (2) when any of the fields are missing
%          (3) when any of the fields are NaNs/Infs or outside the
%              appropriate bounds
%
% Note that the paDataStruct input to this function is slightly different
% than that which is input to the pa_matlab_controller. Input blobs to the
% matlab controller have been converted to structures before this function
% is invoked:
%
%    backgroundBlobs     -> backgroundPolyStruct
%    motionBlobs         -> motionPolyStruct
%
% Allow NaN's for keplerMag, raHours, AND/OR decDegrees for Kepler custom
% targets only (100000000 <= keplerId <= 199999999). All others must have
% valid values.
%
% See pa_matlab_controller.m for a list of inputs validated by this
% function. 
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
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

% Define constants
CUSTOM_TARGET_DEFAULT_MAG = 29;
PPA_STELLAR_LABEL = 'PPA_STELLAR';

% If no input, generate an error.
if nargin == 0
    error('PA:validatePaInputs:EmptyInputStruct', ...
        'This function must be called with an input structure');
end
    

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Validate inputs and check fields and bounds.
%
% (1) check for the presence of all fields
% (2) check whether the parameters are within bounds and are not NaNs/Infs
%
% Note: if fields are structures, make sure that their bounds are empty.
    
%--------------------------------------------------------------------------
% Top level validation.
% Validate fields in paDataStruct.
%--------------------------------------------------------------------------
fieldsAndBounds = cell(39,4);
fieldsAndBounds(1,:)  = { 'ccdModule';  []; []; '[2:4, 6:20, 22:24]'''};
fieldsAndBounds(2,:)  = { 'ccdOutput';  []; []; '[1 2 3 4]'''};
fieldsAndBounds(3,:)  = { 'cadenceType'; []; []; {'LONG' ; 'SHORT'}};
fieldsAndBounds(4,:)  = { 'startCadence'; '>= 0'; '< 2e7'; []};
fieldsAndBounds(5,:)  = { 'endCadence'; '>= 0'; '< 2e7'; []};
fieldsAndBounds(6,:)  = { 'firstCall'; []; []; [true; false]};
fieldsAndBounds(7,:)  = { 'lastCall'; []; []; [true; false]};
fieldsAndBounds(8,:)  = { 'ppaTargetCount'; '>= 0'; []; []};
fieldsAndBounds(9,:)  = { 'fcConstants'; []; []; []};                     % Validate only needed fields
fieldsAndBounds(10,:) = { 'spacecraftConfigMap'; []; []; []};             % Do not validate
fieldsAndBounds(11,:) = { 'raDec2PixModel'; []; []; []};                  % Do not validate
fieldsAndBounds(12,:) = { 'cadenceTimes'; []; []; []};
fieldsAndBounds(13,:) = { 'longCadenceTimes'; []; []; []};
fieldsAndBounds(14,:) = { 'paConfigurationStruct'; []; []; []};
fieldsAndBounds(15,:) = { 'reactionWheelAncillaryEngineeringConfigurationStruct'; []; []; []};
fieldsAndBounds(16,:) = { 'oapAncillaryEngineeringConfigurationStruct'; []; []; []};
fieldsAndBounds(17,:) = { 'ancillaryPipelineConfigurationStruct'; []; []; []};
fieldsAndBounds(18,:) = { 'ancillaryDesignMatrixConfigurationStruct'; []; []; []};
fieldsAndBounds(19,:) = { 'backgroundConfigurationStruct'; []; []; []};
fieldsAndBounds(20,:) = { 'motionConfigurationStruct'; []; []; []};
fieldsAndBounds(21,:) = { 'cosmicRayConfigurationStruct'; []; []; []};
fieldsAndBounds(22,:) = { 'harmonicsIdentificationConfigurationStruct'; []; []; []};
fieldsAndBounds(23,:) = { 'encircledEnergyConfigurationStruct'; []; []; []};
fieldsAndBounds(24,:) = { 'gapFillConfigurationStruct'; []; []; []};
fieldsAndBounds(25,:) = { 'pouConfigurationStruct'; []; []; []};
fieldsAndBounds(26,:) = { 'saturationSegmentConfigurationStruct'; []; []; []};
fieldsAndBounds(27,:) = { 'argabrighteningConfigurationStruct'; []; []; []};
fieldsAndBounds(28,:) = { 'ancillaryEngineeringDataStruct'; []; []; []};        % Validate if exists
fieldsAndBounds(29,:) = { 'ancillaryPipelineDataStruct'; []; []; []};           % Validate if exists
fieldsAndBounds(30,:) = { 'backgroundDataStruct'; []; []; []};                  % Validate if exists
fieldsAndBounds(31,:) = { 'targetStarDataStruct'; []; []; []};                  % Validate if exists
fieldsAndBounds(32,:) = { 'prfModel'; []; []; []};                              % Do not validate
fieldsAndBounds(33,:) = { 'rollingBandArtifactFlags'; []; []; []};              % Validate if exists
fieldsAndBounds(34,:) = { 'backgroundPolyStruct'; []; []; []};                  % Validate if exists
fieldsAndBounds(35,:) = { 'motionPolyStruct'; []; []; []};                      % Validate if exists
fieldsAndBounds(36,:) = { 'transitInjectionParametersFileName'; []; []; []};    % Field must exist but may be empty
fieldsAndBounds(37,:) = { 'apertureModelConfigurationStruct'; []; []; []};      % Field must exist but may be empty
fieldsAndBounds(38,:) = { 'paCoaConfigurationStruct'; []; []; []};              % Field must exist but may be empty
fieldsAndBounds(39,:) = { 'thrusterDataAncillaryEngineeringConfigurationStruct'; []; []; []}; % Field must exist but may be empty

validate_structure(paDataStruct, fieldsAndBounds, 'paDataStruct');

clear fieldsAndBounds;

%--------------------------------------------------------------------------
% Second level validation.
% Validate the structure field paDataStruct.fcConstants (only needed
% fields).
%--------------------------------------------------------------------------
fieldsAndBounds = cell(2,4);
fieldsAndBounds(1,:)  = { 'TWELFTH_MAGNITUDE_ELECTRON_FLUX_PER_SECOND'; '>= 1.5e5'; '< 2.5e5'; []};
fieldsAndBounds(2,:)  = { 'PIXEL_SIZE_IN_MICRONS'; '>= 25'; '< 30'; []};

validate_structure(paDataStruct.fcConstants, fieldsAndBounds, 'paDataStruct.fcConstants');

clear fieldsAndBounds;

%--------------------------------------------------------------------------
% Second level validation.
% Validate the structure field paDataStruct.cadenceTimes.
%--------------------------------------------------------------------------
fieldsAndBounds = cell(6,4);
fieldsAndBounds(1,:)  = { 'startTimestamps'; '> 54500'; '< 70000'; []}; % 2/4/2008 to 7/13/2050
fieldsAndBounds(2,:)  = { 'midTimestamps'; '> 54500'; '< 70000'; []};   % 2/4/2008 to 7/13/2050
fieldsAndBounds(3,:)  = { 'endTimestamps'; '> 54500'; '< 70000'; []};   % 2/4/2008 to 7/13/2050
fieldsAndBounds(4,:)  = { 'gapIndicators'; []; []; [true; false]};
fieldsAndBounds(5,:)  = { 'requantEnabled'; []; []; [true; false]};
fieldsAndBounds(6,:)  = { 'cadenceNumbers'; '>= 0'; '< 2e7'; []};

cadenceTimes = paDataStruct.cadenceTimes;
cadenceTimes.startTimestamps = ...
    cadenceTimes.startTimestamps(~cadenceTimes.gapIndicators);
cadenceTimes.midTimestamps = ...
    cadenceTimes.midTimestamps(~cadenceTimes.gapIndicators);
cadenceTimes.endTimestamps = ...
    cadenceTimes.endTimestamps(~cadenceTimes.gapIndicators);

validate_structure(cadenceTimes, fieldsAndBounds, 'paDataStruct.cadenceTimes');

clear fieldsAndBounds;

%--------------------------------------------------------------------------
% Second level validation.
% Validate the structure field paDataStruct.longCadenceTimes.
%--------------------------------------------------------------------------
fieldsAndBounds = cell(6,4);
fieldsAndBounds(1,:)  = { 'startTimestamps'; '> 54500'; '< 70000'; []}; % 2/4/2008 to 7/13/2050
fieldsAndBounds(2,:)  = { 'midTimestamps'; '> 54500'; '< 70000'; []};   % 2/4/2008 to 7/13/2050
fieldsAndBounds(3,:)  = { 'endTimestamps'; '> 54500'; '< 70000'; []};   % 2/4/2008 to 7/13/2050
fieldsAndBounds(4,:)  = { 'gapIndicators'; []; []; [true; false]};
fieldsAndBounds(5,:)  = { 'requantEnabled'; []; []; [true; false]};
fieldsAndBounds(6,:)  = { 'cadenceNumbers'; '>= 0'; '< 2e7'; []};

cadenceTimes = paDataStruct.longCadenceTimes;
cadenceTimes.startTimestamps = ...
    cadenceTimes.startTimestamps(~cadenceTimes.gapIndicators);
cadenceTimes.midTimestamps = ...
    cadenceTimes.midTimestamps(~cadenceTimes.gapIndicators);
cadenceTimes.endTimestamps = ...
    cadenceTimes.endTimestamps(~cadenceTimes.gapIndicators);

validate_structure(cadenceTimes, fieldsAndBounds, 'paDataStruct.longCadenceTimes');

clear fieldsAndBounds;

%--------------------------------------------------------------------------
% Second level validation.
% Validate the structure field paDataStruct.paConfigurationStruct.
%--------------------------------------------------------------------------
fieldsAndBounds = cell(22,4);
fieldsAndBounds(1,:)  = { 'debugLevel'; '>= 0'; '<= 5'; []};
fieldsAndBounds(2,:)  = { 'cosmicRayCleaningEnabled'; []; []; [true; false]};
fieldsAndBounds(3,:)  = { 'oapEnabled'; []; []; [true; false]};
fieldsAndBounds(4,:)  = { 'targetPrfCentroidingEnabled'; []; []; [true; false]};
fieldsAndBounds(5,:)  = { 'ppaTargetPrfCentroidingEnabled'; []; []; [true; false]};
fieldsAndBounds(6,:)  = { 'discretePrfCentroidingEnabled'; []; []; [true; false]};
fieldsAndBounds(7,:)  = { 'discretePrfOversampleFactor'; '>= 1'; '< 1000'; []};
fieldsAndBounds(8,:)  = { 'stellarVariabilityDetrendOrder'; '>= 0'; '< 10'; []};
fieldsAndBounds(9,:)  = { 'stellarVariabilityThreshold'; '> 0'; '< 1'; []};
fieldsAndBounds(10,:) = { 'madThresholdForCentroidOutliers'; '> 1'; '< 10'; []};
fieldsAndBounds(11,:) = { 'thresholdMultiplierForPositiveCentroidOutliers'; '> 0'; '< 1000'; []};
fieldsAndBounds(12,:) = { 'brightRobustThreshold'; '>= 0'; '<= 1'; []};
fieldsAndBounds(13,:) = { 'minimumBrightTargets'; '>= 5'; '<= 100'; []};
fieldsAndBounds(14,:) = { 'reactionWheelMedianFilterLength'; '>= 1'; '<= 1000'; []};
fieldsAndBounds(15,:) = { 'simulatedTransitsEnabled'; []; []; [true; false]};
fieldsAndBounds(16,:) = { 'rollingBandContaminationFlagsEnabled'; []; []; [true; false]};
fieldsAndBounds(17,:) = { 'removeMedianSimulatedFlux'; []; []; [true; false]};
fieldsAndBounds(18,:) = { 'k2GapIfNotFinePntData';   []; []; [true; false]};
fieldsAndBounds(19,:) = { 'k2GapPreTweakData';       []; []; [true; false]};
fieldsAndBounds(20,:) = { 'k2TrimAperturesEnabled';  []; []; [true; false]};
fieldsAndBounds(21,:) = { 'k2TrimRadiusInPrfWidths'; '>= 0'; []; []};
fieldsAndBounds(22,:) = { 'k2TrimMinSizeInPixels';   '>= 0'; []; []};

validate_structure(paDataStruct.paConfigurationStruct, fieldsAndBounds, ...
    'paDataStruct.paConfigurationStruct');

clear fieldsAndBounds;

%--------------------------------------------------------------------------
% Second level validation.
% Validate the structure field paDataStruct.reactionWheelAncillaryEngineeringConfigurationStruct
%--------------------------------------------------------------------------
fieldsAndBounds = cell(5,4);
if isfield(paDataStruct.reactionWheelAncillaryEngineeringConfigurationStruct, 'mnemonics') && ...
        ~isempty(paDataStruct.reactionWheelAncillaryEngineeringConfigurationStruct.mnemonics)
    fieldsAndBounds(1,:)  = { 'mnemonics'; []; []; {}};
    fieldsAndBounds(2,:)  = { 'modelOrders'; '>= 0'; '<= 5'; []};
    fieldsAndBounds(3,:)  = { 'interactions'; []; []; {}};
    fieldsAndBounds(4,:)  = { 'quantizationLevels'; '>= 0'; []; []};
    fieldsAndBounds(5,:)  = { 'intrinsicUncertainties'; '>= 0'; []; []};
else
    fieldsAndBounds(1,:)  = { 'mnemonics'; []; []; {}};
    fieldsAndBounds(2,:)  = { 'modelOrders'; []; []; []};                   % May be empty; can't validate against bounds
    fieldsAndBounds(3,:)  = { 'interactions'; []; []; {}};
    fieldsAndBounds(4,:)  = { 'quantizationLevels'; []; []; []};            % May be empty; can't validate against bounds
    fieldsAndBounds(5,:)  = { 'intrinsicUncertainties'; []; []; []};        % May be empty; can't validate against bounds
end

validate_structure(paDataStruct.reactionWheelAncillaryEngineeringConfigurationStruct, fieldsAndBounds, ...
    'paDataStruct.reactionWheelAncillaryEngineeringConfigurationStruct');

clear fieldsAndBounds;
    
%--------------------------------------------------------------------------
% Second level validation.
% Validate the structure field paDataStruct.oapAncillaryEngineeringConfigurationStruct
%--------------------------------------------------------------------------
fieldsAndBounds = cell(5,4);
if isfield(paDataStruct.oapAncillaryEngineeringConfigurationStruct, 'mnemonics') && ...
        ~isempty(paDataStruct.oapAncillaryEngineeringConfigurationStruct.mnemonics)
    fieldsAndBounds(1,:)  = { 'mnemonics'; []; []; {}};
    fieldsAndBounds(2,:)  = { 'modelOrders'; '>= 0'; '<= 5'; []};
    fieldsAndBounds(3,:)  = { 'interactions'; []; []; {}};
    fieldsAndBounds(4,:)  = { 'quantizationLevels'; '>= 0'; []; []};
    fieldsAndBounds(5,:)  = { 'intrinsicUncertainties'; '>= 0'; []; []};
else
    fieldsAndBounds(1,:)  = { 'mnemonics'; []; []; {}};
    fieldsAndBounds(2,:)  = { 'modelOrders'; []; []; []};                   % May be empty; can't validate against bounds
    fieldsAndBounds(3,:)  = { 'interactions'; []; []; {}};
    fieldsAndBounds(4,:)  = { 'quantizationLevels'; []; []; []};            % May be empty; can't validate against bounds
    fieldsAndBounds(5,:)  = { 'intrinsicUncertainties'; []; []; []};        % May be empty; can't validate against bounds
end

validate_structure(paDataStruct.oapAncillaryEngineeringConfigurationStruct, fieldsAndBounds, ...
    'paDataStruct.oapAncillaryEngineeringConfigurationStruct');

clear fieldsAndBounds;
%--------------------------------------------------------------------------
% Second level validation.
% Validate the structure field paDataStruct.thrusterDataAncillaryEngineeringConfigurationStruct
%--------------------------------------------------------------------------
fieldsAndBounds = cell(6,4);
if isfield(paDataStruct.thrusterDataAncillaryEngineeringConfigurationStruct, 'mnemonics') && ...
        ~isempty(paDataStruct.thrusterDataAncillaryEngineeringConfigurationStruct.mnemonics)
    fieldsAndBounds(1,:)  = { 'mnemonics'; []; []; {}};
    fieldsAndBounds(2,:)  = { 'modelOrders'; '>= 0'; '<= 5'; []};
    fieldsAndBounds(3,:)  = { 'interactions'; []; []; {}};
    fieldsAndBounds(4,:)  = { 'quantizationLevels'; '>= 0'; []; []};
    fieldsAndBounds(5,:)  = { 'intrinsicUncertainties'; '>= 0'; []; []};
    fieldsAndBounds(6,:)  = { 'thrusterFiringDataCadenceSeconds'; '>= 0'; []; []};    
else
    fieldsAndBounds(1,:)  = { 'mnemonics'; []; []; {}};
    fieldsAndBounds(2,:)  = { 'modelOrders'; []; []; []};                   % May be empty; can't validate against bounds
    fieldsAndBounds(3,:)  = { 'interactions'; []; []; {}};
    fieldsAndBounds(4,:)  = { 'quantizationLevels'; []; []; []};            % May be empty; can't validate against bounds
    fieldsAndBounds(5,:)  = { 'intrinsicUncertainties'; []; []; []};        % May be empty; can't validate against bounds
    fieldsAndBounds(6,:)  = { 'thrusterFiringDataCadenceSeconds'; '>= 0'; []; []};    
end

validate_structure(paDataStruct.thrusterDataAncillaryEngineeringConfigurationStruct, fieldsAndBounds, ...
    'paDataStruct.thrusterDataAncillaryEngineeringConfigurationStruct');

clear fieldsAndBounds;
    
%--------------------------------------------------------------------------
% Second level validation.
% Validate the structure field paDataStruct.ancillaryPipelineConfigurationStruct
% if there is ancillary pipeline data.
%--------------------------------------------------------------------------
if ~isempty(paDataStruct.ancillaryPipelineDataStruct)
    
    fieldsAndBounds = cell(3,4);
    fieldsAndBounds(1,:)  = { 'mnemonics'; []; []; {}};
    fieldsAndBounds(2,:)  = { 'modelOrders'; '>= 0'; '<= 5'; []};
    fieldsAndBounds(3,:)  = { 'interactions'; []; []; {}};

    validate_structure(paDataStruct.ancillaryPipelineConfigurationStruct, fieldsAndBounds, ...
        'paDataStruct.ancillaryPipelineConfigurationStruct');

    clear fieldsAndBounds;
    
end

%--------------------------------------------------------------------------
% Second level validation.
% Validate the structure field paDataStruct.ancillaryDesignMatrixConfigurationStruct.
%--------------------------------------------------------------------------
fieldsAndBounds = cell(4,4);
fieldsAndBounds(1,:)  = { 'filteringEnabled'; []; []; [true; false]};
fieldsAndBounds(2,:)  = { 'sgPolyOrders'; '>= 1'; '<= 4'; []};
fieldsAndBounds(3,:)  = { 'sgFrameSizes'; '> 4'; '< 10000'; []};
fieldsAndBounds(4,:)  = { 'bandpassFlags'; []; []; [true; false]};

validate_structure(paDataStruct.ancillaryDesignMatrixConfigurationStruct, fieldsAndBounds, ...
    'paDataStruct.ancillaryDesignMatrixConfigurationStruct');

clear fieldsAndBounds;

%--------------------------------------------------------------------------
% Second level validation.
% Validate the structure field paDataStruct.backgroundConfigurationStruct.
%--------------------------------------------------------------------------
fieldsAndBounds = cell(4,4);
fieldsAndBounds(1,:)  = { 'aicOrderSelectionEnabled'; []; []; [true; false]};
fieldsAndBounds(2,:)  = { 'fitMaxOrder'; '>= 0'; '<= 8'; []};
fieldsAndBounds(3,:)  = { 'fitOrder'; '>= 0'; '<= 8'; []};
fieldsAndBounds(4,:)  = { 'fitMinPoints'; '>= 10'; '< 1000'; []};

validate_structure(paDataStruct.backgroundConfigurationStruct, fieldsAndBounds, ...
    'paDataStruct.backgroundConfigurationStruct');

clear fieldsAndBounds;

%--------------------------------------------------------------------------
% Second level validation.
% Validate the structure field paDataStruct.motionConfigurationStruct.
%--------------------------------------------------------------------------
fieldsAndBounds = cell(6,4);
fieldsAndBounds(1,:)  = { 'aicOrderSelectionEnabled'; []; []; [true; false]};
fieldsAndBounds(2,:)  = { 'fitMaxOrder'; '>= 0'; '<= 8'; []};
fieldsAndBounds(3,:)  = { 'rowFitOrder'; '>= 0'; '<= 8'; []};
fieldsAndBounds(4,:)  = { 'columnFitOrder'; '>= 0'; '<= 8'; []};
fieldsAndBounds(5,:)  = { 'fitMinPoints'; '>= 5'; '< 200'; []};
fieldsAndBounds(6,:)  = { 'k2PpaTargetRejectionEnabled'; []; []; [true; false]};
    
validate_structure(paDataStruct.motionConfigurationStruct, fieldsAndBounds, ...
    'paDataStruct.motionConfigurationStruct');

clear fieldsAndBounds;

%--------------------------------------------------------------------------
% Second level validation.
% Validate the structure field paDataStruct.cosmicRayConfigurationStruct.
%--------------------------------------------------------------------------
fieldsAndBounds = paCosmicRayCleanerClass.get_config_struct_fields_and_bounds();
validate_structure(paDataStruct.cosmicRayConfigurationStruct, ...
    fieldsAndBounds, 'paDataStruct.cosmicRayConfigurationStruct');

clear fieldsAndBounds;

%--------------------------------------------------------------------------
% Second level validation.
% Validate the structure field paDataStruct.apertureModelConfigurationStruct.
%--------------------------------------------------------------------------
fieldsAndBounds = apertureModelClass.get_config_struct_fields_and_bounds();
validate_structure(paDataStruct.apertureModelConfigurationStruct, ...
    fieldsAndBounds, 'paDataStruct.apertureModelConfigurationStruct');

clear fieldsAndBounds;

%--------------------------------------------------------------------------
% Second level validation.
% Validate the structure field paDataStruct.harmonicsIdentificationConfigurationStruct.
%--------------------------------------------------------------------------
fieldsAndBounds = cell(7,4);
fieldsAndBounds(1,:)  = { 'medianWindowLengthForTimeSeriesSmoothing';  '>= 1'; [];         []};   
fieldsAndBounds(2,:)  = { 'medianWindowLengthForPeriodogramSmoothing'; '>= 1'; [];         []};  
fieldsAndBounds(3,:)  = { 'movingAverageWindowLength';                 '>= 1'; [];         []};                  
fieldsAndBounds(4,:)  = { 'falseDetectionProbabilityForTimeSeries';    '> 0';  '< 1';      []};   
fieldsAndBounds(5,:)  = { 'minHarmonicSeparationInBins';               '>= 1'; '<= 1000';  []};         
fieldsAndBounds(6,:)  = { 'maxHarmonicComponents';                     '>= 1'; '<= 10000'; []};              
fieldsAndBounds(7,:)  = { 'timeOutInMinutes';                          '> 0';  '<= 180';   []};                      

validate_structure(paDataStruct.harmonicsIdentificationConfigurationStruct, ...
    fieldsAndBounds, 'paDataStruct.harmonicsIdentificationConfigurationStruct');

clear fieldsAndBounds;

%--------------------------------------------------------------------------
% Second level validation.
% Validate the structure field paDataStruct.encircledEnergyConfigurationStruct.
%--------------------------------------------------------------------------
fieldsAndBounds = cell(13,4);
fieldsAndBounds(1,:)  = { 'fluxFraction'; '>0'; '<1'; []};
fieldsAndBounds(2,:)  = { 'polyOrder'; '>-2'; []; []};
fieldsAndBounds(3,:)  = { 'maxPolyOrder'; '>0'; []; []};
fieldsAndBounds(4,:)  = { 'maxTargets'; '>0'; []; []};
fieldsAndBounds(5,:)  = { 'maxPixels'; '>0'; []; []};
fieldsAndBounds(6,:)  = { 'maxRadius'; '>=0'; []; []};
fieldsAndBounds(7,:)  = { 'seedRadius'; '>0'; '<1'; []};
fieldsAndBounds(8,:)  = { 'aicFraction'; '>0'; '<=1'; []};
fieldsAndBounds(9,:)  = { 'targetLabel'; []; []; {}};
fieldsAndBounds(10,:) = { 'targetPolyOrder'; '>0'; []; []};
fieldsAndBounds(11,:) = { 'robustThreshold'; []; []; []};
fieldsAndBounds(12,:) = { 'robustLimitEnabled'; []; []; [true; false]};
fieldsAndBounds(13,:) = { 'plotsEnabled'; []; []; [true; false]};

validate_structure(paDataStruct.encircledEnergyConfigurationStruct, fieldsAndBounds, ...
    'paDataStruct.encircledEnergyConfigurationStruct');

clear fieldsAndBounds;

%--------------------------------------------------------------------------
% Second level validation.
% Validate the structure field paDataStruct.gapFillConfigurationStruct.
%--------------------------------------------------------------------------
fieldsAndBounds = cell(10,4);
fieldsAndBounds(1,:)  = { 'madXFactor'; '> 0'; '<= 100'; []};
fieldsAndBounds(2,:)  = { 'maxGiantTransitDurationInHours'; '> 0'; '< 5*24'; []};
fieldsAndBounds(3,:)  = { 'giantTransitPolyFitChunkLengthInHours'; '> 0'; '< 24*30'; []};
fieldsAndBounds(4,:)  = { 'maxDetrendPolyOrder'; '>= 1'; '<= 100'; []};
fieldsAndBounds(5,:)  = { 'maxArOrderLimit'; '>= 1'; '<= 100'; []};
fieldsAndBounds(6,:)  = { 'maxCorrelationWindowXFactor'; '>= 1'; '<= 100'; []};
fieldsAndBounds(7,:)  = { 'gapFillModeIsAddBackPredictionError'; []; []; [true; false]};
fieldsAndBounds(8,:)  = { 'removeEclipsingBinariesOnList'; []; []; [true; false]};
fieldsAndBounds(9,:)  = { 'waveletFamily'; []; []; {'haar'; 'daub'; 'morlet'; 'coiflet'; ...
    'meyer'; 'gauss'; 'mexhat'}};
fieldsAndBounds(10,:) = { 'waveletFilterLength'; []; []; '[2:2:128]'''};

validate_structure(paDataStruct.gapFillConfigurationStruct, fieldsAndBounds, ...
    'paDataStruct.gapFillConfigurationStruct');

clear fieldsAndBounds;

%--------------------------------------------------------------------------
% Second level validation.
% Validate the structure field paDataStruct.pouConfigurationStruct.
%--------------------------------------------------------------------------
fieldsAndBounds = cell(8,4);
fieldsAndBounds(1,:)  = { 'pouEnabled'; []; []; [true; false]};
fieldsAndBounds(2,:)  = { 'compressionEnabled'; []; []; [true; false]};
fieldsAndBounds(3,:)  = { 'pixelChunkSize'; '>= 1132'; '< 10500'; []};
fieldsAndBounds(4,:)  = { 'cadenceChunkSize'; '>= 3'; '< 1000'; []};
fieldsAndBounds(5,:)  = { 'interpDecimation'; '>= 1'; '< 100'; []};
fieldsAndBounds(6,:)  = { 'interpMethod'; []; []; {'nearest'; 'linear'; ...
    'spline'; 'pchip'; 'cubic'; 'v5cubic'}};
fieldsAndBounds(7,:)  = { 'numErrorPropVars'; '>= 1'; '<= 30'; []};
fieldsAndBounds(8,:)  = { 'maxSvdOrder'; '>= 1'; '<= 25'; []};

validate_structure(paDataStruct.pouConfigurationStruct, fieldsAndBounds, ...
    'paDataStruct.pouConfigurationStruct');

clear fieldsAndBounds;

%--------------------------------------------------------------------------
% Second level validation.
% Validate the structure field paDataStruct.saturationSegmentConfigurationStruct.
%--------------------------------------------------------------------------
fieldsAndBounds = cell(5,4);
fieldsAndBounds(1,:)  = { 'sgPolyOrder'; '>= 2'; '<= 24'; []};
fieldsAndBounds(2,:)  = { 'sgFrameSize'; '>= 25'; '< 10000'; []};
fieldsAndBounds(3,:)  = { 'satSegThreshold'; '> 0'; '<= 1e6'; []};
fieldsAndBounds(4,:)  = { 'satSegExclusionZone'; '>= 1'; '<= 10000'; []};
fieldsAndBounds(5,:)  = { 'maxSaturationMagnitude'; '>= 6'; '<= 15'; []};

validate_structure(paDataStruct.saturationSegmentConfigurationStruct, ...
    fieldsAndBounds, 'paDataStruct.saturationSegmentConfigurationStruct');

clear fieldsAndBounds;

%--------------------------------------------------------------------------
% Second level validation.
% Validate the structure field paDataStruct.argabrighteningConfigurationStruct.
%--------------------------------------------------------------------------
fieldsAndBounds = cell(4,4);
fieldsAndBounds(1,:)  = { 'mitigationEnabled'; []; []; [true; false]};
fieldsAndBounds(2,:)  = { 'fitOrder'; '>= 1'; '<= 4'; []};
fieldsAndBounds(3,:)  = { 'medianFilterLength'; '>= 5'; '< 200'; []};
fieldsAndBounds(4,:)  = { 'madThreshold'; '> 0'; '<= 1e6'; []};

validate_structure(paDataStruct.argabrighteningConfigurationStruct, ...
    fieldsAndBounds, 'paDataStruct.argabrighteningConfigurationStruct');

clear fieldsAndBounds;

%--------------------------------------------------------------------------
% Second level validation.
% Validate the structure field paDataStruct.ancillaryEngineeringDataStruct if it exists.
%--------------------------------------------------------------------------
if ~isempty(paDataStruct.ancillaryEngineeringDataStruct)
    
    fieldsAndBounds = cell(3,4);
    fieldsAndBounds(1,:)  = { 'mnemonic'; []; []; {}};
    fieldsAndBounds(2,:)  = { 'timestamps'; '> 54500'; '< 70000'; []};   % 2/4/2008 to 7/13/2050
    fieldsAndBounds(3,:)  = { 'values'; []; []; []};                     % TBD

    nStructures = length(paDataStruct.ancillaryEngineeringDataStruct);

    for i = 1 : nStructures
        validate_structure(paDataStruct.ancillaryEngineeringDataStruct(i), ...
            fieldsAndBounds, 'paDataStruct.ancillaryEngineeringDataStruct()');
    end
    
    clear fieldsAndBounds;

end % if

%--------------------------------------------------------------------------
% Second level validation.
% Validate the structure field paDataStruct.ancillaryPipelineDataStruct if it exists.
%--------------------------------------------------------------------------
if ~isempty(paDataStruct.ancillaryPipelineDataStruct)
    
    fieldsAndBounds = cell(4,4);
    fieldsAndBounds(1,:)  = { 'mnemonic'; []; []; {}};
    fieldsAndBounds(2,:)  = { 'timestamps'; '> 54500'; '< 70000'; []};   % 2/4/2008 to 7/13/2050
    fieldsAndBounds(3,:)  = { 'values'; []; []; []};                     % TBD
    fieldsAndBounds(4,:)  = { 'uncertainties'; '>= 0'; []; []};          % TBD

    nStructures = length(paDataStruct.ancillaryPipelineDataStruct);

    for i = 1 : nStructures
        validate_structure(paDataStruct.ancillaryPipelineDataStruct(i), ...
            fieldsAndBounds, 'paDataStruct.ancillaryPipelineDataStruct()');
    end
    
    clear fieldsAndBounds;

end % if

%--------------------------------------------------------------------------
% Second level validation.
% Validate the structure field paDataStruct.backgroundDataStruct if it exists.
%--------------------------------------------------------------------------
if ~isempty(paDataStruct.backgroundDataStruct)
    
    fieldsAndBounds = cell(6,4);
    fieldsAndBounds(1,:)  = { 'ccdRow'; '>= 0'; '< 1070'; []};
    fieldsAndBounds(2,:)  = { 'ccdColumn'; '>= 0'; '< 1132'; []};
    fieldsAndBounds(3,:)  = { 'inOptimalAperture'; []; []; [true; false]};
    fieldsAndBounds(4,:)  = { 'values'; '> -1e7'; '< 1e9'; []};
    fieldsAndBounds(5,:)  = { 'uncertainties'; '>= 0'; '< 1e5'; []};
    fieldsAndBounds(6,:)  = { 'gapIndicators'; []; []; [true; false]};
        
    nStructures = length(paDataStruct.backgroundDataStruct);

    warningInsteadOfErrorFlag = true;
    for i = 1 : nStructures
        validate_structure(paDataStruct.backgroundDataStruct(i), ...
            fieldsAndBounds, 'paDataStruct.backgroundDataStruct()', ...
            warningInsteadOfErrorFlag);
    end
    
    clear fieldsAndBounds;

end % if

%--------------------------------------------------------------------------
% Second level validation.
% Validate the structure field paDataStruct.targetStarDataStruct if it exists.
%--------------------------------------------------------------------------
if ~isempty(paDataStruct.targetStarDataStruct)
    
    fieldsAndBounds = cell(11,4);
    fieldsAndBounds(1,:)  = { 'keplerId'; '> 0'; '< 1e9'; []};
    fieldsAndBounds(2,:)  = { 'labels'; []; []; {}};
    fieldsAndBounds(3,:)  = { 'raHours'; '>= 0'; '< 24'; []};
    fieldsAndBounds(4,:)  = { 'decDegrees'; '>= -90'; '<= 90'; []};
    fieldsAndBounds(5,:)  = { 'keplerMag'; '>= 0'; '<= 30'; []};
    fieldsAndBounds(6,:)  = { 'fluxFractionInAperture'; '>= 0'; '<= 1'; []};
    fieldsAndBounds(7,:)  = { 'referenceRow'; '>= 0'; '< 1070'; []};
    fieldsAndBounds(8,:)  = { 'referenceColumn'; '>= 0'; '< 1132'; []};
    fieldsAndBounds(9,:)  = { 'pixelDataStruct'; []; []; []};
    fieldsAndBounds(10,:) = { 'rmsCdppStruct'; []; []; []};
    fieldsAndBounds(11,:) = { 'kics'; []; []; []};

    nStructures = length(paDataStruct.targetStarDataStruct);

    for i = 1 : nStructures
        
        targetStruct = paDataStruct.targetStarDataStruct(i);

        % Allow custom targets w/ra/dec/mag == NaN to pass through validator. Set mag = CUSTOM_TARGET_DEFAULT_MAG
        if isfield(targetStruct,'keplerId') && is_valid_id(targetStruct.keplerId,'custom')
            
            if isfield(targetStruct, 'raHours') && isnan(targetStruct.raHours)
                targetStruct.raHours = 0;
            end

            if isfield(targetStruct, 'decDegrees') && isnan(targetStruct.decDegrees)
                targetStruct.decDegrees = 0;
            end

            if isfield(targetStruct, 'keplerMag') && isnan(targetStruct.keplerMag)
                targetStruct.keplerMag = CUSTOM_TARGET_DEFAULT_MAG;
            end
        end
            
        % Allow any non-PPA_STELLAR target w/mag == NaN to pass through validator. Set mag = CUSTOM_TARGET_DEFAULT_MAG        
        if isfield(targetStruct, 'labels') && ~ismember(PPA_STELLAR_LABEL, targetStruct.labels)
            
            if isfield(targetStruct, 'keplerMag') && isnan(targetStruct.keplerMag)
                targetStruct.keplerMag = CUSTOM_TARGET_DEFAULT_MAG;
            end           
            
        end
        
        validate_structure(targetStruct, fieldsAndBounds, 'paDataStruct.targetStarDataStruct()');

    end
    
    clear fieldsAndBounds;

end % if


%--------------------------------------------------------------------------
% Second level validation.
% Validate the structure field paDataStruct.prfModel.
%--------------------------------------------------------------------------


%--------------------------------------------------------------------------
% Second level validation.
% Validate the structure field paDataStruct.rollingBandArtifactFlags if it
% exists.
%--------------------------------------------------------------------------
if ~isempty(paDataStruct.rollingBandArtifactFlags)
    
    fieldsAndBounds = cell(3,4);
    fieldsAndBounds(1,:)  = { 'row'; '>= 0'; '< 1070'; []};
    fieldsAndBounds(2,:)  = { 'testPulseDurationLc'; '>'; '<= 48'; []};
    fieldsAndBounds(3,:)  = { 'flags'; []; []; []};
        
    nStructures = length(paDataStruct.backgroundDataStruct);

    for i = 1 : nStructures
        validate_structure(paDataStruct.rollingBandArtifactFlags(i), ...
            fieldsAndBounds, 'paDataStruct.rollingBandArtifactFlags()');
    end
    
    clear fieldsAndBounds;

end % if

%--------------------------------------------------------------------------
% Second level validation.
% Validate the structure field paDataStruct.backgroundPolyStruct if it
% exists.
%--------------------------------------------------------------------------
if ~isempty(paDataStruct.backgroundPolyStruct)
    
    fieldsAndBounds = cell(8,4);
    fieldsAndBounds(1,:)  = { 'cadence'; '>= 0'; '< 2e7'; []};
    fieldsAndBounds(2,:)  = { 'mjdStartTime'; '> 54500'; '< 70000'; []}; % 2/4/2008 to 7/13/2050
    fieldsAndBounds(3,:)  = { 'mjdMidTime'; '> 54500'; '< 70000'; []}; % 2/4/2008 to 7/13/2050
    fieldsAndBounds(4,:)  = { 'mjdEndTime'; '> 54500'; '< 70000'; []}; % 2/4/2008 to 7/13/2050
    fieldsAndBounds(5,:)  = { 'module'; []; []; '[2:4, 6:20, 22:24]'''};
    fieldsAndBounds(6,:)  = { 'output'; []; []; '[1 2 3 4]'''};
    fieldsAndBounds(7,:)  = { 'backgroundPoly'; []; []; []};
    fieldsAndBounds(8,:)  = { 'backgroundPolyStatus'; []; []; '[0:1]'''};
    
    backgroundPolyStruct = paDataStruct.backgroundPolyStruct;
    backgroundPolyGapIndicators = ...
        ~logical([backgroundPolyStruct.backgroundPolyStatus]');
    backgroundPolyStruct = backgroundPolyStruct(~backgroundPolyGapIndicators);
    
    nStructures = length(backgroundPolyStruct);

    for i = 1 : nStructures
        validate_structure(backgroundPolyStruct(i), fieldsAndBounds, ...
            'paDataStruct.backgroundPolyStruct()');
    end
    
    clear fieldsAndBounds;

end % if

%--------------------------------------------------------------------------
% Second level validation.
% Validate the structure field paDataStruct.motionPolyStruct if it
% exists.
%--------------------------------------------------------------------------
if ~isempty(paDataStruct.motionPolyStruct)
    
    fieldsAndBounds = cell(10,4);
    fieldsAndBounds(1,:)  = { 'cadence'; '>= 0'; '< 2e7'; []};
    fieldsAndBounds(2,:)  = { 'mjdStartTime'; '> 54500'; '< 70000'; []}; % 2/4/2008 to 7/13/2050
    fieldsAndBounds(3,:)  = { 'mjdMidTime'; '> 54500'; '< 70000'; []}; % 2/4/2008 to 7/13/2050
    fieldsAndBounds(4,:)  = { 'mjdEndTime'; '> 54500'; '< 70000'; []}; % 2/4/2008 to 7/13/2050
    fieldsAndBounds(5,:)  = { 'module'; []; []; '[2:4, 6:20, 22:24]'''};
    fieldsAndBounds(6,:)  = { 'output'; []; []; '[1 2 3 4]'''};
    fieldsAndBounds(7,:)  = { 'rowPoly'; []; []; []};
    fieldsAndBounds(8,:)  = { 'rowPolyStatus'; []; []; '[0:1]'''};
    fieldsAndBounds(9,:)  = { 'colPoly'; []; []; []};
    fieldsAndBounds(10,:) = { 'colPolyStatus'; []; []; '[0:1]'''};
    
    motionPolyStruct = paDataStruct.motionPolyStruct;
    motionPolyGapIndicators = ...
        ~logical([motionPolyStruct.rowPolyStatus]');
    motionPolyStruct = motionPolyStruct(~motionPolyGapIndicators);
    
    nStructures = length(motionPolyStruct);

    for i = 1 : nStructures
        validate_structure(motionPolyStruct(i), fieldsAndBounds, ...
            'paDataStruct.motionPolyStruct()');
    end
    
    clear fieldsAndBounds;

end % if

%--------------------------------------------------------------------------
% Third level validation.
% Validate the structure field paDataStruct.targetStarDataStruct().pixelDataStruct
% if it exists.
%--------------------------------------------------------------------------
if ~isempty(paDataStruct.targetStarDataStruct)
    
    fieldsAndBounds = cell(6,4);
    fieldsAndBounds(1,:)  = { 'ccdRow'; '>= 0'; '< 1070'; []};
    fieldsAndBounds(2,:)  = { 'ccdColumn'; '>= 0'; '< 1132'; []};
    fieldsAndBounds(3,:)  = { 'inOptimalAperture'; []; []; [true; false]};
    fieldsAndBounds(4,:)  = { 'values'; '> -1e7'; '< 1e9'; []};
    fieldsAndBounds(5,:)  = { 'uncertainties'; '>= 0'; '< 1e5'; []};
    fieldsAndBounds(6,:)  = { 'gapIndicators'; []; []; [true; false]};

    nTargets = length(paDataStruct.targetStarDataStruct);

    warningInsteadOfErrorFlag = true;
    for i = 1 : nTargets
        nStructures = length(paDataStruct.targetStarDataStruct(i).pixelDataStruct);
        for j = 1 : nStructures
            validate_structure(paDataStruct.targetStarDataStruct(i).pixelDataStruct(j), ...
                fieldsAndBounds, ['paDataStruct.targetStarDataStruct(',num2str(i),').pixelDataStruct()'], ...
                warningInsteadOfErrorFlag);
        end
    end

    clear fieldsAndBounds;

end % if

%--------------------------------------------------------------------------
% Third level validation.
% Validate the structure field paDataStruct.targetStarDataStruct().rmsCdppStruct
% if it exists.
%--------------------------------------------------------------------------
if ~isempty(paDataStruct.targetStarDataStruct)
   
    fieldsAndBounds = cell(2,4);
    fieldsAndBounds(1,:)  = { 'trialTransitPulseInHours'; '>= 0.5'; '<= 100'; []};
    fieldsAndBounds(2,:)  = { 'rmsCdpp'; '> 0'; '< 1000000'; []};

    nTargets = length(paDataStruct.targetStarDataStruct);
    warningInsteadOfErrorFlag = true;
    for i = 1 : nTargets        
        % if rmsCdpp and trialTransitPulseInHours not available rmsCdppStruct is empty
        if ~isempty(paDataStruct.targetStarDataStruct(i).rmsCdppStruct)
            nStructures = length(paDataStruct.targetStarDataStruct(i).rmsCdppStruct);
            for j = 1 : nStructures  
                validate_structure(paDataStruct.targetStarDataStruct(i).rmsCdppStruct(j), ...
                    fieldsAndBounds, ['paDataStruct.targetStarDataStruct(',num2str(i),').rmsCdppStruct(',num2str(j),')'], ...
                    warningInsteadOfErrorFlag);                
            end
        end
    end

    clear fieldsAndBounds;

end % if

%--------------------------------------------------------------------------
% Third level validation.
% Validate the structure field paDataStruct.rollingBandArtifactFlags().flags
% if it exists.
%--------------------------------------------------------------------------
if ~isempty(paDataStruct.rollingBandArtifactFlags)
    
    fieldsAndBounds = cell(2,4);
    fieldsAndBounds(1,:)  = { 'values'; '>= 0'; '< 16'; []};
    fieldsAndBounds(2,:)  = { 'gapIndicators'; []; []; [true; false]};

    nStructures = length(paDataStruct.rollingBandArtifactFlags);

    for i = 1 : nStructures
        validate_structure(paDataStruct.rollingBandArtifactFlags(i).flags, ...
            fieldsAndBounds, 'paDataStruct.rollingBandArtifactFlags().flags');
    end

    clear fieldsAndBounds;

end % if

%--------------------------------------------------------------------------
% Third level validation.
% Validate the structure field paDataStruct.backgroundPolyStruct().backgroundPoly
% if it exists.
%--------------------------------------------------------------------------
if ~isempty(paDataStruct.backgroundPolyStruct)
    
    fieldsAndBounds = cell(13,4);
    fieldsAndBounds(1,:)  = { 'offsetx'; []; []; '0'};
    fieldsAndBounds(2,:)  = { 'scalex'; '>= 0'; []; []};
    fieldsAndBounds(3,:)  = { 'originx'; []; []; []};
    fieldsAndBounds(4,:)  = { 'offsety'; []; []; '0'};
    fieldsAndBounds(5,:)  = { 'scaley'; '>= 0'; []; []};
    fieldsAndBounds(6,:)  = { 'originy'; []; []; []};
    fieldsAndBounds(7,:)  = { 'xindex'; []; []; '-1'};
    fieldsAndBounds(8,:)  = { 'yindex'; []; []; '-1'};
    fieldsAndBounds(9,:)  = { 'type'; []; []; {'standard'}};
    fieldsAndBounds(10,:) = { 'order'; '>= 0'; '< 10'; []};
    fieldsAndBounds(11,:) = { 'message'; []; []; {}};
    fieldsAndBounds(12,:) = { 'coeffs'; []; []; []};                % TBD
    fieldsAndBounds(13,:) = { 'covariance'; []; []; []};            % TBD
        
    nStructures = length(backgroundPolyStruct);

    for i = 1 : nStructures
        validate_structure(backgroundPolyStruct(i).backgroundPoly, ...
            fieldsAndBounds, 'paDataStruct.backgroundPolyStruct().backgroundPoly');
    end
    
    clear fieldsAndBounds;

end % if

%--------------------------------------------------------------------------
% Third level validation.
% Validate the structure field paDataStruct.motionPolyStruct().rowPoly
% if it exists.
%--------------------------------------------------------------------------
if ~isempty(paDataStruct.motionPolyStruct)
    
    fieldsAndBounds = cell(13,4);
    fieldsAndBounds(1,:)  = { 'offsetx'; []; []; '0'};
    fieldsAndBounds(2,:)  = { 'scalex'; '>= 0'; []; []};
    fieldsAndBounds(3,:)  = { 'originx'; []; []; []};
    fieldsAndBounds(4,:)  = { 'offsety'; []; []; '0'};
    fieldsAndBounds(5,:)  = { 'scaley'; '>= 0'; []; []};
    fieldsAndBounds(6,:)  = { 'originy'; []; []; []};
    fieldsAndBounds(7,:)  = { 'xindex'; []; []; '-1'};
    fieldsAndBounds(8,:)  = { 'yindex'; []; []; '-1'};
    fieldsAndBounds(9,:)  = { 'type'; []; []; {'standard'}};
    fieldsAndBounds(10,:) = { 'order'; '>= 0'; '< 10'; []};
    fieldsAndBounds(11,:) = { 'message'; []; []; {}};
    fieldsAndBounds(12,:) = { 'coeffs'; []; []; []};                % TBD
    fieldsAndBounds(13,:) = { 'covariance'; []; []; []};            % TBD
        
    nStructures = length(motionPolyStruct);

    for i = 1 : nStructures
        validate_structure(motionPolyStruct(i).rowPoly, ...
            fieldsAndBounds, 'paDataStruct.motionPolyStruct().rowPoly');
    end
    
    clear fieldsAndBounds;

end % if

%--------------------------------------------------------------------------
% Third level validation.
% Validate the structure field paDataStruct.motionPolyStruct().colPoly
% if it exists.
%--------------------------------------------------------------------------
if ~isempty(paDataStruct.motionPolyStruct)
    
    fieldsAndBounds = cell(13,4);
    fieldsAndBounds(1,:)  = { 'offsetx'; []; []; '0'};
    fieldsAndBounds(2,:)  = { 'scalex'; '>= 0'; []; []};
    fieldsAndBounds(3,:)  = { 'originx'; []; []; []};
    fieldsAndBounds(4,:)  = { 'offsety'; []; []; '0'};
    fieldsAndBounds(5,:)  = { 'scaley'; '>= 0'; []; []};
    fieldsAndBounds(6,:)  = { 'originy'; []; []; []};
    fieldsAndBounds(7,:)  = { 'xindex'; []; []; '-1'};
    fieldsAndBounds(8,:)  = { 'yindex'; []; []; '-1'};
    fieldsAndBounds(9,:)  = { 'type'; []; []; {'standard'}};
    fieldsAndBounds(10,:) = { 'order'; '>= 0'; '< 10'; []};
    fieldsAndBounds(11,:) = { 'message'; []; []; {}};
    fieldsAndBounds(12,:) = { 'coeffs'; []; []; []};                % TBD
    fieldsAndBounds(13,:) = { 'covariance'; []; []; []};            % TBD
        
    nStructures = length(motionPolyStruct);

    for i = 1 : nStructures
        validate_structure(motionPolyStruct(i).colPoly, ...
            fieldsAndBounds, 'paDataStruct.motionPolyStruct().colPoly');
    end
    
    clear fieldsAndBounds;

end % if

%--------------------------------------------------------------------------
% Third level validation.
% Validate the structure field paDataStruct.targetStarDataStruct().kics 
% if it exists.
%--------------------------------------------------------------------------
if ~isempty(paDataStruct.targetStarDataStruct)
    
    % Validate that the needed fields exist and contain
    % struct('value',[],'uncertainty,[]) Note that the existence of
    % targetStarDataStruct.kics was previously established.
    
    fieldsAndBounds = cell(4,4);
    fieldsAndBounds(1,:)  = { 'keplerId';  []; []; []};
    fieldsAndBounds(2,:)  = { 'ra';        []; []; []};
    fieldsAndBounds(3,:)  = { 'dec';       []; []; []};
    fieldsAndBounds(4,:)  = { 'keplerMag'; []; []; []};

    fieldsAndBounds2 = cell(2,4);
    fieldsAndBounds2(1,:)  = { 'value';       []; []; []};
    fieldsAndBounds2(2,:)  = { 'uncertainty'; []; []; []};

    nTargets = length(paDataStruct.targetStarDataStruct);
    for iTarget = 1 : nTargets
        
        nStructures = length(paDataStruct.targetStarDataStruct(iTarget).kics);
        for iStruct = 1 : nStructures
            kicsStruct = paDataStruct.targetStarDataStruct(iTarget).kics(iStruct);
            validate_structure(kicsStruct, fieldsAndBounds, ...
                ['paDataStruct.targetStarDataStruct(',num2str(iTarget),').kics()']);
 
            fieldList = fieldnames(paDataStruct.targetStarDataStruct(iTarget).kics);
            nFields   = length(fieldList);
            for iField = 1:nFields        
                if ~ismember(fieldList{iField},{'keplerId','skyGroupId'})
                    validate_structure( ...
                        paDataStruct.targetStarDataStruct(iTarget).kics(iStruct).(fieldList{iField}), ...
                        fieldsAndBounds2, ...
                        ['paDataStruct.targetStarDataStruct(', ...
                          num2str(iTarget),').kics(',num2str(iStruct),').', ...
                          fieldList{iField}] ...
                    );                
                end
            end
        end 
    end
    
    clear fieldsAndBounds fieldsAndBounds2;

end % if


% Return.
return
