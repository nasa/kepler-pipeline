function [calObject, calIntermediateStruct] = ...
    correct_smear_pix_for_cosmic_rays(calObject, calIntermediateStruct)
%function [calObject, calIntermediateStruct] = ...
%   correct_smear_pix_for_cosmic_rays(calObject, calIntermediateStruct)
%
% This calClass method corrects masked and/or virtual smear pixels for cosmic rays.
%
% The pixel arrays are either passed into clean_cosmic_rays_mad (cosmicRayCleaningMethod = 'mad) or they are extracted from the calClass
% object by calMSmearCosmicRayCleanerClass or calVSmearCosmicRayCleanerClass (cosmicRayCleaningMethod = 'ar). The corrected pixels along
% with a structure with the events indicators (cosmic ray event deltas, which are the difference between the cleaned pixels and original
% pixels, and the rows/columns and mjd timestamps) is either output by clean_cosmic_rays_mad or extracted from the
% calMSmearCosmicRayCleanerObject or calVSmearCosmicRayCleanerObject using the class method,
% get_corrected_flux_and_event_indicator_matrices. A set of metrics (cosmic ray hit rates and energy) are then computed with
% compute_cosmic_ray_metrics, and results are saved to calIntermediateStruct .
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


% extract data flags
isAvailableMaskedSmearPix  = calObject.dataFlags.isAvailableMaskedSmearPix;
isAvailableVirtualSmearPix = calObject.dataFlags.isAvailableVirtualSmearPix;
enableExcludeIndicators = calObject.moduleParametersStruct.enableExcludeIndicators;
enableExcludePreserve = calObject.moduleParametersStruct.enableExcludePreserve;

% extract timestamp (mjds)
cadenceTimes = calObject.cadenceTimes;
timestamp    = cadenceTimes.timestamp;
excludeIndicators = cadenceTimes.dataAnomalyFlags.excludeIndicators;

% get config map parameters
ccdExposureTime = calIntermediateStruct.ccdExposureTime;
ccdReadTime = calIntermediateStruct.ccdReadTime;
numberOfMaskedSmearRows = calIntermediateStruct.numberOfMaskedSmearRows;
numberOfVirtualSmearRows = calIntermediateStruct.numberOfVirtualSmearRows;


% create empty struct for cases in which cosmic rays metrics are unavailable
cosmicRayMetricsEmptyStruct = struct('exists', false, ...
    'hitRates', [], 'hitRateGapIndicators', [], ...
    'meanEnergy', [], 'meanEnergyGapIndicators', [], ...
    'energyVariance', [], 'energyVarianceGapIndicators', [], ...
    'energySkewness', [], 'energySkewnessGapIndicators', [], ...
    'energyKurtosis', [], 'energyKurtosisGapIndicators', []);

%--------------------------------------------------------------------------
% extract smear pixels, gaps, and column arrays
%--------------------------------------------------------------------------
mSmearPixels = calIntermediateStruct.mSmearPixels;
mSmearGaps   = calIntermediateStruct.mSmearGaps;
vSmearPixels = calIntermediateStruct.vSmearPixels;
vSmearGaps   = calIntermediateStruct.vSmearGaps;

% update gaps based on exclude indicators
if enableExcludeIndicators && enableExcludePreserve
    mSmearGaps = mSmearGaps | repmat(excludeIndicators(:)',size(mSmearGaps,1),1);
    vSmearGaps = vSmearGaps | repmat(excludeIndicators(:)',size(vSmearGaps,1),1);
end

%--------------------------------------------------------------------------
% extract cosmic ray parameters from the module interface, which include:
%--------------------------------------------------------------------------
%   detrendOrder
%   medianFilterLength
%   madThreshold
%   thresholdMultiplier
%   consecutiveCosmicRayCleaningEnabled
%   twoSidedFinalThresholdingEnabled
%   madWindowLength

cosmicRayParametersStruct = calObject.cosmicRayParametersStruct;

% initialize counters
numMsmearCrEventsArray = [];
numVsmearCrEventsArray = [];

if isAvailableMaskedSmearPix
    
    %--------------------------------------------------------------------------
    % clean masked smear pixel time series for cosmic rays
    %--------------------------------------------------------------------------
    
    display('CAL:correct_smear_pix_for_cosmic_rays: Correcting masked smear for cosmic rays...');
    
    switch lower(cosmicRayParametersStruct.cosmicRayCleaningMethod)
        case 'mad'
            % transpose inputs to nCadences x nPixels
            [mSmearPixelsCosmicRayCorrected, cosmicRayEventsIndicators] = ...
                clean_cosmic_rays_mad(mSmearPixels', mSmearGaps', ...
                    cosmicRayParametersStruct);
        case 'ar'
            calMSmearCosmicRayCleanerObject = ...
                calMSmearCosmicRayCleanerClass(calObject, calIntermediateStruct);
            returnSparse = issparse(calIntermediateStruct.mSmearPixels);
            [mSmearPixelsCosmicRayCorrected, cosmicRayEventsIndicators] = ...
                calMSmearCosmicRayCleanerObject.get_corrected_flux_and_event_indicator_matrices(returnSparse);
        otherwise
            error('correct_smear_pix_for_cosmic_rays: Invalid cleaning method.');
    end
    
    % transpose results to nPixelsxnCadences
    mSmearPixelsCosmicRayCorrected = mSmearPixelsCosmicRayCorrected';
    cosmicRayEventsIndicators      = cosmicRayEventsIndicators';
    
    cosmicRaysDetectedFlag = any(cosmicRayEventsIndicators( : ));
    
    if ~cosmicRaysDetectedFlag
        warning('CAL:correct_smear_pix_for_cosmic_rays:NoCosmicRaysDetected', ...
            'No cosmic rays detected in masked smear pixel region.');
    end
    
    
    % populate the output structure
    if cosmicRaysDetectedFlag
        
        [rowOrColumn, indices] = find(cosmicRayEventsIndicators);
        
        delta = mSmearPixels(cosmicRayEventsIndicators) - mSmearPixelsCosmicRayCorrected(cosmicRayEventsIndicators);
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
        
        % update cosmic ray corrected pixels
        calIntermediateStruct.mSmearPixels = mSmearPixelsCosmicRayCorrected;
    else
        pixelsWithCosmicRayHits = [];
    end
    
    
    %----------------------------------------------------------------------
    % compute cosmic ray metrics for masked smear if any cosmic rays were detected
    %----------------------------------------------------------------------
    
    % check if cosmic rays were detected
    if isempty(pixelsWithCosmicRayHits)
        calIntermediateStruct.cosmicRayEvents.maskedSmear = [];
        calIntermediateStruct.maskedSmearCosmicRayMetrics = cosmicRayMetricsEmptyStruct;
    else
        
        % extract time pixels were exposed to possible cosmic rays
        timeExposedInSec = ccdExposureTime + ccdReadTime;
        
        % compute masked smear cosmic ray metrics
        [maskedSmearCosmicRayMetrics, numMsmearCrEventsArray] = ...
            compute_cosmic_ray_metrics(calObject, calIntermediateStruct, mSmearGaps, ...
            pixelsWithCosmicRayHits, timeExposedInSec, numberOfMaskedSmearRows);                                    
        
        % save cosmic ray hits struct
        if ~isempty(pixelsWithCosmicRayHits)
            pixelsWithCosmicRayHits = rmfield( pixelsWithCosmicRayHits, 'indices');
        end
        
        calIntermediateStruct.cosmicRayEvents.maskedSmear = pixelsWithCosmicRayHits;
        
        % save cosmic ray metrics struct for final output struct
        calIntermediateStruct.maskedSmearCosmicRayMetrics = maskedSmearCosmicRayMetrics;
        
    end
else
    calIntermediateStruct.cosmicRayEvents.maskedSmear = [];
    calIntermediateStruct.maskedSmearCosmicRayMetrics = cosmicRayMetricsEmptyStruct;
end

% clear cosmic ray events struct for virtual smear
clear pixelsWithCosmicRayHits

if isAvailableVirtualSmearPix
    
    %--------------------------------------------------------------------------
    % clean virtual smear pixel time series for cosmic rays
    %--------------------------------------------------------------------------
    
    display('CAL:correct_smear_pix_for_cosmic_rays: Correcting virtual smear for cosmic rays...');
        
    switch lower(cosmicRayParametersStruct.cosmicRayCleaningMethod)
        case 'mad'
            % transpose inputs to nCadences x nPixels
            [vSmearPixelsCosmicRayCorrected, cosmicRayEventsIndicators] = ...
                clean_cosmic_rays_mad(vSmearPixels', vSmearGaps', ...
                    cosmicRayParametersStruct);
        case 'ar'
            calVSmearCosmicRayCleanerObject = ...
                calVSmearCosmicRayCleanerClass(calObject, calIntermediateStruct);
            returnSparse = issparse(calIntermediateStruct.vSmearPixels);
            [vSmearPixelsCosmicRayCorrected, cosmicRayEventsIndicators] = ...
                calVSmearCosmicRayCleanerObject.get_corrected_flux_and_event_indicator_matrices(returnSparse);
        otherwise
            error('correct_smear_pix_for_cosmic_rays: Invalid cleaning method.');
    end
    
    % transpose results to nPixelsxnCadences
    vSmearPixelsCosmicRayCorrected = vSmearPixelsCosmicRayCorrected';
    cosmicRayEventsIndicators = cosmicRayEventsIndicators';
    
    cosmicRaysDetectedFlag = any(cosmicRayEventsIndicators( : ));
    
    if ~cosmicRaysDetectedFlag
        warning('CAL:correct_smear_pix_for_cosmic_rays:NoCosmicRaysDetected', ...
            'No cosmic rays detected in virtual smear pixel region.');
    end
    
    
    % populate the output structure
    if cosmicRaysDetectedFlag
        
        [rowOrColumn, indices] = find(cosmicRayEventsIndicators);
        
        delta = vSmearPixels(cosmicRayEventsIndicators) - vSmearPixelsCosmicRayCorrected(cosmicRayEventsIndicators);
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
        
        % save cosmic ray corrected pixels
        calIntermediateStruct.vSmearPixels = vSmearPixelsCosmicRayCorrected;
    else
        pixelsWithCosmicRayHits = [];
    end
    
    
    %----------------------------------------------------------------------
    % compute cosmic ray metrics for virtual smear if any cosmic rays were detected
    %----------------------------------------------------------------------
    
    % check if cosmic rays were detected
    if isempty(pixelsWithCosmicRayHits)
        
        calIntermediateStruct.cosmicRayEvents.virtualSmear = [];
        calIntermediateStruct.virtualSmearCosmicRayMetrics = cosmicRayMetricsEmptyStruct;
        calIntermediateStruct.numVsmearCrEventsArray = [];
    else
        
        % extract time pixels were exposed to possible cosmic rays
        timeExposedInSec = ccdReadTime;
        
        % compute virtual smear cosmic ray metrics
        [virtualSmearCosmicRayMetrics, numVsmearCrEventsArray] = ...
            compute_cosmic_ray_metrics(calObject, calIntermediateStruct, vSmearGaps, ...
            pixelsWithCosmicRayHits, timeExposedInSec, numberOfVirtualSmearRows);
        
        % save cosmic ray hits struct
        if ~isempty(pixelsWithCosmicRayHits)
            pixelsWithCosmicRayHits = rmfield( pixelsWithCosmicRayHits, 'indices');
        end
        
        calIntermediateStruct.cosmicRayEvents.virtualSmear = pixelsWithCosmicRayHits;
        
        % save cosmic ray metrics struct for final output struct
        calIntermediateStruct.virtualSmearCosmicRayMetrics = virtualSmearCosmicRayMetrics;
        calIntermediateStruct.numVsmearCrEventsArray = numVsmearCrEventsArray;
    end
else
    calIntermediateStruct.cosmicRayEvents.virtualSmear = [];
    calIntermediateStruct.virtualSmearCosmicRayMetrics = cosmicRayMetricsEmptyStruct;
    calIntermediateStruct.numVsmearCrEventsArray = [];
end



%----------------------------------------------------------------------
% plot smear pixel types corrected for cosmic rays
%----------------------------------------------------------------------
if ~isempty(calIntermediateStruct.cosmicRayEvents.maskedSmear) || ~isempty(calIntermediateStruct.cosmicRayEvents.virtualSmear)
    
    if ~isempty(calIntermediateStruct.cosmicRayEvents.maskedSmear)
        nMsmearEvents = length([calIntermediateStruct.cosmicRayEvents.maskedSmear.delta]);
    else
        nMsmearEvents = 0;
    end
    
    if ~isempty(calIntermediateStruct.cosmicRayEvents.virtualSmear)
        nVsmearEvents = length([calIntermediateStruct.cosmicRayEvents.virtualSmear.delta]);
    else
        nVsmearEvents = 0;
    end
    
    display(['CAL:correct_smear_pix_for_cosmic_rays: Number of cosmic rays detected in masked/virtual smear: ' num2str(nMsmearEvents + nVsmearEvents) ]);
    plot_smear_cosmic_ray_metrics(calIntermediateStruct, numMsmearCrEventsArray, numVsmearCrEventsArray)
else
    display('CAL:correct_smear_pix_for_cosmic_rays: No cosmic rays detected in masked/virtual smear');
end



return;
