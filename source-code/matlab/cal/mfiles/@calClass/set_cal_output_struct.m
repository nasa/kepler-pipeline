function [calOutputStruct, calIntermediateStruct] = set_cal_output_struct(calObject, calIntermediateStruct, calTransformStruct)
% function [calOutputStruct, calIntermediateStruct] = set_cal_output_struct(calObject, calIntermediateStruct, calTransformStruct)
%
% This calClass method saves calibrated pixel results into an output structure that will be read out to the java interface.  The output
% struct has the same fields for all CAL invocations (collateral or photometric data calibration), with only the available fields filled in.
%
% calOutputStruct is a struct with the following fields:
%            targetAndBackgroundPixels: [1x1 struct]
%           calibratedCollateralPixels: [1x1 struct]
%                      cosmicRayEvents: [1x1 struct]
%                     cosmicRayMetrics: [1x1 struct]
%                 ldeUndershootMetrics: [1x1 struct]
%                     twoDBlackMetrics: [1x1 struct]
%                    collateralMetrics: [1x1 struct]
%     theoreticalCompressionEfficiency: [1x1 struct]
%        achievedCompressionEfficiency: [1x1 struct]
%                blackAlgorithmApplied: 'blackAlgorithm' copied from calObject 
%                      uncertaintyInfo: []
%
% Non-empty fields are removed from calIntermediateStruct as the data is packaged into the calOutputStruct. Whatever is left of the
% calIntermediateStruct is returned. The calibrated time series for only pixel indices passed into CAL are written to the outputStruct.
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


% extract state file pathname
stateFilePath = calObject.localFilenames.stateFilePath;

% extract data flags
dataFlags = calObject.dataFlags;
isAvailableBlackPix         = dataFlags.isAvailableBlackPix;
isAvailableMaskedBlackPix   = dataFlags.isAvailableMaskedBlackPix;
isAvailableVirtualBlackPix  = dataFlags.isAvailableVirtualBlackPix;
isAvailableMaskedSmearPix   = dataFlags.isAvailableMaskedSmearPix;
isAvailableVirtualSmearPix  = dataFlags.isAvailableVirtualSmearPix;
isAvailableTargetAndBkgPix  = dataFlags.isAvailableTargetAndBkgPix;
processShortCadence         = dataFlags.processShortCadence;
pouEnabled                  = calObject.pouModuleParametersStruct.pouEnabled;
firstCall                   = calObject.firstCall;

%----------------------------------------------------------------------
% copy pipelineInfoStruct from calObject
%----------------------------------------------------------------------
calOutputStruct.pipelineInfoStruct = calObject.pipelineInfoStruct;


%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% calibrated collateral pixel data: set output struct
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

% create empty output structs
emptyShortCadenceBlackStruct = struct('exists', false, 'values', [],'uncertainties', [], 'gapIndicators', []);
emptySmearTimeseries         = struct('values', [],'uncertainties', [],'gapIndicators', [],'column', -1);
emptyBlackTimeseries         = struct('values', [],'uncertainties', [],'gapIndicators', [],'row', -1);
emptyPhotometricTimeseries   = struct('values', [],'uncertainties', [],'gapIndicators', [],'row', -1,'column', -1);

%----------------------------------------------------------------------
% black corrected pixels: set output struct
%----------------------------------------------------------------------
if isAvailableBlackPix
    
    % restore missing black cadence gaps
    calIntermediateStruct.blackGaps(:, calIntermediateStruct.missingBlackCadences) = true;
    
    % output time  series for each input pixel index    
    outputIndexIndicators = ismember(calIntermediateStruct.blackRows, [calObject.blackPixels.row]);
    
    if ~pouEnabled
        blackUncertainties = full( [calIntermediateStruct.blackUncertaintyStruct.deltaRawBlack] );
    else
        [~, temp] = get_primitive_data(calTransformStruct,'residualBlack');
        blackUncertainties = sqrt( temp );
    end
    
    %----------------------------------------------------------------------
    % convert arrays to array of structures for output
    blackValuesCellArray        = num2cell(full(calIntermediateStruct.blackPixels(outputIndexIndicators,:)'), 1);
    blackGapIndicatorsCellArray = num2cell(full(calIntermediateStruct.blackGaps(outputIndexIndicators,:)'), 1);
    blackRowCellArray           = num2cell(full(calIntermediateStruct.blackRows(outputIndexIndicators)));
    blackUncertaintiesCellArray = num2cell(blackUncertainties(outputIndexIndicators,:)', 1);
    
    % deal into new struct arrays
    blackResidualNew = emptyBlackTimeseries;
    
    [blackResidualNew(1:length(blackValuesCellArray)).values] = ...
        deal(blackValuesCellArray{:});
    [blackResidualNew(1:length(blackUncertaintiesCellArray)).uncertainties] = ...
        deal(blackUncertaintiesCellArray{:});
    [blackResidualNew(1:length(blackGapIndicatorsCellArray)).gapIndicators] = ...
        deal(blackGapIndicatorsCellArray{:});
    [blackResidualNew(1:length(blackRowCellArray)).row] = ...
        deal(blackRowCellArray{:});
    
    calibratedCollateralPixels.blackResidual = blackResidualNew;
    
    % remove field(s) from calIntermediateStruct
    calIntermediateStruct = rmfield(calIntermediateStruct,  {'blackPixels','blackGaps','blackRows'});
    
else
    calibratedCollateralPixels.blackResidual = [];
end


%----------------------------------------------------------------------
% masked black corrected pixels: set output struct
%----------------------------------------------------------------------
if isAvailableMaskedBlackPix
    
    % restore filled Mblack cadence gaps
    calIntermediateStruct.mBlackGaps(calIntermediateStruct.missingMblackCadences) = true;
    
    calibratedCollateralPixels.maskedBlackResidual.exists = true;
    calibratedCollateralPixels.maskedBlackResidual.values = colvec( full( calIntermediateStruct.mBlackPixels ) );
    calibratedCollateralPixels.maskedBlackResidual.gapIndicators = colvec( full( calIntermediateStruct.mBlackGaps ) );
    
    if ~pouEnabled
        temp = full( [calIntermediateStruct.blackUncertaintyStruct.deltaRawMblack] );
    else
        [~, temp] = get_primitive_data(calTransformStruct, 'mBlackEstimate');
        temp = sqrt(temp);
    end    
    calibratedCollateralPixels.maskedBlackResidual.uncertainties = colvec( temp );
    clear temp
    
    % remove field(s) from calIntermediateStruct
    calIntermediateStruct = rmfield(calIntermediateStruct,  {'mBlackPixels','mBlackGaps'});
    
else
    calibratedCollateralPixels.maskedBlackResidual = emptyShortCadenceBlackStruct;
end


%----------------------------------------------------------------------
% virtual black corrected pixels: set output struct
%----------------------------------------------------------------------
if isAvailableVirtualBlackPix
    
    % restore filled Vblack cadence gaps
    calIntermediateStruct.vBlackGaps(calIntermediateStruct.missingVblackCadences) = true;
    
    calibratedCollateralPixels.virtualBlackResidual.exists = true;
    calibratedCollateralPixels.virtualBlackResidual.values = colvec( full( calIntermediateStruct.vBlackPixels ) );
    calibratedCollateralPixels.virtualBlackResidual.gapIndicators = colvec( full( calIntermediateStruct.vBlackGaps ) );
    
    if ~pouEnabled
        temp = full( [calIntermediateStruct.blackUncertaintyStruct.deltaRawVblack] );
    else
        [~, temp] = get_primitive_data(calTransformStruct, 'vBlackEstimate');
        temp = sqrt(temp);
    end    
    calibratedCollateralPixels.virtualBlackResidual.uncertainties = colvec( temp );
    clear temp
    
    % remove field(s) from calIntermediateStruct
    calIntermediateStruct = rmfield(calIntermediateStruct,  {'vBlackPixels','vBlackGaps'});
    
else
    calibratedCollateralPixels.virtualBlackResidual = emptyShortCadenceBlackStruct;
end



%----------------------------------------------------------------------
% masked smear corrected pixels: set output struct
%----------------------------------------------------------------------

if isAvailableMaskedSmearPix
    
    % output time  series for each input pixel index    
    outputIndexIndicators = ismember(calIntermediateStruct.mSmearColumns, [calObject.maskedSmearPixels.column]);

    % initial estimate of uncertainties = raw uncertainties scaled by the gain
    gain = calIntermediateStruct.gain;
    
    if ~pouEnabled
        CsmearArray = [calIntermediateStruct.smearUncertaintyStruct.deltaRawMsmear];    % nPixels x nCadences
    else
        [~, Csmear] = get_primitive_data( calTransformStruct, 'mSmearEstimate' );
        CsmearArray = sqrt(Csmear);
    end
    
    if numel(gain) > 1
        gain   = ones(size(CsmearArray,1), 1) * gain(:)';                           % nPixels x nCadences
    end
    
    smearUncertainties = full(CsmearArray .* gain);
    
    %----------------------------------------------------------------------
    % convert arrays to array of structures for output
    mValuesCellArray        = num2cell(full(calIntermediateStruct.mSmearPixels(outputIndexIndicators,:)'), 1);
    mGapIndicatorsCellArray = num2cell(full(calIntermediateStruct.mSmearGaps(outputIndexIndicators,:)'), 1);
    mColumnCellArray        = num2cell(full(calIntermediateStruct.mSmearColumns(outputIndexIndicators)));
    mUncertaintiesCellArray = num2cell(smearUncertainties(outputIndexIndicators,:)', 1);
    
    % deal into new struct arrays
    maskedSmearNew = emptySmearTimeseries;
    
    [maskedSmearNew(1:length(mValuesCellArray)).values] = ...
        deal(mValuesCellArray{:});
    [maskedSmearNew(1:length(mValuesCellArray)).uncertainties] = ...
        deal(mUncertaintiesCellArray{:});
    [maskedSmearNew(1:length(mGapIndicatorsCellArray)).gapIndicators] = ...
        deal(mGapIndicatorsCellArray{:});
    [maskedSmearNew(1:length(mColumnCellArray)).column] = ...
        deal(mColumnCellArray{:});
    
    % save smear to calibrated collateral pixel struct
    calibratedCollateralPixels.maskedSmear = maskedSmearNew;
    
    % remove field(s) from calIntermediateStruct
    calIntermediateStruct = rmfield(calIntermediateStruct, {'mSmearPixels','mSmearGaps','mSmearColumns'} );
    
    
else
    calibratedCollateralPixels.maskedSmear = [];
end


%----------------------------------------------------------------------
% virtual smear corrected pixels: set output struct
%----------------------------------------------------------------------
if isAvailableVirtualSmearPix
    
    % output time  series for each input pixel index    
    outputIndexIndicators = ismember(calIntermediateStruct.vSmearColumns, [calObject.virtualSmearPixels.column]);
 
    % initial estimate of uncertainties = raw uncertainties scaled by the gain
    gain = calIntermediateStruct.gain;
    
    if ~pouEnabled
        CsmearArray = [calIntermediateStruct.smearUncertaintyStruct.deltaRawVsmear];    % nPixels x nCadences
    else
        [~, Csmear] = get_primitive_data( calTransformStruct, 'vSmearEstimate' );
        CsmearArray = sqrt(Csmear);
    end
    
    if numel(gain) > 1
        gain   = ones(size(CsmearArray,1),1) * gain(:)';     % nPixels x nCadences
    end
    
    smearUncertainties = full(CsmearArray .* gain);
    
    %----------------------------------------------------------------------
    % convert arrays to array of structures for output
    vValuesCellArray        = num2cell(full(calIntermediateStruct.vSmearPixels(outputIndexIndicators,:)'), 1);
    vGapIndicatorsCellArray = num2cell(full(calIntermediateStruct.vSmearGaps(outputIndexIndicators,:)'), 1);
    vColumnCellArray        = num2cell(full(calIntermediateStruct.vSmearColumns(outputIndexIndicators)));
    vUncertaintiesCellArray = num2cell(smearUncertainties(outputIndexIndicators,:)', 1);
    
    % deal into new struct arrays
    virtualSmearNew = emptySmearTimeseries;
    
    [virtualSmearNew(1:length(vValuesCellArray)).values] = ...
        deal(vValuesCellArray{:});
    [virtualSmearNew(1:length(vValuesCellArray)).uncertainties] = ...
        deal(vUncertaintiesCellArray{:});
    [virtualSmearNew(1:length(vGapIndicatorsCellArray)).gapIndicators] = ...
        deal(vGapIndicatorsCellArray{:});
    [virtualSmearNew(1:length(vColumnCellArray)).column] = ...
        deal(vColumnCellArray{:});
    
    % save smear to calibrated collateral pixel struct
    calibratedCollateralPixels.virtualSmear = virtualSmearNew;
    
    % remove field(s) from calIntermediateStruct
    calIntermediateStruct = rmfield(calIntermediateStruct, {'vSmearPixels','vSmearGaps','vSmearColumns'} );
    
    
else
    calibratedCollateralPixels.virtualSmear = [];
end


%----------------------------------------------------------------------
% save all calibrated collateral pixel structs to output struct
%----------------------------------------------------------------------
calOutputStruct.calibratedCollateralPixels = calibratedCollateralPixels;
clear calibratedCollateralPixels;

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% photometric pixels: set output struct
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

if isAvailableTargetAndBkgPix

    % Target and background pixels should never be gapped for all cadences. Saving only the ungapped pixels can potentially cause problems
    % in update_calOutput_w_photometric_variance since get_variance_from_POU_struct returns a value for all original input indices, even the
    % all gapped ones. We would have to then go back and figure out which of these values correspond to the all gapped indices and what
    % index in the calOutputStruct the ungapped indices correspond to. The low cost fix is to save all the indices in the calOutputStruct
    % and not worry about having to track the all gapped indices any further.
    
    % initial estimate of uncertainties = raw uncertainties scaled by the gain
    gain = calIntermediateStruct.gain;
    pixelVariableName = calIntermediateStruct.pixelVariableName;
    
    if ~pouEnabled
        CphotoArray = [calIntermediateStruct.photometricUncertaintyStruct.deltaRawPhotometric];     % nPixels x nCadences
    else
        [~, Cphoto] = get_primitive_data( calTransformStruct, pixelVariableName );
        CphotoArray = sqrt(Cphoto);
    end
    
    if numel(gain) > 1
        gain   = ones(size(CphotoArray,1),1) * gain(:)';                                        % nPixels x nCadences
    end
    
    photometricUncertainties = CphotoArray .* gain;                                             % nPixels x nCadences
    
    %----------------------------------------------------------------------
    % convert arrays to array of structures for output
    valuesCellArray = num2cell(calIntermediateStruct.photometricPixels', 1);
    gapIndicatorsCellArray = num2cell(calIntermediateStruct.photometricGaps', 1);
    uncertaintiesCellArray = num2cell(photometricUncertainties', 1);
    
    % row and column are nPixels x 1 arrays
    pixelRow = [calObject.targetAndBkgPixels.row];
    pixelColumn = [calObject.targetAndBkgPixels.column];
    
    rowCellArray = num2cell(pixelRow');
    columnCellArray = num2cell(pixelColumn');
    
    % deal cell arrays into new structure
    targetAndBackgroundPixelsNew = emptyPhotometricTimeseries;
    
    % deal into struct arrays
    [targetAndBackgroundPixelsNew(1:length(valuesCellArray)).values] = ...
        deal(valuesCellArray{:});
    
    [targetAndBackgroundPixelsNew(1:length(gapIndicatorsCellArray)).gapIndicators] = ...
        deal(gapIndicatorsCellArray{:});
    
    [targetAndBackgroundPixelsNew(1:length(uncertaintiesCellArray)).uncertainties] = ...
        deal(uncertaintiesCellArray{:});
    
    [targetAndBackgroundPixelsNew(1:length(columnCellArray)).column] = ...
        deal(columnCellArray{:});
    
    [targetAndBackgroundPixelsNew(1:length(rowCellArray)).row] = ...
        deal(rowCellArray{:});
    
    calOutputStruct.targetAndBackgroundPixels = targetAndBackgroundPixelsNew;
    
    % remove field(s) from calIntermediateStruct
    calIntermediateStruct = rmfield(calIntermediateStruct, {'photometricPixels','photometricGaps'} );    
    calIntermediateStruct = rmfield(calIntermediateStruct, 'blackColumnStart');
    calIntermediateStruct = rmfield(calIntermediateStruct, 'blackColumnEnd');
    calIntermediateStruct = rmfield(calIntermediateStruct, 'mSmearRowStart');
    calIntermediateStruct = rmfield(calIntermediateStruct, 'mSmearRowEnd');
    calIntermediateStruct = rmfield(calIntermediateStruct, 'vSmearRowStart');
    calIntermediateStruct = rmfield(calIntermediateStruct, 'vSmearRowEnd');
    calIntermediateStruct = rmfield(calIntermediateStruct, 'numberOfBlackColumns');
    calIntermediateStruct = rmfield(calIntermediateStruct, 'numberOfMaskedSmearRows');
    calIntermediateStruct = rmfield(calIntermediateStruct, 'numberOfVirtualSmearRows');
else
    calOutputStruct.targetAndBackgroundPixels = [];
end



%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% cosmic ray events: set output struct
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Note: fields have been preallocated to:
%
%   cosmicRayEvents.black = [];
%   cosmicRayEvents.maskedBlack = [];
%   cosmicRayEvents.virtualBlack = [];
%   cosmicRayEvents.maskedSmear = [];
%   cosmicRayEvents.virtualSmear = [];
%
% if cosmic rays are detected, the above will contain structs with fields:
% 'delta', 'rowOrColumn', and 'mjd' for each cosmic ray detected

% extract and remove the cosmicRayEvents field from calIntermediateStruct
cosmicRayEvents = calIntermediateStruct.cosmicRayEvents;

calIntermediateStruct = rmfield(calIntermediateStruct, 'cosmicRayEvents' );

% ensure that the delta arrays (packaged within PA's cosmic ray code) are
% full and not sparse
if processShortCadence
    
    if ~isempty(cosmicRayEvents.black)
        
        % extract pixels and expand the sparse array
        black = cosmicRayEvents.black;
        
        fullDeltaArray = full([black.delta]);
        
        % convert 2D arrays to cell arrays, and deal delta values back
        % into struct arrays
        fullDeltaArrayCellArray = num2cell(fullDeltaArray);
        
        [black(1:length(fullDeltaArrayCellArray)).delta] = ...
            deal(fullDeltaArrayCellArray{:});
        
        cosmicRayEvents.black = black;
    end
    
    if ~isempty(cosmicRayEvents.maskedBlack)
        
        % extract pixels and expand the sparse array
        maskedBlack = cosmicRayEvents.maskedBlack;
        
        fullDeltaArray = full([maskedBlack.delta]);
        
        % convert 2D arrays to cell arrays, and deal delta values back
        % into struct arrays
        fullDeltaArrayCellArray = num2cell(fullDeltaArray);
        
        [maskedBlack(1:length(fullDeltaArrayCellArray)).delta] = ...
            deal(fullDeltaArrayCellArray{:});
        
        cosmicRayEvents.maskedBlack = maskedBlack;
    end
    
    if ~isempty(cosmicRayEvents.virtualBlack)
        
        % extract pixels and expand the sparse array
        virtualBlack = cosmicRayEvents.virtualBlack;
        
        fullDeltaArray = full([virtualBlack.delta]);
        
        % convert 2D arrays to cell arrays, and deal delta values back
        % into struct arrays
        fullDeltaArrayCellArray = num2cell(fullDeltaArray);
        
        [virtualBlack(1:length(fullDeltaArrayCellArray)).delta] = ...
            deal(fullDeltaArrayCellArray{:});
        
        cosmicRayEvents.virtualBlack = virtualBlack;
    end
    
    if ~isempty(cosmicRayEvents.virtualSmear)
        
        % extract pixels and expand the sparse array
        virtualSmear = cosmicRayEvents.virtualSmear;
        
        fullDeltaArray = full([virtualSmear.delta]);
        
        % convert 2D arrays to cell arrays, and deal delta values back
        % into struct arrays
        fullDeltaArrayCellArray = num2cell(fullDeltaArray);
        
        [virtualSmear(1:length(fullDeltaArrayCellArray)).delta] = ...
            deal(fullDeltaArrayCellArray{:});
        
        cosmicRayEvents.virtualSmear = virtualSmear;
    end
    
    if ~isempty(cosmicRayEvents.maskedSmear)
        
        % extract pixels and expand the sparse array
        maskedSmear = cosmicRayEvents.maskedSmear;
        
        fullDeltaArray = full([maskedSmear.delta]);
        
        % convert 2D arrays to cell arrays, and deal delta values back
        % into struct arrays
        fullDeltaArrayCellArray = num2cell(fullDeltaArray);
        
        [maskedSmear(1:length(fullDeltaArrayCellArray)).delta] = ...
            deal(fullDeltaArrayCellArray{:});
        
        cosmicRayEvents.maskedSmear = maskedSmear;
    end
end
calOutputStruct.cosmicRayEvents = cosmicRayEvents;


%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% cosmic ray metrics: set output struct
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Note: fields have been preallocated to:
%
% cosmicRayMetricsEmptyStruct = struct('exists', false, ...
%     'hitRates', [], 'hitRateGapIndicators', [], ...
%     'meanEnergy', [], 'meanEnergyGapIndicators', [], ...
%     'energyVariance', [], 'energyVarianceGapIndicators', [], ...
%     'energySkewness', [], 'energySkewnessGapIndicators', [], ...
%     'energyKurtosis', [], 'energyKurtosisGapIndicators', []);


% add cosmicRayMetrics with above fields to output struct
calOutputStruct.cosmicRayMetrics.blackCosmicRayMetrics          = calIntermediateStruct.blackCosmicRayMetrics;
calOutputStruct.cosmicRayMetrics.maskedBlackCosmicRayMetrics    = calIntermediateStruct.maskedBlackCosmicRayMetrics;
calOutputStruct.cosmicRayMetrics.virtualBlackCosmicRayMetrics   = calIntermediateStruct.virtualBlackCosmicRayMetrics;
calOutputStruct.cosmicRayMetrics.maskedSmearCosmicRayMetrics    = calIntermediateStruct.maskedSmearCosmicRayMetrics;
calOutputStruct.cosmicRayMetrics.virtualSmearCosmicRayMetrics   = calIntermediateStruct.virtualSmearCosmicRayMetrics;

% remove field(s) from calIntermediateStruct
calIntermediateStruct = rmfield(calIntermediateStruct,...
    {'blackCosmicRayMetrics',...
    'maskedBlackCosmicRayMetrics',...
    'virtualBlackCosmicRayMetrics',...
    'maskedSmearCosmicRayMetrics',...
    'virtualSmearCosmicRayMetrics'} );

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% collateral metrics: set output struct
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
if (isempty(calIntermediateStruct.collateralMetrics))
    
    % create empty output struct
    collateralMetricsEmptyStruct = struct('values', [], 'uncertainties', [], 'gapIndicators', []);    
    collateralMetrics.blackLevelMetrics  = collateralMetricsEmptyStruct;
    collateralMetrics.smearLevelMetrics  = collateralMetricsEmptyStruct;
    collateralMetrics.darkCurrentMetrics = collateralMetricsEmptyStruct;    
    calOutputStruct.collateralMetrics    = collateralMetrics;
    
else
    % add collateralMetrics to output struct
    calOutputStruct.collateralMetrics = calIntermediateStruct.collateralMetrics;
    
    % remove field(s) from calIntermediateStruct
    calIntermediateStruct = rmfield(calIntermediateStruct, 'collateralMetrics' );
end


%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% theoretical and achieved compression efficiency: set output struct
%
% These fields are computed in the controller after collateral/photometric
% pixel calibration is complete
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

% create empty output struct for cases in which compression is unavailable
compressionEmptyStruct = struct('values', [], 'nCodeSymbols', [], 'gapIndicators', []);

calOutputStruct.theoreticalCompressionEfficiency = compressionEmptyStruct;
calOutputStruct.achievedCompressionEfficiency = compressionEmptyStruct;

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% lde undershoot and 2D black metrics: set output struct
%
% These fields are computed in the controller after collateral/photometric
% pixel calibration is complete
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
calOutputStruct.ldeUndershootMetrics = [];
calOutputStruct.twoDBlackMetrics     = [];

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Write the black algorithm name used to the output struct. This comes from the calObject
% so it will be whatever was actually applied to the data which may have overridden the 
% input module parameter. If blackAlgorithm is 'dynablack' also write dynablackCoeffType
% based on the module parameters which have been dynamically determined.
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
blackAlgorithmApplied = calObject.moduleParametersStruct.blackAlgorithm;

if strcmpi(blackAlgorithmApplied, 'dynablack')
    if all([calObject.dynoblackModels.dynoblackConfigStruct.useRobustVerticalCoeffs, ...
            calObject.dynoblackModels.dynoblackConfigStruct.useRobustFrameFgsCoeffs, ...
            calObject.dynoblackModels.dynoblackConfigStruct.useRobustParallelFgsCoeffs])
        
        dynablackCoeffType = 'robust';
    else
        dynablackCoeffType = 'regress';
    end
else
    dynablackCoeffType = [];
end

calOutputStruct.blackAlgorithmApplied = blackAlgorithmApplied;
calOutputStruct.dynablackCoeffType = dynablackCoeffType;

% append black algorithm and coefficient type to black levels state file
if firstCall
    save([stateFilePath,'cal_black_levels.mat'], 'dynablackCoeffType', 'blackAlgorithmApplied', '-append');
end

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Add alerts to output struct
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
calOutputStruct.alerts = [];

return;
