function [cosmicRayMetrics, numCrEventsArray] = compute_cosmic_ray_metrics(calObject, ...
    calIntermediateStruct, gapArray, cosmicRayEventStruct, timeExposedInSec, numCoadds)
% function [cosmicRayMetrics, numCrEventsArray] = compute_cosmic_ray_metrics(calObject, ...
%     calIntermediateStruct, gapArray, cosmicRayEventStruct, timeExposedInSec, numCoadds)
%
% function to compute and record the following cosmic ray metrics for each
% pixel type.  Invalid or unavailable data is set to '-1' with gap indicators
% set to true.
%
%
% INPUT
%
% gapArray                  nPixels x nCadences array of pixel gaps
%
% cosmicRayEventStruct: struct with the following fields:
%
%    .rowOrColumn           black row or smear column of cosmic ray event
%
%    .mjd                   time (mjd) of cosmic ray hit
%
%    .delta                 array of same size as .indices containing
%                           the change in values in cleanedSeries from timeSeries so
%                           timeSeries(.indices) = cleanedSeries(.indices) + .deltas
%
%    .indices               # of cosmic ray events x 1 array of indices in
%                           .cleanedSeries of cosmic ray events
%
% OUTPUT
% cosmicRayMetrics struct with the following fields:
%
%     exists                        logical scalar
%
%     hitRates                      [nCadences x 1]  mean hit rate in units of #events/cm^2/sec
%     hitRateGapIndicators          logical[]
%
%     meanEnergy                    [nCadences x 1]  mean energy in units of photoelectrons
%     meanEnergyGapIndicators       logical[]
%
%     energyVariance                [nCadences x 1]  energy variance in units of photoelectrons^2
%     energyVarianceGapIndicators   logical[]
%
%     energySkewness                [nCadences x 1]  energy skewness (dimensionless)
%     energySkewnessGapIndicators   logical[]
%
%     energyKurtosis                [nCadences x 1]  energy kurtosis (dimensionless)
%     energyKurtosisGapIndicators   logical[]
%
%
% Note masked smear collects dark current during ccdExposureTime +
% ccdReadTime, whereas virtual smear collects dark current during read time only
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

% extract timestamp (mjds)
cadenceTimes = calObject.cadenceTimes;
timestamp    = cadenceTimes.timestamp;
nCadences    = length(timestamp);

numberOfExposures = calIntermediateStruct.numberOfExposures;


% preallocate struct to save cosmic ray metrics when available.  The arrays
% are initialized with values of (-1), which indicate unavailable/gapped data,
% and the gap arrays are initialized to true.
emptyMetricArrays = repmat(-1, nCadences, 1);
gappedArrays = true(nCadences, 1);

cosmicRayMetrics = struct('exists',false, ...
    'hitRates', emptyMetricArrays, 'hitRateGapIndicators', gappedArrays, ...
    'meanEnergy', emptyMetricArrays, 'meanEnergyGapIndicators', gappedArrays, ...
    'energyVariance', emptyMetricArrays, 'energyVarianceGapIndicators', gappedArrays, ...
    'energySkewness', emptyMetricArrays, 'energySkewnessGapIndicators', gappedArrays, ...
    'energyKurtosis', emptyMetricArrays, 'energyKurtosisGapIndicators', gappedArrays);


if (~isempty(cosmicRayEventStruct))
    
    % extract delta and indices from cosmicRayEventStruct, and concatenate arrays
    delta        = [cosmicRayEventStruct.delta]';   % cosmic ray value that is removed from pixel
    indices      = [cosmicRayEventStruct.indices]'; % cadence of cosmic ray hit
    
    % if any hits were recorded for any cadence, set exists field to true
    cosmicRayMetrics.exists = true;
else
    cosmicRayMetrics.exists                      = false;
    cosmicRayMetrics.hitRates                    = [];
    cosmicRayMetrics.hitRateGapIndicators        = [];
    cosmicRayMetrics.meanEnergy                  = [];
    cosmicRayMetrics.meanEnergyGapIndicators     = [];
    cosmicRayMetrics.energyVariance              = [];
    cosmicRayMetrics.energyVarianceGapIndicators = [];
    cosmicRayMetrics.energySkewness              = [];
    cosmicRayMetrics.energySkewnessGapIndicators = [];
    cosmicRayMetrics.energyKurtosis              = [];
    cosmicRayMetrics.energyKurtosisGapIndicators = [];
    numCrEventsArray = [];
    return;
end

numCrEventsArray = zeros(nCadences, 1);

% compute metrics for each cadence
for cadenceIndex = 1:nCadences
    
    if numel(numCoadds) >  1
        numCoadds = numCoadds(cadenceIndex);
    end
    
    if numel(numberOfExposures) >  1
        numberOfExposures = numberOfExposures(cadenceIndex);
    end
    
    if numel(timeExposedInSec) >  1
        timeExposedInSec = timeExposedInSec(cadenceIndex);
    end
    
    
    eventsForThisCadenceIdx = indices(indices == cadenceIndex);
    deltasForThisCadence    = delta(indices == cadenceIndex); %cosmic ray flux
    
    % number of cosmic ray events
    nEvents = length(eventsForThisCadenceIdx);
    
    % record number of events
    numCrEventsArray(cadenceIndex) = nEvents;
    
    if (nEvents > 0) %if at least one cosmic ray detection for this cadence
        
        %------------------------------------------------------------------
        % compute hit rates in units of #events/cm^2/sec
        %------------------------------------------------------------------
        % get number of valid pixels for this cadence from gap array info,
        % which is an (nPixel x nCadence) array for black pixels, and a
        % (1 x nCadence) array for masked/virtual black.  Note that the
        % input numCoadds are the collateral spatial coadds from configmap
        
        nPixelsPerCadence = length(gapArray(:, 1));
        
        if (nPixelsPerCadence > 1)
            
            nAvailablePixels = ...
                length(find(~gapArray(:, cadenceIndex))) .* numCoadds;
            
        elseif (nPixelsPerCadence == 1)  % ensure one value per cadence for masked/virtual black
            
            nAvailablePixels = length(find(~gapArray(cadenceIndex))) .* numCoadds;
        end
        
        % compute pixel size in centimeters
        pixelSizeInMicrons = calObject.fcConstants.PIXEL_SIZE_IN_MICRONS; %pixelSizeInMicrons = 27;
        
        pixelAreaInCmSquared = (pixelSizeInMicrons*1e-4)^2;
        
        % compute area of all valid pixels on ccd for this cadence and
        % input pixel type
        areaOfCcdWithValidPixels = pixelAreaInCmSquared * nAvailablePixels;
        
        %------------------------------------------------------------------
        % compute hit rate in units of events per cm^2 per second
        %------------------------------------------------------------------
        hitsInElectronsPerCmSquaredPerSec =  nEvents / areaOfCcdWithValidPixels / ...
            (numberOfExposures * timeExposedInSec);
        
        if ~isnan(hitsInElectronsPerCmSquaredPerSec)
            
            % save to cosmicRayMetrics output struct
            cosmicRayMetrics.hitRates(cadenceIndex) = hitsInElectronsPerCmSquaredPerSec;
            cosmicRayMetrics.hitRateGapIndicators(cadenceIndex) = false;
        end
        
        %------------------------------------------------------------------
        % compute mean energy in units of photoelectrons
        %------------------------------------------------------------------
        meanEnergy = mean(deltasForThisCadence);
        
        if ~isnan(meanEnergy)
            
            % save to cosmicRayMetrics output struct
            cosmicRayMetrics.meanEnergy(cadenceIndex) = meanEnergy;
            cosmicRayMetrics.meanEnergyGapIndicators(cadenceIndex) = false;
        end
    end
    
    %------------------------------------------------------------------
    % compute energy variance in units of photoelectrons^2
    %------------------------------------------------------------------
    if (nEvents > 1)
        
        % need at least two cosmic ray hits to compute the variance
        energyVariance = var(deltasForThisCadence);
        
        if ~isnan(energyVariance)
            cosmicRayMetrics.energyVariance(cadenceIndex) = energyVariance;
            cosmicRayMetrics.energyVarianceGapIndicators(cadenceIndex) = false;
        end
    end
    
    %------------------------------------------------------------------
    % compute skewness, which is a function of the mean & std, and is a
    % measure of the asymmetry of the distribution (negative values
    % indicate data is skewed towards the left, normal distributions
    % have a skewness of zero, and right-skewed data have positive values)
    %------------------------------------------------------------------
    if (nEvents > 2)
        
        % need at least three cosmic ray hits to compute skewness
        energySkewness = skewness(deltasForThisCadence);
        
        if ~isnan(energySkewness)
            cosmicRayMetrics.energySkewness(cadenceIndex) = energySkewness;
            cosmicRayMetrics.energySkewnessGapIndicators(cadenceIndex) = false;
        end
    end
    
    %------------------------------------------------------------------
    % compute kurtosis, which is a function of the mean & std, and is a
    % measure of whether the data are peaked or flat relative to a
    % normal distribution (data with higher values of kurtosis have
    % sharper peaks)
    %------------------------------------------------------------------
    if (nEvents > 3)
        
        % need at least four cosmic ray hits to compute kurtosis
        energyKurtosis = kurtosis(deltasForThisCadence);
        
        if ~isnan(energyKurtosis)
            cosmicRayMetrics.energyKurtosis(cadenceIndex) = energyKurtosis;
            cosmicRayMetrics.energyKurtosisGapIndicators(cadenceIndex) = false;
        end
    end
end


return;
