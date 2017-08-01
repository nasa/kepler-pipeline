%*************************************************************************************************************
%% function [variability, medianVariability] = pdc_calculate_stellar_variability ...
%               (targetDataStruct, coarseDetrendPolyOrder, doNormalizeFlux, doMaskEpRecovery, maskWindow, doRemoveEclipsingBinaries)
%*************************************************************************************************************
%
%   Finds the stellar variability by first removing a low order polynomial fit to the light curve then taking
%   the standard deviation of the residual then dividing by the rms uncertaintity normalized to the median
%   flux and finally dividing by the median variability. So, in mathematical form it evaulates the following:
%
%   SV = mad(flux_{poly_removed}) / rmsUncertainties / median(SV)
%
%   Where
%       flux_{poly_removed} = the flux time series after a low order polynomial fit is removed
%       rmsUncertainties    = sqrt(nanmedian(uncertainties .^ 2));
%
%   Note: This function requires flux to be NORMALIZED with the median Flux! If it is not already normalized
%   then set doNormalizeFlux = true.
%
%   Note: Polyfit only fits ungapped data.
%
%   Earth Point Recovery Masking: For Quiet targets the Earth-Point Recovery period looks "large" and can over-estimate the
%   target variability. It is therefore optional to mask these regions.
%
%   Flux is evaluated in a normalized frame. The normalization method is currently hardcoded as 'median'. In
%   general median is safer than mean due to outliers. Keep in mind the MAP fitting is by default performed within 'mean'
%   normalization (due to basis vector offset issues). There should be no problem with using a different
%   normalization here and should results in slightly better results.
%
%   Note: coarseDetrendPolyOrder, doMaskEpRecovery and maskWindow are in pdcModuleParameters for PDC runs.
%   However, this function can be called on its own outside PDC so the parameters are explicitely required
%   here.
%
%*************************************************************************************************************
% Inputs:
%   targetDataStruct            -- [struct array(nTargets)]
%       fields Used:
%           .values                 -- [double array(nCadences)] normalized or unnormalized flux
%           .gapIndicators          -- [logical array(nCadences)]
%           .uncertainties          -- [logical array(nCadences)]
%   cadenceTimes                -- [struct] Cadence times data. Only used if doMaskEpRecovery is true.
%   coarseDetrendPolyOrder      -- [double] polyfit order to use in detrending
%   doNormalizeFlux             -- [logical] If the flux is not already normalized then set this to true to normalize (default = median)
%                               -- OR [string] specifies normalization method. 
%   doMaskEpRecovery            -- [logical] If true then the Earth-Point recovery period is masked
%   maskWindow                  -- [double]  Cadence length for recovery window
%   doRemoveTransitsFromFlux    -- [logical] If true then known transits are removed form the flux before finding variability
%
%*************************************************************************************************************
% Outputs:
%   variability       -- [double array(nTargets)] variabilility for each target
%   medianVariability -- [double] median variabilility for all targets
%
%%*************************************************************************************************************
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

function [variability, medianVariability] = pdc_calculate_stellar_variability ...
            (targetDataStruct, cadenceTimes, coarseDetrendPolyOrder, doNormalizeFlux, doMaskEpRecovery, ...
             maskWindow, doRemoveTransitsFromFlux)

nTargets = length(targetDataStruct);

% Plotting some individual curves is a useful test to check that this is working properly but is not necessary
% for every run. So, turn this plotting off.
debugIndividualCurvePlots = false;

% Normalize Flux if needed
% Median normalization is recommened. The algorithm was developed assuming this normalization method
% is used. 
if (doNormalizeFlux)
    if (isa('doNormalizeFlux', 'char'));
        normMethod = doNormalizeFlux;
        normMethod = 'noiseFloor';
    else
        normMethod = 'median';
    end
    doNaNGaps = false;
    [targetDataStruct, ~, ~, ~, ~] = mapNormalizeClass.normalize_flux (targetDataStruct, normMethod, doNaNGaps, ...
                            doMaskEpRecovery, cadenceTimes, maskWindow);
elseif (~isfield(targetDataStruct, 'normMethod'))
    error ('pdc_calculate_stellar_flux can only be called on normalized flux');
end

%%******************************************************************************************
if (doRemoveTransitsFromFlux)
    % We need the gap filled cadence times. 
    gapFilledCadenceMidTimestamps  = pdc_fill_cadence_times (cadenceTimes);
    fluxValues = pdcTransitClass.create_transit_removed_flux_values (targetDataStruct, gapFilledCadenceMidTimestamps);
else
    fluxValues = [targetDataStruct.values];
end

gapIndicators = [targetDataStruct.gapIndicators];
uncertainties = [targetDataStruct.uncertainties];

if (doMaskEpRecovery)
    % Mask earth point recovery regions
    gapIndicators = pdc_mask_recovery_regions (gapIndicators, cadenceTimes, maskWindow);
end

%%******************************************************************************************
% Do low order polyfit to the flux
% Note: Polyfit doesn't like NaNs
% Unfortunately, can't parallelize this :(
x = [1:length(fluxValues(:,1))]';
targetsToPlot = [];
if (debugIndividualCurvePlots);
    % Randomly pick 5 targets to plot polyfit and residual
    targetsToPlot = randperm(nTargets);
    nTargetsToPlot = min(5, nTargets);
    targetsToPlot = targetsToPlot(1:nTargetsToPlot);
    lowOrderPolyFitPlot = figure;
end
nTargetsToPlot = length(find(targetsToPlot));
plottedTargetIndex = 0;
for iTarget = 1:nTargets
    % skip polyfit if numDataPoints < coarsDetrendPolyOrder
    if (length(fluxValues((~gapIndicators(:,iTarget)),iTarget)) < coarseDetrendPolyOrder)
        continue
    end
    [p, s, mu] = polyfit(x(~gapIndicators(:,iTarget)), fluxValues((~gapIndicators(:,iTarget)),iTarget), coarseDetrendPolyOrder);
    fluxValues(:,iTarget) = fluxValues(:,iTarget) - polyval(p, x, s, mu);
    if (any (iTarget == targetsToPlot))
        plottedTargetIndex = plottedTargetIndex + 1;
        figure(lowOrderPolyFitPlot);
        hold off;
        plot(fluxValues(:,iTarget) + polyval(p, x, s, mu), '-b');
        hold on;
        plot(polyval(p, x, s, mu), '--m', 'LineWidth', 2);
        plot(fluxValues(:,iTarget), '-r');
        legend('Raw light curve', 'Polyfit', 'Coarsly detrended light curve with Polyfit');
        title(['Polyfit to target index ', num2str(iTarget)]);
        string = ['Generated plot for target ', num2str(plottedTargetIndex), ' of ', num2str(nTargetsToPlot)];
        disp(string);
        pause;
    end
end

%%******************************************************************************************
% Do a low pass filter to remove noise floor using Savitsky-Golay
%fluxValues = sgolayfilt(fluxValues, 2, 101);


%%***
% In order to get unbiased statistics we need to NaN gaps
fluxValues(gapIndicators)    = NaN;
uncertainties(gapIndicators) = NaN;


%%***
fluxSigma = mad(fluxValues,1)' * 1.4826; % Median absolute deviation based sigma

%***
% Normalize by target RMS uncertainties, if NaN then no valid data.
% Find the raw flux uncertainty median deviation
 rmsUncertainties = sqrt(nanmedian(uncertainties .^ 2));
 variability = fluxSigma ./ rmsUncertainties';

%%***
% Normalize by median target variability ignoring NaNs which means no flux data for that target
% Only do this if the number fo targets is statistically large enough
if (nTargets > 100)
    % We only want to normalize by the median of the non-custom targets
    if (isfield(targetDataStruct, 'excludeBasedOnLabels'))
        % excludeBasedOnLabels is not always available
        medianVariability = nanmedian(variability(~[targetDataStruct.excludeBasedOnLabels]));
    else
        medianVariability = nanmedian(variability);
    end
    variability = variability / medianVariability;
else
    medianVariability = NaN;
end

clear fluxValues gapIndicators uncertainties;

% if variability is NaN then convert to 0
nanHere = isnan(variability);
variability(nanHere) = 0.0;

return

