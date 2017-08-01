function [variableTargetList, normalizedFluxValues] = ...
identify_variable_targets(fluxValues, fluxGapIndicators, detrendOrder, ...
variabilityThreshold, ensembleCorrectionEnabled, thresholdMinMads, ...
medianFilterLengthForThresholds, robustDetrendingEnabled)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [variableTargetList] = ...
% identify_variable_targets(fluxValues, fluxGapIndicators, detrendOrder, ...
% variabilityThreshold, ensembleCorrectionEnabled, thresholdMinMads, ...
% medianFilterLengthForThresholds, robustDetrendingEnabled)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Identify variable targets above the threshold level and return a list of
% such targets. Perform detrending on a target by target basis, normalize
% the detrended flux by the median flux level for each target, and then
% identify the targets with multiple successive flux values above the
% threshold level. Do simple ensemble correction for biases in normalized
% flux and limit the number of targets over threshold on bad cadences.
%
% It is possible to use optional robust detrending, but this tends to
% suffer from edge effects and false positive variable flux
% identifications.
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Inputs:
%
%                fluxValues: [float array]  nCadences x nTargets array of
%                                           target flux values
%       fluxGapIndicators: [logical array]  nCadences x nTargets array of
%                                           flux gap indicators
%                      detrendOrder: [int]  order for flux time series detrending
%            variabilityThreshold: [float]  fractional threshold for
%                                           identification of variable
%                                           targets
%     ensembleCorrectionEnabled: [logical]  make ensemble correction if true
%                                           (optional)
%                thresholdMinMads: [float]  minimum number of MADs to apply
%                                           variability threshold on each cadence
%                                           (optional)
%   medianFilterLengthForThresholds: [int]  length of filter for smoothing
%                                           thresholds
%       robustDetrendingEnabled: [logical]  true for robust detrending
%                                           (optional)
%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Outputs:
%
%          variableTargetList: [int array]  indices of variable targets
%      normalizedFluxValues: [float array]  nCadences x nVariableTargets array
%                                           of normalized flux values
%
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


% HARD CODE THE DEFAULTS FOR OPTIONAL PARAMETERS.
ENSEMBLE_CORRECTION_ENABLED = true;
THRESHOLD_MIN_MADS = 10;
MEDIAN_FILTER_LENGTH = 5;
ROBUST_DETRENDING_ENABLED = false;

% Set the input parameters if they were not specified.
if ~exist('ensembleCorrectionEnabled', 'var')
    ensembleCorrectionEnabled = ENSEMBLE_CORRECTION_ENABLED;
end

if ~exist('thresholdMinMads', 'var')
    thresholdMinMads = THRESHOLD_MIN_MADS;
end

if ~exist('medianFilterLengthForThresholds', 'var')
    medianFilterLengthForThresholds = MEDIAN_FILTER_LENGTH;
end

if ~exist('robustDetrendingEnabled', 'var')
    robustDetrendingEnabled = ROBUST_DETRENDING_ENABLED;
end

% Get the numbers of targets and cadences.
nTargets = size(fluxValues, 2);
nCadences = size(fluxValues, 1);

% Compute the median flux per target.
fluxValues(fluxGapIndicators) = NaN;
medianTargetFlux = nanmedian(fluxValues);

% Create the design matrix for the robust fit.
designMatrix = x2fx((1 : nCadences)' / nCadences, (0 : detrendOrder)');

% Perform detrending on a target by target basis. Move on to the next
% target if the fit fails. Initialize the detrended flux for each target by
% subtracting the median target flux in case the polynomial detrending
% fails for any target.
detrendedFluxValues = fluxValues - repmat(medianTargetFlux,[nCadences, 1]);

for iTarget = 1 : nTargets
    
    % Get the flux values and gap indicators for the given target.
    values = fluxValues( : , iTarget);
    gapIndicators = fluxGapIndicators( : , iTarget);
    
    % Try the robust fit.
    try
        warning off all
        if robustDetrendingEnabled
            fitPoly = robustfit(designMatrix(~gapIndicators, : ), ...
                values(~gapIndicators), [], [], 'off');
        else
            fitPoly = ...
                designMatrix(~gapIndicators, : ) \ values(~gapIndicators);
        end
        warning on all
    catch
        continue
    end
    
    % Compute the fit residuals and save the detrended flux.
    fitResiduals = nan(size(gapIndicators));
    fitResiduals(~gapIndicators) = ...
        values(~gapIndicators) - designMatrix(~gapIndicators, : ) * fitPoly;
    detrendedFluxValues( : , iTarget) = fitResiduals;
    
end % for iTarget

% Normalize the detrended flux by the median flux level per target. Also
% correct for ensemble biases if the correction is enabled.
normalizedFluxValues = ...
    detrendedFluxValues ./ repmat(medianTargetFlux, [nCadences, 1]);
if ensembleCorrectionEnabled
    normalizedFluxValues = normalizedFluxValues - ...
        repmat(nanmedian(normalizedFluxValues, 2), [1, nTargets]);
end
clear fluxValues detrendedFluxValues fluxGapIndicators

% Identify the flux values over threshold by cadence and target. Relax the
% variability threshold on bad cadences if the ensemble correction is
% enabled. Smooth the thresholds prior to identifying the threshold
% crossings.
if ~ensembleCorrectionEnabled
    thresholdMinMads = 0;
end
cadenceThresholds = ...
    max(thresholdMinMads * mad(normalizedFluxValues', 1)', ...
    variabilityThreshold);
cadenceThresholds = medfilt1(cadenceThresholds - variabilityThreshold, ...
    medianFilterLengthForThresholds) + variabilityThreshold;
valuesOverThreshold = ...
    abs(normalizedFluxValues) > repmat(cadenceThresholds, [1, nTargets]);

% Variable targets are those with two or more consecutive flux values over
% threshold at least twice in the time series. Individual outliers are not
% sufficient to identify variable targets.
variableTargetList = [];

for iTarget = find(any(valuesOverThreshold))
    values = valuesOverThreshold( : , iTarget);
    gapIndicators = isnan(normalizedFluxValues( : , iTarget));
    [thresholdCrossingLocations] = ...
        find_datagap_locations(values(~gapIndicators));
    if sum(diff(thresholdCrossingLocations, 1, 2) > 0) > 1
        variableTargetList = [variableTargetList; iTarget];                                %#ok<AGROW>
    end % if
end % for iTarget

% Return the normalized flux values for the variable targets.
normalizedFluxValues = normalizedFluxValues( : , variableTargetList);

% Return.
return
