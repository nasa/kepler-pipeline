function [paResultsStruct, motionPolyStruct] = ...
fit_motion_polynomials(paDataObject, paResultsStruct, targetList, ...
priorTargetStarResultsStruct)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [paResultsStruct, motionPolyStruct] = ...
% fit_motion_polynomials(paDataObject, paResultsStruct, targetList, ...
% priorTargetStarResultsStruct)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Fit two-dimensional motion polynomials separately to target row and
% column centroids for each cadence. Uses
% robust_polyfit2d/weighted_polyfit2D. Note that motion polynomials are fit
% as a function of right ascension and declination for the given module
% output. RA and DEC are both specified in units of degrees for the motion
% polynomial fitting. Add metadata to create motion polynomial super
% structure.
%
% Generate (warning) alerts in the event that the motion polynomials cannot
% be computed for any cadence.
%
% Exclude variable targets (at the specified level) and targets with out of
% family centroids from the motion polynomial fit.
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
processingK2Data = paDataObject.cadenceTimes.startTimestamps(1) > ...
    paDataObject.fcConstants.KEPLER_END_OF_MISSION_MJD;

% Set constant.
RA_HOURS_TO_DEGREES = 360 / 24;

% Get file names.
paFileStruct    = paDataObject.paFileStruct;
paStateFileName = paFileStruct.paStateFileName;

% Get fields from input object.
processingState = paDataObject.processingState;
ccdModule       = paDataObject.ccdModule;
ccdOutput       = paDataObject.ccdOutput;
startCadence    = paDataObject.startCadence;
endCadence      = paDataObject.endCadence;

cadenceTimes            = paDataObject.cadenceTimes;
startTimestamps         = cadenceTimes.startTimestamps;
midTimestamps           = cadenceTimes.midTimestamps;
endTimestamps           = cadenceTimes.endTimestamps;
cadenceGapIndicators    = cadenceTimes.gapIndicators;
cadenceNumbers          = cadenceTimes.cadenceNumbers;

% get pa configuration parameters
paConfigurationStruct                           = paDataObject.paConfigurationStruct;
ppaTargetPrfCentroidingEnabled                  = paConfigurationStruct.ppaTargetPrfCentroidingEnabled;
targetPrfCentroidingEnabled                     = paConfigurationStruct.targetPrfCentroidingEnabled;
stellarVariabilityDetrendOrder                  = paConfigurationStruct.stellarVariabilityDetrendOrder;
stellarVariabilityThreshold                     = paConfigurationStruct.stellarVariabilityThreshold;
madThresholdForCentroidOutliers                 = paConfigurationStruct.madThresholdForCentroidOutliers;
thresholdMultiplierForPositiveCentroidOutliers  = paConfigurationStruct.thresholdMultiplierForPositiveCentroidOutliers;

debugLevel  = paConfigurationStruct.debugLevel;
alerts      = paResultsStruct.alerts;


% get motion configuration parameters
motionConfigurationStruct       = paDataObject.motionConfigurationStruct;
aicOrderSelectionEnabled        = motionConfigurationStruct.aicOrderSelectionEnabled;
maxGappingIterations            = motionConfigurationStruct.maxGappingIterations;
robustWeightGappingThreshold    = motionConfigurationStruct.robustWeightGappingThreshold;
k2PpaTargetRejectionEnabled     = motionConfigurationStruct.k2PpaTargetRejectionEnabled;


% Load the target star results for all invocations from the state file if
% the list of targets in the *current* invocation is not provided.
% Otherwise just use the target list for the current invocation for the
% motion polynomial fit plus the results for PPA targets from prior
% invocations. That is useful for seeding PRF-based centroids for general
% targets based on motion polynomials fit to PPA targets only.
if ~exist('targetList', 'var')
    load(paStateFileName, 'paTargetStarResultsStruct');
else
    paTargetStarResultsStruct = [priorTargetStarResultsStruct, ...
        paResultsStruct.targetStarResultsStruct(targetList)];
end

% We can infer the contents of the state file from the processing state. If
% we're in the GENERATE_MOTION_POLYNOMIALS state, then PPA targets have
% been aggregated and are waiting in the state file. If we're in the final
% aggregation state (AGGREGATE_RESULTS), then all targets, PPA and non-PPA,
% have been aggregated. If fit_motion_polynomials() is called from the
% AGGREGATE_RESULTS state, we can also infer that there were insufficient
% PPA targets from which to derive the MPs and we should use all available
% targets.
switch processingState
    case 'GENERATE_MOTION_POLYNOMIALS'
        prfCentroidingEnabled = ppaTargetPrfCentroidingEnabled;
    case 'AGGREGATE_RESULTS'
        prfCentroidingEnabled = targetPrfCentroidingEnabled;
    otherwise
        prfCentroidingEnabled = targetPrfCentroidingEnabled;
end


% Exclude custom targets from motion polynomial fit
customTargetIndicators = is_valid_id([paTargetStarResultsStruct.keplerId],'custom');
paTargetStarResultsStruct = paTargetStarResultsStruct(~customTargetIndicators);


% Build arrays (nCadences x nTargets) with row and column centroids,
% uncertainties and gap indicators (which apply to both rows and columns).
if prfCentroidingEnabled
    prfCentroidArray = [paTargetStarResultsStruct.prfCentroids];
    centroidRowTimeSeriesArray = [prfCentroidArray.rowTimeSeries];
    centroidColumnTimeSeriesArray = [prfCentroidArray.columnTimeSeries];
    clear prfCentroidArray
else
    fluxWeightedCentroidArray = ...
        [paTargetStarResultsStruct.fluxWeightedCentroids];
    centroidRowTimeSeriesArray = ...
        [fluxWeightedCentroidArray.rowTimeSeries];
    centroidColumnTimeSeriesArray = ...
        [fluxWeightedCentroidArray.columnTimeSeries];
    clear fluxWeightedCentroidArray
end % if / else
    
centroidRows = [centroidRowTimeSeriesArray.values];
centroidRowUncertainties = [centroidRowTimeSeriesArray.uncertainties];
centroidColumns = [centroidColumnTimeSeriesArray.values];
centroidColumnUncertainties = [centroidColumnTimeSeriesArray.uncertainties];
gapArray = [centroidRowTimeSeriesArray.gapIndicators];

% If processing Kepler data or if K2 PPA target rejection is enabled,
% analyze the available PPA targets and reject variable and out of family
% targets. 
if ~processingK2Data || k2PpaTargetRejectionEnabled

    % Exclude variable targets from the motion polynomial fit and save the
    % keplerId's to the PA state file.
    fluxTimeSeriesArray = [paTargetStarResultsStruct.fluxTimeSeries];
    [variableTargetList] = ...
        identify_variable_targets([fluxTimeSeriesArray.values], ...
        [fluxTimeSeriesArray.gapIndicators], stellarVariabilityDetrendOrder, ...
        stellarVariabilityThreshold);

    % Ensure that we leave enough targets with which to perform the motion
    % polynomial fit (necessary for K2 processing).
    participatingTargetIndices = find(any(~gapArray, 1));
    maxNumTargetsToPrune = ...
        max([0, length(participatingTargetIndices) ...
             - motionConfigurationStruct.fitMinPoints]);
    if length(variableTargetList) > maxNumTargetsToPrune    
        [alerts] = add_alert(alerts, 'warning', ...
            [num2str( length(variableTargetList) - maxNumTargetsToPrune ), ...
             [' variable targets identified were not excluded ', ...
            'from motion polynomial fit due to insufficient PPA targets']]);
        disp(alerts(end).message);    

        variableTargetList = variableTargetList(1:maxNumTargetsToPrune);    
    end

    gapArray( : , variableTargetList) = true;
    clear fluxTimeSeriesArray

    nVariableTargets = length(variableTargetList);
    if nVariableTargets > 0
        [alerts] = add_alert(alerts, 'warning', ...
            [num2str(nVariableTargets), ' variable target(s) excluded from motion polynomial fit']);
        disp(alerts(end).message);
        variableTargetKeplerIds = ...
            [paTargetStarResultsStruct(variableTargetList).keplerId]';                                      %#ok<NASGU>
        save(paStateFileName, 'variableTargetKeplerIds', '-append');
    end % if

    % Exclude out of family centroids (based on centroid uncertainties) from
    % the motion polynomial fit if centroids are out of family for any cadence.
    keplerMags = [paTargetStarResultsStruct.keplerMag]';
    [outOfFamilyIndicators, distanceMeasures] = identify_out_of_family_centroids(keplerMags, ...
        centroidRowUncertainties, centroidColumnUncertainties, gapArray, ...
        madThresholdForCentroidOutliers, ...
        thresholdMultiplierForPositiveCentroidOutliers);
    outOfFamilyTargetList = find(any(outOfFamilyIndicators, 1)');

    % Ensure that we leave enough targets with which to perform the motion
    % polynomial fit (necessary for K2 processing). Prune the worst targets
    % first. 
    participatingTargetIndices = find(any(~gapArray, 1));
    maxNumTargetsToPrune = ...
        max([0, length(participatingTargetIndices) ...
             - motionConfigurationStruct.fitMinPoints]);
    if length(outOfFamilyTargetList) > maxNumTargetsToPrune
        [alerts] = add_alert(alerts, 'warning', ...
            [num2str( length(outOfFamilyTargetList) - maxNumTargetsToPrune ), ...
             [' out-of-family targets identified were not excluded ', ...
            'from motion polynomial fit due to insufficient PPA targets']]);
        disp(alerts(end).message);    

        targetBadness = sum(distanceMeasures, 1);
        sorted = sortrows([colvec(participatingTargetIndices), ...
                           colvec(targetBadness(participatingTargetIndices))], -2);
        outOfFamilyTargetList = sorted(1:maxNumTargetsToPrune, 1);
    end

    gapArray( : , outOfFamilyTargetList) = true;
    save(paStateFileName, 'outOfFamilyIndicators', '-append');

    nOutOfFamilyTargets = length(outOfFamilyTargetList);
    if nOutOfFamilyTargets > 0
        [alerts] = add_alert(alerts, 'warning', ...
            [num2str(nOutOfFamilyTargets), ' out of family target(s) excluded from motion polynomial fit']);
        disp(alerts(end).message);
        outOfFamilyTargetKeplerIds = ...
            [paTargetStarResultsStruct(outOfFamilyTargetList).keplerId]';                     %#ok<NASGU>
        save(paStateFileName, 'outOfFamilyTargetKeplerIds', '-append');
    end % if

end % if ~processingK2Data || k2PpaTargetRejectionEnabled


% Create vectors with the right ascension and declination of each of the
% target stars, in degrees.
targetRa = RA_HOURS_TO_DEGREES * [paTargetStarResultsStruct.raHours]';
targetDec = [paTargetStarResultsStruct.decDegrees]';

% Use AIC to determine optimal motion polynomial orders if enabled.
if aicOrderSelectionEnabled
    disp('    Determine optimal polynomial order using AIC...');
    [motionConfigurationStruct, rowAic, columnAic] = ...
        select_motion_polynomial_orders(centroidRows, centroidRowUncertainties, ...
        centroidColumns, centroidColumnUncertainties, gapArray, targetRa, targetDec, ...
        motionConfigurationStruct);
    disp(['    Row order = ',num2str(motionConfigurationStruct.rowFitOrder)]);
    disp(['    Col order = ',num2str(motionConfigurationStruct.columnFitOrder)]);
    
end % if aicOrderSelectionEnabled

% Do the motion polynomial fit and save diagnostic results to the state file.

% Perform the robust fit iteratively. 
% If a target is de-weighted below the threshold for a particular cadence
% then effectively set the weight to zero by gapping that target. If the
% target is de-weighted below the threshold in row then it should be
% de-weighted below the threshold in column as well. This condition is
% enforced by identifying the targets with robust weights below threshold
% in either row or column for any particular cadence and setting the
% gapArray flag. The robust fit and gapping process is iterated until the
% gapArray remains unchanged or either the maximum iterations or minimum
% number of points thresholds are reached.

motionGapIterations = 0;
done = false;
while ~done
    
    motionGapIterations = motionGapIterations + 1;
    disp(['        Motion fit gap adjustment: iteration ',num2str(motionGapIterations),'...']);

    [rowMotionStruct, columnMotionStruct, motionGapIndicators, rowChiSquare, ...
        nRowCentroids, columnChiSquare, nColumnCentroids, ...
        rowRobustWeightArray, columnRobustWeightArray] = ...
        fit_motion_polynomials_by_cadence(centroidRows, centroidRowUncertainties, ...
        centroidColumns, centroidColumnUncertainties, targetRa, targetDec, ...
        gapArray, motionConfigurationStruct);                                                 %#ok<NASGU>

    % Adjust gapArray. Set gap for cadence if target is de-weighted below
    % threshold in either row and column. Count the number of ungapped
    % targets for each cadence and compare to fitMinPoints. Require this
    % logical vector remain unchanged between iterations.
    oldGapArray = gapArray;
    oldEnoughTargets = sum(~oldGapArray,2) >= motionConfigurationStruct.fitMinPoints;
    gapArray( rowRobustWeightArray <= robustWeightGappingThreshold | columnRobustWeightArray <= robustWeightGappingThreshold ) = true;
    enoughTargets = sum(~gapArray,2) >= motionConfigurationStruct.fitMinPoints;
    allTargetsGapped = all(gapArray,2);

    % done? or ~done?
    if isequal(oldGapArray,gapArray) || motionGapIterations >= maxGappingIterations || ~isequal(oldEnoughTargets,enoughTargets)
        done = true;

        % throw alert if max iterations reached
        if motionGapIterations >= maxGappingIterations
            [alerts] = add_alert(alerts, 'warning', ...
                ['Maximum gapping iterations (',num2str(maxGappingIterations),') reached while fitting motion polynomials.']);
            disp(alerts(end).message);
        end   
        
        % throw alert if enoughTargets logical vector changes
        if ~isequal(oldEnoughTargets,enoughTargets)
            nOldEnoughTargets = numel(find(oldEnoughTargets));
            nEnoughTargets = numel(find(enoughTargets));
            [alerts] = add_alert(alerts, 'warning', ...
                ['Number of valid cadences with enough valid targets to perform motion',...
                ' polynomial fit changed during iterative gapping.'...
                ' Was ',num2str(nOldEnoughTargets),', is ',num2str(nEnoughTargets),...
                '. Stopping at iteration ',num2str(motionGapIterations),'.']);
            disp(alerts(end).message);
        end   
    end    
end



% The same targets must participate in the fit from cadence to cadence.
% Gap any targets containing any gaps over unit of work and redo fit
% provided there are enough data points remaining to do so. Otherwise go
% with the fit of the last iteration above.
oldGapArray = gapArray;
gapArray(:,any(gapArray(~allTargetsGapped,:))) = true;
numUngapped = numel(find(~all(gapArray)));
if( numUngapped > motionConfigurationStruct.fitMinPoints )
    disp('        Excluding chattering targets and performing final robust fit...');
        [rowMotionStruct, columnMotionStruct, motionGapIndicators, rowChiSquare, ...
            nRowCentroids, columnChiSquare, nColumnCentroids, ...
            rowRobustWeightArray, columnRobustWeightArray] = ...
            fit_motion_polynomials_by_cadence(centroidRows, centroidRowUncertainties, ...
            centroidColumns, centroidColumnUncertainties, targetRa, targetDec, ...
            gapArray, motionConfigurationStruct);                                               %#ok<NASGU>
else
    % restore gapArray
    gapArray = oldGapArray;
end

save(paStateFileName, 'rowChiSquare', 'nRowCentroids', ...
    'columnChiSquare', 'nColumnCentroids', 'rowRobustWeightArray', ...
    'columnRobustWeightArray', 'motionGapIterations', ...
    'motionConfigurationStruct', '-append');

% Initialize motion polynomial structure.
nCadences = length(startTimestamps);

motionPolyStruct = repmat(struct( ...
    'cadence', -1, ...
    'mjdStartTime', -1, ...
    'mjdMidTime', -1, ...
    'mjdEndTime', -1, ...
    'module', -1, ...
    'output', -1, ...
    'rowPoly', [], ...
    'rowPolyStatus', -1, ...
    'colPoly', [], ...
    'colPolyStatus', -1), [1, nCadences]);

% Create motion polynomial structure with metadata.
cadence = startCadence;  

for iCadence = 1 : nCadences
    polyStruct.cadence = cadence;
    polyStruct.mjdStartTime = startTimestamps(iCadence);
    polyStruct.mjdMidTime = midTimestamps(iCadence);
    polyStruct.mjdEndTime = endTimestamps(iCadence);
    polyStruct.module = ccdModule;
    polyStruct.output = ccdOutput;
    polyStruct.rowPoly = rowMotionStruct(iCadence);
    polyStruct.rowPolyStatus = ...
        double(~motionGapIndicators(iCadence));
    polyStruct.colPoly = columnMotionStruct(iCadence);
    polyStruct.colPolyStatus = ...
        double(~motionGapIndicators(iCadence));
    motionPolyStruct(iCadence) = polyStruct;
    cadence = cadence + 1;
end % for iCadence

% Check for cadence consistency.
if cadence - 1 ~= endCadence
    error('PA:fitMotionPolynomials:cadenceInconsistency', ...
        'Start cadence = %d, End cadence = %d; Number of timestamps = %d', ...
        startCadence, endCadence, nCadences)
end

% Generate alert if the motion polynomials could not be computed for any
% non-gapped cadence.
nGaps = sum(motionGapIndicators & ~cadenceGapIndicators);
if nGaps > 0
    [alerts] = add_alert(alerts, 'warning', ...
        ['Motion polynomials could not be obtained for ', num2str(nGaps), ' valid cadence(s)']);
    disp(alerts(end).message);
end % if

% Plot the AIC for motion polynomial order selection if AIC order selection
% is enabled.
close all;
isLandscapeOrientation = true;
includeTimeFlag = false;
printJpgFlag = false;

if aicOrderSelectionEnabled
    order = (0 : length(rowAic) - 1)';
    isValidRowAic = rowAic ~= 0;
    isValidColumnAic = columnAic ~= 0;
    figure;
    plot(order(isValidRowAic), rowAic(isValidRowAic), 'o-b');
    hold on;
    plot(order(isValidColumnAic), columnAic(isValidColumnAic), 'o-r');
    hold off;
    grid
    title(['[PA] Motion Fit AIC -- Module ', num2str(ccdModule), ...
        ' /  Output ', num2str(ccdOutput)]);
    legend('Row', 'Column');
    xlabel('Order');
    ylabel('AIC');
    plot_to_file('pa_motion_aic', isLandscapeOrientation, includeTimeFlag, ...
        printJpgFlag);
    close;
end % if

% Plot the motion polynomial fits for each cadence if the debug level is
% greater than zero.
if debugLevel
    close all;
    figure;
    for iCadence = 1 : nCadences
        centroidRowValues = centroidRows(iCadence, : )';
        centroidColumnValues = centroidColumns(iCadence, : )';
        gapIndicators = gapArray(iCadence, : )';
        [centroidRowEstimates] = weighted_polyval2d(targetRa, targetDec, ...
            rowMotionStruct(iCadence));
        [centroidColumnEstimates] = weighted_polyval2d(targetRa, targetDec, ...
            columnMotionStruct(iCadence));
        plot3(targetRa(~gapIndicators), targetDec(~gapIndicators), ...
            centroidRowValues(~gapIndicators) - centroidRowEstimates(~gapIndicators), '.b');
        hold on;
        plot3(targetRa(~gapIndicators), targetDec(~gapIndicators), ...
            centroidColumnValues(~gapIndicators) - centroidColumnEstimates(~gapIndicators), '.r');
        hold off;
        title(['[PA] Motion Fit Residuals -- Cadence ', num2str(cadenceNumbers(iCadence)), ' / Order ', ...
            num2str(rowMotionStruct(iCadence).order), '-', num2str(columnMotionStruct(iCadence).order)]);
        xlabel('Target Ra (deg)');
        ylabel('Target Dec (deg)');
        zlabel('Residual (pixels)');
        pause(1)
    end % for iCadence
    close;
end % if

% Append alerts to PA results structure.
paResultsStruct.alerts = alerts;

% Return.
return
