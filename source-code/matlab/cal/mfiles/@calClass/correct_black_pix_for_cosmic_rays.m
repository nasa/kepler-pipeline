function [calObject, calIntermediateStruct, numBlackCrEventsArray] = ...
    correct_black_pix_for_cosmic_rays(calObject, calIntermediateStruct)
%function [calObject, calIntermediateStruct] = ...
%    correct_black_pix_for_cosmic_rays(calObject, calIntermediateStruct)
%
% This function corrects black collateral pixels for cosmic rays (including
% masked black and virtual black for short cadence data).
%
% The pixel arrays are input into clean_cosmic_rays_mad, which outputs the
% corrected pixels along with a structure with the events indicators (cosmic
% ray event deltas, which are the difference between the cleaned pixels and
% original pixels, and the rows/columns and mjd timestamps).
%
% A set of metrics (cosmic ray hit rates and energy) are then computed with
% compute_cosmic_ray_metrics, and results are saved to calIntermediateStruct
%
%
% INPUTS/OUTPUTS:
%  calObject
%  calIntermediateStruct
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


% initialize event arrays
numBlackCrEventsArray = [];
numMblackCrEventsArray = [];            %#ok<NASGU>
numVblackCrEventsArray = [];            %#ok<NASGU>

% extract timestamp (mjds)
cadenceTimes = calObject.cadenceTimes;
timestamp = cadenceTimes.timestamp;
timestampGapIndicators = cadenceTimes.gapIndicators;
excludeIndicators = cadenceTimes.dataAnomalyFlags.excludeIndicators;


% extract data flags
processLongCadence  = calObject.dataFlags.processLongCadence;
processShortCadence = calObject.dataFlags.processShortCadence;
isAvailableMaskedBlackPix = calObject.dataFlags.isAvailableMaskedBlackPix;
isAvailableVirtualBlackPix = calObject.dataFlags.isAvailableVirtualBlackPix;
enableExcludeIndicators = calObject.moduleParametersStruct.enableExcludeIndicators;
enableExcludePreserve = calObject.moduleParametersStruct.enableExcludePreserve;

% extract config map parameters
ccdReadTime = calIntermediateStruct.ccdReadTime;  % scalar or (nCadences x 1)

%--------------------------------------------------------------------------
% extract black pixels, gaps, and row arrays
%--------------------------------------------------------------------------
blackPixels = calIntermediateStruct.blackPixels;        % nPixels x nCadences
blackGaps   = calIntermediateStruct.blackGaps;          % nPixels x nCadences

% update gaps based on exclude indicators
if enableExcludeIndicators && enableExcludePreserve
    blackGaps = blackGaps | repmat(excludeIndicators(:)',size(blackGaps,1),1);
end


% include masked/virtual black pixels in black cosmic ray detection
% algorithm if they are available
if processShortCadence
    
    % get smear rows that were summed onboard spacecraft to find the mean
    % value, which will be the 'row' of the masked or virtual black pixel value
    mSmearRowStart   = calIntermediateStruct.mSmearRowStart;
    mSmearRowEnd     = calIntermediateStruct.mSmearRowEnd;
    vSmearRowStart   = calIntermediateStruct.vSmearRowStart;
    vSmearRowEnd     = calIntermediateStruct.vSmearRowEnd;
    
    if numel(mSmearRowStart) > 1 && numel(mSmearRowEnd) > 1
        
        mSmearRows = [mSmearRowStart mSmearRowEnd];
        validMsmearRows = mSmearRows(~timestampGapIndicators, :);
    else
        validMsmearRows = [mSmearRowStart mSmearRowEnd];
    end
    
    if numel(vSmearRowStart) > 1 && numel(vSmearRowEnd) > 1
        
        vSmearRows = [vSmearRowStart vSmearRowEnd];
        validVsmearRows = vSmearRows(~timestampGapIndicators, :);
    else
        validVsmearRows = [vSmearRowStart vSmearRowEnd];
    end
    
    
    if isAvailableMaskedBlackPix
        
        %--------------------------------------------------------------------------
        % extract masked black pixels and gaps
        %--------------------------------------------------------------------------
        mBlackPixels = calIntermediateStruct.mBlackPixels;  % nCadences x 1
        mBlackRows   = round(mean(validMsmearRows, 2));     % nCadences x 1
        mBlackGaps   = calIntermediateStruct.mBlackGaps;    % nCadences x 1
        
        % update gaps based on exclude indicators
        if enableExcludeIndicators && enableExcludePreserve
            mBlackGaps = mBlackGaps | excludeIndicators;
        end
                
        % update black pixel arrays to include masked black pixel value
        blackPixels(round(mean(mBlackRows)), :) = mBlackPixels;
        blackGaps(round(mean(mBlackRows)), :)   = mBlackGaps;
    end
    
    if isAvailableVirtualBlackPix
        
        %--------------------------------------------------------------------------
        % extract virtual black pixels and gaps
        %--------------------------------------------------------------------------
        vBlackPixels = calIntermediateStruct.vBlackPixels;  % nCadences x 1
        vBlackRows   = round(mean(validVsmearRows, 2));     % nCadences x 1
        vBlackGaps   = calIntermediateStruct.vBlackGaps;    % nCadences x 1        
        
        % update gaps based on exclude indicators
        if enableExcludeIndicators && enableExcludePreserve
            vBlackGaps = vBlackGaps | excludeIndicators;
        end        
        
        % update black pixel arrays to include virtual black pixel value
        blackPixels(round(mean(vBlackRows)), :) = vBlackPixels;
        blackGaps(round(mean(vBlackRows)), :)   = vBlackGaps;
    end
end


%----------------------------------------------------------------------
% clean black pixel time series for cosmic rays
%----------------------------------------------------------------------
% extract cosmic ray parameters from the module interface, which include:
%
%   detrendOrder
%   medianFilterLength
%   madThreshold
%   thresholdMultiplier
%   consecutiveCosmicRayCleaningEnabled
%   twoSidedFinalThresholdingEnabled
%   madWindowLength

display('CAL:correct_black_pix_for_cosmic_rays: Correcting black for cosmic rays ...');

cosmicRayParametersStruct = calObject.cosmicRayParametersStruct;

switch lower(cosmicRayParametersStruct.cosmicRayCleaningMethod)
    case 'mad'
        % transpose inputs to nCadences x nPixels
        [blackPixelsCosmicRayCorrected, cosmicRayEventsIndicators] = ...
            clean_cosmic_rays_mad(blackPixels', blackGaps', ...
                cosmicRayParametersStruct);
    case 'ar'
        calBlackCosmicRayCleanerObject = ...
            calBlackCosmicRayCleanerClass(calObject, calIntermediateStruct);
        returnSparse = issparse(calIntermediateStruct.blackPixels);
        [blackPixelsCosmicRayCorrected, cosmicRayEventsIndicators] = ...
            calBlackCosmicRayCleanerObject.get_corrected_flux_and_event_indicator_matrices(returnSparse);
    otherwise
        error('correct_black_pix_for_cosmic_rays: Invalid cleaning method.');
end

% transpose results to nPixelsxnCadences
blackPixelsCosmicRayCorrected = blackPixelsCosmicRayCorrected';
cosmicRayEventsIndicators     = cosmicRayEventsIndicators';

cosmicRaysDetectedFlag = any(cosmicRayEventsIndicators( : ));

if ~cosmicRaysDetectedFlag
    warning('CAL:correct_black_pix_for_cosmic_rays:NoCosmicRaysDetected', ...
        'No cosmic rays detected in black pixel region.');
end


% populate the output structure
if cosmicRaysDetectedFlag
    
    [rowOrColumn, indices] = find(cosmicRayEventsIndicators);
    
    delta = blackPixels(cosmicRayEventsIndicators) - blackPixelsCosmicRayCorrected(cosmicRayEventsIndicators);
    mjd   = timestamp(indices);
    
    % allocate structure
    pixelsWithCosmicRayHits = repmat(struct('rowOrColumn', [], ...
        'delta', [], 'indices', [], 'mjd', []), 1, length(mjd) );
    
    % convert arrays to cell arrays
    deltasCellArray       = num2cell(delta);
    indicesCellArray      = num2cell(indices);
    rowOrColumnCellArray  = num2cell(rowOrColumn);
    mjdCellArray          = num2cell(mjd);
    
    % deal back into individual struct arrays
    [pixelsWithCosmicRayHits(1:length(deltasCellArray)).delta] = deal(deltasCellArray{:});
    [pixelsWithCosmicRayHits(1:length(indicesCellArray)).indices] = deal(indicesCellArray{:});
    [pixelsWithCosmicRayHits(1:length(rowOrColumnCellArray)).rowOrColumn] = deal(rowOrColumnCellArray{:});
    [pixelsWithCosmicRayHits(1:length(mjdCellArray)).mjd] = deal(mjdCellArray{:});
    
    % check for and remove any duplicates
    [pixelsWithCosmicRayHits] = correct_for_duplicate_cosmic_rays(pixelsWithCosmicRayHits);
else
    pixelsWithCosmicRayHits = [];
end


%--------------------------------------------------------------------------
% overwrite cosmic ray corrected pixels into intermediate struct
%--------------------------------------------------------------------------

if processLongCadence && cosmicRaysDetectedFlag
    
    % only black pixels are corrected (masked/virtual black structs remain empty)
    calIntermediateStruct.blackPixels = blackPixelsCosmicRayCorrected;
    
elseif processShortCadence && cosmicRaysDetectedFlag
    
    % extract masked/virtual black pixel values that were combined with black
    mBlackRow = round(mean(mBlackRows));
    vBlackRow = round(mean(vBlackRows));
    
    mBlackPixelsCosmicRayCorrected = blackPixelsCosmicRayCorrected(mBlackRow, :);
    vBlackPixelsCosmicRayCorrected = blackPixelsCosmicRayCorrected(vBlackRow, :);
    
    % remove masked/virtual black from black pixel array
    blackPixelsCosmicRayCorrected(mBlackRow, :) = calIntermediateStruct.blackPixels(mBlackRow, :);
    blackPixelsCosmicRayCorrected(vBlackRow, :) = calIntermediateStruct.blackPixels(vBlackRow, :);
    
    % overwrite values in intermediate struct for further calibration
    if( issparse(calIntermediateStruct.blackPixels) )
        calIntermediateStruct.blackPixels  = sparse(blackPixelsCosmicRayCorrected);
    else
        calIntermediateStruct.blackPixels  = blackPixelsCosmicRayCorrected;
    end
    
    calIntermediateStruct.mBlackPixels = mBlackPixelsCosmicRayCorrected;
    calIntermediateStruct.vBlackPixels = vBlackPixelsCosmicRayCorrected;
end

%--------------------------------------------------------------------------
% compute cosmic ray metrics if any cosmic rays were detected
%--------------------------------------------------------------------------

% create empty struct for cases in which metrics are unavailable
cosmicRayMetricsEmptyStruct = struct('exists', false, ...
    'hitRates', [], 'hitRateGapIndicators', [], ...
    'meanEnergy', [], 'meanEnergyGapIndicators', [], ...
    'energyVariance', [], 'energyVarianceGapIndicators', [], ...
    'energySkewness', [], 'energySkewnessGapIndicators', [], ...
    'energyKurtosis', [], 'energyKurtosisGapIndicators', []);


%--------------------------------------------------------------------------
% if *no* cosmic ray events are detected, set structs to empty and return
if ~cosmicRaysDetectedFlag
    
    calIntermediateStruct.cosmicRayEvents.black = [];
    calIntermediateStruct.cosmicRayEvents.maskedBlack = [];
    calIntermediateStruct.cosmicRayEvents.virtualBlack = [];
    
    calIntermediateStruct.blackCosmicRayMetrics = cosmicRayMetricsEmptyStruct;
    calIntermediateStruct.maskedBlackCosmicRayMetrics = cosmicRayMetricsEmptyStruct;
    calIntermediateStruct.virtualBlackCosmicRayMetrics = cosmicRayMetricsEmptyStruct;
    
    calIntermediateStruct.numBlackCrEventsArray = [];

    return;
end

%--------------------------------------------------------------------------
% if cosmic ray events *are* detected, the following fields will be
% available:
%
%     pixelsWithCosmicRayHits.delta
%     pixelsWithCosmicRayHits.indices
%     pixelsWithCosmicRayHits.rowOrColumn
%     pixelsWithCosmicRayHits.mjd

% extract time pixels were exposed to possible cosmic rays
numCcdRows = calObject.fcConstants.CCD_ROWS;

timeBlackPixExposedInSec   = ccdReadTime ./ numCcdRows;
timeMblackPixExposedInSec  = ccdReadTime ./ numCcdRows;
timeVblackPixExposedInSec  = ccdReadTime ./ numCcdRows;

if processLongCadence
    
    numberOfBlackColumns = calIntermediateStruct.numberOfBlackColumns; % scalar or (nCadences x 1)
    
    blackPixelsWithCosmicRayHits = pixelsWithCosmicRayHits;
    mBlackPixelsWithCosmicRayHits = [];                         % no events
    vBlackPixelsWithCosmicRayHits = [];                         % no events
    
    %---------------------------------------------------------------------
    % compute black cosmic ray metrics
    %---------------------------------------------------------------------
    [blackCosmicRayMetrics, numBlackCrEventsArray] = compute_cosmic_ray_metrics(calObject, calIntermediateStruct, ...
        blackGaps, blackPixelsWithCosmicRayHits, timeBlackPixExposedInSec, numberOfBlackColumns);
    
    mBlackCosmicRayMetrics = cosmicRayMetricsEmptyStruct;      % no metrics
    vBlackCosmicRayMetrics = cosmicRayMetricsEmptyStruct;      % no metrics

    
elseif processShortCadence
    
    %----------------------------------------------------------------------
    % separate cosmic ray hits for black, masked black, and virtual black in
    % order to compute metrics for each pixel type
    %----------------------------------------------------------------------
    
    numberOfBlackColumns = calIntermediateStruct.numberOfBlackColumns; % scalar or (nCadences x 1)
    
    rowOrColumn = [pixelsWithCosmicRayHits.rowOrColumn]';  % nEvents x 1
    delta       = [pixelsWithCosmicRayHits.delta]';        % nEvents x 1
    indices     = [pixelsWithCosmicRayHits.indices]';      % nEvents x 1
    mjd         = [pixelsWithCosmicRayHits.mjd]';          % nEvents x 1
    
    mBlackRow = round(mean(mBlackRows));
    vBlackRow = round(mean(vBlackRows));
    
    % find indices of any cosmic ray events in masked and/or virtual black
    mBlackCosmicRayHitIdx = find(rowOrColumn == mBlackRow);
    vBlackCosmicRayHitIdx = find(rowOrColumn == vBlackRow);
    
    % black pixel struct contains all cosmic ray events, check for masked black
    % and/or virtual black events, remove them from blackPixelsWithCosmicRayHits
    % and define analogous structs for masked/virtual black.  These structs
    % are used to compute cosmic ray metrics
    blackPixelsWithCosmicRayHits  = pixelsWithCosmicRayHits;
    
    %---------------------------------------------------------------------
    % if there are cosmic ray hits in masked black, define event structure
    % and compute metrics
    if ~isempty(mBlackCosmicRayHitIdx)
        
        numberOfMaskedBlackPixels = calIntermediateStruct.numberOfMaskedBlackPixels; % scalar or (nCadences x 1)
        
        mBlackRowOrColumn = rowOrColumn(mBlackCosmicRayHitIdx); % may be arrays
        mBlackDelta       = delta(mBlackCosmicRayHitIdx);
        mBlackIndices     = indices(mBlackCosmicRayHitIdx);
        mBlackMjd         = mjd(mBlackCosmicRayHitIdx);
        
        % deal to mBlackPixelsWithCosmicRayHits
        mBlackPixelsWithCosmicRayHits = repmat(struct('rowOrColumn', [], ...
            'delta', [], 'indices', [], 'mjd', []), 1, length(mBlackMjd) );
        
        % convert 2D arrays to cell arrays
        mBlackRowOrColumnCell = num2cell(mBlackRowOrColumn);
        mBlackDeltaCell = num2cell(mBlackDelta);
        mBlackIndicesCell = num2cell(mBlackIndices);
        mBlackMjdCell = num2cell(mBlackMjd);
        
        % deal each value into array of structs
        [mBlackPixelsWithCosmicRayHits(1:length(mBlackRowOrColumnCell)).rowOrColumn] = ...
            deal(mBlackRowOrColumnCell{:});
        [mBlackPixelsWithCosmicRayHits(1:length(mBlackDeltaCell)).delta] = ...
            deal(mBlackDeltaCell{:});
        [mBlackPixelsWithCosmicRayHits(1:length(mBlackIndicesCell)).indices] = ...
            deal(mBlackIndicesCell{:});
        [mBlackPixelsWithCosmicRayHits(1:length(mBlackMjdCell)).mjd] = ...
            deal(mBlackMjdCell{:});
        
        %---------------------------------------------------------------------
        % compute masked black cosmic ray metrics
        %---------------------------------------------------------------------
        [mBlackCosmicRayMetrics, numMblackCrEventsArray] = compute_cosmic_ray_metrics(calObject, calIntermediateStruct, ...
            mBlackGaps(:)', mBlackPixelsWithCosmicRayHits, timeMblackPixExposedInSec, numberOfMaskedBlackPixels);                           %#ok<NASGU>
        
    else
        mBlackPixelsWithCosmicRayHits = [];                     % no events
        mBlackCosmicRayMetrics = cosmicRayMetricsEmptyStruct;   % no metrics
    end
    
    %---------------------------------------------------------------------
    % if there are cosmic ray hits in virtual black, define event structure
    % and compute metrics
    if ~isempty(vBlackCosmicRayHitIdx)
        
        numberOfVirtualBlackPixels = calIntermediateStruct.numberOfVirtualBlackPixels;% scalar or (nCadences x 1)
        
        vBlackRowOrColumn = rowOrColumn(vBlackCosmicRayHitIdx); % may be arrays
        vBlackDelta       = delta(vBlackCosmicRayHitIdx);
        vBlackIndices     = indices(vBlackCosmicRayHitIdx);
        vBlackMjd         = mjd(vBlackCosmicRayHitIdx);
        
        % deal to vBlackPixelsWithCosmicRayHits
        vBlackPixelsWithCosmicRayHits = repmat(struct('rowOrColumn', [], ...
            'delta', [], 'indices', [], 'mjd', []), 1, length(vBlackMjd) );
        
        % convert 2D arrays to cell arrays
        vBlackRowOrColumnCell = num2cell(vBlackRowOrColumn);
        vBlackDeltaCell = num2cell(vBlackDelta);
        vBlackIndicesCell = num2cell(vBlackIndices);
        vBlackMjdCell = num2cell(vBlackMjd);
        
        % deal each value into array of structs
        [vBlackPixelsWithCosmicRayHits(1:length(vBlackRowOrColumnCell)).rowOrColumn] = ...
            deal(vBlackRowOrColumnCell{:});
        [vBlackPixelsWithCosmicRayHits(1:length(vBlackDeltaCell)).delta] = ...
            deal(vBlackDeltaCell{:});
        [vBlackPixelsWithCosmicRayHits(1:length(vBlackIndicesCell)).indices] = ...
            deal(vBlackIndicesCell{:});
        [vBlackPixelsWithCosmicRayHits(1:length(vBlackMjdCell)).mjd] = ...
            deal(vBlackMjdCell{:});
        
        %---------------------------------------------------------------------
        % compute virtual black cosmic ray metrics
        %---------------------------------------------------------------------
        [vBlackCosmicRayMetrics, numVblackCrEventsArray] = compute_cosmic_ray_metrics(calObject, calIntermediateStruct, ...
            vBlackGaps(:)', vBlackPixelsWithCosmicRayHits, timeVblackPixExposedInSec, numberOfVirtualBlackPixels);                          %#ok<NASGU>
        
    else
        vBlackPixelsWithCosmicRayHits = [];                   % no events
        vBlackCosmicRayMetrics = cosmicRayMetricsEmptyStruct; % no metrics
    end
    
    %---------------------------------------------------------------------
    % compute black cosmic ray metrics
    %---------------------------------------------------------------------
    
    % update blackPixelsWithCosmicRayHits
    removeIdx = cat(1, mBlackCosmicRayHitIdx(:), vBlackCosmicRayHitIdx(:));
    if (~isempty(removeIdx))
        blackPixelsWithCosmicRayHits(removeIdx) = [];
    end
    
    [blackCosmicRayMetrics, numBlackCrEventsArray] = compute_cosmic_ray_metrics(calObject, calIntermediateStruct, ...
        blackGaps, blackPixelsWithCosmicRayHits, timeBlackPixExposedInSec, numberOfBlackColumns);
end


%----------------------------------------------------------------------
% save cosmic ray metrics struct (cosmicRayMetrics) for CAL outputs
%----------------------------------------------------------------------
calIntermediateStruct.blackCosmicRayMetrics        = blackCosmicRayMetrics;
calIntermediateStruct.maskedBlackCosmicRayMetrics  = mBlackCosmicRayMetrics;
calIntermediateStruct.virtualBlackCosmicRayMetrics = vBlackCosmicRayMetrics;

%----------------------------------------------------------------------
% save cosmic ray events structs (cosmicRayEvents) for CAL outputs
%----------------------------------------------------------------------

% save cosmic ray hits struct, without the indices field, for final output
if ~isempty(blackPixelsWithCosmicRayHits)
    blackPixelsWithCosmicRayHits = rmfield(blackPixelsWithCosmicRayHits, 'indices');
end

calIntermediateStruct.cosmicRayEvents.black = blackPixelsWithCosmicRayHits;


if ~isempty(mBlackPixelsWithCosmicRayHits)
    mBlackPixelsWithCosmicRayHits = rmfield(mBlackPixelsWithCosmicRayHits, 'indices');
end
calIntermediateStruct.cosmicRayEvents.maskedBlack = mBlackPixelsWithCosmicRayHits;


if ~isempty(vBlackPixelsWithCosmicRayHits)
    vBlackPixelsWithCosmicRayHits = rmfield(vBlackPixelsWithCosmicRayHits, 'indices');
end
calIntermediateStruct.cosmicRayEvents.virtualBlack = vBlackPixelsWithCosmicRayHits;


return;
