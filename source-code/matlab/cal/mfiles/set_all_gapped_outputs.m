function [outputsStruct] = set_all_gapped_outputs(inputsStruct)
% function [outputsStruct] = set_all_gapped_outputs(inputsStruct)
%
% This CAL function produces a CAL outputsStruct containing all gapped time series for any pixel that appears in the inputsStruct. The
% length of the time series matches that defined by cadenceTimes. The values and the unceratinties of the all gapped time series are set to
% default values (0 and -1 respectively). Collateral metric time series are also gapped for each cadence and contain default values. Cosmic
% ray events and cosmic ray metrics are structs with empty fields. Theoretical and achieved compression efficiency are structs with empty
% fields. No state files or blobs are produced. Pixel indexing is assumed 0-based 
% in the inputsStruct and is zero based in the outputsStruct.
% 
% This function should only be called when CAL java has determined that all gapped output is required fom CAL MATLAB
% 
% INPUT:
% inputsStruct is a CAL inputsStruct as defined in cal_matlab_controller + 'dataFlags' field added by running add_cal_data_flags on the CAL inputsStruct
%
% OUTPUT:
% outputsStruct is a structure containg the follwoing fields: 
%                   pipelineInfoStruct: [1x1 struct]        copied from inputsStruct.pipelineInfoStruct
%           calibratedCollateralPixels: [1x1 struct]        any collateral pixel appearing in the CAL inputsStruct will contain an all
%                                                           gapped timeseries
%            targetAndBackgroundPixels: [1xnPixels struct]  any photometric pixel appearing in the CAL inputsStruct will contain an all
%                                                           gapped timeseries
%                      cosmicRayEvents: [1x1 struct]        fields will be empty
%                     cosmicRayMetrics: [1x1 struct]        fields will be empty
%                    collateralMetrics: [1x1 struct]        fields of each subfield will contain all gapped time series
%     theoreticalCompressionEfficiency: [1x1 struct]        fields will be empty
%        achievedCompressionEfficiency: [1x1 struct]        fields will be empty
%                 ldeUndershootMetrics: []
%                     twoDBlackMetrics: []
%                blackAlgorithmApplied: ''
%                   dynablackCoeffType: ''
%                               alerts: []
%              uncertaintyBlobFileName: ''
%             oneDBlackFitBlobFileName: ''
%                    smearBlobFileName: ''
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

% hard coded defaults
DEFAULT_VALUE = 0;
DEFAULT_UNC = -1;

% extract ccd dimensions and timeseries length
nCcdRows    = inputsStruct.fcConstants.CCD_ROWS;
nCcdColumns = inputsStruct.fcConstants.CCD_COLUMNS;
nCadences = length(inputsStruct.cadenceTimes.cadenceNumbers);

% create all gapped and empty timeseries templates 
allGappedTimeseries = struct('values', DEFAULT_VALUE .* ones(nCadences,1),...
                                'uncertainties', DEFAULT_UNC .* ones(nCadences,1),...
                                'gapIndicators', true(nCadences,1));
emptyTimeseries = struct('values', [], 'uncertainties', [], 'gapIndicators', []); 

% extract data flags from inputs
dataFlags = inputsStruct.dataFlags;
isAvailableBlackPix         = dataFlags.isAvailableBlackPix;
isAvailableMaskedBlackPix   = dataFlags.isAvailableMaskedBlackPix;
isAvailableVirtualBlackPix  = dataFlags.isAvailableVirtualBlackPix;
isAvailableMaskedSmearPix   = dataFlags.isAvailableMaskedSmearPix;
isAvailableVirtualSmearPix  = dataFlags.isAvailableVirtualSmearPix;
isAvailableTargetAndBkgPix  = dataFlags.isAvailableTargetAndBkgPix;

% set pipelineInfoStruct from inputsStruct
outputsStruct.pipelineInfoStruct = inputsStruct.pipelineInfoStruct;

% set collateral pixels
emptyShortCadenceBlackStruct = struct('exists', false, 'values', [],'uncertainties', [], 'gapIndicators', []);
emptySmearTimeseries         = struct('values', [],'uncertainties', [],'gapIndicators', [],'column', -1);
emptyBlackTimeseries         = struct('values', [],'uncertainties', [],'gapIndicators', [],'row', -1);
emptyPhotometricTimeseries   = struct('values', [],'uncertainties', [],'gapIndicators', [],'row', -1,'column', -1);

% black corrected pixels
if isAvailableBlackPix    
    blackPixels = DEFAULT_VALUE .* ones(nCcdRows, nCadences);
    blackUncertainties = DEFAULT_UNC .* ones(nCcdRows, nCadences);
    blackGaps   = true(nCcdRows, nCadences);
    blackRows   = zeros(nCcdRows, 1);
        
    % read input row indices - zero based
    blackRows([inputsStruct.blackPixels.row]'+1) = [inputsStruct.blackPixels.row]';

    % output time  series for each input pixel index - zero based
    outputIndexIndicators = ismember(1:nCcdRows, [inputsStruct.blackPixels.row]+1);
    
    % convert arrays to array of structures for output
    blackValuesCellArray        = num2cell(blackPixels(outputIndexIndicators,:)', 1);
    blackGapIndicatorsCellArray = num2cell(blackGaps(outputIndexIndicators,:)', 1);
    blackRowCellArray           = num2cell(blackRows(outputIndexIndicators));
    blackUncertaintiesCellArray = num2cell(blackUncertainties(outputIndexIndicators,:)', 1);
    
    % deal into new struct arrays
    blackResidualNew = emptyBlackTimeseries;    
    [blackResidualNew(1:length(blackValuesCellArray)).values] = deal(blackValuesCellArray{:});
    [blackResidualNew(1:length(blackUncertaintiesCellArray)).uncertainties] = deal(blackUncertaintiesCellArray{:});
    [blackResidualNew(1:length(blackGapIndicatorsCellArray)).gapIndicators] = deal(blackGapIndicatorsCellArray{:});
    [blackResidualNew(1:length(blackRowCellArray)).row] = deal(blackRowCellArray{:});    
    calibratedCollateralPixels.blackResidual = blackResidualNew;   
else
    calibratedCollateralPixels.blackResidual = [];
end

% masked black corrected pixels
if isAvailableMaskedBlackPix    
    calibratedCollateralPixels.maskedBlackResidual.exists = true;
    calibratedCollateralPixels.maskedBlackResidual.values = DEFAULT_VALUE .* ones(nCadences, 1);
    calibratedCollateralPixels.maskedBlackResidual.uncertainties = DEFAULT_UNC .* ones(nCadences, 1);
    calibratedCollateralPixels.maskedBlackResidual.gapIndicators = true(nCadences, 1);    
else
    calibratedCollateralPixels.maskedBlackResidual = emptyShortCadenceBlackStruct;
end

% virtual black corrected pixels
if isAvailableVirtualBlackPix    
    calibratedCollateralPixels.virtualBlackResidual.exists = true;
    calibratedCollateralPixels.virtualBlackResidual.values = DEFAULT_VALUE .* ones(nCadences, 1);
    calibratedCollateralPixels.virtualBlackResidual.uncertainties = DEFAULT_UNC .* ones(nCadences, 1);
    calibratedCollateralPixels.virtualBlackResidual.gapIndicators = true(nCadences, 1);
else
    calibratedCollateralPixels.virtualBlackResidual = emptyShortCadenceBlackStruct;
end

% masked smear corrected pixels
if isAvailableMaskedSmearPix    
    mSmearPixels    = DEFAULT_VALUE .* ones(nCcdColumns, nCadences);        % nCcdColumns x nCadences
    smearUncertainties = DEFAULT_UNC .* ones(nCcdColumns, nCadences);       % nCcdColumns x nCadences
    mSmearGaps      = true(nCcdColumns, nCadences);                         % nCcdColumns x nCadences
    mSmearColumns   = zeros(nCcdColumns, 1);                                % nCcdColumns x 1
    
    % read input column indices - zero based
    mSmearColumns([inputsStruct.maskedSmearPixels.column]'+1) = [inputsStruct.maskedSmearPixels.column]';
    
    % output time  series for each input pixel index    
    outputIndexIndicators = ismember(1:nCcdColumns, [inputsStruct.maskedSmearPixels.column]+1);

    % convert arrays to array of structures for output
    mValuesCellArray        = num2cell(mSmearPixels(outputIndexIndicators,:)', 1);
    mGapIndicatorsCellArray = num2cell(mSmearGaps(outputIndexIndicators,:)', 1);
    mColumnCellArray        = num2cell(mSmearColumns(outputIndexIndicators));
    mUncertaintiesCellArray = num2cell(smearUncertainties(outputIndexIndicators,:)', 1);
    
    % deal into new struct arrays
    maskedSmearNew = emptySmearTimeseries;    
    [maskedSmearNew(1:length(mValuesCellArray)).values] = deal(mValuesCellArray{:});
    [maskedSmearNew(1:length(mValuesCellArray)).uncertainties] = deal(mUncertaintiesCellArray{:});
    [maskedSmearNew(1:length(mGapIndicatorsCellArray)).gapIndicators] = deal(mGapIndicatorsCellArray{:});
    [maskedSmearNew(1:length(mColumnCellArray)).column] = deal(mColumnCellArray{:});
    
    % save smear to calibrated collateral pixel struct
    calibratedCollateralPixels.maskedSmear = maskedSmearNew;    
else
    calibratedCollateralPixels.maskedSmear = [];
end

% virtual smear corrected pixels
if isAvailableVirtualSmearPix    
    vSmearPixels    = DEFAULT_VALUE .* ones(nCcdColumns, nCadences);        % nCcdColumns x nCadences
    smearUncertainties = DEFAULT_UNC .* ones(nCcdColumns, nCadences);       % nCcdColumns x nCadences
    vSmearGaps      = true(nCcdColumns, nCadences);                         % nCcdColumns x nCadences
    vSmearColumns   = zeros(nCcdColumns, 1);                                % nCcdColumns x 1
    
    % read input column indices - zero based
    vSmearColumns([inputsStruct.maskedSmearPixels.column]'+1) = [inputsStruct.maskedSmearPixels.column]';
    
    % output time  series for each input pixel index    
    outputIndexIndicators = ismember(1:nCcdColumns, [inputsStruct.maskedSmearPixels.column]+1);

    % convert arrays to array of structures for output
    vValuesCellArray        = num2cell(vSmearPixels(outputIndexIndicators,:)', 1);
    vGapIndicatorsCellArray = num2cell(vSmearGaps(outputIndexIndicators,:)', 1);
    vColumnCellArray        = num2cell(vSmearColumns(outputIndexIndicators));
    vUncertaintiesCellArray = num2cell(smearUncertainties(outputIndexIndicators,:)', 1);
    
    % deal into new struct arrays
    virtualSmearNew = emptySmearTimeseries;    
    [virtualSmearNew(1:length(vValuesCellArray)).values] = deal(vValuesCellArray{:});
    [virtualSmearNew(1:length(vValuesCellArray)).uncertainties] = deal(vUncertaintiesCellArray{:});
    [virtualSmearNew(1:length(vGapIndicatorsCellArray)).gapIndicators] = deal(vGapIndicatorsCellArray{:});
    [virtualSmearNew(1:length(vColumnCellArray)).column] = deal(vColumnCellArray{:});
    
    % save smear to calibrated collateral pixel struct
    calibratedCollateralPixels.virtualSmear = virtualSmearNew;    
else
    calibratedCollateralPixels.virtualSmear = [];
end

% set calibrated collateral pixel output
outputsStruct.calibratedCollateralPixels = calibratedCollateralPixels;

% set photometric pixel data
if isAvailableTargetAndBkgPix    
    % row and column are nPixels x 1 arrays
    pixelRow = [inputsStruct.targetAndBkgPixels.row];
    pixelColumn = [inputsStruct.targetAndBkgPixels.column];
    nPixels = length(pixelRow);
    
    photometricPixels = DEFAULT_VALUE .* ones(nPixels, nCadences);
    photometricUncertainties = DEFAULT_UNC .* ones(nPixels, nCadences);
    photometricGaps = true(nPixels, nCadences);
    
    % convert arrays to array of structures for output
    valuesCellArray = num2cell(photometricPixels', 1);
    gapIndicatorsCellArray = num2cell(photometricGaps', 1);
    uncertaintiesCellArray = num2cell(photometricUncertainties', 1);
    
    rowCellArray = num2cell(pixelRow');
    columnCellArray = num2cell(pixelColumn');
    
    % deal cell arrays into new structure
    targetAndBackgroundPixelsNew = emptyPhotometricTimeseries;    
    % deal into struct arrays
    [targetAndBackgroundPixelsNew(1:length(valuesCellArray)).values] = deal(valuesCellArray{:});    
    [targetAndBackgroundPixelsNew(1:length(gapIndicatorsCellArray)).gapIndicators] = deal(gapIndicatorsCellArray{:});    
    [targetAndBackgroundPixelsNew(1:length(uncertaintiesCellArray)).uncertainties] = deal(uncertaintiesCellArray{:});    
    [targetAndBackgroundPixelsNew(1:length(columnCellArray)).column] = deal(columnCellArray{:});    
    [targetAndBackgroundPixelsNew(1:length(rowCellArray)).row] = deal(rowCellArray{:}); 
    
    % set calibrated photometric pixel output
    outputsStruct.targetAndBackgroundPixels = targetAndBackgroundPixelsNew;
else
    outputsStruct.targetAndBackgroundPixels = [];
end

% set empty cosmic ray events
outputsStruct.cosmicRayEvents = struct('black',[],...
                                        'maskedBlack',[],...
                                        'virtualBlack',[],...
                                        'maskedSmear',[],...
                                        'virtualSmear',[]);

% set empty cosmic ray metrics
cosmicRayMetricsEmptyStruct = struct('exists', false, ...
    'hitRates', [], 'hitRateGapIndicators', [], ...
    'meanEnergy', [], 'meanEnergyGapIndicators', [], ...
    'energyVariance', [], 'energyVarianceGapIndicators', [], ...
    'energySkewness', [], 'energySkewnessGapIndicators', [], ...
    'energyKurtosis', [], 'energyKurtosisGapIndicators', []);

cosmicRayMetrics.blackCosmicRayMetrics        = cosmicRayMetricsEmptyStruct;
cosmicRayMetrics.maskedBlackCosmicRayMetrics  = cosmicRayMetricsEmptyStruct;
cosmicRayMetrics.virtualBlackCosmicRayMetrics = cosmicRayMetricsEmptyStruct;
cosmicRayMetrics.maskedSmearCosmicRayMetrics  = cosmicRayMetricsEmptyStruct;
cosmicRayMetrics.virtualSmearCosmicRayMetrics = cosmicRayMetricsEmptyStruct;
outputsStruct.cosmicRayMetrics = cosmicRayMetrics;

% set collateral metrics
if inputsStruct.firstCall
    thisTimeseries = allGappedTimeseries;
else
    thisTimeseries = emptyTimeseries;
end
collateralMetrics.blackLevelMetrics = thisTimeseries;
collateralMetrics.smearLevelMetrics = thisTimeseries;
collateralMetrics.darkCurrentMetrics = thisTimeseries;
outputsStruct.collateralMetrics = collateralMetrics;

% set empty theoretical and achieved compression efficiency
compressionEmptyStruct = struct('values', [], 'nCodeSymbols', [], 'gapIndicators', []);
outputsStruct.theoreticalCompressionEfficiency = compressionEmptyStruct;
outputsStruct.achievedCompressionEfficiency = compressionEmptyStruct;

% set empty lde undershoot and 2D black metrics
outputsStruct.ldeUndershootMetrics = [];
outputsStruct.twoDBlackMetrics     = [];

% set empty black correction algorithm fields
outputsStruct.blackAlgorithmApplied = inputsStruct.moduleParametersStruct.blackAlgorithm;
outputsStruct.dynablackCoeffType = '';

% set empty alerts and blob filenames
outputsStruct.alerts = [];
outputsStruct.uncertaintyBlobFileName = '';
outputsStruct.oneDBlackFitBlobFileName = '';
outputsStruct.smearBlobFileName = '';

return;
