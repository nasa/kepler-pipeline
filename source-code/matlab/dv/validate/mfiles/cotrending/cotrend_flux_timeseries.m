function [cotrendedFluxTimeSeries, fittedFluxTimeSeries, ...
saturationSegmentsStruct, shortTimeScalePowerRatio] = ...
cotrend_flux_timeseries(designMatrix, pdcModuleParameters, ...
saturationSegmentConfigurationStruct, gapFillParametersStruct, ...
targetDataStruct, restoreMeanFlag, dataAnomalyIndicators)
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
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [cotrendedFluxTimeSeries, fittedFluxTimeSeries, ...
% saturationSegmentsStruct, shortTimeScalePowerRatio] = ...
% cotrend_flux_timeseries(designMatrix, pdcModuleParameters, ...
% saturationSegmentConfigurationStruct, gapFillParametersStruct, ...
% targetDataStruct, restoreMeanFlag, dataAnomalyIndicators)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% This PDC function removes systematic errors by cotrending the flux time
% series for a number of targets against a set of conditioned ancillary
% data. Cotrending is performed by robust fit or by (reduced) singular
% value decomposition of a design matrix and least squares projection
% (P = U * U'). The number of columns of the U matrix that are utilized for
% the projection is determined by the rank of the design matrix (via matlab
% tolerance test for each singular value).
%
% For the least squares cotrending, all targets with identical sets of data
% gaps are processed together, with a single SVD for the group. The rows of
% the design matrix corresponding to the target flux data gaps are removed
% prior to computation of the SVD. Gaps are placed in the fitted series and
% the cotrended series for each target where gaps were present in the
% associated flux time series. The cotrended flux time series (from which
% the nonlinear trend has been removed), and the fitted flux time series
% (representing the nonlinear trend due to systematic errors) are returned
% by this function.
%
% Also compute and return for each target the ratio of the power on short
% time scales in the corrected flux to raw flux. If this ratio is
% significantly greater than one then the cotrending has done more harm
% than good! This has generally been observed for variable targets without
% identifiable harmonic content.
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


% Set constant.
SG_POLY_ORDER = 2;

% Get parameter values.
robustCotrendFitFlag = pdcModuleParameters.robustCotrendFitFlag;
cadenceDurationInMinutes = gapFillParametersStruct.cadenceDurationInMinutes;

if isfield(pdcModuleParameters, 'cotrendRatioMaxTimeScaleInDays')
    cotrendRatioMaxTimeScaleInDays = ...
        pdcModuleParameters.cotrendRatioMaxTimeScaleInDays;
else
    cotrendRatioMaxTimeScaleInDays = 1.0;
end

% Get the number of stellar targets.
nTargets = length(targetDataStruct);

% Compute the SG filter length for computation of the short time scale
% power. Ensure that it is odd.
sgFilterLength = ...
    round(cotrendRatioMaxTimeScaleInDays * get_unit_conversion('day2min') / ...
    cadenceDurationInMinutes);
if mod(sgFilterLength, 2) == 0
    sgFilterLength = sgFilterLength + 1;
end

nCadencesToIgnore = (sgFilterLength - 1) / 2;

% Save the flux, uncertainties and gap indicators before removing the giant
% transits. Set all missing flux values and uncertainties to zero.
keplerMags = [targetDataStruct.keplerMag];
fluxArray = [targetDataStruct.values];
uncertaintiesArray = [targetDataStruct.uncertainties];
gapIndicatorsArray = [targetDataStruct.gapIndicators];

fluxArray(gapIndicatorsArray) = 0;
uncertaintiesArray(gapIndicatorsArray) = 0;

% Initialize the output structures.
cotrendedFluxTimeSeries = repmat(struct( ...
    'values', [], ...
    'uncertainties', [], ...
    'gapIndicators', [] ), [1, nTargets]);

fittedFluxTimeSeries = repmat(struct( ...
    'values', [], ...
    'uncertainties', [], ...
    'gapIndicators', [] ), [1, nTargets]);

shortTimeScalePowerRatio = zeros([nTargets, 1]);

% Identify the astrophysical events for each target and replace them prior
% to locating the saturation segments and performing a (non-robust)cotrend
% fit.
[fluxWithoutTransitsArray] = ...
    replace_astrophysical_events(fluxArray, gapIndicatorsArray, ...
    pdcModuleParameters, gapFillParametersStruct, dataAnomalyIndicators);

% Attempt to locate saturation segments where flux curves have abrupt
% change in curvature. These will be cotrended separately.
[saturationSegmentsStruct] = ...
    locate_saturation_segments(saturationSegmentConfigurationStruct, ...
    fluxWithoutTransitsArray, gapIndicatorsArray, keplerMags, ...
    dataAnomalyIndicators);

% Create lists of standard (unsaturated) and saturated targets to be
% processed.
saturatedTargetList = [saturationSegmentsStruct.target];
standardTargetList = (1 : nTargets);
standardTargetList = setdiff(standardTargetList, saturatedTargetList);

% Loop through the list of standard targets, processing each target with all
% other targets that have identical gaps (i.e. missing data for the same set
% of cadences). The SVD-based fit for each target is to the flux for that
% target with giant transits removed. The residual ("cotrended") flux for
% each target does include the giant transits. The mean flux for each
% target is added back to the residual flux in computing the 
while ~isempty(standardTargetList)
    
    % Find all flux time series with gap indicator sequences that match the
    % gap indicator sequence of the first target in the list.
    targetToMatch = standardTargetList(1);
    gapIndicatorsToMatch = gapIndicatorsArray( : , targetToMatch);
    gapsIndicatorsToMatchArray = ...
        repmat(gapIndicatorsToMatch, [1, length(standardTargetList)]);
    matchingTargetList = standardTargetList(all(gapsIndicatorsToMatchArray == ...
        gapIndicatorsArray( : , standardTargetList)));
    clear gapsIndicatorsToMatchArray;
    
    % Collect the valid flux samples (with giant transits removed) for all
    % targets in the matching list and the rows of the design matrix where
    % there are no data gaps.
    fluxWithoutTransitsNoGapsArray = ...
        fluxWithoutTransitsArray(~gapIndicatorsToMatch, ...
        matchingTargetList);
    A = designMatrix(~gapIndicatorsToMatch, : );
    nValidCadences = size(A, 1);
 
    % Filter the flux without transits and compute the power on short time
    % scales for each target. Use mad rather than std to reduce effects of
    % filtering at discontinuities.
    if nValidCadences > sgFilterLength
        shortTimeScaleFluxWithoutTransits = fluxWithoutTransitsNoGapsArray - ...
            sgolayfilt(fluxWithoutTransitsNoGapsArray, SG_POLY_ORDER, sgFilterLength);
        shortTimeScaleFluxWithoutTransits(1 : nCadencesToIgnore, : ) = [];
        shortTimeScaleFluxWithoutTransits(end - nCadencesToIgnore + 1: end, : ) = [];
        shortTimeScaleRawFluxPower = mad(shortTimeScaleFluxWithoutTransits, 1)' .^ 2;
    else
        shortTimeScaleRawFluxPower = ones([length(matchingTargetList), 1]);
    end % if / else
    
    % Compute the mean flux (after giant transits have been removed) for
    % all targets in the list.    
    if ~restoreMeanFlag || isempty( fluxWithoutTransitsNoGapsArray  )
        meanFlux = zeros([1, size(fluxWithoutTransitsNoGapsArray, 2)]);
    else
        meanFlux = mean(fluxWithoutTransitsNoGapsArray, 1);
    end
    
    % Do robust fit or least-squares projection based on SVD.
    if robustCotrendFitFlag
        
        % Try robust fitting to identify any outliers. This is
        % computationally intensive, as it must be performed separately
        % for all targets. Remove any outliers and then do cotrending with
        % weighted least squares. If the robust fit fails, then perform
        % cotrending by weighted least squares on target flux with transits
        % removed.
        cotrendedFluxWithoutTransitsNoGapsArray = ...
            zeros(size(fluxWithoutTransitsNoGapsArray));
        
        for iTarget = 1 : length(matchingTargetList)
            
            % Get the target, flux (with transits) and uncertainties.
            target = matchingTargetList(iTarget);
            targetFluxNoGaps = ...
                fluxArray(~gapIndicatorsToMatch, target);
            targetUncertainties = ...
                uncertaintiesArray(~gapIndicatorsToMatch, target);
            
            % Try a robust fit and identify outliers. Fall back to standard
            % least squares fit to flux without transits if the robust fit
            % fails.
            try
                warning off all
                [b, stats] = ...
                    robustfit(A, targetFluxNoGaps, [], [], 'off');
                warning on all
                robustWeights = sqrt(stats.w);
            catch
                targetFluxNoGaps = ...
                    fluxWithoutTransitsNoGapsArray( : , iTarget);
                robustWeights = ones(size(targetFluxNoGaps));
            end
            
            isOutlier = (0 == robustWeights);
            robustWeights = robustWeights(~isOutlier);
            
            % Trim the outliers and perform weighted least squares.
            % Obtain the transformation matrix explicitly for the
            % propagation of uncertainties.
            Arobust = A(~isOutlier, : );
            targetUncertaintiesRobust = ...
                targetUncertainties(~isOutlier) ./ robustWeights;
            warning off all
            Trobust = lscov(Arobust, sparse(eye(size(Arobust, 1))), ...
                targetUncertaintiesRobust .^ -2);
            warning on all
            Tparams = zeros(size(A'));
            Tparams( : , ~isOutlier) = Trobust;
            
            % Compute the fit and cotrended residual. Add back the mean
            % flux for the given target. Propagate the uncertainties and
            % populate the output structures. Neglect the very small
            % uncertainties in the mean flux for the purposes of POU.
            fittedFluxNoGaps = A * (Tparams * targetFluxNoGaps);
            cotrendedFluxNoGaps = ...
                targetFluxNoGaps - fittedFluxNoGaps + ...
                repmat(meanFlux(iTarget), [nValidCadences, 1]);
            cotrendedFluxWithoutTransitsNoGapsArray( : , iTarget) = ...
                fluxWithoutTransitsNoGapsArray( : , iTarget) - ...
                fittedFluxNoGaps + repmat(meanFlux(iTarget), ...
                [nValidCadences, 1]);
            [Cfit, Ccot] = ...
                perform_robust_cotrending_pou(A, Tparams, ...
                targetUncertainties);
            
            [fittedFluxTimeSeries(target)] = ...
                populate_timeseries_structure_with_gapped_data( ...
                fittedFluxNoGaps, sqrt(Cfit), ...
                gapIndicatorsToMatch);
            [cotrendedFluxTimeSeries(target)] = ...
                populate_timeseries_structure_with_gapped_data( ...
                cotrendedFluxNoGaps, sqrt(Ccot), ...
                gapIndicatorsToMatch);
            
        end % for iTarget

    else % robust fit is not enabled
    
        % Compute the reduced SVD of the design matrix.
        [U, S, V] = svd(A, 0);                                                           %#ok<NASGU>

        % In order to determine the number of columns of U to use for 
        % cotrending, determine the rank of the design matrix by comparing
        % each of the singular values to a tolerance equal to the maximum 
        % dimension (generally the number of rows) of A times the machine
        % precision at the largest singular value of A. This is comparable
        % (though not identical) to the discussion in Numerical Recipes
        % where the tolerance is set to N (i.e. number of rows of A) times
        % the machine precision times the largest singular value of A.
        nColumns = rank(A);
            
        % Compute the least squares projection (i.e. fitted flux) directly.
        % This may be performed with only the (reduced) U matrix from the
        % SVD.
        temp = U( : , 1:nColumns)' * fluxWithoutTransitsNoGapsArray;
        fittedFluxNoGapsArray = U( : , 1:nColumns) * temp;
        
        % Restore original flux (with giant transits). Compute the residual
        % between the flux time series and the fitted flux time series, and
        % add back the mean flux.
        fluxNoGapsArray = ...
            fluxArray(~gapIndicatorsToMatch, matchingTargetList);
        cotrendedFluxNoGapsArray = ...
            fluxNoGapsArray - fittedFluxNoGapsArray + ...
            repmat(meanFlux, [nValidCadences, 1]);
        cotrendedFluxWithoutTransitsNoGapsArray = ...
            fluxWithoutTransitsNoGapsArray - fittedFluxNoGapsArray + ...
            repmat(meanFlux, [nValidCadences, 1]);
        clear fluxNoGapsArray
        
        % For each target, propagate the uncertainties and populate the
        % output structures. Neglect the very small uncertainties in the
        % mean flux for the purpose of POU.
        for iTarget = 1 : length(matchingTargetList)
        
            target = matchingTargetList(iTarget);
            targetUncertainties = ...
                uncertaintiesArray(~gapIndicatorsToMatch, target);
            [Cfit, Ccot] = ...
                pdc_perform_svd_cotrending_pou(U( : , 1:nColumns), ...
                targetUncertainties);
            
            [fittedFluxTimeSeries(target)] = ...
                populate_timeseries_structure_with_gapped_data( ...
                fittedFluxNoGapsArray( : , iTarget), sqrt(Cfit), ...
                gapIndicatorsToMatch);
            [cotrendedFluxTimeSeries(target)] = ...
                populate_timeseries_structure_with_gapped_data( ...
                cotrendedFluxNoGapsArray( : , iTarget), sqrt(Ccot), ...
                gapIndicatorsToMatch);
            
        end % for iTarget
        
    end % if/else
    
    % Filter the flux without transits and compute the power on short time
    % scales for each target.
    if nValidCadences > sgFilterLength
        shortTimeScaleFluxWithoutTransits = cotrendedFluxWithoutTransitsNoGapsArray - ...
            sgolayfilt(cotrendedFluxWithoutTransitsNoGapsArray, SG_POLY_ORDER, sgFilterLength);
        shortTimeScaleFluxWithoutTransits(1 : nCadencesToIgnore, : ) = [];
        shortTimeScaleFluxWithoutTransits(end - nCadencesToIgnore + 1: end, : ) = [];
        shortTimeScaleCorrectedFluxPower = mad(shortTimeScaleFluxWithoutTransits, 1)' .^ 2;
    else
        shortTimeScaleCorrectedFluxPower = ones([length(matchingTargetList), 1]);
    end % if / else
    
    shortTimeScalePowerRatio(matchingTargetList) = ...
        shortTimeScaleCorrectedFluxPower ./ shortTimeScaleRawFluxPower;
    
    % Clear arrays that are longer necessary.
    clear fittedFluxNoGapsArray cotrendedFluxNoGapsArray
    clear fluxWithoutTransitsNoGapsArray cotrendedFluxWithoutTransitsNoGapsArray
    clear shortTimeScaleFluxWithoutTransits
    
    % Update the list of remaining targets.
    standardTargetList = setdiff(standardTargetList, matchingTargetList);
    
end % while

% Now perform cotrending for each of the targets with saturation
% segments. These must be processed one at a time.
nSaturatedTargets = length(saturatedTargetList);

for iTarget = 1 : nSaturatedTargets
    
    % Identify the target and the indices of the segments.
    target = saturatedTargetList(iTarget);
    indxBreakPoints = ...
        saturationSegmentsStruct(iTarget).indxPeakStatistics;
    
    % Get the flux with and without transits and the gap indicators for the
    % given target.
    targetFlux = fluxArray( : , target);
    targetFluxWithoutTransits = fluxWithoutTransitsArray( : , target);
    gapIndicators = gapIndicatorsArray( : , target);
    
    % Remove the gaps from the target flux and the associated rows in the
    % design matrix.
    targetFluxNoGaps = targetFlux(~gapIndicators);
    targetFluxWithoutTransitsNoGaps = ...
        targetFluxWithoutTransits(~gapIndicators);
    A = designMatrix(~gapIndicators, : );
    nValidCadences = size(A, 1);
    
    % Filter the flux without transits and compute the power on short time
    % scales for each target. Use mad rather than std to reduce effects of
    % filtering at discontinuities.
    if nValidCadences > sgFilterLength
        shortTimeScaleFluxWithoutTransits = targetFluxWithoutTransitsNoGaps - ...
            sgolayfilt(targetFluxWithoutTransitsNoGaps, SG_POLY_ORDER, sgFilterLength);
        shortTimeScaleFluxWithoutTransits(1 : nCadencesToIgnore) = [];
        shortTimeScaleFluxWithoutTransits(end - nCadencesToIgnore + 1: end) = [];
        shortTimeScaleRawFluxPower = mad(shortTimeScaleFluxWithoutTransits, 1) .^ 2;
    else
        shortTimeScaleRawFluxPower = 1;
    end % if / else
    
    % Compute the mean flux for the given target.    
    if ~restoreMeanFlag || isempty( targetFluxWithoutTransitsNoGaps )
        meanFlux = zeros(size(targetFluxWithoutTransitsNoGaps,2));
    else
        meanFlux = mean(targetFluxWithoutTransitsNoGaps);
    end
    
    % Get the uncertainties in the flux for the given target.
    targetUncertainties = ...
        uncertaintiesArray(~gapIndicators, target);
    
    % Initialize the fitted and cotrended flux and covariance diagonals.
    fittedFluxNoGaps = zeros(size(targetFluxNoGaps));
    cotrendedFluxNoGaps = zeros(size(targetFluxNoGaps));
    cotrendedFluxWithoutTransitsNoGaps = zeros(size(targetFluxNoGaps));
    Cfit = zeros(size(targetFluxNoGaps));
    Ccot = zeros(size(targetFluxNoGaps));
    
    % Set the endpoint for the final segment as the last sample in the
    % time series. Do the cotrending on each of the segments. Use robust
    % fitting if the robust fit flag is set. Note that the indices of the
    % break points have already been computed with the gaps removed.
    nSegments = 1 + length(indxBreakPoints);
    indxBreakPoints(nSegments) = length(targetFluxWithoutTransitsNoGaps);
    indxStart = 1;
    
    for iSegment = 1 : nSegments
        
        indxStop = indxBreakPoints(iSegment);
        segA = A(indxStart : indxStop, : );
        segUncertainties = targetUncertainties(indxStart : indxStop);
        
        if robustCotrendFitFlag
            
            segFluxNoGaps = ...
                targetFluxNoGaps(indxStart : indxStop);
            
            try
                warning off all
                [b, stats] = ...
                    robustfit(segA, segFluxNoGaps, [], [], 'off');
                warning on all
                robustWeights = sqrt(stats.w);
            catch
                segFluxNoGaps = ...
                    targetFluxWithoutTransitsNoGaps(indxStart : indxStop);
                robustWeights = ones(size(segFluxNoGaps));
            end
            
            isOutlier = (0 == robustWeights);
            robustWeights = robustWeights(~isOutlier);
            segArobust = segA(~isOutlier, : );
            targetUncertaintiesRobust = ...
                segUncertainties(~isOutlier) ./ robustWeights;
            warning off all
            Trobust = lscov(segArobust, sparse(eye(size(segArobust, 1))), ...
                targetUncertaintiesRobust .^ -2);
            warning on all
            Tparams = zeros(size(segA'));
            Tparams( : , ~isOutlier) = Trobust;
            
            fittedFluxNoGaps(indxStart : indxStop) = ...
                segA * (Tparams * segFluxNoGaps);
            cotrendedFluxNoGaps(indxStart : indxStop) = ...
                targetFluxNoGaps(indxStart : indxStop) - ...
                fittedFluxNoGaps(indxStart : indxStop);
            cotrendedFluxWithoutTransitsNoGaps(indxStart : indxStop) = ...
                targetFluxWithoutTransitsNoGaps(indxStart : indxStop) - ...
                fittedFluxNoGaps(indxStart : indxStop);
            [Cfit(indxStart : indxStop), Ccot(indxStart : indxStop)] = ...
                perform_robust_cotrending_pou(segA, Tparams, ...
                segUncertainties);
            
        else % robust fit is not enabled
            
            segFluxNoGaps = ...
                targetFluxWithoutTransitsNoGaps(indxStart : indxStop);
        
            [U, S, V] = svd(segA, 0);                                                    %#ok<NASGU>
            nColumns = rank(segA);
            temp = U( : , 1:nColumns)' * segFluxNoGaps;
            fittedFluxNoGaps(indxStart : indxStop) = ...
                U( : , 1:nColumns) * temp;
            cotrendedFluxNoGaps(indxStart : indxStop) = ...
                targetFluxNoGaps(indxStart : indxStop) - ...
                fittedFluxNoGaps(indxStart : indxStop);
            cotrendedFluxWithoutTransitsNoGaps(indxStart : indxStop) = ...
                targetFluxWithoutTransitsNoGaps(indxStart : indxStop) - ...
                fittedFluxNoGaps(indxStart : indxStop);
            [Cfit(indxStart : indxStop), Ccot(indxStart : indxStop)] = ...
                pdc_perform_svd_cotrending_pou(U( : , 1:nColumns), ...
                segUncertainties);
            
        end % if/else
        
        indxStart = indxStop + 1;
        
    end % for iSegment
    
    % Add back the mean flux for the given target.
    cotrendedFluxNoGaps = cotrendedFluxNoGaps + ...
        repmat(meanFlux, [nValidCadences, 1]);
    cotrendedFluxWithoutTransitsNoGaps = cotrendedFluxWithoutTransitsNoGaps + ...
        repmat(meanFlux, [nValidCadences, 1]);
    
    % Fill the output structure for the given saturated target.
    [fittedFluxTimeSeries(target)] = ...
        populate_timeseries_structure_with_gapped_data( ...
        fittedFluxNoGaps, sqrt(Cfit), gapIndicators);     
    [cotrendedFluxTimeSeries(target)] = ...
        populate_timeseries_structure_with_gapped_data( ...
        cotrendedFluxNoGaps, sqrt(Ccot), gapIndicators);
    
    % Filter the flux without transits and compute the power on short time
    % scales for each target.
    if nValidCadences > sgFilterLength
        shortTimeScaleFluxWithoutTransits = cotrendedFluxWithoutTransitsNoGaps - ...
            sgolayfilt(cotrendedFluxWithoutTransitsNoGaps, SG_POLY_ORDER, sgFilterLength);
        shortTimeScaleFluxWithoutTransits(1 : nCadencesToIgnore) = [];
        shortTimeScaleFluxWithoutTransits(end - nCadencesToIgnore + 1: end) = [];
        shortTimeScaleCorrectedFluxPower = mad(shortTimeScaleFluxWithoutTransits, 1) .^ 2;
    else
        shortTimeScaleCorrectedFluxPower = 1;
    end % if / else
    
    shortTimeScalePowerRatio(target) = ...
        shortTimeScaleCorrectedFluxPower ./ shortTimeScaleRawFluxPower;
        
end % for iTarget

% Return.
return
