%function [goodnessStruct] = pdc_goodness_metric (rawDataStruct, correctedDataStruct, cadencetimes, basisVectors, ...
%       pdcModuleParameters, goodnessMetricConfigurationStruct, gapFillConfigurationStruct, doNormalizeFlux, doSavePlots, plotTitleIntro, varargin)
%
% Calculates a "goodness metric" that measures how well MAP performed wrt several aspects:
%   1) Remove Systematic trends
%   2) No over-fitting
%   3) No introduced noise
%   4) Earth Point Recovery removal
%   5) Systematic spike removal
%   6) An estimated CDPP
%
% The metric spans (0,1]. 1 Being perfect goodness.
%
% The CDPP calculation is not on a [0,1] scale but the typical ppm scale.
%
% Percentile values are calculated for all targets but the values are with respect to non-custom targets. So,
% if half of all targets are custom targets ans all the custom targets have really bad goodness then they are
% all in the zeroeth percentile.  This allows for the non-custom targets percentiles to not be corrupted by
% the custom targets and yet still lets the custom target users get an idea how their targets performed
% compared to the standard targets.
%
% The rawDataStruct and correctedDataStruct should be normalized. If called on unnormalize flux then set
% doNormalizeFlux = true and this function will normalize them internally.
%
% Flux is evaluated in a normalized frame. The normalization method is currently hardcoded as 'median'. In
% general median is safer than mean due to outliers but the MAP fitting is by default performed within 'mean'
% normalization (due to basis vector offset issues). There should be no problem with using a different
% normalization here and should results in slightly better results.
%
% The basis vectors are used to idenitfy the systematic spikes. It only works well on denoised single-scale basis vectors. Improper performance will result
% ohterwise.
%
% This function can also calculate an estimate of CDPP. If you wish this to happen then pass gapFillConfigurationStruct. If empty then CDPP is not calculated.
% CDPP is is inlcuded in the Total Goodness. TODO: Consider adding CDPP to the Total Goodness.
%
% The default operation is for the goodness to be calculated for all targets. However, if the optional
% argument targetList is given then the goodness is only calculatated for those targets. The returned
% goodnessStruct is of length TargetList and in the same order as the targets in
% targetList. The percentile statistics are not calculated (set to NaN). Even if the goodness is only
% calculated for a reduced set of targets all targets must be passed in the targetDataStruct so that the
% proper sorrelation statistics can be found. The plots are not generated and no verbosity if targetList is given.
%
% If a component is not available or data not valid then the goodness for that component is NaN.
%
% NOTE: Flux data in gaps is ignored for goodness metric calculation
%
%***************************************************************************
% Inputs:
%   rawDataStruct -- [struct array(nTargets)] Raw flux data
%       fields Used:
%           .values        -- [double array(nCadences)] 
%           .gapIndicators -- [logical array(nCadences)]
%           .uncertainties -- [logical array(nCadences)]
%   correctedDataStruct -- [struct array(nTargets)] Corrected flux data
%       fields Used:
%           .values        -- [double array(nCadences)] 
%           .gapIndicators -- [logical array(nCadences)]
%           .uncertainties -- [logical array(nCadences)]
%   cadenceTimes            -- [struct] used for masking Earth Point recovery in stellar variability calculation
%   basisVectors            -- [double matrix(nCadences x nBasisVectors)] the regular MAP basisVectors for spike goodness. (if =[] then do not compute)
%   pdcModuleParameters  -- [struct] Configuration parameters
%       fields:
%           variabilityEpRecoveryMaskEnabled  -- [logical] Mask recovery regions for varability calculation
%           variabilityEpRecoveryMaskWindow   -- [int32]   Number of cadences after Earth-Point to mask
%           variabilityDetrendPolyOrder       -- [int32]   Polynomial Order for variability coarse detrending
%   goodnessMetricConfigurationStruct -- [struct]  Configuration parameters
%       fields:
%           correlationScale        -- [double] relative scale to weight the correlation part
%           variabilityScale        -- [double] relative scale to weight the delta variability part
%           noiseScale              -- [double] relative scale to weight the added noise part
%   gapFillConfigurationStruct      -- [gapFillConfigurationStruct] Used for CDPP calculation, if empty then no CDPP calculation.
%   doNormalizeFlux     -- [logical] normalize the flux (do this if not already normalize)
%   doSavePlots         -- [logical] Save the result plots to a subdirectory then closes figures
%   plotTitleIntro      -- [char string] Beginning text to title
%   targetList          -- [int array(nTargets) (optional)] target list to calculate goodness for (0 means all targets)
%   plotSubDirSuffix    -- [char string (optional)] directory ending for goodness plots
%   doCalcEpGoodness    -- [logical (optional) Default: TRUE] The Earth-Point Goodness takes considerably longer to compute
%                           than the other three components so computing it is optional. This is mainly here for when 
%                           iterating with the goodness metric the function can be fast enough to be iterated with. 
%                           In the future we should be able to speed up the EP goodness claculation and remove this "feature"
%
%***************************************************************************
% Outputs:
%   goodnessStruct -- [struct array(nTargets)]
%       fields:
%           keplerId          -- [int] Kepler ID; Added to be explicit about which target we are talking about
%           total             -- [pdcGoodnessComponent] total Goodness value for this target
%           correlation       -- [pdcGoodnessComponent] cross correlation component to goodness
%           deltaVariability  -- [pdcGoodnessComponent] change in variability component to goodness
%           introducedNoise   -- [pdcGoodnessComponent] Noise contribution to goodness
%           earthPointRemoval -- [pdcGoodnessComponent] Earth point recovery contribution to goodness
%           spikeRemoval      -- [pdcGoodnessComponent] Correlated spikes removal contribution to goodness
%           cdpp              -- [pdcGoodnessComponent] An etimated CDPP
%           kepstddev         -- [pdcGoodnessComponent] An estimate of photmetric precision based on the GO tool kepstddev
%               pdcGoodnessComponent   -- [struct]
%                   fields:
%                       value      -- [double] The component value
%                       percentile -- [double] The component percentile ranking among all non-custom targets
%
%%***************************************************************************
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

function goodnessStruct = pdc_goodness_metric (rawDataStruct, correctedDataStruct, cadenceTimes, basisVectors, ...
        pdcModuleParameters, goodnessMetricConfigurationStruct, gapFillConfigurationStruct, doNormalizeFlux, doSavePlots, plotTitleIntro, varargin)

calcEpGoodness = true;
plottingEnabled = true;

% Overload pdc_goodness_metric to take inputsStruct and outputsStruct (and basisVectors)
if (nargin == 3)
    % The three arguments are then inputsStruct, outputsStruct and basisVectors
    inputsStruct = rawDataStruct;
    outputsStruct = correctedDataStruct;
    basisVectors = cadenceTimes;

    % Now access the proper input parameters
    if (isfield(inputsStruct, 'channelDataStruct'))
        inputsStruct = pdcInputClass.process_channelDataStruct(inputsStruct);
    end
    rawDataStruct = inputsStruct.targetDataStruct;
    correctedDataStruct = outputsStruct.targetResultsStruct;
    cadenceTimes = inputsStruct.cadenceTimes;
    pdcModuleParameters = inputsStruct.pdcModuleParameters;
    goodnessMetricConfigurationStruct = inputsStruct.goodnessMetricConfigurationStruct;
    gapFillConfigurationStruct = inputsStruct.gapFillConfigurationStruct;
    doNormalizeFlux = true;
    doSavePlots = false;
    plotTitleIntro = 'From Task Directory ';
    calcEpGoodness = false;
    plottingEnabled = false;
end


% Check if correctedDataStruct is a targetResultsStruct
if (isfield(correctedDataStruct, 'correctedFluxTimeSeries'))
    correctedDataStruct = pdc_convert_output_flux_to_targetDataStruct (correctedDataStruct);
end

% Set rawDataStruct gaps values to those of the output so that gaps are consistent and data anomalies are not included in the calculations
for iTarget = 1 : length(rawDataStruct)
    rawDataStruct(iTarget).gapIndicators = correctedDataStruct(iTarget).gapIndicators;
end

    
plotSubDirSuffix = '';
doAllTargets = true;
nTargets = length(rawDataStruct);
targetList = [1:nTargets];
if (~isempty(varargin))
    % Find which optional arguments are given
    for iArg = 1 : length(varargin)
        if(isa(varargin{iArg}, 'char'))
            plotSubDirSuffix = varargin{iArg};
        elseif(isa(varargin{iArg}, 'numeric'))
            doAllTargets = false;
            if(varargin{iArg} ~= 0)
                targetList = varargin{iArg};
                nTargets = length(targetList);
            end
        elseif(isa(varargin{iArg}, 'logical'))
            calcEpGoodness = varargin{iArg};
        end
    end
end

if(doAllTargets)
    goodnesstic = tic;
    disp(['Computing PDC Goodness Metric for ', plotTitleIntro])
end

plotSubDir = [ './goodness_metric_plots' plotSubDirSuffix ];
saveFigureFormat = 'fig';

nCadences = length(cadenceTimes.startTimestamps);
if (doAllTargets && nCadences > 5000)
    disp(['A large number of cadences at ', num2str(nCadences), '. This may take a while, please be patient...']);
    if (nTargets > 40)
        disp('Woah there tiger! A large number of targets with a large number of cadences each, this will take a *really* long time!');
        disp('Do you really want to do this? If so, find something else to do for a while.');
    end
    longTimeFlag = true;
else
    longTimeFlag = false;
end

pdcGoodnessComponent = struct ( ...
    'value',        0.0,...
    'percentile',   NaN);

goodnessStruct = repmat( struct( ...
    'keplerId',           -1, ...
    'total',              pdcGoodnessComponent, ...
    'correlation',        pdcGoodnessComponent, ...
    'deltaVariability',   pdcGoodnessComponent, ...
    'earthPointRemoval',  pdcGoodnessComponent, ...
    'spikeRemoval',       pdcGoodnessComponent, ...
    'introducedNoise',    pdcGoodnessComponent, ...
    'rollTweak',          pdcGoodnessComponent, ...
    'kepstddev',          pdcGoodnessComponent, ...
    'cdpp',               pdcGoodnessComponent), [nTargets,1]);

%*******************************************************************************************
% Earth point recovery

% EP Goodness normalizes the flux on its own so pass unnormalized flux to it
% TODO: get this working when flux passed to pdc_goodness_metric is already normalized
if (calcEpGoodness)
    if (~doAllTargets)
        error('pdc_goodeness_metric: Earth Point Goodness can only be calculated if and only if goodness for all targets is being computed.');
    end
    if (isfield(rawDataStruct, 'normMethod'))
        error ('Can only calculate the EP goodness if the flux is NOT normalized');
        % TODO: get this working, need to add Flux statitics to targetDataStruct
    else
        unnormalizedRawDataStruct = rawDataStruct;
        unnormalizedCorrectedDataStruct = correctedDataStruct;
    end
    % earthPointRemoval is NaN for targets where value could not be calculated.
    earthPointRemoval = pdcEarthPointClass.calc_earthpoint_goodnessmetric_for_modout (unnormalizedRawDataStruct, unnormalizedCorrectedDataStruct, cadenceTimes);
else
    earthPointRemoval = NaN(nTargets, 1); 
end 

 earthPointRemoval = earthPointRemoval .* goodnessMetricConfigurationStruct.earthPointScale;

%*******************************************************************************************
% Normalize Flux
if (doNormalizeFlux)
    doNanGaps = false;
    doMaskEpRecovery = true;
    normMethod = 'median';
    [rawDataStruct, ~, ~, ~, ~] = mapNormalizeClass.normalize_flux (rawDataStruct, normMethod, doNanGaps, ...
                doMaskEpRecovery, cadenceTimes, pdcModuleParameters.variabilityEpRecoveryMaskWindow); 
    [correctedDataStruct, ~, ~, ~, ~] = mapNormalizeClass.normalize_flux (correctedDataStruct, normMethod, doNanGaps, ...
                doMaskEpRecovery, cadenceTimes, pdcModuleParameters.variabilityEpRecoveryMaskWindow); 
end

%*******************************************************************************************
% Correlation
%*******************************************************************************************

% Correlation matrix
correlationMatrix = pdc_compute_correlation(correctedDataStruct);

% The selection basis for targets used for the MAP SVD based on correlation uses median absolute correlation per star.
% However, here we wish to overemphasize any residual correlation between a handfull of targets and not the
% overall correlation (which should almost always be low).

% Over-emphasize any individual correlation groups. Note the power of three after taking the absolute value
% of the correlation. Also, the mean is used so that outliers are *not* ignored. 
% Zero diagonal elements (self correlation)
correlationMatrix = tril(correlationMatrix, -1) + triu(correlationMatrix, 1);
% Add up the correlation over all targets ingoring NaNs (no corrected fit)
correlationSum = goodnessMetricConfigurationStruct.correlationScale*nanmean(abs(correlationMatrix).^3)';
if (~doAllTargets)
    correlationSum = correlationSum(targetList);
end

%*******************************************************************************************
% Variability
%*******************************************************************************************

%% Flux already normalized
 doNormalizeFlux = false;
 % rawDataStruct does not have transit gaps calculated so must do that now
 rawDataStruct = pdcTransitClass.find_transit_gaps(cadenceTimes, rawDataStruct);
 [rawVariability, ~] = pdc_calculate_stellar_variability ...
                   (rawDataStruct, cadenceTimes, pdcModuleParameters.variabilityDetrendPolyOrder, ...
                              doNormalizeFlux, pdcModuleParameters.variabilityEpRecoveryMaskEnabled, ...
                              pdcModuleParameters.variabilityEpRecoveryMaskWindow, ...
                              pdcModuleParameters.stellarVariabilityRemoveEclipsingBinariesEnabled);

%***
%% The variability calculator is not precise enough to use for delta variability. It's fine as a rough
%% estimate for weighting the prior but not good enough for the subtle details we are looking for here.

%***
% Remove high and low frequency components to isolate the center band where a robust fit tends to remove
% stellar variability. Then compare the corrected to the raw flux to see when it has changed.
% Data in gaps is ignored
% Periodogram cannot be parallelized : (
deltaVariability = zeros(nTargets,1);

%sgWindow = 501;
% 10% of the cadence times series length
sgWindow = floor(nCadences / 10);
% window must be odd
if (mod(sgWindow,2) == 0)
    sgWindow = sgWindow + 1;
end
sgPolyOrder = 3;
for iTarget = 1 : nTargets
    targetIndex = targetList(iTarget);
    
    if (longTimeFlag)
        disp(['Working on Delta Variability of target ', num2str(targetIndex), ' of ', num2str(nTargets), '.']);
    end
    
    % Use outputsStruct gaps so that data anomalies are gapped
    gaps = correctedDataStruct(targetIndex).gapIndicators;

    % Mask Earth Point recovery regions
    gaps = pdc_mask_recovery_regions (gaps, cadenceTimes, pdcModuleParameters.variabilityEpRecoveryMaskWindow);

    % Ignore fully gapped targets
    if (all(gaps))
        continue;
    end

    x = [1:length(rawDataStruct(targetIndex).values(~gaps))]';

    % Remove high frequency
    % window must be shorter than the data length
    windowToUse = min(sgWindow, length(rawDataStruct(targetIndex).values(~gaps)));
    % window must be odd
    if (mod(windowToUse,2) == 0)
        windowToUse = windowToUse - 1;
    end

    rawFluxValues = sgolayfilt(rawDataStruct(targetIndex).values(~gaps), sgPolyOrder , windowToUse);

    correctedFluxValues = sgolayfilt(correctedDataStruct(targetIndex).values(~gaps), sgPolyOrder , windowToUse);

    % Remove low frequency
    polyOrder = 3;
    [p, s, mu] = polyfit(x, rawFluxValues, polyOrder);
    rawFluxValues = rawFluxValues - polyval(p, x, s, mu);
    [p, s, mu] = polyfit(x, correctedFluxValues, polyOrder);
    correctedFluxValues = correctedFluxValues - polyval(p, x, s, mu);

    % Use std instead of mad so that outliers *are* emphasized
    deltaVariability(iTarget) = goodnessMetricConfigurationStruct.variabilityScale * std((correctedFluxValues - rawFluxValues).^2);

    % Scale by Variability
    % This works for most of the variability range but it greatly overenphasizes exceedingly high variability targets
    % TODO: get scaling right for very highly variable targets as well
    % NOTE: deltaVariability is only of length <targetList> whereas rawVariability is for all targets
   %deltaVariability(iTarget) = deltaVariability(iTarget) * nthroot(rawVariability(targetIndex),2);
    deltaVariability(iTarget) = deltaVariability(iTarget) * nthroot(rawVariability(targetIndex),2.5);

    %***
    % Neither of the below do seem to work but keeping code in for reference just in case we want to
    % investigate it further

    % normalize by noise floor
   %deltaVariability(iTarget) = deltaVariability(iTarget) / mad(diff(rawDataStruct(targetIndex).values(~gaps)));

    % scale by (conditioned) raw flux mad
   %deltaVariability(iTarget) = deltaVariability(iTarget) * mad(rawFluxValues);

end


%*******************************************************************************************
% Noise
%*******************************************************************************************

% Data in gaps is ignored
% Periodogram cannot be parallelized : (
deltaNoise = zeros(nTargets,1);
for iTarget = 1 : nTargets
    targetIndex = targetList(iTarget);

    % Use the same gaps for both flux series for easy comparison
    % Use outputsStruct gaps so that data anomalies are gapped
    gaps = correctedDataStruct(targetIndex).gapIndicators;

    % Ignore fully gapped targets
    if (all(gaps))
        continue;
    end

    [PSDRaw, ~]             = periodogram(diff(rawDataStruct(targetIndex).values(~gaps)));
    [PSDCorrected, ~]       = periodogram(diff(correctedDataStruct(targetIndex).values(~gaps)));

    PsdChange = PSDCorrected ./ PSDRaw;

    % We are only concerned with bands where the power increased so when(PSDCorrected ./ PSDRaw) > 1 
    deltaNoise(iTarget)    = goodnessMetricConfigurationStruct.noiseScale*sum(log(PsdChange(PsdChange>1)).^2);

    % normalize by the median raw PSD value to equalize all target's scales
    % NOTE: leaving this commented out code here for reference
    %deltaNoise(iTarget) = deltaNoise(iTarget) / median(PSDRaw);
end

%*******************************************************************************************
% Spike Removal Goodness
%*******************************************************************************************
%
% Only perform if Basis Vectors are passed
%

spikeRemoval = zeros(nTargets,1);

if (~isempty(basisVectors))
    % Identify the spikes using the basis Vectors
    % An easy way to identify spikes is to take the second deriviative (acceleration)
    % Then find the average second derivative for all the basis vectors
    basisVectorMean2nd = mean(diff(diff(basisVectors))');

    % Spikes above a threshold of 100 sigma will be flagged
    sigma = mad(basisVectorMean2nd,1) * 1.4826;
    threshold = 100 * sigma;
    
    aboveThreshold = abs(basisVectorMean2nd) > threshold;
    
    % Add all cadences 1 away from identified cadences because of the uncertanty introduced by taking the second deriviative via the diff function
    cadencesAboveSpikeThreshold = find(aboveThreshold);
    aboveThreshold(cadencesAboveSpikeThreshold(cadencesAboveSpikeThreshold ~= 1) - 1) = true;
    aboveThreshold(cadencesAboveSpikeThreshold(cadencesAboveSpikeThreshold ~= length(aboveThreshold)) + 1) = true;
    
    % Add 1 for the diff(diff()) offset
    cadencesAboveSpikeThreshold = find(aboveThreshold) + 1;

    if (~isempty(cadencesAboveSpikeThreshold))
        %*****
        % Find how strong of an impulse in each basis vector at each identified spike
        
       %fluxFigure = figure;
       %flux2ndFigure = figure;
        for iTarget = 1 : nTargets
        
            targetIndex = targetList(iTarget);
       
            gaps = correctedDataStruct(targetIndex).gapIndicators;
       
            flux = correctedDataStruct(targetIndex).values;
            filteredFlux = flux - medfilt1_soc(flux, 100);
            % get rid of first pesky peak after filtering
            filteredFlux(1) = median(filteredFlux);
        
            flux2nd = diff(diff(filteredFlux.^2)); % Note the square here
            fluxSigma =  mad(flux2nd,1) * 1.4826; % Median absolute deviation based sigma
        
            %***
            % Find response at each identified spike
            
            % First remove gapped cadences
            onGap = ismember(cadencesAboveSpikeThreshold, find(gaps));
            thisTargetCadencesAboveSpikeThreshold = cadencesAboveSpikeThreshold(~onGap);

            if (isempty(thisTargetCadencesAboveSpikeThreshold))
                % No cadences with spike corrections for this target. Nothing to do.
                continue;
            end
       
            % If the first listed cadence is 1 then remove it because the 1 offset will place this at cadence zero.
            if (thisTargetCadencesAboveSpikeThreshold(1) == 1)
                thisTargetCadencesAboveSpikeThreshold = thisTargetCadencesAboveSpikeThreshold(2:end);
            end
            fluxSpikes = abs(flux2nd(thisTargetCadencesAboveSpikeThreshold-1));
            % Normalize by filtered flux sigma to get the background spike rate
            spikeRemoval(iTarget) = sum((fluxSpikes / fluxSigma).^2);
           %display (['Reponse = ', num2str(spikeRemoval(iTarget))]);
       
            %***
            % TESTING PLOTTING CODE
            %***
            % Plot detected spikes for testing
           %fluxThreshold = 10 * fluxSigma;
           %
           %fluxCadencesAboveThreshold = find(abs(flux2nd) > fluxThreshold) + 1;
           %spikeSignalCadences = intersect(fluxCadencesAboveThreshold, cadencesAboveSpikeThreshold);
           %
           %figure(flux2ndFigure);
           %plot(abs(flux2nd), '-b');
           %hold on;
           %plot([1:nCadences], repmat(fluxThreshold, [nCadences,1]), '-r');
           %hold off;
           %
           %figure(fluxFigure);
           %plot(flux, '-b');
           %hold on;
           %plot(spikeSignalCadences, repmat(mean(flux), [size(spikeSignalCadences)]), '*r');
           %title (['Target index ', num2str(iTarget)]);
           %hold off;
           %pause;
            %***
            % TESTING CODE
            %***
        end
    end

    % Scale by scaling factor
    spikeRemoval = spikeRemoval * goodnessMetricConfigurationStruct.spikeScale;
end
        
%*******************************************************************************************
% Estimated CDPP
% 
%*******************************************************************************************

% Only do this if gapFillConfigurationStruct is passed
cdpp = zeros(nTargets,1);
if (~isempty(gapFillConfigurationStruct ))
    doCdpp = true;
    cdppMedFiltSmoothLength = 100;

    gapFilledTimestamps  = pdc_fill_cadence_times (cadenceTimes);

    for iTarget = 1 : nTargets
        targetIndex = targetList(iTarget);
        
        % Flux here is normalized
        gaps = correctedDataStruct(targetIndex).gapIndicators;
        flux = correctedDataStruct(targetIndex).values;

        %***
        % Condition the data for CDPP
        flux(gaps) = nan;
        
        % NaNs will "NaN" the medfilt1 values within cdppMedFiltSmoothLength cadences from each NaNed cadence, 
        % so we need to simply fill the gaps.
        % Further down we fill gaps better
        if (~isempty(flux(~gaps)))
            flux(gaps)   = interp1(gapFilledTimestamps(~gaps), flux(~gaps), gapFilledTimestamps(gaps), 'pchip');
        end
        
        fluxDetrended  = flux - medfilt1_soc(flux, cdppMedFiltSmoothLength);
        
        % Need
        % maxCorrelationWindowLimit           = maxCorrelationWindowXFactor * maxArOrderLimit;
        % To be larger than the largest gap
        % Make local copy of gapFillConfigurationStruct so we can edit it
        gapFillConfigurationStructTemp = gapFillConfigurationStruct;
        gapFillConfigurationStructTemp.maxCorrelationWindowXFactor = 300 / gapFillConfigurationStructTemp.maxArOrderLimit;
        
        %[fluxDetrended] = fill_short_gaps(fluxDetrended, gaps, [], false, gapFillConfigurationStructTemp, [], zeros(length(fluxDetrended),1));

        [fluxDetrended] = fill_short_gaps(fluxDetrended, gaps, 0, false, gapFillConfigurationStructTemp, []);
        
        %***
        % Compute the current CDPP
        tpsModuleParameters = [];
       %tpsModuleParameters.usePolyFitTransitModel  =
       %tpsModuleParameters.superResolutionFactor  =
       %tpsModuleParameters.varianceWindowLengthMultiplier =
       %tpsModuleParameters.waveletFilterLength =
        cadencesPerHour = 1 / (median(diff(gapFilledTimestamps))*24);
        trialTransitPulseDurationInHours = 6;
        
        if (~isnan(fluxDetrended))
            % Ignore the edge effects by only looking at the center portion
            fluxTimeSeries.values = ...
                    fluxDetrended(cdppMedFiltSmoothLength:end-cdppMedFiltSmoothLength);
            if (length(fluxTimeSeries.values) < 1)
                cdpp(iTarget) = 0.0;
            else
                cdppTemp = calculate_cdpp_wrapper (fluxTimeSeries, cadencesPerHour, trialTransitPulseDurationInHours, tpsModuleParameters);
                cdpp(iTarget) = cdppTemp.rms;
            end
        else
            cdpp(iTarget) = 0.0;
        end

    end
else
    doCdpp = false;
end

%*******************************************************************************************
% kepstddev 
% find the running bin standard deviation, which is the method used in the GO tool kepstddev
%*******************************************************************************************

runningBinLength = 13;

gapFilledTimestamps  = pdc_fill_cadence_times (cadenceTimes);

kepstddev = zeros(nTargets,1);
for iTarget = 1 : nTargets

    targetIndex = targetList(iTarget);
    
    % Flux here is normalized
    gaps = correctedDataStruct(targetIndex).gapIndicators;
    flux = correctedDataStruct(targetIndex).values;
    
    %***
    % Condition the data
    flux(gaps) = nan;
    
    % NaNs will "NaN" the medfilt1 values within cdppMedFiltSmoothLength cadences from each NaNed cadence, 
    % so we need to simply fill the gaps.
    if (~isempty(flux(~gaps)))
        flux(gaps)   = interp1(gapFilledTimestamps(~gaps), flux(~gaps), gapFilledTimestamps(gaps), 'pchip');
    end
        
    % Calculate the running bin standard deviation
    startCadence = ceil(runningBinLength / 2);
    endCadence = floor(nCadences - runningBinLength / 2);
    binHalfLength = floor(runningBinLength / 2);
    runningStd = nan(nCadences,1);
    for iCadence = startCadence : endCadence
        runningStd(iCadence) = std(flux(iCadence-binHalfLength:iCadence+binHalfLength)) / sqrt(runningBinLength);
    end

    % take the median of the running std then divide by the median flux value times 1e6 to get ppm
    kepstddev(iTarget) = nanmedian(runningStd) * 1e6;

end

% Sometimes, median(flux) can be negative)
kepstddev(kepstddev < 0) = 0;

%*******************************************************************************************
% K2 Roll Sawtooth removal
% Roll tweak is potentially every 12th cadence. Look at residual power at 6-hour period
% Some of this is a repeat from the CDPP calcualtion but keeping completely seperate (and repeating) for clearity.
%*******************************************************************************************

rollTweakFreqInCadences = 12;
bandPassInCadences = 0.25; % Band pass about roll tweak frequency to integrate over

rollTweak = zeros(nTargets,1);
isK2Data = true;
if (isK2Data)
    doRollTweak = true;

    gapFilledTimestamps  = pdc_fill_cadence_times (cadenceTimes);

    for iTarget = 1 : nTargets
        targetIndex = targetList(iTarget);
        
        % Flux here is normalized
        gaps = correctedDataStruct(targetIndex).gapIndicators;
        inputFlux  = rawDataStruct(targetIndex).values;
        outputFlux = correctedDataStruct(targetIndex).values;
        
        %***
        % Condition the data
        inputFlux(gaps) = nan;
        outputFlux(gaps) = nan;
        
        if (~isempty(inputFlux(~gaps)))
            inputFlux(gaps)   = interp1(gapFilledTimestamps(~gaps), inputFlux(~gaps), gapFilledTimestamps(gaps), 'pchip');
            outputFlux(gaps)   = interp1(gapFilledTimestamps(~gaps), outputFlux(~gaps), gapFilledTimestamps(gaps), 'pchip');
        end
        
        %***
        % Compute the PSD at the frequency of the roll tweak
        [pInput, w] = periodogram(inputFlux);
        [pOutput, ~] = periodogram(outputFlux);

       %medianCadenceLength = median(diff(gapFilledTimestamps(gapFilledTimestamps>0)));
        cadencesPerTwoPiRads = 1 / (2 * pi);

        periodInCadences = (w * cadencesPerTwoPiRads).^-1;

        % Integrated power about Roll Tweak Frequency
        datumsToIntegrateRange = [rollTweakFreqInCadences - bandPassInCadences, rollTweakFreqInCadences + bandPassInCadences];
        useTheseDatums = periodInCadences >= datumsToIntegrateRange(1) & periodInCadences <= datumsToIntegrateRange(2);

        integratedPowerInput  = sum(real(pInput(useTheseDatums))) / sum(useTheseDatums); 
        integratedPowerOutput = sum(real(pOutput(useTheseDatums))) / sum(useTheseDatums); 

        % change in power within bandpass
        rollTweak(iTarget) = (integratedPowerInput - integratedPowerOutput) / integratedPowerInput;
       %rollTweak(iTarget) = (integratedPowerInput - integratedPowerOutput);

    end
else
    doRollTweak = false;
end

%*******************************************************************************************

% We want the goodness to span (0,1] so take the inverse of each component
correlationSum = 1 ./ (correlationSum+1);
deltaVariability = 1 ./ (deltaVariability+1);
deltaNoise = 1 ./ (deltaNoise+1);
spikeRemoval = 1 ./ (spikeRemoval+1);
% EP Goodness already spanning (0,1]

% Total goodness is geometric mean of the components
% 3, 4 or 5 total components
if (calcEpGoodness && ~isempty(basisVectors))
    % earthPointRemoval can be NaN, ignore this component for such targets.
    nanEarthPointGoodnessHere = isnan(earthPointRemoval);
    goodness(~nanEarthPointGoodnessHere)  = nthroot(correlationSum(~nanEarthPointGoodnessHere) .* deltaVariability(~nanEarthPointGoodnessHere) .* ...
                        deltaNoise(~nanEarthPointGoodnessHere) .* spikeRemoval(~nanEarthPointGoodnessHere) .*earthPointRemoval(~nanEarthPointGoodnessHere) ,5);
    goodness(nanEarthPointGoodnessHere)  = nthroot(correlationSum(nanEarthPointGoodnessHere) .* deltaVariability(nanEarthPointGoodnessHere) .* ...
                                                  spikeRemoval(nanEarthPointGoodnessHere) .*  deltaNoise(nanEarthPointGoodnessHere),4);
elseif(calcEpGoodness)
    nanEarthPointGoodnessHere = isnan(earthPointRemoval);
    goodness(~nanEarthPointGoodnessHere)  = nthroot(correlationSum(~nanEarthPointGoodnessHere) .* deltaVariability(~nanEarthPointGoodnessHere) .* ...
                        deltaNoise(~nanEarthPointGoodnessHere).*earthPointRemoval(~nanEarthPointGoodnessHere) ,4);
    goodness(nanEarthPointGoodnessHere)  = nthroot(correlationSum(nanEarthPointGoodnessHere) .* deltaVariability(nanEarthPointGoodnessHere) .* ...
                                                  deltaNoise(nanEarthPointGoodnessHere),3);
elseif(~isempty(basisVectors))
    goodness = nthroot(correlationSum .* deltaVariability .* deltaNoise .* spikeRemoval,4);
else
    goodness = nthroot(correlationSum .* deltaVariability .* deltaNoise,3);
end

if (doAllTargets && isfield(correctedDataStruct, 'excludeBasedOnLabels'))
    % only use non-custom targets for percentile calculation
    reducedCorrelationSum    = correlationSum(~[correctedDataStruct.excludeBasedOnLabels]);
    reducedDeltaVariability  = deltaVariability(~[correctedDataStruct.excludeBasedOnLabels]);
    reducedDeltaNoise        = deltaNoise(~[correctedDataStruct.excludeBasedOnLabels]);
    reducedEarthPointRemoval = earthPointRemoval(~[correctedDataStruct.excludeBasedOnLabels]);
    reducedSpikeRemoval      = spikeRemoval(~[correctedDataStruct.excludeBasedOnLabels]);
    reducedGoodness          = goodness(~[correctedDataStruct.excludeBasedOnLabels]);
    reducedCdppSum           = cdpp(~[correctedDataStruct.excludeBasedOnLabels]);
    reducedKepstddevSum      = kepstddev(~[correctedDataStruct.excludeBasedOnLabels]);
    reducedRollTweakSum      = rollTweak(~[correctedDataStruct.excludeBasedOnLabels]);
else
    reducedCorrelationSum    = correlationSum;
    reducedDeltaVariability  = deltaVariability;
    reducedDeltaNoise        = deltaNoise;
    reducedEarthPointRemoval = earthPointRemoval;
    reducedSpikeRemoval      = spikeRemoval;
    reducedGoodness          = goodness;
    reducedCdppSum           = cdpp;
    reducedKepstddevSum      = kepstddev;
    reducedRollTweakSum      = rollTweak;
end

% Populate the output structure

if (doAllTargets)
    correlationPercentileArray  = 100*ksdensity(reducedCorrelationSum,    correlationSum,   'function', 'cdf');
    variabilityPercentileArray  = 100*ksdensity(reducedDeltaVariability,  deltaVariability, 'function', 'cdf');
    noisePercentileArray        = 100*ksdensity(reducedDeltaNoise,        deltaNoise, 'function', 'cdf');
    spikePercentileArray        = 100*ksdensity(reducedSpikeRemoval,      spikeRemoval, 'function', 'cdf');
    if(calcEpGoodness)
        earthPercentileArray        = zeros(nTargets, 1);
        % ksdensity crashes if given NaNs
        if (~all(nanEarthPointGoodnessHere))
            earthPercentileArray(~nanEarthPointGoodnessHere) = 100*ksdensity(reducedEarthPointRemoval, earthPointRemoval(~nanEarthPointGoodnessHere), 'function', 'cdf');
        end
    end
    totalPercentileArray        = 100*ksdensity(reducedGoodness,     goodness, 'function', 'cdf');
    cdppPercentileArray         = 100*ksdensity(reducedCdppSum,      cdpp,  'function', 'cdf');
    kepstddevPercentileArray    = 100*ksdensity(reducedKepstddevSum, kepstddev,  'function', 'cdf');
    rollTweakPercentileArray    = 100*ksdensity(reducedRollTweakSum, rollTweak,  'function', 'cdf');
end

for iTarget = 1 : nTargets
    goodnessStruct(iTarget).keplerId                = rawDataStruct(targetList(iTarget)).keplerId;
    goodnessStruct(iTarget).correlation.value       = correlationSum(iTarget);
    goodnessStruct(iTarget).deltaVariability.value  = deltaVariability(iTarget);
    goodnessStruct(iTarget).introducedNoise.value   = deltaNoise(iTarget);
    goodnessStruct(iTarget).earthPointRemoval.value = earthPointRemoval(iTarget);
    goodnessStruct(iTarget).spikeRemoval.value      = spikeRemoval(iTarget);
    goodnessStruct(iTarget).total.value             = goodness(iTarget);
    goodnessStruct(iTarget).cdpp.value              = cdpp(iTarget);
    goodnessStruct(iTarget).kepstddev.value         = kepstddev(iTarget);
    goodnessStruct(iTarget).rollTweak.value         = rollTweak(iTarget);

    if (doAllTargets)
        goodnessStruct(iTarget).correlation.percentile          = correlationPercentileArray(iTarget);
        goodnessStruct(iTarget).deltaVariability.percentile     = variabilityPercentileArray(iTarget);
        goodnessStruct(iTarget).introducedNoise.percentile      = noisePercentileArray(iTarget);      
        goodnessStruct(iTarget).spikeRemoval.percentile         = spikePercentileArray(iTarget);
        % ksdensity crashes if given NaNs
        if (calcEpGoodness && ~nanEarthPointGoodnessHere(iTarget))
            goodnessStruct(iTarget).earthPointRemoval.percentile     = earthPercentileArray(iTarget);
        end
        goodnessStruct(iTarget).total.percentile                = totalPercentileArray(iTarget); 
        goodnessStruct(iTarget).cdpp.percentile                 = cdppPercentileArray(iTarget);
        goodnessStruct(iTarget).kepstddev.percentile            = kepstddevPercentileArray(iTarget);
        goodnessStruct(iTarget).rollTweak.percentile            = rollTweakPercentileArray(iTarget);
    end
end

% Plot the results
if (doAllTargets && plottingEnabled)
    figureHandles(1) = figure;
    subplot(2,1,1)
    goodnessArray       = [goodnessStruct.total];
    correlationArray    = [goodnessStruct.correlation];
    variabilityArray    = [goodnessStruct.deltaVariability];
    noiseArray          = [goodnessStruct.introducedNoise];
    earthPointArray     = [goodnessStruct.earthPointRemoval];
    spikeRemovalArray   = [goodnessStruct.spikeRemoval];
    plot([goodnessArray.value], '-*k')
    title([plotTitleIntro, 'Goodness Metric']);
    ylabel('Goodness (0,1]; 1 := good ');
    xlabel('Target Index');
    grid on;
    axis([0 nTargets 0 1]);
    % The components plotted together
    subplot(2,1,2);
    plot([correlationArray.value], '-*b');
    hold on;
    plot([variabilityArray.value], '-*r');
    plot([noiseArray.value], '-*m');
    if (~isempty(basisVectors))
        plot([spikeRemovalArray.value], '-*c');
    end
    if (calcEpGoodness)
        plot([earthPointArray.value], '-*g');
    end
    title([plotTitleIntro, 'Components to Goodness Metric']);
    ylabel('Goodness (0,1]; 1 := good ');
    xlabel('Target Index');
    grid on;
    axis([0 nTargets 0 1]);
    if (calcEpGoodness && ~isempty(basisVectors))
        legend('Correlation Part', 'Delta Variability Part', 'Delta Noise Part', 'Spike Removal Part', 'Earth Point Part', 'Location', 'Best');
    elseif (calcEpGoodness)
        legend('Correlation Part', 'Delta Variability Part', 'Delta Noise Part', 'Earth Point Part', 'Location', 'Best');
    elseif (~isempty(basisVectors))
        legend('Correlation Part', 'Delta Variability Part', 'Delta Noise Part', 'Spike Removal Part', 'Location', 'Best');
    else
        legend('Correlation Part', 'Delta Variability Part', 'Delta Noise Part', 'Location', 'Best');
    end

    % Plot the goodness percentiles
    figureHandles(2) = figure;    
    [f, xi] = ksdensity(reducedCorrelationSum, 'function', 'cdf');
    plot(xi, 100*(1-f), '-b');
    hold on;
    [f, xi] = ksdensity(reducedDeltaVariability, 'function', 'cdf');
    plot(xi, 100*(1-f), '-r');
    [f, xi] = ksdensity(reducedDeltaNoise, 'function', 'cdf');
    plot(xi, 100*(1-f), '-m');
    [f, xi] = ksdensity(reducedSpikeRemoval, 'function', 'cdf');
    plot(xi, 100*(1-f), '-c');
    if (calcEpGoodness && any(~nanEarthPointGoodnessHere))
        % find targets in the reduced list that are not NaN
        nanReducedEarthPointGoodnessHere = isnan(reducedEarthPointRemoval);
        [f, xi] = ksdensity(reducedEarthPointRemoval(~nanReducedEarthPointGoodnessHere), 'function', 'cdf');
        plot(xi, 100*(1-f), '-g');
    end
    [f, xi] = ksdensity(reducedGoodness, 'function', 'cdf');
    plot(xi, 100*(1-f), '-k');
    grid on;
    if (calcEpGoodness)
        legend('Correlation Part', 'Delta Variability Part', 'Delta Noise Part', 'Spike Removal Part', 'Earth Point Part', 'Total', 'Location', 'NorthWest');
    else
        legend('Correlation Part', 'Delta Variability Part', 'Delta Noise Part', 'Spike Removal Part', 'Total', 'Location', 'NorthWest');
    end
    title([plotTitleIntro, 'Goodness Metric Percentile values']);
    xlabel('Goodness Value');
    axis([0 1 0 100]);
    set(gca, 'YDir', 'reverse');
    ylabel('Percent at or above based on non-custom targets [%]');


    % Plot the correlation matrix only if figures are not being saved (huge file size)
    if (~doSavePlots)
        figureHandles(3) = figure;    
        imagesc(abs(correlationMatrix), [0,1]);
        colorbar;
        title([plotTitleIntro, 'Empirical Target to Target Correlation for Corrected Data']);
    end

    % Plot the mean absolute correlation per star
    figureHandles(4) = figure;    
    %medianAbsCorrPerStar = nanmedian(abs(correlationMatrix));
    medianAbsCorrPerStar = nanmean(abs(correlationMatrix));
    hist(medianAbsCorrPerStar, 50, 'r');
    grid on;
    xlim([0,1]);
    title([plotTitleIntro, 'Mean Absolute Correlation Per Star; Median Correlation Overall: ', ...
        num2str(median(medianAbsCorrPerStar)), '; for Corrected Data']);

    % Plot the CDPP
    if (doCdpp)

        % Histogram
        figureHandles(5) = figure;    
        % Only show 95th percentile values to ignore outliers
        hist(cdpp(cdpp < prctile(cdpp, 95)), 150, 'b*');
        medianCdpp = median(cdpp);
        title([plotTitleIntro, 'Quasi-CDPP for all targets; median = ', num2str(medianCdpp)]);
        grid on;

        % Vs. Kepler Mag
        figureHandles(6) = figure;
        keplerMags = [rawDataStruct.keplerMag];
        plot(keplerMags, cdpp , '.');
        axis([8 17 0 1000]);
        title('CDPP vs. KeplerMag');

        % over Field of View
        ra = [rawDataStruct.kic];
        ra = [ra.ra];
        ra = [ra.value];
        dec = [rawDataStruct.kic];
        dec = [dec.dec];
        dec = [dec.value];
        RA_HOURS_TO_DEGREES = 360 / 24;
        ra= RA_HOURS_TO_DEGREES .* ra;

        figureHandles(7) = figure;
        % Scatter plot does not like zero values
        nonZeroCdpp = cdpp > 0;
        scatter(dec(nonZeroCdpp), ra(nonZeroCdpp), cdpp(nonZeroCdpp)./500)
        title('CDPP Vs Field Of View')
    end

    % Plot the Roll Tweak Removal
    if (doRollTweak)
        figureHandles(8) = figure;    
        plot(rollTweak, 'b*');
        medianRollTweak = median(rollTweak);
        title([plotTitleIntro, 'Roll Tweak Goodness for all targets; median = ', num2str(medianRollTweak)]);
        xlabel('Target Index');
    end

    % Plot the kepstddev
   %figureHandles(9) = figure;    
   %% Only show values below 1000 to make the histogram bottom legible
   %hist(kepstddev(kepstddev < prctile(kepstddev, 95)), 150, 'b*');
   %medianKepstddev = median(kepstddev);
   %title([plotTitleIntro, 'GO kepstddev for all targets; median = ', num2str(medianKepstddev)]);
   %grid on;

    % Vs. Kepler Mag
    figureHandles(9) = figure;
    keplerMags = [rawDataStruct.keplerMag];
    plot(keplerMags, kepstddev, '.');
    axis([8 17 0 1000]);
    title('kepstddev vs. KeplerMag');


    if (doSavePlots)
        directory = fullfile(plotSubDir);
        if (~exist(directory, 'dir'))
            mkdir(directory);
        end
 
        % Goodness Metric
        filename = 'goodness_metric';
        fullFilename = fullfile(directory, filename);
        saveas (figureHandles(1), fullFilename, saveFigureFormat);
        close(figureHandles(1));
 
        % Goodness Percentiles
        filename = 'goodness_percentiles';
        fullFilename = fullfile(directory, filename);
        saveas (figureHandles(2), fullFilename, saveFigureFormat);
        close(figureHandles(2));
 
        % Median absolute correlation per star
        filename = 'correlation_histogram';
        fullFilename = fullfile(directory, filename);
        saveas (figureHandles(4), fullFilename, saveFigureFormat);
        close(figureHandles(4));

        % CDPP
        if (doCdpp)
            filename = 'quasi-CDPP';
            fullFilename = fullfile(directory, filename);
            saveas (figureHandles(5), fullFilename, saveFigureFormat);
            close(figureHandles(5));

            filename = 'quasi-CDPP_vs_kepMag';
            fullFilename = fullfile(directory, filename);
            saveas (figureHandles(6), fullFilename, saveFigureFormat);
            close(figureHandles(6));

            filename = 'quasi-CDPP_vs_FOV';
            fullFilename = fullfile(directory, filename);
            saveas (figureHandles(7), fullFilename, saveFigureFormat);
            close(figureHandles(7));
        end

        % Roll Tweak
        if (doRollTweak)
            filename = 'thruster_firing';
            fullFilename = fullfile(directory, filename);
            saveas (figureHandles(8), fullFilename, saveFigureFormat);
            close(figureHandles(8));
        end

        % kepstddev
        filename = 'kepstddev';
        fullFilename = fullfile(directory, filename);
        saveas (figureHandles(9), fullFilename, saveFigureFormat);
        close(figureHandles(9));


    end
end

if(doAllTargets)
    duration = toc(goodnesstic);
    display(['Finished Computing PDC Goodness Metric for ', plotTitleIntro, ': ' num2str(duration) ' seconds = '  num2str(duration/60) ' minutes']);
end

return
