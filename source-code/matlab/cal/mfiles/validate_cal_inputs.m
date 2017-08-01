function [calInputStruct] = validate_cal_inputs(calInputStruct)
% function [calInputStruct] = validate_cal_inputs(calInputStruct)
%
% This method checks for the presence of expected fields in the input structure, then checks whether each parameter is within the appropriate range.
% An error will result if any of the required pixel types for each invocation are either empty structs or all gapped.
%
%--------------------------------------------------------------------------
% validate inputs and check fields and bounds
% (1) check for the presence of all fields
% (2) check whether the parameters are within bounds and are not NaNs/Infs
%
% Note: if fields are structures, make sure their bounds are empty
%
% Comments: This function generates an error under the following scenarios:
%          (1) when invoked with no inputs
%          (2) when any of the essential fields are missing
%          (3) when any of the fields are NaNs/Infs or outside the appropriate bounds
%
%
% If calinputStruct.processFFI flag is enabled, the photometric pixel validation will be skipped over.
%--------------------------------------------------------------------------
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

% start clock
tic;
metricsKey = metrics_interval_start;

% ensure there is a debugLevel field
if ~isfield(calInputStruct, 'debugLevel')
    calInputStruct.debugLevel = 0;
end

% extract data flags
firstCall                   = calInputStruct.firstCall;
processShortCadence         = calInputStruct.dataFlags.processShortCadence;
processLongCadence          = calInputStruct.dataFlags.processLongCadence;
processFFI                  = calInputStruct.dataFlags.processFFI;
isAvailableBlackPix         = calInputStruct.dataFlags.isAvailableBlackPix;
isAvailableMaskedBlackPix   = calInputStruct.dataFlags.isAvailableMaskedBlackPix;
isAvailableVirtualBlackPix  = calInputStruct.dataFlags.isAvailableVirtualBlackPix;
isAvailableMaskedSmearPix   = calInputStruct.dataFlags.isAvailableMaskedSmearPix;
isAvailableVirtualSmearPix  = calInputStruct.dataFlags.isAvailableVirtualSmearPix;
isAvailableTargetAndBkgPix  = calInputStruct.dataFlags.isAvailableTargetAndBkgPix;
isAvailableTwoDCollateral   = calInputStruct.dataFlags.isAvailableTwoDCollateral;                   %#ok<NASGU>
isK2UnitOfWork              = calInputStruct.dataFlags.isK2UnitOfWork;

% must use these flags before they are validated in order to set gaps correctly
errorOnCoarsePointFfi       = calInputStruct.moduleParametersStruct.errorOnCoarsePointFfi;
enableMmntmDmpFlag          = calInputStruct.moduleParametersStruct.enableMmntmDmpFlag;
enableSefiAccFlag           = calInputStruct.moduleParametersStruct.enableSefiAccFlag;
enableSefiCadFlag           = calInputStruct.moduleParametersStruct.enableSefiCadFlag;
enableLdeOosFlag            = calInputStruct.moduleParametersStruct.enableLdeOosFlag;
enableLdeParErFlag          = calInputStruct.moduleParametersStruct.enableLdeParErFlag;
enableScrcErrFlag           = calInputStruct.moduleParametersStruct.enableScrcErrFlag;
enableCoarsePointProcessing = calInputStruct.moduleParametersStruct.enableCoarsePointProcessing;
enableSmearExcludeColumnMap = calInputStruct.moduleParametersStruct.enableSmearExcludeColumnMap;
enableExcludeIndicators     = calInputStruct.moduleParametersStruct.enableExcludeIndicators;
enableExcludePreserve       = calInputStruct.moduleParametersStruct.enableExcludePreserve;

%--------------------------------------------------------------------------
% get bleeding smear columns gaps
%--------------------------------------------------------------------------
ccdModule   = calInputStruct.ccdModule;
ccdOutput   = calInputStruct.ccdOutput;
ccdChannel  = convert_from_module_output(ccdModule,ccdOutput);
season      = calInputStruct.season;
campaign    = calInputStruct.k2Campaign;

% load columns to exclude from file or set to empty
if enableSmearExcludeColumnMap
    if isK2UnitOfWork
        mSmearBleedingCols = get_masked_smear_columns_to_exclude_K2(campaign, ccdChannel) - 1;
        vSmearBleedingCols = get_virtual_smear_columns_to_exclude_K2(campaign, ccdChannel) - 1;                
    else
        mSmearBleedingCols = get_masked_smear_columns_to_exclude(season, ccdChannel) - 1;
        vSmearBleedingCols = get_virtual_smear_columns_to_exclude(season, ccdChannel) - 1;
    end
else
    mSmearBleedingCols = [];
    vSmearBleedingCols = [];
end


%--------------------------------------------------------------------------
% update all gap information for cadences in which:
%
% (1) momentum dump occurred during accumulation (isMmntmDmp = T)
% (2) spacecraft is not in fine point (isFinePnt = F)
% (3) single event functional interrupt in accumulation memory (isSefiAcc = T)
% (4) single event functional interrupt in cadence memory (isSefiCad = T)
% (5) Local Detector Electronics out of synch reported (isLdeOos = T)
% (6) Local Detector Electronics parity error occurred (isLdeParEr = T)
% (7) SDRAM Controller memory pixel error occurred (isScrcErr = T)
%--------------------------------------------------------------------------

% Update the time-dependent data gap flags for SC, LC, and for FFI only if the errorOnCoarsePointFfi is true. Otherwise the FFI will be
% gapped if any FS flag is false (and/or isFinePnt = true) and the FFI would not be processed.

isMmntmDmp = calInputStruct.cadenceTimes.isMmntmDmp;            % nCadences x 1 array
isFinePnt  = calInputStruct.cadenceTimes.isFinePnt;
isSefiAcc  = calInputStruct.cadenceTimes.isSefiAcc;
isSefiCad  = calInputStruct.cadenceTimes.isSefiCad;
isLdeOos   = calInputStruct.cadenceTimes.isLdeOos;
isLdeParEr = calInputStruct.cadenceTimes.isLdeParEr;
isScrcErr  = calInputStruct.cadenceTimes.isScrcErr;

excludeIndicators = calInputStruct.cadenceTimes.dataAnomalyFlags.excludeIndicators;

newCadenceGaps = false(size(calInputStruct.cadenceTimes.gapIndicators));

if ~processFFI || (processFFI && errorOnCoarsePointFfi)
    % add F/S flags one-by-one depending on module parameter state
    if enableMmntmDmpFlag
        newCadenceGaps = newCadenceGaps | isMmntmDmp;
    end
    if enableSefiAccFlag
        newCadenceGaps = newCadenceGaps | isSefiAcc;
    end
    if enableSefiCadFlag
        newCadenceGaps = newCadenceGaps |isSefiCad;
    end
    if enableLdeOosFlag
        newCadenceGaps = newCadenceGaps |isLdeOos;
    end
    if enableLdeParErFlag
        newCadenceGaps = newCadenceGaps | isLdeParEr;
    end
    if enableScrcErrFlag
        newCadenceGaps = newCadenceGaps | isScrcErr;
    end
    if ~enableCoarsePointProcessing
        newCadenceGaps = newCadenceGaps | ~isFinePnt;
    end
end

% update gaps based on excludeIndicators
if enableExcludeIndicators && ~enableExcludePreserve
    newCadenceGaps = newCadenceGaps | excludeIndicators;
end


% update gaps in cadence times array
calInputStruct.cadenceTimes.gapIndicators(newCadenceGaps) = true;

if isAvailableBlackPix
    
    blackPixels = calInputStruct.blackPixels;    
    blackPixelGaps = [blackPixels.gapIndicators];               % nCadencesx1070
    
    % update the gaps
    blackPixelGaps(newCadenceGaps, :) = true;
    
    % deal the gaps back into the input struct
    blackGapIndicatorsCellArray = num2cell(blackPixelGaps, 1);  % NUM2CELL(A,1) places the cols of A into separate cells.
    
    [blackPixels(1:length(blackGapIndicatorsCellArray)).gapIndicators] = ...
        deal(blackGapIndicatorsCellArray{:});
    
    calInputStruct.blackPixels = blackPixels;
end

if isAvailableMaskedBlackPix
    
    maskedBlackPixels = calInputStruct.maskedBlackPixels;
    mBlackPixelGaps   = [maskedBlackPixels.gapIndicators];      % nCadencesx1
    
    % update the gaps
    mBlackPixelGaps(newCadenceGaps) = true;
    
    % deal the gaps back into the input struct
    mBlackGapIndicatorsCellArray = num2cell(mBlackPixelGaps, 1);
    
    [maskedBlackPixels(1:length(mBlackGapIndicatorsCellArray)).gapIndicators] = ...
        deal(mBlackGapIndicatorsCellArray{:});
    
    calInputStruct.maskedBlackPixels = maskedBlackPixels;
end

if isAvailableVirtualBlackPix
    
    virtualBlackPixels = calInputStruct.virtualBlackPixels;
    vBlackPixelGaps    = [virtualBlackPixels.gapIndicators];    % nCadencesx1
    
    % update the gaps
    vBlackPixelGaps(newCadenceGaps) = true;
    
    % deal the gaps back into the input struct
    vBlackGapIndicatorsCellArray = num2cell(vBlackPixelGaps, 1);
    
    [virtualBlackPixels(1:length(vBlackGapIndicatorsCellArray)).gapIndicators] = ...
        deal(vBlackGapIndicatorsCellArray{:});
    
    calInputStruct.virtualBlackPixels = virtualBlackPixels;
end

if isAvailableMaskedSmearPix
    
    maskedSmearPixels = calInputStruct.maskedSmearPixels;
    mSmearPixelGaps   = [maskedSmearPixels.gapIndicators];      % nCadencesx1100
    
    % update the cadence gaps for all pixels
    mSmearPixelGaps(newCadenceGaps, :) = true;
    
    % update bleeding column gaps for all cadences
    mSmearColumns = [maskedSmearPixels.column]';    
    mSmearPixelGaps(:, ismember(mSmearColumns, mSmearBleedingCols)) = true;
    
    % deal the gaps back into the input struct
    mSmearGapIndicatorsCellArray = num2cell(mSmearPixelGaps, 1); % NUM2CELL(A,1) places the cols of A into separate cells.
    
    [maskedSmearPixels(1:length(mSmearGapIndicatorsCellArray)).gapIndicators] = ...
        deal(mSmearGapIndicatorsCellArray{:});
    
    calInputStruct.maskedSmearPixels = maskedSmearPixels;
end

if isAvailableVirtualSmearPix
    
    virtualSmearPixels = calInputStruct.virtualSmearPixels;
    vSmearPixelGaps    = [virtualSmearPixels.gapIndicators];    % nCadencesx1100
    
    % update the cadence gaps for all pixels
    vSmearPixelGaps(newCadenceGaps, :) = true;
    
    % update bleeding column gaps for all cadences
    vSmearColumns = [virtualSmearPixels.column]';    
    vSmearPixelGaps(:, ismember(vSmearColumns, vSmearBleedingCols)) = true;
    
    % deal the gaps back into the input struct
    vSmearGapIndicatorsCellArray = num2cell(vSmearPixelGaps, 1); % NUM2CELL(A,1) places the cols of A into separate cells.
    
    [virtualSmearPixels(1:length(vSmearGapIndicatorsCellArray)).gapIndicators] = ...
        deal(vSmearGapIndicatorsCellArray{:});
    
    calInputStruct.virtualSmearPixels = virtualSmearPixels;
end

if isAvailableTargetAndBkgPix
    
    targetAndBkgPixels    = calInputStruct.targetAndBkgPixels;
    targetAndBkgPixelGaps = [targetAndBkgPixels.gapIndicators]; % nCadencesxnPixels
    
    % update the gaps
    targetAndBkgPixelGaps(newCadenceGaps, :) = true;
    
    % deal the gaps back into the input struct
    targetAndBkgGapIndicatorsCellArray = num2cell(targetAndBkgPixelGaps, 1); % NUM2CELL(A,1) places the cols of A into separate cells.
    
    [targetAndBkgPixels(1:length(targetAndBkgGapIndicatorsCellArray)).gapIndicators] = ...
        deal(targetAndBkgGapIndicatorsCellArray{:});
    
    calInputStruct.targetAndBkgPixels = targetAndBkgPixels;
end


%--------------------------------------------------------------------------
% check that all required pixel types are available
%--------------------------------------------------------------------------
if firstCall
    
    if processLongCadence || processFFI
        %------------------------------------------------------------------
        % check for available pixels structs: black, masked smear and
        % virtual smear are all needed to calibrate LC collateral data
        %------------------------------------------------------------------
        if (~isAvailableBlackPix && ~isAvailableMaskedSmearPix && ~isAvailableVirtualSmearPix)
            
            error('CAL:validate_cal_inputs:MissingInputPixelTypes', ...
                'Black, masked smear, and virtual smear pixels are needed to process long cadence collateral data.');
        end
        
    elseif processShortCadence
        %------------------------------------------------------------------
        % check for available pixels structs: black, masked smear, virtual
        % smear, masked black, and virtual black are all needed to calibrate
        % SC collateral data
        %------------------------------------------------------------------
        if (~isAvailableBlackPix && ~isAvailableMaskedBlackPix && ~isAvailableVirtualBlackPix && ...
                ~isAvailableMaskedSmearPix && ~isAvailableVirtualSmearPix)
            
            error('CAL:validate_cal_inputs:MissingInputPixelTypes', ...
                'Black, masked black, virtual black, masked smear, and virtual smear are needed to process short cadence collateral data.');
        end
    end
    
    %------------------------------------------------------------------
    % check to ensure data is not all gapped or all zero-valued.
    %------------------------------------------------------------------
    allBlackGaps  = all(all([calInputStruct.blackPixels.gapIndicators]));
    allMsmearGaps = all(all([calInputStruct.maskedSmearPixels.gapIndicators]));
    allVsmearGaps = all(all([calInputStruct.virtualSmearPixels.gapIndicators]));
    
    anyBlackPixels  = any(any([calInputStruct.blackPixels.values]));
    anyMsmearPixels = any(any([calInputStruct.maskedSmearPixels.values]));
    anyVsmearPixels = any(any([calInputStruct.virtualSmearPixels.values]));
    
    % check for valid input black pixel values
    if (allBlackGaps  || ~anyBlackPixels)
        error('CAL:validate_cal_inputs:MissingInputPixelTypes', ...
            'There are no valid (non-zero or non-gapped) black pixel values available.');
    end
    
    % check for valid input masked smear pixel values
    if (allMsmearGaps || ~anyMsmearPixels)
        error('CAL:validate_cal_inputs:MissingInputPixelTypes', ...
            'There are no valid (non-zero or non-gapped) masked smear pixel values available.');
    end
    
    % check for valid input virtual smear pixel values
    if (allVsmearGaps || ~anyVsmearPixels)
        error('CAL:validate_cal_inputs:MissingInputPixelTypes', ...
            'There are no valid (non-zero or non-gapped) virtual smear pixel values available.');
    end
    
    if processShortCadence                              % validate additional collateral fields for SC
        
        allMblackGaps = all(all([calInputStruct.maskedBlackPixels.gapIndicators]));
        allVblackGaps = all(all([calInputStruct.virtualBlackPixels.gapIndicators]));
        
        anyMblackPixels = any(any([calInputStruct.maskedBlackPixels.values]));
        anyVblackPixels = any(any([calInputStruct.virtualBlackPixels.values]));
        
        % check for valid input masked black pixel values
        if (allMblackGaps || ~anyMblackPixels)
            error('CAL:validate_cal_inputs:MissingInputPixelTypes', ...
                'There are no valid (non-zero or non-gapped) masked black pixel values available.');
        end
        
        % check for valid input virtual black pixel values
        if (allVblackGaps || ~anyVblackPixels)
            error('CAL:validate_cal_inputs:MissingInputPixelTypes', ...
                'There are no valid (non-zero or non-gapped) virtual black pixel values available.');
        end
    end
else
    %------------------------------------------------------------------
    % check for available photometric pixel struct, and check to ensure
    % data is not all gapped or all zero-valued
    %------------------------------------------------------------------
    allPhotometricGaps   = all(all([calInputStruct.targetAndBkgPixels.gapIndicators]));
    anyPhotometricPixels = any(any([calInputStruct.targetAndBkgPixels.values]));
    
    if (allPhotometricGaps || ~anyPhotometricPixels)
        error('CAL:validate_cal_inputs:MissingInputPixelTypes', ...
            'There are no valid (non-zero or non-gapped) photometric pixel values available.');
    end
end


%--------------------------------------------------------------------------
% validate all fields in top level input struct; all fields should exist
% regardless of pixel types that are to be calibrated
%--------------------------------------------------------------------------
fieldsAndBounds = cell(44,4);
fieldsAndBounds(1,:)  = { 'version'; []; []; []};
fieldsAndBounds(2,:)  = { 'debugLevel'; []; []; []};
fieldsAndBounds(3,:)  = { 'firstCall'; []; []; [true, false]};
fieldsAndBounds(4,:)  = { 'lastCall'; []; []; [true, false]};
fieldsAndBounds(5,:)  = { 'emptyInputs'; []; []; [true, false]};
fieldsAndBounds(6,:)  = { 'calInvocationNumber'; '>=0'; []; []};
fieldsAndBounds(7,:)  = { 'totalCalInvocations'; '> 0'; []; []};
fieldsAndBounds(8,:)  = { 'totalPixels'; []; []; []};
fieldsAndBounds(9,:)  = { 'cadenceType'; []; []; []};
fieldsAndBounds(10,:) = { 'ccdModule'; []; []; '[2:4, 6:20, 22:24]'};
fieldsAndBounds(11,:) = { 'ccdOutput'; []; []; '[1 2 3 4]'};
fieldsAndBounds(12,:) = { 'moduleParametersStruct'; []; []; []};
fieldsAndBounds(13,:) = { 'cosmicRayParametersStruct'; []; []; []};
fieldsAndBounds(14,:) = { 'pouModuleParametersStruct'; []; []; []};
fieldsAndBounds(15,:) = { 'harmonicsIdentificationConfigurationStruct'; []; []; []};
fieldsAndBounds(16,:) = { 'gapFillConfigurationStruct'; []; []; []};
fieldsAndBounds(17,:) = { 'fcConstants'; []; []; []};               % validate only fc constants which are used in CAL
fieldsAndBounds(18,:) = { 'cadenceTimes'; []; []; []};              
fieldsAndBounds(19,:) = { 'gainModel'; []; []; []};                 % no need to validate fc model
fieldsAndBounds(20,:) = { 'flatFieldModel'; []; []; []};            % no need to validate fc model
fieldsAndBounds(21,:) = { 'twoDBlackModel'; []; []; []};            % no need to validate fc model
fieldsAndBounds(22,:) = { 'linearityModel'; []; []; []};            % no need to validate fc model
fieldsAndBounds(23,:) = { 'undershootModel'; []; []; []};           % no need to validate fc model
fieldsAndBounds(24,:) = { 'readNoiseModel'; []; []; []};            % no need to validate fc model
fieldsAndBounds(25,:) = { 'targetAndBkgPixels'; []; []; []};        % validate if exists
fieldsAndBounds(26,:) = { 'twoDBlackIds'; []; []; []};              % validate if exists
fieldsAndBounds(27,:) = { 'ldeUndershootIds'; []; []; []};          % validate if exists
fieldsAndBounds(28,:) = { 'maskedSmearPixels'; []; []; []};         % validate if exists
fieldsAndBounds(29,:) = { 'virtualSmearPixels'; []; []; []};        % validate if exists
fieldsAndBounds(30,:) = { 'blackPixels'; []; []; []};               % validate if exists
fieldsAndBounds(31,:) = { 'maskedBlackPixels'; []; []; []};         % validate if exists
fieldsAndBounds(32,:) = { 'virtualBlackPixels'; []; []; []};        % validate if exists
fieldsAndBounds(33,:) = { 'spacecraftConfigMap'; []; []; []};       % error out if more than 1 unique table
fieldsAndBounds(34,:) = { 'requantTables'; []; []; []};             % error out if more than 1 unique table
fieldsAndBounds(35,:) = { 'huffmanTables'; []; []; []};             % no need to validate
fieldsAndBounds(36,:) = { 'twoDCollateral'; []; []; []};            % no need to validate
fieldsAndBounds(37,:) = { 'season'; '>=0'; '<=3'; '[0:3]'};
fieldsAndBounds(38,:) = { 'oneDBlackBlobs'; []; []; []};            % no need to validate
fieldsAndBounds(39,:) = { 'dynamic2DBlackBlobs'; []; []; []};       % no need to validate
fieldsAndBounds(40,:) = { 'smearBlobs'; []; []; []};                % no need to validate
fieldsAndBounds(41,:) = { 'pipelineInfoStruct'; []; []; []};        % no need to validate
fieldsAndBounds(42,:) = { 'ffis'; []; []; []};                      % validate if exists
fieldsAndBounds(43,:) = { 'quarter';[];[];[]};
fieldsAndBounds(44,:) = { 'k2Campaign';[];[];[]};

validate_structure(calInputStruct, fieldsAndBounds,'calInputStruct');

clear fieldsAndBounds;
 

%--------------------------------------------------------------------------
% validate fields in moduleParametersStruct
%--------------------------------------------------------------------------
fieldsAndBounds = cell(37,4);
fieldsAndBounds(1,:)  = { 'crCorrectionEnabled'; []; []; [true, false]};
fieldsAndBounds(2,:)  = { 'linearityCorrectionEnabled'; []; []; [true, false]};
fieldsAndBounds(3,:)  = { 'flatFieldCorrectionEnabled'; []; []; [true, false]};
fieldsAndBounds(4,:)  = { 'undershootEnabled'; []; []; [true, false]};
fieldsAndBounds(5,:)  = { 'collateralMetricUncertEnabled'; []; []; [true, false]};
fieldsAndBounds(6,:)  = { 'madSigmaThresholdForSmearLevels'; '> 0'; '< 25'; []};
fieldsAndBounds(7,:)  = { 'undershootReverseFitPolyOrder'; []; []; []};
fieldsAndBounds(8,:)  = { 'undershootReverseFitWindow'; []; []; []};
fieldsAndBounds(9,:)  = { 'polyOrderMax'; '>= 0'; '< 25'; []};
fieldsAndBounds(10,:) = { 'debugEnabled'; []; []; [true, false]};
fieldsAndBounds(11,:) = { 'stdRatioThreshold'; '>0.1';'<10';[]};
fieldsAndBounds(12,:) = { 'coefficentModelId';[];[];'[1 2 3 4]'};
fieldsAndBounds(13,:) = { 'useRobustVerticalCoeffs';[];[];[true, false]};
fieldsAndBounds(14,:) = { 'useRobustFrameFgsCoeffs';[];[];[true, false]};
fieldsAndBounds(15,:) = { 'useRobustParallelFgsCoeffs';[];[];[true, false]};
fieldsAndBounds(16,:) = { 'blackAlgorithm';[];[];[]};
fieldsAndBounds(17,:) = { 'defaultDarkCurrentElectronsPerSec';'>=0';'<100';[]};
fieldsAndBounds(18,:) = { 'minCadencesForCompression';'>=0';'<50';[]};
fieldsAndBounds(19,:) = { 'nSigmaForFfiOutlierRejection';'>0.1';'<50';[]};
fieldsAndBounds(20,:) = { 'errorOnCoarsePointFfi';[];[];[true false]};
fieldsAndBounds(21,:) = { 'dynoblackModelAutoSelectEnable';[];[];[true false]};
fieldsAndBounds(22,:) = { 'dynoblackChi2Threshold';'>0';'<=1';[]};
fieldsAndBounds(23,:) = { 'enableLcInformSmear';[];[];[true false]};
fieldsAndBounds(24,:) = { 'enableFfiInform';[];[];[true false]};
fieldsAndBounds(25,:) = { 'enableCoarsePointProcessing';[];[];[true false]};
fieldsAndBounds(26,:) = { 'enableMmntmDmpFlag';[];[];[true false]};
fieldsAndBounds(27,:) = { 'enableSefiAccFlag';[];[];[true false]};
fieldsAndBounds(28,:) = { 'enableSefiCadFlag';[];[];[true false]};
fieldsAndBounds(29,:) = { 'enableLdeOosFlag';[];[];[true false]};
fieldsAndBounds(30,:) = { 'enableLdeParErFlag';[];[];[true false]};
fieldsAndBounds(31,:) = { 'enableScrcErrFlag';[];[];[true false]};
fieldsAndBounds(32,:) = { 'enableSmearExcludeColumnMap';[];[];[true false]};
fieldsAndBounds(33,:) = { 'enableSceneDependentRowMap';[];[];[true false]};
fieldsAndBounds(34,:) = { 'enableBlackCoefficientOverrides';[];[];[true false]};
fieldsAndBounds(35,:) = { 'enableExcludeIndicators';[];[];[true false]};
fieldsAndBounds(36,:) = { 'enableExcludePreserve';[];[];[true false]};
fieldsAndBounds(37,:) = { 'enableDbDataQualityGapping';[];[];[true false]};

validate_structure(calInputStruct.moduleParametersStruct, fieldsAndBounds,'calInputStruct.moduleParametersStruct');

clear fieldsAndBounds;


%--------------------------------------------------------------------------
% validate fields in cosmicRayParametersStruct
%--------------------------------------------------------------------------
fieldsAndBounds = cell(8,4);
fieldsAndBounds(1,:)  = { 'detrendOrder'; '>= 0'; '< 25'; []};
fieldsAndBounds(2,:)  = { 'medianFilterLength'; '> 0'; '< 1000'; []};
fieldsAndBounds(3,:)  = { 'madThreshold'; '>= 0'; '< 1000'; []};
fieldsAndBounds(4,:)  = { 'madWindowLength'; '>= 0'; '< 1000'; []};
fieldsAndBounds(5,:)  = { 'thresholdMultiplierForNegativeEvents'; '>= 0'; '< 1000'; []};
fieldsAndBounds(6,:)  = { 'consecutiveCosmicRayCleaningEnabled'; []; []; [true, false]};
fieldsAndBounds(7,:)  = { 'twoSidedFinalThresholdingEnabled'; []; []; [true, false]};
fieldsAndBounds(8,:)  = { 'cosmicRayCleaningMethod'; []; []; {'mad', 'ar'}};

fieldsAndBounds = ...
    [fieldsAndBounds; ...
     calCosmicRayCleanerClass.get_config_struct_fields_and_bounds()];
 
validate_structure(calInputStruct.cosmicRayParametersStruct, fieldsAndBounds,'calInputStruct.cosmicRayParametersStruct');

clear fieldsAndBounds;


%--------------------------------------------------------------------------
% validate fields in harmonicsIdentificationConfigurationStruct.
% Identification of harmonic components is done in the autoregressive
% ('ar') cosmic ray cleaning method.
%--------------------------------------------------------------------------
fieldsAndBounds = cell(7,4);
fieldsAndBounds(1,:)  = { 'medianWindowLengthForTimeSeriesSmoothing';  '>= 1'; [];         []};
fieldsAndBounds(2,:)  = { 'medianWindowLengthForPeriodogramSmoothing'; '>= 1'; [];         []};
fieldsAndBounds(3,:)  = { 'movingAverageWindowLength';                 '>= 1'; [];         []};
fieldsAndBounds(4,:)  = { 'falseDetectionProbabilityForTimeSeries';    '> 0';  '< 1';      []};
fieldsAndBounds(5,:)  = { 'minHarmonicSeparationInBins';               '>= 1'; '<= 1000';  []};
fieldsAndBounds(6,:)  = { 'maxHarmonicComponents';                     '>= 1'; '<= 10000'; []};
fieldsAndBounds(7,:)  = { 'timeOutInMinutes';                          '> 0';  '<= 180';   []};

validate_structure(calInputStruct.harmonicsIdentificationConfigurationStruct, ...
    fieldsAndBounds, 'calInputStruct.harmonicsIdentificationConfigurationStruct');

clear fieldsAndBounds;


%--------------------------------------------------------------------------
% Validate fields in gapFillConfigurationStruct. 
% This structure is used by the harmonics identification procedure called
% from within the autoregressive ('ar') cosmic ray cleaning method.
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

validate_structure(calInputStruct.gapFillConfigurationStruct, fieldsAndBounds, ...
    'calInputStruct.gapFillConfigurationStruct');

clear fieldsAndBounds;


%--------------------------------------------------------------------------
% validate fields in pouModuleParametersStruct
%--------------------------------------------------------------------------
fieldsAndBounds = cell(8,4);
fieldsAndBounds(1,:) = { 'pouEnabled'; []; []; [true, false]};
fieldsAndBounds(2,:) = { 'compressionEnabled'; []; []; [true, false]};
fieldsAndBounds(3,:) = { 'maxSvdOrder'; '>= 0'; '< 25'; []};
fieldsAndBounds(4,:) = { 'numErrorPropVars'; []; []; []};
fieldsAndBounds(5,:) = { 'pixelChunkSize'; '> 999'; '< 3500'; []};
fieldsAndBounds(6,:) = { 'interpDecimation'; '> 0'; []; []};
fieldsAndBounds(7,:) = { 'interpMethod'; []; []; []};                                  %{'nearest', 'linear', 'spline', 'pchip', 'cubic'}
fieldsAndBounds(8,:) = { 'cadenceChunkSize'; []; []; []};

validate_structure(calInputStruct.pouModuleParametersStruct, fieldsAndBounds,'calInputStruct.pouModuleParametersStruct');

clear fieldsAndBounds;

%--------------------------------------------------------------------------
% validate fields in cadenceTimes
%--------------------------------------------------------------------------

% validate only non-gapped timestamps
validCadenceTimes = calInputStruct.cadenceTimes;
validCadenceTimes.startTimestamps = validCadenceTimes.startTimestamps(~validCadenceTimes.gapIndicators);
validCadenceTimes.midTimestamps   = validCadenceTimes.midTimestamps(~validCadenceTimes.gapIndicators);
validCadenceTimes.endTimestamps   = validCadenceTimes.endTimestamps(~validCadenceTimes.gapIndicators);

fieldsAndBounds = cell(5,4);

fieldsAndBounds(1,:) = { 'startTimestamps'; '> 54000'; '< 64000'; []};
fieldsAndBounds(2,:) = { 'midTimestamps'; '> 54000'; '< 64000'; []};
fieldsAndBounds(3,:) = { 'endTimestamps'; '> 54000'; '< 64000'; []};
fieldsAndBounds(4,:) = { 'gapIndicators'; []; []; [true, false]};
fieldsAndBounds(5,:) = { 'requantEnabled'; []; []; [true, false]};
%fieldsAndBounds(6,:) = { 'cadenceNumbers'; '>=0'; '< 2e4'; []};

validate_structure(validCadenceTimes, fieldsAndBounds,'calInputStruct.cadenceTimes');

clear fieldsAndBounds;


%--------------------------------------------------------------------------
% validate pixel types in fields that are not empty.  Either collateral
% pixel types will exist (three types for long cadence and five types for
% short cadence), or target/background pixels will exist, but never both.
% If processing FFIs, this validation will be skipped over
%--------------------------------------------------------------------------

if ~isempty([calInputStruct.targetAndBkgPixels]) && ~processFFI
    
    fieldsAndBounds = cell(4,4);    
    fieldsAndBounds(1,:) = { 'row';'>= 0';'<= 1200'; []};
    fieldsAndBounds(2,:) = { 'column';'>= 0';'<= 1200'; []};
    fieldsAndBounds(3,:) = { 'values';'>= 0'; '<=2^23-1'; []};
    fieldsAndBounds(4,:) = { 'gapIndicators'; []; []; [true, false]};
    
    nStructures = length(calInputStruct.targetAndBkgPixels);
    
    for j = 1:nStructures
        validate_structure(calInputStruct.targetAndBkgPixels(j), fieldsAndBounds,'calInputStruct.targetAndBkgPixels');
    end
    
    clear fieldsAndBounds;
end
%------------------------------------------------------------
if ~isempty([calInputStruct.twoDBlackIds])
    
    fieldsAndBounds = cell(3,4);    
    fieldsAndBounds(1,:) = { 'keplerId'; []; []; []};
    fieldsAndBounds(2,:) = { 'rows';'>= 0';'<= 1200'; []};
    fieldsAndBounds(3,:) = { 'cols';'>= 0';'<= 1200'; []};
    
    nStructures = length(calInputStruct.twoDBlackIds);
    
    for j = 1:nStructures
        validate_structure(calInputStruct.twoDBlackIds(j), fieldsAndBounds,'calInputStruct.twoDBlackIds');
    end
    
    clear fieldsAndBounds;
end
%------------------------------------------------------------
if ~isempty([calInputStruct.ldeUndershootIds])
    
    fieldsAndBounds = cell(3,4);    
    fieldsAndBounds(1,:) = { 'keplerId'; []; []; []};
    fieldsAndBounds(2,:) = { 'rows';'>= 0';'<= 1200'; []};
    fieldsAndBounds(3,:) = { 'cols';'>= 0';'<= 1200'; []};
    
    nStructures = length(calInputStruct.ldeUndershootIds);
    
    for j = 1:nStructures
        validate_structure(calInputStruct.ldeUndershootIds(j), fieldsAndBounds,'calInputStruct.ldeUndershootIds');
    end
    
    clear fieldsAndBounds;
end
%------------------------------------------------------------
if ~isempty([calInputStruct.maskedSmearPixels]) && ~processFFI
    
    fieldsAndBounds = cell(3,4);    
    fieldsAndBounds(1,:) = { 'column';'>= 0';'<= 1200'; []};
    fieldsAndBounds(2,:) = { 'values';'>= 0'; '<=2^23-1'; []};
    fieldsAndBounds(3,:) = { 'gapIndicators'; []; []; [true, false]};
    
    nStructures = length(calInputStruct.maskedSmearPixels);
    
    for j = 1:nStructures
        validate_structure(calInputStruct.maskedSmearPixels(j), fieldsAndBounds,'calInputStruct.maskedSmearPixels');
    end
    
    clear fieldsAndBounds;
end
%------------------------------------------------------------
if ~isempty([calInputStruct.virtualSmearPixels]) && ~processFFI
    
    fieldsAndBounds = cell(3,4);    
    fieldsAndBounds(1,:) = { 'column';'>= 0';'<= 1200'; []};
    fieldsAndBounds(2,:) = { 'values';'>= 0'; '<=2^23-1'; []};
    fieldsAndBounds(3,:) = { 'gapIndicators'; []; []; [true, false]};
    
    nStructures = length(calInputStruct.virtualSmearPixels);
    
    for j = 1:nStructures
        validate_structure(calInputStruct.virtualSmearPixels(j), fieldsAndBounds,'calInputStruct.virtualSmearPixels');
    end
    
    clear fieldsAndBounds;
end
%------------------------------------------------------------
if ~isempty([calInputStruct.blackPixels]) && ~processFFI
    
    fieldsAndBounds = cell(3,4);    
    fieldsAndBounds(1,:) = { 'row';'>= 0';'<= 1200'; []};
    fieldsAndBounds(2,:) = { 'values';'>= 0'; '<=2^23-1'; []};
    fieldsAndBounds(3,:) = { 'gapIndicators'; []; []; [true, false]};
    
    nStructures = length(calInputStruct.blackPixels);
    
    for j = 1:nStructures
        validate_structure(calInputStruct.blackPixels(j), fieldsAndBounds,'calInputStruct.blackPixels');
    end
    
    clear fieldsAndBounds;
end
%--------------------------------------------------------------------------
% validate masked/virtual black fields if they are inputs
%--------------------------------------------------------------------------
if  processShortCadence
    
    if (~isempty([calInputStruct.maskedBlackPixels]))
        
        fieldsAndBounds = cell(2,4);        
        fieldsAndBounds(1,:) = { 'values';'>= 0'; '<=2^23-1'; []};
        fieldsAndBounds(2,:) = { 'gapIndicators'; []; []; [true, false]};
        
        validate_structure(calInputStruct.maskedBlackPixels, fieldsAndBounds,'calInputStruct.maskedBlackPixels');
        
        clear fieldsAndBounds;
    end
    
    
    if (~isempty([calInputStruct.virtualBlackPixels]))
        
        fieldsAndBounds = cell(2,4);        
        fieldsAndBounds(1,:) = { 'values';'>= 0'; '<=2^23-1'; []};
        fieldsAndBounds(2,:) = { 'gapIndicators'; []; []; [true, false]};
        
        validate_structure(calInputStruct.virtualBlackPixels, fieldsAndBounds,'calInputStruct.virtualBlackPixels');
        
        clear fieldsAndBounds;
    end
end

%--------------------------------------------------------------------------
% validate ffi fields if they are inputs
%--------------------------------------------------------------------------
if ~isempty(calInputStruct.ffis)
    
    for iFfi = 1:length(calInputStruct.ffis)
    
        fieldsAndBounds = cell(6,4);
        fieldsAndBounds(1,:) = { 'fileName'; []; []; []};
        fieldsAndBounds(2,:) = { 'startTimestamp';  '> 54000'; '< 64000'; []};    
        fieldsAndBounds(3,:) = { 'midTimestamp';  '> 54000'; '< 64000'; []};    
        fieldsAndBounds(4,:) = { 'endTimestamp';  '> 54000'; '< 64000'; []};       
        fieldsAndBounds(5,:) = { 'absoluteRowNumbers';  '>= 0'; '<= 1069'; []};   
        fieldsAndBounds(6,:) = { 'image'; []; []; []}; 

        validate_structure(calInputStruct.ffis(iFfi), fieldsAndBounds,['calInputStruct.ffis(',num2str(iFfi),')']);
        clear fieldsAndBounds;
        
        % check image values        
        fieldsAndBounds = cell(1,4);
        fieldsAndBounds(1,:) = { 'array'; '>= 0'; '<=2^23-1'; []};
            
        for iImage = 1:length(calInputStruct.ffis(iFfi).image)    
            validate_structure(calInputStruct.ffis(iFfi).image(iImage), fieldsAndBounds,['calInputStruct.ffis(',num2str(iFfi),').image(',num2str(iImage),')']);
        end        
        clear fieldsAndBounds; 
        
        % check that image contains all columns for rows provided
        [rows, cols] = size([calInputStruct.ffis(iFfi).image.array]');
        if ~isequal(cols,1132)
            error('CAL:validate_cal_inputs:ffiImageWrongSize', ...
                ['Image size = [',num2str(rows),', ',num2str(cols),'] not [',num2str(rows),', 1132].']);
        end
        clear rows cols
        
    end
end
    
    
%--------------------------------------------------------------------------
% validate spacecraft config map
%--------------------------------------------------------------------------
nConfigMaps = length(calInputStruct.spacecraftConfigMap);

% check for consistent entries among config map parameters used by CAL,
% error out if config map parameters are different
if nConfigMaps > 1
    
    collectParams = repmat(struct(...
        'FDMLCOFFSET', [], ...      %lcFixedOffsets
        'FDMSCOFFSET', [], ...      %scFixedOffsets
        'FDMDRKCOLSTART', [], ...   %blackStartColumns
        'FDMDRKCOLEND', [], ...     %blackEndColumns
        'FDMMSKROWSTART', [], ...   %maskedSmearStartRows
        'FDMMSKROWEND', [], ...     %maskedSmearEndRows
        'FDMSMRROWSTART', [], ...   %virtualSmearStartRows
        'FDMSMRROWEND', [], ...     %virtualSmearEndRows
        'GSprm_ROPER', [], ...      %ccdReadTime
        'FDMINTPER', [], ...        %ccdExposureTime
        'GSprm_FGSPER', [], ...     %ccdExposureTime
        'FDMLCPER', [], ...         %numberOfExposuresPerLongCadence
        'FDMSCPER', [], ...         %numberOfExposuresPerShortCadence
        'FDMLDEFFINUM', [] ...      %numberOfExposuresPerFFI
        ), nConfigMaps, 1);
    
    for mapIndex = 1:nConfigMaps
        
        mnemonics = {calInputStruct.spacecraftConfigMap(mapIndex).entries.mnemonic}';        
        
        collectParams(mapIndex).FDMLCOFFSET     = calInputStruct.spacecraftConfigMap(mapIndex).entries(ismember(mnemonics, 'FDMLCOFFSET')).value;
        collectParams(mapIndex).FDMSCOFFSET     = calInputStruct.spacecraftConfigMap(mapIndex).entries(ismember(mnemonics, 'FDMSCOFFSET')).value;
        
        collectParams(mapIndex).FDMDRKCOLSTART  = calInputStruct.spacecraftConfigMap(mapIndex).entries(ismember(mnemonics, 'FDMDRKCOLSTART')).value;
        collectParams(mapIndex).FDMDRKCOLEND    = calInputStruct.spacecraftConfigMap(mapIndex).entries(ismember(mnemonics, 'FDMDRKCOLEND')).value;
        
        collectParams(mapIndex).FDMMSKROWSTART  = calInputStruct.spacecraftConfigMap(mapIndex).entries(ismember(mnemonics, 'FDMMSKROWSTART')).value;
        collectParams(mapIndex).FDMMSKROWEND    = calInputStruct.spacecraftConfigMap(mapIndex).entries(ismember(mnemonics, 'FDMMSKROWEND')).value;
        
        collectParams(mapIndex).FDMSMRROWSTART  = calInputStruct.spacecraftConfigMap(mapIndex).entries(ismember(mnemonics, 'FDMSMRROWSTART')).value;
        collectParams(mapIndex).FDMSMRROWEND    = calInputStruct.spacecraftConfigMap(mapIndex).entries(ismember(mnemonics, 'FDMSMRROWEND')).value;
        
        collectParams(mapIndex).GSprm_ROPER     = calInputStruct.spacecraftConfigMap(mapIndex).entries(ismember(mnemonics, 'GSprm_ROPER')).value;
        collectParams(mapIndex).FDMINTPER       = calInputStruct.spacecraftConfigMap(mapIndex).entries(ismember(mnemonics, 'FDMINTPER')).value;
        
        collectParams(mapIndex).GSprm_FGSPER    = calInputStruct.spacecraftConfigMap(mapIndex).entries(ismember(mnemonics, 'GSprm_FGSPER')).value;
        collectParams(mapIndex).FDMLCPER        = calInputStruct.spacecraftConfigMap(mapIndex).entries(ismember(mnemonics, 'FDMLCPER')).value;
        collectParams(mapIndex).FDMSCPER        = calInputStruct.spacecraftConfigMap(mapIndex).entries(ismember(mnemonics, 'FDMSCPER')).value;
        collectParams(mapIndex).FDMLDEFFINUM    = calInputStruct.spacecraftConfigMap(mapIndex).entries(ismember(mnemonics, 'FDMLDEFFINUM')).value;
        
    end
    
    % determine if the parameters are equivalent
    for mapIndex = 1:nConfigMaps-1
        if(~isequal(collectParams(mapIndex), collectParams(mapIndex+1)))
            % produce an error if they contain different parameters
            error('CAL:validate_cal_inputs', ...
                'More than one spacecraft config map passed into CAL, and relevant values do not match.');
        end;
    end;
    
    % if the parameters are equivalent, validate and pass in first config map into CAL
    calInputStruct.spacecraftConfigMap = calInputStruct.spacecraftConfigMap(1);
end

fieldsAndBounds = cell(3,4);
fieldsAndBounds(1,:) = { 'id'; []; []; []};
fieldsAndBounds(2,:) = { 'time'; []; []; []};
fieldsAndBounds(3,:) = { 'entries'; []; []; []};

validate_structure(calInputStruct.spacecraftConfigMap, fieldsAndBounds,'calInputStruct.spacecraftConfigMap');

clear fieldsAndBounds;

    
%------------------------------------------------------------
% second level validation for spacecraft config map
%------------------------------------------------------------
fieldsAndBounds = cell(2,4);
fieldsAndBounds(1,:) = { 'mnemonic'; []; []; []};
fieldsAndBounds(2,:) = { 'value'; []; []; []};

nStructures = length(calInputStruct.spacecraftConfigMap.entries);

for j = 1:nStructures
    validate_structure(calInputStruct.spacecraftConfigMap.entries(j), fieldsAndBounds,'calInputStruct.spacecraftConfigMap.entries');
end

clear fieldsAndBounds;

%--------------------------------------------------------------------------
% validate requantization tables
%--------------------------------------------------------------------------
% produce an error if more than one requant table is given in input
if length(calInputStruct.requantTables) > 1
    error('CAL:validate_cal_inputs', ...
        'Only one requantization table should be passed into CAL.');
else
    if ~processFFI
        
        fieldsAndBounds = cell(4,4);        
        fieldsAndBounds(1,:) = { 'externalId'; []; []; []};
        fieldsAndBounds(2,:) = { 'startMjd'; '> 54000'; '< 64000'; []};% use mjd
        fieldsAndBounds(3,:) = { 'requantEntries'; '>=0'; '<=2^23-1'; []}; % max value of requantization table = 2^23 - 1
        fieldsAndBounds(4,:) = { 'meanBlackEntries'; '>=0'; '<=2^24-1'; []}; % max value of mean black per read = 2^14 -1, 14 =  number of bits in the ADC
        
        validate_structure(calInputStruct.requantTables, fieldsAndBounds,'calInputStruct.requantTables');
        
        clear fieldsAndBounds;
    end
end

if ~processFFI
    %--------------------------------------------------------------------------
    % validate huffman tables
    %------------------------------------------------------------
    fieldsAndBounds = cell(6,4);
    fieldsAndBounds(1,:) = { 'theoreticalCompressionRate'; []; []; []};
    fieldsAndBounds(2,:) = { 'effectiveCompressionRate'; []; []; []};
    fieldsAndBounds(3,:) = { 'achievedCompressionRate'; []; []; []};
    fieldsAndBounds(4,:) = { 'externalId'; []; []; []};
    fieldsAndBounds(5,:) = { 'bitString'; []; []; []};
    fieldsAndBounds(6,:) = { 'startMjd'; []; []; []};
    
    validate_structure(calInputStruct.huffmanTables, fieldsAndBounds,'calInputStruct.huffmanTables');
    
    clear fieldsAndBounds;
end

%--------------------------------------------------------------------------
%  validate FC constants fields
%------------------------------------------------------------
fieldsAndBounds = cell(15,4);
fieldsAndBounds(1,:)  = { 'nRowsImaging'; '== 1024'; []; []};
fieldsAndBounds(2,:)  = { 'nColsImaging'; '== 1100'; []; []};
fieldsAndBounds(3,:)  = { 'nLeadingBlack'; '==12'; []; []};
fieldsAndBounds(4,:)  = { 'nTrailingBlack'; '==20'; []; []};
fieldsAndBounds(5,:)  = { 'nVirtualSmear'; '==26'; []; []};
fieldsAndBounds(6,:)  = { 'nMaskedSmear'; '== 20'; []; []};
fieldsAndBounds(7,:)  = { 'CCD_ROWS'; '== 1070'; []; []};
fieldsAndBounds(8,:)  = { 'CCD_COLUMNS'; '== 1132'; []; []};
fieldsAndBounds(9,:)  = { 'PIXEL_SIZE_IN_MICRONS'; '==27'; []; []};
fieldsAndBounds(10,:) = { 'REQUANT_TABLE_MIN_VALUE'; '==0'; []; []};
fieldsAndBounds(11,:) = { 'REQUANT_TABLE_MAX_VALUE'; '==8388607'; []; []};
fieldsAndBounds(12,:) = { 'MEAN_BLACK_TABLE_LENGTH'; '==84'; []; []};
fieldsAndBounds(13,:) = { 'MEAN_BLACK_TABLE_MIN_VALUE'; '==0'; []; []};
fieldsAndBounds(14,:) = { 'MEAN_BLACK_TABLE_MAX_VALUE'; '==16383'; []; []};
fieldsAndBounds(15,:) = { 'REQUANT_TABLE_LENGTH'; '==65536'; []; []};

validate_structure(calInputStruct.fcConstants, fieldsAndBounds,'calInputStruct.fcConstants');

clear fieldsAndBounds;

%--------------------------------------------------------------------------
%  validate blackAlgorithm values
%------------------------------------------------------------
allowedStrings = {'dynablack','exponentialOneDBlack','polynomialOneDBlack'};
mnemonic = 'blackAlgorithm';
blackAlgorithm = calInputStruct.moduleParametersStruct.blackAlgorithm;

if ~ismember( blackAlgorithm, allowedStrings)
    if isempty( blackAlgorithm )
        messageIdentifier = 'validate_cal_inputs:FieldEmpty' ;
        messageText =  ['validate_cal_inputs: ', mnemonic, ' can''t be empty.'];
        error( messageIdentifier, messageText ) ;
    else
        s = [];
        for iString = 1: length(allowedStrings)
            s = [s,' ''',allowedStrings{iString},''''];                                                                                        %#ok<AGROW>
        end
        messageIdentifier = 'validate_cal_inputs:ValueNotAllowed' ;
        messageText =  ['validate_cal_inputs: ', mnemonic, ' = ''', blackAlgorithm, ''' not one of the following:', s];
        error( messageIdentifier, messageText ) ;
    end
    
end

clear allowedStrings mnemonic blackAlgorithm s

%--------------------------------------------------------------------------
% Note: FC models are validated in FC API function calls
%--------------------------------------------------------------------------
display_cal_status('CAL:cal_matlab_controller: Inputs validated', 1);
metrics_interval_stop('cal.validate_cal_inputs.execTimeMillis',metricsKey);


